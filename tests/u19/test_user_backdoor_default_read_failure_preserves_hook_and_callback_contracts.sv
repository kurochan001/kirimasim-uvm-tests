/*
:name: test_user_backdoor_default_read_failure_preserves_hook_and_callback_contracts
:description: user backdoor default read failure preserves hook and callback contracts (IEEE 1800.2-2020 Section 19.5.2.7)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.5.2.7 19.5.2.2 19.5.2.3 19.5.2.8 19.5.2.9 19.5.2.10 D.4.5.3 18.11.2.4 18.11.2.5 19.1.1.2.4 19.1.1.2.5 19.1.1.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_user_backdoor_default_read_failure_preserves_hook_and_callback_contracts.expected
*/
// What it checks:
// 1. The default backdoor read delegates its peek step to the virtual
//    read_func extension.
// 2. A function-based backdoor supplies the current value and operation status
//    through its descriptor.
// 3. The user pre-read hook precedes registered callbacks and the backdoor
//    peek.
// 4. Registered post-read callbacks precede the user post-read hook after the
//    peek.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 19.5.2.7 (UVM-REG-INTERACTION-DEFAULT-READ-FUNCTION-DISPATCH)
//    gives rule 1 above. Setup: Invoke the inherited read task through a base
//    handle with success, failure and callback lifecycle cases. Expected: The
//    same supplied descriptor reaches the original function once per read and
//    retains its selected success or failure result.
// 2. 1800.2-2020 19.5.2.8 (UVM-REG-INTERACTION-READ-FUNCTION-RESULT) gives
//    rule 2 above. Setup: The default read invokes an original function using
//    the offset selected by pre processing. Expected: Success returns the
//    selected stored value after the original callback transform; failure
//    returns NOT_OK without constraining data.
// 3. 1800.2-2020 19.5.2.9 (UVM-REG-INTERACTION-READ-PRE-HOOK-ORDER) gives rule
//    3 above. Setup: An original hook sets offset one and a callback verifies
//    it before changing it to two. Expected: Trace RCFcr and the body-offset
//    check show hook, callback and function ordering with the same descriptor.
// 4. 1800.2-2020 19.5.2.10 (UVM-REG-INTERACTION-READ-POST-HOOK-ORDER) gives
//    rule 4 above. Setup: The post callback modifies successful data before
//    the original post hook inspects it. Expected: Trace and the post-value
//    check show the callback change at the final hook.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The library default read task wraps an original read_func implementation.
// Trace only original hooks/callbacks and compare the exact supplied
// descriptor.
// Original storage and value/offset transformations define the fixture; this
// asserts neither physical HDL nor encode/decode-array transformation
// behavior.
// Failed-read data is not constrained.
module test_user_backdoor_default_read_failure_preserves_hook_and_callback_contracts;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  string trace = "";
  uvm_reg_item expected_item;
  uvm_reg_data_t expected_value;
  uvm_reg_addr_t expected_offset;
  bit identity_ok = 1, pre_order_ok = 1, post_order_ok = 1, body_offset_ok = 1;
  class memory_model extends uvm_mem;
    function new(); super.new("memory", 4, 8, "RW", UVM_NO_COVERAGE); endfunction
  endclass
  class callback_probe extends uvm_reg_cbs;
    int pre_calls = 0, post_calls = 0;
    virtual task pre_read(uvm_reg_item rw);
      trace = {trace,"C"}; pre_calls++;
      identity_ok &= rw == expected_item; pre_order_ok &= rw.get_offset() == 1;
      rw.set_offset(2);
    endtask
    virtual task post_read(uvm_reg_item rw);
      trace = {trace,"c"}; post_calls++;
      identity_ok &= rw == expected_item;
      if (rw.get_status() == UVM_IS_OK) rw.set_value(rw.get_value(0) ^ 'h80);
    endtask
  endclass
  class function_backdoor extends uvm_reg_backdoor;
    uvm_reg_data_t storage[uvm_reg_addr_t];
    uvm_status_e response = UVM_IS_OK;
    int reads = 0;
    function new(); super.new("subject"); endfunction
    virtual task pre_read(uvm_reg_item rw);
      trace = {trace,"R"}; identity_ok &= rw == expected_item; rw.set_offset(1);
    endtask
    virtual function void read_func(uvm_reg_item rw);
      trace = {trace,"F"}; reads++; identity_ok &= rw == expected_item;
      body_offset_ok &= rw.get_offset() == expected_offset;
      if (response == UVM_IS_OK) rw.set_value(storage[rw.get_offset()]);
      rw.set_status(response);
    endfunction
    virtual task post_read(uvm_reg_item rw);
      trace = {trace,"r"}; identity_ok &= rw == expected_item;
      if (rw.get_status() == UVM_IS_OK) post_order_ok &= rw.get_value(0) == expected_value;
    endtask
  endclass

  initial begin
    automatic function_backdoor subject = new();
    automatic callback_probe callback_value = new();
    automatic uvm_reg_item operation = new("read");
    automatic memory_model memory = new();
    automatic uvm_reg_backdoor base_view = subject;
    operation.set_element_kind(UVM_MEM); operation.set_element(memory);
    operation.set_kind(UVM_READ); operation.set_offset(0); operation.set_value('ha5);
    expected_item = operation; expected_value = 'hb5; expected_offset = 2;
    subject.storage[1] = 'h24; subject.storage[2] = 'h35;
    uvm_reg_bd_cb::add(subject, callback_value);
    subject.response = UVM_NOT_OK;
    base_view.read(operation);
    $display("UT: read_trace %s identity %0d pre %0d body %0d post %0d", trace, identity_ok,
             pre_order_ok, body_offset_ok, post_order_ok);
    $display("UT: read_failure status %0d reads %0d callbacks %0d %0d",
             operation.get_status() == UVM_NOT_OK, subject.reads,
             callback_value.pre_calls, callback_value.post_calls);

    $finish;
  end
endmodule
