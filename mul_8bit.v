/////////////////////////////////////////////////////////////////////////////////
// Institution: University Visvesvaraya College of Engineering
// Project Guide: Dr. B P Harish, Chairman and Asst professor, ECE Dept UVCE.
// Student: Sagar B C (20GAMD3015), IV sem M Tech in ECE, UVCE.
// Create Date:    07:34:38 09/09/2022 
// Design Name: 8 - bit multiplier using Modified Booth encoding
// Module Name:    mul_8bit
// Project Name: submodule of single precision Floating Point Multiplier
// Target Devices: Xilinx FPGAs
// Tool versions: Xilinx ISE 
// Description: 8 x 8 bit multiplier is designed by employing modified booth
//              encoding and final stage reduction is done by using RCA adder.
//              A novel and efficient  way is developed for partial product
//              generation.
// Version : v1.0
//
//////////////////////////////////////////////////////////////////////////////////

module mul_8bit(y, a, b);
input [7:0] a;        //8-bit Multiplicand
input [7:0] b;        //8-bit Multiplier
output [15:0] y;      //16-bit result
wire [4:0] sel_m;    // 1*multiplicand selecting signal
wire [4:0] sel_2m;   // 2*multiplicand selecting signal
wire [4:0] sign;     // sign indicator for partial product
wire [11:0] p0, p1, p2; //Partial product rows
wire [10:0] p3;         //Last two rows
wire [8:0] p4; 

// LSB generation of each partial product row
assign p0[0] = sel_m[0] & a[0],
       p1[1] = sel_m[1] & a[0],
       p2[1] = sel_m[2] & a[0],
       p3[1] = sel_m[3] & a[0],
       p4[1] = sel_m[4] & a[0];

// Carry bit generation to regularise partial product matrix
assign p1[0] = sign[0] & ~p0[0],
       p2[0] = sign[1] & ~p1[1],
       p3[0] = sign[2] & ~p2[1],
       p4[0] = sign[3] & ~p3[1];

// Adopting sign extension mechanism
assign p0[9] = sign[0],
       p0[10] = sign[0],
       p0[11] = ~sign[0],
       p1[10] = ~sign[1],
       p1[11] = 1'b1,
       p2[10] = ~sign[2],
       p2[11] = 1'b1,
       p3[10] = ~sign[3];

