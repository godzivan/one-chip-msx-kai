//
//  t800_shift8.v
//   Shifter unit for 8bit
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

module t800_shift8 (
	input	[7:0]	opecode,
	input	[7:0]	operand_q,
	input			cy_q,
	input			prefix_cb,
	input			prefix_ed,
	output	[7:0]	shift8_result_d,
	output			shift8_result_d_en,
	output			shift8_sign_d,
	output			shift8_sign_d_en,
	output			shift8_zero_d,
	output			shift8_zero_d_en,
	output			shift8_yf_d,
	output			shift8_yf_d_en,
	output			shift8_half_cy_d,
	output			shift8_half_cy_d_en,
	output			shift8_xf_d,
	output			shift8_xf_d_en,
	output			shift8_pv_d,
	output			shift8_pv_d_en,
	output			shift8_negative_d,
	output			shift8_negative_d_en,
	output			shift8_cy_d,
	output			shift8_cy_d_en
);
	wire			w_prefix;
	wire	[9:0]	w_result;

	assign w_prefix				= prefix_cb & ~prefix_ed;

	function [9:0] mux;
		input	[7:0]	opecode;
		input	[8:0]	operand;

		casex( opecode )
		8'b00000xxx:
			mux = { 1'b1, operand[7:0], operand[7] };
		8'b00001xxx:
			mux = { 1'b1, operand[0], operand[0], operand[7:1] };
		8'b00010xxx:
			mux = { 1'b1, operand[7:0], operand[8] };
		8'b00011xxx:
			mux = { 1'b1, operand[0], operand[8], operand[7:1] };
		8'b00100xxx:
			mux = { 1'b1, operand[7:0], 1'b0 };
		8'b00110xxx:
			mux = { 1'b1, operand[7:0], 1'b1 };
		8'b00101xxx:
			mux = { 1'b1, operand[0], operand[7], operand[7:1] };
		8'b00111xxx:
			mux = { 1'b1, operand[0], 1'b0, operand[7:1] };
		default:
			mux = 10'd0;
		endcase
	endfunction

	assign w_result				= mux( opecode, operand_q );

	assign shift8_result_d		= w_result[7:0];
	assign shift8_result_d_en	= w_prefix & w_result[9];
	assign shift8_negative_d	= 1'b0;
	assign shift8_negative_d_en	= w_prefix & w_result[9];
	assign shift8_half_cy_d		= 1'b0;
	assign shift8_half_cy_d_en	= w_prefix & w_result[9];
	assign shift8_cy_d			= w_result[8];
	assign shift8_cy_d_en		= w_prefix & w_result[9];
	assign shift8_zero_d		= (w_result[7:0] == 8'd0) ? 1'b1: 1'b0;
	assign shift8_zero_d_en		= w_prefix & w_result[9];
	assign shift8_sign_d		= w_prefix & w_result[9] & w_result[7];
	assign shift8_sign_d_en		= w_prefix & w_result[9];
	assign shift8_yf_d			= w_prefix & w_result[9] & w_result[5];
	assign shift8_yf_d_en		= w_prefix & w_result[9];
	assign shift8_xf_d			= w_prefix & w_result[9] & w_result[3];
	assign shift8_xf_d_en		= w_prefix & w_result[9];
	assign shift8_pv_d			= w_prefix & w_result[9] & ~(w_result[7] ^ w_result[6] ^ w_result[5] ^ w_result[4] ^ w_result[3] ^ w_result[2] ^ w_result[1] ^ w_result[0]);
	assign shift8_pv_d_en		= w_prefix & w_result[9];
endmodule
