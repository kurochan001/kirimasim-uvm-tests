/*
:name: test_object_abstract_utils_create_the_overriding_concrete_types_with_fields
:description: the abstract object utility macros register virtual classes whose creation gives the overriding concrete type, in the plain, parameterized and begin forms (IEEE 1800.2-2020 Section B.2.1.2)
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.2.1.2 B.2.2.1.1 8.2.5 8.2.5.2 8.2.5.2.3 8.2.5.2.5 8.2.5.2.6 5.3.8.1 5.3.9.1 1800-2023 6.21 8.21 8.25
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_abstract_utils_create_the_overriding_concrete_types_with_fields.expected
*/
// What it checks:
// 1. `uvm_object_abstract_utils and `uvm_object_abstract_param_utils register
//    a virtual class, so that creating it through type_id gives the concrete
//    type that overrides it.
// 2. The plain form registers the type name, as `uvm_object_utils does.
// 3. The two begin forms also provide the field operations of the macros up
//    to `uvm_object_utils_end.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 B.2.1.2 (UVM-ABSTRACT-UTILS-OBJECT-OVERRIDE) gives rule 1:
//    the abstract forms differ from the others only in the registry, and 8.2.5
//    has the user provide an override for a registered abstract class. Setup:
//    override shape by square and sized#(3) by sized_three (8.2.5.2.6), then
//    create shape and sized#(3) (8.2.5.2.5). Expected: the objects are a square
//    with 4 sides and a sized_three of size 3.
// 2. 1800.2-2020 B.2.1.2 (UVM-ABSTRACT-UTILS-OBJECT-NAME) gives rule 2 with
//    8.2.5.2.3. Expected: the proxy of shape has the type name shape.
// 3. 1800.2-2020 B.2.1.2 (UVM-ABSTRACT-UTILS-OBJECT-FIELDS) gives rule 3 with
//    B.2.2.1.1. Setup: for labeled and for leveled#(6), create two overriding
//    objects, copy one into the other (5.3.8.1), compare them (5.3.9.1), then
//    change one field. Expected: the copies hold 5 and 'h2a, the equal objects
//    compare as 1 and the changed ones as 0.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Creating an abstract class without an override, which 8.2.5 makes an error,
// is left to the tests of the abstract registries.
module test_object_abstract_utils_create_the_overriding_concrete_types_with_fields;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  virtual class shape extends uvm_object;
    `uvm_object_abstract_utils(shape)
    function new(string name="shape");
      super.new(name);
    endfunction
    pure virtual function int sides();
  endclass
  class square extends shape;
    `uvm_object_utils(square)
    function new(string name="square");
      super.new(name);
    endfunction
    virtual function int sides();
      return 4;
    endfunction
  endclass

  virtual class sized #(int N=1) extends uvm_object;
    `uvm_object_abstract_param_utils(sized#(N))
    function new(string name="sized");
      super.new(name);
    endfunction
    pure virtual function int size();
  endclass
  class sized_three extends sized#(3);
    `uvm_object_utils(sized_three)
    function new(string name="sized_three");
      super.new(name);
    endfunction
    virtual function int size();
      return N;
    endfunction
  endclass

  virtual class labeled extends uvm_object;
    int tag;
    `uvm_object_abstract_utils_begin(labeled)
      `uvm_field_int(tag, UVM_DEFAULT)
    `uvm_object_utils_end
    function new(string name="labeled");
      super.new(name);
    endfunction
  endclass
  class labeled_item extends labeled;
    `uvm_object_utils(labeled_item)
    function new(string name="labeled_item");
      super.new(name);
    endfunction
  endclass

  virtual class leveled #(int W=8) extends uvm_object;
    bit [W-1:0] level;
    `uvm_object_abstract_param_utils_begin(leveled#(W))
      `uvm_field_int(level, UVM_DEFAULT)
    `uvm_object_utils_end
    function new(string name="leveled");
      super.new(name);
    endfunction
  endclass
  class leveled_six extends leveled#(6);
    `uvm_object_utils(leveled_six)
    function new(string name="leveled_six");
      super.new(name);
    endfunction
  endclass

  initial begin
    automatic uvm_object_wrapper shape_proxy = shape::get_type();
    shape made_shape;
    sized#(3) made_sized;
    labeled tag_source;
    labeled tag_target;
    leveled#(6) level_source;
    leveled#(6) level_target;
    int copied_tag;
    bit [5:0] copied_level;
    bit tag_equal;
    bit tag_changed;
    bit level_equal;
    bit level_changed;
    shape::type_id::set_type_override(square::get_type());
    sized#(3)::type_id::set_type_override(sized_three::get_type());
    labeled::type_id::set_type_override(labeled_item::get_type());
    leveled#(6)::type_id::set_type_override(leveled_six::get_type());
    made_shape = shape::type_id::create("made_shape");
    made_sized = sized#(3)::type_id::create("made_sized");
    $display("UT: created sides %0d size %0d shape_name %s", made_shape.sides(),
             made_sized.size(), shape_proxy.get_type_name());
    tag_source = labeled::type_id::create("tag_source");
    tag_target = labeled::type_id::create("tag_target");
    tag_source.tag = 5;
    tag_target.copy(tag_source);
    copied_tag = tag_target.tag;
    tag_equal = tag_source.compare(tag_target);
    tag_target.tag = 6;
    tag_changed = tag_source.compare(tag_target);
    $display("UT: labeled copied %0d equal %0d changed %0d", copied_tag, tag_equal, tag_changed);
    level_source = leveled#(6)::type_id::create("level_source");
    level_target = leveled#(6)::type_id::create("level_target");
    level_source.level = 6'h2a;
    level_target.copy(level_source);
    copied_level = level_target.level;
    level_equal = level_source.compare(level_target);
    level_target.level = 6'h15;
    level_changed = level_source.compare(level_target);
    $display("UT: leveled copied %0h equal %0d changed %0d", copied_level, level_equal,
             level_changed);
    $finish;
  end
endmodule
