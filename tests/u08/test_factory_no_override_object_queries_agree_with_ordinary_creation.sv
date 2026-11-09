/*
:name: test_factory_no_override_object_queries_agree_with_ordinary_creation
:description: lookup without any override selects the registered wrapper used by ordinary creation (IEEE 1800.2-2020 Section 8.3.1.7.1)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.3.1.7.1 8.3.1.7.2 8.3.1.7.3 8.3.1.7.4 B.2.1
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_factory_no_override_object_queries_agree_with_ordinary_creation.expected
*/
// What it checks:
// Override lookup without a matching override returns the wrapper that
// ordinary creation would use.
//
// How the expected output follows from the standard:
// 1800.2-2020 8.3.1.7.1 (UVM-FACTORY-NO-OVERRIDE-QUERY) gives the rule above.
// Setup: Register an ordinary named type and query a path with no
// instance/type override. Expected: The selected wrapper agrees with ordinary
// creation rather than requiring an installed override.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Install no overrides. Both lookup spellings must agree with creation.
module test_factory_no_override_object_queries_agree_with_ordinary_creation;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class original_item extends uvm_object;
    `uvm_object_utils(original_item)
    function new(string name="original_item"); super.new(name); endfunction
  endclass
  initial begin
    uvm_factory factory;
    uvm_object_wrapper original;
    uvm_object made;
    factory = uvm_factory::get();
    original = original_item::get_type();
    made = factory.create_object_by_name("original_item", "env", "leaf");
    $display("UT: by_type %0d by_name %0d created %0d",
             factory.find_override_by_type(original, "env.leaf") == original,
             factory.find_override_by_name("original_item", "env.leaf") == original,
             made != null && made.get_object_type() == original);
    $finish;
  end
endmodule
