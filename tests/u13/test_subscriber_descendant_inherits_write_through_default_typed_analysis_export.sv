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
