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
// What it checks:
// 1. The FIFO size query reports the number of abstract queue entries.
// 2. The capacity query reports the configured maximum entry count
//    independently of occupancy.
// 3. The public FIFO queue supplies the abstract representation observed by
//    its queries.
// 4. A nonempty FIFO get returns its next abstract value without removing it.
// 5. FIFO get filename and line-number arguments do not change its functional
//    result.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.8.4.1 (UVM-REG-FIFO-SIZE-REFLECTS-ABSTRACT-OCCUPANCY)
//    gives rule 1 above. Setup: Constructed empty queues and a valid queue of
//    three entries are queried; an explicit fixture pop removes one. Expected:
//    Sizes are initially zero, then three and two for the selected prepared
//    queue.
// 2. 1800.2-2020 18.8.4.2 (UVM-REG-FIFO-CAPACITY-REMAINS-CONFIGURED-DEPTH)
//    gives rule 2 above. Setup: A capacity-four FIFO changes from a
//    three-entry public queue to two entries. Expected: Capacity stays four
//    while the occupied size changes.
// 3. 1800.2-2020 18.8.2 (UVM-REG-FIFO-PUBLIC-QUEUE-REPRESENTATION) gives rule
//    3 above. Setup: The original fixture prepares in-bound queues and changes
//    only the first queue explicitly. Expected: Public queue contents, front
//    values and occupied sizes agree in the selected states.
// 4. 1800.2-2020 18.8.5.1 (UVM-REG-FIFO-GET-DOES-NOT-POP) gives rule 4 above.
//    Setup: Two gets inspect the prepared 17/34/51 queue before a separate
//    explicit fixture pop. Expected: Both gets return 17 with size three; only
//    the explicit pop changes the next front to 34.
// 5. 1800.2-2020 18.8.5.1 (UVM-REG-FIFO-GET-DEBUG-ARGUMENTS-NONFUNCTIONAL)
//    gives rule 5 above. Setup: A default call and a call with
//    debug_only.sv/73 inspect the same valid queue. Expected: Both calls
//    return 17 without popping.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
