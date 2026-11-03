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
