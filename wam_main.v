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
    output wire [6:0] a2g   // digital tube - stroke
    //output wire [3:0] ld
    );

    reg  [32:0] clk_cnt;    // clock count
    wire [3:0]  holes [7:0];        //
    wire [7:0]  tap;
    wire [7:0]  hit;
    wire [11:0] score;      // score

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
    wam_tap sub_tap( .clk(clk), .clr(clr), .clk_cnt(clk_cnt), .sw(sw), .tap(tap) );
    wam_hit sub_hit( .tap(tap), .hit(hit) );
    wam_swc sub_swc( .clk(clk), .clr(clr), .hit(hit), .num(score) );

    // handle display on digital tube
    wam_dis sub_dis( .sbit(clk_cnt[16:15]), .score(score), .an(an), .a2g(a2g) );
endmodule
