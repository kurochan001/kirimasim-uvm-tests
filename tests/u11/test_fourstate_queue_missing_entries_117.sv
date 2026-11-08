/*
:name: test_fourstate_queue_missing_entries_117
:description: a queue of a four-state type returns all X with a warning for an out-of-range get and for pops from an empty queue (IEEE 1800.2-2020 Section 11.3.2.4)
:tags: u11 uvm
:type: simulation
:lrm: 1800.2-2020 11.3.2.4 11.3.2.1 11.3.2.5 11.3.2.8 11.3.2.9 11.3.2.11 6.6.5 D.4.4 1800-2023 7.4.5 5.7.1 6.3.1 6.11 11.4.5 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_fourstate_queue_missing_entries_117.expected
*/
// Table 7-1 of 1800-2023 gives all X for a missing four-state entry. An out-of-
// range get must warn, return all X and leave the size unchanged; stored values
// with X and Z bits must be returned exactly; pops from the emptied queue must
// warn and return all X. The expectation comes from the cited clauses; a two-
// state simulator cannot represent X or Z, so this case is spec-only. Only the
// lines that begin with "UT: " are compared.
module test_fourstate_queue_missing_entries_117;
  import uvm_pkg::*;

  class warning_probe117 extends uvm_report_catcher;
    int warnings;

    virtual function action_e catch();
      if (get_severity() == UVM_WARNING) begin
        warnings++;
        return CAUGHT;
      end
      return THROW;
    endfunction
  endclass

  initial begin
    automatic uvm_queue #(logic [7:0]) queue = new("logic_queue117");
    automatic warning_probe117 probe = new;
    logic [7:0] beyond;
    logic [7:0] front;
    logic [7:0] back;
    logic [7:0] empty_front;
    logic [7:0] empty_back;
    int prior_warnings;
    queue.push_back(8'b1x0z_10xz);
    queue.push_back(8'bz0x1_1z0x);
    uvm_report_cb::add(null, probe);
    beyond = queue.get(2);
    $display("UT: beyond x %0d warned %0d size %0d", beyond === 8'bxxxx_xxxx,
             probe.warnings > 0, queue.size());
    $display("UT: stored same %0d %0d", queue.get(0) === 8'b1x0z_10xz,
             queue.get(1) === 8'bz0x1_1z0x);
    front = queue.pop_front();
    back = queue.pop_back();
    prior_warnings = probe.warnings;
    empty_front = queue.pop_front();
    $display("UT: popped same %0d %0d empty_front x %0d warned %0d", front === 8'b1x0z_10xz,
             back === 8'bz0x1_1z0x, empty_front === 8'bxxxx_xxxx, probe.warnings > prior_warnings);
    prior_warnings = probe.warnings;
    empty_back = queue.pop_back();
    $display("UT: empty_back x %0d warned %0d", empty_back === 8'bxxxx_xxxx,
             probe.warnings > prior_warnings);
    uvm_report_cb::delete(null, probe);
    $finish;
  end
endmodule
