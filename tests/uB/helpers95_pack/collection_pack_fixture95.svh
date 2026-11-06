// Original selected element-stream interpretation, not an external wire format.
function automatic uvm_bitstream_t value95(int position);
  uvm_bitstream_t value;
  value='0;value[BITS95-1]=1;
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
  virtual function void `METHOD95(uvm_packer packer);
    `APPLY95(values);
  endfunction
endclass
initial begin
  subject95 subject,peer;
  uvm_packer packer,independent;
  uvm_bitstream_t decoded;
  uvm_integral_t tail;
  int position;
  bit values_ok,source_ok,peer_ok,remaining;
  subject=new("subject95");peer=new("peer95");packer=new();independent=new();
  independent.pack_field_int(29,5);
  position=0;
  foreach(subject.values[index]) begin
    subject.values[index]=PACK95?stored95(position):'1;
    position++;
  end
  position=0;
  foreach(peer.values[index]) begin peer.values[index]=~stored95(position);position++;end
  if(PACK95) begin
    subject.do_pack(packer);
    packer.pack_field_int('h35,7);
    position=0;values_ok=1;source_ok=1;
    foreach(subject.values[index]) begin
      decoded=packer.unpack_field(BITS95);
      values_ok &= decoded==value95(position);
      source_ok &= subject.values[index]==stored95(position);
      position++;
    end
  end else begin
    for(int item=0;item<COUNT95;item++) packer.pack_field(value95(item),BITS95);
    packer.pack_field_int('h35,7);
    subject.do_unpack(packer);
    position=0;values_ok=1;source_ok=1;
    foreach(subject.values[index]) begin
      values_ok &= subject.values[index]==STORE95'(value95(position));
      position++;
    end
  end
  peer_ok=1;position=0;
  foreach(peer.values[index]) begin peer_ok &= peer.values[index]==STORE95'(~stored95(position));position++;end
  peer_ok &= `COUNT_OF95(peer.values)==COUNT95 && independent.get_packed_size()==5 && independent.unpack_field_int(5)==29;
  remaining=packer.get_packed_size()==7;tail=packer.unpack_field_int(7);
  $display("UT: collection95 %s %0d values %0d shape %0d independent %0d",CASE95,VARIANT95,
    values_ok,`COUNT_OF95(subject.values)==COUNT95,peer_ok);
  $display("UT: collection95 %s %0d trailer %0d remaining %0d consumed %0d",CASE95,VARIANT95,
    tail=='h35,remaining,packer.get_packed_size()==0);
  if(PACK95)
    $display("UT: collection95 %s %0d source_preserved %0d unrelated_field %0d",CASE95,VARIANT95,
      source_ok,subject.marker==271 && peer.marker==271);
  else
    $display("UT: collection95 %s %0d unrelated_field %0d",CASE95,VARIANT95,
      subject.marker==271 && peer.marker==271);
  $finish;
end
