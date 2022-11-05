BITS 64
global _start

section .text
_start:
  mov r12, rsp   ; need this to avoid a NULL argument error on exit
  xor rax, rax  ; clear the reg
  mov rax, 0x66 ; getuid syscall 102
  syscall

  cmp rax, 0    ; 0 == root
  je is_root    ; if so, jump
  jmp not_root

is_root:       ; are we root?
  call root
  db "you ARE root", 0xa, 0x0
root:          ; custom write func
  xor rax, rax
  xor rdx, rdx
  inc al
  mov rdi, rax
  pop rsi
  mov dl,  13
  syscall

socket:
  mov rdi, 2        ; AF_INET == 2
  mov rsi, 1        ; SOCK_STREAM == 1
  xor rdx, rdx      ; IPPROTO_IP == 0
  mov rax, 0x29     ; socket syscall 41
  syscall

  mov r14, rax      ; save the return value as we need a couple more times    

setup_sockaddr_in:
  mov rdi, r14             ; move return value to rdi
  xor rax, rax
  push rax                 ; put some space on the stack

  mov r13d, 0x0100007f     ; "127.0.0.1"
  ;mov r13d, 0x1011116e
  ;xor r13d, 0x11111111 ; make this 127.0.0.1 avoiding null bytes

  mov dword [rsp-4], r13d
  mov word [rsp-6], 0x901f ; reverse byte order for port 8080
  xor r13, r13
  mov r13b, 2              ; AF_INET == 2
  mov word [rsp-8], r13w
  sub rsp, 8

connect:
  mov rsi, rsp      ; this should be a struct of some kind
  mov rdx, 16       ; not sure where this value comes from yet...
  mov rax, 0x2a     ; connect syscall 42
  syscall

sendto:
  mov rdi, r14

  xor rsi, rsi
  push rsi
  mov rsi, 0x68732f6e69622f
  push rsi
  mov rsi, rsp

  mov rdx, 7
  mov r10, 0
  mov r8, 0
  mov r9, 0
  mov rax, 0x2c
  syscall

  jmp close

not_root:      ; are we not root?
  call noroot
  db "you are NOT root", 0xa, 0x0
noroot:        ; custom write func
  xor rax, rax
  xor rdx, rdx
  inc al
  mov rdi, rax
  pop rsi
  mov dl,  17
  syscall
  jmp close

close:
  mov rsp, r12  ; BRING IT BACK!!!
  xor rdx, rdx  ; must exit with this instruction all the time
