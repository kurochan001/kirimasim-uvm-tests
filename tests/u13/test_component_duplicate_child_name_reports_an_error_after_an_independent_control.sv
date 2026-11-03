/*
:name: test_component_duplicate_child_name_reports_an_error_after_an_independent_control
:description: component duplicate child name reports an error after an independent control
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.1.2.1 6.6.5 D.4.4 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_duplicate_child_name_reports_an_error_after_an_independent_control.expected
*/
module test_component_duplicate_child_name_reports_an_error_after_an_independent_control;
  import uvm_pkg::*;
  class actor extends uvm_component;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
  endclass
  class error_probe extends uvm_report_catcher;
    virtual function action_e catch();
      if (get_severity() inside {UVM_ERROR,UVM_FATAL}) begin
        $display("UT: duplicate_child_error 1");
        $finish;
        return CAUGHT;
      end
      return THROW;
    endfunction
  endclass
  initial begin
    automatic actor owner=new("valid_parent46",null);
    automatic actor child=new("child46",owner);
    automatic actor parent=new("invalid_parent46",null);
    automatic actor first=new("child46",parent);
    automatic error_probe probe=new();
    actor duplicate;
    $display("UT: unique_child_control %0d",owner.get_child("child46")==child);
    // Stop in our catcher: the invalid constructor need not return or recover.
    uvm_report_cb::add(null,probe); duplicate=new("child46",parent);
    $fatal(1,"missing expected constructor error");
  end
endmodule
