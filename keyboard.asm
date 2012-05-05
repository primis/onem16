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
kbdus_s   db 0, 27, '!@#$%^&*()_+', 8, 9, 'QWERTYUIOP{}', 10, 0      ; Shifted QWERTY 
	      db 'ASDFGHJKL:"~', 0,	'|ZXCVBNM<>?', 0, '*', 0, ' ', 0     ; This one is different from the one above
	      db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '7', '8', '9', 0    ; I'm not gonna do a caps lock though
	      db '4', '5', '6', 0, '1', '2', '3', '0', 0, 0, 0, 0, 0, 0  ; no need really
	      db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ; OK almost done now
	      db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ; yep, here it is
key_buff  times 128 db 'a'                                           ; Keyboard buffer
last_key  db 0                                                       ; Last key in buffer
wait_key  db 0                                                       ; Used in getchar
spec_key  db 0                                                       ; Special keys, (shift, ctrl, alt, caps, num, scroll)
caps_lock db 0                                                       ; Caps lock
num_lock  db 0                                                       ; Num Lock
scrl_lock db 0                                                       ; Scrol Lock
;--------------------------------------------------------------------;


;-----[ get the keyboard input ]-----;
kb_handler:                          ; not a dummy function :3
   pusha                             ; Push all registers onto the stack
   in al, 0x60                       ; Read the scancode from the keyboard
   jmp .specialkey                   ; Check for special keys
   je .done                          ; If any are found, jump to end
.compare:                            ; Making sure we are using the right key, down, not up.
   cmp al, 0x80                      ; See if the key is being pressed or released
   jae .done                         ; If its being released, we don't care, end early
   mov bl, byte [spec_key]           ; Get ready for some and'ing!
   and bl, 10000000b                 ; See if shift is there
   cmp bl, 0                         ; See if shift is down
   ja .shift_cnv                     ; If its set, jusmp to shift convert
   mov bx, kbdus                     ; Set up for the xlat
.convert:                            ; Convert to ascii here
   xlat                              ; Exchange the scancode for its ascii interpretation  
   mov bx, key_buff                  ; Move the key buffer to bx
   xor cx, cx                        ; Make it zero!
   mov cl, byte [last_key]           ; Stuff goes here...
   add bx, cx                        ; Add to current pointer
   mov [bx], al                      ; Put the ascii code there
   inc byte [last_key]               ; Increment the last key pointer
.done:                               ; We're all set, clean up
   mov al, 0x20                      ; Prepare to tell the PIC (programmable interrupt contoller)
   out 0x20, al                      ; Tell the PIC that the interrupt is finished
   popa                              ; Put our registers back
   iret                              ; Return from the interrupt
.shift_cnv:                          ; Shift is down, use the shifted table
   mov bx, kbdus_s                   ; Moving into BX
   jmp .convert                      ; Go to our conversion
.specialkey:                         ; Are there any special keys down?
   mov bl, byte [spec_key]           ; Move our special keys variable into bx            
   cmp al, 0x36                      ; Is shift down?
    je .shift_d                      ; Jump to shift
   cmp al, 0x2A                      ; Is shift down?
    je .shift_d                      ; Jump to shift
   cmp al, 0xB6                      ; Is shift up?
    je .shift_u                      ; Jump to shift
   cmp al, 0xAA                      ; Is shift up?
    je .shift_u                      ; Jump to shift
   cmp al, 0x1D                      ; Ctrl down
    je .ctrl_d                       ; Jump to the code
   cmp al, 0x9D                      ; Ctrl up
    je .ctrl_u                       ; Jump to the code
   cmp al, 0x38                      ; Alt Pressed
    je .alt_d                        ; Jump to the code
   cmp al, 0xB8                      ; Alt Released
    je .alt_u                        ; Jump to the code
   cmp al, 0x3A                      ; Caps Lock Down
    je .caps_d                       ; Jump to the code
   cmp al, 0x45                      ; Number Lock Down
    je .num_d                        ; Jump to the code
   cmp al, 0x46                      ; Scroll Lock Down
    je .scrl_d                       ; Jump to the code
   cmp al, 0xBA                      ; Caps Lock released
    je .done                         ; Skip to the end
   cmp al, 0xC5                      ; Number Lock released
    je .done                         ; Skip to the end
   cmp al, 0xC6                      ; Scroll Lock was released
    je .done                         ; Skip to the end
   cmp al, 0xE0                      ; The first code to the right alt and ctrl
    je .done                         ; Skip to the end
   jmp .compare                      ; If nothing was changed, we go back to our normally scheduled programming (yes that is the correct terms :D)
.shift_d:                            ; This is shift down code
    or bl, 10000000b                 ; We OR the shift bit here
    mov byte [spec_key], bl          ; Then we put it back to the variable
    jmp .done                        ; Jump to end of interrupt.
.shift_u:                            ; Shift Up Code
    and bl, 01111111b                ; We AND bl with every bit except the shift one
    mov byte [spec_key], bl          ; Then we put bl in the special key var
    jmp .done                        ; Jump to end of interrupt.
.ctrl_d:                             ; Ctrl down
    or bl, 01000000b                 ; Same as shift, cept we move it over one
    mov byte [spec_key], bl          ; How about a poem to pass the lines?
    jmp .done                        ; I found a pretty bookmark
