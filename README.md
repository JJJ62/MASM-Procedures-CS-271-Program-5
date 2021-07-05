# MASM-Procedures-CS-271-Program-5

Problem Definition:

  •Implement and test your own ReadValand WriteVal procedures for unsigned integers.
  •Implement macros getString and displayString. The macros may use Irvine’s ReadString to get input from the user, and WriteString      to display output.  
    o getString should display a prompt, then get the user’s keyboard input into a memory location 
    o displayString should display the string stored in a specified memory location.  
    o readVal should invoke the getStringmacro to get the user’s string of digits.  It should then convert the digit string to             numeric,     while validating the user’s input.
    o writeVal should convert a numeric value to a string of digits, and invoke the displayString macro to produce the output.
  •Write a small test program that gets 10 valid integers from the user and stores the numeric values in an array.  The program then    displays the integers, their sum, and their average.

Requirements:
  1) User’s numeric input must be validated the hard way: Read the user's input as a string, and convert the string to numeric form.      If the user enters non-digits or the number is too large for 32-bit registers, an error message should be displayed and the          number should be discarded.
  2) Conversion routines must appropriately use the lodsb and/or stosb operators.
  3) All procedure parameters must be passed on the system stack.
  4) Addresses of prompts, identifying strings, and other memory locations should be passed by address to the macros.  
  5) Used registers must be saved and restored by the called procedures and macros.
  6) The stack must be “cleaned up” by the called procedure.
  7) The usual requirements regarding documentation, readability, user-friendliness, etc., apply
