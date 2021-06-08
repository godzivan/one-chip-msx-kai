; -----------------------------------------------------------------------------
;	VDP Register Test Program
; =============================================================================
;	2021/6/8	t.hara
; -----------------------------------------------------------------------------

VDP_IO_PORT0	= 0x98
VDP_IO_PORT1	= 0x99
VDP_IO_PORT2	= 0x9A
VDP_IO_PORT3	= 0x9B

RG0SAV			= 0xF3DF

		; BSAVE header
		db		0xFE
		dw		start_address
		dw		end_address
		dw		start_address

		; Program body
		org		0xC000

start_address::
; =====================================================================
;	N = 300, 299, ... , 1 �ŌJ��Ԃ�
; =====================================================================
		scope	main_loop
main_loop::
		ld		de, 300
		ld		hl, result

		di							; ���荞�݋֎~

		ld		a, 128				; R#19 = 128
		out		[VDP_IO_PORT1], a
		ld		a, 0x80 | 19
		out		[VDP_IO_PORT1], a

		; V-Blanking �𔲂���̂�҂�
		ld		a, 2				; R#15 = 2
		out		[VDP_IO_PORT1], a
		ld		a, 0x80 | 15
		out		[VDP_IO_PORT1], a
wait_non_v_blank:
		in		a, [VDP_IO_PORT1]
		and		a, 0x40
		jp		nz, wait_non_v_blank

		; V-Blanking �ɓ���̂�҂�
wait_v_blank:
		in		a, [VDP_IO_PORT1]
		and		a, 0x40
		jp		z, wait_v_blank

		; S#0, S#1 ��ǂ�ŃX�e�[�^�X�N���A
		ld		a, 0				; R#15 = 0
		out		[VDP_IO_PORT1], a
		ld		a, 0x80 | 15
		out		[VDP_IO_PORT1], a
		in		a, [VDP_IO_PORT1]

		ld		a, 1				; R#15 = 1
		out		[VDP_IO_PORT1], a
		ld		a, 0x80 | 15
		out		[VDP_IO_PORT1], a
		in		a, [VDP_IO_PORT1]

count_h_blank_loop:
		ld		a, 2				; R#15 = 2
		out		[VDP_IO_PORT1], a
		ld		a, 0x80 | 15
		out		[VDP_IO_PORT1], a

		; H-Blank ������҂�
wait_non_h_blank:
		in		a, [VDP_IO_PORT1]
		and		a, 0x20
		jp		nz, wait_non_h_blank

		; H-Blanking �ɓ���̂�҂�
wait_h_blank:
		in		a, [VDP_IO_PORT1]
		and		a, 0x20
		jp		z, wait_h_blank

		; S#1 ��ǂ�
		ld		a, 1				; R#15 = 1
		out		[VDP_IO_PORT1], a
		ld		a, 0x80 | 15
		out		[VDP_IO_PORT1], a
		in		a, [VDP_IO_PORT1]

		; ���ʂ� result �Ɋi�[
		ld		[hl], a
		inc		hl

		dec		de
		ld		a, e
		or		a, d
		jp		nz, count_h_blank_loop

		; S#0 ��ǂ�ŃX�e�[�^�X�N���A
		ld		a, 0				; R#15 = 0
		out		[VDP_IO_PORT1], a
		ld		a, 0x80 | 15
		out		[VDP_IO_PORT1], a
		in		a, [VDP_IO_PORT1]

		ei							; ���荞�݋���
		ret
		endscope

; =====================================================================
;	���ʊi�[��
; =====================================================================
result::
		space	300
end_address::
