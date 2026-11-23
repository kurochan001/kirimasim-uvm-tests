/*
:name: test_fourstate_event_releases_typed_waiter_and_retains_distinct_x_and_z_bits
:description: Typed event wait and retained data independently preserve X and Z positions across subsequent triggers (IEEE 1800.2-2020 Section 10.1.2.2.2)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.1.2.2.2 10.1.2.2.4 10.1.2.2.5 1800-2023 6.3.1 11.4.5 9.3.2 20.9
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_fourstate_event_releases_typed_waiter_and_retains_distinct_x_and_z_bits.expected
*/
// Arm a waiter, trigger one four-state vector, and sample the returned value
// and retained event data. Overwrite the source and trigger a vector with X
// and Z exchanged. The saved waiter result must preserve the first pattern
// while the event now exposes the second. Case equality checks the particular
// positions, and an unknown-bit check makes two-state collapse observable.

module test_fourstate_event_releases_typed_waiter_and_retains_distinct_x_and_z_bits;
  import uvm_pkg::*;
  typedef logic [3:0] sample_t;

  initial begin
    automatic uvm_event #(sample_t) ev = new("samples");
    sample_t supplied, saved, latest;
    bit finished;
    finished = 0;
    fork
      begin
        ev.wait_trigger_data(saved);
        finished = 1;
      end
    join_none
    #1;
    supplied = 4'b1xz0;
    ev.trigger(supplied);
    #1;
    if (!finished) $fatal(1, "event waiter was not released");
    latest = ev.get_trigger_data();
    $display("UT: first waiter %0d retained %0d unknown %0d",
             saved === 4'b1xz0, latest === 4'b1xz0, $isunknown(saved));
    supplied = 4'b1zx0;
    ev.trigger(supplied);
    latest = ev.get_trigger_data();
    $display("UT: next retained %0d saved %0d distinct %0d unknown %0d",
             latest === 4'b1zx0, saved === 4'b1xz0, latest !== saved, $isunknown(latest));
    $finish;
  end
endmodule
