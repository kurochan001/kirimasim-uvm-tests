/*
:name: test_run_timeout_default_overridable_argument_allows_a_later_absolute_limit
:description: run timeout default overridable argument allows a later absolute limit
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.7.3.3 9.8.1.5 9.3.1.7.2 9.3.1.7.3 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_run_timeout_default_overridable_argument_allows_a_later_absolute_limit.expected
*/
module test_run_timeout_default_overridable_argument_allows_a_later_absolute_limit;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class t extends uvm_test;
    `uvm_component_utils(t)
    bit completed=0;
    function new(string name,uvm_component parent);super.new(name,parent);endfunction
    virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);#8;completed=1;phase.drop_objection(this);
    endtask
    virtual function void final_phase(uvm_phase phase);
      $display("UT: timeout_override crossed_old_limit %0d completed %0d before_new_limit %0d",
        $time>5,completed,$time<20);
    endfunction
  endclass
  initial begin
    uvm_root root;
    root=uvm_root::get();root.set_timeout(5);root.set_timeout(20);run_test("t");
  end
  initial begin #100;$fatal(1,"timeout override watchdog");end
endmodule
