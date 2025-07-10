module vedic_32bit_mul (
    input [31:0] a,
    input [31:0] b,
    output [63:0] m
);

    wire [31:0] p0, p1, p2, p3; 
    
    wire [31:0] temp1, temp2, temp3; 
    wire cout1, cout2, cout3;
    wire cin3;

    vedic_16bit_mul m1 (.a(a[15:0]), .b(b[15:0]), .m(p0));
    vedic_16bit_mul m2 (.a(a[15:0]), .b(b[31:16]), .m(p1));
    vedic_16bit_mul m3 (.a(a[31:16]), .b(b[15:0]), .m(p2));
    vedic_16bit_mul m4 (.a(a[31:16]), .b(b[31:16]), .m(p3));

    cla_nbit #(.WIDTH(32)) adder1 ( 
        .a(p1),
        .b(p2),
        .cin(1'b0),
        .sum(temp1),
        .cout(cout1)
    );

    
    cla_nbit #(.WIDTH(32)) adder2 (
        .a(temp1),
        .b({16'h0000, p0[31:16]}),
        .cin(1'b0),
        .sum(temp2),
        .cout(cout2)
    );

    assign cin3 = cout1 | cout2;

  
    cla_nbit #(.WIDTH(32)) adder3 (
        .a({3'b000,12'h000, cin3, temp2[31:16]}), 
        .cin(1'b0),
        .sum(temp3),
        .cout(cout3)
    );


    assign m = {temp3, temp2[15:0], p0[15:0]};

endmodule