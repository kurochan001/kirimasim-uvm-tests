/*
:name: test_policy_plugins_alternate_print_and_compare_without_redefining_the_object
:description: one object alternates custom printer and comparer policies (IEEE 1800.2-2020 Section 16)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16 5.3.6.2 5.3.6.3 5.3.9.1 5.3.9.2 16.2.3.9 16.2.4.1 16.3.3.2 16.3.4.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers74/policy_plugin_fixture74.svh
:expected_exit: 0
:expected_stdout: @test_policy_plugins_alternate_print_and_compare_without_redefining_the_object.expected
*/
// What it checks:
// 1. Object sprint returns the text emitted by its selected printer.
// 2. The virtual compare hook receives the selected rhs and comparer.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 5.3.6.2 (UVM-OBJECT-SPRINT-EMISSION) gives rule 1 above.
//    Setup: The custom printer captures field inputs and returns a controlled
//    string. An additional unchanged class alternates printer A/B/A with
//    comparisons between prints; custom emit formats differ by subtype.
//    Expected: Captured values match the object and sprint returns captured.
//    The additional fixture returns A:165/B:165/A:165, uses the selected
//    printer and leaves the other observer idle.
// 2. 1800.2-2020 5.3.9.2 (UVM-BASE-AUDIT-COMPARE-HOOK) gives rule 2 above.
//    Setup: Use same-type original objects and compare equal then unequal
//    eight-bit values through a base view. An additional fixture alternates
//    strict and high-nibble-mask comparer subtypes A/B/A between prints on
//    payloads A5/A6 hexadecimal. Expected: The two hook calls retain exact
//    policy identity and return equal/unequal results. The additional hook
//    retains each exact comparer and returns 0/1/0 with the other observer
//    idle and payloads unchanged.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Own printer text and comparison masks define this original fixture.
// Reuse A after B and another operation family; retain the object class.
module test_policy_plugins_alternate_print_and_compare_without_redefining_the_object;
  import uvm_pkg::*;
  `include "policy_plugin_fixture74.svh"
  initial begin
    automatic subject74 value = new("value");
    automatic subject74 peer = new("peer");
    automatic printer_a74 pa = new;
    automatic printer_b74 pb = new;
    automatic comparer_a74 ca = new;
    automatic comparer_b74 cb = new;
    printer74 printer, other_printer;
    comparer74 comparer, other_comparer;
    string text;
    bit result;
    value.payload = 'ha5; peer.payload = 'ha6;
    ca.set_recursion_policy(UVM_DEEP); cb.set_recursion_policy(UVM_DEEP);
    for (int step = 0; step < 3; step++) begin
      printer = (step == 1) ? printer74'(pb) : printer74'(pa);
      other_printer = (step == 1) ? printer74'(pa) : printer74'(pb);
      comparer = (step == 1) ? comparer74'(cb) : comparer74'(ca);
      other_comparer = (step == 1) ? comparer74'(ca) : comparer74'(cb);
      pa.field_seen = 0; pb.field_seen = 0;
      text = value.sprint(printer);
      $display("UT: print74 %0d policy %0b idle %0b text %s payload %02h",
               step, value.last_printer == printer && printer.field_seen,
               !other_printer.field_seen, text, value.payload);
      ca.field_seen = 0; cb.field_seen = 0;
      result = value.compare(peer, comparer);
      $display("UT: compare74 %0d policy %0b idle %0b result %0b payload %02h peer %02h",
               step, value.last_comparer == comparer && comparer.field_seen,
               !other_comparer.field_seen, result, value.payload, peer.payload);
    end
    $finish;
  end
endmodule
