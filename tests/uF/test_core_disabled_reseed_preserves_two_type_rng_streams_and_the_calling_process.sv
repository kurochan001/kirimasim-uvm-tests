/*
:name: test_core_disabled_reseed_preserves_two_type_rng_streams_and_the_calling_process
:description: Disabling seeding through the core preserves object and caller RNG state
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.4.1.4.26 F.4.1.4.25 5.3.3.3 5.3.3.1 1800-2023 6.21 8.20 8.21 13.5.2 18.13.3 18.13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_core_disabled_reseed_preserves_two_type_rng_streams_and_the_calling_process.expected
*/
// No random number, serialized state format or backend seed encoding is fixed.
module test_core_disabled_reseed_preserves_two_type_rng_streams_and_the_calling_process;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class first_item extends uvm_object;
    `uvm_object_utils(first_item)
    rand bit [31:0] payload;
    function new(string name="first64"); super.new(name); endfunction
  endclass
  class second_item extends uvm_object;
    `uvm_object_utils(second_item)
    rand bit [31:0] payload;
    function new(string name="second64"); super.new(name); endfunction
  endclass
  initial begin
    automatic uvm_coreservice_t service=uvm_coreservice_t::get();
    automatic bit saved=service.get_uvm_seeding();
    automatic first_item first=new("one64"), reference_first=new("reference_one64");
    automatic second_item second=new("two64"), reference_second=new("reference_two64");
    automatic process caller=process::self();
    string first_before,second_before,caller_before;
    automatic bit success=1, same_values=1;
    service.set_uvm_seeding(0);
    first.srandom(197); reference_first.srandom(197);
    second.srandom(293); reference_second.srandom(293);
    first.set_name("renamed_one64"); second.set_name("renamed_two64");
    first_before=first.get_randstate(); second_before=second.get_randstate();
    caller_before=caller.get_randstate();
    first.reseed(); second.reseed(); first.reseed(); second.reseed();
    $display("UT: disabled_core_rng first %0d second %0d caller %0d disabled %0d",
      first.get_randstate()==first_before,second.get_randstate()==second_before,
      caller.get_randstate()==caller_before,!service.get_uvm_seeding());
    repeat (3) begin
      success &= first.randomize() && reference_first.randomize();
      success &= second.randomize() && reference_second.randomize();
      same_values &= first.payload==reference_first.payload;
      same_values &= second.payload==reference_second.payload;
    end
    $display("UT: disabled_core_stream success %0d exact %0d",success,same_values);
    service.set_uvm_seeding(saved);
    $display("UT: disabled_core_restore %0d",service.get_uvm_seeding()==saved);
    $finish;
  end
endmodule
