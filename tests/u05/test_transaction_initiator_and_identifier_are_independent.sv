/*
:name: test_transaction_initiator_and_identifier_are_independent
:description: the transaction initiator and explicit identifier update independently (IEEE 1800.2-2020 Section 5.4.2.1)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.4.2.1 5.4.2.14 5.4.2.15 5.4.2.17 5.4.2.18
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_transaction_initiator_and_identifier_are_independent.expected
*/
// What it checks:
// 1. The initiator query returns the component currently assigned to the
//    transaction.
// 2. The transaction ID query returns the assigned identifier, with -1 before
//    assignment.
// 3. The initiator setter replaces the selected component handle.
// 4. The transaction identifier defaults to minus one and retains selected
//    explicit IDs.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 5.4.2.15 (UVM-TRANSACTION-INITIATOR) gives rule 1 above.
//    Setup: Construct with one component, then set another initiator and
//    change transaction IDs. Expected: The selected initiator handle is
//    preserved independently of the numeric ID.
// 2. 1800.2-2020 5.4.2.18 (UVM-TRANSACTION-NUMERIC-ID) gives rule 2 above.
//    Setup: Inspect a new transaction, then assign IDs 37 and 0. Expected: The
//    observed IDs are -1, 37 and 0.
// 3. 1800.2-2020 5.4.2.14 (UVM-BASE-AUDIT-INITIATOR-SET) gives rule 3 above.
//    Setup: Reassess the unchanged original initiator/identifier fixture and
//    its compatible measurement; no new execution is claimed merely from a
//    link. Expected: The existing source changes first to second without
//    changing the selected identifier.
// 4. 1800.2-2020 5.4.2.17 (UVM-BASE-AUDIT-TRANSACTION-ID) gives rule 4 above.
//    Setup: Reassess the unchanged original initiator/identifier fixture and
//    its compatible measurement; no new execution is claimed merely from a
//    link. Expected: The existing fixture observes minus one, thirty-seven and
//    zero while initiator state remains independent.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Compare initiator handles and explicit transaction identifiers. Do not
// confuse transaction identifiers with implementation-assigned object IDs.

module test_transaction_initiator_and_identifier_are_independent;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class transaction extends uvm_transaction;
    `uvm_object_utils(transaction)
    int accept_calls = 0;
    int begin_calls = 0;
    int end_calls = 0;
    function new(string name="transaction", uvm_component initiator=null);
      super.new(name, initiator);
    endfunction
    protected function void do_accept_tr();
      super.do_accept_tr();
      accept_calls++;
    endfunction
    protected function void do_begin_tr();
      super.do_begin_tr();
      begin_calls++;
    endfunction
    protected function void do_end_tr();
      super.do_end_tr();
      end_calls++;
    endfunction
  endclass

  class owner extends uvm_component;
    `uvm_component_utils(owner)
    function new(string name, uvm_component parent=null); super.new(name, parent); endfunction
  endclass

  initial begin
    automatic owner first = new("first");
    automatic owner second = new("second");
    automatic transaction value = new("value", first);
    $display("UT: initial initiator %0d id %0d", value.get_initiator() == first,
        value.get_transaction_id());
    value.set_transaction_id(37);
    value.set_initiator(second);
    $display("UT: changed initiator %0d id %0d", value.get_initiator() == second,
        value.get_transaction_id());
    value.set_transaction_id(0);
    $display("UT: zero id %0d initiator %0d", value.get_transaction_id(),
        value.get_initiator() == second);
    $finish;
  end
endmodule
