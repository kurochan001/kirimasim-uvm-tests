/*
:name: test_abstract_component_registry_instance_override_precedes_concrete_type_fallback
:description: abstract registry creation uses a relative instance override and concrete type fallback (8.2.5.1.5)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.2.5.1.5 8.2.5.1.6 8.2.5.1.7 8.2.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_abstract_component_registry_instance_override_precedes_concrete_type_fallback.expected
*/
module test_abstract_component_registry_instance_override_precedes_concrete_type_fallback;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  virtual class subject extends uvm_component;
    static int made = 0;
    function new(string name, uvm_component parent); super.new(name, parent); made++; endfunction
    pure virtual function int marker();
  endclass
  typedef uvm_abstract_component_registry#(subject, "subject_proxy") registry;
  typedef uvm_abstract_component_registry#(subject) default_registry;
  class fallback extends subject;
    `uvm_component_utils(fallback)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function int marker(); return 1; endfunction
  endclass
  class selected extends subject;
    `uvm_component_utils(selected)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function int marker(); return 2; endfunction
  endclass
  class owner_type extends uvm_component;
    function new(string name); super.new(name, null); endfunction
  endclass
  initial begin
    automatic owner_type one = new("one");
    automatic owner_type two = new("two");
    automatic subject first, second;
    registry::set_type_override(fallback::get_type());
    registry::set_inst_override(selected::get_type(), "item", one);
    first = registry::create("item", one); second = registry::create("item", two);
    if (first == null || second == null) $fatal(1, "concrete override creation failed");
    $display("UT: markers %0d %0d distinct %0d constructors %0d", first.marker(),
             second.marker(), first != second, subject::made);
    $display("UT: identity %0d",
             first.get_parent() == one && second.get_parent() == two &&
             first.get_name() == "item" && second.get_name() == "item");
    $finish;
  end
endmodule
