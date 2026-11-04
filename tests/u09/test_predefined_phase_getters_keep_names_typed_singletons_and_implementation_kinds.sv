/*
:name: test_predefined_phase_getters_keep_names_typed_singletons_and_implementation_kinds
:description: predefined phase getters keep names typed singletons and implementation kinds
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.8 9.3.1.3.2 9.8.1.1 9.8.1.2 9.8.1.3 9.8.1.4 9.8.1.5 9.8.1.6 9.8.1.7 9.8.1.8 9.8.1.9 9.8.2.1 9.8.2.2 9.8.2.3 9.8.2.4 9.8.2.5 9.8.2.6 9.8.2.7 9.8.2.8 9.8.2.9 9.8.2.10 9.8.2.11 9.8.2.12 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_predefined_phase_getters_keep_names_typed_singletons_and_implementation_kinds.expected
*/
// One matrix fixture, not twenty-one independent fixtures or full delegates.
module test_predefined_phase_getters_keep_names_typed_singletons_and_implementation_kinds;
  import uvm_pkg::*;
  initial begin
    begin
      uvm_build_phase typed;
      uvm_phase base_view;
      typed=uvm_build_phase::get();base_view=typed;
      $display("UT: predefined build name %0d singleton %0d implementation %0d",
        typed.get_name()=="build",typed==uvm_build_phase::get(),
        base_view.get_phase_type()==UVM_PHASE_IMP);
    end
    begin
      uvm_connect_phase typed;
      uvm_phase base_view;
      typed=uvm_connect_phase::get();base_view=typed;
      $display("UT: predefined connect name %0d singleton %0d implementation %0d",
        typed.get_name()=="connect",typed==uvm_connect_phase::get(),
        base_view.get_phase_type()==UVM_PHASE_IMP);
    end
    begin
      uvm_end_of_elaboration_phase typed;
      uvm_phase base_view;
      typed=uvm_end_of_elaboration_phase::get();base_view=typed;
      $display("UT: predefined end_of_elaboration name %0d singleton %0d implementation %0d",
        typed.get_name()=="end_of_elaboration",typed==uvm_end_of_elaboration_phase::get(),
        base_view.get_phase_type()==UVM_PHASE_IMP);
    end
    begin
      uvm_start_of_simulation_phase typed;
      uvm_phase base_view;
      typed=uvm_start_of_simulation_phase::get();base_view=typed;
      $display("UT: predefined start_of_simulation name %0d singleton %0d implementation %0d",
        typed.get_name()=="start_of_simulation",typed==uvm_start_of_simulation_phase::get(),
        base_view.get_phase_type()==UVM_PHASE_IMP);
    end
    begin
      uvm_run_phase typed;
      uvm_phase base_view;
      typed=uvm_run_phase::get();base_view=typed;
      $display("UT: predefined run name %0d singleton %0d implementation %0d",
        typed.get_name()=="run",typed==uvm_run_phase::get(),
        base_view.get_phase_type()==UVM_PHASE_IMP);
    end
    begin
      uvm_extract_phase typed;
      uvm_phase base_view;
      typed=uvm_extract_phase::get();base_view=typed;
      $display("UT: predefined extract name %0d singleton %0d implementation %0d",
        typed.get_name()=="extract",typed==uvm_extract_phase::get(),
        base_view.get_phase_type()==UVM_PHASE_IMP);
    end
    begin
      uvm_check_phase typed;
      uvm_phase base_view;
      typed=uvm_check_phase::get();base_view=typed;
      $display("UT: predefined check name %0d singleton %0d implementation %0d",
        typed.get_name()=="check",typed==uvm_check_phase::get(),
        base_view.get_phase_type()==UVM_PHASE_IMP);
    end
    begin
      uvm_report_phase typed;
      uvm_phase base_view;
      typed=uvm_report_phase::get();base_view=typed;
      $display("UT: predefined report name %0d singleton %0d implementation %0d",
        typed.get_name()=="report",typed==uvm_report_phase::get(),
        base_view.get_phase_type()==UVM_PHASE_IMP);
    end
    begin
      uvm_final_phase typed;
      uvm_phase base_view;
      typed=uvm_final_phase::get();base_view=typed;
      $display("UT: predefined final name %0d singleton %0d implementation %0d",
        typed.get_name()=="final",typed==uvm_final_phase::get(),
        base_view.get_phase_type()==UVM_PHASE_IMP);
    end
    begin
      uvm_pre_reset_phase typed;
      uvm_phase base_view;
      typed=uvm_pre_reset_phase::get();base_view=typed;
      $display("UT: predefined pre_reset name %0d singleton %0d implementation %0d",
        typed.get_name()=="pre_reset",typed==uvm_pre_reset_phase::get(),
        base_view.get_phase_type()==UVM_PHASE_IMP);
    end
    begin
      uvm_reset_phase typed;
      uvm_phase base_view;
      typed=uvm_reset_phase::get();base_view=typed;
      $display("UT: predefined reset name %0d singleton %0d implementation %0d",
        typed.get_name()=="reset",typed==uvm_reset_phase::get(),
        base_view.get_phase_type()==UVM_PHASE_IMP);
    end
    begin
      uvm_post_reset_phase typed;
      uvm_phase base_view;
      typed=uvm_post_reset_phase::get();base_view=typed;
      $display("UT: predefined post_reset name %0d singleton %0d implementation %0d",
        typed.get_name()=="post_reset",typed==uvm_post_reset_phase::get(),
        base_view.get_phase_type()==UVM_PHASE_IMP);
    end
    begin
      uvm_pre_configure_phase typed;
      uvm_phase base_view;
      typed=uvm_pre_configure_phase::get();base_view=typed;
      $display("UT: predefined pre_configure name %0d singleton %0d implementation %0d",
        typed.get_name()=="pre_configure",typed==uvm_pre_configure_phase::get(),
        base_view.get_phase_type()==UVM_PHASE_IMP);
    end
    begin
      uvm_configure_phase typed;
      uvm_phase base_view;
      typed=uvm_configure_phase::get();base_view=typed;
      $display("UT: predefined configure name %0d singleton %0d implementation %0d",
        typed.get_name()=="configure",typed==uvm_configure_phase::get(),
        base_view.get_phase_type()==UVM_PHASE_IMP);
    end
    begin
      uvm_post_configure_phase typed;
      uvm_phase base_view;
      typed=uvm_post_configure_phase::get();base_view=typed;
      $display("UT: predefined post_configure name %0d singleton %0d implementation %0d",
        typed.get_name()=="post_configure",typed==uvm_post_configure_phase::get(),
        base_view.get_phase_type()==UVM_PHASE_IMP);
    end
    begin
      uvm_pre_main_phase typed;
      uvm_phase base_view;
      typed=uvm_pre_main_phase::get();base_view=typed;
      $display("UT: predefined pre_main name %0d singleton %0d implementation %0d",
        typed.get_name()=="pre_main",typed==uvm_pre_main_phase::get(),
        base_view.get_phase_type()==UVM_PHASE_IMP);
    end
    begin
      uvm_main_phase typed;
      uvm_phase base_view;
      typed=uvm_main_phase::get();base_view=typed;
      $display("UT: predefined main name %0d singleton %0d implementation %0d",
        typed.get_name()=="main",typed==uvm_main_phase::get(),
        base_view.get_phase_type()==UVM_PHASE_IMP);
    end
    begin
      uvm_post_main_phase typed;
      uvm_phase base_view;
      typed=uvm_post_main_phase::get();base_view=typed;
      $display("UT: predefined post_main name %0d singleton %0d implementation %0d",
        typed.get_name()=="post_main",typed==uvm_post_main_phase::get(),
        base_view.get_phase_type()==UVM_PHASE_IMP);
    end
    begin
      uvm_pre_shutdown_phase typed;
      uvm_phase base_view;
      typed=uvm_pre_shutdown_phase::get();base_view=typed;
      $display("UT: predefined pre_shutdown name %0d singleton %0d implementation %0d",
        typed.get_name()=="pre_shutdown",typed==uvm_pre_shutdown_phase::get(),
        base_view.get_phase_type()==UVM_PHASE_IMP);
    end
    begin
      uvm_shutdown_phase typed;
      uvm_phase base_view;
      typed=uvm_shutdown_phase::get();base_view=typed;
      $display("UT: predefined shutdown name %0d singleton %0d implementation %0d",
        typed.get_name()=="shutdown",typed==uvm_shutdown_phase::get(),
        base_view.get_phase_type()==UVM_PHASE_IMP);
    end
    begin
      uvm_post_shutdown_phase typed;
      uvm_phase base_view;
      typed=uvm_post_shutdown_phase::get();base_view=typed;
      $display("UT: predefined post_shutdown name %0d singleton %0d implementation %0d",
        typed.get_name()=="post_shutdown",typed==uvm_post_shutdown_phase::get(),
        base_view.get_phase_type()==UVM_PHASE_IMP);
    end
    $finish;
  end
endmodule
