module vedic_4bit_mul (
    input [3:0] a,
    input [3:0] b,
    output [7:0] m
);

    // Partial products from 2-bit multipliers
    wire [3:0] p0, p1, p2, p3;
    
    wire [3:0] temp1, temp2, temp3;
    wire cout1, cout2, cout3;
    wire cin3;

    // Four 2-bit Vedic multipliers
    vedic_2bit_mul m1 (.a(a[1:0]), .b(b[1:0]), .m(p0));
    vedic_2bit_mul m2 (.a(a[1:0]), .b(b[3:2]), .m(p1));
    vedic_2bit_mul m3 (.a(a[3:2]), .b(b[1:0]), .m(p2));
    vedic_2bit_mul m4 (.a(a[3:2]), .b(b[3:2]), .m(p3));

    // First addition: p1 + p2 (both at bit position 2)
    cla_nbit #(.WIDTH(4)) adder1 (
        .a(p1),
        .b(p2),
        .cin(1'b0),
        .sum(temp1),
        .cout(cout1)
    );

    // Second addition: temp1 + upper 2 bits of p0 (shifted)
    cla_nbit #(.WIDTH(4)) adder2 (
        .a(temp1),
        .b({2'b00, p0[3:2]}),  // Fixed: was p0[3:4] which is invalid
        .cin(1'b0),
        .sum(temp2),
        .cout(cout2)
    );

    // Combine carries for next addition
    assign cin3 = cout1 | cout2;  // Fixed: 'or' should be '|'

    // Third addition: combine with p3
    cla_nbit #(.WIDTH(4)) adder3 (  // Fixed: was 'adder2' again
        .a({1'b0, cin3, temp2[3:2]}),
        .b(p3),
        .cin(1'b0),
        .sum(temp3),
        .cout(cout3)
    );

    // Final result assembly
    assign m = {temp3, temp2[1:0], p0[1:0]};  // Fixed: corrected bit slicing

endmodule

/*

    Time    A       B       Product
    0        0       0        0 (0)
    20       0       1        0 (0)
    30       0       2        0 (0)
    40       0       3        0 (0)
    50       0       4        0 (0)
    180      1       1        1 (1)
    190      1       2        2 (2)
    200      1       3        3 (3)
    210      1       4        4 (4)
    320      1      15       15 (15)
    330      2       0        0 (0)
    340      2       1        2 (2)
    350      2       2        4 (4)
    360      2       3        6 (6)
    370      2       4        8 (8)
    380      2       5       10 (10)
    490      3       0        0 (0)
    500      3       1        3 (3)
    510      3       2        6 (6)
    520      3       3        9 (9)
    600      3      11       33 (33)
    610      3      12       36 (36)
    620      3      13       39 (39)
    630      3      14       42 (42)
    640      3      15       45 (45)
    650      4       0        0 (0)
    740      4       9       36 (36)
    750      4      10       40 (40)
    760      4      11       44 (44)
    770      4      12       48 (48)
    780      4      13       52 (52)
    790      4      14       56 (56)
    800      4      15       60 (60)
    810      5       0        0 (0)
    820      5       1        5 (5)
    830      5       2       10 (10)
    840      5       3       15 (15)
    1810    11       4       44 (44)
    1820    11       5       55 (55)
    1830    11       6       66 (66)
    1840    11       7       77 (77)
    1850    11       8       88 (88)
    1860    11       9       99 (99)
    1990    12       6       72 (72)
    2540    15      13      195 (195)
    2550    15      14      210 (210)
    2560    15      15      225 (225)

*/
