; ==============================================================================
;	IPL-ROM for OCM-PLD v3.4 or later
;	SD-Card Driver
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
;   2021/Aug/20th  t.hara  Overall revision.
; ==============================================================================

; --------------------------------------------------------------------
;	SD Card Command
; --------------------------------------------------------------------
SDCMD_GO_IDLE_STATE				:= 0
SDCMD_SEND_IO_COND				:= 1
SDCMD_SEND_IF_COND				:= 8
SDCMD_SEND_CSD					:= 9
SDCMD_SEND_CID					:= 10
SDCMD_SEND_STATUS				:= 13
SDCMD_SEND_BKICKLEN				:= 16
SDCMD_READ_SINGLE_BLK			:= 17
SDCMD_WRITE_BLOCK				:= 24
SDCMD_PROGRAM_CSD				:= 27
SDCMD_SET_WRITE_PROT			:= 28
SDCMD_CLR_WRITE_PROT			:= 29
SDCMD_SEND_WRITE_PROT			:= 30
SDCMD_TAG_SECT_START			:= 32
SDCMD_TAG_SECT_END				:= 33
SDCMD_UNTAG_SECTOR				:= 34
SDCMD_TAG_ERASE_G_SEL			:= 35
SDCMD_TAG_ERASE_G_END			:= 36
SDCMD_UNTAG_ERASE_GRP			:= 37
SDCMD_ERASE						:= 38
SDCMD_CRC_ON_OFF				:= 39
SDCMD_LOCK_UNLOCK				:= 42
SDCMD_APP_CMD					:= 55
SDCMD_READ_OCR					:= 58

SDACMD_SET_WR_BLOCK_ERASE_COUNT	:= 23
SDACMD_APP_SEND_OP_COND			:= 41

; --------------------------------------------------------------------
;	SD card type
; --------------------------------------------------------------------
TYPE_UNKNOWN					:= 0
TYPE_MMC						:= 1
TYPE_SDSD						:= 2
TYPE_SDHC						:= 3

; --------------------------------------------------------------------
;	Master Boot Record Offset
; --------------------------------------------------------------------
mbr_boot_strap_loader			:= 0
mbr_1st_partition				:= 0x01BE
mbr_2nd_partition				:= 0x01CE
mbr_3rd_partition				:= 0x01DE
mbr_4th_partition				:= 0x01EE
mbr_boot_signature				:= 0x01FE

mbr_partition_boot_flag			:= 0		; 1byte
mbr_partition_chs_begin_sector	:= 1		; 3bytes
mbr_partition_type				:= 4		; 1byte
mbr_partition_chs_end_sector	:= 5		; 3bytes
mbr_partition_lba_begin_sector	:= 8		; 4bytes
mbr_partition_total_sectors		:= 12		; 4bytes

; --------------------------------------------------------------------
;	Partition Boot Record Offset
; --------------------------------------------------------------------
pbr_jump_instruction			:= 0x000	; 3bytes
pbr_oem_name					:= 0x003	; 8bytes
pbr_bios_parameter_block		:= 0x00B	; 25bytes
	pbr_bytes_per_sector		:= 0x00B	;   2bytes
	pbr_sectors_per_cluster		:= 0x00D	;   1byte
	pbr_reserved_sectors		:= 0x00E	;   2bytes
	pbr_num_of_fat				:= 0x010	;   1byte
	pbr_root_entries			:= 0x011	;   2bytes
	pbr_small_sector			:= 0x013	;   2bytes
	pbr_media_type				:= 0x015	;   1byte
	pbr_sectors_per_fat			:= 0x016	;   2bytes
	pbr_sectors_per_track		:= 0x018	;   2bytes
	pbr_number_of_heads			:= 0x01A	;   2bytes
pbr_extend_bios_parameter_block	:= 0x01C	; 26bytes
pbr_bootstrap_code				:= 0x03E	; 448bytes
pbr_signature					:= 0x1FE	; 2bytes

card_type						:= 0xFFCF	; 1byte: 2: MMC/SDHC, 3: SDHC

; --------------------------------------------------------------------
;	SEND CMD0
;	input)
;		hl .... megasd_sd_register
; --------------------------------------------------------------------
		scope	send_cmd0
