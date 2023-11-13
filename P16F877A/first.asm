;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	Project:		Interfacing PICs 
;	Source File Name:	VINTEST.ASM		
;	Devised by:		MPB		
;	Date:			19-12-05
;	Status:			Final version
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; 	Demonstrates simple analogue input
;	using an external reference voltage of 2.56V
;	The 8-bit result is converted to BCD for display
;	as a voltage using the standard LCD routines.
;	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	PROCESSOR 16F877A
;	Clock = XT 4MHz, standard fuse settings
	__CONFIG 0x3731

;	LABEL EQUATES	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	#INCLUDE "P16F877A.INC" 	; standard labels 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	
	cblock 0x20
d1
d2
d3
d11	;tenthousandth of first num
d12	;thousandth of first num
d13	; and so on
d14
d15
d21;tenthousandth of second num
d22
d23
d24
d25
counter
d31
d32
d33
d34
d35
d36
digit_pos
op_num
clkNum
keepVar
num1
num2
num1L
num1M
num2L
num2M
dgt
x2
x
qH
qL
remH
remL
temp
result
resultH
resultL
	endc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; PROGRAM BEGINS ;;;;;;;

	ORG	0		; Default start address 
	GOTO start 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Inerupt service routine
ISR
	ORG 004
	BCF INTCON,7 ;clear GIE to deny other interupt
	BCF	Select,RS	; set display command mode
	;check if we at 1st tenthousandth
 	MOVLW 1
	SUBWF digit_pos,W
	BTFSC STATUS,2 ; check if digit_pos is 5
	GOTO  tenthous1
	;check if we at 1st tens 	
	MOVLW 2
	SUBWF digit_pos,W
	BTFSC STATUS,2 ; check if digit_pos is 4
	GOTO  thous1
	;check if we at 1st ones
	MOVLW 3
	SUBWF digit_pos,W
	BTFSC STATUS,2 ; check if digit_pos is 3
	GOTO  huns1 
	;check if we at operation
	MOVLW 4
	SUBWF digit_pos,W
	BTFSC STATUS,2 ; check if digit_pos is 2
	GOTO  tens1
	MOVLW 5
	SUBWF digit_pos,W
	BTFSC STATUS,2 ; check if digit_pos is 1
	GOTO  ones1
;--------operation pos
	;check if we at operation pos	
	MOVLW 6
	SUBWF digit_pos,W
	BTFSC STATUS,2 ; check if digit_pos is 4
	GOTO  operation
;--------second number
	MOVLW 7
	SUBWF digit_pos,W
	BTFSC STATUS,2 ; check if digit_pos is 5 of second num
	GOTO  tenthous2
	;check if we at 1st tens 	
	MOVLW 8
	SUBWF digit_pos,W
	BTFSC STATUS,2 ; check if digit_pos is 4
	GOTO  thous2
	;check if we at 1st ones
	MOVLW 9
	SUBWF digit_pos,W
	BTFSC STATUS,2 ; check if digit_pos is 3
	GOTO  huns2
	;check if we at operation
	MOVLW 10
	SUBWF digit_pos,W
	BTFSC STATUS,2 ; check if digit_pos is 2
	GOTO  tens2
	MOVLW 11
	SUBWF digit_pos,W
	BTFSC STATUS,2 ; check if digit_pos is 1
	GOTO  ones2 
	GOTO cont
