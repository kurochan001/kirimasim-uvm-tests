/*
:name: test_recorder_concrete_subclass_must_implement_do_record_field_real
:description: recorder rejects the selected illegal declaration
:tags: u16 uvm
:type: elaboration
:lrm: 1800.2-2020 16.4.7.6 16.4.1 1800-2023 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the virtual or incomplete recorder cannot be constructed
:expected_stderr_regex: (?i)^(?=.*test_recorder_concrete_subclass_must_implement_do_record_field_real\.sv:[0-9]+:[0-9]+:)(?=.*\b(?:pure|virtual|abstract|missing implementation)\b)(?=.*\bdo_record_field_real\b).*error
*/
// What it checks:
// A concrete recorder must implement the pure do_record_field_real hook.
//
// How the expected output follows from the standard:
// 1800.2-2020 16.4.7.6
// (UVM-POLICY-AUDIT-RECORDER-ILLEGAL-DO-RECORD-FIELD-REAL) gives the rule
// above. Setup: Use the selected original fixtures, explicit arguments and
// stage observations in the linked anchors; each fresh policy and peer is
// independently constructed. Expected: Compile rejects the targeted abstract
// construction or isolated missing hook with the declared diagnostic; no
// runtime seeds execute.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_recorder_concrete_subclass_must_implement_do_record_field_real;
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
    protected virtual function void do_record_string(string name,string value); endfunction
    protected virtual function void do_record_time(string name,time value); endfunction
    protected virtual function void do_record_generic(string name,string value,string type_name);
    endfunction
  endclass
  initial begin
    incomplete_recorder illegal_value;
    illegal_value=new();
  end
endmodule
