/*
:name: test_factory_unknown_component_name_reports_an_error_and_returns_null_with_a_registered_control
:description: factory unknown component name reports an error and returns null with a registered control
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.3.1.5 8.3.1.3 6.6.3.2 6.6.5 10.7.2.3.1 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_factory_unknown_component_name_reports_an_error_and_returns_null_with_a_registered_control.expected
*/
// What it checks:
// 1. An unrecognized component type name generates an error.
// 2. An unrecognized component type name returns null.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 8.3.1.5 (UVM-FACTORY-AUDIT-UNKNOWN-COMPONENT-ERROR) gives
//    rule 1 above. Setup: A fresh factory first creates a registered original
//    control, then is asked for a distinct unregistered name while an ERROR
//    observer is active. Expected: An ERROR is observed during the unknown
//    request.
// 2. 1800.2-2020 8.3.1.5 (UVM-FACTORY-AUDIT-UNKNOWN-COMPONENT-NULL) gives rule
//    2 above. Setup: A fresh factory first creates a registered original
//    control, then is asked for a distinct unregistered name while an ERROR
//    observer is active. Expected: The unknown result is null; the earlier
//    registered control establishes successful valid creation.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module
  test_factory_unknown_component_name_reports_an_error_and_returns_null_with_a_registered_control;
  import uvm_pkg::*;
  class error_probe extends uvm_report_catcher;
    int errors=0;
    function new();super.new("error_probe55");endfunction
    virtual function action_e catch();
      if (get_severity()==UVM_ERROR) errors++;
      return CAUGHT;
    endfunction
  endclass
  class original extends uvm_component;
    function new(string name,uvm_component parent);super.new(name,parent);endfunction
  endclass
  typedef uvm_component_registry#(original,"registered_component55") registry;
  initial begin
    automatic uvm_default_factory factory=new();
    automatic error_probe observer=new();
    uvm_component missing,control;
    int before_errors;
    bit error_seen;
    factory.register(registry::get());uvm_report_cb::add(null,observer);
    // Run the valid control first; no post-error registry state is assumed.
    control=factory.create_component_by_name("registered_component55","ctx55","control55",null);
    before_errors=observer.errors;
    missing=factory.create_component_by_name("unregistered_component55","ctx55","missing55",null);
    error_seen=observer.errors>before_errors;
    $display("UT: unknown_component error %0d null_result %0d registered_control %0d",
      error_seen,missing==null,control!=null && control.get_name()=="control55");
    uvm_report_cb::delete(null,observer);$finish;
  end
endmodule
