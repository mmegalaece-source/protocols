module slave(
        input clk,
        input reset,
        input psel,
        input pena,
        input pwrite,
        input [7:0] padd,
        input [7:0]pwdata,
        output reg [7:0]prdata,
        output reg pready);
reg[7:0]mem[0:7];
always@(*)begin
        pready=1'b1;
end
always@(posedge clk)begin
        if(psel && pena && pwrite)begin
                mem[padd]<=pwdata;
        end
end
always@(*)begin
        if(psel && pena && !pwrite)begin
                prdata=mem[padd];
end
else begin
        prdata<=8'd0;
end
end
endmodule
