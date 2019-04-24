`timescale 1ns / 1ps
//
// contents
// wam_main     // main function
// wam_dis      // digital tubes display
// wam_swc      // switch control and score count
// wam_gen      // moles generator
// wam_led      // led display

module wam_m(
    input wire clk,         // clock
    input wire clr,         // button - clear
    input wire [7:0] sw,    // switch
    output wire [3:0] an,   // digital tube - analog
    output wire [6:0] a2g,  // digital tube - stroke
    output wire [7:0] ld
    );

    reg  [32:0] clk_cnt;    // clock count
    wire clk_16;            // clock at 2^16
    wire clk_19;
    wire clk_22;

    wire [7:0]  holes;      // 8 holes, each is a 4-bit counter
    wire [7:0]  tap;
    wire [7:0]  hit;
    wire [11:0] score;      // score

    // handle clock
    always @(posedge clk) begin
        // if(clr)
        //     clk_cnt = 0;
        // else begin
        begin
            clk_cnt = clk_cnt + 1;
            if(clk_cnt[32:29]>15)
                clk_cnt = 0;
        end
    end

    assign clk_16 = clk_cnt[16];
    assign clk_19 = clk_cnt[19];
    assign clk_22 = clk_cnt[22];

    wam_gen sub_gen( .clk_19(clk_19), .clr(clr), .clk_cnt(clk_cnt), .hit(hit), .holes(holes) );
    wam_led sub_led( .clk(clk), .holes(holes), .ld(ld) );
    // handle score count
    wam_tap sub_tap( .clk_19(clk_19), .sw(sw), .tap(tap) );
    wam_hit sub_hit( .clk_19(clk_19), .tap(tap), .holes(holes), .hit(hit) );
    wam_swc sub_swc( .clk(clk), .clr(clr), .hit(hit), .num(score) );

    // handle display on digital tube
    wam_dis sub_dis( .clk_16(clk_16), .score(score), .an(an), .a2g(a2g) );
endmodule
