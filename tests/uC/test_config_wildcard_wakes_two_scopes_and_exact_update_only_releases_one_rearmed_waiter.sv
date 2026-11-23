/*
:name: test_config_wildcard_wakes_two_scopes_and_exact_update_only_releases_one_rearmed_waiter
:description: A wildcard set releases both matching waiters, then an exact update releases only its rearmed waiter (IEEE 1800.2-2020 Section C.4.2.2.4)
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.4.2.2.4 C.4.2.2.1 C.4.2.2.2 1800-2023 9.3.2
:uvm: 2020.3.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_config_wildcard_wakes_two_scopes_and_exact_update_only_releases_one_rearmed_waiter.expected
*/
// Two branches wait twice at different leaf paths. A common wildcard write
// must reach both. Once they have rearmed, an exact replacement for the right
// leaf can only finish the right waiter. An exact left replacement then
// completes the other one. Record at distinct times; the two branches never
// compete for the same counter.

module test_config_wildcard_wakes_two_scopes_and_exact_update_only_releases_one_rearmed_waiter;
  import uvm_pkg::*;
  int hits[2] = '{0, 0};
  int latest[2];

  task automatic observe(int slot, string path);
    repeat (2) begin
      uvm_config_db#(int)::wait_modified(null, path, "level");
      if (!uvm_config_db#(int)::get(null, path, "level", latest[slot]))
        $fatal(1, "notification without a matching setting");
      hits[slot]++;
    end
  endtask

  initial begin
    fork
      observe(0, "env.left");
      observe(1, "env.right");
    join_none
    #1;
    uvm_config_db#(int)::set(null, "env.*", "level", 17);
    #1;
    $display("UT: first counts %0d %0d values %0d %0d", hits[0], hits[1], latest[0], latest[1]);
    uvm_config_db#(int)::set(null, "env.right", "level", 29);
    #1;
    $display("UT: right counts %0d %0d values %0d %0d", hits[0], hits[1], latest[0], latest[1]);
    uvm_config_db#(int)::set(null, "env.left", "level", 43);
    #1;
    $display("UT: final counts %0d %0d values %0d %0d", hits[0], hits[1], latest[0], latest[1]);
    $finish;
  end
endmodule
