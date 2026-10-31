/*
:name: test_tlm2_payload_pack_does_not_serialize_source_extensions
:description: generic payload packing and unpacking preserve the prescribed fields and lengths (IEEE 1800.2-2020 Section 12.3.4.2.4)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.2.4 12.3.4.2.5 12.3.4.2.43 12.3.4.2.44 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_payload_pack_does_not_serialize_source_extensions.expected
*/
// Attach a source extension with observable pack hooks. Default payload
// packing must not invoke those hooks or create an extension in the receiver.

module test_tlm2_payload_pack_does_not_serialize_source_extensions;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class label_extension extends uvm_tlm_extension#(label_extension);
    `uvm_object_utils(label_extension)
    static int pack_calls = 0;
    static int unpack_calls = 0;
    int value = 0;
    function new(string name="label_extension"); super.new(name); endfunction
    function void do_pack(uvm_packer packer); pack_calls++; endfunction
    function void do_unpack(uvm_packer packer); unpack_calls++; endfunction
  endclass

  initial begin
    automatic uvm_tlm_generic_payload source = new("source");
    automatic uvm_tlm_generic_payload target = new("target");
    automatic uvm_packer packer = new;
    automatic label_extension label_value = new("label_value");
    uvm_tlm_extension_base previous;
    previous = source.set_extension(label_value);
    source.do_pack(packer);
    target.do_unpack(packer);
    $display("UT: source_same %0d destination_extensions %0d hooks %0d %0d",
             source.get_extension(label_extension::ID()) == label_value,
             target.get_num_extensions(), label_extension::pack_calls,
                 label_extension::unpack_calls);
    $finish;
  end
endmodule
