/*
:name: test_component_abstract_utils_create_the_overriding_concrete_components
:description: the abstract component utility macros register virtual component classes whose creation gives the overriding concrete component, in the plain, parameterized and begin forms (IEEE 1800.2-2020 Section B.2.1.3)
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.2.1.3 B.2.2.1.1 8.2.5 8.2.5.1 8.2.5.1.3 8.2.5.1.5 8.2.5.1.6 5.3.9.1 13.1.2.1 1800-2023 6.21 8.21 8.25
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_abstract_utils_create_the_overriding_concrete_components.expected
*/
// What it checks:
// 1. `uvm_component_abstract_utils and `uvm_component_abstract_param_utils
//    register a virtual component class, so that creating it through type_id
//    gives the concrete component that overrides it.
// 2. The plain form registers the type name, as `uvm_component_utils does.
// 3. The two begin forms also provide the field operations of the macros up
//    to `uvm_component_utils_end.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 B.2.1.3 (UVM-ABSTRACT-UTILS-COMPONENT-OVERRIDE) gives rule 1:
//    the abstract forms differ from the others only in the registry, and 8.2.5
//    has the user provide an override for a registered abstract class. Setup:
//    override stage by real_stage and lane#(3) by lane_three (8.2.5.1.6), then
//    create stage and lane#(3) with a null parent (8.2.5.1.5). Expected: the
//    components are a real_stage of kind 1 and a lane_three with 3 lanes.
// 2. 1800.2-2020 B.2.1.3 (UVM-ABSTRACT-UTILS-COMPONENT-NAME) gives rule 2 with
//    8.2.5.1.3. Expected: the proxy of stage has the type name stage.
// 3. 1800.2-2020 B.2.1.3 (UVM-ABSTRACT-UTILS-COMPONENT-FIELDS) gives rule 3
//    with B.2.2.1.1. Setup: for gauge and for meter#(5), create two overriding
//    components and compare them (5.3.9.1) with equal and then with different
//    fields. Expected: 1, then 0, for both.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Creating an abstract component without an override, which 8.2.5 makes an
// error, is left to the tests of the abstract registries; run_test is not
// called.
module test_component_abstract_utils_create_the_overriding_concrete_components;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  virtual class stage extends uvm_component;
    `uvm_component_abstract_utils(stage)
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    pure virtual function int kind();
  endclass
  class real_stage extends stage;
    `uvm_component_utils(real_stage)
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    virtual function int kind();
      return 1;
    endfunction
  endclass

  virtual class lane #(int N=1) extends uvm_component;
    `uvm_component_abstract_param_utils(lane#(N))
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    pure virtual function int lanes();
  endclass
  class lane_three extends lane#(3);
    `uvm_component_utils(lane_three)
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    virtual function int lanes();
      return N;
    endfunction
  endclass

  virtual class gauge extends uvm_component;
    int reading;
    `uvm_component_abstract_utils_begin(gauge)
      `uvm_field_int(reading, UVM_DEFAULT)
    `uvm_component_utils_end
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass
  class real_gauge extends gauge;
    `uvm_component_utils(real_gauge)
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass

  virtual class meter #(int W=8) extends uvm_component;
    bit [W-1:0] level;
    `uvm_component_abstract_param_utils_begin(meter#(W))
      `uvm_field_int(level, UVM_DEFAULT)
    `uvm_component_utils_end
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass
  class meter_five extends meter#(5);
    `uvm_component_utils(meter_five)
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass

  initial begin
    automatic uvm_object_wrapper stage_proxy = stage::get_type();
    stage made_stage;
    lane#(3) made_lane;
    gauge gauge_a;
    gauge gauge_b;
    meter#(5) meter_a;
    meter#(5) meter_b;
    bit gauge_equal;
    bit gauge_changed;
    bit meter_equal;
    bit meter_changed;
    stage::type_id::set_type_override(real_stage::get_type());
    lane#(3)::type_id::set_type_override(lane_three::get_type());
    gauge::type_id::set_type_override(real_gauge::get_type());
    meter#(5)::type_id::set_type_override(meter_five::get_type());
    made_stage = stage::type_id::create("made_stage", null);
    made_lane = lane#(3)::type_id::create("made_lane", null);
    $display("UT: created kind %0d lanes %0d stage_name %s", made_stage.kind(),
             made_lane.lanes(), stage_proxy.get_type_name());
    gauge_a = gauge::type_id::create("gauge_a", null);
    gauge_b = gauge::type_id::create("gauge_b", null);
    gauge_a.reading = 12;
    gauge_b.reading = 12;
    gauge_equal = gauge_a.compare(gauge_b);
    gauge_b.reading = 13;
    gauge_changed = gauge_a.compare(gauge_b);
    meter_a = meter#(5)::type_id::create("meter_a", null);
    meter_b = meter#(5)::type_id::create("meter_b", null);
    meter_a.level = 5'h1b;
    meter_b.level = 5'h1b;
    meter_equal = meter_a.compare(meter_b);
    meter_b.level = 5'h04;
    meter_changed = meter_a.compare(meter_b);
    $display("UT: gauge equal %0d changed %0d meter equal %0d changed %0d", gauge_equal,
             gauge_changed, meter_equal, meter_changed);
    $finish;
  end
endmodule
