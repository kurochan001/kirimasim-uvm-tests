// Original fixture: expectations come from IEEE clauses in each wrapper.
int actual_trace92[$];
int chosen_trace92[$];
int hook_calls92=0;
bit hook_bounds92=1;
class packet92 extends uvm_sequence_item;
  `uvm_object_utils(packet92)
  function new(string name="packet92"); super.new(name); endfunction
endclass
class alpha92 extends uvm_sequence#(packet92);
  `uvm_object_utils(alpha92)
  function new(string name="alpha92"); super.new(name); endfunction
  task body(); actual_trace92.push_back(0); #1; endtask
endclass
class beta92 extends uvm_sequence#(packet92);
  `uvm_object_utils(beta92)
  function new(string name="beta92"); super.new(name); endfunction
  task body(); actual_trace92.push_back(1); #1; endtask
endclass
class library92 extends uvm_sequence_library#(packet92);
  `uvm_object_utils(library92)
  `uvm_sequence_library_utils(library92)
  constraint rand_choice92 { if (LIB_KIND==0) select_rand==VARIANT; }
  function new(string name="library92"); super.new(name); endfunction
  virtual function int unsigned select_sequence(int unsigned max);
    int unsigned idx;
    hook_bounds92 &= (max==1);
    if (VARIANT==0) idx=hook_calls92%2;
    else idx=(hook_calls92%3==0)?0:1;
    hook_calls92++;
    chosen_trace92.push_back(get_sequence(idx)==alpha92::get_type()?0:1);
    return idx;
  endfunction
endclass
class driver92 extends uvm_driver#(packet92);
  int received=0;
  bit nonnull=1;
  function new(string name,uvm_component parent);super.new(name,parent);endfunction
  task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      nonnull &= (req!=null);
      received++;
      seq_item_port.item_done();
    end
  endtask
endclass
class t extends uvm_test;
  `uvm_component_utils(t)
  library92 value;
  uvm_sequencer#(packet92) sequencer,peer_sequencer;
  driver92 driver,peer_driver;
  function new(string name,uvm_component parent);super.new(name,parent);endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    value=new("value");
    sequencer=new("sequencer",this);peer_sequencer=new("peer_sequencer",this);
    driver=new("driver",this);peer_driver=new("peer_driver",this);
    if (VARIANT==0 || LIB_KIND==0) begin value.add_sequence(alpha92::get_type());value.add_sequence(beta92::get_type());end
    else begin value.add_sequence(beta92::get_type());value.add_sequence(alpha92::get_type());end
  endfunction
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
    peer_driver.seq_item_port.connect(peer_sequencer.seq_item_export);
  endfunction
  task run_phase(uvm_phase phase);
    uvm_object_wrapper selected,entries[$];
    bit configured=1,membership=1,trace_ok=1,cyclic_ok=1;
    int alpha_count=0,beta_count=0;
    phase.raise_objection(this);
    value.get_sequences(entries);
    membership=(entries.size()==2);
    foreach(entries[i]) membership &= (entries[i]==alpha92::get_type() || entries[i]==beta92::get_type());
    if (entries.size()==2) membership &= (entries[0]!=entries[1]);
    selected=value.get_sequence(VARIANT);
`ifdef STANDARD_API92
    value.set_selection_mode(SELECT_MODE);
    configured=(value.get_selection_mode()==SELECT_MODE);
`endif
`ifdef LEGACY_MODE92
    // Separate additional premise: this is not a replacement standard API.
    value.selection_mode=SELECT_MODE;
    configured=(value.selection_mode==SELECT_MODE);
`endif
    value.start(sequencer);
    foreach(actual_trace92[i]) begin
      if (actual_trace92[i]==0) alpha_count++;else beta_count++;
      if (LIB_KIND==0) trace_ok &= (actual_trace92[i]==(selected==alpha92::get_type()?0:1));
      if (LIB_KIND==1 && i%2==1) cyclic_ok &= (actual_trace92[i]!=actual_trace92[i-1]);
      if (LIB_KIND==3) begin
        if (i>=chosen_trace92.size()) trace_ok=0;
        else trace_ok &= (actual_trace92[i]==chosen_trace92[i]);
      end
    end
    if (LIB_KIND==0) trace_ok &= (actual_trace92.size()==10 && hook_calls92==0 && driver.received==0);
    if (LIB_KIND==1) trace_ok=(cyclic_ok && alpha_count==5 && beta_count==5 && actual_trace92.size()==10 && hook_calls92==0 && driver.received==0);
    if (LIB_KIND==2) trace_ok=(actual_trace92.size()==0 && hook_calls92==0 && driver.received==10 && driver.nonnull);
    if (LIB_KIND==3) trace_ok &= (actual_trace92.size()==10 && hook_calls92==10 && chosen_trace92.size()==10 && hook_bounds92 && driver.received==0);
    $display("UT: library92 %s configured %0d membership %0d",CASE_NAME,configured,membership);
    $display("UT: library92 selected_effect %0d peer_idle %0d",trace_ok,peer_driver.received==0);
    phase.drop_objection(this);
  endtask
endclass
initial run_test("t");
