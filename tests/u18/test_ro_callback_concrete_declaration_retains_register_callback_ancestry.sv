/*
:name: test_ro_callback_concrete_declaration_retains_register_callback_ancestry
:description: The predefined protection callback is concrete and extends the register callback facade
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.11.4.1 18.11 18.11.1 18.11.2.2 18.11.2.4 18.4.2.1 18.4.2.2 18.4.4.9 18.4.4.10 18.5.3.2 18.5.5.9 18.5.5.10 18.4.6.2 18.1.2.1 18.1.2.2 18.2.3.6 18.2.5.2 19.4.2.1 19.4.2.2.1 19.4.2.3 19.5.2.4 19.5.2.5 19.5.2.6 19.5.2.7 19.5.2.8 6.6.3.2 6.6.5 D.4.5.1 D.4.5.7 10.7.2.5 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers67/protection_fixture67.svh
:expected_exit: 0
:expected_stdout: @test_ro_callback_concrete_declaration_retains_register_callback_ancestry.expected
*/
// Original providers and selected callback contracts; no physical HDL.
module test_ro_callback_concrete_declaration_retains_register_callback_ancestry;
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
        uvm_reg_read_only_cbs subject=new();
        uvm_reg_cbs facade;
        uvm_callback callback_view;
        $display("UT: protection_ro_declaration facade %0d callback %0d",
          $cast(facade,subject) && facade==subject,
          $cast(callback_view,subject) && callback_view==subject);
      end
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("trial");
  initial begin #200;$fatal(1,"original67 watchdog");end
endmodule
