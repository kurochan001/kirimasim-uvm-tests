class owner96 extends uvm_component;
  int shared_values[$],plain_values[$];
  function new(string name,uvm_component parent);super.new(name,parent);endfunction
  task put_shared96(int value);#1;shared_values.push_back(value);endtask
  task putplain96(int value);#1;plain_values.push_back(value);endtask
endclass
class t extends uvm_test;
  `uvm_component_utils(t)
  owner96 a,b;
  decl_a96::uvm_blocking_put_imp_shared96#(int,owner96) a_shared;
  decl_a96::uvm_blocking_put_impplain96#(int,owner96) a_plain;
  decl_b96::uvm_blocking_put_imp_shared96#(int,owner96) b_shared;
  decl_b96::uvm_blocking_put_impplain96#(int,owner96) b_plain;
  uvm_blocking_put_port#(int) pa_shared,pa_plain,pb_shared,pb_plain;
  function new(string name,uvm_component parent);super.new(name,parent);endfunction
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(VARIANT96==0) begin a=new("owner_a96",this);b=new("owner_b96",this);end
    else begin b=new("owner_b96",this);a=new("owner_a96",this);end
    a_shared=new("shared96",a);a_plain=new("plain96",a);
    b_shared=new("shared96",b);b_plain=new("plain96",b);
    pa_shared=new("pa_shared",this);pa_plain=new("pa_plain",this);
    pb_shared=new("pb_shared",this);pb_plain=new("pb_plain",this);
  endfunction
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    pa_shared.connect(a_shared);pa_plain.connect(a_plain);
    pb_shared.connect(b_shared);pb_plain.connect(b_plain);
  endfunction
  virtual task run_phase(uvm_phase phase);
    uvm_tlm_if_base#(int,int) a_view,b_view;
    decl_b96::uvm_blocking_put_imp_shared96#(int,owner96) cross_package;
    decl_a96::uvm_blocking_put_impplain96#(int,owner96) cross_suffix;
    int salt;
    bit ns_ok,parents_ok,route_ok,counts_ok,package_rejected,suffix_rejected;
    phase.raise_objection(this);salt=VARIANT96==0?0:100;
    a_view=VARIANT96==0?pa_shared.get_if():pa_shared.get_if(0);
    b_view=VARIANT96==0?pb_shared.get_if():pb_shared.get_if(0);
    package_rejected=!$cast(cross_package,a_view);
    suffix_rejected=!$cast(cross_suffix,a_view);
    ns_ok=package_rejected && suffix_rejected;
    parents_ok=a_shared.get_parent()==a && a_plain.get_parent()==a && b_shared.get_parent()==b && b_plain.get_parent()==b;
    $display("UT: package_imp96 put %0d distinct_types %0d selected_views %0d parents %0d",VARIANT96,
      ns_ok,a_view==a_shared && b_view==b_shared,parents_ok);
    $display("UT: package_imp96 put %0d package_cast_rejected %0d suffix_cast_rejected %0d",VARIANT96,package_rejected,suffix_rejected);
    if(VARIANT96==0) begin
      a_view.put(salt+13);pb_plain.put(salt+29);pa_plain.put(salt+41);b_view.put(salt+57);
    end else begin
      b_view.put(salt+57);pa_plain.put(salt+41);pb_plain.put(salt+29);a_view.put(salt+13);
    end
    a_view.put(salt+71);
    counts_ok=a.shared_values.size()==2 && a.plain_values.size()==1 && b.shared_values.size()==1 && b.plain_values.size()==1;
    route_ok=counts_ok;
    if(counts_ok) route_ok=a.shared_values[0]==salt+13 && a.shared_values[1]==salt+71 && a.plain_values[0]==salt+41 && b.shared_values[0]==salt+57 && b.plain_values[0]==salt+29;
    $display("UT: package_imp96 put %0d routed %0d counts %0d",VARIANT96,route_ok,counts_ok);
    pb_plain.put(salt+83);
    $display("UT: package_imp96 put %0d later_target %0d others_retained %0d",VARIANT96,
      b.plain_values.size()==2 && b.plain_values[1]==salt+83,
      a.shared_values.size()==2 && a.plain_values.size()==1 && b.shared_values.size()==1);
    phase.drop_objection(this);
  endtask
endclass
initial run_test("t");
initial begin #100;$fatal(1,"package_imp96 put watchdog");end
