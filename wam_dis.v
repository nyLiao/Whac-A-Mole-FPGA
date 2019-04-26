module wam_led (            // led output
    input wire [7:0]  holes,
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

module wam_dis(             // handle digital tube output
    input clk_16,
    input wire [3:0] hrdn,
    input wire [11:0] score,
    output reg [3:0] an,
    output wire [6:0] a2g
    );

    reg [1:0] clk_16_cnt;
    reg [3:0] dnum;

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
                dnum = hrdn; //4'hB;
                an = 4'b0111;
            end
        endcase
    end
    wam_obd obd( .num(dnum), .a2g(a2g) );
endmodule // wam_dis
