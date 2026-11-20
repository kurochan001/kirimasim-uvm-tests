/*
:name: test_component_utils_begin_and_param_utils_register_components_with_fields
:description: the component utility macros with a field block and the parameterized forms register components, give each specialization its own proxy and provide field operations (IEEE 1800.2-2020 Section B.2.1.3)
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.2.1.3 B.2.2.1.1 5.3.4.5 5.3.4.6 5.3.4.7 5.3.9.1 8.2.3.2.4 13.1.2.1 1800-2023 6.21 8.25
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_utils_begin_and_param_utils_register_components_with_fields.expected
*/
// What it checks:
// 1. `uvm_component_utils_begin with `uvm_component_utils_end registers a
//    component as `uvm_component_utils does and adds the field operations of
//    the macros between them.
// 2. `uvm_component_param_utils gives each specialization of a parameterized
//    component a type_id, a get_type and a get_object_type of its own.
// 3. `uvm_component_param_utils_begin also adds the field operations.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 B.2.1.3 (UVM-COMPONENT-UTILS-BEGIN-FIELDS) gives rule 1 with
//    B.2.2.1.1. Setup: create two knob_comp through type_id::create
//    (8.2.3.2.4) with a null parent, give both the knob 5 and compare them
//    (5.3.9.1), then change one knob. Expected: get_type_name (5.3.4.7) is
//    knob_comp, the equal components compare as 1 and the changed ones as 0.
// 2. 1800.2-2020 B.2.1.3 (UVM-PARAM-UTILS-COMPONENT-PROXY) gives rule 2.
//    Setup: create width_comp#(8) and width_comp#(16). Expected: they report
//    the widths 8 and 16, their proxies (5.3.4.5) differ, and each component's
//    get_object_type (5.3.4.6) is the proxy of its own specialization.
// 3. 1800.2-2020 B.2.1.3 (UVM-PARAM-UTILS-COMPONENT-FIELDS) gives rule 3.
//    Setup: compare two sized_comp#(4) with equal and then with different
//    levels. Expected: 1, then 0.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The components are constructed with a null parent before run_test, which
// is not called; the type name of a parameterized component is not observed.
module test_component_utils_begin_and_param_utils_register_components_with_fields;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class knob_comp extends uvm_component;
    int knob;
    `uvm_component_utils_begin(knob_comp)
      `uvm_field_int(knob, UVM_DEFAULT)
    `uvm_component_utils_end
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass

  class width_comp #(int W=8) extends uvm_component;
    `uvm_component_param_utils(width_comp#(W))
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    function int width();
      return W;
    endfunction
  endclass

  class sized_comp #(int W=8) extends uvm_component;
    bit [W-1:0] level;
    `uvm_component_param_utils_begin(sized_comp#(W))
      `uvm_field_int(level, UVM_DEFAULT)
    `uvm_component_utils_end
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass

  initial begin
    automatic knob_comp first = knob_comp::type_id::create("first", null);
    automatic knob_comp second = knob_comp::type_id::create("second", null);
    automatic width_comp#(8) narrow = width_comp#(8)::type_id::create("narrow", null);
    automatic width_comp#(16) wide = width_comp#(16)::type_id::create("wide", null);
    automatic uvm_object_wrapper narrow_proxy = width_comp#(8)::get_type();
    automatic uvm_object_wrapper wide_proxy = width_comp#(16)::get_type();
    automatic sized_comp#(4) left = sized_comp#(4)::type_id::create("left", null);
    automatic sized_comp#(4) right = sized_comp#(4)::type_id::create("right", null);
    bit equal;
    bit changed;
    first.knob = 5;
    second.knob = 5;
    equal = first.compare(second);
    second.knob = 6;
    changed = first.compare(second);
    $display("UT: knob_comp name %s equal %0d changed %0d", first.get_type_name(), equal,
             changed);
    $display("UT: widths %0d %0d proxies_differ %0d own_proxy %0d %0d", narrow.width(),
             wide.width(), narrow_proxy != wide_proxy,
             narrow.get_object_type() == narrow_proxy, wide.get_object_type() == wide_proxy);
    left.level = 4'h9;
    right.level = 4'h9;
    equal = left.compare(right);
    right.level = 4'h6;
    changed = left.compare(right);
    $display("UT: sized_comp equal %0d changed %0d", equal, changed);
    $finish;
  end
endmodule
