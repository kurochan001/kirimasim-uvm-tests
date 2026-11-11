/*
:name: test_field_macro_omitted_default_and_all_on_enable_the_same_copy_and_compare_fields
:description: Omitted FLAG DEFAULT and ALL_ON have the same selected field behavior
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.2.2 B.2.2.1.1 F.2.1.10 F.2.1.9 5.3.8.1 5.3.9.1 1800-2023 6.21 8.20 8.21 7.4 7.8 7.9 8.19
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_field_macro_omitted_default_and_all_on_enable_the_same_copy_and_compare_fields.expected
*/
// What it checks:
// An omitted FLAG and explicit DEFAULT are functionally identical to ALL_ON
// for selected operations.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.2.1.10 (UVM-FIELD-MACRO-AUDIT-DEFAULT-ALL-ON-EQUIVALENCE)
// gives the rule above. Setup: Use distinct enabled/excluded fields or
// omitted/explicit flags in an original registered class without user
// operation hooks; independently initialize source and target. Expected: All
// three fields copy their distinct source values and each independent mutation
// makes comparison false.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_field_macro_omitted_default_and_all_on_enable_the_same_copy_and_compare_fields;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class packet extends uvm_object;
    int omitted, explicit_default, explicit_all;
    `uvm_object_utils_begin(packet)
      `uvm_field_int(omitted)
      `uvm_field_int(explicit_default,UVM_DEFAULT)
      `uvm_field_int(explicit_all,UVM_ALL_ON)
    `uvm_object_utils_end
    function new(string name="packet65"); super.new(name); endfunction
  endclass
  initial begin
    automatic packet source=new(), target=new();
    bit equal_value, mismatch[3];
    source.omitted=17; source.explicit_default=29; source.explicit_all=43;
    target.copy(source); equal_value=target.compare(source);
    target.omitted++; mismatch[0]=target.compare(source); target.omitted--;
    target.explicit_default++; mismatch[1]=target.compare(source); target.explicit_default--;
    target.explicit_all++; mismatch[2]=target.compare(source);
    $display("UT: default_flags copied %0d equal %0d mismatches %0d %0d %0d",
      target.omitted==17 && target.explicit_default==29 && target.explicit_all==44,
      equal_value,mismatch[0],mismatch[1],mismatch[2]);
    $finish;
  end
endmodule
