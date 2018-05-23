//Bruce Baker
//May 23, 2018
//TCES 330 Spring 2018
//This is a driver module for the UART transmitter
//It fetches values from memory and send them to the 
//transmitter whenever we recieve a TxEmpty on a rising edge of a clock


module TXDriver(clk, rst, TxEmpty, TxData, XMitGo, OutState);
	input clk, rst, TxEmpty;
	output logic [7:0] TxData;
	output logic XMitGo;
	output [1:0] OutState;
	
	logic NextMit = 0;
	logic [1:0] CurrentState = 2'b00;
	logic [1:0] NextState;
	logic [7:0] AMem[0:15]/* synthesis ram_init_file = "Hello_World.mif" */;
	logic [3:0] CurrentPosition = 0; 
	logic [3:0] NextPosition = 0;
	logic [15:0] SecondWait = 0;
	logic [15:0] NextSecond = 0;
	
	assign OutState = CurrentState;
	//our states are transmit,  finish
	//  Transmit assigns the byte value to the txData to be passed in and  Xmitgo = true
	//  Finish will be sending Xmitgo = false and we pause for a second then send the 
	//	 The message again
	
	//We could have the finish set the reset value to the MHz clock off so it would
	//run properly in response to the pulse?
	localparam WordLength = 4'd13;
	
	localparam Initial = 2'b00,
				  Transmit = 2'b01,
				  Finish   = 2'b10,
				  Wait = 2'b11;
				  
	
	always @(*) begin
		case(CurrentState)
			//make a reset\initialized state that moves forward on a TxEmpty
			Initial: begin 
							if( TxEmpty == 1'b1) begin
								NextMit = 1;
								NextState = Transmit;
								NextPosition = 0;
								NextSecond = 0;
							end else begin
								NextMit = 0;
								NextState = Initial;
								NextPosition = 0;
								NextSecond = 0;
							end
						end
			//Transmit outputs the byte and the xmitgo signal whenever a new byte is sent
			Transmit:begin 
							NextSecond = 0;
							if(TxEmpty == 1'b1 ) begin
								if( CurrentPosition >= WordLength - 1) begin
									NextMit = 0;
									NextState = Finish;
									NextPosition = 0;
								end else begin
									NextMit = 1;
									NextState = Transmit;	
									NextPosition = CurrentPosition + 1'b1;
								end 
							end else begin
								NextMit = 0;
								NextState = Transmit;
								NextPosition = CurrentPosition;
							end
						end
			//Resets the values in the state and moves us into the wait state
			
			Finish: begin 
						  NextSecond = 0;
						  NextState = Wait;
						  NextPosition = 0;
						  NextMit = 0;
					  end
			//Full second wait before returning to initial		  
			Wait:begin 
						if(SecondWait >= 50_000_000) begin
								NextState = Initial;
								NextPosition = 0;
								NextSecond = 0;
								NextMit = 1;
						end else begin
								NextMit = 0;
								NextState = Wait;
								NextPosition = 0;
								NextSecond = SecondWait + 4'h1;
						end
					end
						  
			default begin NextState = Initial; NextPosition = 4'h0; NextSecond = 0; NextMit = 0; end
		endcase
	end
	
	//The state assignment on clock edge and active high reset
	always_ff @(posedge clk) begin
		if(rst == 1'b1) begin
			CurrentState <= Initial;
			CurrentPosition <= 0;
			SecondWait <= 0;
			XMitGo <= 0;
			TxData <= 0;
		end else begin
			CurrentState <= NextState;
			CurrentPosition = NextPosition;
			SecondWait <= NextSecond;
			XMitGo <= NextMit;
			TxData <= AMem[CurrentPosition];
		end
		
	end // state_FFS
	
	
	
endmodule





