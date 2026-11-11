// Original policy observers; object definition stays fixed across operations.
bit record_field_window74 = 0;
int unsigned policy_clock74 = 0;
class subject74 extends uvm_object;
  bit [7:0] payload = 0;
  uvm_printer last_printer;
  uvm_comparer last_comparer;
  uvm_recorder last_recorder;
  uvm_packer last_pack, last_unpack;
  int unsigned pack_tick = 0, unpack_tick = 0;
  function new(string name = "subject74");
    super.new(name);
  endfunction
  virtual function void do_print(uvm_printer printer);
    last_printer = printer;
    printer.print_field_int("payload74", payload, 8, UVM_HEX);
  endfunction
  virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    subject74 peer;
    if (!$cast(peer, rhs)) $fatal(1, "unexpected comparison type");
    last_comparer = comparer;
    return comparer.compare_field_int("payload74", payload, peer.payload, 8, UVM_HEX);
  endfunction
  virtual function void do_copy(uvm_object rhs);
    subject74 source;
    super.do_copy(rhs);
    if (!$cast(source, rhs)) $fatal(1, "unexpected copy type");
    payload = source.payload;
  endfunction
  virtual function void do_record(uvm_recorder recorder);
    last_recorder = recorder;
    record_field_window74 = 1;
    recorder.record_field_int("payload74", payload, 8, UVM_HEX);
    record_field_window74 = 0;
  endfunction
  virtual function void do_pack(uvm_packer packer);
    last_pack = packer;
    packer.pack_field_int(payload, 8);
    pack_tick = ++policy_clock74;
  endfunction
  virtual function void do_unpack(uvm_packer packer);
    last_unpack = packer;
    unpack_tick = ++policy_clock74;
    payload = packer.unpack_field_int(8);
  endfunction
endclass
class printer74 extends uvm_printer;
  bit field_seen = 0;
  uvm_integral_t captured = 0;
  string label;
  function new(string label);
    super.new();
    this.label = label;
  endfunction
  virtual function void print_field_int(string name, uvm_integral_t value, int size,
                                       uvm_radix_enum radix = UVM_NORADIX,
                                       byte scope_separator = ".", string type_name = "");
    if (name == "payload74" && size == 8) begin
      field_seen = 1;
      captured = value;
    end
  endfunction
  virtual function string emit();
    return $sformatf("%s:%0d", label, captured);
  endfunction
endclass
class printer_a74 extends printer74;
  function new();
    super.new("A");
  endfunction
endclass
class printer_b74 extends printer74;
  function new();
    super.new("B");
  endfunction
endclass
class comparer74 extends uvm_comparer;
  bit field_seen = 0;
  bit [7:0] mask;
  function new(bit [7:0] mask);
    super.new();
    this.mask = mask;
  endfunction
  virtual function bit compare_field_int(string name, uvm_integral_t lhs,
                                        uvm_integral_t rhs, int size,
                                        uvm_radix_enum radix = UVM_NORADIX);
    if (name == "payload74" && size == 8) field_seen = 1;
    return super.compare_field_int(name, lhs & mask, rhs & mask, size, radix);
  endfunction
