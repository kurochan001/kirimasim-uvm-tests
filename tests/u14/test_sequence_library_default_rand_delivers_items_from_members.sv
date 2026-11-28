/*
:name: test_sequence_library_default_rand_delivers_items_from_members
:description: The default RAND library starts registered children that deliver items through its sequencer
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.4 14.4.4.1 14.4.4.6 14.4.4.7 14.4.5.3 14.1.2.5 14.1.2.7 14.2.3.1 14.2.6.2 14.2.6.3 15.2.1.2.1 15.2.1.2.3 B.3.2.2 F.2.4.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_library_default_rand_delivers_items_from_members.expected
*/
// What it checks:
// The default RAND library runs members that send through its sequencer.
//
// How the expected output follows from the standard:
// 1800.2-2020 14.4 (UVM-LIBRARY-DEFAULT-RAND-MEMBER-ITEMS) executes registered
// child sequences. A singleton registration removes selection uncertainty.
// The default count is ten (14.4.4.6), and each child completes finish_item
// only after the driver's completion notification (14.2.6.3).
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_sequence_library_default_rand_delivers_items_from_members;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    int ordinal;

    function new(string name = "packet");
      super.new(name);
    endfunction
  endclass

  class member_sequence extends uvm_sequence#(packet);
    `uvm_object_utils(member_sequence)
    static int started = 0;
    static int completed = 0;
    static uvm_sequence_base expected_parent;
    static uvm_sequencer_base expected_sequencer;
    static bit context_matches = 1;

    function new(string name = "member_sequence");
      super.new(name);
    endfunction

    virtual task body();
      packet item_value;
      started++;
      context_matches &= get_parent_sequence() == expected_parent &&
                         get_sequencer() == expected_sequencer;
      item_value = new("request");
      item_value.ordinal = started;
      start_item(item_value);
      finish_item(item_value);
      completed++;
    endtask
  endclass

  class selected_library extends uvm_sequence_library#(packet);
    `uvm_object_utils(selected_library)
    `uvm_sequence_library_utils(selected_library)

    function new(string name = "selected_library");
      super.new(name);
      init_sequence_library();
    endfunction
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    selected_library library_instance;
    uvm_sequencer#(packet) sequencer;
    uvm_driver#(packet) driver;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      library_instance = new("library_instance");
      library_instance.add_sequence(member_sequence::get_type());
      sequencer = new("sequencer", this);
      sequencer.disable_auto_item_recording();
      driver = new("driver", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction

    virtual task run_phase(uvm_phase phase);
      packet observed;
      bit [9:0] received_ordinals;
      bit held_until_ack;
      bit library_returned;

      received_ordinals = '0;
      held_until_ack = 1;
      library_returned = 0;
      phase.raise_objection(this);
      member_sequence::expected_parent = library_instance;
      member_sequence::expected_sequencer = sequencer;

      fork
        begin
          library_instance.start(sequencer);
          library_returned = 1;
        end
        begin
          for (int index = 1; index <= 10; index++) begin
            driver.seq_item_port.get_next_item(observed);
            if (observed == null || !(observed.ordinal inside {[1:10]}))
              $fatal(1, "driver received an invalid member request");
            received_ordinals[observed.ordinal - 1] = 1;
            #1;
            held_until_ack &= member_sequence::completed == index - 1 &&
                              !library_returned;
            driver.seq_item_port.item_done();
          end
        end
      join

      $display("UT: members started %0d completed %0d context %0d",
               member_sequence::started, member_sequence::completed,
               member_sequence::context_matches);
      $display("UT: driver all_ordinals %0d waited_for_ack %0d library_returned %0d",
               &received_ordinals, held_until_ack, library_returned);
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #100;
    $fatal(1, "sequence library transport watchdog expired");
  end
endmodule
