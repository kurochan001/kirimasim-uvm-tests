/*
:name: test_report_file_hierarchy_propagates_each_scope_and_preserves_outside_peers
:description: hierarchical file settings recurse within the selected component subtree (IEEE 1800.2-2020 Section D.2.2.3)
:tags: uD uvm
:type: simulation
:lrm: 1800.2-2020 D.2.2.3 6.3.6.1 6.3.6.2 6.4.5.1 6.4.5.2 13.1.2.1 B.2.1.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_file_hierarchy_propagates_each_scope_and_preserves_outside_peers.expected
*/
// What it checks:
// 1. The hierarchical default-file setter associates the descriptor throughout
//    the selected subtree.
// 2. The hierarchical severity-file setter associates the descriptor
//    throughout the selected subtree.
// 3. The hierarchical ID-file setter associates the descriptor throughout the
//    selected subtree.
// 4. The hierarchical severity-ID-file setter associates the pair descriptor
//    throughout the subtree.
// 5. A severity-ID file association takes precedence over less specific
//    associations.
// 6. Updating a child subtree leaves its ancestor association unchanged.
// 7. Updating an ID file association preserves the effective more specific
//    pair association.
// 8. Hierarchical file settings leave components outside the selected subtree
//    unchanged.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 D.2.2.3 (UVM-REPORT-FILE-HIER-DEFAULT) gives rule 1 above.
//    Setup: A component, child and grandchild receive the default setting from
//    their subtree root. Expected: All three resolve an otherwise unconfigured
//    key to the supplied default descriptor.
// 2. 1800.2-2020 D.2.2.3 (UVM-REPORT-FILE-HIER-SEVERITY) gives rule 2 above.
//    Setup: A WARNING-specific descriptor is set at the root of the
//    three-level subtree. Expected: All three resolve the otherwise
//    unconfigured WARNING key to that descriptor.
// 3. 1800.2-2020 D.2.2.3 (UVM-REPORT-FILE-HIER-ID) gives rule 3 above. Setup:
//    The picked ID descriptor is configured before a more specific pair
//    setting. Expected: All three resolve INFO/WARNING picked to the ID
//    descriptor at that stage.
// 4. 1800.2-2020 D.2.2.3 (UVM-REPORT-FILE-HIER-PAIR) gives rule 4 above.
//    Setup: A WARNING/picked pair descriptor is applied after default,
//    severity and ID settings. Expected: The component, child and grandchild
//    return that pair descriptor.
// 5. 1800.2-2020 D.2.2.3 (UVM-REPORT-FILE-HIER-PAIR-PRECEDENCE) gives rule 5
//    above. Setup: Four distinct live descriptors apply to the same subtree at
//    different specificities. Expected: The pair query resolves to the pair
//    descriptor.
// 6. 1800.2-2020 D.2.2.3 (UVM-REPORT-FILE-HIER-NARROWER-SUBTREE) gives rule 6
//    above. Setup: After root-wide configuration, the child changes its
//    subtree ID descriptor. Expected: Child and leaf use the new ID descriptor
//    while the original branch retains its previous one.
// 7. 1800.2-2020 D.2.2.3 (UVM-REPORT-FILE-HIER-LOWER-PRIORITY-UPDATE) gives
//    rule 7 above. Setup: The narrowed subtree ID changes after its
//    WARNING/picked pair was installed. Expected: All three effective pair
//    descriptors remain the original pair value.
// 8. 1800.2-2020 D.2.2.3 (UVM-REPORT-FILE-HIER-OUTSIDE-PEER) gives rule 8
//    above. Setup: An outside peer is queried before all four setters and the
//    narrower update. Expected: Its default, severity, ID and pair queries
//    retain their before values.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Compare effective descriptors while four distinct files remain open.
// Only public getter identity is observed; numeric descriptor values, report
// formatting and written file contents are not part of this oracle.
module test_report_file_hierarchy_propagates_each_scope_and_preserves_outside_peers;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class node_type extends uvm_component;
    `uvm_component_utils(node_type)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass
  initial begin
    automatic node_type branch = new("branch", null);
    automatic node_type child = new("child", branch);
    automatic node_type leaf = new("leaf", child);
    automatic node_type peer = new("peer", null);
    uvm_component nodes[3];
    UVM_FILE before_peer[4];
    int default_fd, severity_fd, id_fd, pair_fd;
    bit defaults, severities, ids, pairs;
    nodes[0] = branch; nodes[1] = child; nodes[2] = leaf;
    before_peer[0] = peer.get_report_file_handle(UVM_INFO, "plain");
    before_peer[1] = peer.get_report_file_handle(UVM_WARNING, "plain");
    before_peer[2] = peer.get_report_file_handle(UVM_INFO, "picked");
    before_peer[3] = peer.get_report_file_handle(UVM_WARNING, "picked");
    default_fd = $fopen("hier-default.txt", "w");
    severity_fd = $fopen("hier-severity.txt", "w");
    id_fd = $fopen("hier-id.txt", "w"); pair_fd = $fopen("hier-pair.txt", "w");
    if (!default_fd || !severity_fd || !id_fd || !pair_fd) $fatal(1, "fixture file open failed");
    branch.set_report_default_file_hier(default_fd);
    branch.set_report_severity_file_hier(UVM_WARNING, severity_fd);
    branch.set_report_id_file_hier("picked", id_fd);
    ids = 1;
    foreach (nodes[i]) begin
      ids &= nodes[i].get_report_file_handle(UVM_INFO, "picked") == id_fd &&
             nodes[i].get_report_file_handle(UVM_WARNING, "picked") == id_fd;
    end
    branch.set_report_severity_id_file_hier(UVM_WARNING, "picked", pair_fd);
    defaults = 1; severities = 1; pairs = 1;
    foreach (nodes[i]) begin
      defaults &= nodes[i].get_report_file_handle(UVM_INFO, "plain") == default_fd;
      severities &= nodes[i].get_report_file_handle(UVM_WARNING, "plain") == severity_fd;
      pairs &= nodes[i].get_report_file_handle(UVM_WARNING, "picked") == pair_fd;
    end
    $display("UT: hierarchy default %0d severity %0d id %0d pair %0d", defaults,
             severities, ids, pairs);
    child.set_report_id_file_hier("picked", default_fd);
    $display("UT: narrowed branch %0d child %0d leaf %0d pair_preserved %0d",
             branch.get_report_file_handle(UVM_INFO, "picked") == id_fd,
             child.get_report_file_handle(UVM_INFO, "picked") == default_fd,
             leaf.get_report_file_handle(UVM_INFO, "picked") == default_fd,
             branch.get_report_file_handle(UVM_WARNING, "picked") == pair_fd &&
             child.get_report_file_handle(UVM_WARNING, "picked") == pair_fd &&
             leaf.get_report_file_handle(UVM_WARNING, "picked") == pair_fd);
    $display("UT: peer_unchanged %0d",
             peer.get_report_file_handle(UVM_INFO, "plain") == before_peer[0] &&
             peer.get_report_file_handle(UVM_WARNING, "plain") == before_peer[1] &&
             peer.get_report_file_handle(UVM_INFO, "picked") == before_peer[2] &&
             peer.get_report_file_handle(UVM_WARNING, "picked") == before_peer[3]);
    $fclose(default_fd); $fclose(severity_fd); $fclose(id_fd); $fclose(pair_fd);
    $finish;
  end
endmodule
