/*
:name: test_root_find_all_scoped_search_includes_its_starting_component
:description: root find_all includes the starting component when its full name matches (IEEE 1800.2-2020 Section F.7.4.1)
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.7.4.1 F.7.1 F.3.3.1 13.1.3.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_root_find_all_scoped_search_includes_its_starting_component.expected
*/
// What it checks:
// A matching starting component is included in its scoped search.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.7.4.1 (UVM-ROOT-FIND-ALL-INCLUDES-START) gives the rule above.
// Setup: Use alpha as both the starting component and exact full-name pattern.
// Expected: The sole result is alpha itself.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Explicit finite component tree; only exact handles and set membership.
// No sibling traversal order, global root enumeration or print format is fixed.
module test_root_find_all_scoped_search_includes_its_starting_component;
  import uvm_pkg::*;

  class node extends uvm_component;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass
  function automatic int occurrences(uvm_component queue[$], uvm_component value);
    int result_value = 0;
    foreach (queue[i]) if (queue[i] == value) result_value++;
    return result_value;
  endfunction
  initial begin
    automatic uvm_root root = uvm_root::get();
    automatic node env = new("env", null);
    automatic node alpha = new("alpha", env);
    automatic node beta = new("beta", env);
    automatic node alpha_leaf = new("leaf", alpha);
    automatic node beta_leaf = new("leaf", beta);
    uvm_component found_components[$];

    root.find_all("env.alpha", found_components, alpha);
    $display("UT: starting_node size %0d exact %0d", found_components.size(),
    found_components.size() == 1 &&
    found_components[0] == alpha);

    $finish;
  end

endmodule
