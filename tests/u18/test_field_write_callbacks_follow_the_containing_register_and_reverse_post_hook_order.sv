/*
:name: test_field_write_callbacks_follow_the_containing_register_and_reverse_post_hook_order
:description: Containing register and field methods and registered callbacks retain the declared operation order
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.6.1 18.5.6.2 18.5.6.3 18.5.6.4 18.4.8.1 18.4.8.2 18.4.8.3 18.4.8.4 18.11 18.11.1 18.11.2.1 18.11.2.2 18.11.2.3 18.11.2.4 18.11.2.5 D.4.5.1 D.4.5.7 10.7.2.3.1 10.7.2.3.3 18.5.5.9 18.5.5.10 18.5.3.2 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.4.2.1 18.4.2.2 18.4.6.2 18.2.3.6 18.2.5.2 19.4.2.2.1 19.4.2.1 19.4.2.3 19.5.2.4 19.5.2.5 19.5.2.6 19.5.2.7 19.5.2.8 19.1.1.2.9 1800-2023 6.21 8.20 8.21 18.5
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers66/field_access_fixture66.svh
:expected_exit: 0
:expected_stdout: @test_field_write_callbacks_follow_the_containing_register_and_reverse_post_hook_order.expected
*/
// What it checks:
// 1. Field pre-write work follows containing-register pre-write callbacks.
// 2. Field post-write work follows containing-register post-write callbacks.
// 3. Containing-register pre-write work precedes the contained field
//    callbacks.
// 4. Each selected registered pre-write callback follows its associated
//    method.
// 5. Each selected registered post-write callback precedes its associated
//    method.
// 6. A register callback extension supports selected register and field
//    delivery.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.5.6.1
//    (UVM-FIELD-ACCESS-AUDIT-FIELD-PREWRITE-AFTER-REGISTER) gives rule 1
//    above. Setup: Invoke the containing-register API once with both typed
//    callback registrations; record inherited-method, registered-callback and
//    original-transfer markers. Expected: The selected complete trace is
//    RCFDBcrdf: register method/callback, field method/callback, transfer,
//    register callback/method, field callback/method.
// 2. 1800.2-2020 18.5.6.2
//    (UVM-FIELD-ACCESS-AUDIT-FIELD-POSTWRITE-AFTER-REGISTER) gives rule 2
//    above. Setup: Invoke the containing-register API once with both typed
//    callback registrations; record inherited-method, registered-callback and
//    original-transfer markers. Expected: The selected post suffix is crdf:
//    register callback/method, then field callback/method; the full input
//    retains its separate pre-order expectation.
// 3. 1800.2-2020 18.4.8.1
//    (UVM-FIELD-ACCESS-AUDIT-REGISTER-PREWRITE-BEFORE-FIELD) gives rule 3
//    above. Setup: Invoke the containing-register API once with both typed
//    callback registrations; record inherited-method, registered-callback and
//    original-transfer markers. Expected: The selected complete trace is
//    RCFDBcrdf: register method/callback, field method/callback, transfer,
//    register callback/method, field callback/method.
// 4. 1800.2-2020 18.11.2.2
//    (UVM-FIELD-ACCESS-AUDIT-REGISTERED-PRE-AFTER-METHOD) gives rule 4 above.
//    Setup: Invoke the containing-register API once with both typed callback
//    registrations; record inherited-method, registered-callback and
//    original-transfer markers. Expected: The selected complete trace is
//    RCFDBcrdf: register method/callback, field method/callback, transfer,
//    register callback/method, field callback/method.
// 5. 1800.2-2020 18.11.2.3
//    (UVM-FIELD-ACCESS-AUDIT-REGISTERED-POST-BEFORE-METHOD) gives rule 5
//    above. Setup: Invoke the containing-register API once with both typed
//    callback registrations; record inherited-method, registered-callback and
//    original-transfer markers. Expected: The selected post suffix is crdf:
//    register callback/method, then field callback/method; the full input
//    retains its separate pre-order expectation.
// 6. 1800.2-2020 18.11 (UVM-FIELD-ACCESS-AUDIT-FACADE-REGISTER-FIELD) gives
//    rule 6 above. Setup: Invoke the containing-register API once with both
//    typed callback registrations; record inherited-method,
//    registered-callback and original-transfer markers. Expected: The selected
//    complete trace is RCFDBcrdf: register method/callback, field
//    method/callback, transfer, register callback/method, field
//    callback/method.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original access-provider storage is distinct from physical HDL evidence.
module test_field_write_callbacks_follow_the_containing_register_and_reverse_post_hook_order;
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


      uvm_reg_cb::add(rg,register_cb);uvm_reg_field_cb::add(selected,field_cb);
      trace66="";rg.write(status,'h63,UVM_FRONTDOOR,first_map);
      $display("UT: field_write_order status %0d calls %0d trace %s",
        status==UVM_IS_OK,first_fd.calls,trace66);
      $display("UT: field_write_post_order contract %0d",
        trace66.len()==9 && trace66.substr(5,8)=="crdf");

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("trial");
  initial begin #200;$fatal(1,"original66 watchdog");end
endmodule
