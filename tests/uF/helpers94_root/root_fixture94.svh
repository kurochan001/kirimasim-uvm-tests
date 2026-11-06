class node94 extends uvm_component;
  function new(string name,uvm_component parent);super.new(name,parent);endfunction
endclass
initial begin
  uvm_root root,recovered;
  uvm_component component_view;
  uvm_object object_view;
  node94 first,second,leaf,late_child;
  if(VARIANT==0) first=new("first94",null);
  root=uvm_root::get();
  if(VARIANT!=0) first=new("first94",null);
  second=new("second94",null);leaf=new("leaf94",VARIANT==0?first:second);
  component_view=root;object_view=component_view;
  if(!$cast(recovered,object_view) || recovered==null) $fatal(1,"root94 base-view cast");
  $display("UT: root94 %0d base_views %0d identity %0d",VARIANT,
    component_view==root && object_view==root,recovered==root && recovered==uvm_root::get());
  $display("UT: root94 %0d top_children %0d nested_parent %0d",VARIANT,
    first.get_parent()==root && second.get_parent()==root &&
    component_view.get_child("first94")==first && component_view.get_child("second94")==second,
    leaf.get_parent()==(VARIANT==0?first:second) && leaf.get_parent().get_parent()==root);
  late_child=new("late94",null);
  $display("UT: root94 %0d live_base_view %0d retained_branches %0d",VARIANT,
    component_view.get_child("late94")==late_child && late_child.get_parent()==root,
    VARIANT==0 ? (first.get_child("leaf94")==leaf && second.get_child("leaf94")==null) :
      (first.get_child("leaf94")==null && second.get_child("leaf94")==leaf));
  $finish;
end
