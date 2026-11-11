/*
:name: test_flattened_regfile_omits_its_name_from_full_paths_for_each_selected_abstraction
:description: a flattened register file adds no HDL path component to its descendants (18.3.2.2)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.3.2.2 18.3.4.5 18.3.4.2 18.3.4.7 18.1.2.2 18.1.6.5 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_flattened_regfile_omits_its_name_from_full_paths_for_each_selected_abstraction.expected
*/
// What it checks:
// 1. A register file configured without an HDL contribution does not add its
//    logical name to descendant HDL paths.
// 2. An omitted full-path kind uses the nearest enclosing default abstraction
//    through flattened file scopes.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.3.2.2 (UVM-REGFILE-CONFIGURED-FLATTENED-HDL-SCOPE) gives
//    rule 1 above. Setup: A logical not_an_hdl_scope file is flattened between
//    a dut block and a leaf file. Expected: The RTL descendant path is
//    dut.leaf with no logical-file component.
// 2. 1800.2-2020 18.3.4.5 (UVM-REGFILE-FULL-HDL-DEFAULT-ABSTRACTION-SELECTION)
//    gives rule 2 above. Setup: A flattened parent selects GATE while its
//    child has distinct RTL leaf and GATE cell contributions. Expected: The
//    explicit RTL path is dut.leaf and both selected and explicit GATE paths
//    are net.cell; the explicit GATE query controls for path assembly.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Symbolic path strings only: no HDL lookup, DPI, bus or DUT access.
// The pinned child keeps its initial RTL default instead of inheriting GATE.
// Explicit RTL and GATE paths isolate flattening from default selection.
module test_flattened_regfile_omits_its_name_from_full_paths_for_each_selected_abstraction;
  import uvm_pkg::*;
  class block_type extends uvm_reg_block;
    function new(string name); super.new(name, UVM_NO_COVERAGE); endfunction
  endclass

  initial begin
    automatic block_type root_block = new("root");
    automatic uvm_reg_file flat_file = new("not_an_hdl_scope");
    automatic uvm_reg_file leaf_file = new("leaf_file");
    string rtl[$], gate[$], explicit_gate[$];
    root_block.configure(null, "dut"); root_block.add_hdl_path("net", "GATE");
    flat_file.configure(root_block, null);
    flat_file.add_hdl_path("", "GATE");
    leaf_file.configure(root_block, flat_file, "leaf"); leaf_file.add_hdl_path("cell", "GATE");
    leaf_file.get_full_hdl_path(rtl, "RTL");
    flat_file.set_default_hdl_path("GATE"); leaf_file.get_full_hdl_path(gate);
    leaf_file.get_full_hdl_path(explicit_gate, "GATE");
    $display("UT: rtl_count %0d flattened %0d gate_count %0d flattened %0d", rtl.size(),
             rtl.size() == 1 && rtl[0] == "dut.leaf", gate.size(),
             gate.size() == 1 && gate[0] == "net.cell");
    $display("UT: explicit_gate count %0d flattened %0d", explicit_gate.size(),
             explicit_gate.size() == 1 && explicit_gate[0] == "net.cell");
    $finish;
  end
endmodule
