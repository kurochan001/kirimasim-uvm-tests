/*
:name: test_pool_num_tracks_implicit_creation_deletion_and_instance_scope
:description: pool count follows creation and deletion without changing a peer pool (IEEE 1800.2-2020 Section 11.2.2.6)
:tags: u11 uvm
:type: simulation
:lrm: 1800.2-2020 11.2.2.6 11.2.2.1 11.2.2.4 11.2.2.5 11.2.2.7 11.2.2.8 1800-2023 6.11.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pool_num_tracks_implicit_creation_deletion_and_instance_scope.expected
*/
// What it checks:
// 1. Pool num reports how many distinct keys currently have entries.
// 2. Getting a missing pool key creates an entry with the element type default
//    value.
// 3. Pool deletion removes the selected key from that pool.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 11.2.2.6 (UVM-POOL-UNIQUE-COUNT) gives rule 1 above. Setup:
//    Replace a key, insert a different key, implicitly create one through get
//    and delete it while preserving another pool. Expected: Counts follow
//    unique stored keys rather than operation count, and deleting one pool
//    entry leaves the peer pool unchanged.
// 2. 1800.2-2020 11.2.2.4 (UVM-POOL-MISSING-GET-CREATES-DEFAULT) gives rule 2
//    above. Setup: Use an explicitly two-state 32-bit element type so the
//    default zero is defined. Expected: The returned value is zero and the
//    pool gains one entry.
// 3. 1800.2-2020 11.2.2.7 (UVM-POOL-DELETE-KEY) gives rule 3 above. Setup:
//    Delete a populated key shared in name only with another pool. Expected:
//    The key becomes absent, the first count becomes zero and the peer retains
//    its value.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A two-state element type has a defined zero default for a missing key.
module test_pool_num_tracks_implicit_creation_deletion_and_instance_scope;
  import uvm_pkg::*;
  typedef bit [31:0] word_t;
  initial begin
    uvm_pool#(string, word_t) first;
    uvm_pool#(string, word_t) second;
    word_t value;
    first = new("first");
    second = new("second");
    second.add("entry", 77);
    value = first.get("entry");
    $display("UT: implicit count %0d default %0d", first.num(), value);
    first.add("entry", 9);
    $display("UT: replaced count %0d value %0d", first.num(), first.get("entry"));
    first.delete("entry");
    $display("UT: removed count %0d absent %0d", first.num(), !first.exists("entry"));
    $display("UT: peer count %0d value %0d", second.num(), second.get("entry"));
    $finish;
  end
endmodule
