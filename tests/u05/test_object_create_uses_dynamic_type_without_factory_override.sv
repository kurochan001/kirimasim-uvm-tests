/*
:name: test_object_create_uses_dynamic_type_without_factory_override
:description: virtual object create allocates the same dynamic type while registry create applies overrides (IEEE 1800.2-2020 Section 5.3.5.1)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.5.1 5.3.4.7 8.2.4.2.4 8.3.1.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_create_uses_dynamic_type_without_factory_override.expected
*/
// Object create allocates a new object of its own type. Registering a
// factory override changes registry creation while object create keeps its
// type.

module test_object_create_uses_dynamic_type_without_factory_override;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class base_value extends uvm_object;
    `uvm_object_utils(base_value)
    int payload = 7;
    function new(string name="base_value"); super.new(name); endfunction
  endclass
  class derived_value extends base_value;
    `uvm_object_utils(derived_value)
    function new(string name="derived_value"); super.new(name); endfunction
  endclass
  class replacement_value extends derived_value;
    `uvm_object_utils(replacement_value)
    function new(string name="replacement_value"); super.new(name); endfunction
  endclass

  initial begin
    automatic derived_value source = new("source");
    automatic uvm_object base_handle = source;
    automatic uvm_factory factory = uvm_factory::get();
    uvm_object created;
    derived_value typed_created;
    derived_value from_factory;
    source.payload = 99;
    factory.set_type_override_by_type(derived_value::get_type(), replacement_value::get_type());
    created = base_handle.create("fresh");
    if (!$cast(typed_created, created) || typed_created == null) $fatal(1, "created object type");
    from_factory = derived_value::type_id::create("from_factory");
    $display("UT: created type %s name %s distinct %0d payload %0d", created.get_type_name(),
             created.get_name(), created != source, typed_created.payload);
    $display("UT: registry type %s", from_factory.get_type_name());
    $finish;
  end
endmodule
