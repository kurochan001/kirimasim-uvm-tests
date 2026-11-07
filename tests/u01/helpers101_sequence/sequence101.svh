// Inactive sequence metadata only; cached depth and actual traffic are separate.
class seq101 extends uvm_sequence#(uvm_sequence_item);
  function new(string name);super.new(name);endfunction
  virtual task body();endtask
endclass
seq101 roots101[2],middles101[2],tips101[2];
string root_names101[2],middle_names101[2],tip_names101[2];
int parent_index101[2],saved_ids101[2];
function automatic void show_sequence101(int stage);
  bit good,identities;good=1;identities=1;
  for(int i=0;i<2;i++) begin
    if(parent_index101[i]<0) begin
      good &= tips101[i].get_sequence_path()==tip_names101[i];
      good &= tips101[i].get_root_sequence()==tips101[i];
      good &= tips101[i].get_root_sequence_name()==tip_names101[i];
    end else begin
      good &= tips101[i].get_sequence_path()=={root_names101[parent_index101[i]],".",
        middle_names101[parent_index101[i]],".",tip_names101[i]};
      good &= tips101[i].get_parent_sequence()==middles101[parent_index101[i]];
      good &= tips101[i].get_root_sequence()==roots101[parent_index101[i]];
      good &= tips101[i].get_root_sequence_name()==root_names101[parent_index101[i]];
    end
    identities &= tips101[i].get_name()==tip_names101[i] &&
      tips101[i].get_inst_id()==saved_ids101[i];
  end
  $display("UT: case101 sequence %0d stage %0d names_paths %0d identities %0d",
    VARIANT101,stage,good,identities);
endfunction
initial begin
  root_names101[0]="stream101";root_names101[1]="Stream101";
  middle_names101[0]="lane101";middle_names101[1]="Lane101";
  tip_names101[0]="unit101";tip_names101[1]="Unit101";
  for(int j=0;j<2;j++) begin
    automatic int i=VARIANT101==0?j:1-j;
    roots101[i]=new(root_names101[i]);middles101[i]=new(middle_names101[i]);
    tips101[i]=new(tip_names101[i]);middles101[i].set_parent_sequence(roots101[i]);
    tips101[i].set_parent_sequence(middles101[i]);parent_index101[i]=i;
    saved_ids101[i]=tips101[i].get_inst_id();
  end
  show_sequence101(0);parent_index101[VARIANT101]=1-VARIANT101;
  tips101[VARIANT101].set_parent_sequence(middles101[1-VARIANT101]);show_sequence101(1);
  root_names101[1-VARIANT101]="STREAM101";tip_names101[VARIANT101]="UNIT101";
  roots101[1-VARIANT101].set_name(root_names101[1-VARIANT101]);
  tips101[VARIANT101].set_name(tip_names101[VARIANT101]);show_sequence101(2);
  parent_index101[VARIANT101]=-1;tips101[VARIANT101].set_parent_sequence(null);
  show_sequence101(3);
  // Qualified root-self reading from14.1.2.9/.12/.13 and14.2.3.1.
  // Separate flags diagnose this reading without attributing a case-folding bug.
  $display("UT: case101 sequence %0d detached path %0d parent_null %0d root_self %0d root_name %0d",
    VARIANT101,tips101[VARIANT101].get_sequence_path()==tip_names101[VARIANT101],
    tips101[VARIANT101].get_parent_sequence()==null,
    tips101[VARIANT101].get_root_sequence()==tips101[VARIANT101],
    tips101[VARIANT101].get_root_sequence_name()==tip_names101[VARIANT101]);
  $finish;
end
