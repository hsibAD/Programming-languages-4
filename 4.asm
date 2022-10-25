; hello_mmap.asm
%define O_RDONLY 0 
%define PROT_READ 0x1
%define MAP_PRIVATE 0x2
%define SYS_WRITE 1
%define SYS_OPEN 2
%define SYS_CLOSE 3
%define SYS_MMAP 9
%define SYS_MUNMAP 11
%define SYS_FSTAT 5
%define SYS_EXIT 60
%define FD_STDOUT 1

section .data

section .text
global print_file

; use exit system call to shut down correctly
exit:
    mov  rax, SYS_EXIT
    xor  rdi, rdi
    syscall

; These functions are used to print a null terminated string    
; rdi holds a string pointer
print_string:
    push rdi
    call string_length
    pop  rsi
    mov  rdx, rax 
    mov  rax, SYS_WRITE
    mov  rdi, FD_STDOUT
    syscall
    ret

string_length:
    xor  rax, rax
.loop:
    cmp  byte [rdi+rax], 0
    je   .end 
    inc  rax
    jmp .loop 
.end:
    ret

; This function is used to print a substring with given length
; rdi holds a string pointer
; rsi holds a substring length
print_substring:
    mov  rdx, rsi 
    mov  rsi, rdi
    mov  rax, SYS_WRITE
    mov  rdi, FD_STDOUT
    syscall
    ret

print_file:
    push rbx

    ;fname_read
    push rdi

    ;open
    mov  rax, SYS_OPEN
    pop  rdi
    mov  rsi, O_RDONLY    
    mov  rdx, 0 	      
    syscall

    push rax

    ;fstat
    mov  rax, SYS_FSTAT

    pop rdi
    push rdi

    sub  rsp, 144 
    mov  rsi, rsp

    syscall

    add  rsp, 48
    pop  rbx ;len -> rbx
    add  rsp, 88

    ;mmap
    mov  rax, SYS_MMAP
    mov  rdi, 0
    mov  rsi, rbx
    mov  rdx, PROT_READ

    pop  r8
    push r8

    mov  r9, 0 	
    mov  r10, MAP_PRIVATE       
    syscall

    ;print_substring
    mov rdi, rax
    mov  rsi, rbx
    call print_substring

    ;munmap
    mov  rax, SYS_MUNMAP
    pop rdi
    push rdi
    mov  rsi, rbx
    syscall

    ;close
    mov  rax, SYS_CLOSE 
    pop rdi
    syscall
    pop rbx
    ret
