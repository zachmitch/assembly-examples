TITLE Random-ish Numbers     (prog5_mitcheza.asm)

; Author: Zach Mitchell mitcheza@oregonstate.edu
; Course / Project ID:  CS271-400,  Program 5  Date:  2/20/18  Due:  3/4/18
; Description:  Produces an array of random-ish integers, the count of which
; is chosen by the user

INCLUDE Irvine32.inc

; Constants

     MIN = 10       ;Lowest number of items in array
     MAX = 200      ;Highest number of items in array
     LO = 100       ;Lowest random number possible
     HI = 999       ;Highest random number possible

.data
   
     intro          BYTE      "Welcome to 'Random-ish Numbers,' by Zach Mitchell.",0
     intro2         BYTE      "You will choose a number between ",0
     intro3         BYTE      " and ",0
     intro4         BYTE      "At which point I will fill an array with that many random looking numbers between ",0
     intro5         BYTE      "Then I will give you the median of those numbers and the then show them in descending order.",0
     enterNum       BYTE      "PLEASE ENTER INTEGER BETWEEN ",0
     enterAnd       BYTE      " AND ",0
     incorrect      BYTE      "INPUT INCORRECT.  TRY AGAIN.",0
     request        DWORD     ?           ; Will hold user input between MIN and MAX
     array          DWORD     MAX DUP(?)  ;Array of random numbers between LO and HI
     hereIs         BYTE      "Here is the ",0
     unsrtTitle     BYTE      "UNSORTED LIST:",0
     srtTitle       BYTE      "SORTED LIST:",0
     medianTitle    BYTE      "MEDIAN: ",0         

.code
main PROC

     call      Randomize           ;Seed for future random numbers



                                   ;Introduction - intro program/mer
     push      OFFSET intro        ;Pass all necessary global vars to stack     
     push      OFFSET intro2
     push      OFFSET intro3
     push      OFFSET intro4
     push      OFFSET intro5
     call      introduction



                                   ;getData - Get and Validate (validate is nested proc) a number from user
     push      OFFSET incorrect
     push      OFFSET enterNum
     push      OFFSET enterAnd
     push      OFFSET request
     call      getData      
     
                                   ;fillArray - Generate Random numbers and fill in array
     push      request
     push      OFFSET array
     call      fillArray

                                   ;display list- unsorted array
     push      OFFSET hereIs
     push      OFFSET unsrtTitle
     push      request
     push      OFFSET array
     call      displayList

                                   ;SortList - array descending
     push      request
     push      OFFSET array
     call      sortList

                                   ;Median - Find median value of array, display it
     push      OFFSET hereIs
     push      OFFSET medianTitle
     push      request
     push      OFFSET array
     call      median

                                   ; display list - sorted array
     push      OFFSET hereIs
     push      OFFSET srtTitle
     push      request
     push      OFFSET array
     call      displayList

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)




;- - - - - - introduction - - - - - - - - - - - - - - - - - - 
;Description - Introduces program and gives directions of what to do
;Receives - As params on stack - intro, intro2,intro3, intro4, intro5
;           As Constants: MIN, MAX
;Returns - N/A
;Preconditions - N/A
;Registers Changed - N/A

introduction PROC

     push      ebp                 ;Save variable to stack for future re-establishment
     mov       ebp, esp
     push      eax
     push      edx                 

     mov       edx, [ebp+24]       ;"Welcome to 'randomish nums...'"
     call      WriteString
     call      CrLf
     call      CrLf

     mov       edx, [ebp+20]       ;"You will choose a number between x and y."
     call      WriteString
     mov       eax, MIN
     call      WriteDec
     mov       edx, [ebp+16]
     call      WriteString
     mov       eax, MAX
     call      WriteDec
     mov       eax, 02Eh
     call      WriteChar
     call      CrLf

     mov       edx, [ebp+12]       ;"At which point I will list ...."
     call      WriteString
     mov       eax, LO
     call      WriteDec
     mov       edx, [ebp+16]
     call      WriteString
     mov       eax, HI
     call      WriteDec
     mov       eax, 02Eh
     call      WriteChar
     call      CrLf

     mov       edx, [ebp+8]        ;"Then I will ...median...sorted descending"
     call      WriteString
     call      CrLf
     call      CrLf

     pop       edx                 ;Re-establish EDX/EAX/EBP to pre proc values
     pop       eax
     pop       ebp                

     ret 20                        ; 20 (pushed 5 x 4-byte addresses to stack)
