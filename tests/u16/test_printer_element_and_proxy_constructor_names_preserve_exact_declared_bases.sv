/*
:name: test_printer_element_and_proxy_constructor_names_preserve_exact_declared_bases
:description: printer element and proxy constructor names preserve exact declared bases
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.9.2.1 16.2.9.1 16.2.8.1 16.2.8.2.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_element_and_proxy_constructor_names_preserve_exact_declared_bases.expected
*/
module test_printer_element_and_proxy_constructor_names_preserve_exact_declared_bases;
  import uvm_pkg::*;
  initial begin
    automatic uvm_printer_element element_default=new();
    automatic uvm_printer_element element_named=new("element");
    automatic uvm_printer_element element_empty=new("");
    automatic uvm_printer_element_proxy proxy_default=new();
    automatic uvm_printer_element_proxy proxy_named=new("proxy");
    automatic uvm_printer_element_proxy proxy_empty=new("");
    automatic uvm_object element_base=element_named;
    automatic uvm_structure_proxy#(uvm_printer_element) proxy_base=proxy_named;
    $display("UT: element_names default %0d named %0d empty %0d base %0d",
             element_default.get_name()=="",element_named.get_name()=="element",
             element_empty.get_name()=="",element_base==element_named);
    $display("UT: proxy_names default %0d named %0d empty %0d base %0d",
             proxy_default.get_name()=="",proxy_named.get_name()=="proxy",
             proxy_empty.get_name()=="",proxy_base==proxy_named);
    $finish;
  end
endmodule
