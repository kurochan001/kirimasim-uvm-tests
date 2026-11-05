/*
:name: test_field_configured_rand_modes_follow_the_predefined_writable_policy_exceptions
:description: Predefined access policies gate the rand_mode of the public field value
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.3.2 18.5.2 18.5.4.6 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.4.2.1 18.4.2.2 18.4.6.2 18.2.3.6 18.2.5.2 19.4.2.2.1 19.4.2.1 19.4.2.3 19.5.2.4 19.5.2.5 19.5.2.6 19.5.2.7 19.5.2.8 19.1.1.2.9 1800-2023 6.21 8.20 8.21 18.5
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers66/field_access_fixture66.svh
:expected_exit: 0
:expected_stdout: @test_field_configured_rand_modes_follow_the_predefined_writable_policy_exceptions.expected
*/
// Original access-provider storage is distinct from physical HDL evidence.
module test_field_configured_rand_modes_follow_the_predefined_writable_policy_exceptions;
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
        automatic string names[12]='{"RW","WRC","WRS","WO","W1","WO1",
          "RO","RC","RS","W1C","W0S","W1T"};
        automatic bit writable_ok=1,restricted_ok=1,explicit_off=1;
        foreach(names[i])begin
          automatic register_probe66 owner=new();
          automatic uvm_reg_field enabled=new("enabled66"),disabled=new("disabled66");
          enabled.configure(owner,4,0,names[i],0,0,0,1,0);
          disabled.configure(owner,4,4,names[i],0,0,0,0,0);
          if(i<6)writable_ok &= enabled.value.rand_mode()==1;
          else restricted_ok &= enabled.value.rand_mode()==0;
          explicit_off &= disabled.value.rand_mode()==0;
        end
        $display("UT: field_rand_modes writable %0d restricted %0d explicit_off %0d",
          writable_ok,restricted_ok,explicit_off);
      end

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("trial");
  initial begin #200;$fatal(1,"original66 watchdog");end
endmodule
