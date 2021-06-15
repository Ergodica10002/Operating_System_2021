#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"

// mp3 self define
void reload_thrd_context(int context_id);
void store_thrd_context(int context_id);
// end of mp3 self define

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


// for mp3
uint64
sys_thrdstop(void)
{
  int interval, thrdstop_context_id;
  uint64 handler;
  if (argint(0, &interval) < 0)
    return -1;
  if (argint(1, &thrdstop_context_id) < 0)
    return -1;
  if (argaddr(2, &handler) < 0)
    return -1;
  myproc()->thrdstop_ticks = 0;
  myproc()->thrdstop_interval = interval;
  myproc()->thrdstop_handler_pointer = handler;
  if (thrdstop_context_id == -1){
    for (int i = 0; i < MAX_THRD_NUM; i++){
      if (myproc()->thrdstop_context_used[i] == 0){
        myproc()->thrdstop_context_id = i;
        return i;
      }
    }
  } else{
    myproc()->thrdstop_context_id = thrdstop_context_id;
    return thrdstop_context_id;
  }

  
  return -1;
}

// for mp3
uint64
sys_cancelthrdstop(void)
{
  int thrdstop_context_id;
  if (argint(0, &thrdstop_context_id) < 0)
    return -1;

  myproc()->thrdstop_interval = -1;
  if (thrdstop_context_id != -1){
    store_thrd_context(thrdstop_context_id);  
    myproc()->thrdstop_context_used[thrdstop_context_id] = 1;
  }
  return myproc()->thrdstop_ticks;
}

// for mp3
uint64
sys_thrdresume(void)
{
  int  thrdstop_context_id, is_exit;
  if (argint(0, &thrdstop_context_id) < 0)
    return -1;
  if (argint(1, &is_exit) < 0)
    return -1;

  if (is_exit == 0){
    reload_thrd_context(thrdstop_context_id);

    return -2;
  } else if (is_exit == 1){
    myproc()->thrdstop_context_used[thrdstop_context_id] = 0;
    myproc()->thrdstop_interval = -1;
  } else{
    return -1;
  }

  return 0;
}

// mp3 self define
void reload_thrd_context(int context_id){
  struct trapframe* mytrapframe = myproc()->trapframe;
  struct thrd_context_data* mythrd_context = myproc()->thrdstop_context;

  mytrapframe->s0 = mythrd_context[context_id].s_regs[0];
  mytrapframe->s1 = mythrd_context[context_id].s_regs[1];
  mytrapframe->s2 = mythrd_context[context_id].s_regs[2];
  mytrapframe->s3 = mythrd_context[context_id].s_regs[3];
  mytrapframe->s4 = mythrd_context[context_id].s_regs[4];
  mytrapframe->s5 = mythrd_context[context_id].s_regs[5];
  mytrapframe->s6 = mythrd_context[context_id].s_regs[6];
  mytrapframe->s7 = mythrd_context[context_id].s_regs[7];
  mytrapframe->s8 = mythrd_context[context_id].s_regs[8];
  mytrapframe->s9 = mythrd_context[context_id].s_regs[9];
  mytrapframe->s10 = mythrd_context[context_id].s_regs[10];
  mytrapframe->s11 = mythrd_context[context_id].s_regs[11];

  mytrapframe->ra = mythrd_context[context_id].ra;
  mytrapframe->sp = mythrd_context[context_id].sp;

  mytrapframe->t0 = mythrd_context[context_id].t_regs[0];
  mytrapframe->t1 = mythrd_context[context_id].t_regs[1];
  mytrapframe->t2 = mythrd_context[context_id].t_regs[2];
  mytrapframe->t3 = mythrd_context[context_id].t_regs[3];
  mytrapframe->t4 = mythrd_context[context_id].t_regs[4];
  mytrapframe->t5 = mythrd_context[context_id].t_regs[5];
  mytrapframe->t6 = mythrd_context[context_id].t_regs[6];

  mytrapframe->a0 = mythrd_context[context_id].a_regs[0];
  mytrapframe->a1 = mythrd_context[context_id].a_regs[1];
  mytrapframe->a2 = mythrd_context[context_id].a_regs[2];
  mytrapframe->a3 = mythrd_context[context_id].a_regs[3];
  mytrapframe->a4 = mythrd_context[context_id].a_regs[4];
  mytrapframe->a5 = mythrd_context[context_id].a_regs[5];
  mytrapframe->a6 = mythrd_context[context_id].a_regs[6];
  mytrapframe->a7 = mythrd_context[context_id].a_regs[7];

  mytrapframe->gp = mythrd_context[context_id].gp;
  mytrapframe->tp = mythrd_context[context_id].tp;
  mytrapframe->epc = mythrd_context[context_id].epc;

}
// end of mp3 self define