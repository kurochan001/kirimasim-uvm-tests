/*
:name: test_memory_virtual_name_lookup_preserves_handles_and_isolates_other_memories
:description: Memory-local virtual names return exact handles or null for absent, foreign and unimplemented entries
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6.4.13 18.6.4.14 18.9.1.1.2 18.10.2.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_virtual_name_lookup_preserves_handles_and_isolates_other_memories.expected
*/
module test_memory_virtual_name_lookup_preserves_handles_and_isolates_other_memories;
  import uvm_pkg::*;

  class block_type extends uvm_reg_block;
    function new(string name="owner56"); super.new(name,UVM_NO_COVERAGE); endfunction
  endclass

  class quiet_probe extends uvm_report_catcher;
    virtual function action_e catch();
      if (get_severity() inside {UVM_WARNING,UVM_ERROR}) return CAUGHT;
      return THROW;
    endfunction
  endclass
  initial begin

    automatic block_type owner=new();
    automatic uvm_mem memory=new("memory56",64,8);
    automatic uvm_mem peer=new("peer56",64,8);
    automatic uvm_vreg alpha=new("alpha56",16);
    automatic uvm_vreg beta=new("beta56",8);
    automatic uvm_vreg foreign_reg=new("foreign56",8);
    automatic uvm_vreg unimplemented=new("unimplemented56",8);
    automatic uvm_vreg_field low=new("low56");
    automatic uvm_vreg_field high=new("high56");
    automatic uvm_vreg_field flag=new("flag56");
    automatic uvm_vreg_field foreign_field=new("foreign_field56");

    automatic quiet_probe quiet=new();
    uvm_report_cb::add(null,quiet);

    owner.configure(); memory.configure(owner); peer.configure(owner);
    alpha.configure(owner,memory,2,2,2); beta.configure(owner,memory,2,12,1);
    foreign_reg.configure(owner,peer,2,2,1); unimplemented.configure(owner);
    low.configure(alpha,8,0); high.configure(alpha,8,8); flag.configure(beta,1,0);
    foreign_field.configure(foreign_reg,1,0);

    $display("UT: register_lookup alpha %0d beta %0d absent %0d foreign %0d pending %0d",
      memory.get_vreg_by_name("alpha56")==alpha,memory.get_vreg_by_name("beta56")==beta,
      memory.get_vreg_by_name("absent56")==null,memory.get_vreg_by_name("foreign56")==null,
      memory.get_vreg_by_name("unimplemented56")==null);
    $display("UT: field_lookup low %0d high %0d flag %0d absent %0d foreign %0d",
      memory.get_vfield_by_name("low56")==low,memory.get_vfield_by_name("high56")==high,
      memory.get_vfield_by_name("flag56")==flag,memory.get_vfield_by_name("absent56")==null,
      memory.get_vfield_by_name("foreign_field56")==null);
    $finish;
  end
endmodule
