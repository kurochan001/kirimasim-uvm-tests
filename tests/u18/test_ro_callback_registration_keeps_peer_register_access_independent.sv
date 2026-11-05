/*
:name: test_ro_callback_registration_keeps_peer_register_access_independent
:description: Register-specific protection does not attach to or block an unrelated peer register
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.11.4.2.2 18.11 18.11.1 18.11.2.2 18.11.2.4 18.4.2.1 18.4.2.2 18.4.4.9 18.4.4.10 18.5.3.2 18.5.5.9 18.5.5.10 18.4.6.2 18.1.2.1 18.1.2.2 18.2.3.6 18.2.5.2 19.4.2.1 19.4.2.2.1 19.4.2.3 19.5.2.4 19.5.2.5 19.5.2.6 19.5.2.7 19.5.2.8 6.6.3.2 6.6.5 D.4.5.1 D.4.5.7 10.7.2.5 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers67/protection_fixture67.svh
:expected_exit: 0
:expected_stdout: @test_ro_callback_registration_keeps_peer_register_access_independent.expected
*/
// Original providers and selected callback contracts; no physical HDL.
module test_ro_callback_registration_keeps_peer_register_access_independent;
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
      install67(0);access67(0,1,1,UVM_FRONTDOOR,status,value);
      $display("UT: protection_ro_peer membership %0d allowed %0d errors %0d target %0d",
        members67(0,0,1)==0 && members67(0,1,1)==0 && members67(0,2,1)==0,
        allowed67(0,1,1,UVM_FRONTDOOR,status,value),catcher.errors,transfers67());
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("trial");
  initial begin #200;$fatal(1,"original67 watchdog");end
endmodule
