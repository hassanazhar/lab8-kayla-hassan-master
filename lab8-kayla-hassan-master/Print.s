; Print.s
; Student names: change this to your names or look very silly
; Last modification date: change this to the last modification date or look very silly
; Runs on LM4F120 or TM4C123
; EE319K lab 7 device driver for any LCD
;
; As part of Lab 7, students need to implement these LCD_OutDec and LCD_OutFix
; This driver assumes two low-level LCD functions
; ST7735_OutChar   outputs a single 8-bit ASCII character
; ST7735_OutString outputs a null-terminated string 

    IMPORT   ST7735_OutChar
    IMPORT   ST7735_OutString
    EXPORT   LCD_OutDec
    EXPORT   LCD_OutFix

    AREA    |.text|, CODE, READONLY, ALIGN=2
	PRESERVE8
    THUMB

n EQU 0

;-----------------------LCD_OutDec-----------------------
; Output a 32-bit number in unsigned decimal format
; Input: R0 (call by value) 32-bit unsigned number
; Output: none
; Invariables: This function must not permanently modify registers R4 to R11

LCD_OutDec
	PUSH {R4-R11, LR}
	MOV R1, #10; R4
	MOV R3, #0
find_rem
	SUB SP, SP, #4;DONE 
	MOV R5, R0;DONE R7,R0
	UDIV R0,R1;DONE R2,R0,R4
	MUL R2, R0, R1; R2, R0,R4
	SUB R2, R5, R2;DONE R3,R7,R2
	STRB R2, [SP]; DONE R3,SP
	ADD R3, R3, #1; DONE R6,1
	CMP R0 ,#0; DONE
	BEQ done_finding_rem;DONE 
	B find_rem
	
done_finding_rem
	MOV R4, R3; R8,R6
output
	LDRB R0, [SP]
	ADD R0 ,R0, #0x30
	BL ST7735_OutChar
	NOP
	ADDS R13, R13, #4
	SUB R4, R4, #1
	CMP R4, #0
	BEQ done_pop
	B output
done_pop
	POP {R4-R11, LR}
      BX  LR
;* * * * * * * * End of LCD_OutDec * * * * * * * *

; -----------------------LCD _OutFix----------------------
; Output characters to LCD display in fixed-point format
; unsigned decimal, resolution 0.001, range 0.000 to 9.999
; Inputs:  R0 is an unsigned 32-bit number
; Outputs: none
; E.g., R0=0,    then output "0.000 "
;       R0=3,    then output "0.003 "
;       R0=89,   then output "0.089 "
;       R0=123,  then output "0.123 "
;       R0=9999, then output "9.999 "
;       R0>9999, then output "*.*** "
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutFix
; change r8 to r7
	PUSH {R4-R11,LR};DONE
	MOV R4, #1; R5
	MOV R8, #10000;R7,9999,DONE
	CMP R0, R8;DONE
	BHS asterik;DONE
divide;GOOD DONE
	CMP R4, #5; DONE R5, 5
	BEQ out_number;DONE 
	MOV R1, #10; R4,10, DONE
	MOV R5, R0; R1,R0, DONE
	UDIV R0, R0, R1; R0,R0,R4 DONE
	MUL R2, R0, R1; R2,R0,R4 DONE
	SUB R2, R5, R2; R2,R1,R2 DONE
	SUB SP, SP, #4; DONE
	STRB R2, [SP];DONE
	ADD R4, R4, #1;DONE
	B divide;DONE
	
out_number
	CMP R4, #0; R5,0 DONE
	BEQ done; NONUMLEFT2 DONE
	CMP R4, #4; DONE
	BEQ out_decimal; DONE
	LDRB R0, [SP]; DONE
	BL LCD_OutDec;DONE
	ADD SP, SP, #4;DONE
	SUB R4, R4, #1;DONE
	B out_number;DONE
out_decimal ;DONE
	MOV R7, R0;DONE
	MOV R0, #0x2E;DONE
	BL ST7735_OutChar;DONE
	SUB R4, R4, #1;DONE
	MOV R0, R7;DONE
	B out_number;DONE
	
asterik;DONE
	MOV R0, #0x2A;DONE
	BL ST7735_OutChar;DONE
	MOV R0, #0x2E;DONE
	BL ST7735_OutChar;DONE
	MOV R0, #0x2A;DONE
	BL ST7735_OutChar;DONE
	MOV R0, #0x2A;DONE
	BL ST7735_OutChar;DONE
	MOV R0, #0x2A;DONE
	BL ST7735_OutChar;DONE
done
	POP {R4-R11,LR};DONE
     BX   LR
 
     ALIGN
;* * * * * * * * End of LCD_OutFix * * * * * * * *

     ALIGN                           ; make sure the end of this section is aligned
     END                             ; end of file
