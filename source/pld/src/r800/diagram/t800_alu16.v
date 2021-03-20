//
//  t800_alu16.v
//   Arithmetic logical unit for 16bit
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

module t800_alu16 (
	input	[ 7:0]	opecode,
	input	[15:0]	acc_q,
	input	[15:0]	operand_q,
	input			cy_q,
	input			prefix_cb,
	input			prefix_ed,
	output	[15:0]	alu16_acc_d,
	output			alu16_acc_d_en,
	output			alu16_sign_d,
	output			alu16_sign_d_en,
	output			alu16_zero_d,
	output			alu16_zero_d_en,
	output			alu16_yf_d,
	output			alu16_yf_d_en,
	output			alu16_half_cy_d,
	output			alu16_half_cy_d_en,
	output			alu16_xf_d,
	output			alu16_xf_d_en,
	output			alu16_pv_d,
	output			alu16_pv_d_en,
	output			alu16_negative_d,
	output			alu16_negative_d_en,
	output			alu16_cy_d,
	output			alu16_cy_d_en
);
	wire			w_cy_q;
	wire	[ 7:0]	w_acc_q;
	wire	[12:0]	w_add_l;
	wire	[ 4:0]	w_add_h;
	wire	[12:0]	w_sub_l;
	wire	[ 4:0]	w_sub_h;
	wire	[12:0]	w_result_l;
	wire	[ 4:0]	w_result_h;
	wire	[15:0]	w_result;
	wire			w_half_cy;
	wire			w_cy;
	wire			w_overflow;
	wire			w_prefix;
	wire	[ 1:0]	w_flag_d_en;
	wire			w_flag0_d_en;
	wire			w_flag1_d_en;

	assign w_result				= { w_result_h[3:0], w_result_l[11:0] };
	assign w_cy_q				= cy_q & opecode[6];
	assign w_acc_q				= (opecode[1:0] != 2'b11) ? acc_q: 8'd1;
	assign w_prefix				= ~(prefix_cb | prefix_ed);
	assign w_add_l				= { 1'b0, w_acc_q[11: 0] } + { 1'b0, operand_q[11: 0] } + { 12'd0, w_cy_q };
	assign w_sub_l				= { 1'b0, w_acc_q[11: 0] } - { 1'b0, operand_q[11: 0] } - { 12'd0, w_cy_q };
	assign w_add_h				= { 1'b0, w_acc_q[15:12] } + { 1'b0, operand_q[15:12] } + { 12'd0, w_half_cy };
	assign w_sub_h				= { 1'b0, w_acc_q[15:12] } - { 1'b0, operand_q[15:12] } - { 12'd0, w_half_cy };

	function [1:0] mux_flag_d_en;
		input	[7:0]	opecode;

		casex( opecode )
		8'b01xx1010, 8'b01xx0010:
			mux_flag_d_en = 2'b11;
		8'b00xx1001:
			mux_flag_d_en = 2'b01;
		default:
			mux_flag_d_en = 2'b00;
		endcase
	endfunction

	assign w_flag_d_en			= mux_flag_d_en( opecode );
	assign w_flag0_d_en			= w_prefix & w_flag_d[0];
	assign w_flag1_d_en			= w_prefix & w_flag_d[1];

	function [12:0] mux_result_l;
		input	[ 7:0]	opecode;
		input	[12:0]	w_add_l;
		input	[12:0]	w_sub_l;
	
		casex( opecode )
		8'b00xx1001, 8'b01xx1010, 8'b00xx0011:
			mux_result_l = w_add_l;
		8'b01xx0010, 8'b00xx1011:
			mux_result_l = w_sub_l;
		default:
			mux_result_l = 13'd0;
		endcase
	endfunction

	function [12:0] mux_result_h;
		input	[7:0]	opecode;
		input	[4:0]	w_add_h;
		input	[4:0]	w_sub_h;
	
		casex( opecode )
		8'b00xx1001, 8'b01xx1010, 8'b00xx0011:
			mux_result_h = w_add_h;
		8'b01xx0010, 8'b00xx1011:
			mux_result_h = w_sub_h;
		default:
			mux_result_h = 5'd0;
		endcase
	endfunction

	assign w_result_l			= mux_result_l( opecode, w_add_l, w_sub_l );
	assign w_result_h			= mux_result_h( opecode, w_add_h, w_sub_h );

	assign w_half_cy			= w_result_l[12];
	assign w_cy					= w_result_h[4];

	assign w_overflow			= w_acc_q[15] ^ operand_q[15] ^ w_cy;
	assign w_flag_d_en			= w_prefix & w_opdec[0];

	assign alu16_acc_d			= w_result;
	assign alu16_acc_d_en		= w_prefix & w_opdec[1];

	assign alu16_zero_d			= ( w_result == 16'd0 ) ? 1'b1: 1'b0;
	assign alu16_half_cy_d		= w_half_cy;
	assign alu16_cy_d			= w_cy;
	assign alu16_pv_d			= w_overflow;
	assign alu16_negative_d		= (opecode == 8'b01xx0010) ? 1'b1: 1'b0;
	assign alu16_sign_d			= w_result[15];
	assign alu16_yf_d			= w_result[13];
	assign alu16_xf_d			= w_result[11];

	assign alu16_yf_d_en		= w_flag0_d_en;
	assign alu16_half_cy_d_en	= w_flag0_d_en;
	assign alu16_xf_d_en		= w_flag0_d_en;
	assign alu16_negative_d_en	= w_flag0_d_en;
	assign alu16_cy_d_en		= w_flag0_d_en;

	assign alu16_sign_d_en		= w_flag1_d_en;
	assign alu16_zero_d_en		= w_flag1_d_en;
	assign alu16_pv_d_en		= w_flag1_d_en;
endmodule
