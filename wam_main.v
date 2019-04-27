`timescale 1ns / 1ps
//
// contents
// wam_main     // main function
// wam_dis      // digital tubes display
// wam_scr      // switch control and score count
// wam_gen      // moles generator
// wam_led      // led display

module wam_m(
    input wire clk,         // clock
    input wire clr,         // button - clear
    input wire lft,         // button - left
    input wire rgt,         // button - right
    input wire pse,         // button - pause
    input wire [7:0] sw,    // switch
    output wire [3:0] an,   // digital tube - analog
    output wire [6:0] a2g,  // digital tube - stroke
    output wire [7:0] ld
    );

    reg  [31:0] clk_cnt;    // clock count
    wire clk_16;            // clock at 2^16
    reg  clk_19;            // clock at 2^19
    reg  pse_flg;

    wire cout0;
    wire [3:0] hrdn;        // hardness of 0~9
    wire [3:0] age;
    wire [7:0] rto;

    wire [7:0]  holes;      // 8 holes, each is a 4-bit counter
    wire [7:0]  tap;
    wire [7:0]  hit;
    wire [11:0] score;      // score

    // handle clock
    always @(posedge clk) begin
        // if(clr)          // DO NOT clear main clock as it is seed of randomizer
        //     clk_cnt = 0;
        // else begin
        begin
            clk_cnt = clk_cnt + 1;
            if(clk_cnt[31:28]>15)
                clk_cnt = 0;
        end
    end

    assign clk_16 = clk_cnt[16];

    always @ (posedge pse) begin
        pse_flg = ~pse_flg;
    end

    always @ (posedge clk) begin
        if (!pse_flg)
            clk_19 = clk_cnt[19];
    end

    // generate moles
    wam_hrd sub_hrd( .clk_19(clk_19), .clr(clr), .lft(lft), .rgt(rgt), .cout0(cout0), .hrdn(hrdn) );
    wam_gen sub_gen( .clk_19(clk_19), .clr(clr), .clk_cnt(clk_cnt), .hit(hit), .hrdn(hrdn), .holes(holes) );
    wam_led sub_led( .holes(holes), .ld(ld) );

    // handle input tap
    wam_tap sub_tap( .clk_19(clk_19), .sw(sw), .tap(tap) );
    wam_hit sub_hit( .clk_19(clk_19), .tap(tap), .holes(holes), .hit(hit) );

    // handle score count
    wam_scr sub_scr( .clk(clk), .clr(clr), .hit(hit), .num(score), .cout0(cout0) );

    // handle display on digital tube
    wam_dis sub_dis( .clk_16(clk_16), .hrdn(hrdn), .score(score), .an(an), .a2g(a2g) );
endmodule
