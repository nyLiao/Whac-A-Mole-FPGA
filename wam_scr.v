module wam_cnt(             // 1-bit 0-to-9 counter
    input wire clr,
    input wire cin,
    output reg cout,
    output reg [3:0] num
    );

    always @(posedge cin or posedge clr) begin
        if (clr)
            begin
                num <= 0;
            end
        else
            begin
                if (num < 9)
                    begin
                        num <= num + 1;
                        cout <= 0;
                    end
                else
                    begin
                        num <= 0;
                        cout <= 1;
                    end
            end
    end
endmodule // wam_cnt

module wam_scr(             // score count
    input wire clk,         // synchronize clock
    input wire clr,
    input wire [7:0] hit,
    output reg [11:0] num,
    output wire cout0
    );

    wire [11:0] cnum;       // counter number register
    wire cout1, cout2;
    wire scr;

    assign scr = hit[0] | hit[1] | hit[2] | hit[3] | hit[4] | hit[5] | hit[6] | hit[7];

    wam_cnt cnt0( .clr(clr), .cin(scr), .cout(cout0), .num(cnum[3:0]) );
    wam_cnt cnt1( .clr(clr), .cin(cout0), .cout(cout1), .num(cnum[7:4]) );
    wam_cnt cnt2( .clr(clr), .cin(cout1), .cout(cout2), .num(cnum[11:8]) );

    always @(posedge clk) begin
        num <= cnum;
    end
endmodule // wam_scr
