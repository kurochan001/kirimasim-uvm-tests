/*
:name: test_queue_insert_shifts_valid_entries_and_rejects_size_and_larger_indexes
:description: queue insertion preserves order and warns without mutation at or above size (IEEE 1800.2-2020 Section 11.3.2.6)
:tags: u11 uvm
:type: simulation
:lrm: 1800.2-2020 11.3.2.6 11.3.2.4 11.3.2.5 11.3.2.11 6.6.3.2 6.6.5 D.4.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_queue_insert_shifts_valid_entries_and_rejects_size_and_larger_indexes.expected
*/
// What it checks:
// 1. Queue insert places the new item at a valid existing index and shifts
//    later entries.
// 2. An insertion at or above queue size warns and leaves the queue unchanged.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 11.3.2.6 (UVM-QUEUE-INSERT-VALID-INDEX) gives rule 1 above.
//    Setup: Insert at an interior index and then at the front of a nonempty
//    queue. Expected: The queue grows in the observed order 5, 10, 20, 30
//    without warnings.
// 2. 1800.2-2020 11.3.2.6 (UVM-QUEUE-INSERT-OUT-OF-RANGE) gives rule 2 above.
//    Setup: Call insert at exactly size and at a larger positive index after
//    valid insertions. Expected: Two warnings are observed and the four stored
//    values remain unchanged.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_queue_insert_shifts_valid_entries_and_rejects_size_and_larger_indexes;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  typedef bit [31:0] word_t;
  class warning_probe extends uvm_report_catcher;
    int warnings = 0;
    function new(); super.new("probe"); endfunction
    virtual function action_e catch();
      if (get_severity() == UVM_WARNING) begin warnings++; return CAUGHT; end
      return THROW;
    endfunction
  endclass

  initial begin
    automatic uvm_queue#(word_t) queue_value = new("queue_value");
    automatic warning_probe probe = new();
    uvm_report_cb::add(null, probe);
    queue_value.push_back(10); queue_value.push_back(30);
    queue_value.insert(1, 20); queue_value.insert(0, 5);
    $display("UT: inserted size %0d values %0d %0d %0d %0d warnings %0d", queue_value.size(),
             queue_value.get(0), queue_value.get(1), queue_value.get(2), queue_value.get(3),
                 probe.warnings);
    queue_value.insert(queue_value.size(), 99); queue_value.insert(99, 88);
    $display("UT: rejected warnings %0d size %0d values %0d %0d %0d %0d", probe.warnings,
             queue_value.size(), queue_value.get(0), queue_value.get(1), queue_value.get(2),
                 queue_value.get(3));
    uvm_report_cb::delete(null, probe);
    $finish;
  end

endmodule
