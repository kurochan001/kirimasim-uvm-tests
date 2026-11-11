/*
:name: test_sequence_library_inherits_the_selected_request_and_response_sequence_type
:description: sequence library inherits the selected request and response sequence type (IEEE 1800.2-2020 Section 14.4.1)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.4.1 14.4 14.4.3 14.3.1 14.3.2.1 14.3.2.2 B.3.2.2 B.2.1.2 1800-2023 6.21 18.5 18.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_library_inherits_the_selected_request_and_response_sequence_type.expected
*/
// What it checks:
// The sequence library derives from the sequence specialization selected by
// REQ and RSP.
//
// How the expected output follows from the standard:
// 1800.2-2020 14.4.1 (UVM-SEQ-REVIEW-LIBRARY-PARAMETERIZED-BASE) gives the
// rule above. Setup: An original library subtype uses distinct request and
// response types. Expected: The exact sequence specialization and
// sequence-base views preserve identity and typed fields.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original subtype declaration and public type/field observations only.
// Macro inclusion is fixture setup, not proof of every static registration
// contract. This does not substitute a legacy member for a missing API.
module test_sequence_library_inherits_the_selected_request_and_response_sequence_type;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class request_packet extends uvm_sequence_item;
    function new(); super.new("request"); endfunction
  endclass
  class response_packet extends uvm_sequence_item;
    function new(); super.new("response"); endfunction
  endclass
  class typed_library extends uvm_sequence_library#(request_packet,response_packet);
    `uvm_object_utils(typed_library)
    `uvm_sequence_library_utils(typed_library)
    function new(string name="library"); super.new(name); endfunction
  endclass
  initial begin
    automatic typed_library value = new();
    automatic request_packet request = new();
    automatic response_packet response = new();
    automatic uvm_sequence#(request_packet,response_packet) sequence_view = value;
    automatic uvm_sequence_base base_view = sequence_view;
    value.req = request; value.rsp = response;
    $display("UT: library_type sequence %0d base %0d req %0d rsp %0d",
             sequence_view == value, base_view == value,
             sequence_view.req == request, sequence_view.rsp == response);
    $finish;
  end
endmodule
