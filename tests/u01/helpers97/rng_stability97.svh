// Original relative-stream oracle; no numeric RNG or state format is fixed.
typedef enum int {P97_AMBER=7,P97_INDIGO=19,P97_SILVER=43} palette97_t;
class sample97 extends uvm_object;
  rand bit [31:0] payload;
  rand bit [15:0] marker;
  function new(string name);super.new(name);endfunction
endclass
sample97 item97;
int calls97;

function automatic bit exercise97(int step);
  string parts[$];
  palette97_t converted;
  bit success;
  calls97++;
  case(FAMILY97)
    0: begin
      if(step%2==0) begin
        uvm_string_split("larch||iris|",8'h7c,parts);
        return parts.size()==4 && parts[0]=="larch" && parts[1]=="" &&
               parts[2]=="iris" && parts[3]=="";
      end
      uvm_string_split("cedar|quartz",8'h7c,parts);
      return parts.size()==2 && parts[0]=="cedar" && parts[1]=="quartz";
    end
    1: begin
      converted=P97_INDIGO;
      case(step%4)
        0: begin
          success=uvm_enum_wrapper#(palette97_t)::from_name("P97_AMBER",converted);
          return success==1 && converted==P97_AMBER;
        end
        1: begin
          success=uvm_enum_wrapper#(palette97_t)::from_name("P97_SILVER",converted);
          return success==1 && converted==P97_SILVER;
        end
        2: begin
          success=uvm_enum_wrapper#(palette97_t)::from_name("p97_amber",converted);
          return success==0;
        end
        3: begin
          success=uvm_enum_wrapper#(palette97_t)::from_name("P97_INDIGO",converted);
          return success==1 && converted==P97_INDIGO;
        end
      endcase
    end
    2: begin
      if(step%2==0) return item97.get_name()==LABEL97;
      return item97.get_full_name()==LABEL97;
    end
  endcase
  return 0;
endfunction

initial begin
  process caller;
  string caller_state,object_state;
  int unsigned caller_reference[24],actual;
  bit [47:0] object_reference[24];
  bit values_ok,caller_ok,object_ok,randomize_ok;
  int success;
  caller=process::self();
  if(caller==null) $fatal(1,"rng97 requires a calling process");
  values_ok=1;caller_ok=1;object_ok=1;randomize_ok=1;calls97=0;
  // User construction and optional warmup precede the measured state.
  if(FAMILY97==2) item97=new(LABEL97);
  if(VARIANT97==1) begin
    values_ok &= exercise97(5);
    values_ok &= exercise97(2);
  end
  calls97=0;
  caller_state=caller.get_randstate();
  if(FAMILY97==2) object_state=item97.get_randstate();
  for(int i=0;i<24;i++) begin
    caller_reference[i]=$urandom();
    if(FAMILY97==2) begin
      success=item97.randomize();randomize_ok &= success==1;
      object_reference[i]={item97.payload,item97.marker};
    end
  end
  caller.set_randstate(caller_state);
  if(FAMILY97==2) item97.set_randstate(object_state);
  for(int i=0;i<24;i++) begin
    if(VARIANT97==0) values_ok &= exercise97(i);
    else begin
      values_ok &= exercise97(47-i);
      values_ok &= exercise97(i+8);
    end
    actual=$urandom();caller_ok &= actual==caller_reference[i];
    if(FAMILY97==2) begin
      success=item97.randomize();randomize_ok &= success==1;
      object_ok &= {item97.payload,item97.marker}==object_reference[i];
    end
  end
  $display("UT: rng97 %s %0d values %0d caller_stream %0d calls %0d",
    FAMILY_NAME97,VARIANT97,values_ok,caller_ok,calls97);
  if(FAMILY97==2)
    $display("UT: rng97 object %0d randomize %0d object_stream %0d",
      VARIANT97,randomize_ok,object_ok);
  $finish;
end
