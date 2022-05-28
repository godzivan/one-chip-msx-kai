module tb;
	localparam		clk_base	= 1000000000/21480;

	reg		[2:0]	ff_div6;

	reg				clk21m;
	reg				reset;
	reg				clkena;
	reg				Kmap;
	reg				Caps;
	reg				Kana;
	reg		[7:0]	PpiPortC;
	reg				CmtScro;

	wire			org_Paus;
	wire			org_Scro;
	wire			org_Reso;
	wire	[7:0]	org_Fkeys;
	wire			org_pPs2Clk;
	wire			org_pPs2Dat;
	wire	[7:0]	org_pKeyX;

	wire			dut_Paus;
	wire			dut_Scro;
	wire			dut_Reso;
	wire	[7:0]	dut_Fkeys;
	wire			dut_pPs2Clk;
	wire			dut_pPs2Dat;
	wire	[7:0]	dut_pKeyX;

	reg				ff_org_pPs2Clk;
	reg				ff_org_pPs2Dat;
	reg				ff_dut_pPs2Clk;
	reg				ff_dut_pPs2Dat;

	reg		[15:0]	ff_test_state;
	reg		[15:0]	ff_line_no;

	reg		[7:0]	ff_data;
	integer			i;

	// -------------------------------------------------------------
	//	clock generator
	// -------------------------------------------------------------
	always #(clk_base/2) begin
		clk21m	<= ~clk21m;
	end

	always @( posedge clk21m ) begin
		if( ff_div6 == 3'd0 ) begin
			ff_div6 <= 3'd5;
			clkena <= 1'b1;
		end
		else begin
			ff_div6	<= ff_div6 - 3'd1;
			clkena <= 1'b0;
		end
	end

	// -------------------------------------------------------------
	//	dut
	// -------------------------------------------------------------
	eseps2_original u_eseps2_original (
		.clk21m		( clk21m		),
		.reset		( reset			),
		.clkena		( clkena		),
		.Kmap		( Kmap			),
		.Caps		( Caps			),
		.Kana		( Kana			),
		.Paus		( org_Paus		),
		.Scro		( org_Scro		),
		.Reso		( org_Reso		),
		.Fkeys		( org_Fkeys		),
		.pPs2Clk	( org_pPs2Clk	),
		.pPs2Dat	( org_pPs2Dat	),
		.PpiPortC	( PpiPortC		),
		.pKeyX		( org_pKeyX		),
		.CmtScro	( CmtScro		)
	);

	eseps2 u_eseps2 (
		.clk21m		( clk21m		),
		.reset		( reset			),
		.clkena		( clkena		),
		.Kmap		( Kmap			),
		.Caps		( Caps			),
		.Kana		( Kana			),
		.Paus		( dut_Paus		),
		.Scro		( dut_Scro		),
		.Reso		( dut_Reso		),
		.Fkeys		( dut_Fkeys		),
		.pPs2Clk	( dut_pPs2Clk	),
		.pPs2Dat	( dut_pPs2Dat	),
		.PpiPortC	( PpiPortC		),
		.pKeyX		( dut_pKeyX		),
		.CmtScro	( CmtScro		)
//		.debug_sig	(				)
	);

	assign org_pPs2Clk = ff_org_pPs2Clk;
	assign org_pPs2Dat = ff_org_pPs2Dat;
	assign dut_pPs2Clk = ff_dut_pPs2Clk;
	assign dut_pPs2Dat = ff_dut_pPs2Dat;

	// -------------------------------------------------------------
	task send_bit(
		input			data
	);
		#40us
		ff_org_pPs2Clk <= 1'b1;
		ff_dut_pPs2Clk <= 1'b1;

		#20us
		ff_org_pPs2Dat <= data;
		ff_dut_pPs2Dat <= data;

		#20us
		ff_org_pPs2Clk <= 1'b0;
		ff_dut_pPs2Clk <= 1'b0;
	endtask

	// -------------------------------------------------------------
	task send_byte(
		input	[7:0]	data
	);
		// start bit
		ff_test_state = 1;
		send_bit( 1'b0 );
		// data bits
		ff_test_state = 2;
		send_bit( data[0] );
		ff_test_state = 3;
		send_bit( data[1] );
		ff_test_state = 4;
		send_bit( data[2] );
		ff_test_state = 5;
		send_bit( data[3] );
		ff_test_state = 6;
		send_bit( data[4] );
		ff_test_state = 7;
		send_bit( data[5] );
		ff_test_state = 8;
		send_bit( data[6] );
		ff_test_state = 9;
		send_bit( data[7] );
		// parity bit
		ff_test_state = 10;
		send_bit( data[0] ^ data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[5] ^ data[6] ^ data[7] ^ 1'b1 );
		// end bit
		ff_test_state = 11;
		send_bit( 1'b1 );
		ff_test_state = 12;
		
		#40us
		ff_org_pPs2Clk <= 1'b1;
		ff_dut_pPs2Clk <= 1'b1;

		#1us
		ff_org_pPs2Clk <= 1'bZ;
		ff_dut_pPs2Clk <= 1'bZ;
		ff_org_pPs2Dat <= 1'bZ;
		ff_dut_pPs2Dat <= 1'bZ;
		ff_test_state = 0;
	endtask

	// -------------------------------------------------------------
	task recv_bit(
		output			data
	);
		ff_org_pPs2Clk <= 1'b1;
		ff_dut_pPs2Clk <= 1'b1;

		#500ns
		data <= (dut_pPs2Dat === 1'bZ) ? 1'b1 : 1'b0;

		#39500ns
		ff_org_pPs2Clk <= 1'b0;
		ff_dut_pPs2Clk <= 1'b0;

		#40us
		ff_org_pPs2Clk <= 1'b1;
		ff_dut_pPs2Clk <= 1'b1;
	endtask

	// -------------------------------------------------------------
	task send_ack_bit(
		input			data
	);
		ff_org_pPs2Clk <= 1'b1;
		ff_dut_pPs2Clk <= 1'b1;
		#20us
		ff_org_pPs2Dat <= data;
		ff_dut_pPs2Dat <= data;
		#20us

		ff_org_pPs2Clk <= 1'b0;
		ff_dut_pPs2Clk <= 1'b0;
		#40us

		ff_org_pPs2Clk <= 1'b1;
		ff_dut_pPs2Clk <= 1'b1;
		#500ns
		ff_org_pPs2Dat <= 1'bZ;
		ff_dut_pPs2Dat <= 1'bZ;
	endtask

	// --------------------------------------------------------------------
	task recv_byte(
		output	[7:0]	data
	);
		reg ff_bit;

		ff_test_state = 101;
		ff_org_pPs2Clk <= 1'bZ;
		ff_dut_pPs2Clk <= 1'bZ;
		ff_org_pPs2Dat <= 1'bZ;
		ff_dut_pPs2Dat <= 1'bZ;

		// start bit
		@( dut_pPs2Clk === 1'b0 && dut_pPs2Dat === 1'b0 );
		@( dut_pPs2Clk === 1'bZ );
		ff_test_state = 102;
		recv_bit( ff_bit );
		ff_test_state = 103;
		assert( ff_bit == 1'b0 );

		// data bits
		recv_bit( data[0] );
		ff_test_state = 104;
		recv_bit( data[1] );
		ff_test_state = 105;
		recv_bit( data[2] );
		ff_test_state = 106;
		recv_bit( data[3] );
		ff_test_state = 107;
		recv_bit( data[4] );
		ff_test_state = 108;
		recv_bit( data[5] );
		ff_test_state = 109;
		recv_bit( data[6] );
		ff_test_state = 110;
		recv_bit( data[7] );
		ff_test_state = 111;
		// parity bit
		recv_bit( ff_bit );
		assert( ff_bit == ((^data) ^ 1'b1) );
		//	ack
		ff_test_state = 112;
		send_ack_bit( 1'b0 );

		# 100us
		ff_test_state = 113;
		ff_org_pPs2Clk <= 1'bZ;
		ff_dut_pPs2Clk <= 1'bZ;
		ff_org_pPs2Dat <= 1'bZ;
		ff_dut_pPs2Dat <= 1'bZ;
		ff_test_state = 0;
	endtask

	// -------------------------------------------------------------
	initial begin
		ff_test_state = 0;
		reset = 1;
		clk21m = 0;
		ff_div6 = 5;
		ff_org_pPs2Clk = 1'bZ;
		ff_org_pPs2Dat = 1'bZ;
		ff_dut_pPs2Clk = 1'bZ;
		ff_dut_pPs2Dat = 1'bZ;
		Kmap = 0;
		Caps = 0;
		Kana = 0;
		PpiPortC = 0;
		CmtScro = 0;
		ff_data = 0;
		ff_line_no = `__LINE__;

		repeat( 50 ) @( negedge clk21m );
		reset = 0;
		@( dut_pPs2Clk === 1'bZ );
		@( posedge clk21m );

		ff_line_no = `__LINE__;
		$display( "Receive RESET command." );
		recv_byte( ff_data );
		assert( ff_data == 8'hFF );
		$display( "-- 0x%02X", ff_data );

		#100us
		ff_line_no = `__LINE__;
		$display( "Send ACK." );
		send_byte( 8'hFA );

		#2ms
		ff_line_no = `__LINE__;
		$display( "Send BAT Completion." );
		send_byte( 8'hAA );

		ff_line_no = `__LINE__;
		$display( "Receive ID Read command." );
		recv_byte( ff_data );
		assert( ff_data == 8'hF2 );
		$display( "-- 0x%02X", ff_data );

		ff_line_no = `__LINE__;
		$display( "Send ACK." );
		send_byte( 8'hFA );

		ff_line_no = `__LINE__;
		$display( "Send ID1." );
		send_byte( 8'hAB );

		ff_line_no = `__LINE__;
		$display( "Send ID2." );
		send_byte( 8'h83 );

		ff_line_no = `__LINE__;
		$display( "Receive LED command." );
		recv_byte( ff_data );
		assert( ff_data == 8'hED );
		$display( "-- 0x%02X", ff_data );

		ff_line_no = `__LINE__;
		$display( "Send ACK." );
		send_byte( 8'hFA );

		ff_line_no = `__LINE__;
		$display( "Receive LED option ff_data." );
		recv_byte( ff_data );

		ff_line_no = `__LINE__;
		$display( "Send ACK." );
		send_byte( 8'hFA );

		ff_line_no = `__LINE__;
		$display( "Key press test:" );
		$display( "Scan Code 0x45: Full Key '0'" );
		send_byte( 8'h45 );
		# 50us
		assert( dut_pKeyX == 8'b11111110 );
		# 200us

		ff_line_no = `__LINE__;
		$display( "Scan Code 0x16: Full Key '1'" );
		send_byte( 8'h16 );
		# 50us
		assert( dut_pKeyX == 8'b11111100 );
		# 200us

		ff_line_no = `__LINE__;
		$display( "Scan Code 0x1E: Full Key '2'" );
		send_byte( 8'h1E );
		# 50us
		assert( dut_pKeyX == 8'b11111000 );
		# 200us

		ff_line_no = `__LINE__;
		$display( "Scan Code 0x26: Full Key '3'" );
		send_byte( 8'h26 );
		# 50us
		assert( dut_pKeyX == 8'b11110000 );
		# 200us

		ff_line_no = `__LINE__;
		$display( "Scan Code 0x25: Full Key '4'" );
		send_byte( 8'h25 );
		# 50us
		assert( dut_pKeyX == 8'b11100000 );
		# 200us

		ff_line_no = `__LINE__;
		$display( "Scan Code 0x2E: Full Key '5'" );
		send_byte( 8'h2E );
		# 50us
		assert( dut_pKeyX == 8'b11000000 );
		# 200us

		ff_line_no = `__LINE__;
		$display( "Scan Code 0x36: Full Key '6'" );
		send_byte( 8'h36 );
		# 50us
		assert( dut_pKeyX == 8'b10000000 );
		# 200us

		ff_line_no = `__LINE__;
		$display( "Scan Code 0x3D: Full Key '7'" );
		send_byte( 8'h3D );
		# 50us
		assert( dut_pKeyX == 8'b00000000 );
		# 200us

		ff_line_no = `__LINE__;
		$display( "Key release test:" );
		$display( "Scan Code 0x45: Full Key '0'" );
		send_byte( 8'hF0 );
		send_byte( 8'h45 );
		# 50us
		assert( dut_pKeyX == 8'b00000001 );
		# 200us

		ff_line_no = `__LINE__;
		$display( "Scan Code 0x16: Full Key '1'" );
		send_byte( 8'hF0 );
		send_byte( 8'h16 );
		# 50us
		assert( dut_pKeyX == 8'b00000011 );
		# 200us

		ff_line_no = `__LINE__;
		$display( "Scan Code 0x1E: Full Key '2'" );
		send_byte( 8'hF0 );
		send_byte( 8'h1E );
		# 50us
		assert( dut_pKeyX == 8'b00000111 );
		# 200us

		ff_line_no = `__LINE__;
		$display( "Scan Code 0x26: Full Key '3'" );
		send_byte( 8'hF0 );
		send_byte( 8'h26 );
		# 50us
		assert( dut_pKeyX == 8'b00001111 );
		# 200us

		ff_line_no = `__LINE__;
		$display( "Scan Code 0x25: Full Key '4'" );
		send_byte( 8'hF0 );
		send_byte( 8'h25 );
		# 50us
		assert( dut_pKeyX == 8'b00011111 );
		# 200us

		ff_line_no = `__LINE__;
		$display( "Scan Code 0x2E: Full Key '5'" );
		send_byte( 8'hF0 );
		send_byte( 8'h2E );
		# 50us
		assert( dut_pKeyX == 8'b00111111 );
		# 200us

		ff_line_no = `__LINE__;
		$display( "Scan Code 0x36: Full Key '6'" );
		send_byte( 8'hF0 );
		send_byte( 8'h36 );
		# 50us
		assert( dut_pKeyX == 8'b01111111 );
		# 200us

		ff_line_no = `__LINE__;
		$display( "Scan Code 0x3D: Full Key '7'" );
		send_byte( 8'hF0 );
		send_byte( 8'h3D );
		# 50us
		assert( dut_pKeyX == 8'b11111111 );
		# 200us

		ff_line_no = `__LINE__;
		$display( "Pause/Break key test:" );
		send_byte( 8'hE1 );
		send_byte( 8'h14 );
		send_byte( 8'h77 );
		send_byte( 8'hE1 );
		send_byte( 8'hF0 );
		send_byte( 8'h14 );
		send_byte( 8'hF0 );
		send_byte( 8'h77 );
		for( i = 0; i < 16; i++ ) begin
			PpiPortC <= i;
			# 50us
			assert( dut_pKeyX == 8'b11111111 );
		end
		PpiPortC <= i;
		# 200us

		$display( "Pause/Break key test2:" );
		send_byte( 8'hE1 );
		send_byte( 8'h14 );
		send_byte( 8'h77 );
		send_byte( 8'hE1 );
		send_byte( 8'hF0 );
		send_byte( 8'h14 );
		send_byte( 8'hF0 );
		send_byte( 8'h77 );
		for( i = 0; i < 16; i++ ) begin
			PpiPortC <= i;
			# 50us
			assert( dut_pKeyX == 8'b11111111 );
		end
		PpiPortC <= i;
		# 200us

		ff_line_no = `__LINE__;
		$display( "PrtSc key test:" );
		send_byte( 8'hE0 );
		send_byte( 8'h12 );
		send_byte( 8'hE0 );
		send_byte( 8'h7C );
		for( i = 0; i < 16; i++ ) begin
			PpiPortC <= i;
			# 50us
			assert( dut_pKeyX == 8'b11111111 );
		end
		PpiPortC <= i;
		# 200us

		ff_line_no = `__LINE__;
		$display( "ALT Right key test:" );
		send_byte( 8'hE0 );
		send_byte( 8'h11 );
		# 200us

		send_byte( 8'hE0 );
		send_byte( 8'hF0 );
		send_byte( 8'h11 );
		# 200us

		ff_line_no = `__LINE__;
		# 50us
		assert( dut_Fkeys[6] == 1'b0 );
		$display( "CTRL Left key test:" );
		send_byte( 8'h14 );
		# 50us
		assert( dut_Fkeys[6] == 1'b1 );
		# 200us

		send_byte( 8'hF0 );
		send_byte( 8'h14 );
		# 50us
		assert( dut_Fkeys[6] == 1'b0 );
		# 200us

		ff_line_no = `__LINE__;
		$display( "CTRL Right key test:" );
		send_byte( 8'hE0 );
		send_byte( 8'h14 );
		# 50us
		assert( dut_Fkeys[6] == 1'b1 );
		# 200us

		send_byte( 8'hE0 );
		send_byte( 8'hF0 );
		send_byte( 8'h14 );
		# 50us
		assert( dut_Fkeys[6] == 1'b0 );
		# 200us

		# 50us
		assert( dut_Fkeys[7] == 1'b0 );
		$display( "SHIFT Left key test:" );
		send_byte( 8'h12 );
		# 50us
		assert( dut_Fkeys[7] == 1'b1 );
		# 200us

		send_byte( 8'hF0 );
		send_byte( 8'h12 );
		# 50us
		assert( dut_Fkeys[7] == 1'b0 );
		# 200us

		ff_line_no = `__LINE__;
		$display( "SHIFT Right key test:" );
		send_byte( 8'h59 );
		# 50us
		assert( dut_Fkeys[7] == 1'b1 );
		# 200us

		send_byte( 8'hF0 );
		send_byte( 8'h59 );
		# 50us
		assert( dut_Fkeys[7] == 1'b0 );
		# 200us

		ff_line_no = `__LINE__;
		$display( "Win Left key test:" );
		send_byte( 8'hE0 );
		send_byte( 8'h1F );
		# 200us

		send_byte( 8'hE0 );
		send_byte( 8'hF0 );
		send_byte( 8'h1F );
		# 200us

		ff_line_no = `__LINE__;
		$display( "Win Right key test:" );
		send_byte( 8'hE0 );
		send_byte( 8'h27 );
		# 200us

		send_byte( 8'hE0 );
		send_byte( 8'hF0 );
		send_byte( 8'h27 );
		# 200us

		ff_line_no = `__LINE__;
		$display( "PPI Port#C test:" );
		send_byte( 8'h45 );			//	0
		send_byte( 8'h46 );			//	9
		send_byte( 8'h41 );			//	,
		send_byte( 8'h2B );			//	F
		send_byte( 8'h44 );			//	O
		send_byte( 8'h22 );			//	X
		send_byte( 8'h06 );			//	F2
		send_byte( 8'h5A );			//	ENTER
		send_byte( 8'h29 );			//	SPACE
		send_byte( 8'hE0 );			//	HOME (1st)
		send_byte( 8'h6C );			//	HOME (2nd)
		send_byte( 8'h7C );			//	* (NUMPAD)
		send_byte( 8'hE0 );			//	/ (NUMPAD) (1st)
		send_byte( 8'h4A );			//	/ (NUMPAD) (2nd)
		send_byte( 8'h73 );			//	5 (NUMPAD)
		send_byte( 8'h75 );			//	8 (NUMPAD)
		send_byte( 8'h67 );			//	��� 
		send_byte( 8'h64 );			//	���s 
		send_byte( 8'hE0 );			//	PgUp (1st)
		send_byte( 8'h7A );			//	PgUp (2nd)
		send_byte( 8'hE0 );			//	PgDn (1st)
		send_byte( 8'h7D );			//	PgDn (2nd)
		send_byte( 8'h01 );			//	F9
		send_byte( 8'h09 );			//	F10
		send_byte( 8'h78 );			//	F11
		send_byte( 8'h07 );			//	F12
		# 200us

		ff_line_no = `__LINE__;
		@( posedge clkena );
		PpiPortC <= 0;
		# 50us
		assert( dut_pKeyX == 8'b11111110 );
		PpiPortC <= 1;
		# 50us
		assert( dut_pKeyX == 8'b11111101 );
		PpiPortC <= 2;
		# 50us
		assert( dut_pKeyX == 8'b11111011 );
		PpiPortC <= 3;
		# 50us
		assert( dut_pKeyX == 8'b11110111 );
		PpiPortC <= 4;
		# 50us
		assert( dut_pKeyX == 8'b11101111 );
		PpiPortC <= 5;
		# 50us
		assert( dut_pKeyX == 8'b11011111 );
		PpiPortC <= 6;
		# 50us
		assert( dut_pKeyX == 8'b10111111 );
		PpiPortC <= 7;
		# 50us
		assert( dut_pKeyX == 8'b01111111 );
		PpiPortC <= 8;
		# 50us
		assert( dut_pKeyX == 8'b11111100 );
		PpiPortC <= 9;
		# 50us
		assert( dut_pKeyX == 8'b11111010 );
		PpiPortC <= 10;
		# 50us
		assert( dut_pKeyX == 8'b11110110 );
		PpiPortC <= 11;
		# 50us
		assert( dut_pKeyX == 8'b11110101 );
		PpiPortC <= 12;
		# 50us
		assert( dut_pKeyX == 8'b11111111 );
		PpiPortC <= 13;
		# 50us
		assert( dut_pKeyX == 8'b11111111 );
		PpiPortC <= 14;
		# 50us
		assert( dut_pKeyX == 8'b11111111 );
		PpiPortC <= 15;
		# 50us
		assert( dut_pKeyX == 8'b11000000 );
		# 200us

		ff_line_no = `__LINE__;
		send_byte( 8'hF0 );
		send_byte( 8'h45 );			//	0
		send_byte( 8'hF0 );
		send_byte( 8'h46 );			//	9
		send_byte( 8'hF0 );
		send_byte( 8'h41 );			//	,
		send_byte( 8'hF0 );
		send_byte( 8'h2B );			//	F
		send_byte( 8'hF0 );
		send_byte( 8'h44 );			//	O
		send_byte( 8'hF0 );
		send_byte( 8'h22 );			//	X
		send_byte( 8'hF0 );
		send_byte( 8'h06 );			//	F2
		send_byte( 8'hF0 );
		send_byte( 8'h5A );			//	ENTER
		send_byte( 8'hF0 );
		send_byte( 8'h29 );			//	SPACE
		send_byte( 8'hE0 );			//	HOME (1st)
		send_byte( 8'hF0 );
		send_byte( 8'h6C );			//	HOME (2nd)
		send_byte( 8'hF0 );
		send_byte( 8'h7C );			//	* (NUMPAD)
		send_byte( 8'hE0 );			//	/ (NUMPAD) (1st)
		send_byte( 8'hF0 );
		send_byte( 8'h4A );			//	/ (NUMPAD) (2nd)
		send_byte( 8'hF0 );
		send_byte( 8'h73 );			//	5 (NUMPAD)
		send_byte( 8'hF0 );
		send_byte( 8'h75 );			//	8 (NUMPAD)
		send_byte( 8'hF0 );
		send_byte( 8'h67 );			//	��� 
		send_byte( 8'hF0 );
		send_byte( 8'h64 );			//	���s 
		send_byte( 8'hE0 );			//	PgUp (1st)
		send_byte( 8'hF0 );
		send_byte( 8'h7A );			//	PgUp (2nd)
		send_byte( 8'hE0 );			//	PgDn (1st)
		send_byte( 8'hF0 );
		send_byte( 8'h7D );			//	PgDn (2nd)
		send_byte( 8'hF0 );
		send_byte( 8'h01 );			//	F9
		send_byte( 8'hF0 );
		send_byte( 8'h09 );			//	F10
		send_byte( 8'hF0 );
		send_byte( 8'h78 );			//	F11
		send_byte( 8'hF0 );
		send_byte( 8'h07 );			//	F12
		# 200us

		ff_line_no = `__LINE__;
		@( posedge clkena );
		PpiPortC <= 0;
		# 50us
		assert( dut_pKeyX == 8'b11111111 );
		PpiPortC <= 1;
		# 50us
		assert( dut_pKeyX == 8'b11111111 );
		PpiPortC <= 2;
		# 50us
		assert( dut_pKeyX == 8'b11111111 );
		PpiPortC <= 3;
		# 50us
		assert( dut_pKeyX == 8'b11111111 );
		PpiPortC <= 4;
		# 50us
		assert( dut_pKeyX == 8'b11111111 );
		PpiPortC <= 5;
		# 50us
		assert( dut_pKeyX == 8'b11111111 );
		PpiPortC <= 6;
		# 50us
		assert( dut_pKeyX == 8'b11111111 );
		PpiPortC <= 7;
		# 50us
		assert( dut_pKeyX == 8'b11111111 );
		PpiPortC <= 8;
		# 50us
		assert( dut_pKeyX == 8'b11111111 );
		PpiPortC <= 9;
		# 50us
		assert( dut_pKeyX == 8'b11111111 );
		PpiPortC <= 10;
		# 50us
		assert( dut_pKeyX == 8'b11111111 );
		PpiPortC <= 11;
		# 50us
		assert( dut_pKeyX == 8'b11111111 );
		PpiPortC <= 12;
		# 50us
		assert( dut_pKeyX == 8'b11111111 );
		PpiPortC <= 13;
		# 50us
		assert( dut_pKeyX == 8'b11111111 );
		PpiPortC <= 14;
		# 50us
		assert( dut_pKeyX == 8'b11111111 );
		PpiPortC <= 15;
		# 50us
		assert( dut_pKeyX == 8'b11111111 );
		# 200us

		ff_line_no = `__LINE__;
		$display( "CAPS LED Control test:" );
		ff_org_pPs2Clk = 1'bZ;
		ff_org_pPs2Dat = 1'bZ;
		ff_dut_pPs2Clk = 1'bZ;
		ff_dut_pPs2Dat = 1'bZ;

		//	US Keymap
		Kmap = 1'b1;

		# 50us
		PpiPortC <= 6;
		assert( dut_Fkeys[7] == 1'b0 );
		$display( "SHIFT Left key test:" );
		send_byte( 8'h12 );
		# 50us
		assert( dut_Fkeys[7] == 1'b1 );
		assert( dut_pKeyX == 8'b11111110 );
		# 200us

		# 50us
		PpiPortC <= 1;
		$display( "'2' key test ('@' Key test):" );
		send_byte( 8'h1E );
		# 200us
		assert( dut_pKeyX == 8'b11011111 );
		PpiPortC <= 6;
		# 200us
		assert( dut_pKeyX == 8'b11111111 );
		# 200us

		ff_line_no = `__LINE__;
		$display( "PgUp key test:" );
		send_byte( 8'hE0 );			//	PgUp (1st) press
		send_byte( 8'h7D );			//	PgUp (2nd) press
		# 200us
		send_byte( 8'hE0 );			//	PgUp (1st) unpress
		send_byte( 8'hF0 );			//	PgUp (2nd) unpress
		send_byte( 8'h7D );			//	PgUp (3rd) unpress
		# 200us
		send_byte( 8'hE0 );			//	PgUp (1st) press
		send_byte( 8'h7D );			//	PgUp (2nd) press
		# 200us
		send_byte( 8'hE0 );			//	PgUp (1st) unpress
		send_byte( 8'hF0 );			//	PgUp (2nd) unpress
		send_byte( 8'h7D );			//	PgUp (3rd) unpress
		# 300us

		ff_line_no = `__LINE__;
		$display( "PgDn key test:" );
		send_byte( 8'hE0 );			//	PgDn (1st) press
		send_byte( 8'h7A );			//	PgDn (2nd) press
		# 200us
		send_byte( 8'hE0 );			//	PgDn (1st) unpress
		send_byte( 8'hF0 );			//	PgDn (2nd) unpress
		send_byte( 8'h7A );			//	PgDn (3rd) unpress
		# 200us
		send_byte( 8'hE0 );			//	PgDn (1st) press
		send_byte( 8'h7A );			//	PgDn (2nd) press
		# 200us
		send_byte( 8'hE0 );			//	PgDn (1st) unpress
		send_byte( 8'hF0 );			//	PgDn (2nd) unpress
		send_byte( 8'h7A );			//	PgDn (3rd) unpress
		# 300us

		ff_line_no = `__LINE__;
		$display( "F9 key test:" );
		send_byte( 8'h01 );			//	F9 press
		# 200us
		send_byte( 8'hF0 );			//	F9 (1st) unpress
		send_byte( 8'h01 );			//	F9 (2nd) unpress
		# 200us
		send_byte( 8'h01 );			//	F9 press
		# 200us
		send_byte( 8'hF0 );			//	F9 (1st) unpress
		send_byte( 8'h01 );			//	F9 (2nd) unpress
		# 300us

		ff_line_no = `__LINE__;
		$display( "F10 key test:" );
		send_byte( 8'h09 );			//	F10 press
		# 200us
		send_byte( 8'hF0 );			//	F10 (1st) unpress
		send_byte( 8'h09 );			//	F10 (2nd) unpress
		# 200us
		send_byte( 8'h09 );			//	F10 press
		# 200us
		send_byte( 8'hF0 );			//	F10 (1st) unpress
		send_byte( 8'h09 );			//	F10 (2nd) unpress
		# 300us

		ff_line_no = `__LINE__;
		$display( "F11 key test:" );
		send_byte( 8'h78 );			//	F11 press
		# 200us
		send_byte( 8'hF0 );			//	F11 (1st) unpress
		send_byte( 8'h78 );			//	F11 (2nd) unpress
		# 200us
		send_byte( 8'h78 );			//	F11 press
		# 200us
		send_byte( 8'hF0 );			//	F11 (1st) unpress
		send_byte( 8'h78 );			//	F11 (2nd) unpress
		# 300us

		ff_line_no = `__LINE__;
		$display( "F12 key test:" );
		send_byte( 8'h07 );			//	F12 press
		# 200us
		send_byte( 8'hF0 );			//	F12 (1st) unpress
		send_byte( 8'h07 );			//	F12 (2nd) unpress
		# 200us
		send_byte( 8'h07 );			//	F12 press
		# 200us
		send_byte( 8'hF0 );			//	F12 (1st) unpress
		send_byte( 8'h07 );			//	F12 (2nd) unpress
		# 300us

		$finish;
	end
endmodule
