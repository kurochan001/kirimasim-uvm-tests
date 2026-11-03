/*
:name: test_user_backdoor_task_read_failure_uses_first_and_last_protected_helpers
:description: user backdoor task read failure uses first and last protected helpers (IEEE 1800.2-2020 Section 19.5.2.3)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.5.2.3 19.5.2.7 19.5.2.2 19.5.2.9 19.5.2.10 D.4.5.3 18.11.2.4 18.11.2.5 19.1.1.2.4 19.1.1.2.5 19.1.1.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_user_backdoor_task_read_failure_uses_first_and_last_protected_helpers.expected
*/
// Override the task-based read with the protected pre helper as its first
// statement
// and the post helper as its last. A positive delay requires task execution.
// Original storage and transformations isolate descriptor/status and hook
// order.
// No failed-read data, physical HDL or encode/decode-array claim is made.
module test_user_backdoor_task_read_failure_uses_first_and_last_protected_helpers;
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
  class task_backdoor extends uvm_reg_backdoor;
    uvm_reg_data_t storage[uvm_reg_addr_t];
    uvm_status_e response = UVM_IS_OK;
    int reads = 0;
    function new(); super.new("subject"); endfunction
    virtual task pre_read(uvm_reg_item rw);
      trace = {trace,"R"}; identity_ok &= rw == expected_item; rw.set_offset(1);
    endtask
    virtual task read(uvm_reg_item rw);
      do_pre_read(rw);
      trace = {trace,"T"}; reads++; identity_ok &= rw == expected_item;
      #2;
      body_offset_ok &= rw.get_offset() == expected_offset;
      if (response == UVM_IS_OK) rw.set_value(storage[rw.get_offset()]);
      rw.set_status(response);
      do_post_read(rw);
    endtask
    virtual task post_read(uvm_reg_item rw);
      trace = {trace,"r"}; identity_ok &= rw == expected_item;
      if (rw.get_status() == UVM_IS_OK) post_order_ok &= rw.get_value(0) == expected_value;
    endtask
  endclass

  initial begin
    automatic task_backdoor subject = new();
    automatic callback_probe callback_value = new();
    automatic uvm_reg_item operation = new("read");
    automatic memory_model memory = new();
    automatic uvm_reg_backdoor base_view = subject;
    automatic time started;
    operation.set_element_kind(UVM_MEM); operation.set_element(memory);
    operation.set_kind(UVM_READ); operation.set_offset(0); operation.set_value('ha5);
    expected_item = operation; expected_value = 'hb5; expected_offset = 2;
    subject.storage[1] = 'h24; subject.storage[2] = 'h35;
    uvm_reg_bd_cb::add(subject, callback_value);
    subject.response = UVM_NOT_OK;
    started = $time;
    base_view.read(operation);
    $display("UT: task_read_delay %0d", $time - started == 2);
    $display("UT: read_trace %s identity %0d pre %0d body %0d post %0d", trace, identity_ok,
             pre_order_ok, body_offset_ok, post_order_ok);
    $display("UT: read_failure status %0d reads %0d callbacks %0d %0d",
             operation.get_status() == UVM_NOT_OK, subject.reads,
             callback_value.pre_calls, callback_value.post_calls);

    $finish;
  end
endmodule
