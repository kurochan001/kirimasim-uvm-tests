/*
:name: test_callback_duplicate_registration_reports_warning
:description: adding an already registered callback reports a warning (IEEE 1800.2-2020 Section 10.7.2.3.1)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.7.2.3.1 6.5.1.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_callback_duplicate_registration_reports_warning.expected
*/
// Observe the required warning without prescribing the treatment of
// a duplicate entry or a particular diagnostic identifier.

module test_callback_duplicate_registration_reports_warning;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class user_callback extends uvm_callback;
    `uvm_object_utils(user_callback)
    int calls = 0;
    function new(string name="user_callback");
      super.new(name);
      void'(callback_mode(1));
    endfunction
    virtual function void hit();
      calls++;
      $display("UT: hit %s", get_name());
    endfunction
  endclass
  class agent extends uvm_component;
    `uvm_component_utils(agent)
    `uvm_register_cb(agent, user_callback)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void fire();
      `uvm_do_callbacks(agent, user_callback, hit())
    endfunction
  endclass
  typedef uvm_callbacks#(agent, user_callback) pool_t;

  initial begin
    automatic agent context_value = new("context_value", null);
    automatic user_callback value = new("value");
    automatic uvm_root root = uvm_root::get();
    automatic uvm_report_server server = uvm_report_server::get_server();
    int warnings;
    root.set_report_severity_action(UVM_WARNING, UVM_DISPLAY);
    pool_t::add(context_value, value);
    warnings = server.get_severity_count(UVM_WARNING);
    pool_t::add(context_value, value);
    $display("UT: duplicate_warned %0d", server.get_severity_count(UVM_WARNING) > warnings);
    $finish;
  end
endmodule
