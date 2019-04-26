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

module wam_hrd (
    input wire clk,
    input wire clr,
    input wire lft,
    input wire rgt,
    input wire cout0,
    output reg [3:0] hrdn,          // hardness of 0~9
    output reg [3:0] age,
    output reg [7:0] rto
    );

    reg [4:0] hrdn0;
    wire harder;
    wire easier;

    assign easier = lft;
    assign harder = rgt | cout0;

    always @ ( posedge harder or posedge easier ) begin
        if (easier) begin               // lft: easier
            if (hrdn > 0) begin
                hrdn0 <= hrdn0 - 4'b0001;
            end
        end
        else begin                      // rgt or cout0: harder
            if (hrdn < 10) begin
                hrdn0 <= hrdn0 + 4'b0001;
            end
        end
    end

    always @ (posedge clk or posedge clr) begin
        if (clr) begin
            hrdn <= 0;
        end
        else begin
            hrdn <= hrdn0[3:0];
        end
    end

    always @ ( * ) begin
        case (hrdn)
            'h0: begin
                age <= 4'd14;
                rto <= 42;
            end
            'h1: begin
                age <= 4'd11;
                rto <= 62;
            end
            'h2: begin
                age <= 4'd09;
                rto <= 76;
            end
            'h3: begin
                age <= 4'd07;
                rto <= 87;
            end
            'h4: begin
                age <= 4'd06;
                rto <= 93;
            end
            'h5: begin
                age <= 4'd05;
                rto <= 96;
            end
            'h6: begin
                age <= 4'd04;
                rto <= 93;
            end
            'h7: begin
                age <= 4'd04;
                rto <= 87;
            end
            'h8: begin
                age <= 4'd03;
                rto <= 76;
            end
            'h9: begin
                age <= 4'd03;
                rto <= 61;
            end
            'hA: begin
                age <= 4'd01;
                rto <= 200;
            end
            default: begin
                age <= 4'b0111;
                rto <= 70;
            end
        endcase
    end

endmodule // wam_hrd

module wam_gen (            // control lives of moles
    input wire clk_19,
    input wire clr,
    input wire [31:0] clk_cnt,
    input wire [7:0]  hit,
    input wire [3:0]  age,
    input wire [7:0]  rto,
    output reg [7:0]  holes         // which hole has moles
    );

    reg  [2:0] clk_22_cnt;          // clk_22 counter, 3 bits on 2^19
    reg  [31:0] holes_cnt;          // counter of roles, 3 bits for each hole on 2^22
    wire [7:0] rnum;                // random number

    reg  [2:0] j;                   // select holes in different rounds
    integer i;                      // index for holes in one round

    // make random number
    wam_rdn rdn1( .clk(clk_cnt[21]), .load(clr), .seed(~clk_cnt[7:0]), .num(rnum) );

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
                        if ((holes_cnt[4*i+:4] >= age) || hit[i]) begin      // count moles' life
                            holes_cnt[4*i+:4] <= 4'b0000;
                            holes[i] <= 0;
                        end
                        else begin                                  // die
                            holes_cnt[4*i+:4] <= holes_cnt[4*i+:4] + 1;
                        end
                    end
                    else begin                                      // no mole yet
                        if (rnum < rto) begin
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
    end
endmodule // wam_gen
