/*
:name: test_callback_macro_unregistered_delete_typewide_82
:description: Using an unregistered callback pair requires a warning without prescribing queue effects
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.4.1 10.7.2.3.1 10.7.2.3.3 6.6.5 6.3.5.2 1800-2023 6.21 8.20 8.23 8.25 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers82/callbacks82.svh
:expected_exit: 0
:expected_stdout: @test_callback_macro_unregistered_delete_typewide_82.expected
*/
// Original callback arithmetic/trace is stimulus; no private registration bits.
module test_callback_macro_unregistered_delete_typewide_82;
  import uvm_pkg::*;
  `include "callbacks82.svh"
  initial begin
    automatic unregistered_owner82 target=new();
    automatic callback82 cb=new("U");
    automatic warning_observer82 observer=new();
    uvm_root::get().set_report_severity_action(UVM_WARNING,UVM_DISPLAY);
    uvm_report_cb::add(null,observer); observer.active=1;
    uvm_callbacks#(unregistered_owner82,callback82)::delete(null,cb);
    observer.active=0;
    $display("UT: cb82 unregistered_delete_typewide warning %0d",observer.warnings>0);
    // Empty delete and add outcomes do not establish a validation mechanism.
    uvm_report_cb::delete(null,observer);
    $finish;
  end
endmodule
