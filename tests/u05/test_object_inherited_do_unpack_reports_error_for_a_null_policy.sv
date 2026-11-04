/*
:name: test_object_inherited_do_unpack_reports_error_for_a_null_policy
:description: Inherited do_unpack receives null directly and generates an error
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.11.2 6.6.3.2 6.6.5 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_inherited_do_unpack_reports_error_for_a_null_policy.expected
*/
module test_object_inherited_do_unpack_reports_error_for_a_null_policy;
  import uvm_pkg::*;
  class original_object extends uvm_object;
    function new(string name=""); super.new(name); endfunction
    virtual function string get_type_name(); return "original_object61"; endfunction
    virtual function uvm_object create(string name="");
      original_object result;
      result=new(name); return result;
    endfunction
  endclass
  class reports extends uvm_report_catcher;
    bit gated=0;
    int errors=0;
    virtual function action_e catch();
      if (gated && (get_severity()==UVM_ERROR || get_severity()==UVM_FATAL)) begin
        errors++; return CAUGHT;
      end
      return THROW;
    endfunction
  endclass
  initial begin
    original_object value;
    uvm_object view;
    reports catcher;
    value=new("value61"); view=value; catcher=new();
    uvm_report_cb::add(null,catcher); catcher.gated=1;
    view.do_unpack(null); catcher.gated=0;
    $display("UT: null_hook error %0d",catcher.errors>0);
    uvm_report_cb::delete(null,catcher);
    $finish;
  end
  initial begin #100; $fatal(1,"base-class fixture watchdog expired"); end
endmodule
