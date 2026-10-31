/*
:name: test_reg_item_value_array_resize_preserves_prefix_and_zero_fills_growth
:description: register operation value arrays preserve existing entries and initialize new entries to zero (IEEE 1800.2-2020 Section 19.1.1.2.4)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.1.1.2.4 19.1.1.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_item_value_array_resize_preserves_prefix_and_zero_fills_growth.expected
*/
// Observe default size, growth and shrink/regrowth through the public API.
// Discarded data must not reappear when the array grows again.

module test_reg_item_value_array_resize_preserves_prefix_and_zero_fills_growth;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_reg_item item = new("operation");
    $display("UT: default_size %0d", item.get_value_size());
    item.set_value('ha5);
    item.set_value_size(3);
    $display("UT: grown_size %0d values %0h %0h %0h", item.get_value_size(),
             item.get_value(0), item.get_value(1), item.get_value(2));
    item.set_value('h42, 1);
    item.set_value('hc3, 2);
    item.set_value_size(2);
    $display("UT: shrunk_size %0d values %0h %0h", item.get_value_size(),
             item.get_value(0), item.get_value(1));
    item.set_value_size(3);
    $display("UT: regrown_size %0d values %0h %0h %0h", item.get_value_size(),
             item.get_value(0), item.get_value(1), item.get_value(2));
    $finish;
  end
endmodule
