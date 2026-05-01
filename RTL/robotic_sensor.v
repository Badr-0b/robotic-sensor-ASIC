module robotic_sensor (
    input  [2:0] G,
    input  [2:0] Y,
    input  [2:0] S,
    output reg [3:0] result,
    output reg       overflow,
    output reg       blank,
    output reg       show_E,
    output reg       show_U
);

    reg [4:0] temp; // 5-bit intermediate to catch overflow before truncating

    always @(*) begin
        // defaults
        result   = 4'd0;
        overflow = 1'b0;
        blank    = 1'b0;
        show_E   = 1'b0;
        show_U   = 1'b0;
        temp     = 5'd0;

        case (S)

            3'b000: begin // Motor Speed Mapping: 2G
                temp = {2'b00, G} << 1;
                if (temp > 5'd7) begin
                    overflow = 1'b1;
                    result   = 4'd0;
                end else
                    result = temp[3:0];
            end

            3'b001: begin // Turning Angle Mapping: 3Y
                temp = {2'b00, Y} + {2'b00, Y} + {2'b00, Y};
                if (temp > 5'd7) begin
                    overflow = 1'b1;
                    result   = 4'd0;
                end else
                    result = temp[3:0];
            end

            3'b010: begin // Sensor Comparison: E if G==Y, U otherwise
                if (G == Y) show_E = 1'b1;
                else        show_U = 1'b1;
            end

            3'b011: begin // Forward Adjustment: G + 3
                temp = {2'b00, G} + 5'd3;
                if (temp > 5'd7) begin
                    overflow = 1'b1;
                    result   = 4'd0;
                end else
                    result = temp[3:0];
            end

            3'b100: begin // Clearance Check: 7 - Y (always 0-7, no overflow possible)
                result = 4'd7 - {1'b0, Y};
            end

            3'b101: begin // Path Average: (G + Y) / 2
                // sum max = 14, fits in 5 bits; right shift 1 = divide by 2, result max = 7
                temp   = {2'b00, G} + {2'b00, Y};
                result = temp[4:1]; // integer division by 2
            end

            3'b110: begin // Difference: G - Y
                // clamp to 0 if negative (G < Y)
                if (G >= Y)
                    result = {1'b0, G} - {1'b0, Y};
                else
                    result = 4'd0;
            end

            3'b111: begin // System Off: blank display
                blank = 1'b1;
            end

        endcase
    end

endmodule