;;;;;;;;;;;;;;;;;;;;;;;;;;;;for keep
	MOVLW 1
	SUBWF keepVar,W
	BTFSC STATUS,2 ; check if digit_pos is 1
	GOTO  keepfun
	GOTO cont
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;tenthousandth part
	tenthous1
		MOVLW 0C0		; code to home cursor at first position
		CALL send	; output it to display
		BSF	Select,RS	; and restore data mode
		BTFSS INTCON,1  ; check if interrupt is from RB0 or Timer0 
		GOTO TM0_INT	; handle interrupt Timer 0
		; handle interrupt RB0
	RBO_INTR
		CLRF counter
		INCF d11, 1
		MOVLW 7
		SUBWF d11,W
		BTFSC STATUS,2 ; check if thousandth is more than 6
		GOTO zero_tenthous
		GOTO dis_RB0
	zero_tenthous
		CLRF d11
		GOTO dis_RB0
	TM0_INT
		INCF counter, 1
		MOVLW d'40' ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;=====================================================================================================
		SUBWF counter,W
		BTFSC STATUS,2 ;check if counter value is 
		GOTO dis_TM0
		GOTO cont
	dis_TM0
		;here timer is arrive 2 second
		CLRF counter
		INCF digit_pos,1
		;MOVF d11,w
		;MOVWF dgt
		;call MUL_BY_10000 
		;MOVF x2,w
		;ADDWF num1,f
		;CLRF x2
		GOTO dis_RB0
	dis_RB0
		MOVLW	030		; load ASCII offset
		ADDWF	d11,W
		CALL send
		
		GOTO cont
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;thousandth part
	thous1
		MOVLW 0C1		; code to home cursor
		CALL send		; output it to display
		BSF	Select,RS	; and restore data mode
		BTFSS INTCON,1 ; check if interrupt is from RB0 or Timer0 
		GOTO TM0_INT1 
	RBO_INTR1
		CLRF counter
		INCF d12, 1
		MOVLW 6
		SUBWF d11,W
		BTFSC STATUS,2
		GOTO rolling_thous_5_0
		MOVLW d'10'		
		SUBWF d12,W
		BTFSC STATUS,2 
		GOTO zero_thous
		GOTO dis_RB01
	rolling_thous_5_0
		MOVLW 6
		SUBWF d12,W		; here means that tenthousandth is 6
		BTFSC STATUS,2  ; then must check if thousandth is 5 
		GOTO zero_thous
		GOTO dis_RB01
	zero_thous
		CLRF d12
		GOTO dis_RB01
	TM0_INT1
		INCF counter, 1
		MOVLW d'40'
		SUBWF counter,W
		BTFSC STATUS,2 ;check if counter value is 20
		GOTO dis_TM01
		GOTO cont
	dis_TM01
		CLRF counter
		INCF digit_pos,1
		;MOVF d12,w
		;MOVWF dgt
		;call MUL_BY_1000
		;MOVF x2,w
		;ADDWF num1,f
		;CLRF x2
		GOTO dis_RB01
	dis_RB01
		MOVLW	030		; load ASCII offset
		ADDWF	d12,W
		CALL	send
		
		GOTO cont
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;hundredth part
	huns1
		MOVLW 0C2		; code to home cursor
		CALL send		; output it to display
		BSF	Select,RS	; and restore data mode
		BTFSS INTCON,1  ; check if interrupt is from RB0 or Timer0 
		GOTO TM0_INT2 
	RBO_INTR2
		CLRF counter
		INCF d13,1
		MOVLW 6
		SUBWF d11,W		;check if tenthousandth is 6
		BTFSC STATUS,2
		GOTO chk_thous	; if yes go check thousandth
	normal
		MOVLW d'10'
		SUBWF d13,W
		BTFSC STATUS,2 ; check if huns is between 0 and 9
		GOTO zero_huns
		GOTO dis_RB02
	chk_thous
		MOVLW 5
		SUBWF d12,W
		BTFSC STATUS,2
		GOTO rolling_huns_5_0
		GOTO normal
	rolling_huns_5_0 ;;reaches when tenthousandth=6 and thousandth=5
		MOVLW 6
		SUBWF d13,W
		BTFSC STATUS,2 ; check if huns is 5
		GOTO zero_huns
		GOTO dis_RB02
	zero_huns
		CLRF d13
		GOTO dis_RB02
	TM0_INT2
		INCF counter,1
		MOVLW d'40'
		SUBWF counter,W
		BTFSC STATUS,2 ;check if counter value is 20 ======================================================================================================
		GOTO dis_TM02
		GOTO cont
	dis_TM02
		CLRF counter
		INCF digit_pos,1
		;MOVF d13,w
		;MOVWF dgt
		;call MUL_BY_100
		;MOVF x2,w
		;ADDWF num1,f
		;CLRF x2
		GOTO dis_RB02
	dis_RB02
		
		MOVLW	030		; load ASCII offset
		ADDWF	d13,W
		CALL	send
		
		GOTO cont
	;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;tenth part
	tens1
		MOVLW	0C3		; code to home cursor
		CALL send		; output it to display
		BSF	Select,RS	; and restore data mode
		BTFSS INTCON,1  ; check if interrupt is from RB0 or Timer0 
		GOTO TM0_INT3
	RBO_INTR3
		CLRF counter
		INCF d14,1
		MOVLW 6			;check if tenthousandth=6
		SUBWF d11,W		
		BTFSC STATUS,2	
		GOTO chk_thous2	;if yes then check thousandth value
	normal_tens
		MOVLW d'10'
		SUBWF d14,W
		BTFSC STATUS,2 ; check if huns is between 0 and 9
		GOTO zero_tens
		GOTO dis_RB03
	chk_thous2																													
		MOVLW 5
		SUBWF d12,W
		BTFSC STATUS,2
		GOTO chk_huns
		GOTO normal_tens
	chk_huns
		MOVLW 5
		SUBWF d13,W
		BTFSC STATUS,2
		GOTO rolling_tens_3_0
		GOTO normal_tens
	rolling_tens_3_0 ;;reaches when tenthousandth=6 and thousandth=5
		MOVLW 4
		SUBWF d14,W
		BTFSC STATUS,2 ; check if tens is more than 3
		GOTO zero_tens
		GOTO dis_RB03
	zero_tens
		CLRF d14
		GOTO dis_RB03
	TM0_INT3
		INCF counter,1
		MOVLW d'40'
		SUBWF counter,W
		BTFSC STATUS,2 ;check if counter value is 20 ======================================================================================================
		GOTO dis_TM03
		GOTO cont
	dis_TM03
		CLRF counter
		INCF digit_pos,1
		;MOVF d14,w
		;MOVWF dgt
		;call MUL_BY_10
		;MOVF x2,w
		;ADDWF num1,f
		;CLRF x2
		GOTO dis_RB03
	dis_RB03
		MOVLW	030		; load ASCII offset
		ADDWF	d14,W
		CALL	send
		
		GOTO cont
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;ones part
	ones1
		MOVLW	0C4		; code to home cursor
		CALL send		; output it to display
		BSF	Select,RS	; and restore data mode
		BTFSS INTCON,1  ; check if interrupt is from RB0 or Timer0 
		GOTO TM0_INT4 
	RBO_INTR4
		CLRF counter
		INCF d15,1
		MOVLW 6			;check if tenthousandth=6
		SUBWF d11,W		
		BTFSC STATUS,2	
		GOTO chk_thous4	;if yes then check thousandth value
	normal_ones
		MOVLW d'10'
		SUBWF d15,W
		BTFSC STATUS,2 ; check if ones is between 0 and 9
		GOTO zero_ones
		GOTO dis_RB04
	chk_thous4																													
		MOVLW 5
		SUBWF d12,W
		BTFSC STATUS,2
		GOTO chk_huns4
		GOTO normal_ones
	chk_huns4
		MOVLW 5
		SUBWF d13,W
		BTFSC STATUS,2
		GOTO chk_tens
		GOTO normal_ones
	chk_tens
		MOVLW 3
		SUBWF d14,W
		BTFSC STATUS,2
		GOTO rolling_ones_5_0
		GOTO normal_ones
	rolling_ones_5_0 ;;reaches when tenthousandth=6 and thousandth=5 and hundredth=5 and tens=3
		MOVLW 6
		SUBWF d15,W
		BTFSC STATUS,2 ; check if tens is more than 3
		GOTO zero_ones
		GOTO dis_RB04
	zero_ones
		CLRF d15
		GOTO dis_RB04
	TM0_INT4
		INCF counter,1
		MOVLW d'40'
		SUBWF counter,W
		BTFSC STATUS,2 ;check if counter value is 20 ======================================================================================================
		GOTO dis_TM04
		GOTO cont
	dis_TM04
		CLRF counter
		INCF digit_pos,1
		;MOVF d15,w
		;ADDWF num1,f
		GOTO dis_RB04
	dis_RB04
		MOVLW	030		; load ASCII offset
		ADDWF	d15,W
		CALL	send
		
		goto cont
