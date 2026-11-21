/*
:name: test_object_param_utils_register_each_specialization_with_its_own_proxy
:description: the parameterized object utility macros give each specialization its own factory proxy, creation and overrides, and their begin form adds field operations (IEEE 1800.2-2020 Section B.2.1.2)
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.2.1.2 B.2.2.1.1 5.3.4.5 5.3.4.6 5.3.8.1 5.3.9.1 8.2.4.2.4 8.2.4.2.5 1800-2023 6.21 8.25 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_param_utils_register_each_specialization_with_its_own_proxy.expected
*/
// What it checks:
// 1. `uvm_object_param_utils gives each specialization of a parameterized
//    class a type_id, a static get_type and a get_object_type of its own.
// 2. A type override of one specialization does not affect another.
// 3. `uvm_object_param_utils_begin with `uvm_object_utils_end also provides
//    the field operations of the macros between them.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 B.2.1.2 (UVM-PARAM-UTILS-OBJECT-PROXY) gives rule 1: the
//    macro implements type_id, get_type (5.3.4.5) and get_object_type
//    (5.3.4.6) for the class it is used in. Setup: create typed_item#(int) and
//    typed_item#(string) through type_id::create (8.2.4.2.4). Expected: both
//    objects exist with their own value type, the two proxies differ, and each
//    object's get_object_type is the proxy of its own specialization.
// 2. 1800.2-2020 B.2.1.2 (UVM-PARAM-UTILS-OBJECT-OVERRIDE) gives rule 2 with
//    8.2.4.2.5. Setup: override typed_item#(int) by int_special and create both
//    specializations again. Expected: the int request gives int_special, and
//    the string request still gives typed_item#(string).
// 3. 1800.2-2020 B.2.1.2 (UVM-PARAM-UTILS-OBJECT-FIELDS) gives rule 3 with
//    B.2.2.1.1. Setup: copy a wide_item#(12) whose level is 'hABC into another
//    (5.3.8.1) and compare them (5.3.9.1), then change one level. Expected:
//    the copy has 'hABC, the equal objects compare as 1 and the changed ones
//    as 0.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The type name and name-based lookup of a parameterized class are not
// observed: B.2.1.2 says only that no type name is supplied at registration.
module test_object_param_utils_register_each_specialization_with_its_own_proxy;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class typed_item #(type T=int) extends uvm_object;
    T value;
    `uvm_object_param_utils(typed_item#(T))
    function new(string name="typed_item");
      super.new(name);
    endfunction
    virtual function string kind();
      return "plain";
    endfunction
  endclass

  class int_special extends typed_item#(int);
    `uvm_object_utils(int_special)
    function new(string name="int_special");
      super.new(name);
    endfunction
    virtual function string kind();
      return "special";
    endfunction
  endclass

  class wide_item #(int W=8) extends uvm_object;
    bit [W-1:0] level;
    `uvm_object_param_utils_begin(wide_item#(W))
      `uvm_field_int(level, UVM_DEFAULT)
    `uvm_object_utils_end
    function new(string name="wide_item");
      super.new(name);
    endfunction
  endclass

  initial begin
    automatic typed_item#(int) number = typed_item#(int)::type_id::create("number");
    automatic typed_item#(string) text = typed_item#(string)::type_id::create("text");
    automatic uvm_object_wrapper int_proxy = typed_item#(int)::get_type();
    automatic uvm_object_wrapper string_proxy = typed_item#(string)::get_type();
    automatic wide_item#(12) source = wide_item#(12)::type_id::create("source");
    automatic wide_item#(12) target = wide_item#(12)::type_id::create("target");
    typed_item#(int) overridden;
    typed_item#(string) untouched;
    bit [11:0] copied;
    bit equal;
    bit changed;
    number.value = 7;
    text.value = "seven";
    $display("UT: created %0d %s proxies_differ %0d own_proxy %0d %0d", number.value,
             text.value, int_proxy != string_proxy, number.get_object_type() == int_proxy,
             text.get_object_type() == string_proxy);
    typed_item#(int)::type_id::set_type_override(int_special::get_type());
    overridden = typed_item#(int)::type_id::create("overridden");
    untouched = typed_item#(string)::type_id::create("untouched");
    $display("UT: override int %s string %s string_proxy %0d", overridden.kind(),
             untouched.kind(), untouched.get_object_type() == string_proxy);
    source.level = 12'hABC;
    target.copy(source);
    copied = target.level;
    equal = source.compare(target);
    target.level = 12'h123;
    changed = source.compare(target);
    $display("UT: fields copied %0h equal %0d changed %0d", copied, equal, changed);
    $finish;
  end
endmodule
