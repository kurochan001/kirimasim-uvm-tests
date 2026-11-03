/*
:name: test_abstract_component_registry_without_override_reports_error_and_returns_null
:description: factory invocation of an unimplemented abstract registry reports an error and returns null (8.2.5.1.2)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.2.5.1.2 8.2.5 8.3.2.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_abstract_component_registry_without_override_reports_error_and_returns_null.expected
*/
// The pinned callback formats parent.get_full_name() without checking null.
// Retain the required error and null return for a parentless request.
module test_abstract_component_registry_without_override_reports_error_and_returns_null;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  virtual class subject extends uvm_component;
    static int made = 0;
    function new(string name, uvm_component parent); super.new(name, parent); made++; endfunction
    pure virtual function int marker();
  endclass
  typedef uvm_abstract_component_registry#(subject, "subject_proxy") registry;
  typedef uvm_abstract_component_registry#(subject) default_registry;
  class fallback extends subject;
    `uvm_component_utils(fallback)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function int marker(); return 1; endfunction
  endclass
  class selected extends subject;
    `uvm_component_utils(selected)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function int marker(); return 2; endfunction
  endclass
  class owner_type extends uvm_component;
    function new(string name); super.new(name, null); endfunction
  endclass
  class report_probe extends uvm_report_catcher;
    int errors = 0;
    function new(); super.new("probe"); endfunction
    function action_e catch();
      if (get_severity() == UVM_ERROR) begin errors++; return CAUGHT; end
      return THROW;
    endfunction
  endclass
  // Enter through the public factory boundary, not a guessed callback overload.
  initial begin
    automatic uvm_default_factory fresh = new();
    automatic registry proxy = registry::get();
    automatic report_probe probe = new();
    automatic uvm_component created;
    fresh.register(proxy); uvm_report_cb::add(null, probe);
    created = fresh.create_component_by_type(proxy, "", "unimplemented", null);
    $display("UT: error_reported %0d returned_null %0d constructors %0d",
             probe.errors > 0, created == null, subject::made);
    uvm_report_cb::delete(null, probe);
    $finish;
  end
endmodule
