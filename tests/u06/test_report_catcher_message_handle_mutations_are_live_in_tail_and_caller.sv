/*
:name: test_report_catcher_message_handle_mutations_are_live_in_tail_and_caller
:description: mutating the current message object is visible through catcher getters and caller aliases (IEEE 1800.2-2020 Section 6.6.3.10)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.6.3.10 6.3.3.4 6.2.4.1 6.2.4.2 6.2.4.3 6.2.4.4 6.2.4.5 6.2.4.6 6.2.4.7 6.2.4.8 6.2.4.10 6.6.3.2 6.6.3.3 6.6.3.4 6.6.3.5 6.6.3.6 6.6.3.7 6.6.3.8 6.6.3.9 6.6 D.4.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_catcher_message_handle_mutations_are_live_in_tail_and_caller.expected
*/
// Mutations use public report-message setters, not catcher setter wrappers.
// Tail and caller aliases observe the same object; the report is caught.
// The pinned release omits required catcher get_report_message.
// Keep the public API and expected behavior without a private substitute.

module test_report_catcher_message_handle_mutations_are_live_in_tail_and_caller;
  import uvm_pkg::*;
  class mutator extends uvm_report_catcher;
    uvm_report_message expected;
    bit same = 0;
    function new(); super.new("mutator"); endfunction
    virtual function action_e catch();
      uvm_report_message current;
      current = get_report_message(); same = current == expected;
      current.set_severity(UVM_WARNING); current.set_id("alias");
      current.set_message("alias payload"); current.set_verbosity(UVM_HIGH);
      current.set_filename("alias.sv"); current.set_line(91);
      current.set_context("alias.ctx"); current.set_action(UVM_DISPLAY | UVM_COUNT);
      return THROW;
    endfunction
  endclass
  class observer extends uvm_report_catcher;
    int visits = 0;
    bit core = 0, location = 0, action = 0;
    function new(); super.new("observer"); endfunction
    virtual function action_e catch();
      visits++;
      core = get_severity() == UVM_WARNING && get_id() == "alias" &&
             get_message() == "alias payload" && get_verbosity() == UVM_HIGH;
      location = get_fname() == "alias.sv" && get_line() == 91 &&
                 get_context() == "alias.ctx";
      action = get_action() == (UVM_DISPLAY | UVM_COUNT);
      return CAUGHT;
    endfunction
  endclass
  initial begin
    automatic uvm_report_object reporter = new("reporter");
    automatic uvm_report_message msg = uvm_report_message::new_report_message("input");
    automatic mutator first = new();
    automatic observer tail = new();
    msg.set_report_message(UVM_INFO, "original", "payload", UVM_LOW,
                           "input.sv", 41, "input.ctx");
    first.expected = msg; reporter.set_report_verbosity_level(UVM_DEBUG);
    uvm_report_cb::add(reporter, first); uvm_report_cb::add(reporter, tail);
    reporter.uvm_process_report_message(msg);
    $display("UT: tail visits %0d same %0d core %0d location %0d action %0d",
             tail.visits, first.same, tail.core, tail.location, tail.action);
    $display("UT: caller core %0d location %0d action %0d",
             msg.get_severity() == UVM_WARNING && msg.get_id() == "alias" &&
             msg.get_message() == "alias payload" && msg.get_verbosity() == UVM_HIGH,
             msg.get_filename() == "alias.sv" && msg.get_line() == 91 &&
             msg.get_context() == "alias.ctx", msg.get_action() == (UVM_DISPLAY | UVM_COUNT));
    uvm_report_cb::delete(reporter, first); uvm_report_cb::delete(reporter, tail); $finish;
  end
endmodule
