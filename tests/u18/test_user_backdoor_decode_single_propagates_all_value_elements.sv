/*
:name: test_user_backdoor_decode_single_propagates_all_value_elements
:description: user backdoor decode single propagates all value elements (IEEE 1800.2-2020 Section 18.11.2.8)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.11.2.8 18.11.2.2 18.11.2.3 18.11.2.4 18.11.2.5 19.5.2.2 19.5.2.3 19.5.2.4 19.5.2.5 19.5.2.6 19.5.2.7 19.5.2.8 19.1.1.2.4 D.4.5.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_user_backdoor_decode_single_propagates_all_value_elements.expected
*/
// The standard requires callback transformations to reach the next callback
// and the actual value path. Two noncommuting operations and two memory-value
// elements distinguish order from value propagation. The library helpers
// perform
// the callback iteration; the test never repairs their arrays. Original
// storage
// is used without physical HDL. Write visibility/virtuality remains separate.
module test_user_backdoor_decode_single_propagates_all_value_elements;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  string trace = "";
  uvm_reg_item expected_item;
  bit identity_ok = 1, clear_ok = 1, chain_ok = 1, final_ok = 1;
  class memory_model extends uvm_mem;
    function new(); super.new("memory",4,8,"RW",UVM_NO_COVERAGE); endfunction
  endclass
  class first_codec extends uvm_reg_cbs;
    virtual task pre_write(uvm_reg_item rw);
      trace = {trace,"PA|"}; identity_ok &= rw == expected_item;
      clear_ok &= rw.get_value(0) == 'h13 && rw.get_value(1) == 'h25;
    endtask
    virtual task post_write(uvm_reg_item rw);
      trace = {trace,"QA|"}; identity_ok &= rw == expected_item;
    endtask
    virtual task pre_read(uvm_reg_item rw);
      trace = {trace,"PA|"}; identity_ok &= rw == expected_item;
    endtask
    virtual task post_read(uvm_reg_item rw);
      trace = {trace,"QA|"}; identity_ok &= rw == expected_item;
      final_ok &= rw.get_value(0) == 'h13 && rw.get_value(1) == 'h25;
    endtask
    virtual function void encode(ref uvm_reg_data_t data[]);
      trace = {trace,"EA|"}; chain_ok &= data.size() == 2;
      if (data.size() == 2) begin
        chain_ok &= data[0] == 'h13 && data[1] == 'h25;
        foreach (data[i]) data[i] ^= 'h1f;
      end
    endfunction
    virtual function void decode(ref uvm_reg_data_t data[]);
      trace = {trace,"DA|"}; chain_ok &= data.size() == 2;
      if (data.size() == 2) begin
        chain_ok &= data[0] == 'h0c && data[1] == 'h3a;
        foreach (data[i]) data[i] ^= 'h1f;
      end
    endfunction
  endclass
  class second_codec extends uvm_reg_cbs;
    virtual task pre_write(uvm_reg_item rw);
      trace = {trace,"PB|"}; identity_ok &= rw == expected_item;
      clear_ok &= rw.get_value(0) == 'h13 && rw.get_value(1) == 'h25;
    endtask
    virtual task post_write(uvm_reg_item rw);
      trace = {trace,"QB|"}; identity_ok &= rw == expected_item;
    endtask
    virtual task pre_read(uvm_reg_item rw);
      trace = {trace,"PB|"}; identity_ok &= rw == expected_item;
    endtask
    virtual task post_read(uvm_reg_item rw);
      trace = {trace,"QB|"}; identity_ok &= rw == expected_item;
      final_ok &= rw.get_value(0) == 'h13 && rw.get_value(1) == 'h25;
    endtask
    virtual function void encode(ref uvm_reg_data_t data[]);
      trace = {trace,"EB|"}; chain_ok &= data.size() == 2;
      if (data.size() == 2) begin
        chain_ok &= data[0] == 'h0c && data[1] == 'h3a;
        foreach (data[i]) data[i] += 1;
      end
    endfunction
    virtual function void decode(ref uvm_reg_data_t data[]);
      trace = {trace,"DB|"}; chain_ok &= data.size() == 2;
      if (data.size() == 2) begin
        chain_ok &= data[0] == 'h0d && data[1] == 'h3b;
        foreach (data[i]) data[i] -= 1;
      end
    endfunction
  endclass
  class storage_backdoor extends uvm_reg_backdoor;
    uvm_reg_data_t storage[];
    function new(); super.new("storage"); storage = new[2]; endfunction
    virtual task pre_write(uvm_reg_item rw);
      trace = {trace,"W|"}; identity_ok &= rw == expected_item;
    endtask
    virtual task post_write(uvm_reg_item rw);
      trace = {trace,"w|"}; identity_ok &= rw == expected_item;
    endtask
    virtual task pre_read(uvm_reg_item rw);
      trace = {trace,"R|"}; identity_ok &= rw == expected_item;
    endtask
    virtual task post_read(uvm_reg_item rw);
      trace = {trace,"r|"}; identity_ok &= rw == expected_item;
      final_ok &= rw.get_value(0) == 'h13 && rw.get_value(1) == 'h25;
    endtask
    virtual task write(uvm_reg_item rw);
      do_pre_write(rw);
      trace = {trace,"X|"}; identity_ok &= rw == expected_item;
      rw.get_value_array(storage); rw.set_status(UVM_IS_OK);
      do_post_write(rw);
    endtask
    virtual function void read_func(uvm_reg_item rw);
      trace = {trace,"X|"}; identity_ok &= rw == expected_item;
      rw.set_value_array(storage); rw.set_status(UVM_IS_OK);
    endfunction
  endclass
  initial begin
    automatic storage_backdoor subject = new();
    automatic first_codec first = new();
    automatic second_codec second = new();
    automatic uvm_reg_backdoor base_view = subject;
    automatic uvm_reg_item operation = new("operation");
    automatic memory_model memory = new();
    operation.set_element_kind(UVM_MEM); operation.set_element(memory);
    operation.set_value_size(2); operation.set_value('h13,0); operation.set_value('h25,1);
    operation.set_offset(0); operation.set_status(UVM_IS_OK); expected_item = operation;
    uvm_reg_bd_cb::add(subject,first);

    subject.storage[0] = 'h0c; subject.storage[1] = 'h3a;
    operation.set_kind(UVM_READ); base_view.read(operation);
    $display("UT: codec_trace %s", trace);
    $display("UT: codec_state identity %0d clear %0d chain %0d final %0d", identity_ok,
             clear_ok, chain_ok, final_ok);
    $display("UT: codec_result status %0d first %0h second %0h",
           operation.get_status() == UVM_IS_OK,
             operation.get_value(0),operation.get_value(1));
    $finish;
  end
endmodule
