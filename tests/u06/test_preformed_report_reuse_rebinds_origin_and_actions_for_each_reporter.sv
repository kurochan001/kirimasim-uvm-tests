/*
:name: test_preformed_report_reuse_rebinds_origin_and_actions_for_each_reporter
:description: reused preformed reports follow the current reporter and its action configuration (IEEE 1800.2-2020 Section 6.3.3.4)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.3.3.4 6.6.3.10 6.6.3.1 6.6.3.7 6.2.3.1 6.3.5.2 6.2.4.10 D.4.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_preformed_report_reuse_rebinds_origin_and_actions_for_each_reporter.expected
*/
// Reuse is sequential. Each reporter has its own callback registration and
// action. The tail catches both; no output or concurrent-reuse claim is made.
// The pinned release omits required catcher get_report_message.
// Keep the public API and expected behavior without a private substitute.

module test_preformed_report_reuse_rebinds_origin_and_actions_for_each_reporter;
  import uvm_pkg::*;
  class probe_type extends uvm_report_catcher;
    uvm_report_message expected;
    uvm_report_object client;
    uvm_action expected_action;
    int visits = 0;
    bit same = 1, origin = 1, actions = 1;
    function new(); super.new("probe"); endfunction
    virtual function action_e catch();
      uvm_report_message current;
      current = get_report_message(); visits++;
      same &= current == expected;
      origin &= get_client() == client && current.get_report_object() == client;
      actions &= get_action() == expected_action;
      return CAUGHT;
    endfunction
  endclass
  initial begin
    automatic uvm_report_object first = new("first");
    automatic uvm_report_object second = new("second");
    automatic uvm_report_message msg = uvm_report_message::new_report_message("input");
    automatic probe_type probe = new();
    msg.set_report_message(UVM_INFO, "reuse", "payload", UVM_NONE, "", 0, "ctx");
    first.set_report_severity_action(UVM_INFO, UVM_DISPLAY);
    second.set_report_severity_action(UVM_INFO, UVM_DISPLAY | UVM_COUNT);
    probe.expected = msg;
    uvm_report_cb::add(first, probe); uvm_report_cb::add(second, probe);
    probe.client = first; probe.expected_action = UVM_DISPLAY;
    first.uvm_process_report_message(msg);
    $display("UT: first visits %0d same %0d origin %0d action %0d", probe.visits,
             probe.same, probe.origin, probe.actions);
    probe.client = second; probe.expected_action = UVM_DISPLAY | UVM_COUNT;
    second.uvm_process_report_message(msg);
    $display("UT: second visits %0d same %0d origin %0d action %0d caller_origin %0d",
             probe.visits, probe.same, probe.origin, probe.actions,
             msg.get_report_object() == second);
    uvm_report_cb::delete(first, probe); uvm_report_cb::delete(second, probe); $finish;
  end
endmodule
