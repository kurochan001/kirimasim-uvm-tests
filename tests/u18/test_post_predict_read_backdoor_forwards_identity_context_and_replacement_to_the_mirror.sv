/*
:name: test_post_predict_read_backdoor_forwards_identity_context_and_replacement_to_the_mirror
:description: Post-predict observes the actual field and prediction context before changing predicted state
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.11.2.6 18.5.5.17 18.5.5.1 18.5.5.2 18.5.5.3 D.4.5.7 10.7.2.3.1 18.11 18.11.1 18.11.2.2 18.11.2.4 18.4.2.1 18.4.2.2 18.4.4.9 18.4.4.10 18.5.3.2 18.5.5.9 18.5.5.10 18.4.6.2 18.1.2.1 18.1.2.2 18.2.3.6 18.2.5.2 19.4.2.1 19.4.2.2.1 19.4.2.3 19.5.2.4 19.5.2.5 19.5.2.6 19.5.2.7 19.5.2.8 6.6.3.2 6.6.5 D.4.5.1 10.7.2.5 1800-2023 6.21 8.20 8.21 21.2.1
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers67/protection_fixture67.svh
:expected_exit: 0
:expected_stdout: @test_post_predict_read_backdoor_forwards_identity_context_and_replacement_to_the_mirror.expected
*/
// What it checks:
// 1. Successful read/write prediction supplies the selected field, previous
//    value and actual prediction context.
// 2. A post-predict value change modifies the predicted mirror.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.11.2.6
//    (UVM-PROTECTION-AUDIT-POST-PREDICT-READ-BACKDOOR-CONTEXT) gives rule 1
//    above. Setup: Post-predict observes the actual field and prediction
//    context before changing predicted state. Fresh original sixteen-bit RW
//    models, two contained byte fields and independent frontdoor/backdoor
//    storage; exact message text/count and physical HDL are not prescribed.
//    Select the low byte field, previous mirror 0xAD, supplied value 0x39,
//    UVM_PREDICT_READ, UVM_BACKDOOR and exact second_map handle. Expected: The
//    callback sees the exact field, kind, path, map and previous/latest
//    values.
// 2. 1800.2-2020 18.11.2.6
//    (UVM-PROTECTION-AUDIT-POST-PREDICT-READ-BACKDOOR-REPLACEMENT) gives rule
//    2 above. Setup: Post-predict observes the actual field and prediction
//    context before changing predicted state. Fresh original sixteen-bit RW
//    models, two contained byte fields and independent frontdoor/backdoor
//    storage; exact message text/count and physical HDL are not prescribed.
//    Select the low byte field, previous mirror 0xAD, supplied value 0x39,
//    UVM_PREDICT_READ, UVM_BACKDOOR and exact second_map handle. Expected: The
//    selected mirror and desired value become the callback replacement.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original providers and selected callback contracts; no physical HDL.
module test_post_predict_read_backdoor_forwards_identity_context_and_replacement_to_the_mirror;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "protection_fixture67.svh"
  class trial extends fixture67;
    `uvm_component_utils(trial)
    function new(string name,uvm_component parent);super.new(name,parent);endfunction
    virtual task run_phase(uvm_phase phase);
      uvm_status_e status;
      uvm_reg_data_t value;
      phase.raise_objection(this);
      begin
        prediction67 cb=new();
        bit ok;
        uvm_reg_field_cb::add(low_field[0],cb);
        ok=low_field[0].predict('h39,-1,UVM_PREDICT_READ,UVM_BACKDOOR,second_map);
        $display("UT: %s success %0d calls %0d context %0d data %0d model %0d",
          "post_predict_read_backdoor",
          ok,cb.calls,cb.seen_field==low_field[0] && cb.seen_kind==UVM_PREDICT_READ &&
          cb.seen_path==UVM_BACKDOOR && cb.seen_map==second_map,
          cb.seen_previous=='had && cb.seen_value=='h39,
          low_field[0].get()=='h63 && low_field[0].get_mirrored_value()=='h63);
        $display("UT: post_predict_read_backdoor_storage transfers %0d original %0d peer %0d",
          transfers67(),storage67(),high_field[0].get_mirrored_value()=='h11);
      end
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("trial");
  initial begin #200;$fatal(1,"original67 watchdog");end
endmodule
