/*
:name: test_database_constructor_forwards_default_and_explicit_names
:description: database construction preserves the base default name and explicit names independently (7.1.2)
:tags: u07 uvm
:type: simulation
:lrm: 1800.2-2020 7.1.2 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_database_constructor_forwards_default_and_explicit_names.expected
*/
// The concrete subclass forwards an omitted argument to the abstract base.
// No recording backend is opened.
module test_database_constructor_forwards_default_and_explicit_names;
  import uvm_pkg::*;
  class local_database extends uvm_tr_database;
    function new();
      super.new();
    endfunction
    protected function bit do_open_db(); return 1; endfunction
    protected function bit do_close_db(); return 1; endfunction
    protected function uvm_tr_stream do_open_stream(string name, string scope, string type_name);
      return null;
    endfunction
    protected function void do_establish_link(uvm_link_base link); endfunction
  endclass
  class named_local_database extends uvm_tr_database;
    function new(string name);
      super.new(name);
    endfunction
    protected function bit do_open_db(); return 1; endfunction
    protected function bit do_close_db(); return 1; endfunction
    protected function uvm_tr_stream do_open_stream(string name, string scope, string type_name);
      return null;
    endfunction
    protected function void do_establish_link(uvm_link_base link); endfunction
  endclass
  function automatic bit distinct_objects(uvm_object lhs, uvm_object rhs);
    return lhs != rhs;
  endfunction
  initial begin
    automatic local_database first = new();
    automatic named_local_database named = new("named_db");
    automatic named_local_database empty_name = new("");
    $display("UT: names default %s explicit %s empty %0d", first.get_name(), named.get_name(),
             empty_name.get_name() == "");
    $display("UT: distinct %0d %0d", distinct_objects(first, named), named != empty_name);
    $finish;
  end
endmodule
