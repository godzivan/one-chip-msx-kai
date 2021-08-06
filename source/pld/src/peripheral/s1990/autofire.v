//
// autofire.v
//   Auto fire
//   Version 1.00
//
// Copyright (c) 2021 Takayuki Hara
// All rights reserved.
//
// Redistribution and use of this source code or any derivative works, are
// permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
// 3. Redistributions may not be sold, nor may they be used in a commercial
//    product or activity without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
// OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
// OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// ============================================================================
// History
// 2021/Aug/05  t.hara
//   1st release
// ============================================================================

module autofire (
		input			clk21m,
		input			reset,
		input			count_en,
		input			af_increment,
		input			af_decrement,
		output			af_mask,
		output	[3:0]	af_speed
	);
	reg					ff_count_en;
	reg		[3:0]		ff_af_speed;
	reg		[3:0]		ff_af_count;
	wire				w_count_en;
	reg					ff_af_mask;

	always @( posedge clk21m ) begin
		ff_count_en <= count_en;
	end

	assign w_count_en	= count_en & ~ff_count_en;

	always @( posedge reset or posedge clk21m ) begin
		if( reset ) begin
			ff_af_speed <= 4'b1111;
		end
		else if( af_increment ) begin
			if( ff_af_speed != 4'b1111 ) begin
				ff_af_speed <= ff_af_speed + 4'd1;
			end
			else begin
				//	hold
			end
		end
		else if( af_decrement ) begin
			if( ff_af_speed != 4'b0000 ) begin
				ff_af_speed <= ff_af_speed - 4'd1;
			end
			else begin
				//	hold
			end
		end
	end

	always @( posedge reset or posedge clk21m ) begin
		if( reset ) begin
			ff_af_count <= 4'd0;
		end
		else if( w_count_en ) begin
			if( ff_af_speed == 4'b1111 ) begin
				ff_af_count <= 4'd0;
			end
			else if( ff_af_count == 4'd0 ) begin
				ff_af_count <= ff_af_speed;
			end
			else begin
				ff_af_count <= ff_af_count - 4'd1;
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge reset or posedge clk21m ) begin
		if( reset ) begin
			ff_af_mask <= 1'd0;
		end
		else if( w_count_en && (ff_af_count == 4'd0) ) begin
			if( ff_af_speed == 4'b1111 ) begin
				ff_af_mask <= 1'd0;
			end
			else begin
				ff_af_mask <= ~ff_af_mask;
			end
		end
		else begin
			//	hold
		end
	end

	assign af_mask	= ff_af_mask;
	assign af_speed	= ff_af_speed;
endmodule