introduction ENDP




;- - - - - - getData - - - - - - - - - - - - - - - - - - 
;Description - Asks user for a number and then calls validate proc to confirm within range
;Receives -   request (address), enterNum, enterAnd, MIN, MAX, incorrect
;Returns -     request will have a valid value
;Preconditions - N/A
;Registers Changed - N/A 

getData PROC
     
     push      ebp                 ;Save variable to stack for future re-establishment
     mov       ebp, esp
     push      eax
     push      ebx
     push      edx  
     
     mov       edx, [ebp+16]       ;"ENTER NUMBER BETWEEN X AND Y:"
     call      WriteString
     mov       eax, MIN
     call      WriteDec
     mov       edx, [ebp+12]
     call      WriteString
     mov       eax, MAX
     call      WriteDec
     mov       eax, 03Ah
     call      WriteChar
     mov       eax, 000h
     call      WriteChar
     
     call      validate            ;Make certain input is within range/ valid input

     call      CrLf
     mov       ebx, [ebp+8]
     mov       [ebx], eax

     pop       edx                 ;Re-establish EDX/EBX/EAX/EBP to pre proc values
     pop       ebx
     pop       eax
     pop       ebp    


     ret 16
getData ENDP


;- - - - - - fillArray - - - - - - - - - - - - - - - - - - 
;Description - Generates random numbers between LO and HI, fills array with rands
;Receives - Constants: LO, HI  var:  request, array
;Returns - array populated with numbers within range
;Preconditions - request must be within range, array large enough
;Registers Changed - N/A


;Used as reference - lecture slides from lecture 19 and 20

fillArray PROC

     push      ebp                 ;Save variable to stack for future re-establishment
     mov       ebp, esp
     push      eax
     push      ebx
     push      ecx


;Used as reference - lecture slides from lecture 19 and 20

     mov       ecx, [ebp+12]       ;Loop counter that will generate user determined # of rands
     mov       esi, [ebp+8]        ;set esi with first position of array

GenerateRand:
     mov       eax, HI             ;Generate number between 0 - MAX
     inc       eax                 ;Necessary inc as RandomRange is not inclusive
     call      RandomRange
     cmp       eax, LO             ;If random num is < LO, Re-generate
     jl        GenerateRand

                                   ;Place random number within array positon
     mov       [esi], eax          ;Move array to next position
     add       esi, 4
     loop      GenerateRand        ;Decrement loop until we reach user asked for amount


     pop       ecx                 ;Re-establish EAX/EBX/ECX/EBP to pre proc values
     pop       ebx
     pop       eax
     pop       ebp 

;Used as reference - lecture slides from lecture 19 and 20

     ret 8
fillArray ENDP




;- - - - - - displayList - - - - - - - - - - - - - - - - - - 
;Description - Displays the entirety of an array
;Receives -  hereIs, title, request, array
;Returns - N/A
;Preconditions - Array has been populated, Stack parameter pushes must 
;    be made in this order before call(hereIs, title, request, array)
;Registers Changed - N/A

displayList PROC

;Used as reference - lecture slides from lecture 19 and 20

     push      ebp                 ;Save variable to stack for future re-establishment
     mov       ebp, esp
     push      eax                 ; ebp-4
     push      ebx                 ; ebp-8
     push      ecx                 ; ebp-12
     push      edx                 ; ebp-16
     sub       esp, 4              ; ebp-20: Create local variable for making 10 items/line...hold remainder of request/10

     mov       edx, [ebp+20]       ;Output to user that they are seeing rand unsrtd array results
     call      WriteString
     mov       edx, [ebp+16]
     call      WriteString
     call      CrLf

     mov       eax, [ebp+12]       ;We need to print only 10 per line, so we are going to find
     mov       edx, 0              ;the remainder of request/10 to compare to ecx(loop)/10
     mov       ebx, 10             ;storing it in local variable [ebp-20]
     div       ebx
     mov       [ebp-20], edx


 ;Used as reference - lecture slides from lecture 19 and 20

     mov       ecx, [ebp+12]       ;Set loop counter to user input amount
     mov       esi, [ebp+8]        ;Set esi to array[0]

