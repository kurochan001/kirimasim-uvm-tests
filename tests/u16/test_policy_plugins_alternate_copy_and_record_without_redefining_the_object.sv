/*
:name: test_policy_plugins_alternate_copy_and_record_without_redefining_the_object
:description: one object alternates copier subtypes and fresh recorder subtypes (IEEE 1800.2-2020 Section 16)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16 5.3.7.1 5.3.7.2 5.3.8.1 5.3.8.2 7.1.4.1 7.2.5.1 16.4.2.1 16.4.6.2 16.4.6.4 16.4.7.5 16.4.7.7 16.6.3 16.6.4.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers74/policy_plugin_fixture74.svh
:expected_exit: 0
:expected_stdout: @test_policy_plugins_alternate_copy_and_record_without_redefining_the_object.expected
*/
// What it checks:
// 1. Object copy uses the supplied copier, or the default when none is
//    supplied.
// 2. The virtual recording hook receives each supplied recorder policy.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 5.3.8.1 (UVM-OBJECT-COPY-POLICY) gives rule 1 above. Setup:
//    Install a counting default copier, supply another explicitly and repeat a
//    copy after changing data. An additional fixture alternates explicit
//    copier subtypes A/B/A with fresh recorder operations between copies and
//    source bytes 31/52/73 hexadecimal. Expected: Each selected policy is
//    invoked for its operation and copies current scalar data. The additional
//    selected copier receives exact lhs/rhs handles, the other observer stays
//    idle, and each current byte reaches the target.
// 2. 1800.2-2020 5.3.7.2 (UVM-BASE-AUDIT-RECORD-HOOK) gives rule 2 above.
//    Setup: Call the original hook through an object base with two legally
//    opened original recorders. An additional outer record input uses fresh
//    legally opened A/B/A recorder subtypes after alternating copies and
//    captures the selected eight-bit field through the public recording API.
//    Expected: Policy identity and successive payload values match while the
//    first policy remains unchanged. The additional object hook and backend
//    field hook use the current recorder and observe copied values 31/52/73
//    hexadecimal.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Copy updates data, not the class definition. Each record uses a fresh
// opened policy; no repeated-recorder history or external database claim.
module test_policy_plugins_alternate_copy_and_record_without_redefining_the_object;
  import uvm_pkg::*;
  `include "policy_plugin_fixture74.svh"
  initial begin
    automatic subject74 source = new("source");
    automatic subject74 target = new("target");
    automatic copier_a74 ca = new;
    automatic copier_b74 cb = new;
    automatic database74 db = new;
    uvm_tr_stream stream;
    uvm_recorder opened;
    recorder74 recorder;
    copier74 copier, other;
    stream = db.open_stream("stream74");
    if (stream == null) $fatal(1, "original stream setup failed");
    ca.set_recursion_policy(UVM_DEEP); cb.set_recursion_policy(UVM_DEEP);
    for (int step = 0; step < 3; step++) begin
      source.payload = 'h31 + step * 'h21;
      copier = (step == 1) ? copier74'(cb) : copier74'(ca);
      other = (step == 1) ? copier74'(ca) : copier74'(cb);
      ca.called = 0; cb.called = 0;
      target.copy(source, copier);
      $display("UT: copy74 %0d policy %0b idle %0b arguments %0b value %02h",
               step, copier.called, !other.called,
               copier.last_lhs == target && copier.last_rhs == source, target.payload);
      opened = stream.open_recorder((step == 1) ? "B" : "A", 0, "packet74");
      if (!$cast(recorder, opened) || recorder == null)
        $fatal(1, "original recorder setup failed");
      recorder.set_recursion_policy(UVM_DEEP);
      target.record(recorder);
      $display("UT: record74 %0d policy %0b style %s value %02h",
               step, target.last_recorder == recorder && recorder.field_seen,
               recorder.label, recorder.captured);
    end
    $finish;
  end
endmodule
