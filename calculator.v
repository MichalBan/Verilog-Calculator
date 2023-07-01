module alu(
  input signed [7:0] A,B,
  input [2:0] control,
  input bit reset,
  input bit enable,

  output signed [7:0] Result
);
  reg signed [7:0] Result_Register;
  assign Result = Result_Register;

  always @(*)
    begin
      if (reset)
        begin
          Result_Register = 0; 
        end
      else if (enable)
        begin
          case(control)
            0:
              Result_Register = A + B; 
            1:
              Result_Register = A - B;
            2:
              Result_Register = A & B;
            3:
              Result_Register = A | B;
            4:
              Result_Register = A ^ B;
            5:
              Result_Register = ~A;
            default:
              Result_Register = A;
          endcase
        end
    end

endmodule
//--------------------------------------------------------------------
module input_register (
  input bit ld,
  input signed [7:0] in,
  input bit reset,
  input bit enable,

  output signed [7:0] out
);
  reg signed [7:0] out_Register;
  assign out = out_Register;

  always @(posedge ld, posedge reset)
    begin
      if(reset)
        begin
          out_Register = 0;
        end
      else if (enable)
        begin
          //$display("load it!");
          out_Register = in;
        end
    end

endmodule

//--------------------------------------------------------------------
module multiplex(
  input signed [7:0] in0,
  input signed [7:0] in1,
  input bit mux_s,
  input bit reset,
  input bit enable,

  output signed [7:0] out
);
  reg signed [7:0] out_Register;
  assign out = out_Register;

  always@(*)
    begin
      if(reset)
        begin
          out_Register = 0;
        end
      else if (enable)
        begin
          if (mux_s) 
            out_Register = in1;
          else
            out_Register = in0;
        end
    end
endmodule

//--------------------------------------------------------------------
module counter(
  input signed[7:0] in,
  input bit ld,
  input bit clk,
  input bit reset,
  input bit enable,

  output signed[7:0] current
);
  reg signed [7:0] current_Register;
  assign current = current_Register;

  always@(posedge reset, posedge ld)
    begin
      if(reset)
        begin
          current_Register = 0;
          //$display("counter reset: %d", current_Register);
        end
      else
        begin        
          current_Register = in - 1;
          //$display("counter loaded: %d", in); 
        end
    end

  always@(posedge clk)
    begin
      if(reset)
        current_Register = 0;
      else if (enable)
        begin
          if(current_Register > 0) 
            begin
              current_Register = current_Register - 1;   
              //$display("counting: %d", current_Register);    
            end
        end
    end
endmodule

//--------------------------------------------------------------------
module out_enabler(
  input signed[7:0] current,
  input bit enable,
  input bit clk,

  output bit out_en
);

  bit out_en_Register;
  assign out_en = out_en_Register;

  always@(posedge clk)
    begin
      if(current == 0 && enable)
        out_en_Register = 1;
      else
        out_en_Register = 0;
    end
endmodule
//--------------------------------------------------------------------
module state_machine(
  input [2:0]operation,
  input bit in_reset,
  input bit in_enable,
  input signed [7:0] counter_current,
  input bit clk,

  output [2:0] ALU_control,
  output bit counter_ld,
  output bit mux_s,
  output bit reset,
  output bit enable
);
  
  reg signed [2:0] ALU_control_Register;
  assign ALU_control = ALU_control_Register;
  
  bit counter_ld_Register;
  assign counter_ld = counter_ld_Register;
  bit mux_s_Register;
  assign mux_s = mux_s_Register;
  bit reset_Register;
  assign reset = reset_Register;
  bit enable_Register;
  assign enable = enable_Register;

  bit multiplication;

  always@(posedge clk)
    begin
      if (in_reset)
        begin
          reset_Register = 1;
          multiplication = 0;       
        end
      else if(in_enable)
        begin
          reset_Register = 0;
          enable_Register = 1;
          if(multiplication)
            begin
              if (counter_current > 0)
                begin 
                  multiplication = 1;
                  counter_ld_Register = 0;
                  mux_s_Register = 1;
                  //$display("counting state machine: %d", counter_current);
                end
              else if(operation == 6)
                enable_Register = 0;
              else
                begin
                  mux_s_Register = 0; 
                  multiplication = 0;
                  enable_Register = 1; 
                end
            end
          else
            begin
              if (counter_current > 0)
                begin 
                  multiplication = 1;
                  counter_ld_Register = 0;
                  mux_s_Register = 1;                  
                  ALU_control_Register = 0;
                  //$display("counting state machine: %d", counter_current);
                end

              else if(operation == 6)
                begin
                  counter_ld_Register = 1;
                  mux_s_Register = 1;
                  ALU_control_Register = 7;
                end
              else
                begin
                  ALU_control_Register = operation;
                  mux_s_Register = 0;
                  counter_ld_Register = 0;
                end
            end
        end
      else
        enable_Register = 0;
    end
endmodule