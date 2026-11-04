/*
:name: test_config_db_omitted_type_matches_int_without_merging_string_settings
:description: config db omitted type matches int without merging string settings
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.4.2.1 C.4.2 C.4.2.2.1 C.4.2.2.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_config_db_omitted_type_matches_int_without_merging_string_settings.expected
*/
module test_config_db_omitted_type_matches_int_without_merging_string_settings;
  import uvm_pkg::*;
  initial begin
    int first,second;
    string text;
    bit found_first,found_second,found_text;
    uvm_config_db#()::set(null,"scope62","slot62",29);
    uvm_config_db#(string)::set(null,"scope62","slot62","separate62");
    found_first=uvm_config_db#(int)::get(null,"scope62","slot62",first);
    uvm_config_db#(int)::set(null,"scope62","slot62",37);
    found_second=uvm_config_db#()::get(null,"scope62","slot62",second);
    found_text=uvm_config_db#(string)::get(null,"scope62","slot62",text);
    $display("UT: config_default integer_shared %0d string_separate %0d",
      found_first && first==29 && found_second && second==37,
      found_text && text=="separate62");
    $finish;
  end
endmodule
