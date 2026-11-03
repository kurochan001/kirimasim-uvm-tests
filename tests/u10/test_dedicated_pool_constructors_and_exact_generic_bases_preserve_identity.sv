/*
:name: test_dedicated_pool_constructors_and_exact_generic_bases_preserve_identity
:description: dedicated pool constructors and exact generic bases preserve identity (IEEE 1800.2-2020 Section 10.4.1.2.1)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.4.1.2.1 10.4.1.1 10.4.2.2.1 10.4.2.1 11.2.1 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_dedicated_pool_constructors_and_exact_generic_bases_preserve_identity.expected
*/
// Positive dedicated-to-generic pool compatibility and optional names only.
// Initial membership has a separate fixture. The printed get_global return
// signature versus item-return prose is not resolved by these assignments.
module test_dedicated_pool_constructors_and_exact_generic_bases_preserve_identity;
  import uvm_pkg::*;
  initial begin
    automatic uvm_event_pool event_default = new();
    automatic uvm_event_pool event_named = new("events");
    automatic uvm_event_pool event_empty = new("");
    automatic uvm_barrier_pool barrier_default = new();
    automatic uvm_barrier_pool barrier_named = new("barriers");
    automatic uvm_barrier_pool barrier_empty = new("");
    automatic uvm_pool#(string,uvm_event#(uvm_object)) event_view = event_named;
    automatic uvm_pool#(string,uvm_barrier) barrier_view = barrier_named;
    $display("UT: event_pool_names omitted %0d named %0d empty %0d base %0d",
             event_default.get_name() == "",event_named.get_name() == "events",
             event_empty.get_name() == "",event_view == event_named);
    $display("UT: barrier_pool_names omitted %0d named %0d empty %0d base %0d",
             barrier_default.get_name() == "",barrier_named.get_name() == "barriers",
             barrier_empty.get_name() == "",barrier_view == barrier_named);
    $finish;
  end
endmodule
