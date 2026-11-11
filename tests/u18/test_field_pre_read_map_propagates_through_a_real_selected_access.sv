/*
:name: test_field_pre_read_map_propagates_through_a_real_selected_access
:description: A selected field hook change propagates through original access-provider storage
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.6.3 18.5.6.1 18.5.6.2 18.5.6.4 18.4.8.1 18.4.8.2 18.4.8.3 18.4.8.4 18.11 18.11.1 18.11.2.1 18.11.2.2 18.11.2.3 18.11.2.4 18.11.2.5 D.4.5.1 D.4.5.7 10.7.2.3.1 10.7.2.3.3 18.5.5.9 18.5.5.10 18.5.3.2 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.4.2.1 18.4.2.2 18.4.6.2 18.2.3.6 18.2.5.2 19.4.2.2.1 19.4.2.1 19.4.2.3 19.5.2.4 19.5.2.5 19.5.2.6 19.5.2.7 19.5.2.8 19.1.1.2.9 1800-2023 6.21 8.20 8.21 18.5
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers66/field_access_fixture66.svh
:expected_exit: 0
:expected_stdout: @test_field_pre_read_map_propagates_through_a_real_selected_access.expected
*/
// What it checks:
// Changing the field pre-read map selects the replacement access route.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.5.6.3 (UVM-FIELD-ACCESS-AUDIT-PRE-READ-MAP) gives the rule
// above. Setup: Set exactly one original method or registered callback change,
// then call the public field read/write API. Route buffers are independent
// testbench controls, not a proof of physical alias coherence. Expected: Only
// the second original frontdoor is called and returns its 0x73.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original access-provider storage is distinct from physical HDL evidence.
module test_field_pre_read_map_propagates_through_a_real_selected_access;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "field_access_fixture66.svh"
  class trial extends fixture66;
    `uvm_component_utils(trial)
    function new(string name,uvm_component parent);super.new(name,parent);endfunction

    virtual task run_phase(uvm_phase phase);
      uvm_status_e status;
      uvm_reg_data_t value;
      phase.raise_objection(this);


      selected.pre_read_change=MAP66;second_fd.word='h73;
      selected.read(status,value,UVM_FRONTDOOR,first_map);
      $display("DETAIL: map status %0d first_calls %0d second_calls %0d value %0h",
        status,first_fd.calls,second_fd.calls,value);
      $display("UT: field_pre_read_map contract %0d",
        status==UVM_IS_OK &&
          value=='h73 &&
          first_fd.calls==0 &&
          second_fd.calls==1);

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("trial");
  initial begin #200;$fatal(1,"original66 watchdog");end
endmodule
