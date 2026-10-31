/*
:name: test_config_db_wait_modified_ignores_other_fields
:description: wait_modified ignores unrelated fields and observes a replacement (IEEE 1800.2-2020 Section C.4.2.2.4)
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.4.2.2.4 C.4.2.2.1 C.4.2.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_config_db_wait_modified_ignores_other_fields.expected
*/
// Start the waiter before any update. An unrelated write must not wake
// it. A watchdog turns a missing notification into a bounded failure.

module test_config_db_wait_modified_ignores_other_fields;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    static bit woke;
    static int value;
    static bit found;
    // Forked branches share this state. Initialize it at block entry.
    woke = 0;
    value = -1;
    uvm_config_db#(int)::set(null, "scope", "target", 3);
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
            uvm_config_db#(int)::set(null, "scope", "other", 99);
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
