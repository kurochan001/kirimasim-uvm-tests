// Original textual attributes isolate visibility from numeric formatting.
function automatic bit contains75(string text, string token);
  if (text.len() < token.len()) return 0;
  for (int i = 0; i <= text.len() - token.len(); i++)
    if (text.substr(i, i + token.len() - 1) == token) return 1;
  return 0;
endfunction
function automatic bit visible75(string text, string a, string b, bit enabled);
  return contains75(text, a) == enabled && contains75(text, b) == enabled;
endfunction
class subject75 extends uvm_object;
  int revision = 0;
  function new(string name = "root75");
    super.new(name);
  endfunction
  virtual function void do_print(uvm_printer printer);
    printer.print_generic_element("N75_ALPHA", "T75_ALPHA", "S75_ALPHA",
                                 $sformatf("V75_ALPHA_%0d_END", revision));
    printer.print_generic_element("N75_BETA", "T75_BETA", "S75_BETA",
                                 $sformatf("V75_BETA_%0d_END", revision));
  endfunction
endclass
function automatic uvm_printer make_printer75(int kind);
  uvm_table_printer table_value;
  uvm_tree_printer tree_value;
  uvm_line_printer line_value;
  case (kind)
    0: begin
      table_value = new;
      return table_value;
    end
    1: begin
      tree_value = new;
      return tree_value;
    end
    2: begin
      line_value = new;
      return line_value;
    end
    default: $fatal(1, "unexpected printer kind");
  endcase
  return null;
endfunction
function automatic void configure75(uvm_printer printer, int mask);
  printer.set_name_enabled(mask[0]);
  printer.set_type_name_enabled(mask[1]);
  printer.set_size_enabled(mask[2]);
endfunction
function automatic bit peer75(uvm_printer printer, subject75 subject);
  string text;
  text = subject.sprint(printer);
  return printer.get_name_enabled() && printer.get_type_name_enabled() &&
         printer.get_size_enabled() && visible75(text, "N75_ALPHA", "N75_BETA", 1) &&
         visible75(text, "T75_ALPHA", "T75_BETA", 1) &&
         visible75(text, "S75_ALPHA", "S75_BETA", 1);
endfunction
function automatic void observe75(int mask, string text, subject75 subject,
                                  uvm_printer peer);
  bit names, types, sizes, values, stale, other;
  names = visible75(text, "N75_ALPHA", "N75_BETA", mask[0]);
  types = visible75(text, "T75_ALPHA", "T75_BETA", mask[1]);
  sizes = visible75(text, "S75_ALPHA", "S75_BETA", mask[2]);
  values = contains75(text, $sformatf("V75_ALPHA_%0d_END", subject.revision)) &&
           contains75(text, $sformatf("V75_BETA_%0d_END", subject.revision));
  stale = 0;
  for (int previous = 0; previous < subject.revision; previous++)
    stale |= contains75(text, $sformatf("V75_ALPHA_%0d_END", previous)) ||
             contains75(text, $sformatf("V75_BETA_%0d_END", previous));
  other = peer75(peer, subject);
  $display("UT: p75 %0d name %0b type %0b size %0b value %0b stale %0b peer %0b",
           mask, names, types, sizes, values, stale, other);
endfunction
