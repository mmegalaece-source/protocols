`timescale 1ns/1ps

module spi_protocol (
    input  wire       clk,
    input  wire       reset,
    input  wire       start,
    input  wire [7:0] tx_data,
    input  wire       miso,

    output wire       sclk,
    output reg        mosi,
    output reg        cs_n,
    output reg [7:0]  rx_data,
    output reg        busy,
    output reg        done
);

    //============================================
    // SPI MODE 0
    //
    // CPOL = 0
    // CPHA = 0
    //
    // Rising edge  -> Sample MISO
    // Falling edge -> Change MOSI
    //============================================

    localparam ST_IDLE     = 2'd0;
    localparam ST_TRANSFER = 2'd1;
    localparam ST_DONE     = 2'd2;

    reg [1:0] state;

    reg [7:0] tx_shift;
    reg [7:0] rx_shift;

    reg [2:0] bit_cnt;
    reg       active;


    //============================================
    // SCLK = CLK
    // Same frequency
    // When SPI is inactive, SCLK stays LOW
    //============================================

    assign sclk = active ? clk : 1'b0;


    //============================================
    // START / CONTROL
    // First MOSI bit must be ready
    // before first rising edge
    //============================================

    always @(negedge clk or posedge reset) begin

        if (reset) begin

            state    <= ST_IDLE;

            tx_shift <= 8'h00;
            bit_cnt  <= 3'd7;

            mosi     <= 1'b0;
            cs_n     <= 1'b1;

            busy     <= 1'b0;
            done     <= 1'b0;

            active   <= 1'b0;

        end

        else begin

            done <= 1'b0;

            case (state)

                //====================================
                // IDLE
                //====================================

                ST_IDLE: begin

                    cs_n   <= 1'b1;
                    busy   <= 1'b0;
                    mosi   <= 1'b0;
                    active <= 1'b0;

                    if (start) begin

                        tx_shift <= tx_data;

                        bit_cnt <= 3'd7;

                        // First MOSI bit = MSB
                        mosi <= tx_data[7];

                        // Start SPI transaction
                        cs_n   <= 1'b0;
                        busy   <= 1'b1;
                        active <= 1'b1;

                        state <= ST_TRANSFER;

                    end

                end


                //====================================
                // TRANSFER
                // Falling edge -> Change MOSI
                //====================================

                ST_TRANSFER: begin

                    if (bit_cnt != 3'd0) begin

                        // Shift TX register
                        tx_shift <= {
                            tx_shift[6:0],
                            1'b0
                        };

                        // Send next bit
                        mosi <= tx_shift[6];

                    end

                end


                //====================================
                // DONE
                //====================================

                ST_DONE: begin

                    cs_n   <= 1'b1;
                    busy   <= 1'b0;
                    active <= 1'b0;
                    mosi   <= 1'b0;

                    done <= 1'b1;

                    state <= ST_IDLE;

                end


                default: begin

                    state  <= ST_IDLE;
                    cs_n   <= 1'b1;
                    busy   <= 1'b0;
                    active <= 1'b0;
                    mosi   <= 1'b0;

                end

            endcase

        end

    end


    //============================================
    // RECEIVE
    //
    // MODE 0:
    // Rising edge -> Sample MISO
    //============================================

    always @(posedge clk or posedge reset) begin

        if (reset) begin

            rx_shift <= 8'h00;
            rx_data  <= 8'h00;

        end

        else if (state == ST_TRANSFER && active) begin

            // Sample MISO
            rx_shift <= {
                rx_shift[6:0],
                miso
            };


            // Last bit?
            if (bit_cnt == 3'd0) begin

                // Store final received data
                rx_data <= {
                    rx_shift[6:0],
                    miso
                };

                // Transfer completed
                state <= ST_DONE;

            end

            else begin

                // Count received bits
                bit_cnt <= bit_cnt - 3'd1;

            end

        end

    end

endmodule
