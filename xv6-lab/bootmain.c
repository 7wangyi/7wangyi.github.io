// Boot loader.
//
// Part of the boot block, along with bootasm.S, which calls bootmain().
// bootasm.S has put the processor into protected 32-bit mode.
// bootmain() loads an ELF kernel image from the disk starting at
// sector 1 and then jumps to the kernel entry routine.
// ================================================
// bootstrap.c - xv6引导加载器（相当于bootmain.c）
// 功能：从磁盘加载ELF格式的内核镜像
// ================================================

#include "types.h"
#include "elf.h"
#include "x86.h"
#include "memlayout.h"

#define SECTSIZE  512

void readseg(uchar*, uint, uint);

void
bootmain(void)
{
    // [BOOT] enter bootmain
    // 这里实际应该调用cprintf，但现在还没有控制台，我们先记下位置
  struct elfhdr *elf;
  struct proghdr *ph, *eph;
  void (*entry)(void);
  uchar* pa;

  elf = (struct elfhdr*)0x10000;  // scratch space

  // Read 1st page off disk
    // 第一步：读取ELF文件头部（第一页，4096字节）
    // 目的：获取内核的程序头表信息
  readseg((uchar*)elf, 4096, 0);
  // Is this an ELF executable?
    // [BOOT] elf header loaded
    // ELF头部已成功加载到内存
  if(elf->magic != ELF_MAGIC)
    return;  // let bootasm.S handle error


  // Load each program segment (ignores ph flags).
// 第二步：验证ELF魔数
    // 检查是否是合法的可执行文件格式
  ph = (struct proghdr*)((uchar*)elf + elf->phoff);
  eph = ph + elf->phnum;
  for(; ph < eph; ph++){
    pa = (uchar*)ph->paddr;
    readseg(pa, ph->filesz, ph->off);
    if(ph->memsz > ph->filesz)
      stosb(pa + ph->filesz, 0, ph->memsz - ph->filesz);
  }

  // Call the entry point from the ELF header.
  // Does not return!
  entry = (void(*)(void))(elf->entry);
    // [BOOT] kernel loaded
    // 内核所有程序段已加载完毕，准备跳转
  entry();
}

void
waitdisk(void)
{
  while((inb(0x1F7) & 0xC0) != 0x40)
    ;
}

// 任务2：添加中文注释 - 磁盘读取函数

/*
 * readsec - 从硬盘读取一个扇区到内存
 * @dst: 目标内存地址
 * @offset: 扇区偏移量（LBA地址）
 * 功能：通过IDE硬盘控制器读取指定扇区
 */
void
readsect(void *dst, uint offset)
{

  waitdisk();
  outb(0x1F2, 1);   // count = 1
                    // 扇区数量寄存器：读取1个扇区
  outb(0x1F3, offset);
  outb(0x1F4, offset >> 8);
  outb(0x1F5, offset >> 16);
  outb(0x1F6, (offset >> 24) | 0xE0);
  outb(0x1F7, 0x20);  // cmd 0x20 - read sectors
                      // 设备寄存器：LBA第24-27位 | 主设备 | LBA模式


// 任务2：读取数据到内存
  // Read data.
  waitdisk();
  insl(0x1F0, dst, SECTSIZE/4);
}

// Read 'count' bytes at 'offset' from kernel into physical address 'pa'.
// Might copy more than asked.
/*
 * readseg - 从内核镜像读取指定字节到物理地址
 * @pa: 目标物理地址
 * @count: 要读取的字节数
 * @offset: 内核镜像中的偏移量
 * 注意：可能会读取比请求更多的数据（按扇区对齐）
 */
void
readseg(uchar* pa, uint count, uint offset)
{
  uchar* epa;

  epa = pa + count;

  // Round down to sector boundary.
// 任务2：向下对齐到扇区边界（512字节对齐）
  pa -= offset % SECTSIZE;

  // Translate from bytes to sectors; kernel starts at sector 1.
// 任务2：将字节偏移转换为扇区号
  offset = (offset / SECTSIZE) + 1;

  // If this is too slow, we could read lots of sectors at a time.
  // We'd write more to memory than asked, but it doesn't matter --
  // we load in increasing order.
 // 任务2：循环读取扇区，直到读完所需数据
  for(; pa < epa; pa += SECTSIZE, offset++)
    readsect(pa, offset);
}
