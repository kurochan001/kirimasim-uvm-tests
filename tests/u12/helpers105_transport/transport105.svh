// Original endpoints expose forwarding and argument semantics, not a
// prescribed transaction algorithm. Rebinding an input handle differs from
// mutating its object; custom phases have no asserted base-protocol meaning.
typedef enum {OUTER_BEGIN105, OUTER_ACTIVE105, INNER_BEGIN105,
              INNER_DONE105, OUTER_DONE105} phase105;

function automatic bit annotation105(uvm_tlm_time value, real wanted);
  real difference;
  difference = value.get_abstime(1.0e-9) - wanted;
  if (difference < 0.0) difference = -difference;
  return difference < 1.0e-6;
endfunction

class message105 extends uvm_object;
  int value;
  function new(string name);
    super.new(name);
  endfunction
endclass

class context105;
  message105 a, b, inner_value;
  uvm_tlm_time da, db, inner_delay;
  phase105 outer_phase, inner_phase;
  int round_number;
  function new();
    a = new("a");
    b = new("b");
    da = new("da", 1.0e-12);
    db = new("db", 1.0e-12);
    inner_value = SHARED105 ? a : b;
    inner_delay = SHARED105 ? da : db;
  endfunction
endclass

class endpoint105 extends uvm_component;
  uvm_tlm_b_transport_imp#(message105, endpoint105) blocking_imp;
  uvm_tlm_nb_transport_fw_imp#(message105, phase105, endpoint105) forward_imp;
  uvm_tlm_nb_transport_bw_imp#(message105, phase105, endpoint105) backward_imp;
  uvm_tlm_b_transport_port#(message105) blocking_port;
  uvm_tlm_nb_transport_fw_port#(message105, phase105) forward_port;
  uvm_tlm_nb_transport_bw_port#(message105, phase105) backward_port;
  context105 state;
  message105 shadow[2];
  uvm_tlm_time shadow_delay[2];
  int depth = 0, calls = 0;
  function new(string name, uvm_component parent);
    super.new(name, parent);
    if (KIND105 == 0) blocking_imp = new("blocking_imp", this);
    if (KIND105 == 1) forward_imp = new("forward_imp", this);
    if (KIND105 == 2) backward_imp = new("backward_imp", this);
    for (int i = 0; i < 2; i++) begin
      shadow[i] = new($sformatf("shadow%0d", i));
      shadow_delay[i] = new($sformatf("shadow_delay%0d", i), 1.0e-12);
    end
  endfunction
  function void enter105(message105 value, uvm_tlm_time delay, int level);
    bit handles;
    handles = value == (level == 0 ? state.a : state.inner_value) &&
              delay == (level == 0 ? state.da : state.inner_delay);
    value.value += level == 0 ? 10 : 7;
    delay.set_abstime(level == 0 ? 5.0 : 11.0, 1.0e-9);
    $display("UT: round %0d enter level %0d handles %0d value %0d annotation %0d",
             state.round_number, level, handles, value.value,
             annotation105(delay, level == 0 ? 5.0 : 11.0));
  endfunction
  function void rebound105(message105 value, uvm_tlm_time delay,
                           message105 original, uvm_tlm_time original_delay, int level);
    bit caller_kept;
    caller_kept = original == (level == 0 ? state.a : state.inner_value) &&
                  original_delay == (level == 0 ? state.da : state.inner_delay);
    value.value = 901 + level;
    delay.set_abstime(50.0 + level, 1.0e-9);
    $display("UT: round %0d rebound level %0d local %0d caller %0d value %0d annotation %0d",
             state.round_number, level, value == shadow[level] && delay == shadow_delay[level],
             caller_kept, value.value, annotation105(delay, 50.0 + level));
  endfunction
  function uvm_tlm_sync_e invoke105(message105 value, ref phase105 phase,
                                     input uvm_tlm_time delay);
    if (KIND105 == 1) return forward_port.nb_transport_fw(value, phase, delay);
    return backward_port.nb_transport_bw(value, phase, delay);
  endfunction
  function uvm_tlm_sync_e nb_transport_fw(message105 value, ref phase105 phase,
                                      input uvm_tlm_time delay);
    automatic message105 original = value;
    automatic uvm_tlm_time original_delay = delay;
    automatic int level = depth;
    automatic bit incoming = phase == (level == 0 ? OUTER_BEGIN105 : INNER_BEGIN105);
    uvm_tlm_sync_e nested;
    depth++;
    calls++;
    enter105(value, delay, level);
    phase = level == 0 ? OUTER_ACTIVE105 : INNER_DONE105;
    $display("UT: round %0d phase level %0d incoming %0d live %0d",
             state.round_number, level, incoming,
             phase == (level == 0 ? state.outer_phase : state.inner_phase));
    value = shadow[level];
    delay = shadow_delay[level];
    rebound105(value, delay, original, original_delay, level);
    if (level == 0) begin
      nested = invoke105(state.inner_value, state.inner_phase, state.inner_delay);
      $display("UT: round %0d resume outer_locals %0d updated %0d depth %0d",
               state.round_number, value == shadow[0] && delay == shadow_delay[0],
               nested == UVM_TLM_UPDATED, depth);
      $display("UT: round %0d resume_phase outer %0d inner %0d", state.round_number,
               phase == OUTER_ACTIVE105, state.inner_phase == INNER_DONE105);
      original.value += 100;
      original_delay.set_abstime(17.0, 1.0e-9);
      phase = OUTER_DONE105;
      $display("UT: round %0d final_phase live %0d", state.round_number,
               state.outer_phase == OUTER_DONE105);
    end
    depth--;
    return level == 0 ? UVM_TLM_COMPLETED : UVM_TLM_UPDATED;
  endfunction

  function uvm_tlm_sync_e nb_transport_bw(message105 value, ref phase105 phase,
                                      input uvm_tlm_time delay);
    automatic message105 original = value;
    automatic uvm_tlm_time original_delay = delay;
    automatic int level = depth;
    automatic bit incoming = phase == (level == 0 ? OUTER_BEGIN105 : INNER_BEGIN105);
    uvm_tlm_sync_e nested;
    depth++;
    calls++;
    enter105(value, delay, level);
    phase = level == 0 ? OUTER_ACTIVE105 : INNER_DONE105;
    $display("UT: round %0d phase level %0d incoming %0d live %0d",
             state.round_number, level, incoming,
             phase == (level == 0 ? state.outer_phase : state.inner_phase));
    value = shadow[level];
    delay = shadow_delay[level];
    rebound105(value, delay, original, original_delay, level);
    if (level == 0) begin
      nested = invoke105(state.inner_value, state.inner_phase, state.inner_delay);
      $display("UT: round %0d resume outer_locals %0d updated %0d depth %0d",
               state.round_number, value == shadow[0] && delay == shadow_delay[0],
               nested == UVM_TLM_UPDATED, depth);
      $display("UT: round %0d resume_phase outer %0d inner %0d", state.round_number,
               phase == OUTER_ACTIVE105, state.inner_phase == INNER_DONE105);
      original.value += 100;
      original_delay.set_abstime(17.0, 1.0e-9);
      phase = OUTER_DONE105;
      $display("UT: round %0d final_phase live %0d", state.round_number,
               state.outer_phase == OUTER_DONE105);
    end
    depth--;
    return level == 0 ? UVM_TLM_COMPLETED : UVM_TLM_UPDATED;
  endfunction

  task b_transport(message105 value, uvm_tlm_time delay);
    automatic message105 original = value;
    automatic uvm_tlm_time original_delay = delay;
    automatic int level = depth;
    depth++;
    calls++;
    enter105(value, delay, level);
    value = shadow[level];
    delay = shadow_delay[level];
    rebound105(value, delay, original, original_delay, level);
    if (level == 0) begin
      #1;
      blocking_port.b_transport(state.inner_value, state.inner_delay);
      $display("UT: round %0d resume outer_locals %0d depth %0d",
               state.round_number, value == shadow[0] && delay == shadow_delay[0], depth);
      #1;
      original.value += 100;
      original_delay.set_abstime(17.0, 1.0e-9);
    end
    else #2;
    depth--;
  endtask
