/*
:name: test_nested_nonblocking_transport_exports_forward_status_handles_failure_and_reuse
:description: nested nonblocking exports preserve custom types, returned status and repeated invocation (12.2.6.2)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.6.2 12.2.7.2.1 12.2.4.2.11 5.5.2.14 5.5.2.15 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_nested_nonblocking_transport_exports_forward_status_handles_failure_and_reuse.expected
*/
module test_nested_nonblocking_transport_exports_forward_status_handles_failure_and_reuse;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class request extends uvm_object;
    int number;
    function new(int value); super.new("request"); number = value; endfunction
  endclass
  class response extends uvm_object;
    string text;
    function new(string value); super.new("response"); text = value; endfunction
  endclass
  class endpoint extends uvm_component;
    uvm_nonblocking_transport_imp#(request, response, endpoint) imp;
    uvm_nonblocking_transport_export#(request, response) relay;
    request seen;
    response reply;
    bit enabled = 1;
    int calls = 0;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      imp = new("imp", this);
      relay = new("relay", this);
    endfunction
    function void connect_phase(uvm_phase phase); relay.connect(imp); endfunction
    function bit nb_transport(input request req, output response rsp);
      calls++;
      seen = req;
      if (!enabled) return 0;
      rsp = reply;
      return 1;
    endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    endpoint target;
    uvm_nonblocking_transport_export#(request, response) outer;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      target = new("target", this);
      outer = new("outer", this);
    endfunction
    function void connect_phase(uvm_phase phase); outer.connect(target.relay); endfunction
    task run_phase(uvm_phase phase);
      request first = new(11);
      request second = new(22);
      response reply_one = new("first");
      response reply_two = new("second");
      response got_one, got_two, failed_output;
      bit ok;
      target.reply = reply_one;
      ok = outer.nb_transport(first, got_one);
      $display("UT: first success %0d request %0d response %0d value %0d calls %0d",
               ok, target.seen == first, got_one == reply_one,
               got_one.text == "first", target.calls);
      target.reply = reply_two;
      ok = outer.nb_transport(second, got_two);
      $display("UT: second success %0d request %0d response %0d first_retained %0d calls %0d",
               ok, target.seen == second, got_two == reply_two,
               got_one == reply_one && got_one.text == "first", target.calls);
      target.enabled = 0;
      ok = outer.nb_transport(first, failed_output);
      $display("UT: failure propagated %0d calls %0d", !ok, target.calls);
      target.enabled = 1;
      ok = outer.nb_transport(second, got_two);
      $display("UT: reused success %0d response %0d calls %0d",
               ok, got_two == reply_two, target.calls);
    endtask
  endclass
  initial run_test("t");
endmodule
