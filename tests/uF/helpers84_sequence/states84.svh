// Original hooks observe the actual UVM sequence state; no state is assigned.
class state_sequence84 extends uvm_sequence#(uvm_sequence_item);
  int hits[5], kills, body_writes;
  bit hooks_ok, in_body, check_normal_post;
  int unsigned seen;
  time post_pause;
  function new(string name="state84");
    super.new(name);
    prepare84();
  endfunction
  function void prepare84();
    foreach(hits[i]) hits[i]=0;
    kills=0;
    body_writes=0;
    hooks_ok=1;
    in_body=0;
    seen=0;
    check_normal_post=1;
    post_pause=2;
  endfunction
  function void observe84(int slot,uvm_sequence_state_enum wanted);
    hits[slot]++;
    hooks_ok &= get_sequence_state()==wanted;
    seen |= int'(get_sequence_state());
  endfunction
  virtual task pre_start();
    observe84(0,UVM_PRE_START);
    #1;
  endtask
  virtual task pre_body();
    observe84(1,UVM_PRE_BODY);
    #1;
  endtask
  virtual task body();
    observe84(2,UVM_BODY);
    in_body=1;
    #4;
    body_writes++;
    in_body=0;
  endtask
  virtual task post_body();
    if(check_normal_post) observe84(3,UVM_POST_BODY);
    else hits[3]++;
    if(post_pause!=0) #post_pause;
  endtask
  virtual task post_start();
    if(check_normal_post) observe84(4,UVM_POST_START);
    else hits[4]++;
  endtask
  virtual function void do_kill();
    kills++;
  endfunction
endclass
