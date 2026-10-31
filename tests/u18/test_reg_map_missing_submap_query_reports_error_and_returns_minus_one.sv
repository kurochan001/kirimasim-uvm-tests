/*
:name: test_reg_map_missing_submap_query_reports_error_and_returns_minus_one
:description: a null submap query reports an error and returns the all-one address (IEEE 1800.2-2020 Section 18.2.3.7)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.2.3.7 18.1.2.3 6.6.3.2 6.6.5 18.1.2.1 18.1.2.2 18.4.2.1 18.6.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_map_missing_submap_query_reports_error_and_returns_minus_one.expected
*/
// The catcher observes the original error severity without rewriting it.
// Compare the address-width minus-one value symbolically.

module test_reg_map_missing_submap_query_reports_error_and_returns_minus_one;
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
    uvm_reg_map mapping;
    automatic uvm_reg_addr_t result = 0;
    automatic report_probe probe = new();
    blk.configure();
    mapping = blk.create_map("bus", 0, 1, UVM_LITTLE_ENDIAN);
    uvm_report_cb::add(null, probe);
    result = mapping.get_submap_offset(null);
    $display("UT: rejected %0d error %0d", result == '1, probe.errors > 0);
    $finish;
  end
endmodule
