/*
:name: test_recorder_concrete_subclass_must_implement_do_record_generic
:description: recorder rejects the selected illegal declaration
:tags: u16 uvm
:type: elaboration
:lrm: 1800.2-2020 16.4.7.11 16.4.1 1800-2023 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the virtual or incomplete recorder cannot be constructed
:expected_stderr_regex: (?i)^(?=.*test_recorder_concrete_subclass_must_implement_do_record_generic\.sv:[0-9]+:[0-9]+:)(?=.*\b(?:pure|virtual|abstract|missing implementation)\b)(?=.*\bdo_record_generic\b).*error
*/
module test_recorder_concrete_subclass_must_implement_do_record_generic;
  import uvm_pkg::*;
  class incomplete_recorder extends uvm_recorder;
    protected virtual function void do_open(uvm_tr_stream stream,time open_time,string type_name);
    endfunction
    protected virtual function void do_close(time close_time); endfunction
    protected virtual function void do_free(); endfunction
    protected virtual function void do_record_field(string name,uvm_bitstream_t value,
                                                           int size,uvm_radix_enum radix);
    endfunction
    protected virtual function void do_record_field_int(string name,uvm_integral_t value,
                                                               int size,uvm_radix_enum radix);
    endfunction
    protected virtual function void do_record_field_real(string name,real value); endfunction
    protected virtual function void do_record_string(string name,string value); endfunction
    protected virtual function void do_record_time(string name,time value); endfunction
  endclass
  initial begin
    incomplete_recorder illegal_value;
    illegal_value=new();
  end
endmodule
