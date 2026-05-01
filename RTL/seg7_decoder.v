module seg7_decoder (
    input  [3:0] result,
    input        overflow,
    input        blank,
    input        show_E,
    input        show_U,
    output reg [6:0] seg  // active LOW: seg[6:0] = {g, f, e, d, c, b, a}
);

    always @(*) begin
        if (blank)
            seg = 7'b1111111;   // all segments OFF (system off)
        else if (overflow)
            seg = 7'b0110111;   // '=' : segments g (middle) and d (bottom) ON
        else if (show_E)
            seg = 7'b0000110;   // 'E' : segments a, f, g, e, d ON
        else if (show_U)
            seg = 7'b1000001;   // 'U' : segments b, c, d, e, f ON
        else begin
            case (result)
                4'd0: seg = 7'b1000000; // 0
                4'd1: seg = 7'b1111001; // 1
                4'd2: seg = 7'b0100100; // 2
                4'd3: seg = 7'b0110000; // 3
                4'd4: seg = 7'b0011001; // 4
                4'd5: seg = 7'b0010010; // 5
                4'd6: seg = 7'b0000010; // 6
                4'd7: seg = 7'b1111000; // 7
                4'd8: seg = 7'b0000000; // 8
                4'd9: seg = 7'b0010000; // 9
                default: seg = 7'b1111111; // blank for undefined states
            endcase
        end
    end

endmodule