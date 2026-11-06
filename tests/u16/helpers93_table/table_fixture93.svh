// Original short-cell row oracle; no fixed header/order/width/punctuation.
function automatic bit has93(string text,string token);
  if(text.len()<token.len()) return 0;
  for(int i=0;i<=text.len()-token.len();i++)
    if(text.substr(i,i+token.len()-1)==token) return 1;
  return 0;
endfunction
class subject93 extends uvm_object;
  string names[$],types[$],sizes[$],values[$];
  function new(string name="root93");super.new(name);endfunction
  virtual function void do_print(uvm_printer printer);
    if(VARIANT==0) foreach(names[i]) printer.print_generic_element(names[i],types[i],sizes[i],values[i]);
    else for(int i=names.size()-1;i>=0;i--) printer.print_generic_element(names[i],types[i],sizes[i],values[i]);
  endfunction
endclass
function automatic bit associated93(string text,subject93 subject);
  string row;
  int found[int];
  bit okay=1;
  row="";
  for(int at=0;at<=text.len();at++) begin
    if(at==text.len() || text[at]==10) begin
      foreach(subject.names[i]) if(has93(row,subject.names[i])) begin
        found[i]++;
        okay &= has93(row,subject.types[i]) && has93(row,subject.sizes[i]) && has93(row,subject.values[i]);
        foreach(subject.names[j]) if(j!=i) okay &= !has93(row,subject.names[j]) && !has93(row,subject.values[j]);
      end
      row="";
    end else row={row,text[at]};
  end
  foreach(subject.names[i]) okay &= found.exists(i) && found[i]==1;
  return okay;
endfunction
initial begin
  subject93 subject,peer_subject;
  uvm_table_printer printer,peer;
  string text,peer_text;
  bit peer_clean;
  subject=new("root93");peer_subject=new("peer93");printer=new();peer=new();
  subject.names={"N93_ALPHA","N93_BETA_LONG"};subject.types={"T93_ALPHA_LONG","T93_BETA"};
  subject.sizes={"S93_ALPHA","S93_BETA_LONG"};subject.values={"V93_ALPHA_LONG","V93_BETA"};
  if(VARIANT!=0) begin subject.names.push_back("N93_GAMMA");subject.types.push_back("T93_GAMMA_LONGER");subject.sizes.push_back("S93_GAMMA");subject.values.push_back("V93_GAMMA_LONGER");end
  peer_subject.names={"PEER_N93"};peer_subject.types={"PEER_T93"};peer_subject.sizes={"PEER_S93"};peer_subject.values={"PEER_V93"};
  printer.set_name_enabled(1);printer.set_type_name_enabled(1);printer.set_size_enabled(1);
  peer.set_name_enabled(1);peer.set_type_name_enabled(1);peer.set_size_enabled(1);
  text=subject.sprint(printer);peer_text=peer_subject.sprint(peer);
  peer_clean=associated93(peer_text,peer_subject);
  foreach(subject.names[i]) peer_clean &= !has93(peer_text,subject.names[i]) && !has93(peer_text,subject.values[i]);
  $display("UT: table93 %s rows %0d associated %0d peer %0d",CASE_NAME,subject.names.size(),associated93(text,subject),peer_clean);
  $finish;
end
