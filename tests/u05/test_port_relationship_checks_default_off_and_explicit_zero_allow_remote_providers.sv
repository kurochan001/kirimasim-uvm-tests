/*
:name: test_port_relationship_checks_default_off_and_explicit_zero_allow_remote_providers
:description: typed relationship configuration controls remote-provider warnings (5.5.2.14)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.5.2.14 5.5.2.9 6.6.3.7 C.2.4.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_port_relationship_checks_default_off_and_explicit_zero_allow_remote_providers.expected
*/
// What it checks:
// 1. Port hierarchy relationship checks are disabled by default.
// 2. A matching typed relationship resource with value zero disables checking.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 5.5.2.14 (UVM-PORT-RELATIONSHIP-DEFAULT-DISABLED) gives rule
//    1 above. Setup: Connect a compatible implementation below a remote branch
//    without a resource setting. Expected: No warning or error is issued for
//    that hierarchy.
// 2. 1800.2-2020 5.5.2.14 (UVM-PORT-RELATIONSHIP-ZERO-DISABLED) gives rule 2
//    above. Setup: Set check_connection_relationships to zero for owner.p
//    before construction. Expected: The remote connection is retained without
//    warning or error.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The pinned library treats a present zero-valued setting as enabled.
module test_port_relationship_checks_default_off_and_explicit_zero_allow_remote_providers;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class report_probe extends uvm_report_catcher;
    int warnings = 0;
    int errors = 0;
    function new(); super.new("probe"); endfunction
    function action_e catch();
      if (get_action() == UVM_NO_ACTION) return THROW;
      if (get_severity() == UVM_WARNING) begin warnings++; return CAUGHT; end
      if (get_severity() == UVM_ERROR) begin errors++; return CAUGHT; end
      return THROW;
    endfunction
  endclass
  class sink extends uvm_component;
    uvm_blocking_put_imp#(int, sink) imp;
    function new(string name, uvm_component parent);
      super.new(name, parent); imp = new("imp", this);
    endfunction
    task put(int value); endtask
  endclass
  class owner_type extends uvm_component;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass
  // Count actionable warnings only; a disabled report action is not emission.
  // The provider is deliberately below a remote branch, not a legal sibling.
  initial begin
    automatic uvm_resource_pool pool = uvm_resource_pool::get();
    automatic owner_type owner = new("owner", null);
    automatic owner_type branch = new("branch", owner);
    automatic sink remote = new("remote", branch);
    automatic report_probe probe = new();
    automatic uvm_resource#(uvm_bitstream_t) setting;
    automatic uvm_blocking_put_port#(int) p;
    automatic uvm_blocking_put_port#(int) control = new("control", owner, 0);
    uvm_port_base#(uvm_tlm_if_base#(int, int)) connections[string];
    uvm_report_cb::add(null, probe);
    control.connect(remote.imp);
    $display("UT: default warnings %0d errors %0d", probe.warnings, probe.errors);
    setting = new("check_connection_relationships", "owner.p");
    setting.write(0); pool.set_scope(setting, "owner.p");
    p = new("p", owner, 0); p.connect(remote.imp);
    p.get_connected_to(connections);
    $display("UT: configured warnings %0d errors %0d connected %0d",
             probe.warnings, probe.errors, connections.num());
    uvm_report_cb::delete(null, probe);
    $finish;
  end
endmodule
