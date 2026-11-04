/*
:name: test_run_phase_timeout_reports_fatal_at_the_locked_absolute_limit
:description: run phase timeout reports fatal at the locked absolute limit
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.8.1.5 F.7.3.3 6.6.3.2 6.6.5 10.7.2.3.1 9.3.1.7.2 9.3.1.7.3 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_run_phase_timeout_reports_fatal_at_the_locked_absolute_limit.expected
*/
module test_run_phase_timeout_reports_fatal_at_the_locked_absolute_limit;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class fatal_probe extends uvm_report_catcher;
    function new();super.new("fatal_probe54");endfunction
    virtual function action_e catch();
      if (get_severity()==UVM_FATAL)
        $display("UT: run_timeout fatal 1 at_limit %0d",$time==5);
      return THROW;
    endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    function new(string name,uvm_component parent);super.new(name,parent);endfunction
    virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);#20;
      $display("UT: run_timeout unexpected_completion");phase.drop_objection(this);
    endtask
  endclass
  initial begin
    automatic fatal_probe observer=new();
    uvm_root root;
    root=uvm_root::get();root.set_timeout(5,0);root.set_timeout(30,1);
    uvm_report_cb::add(null,observer);run_test("t");
  end
  initial begin #100;$fatal(1,"timeout watchdog");end
endmodule
