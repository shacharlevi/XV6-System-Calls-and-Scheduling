#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
uint64
sys_memsize(void)
{
  return myproc()->sz;
}
uint64
sys_exit(void)
{
  int n;
  char msg[32];
  argint(0, &n);
  argstr(1,msg,32);
  exit(n, msg);
  return 0;  // not reached
}
uint64 
sys_set_cfs_priority(void) { //task6
  int priority;
  argint(0, &priority);
  if (priority >2 || priority<0){
    return -1;
  }
  acquire(& myproc()->lock);
  myproc()->cfs_priority=priority;
  release(& myproc()->lock);
  return 0;
}

uint64
sys_get_cfs_stats(void){//task6
  uint64 add;
  argaddr(0, &add);
  int pid;
  argint(1,&pid);
  return get_cfs_stats(add,pid);
}

uint64
sys_set_policy(void){//task7 
  int policy;
  argint(0,&policy);
  if (policy >2 || policy<0){
    return -1;
  }
  return set_policy(policy);
}
// uint64
// get_ps_priority(void){

// }
uint64 
sys_set_ps_priority(void) {//task5
  int priority;
  argint(0, &priority);
  if (priority < 1 || priority > 10) {
    return -1;
  }
  acquire(&myproc()->lock);
  myproc()->ps_priority = priority;
  release(&myproc()->lock);
  // print the current process's priority
  // printf("Process %d priority set to %d in sysproc.c\n", myproc()->pid, priority);
  return 0;
}
int
sys_get_ps_priority(void)//test 5
{
  int pid;
  argint(0, &pid);
  struct proc *p = get_ps_priority(pid);
  if (p == 0) {
    return -1;
  }
  return p->ps_priority;
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
  argaddr(0, &p);
  uint64 p2;
  argaddr(1, &p2);
  return wait(p,p2);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int n;

  argint(0, &n);
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

  argint(0, &n);
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(killed(myproc())){
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

  argint(0, &pid);
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
