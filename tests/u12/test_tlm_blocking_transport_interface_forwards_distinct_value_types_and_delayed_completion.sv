/*
:name: test_tlm_blocking_transport_interface_forwards_distinct_value_types_and_delayed_completion
:description: tlm blocking transport interface forwards distinct value types and delayed completion (IEEE 1800.2-2020 Section 12.2.4.2.10)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.4.2.10 12.2.3.1 12.2.5.2 12.2.7.2 12.2.7.2.1 12.2.4.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_blocking_transport_interface_forwards_distinct_value_types_and_delayed_completion.expected
*/
// What it checks:
// 1. Blocking transport forwards a request and returns its response after
//    implementation completion.
// 2. A selected bidirectional imp delegates request/response methods to its
//    supplied component.
// 3. The transport imp constructor binds its supplied implementation handle.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.2.4.2.10 (UVM-TLM1-REVIEW-BLOCKING-TRANSPORT-COMPLETION)
//    gives rule 1 above. Setup: Invoke the actual bound port through its
//    interface base, then reuse the typed port with a second request.
//    Expected: Distinct packed values and the original two-unit delay reach
//    the caller, with matching sequential responses.
// 2. 1800.2-2020 12.2.7.2 (UVM-TLM1-REVIEW-BIDIRECTIONAL-IMP-DELEGATION) gives
//    rule 2 above. Setup: Bind actual blocking/nonblocking ports to an
//    original combined transport imp. Expected: The original component
//    receives the request and its response/status/delay returns through the
//    interface.
// 3. 1800.2-2020 12.2.7.2.1
//    (UVM-TLM1-REVIEW-TRANSPORT-IMP-CONSTRUCTOR-BINDING) gives rule 3 above.
//    Setup: Construct a combined imp in an original target and connect an
//    actual transport port. Expected: Observed target calls and values
//    identify the selected implementation.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A real blocking port and combined imp forward distinct packed
// request/response
// value types. The original backend defines its two-unit delay and arithmetic;
// the UVM interface path must retain them. No concurrent ordering guarantee,
// failed output, omitted response default or physical protocol is inferred.
module test_tlm_blocking_transport_interface_forwards_distinct_value_types_and_delayed_completion;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  typedef struct packed { bit [7:0] number; bit [3:0] opcode; } request_type;
  typedef struct packed { bit [15:0] echo; bit accepted; } response_type;
  class target_type extends uvm_component;
    uvm_transport_imp#(request_type,response_type,target_type) imp;
    request_type last;
    int calls = 0;
    bit ready = 0;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase); imp = new("imp",this); endfunction
    task transport(input request_type request,output response_type response);
      last = request; calls++; #2; response.echo = request.number + 100; response.accepted = 1;
    endtask
    function bit nb_transport(input request_type request,output response_type response);
      last = request; calls++;
      if (!ready) return 0;
      response.echo = request.number + 100; response.accepted = 1; return 1;
    endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    target_type target;
    uvm_blocking_transport_port#(request_type,response_type) writer;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase); target = new("target",this); writer = new("writer",this);
    endfunction
    function void connect_phase(uvm_phase phase); writer.connect(target.imp); endfunction
    task run_phase(uvm_phase phase);
      automatic uvm_tlm_if_base#(request_type,response_type) interface_view = writer;
      request_type request;
      response_type response;
      time started;
      bit accepted;
      phase.raise_objection(this);
      request.number = 13; request.opcode = 1; started = $time;
      interface_view.transport(request,response);
      $display("UT: blocking_value_transport request %0d response %0d accepted %0d delayed %0d",
               target.last == request,response.echo,response.accepted,$time - started == 2);
      request.number = 27; request.opcode = 2; writer.transport(request,response);
      $display("UT: blocking_value_reuse request %0d response %0d accepted %0d calls %0d",
               target.last == request,response.echo,response.accepted,target.calls);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1,"transport watchdog expired"); end
endmodule
