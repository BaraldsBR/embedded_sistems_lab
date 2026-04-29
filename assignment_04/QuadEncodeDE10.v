module QuadEncoderDE10 (
    input            FPGA_CLK1_50,
    input      [3:0] SW,
    output reg [7:0] LED
);
  wire signed [7:0] pos_out;

  wire signal_A;
  wire signal_B;

  Debouncer debA (
    .clk(FPGA_CLK1_50),
    .rst(SW[3]),
    .signal(SW[0]),
    .debounced(signal_A)
  );
  
  Debouncer debB (
    .clk(FPGA_CLK1_50),
    .rst(SW[3]),
    .signal(SW[1]),
    .debounced(signal_B)
  );

  QuadEncoder #(.STEPS(25)) dut (
    .clk(FPGA_CLK1_50),
    .rst(SW[3]),
    .signal_A(signal_A),
    .signal_B(signal_B),
    .pos_out(pos_out)
  );

  always @(posedge FPGA_CLK1_50) begin
    LED <= pos_out;
  end

endmodule