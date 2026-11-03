/*
:name: test_reg_tlm_adapter_fresh_objects_preserve_conversion_contracts
:description: standard TLM adapter conversions preserve selected identity and operation fields (IEEE 1800.2-2020 Section 19.2.2.2.1)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.2.2.2.1 19.2.2.2.2 19.2.1.2.5 19.2.1.2.6 19.1.2.1 19.1.2.2 19.1.2.3 19.1.2.4 19.1.2.5 19.1.2.6 12.3.4.2.15 12.3.4.2.38 12.3.4.2.39 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_tlm_adapter_fresh_objects_preserve_conversion_contracts.expected
*/
// Uniform data/enable bytes avoid imposing numeric byte ordering.
// Failed-read data and unused upper data/mask bits are not constrained.
module test_reg_tlm_adapter_fresh_objects_preserve_conversion_contracts;
  import uvm_pkg::*;
  initial begin

    uvm_reg_tlm_adapter adapter;
    uvm_reg_bus_op rw;
    uvm_tlm_gp payload;
    uvm_sequence_item item;
    byte unsigned data_bytes[], enables[];
    uvm_tlm_gp first, second;
    adapter = new("adapter");
      rw.kind = UVM_READ; rw.addr = 'h120; rw.data = 'haaaa;
      rw.n_bits = 16; rw.byte_en = '1; rw.status = UVM_IS_OK;
      item = adapter.reg2bus(rw);
      if (!$cast(first, item)) $fatal(1, "wrong payload type");
      rw.kind = UVM_WRITE; rw.addr = 'h240; rw.data = 'h5a5a;
      item = adapter.reg2bus(rw);
      if (!$cast(second, item)) $fatal(1, "wrong payload type");
      $display("UT: distinct %0d first_read %0d second_write %0d addresses %0h %0h lengths %0d %0d",
               first != second, first.is_read(), second.is_write(), first.get_address(),
               second.get_address(), first.get_data_length(), second.get_data_length());
      second.get_data(data_bytes);
      $display("UT: second_data %0d", data_bytes.size() == 2 &&
               data_bytes[0] == 'h5a && data_bytes[1] == 'h5a);
      first.set_address('h999); data_bytes = new[2];
      data_bytes[0] = 'he1; data_bytes[1] = 'he1; first.set_data(data_bytes);
      second.get_data(data_bytes);
      $display("UT: second_isolated %0d", second.get_address() == 'h240 &&
               data_bytes.size() == 2 && data_bytes[0] == 'h5a && data_bytes[1] == 'h5a);
    $finish;
  end
endmodule
