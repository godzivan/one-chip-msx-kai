//
//  t800_daa.v
//   DAA unit
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

module t800_daa (
	input	[7:0]	opecode,
	input	[7:0]	acc_q,
	input			cy_q,
	input			half_cy_q,
	input			negative_q,
	input			prefix_cb,
	input			prefix_ed,
	output	[7:0]	daa_acc_d,
	output			daa_acc_d_en,
	output			daa_sign_d,
	output			daa_sign_d_en,
	output			daa_zero_d,
	output			daa_zero_d_en,
	output			daa_yf_d,
	output			daa_yf_d_en,
	output			daa_half_cy_d,
	output			daa_half_cy_d_en,
	output			daa_xf_d,
	output			daa_xf_d_en,
	output			daa_pv_d,
	output			daa_pv_d_en,
	output			daa_cy_d,
	output			daa_cy_d_en
);
	wire			w_flag_d_en;
	wire	[3:0]	w_acc_l;
	wire	[7:4]	w_acc_h;
	wire	[3:0]	w_acc_l_cond;
	wire	[3:0]	w_acc_h_cond;
	wire			w_acc_l_cond2;
	wire	[5:0]	w_acc_cond;
	wire	[3:0]	w_acc_half_cond;
	wire	[7:0]	w_result;
	wire			w_cy;
	wire			w_half_cy;
	wire	[7:0]	w_decimal_adjust;
	wire	[7:0]	w_add;
	wire	[7:0]	w_sub;

	assign w_acc_l				= acc_q[3:0];
	assign w_acc_h				= acc_q[7:4];

	function [1:0] mux_cond;
		input	[3:0]	w_acc;

		casex( w_acc )
		4'b0xxx:
			mux_cond = 2'b11;
		4'b1000:
			mux_cond = 2'b11;
		4'b1001:
			mux_cond = 2'b10;
		default:
			mux_cond = 2'b00;
		endcase
	endfunction

	function mux_cond2;
		input	[3:0]	w_acc;

		casex( w_acc )
		4'b00xx:
			mux_cond2 = 1'b0;
		4'b010x:
			mux_cond2 = 1'b0;
		default:
			mux_cond2 = 1'b1;
		endcase
	endfunction

	function [7:0] mux_decimal_adjust;
		input	[5:0]	w_acc_cond;

		casex( w_acc_cond )
		6'b00_00_00:
			mux_decimal_adjust = 8'h00;
		6'b01_00_00:
			mux_decimal_adjust = 8'h06;
		6'b0x_x0_1x:
			mux_decimal_adjust = 8'h06;
		6'b00_1x_00:
			mux_decimal_adjust = 8'h60;
		6'b10_xx_00:
			mux_decimal_adjust = 8'h60;
		default:
			mux_decimal_adjust = 8'h66;
		endcase
	endfunction

	function mux_cy;
		input	[5:0]	w_acc_cond;

		casex( w_acc_cond )
		6'b0x_00_00:
			mux_cy = 1'b0;
		6'b0x_x0_1x:
			mux_cy = 1'b0;
		6'b0x_x1_1x:
			mux_cy = 1'b1;
		6'b0x_1x_00:
			mux_cy = 1'b1;
		default:
			mux_cy = 1'b1;
		endcase
	endfunction

	function mux_half_cy;
		input	[3:0]	w_acc_half_cond;

		casex( w_acc_half_cond )
		4'b0x_x0:
			mux_cy = 1'b0;
		4'b0x_x1:
			mux_cy = 1'b1;
		4'b10_xx:
			mux_cy = 1'b0;
		4'b11_0x:
			mux_cy = 1'b0;
		default:
			mux_cy = 1'b1;
		endcase
	endfunction

	assign w_acc_l_cond			= mux_cond( w_acc_l );
	assign w_acc_h_cond			= mux_cond( w_acc_h );
	assign w_acc_l_cond2		= mux_cond2( w_acc_l );
	assign w_acc_cond			= { cy_q, half_cy_q, w_acc_h_cond, w_acc_l_cond };
	assign w_acc_half_cond		= { negative_q, half_cy_q, w_acc_l_cond2, w_acc_l_cond[1] }

	assign w_decimal_adjust		= mux_decimal_adjust( w_acc_cond );
	assign w_cy					= mux_cy( w_acc_cond );
	assign w_half_cy			= mux_half_cy( w_acc_half_ond );

	assign w_add				= acc_q + w_decimal_adjust;
	assign w_sub				= acc_q - w_decimal_adjust;
	assign w_result				= negative_q ? w_sub: w_add;

	assign w_flag_d_en			= (opecode == 8'h27 && ~(prefix_cb | prefix_ed)) ? 1'b1: 1'b0;

	assign daa_acc_d_en			= w_flag_d_en;
	assign daa_sign_d_en		= w_flag_d_en;
	assign daa_zero_d_en		= w_flag_d_en;
	assign daa_yf_d_en			= w_flag_d_en;
	assign daa_half_cy_d_en		= w_flag_d_en;
	assign daa_xf_d_en			= w_flag_d_en;
	assign daa_pv_d_en			= w_flag_d_en;
	assign daa_cy_d_en			= w_flag_d_en;

	assign daa_acc_d			= w_flag_d_en ? w_result: 8'd0;
	assign daa_sign_d			= w_flag_d_en & w_result[7];
	assign daa_zero_d			= (w_result == 8'd0) ? w_flag_d_en: 1'b0;
	assign daa_yf_d				= w_flag_d_en & w_result[5];
	assign daa_half_cy_d		= w_flag_d_en & w_half_cy;
	assign daa_xf_d				= w_flag_d_en & w_result[3];
	assign daa_pv_d				= w_flag_d_en & ~(w_result[7] ^ w_result[6] ^ w_result[5] ^ w_result[4] ^ w_result[3] ^ w_result[2] ^ w_result[1] ^ w_result[0]);
	assign daa_cy_d				= w_flag_d_en & w_cy;
endmodule
