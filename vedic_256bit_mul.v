module vedic_256bit_mul (
    input [255:0] a,
    input [255:0] b,
    output [511:0] m
);

    wire [255:0] p0, p1, p2, p3; 
    
    wire [255:0] temp1, temp2, temp3; 
    wire cout1, cout2, cout3;
    wire cin3;

    vedic_128bit_mul m1 (.a(a[127:0]), .b(b[127:0]), .m(p0));
    vedic_128bit_mul m2 (.a(a[127:0]), .b(b[255:128]), .m(p1));
    vedic_128bit_mul m3 (.a(a[255:128]), .b(b[127:0]), .m(p2));
    vedic_128bit_mul m4 (.a(a[255:128]), .b(b[255:128]), .m(p3));

    cla_nbit #(.WIDTH(256)) adder1 (  
        .a(p1),
        .b(p2),
        .cin(1'b0),
        .sum(temp1),
        .cout(cout1)
    );

    cla_nbit #(.WIDTH(256)) adder2 (
        .a(temp1),
        .b({128'h0000, p0[255:128]}),
        .cin(1'b0),
        .sum(temp2),
        .cout(cout2)
    );

    assign cin3 = cout1 | cout2;

    cla_nbit #(.WIDTH(256)) adder3 (
        .a({127'h0, cin3, temp2[255:128]}), 
        .b(p3),
        .cin(1'b0),
        .sum(temp3),
        .cout(cout3)
    );

    assign m = {temp3, temp2[127:0], p0[127:0]};

endmodule