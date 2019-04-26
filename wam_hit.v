module wam_tap (            // input switch
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

module wam_hit (            // get successful hit condition
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
