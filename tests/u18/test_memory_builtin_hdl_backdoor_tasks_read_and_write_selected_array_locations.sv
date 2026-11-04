/*
:name: test_memory_builtin_hdl_backdoor_tasks_read_and_write_selected_array_locations
:description: Built-in memory backdoor tasks access actual public HDL array elements and preserve neighboring locations
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6.7.10 18.6.7.11 18.6.3.2 19.6.2.2 19.6.2.7 19.1.1.2.4 19.1.1.2.6 19.1.1.2.7 19.1.1.2.8 19.1.1.2.10 1800-2023 6.21 8.20
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
:expected_stdout: @test_memory_builtin_hdl_backdoor_tasks_read_and_write_selected_array_locations.expected
*/
// Real HDL storage. Run the independent VPI HDL condition as well.
module test_memory_builtin_hdl_backdoor_tasks_read_and_write_selected_array_locations;
  import uvm_pkg::*;
  logic [15:0] cells[0:3] /*verilator public_flat_rw*/;

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
    automatic memory_type memory=new("memory56",4,16);
    automatic uvm_reg_item operation=new("operation56");
    automatic quiet_probe quiet=new();
    bit ok;
    foreach (cells[i]) cells[i]=16'h5600+i;
    owner.configure(null,
      "test_memory_builtin_hdl_backdoor_tasks_read_and_write_selected_array_locations");
    memory.configure(owner,"cells");
    uvm_report_cb::add(null,quiet); #1;
    operation.set_element_kind(UVM_MEM); operation.set_element(memory);
    operation.set_kind(UVM_READ); operation.set_offset(1); operation.set_value_size(1);
    memory.access_read(operation);
    $display("UT: physical_memory_read status %0d data %0d",
      operation.get_status()==UVM_IS_OK,operation.get_value(0)=='h5601);
    operation.set_kind(UVM_WRITE); operation.set_offset(2); operation.set_value('habcd);
    memory.access_write(operation); ok=operation.get_status()==UVM_IS_OK; #1;
    $display("UT: physical_memory_write status %0d selected %0d neighbors %0d",ok,
      cells[2]=='habcd,cells[0]=='h5600 && cells[1]=='h5601 && cells[3]=='h5603);
    operation.set_kind(UVM_READ); memory.access_read(operation);
    $display("UT: physical_memory_readback status %0d data %0d",
      operation.get_status()==UVM_IS_OK,operation.get_value(0)=='habcd);
    $finish;
  end
endmodule
