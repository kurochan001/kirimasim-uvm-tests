/*
:name: test_block_backdoor_selection_drives_real_register_poke_peek_with_debug_and_failure_controls
:description: block backdoor selection drives real register poke peek with debug and failure controls
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.1.6.3 18.1.6.2 18.4.6.1 18.4.6.2 18.4.4.11 18.4.4.12 19.5.2.2 19.5.2.3 19.5.2.4 19.5.2.5 19.5.2.6 19.5.2.7 19.1.1.2.2 19.1.1.2.4 19.1.1.2.6 18.1.2.2 18.4.2.2 18.5.3.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_block_backdoor_selection_drives_real_register_poke_peek_with_debug_and_failure_controls.expected
*/
// Original user storage. No physical HDL access or failed-read data oracle.
module test_block_backdoor_selection_drives_real_register_poke_peek_with_debug_and_failure_controls;
  import uvm_pkg::*;
class block_type extends uvm_reg_block;
  function new(string name="",int available=UVM_NO_COVERAGE);
    super.new(name,available);
  endfunction
endclass

class register_type extends uvm_reg;
  function new(string name); super.new(name,32,UVM_NO_COVERAGE); endfunction
endclass
class storage_backdoor extends uvm_reg_backdoor;
  uvm_reg_data_t words[string];
  bit reject=0;
  int writes=0,reads=0;
  function new(string name); super.new(name); endfunction
  virtual task write(uvm_reg_item rw);
    do_pre_write(rw);
    writes++;
    #1;
    if (!reject) words[rw.get_element().get_full_name()]=rw.get_value(0);
    rw.set_status(reject ? UVM_NOT_OK : UVM_IS_OK);
    do_post_write(rw);
  endtask
  virtual task read(uvm_reg_item rw);
    do_pre_read(rw);
    reads++;
    #1;
    if (!reject) rw.set_value(words[rw.get_element().get_full_name()]);
    rw.set_status(reject ? UVM_NOT_OK : UVM_IS_OK);
    do_post_read(rw);
  endtask
endclass
function automatic register_type reg_in(block_type owner,string name);
  register_type r=new(name);
  uvm_reg_field f=new("bits50");
  r.configure(owner); f.configure(r,32,0,"RW",0,0,1,0,0);
  return r;
endfunction
initial begin
  automatic block_type root=new("root50");
  automatic block_type child=new("child50");
  automatic block_type other=new("other50");
  automatic storage_backdoor ancestor=new("ancestor50");
  automatic storage_backdoor branch=new("branch50");
  automatic storage_backdoor direct=new("direct50");
  register_type local_reg,child_reg,override_reg;
  uvm_status_e status;
  uvm_reg_data_t value;
  bit ok;
  root.configure(); child.configure(root); other.configure(root);
  local_reg=reg_in(root,"local50"); child_reg=reg_in(child,"child_reg50");
  override_reg=reg_in(other,"override50");
  override_reg.set_backdoor(direct);
  root.set_backdoor(ancestor); child.set_backdoor(branch);
  for (int variant=0;variant<2;variant++) begin
    root.set_backdoor(ancestor,variant ? "debug_root50" : "",variant ? 950 : 0);
    child.set_backdoor(branch,variant ? "debug_child50" : "",variant ? 951 : 0);
    local_reg.poke(status,'h5011); ok=status==UVM_IS_OK;
    child_reg.poke(status,'h5022); ok &= status==UVM_IS_OK;
    override_reg.poke(status,'h5033); ok &= status==UVM_IS_OK;
    local_reg.peek(status,value); ok &= status==UVM_IS_OK && value=='h5011;
    child_reg.peek(status,value); ok &= status==UVM_IS_OK && value=='h5022;
    override_reg.peek(status,value); ok &= status==UVM_IS_OK && value=='h5033;
    $display("UT: backdoor_access debug %0d status_and_data %0d roots %0d branches %0d direct %0d",
      variant,ok,ancestor.words.num()==1 && ancestor.words[local_reg.get_full_name()]=='h5011,
      branch.words.num()==1 && branch.words[child_reg.get_full_name()]=='h5022,
      direct.words.num()==1 && direct.words[override_reg.get_full_name()]=='h5033);
  end
  branch.reject=1;
  child_reg.poke(status,'h50EE);
  $display("UT: backdoor_access write_failure %0d unchanged %0d peer %0d",
    status==UVM_NOT_OK,branch.words[child_reg.get_full_name()]=='h5022,
    ancestor.words[local_reg.get_full_name()]=='h5011);
  child_reg.peek(status,value);
  $display("UT: backdoor_access read_failure %0d",status==UVM_NOT_OK);
  branch.reject=0; child_reg.poke(status,'h5044); ok=status==UVM_IS_OK;
  child_reg.peek(status,value);
  $display("UT: backdoor_access retry %0d value %0h all_backends_used %0d",
    ok && status==UVM_IS_OK,value,
    ancestor.reads>0 && ancestor.writes>0 && branch.reads>0 && branch.writes>0 &&
    direct.reads>0 && direct.writes>0);
  $finish;
end
endmodule
