/*
:name: test_event_default_data_and_explicit_trigger_values_remain_independent_between_instances
:description: event default data is local and explicit trigger data does not replace that default (IEEE 1800.2-2020 Section 10.1.2.2.6)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.1.2.2.6 10.1.2.2.4 10.1.2.2.5 1800-2023 6.11.2 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_event_default_data_and_explicit_trigger_values_remain_independent_between_instances.expected
*/
// Positive delays establish waiting states. The fixtures do not require a
// particular order among processes released at the same synchronization point.
module test_event_default_data_and_explicit_trigger_values_remain_independent_between_instances;
  import uvm_pkg::*;
  typedef bit [31:0] word_t;
  uvm_event#(word_t) first;
  uvm_event#(word_t) second;
  initial begin

    first = new("first"); second = new("second");
    $display("UT: defaults %0d %0d", first.get_default_data(), second.get_default_data());
    first.set_default_data(11); second.set_default_data(22); first.trigger(33);
    $display("UT: explicit latest %0d default %0d peer_default %0d", first.get_trigger_data(),
             first.get_default_data(), second.get_default_data());
    first.trigger(); second.trigger();
    $display("UT: omitted latest %0d %0d defaults %0d %0d", first.get_trigger_data(),
             second.get_trigger_data(), first.get_default_data(), second.get_default_data());
    first.set_default_data(44); first.trigger();
    $display("UT: replaced latest %0d peer_latest %0d peer_default %0d", first.get_trigger_data(),
             second.get_trigger_data(), second.get_default_data());

    $finish;
  end
  initial begin #60; $fatal(1, "synchronization watchdog expired"); end
endmodule
