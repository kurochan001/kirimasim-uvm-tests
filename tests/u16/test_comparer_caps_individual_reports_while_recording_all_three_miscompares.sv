/*
:name: test_comparer_caps_individual_reports_while_recording_all_three_miscompares
:description: message limiting does not discard recorded comparison failures (IEEE 1800.2-2020 Section 16.3.5.1)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.3.5.1 16.3.3.2 16.3.3.7 16.3.3.9 16.3.5.2 16.3.5.3 5.3.7.1 5.3.7.2 6.6.3.2 6.6.5 D.4.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_comparer_caps_individual_reports_while_recording_all_three_miscompares.expected
*/
// Catch only reports emitted inside do_compare; framework rollups lie
// outside that window. Compare every field without short-circuiting.
module test_comparer_caps_individual_reports_while_recording_all_three_miscompares;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  bit comparison_window = 0;
  class message_probe extends uvm_report_catcher;
    int messages = 0;
    function new(); super.new("probe"); endfunction
    virtual function action_e catch();
      if (comparison_window) begin messages++; return CAUGHT; end
      return THROW;
    endfunction
  endclass
  class record_value extends uvm_object;
    `uvm_object_utils(record_value)
    int values[3];
    function new(string name="record_value");
      super.new(name);
      foreach (values[i]) values[i] = 0;
    endfunction
    virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      record_value other;
      bit same;
      if (!$cast(other, rhs)) $fatal(1, "unexpected comparison fixture type");
      same = 1;
      comparison_window = 1;
      foreach (values[i])
        same &= comparer.compare_field_int($sformatf("field%0d", i), values[i],
                                           other.values[i], 32, UVM_DEC);
      comparison_window = 0;
      return same;
    endfunction
  endclass

  initial begin
    record_value first;
    record_value second;
    uvm_comparer comparer;
    message_probe probe;
    bit matched;
    first = new("first");
    second = new("second");
    foreach (second.values[i]) second.values[i] = 11 + i;
    comparer = new();
    probe = new();
    comparer.set_verbosity(UVM_NONE);
    comparer.set_severity(UVM_INFO);
    comparer.set_show_max(1);
    uvm_report_cb::add(null, probe);
    matched = first.compare(second, comparer);
    $display("UT: matched %0d failures %0d within_cap %0d", matched, comparer.get_result(),
             probe.messages <= 1);
    probe.messages = 0;
    comparer.set_show_max(5);
    matched = first.compare(second, comparer);
    $display("UT: control matched %0d failures %0d reports %0d", matched,
             comparer.get_result(), probe.messages);
    uvm_report_cb::delete(null, probe);
    $finish;
  end
endmodule
