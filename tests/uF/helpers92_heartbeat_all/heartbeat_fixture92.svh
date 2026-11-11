// Original activity-window stimulus; do not infer severity or recovery.
class participant92 extends uvm_component;
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
endclass
class observer92 extends uvm_report_catcher;
  function new();
    super.new("observer92");
  endfunction
  virtual function action_e catch();
    if (get_severity()!=UVM_INFO) begin
      $display("HB92_DIAG severity %0d id %s message %s",get_severity(),get_id(),get_message());
      $display("UT: heartbeat92 unexpected_report 1");
      // End at the first report; no post-fatal continuation is assumed.
      $finish;
      return CAUGHT;
    end
    return THROW;
  endfunction
endclass
class t extends uvm_test;
  `uvm_component_utils(t)
  participant92 actor_a,actor_b,outsider;
  uvm_heartbeat first,peer;
  uvm_objection sync;
  uvm_event#(uvm_object) tick;
  observer92 observer;
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    actor_a=new("actor_a",this);
    actor_b=new("actor_b",this);
    outsider=new("outsider",this);
    sync=new("sync");
    tick=new("tick");
    first=new("first",this,sync);
    peer=new("peer",this,sync);
    observer=new();
  endfunction
  function void participate(uvm_component actor,int count=1);
    sync.raise_objection(actor,"original activity",count);
    sync.drop_objection(actor,"original activity",count);
  endfunction
  function bit counts_zero();
    return sync.get_objection_count(actor_a)==0 && sync.get_objection_count(actor_b)==0 && sync.get_objection_count(outsider)==0;
  endfunction
  task run_phase(uvm_phase phase);
    uvm_component actors[$];
    uvm_heartbeat_modes ignored;
    phase.raise_objection(this);
    if(VARIANT==0) begin
      actors.push_back(actor_a);
      actors.push_back(actor_b);
    end
    else begin
      actors.push_back(actor_b);
      actors.push_back(actor_a);
    end
    ignored=peer.set_mode(UVM_ANY_ACTIVE);
    if (HB_KIND==3) ignored=first.set_mode(VARIANT==0?UVM_ALL_ACTIVE:UVM_ONE_ACTIVE);
    else ignored=first.set_mode(SELECT_MODE);
    uvm_report_cb::add(this,observer);
    first.set_heartbeat(tick,actors);
    #1;
    tick.trigger();
    if (HB_KIND==3) begin
      #1;
      participate(actor_a,2);
      if(VARIANT==0) participate(actor_b);
      #1;
      tick.trigger();
      #1;
`ifdef STOP_CONTROL92
      first.stop();
`else
      ignored=first.set_mode(UVM_NO_HB_MODE);
      $display("UT: heartbeat92 disabled_selected %0d",first.set_mode()==UVM_NO_HB_MODE);
`endif
      for (int i=0;i<2;i++) begin
        #1;
        tick.trigger();
        #1;
        $display("UT: heartbeat92 %s idle_window %0d quiet 1 counts_zero %0d",CASE_NAME,i,counts_zero());
      end
    end else begin
      $display("UT: heartbeat92 selected %0d",first.set_mode()==SELECT_MODE);
      for(int i=0;i<3;i++) begin
        #1;
        if(HB_KIND==0) begin
          if(VARIANT==0) begin
            participate(actor_a,2);
            participate(actor_b);
          end
          else begin
            participate(actor_b,3);
            participate(actor_a);
          end
        end
        if(HB_KIND==1) begin
          if((i+VARIANT)%2==0) participate(actor_a,2);
          else participate(actor_b,3);
        end
        if(HB_KIND==2) begin
          if((i+VARIANT)%3!=1) participate(actor_a,2);
          if((i+VARIANT)%3!=0) participate(actor_b,3);
        end
        participate(outsider,4);
        #1;
        tick.trigger();
        #1;
        $display("UT: heartbeat92 %s window %0d quiet 1 counts_zero %0d",CASE_NAME,i,counts_zero());
      end
    end
    first.stop();
    $display("UT: heartbeat92 peer_mode %0d",peer.set_mode()==UVM_ANY_ACTIVE);
    uvm_report_cb::delete(this,observer);
    phase.drop_objection(this);
  endtask
endclass
initial run_test("t");
