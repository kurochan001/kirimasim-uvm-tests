/*
:name: test_tlm2_extension_polymorphic_type_handle_is_shared_by_same_type_instances
:description: polymorphic extension type handles identify a type independently of an instance (IEEE 1800.2-2020 Section 12.3.4.4.4)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.4.4 12.3.4.5.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_extension_polymorphic_type_handle_is_shared_by_same_type_instances.expected
*/
// Compare base-handle dispatch on two distinct instances with the static
// ID. Check relationships rather than a numeric identifier.

module test_tlm2_extension_polymorphic_type_handle_is_shared_by_same_type_instances;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class label_extension extends uvm_tlm_extension#(label_extension);
    `uvm_object_utils(label_extension)
    function new(string name="label_extension"); super.new(name); endfunction
  endclass
  class route_extension extends uvm_tlm_extension#(route_extension);
    `uvm_object_utils(route_extension)
    function new(string name="route_extension"); super.new(name); endfunction
  endclass

  initial begin
    automatic label_extension first = new("first");
    automatic label_extension second = new("second");
    automatic uvm_tlm_extension_base first_view = first;
    automatic uvm_tlm_extension_base second_view = second;
    automatic uvm_tlm_extension_base key = first_view.get_type_handle();
    $display("UT: instances_distinct %0d key_nonnull %0d same_key %0d static_same %0d",
             first != second, key != null, key == second_view.get_type_handle(), key ==
                 label_extension::ID());
    $finish;
  end
endmodule
