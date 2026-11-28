/*
:name: test_reg_tlm_adapter_reg2bus_preserves_enabled_data_pairs
:description: A write payload carries the bytes selected by its source operation's byte enables
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.2.2.2.1 19.2.1.2.5 19.1.2.1 19.1.2.2 19.1.2.3 19.1.2.4 19.1.2.5 12.3.4.2.9 12.3.4.2.10 12.3.4.2.12 12.3.4.2.15 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_tlm_adapter_reg2bus_preserves_enabled_data_pairs.expected
*/
// What it checks:
// Each enabled payload byte corresponds to an enabled source lane.
//
// How the expected output follows from the standard:
// 1800.2-2020 19.2.2.2.1 (UVM-TLM-REG2BUS-ENABLED-DATA-PAIRS) converts
// a generic operation whose data and enables refer to the same lanes
// (19.1.2.3 and 19.1.2.5). The payload enable pattern identifies valid
// bytes (12.3.4.2.12). A 32-bit write has a four-byte data extent even
// when lanes are disabled (19.1.2.4 and 12.3.4.2.10). Use two nonuniform
// words with different masks and compare the enabled source-byte sets.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_reg_tlm_adapter_reg2bus_preserves_enabled_data_pairs;
  import uvm_pkg::*;

  initial begin
    automatic uvm_reg_tlm_adapter adapter = new("adapter");
    uvm_reg_bus_op source;
    uvm_sequence_item item;
    uvm_tlm_gp payload;
    byte unsigned bytes[];
    byte unsigned enables[];
    bit [3:0] source_lanes;
    int unsigned data_length;
    int unsigned enable_length;
    int enabled_count;

    for (int trial = 0; trial < 2; trial++) begin
      source.kind = UVM_WRITE;
      source.addr = (trial == 0) ? 'h120 : 'h240;
      source.data = (trial == 0) ? 32'hc49b3712 : 32'h6dea7851;
      source.byte_en = (trial == 0) ? 4'b0100 : 4'b1011;
      source.n_bits = 32;
      source.status = UVM_IS_OK;
      item = adapter.reg2bus(source);
      if (!$cast(payload, item) || payload == null)
        $fatal(1, "adapter returned the wrong payload");

      payload.get_data(bytes);
      payload.get_byte_enable(enables);
      data_length = payload.get_data_length();
      enable_length = payload.get_byte_enable_length();
      if (data_length != 4 || bytes.size() < data_length ||
          enable_length == 0 || enables.size() < enable_length)
        $fatal(1, "payload does not describe four bytes with a valid enable pattern");

      source_lanes = 0;
      enabled_count = 0;
      for (int index = 0; index < data_length; index++) begin
        byte unsigned enable_value;
        // The payload can repeat a shorter enable pattern over its data.
        enable_value = enables[index % enable_length];
        if (enable_value == 8'hff) begin
          enabled_count++;
          for (int lane = 0; lane < 4; lane++)
            if (bytes[index] == source.data[8 * lane +: 8]) source_lanes[lane] = 1;
        end else if (enable_value != 8'h00) begin
          $fatal(1, "invalid byte-enable value");
        end
      end

      $display("UT: trial %0d write %0d address %0h length %0d enabled %0d sources %04b",
               trial, payload.is_write(), payload.get_address(), data_length,
               enabled_count, source_lanes);
    end
    $finish;
  end
endmodule
