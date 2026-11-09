/*
:name: test_phase_callback_constructor_keeps_default_names_and_callback_object_views
:description: phase callback constructor keeps default names and callback object views
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.3.3.2.1 9.3.3.1 5.3.4.2 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_phase_callback_constructor_keeps_default_names_and_callback_object_views.expected
*/
// What it checks:
// 1. The callback constructor preserves its printed default and explicit
//    names.
// 2. A phase callback extends uvm_callback.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 9.3.3.2.1 (UVM-PHASE-CONTRACT-CALLBACK-NEW-NAMES) gives rule
//    1 above. Setup: Default and explicitly named callback objects are viewed
//    through callback/object handles. Expected: Default unnamed-uvm_phase_cb
//    and explicit chosen53 names both match.
// 2. 1800.2-2020 9.3.3.1 (UVM-PHASE-CONTRACT-CALLBACK-BASE-VIEW) gives rule 2
//    above. Setup: Default and explicitly named callback objects are viewed
//    through callback/object handles. Expected: Callback/object views cast
//    back to the same callback.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_phase_callback_constructor_keeps_default_names_and_callback_object_views;
  import uvm_pkg::*;
  initial begin
    automatic uvm_phase_cb unnamed=new();
    automatic uvm_phase_cb named=new("chosen53");
    uvm_callback callback_view;
    uvm_object object_view;
    uvm_phase_cb back;
    callback_view=named;object_view=callback_view;
    $display("UT: phase_callback_new default_name %0d explicit_name %0d distinct %0d object %0d",
      unnamed.get_name()=="unnamed-uvm_phase_cb",named.get_name()=="chosen53",unnamed!=named,
      $cast(back,object_view) && back==named);
    $finish;
  end
endmodule
