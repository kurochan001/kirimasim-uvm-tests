/*
:name: test_rtl_frontdoor_update_writes_only_dirty_registers_and_preserves_other_pending_values
:description: Frontdoor update performs only needed writes while a sibling register independently remains dirty (IEEE 1800.2-2020 Section 18.4.4.13)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.4.13 18.4.4.4 18.4.4.2 18.4.4.3 18.2.5.2 19.2.1.2.5 19.2.1.2.6 1800-2023 14.3 14.4 14.13 25.9 9.2.2.4 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: ../u19/helpers116_rtl/rf_rtl116.sv ../u19/helpers116_rtl/rf_env116.svh
:expected_exit: 0
:expected_stdout: @test_rtl_frontdoor_update_writes_only_dirty_registers_and_preserves_other_pending_values.expected
*/
// On the register-file RTL, set desired CTRL twice and DATA once. No bus
// traffic occurs until update. Flush CTRL and update it again while DATA
// remains pending. Flush DATA, then issue three raw reads through the bus.
// The peripheral write counter, monitor and scoreboard independently
// distinguish two effective writes from redundant requests.

module test_rtl_frontdoor_update_writes_only_dirty_registers_and_preserves_other_pending_values;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "rf_env116.svh"

  bit clk;
  always #5 clk = ~clk;
  rf_if116 bus(clk);
  rf_dut116 dut(bus);

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
    task run_phase(uvm_phase phase);
      rf_seq116 reads = new("reads");
      uvm_status_e status;
      phase.raise_objection(this);
      env.model.ctrl.set('h17);
      env.model.ctrl.set('h51);
      env.model.data.set('hc3);
      env.idle116(3);
      $display("UT: staged traffic %0d dirty %0d %0d mirror %0h %0h", env.collector.seen.size(),
               env.model.ctrl.needs_update(), env.model.data.needs_update(),
               env.model.ctrl.get_mirrored_value(), env.model.data.get_mirrored_value());
      env.model.ctrl.update(status, UVM_FRONTDOOR, env.model.bus_map);
      if (status != UVM_IS_OK) $fatal(1, "CTRL write failed");
      env.idle116(2);
      $display("UT: ctrl traffic %0d dirty %0d %0d mirrors %0h %0h", env.collector.seen.size(),
               env.model.ctrl.needs_update(), env.model.data.needs_update(),
               env.model.ctrl.get_mirrored_value(), env.model.data.get_mirrored_value());
      env.model.ctrl.update(status, UVM_FRONTDOOR, env.model.bus_map);
      env.idle116(2);
      $display("UT: repeated traffic %0d peer desired %0h",
               env.collector.seen.size(), env.model.data.get());
      env.model.data.update(status, UVM_FRONTDOOR, env.model.bus_map);
      if (status != UVM_IS_OK) $fatal(1, "DATA write failed");
      env.idle116(2);
      $display("UT: updated traffic %0d dirty %0d %0d mirrors %0h %0h", env.collector.seen.size(),
               env.model.ctrl.needs_update(), env.model.data.needs_update(),
               env.model.ctrl.get_mirrored_value(), env.model.data.get_mirrored_value());
      reads.add116(0, 0, 0);
      reads.add116(0, 1, 0);
      reads.add116(0, 2, 0);
      reads.start(env.agent.sqr);
      env.idle116(2);
      $display("UT: readback %0h %0h count %0d total %0d", reads.ops[0].data, reads.ops[1].data,
               reads.ops[2].data, env.collector.seen.size());
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
