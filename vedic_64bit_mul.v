module vedic_64bit_mul (
    input [63:0] a,
    input [63:0] b,
    output [127:0] m
);

    wire [63:0] p0, p1, p2, p3; 
    
    wire [63:0] temp1, temp2, temp3; 
    wire cout1, cout2, cout3;
    wire cin3;

   
    vedic_32bit_mul m1 (.a(a[31:0]), .b(b[31:0]), .m(p0));
    vedic_32bit_mul m2 (.a(a[31:0]), .b(b[63:32]), .m(p1));
    vedic_32bit_mul m3 (.a(a[63:32]), .b(b[31:0]), .m(p2));
    vedic_32bit_mul m4 (.a(a[63:32]), .b(b[63:32]), .m(p3));

    
    cla_nbit #(.WIDTH(64)) adder1 (  
        .a(p1),
        .b(p2),
        .cin(1'b0),
        .sum(temp1),
        .cout(cout1)
    );

    
    cla_nbit #(.WIDTH(64)) adder2 (
        .a(temp1),
        .b({32'h0000, p0[63:32]}),
        .cin(1'b0),
        .sum(temp2),
        .cout(cout2)
    );

    assign cin3 = cout1 | cout2;

    cla_nbit #(.WIDTH(64)) adder3 (
        .a({3'b000,28'h0000000, cin3, temp2[63:32]}), 
        .cin(1'b0),
        .sum(temp3),
        .cout(cout3)
    );

    assign m = {temp3, temp2[31:0], p0[31:0]};

endmodule