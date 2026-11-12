/*
:name: test_reg_adapter_constructor_forwards_names_and_inherits_the_object_base
:description: reg adapter constructor forwards names and inherits the object base (IEEE 1800.2-2020 Section 19.2.1.2.1)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.2.1.2.1 19.2.1.1 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_adapter_constructor_forwards_names_and_inherits_the_object_base.expected
*/
// What it checks:
// 1. A concrete register-adapter extension is usable as an object.
// 2. The register-adapter constructor accepts an optional name.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 19.2.1.1 (UVM-REG-INTERACTION-ADAPTER-BASE) gives rule 1
//    above. Setup: Assign a concrete converter to an object base view.
//    Expected: The view retains the adapter identity.
// 2. 1800.2-2020 19.2.1.2.1 (UVM-REG-INTERACTION-ADAPTER-NAMES) gives rule 2
//    above. Setup: A subtype without a constructor uses the omitted base name;
//    another forwards selected or empty names. Expected: The observed names
//    are empty, selected and empty.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Concrete original converters satisfy the abstract base interface. The
// implicit subtype constructor invokes the omitted base name, without a
// subtype default masking it. Converter implementation is setup, not its
// oracle.
module test_reg_adapter_constructor_forwards_names_and_inherits_the_object_base;
  import uvm_pkg::*;
  class original_bus_item extends uvm_sequence_item;
    uvm_reg_bus_op operation;
    function new(); super.new("bus"); endfunction
  endclass
  class omitted_adapter extends uvm_reg_adapter;
    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
      automatic original_bus_item item = new(); item.operation = rw; return item;
    endfunction
    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
      original_bus_item item;
      if (!$cast(item, bus_item) || item == null) $fatal(1, "wrong original bus item");
      rw = item.operation;
    endfunction
  endclass
  class named_adapter extends uvm_reg_adapter;
    function new(string name); super.new(name); endfunction
    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
      automatic original_bus_item item = new(); item.operation = rw; return item;
    endfunction
    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
      original_bus_item item;
      if (!$cast(item, bus_item) || item == null) $fatal(1, "wrong original bus item");
      rw = item.operation;
    endfunction
  endclass
  initial begin
    automatic omitted_adapter omitted = new();
    automatic named_adapter named = new("selected");
    automatic named_adapter empty = new("");
    automatic uvm_object base_view = named;
    $display("UT: adapter_names omitted %0d named %0d empty %0d",
             omitted.get_name() == "", named.get_name() == "selected", empty.get_name() == "");
    $display("UT: adapter_base %0d", base_view == named);
    $finish;
  end
endmodule
