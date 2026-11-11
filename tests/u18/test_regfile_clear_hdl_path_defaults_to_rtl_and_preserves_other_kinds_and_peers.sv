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
// What it checks:
// 1. Path presence is reported for the selected abstraction; an omitted kind
//    uses the nearest enclosing register-file or block default.
// 2. Omitting kind in clear_hdl_path removes RTL paths even when the file
//    default selects another abstraction.
// 3. Explicit HDL path clearing removes only the chosen file/abstraction
//    entries.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.3.4.3 (UVM-REGFILE-HDL-PRESENCE-QUERY) gives rule 1 above.
//    Setup: Known RTL/GATE paths and a missing kind are queried; another file
//    selects GATE before clearing paths. Expected: Known paths report true and
//    a missing kind false. After RTL is cleared, omitted-kind presence is
//    false even though the current file selects GATE and the explicit GATE
//    path exists.
// 2. 1800.2-2020 18.3.4.1 (UVM-REGFILE-CLEAR-HDL-DEFAULT-RTL) gives rule 2
//    above. Setup: The file has RTL/GATE paths, selects GATE as default, then
//    calls clear_hdl_path without kind. Expected: RTL becomes absent while
//    explicit GATE presence stays true. The enclosing RTL default gives false
//    for an omitted-kind presence query; the current-file default remains GATE
//    and peer paths are retained.
// 3. 1800.2-2020 18.3.4.1 (UVM-REGFILE-CLEAR-HDL-SELECTED-KIND-ISOLATION)
//    gives rule 3 above. Setup: After the RTL control, GATE is explicitly
//    cleared on one of two independent files. Expected: The selected default
//    GATE path becomes absent while the peer GATE path remains present.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
