// Low-level registration only: no utils macro or explicit factory registration.
class object_a94 extends uvm_object;
  int marker=19;
  `uvm_object_registry(object_a94,"lookup_amber94")
  function new(string name="a94");super.new(name);endfunction
endclass
class object_b94 extends uvm_object;
  int marker=47;
  `uvm_object_registry(object_b94,"lookup_blue94")
  function new(string name="b94");super.new(name);endfunction
endclass
class component_a94 extends uvm_component;
  int marker=23;
  `uvm_component_registry(component_a94,"lookup_cedar94")
  function new(string name,uvm_component parent);super.new(name,parent);endfunction
endclass
class component_b94 extends uvm_component;
  int marker=61;
  `uvm_component_registry(component_b94,"lookup_dune94")
  function new(string name,uvm_component parent);super.new(name,parent);endfunction
endclass
class parent94 extends uvm_component;
  function new(string name,uvm_component parent);super.new(name,parent);endfunction
endclass
initial begin
  uvm_factory factory;
  object_a94 object_witness_a,a1,a2;
  object_b94 object_witness_b,b;
  component_a94 component_witness_a,c1,c2;
  component_b94 component_witness_b,d;
  parent94 host,peer;
  uvm_object raw_a1,raw_a2,raw_b;
  uvm_component raw_c1,raw_c2,raw_d;
  factory=uvm_factory::get();
  if(COMPONENT94) begin
    host=new("host94",null);peer=new("peer94",null);
    if(VARIANT==0) begin component_witness_a=new("witness_a94",host);component_witness_b=new("witness_b94",host);end
    else begin component_witness_b=new("witness_b94",host);component_witness_a=new("witness_a94",host);end
    if(VARIANT==0) begin raw_c1=factory.create_component_by_name("lookup_cedar94","", "made_a94",host);raw_d=factory.create_component_by_name("lookup_dune94","", "made_b94",peer);end
    else begin raw_d=factory.create_component_by_name("lookup_dune94","", "made_b94",peer);raw_c1=factory.create_component_by_name("lookup_cedar94","", "made_a94",host);end
    raw_c2=factory.create_component_by_name("lookup_cedar94","", "made_again94",peer);
    if(!$cast(c1,raw_c1) || !$cast(c2,raw_c2) || !$cast(d,raw_d) || c1==null || c2==null || d==null) $fatal(1,"registry94 component lookup");
    $display("UT: registry94 component %0d aliases %0d values %0d",VARIANT,
      factory.is_type_name_registered("lookup_cedar94") && factory.is_type_name_registered("lookup_dune94"),
      c1.marker==23 && c2.marker==23 && d.marker==61);
    $display("UT: registry94 component %0d names %0d parents %0d fresh %0d",VARIANT,
      c1.get_name()=="made_a94" && c2.get_name()=="made_again94" && d.get_name()=="made_b94",
      c1.get_parent()==host && c2.get_parent()==peer && d.get_parent()==peer,
      c1!=c2 && c1!=component_witness_a && d!=component_witness_b);
  end else begin
    if(VARIANT==0) begin object_witness_a=new();object_witness_b=new();end
    else begin object_witness_b=new();object_witness_a=new();end
    if(VARIANT==0) begin raw_a1=factory.create_object_by_name("lookup_amber94","", "made_a94");raw_b=factory.create_object_by_name("lookup_blue94","", "made_b94");end
    else begin raw_b=factory.create_object_by_name("lookup_blue94","", "made_b94");raw_a1=factory.create_object_by_name("lookup_amber94","", "made_a94");end
    raw_a2=factory.create_object_by_name("lookup_amber94","", "made_again94");
    if(!$cast(a1,raw_a1) || !$cast(a2,raw_a2) || !$cast(b,raw_b) || a1==null || a2==null || b==null) $fatal(1,"registry94 object lookup");
    $display("UT: registry94 object %0d aliases %0d values %0d",VARIANT,
      factory.is_type_name_registered("lookup_amber94") && factory.is_type_name_registered("lookup_blue94"),
      a1.marker==19 && a2.marker==19 && b.marker==47);
    $display("UT: registry94 object %0d names %0d fresh %0d",VARIANT,
      a1.get_name()=="made_a94" && a2.get_name()=="made_again94" && b.get_name()=="made_b94",
      a1!=a2 && a1!=object_witness_a && b!=object_witness_b);
    a1.marker=83;
    $display("UT: registry94 object %0d independent %0d",VARIANT,a2.marker==19 && object_witness_a.marker==19 && b.marker==47);
  end
  $finish;
end
