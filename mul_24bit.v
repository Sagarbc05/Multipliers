/////////////////////////////////////////////////////////////////////////////////
// Institution: University Visvesvaraya College of Engineering
// Project Guide: Dr. B P Harish, Chairman and Asst professor, ECE Dept, UVCE.
// Student: Sagar B C (20GAMD3015), IV sem M Tech in ECE, UVCE.
// Create Date:    07:34:38 09/09/2022 
// Design Name: 24- bit mantissa multiplier using Modified Booth Encoding.
// Module Name:    mul_24bit
// Project Name: submodule of single precision Floating Point Multiplier
// Target Devices: Xilinx FPGAs
// Tool versions: Xilinx ISE 14.
// Description: 24 x 24 bit multiplier is designed by employing modified booth
//              encoding and final stage reduction is done by using RCA adder.
//              A novel  and  efficient  way  is developed for partial product
//              generation and reduction.
// Version : v1.0
//
//////////////////////////////////////////////////////////////////////////////////

module mul_24bit(y, a, b);
input [23:0] a;        //8-bit Multiplicand
input [23:0] b;        //8-bit Multiplier
output [47:0] y;      //16-bit result
wire [12:0] sel_m;    // 1*multiplicand selecting signal
wire [12:0] sel_2m;   // 2*multiplicand selecting signal
wire [12:0] sign;     // sign indicator for partial product
wire [27:0] p0, p1, p2, p3, p4, p5; //Partial product rows 0 to 10
wire [27:0] p6, p7, p8, p9, p10;
wire [26:0] p11;         //Last two rows 11 to 12
wire [24:0] p12; 
genvar i;    // variable used in generate statements

// LSB generation of each partial product row
assign p0[0] = sel_m[0] & a[0],
       p1[1] = sel_m[1] & a[0],
       p2[1] = sel_m[2] & a[0],
       p3[1] = sel_m[3] & a[0],
       p4[1] = sel_m[4] & a[0],
       p5[1] = sel_m[5] & a[0],
       p6[1] = sel_m[6] & a[0],
       p7[1] = sel_m[7] & a[0],
       p8[1] = sel_m[8] & a[0],
       p9[1] = sel_m[9] & a[0],
       p10[1] = sel_m[10] & a[0],
       p11[1] = sel_m[11] & a[0],
       p12[1] = sel_m[12] & a[0];

// Carry bit generation to regularise partial product matrix
assign p1[0] = sign[0] & ~p0[0],
       p2[0] = sign[1] & ~p1[1],
       p3[0] = sign[2] & ~p2[1],
       p4[0] = sign[3] & ~p3[1],
       p5[0] = sign[4] & ~p4[1],
       p6[0] = sign[5] & ~p5[1],
       p7[0] = sign[6] & ~p6[1],
       p8[0] = sign[7] & ~p7[1],
       p9[0] = sign[8] & ~p8[1],
       p10[0] = sign[9] & ~p9[1],
       p11[0] = sign[10] & ~p10[1],
       p12[0] = sign[11] & ~p11[1];

// Adopting sign extension mechanism
// Assigning sign bits as per the mechanism
assign p0[25] = sign[0],
       p0[26] = sign[0],
       p0[27] = ~sign[0],
       p1[26] = ~sign[1],
       p1[27] = 1'b1,
       p2[26] = ~sign[2],
       p2[27] = 1'b1,
       p3[26] = ~sign[3],
       p3[27] = 1'b1,
       p4[26] = ~sign[4],
       p4[27] = 1'b1,
       p5[26] = ~sign[5],
       p5[27] = 1'b1,
       p6[26] = ~sign[6],
       p6[27] = 1'b1,
       p7[26] = ~sign[7],
       p7[27] = 1'b1,
       p8[26] = ~sign[8],
       p8[27] = 1'b1,
       p9[26] = ~sign[9],
       p9[27] = 1'b1,
       p10[26] = ~sign[10],
       p10[27] = 1'b1,
       p11[26] = ~sign[11];

