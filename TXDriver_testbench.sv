`timescale 1ns/1ns
module TXDriver_testbench();
	logic clk, rst, TxEmpty, XMitGo;
	logic [7:0] TxData;
	logic [1:0] OutState;
	//TXDriver(clk, rst, TxEmpty, TxData, XMitGo, OutState);
	TXDriver dut(clk, rst, TxEmpty, TxData, XMitGo, OutState);
	
	always begin
	   clk = 0;
		#10;
		clk = 1;
		#10;
	end
	
	initial begin
		rst = 1;
		TxEmpty = 0;
		
		#30;
		rst = 0;
		TxEmpty = 1;
		#20;
		TxEmpty = 0;
		#30;
		TxEmpty = 1;
		#20;
		TxEmpty = 0;
		#30;
		TxEmpty = 1;
		#20;
		TxEmpty = 0;
		#30;
		TxEmpty = 1;
		#20;
		TxEmpty = 0;
		#30;
		TxEmpty = 1;
		#20;
		TxEmpty = 0;
		#30;
		TxEmpty = 1;
		#20;
		TxEmpty = 0;
		#30;
		TxEmpty = 1;
		#10000;
		$stop;
	end
	
endmodule


