/*
:name: test_field_mirror_check_1_policy_0_gates_comparison_but_refreshes_the_selected_value
:description: Field mirror uses both check gates and refreshes selected original frontdoor data
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.5.13 18.5.5.14 18.5.5.15 18.5.5.17 6.6.3.2 6.6.5 10.7.2.5 18.5.3.2 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.4.2.1 18.4.2.2 18.4.6.2 18.2.3.6 18.2.5.2 19.4.2.2.1 19.4.2.1 19.4.2.3 19.5.2.4 19.5.2.5 19.5.2.6 19.5.2.7 19.5.2.8 19.1.1.2.9 1800-2023 6.21 8.20 8.21 18.5
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers66/field_access_fixture66.svh
:expected_exit: 0
:expected_stdout: @test_field_mirror_check_1_policy_0_gates_comparison_but_refreshes_the_selected_value.expected
*/
// What it checks:
// 1. Field mirror refreshes the selected original read value.
// 2. Field mirror comparison requires both selected check gates.
// 3. The field compare getter retains the selected policy during mirror
//    access.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.5.5.13
//    (UVM-FIELD-ACCESS-AUDIT-MIRROR-CHECK-1-POLICY-0-REFRESH) gives rule 1
//    above. Setup: Select field and operation check settings independently,
//    initialize mirror 0x11 and original frontdoor storage 0x73, and gate a
//    report catcher around the single mirror call. Expected: One original read
//    changes the selected mirror from 0x11 to 0x73.
// 2. 1800.2-2020 18.5.5.13
//    (UVM-FIELD-ACCESS-AUDIT-MIRROR-CHECK-1-POLICY-0-CHECK-GATE) gives rule 2
//    above. Setup: Select field and operation check settings independently,
//    initialize mirror 0x11 and original frontdoor storage 0x73, and gate a
//    report catcher around the single mirror call. Expected: The selected
//    mismatch reports an error exactly when check=1 and policy=0 are both
//    enabled; no ID/text/count is imposed.
// 3. 1800.2-2020 18.5.5.14
//    (UVM-FIELD-ACCESS-AUDIT-MIRROR-CHECK-1-POLICY-0-POLICY-GET) gives rule 3
//    above. Setup: Select field and operation check settings independently,
//    initialize mirror 0x11 and original frontdoor storage 0x73, and gate a
//    report catcher around the single mirror call. Expected: The getter still
//    reports the independently selected check policy after the real read.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original access-provider storage is distinct from physical HDL evidence.
module test_field_mirror_check_1_policy_0_gates_comparison_but_refreshes_the_selected_value;
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
        automatic errors66 watcher=new();
        selected.set_compare(UVM_NO_CHECK);
        first_fd.word='h73;
        uvm_report_cb::add(null,watcher);
        selected.mirror(status,UVM_CHECK,
          UVM_FRONTDOOR,first_map);
        uvm_report_cb::delete(null,watcher);
        $display("UT: field_mirror_check_1_policy_0 read %0d mirror %0d error_gate %0d policy %0d",
          first_fd.calls==1,selected.get_mirrored_value()=='h73,
          (watcher.count>0)==0,
          selected.get_compare()==UVM_NO_CHECK);
      end

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("trial");
  initial begin #200;$fatal(1,"original66 watchdog");end
endmodule
