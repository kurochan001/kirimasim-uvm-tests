/*
:name: test_resource_pool_default_precedence_updates_only_future_resources_implicit_assignments
:description: Default precedence wrappers agree with core service and affect future/default assignments without changing peers
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.2.4.5.4 C.2.4.5.5 C.2.4.5.6 C.2.4.5.7 C.2.4.3.1 F.4.1.4.23 F.4.1.4.24 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_resource_pool_default_precedence_updates_only_future_resources_implicit_assignments.expected
*/
// What it checks:
// 1. The pool default-precedence setter updates the core-service default.
// 2. The pool default-precedence getter agrees with the core-service getter.
// 3. A selected resource accepts explicit precedence or the current
//    omitted-argument default.
// 4. A registered resource query returns its own assigned numeric precedence.
// 5. Changing the service default does not change resources already stored in
//    the pool.
// 6. The unoverridden service default precedence is one thousand.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 C.2.4.5.4 (UVM-RESOURCE-AUDIT-DEFAULT-PRECEDENCE-SET) gives
//    rule 1 above. Setup: Capture the initial default, store one explicit
//    resource, change the default before inserting an already constructed
//    peer, then change it again and omit an assignment argument. Restore the
//    initial value. Expected: Initial default/core views agree at 1000; later
//    values are 58/59, an existing explicit eleven stays until reassigned, and
//    the peer retains 58.
// 2. 1800.2-2020 C.2.4.5.5 (UVM-RESOURCE-AUDIT-DEFAULT-PRECEDENCE-GET) gives
//    rule 2 above. Setup: Capture the initial default, store one explicit
//    resource, change the default before inserting an already constructed
//    peer, then change it again and omit an assignment argument. Restore the
//    initial value. Expected: Initial default/core views agree at 1000; later
//    values are 58/59, an existing explicit eleven stays until reassigned, and
//    the peer retains 58.
// 3. 1800.2-2020 C.2.4.5.6 (UVM-RESOURCE-AUDIT-PRECEDENCE-ASSIGN) gives rule 3
//    above. Setup: Capture the initial default, store one explicit resource,
//    change the default before inserting an already constructed peer, then
//    change it again and omit an assignment argument. Restore the initial
//    value. Expected: Initial default/core views agree at 1000; later values
//    are 58/59, an existing explicit eleven stays until reassigned, and the
//    peer retains 58.
// 4. 1800.2-2020 C.2.4.5.7 (UVM-RESOURCE-AUDIT-PRECEDENCE-QUERY) gives rule 4
//    above. Setup: Capture the initial default, store one explicit resource,
//    change the default before inserting an already constructed peer, then
//    change it again and omit an assignment argument. Restore the initial
//    value. Expected: Initial default/core views agree at 1000; later values
//    are 58/59, an existing explicit eleven stays until reassigned, and the
//    peer retains 58.
// 5. 1800.2-2020 F.4.1.4.23 (UVM-RESOURCE-AUDIT-SERVICE-DEFAULT-FUTURE) gives
//    rule 5 above. Setup: Capture the initial default, store one explicit
//    resource, change the default before inserting an already constructed
//    peer, then change it again and omit an assignment argument. Restore the
//    initial value. Expected: Initial default/core views agree at 1000; later
//    values are 58/59, an existing explicit eleven stays until reassigned, and
//    the peer retains 58.
// 6. 1800.2-2020 F.4.1.4.24 (UVM-RESOURCE-AUDIT-SERVICE-DEFAULT-INITIAL) gives
//    rule 6 above. Setup: Capture the initial default, store one explicit
//    resource, change the default before inserting an already constructed
//    peer, then change it again and omit an assignment argument. Restore the
//    initial value. Expected: Initial default/core views agree at 1000; later
//    values are 58/59, an existing explicit eleven stays until reassigned, and
//    the peer retains 58.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module
  test_resource_pool_default_precedence_updates_only_future_resources_implicit_assignments;
  import uvm_pkg::*;
  initial begin
    automatic uvm_coreservice_t core=uvm_coreservice_t::get();
    automatic uvm_resource_pool pool=uvm_resource_pool::get();
    automatic int unsigned saved=uvm_resource_pool::get_default_precedence();
    automatic uvm_resource#(int) existing=new("existing58");
    automatic uvm_resource#(int) future_resource=new("future58");
    $display("UT: precedence_default initial %0d core_view %0d",saved==1000,
      saved==core.get_resource_pool_default_precedence());
    pool.set_scope(existing,"scope58"); pool.set_precedence(existing,11);
    uvm_resource_pool::set_default_precedence(58); pool.set_scope(future_resource,"scope58");
    $display("UT: precedence_default changed %0d existing %0d future %0d",
      core.get_resource_pool_default_precedence()==58 &&
      uvm_resource_pool::get_default_precedence()==58,
      pool.get_precedence(existing)==11,pool.get_precedence(future_resource)==58);
    core.set_resource_pool_default_precedence(59); pool.set_precedence(existing);
    $display("UT: precedence_default implicit_assignment %0d peer_unchanged %0d",
      pool.get_precedence(existing)==59,pool.get_precedence(future_resource)==58);
    uvm_resource_pool::set_default_precedence(saved); $finish;
  end
endmodule
