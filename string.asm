;=====================================================================================================;
;                                  2011 Onem16 Developers Presents:                                   ;
;                            The Onem16 Kernel - string.asm - String Functions                        ;
;                                 String functions, like comparison                                   ; 
;=====================================================================================================;

;-----[CmpStr]-----;
cmpStr:            ; Compare two strings: first one in si, second in di. Returns a flag.
push si            ; Push the values we're gonna change
push di            ; That way, we can be nice and restore them
push ax            ; :D
dec di             ; Have to have it one less for the loop to work.
                   ;
.lab1              ; The loop Label.
inc di             ; ds:di points to the next charecter in string 2
lodsb              ; Load al with next charecter from string 1 (decrements automatically)
                   ;
cmp [di], al       ; Compare the two charecters.
jne .NotEqual      ; If they are not the same, break loop.
cmp al, 0          ; Just check to see if we hit the end of the string.
jne .lab1          ; If it isn't yet, repeat the loop.
                   ; loop exited, so they're equal:
cmp al, al         ; Gonna be zero flag set
pop ax             ; Restore stuff
pop di             ; Restore stuff
pop si             ; Restore stuff
ret                ; return
                   ;
.NotEqual:         ; Strings are not equal, return with NE flag
mov ah, 5          ; Random value
cmp ah, 1          ; Always gonna be wrong! 
pop ax             ; Restore stuff
pop di             ; Restore stuff
pop si             ; Restore stuff
ret                ; return
;------------------;