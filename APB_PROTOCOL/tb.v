module apb_tb;
    reg pclk;
    reg reset;
    reg start;
    reg rw;
    reg [7:0] add;
    reg [7:0] write_data;
    wire [7:0] read_data;
    apb_top uut (
        .pclk (pclk),
        .reset (reset),
        .start (start),
        .rw (rw),
        .add (add),
        .write_data (write_data),
        .read_data (read_data)
    );
    always #5 pclk = ~pclk;
    initial begin
        pclk = 0;
        reset = 0;
        start = 0;
        rw = 0;
        add = 8'h00;
        write_data = 8'h00;

	#10;
        reset = 1;
        #10;
        add = 8'h10;
        write_data = 8'hAA;
        rw = 1;          
        start = 1;
        #10;
        start = 0;
        #40;


	add = 8'h10;
        rw = 0;          
        start = 1;
        #10;
        start = 0;
        #30;
        $display("READ DATA = %h", read_data);
        #20;
        $finish;
    end
    initial begin
        $dumpfile("apb.vcd");
        $dumpvars(0, apb_tb);
    end
    initial begin
        $monitor("TIME=%0t PSEL=%b PENA=%b PWRITE=%b PADDR=%h PWDATA=%h  READ_DATA=%h",
            $time,
            uut.psel,
            uut.pena,
            uut.pwrite,
            uut.padd,
            uut.pwdata,
            read_data);
        
    end
endmodule
