module wam_tap (
    input wire clk_19,
    input wire [7:0] sw,
    // output wire [7:0] tap
    output reg [7:0] tap       // active high
    );

    reg [7:0]  sw_pre;
    wire [7:0] sw_edg;
    reg [31:0] sw_cnt;
    integer i;

    always @(posedge clk_19)    // edge detection
        sw_pre <= sw;
    assign sw_edg = ((sw_pre) & (~sw)) | ((~sw_pre) & (sw));

    always @ (posedge clk_19) begin
        for (i=0; i<8; i=i+1) begin
            if (sw_cnt[4*i+:4] > 0) begin               // filtering
                if (sw_cnt[4*i+:4] >= 4'b0100) begin    // stable
                    sw_cnt[4*i+:4] <= 4'b0000;
                    tap[i] <= 1;                        // output status
                end
                else begin
                    if (sw_edg[i]) begin                // if switch then back to idle
                        sw_cnt[4*i+:4] <= 0;
                    end
                    else begin                          // count
                        sw_cnt[4*i+:4] <= sw_cnt[4*i+:4] + 1;
                    end
                end
            end
            else begin                                  // idle
                tap[i] <= 0;
                if (sw_edg[i]) begin                    // if switch then start filtering
                    sw_cnt[4*i+:4] <= 4'b0001;
                end
            end
        end
    end

    // assign tap = sw_edg;
    // assign tap = sw;
endmodule // wam_tap

module wam_hit (
    input wire clk_19,
    input wire [7:0] tap,
    input wire [7:0] holes,
    output reg [7:0] hit         // effective hit
    );

    reg [7:0] holes_pre;

    always @ (posedge clk_19) begin
        hit <= tap & holes_pre;
        holes_pre <= holes;
    end

    // assign hit = tap & holes_pre;
    // assign hit = tap;
endmodule // wam_hit

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
endmodule

module wam_swc(             // switch count
    input wire clk,         // synchronize clock
    input wire clr,
    input wire [7:0] hit,
    output reg [11:0] num
    );

    wire [11:0] cnum;       // counter number register
    wire cout0, cout1, cout2;
    wire scr;

    assign scr = hit[0] | hit[1] | hit[2] | hit[3] | hit[4] | hit[5] | hit[6] | hit[7];

    wam_cnt cnt0( .clr(clr), .cin(scr), .cout(cout0), .num(cnum[3:0]) );
    wam_cnt cnt1( .clr(clr), .cin(cout0), .cout(cout1), .num(cnum[7:4]) );
    wam_cnt cnt2( .clr(clr), .cin(cout1), .cout(cout2), .num(cnum[11:8]) );

    always @(posedge clk) begin
        num <= cnum;
    end
endmodule
