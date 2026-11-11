/*
:name: test_memory_hdl_split_array_paths_assemble_and_deposit_the_declared_bit_slices
:description: Built-in memory HDL backdoors assemble and deposit split real arrays at explicit bit coordinates
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6.7.10 18.6.7.11 18.6.7.4 18.6.3.2 19.6.2.2 19.6.2.7 1800-2023 6.21 8.20
:uvm: 2020.3.1
:uvm_dpi: yes
:uvm_hdl_backend: vpi
:uvm_defines: UVM_REGEX_NO_DPI UVM_CMDLINE_NO_DPI
:dpi_c: @../../tools/uvm_hdl_vpi.cpp
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_hdl_split_array_paths_assemble_and_deposit_the_declared_bit_slices.expected
*/
// What it checks:
// Memory HDL backdoor reads assemble and writes distribute the specified
// physical slices.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.6.7.10 (UVM-MEMORY-AUDIT-PHYSICAL-SPLIT-SLICES) gives the
// rule above. Setup: A 24-bit memory uses separate actual 8-bit low and 16-bit
// high arrays with explicit bit coordinates and the same location index.
// Expected: Read assembles ab0111; write cd2356 deposits cd23 and 56 into the
// selected bank cells with success and leaves neighboring cells unchanged.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Actual two-bank array storage, not a path/value mock.
module test_memory_hdl_split_array_paths_assemble_and_deposit_the_declared_bit_slices;
  import uvm_pkg::*;
  logic [7:0] low_bank[0:3] /*verilator public_flat_rw*/;
  logic [15:0] high_bank[0:3] /*verilator public_flat_rw*/;

  // A derived wrapper reaches protected implementations in the pinned library.
  // Separate legal declaration probes retain the public-access discrepancy.
  class memory_type extends uvm_mem;
    function new(string name,longint unsigned size,int unsigned width);
      super.new(name,size,width);
    endfunction
    task access_read(uvm_reg_item rw); super.backdoor_read(rw); endtask
    task access_write(uvm_reg_item rw); super.backdoor_write(rw); endtask
  endclass
  class block_type extends uvm_reg_block;
    function new(string name="owner56"); super.new(name,UVM_NO_COVERAGE); endfunction
  endclass

  class quiet_probe extends uvm_report_catcher;
    virtual function action_e catch();
      if (get_severity() inside {UVM_WARNING,UVM_ERROR}) return CAUGHT;
      return THROW;
    endfunction
  endclass

  initial begin
    automatic block_type owner=new();
    automatic memory_type memory=new("memory56",4,24);
    automatic uvm_reg_item operation=new("operation56");
    automatic quiet_probe quiet=new();
    uvm_hdl_path_slice slices[]; bit ok;
    foreach (low_bank[i]) begin low_bank[i]=8'h10+i; high_bank[i]=16'hab00+i; end
    owner.configure(null,
      "test_memory_hdl_split_array_paths_assemble_and_deposit_the_declared_bit_slices");
    memory.configure(owner);
    slices=new[2];
    slices[0].path="low_bank"; slices[0].offset=0; slices[0].size=8;
    slices[1].path="high_bank"; slices[1].offset=8; slices[1].size=16;
    memory.add_hdl_path(slices); uvm_report_cb::add(null,quiet); #1;
    operation.set_element_kind(UVM_MEM); operation.set_element(memory);
    operation.set_kind(UVM_READ); operation.set_offset(1); operation.set_value_size(1);
    memory.access_read(operation);
    $display("UT: physical_split_read status %0d data %0d",
      operation.get_status()==UVM_IS_OK,operation.get_value(0)=='hab0111);
    operation.set_kind(UVM_WRITE); operation.set_value('hcd2356);
    memory.access_write(operation); ok=operation.get_status()==UVM_IS_OK; #1;
    $display("UT: physical_split_write status %0d slices %0d peers %0d",ok,
      high_bank[1]=='hcd23 && low_bank[1]=='h56,
      high_bank[0]=='hab00 && low_bank[0]=='h10 && high_bank[2]=='hab02 && low_bank[2]=='h12);
    $finish;
  end
endmodule
