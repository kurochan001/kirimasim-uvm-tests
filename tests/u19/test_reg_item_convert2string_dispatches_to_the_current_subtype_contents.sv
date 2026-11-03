/*
:name: test_reg_item_convert2string_dispatches_to_the_current_subtype_contents
:description: reg item convert2string dispatches to the current subtype contents (IEEE 1800.2-2020 Section 19.1.1.3.2)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.1.1.3.2 19.1.1.3.1 19.1.1.2.4 5.3.4.1 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_item_convert2string_dispatches_to_the_current_subtype_contents.expected
*/
// The string layout is the original subtype formatter, not a default-library
// text expectation. This checks virtual dispatch with live public values;
// default formatting/completeness remains separate review work.
module test_reg_item_convert2string_dispatches_to_the_current_subtype_contents;
  import uvm_pkg::*;
  class formatted_item extends uvm_reg_item;
    function new(); super.new("item"); endfunction
    virtual function string convert2string();
      return $sformatf("%s/%0h", get_name(), get_value(0));
    endfunction
  endclass
  initial begin
    automatic formatted_item item = new();
    automatic uvm_reg_item base_view = item;
    string first;
    item.set_value('h3a7); first = base_view.convert2string();
    item.set_name("changed"); item.set_value('h52);
    $display("UT: virtual_string first %0d current %0d retained %0d", first == "item/3a7",
             base_view.convert2string() == "changed/52", first == "item/3a7");
    $finish;
  end
endmodule
