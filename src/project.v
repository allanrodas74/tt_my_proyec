/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_allanrodas74 (
    input  [7:0]  ui_in,
    output [7:0]  uo_out,
    input  [7:0]  uio_in,
    output [7:0]  uio_out,
    output [7:0]  uio_oe,
    input clk,
    input  rst_n
);

    wire [7:0] result;
    wire carry_out;

    ALU_8bit alu (
        .a(ui_in),
        .b(uio_in),
        .sel(uio_in[2:0]),
        .result(result),
        .carry_out(carry_out)
    );

    assign uo_out = result;
    assign uio_out[0] = carry_out;
    assign uio_oe[0] = 1'b1;
    assign uio_out[7:1] = 7'b0;
    assign uio_oe[7:1] = 7'b0;

endmodule


module ALU_8bit (
    input  [7:0] a,
    input  [7:0] b,
    input  [2:0] sel,
    output reg [7:0] result,
    output reg carry_out
);

    wire [8:0] sum;
    wire [7:0] b_neg;
    wire [8:0] sum_sub;

    PrefixAdder8 prefix_adder (
        .a(a),
        .b(b),
        .sum(sum)
    );

    assign b_neg = ~b + 8'b1;

    PrefixAdder8 prefix_sub (
        .a(a),
        .b(b_neg),
        .sum(sum_sub)
    );

    always @(*) begin
        carry_out = 0;
        result = 0;
        case (sel)
            3'b000: begin // suma normal
                {carry_out, result} = sum;
            end
            3'b001: begin // resta usando suma con complemento a 2
                {carry_out, result} = sum_sub;
            end
            3'b010: result = a & b;
            3'b011: result = a | b;
            3'b100: result = a ^ b;
            3'b101: result = a << 1;
            3'b110: result = a >> 1;
            3'b111: begin // también suma
                {carry_out, result} = sum;
            end
            default: result = 8'b0;
        endcase
    end

endmodule


module PrefixAdder8 (
    input  [7:0] a,
    input  [7:0] b,
    output [8:0] sum
);
    wire [7:0] g, p;
    wire [7:0] c;

    assign g = a & b;
    assign p = a ^ b;

    assign c[0] = 1'b0;
    assign c[1] = g[0] | (p[0] & c[0]);
    assign c[2] = g[1] | (p[1] & c[1]);
    assign c[3] = g[2] | (p[2] & c[2]);
    assign c[4] = g[3] | (p[3] & c[3]);
    assign c[5] = g[4] | (p[4] & c[4]);
    assign c[6] = g[5] | (p[5] & c[5]);
    assign c[7] = g[6] | (p[6] & c[6]);
    wire c8 = g[7] | (p[7] & c[7]);

    assign sum[0] = p[0] ^ c[0];
    assign sum[1] = p[1] ^ c[1];
    assign sum[2] = p[2] ^ c[2];
    assign sum[3] = p[3] ^ c[3];
    assign sum[4] = p[4] ^ c[4];
    assign sum[5] = p[5] ^ c[5];
    assign sum[6] = p[6] ^ c[6];
    assign sum[7] = p[7] ^ c[7];
    assign sum[8] = c8;

endmodule