endclass

class relay105 extends uvm_component;
  uvm_tlm_b_transport_export#(message105) blocking_export;
  uvm_tlm_nb_transport_fw_export#(message105, phase105) forward_export;
  uvm_tlm_nb_transport_bw_export#(message105, phase105) backward_export;
  function new(string name, uvm_component parent);
    super.new(name, parent);
    if (KIND105 == 0) blocking_export = new("blocking_export", this);
    if (KIND105 == 1) forward_export = new("forward_export", this);
    if (KIND105 == 2) backward_export = new("backward_export", this);
  endfunction
endclass

class t extends uvm_test;
  `uvm_component_utils(t)
  uvm_tlm_b_transport_port#(message105) blocking_port;
  uvm_tlm_nb_transport_fw_port#(message105, phase105) forward_port;
  uvm_tlm_nb_transport_bw_port#(message105, phase105) backward_port;
  relay105 outer, inner;
  endpoint105 target;
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    outer = new("outer", this);
    inner = new("inner", outer);
    target = new("target", inner);
    if (KIND105 == 0) begin
      blocking_port = new("blocking_port", this);
      target.blocking_port = blocking_port;
    end
    if (KIND105 == 1) begin
      forward_port = new("forward_port", this);
      target.forward_port = forward_port;
    end
    if (KIND105 == 2) begin
      backward_port = new("backward_port", this);
      target.backward_port = backward_port;
    end
  endfunction
  function void connect_phase(uvm_phase phase);
    if (KIND105 == 0) begin
      blocking_port.connect(outer.blocking_export);
      outer.blocking_export.connect(inner.blocking_export);
      inner.blocking_export.connect(target.blocking_imp);
    end
    if (KIND105 == 1) begin
      forward_port.connect(outer.forward_export);
      outer.forward_export.connect(inner.forward_export);
      inner.forward_export.connect(target.forward_imp);
    end
    if (KIND105 == 2) begin
      backward_port.connect(outer.backward_export);
      outer.backward_export.connect(inner.backward_export);
      inner.backward_export.connect(target.backward_imp);
    end
  endfunction
  task run_phase(uvm_phase phase);
    automatic context105 state = new();
    automatic message105 fixed_a = state.a;
    automatic message105 fixed_b = state.b;
    automatic uvm_tlm_time fixed_da = state.da;
    automatic uvm_tlm_time fixed_db = state.db;
    time before_time;
    uvm_tlm_sync_e result;
    phase.raise_objection(this);
    target.state = state;
    for (int round_number = 0; round_number < 2; round_number++) begin
      state.round_number = round_number;
      state.a.value = round_number == 0 ? 13 : 29;
      state.b.value = round_number == 0 ? 31 : 47;
      state.da.set_abstime(round_number == 0 ? 2.0 : 4.0, 1.0e-9);
      state.db.set_abstime(round_number == 0 ? 3.0 : 6.0, 1.0e-9);
      state.outer_phase = OUTER_BEGIN105;
      state.inner_phase = INNER_BEGIN105;
      before_time = $time;
      if (KIND105 == 0) blocking_port.b_transport(state.a, state.da);
      else if (KIND105 == 1)
        result = forward_port.nb_transport_fw(state.a, state.outer_phase, state.da);
      else result = backward_port.nb_transport_bw(state.a, state.outer_phase, state.da);
      $display("UT: round %0d returned handles %0d a %0d b %0d inner %0d",
               round_number, state.a == fixed_a && state.b == fixed_b &&
               state.da == fixed_da && state.db == fixed_db, state.a.value, state.b.value,
               state.inner_value.value);
      $display("UT: round %0d timing delay_a %0d delay_b %0d elapsed %0d calls %0d depth %0d",
               round_number, annotation105(state.da, 17.0),
               annotation105(state.db, SHARED105 ? (round_number == 0 ? 3.0 : 6.0) : 11.0),
               $time - before_time, target.calls, target.depth);
      if (KIND105 != 0)
        $display("UT: round %0d returned_phase outer %0d inner %0d completed %0d",
                 round_number, state.outer_phase == OUTER_DONE105,
                 state.inner_phase == INNER_DONE105, result == UVM_TLM_COMPLETED);
      $display("UT: round %0d shadows values %0d/%0d delays %0d/%0d independent %0d",
               round_number, target.shadow[0].value, target.shadow[1].value,
               annotation105(target.shadow_delay[0], 50.0),
               annotation105(target.shadow_delay[1], 51.0),
               target.shadow[0] != fixed_a && target.shadow[0] != fixed_b &&
               target.shadow[1] != fixed_a && target.shadow[1] != fixed_b &&
               target.shadow[0] != target.shadow[1] &&
               target.shadow_delay[0] != fixed_da && target.shadow_delay[0] != fixed_db &&
               target.shadow_delay[1] != fixed_da && target.shadow_delay[1] != fixed_db &&
               target.shadow_delay[0] != target.shadow_delay[1]);
    end
    phase.drop_objection(this);
  endtask
endclass
