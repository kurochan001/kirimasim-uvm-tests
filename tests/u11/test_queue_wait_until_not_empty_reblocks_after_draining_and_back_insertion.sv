/*
:name: test_queue_wait_until_not_empty_reblocks_after_draining_and_back_insertion
:description: queue waiting is local, non-consuming, and resumes again after an empty refill (IEEE 1800.2-2020 Section 11.3.2.12)
:tags: u11 uvm
:type: simulation
:lrm: 1800.2-2020 11.3.2.12 11.3.2.4 11.3.2.5 11.3.2.7 11.3.2.11 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_queue_wait_until_not_empty_reblocks_after_draining_and_back_insertion.expected
*/
module test_queue_wait_until_not_empty_reblocks_after_draining_and_back_insertion;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  typedef bit [31:0] word_t;
  class warning_probe extends uvm_report_catcher;
    int warnings = 0;
    function new(); super.new("probe"); endfunction
    virtual function action_e catch();
      if (get_severity() == UVM_WARNING) begin warnings++; return CAUGHT; end
      return THROW;
    endfunction
  endclass

  uvm_queue#(word_t) queue_value;
  uvm_queue#(word_t) peer;
  time before_wait;
  bit first_returned = 0;
  bit second_returned = 0;
  initial begin
    queue_value = new("queue_value"); peer = new("peer");
    fork
      begin queue_value.wait_until_not_empty(); first_returned = 1; end
      begin
        #1;
        $display("UT: first_wait %0d size %0d", !first_returned, queue_value.size());
        peer.push_back(91);
        #1;
        $display("UT: peer_did_not_wake %0d", !first_returned);
        queue_value.push_back(42);
      end
    join
    $display("UT: first_done %0d retained %0d value %0d",
               first_returned, queue_value.size(),
        queue_value.get(0));
    before_wait = $time;
    queue_value.wait_until_not_empty();
    $display("UT: nonempty_immediate same_time %0d size %0d", $time == before_wait,
        queue_value.size());
    queue_value.delete();
    fork
      begin queue_value.wait_until_not_empty(); second_returned = 1; end
      begin #1; $display("UT: second_wait %0d", !second_returned); queue_value.push_back(73); end
    join
    $display("UT: second_done %0d retained %0d value %0d peer %0d", second_returned,
             queue_value.size(), queue_value.get(0), peer.get(0));
    $finish;
  end
  initial begin #20; $fatal(1, "queue wait watchdog expired"); end

endmodule
