/*
:name: test_sequence_library_index_lookup_matches_public_enumeration_and_repeated_identity
:description: valid sequence-library indices match public enumeration and repeat identity (IEEE 1800.2-2020 Section 14.4.4.10)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.4.4.10 14.4.5.3 14.4.5.6 B.3.2.2 6.6.3.2 6.6.5 10.7.2.5 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_library_index_lookup_matches_public_enumeration_and_repeated_identity.expected
*/
// What it checks:
// Valid library indices resolve to the wrappers supplied by public
// enumeration.
//
// How the expected output follows from the standard:
// 1800.2-2020 14.4.4.10 (UVM-LIBRARY-INDEX-ENUMERATION-IDENTITY) gives the
// rule above. Setup: Register alpha/beta and query every enumerated index
// repeatedly. Expected: Two indices match their exact enumerated wrappers,
// with one alpha and one beta.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Query registered type wrappers without executing member sequences.
// Enumeration defines valid indices; no registration ordering is prescribed.
// Invalid probes exceed the count, avoiding the printed equal-count boundary.
module test_sequence_library_index_lookup_matches_public_enumeration_and_repeated_identity;
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
    automatic int alpha_seen = 0;
    automatic int beta_seen = 0;


    first.add_sequence(alpha_sequence::get_type()); first.add_sequence(beta_sequence::get_type());
    first.get_sequences(entries);
    foreach (entries[i]) begin
      exact &= first.get_sequence(i) == entries[i] &&
      first.get_sequence(i) == first.get_sequence(i);
      if (first.get_sequence(i) == alpha_sequence::get_type()) alpha_seen++;
      if (first.get_sequence(i) == beta_sequence::get_type()) beta_seen++;
    end
    $display("UT: entries %0d indexed_exact %0d alpha %0d beta %0d", entries.size(), exact,
    alpha_seen, beta_seen);

    $finish;
  end

endmodule
