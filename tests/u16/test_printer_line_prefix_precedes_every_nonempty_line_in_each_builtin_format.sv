/*
:name: test_printer_line_prefix_precedes_every_nonempty_line_in_each_builtin_format
:description: printer line prefix precedes every nonempty line in each builtin format
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.5.12 16.2.4.1 16.2.10 16.2.11 16.2.12 16.2 16.2.5 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_line_prefix_precedes_every_nonempty_line_in_each_builtin_format.expected
*/
// What it checks:
// 1. Fresh built-in printer kinds have an empty line prefix.
// 2. Every nonempty emitted line begins with the configured line prefix.
// 3. The built-in printer instances are usable through the common printer
//    interface.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.2.5.12 (UVM-PRINTER-AUDIT-LINE-PREFIX-DEFAULT) gives rule
//    1 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: All three
//    concrete kinds return the empty default.
// 2. 1800.2-2020 16.2.5.12 (UVM-PRINTER-AUDIT-LINE-PREFIX-ACTUAL-EMISSION)
//    gives rule 2 above. Setup: Use the original selected fixtures and
//    explicit API arguments represented by the observation anchors. Expected:
//    Table/tree/line emissions are nonempty and every observed nonempty line
//    starts P42|.
// 3. 1800.2-2020 16.2 (UVM-PRINTER-AUDIT-COMMON-PRINTER-INTERFACE) gives rule
//    3 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: The three
//    typed base views accept construction of a small array and emit their
//    configured prefixed output.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_printer_line_prefix_precedes_every_nonempty_line_in_each_builtin_format;
  import uvm_pkg::*;
  function automatic void inspect(string text,string prefix,output int lines,bad);
    string line="";
    lines=0; bad=0;
    for (int i=0;i<=text.len();i++) begin
      if (i==text.len() || text[i]==10) begin
        if (line!="") begin
          lines++;
          if (line.len()<prefix.len() || line.substr(0,prefix.len()-1)!=prefix) bad++;
        end
        line="";
      end else line={line,text.substr(i,i)};
    end
  endfunction
  initial begin
    automatic uvm_table_printer table_value=new();
    automatic uvm_tree_printer tree_value=new();
    automatic uvm_line_printer line_value=new();
    automatic uvm_printer printers[3]='{table_value,tree_value,line_value};
    int lines,bad;
    string text;
    foreach (printers[i]) begin
      $display("UT: prefix_default %0d empty %0d",i,printers[i].get_line_prefix()=="");
      printers[i].set_line_prefix("P42|"); printers[i].print_array_header("values",2);
      printers[i].print_field_int("first",3,8); printers[i].print_field_int("second",7,8);
      printers[i].print_array_footer(); text=printers[i].emit(); inspect(text,"P42|",lines,bad);
      $display("UT: prefix_emitted %0d nonempty %0d all_prefixed %0d getter %0d",i,
               lines>0,bad==0,printers[i].get_line_prefix()=="P42|");
    end
    $finish;
  end
endmodule
