/*
:name: test_regfile_clear_hdl_path_defaults_to_rtl_and_preserves_other_kinds_and_peers
:description: clear_hdl_path removes only its selected abstraction with an RTL default (18.3.4.1)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.3.4.1 18.3.4.2 18.3.4.3 18.3.4.6 18.3.4.7 18.3.2.2 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_regfile_clear_hdl_path_defaults_to_rtl_and_preserves_other_kinds_and_peers.expected
*/
// Symbolic path strings only: no HDL lookup, DPI, bus or DUT access.
// Queues are fresh and compared by membership without an enumeration order.
module test_regfile_clear_hdl_path_defaults_to_rtl_and_preserves_other_kinds_and_peers;
  import uvm_pkg::*;
  class block_type extends uvm_reg_block;
    function new(string name); super.new(name, UVM_NO_COVERAGE); endfunction
  endclass

  // Presence with no kind uses the enclosing file/block default (18.3.4.3),
  // while get_default_hdl_path queries the current file default (18.3.4.6).
  initial begin
    automatic block_type root_block = new("root");
    automatic uvm_reg_file first = new("first");
    automatic uvm_reg_file peer = new("peer");
    root_block.configure();
    first.configure(root_block, null, "first_rtl"); peer.configure(root_block, null, "peer_rtl");
    first.add_hdl_path("first_gate", "GATE"); peer.add_hdl_path("peer_gate", "GATE");
    first.set_default_hdl_path("GATE"); first.clear_hdl_path();
    $display("UT: default_clear rtl %0d gate %0d default %0d own %s peer_rtl %0d peer_gate %0d",
             first.has_hdl_path("RTL"), first.has_hdl_path("GATE"), first.has_hdl_path(),
             first.get_default_hdl_path(),
             peer.has_hdl_path("RTL"), peer.has_hdl_path("GATE"));
    first.clear_hdl_path("GATE");
    $display("UT: explicit_clear default %0d peer_gate %0d", first.has_hdl_path(),
             peer.has_hdl_path("GATE"));
    $finish;
  end
endmodule
