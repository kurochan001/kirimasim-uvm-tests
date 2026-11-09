// Original bridge/leaf types add no name, ID or tested API override.
class transaction_bridge99 extends uvm_transaction;
  function new(string name);
    super.new(name);
  endfunction
endclass
class transaction_leaf99 extends transaction_bridge99;
  function new(string name);
    super.new(name);
  endfunction
endclass
transaction_leaf99 transactions99[2];
class callback_bridge99 extends uvm_callback;
  function new(string name);
    super.new(name);
  endfunction
endclass
class callback_leaf99 extends callback_bridge99;
  function new(string name);
    super.new(name);
  endfunction
endclass
callback_leaf99 callbacks99[2];
class item_bridge99 extends uvm_sequence_item;
  function new(string name);
    super.new(name);
  endfunction
endclass
class item_leaf99 extends item_bridge99;
  function new(string name);
    super.new(name);
  endfunction
endclass
item_leaf99 items99[2];
class component_bridge99 extends uvm_component;
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
endclass
class component_leaf99 extends component_bridge99;
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
endclass
component_leaf99 components99[2];
class register_bridge99 extends uvm_reg;
  function new(string name);
    super.new(name,8,UVM_NO_COVERAGE);
  endfunction
endclass
class register_leaf99 extends register_bridge99;
  function new(string name);
    super.new(name);
  endfunction
endclass
register_leaf99 registers99[2];
class memory_bridge99 extends uvm_mem;
  function new(string name);
    super.new(name,16,8,"RW",UVM_NO_COVERAGE);
  endfunction
endclass
class memory_leaf99 extends memory_bridge99;
  function new(string name);
    super.new(name);
  endfunction
endclass
memory_leaf99 memorys99[2];
class block99 extends uvm_reg_block;
  function new();
    super.new("owner99",UVM_NO_COVERAGE);
  endfunction
endclass
class field99 extends uvm_reg_field;
  function new();
    super.new("payload99");
  endfunction
endclass
uvm_object views99[2];
component_leaf99 parent99,twig99;
block99 owner99;
uvm_reg_map map99;
field99 fields99[2];
string expected_names99[2],prefix99;
int saved_ids99[2],expected_tx99[2];
bit expected_enable99[2],old_mode_ok99;
int selected99,peer99;
function automatic string leaf_name99(int i);
  case(FAMILY99)
    0:return transactions99[i].get_name();
    1:return callbacks99[i].get_name();
    2:return items99[i].get_name();
    3:return components99[i].get_name();
    4:return registers99[i].get_name();
    5:return memorys99[i].get_name();
  endcase
  return "";
endfunction
function automatic int leaf_id99(int i);
  case(FAMILY99)
    0:return transactions99[i].get_inst_id();
    1:return callbacks99[i].get_inst_id();
    2:return items99[i].get_inst_id();
    3:return components99[i].get_inst_id();
    4:return registers99[i].get_inst_id();
    5:return memorys99[i].get_inst_id();
  endcase
  return 0;
endfunction
function automatic string bridge_name99(int i);
  transaction_bridge99 transaction_view;
  callback_bridge99 callback_view;
  item_bridge99 item_view;
  component_bridge99 component_view;
  register_bridge99 register_view;
  memory_bridge99 memory_view;
  case(FAMILY99)
    0:begin
      transaction_view=transactions99[i];
      return transaction_view.get_name();
    end
    1:begin
      callback_view=callbacks99[i];
      return callback_view.get_name();
    end
    2:begin
      item_view=items99[i];
      return item_view.get_name();
    end
    3:begin
      component_view=components99[i];
      return component_view.get_name();
    end
    4:begin
      register_view=registers99[i];
      return register_view.get_name();
    end
    5:begin
      memory_view=memorys99[i];
      return memory_view.get_name();
    end
  endcase
  return "";
