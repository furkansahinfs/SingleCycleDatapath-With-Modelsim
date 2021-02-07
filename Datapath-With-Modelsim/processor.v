module processor;
reg [31:0] pc; //32-bit program counter
reg clk; //clock
reg [7:0] datmem[0:31],mem[0:31]; //32-size data and instruction memory (8 bit(1 byte) for each location)
wire [31:0] 
dataa,	//Read data 1 output of Register File
datab,	//Read data 2 output of Register File
out2,		//Output of mux with ALUSrc control-mult2
out3,		//Output of mux with MemToReg control-mult3
out4,		//Output of mux with (Branch&ALUZero) control-mult4 
out5,		//Output of mux with (jump) control-mult5
out6,		//Output of mux with (jumpreg) control-mult6 
sum,		//ALU result
extad,	//Output of sign-extend unit
adder1out,	//Output of adder which adds PC and 4-add1
adder2out,	//Output of adder which adds PC+4 and 2 shifted sign-extend result-add2
sextad,	//Output of shift left 2 unit
jumpshift;	//Output of shift left of jump address.

wire [5:0] inst31_26;	//31-26 bits of instruction
wire [4:0] 
inst25_21,	//25-21 bits of instruction
inst20_16,	//20-16 bits of instruction
inst15_11,	//15-11 bits of instruction
out1;		//Write data input of Register File

wire [15:0] inst15_0;	//15-0 bits of instruction
wire [25:0] inst25_0;	//25-0 bits for jump	
wire [31:0] instruc,	//current instruction
dpack;	//Read data output of memory (data read from memory)

wire [3:0] gout;	//Output of ALU control unit
wire zout,	//Zero output of ALU
pcsrc,	//Output of AND gate with Branch and ZeroOut inputs
signsrc, //Output of sign_control
//Control signals
regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,branch2,branch3,aluop2,aluop1,aluop0,jump,jumpreg;

//32-size register file (32 bit(1 word) for each register)
reg [31:0] registerfile[0:31];

integer i;

// datamemory connections

always @(posedge clk)
//write data to memory
if (memwrite)
begin 
//sum stores address,datab stores the value to be written
datmem[sum[4:0]+3]=datab[7:0];
datmem[sum[4:0]+2]=datab[15:8];
datmem[sum[4:0]+1]=datab[23:16];
datmem[sum[4:0]]=datab[31:24];
end

//instruction memory
//4-byte instruction
 assign instruc={mem[pc[4:0]],mem[pc[4:0]+1],mem[pc[4:0]+2],mem[pc[4:0]+3]};
 assign inst31_26=instruc[31:26];
 assign inst25_21=instruc[25:21];
 assign inst20_16=instruc[20:16];
 assign inst15_11=instruc[15:11];
 assign inst15_0=instruc[15:0];
 assign inst25_0=instruc[25:0];
 assign jumpshift = inst25_0<<2;


// registers

assign dataa=registerfile[inst25_21];//Read register 1
assign datab=registerfile[inst20_16];//Read register 2
always @(posedge clk)
 registerfile[out1]= regwrite ? out3:registerfile[out1];//Write data to register

//read data from memory, sum stores address
assign dpack={datmem[sum[5:0]],datmem[sum[5:0]+1],datmem[sum[5:0]+2],datmem[sum[5:0]+3]}; //big endian format

//multiplexers
//mux with RegDst&JAL control
mult3_to_1_5  mult1(out1, instruc[20:16],instruc[15:11],regdest,jump);

//mux with ALUSrc control
mult2_to_1_32 mult2(out2, datab,extad,alusrc);

//mux with MemToReg&JAL control
mult3_to_1_32 mult3(out3, sum,dpack,adder1out,memtoreg,jump);

//mux with (Branch&ALUZero) control
mult2_to_1_32 mult4(out4, adder1out,adder2out,pcsrc);

//mux with (jump) control for jump
mult2_to_1_32 mult5(out5,out4,jumpshift,jump);

//mux with (jumpreg) control for jumpreg
mult2_to_1_32 mult6(out6,out5,dataa,jumpreg);


// load pc
always @(posedge clk)
pc=out6;

// alu, adder and control logic connections

//ALU unit
alu32 alu1(sum,dataa,out2,zout,gout);

//adder which adds PC and 4
adder add1(pc,32'h4,adder1out);

//adder which adds PC+4 and 2 shifted sign-extend result
adder add2(adder1out,sextad,adder2out);

//Control unit
control cont(instruc[31:26],instruc[20:16],instruc[5:0],regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,branch2,branch3,
aluop2,aluop1,aluop0,jump,jumpreg);

//Sign extend unit
signext sext(instruc[15:0],extad);

//ALU control unit
alucont acont(aluop2,aluop1,aluop0,instruc[3],instruc[2], instruc[1], instruc[0] ,gout);


//Shift-left 2 unit
shift shift2(sextad,extad);

//control sign, negative returns 1, positive returns 0
sign_control signcont(signsrc,sum);



//AND gate 			
assign pcsrc=
 (branch && (~branch2) && (~branch3) && zout) // for BEQ
|(branch && branch2 && branch3 && (~zout)) // for BNE
|(branch && branch2 && (~branch3) && zout && (~signsrc)) // for BGEZ
|(branch && branch2 && (~branch3) && (~zout) && (~signsrc)) // for BGEZ
|((~branch) && branch2 && (~branch3) && (~zout) && (~signsrc)) // for BGTZ
|(branch && (~branch2) && branch3 && zout &&(~signsrc)) // for BLEZ
|(branch && (~branch2) && branch3 && (~zout) && signsrc) // for BLEZ
|((~branch) && (~branch2) && branch3 && (~zout) && signsrc); // for BLTZ

//initialize datamemory,instruction memory and registers
//read initial data from files given in hex
initial
begin
$readmemh("initDM.dat",datmem); //read Data Memory
$readmemh("initIM.dat",mem);//read Instruction Memory
$readmemh("initReg.dat",registerfile);//read Register File

	for(i=0; i<31; i=i+1)
	$display("Instruction Memory[%0d]= %h  ",i,mem[i],"Data Memory[%0d]= %h   ",i,datmem[i],
	"Register[%0d]= %h",i,registerfile[i]);
end

initial
begin
pc=0;
#260 $finish;
	
end
initial
begin
clk=0;
//40 time unit for each cycle
forever #20  clk=~clk;
end
initial 
begin
  $monitor($time,"PC %h",pc,"  SUM %h",sum,"   INST %h",instruc[31:0],
"   REGISTER %h %h %h %h ",registerfile[4],registerfile[5], registerfile[6],registerfile[1] );
end
endmodule
