/*
:name: test_tlm2_blocking_socket_constructors_preserve_kind_bounds_and_parent
:description: blocking sockets expose standard constructor roles and connection bounds (IEEE 1800.2-2020 Section 12.3.5.1.3)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.5.1.3 12.3.5.2.3 12.3.5.7.3 12.3.5.8.3 5.5.2 13.1.3.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_blocking_socket_constructors_preserve_kind_bounds_and_parent.expected
*/
// What it checks:
// 1. The socket constructor retains its specified port role and one-to-one
//    connection bounds.
// 2. The socket constructor retains its specified port role and one-to-one
//    connection bounds.
// 3. The socket constructor retains its specified port role and one-to-one
//    connection bounds.
// 4. The socket constructor retains its specified port role and one-to-one
//    connection bounds.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.3.5.1.3 (UVM-TLM2-BLOCKING-TARGET-CONSTRUCTOR) gives rule
//    1 above. Setup: Construct the socket under a compatible parent and query
//    role, min/max sizes and parent. Expected: The expected
//    implementation/port/export predicate is true, both bounds are one and
//    parent identity matches.
// 2. 1800.2-2020 12.3.5.2.3 (UVM-TLM2-BLOCKING-INITIATOR-CONSTRUCTOR) gives
//    rule 2 above. Setup: Construct the socket under a compatible parent and
//    query role, min/max sizes and parent. Expected: The expected
//    implementation/port/export predicate is true, both bounds are one and
//    parent identity matches.
// 3. 1800.2-2020 12.3.5.8.3 (UVM-TLM2-BLOCKING-RELAY-TARGET-CONSTRUCTOR) gives
//    rule 3 above. Setup: Construct the socket under a compatible parent and
//    query role, min/max sizes and parent. Expected: The expected
//    implementation/port/export predicate is true, both bounds are one and
//    parent identity matches.
// 4. 1800.2-2020 12.3.5.7.3 (UVM-TLM2-BLOCKING-RELAY-INITIATOR-CONSTRUCTOR)
//    gives rule 4 above. Setup: Construct the socket under a compatible parent
//    and query role, min/max sizes and parent. Expected: The expected
//    implementation/port/export predicate is true, both bounds are one and
//    parent identity matches.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Constructor metadata only, before binding resolution. Omitted IMP uses
// a compatible parent; no transport execution or backward binding is claimed.
module test_tlm2_blocking_socket_constructors_preserve_kind_bounds_and_parent;
  import uvm_pkg::*;

  class endpoint extends uvm_component;

    uvm_tlm_b_target_socket#(endpoint) target;
    uvm_tlm_b_initiator_socket#() initiator;
    uvm_tlm_b_passthrough_target_socket#() relay_target;
    uvm_tlm_b_passthrough_initiator_socket#() relay_initiator;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      target = new("target", this); initiator = new("initiator", this);
      relay_target = new("relay_target", this); relay_initiator = new("relay_initiator", this);
    endfunction

    task b_transport(uvm_tlm_generic_payload t, uvm_tlm_time delay); endtask
  endclass

  initial begin
    endpoint owner;
    owner = new("owner", null);
    $display("UT: target kind %0d bounds %0d/%0d parent %0d", owner.target.is_imp(),
             owner.target.min_size(), owner.target.max_size(), owner.target.get_parent() == owner);
    $display("UT: initiator kind %0d bounds %0d/%0d parent %0d", owner.initiator.is_port(),
             owner.initiator.min_size(), owner.initiator.max_size(),
             owner.initiator.get_parent() == owner);
    $display("UT: relay_target kind %0d bounds %0d/%0d parent %0d", owner.relay_target.is_export(),
             owner.relay_target.min_size(), owner.relay_target.max_size(),
             owner.relay_target.get_parent() == owner);
    $display("UT: relay_initiator kind %0d bounds %0d/%0d parent %0d",
    owner.relay_initiator.is_port(),
             owner.relay_initiator.min_size(), owner.relay_initiator.max_size(),
             owner.relay_initiator.get_parent() == owner);
    $finish;
  end

endmodule
