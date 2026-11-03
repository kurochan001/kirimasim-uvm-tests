/*
:name: test_sequence_unlock_without_a_default_sequencer_reports_fatal
:description: ownership API reports a fatal when neither explicit nor default sequencer exists (IEEE 1800.2-2020 Section 14.2.5.7)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.5.7 14.1.2.5 6.6.3.2 6.6 D.4.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: nonzero
:expected_stderr_regex: fixture observed required UVM_FATAL
:expected_stdout: @test_sequence_unlock_without_a_default_sequencer_reports_fatal.expected
*/
// End through a testbench fatal after observing original UVM_FATAL severity.
// The declared nonzero exit and unique fixture sentinel avoid post-fatal
// continuation and do not constrain the library diagnostic or its exit code.

module test_sequence_unlock_without_a_default_sequencer_reports_fatal;
  import uvm_pkg::*;
  class empty_sequence extends uvm_sequence#(uvm_sequence_item);
    function new(); super.new("sequence"); endfunction
    virtual task body(); endtask
  endclass
  class fatal_probe extends uvm_report_catcher;
    function new(); super.new("probe"); endfunction
    virtual function action_e catch();
      if (get_severity() == UVM_FATAL) begin
        $display("UT: missing_default fatal 1");
        $fatal(1, "fixture observed required UVM_FATAL");
        return CAUGHT;
      end
      return THROW;
    endfunction
  endclass
  fatal_probe probe;
  initial begin
    automatic empty_sequence seq = new();
    probe = new();
    uvm_report_cb::add(null, probe);
    $display("UT: default_is_null %0d", seq.get_sequencer() == null);
    seq.unlock();
    $display("UT: missing_default fatal 0");
    $finish;
  end
  initial begin #20; $fatal(1, "missing-default watchdog expired"); end
endmodule
