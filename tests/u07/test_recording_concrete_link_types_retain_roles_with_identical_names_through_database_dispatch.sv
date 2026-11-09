/*
:name: test_recording_concrete_link_types_retain_roles_with_identical_names_through_database_dispatch
:description: recording concrete link types retain roles with identical names through database dispatch
:tags: u07 uvm
:type: simulation
:lrm: 1800.2-2020 7.3.2.1 7.3.3.1 7.3.4.1 7.3 7.3.1 7.1.5 7.1.6.4 7.1.3.1 7.1.4.1 7.3.1.3.5 13.1.7.11 13.1.7.13 7.1.3.1 7.1.4.1 7.1.6.1 7.1.6.2 7.1.6.3 7.1.6.4 7.2.7.1 7.2.7.2 7.2.7.3 7.2.7.4 16.4.7.1 16.4.7.2 16.4.7.3 16.4.7.4 16.4.7.5 16.4.7.6 16.4.7.9 16.4.7.10 16.4.7.11 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_recording_concrete_link_types_retain_roles_with_identical_names_through_database_dispatch.expected
*/
// What it checks:
// 1. The concrete parent-child link retains its link/object bases and selected
//    typed role through real database dispatch despite identical instance
//    names.
// 2. The concrete cause-effect link retains its link/object bases and selected
//    typed role through real database dispatch despite identical instance
//    names.
// 3. The concrete related link retains its link/object bases and selected
//    typed role through real database dispatch despite identical instance
//    names.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 7.3.2.1 (UVM-RECORDING-AUDIT-PARENT-CHILD-LINK-BASE) gives
//    rule 1 above. Setup: Use the linked original fixtures, selected public
//    arguments, explicit declared types and exact expected observations. The
//    recording backend is original in-memory setup, not an
//    implementation-derived oracle. Expected: The concrete parent-child link
//    retains its link/object bases and selected typed role through real
//    database dispatch despite identical instance names.
// 2. 1800.2-2020 7.3.3.1 (UVM-RECORDING-AUDIT-CAUSE-EFFECT-LINK-BASE) gives
//    rule 2 above. Setup: Use the linked original fixtures, selected public
//    arguments, explicit declared types and exact expected observations. The
//    recording backend is original in-memory setup, not an
//    implementation-derived oracle. Expected: The concrete cause-effect link
//    retains its link/object bases and selected typed role through real
//    database dispatch despite identical instance names.
// 3. 1800.2-2020 7.3.4.1 (UVM-RECORDING-AUDIT-RELATED-LINK-BASE) gives rule 3
//    above. Setup: Use the linked original fixtures, selected public
//    arguments, explicit declared types and exact expected observations. The
//    recording backend is original in-memory setup, not an
//    implementation-derived oracle. Expected: The concrete related link
//    retains its link/object bases and selected typed role through real
//    database dispatch despite identical instance names.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module
  test_recording_concrete_link_types_retain_roles_with_identical_names_through_database_dispatch;
  import uvm_pkg::*;
  time wanted_time;
  bit saw_time=0,saw_zero_length=0,saw_field=0,saw_user=0;
  class original_recorder extends uvm_recorder;
    time opened_at;
    function new(string name); super.new(name); endfunction
    protected virtual function void do_open(uvm_tr_stream stream,time open_time,string type_name);
      opened_at=open_time; if (open_time==wanted_time) saw_time=1;
    endfunction
    protected virtual function void do_close(time close_time);
      if (opened_at==wanted_time && close_time==wanted_time) saw_zero_length=1;
    endfunction
    protected virtual function void do_free(); endfunction
    protected virtual function void do_record_field(string name,uvm_bitstream_t value,int size,
                                                   uvm_radix_enum radix); endfunction
    protected virtual function void do_record_field_int(string name,uvm_integral_t value,int size,
                                                       uvm_radix_enum radix);
      if (name=="origin_field48" && value==48 && size==32 && radix==UVM_DEC) saw_field=1;
      if (name=="origin_user48" && value==96 && size==32 && radix==UVM_DEC) saw_user=1;
    endfunction
    protected virtual function void do_record_field_real(string name,real value); endfunction
    protected virtual function void do_record_string(string name,string value); endfunction
    protected virtual function void do_record_time(string name,time value); endfunction
    protected virtual function void do_record_generic(string name,string value,string type_name);
    endfunction
  endclass
  class original_stream extends uvm_tr_stream;
    function new(string name); super.new(name); endfunction
    protected virtual function void do_open(uvm_tr_database db,string scope,string type_name);
    endfunction
    protected virtual function void do_close(); endfunction
    protected virtual function void do_free(); endfunction
    protected virtual function uvm_recorder do_open_recorder(string name,time open_time,
                                                          string type_name);
      original_recorder value;
      value=new(name); return value;
    endfunction
  endclass
  class original_database extends uvm_tr_database;
    function new(string name="db48"); super.new(name); endfunction
    protected virtual function bit do_open_db(); return 1; endfunction
    protected virtual function bit do_close_db(); return 1; endfunction
    protected virtual function uvm_tr_stream do_open_stream(string name,string scope,
                                                         string type_name);
      original_stream value;
      value=new(name); return value;
    endfunction
    protected virtual function void do_establish_link(uvm_link_base link); endfunction
  endclass
  class original_component extends uvm_component;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
  endclass
  class role_database extends original_database;
    uvm_link_base last_link;
    int last_kind=0;
    protected virtual function void do_establish_link(uvm_link_base link);
      uvm_parent_child_link pc;
      uvm_cause_effect_link ce;
      uvm_related_link related;
      last_link=link; last_kind=0;
      if ($cast(pc,link)) last_kind=1;
      else if ($cast(ce,link)) last_kind=2;
      else if ($cast(related,link)) last_kind=3;
    endfunction
  endclass
  initial begin
    automatic role_database db=new();
    automatic uvm_parent_child_link pc=new("same48");
    automatic uvm_cause_effect_link ce=new("same48");
    automatic uvm_related_link related=new("same48");
    automatic uvm_link_base links[3]='{pc,ce,related};
    uvm_object object_view;
    uvm_tr_stream left_value,right_value;
    if (!db.open_db()) $fatal(1,"original database not open");
    left_value=db.open_stream("left48","scope48","");
    right_value=db.open_stream("right48","scope48","");
    foreach (links[i]) begin
      links[i].set(left_value,right_value); object_view=links[i];
      db.establish_link(links[i]);
      $display("UT: recording_link_role %0d kind %0d exact %0d endpoints %0d object %0d name %0d",
               i,db.last_kind,db.last_link==links[i],
               db.last_link.get_lhs()==left_value && db.last_link.get_rhs()==right_value,
               object_view==links[i],links[i].get_name()=="same48");
    end
    $finish;
  end
endmodule
