;=====================================================================================================;
;                                  2011 Onem16 Developers Presents:                                   ;
;                          The Onem16 Kernel - keyboard.asm - Keyboard functions                      ;
;                                  Keyboard interrupt, and functions                                  ; 
;=====================================================================================================;

;---------[ Keyboard Variables ]-------------------------------------;
kbdus     db 0, 27, '1234567890-=', 8, 11, 'qwertyuiop[]', 10, 0     ; Entries for the xlat!
          db 'asdfghjkl;', 39, '`', 0, 92, 'zxcvbnm,./', 0, '*', 0,  ;
          db ' ', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ; Most of these are 0's
          db 0, 0, 0, '-', 0, 0, 0, '+', 0, 0, 0, 0, 0, 0, 0, 0, 0   ; But thats too bad :P
          db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0    ; Oh well, keep going.
          db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0    ; Wow this is long...
          db 0, 0, 0, 0                                              ; Ah, finally done :D.
key_buff  times 128 db 'a'                                           ; Keyboard buffer
last_key  db 0                                                       ; Last key in buffer
wait_key  db 0                                                       ; Used in getchar
;--------------------------------------------------------------------;


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
   mov bx, key_buff                  ; Move the key buffer to bx
   xor cx, cx                        ; Make it zero!
   mov cl, byte [last_key]           ; Stuff goes here...
   add bx, cx                        ; Add to current pointer
   mov [bx], al                      ; Put the ascii code there
   inc byte [last_key]               ; Increment the last key pointer
 .done:                              ; We're all set, clean up
   mov al, 0x20                      ; Prepare to tell the PIC (programmable interrupt contoller)
   out 0x20, al                      ; Tell the PIC that the interrupt is finished
   popa                              ; Put our registers back
   iret                              ; Return from the interrupt
;------------------------------------;

;-----[ get a charecter from input ]--------------;
getchar:                                          ; Input nothing, Output al = charecter
   pusha                                          ; Push all our registers
   cld                                            ; Make sure stosb and lodsb increment DI and SI respectivly 
.check:                                           ; Wait for buffer to have a key
   xor al, al                                     ; Here's a fun trick:
   cmp al, byte [last_key]                        ; We can wait for the buffer to be empty
   je .check                                      ; By checking if the last key is 0
   mov dl, byte [key_buff]                        ; Retreive the charecter
   mov byte [wait_key], dl                        ; We store the char here
   cli                                            ; We have controll over the buffer now, keep it that way!
   xor cx, cx                                     ; We need CX to be empty
   mov cl, byte [last_key]                        ; Move the length to our counter
   mov di, key_buff                               ; Data index points to the buffer start
   lea si, [di+1]                                 ; load the address of Data index to source index +1
   rep movsb                                      ; mov a byte from si to di until cx = 0
   dec byte [last_key]                            ; Decrement the number of keys by one
   sti                                            ; Restore interrupts
   popa                                           ; Restore our registers
   mov al, byte [wait_key]                        ; Move the contents of the key buffer to al
   ret                                            ; Return
;-----[ get a string from input ]-----------------;
gets:                                             ; Input SI = String Pointer
   pusha                                          ; Put all registers on stack
   mov di, si                                     ; We're gonna use di
    .get:                                         ; Get a charecter
   call getchar                                   ; We're getting one charecter here
   cmp al, 10                                     ; See if we hit an enter
   je .done                                       ; If we did, finish
   stosb                                          ; Store the byte
   jmp .get                                       ; Keep going
 .done                                            ; Finished now, clean up
   xor ax, ax                                     ; zero it out
   stosb                                          ; Store our null
   popa                                           ; Return everything to normal
   ret                                            ; All done
;-----[ wait for a key to be pressed ]------------;
waitkey:                                          ; Input nothing, Output nothing
   pusha                                          ; Put all registers on stack
   call getchar                                   ; Call getchar to wait for a keypress
   popa                                           ; All done, pop all our registers
   ret                                            ; Return
;-------------------------------------------------;