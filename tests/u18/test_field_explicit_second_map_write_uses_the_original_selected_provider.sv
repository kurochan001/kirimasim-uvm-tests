/*
:name: test_field_explicit_second_map_write_uses_the_original_selected_provider
:description: An explicitly supplied field map selects its original configured access provider
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.5.9 18.5.6.2 18.5.6.3 18.5.6.4 18.4.8.1 18.4.8.2 18.4.8.3 18.4.8.4 18.11 18.11.1 18.11.2.1 18.11.2.2 18.11.2.3 18.11.2.4 18.11.2.5 D.4.5.1 D.4.5.7 10.7.2.3.1 10.7.2.3.3 18.5.5.10 18.5.3.2 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.4.2.1 18.4.2.2 18.4.6.2 18.2.3.6 18.2.5.2 19.4.2.2.1 19.4.2.1 19.4.2.3 19.5.2.4 19.5.2.5 19.5.2.6 19.5.2.7 19.5.2.8 19.1.1.2.9 1800-2023 6.21 8.20 8.21 18.5
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers66/field_access_fixture66.svh
:expected_exit: 0
:expected_stdout: @test_field_explicit_second_map_write_uses_the_original_selected_provider.expected
*/
// Original access-provider storage is distinct from physical HDL evidence.
module test_field_explicit_second_map_write_uses_the_original_selected_provider;
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



      selected.write(status,'h63,UVM_FRONTDOOR,second_map);
      $display("UT: field_explicit_second_map_write contract %0d",
        status==UVM_IS_OK &&
          first_fd.calls==0 &&
          second_fd.calls==1 &&
          second_fd.word=='h63);

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("trial");
  initial begin #200;$fatal(1,"original66 watchdog");end
endmodule
