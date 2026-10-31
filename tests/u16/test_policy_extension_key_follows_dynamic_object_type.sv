/*
:name: test_policy_extension_key_follows_dynamic_object_type
:description: a base handle stores an extension under its dynamic derived wrapper (IEEE 1800.2-2020 Section 16.1.2.3.2)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.1.2.3.2 16.1.2.3.3 5.3.4.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_policy_extension_key_follows_dynamic_object_type.expected
*/
// The key is the extension get_object_type result. A derived extension
// passed through a base handle coexists with a separate base-type extension.

module test_policy_extension_key_follows_dynamic_object_type;
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
    automatic derived_limit_ext derived_value = new;
    automatic limit_ext base_handle = derived_value;
    automatic limit_ext base_value = new;
    uvm_object previous;
    previous = policy.set_extension(base_handle);
    $display("UT: derived key %0d base absent %0d",
             policy.get_extension(derived_limit_ext::get_type()) == derived_value,
             !policy.extension_exists(limit_ext::get_type()));
    previous = policy.set_extension(base_value);
    $display("UT: distinct keys base %0d derived %0d",
        policy.get_extension(limit_ext::get_type()) == base_value,
             policy.get_extension(derived_limit_ext::get_type()) == derived_value);
    $finish;
  end
endmodule
