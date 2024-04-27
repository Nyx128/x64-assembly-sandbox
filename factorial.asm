default rel
bits 64

segment .data
  fmt db "factorial is: %d", 0xd, 0xa, 0

segment .text

global main
global factorial

extern _CRT_INIT
extern ExitProcess
extern printf

;we only have one argument and that too of type int so its going to be in the rcx register as per microsoft x64 calling conv
;as usual return value is stored in the rax register
factorial:
  push    rbp ;set stack pointer and decrement it by 1 from top of stack
  mov     rbp, rsp ;now set it back to the top of the stack
  sub     rsp, 32 ;now decrement stack pointer by 32 for windows shadow space before a functon call

  test ecx, ecx;set zero flag considering 
  jz .zero

  mov ebx, 1 ;loop counter and the number to multiply
  mov eax, 1 ; set return value to 1 initially

  inc ecx ;increment ecx by 1

;loop from 1 to argument + 1 and multiply the result to eax each step
.for_loop:
  cmp ebx, ecx
  je .loop_end

  mul ebx

  inc ebx

  jmp .for_loop

.zero:
  mov eax, 1

  leave;copies ebp to esp or basically undo the stack frame changes
  ret

.loop_end:
  leave 
  ret

main:
  push    rbp
  mov     rbp, rsp
  sub     rsp, 32

  mov     rcx, 5;pass 5 as our argument so basically we are gonna do 5!
  call    factorial; call our function

  lea     rcx, [fmt]; then pass our format to printf 
  mov     rdx, rax; pass variadic argument into rdx or second argument to printf essentially calling printf("factorial is %d", rdx)
  call    printf

  xor     rax, rax; zero out rax register before ending process
  call    ExitProcess
