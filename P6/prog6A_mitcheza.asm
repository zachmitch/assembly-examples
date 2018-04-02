TITLE String-2-uInt - Assignment 6A     (prog6A_mitcheza.asm)

; Author:  Zach mitchell mitcheza@oregonstate.edu
; Course / Project ID:  CS271-400, Assignment 6A  Date: 3/3/2018, Due: 3/18/18
; Description: Takes in a string, parses for integer, converts to int and then
; does maths with those ints, then doing the opposite conversion

INCLUDE Irvine32.inc

;Constants

     ARRAY_LEN = 10

;Macros




     displayString MACRO text:REQ          ;Prints passed OFFSET text to console
   
          push      edx                      ;save registers

          mov       edx, text                ;Print passed string
          call      WriteString

          pop       edx                      ;re-establish register
     ENDM

     getString MACRO prompt:REQ, memLoc:REQ, maxChar:REQ    ;reads in user data 

          push      ecx                      ;save registers
          push      edx

          displayString prompt               ;Display prompt

          mov       edx, memLoc              ;Read user input
          mov       ecx, maxChar
          call      ReadString

          pop       edx                      ;re-establish registers
          pop       ecx

     ENDM

.data

     intro          BYTE      "Welcome to 'String-2-uInt, Assignment 6A' by Zach Mitchell",10,13,0
     intro2         BYTE      "Please provide me 10 unsigned integers, each small enough to fit inside a 32-bit register.",10,13,0
     intro3         BYTE      "At which point, I will display the list of acceptable ints, their sum, and average.",10,13,10,13,0
     gimmeNum       BYTE      "ENTER AN UNSIGNED INT: ",0
     incorrect      BYTE      "SORRY, EITHER TOO BIG, NEGATIVE, OR NOT AN INT.  TRY AGAIN.",10,13,0
     intArray       DWORD     ARRAY_LEN DUP(?)   ;Will hold valid user input integers
     listEm         BYTE      "HERE ARE THE NUMBERS YOU ENTERED CORRECTLY:",10,13,0
     sumEm          BYTE      "THEIR SUM IS: ",0
     avgEm          BYTE      "THEIR AVG IS: ",0
     goodBye        BYTE      "Later alligator!",10,13,0
     spacer         BYTE      ", ",0
     stagingInt     BYTE      12 DUP(0)   ;Will be a 'staging' area (buffer) to validate input,
     curArray       DWORD     0    ; The current position in the array
     accumulator    DWORD     0    ; Will use as an accumulator during conversion from char to int
     sumArr         DWORD     0    ; Sum of all numbers in array, will be in unsigned integer form
     avgArr         DWORD     ?    ; Avg of all numbers in array, will be in unsigned int form

.code
main PROC


     ; Introduction - Introduce the program/mer and explain to user what to do

     push      OFFSET intro3        
     push      OFFSET intro2
     push      OFFSET intro
     call      introduction



     ; gatherNumbers - calls the readVal procedure (nested) to gather items for an array of uints

     push      OFFSET accumulator        
     push      curArray            
     push      OFFSET gimmeNum     
     push      OFFSET incorrect
     push      OFFSET stagingInt
     push      OFFSET intArray
     call      gatherNumbers

    ; maths - calculates the sum and avg of int array

     push      OFFSET accumulator
     push      OFFSET sumArr
     push      OFFSET avgArr
     push      OFFSET intArray
     call      maths

                              
     ; deliverNumbers - calls the writeVal procedure (nested) to show that we can write uints as strings

     push      OFFSET stagingInt
     push      OFFSET spacer
     push      OFFSET listEm
     push      OFFSET sumEm
     push      OFFSET avgEm
     push      OFFSET goodBye
     push      sumArr
     push      avgArr
     push      OFFSET intArray
     call      deliverNumbers

	exit	; exit to operating system

main ENDP


;- - - - - - introduction - - - - - - - - - - - - - - - - - - 
;Description - Introduce program/mer to user, explain the gist of program
;Receives - intro,intro2,intro3
;Returns - N/A
;Preconditions - N/A 
;Registers Changed - N/A

introduction PROC

     push      ebp                      ; Save register contents & setup ebp to reach
     mov       ebp, esp                 ; passed stack params

     displayString [ebp+8]              ;"Welcome to..."

     displayString [ebp+12]             ;"Please enter 10..."

     displayString [ebp+16]             ;"At which point I will..."

     
     pop       ebp
     ret 12
introduction ENDP



;- - - - - - readVal - - - - - - - - - - - - - - - - - - 
;Description - Reads in a string from user, validates its an integer within range, converts to uint
;Receives - OFFSET gimmeNum, OFFSET incorrect, stagingInt, accumulator
;Returns - valid unsigned integer in accumulator
;Preconditions - Pass parameters to readVal in order shown in 'Receives' above
;Registers Changed - N/A 

