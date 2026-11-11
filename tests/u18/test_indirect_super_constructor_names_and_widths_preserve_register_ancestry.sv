/*
:name: test_indirect_super_constructor_names_and_widths_preserve_register_ancestry
:description: indirect super constructor names and widths preserve register ancestry
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.7.2.1 18.7.1 18.4.3.8 5.3.4.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_indirect_super_constructor_names_and_widths_preserve_register_ancestry.expected
*/
// What it checks:
// 1. An indirect-register extension retains actual omitted/explicit super
//    constructor names.
// 2. The indirect constructor retains the selected register widths.
// 3. Indirect-register extensions retain distinct uvm_reg base views.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.7.2.1 (UVM-MEM-FIFO-AUDIT-INDIRECT-CONSTRUCTOR-NAME) gives
//    rule 1 above. Setup: Use original subclasses calling super.new, including
//    a genuinely omitted name through the printed named arguments; do not
//    directly construct the discouraged base. Expected: The omitted name is
//    uvm_reg_indirect and the explicit peer name is explicit63.
// 2. 1800.2-2020 18.7.2.1 (UVM-MEM-FIFO-AUDIT-INDIRECT-CONSTRUCTOR-WIDTH)
//    gives rule 2 above. Setup: Use original subclasses calling super.new,
//    including a genuinely omitted name through the printed named arguments;
//    do not directly construct the discouraged base. Expected: The two legal
//    extensions report eight and sixteen bits respectively.
// 3. 1800.2-2020 18.7.1 (UVM-MEM-FIFO-AUDIT-INDIRECT-ANCESTRY) gives rule 3
//    above. Setup: Use original subclasses calling super.new, including a
//    genuinely omitted name through the printed named arguments; do not
//    directly construct the discouraged base. Expected: Both implicit base
//    views preserve their exact distinct original handles.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_indirect_super_constructor_names_and_widths_preserve_register_ancestry;
  import uvm_pkg::*;
  class omitted_extension extends uvm_reg_indirect_data;
    function new(); super.new(.n_bits(8),.has_cover(UVM_NO_COVERAGE)); endfunction
  endclass
  class explicit_extension extends uvm_reg_indirect_data;
    function new(string name); super.new(name,16,UVM_NO_COVERAGE); endfunction
  endclass
  initial begin
    omitted_extension first;
    explicit_extension second;
    uvm_reg first_base,second_base;
    first=new(); second=new("explicit63"); first_base=first; second_base=second;
    $display("UT: indirect_constructor omitted_name %0d explicit_name %0d dimensions %0d",
      first.get_name()=="uvm_reg_indirect",second.get_name()=="explicit63",
      first.get_n_bits()==8 && second.get_n_bits()==16);
    $display("UT: indirect_ancestry first %0d second %0d distinct %0d",
      first_base==first,second_base==second,first_base!=second_base);
    $finish;
  end
endmodule
