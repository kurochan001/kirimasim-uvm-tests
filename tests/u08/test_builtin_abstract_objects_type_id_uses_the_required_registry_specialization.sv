/*
:name: test_builtin_abstract_objects_type_id_uses_the_required_registry_specialization
:description: builtin abstract objects type id uses the required registry specialization
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.2.2 5.4.1 14.2.1 6.5.1.1 8.2.3.1 8.2.4.1 8.2.5.1.1 8.2.5.2.1 1800-2023 6.18 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_builtin_abstract_objects_type_id_uses_the_required_registry_specialization.expected
*/
// What it checks:
// Selected non-parameterized abstract objects declare named abstract object
// registries.
//
// How the expected output follows from the standard:
// 1800.2-2020 8.2.2 (UVM-FACTORY-AUDIT-TYPE-ID-ABSTRACT-OBJECTS) gives the
// rule above. Setup: uvm_transaction, uvm_sequence_base and uvm_report_server
// are checked through required named registry receivers. Expected: The
// declared alias and required registry are statically assignable in both
// directions, retain one nonnull singleton, and report the explicit class name
// or default <unknown> as applicable.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_builtin_abstract_objects_type_id_uses_the_required_registry_specialization;
  import uvm_pkg::*;
  initial begin
    begin
      typedef uvm_transaction represented;
      typedef uvm_abstract_object_registry#(represented,"uvm_transaction") required_registry;
      typedef represented::type_id supplied_registry;
      supplied_registry alias_view;
      required_registry typed;
      uvm_object_wrapper wrapper;
      alias_view=represented::type_id::get();
      typed=alias_view;alias_view=typed;wrapper=typed;
      $display("UT: type_id uvm_transaction registry_compatible %0d singleton %0d named %0d",
        typed!=null && alias_view==typed,wrapper==represented::type_id::get(),
        typed.get_type_name()=="uvm_transaction");
    end
    begin
      typedef uvm_sequence_base represented;
      typedef uvm_abstract_object_registry#(represented,"uvm_sequence_base") required_registry;
      typedef represented::type_id supplied_registry;
      supplied_registry alias_view;
      required_registry typed;
      uvm_object_wrapper wrapper;
      alias_view=represented::type_id::get();
      typed=alias_view;alias_view=typed;wrapper=typed;
      $display("UT: type_id uvm_sequence_base registry_compatible %0d singleton %0d named %0d",
        typed!=null && alias_view==typed,wrapper==represented::type_id::get(),
        typed.get_type_name()=="uvm_sequence_base");
    end
    begin
      typedef uvm_report_server represented;
      typedef uvm_abstract_object_registry#(represented,"uvm_report_server") required_registry;
      typedef represented::type_id supplied_registry;
      supplied_registry alias_view;
      required_registry typed;
      uvm_object_wrapper wrapper;
      alias_view=represented::type_id::get();
      typed=alias_view;alias_view=typed;wrapper=typed;
      $display("UT: type_id uvm_report_server registry_compatible %0d singleton %0d named %0d",
        typed!=null && alias_view==typed,wrapper==represented::type_id::get(),
        typed.get_type_name()=="uvm_report_server");
    end
    $finish;
  end
endmodule
