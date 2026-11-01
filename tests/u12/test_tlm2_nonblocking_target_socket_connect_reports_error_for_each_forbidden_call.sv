/*
:name: test_tlm2_nonblocking_target_socket_connect_reports_error_for_each_forbidden_call
:description: calling connect on a nonblocking target terminator reports an error (IEEE 1800.2-2020 Section 12.3.5.3.4)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.5.3.4 12.3.5.3.3 12.3.5.4.3 12.3.5.5.3 12.3.5.6.3 6.5.1.2.6 5.5.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_nonblocking_target_socket_connect_reports_error_for_each_forbidden_call.expected
*/
// A target terminator cannot initiate connect. Two compatible provider
// handles distinguish repeated required errors without fixing report text.
module test_tlm2_nonblocking_target_socket_connect_reports_error_for_each_forbidden_call;
  import uvm_pkg::*;

  class endpoint extends uvm_component;

    uvm_tlm_nb_target_socket#(endpoint) target;
    uvm_tlm_nb_initiator_socket#(endpoint) initiator;
    uvm_tlm_nb_passthrough_target_socket#() relay_target;
    uvm_tlm_nb_passthrough_initiator_socket#() relay_initiator;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      target = new("target", this); initiator = new("initiator", this);
      relay_target = new("relay_target", this); relay_initiator = new("relay_initiator", this);
    endfunction

    function uvm_tlm_sync_e nb_transport_fw(uvm_tlm_generic_payload t,
                                           ref uvm_tlm_phase_e p, uvm_tlm_time delay);
      return UVM_TLM_COMPLETED;
    endfunction
    function uvm_tlm_sync_e nb_transport_bw(uvm_tlm_generic_payload t,
                                           ref uvm_tlm_phase_e p, uvm_tlm_time delay);
      return UVM_TLM_COMPLETED;
    endfunction
  endclass

  initial begin
    endpoint owner;
    uvm_report_server server;
    int before_count;
    bit first_error;
    bit second_error;
    owner = new("owner", null); server = uvm_report_server::get_server();
    before_count = server.get_severity_count(UVM_ERROR);
    owner.target.connect(owner.initiator);
    first_error = server.get_severity_count(UVM_ERROR) > before_count;
    before_count = server.get_severity_count(UVM_ERROR);
    owner.target.connect(owner.relay_target);
    second_error = server.get_severity_count(UVM_ERROR) > before_count;
    $display("UT: forbidden_calls errors %0d %0d", first_error, second_error);
    $display("UT: retained_kind %0d bounds %0d/%0d", owner.target.is_imp(),
             owner.target.min_size(), owner.target.max_size());
    $finish;
  end

endmodule
