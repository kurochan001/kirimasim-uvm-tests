/*
:name: test_recorder_link_window_closed_stream_cause_effect
:description: Recorder link lifetime with records closed by their owning stream (IEEE 1800.2-2020 Section 16.4.4).
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.4.4 7.1.5 7.1.6.4 7.2.5.1 16.4.4.2 16.4.4.3 16.4.4.4 16.4.4.6 16.4.5.1 7.2.4.1 7.3.3.2.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_recorder_link_window_closed_stream_cause_effect.expected
:files: helpers72/recorder_link_fixture72.svh
*/
// What it checks:
// Establishing a database link is permitted while endpoint recorders are
// opened and not freed.
//
// How the expected output follows from the standard:
// 1800.2-2020 16.4.4 (UVM-RECORDER-LINK-WINDOW-CLOSED-STREAM-CAUSE-EFFECT)
// gives the rule above. Setup: records closed by their owning stream; use
// original in-memory callbacks and a cause_effect link. Expected: The actual
// database dispatches the exact link once, retaining both recorder endpoints
// without ERROR/FATAL.
// It also supports, as a control, the setup or conditions of
// UVM-RECORDER-LINK-WINDOW-FREED-OTHER-STREAM-CAUSE-EFFECT.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Closed recorders remain linkable until free; only public APIs are used.
module test_recorder_link_window_closed_stream_cause_effect;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "recorder_link_fixture72.svh"
  initial begin
    automatic database72 db = new();
    automatic error_window72 watcher = new();
    stream72 left_stream, right_stream;
    recorder72 left, right, extra;
    uvm_link_base relation;
    if (!db.open_db()) $fatal(1, "original database setup failed");
    left_stream = make_stream72(db, "left_stream72");
    right_stream = left_stream;
    left = make_recorder72(left_stream, "left72");
    right = make_recorder72(right_stream, "right72");
    left_stream.close();
    relation = uvm_cause_effect_link::get_link(left, right, "relation72");
    $display("UT: recorder_link_state left %0d %0d %0d right %0d %0d %0d",
             left.is_open(), left.is_closed(), left.get_handle() != 0,
             right.is_open(), right.is_closed(), right.get_handle() != 0);
    uvm_report_cb::add(null, watcher);
    watcher.active = 1; watcher.terminal_error = 0;
    db.establish_link(relation);
    watcher.active = 0;
    $display("UT: recorder_link_valid calls %0d exact %0d endpoints %0d errors %0d",
             db.link_calls, db.last_link == relation,
             relation.get_lhs() == left && relation.get_rhs() == right,
             watcher.errors);
    $finish;
  end
endmodule
