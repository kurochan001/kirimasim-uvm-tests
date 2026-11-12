/*
:name: test_reg_adapter_descendant_inherits_both_converters_and_preserves_reference_directions
:description: Inherited adapter converters allocate items and update existing operations (19.2.1.2.5)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.2.1.2.5 19.2.1.2.6 19.2.1.1 1800-2023 6.21 8.21 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_adapter_descendant_inherits_both_converters_and_preserves_reference_directions.expected
*/
// What it checks:
// 1. The inherited reg2bus implementation is callable through the declared
//    adapter base and preserves its argument direction.
// 2. The inherited bus2reg implementation is callable through the declared
//    adapter base and preserves its argument direction.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 19.2.1.2.5 (UVM-ADAPTER-INHERITED-REG2BUS) gives rule 1
//    above. Setup: A leaf inherits both exact converter signatures from an
//    original adapter. Initialize every operation member, convert twice, then
//    change one original bus item before copying back to an existing
//    operation. Expected: Two forward calls produce separate items containing
//    the input operation without modifying it. The reverse call updates the
//    caller operation to the selected item and leaves the original input and
//    peer item unchanged.
// 2. 1800.2-2020 19.2.1.2.6 (UVM-ADAPTER-INHERITED-BUS2REG) gives rule 2
//    above. Setup: A leaf inherits both exact converter signatures from an
//    original adapter. Initialize every operation member, convert twice, then
//    change one original bus item before copying back to an existing
//    operation. Expected: Two forward calls produce separate items containing
//    the input operation without modifying it. The reverse call updates the
//    caller operation to the selected item and leaves the original input and
//    peer item unchanged.
// It also supports, as a control, the setup or conditions of
// UVM-NEGATIVE-REG-ADAPTER-CONCRETE-SUBCLASS-MUST-IMPLEMENT-REG2BUS,
// UVM-NEGATIVE-REG-ADAPTER-CONCRETE-SUBCLASS-MUST-IMPLEMENT-BUS2REG,
// UVM-NEGATIVE-REG-ADAPTER-REG2BUS-CONST-REFERENCE-REJECTS-INPUT-MUTATION.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_reg_adapter_descendant_inherits_both_converters_and_preserves_reference_directions;
  import uvm_pkg::*;
  // Original payload copying selects a legal implementation. The oracle
  // concerns inherited calls, fresh objects and const/ref argument effects.
  class original_bus_item extends uvm_sequence_item;
    uvm_reg_bus_op operation;
    function new(); super.new("bus"); endfunction
  endclass
  class implemented_adapter extends uvm_reg_adapter;
    int to_bus = 0, to_reg = 0;
    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
      original_bus_item result = new();
      to_bus++; result.operation = rw; return result;
    endfunction
    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
      original_bus_item result;
      if (!$cast(result, bus_item) || result == null) $fatal(1, "wrong original item");
      to_reg++; rw = result.operation;
    endfunction
  endclass
  class inherited_adapter extends implemented_adapter;
  endclass
  initial begin
    automatic inherited_adapter selected = new();
    automatic uvm_reg_adapter base_view = selected;
    uvm_sequence_item first_value, second_value;
    original_bus_item first_item, second_item;
    uvm_reg_bus_op input_op, saved_op, output_op;
    input_op.kind = UVM_WRITE; input_op.addr = 'h123; input_op.data = 'h4567;
    input_op.n_bits = 16; input_op.byte_en = 'h3; input_op.status = UVM_IS_OK;
    saved_op = input_op;
    first_value = base_view.reg2bus(input_op); second_value = base_view.reg2bus(input_op);
    if (!$cast(first_item, first_value) || !$cast(second_item, second_value))
      $fatal(1, "missing original bus items");
    $display("UT: inherited_reg2bus calls %0d fresh %0d copies %0d/%0d input %0d",
             selected.to_bus, first_value != second_value,
             first_item.operation == saved_op, second_item.operation == saved_op,
             input_op == saved_op);
    first_item.operation.kind = UVM_READ; first_item.operation.addr = 'h789;
    first_item.operation.data = 'h89ab; first_item.operation.n_bits = 8;
    first_item.operation.byte_en = 'h1; first_item.operation.status = UVM_NOT_OK;
    output_op = saved_op;
    base_view.bus2reg(first_value, output_op);
    $display("UT: inherited_bus2reg calls %0d output %0d input %0d peer %0d",
             selected.to_reg, output_op == first_item.operation,
             input_op == saved_op, second_item.operation == saved_op);
    $finish;
  end
endmodule
