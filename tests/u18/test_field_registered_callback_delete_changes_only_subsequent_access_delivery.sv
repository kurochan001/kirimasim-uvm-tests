/*
:name: test_field_registered_callback_delete_changes_only_subsequent_access_delivery
:description: Field callback membership or enable changes affect later real access payloads
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.6.1 18.11.2.2 D.4.5.7 10.7.1.2.2 10.7.2.3.1 10.7.2.3.3 18.5.5.9 18.5.3.2 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.4.2.1 18.4.2.2 18.4.6.2 18.2.3.6 18.2.5.2 19.4.2.2.1 19.4.2.1 19.4.2.3 19.5.2.4 19.5.2.5 19.5.2.6 19.5.2.7 19.5.2.8 19.1.1.2.9 1800-2023 6.21 8.20 8.21 18.5
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers66/field_access_fixture66.svh
:expected_exit: 0
:expected_stdout: @test_field_registered_callback_delete_changes_only_subsequent_access_delivery.expected
*/
// Original access-provider storage is distinct from physical HDL evidence.
module test_field_registered_callback_delete_changes_only_subsequent_access_delivery;
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


      begin
        bit first_ok,disabled_ok;
        field_cb.pre_write_change=VALUE66;uvm_reg_field_cb::add(selected,field_cb);
        selected.write(status,'h21,UVM_FRONTDOOR,first_map);
        first_ok=status==UVM_IS_OK && first_fd.word=='h73;
        uvm_reg_field_cb::delete(selected,field_cb);
        selected.write(status,'h21,UVM_FRONTDOOR,first_map);
        disabled_ok=status==UVM_IS_OK && first_fd.word=='h21;
        $display("UT: field_callback_delete first %0d later %0d calls %0d transfers %0d",
          first_ok,disabled_ok,field_cb.pre_writes,first_fd.calls);
      end

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("trial");
  initial begin #200;$fatal(1,"original66 watchdog");end
endmodule
