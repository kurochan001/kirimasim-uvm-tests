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
// What it checks:
// 1. Pool construction retains an explicit name and the empty default name.
// 2. The default pool specialization uses int keys and uvm_void items.
// 3. Passing a pool by handle shares its storage while other instances remain
//    independent.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 11.2.2.1 (UVM-POOL-CONSTRUCTOR-NAMES) gives rule 1 above.
//    Setup: Construct one unnamed and one named local pool. Expected: The
//    names are empty/named_pool and initial sizes are zero.
// 2. 1800.2-2020 11.2.1 (UVM-POOL-DEFAULT-KEY-ITEM-TYPES) gives rule 2 above.
//    Setup: Assign the default pool to an explicitly specialized alias and get
//    a missing signed key. Expected: The alias is exact; the missing item is
//    null and its key becomes stored locally.
// 3. 1800.2-2020 11.2 (UVM-POOL-CONTAINER-REFERENCE-SHARING) gives rule 3
//    above. Setup: Add a null item through an alias of one of two local pools.
//    Expected: The original observes the new key and size two while the peer
//    remains empty.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
