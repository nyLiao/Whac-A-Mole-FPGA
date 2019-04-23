module wam_cnt(           // 1-bit counter
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
endmodule

module wam_swc(           // switch count
    input wire clk,
    input wire clr,
    input wire [3:0] sw,
    output reg [7:0] num
    );

    wire [7:0] cnum;        // counter number register
    wire cout0, cout1;
    wire f;

    assign f = sw[0] | sw[1] | sw[2] | sw[3];

    wam_cnt cnt0( .clr(clr), .cin(f), .cout(cout0), .num(cnum[3:0]) );
    wam_cnt cnt1( .clr(clr), .cin(cout0), .cout(cout1), .num(cnum[7:4]) );

    always @(posedge clk) begin
        num <= cnum;
    end
endmodule
