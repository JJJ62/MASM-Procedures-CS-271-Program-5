TITLE I/O     (I/O.asm)

; Author: Jawad Alamgir
; Description: CS271 Program 5
; Date: 08/06/2020
; Description:


INCLUDE Irvine32.inc

.data

;intro
intro_message			BYTE "I/O.asm low level I/O procedures "
						BYTE "coded by Jawad Alamgir", 0
instructions			BYTE "Please input 10 unsigned decimal integers.", 13, 10
						BYTE "Each value needs to be small enough to fit inside a "
						BYTE "32 bit register(0-2,147,483,647).", 13, 10
						BYTE "Once you have done so I will display the "
						BYTE "numbers you have input, find their sum ", 13, 10
						BYTE "and their average and finally display "
						BYTE "them.", 0

;prompts
input_prompt			BYTE "Please enter an integer: ", 0
input_prompt2			BYTE "Please try again: ", 0

;messages
error_message			BYTE "Invalid input. Either your input was not unisgned "
						BYTE "or too big.", 0
input_disp_msg			BYTE "You entered the following 10 numbers: ", 0
sum_message			    BYTE "Sum of 10 numbers: ", 0
average_message			BYTE "Average of 10 numbers: ", 0
outro_message			BYTE "Thank you for using my program. Bye!", 0

;misc
punctuation				BYTE ", ", 0
input_array				DWORD 10 DUP(?)

.code

;---------------------------------------------------
; Procedure name: Main
; Purpose: calls all the functions needed for the program to run
;---------------------------------------------------

main PROC

	;intro
	push	OFFSET		intro_message
	push	OFFSET		instructions
	call	intro

	;get input from user adn store in an array
	push	OFFSET		input_array
	push	LENGTHOF	input_array
	push	OFFSET		input_prompt
	push	OFFSET		input_prompt2
	push	OFFSET		error_message
	call	get_input

	;print the array filled with the 10 numbers input by the user
	push	OFFSET		input_array
	push	LENGTHOF	input_array
	push	OFFSET		input_disp_msg
	push	OFFSET		punctuation
	call	print_arr

	;display the sum and the average of the numbers input by the user
	push	OFFSET		input_array
	push	LENGTHOF	input_array
	push	OFFSET		sum_message
	push	OFFSET		average_message
	call	display_sum_avg

	;goobye message
	push	OFFSET		outro_message
	call	outro

exit

main ENDP

;---------------------------------------------------
; Macro name: get_string
; Purpose: Asks user to input a number and then store
;          user input into a memory location.
;---------------------------------------------------

get_string MACRO prompt_address, buffer, buffer_length

	push			edx
	push			ecx
	mov				edx, prompt_address
	call			WriteString
	mov				edx, buffer
	mov				ecx, buffer_length
	call			ReadString
	pop				ecx
	pop				edx

ENDM

;-----------------------------------------------------------
; Macro name: display_string
; Purpose: Prints string from the address passed to it
;-----------------------------------------------------------

display_string MACRO string_address

	push			edx
	mov				edx, string_address
	call			WriteString
	pop				edx

ENDM

;---------------------------------------------------
; Procedure name: intro
; Purpose: Displays the program intro to the user.
;--------------------------------------------------

intro PROC USES edx

	;set the stack pointer
	push			ebp
	mov				ebp, esp

	; print intro_message
	mov				edx, [ebp + 16]
	display_string	edx
	call			Crlf
	call			Crlf

	; print instructions
	mov				edx, [ebp + 12]
	display_string	edx
	call			Crlf
	call			Crlf
	pop				ebp
	ret				8

intro ENDP

;-----------------------------------------------------------
; Procedure name: get_input
; Purpose: stores user input in an array in integer form and
;		   validates it
;-----------------------------------------------------------

get_input PROC USES esi ecx eax

	;set the stack pointer
	push			ebp
	mov				ebp, esp
	; [ebp + 36] starting point of input_array
	mov				esi, [ebp + 36]
	mov				ecx, [ebp + 32]

