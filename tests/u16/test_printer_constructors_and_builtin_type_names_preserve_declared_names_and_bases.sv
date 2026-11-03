/*
:name: test_printer_constructors_and_builtin_type_names_preserve_declared_names_and_bases
:description: printer constructors and builtin type names preserve declared names and bases
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.2.1 16.2.1 16.2.10.1 16.2.10.2.1 16.2.10.2.2 16.2.11.1 16.2.11.2.1 16.2.11.2.2 16.2.12.1 16.2.12.2.1 16.2.12.2.2 16.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_constructors_and_builtin_type_names_preserve_declared_names_and_bases.expected
*/
module test_printer_constructors_and_builtin_type_names_preserve_declared_names_and_bases;
  import uvm_pkg::*;
  class omitted_printer extends uvm_printer;
    virtual function string emit(); return ""; endfunction
  endclass
  class named_printer extends uvm_printer;
    function new(string name); super.new(name); endfunction
    virtual function string emit(); return ""; endfunction
  endclass
  initial begin
    automatic omitted_printer omitted=new();
    automatic named_printer named=new("selected");
    automatic named_printer empty=new("");
    automatic uvm_policy base_view=named;
    automatic uvm_table_printer table_default=new();
    automatic uvm_table_printer table_named=new("table");
    automatic uvm_table_printer table_empty=new("");
    automatic uvm_tree_printer tree_default=new();
    automatic uvm_tree_printer tree_named=new("tree");
    automatic uvm_tree_printer tree_empty=new("");
    automatic uvm_line_printer line_default=new();
    automatic uvm_line_printer line_named=new("line");
    automatic uvm_line_printer line_empty=new("");
    automatic uvm_printer views[3]='{table_named,tree_named,line_named};
    $display("UT: base_printer_names default %0d named %0d empty %0d base %0d",
             omitted.get_name()=="",named.get_name()=="selected",empty.get_name()=="",
             base_view==named);
    $display("UT: table_printer_names default %0d named %0d empty %0d type %0d base %0d",
             table_default.get_name()=="",table_named.get_name()=="table",
             table_empty.get_name()=="",
             table_named.get_type_name()=="uvm_table_printer",views[0]==table_named);
    $display("UT: tree_printer_names default %0d named %0d empty %0d type %0d base %0d",
             tree_default.get_name()=="",tree_named.get_name()=="tree",tree_empty.get_name()=="",
             tree_named.get_type_name()=="uvm_tree_printer",views[1]==tree_named);
    $display("UT: line_printer_names default %0d named %0d empty %0d type %0d base %0d",
             line_default.get_name()=="",line_named.get_name()=="line",line_empty.get_name()=="",
             line_named.get_type_name()=="uvm_line_printer",views[2]==line_named);
    $finish;
  end
endmodule
