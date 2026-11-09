/*
:name: test_base_recording_disable_push_manual_marks_108
:description: base recording disable preserves actual push_manual_marks traffic and selected driver-owned transaction marks (IEEE 1800.2-2020 Section 15.3.2.22)
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.3.2.22 15.3.1 5.4.2.13 5.4.2.16 10.2.2.3 10.7.2.3.1 14.2.6.2 14.2.6.3 14.2.3.1 15.6.1 15.6.2 15.6.3.3 13.8.2.1 13.1.7.3 13.1.7.5 5.4.2.4 5.4.2.6 1800-2023 6.21 8.20 8.21 9.4.1 9.4.3
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_base_recording_disable_push_manual_marks_108.expected
:files: helpers108_recording/recording108.svh
*/
// What it checks:
// 1. Transaction begin uses current simulation time when its time argument is
//    zero or omitted.
// 2. Transaction begin triggers its named event in the transaction event pool.
// 3. Transaction end uses current simulation time when its time argument is
//    zero or omitted.
// 4. Transaction end triggers its named event in the transaction event pool.
// 5. The base recording-disable API changes the selected sequencer state
//    without disabling an independent peer.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 5.4.2.4 (UVM-TRANSACTION-BEGIN-ZERO-TIME) gives rule 1 above.
//    Setup: Run the three lifecycle calls at separate positive delays with
//    recording disabled. Also observe explicit zero-time component lifecycle
//    calls made by a real pull/push driver after automatic recording was
//    disabled through the sequencer base API. Expected: The fixture records
//    accept/begin/end times 2, 5 and 9. The transaction time and callback
//    observation equal the driver time captured at the explicit call.
// 2. 1800.2-2020 5.4.2.4 (UVM-TRANSACTION-BEGIN-EVENT) gives rule 2 above.
//    Setup: Acquire the three event handles before running the lifecycle. Also
//    observe explicit zero-time component lifecycle calls made by a real
//    pull/push driver after automatic recording was disabled through the
//    sequencer base API. Expected: Each event becomes on only after its
//    matching lifecycle call. The selected named callback is invoked once for
//    the actual transaction event.
// 3. 1800.2-2020 5.4.2.6 (UVM-TRANSACTION-END-ZERO-TIME) gives rule 3 above.
//    Setup: Run the three lifecycle calls at separate positive delays with
//    recording disabled. Also observe explicit zero-time component lifecycle
//    calls made by a real pull/push driver after automatic recording was
//    disabled through the sequencer base API. Expected: The fixture records
//    accept/begin/end times 2, 5 and 9. The transaction time and callback
//    observation equal the driver time captured at the explicit call.
// 4. 1800.2-2020 5.4.2.6 (UVM-TRANSACTION-END-EVENT) gives rule 4 above.
//    Setup: Acquire the three event handles before running the lifecycle. Also
//    observe explicit zero-time component lifecycle calls made by a real
//    pull/push driver after automatic recording was disabled through the
//    sequencer base API. Expected: Each event becomes on only after its
//    matching lifecycle call. The selected named callback is invoked once for
//    the actual transaction event.
// 5. 1800.2-2020 15.3.2.22 (UVM-SQR-AUDIT-BASE-RECORDING-DISABLE) gives rule 5
//    above. Setup: Use the selected original fixture, declared type arguments,
//    public endpoint/base views and linked stage observations. Requests
//    satisfy the grant precondition before send_request and response IDs are
//    copied from the actual request. Additionally disable twice through a base
//    handle before first connected pull/push traffic, with selected driver
//    marks omitted or explicitly supplied and an independent peer completing
//    its own request. Also disable the selected base before real pull/push
//    traffic while recording storage is explicitly enabled and an independent
//    peer remains in default automatic mode. Expected: The base
//    recording-disable API changes the selected sequencer state without
//    disabling an independent peer. Added no-mark inputs retain captured
//    transaction begin/end times and deliver no named begin/end notification.
//    Added manual inputs still accept exactly one explicit component begin/end
//    mark at the captured driver times. Both selected and peer traffic retain
//    the original request and block completion until their delayed driver work
//    returns; the added profiles do not assert peer automatic recording
//    counts. The added enabled-backend inputs deliver both original requests
//    but invoke no selected request custom-record hook or named property-field
//    hook; the peer still records its own distinct stable property through the
//    original backend.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Base disable precedes both worker starts and the first pull-driver request.
// The selected driver alone optionally calls component begin_tr/end_tr.
// Peer automatic event counts are DIAG108 only, not a default-policy oracle.
// No alias substitutes for the separately known printed base query API.
module test_base_recording_disable_push_manual_marks_108;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam bit PUSH108=1, MANUAL108=1;
  `include "recording108.svh"
  initial run_test("t");
  initial begin #80; $fatal(1,"recording108 traffic watchdog expired"); end
endmodule
