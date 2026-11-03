/*
:name: test_printed_report_callback_typedef_name_matches_the_declared_specialization
:description: printed report callback typedef name matches the declared specialization
:tags: uD uvm
:type: simulation
:lrm: 1800.2-2020 D.4.3 10.7.2.1 D.1.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printed_report_callback_typedef_name_matches_the_declared_specialization.expected
*/
module test_printed_report_callback_typedef_name_matches_the_declared_specialization;
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
    automatic uvm_report_db alias_0=null;
    automatic uvm_callbacks#(uvm_report_object,uvm_report_catcher) exact_0=
      alias_probe#(uvm_callbacks#(uvm_report_object,uvm_report_catcher),
                   uvm_report_db)::through_alias(alias_0);
    $display("UT: declared_callback_alias uvm_report_db compatible %0d",exact_0==alias_0);
    $finish;
  end
endmodule
