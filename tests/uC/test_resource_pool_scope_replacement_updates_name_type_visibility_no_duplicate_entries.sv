/*
:name: test_resource_pool_scope_replacement_updates_name_type_visibility_no_duplicate_entries
:description: Replacing an existing pool scope moves visibility in both maps and retains one resource entry
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.2.4.3.1 C.2.4.3 C.2.4.3.5 C.2.4.4.1 C.2.4.4.5 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_resource_pool_scope_replacement_updates_name_type_visibility_no_duplicate_entries.expected
*/
// What it checks:
// 1. Scope matching uses the stored scope expression against the current
//    lookup scope.
// 2. Scope insertion registers both maps and replacing an existing scope
//    changes its visibility without duplicate entries.
// 3. A registered scope query returns the stored text and true.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 C.2.4.3 (UVM-RESOURCE-AUDIT-POOL-SCOPE-MATCH-DIRECTION) gives
//    rule 1 above. Setup: One original resource moves from old58.* to new58.*
//    in a directly constructed pool and fresh name/type collections are
//    queried. Expected: The old scope loses both views; the new scope contains
//    the original handle once per map and get_scope returns the new text.
// 2. 1800.2-2020 C.2.4.3.1 (UVM-RESOURCE-AUDIT-POOL-SCOPE-INSERT-REPLACE)
//    gives rule 2 above. Setup: One original resource moves from old58.* to
//    new58.* in a directly constructed pool and fresh name/type collections
//    are queried. Expected: The old scope loses both views; the new scope
//    contains the original handle once per map and get_scope returns the new
//    text.
// 3. 1800.2-2020 C.2.4.3.5 (UVM-RESOURCE-AUDIT-POOL-SCOPE-GET) gives rule 3
//    above. Setup: One original resource moves from old58.* to new58.* in a
//    directly constructed pool and fresh name/type collections are queried.
//    Expected: The old scope loses both views; the new scope contains the
//    original handle once per map and get_scope returns the new text.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module
  test_resource_pool_scope_replacement_updates_name_type_visibility_no_duplicate_entries;
  import uvm_pkg::*;
  initial begin
    automatic uvm_resource_pool pool=new();
    automatic uvm_resource#(int) resource=new("slot58");
    uvm_resource_types::rsrc_q_t names,types;
    string scope;
    bit found;
    pool.set_scope(resource,"old58.*");
    names=pool.lookup_name("old58.child","slot58",uvm_resource#(int)::get_type(),0);
    types=pool.lookup_type("old58.child",uvm_resource#(int)::get_type());
    found=pool.get_scope(resource,scope);
    $display("UT: scope_initial name %0d type %0d text %0d",
      names.size()==1 && names.get(0)==resource,types.size()==1 && types.get(0)==resource,
      found && scope=="old58.*");
    pool.set_scope(resource,"new58.*");
    names=pool.lookup_name("old58.child","slot58",uvm_resource#(int)::get_type(),0);
    types=pool.lookup_type("old58.child",uvm_resource#(int)::get_type());
    $display("UT: scope_replaced old_name_empty %0d old_type_empty %0d",
      names.size()==0,types.size()==0);
    names=pool.lookup_name("new58.child","slot58",uvm_resource#(int)::get_type(),0);
    types=pool.lookup_type("new58.child",uvm_resource#(int)::get_type());
    found=pool.get_scope(resource,scope);
    $display("UT: scope_replaced new_name_once %0d new_type_once %0d text %0d",
      names.size()==1 && names.get(0)==resource,types.size()==1 && types.get(0)==resource,
      found && scope=="new58.*");
    $finish;
  end
endmodule
