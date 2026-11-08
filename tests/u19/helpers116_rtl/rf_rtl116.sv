// Original register-file bus and design for the 116th RTL integration profiles.
// One request is presented per clock; a read returns its data on the next clock.

interface rf_if116(input logic clk);
  logic rst_n = 1'b0;
  logic sel = 1'b0;
  logic write = 1'b0;
  logic [1:0] addr = 2'd0;
  logic [7:0] wdata = 8'h00;
  logic [7:0] rdata;
  int unsigned cycle = 0;

  // Cycle stamp for observations; it changes only at a clock edge.
  always @(posedge clk) cycle <= cycle + 1;

  // Inputs are sampled one step before each edge and outputs are driven with
  // zero skew in the Re-NBA region of the clocking event (1800-2023 14.4,
  // 14.13 and 14.16), so a drive reaches the design at the next edge.
  clocking drv_cb @(posedge clk);
    default input #1step output #0;
    output sel, write, addr, wdata;
    input rdata, rst_n, cycle;
  endclocking

  clocking mon_cb @(posedge clk);
    default input #1step;
    input sel, write, addr, wdata, rdata, rst_n, cycle;
  endclocking
endinterface

// CTRL (address 0) and DATA (address 1) are read-write.
// COUNT (address 2) counts accepted writes to CTRL and DATA.
// ID (address 3) is the constant 8'hA5.
// Writes to COUNT and ID are ignored.
module rf_dut116(rf_if116 bus);
  logic [7:0] ctrl;
  logic [7:0] data;
  logic [7:0] count;

  always_ff @(posedge bus.clk) begin
    if (!bus.rst_n) begin
      ctrl <= 8'h00;
      data <= 8'h00;
      count <= 8'h00;
      bus.rdata <= 8'h00;
    end else if (bus.sel && bus.write) begin
      if (bus.addr == 2'd0) begin
        ctrl <= bus.wdata;
        count <= count + 8'd1;
      end else if (bus.addr == 2'd1) begin
        data <= bus.wdata;
        count <= count + 8'd1;
      end
    end else if (bus.sel) begin
      case (bus.addr)
        2'd0: bus.rdata <= ctrl;
        2'd1: bus.rdata <= data;
        2'd2: bus.rdata <= count;
        default: bus.rdata <= 8'hA5;
      endcase
    end
  end
endmodule
