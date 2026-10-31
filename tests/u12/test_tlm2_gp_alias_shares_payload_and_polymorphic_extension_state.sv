/*
:name: test_tlm2_gp_alias_shares_payload_and_polymorphic_extension_state
:description: generic payload short alias shares extension bindings with its canonical type (IEEE 1800.2-2020 Section 12.3.4.3)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.3 12.3.4.4.4 12.3.4.2.43 12.3.4.2.44 12.3.4.2.46 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_gp_alias_shares_payload_and_polymorphic_extension_state.expected
*/
// Assign the short payload alias to the canonical type and mutate bindings
// through both handles. Observe identity and the same polymorphic type key.

module test_tlm2_gp_alias_shares_payload_and_polymorphic_extension_state;
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
    automatic uvm_tlm_gp alias_value = new("alias_value");
    automatic uvm_tlm_generic_payload canonical = alias_value;
    automatic label_extension extension_value = new("extension_value");
    automatic uvm_tlm_extension_base key = extension_value.get_type_handle();
    uvm_tlm_extension_base previous;
    previous = alias_value.set_extension(extension_value);
    $display("UT: alias_same %0d retrieved_same %0d count %0d", alias_value == canonical,
             canonical.get_extension(key) == extension_value, canonical.get_num_extensions());
    canonical.clear_extensions();
    $display("UT: cleared %0d key_stable %0d", alias_value.get_num_extensions(),
             extension_value.get_type_handle() == key);
    $finish;
  end
endmodule
