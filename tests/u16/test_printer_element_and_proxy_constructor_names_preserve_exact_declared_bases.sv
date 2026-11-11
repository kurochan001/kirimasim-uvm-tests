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
// What it checks:
// 1. Constructing a printer element gives its object the supplied name.
// 2. The printer element retains its declared object base.
// 3. The element proxy retains the exact structure-proxy specialization.
// 4. The element proxy constructor preserves default, explicit and empty
//    names.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.2.8.2.1 (UVM-PRINTER-ELEMENT-CONSTRUCTOR-NAME) gives rule
//    1 above. Setup: Construct two named elements before assigning any element
//    fields. Expected: Object names reflect constructor arguments without
//    substituting them for element-field values.
// 2. 1800.2-2020 16.2.8.1 (UVM-PRINTER-AUDIT-ELEMENT-OBJECT-BASE) gives rule 2
//    above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: The selected
//    default/named/empty observations and exact base assignment match.
// 3. 1800.2-2020 16.2.9.1 (UVM-PRINTER-AUDIT-PROXY-EXACT-BASE) gives rule 3
//    above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: The selected
//    default/named/empty observations and exact base assignment match.
// 4. 1800.2-2020 16.2.9.2.1 (UVM-PRINTER-AUDIT-PROXY-CONSTRUCTOR) gives rule 4
//    above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: The selected
//    default/named/empty observations and exact base assignment match.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
