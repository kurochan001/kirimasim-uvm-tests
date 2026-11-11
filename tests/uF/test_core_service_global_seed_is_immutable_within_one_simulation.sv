/*
:name: test_core_service_global_seed_is_immutable_within_one_simulation
:description: core global seed remains immutable within a simulation (IEEE 1800.2-2020 Section F.4.1.4.20)
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.4.1.4.20 F.4.1.3 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_core_service_global_seed_is_immutable_within_one_simulation.expected
*/
// What it checks:
// 1. Successive core-service get calls identify the current shared service
//    instance.
// 2. The core global seed remains unchanged within one simulation.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 F.4.1.3 (UVM-CORE-SERVICE-INSTANCE-STABILITY) gives rule 1
//    above. Setup: Query around service selection, object construction, random
//    draws and a delay. Expected: Each get returns the same service handle.
// 2. 1800.2-2020 F.4.1.4.20 (UVM-CORE-GLOBAL-SEED-IMMUTABILITY) gives rule 2
//    above. Setup: Take four process-random draws, construct objects and
//    advance time. Expected: Every seed query equals the initial query.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Observe equality within one simulation only, never a particular seed value
// or equality between separate seed-1/seed-73 processes or RNG algorithms.
module test_core_service_global_seed_is_immutable_within_one_simulation;
  import uvm_pkg::*;

  class token extends uvm_object;
    function new(string name="token"); super.new(name); endfunction
  endclass
  initial begin
    automatic uvm_coreservice_t core = uvm_coreservice_t::get();
    automatic int unsigned seed_value = core.get_global_seed();
    automatic bit unchanged = 1;
    token item;
    int unsigned discarded;
    repeat (4) begin
      discarded = $urandom(); item = new("item");
      unchanged &= core.get_global_seed() == seed_value;
    end
    #1;
    $display("UT: repeated_seed_unchanged %0d after_delay %0d service_same %0d", unchanged,
    core.get_global_seed() == seed_value, uvm_coreservice_t::get() == core);
    $finish;
  end

endmodule
