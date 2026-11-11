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
// What it checks:
// 1. Changing selected field callback enable/membership affects subsequent
//    delivery.
// 2. The field callback convenience type manages the selected
//    field/uvm_reg_cbs pair.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 10.7.2.3.3 (UVM-FIELD-ACCESS-AUDIT-CALLBACK-DELETE) gives
//    rule 1 above. Setup: Register one payload-changing callback, perform a
//    write, disable or delete it, then repeat the same original input write.
//    Expected: The first transfer stores 0x73; the next stores unmodified
//    0x21, with one callback call and two provider transfers.
// 2. 1800.2-2020 D.4.5.7 (UVM-FIELD-ACCESS-AUDIT-FIELD-CALLBACK-ALIAS) gives
//    rule 2 above. Setup: Use the printed field-callback alias to add and
//    delete one original field callback around two real transfers. Expected:
//    Only the registered first transfer is modified; subsequent delivery is
//    absent after deletion.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
