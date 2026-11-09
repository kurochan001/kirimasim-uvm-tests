/*
:name: test_port_connection_queries_include_the_connected_and_served_handles
:description: connection queries expose exact immediate providers and clients without relying on key/order (5.5.2.9)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.5.2.9 5.5.2.10 5.5.2.14 12.2.5.1 12.2.6.1 12.2.7.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_port_connection_queries_include_the_connected_and_served_handles.expected
*/
// What it checks:
// 1. Connection queries include each exact immediate provider handle.
// 2. A provider query includes the exact client port served by the export.
// 3. Compatible typed port/export/implementation bindings establish the
//    selected provider chain.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 5.5.2.9 (UVM-PORT-CONNECTED-PROVIDER-MEMBERSHIP) gives rule 1
//    above. Setup: Connect one int blocking-put port to an export and that
//    export to a matching implementation. Expected: Port lists its export and
//    export lists its implementation.
// 2. 1800.2-2020 5.5.2.10 (UVM-PORT-PROVIDED-CLIENT-MEMBERSHIP) gives rule 2
//    above. Setup: Connect one int blocking-put port to an export and that
//    export to a matching implementation. Expected: The export provided-to
//    list contains the exact requesting port.
// 3. 1800.2-2020 5.5.2.14 (UVM-PORT-COMPATIBLE-CONNECTION-CHAIN) gives rule 3
//    above. Setup: Connect one int blocking-put port to an export and that
//    export to a matching implementation. Expected: Exact provider, client and
//    implementation memberships are observed after connect.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_port_connection_queries_include_the_connected_and_served_handles;
  import uvm_pkg::*;
  class sink extends uvm_component;
    uvm_blocking_put_imp#(int, sink) imp;
    int calls = 0;
    int last = 0;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      imp = new("imp", this);
    endfunction
    task put(int value); #1; calls++; last = value; endtask
  endclass
  initial begin
    automatic sink owner = new("owner", null);
    automatic uvm_blocking_put_port#(int) p = new("p", owner);
    automatic uvm_blocking_put_export#(int) e = new("e", owner);
    uvm_port_base#(uvm_tlm_if_base#(int, int)) connected[string];
    uvm_port_base#(uvm_tlm_if_base#(int, int)) provided[string];
    bit found_provider, found_client, found_imp;
    p.connect(e);
    e.connect(owner.imp);
    p.get_connected_to(connected);
    e.get_provided_to(provided);
    found_provider = 0;
    found_client = 0;
    foreach (connected[key]) if (connected[key] == e) found_provider = 1;
    foreach (provided[key]) if (provided[key] == p) found_client = 1;
    connected.delete();
    e.get_connected_to(connected);
    found_imp = 0;
    foreach (connected[key]) if (connected[key] == owner.imp) found_imp = 1;
    $display("UT: provider %0d client %0d implementation %0d",
             found_provider, found_client, found_imp);
    $finish;
  end
endmodule
