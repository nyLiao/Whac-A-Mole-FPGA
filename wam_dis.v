module wam_obd(             // 1-bit digital tube output
    input wire [3:0] num,
    output reg [6:0] a2g
    );

    always @(*) begin
        case(num)
            0: a2g=7'b0000001;
            1: a2g=7'b1001111;
            2: a2g=7'b0010010;
            3: a2g=7'b0000110;
            4: a2g=7'b1001100;
            5: a2g=7'b0100100;
            6: a2g=7'b0100000;
            7: a2g=7'b0001111;
            8: a2g=7'b0000000;
            9: a2g=7'b0000100;
            'hA: a2g=7'b1111111;        // use A for blank
            'hB: a2g=7'b0011100;        // use B for higher o
            'hC: a2g=7'b0110001;
            'hD: a2g=7'b1000010;
            'hE: a2g=7'b0110000;
            'hF: a2g=7'b0111000;
            default: a2g=7'b1111111;    // default is blank
        endcase
    end
endmodule

module wam_dis(             // handle digital tube output
    input wire [1:0] sbit,
    input wire [11:0] score,
    output reg [3:0] an,
    output wire [6:0] a2g
    );

    reg [3:0] dnum;

    always @(*) begin
        case(sbit)
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
                dnum = 4'hB;
                an = 4'b0111;
            end
        endcase
    end
    wam_obd obd( .num(dnum), .a2g(a2g) );
endmodule
