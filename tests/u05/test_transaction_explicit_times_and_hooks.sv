/*
:name: test_transaction_explicit_times_and_hooks
:description: explicit transaction times and lifecycle hooks retain their specified values (IEEE 1800.2-2020 Section 5.4.2.2)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.4.2.2 5.4.2.3 5.4.2.4 5.4.2.5 5.4.2.6 5.4.2.7 5.4.2.12 5.4.2.16
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_transaction_explicit_times_and_hooks.expected
*/
// Disable recording before acceptance. Explicit nonzero times need not
// match simulation time; each lifecycle operation calls its user hook once.

module test_transaction_explicit_times_and_hooks;
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
    value.accept_tr(17);
    handle_value = value.begin_tr(23);
    $display("UT: begin active %0d no_record_handle %0d", value.is_active(), handle_value == 0);
    value.end_tr(29);
    $display("UT: times %0d %0d %0d", value.get_accept_time(), value.get_begin_time(),
        value.get_end_time());
    $display("UT: hooks %0d %0d %0d inactive %0d", value.accept_calls, value.begin_calls,
             value.end_calls, !value.is_active());
    $finish;
  end
endmodule
