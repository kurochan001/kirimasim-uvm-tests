/*
:name: test_map_clone_printed_implicit_return_type_supports_a_scalar_override_and_base_dispatch
:description: printed clone implicit return supports scalar override and base dispatch
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.2.3.12 18.2.3.1 1800-2023 6.21 8.20 13.4
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_map_clone_printed_implicit_return_type_supports_a_scalar_override_and_base_dispatch.expected
*/
// What it checks:
// The literal printed virtual function with an empty implicit return type
// supports a scalar-logic override and base-view dispatch to the selected
// implementation.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.2.3.12 (UVM-REGISTER-CONTRACT-CLONE-PRINTED-SCALAR-RETURN)
// gives the rule above. Setup: Read the prototype together with SystemVerilog
// 13.4 implicit function return rules and virtual method override
// compatibility. The original subtype returns one and records the supplied
// rights; no clone algorithm or map-handle return is substituted. Expected:
// The literal printed virtual function with an empty implicit return type
// supports a scalar-logic override and base-view dispatch to the selected
// implementation.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Qualified literal declaration: no explicit return type means scalar logic.
// This observes the declaration/dispatch boundary, not a new map's contents.
module test_map_clone_printed_implicit_return_type_supports_a_scalar_override_and_base_dispatch;
  import uvm_pkg::*;
  class literal_map extends uvm_reg_map;
    int calls=0;
    string seen;
    function new();super.new("literal52");endfunction
    virtual function clone_and_update(string rights);
      calls++;seen=rights;return 1'b1;
    endfunction
  endclass
  initial begin
    automatic literal_map selected=new();
    uvm_reg_map base_view;
    logic returned;
    base_view=selected;returned=base_view.clone_and_update("RO");
    $display("UT: map_clone_declaration scalar %0b calls %0d argument %0d",
      returned,selected.calls,selected.seen=="RO");
    $finish;
  end
endmodule
