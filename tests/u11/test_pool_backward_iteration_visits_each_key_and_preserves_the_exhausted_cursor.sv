/*
:name: test_pool_backward_iteration_visits_each_key_and_preserves_the_exhausted_cursor
:description: pool traversal visits every surviving key once and leaves its terminal cursor unchanged (IEEE 1800.2-2020 Section 11.2.2.12)
:tags: u11 uvm
:type: simulation
:lrm: 1800.2-2020 11.2.2.12 11.2.2.9 11.2.2.10 11.2.2.4 11.2.2.5 11.2.2.6 11.2.2.7 11.2.2.8 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pool_backward_iteration_visits_each_key_and_preserves_the_exhausted_cursor.expected
*/
module test_pool_backward_iteration_visits_each_key_and_preserves_the_exhausted_cursor;
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
    automatic int key = 99;
    automatic int previous_key = 99;
    int found;
    automatic int count = 0;
    automatic bit [2:0] membership = 0;
    automatic bit values_ok = 1;
    automatic bit unique_keys = 1;
    pool.add(11, 111); pool.add(2, 22); pool.add(7, 77);
    found = pool.last(key);
    while (found && count < 4) begin
      case (key)
        2: begin unique_keys &= !membership[0]; membership[0] = 1;
            values_ok &= pool.get(key) == 22; end
        7: begin unique_keys &= !membership[1]; membership[1] = 1;
            values_ok &= pool.get(key) == 77; end
        11: begin unique_keys &= !membership[2]; membership[2] = 1;
            values_ok &= pool.get(key) == 111; end
        default: values_ok = 0;
      endcase
      count++; previous_key = key; found = pool.prev(key);
    end
    $display("UT: traversal count %0d membership %0h unique %0d values %0d count_unchanged %0d",
             count, membership, unique_keys, values_ok, pool.num() == 3);
    $display("UT: exhausted %0d cursor_preserved %0d", !found, key == previous_key);
    pool.delete(7);
    count = 0; membership = 0; found = pool.last(key);
    while (found && count < 4) begin
      case (key) 2: membership[0] = 1; 7: membership[1] = 1; 11: membership[2] = 1; endcase
      count++; found = pool.prev(key);
    end
    $display("UT: after_delete count %0d membership %0h absent %0d", count, membership,
        !pool.exists(7));
    $finish;
  end

endmodule
