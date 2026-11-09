/*
:name: test_resource_pool_scope_collection_preserves_all_visible_named_types
:description: resource pool scope collection preserves all visible named types
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.2.4.4.8 C.2.4 C.2.4.3.1 C.2.4.3 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_resource_pool_scope_collection_preserves_all_visible_named_types.expected
*/
// What it checks:
// 1. Scope collection includes all selected visible named resource types.
// 2. Scope collection follows a selected resource scope replacement.
// 3. The selected pool contains typed resources whose visibility follows
//    registered scope expressions.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 C.2.4.4.8 (UVM-RESOURCE-COLLECTION-SCOPE-NAMED) gives rule 1
//    above. Setup: Use fresh pools, explicit scope registration and exact
//    original handle membership without assuming traversal order. Expected:
//    Exactly the int and string handles are collected; a missing scope is
//    empty.
// 2. 1800.2-2020 C.2.4.4.8 (UVM-RESOURCE-COLLECTION-SCOPE-REPLACED) gives rule
//    2 above. Setup: Use fresh pools, explicit scope registration and exact
//    original handle membership without assuming traversal order. Expected:
//    Moving the integer resource leaves only its string peer visible in the
//    old scope.
// 3. 1800.2-2020 C.2.4 (UVM-RESOURCE-COLLECTION-POOL-VISIBILITY-ROLE) gives
//    rule 3 above. Setup: Register distinct int/string resources and query
//    visible/missing scopes before and after one scope replacement. Expected:
//    The selected scope queries return the exact currently visible original
//    handles.
// It also supports, as a control, the setup or conditions of
// UVM-RESOURCE-COLLECTION-POOL-BARE-DECLARATION.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_resource_pool_scope_collection_preserves_all_visible_named_types;
  import uvm_pkg::*;
  initial begin
    uvm_resource_pool pool;
    uvm_resource#(int) integer_value,hidden;
    uvm_resource#(string) string_value;
    uvm_resource_types::rsrc_q_t found,missing;
    bit have_int,have_string;
    pool=new(); integer_value=new("integer62"); hidden=new("hidden62");
    string_value=new("string62");
    pool.set_scope(integer_value,"visible62.*"); pool.set_scope(hidden,"hidden62");
    pool.set_scope(string_value,"visible62.*");
    found=pool.lookup_scope("visible62.child"); missing=pool.lookup_scope("other62");
    have_int=0; have_string=0;
    for (int i=0;i<found.size();i++) begin
      have_int|=found.get(i)==integer_value; have_string|=found.get(i)==string_value;
    end
    $display("UT: scope_named both_types %0d missing_empty %0d",
      found.size()==2 && have_int && have_string,missing.size()==0);
    pool.set_scope(integer_value,"hidden62"); found=pool.lookup_scope("visible62.child");
    $display("UT: scope_replaced selected_only %0d",
      found.size()==1 && found.get(0)==string_value);
    $finish;
  end
endmodule
