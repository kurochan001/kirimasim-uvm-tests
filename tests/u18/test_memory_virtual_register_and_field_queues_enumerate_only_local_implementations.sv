/*
:name: test_memory_virtual_register_and_field_queues_enumerate_only_local_implementations
:description: Memory queue APIs return all local virtual registers and fields without relying on enumeration order
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6.4.11 18.6.4.12 18.9.1.1.2 18.10.2.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_virtual_register_and_field_queues_enumerate_only_local_implementations.expected
*/
module test_memory_virtual_register_and_field_queues_enumerate_only_local_implementations;
  import uvm_pkg::*;

  class block_type extends uvm_reg_block;
    function new(string name="owner56"); super.new(name,UVM_NO_COVERAGE); endfunction
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

    uvm_vreg regs[$]; uvm_vreg_field fields[$];
    automatic int alpha_count=0,beta_count=0,low_count=0,high_count=0,flag_count=0;
    automatic bit local_regs=1,local_fields=1;

    owner.configure(); memory.configure(owner); peer.configure(owner);
    alpha.configure(owner,memory,2,2,2); beta.configure(owner,memory,2,12,1);
    foreign_reg.configure(owner,peer,2,2,1); unimplemented.configure(owner);
    low.configure(alpha,8,0); high.configure(alpha,8,8); flag.configure(beta,1,0);
    foreign_field.configure(foreign_reg,1,0);

    memory.get_virtual_registers(regs); memory.get_virtual_fields(fields);
    foreach (regs[i]) begin
      alpha_count+=regs[i]==alpha; beta_count+=regs[i]==beta;
      local_regs &= regs[i]==alpha || regs[i]==beta;
    end
    foreach (fields[i]) begin
      low_count+=fields[i]==low; high_count+=fields[i]==high; flag_count+=fields[i]==flag;
      local_fields &= fields[i]==low || fields[i]==high || fields[i]==flag;
    end
    $display("UT: local_registers size %0d exact %0d unrelated_absent %0d",regs.size(),
      alpha_count==1 && beta_count==1,local_regs);
    $display("UT: local_fields size %0d exact %0d unrelated_absent %0d",fields.size(),
      low_count==1 && high_count==1 && flag_count==1,local_fields);
    $finish;
  end
endmodule
