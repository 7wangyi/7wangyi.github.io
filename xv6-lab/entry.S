# The xv6 kernel starts executing in this file. This file is linked with
# the kernel C code, so it can refer to kernel symbols such as main().
# The boot block (bootasm.S and bootmain.c) jumps to entry below.
# xv6内核从这个文件开始执行。此文件与内核C代码链接，
# 因此可以引用内核符号，如main()。
# 引导块（bootstrap.S和bootmain.c）跳转到下面的entry处。

# Multiboot header, for multiboot boot loaders like GNU Grub.
# Multiboot头，用于GNU Grub等多引导启动加载器。
# http://www.gnu.org/software/grub/manual/multiboot/multiboot.html
#
# Using GRUB 2, you can boot xv6 from a file stored in a
# Linux file system by copying kernel or kernelmemfs to /boot
# and then adding this menu entry:
# 使用GRUB 2，你可以从存储在Linux文件系统中的文件启动xv6，
# 方法是将kernel或kernelmemfs复制到/boot，然后添加以下菜单项：
#
# menuentry "xv6" {
# 	insmod ext2
# 	set root='(hd0,msdos1)'
# 	set kernel='/boot/kernel'
# 	echo "Loading ${kernel}..."
# 	multiboot ${kernel} ${kernel}
# 	boot
# }

#include "asm.h"
#include "memlayout.h"
#include "mmu.h"
#include "param.h"

# Multiboot header.  Data to direct multiboot loader.
# Multiboot头。指导多引导加载器的数据。
.p2align 2
.text
.globl multiboot_header
multiboot_header:
  #define magic 0x1badb002
  #define flags 0
  .long magic
  .long flags
  .long (-magic-flags)

# By convention, the _start symbol specifies the ELF entry point.
# Since we haven't set up virtual memory yet, our entry point is
# the physical address of 'entry'.
# 按照惯例，_start符号指定ELF入口点。
# 由于我们尚未设置虚拟内存，因此我们的入口点是'entry'的物理地址。
.globl _start
_start = V2P_WO(entry)

# Entering xv6 on boot processor, with paging off.
# 在引导处理器上进入xv6，分页功能关闭。
.globl entry
entry:\
# ========================
# [KERNEL] ENTRY POINT
# ========================
  # Turn on page size extension for 4Mbyte pages
# 开启页面大小扩展，支持4MB大页
  movl    %cr4, %eax
  orl     $(CR4_PSE), %eax
  movl    %eax, %cr4
  # Set page directory
# 设置页目录
  movl    $(V2P_WO(entrypgdir)), %eax
  movl    %eax, %cr3
  # Turn on paging.
#开启分页
  movl    %cr0, %eax
  orl     $(CR0_PG|CR0_WP), %eax
  movl    %eax, %cr0

  # Set up the stack pointer.
#设置堆栈指针
  movl $(stack + KSTACKSIZE), %esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
 # 跳转到main()，并切换到高地址执行。
    # 需要间接调用，因为汇编器为直接跳转生成PC相对指令。
  mov $main, %eax
  jmp *%eax

.comm stack, KSTACKSIZE
