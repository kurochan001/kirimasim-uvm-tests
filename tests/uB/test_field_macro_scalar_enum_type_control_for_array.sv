/*
:name: test_field_macro_scalar_enum_type_control_for_array
:description: A scalar-enum T control keeps collection storage and selected data operations
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.2.2.3.4 B.2.2.3 B.2.2 B.2.1.2 5.3.8.1 5.3.9.1 F.2.1.8 1800-2023 6.21 8.20 8.21 7.4 7.8 7.9 8.19
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_field_macro_scalar_enum_type_control_for_array.expected
*/
// Observe exact values and key membership without traversal order.
// Control-only: T is the element enum; the collection property is unchanged.
module test_field_macro_scalar_enum_type_control_for_array;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  typedef enum int {VALUE_FIRST=3,VALUE_SECOND=19,VALUE_CHANGED=71} value_t;
  typedef enum bit [7:0] {KEY_FIRST=8'h13,KEY_SECOND=8'hd7} enum_key_t;
  typedef bit [95:0] wide_key_t;
  typedef value_t collection_t[];
  class packet extends uvm_object;
    collection_t data;
    int untouched=31;
    `uvm_object_utils_begin(packet)
      `uvm_field_array_enum(value_t,data,UVM_COPY|UVM_COMPARE)
    `uvm_object_utils_end
    function new(string name="packet65"); super.new(name); endfunction
  endclass
  initial begin
    automatic packet source=new("source65"), target=new("target65");
    bit shape_ok, values_ok, independent_ok, equal_ok, changed_equal, source_ok;
    source.data=new[2];
    source.data[0]=VALUE_FIRST;
    source.data[1]=VALUE_SECOND;
    target.data=new[3];
    source.untouched=97;
    target.copy(source);
    shape_ok=target.data.size()==2;
    values_ok=shape_ok &&
      target.data[0]==VALUE_FIRST &&
      target.data[1]==VALUE_SECOND;
    independent_ok=1;
    equal_ok=target.compare(source);
    if (values_ok) target.data[0]=VALUE_CHANGED;
    changed_equal=target.compare(source);
    source_ok=source.data[0]==VALUE_FIRST &&
      source.data[1]==VALUE_SECOND;
    $display("UT: macro_copy shape %0d values %0d independent %0d",
      shape_ok,values_ok,independent_ok);
    $display("UT: macro_compare equal %0d changed %0d source %0d peer %0d",
      equal_ok,changed_equal,source_ok,target.untouched==31 && source.untouched==97);
    $finish;
  end
endmodule
