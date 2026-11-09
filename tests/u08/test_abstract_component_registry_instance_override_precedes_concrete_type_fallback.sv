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
// What it checks:
// 1. Abstract registry create returns concrete instances selected by factory
//    overrides.
// 2. A type override supplies a concrete fallback for an abstract request
//    without a matching instance override.
// 3. An abstract-registry instance override is relative to its supplied parent
//    and takes precedence on a matching path.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 8.2.5.1.5 (UVM-ABSTRACT-COMPONENT-CREATE-CONCRETE-OVERRIDES)
//    gives rule 1 above. Setup: Configure concrete type and scoped instance
//    overrides and create under two contexts. Expected: Distinct concrete
//    instances have markers two/one, requested names and exact parents.
// 2. 1800.2-2020 8.2.5.1.6 (UVM-ABSTRACT-COMPONENT-TYPE-OVERRIDE-FALLBACK)
//    gives rule 2 above. Setup: Create under the second parent outside the
//    relative instance override. Expected: That creation has fallback marker
//    one.
// 3. 1800.2-2020 8.2.5.1.7 (UVM-ABSTRACT-COMPONENT-RELATIVE-INSTANCE-OVERRIDE)
//    gives rule 3 above. Setup: Override item relative to one of two
//    independent parents. Expected: The selected path yields marker two while
//    its peer uses marker one.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
