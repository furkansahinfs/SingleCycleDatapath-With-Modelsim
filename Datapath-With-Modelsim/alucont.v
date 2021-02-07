module alucont(aluop2,aluop1,aluop0,f3,f2,f1,f0,gout);//Figure 4.12 
input aluop2,aluop1,aluop0,f3,f2,f1,f0;
output [3:0] gout;
reg [3:0] gout;
always @(aluop2 or aluop1 or aluop0 or f3 or f2 or f1 or f0)
begin
if(~(aluop2|aluop1|aluop0))gout=4'b0010;
if((~aluop1) & (~aluop2) & aluop0)gout=4'b0110;
if(aluop2 & (~aluop1) & aluop0)gout=4'b0000;
if(aluop2 & (~aluop1) &(~aluop0)) gout=4'b0001;
if((~aluop2) & aluop1 & (~aluop0))//R-type
begin
	if (~(f3|f2|f1|f0))gout=4'b0010; 	//function code=0000,ALU control=0010 (add)
	if (f1&f3)gout=4'b0111;			//function code=1x1x,ALU control=0111 (set on less than)
	if (f1&~(f3))gout=4'b0110;		//function code=0x10,ALU control=0110 (sub)
	if (f2&f0)gout=4'b0001;			//function code=x1x1,ALU control=0001 (or)
	if (f2&~(f0))gout=4'b0000;		//function code=x1x0,ALU control=0000 (and)
	if ((~f3)&f2&f1&f0)gout=4'b1100;	//function code=0111,ALU control=1100 (nor)
end
end
endmodule
