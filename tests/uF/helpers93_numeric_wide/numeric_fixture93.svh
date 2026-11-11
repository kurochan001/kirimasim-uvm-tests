// Original observer uses the public element stack, not rendered layout.
function automatic bit contains93(string text,string token);
  if(text.len()<token.len()) return 0;
  for(int i=0;i<=text.len()-token.len();i++)
    if(text.substr(i,i+token.len()-1)==token) return 1;
  return 0;
endfunction
class observer93 extends uvm_printer;
  string values[string];
  function new(string name="observer93");
    super.new(name);
  endfunction
  virtual function void push_element(string name,string type_name,string size,string value="");
    uvm_printer_element current;
    super.push_element(name,type_name,size,value);
    current=get_top_element();
    values[name]=current.get_element_value();
  endfunction
  virtual function string emit();
    return "";
  endfunction
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
  function new(string name="payload93");
    super.new(name);
  endfunction
endclass
function automatic bit decoded93(string value,string format,uvm_bitstream_t expected_value);
  uvm_bitstream_t parsed;
  int base,digit;
  bit seen,negative,sign_seen,trailing,space;
  parsed='0;
  seen=0;
  negative=0;
  sign_seen=0;
  trailing=0;
  if(format=="%b") base=2;
  else if(format=="%o") base=8;
  else if(format=="%h") base=16;
  else if(format=="%d") base=10;
  else return 0;
  // Independent positional arithmetic; no scanf width or library converter dependency.
  for(int i=0;i<value.len();i++) begin
    space=(value[i]==32 || value[i]==9 || value[i]==10 || value[i]==13);
    if(space) begin
      if(seen) trailing=1;
      continue;
    end
    if(trailing) return 0;
    if(!seen && !sign_seen && (value[i]=="-" || value[i]=="+")) begin
      negative=(value[i]=="-");
      sign_seen=1;
      continue;
    end
    if(value[i]>="0" && value[i]<="9") digit=value[i]-"0";
    else if(value[i]>="a" && value[i]<="f") digit=value[i]-"a"+10;
    else if(value[i]>="A" && value[i]<="F") digit=value[i]-"A"+10;
    else return 0;
    if(digit>=base) return 0;
    parsed=parsed*uvm_bitstream_t'(base)+uvm_bitstream_t'(digit);
    seen=1;
  end
  if(negative) parsed=-parsed;
  return seen && parsed==expected_value;
endfunction

initial begin
  payload93 subject;
  observer93 printer,peer;
  logic[WIDTH93-1:0] value;
  string ignored,raw;
  subject=new();
  printer=new();
  peer=new();
  if(LITERAL93) value=VARIANT==0?WIDTH93'(32'h8f2a4b61):WIDTH93'(64'hc1d2e3f412345678);
  else begin
    value='0;
    value[WIDTH93-1]=1;
    value[15:0]=VARIANT==0?16'h4b61:16'h5a37;
  end
  subject.bin_value=value;
  subject.oct_value=value;
  subject.hex_value=value;
  subject.dec_value=value;
  subject.unsigned_value=value;
  subject.noradix_value=value;
  subject.omitted_value=value;
  prepare93(printer);
  printer.set_default_radix(VARIANT==0?UVM_HEX:UVM_BIN);
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
