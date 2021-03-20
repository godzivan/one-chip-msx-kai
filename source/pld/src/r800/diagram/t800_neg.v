//
//  t800_neg.v
//   NEG/CPL/CCF/SCF unit
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

module t800_neg (
	input	[7:0]	opecode,
	input	[7:0]	acc_q,
	input			cy_q,
	input			prefix_cb,
	input			prefix_ed,
	output	[7:0]	neg_result_d,
	output			neg_result_d_en,
	output			neg_sign_d,
	output			neg_sign_d_en,
	output			neg_zero_d,
	output			neg_zero_d_en,
	output			neg_yf_d,
	output			neg_yf_d_en,
	output			neg_half_cy_d,
	output			neg_half_cy_d_en,
	output			neg_xf_d,
	output			neg_xf_d_en,
	output			neg_pv_d,
	output			neg_pv_d_en,
	output			neg_negative_d,
	output			neg_negative_d_en,
	output			neg_cy_d,
	output			neg_cy_d_en
);
	wire	[8:0]	w_opecode;
	wire	[3:0]	w_opdec;
	wire			w_flag_d_en;
	wire	[7:0]	w_cpl_result;
	wire	[4:0]	w_neg_l;
	wire	[4:0]	w_neg_h;
	wire			w_neg_half_cy;
	wire			w_neg_cy;
	wire	[7:0]	w_result;

	assign w_opecode			= { prefix_cb, opecode };

	function [3:0] mux;
		input	[8:0]	opecode;
		input			prefix_ed;

		case( opecode )
		9'h2f:
			mux	= 4'b0001;
		9'h44:
			mux	= { 2'b00, prefix_ed, 1'b0 };
		9'h3f:
			mux	= 4'b0100;
		9'h37:
			mux	= 4'b1000;
		default:
			mux	= 4'b0000;
		endcase
	endfunction

	assign w_opdec				= mux( w_opecode, prefix_ed );
	assign w_flag_d_en			= (w_opdec != 4'b0000) ? 1'b1: 1'b0;

	assign w_cpl_result			= ~acc_q;

	assign w_neg_l				= 5'd0 - { 1'b0, acc_q[3:0] };
	assign w_neg_half_cy		= w_neg_l[4];
	assign w_neg_h				= { 5 { w_neg_l[4] } } - { 1'b0, acc_q[7:4] };
	assign w_neg_cy				= w_neg_h[4];

	assign w_result				= (w_opdec[0] ? w_cpl_result : 8'd0) | (w_opdec[1] ? { w_neg_h[3:0], w_neg_l[3:0] } : 8'd0);

	assign neg_result_d			= w_result;
	assign neg_result_d_en		= w_opdec[0] | w_opdec[1];

	assign neg_sign_d_en		= w_opdec[1];
	assign neg_zero_d_en		= w_opdec[1];
	assign neg_pv_d_en			= w_opdec[1];
	assign neg_yf_d_en			= w_flag_d_en;
	assign neg_xf_d_en			= w_flag_d_en;
	assign neg_half_cy_d_en		= w_flag_d_en;
	assign neg_negative_d_en	= w_flag_d_en;

	assign neg_sign_d			= w_opdec[1]  & w_result[7];
	assign neg_yf_d				= w_flag_d_en & w_result[5];
	assign neg_xf_d				= w_flag_d_en & w_result[3];

	assign neg_zero_d			= (w_result[7:0] == 8'd0) ? w_opdec[1]: 1'b0;

	assign neg_half_cy_d		= w_opdec[0] | (w_opdec[1] & w_neg_half_cy) | (w_opdec[2] & cy_q);

	assign neg_cy_d				= (w_opdec[1] & w_neg_cy) | (w_opdec[2] & ~cy_q) | w_opdec[3];
	assign neg_cy_d_en			= w_opdec[1] | w_opdec[2] | w_opdec[3];

	assign neg_pv_d				= w_opdec[1] & (acc_q[7] ^ w_neg_cy);

	assign neg_negative_d		= w_opdec[0] | w_opdec[1];
endmodule
