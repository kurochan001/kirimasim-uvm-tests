uvm_phase stable91;
uvm_wait_op operations91[6];
uvm_phase_state threshold91;
bit returned91[6];
time returned_at91[6];
function automatic bit comparison91(uvm_phase_state value,uvm_phase_state threshold,uvm_wait_op op);
  case (op)
    UVM_EQ:return value==threshold;
    UVM_NE:return value!=threshold;
    UVM_LT:return value<threshold;
    UVM_LTE:return value<=threshold;
    UVM_GT:return value>threshold;
    UVM_GTE:return value>=threshold;
    default:return 0;
  endcase
endfunction
initial begin
  automatic uvm_phase peer=new("peer91",UVM_PHASE_IMP);
  uvm_phase_state initial_state;
  string labels[6];
  stable91=new("stable91",UVM_PHASE_IMP); initial_state=stable91.get_state();
  threshold91=MODE==0 ? initial_state : UVM_PHASE_DONE;
  operations91='{UVM_EQ,UVM_NE,UVM_LT,UVM_LTE,UVM_GT,UVM_GTE};
  labels='{"eq","ne","lt","lte","gt","gte"};
  for (int i=0;i<6;i++) begin
    automatic int slot=i;
    fork
      begin
        stable91.wait_for_state(threshold91,operations91[slot]);
        returned91[slot]=1; returned_at91[slot]=$time;
      end
    join_none
  end
  #1;
  foreach (operations91[i])
    $display("UT: wait_ops91 %s %s predicate %0d immediate %0d",CASE_NAME,labels[i],
      returned91[i]==comparison91(initial_state,threshold91,operations91[i]),
      !returned91[i] || returned_at91[i]==0);
  $display("UT: wait_ops91 unchanged %0d peer %0d",stable91.get_state()==initial_state &&
    initial_state==UVM_PHASE_UNINITIALIZED,peer.get_state()==UVM_PHASE_UNINITIALIZED);
  disable fork;
  $finish;
end
