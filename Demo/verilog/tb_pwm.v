`include "pwm.v"
`timescale 1ns / 1ps
module tb_pwm;
  localparam PWM_MAX = 100;
  localparam LOW_VALUE = 10;
  localparam HIGH_VALUE = 80;

  reg rst;
  reg clk;
  reg [15:0] target_value;
  wire dir_A;
  wire dir_B;
  wire PWM_VAL;

  pwm #(
    .PWM_MAX(PWM_MAX)
  ) dut (
    .rst(rst),
    .clk(clk),
    .target_value(target_value),
    .dir_A(dir_A),
    .dir_B(dir_B),
    .PWM_VAL(PWM_VAL)
  );

  // generate clock
  initial begin
    forever begin
      clk = 0;
      #1;
      clk = ~clk;
      #1;
    end
  end

  initial begin
    $dumpfile("signals.vcd");
    $dumpvars(0, tb_pwm);

    target_value = 0;
    rst = 0;
    #10;
    rst = 1;
    #10;
    rst = 0; 
    #200;

    target_value = LOW_VALUE;
    #400;
    target_value = HIGH_VALUE;
    #400;
    target_value = -LOW_VALUE;
    #400;
    target_value = -HIGH_VALUE;
    #400;
    
    $finish;
  end
endmodule