endclass
class comparer_a74 extends comparer74;
  function new();
    super.new('hff);
  endfunction
endclass
class comparer_b74 extends comparer74;
  function new();
    super.new('hf0);
  endfunction
endclass
class copier74 extends uvm_copier;
  bit called = 0;
  uvm_object last_lhs, last_rhs;
  function new();
    super.new();
  endfunction
  virtual function void copy_object(uvm_object lhs, uvm_object rhs);
    called = 1;
    last_lhs = lhs;
    last_rhs = rhs;
    super.copy_object(lhs, rhs);
  endfunction
endclass
class copier_a74 extends copier74; endclass
class copier_b74 extends copier74; endclass
class recorder74 extends uvm_recorder;
  bit field_seen = 0;
  bit [7:0] captured = 0;
  string label;
  function new(string name, string label);
    super.new(name);
    this.label = label;
  endfunction
  protected virtual function void do_open(uvm_tr_stream stream, time open_time,
                                          string type_name); endfunction
  protected virtual function void do_close(time close_time); endfunction
  protected virtual function void do_free(); endfunction
  protected virtual function void do_record_field(string name, uvm_bitstream_t value,
                                                 int size, uvm_radix_enum radix); endfunction
  protected virtual function void do_record_field_int(string name, uvm_integral_t value,
                                                     int size, uvm_radix_enum radix);
    if (record_field_window74 && name == "payload74" && size == 8) begin
      field_seen = 1;
      captured = value;
    end
  endfunction
  protected virtual function void do_record_field_real(string name, real value); endfunction
  protected virtual function void do_record_string(string name, string value); endfunction
  protected virtual function void do_record_time(string name, time value); endfunction
  protected virtual function void do_record_generic(string name, string value,
                                                   string type_name); endfunction
endclass
class recorder_a74 extends recorder74;
  function new(string name);
    super.new(name, "A");
  endfunction
endclass
class recorder_b74 extends recorder74;
  function new(string name);
    super.new(name, "B");
  endfunction
endclass
class stream74 extends uvm_tr_stream;
  function new(string name);
    super.new(name);
  endfunction
  protected virtual function void do_open(uvm_tr_database db, string scope,
                                          string stream_type_name); endfunction
  protected virtual function void do_close(); endfunction
  protected virtual function void do_free(); endfunction
  protected virtual function uvm_recorder do_open_recorder(string name, time open_time,
                                                         string type_name);
    recorder_a74 a;
    recorder_b74 b;
    if (name == "B") begin
      b = new(name);
      return b;
    end
    a = new(name);
    return a;
  endfunction
endclass
class database74 extends uvm_tr_database;
  function new();
    super.new("database74");
  endfunction
  protected virtual function bit do_open_db();
    return 1;
  endfunction
  protected virtual function bit do_close_db();
    return 1;
  endfunction
  protected virtual function uvm_tr_stream do_open_stream(string name, string scope,
                                                        string type_name);
    stream74 value;
    value = new(name);
    return value;
  endfunction
  protected virtual function void do_establish_link(uvm_link_base link); endfunction
endclass
class packer74 extends uvm_packer;
  bit get_seen[4] = '{default:0};
  bit set_seen[4] = '{default:0};
  int unsigned get_tick[4] = '{default:0};
  int unsigned set_tick[4] = '{default:0};
  function new();
    super.new();
  endfunction
  function void clear_observers();
    foreach (get_seen[i]) begin
      get_seen[i] = 0;
      set_seen[i] = 0;
      get_tick[i] = 0;
      set_tick[i] = 0;
    end
  endfunction
  function bit idle();
    foreach (get_seen[i]) if (get_seen[i] || set_seen[i]) return 0;
    return 1;
  endfunction
  virtual function void get_packed_bits(ref bit stream[]);
    get_seen[0] = 1;
    get_tick[0] = ++policy_clock74;
    super.get_packed_bits(stream);
  endfunction
  virtual function void set_packed_bits(ref bit stream[]);
    set_seen[0] = 1;
    set_tick[0] = ++policy_clock74;
    super.set_packed_bits(stream);
  endfunction
  virtual function void get_packed_bytes(ref byte unsigned stream[]);
    get_seen[1] = 1;
    get_tick[1] = ++policy_clock74;
    super.get_packed_bytes(stream);
  endfunction
  virtual function void set_packed_bytes(ref byte unsigned stream[]);
    set_seen[1] = 1;
    set_tick[1] = ++policy_clock74;
    super.set_packed_bytes(stream);
  endfunction
  virtual function void get_packed_ints(ref int unsigned stream[]);
    get_seen[2] = 1;
    get_tick[2] = ++policy_clock74;
    super.get_packed_ints(stream);
  endfunction
  virtual function void set_packed_ints(ref int unsigned stream[]);
    set_seen[2] = 1;
    set_tick[2] = ++policy_clock74;
    super.set_packed_ints(stream);
  endfunction
  virtual function void get_packed_longints(ref longint unsigned stream[]);
    get_seen[3] = 1;
    get_tick[3] = ++policy_clock74;
    super.get_packed_longints(stream);
  endfunction
  virtual function void set_packed_longints(ref longint unsigned stream[]);
    set_seen[3] = 1;
    set_tick[3] = ++policy_clock74;
    super.set_packed_longints(stream);
  endfunction
endclass
class packer_a74 extends packer74; endclass
class packer_b74 extends packer74; endclass