// Modified booth encoder
// Booth encoder for 1st group of bits 
booth_encoder BE0 (sel_m[0], sel_2m[0], sign[0], b[1], b[0], 1'b0);  
                                                                     
generate for (i = 1; i < 12; i = i + 1)   // Booth Encoder for intermediate groups
begin: B_Encoder
booth_encoder BE (sel_m[i], sel_2m[i], sign[i], b[2*i+1], b[2*i], b[2*i-1]);
end
endgenerate  
// Booth Encoder for last group of bits
booth_encoder BE12 (sel_m[12], sel_2m[12], sign[12], 1'b0, 1'b0, b[23]); 

//Partial product generation module instantiation
// First row partial product generator
partial PP0 (p0[24:1], sel_m[0], sel_2m[0], sign[0], a);

//Intermediate rows partial product generator : 1 to 11
partial PP1 (p1[25:2], sel_m[1], sel_2m[1], sign[1], a);
partial PP2 (p2[25:2], sel_m[2], sel_2m[2], sign[2], a);
partial PP3 (p3[25:2], sel_m[3], sel_2m[3], sign[3], a);
partial PP4 (p4[25:2], sel_m[4], sel_2m[4], sign[4], a);
partial PP5 (p5[25:2], sel_m[5], sel_2m[5], sign[5], a);
partial PP6 (p6[25:2], sel_m[6], sel_2m[6], sign[6], a);
partial PP7 (p7[25:2], sel_m[7], sel_2m[7], sign[7], a);
partial PP8 (p8[25:2], sel_m[8], sel_2m[8], sign[8], a);
partial PP9 (p9[25:2], sel_m[9], sel_2m[9], sign[9], a);
partial PP10 (p10[25:2], sel_m[10], sel_2m[10], sign[10], a);
partial PP11 (p11[25:2], sel_m[11], sel_2m[11], sign[11], a);

// Last row partial product generator
partial_last PP12 (p12[24:2], sel_m[12], sel_2m[12], sign[12], a);

//wallace tree reduction
wallace_tree WT (y, p0, p1, p2, p3, p4, p5,
                p6, p7, p8, p9, p10, p11, p12);

endmodule  // Top level module ends here


// module for Booth Encoder
module booth_encoder (m1, m2, s, b2, b1, b0);
input b0, b1, b2;     // group of 3 bits of multiplicand
output m1, m2, s;     // Encoded bits 
wire t;
assign s = b2;        //sign bit
xor G1 (m1, b1, b0);  //m1 : 1*multiplicand
xnor G2 (t, b2, b1);  
nor G3 (m2, t, m1);   //m2 : 2*multiplicand
endmodule


//module for partial product generation
module partial (p, m1, m2, s, a);
input m1, m2, s;  // Booth encoded signals
input [23:0] a;   //multiplicand a;
output [23:0] p;  // partial product bits except lsb and carry bit
wire [22:0] t1, t2, t3;
wire t_msb;

genvar i;
generate for (i = 0; i < 23; i = i + 1) // generates partial products except msb
begin : PG
and G4 (t1[i], a[i], m2);   // Can be implemented using NAND-NAND logic
and G5 (t2[i], a[i+1], m1);
or G6 (t3[i], t1[i], t2[i]);
xor G7 (p[i], t3[i], s);
end
endgenerate

//To generate MSB of partial product
and G8 (t_msb, a[23], m2);
xor G9 (p[23], t_msb, s);

endmodule

// Separate module to generate last row of partial product matrix
module partial_last (p, m1, m2, s, a);
input [23:0] a;
input m1, m2, s;
output [22:0] p;
wire [22:0] t1, t2, t3;
wire t_msb;

genvar i;
generate for (i = 0; i < 23; i = i + 1) // generates partial products except msb
begin : PG_last
and G4 (t1[i], a[i], m2);
and G5 (t2[i], a[i+1], m1);
or G6 (t3[i], t1[i], t2[i]);
xor G7 (p[i], t3[i], s);
end
endgenerate

endmodule

// Wallace tree reduction using carry save adders
module wallace_tree (y, p0, p1, p2, p3, p4, p5,
                    p6, p7, p8, p9, p10, p11, p12);
input [27:0] p0, p1, p2, p3, p4, p5;   //Partial product matrix rows
input [27:0] p6, p7, p8, p9, p10;
input [26:0] p11;
input [24:0] p12;
output [47:0] y;                       // Final multiplication result

// First stage
wire [30:0] s0;  // First row adder sum bits
wire [27:0] c0;  // First row adder carry bits
wire [31:0] s1;  // Second row adder sum bits
wire [27:0] c1;  // Second row adder carry bits
wire [31:0] s2;  // Third row adder sum bits
wire [27:0] c2;  // Third row adder carry bits
wire [30:0] s3;  // Fourth row adder bits
wire [27:0] c3;  // Fourth row carry bits

// Second stage
wire [35:0] s4;   // First row adder sum bits
wire [28:0] c4;   // First row adder carry bits
wire [34:0] s5;   // Second row adder sum bits
wire [30:0] c5;   // Second row adder carry bits
wire [30:0] s6;   // Third row adder sum bits
wire [27:0] c6;   // Third row adder carry bits

// Third stage
wire [42:0] s7;   // First row adder sum bits
wire [32:0] c7;   // First row adder carry bits
wire [35:0] s8;   // Second row adder sum bits
wire [30:0] c8;   // Second row adder carry bits

// Fourth stage
wire [47:0] s9;   // Adder sum bits
wire [38:0] c9;   // Adder carry bits

// Fifth stage
wire [47:0] s10;  // Adder sum bits
wire [42:0] c10;  // Adder carry bits


wire [41:0] t;   // Ripple carry adder carry bits

// First stage first row reduction   
// 3-HAs 25-FAs
assign s0[0] = p0[0];
assign s0[29] = p2[26];
assign s0[30] = p2[27];
Half_Adder H0 (s0[1], c0[0], p0[1], p1[0]);
Half_Adder H1 (s0[2], c0[1], p0[2], p1[1]);

genvar i;      // Generating Full Adders
generate for (i = 0; i < 25; i = i + 1)
begin : F_adder0
Full_Adder FA0 (s0[i+3], c0[i+2], p0[i+3], p1[i+2], p2[i]);
end
endgenerate

Half_Adder H3 (s0[28], c0[27], p1[27], p2[25]);
// first stage First row reduction ends here

// First stage second row reduction
// 4-HAs 24-FAs
assign s1[0] = p3[0];
assign s1[1] = p3[1];
assign s1[30] = p5[26];
assign s1[31] = p5[27];

Half_Adder H4 (s1[2], c1[0], p3[2], p4[0]);
Half_Adder H5 (s1[3], c1[1], p3[3], p4[1]);

generate for (i = 0; i < 24; i = i + 1)
begin : F_adder1
Full_Adder FA1 (s1[i+4], c1[i+2], p3[i+4], p4[i+2], p5[i]);
end
endgenerate

Half_Adder H6 (s1[28], c1[26], p4[26], p5[24]);
Half_Adder H7 (s1[29], c1[27], p4[27], p5[25]);
// First stage second row reduction ends here

// First stage third row reduction 
// 4-HAs 24-FAs
assign s2[0] = p6[0];
assign s2[1] = p6[1];
assign s2[30] = p8[26];
assign s2[31] = p8[27];

Half_Adder H8 (s2[2], c2[0], p6[2], p7[0]);
Half_Adder H9 (s2[3], c2[1], p6[3], p7[1]);

generate for (i = 0; i < 24; i = i+1)
begin : F_adder2
Full_Adder FA2 (s2[i+4], c2[i+2], p6[i+4], p7[i+2], p8[i]);
end
endgenerate

Half_Adder H10 (s2[28], c2[26], p7[26], p8[24]);
Half_Adder H11 (s2[29], c2[27], p7[27], p8[25]);
// First stage third row reduction ends here

// First stage fourth row reduction
// 4-HAs 24-FAs
 assign s3[0] = p9[0];
 assign s3[1] = p9[1];
 assign s3[30] = p11[26];

 Half_Adder H12 (s3[2], c3[0], p9[2], p10[0]);
 Half_Adder H13 (s3[3], c3[1], p9[3], p10[1]);

 generate for (i = 0; i < 24; i = i+1)
begin : F_adder3
Full_Adder FA3 (s3[i+4], c3[i+2], p9[i+4], p10[i+2], p11[i]);
end
endgenerate

Half_Adder H14 (s3[28], c3[26], p10[26], p11[24]);
Half_Adder H15 (s3[29], c3[27], p10[27], p11[25]);
// First stage fourth row reduction ends here


//Second stage first row reduction 
// 4-HAs 25-FAs
assign s4[0] = s0[0];
assign s4[1] = s0[1];
assign s4[31] = s1[26],
       s4[32] = s1[27],
       s4[33] = s1[28],
       s4[34] = s1[29],
       s4[35] = s1[30];

Half_Adder H16 (s4[2], c4[0], s0[2], c0[0]);
Half_Adder H17 (s4[3], c4[1], s0[3], c0[1]);
Half_Adder H18 (s4[4], c4[2], s0[4], c0[2]);

generate for (i = 0; i < 25; i = i+1)
begin : F_adder4
Full_Adder FA4 (s4[i+5], c4[i+3], s0[i+5], c0[i+3], s1[i]);
end
endgenerate

Half_Adder H19 (s4[30], c4[28], s0[30], s1[25]);
// Second stage first row reduction ends here

// Second stage second row reduction
// 8-HAs 23-FAs
assign s5[0] = c1[0];
assign s5[1] = c1[1];
assign s5[2] = c1[2];
assign s5[34] = s2[31];

Half_Adder H20 (s5[3], c5[0], c1[3], s2[0]);
Half_Adder H21 (s5[4], c5[1], c1[4], s2[1]);
Half_Adder H22 (s5[5], c5[2], c1[5], s2[2]);

generate for (i = 0; i < 22; i = i + 1)
begin: F_Adder5
Full_Adder FA5 (s5[i+6], c5[i+3], c1[i+6], s2[i+3], c2[i]);
end
endgenerate

Full_Adder FA6 (s5[28], c5[25], s1[31], s2[25], c2[22]);
Half_Adder H23 (s5[29], c5[26], s2[26], c2[23]);
Half_Adder H24 (s5[30], c5[27], s2[27], c2[24]);
Half_Adder H25 (s5[31], c5[28], s2[28], c2[25]);
Half_Adder H26 (s5[32], c5[29], s2[29], c2[26]);
Half_Adder H27 (s5[33], c5[30], s2[30], c2[27]);
// Second stage second row reduction ends here

// Second stage third row reduction
// 3-HAs 25-FAs
assign s6[0] = s3[0];
assign s6[1] = s3[1];
assign s6[2] = s3[2];

Half_Adder H28 (s6[3], c6[0], s3[3], c3[0]);
Half_Adder H29 (s6[4], c6[1], s3[4], c3[1]);
Half_Adder H30 (s6[5], c6[2], s3[5], c3[2]);

generate for (i = 0; i < 25; i = i + 1)
begin:F_Adder7
Full_Adder FA7 (s6[i+6], c6[i+3], s3[i+6], c3[i+3], p12[i]);
end
endgenerate
// Second stage third row reduction ends here

// Third stage first row reduction
// 9-HAs 24-FAs
assign s7[0] = s4[0],
       s7[1] = s4[1],
       s7[2] = s4[2];

assign s7[36] = s5[28],
       s7[37] = s5[29],
       s7[38] = s5[30],
       s7[39] = s5[31],
       s7[40] = s5[32],
       s7[41] = s5[33],
       s7[42] = s5[34];

generate for (i = 0; i < 5; i = i + 1)          
begin: H_Adder31
Half_Adder HA31 (s7[i+3], c7[i], s4[i+3], c4[i]);
end
endgenerate

generate for (i = 0; i < 24; i = i + 1)
begin: F_Adder8
Full_Adder FA8 (s7[i+8], c7[i+5], s4[i+8], c4[i+5], s5[i]);
end
endgenerate

generate for (i = 0; i < 4; i = i + 1)          //4 HAs
begin: H_Adder32
Half_Adder HA32 (s7[i+32], c7[i+29], s4[i+32], s5[i+24]);
end
endgenerate
// Third stage first row reduction ends here

// Third stage second row reduction
// 9-HAs 22-FAs
assign s8[0] = c5[0],
       s8[1] = c5[1],
       s8[2] = c5[2],
       s8[3] = c5[3],
       s8[4] = c5[4];

generate for (i = 0; i < 4; i = i + 1)
begin: H_Adder33
Half_Adder HA33 (s8[i+5], c8[i], c5[i+5], s6[i]);
end
endgenerate

generate for (i = 0; i < 22; i = i + 1)
begin: F_Adder9
Full_Adder FA9 (s8[i+9], c8[i+4], c5[i+9], s6[i+4], c6[i]);
end
endgenerate

generate for (i = 0; i < 5; i = i + 1)
begin: H_Adder34
Half_Adder HA34 (s8[i+31], c8[i+26], s6[i+26], c6[i+22]);
end
endgenerate
// Third stage second row reduction ends here

//Fourth stage reduction
// 14-HAs 25-FAs
assign s9[0] = s7[0],
       s9[1] = s7[1],
       s9[2] = s7[2],
       s9[3] = s7[3];

assign s9[43] = s8[31],
       s9[44] = s8[32],
       s9[45] = s8[33],
       s9[46] = s8[34],
       s9[47] = s8[35];

generate for (i = 0; i < 8; i = i + 1)
begin: H_Adder35
Half_Adder HA35 (s9[i+4], c9[i], s7[i+4], c7[i]);
end
endgenerate

generate for (i = 0; i < 25; i = i + 1)
begin: F_Adder10
Full_Adder FA10 (s9[i+12], c9[i+8], s7[i+12], c7[i+8], s8[i]);
end
endgenerate

generate for (i = 0; i < 6; i = i + 1)
begin: H_Adder36
Half_Adder HA36 (s9[i+37], c9[i+33], s7[i+37], s8[i+25]);
end
endgenerate
// Fourth stage reduction ends here

// Fifth stage reduction
// 17-HAs 26-FAs
assign s10[0] = s9[0],
       s10[1] = s9[1],
       s10[2] = s9[2],
       s10[3] = s9[3],
       s10[4] = s9[4];

generate for (i = 0; i < 13; i = i + 1)
begin: H_Adder37
Half_Adder HA37 (s10[i+5], c10[i], s9[i+5], c9[i]);
end
endgenerate

generate for (i = 0; i < 26; i = i + 1)
begin: F_Adder11
Full_Adder FA10 (s10[i+18], c10[i+13], s9[i+18], c9[i+13], c8[i]);
end
endgenerate


generate for (i = 0; i < 4; i = i + 1)
begin: Half_Adder38
Half_Adder HA38 (s10[i+44], c10[i+39], s9[i+44], c8[i+26]);
end
endgenerate
// Fifth stage reduction ends here


// Final stage : 42 bit RCA adder is used
// 1-HA 42-FAs
assign y[0] = s10[0],
       y[1] = s10[1],
       y[2] = s10[2],
       y[3] = s10[3],
       y[4] = s10[4],
       y[5] = s10[5];  // Final result bits

RCA_42bit RC (y[47:6], s10[47:6], c10[41:0]);  //c10[42] bit is discarded

endmodule

// ripple carry module
module RCA_42bit (y, a, b);
input [41:0] a;
input [41:0] b;
output [41:0] y;
wire [41:0] t;   // Ripple carry adder intermediate carry bits
genvar i;        //generate variable 

Half_Adder H39 (y[0], t[0], a[0], b[0]);

generate for (i = 1; i < 42; i = i + 1)
begin: F_adder12
Full_Adder FA11 (y[i], t[i], a[i], b[i], t[i-1]);  // 42-FAs
end
endgenerate   

endmodule
// Ripple carry addtion module ends here


// Full Adder module
module Full_Adder (sum, cout, a, b, cin);
input a, b, cin;
output sum, cout;
assign sum = a ^ b ^ cin;                  //Full adder sum bit
assign cout = (a & b)|(b & cin)|(cin & a); //Full adder carry bit
endmodule
// Full Adder module ends here


// Half Adder module
module Half_Adder (sum, cout, a, b);
input a, b;
output sum, cout;
assign sum = a ^ b;                       //Half adder sum bit
assign cout = a & b;                      //Half adder carry bit
endmodule
//Half Adder module ends here










