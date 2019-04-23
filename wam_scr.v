module wam_tap (
    input wire clk,
    input wire clr,
    input wire [32:0] clk_cnt,
    input wire [7:0] sw,
    output wire [7:0] tap
    // output reg [7:0] tap        // active high
    );

    // reg [7:0] ns;
    // reg [7:0] sw_pre;
    // wire [7:0] sw_edg;
    // reg cnt_en;                 // clock_20 enable
    // reg [19:0] cnt;             // clock 20 Hz
    // integer i;
    //
    // always @(posedge clk)       // edge detection
    //     sw_pre <= sw;
    // assign sw_edg = ((sw_pre) & (!sw)) | ((!sw_pre) & (sw));
    //
    // always @ ( posedge clk, negedge clr ) begin     // state machine
    //     if (!clr) begin
    //         ns <= 8'b00000000;
    //         cnt_en <= 0;
    //         cnt <=
    //     end
    // end

    assign tap = sw;
endmodule // wam_tap

module wam_hit (
    input wire [7:0] tap,
    output wire [7:0] hit         // effective hit
    );

    assign hit = tap;
endmodule // wam_hit

module wam_cnt(             // 1-bit counter
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
