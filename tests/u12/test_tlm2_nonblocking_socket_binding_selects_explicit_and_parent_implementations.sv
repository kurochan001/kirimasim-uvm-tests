/*
:name: test_tlm2_nonblocking_socket_binding_selects_explicit_and_parent_implementations
:description: tlm2 nonblocking socket implementation selection distinguishes explicit and parent hooks (IEEE 1800.2-2020 Section 12.3.5.4.3)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.5.4.3 12.3.5.3.3 12.3.5.4.4 12.3.5.3 12.3.5.4 12.3.2.2.1 12.3.2.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_nonblocking_socket_binding_selects_explicit_and_parent_implementations.expected
*/
// Two actual socket pairs select distinct explicit IMPs or omitted parent
// IMPs.
// Unused worker/parent hooks must remain uncalled; actual connect also wires
// the
// backward path. Original read-data algorithms identify selected forwarding,
// not prescribed target computation. Physical bus/all protocol rules stay
// open.
module test_tlm2_nonblocking_socket_binding_selects_explicit_and_parent_implementations;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class handler extends uvm_component;
    int delta = 10,forward_calls = 0,backward_calls = 0;
    uvm_tlm_generic_payload expected;
    uvm_tlm_time expected_delay;
    bit same_handles = 1;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function uvm_tlm_sync_e nb_transport_fw(uvm_tlm_generic_payload value,
                                           ref uvm_tlm_phase_e phase,input uvm_tlm_time delay);
      byte unsigned data_value[];
      forward_calls++; same_handles &= value == expected && delay == expected_delay;
      value.get_data(data_value); data_value[0] += delta;
      value.set_data(data_value); value.set_response_status(UVM_TLM_OK_RESPONSE);
      phase = BEGIN_RESP; delay.set_abstime(3.0,1.0e-9); return UVM_TLM_UPDATED;
    endfunction
    function uvm_tlm_sync_e nb_transport_bw(uvm_tlm_generic_payload value,
                                           ref uvm_tlm_phase_e phase,input uvm_tlm_time delay);
      backward_calls++; same_handles &= value == expected && delay == expected_delay;
      phase = END_RESP; delay.set_abstime(7.0,1.0e-9); return UVM_TLM_COMPLETED;
    endfunction
  endclass
  class initiator extends handler;
    handler implementation;
    uvm_tlm_nb_initiator_socket#(handler) socket;
    function new(string name,uvm_component parent,bit explicit_imp);
      super.new(name,parent); implementation = new("implementation",this);
      if (explicit_imp) socket = new("socket",this,implementation);
      else socket = new("socket",this);
    endfunction
  endclass
  class target extends handler;
    handler implementation;
    uvm_tlm_nb_target_socket#(handler) socket;
    function new(string name,uvm_component parent,bit explicit_imp);
      super.new(name,parent); implementation = new("implementation",this);
      implementation.delta = 100;
      if (explicit_imp) socket = new("socket",this,implementation);
      else socket = new("socket",this);
    endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    initiator explicit_caller,parent_caller;
    target explicit_target,parent_target;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      explicit_caller = new("explicit_caller",this,1); parent_caller = new("parent_caller",this,0);
      explicit_target = new("explicit_target",this,1); parent_target = new("parent_target",this,0);
    endfunction
    function void connect_phase(uvm_phase phase);
      explicit_caller.socket.connect(explicit_target.socket);
      parent_caller.socket.connect(parent_target.socket);
    endfunction
    task invoke(initiator caller,target callee,bit explicit_imp,int initial_value);
      uvm_tlm_generic_payload value = new("value");
      uvm_tlm_time delay = new("delay",1.0e-12);
      byte unsigned data_value[];
      uvm_tlm_phase_e phase_value;
      uvm_tlm_sync_e forward_result,backward_result;
      handler fw,bw;
      time before_time;
      real annotation;
      string label;
      if (explicit_imp) label = "explicit"; else label = "parent";
      if (explicit_imp) begin fw = callee.implementation; bw = caller.implementation; end
      else begin fw = callee; bw = caller; end
      fw.expected = value; bw.expected = value; fw.expected_delay = delay;
      bw.expected_delay = delay;
      data_value = new[1]; data_value[0] = initial_value;
      value.set_read(); value.set_data_length(1); value.set_data(data_value);
      before_time = $time; phase_value = BEGIN_REQ;
      forward_result = caller.socket.nb_transport_fw(value,phase_value,delay);
      phase_value = BEGIN_RESP;
      backward_result = callee.socket.nb_transport_bw(value,phase_value,delay);
      value.get_data(data_value); annotation = delay.get_abstime(1.0e-9);
      $display("UT: socket_binding %s forward %0d backward %0d phase %0d data %0d immediate %0d",
               label,forward_result == UVM_TLM_UPDATED,
               backward_result == UVM_TLM_COMPLETED,phase_value == END_RESP,data_value[0],
               $time == before_time);
      $display("UT: socket_binding %s counts %0d/%0d/%0d/%0d handles %0d delay %0d",
               label,callee.implementation.forward_calls,
               callee.forward_calls,caller.implementation.backward_calls,caller.backward_calls,
               fw.same_handles && bw.same_handles,annotation > 6.999999 && annotation < 7.000001);
    endtask
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      invoke(explicit_caller,explicit_target,1,13); invoke(parent_caller,parent_target,0,35);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #60; $fatal(1,"socket selection watchdog expired"); end
endmodule
