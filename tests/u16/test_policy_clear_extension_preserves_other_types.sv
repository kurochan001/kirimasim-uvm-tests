/*
:name: test_policy_clear_extension_preserves_other_types
:description: clearing one extension removes only its type slot (IEEE 1800.2-2020 Section 16.1.2.3.4)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.1.2.3.4 16.1.2.3.1 16.1.2.3.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_policy_clear_extension_preserves_other_types.expected
*/
// Install two types then remove one. Presence and retrieval of the
// removed type change while the other extension retains its original handle.

module test_policy_clear_extension_preserves_other_types;
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
    automatic limit_ext limit_value = new;
    automatic flag_ext flag_value = new;
    uvm_object previous;
    previous = policy.set_extension(limit_value);
    previous = policy.set_extension(flag_value);
    policy.clear_extension(limit_ext::get_type());
    $display("UT: cleared exists %0d null %0d retained %0d",
        policy.extension_exists(limit_ext::get_type()),
             policy.get_extension(limit_ext::get_type()) == null,
             policy.get_extension(flag_ext::get_type()) == flag_value);
    $finish;
  end
endmodule
