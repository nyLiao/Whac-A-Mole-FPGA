module wam_obd(           // 1-bit digital tube output
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
            'hA: a2g=7'b0001000;
            'hB: a2g=7'b1100000;
            'hC: a2g=7'b0110001;
            'hD: a2g=7'b1000010;
            'hE: a2g=7'b0110000;
            'hF: a2g=7'b0111000;
            default: a2g=7'b0000001;
        endcase
    end
endmodule

module wam_dis(           // handle digital tube output
    input wire sbit,
    input wire [7:0] score,
    output wire [3:0] an,
    output wire [6:0] a2g
    );

    reg [3:0] dnum;

    assign an[1] =  sbit;
    assign an[0] = ~sbit;
    assign an[3:2] = 2'b11;

    always @(*)
        case(sbit)
            1: dnum = score[3:0];
            0: dnum = score[7:4];
        endcase
    wam_obd obd( .num(dnum), .a2g(a2g) );
endmodule
