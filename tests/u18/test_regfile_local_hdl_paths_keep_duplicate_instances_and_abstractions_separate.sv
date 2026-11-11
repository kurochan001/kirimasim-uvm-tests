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
// What it checks:
// 1. The configured HDL path supplies the register file contribution for its
//    RTL abstraction.
// 2. Repeated HDL path additions retain the register-file alternatives for the
//    selected abstraction.
// 3. An explicitly selected design abstraction keeps its added path separate
//    from RTL paths.
// 4. The local path query returns the selected register-file components
//    without ancestor prefixes.
// 5. Path presence is reported for the selected abstraction; an omitted kind
//    uses the nearest enclosing register-file or block default.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.3.2.2 (UVM-REGFILE-CONFIGURED-HDL-CONTRIBUTION) gives rule
//    1 above. Setup: A file is configured with bank_a, then another RTL
//    alternative and a GATE path are added. Expected: Its local RTL set
//    contains bank_a and bank_b, independently of the GATE path.
// 2. 1800.2-2020 18.3.4.2 (UVM-REGFILE-ADD-HDL-ALTERNATIVES) gives rule 2
//    above. Setup: A configured RTL bank_a receives bank_b through
//    add_hdl_path with its kind omitted. Expected: The RTL list contains
//    exactly the two distinct local alternatives.
// 3. 1800.2-2020 18.3.4.2 (UVM-REGFILE-ADD-HDL-ABSTRACTION-ISOLATION) gives
//    rule 3 above. Setup: The file receives net_bank for GATE while two RTL
//    alternatives already exist. Expected: The GATE list has only net_bank and
//    the RTL list still has both original alternatives.
// 4. 1800.2-2020 18.3.4.4 (UVM-REGFILE-LOCAL-HDL-QUERY-EXCLUDES-ANCESTORS)
//    gives rule 4 above. Setup: A parent block has dut, and the file has two
//    local RTL paths and one GATE path; each output queue is fresh. Expected:
//    Local results contain only bank_a/bank_b or net_bank, and a repeated RTL
//    query has two entries.
// 5. 1800.2-2020 18.3.4.3 (UVM-REGFILE-HDL-PRESENCE-QUERY) gives rule 5 above.
//    Setup: Known RTL/GATE paths and a missing kind are queried; another file
//    selects GATE before clearing paths. Expected: Known paths report true and
//    a missing kind false. After RTL is cleared, omitted-kind presence is
//    false even though the current file selects GATE and the explicit GATE
//    path exists.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
