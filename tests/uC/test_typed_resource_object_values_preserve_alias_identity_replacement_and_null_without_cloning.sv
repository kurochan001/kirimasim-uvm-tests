/*
:name: test_typed_resource_object_values_preserve_alias_identity_replacement_and_null_without_cloning
:description: Object resources retain live handles, replace their selected value and can store null
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.2.5.4.1 C.2.5.4.2 C.2.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_typed_resource_object_values_preserve_alias_identity_replacement_and_null_without_cloning.expected
*/
module
  test_typed_resource_object_values_preserve_alias_identity_replacement_and_null_without_cloning;
  import uvm_pkg::*;
  class token_type extends uvm_object;
    int marker;
    function new(string name,int value); super.new(name); marker=value; endfunction
  endclass
  initial begin
    automatic uvm_resource#(token_type) resource=new("resource58");
    automatic token_type first_token=new("first58",11);
    automatic token_type second_token=new("second58",22);
    token_type saved;
    resource.write(first_token); saved=resource.read(); first_token.marker=33;
    $display("UT: object_resource same_handle %0d live_alias %0d",
      saved==first_token,saved.marker==33);
    resource.write(second_token);
    $display("UT: object_resource replacement %0d old_valid %0d",
      resource.read()==second_token,saved==first_token && saved.marker==33);
    resource.write(null);
    $display("UT: object_resource null %0d peer_valid %0d",resource.read()==null,
      second_token.marker==22);
    $finish;
  end
endmodule
