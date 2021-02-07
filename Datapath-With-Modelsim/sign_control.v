module sign_control(out,sum);
output out;
input [31:0]sum;
reg  scontrol;
always @(sum)
begin
if (sum[31]==1'b1)
	scontrol=1'b1;
else
	scontrol=1'b0;
end
assign out = scontrol ? 1'b1:1'b0;
endmodule