endfunction
function automatic void leaf_set99(int i,string name);
  case(FAMILY99)
    0:transactions99[i].set_name(name);
    1:callbacks99[i].set_name(name);
    2:items99[i].set_name(name);
    3:components99[i].set_name(name);
    4:registers99[i].set_name(name);
    5:memorys99[i].set_name(name);
  endcase
endfunction
function automatic void bridge_set99(int i,string name);
  transaction_bridge99 transaction_view;
  callback_bridge99 callback_view;
  item_bridge99 item_view;
  component_bridge99 component_view;
  register_bridge99 register_view;
  memory_bridge99 memory_view;
  case(FAMILY99)
    0:begin
      transaction_view=transactions99[i];
      transaction_view.set_name(name);
    end
    1:begin
      callback_view=callbacks99[i];
      callback_view.set_name(name);
    end
    2:begin
      item_view=items99[i];
      item_view.set_name(name);
    end
    3:begin
      component_view=components99[i];
      component_view.set_name(name);
    end
    4:begin
      register_view=registers99[i];
      register_view.set_name(name);
    end
    5:begin
      memory_view=memorys99[i];
      memory_view.set_name(name);
    end
  endcase
endfunction
function automatic uvm_transaction transaction_view99(int i);
  if(FAMILY99==0) return transactions99[i];
  return items99[i];
endfunction
function automatic void auxiliary99(int i,int step);
  uvm_transaction tx;
  int old_value;
  if(FAMILY99==0 || FAMILY99==2) begin
    expected_tx99[i]=step*64+31+i;
    tx=transaction_view99(i);
    tx.set_transaction_id(expected_tx99[i]);
  end
  if(FAMILY99==1) begin
    old_value=callbacks99[i].callback_mode(step==3?1:0);
    old_mode_ok99 &= old_value==expected_enable99[i];
    expected_enable99[i]=(step==3);
  end
endfunction
function automatic void show99(string stage);
  bit names_ok,ids_ok,tx_ok,enabled_ok,full_ok,parents_ok,shape_ok;
  uvm_transaction tx;
  names_ok=1;
  ids_ok=1;
  tx_ok=1;
  enabled_ok=1;
  for(int i=0;i<2;i++) begin
    names_ok &= views99[i].get_name()==expected_names99[i];
    names_ok &= leaf_name99(i)==expected_names99[i];
    names_ok &= bridge_name99(i)==expected_names99[i];
    ids_ok &= views99[i].get_inst_id()==saved_ids99[i];
    ids_ok &= leaf_id99(i)==saved_ids99[i];
    if(FAMILY99==0 || FAMILY99==2) begin
      tx=transaction_view99(i);
      tx_ok &= tx.get_transaction_id()==expected_tx99[i];
    end
    if(FAMILY99==1) enabled_ok &= callbacks99[i].is_enabled()==expected_enable99[i];
  end
  $display("UT: inherit99 %s %0d %s names %0d ids %0d distinct %0d",
    FAMILY_NAME99,VARIANT99,stage,names_ok,ids_ok,
    views99[0]!=views99[1] && saved_ids99[0]!=saved_ids99[1]);
  if(FAMILY99==0 || FAMILY99==2)
    $display("UT: inherit99 %s %0d %s transaction_values %0d",
      FAMILY_NAME99,VARIANT99,stage,tx_ok);
  if(FAMILY99==1)
    $display("UT: inherit99 callback %0d %s enabled %0d old_mode %0d",
      VARIANT99,stage,enabled_ok,old_mode_ok99);
  if(FAMILY99==3) begin
    full_ok=parent99.get_full_name()==prefix99;
    full_ok &= views99[0].get_full_name()=={prefix99,".",expected_names99[0]};
    full_ok &= views99[1].get_full_name()=={prefix99,".",expected_names99[1]};
    full_ok &= twig99.get_full_name()=={prefix99,".",expected_names99[0],".twig99"};
    parents_ok=components99[0].get_parent()==parent99 &&
      components99[1].get_parent()==parent99 && twig99.get_parent()==components99[0];
    $display("UT: inherit99 component %0d %s full_names %0d parents %0d",
      VARIANT99,stage,full_ok,parents_ok);
  end
  if(FAMILY99==4) begin
    shape_ok=registers99[0].get_parent()==owner99 && registers99[1].get_parent()==owner99;
    shape_ok &= registers99[0].get_n_bits()==8 && registers99[1].get_n_bits()==8;
    $display("UT: inherit99 register %0d %s model_shape %0d",VARIANT99,stage,shape_ok);
  end
  if(FAMILY99==5) begin
    shape_ok=memorys99[0].get_parent()==owner99 && memorys99[1].get_parent()==owner99;
    shape_ok &= memorys99[0].get_size()==16 && memorys99[1].get_size()==16;
    shape_ok &= memorys99[0].get_n_bits()==8 && memorys99[1].get_n_bits()==8;
    $display("UT: inherit99 memory %0d %s model_shape %0d",VARIANT99,stage,shape_ok);
  end
