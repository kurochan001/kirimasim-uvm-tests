/*
:name: test_reg_map_auto_predict_configuration_is_independent_per_map
:description: auto-predict defaults off and changes independently for each map (IEEE 1800.2-2020 Section 18.2.5.1)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.2.5.1 18.2.5.2 18.1.2.3 18.1.2.1 18.1.2.2 18.4.2.1 18.6.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_map_auto_predict_configuration_is_independent_per_map.expected
*/
// This checks the mode setting only. It does not claim that a bus read
// or write has exercised automatic prediction.

module test_reg_map_auto_predict_configuration_is_independent_per_map;
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
    uvm_reg_map first;
    uvm_reg_map second;
    blk.configure();
    first = blk.create_map("first", 0, 1, UVM_LITTLE_ENDIAN);
    second = blk.create_map("second", 'h100, 1, UVM_LITTLE_ENDIAN);
    $display("UT: defaults %0d %0d", first.get_auto_predict(), second.get_auto_predict());
    first.set_auto_predict();
    $display("UT: enabled %0d %0d", first.get_auto_predict(), second.get_auto_predict());
    first.set_auto_predict(0);
    $display("UT: disabled %0d %0d", first.get_auto_predict(), second.get_auto_predict());
    $finish;
  end
endmodule
