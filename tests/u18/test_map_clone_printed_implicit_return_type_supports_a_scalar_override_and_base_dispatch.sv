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