;read from array
read:

	;input_propmt
	mov				eax, [ebp + 28]
	push			eax

	;input_propmt2 and error_message
	push			[ebp + 24]
	push			[ebp + 20]
	;read user input and validates it while converting it to int
	call			read_value

	;store value
	pop				[esi]
	add				esi, 4
	loop			read
	pop				ebp
	ret				20

get_input ENDP

;-------------------------------------------------------------
; Procedure name: read_value
; Purpose: reads user input and converts it to integer validating
;		   it
;-------------------------------------------------------------

read_value PROC USES eax ebx

	LOCAL			input[15]:BYTE, is_valid:DWORD

	push			esi
	push			ecx
	;input_prompt
	mov				eax, [ebp + 16]
	lea				ebx, input

;read value, check validity(hence convert it)
read:
	get_string eax, ebx, LENGTHOF input
	mov				ebx, [ebp + 8]
	push			ebx
	lea				eax, is_valid
	push			eax
	lea				eax, input
	push			eax

	;is_valid_input needs length of input
	push			LENGTHOF input
	call			isvalid_input
	pop				edx

	;store value after conversion
	mov				[ebp + 16], edx
	mov				eax, is_valid
	cmp				eax, 1
	mov				eax, [ebp + 12]
	lea				ebx, input
	jne				read
	pop				ecx
	pop				esi
	ret				8

read_value ENDP

;------------------------------------------------------------------------------
; Procedure Name: isvalid_input
; Purpose: Checks if entered string is an unsigned integer and can fit in 32 bit
;		   register
;------------------------------------------------------------------------------

isvalid_input PROC USES esi ecx eax edx

	LOCAL			too_large:DWORD

	;intialize index and counter
	mov				esi, [ebp + 12]
	mov				ecx, [ebp + 8]
	cld

;feeds string one byte at a time and checks if they are numbers
load_string:
	lodsb

	;checks if value is in the ascii range for integers
	cmp				al, 0
	je				string_to_int
	cmp				al, 48
	jl				error
	cmp				al, 57
	ja				error
	loop			load_string

error:

	;error_message
	mov				edx, [ebp + 20]
	display_string	edx
	call			Crlf

	;is_valid=0
	mov				edx, [ebp + 16]
	mov				eax, 0
	mov				[edx], eax
	jmp				before_end

;converts string to int and checks if it's within range of 32 bit register
string_to_int:
	mov				edx, [ebp + 8]

	;if input is empty
	cmp				ecx, edx
	je				error
	lea				eax, too_large
	mov				edx, 0
	mov				[eax], edx
	push			[ebp + 12]
	push			[ebp + 8]
	lea				edx, too_large
	push			edx
	call			convert_to_num
	mov				edx, too_large
	cmp				edx, 1
	je				error

	;is_valid = 1
	mov				edx, [ebp + 16]
	mov				eax, 1
	mov				[edx], eax

before_end:
	pop				edx
	mov				[ebp + 20], edx
	ret				12

isvalid_input ENDP

;----------------------------------------------------------------
; Procedure_name: convert_to_num
; Purpose: converts strign to int
;----------------------------------------------------------------

convert_to_num PROC USES esi ecx eax ebx edx

	LOCAL			val:DWORD

	; register and stack initalization
	mov				esi, [ebp + 16]
	mov				ecx, [ebp + 12]
	lea				eax, val
	xor				ebx, ebx
	mov				[eax], ebx
	xor				eax, eax
	xor				edx, eax
	cld

;feeds string one character at a time
load_digit:
	lodsb
	cmp				eax, 0
	je				stop_load
	sub				eax, 48
	mov				ebx, eax
	mov				eax, val
	mov				edx, 10
	mul				edx

	;carry check, add digit after conversion
	jc				outside_range
	add				eax, ebx
	jc				outside_range

	;store value of eax and set eax to 0
	mov				val, eax
	mov				eax, 0
	loop			load_digit

