/*
:name: test_core_service_report_server_selection_and_restoration
:description: core service selects and restores the report server (IEEE 1800.2-2020 Section F.4.1.4.5)
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.4.1.4.5 F.4.1.4.4 F.4.1.3 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_core_service_report_server_selection_and_restoration.expected
*/
// Swap valid concrete service instances and restore the saved handle.
// No factory creation, override execution or report-count migration is claimed.
module test_core_service_report_server_selection_and_restoration;
  import uvm_pkg::*;

  initial begin
    automatic uvm_coreservice_t core = uvm_coreservice_t::get();
    automatic uvm_report_server saved = core.get_report_server();
    automatic uvm_default_report_server first = new();
    automatic uvm_default_report_server second = new();
    core.set_report_server(first);
    $display("UT: selected first %0d shared_service %0d", core.get_report_server() == first,
    uvm_coreservice_t::get() == core);
    core.set_report_server(second);
    $display("UT: selected second %0d excludes_first %0d", core.get_report_server() == second,
    core.get_report_server() != first);
    core.set_report_server(saved);
    $display("UT: restored exact %0d", core.get_report_server() == saved);
    $finish;
  end

endmodule
