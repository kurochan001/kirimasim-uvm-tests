/*
:name: test_sequence_library_add_sequence_ignores_duplicate_wrappers
:description: instance registration silently ignores duplicate sequence types (IEEE 1800.2-2020 Section 14.4.5.3)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.4.5.3 14.4.5.6 14.4.4.10 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_library_add_sequence_ignores_duplicate_wrappers.expected
*/
// Register two sequence types, including one duplicate. Compare membership
// and public indexed access without requiring an insertion order.

module test_sequence_library_add_sequence_ignores_duplicate_wrappers;
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
    uvm_object_wrapper first_type;
    uvm_object_wrapper second_type;
    value.add_sequence(alpha_sequence::get_type());
    value.add_sequence(alpha_sequence::get_type());
    value.add_sequence(beta_sequence::get_type());
    value.get_sequences(entries);
    first_type = value.get_sequence(0);
    second_type = value.get_sequence(1);
    $display("UT: count %0d alpha %0d beta %0d indexed_distinct %0d", entries.size(),
             occurrences(entries, alpha_sequence::get_type()),
             occurrences(entries, beta_sequence::get_type()), first_type != second_type);
    $display("UT: indexed_members %0d %0d warnings %0d errors %0d",
             occurrences(entries, first_type), occurrences(entries, second_type),
             server.get_severity_count(UVM_WARNING), server.get_severity_count(UVM_ERROR));
    $finish;
  end
endmodule
