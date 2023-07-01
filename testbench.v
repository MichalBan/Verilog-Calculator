`timescale 1ns / 1ps 

module clock(output bit clk);
  bit clk_Register;
  assign clk = clk_Register;

  initial
    begin
      forever
        begin
        	#10 clk_Register = !clk_Register;
          //if(clk_Register)
            //$display("rising"); 
        end
    end

endmodule

//--------------------------------------------------------------------
module tb_alu;
  // inputs
    // registers
    reg signed [7:0] A;
    reg signed [7:0] B;
    // control state machine
    reg [2:0] operation;
    bit in_reset;
    bit in_enable;    
    //clock
    bit clk;

  // output
  	wire signed [7:0] Out;

  // signals  
    // registers
    reg signed [7:0] A_reg,B_reg;
    reg signed [7:0] O_Reg;
    reg signed [7:0] B_mux; 
  	bit out_enable;
    // counter
    reg signed [7:0] current;
    bit ld;
    // mux
    bit mux_s;
    // alu
    reg[2:0] ALU_Sel;
    // shared
    bit reset;
    bit enable;

  // modules
  state_machine automaton(operation, in_reset, in_enable, current, clk, ALU_Sel, ld, mux_s, reset, enable);
  alu test_alu(A_reg, B_reg, ALU_Sel, reset, enable, O_Reg);
  input_register A_buffer(clk, A, reset, enable, A_reg);
  input_register B_buffer(clk, B_mux, reset, enable, B_reg);
  input_register O_buffer(clk, O_Reg, reset, out_enable, Out);
  out_enabler O_en(current, enable, clk, out_enable);
  multiplex mux(B,O_Reg, mux_s, reset, enable, B_mux);
  counter mult_couter(B_reg, ld, clk, reset, enable, current);
  clock ticker(clk);

  // initialization
  initial begin
    in_reset = 0;
    #10;
    in_reset = 1;
    #30;
    in_reset = 0;

    in_enable = 1;
    A = 4;
    B = 9;

    // test
    operation = 0;
    #100$display("%d result: %d",operation, Out);
    operation = 1;
    #100$display("%d result: %d",operation, Out);
    operation = 2;
    #100$display("%d result: %d",operation, Out);
    operation = 3;
    #100$display("%d result: %d",operation, Out);
    operation = 6;
    #(100 + B * 20);$display("%d result: %d",operation, Out);
    operation = 4;
    #100$display("%d result: %d",operation, Out);
    operation = 5;
    #100$display("%d result: %d",operation, Out);
    in_reset = 1;
    #30;$display("%d result: %d",operation, Out);
    in_reset = 0;
    operation = 3;
    #100$display("%d result: %d",operation, Out);
    in_enable = 0;
    operation = 0;
    #100$display("%d result: %d",operation, Out);
    operation = 1;
    #100$display("%d result: %d",operation, Out);
    in_enable = 1;
    #100$display("%d result: %d",operation, Out);
    $stop;
  end

  always@(current)
    begin
    //$display("counting: %d", current); 
    end

  
endmodule