stop_load:
	mov				eax, val

	;move to stack after conversion
	mov				[ebp + 16], eax
	jmp				finish

;checks if value fits in 32 bit register
outside_range:

	;too_large
	mov				ebx, [ebp + 8]
	mov				eax, 1
	mov				[ebx], eax
	mov				eax, 0
	mov				[ebp + 16], eax

finish:
	ret				8

convert_to_num ENDP

;----------------------------------------------------------
; Procedure_name: print_arr
; Purpose: prints values in an array
;----------------------------------------------------------

print_arr PROC USES esi ebx ecx edx

	push			ebp
	mov				ebp, esp

	;print array title
	call			Crlf

	;input_disp_message
	mov				edx, [ebp + 28]
	display_string	edx
	call			Crlf
	mov				esi, [ebp + 36]
	mov				ecx, [ebp + 32]

	;set counter to 1
	mov				ebx, 1

;prints value
print:
	push			[esi]
	call			writeVal
	add				esi, 4
	cmp				ebx, [ebp + 32]

	; no punctuation after final number
	jge				finish

	;punctuation after every other number
	mov				edx, [ebp + 24]
	display_string	edx
	inc				ebx
	loop			print

finish:
	call			Crlf
	pop				ebp
	ret				16

print_arr ENDP

;-----------------------------------------------------------
; Procedure_name: writeVal
; Purpose: converts integer to string and prints it
;----------------------------------------------------------

writeVal PROC USES eax

	LOCAL			result[11]:BYTE

	lea				eax, result
	push			eax
	push			[ebp + 8]
	call			convert_to_string ; call the procedure convert_to_string
	lea				eax, result
	display_string	eax ; print the value
	ret				4

writeVal ENDP

;-----------------------------------------------------------
; Procedure name: convert_to_string
; Purpose: changes integer to string
;-----------------------------------------------------------

convert_to_string PROC USES eax ebx ecx

	LOCAL temp:DWORD

	;initialization of registers
	mov				eax, [ebp + 8]
	mov				ebx, 10
	mov				ecx, 0
	cld

;counts value of numbers and moves them to stack in opposite sequence
divide:
	cdq
	div				ebx
	push			edx
	inc				ecx
	cmp				eax, 0
	jne				divide

	;move to array
	mov				edi, [ebp + 12]

;saves character in array
save:
	pop				temp
	mov				al, BYTE PTR temp
	add				al, 48
	stosb
	loop			save
	mov				al, 0
	stosb
	ret				8

convert_to_string ENDP

;------------------------------------------------------------------------------
; Procedure name: display_sum_avg
; Purpose: Prints sum and average of array
;------------------------------------------------------------------------------

display_sum_avg PROC USES esi edx ecx eax ebx

; set the stack frame
	push			ebp
	mov				ebp, esp

	;sum_message
	mov				edx, [ebp + 32]
	display_string	edx

	;input_array
	mov				esi, [ebp + 40]

	; LENGTHOF input_array
	mov				ecx, [ebp + 36]

	;clear flags
	xor				eax, eax

;add
sum:
	add				eax, [esi]
	add				esi, 4
	loop			sum

	; print sum
	push			eax
	call			writeVal
	call			Crlf

	;calculate and display average
	;average_message
	mov				edx, [ebp + 28]
	display_string	edx
	cdq

	;LENGTHOF input_array
	mov				ebx, [ebp + 36]
	div				ebx
	push			eax

	;print value
	call			writeVal
	call			Crlf
	pop				ebp
	ret				16

display_sum_avg ENDP

;---------------------------------------------------------------
; Procedure name: outro
; Purpose: displays goodbye message
;---------------------------------------------------------------

outro PROC USES edx

	push			ebp
	mov				ebp, esp
	call			Crlf

	;outro_message
	mov				edx, [ebp + 12]
	display_string	edx
	call			Crlf
	pop				ebp
	ret				4

outro ENDP

END main