readVal PROC
     push      ebp                           ;Save registers as they will be affected
     mov       ebp, esp
     pushad

  GetInts:

     mov       eax, [ebp+8]                  ;Clear accumulator
     mov       ebx, 0
     mov       [eax], ebx

                                             ;"Please enter an unsigned int""
     getString [ebp+20], [ebp+12], 12        ;Take in user input to 'staging variable' for validation

  ValidateInput:
     
     mov       esi, [ebp+12]                 ;Check each char of input string, starting with first char of buffer (stagingInt)
     mov       eax, 0                        ; Setup the ability to check each character
     mov       ecx, 12                      
     cld

  Char2Int:
     mov       eax, 0                        ;Clear eax
     lodsb                                   ;See if ASCII value of each char input is 48 <= x <= 57
     cmp       al, 48
     jl        IsZero                        ;Check for null terminator
     cmp       al, 57
     jg        WrongAnswer                   ;If larger than 57 ASCII (9), we have incorrect input
     jmp       Conversion

  IsZero:                                    ;See if ACII value is a 0, as that is the only non digit we will
                                             ; accept out of range.  Once we reach zero, clear buffer (stagingInt)
     cmp       al, 0
     jne       WrongAnswer
     jmp       ZeroClear                     ;ZeroClear - Usually this is how we exit our Char2Int loop, hitting a null terminator

  Conversion:                                ;Convert validated char into an integer, using pseudocode formula from Lecture #23, slide 3
     mov       ebx, 0
     mov       bl, al
     mov       eax, 10                       ; multiply 10 * x (from slide), equivalent here to 10 * accumulator
     push      ecx
     mov       ecx, [ebp+8]                  ; need the ecx register for quick maths, so we push an pop it to save contents
     mov       ecx, [ecx]
     clc                                     ;Clear carry flag, we want to see if we are over capacity
     mul       ecx
     pop       ecx
     jc        WrongAnswer                   ;If carry flag is tripped, we have a value that is too large


     sub       bl, 48                        ;Convert from ascii -> digit
     add       eax, ebx                      ; add to accumulator

     mov       ebx, [ebp+8]
     mov       [ebx], eax                    ;Save accumulator
     loop      Char2Int

  WrongAnswer:
     mov       ebx, -1                       ;Set -1 so we can check later to see if input was correct
     displayString [ebp+16]                  ;Let user know they did it wrong

  ZeroClear:                                 ;Resource: https://stackoverflow.com/questions/29003106/x86-masm-assembly-empty-variable-that-holds-a-string
     mov       edi, [ebp+12]                 ;Clear our staging variable with all zeros
     mov       ecx, 12

  ZeroCont:                                  ;Zero out the staging buffer, stagingInt
     mov       al, 0
     stosb                                   ; All positions of string will be 0 now
     loop      ZeroCont

     cmp       ebx, -1                       ;Check to see if input was correct
     jne       Correct                       ;We jump here to avoid decrementing the ecx loop counter below in "Correct"
     jmp       GetInts

  Correct:

     popad                                   ;re-establish registers
     pop       ebp

     ret 16
readVal ENDP




;- - - - - - writeVal - - - - - - - - - - - - - - - - - - 
;Description - Takes in a 32-bit unsigned int, converting it to a string of digits printing result to console
;Receives - uint, staging int
;Returns - output to console -> string
;Preconditions - integer must be positive and fit within 32-bit register
;    Pass parameters as shown in 'Returns'
;Registers Changed - N/A

writeVal PROC
     push      ebp                           ;Save registers
     mov       ebp, esp
     pushad

     mov       eax, [ebp+12]                 ; Setup integer, we are going to div by 10
     mov       ebx, 10                       ; iteratively to get our string and must first
     mov       ecx, 0                        ; determine its length
     mov       edx, 0

  Div4Length:                                ; Div4Length, will divide until we get a 
     div       ebx                           ; quotient of zero in eax. At which point,
     inc       ecx                           ; Length will be in ecx register
     mov       edx, 0
     cmp       eax, 0
     je        BufferSetup
     jmp       Div4Length


  BufferSetup:
     std                                      ; Taking the remainder each division, so we go backwards (std)
     mov       edi, [(ebp+8)]                 ; Set edi to last position of strength
     add       edi, ecx
     dec       edi
     mov       eax, [ebp+12]

  Push2Buffer:
     div       ebx                            ; Find the remainder
     push      eax                            
     mov       eax, 0
     mov       al, dl                         ; Put remainder in position to push to string, convert to ascii
     add       al, 48
     mov       edx, 0                         ; Clear edx for future divs
     stosb                                    ; Place char in the string at position, decrement edi
     pop       eax
     loop      Push2Buffer                    ; Loop the entire length of string, back to front

  displayString [ebp+8]                       ;Output to screen
     

  ZeroClear:                                 ;Resource: https://stackoverflow.com/questions/29003106/x86-masm-assembly-empty-variable-that-holds-a-string
     mov       edi, [ebp+8]                  ;Clear our staging variable buffer with all zeros
     mov       ecx, 11

  ZeroCont:                                  ;Zero out the staging buffer, stagingInt
     mov       al, 0
     stosb                                   ; All positions of string will be 0 now
     loop      ZeroCont

     popad                                   ;Re-establish registers
     pop       ebp
     ret 8
