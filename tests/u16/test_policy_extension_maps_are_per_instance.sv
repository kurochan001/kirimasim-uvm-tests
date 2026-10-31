/*
:name: test_policy_extension_maps_are_per_instance
:description: policy instances keep separate extension values even for the same wrapper (IEEE 1800.2-2020 Section 16.1.2.3.5)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.1.2.3.5 16.1.2.3.2 16.1.2.3.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_policy_extension_maps_are_per_instance.expected
*/
// Two policies store different extensions of the same type. Clearing
// one policy twice does not remove or replace the other policy extension.

module test_policy_extension_maps_are_per_instance;
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
    automatic uvm_comparer first_policy = new("same_name");
    automatic uvm_comparer second_policy = new("same_name");
    automatic limit_ext first_value = new;
    automatic limit_ext second_value = new;
    uvm_object previous;
    previous = first_policy.set_extension(first_value);
    previous = second_policy.set_extension(second_value);
    first_policy.clear_extensions();
    first_policy.clear_extensions();
    $display("UT: first_empty %0d second_retained %0d",
             first_policy.get_extension(limit_ext::get_type()) == null,
             second_policy.get_extension(limit_ext::get_type()) == second_value);
    $finish;
  end
endmodule
