module wam_hrd (
    input wire clr,
    input wire lft,
    input wire rgt,
    input wire cout0,
    output reg [3:0] hrdn,          // hardness of 0~9
    output reg [3:0] age,
    output reg [7:0] rto
    );

    wire harder;
    wire easier;

    assign easier = lft;
    assign harder = rgt | cout0;

    reg c0, c1, c2;

    always @ ( posedge clr or posedge harder or posedge easier ) begin
        if (clr)
            hrdn = 0;
        else if (easier) begin          // lft: easier
            if (hrdn > 0) begin
                c0 = (~hrdn[0]) & 1;
                hrdn[0] = hrdn[0] ^ 1;

                c1 = (~hrdn[1]&(1^c0))|(1&c0);
                hrdn[1] = hrdn[1] ^ 1 ^ c0;

                c2 = (~hrdn[2]&(1^c1))|(1&c1);
                hrdn[2] = hrdn[2] ^ 1 ^ c1;

                hrdn[3] = hrdn[3] ^ 1 ^ c2;
            end
        end
        else begin                      // rgt or cout0: harder
            if (hrdn < 10) begin
                hrdn = hrdn + 4'b0001;
            end
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

module wam_par ();

endmodule // wam_par
