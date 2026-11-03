/*
:name: test_tlm2_nonblocking_initiator_connect_accepts_all_three_declared_provider_families
:description: tlm2 nonblocking initiator connect accepts all three declared provider families (IEEE 1800.2-2020 Section 12.3.5.4.4)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.5.4.4 12.3.5.3.1 12.3.5.5.1 12.3.5.6.1 5.5.2.14 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_nonblocking_initiator_connect_accepts_all_three_declared_provider_families.expected
*/
// Before elaboration, invoke connect with each literal listed provider family.
// No runtime transport or backward resolution is claimed. The selected legal
// nonblocking defaults use matching generic payload and
// standard phase types. Custom-phase printed signatures and illegal provider
// diagnostics are not inferred.
module test_tlm2_nonblocking_initiator_connect_accepts_all_three_declared_provider_families;
  import uvm_pkg::*;
  class endpoint extends uvm_component;
    function new(); super.new("owner",null); endfunction
    function uvm_tlm_sync_e nb_transport_fw(uvm_tlm_generic_payload value,
        ref uvm_tlm_phase_e phase,input uvm_tlm_time delay); return UVM_TLM_COMPLETED; endfunction
    function uvm_tlm_sync_e nb_transport_bw(uvm_tlm_generic_payload value,
        ref uvm_tlm_phase_e phase,input uvm_tlm_time delay); return UVM_TLM_COMPLETED; endfunction
  endclass
  initial begin
    automatic endpoint owner = new();
    automatic uvm_report_server server = uvm_report_server::get_server();
    automatic uvm_tlm_nb_target_socket#(endpoint) provider_0 = new("provider_0",owner);
    automatic uvm_tlm_nb_initiator_socket#(endpoint) consumer_0 = new("consumer_0",owner);
    automatic uvm_tlm_nb_passthrough_initiator_socket#() provider_1 = new("provider_1",owner);
    automatic uvm_tlm_nb_initiator_socket#(endpoint) consumer_1 = new("consumer_1",owner);
    automatic uvm_tlm_nb_passthrough_target_socket#() provider_2 = new("provider_2",owner);
    automatic uvm_tlm_nb_initiator_socket#(endpoint) consumer_2 = new("consumer_2",owner);
    int before_count,after_count;
    bit accepted[3];
    automatic int errors = 0;
    before_count = server.get_severity_count(UVM_ERROR);
    consumer_0.connect(provider_0); after_count = server.get_severity_count(UVM_ERROR);
    accepted[0] = after_count == before_count; errors += after_count - before_count;
    before_count = server.get_severity_count(UVM_ERROR);
    consumer_1.connect(provider_1); after_count = server.get_severity_count(UVM_ERROR);
    accepted[1] = after_count == before_count; errors += after_count - before_count;
    before_count = server.get_severity_count(UVM_ERROR);
    consumer_2.connect(provider_2); after_count = server.get_severity_count(UVM_ERROR);
    accepted[2] = after_count == before_count; errors += after_count - before_count;
    $display("UT: listed_providers accepted %0d/%0d/%0d errors %0d",
             accepted[0],accepted[1],accepted[2],errors);
    $finish;
  end
endmodule
