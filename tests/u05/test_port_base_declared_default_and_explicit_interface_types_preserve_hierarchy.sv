/*
:name: test_port_base_declared_default_and_explicit_interface_types_preserve_hierarchy
:description: Base ports use the declared default interface, explicit inheritance and selected generic names
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.5.1 5.5 5.5.2.1 5.5.2.2 5.5.2.3 5.5.2.4 5.5.2.5 5.5.2.6 5.5.2.7 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_port_base_declared_default_and_explicit_interface_types_preserve_hierarchy.expected
*/
module test_port_base_declared_default_and_explicit_interface_types_preserve_hierarchy;
  import uvm_pkg::*;
  class owner extends uvm_component;
    function new(); super.new("owner61",null); endfunction
  endclass
  class default_port extends uvm_port_base#();
    function new(string name,uvm_component parent,uvm_port_type_e kind);
      super.new(name,parent,kind);
    endfunction
    virtual function void get_connected_to(ref uvm_port_base#() list[string]);
      list.delete();
    endfunction
    virtual function void get_provided_to(ref uvm_port_base#() list[string]);
      list.delete();
    endfunction
  endclass
  class interface_type extends uvm_void;
    int marker=61;
  endclass
  class explicit_port extends uvm_port_base#(interface_type);
    function new(string name,uvm_component parent);
      super.new(name,parent,UVM_PORT);
    endfunction
    virtual function void get_connected_to(
      ref uvm_port_base#(interface_type) list[string]);
      list.delete();
    endfunction
    virtual function void get_provided_to(
      ref uvm_port_base#(interface_type) list[string]);
      list.delete();
    endfunction
  endclass
  initial begin
    owner parent;
    default_port port_value,export_value,implementation_value;
    explicit_port explicit_value;
    uvm_port_base#(uvm_void) exact_default;
    interface_type inherited_view;
    parent=new(); port_value=new("port61",parent,UVM_PORT);
    export_value=new("export61",parent,UVM_EXPORT);
    implementation_value=new("imp61",parent,UVM_IMPLEMENTATION);
    explicit_value=new("explicit61",parent);
    exact_default=port_value; inherited_view=explicit_value;
    $display("UT: port_base default_type %0d explicit_inheritance %0d names %0d parent %0d",
      exact_default==port_value,inherited_view.marker==61,
      port_value.get_name()=="port61" && port_value.get_full_name()=="owner61.port61",
      port_value.get_parent()==parent);
    $display("DETAIL: generic types <%s> <%s> <%s>",port_value.get_type_name(),
      export_value.get_type_name(),implementation_value.get_type_name());
    $display("UT: port_defaults min_zero %0d max_one %0d generic_names %0d",
      port_value.min_size()==0,port_value.max_size()==1,
      port_value.get_type_name()=="uvm_port" && export_value.get_type_name()=="uvm_export" &&
      implementation_value.get_type_name()=="uvm_implementation");
    $finish;
  end
  initial begin #100; $fatal(1,"base hook fixture watchdog expired"); end
endmodule
