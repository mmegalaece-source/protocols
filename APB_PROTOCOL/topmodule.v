module apb_top (
    input        pclk,
    input        reset,
    input        start,
    input        rw,
    input  [7:0] add,
    input  [7:0] write_data,
    output [7:0] read_data
);
    wire        psel;
    wire        pena;
    wire [7:0]  padd;
    wire [7:0]  pwdata;
    wire        pwrite;
    wire [7:0]  prdata;
    wire        pready;
    apb_master master (
        .pclk (pclk),
        .reset (reset),
        .start (start),
        .rw (rw),
        .add (add),
        .write_data (write_data),
        .prdata (prdata),
        .pready (pready),
        .psel (psel),
        .pena (pena),
        .padd (padd),
        .pwdata (pwdata),
        .pwrite (pwrite),
        .read_data(read_data)
    );
    apb_slave slave (
        .pclk (pclk),
        .reset (reset),
        .psel (psel),
        .pena (pena),
        .pwrite (pwrite),
        .padd (padd),
        .pwdata (pwdata),
        .prdata (prdata),
        .pready (pready)
    );
endmodule
