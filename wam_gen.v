module wam_rdn(             // generate 8-bit random number
    input wire clk,
    input wire clr,
    input wire load,
    input wire [7:0] seed,
    output reg [7:0] num
    );

    always @( posedge clk or negedge clr ) begin
        if(!clr)
            num <= 8'b0;        // clear
        else if(load)
            num <= seed;        // load seed
        else
            begin               // shift with feed back
                num[0] <= num[7];
                num[1] <= num[0];
                num[2] <= num[1]^num[7];
                num[3] <= num[2];
                num[4] <= num[3]^num[7];
                num[5] <= num[4];
                num[6] <= num[5]^num[7];
                num[7] <= num[6];
            end
    end
endmodule

module wam_gen (            // control life of moles
    input wire clk,
    input wire [32:0] clk_cnt,
    output reg [3:0]  holes [7:0]      // which hole has moles
    );


endmodule // wam_gen