writeVal ENDP


;- - - - - - gatherNumbers - - - - - - - - - - - - - - - - - - 
;Description - Invokes the readVal method the number of times needed, passing string and mem location to readVal
;Receives - curArray, OFFSET gimmeNum, OFFSET incorrect, OFFSET stagingInt, OFFSET intArray
;Returns - Array filled with validated uints
;Preconditions - N/A
;Registers Changed - N/A

gatherNumbers PROC
     push      ebp
     mov       ebp, esp
     pushad

     mov       ecx, ARRAY_LEN                     ;Set our count equal to length of array

  GetN:
     push      [ebp+20]                           ;push on to stack:  gimmeNum, incorrect, stagingInt, accumulator (in this order)
     push      [ebp+16]
     push      [ebp+12]
     push      [ebp+28]
     call      readVal                            ;Take in string, validate it, convert to number which will reside in accumulator afterward

 PlaceInArray:                                    ;Place converted integer into array

     mov       esi, [ebp+8]                       ;Setup access to front of intArray
     mov       eax, [ebp+24]                      ;Setup array position and current integer for array placement
     mov       ebx, [ebp+28]
     mov       ebx, [ebx]

     mov       [esi + (4 * eax)], ebx             ; Place integer in the array at correct position

     mov       eax, [ebp+24]                      ;Increment current position in array
     inc       eax
     mov       [ebp+24], eax

     loop      GetN                               ;loop until array is filled
     call      CrLf

     popad
     pop       ebp                                ;re-establish registers
     ret 24
gatherNumbers ENDP


;- - - - - - maths - - - - - - - - - - - - - - - - - - 
;Description - Avgs/Sums the total of the array, outputting to screen and saying goodbye to user
;Receives - accumulator, sumArr, avgArr, intArr
;Returns - sumArr, avgArr will have respective correct numbers in int form
;Preconditions - must have ints in the array passed, params must be in order seen in 'receives'
;Registers Changed - N/A

maths PROC

     push      ebp                           ;save the regs
     mov       ebp, esp
     pushad

     mov       eax, 0                        ;Clear the accumulator
     mov       [ebp+20], eax

     mov       esi, [ebp+8]                  ;Point to front of array
     mov       ecx, ARRAY_LEN                ; # of items in array

  AddArray:
     mov       ebx, ecx
     dec       ebx
     add       eax, [esi + (4 * ebx)]        ;Sum up all integers
     loop      AddArray


     mov       edx, [ebp+16]                 ;Save sum in sumArr
     mov       [edx], eax

     mov       edx, 0                        ;Divide by # of array items to find avg
     mov       ebx, ARRAY_LEN
     div       ebx
     mov       edx, [ebp+12]                 ;Save avg in avgArr
     mov       [edx], eax

     popad                                   ;re-establish regs
     pop       ebp
     ret 16
maths ENDP



;- - - - - - deliverNumbers - - - - - - - - - - - - - - - - - - 
;Description - Invokes the writeVal procedure, displaying the array, sum and avg of array
;Receives - stagingInt, spacer, listEm, sumEm, avgEm, goodBye, sumArr, avgArr, intArr
;Returns - Prints inputs to screen
;Preconditions - must have ints in the array passed, params must be in order seen in 'receives'
;Registers Changed - N/A

deliverNumbers PROC
     push      ebp                 ;Save Registers
     mov       ebp, esp
     pushad

     displayString [ebp+32]        ;"Here are your numbers.."

     mov       ecx, ARRAY_LEN      ;Setup counter for length of array 
     mov       esi, [ebp+8]        ;Point to beginning of array

  PrintArray:
     push      [esi]               ;Print value in each array position
     push      [ebp+40]
     call      writeVal            ; Invoking writeVal, makes uint a string, and prints it

     cmp       ecx, 1              ; Don't want a comma on last list item
     je        NoComma
     displayString [ebp+36]

   NoComma:

     add       esi, 4              ;traverse the array until finished
     loop      PrintArray
     call      CrLf
     call      CrLf

     
     displayString  [ebp+28]       ;Prints sum of digits
     push      [ebp+16]
     push      [ebp+40]
     call      writeVal
     call      CrLf
     call      CrLf


     displayString  [ebp+24]       ;Prints avg of digits
     push      [ebp+12]
     push      [ebp+40]
     call      writeVal
     call      CrLf
     call      CrLf


     displayString [ebp+20]        ;Say goodbye to user
     call      CrLf
     call      CrLf


     popad
     pop       ebp                 ;Re-establish registers
     ret 36
deliverNumbers ENDP



END main









