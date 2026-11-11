/*
:name: test_field_macro_negative_copy_compare_flags_override_all_positive_operations
:description: Negative field flags override COPY COMPARE ALL_ON and DEFAULT independently
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.2.2 F.2.1.9 F.2.1.8 F.2.1.10 B.2.2.1.1 5.3.8.1 5.3.9.1 1800-2023 6.21 8.20 8.21 7.4 7.8 7.9 8.19
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_field_macro_negative_copy_compare_flags_override_all_positive_operations.expected
*/
// What it checks:
// 1. NOCOPY overrides selected positive copy flags including ALL_ON.
// 2. NOCOMPARE overrides selected positive compare flags including DEFAULT.
// 3. NOCOPY suppresses the selected field copy operation.
// 4. NOCOMPARE removes the selected field from comparison.
// 5. COPY and COMPARE enable their selected field operations.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 B.2.2 (UVM-FIELD-MACRO-AUDIT-NEGATIVE-COPY-PRECEDENCE) gives
//    rule 1 above. Setup: Use distinct enabled/excluded fields or
//    omitted/explicit flags in an original registered class without user
//    operation hooks; independently initialize source and target. Expected:
//    The ordinary field copies seventeen while the excluded destination field
//    retains seventy-one.
// 2. 1800.2-2020 B.2.2 (UVM-FIELD-MACRO-AUDIT-NEGATIVE-COMPARE-PRECEDENCE)
//    gives rule 2 above. Setup: Use distinct enabled/excluded fields or
//    omitted/explicit flags in an original registered class without user
//    operation hooks; independently initialize source and target. Expected:
//    Changing the participating field makes comparison false; changing only
//    the excluded field leaves comparison true.
// 3. 1800.2-2020 F.2.1.9 (UVM-FIELD-MACRO-AUDIT-NOCOPY-MEANING) gives rule 3
//    above. Setup: Use distinct enabled/excluded fields or omitted/explicit
//    flags in an original registered class without user operation hooks;
//    independently initialize source and target. Expected: The excluded field
//    retains its independently initialized destination value.
// 4. 1800.2-2020 F.2.1.9 (UVM-FIELD-MACRO-AUDIT-NOCOMPARE-MEANING) gives rule
//    4 above. Setup: Use distinct enabled/excluded fields or omitted/explicit
//    flags in an original registered class without user operation hooks;
//    independently initialize source and target. Expected: A selected
//    difference in the excluded field does not make comparison false.
// 5. 1800.2-2020 F.2.1.8 (UVM-FIELD-MACRO-AUDIT-POSITIVE-OPERATION-FLAGS)
//    gives rule 5 above. Setup: Use distinct enabled/excluded fields or
//    omitted/explicit flags in an original registered class without user
//    operation hooks; independently initialize source and target. Expected:
//    The participating field is copied and an independent compare-enabled
//    field detects its selected mismatch.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_field_macro_negative_copy_compare_flags_override_all_positive_operations;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class packet extends uvm_object;
    int copied, ignored_copy, compared, ignored_compare;
    `uvm_object_utils_begin(packet)
      `uvm_field_int(copied,UVM_COPY|UVM_COMPARE)
      `uvm_field_int(ignored_copy,UVM_COPY|UVM_ALL_ON|UVM_NOCOPY|UVM_NOCOMPARE)
      `uvm_field_int(compared,UVM_COMPARE|UVM_NOCOPY)
      `uvm_field_int(ignored_compare,UVM_COMPARE|UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOCOPY)
    `uvm_object_utils_end
    function new(string name="packet65"); super.new(name); endfunction
  endclass
  initial begin
    automatic packet source=new(), target=new();
    bit equal_before, compared_mismatch, ignored_mismatch;
    source.copied=17; target.copied=-1;
    source.ignored_copy=29; target.ignored_copy=71;
    source.compared=43; target.compared=43;
    source.ignored_compare=89; target.ignored_compare=-31;
    target.copy(source); equal_before=target.compare(source);
    target.compared=44; compared_mismatch=target.compare(source);
    target.compared=43; target.ignored_compare=501; ignored_mismatch=target.compare(source);
    $display("UT: negative_flags copied %0d skip_copy %0d equal %0d mismatch %0d ignored %0d",
      target.copied==17,target.ignored_copy==71,equal_before,compared_mismatch,ignored_mismatch);
    $finish;
  end
endmodule
