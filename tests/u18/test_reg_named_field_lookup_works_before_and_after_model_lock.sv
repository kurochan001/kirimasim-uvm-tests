/*
:name: test_reg_named_field_lookup_works_before_and_after_model_lock
:description: named field lookup resolves configured fields before and after model locking (IEEE 1800.2-2020 Section 18.4.3.12)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.3.12 18.4.3.11 18.1.2.6 18.5.3.2 18.4.4.5 18.1.2.1 18.1.2.2 18.4.2.1 18.4.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_named_field_lookup_works_before_and_after_model_lock.expected
*/
// What it checks:
// Named field lookup returns configured field handles before and after lock.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.4.3.12 (UVM-REG-NAMED-FIELD-LOOKUP-BEFORE-AND-AFTER-LOCK)
// gives the rule above. Setup: Configure high before low, enumerate and look
// up both names around locking. Expected: Enumeration is in bit order and
// every named lookup preserves the exact handle.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Configure the high field first and enumerate an initially empty queue.
// Named lookup has no lock prerequisite. Compare it before and after lock.

module test_reg_named_field_lookup_works_before_and_after_model_lock;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class model_block extends uvm_reg_block;
    function new(string name="blk");
      super.new(name, UVM_NO_COVERAGE);
    endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(string name="r", int unsigned width=16);
      super.new(name, width, UVM_NO_COVERAGE);
    endfunction
  endclass

  initial begin

    automatic model_block blk = new("blk");
    automatic model_reg rg = new("r", 16);
    automatic uvm_reg_field low = new("low");
    automatic uvm_reg_field high = new("high");
    uvm_reg_field fields[$];

    blk.configure();
    rg.configure(blk);
    high.configure(rg, 8, 8, "RW", 0, 8'h12, 1, 0, 1);
    low.configure(rg, 8, 0, "RW", 0, 8'h34, 1, 0, 1);
    rg.reset();
    rg.get_fields(fields);
    $display("UT: fields %0d low_first %0d high_second %0d names %0d %0d",
             fields.size(), fields.size() == 2 && fields[0] == low,
             fields.size() == 2 && fields[1] == high,
             rg.get_field_by_name("low") == low, rg.get_field_by_name("high") == high);
    blk.lock_model();
    $display("UT: locked_names %0d %0d", rg.get_field_by_name("low") == low,
             rg.get_field_by_name("high") == high);
    $finish;
  end
endmodule
