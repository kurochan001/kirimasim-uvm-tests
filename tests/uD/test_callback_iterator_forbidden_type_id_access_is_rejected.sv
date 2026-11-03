/*
:name: test_callback_iterator_forbidden_type_id_access_is_rejected
:description: callback iterator forbidden type id access is rejected
:tags: uD uvm
:type: elaboration
:lrm: 1800.2-2020 D.1.1 8.2.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the callback iterator shall not declare type_id
:expected_stderr_regex: (?i)(?=.*(?:not found|cannot find|can't find|unknown|missing|no (?:such )?(?:member|type)|does not exist))(?=.*\btype_id\b).*
*/
module test_callback_iterator_forbidden_type_id_access_is_rejected;
  import uvm_pkg::*;
  initial begin
    uvm_object_wrapper illegal;
    illegal=uvm_callback_iter#()::type_id::get();
  end
endmodule
