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
