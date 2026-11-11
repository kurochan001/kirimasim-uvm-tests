/*
:name: test_tlm2_payload_response_status_predicates_follow_explicit_status
:description: generic payload response predicates distinguish OK from incomplete and error statuses (IEEE 1800.2-2020 Section 12.3.4.2.36)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.2.36 12.3.4.2.37 12.3.4.2.38 12.3.4.2.39 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_payload_response_status_predicates_follow_explicit_status.expected
*/
// What it checks:
// 1. The response-status getter returns the assigned standard enum.
// 2. The response-OK predicate is true only for OK_RESPONSE.
// 3. The response-error predicate is true for a non-OK response status.
// 4. The public setter specifies the selected payload response status.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.3.4.2.36 (UVM-GP-RESPONSE-STATUS-STATE) gives rule 1
//    above. Setup: Assign OK, INCOMPLETE and ADDRESS_ERROR statuses. Expected:
//    Each getter result equals the assigned enum.
// 2. 1800.2-2020 12.3.4.2.38 (UVM-GP-RESPONSE-OK-PREDICATE) gives rule 2
//    above. Setup: Inspect explicit successful, incomplete and error states.
//    Expected: Only the successful status reports OK.
// 3. 1800.2-2020 12.3.4.2.39 (UVM-GP-RESPONSE-ERROR-PREDICATE) gives rule 3
//    above. Setup: Inspect successful, incomplete and address-error states.
//    Expected: Incomplete and address-error report error while OK does not.
// 4. 1800.2-2020 12.3.4.2.37 (UVM-PAYLOAD-SET-RESPONSE-STATUS-EXPLICIT-UPDATE)
//    gives rule 4 above. Setup: An unchanged accessor fixture assigns explicit
//    values and reads them back through public methods. Expected: OK,
//    INCOMPLETE and ADDRESS_ERROR statuses read back with their selected
//    status predicates.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Assign only standard status values and compare enumeration identity.
// The response string representation is not prescribed by this test.

module test_tlm2_payload_response_status_predicates_follow_explicit_status;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_tlm_generic_payload payload = new("payload");
    payload.set_response_status(UVM_TLM_OK_RESPONSE);
    $display("UT: ok status_same %0d ok %0d error %0d",
        payload.get_response_status() == UVM_TLM_OK_RESPONSE,
             payload.is_response_ok(), payload.is_response_error());
    payload.set_response_status(UVM_TLM_INCOMPLETE_RESPONSE);
    $display("UT: incomplete status_same %0d ok %0d error %0d",
        payload.get_response_status() == UVM_TLM_INCOMPLETE_RESPONSE,
             payload.is_response_ok(), payload.is_response_error());
    payload.set_response_status(UVM_TLM_ADDRESS_ERROR_RESPONSE);
    $display("UT: address_error status_same %0d ok %0d error %0d",
        payload.get_response_status() == UVM_TLM_ADDRESS_ERROR_RESPONSE,
             payload.is_response_ok(), payload.is_response_error());
    $finish;
  end
endmodule
