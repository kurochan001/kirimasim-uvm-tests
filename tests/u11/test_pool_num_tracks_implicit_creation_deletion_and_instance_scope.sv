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
