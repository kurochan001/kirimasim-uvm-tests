/*
:name: test_regfile_local_hdl_paths_keep_duplicate_instances_and_abstractions_separate
:description: register file local HDL path lists preserve alternatives and design abstractions (18.3.4.2)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.3.4.2 18.3.4.3 18.3.4.4 18.3.2.2 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_regfile_local_hdl_paths_keep_duplicate_instances_and_abstractions_separate.expected
*/
// Symbolic path strings only: no HDL lookup, DPI, bus or DUT access.
// Queues are fresh and compared by membership without an enumeration order.
module test_regfile_local_hdl_paths_keep_duplicate_instances_and_abstractions_separate;
  import uvm_pkg::*;
  class block_type extends uvm_reg_block;
    function new(string name); super.new(name, UVM_NO_COVERAGE); endfunction
  endclass

  initial begin
    automatic block_type root_block = new("root");
    automatic uvm_reg_file file_value = new("file");
    string rtl[$], gate[$], repeated[$];
    automatic int rtl_mask = 0;
    root_block.configure(null, "dut"); file_value.configure(root_block, null, "bank_a");
    file_value.add_hdl_path("bank_b"); file_value.add_hdl_path("net_bank", "GATE");
    file_value.get_hdl_path(rtl); file_value.get_hdl_path(gate, "GATE");
    file_value.get_hdl_path(repeated, "RTL");
    foreach (rtl[i]) begin
      if (rtl[i] == "bank_a") rtl_mask |= 1;
      if (rtl[i] == "bank_b") rtl_mask |= 2;
    end
    $display("UT: local rtl_count %0d members %0d gate_count %0d gate %0d", rtl.size(), rtl_mask,
             gate.size(), gate.size() == 1 && gate[0] == "net_bank");
    $display("UT: repeated_count %0d has_default %0d has_gate %0d has_missing %0d",
             repeated.size(), file_value.has_hdl_path(), file_value.has_hdl_path("GATE"),
             file_value.has_hdl_path("MISSING"));
    $finish;
  end
endmodule
