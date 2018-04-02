TITLE Program 3 - Negative Funstuff     (prog3_mitcheza.asm)

; Author:  Zach Mitchell  mitcheza@oregonstate.edu
; Course / Project ID: CS271-400, Program 3  Date: 2/7/18  Due: 2/11/18
; Description:  This program will prompt user for negative numbers until they do not
; input a negative number, then it will avg all of the numbers they did input w/other stats

INCLUDE Irvine32.inc

; Constants

     LOWER_LIMIT = -100   ;Lowest allowable number to be input by user
     UPPER_LIMIT = -1    ;Highest allowable number to be input by user

.data

; Variables

     
     intro          BYTE      "Welcome to Program 3 - 'Negative Funstuff,' by Zach Mitchell",0
     promptName     BYTE      "Please input your name, human: ",0
     userName       BYTE      30 DUP(0)      ;Holds user's name
     helloUser      BYTE      ", yes, I thought that looked like you.",0
     directions1    BYTE      "So today you are going to enter number from ",0
     directionsTo   BYTE      " to ",0   ; Example from '-100 to -1'
     directions3    BYTE      " (inclusive), and then I am going to give you some statistics about those numbers.  Cool? [PRESS ENTER/RETURN]",0
     promptNum1     BYTE      ". Enter a number from ",0
     promptNum2     BYTE      ": ",0
     negCount       SDWORD    0         ;Holds number of acceptably input user numbers
     negCountOut1   BYTE      "You entered ",0
     negCountOut2   BYTE      " acceptable numbers within the stated range.",0
     negSum         SDWORD    0         ;Will hold sum of acceptable inputs from user
     negSumOut      BYTE      " was the sum of acceptable numbers that you input.",0
     negAvg         SDWORD    ?         ;Hold average of acceptable inputs from user
     negAvgOut      BYTE      " was the rounded average of your acceptable inputs.",0
     ifZeroNums     BYTE      "You didn't input any numbers within the acceptable range.",0
     goodBye        BYTE      ", what a fantastic time we had.  Goodbye my friend.",0
     ecPromptCt     SDWORD    1         ;Will be the number of times the user has been prompted
     ec1Out         BYTE      "**EXTRA CREDIT ATTEMPT 1, NUMBER THE PROMPT LINES**",0


.code
main PROC

;Display the program title and programmer's name

     mov       edx, OFFSET intro
     call      WriteString
     call      CrLf
     call      CrLf

;Get the user's name and then greet the user

     mov       edx, OFFSET promptName             ;Ask for name
     call      WriteString

     call      ReadString                         ;Read in user input name
     mov       edx, OFFSET userName
     mov       ecx, 29
     call      ReadString
     call      CrLf
     call      CrLf

     mov       edx, OFFSET userName              ;Greet user  with their name
     call      WriteString
     mov       edx, OFFSET helloUser
     call      WriteString
     call      CrLf
     call      CrLf

;Display instructions for what the program is supposed to do (input numbers within range)

     mov       edx, OFFSET directions1
     call      WriteString
     mov       eax, LOWER_LIMIT                   ;Display lower limit constant
     call      WriteInt
     mov       edx, OFFSET directionsTo
     call      WriteString
     mov       eax, UPPER_LIMIT                   ;Display upper limit constant
     call      WriteInt
     mov       edx, OFFSET directions3
     call      WriteString
     call      ReadString
     call      CrLf
     call      CrLf

;Repeatedly prompt for negative number

     ;Extra Credit output to grader
     mov       edx, OFFSET ec1Out
     call      WriteString
     call      CrLf

PromptNum:

     mov       eax, ecPromptCt                    ;Extra credit, numbering the line
     call      WriteDec
     inc       ecPromptCt

     mov       edx, OFFSET promptNum1
     call      WriteString
     mov       eax, LOWER_LIMIT                   ;Display lower limit constant
     call      WriteInt
     mov       edx, OFFSET directionsTo
     call      WriteString
     mov       eax, UPPER_LIMIT                   ;Display upper limit constant
     call      WriteInt
     mov       edx, OFFSET promptNum2
     call      WriteString

;Validate that user input is within range

     call      ReadInt
     jns       ifZero                        ;Check sign flag to see if positive number (>=0) input, if so exit prompt loop
     cmp       eax, LOWER_LIMIT              ;If user inputs number < limit, reprompt (ignores input)
     jl        PromptNum

;Count and accumulate the valid user numbers until a non-negative number is entered
;We are in this code block only if user has input a successful number within range


     add       negSum, eax                   ;Accumulate sum of successful inputs

     inc       negCount                      ;Increment count of successful inputs

     jmp       PromptNum                     ;Send user back to reprompt for more numbers



;Before performing any calculation let us check if user input ANY acceptable numbers
;because if the negCount == 0, we cannot divide by 0 (maths).

ifZero:

     mov       eax, negCount                 ;If user didn't input any acceptable numbers
     cmp       eax, 0                  
     jg        Calculate
     mov       edx, OFFSET ifZeroNums        ;Tell them they didn't do it correctly
     call      WriteString
     call      CrLf
     call      CrLf
     jmp       ExitMessage                   ;Move to exit message


;Calculate the average (rounded int) of all negative inputs

Calculate:

     mov       eax, negSum                   ;Divide total by count for average
     cdq                                     ;Extend so it divides correctly
     idiv      negCount

     mov       negAvg, eax                   ;Move current average to variable, integer division so we must acct for rounding next

     mov       eax, edx                      ;If remainder > .5 round integer down on number line (it's negative) (Examples: -20.5 => -20, -20.51 => -21)
     neg       eax

     mov       ecx, 10                       ;Multiply by 10 so we can move the decimal place to the right accounting for integer division (odd divisor creates .5 results)
     mul       ecx
                                           
     mov       ebx, eax

     mov       eax, negCount                 ;negCount is our original divisor, we must find the .5 threshold of it by dividing by 2
     mul       ecx                           ;We first multiply by 10 though, again, moving the decimal place right once to acct for integer division
     cdq

     mov       ecx, 2
     div       ecx                           ;We must find .5 threshold by dividing original divisor (negCount) by 2, and then comparing to previous remainder (in ebx)

     cmp       ebx, eax

     jle       DisplayOutput                 ;If remainder <= negCount/2 (.5), output results without decrementing
     dec       negAvg                        ;Else if > .5, decrement (it's negative) (Examples: -20.5 => -20, -20.51 => -21)


;Display the count of neg #'s entered

DisplayOutput:

     call      CrLf
     mov       edx, OFFSET negCountOut1
     call      WriteString
     mov       eax, negCount
     call      WriteDec
     mov       edx, OFFSET negCountOut2
     call      WriteString
     call      CrLf
     call      CrLf

;Display the sum of negative numbers entered 

     mov       eax, negSum
     call      WriteInt
     mov       edx, OFFSET negSumOut
     call      WriteString
     call      CrLf
     call      CrLf

;Display the average of negative numbers entered


     mov       eax, negAvg
     call      WriteInt
     mov       edx, OFFSET negAvgOut
     call      WriteString
     call      CrLf
     call      CrLf

;Display a goodbye to the user

ExitMessage:

     mov       edx, OFFSET userName
     call      WriteString
     mov       edx, OFFSET goodBye
     call      WriteString
     call      CrLf
     call      CrLf


	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
