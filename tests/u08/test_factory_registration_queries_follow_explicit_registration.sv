/*
:name: test_factory_registration_queries_follow_explicit_registration
:description: name and type registration queries reflect explicit registration in a local factory (IEEE 1800.2-2020 Section 8.3.1.3)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.3.1.3 8.3.1.7.3 8.3.1.7.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_factory_registration_queries_follow_explicit_registration.expected
*/
// Registry macros register with the global factory. Use a separate
// default-factory instance to observe its own explicit registration.

module test_factory_registration_queries_follow_explicit_registration;
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
    automatic uvm_object_wrapper other_type = other_item::get_type();
    $display("UT: before name %0d type %0d", factory.is_type_name_registered("base_item"),
        factory.is_type_registered(base_type));
    factory.register(base_type);
    $display("UT: after name %0d type %0d", factory.is_type_name_registered("base_item"),
        factory.is_type_registered(base_type));
    $display("UT: other name %0d type %0d", factory.is_type_name_registered("other_item"),
        factory.is_type_registered(other_type));
    $finish;
  end
endmodule
