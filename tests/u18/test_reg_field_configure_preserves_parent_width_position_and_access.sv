/*
:name: test_reg_field_configure_preserves_parent_width_position_and_access
:description: configured field reports its parent, layout, access and volatility (IEEE 1800.2-2020 Section 18.5.3.2)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.3.2 18.5.4.1 18.5.4.2 18.5.4.3 18.5.4.5 18.5.4.9 18.5.4.10 18.5.3.1 18.5.5.4 18.1.2.1 18.1.2.2 18.4.2.1 18.4.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_field_configure_preserves_parent_width_position_and_access.expected
*/
// What it checks:
// 1. Field configuration records parent, size, position, access and
//    volatility.
// 2. get_parent returns the configured parent register.
// 3. get_lsb_pos returns the configured logical bit position.
// 4. get_n_bits returns the configured field width.
// 5. is_volatile reflects the field volatility setting.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.5.3.2 (UVM-REG-FIELD-CONFIGURATION-METADATA) gives rule 1
//    above. Setup: Configure an eight-bit RW field at bit four and later
//    enable volatility. Expected: The exact parent, width eight, position
//    four, RW and volatility zero then one are returned.
// 2. 1800.2-2020 18.5.4.1 (UVM-FIELD-INTROSPECTION-PARENT) gives rule 2 above.
//    Setup: An original eight-bit field is configured on a concrete register.
//    Expected: The returned handle equals that register.
// 3. 1800.2-2020 18.5.4.2 (UVM-FIELD-INTROSPECTION-LSB-POSITION) gives rule 3
//    above. Setup: The field begins at bit four. Expected: The returned
//    position is 4.
// 4. 1800.2-2020 18.5.4.3 (UVM-FIELD-INTROSPECTION-WIDTH) gives rule 4 above.
//    Setup: The original field width is eight bits. Expected: The returned
//    width is 8.
// 5. 1800.2-2020 18.5.4.10 (UVM-FIELD-INTROSPECTION-VOLATILITY-QUERY) gives
//    rule 5 above. Setup: The configured nonvolatile field is changed to
//    volatile. Expected: The getter returns 0 before and 1 after the change.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use public introspection on an eight-bit field starting at bit four.
// Volatility changes are observed separately from stored values.

module test_reg_field_configure_preserves_parent_width_position_and_access;
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
    automatic uvm_reg_field field = new("f");

    blk.configure();
    rg.configure(blk);
    field.configure(rg, 8, 4, "RW", 0, 8'h35, 1, 0, 0);
    field.reset();
    $display("UT: parent %0d bits %0d lsb %0d access %s volatile %0d",
             field.get_parent() == rg, field.get_n_bits(), field.get_lsb_pos(),
             field.get_access(), field.is_volatile());
    field.set_volatility(1);
    $display("UT: volatile %0d", field.is_volatile());
    $finish;
  end
endmodule
