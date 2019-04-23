module wam_m(
    input wire clk,         // clock
    input wire clr,         // button - clear
    input wire [3:0] sw,    // switch
    output wire [3:0] an,   // digital tube - analog
    output wire [6:0] a2g   // digital tube - stroke
    //output wire [3:0] ld
    );

    reg [32:0] clk_cnt;     // clock count
    wire [7:0] score;       // score

    // handle clock
    always @(posedge clk) begin
        if(clr)
            clk_cnt = 0;
        else begin
            clk_cnt = clk_cnt + 1;
            if(clk_cnt[32:29]>15)
                clk_cnt = 0;
        end
    end

    // handle score count
    wam_swc sub_swc( .clk(clk), .clr(clr), .sw(sw), .num(score) );

    // handle display on digital tube
    wam_dis sub_dis( .sbit(clk_cnt[15]), .score(score), .an(an), .a2g(a2g) );
endmodule
