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
   jmp .specialkey                  ; Check for special keys
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
   cmp al, 0x1D                      ; 
    je .ctrl_d                       ;
   cmp al, 0x9D                      ;
    je .ctrl_u                       ;
   cmp al, 0x38                      ;
    je .alt_d                        ;
   cmp al, 0xB8                      ;
    je .alt_u                        ;
   cmp al, 0x3A                      ;
    je .caps_d                       ;
   cmp al, 0x45                      ;
    je .num_d                        ;
   cmp al, 0x46                      ;
    je .scrl_d                       ;
   cmp al, 0xBA                      ;
    je .done                         ;
   cmp al, 0xC5                      ;
    je .done                         ;
   cmp al, 0xC6                      ;
    je .done                         ;
   cmp al, 0xE0                      ;
    je .done                         ;
   jmp .compare                      ;
.shift_d:                            ;
    or bl, 10000000b                 ;
    mov byte [spec_key], bl          ;
    jmp .done                        ;
.shift_u:                            ;
    and bl, 01111111b                ;
    mov byte [spec_key], bl          ;
    jmp .done                        ;
.ctrl_d:                             ;
    or bl, 01000000b                 ;
    mov byte [spec_key], bl          ;
    jmp .done                        ;
.ctrl_u:                             ;
    and bl, 10111111b                ;
    mov byte [spec_key], bl          ;
    jmp .done                        ;
.alt_u:                              ;
    or bl, 00100000b                 ;
    mov byte [spec_key], bl          ;
    jmp .done                        ;
.alt_d:                              ;
    and bl, 11011111b                ;
    mov byte [spec_key], bl          ;
    jmp .done                        ;
.caps_d:                             ;
    not byte [caps_lock]             ;
    call .update_led                 ;
    jmp .done                        ;
.num_d:                              ;
    not byte [num_lock]              ;
    call .update_led                 ;
    jmp .done                        ;
.scrl_d:                             ;
    not byte [scrl_lock]             ;
    call .update_led                 ;
    jmp .done                        ;
.update_led:                         ;
    xor bl, bl                       ;
    mov cl, byte [caps_lock]         ;
    and cl, 0x04                     ;
    add bl, cl                       ;
    mov cl, byte [num_lock]          ;
    and cl, 0x02                     ;
    add bl, cl                       ;
    mov cl, byte [scrl_lock]         ;
    and cl, 0x01                     ;
    add bl, cl                       ;
    call .keyboardloop               ;
    mov al, 0xED                     ;
    out 0x60, al                     ;
    call .keyboardloop               ;
    mov al, bl                       ;
    out 0x60, al                     ;
    ret                              ;
.keyboardloop:                       ;
    push ax                          ;
    in al, 0x64                      ;
    and al, 2                        ;
    cmp al, 0                        ;
    ja .keyboardloop                 ;
    pop ax                           ;
    ret                              ;
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