send_cmd0::
		ld		bc, (16 << 8) | 0
		ld		a, [hl]								; dummy read
		call	wait_busy
		ld		[hl], 0x40 | SDCMD_GO_IDLE_STATE	; CMD0 command
		call	wait_busy
		ld		[hl], c								; CMD0 parameter 1st
		call	wait_busy
		ld		[hl], c								; CMD0 parameter 2nd
		call	wait_busy
		ld		[hl], c								; CMD0 parameter 3rd
		call	wait_busy
		ld		[hl], c								; CMD0 parameter 4th
		call	wait_busy
		ld		[hl], 0x95							; CMD0 CRC
		call	wait_busy
		ld		a, [hl]								; dummy read
		call	wait_busy
get_r1_wait:
		ld		a, [hl]								; read R1
		call	wait_busy
		ld		a, [megasd_last_data_register]
		cp		a, 0xFF
		ccf
		ret		nc
		djnz	get_r1_wait
		ret

wait_busy::
		ld		a, [megasd_status_register]
		rlca
		jr		c, wait_busy
		ret
		endscope

; --------------------------------------------------------------------
;	SD/SDHC/MMC command
;	input)
; --------------------------------------------------------------------
		scope	set_sd_command
set_sd_command::
		ld		a, [card_type]		;	Card type
		cp		a, TYPE_SDHC
		jr		c, set_sd_mmc

		;	for SDHC
set_sdhc:
		ld		a, [hl]
		ld		[hl], b				;	set command code
		ld		[hl], 0
		ld		[hl], c
		ld		[hl], d
		ld		[hl], e
		jr		set_src95

		;	for SD/MMC
set_sd_mmc:
		sla		e					;	convert 'number of sector' to 'number of byte'
		rl		d					;	cde = cde * 2
		rl		c
send_command::
		ld		a, [hl]
		ld		[hl], b				;	set command code
		ld		[hl], c
		ld		[hl], d
		ld		[hl], e
		ld		[hl], 0

set_src95:
		ld		[hl], 0x95			;	CRC

		ld		b, 16				;	retry count = 16
receive_response::
		ld		a, [hl]
wait_command_accept:
		ld		a, [hl]
		cp		a, 0x0FF
		ccf
		ret		nc					;	no error
		djnz	wait_command_accept	;	no flag change
		ret							;	Cy = 1
		endscope

; --------------------------------------------------------------------
;	Initialize SD card
;	input)
;		none
;	output)
;		HL .... mega_sd_register
;		Cy .... 1: error, 0: others
;		Zf .... 0: error, 0: others
; --------------------------------------------------------------------
		scope	sd_initialize
sd_initialize::
		;	Set low speed mode
		ld		a, 0x80				; Low speed and data enable mode
		ld		[megasd_mode_register], a

		;	"/CS=1, DI=1" is input for a period of 74 clocks or more.
		;	"/CS = 1, DI = 1 �̏�Ԃ� 74clock �ȏ�N���b�N�𓊓�����.
		ld		hl, megasd_sd_register
		ld		b, 10
wait_cs:
		ld		a, [megasd_sd_register | (1 << 12)]		;	/CS = 1 (bit12)
		call	wait_busy
		djnz	wait_cs

		;	send SDCMD_GO_IDLE_STATE (CMD0)
		call	send_cmd0
		ret		c					;	error

		;	Check R1 Response
		and		a, 0x0F3
		cp		a, 0x01				;	bit0 - in idle state?
		ret		nz					;	error (SD is not idle state when bit0 is zero.)

		; Set high speed mode
		xor		a, a				; High speed and data enable mode
		ld		[megasd_mode_register], a
		endscope

; --------------------------------------------------------------------
;	Send initialize command and detect card type.
;	input)
;		DE = 0
;	output)
;		Cy ............ 1: error
;		Others ........ success
;		[card_type] ... card type code
; --------------------------------------------------------------------
		scope	send_init_command
