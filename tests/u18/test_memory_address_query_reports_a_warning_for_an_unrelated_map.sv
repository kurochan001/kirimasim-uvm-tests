/*
:name: test_memory_address_query_reports_a_warning_for_an_unrelated_map
:description: memory address query reports a warning for an unrelated map
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6.4.16 18.6.4.16 18.6.3.2 18.2.3.4 6.6.5 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_address_query_reports_a_warning_for_an_unrelated_map.expected
*/
// What it checks:
// The selected memory address query warns for a map that does not contain the
// memory.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.6.4.16 (UVM-MEM-FIFO-AUDIT-MEM-INVALID-ADDRESS-WARNING) gives
// the rule above. Setup: Observe a valid explicit address first, then gate a
// catcher around one unrelated-map call in a fresh independent fixture.
// Expected: At least one UVM_WARNING is reported without an exact
// ID/text/count requirement.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_memory_address_query_reports_a_warning_for_an_unrelated_map;
  import uvm_pkg::*;
  class block_type extends uvm_reg_block;
    function new(); super.new("owner63",UVM_NO_COVERAGE); endfunction
  endclass
  class reports extends uvm_report_catcher;
    bit gated=0;
    int warnings=0;
    virtual function action_e catch();
      if (gated && get_severity()==UVM_WARNING) begin warnings++; return CAUGHT; end
      return THROW;
    endfunction
  endclass

  // The unspecified scalar result of an invalid address/offset is ignored.
  // Valid-map observations precede the invalid call; recovery is not assumed.
  initial begin
    block_type owner;
    uvm_mem memory;
    uvm_reg_map member_map,other_map;
    reports probe;
    uvm_reg_addr_t ignored;
    owner=new(); owner.configure(); memory=new("memory63",4,16); memory.configure(owner);
    member_map=owner.create_map("member63",'h100,2,UVM_LITTLE_ENDIAN);
    other_map=owner.create_map("other63",'h500,2,UVM_LITTLE_ENDIAN);
    member_map.add_mem(memory,'h20); owner.lock_model(); probe=new();
    uvm_report_cb::add(null,probe);
    $display("UT: valid_memory_map address %0d",memory.get_address(0,member_map)=='h120);
    probe.gated=1;
    ignored=memory.get_address(0,other_map);
    probe.gated=0;
    $display("UT: invalid_memory_map warning %0d",probe.warnings>0);
    $finish;
  end
endmodule
