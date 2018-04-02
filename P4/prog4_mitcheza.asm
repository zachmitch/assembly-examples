TITLE Composite Numbers   (prog4_mitcheza.asm)

; Author: Zach Mitchell mitcheza@oregonstate.edu
; Course / Project ID:  CS271-400, Program 4  Date: 2/11/18  Due: 2/18/18
; Description: Program prompts user for a number from 1-400, then displays
; that input number's worth of composite nums 1 - n

INCLUDE Irvine32.inc

; Constants

     LOWER_LIMIT = 1
     UPPER_LIMIT = 400

.data

; Variables

     introTxt       BYTE      "Welcome to 'Composite Numbers' by Zach Mitchell.",0
     summaryTxt1    BYTE      "Enter a number and I will show that many composite numbers.",0
     summaryTxt2    BYTE      "I accept numbers from ",0
     direct1        BYTE      "Please enter a number from ",0
     direct2        BYTE      " - ",0
     direct3        BYTE      " and I'll display that many composite numbers: ",0
     notInRgTxt     BYTE      "That number wasn't within range.  Try again.",0
     goodByeTxt     BYTE      "That was swell.  Until next time...be cool.",0
     nComps         DWORD     ?         ;Will be the number of printed composite numbers
     nCompsMod      DWORD     ?         ;Will hold nComps % 10 for comparison/making 10 items per line
     nCompTxt       BYTE      "You will see this many composite numbers: ",0
     curComp        DWORD     4         ;holds current composite number, 4 is first composite number
     compSpcr       BYTE      "   ",0
     compFndr       DWORD     5         ;Used to efficiently find whether a number is composite in Log(n)

.code
main PROC

     call      intro                    ;Introduce program and programmer and summary
     call      getUserData              ;Prompt for # between LOWER_LIM - UPPER_LIM, and validate 
     call      showComps                ;Show composite numbers 1 - n
     call      goodBye                  ;Say goodbye to user

	exit	                              ; exit to operating system
main ENDP

; Additional Procedures


;- - - - - - intro - - - - - - - - - - - - - - - - - - 
;Description - Introduces program and gives directions of what to do
;Receives - global variables: introTxt, summaryTxt1, summaryTxt2
;direct2...Constants: LOWER_LIMIT, UPPER_LIMIT
;Returns - N/A
;Preconditions - N/A
;Registers Changed - EDX, EAX

intro PROC

     mov       edx, OFFSET introTxt          ;Display program/mer name
     call      WriteString
     call      CrLF
     call      CrLf

     mov       edx, OFFSET summaryTxt1       ;Give user directions of how to use the program
     call      WriteString
     call      CrLf
     mov       edx, OFFSET summaryTxt2
     call      WriteString
     mov       eax, LOWER_LIMIT              ;Show lower limit
     call      WriteDec
     mov       edx, OFFSET direct2
     call      WriteString
     mov       eax, UPPER_LIMIT              ;Show upper limit
     call      WriteDec
     call      CrLf
     call      CrLf


     ret
intro ENDP


;- - - - - - getUserData - - - - - - - - - - - - - - - - - - 
;Description - Asks for number and runs validate procedure making sure within range
;Receives - Global Variables: direct1, direct2, direct3
; Constants: LOWER_LIMIT, UPPER_LIMIT
;Returns - N/A
;Preconditions - N/A
;Registers Changed - EAX, EDX

getUserData PROC

     mov       edx, OFFSET direct1           ;Tell user to input number from LOWER_LIMIT to UPPER_LIMIT
     call      WriteString
     mov       eax, LOWER_LIMIT              ;Show lower limit
     call      WriteDec                      
     mov       edx, OFFSET direct2           
     call      WriteString
     mov       eax, UPPER_LIMIT
     call      WriteDec
     mov       edx, OFFSET direct3
     call      WriteString
     call      ReadInt
     call      validate                      ;Validate that number input is within range

     ret
getUserData ENDP


;- - - - - - showComps - - - - - - - - - - - - - - - - - - 
;Description - Introduces program and tells user what to do
;Receives - nComps 
;Returns - N/A
;Preconditions - nComps defined
;Registers Changed - EDX, ECX

showComps PROC

     mov       edx, OFFSET nCompTxt          ;Tell user how many numbers they are going to see
     call      WriteString
     mov       eax, nComps
     call      WriteDec
     call      CrLf
     call      CrLf

     mov       ecx, nComps                   ;Set ecx for loop

     mov       eax, nComps                   ;Find the mod of nComps % 10 as we want 10 #'s row
     mov       edx, 0
     mov       ebx, 10
     div       ebx
     mov       nCompsMod, edx                ;Save nComps % 10 for later comparison when printing

   CheckComp:                                ;print out composite numbers

     call      isComposite                   ;Make sure current number is composite

     cmp       eax, 0
     js        NoComp                        ;Check sign flag (-1 in EAX means Prime number)

   YesComp:                                  ;Since it's composite, print it out, with spacer
                                             
     mov       eax, curComp                  
     call      WriteDec
     mov       edx, OFFSET compSpcr
     call      WriteString

   
     mov       eax, ecx                      ;Checking to see if we have 10 items per line
     sub       eax, 1
     mov       ebx, 10
     mov       edx, 0                    
     div       ebx
     cmp       edx, nCompsMod                ; Compare nComps mod to current ecx mod 
     jne       Not10                         ; If they are equal, we have 10 on a row and
     call      CrLf                          ; we move to next line

     Not10:                                  ;There are not yet 10 items on a row

     inc       curComp                       ;Increment to next number and then jump to end of loop (and let it dec ecx)

     jmp       LoopComp

   NoComp:                                   ;Is a prime number, increment to next number and retest
                                             ;Does not make decrement the loop counter in ECX
     inc       curComp
     jmp       CheckComp

   LoopComp:                                 ;Only if a successful printed comp happens does this execute

     loop      CheckComp                     ;Loop through user defined n



     ret
