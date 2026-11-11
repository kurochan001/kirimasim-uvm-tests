/*
:name: test_reg_item_documented_defaults_exclude_undefined_enum_and_data_values
:description: register item exposes specified initial defaults without reading undefined fields (IEEE 1800.2-2020 Section 19.1.1.2.11)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.1.1.2.11 19.1.1.2.2 19.1.1.2.4 19.1.1.2.5 19.1.1.2.7 19.1.1.2.8 19.1.1.2.10 19.1.1.2.12 19.1.1.2.13 19.1.1.2.14 19.1.1.2.15 19.1.1.3.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_item_documented_defaults_exclude_undefined_enum_and_data_values.expected
*/
// What it checks:
// 1. The initial register-item element handle is null.
// 2. The initial register-item offset is zero.
// 3. The initial register-item local map is null.
// 4. The initial register-item original map is null.
// 5. The initial register-item parent sequence is null.
// 6. The initial register-item priority is minus one.
// 7. The initial register-item extension is null.
// 8. The initial register-item backdoor kind is empty.
// 9. The initial register-item filename is empty.
// 10. The initial register-item line number is zero.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 19.1.1.2.2 (UVM-REG-ITEM-DEFAULT-ELEMENT) gives rule 1 above.
//    Setup: Query a freshly constructed descriptor before any setter.
//    Expected: The documented element handle is null.
// 2. 1800.2-2020 19.1.1.2.5 (UVM-REG-ITEM-DEFAULT-OFFSET) gives rule 2 above.
//    Setup: Query a freshly constructed descriptor before any setter.
//    Expected: The documented offset is zero.
// 3. 1800.2-2020 19.1.1.2.7 (UVM-REG-ITEM-DEFAULT-LOCAL-MAP) gives rule 3
//    above. Setup: Query a freshly constructed descriptor before any setter.
//    Expected: The documented local map is null.
// 4. 1800.2-2020 19.1.1.2.8 (UVM-REG-ITEM-DEFAULT-MAP) gives rule 4 above.
//    Setup: Query a freshly constructed descriptor before any setter.
//    Expected: The documented original map is null.
// 5. 1800.2-2020 19.1.1.2.10 (UVM-REG-ITEM-DEFAULT-PARENT) gives rule 5 above.
//    Setup: Query a freshly constructed descriptor before any setter.
//    Expected: The documented parent sequence is null.
// 6. 1800.2-2020 19.1.1.2.11 (UVM-REG-ITEM-DEFAULT-PRIORITY) gives rule 6
//    above. Setup: Query a freshly constructed descriptor before any setter.
//    Expected: The documented priority is minus one.
// 7. 1800.2-2020 19.1.1.2.12 (UVM-REG-ITEM-DEFAULT-EXTENSION) gives rule 7
//    above. Setup: Query a freshly constructed descriptor before any setter.
//    Expected: The documented extension is null.
// 8. 1800.2-2020 19.1.1.2.13 (UVM-REG-ITEM-DEFAULT-BD-KIND) gives rule 8
//    above. Setup: Query a freshly constructed descriptor before any setter.
//    Expected: The documented backdoor kind is empty.
// 9. 1800.2-2020 19.1.1.2.14 (UVM-REG-ITEM-DEFAULT-FNAME) gives rule 9 above.
//    Setup: Query a freshly constructed descriptor before any setter.
//    Expected: The documented filename is empty.
// 10. 1800.2-2020 19.1.1.2.15 (UVM-REG-ITEM-DEFAULT-LINE) gives rule 10 above.
//     Setup: Query a freshly constructed descriptor before any setter.
//     Expected: The documented line number is zero.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Exercise the descriptor public API directly, without bus or DUT access.
// Undefined initial enum/data values are never observed. UVM_HAS_X here is
// an explicitly assigned status enum, not a four-state data observation.
module test_reg_item_documented_defaults_exclude_undefined_enum_and_data_values;
  import uvm_pkg::*;

  `include "uvm_macros.svh"
  class block_type extends uvm_reg_block;
    function new(); super.new("blk", UVM_NO_COVERAGE); endfunction
  endclass
  class reg_type extends uvm_reg;
    function new(); super.new("r", 8, UVM_NO_COVERAGE); endfunction
  endclass
  class mem_type extends uvm_mem;
    function new(); super.new("m", 4, 8, "RW", UVM_NO_COVERAGE); endfunction
  endclass
  class sequence_type extends uvm_sequence;
    function new(string name); super.new(name); endfunction
    virtual task body(); endtask
  endclass
  class warning_probe extends uvm_report_catcher;
    int warnings = 0;
    function new(); super.new("warning_probe"); endfunction
    function action_e catch();
      if (get_severity() == UVM_WARNING) begin warnings++; return CAUGHT; end
      return THROW;
    endfunction
  endclass
  initial begin
    automatic uvm_reg_item first = new("first");
    automatic uvm_reg_item peer = new("peer");


    $display("UT: handles element %0d local_map %0d map %0d parent %0d extension %0d",
    first.get_element() == null, first.get_local_map() == null, first.get_map() == null,
    first.get_parent_sequence() == null, first.get_extension() == null);
    $display("UT: numeric size %0d offset %0d priority %0d line %0d", first.get_value_size(),
    first.get_offset(), first.get_priority(), first.get_line());
    $display("UT: strings backdoor_empty %0d filename_empty %0d", first.get_bd_kind() == "",
    first.get_fname() == "");

    $finish;
  end

endmodule
