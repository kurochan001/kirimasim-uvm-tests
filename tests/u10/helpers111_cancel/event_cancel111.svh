// Original same-event reuse and independent-peer cancellation fixture.
typedef uvm_event#(int) event111;
task automatic selected_wait111(input event111 subject);
  case (STYLE111)
    0: subject.wait_trigger();
    1: subject.wait_ptrigger();
    2: subject.wait_on();
    3: subject.wait_off();
  endcase
endtask
function automatic void prepare111(input event111 subject);
  if (STYLE111==3) subject.trigger(91);
  else subject.reset();
endfunction
function automatic void release111(input event111 subject);
  if (STYLE111==3) subject.reset();
  else subject.trigger(43);
endfunction
task automatic exercise111();
  automatic event111 subject=new("subject");
  automatic event111 peer=new("peer");
  automatic bit [2:0] returned=0;
  automatic bit peer_returned=0;
  automatic int round=0;
  process waiting[3];
  $display("UT: initial subject %0d peer %0d",
           subject.get_num_waiters(),peer.get_num_waiters());
  prepare111(peer);
  #1;
  fork
    begin
      selected_wait111(peer);
      peer_returned=1;
    end
  join_none
  #1;
  $display("UT: peer armed %0d waiters %0d",!peer_returned,peer.get_num_waiters());
  for (round=1;round<=2;round++) begin
    prepare111(subject);
    #1;
    returned=0;
    fork
      begin
        waiting[0]=process::self();
        selected_wait111(subject);
        returned[0]=1;
      end
      begin
        waiting[1]=process::self();
        selected_wait111(subject);
        returned[1]=1;
      end
      begin
        waiting[2]=process::self();
        selected_wait111(subject);
        returned[2]=1;
      end
    join_none
    #1;
    if (waiting[0]==null || waiting[1]==null || waiting[2]==null)
      $fatal(1,"event111 missing process handle");
    $display("UT: round %0d armed blocked %0d waiters %0d peer %0d",round,
             returned==0,subject.get_num_waiters(),!peer_returned && peer.get_num_waiters()==1);
    // Query only after the explicit kill/cancel pair, never between them.
    waiting[0].kill();
    subject.cancel();
    #1;
    $display("UT: round %0d cancel_first waiters %0d blocked %0d killed %0d peer %0d",
             round,subject.get_num_waiters(),returned==0,
             waiting[0].status()==process::KILLED,!peer_returned && peer.get_num_waiters()==1);
    waiting[1].kill();
    subject.cancel();
    #1;
    $display("UT: round %0d cancel_second waiters %0d blocked %0d killed %0d peer %0d",
             round,subject.get_num_waiters(),returned==0,
             waiting[0].status()==process::KILLED && waiting[1].status()==process::KILLED,
             !peer_returned && peer.get_num_waiters()==1);
    release111(subject);
    #1;
    $display("UT: round %0d released survivor %0d victims %0d waiters %0d peer %0d",
             round,returned[2],returned[1:0]==0,subject.get_num_waiters(),
             !peer_returned && peer.get_num_waiters()==1);
  end
  $display("UT: peer retained %0d waiters %0d",!peer_returned,peer.get_num_waiters());
  release111(peer);
  #1;
  $display("UT: peer released %0d waiters %0d",peer_returned,peer.get_num_waiters());
endtask
