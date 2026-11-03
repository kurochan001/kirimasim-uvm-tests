/*
:name: test_reg_fifo_constructor_preserves_depth_width_name_and_empty_state
:description: FIFO construction establishes the supplied capacity and register width (18.8.3.1)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.8.3.1 18.8.4.1 18.8.4.2 18.8.2 18.4.3.8 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_fifo_constructor_preserves_depth_width_name_and_empty_state.expected
*/
// Abstract FIFO metadata only; no factory registration or DUT transfer.
// No implementation-specific build method is called.
module test_reg_fifo_constructor_preserves_depth_width_name_and_empty_state;
  import uvm_pkg::*;
  initial begin
    automatic uvm_reg_fifo first = new(.size(4), .n_bits(8), .has_cover(UVM_NO_COVERAGE));
    automatic uvm_reg_fifo peer = new("peer", 2, 16, UVM_NO_COVERAGE);
    $display("UT: names %s %s", first.get_name(), peer.get_name());
    $display("UT: first capacity %0d bits %0d size %0d queue %0d", first.capacity(),
             first.get_n_bits(), first.size(), first.fifo.size());
    $display("UT: peer capacity %0d bits %0d size %0d", peer.capacity(),
             peer.get_n_bits(), peer.size());
    $finish;
  end
endmodule
