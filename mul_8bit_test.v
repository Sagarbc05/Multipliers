module mul_8bit_test;
reg [7:0] a, b;
wire [15:0] y;

mul_8bit DUT (y, a, b);

initial begin
    a = 8'b10100110;
    b = 8'b11011001;
    #10 $display("a = %b b = %b product = %b", a, b, y);
    #10 $display("a = %d b = %d product = %d", a, b, y);
end
endmodule