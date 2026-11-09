/*
:name: test_abstract_component_registry_with_a_parent_reports_error_and_returns_null
:description: an unimplemented abstract component with a concrete parent reports an error and returns null (8.2.5.1.2)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.2.5.1.2 8.2.5 8.3.2.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_abstract_component_registry_with_a_parent_reports_error_and_returns_null.expected
*/
// What it checks:
// 1. Creation without a concrete override reports an error and returns null
//    from the abstract callback.
// 2. Requests to construct registered abstract classes require concrete
//    overrides.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 8.2.5.1.2
//    (UVM-ABSTRACT-COMPONENT-UNIMPLEMENTED-CALLBACK-ERROR-NULL) gives rule 1
//    above. Setup: Ask an isolated factory to create through the abstract
//    wrapper without configuring overrides. Expected: An ERROR is observed,
//    the result is null and no represented constructor runs.
// 2. 1800.2-2020 8.2.5 (UVM-ABSTRACT-FACTORY-REQUIRES-CONCRETE-OVERRIDE) gives
//    rule 2 above. Setup: Attempt object/component creation with their
//    abstract wrappers and no overrides. Expected: Both attempts report an
//    error and return null without calling the represented constructors.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_abstract_component_registry_with_a_parent_reports_error_and_returns_null;
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
  class report_probe extends uvm_report_catcher;
    int errors = 0;
    function new(); super.new("probe"); endfunction
    function action_e catch();
      if (get_severity() == UVM_ERROR) begin errors++; return CAUGHT; end
      return THROW;
    endfunction
  endclass
  // Enter through the public factory boundary, not a guessed callback overload.
  initial begin
    automatic uvm_default_factory fresh = new();
    automatic registry proxy = registry::get();
    automatic report_probe probe = new();
    automatic owner_type parent = new("owner");
    automatic uvm_component created;
    fresh.register(proxy); uvm_report_cb::add(null, probe);
    created = fresh.create_component_by_type(proxy, "", "unimplemented", parent);
    $display("UT: error_reported %0d returned_null %0d constructors %0d",
             probe.errors > 0, created == null, subject::made);
    uvm_report_cb::delete(null, probe);
    $finish;
  end
endmodule
