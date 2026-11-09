// Original hierarchy. Enumeration accepts any order but checks multiplicity.
class node101 extends uvm_component;
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
endclass
node101 root101,children101[3],leaves101[2];
string child_names101[3];
function automatic void show_component101(int stage,int count);
  uvm_component q[$];
  int seen[3],iter_seen[3],found,visits;
  string cursor,last_cursor;
  bit members,iteration,lookups;
  seen='{default:0};
  iter_seen='{default:0};
  members=1;
  iteration=1;
  visits=0;
  q.push_back(leaves101[0]);
  root101.get_children(q);
  for(int j=1;j<q.size();j++) begin
    bit known;
    known=0;
    for(int i=0;i<count;i++) if(q[j]==children101[i]) begin
      seen[i]++;
      known=1;
    end
    members &= known;
  end
  for(int i=0;i<count;i++) members &= seen[i]==1;
  members &= q.size()==count+1 && q[0]==leaves101[0];
  cursor="start101";
  found=root101.get_first_child(cursor);
  last_cursor=cursor;
  while(found && visits<5) begin
    bit known;
    known=0;
    for(int i=0;i<count;i++) if(root101.get_child(cursor)==children101[i]) begin
      iter_seen[i]++;
      known=1;
    end
    iteration &= known;
    visits++;
    last_cursor=cursor;
    found=root101.get_next_child(cursor);
  end
  for(int i=0;i<count;i++) iteration &= iter_seen[i]==1;
  iteration &= visits==count && found==0 && cursor==last_cursor;
  lookups=root101.get_child("route101")==children101[0] &&
    root101.get_child("Route101")==children101[1] &&
    root101.lookup("route101.leaf101")==leaves101[0] &&
    root101.lookup("Route101.Leaf101")==leaves101[1];
  lookups &= root101.lookup("Route101.leaf101")==null;
  if(stage==0) lookups &= !root101.has_child("ROUTE101");
  else lookups &= root101.has_child("ROUTE101")==1 &&
    root101.get_child("ROUTE101")==children101[2];
  $display("UT: case101 component %0d stage %0d names %0d count %0d bag %0d iterator %0d",
    VARIANT101,stage,lookups,root101.get_num_children(),members,iteration);
endfunction
initial begin
  root101=new("owner101",null);
  child_names101[0]="route101";
  child_names101[1]="Route101";
  child_names101[2]="ROUTE101";
  for(int j=0;j<2;j++) begin
    automatic int i=VARIANT101==0?j:1-j;
    children101[i]=new(child_names101[i],root101);
    leaves101[i]=new(i==0?"leaf101":"Leaf101",children101[i]);
  end
  show_component101(0,2);
  children101[2]=new(child_names101[2],root101);
  show_component101(1,3);
  show_component101(2,3);
  $finish;
end
