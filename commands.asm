;=====================================================================================================;
;                                  2012 Onem16 Developers Presents:                                   ;
;                          The Onem16 Kernel - commands.asm - CLI commands                            ;
;                                          Standard commands                                          ; 
;=====================================================================================================;

;-----[command execute thing]----------------;
cmd_hello db 'hello', 0                      ;
not_found db 'Command not found!', 10, 13, 0 ;
cmd_chk:                                     ;
   mov di, cmd_hello                         ;
   call cmpStr                               ;
   jne .no1                                  ;
   call exec_hello                           ;
   ret                                       ;
.no1:                                        ;
   mov si, not_found                         ;
   call print_string                         ;
   ret                                       ;
;--------------------------------------------;
   

;-----[Hello World]-------------------------------------------------------;
txt_hello db 'HELLO WORLD', 10, 13, 'God damnit osdev is hard', 10, 13, 0 ; text to print
exec_hello:                                                               ;
   mov si, txt_hello                                                      ;
   call print_string                                                      ;
   ret                                                                    ;
;-------------------------------------------------------------------------;
