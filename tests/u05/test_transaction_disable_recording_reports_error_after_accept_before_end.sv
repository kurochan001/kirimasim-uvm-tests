/*
:name: test_transaction_disable_recording_reports_error_after_accept_before_end
:description: disable recording after accept generates an error without a post-error recovery assertion
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.4.2.10 5.4.2.2 5.4.2.4 6.6.3.2 6.6.5 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_transaction_disable_recording_reports_error_after_accept_before_end.expected
*/
module test_transaction_disable_recording_reports_error_after_accept_before_end;
  import uvm_pkg::*;
  class transaction_type extends uvm_transaction;
    function new(string name="",uvm_component initiator=null);
      super.new(name,initiator);
    endfunction
    virtual function string get_type_name(); return "transaction_type61"; endfunction
    virtual function uvm_object create(string name="");
      transaction_type result;
      result=new(name); return result;
    endfunction
  endclass
  class capture_recorder extends uvm_recorder;
    int objects=0,fields=0;
    uvm_object last_object;
    time opened=0,closed=0;
    uvm_integral_t field_value=0;
    function new(string name); super.new(name); endfunction
    protected virtual function void do_open(uvm_tr_stream stream,time open_time,string type_name);
      opened=open_time;
    endfunction
    protected virtual function void do_close(time close_time); closed=close_time; endfunction
    protected virtual function void do_free(); endfunction
    protected virtual function void do_record_object(string name,uvm_object value);
      objects++; last_object=value;
    endfunction
    protected virtual function void do_record_field(string name,uvm_bitstream_t value,int size,
                                                   uvm_radix_enum radix); endfunction
    protected virtual function void do_record_field_int(string name,uvm_integral_t value,int size,
                                                       uvm_radix_enum radix);
      if (name=="payload61" && size==8 && radix==UVM_HEX) begin
        fields++; field_value=value;
      end
    endfunction
    protected virtual function void do_record_field_real(string name,real value); endfunction
    protected virtual function void do_record_string(string name,string value); endfunction
    protected virtual function void do_record_time(string name,time value); endfunction
    protected virtual function void do_record_generic(string name,string value,string type_name);
    endfunction
  endclass
  class capture_stream extends uvm_tr_stream;
    capture_recorder last;
    int opens=0;
    function new(string name); super.new(name); endfunction
    protected virtual function void do_open(
        uvm_tr_database db,string scope,string stream_type_name);
    endfunction
    protected virtual function void do_close(); endfunction
    protected virtual function void do_free(); endfunction
    protected virtual function uvm_recorder do_open_recorder(
        string name,time open_time,string type_name);
      last=new(name); opens++; return last;
    endfunction
  endclass
  class capture_database extends uvm_tr_database;
    function new(); super.new("database61"); endfunction
    protected virtual function bit do_open_db(); return 1; endfunction
    protected virtual function bit do_close_db(); return 1; endfunction
    protected virtual function uvm_tr_stream do_open_stream(
        string name,string scope,string type_name);
      capture_stream result;
      result=new(name); return result;
    endfunction
    protected virtual function void do_establish_link(uvm_link_base link); endfunction
  endclass
  class reports extends uvm_report_catcher;
    bit gated=0;
    int errors=0;
    virtual function action_e catch();
      if (gated && (get_severity()==UVM_ERROR || get_severity()==UVM_FATAL)) begin
        errors++; return CAUGHT;
      end
      return THROW;
    endfunction
  endclass
  initial begin
    transaction_type value,peer;
    capture_database database;
    capture_stream first_stream,second_stream;
    uvm_tr_stream first_base,second_base;
    int handle_value;
    reports catcher;
    value=new("value61"); peer=new("peer61"); database=new(); catcher=new();
    if (!database.open_db()) $fatal(1,"original database did not open");
    first_base=database.open_stream("first61","scope61","");
    second_base=database.open_stream("second61","scope61","");
    if (!$cast(first_stream,first_base) || !$cast(second_stream,second_base))
      $fatal(1,"original streams missing");
    value.enable_recording(first_base);
    #2; value.accept_tr();
    uvm_report_cb::add(null,catcher); catcher.gated=1;
    #1; value.disable_recording();
    catcher.gated=0;
    $display("UT: recording_interval error %0d",catcher.errors>0);
    uvm_report_cb::delete(null,catcher);
    $finish;
  end
  initial begin #100; $fatal(1,"base-class fixture watchdog expired"); end
endmodule
