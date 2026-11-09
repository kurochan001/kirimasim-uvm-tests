/*
:name: test_fourstate_pool_missing_key_117
:description: getting a missing key from a pool of a four-state type creates an all-X entry (IEEE 1800.2-2020 Section 11.2.2.4)
:tags: u11 uvm
:type: simulation
:lrm: 1800.2-2020 11.2.2.4 11.2.2.1 11.2.2.5 11.2.2.6 11.2.2.8 1800-2023 7.4.5 5.7.1 6.3.1 6.11 11.4.5 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_fourstate_pool_missing_key_117.expected
*/
// What it checks:
// Getting a missing key from a pool of a four-state element type creates the
// key with an all-X value.
//
// How the expected output follows from the standard:
// 1800.2-2020 11.2.2.4 (UVM-FOURSTATE-POOL-MISSING-GET-X) gives the rule
// above. Setup: Get a missing key from a pool of 8-bit logic values and from a
// pool of 8-bit bit values, then add and get a logic value with X and Z bits.
// Expected: The logic pool returns all X and creates the key; the bit pool
// returns zero and creates the key; the stored value returns with the same
// bits.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Table 7-1 of 1800-2023 gives all X for a missing four-state entry and zero
// for a two-state one. A logic pool must return all X and create the key; a bit
// pool is the two-state control; a stored value with X and Z bits must be
// returned exactly. The expectation comes from the cited clauses; a two-state
// simulator cannot represent X or Z, so this case is spec-only. Only the lines
// that begin with "UT: " are compared.
module test_fourstate_pool_missing_key_117;
  import uvm_pkg::*;


  initial begin
    automatic uvm_pool #(int, logic [7:0]) logic_pool = new("logic_pool117");
    automatic uvm_pool #(int, bit [7:0]) bit_pool = new("bit_pool117");
    logic [7:0] missing;
    bit [7:0] missing_bit;
    missing = logic_pool.get(5);
    $display("UT: logic missing x %0d created %0d", missing === 8'bxxxx_xxxx,
             logic_pool.exists(5) && logic_pool.num() == 1);
    missing_bit = bit_pool.get(5);
    $display("UT: bit missing zero %0d created %0d", missing_bit === 8'h00, bit_pool.exists(5));
    logic_pool.add(7, 8'b1x0z_z0x1);
    $display("UT: logic stored same %0d", logic_pool.get(7) === 8'b1x0z_z0x1);
    $finish;
  end
endmodule
