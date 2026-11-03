/*
:name: test_port_invalid_export_and_implementation_directions_are_rejected
:description: exports cannot connect to a port and implementations cannot have outgoing bindings (5.5.2.14)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.5.2.14 5.5.2.9 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_port_invalid_export_and_implementation_directions_are_rejected.expected
*/
module test_port_invalid_export_and_implementation_directions_are_rejected;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class report_probe extends uvm_report_catcher;
    int warnings = 0;
    int errors = 0;
    function new(); super.new("probe"); endfunction
    function action_e catch();
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
  initial begin
    automatic sink owner = new("owner", null);
    automatic sink peer = new("peer", null);
    automatic uvm_blocking_put_port#(int) p = new("p", owner, 0);
    automatic uvm_blocking_put_export#(int) e = new("e", owner, 0);
    automatic report_probe probe = new();
    uvm_port_base#(uvm_tlm_if_base#(int, int)) connections[string];
    uvm_report_cb::add(null, probe);
    e.connect(p); e.get_connected_to(connections);
    $display("UT: export rejected %0d", connections.num() == 0);
    probe.warnings = 0; probe.errors = 0; connections.delete();
    owner.imp.connect(peer.imp); owner.imp.get_connected_to(connections);
    $display("UT: implementation rejected %0d", connections.num() == 0);
    uvm_report_cb::delete(null, probe);
    $finish;
  end
endmodule
