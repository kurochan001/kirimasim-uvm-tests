/*
:name: test_callback_get_all_includes_disabled_and_preserves_prefix
:description: get_all appends enabled and disabled registrations without changing existing entries (IEEE 1800.2-2020 Section 10.7.2.5)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.7.2.5 10.7.2.3.1 10.7.1.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_callback_get_all_includes_disabled_and_preserves_prefix.expected
*/
// The queue prefix contains a callback that is not registered. Compare
// membership after the prefix without depending on collection order.

module test_callback_get_all_includes_disabled_and_preserves_prefix;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class user_callback extends uvm_callback;
    `uvm_object_utils(user_callback)
    int calls = 0;
    function new(string name="user_callback");
      super.new(name);
      void'(callback_mode(1));
    endfunction
    virtual function void hit();
      calls++;
      $display("UT: hit %s", get_name());
    endfunction
  endclass
  class agent extends uvm_component;
    `uvm_component_utils(agent)
    `uvm_register_cb(agent, user_callback)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void fire();
      `uvm_do_callbacks(agent, user_callback, hit())
    endfunction
  endclass
  typedef uvm_callbacks#(agent, user_callback) pool_t;

  initial begin
    automatic agent context_value = new("context_value", null);
    automatic user_callback enabled = new("enabled");
    automatic user_callback disabled = new("disabled");
    automatic user_callback sentinel = new("sentinel");
    user_callback all_callbacks[$];
    int enabled_count;
    int disabled_count;
    void'(disabled.callback_mode(0));
    pool_t::add(context_value, enabled);
    pool_t::add(context_value, disabled);
    all_callbacks.push_back(sentinel);
    pool_t::get_all(all_callbacks, context_value);
    if (all_callbacks.size() < 1) $fatal(1, "queue prefix lost");
    enabled_count = 0;
    disabled_count = 0;
    foreach (all_callbacks[i]) if (i >= 1) begin
      if (all_callbacks[i] == enabled) enabled_count++;
      if (all_callbacks[i] == disabled) disabled_count++;
    end
    $display("UT: size %0d prefix_same %0d enabled %0d disabled %0d", all_callbacks.size(),
             all_callbacks[0] == sentinel, enabled_count, disabled_count);
    $finish;
  end
endmodule
