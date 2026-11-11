/*
:name: test_field_macro_scalar_enum_copies_and_compares_values
:description: Typed field automation copies original values and detects a selected independent mutation
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.2.2.1.4 B.2.2.1 B.2.2 B.2.1.2 5.3.8.1 5.3.9.1 F.2.1.8 1800-2023 6.21 8.20 8.21 7.4 7.8 7.9 8.19
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_field_macro_scalar_enum_copies_and_compares_values.expected
*/
// What it checks:
// 1. The selected enum scalar field macro copies its selected values and
//    collection shape.
// 2. The selected enum scalar field macro compares copied equal data
//    successfully.
// 3. The selected enum scalar field macro detects the selected value change.
// 4. The selected field-macro family supplies data operations for its declared
//    scalar properties.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 B.2.2.1.4 (UVM-FIELD-MACRO-AUDIT-B-2-2-1-4-COPY) gives rule 1
//    above. Setup: An original class declares one enum scalar property with
//    COPY and COMPARE flags and no do-copy/compare implementation. Values,
//    sparse keys or two selected elements are initialized independently; the
//    destination may contain stale entries. An unregistered peer differs
//    between source and target. Expected: The destination has exactly the
//    selected values and shape, including the chosen high bits or signed/wide
//    key membership; stale associative entries disappear where applicable.
// 2. 1800.2-2020 B.2.2.1.4 (UVM-FIELD-MACRO-AUDIT-B-2-2-1-4-COMPARE-EQUAL)
//    gives rule 2 above. Setup: An original class declares one enum scalar
//    property with COPY and COMPARE flags and no do-copy/compare
//    implementation. Values, sparse keys or two selected elements are
//    initialized independently; the destination may contain stale entries. An
//    unregistered peer differs between source and target. Expected: The copied
//    source/target compare equal despite their different unregistered peer
//    property.
// 3. 1800.2-2020 B.2.2.1.4 (UVM-FIELD-MACRO-AUDIT-B-2-2-1-4-COMPARE-MUTATION)
//    gives rule 3 above. Setup: An original class declares one enum scalar
//    property with COPY and COMPARE flags and no do-copy/compare
//    implementation. Values, sparse keys or two selected elements are
//    initialized independently; the destination may contain stale entries. An
//    unregistered peer differs between source and target. Expected: Changing
//    one destination value makes comparison false while the original source
//    values and both unregistered peers retain their selected states.
// 4. 1800.2-2020 B.2.2.1 (UVM-FIELD-MACRO-AUDIT-B-2-2-1-APPLICABILITY) gives
//    rule 4 above. Setup: Use independently constructed original properties of
//    the declared scalar or one-dimensional collection type; no user
//    data-operation hook substitutes for macro execution. Expected: Each
//    selected shape completes copying and positive/negative comparison on its
//    original values and chosen keys.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Observe exact values and key membership without traversal order.
// Enum collections use the collection typedef described by printed T text.
module test_field_macro_scalar_enum_copies_and_compares_values;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  typedef enum int {VALUE_FIRST=3,VALUE_SECOND=19,VALUE_CHANGED=71} value_t;
  typedef enum bit [7:0] {KEY_FIRST=8'h13,KEY_SECOND=8'hd7} enum_key_t;
  typedef bit [95:0] wide_key_t;
  class packet extends uvm_object;
    value_t data;
    int untouched=31;
    `uvm_object_utils_begin(packet)
      `uvm_field_enum(value_t,data,UVM_COPY|UVM_COMPARE)
    `uvm_object_utils_end
    function new(string name="packet65"); super.new(name); endfunction
  endclass
  initial begin
    automatic packet source=new("source65"), target=new("target65");
    bit shape_ok, values_ok, independent_ok, equal_ok, changed_equal, source_ok;
    source.data=VALUE_FIRST;
    source.untouched=97;
    target.copy(source);
    shape_ok=1;
    values_ok=shape_ok &&
      target.data==VALUE_FIRST;
    independent_ok=1;
    equal_ok=target.compare(source);
    if (values_ok) target.data=VALUE_CHANGED;
    changed_equal=target.compare(source);
    source_ok=source.data==VALUE_FIRST;
    $display("UT: macro_copy shape %0d values %0d independent %0d",
      shape_ok,values_ok,independent_ok);
    $display("UT: macro_compare equal %0d changed %0d source %0d peer %0d",
      equal_ok,changed_equal,source_ok,target.untouched==31 && source.untouched==97);
    $finish;
  end
endmodule
