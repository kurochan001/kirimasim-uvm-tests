/*
:name: test_stream_constructor_forwards_default_and_explicit_names
:description: stream construction forwards omitted and explicit names to the abstract base (7.2.2)
:tags: u07 uvm
:type: simulation
:lrm: 1800.2-2020 7.2.2 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_stream_constructor_forwards_default_and_explicit_names.expected
*/
// What it checks:
// 1. The stream constructor uses its specified default name when the name
//    argument is omitted.
// 2. The stream constructor preserves an explicitly supplied instance name.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 7.2.2 (UVM-STREAM-CONSTRUCTOR-DEFAULT-NAME) gives rule 1
//    above. Setup: Concrete extensions forward omitted and explicit arguments
//    to the base constructor. Expected: The omitted-name instance has the name
//    unnamed-uvm_tr_stream.
// 2. 1800.2-2020 7.2.2 (UVM-STREAM-CONSTRUCTOR-EXPLICIT-NAME) gives rule 2
//    above. Setup: Concrete extensions forward omitted and explicit arguments
//    to the base constructor. Expected: The explicit name is named_stream and
//    an explicitly empty name remains empty.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Only constructor names are observed; no uninitialized metadata query is made.
module test_stream_constructor_forwards_default_and_explicit_names;
  import uvm_pkg::*;
  class local_stream extends uvm_tr_stream;
    function new();
      super.new();
    endfunction
    protected function void do_open(uvm_tr_database db, string scope, string stream_type_name);
    endfunction
    protected function void do_close(); endfunction
    protected function void do_free(); endfunction
    protected function uvm_recorder do_open_recorder(string name, time open_time, string type_name);
      return null;
    endfunction
  endclass
  class named_local_stream extends uvm_tr_stream;
    function new(string name);
      super.new(name);
    endfunction
    protected function void do_open(uvm_tr_database db, string scope, string stream_type_name);
    endfunction
    protected function void do_close(); endfunction
    protected function void do_free(); endfunction
    protected function uvm_recorder do_open_recorder(string name, time open_time, string type_name);
      return null;
    endfunction
  endclass
  function automatic bit distinct_objects(uvm_object lhs, uvm_object rhs);
    return lhs != rhs;
  endfunction
  initial begin
    automatic local_stream first = new();
    automatic named_local_stream named = new("named_stream");
    automatic named_local_stream empty_name = new("");
    $display("UT: names default %s explicit %s empty %0d", first.get_name(), named.get_name(),
             empty_name.get_name() == "");
    $display("UT: distinct %0d %0d", distinct_objects(first, named), named != empty_name);
    $finish;
  end
endmodule
