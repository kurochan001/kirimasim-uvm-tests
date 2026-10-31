/*
:name: test_config_db_wait_modified_waits_for_creation
:description: wait_modified blocks for an absent setting until its first matching set (IEEE 1800.2-2020 Section C.4.2.2.4)
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.4.2.2.4 C.4.2.2.1 C.4.2.2.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_config_db_wait_modified_waits_for_creation.expected
*/
// Start the waiter before any update. An unrelated write must not wake
// it. A watchdog turns a missing notification into a bounded failure.

module test_config_db_wait_modified_waits_for_creation;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    bit woke = 0;
    int value = -1;
    bit found;

    fork : guarded
      begin
        fork
          begin
            uvm_config_db#(int)::wait_modified(null, "scope", "target");
            woke = 1;
            found = uvm_config_db#(int)::get(null, "scope", "target", value);
            $display("UT: modified found %0d value %0d", found, value);
          end
          begin
            #1;
            $display("UT: initially waiting %0d", !woke);
            uvm_config_db#(int)::set(null, "other_scope", "target", 99);
            #1;
            $display("UT: unrelated still waiting %0d", !woke);
            uvm_config_db#(int)::set(null, "scope", "target", 58);
          end
        join
      end
      begin
        #10;
        $fatal(1, "configuration waiter did not complete");
      end
    join_any
    disable guarded;
    $display("UT: completed %0d", woke);
    $finish;
  end
endmodule
