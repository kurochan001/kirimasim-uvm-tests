/*
:name: test_automatic_recording_properties_push_default_109
:description: actual push_default item recording carries original request properties through public recorder hooks (IEEE 1800.2-2020 Section 15.3.2.22)
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.3.2.22 13.1.7.11 13.1.7.12 13.1.7.13 13.1.7.14 5.4.2.9 5.4.2.11 5.3.7.1 5.3.7.2 16.4.6.4 16.4.7.7 16.4.7.8 16.4.2.1 5.7.2.7 5.3.13 F.4.1.4.6 F.4.1.4.7 7.1.3.1 7.1.4.1 7.1.6.1 7.1.6.2 7.1.6.3 7.1.6.4 7.2.5.1 7.2.7.1 7.2.7.2 7.2.7.3 7.2.7.4 16.4.6.2 16.4.7.1 16.4.7.2 16.4.7.3 16.4.7.4 16.4.7.5 16.4.7.6 16.4.7.9 16.4.7.10 16.4.7.11 14.2.3.1 14.2.6.2 14.2.6.3 15.6.1 15.6.2 15.6.3.3 13.8.2.1 1800-2023 6.21 8.20 8.21 9.4.1 9.4.3
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_automatic_recording_properties_push_default_109.expected
:files: helpers109_recording/automatic109.svh
*/
// What it checks:
// Default automatic item recording records the actual enabled request through
// its custom record hook and recorder property API during pull/push execution.
//
// How the expected output follows from the standard:
// 1800.2-2020 15.3.2.22
// (UVM-SEQUENCER-AUTOMATIC-REQUEST-PROPERTY-RECORDING-109) gives the rule
// above. Setup: Use connected pull get_next_item/item_done or push
// req_port.put with a positive-delay gated original driver and one real
// request per sequencer. Enable component recording and original explicit
// transaction streams, binding the same original backend globally and on both
// sequencers. The peer always stays in default automatic mode; the selected
// instance is additionally checked without disable in the positive profiles.
// Keep selected/peer32-bit payloads41/97 stable throughout execution; no
// participant manually calls record/begin/end. Expected: Each non-disabled
// request has at least one custom record-hook invocation and its named
// stable32-bit property reaches the original recorder field hook with its
// declared value,size32 and UVM_DEC. The independent peer provides positive
// recording evidence even when the selected instance is disabled. Neither
// exact repetition counts nor an early/late snapshot rule is inferred from
// automatic recording.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original item data is41/97 and never changes during traffic. Recording is
// enabled through both public component and transaction-stream configuration.
// Neither driver nor coordinator records an item or manually marks
// its lifecycle.
// Only presence and declared property values are checked; DIAG109 exact counts
// have no oracle. No stream name, wire format, handle encoding or event
// time is fixed.
module test_automatic_recording_properties_push_default_109;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam bit PUSH109=1, DISABLE109=0;
  `include "automatic109.svh"
  initial run_test("t");
  initial begin #100; $fatal(1,"automatic109 property watchdog expired"); end
endmodule
