/*
:name: test_hdl_force_time_reg8_distinct_targets
:description: positive force_time holds and releases real reg8 across distinct-target sequential intervals (19.6.2.4)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.6.2.4 19.6.2.3 19.6.2.5 19.6.2.6 1800-2023 10.6.2 13.3.1 6.21
:uvm: 2020.3.1
:uvm_dpi: yes
:uvm_hdl_backend: vpi
:uvm_defines: UVM_REGEX_NO_DPI UVM_CMDLINE_NO_DPI
:dpi_c: @../../tools/uvm_hdl_vpi.cpp
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_hdl_force_time_reg8_distinct_targets.expected
*/
// What it checks:
// 1. A positive force_time keeps the requested value forced on its selected
//    path for the specified period.
// 2. The positive-duration force ends after its specified period so normal
//    updates can resume.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 19.6.2.4 (UVM-HDL-FORCE-TIME-HOLDS-DURING-POSITIVE-INTERVAL)
//    gives rule 1 above. Setup: Real public forceable 8/40-bit procedurally
//    assigned regs and continuously driven wires under the shared
//    compilation-default time unit; sequential durations 5 and 13 on one
//    target or two distinct targets, with an idle forceable target and an
//    unforced peer. The unchanged original backend and separate HDL runner are
//    explicitly selected. No call overlaps another call to the package task.
//    Expected: Each requested value is visible at the selected interior times
//    despite opposing assignments or changed drivers, while the dormant target
//    and independent peer retain their values.
// 2. 1800.2-2020 19.6.2.4
//    (UVM-HDL-FORCE-TIME-RELEASES-AFTER-POSITIVE-INTERVAL) gives rule 2 above.
//    Setup: Real public forceable 8/40-bit procedurally assigned regs and
//    continuously driven wires under the shared compilation-default time unit;
//    sequential durations 5 and 13 on one target or two distinct targets, with
//    an idle forceable target and an unforced peer. The unchanged original
//    backend and separate HDL runner are explicitly selected. No call overlaps
//    another call to the package task. Expected: After each period the reg
//    retains its forced value until reassigned and the driven wire resolves to
//    its driver; a later normal update becomes visible, including after reuse
//    or selection of a second target.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original positive-duration observers, independent of task return timing.
// Both scopes use the compilation default time unit; no ns value is assumed.
// Calls do not overlap; package task argument lifetime is a separate premise.
module test_hdl_force_time_reg8_distinct_targets;
  import uvm_pkg::*;
  logic [7:0] first /*verilator public_flat_rw*/ /*verilator forceable*/;
  logic [7:0] second /*verilator public_flat_rw*/ /*verilator forceable*/;
  logic [7:0] peer /*verilator public_flat_rw*/;
  localparam string ROOT_PATH = "test_hdl_force_time_reg8_distinct_targets";
  function automatic logic [7:0] selected_value(bit choose_second);
    return choose_second ? second : first;
  endfunction
  initial begin
    int cycle;
    bit choose_second;
    time duration;
    string path;
    logic [7:0] forced_value, opposing_value, resumed_value, dormant_value;
    first = 8'h3c; second = 8'h29; peer = 8'h5a;
    #1;
    for (cycle = 0; cycle < 2; ++cycle) begin
      choose_second = cycle == 1;
      duration = cycle == 0 ? 5 : 13;
      forced_value = cycle == 0 ? 8'ha6 : 8'hb7;
      opposing_value = cycle == 0 ? 8'h11 : 8'h22;
      resumed_value = cycle == 0 ? 8'h77 : 8'h66;
      dormant_value = selected_value(!choose_second);
      path = {ROOT_PATH, choose_second ? ".second" : ".first"};
      fork
        begin
          uvm_hdl_force_time(path, forced_value, duration);
        end
        begin
          #1;
          $display("UT: timed78 cycle %0d active %0b dormant %0b peer %0b", cycle,
                   selected_value(choose_second) == forced_value,
                   selected_value(!choose_second) == dormant_value, peer == 8'h5a);
          #1;
          if (choose_second) second = opposing_value;
          else first = opposing_value;
          #1;
          $display("UT: timed78 cycle %0d opposing_held %0b dormant %0b peer %0b", cycle,
                   selected_value(choose_second) == forced_value,
                   selected_value(!choose_second) == dormant_value, peer == 8'h5a);
          #(duration - 4);
          $display("UT: timed78 cycle %0d near_end %0b dormant %0b peer %0b", cycle,
                   selected_value(choose_second) == forced_value,
                   selected_value(!choose_second) == dormant_value, peer == 8'h5a);
          #2;
          $display("UT: timed78 cycle %0d released_value %0b dormant %0b peer %0b", cycle,
                   selected_value(choose_second) == forced_value,
                   selected_value(!choose_second) == dormant_value, peer == 8'h5a);
          if (choose_second) second = resumed_value;
          else first = resumed_value;
          #1;
          $display("UT: timed78 cycle %0d resumed %0b dormant %0b peer %0b", cycle,
                   selected_value(choose_second) == resumed_value,
                   selected_value(!choose_second) == dormant_value, peer == 8'h5a);
        end
      join
    end
    $finish;
  end
  initial begin
    #100;
    $fatal(1, "timed78 watchdog");
  end
endmodule
