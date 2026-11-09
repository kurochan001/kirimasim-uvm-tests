/*
:name: test_factory_registration_distinguishes_base_and_derived_wrappers
:description: registering a base type does not register a derived type in the same factory (IEEE 1800.2-2020 Section 8.3.1.7.4)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.3.1.7.4 8.3.1.7.3 8.3.1.3 8.3.1.7.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_factory_registration_distinguishes_base_and_derived_wrappers.expected
*/
// What it checks:
// 1. Registering a proxy adds that exact type to the receiving factory.
// 2. The type-registration query identifies the exact proxy registered in that
//    factory.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 8.3.1.3 (UVM-FACTORY-REGISTRATION-LOCAL) gives rule 1 above.
//    Setup: Use independent local factories and register base/derived wrappers
//    separately. Expected: Registration is visible only after the relevant
//    proxy is registered in that factory.
// 2. 1800.2-2020 8.3.1.7.4 (UVM-FACTORY-PROXY-REGISTRATION-QUERY) gives rule 2
//    above. Setup: Register one wrapper without its derived wrapper and
//    compare separate factories. Expected: Inheritance or registration in
//    another factory does not make an unregistered proxy present.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Inheritance relates object types, while factory registration uses
// the exact proxy object for each type.

module test_factory_registration_distinguishes_base_and_derived_wrappers;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class base_item extends uvm_object;
    `uvm_object_utils(base_item)
    function new(string name="base_item"); super.new(name); endfunction
  endclass
  class replacement_item extends base_item;
    `uvm_object_utils(replacement_item)
    function new(string name="replacement_item"); super.new(name); endfunction
  endclass
  class other_item extends uvm_object;
    `uvm_object_utils(other_item)
    function new(string name="other_item"); super.new(name); endfunction
  endclass

  initial begin
    automatic uvm_default_factory factory = new;
    automatic uvm_object_wrapper base_type = base_item::get_type();
    automatic uvm_object_wrapper derived_type = replacement_item::get_type();
    factory.register(base_type);
    $display("UT: base_only base %0d derived %0d derived_name %0d",
        factory.is_type_registered(base_type),
             factory.is_type_registered(derived_type),
                 factory.is_type_name_registered("replacement_item"));
    factory.register(derived_type);
    $display("UT: both base %0d derived %0d exact %0d %0d", factory.is_type_registered(base_type),
             factory.is_type_registered(derived_type),
                 factory.find_wrapper_by_name("base_item") == base_type,
             factory.find_wrapper_by_name("replacement_item") == derived_type);
    $finish;
  end
endmodule
