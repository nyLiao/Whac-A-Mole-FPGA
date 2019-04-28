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
endmodule // wam_rdn

module wam_gen (            // control lives of moles
    input wire clk_19,
    input wire clr,
    input wire [31:0] clk_cnt,
    input wire [7:0]  hit,
    input wire [3:0]  hrdn,
    output reg [7:0]  holes         // which hole has moles
    );

    reg  [2:0]  clk_22_cnt;         // clk_22 counter, 3 bits on 2^19
    reg  [31:0] holes_cnt;          // counter of roles, 3 bits for each hole on 2^22
    wire [7:0]  rnum;               // random number

    wire [3:0]  age;                // moles lifelength
    wire [7:0]  rto;                // moles appearance ratio

    reg  [2:0]  j;                  // select holes in different rounds
    integer i;                      // index for holes in one round

    // get parameters
    wam_par par( .hrdn(hrdn), .age(age), .rto(rto) );

    // make random number
    wam_rdn rdn( .clk(clk_cnt[21]), .load(clr), .seed(~clk_cnt[7:0]), .num(rnum) );

    // 1-phrase stage machine
    always @ ( posedge clk_19 or posedge clr ) begin
        if (clr) begin
            holes <= 8'b0;
            holes_cnt <= 32'b0;
            j <= 0;
        end
        else begin
            if (clk_22_cnt < 3'b111) begin      // the clk_19 control
                clk_22_cnt <= clk_22_cnt + 1;
                for (i=0; i<8; i=i+1) begin
                    if (hit[i]) begin           // handle hit event
                        holes_cnt[4*i+:4] <= 4'b0000;
                        holes[i] <= 0;
                    end
                end
            end
            else begin                          // the clk_22 control
                clk_22_cnt <= 3'b000;
                for (i=0; i<8; i=i+1) begin
                    if (holes[i] > 0) begin                         // already have mole
                        if ((holes_cnt[4*i+:4] > age) || hit[i]) begin      // age decide moles' life
                            holes_cnt[4*i+:4] <= 4'b0000;
                            holes[i] <= 0;
                        end
                        else begin                                  // count moles' life
                            holes_cnt[4*i+:4] <= holes_cnt[4*i+:4] + 1;
                        end
                    end
                    else begin                                      // no mole yet
                        if (rnum < rto) begin                       // rto decide new mole or not
                            if (j==i) begin                         // new mole in random hole j
                                holes_cnt[4*i+:4] <= 4'b0001;
                                holes[i] <= 1;
                            end
                        end
                    end
                end
                j <= j + 1;
            end
        end
    end
endmodule // wam_gen
