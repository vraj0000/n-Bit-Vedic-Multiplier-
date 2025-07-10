module vedic_nbit_mul #(parameter WIDTH = 64) (
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output [2*WIDTH-1:0] m
);

    // Assert that WIDTH is a power of 2 and at least 2
    initial begin
        if (WIDTH < 2 || (WIDTH & (WIDTH - 1)) != 0) begin
            $fatal(1, "Error: WIDTH must be a power of 2 and at least 2 for vedic_mul.");
        end
    end

    generate
        // Base case: 2-bit multiplier the leaf of the mutipler
        if (WIDTH == 2) begin : gen_2bit_mul
            wire p0, p1, p2, p3; // partial products
            wire c1;             // intermediate carry for 1st adder

            assign p0 = a[0] & b[0];
            assign p1 = a[1] & b[0];
            assign p2 = a[0] & b[1];
            assign p3 = a[1] & b[1];
            assign c1 = p1 & p2; // Corrected logic based on Vedic 2-bit mul

            assign m[0] = p0;
            assign m[1] = p1 ^ p2;
            assign m[2] = c1 ^ p3;
            assign m[3] = c1 & p3;
        end else begin : gen_recursive_mul
            // Recursive case: Break down into four smaller multipliers
            localparam integer HALF_WIDTH = WIDTH / 2;

            wire [WIDTH-1:0] p0_sub, p1_sub, p2_sub, p3_sub; // Partial products from sub-multipliers
            wire [WIDTH-1:0] temp1, temp2, temp3;
            wire cout1, cout2, cout3;
            wire cin3;

            // Four sub-multipliers, each operating on HALF_WIDTH bits
            vedic_nbit_mul #(.WIDTH(HALF_WIDTH)) m1 (.a(a[HALF_WIDTH-1:0]), .b(b[HALF_WIDTH-1:0]), .m(p0_sub));
            vedic_nbit_mul #(.WIDTH(HALF_WIDTH)) m2 (.a(a[HALF_WIDTH-1:0]), .b(b[WIDTH-1:HALF_WIDTH]), .m(p1_sub));
            vedic_nbit_mul #(.WIDTH(HALF_WIDTH)) m3 (.a(a[WIDTH-1:HALF_WIDTH]), .b(b[HALF_WIDTH-1:0]), .m(p2_sub));
            vedic_nbit_mul #(.WIDTH(HALF_WIDTH)) m4 (.a(a[WIDTH-1:HALF_WIDTH]), .b(b[WIDTH-1:HALF_WIDTH]), .m(p3_sub));

            // First crosswise addition: p1_sub + p2_sub
            cla_nbit #(.WIDTH(WIDTH)) adder1 (
                .a(p1_sub),
                .b(p2_sub),
                .cin(1'b0),
                .sum(temp1),
                .cout(cout1)
            );

            // Second crosswise addition: temp1 + upper half of p0_sub
            localparam integer ZERO_PAD_WIDTH_ADDER2 = WIDTH - HALF_WIDTH;
            wire [ZERO_PAD_WIDTH_ADDER2-1:0] zeros_for_adder2_pad;
            assign zeros_for_adder2_pad = '0; // Assign all bits to zero

            wire [WIDTH-1:0] b_adder2_padded;
            assign b_adder2_padded = {zeros_for_adder2_pad, p0_sub[WIDTH-1:HALF_WIDTH]};

            cla_nbit #(.WIDTH(WIDTH)) adder2 (
                .a(temp1),
                .b(b_adder2_padded),
                .cin(1'b0),
                .sum(temp2),
                .cout(cout2)
            );

            // Combine carries for next addition
            assign cin3 = cout1 | cout2;

            // Third crosswise addition: combine with p3_sub and combined carry
            localparam integer CONCAT_BITS_ADDER3 = HALF_WIDTH + 1;
            localparam integer ZERO_PAD_WIDTH_ADDER3 = WIDTH - CONCAT_BITS_ADDER3;
            // *** NEW: Explicit wire for zeros to avoid replication operator in concatenation ***
            wire [ZERO_PAD_WIDTH_ADDER3-1:0] zeros_for_adder3_pad;
            assign zeros_for_adder3_pad = '0; // Assign all bits to zero

            wire [WIDTH-1:0] a_adder3_padded;
            assign a_adder3_padded = {zeros_for_adder3_pad, cin3, temp2[WIDTH-1:HALF_WIDTH]};

            cla_nbit #(.WIDTH(WIDTH)) adder3 (
                .a(a_adder3_padded),
                .b(p3_sub),
                .cin(1'b0),
                .sum(temp3),
                .cout(cout3)
            );

            // Final result assembly following Vedic pattern
            assign m = {temp3[WIDTH-1:0], temp2[HALF_WIDTH-1:0], p0_sub[HALF_WIDTH-1:0]};
        end
    endgenerate

endmodule