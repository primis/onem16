;=====================================================================================================;
;                                  2011 Onem16 Developers Presents:                                   ;
;                        The Onem16 Kernel - kernel.asm main entry to the kernel                      ;
;                                     Sets up the basics and stuff                                    ; 
;=====================================================================================================;

[ORG 0x7C00]
jmp 0:start    ; Skip our data area

;=========[ Data Section ]============================================================================

;---------[ Messages, Prompts, Etc ]---------------------------------;
welcome   db 'Welcome to onem16!', 0x0D, 0x0A                        ; The Welcome message
          db 'Please close the door when you leave.', 0x0D, 0x0A, 0  ; It spans two lines.
prompt    db '>>', 0                                                 ; The system prompt.
str_buf   times 64 db 0                                              ; String buffer
;--------------------------------------------------------------------; 

;=========[ Code Section ]============================================================================

;-----[ start, entry point ]-----;
start:                           ;
   xor ax, ax                    ; mov the segment to 2000
   mov ds, ax                    ; Data segment 0
   mov es, ax                    ; While we're at it...
   mov fs, ax                    ; Lets get all the segments
   mov gs, ax                    ; Its better this way...
   mov si, welcome               ; Source index is now a pointer to the welcome message
   call print_string             ; Print the string
   cli                           ; No interruptions!
   mov bx, 0x09                  ; Hardware interrupt Number for Keyboard
   shl bx, 2                     ; Multiply by 4
   mov [gs:bx], word kb_handler  ; Move the function there  
   mov [gs:bx+2], ds             ; And its segment
   sti                           ; Restore interrupts
   jmp main                      ; Jump to the main loop
;--------------------------------;

;-----[ main hang, CLI etc ]-----;
main:                            ;
   mov si, str_buf               ; Move our source to a buffer (string)
   call gets                     ; Get a string from the keyboard
   call cmd_chk                  ; Call the command execute thingy
   jmp main                      ; loopy loop!
;--------------------------------;

;-----[ parse command ]-----;
exec_command:               ; not in use yet
;---------------------------;


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

%INCLUDE "keyboard.asm"
%INCLUDE "string.asm"
%INCLUDE "commands.asm"
