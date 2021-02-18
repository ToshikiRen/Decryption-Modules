`timescale 1ns / 1ps

module division(N,D,Q,R);
	 
	parameter width = 16;
	 
    input[width-1:0] N;
    input[width-1:0] D;

    output[width-1:0] Q;
    output[width-1:0] R;
	 
	reg[width-1:0] regR, regQ;
	reg[width - 1:0] i; // voiam sa pun un $clog2(width), dar nu 
							  // m-am descurcat
	always @(*) begin
		
		// Initializare rezultat cu 0
		regR = 0;
		regQ = 0;
		
		// Test impartitor diferit de 0
		if(D) begin
			
			// Test impartitor <= deimpartit
			if(D <= N) begin
				// Executam partea din algoritm mai putin ultimul pas 
				for(i = width - 1; i >= 1; i = i - 1) begin
					// Shiftare rest la stanga
					regR = regR << 1;
					// Completare rest cu bit-ul curent din deimpartit
					regR[0] = N[i];
					// Daca restul a devenit mai mare decat impartitorul
					// scadem din rest impartitorul si punem bit-ul curent
					// din cat pe 1 
					if(regR >= D) begin
						regR = regR - D;
						regQ[i] = 1;
					end
					
				end
				// Executare ultim pas algoritm
				regR = regR << 1;
				regR[0] = N[0];
				if(regR >= D) begin
					regR = regR - D;
					regQ[i] = 1;
				end
			end
			else begin
				// Caz impartitor mai mare decat deimpartit
				regQ = 0;
				regR = N;
			end
		end
	
	end
	
	// Assignare rezultate
	assign R = regR;
	assign Q = regQ;
	
	
endmodule
