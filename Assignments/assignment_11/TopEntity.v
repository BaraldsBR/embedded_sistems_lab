module TopEntity (
    input  clk,
    input  SPI_CLK,
    input  SPI_PICO,
    input  SPI_CS,
    output SPI_POCI
);

  reg [2:0] SPI_CLKr;
  always @(posedge clk) SPI_CLKr <= {SPI_CLKr[1:0], SPI_CLK};
  wire SPI_CLK_risingedge = (SPI_CLKr[2:1] == 2'b01);
  wire SPI_CLK_fallingedge = (SPI_CLKr[2:1] == 2'b10);

  reg [2:0] SPI_CSr;
  always @(posedge clk) SPI_CSr <= {SPI_CSr[1:0], SPI_CS};
  wire SPI_CS_active = ~SPI_CSr[1];
  wire SPI_CS_startmessage = (SPI_CSr[2:1] == 2'b10); // when chip gets selected
  wire SPI_CS_endmessage = (SPI_CSr[2:1] == 2'b01); // when chip gets deselected

  reg [1:0] SPI_PICOr;
  always @(posedge clk) SPI_PICOr <= {SPI_PICOr[0], SPI_PICO};
  wire SPI_PICO_data = SPI_PICOr[1];

  // Receive data from SPI
  reg [3:0] bitcnt;
  reg data_received_ready;
  reg [15:0] data_received;

  always @(posedge clk) begin
    if (~SPI_CS_active) bitcnt <= 4'b0000;
    else if (SPI_CLK_risingedge) begin
      bitcnt <= bitcnt + 4'b0001;
      data_received <= {data_received[14:0], SPI_PICO_data};
    end
  end

  always @(posedge clk) data_received_ready <= SPI_CS_active && SPI_CLK_risingedge && (bitcnt == 4'b1111);

  // Send addition back over SPI
  reg [8:0] data_sent;
  reg [7:0] result;

  always @(posedge clk)
    if (SPI_CS_active) begin
      if (data_received_ready) begin
        result <= data_received[15:8] + data_received[7:0];
        data_sent <= {1'b0, data_received[15:8] + data_received[7:0]};
      end
      else if (SPI_CLK_fallingedge) begin
        data_sent <= {data_sent[7:0], 1'b0};
      end
    end

  assign SPI_POCI = data_sent[8];

endmodule
