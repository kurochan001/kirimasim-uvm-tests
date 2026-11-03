/*
:name: test_factory_object_context_does_not_add_hierarchy_to_instance_names
:description: factory lookup context does not change nonhierarchical object name accessors (IEEE 1800.2-2020 Section 5.3.4.2)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.4.2 5.3.4.3 5.3.4.1 8.3.1.4.2 B.2.1.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_factory_object_context_does_not_add_hierarchy_to_instance_names.expected
*/
// A plain object inherits default get_full_name. Factory context
// is used for lookup; this fixture adds no object hierarchy or component
// parent.
module test_factory_object_context_does_not_add_hierarchy_to_instance_names;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class named_value extends uvm_object;
    `uvm_object_utils(named_value)
    function new(string name=""); super.new(name); endfunction
  endclass
  initial begin
    automatic uvm_factory factory = uvm_factory::get();
    uvm_object item, peer;
    item = factory.create_object_by_type(named_value::get_type(), "context.branch", "leaf");
    peer = factory.create_object_by_type(named_value::get_type(), "other.branch", "peer");
    if (item == null || peer == null) $fatal(1, "missing object");
    $display("UT: created name %s full %s peer %s", item.get_name(), item.get_full_name(),
             peer.get_full_name());
    item.set_name("literal.segment");
    $display("UT: renamed name %s full %s peer %s", item.get_name(), item.get_full_name(),
             peer.get_full_name());
    item.set_name("");
    $display("UT: cleared name %0d full %0d peer %s", item.get_name() == "",
             item.get_full_name() == "", peer.get_full_name());
    $finish;
  end
endmodule
