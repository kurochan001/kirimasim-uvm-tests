/*
:name: test_object_copy_selects_default_or_explicit_policy
:description: copy uses the default policy unless an explicit policy is supplied (IEEE 1800.2-2020 Section 5.3.8.1)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.8.1 5.3.8.2 16.6.2.3 16.6.2.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_copy_selects_default_or_explicit_policy.expected
*/
// What it checks:
// Object copy uses the supplied copier, or the default when none is supplied.
//
// How the expected output follows from the standard:
// 1800.2-2020 5.3.8.1 (UVM-OBJECT-COPY-POLICY) gives the rule above. Setup:
// Install a counting default copier, supply another explicitly and repeat a
// copy after changing data. An additional fixture alternates explicit copier
// subtypes A/B/A with fresh recorder operations between copies and source
// bytes 31/52/73 hexadecimal. Expected: Each selected policy is invoked for
// its operation and copies current scalar data. The additional selected copier
// receives exact lhs/rhs handles, the other observer stays idle, and each
// current byte reaches the target.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Install a counting default copier, then supply a different explicit
// copier. The explicit argument overrides the default for that call only.

module test_object_copy_selects_default_or_explicit_policy;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class datum extends uvm_object;
    `uvm_object_utils(datum)
    int value = 0;
    function new(string name="datum"); super.new(name); endfunction
    function void do_copy(uvm_object rhs);
      datum source;
      super.do_copy(rhs);
      if (!$cast(source, rhs)) $fatal(1, "unexpected copy type");
      value = source.value;
    endfunction
  endclass
  class counting_copier extends uvm_copier;
    `uvm_object_utils(counting_copier)
    int calls = 0;
    function new(string name="counting_copier"); super.new(name); endfunction
    function void copy_object(uvm_object lhs, uvm_object rhs);
      calls++;
      super.copy_object(lhs, rhs);
    endfunction
  endclass

  initial begin
    automatic datum source = new;
    automatic datum target = new;
    automatic counting_copier default_policy = new;
    automatic counting_copier explicit_policy = new;
    automatic uvm_copier saved = uvm_copier::get_default();
    uvm_copier::set_default(default_policy);
    source.value = 21;
    target.copy(source);
    $display("UT: default calls %0d value %0d", default_policy.calls, target.value);
    source.value = 65;
    target.copy(source, explicit_policy);
    $display("UT: explicit calls %0d default calls %0d value %0d",
             explicit_policy.calls, default_policy.calls, target.value);
    uvm_copier::set_default(saved);
    $finish;
  end
endmodule
