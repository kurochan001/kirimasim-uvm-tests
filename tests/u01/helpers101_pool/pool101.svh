// Ordinary typed pool; missing-key checks use exists without creating values.
uvm_pool#(string,int) pool101,peer101;
string keys101[2];
int wanted101[2];
function automatic void show_pool101(int stage,int active);
  int seen[2],found,count;
  string cursor,last_cursor;
  bit good,iteration;
  seen='{default:0};count=0;good=1;iteration=1;
  for(int i=0;i<2;i++) begin
    if(stage==1 && i==VARIANT101) good &= !pool101.exists(keys101[i]);
    else good &= pool101.exists(keys101[i])==1 && pool101.get(keys101[i])==wanted101[i];
  end
  good &= !pool101.exists("KEY101");
  cursor="start101";found=pool101.first(cursor);last_cursor=cursor;
  while(found && count<4) begin
    bit known;known=0;
    for(int i=0;i<2;i++) if(cursor==keys101[i]) begin seen[i]++;known=1;end
    iteration &= known;count++;last_cursor=cursor;found=pool101.next(cursor);
  end
  for(int i=0;i<2;i++) iteration &= seen[i]==((stage==1 && i==VARIANT101)?0:1);
  iteration &= found==0 && count==active && cursor==last_cursor;
  $display("UT: case101 pool %0d stage %0d keys %0d count %0d iterator %0d peer %0d",
    VARIANT101,stage,good,pool101.num(),iteration,
    peer101.num()==2 && peer101.get(keys101[0])==13 && peer101.get(keys101[1])==17);
endfunction
initial begin
  pool101=new("pool101");peer101=new("peer101");keys101[0]="key101";keys101[1]="Key101";
  wanted101[0]=31;wanted101[1]=79;
  for(int j=0;j<2;j++) begin
    automatic int i=VARIANT101==0?j:1-j;
    pool101.add(keys101[i],wanted101[i]);peer101.add(keys101[i],i==0?13:17);
  end
  show_pool101(0,2);pool101.delete(keys101[VARIANT101]);show_pool101(1,1);
  wanted101[VARIANT101]=43;pool101.add(keys101[VARIANT101],wanted101[VARIANT101]);
  show_pool101(2,2);wanted101[1-VARIANT101]=97;
  pool101.add(keys101[1-VARIANT101],wanted101[1-VARIANT101]);show_pool101(3,2);$finish;
end
