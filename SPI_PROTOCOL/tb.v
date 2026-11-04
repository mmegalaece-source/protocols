`timescale 1ns/1ps

module spi_protocol_tb;
    reg clk;
    reg reset;
    reg start;
    reg [7:0]  tx_data;
    reg miso;
    wire sclk;
    wire mosi;
    wire cs_n;
    wire [7:0] rx_data;
    wire busy;
    wire done;
    spi_protocol uut (
        .clk     (clk),
        .reset   (reset),
        .start   (start),
        .tx_data (tx_data),
        .miso    (miso),
        .sclk    (sclk),
        .mosi    (mosi),
        .cs_n    (cs_n),
        .rx_data (rx_data),
        .busy    (busy),
        .done    (done)
    );
    always #10 clk = ~clk;
    reg [7:0] slave_tx_data;
    reg [2:0] slave_bit_cnt;
    always @(negedge cs_n) begin

        if (!reset) begin

            // Send first bit (MSB)
            miso = slave_tx_data[7];

            // Next bit position
            slave_bit_cnt = 3'd6;

        end

    end
    always @(negedge sclk) begin
        if (!cs_n) begin
            miso = slave_tx_data[slave_bit_cnt];
            if (slave_bit_cnt != 3'd0)
                slave_bit_cnt = slave_bit_cnt - 3'd1;
        end
    end
    initial begin
        clk     = 1'b0;
        reset   = 1'b1;
        start   = 1'b0;
        tx_data = 8'hA5;
        slave_tx_data = 8'h3C;
        slave_bit_cnt = 3'd7;
        miso = 1'b0;
        #40;
        reset = 1'b0;
        #10;
        start = 1'b1;
        #20;
        start = 1'b0;
        #400;
        $display("--------------------------------");
        $display("       SPI MODE 0 RESULT");
        $display("--------------------------------");

        $display("CLK Frequency  = 50 MHz");
        $display("SCLK Frequency = 50 MHz");

        $display("Master TX = %h", tx_data);
        $display("Slave TX  = %h", slave_tx_data);
        $display("Master RX = %h", rx_data);
        if (rx_data == slave_tx_data)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        #50;
        $finish;
    end
    initial begin

        $monitor(
            "TIME=%0t | CLK=%b | SCLK=%b | CS=%b | MOSI=%b | MISO=%b | RX=%h | BUSY=%b | DONE=%b",
            $time,
            clk,
            sclk,
            cs_n,
            mosi,
            miso,
            rx_data,
            busy,
            done
        );
    end
    initial begin
        $dumpfile("spi_protocol.vcd");
        $dumpvars(0, spi_protocol_tb);
    end
endmodule
