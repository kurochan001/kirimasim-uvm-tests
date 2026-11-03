/*
:name: test_pool_constructor_names_and_default_type_keep_local_instances_independent
:description: pool construction records default/explicit names and default-type keyed storage stays instance-local (11.2.2.1)
:tags: u11 uvm
:type: simulation
:lrm: 1800.2-2020 11.2.2.1 11.2.1 11.2 11.2.2.4 11.2.2.6 11.2.2.8 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pool_constructor_names_and_default_type_keep_local_instances_independent.expected
*/
module test_pool_constructor_names_and_default_type_keep_local_instances_independent;
  import uvm_pkg::*;
  initial begin
    automatic uvm_pool#() unnamed = new();
    automatic uvm_pool#() named = new("named_pool");
    uvm_void item;
    uvm_pool#(int, uvm_void) typed_alias;
    $display("UT: names default_empty %0d explicit %0d initial_sizes %0d %0d",
             unnamed.get_name() == "", named.get_name() == "named_pool",
             unnamed.num(), named.num());
    item = unnamed.get(-7);
    $display("UT: default_type null %0d stored %0d local_size %0d peer_size %0d",
             item == null, unnamed.exists(-7), unnamed.num(), named.num());
    typed_alias = unnamed;
    typed_alias.add(9, null);
    $display("UT: default_types %0d shared_entry %0d count %0d peer_size %0d",
             typed_alias == unnamed, unnamed.exists(9), unnamed.num(), named.num());
    $finish;
  end
endmodule
