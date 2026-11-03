/*
:name: test_heartbeat_declared_object_base_preserves_selected_name_and_identity
:description: heartbeat declared object base preserves selected name and identity (IEEE 1800.2-2020 Section 10.6.1)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.6.1 10.6.2.1 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_heartbeat_declared_object_base_preserves_selected_name_and_identity.expected
*/
// Construct a heartbeat in an actual component context without starting its
// monitor. This checks declared object inheritance/name only, not monitoring,
// window activity, private context fields or factory behavior.
module test_heartbeat_declared_object_base_preserves_selected_name_and_identity;
  import uvm_pkg::*;
  class owner extends uvm_component;
    function new(); super.new("scope",null); endfunction
  endclass
  initial begin
    automatic owner context_value = new();
    automatic uvm_heartbeat subject = new("selected",context_value);
    automatic uvm_object base_view = subject;
    $display("UT: heartbeat_base identity %0d selected_name %0d",base_view == subject,
             base_view.get_name() == "selected");
    $finish;
  end
endmodule
