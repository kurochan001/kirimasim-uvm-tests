/*
:name: test_pool_exists_distinguishes_a_stored_zero_without_creating_missing_keys
:description: pool exists distinguishes stored zero from absence without inserting an entry (11.2.2.8)
:tags: u11 uvm
:type: simulation
:lrm: 1800.2-2020 11.2.2.8 11.2.2.5 11.2.2.6 11.2.2.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pool_exists_distinguishes_a_stored_zero_without_creating_missing_keys.expected
*/
module test_pool_exists_distinguishes_a_stored_zero_without_creating_missing_keys;
  import uvm_pkg::*;
  initial begin
    automatic uvm_pool#(int, bit[15:0]) pool = new("pool");
    pool.add(0, 0);
    $display("UT: exists stored_zero %0d missing %0d count %0d",
             pool.exists(0), pool.exists(99), pool.num());
    $display("UT: repeated missing %0d count %0d", pool.exists(99), pool.num());
    pool.delete(0);
    $display("UT: deleted missing %0d count %0d", pool.exists(0), pool.num());
    $finish;
  end
endmodule
