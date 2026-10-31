/*
:name: test_transaction_is_inactive_before_first_begin
:description: a newly constructed transaction is inactive until its first begin (IEEE 1800.2-2020 Section 5.4.2.12)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.4.2.12 5.4.2.4 5.4.2.6
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_transaction_is_inactive_before_first_begin.expected
*/
// The pinned library tests only its end-time sentinel and reports active
// before begin. Preserve the normative initial state as a spec-only case.

module test_transaction_is_inactive_before_first_begin;
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

  initial begin
    automatic transaction value = new;
    int handle_value;
    value.disable_recording();
    $display("UT: initial active %0d", value.is_active());
    handle_value = value.begin_tr(3);
    $display("UT: begun active %0d", value.is_active());
    value.end_tr(4);
    $display("UT: ended active %0d", value.is_active());
    $finish;
  end
endmodule
