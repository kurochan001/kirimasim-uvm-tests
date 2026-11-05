/*
:name: test_hdl_force_time_wire40_distinct_targets
:description: positive force_time holds and releases real wire40 across distinct-target sequential intervals (19.6.2.4)
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
:expected_stdout: @test_hdl_force_time_wire40_distinct_targets.expected
*/
// Original positive-duration observers, independent of task return timing.
// Both scopes use the compilation default time unit; no ns value is assumed.
// Calls do not overlap; package task argument lifetime is a separate premise.
module test_hdl_force_time_wire40_distinct_targets;
  import uvm_pkg::*;
  wire [39:0] first /*verilator public_flat_rw*/ /*verilator forceable*/;
  wire [39:0] second /*verilator public_flat_rw*/ /*verilator forceable*/;
  logic [39:0] peer /*verilator public_flat_rw*/;
  logic [39:0] source_first, source_second;
  assign first = source_first;
  assign second = source_second;
  localparam string ROOT_PATH = "test_hdl_force_time_wire40_distinct_targets";
  function automatic logic [39:0] selected_value(bit choose_second);
    return choose_second ? second : first;
  endfunction
  initial begin
    int cycle;
    bit choose_second;
    time duration;
    string path;
    logic [39:0] forced_value, opposing_value, resumed_value, dormant_value;
    source_first = 40'h123456789a; source_second = 40'hfedcba987; peer = 40'h5aa55aa55a;
    #1;
    for (cycle = 0; cycle < 2; ++cycle) begin
      choose_second = cycle == 1;
      duration = cycle == 0 ? 5 : 13;
      forced_value = cycle == 0 ? 40'he1d2c3b4a5 : 40'h91a2b3c4d5;
      opposing_value = cycle == 0 ? 40'h1122334455 : 40'h66778899aa;
      resumed_value = cycle == 0 ? 40'haa99776655 : 40'hbb88776655;
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
                   selected_value(!choose_second) == dormant_value, peer == 40'h5aa55aa55a);
          #1;
          if (choose_second) source_second = opposing_value;
          else source_first = opposing_value;
          #1;
          $display("UT: timed78 cycle %0d opposing_held %0b dormant %0b peer %0b", cycle,
                   selected_value(choose_second) == forced_value,
                   selected_value(!choose_second) == dormant_value, peer == 40'h5aa55aa55a);
          #(duration - 4);
          $display("UT: timed78 cycle %0d near_end %0b dormant %0b peer %0b", cycle,
                   selected_value(choose_second) == forced_value,
                   selected_value(!choose_second) == dormant_value, peer == 40'h5aa55aa55a);
          #2;
          $display("UT: timed78 cycle %0d released_value %0b dormant %0b peer %0b", cycle,
                   selected_value(choose_second) == opposing_value,
                   selected_value(!choose_second) == dormant_value, peer == 40'h5aa55aa55a);
          if (choose_second) source_second = resumed_value;
          else source_first = resumed_value;
          #1;
          $display("UT: timed78 cycle %0d resumed %0b dormant %0b peer %0b", cycle,
                   selected_value(choose_second) == resumed_value,
                   selected_value(!choose_second) == dormant_value, peer == 40'h5aa55aa55a);
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
