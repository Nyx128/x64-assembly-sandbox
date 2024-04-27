%include "macros.inc"

default rel
bits 64

segment .data
  c12_index dd 0, 4, 8, 12, 1, 5, 9, 13
  c34_index dd 2, 6, 10, 14, 3, 7, 11, 15
  result times 16 dd 0.0

segment .text
global mul4x4_avx

;function would look like mul4x4_avx(float left[16], float right[16]]) and will return a float result[16]
;each ymm register is 256 bit or capable of holding 8 floats
;rcx -> left
;rdx -> right
;ymm1 ->r12
;ymm3 ->r34
;ymm2 -> c12
;ymm4 -> c34
;ymm5 ->c21
;ymm6 ->c43


mul4x4_avx:
  ;going to make use of every single avx2 register possible for maximum throughput
  multipush_ymm ymm6, ymm7, ymm8, ymm9, ymm10, ymm11, ymm12, ymm13, ymm14
  ;the use for ymm0, ymm1, ymm3 is finished so we will use them again to store our multiplication data
  vzeroall

  push rbp
  mov rbp, rsp

  vmovdqu32 ymm0, [c12_index]
  vmovdqu32 ymm1, [c34_index]

  ;load and transpose right matrix
  vpcmpeqb   ymm3,ymm3,ymm3;turn each bit to 1
  vgatherdps ymm2, [rdx + ymm0 * 4], ymm3
  vpcmpeqb   ymm3,ymm3,ymm3;turn each bit to 1
  vgatherdps ymm4, [rdx + ymm1 * 4], ymm3

  vmovaps ymm5, ymm2
  vperm2f128 ymm5, ymm5, ymm2, 1

  vmovaps ymm6, ymm4
  vperm2f128 ymm6, ymm6, ymm4, 1

  ;load left matrix rows
  vmovupd ymm1, [rcx]
  vmovupd ymm3, [rcx + 32]

  ;ymm7 to ymm14 will be used for multiplication
  vmulps ymm7, ymm1, ymm2
  vmulps ymm8, ymm1, ymm5
  vmulps ymm9, ymm1, ymm4
  vmulps ymm10, ymm1, ymm6

  vmulps ymm11, ymm3, ymm2
  vmulps ymm12, ymm3, ymm5
  vmulps ymm13, ymm3, ymm4
  vmulps ymm14, ymm3, ymm6

  ;add the halves together
  vhaddps ymm7, ymm7
  vhaddps ymm7, ymm7

  vhaddps ymm8, ymm8
  vhaddps ymm8, ymm8

  vhaddps ymm9, ymm9
  vhaddps ymm9, ymm9

  vhaddps ymm10, ymm10
  vhaddps ymm10, ymm10

  vhaddps ymm11, ymm11
  vhaddps ymm11, ymm11

  vhaddps ymm12, ymm12
  vhaddps ymm12, ymm12

  vhaddps ymm13, ymm13
  vhaddps ymm13, ymm13

  vhaddps ymm14, ymm14
  vhaddps ymm14, ymm14

  mov rax, result

;ymm7->m12_12
;ymm8->m12_21
;ymm9->m12_34
;ymm10->m12_43
;ymm11->m34_12
;ymm12->m34_21
;ymm13->m34_34
;ymm14->m34_43


  ;extraction
  vextractf128 xmm0, ymm7, 0
  movss [rax], xmm0

  vextractf128 xmm0, ymm8, 0
  movss [rax + 4], xmm0

  vextractf128 xmm0, ymm9, 0
  movss [rax + 8], xmm0

  vextractf128 xmm0, ymm10, 0
  movss [rax + 12], xmm0

  vextractf128 xmm0, ymm8, 1
  movss [rax + 16], xmm0

  vextractf128 xmm0, ymm7, 1
  movss [rax + 20], xmm0

  vextractf128 xmm0, ymm10, 1
  movss [rax + 24], xmm0

  vextractf128 xmm0, ymm9, 1
  movss [rax + 28], xmm0

  vextractf128 xmm0, ymm11, 0
  movss [rax + 32], xmm0

  vextractf128 xmm0, ymm12, 0
  movss [rax + 36], xmm0

  vextractf128 xmm0, ymm13, 0
  movss [rax + 40], xmm0

  vextractf128 xmm0, ymm14, 0
  movss [rax + 44], xmm0

  vextractf128 xmm0, ymm12, 1
  movss [rax + 48], xmm0

  vextractf128 xmm0, ymm11, 1
  movss [rax + 52], xmm0

  vextractf128 xmm0, ymm14, 1
  movss [rax + 56], xmm0

  vextractf128 xmm0, ymm13, 1
  movss [rax + 60], xmm0

  leave
  multipop_ymm ymm6, ymm7, ymm8, ymm9, ymm10, ymm11, ymm12, ymm13, ymm14
  ret



  