/*
:name: test_mem_hdl_path_default_kind_and_rtl_clear_preserve_the_other_abstraction
:description: mem HDL kind selection uses the parent default while default clear removes only RTL (IEEE 1800.2-2020 Section 18.6.7.3)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6.7.3 18.6.7.4 18.6.7.5 18.6.7.6 18.6.7.7 18.6.7.8 18.4.2.1 18.4.2.2 18.6.3.1 18.6.3.2 17.2.1.7 18.1.2.1 18.1.2.2 18.1.6.4 18.1.6.5 18.1.6.6 18.1.6.7 18.1.6.8 18.1.6.9 18.1.6.10 18.1.6.11 18.1.6.12 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_mem_hdl_path_default_kind_and_rtl_clear_preserve_the_other_abstraction.expected
*/
// Symbolic HDL path metadata only: no HDL access, RTL storage or DPI calls.
module test_mem_hdl_path_default_kind_and_rtl_clear_preserve_the_other_abstraction;
  import uvm_pkg::*;
  class model_block extends uvm_reg_block;
    function new(string name="blk"); super.new(name, UVM_NO_COVERAGE); endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(); super.new("r", 16, UVM_NO_COVERAGE); endfunction
  endclass
  initial begin

    automatic model_block blk = new();
    automatic uvm_mem element = new("mem", 4, 16, "RW", UVM_NO_COVERAGE);
    uvm_hdl_path_slice slices[];
    uvm_hdl_path_concat paths[$];
    string kinds[$];
    bit rtl_seen;
    bit gate_seen;
    blk.configure(); blk.set_default_hdl_path("GATE"); element.configure(blk);
    slices = new[2];
    slices[0].path = "high"; slices[0].offset = 8; slices[0].size = 8;
    slices[1].path = "low"; slices[1].offset = 0; slices[1].size = 8;
    element.add_hdl_path(slices, "RTL");
    element.add_hdl_path_slice("gate_value", -1, -1, 1, "GATE");
    element.get_hdl_path(paths);
    element.get_hdl_path_kinds(kinds);
    rtl_seen = 0; gate_seen = 0;
    foreach (kinds[i]) begin rtl_seen |= kinds[i] == "RTL"; gate_seen |= kinds[i] == "GATE"; end
    $display("UT: before default_present %0d paths %0d kinds %0d members %0d",
    element.has_hdl_path(),
             paths.size(), kinds.size(), rtl_seen && gate_seen);
    element.clear_hdl_path();
    paths.delete(); kinds.delete(); element.get_hdl_path(paths); element.get_hdl_path_kinds(kinds);
    $display(
    "UT: rtl_clear absent %0d gate %0d default %0d paths %0d kinds %0d kind_ok %0d",
             !element.has_hdl_path("RTL"), element.has_hdl_path("GATE"), element.has_hdl_path(),
             paths.size(), kinds.size(), kinds.size() == 1 && kinds[0] == "GATE");
    element.clear_hdl_path("GATE"); kinds.delete(); element.get_hdl_path_kinds(kinds);
    $display("UT: gate_clear default_absent %0d kinds %0d", !element.has_hdl_path(), kinds.size());

    $finish;
  end
endmodule
