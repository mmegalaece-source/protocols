module apb_master (
    input pclk,
    input reset,
    input start,
    input rw,              
    input [7:0] add,
    input [7:0] write_data,
    input [7:0] prdata,
    input pready,

    output reg psel,
    output reg pena,
    output reg [7:0] padd,
    output reg [7:0] pwdata,
    output reg pwrite,
    output reg [7:0] read_data
);

    parameter IDLE   = 2'b00;
    parameter SETUP  = 2'b01;
    parameter ACCESS = 2'b10;

    reg [1:0] state, next_state;


    // State register
    always @(posedge pclk or negedge reset) begin
        if (!reset)
            state <= IDLE;
        else
            state <= next_state;
    end


    // Next state logic
    always @(*) begin
        case (state)

            IDLE: begin
                if (start)
                    next_state = SETUP;
                else
                    next_state = IDLE;
            end

            SETUP: begin
                next_state = ACCESS;
            end

            ACCESS: begin
                if (pready)
                    next_state = IDLE;
                else
                    next_state = ACCESS;
            end

            default:
                next_state = IDLE;

        endcase
    end

    always @(*) begin
        psel   = 1'b0;
        pena   = 1'b0;
        padd   = add;
        pwdata = write_data;
        pwrite = rw;

        case (state)

            IDLE: begin
                psel = 1'b0;
                pena = 1'b0;
            end

            SETUP: begin
                psel = 1'b1;
                pena = 1'b0;
            end

            ACCESS: begin
                psel = 1'b1;
                pena = 1'b1;
            end
        endcase
    end
    always @(posedge pclk or negedge reset) begin
        if (!reset) begin
            read_data <= 8'h00;
        end
        else begin
            if (state == ACCESS &&
                !pwrite &&
                pready) begin
                read_data <= prdata;
            end
        end
end
endmodule

module apb_slave (
    input pclk,
    input reset,
    input psel,
    input pena,
    input pwrite,
    input [7:0] padd,
    input [7:0] pwdata,
    output reg [7:0] prdata,
    output  pready
);
    assign pready = 1'b1;
    reg [7:0] mem [0:255];
    integer i;
 
       always @(posedge pclk or negedge reset) begin
        if (!reset) begin
            for (i = 0; i < 256; i = i + 1)
                mem[i] <= 8'h00;
        end
        else begin
            if (psel && pena && pwrite ) begin
    		    mem[padd] <= pwdata;
		end
            end
        end
    
    always @(*) begin
        if (psel && pena && !pwrite ) 
            prdata = mem[padd];
        else
		prdata <= 8'h00;
      end

endmodule
