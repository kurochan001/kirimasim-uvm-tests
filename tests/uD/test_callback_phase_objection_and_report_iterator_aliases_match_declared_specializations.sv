/*
:name: test_callback_phase_objection_and_report_iterator_aliases_match_declared_specializations
:description: callback phase objection and report iterator aliases match declared specializations
:tags: uD uvm
:type: simulation
:lrm: 1800.2-2020 D.4.1 D.4.2 D.4.4 10.7.2.1 D.1.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_callback_phase_objection_and_report_iterator_aliases_match_declared_specializations.expected
*/
module test_callback_phase_objection_and_report_iterator_aliases_match_declared_specializations;
  import uvm_pkg::*;
  // The called generic function checks both implicit class conversions.
  // Null equality is a completion marker, not a callback-behavior oracle.
  class alias_probe #(type EXACT=uvm_object,type ALIAS=uvm_object);
    static function EXACT through_alias(ALIAS value);
      EXACT exact_view;
      ALIAS back_view;
      exact_view=value; back_view=exact_view;
      return back_view;
    endfunction
  endclass
  initial begin
    automatic uvm_phase_cb_pool alias_0=null;
    automatic uvm_callbacks#(uvm_phase,uvm_phase_cb) exact_0=
      alias_probe#(uvm_callbacks#(uvm_phase,uvm_phase_cb),
                   uvm_phase_cb_pool)::through_alias(alias_0);
    automatic uvm_objection_cbs_t alias_1=null;
    automatic uvm_callbacks#(uvm_objection,uvm_objection_callback) exact_1=
      alias_probe#(uvm_callbacks#(uvm_objection,uvm_objection_callback),
                   uvm_objection_cbs_t)::through_alias(alias_1);
    automatic uvm_report_cb_iter alias_2=null;
    automatic uvm_callback_iter#(uvm_report_object,uvm_report_catcher) exact_2=
      alias_probe#(uvm_callback_iter#(uvm_report_object,uvm_report_catcher),
                   uvm_report_cb_iter)::through_alias(alias_2);
    automatic uvm_callback_iter alias_3=null;
    automatic uvm_callback_iter#(uvm_object,uvm_callback) exact_3=
      alias_probe#(uvm_callback_iter#(uvm_object,uvm_callback),
                   uvm_callback_iter)::through_alias(alias_3);
    $display("UT: declared_callback_alias uvm_phase_cb_pool compatible %0d",exact_0==alias_0);
    $display("UT: declared_callback_alias uvm_objection_cbs_t compatible %0d",exact_1==alias_1);
    $display("UT: declared_callback_alias uvm_report_cb_iter compatible %0d",exact_2==alias_2);
    $display("UT: declared_callback_alias uvm_callback_iter compatible %0d",exact_3==alias_3);
    $finish;
  end
endmodule
