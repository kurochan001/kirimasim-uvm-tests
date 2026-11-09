/*
:name: test_default_factory_can_be_extended_and_used_through_the_abstract_factory_view
:description: default factory can be extended and used through the abstract factory view
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.3.3 8.3.1.3 8.3.1.5 8.3.1.7.4 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_default_factory_can_be_extended_and_used_through_the_abstract_factory_view.expected
*/
// What it checks:
// The default factory can be extended and used through the abstract factory
// interface.
//
// How the expected output follows from the standard:
// 1800.2-2020 8.3.3 (UVM-FACTORY-AUDIT-DEFAULT-FACTORY-EXTENSION) gives the
// rule above. Setup: An original default-factory subclass supplies no
// replacement methods; registration, creation and a query are called through
// its base handle. Expected: Construction succeeds, the base view casts back,
// the wrapper is registered and the named object is created.
// It also supports, as a control, the setup or conditions of
// UVM-FACTORY-AUDIT-VIRTUAL-BASE-CONSTRUCTION.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_default_factory_can_be_extended_and_used_through_the_abstract_factory_view;
  import uvm_pkg::*;
  class original_factory extends uvm_default_factory;
  endclass
  class item extends uvm_object;
    function new(string name="");super.new(name);endfunction
  endclass
  typedef uvm_object_registry#(item,"default_factory_item55") registry;
  initial begin
    automatic original_factory selected_factory=new();
    uvm_factory base;
    original_factory back;
    uvm_object created;
    base=selected_factory;base.register(registry::get());
    created=base.create_object_by_name("default_factory_item55","","chosen55");
    $display("UT: default_factory concrete %0d identity %0d registered %0d created %0d",
      selected_factory!=null,$cast(back,base) && back==selected_factory,
      base.is_type_registered(registry::get()),created!=null && created.get_name()=="chosen55");
    $finish;
  end
endmodule
