/*
:name: test_comparer_flush_preserves_extension_and_resets_miscompares
:description: comparer flush keeps extensions while clearing comparison results (IEEE 1800.2-2020 Section 16.1.2.3)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.1.2.3 16.3.2.2 16.3.3.9 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_comparer_flush_preserves_extension_and_resets_miscompares.expected
*/
// Cause a scalar mismatch before reset. The result and miscompare text
// are cleared without removing the policy extension or its mutable value.

module test_comparer_flush_preserves_extension_and_resets_miscompares;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class limit_ext extends uvm_object;
    `uvm_object_utils(limit_ext)
    int threshold = 0;
    function new(string name="limit_ext"); super.new(name); endfunction
  endclass
  class derived_limit_ext extends limit_ext;
    `uvm_object_utils(derived_limit_ext)
    function new(string name="derived_limit_ext"); super.new(name); endfunction
  endclass
  class flag_ext extends uvm_object;
    `uvm_object_utils(flag_ext)
    bit enabled = 1;
    function new(string name="flag_ext"); super.new(name); endfunction
  endclass

  initial begin
    automatic uvm_comparer policy = new;
    automatic limit_ext extension_value = new;
    uvm_object previous;
    bit result;
    extension_value.threshold = 21;
    previous = policy.set_extension(extension_value);
    policy.set_show_max(0);
    result = policy.compare_field_int("value", 1, 2, 32);
    $display("UT: mismatch result %0d count %0d", result, policy.get_result());
    policy.flush();
    $display("UT: flushed count %0d empty_text %0d retained %0d", policy.get_result(),
             policy.get_miscompares() == "",
                 policy.get_extension(limit_ext::get_type()) == extension_value);
    $display("UT: extension threshold %0d", extension_value.threshold);
    $finish;
  end
endmodule
