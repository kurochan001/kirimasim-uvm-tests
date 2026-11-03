/*
:name: test_object_registry_singletons_preserve_specialization_names_without_constructing_items
:description: registry singleton identity, explicit/default type names and lazy construction (8.2.4)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.2.4.2.3 8.2.4.2.2 8.2.4.1 8.2.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_registry_singletons_preserve_specialization_names_without_constructing_items.expected
*/
module test_object_registry_singletons_preserve_specialization_names_without_constructing_items;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class represented extends uvm_object;
    static int made = 0;
    function new(string name=""); super.new(name); made++; endfunction
  endclass
  typedef uvm_object_registry#(represented, "named_proxy") named_registry;
  typedef uvm_object_registry#(represented, "other_proxy") other_registry;
  typedef uvm_object_registry#(represented) default_registry;
  // Distinct Tname specializations are compared through their common base.
  initial begin
    automatic uvm_object_wrapper first = named_registry::get();
    automatic uvm_object_wrapper again = named_registry::get();
    automatic uvm_object_wrapper other = other_registry::get();
    automatic uvm_object_wrapper unnamed = default_registry::get();
    $display("UT: singleton %0d specializations_distinct %0d constructors %0d",
             first == again, first != other && first != unnamed && other != unnamed,
             represented::made);
    $display("UT: names %s %s %s", first.get_type_name(), other.get_type_name(),
             unnamed.get_type_name());
    $finish;
  end
endmodule
