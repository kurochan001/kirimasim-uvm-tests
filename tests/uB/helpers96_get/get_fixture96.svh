class packet96 extends uvm_object;
  int value;
  function new(string name="packet96");
    super.new(name);
  endfunction
endclass
class owner96 extends uvm_component;
  packet96 shared_values[$],plain_values[$];
  int shared_calls=0,plain_calls=0;
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
  function bit try_get_shared96(output packet96 value);
    shared_calls++;
    if(shared_values.size()==0) return 0;
    value=shared_values.pop_front();
    return 1;
  endfunction
  function bit can_get_shared96();
    return shared_values.size()>0;
  endfunction
  function bit try_getplain96(output packet96 value);
    plain_calls++;
    if(plain_values.size()==0) return 0;
    value=plain_values.pop_front();
    return 1;
  endfunction
  function bit can_getplain96();
    return plain_values.size()>0;
  endfunction
endclass
class t extends uvm_test;
  `uvm_component_utils(t)
  owner96 a,b;
  decl_a96::uvm_nonblocking_get_imp_shared96#(packet96,owner96) a_shared;
  decl_a96::uvm_nonblocking_get_impplain96#(packet96,owner96) a_plain;
  decl_b96::uvm_nonblocking_get_imp_shared96#(packet96,owner96) b_shared;
  decl_b96::uvm_nonblocking_get_impplain96#(packet96,owner96) b_plain;
  uvm_nonblocking_get_port#(packet96) pa_shared,pa_plain,pb_shared,pb_plain;
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(VARIANT96==0) begin
      a=new("owner_a96",this);
      b=new("owner_b96",this);
    end
    else begin
      b=new("owner_b96",this);
      a=new("owner_a96",this);
    end
    a_shared=new("shared96",a);
    a_plain=new("plain96",a);
    b_shared=new("shared96",b);
    b_plain=new("plain96",b);
    pa_shared=new("pa_shared",this);
    pa_plain=new("pa_plain",this);
    pb_shared=new("pb_shared",this);
    pb_plain=new("pb_plain",this);
  endfunction
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    pa_shared.connect(a_shared);
    pa_plain.connect(a_plain);
    pb_shared.connect(b_shared);
    pb_plain.connect(b_plain);
  endfunction
  virtual task run_phase(uvm_phase phase);
    uvm_tlm_if_base#(packet96,packet96) a_view,b_view;
    decl_b96::uvm_nonblocking_get_imp_shared96#(packet96,owner96) cross_package;
    decl_a96::uvm_nonblocking_get_impplain96#(packet96,owner96) cross_suffix;
    packet96 p0,p1,p2,p3,p4,r0,r1,r2,r3,r4,failed_output;
    int salt;
    bit ns_ok,ready_ok,ok0,ok1,ok2,ok3,ok4,rejected,handles_ok,values_ok,package_rejected,suffix_rejected;
    phase.raise_objection(this);
    salt=VARIANT96==0?0:100;
    p0=new("p0");
    p1=new("p1");
    p2=new("p2");
    p3=new("p3");
    p4=new("p4");
    p0.value=salt+19;
    p1.value=salt+31;
    p2.value=salt+47;
    p3.value=salt+61;
    p4.value=salt+79;
    a.shared_values.push_back(p0);
    a.shared_values.push_back(p1);
    b.shared_values.push_back(p2);
    b.plain_values.push_back(p3);
    a_view=VARIANT96==0?pa_shared.get_if():pa_shared.get_if(0);
    b_view=VARIANT96==0?pb_shared.get_if():pb_shared.get_if(0);
    package_rejected=!$cast(cross_package,a_view);
    suffix_rejected=!$cast(cross_suffix,a_view);
    ns_ok=package_rejected && suffix_rejected;
    $display("UT: package_imp96 get %0d distinct_types %0d selected_views %0d parents %0d",VARIANT96,
      ns_ok,a_view==a_shared && b_view==b_shared,
      a_shared.get_parent()==a && a_plain.get_parent()==a && b_shared.get_parent()==b && b_plain.get_parent()==b);
    $display("UT: package_imp96 get %0d package_cast_rejected %0d suffix_cast_rejected %0d",VARIANT96,package_rejected,suffix_rejected);
    ready_ok=a_view.can_get() && !pa_plain.can_get() && b_view.can_get() && pb_plain.can_get();
    rejected=!pa_plain.try_get(failed_output);
    if(VARIANT96==0) begin
      ok0=a_view.try_get(r0);
      ok3=pb_plain.try_get(r3);
      ok2=b_view.try_get(r2);
    end
    else begin
      ok2=b_view.try_get(r2);
      ok3=pb_plain.try_get(r3);
      ok0=a_view.try_get(r0);
    end
    a.plain_values.push_back(p4);
    ok4=pa_plain.try_get(r4);
    ok1=a_view.try_get(r1);
    handles_ok=ok0 && ok1 && ok2 && ok3 && ok4 && r0==p0 && r1==p1 && r2==p2 && r3==p3 && r4==p4;
    values_ok=0;
    if(handles_ok) values_ok=r0.value==salt+19 && r1.value==salt+31 && r2.value==salt+47 && r3.value==salt+61 && r4.value==salt+79;
    $display("UT: package_imp96 get %0d ready %0d rejection %0d handles %0d values %0d",VARIANT96,ready_ok,rejected,handles_ok,values_ok);
    $display("UT: package_imp96 get %0d exhausted %0d routed_calls %0d",VARIANT96,
      !a_view.can_get() && !pa_plain.can_get() && !b_view.can_get() && !pb_plain.can_get(),
      a.shared_calls==2 && a.plain_calls==2 && b.shared_calls==1 && b.plain_calls==1);
    phase.drop_objection(this);
  endtask
endclass
initial run_test("t");
initial begin
  #100;
  $fatal(1,"package_imp96 get watchdog");
end
