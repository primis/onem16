jmp 0x7C00:start    ; Skip our data area

;=========[ Data Section ]============================================================================

;---------[ Messages, Prompts, Etc ]---------------------------------;
welcome   db 'welcome to onem16!', 0x0D, 0x0A                        ; The Welcome message
          db 'please close the door when you leave.', 0x0D, 0x0A, 0  ; It spans two lines.
prompt    db '>>', 0                                                 ; The system prompt.
;--------------------------------------------------------------------; 


;---------[ Keyboard Variables ]-------------------------------------;
kbdus     db 0, 27, '1234567890-=', 8, 11, 'qwertyuiop[]', 10, 0     ; Entries for the xlat!
          db 'asdfghjkl;', 39, '`', 0, 92, 'zxcvbnm,./', 0, '*', 0,  ;
          db ' ', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ; Most of these are 0's
          db 0, 0, 0, '-', 0, 0, 0, '+', 0, 0, 0, 0, 0, 0, 0, 0, 0   ; But thats too bad :P
          db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0    ; Oh well, keep going.
          db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0    ; Wow this is long...
          db 0, 0, 0, 0                                              ; Ah, finally done :D.
key_buff  times 128 db 0                                             ; Keyboard buffer
last_key  db 0                                                       ; Last key in buffer
;--------------------------------------------------------------------;

;=========[ Code Section ]============================================================================

;-----[ start, entry point ]-----;
start:                           ;
   mov ax, 07C0h                 ; mov the segment to 2000
   mov ds, ax                    ; Data segment 0
   mov si, welcome               ; Source index is now a pointer to the welcome message
   call print_string             ; Print the string
   cli                           ; No interruptions!
   mov bx, 0x09                  ; Hardware interrupt Number for Keyboard
   shl bx, 2                     ; Multiply by 4
   xor ax, ax                    ; Zero it out
   mov gs, ax                    ; Start of memory
   mov [gs:bx], word kb_handler  ; Move the function there  
   mov [gs:bx+2], ds             ; And its segment
   sti                           ; Restore interrupts
   mov ax, 07C0h                 ; lets fix up gs...
   mov gs, ax                    ; Its better this way...
   mov es, ax                    ; While we're at it...
   mov fs, ax                    ; Lets get all the segments
   jmp main                      ; Jump to the main loop
;--------------------------------;

;-----[ main hang, CLI etc ]-----;
main:                            ;
   jmp $                         ; loop dat empty loop!
;--------------------------------;

;-----[ parse command ]-----;
exec_command:               ; not in use yet
;---------------------------;

;-----[ get the keyboard input ]-----;
kb_handler:                          ; not a dummy function :3
   pusha                             ; Push all registers onto the stack
   in al, 0x60                       ; Read the scancode from the keyboard
   cmp al, 0x80                      ; See if the key is being pressed or released
   jae .done                         ; If its being released, we don't care, end early
   mov bx, kbdus                     ; Set up for the xlat
   xlat                              ; Exchange the scancode for its ascii interpretation  
   mov ah, 0x0E                      ; Using the teletype function in BIOS
   cmp al, 10                        ; See if its enter
   jne .print                        ; If it is, we need a bit more to our output
   mov bl, al                        ; Temp spot here
   mov al, 13                        ; Carraige return 
   int 0x10                          ; Write it
   mov al, bl                        ; Put our original charecter back
.print:                              ; Printing sub routine
   int 0x10                          ; Print dat char
   mov bx, key_buff                  ; Move BX to the keyboard buffer
   add bx, last_key                  ; Add to current pointer
   mov [bx], al                      ; Put the ascii code there
   mov ax, last_key                  ; Get the key pointer
   inc ax                            ; Increment the last key pointer
   mov [last_key], ax                ; Put the key back 
 .done:                              ; We're all set, clean up
   mov al, 0x20                      ; Prepare to tell the PIC (programmable interrupt contoller)
   out 0x20, al                      ; Tell the PIC that the interrupt is finished
   popa                              ; Put our registers back
   iret                              ; Return from the interrupt
;------------------------------------;

;-----[ get a charecter from input ]--------------;
getchar:                                          ;
   pusha                                          ; Push all our registers
   xor ax, ax                                     ; Here's a fun trick:
   cmp ax, last_key                               ; We can wait for the buffer to be empty
   je getchar                                     ; By checking if the last key is 0
   cli                                            ; We have controll over the buffer now, keep it that way!
   xor cl, cl                                     ; CX acts as a counter
   mov si, key_buff                               ; Put our key_buffer here 
   mov di, si                                     ; Copy Source to data
   inc si                                         ; Increment the source
 .copy:                                           ; Start of a loop
   lodsb                                          ; Load from si
   stosb                                          ; Store to di
   inc si                                         ; Increment source pointer
   inc di                                         ; Increment destination pointer
   dec cl                                         ; Decrement Counter
   cmp cl, [last_key]                             ; Check to see if we hit the end yet
   jne .copy                                      ; If not, reiterate
   sti                                            ; If so, restore interrupts
   popa                                           ; Restore our registers
   mov al, [key_buff]                             ; Move the contents of the key buffer to ax
   ret                                            ; Return
;-----[ print_string, message location = si ]-----;
print_string:                                     ;
   lodsb                                          ; Grab a byte from our data source (message)
   or al, al                                      ; zero=end of string
   jz .done                                       ; get out
   mov ah, 0x0E                                   ; tell BIOS we want to use the Teletype function
   int 0x10                                       ; tell BIOS to run the function
   jmp print_string                               ; Jump to the start
.done:                                            ; All finished, closing up shop
   ret                                            ; Return to calling code
;-------------------------------------------------;