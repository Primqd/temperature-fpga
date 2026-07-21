module top(
    input CLK,
    inout PMOD1, // for reading RC value
    output reg LED1,
    output reg LED2,
    output reg LED3,
    output reg LED4,
    output S1_A,
    output S1_B,
    output S1_C,
    output S1_D,
    output S1_E,
    output S1_F,
    output S1_G,
    output S2_A,
    output S2_B,
    output S2_C,
    output S2_D,
    output S2_E,
    output S2_F,
    output S2_G
);
    // states
    localparam RESET = 2'b00;
    localparam DISCHARGE = 2'b01;
    localparam CHARGE = 2'b10;

    // clk cycles till 100ms
    localparam MS100 = 25'd2_499_999;

    // thresholds for clk zones, currently arbitrary
    localparam THRESH_COLD = 18000; // above = cold
    localparam THRESH_HOT = 10250; // below = HOT

    // state and next state for FSM
    reg [1:0] state = RESET;
    reg [1:0] next_state;

    // whether discharge has been measured
    reg timer_discharge_done = 1'b0;
    reg [25:0] counter_discharge = 0; // clk cycles to "fully discharge" RC circuit, cnt for exactly 10ms

    // whether charging is done
    reg timer_charge_done = 1'b0;
    reg [25:0] counter_charge = 0;

    reg control;

    assign PMOD1 = control ? 1'b0 : 1'bz; // control == 1 --> input, otherwise listening

    // assign look-up table for clock to ones and twos digit
    reg [3:0] ones [0:255]; // 256 words, 8 bits wide
    reg [3:0] tens [0:255];

    initial begin
        $readmemh("lut_ones.mem", ones);
        $readmemh("lut_tens.mem", tens);
    end

    always @(posedge CLK) begin
        state <= next_state;
        case(state)
            RESET: begin // reset
                d1 <= tens[counter_charge[15:8]]; // use full third and fourth hex bits
                d2 <= ones[counter_charge[15:8]];
                counter_discharge <= 0;
                counter_charge <= 0;
                timer_charge_done <= 0;
                timer_discharge_done <= 0;
                if(counter_charge > THRESH_COLD) begin// cold
                    LED1 = 1'b1;
                    LED2 = 1'b0;
                    LED3 = 1'b0;
                end
                else if(counter_charge < THRESH_HOT) begin // hot
                    LED1 = 1'b1;
                    LED2 = 1'b1;
                    LED3 = 1'b1;
                end
                else begin // warm
                    LED1 = 1'b1;
                    LED2 = 1'b1;
                    LED3 = 1'b0;
                end 
            end

            DISCHARGE: begin
                if(counter_discharge >= MS100) timer_discharge_done <= 1'b1; // done discharging
                else counter_discharge <= counter_discharge + 1'b1; // continue counting
            end

            CHARGE: begin
                if(PMOD1) timer_charge_done <= 1'b1; // PMOD currently listening, capacitor is finished charging 
                else counter_charge <= counter_charge + 1'b1;
            end
        endcase
    end

    always @(*) begin // state handling
        control = 1'b0;
        case (state)

        RESET: begin
            // go directly to discharging
            next_state = DISCHARGE;
        end

        DISCHARGE: begin
            control = 1'b1; 
            if(timer_discharge_done) next_state = CHARGE;
            else next_state = DISCHARGE;
        end

        CHARGE: begin
            control = 1'b0;
            if(timer_charge_done) next_state = RESET; // done cycle, go reset
            else next_state = CHARGE;
        end

        default: next_state = RESET;
        endcase
    end

    reg [3:0] d1 = 0;
    reg [3:0] d2 = 0;
    hex_sseg a (
        .bin_in(d1),
        .sseg_out({S1_G, S1_F, S1_E, S1_D, S1_C, S1_B, S1_A})
    );

    hex_sseg b (
        .bin_in(d2),
        .sseg_out({S2_G, S2_F, S2_E, S2_D, S2_C, S2_B, S2_A})
    );
endmodule