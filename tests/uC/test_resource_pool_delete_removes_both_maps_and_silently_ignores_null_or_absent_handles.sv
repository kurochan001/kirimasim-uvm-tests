/*
:name: test_resource_pool_delete_removes_both_maps_and_silently_ignores_null_or_absent_handles
:description: Pool deletion removes name/type visibility and missing scope clears output; null/absent deletion stays silent
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.2.4.3.6 C.2.4.3.5 C.2.4.4.1 C.2.4.4.5 C.2.4.3.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_resource_pool_delete_removes_both_maps_and_silently_ignores_null_or_absent_handles.expected
*/
// What it checks:
// 1. Deleting a registered resource removes it from name and type maps.
// 2. Deleting null, absent or already deleted handles is silently ignored.
// 3. A missing resource scope query returns false and clears its output
//    string.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 C.2.4.3.6 (UVM-RESOURCE-AUDIT-POOL-DELETE-BOTH-MAPS) gives
//    rule 1 above. Setup: A directly constructed pool receives one resource;
//    after deletion, repeated/absent/null operations are report-gated and a
//    sentinel scope output is queried. Expected: Both collections are empty;
//    missing scope becomes empty/false and no gated report is delivered by
//    no-op deletes.
// 2. 1800.2-2020 C.2.4.3.6 (UVM-RESOURCE-AUDIT-POOL-DELETE-NOOPS) gives rule 2
//    above. Setup: A directly constructed pool receives one resource; after
//    deletion, repeated/absent/null operations are report-gated and a sentinel
//    scope output is queried. Expected: Both collections are empty; missing
//    scope becomes empty/false and no gated report is delivered by no-op
//    deletes.
// 3. 1800.2-2020 C.2.4.3.5 (UVM-RESOURCE-AUDIT-POOL-MISSING-SCOPE) gives rule
//    3 above. Setup: A directly constructed pool receives one resource; after
//    deletion, repeated/absent/null operations are report-gated and a sentinel
//    scope output is queried. Expected: Both collections are empty; missing
//    scope becomes empty/false and no gated report is delivered by no-op
//    deletes.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_resource_pool_delete_removes_both_maps_and_silently_ignores_null_or_absent_handles;
  import uvm_pkg::*;

  class report_probe extends uvm_report_catcher;
    bit gated=0;
    int messages=0,warnings=0,errors=0;
    virtual function action_e catch();
      if (!gated) return THROW;
      messages++; warnings+=get_severity()==UVM_WARNING; errors+=get_severity()==UVM_ERROR;
      return CAUGHT;
    endfunction
  endclass

  initial begin
    automatic uvm_resource_pool pool=new();
    automatic uvm_resource#(int) resource=new("slot58");
    automatic uvm_resource#(int) absent=new("absent58");
    automatic report_probe reports=new();
    uvm_resource_types::rsrc_q_t names,types;
    string scope;
    bit found;
    pool.set_scope(resource,"scope58"); uvm_report_cb::add(null,reports);
    pool.delete(resource); reports.gated=1;
    pool.delete(resource); pool.delete(absent); pool.delete(null); reports.gated=0;
    names=pool.lookup_name("scope58","slot58",uvm_resource#(int)::get_type(),0);
    types=pool.lookup_type("scope58",uvm_resource#(int)::get_type());
    scope="sentinel58"; found=pool.get_scope(resource,scope);
    $display("UT: pool_delete names %0d types %0d scope_cleared %0d silent_noops %0d",
      names.size()==0,types.size()==0,!found && scope=="",reports.messages==0);
    $finish;
  end
endmodule
