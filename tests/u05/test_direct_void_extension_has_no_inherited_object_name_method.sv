/*
:name: test_direct_void_extension_has_no_inherited_object_name_method
:description: A direct void extension has none of the object identification methods
:tags: u05 uvm
:type: elaboration
:lrm: 1800.2-2020 5.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: uvm_void does not provide the object get_name member
:expected_stderr_regex: (?i)^(?=.*test_direct_void_extension_has_no_inherited_object_name_method\.sv:[0-9]+:[0-9]+:)(?=.*\bget_name\b)(?=.*(?:not found|can't find|no member|does not exist|unknown)).*error
*/
module test_direct_void_extension_has_no_inherited_object_name_method;
  import uvm_pkg::*;
  class plain_extension extends uvm_void; endclass
  initial begin
    plain_extension value;
    string illegal_name;
    value=new(); illegal_name=value.get_name();
    $finish;
  end
  initial begin #100; $fatal(1,"base-class fixture watchdog expired"); end
endmodule
