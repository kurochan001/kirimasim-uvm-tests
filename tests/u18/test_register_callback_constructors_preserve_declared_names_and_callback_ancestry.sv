/*
:name: test_register_callback_constructors_preserve_declared_names_and_callback_ancestry
:description: Register callback construction retains declared default names and callback base identity
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.11.2.1 18.11.1 18.11 18.5.3.2 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.4.2.1 18.4.2.2 18.4.6.2 18.2.3.6 18.2.5.2 19.4.2.2.1 19.4.2.1 19.4.2.3 19.5.2.4 19.5.2.5 19.5.2.6 19.5.2.7 19.5.2.8 19.1.1.2.9 1800-2023 6.21 8.20 8.21 18.5
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers66/field_access_fixture66.svh
:expected_exit: 0
:expected_stdout: @test_register_callback_constructors_preserve_declared_names_and_callback_ancestry.expected
*/
// What it checks:
// 1. Register callback construction preserves default, explicit and empty
//    names.
// 2. The concrete register callback extends uvm_callback.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.11.2.1 (UVM-FIELD-ACCESS-AUDIT-CALLBACK-CONSTRUCTOR) gives
//    rule 1 above. Setup: Construct fresh uvm_reg_cbs instances directly
//    without imposing a derived factory-registration requirement. Expected:
//    Default uvm_reg_cbs and supplied names are retained by concrete
//    instances.
// 2. 1800.2-2020 18.11.1 (UVM-FIELD-ACCESS-AUDIT-CALLBACK-ANCESTRY) gives rule
//    2 above. Setup: Construct fresh uvm_reg_cbs instances directly without
//    imposing a derived factory-registration requirement. Expected: Implicit
//    base assignment preserves the exact named callback handle.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original access-provider storage is distinct from physical HDL evidence.
module test_register_callback_constructors_preserve_declared_names_and_callback_ancestry;
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
        automatic uvm_reg_cbs omitted=new(),named=new("named66"),empty=new("");
        automatic uvm_callback base=named;
        $display("UT: callback_constructor default %0d named %0d empty %0d ancestry %0d",
          omitted.get_name()=="uvm_reg_cbs",named.get_name()=="named66",
          empty.get_name()=="",base==named);
      end

      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("trial");
  initial begin #200;$fatal(1,"original66 watchdog");end
endmodule
