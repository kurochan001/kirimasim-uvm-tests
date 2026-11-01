/*
:name: test_sequence_library_index_membership_is_local_to_each_library_instance
:description: sequence-library index membership is local to each instance (IEEE 1800.2-2020 Section 14.4.4.10)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.4.4.10 14.4.5.3 14.4.5.6 B.3.2.2 6.6.3.2 6.6.5 10.7.2.5 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_library_index_membership_is_local_to_each_library_instance.expected
*/
// Query registered type wrappers without executing member sequences.
// Enumeration defines valid indices; no registration ordering is prescribed.
// Invalid probes exceed the count, avoiding the printed equal-count boundary.
module test_sequence_library_index_membership_is_local_to_each_library_instance;
  import uvm_pkg::*;

  `include "uvm_macros.svh"
  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    function new(string name="packet"); super.new(name); endfunction
  endclass
  class alpha_sequence extends uvm_sequence#(packet);
    `uvm_object_utils(alpha_sequence)
    function new(string name="alpha"); super.new(name); endfunction
    task body(); endtask
  endclass
  class beta_sequence extends uvm_sequence#(packet);
    `uvm_object_utils(beta_sequence)
    function new(string name="beta"); super.new(name); endfunction
    task body(); endtask
  endclass
  typedef uvm_sequence_library#(packet) library_type;
  class error_probe extends uvm_report_catcher;
    int errors = 0;
    function new(); super.new("probe"); endfunction
    function action_e catch();
      if (get_severity() == UVM_ERROR) begin errors++; return CAUGHT; end
      return THROW;
    endfunction
  endclass

  initial begin
    automatic library_type first = new("first");
    automatic library_type peer = new("peer");
    uvm_object_wrapper entries[$];

    automatic bit exact = 1;
    uvm_object_wrapper peer_entries[$];


    first.add_sequence(alpha_sequence::get_type()); peer.add_sequence(beta_sequence::get_type());
    $display("UT: initial first_alpha %0d peer_beta %0d",
    first.get_sequence(0) == alpha_sequence::get_type(),
    peer.get_sequence(0) == beta_sequence::get_type());
    first.add_sequence(beta_sequence::get_type()); first.get_sequences(entries);
    peer.get_sequences(peer_entries);
    foreach (entries[i]) exact &= first.get_sequence(i) == entries[i];
    $display("UT: sizes first %0d peer %0d first_exact %0d peer_unchanged %0d", entries.size(),
    peer_entries.size(), exact, peer.get_sequence(0) == beta_sequence::get_type());

    $finish;
  end

endmodule
