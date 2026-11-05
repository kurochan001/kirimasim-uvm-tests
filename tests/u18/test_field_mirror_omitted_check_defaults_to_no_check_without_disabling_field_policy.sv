/*
:name: test_field_mirror_omitted_check_defaults_to_no_check_without_disabling_field_policy
:description: Omitting mirror check skips comparison while retaining the field compare policy
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.5.13 18.5.5.14 18.5.5.15 6.6.3.2 6.6.5 10.7.2.5 18.5.3.2 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.4.2.1 18.4.2.2 18.4.6.2 18.2.3.6 18.2.5.2 19.4.2.2.1 19.4.2.1 19.4.2.3 19.5.2.4 19.5.2.5 19.5.2.6 19.5.2.7 19.5.2.8 19.1.1.2.9 1800-2023 6.21 8.20 8.21 18.5
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers66/field_access_fixture66.svh
:expected_exit: 0
:expected_stdout: @test_field_mirror_omitted_check_defaults_to_no_check_without_disabling_field_policy.expected
*/
// Original access-provider storage is distinct from physical HDL evidence.
module test_field_mirror_omitted_check_defaults_to_no_check_without_disabling_field_policy;
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
        selected.set_compare();first_fd.word='h73;
        uvm_report_cb::add(null,watcher);
        selected.mirror(status,.path(UVM_FRONTDOOR),.map(first_map));
        uvm_report_cb::delete(null,watcher);
        $display("UT: field_mirror_default mirror %0d no_error %0d policy %0d read %0d",
          selected.get_mirrored_value()=='h73,watcher.count==0,
          selected.get_compare()==UVM_CHECK,first_fd.calls==1);
      end

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("trial");
  initial begin #200;$fatal(1,"original66 watchdog");end
endmodule
