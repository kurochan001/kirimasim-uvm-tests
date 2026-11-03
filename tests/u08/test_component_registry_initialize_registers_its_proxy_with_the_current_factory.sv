/*
:name: test_component_registry_initialize_registers_its_proxy_with_the_current_factory
:description: explicit registry initialize registers the exact proxy with the selected factory (8.2.3.2.7)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.2.3.2.7 8.2.3.2.3 8.2.3.2.1 8.3.1.3 8.3.1.2.1 8.3.1.7.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_registry_initialize_registers_its_proxy_with_the_current_factory.expected
*/
module test_component_registry_initialize_registers_its_proxy_with_the_current_factory;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class represented extends uvm_component;
    static int made = 0;
    function new(string name, uvm_component parent); super.new(name, parent); made++; endfunction
  endclass
  typedef uvm_component_registry#(represented, "named_proxy") named_registry;
  typedef uvm_component_registry#(represented, "other_proxy") other_registry;
  typedef uvm_component_registry#(represented) default_registry;
  class owner_type extends uvm_component;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass
  initial begin
    automatic uvm_factory saved = uvm_factory::get();
    automatic uvm_default_factory selected = new();
    automatic named_registry proxy = named_registry::get();
    automatic owner_type parent = new("owner", null);
    automatic uvm_component created;
    automatic represented typed;
    uvm_factory::set(selected);
    proxy.initialize();
    $display("UT: current_registered %0d exact_lookup %0d constructors_before %0d",
             selected.is_type_registered(proxy),
             selected.find_wrapper_by_name("named_proxy") == proxy, represented::made);
    created = selected.create_component_by_name("named_proxy", "", "created", parent);
    if (!$cast(typed, created) || typed == null) $fatal(1, "proxy creation failed");
    $display("UT: created_identity %0d constructors_after %0d",
             typed.get_parent() == parent && typed.get_name() == "created", represented::made);
    uvm_factory::set(saved);
    $display("UT: restored %0d", uvm_factory::get() == saved);
    $finish;
  end
endmodule
