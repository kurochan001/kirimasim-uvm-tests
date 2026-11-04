/*
:name: test_domain_constructor_preserves_names_domain_type_and_phase_object_views
:description: domain constructor preserves names domain type and phase object views
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.4.2.1 9.4.1 9.3.1.3.2 5.3.4.2 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_domain_constructor_preserves_names_domain_type_and_phase_object_views.expected
*/
module test_domain_constructor_preserves_names_domain_type_and_phase_object_views;
  import uvm_pkg::*;
  initial begin
    automatic uvm_domain first=new("first_domain53");
    automatic uvm_domain second=new("second_domain53");
    uvm_phase phase_view;
    uvm_object object_view;
    uvm_domain back;
    phase_view=first;object_view=phase_view;
    $display("UT: domain_new name %0d domain_type %0d distinct %0d object %0d",
      first.get_name()=="first_domain53",first.get_phase_type()==UVM_PHASE_DOMAIN,
      first!=second,$cast(back,object_view) && back==first);
    $finish;
  end
endmodule
