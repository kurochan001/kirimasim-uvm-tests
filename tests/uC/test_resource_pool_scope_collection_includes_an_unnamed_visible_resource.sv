/*
:name: test_resource_pool_scope_collection_includes_an_unnamed_visible_resource
:description: resource pool scope collection includes an unnamed visible resource
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.2.4.4.8 C.3.2.3.3 C.2.4.3.1 C.2.5.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_resource_pool_scope_collection_includes_an_unnamed_visible_resource.expected
*/
module test_resource_pool_scope_collection_includes_an_unnamed_visible_resource;
  import uvm_pkg::*;
  initial begin
    uvm_resource_pool pool;
    uvm_resource#(int) anonymous_value,named_value;
    uvm_resource_types::rsrc_q_t found;
    bit have_anonymous,have_named;
    pool=new(); anonymous_value=new(""); named_value=new("named62");
    pool.set_scope(anonymous_value,"scope62"); pool.set_scope(named_value,"scope62");
    found=pool.lookup_scope("scope62"); have_anonymous=0; have_named=0;
    for (int i=0;i<found.size();i++) begin
      have_anonymous|=found.get(i)==anonymous_value; have_named|=found.get(i)==named_value;
    end
    $display("UT: scope_anonymous selected %0d",found.size()==2 && have_anonymous && have_named);
    $finish;
  end
endmodule
