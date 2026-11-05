/*
:name: test_recorder_link_window_freed_closed_right_parent_child
:description: Recorder link lifetime with right recorder freed after close (IEEE 1800.2-2020 Section 16.4.4).
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.4.4 7.1.5 7.1.6.4 7.2.5.1 16.4.4.2 16.4.4.3 16.4.4.4 16.4.4.6 16.4.5.1 7.3.2.2.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_recorder_link_window_freed_closed_right_parent_child.expected
:files: helpers72/recorder_link_fixture72.svh
*/
// Stop inside the original catcher on ERROR/FATAL, without assuming recovery.
// No diagnostic wording, count, or post-error backend behavior is fixed.
module test_recorder_link_window_freed_closed_right_parent_child;
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
    right.close(31); right.free(41);
    relation = uvm_parent_child_link::get_link(left, right, "relation72");
    $display("UT: recorder_link_state left %0d %0d %0d right %0d %0d %0d",
             left.is_open(), left.is_closed(), left.get_handle() != 0,
             right.is_open(), right.is_closed(), right.get_handle() != 0);
    uvm_report_cb::add(null, watcher);
    watcher.active = 1; watcher.terminal_error = 1;
    db.establish_link(relation);
    $display("UT: recorder_link_error present 0");
    $finish;
  end
endmodule
