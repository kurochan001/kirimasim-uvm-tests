/*
:name: test_sequence_library_index_invalid_probes_preserve_valid_types
:description: out-of-range library indices report errors and leave valid membership intact (IEEE 1800.2-2020 Section 14.4.4.10)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.4.4.10 14.4.5.3 14.4.5.6 B.3.2.2 6.6.3.2 6.6.5 10.7.2.5 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_library_index_invalid_probes_preserve_valid_types.expected
*/
// What it checks:
// An index beyond the registered count reports an error and returns null.
//
// How the expected output follows from the standard:
// 1800.2-2020 14.4.4.10 (UVM-LIBRARY-INDEX-OUT-OF-RANGE-ERROR) gives the rule
// above. Setup: Probe count plus one and maximum unsigned, then query valid
// index zero. Expected: Each invalid call yields one ERROR and null; the
// original valid alpha remains available.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Query registered type wrappers without executing member sequences.
// Enumeration defines valid indices; no registration ordering is prescribed.
// Invalid probes exceed the count, avoiding the printed equal-count boundary.
module test_sequence_library_index_invalid_probes_preserve_valid_types;
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

    automatic error_probe probe = new();
    uvm_object_wrapper rejected;


    first.add_sequence(alpha_sequence::get_type()); first.get_sequences(entries);
    uvm_report_cb::add(null, probe);
    rejected = first.get_sequence(entries.size() + 1);
    $display("UT: beyond_count null %0d errors %0d", rejected == null, probe.errors);
    rejected = first.get_sequence('1);
    $display("UT: max_unsigned null %0d errors %0d", rejected == null, probe.errors);
    uvm_report_cb::delete(null, probe);
    entries.delete(); first.get_sequences(entries);
    $display("UT: retained size %0d valid %0d", entries.size(),
    first.get_sequence(0) == alpha_sequence::get_type());

    $finish;
  end

endmodule
