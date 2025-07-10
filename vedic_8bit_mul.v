module vedic_8bit_mul (
    input [7:0] a,
    input [7:0] b,
    output [15:0] m
);

    // Partial products from 4-bit multipliers (8-bit results each)
    wire [7:0] p0, p1, p2, p3;  // Changed from [8:0] to [7:0]
    
    wire [7:0] temp1, temp2, temp3;  // Changed from [8:0] to [7:0]
    wire cout1, cout2, cout3;
    wire cin3;

    // Four 4-bit Vedic multipliers
    vedic_4bit_mul m1 (.a(a[3:0]), .b(b[3:0]), .m(p0));
    vedic_4bit_mul m2 (.a(a[3:0]), .b(b[7:4]), .m(p1));
    vedic_4bit_mul m3 (.a(a[7:4]), .b(b[3:0]), .m(p2));
    vedic_4bit_mul m4 (.a(a[7:4]), .b(b[7:4]), .m(p3));

    // First crosswise addition: p1 + p2 (both at bit position 4)
    cla_nbit #(.WIDTH(8)) adder1 (  // Fixed: missing closing parenthesis
        .a(p1),
        .b(p2),
        .cin(1'b0),
        .sum(temp1),
        .cout(cout1)
    );

    // Second crosswise addition: temp1 + upper 4 bits of p0
    cla_nbit #(.WIDTH(8)) adder2 (
        .a(temp1),
        .b({4'b0000, p0[7:4]}),
        .cin(1'b0),
        .sum(temp2),
        .cout(cout2)
    );

    // Combine carries for next addition
    assign cin3 = cout1 | cout2;

    // Third crosswise addition: combine with p3
    cla_nbit #(.WIDTH(8)) adder3 (
        .a({3'b00, cin3, temp2[7:4]}),  // Fixed: proper bit alignment
        .b(p3),
        .cin(1'b0),
        .sum(temp3),
        .cout(cout3)
    );

    // Final result assembly following Vedic pattern
    assign m = {temp3, temp2[3:0], p0[3:0]};

endmodule

/*
    238840  254     113     28702 (28702)
    238850  254     114     28956 (28956)
    238860  254     115     29210 (29210)
    238870  254     116     29464 (29464)
    238880  254     117     29718 (29718)
    238890  254     118     29972 (29972)
    238900  254     119     30226 (30226)
    238910  254     120     30480 (30480)

    230130  248     172     42656 (42656)
    230140  248     173     42904 (42904)
    230150  248     174     43152 (43152)
    230160  248     175     43400 (43400)
    230170  248     176     43648 (43648)
*/