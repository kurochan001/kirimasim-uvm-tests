/*
:name: test_rtl_mirror_rechecks_after_field_comparison_is_reenabled
:description: Raw RTL writes diverge from the mirror, which resynchronizes with and without comparison (IEEE 1800.2-2020 Section 18.4.4.14)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.4.14 18.5.5.15 18.4.4.3 18.2.5.2 6.6.3.2 1800-2023 14.3 14.4 14.13 25.9 9.2.2.4 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: ../u19/helpers116_rtl/rf_rtl116.sv ../u19/helpers116_rtl/rf_env116.svh
:expected_exit: 0
:expected_stdout: @test_rtl_mirror_rechecks_after_field_comparison_is_reenabled.expected
*/
// Raw writes change the RTL behind the mirror. The three checked reads must
// respectively ignore the masked mismatch, report the enabled mismatch and
// accept the refreshed value. Observe errors only while mirror() executes.
// Consume the expected error on the second read so the simulator can exit
// normally. The other reads propagate errors. The passive scoreboard sees
// two writes and three reads and independently checks the observed bus data.

module test_rtl_mirror_rechecks_after_field_comparison_is_reenabled;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "rf_env116.svh"

  bit clk;
  always #5 clk = ~clk;
  rf_if116 bus(clk);
  rf_dut116 dut(bus);

  class error_counter extends uvm_report_catcher;
    int errors = 0;
    bit consume_expected;
    function action_e catch();
      if (get_severity() == UVM_ERROR) begin
        errors++;
        if (consume_expected) return CAUGHT;
      end
      return THROW;
    endfunction
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    rf_env116 env;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = new("env", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      env.model.bus_map.set_auto_predict(1);
    endfunction
    task write_raw(byte unsigned value);
      rf_seq116 raw_seq = new("raw_seq");
      raw_seq.add116(1, 0, value);
      raw_seq.start(env.agent.sqr);
    endtask
    task checked_read(input bit expect_mismatch, output int errors);
      error_counter probe = new;
      uvm_status_e status;
      probe.consume_expected = expect_mismatch;
      uvm_report_cb::add(null, probe);
      env.model.ctrl.mirror(status, UVM_CHECK, UVM_FRONTDOOR, env.model.bus_map);
      uvm_report_cb::delete(null, probe);
      if (status != UVM_IS_OK) $fatal(1, "frontdoor read failed");
      errors = probe.errors;
    endtask
    task run_phase(uvm_phase phase);
      uvm_reg_data_t prior_value;
      int errors;
      phase.raise_objection(this);
      env.model.ctrl.value.set_compare(UVM_NO_CHECK);
      write_raw('h39);
      prior_value = env.model.ctrl.get_mirrored_value();
      checked_read(0, errors);
      $display("UT: masked before %0h errors %0d mirror %0h",
               prior_value, errors, env.model.ctrl.get_mirrored_value());
      env.model.ctrl.value.set_compare(UVM_CHECK);
      write_raw('ha7);
      prior_value = env.model.ctrl.get_mirrored_value();
      checked_read(1, errors);
      $display("UT: enabled before %0h mismatch %0d mirror %0h",
               prior_value, errors > 0, env.model.ctrl.get_mirrored_value());
      checked_read(0, errors);
      env.idle116(2);
      $display("UT: matched errors %0d mirror %0h traffic %0d",
               errors, env.model.ctrl.get_mirrored_value(), env.collector.seen.size());
      env.report116();
      phase.drop_objection(this);
    endtask
  endclass

  initial begin
    uvm_config_db #(virtual rf_if116)::set(null, "uvm_test_top.env.agent*", "vif", bus);
    run_test("t");
  end
  initial begin
    repeat (2) @(negedge clk);
    bus.rst_n = 1;
  end
  initial begin
    repeat (200) @(posedge clk);
    $fatal(1, "register-file watchdog expired");
  end
endmodule
