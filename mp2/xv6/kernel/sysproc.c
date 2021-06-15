#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
// mp2 define
#include <stddef.h>
#include "fcntl.h"
#include "fs.h"
pte_t *walk(pagetable_t pagetable, uint64 va, int alloc);
// end of mp2 define

uint64
sys_exit(void)
{
  int n;
  if(argint(0, &n) < 0)
    return -1;
  exit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return fork();
}

uint64
sys_wait(void)
{
  uint64 p;
  if(argaddr(0, &p) < 0)
    return -1;
  return wait(p);
}

uint64
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;
//  myproc()->sz += n;

  if(growproc(n) < 0)
    return -1;

  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}


// mp2-implementation
struct file {
  enum { FD_NONE, FD_PIPE, FD_INODE, FD_DEVICE } type;
  int ref; // reference count
  char readable;
  char writable;
  struct pipe *pipe; // FD_PIPE
  struct inode *ip;  // FD_INODE and FD_DEVICE
  uint off;          // FD_INODE
  short major;       // FD_DEVICE
};
struct VMA{
  uint64 start;
  uint64 end;
  uint64 length;
  int prot;
  int flags;
  int index;
  struct file* file;
  struct VMA* next;
  struct VMA* prev;
};
#define MAXVMA 512
#define VMA_START TRAPFRAME - PGSIZE*MAXVMA
struct VMA VMA_array[MAXVMA];
int newvma_index = 0;

uint64
sys_mmap(void)
{
  uint64 addr;
  int length;
  int prot;
  int flags;
  int fd;
  int offset;

  if (newvma_index >= MAXVMA){
    printf("reach maximum!\n");
    return -1;
  }
// Get argument
  if(argaddr(0, &addr) < 0){
    return 0xffffffffffffffff;
  }
  if(argint(1, &length) < 0){
    return 0xffffffffffffffff;
  }
  if(argint(2, &prot) < 0){
    return 0xffffffffffffffff;
  }
  if(argint(3, &flags) < 0){
    return 0xffffffffffffffff;
  }
  if(argint(4, &fd) < 0){
    return 0xffffffffffffffff;
  }
  if(argint(5, &offset) < 0){
    return 0xffffffffffffffff;
  }

  if (addr != 0){
    return 0xffffffffffffffff;
  }
  if (offset != 0){
    return 0xffffffffffffffff;
  }
// Handle the permission of the VMA
// The permission cannot contradict 
// the permission of the file
  struct proc* p = myproc();
  struct file* newfile = p->ofile[fd];
  int newprot;
  int canread = newfile->readable;
  int canwrite = newfile->writable;
  if (((prot & PROT_READ) != 0) && ((prot & PROT_WRITE) != 0)){
    //can read and write
    if (canread == 0){
      return 0xffffffffffffffff;
    }
    if (canwrite == 0){
      if (flags == MAP_SHARED){
        return 0xffffffffffffffff;
      }
    }
    newprot = PTE_R | PTE_W | PTE_U;
  } else if ((prot & PROT_READ) != 0){
    //can read
    if (newfile->readable == 0){
      return 0xffffffffffffffff;
    }
    newprot = PTE_R | PTE_U;
  } else if ((prot & PROT_WRITE) != 0){
    //can write
    if (newfile->writable == 0){
      return 0xffffffffffffffff;
    }
    newprot = PTE_W | PTE_U;
  } else{
    return 0xffffffffffffffff;
  }
  filedup(newfile); // Increment the reference count of the file

// Take a new VMA from VMA_array
// Protect the linked list structure
  while (VMA_array[newvma_index].length != 0){
    newvma_index += 1;
    if (newvma_index >= MAXVMA)
      break;
  }
  struct VMA* newvma = &(VMA_array[newvma_index]);
  newvma->index = newvma_index;
  if (p->vma_index == NULL){
    newvma->prev = NULL;
    newvma->start = PGROUNDUP(VMA_START);
    newvma->end = newvma->start + length;
    p->vma_index = newvma;
  } else{
    newvma->prev = p->vma_index;
    p->vma_index->next = newvma;
    newvma->start = PGROUNDUP(p->vma_index->end);
    newvma->end = newvma->start + length;
    p->vma_index = newvma;
  }
  newvma->next = NULL;

  if (newvma->end >= TRAPFRAME){
    newvma->start = 0;
    newvma->end = 0;
    newvma_index -= 1;
    newvma->prev = NULL;
    newvma->next = NULL;
    newvma->index = -1;
    fileclose(newvma->file);
    p->vma_index = p->vma_index->prev;
    if (p->vma_index != NULL){
      p->vma_index->next = NULL;
    } 
    printf("mmap memory overflow\n");
    return 0xffffffffffffffff;
  }

// Set all attributes of new VMA
  newvma->file = newfile;
  newvma->prot = newprot;
  newvma->length = length;
  newvma->flags = flags;

  //vmprint(myproc()->pagetable);
  return newvma->start;
}

uint64
sys_munmap(void)
{
  uint64 addr;
  int length;

// Get argument
  if(argaddr(0, &addr) < 0){
    return -1;
  }
  if(argint(1, &length) < 0){
    return -1;
  }

// Find the corresponding VMA structure
// of the requested addr and length
  struct VMA* nowvma = myproc()->vma_index;
  while (nowvma != NULL){
    if(nowvma->start == addr || nowvma->end == addr + length){
      break;
    }
    nowvma = nowvma->prev;
  }
  if (nowvma == NULL){
    printf("not found!\n");
    return -1;
  }

// Handle memory write back is flag is MAP_SHARED
// Sequentially wirte at most max bytes
// The following is modified from file.c filewrite()
  if (nowvma->flags == MAP_SHARED){
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    int r = 0;
    while(i < length){
      int num_to_write = length - i;
      if(num_to_write > max)
        num_to_write = max;

      begin_op();
      ilock(nowvma->file->ip);
      if ((r = writei(nowvma->file->ip, 1, addr + i, nowvma->file->off, num_to_write)) > 0)
        nowvma->file->off += r;
      iunlock(nowvma->file->ip);
      end_op();

      if(r != num_to_write){
        // error from writei
        break;
      }
      i += r;
    }
  }

// Sequentially free physical memory
// The following is modified from vm.c uvmunmap()
  uint64 start_page_addr = PGROUNDDOWN(addr);
  uint64 end_page_addr = PGROUNDDOWN(addr + length);
  uint64 a;
  pte_t *pte;
  for(a = start_page_addr; a < end_page_addr; a += PGSIZE){
    if((pte = walk(myproc()->pagetable, a, 0)) == 0){
      panic("uvmunmap: walk");
    }
    if(*pte & PTE_V){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }

// Handle VMA linked list structure
// If a VMA is totally unmapped, decrement the reference count of the file  
  if(nowvma->start == addr && nowvma->end == addr + length){
    fileclose(nowvma->file);
    if (nowvma->prev != NULL){
      nowvma->prev->next = nowvma->next;
    }
    if (nowvma->next != NULL){
      nowvma->next->prev = nowvma->prev;
    } else{
      // To remove is the last one
      myproc()->vma_index = myproc()->vma_index->prev;
    }
    nowvma->length = 0;
    newvma_index = nowvma->index;
    nowvma->prev = NULL;
    nowvma->next = NULL;
    nowvma->index = -1;
  } else if (nowvma->start == addr){
    nowvma->length = nowvma->length - length;
    nowvma->start = nowvma->start + length;
  } else{
    nowvma->length = nowvma->length - length;
    nowvma->end = addr;
  }
  return 0;
}

// end of mp2-implementation
