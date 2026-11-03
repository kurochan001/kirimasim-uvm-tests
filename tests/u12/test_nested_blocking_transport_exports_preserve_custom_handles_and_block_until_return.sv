/*
:name: test_nested_blocking_transport_exports_preserve_custom_handles_and_block_until_return
:description: nested bidirectional exports route custom request/response handles and blocking completion (12.2.6.2)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.6.2 12.2.7.2.1 12.2.4.2.10 5.5.2.14 5.5.2.15 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_nested_blocking_transport_exports_preserve_custom_handles_and_block_until_return.expected
*/
module test_nested_blocking_transport_exports_preserve_custom_handles_and_block_until_return;
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
    uvm_blocking_transport_imp#(request, response, endpoint) imp;
    uvm_blocking_transport_export#(request, response) relay;
    request seen;
    response reply;
    int calls = 0;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      imp = new("imp", this);
      relay = new("relay", this);
      reply = new("ready");
    endfunction
    function void connect_phase(uvm_phase phase); relay.connect(imp); endfunction
    task transport(input request req, output response rsp);
      calls++;
      seen = req;
      #3;
      rsp = reply;
    endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    endpoint target;
    uvm_blocking_transport_export#(request, response) outer;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      target = new("target", this);
      outer = new("outer", this);
    endfunction
    function void connect_phase(uvm_phase phase); outer.connect(target.relay); endfunction
    task run_phase(uvm_phase phase);
      request req = new(41);
      response rsp;
      bit returned = 0;
      phase.raise_objection(this);
      fork
        begin outer.transport(req, rsp); returned = 1; end
        begin
          #1;
          $display("UT: blocked %0d calls %0d", !returned, target.calls);
        end
      join
      $display("UT: returned %0d request %0d number %0d response %0d text %0d calls %0d",
               returned, target.seen == req, target.seen.number, rsp == target.reply,
               rsp.text == "ready", target.calls);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1, "blocking transport watchdog expired"); end
endmodule
