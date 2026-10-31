/*
:name: test_tlm2_payload_extension_replacement_retains_key_across_instance_names
:description: same-type replacement retains its polymorphic key independently of instance names (IEEE 1800.2-2020 Section 12.3.4.4.4)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.4.4 12.3.4.2.43 12.3.4.2.44 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_payload_extension_replacement_retains_key_across_instance_names.expected
*/
// Obtain a key from the original instance, replace it with another name,
// and retrieve through that durable key. The returned prior handle is exact.

module test_tlm2_payload_extension_replacement_retains_key_across_instance_names;
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
    automatic uvm_tlm_generic_payload payload = new("payload");
    automatic label_extension first = new("first");
    automatic label_extension second = new("second");
    automatic uvm_tlm_extension_base key = first.get_type_handle();
    uvm_tlm_extension_base previous;
    previous = payload.set_extension(first);
    previous = payload.set_extension(second);
    $display("UT: previous_same %0d key_same %0d replacement_same %0d count %0d", previous == first,
             second.get_type_handle() == key, payload.get_extension(key) == second,
                 payload.get_num_extensions());
    $finish;
  end
endmodule
