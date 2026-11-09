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
// What it checks:
// 1. Factory-created objects expose their supplied instance name.
// 2. Plain objects do not acquire hierarchy from factory lookup context.
// 3. get_name preserves a supplied dotted instance-name string.
// 4. The default full name equals the object name even when the name contains
//    a dot.
// 5. An explicitly cleared instance name is returned as empty.
// 6. A plain object with an empty name has an empty default full name.
// 7. Renaming one object leaves a separately created peer full name unchanged.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 5.3.4.2 (UVM-OBJECT-TRAIT-FACTORY-INSTANCE-NAME) gives rule 1
//    above. Setup: Factory lookup context is context.branch and the requested
//    object name is leaf. Expected: The name getter returns leaf.
// 2. 1800.2-2020 5.3.4.3 (UVM-OBJECT-TRAIT-NO-IMPLICIT-HIERARCHY) gives rule 2
//    above. Setup: The registered class inherits the default full-name
//    implementation. Expected: The full name is leaf, without the lookup
//    context prefix.
// 3. 1800.2-2020 5.3.4.2 (UVM-OBJECT-TRAIT-DOTTED-INSTANCE-NAME) gives rule 3
//    above. Setup: The object is renamed to literal.segment. Expected: The
//    name is literal.segment.
// 4. 1800.2-2020 5.3.4.3 (UVM-OBJECT-TRAIT-DOTTED-FULL-NAME) gives rule 4
//    above. Setup: The plain object is renamed to literal.segment. Expected:
//    Full name is exactly literal.segment.
// 5. 1800.2-2020 5.3.4.2 (UVM-OBJECT-TRAIT-EMPTY-INSTANCE-NAME) gives rule 5
//    above. Setup: After a dotted name, set_name receives an empty string.
//    Expected: The name getter is empty.
// 6. 1800.2-2020 5.3.4.3 (UVM-OBJECT-TRAIT-EMPTY-FULL-NAME) gives rule 6
//    above. Setup: The same plain object has its name cleared. Expected: The
//    full-name getter is empty.
// 7. 1800.2-2020 5.3.4.3 (UVM-OBJECT-TRAIT-PEER-FULL-NAME-ISOLATION) gives
//    rule 7 above. Setup: Two objects are created with different lookup
//    contexts and names. Expected: Peer full name stays peer through rename
//    and clearing.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
