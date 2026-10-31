/*
:name: test_policy_extension_replacement_returns_previous_handle
:description: replacing an extension returns its old handle and selects the new object (IEEE 1800.2-2020 Section 16.1.2.3.2)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.1.2.3.2 16.1.2.3.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_policy_extension_replacement_returns_previous_handle.expected
*/
// The two extensions have the same registered type. Mutating the old
// object after replacement does not change the newly selected extension.

module test_policy_extension_replacement_returns_previous_handle;
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
    automatic uvm_copier policy = new;
    automatic limit_ext first = new("first");
    automatic limit_ext second = new("second");
    limit_ext selected;
    uvm_object previous;
    first.threshold = 3;
    second.threshold = 8;
    previous = policy.set_extension(first);
    previous = policy.set_extension(second);
    first.threshold = 99;
    if (!$cast(selected, policy.get_extension(limit_ext::get_type()))) $fatal(1, "extension type");
    $display("UT: replaced old %0d selected_new %0d threshold %0d", previous == first,
             selected == second, selected.threshold);
    $finish;
  end
endmodule