;;;;;;;;;;;;;;;;;;;;;;;;
;for operation
	operation
		MOVLW 0C5		; code to home cursor at first position
		CALL send	; output it to display
		BSF Select,RS	; and restore data mode
		BTFSS INTCON,1
		GOTO TM0_INTOP
	RB0_INTOP
		CLRF counter
		INCF op_num
		MOVLW 3
		SUBWF op_num,W
		BTFSS STATUS, 2
		GOTO dis_RB0OP
	zero_op
		CLRF op_num
	dis_RB0OP
		MOVLW 0
		SUBWF op_num,W
		BTFSC STATUS,2
		GOTO add_op
		MOVLW 1
		SUBWF op_num,W
		BTFSC STATUS,2
		GOTO div_op
		MOVLW 2
		SUBWF op_num,W
		BTFSC STATUS,2
		GOTO mod_op
	add_op
		MOVLW '+'
		CALL send
		GOTO cont
	div_op
		MOVLW '/'
		CALL send
		GOTO cont
	mod_op
		MOVLW '%'
		CALL send
		GOTO cont
	TM0_INTOP
		INCF counter,1
		MOVLW d'40'
		SUBWF counter,W
		BTFSC STATUS,2 ;check if counter value is 20 
		GOTO dis_OP
		GOTO cont
	dis_OP
		CLRF counter
		INCF digit_pos,1
		GOTO dis_RB0OP
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; for second number ;;;;;
;;;tenthousandth part
	;tenthousandth part
	tenthous2
		MOVLW	0C6  	; code to home cursor at first position
		CALL send	; output it to display
		BSF	Select,RS	; and restore data mode
		BTFSS INTCON,1  ; check if interrupt is from RB0 or Timer0 
		GOTO TM0_INT7	; handle interrupt Timer 0
