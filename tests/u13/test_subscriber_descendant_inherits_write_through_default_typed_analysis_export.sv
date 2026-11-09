/*
:name: test_subscriber_descendant_inherits_write_through_default_typed_analysis_export
:description: Inherited subscriber write receives default-int export traffic (13.9.3.2)
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.9 13.9.1 13.9.2 13.9.3.1 13.9.3.2 1800-2023 6.21 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_subscriber_descendant_inherits_write_through_default_typed_analysis_export.expected
*/
// What it checks:
// 1. A concrete subscriber receives emitted transactions through its analysis
//    export.
// 2. The omitted subscriber type parameter is int and the concrete leaf is
//    usable through the corresponding subscriber base.
// 3. The subscriber exposes an analysis implementation specialized with its
//    selected transaction type and subscriber base.
// 4. The subscriber constructor forwards its component name and null parent to
//    normal root parenting.
// 5. A concrete subscriber may inherit an implemented write, reachable by
//    outside analysis-export calls.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 13.9 (UVM-SUBSCRIBER-DELIVERY) gives rule 1 above. Setup: Use
//    two leaves that inherit write from an original subscriber with omitted
//    type parameter; connect independent int analysis ports and send 13/27 to
//    one and 41 to the peer. Expected: Selected delivery has two values in
//    order and peer delivery has one. Exact base/export assignments compile;
//    constructor names and root parenting are preserved.
// 2. 1800.2-2020 13.9.1 (UVM-SUBSCRIBER-DEFAULT-TYPE-BASE) gives rule 2 above.
//    Setup: Use two leaves that inherit write from an original subscriber with
//    omitted type parameter; connect independent int analysis ports and send
//    13/27 to one and 41 to the peer. Expected: Selected delivery has two
//    values in order and peer delivery has one. Exact base/export assignments
//    compile; constructor names and root parenting are preserved.
// 3. 1800.2-2020 13.9.2 (UVM-SUBSCRIBER-EXACT-EXPORT-TYPE) gives rule 3 above.
//    Setup: Use two leaves that inherit write from an original subscriber with
//    omitted type parameter; connect independent int analysis ports and send
//    13/27 to one and 41 to the peer. Expected: Selected delivery has two
//    values in order and peer delivery has one. Exact base/export assignments
//    compile; constructor names and root parenting are preserved.
// 4. 1800.2-2020 13.9.3.1 (UVM-SUBSCRIBER-CONSTRUCTOR) gives rule 4 above.
//    Setup: Use two leaves that inherit write from an original subscriber with
//    omitted type parameter; connect independent int analysis ports and send
//    13/27 to one and 41 to the peer. Expected: Selected delivery has two
//    values in order and peer delivery has one. Exact base/export assignments
//    compile; constructor names and root parenting are preserved.
// 5. 1800.2-2020 13.9.3.2 (UVM-SUBSCRIBER-INHERITED-WRITE) gives rule 5 above.
//    Setup: Use two leaves that inherit write from an original subscriber with
//    omitted type parameter; connect independent int analysis ports and send
//    13/27 to one and 41 to the peer. Expected: Selected delivery has two
//    values in order and peer delivery has one. Exact base/export assignments
//    compile; constructor names and root parenting are preserved.
// It also supports, as a control, the setup or conditions of
// UVM-NEGATIVE-SUBSCRIBER-CONCRETE-SUBCLASS-MUST-IMPLEMENT-WRITE.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_subscriber_descendant_inherits_write_through_default_typed_analysis_export;
  import uvm_pkg::*;
  // No write override in the leaf; calls enter through the public export.
  class implemented_subscriber extends uvm_subscriber#();
    int values[$];
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    virtual function void write(int t); values.push_back(t); endfunction
  endclass
  class inherited_subscriber extends implemented_subscriber;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass
  initial begin
    automatic inherited_subscriber selected = new("selected", null);
    automatic inherited_subscriber peer = new("peer", null);
    automatic uvm_analysis_port#(int) source = new("source", null);
    automatic uvm_analysis_port#(int) peer_source = new("peer_source", null);
    automatic uvm_subscriber#(int) base_view = selected;
    automatic uvm_analysis_imp#(int, uvm_subscriber#(int)) export_view = selected.analysis_export;
    source.connect(selected.analysis_export); peer_source.connect(peer.analysis_export);
    source.resolve_bindings(); peer_source.resolve_bindings();
    source.write(13); source.write(27); peer_source.write(41);
    $display("UT: inherited_subscriber count %0d values %0d/%0d peer %0d/%0d",
             selected.values.size(), selected.values[0], selected.values[1],
             peer.values.size(), peer.values[0]);
    $display("UT: subscriber_declaration base %0d export %0d names %0d/%0d parent %0d",
             base_view == selected, export_view == selected.analysis_export,
             selected.get_name() == "selected", peer.get_name() == "peer",
             selected.get_parent() == uvm_root::get());
    $finish;
  end
endmodule
