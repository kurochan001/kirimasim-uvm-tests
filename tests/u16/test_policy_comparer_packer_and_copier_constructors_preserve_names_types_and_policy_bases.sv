/*
:name: test_policy_comparer_packer_and_copier_constructors_preserve_names_types_and_policy_bases
:description: policy comparer packer and copier constructors preserve names types and policy bases
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.3.2.1 16.3.1 16.3.2.3 16.5.1 16.5.2.1 16.5.2.3 16.6.1 16.6.2.1 16.6.2.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_policy_comparer_packer_and_copier_constructors_preserve_names_types_and_policy_bases.expected
*/
module test_policy_comparer_packer_and_copier_constructors_preserve_names_types_and_policy_bases;
  import uvm_pkg::*;
  initial begin
    automatic uvm_comparer compare_default=new();
    automatic uvm_comparer compare_named=new("compare43");
    automatic uvm_comparer compare_empty=new("");
    automatic uvm_packer pack_default=new();
    automatic uvm_packer pack_named=new("pack43");
    automatic uvm_packer pack_empty=new("");
    automatic uvm_copier copy_default=new();
    automatic uvm_copier copy_named=new("copy43");
    automatic uvm_copier copy_empty=new("");
    automatic uvm_policy views[3]='{compare_named,pack_named,copy_named};
    $display("UT: comparer_constructor default %0d named %0d empty %0d type %0d base %0d",
             compare_default.get_name()=="",compare_named.get_name()=="compare43",
             compare_empty.get_name()=="",compare_named.get_type_name()=="uvm_comparer",
             views[0]==compare_named);
    $display("UT: packer_constructor default %0d named %0d empty %0d type %0d base %0d",
             pack_default.get_name()=="",pack_named.get_name()=="pack43",pack_empty.get_name()=="",
             pack_named.get_type_name()=="uvm_packer",views[1]==pack_named);
    $display("UT: copier_constructor default %0d named %0d empty %0d type %0d base %0d",
             copy_default.get_name()=="",copy_named.get_name()=="copy43",copy_empty.get_name()=="",
             copy_named.get_type_name()=="uvm_copier",views[2]==copy_named);
    $finish;
  end
endmodule
