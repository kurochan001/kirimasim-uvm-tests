/*
:name: test_resource_pool_regex_literal_combines_exact_names_and_scope_visibility
:description: resource pool regex literal combines exact names and scope visibility
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.2.4.4.7 C.2.4.4 C.2.4.4.1 C.2.4.3 C.2.4 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_resource_pool_regex_literal_combines_exact_names_and_scope_visibility.expected
*/
// What it checks:
// 1. Regex lookup combines a selected literal name with scope visibility
//    across types.
// 2. The selected name lookup returns the collection matching its current name
//    and scope.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 C.2.4.4.7 (UVM-RESOURCE-COLLECTION-REGEX-LITERAL) gives rule
//    1 above. Setup: Use same-name int/string resources, a hidden same-name
//    peer and a visible wrong-name peer in a fresh pool. Expected: Exactly
//    both visible same-name handles are returned, and an unmatched scope
//    returns an empty queue.
// 2. 1800.2-2020 C.2.4.4 (UVM-RESOURCE-COLLECTION-LOOKUP-OVERVIEW) gives rule
//    2 above. Setup: The literal-regex fixture independently queries the
//    printed name-collection API on its mixed-type visible set. Expected: The
//    named collection contains exactly the two visible same-name handles.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_resource_pool_regex_literal_combines_exact_names_and_scope_visibility;
  import uvm_pkg::*;
  initial begin

    uvm_resource_pool pool;
    uvm_resource#(int) visible,hidden,wrong_name;
    uvm_resource#(string) second_type;
    uvm_resource_types::rsrc_q_t found,miss,named;
    bit have_int,have_string,named_int,named_string;
    pool=new(); visible=new("item62_red"); hidden=new("item62_red");
    wrong_name=new("other62"); second_type=new("item62_red");
    pool.set_scope(visible,"visible62.*"); pool.set_scope(hidden,"hidden62.*");
    pool.set_scope(wrong_name,"visible62.*"); pool.set_scope(second_type,"visible62.*");

    found=pool.lookup_regex("item62_red","visible62.child");
    have_int=0; have_string=0;
    for (int i=0;i<found.size();i++) begin
      have_int|=found.get(i)==visible; have_string|=found.get(i)==second_type;
    end
    miss=pool.lookup_regex("item62_red","outside62");
    named=pool.lookup_name("visible62.child","item62_red",null,0);
    named_int=0; named_string=0;
    for (int i=0;i<named.size();i++) begin
      named_int|=named.get(i)==visible; named_string|=named.get(i)==second_type;
    end
    $display("UT: regex_literal selected %0d hidden_scope %0d name_collection %0d",
      found.size()==2 && have_int && have_string,miss.size()==0,
      named.size()==2 && named_int && named_string);
    $finish;
  end
endmodule
