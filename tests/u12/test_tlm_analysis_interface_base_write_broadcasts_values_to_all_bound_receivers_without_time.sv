/*
:name: test_tlm_analysis_interface_base_write_broadcasts_values_to_all_bound_receivers_without_time
:description: tlm analysis interface base write broadcasts values to all bound receivers without time (IEEE 1800.2-2020 Section 12.2.4.2.12)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.4.2.12 12.2.10.1.4 12.2.4.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_analysis_interface_base_write_broadcasts_values_to_all_bound_receivers_without_time.expected
*/
// Upcast the actual analysis port to the default integer interface and call
// its
// virtual write. Both real bound subscribers receive each supplied value
// without
// time advance. No ordering between receivers, object cloning or physical bus
// monitor is inferred.
module test_tlm_analysis_interface_base_write_broadcasts_values_to_all_bound_receivers_without_time;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class observer extends uvm_subscriber#(int);
    int values[$];
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void write(int value); values.push_back(value); endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_analysis_port#(int) writer;
    observer first,second;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase); writer = new("writer",this);
      first = new("first",this); second = new("second",this);
    endfunction
    function void connect_phase(uvm_phase phase);
      writer.connect(first.analysis_export); writer.connect(second.analysis_export);
    endfunction
    task run_phase(uvm_phase phase);
      automatic uvm_tlm_if_base#() interface_view = writer;
      time started;
      phase.raise_objection(this); started = $time;
      interface_view.write(13); interface_view.write(27);
      $display("UT: analysis_base_broadcast immediate %0d counts %0d/%0d values %0d/%0d/%0d/%0d",
               $time == started,first.values.size(),second.values.size(),first.values[0],
               first.values[1],second.values[0],second.values[1]);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1,"analysis interface watchdog expired"); end
endmodule
