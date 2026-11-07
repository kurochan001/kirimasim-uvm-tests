// Independent gates expose pending-drop cancellation and public counts.
// Blocking uses the documented objection/callback tasks. The component
// function/task signature discrepancy remains a separate, unchanged test.
uvm_objection subject_base106;
uvm_component gate_base106, upper_base106;
uvm_object renewed_source106;
time drop_time106;

class monitor106;
  int entries = 0;
  bit entered = 0, release_old = 0;
  bit old_context = 1, old_drained = 1, last_context = 0;
  function void reset();
    entries = 0; entered = 0; release_old = 0;
    old_context = 1; old_drained = 1; last_context = 0;
  endfunction
  task visit(uvm_object source, string description, int count);
    entries++;
    if (description == "old") begin
      old_context &= source == gate_base106 && count == OLD106;
      old_drained &= $time >= drop_time106 + DRAIN106;
      entered = 1;
      if (CALLBACK106) wait (release_old);
    end
    if (description == "last")
      last_context = source == renewed_source106 && count == NEW106;
  endtask
endclass
monitor106 monitor_value106;

class subject106 extends uvm_objection;
  function new(); super.new("subject"); endfunction
  virtual task all_dropped(uvm_object obj, uvm_object source_obj,
                           string description, int count);
    if (!REGISTERED106 && obj == gate_base106)
      monitor_value106.visit(source_obj, description, count);
    super.all_dropped(obj, source_obj, description, count);
  endtask
endclass

class observer106 extends uvm_objection_callback;
  int again_raises = 0, again_calls = 0, again_drops = 0;
  bit again_context = 1;
  function new();
    super.new("observer"); void'(callback_mode(1));
  endfunction
  function void reset();
    again_raises = 0; again_calls = 0; again_drops = 0; again_context = 1;
  endfunction
  virtual function void raised(uvm_objection objection, uvm_object obj,
                               uvm_object source_obj, string description, int count);
    if (objection == subject_base106 && obj == upper_base106 && description == "again") begin
      again_raises += count; again_calls++;
      again_context &= source_obj == renewed_source106;
    end
  endfunction
  virtual function void dropped(uvm_objection objection, uvm_object obj,
                                uvm_object source_obj, string description, int count);
    if (objection == subject_base106 && obj == upper_base106 && description == "again")
      again_drops += count;
  endfunction
  virtual task all_dropped(uvm_objection objection, uvm_object obj,
                           uvm_object source_obj, string description, int count);
    if (REGISTERED106 && objection == subject_base106 && obj == gate_base106)
      monitor_value106.visit(source_obj, description, count);
  endtask
endclass

class node106 extends uvm_component;
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
endclass

class t extends uvm_test;
  `uvm_component_utils(t)
  node106 upper, gate, leaf, peer;
  subject106 subject;
  uvm_objection other;
  observer106 observer;
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    upper = new("upper", this); gate = new("gate", upper);
    leaf = new("leaf", gate); peer = new("peer", this);
    subject = new(); other = new("other"); observer = new();
    monitor_value106 = new(); subject_base106 = subject;
    gate_base106 = gate; upper_base106 = upper;
    renewed_source106 = DESCENDANT106 ? leaf : gate;
    subject.set_propagate_mode(1); subject.set_drain_time(gate, DRAIN106);
    uvm_objection_cbs_t::add(subject, observer);
  endfunction
  function void snapshot(int round_number, string stage);
    $display("UT: r%0d %s local gate %0d leaf %0d upper %0d peer %0d",
             round_number, stage, subject.get_objection_count(gate),
             subject.get_objection_count(leaf), subject.get_objection_count(upper),
             subject.get_objection_count(peer));
    $display("UT: r%0d %s total gate %0d upper %0d root %0d", round_number, stage,
             subject.get_objection_total(gate), subject.get_objection_total(upper),
             subject.get_objection_total());
    $display("UT: r%0d %s other gate %0d root %0d", round_number, stage,
             other.get_objection_count(gate), other.get_objection_total());
  endfunction
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    other.raise_objection(gate, "independent", 7);
    $display("UT: config mode %0d drain %0d", subject.get_propagate_mode(),
             subject.get_drain_time(gate));
    for (int round_number = 0; round_number < 2; round_number++) begin
      monitor_value106.reset(); observer.reset();
      subject.raise_objection(peer, "peer", PEER106);
      subject.raise_objection(gate, "initial", OLD106);
      snapshot(round_number, "raised");
      drop_time106 = $time;
      subject.drop_objection(gate, "old", OLD106);
      if (CALLBACK106) begin
        wait (monitor_value106.entered);
        #1;
      end
      else #1;
      snapshot(round_number, "pending");
      if (CALLBACK106)
        $display("UT: r%0d pending entered %0d context %0d drained %0d", round_number,
                 monitor_value106.entered, monitor_value106.old_context,
                 monitor_value106.old_drained);
      else
        $display("UT: r%0d pending entered %0d", round_number, monitor_value106.entered);
      subject.raise_objection(renewed_source106, "again", NEW106);
      snapshot(round_number, "again");
      if (NEW106 >= OLD106) begin
        $display("UT: r%0d net raises %0d calls %0d", round_number,
                 observer.again_raises, observer.again_calls);
        if (NEW106 > OLD106)
          $display("UT: r%0d net source %0d", round_number, observer.again_context);
      end
      else
        $display("DIAG106: r%0d compensation raises %0d calls %0d drops %0d", round_number,
                 observer.again_raises, observer.again_calls, observer.again_drops);
      monitor_value106.release_old = 1;
      #(DRAIN106 + 1);
      snapshot(round_number, "held");
      $display("UT: r%0d held entries %0d", round_number, monitor_value106.entries);
      subject.drop_objection(renewed_source106, "last", NEW106);
      #(DRAIN106 + 2);
      snapshot(round_number, "final");
      $display("UT: r%0d final entries %0d context %0d", round_number,
               monitor_value106.entries, monitor_value106.last_context);
      subject.drop_objection(peer, "peer last", PEER106);
      #1;
      snapshot(round_number, "peer_done");
    end
    uvm_objection_cbs_t::delete(subject, observer);
    other.clear();
    $display("UT: cleanup subject %0d other %0d", subject.get_objection_total(),
             other.get_objection_total());
    phase.drop_objection(this);
  endtask
endclass
