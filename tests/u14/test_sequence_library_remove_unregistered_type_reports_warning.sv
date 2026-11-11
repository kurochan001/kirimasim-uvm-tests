/*
:name: test_sequence_library_remove_unregistered_type_reports_warning
:description: removing an unregistered sequence type generates the required warning (IEEE 1800.2-2020 Section 14.4.5.5)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.4.5.5 14.4.5.3 14.4.5.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_library_remove_unregistered_type_reports_warning.expected
*/
// What it checks:
// Removing an unregistered sequence wrapper reports a warning.
//
// How the expected output follows from the standard:
// 1800.2-2020 14.4.5.5 (UVM-LIBRARY-ABSENT-REMOVAL-WARNING) gives the rule
// above. Setup: Retain alpha and attempt to remove absent beta. Expected: One
// warning is added and alpha membership remains one.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Remove an absent wrapper and count the required warning. The pinned
// library silently returns instead; retain the normative warning as spec-only.

module test_sequence_library_remove_unregistered_type_reports_warning;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    function new(string name="packet"); super.new(name); endfunction
  endclass
  class alpha_sequence extends uvm_sequence#(packet);
    `uvm_object_utils(alpha_sequence)
    static int started = 0;
    static int finished = 0;
    function new(string name="alpha_sequence"); super.new(name); endfunction
    task body();
      started++;
      #3;
      finished++;
    endtask
  endclass
  class beta_sequence extends uvm_sequence#(packet);
    `uvm_object_utils(beta_sequence)
    function new(string name="beta_sequence"); super.new(name); endfunction
    task body(); endtask
  endclass
  class prefix_sequence extends uvm_sequence#(packet);
    `uvm_object_utils(prefix_sequence)
    function new(string name="prefix_sequence"); super.new(name); endfunction
    task body(); endtask
  endclass
  typedef uvm_sequence_library#(packet) library_type;
  function automatic int occurrences(uvm_object_wrapper entries[$], uvm_object_wrapper kind);
    int count = 0;
    foreach (entries[i]) if (entries[i] == kind) count++;
    return count;
  endfunction

  initial begin
    automatic library_type value = new("value");
    automatic uvm_report_server server = uvm_report_server::get_server();
    uvm_object_wrapper entries[$];
    int before_warnings;
    value.add_sequence(alpha_sequence::get_type());
    before_warnings = server.get_severity_count(UVM_WARNING);
    value.remove_sequence(beta_sequence::get_type());
    value.get_sequences(entries);
    $display("UT: warnings %0d count %0d alpha %0d",
             server.get_severity_count(UVM_WARNING) - before_warnings, entries.size(),
             occurrences(entries, alpha_sequence::get_type()));
    $finish;
  end
endmodule
