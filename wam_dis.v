module wam_led (            // LED output
    input  wire [7:0] holes,
    output wire [7:0] ld
    );

    assign ld = holes;
endmodule // wam_led

module wam_obd(             // 1-bit digital tube output
    input wire [3:0] num,
    output reg [6:0] a2g
    );

    always @(*) begin
        case(num)
            'h0: a2g=7'b0000001;
            'h1: a2g=7'b1001111;
            'h2: a2g=7'b0010010;
            'h3: a2g=7'b0000110;
            'h4: a2g=7'b1001100;
            'h5: a2g=7'b0100100;
            'h6: a2g=7'b0100000;
            'h7: a2g=7'b0001111;
            'h8: a2g=7'b0000000;
            'h9: a2g=7'b0000100;
            'hA: a2g=7'b1001000;        // use A for H
            'hB: a2g=7'b0011100;        // use B for higher o
            'hC: a2g=7'b0110001;
            'hD: a2g=7'b1000010;
            'hE: a2g=7'b0110000;
            'hF: a2g=7'b1111111;        // use F for blank
            default: a2g=7'b1111111;    // default is blank
        endcase
    end
endmodule // wam_obd

module wam_lst (            // digital first bit (hardness bit) flashing for tap or hardness change
    input wire clk_19,
    input wire [7:0] tap,
    input wire lft,
    input wire rgt,
    input wire cout0,
    output reg lstn
    );

    reg  [3:0] cnt;     // counter
    wire trg;           // trigger signal
    wire cout0s;        // cout0 signal conveter

    wam_tch tchc( .clk_19(clk_19), .btn(cout0), .tch(cout0s));
    assign trg = tap[0] | tap[1] | tap[2] | tap[3] | tap[4] | tap[5] | tap[6] | tap[7] | lft | rgt | cout0s;

    always @ (posedge clk_19) begin
        if (cnt > 0) begin                  // lasting
            if (cnt > 4'b0100) begin        // long enough
                cnt <= 4'b0000;
                lstn <= 0;                  // dim
            end
            else begin
                cnt <= cnt + 1;
            end
        end
        else begin                          // idle
            if (trg) begin                  // if trigger then light up
                cnt <= 4'b0001;
                lstn <= 1;
            end
        end
    end
endmodule // wam_lst

module wam_dis(             // handle digital tube output
    input clk_16,
    input wire  [3:0]  hrdn,
    input wire  [11:0] score,
    input wire  lstn,
    output reg  [3:0]  an,
    output wire [6:0]  a2g
    );

    reg [1:0] clk_16_cnt;   // counter
    reg [3:0] dnum;         // displaying number

    always @ (posedge clk_16) begin
        clk_16_cnt <= clk_16_cnt + 1;
    end

    always @(*) begin
        case(clk_16_cnt)    // choose which tube to display
            2'b00: begin
                dnum = score[3:0];
                an = 4'b1110;
            end
            2'b01: begin
                dnum = score[7:4];
                an = 4'b1101;
            end
            2'b10: begin
                dnum = score[11:8];
                an = 4'b1011;
            end
            2'b11: begin
                dnum = hrdn;
                if (lstn)
                    an = 4'b0111;
                else
                    an = 4'b1111;
            end
        endcase
    end
    wam_obd obd( .num(dnum), .a2g(a2g) );
endmodule // wam_dis
