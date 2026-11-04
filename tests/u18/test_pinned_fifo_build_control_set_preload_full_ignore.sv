/*
:name: test_pinned_fifo_build_control_set_preload_full_ignore
:description: Pinned-library build initialization control; constructor-only requirements remain independently measured
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.8.5.2 18.8.3.1 18.8.2 18.8.5.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pinned_fifo_build_control_set_preload_full_ignore.expected
*/
// Explicit pinned-library initialization control, not an IEEE API duty.
// Its result does not pass the separately retained constructor-only input.
module test_pinned_fifo_build_control_set_preload_full_ignore;
  import uvm_pkg::*;
  initial begin
    uvm_reg_fifo chosen,peer;
    chosen=new("chosen63",2,8,UVM_NO_COVERAGE); chosen.build();
    peer=new("peer63",2,8,UVM_NO_COVERAGE); peer.build();
    chosen.set('h11); chosen.set('h22,"debug63.sv",73); chosen.set('h33);
    $display("UT: fifo_set ordered %0d full_ignored %0d peer %0d",
      chosen.fifo.size()==2 && chosen.fifo[0]=='h11 && chosen.fifo[1]=='h22,
      chosen.size()==2 && chosen.get()=='h11,peer.size()==0);
    $finish;
  end
endmodule
