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
