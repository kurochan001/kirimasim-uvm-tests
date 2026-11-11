bit final_seen88=0,returned88=0,user_finish88=0;
class finish_test88 extends uvm_test;
  `uvm_component_utils(finish_test88)
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    #3;
    phase.drop_objection(this);
  endtask
  virtual function void final_phase(uvm_phase phase);
    final_seen88=1;
  endfunction
endclass
initial begin
  automatic uvm_root root=uvm_root::get();
  if (MODE==0) begin
    $display("UT: finish88 default %0d",root.get_finish_on_completion()==1);
    root.set_finish_on_completion(0);
    $display("UT: finish88 latest_zero %0d",root.get_finish_on_completion()==0);
    root.set_finish_on_completion(1);
    $display("UT: finish88 latest_one %0d",root.get_finish_on_completion()==1);
    root.set_finish_on_completion(0);
    root.set_finish_on_completion(0);
    $display("UT: finish88 repeated_zero %0d",root.get_finish_on_completion()==0);
    $finish;
  end else begin
    if (MODE==2) begin
      root.set_finish_on_completion(0);
      root.set_finish_on_completion(1);
    end
    if (MODE==3) root.set_finish_on_completion(0);
    $display("UT: finish88 %s selected %0d",CASE_NAME,
      root.get_finish_on_completion()==(MODE!=3));
    run_test("finish_test88");
    returned88=1;
    $display("UT: finish88 returned_after_final %0d selected_zero %0d",final_seen88,
      root.get_finish_on_completion()==0);
    #2;
    user_finish88=1;
    $display("UT: finish88 user_termination %0d",user_finish88);
    $finish;
  end
end
final begin
  if (MODE!=0) $display("UT: finish88 final phase %0d returned %0d user_finish %0d",
    final_seen88,returned88,user_finish88);
end
