/*
:name: test_printer_tree_and_line_separators_ignore_extra_characters_around_children
:description: printer tree and line separators ignore extra characters around children
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.11.3.2 16.2.12.3 16.2.12 16.2.4.1 16.2.8 16.2.11 16.1.2.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_tree_and_line_separators_ignore_extra_characters_around_children.expected
*/
// What it checks:
// 1. The selected built-in emitters return a representation of the constructed
//    child structure.
// 2. The selected tree format renders a named child within its parent
//    separators.
// 3. The selected line printer renders its structure on one nonempty line.
// 4. A flushed selected printer can be reused without stale structural output.
// 5. The tree printer uses the first two separator characters and ignores the
//    rest.
// 6. The line printer uses the first two separator characters and ignores the
//    rest.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.2.4.1 (UVM-PRINTER-AUDIT-EMIT-STRUCTURED-CHILD) gives rule
//    1 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: The emitted
//    child marker occurs between the selected opening/closing separators, with
//    ignored separator suffix absent.
// 2. 1800.2-2020 16.2.11 (UVM-PRINTER-AUDIT-TREE-NESTED-OUTPUT) gives rule 2
//    above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: The emitted
//    child marker occurs between the selected opening/closing separators, with
//    ignored separator suffix absent.
// 3. 1800.2-2020 16.2.12 (UVM-PRINTER-AUDIT-LINE-SINGLE-LINE-OUTPUT) gives
//    rule 3 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: The selected
//    parent/child emission contains one nonempty line.
// 4. 1800.2-2020 16.1.2.2 (UVM-PRINTER-AUDIT-POLICY-FLUSH-PRINT-REUSE) gives
//    rule 4 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: Rebuilding
//    the same structure after flush gives the same output when only ignored
//    separator characters differ.
// 5. 1800.2-2020 16.2.11.3.2 (UVM-PRINTER-AUDIT-TREE-SEPARATOR-SUFFIX-IGNORED)
//    gives rule 5 above. Setup: Use the original selected fixtures and
//    explicit API arguments represented by the observation anchors. Expected:
//    [] and []EXTRA42 produce the same selected structure with the child
//    inside brackets.
// 6. 1800.2-2020 16.2.12.3 (UVM-PRINTER-AUDIT-LINE-SEPARATOR-SUFFIX-IGNORED)
//    gives rule 6 above. Setup: Use the original selected fixtures and
//    explicit API arguments represented by the observation anchors. Expected:
//    [] and []EXTRA42 produce the same selected structure with the child
//    inside brackets.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_printer_tree_and_line_separators_ignore_extra_characters_around_children;
  import uvm_pkg::*;
  function automatic int find_token(string text,string token);
    for (int i=0;i+token.len()<=text.len();i++)
      if (text.substr(i,i+token.len()-1)==token) return i;
    return -1;
  endfunction
  function automatic string render(uvm_printer printer);
    printer.print_array_header("parent42",1);
    printer.print_string("child42","value42"); printer.print_array_footer();
    return printer.emit();
  endfunction
  initial begin
    automatic uvm_tree_printer tree_value=new();
    automatic uvm_line_printer line_value=new();
    automatic uvm_printer printers[2]='{tree_value,line_value};
    string normal,extra;
    int opened,child,closed,lines;
    bit in_line;
    foreach (printers[i]) begin
      printers[i].flush(); printers[i].set_name_enabled(1);
      if (i==0) tree_value.set_separators("[]"); else line_value.set_separators("[]");
      normal=render(printers[i]); printers[i].flush();
      if (i==0) tree_value.set_separators("[]EXTRA42");
      else line_value.set_separators("[]EXTRA42");
      extra=render(printers[i]);
      opened=find_token(extra,"["); child=find_token(extra,"child42"); closed=find_token(extra,"]");
      $display("UT: separator_format %0d unchanged %0d brackets %0d tail_absent %0d",i,
               normal==extra,opened>=0 && child>opened && closed>child,
               find_token(extra,"EXTRA42")==-1);
      if (i==1) begin
        lines=0; in_line=0;
        for (int k=0;k<extra.len();k++) begin
          if (extra[k]==10) begin if (in_line) lines++; in_line=0; end
          else in_line=1;
        end
        if (in_line) lines++;
        $display("UT: line_format one_nonempty_line %0d",lines==1);
      end
    end
    $finish;
  end
endmodule
