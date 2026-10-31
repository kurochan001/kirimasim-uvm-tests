/*
:name: test_mem_intrinsic_readonly_policy_and_map_rights_are_distinct
:description: unshared rights and intrinsic or map-imposed readonly access are queried separately (IEEE 1800.2-2020 Section 18.6.4.5)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6.4.5 18.6.4.6 18.6.3.2 18.1.2.3 18.2.3.4 18.1.2.6 18.1.2.1 18.1.2.2 18.4.2.1 18.6.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_mem_intrinsic_readonly_policy_and_map_rights_are_distinct.expected
*/
// Both memories are unshared, so the rights query returns RW (18.6.4.5).
// Effective access must still include the map restriction (18.6.4.6): the
// intrinsic RO memory and the RO-restricted RW memory both expose RO access.

module test_mem_intrinsic_readonly_policy_and_map_rights_are_distinct;
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
    automatic model_mem rom = new("rom", 4, 16, "RO");
    automatic model_mem ram = new("ram", 4, 16, "RW");
    uvm_reg_map mapping;
    blk.configure();
    rom.configure(blk);
    ram.configure(blk);
    mapping = blk.create_map("bus", 0, 2, UVM_LITTLE_ENDIAN);
    mapping.add_mem(rom, 0, "RW");
    mapping.add_mem(ram, 'h40, "RO");
    blk.lock_model();
    $display("UT: rights %s %s access %s %s", rom.get_rights(mapping),
             ram.get_rights(mapping), rom.get_access(mapping), ram.get_access(mapping));
    $finish;
  end
endmodule
