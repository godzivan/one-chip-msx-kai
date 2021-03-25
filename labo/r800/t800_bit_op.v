//
//  t800_bit_op.v
//   bit operation unit
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

module t800_bit_op (
	input	[7:0]	opecode,
	input	[7:0]	operand_q,
	input			cy_q,
	input			prefix_cb,
	input			prefix_ed,
	output	[7:0]	bit_op_result_d,
	output			bit_op_result_d_en,
	output			bit_op_sign_d,
	output			bit_op_sign_d_en,
	output			bit_op_zero_d,
	output			bit_op_zero_d_en,
	output			bit_op_yf_d,
	output			bit_op_yf_d_en,
	output			bit_op_half_cy_d,
	output			bit_op_half_cy_d_en,
	output			bit_op_xf_d,
	output			bit_op_xf_d_en,
	output			bit_op_pv_d,
	output			bit_op_pv_d_en,
	output			bit_op_negative_d,
	output			bit_op_negative_d_en
);
	wire			w_prefix;
	wire			w_flag_d_en;
	wire			w_op_bit;
	wire			w_op_set;
	wire			w_op_res;
	wire	[7:0]	w_set_bit;
	wire	[7:0]	w_result_bit;
	wire	[7:0]	w_result_set;
	wire	[7:0]	w_result_res;
	wire	[7:0]	w_mask_bit;
	wire	[7:0]	w_mask_set;
	wire	[7:0]	w_mask_res;

	assign w_prefix				= (~prefix_ed) & prefix_cb;
	assign w_flag_d_en			= w_prefix & w_op_bit;

	assign w_op_bit				= ~opecode[7] &  opecode[6];
	assign w_op_set				=  opecode[7] &  opecode[6];
	assign w_op_res				=  opecode[7] & ~opecode[6];

	function [7:0] mux_set;
		input	[2:0]	opecode;

		case( opecode )
		3'd0:
			mux_set = 8'b00000001;
		3'd1:
			mux_set = 8'b00000010;
		3'd2:
			mux_set = 8'b00000100;
		3'd3:
			mux_set = 8'b00001000;
		3'd4:
			mux_set = 8'b00010000;
		3'd5:
			mux_set = 8'b00100000;
		3'd6:
			mux_set = 8'b01000000;
		default:
			mux_set = 8'b10000000;
		endcase
	endfunction

	assign w_set_bit			= mux_set( opecode[5:3] );
	assign w_result_bit			= operand_q &  w_set_bit;
	assign w_result_set			= operand_q |  w_set_bit;
	assign w_result_res			= operand_q & ~w_set_bit;
	assign w_mask_bit			= (w_prefix & w_op_bit) ? w_result_bit: 8'd0;
	assign w_mask_set			= (w_prefix & w_op_set) ? w_result_set: 8'd0;
	assign w_mask_res			= (w_prefix & w_op_res) ? w_result_res: 8'd0;

	assign bit_op_result_d_en	= w_prefix & (w_op_bit | w_op_set | w_op_res);
	assign bit_op_sign_d_en		= w_flag_d_en;
	assign bit_op_zero_d_en		= w_flag_d_en;
	assign bit_op_yf_d_en		= w_flag_d_en;
	assign bit_op_half_cy_d_en	= w_flag_d_en;
	assign bit_op_xf_d_en		= w_flag_d_en;
	assign bit_op_pv_d_en		= w_flag_d_en;
	assign bit_op_negative_d_en	= w_flag_d_en;

	assign w_zero_d				= (w_result_bit == 8'd0) ? w_flag_d_en: 1'b0;
	assign bit_op_result_d		= w_mask_bit | w_mask_set | w_mask_res;
	assign bit_op_sign_d		= w_mask_bit[7];
	assign bit_op_zero_d		= w_zero_d;
	assign bit_op_yf_d			= w_mask_bit[5];
	assign bit_op_half_cy_d		= w_flag_d_en;
	assign bit_op_xf_d			= w_mask_bit[3];
	assign bit_op_pv_d			= w_zero_d;
	assign bit_op_negative_d	= 1'b0;
endmodule
