/*
:name: test_queue_out_of_range_object_get_warns_returns_null_and_preserves_the_entry
:description: object queue get beyond its end warns and returns null without consuming the stored handle (11.3.2.4)
:tags: u11 uvm
:type: simulation
:lrm: 1800.2-2020 11.3.2.4 11.3.2.5 11.3.2.11 6.6.3.2 D.4.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_queue_out_of_range_object_get_warns_returns_null_and_preserves_the_entry.expected
*/
module test_queue_out_of_range_object_get_warns_returns_null_and_preserves_the_entry;
  import uvm_pkg::*;
  class item extends uvm_object;
    int value;
    function new(string name, int number); super.new(name); value = number; endfunction
  endclass
  class warning_probe extends uvm_report_catcher;
    int warnings = 0;
    int errors = 0;
    function new(); super.new("probe"); endfunction
    virtual function action_e catch();
      if (get_severity() == UVM_WARNING) begin warnings++; return CAUGHT; end
      if (get_severity() == UVM_ERROR) begin errors++; return CAUGHT; end
      return THROW;
    endfunction
  endclass
  initial begin
    automatic uvm_queue#(item) queue = new("queue");
    automatic item stored = new("stored", 41);
    automatic warning_probe probe = new();
    item missing;
    queue.push_back(stored);
    uvm_report_cb::add(null, probe);
    missing = queue.get(1);
    uvm_report_cb::delete(null, probe);
    $display("UT: warnings %0d errors %0d null %0d retained %0d size %0d",
             probe.warnings, probe.errors, missing == null, queue.get(0) == stored, queue.size());
    $finish;
  end
endmodule
