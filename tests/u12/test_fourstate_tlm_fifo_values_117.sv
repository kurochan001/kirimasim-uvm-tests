/*
:name: test_fourstate_tlm_fifo_values_117
:description: TLM FIFOs deliver four-state X and Z bits exactly and in order (IEEE 1800.2-2020 Section 12.2.4.2.2)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.4.2.2 12.2.4.2.1 12.2.4.2.6 12.2.8.2 12.2.8.2.1 12.2.8.3 12.2.8.3.1 1800-2023 5.7.1 6.3.1 6.11 11.4.5 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_fourstate_tlm_fifo_values_117.expected
*/
// What it checks:
// TLM FIFOs deliver four-state transactions in order with their X and Z bits
// unchanged.
//
// How the expected output follows from the standard:
// 1800.2-2020 12.2.4.2.2 (UVM-FOURSTATE-TLM-FIFO-PRESERVES-XZ) gives the rule
// above. Setup: Put two 8-bit logic values with X and Z bits into a two-entry
// FIFO and write a third to an analysis FIFO, then get them. Expected: The
// values return in order with the same bits, and the analysis FIFO try_get
// succeeds.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A two-entry FIFO receives two values with X and Z bits and an analysis FIFO
// receives a third. The values must come back in order with the same bits,
// compared with case equality. The expectation comes from the cited clauses; a
// two-state simulator cannot represent X or Z, so this case is spec-only. Only
// the lines that begin with "UT: " are compared.
module test_fourstate_tlm_fifo_values_117;
  import uvm_pkg::*;


  initial begin
    automatic uvm_tlm_fifo #(logic [7:0]) fifo = new("fifo117", null, 2);
    automatic uvm_tlm_analysis_fifo #(logic [7:0]) analysis = new("analysis117");
    logic [7:0] first;
    logic [7:0] second;
    logic [7:0] third;
    bit got;
    fifo.put(8'b1x0z_10xz);
    fifo.put(8'bzz11_xx00);
    fifo.get(first);
    fifo.get(second);
    analysis.analysis_export.write(8'bx1z0_0110);
    got = analysis.try_get(third);
    $display("UT: fifo first %0d second %0d", first === 8'b1x0z_10xz, second === 8'bzz11_xx00);
    $display("UT: analysis got %0d same %0d", got, third === 8'bx1z0_0110);
    $finish;
  end
endmodule
