/*
:name: test_recorder_flush_frees_an_open_record_through_close_before_free_without_releasing_peer
:description: recorder flush frees an open record through close before free without releasing peer
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.4.4.1 16.4.4.2 16.4.4.3 16.4.7.2 16.4.7.3 16.4.5.1 16.4.5.2 7.2.5.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_recorder_flush_frees_an_open_record_through_close_before_free_without_releasing_peer.expected
*/
module test_recorder_flush_frees_an_open_record_through_close_before_free_without_releasing_peer;
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
    automatic local_stream stream=make_stream();
    automatic local_recorder selected=new("selected");
    automatic local_recorder peer=new("peer");
    uvm_recorder result;
    int selected_handle,peer_handle;
    stream.candidate=selected; result=stream.open_recorder("selected",17,"packet");
    stream.candidate=peer; result=stream.open_recorder("peer",23,"packet");
    selected_handle=selected.get_handle(); peer_handle=peer.get_handle();
    order=""; selected.flush();
    $display("UT: recorder_flush_hooks order %s close %0d free %0d freed %0d peer_open %0d",
             order,selected.closes,selected.frees,selected.get_handle()==0,peer.is_open());
    $display("UT: recorder_flush_handles selected %0d peer %0d",
             uvm_recorder::get_recorder_from_handle(selected_handle)!=null,
             uvm_recorder::get_recorder_from_handle(peer_handle)==peer);
    peer.free(); stream.close(); stream.free(); $finish;
  end
endmodule
