module robotic_sensor_tb;

    reg  [2:0] G, Y, S;
    wire [3:0] result;
    wire       overflow, blank, show_E, show_U;

    robotic_sensor uut (
        .G(G), .Y(Y), .S(S),
        .result(result),
        .overflow(overflow),
        .blank(blank),
        .show_E(show_E),
        .show_U(show_U)
    );

    initial begin
        // S=000 | 2G | G=3 → result=6, no overflow
        G=3'd3; Y=3'd0; S=3'b000; #10;
        // S=000 | 2G | G=5 → result=10, OVERFLOW
        G=3'd5; Y=3'd0; S=3'b000; #10;

        // S=001 | 3Y | Y=2 → result=6, no overflow
        G=3'd0; Y=3'd2; S=3'b001; #10;
        // S=001 | 3Y | Y=4 → result=12, OVERFLOW
        G=3'd0; Y=3'd4; S=3'b001; #10;

        // S=010 | G==Y → show_E
        G=3'd4; Y=3'd4; S=3'b010; #10;
        // S=010 | G!=Y → show_U
        G=3'd3; Y=3'd5; S=3'b010; #10;

        // S=011 | G+3 | G=3 → result=6, no overflow
        G=3'd3; Y=3'd0; S=3'b011; #10;
        // S=011 | G+3 | G=6 → result=9, OVERFLOW
        G=3'd6; Y=3'd0; S=3'b011; #10;

        // S=100 | 7-Y | Y=4 → result=3
        G=3'd0; Y=3'd4; S=3'b100; #10;
        // S=100 | 7-Y | Y=0 → result=7
        G=3'd0; Y=3'd0; S=3'b100; #10;

        // S=101 | (G+Y)/2 | G=4, Y=6 → result=5
        G=3'd4; Y=3'd6; S=3'b101; #10;
        // S=101 | (G+Y)/2 | G=3, Y=4 → result=3 (truncated)
        G=3'd3; Y=3'd4; S=3'b101; #10;

        // S=110 | G-Y | G=5, Y=3 → result=2
        G=3'd5; Y=3'd3; S=3'b110; #10;
        // S=110 | G-Y | G=2, Y=5 → result=0 (clamped)
        G=3'd2; Y=3'd5; S=3'b110; #10;

        // S=111 | System Off → blank
        G=3'd0; Y=3'd0; S=3'b111; #10;

        $stop;
    end

    // optional monitor for waveform-less debugging
    initial begin
        $monitor("t=%0t S=%b G=%0d Y=%0d | result=%0d overflow=%b blank=%b E=%b U=%b",
                 $time, S, G, Y, result, overflow, blank, show_E, show_U);
    end

endmodule