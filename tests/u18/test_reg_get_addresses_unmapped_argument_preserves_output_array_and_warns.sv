/*
:name: test_reg_get_addresses_unmapped_argument_preserves_output_array_and_warns
:description: an unmapped register address query warns and leaves the caller array unchanged (IEEE 1800.2-2020 Section 18.4.3.15)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.3.15 6.6.3.2 6.6.5 18.4.2.2 18.5.3.2 18.1.2.3 18.2.3.3 18.1.2.6 18.1.2.1 18.1.2.2 18.4.2.1 18.6.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_get_addresses_unmapped_argument_preserves_output_array_and_warns.expected
*/
// The register is mapped only in the first map. Pass the other map
// explicitly and retain a sentinel in the output array.

module test_reg_get_addresses_unmapped_argument_preserves_output_array_and_warns;
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

  class report_probe extends uvm_report_catcher;
    int warnings = 0;
    int errors = 0;
    function new(); super.new("probe"); endfunction
    virtual function action_e catch();
      if (get_severity() == UVM_WARNING) warnings++;
      if (get_severity() == UVM_ERROR) errors++;
      return CAUGHT;
    endfunction
  endclass

  initial begin
    automatic model_block blk = new("blk");
    automatic model_reg rg = new("r", 8);
    automatic uvm_reg_field field = new("value");
    uvm_reg_map mapping;
    uvm_reg_map other;
    uvm_reg_addr_t addresses[];
    automatic int transferred = 0;
    automatic report_probe probe = new();
    blk.configure();
    rg.configure(blk);
    field.configure(rg, 8, 0, "RW", 0, 8'h12, 1, 0, 1);
    mapping = blk.create_map("mapped", 0, 1, UVM_LITTLE_ENDIAN);
    other = blk.create_map("unrelated", 'h100, 1, UVM_LITTLE_ENDIAN);
    mapping.add_reg(rg, 0);
    blk.lock_model();
    addresses = new[1];
    addresses[0] = 'hcafe;
    uvm_report_cb::add(null, probe);
    transferred = rg.get_addresses(other, addresses);
    $display("UT: rejected %0d count %0d warned %0d", transferred == -1,
             addresses.size(), probe.warnings > 0);
    if (addresses.size() == 1) $display("UT: sentinel %0h", addresses[0]);
    $finish;
  end
endmodule
