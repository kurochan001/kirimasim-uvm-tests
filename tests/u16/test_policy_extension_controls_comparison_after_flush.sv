/*
:name: test_policy_extension_controls_comparison_after_flush
:description: a compare hook reads a retained extension after top-level comparison resets (IEEE 1800.2-2020 Section 16.1.2.3.3)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.1.2.3.3 16.1.2.3 5.3.9.1 5.3.9.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_policy_extension_controls_comparison_after_flush.expected
*/
// An ignored field compares equal, then a mutation of the same extension
// enables the field comparison. Each object compare starts a fresh operation.

module test_policy_extension_controls_comparison_after_flush;
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

  class comparable extends uvm_object;
    `uvm_object_utils(comparable)
    int payload = 0;
    function new(string name="comparable"); super.new(name); endfunction
    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      comparable other;
      flag_ext gate;
      bit enabled = 1;
      if (!$cast(other, rhs)) return 0;
      if ($cast(gate,
          comparer.get_extension(flag_ext::get_type())) && gate != null) enabled = gate.enabled;
      if (!super.do_compare(rhs, comparer)) return 0;
      if (!enabled) return 1;
      return comparer.compare_field_int("payload", payload, other.payload, 32);
    endfunction
  endclass
  initial begin
    automatic uvm_comparer policy = new;
    automatic comparable first = new("first");
    automatic comparable second = new("second");
    automatic flag_ext gate = new;
    uvm_object previous;
    bit result;
    first.payload = 3;
    second.payload = 4;
    policy.set_show_max(0);
    gate.enabled = 0;
    previous = policy.set_extension(gate);
    result = first.compare(second, policy);
    $display("UT: ignored equal %0d", result);
    gate.enabled = 1;
    result = first.compare(second, policy);
    $display("UT: enabled equal %0d retained %0d", result,
             policy.get_extension(flag_ext::get_type()) == gate);
    $finish;
  end
endmodule
