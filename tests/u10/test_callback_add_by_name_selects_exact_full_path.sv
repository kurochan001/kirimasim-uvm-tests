/*
:name: test_callback_add_by_name_selects_exact_full_path
:description: callback add by name selects an exact component full path within the chosen root (IEEE 1800.2-2020 Section 10.7.2.3.2)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.7.2.3.2 F.7.4.1 B.4.1 B.4.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_callback_add_by_name_selects_exact_full_path.expected
*/
// What it checks:
// Name-based callback addition searches matching existing components from the
// supplied root.
//
// How the expected output follows from the standard:
// 1800.2-2020 10.7.2.3.2 (UVM-CALLBACK-ADD-BY-NAME) gives the rule above.
// Setup: Use an exact full path and a glob that also matches a component
// outside the search root. Expected: Only the matching components within the
// search root receive the callback.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Create the component hierarchy first and use its full path in the
// match expression. Invoke matching and nonmatching objects explicitly.

module test_callback_add_by_name_selects_exact_full_path;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class user_callback extends uvm_callback;
    `uvm_object_utils(user_callback)
    int calls = 0;
    bit answer = 0;
    function new(string name="user_callback");
      super.new(name);
      void'(callback_mode(1));
    endfunction
    virtual function void hit();
      calls++;
      $display("UT: hit %s", get_name());
    endfunction
    virtual function bit vote();
      calls++;
      $display("UT: vote %s", get_name());
      return answer;
    endfunction
  endclass
  class agent extends uvm_component;
    `uvm_component_utils(agent)
    `uvm_register_cb(agent, user_callback)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void fire();
      `uvm_do_callbacks(agent, user_callback, hit())
    endfunction
    function bit stop_on_true();
      `uvm_do_callbacks_exit_on(agent, user_callback, vote(), 1)
      return 0;
    endfunction
    function bit stop_on_false();
      `uvm_do_callbacks_exit_on(agent, user_callback, vote(), 0)
      return 1;
    endfunction
  endclass
  typedef uvm_callbacks#(agent, user_callback) pool_t;

  initial begin
    automatic agent tree = new("tree", null);
    automatic agent left = new("left", tree);
    automatic agent right = new("right", tree);
    automatic user_callback value = new("value");
    pool_t::add_by_name("tree.left", value, tree);
    left.fire();
    right.fire();
    $display("UT: calls %0d", value.calls);
    $finish;
  end
endmodule
