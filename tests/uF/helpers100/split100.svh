// Exercise a signed byte separator without regex, DPI or a legacy alias.
initial begin
  string sep_text,input_text,values[$];
  bit positions;
  sep_text="x";sep_text.putc(0,SEPARATOR100);
  values.push_back("stale100");values.push_back("another100");
  input_text={"north100",sep_text,sep_text,"south100",sep_text};
  uvm_string_split(input_text,SEPARATOR100,values);
  positions=values.size()==4;
  if(positions) positions=values[0]=="north100" && values[1]=="" && values[2]=="south100" && values[3]=="";
  $display("UT: split100 %0d mixed count %0d positions %0d",PROFILE100,values.size(),positions);
  if(values.size()>0) values[0]="mutated100";
  uvm_string_split({sep_text,sep_text,sep_text},SEPARATOR100,values);
  positions=values.size()==4;
  foreach(values[i]) positions &= values[i]=="";
  $display("UT: split100 %0d all count %0d positions %0d",PROFILE100,values.size(),positions);
  uvm_string_split("kept100",SEPARATOR100,values);
  positions=values.size()==1;
  if(positions) positions=values[0]=="kept100";
  $display("UT: split100 %0d none count %0d positions %0d",PROFILE100,values.size(),positions);
  uvm_string_split("",SEPARATOR100,values);
  positions=values.size()==1;
  if(positions) positions=values[0]=="";
  $display("UT: split100 %0d empty count %0d positions %0d",PROFILE100,values.size(),positions);
  $finish;
end
