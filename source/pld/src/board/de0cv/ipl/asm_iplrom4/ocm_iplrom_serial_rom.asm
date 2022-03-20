; ==============================================================================
;	IPL-ROM for OCM-PLD v3.9.1 or later
;	EPCS Serial ROM Driver
; ------------------------------------------------------------------------------
; Copyright (c) 2021 Takayuki Hara
; All rights reserved.
;
; Redistribution and use of this source code or any derivative works, are
; permitted provided that the following conditions are met:
;
; 1. Redistributions of source code must retain the above copyright notice,
;	 this list of conditions and the following disclaimer.
; 2. Redistributions in binary form must reproduce the above copyright
;	 notice, this list of conditions and the following disclaimer in the
;	 documentation and/or other materials provided with the distribution.
; 3. Redistributions may not be sold, nor may they be used in a commercial
;	 product or activity without specific prior written permission.
;
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
; "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
; TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
; PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
; CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
; EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
; PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
; WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
; OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
; ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
; ------------------------------------------------------------------------------
; History:
;   2021/Aug/09th  t.hara  Overall revision.
; ==============================================================================

; --------------------------------------------------------------------
;	EPCS Operation Codes
; --------------------------------------------------------------------
EPCS_WRITE_ENABLE		:= 0b0000_0110
EPCS_WRITE_DISABLE		:= 0b0000_0100
EPCS_READ_STATUS		:= 0b0000_0101
EPCS_READ_BYTES			:= 0b0000_0011
EPCS_READ_SILICON_ID	:= 0b1010_1011			; require EPCS1/4/16/64
EPCS_FAST_READ			:= 0b0000_1011
EPCS_WRITE_STATUS		:= 0b0000_0001
EPCS_WRITE_BYTES		:= 0b0000_0010
EPCS_ERASE_BULK			:= 0b1100_0111
EPCS_ERASE_SECTOR		:= 0b1101_1000
EPCS_READ_DEVICE_ID		:= 0b1001_1111			; require EPCS128 or later

; ------------------------------------------------------------------------------
;	read_sector_from_epcs
;	input:
;		DE .... target sector number
;		HL .... destination address
;		B ..... number of sectors (1-127)
;	output:
;		Cy .... 0: success, 1: error
;		DE .... next sector number
;	comment:
;		-
; ------------------------------------------------------------------------------
			scope		read_sector_from_epcs
read_sector_from_epcs::
			push		de								; target sector number

			ex			de, hl							; de = de * 2
			add			hl, hl
			ex			de, hl
			xor			a, a							; dea = byte address, Cy = 0
			ld			c, a							; C = 0

			push		bc								; save number of sectors
			push		hl
			ld			hl, megasd_sd_register|(0<<12)	; /CS=0 (address bit12)
			ld			[hl], EPCS_READ_BYTES			; command byte
			nop
			ld			[hl], d							; byte address b23-b16
			nop
			ld			[hl], e							; byte address b15-b8
			nop
			ld			[hl], a							; byte address b7-b0
			nop
			ld			a, [hl]
			pop			de								; de = adress of buffer

			sla			b								; b = number of half sectors
read_all:
			ld			a, [hl]							; �� DE0CV �ł� LDIR �œǂނƎ�肱�ڂ��P�[�X������
			ld			[de], a
			inc			de
			dec			bc
			ld			a, c
			or			a, b
			jr			nz, read_all

			ld			a, [megasd_sd_register|(1<<12)]	; /CS=1 (address bit12)

			pop			hl								; H = number of sectors
			pop			de								; target sector number
			ld			l, h
			ld			h, 0
			add			hl, de							; Cy = 0
			ex			de, hl							; next sector (512 byte)
			ret
			endscope

