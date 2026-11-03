/*
:name: test_component_permitted_leaf_names_register_without_changing_their_characters
:description: component permitted leaf names register without changing their characters
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.1.2.1 13.1.3.4 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_permitted_leaf_names_register_without_changing_their_characters.expected
*/
module test_component_permitted_leaf_names_register_without_changing_their_characters;
  import uvm_pkg::*;
  class actor extends uvm_component;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
  endclass
  initial begin
    automatic actor owner=new("owner46",null);
    automatic string names[7]='{"Alpha09","a_b","a-b","a[3]","a(4)","a{5}","Z9"};
    actor value;
    foreach (names[i]) begin
      value=new(names[i],owner);
      $display("UT: permitted_leaf %0d name %0d child %0d",i,
               value.get_name()==names[i],owner.get_child(names[i])==value);
    end
    $finish;
  end
endmodule
