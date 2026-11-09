/*
:name: test_resource_pool_name_lookup_filters_type_and_scope_and_respects_missing_report_controls
:description: Resource name lookup combines scope/type filters and preserves default/suppressed warning behavior
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.2.4.4.1 C.2.4.4.5 C.2.4.3.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_resource_pool_name_lookup_filters_type_and_scope_and_respects_missing_report_controls.expected
*/
// What it checks:
// 1. Name lookup combines exact name, scope visibility and optional type
//    filtering.
// 2. Missing-name lookup warns with default rpterr and suppresses warnings
//    when zero is explicit.
// 3. An empty name or absent matching resources produces an empty name-lookup
//    queue.
// 4. Type lookup returns a queue matching the type token and visible scope.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 C.2.4.4.1 (UVM-RESOURCE-AUDIT-LOOKUP-NAME-FILTER) gives rule
//    1 above. Setup: Int/string resources share a name and simplified scope.
//    Null/int type filters, a foreign scope, empty/missing names and
//    default/explicit reporting flags are exercised. Expected: Unchecked type
//    returns both original handles; int filtering returns one, hidden
//    type/empty/missing lookups are empty, and warning behavior follows
//    rpterr.
// 2. 1800.2-2020 C.2.4.4.1 (UVM-RESOURCE-AUDIT-LOOKUP-NAME-DIAGNOSTIC) gives
//    rule 2 above. Setup: Int/string resources share a name and simplified
//    scope. Null/int type filters, a foreign scope, empty/missing names and
//    default/explicit reporting flags are exercised. Expected: Unchecked type
//    returns both original handles; int filtering returns one, hidden
//    type/empty/missing lookups are empty, and warning behavior follows
//    rpterr.
// 3. 1800.2-2020 C.2.4.4.1 (UVM-RESOURCE-AUDIT-LOOKUP-NAME-EMPTY) gives rule 3
//    above. Setup: Int/string resources share a name and simplified scope.
//    Null/int type filters, a foreign scope, empty/missing names and
//    default/explicit reporting flags are exercised. Expected: Unchecked type
//    returns both original handles; int filtering returns one, hidden
//    type/empty/missing lookups are empty, and warning behavior follows
//    rpterr.
// 4. 1800.2-2020 C.2.4.4.5 (UVM-RESOURCE-AUDIT-LOOKUP-TYPE-COLLECTION) gives
//    rule 4 above. Setup: Int/string resources share a name and simplified
//    scope. Null/int type filters, a foreign scope, empty/missing names and
//    default/explicit reporting flags are exercised. Expected: Unchecked type
//    returns both original handles; int filtering returns one, hidden
//    type/empty/missing lookups are empty, and warning behavior follows
//    rpterr.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Queue signatures/collection prose govern lookup_type despite its
// conflicting convenience-method sentence about a single highest resource.
module test_resource_pool_name_lookup_filters_type_and_scope_and_respects_missing_report_controls;
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
    automatic uvm_resource#(int) integer_resource=new("slot58");
    automatic uvm_resource#(string) string_resource=new("slot58");
    automatic report_probe reports=new();
    uvm_resource_types::rsrc_q_t both,typed,missing;
    automatic bit saw_int=0,saw_string=0;
    pool.set_scope(integer_resource,"visible58.*"); pool.set_scope(string_resource,"visible58.*");
    uvm_report_cb::add(null,reports);
    both=pool.lookup_name("visible58.child","slot58",null,0);
    for (int i=0;i<both.size();i++) begin
      saw_int |= both.get(i)==integer_resource; saw_string |= both.get(i)==string_resource;
    end
    typed=pool.lookup_name("visible58.child","slot58",uvm_resource#(int)::get_type(),0);
    missing=pool.lookup_type("other58",uvm_resource#(int)::get_type());
    $display("UT: lookup_filters unchecked_type %0d checked_type %0d hidden_type %0d",
      both.size()==2 && saw_int && saw_string,typed.size()==1 && typed.get(0)==integer_resource,
      missing.size()==0);
    reports.gated=1;
    missing=pool.lookup_name("visible58.child","missing58",null,0);
    reports.gated=0;
    $display("UT: lookup_missing disabled_report %0d empty %0d",
      reports.warnings==0,missing.size()==0);
    reports.gated=1; missing=pool.lookup_name("visible58.child","missing58",null);
    reports.gated=0;
    $display("UT: lookup_missing default_warning %0d empty %0d",
      reports.warnings>0,missing.size()==0);
    missing=pool.lookup_name("visible58.child","",null,0);
    $display("UT: lookup_empty_name empty %0d",missing.size()==0);
    $finish;
  end
endmodule
