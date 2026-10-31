/*
:name: test_config_db_build_hierarchy_precedence
:description: higher build-time context has precedence over a later child setting (IEEE 1800.2-2020 Section C.4.2.2.1)
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.4.2.2.1 C.4.2.2.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:args: +UVM_TESTNAME=t
:expected_stdout: @test_config_db_build_hierarchy_precedence.expected
*/
// During build, a higher context takes precedence. The child writes later
// from a lower context, then reads the value installed by the test.

module test_config_db_build_hierarchy_precedence;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

class reader extends uvm_component;
    `uvm_component_utils(reader)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void build_phase(uvm_phase phase);
    int value = -1;
    bit found;
    uvm_config_db#(int)::set(this, "", "limit", 12);
    found = uvm_config_db#(int)::get(this, "", "limit", value);
    $display("UT: build found %0d value %0d", found, value);
  endfunction
endclass
class t extends uvm_test;
  `uvm_component_utils(t)
  reader child;
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void build_phase(uvm_phase phase);
    uvm_config_db#(int)::set(this, "child", "limit", 84);
    child = new("child", this);
  endfunction
endclass
initial run_test();
endmodule
