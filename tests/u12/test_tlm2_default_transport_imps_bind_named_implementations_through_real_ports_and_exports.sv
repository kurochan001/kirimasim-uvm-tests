/*
:name: test_tlm2_default_transport_imps_bind_named_implementations_through_real_ports_and_exports
:description: tlm2 default transport imps bind named implementations through real ports and exports (IEEE 1800.2-2020 Section 12.3.8)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.8 12.3.8.1 12.3.8.2 12.3.8.3 12.3.6.1 12.3.6.2 12.3.6.3 12.3.7.1 12.3.7.2 12.3.7.3 12.3.2.2.1 12.3.2.2.2 12.3.2.2.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_default_transport_imps_bind_named_implementations_through_real_ports_and_exports.expected
*/
// What it checks:
// 1. The blocking imp defaults its transaction type to generic payload when
//    only IMP is selected.
// 2. The blocking imp delegates its selected transport method to the supplied
//    implementation.
// 3. The forward imp defaults its transaction type to generic payload when
//    only IMP is selected.
// 4. The forward imp defaults its phase type to uvm_tlm_phase_e.
// 5. The forward imp delegates its selected transport method to the supplied
//    implementation.
// 6. The backward imp defaults its transaction type to generic payload when
//    only IMP is selected.
// 7. The backward imp defaults its phase type to uvm_tlm_phase_e.
// 8. The backward imp delegates its selected transport method to the supplied
//    implementation.
// 9. The imp constructor installs the supplied implementation object.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.3.8.1 (UVM-TLM2-TYPES-IMP-1-DEFAULT-T) gives rule 1 above.
//    Setup: Bind real default ports through actual exports to three imps with
//    only IMP explicitly named; call blocking, forward and backward
//    transports. Expected: The exact generic-payload base accepts the imp and
//    real typed forwarding reaches the implementation.
// 2. 1800.2-2020 12.3.8.1 (UVM-TLM2-TYPES-IMP-1-DELEGATION) gives rule 2
//    above. Setup: Bind real default ports through actual exports to three
//    imps with only IMP explicitly named; call blocking, forward and backward
//    transports. Expected: The original implementation receives matching
//    handles and returns its selected completion/status/data/annotation.
// 3. 1800.2-2020 12.3.8.2 (UVM-TLM2-TYPES-IMP-2-DEFAULT-T) gives rule 3 above.
//    Setup: Bind real default ports through actual exports to three imps with
//    only IMP explicitly named; call blocking, forward and backward
//    transports. Expected: The exact generic-payload base accepts the imp and
//    real typed forwarding reaches the implementation.
// 4. 1800.2-2020 12.3.8.2 (UVM-TLM2-TYPES-IMP-2-DEFAULT-P) gives rule 4 above.
//    Setup: Bind real default ports through actual exports to three imps with
//    only IMP explicitly named; call blocking, forward and backward
//    transports. Expected: The exact phase type compiles and its selected
//    reference update returns through the bound interface.
// 5. 1800.2-2020 12.3.8.2 (UVM-TLM2-TYPES-IMP-2-DELEGATION) gives rule 5
//    above. Setup: Bind real default ports through actual exports to three
//    imps with only IMP explicitly named; call blocking, forward and backward
//    transports. Expected: The original implementation receives matching
//    handles and returns its selected completion/status/data/annotation.
// 6. 1800.2-2020 12.3.8.3 (UVM-TLM2-TYPES-IMP-3-DEFAULT-T) gives rule 6 above.
//    Setup: Bind real default ports through actual exports to three imps with
//    only IMP explicitly named; call blocking, forward and backward
//    transports. Expected: The exact generic-payload base accepts the imp and
//    real typed forwarding reaches the implementation.
// 7. 1800.2-2020 12.3.8.3 (UVM-TLM2-TYPES-IMP-3-DEFAULT-P) gives rule 7 above.
//    Setup: Bind real default ports through actual exports to three imps with
//    only IMP explicitly named; call blocking, forward and backward
//    transports. Expected: The exact phase type compiles and its selected
//    reference update returns through the bound interface.
// 8. 1800.2-2020 12.3.8.3 (UVM-TLM2-TYPES-IMP-3-DELEGATION) gives rule 8
//    above. Setup: Bind real default ports through actual exports to three
//    imps with only IMP explicitly named; call blocking, forward and backward
//    transports. Expected: The original implementation receives matching
//    handles and returns its selected completion/status/data/annotation.
// 9. 1800.2-2020 12.3.8 (UVM-TLM2-TYPES-IMP-CONSTRUCTOR-BINDING) gives rule 9
//    above. Setup: Bind real default ports through actual exports to three
//    imps with only IMP explicitly named; call blocking, forward and backward
//    transports. Expected: All three actual ports/exports reach their selected
//    bound original implementation.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Actual default ports/exports bind imps whose IMP alone is explicitly named.
// Original read data/status/delay implementations identify delegation and
// completion; their algorithms are setup. The forward port is invoked through
// nb_transport_fw; its apparent backward-path prose remains unresolved.
// No complete base protocol, physical bus or nominal IMP=int is certified.
module test_tlm2_default_transport_imps_bind_named_implementations_through_real_ports_and_exports;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class worker extends uvm_component;
    uvm_tlm_b_transport_imp#(.IMP(worker)) blocking_imp;
    uvm_tlm_nb_transport_fw_imp#(.IMP(worker)) forward_imp;
    uvm_tlm_nb_transport_bw_imp#(.IMP(worker)) backward_imp;
    int blocking_calls = 0,forward_calls = 0,backward_calls = 0;
    uvm_tlm_generic_payload expected;
    uvm_tlm_time expected_delay;
    bit same_handles = 1;
    function new(string name,uvm_component parent);
      super.new(name,parent);
      blocking_imp = new("blocking_imp",this); forward_imp = new("forward_imp",this);
      backward_imp = new("backward_imp",this);
    endfunction
    task b_transport(uvm_tlm_generic_payload value,uvm_tlm_time delay);
      byte unsigned data_value[];
      blocking_calls++; same_handles &= value == expected && delay == expected_delay;
      #2; data_value = new[1]; data_value[0] = 21;
      value.set_data(data_value); value.set_response_status(UVM_TLM_OK_RESPONSE);
      delay.set_abstime(3.0,1.0e-9);
    endtask
    function uvm_tlm_sync_e nb_transport_fw(uvm_tlm_generic_payload value,
                                           ref uvm_tlm_phase_e phase,input uvm_tlm_time delay);
      byte unsigned data_value[];
      forward_calls++; same_handles &= value == expected && delay == expected_delay;
      data_value = new[1]; data_value[0] = 47; value.set_data(data_value);
      value.set_response_status(UVM_TLM_OK_RESPONSE); phase = BEGIN_RESP;
      delay.set_abstime(5.0,1.0e-9); return UVM_TLM_UPDATED;
    endfunction
    function uvm_tlm_sync_e nb_transport_bw(uvm_tlm_generic_payload value,
                                           ref uvm_tlm_phase_e phase,input uvm_tlm_time delay);
      backward_calls++; same_handles &= value == expected && delay == expected_delay;
      phase = END_RESP; delay.set_abstime(7.0,1.0e-9); return UVM_TLM_COMPLETED;
    endfunction
  endclass
  class relay extends uvm_component;
    uvm_tlm_b_transport_export#() blocking_export;
    uvm_tlm_nb_transport_fw_export#() forward_export;
    uvm_tlm_nb_transport_bw_export#() backward_export;
    worker implementation;
    function new(string name,uvm_component parent);
      super.new(name,parent);
      blocking_export = new("blocking_export",this); forward_export = new("forward_export",this);
      backward_export = new("backward_export",this); implementation = new("implementation",this);
    endfunction
    function void connect_phase(uvm_phase phase);
      blocking_export.connect(implementation.blocking_imp);
      forward_export.connect(implementation.forward_imp);
      backward_export.connect(implementation.backward_imp);
    endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_tlm_b_transport_port#() blocking_port;
    uvm_tlm_nb_transport_fw_port#() forward_port;
    uvm_tlm_nb_transport_bw_port#() backward_port;
    relay shell;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      blocking_port = new("blocking_port",this); forward_port = new("forward_port",this);
      backward_port = new("backward_port",this); shell = new("shell",this);
    endfunction
    function void connect_phase(uvm_phase phase);
      blocking_port.connect(shell.blocking_export); forward_port.connect(shell.forward_export);
      backward_port.connect(shell.backward_export);
    endfunction
    task run_phase(uvm_phase phase);
      uvm_tlm_generic_payload value = new("value");
      uvm_tlm_time delay = new("delay",1.0e-12);
      uvm_tlm_phase_e transport_phase;
      uvm_tlm_sync_e result;
      uvm_port_base#(uvm_tlm_if#(uvm_tlm_generic_payload,uvm_tlm_phase_e)) exact;
      byte unsigned data_value[];
      time before_time;
      real annotation;
      bit types;
      phase.raise_objection(this);
      exact = shell.implementation.blocking_imp; types = exact != null;
      exact = shell.implementation.forward_imp; types &= exact != null;
      exact = shell.implementation.backward_imp; types &= exact != null;
      value.set_read(); value.set_data_length(1); data_value = new[1]; value.set_data(data_value);
      shell.implementation.expected = value; shell.implementation.expected_delay = delay;
      before_time = $time; blocking_port.b_transport(value,delay); value.get_data(data_value);
      annotation = delay.get_abstime(1.0e-9);
      $display("UT: imp_b types %0d calls %0d data %0d ok %0d delayed %0d delay %0d",
               types,shell.implementation.blocking_calls,data_value[0],value.is_response_ok(),
               $time == before_time + 2,annotation > 2.999999 && annotation < 3.000001);
      before_time = $time; transport_phase = BEGIN_REQ;
      result = forward_port.nb_transport_fw(value,transport_phase,delay); value.get_data(
      data_value);
      annotation = delay.get_abstime(1.0e-9);
      $display("UT: imp_fw updated %0d phase %0d data %0d calls %0d delay %0d immediate %0d",
               result == UVM_TLM_UPDATED,transport_phase == BEGIN_RESP,data_value[0],
               shell.implementation.forward_calls,annotation > 4.999999 && annotation < 5.000001,
               $time == before_time);
      transport_phase = BEGIN_RESP;
      result = backward_port.nb_transport_bw(value,transport_phase,delay);
      annotation = delay.get_abstime(1.0e-9);
      $display("UT: imp_bw completed %0d phase %0d calls %0d same %0d delay %0d immediate %0d",
               result == UVM_TLM_COMPLETED,transport_phase == END_RESP,
               shell.implementation.backward_calls,shell.implementation.same_handles,
               annotation > 6.999999 && annotation < 7.000001,$time == before_time);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #60; $fatal(1,"default imp watchdog expired"); end
endmodule
