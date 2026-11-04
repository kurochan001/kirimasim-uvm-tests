/*
:name: test_resource_base_legal_extensions_preserve_default_explicit_names_virtual_type_handles
:description: An original concrete resource-base extension implements the pure type hook and preserves constructor naming
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.2.3.2.1 C.2.3.2.2 C.2.3.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_resource_base_legal_extensions_preserve_default_explicit_names_virtual_type_handles.expected
*/
// Use the prose's unnamed default; the printed prototype has a stray comma.
module
  test_resource_base_legal_extensions_preserve_default_explicit_names_virtual_type_handles;
  import uvm_pkg::*;
  class resource_type extends uvm_resource_base;
    static resource_type token;
    function new(string name); super.new(name); endfunction
    virtual function uvm_resource_base get_type_handle();
      if (token==null) token=new("token58");
      return token;
    endfunction
  endclass
  class default_resource extends uvm_resource_base;
    static default_resource token;
    function new(); super.new(); endfunction
    virtual function uvm_resource_base get_type_handle();
      if (token==null) token=new();
      return token;
    endfunction
  endclass
  initial begin
    automatic default_resource omitted=new();
    automatic resource_type named=new("named58");
    uvm_resource_base base_view; uvm_object object_view;
    base_view=omitted; object_view=omitted;
    $display("UT: base_constructor unnamed %0d named %0d object %0d virtual_handle %0d",
      omitted.get_name()=="",named.get_name()=="named58",object_view==omitted,
      base_view.get_type_handle()!=null && base_view.get_type_handle()==omitted.get_type_handle());
    $finish;
  end
endmodule
