/*
:name: test_root_find_exact_full_names_return_the_original_component_handles
:description: root find resolves full names to exact component handles (IEEE 1800.2-2020 Section F.7.4.1)
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.7.4.1 F.7.1 F.3.3.1 13.1.3.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_root_find_exact_full_names_return_the_original_component_handles.expected
*/
// What it checks:
// Root find resolves matching full names to the original components.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.7.4.1 (UVM-ROOT-FIND-EXACT-HANDLES) gives the rule above.
// Setup: Query the root environment, one branch and one leaf. Expected: Each
// result is the exact corresponding handle.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Explicit finite component tree; only exact handles and set membership.
// No sibling traversal order, global root enumeration or print format is fixed.
module test_root_find_exact_full_names_return_the_original_component_handles;
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

    $display("UT: exact env %0d branch %0d leaf %0d", root.find("env") == env,
    root.find("env.alpha") == alpha, root.find("env.beta.leaf") == beta_leaf);

    $finish;
  end

endmodule
