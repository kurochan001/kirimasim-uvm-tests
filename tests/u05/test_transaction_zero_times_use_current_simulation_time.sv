/*
:name: test_transaction_zero_times_use_current_simulation_time
:description: default transaction timestamps use the current simulation time (IEEE 1800.2-2020 Section 5.4.2.2)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.4.2.2 5.4.2.4 5.4.2.6 5.4.2.16
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_transaction_zero_times_use_current_simulation_time.expected
*/
// Accept, begin and end after distinct positive delays. Omitted and
// explicit zero arguments both select the current time in the caller units.

module test_transaction_zero_times_use_current_simulation_time;
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
    #2;
    value.accept_tr();
    #3;
    handle_value = value.begin_tr(0);
    #4;
    value.end_tr();
    $display("UT: times %0d %0d %0d", value.get_accept_time(), value.get_begin_time(),
        value.get_end_time());
    $display("UT: elapsed %0d no_record_handle %0d", $time, handle_value == 0);
    $finish;
  end
endmodule
