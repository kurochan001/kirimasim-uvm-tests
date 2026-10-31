/*
:name: test_tlm2_payload_pack_field_order_is_decodable_by_public_packer
:description: generic payload packing and unpacking preserve the prescribed fields and lengths (IEEE 1800.2-2020 Section 12.3.4.2.4)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.2.4 12.3.4.2.5 16.5.4.17 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_payload_pack_field_order_is_decodable_by_public_packer.expected
*/
// Call the payload pack hook directly so no object marker is involved.
// Decode fields in their prescribed order with their declared widths.
// The stream bits and byte-order representation are not inspected.

module test_tlm2_payload_pack_field_order_is_decodable_by_public_packer;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_tlm_generic_payload source = new("source");
    automatic uvm_tlm_generic_payload target = new("target");
    automatic uvm_packer packer = new;
    automatic byte unsigned data_bytes[] = '{8'h81, 8'h24};
    automatic byte unsigned enable_bytes[] = '{8'hff};
    source.set_address(64'h1020304050607080);
    source.set_command(UVM_TLM_WRITE_COMMAND);
    source.set_data(data_bytes);
    source.set_data_length(2);
    source.set_dmi_allowed(1);
    source.set_response_status(UVM_TLM_ADDRESS_ERROR_RESPONSE);
    source.set_byte_enable(enable_bytes);
    source.set_byte_enable_length(1);
    source.set_streaming_width(2);
    source.do_pack(packer);
    begin
      automatic longint unsigned address = packer.unpack_field_int(64);
      automatic int command_value = packer.unpack_field_int(32);
      automatic int length_value = packer.unpack_field_int(32);
      automatic bit dmi_value = packer.unpack_field_int(1);
      automatic byte unsigned first_byte = packer.unpack_field_int(8);
      automatic byte unsigned second_byte = packer.unpack_field_int(8);
      automatic int status_value = packer.unpack_field_int(32);
      automatic int enable_length = packer.unpack_field_int(32);
      automatic byte unsigned enable_value = packer.unpack_field_int(8);
      automatic int width_value = packer.unpack_field_int(32);
      $display("UT: address %016h", address);
      $display("UT: command %0d length %0d dmi %0d", command_value, length_value, dmi_value);
      $display("UT: data %02h %02h", first_byte, second_byte);
      $display("UT: status_same %0d", status_value == int'(UVM_TLM_ADDRESS_ERROR_RESPONSE));
      $display("UT: enable_length %0d enable %02h width %0d", enable_length,
               enable_value, width_value);
    end
    $finish;
  end
endmodule
