module wam_rdn(             // generate 8-bit random number
    input wire clk,
    input wire load,
    input wire [7:0] seed,
    output reg [7:0] num
    );

    always @( posedge clk or posedge load ) begin
        if(load)
            num <= seed;            // load seed
        else begin                  // shift with feed back
            num[0] <= num[7];
            num[1] <= num[0];
            num[2] <= num[1];
            num[3] <= num[2];
            num[4] <= num[3]^num[7];
            num[5] <= num[4]^num[7];
            num[6] <= num[5]^num[7];
            num[7] <= num[6];
        end
    end
endmodule

module wam_gen (            // control life of moles
    input wire clk,
    input wire clr,
    input wire [32:0] clk_cnt,
    output reg [7:0]  holes         // which hole has moles
    );

    wire [7:0] clk_n;
    wire [7:0] rnum1;
    wire [7:0] rnum2;
    reg  [31:0] holes_cnt;          // counter of roles, 3 bits for each hole
    reg  [2:0] j;                   // select holes in different rounds
    integer i;                      // index for holes in one round

    assign clk_n = clk_cnt[29:22];      // new clock

    // make random number
    wam_rdn rdn1( .clk(clk_cnt[21]), .load(clr), .seed(~clk_cnt[7:0]), .num(rnum1) );
    // wam_rdn rdn2( .clk(clk), .clr(clr), .load(clk_cnt[30]), .seed(clk_cnt[7:0]), .num(rnum2) );

    always @ ( posedge clk_n[0] or posedge clr ) begin       // 1-phrase stage machine
        if (clr) begin
            holes <= 8'b0;
            holes_cnt <= 32'b0;
            j <= 0;
        end
        else begin
            for (i=0; i<8; i=i+1) begin
                if (holes[i] > 0) begin                         // already have mole
                    if (holes_cnt[4*i+:4] < 4'b0111) begin      // count
                        holes_cnt[4*i+:4] <= holes_cnt[4*i+:4] + 1;
                    end
                    else begin                                  // die
                        holes_cnt[4*i+:4] <= 4'b0000;
                        holes[i] <= 0;
                    end
                end
                else begin                                      // no mole yet
                    if (rnum1 < 50) begin
                        if (j==i) begin                         // new mole in hole j
                            holes_cnt[4*i+:4] <= 4'b0001;
                            holes[i] <= 1;
                        end
                    end
                end
            end
            j <= j + 1;
            // holes <= rnum1;
        end
    end
endmodule // wam_gen
