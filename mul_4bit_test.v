module testbench;
reg [3:0] a, b;
wire [7:0] y;

mul_4bit MM (a, b, y);

initial begin
    a = 4'b1000;
    b = 4'b0111;
    #10 $display("p0 = %b, p1 = %b, p2 = %b %b %b ", MM.p1, MM.p2, MM.p3, MM.c0, MM.c1);
    #10 $display("y = %d  %b", y, y);
end
endmodule