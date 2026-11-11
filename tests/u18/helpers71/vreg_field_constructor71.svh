// Factory-created subclasses expose actual omitted/explicit base constructors.
class default_field71 extends uvm_vreg_field;
  `uvm_object_utils(default_field71)
  string constructor_name;
  function new(string name="");
    super.new();
    constructor_name=get_name();
  endfunction
endclass
class named_field71 extends uvm_vreg_field;
  `uvm_object_utils(named_field71)
  string constructor_name;
  function new(string name="");
    super.new(name);
    constructor_name=get_name();
  endfunction
endclass
