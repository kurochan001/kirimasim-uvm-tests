/*
:name: test_tlm_nonblocking_transport_interface_forwards_failure_success_and_distinct_value_types
:description: tlm nonblocking transport interface forwards failure success and distinct value types (IEEE 1800.2-2020 Section 12.2.4.2.11)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.4.2.11 12.2.3.1 12.2.5.2 12.2.7.2 12.2.7.2.1 12.2.4.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_nonblocking_transport_interface_forwards_failure_success_and_distinct_value_types.expected
*/
// A real nonblocking port and combined imp forward explicit distinct request/
// response types and original availability/status. Failure data is not
// inspected.
// No failed-output preservation, default response parameter, physical protocol
// or arbitrary concurrent interface arbitration is inferred.
module test_tlm_nonblocking_transport_interface_forwards_failure_success_and_distinct_value_types;
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
    uvm_nonblocking_transport_port#(request_type,response_type) writer;
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
      accepted = interface_view.nb_transport(request,response);
      $display("UT: nonblocking_value_refused accepted %0d immediate %0d request %0d",
               accepted,$time == started,target.last == request);
      target.ready = 1; request.number = 27; request.opcode = 2; started = $time;
      accepted = writer.nb_transport(request,response);
      $display("UT: nonblocking_value_accepted accepted %0d immediate %0d response %0d calls %0d",
               accepted && response.accepted,$time == started,response.echo,target.calls);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1,"transport watchdog expired"); end
endmodule
