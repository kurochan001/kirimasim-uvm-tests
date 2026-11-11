/*
:name: test_namespace_1_94
:description: Selected UVM classes, types, enum values and global accessors agree across imported and qualified package views
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.1 1.4.5 F.2.1.3 F.2.1.5 F.7.2.2 F.3.2.1 5.3.3.1 5.3.3.2 1800-2023 6.21 8.20 8.21 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers94_namespace/namespace_fixture94.sv
:expected_exit: 0
:expected_stdout: @test_namespace_1_94.expected
*/
// What it checks:
// Selected public UVM classes, types, enum values and global methods are
// accessible through import and package qualification with the same
// identities.
//
// Variant: Input 0 takes the first of each pair of choices (the value
// 16'h3a71, UVM_HEX and the object q); input 1 takes the second (16'h8c25,
// UVM_OCT and the object i).
//
// How the expected output follows from the standard:
// 1800.2-2020 1.4.5 (UVM-PACKAGE-IMPORTED-QUALIFIED-ACCESS-94) gives the rule
// above. Setup: Use two separately compiled original packages; one has no UVM
// wildcard import and fully qualifies its UVM references, while the other
// imports uvm_pkg. Transfer original objects and typed words across both
// views, in opposite object directions. Expected: Cross-view object access
// retains the same live handle and independent peer; a selected high bit/value
// and named radix agree; root and package report-object accessors agree.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_namespace_1_94;
  initial begin
    qualified94::packet94 q;
    imported94::packet94 i;
    qualified94::word94 qw;
    imported94::word94 iw;
    uvm_pkg::uvm_object viewed;
    uvm_pkg::uvm_radix_enum selected;
    q=new("q94");i=new("i94");
    qw='0;qw[137]=1;qw[15:0]=1==0?16'h3a71:16'h8c25;iw=qw;
    selected=1==0?uvm_pkg::UVM_HEX:uvm_pkg::UVM_OCT;
    if(1==0) begin viewed=imported94::echo94(q);viewed.set_name("q_live94");end
    else begin viewed=qualified94::echo94(i);viewed.set_name("i_live94");end
    $display("UT: namespace94 %0d class_identity %0d mutation %0d peer %0d",1,
      1==0?viewed==q:viewed==i,1==0?q.get_name()=="q_live94":i.get_name()=="i_live94",
      1==0?i.get_name()=="i94":q.get_name()=="q94");
    $display("UT: namespace94 %0d type_value %0d enum_name %0d",1,iw==qw && iw[137],
      qualified94::radix94(selected)==imported94::radix94(selected) &&
      imported94::radix94(selected)==(1==0?"UVM_HEX":"UVM_OCT"));
    $display("UT: namespace94 %0d root %0d global_method %0d",1,
      qualified94::root94()==imported94::root94(),
      qualified94::reporter94()==imported94::reporter94() &&
      qualified94::reporter94()==qualified94::root94());
    $finish;
  end
endmodule
