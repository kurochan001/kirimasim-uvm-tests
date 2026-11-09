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
// What it checks:
// 1. The push sequencer constructor retains its configured component parent.
// 2. A legal concrete sequencer-base subtype retains the component base.
// 3. The sequencer-base constructor forwards its explicit instance name and
//    parent.
// 4. The pull sequencer constructor preserves its explicit name and parent.
// 5. The typed pull sequencer is usable through uvm_sequencer_base.
// 6. The typed push sequencer is usable through uvm_sequencer_base.
// 7. The push sequencer constructor retains its explicit instance name.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 15.6.3.2 (UVM-PUSH-SEQUENCER-CONSTRUCTOR-PARENT) gives rule 1
//    above. Setup: Construct the typed sequencer and driver under a test
//    component. Expected: Both hierarchy parent queries return the test
//    component.
// 2. 1800.2-2020 15.3.1 (UVM-SQR-AUDIT-BASE-COMPONENT-TYPE) gives rule 2
//    above. Setup: Use the selected original fixture, declared type arguments,
//    public endpoint/base views and linked stage observations. Requests
//    satisfy the grant precondition before send_request and response IDs are
//    copied from the actual request. Expected: A legal concrete sequencer-base
//    subtype retains the component base.
// 3. 1800.2-2020 15.3.2.1 (UVM-SQR-AUDIT-BASE-CONSTRUCTOR) gives rule 3 above.
//    Setup: Use the selected original fixture, declared type arguments, public
//    endpoint/base views and linked stage observations. Requests satisfy the
//    grant precondition before send_request and response IDs are copied from
//    the actual request. Expected: The sequencer-base constructor forwards its
//    explicit instance name and parent.
// 4. 1800.2-2020 15.5.2.1 (UVM-SQR-AUDIT-PULL-CONSTRUCTOR) gives rule 4 above.
//    Setup: Use the selected original fixture, declared type arguments, public
//    endpoint/base views and linked stage observations. Requests satisfy the
//    grant precondition before send_request and response IDs are copied from
//    the actual request. Expected: The pull sequencer constructor preserves
//    its explicit name and parent.
// 5. 1800.2-2020 15.5.1 (UVM-SQR-AUDIT-PULL-BASE-TYPE) gives rule 5 above.
//    Setup: Use the selected original fixture, declared type arguments, public
//    endpoint/base views and linked stage observations. Requests satisfy the
//    grant precondition before send_request and response IDs are copied from
//    the actual request. Expected: The typed pull sequencer is usable through
//    uvm_sequencer_base.
// 6. 1800.2-2020 15.6.1 (UVM-SQR-AUDIT-PUSH-BASE-TYPE) gives rule 6 above.
//    Setup: Use the selected original fixture, declared type arguments, public
//    endpoint/base views and linked stage observations. Requests satisfy the
//    grant precondition before send_request and response IDs are copied from
//    the actual request. Expected: The typed push sequencer is usable through
//    uvm_sequencer_base.
// 7. 1800.2-2020 15.6.3.2 (UVM-SQR-AUDIT-PUSH-CONSTRUCTOR-NAME) gives rule 7
//    above. Setup: Use the selected original fixture, declared type arguments,
//    public endpoint/base views and linked stage observations. Requests
//    satisfy the grant precondition before send_request and response IDs are
//    copied from the actual request. Expected: The push sequencer constructor
//    retains its explicit instance name.
// It also supports, as a control, the setup or conditions of
// UVM-SQR-AUDIT-UVM-SEQUENCER-BASE-ABSTRACT.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
