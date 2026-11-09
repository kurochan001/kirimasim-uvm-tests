/*
:name: test_object_set_local_virtual_extension_selects_named_resource_properties
:description: The designer-defined configuration hook chooses accessible fields by the resource name
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.12 C.2.5.4.1 5.3.4.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_set_local_virtual_extension_selects_named_resource_properties.expected
*/
// What it checks:
// A designer-defined set_local hook can select accessible properties by
// resource name.
//
// How the expected output follows from the standard:
// 1800.2-2020 5.3.12 (UVM-BASE-AUDIT-CONFIGURATION-HOOK) gives the rule above.
// Setup: The original override accepts only chosen61 and reads the exact typed
// resource through a base-view call. Expected: The chosen value changes, an
// unselected property/peer is preserved and the original hook sees the exact
// resource handle.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_object_set_local_virtual_extension_selects_named_resource_properties;
  import uvm_pkg::*;
  class original_object extends uvm_object;
    function new(string name=""); super.new(name); endfunction
    virtual function string get_type_name(); return "original_object61"; endfunction
    virtual function uvm_object create(string name="");
      original_object result;
      result=new(name); return result;
    endfunction
  endclass
  class configurable_object extends original_object;
    int chosen=0,other=7,calls=0;
    uvm_resource_base last_resource;
    function new(); super.new("configurable61"); endfunction
    virtual function void set_local(uvm_resource_base rsrc);
      uvm_resource#(int) typed;
      calls++; last_resource=rsrc;
      if (rsrc.get_name()=="chosen61" && $cast(typed,rsrc))
        chosen=typed.read();
    endfunction
    virtual function string get_type_name(); return "configurable_object61"; endfunction
    virtual function uvm_object create(string name="");
      configurable_object result;
      result=new(); result.set_name(name); return result;
    endfunction
  endclass
  initial begin
    configurable_object value,peer;
    uvm_object view;
    uvm_resource#(int) selected,ignored;
    value=new(); peer=new(); view=value;
    selected=new("chosen61"); ignored=new("other61");
    selected.write(61); ignored.write(99);
    view.set_local(selected); view.set_local(ignored);
    $display("UT: set_local selected %0d other_unchanged %0d peer_unchanged %0d exact_resource %0d",
      value.chosen==61,value.other==7,peer.chosen==0,value.last_resource==ignored);
    $finish;
  end
  initial begin #100; $fatal(1,"base hook fixture watchdog expired"); end
endmodule
