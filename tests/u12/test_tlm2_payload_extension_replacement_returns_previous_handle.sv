/*
:name: test_tlm2_payload_extension_replacement_returns_previous_handle
:description: generic payload extension replacement returns the old handle without increasing type count (IEEE 1800.2-2020 Section 12.3.4.2.44)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.2.44 12.3.4.2.43 12.3.4.2.42 12.3.4.5.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_payload_extension_replacement_returns_previous_handle.expected
*/
// Insert two distinct instances of one extension type. Retained
// application handles remain available after replacement.

module test_tlm2_payload_extension_replacement_returns_previous_handle;
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
    automatic tag_extension first = new("first");
    automatic tag_extension second = new("second");
    uvm_tlm_extension_base previous;
    first.value = 11;
    second.value = 29;
    void'(payload.set_extension(first));
    previous = payload.set_extension(second);
    $display("UT: previous_same %0d current_same %0d count %0d", previous == first,
             payload.get_extension(tag_extension::ID()) == second, payload.get_num_extensions());
    $display("UT: retained_values %0d %0d", first.value, second.value);
    $finish;
  end
endmodule
