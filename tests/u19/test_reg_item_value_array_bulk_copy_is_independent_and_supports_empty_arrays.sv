/*
:name: test_reg_item_value_array_bulk_copy_is_independent_and_supports_empty_arrays
:description: register item bulk value arrays copy contents and accept empty arrays (IEEE 1800.2-2020 Section 19.1.1.2.4)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.1.1.2.4 19.1.1.3.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_item_value_array_bulk_copy_is_independent_and_supports_empty_arrays.expected
*/
// Exercise the descriptor public API directly, without bus or DUT access.
// Undefined initial enum/data values are never observed. UVM_HAS_X here is
// an explicitly assigned status enum, not a four-state data observation.
module test_reg_item_value_array_bulk_copy_is_independent_and_supports_empty_arrays;
  import uvm_pkg::*;

  `include "uvm_macros.svh"
  class block_type extends uvm_reg_block;
    function new(); super.new("blk", UVM_NO_COVERAGE); endfunction
  endclass
  class reg_type extends uvm_reg;
    function new(); super.new("r", 8, UVM_NO_COVERAGE); endfunction
  endclass
  class mem_type extends uvm_mem;
    function new(); super.new("m", 4, 8, "RW", UVM_NO_COVERAGE); endfunction
  endclass
  class sequence_type extends uvm_sequence;
    function new(string name); super.new(name); endfunction
    virtual task body(); endtask
  endclass
  class warning_probe extends uvm_report_catcher;
    int warnings = 0;
    function new(); super.new("warning_probe"); endfunction
    function action_e catch();
      if (get_severity() == UVM_WARNING) begin warnings++; return CAUGHT; end
      return THROW;
    endfunction
  endclass
  initial begin
    automatic uvm_reg_item first = new("first");
    automatic uvm_reg_item peer = new("peer");

    uvm_reg_data_t source_values[];
    uvm_reg_data_t returned_values[];


    source_values = new[3]; source_values[0] = 'h11; source_values[1] = 'h22;
    source_values[2] = 'h33;
    first.set_value_array(source_values); source_values[1] = 'h99;
    returned_values = new[1]; returned_values[0] = 'hff; first.get_value_array(returned_values);
    $display("UT: copied size %0d values %0h %0h %0h", returned_values.size(), returned_values[0],
    returned_values[1], returned_values[2]);
    returned_values[0] = 'haa;
    $display("UT: independent internal %0h source %0h", first.get_value(0), source_values[1]);
    source_values = new[0]; first.set_value_array(source_values);
    first.get_value_array(returned_values);
    $display("UT: empty internal %0d returned %0d", first.get_value_size(), returned_values.size());
    first.set_value_size(1);
    $display("UT: regrown size %0d value %0h", first.get_value_size(), first.get_value());

    $finish;
  end

endmodule
