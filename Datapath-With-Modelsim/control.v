module control(in,rt,func,regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,branch2,branch3,aluop2,aluop1,aluop0,jump,jumpreg);
input [5:0] in,func;
input [4:0] rt;
output regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,branch2,branch3,aluop0,aluop1,aluop2,jump,jumpreg;
wire rformat,lw,sw,beq,bne,bgez,bgtz,blez,bltz,addi,andi,ori,j,jr,jal;
assign rformat=~|in;
assign lw=in[5]& (~in[4])&(~in[3])&(~in[2])&in[1]&in[0];
assign sw=in[5]& (~in[4])&in[3]&(~in[2])&in[1]&in[0];
assign beq=~in[5]& (~in[4])&(~in[3])&in[2]&(~in[1])&(~in[0]);
assign addi=(~in[5])& (~in[4])& in[3]& (~in[2])&(~in[1])&(~in[0]);
assign andi=(~in[5])& (~in[4])& in[3]& in[2]&(~in[1])&(~in[0]);
assign ori=(~in[5])& (~in[4])& in[3]& in[2]&(~in[1])&in[0];
assign bne=~in[5]& (~in[4])&(~in[3])&in[2]&(~in[1])&in[0];
assign bgez=~in[5]& (~in[4])&(~in[3])&(~in[2])&(~in[1])&in[0]&(~rt[4])&(~rt[3])&(~rt[2])&(~rt[1])&rt[0]; 
assign bgtz=~in[5]& (~in[4])&(~in[3])&in[2]&in[1]&in[0]&(~rt[4])&(~rt[3])&(~rt[2])&(~rt[1])&(~rt[0]);
assign blez=~in[5]& (~in[4])&(~in[3])&in[2]&in[1]&(~in[0])&(~rt[4])&(~rt[3])&(~rt[2])&(~rt[1])&(~rt[0]);
assign bltz=~in[5]& (~in[4])&(~in[3])&(~in[2])&(~in[1])&in[0]&(~rt[4])&(~rt[3])&(~rt[2])&(~rt[1])&(~rt[0]);
assign j= ~in[5]& (~in[4])&(~in[3])&(~in[2])&in[1]&(~in[0]);
assign jr= (~|in)& (~func[5])&(~func[4])&func[3]&(~func[2])&(~func[1])&(~func[0]);
assign jal= ~in[5]& (~in[4])&(~in[3])&(~in[2])&in[1]&in[0];
assign regdest=(rformat&(~jr));
assign alusrc=lw|sw|addi|andi|ori;
assign memtoreg=lw;
assign regwrite=(rformat&(~jr))|lw|addi|andi|ori|jal;
assign memread=lw;
assign memwrite=sw;
assign branch=beq|bne|bgez|blez;
assign branch2=bgez|bgtz|bne;
assign branch3=blez|bltz|bne;
assign aluop2=andi|ori;
assign aluop1=(rformat&(~jr));
assign aluop0=beq|andi|bne|bgez|bgtz|blez|bltz;
assign jump=j|jal;
assign jumpreg=jr;
endmodule

//	branch	branch2	branch3	
//	1	0	0	= for BEQ 
// 	1	1	0	= for BGEZ
//	0	1	0	= for BGTZ
//	1	0	1 	= for BLEZ
//	0	0	1	= for BLTZ	
// 	1 	1 	1 	= for BNE	

//	aluop2	aluop1	aluop0	
//	0	0	0	= addi -> alucont.v gout = b0010 add operation
//	0	0	1 	= beq, bne, bgez, bqtz, blez, bltz -> alucont.v gout = b0110 sub operation
//	0	1	0	= R -> alucont.v gout = Rtype selection 
//	0	1	1	= empty
//	1	0	0	= ori -> alucont.v gout = b0001 or operation
//	1	0	1	= andi -> alucont.v gout = b0000 and operation
//	1	1	0	= empty
//	1	1	1	= empty