; handle interrupt RB0
	RBO_INTR7
		CLRF counter
		INCF d21,1
		MOVLW 7
		SUBWF d21,W
		BTFSC STATUS,2 ; check if thousandth is more than 6
		GOTO zero_tenthous2
		GOTO dis_RB07
	zero_tenthous2
		CLRF d21
		GOTO dis_RB07
	TM0_INT7
		INCF counter,1
		MOVLW d'40' ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;=====================================================================================================
		SUBWF counter,W
		BTFSC STATUS,2 ;check if counter value is 20
		GOTO dis_TM07
		GOTO cont
	dis_TM07
		;here timer is arrive 2 second
		CLRF counter 
		INCF digit_pos,1
		;MOVF d21,w
		;MOVWF dgt
		;call MUL_BY_10000 
		;MOVF x2,w
		;ADDWF num2,f
		;CLRF x2
		GOTO dis_RB07
	dis_RB07
		MOVLW	030		; load ASCII offset
		ADDWF	d21,W
		CALL	send
		
		GOTO cont
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;thousandth part
	thous2
		MOVLW	0C7		; code to home cursor
		CALL	send		; output it to display
		BSF	Select,RS	; and restore data mode
		BTFSS INTCON,1 ; check if interrupt is from RB0 or Timer0 
		GOTO TM0_INT8 
	RBO_INTR8
		CLRF counter
		INCF d22,1
		MOVLW 6
		SUBWF d21,W
		BTFSC STATUS,2
		GOTO rolling_thous2_5_0
		MOVLW d'10'		
		SUBWF d22,W
		BTFSC STATUS,2 
		GOTO zero_thous2
		GOTO dis_RB08
	rolling_thous2_5_0
		MOVLW 6
		SUBWF d22,W		; here means that tenthousandth is 6
		BTFSC STATUS,2  ; then must check if thousandth is 5 
		GOTO zero_thous2
		GOTO dis_RB08
	zero_thous2
		CLRF d22
		GOTO dis_RB08
	TM0_INT8
		INCF counter,1
		MOVLW d'40'
		SUBWF counter,W
		BTFSC STATUS,2 ;check if counter value is 20
		GOTO dis_TM08
		GOTO cont
	dis_TM08
		CLRF counter
		INCF digit_pos,1
		;MOVF d22,w
		;MOVWF dgt
		;call MUL_BY_1000
		;MOVF x2,w
		;ADDWF num2,f
		;CLRF x2
		GOTO dis_RB08
	dis_RB08
		MOVLW	030		; load ASCII offset
		ADDWF	d22,W
		CALL	send
		
		GOTO cont
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;hundredth part
	huns2
		MOVLW	0C8		; code to home cursor
		CALL send		; output it to display
		BSF	Select,RS	; and restore data mode
		BTFSS INTCON,1  ; check if interrupt is from RB0 or Timer0 
		GOTO TM0_INT_huns2 
	RBO_INTR_huns2
		CLRF counter
		INCF d23,1
		MOVLW 6
		SUBWF d21,W		;check if tenthousandth is 6
		BTFSC STATUS,2
		GOTO chk_thous_huns2	; if yes go check thousandth
	normal_huns2
		MOVLW d'10'
		SUBWF d23,W
		BTFSC STATUS,2 ; check if huns is between 0 and 9
		GOTO zero_huns2
		GOTO dis_RB0_huns2
	chk_thous_huns2
		MOVLW 5
		SUBWF d22,W
		BTFSC STATUS,2
		GOTO rolling_huns2_5_0
		GOTO normal_huns2
	rolling_huns2_5_0 ;;reaches when tenthousandth=6 and thousandth=5
		MOVLW 6
		SUBWF d23,W
		BTFSC STATUS,2 ; check if huns is 5
		GOTO zero_huns2
		GOTO dis_RB0_huns2
	zero_huns2
		CLRF d23
		GOTO dis_RB0_huns2
	TM0_INT_huns2
		INCF counter,1
		MOVLW d'40'
		SUBWF counter,W
		BTFSC STATUS,2 ;check if counter value is 20 ======================================================================================================
		GOTO dis_TM0_huns2
		GOTO cont
	dis_TM0_huns2
		CLRF counter
		INCF digit_pos,1
		;MOVF d23,w
		;MOVWF dgt
		;call MUL_BY_100
		;MOVF x2,w
		;ADDWF num2,f
		;CLRF x2
		GOTO dis_RB0_huns2
	dis_RB0_huns2
		MOVLW	030		; load ASCII offset
		ADDWF	d23,W
		CALL	send
		
		GOTO cont
	;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;tenth part
	tens2
		MOVLW 0C9		; code to home cursor
		CALL send		; output it to display
		BSF	Select,RS	; and restore data mode
		BTFSS INTCON,1  ; check if interrupt is from RB0 or Timer0 
		GOTO TM0_INT24
	RBO_INTR24
		CLRF counter
		INCF d23,1
		MOVLW 6			;check if tenthousandth=6
		SUBWF d21,W		
		BTFSC STATUS,2	
		GOTO chk_thous24	;if yes then check thousandth value
	normal_tens24
		MOVLW d'10'
		SUBWF d24,W
		BTFSC STATUS,2 ; check if huns is between 0 and 9
		GOTO zero_tens24
		GOTO dis_RB024
	chk_thous24																											
		MOVLW 5
		SUBWF d22,W
		BTFSC STATUS,2
		GOTO chk_huns24																															
		GOTO normal_tens24
	chk_huns24
		MOVLW 5
		SUBWF d23,W
		BTFSC STATUS,2
		GOTO rolling_tens2_3_0
		GOTO normal_tens24
	rolling_tens2_3_0 ;;reaches when tenthousandth=6 and thousandth=5
		MOVLW 4
		SUBWF d24,W
		BTFSC STATUS,2 ; check if tens is more than 3
		GOTO zero_tens24
		GOTO dis_RB024
	zero_tens24
		CLRF d24
		GOTO dis_RB024
	TM0_INT24
		INCF counter,1
		MOVLW d'40'
		SUBWF counter,W
		BTFSC STATUS,2 ;check if counter value is 20 ======================================================================================================
		GOTO dis_TM024
		GOTO cont
	dis_TM024
		CLRF counter
		INCF digit_pos,1
		;MOVF d24,w
		;MOVWF dgt
		;call MUL_BY_10
		;MOVF x2,w
		;ADDWF num2,f
		;CLRF x2
		GOTO dis_RB024
	dis_RB024
		MOVLW	030		; load ASCII offset
		ADDWF	d24,W
		CALL	send
		
		GOTO cont
;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;ones part
	ones2
		MOVLW 0CA		; code to home cursor
		CALL send		; output it to display
		BSF	Select,RS	; and restore data mode
		BTFSS INTCON,1  ; check if interrupt is from RB0 or Timer0 
		GOTO TM0_INT25 
	RBO_INTR25
		CLRF counter
		INCF d25,1
		MOVLW 6			;check if tenthousandth=6
		SUBWF d21,W		
		BTFSC STATUS,2	
		GOTO chk_thous25	;if yes then check thousandth value
	normal_ones25
		MOVLW d'10'
		SUBWF d25,W
		BTFSC STATUS,2 ; check if ones is between 0 and 9
		GOTO zero_ones25
		GOTO dis_RB025
	chk_thous25																												
		MOVLW 5
		SUBWF d22,W
		BTFSC STATUS,2
		GOTO chk_huns25
		GOTO normal_ones25
	chk_huns25
		MOVLW 5
		SUBWF d23,W
		BTFSC STATUS,2
		GOTO chk_tens25
		GOTO normal_ones25
	chk_tens25
		MOVLW 3
		SUBWF d24,W
		BTFSC STATUS,2
		GOTO rolling_ones2_5_0
		GOTO normal_ones25
	rolling_ones2_5_0 ;;reaches when tenthousandth=6 and thousandth=5 and hundredth=5 and tens=3
		MOVLW 6
		SUBWF d25,W
		BTFSC STATUS,2 ; check if tens is more than 3
		GOTO zero_ones25
		GOTO dis_RB025
	zero_ones25
		CLRF d25
		GOTO dis_RB025
	TM0_INT25
		INCF counter,1
		MOVLW d'40'
		SUBWF counter,W
		BTFSC STATUS,2 ;check if counter value is 20 ======================================================================================================
		GOTO dis_TM025
		GOTO cont
	dis_TM025
		CLRF counter
		INCF digit_pos,1
		;MOVF d25,w
		;ADDWF num2,f
		GOTO dis_RB025
	dis_RB025
		MOVLW	030		; load ASCII offset
		ADDWF	d25,W
		CALL	send
		goto cont
