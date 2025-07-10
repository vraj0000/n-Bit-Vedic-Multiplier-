module vedic_128bit_mul (
    input [127:0] a,
    input [127:0] b,
    output [255:0] m
);

    wire [127:0] p0, p1, p2, p3; 
    
    wire [127:0] temp1, temp2, temp3; 
    wire cout1, cout2, cout3;
    wire cin3;

    vedic_64bit_mul m1 (.a(a[63:0]), .b(b[63:0]), .m(p0));
    vedic_64bit_mul m2 (.a(a[63:0]), .b(b[127:64]), .m(p1));
    vedic_64bit_mul m3 (.a(a[127:64]), .b(b[63:0]), .m(p2));
    vedic_64bit_mul m4 (.a(a[127:64]), .b(b[127:64]), .m(p3));

    cla_nbit #(.WIDTH(128)) adder1 ( 
        .b(p2),
        .cin(1'b0),
        .sum(temp1),
        .cout(cout1)
    );

    cla_nbit #(.WIDTH(128)) adder2 (
        .a(temp1),
        .b({64'h0000, p0[127:64]}),
        .cin(1'b0),
        .sum(temp2),
        .cout(cout2)
    );

    assign cin3 = cout1 | cout2;

    cla_nbit #(.WIDTH(128)) adder3 (
        .a({3'b000,60'h000000000000000, cin3, temp2[127:64]}),  
        .b(p3),
        .cin(1'b0),
        .sum(temp3),
        .cout(cout3)
    );

    assign m = {temp3, temp2[63:0], p0[63:0]};

endmodule