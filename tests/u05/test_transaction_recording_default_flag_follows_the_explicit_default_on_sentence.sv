/*
:name: test_transaction_recording_default_flag_follows_the_explicit_default_on_sentence
:description: Qualified literal reading of the transaction recording default-on sentence
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.4.2.9 5.4.2.11 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_transaction_recording_default_flag_follows_the_explicit_default_on_sentence.expected
*/
module test_transaction_recording_default_flag_follows_the_explicit_default_on_sentence;
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
  initial begin
    transaction_type value;
    value=new();
    $display("UT: recording_default enabled %0d",value.is_recording_enabled());
    $finish;
  end
  initial begin #100; $fatal(1,"base-class fixture watchdog expired"); end
endmodule