;;;;;;;;;;;;;;;;;;;;;;;;
	keepfun
		BSF	Select,RS	; and restore data mode
		BTFSS INTCON,1  ; check if interrupt is from RB0 or Timer0 
		GOTO TM0_INTRr	; handle interrupt Timer 0
		GOTO here
	here
		CLRF counter
		INCF clkNum, 1
		MOVLW 3
		SUBWF clkNum,W
		BTFSC STATUS,2 ; 
		GOTO zero_clks
	TM0_INTRr
		INCF counter, 1
		MOVLW d'40' 
		SUBWF counter,W
		BTFSC STATUS,2 ;
		GOTO dis_TM0_k
		GOTO cont
	zero_clks
		CLRF clkNum
		return
	dis_TM0_k
		;here timer is arrive 2 second
		CLRF counter
		MOVLW 0
		SUBWF clkNum,w
		BTFSC STATUS, 2
		GOTO displayNums
		MOVLW 1
		SUBWF clkNum,w
		BTFSC STATUS,2
		GOTO displayNums
		MOVLW 2
		SUBWF clkNum,w
		BTFSC STATUS,2
		GOTO start
	displayNums
		MOVLW 0C0
		call send
		MOVLW 030
		addwf d11,w
		call send
		MOVLW 030
		addwf d12,w
		call send
		MOVLW 030
		addwf d13,w
		call send
		MOVLW 030
		addwf d14,w
		call send
		MOVLW 030
		addwf d15,w
		call send
		MOVLW 0C6
		call send
		MOVLW 030
		addwf d21,w
		call send
		MOVLW 030
		addwf d22,w
		call send
		MOVLW 030
		addwf d23,w
		call send
		MOVLW 030
		addwf d24,w
		call send
		MOVLW 030
		addwf d25,w
		call send
;; start changing operation
		MOVLW 0C5		; code to home cursor at first position
		CALL send	; output it to display
		BSF Select,RS	; and restore data mode
		BTFSS INTCON,1
		GOTO TM0_INTk
	RB0_INTk
		CLRF counter
		INCF op_num
		MOVLW 3
		SUBWF op_num,W
		BTFSS STATUS, 2
		GOTO dis_RB0k
	zero_opk
		CLRF op_num
	dis_RB0k
		MOVLW 0
		SUBWF op_num,W
		BTFSC STATUS,2
		GOTO add_opk
		MOVLW 1
		SUBWF op_num,W
		BTFSC STATUS,2
		GOTO div_opk
		MOVLW 2
		SUBWF op_num,W
		BTFSC STATUS,2
		GOTO mod_opk
	add_opk
		MOVLW '+'
		CALL send
		GOTO cont
	div_opk
		MOVLW '/'
		CALL send
		GOTO cont
	mod_opk
		MOVLW '%'
		CALL send
		GOTO cont
	TM0_INTk
		INCF counter,1
		MOVLW d'40'
		SUBWF counter,W
		BTFSC STATUS,2 ;check if counter value is 20 
		GOTO dis_OPk
		GOTO cont
	dis_OPk
		CLRF counter
		movf 9, w
		movwf digit_pos
		GOTO dis_RB0k

	

	;;;;;;;;;;;;;;;;;;;;;;;;;;;
	cont
		MOVLW d'61'
		MOVWF TMR0
		BCF INTCON,1
		BCF INTCON,2
		BSF INTCON,7
		return 
	RETFIE


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Port & display setup.....................................
start
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;initialize all digits to zero
	MOVLW 0
	MOVWF d11
	MOVWF d12
	MOVWF d13
	MOVWF d14
	MOVWF d15
	MOVWF d21
	MOVWF d22
	MOVWF d23
	MOVWF d24
	MOVWF d25
	MOVWF d31
	MOVWF d32
	MOVWF d33
	MOVWF d34
	MOVWF d35
	MOVWF d36
	MOVWF counter
	CLRF op_num
	CLRF clkNum
	MOVLW 1
	MOVWF digit_pos
	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;some config. for LCD that connected with portA
	BANKSEL	TRISD		; Select bank 1
	CLRF	TRISD		; Display port is output for the LDC
	BANKSEL TRISC 		; Select bank 1
	BANKSEL TRISB 		; Select bank 1
	BSF TRISB, 0 		; Make RB0 as an input for the push button
	BCF TRISC, 1 		; Make RC1 as an OUTPUT for the led
	BANKSEL PORTD		; Select bank 0
	CLRF	PORTD		; Clear display outputs
	CLRF   0x30
	BANKSEL PORTC		; Select bank 0
	CLRF	PORTC		; Clear display outputs
	BANKSEL PORTB		; Select bank 0
	CLRF	PORTB		; Clear display outputs

	CALL	inid		; Initialise the display

	clrf keepVar
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;print "ENTER OPERATION" in first line
	CALL	putLCD		; display input
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;configuration for interupt on RB0 and TIMR0
	banksel OPTION_REG
	MOVLW B'11000111'
	MOVWF OPTION_REG
	BANKSEL TRISB
	MOVLW H'FF'
	MOVWF TRISB
	BANKSEL INTCON
	BSF INTCON,7 ; Globak=l interrupt enable
	BSF INTCON,4 ; RB0 interrupt enable
	BCF INTCON,1 ; RB0 interrrupt flag
	BSF INTCON,5 ;TIMR0 interrupt enable
	BCF INTCON,2 ;TIMR0 interrupt flag
	MOVLW d'61'
	MOVWF TMR0 ;TMR0 = 256 - (Fosc/4*F*PRE)-->Fosc=4MHZ, F = 1/(50ms),PRE = 256

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;now,just do nothing until interupt on RB0 occur
start2	
	MOVLW 9
	SUBWF digit_pos,W
	BTFSS STATUS, 2
	GOTO rtrn
	BCF INTCON,5
	BCF	Select,RS	; and restore data mode
	MOVLW	0C0		; code to home cursor
	CALL    send		; output it to display
	BSF	Select,RS	; and restore data mode
    MOVLW '=' 
    CALL send   
    CALL print_result
	MOVLW 0
	SUBWF op_num,W	
	BTFSC STATUS,2
	GOTO addition
	GOTO chk_operation
