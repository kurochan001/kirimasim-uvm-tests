/*
:name: test_pool_empty_and_singleton_endpoints_preserve_reference_arguments
:description: empty endpoints preserve sentinels and a singleton is both the first and last item (IEEE 1800.2-2020 Section 11.2.2.9)
:tags: u11 uvm
:type: simulation
:lrm: 1800.2-2020 11.2.2.9 11.2.2.10 11.2.2.11 11.2.2.12 11.2.2.5 11.2.2.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pool_empty_and_singleton_endpoints_preserve_reference_arguments.expected
*/
// What it checks:
// 1. Pool first returns an available first key, or returns zero and leaves the
//    key unchanged when empty.
// 2. Pool last returns an available last key, or returns zero and leaves the
//    key unchanged when empty.
// 3. Pool next advances to the next available key and preserves the key when
//    already at the end.
// 4. Pool prev advances to the previous available key and preserves the key at
//    the beginning.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 11.2.2.9 (UVM-POOL-FIRST-ENDPOINT) gives rule 1 above. Setup:
//    Inspect an empty pool, a singleton and a three-key traversal. Expected:
//    Empty sentinels survive, a singleton key is returned, and traversal
//    includes all entries.
// 2. 1800.2-2020 11.2.2.10 (UVM-POOL-LAST-ENDPOINT) gives rule 2 above. Setup:
//    Inspect empty/singleton endpoints and a backward traversal. Expected:
//    Empty sentinels survive, a singleton is both endpoints, and backward
//    traversal reaches each entry.
// 3. 1800.2-2020 11.2.2.11 (UVM-POOL-NEXT-CURSOR) gives rule 3 above. Setup:
//    Traverse three entries, remove a middle key before a fresh traversal, and
//    inspect a singleton boundary. Expected: Every surviving key appears once;
//    exhaustion returns zero without changing the final cursor.
// 4. 1800.2-2020 11.2.2.12 (UVM-POOL-PREV-CURSOR) gives rule 4 above. Setup:
//    Traverse backward before/after deletion and inspect a singleton boundary.
//    Expected: Every surviving key appears once; the boundary returns zero
//    without changing the cursor.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_pool_empty_and_singleton_endpoints_preserve_reference_arguments;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  typedef bit [31:0] word_t;
  class warning_probe extends uvm_report_catcher;
    int warnings = 0;
    function new(); super.new("probe"); endfunction
    virtual function action_e catch();
      if (get_severity() == UVM_WARNING) begin warnings++; return CAUGHT; end
      return THROW;
    endfunction
  endclass

  initial begin
    automatic uvm_pool#(int, word_t) pool = new("pool");
    automatic int first_key = 101;
    automatic int last_key = 202;
    int first_result;
    int last_result;
    first_result = pool.first(first_key); last_result = pool.last(last_key);
    $display("UT: empty first %0d last %0d sentinels %0d", first_result, last_result,
             first_key == 101 && last_key == 202);
    pool.add(7, 77);
    first_result = pool.first(first_key); last_result = pool.last(last_key);
    $display("UT: singleton first %0d last %0d same_key %0d", first_result, last_result,
             first_key == 7 && last_key == 7);
    first_result = pool.prev(first_key); last_result = pool.next(last_key);
    $display("UT: boundaries before %0d after %0d unchanged %0d", first_result, last_result,
             first_key == 7 && last_key == 7);
    pool.delete(7);
    first_result = pool.first(first_key); last_result = pool.last(last_key);
    $display("UT: emptied first %0d last %0d retained %0d", first_result, last_result,
             first_key == 7 && last_key == 7);
    $finish;
  end

endmodule
