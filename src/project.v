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

endmodule

