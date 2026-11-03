/*
:name: test_sequencer_constructors_preserve_names_parents_and_selected_component_bases
:description: sequencer constructors preserve names parents and selected component bases
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.3.2.1 15.3.1 15.5.2.1 15.5.1 15.6.3.2 15.6.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequencer_constructors_preserve_names_parents_and_selected_component_bases.expected
*/
module test_sequencer_constructors_preserve_names_parents_and_selected_component_bases;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class request_item extends uvm_sequence_item;
    `uvm_object_utils(request_item)
    int value=45;
    function new(string name="request"); super.new(name); endfunction
  endclass
  class response_item extends uvm_sequence_item;
    `uvm_object_utils(response_item)
    int value=145;
    function new(string name="response"); super.new(name); endfunction
  endclass
  class owner extends uvm_component;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
  endclass
  class base_probe extends uvm_sequencer_base;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
  endclass
  initial begin
    automatic owner parent=new("owner",null);
    automatic base_probe base_value=new("base45",parent);
    automatic uvm_sequencer#(request_item,response_item) pull=new("pull45",parent);
    automatic uvm_push_sequencer#(request_item,response_item) push=new("push45",parent);
    automatic uvm_component views[3]='{base_value,pull,push};
    automatic uvm_sequencer_base sequencer_views[2]='{pull,push};
    $display("UT: sequencer_names base %0d pull %0d push %0d",
             base_value.get_name()=="base45",pull.get_name()=="pull45",push.get_name()=="push45");
    foreach (views[i])
      $display("UT: sequencer_parent %0d exact %0d",i,views[i].get_parent()==parent);
    $display("UT: sequencer_bases pull %0d push %0d",
             sequencer_views[0]==pull,sequencer_views[1]==push);
    $finish;
  end
endmodule
