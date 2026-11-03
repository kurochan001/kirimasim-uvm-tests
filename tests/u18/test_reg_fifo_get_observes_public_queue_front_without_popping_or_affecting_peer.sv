/*
:name: test_reg_fifo_get_observes_public_queue_front_without_popping_or_affecting_peer
:description: FIFO get returns the front abstract value without popping it or using debug arguments (18.8.5.1)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.8.5.1 18.8.2 18.8.4.1 18.8.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_fifo_get_observes_public_queue_front_without_popping_or_affecting_peer.expected
*/
// The public abstract queue supplies a valid nonempty state within capacity.
// The explicit queue pop is fixture stimulus, not a DUT read or a FIFO get pop.
module test_reg_fifo_get_observes_public_queue_front_without_popping_or_affecting_peer;
  import uvm_pkg::*;
  initial begin
    automatic uvm_reg_fifo first = new("first", 4, 8, UVM_NO_COVERAGE);
    automatic uvm_reg_fifo peer = new("peer", 2, 8, UVM_NO_COVERAGE);
    uvm_reg_data_t first_value, repeated, after_pop, discarded;
    first.fifo = '{17, 34, 51}; peer.fifo = '{99};
    first_value = first.get(); repeated = first.get("debug_only.sv", 73);
    $display("UT: front %0d repeated %0d size %0d peer %0d peer_size %0d", first_value,
             repeated, first.size(), peer.get(), peer.size());
    discarded = first.fifo.pop_front(); after_pop = first.get();
    $display("UT: explicit_pop removed %0d front %0d size %0d capacity %0d", discarded,
             after_pop, first.size(), first.capacity());
    $finish;
  end
endmodule
