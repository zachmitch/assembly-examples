TITLE Assignment 1 - Simple Maths   (assignment1.asm)

; Author:  Zach Mitchell	mitcheza@oregonstate.edu
; Course / Project ID:  CS271-Sec400, Assignment1  Date:1/15/18	 Due: 1/21/18
; Description:	This program takes in two numbers from a user 
; and then provides user with calculations/output of those numbers

INCLUDE Irvine32.inc

.data

num1          DWORD     ?	; Holds first user integer input 
num2          DWORD     ?	; Holds second user integer input
numSum        DWORD     ?	; Sum of num1 & num2
numSub        DWORD     ?	; Difference of num1 & num2
numMul        DWORD     ?	; Product of num1 & num2
numDivQ       DWORD     ?	; Quotient of num1 / num2
numDivR       DWORD     ?	; Integer remainder of num1 / num2
intro_1       BYTE      "Welcome to 'Assignment 1 - Simple Maths' by Zach Mitchell",0
intro_2       BYTE      "Please enter 2 integers (the FIRST being > the SECOND) to see the maths...",0
prompt_num1   BYTE      "ENTER FIRST POSITIVE INTEGER: ",0
prompt_num2   BYTE      "ENTER SECOND POSITIVE INTEGER: ",0
resSum        BYTE      " + ",0
resSub        BYTE      " - ",0
resMul        BYTE      " * ",0
resDivQ       BYTE      " / ",0
resDivR       BYTE      " Remainder ",0
equals        BYTE      " = ",0
outro         BYTE      "That was too much fun.  Goodbye.",0
ec1Intro      BYTE      "**EC1: Program Repeats until user chooses to quit**",0
ec1           BYTE      "Would you like to see the maths again? 1 = YES, 0 = NO: ",0
ec2Intro      BYTE      "**EC2: Program verifies that Number 1 > Number 2**",0
ec2           BYTE      "Number 1 must be greater than Number 2, TRY AGAIN...",0


.code
main PROC

; Display author name and program title on the output screen

    mov     edx, OFFSET intro_1
    call    WriteString
    call    CrLf
    call    CrLf

; Display instructions to the user of the nature of the program

    mov     edx, OFFSET intro_2
    call    WriteString
    call    CrLf


; Prompt user for two numbers

promptNums:

    call    CrLf					
    mov     edx, OFFSET ec2Intro        ;Extra credit 2 output alert
    call    WriteString
    call    CrLf	
    call    CrLf	

    mov     edx, OFFSET prompt_num1    ;Prompt for first number
    call    WriteString
    call    ReadInt                    ;Read number into variable
    mov     num1, eax
    call	  CrLf

    mov     edx, OFFSET	prompt_num2    ;Prompt for second number
    call    WriteString
    call    ReadInt                    ;Read number into variable
    mov     num2, eax
    call    CrLf

    ;Extra credit 2 - Verify that number 1 is > number 2

    mov     eax, num1
    cmp     eax, num2
    jg      calculate                  ;Jump to calculate section if num1 > num2
    mov     edx, OFFSET ec2            ;Else tell user of erroneous ways, then prompt again
    call    WriteString
    call    CrLf
    jmp     promptNums                 ;Jump back to prompt for two new numbers
        


; Calculate sum/difference/product/quotient of the numbers

calculate:

    mov     eax, num1                  ;addition of num1 and num2
    add     eax, num2
    mov     numSum, eax

    mov     eax, num1                  ;subtraction of num1 and num2
    sub     eax, num2		
    mov     numSub, eax

    mov     eax, num1                  ;multiplication of num1 and num2
    mul     num2
    mov     numMul, eax

    mov     eax, num1                  ;division of num1 and num2
    div     num2
    mov     numDivQ, eax
    mov     numDivR, edx

; Display results

    mov     eax, num1                  ;Display result of addition
    call    WriteDec
    mov     edx, OFFSET resSum
    call    WriteString
    mov     eax, num2
    call    WriteDec
    mov     edx, OFFSET equals
    call    WriteString
    mov     eax, numSum
    call    WriteDec
    call    CrLf

    mov     eax, num1                  ;Display result of subtraction
    call    WriteDec
    mov     edx, OFFSET resSub
    call    WriteString
    mov     eax, num2
    call    WriteDec
    mov     edx, OFFSET equals
    call    WriteString
    mov     eax, numSub
    call    WriteDec
    call    CrLf

    mov     eax, num1                 ;Display result of multiplication
    call    WriteDec
    mov     edx, OFFSET resMul
    call    WriteString
    mov     eax, num2
    call    WriteDec
    mov     edx, OFFSET equals
    call    WriteString
    mov     eax, numMul
    call    WriteDec
    call    CrLf

    mov     eax, num1                 ;Display result of division
    call    WriteDec
    mov     edx, OFFSET resDivQ
    call    WriteString
    mov     eax, num2
    call    WriteDec
    mov     edx, OFFSET equals
    call    WriteString
    mov     eax, numDivQ
    call    WriteDec
    mov     edx, OFFSET resDivR
    call    WriteString
    mov     eax, numDivR
    call    WriteDec
    call    CrLf
    call    CrLf

; Extra Credit 1 - Prompt user whether they'd like to go again

    mov     edx, OFFSET ec1Intro
    call    WriteString             ;Instruct user to input yes(1) or no(0) to go again
    call    CrLf
    call    CrLf
    mov     edx, OFFSET ec1
    call    WriteString
    call    ReadInt
    cmp     eax, 1                  ;If user says yes, prompt again for numbers
    je      promptNums
    call    CrLf


; Say goodbye to user
    
    call    CrLf
    mov     edx, OFFSET outro
    call    WriteString
    call    CrLf

    exit	; exit to operating system

main ENDP

; (insert additional procedures here)

END main
