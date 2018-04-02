TITLE Fibonacci Numbers     (project2_ZachMitchell.asm)

; Author:  Zach Mitchell    mitcheza@oregonstate.edu
; Course / Project ID: CS271-400, Project 2       Date: 1/23/18  Due: 1/28/18
; Description:  Lists user name and n number of fibonacci numbers

INCLUDE Irvine32.inc

     HIGHESTFIB = 46          ;Highest allowable number of Fibonacci numbers to be listed
     LOWESTFIB = 1            ;Lowest allowable number of Fibonacci numbers to be listed
     LINEMAX = 5              ;Most numbers to be printed on a line

.data

     intro          BYTE     "Welcome to The Fibonacci List, by Zach Mitchell",0
     promptName     BYTE     "Hello, please enter your name: ",0
     userName       BYTE     35 DUP(0)         ;Holds user name
     greetUser      BYTE     ", yes, I thought that looked like you.  Let's begin.",0
     promptFibN     BYTE     "Choose a number (1-46) and I will show you that many Fibonacci numbers: ",0
     outsideFibN    BYTE     "That is not a number from 1-46.  Why don't you try again: ",0
     printStatus    BYTE     "Here are your Fibonacci numbers: ",0
     fibN           DWORD    ?     ;Will hold n number of Fibonacci numbers, between LOWESTFIB-HIGHESTFIB
     curN           DWORD    0     ;Will hold the current fibN printed out (iterator)
     curFib         DWORD    1     ;Current Fibonacci number, starts with 1
     byeUser        BYTE     ", it was an excellent time.  Until the next, eat your vegetables.",0
     ecColumns      BYTE     "**EC - Print output to columns**",0

.code
main PROC

;Display introduction - program title and programmer's name

     mov       edx, OFFSET intro
     call      WriteString
     call      CrLf
     call      CrLf

;Get user name

     mov       edx, OFFSET promptName
     call      WriteString
     mov       edx, OFFSET userName
     mov       ecx, 34
     call      ReadString

;Greet user with collected name

     mov       edx, OFFSET userName
     call      WriteString
     mov       edx, OFFSET greetUser
     call      WriteString
     call      CrLf
     call      CrLf

;Instructions to input integer between LOWESTFIB-HIGHESTFIB

ReadFib:
     mov       edx, OFFSET promptFibN
     call      WriteString

;Get and validate the user input

     call      ReadInt                       ; if (n >= 1 && n <= 46), jump to list fib numbers
     cmp       eax, LOWESTFIB                ;Compare to min allowable number of Fibs
     jl        RePromptFib
     cmp       eax, HIGHESTFIB               ;Compare to max allowable number of Fibs
     jg        RePromptFib
     mov       fibN, eax
     jmp       ListFibs
     
RePromptFib:                                 ;Else, if user inputs number outside range tell them
     mov       edx, OFFSET outSideFibN       ; then send back to read in another number
     call      WriteString
     call      CrLf
     call      CrLf
     jmp       ReadFib

     

;Display fibonacci numbers through nth term (display 5 items & >=5 spaces between per line)


ListFibs:

     call      CrLf
     mov       edx, OFFSET printStatus       ;Let user know their numbers are on the way
     call      WriteString
     call      CrLf

     mov       edx, OFFSET ecColumns         ;Let grader know I attempted the extra credit of columnar output
     call      WriteString
     call      CrLf
     call      CrLf

     mov       ebx, 0                        ;Clear ebx register for fibonacci algorithm

StillPrinting:                               ;A do-while loop begins here, print while fibN > 0

     mov       eax, fibN                     
     sub       eax, curN                     ;See how many we have to print left
     cmp       eax, LINEMAX                  ;Set inner for-loop iterator (Print line length)
     jg        GreaterThanLineMax            ;we need to see if user input fibN is < Line max,
     mov       ecx, eax                      ;as we only want to print so many per line, or less if fibN < line max
     jmp       PrintALine
    
GreaterThanLineMax:     
     mov       ecx, LINEMAX                  ;Sets line length to our line max

PrintALine:                                  ;A for-loop, where iterator == to either 5 or fibN
     
     mov       eax, curFib                   ;Print the current Fib number
     call      WriteDec

     add       eax, ebx                      ; Create next Fib number
     mov       ebx, curFib                   ;'Rotate' numbers to new positions of Fib sequence
     mov       curFib, eax

     ;**Extra credit - Print output in columns**

     mov       al, 9                         ;Print Tab to screen, (ascii 9)
     call      WriteChar                     ;If curN is >= 35 print 1 tab (numbers get big)
     cmp       curN, 35                      ;Else print 2 tab
     jge       IncAndRepeat
     call      WriteChar

IncAndRepeat:
     inc       curN                          ;Increment iterator of current Fib number

     loop      PrintALine                    ;Loop back to calling print statement again, while ecx > 0
     call      CrLf

     mov       eax, fibN                     ;Post-test for do-while
     cmp       eax, curN                     ;See if we have any more fibs to print
     jg        StillPrinting                 ;Keep printing if so

;Say goodbye to user with departing message
     
     call      CrLf
     mov       edx, OFFSET userName
     call      WriteString
     mov       edx, OFFSET byeUser
     call      WriteString
     call      CrLf
	
exit	; exit to operating system
main ENDP


END main
