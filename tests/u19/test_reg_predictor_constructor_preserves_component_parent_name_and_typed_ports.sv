/*
:name: test_reg_predictor_constructor_preserves_component_parent_name_and_typed_ports
:description: reg predictor constructor preserves component parent name and typed ports (IEEE 1800.2-2020 Section 19.3.3.1)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.3.3.1 19.3.1 19.3.2.1 19.3.2.2 13.1.2.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_predictor_constructor_preserves_component_parent_name_and_typed_ports.expected
*/
// Observe the selected item-derived BUSTYPE specialization and exact public
// port types. Default integer-type usability, arbitrary BUSTYPE conversions
// and pending-transaction diagnostic severity remain separate review work.
module test_reg_predictor_constructor_preserves_component_parent_name_and_typed_ports;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    function new(string name = "packet"); super.new(name); endfunction
  endclass
  class owner extends uvm_component;
    function new(string name); super.new(name,null); endfunction
  endclass
  initial begin
    automatic owner parent_value = new("scope");
    automatic uvm_reg_predictor#(packet) predictor = new("selected",parent_value);
    automatic uvm_component base_view = predictor;
    uvm_analysis_imp#(packet,uvm_reg_predictor#(packet)) input_view;
    uvm_analysis_port#(uvm_reg_item) output_view;
    input_view = predictor.bus_in; output_view = predictor.reg_ap;
    $display("UT: predictor_constructor parent %0d name %0d full_name %0d base %0d",
             predictor.get_parent() == parent_value, predictor.get_name() == "selected",
             predictor.get_full_name() == "scope.selected", base_view == predictor);
    $display("UT: predictor_ports input %0d output %0d", input_view != null, output_view != null);
    $finish;
  end
endmodule