endfunction
initial begin
  uvm_transaction tx;
  selected99=VARIANT99;
  peer99=1-VARIANT99;
  old_mode_ok99=1;
  if(FAMILY99==3) parent99=new("atlas99",null);
  if(FAMILY99>=4) begin
    owner99=new();
    owner99.configure();
    map99=owner99.create_map("model_map99",0,1,UVM_LITTLE_ENDIAN);
  end
  for(int j=0;j<2;j++) begin
    automatic int i=VARIANT99==0?j:1-j;
    expected_names99[i]=i==0?"left99":"right99";
    case(FAMILY99)
      0:begin
        transactions99[i]=new(expected_names99[i]);
        views99[i]=transactions99[i];
      end
      1:begin
        callbacks99[i]=new(expected_names99[i]);
        views99[i]=callbacks99[i];
        void'(callbacks99[i].callback_mode(1));
        expected_enable99[i]=1;
      end
      2:begin
        items99[i]=new(expected_names99[i]);
        views99[i]=items99[i];
      end
      3:begin
        components99[i]=new(expected_names99[i],parent99);
        views99[i]=components99[i];
      end
      4:begin
        registers99[i]=new(expected_names99[i]);
        registers99[i].configure(owner99);
        fields99[i]=new();
        fields99[i].configure(registers99[i],8,0,"RW",0,0,1,0,1);
        map99.add_reg(registers99[i],i*64,"RW");
        views99[i]=registers99[i];
      end
      5:begin
        memorys99[i]=new(expected_names99[i]);
        memorys99[i].configure(owner99);
        map99.add_mem(memorys99[i],i*64,"RW");
        views99[i]=memorys99[i];
      end
    endcase
    saved_ids99[i]=views99[i].get_inst_id();
    if(FAMILY99==0 || FAMILY99==2) begin
      expected_tx99[i]=31+i;
      tx=transaction_view99(i);
      tx.set_transaction_id(expected_tx99[i]);
    end
  end
  if(FAMILY99==3) begin
    twig99=new("twig99",components99[0]);
    prefix99=parent99.get_full_name();
  end
  show99("initial");
  expected_names99[selected99]=$sformatf("changed_%0d_99",selected99);
  if(VARIANT99==0) views99[selected99].set_name(expected_names99[selected99]);
  else leaf_set99(selected99,expected_names99[selected99]);
  auxiliary99(selected99,1);
  show99("selected");
  expected_names99[peer99]=$sformatf("changed_%0d_99",peer99);
  if(VARIANT99==0) leaf_set99(peer99,expected_names99[peer99]);
  else views99[peer99].set_name(expected_names99[peer99]);
  auxiliary99(peer99,2);
  show99("peer");
  expected_names99[selected99]=$sformatf("again_%0d_99",selected99);
  bridge_set99(selected99,expected_names99[selected99]);
  auxiliary99(selected99,3);
  show99("again");
  $finish;
end
