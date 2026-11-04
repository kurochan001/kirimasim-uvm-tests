/*
:name: test_port_base_virtual_declaration_rejects_direct_construction
:description: The default-specialization port base cannot be directly constructed
:tags: u05 uvm
:type: elaboration
:lrm: 1800.2-2020 5.5.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: direct construction of the virtual port base is illegal
:expected_stderr_regex: (?i)^(?=.*test_port_base_virtual_declaration_rejects_direct_construction\.sv:[0-9]+:[0-9]+:)(?=.*\b(?:virtual|abstract)\b)(?=.*\buvm_port_base\b).*error
*/
module test_port_base_virtual_declaration_rejects_direct_construction;
  import uvm_pkg::*;
  initial begin
    uvm_port_base#() illegal_value;
    illegal_value=new("illegal61",null,UVM_PORT);
    $finish;
  end
  initial begin #100; $fatal(1,"base hook fixture watchdog expired"); end
endmodule