ListEm:                            ;List random array numbers, 10 per line
     mov       eax, [esi]          ;Write current number & tab
     call      WriteDec
     mov       eax, 09h
     call      WriteChar
     add       esi, 4              ;increment along the array

     mov       eax, ecx            ; We are going to find the remainder of current n
     mov       edx, 0              ; (request - n) / 10 for comparison (making 10 items/line)
     mov       ebx, 10
     div       ebx
     dec       edx                 ;Must dec our remainder so as not to get a CRLF after array[0]
     cmp       edx, -1             
     jne       notNine             ;In the case that user puts in a request ending in 9, it takes
     mov       edx, 9              ;our remainder negative (0xFFFF..), special case

notNine:
     cmp       edx, [ebp-20]       ;compare remainders, if equal, CrLf
     je        printCrLf
     cmp       ecx, 0              
     jle       DonePrinting        
     loop      ListEm

printCrLf:                         ;Print 10 items every line
     call      CrLf
     cmp       ecx, 0
     jle       DonePrinting
     loop      ListEm

DonePrinting:

     call      CrLf
     add       esp, 4              ;remove local variable
     pop       edx                 ;Re-establish EDX/ECX/EBX/EAX/EBP to pre proc values
     pop       ecx
     pop       ebx
     pop       eax
     pop       ebp 

     ret 16
displayList ENDP



;- - - - - - sortList - - - - - - - - - - - - - - - - - - 
;Description - Sorts a passed array from greatest to least
;Receives - Array, request(array length)
;Returns - Array(sorted)
;Preconditions - Array must have integers, both arguments must be passed in correct order
;Registers Changed - N/A
;
;   I used selection sort following the C code here:
;
;    for(k = 0; k < request - 1; k++) {
;
;         i = k;
;         for(j = k + 1; j < request; j++) {
;              if(array[j] > array[i])
;                   i = j;
;         }
;         exchange(array[k], array[i]);
;    }
;
;


sortList PROC

     push      ebp                           ;Save variable to stack for future re-establishment
     mov       ebp, esp
     push      eax
     push      ebx
     push      edx  
     sub       esp, 12                       ;Create local variables: i, j, k 
                                             ;                    // also, listed variables passed as arguments
                                             ; i = ebp-16        //    array = ebp+8      (for reference/sanity)
                                             ; j = ebp-20       //     request = ebp+12
                                             ; k = ebp-24      //

     mov       eax, 0
     mov       [ebp-24], eax                 ; set k = 0
     mov       esi, [ebp+8]                  ; target first item of array

