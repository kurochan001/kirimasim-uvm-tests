/*
:name: test_recorder_configuration_defaults_updates_and_flush_restore_the_declared_values
:description: recorder configuration defaults updates and flush restore the declared values
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.4.2.1 16.4.2.2 16.4.2.3 16.4.4.1 16.4.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_recorder_configuration_defaults_updates_and_flush_restore_the_declared_values.expected
*/
// What it checks:
// 1. A legal concrete recorder retains its declared uvm_policy base.
// 2. A fresh recorder recursion getter returns UVM_DEFAULT_POLICY.
// 3. A selected recorder recursion setter changes its getter while a fresh
//    peer keeps its default.
// 4. Recorder flush restores the declared recursion default
//    UVM_DEFAULT_POLICY.
// 5. A fresh recorder id getter returns one.
// 6. A selected recorder id setter changes its getter while a fresh peer keeps
//    its default.
// 7. Recorder flush restores the declared id default one.
// 8. A fresh recorder radix getter returns UVM_HEX.
// 9. A selected recorder radix setter changes its getter while a fresh peer
//    keeps its default.
// 10. Recorder flush restores the declared radix default UVM_HEX.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.4.1 (UVM-POLICY-AUDIT-RECORDER-BASE) gives rule 1 above.
//    Setup: Use the selected original fixtures, explicit arguments and stage
//    observations in the linked anchors; each fresh policy and peer is
//    independently constructed. Expected: A legal concrete recorder retains
//    its declared uvm_policy base.
// 2. 1800.2-2020 16.4.2.1 (UVM-POLICY-AUDIT-RECORDER-RECURSION-INITIAL) gives
//    rule 2 above. Setup: Use the selected original fixtures, explicit
//    arguments and stage observations in the linked anchors; each fresh policy
//    and peer is independently constructed. Expected: A fresh recorder
//    recursion getter returns UVM_DEFAULT_POLICY.
// 3. 1800.2-2020 16.4.2.1 (UVM-POLICY-AUDIT-RECORDER-RECURSION-UPDATE) gives
//    rule 3 above. Setup: Use the selected original fixtures, explicit
//    arguments and stage observations in the linked anchors; each fresh policy
//    and peer is independently constructed. Expected: A selected recorder
//    recursion setter changes its getter while a fresh peer keeps its default.
// 4. 1800.2-2020 16.4.2.1 (UVM-POLICY-AUDIT-RECORDER-RECURSION-FLUSH) gives
//    rule 4 above. Setup: Use the selected original fixtures, explicit
//    arguments and stage observations in the linked anchors; each fresh policy
//    and peer is independently constructed. Expected: Recorder flush restores
//    the declared recursion default UVM_DEFAULT_POLICY.
// 5. 1800.2-2020 16.4.2.2 (UVM-POLICY-AUDIT-RECORDER-ID-INITIAL) gives rule 5
//    above. Setup: Use the selected original fixtures, explicit arguments and
//    stage observations in the linked anchors; each fresh policy and peer is
//    independently constructed. Expected: A fresh recorder id getter returns
//    one.
// 6. 1800.2-2020 16.4.2.2 (UVM-POLICY-AUDIT-RECORDER-ID-UPDATE) gives rule 6
//    above. Setup: Use the selected original fixtures, explicit arguments and
//    stage observations in the linked anchors; each fresh policy and peer is
//    independently constructed. Expected: A selected recorder id setter
//    changes its getter while a fresh peer keeps its default.
// 7. 1800.2-2020 16.4.2.2 (UVM-POLICY-AUDIT-RECORDER-ID-FLUSH) gives rule 7
//    above. Setup: Use the selected original fixtures, explicit arguments and
//    stage observations in the linked anchors; each fresh policy and peer is
//    independently constructed. Expected: Recorder flush restores the declared
//    id default one.
// 8. 1800.2-2020 16.4.2.3 (UVM-POLICY-AUDIT-RECORDER-RADIX-INITIAL) gives rule
//    8 above. Setup: Use the selected original fixtures, explicit arguments
//    and stage observations in the linked anchors; each fresh policy and peer
//    is independently constructed. Expected: A fresh recorder radix getter
//    returns UVM_HEX.
// 9. 1800.2-2020 16.4.2.3 (UVM-POLICY-AUDIT-RECORDER-RADIX-UPDATE) gives rule
//    9 above. Setup: Use the selected original fixtures, explicit arguments
//    and stage observations in the linked anchors; each fresh policy and peer
//    is independently constructed. Expected: A selected recorder radix setter
//    changes its getter while a fresh peer keeps its default.
// 10. 1800.2-2020 16.4.2.3 (UVM-POLICY-AUDIT-RECORDER-RADIX-FLUSH) gives rule
//     10 above. Setup: Use the selected original fixtures, explicit arguments
//     and stage observations in the linked anchors; each fresh policy and peer
//     is independently constructed. Expected: Recorder flush restores the
//     declared radix default UVM_HEX.
// It also supports, as a control, the setup or conditions of
// UVM-POLICY-AUDIT-RECORDER-ILLEGAL-DO-RECORD-FIELD,
// UVM-POLICY-AUDIT-RECORDER-ILLEGAL-DO-RECORD-FIELD-INT,
// UVM-POLICY-AUDIT-RECORDER-ILLEGAL-DO-RECORD-FIELD-REAL,
// UVM-POLICY-AUDIT-RECORDER-ILLEGAL-DO-RECORD-STRING,
// UVM-POLICY-AUDIT-RECORDER-ILLEGAL-DO-RECORD-TIME,
// UVM-POLICY-AUDIT-RECORDER-ILLEGAL-DO-RECORD-GENERIC,
// UVM-POLICY-AUDIT-RECORDER-ILLEGAL-ABSTRACT.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_recorder_configuration_defaults_updates_and_flush_restore_the_declared_values;
  import uvm_pkg::*;
  string order="";
  class local_recorder extends uvm_recorder;
    int opens=0,closes=0,frees=0,object_calls=0;
    string object_name;
    uvm_object object_value;
    function new(string name="recorder"); super.new(name); endfunction
    protected virtual function void do_open(uvm_tr_stream stream,time open_time,string type_name);
      opens++; order={order,"O"};
    endfunction
    protected virtual function void do_close(time close_time); closes++; order={order,"C"};
    endfunction
    protected virtual function void do_free(); frees++; order={order,"F"}; endfunction
    protected virtual function void do_record_field(string name,uvm_bitstream_t value,
                                                           int size,uvm_radix_enum radix);
    endfunction
    protected virtual function void do_record_field_int(string name,uvm_integral_t value,
                                                               int size,uvm_radix_enum radix);
    endfunction
    protected virtual function void do_record_field_real(string name,real value); endfunction
    protected virtual function void do_record_string(string name,string value); endfunction
    protected virtual function void do_record_time(string name,time value); endfunction
    protected virtual function void do_record_generic(string name,string value,string type_name);
    endfunction

    protected virtual function void do_record_object(string name,uvm_object value);
      object_calls++; object_name=name; object_value=value; order={order,"H"};
      super.do_record_object(name,value);
    endfunction
  endclass
  class local_stream extends uvm_tr_stream;
    uvm_recorder candidate;
    function new(string name); super.new(name); endfunction
    protected virtual function void do_open(uvm_tr_database db,string scope,
                                            string stream_type_name);
    endfunction
    protected virtual function void do_close(); endfunction
    protected virtual function void do_free(); endfunction
    protected virtual function uvm_recorder do_open_recorder(string name,time open_time,
                                                           string type_name);
      uvm_recorder result=candidate; candidate=null; return result;
    endfunction
  endclass
  class local_database extends uvm_tr_database;
    protected virtual function bit do_open_db(); return 1; endfunction
    protected virtual function bit do_close_db(); return 1; endfunction
    protected virtual function uvm_tr_stream do_open_stream(string name,string scope,
                                                          string type_name);
      local_stream result=new(name); return result;
    endfunction
    protected virtual function void do_establish_link(uvm_link_base link); endfunction
  endclass
  function automatic local_stream make_stream();
    local_database db=new();
    local_stream value;
    if (!db.open_db() || !$cast(value,db.open_stream("stream"))) $fatal(1,"missing stream");
    return value;
  endfunction
  initial begin
    automatic local_recorder selected=new();
    automatic local_recorder peer=new();
    automatic uvm_policy view=selected;
    $display("UT: recorder_defaults recursion %0d id %0d radix %0d base %0d",
             selected.get_recursion_policy()==UVM_DEFAULT_POLICY,selected.get_id_enabled()==1,
             selected.get_default_radix()==UVM_HEX,view==selected);
    selected.set_recursion_policy(UVM_SHALLOW); selected.set_id_enabled(0);
    selected.set_default_radix(UVM_DEC);
    $display("UT: recorder_changed recursion %0d id %0d radix %0d peer %0d",
             selected.get_recursion_policy()==UVM_SHALLOW,selected.get_id_enabled()==0,
             selected.get_default_radix()==UVM_DEC,
             peer.get_recursion_policy()==UVM_DEFAULT_POLICY && peer.get_id_enabled()==1 &&
             peer.get_default_radix()==UVM_HEX);
    selected.flush();
    $display("UT: recorder_flushed recursion %0d id %0d radix %0d",
             selected.get_recursion_policy()==UVM_DEFAULT_POLICY,selected.get_id_enabled()==1,
             selected.get_default_radix()==UVM_HEX);
    $finish;
  end
endmodule
