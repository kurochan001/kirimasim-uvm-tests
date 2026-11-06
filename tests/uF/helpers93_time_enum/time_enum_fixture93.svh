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
typedef enum {ALPHA93,BETA93} choice93;
class payload93 extends uvm_object;
  time time_value;
  choice93 enum_value;
  `uvm_object_utils_begin(payload93)
    `uvm_field_int(time_value,UVM_PRINT|UVM_TIME)
    `uvm_field_enum(choice93,enum_value,UVM_PRINT|UVM_ENUM)
  `uvm_object_utils_end
  function new(string name="payload93");super.new(name);endfunction
endclass
initial begin
  payload93 subject;
  observer93 printer,control;
  string ignored,expected_name,time_text;
  subject=new();printer=new();control=new();prepare93(printer);prepare93(control);
  $timeformat(-9,0,"NS93",0);
  subject.time_value=VARIANT==0?19:31;subject.enum_value=VARIANT==0?ALPHA93:BETA93;
  expected_name=subject.enum_value.name();ignored=subject.sprint(printer);
  control.push_element("root93","object","0","");
  control.print_time("time_control",subject.time_value);
  time_text=printer.values["time_value"];
  $display("UT: radix93 %s time representation %0d suffix %0d",CASE_NAME,
    time_text==control.values["time_control"],contains93(time_text,"NS93"));
  $display("UT: radix93 %s enum name %0d",CASE_NAME,printer.values["enum_value"]==expected_name);
  $finish;
end
