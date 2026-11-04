/*
:name: test_factory_unknown_object_name_reports_an_error_and_returns_null_with_a_registered_control
:description: factory unknown object name reports an error and returns null with a registered control
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.3.1.5 8.3.1.3 6.6.3.2 6.6.5 10.7.2.3.1 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_factory_unknown_object_name_reports_an_error_and_returns_null_with_a_registered_control.expected
*/
module
  test_factory_unknown_object_name_reports_an_error_and_returns_null_with_a_registered_control;
  import uvm_pkg::*;
  class error_probe extends uvm_report_catcher;
    int errors=0;
    function new();super.new("error_probe55");endfunction
    virtual function action_e catch();
      if (get_severity()==UVM_ERROR) errors++;
      return CAUGHT;
    endfunction
  endclass
  class original extends uvm_object;
    function new(string name="");super.new(name);endfunction
  endclass
  typedef uvm_object_registry#(original,"registered_object55") registry;
  initial begin
    automatic uvm_default_factory factory=new();
    automatic error_probe observer=new();
    uvm_object missing,control;
    int before_errors;
    bit error_seen;
    factory.register(registry::get());uvm_report_cb::add(null,observer);
    // Run the valid control first; no post-error registry state is assumed.
    control=factory.create_object_by_name("registered_object55","ctx55","control55");
    before_errors=observer.errors;
    missing=factory.create_object_by_name("unregistered_object55","ctx55","missing55");
    error_seen=observer.errors>before_errors;
    $display("UT: unknown_object error %0d null_result %0d registered_control %0d",
      error_seen,missing==null,control!=null && control.get_name()=="control55");
    uvm_report_cb::delete(null,observer);$finish;
  end
endmodule
