/*
:name: test_builtin_abstract_components_type_id_uses_the_required_registry_specialization
:description: builtin abstract components type id uses the required registry specialization
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.2.2 13.1.1 13.3.1 13.5.1 8.2.3.1 8.2.4.1 8.2.5.1.1 8.2.5.2.1 1800-2023 6.18 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_builtin_abstract_components_type_id_uses_the_required_registry_specialization.expected
*/
// What it checks:
// Selected non-parameterized virtual components use named abstract component
// registries.
//
// How the expected output follows from the standard:
// 1800.2-2020 8.2.2 (UVM-FACTORY-AUDIT-TYPE-ID-ABSTRACT-COMPONENTS) gives the
// rule above. Setup: uvm_component, uvm_env and uvm_monitor; each named
// receiver uses its exact class and printed class-name parameter. Expected:
// The declared alias and required registry are statically assignable in both
// directions, retain one nonnull singleton, and report the explicit class name
// or default <unknown> as applicable.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_builtin_abstract_components_type_id_uses_the_required_registry_specialization;
  import uvm_pkg::*;
  initial begin
    begin
      typedef uvm_component represented;
      typedef uvm_abstract_component_registry#(represented,"uvm_component") required_registry;
      typedef represented::type_id supplied_registry;
      supplied_registry alias_view;
      required_registry typed;
      uvm_object_wrapper wrapper;
      alias_view=represented::type_id::get();
      typed=alias_view;alias_view=typed;wrapper=typed;
      $display("UT: type_id uvm_component registry_compatible %0d singleton %0d named %0d",
        typed!=null && alias_view==typed,wrapper==represented::type_id::get(),
        typed.get_type_name()=="uvm_component");
    end
    begin
      typedef uvm_env represented;
      typedef uvm_abstract_component_registry#(represented,"uvm_env") required_registry;
      typedef represented::type_id supplied_registry;
      supplied_registry alias_view;
      required_registry typed;
      uvm_object_wrapper wrapper;
      alias_view=represented::type_id::get();
      typed=alias_view;alias_view=typed;wrapper=typed;
      $display("UT: type_id uvm_env registry_compatible %0d singleton %0d named %0d",
        typed!=null && alias_view==typed,wrapper==represented::type_id::get(),
        typed.get_type_name()=="uvm_env");
    end
    begin
      typedef uvm_monitor represented;
      typedef uvm_abstract_component_registry#(represented,"uvm_monitor") required_registry;
      typedef represented::type_id supplied_registry;
      supplied_registry alias_view;
      required_registry typed;
      uvm_object_wrapper wrapper;
      alias_view=represented::type_id::get();
      typed=alias_view;alias_view=typed;wrapper=typed;
      $display("UT: type_id uvm_monitor registry_compatible %0d singleton %0d named %0d",
        typed!=null && alias_view==typed,wrapper==represented::type_id::get(),
        typed.get_type_name()=="uvm_monitor");
    end
    $finish;
  end
endmodule
