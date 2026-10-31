/*
:name: test_tlm2_payload_extension_uses_unique_type_key
:description: generic payload extension insertion uses a stable unique key for its type (IEEE 1800.2-2020 Section 12.3.4.2.44)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.2.44 12.3.4.2.43 12.3.4.2.42 12.3.4.5.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_payload_extension_uses_unique_type_key.expected
*/
// Compare extension type keys through their common base type and
// retrieve the exact inserted handle. No numeric ID value is prescribed.

module test_tlm2_payload_extension_uses_unique_type_key;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class tag_extension extends uvm_tlm_extension#(tag_extension);
    `uvm_object_utils(tag_extension)
    int value = 0;
    function new(string name="tag_extension"); super.new(name); endfunction
  endclass
  class route_extension extends uvm_tlm_extension#(route_extension);
    `uvm_object_utils(route_extension)
    function new(string name="route_extension"); super.new(name); endfunction
  endclass

  initial begin
    automatic uvm_tlm_generic_payload payload = new("payload");
    automatic tag_extension value = new("value");
    automatic uvm_tlm_extension_base tag_key = tag_extension::ID();
    automatic uvm_tlm_extension_base route_key = route_extension::ID();
    uvm_tlm_extension_base previous;
    previous = payload.set_extension(value);
    $display("UT: inserted previous_null %0d count %0d handle_same %0d", previous == null,
             payload.get_num_extensions(), payload.get_extension(tag_key) == value);
    $display("UT: stable_key %0d distinct_keys %0d absent_route %0d",
        tag_key == tag_extension::ID(),
             tag_key != route_key, payload.get_extension(route_key) == null);
    $finish;
  end
endmodule
