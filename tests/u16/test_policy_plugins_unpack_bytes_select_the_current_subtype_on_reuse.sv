/*
:name: test_policy_plugins_unpack_bytes_select_the_current_subtype_on_reuse
:description: bytes object unpack selects the supplied policy subtype on reuse (IEEE 1800.2-2020 Section 16)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16 5.3.10.1 5.3.10.2 5.3.11.1 5.3.11.2 16.5.3.1 16.5.3.2 16.5.3.3 16.5.4.9 16.5.4.17 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers74/policy_plugin_fixture74.svh
:expected_exit: 0
:expected_stdout: @test_policy_plugins_unpack_bytes_select_the_current_subtype_on_reuse.expected
*/
// What it checks:
// 1. Each object unpacking entry point uses the supplied packer for its
//    operation.
// 2. Before processing fields, object unpacking assigns policy state using the
//    matching stream-type method.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 5.3.11.1 (UVM-OBJECT-UNPACK-EXPLICIT-POLICY) gives rule 1
//    above. Setup: Same unchanged original subject class; explicit packer
//    subtypes A/B/A and eight-bit payloads 11/22/33 hexadecimal, separately
//    for bit/byte/int/longint streams. Observer flags identify the selected
//    hook and typed state method, with monotonic original callback ticks
//    recording the selected order. Expected: The selected subtype receives the
//    typed assignment and object hook, while the other policy stays idle at
//    each A/B/A selection.
// 2. 1800.2-2020 5.3.11.1 (UVM-OBJECT-UNPACK-STREAM-TYPE) gives rule 2 above.
//    Setup: Same unchanged original subject class; explicit packer subtypes
//    A/B/A and eight-bit payloads 11/22/33 hexadecimal, separately for
//    bit/byte/int/longint streams. Observer flags identify the selected hook
//    and typed state method, with monotonic original callback ticks recording
//    the selected order. Expected: The matching setter is called before the
//    custom field unpacking hook, and the selected original value is restored.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Streams are opaque and paired with the same policy and stream type.
// The roundtrip guards data, not an independent encoding or decoder proof.
module test_policy_plugins_unpack_bytes_select_the_current_subtype_on_reuse;
  import uvm_pkg::*;
  `include "policy_plugin_fixture74.svh"
  initial begin
    automatic subject74 source = new("source");
    automatic subject74 target = new("target");
    automatic packer_a74 a = new;
    automatic packer_b74 b = new;
    packer74 picked, other;
    byte unsigned stream[];
    int count;
    bit selected, other_idle, size_match, ordered;
    for (int step = 0; step < 3; step++) begin
      source.payload = 'h11 * (step + 1);
      picked = (step == 1) ? packer74'(b) : packer74'(a);
      other = (step == 1) ? packer74'(a) : packer74'(b);
      a.clear_observers(); b.clear_observers();
      count = source.pack_bytes(stream, picked);
      a.clear_observers(); b.clear_observers();
      target.payload = 0;
      void'(target.unpack_bytes(stream, picked));
      selected = target.last_unpack == picked && picked.set_seen[1];
      other_idle = other.idle();
      ordered = picked.set_tick[1] > 0 && target.unpack_tick > picked.set_tick[1];
      $display("UT: unpack74 bytes %0d policy %0b idle %0b order %0b value %02h src %02h",
               step, selected, other_idle, ordered, target.payload, source.payload);
    end
    $finish;
  end
endmodule
