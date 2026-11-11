// The serialized state is opaque. Source values, not stream layout, are the oracle.
function automatic uvm_bitstream_t value95(int position);
  uvm_bitstream_t value;
  value='0;
  value[BITS95-1]=1;
  value[7:0]=8'(VARIANT95==0?31+position*17:197-position*23);
  return value;
endfunction
function automatic bit[STORE95-1:0] stored95(int position);
  bit[STORE95-1:0] value;
  value=STORE95'(value95(position));
  if(EXPLICIT95) value[STORE95-1]=1;
  return value;
endfunction
class subject95 extends uvm_object;
  `DECLARE95
  int marker=271;
  function new(string name="subject95");
    super.new(name);
    `INITIALIZE95
  endfunction
  virtual function void do_pack(uvm_packer packer);
    `PACK_APPLY95(values);
  endfunction
  virtual function void do_unpack(uvm_packer packer);
    `UNPACK_APPLY95(values);
  endfunction
endclass
initial begin
  subject95 source,target,peer;
  uvm_packer source_packer,consumer,independent;
  bit opaque_state[];
  uvm_integral_t tail;
  int position,source_size;
  bit values_ok,source_ok,peer_ok,remaining,state_ok;
  source=new("source95");
  target=new("target95");
  peer=new("peer95");
  source_packer=new();
  independent=new();
  independent.pack_field_int(29,5);
  position=0;
  foreach(source.values[index]) begin
    source.values[index]=stored95(position);
    position++;
  end
  foreach(target.values[index]) target.values[index]='1;
  position=0;
  foreach(peer.values[index]) begin
    peer.values[index]=~stored95(position);
    position++;
  end
  source.do_pack(source_packer);
  source_packer.pack_field_int('h35,7);
  source_size=source_packer.get_packed_size();
  if(PACK95) consumer=source_packer;
  else begin
    source_packer.get_packed_bits(opaque_state);
    consumer=new();
    consumer.set_packed_bits(opaque_state);
  end
  target.do_unpack(consumer);
  values_ok=1;
  position=0;
  foreach(target.values[index]) begin
    values_ok &= target.values[index]==STORE95'(value95(position));
    position++;
  end
  source_ok=1;
  position=0;
  foreach(source.values[index]) begin
    source_ok &= source.values[index]==stored95(position);
    position++;
  end
  peer_ok=1;
  position=0;
  foreach(peer.values[index]) begin
    peer_ok &= peer.values[index]==STORE95'(~stored95(position));
    position++;
  end
  peer_ok &= `COUNT_OF95(peer.values)==COUNT95 && independent.get_packed_size()==5 && independent.unpack_field_int(5)==29;
  remaining=consumer.get_packed_size()==7;
  tail=consumer.unpack_field_int(7);
  $display("UT: collection95 %s %0d values %0d shape %0d independent %0d",CASE95,VARIANT95,
    values_ok,`COUNT_OF95(target.values)==COUNT95 && `COUNT_OF95(source.values)==COUNT95,peer_ok);
  $display("UT: collection95 %s %0d trailer %0d remaining %0d consumed %0d",CASE95,VARIANT95,
    tail=='h35,remaining,consumer.get_packed_size()==0);
  if(PACK95)
    $display("UT: collection95 %s %0d source_preserved %0d unrelated_field %0d",CASE95,VARIANT95,
      source_ok,source.marker==271 && target.marker==271 && peer.marker==271);
  else begin
    state_ok=source_packer.get_packed_size()==source_size && source_size>7;
    $display("UT: collection95 %s %0d source_preserved %0d unrelated_field %0d state_isolated %0d",CASE95,VARIANT95,
      source_ok,source.marker==271 && target.marker==271 && peer.marker==271,state_ok);
  end
  $finish;
end
