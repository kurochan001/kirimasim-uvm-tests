/*
:name: test_sequence_base_and_typed_sequence_constructors_forward_base_name_defaults
:description: concrete extensions preserve sequence base and typed sequence constructor defaults (14.2.2.1)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.2.1 14.3.3.1 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_base_and_typed_sequence_constructors_forward_base_name_defaults.expected
*/
// Concrete extensions forward omitted arguments to their base constructors.
// No sequence is started or randomized in this constructor-only fixture.
module test_sequence_base_and_typed_sequence_constructors_forward_base_name_defaults;
  import uvm_pkg::*;
  class base_sequence extends uvm_sequence_base;
    function new();
      super.new();
    endfunction
    task body(); endtask
  endclass
  class named_base_sequence extends uvm_sequence_base;
    function new(string name);
      super.new(name);
    endfunction
    task body(); endtask
  endclass
  class typed_sequence extends uvm_sequence#(uvm_sequence_item);
    function new();
      super.new();
    endfunction
    task body(); endtask
  endclass
  class named_typed_sequence extends uvm_sequence#(uvm_sequence_item);
    function new(string name);
      super.new(name);
    endfunction
    task body(); endtask
  endclass
  function automatic bit distinct_objects(uvm_object lhs, uvm_object rhs);
    return lhs != rhs;
  endfunction
  initial begin
    automatic base_sequence base_default = new();
    automatic named_base_sequence base_named = new("base_named");
    automatic typed_sequence typed_default = new();
    automatic named_typed_sequence typed_empty = new("");
    $display("UT: default_names %s %s", base_default.get_name(), typed_default.get_name());
    $display("UT: explicit base %s typed_empty %0d", base_named.get_name(),
             typed_empty.get_name() == "");
    $display("UT: distinct %0d %0d", distinct_objects(base_default, base_named),
             distinct_objects(typed_default, typed_empty));
    $finish;
  end
endmodule
