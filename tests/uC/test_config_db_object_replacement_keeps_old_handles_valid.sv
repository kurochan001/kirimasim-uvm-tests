/*
:name: test_config_db_object_replacement_keeps_old_handles_valid
:description: replacing a configured object changes future gets without retargeting old handles (IEEE 1800.2-2020 Section C.4.2.2.1)
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.4.2.2.1 C.4.2.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_config_db_object_replacement_keeps_old_handles_valid.expected
*/
// A retrieved handle remains bound to its original object when the same
// setting is replaced. A later get selects the replacement object instead.

module test_config_db_object_replacement_keeps_old_handles_valid;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class item extends uvm_object;
    `uvm_object_utils(item)
    int payload = 0;
    function new(string name="item"); super.new(name); endfunction
  endclass

  initial begin
    automatic item first = new("first");
    automatic item second = new("second");
    item cached;
    item current;
    bit found;
    first.payload = 7;
    second.payload = 11;
    uvm_config_db#(item)::set(null, "env", "packet", first);
    found = uvm_config_db#(item)::get(null, "env", "packet", cached);
    $display("UT: first found %0d cached %0d", found, cached == first);
    uvm_config_db#(item)::set(null, "env", "packet", second);
    found = uvm_config_db#(item)::get(null, "env", "packet", current);
    cached.payload = 29;
    $display("UT: replacement found %0d current %0d old_retained %0d", found,
        current == second, cached == first);
    $display("UT: values old %0d current %0d", cached.payload, current.payload);
    $finish;
  end
endmodule
