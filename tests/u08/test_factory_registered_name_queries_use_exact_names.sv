/*
:name: test_factory_registered_name_queries_use_exact_names
:description: registration name queries distinguish exact names from case and prefix variants (IEEE 1800.2-2020 Section 8.3.1.7.3)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.3.1.7.3 8.3.1.3 8.3.1.7.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_factory_registered_name_queries_use_exact_names.expected
*/
// Register a concrete type name and query several distinct strings.
// The factory has no aliases or overrides in this case.

module test_factory_registered_name_queries_use_exact_names;
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
    factory.register(base_type);
    $display("UT: exact %0d uppercase %0d prefix %0d suffix %0d",
        factory.is_type_name_registered("base_item"),
             factory.is_type_name_registered("BASE_ITEM"),
                 factory.is_type_name_registered("base"),
                     factory.is_type_name_registered("base_item_extra"));
    $display("UT: exact_wrapper %0d empty %0d absent %0d",
        factory.find_wrapper_by_name("base_item") == base_type,
             factory.is_type_name_registered(""), factory.is_type_name_registered("missing_item"));
    $finish;
  end
endmodule