send_init_command::
		xor		a, a
		ld		[card_type], a
		; ---------------------------------------------------------------------
		; CMD8 (Voltage Check Command)
		;   bit 47 46 45-40 39-22 21   20   19-16 15-08   07-01 00
		;       S  D  Index Resv. PCIe PCIe VHS   Pattern CRC7  E
		;
		; Response (Format R7)
		;   bit 39-32 31-28 27-12 11-08 07-00
		;       R1    Ver.  Resv. Vacc. pattern
		;
		;  Vacc. ... Voltage accepted
		;            0000b  Not defined
		;            0001b  2.7 ... 3.6V
		;            0010b  Reserved for Low Voltage Range
		;            0100b  Reserved
		;            1000b  Reserved
		;            Others Not defined
		; ---------------------------------------------------------------------
		ld		a, [hl]
		ld		[hl], 0x40 | SDCMD_SEND_IF_COND
		ld		[hl], 0
		ld		[hl], 0
		ld		[hl], 0x01					; VHS = 2.7 ... 3.6V
		ld		[hl], 0xAA					; Pattern
		ld		[hl], 0x87					; CRC7, E
		ld		b, 16						; retry count
		call	receive_response
		ret		c							; error
		cp		a, 1
		jr		nz, check_sd1				; Not SD version 2, go to check SD version 1.

		ld		a, [hl]						; R7 bit31-24
		ld		a, [hl]						; R7 bit23-16
		ld		a, [hl]						; R7 bit15-08
		and		a, 0x0F						; A = R7 bit11-08 = Voltage accepted
		cp		a, 1						; 1 = 2.7 ... 3.6V
		ld		a, [hl]						; R7 bit07-00
		ret		nz							; error when mismatch
		cp		a, 0xAA						; Check pattern
		ret		nz							; error when mismatch

		; Try initialize SDHC card.
		;
		; ---------------------------------------------------------------------
		; ACMD41
		;   bit 47 46 45-40  39   38  37 36  35   34-33 32   31-16 15-08 07-01 00
		;       S  D  Index  Busy HCS FB XPC HO2T Rsv.  S18R OCR   Resv. CRC7  E
		;       0  1  101001 0    X   0  X   X    00    X    XX    00    XX    1
		;
		;  { HCS, HO2T }
		;    00b : SDSC Supported Host
		;    10b : SDHC/SDXC Supported Host
		;    11b :   Over 2TB Supported Host
		;    01b : N/A
		;
		; Send SDACMD_APP_SEND_OP_COND(ACMD41). Initialize connection for SDHC.
		; SD�J�[�h�ɑ΂��� SDACMD_APP_SEND_OP_COND(ACMD41), { HCS, HO2T } = 10b �Őڑ����������w���B
retry_acmd41_v2:
		ld		bc, ((0x40 | SDCMD_APP_CMD) << 8) | 0x00
		call	send_command
		ret		c							;	error
		cp		a, 1
		ret		nz							;	error

		ld		bc, ((0x40 | SDACMD_APP_SEND_OP_COND) << 8) | 0x40
		call	send_command
		ret		c							;	error
		and		a, 1
		jr		nz, retry_acmd41_v2

		; ---------------------------------------------------------------------
		; CMD58
		;   bit 47 46 45-40  39  38-35 34  33-17 16-08 07-01 00
		;       S  D  Index  MIO FNO   BUS ADDR  BUC   CRC7  E
		;       0  1  111010 X   XX    X   17bit XX    XX    1
		;
		;   MIO (Memory or I/O)
		;     0: Memory Extension
		;     1: I/O Extension
		;
		;  FNO (Function No.)
		;
		;  BUS (Block Unit Select)
		;     0: 512 Bytes
		;     1: 32768 Bytes
		;
		;  BUC (Block Unit Count)
		;     0: 1 unit
		;     1: 2 units
		;       :
		;
		;  After initialization is completed, the host should get CCS information in the response of CMD58.
		;  CCS is valid when the card accepted CMD8 and after the completion of initialization.
		;  CCS=0 means that the card is SDSD. CCS=1 means that the card is SDHC or SDXC.
		;
		; Send SDCMD_READ_OCR(CMD58). And receive OCR datas.
		; SD�J�[�h�ɑ΂��� SDCMD_READ_OCR(CMD58) �𑗐M���� OCR�f�[�^��ǂݎ��B
		ld		bc, ((0x40 | SDCMD_READ_OCR) << 8) | 0x00		; READ_OCR
		call	send_command				;	Send command and receive R1
		jr		c, check_mmc				;	go to check MMC card, when error

		ld		a, [hl]						;	receive OCR 1st (bit31-24)
		cp		a, [hl]						;	receive OCR 2nd (bit23-16)
		cp		a, [hl]						;	receive OCR 3rd (bit15-08)
		cp		a, [hl]						;	receive OCR 4th (bit07-00)
		bit		6, a						;	check CCS bit (bit6 on OCR 1st)
		ld		a, TYPE_SDSD
		jr		z, is_byte_access
		inc		a							;	TYPE_SDHC
is_byte_access:
		ld		[card_type], a
		xor		a, a
		ret									;	success (Cy = 0, Z = 1)

check_sd1:
		; Send SDACMD_APP_SEND_OP_COND(ACMD41). Initialize connection for SDHC.
		; SD�J�[�h�ɑ΂��� SDACMD_APP_SEND_OP_COND(ACMD41), { HCS, HO2T } = 00b �Őڑ����������w���B
retry_acmd41_v1:
		ld		bc, ((0x40 | SDCMD_APP_CMD) << 8) | 0x00
		call	send_command
		jr		c, check_mmc				;	go to check MMC, when error
		cp		a, 1
		jr		nz, check_mmc				;	go to check MMC, when error

		ld		bc, ((0x40 | SDACMD_APP_SEND_OP_COND) << 8) | 0x00
		call	send_command
		jr		c, check_mmc				;	go to check MMC, when error
		and		a, 1
		jr		nz, retry_acmd41_v1
		ld		a, TYPE_SDSD
		ld		[card_type], a
		ret									;	success (Cy = 0, Z = 1)

check_mmc:
		; Send SDCMD_SEND_IO_COND(CMD1). Initialize connection for MMC.
		; SD�J�[�h�ɑ΂��� SDCMD_SEND_IO_COND(CMD1) �Őڑ����������w���B
retry_cmd1:
		ld		bc, ((0x40 | SDCMD_SEND_IO_COND) << 8) | 0x00
		call	send_command				;	Send command and receive R1
		ret		c							; if Cy = 1 then error
		bit		2, a
		ret		nz							; if bit2 on R1 then error
		and		a, 1
		jr		nz, retry_cmd1
		ld		a, TYPE_MMC
		ld		[card_type], a
		ret
		endscope

; --------------------------------------------------------------------
;	Read sectors from MMC/SD/SDHC card
;	input)
;		B   = number of sectors
;		HL  = read buffer
;		CDE = sector number
; --------------------------------------------------------------------
		scope	sd_read_sector
retry_init:
		call	sd_initialize
		pop		bc
		pop		de
		pop		hl
		ret		c					;	initialize error

sd_read_sector::
		push	hl
		push	de
		push	bc

		ld		b, 0x40 + SDCMD_READ_SINGLE_BLK
		ld		hl, megasd_sd_register
		call	set_sd_command
		jr		c, retry_init

		pop		bc
		pop		de
		pop		hl
		or		a, a
		scf
		ret		nz					;	error

		push	de
		push	bc
		ex		de, hl
		ld		bc, 0x200			;	512bytes
		ld		hl, megasd_sd_register

read_wait:
		ld		a, [hl]
		cp		a, 0x0FE
		jr		nz, read_wait

		ldir						;	read sector
		ex		de, hl
		ld		a, [de]
		pop		bc
		ld		a, [de]
		pop		de
		inc		de
		ld		a, d
		or		a, e

		jr		nz, skip

		inc		c
skip:
		djnz	sd_read_sector		;	next sector

		ret
		endscope

; --------------------------------------------------------------------
;	test MBR (Search partition)
; --------------------------------------------------------------------
		scope	search_active_partition_on_mbr
search_active_partition_on_mbr::
		ld		b, 4															; number of partition entry
		ld		hl, buffer + mbr_1st_partition + mbr_partition_lba_begin_sector	; offset in sector
test_partition_loop:
		ld		e, [hl]
		inc		hl
		ld		d, [hl]
		inc		hl
		ld		c, [hl]
		ld		a, c
		or		a, d
		or		a, e
		ret		nz					; if CDE != 0 then found partition

		; failed, and test next partition.
		ld		de, 16 - 2
		add		hl, de
		djnz	test_partition_loop

		; Not found a partition.
		scf							; CY = 1, error
		ret
		endscope
