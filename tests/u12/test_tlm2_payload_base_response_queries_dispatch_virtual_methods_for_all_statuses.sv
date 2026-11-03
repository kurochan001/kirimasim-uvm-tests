/*
:name: test_tlm2_payload_base_response_queries_dispatch_virtual_methods_for_all_statuses
:description: tlm2 payload base response queries dispatch virtual strings and predicates for all statuses (IEEE 1800.2-2020 Section 12.3.4.2.40)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.2.40 12.3.4.2.15 12.3.4.2.38 12.3.4.2.39 12.3.4.1.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_payload_base_response_queries_dispatch_virtual_methods_for_all_statuses.expected
*/
// The original prefix and counters check virtual response-string dispatch.
// no exact spelling or format from the underlying standard getter is presumed.
// Real base predicates are checked for every named standard status. Default
// response-string representation and bus-error selection remain separate work.
// Count selected external queries; internal predicate delegation is free.
module test_tlm2_payload_base_response_queries_dispatch_virtual_methods_for_all_statuses;
  import uvm_pkg::*;
  class status_probe extends uvm_tlm_generic_payload;
    int string_calls = 0,ok_calls = 0,error_calls = 0;
    int selected_query = 0;
    function new(); super.new("probe"); endfunction
    virtual function string get_response_string();
      if (selected_query == 1) string_calls++;
      return {"probe:",super.get_response_string()};
    endfunction
    virtual function bit is_response_ok();
      if (selected_query == 2) ok_calls++;
      return super.is_response_ok();
    endfunction
    virtual function bit is_response_error();
      if (selected_query == 3) error_calls++;
      return super.is_response_error();
    endfunction
  endclass
  initial begin
    automatic status_probe probe = new();
    automatic uvm_tlm_generic_payload base = probe;
    automatic uvm_tlm_response_status_e statuses[7] = '{
      UVM_TLM_OK_RESPONSE,UVM_TLM_INCOMPLETE_RESPONSE,UVM_TLM_GENERIC_ERROR_RESPONSE,
      UVM_TLM_ADDRESS_ERROR_RESPONSE,UVM_TLM_COMMAND_ERROR_RESPONSE,
      UVM_TLM_BURST_ERROR_RESPONSE,UVM_TLM_BYTE_ENABLE_ERROR_RESPONSE};
    automatic bit results = 1;
    string text;
    foreach (statuses[i]) begin
      base.set_response_status(statuses[i]); probe.selected_query = 1;
      text = base.get_response_string();
      results &= text.substr(0,5) == "probe:";
      probe.selected_query = 2;
      results &= base.is_response_ok() == (statuses[i] == UVM_TLM_OK_RESPONSE);
      probe.selected_query = 3;
      results &= base.is_response_error() == (statuses[i] != UVM_TLM_OK_RESPONSE);
      probe.selected_query = 0;
    end
    $display("UT: response_query_dispatch string %0d ok %0d error %0d all_statuses %0d",
             probe.string_calls,probe.ok_calls,probe.error_calls,results);
    $finish;
  end
endmodule
