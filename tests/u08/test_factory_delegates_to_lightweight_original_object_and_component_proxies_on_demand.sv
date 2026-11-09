/*
:name: test_factory_delegates_to_lightweight_original_object_and_component_proxies_on_demand
:description: factory delegates to lightweight original object and component proxies on demand
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.3.2 8.2.1 8.3.1.3 8.3.1.5 8.3.2.2.1 8.3.2.2.2 8.3.2.2.3 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_factory_delegates_to_lightweight_original_object_and_component_proxies_on_demand.expected
*/
// What it checks:
// 1. Lightweight registration does not construct the selected represented
//    object/component instances.
// 2. Factory object requests delegate to the selected wrapper.
// 3. Factory component requests delegate to the selected wrapper.
// 4. No-override object creation returns the represented object type.
// 5. No-override component creation returns the represented component type.
// 6. Created object/components retain the selected requested names.
// 7. Component creation forwards the selected parent handle.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 8.2.1
//    (UVM-FACTORY-AUDIT-REGISTRATION-WITHOUT-REPRESENTED-INSTANCES) gives rule
//    1 above. Setup: A fresh factory receives original object/component
//    wrappers; requests enter through both public by-type and by-name creation
//    APIs. Expected: Both represented constructor counters remain zero after
//    registration.
// 2. 1800.2-2020 8.3.2 (UVM-FACTORY-AUDIT-WRAPPER-OBJECT-DISPATCH) gives rule
//    2 above. Setup: A fresh factory receives original object/component
//    wrappers; requests enter through both public by-type and by-name creation
//    APIs. Expected: Two object requests call the object proxy twice and
//    create two objects.
// 3. 1800.2-2020 8.3.2 (UVM-FACTORY-AUDIT-WRAPPER-COMPONENT-DISPATCH) gives
//    rule 3 above. Setup: A fresh factory receives original object/component
//    wrappers; requests enter through both public by-type and by-name creation
//    APIs. Expected: Two component requests call the component proxy twice and
//    create two components.
// 4. 1800.2-2020 8.3.1.5 (UVM-FACTORY-AUDIT-CREATE-OBJECT-TYPE) gives rule 4
//    above. Setup: A fresh factory receives original object/component
//    wrappers; requests enter through both public by-type and by-name creation
//    APIs. Expected: The selected object casts to the original item subtype.
// 5. 1800.2-2020 8.3.1.5 (UVM-FACTORY-AUDIT-CREATE-COMPONENT-TYPE) gives rule
//    5 above. Setup: A fresh factory receives original object/component
//    wrappers; requests enter through both public by-type and by-name creation
//    APIs. Expected: The selected component casts to the original node
//    subtype.
// 6. 1800.2-2020 8.3.1.5 (UVM-FACTORY-AUDIT-CREATE-REQUESTED-NAMES) gives rule
//    6 above. Setup: A fresh factory receives original object/component
//    wrappers; requests enter through both public by-type and by-name creation
//    APIs. Expected: Both object names and both child names agree with the
//    original requests.
// 7. 1800.2-2020 8.3.1.5 (UVM-FACTORY-AUDIT-CREATE-COMPONENT-PARENTS) gives
//    rule 7 above. Setup: A fresh factory receives original object/component
//    wrappers; requests enter through both public by-type and by-name creation
//    APIs. Expected: Both created components retain the supplied parent.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_factory_delegates_to_lightweight_original_object_and_component_proxies_on_demand;
  import uvm_pkg::*;
  int object_made=0,component_made=0;
  class item extends uvm_object;
    function new(string name="");super.new(name);object_made++;endfunction
    virtual function string get_type_name();return "proxy_object55";endfunction
  endclass
  class node extends uvm_component;
    function new(string name,uvm_component parent);
      super.new(name,parent);component_made++;
    endfunction
    virtual function string get_type_name();return "proxy_component55";endfunction
  endclass
  class parent_type extends uvm_component;
    function new(string name);super.new(name,null);endfunction
  endclass
  class object_proxy extends uvm_object_wrapper;
    int calls=0;
    virtual function string get_type_name();return "proxy_object55";endfunction
    virtual function uvm_object create_object(string name="");
      item created;
      calls++;created=new(name);return created;
    endfunction
  endclass
  class component_proxy extends uvm_object_wrapper;
    int calls=0;
    virtual function string get_type_name();return "proxy_component55";endfunction
    virtual function uvm_component create_component(string name,uvm_component parent);
      node created;
      calls++;created=new(name,parent);return created;
    endfunction
  endclass
  initial begin
    automatic uvm_default_factory factory=new();
    automatic object_proxy objects=new();
    automatic component_proxy components=new();
    automatic parent_type parent=new("owner55");
    uvm_object a,b;
    uvm_component c,d;
    item item_view;
    node node_view;
    factory.register(objects);factory.register(components);
    $display("UT: proxy_registration object_made %0d component_made %0d",
      object_made,component_made);
    a=factory.create_object_by_type(objects,"ctx55","first55");
    b=factory.create_object_by_name("proxy_object55","ctx55","second55");
    c=factory.create_component_by_type(components,"ctx55","child_a55",parent);
    d=factory.create_component_by_name("proxy_component55","ctx55","child_b55",parent);
    $display("UT: proxy_dispatch objects %0d components %0d distinct %0d",
      objects.calls==2 && object_made==2,components.calls==2 && component_made==2,a!=b && c!=d);
    $display("UT: proxy_values object_type %0d component_type %0d names %0d parents %0d",
      $cast(item_view,a),$cast(node_view,c),
      a.get_name()=="first55" && b.get_name()=="second55" &&
      c.get_name()=="child_a55" && d.get_name()=="child_b55",
      c.get_parent()==parent && d.get_parent()==parent);
    $finish;
  end
endmodule
