// Simple 4 bit multiplier based on Modified booth encoding and Wallace tree multiplier


module mul_4bit (a, b, y);
input [3:0] a, b;
output [7:0] y;

wire [2:0] sel_m, sel_2m, sign;
wire [7:0] p1;
wire [5:0] p2;
wire [3:0] p3;
wire c0, c1;


// To generate lsbi and ci (to merge lsb partial product with sign bit)
assign p1[0] = sel_m[0] & b[0];
assign c0 = sign[0] & ~p1[0];
assign p2[0] = sel_m[1] & b[0];
assign c1 = sign[1] & ~p2[0];
assign p3[0] = sel_m[2] & b[0];
assign p1[5] = sign[0];
assign p1[6] = sign[0];
assign p1[7] = ~sign[0];
assign p2[5] = ~sign[1];



// Booth Encoder circuit generating sel_m and sel_2m signals

Booth_encoder E0 (sel_m[0], sel_2m[0], sign[0], a[1], a[0], 1'b0);
Booth_encoder E1 (sel_m[1], sel_2m[1], sign[1], a[3], a[2], a[1]);
Booth_encoder E2 (sel_m[2], sel_2m[2], sign[2], 1'b0, 1'b0, a[3]);

// Partial product generator circuits
partial A0 (p1[4:1], sel_m[0], sel_2m[0], sign[0], b);
partial A1 (p2[4:1], sel_m[1], sel_2m[1], sign[1], b);
partial_last B0 (p3[3:1], sel_m[2], sel_2m[2], sign[2], b);

wallace_tree W (y, p1, p2, p3, c0, c1);

endmodule

// Booth Encoder circuit

module Booth_encoder (m1, m2, s, a2, a1, a0);
input a2, a1, a0;
output m1, m2, s;
wire t;
assign s = a2;
xor G1 (m1, a1, a0);
xnor G2 (t, a2, a1);
nor G3 (m2, t, m1);
endmodule

// module to generate partial product
module partial (p, m1, m2, s, b);
input m1, m2, s;
input [3:0] b;
output [3:0] p;
wire [2:0] t1, t2, t3;
wire t_msb;
genvar i;
generate for (i = 0; i < 3; i = i + 1)
begin : pargt
and G1 (t1[i], m2, b[i]);
and G2 (t2[i], m1, b[i+1]);
or G3 (t3[i], t1[i], t2[i]);
xor G4 (p[i], t3[i], s);
end
endgenerate
and A1 (t_msb, m2, b[3]);
xor A2 (p[3], t_msb, s);

endmodule

module partial_last (p, m1, m2, s, b);
input m1, m2, s;
input [3:0] b;
output [2:0] p;
wire [2:0] t1, t2, t3;
genvar i;
generate for (i = 0; i < 3; i = i + 1)
begin : pargt
and G1 (t1[i], m2, b[i]);
and G2 (t2[i], m1, b[i+1]);
or G3 (t3[i], t1[i], t2[i]);
xor G4 (p[i], t3[i], s);
end
endgenerate
endmodule

//module ends here

module wallace_tree (y, p1, p2, p3, c0, c1);
input [7:0] p1;
input [5:0] p2;
input [3:0] p3;
input c0, c1;
output [7:0] y;
wire [7:0] s, cy;
wire c1_out;
reg cin = 1'b0;

HA H0 (s[0], cy[0], p1[1], c0);
HA H1 (s[1], cy[1], p1[2], p2[0]);
FA F0 (s[2], cy[2], p1[3], p2[1], c1);
FA F1 (s[3], cy[3], p1[4], p2[2], p3[0]);
FA F2 (s[4], cy[4], p1[5], p2[3], p3[1]);
FA F3 (s[5], cy[5], p1[6], p2[4], p3[2]);
FA F4 (s[6], cy[6], p1[7], p2[5], p3[3]);

//Instantiating CLA adder for final addition
assign y[0] = p1[0];
assign y[1] = s[0];
cla_4bit C0 (c1_out, y[5:2], s[4:1], cy[3:0], cin);
cla_2bit C1 (y[7:6], s[6:5], cy[5:4], c1_out);
endmodule

// Implementing CLA

module cla_4bit (cout, y, a, b, cin);
input [3:0] a, b;
output [3:0] y;
output cout;
input cin;
wire [3:0] p, g;
wire c1, c2, c3;

assign c1 = (p[0] & cin) | g[0];
assign c2 = (p[1] & p[0] & cin) | (p[1] & g[0]) | g[1];
assign c3 = (p[2] & p[1] & p[0] & cin) | (p[2] & p[1] & g[0]) | (p[2] & g[1]) | g[2];
assign y[0] = p[0] ^ cin;
assign y[1] = p[1] ^ c1;
assign y[2] = p[2] ^ c2;
assign y[3] = p[3] ^ c3;
assign cout = (p[3] & c3) | g[3];

genvar i;
generate for (i = 0; i < 4; i = i + 1)
begin : png 
assign p[i] = a[i] ^ b[i];
assign g[i] = a[i] & b[i];
end
endgenerate
endmodule


module cla_2bit (y, a, b, cin);
input [1:0] a, b;
input cin;
output [1:0] y;
wire t;
wire [1:0] p, g;
assign p[0] = a[0] ^ b[0];
assign p[1] = a[1] ^ b[1];
assign g[0] = a[0] & b[0];
assign g[1] = a[1] & b[1];
assign t = (p[0] & cin) | g[0];
assign y[0] = p[0] ^ cin;
assign y[1] = p[1] ^ t;
endmodule

module FA (sum, cout, a, b, cin);
input a, b, cin;
output sum, cout;
assign sum = a ^ b ^ cin;
assign cout = (a & b)|(b & cin)|(cin & a);
endmodule

module HA (sum, cout, a, b);
input a, b;
output sum, cout;
assign sum = a ^ b;
assign cout = a & b;
endmodule




