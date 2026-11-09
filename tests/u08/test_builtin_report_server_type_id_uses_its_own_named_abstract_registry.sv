/*
:name: test_builtin_report_server_type_id_uses_its_own_named_abstract_registry
:description: builtin report server type id uses its own named abstract registry
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.2.2 6.5.1.1 8.2.5.2.1 1800-2023 6.18
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_builtin_report_server_type_id_uses_its_own_named_abstract_registry.expected
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
module test_builtin_report_server_type_id_uses_its_own_named_abstract_registry;
  import uvm_pkg::*;
  initial begin
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
