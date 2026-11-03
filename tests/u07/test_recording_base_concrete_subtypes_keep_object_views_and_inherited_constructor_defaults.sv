/*
:name: test_recording_base_concrete_subtypes_keep_object_views_and_inherited_constructor_defaults
:description: recording base concrete subtypes keep object views and inherited constructor defaults
:tags: u07 uvm
:type: simulation
:lrm: 1800.2-2020 7.1.1 7.2.1 7.3.1.1 7.1.2 7.2.2 7.3.1.2 7.1.6.1 7.1.6.2 7.1.6.3 7.1.6.4 7.2.7.1 7.2.7.2 7.2.7.3 7.2.7.4 7.3.1.4.1 7.3.1.4.2 7.3.1.4.3 7.3.1.4.4 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_recording_base_concrete_subtypes_keep_object_views_and_inherited_constructor_defaults.expected
*/
module test_recording_base_concrete_subtypes_keep_object_views_and_inherited_constructor_defaults;
  import uvm_pkg::*;
  class database_probe extends uvm_tr_database;
    function new(); super.new(); endfunction
    protected virtual function bit do_open_db(); return 1; endfunction
    protected virtual function bit do_close_db(); return 1; endfunction
    protected virtual function uvm_tr_stream do_open_stream(string name,string scope,
                                                         string type_name);
      return null;
    endfunction
    protected virtual function void do_establish_link(uvm_link_base link); endfunction
  endclass
  class stream_probe extends uvm_tr_stream;
    function new(); super.new(); endfunction
    protected virtual function void do_open(uvm_tr_database db,string scope,string type_name);
    endfunction
    protected virtual function void do_close(); endfunction
    protected virtual function void do_free(); endfunction
    protected virtual function uvm_recorder do_open_recorder(string name,time open_time,
                                                          string type_name);
      return null;
    endfunction
  endclass
  class link_probe extends uvm_link_base;
    function new(); super.new(); endfunction
    uvm_object left_value,right_value;
    protected virtual function uvm_object do_get_lhs(); return left_value; endfunction
    protected virtual function uvm_object do_get_rhs(); return right_value; endfunction
    protected virtual function void do_set_lhs(uvm_object value); left_value=value; endfunction
    protected virtual function void do_set_rhs(uvm_object value); right_value=value; endfunction
  endclass
  class named_link_probe extends uvm_link_base;
    function new(string name); super.new(name); endfunction
    uvm_object left_value,right_value;
    protected virtual function uvm_object do_get_lhs(); return left_value; endfunction
    protected virtual function uvm_object do_get_rhs(); return right_value; endfunction
    protected virtual function void do_set_lhs(uvm_object value); left_value=value; endfunction
    protected virtual function void do_set_rhs(uvm_object value); right_value=value; endfunction
  endclass
  initial begin
    automatic database_probe db=new();
    automatic stream_probe stream_value=new();
    automatic link_probe link_value=new();
    automatic named_link_probe named_link=new("named48");
    automatic uvm_object objects[3]='{db,stream_value,link_value};
    $display("UT: recording_base_objects database %0d stream %0d link %0d",
             objects[0]==db,objects[1]==stream_value,objects[2]==link_value);
    $display("UT: recording_base_defaults database %0d stream %0d link %0d explicit %0d",
             db.get_name()=="unnamed-uvm_tr_database",
             stream_value.get_name()=="unnamed-uvm_tr_stream",
             link_value.get_name()=="unnamed-uvm_link_base",named_link.get_name()=="named48");
    $finish;
  end
endmodule
