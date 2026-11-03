/*
:name: test_tlm2_blocking_passthrough_target_connect_accepts_its_spec_listed_provider_families
:description: tlm2 blocking passthrough target connect accepts its spec listed provider families (IEEE 1800.2-2020 Section 12.3.5.8.4)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.5.8.4 12.3.5.3.1 12.3.5.5.1 12.3.5.6.1 5.5.2.14 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_blocking_passthrough_target_connect_accepts_its_spec_listed_provider_families.expected
*/
// Before elaboration, invoke connect with each literal listed provider family.
// No runtime transport or backward resolution is claimed. This is a qualified
// printed-list interpretation: the blocking heading and
// nonblocking provider names conflict. Preserve that interpretation and any
// observed rejection separately from the operational blocking-path control.
module test_tlm2_blocking_passthrough_target_connect_accepts_its_spec_listed_provider_families;
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
    automatic uvm_tlm_b_passthrough_target_socket#() consumer_0 = new("consumer_0",owner);
    automatic uvm_tlm_nb_passthrough_target_socket#() provider_1 = new("provider_1",owner);
    automatic uvm_tlm_b_passthrough_target_socket#() consumer_1 = new("consumer_1",owner);
    int before_count,after_count;
    bit accepted[2];
    automatic int errors = 0;
    before_count = server.get_severity_count(UVM_ERROR);
    consumer_0.connect(provider_0); after_count = server.get_severity_count(UVM_ERROR);
    accepted[0] = after_count == before_count; errors += after_count - before_count;
    before_count = server.get_severity_count(UVM_ERROR);
    consumer_1.connect(provider_1); after_count = server.get_severity_count(UVM_ERROR);
    accepted[1] = after_count == before_count; errors += after_count - before_count;
    $display("UT: listed_providers accepted %0d/%0d errors %0d",
             accepted[0],accepted[1],errors);
    $finish;
  end
endmodule
