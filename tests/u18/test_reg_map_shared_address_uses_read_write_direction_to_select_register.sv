/*
:name: test_reg_map_shared_address_uses_read_write_direction_to_select_register
:description: read and write lookup select different registers sharing one map address (IEEE 1800.2-2020 Section 18.2.4.17)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.2.4.17 18.5.4.6 18.4.2.2 18.5.3.2 18.1.2.3 18.2.3.3 18.1.2.6 18.1.2.1 18.1.2.2 18.4.2.1 18.6.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_map_shared_address_uses_read_write_direction_to_select_register.expected
*/
// Read-only and write-only registers may share an address. Each lookup
// selects the proper direction without assuming insertion order.

module test_reg_map_shared_address_uses_read_write_direction_to_select_register;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class model_block extends uvm_reg_block;
    function new(string name="blk"); super.new(name, UVM_NO_COVERAGE); endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(string name="r", int unsigned width=8);
      super.new(name, width, UVM_NO_COVERAGE);
    endfunction
  endclass
  class model_mem extends uvm_mem;
    function new(string name="mem", longint unsigned size=4,
                 int unsigned width=16, string access="RW");
      super.new(name, size, width, access, UVM_NO_COVERAGE);
    endfunction
  endclass

  initial begin
    automatic model_block blk = new("blk");
    automatic model_reg rg = new("r", 8);
    automatic uvm_reg_field field = new("value");
    uvm_reg_map mapping;
    automatic model_reg write_reg = new("write_reg", 8);
    automatic uvm_reg_field write_field = new("write_value");
    blk.configure();
    rg.configure(blk);
    write_reg.configure(blk);
    field.configure(rg, 8, 0, "RO", 0, 0, 1, 0, 1);
    write_field.configure(write_reg, 8, 0, "WO", 0, 0, 1, 0, 1);
    mapping = blk.create_map("bus", 0, 1, UVM_LITTLE_ENDIAN);
    mapping.add_reg(write_reg, 'h20, "WO");
    mapping.add_reg(rg, 'h20, "RO");
    blk.lock_model();
    $display("UT: read %0d write %0d missing %0d", mapping.get_reg_by_offset('h20) == rg,
             mapping.get_reg_by_offset('h20, 0) == write_reg,
             mapping.get_reg_by_offset('h40) == null);
    $finish;
  end
endmodule
