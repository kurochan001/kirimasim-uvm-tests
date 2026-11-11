/*
:name: test_barrier_constructor_names_threshold_defaults_and_object_base_are_instance_local
:description: barrier constructor names threshold defaults and object base are instance local (IEEE 1800.2-2020 Section 10.3.2.1)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.3.2.1 10.3.1 10.3.2.5 10.3.2.6 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_barrier_constructor_names_threshold_defaults_and_object_base_are_instance_local.expected
*/
// What it checks:
// 1. The barrier constructor accepts the declared optional name.
// 2. The omitted barrier threshold defaults to zero.
// 3. A barrier derives from the object base.
// 4. The barrier threshold getter returns its current per-instance setting.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 10.3.2.1 (UVM-SYNC-REVIEW-BARRIER-NAMES) gives rule 1 above.
//    Setup: Construct omitted, selected and empty names with legal selected
//    thresholds. Expected: Names are empty, selected and empty.
// 2. 1800.2-2020 10.3.2.1 (UVM-SYNC-REVIEW-BARRIER-DEFAULT-THRESHOLD) gives
//    rule 2 above. Setup: Construct one omitted threshold and two explicit
//    thresholds. Expected: Getters report zero, three and five respectively.
// 3. 1800.2-2020 10.3.1 (UVM-SYNC-REVIEW-BARRIER-OBJECT-BASE) gives rule 3
//    above. Setup: Assign the selected barrier to an object handle. Expected:
//    The base retains identity.
// 4. 1800.2-2020 10.3.2.5 (UVM-SYNC-REVIEW-BARRIER-CURRENT-THRESHOLD) gives
//    rule 4 above. Setup: Change only one of three separately constructed
//    barrier thresholds. Expected: That getter reports seven while peers
//    retain zero and five.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Inspect declared optional names, zero threshold default, selected thresholds
// and current getter values per instance. No zero/negative-threshold wait
// semantics, waiter scheduling or object layout is inferred.
module test_barrier_constructor_names_threshold_defaults_and_object_base_are_instance_local;
  import uvm_pkg::*;
  initial begin
    automatic uvm_barrier omitted = new();
    automatic uvm_barrier named = new("selected",3);
    automatic uvm_barrier empty = new("",5);
    automatic uvm_object base_view = named;
    $display("UT: barrier_names omitted %0d named %0d empty %0d base %0d",
             omitted.get_name() == "",named.get_name() == "selected",empty.get_name() == "",
             base_view == named);
    $display("UT: barrier_thresholds default %0d selected %0d explicit %0d",
             omitted.get_threshold(),named.get_threshold(),empty.get_threshold());
    named.set_threshold(7);
    $display("UT: barrier_threshold_update current %0d peer %0d empty %0d",
             named.get_threshold(),omitted.get_threshold(),empty.get_threshold());
    $finish;
  end
endmodule
