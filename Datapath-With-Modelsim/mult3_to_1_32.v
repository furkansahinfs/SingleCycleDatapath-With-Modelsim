module mult3_to_1_32(out,i0,i1,i2,s0,s1);
output [31:0] out;
input [31:0]i0,i1,i2; //i2 = pc+8
input s0,s1; //s0 = memtoreg , s1 = jal
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
assign out = scontrol ? i2:(scontrol2 ? i1:i0);
endmodule

// S0,S1 
// 01 = JAL
// 10 = MEMTOREG
// 00 = NORMAL 