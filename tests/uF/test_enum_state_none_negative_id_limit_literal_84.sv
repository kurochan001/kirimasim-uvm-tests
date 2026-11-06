/*
:name: test_enum_state_none_negative_id_limit_literal_84
:description: A qualified literal NONE probe keeps its no-verbosity-disable wording separate from the ordinary API bound
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.2.4 6.3.3.2 6.3.3.3 6.3.4.1 6.3.4.4 6.4.3.3 6.3.5.2 6.5.1.2.16 6.5.1.2.19 1800-2023 6.21 6.19.5 8.20 13.5.2
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers84_report/report84.svh
:expected_exit: 0
:expected_stdout: @test_enum_state_none_negative_id_limit_literal_84.expected
*/
// Standard-derived observations; no enum bit positions or report layout fixed.
module test_enum_state_none_negative_id_limit_literal_84;
  import uvm_pkg::*;
  `include "report84.svh"
  // Count matching fixture messages only during the selected API call.
  class none_observer84 extends report_observer84;
    bit active;
    int deliveries;
    uvm_report_object wanted;
    function new(); super.new(); active=0; deliveries=0; wanted=null; endfunction
    virtual function void execute_report_message(uvm_report_message message,
                                                  string composed_message);
      super.execute_report_message(message,composed_message);
      if(active && matches84(wanted,UVM_INFO,UVM_NONE,"N84","none84")) deliveries++;
    endfunction
  endclass
  initial begin
    automatic none_observer84 server=new();
    automatic uvm_report_object reporter=new("none84");
    uvm_report_server::set_server(server);
    reporter.set_report_severity_action(UVM_INFO,UVM_DISPLAY);
    reporter.set_report_id_verbosity("N84",-1);
    $display("UT: verbosity84 none_negative configured %0d query_bound %0d",
      reporter.get_report_verbosity_level(UVM_INFO,"N84")==-1,
      reporter.uvm_report_enabled(UVM_NONE,UVM_INFO,"N84")==0);
    server.wanted=reporter; server.active=1;
    reporter.uvm_report_info("N84","none84",UVM_NONE);
    server.active=0;
    $display("UT: verbosity84 none_negative delivered %0d",server.deliveries>0);
    server.deliveries=0;
    reporter.set_report_id_verbosity("N84",UVM_NONE);
    server.active=1;
    reporter.uvm_report_info("N84","none84",UVM_NONE);
    server.active=0;
    $display("UT: verbosity84 none_negative observer_control %0d",server.deliveries>0);
    $finish;
  end
endmodule
