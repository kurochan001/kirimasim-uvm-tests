// Original observer uses the public element stack, not rendered layout.
function automatic bit contains93(string text,string token);
  if(text.len()<token.len()) return 0;
  for(int i=0;i<=text.len()-token.len();i++)
    if(text.substr(i,i+token.len()-1)==token) return 1;
  return 0;
endfunction
class observer93 extends uvm_printer;
  string values[string];
  function new(string name="observer93");super.new(name);endfunction
  virtual function void push_element(string name,string type_name,string size,string value="");
    uvm_printer_element current;
    super.push_element(name,type_name,size,value);
    current=get_top_element();
    values[name]=current.get_element_value();
  endfunction
  virtual function string emit();return "";endfunction
endclass
function automatic void prepare93(observer93 p);
  uvm_radix_enum selected[$];
  selected={UVM_BIN,UVM_DEC,UVM_UNSIGNED,UVM_UNFORMAT2,UVM_UNFORMAT4,UVM_OCT,UVM_HEX,UVM_STRING,UVM_TIME,UVM_ENUM,UVM_REAL,UVM_REAL_DEC,UVM_REAL_EXP,UVM_NORADIX};
  foreach(selected[i]) p.set_radix_string(selected[i],"");
  p.set_radix_enabled(1);
endfunction
class payload93 extends uvm_object;
  logic[TEXT_WIDTH93-1:0] packed_value;
  string text_value;
  `uvm_object_utils_begin(payload93)
    `uvm_field_int(packed_value,UVM_PRINT|UVM_STRING)
    `uvm_field_string(text_value,UVM_PRINT|UVM_STRING)
  `uvm_object_utils_end
  function new(string name="payload93");super.new(name);endfunction
endclass
initial begin
  payload93 subject;
  observer93 printer;
  string ignored,packed_expected,text_expected;
  subject=new();printer=new();prepare93(printer);
  if(VARIANT==0) begin subject.packed_value="AZ";packed_expected="AZ";text_expected="alpha93";end
  else begin subject.packed_value="mN7!";packed_expected="mN7!";text_expected="BETA:73";end
  subject.text_value=text_expected;ignored=subject.sprint(printer);
  $display("UT: radix93 %s string packed %0d native %0d",CASE_NAME,
    printer.values["packed_value"]==packed_expected,printer.values["text_value"]==text_expected);
  $finish;
end