chk_operation
	MOVLW 1
	SUBWF op_num,W		
	BTFSC STATUS,2
	GOTO division_op
	GOTO module_op
module_op
	goto div
division_op
	goto div
addition 
	call add_numbers
showAdd
	;call get_digits
	call display
	call d_3sec
	clrf op_num
	clrf digit_pos
	goto keep
show2
	call get_digits
	call display
	call d_3sec
	clrf op_num
	clrf digit_pos
	goto keep
rtrn
	GOTO start2		; jump to start2 loop

keep
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;initialize all digits to zero
	MOVLW 0
	MOVWF counter
	CLRF op_num
	CLRF clkNum
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;some config. for LCD that connected with portA
	BANKSEL	TRISD		; Select bank 1
	CLRF	TRISD		; Display port is output for the LDC
	BANKSEL TRISC 		; Select bank 1
	BANKSEL TRISB 		; Select bank 1
	BSF TRISB, 0 		; Make RB0 as an input for the push button
	BCF TRISC, 1 		; Make RC1 as an OUTPUT for the led
	BANKSEL PORTD		; Select bank 0
	CLRF	PORTD		; Clear display outputs
	CLRF   0x30
	BANKSEL PORTC		; Select bank 0
	CLRF	PORTC		; Clear display outputs
	BANKSEL PORTB		; Select bank 0
	CLRF	PORTB		; Clear display outputs
	movf 1,w
	movwf keepVar
	CALL	inid		; Initialise the display
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;print "ENTER OPERATION" in first line
	goto print_keep		; display input
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;configuration for interupt on RB0 and TIMR0
	banksel OPTION_REG
	MOVLW B'11000111'
	MOVWF OPTION_REG
	BANKSEL TRISB
	MOVLW H'FF'
	MOVWF TRISB
	BANKSEL INTCON
	BSF INTCON,7 ; Global=l interrupt enable
	BSF INTCON,4 ; RB0 interrupt enable
	BCF INTCON,1 ; RB0 interrrupt flag
	BSF INTCON,5 ;TIMR0 interrupt enable
	BCF INTCON,2 ;TIMR0 interrupt flag
	MOVLW d'61'
	MOVWF TMR0 ;TMR0 = 256 - (Fosc/4*F*PRE)-->Fosc=4MHZ, F = 1/(50ms),PRE = 256
	goto start2

putLCD
    BCF	Select,RS	; set display command mode
	MOVLW	080		; code to home cursor
	CALL	send	; output it to display
	BSF	Select,RS	; and restore data mode

	MOVLW	'E'		; load volts code
	CALL	send		; and output
	MOVLW	'N'		; load volts code
	CALL	send		; and output
	MOVLW	'T'		; load volts code
	CALL	send		; and output
	MOVLW	'E'		; load volts code
	CALL	send		; and output
	MOVLW	'R'		; load volts code
	CALL	send		; and output
	MOVLW	' '		; load volts code
	CALL	send		; and output
	MOVLW	'O'		; load volts code
	CALL	send		; and output
	MOVLW	'P'		; load volts code
	CALL	send		; and output
	MOVLW	'E'		; load volts code
	CALL	send		; and output
	MOVLW	'R'		; load volts code
	CALL	send		; and output
	MOVLW	'A'		; load volts code
	CALL	send		; and output
	MOVLW	'T'		; load volts code
	CALL	send		; and output
	MOVLW	'I'		; load volts code
	CALL	send		; and output
	MOVLW	'O'		; load volts code
	CALL	send		; and output
	MOVLW	'N'		; load volts code
	CALL	send		; and output

	RETURN			; done
    
print_result
	BCF	Select,RS	; and restore data mode
    MOVLW	080		; code to home cursor
    CALL    send		; output it to display
    BSF	Select,RS	; and restore data mode
    MOVLW	'R'		; load volts code
	CALL	send		; and output
	MOVLW	'E'		; load volts code
	CALL	send		; and output
	MOVLW	'S'		; load volts code
	CALL	send		; and output
	MOVLW	'U'		; load volts code
	CALL	send		; and output
	MOVLW	'L'		; load volts code
	CALL	send		; and output
	MOVLW	'T'		; load volts code
	CALL	send		; and output
    MOVLW	' '		; load volts code
	CALL	send		; and output
	MOVLW	' '		; load volts code
	CALL	send		; and output
	MOVLW	' '		; load volts code
	CALL	send		; and output
	MOVLW	' '		; load volts code
	CALL	send		; and output
	MOVLW	' '		; load volts code
	CALL	send		; and output
	MOVLW	' '		; load volts code
	CALL	send		; and output
	MOVLW	' '		; load volts code
	CALL	send		; and output
	MOVLW	' '		; load volts code
	CALL	send		; and output
	MOVLW	' '		; load volts code
	CALL	send		; and output
    
    RETURN			; done