.ctrl_u:                             ; As sweet as it can be
    and bl, 10111111b                ; Was in the middle of the park
    mov byte [spec_key], bl          ; And on the ground you see!
    jmp .done                        ; Whenever I am reading
.alt_u:                              ; It only wants to show
    or bl, 00100000b                 ; Exactly where I’ve been
    mov byte [spec_key], bl          ; And where I want to go!
    jmp .done                        ; Don’t touch my little bookmark
.alt_d:                              ; Or take it from its home
    and bl, 11011111b                ; For I will only read again
    mov byte [spec_key], bl          ; The pages that I know
    jmp .done                        ; Yup.
.caps_d:                             ; Still got more lines to kill
    not byte [caps_lock]             ; How about some computer related quotes?  
    call .update_led                 ; "Never trust a computer you can't throw out a window."
    jmp .done                        ;  - Steve Wozniak
.num_d:                              ; "Hardware: The parts of a computer system that can be kicked."
    not byte [num_lock]              ;  - Jeff Pesis
    call .update_led                 ; "There are two major products that come out of Berkeley: LSD and BSD.
    jmp .done                        ; We don't believe this to be a coincidence."
.scrl_d:                             ;  - Jeremy S. Anderson
    not byte [scrl_lock]             ; "Good code is its own best documentation."
    call .update_led                 ;  - Steve McConnell
    jmp .done                        ; Ok Back to reality here;
.update_led:                         ; Update the keyboard LED's
    xor bl, bl                       ; First we make bl 0
    mov cl, byte [caps_lock]         ; Then we move the caps lock to cl
    and cl, 0x04                     ; AND it with 0x04 to leave only one bit on (third bit)
    add bl, cl                       ; If anything is left, it gets added to bl
    mov cl, byte [num_lock]          ; Now the same thing with num_lock
    and cl, 0x02                     ; 0x02 with Number Lock (second bit)
    add bl, cl                       ; Belive it or not, the update_led routine is very fast.
    mov cl, byte [scrl_lock]         ; Only 30 clock cycles when keyboardloop isn't blocked.
    and cl, 0x01                     ; Can be slower of course...
    add bl, cl                       ; Worst case is about 50 cycles waiting for the keyboard controller.
    call .keyboardloop               ; Now we request the keyboard controller
    mov al, 0xED                     ; Here we tell it "Yo! we have status bits for your led's!"
    out 0x60, al                     ; We send it to the chip here
    call .keyboardloop               ; We wait for it to understand us, its for precautionary sake
    mov al, bl                       ; Here we move the status bits to al to be sent
    out 0x60, al                     ; And lastly, we send it down the line to the keyboard controller
    ret                              ; Then we return.
.keyboardloop:                       ; This subfunction waits for the keyboard controller to be ready
    push ax                          ; We use ax in this function, but we also need it in the parent function
    in al, 0x64                      ; We request the keyboards status bits here
    and al, 2                        ; Second bit is basically the keyboard saying "I'm busy"
    cmp al, 0                        ; We check if it's set
    ja .keyboardloop                 ; If so, we just loop again.
    pop ax                           ; Otherwise, we're done, get out of here
    ret                              ; Return to parent function
;------------------------------------; Hey! thats the end of the keyboard interrupt! now it may seem like it would take forever to run, but its a lot slower in the BIOS!

;-----[ get a character from input ]--------------;
getchar:                                          ; Input nothing, Output al = character
   pusha                                          ; Push all our registers
   cld                                            ; Make sure stosb and lodsb increment DI and SI respectivly 
.check:                                           ; Wait for buffer to have a key
   xor al, al                                     ; Here's a fun trick:
   cmp al, byte [last_key]                        ; We can wait for the buffer to be empty
   je .check                                      ; By checking if the last key is 0
   mov dl, byte [key_buff]                        ; Retreive the character
   mov byte [wait_key], dl                        ; We store the char here
   cli                                            ; We have controll over the buffer now, keep it that way!
   xor cx, cx                                     ; We need CX to be empty
   mov cl, byte [last_key]                        ; Move the length to our counter
   mov di, key_buff                               ; Data index points to the buffer start
   lea si, [di+1]                                 ; load the address of Data index to source index +1
   rep movsb                                      ; mov a byte from si to di until cx = 0
   dec byte [last_key]                            ; Decrement the number of keys by one
   mov al, byte [wait_key]                        ; Put our kye here
   mov ah, 0x0E                                   ; Using the teletype function in BIOS
   cmp al, 10                                     ; See if its enter
   jne .print                                     ; If it is, we need a bit more to our output
   mov bl, al                                     ; Temp spot here
   mov al, 13                                     ; Carraige return 
   int 0x10                                       ; Write it
   mov al, bl                                     ; Put our original charecter back
.print:                                           ; Printing sub routine, we do it here and not in the interrupt so we can do blind input.
   int 0x10                                       ; Print dat char
   sti                                            ; Restore interrupts
   popa                                           ; Restore our registers
   mov al, byte [wait_key]                        ; Move the contents of the key buffer to al
   ret                                            ; Return
;-----[ get a string from input ]-----------------;
gets:                                             ; Input SI = String Pointer
   pusha                                          ; Put all registers on stack
   mov di, si                                     ; We're gonna use di
    .get:                                         ; Get a character
   call getchar                                   ; We're getting one character here
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
