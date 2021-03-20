//
//  t800_register_file.v
//   Register file
//
//  Copyright (C) 2020 Takayuki Hara
//  All rights reserved.
//                               http://hraroom.s602.xrea.com/msx/ocm/index.html
//
//  �{�\�t�g�E�F�A����і{�\�t�g�E�F�A�Ɋ�Â��č쐬���ꂽ�h�����́A�ȉ��̏�����
//  �������ꍇ�Ɍ���A�ĔЕz����юg�p��������܂��B
//
//  1.�\�[�X�R�[�h�`���ōĔЕz����ꍇ�A��L�̒��쌠�\���A�{�����ꗗ�A����щ��L
//    �Ɛӏ��������̂܂܂̌`�ŕێ����邱�ƁB
//  2.�o�C�i���`���ōĔЕz����ꍇ�A�Еz���ɕt���̃h�L�������g���̎����ɁA��L��
//    ���쌠�\���A�{�����ꗗ�A����щ��L�Ɛӏ������܂߂邱�ƁB
//  3.���ʂɂ�鎖�O�̋��Ȃ��ɁA�{�\�t�g�E�F�A��̔��A����я��ƓI�Ȑ��i�⊈��
//    �Ɏg�p���Ȃ����ƁB
//
//  �{�\�t�g�E�F�A�́A���쌠�҂ɂ���āu����̂܂܁v�񋟂���Ă��܂��B���쌠�҂́A
//  ����ړI�ւ̓K�����̕ۏ؁A���i���̕ۏ؁A�܂�����Ɍ��肳��Ȃ��A�����Ȃ閾��
//  �I�������͈ÖقȕۏؐӔC�������܂���B���쌠�҂́A���R�̂�������킸�A���Q
//  �����̌�����������킸�A���ӔC�̍������_��ł��邩���i�ӔC�ł��邩�i�ߎ�
//  ���̑��́j�s�@�s�ׂł��邩���킸�A���ɂ��̂悤�ȑ��Q����������\����m��
//  ����Ă����Ƃ��Ă��A�{�\�t�g�E�F�A�̎g�p�ɂ���Ĕ��������i��֕i�܂��͑�p�T
//  �[�r�X�̒��B�A�g�p�̑r���A�f�[�^�̑r���A���v�̑r���A�Ɩ��̒��f���܂߁A�܂���
//  ��Ɍ��肳��Ȃ��j���ڑ��Q�A�Ԑڑ��Q�A�����I�ȑ��Q�A���ʑ��Q�A�����I���Q�A��
//  ���͌��ʑ��Q�ɂ��āA��ؐӔC�𕉂�Ȃ����̂Ƃ��܂��B
//
//  Note that above Japanese version license is the formal document.
//  The following translation is only for reference.
//
//  Redistribution and use of this software or any derivative works,
//  are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above
//     copyright notice, this list of conditions and the following
//     disclaimer in the documentation and/or other materials
//     provided with the distribution.
//  3. Redistributions may not be sold, nor may they be used in a
//     commercial product or activity without specific prior written
//     permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
//  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
//  COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
//  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
//  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
//  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.

