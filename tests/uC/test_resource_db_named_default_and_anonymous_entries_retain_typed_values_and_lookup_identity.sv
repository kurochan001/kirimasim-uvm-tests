/*
:name: test_resource_db_named_default_and_anonymous_entries_retain_typed_values_and_lookup_identity
:description: Resource DB creates named/default/anonymous typed resources and exposes their original handles
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.3.2.3.1 C.3.2.3.2 C.3.2.3.3 C.3.2.3.4 C.3.2.3.5 C.3.2.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_resource_db_named_default_and_anonymous_entries_retain_typed_values_and_lookup_identity.expected
*/
module test_resource_db_named_default_and_anonymous_entries_retain_typed_values_and_lookup_identity;
  import uvm_pkg::*;
  typedef bit [15:0] word_type;
  initial begin
    uvm_resource_db#(word_type)::rsrc_t default_value;
    uvm_resource#(word_type) exact;
    uvm_resource#(int) named,anonymous_value;
    default_value=uvm_resource_db#(word_type)::set_default("default_scope58","default58");
    exact=default_value; default_value=exact;
    uvm_resource_db#(int)::set("named_scope58","named58",58);
    named=uvm_resource_db#(int)::get_by_name("named_scope58","named58",0);
    uvm_resource_db#(int)::set_anonymous("anonymous_scope58",59);
    anonymous_value=uvm_resource_db#(int)::get_by_type("anonymous_scope58");
    $display("UT: database_entries default %0d named %0d named_identity %0d anonymous %0d",
      default_value!=null && default_value.read()==0,
      named!=null && named.read()==58,
      named==uvm_resource_db#(int)::get_by_type("named_scope58"),
      anonymous_value!=null && anonymous_value.get_name()=="" && anonymous_value.read()==59);
    $finish;
  end
endmodule
