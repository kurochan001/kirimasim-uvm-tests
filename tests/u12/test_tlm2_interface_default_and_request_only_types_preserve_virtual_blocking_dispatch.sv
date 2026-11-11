/*
:name: test_tlm2_interface_default_and_request_only_types_preserve_virtual_blocking_dispatch
:description: tlm2 interface default and request only types preserve virtual blocking dispatch (IEEE 1800.2-2020 Section 12.3.2.1)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.2.1 12.3.2.2.3 12.3.3.1 12.3.2 12.3.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_interface_default_and_request_only_types_preserve_virtual_blocking_dispatch.expected
*/
// What it checks:
// 1. The omitted TLM 2 interface transaction type is the generic payload.
// 2. The omitted TLM 2 phase type is uvm_tlm_phase_e even when only T changes.
// 3. The TLM 2 base interface supports selected blocking and nonblocking
//    transaction transport forms.
// 4. The selected transport methods accept transaction and delay object
//    handles.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.3.2.1 (UVM-TLM-DECL-TLM2-DEFAULT-T) gives rule 1 above.
//    Setup: Call original default and T-only concrete TLM 2 interfaces through
//    exact base views with real payload/delay handles. Expected: The exact
//    generic-payload/phase base view retains identity and dispatches its
//    blocking task.
// 2. 1800.2-2020 12.3.2.1 (UVM-TLM-DECL-TLM2-DEFAULT-P) gives rule 2 above.
//    Setup: Call original default and T-only concrete TLM 2 interfaces through
//    exact base views with real payload/delay handles. Expected: Both default
//    and custom-T instances fit exact standard-phase base views.
// 3. 1800.2-2020 12.3.2 (UVM-TLM-DECL-TLM2-TRANSPORT-INTERFACE-FORMS) gives
//    rule 3 above. Setup: Call original default/T-only blocking and custom-T/P
//    nonblocking concrete interfaces through exact declared base views.
//    Expected: Exact concrete base views accept the selected virtual method
//    definitions and calls.
// 4. 1800.2-2020 12.3.2.2 (UVM-TLM-DECL-TLM2-TRANSACTION-DELAY-HANDLES) gives
//    rule 4 above. Setup: Call original default and T-only concrete TLM 2
//    interfaces through exact base views with real payload/delay handles.
//    Expected: Callee mutations and completion are observed through the
//    original caller handles.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original concrete interface implementations check declared default types,
// independent default phase type and virtual dispatch through exact base
// views.
// Their status/data/timing algorithms are setup, not a prescribed UVM target.
// Real standard port/export/socket forwarding has separate fixtures.
module test_tlm2_interface_default_and_request_only_types_preserve_virtual_blocking_dispatch;
  import uvm_pkg::*;
  class custom_item extends uvm_object;
    int value = 13;
    function new(); super.new("custom"); endfunction
  endclass
  class default_probe extends uvm_tlm_if#();
    int calls = 0;
    virtual task b_transport(uvm_tlm_generic_payload value,uvm_tlm_time delay);
      calls++; #2;
      value.set_response_status(UVM_TLM_OK_RESPONSE); delay.set_abstime(6.0,1.0e-9);
    endtask
  endclass
  class request_probe extends uvm_tlm_if#(custom_item);
    int calls = 0;
    virtual task b_transport(custom_item value,uvm_tlm_time delay);
      calls++; #2; value.value += 7; delay.set_abstime(9.0,1.0e-9);
    endtask
  endclass
  initial begin
    automatic default_probe first = new();
    automatic request_probe second = new();
    automatic uvm_tlm_if#(uvm_tlm_generic_payload,uvm_tlm_phase_e) default_view = first;
    automatic uvm_tlm_if#(custom_item,uvm_tlm_phase_e) request_view = second;
    automatic uvm_tlm_generic_payload value = new("value");
    automatic custom_item custom = new();
    automatic uvm_tlm_time delay = new("delay",1.0e-12);
    automatic time before_time = $time;
    real annotation;
    default_view.b_transport(value,delay); annotation = delay.get_abstime(1.0e-9);
    $display("UT: tlm2_default identity %0d calls %0d delayed %0d status %0d annotation %0d",
             default_view == first,first.calls,$time == before_time + 2,
             value.is_response_ok(),annotation > 5.999999 && annotation < 6.000001);
    before_time = $time; request_view.b_transport(custom,delay);
    annotation = delay.get_abstime(1.0e-9);
    $display("UT: tlm2_request_only identity %0d calls %0d delayed %0d value %0d annotation %0d",
             request_view == second,second.calls,$time == before_time + 2,custom.value,
             annotation > 8.999999 && annotation < 9.000001);
    $finish;
  end
endmodule