module t800_register_file (
	input			reset,
	input			clk,
	input			clk_en,

	input			ex_af,
	input			exx,

	input			sign_d,
	input			sign_d_en,
	input			zero_d,
	input			zero_d_en,
	input			yf_d,
	input			yf_d_en,
	input			half_cy_d,
	input			half_cy_d_en,
	input			xf_d,
	input			xf_d_en,
	input			pv_d,
	input			pv_d_en,
	input			negative_d,
	input			negative_d_en,
	input			cy_d,
	input			cy_d_en,

	input	[7:0]	a_d,
	input			a_d_en,
	input	[7:0]	b_d,
	input			b_d_en,
	input	[7:0]	c_d,
	input			c_d_en,
	input	[7:0]	d_d,
	input			d_d_en,
	input	[7:0]	e_d,
	input			e_d_en,
	input	[7:0]	h_d,
	input			h_d_en,
	input	[7:0]	l_d,
	input			l_d_en,
	input	[7:0]	ixh_d,
	input			ixh_d_en,
	input	[7:0]	ixl_d,
	input			ixl_d_en,
	input	[7:0]	iyh_d,
	input			iyh_d_en,
	input	[7:0]	iyl_d,
	input			iyl_d_en,

	output			sign_q,
	output			zero_q,
	output			yf_q,
	output			half_cy_q,
	output			xf_q,
	output			pv_q,
	output			negative_q,
	output			cy_q,

	output	[7:0]	a_q,
	output	[7:0]	b_q,
	output	[7:0]	c_q,
	output	[7:0]	d_q,
	output	[7:0]	e_q,
	output	[7:0]	h_q,
	output	[7:0]	l_q,
	output	[7:0]	ixh_q,
	output	[7:0]	ixl_q,
	output	[7:0]	iyh_q,
	output	[7:0]	iyl_q
);
	reg				ff_af_bank;
	reg				ff_pr_bank;

	reg				ff_sign0;
	reg				ff_zero0;
	reg				ff_yf0;
	reg				ff_half_cy0;
	reg				ff_xf0;
	reg				ff_pv0;
	reg				ff_negative0;
	reg				ff_cy0;

	reg				ff_sign1;
	reg				ff_zero1;
	reg				ff_yf1;
	reg				ff_half_cy1;
	reg				ff_xf1;
	reg				ff_pv1;
	reg				ff_negative1;
	reg				ff_cy1;

	reg		[7:0]	ff_a0;
	reg		[7:0]	ff_b0;
	reg		[7:0]	ff_c0;
	reg		[7:0]	ff_d0;
	reg		[7:0]	ff_e0;
	reg		[7:0]	ff_h0;
	reg		[7:0]	ff_l0;

	reg		[7:0]	ff_a1;
	reg		[7:0]	ff_b1;
	reg		[7:0]	ff_c1;
	reg		[7:0]	ff_d1;
	reg		[7:0]	ff_e1;
	reg		[7:0]	ff_h1;
	reg		[7:0]	ff_l1;

	reg		[7:0]	ff_ixh;
	reg		[7:0]	ff_ixl;
	reg		[7:0]	ff_iyh;
	reg		[7:0]	ff_iyl;

	// exchange AF register --------------------------------
	always @( posedge reset or posedge clk ) begin
		if( reset ) begin
			ff_af_bank <= 1'b0;
		end
		else if( clk_en ) begin
			if( ex_af ) begin
				ff_af_bank <= ~ff_af_bank;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	// exchange pair registers -----------------------------
	always @( posedge reset or posedge clk ) begin
		if( reset ) begin
			ff_pr_bank <= 1'b0;
		end
		else if( clk_en ) begin
			if( exx ) begin
				ff_pr_bank <= ~ff_pr_bank;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	// general purpose registers ---------------------------
	always @( posedge reset or posedge clk ) begin
		if( reset ) begin
			ff_a0 <= 8'd0;
		end
		else if( clk_en ) begin
			if( ff_af_bank == 1'b0 && a_d_en ) begin
				ff_a0 <= a_d;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge reset or posedge clk ) begin
		if( reset ) begin
			ff_a1 <= 8'd0;
		end
		else if( clk_en ) begin
			if( ff_af_bank == 1'b1 && a_d_en ) begin
				ff_a1 <= a_d;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge reset or posedge clk ) begin
		if( reset ) begin
			ff_b0 <= 8'd0;
		end
		else if( clk_en ) begin
			if( ff_pr_bank == 1'b0 && b_d_en ) begin
				ff_b0 <= b_d;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge reset or posedge clk ) begin
		if( reset ) begin
			ff_b1 <= 8'd0;
		end
		else if( clk_en ) begin
			if( ff_pr_bank == 1'b1 && b_d_en ) begin
				ff_b1 <= b_d;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge reset or posedge clk ) begin
		if( reset ) begin
			ff_c0 <= 8'd0;
		end
		else if( clk_en ) begin
			if( ff_pr_bank == 1'b0 && c_d_en ) begin
				ff_c0 <= c_d;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge reset or posedge clk ) begin
		if( reset ) begin
			ff_c1 <= 8'd0;
		end
		else if( clk_en ) begin
			if( ff_pr_bank == 1'b1 && c_d_en ) begin
				ff_c1 <= c_d;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge reset or posedge clk ) begin
		if( reset ) begin
			ff_d0 <= 8'd0;
		end
		else if( clk_en ) begin
			if( ff_pr_bank == 1'b0 && d_d_en ) begin
				ff_d0 <= d_d;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge reset or posedge clk ) begin
		if( reset ) begin
			ff_d1 <= 8'd0;
		end
		else if( clk_en ) begin
			if( ff_pr_bank == 1'b1 && d_d_en ) begin
				ff_d1 <= d_d;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge reset or posedge clk ) begin
		if( reset ) begin
			ff_e0 <= 8'd0;
		end
		else if( clk_en ) begin
			if( ff_pr_bank == 1'b0 && e_d_en ) begin
				ff_e0 <= e_d;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge reset or posedge clk ) begin
		if( reset ) begin
			ff_e1 <= 8'd0;
		end
		else if( clk_en ) begin
			if( ff_pr_bank == 1'b1 && e_d_en ) begin
				ff_e1 <= e_d;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge reset or posedge clk ) begin
		if( reset ) begin
			ff_h0 <= 8'd0;
		end
		else if( clk_en ) begin
			if( ff_pr_bank == 1'b0 && h_d_en ) begin
				ff_h0 <= h_d;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge reset or posedge clk ) begin
		if( reset ) begin
			ff_h1 <= 8'd0;
		end
		else if( clk_en ) begin
			if( ff_pr_bank == 1'b1 && h_d_en ) begin
				ff_h1 <= h_d;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge reset or posedge clk ) begin
		if( reset ) begin
			ff_l0 <= 8'd0;
		end
		else if( clk_en ) begin
			if( ff_pr_bank == 1'b0 && l_d_en ) begin
				ff_l0 <= l_d;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge reset or posedge clk ) begin
		if( reset ) begin
			ff_l1 <= 8'd0;
		end
		else if( clk_en ) begin
			if( ff_pr_bank == 1'b1 && l_d_en ) begin
				ff_l1 <= l_d;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	// index registers -------------------------------------
	always @( posedge reset or posedge clk ) begin
		if( reset ) begin
			ff_ixh <= 8'd0;
		end
		else if( clk_en ) begin
			if( ixh_d_en ) begin
				ff_ixh0 <= ixh_d;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge reset or posedge clk ) begin
		if( reset ) begin
			ff_ixl <= 8'd0;
		end
		else if( clk_en ) begin
			if( ixl_d_en ) begin
				ff_ixl <= ixl_d;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge reset or posedge clk ) begin
		if( reset ) begin
			ff_iyh <= 8'd0;
		end
		else if( clk_en ) begin
			if( iyh_d_en ) begin
				ff_iyh0 <= iyh_d;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge reset or posedge clk ) begin
		if( reset ) begin
			ff_iyl <= 8'd0;
		end
		else if( clk_en ) begin
			if( iyl_d_en ) begin
				ff_iyl <= iyl_d;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	assign sign_q		= (ff_af_bank == 1'b0) ? ff_sign0		: ff_sign1;
	assign zero_q		= (ff_af_bank == 1'b0) ? ff_zero0		: ff_zero1;
	assign yf_q			= (ff_af_bank == 1'b0) ? ff_yf0			: ff_yf1;
	assign half_cy_q	= (ff_af_bank == 1'b0) ? ff_half_cy0	: ff_half_cy1;
	assign xf_q			= (ff_af_bank == 1'b0) ? ff_xf0			: ff_xf1;
	assign pv_q			= (ff_af_bank == 1'b0) ? ff_pv0			: ff_pv1;
	assign negative_q	= (ff_af_bank == 1'b0) ? ff_negative0	: ff_negative1;
	assign cy_q			= (ff_af_bank == 1'b0) ? ff_cy0			: ff_cy1;

	assign a_q			= (ff_af_bank == 1'b0) ? ff_a0: ff_a1;
	assign b_q			= (ff_pr_bank == 1'b0) ? ff_b0: ff_b1;
	assign c_q			= (ff_pr_bank == 1'b0) ? ff_c0: ff_c1;
	assign d_q			= (ff_pr_bank == 1'b0) ? ff_d0: ff_d1;
	assign e_q			= (ff_pr_bank == 1'b0) ? ff_e0: ff_e1;
	assign h_q			= (ff_pr_bank == 1'b0) ? ff_h0: ff_h1;
	assign l_q			= (ff_pr_bank == 1'b0) ? ff_l0: ff_l1;
	assign ixh_q		= ff_ixh;
	assign ixl_q		= ff_ixl;
	assign iyh_q		= ff_iyh;
	assign iyl_q		= ff_iyl;
endmodule
