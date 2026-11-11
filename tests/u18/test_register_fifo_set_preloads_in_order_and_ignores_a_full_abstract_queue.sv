/*
:name: test_register_fifo_set_preloads_in_order_and_ignores_a_full_abstract_queue
:description: register fifo set preloads in order and ignores a full abstract queue
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.8.5.2 18.8.3.1 18.8.2 18.8.5.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_register_fifo_set_preloads_in_order_and_ignores_a_full_abstract_queue.expected
*/
// What it checks:
// 1. FIFO set pushes selected values into the abstract queue in call order.
// 2. FIFO set ignores a push into a full abstract queue.
// 3. Selected FIFO set debug arguments do not change the pushed value.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.8.5.2 (UVM-MEM-FIFO-AUDIT-FIFO-SET-PUSH) gives rule 1
//    above. Setup: Use depth two, two valid preloads, an explicit debug call,
//    one full push and an untouched peer; finish without a blocking statement
//    or DUT-access claim. Expected: The queue retains 0x11 then 0x22.
// 2. 1800.2-2020 18.8.5.2 (UVM-MEM-FIFO-AUDIT-FIFO-SET-FULL-IGNORED) gives
//    rule 2 above. Setup: Use depth two, two valid preloads, an explicit debug
//    call, one full push and an untouched peer; finish without a blocking
//    statement or DUT-access claim. Expected: The third value is absent and
//    occupancy remains two.
// 3. 1800.2-2020 18.8.5.2 (UVM-MEM-FIFO-AUDIT-FIFO-SET-DEBUG) gives rule 3
//    above. Setup: Use depth two, two valid preloads, an explicit debug call,
//    one full push and an untouched peer; finish without a blocking statement
//    or DUT-access claim. Expected: The explicit filename/line call retains
//    its supplied second value.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_register_fifo_set_preloads_in_order_and_ignores_a_full_abstract_queue;
  import uvm_pkg::*;
  initial begin
    uvm_reg_fifo chosen,peer;
    chosen=new("chosen63",2,8,UVM_NO_COVERAGE); peer=new("peer63",2,8,UVM_NO_COVERAGE);
    chosen.set('h11); chosen.set('h22,"debug63.sv",73); chosen.set('h33);
    $display("UT: fifo_set ordered %0d full_ignored %0d peer %0d",
      chosen.fifo.size()==2 && chosen.fifo[0]=='h11 && chosen.fifo[1]=='h22,
      chosen.size()==2 && chosen.get()=='h11,peer.size()==0);
    $finish;
  end
endmodule