// Modified booth encoder
booth_encoder BE0 (sel_m[0], sel_2m[0], sign[0], b[1], b[0], 1'b0);  //use generate for high bit multiplication
booth_encoder BE1 (sel_m[1], sel_2m[1], sign[1], b[3], b[2], b[1]);  //2*i
booth_encoder BE2 (sel_m[2], sel_2m[2], sign[2], b[5], b[4], b[3]);
booth_encoder BE3 (sel_m[3], sel_2m[3], sign[3], b[7], b[6], b[5]);
booth_encoder BE4 (sel_m[4], sel_2m[4], sign[4], 1'b0, 1'b0, b[7]);

//Partial product generation module instantiation
partial PP0 (p0[8:1], sel_m[0], sel_2m[0], sign[0], a);
partial PP1 (p1[9:2], sel_m[1], sel_2m[1], sign[1], a); // Use generate statement for middle rows
partial PP2 (p2[9:2], sel_m[2], sel_2m[2], sign[2], a);
partial PP3 (p3[9:2], sel_m[3], sel_2m[3], sign[3], a);
partial_last PP4 (p4[8:2], sel_m[4], sel_2m[4], sign[4], a);

//wallace tree reduction
wallace_tree WT (y, p0, p1, p2, p3, p4);

endmodule  // Top level module ends here


// module for Booth Encoder
module booth_encoder (m1, m2, s, b2, b1, b0);
input b0, b1, b2;   // group of 3 bits of multiplicand
output m1, m2, s;   // Encoded bits 
wire t;
assign s = b2;
xor G1 (m1, b1, b0);
xnor G2 (t, b2, b1);
nor G3 (m2, t, m1);
endmodule


//module for partial product generation
module partial (p, m1, m2, s, a);
input m1, m2, s;
input [7:0] a;
output [7:0] p;
wire [6:0] t1, t2, t3;
wire t_msb;

genvar i;
generate for (i = 0; i < 7; i = i + 1) // generates partial products except msb
begin : PG
and G4 (t1[i], a[i], m2);
and G5 (t2[i], a[i+1], m1);
or G6 (t3[i], t1[i], t2[i]);
xor G7 (p[i], t3[i], s);
end
endgenerate

//To generate MSB of partial product
and G8 (t_msb, a[7], m2);
xor G9 (p[7], t_msb, s);

endmodule

// separate module to generate last row of partial product matrix
module partial_last (p, m1, m2, s, a);
input [7:0] a;
input m1, m2, s;
output [6:0] p;
wire [6:0] t1, t2, t3;
wire t_msb;

genvar i;
generate for (i = 0; i < 7; i = i + 1) // generates partial products except msb
begin : PG
and G4 (t1[i], a[i], m2);
and G5 (t2[i], a[i+1], m1);
or G6 (t3[i], t1[i], t2[i]);
xor G7 (p[i], t3[i], s);
end
endgenerate

endmodule

// Wallace tree reduction
module wallace_tree (y, p0, p1, p2, p3, p4);
input [11:0] p0, p1, p2;
input [10:0] p3;
input [8:0] p4;
output [15:0] y;

wire [14:0] s0;  // First stage first row adder sum bits
wire [11:0] c0;  // First stage first row adder carry bits
wire [15:0] s1;  // Second stage adder sum bits
wire [12:0] c1;  // Second stage adder carry bits
wire [15:0] s2;  // Third stage adder sum bits
wire [12:0] c2;  // Third stage adder carry bits
wire [10:0] t;   // Ripple carry adder carry bits

// First stage first row reduction
assign s0[0] = p0[0];
assign s0[13] = p2[10];
assign s0[14] = p2[11];
Half_Adder H0 (s0[1], c0[0], p0[1], p1[0]);
Half_Adder H1 (s0[2], c0[1], p0[2], p1[1]);

genvar i;
generate for (i = 0; i < 9; i = i + 1)
begin : F_adder1
Full_Adder FA1 (s0[i+3], c0[i+2], p0[i+3], p1[i+2], p2[i]);
end
endgenerate

Half_Adder H3 (s0[12], c0[11], p1[11], p2[9]);
// first stage reduction ends here

// Second stage first row reduction
assign s1[0] = s0[0];
assign s1[1] = s0[1];
assign s1[15] = p3[10];
Half_Adder H4 (s1[2], c1[0], s0[2], c0[0]);
Half_Adder H5 (s1[3], c1[1], s0[3], c0[1]);
Half_Adder H6 (s1[4], c1[2], s0[4], c0[2]);

generate for (i = 0; i < 9; i = i + 1)
begin : F_adder2
Full_Adder FA2 (s1[i+5], c1[i+3], s0[i+5], c0[i+3], p3[i]);
end
endgenerate

Half_Adder H7 (s1[14], c1[12], s0[14], p3[9]);
// Second stage of reduction ends here

// Third stage of reduction 
assign s2[0] = s1[0];
assign s2[1] = s1[1];
assign s2[2] = s1[2];

Half_Adder H8 (s2[3], c2[0], s1[3], c1[0]);
Half_Adder H9 (s2[4], c2[1], s1[4], c1[1]);
Half_Adder H10 (s2[5], c2[2], s1[5], c1[2]);
Half_Adder H11 (s2[6], c2[3], s1[6], c1[3]);

generate for (i = 0; i < 9; i = i+1)
begin : F_adder3
Full_Adder FA3 (s2[i+7], c2[i+4], s1[i+7], c1[i+4], p4[i]);
end
endgenerate
// Third stage of reduction ends here

// Final stage : 12 bit RCA adder is used
RCA_12bit RC (y, s2, c2[11:0]);  //c2[12] bit is discarded

endmodule

// ripple carry module
module RCA_12bit (y, s2, c2);
input [15:0] s2;
input [11:0] c2;
output [15:0] y;
wire [11:0] t;   // Ripple carry adder carry bits

assign y[0] = s2[0],
       y[1] = s2[1],
       y[2] = s2[2],
       y[3] = s2[3];   // Final result bits

Half_Adder H12 (y[4], t[0], s2[4], c2[0]);

genvar i;
generate for (i = 0; i < 11; i = i + 1)
begin: F_adder4
Full_Adder FA4 (y[i+5], t[i+1], s2[i+5], c2[i+1], t[i]);
end
endgenerate       

endmodule
// Ripple carry addtion module ends here


// Full Adder module
module Full_Adder (sum, cout, a, b, cin);
input a, b, cin;
output sum, cout;
assign sum = a ^ b ^ cin;
assign cout = (a & b)|(b & cin)|(cin & a);
endmodule
// Full Adder module ends here


// Half Adder module
module Half_Adder (sum, cout, a, b);
input a, b;
output sum, cout;
assign sum = a ^ b;
assign cout = a & b;
endmodule
//Half Adder module ends here










