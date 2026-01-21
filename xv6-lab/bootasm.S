#include "asm.h"

.code16
.globl start
start:
  cli
  xorw    %ax,%ax
  movw    %ax,%ds
  movw    %ax,%es
  movw    %ax,%ss

seta20.1:
  inb     $0x64,%al
  testb   $0x2,%al
  jnz     seta20.1
  movb    $0xd1,%al
  outb    %al,$0x64

seta20.2:
  inb     $0x64,%al
  testb   $0x2,%al
  jnz     seta20.2
  movb    $0xdf,%al
  outb    %al,$0x60

  lgdt    gdtdesc
  movl    %cr0,%eax
  orl     $0x1,%eax
  movl    %eax,%cr0
  ljmp    $0x8,$start32

.code32
start32:
  movw    $0x10,%ax
  movw    %ax,%ds
  movw    %ax,%es
  movw    %ax,%ss
  movw    $0,%ax
  movw    %ax,%fs
  movw    %ax,%gs
  movl    $0x7c00,%esp
  call    bootmain

spin:
  jmp     spin

.p2align 2
gdt:
  .word 0,0,0,0
  .word 0xffff,0,0x9a00,0x00cf
  .word 0xffff,0,0x9200,0x00cf

gdtdesc:
  .word   (gdtdesc - gdt - 1)
  .long   gdt
