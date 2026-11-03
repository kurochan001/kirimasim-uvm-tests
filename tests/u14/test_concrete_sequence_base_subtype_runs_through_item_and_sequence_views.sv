/*
:name: test_concrete_sequence_base_subtype_runs_through_item_and_sequence_views
:description: concrete sequence base subtype runs through item and sequence views (IEEE 1800.2-2020 Section 14.2.1)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.1 14.2 14.2.2.1 14.2.2.4 14.2.3.1 14.2.3.6 14.1.2.11 1800-2023 6.21 18.5 18.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_concrete_sequence_base_subtype_runs_through_item_and_sequence_views.expected
*/
// A concrete test subtype implements the virtual base body. This observes
// positive inheritance and direct unbound execution, not arbitrary subclass
// validity, request traffic or a fixed formatted state name.
module test_concrete_sequence_base_subtype_runs_through_item_and_sequence_views;
  import uvm_pkg::*;
  class leaf_sequence extends uvm_sequence_base;
    int bodies = 0;
    function new(string name="leaf"); super.new(name); endfunction
    task body(); bodies++; endtask
  endclass
  initial begin
    automatic leaf_sequence value = new();
    automatic uvm_sequence_base sequence_view = value;
    automatic uvm_sequence_item item_view = sequence_view;
    automatic uvm_transaction transaction_view = item_view;
    $display("UT: sequence inheritance item %0d transaction %0d category %0d",
             item_view == value, transaction_view == value, !item_view.is_item());
    sequence_view.start(null);
    $display("UT: base_dispatch bodies %0d finished %0d", value.bodies,
             sequence_view.get_sequence_state() == UVM_FINISHED);
    $finish;
  end
endmodule
