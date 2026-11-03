/*
:name: test_tlm2_payload_inherited_rand_fields_constrain_public_scalar_and_array_observations
:description: tlm2 payload inherited rand fields constrain public scalar and array observations (IEEE 1800.2-2020 Section 12.3.4.2.7)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.2.7 12.3.4.2.1 12.3.4.2.8 12.3.4.2.9 12.3.4.2.10 12.3.4.2.11 12.3.4.2.12 12.3.4.2.13 12.3.4.2.14 12.3.4.1.1 12.3.4.1.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_payload_inherited_rand_fields_constrain_public_scalar_and_array_observations.expected
*/
// Constrain inherited rand members only within an original derived constraint,
// then observe through real base accessors. Every reported value is
// constrained,
// not seed-dependent. Lengths equal array sizes here; mismatched-length
// wording,
// physical bus rules, interconnect preservation and target algorithms stay
// open.
module test_tlm2_payload_inherited_rand_fields_constrain_public_scalar_and_array_observations;
  import uvm_pkg::*;
  class constrained_payload extends uvm_tlm_generic_payload;
    function new(); super.new("constrained"); endfunction
    constraint selected_values {
      m_address == 64'hf123456789abcdef;
      m_command == UVM_TLM_WRITE_COMMAND;
      m_length == 3;
      m_data.size() == 3;
      m_data[0] == 8'ha5; m_data[1] == 8'h00; m_data[2] == 8'hff;
      m_response_status == UVM_TLM_INCOMPLETE_RESPONSE;
      m_byte_enable.size() == 2;
      m_byte_enable[0] == 8'hff; m_byte_enable[1] == 8'h00;
      m_byte_enable_length == 2;
      m_streaming_width == 2;
    }
  endclass
  initial begin
    automatic constrained_payload probe = new();
    automatic uvm_tlm_generic_payload base = probe;
    byte unsigned data_value[],enable_value[];
    if (!probe.randomize()) $fatal(1,"payload constraints unsatisfied");
    base.get_data(data_value); base.get_byte_enable(enable_value);
    $display("UT: payload_rand_scalars address %0d write %0d length %0d width %0d incomplete %0d",
             base.get_address() == 64'hf123456789abcdef,base.is_write(),
             base.get_data_length(),base.get_streaming_width(),
             base.get_response_status() == UVM_TLM_INCOMPLETE_RESPONSE);
    $display("UT: payload_rand_arrays data %0d/%0d/%0d/%0d enable %0d/%0d/%0d length %0d",
             data_value.size(),data_value[0],data_value[1],data_value[2],enable_value.size(),
             enable_value[0],enable_value[1],base.get_byte_enable_length());
    $finish;
  end
endmodule
