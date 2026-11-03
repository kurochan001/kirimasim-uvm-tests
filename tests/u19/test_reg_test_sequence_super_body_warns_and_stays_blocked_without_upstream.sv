/*
:name: test_reg_test_sequence_super_body_warns_and_stays_blocked_without_upstream
:description: reg test sequence super body warns and stays blocked without upstream (IEEE 1800.2-2020 Section 19.4.1.4.2)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.4.1.4.2 19.4.1.2 14.2.5.11 6.6.3.2 6.6.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_test_sequence_super_body_warns_and_stays_blocked_without_upstream.expected
*/
// An original test body incorrectly calls super.body on a compatible bound
// sequencer without an upstream reg_seqr. Observe the required warning and
// nonreturn after a positive delay; then kill only for cleanup. Warning
// ID/text,
// null-bus behavior and required termination post-hooks remain unconstrained.
module test_reg_test_sequence_super_body_warns_and_stays_blocked_without_upstream;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class warning_probe extends uvm_report_catcher;
    int warnings = 0;
    function action_e catch();
      if (get_severity() == UVM_WARNING) begin warnings++; return CAUGHT; end
      return THROW;
    endfunction
  endclass
  class test_sequence extends uvm_reg_sequence;
    virtual task body(); super.body(); endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer#(uvm_reg_item) bus;
    test_sequence subject;
    warning_probe probe;
    bit returned = 0;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase); bus = new("bus",this); subject = new(); probe = new();
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this); uvm_report_cb::add(null,probe);
      fork begin subject.start(bus); returned = 1; end join_none
      #3;
      $display("UT: super_body warning %0d returned %0d active %0d",probe.warnings,returned,
               subject.get_sequence_state() == UVM_BODY);
      subject.kill(); #1;
      $display("UT: super_body_cleanup stopped %0d returned %0d",
               subject.get_sequence_state() == UVM_STOPPED,returned);
      uvm_report_cb::delete(null,probe); phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1,"super-body watchdog expired"); end
endmodule
