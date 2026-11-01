/*
:name: test_core_component_visitor_selection_and_restoration
:description: core service selects and restores a component visitor (IEEE 1800.2-2020 Section F.4.1.4.9)
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.4.1.4.9 F.4.1.4.8 F.4.1.3 F.5.1.2.3 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_core_component_visitor_selection_and_restoration.expected
*/
// Check service selection independently of automatic end-of-elaboration
// traversal or component-name validation; no default visitor type is assumed.
module test_core_component_visitor_selection_and_restoration;
  import uvm_pkg::*;

  class component_node extends uvm_component;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass
  class audit_visitor extends uvm_visitor#(uvm_component);
    uvm_component visited[$];
    int begins = 0;
    int ends = 0;
    string trace = "";
    function new(string name="visitor"); super.new(name); endfunction
    virtual function void begin_v(); begins++; trace = {trace, "B"}; endfunction
    virtual function void end_v(); ends++; trace = {trace, "E"}; endfunction
    virtual function void visit(uvm_component node); visited.push_back(node); trace = {trace,
    "V"}; endfunction
    function int count(uvm_component node);
      int result_value = 0;
      foreach (visited[i]) if (visited[i] == node) result_value++;
      return result_value;
    endfunction
    function int position(uvm_component node);
      foreach (visited[i]) if (visited[i] == node) return i;
      return -1;
    endfunction
  endclass

  initial begin
    automatic uvm_coreservice_t core = uvm_coreservice_t::get();
    automatic uvm_visitor#(uvm_component) saved = core.get_component_visitor();
    automatic audit_visitor first = new("first");
    automatic audit_visitor second = new("second");
    core.set_component_visitor(first);
    $display("UT: selected first %0d", core.get_component_visitor() == first);
    core.set_component_visitor(second);
    $display("UT: selected second %0d first_unused %0d", core.get_component_visitor() == second,
    first.visited.size() == 0);
    core.set_component_visitor(saved);
    $display("UT: restored exact %0d", core.get_component_visitor() == saved);
    $finish;
  end

endmodule
