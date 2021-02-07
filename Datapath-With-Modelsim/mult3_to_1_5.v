module mult3_to_1_5(out,i0,i1,s0,s1);
output [4:0] out;
input [4:0]i0,i1;
input s0,s1; //s0 = regdest , s1 = jal
reg  scontrol,scontrol2;
always @(s0,s1)
begin
if (s1&(~s0))
begin
	scontrol=1'b1;
	scontrol2=1'b0;
end
if ((~s1)&s0)
begin
	scontrol=1'b0;
	scontrol2=1'b1;
end
if ((~s1)&(~s0))
begin
	scontrol=1'b0;
	scontrol2=1'b0;
end
end
assign out = scontrol ? 5'b11111:(scontrol2 ? i1:i0);
endmodule

// S0,S1 
// 01 = JAL
// 10 = REGDEST
// 00 = NORMAL 