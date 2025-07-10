module vedic_2bit_mul (
    input [1:0] a,
    input [1:0] b,
    output [3:0] m
);

wire c1; //intermediate carry for 1st adder
wire p0, p1, p2, p3; //partial products

assign p0 = a[0] & b[0];
assign p1 = a[1] & b[0];
assign p2 = a[0] & b[1];
assign p3 = a[1] & b[1];



assign c1 = p1 & p2; //Half Adder

assign m[0] = p0;
assign m[1] = p1 ^ p2; 
assign m[2] = c1 ^ p3;
assign m[3] = c1 & p3;

    
endmodule

/* 
Test bench :-
module tb_cla_4bit;

    reg [1:0] a;
    reg [1:0] b;
    wire [3:0] m;

// Instantiate the 2-bit Vedic multiplier
vedic_2bit_mul uut (
    .a(a),
    .b(b),
    .m(m)
);

initial begin
    // Test all combinations for 2-bit multiplier
    integer i, j;
        
        // Initialize
        a = 2'b00; b = 2'b00;
        
        // Loop through all combinations
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                #10 a = i[1:0]; b = j[1:0];
            end
        end

    #10 $finish;

end


initial begin
    $display("Time\tA\tB\tProduct");
    $monitor("%0t\t%b\t%b\t%b (%0d)", $time, a, b, m, m);
end

endmodule
*/

/*
    Verification :-
    Time    A       B       Product
    0       00      00      0000 (0)
    10      01      00      0000 (0)
    20      10      00      0000 (0)
    30      11      00      0000 (0)
    40      00      01      0000 (0)
    50      01      01      0001 (1)
    60      10      01      0010 (2)
    70      11      01      0011 (3)
    80      00      10      0000 (0)
    90      01      10      0010 (2)
    100     10      10      0100 (4)
    110     11      10      0110 (6)
    120     00      11      0000 (0)
    130     01      11      0011 (3)
    140     10      11      0110 (6)
    150     11      11      1001 (9)
*/