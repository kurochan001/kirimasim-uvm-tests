/*
:name: test_database_and_link_descendants_inherit_concrete_pure_hook_implementations
:description: Inherited implementations satisfy the database and link pure interfaces (7.1.6.1)
:tags: u07 uvm
:type: simulation
:lrm: 1800.2-2020 7.1.6.1 7.1.6.2 7.1.6.3 7.1.6.4 7.1.3.1 7.1.3.2 7.1.3.3 7.1.4.1 7.1.5 7.3.1.3.1 7.3.1.3.2 7.3.1.3.3 7.3.1.3.4 7.3.1.3.5 7.3.1.4.1 7.3.1.4.2 7.3.1.4.3 7.3.1.4.4 1800-2023 6.21 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_database_and_link_descendants_inherit_concrete_pure_hook_implementations.expected
*/
module test_database_and_link_descendants_inherit_concrete_pure_hook_implementations;
  import uvm_pkg::*;
  // Original in-memory endpoints and hook bodies are setup. Only inherited
  // availability and public-wrapper dispatch are observed; no hook order.
  class local_stream extends uvm_tr_stream;
    function new(string name); super.new(name); endfunction
    protected function void do_open(uvm_tr_database db, string scope, string stream_type_name);
    endfunction
    protected function void do_close(); endfunction
    protected function void do_free(); endfunction
    protected function uvm_recorder do_open_recorder(string name, time open_time, string type_name);
      return null;
    endfunction
  endclass
  class implemented_database extends uvm_tr_database;
    local_stream candidate;
    uvm_link_base seen_link;
    int opens = 0, closes = 0, streams = 0, links = 0;
    function new(string name); super.new(name); endfunction
    protected function bit do_open_db(); opens++; return 1; endfunction
    protected function bit do_close_db(); closes++; return 1; endfunction
    protected function uvm_tr_stream do_open_stream(string name, string scope, string type_name);
      streams++; return candidate;
    endfunction
    protected function void do_establish_link(uvm_link_base link);
      links++; seen_link = link;
    endfunction
  endclass
  class inherited_database extends implemented_database;
    function new(string name); super.new(name); endfunction
  endclass
  class implemented_link extends uvm_link_base;
    uvm_object left_value, right_value;
    int left_sets = 0, right_sets = 0, left_gets = 0, right_gets = 0;
    virtual function void do_set_lhs(uvm_object lhs); left_sets++; left_value = lhs; endfunction
    virtual function void do_set_rhs(uvm_object rhs); right_sets++; right_value = rhs; endfunction
    virtual function uvm_object do_get_lhs(); left_gets++; return left_value; endfunction
    virtual function uvm_object do_get_rhs(); right_gets++; return right_value; endfunction
  endclass
  class inherited_link extends implemented_link;
  endclass
  initial begin
    automatic inherited_database db = new("inherited_db");
    automatic inherited_link relation = new();
    automatic local_stream left_value = new("left");
    automatic local_stream right_value = new("right");
    automatic uvm_tr_database db_view = db;
    automatic uvm_link_base link_view = relation;
    bit opened, left_opened, right_opened, left_matches, right_matches, closed;
    opened = db_view.open_db();
    db.candidate = left_value;
    left_opened = db_view.open_stream("left") == left_value;
    db.candidate = right_value;
    right_opened = db_view.open_stream("right") == right_value;
    link_view.set(left_value, right_value);
    left_matches = link_view.get_lhs() == left_value;
    right_matches = link_view.get_rhs() == right_value;
    $display("UT: inherited_endpoints identity %0d %0d sets %0d/%0d gets %0d/%0d",
             left_matches, right_matches, relation.left_sets, relation.right_sets,
             relation.left_gets, relation.right_gets);
    db_view.establish_link(link_view);
    $display("UT: inherited_database open %0d streams %0d/%0d calls %0d/%0d link %0d/%0d",
             opened, left_opened, right_opened, db.opens, db.streams,
             db.links, db.seen_link == link_view);
    left_value.close(); right_value.close();
    left_value.free(); right_value.free();
    closed = db_view.close_db();
    $display("UT: inherited_close result %0d calls %0d state %0d", closed, db.closes,
             !db_view.is_open());
    $finish;
  end
endmodule
