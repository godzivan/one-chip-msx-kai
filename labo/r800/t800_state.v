//
//  t800_state.v
//   State
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

module t800_state (
	input			reset,
	input			clk,
	input			clk_en,

	output			mem_req,
	output			mem_write,
	input			mem_ready,
	output	[15:0]	mem_a,
	output	[ 7:0]	mem_d,
	input	[ 7:0]	mem_q
);
	reg		[ 4:0]	ff_state;

	local parameter	c_fetch0	= 5'd0;
	local parameter	c_memwr0	= 5'd1;
	local parameter	c_memrd0	= 5'd2;
	local parameter	c_iowr0		= 5'd3;
	local parameter	c_iord0		= 5'd4;
	local parameter	c_memwr1	= 5'd5;
	local parameter	c_memwr2	= 5'd6;
	local parameter	c_memrd1	= 5'd7;
	local parameter	c_memwr3	= 5'd8;
	local parameter	c_fetch1	= 5'd9;
	local parameter	c_fetch2	= 5'd10;
	local parameter	c_fetch3	= 5'd11;
	local parameter	c_iowr1		= 5'd12;
	local parameter	c_fetch4	= 5'd13;
	local parameter	c_iord1		= 5'd14;
	local parameter	c_fetch5	= 5'd15;
	local parameter	c_fetch6	= 5'd16;
	local parameter	c_fetch7	= 5'd17;
	local parameter	c_fetch8	= 5'd18;
	local parameter	c_branch0	= 5'd19;
	local parameter	c_fetch9	= 5'd20;
	local parameter	c_fetch10	= 5'd21;
	local parameter	c_memwr4	= 5'd22;
	local parameter	c_memwr5	= 5'd23;
	local parameter	c_memwr6	= 5'd24;
	local parameter	c_memwr7	= 5'd25;

	always @( posedge reset or posedge clk ) begin
		if( reset ) begin
			ff_state		<= 5'd0;
			ff_decode_en	<= 1'b0;
		end
		else if( clk_en ) begin
			case( ff_state )
			c_fetch0:
				begin
					if( mem_ready ) begin
						ff_decode_en <= 1'b1;
					end
					else begin
						ff_decode_en <= 1'b1;
					end
				end
			c_fetch1, c_fetch2, c_fetch3
			c_fetch4:
			c_fetch5:
			c_fetch6:
			c_fetch7:
			c_fetch8:
			c_fetch9:
			c_fetch10:

			c_memwr0:
			c_memwr1:
			c_memwr2:
			c_memwr3:
			c_memwr4:
			c_memwr5:
			c_memwr6:
			c_memwr7:

			c_memrd0:
			c_memrd1:

			c_iowr0:
			c_iowr1:
			c_iord0:
			c_iord1:

			c_branch0:
			endcase
		end
		else begin
			//	hold
		end
	end
endmodule