OuterK:                                      ; Outer for-loop:  for(k = 0; k < req...
     mov       eax, [ebp+12]                 ; Test condition first, that k < request - 1
     dec       eax                 
     cmp       eax, [ebp-24]
     jle       Sorted                        ; Break if 'while' condition isn't met

     mov       eax, [ebp-24]                 ; Set i = k
     mov       [ebp-16], eax

     inc       eax                           ; Set j
     mov       [ebp-20], eax                 ; j = k + 1

InnerJ:                                      ;Inner for-loop:  for(j = k + 1; ....
     mov       eax, [ebp-20]
     cmp       eax, [ebp+12]                 ; j < request
     jge       Exchange                      ; Break if 'while' condition not met

     mov       eax, [ebp-20]                 ; if(array[j] > array[i]) == eax > ebx
     mov       ebx, [ebp-16]
     mov       eax, [esi + (eax * 4)]        ; < == array[j]
     mov       ebx, [esi + (ebx * 4)]        ; < == array[i]
     cmp       eax, ebx
     jle       IncJ                
                                             ; i = j
     mov       eax, [ebp-20]
     mov       [ebp-16], eax

IncJ:                                        ;Increment j before looping through Inner J-for-loop
     mov       eax, [ebp-20]
     inc       eax
     mov       [ebp-20],eax
     jmp       InnerJ


Exchange:                                    ; exchange(array[k], array[i])
     mov       eax, [ebp-24]                 ; k
     mov       eax, [esi + (eax * 4)]        ;  == array[k]
     mov       edx, eax                      ; temporary placement for exchange

     mov       eax, [ebp-16]                 ; i
     mov       ebx, [esi + (eax * 4)]        ; == array[i]
     mov       eax, [ebp-24]                 ; k
     mov       [esi + (eax * 4)], ebx        ; == array[k] = array[i]

     mov       eax, [ebp-16]
     mov       [esi + (eax * 4)], edx        ; < == array[i] = temp


IncK:
     mov       eax, [ebp-24]                 ;Increment k before looping through outer k-for-loop
     inc       eax
     mov       [ebp-24], eax
     jmp       OuterK


Sorted:
     add       esp, 12
     pop       edx                           ;Re-establish EDX/EBX/EAX/EBP to pre proc values
     pop       ebx
     pop       eax
     pop       ebp 

     ret
sortList ENDP



;- - - - - - median - - - - - - - - - - - - - - - - - - 
;Description - Finds and displays median of values in array
;Receives -  array, request
;Returns - median
;Preconditions - array must have numbers in it
;Registers Changed - n/a

median PROC

     push      ebp                           ;Save variable to stack for future re-establishment
     mov       ebp, esp
     push      eax
     push      ebx
     push      edx  



     mov       edx, [ebp+20]                 ;Tell user they're seeing the median
     call      WriteString
     mov       edx, [ebp+16]
     call      WriteString

     mov       esi, [ebp+8]                  ;point to beginning of array

     mov       eax, [ebp+12]                 ;First determine if odd/even number of items in array
     mov       edx, 0
     mov       ebx, 2
     div       ebx
     cmp       edx, 1
     je        Odd
     mov       ebx, eax                      ;Even valued array, we mean the two middle values
     dec       ebx
     mov       eax, [esi + (4 * eax)]        ;Value of two middle array values
     mov       ebx, [esi + (4 * ebx)]
     add       eax, ebx
     mov       ebx, 2
     mov       edx, 0
     div       ebx                           ;Find the mean
     cmp       edx, 1            
     je        Add1                          ; See if mean ends in .5, for rounding
     call      WriteDec
     jmp       Fin

Add1:
     inc       eax                           ; (Round up if mean ends in decimal >= .5)
     call      WriteDec
     jmp       Fin
     

Odd:                                         ;If odd number of values in array, just display middle value
     mov       eax, [esi + (eax * 4)]
     call      WriteDec


Fin:


     call      CrLf
     call      CrLf
     pop       edx                           ;Re-establish EDX/EBX/EAX/EBP to pre proc values
     pop       ebx
     pop       eax
     pop       ebp 

     ret
median ENDP



;- - - - - - validate - - - - - - - - - - - - - - - - - - 
;Description - Confirms that number input is within range stated
;Receives - request, accesses items already on the stack
;Returns - A valid number for request
;Preconditions - MIN and MAX must be defined
;Registers Changed - EAX

validate PROC

keepAsking:
     call      ReadInt                  ;Asked user for input, confirm within range of min/max
     cmp       eax, MIN       
     jl        wrongAnswer
     cmp       eax, MAX
     jle       rightAnswer


wrongAnswer:
     mov       edx, [ebp+20]            ;Input was incorrect
     call      WriteString
     call      CrLf
     mov       edx, [ebp+16]            ;ENTER NUMBER BETWEEN X AND Y:
     call      WriteString
     mov       eax, MIN
     call      WriteDec
     mov       edx, [ebp+12]
     call      WriteString
     mov       eax, MAX
     call      WriteDec
     mov       eax, 03Ah
     call      WriteChar
     mov       eax, 000h
     call      WriteChar
     jmp       keepAsking

rightAnswer:

     ret
validate ENDP

END main
