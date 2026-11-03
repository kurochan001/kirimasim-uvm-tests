/*
:name: test_tlm2_payload_base_handle_dispatches_virtual_width_dmi_and_status_accessors
:description: base-typed payload hint and status accessors retain virtual dispatch and values (12.3.4.2.15)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.2.15 12.3.4.2.28 12.3.4.2.29 12.3.4.2.34 12.3.4.2.35 12.3.4.2.36 12.3.4.2.37 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_payload_base_handle_dispatches_virtual_width_dmi_and_status_accessors.expected
*/
// Virtual-dispatch observations are separate from transport and DMI mappings.
// Only direct public calls are counted after construction.
module test_tlm2_payload_base_handle_dispatches_virtual_width_dmi_and_status_accessors;
  import uvm_pkg::*;
  class payload extends uvm_tlm_generic_payload;
    int width_sets = 0, width_gets = 0, dmi_sets = 0, dmi_gets = 0;
    int status_sets = 0, status_gets = 0;
    function new(); super.new("payload"); endfunction
    virtual function void set_streaming_width(int unsigned width);
      width_sets++; super.set_streaming_width(width);
    endfunction
    virtual function int unsigned get_streaming_width();
      width_gets++; return super.get_streaming_width();
    endfunction
    virtual function void set_dmi_allowed(bit dmi);
      dmi_sets++; super.set_dmi_allowed(dmi);
    endfunction
    virtual function bit is_dmi_allowed();
      dmi_gets++; return super.is_dmi_allowed();
    endfunction
    virtual function void set_response_status(uvm_tlm_response_status_e status);
      status_sets++; super.set_response_status(status);
    endfunction
    virtual function uvm_tlm_response_status_e get_response_status();
      status_gets++; return super.get_response_status();
    endfunction
  endclass
  initial begin
    automatic payload probe = new();
    automatic uvm_tlm_generic_payload base = probe;
    int unsigned width;
    bit dmi;
    uvm_tlm_response_status_e status;
    probe.width_sets = 0; probe.width_gets = 0; probe.dmi_sets = 0; probe.dmi_gets = 0;
    probe.status_sets = 0; probe.status_gets = 0;
    base.set_streaming_width(3); base.set_dmi_allowed(1);
    base.set_response_status(UVM_TLM_ADDRESS_ERROR_RESPONSE);
    width = base.get_streaming_width(); dmi = base.is_dmi_allowed();
    status = base.get_response_status();
    $display("UT: dispatch width %0d %0d dmi %0d %0d status %0d %0d", probe.width_sets,
             probe.width_gets, probe.dmi_sets, probe.dmi_gets, probe.status_sets,
             probe.status_gets);
    $display("UT: values width %0d dmi %0d address_error %0d", width, dmi,
             status == UVM_TLM_ADDRESS_ERROR_RESPONSE);
    $finish;
  end
endmodule
