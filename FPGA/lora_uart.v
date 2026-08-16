module lora_uart (
    input        rx_clk,
    input        res,
    input        rx_in,
    output [7:0] led
    
);

  wire [7:0] rx_data_reg;
  wire busy, data_valid, error;

  rx_module uut (
    rx_clk, res, rx_in,
    rx_data_reg, busy, data_valid, error
  );

  // FSM states
  localparam IDLE     = 0,
             HEADER   = 1,
             ADDR     = 2,
             LENGTH   = 3,
             PAYLOAD  = 4,
             DONE     = 5;

  reg [2:0] state;
  reg cr_seen;

  // header "+RCV="
  reg [2:0] header_index;

  reg [7:0] length;
  reg [7:0] payload_count;
  reg [15:0] number;

  reg [7:0] latched_data_out;

  always @(posedge rx_clk or negedge res) begin
    if (!res) begin
      state <= IDLE;
      header_index <= 0;
      length <= 0;
      payload_count <= 0;
      number <= 0;
      latched_data_out <= 0;
      cr_seen <= 0;
    end 
    else if (data_valid) begin

      case(state)

        // -------------------------------
        // WAIT FOR '+'
        // -------------------------------
        IDLE: begin
          if (rx_data_reg == 8'h2B) begin // '+'
            state <= HEADER;
            header_index <= 0;
          end
        end

        // -------------------------------
        // MATCH "RCV="
        // -------------------------------
        HEADER: begin
          case(header_index)
            0: if (rx_data_reg == "R") header_index <= 1; else state <= IDLE;
            1: if (rx_data_reg == "C") header_index <= 2; else state <= IDLE;
            2: if (rx_data_reg == "V") header_index <= 3; else state <= IDLE;
            3: if (rx_data_reg == "=") state<= ADDR; else state <= IDLE;
          endcase
        end

        // -------------------------------
        // SKIP ADDRESS
        // -------------------------------
        ADDR: begin
          if (rx_data_reg == 8'h2C) begin
            state <= LENGTH;
            length <= 0;
          end
        end

        // -------------------------------
        // READ LENGTH
        // -------------------------------
        LENGTH: begin
          if (rx_data_reg == 8'h2C) begin
            state <= PAYLOAD;
            payload_count <= 0;
            number <= 0;   // ? important reset
          end 
          else if (rx_data_reg >= 8'h30 && rx_data_reg <= 8'h39) begin
            length <= (length * 10) + (rx_data_reg - 8'h30);
          end
        end

        // -------------------------------
        // READ PAYLOAD (FIXED)
        // -------------------------------
        PAYLOAD: begin
          if (payload_count < length) begin

            if (rx_data_reg >= 8'h30 && rx_data_reg <= 8'h39) begin
              number <= (number * 10) + (rx_data_reg - 8'h30);
            end

            payload_count <= payload_count + 1;
            
            if(payload_count==length-1)begin
                state<=DONE;
            end
          end 
        end

        // -------------------------------
        // OUTPUT RESULT
        // -------------------------------
        DONE: begin
          latched_data_out <= number[7:0];
          if (rx_data_reg == 8'h0D) begin   // '\r'
              cr_seen <= 1;
            end
            else if (rx_data_reg == 8'h0A && cr_seen) begin  // '\n' after '\r'
              cr_seen <= 0;
              state <= IDLE;
            end
            else begin
              cr_seen <= 0;   // reset if sequence breaks
            end
        end

      endcase
    end
  end

  assign led = latched_data_out;
  //assign state_r=state;

endmodule
