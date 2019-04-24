module wam_led (
    input wire clk,
    input wire [7:0]  holes,
    output wire [7:0] ld
    );

    integer i;

    assign ld = holes;

endmodule // wam_led
