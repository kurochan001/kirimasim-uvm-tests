/*
:name: test_object_static_and_dynamic_type_proxies_survive_factory_override_and_rename
:description: static proxies remain nominal while dynamic proxies identify the allocated type (IEEE 1800.2-2020 Section 5.3.4.5)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.4.5 5.3.4.6 5.3.4.7 5.3.4.1 8.3.1.4.2 8.3.1.5 B.2.1.2 B.2.1.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_static_and_dynamic_type_proxies_survive_factory_override_and_rename.expected
*/
// Keep direct construction separate from registry construction under
// override.
// Only proxy identity and defined type strings are checked, not numeric IDs.
module test_object_static_and_dynamic_type_proxies_survive_factory_override_and_rename;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class base_value extends uvm_object;
    `uvm_object_utils(base_value)
    function new(string name="base"); super.new(name); endfunction
  endclass
  class child_value extends base_value;
    `uvm_object_utils(child_value)
    function new(string name="child"); super.new(name); endfunction
  endclass
  class component_value extends uvm_component;
    `uvm_component_utils(component_value)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass
  initial begin
    automatic component_value component_item = new("component", null);
    automatic base_value direct = new("direct");
    automatic uvm_object_wrapper base_proxy = base_value::get_type();
    automatic uvm_object_wrapper child_proxy = child_value::get_type();
    automatic uvm_factory factory = uvm_factory::get();
    base_value created;
    uvm_object dynamic_handle;
    factory.set_type_override_by_type(base_proxy, child_proxy);
    created = base_value::type_id::create("created"); dynamic_handle = created;
    $display("UT: static base %0d child %0d distinct %0d", base_value::get_type() == base_proxy,
             child_value::get_type() == child_proxy, base_proxy != child_proxy);
    $display("UT: dynamic direct %0d created %0d names %0d", direct.get_object_type() == base_proxy,
             dynamic_handle.get_object_type() == child_proxy,
             direct.get_type_name() == "base_value" &&
             dynamic_handle.get_type_name() == "child_value");
    dynamic_handle.set_name("renamed");
    $display("UT: renamed proxy %0d type_name %0d static_base %0d",
             dynamic_handle.get_object_type() == child_proxy,
             dynamic_handle.get_type_name() == "child_value", base_value::get_type() == base_proxy);
    $display("UT: component proxy %0d type_name %0d", component_item.get_object_type() ==
             component_value::get_type(), component_item.get_type_name() == "component_value");
    $finish;
  end
endmodule
