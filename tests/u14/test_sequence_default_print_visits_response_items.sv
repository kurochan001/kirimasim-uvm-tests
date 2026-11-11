/*
:name: test_sequence_default_print_visits_response_items
:description: default sequence printing reaches the current typed request and response (IEEE 1800.2-2020 Section 14.3.2.2)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.3.2.2 14.3.2.1 5.3.6.2 5.3.6.3 16.2.3.1 16.2.5.9 16.2.5.10 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_default_print_visits_response_items.expected
*/
// What it checks:
// Default sequence printing follows the current rsp field.
//
// How the expected output follows from the standard:
// 1800.2-2020 14.3.2.2 (UVM-SEQUENCE-DEFAULT-PRINT-RSP-INITIAL) gives the rule
// above. Setup: Only rsp holds a non-null typed item. Expected: The current
// rsp item print hook is visited once.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The sequence keeps its default do_print. Deep, unlimited recursion is
// explicit. Item hooks identify reached objects without text assumptions.
module test_sequence_default_print_visits_response_items;
  import uvm_pkg::*;
  class request_item extends uvm_sequence_item;
    int prints = 0;
    function new(string name="request"); super.new(name); endfunction
    virtual function void do_print(uvm_printer printer);
      prints++; printer.print_field_int("request_marker", 17, 8, UVM_DEC);
    endfunction
  endclass
  class response_item extends uvm_sequence_item;
    int prints = 0;
    function new(string name="response"); super.new(name); endfunction
    virtual function void do_print(uvm_printer printer);
      prints++; printer.print_field_int("response_marker", 39, 8, UVM_DEC);
    endfunction
  endclass
  class sequence_under_test extends uvm_sequence#(request_item, response_item);
    function new(); super.new("sequence"); endfunction
    virtual task body(); endtask
  endclass
  initial begin
    automatic sequence_under_test seq = new();
    automatic request_item first_req = new("first_req");
    automatic request_item second_req = new("second_req");
    automatic response_item first_rsp = new("first_rsp");
    automatic response_item second_rsp = new("second_rsp");
    automatic uvm_tree_printer printer = new();
    string rendered;
    printer.set_recursion_policy(UVM_DEEP); printer.set_max_depth(-1);
    seq.req = null; seq.rsp = first_rsp;
    rendered = seq.sprint(printer);
    $display("UT: request %0d response %0d retained %0d", first_req.prints,
             first_rsp.prints, seq.req == null && seq.rsp == first_rsp);
    $finish;
  end
endmodule
