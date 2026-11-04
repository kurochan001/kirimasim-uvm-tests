/*
:name: test_builtin_objects_type_id_uses_the_required_registry_specialization
:description: builtin objects type id uses the required registry specialization
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.2.2 14.1.1 12.3.4.2.1 8.2.3.1 8.2.4.1 8.2.5.1.1 8.2.5.2.1 1800-2023 6.18 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_builtin_objects_type_id_uses_the_required_registry_specialization.expected
*/
module test_builtin_objects_type_id_uses_the_required_registry_specialization;
  import uvm_pkg::*;
  initial begin
    begin
      typedef uvm_sequence_item represented;
      typedef uvm_object_registry#(represented,"uvm_sequence_item") required_registry;
      typedef represented::type_id supplied_registry;
      supplied_registry alias_view;
      required_registry typed;
      uvm_object_wrapper wrapper;
      alias_view=represented::type_id::get();
      typed=alias_view;alias_view=typed;wrapper=typed;
      $display("UT: type_id uvm_sequence_item registry_compatible %0d singleton %0d named %0d",
        typed!=null && alias_view==typed,wrapper==represented::type_id::get(),
        typed.get_type_name()=="uvm_sequence_item");
    end
    begin
      typedef uvm_tlm_generic_payload represented;
      typedef uvm_object_registry#(represented,"uvm_tlm_generic_payload") required_registry;
      typedef represented::type_id supplied_registry;
      supplied_registry alias_view;
      required_registry typed;
      uvm_object_wrapper wrapper;
      alias_view=represented::type_id::get();
      typed=alias_view;alias_view=typed;wrapper=typed;
      $display(
        "UT: type_id uvm_tlm_generic_payload registry_compatible %0d singleton %0d named %0d",
        typed!=null && alias_view==typed,wrapper==represented::type_id::get(),
        typed.get_type_name()=="uvm_tlm_generic_payload");
    end
    $finish;
  end
endmodule
