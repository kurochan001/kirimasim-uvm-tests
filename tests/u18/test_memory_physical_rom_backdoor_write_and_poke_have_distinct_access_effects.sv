/*
:name: test_memory_physical_rom_backdoor_write_and_poke_have_distinct_access_effects
:description: Actual memory HDL backdoor write preserves ROM policy while poke deposits and read/peek return storage
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6.5.1 18.6.5.2 18.6.5.5 18.6.5.6 18.6.7.2 18.6.3.2 19.6.2.2 19.6.2.7 1800-2023 6.21 8.20
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
:expected_stdout: @test_memory_physical_rom_backdoor_write_and_poke_have_distinct_access_effects.expected
*/
// Read-only modeled writes and direct deposits use actual HDL array cells.
module test_memory_physical_rom_backdoor_write_and_poke_have_distinct_access_effects;
  import uvm_pkg::*;
  logic [15:0] cells[0:3] /*verilator public_flat_rw*/;

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
    automatic uvm_mem memory=new("rom56",4,16,"RO");
    automatic quiet_probe quiet=new();
    uvm_reg_map mapping; uvm_status_e status; uvm_reg_data_t value; bit ok;
    foreach (cells[i]) cells[i]=16'h5600+i;
    owner.configure(null,
      "test_memory_physical_rom_backdoor_write_and_poke_have_distinct_access_effects");
    memory.configure(owner,"cells");
    mapping=owner.create_map("bus56",0,2,UVM_LITTLE_ENDIAN);
    mapping.add_mem(memory,0); owner.lock_model(); uvm_report_cb::add(null,quiet); #1;
    memory.write(status,1,'h56ee,UVM_BACKDOOR,mapping); #1;
    $display("UT: physical_rom_write unchanged %0d peer %0d",cells[1]=='h5601,cells[2]=='h5602);
    memory.poke(status,1,'h5633); ok=status==UVM_IS_OK; #1;
    $display("UT: physical_rom_poke status %0d data %0d peer %0d",ok,
      cells[1]=='h5633,cells[2]=='h5602);
    memory.read(status,1,value,UVM_BACKDOOR,mapping);
    $display("UT: physical_rom_read status %0d data %0d",status==UVM_IS_OK,value=='h5633);
    memory.peek(status,1,value);
    $display("UT: physical_rom_peek status %0d data %0d",status==UVM_IS_OK,value=='h5633);
    $finish;
  end
endmodule
