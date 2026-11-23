// A read bus with an address tag on each response. The first pair completes
// in reverse order. Only the second request gets an error. Subsequent reads
// complete normally. Signal changes in the driver occur on falling edges.
interface tagged_read_bus(input bit clk);
  bit rst_n, valid, rsp_valid, rsp_error;
  bit [7:0] addr, rsp_addr, rsp_data;
  int unsigned accepted, completed;
endinterface

module reordered_read_slave(tagged_read_bus bus);
  bit [7:0] first_addr;
  bit first_due;

  function automatic bit [7:0] read_byte(bit [7:0] addr);
    case (addr)
      8'h10: return 8'h31;
      8'h20: return 8'ha5;
      default: return 8'h00;
    endcase
  endfunction

  always_ff @(posedge bus.clk) begin
    if (!bus.rst_n) begin
      bus.accepted <= 0;
      bus.completed <= 0;
      bus.rsp_valid <= 0;
      bus.rsp_error <= 0;
      first_due <= 0;
    end else begin
      bus.rsp_valid <= 0;
      if (first_due) begin
        bus.rsp_valid <= 1;
        bus.rsp_addr <= first_addr;
        bus.rsp_data <= read_byte(first_addr);
        bus.rsp_error <= 0;
        bus.completed <= bus.completed + 1;
        first_due <= 0;
      end else if (bus.valid) begin
        bus.accepted <= bus.accepted + 1;
        if (bus.accepted == 0) begin
          first_addr <= bus.addr;
        end else begin
          bus.rsp_valid <= 1;
          bus.rsp_addr <= bus.addr;
          bus.rsp_error <= bus.accepted == 1;
          bus.rsp_data <= bus.accepted == 1 ? 8'he1 : read_byte(bus.addr);
          bus.completed <= bus.completed + 1;
          first_due <= bus.accepted == 1;
        end
      end
    end
  end
endmodule
