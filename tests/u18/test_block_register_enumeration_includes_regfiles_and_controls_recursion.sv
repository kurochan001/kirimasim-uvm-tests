/*
:name: test_block_register_enumeration_includes_regfiles_and_controls_recursion
:description: register enumeration includes regfile members and isolates block recursion (IEEE 1800.2-2020 Section 18.1.3.7)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.3.7 18.1.2.1 18.1.2.2 18.1.3.1 18.3.2.1 18.3.2.2 18.3.3.1 18.3.3.2 18.4.2.1 18.4.2.2 18.4.3.1 18.4.3.2 18.5.3.2 18.6.3.1 18.6.3.2 17.2.2.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_block_register_enumeration_includes_regfiles_and_controls_recursion.expected
*/
// Register-model hierarchy only. Queries use fresh result queues and handle
// membership, without a visit order, address maps, RTL transfers or HDL DPI.
module test_block_register_enumeration_includes_regfiles_and_controls_recursion;
  import uvm_pkg::*;
  class model_block extends uvm_reg_block;
    function new(string name="blk"); super.new(name, UVM_NO_COVERAGE); endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(string name="r"); super.new(name, 8, UVM_NO_COVERAGE); endfunction
  endclass
  model_block root_block, child, side, grandchild, peer;
  model_reg root_reg, file_reg, child_reg, deep_reg, peer_reg;
  uvm_reg_file outer_file, inner_file;
  uvm_reg_field root_low, root_high, file_value, child_value, deep_value, peer_value;
  uvm_mem root_mem, child_mem, deep_mem, peer_mem;
  function automatic uvm_reg_field field_for(model_reg rg, string name, int width=8, int lsb=0);
    uvm_reg_field result_value;
    result_value = new(name); result_value.configure(rg, width, lsb, "RW", 0, 0, 1, 0, 1);
    return result_value;
  endfunction
  function automatic void build_model();
    root_block = new("root"); child = new("child"); side = new("side");
    grandchild = new("grandchild"); peer = new("peer");
    root_block.configure(); child.configure(root_block); side.configure(root_block);
    grandchild.configure(child); peer.configure();
    outer_file = new("outer"); outer_file.configure(root_block, null);
    inner_file = new("inner"); inner_file.configure(root_block, outer_file);
    root_reg = new("root_reg"); root_reg.configure(root_block);
    file_reg = new("file_reg"); file_reg.configure(root_block, inner_file);
    child_reg = new("child_reg"); child_reg.configure(child);
    deep_reg = new("deep_reg"); deep_reg.configure(grandchild);
    peer_reg = new("peer_reg"); peer_reg.configure(peer);
    root_low = field_for(root_reg, "root_low", 4, 0);
    root_high = field_for(root_reg, "root_high", 4, 4);
    file_value = field_for(file_reg, "file_value");
    child_value = field_for(child_reg, "child_value");
    deep_value = field_for(deep_reg, "deep_value");
    peer_value = field_for(peer_reg, "peer_value");
    root_mem = new("root_mem", 4, 8, "RW", UVM_NO_COVERAGE); root_mem.configure(root_block);
    child_mem = new("child_mem", 4, 8, "RW", UVM_NO_COVERAGE); child_mem.configure(child);
    deep_mem = new("deep_mem", 4, 8, "RW", UVM_NO_COVERAGE); deep_mem.configure(grandchild);
    peer_mem = new("peer_mem", 4, 8, "RW", UVM_NO_COVERAGE); peer_mem.configure(peer);
  endfunction
  initial begin
    uvm_reg regs[$]; bit [3:0] members;
    build_model();

    root_block.get_registers(regs, UVM_NO_HIER); members = 0;
    foreach (regs[i]) begin
      if (regs[i] == root_reg) members[0] = 1;
      if (regs[i] == file_reg) members[1] = 1;
      if (regs[i] == child_reg) members[2] = 1;
      if (regs[i] == deep_reg) members[3] = 1;
    end
    $display("UT: local count %0d members %0h", regs.size(), members);
    regs.delete(); root_block.get_registers(regs); members = 0;
    foreach (regs[i]) begin
      if (regs[i] == root_reg) members[0] = 1;
      if (regs[i] == file_reg) members[1] = 1;
      if (regs[i] == child_reg) members[2] = 1;
      if (regs[i] == deep_reg) members[3] = 1;
    end
    $display("UT: recursive count %0d members %0h", regs.size(), members);
    regs.delete(); child.get_registers(regs); members = 0;
    foreach (regs[i]) begin
      if (regs[i] == child_reg) members[2] = 1;
      if (regs[i] == deep_reg) members[3] = 1;
    end
    $display("UT: child_scope count %0d members %0h", regs.size(), members);

    $finish;
  end
endmodule
