/*
:name: test_environment_omitted_constructor_arguments_use_env_name_and_implicit_root_parent
:description: environment omitted constructor arguments use env name and implicit root parent
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.3.2 13.1.2.1 F.4.1.4.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_environment_omitted_constructor_arguments_use_env_name_and_implicit_root_parent.expected
*/
// What it checks:
// 1. Omitting the environment name selects env.
// 2. Omitting the environment parent registers it under the implicit root.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 13.3.2 (UVM-COMPONENT-AUDIT-ENV-DEFAULT-NAME) gives rule 1
//    above. Setup: Use the selected original concrete component subtypes,
//    legal unique names, declared public types and linked observations.
//    Construct the hierarchy before phasing where phase callbacks are
//    observed. Expected: Omitting the environment name selects env.
// 2. 1800.2-2020 13.3.2 (UVM-COMPONENT-AUDIT-ENV-DEFAULT-PARENT) gives rule 2
//    above. Setup: Use the selected original concrete component subtypes,
//    legal unique names, declared public types and linked observations.
//    Construct the hierarchy before phasing where phase callbacks are
//    observed. Expected: Omitting the environment parent registers it under
//    the implicit root.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_environment_omitted_constructor_arguments_use_env_name_and_implicit_root_parent;
  import uvm_pkg::*;
  class default_environment extends uvm_env; endclass
  initial begin
    automatic default_environment value=new();
    automatic uvm_coreservice_t service=uvm_coreservice_t::get();
    $display("UT: environment_defaults name %0d parent %0d registered %0d",
             value.get_name()=="env",value.get_parent()==service.get_root(),
             service.get_root().get_child("env")==value);
    $finish;
  end
endmodule