showComps ENDP



;- - - - - - goodBye - - - - - - - - - - - - - - - - - - 
;Description - Message to let user know the program is ending
;Receives - Global Variables: goodByeTxt
;Returns - N/A
;Preconditions - N/A
;Registers Changed - EDX

goodBye PROC

     call      CrLf
     call      CrLf
     mov       edx, OFFSET goodByeTxt        ;Say goodbye to user
     call      WriteString
     call      CrLf
     call      CrLf

     ret
goodBye ENDP



;- - - - - - validate - - - - - - - - - - - - - - - - - - 
;Description - Makes sure that user input is within stated range
;Receives - EAX (user input)
;Returns - nComps
;Preconditions - Prompt user for a number
;Registers Changed - EAX,EBX

validate PROC

     mov       ebx, LOWER_LIMIT              ;Compare to lower limit
     cmp       eax, ebx
     jl        NotInRange

     mov       ebx, UPPER_LIMIT              ;Compare to upper limit
     cmp       eax, ebx
     jg        NotInRange

     mov       nComps, eax                   ;Assign acceptable number to nComps
     jmp       InRange                  

  NotInRange:                                ;Tell user out of range

     mov       edx, OFFSET notInRgTxt
     call      WriteString
     call      CrLf
     call      CrLf
     call      getUserData                   ;Reprompt for another number

  InRange:                                   ;Was in range, end validation
                
     ret
validate ENDP



;- - - - - - isComposite - - - - - - - - - - - - - - - - - - 
;Description - Produces bool whether the input is a composite number
;Receives - curComp
;Returns -   1(TRUE) or -1(FALSE) in EAX
;Preconditions- First number passed is > 3
;Registers Changed - EAX, EBX, EDX

isComposite PROC

;    Found efficient composite finding algorithm in C++ @:
;    https://www.geeksforgeeks.org/composite-number/
;
;    Converted to Assembly below, but here it is in C++ for purposes of documentation
;
;    bool isComposite(int i) {
;         if (n <= 3) return false;
;
;         if(n % 2 == 0 || n % 3 == 0) return true;
;
;         //Labeled as "FindFactors:" below
;         //Log(n) search through possible factors of n
;         for (int i = 5; i * i <= n; i += 6)          
;              if(n % i == 0 || n % (i + 2) == 0)
;                   return true;
;    }


     mov       eax, curComp                  ;Check if current number is even (composite)
     mov       ebx, 2                        
     mov       edx, 0
     div       ebx                           
     cmp       edx, 0
     je        IsTrue                        ;If no remainder, it's composite

     mov       eax, curComp                  ;Check if current number is divisible by 3
     mov       ebx, 3
     mov       edx, 0
     div       ebx                           
     cmp       edx, 0
     je        IsTrue                        ;no remainder, is composite

  FindFactors:                               ; We duplicate the for-loop seen above in C++ starting iterator = 5
                                             ; incrementing += 6 on each iteration
     mov       ebx, curComp                  ; loop breaks if (i * i > n) [false] or modding of n % (i || i +2) == 0 [true]
     mov       eax, compFndr                 
     mul       eax                           ; == while (i * i <= n) in C++ for-loop documented above
     cmp       eax, ebx
     jg        IsFalse                       ;Break for loop and return false if i * i > n

     mov       eax, curComp                  ; Mod n by i
     mov       edx, 0                        
     mov       ebx, compFndr                  
     div       ebx                           
     cmp       edx, 0                        ; If no remainder upon n / i, it's composite
     je        IsTrue
     
     mov       eax, curComp                  ; Mod n by i + 2
     add       ebx, 2
     mov       edx, 0
     div       ebx
     cmp       edx, 0
     je        IsTrue                        ;If no remainder upon n / (i + 2), it's composite

     add       compFndr, 6                   ; Not yet sure if composite/prime number, so we += divisor by 6 and 
     jmp       FindFactors                   ; loop through again until we hit limit in our for-loop

  IsTrue:
     mov       eax, 1                        ;curComp is a composite number
     jmp       EndIsComposite

  IsFalse:
     mov       eax, -1                       ;curComp is NOT a composite number, It's prime

  EndIsComposite:

     mov       compFndr, 5                   ;Reset our for loop iterator for next number     
     ret
isComposite ENDP



END main
