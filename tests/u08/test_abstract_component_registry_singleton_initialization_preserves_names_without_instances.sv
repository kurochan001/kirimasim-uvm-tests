/*
:name: test_abstract_component_registry_singleton_initialization_preserves_names_without_instances
:description: abstract registry singleton/default names and explicit initialization (8.2.5.1)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.2.5.1.4 8.2.5.1.3 8.2.5.1.1 8.2.5.1.8 8.2.5.1 8.3.1.7.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_abstract_component_registry_singleton_initialization_preserves_names_without_instances.expected
*/
// What it checks:
// 1. An abstract registry specialization returns its singleton wrapper.
// 2. An abstract registry returns its explicit Tname as the represented type
//    name.
// 3. An abstract registry with omitted Tname uses <unknown>.
// 4. An abstract registry represents its virtual type without constructing an
//    instance.
// 5. Abstract registry initialization registers its exact proxy with the
//    current factory.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 8.2.5.1.4 (UVM-ABSTRACT-COMPONENT-SINGLETON) gives rule 1
//    above. Setup: Repeat get and compare a default-Tname specialization.
//    Expected: Repeated get returns the same handle and the distinct
//    specialization has another handle.
// 2. 1800.2-2020 8.2.5.1.3 (UVM-ABSTRACT-COMPONENT-EXPLICIT-TYPE-NAME) gives
//    rule 2 above. Setup: Use the subject_proxy specialization. Expected: The
//    name is subject_proxy.
// 3. 1800.2-2020 8.2.5.1.1 (UVM-ABSTRACT-COMPONENT-DEFAULT-UNKNOWN-TNAME)
//    gives rule 3 above. Setup: Obtain a default-name specialization for the
//    same virtual type. Expected: The default proxy name is <unknown>.
// 4. 1800.2-2020 8.2.5.1 (UVM-ABSTRACT-COMPONENT-PROXY-WITHOUT-INSTANCE) gives
//    rule 4 above. Setup: Count the abstract base constructor during singleton
//    retrieval and explicit registration. Expected: The represented
//    constructor count stays zero.
// 5. 1800.2-2020 8.2.5.1.8 (UVM-ABSTRACT-COMPONENT-INITIALIZE-CURRENT-FACTORY)
//    gives rule 5 above. Setup: Select a fresh factory, explicitly initialize
//    a retained proxy, query it and restore the original factory. Expected:
//    The fresh factory reports the exact registered handle and exact name
//    lookup.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_abstract_component_registry_singleton_initialization_preserves_names_without_instances;
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
    automatic uvm_factory saved = uvm_factory::get();
    automatic uvm_default_factory fresh = new();
    automatic registry proxy = registry::get();
    automatic uvm_object_wrapper unnamed = default_registry::get();
    $display("UT: singleton %0d distinct %0d names %s %s constructors %0d",
             proxy == registry::get(), proxy != unnamed, proxy.get_type_name(),
             unnamed.get_type_name(), subject::made);
    uvm_factory::set(fresh); proxy.initialize();
    $display("UT: current_registered %0d exact_lookup %0d constructors %0d",
             fresh.is_type_registered(proxy),
             fresh.find_wrapper_by_name("subject_proxy") == proxy, subject::made);
    uvm_factory::set(saved);
    $finish;
  end
endmodule
