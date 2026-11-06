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
  real general_value,decimal_value,exponential_value;
  `uvm_object_utils_begin(payload93)
    `uvm_field_real(general_value,UVM_PRINT|UVM_REAL)
    `uvm_field_real(decimal_value,UVM_PRINT|UVM_REAL_DEC)
    `uvm_field_real(exponential_value,UVM_PRINT|UVM_REAL_EXP)
  `uvm_object_utils_end
  function new(string name="payload93");super.new(name);endfunction
endclass
function automatic bit real_value93(string text,real expected_value);
  real parsed;
  int count;
  parsed=0;count=$sscanf(text,"%f",parsed);
  return count==1 && parsed>=expected_value-((expected_value<0?-expected_value:expected_value)*1.0e-6) &&
         parsed<=expected_value+((expected_value<0?-expected_value:expected_value)*1.0e-6);
endfunction
initial begin
  payload93 subject;
  observer93 printer;
  string ignored,g,d,e;
  bit ge,de,ee;
  subject=new();printer=new();prepare93(printer);
  subject.general_value=VARIANT==0?1.25:125000000.0;
  subject.decimal_value=VARIANT==0?125000000.0:-3500000000.0;
  subject.exponential_value=VARIANT==0?1.25:-2.5;
  ignored=subject.sprint(printer);
  g=printer.values["general_value"];d=printer.values["decimal_value"];e=printer.values["exponential_value"];
  ge=contains93(g,"e")||contains93(g,"E");de=contains93(d,"e")||contains93(d,"E");ee=contains93(e,"e")||contains93(e,"E");
  $display("UT: radix93 %s real_general value %0d notation %0d",CASE_NAME,real_value93(g,subject.general_value),ge==(VARIANT!=0));
  $display("UT: radix93 %s real_decimal value %0d notation %0d",CASE_NAME,real_value93(d,subject.decimal_value),!de);
  $display("UT: radix93 %s real_exponential value %0d notation %0d",CASE_NAME,real_value93(e,subject.exponential_value),ee);
  $finish;
end