print_keep
	BCF	Select,RS	; and restore data mode
    MOVLW	080		; code to home cursor
    CALL    send		; output it to display
    BSF	Select,RS	; and restore data mode
    MOVLW	'K'		; load volts code
	CALL	send		; and output
	MOVLW	'E'		; load volts code
	CALL	send		; and output
	MOVLW	'E'		; load volts code
	CALL	send		; and output
	MOVLW	'P'		; load volts code
	CALL	send		; and output
	MOVLW	'?'		; load volts code
	CALL	send		; and output
	MOVLW	' '		; load volts code
	CALL	send		; and output
    MOVLW	'1'		; load volts code
	CALL	send		; and output
	MOVLW	':'		; load volts code
	CALL	send		; and output
	MOVLW	'Y'		; load volts code
	CALL	send		; and output
	MOVLW	' '		; load volts code
	CALL	send		; and output
	MOVLW	'2'		; load volts code
	CALL	send		; and output
	MOVLW	':'		; load volts code
	CALL	send		; and output
	MOVLW	'N'		; load volts code
	CALL	send		; and output
	MOVLW	' '		; load volts code
	CALL	send		; and output
	MOVLW	' '		; load volts code
	CALL	send		; and output
    
    RETURN			; done  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
display
	BCF	Select,RS	; and restore data mode
	MOVLW 0C1		; code to home cursor
	CALL send		; output it to display
	BSF	Select,RS	; and restore data mode
	MOVLW 030		; load ASCII offset
	ADDWF d31,W
	CALL send
	MOVLW 030		; load ASCII offset
	ADDWF d32,W
	CALL send
	MOVLW 030		; load ASCII offset
	ADDWF d33,W
	CALL send
	MOVLW 030		; load ASCII offset
	ADDWF d34,W
	CALL send
	MOVLW 030		; load ASCII offset
	ADDWF d35,W
	CALL send
	MOVLW 030		; load ASCII offset
	ADDWF d36,W
	CALL send
	MOVLW	' '		; load volts code
	CALL	send		; and output
	MOVLW	' '		; load volts code
	CALL	send		; and output
	MOVLW	' '		; load volts code
	CALL	send		; and output
	MOVLW	' '		; load volts code
	CALL	send		; and output
	RETURN
;;;;;;;;;;;;;;;;;;;;;;;;
;Addition
add_numbers	
	movf d15,w
    addwf d25,f
	movwf d36
	; Handle the carry, if any
	btfss STATUS, C     ; Check the carry flag
	goto no_carry1       ; If no carry, skip the next instruction
	carry1	
		movf 1,w
		addwf d14,w
		addwf d24,w
		movwf d35
		btfss STATUS,C
		goto no_carry2
	carry2
		movf 1,w
		addwf d13,w
		addwf d23,w
		movwf d34
		btfss STATUS,C
		goto no_carry3
	carry3
		movf 1,w
		addwf d12,w
		addwf d22,w
		movwf d33
		btfss STATUS,C
		goto no_carry4
	carry4
		movf 1,w
		addwf d11,w
		addwf d21,w
		movwf d32
		btfss STATUS,C
		goto dn
	carry5
		movf 1,w
		addwf d31,w
		goto dn
    no_carry1
		movf d14,w
		addwf d24,w
		movwf d35
		btfsc STATUS,C
		goto carry2
	no_carry2
		movf d13,w
		addwf d23,w
		movwf d34
		btfsc STATUS,C
		goto carry3
	no_carry3
		movf d12,w
		addwf d22,w
		movwf d33
		btfsc STATUS,C
		goto carry4
	no_carry4
		movf d11,w
		addwf d21,w
		movwf d32
		btfsc STATUS,C
		goto carry5
	dn
	RETURN
;;;;;;div
div 
	;MOVLW 'h'
	;call send
	goto getFullNumbers
	goto split8bitReg
	; Load initial values for loop variables
    MOVLW 16        ; Initialize loop counter to 16 (16 bits)
    MOVWF counter     ; Store loop counter in COUNT register
	CLRF qL     ; Clear the quotient's least significant byte
    CLRF qH   ; Clear the quotient's most significant byte
    CLRF remL   ; Clear the remainder's least significant byte
    CLRF remH   ; Clear the remainder's most significant byte
	MOVF num2M, W   ; Get the most significant byte of the divisor
    ;MOVWF temp            ; Store in TEMP register for later use
	movf num2M, w
    iorwf num2L, w  ; Check if the divisor is zero
    bz start    ; If divisor is zero, division is not possible
	goto division_loop
	return
    ; Loop to perform division
division_loop
    rlf num1M, f    ; Rotate dividend left
    rlf num1L, f
    rlf qH, f    ; Rotate quotient left
    rlf qL, f

    movf num1M, w
    subwf num2M, w   ; Compare dividend and divisor
    btfsc STATUS, C         ; If result is negative, skip next line
    movf num1L, w
    subwf num2L, w

    btfss STATUS, C         ; If no borrow, repeat the loop
    goto division_loop

    ; If borrow occurred, the division is done
    ; The quotient is in 'quotient_high' and 'quotient_low' registers
    ; The remainder is in 'dividend_high' and 'dividend_low' registers
    ; Move the quotient to 'num_high' and 'num_low' registers
    movf qH, w
    movwf resultH
    movf qL, w
    movwf resultL
    ; Move the remainder to 'remainder_high' and 'remainder_low' registers
    movf num1M, w
    movwf remH
    movf num1L, w
    movwf remL
	MOVLW 1
	SUBWF op_num,w
	BTFSC STATUS,2
	GOTO divResult
	GOTO modResult
divResult
	MOVLW qL
	MOVWF resultL
	MOVLW qH
	MOVWF resultH	
	goto show2
modResult
	MOVLW remL
	MOVWF resultL
	MOVLW remH
	MOVWF resultH	
	goto show2
