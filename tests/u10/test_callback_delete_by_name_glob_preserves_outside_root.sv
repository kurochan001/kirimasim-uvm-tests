/*
:name: test_callback_delete_by_name_glob_preserves_outside_root
:description: callback delete by name glob leaves matching components outside the search root unchanged (IEEE 1800.2-2020 Section 10.7.2.3.4)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.7.2.3.4 10.7.2.3.1 F.7.4.1 B.4.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_callback_delete_by_name_glob_preserves_outside_root.expected
*/
// Install the same callback on inside and outside leaves. Delete the
// inside subtree by name, then invoke all three leaves explicitly.

module test_callback_delete_by_name_glob_preserves_outside_root;
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
    automatic agent first = new("first", tree);
    automatic agent second = new("second", tree);
    automatic agent outside = new("outside", null);
    automatic agent left_leaf = new("leaf", first);
    automatic agent right_leaf = new("leaf", second);
    automatic agent outside_leaf = new("leaf", outside);
    automatic user_callback value = new("value");
    pool_t::add(left_leaf, value);
    pool_t::add(right_leaf, value);
    pool_t::add(outside_leaf, value);
    pool_t::delete_by_name("*.leaf", value, tree);
    left_leaf.fire();
    right_leaf.fire();
    outside_leaf.fire();
    $display("UT: calls %0d", value.calls);
    $finish;
  end
endmodule
