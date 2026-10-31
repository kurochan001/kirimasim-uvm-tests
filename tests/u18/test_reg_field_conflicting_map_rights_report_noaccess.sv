/*
:name: test_reg_field_conflicting_map_rights_report_noaccess
:description: field and map access contradictions produce NOACCESS in the restricted view (IEEE 1800.2-2020 Section 18.5.4.5)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.4.5 18.5.4.6 18.4.2.2 18.5.3.2 18.1.2.3 18.2.3.3 18.1.2.6 18.1.2.1 18.1.2.2 18.4.2.1 18.6.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_field_conflicting_map_rights_report_noaccess.expected
*/
// One register contains a WO field and an RO field. Explicit map
// arguments select two different views of those same fields.

module test_reg_field_conflicting_map_rights_report_noaccess;
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
    automatic model_reg rg = new("r", 16);
    automatic uvm_reg_field low = new("low");
    automatic uvm_reg_field high = new("high");
    uvm_reg_map reading;
    uvm_reg_map writing;
    blk.configure();
    rg.configure(blk);
    low.configure(rg, 8, 0, "WO", 0, 0, 1, 0, 1);
    high.configure(rg, 8, 8, "RO", 0, 0, 1, 0, 1);
    reading = blk.create_map("read", 0, 2, UVM_LITTLE_ENDIAN);
    writing = blk.create_map("write", 'h100, 2, UVM_LITTLE_ENDIAN);
    reading.add_reg(rg, 0, "RO");
    writing.add_reg(rg, 0, "WO");
    blk.lock_model();
    $display("UT: low %s %s high %s %s", low.get_access(reading),
             low.get_access(writing), high.get_access(reading), high.get_access(writing));
    $finish;
  end
endmodule
