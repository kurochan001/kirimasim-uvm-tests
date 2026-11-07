// Original stream writer and first-visit observer; no do_unpack override.
class tag112 extends uvm_tlm_extension#(tag112);
  `uvm_object_utils(tag112)
  int value=63;
  int unpack_calls=0;
  function new(string name="tag112"); super.new(name); endfunction
  virtual function void do_unpack(uvm_packer packer); unpack_calls++; endfunction
endclass
class observed112 extends uvm_tlm_generic_payload;
  bit capture=0;
  bit [8:0] seen=0;
  string first="";
  int calls[9];
  function new(string name="observed112");
    super.new(name); reset_capture(0);
  endfunction
  function void reset_capture(bit enable);
    capture=enable; seen=0; first="";
    foreach(calls[i]) calls[i]=0;
  endfunction
  function void visit112(int index,string field_name);
    if (capture) begin
      calls[index]++;
      if (!seen[index]) begin
        if (first.len()!=0) first={first," "};
        first={first,field_name}; seen[index]=1;
      end
    end
  endfunction
  virtual function void set_address(bit [63:0] addr);
    visit112(0,"address"); super.set_address(addr);
  endfunction
  virtual function void set_command(uvm_tlm_command_e command);
    visit112(1,"command"); super.set_command(command);
  endfunction
  virtual function void set_data_length(int unsigned length);
    visit112(2,"length"); super.set_data_length(length);
  endfunction
  virtual function void set_dmi_allowed(bit dmi);
    visit112(3,"dmi"); super.set_dmi_allowed(dmi);
  endfunction
  virtual function void set_data(ref byte unsigned p[]);
    visit112(4,"data"); super.set_data(p);
  endfunction
  virtual function void set_response_status(uvm_tlm_response_status_e status);
    visit112(5,"response"); super.set_response_status(status);
  endfunction
  virtual function void set_byte_enable_length(int unsigned length);
    visit112(6,"enable_length"); super.set_byte_enable_length(length);
  endfunction
  virtual function void set_byte_enable(ref byte unsigned p[]);
    visit112(7,"enables"); super.set_byte_enable(p);
  endfunction
  virtual function void set_streaming_width(int unsigned width);
    visit112(8,"width"); super.set_streaming_width(width);
  endfunction
endclass
function automatic bit [63:0] address112(int round);
  return 64'h0000_0012_0000_0043+round;
endfunction
function automatic uvm_tlm_command_e command112();
  return EMPTY112 ? UVM_TLM_IGNORE_COMMAND : UVM_TLM_WRITE_COMMAND;
endfunction
function automatic uvm_tlm_response_status_e status112();
  return EMPTY112 ? UVM_TLM_BURST_ERROR_RESPONSE : UVM_TLM_ADDRESS_ERROR_RESPONSE;
endfunction
function automatic int unsigned length112(); return EMPTY112 ? 0 : 3; endfunction
function automatic int unsigned mask_length112(); return EMPTY112 ? 0 : 2; endfunction
function automatic int unsigned width112(); return EMPTY112 ? 0 : 2; endfunction
function automatic byte unsigned data112(int round,int index);
  return 8'h20+round+index;
endfunction
function automatic byte unsigned mask112(int index);
  return index==0 ? 8'hff : 8'h00;
endfunction
function automatic uvm_packer stream112(int round);
  automatic uvm_packer packer=new;
  // Typed public writes follow the independently cited field list.
  // No payload do_pack result or binary byte-order assumption supplies it.
  packer.pack_field_int(address112(round),64);
  packer.pack_field_int(int'(command112()),32);
  packer.pack_field_int(length112(),32);
  packer.pack_field_int(1,1);
  for (int i=0;i<int'(length112());i++) packer.pack_field_int(data112(round,i),8);
  packer.pack_field_int(int'(status112()),32);
  packer.pack_field_int(mask_length112(),32);
  for (int i=0;i<int'(mask_length112());i++) packer.pack_field_int(mask112(i),8);
  packer.pack_field_int(width112(),32);
  return packer;
endfunction
function automatic bit data_ok112(input byte unsigned p[],input int round);
  if (p.size()<length112()) return 0;
  for (int i=0;i<int'(length112());i++) if(p[i]!=data112(round,i)) return 0;
  return 1;
endfunction
function automatic bit mask_ok112(input byte unsigned p[]);
  if (p.size()<mask_length112()) return 0;
  for (int i=0;i<int'(mask_length112());i++) if(p[i]!=mask112(i)) return 0;
  return 1;
endfunction
task automatic exercise112();
  automatic uvm_tlm_generic_payload target;
  automatic observed112 observer;
  automatic tag112 extension_value=new("retained");
  automatic byte unsigned sentinel_data[]='{8'haa};
  automatic byte unsigned sentinel_mask[]='{8'h00};
  uvm_packer packer;
  byte unsigned data[],enables[];
  if (OBSERVE112) begin observer=new("target"); target=observer; end
  else target=new("target");
  void'(target.set_extension(extension_value));
  for (int round=1;round<=2;round++) begin
    if (OBSERVE112) observer.reset_capture(1);
    // Deliberately reverse the nine direct calls to calibrate dispatch.
    target.set_streaming_width(19);
    target.set_byte_enable(sentinel_mask); target.set_byte_enable_length(1);
    target.set_response_status(UVM_TLM_INCOMPLETE_RESPONSE);
    target.set_data(sentinel_data); target.set_dmi_allowed(0);
    target.set_data_length(1); target.set_command(UVM_TLM_READ_COMMAND);
    target.set_address(99);
    target.get_data(data); target.get_byte_enable(enables);
    $display("UT: round %0d setup values %0d",round,
             target.get_address()==99 && target.get_command()==UVM_TLM_READ_COMMAND &&
             target.get_data_length()==1 && !target.is_dmi_allowed() &&
             target.get_response_status()==UVM_TLM_INCOMPLETE_RESPONSE &&
             target.get_byte_enable_length()==1 && target.get_streaming_width()==19 &&
             data.size()==1 && data[0]==8'haa && enables.size()==1 && enables[0]==0);
    if (OBSERVE112) begin
      $display("UT: round %0d direct first_mask %0d order %s",round,
               observer.seen==9'h1ff,observer.first);
      observer.reset_capture(1);
    end
    packer=stream112(round);
    target.do_unpack(packer);
    if (OBSERVE112) observer.capture=0;
    target.get_data(data); target.get_byte_enable(enables);
    $display("UT: round %0d scalars address %0d command %0d length %0d dmi %0d status %0d width %0d",
             round,target.get_address()==address112(round),target.get_command()==command112(),
             target.get_data_length()==length112(),target.is_dmi_allowed(),
             target.get_response_status()==status112(),target.get_streaming_width()==width112());
    $display("UT: round %0d arrays active_data %0d active_enables %0d",round,
             data_ok112(data,round),mask_ok112(enables) &&
             target.get_byte_enable_length()==mask_length112());
    $display("UT: round %0d extension same %0d value %0d unpack_calls %0d",round,
             target.get_extension(tag112::ID())==extension_value,
             extension_value.value,extension_value.unpack_calls);
    if (OBSERVE112) begin
      $display("UT: round %0d unpack first_mask %0d order %s",round,
               observer.seen==9'h1ff,observer.first);
      $display("DIAG112: round %0d setter_calls %0d/%0d/%0d/%0d/%0d/%0d/%0d/%0d/%0d",
               round,observer.calls[0],observer.calls[1],observer.calls[2],observer.calls[3],
               observer.calls[4],observer.calls[5],observer.calls[6],observer.calls[7],observer.calls[8]);
    end
  end
endtask
