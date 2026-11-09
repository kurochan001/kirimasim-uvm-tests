/*
:name: test_object_default_type_lookup_tracks_the_current_registered_type_name
:description: default get_object_type looks up the current virtual type-name result (IEEE 1800.2-2020 Section 5.3.4.6)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.4.6 5.3.4.5 5.3.4.7 5.3.4.1 8.3.1.5 B.2.1.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_default_type_lookup_tracks_the_current_registered_type_name.expected
*/
// What it checks:
// 1. Default get_object_type returns null for an unregistered virtual type
//    name.
// 2. Default get_object_type looks up the current virtual type-name result in
//    the factory.
// 3. The default proxy lookup uses type name independently of instance name.
// 4. Changing one default-lookup object does not change its peer type-name
//    lookup.
// 5. Returning to an unregistered type name clears the formerly resolved proxy
//    result.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 5.3.4.6 (UVM-OBJECT-TRAIT-DEFAULT-UNKNOWN-NULL) gives rule 1
//    above. Setup: The lookup object initially reports a unique unregistered
//    type name. Expected: Its proxy is null, as is the independent peer proxy.
// 2. 1800.2-2020 5.3.4.6 (UVM-OBJECT-TRAIT-DEFAULT-REGISTERED-LOOKUP) gives
//    rule 2 above. Setup: The controlled type-name result changes to
//    registered_value. Expected: The returned proxy matches the registered
//    wrapper.
// 3. 1800.2-2020 5.3.4.6 (UVM-OBJECT-TRAIT-DEFAULT-INSTANCE-NAME-INDEPENDENCE)
//    gives rule 3 above. Setup: Instance name changes while virtual type name
//    remains registered_value. Expected: Lookup still returns the registered
//    proxy.
// 4. 1800.2-2020 5.3.4.6 (UVM-OBJECT-TRAIT-DEFAULT-LOOKUP-PEER-ISOLATION)
//    gives rule 4 above. Setup: One object changes its lookup name while the
//    peer remains unregistered. Expected: The changed object resolves and the
//    peer remains null.
// 5. 1800.2-2020 5.3.4.6 (UVM-OBJECT-TRAIT-DEFAULT-LOOKUP-REFRESH) gives rule
//    5 above. Setup: The same object changes from known type name back to the
//    unknown name. Expected: The new query returns null.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The lookup class inherits default get_object_type. It exposes
// a controlled type-name string, while the registered peer uses standard
// macros.
// No warning text or lookup-diagnostic count is constrained.
module test_object_default_type_lookup_tracks_the_current_registered_type_name;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class registered_value extends uvm_object;
    `uvm_object_utils(registered_value)
    function new(string name="registered"); super.new(name); endfunction
  endclass
  class lookup_value extends uvm_object;
    string lookup_name = "unregistered_type_28";
    function new(string name="lookup"); super.new(name); endfunction
    virtual function string get_type_name(); return lookup_name; endfunction
    virtual function uvm_object create(string name="");
      automatic lookup_value item = new(name); return item;
    endfunction
  endclass
  initial begin
    automatic lookup_value item = new("item");
    automatic lookup_value peer = new("peer");
    automatic uvm_object_wrapper known = registered_value::get_type();
    automatic uvm_object base_handle = item;
    $display("UT: unknown_null %0d peer_null %0d", base_handle.get_object_type() == null,
             peer.get_object_type() == null);
    item.lookup_name = "registered_value";
    $display("UT: registered %0d peer_still_null %0d", base_handle.get_object_type() == known,
             peer.get_object_type() == null);
    item.set_name("other_instance");
    $display("UT: instance_rename %0d", base_handle.get_object_type() == known);
    item.lookup_name = "unregistered_type_28";
    $display("UT: unknown_again %0d", base_handle.get_object_type() == null);
    $finish;
  end
endmodule
