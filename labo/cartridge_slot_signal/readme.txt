�J�[�g���b�W�X���b�g�� 20MHz �� 5MSa �T���v�����O�����g�`�f�[�^�ł��B

�g�`�f�[�^�͉��L�̃c�[���ŉ{���ł��܂��B
http://www.qdkingst.com/en
	KingstVIS

----------------------------------------------------------------
slot_signal_A1GT_R800_RDWRTEST.kvdat
	A1GT R800���[�h

slot_signal_A1GT_Z80_RDWRTEST.kvdat
	A1GT Z80���[�h

slot_signal_SX-2_3.58MHz_RDWRTEST.kvdat
	SX-2 3.58MHz���[�h, OCM-PLD 3.9 beta (�X���b�g�M���� OCM-PLD 3.8.1����)

slot_signal_SX-2_8.06MHz_RDWRTEST.kvdat
	SX-2 8.06MHz���[�h, OCM-PLD 3.9 beta (�X���b�g�M���� OCM-PLD 3.8.1����)

slot_signal_SX-2_3.58MHz_RDWRTEST2.kvdat
	SX-2 3.58MHz���[�h, OCM-PLD 3.9 beta2 (�X���b�g�M���͉��L�̉��C����������)
	
		---- Modified by t.hara in 4th/Aug/2021
		--    BusDir_o    <=  '0' when( pSltRd_n = '1' )else
		--                    '1' when( pSltIorq_n = '0' and BusDir    = '1' )else
		--                    '1' when( pSltMerq_n = '0' and PriSltNum = "00" )else
		--                    '1' when( pSltMerq_n = '0' and PriSltNum = "11" )else
		--                    '1' when( pSltMerq_n = '0' and PriSltNum = "01" and Scc1Type /= "00" )else
		--                    '1' when( pSltMerq_n = '0' and PriSltNum = "10" and Slot2Mode /= "00" )else
		--                    '0';

		---- Modified by t.hara in 4th/Aug/2021
		    BusDir_o    <=  '0' when( pSltRd_n = '1' )else
		                    '1' when( pSltIorq_n = '0' and BusDir    = '1' )else
		                    '1' when( pSltMerq_n = '0' )else
		                    '0';
