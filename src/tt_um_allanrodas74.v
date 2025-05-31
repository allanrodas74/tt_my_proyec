// Módulo principal solicitado por Tiny Tapeout
module tt_um_allanrodas74 (
    input  [7:0]  ui_in,
    output [7:0]  uo_out,
    input  [7:0]  uio_in,
    output [7:0]  uio_out,
    output [7:0]  uio_oe,
    input         clk,
    input         rst_n
);

    wire [7:0] result;
    wire carry_out;

    ALU_8bit alu (
        .a(ui_in[7:4]),
        .b(ui_in[3:0]),
        .sel(uio_in[2:0]),  // código de operación
        .result(result),
        .carry_out(carry_out)
    );

    assign uo_out = result;
    assign uio_out[0] = carry_out;
    assign uio_oe[0] = 1'b1; // habilita la salida
    assign uio_out[7:1] = 7'b0;
    assign uio_oe[7:1] = 7'b0;

endmodule

// Módulo ALU de 8 bits
module ALU_8bit (
    input  [3:0] a,
    input  [3:0] b,
    input  [2:0] sel,
    output reg [7:0] result,
    output reg carry_out
);
    wire [4:0] sum;
    PrefixAdder8 adder (
        .a(a),
        .b(b),
        .sum(sum)
    );

    always @(*) begin
        case (sel)
            3'b000: {carry_out, result} = {1'b0, a + b};      // suma normal
            3'b001: result = a - b;                            // resta
            3'b010: result = a & b;                            // AND
            3'b011: result = a | b;                            // OR
            3'b100: result = a ^ b;                            // XOR
            3'b101: result = a << 1;                           // shift left
            3'b110: result = a >> 1;                           // shift right
            3'b111: {carry_out, result} = {sum[4], sum[3:0]};  // suma por prefix adder
            default: result = 8'b00000000;
        endcase
    end
endmodule

// Módulo Prefix Adder de 8 bits (solo 4 bits útiles aquí)
module PrefixAdder8 (
    input  [3:0] a,
    input  [3:0] b,
    output [4:0] sum
);
    wire [3:0] g, p, c;

    assign g = a & b;          // generate
    assign p = a ^ b;          // propagate

    assign c[0] = 1'b0;
    assign c[1] = g[0] | (p[0] & c[0]);
    assign c[2] = g[1] | (p[1] & c[1]);
    assign c[3] = g[2] | (p[2] & c[2]);

    assign sum[0] = p[0] ^ c[0];
    assign sum[1] = p[1] ^ c[1];
    assign sum[2] = p[2] ^ c[2];
    assign sum[3] = p[3] ^ c[3];
    assign sum[4] = g[3] | (p[3] & c[3]);
endmodule
