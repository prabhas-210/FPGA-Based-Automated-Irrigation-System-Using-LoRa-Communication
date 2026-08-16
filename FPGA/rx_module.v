`timescale 1ns/1ps

module rx_module
  (
    input 				rx_clk,
    input  				res,
    input 		 		rx_in,
    output wire [7:0]	rx_data_reg,
    output wire 		busy,
    output wire 		data_valid,
    output wire 		error
  );
  
  //states declaration
  parameter idle		=2'b00;
  parameter start_bit	=2'b01;
  parameter data_bits	=2'b10;
  parameter stop_bit	=2'b11;
  
  //baudrate values
  localparam count_width	=14;  // for 100MHz clock and baud rate=9600
  localparam clks_per_bit	=10416;// for 100MHz clock and baud rate=9600
  
  //output registers decleration
  reg 		rx_data1		=1'b1;
  reg 		rx_data			=1'b1;
  reg [7:0]	rx_output_data;
  reg 		rx_busy;
  reg 		rx_data_valid;
  reg 		rx_error;
  
  
  reg [count_width-1:0]	counter			=0;
  reg [2:0]				bit_index		=3'b000;
  reg [1:0]				current_state	=2'b00;
  
  //rx_data synchronization logic
  always @(posedge rx_clk or negedge res)begin
    
    if(!res)begin
      rx_data1<=1;
      rx_data<=1;
    end
    else begin
      rx_data1<=rx_in;
      rx_data<=rx_data1;
    end
  end
  
  //uart receiver 8N1 logic
  always @(posedge rx_clk or negedge res)begin
    if(!res)begin
      current_state	<=idle;
      rx_output_data<=8'b0;
      rx_data_valid	<=1'b0;
      rx_error		<=1'b0;
      rx_busy		<=1'b0;
      counter		<=0;
      bit_index		<=3'b000;
    end
    
    else begin
      case(current_state)
        //idle state
      idle:begin
        rx_error		<=1'b0;
        rx_data_valid	<=1'b0;
        rx_busy			<=1'b0;
        counter			<=0;
        bit_index		<=3'b0;
        
        if(rx_data==1'b0)begin
          current_state<=start_bit;
        end
      end
        //start bit detection
      start_bit:begin
        if(counter==(clks_per_bit-1)/2)begin
          if(rx_data==1'b0)begin
            counter<=0;
            rx_busy<=1'b1;
            current_state<=data_bits;
          end
          else begin
            current_state<=idle;
            rx_error<=1'b1;
          end
        end
        else begin
          counter<=counter+1'b1;
        end
      end
        //data bits collection
      data_bits:begin
        if(counter<clks_per_bit-1)begin
          counter<=counter+1'b1;
        end
        else begin
          counter<=0;
          rx_output_data[bit_index]<=rx_data;
          if(bit_index<7)begin
            bit_index<=bit_index+1'b1;
          end
          else begin
            bit_index<=3'b0;
            current_state<=stop_bit;
          end
        end
      end
        //stop bit detection
      stop_bit:begin
        if(counter<clks_per_bit-1)begin
          counter<=counter+1'b1;
        end
        else begin
          if(rx_data==1'b1)begin
            rx_data_valid<=1'b1;
            counter<=0;
            rx_busy<=1'b0;
            current_state<=idle;
          end
          else begin
            rx_error<=1'b1;
            rx_output_data <= 8'b0;
  			rx_data_valid <= 0;
            current_state<=idle;
          end
        end
      end
        //default case
      default :current_state<=idle;
    endcase
    end
  end
  //data assignments
  assign rx_data_reg=rx_output_data;
  assign busy		=rx_busy;
  assign data_valid	=rx_data_valid;
  assign error		=rx_error;
endmodule
