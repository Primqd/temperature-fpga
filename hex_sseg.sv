module hex_sseg ( // reads bin_in and displays it as an active-low sseg in sseg_out
    input  logic [3:0] bin_in,   // 4-bit binary input (0 to 15)
    output logic [6:0] sseg_out  // 7-bit output mapped to hex number
);

    always_comb begin
        case (bin_in)
            4'h0: sseg_out = 7'b100_0000; // Displays 0
            4'h1: sseg_out = 7'b111_1001; // Displays 1
            4'h2: sseg_out = 7'b010_0100; // Displays 2
            4'h3: sseg_out = 7'b011_0000; // Displays 3
            4'h4: sseg_out = 7'b001_1001; // Displays 4
            4'h5: sseg_out = 7'b001_0010; // Displays 5
            4'h6: sseg_out = 7'b000_0010; // Displays 6
            4'h7: sseg_out = 7'b111_1000; // Displays 7
            4'h8: sseg_out = 7'b000_0000; // Displays 8
            4'h9: sseg_out = 7'b001_0000; // Displays 9
            4'hA: sseg_out = 7'b000_1000; // Displays A
            4'hB: sseg_out = 7'b000_0011; // Displays b
            4'hC: sseg_out = 7'b100_0110; // Displays C
            4'hD: sseg_out = 7'b010_0001; // Displays d
            4'hE: sseg_out = 7'b000_0110; // Displays E
            4'hF: sseg_out = 7'b000_1110; // Displays F
            default: sseg_out = 7'b111_1111; // All segments OFF
        endcase
    end

endmodule