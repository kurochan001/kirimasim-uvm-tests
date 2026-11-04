/*
:name: test_pinned_fifo_build_control_write_and_read_prediction
:description: Pinned-library build initialization control; constructor-only requirements remain independently measured
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.8.5.7 18.8.2 18.8.5.3 18.8.5.4 18.4.4.15 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pinned_fifo_build_control_write_and_read_prediction.expected
*/
// Explicit pinned-library initialization control, not an IEEE API duty.
// Its result does not pass the separately retained constructor-only input.
module test_pinned_fifo_build_control_write_and_read_prediction;
  import uvm_pkg::*;
  initial begin
    uvm_reg_fifo chosen;
    bit first_ok,second_ok,read_ok;
    chosen=new("chosen63",4,8,UVM_NO_COVERAGE); chosen.build();
    first_ok=chosen.predict('h11,.kind(UVM_PREDICT_WRITE));
    second_ok=chosen.predict('h22,.kind(UVM_PREDICT_WRITE));
    $display("UT: fifo_predict writes %0d ordered %0d",
      first_ok && second_ok,chosen.fifo.size()==2 && chosen.fifo[0]=='h11 && chosen.fifo[1]=='h22);
    read_ok=chosen.predict('h11,.kind(UVM_PREDICT_READ));
    $display("UT: fifo_predict read %0d remaining %0d",
      read_ok,chosen.fifo.size()==1 && chosen.fifo[0]=='h22);
    $finish;
  end
endmodule
