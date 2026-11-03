/*
:name: test_abstract_object_registry_singleton_initialization_preserves_names_without_instances
:description: abstract registry singleton/default names and explicit initialization (8.2.5.2)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.2.5.2.4 8.2.5.2.3 8.2.5.2.1 8.2.5.2.8 8.2.5.2 8.3.1.7.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_abstract_object_registry_singleton_initialization_preserves_names_without_instances.expected
*/
module test_abstract_object_registry_singleton_initialization_preserves_names_without_instances;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  virtual class subject extends uvm_object;
    static int made = 0;
    function new(string name=""); super.new(name); made++; endfunction
    pure virtual function int marker();
  endclass
  typedef uvm_abstract_object_registry#(subject, "subject_proxy") registry;
  typedef uvm_abstract_object_registry#(subject) default_registry;
  class fallback extends subject;
    `uvm_object_utils(fallback)
    function new(string name=""); super.new(name); endfunction
    function int marker(); return 1; endfunction
  endclass
  class selected extends subject;
    `uvm_object_utils(selected)
    function new(string name=""); super.new(name); endfunction
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
