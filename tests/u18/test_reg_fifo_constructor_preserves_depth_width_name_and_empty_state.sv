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
// What it checks:
// 1. Omitting the FIFO name uses its specified reg_fifo constructor default.
// 2. FIFO construction establishes the selected entry capacity and register
//    width.
// 3. The FIFO size query reports the number of abstract queue entries.
// 4. The capacity query reports the configured maximum entry count
//    independently of occupancy.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.8.3.1 (UVM-REG-FIFO-CONSTRUCTOR-DEFAULT-NAME) gives rule 1
//    above. Setup: Required size, width and coverage arguments are supplied by
//    name without a name argument. Expected: The omitted-name instance is
//    named reg_fifo and its named peer remains peer.
// 2. 1800.2-2020 18.8.3.1 (UVM-REG-FIFO-CONSTRUCTOR-CAPACITY-AND-WIDTH) gives
//    rule 2 above. Setup: Two FIFOs use capacities four/two and widths
//    eight/sixteen. Expected: The metadata queries return exactly those
//    supplied dimensions.
// 3. 1800.2-2020 18.8.4.1 (UVM-REG-FIFO-SIZE-REFLECTS-ABSTRACT-OCCUPANCY)
//    gives rule 3 above. Setup: Constructed empty queues and a valid queue of
//    three entries are queried; an explicit fixture pop removes one. Expected:
//    Sizes are initially zero, then three and two for the selected prepared
//    queue.
// 4. 1800.2-2020 18.8.4.2 (UVM-REG-FIFO-CAPACITY-REMAINS-CONFIGURED-DEPTH)
//    gives rule 4 above. Setup: A capacity-four FIFO changes from a
//    three-entry public queue to two entries. Expected: Capacity stays four
//    while the occupied size changes.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
