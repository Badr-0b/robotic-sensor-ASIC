module top (
    input  [2:0] G,         // front sensor input (SW[2:0])
    input  [2:0] Y,         // side sensor input  (SW[5:3])
    input  [2:0] S,         // select lines       (SW[8:6])
    output [6:0] seg,       // 7-segment display  (HEX0)
    output       overflow_led // overflow indicator (LEDR0)
);

    wire [3:0] result;
    wire overflow, blank, show_E, show_U;

    robotic_sensor rs_inst (
        .G        (G),
        .Y        (Y),
        .S        (S),
        .result   (result),
        .overflow (overflow),
        .blank    (blank),
        .show_E   (show_E),
        .show_U   (show_U)
    );

    seg7_decoder sd_inst (
        .result   (result),
        .overflow (overflow),
        .blank    (blank),
        .show_E   (show_E),
        .show_U   (show_U),
        .seg      (seg)
    );

    assign overflow_led = overflow;

endmodule