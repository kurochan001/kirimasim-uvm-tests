/*
:name: test_objection_mode_change_while_draining_reports_error_and_preserves_mode
:description: objection mode change while draining reports error and preserves mode (IEEE 1800.2-2020 Section 10.5.1.3.2)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.5.1.3.2 10.5.1.3.1 10.5.1.3.3 10.5.1.3.4 10.5.1.3.7 10.5.1.5.4 6.6.3.2 6.6.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_objection_mode_change_while_draining_reports_error_and_preserves_mode.expected
*/
// Make an actual raised or positive-drain condition before changing mode.
// Catch the required ERROR without depending on its ID or text. The mode must
// remain unchanged until idle, when the selected change succeeds. No fatal
// severity substitution, private state or arbitrary racing transition is used.
module test_objection_mode_change_while_draining_reports_error_and_preserves_mode;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class error_probe extends uvm_report_catcher;
    int errors = 0;
    function action_e catch();
      if (get_severity() == UVM_ERROR) begin errors++; return CAUGHT; end
      return THROW;
    endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_objection subject;
    uvm_object source;
    error_probe probe;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase); subject = new("subject"); source = new("source"); probe = new();
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this); uvm_report_cb::add(subject,probe);
      subject.set_drain_time(source,4); subject.raise_objection(source);
      subject.drop_objection(source); #1;
      subject.set_propagate_mode(0);
      $display("UT: active_mode_change errors %0d mode %0d source %0d root %0d",probe.errors,
               subject.get_propagate_mode(),subject.get_objection_total(source),
               subject.get_objection_total(uvm_root::get()));

      #6; subject.set_propagate_mode(0);
      $display("UT: idle_mode_change errors %0d mode %0d root %0d",probe.errors,
               subject.get_propagate_mode(),subject.get_objection_total(uvm_root::get()));
      uvm_report_cb::delete(subject,probe); phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1,"mode-change watchdog expired"); end
endmodule