getFullNumbers
	MOVF d11,w
	MOVWF dgt
	call MUL_BY_10000
	MOVF x2,w
	ADDWF num1,f
	CLRF x2
	MOVF d12,w
	MOVWF dgt
	call MUL_BY_1000
	MOVF x2,w
	ADDWF num1,f
	CLRF x2
	MOVF d13,w
	MOVWF dgt
	call MUL_BY_100
	MOVF x2,w
	ADDWF num1,f
	CLRF x2
	MOVF d14,w
	MOVWF dgt
	call MUL_BY_10
	MOVF x2,w
	ADDWF num1,f
	CLRF x2
	MOVF d15,w
	ADDWF num1,f
	;;; second num
	MOVF d21,w
	MOVWF dgt
	call MUL_BY_10000
	MOVF x2,w
	ADDWF num2,f
	CLRF x2
	MOVF d22,w
	MOVWF dgt
	call MUL_BY_1000
	MOVF x2,w
	ADDWF num2,f
	CLRF x2
	MOVF d23,w
	MOVWF dgt
	call MUL_BY_100
	MOVF x2,w
	ADDWF num2,f
	CLRF x2
	MOVF d24,w
	MOVWF dgt
	call MUL_BY_10
	MOVF x2,w
	ADDWF num2,f
	CLRF x2
	MOVF d25,w
	ADDWF num2,f
	
	return
split8bitReg
	MOVF num1, W ; Move the LSB of the 16-bit number to the W register
    MOVWF num1L   ; Store the LSB in the LSB_NUMBER register
    ; Extract the most significant byte (MSB) of the 16-bit number
    MOVF num1+1, W ; Move the MSB of the 16-bit number to the W register
    MOVWF num1M    ; Store the MSB in the MSB_NUMBER register
	;;second num
	MOVF num2, W ; Move the LSB of the 16-bit number to the W register
    MOVWF num2L   ; Store the LSB in the LSB_NUMBER register
    ; Extract the most significant byte (MSB) of the 16-bit number
    MOVF num2+1, W ; Move the MSB of the 16-bit number to the W register
    MOVWF num2M    ; Store the MSB in the MSB_NUMBER register
	return
MUL_BY_10000
	MOVLW d'10000'
	MOVWF x
	MOVF dgt,w
	loop3
		ADDWF x2,f 
		decfsz x,f
	GOTO loop3
	RETURN			; done
MUL_BY_1000
	MOVLW d'1000'
	MOVWF x
	MOVF dgt,w
	loop4
		ADDWF x2,f 
		decfsz x,f
	GOTO loop4
	RETURN			; done
MUL_BY_100	
	MOVLW d'100'
	MOVWF x
	MOVF dgt,w
	loop5
		ADDWF x2,f 
		decfsz x,f
	GOTO loop5
	RETURN			; done
MUL_BY_10	
	MOVLW d'10'
	MOVWF x
	MOVF dgt,w
	loop6
		ADDWF x2,f 
		decfsz x,f
	GOTO loop6
	CLRF dgt
	RETURN			; done

;;;;;;mod
; get all digits.....................................
; Calculate tenthousandth digit.....................................
get_digits	
; Step 1: Move the content of regH to the W register (MSB)
    MOVF resultH, W
; Step 2: Shift the content of W to the left by 8 bits (making space for the middle byte)
    SWAPF W, F      ; Swap the nibbles to get the high nibble on the right side
    MOVWF temp      ; Store the result in a temporary register

    MOVF resultL, W

; Step 4: Shift the content of W to the left by 8 bits (making space for the LSB)
    SWAPF W, F      ; Swap the nibbles to get the high nibble on the right side
    MOVWF temp+1    ; Store the result in the next byte of the temporary register

; Step 7: Combine the three bytes into the original 24-bit number
    MOVF temp, W    ; Move the MSB from the temporary register to W
    MOVWF result ; Move the result from W to the originalNumber
    MOVF temp+1, W  ; Move the middle byte from the temporary register to W
    IORWF result+1, F   ; OR the result with the originalNumber middle byte
																												
	BSF	STATUS,C	; set carry for subtract
	MOVLW	D'10000'		; load 10000
sub3 																																		
	SUBWF	result		; and subtract from result
	INCF	d32,1		; count number of loops
	BTFSC	STATUS,C	; and check if done
	GOTO	sub3		; no, carry on
	ADDWF	result		; yes, add 10000 back on
	DECF	d32,1		; and correct loop count

; Calculate thousandth digit.....................................

	BSF	STATUS,C	; repeat process for tens
	MOVLW	D'1000'		; load 1000
sub4
	SUBWF	result	    ; and subtract from result
	INCF	d33		; count number of loops
	BTFSC	STATUS,C	; and check if done
	GOTO	sub4		; no, carry on
	ADDWF	result		    ; yes, add 1000 back on
	DECF	d33		; and correct loop count

; Calculate hundredth digit.....................................

	BSF	STATUS,C	; repeat process for tens
	MOVLW	D'100'		; load 100
sub5
	SUBWF	result		    ; and subtract from result
	INCF	d34		; count number of loops
	BTFSC	STATUS,C	; and check if done
	GOTO	sub5		; no, carry on
	ADDWF	result	    ; yes, add 100 back on
	DECF	d34		; and correct loop count
	
; Calculate tens digit.....................................

	BSF	STATUS,C	; repeat process for tens
	MOVLW	D'10'		; load 10
sub6
	SUBWF	result		; and subtract from result
	INCF	d35		; count number of loops
	BTFSC	STATUS,C	; and check if done
	GOTO	sub6		; no, carry on
	ADDWF	result		; yes, add 100 back on
	DECF	d35		; and correct loop count
; Calculate oness digit.....................................
	MOVF	result,W		; load remainder
	MOVWF	d36		; and store as ones digit

	RETURN			; done


d_3sec
	movlw d'12'
	movwf d3
	loop3d
	movlw d'200'
	movwf d2
	loop2d
	movlw d'250'
	movwf d1
	loopd
	nop
	nop
	decfsz d1,f
	goto loopd 
	decfsz d2,f
	goto loop2d
	decfsz d3,f
	GOTO loop3d
	return



	#INCLUDE "LCDIS.INC"

finl
	END	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;