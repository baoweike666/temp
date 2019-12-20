`timescale 1ns/1ps

module ppm(clk, rst, din, dout, d_en, f_en);

input clk, rst;
input din;
output reg [1:0] dout;
output d_en, f_en;

reg [7:0] shiftreg;
wire d_en, f_en;
reg [2:0] count;
reg [2:0] state;

// shift register
always @(posedge clk or negedge rst) begin
	if(!rst)	shiftreg <= 8'h00;
	else	begin
		shiftreg[0] <= din;
		shiftreg[1] <= shiftreg[0];
		shiftreg[2] <= shiftreg[1];
		shiftreg[3] <= shiftreg[2];
		shiftreg[4] <= shiftreg[3];
		shiftreg[5] <= shiftreg[4];
		shiftreg[6] <= shiftreg[5];
		shiftreg[7] <= shiftreg[6];
	end
end

// state machine
always @(posedge clk or negedge rst) begin
	if(!rst) begin
		state <= 3'd0;
	end
	else begin
		// state 0,1,2 shift
		case(state)
		3'd0:// state 0
			if(shiftreg==8'b0111_1011) state <= 3'd1;// SOF, 0 to 1
			else state <= 3'd0;// keep state 0
		3'd1:// state 1
			state <= 3'd2;// 1 to 2
		3'd2:// state 2
			if(shiftreg == 8'b1101_0001) state <= 3'd0;// EOF, 2 to 0
			else state <= 3'd2;// keep state 2
		default: state <= 3'd0;// default, state 0
		endcase
	end
end

// counter
always @(posedge clk or negedge rst) begin
	if(!rst) begin
		count <= 3'd0;
	end
	else begin
		if (state==3'd0 && shiftreg==8'b0111_1011) count <= 3'd0;// state 0 & SOF, count 0
		else count <= count + 3'd1;// counting
	end
end

assign f_en = (state==3'd1) ? 1'b1 : 1'b0;
assign d_en = (state==3'd2 && count==3'd0) ? 1'b1 : 1'b0;

// decoder
always @(posedge clk or negedge rst) begin
	if(!rst) begin
		dout <= 2'b00;
	end
	else if(state==3'd2 && count==3'd7) begin
		case(shiftreg)
		8'b1011_1111: dout <= 2'b00;// decode as 00
		8'b1110_1111: dout <= 2'b01;// decode as 01
		8'b1111_1011: dout <= 2'b10;// decode as 10
		8'b1111_1110: dout <= 2'b11;// decode as 11
		default: dout <= 2'b00;
		endcase
	end
	else dout<=2'b00;
end

endmodule
