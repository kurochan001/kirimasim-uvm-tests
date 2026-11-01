/*
:name: test_reg_item_invalid_value_indices_warn_without_changing_existing_data
:description: register item out-of-range value access warns and preserves stored values (IEEE 1800.2-2020 Section 19.1.1.2.4)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.1.1.2.4 6.6.3.2 6.6.5 19.1.1.3.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_item_invalid_value_indices_warn_without_changing_existing_data.expected
*/
// The pinned library expands out-of-range writes and omits index warnings.
// Preserve the required warning/ignore behavior with bounded indices 2/3.
// Read and write probes use separate items so expansion cannot mask reads.
// Exercise the descriptor public API directly, without bus or DUT access.
// Undefined initial enum/data values are never observed. UVM_HAS_X here is
// an explicitly assigned status enum, not a four-state data observation.
module test_reg_item_invalid_value_indices_warn_without_changing_existing_data;
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

    automatic warning_probe probe = new();
    automatic uvm_reg_data_t at_count;
    automatic uvm_reg_data_t at_beyond;
    automatic uvm_reg_data_t at_empty;


    first.set_value_size(2); first.set_value('h11, 0); first.set_value('h22, 1);
    uvm_report_cb::add(null, probe);
    peer.set_value_size(2); peer.set_value('h33, 0); peer.set_value('h44, 1);
    at_count = peer.get_value(2); at_beyond = peer.get_value(3);
    first.set_value('hff, 2); first.set_value('hff, 3);
    $display("UT: invalid warnings %0d returned %0h %0h size %0d values %0h %0h", probe.warnings,
    at_count, at_beyond, first.get_value_size(), first.get_value(0), first.get_value(1));
    first.set_value_size(0); peer.set_value_size(0);
    at_empty = peer.get_value(0); first.set_value('haa, 0);
    $display("UT: empty warnings %0d returned %0h size %0d", probe.warnings, at_empty,
    first.get_value_size());
    uvm_report_cb::delete(null, probe);

    $finish;
  end

endmodule
