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
// What it checks:
// 1. Static get_type identifies its declared type independently of a factory
//    override.
// 2. Virtual get_object_type identifies the allocated dynamic object type.
// 3. get_type_name returns the defined type name of the current dynamic
//    object.
// 4. Instance renaming preserves its dynamic type proxy.
// 5. Instance renaming leaves the defined type name unchanged.
// 6. Object utility macros implement the static type-proxy API.
// 7. Object utility macros implement an instance proxy for its actual type.
// 8. Object utility macros implement get_type_name using the supplied type
//    name.
// 9. Component utility macros implement get_type_name using the supplied type
//    name.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 5.3.4.5 (UVM-OBJECT-TRAIT-STATIC-PROXY-STABILITY) gives rule
//    1 above. Setup: Registered base/child object types and one component type
//    are queried around a base-to-child factory override. Expected: Base and
//    child static proxies retain their saved, distinct identities.
// 2. 1800.2-2020 5.3.4.6 (UVM-OBJECT-TRAIT-DYNAMIC-PROXY-ACTUAL-TYPE) gives
//    rule 2 above. Setup: Registered base/child object types and one component
//    type are queried around a base-to-child factory override. Expected:
//    Direct base returns base proxy; a factory-created child through a base
//    handle returns child proxy.
// 3. 1800.2-2020 5.3.4.7 (UVM-OBJECT-TRAIT-DYNAMIC-TYPE-NAME) gives rule 3
//    above. Setup: Registered base/child object types and one component type
//    are queried around a base-to-child factory override. Expected: The direct
//    and created instances identify base_value and child_value.
// 4. 1800.2-2020 5.3.4.6 (UVM-OBJECT-TRAIT-RENAME-PRESERVES-PROXY) gives rule
//    4 above. Setup: Registered base/child object types and one component type
//    are queried around a base-to-child factory override. Expected: Renamed
//    child still returns the child proxy.
// 5. 1800.2-2020 5.3.4.7 (UVM-OBJECT-TRAIT-RENAME-PRESERVES-TYPE-NAME) gives
//    rule 5 above. Setup: Registered base/child object types and one component
//    type are queried around a base-to-child factory override. Expected:
//    Renamed instance still identifies child_value.
// 6. 1800.2-2020 B.2.1.2 (UVM-OBJECT-TRAIT-OBJECT-MACRO-STATIC-PROXY) gives
//    rule 6 above. Setup: Registered base/child object types and one component
//    type are queried around a base-to-child factory override. Expected:
//    Macro-generated base/child proxies retain distinct identity.
// 7. 1800.2-2020 B.2.1.2 (UVM-OBJECT-TRAIT-OBJECT-MACRO-DYNAMIC-PROXY) gives
//    rule 7 above. Setup: Registered base/child object types and one component
//    type are queried around a base-to-child factory override. Expected: The
//    allocated child proxy is returned through a base object handle.
// 8. 1800.2-2020 B.2.1.2 (UVM-OBJECT-TRAIT-OBJECT-MACRO-TYPE-NAME) gives rule
//    8 above. Setup: Registered base/child object types and one component type
//    are queried around a base-to-child factory override. Expected: Generated
//    type strings identify base_value and child_value.
// 9. 1800.2-2020 B.2.1.3 (UVM-OBJECT-TRAIT-COMPONENT-MACRO-TYPE-NAME) gives
//    rule 9 above. Setup: Registered base/child object types and one component
//    type are queried around a base-to-child factory override. Expected: The
//    component type string identifies component_value.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
