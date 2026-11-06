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
  logic[WIDTH93-1:0] bin_value,oct_value,hex_value,dec_value,unsigned_value,noradix_value,omitted_value;
  `uvm_object_utils_begin(payload93)
    `uvm_field_int(bin_value,UVM_PRINT|UVM_BIN)
    `uvm_field_int(oct_value,UVM_PRINT|UVM_OCT)
    `uvm_field_int(hex_value,UVM_PRINT|UVM_HEX)
    `uvm_field_int(dec_value,UVM_PRINT|UVM_DEC)
    `uvm_field_int(unsigned_value,UVM_PRINT|UVM_UNSIGNED)
    `uvm_field_int(noradix_value,UVM_PRINT|UVM_NORADIX)
    `uvm_field_int(omitted_value,UVM_PRINT)
  `uvm_object_utils_end
  function new(string name="payload93");super.new(name);endfunction
endclass
function automatic bit decoded93(string value,string format,uvm_bitstream_t expected_value);
  uvm_bitstream_t parsed;
  int count;
  parsed='0;count=0;
  // Same finite formats as the caller; avoid an unrelated variable-format parser limitation.
  if(format=="%b") count=$sscanf(value,"%b",parsed);
  else if(format=="%o") count=$sscanf(value,"%o",parsed);
  else if(format=="%h") count=$sscanf(value,"%h",parsed);
  else if(format=="%d") count=$sscanf(value,"%d",parsed);
  return count==1 && parsed==expected_value;
endfunction
initial begin
  payload93 subject;
  observer93 printer,peer;
  logic[WIDTH93-1:0] value;
  string ignored,raw;
  subject=new();printer=new();peer=new();
  if(LITERAL93) value=VARIANT==0?WIDTH93'(32'h8f2a4b61):WIDTH93'(64'hc1d2e3f412345678);
  else begin value='0;value[WIDTH93-1]=1;value[15:0]=VARIANT==0?16'h4b61:16'h5a37;end
  subject.bin_value=value;subject.oct_value=value;subject.hex_value=value;subject.dec_value=value;
  subject.unsigned_value=value;subject.noradix_value=value;subject.omitted_value=value;
  prepare93(printer);printer.set_default_radix(VARIANT==0?UVM_HEX:UVM_BIN);
  ignored=subject.sprint(printer);
  if(LITERAL93) begin
    // Qualified alternative to the unsigned-decimal prose: literal %u.
    raw=$sformatf("%u",value);
    $display("UT: radix93 %s unsigned_literal format %0d",CASE_NAME,
      printer.values.exists("unsigned_value") && printer.values["unsigned_value"]==raw);
  end else begin
    $display("UT: radix93 %s bin format %0d",CASE_NAME,decoded93(printer.values["bin_value"],"%b",uvm_bitstream_t'(value)));
    $display("UT: radix93 %s oct format %0d",CASE_NAME,decoded93(printer.values["oct_value"],"%o",uvm_bitstream_t'(value)));
    $display("UT: radix93 %s hex format %0d",CASE_NAME,decoded93(printer.values["hex_value"],"%h",uvm_bitstream_t'(value)));
    $display("UT: radix93 %s dec format %0d",CASE_NAME,decoded93(printer.values["dec_value"],"%d",uvm_bitstream_t'(value)));
    $display("UT: radix93 %s unsigned_text format %0d",CASE_NAME,decoded93(printer.values["unsigned_value"],"%d",uvm_bitstream_t'(value)));
    $display("UT: radix93 %s default explicit %0d omitted %0d peer %0d",CASE_NAME,
      decoded93(printer.values["noradix_value"],VARIANT==0?"%h":"%b",uvm_bitstream_t'(value)),
      decoded93(printer.values["omitted_value"],VARIANT==0?"%h":"%b",uvm_bitstream_t'(value)),peer.get_default_radix()==UVM_HEX);
  end
  $finish;
end
