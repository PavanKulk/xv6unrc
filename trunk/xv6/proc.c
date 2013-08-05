#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "proc.h"
#include "spinlock.h"

struct {
  struct spinlock lock;
  struct proc proc[NPROC];
} ptable;

static struct proc *initproc;

int nextpid = 1;
extern void forkret(void);
extern void trapret(void);
extern void clearptew(pde_t *pgdir, char *uva);
extern void setptew(pde_t *pgdir, char *uva);
extern pte_t * wpgdir(pde_t *pgdir, const void *va, int alloc);
extern int mappage1(pde_t *pgdir, void *va, uint size, uint pa, int perm);
static void wakeup1(void *chan);

void
pinit(void)
{
  initlock(&ptable.lock, "ptable");
}

//PAGEBREAK: 32
// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;
  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
  p->tf = (struct trapframe*)sp;
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;

  return p;
}

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
  initproc = p;
  if((p->pgdir = setupkvm(kalloc)) == 0)
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  p->sz = PGSIZE;
  memset(p->tf, 0, sizeof(*p->tf));
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  p->tf->es = p->tf->ds;
  p->tf->ss = p->tf->ds;
  p->tf->eflags = FL_IF;
  p->tf->esp = PGSIZE;
  p->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  p->state = RUNNABLE;
}

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  
  sz = proc->sz;
  if(n > 0){
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  proc->sz = sz;
  switchuvm(proc);
  return 0;
}
//Recorrer todas las tablas de procesos
 struct proc* recorrerTablaProcesos( uint registroCR2,int* compartenDirectorio){
    struct proc *p;
//  pte_t * entryTablePage= wpgdir(pgdir,(void *)registroCR2, 0);
    //cprintf("proceso->pid: %d\n", proceso->pid);
    for(p = ptable.proc; p < &ptable.proc[NPROC] && (p->pid != 0); p++){
        
    //cprintf("p->pid: %d\n", p->pid);
        if (p->pid == 0){
            return 0;
        }
        if (proc->pgdir == p->pgdir && p!=proc){
            *compartenDirectorio=1;

            //cprintf("Retorno p->pid %d \n", p->pid);
            return p;           
        }/*else{ //no comparten directorio
            compartenDirectorio = 0;
            int i,j;
            for( i= 0 ; i < 1024 ; i++){//por cada entrada en directorio
                pte_t * entradaTabla= (pte_t *) PTE_ADDR(&p->pgdir[i]);
                for(j= 0 ; j < 1024 ; j++){//por cada entrada en la tabla de pagina
                    cprintf("entryTablePage !!!%d\n",entryTablePage);
                    cprintf("entradaTabla !!!%d\n",&entradaTabla[j]);
                    if (entryTablePage==&entradaTabla[j]){
                        cprintf("IGUAL TABLA !!!\n");
                        release(&ptable.lock);
                        return p;
                    }
                }
            }
            
        }*/
        //cprintf("ProcesoName: %s ProcesoPID: %d ProcesoPadre: %s\n",p->name,p->pid,p->parent->name);
    }
    //cprintf("No deberia imprimirse esto...");
    return 0;
    //cprintf("Fin Tabla de Procesos\n");
}
 
 void trapCOW(){  
cprintf("proc.c--->trapCOW() Entramos a la trampa por fallo de pagina \n");
     int compartenDirectorio = 0;
     acquire(&ptable.lock);
     struct proc* procComparteMemoria = recorrerTablaProcesos(rcr2(),&compartenDirectorio);
     uint cr2Rounded = PGROUNDDOWN(rcr2());
     setptew(proc->pgdir,(char*)cr2Rounded);// seteo solo la pagina que produjo el fallo como escribible
     
     pte_t *pte, *pte2;
        int i;
        for (i=0; i<procComparteMemoria->sz; i += PGSIZE){
            pte = wpgdir(procComparteMemoria->pgdir, (void *) i, 0);
            pte2 = wpgdir(proc->pgdir, (void *) i, 0);
            cprintf("proc.c--->trapCOW() i = %d; procComparteMemoria = %d; proc = %d\n", i,*pte,*pte2);
        }
     
     while(procComparteMemoria){//si hay procesos que comparten memoria entonces aplicar tecnica COW
        if (compartenDirectorio){
            pde_t *d;
            pte_t *pte,*pteAux;
            uint pa, i;
            char *mem;
            d = setupkvm();
            for(i = 0; i < proc->sz; i += PGSIZE){
              if((pte = wpgdir(proc->pgdir, (void *) i, 0)) == 0)
                panic("proc.c--->trapCOW(): ptedeberia existir");
              if(!(*pte & PTE_P))
                panic("proc.c--->trapCOW(): pagina no presente");
              if(cr2Rounded == i){//Encontre la pagina que debo copiar (la que contiene la direccion que produjo el fallo))
                  cprintf("proc.c--->trapCOW() i==cr2Rounded %d==%d  \n", i,cr2Rounded);
                  pa = PTE_ADDR(*pte);
                  mem = kalloc();
                  memmove(mem, (char*)p2v(pa), PGSIZE);
                  mappage1(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U);
              }else{
                  cprintf("proc.c--->trapCOW() i!=cr2Rounded i=%d  \n", i);
                  pa = PTE_ADDR(*pte); 
                  cprintf("proc.c--->trapCOW()  pa = %d  \n", pa);
                  pteAux = wpgdir(proc->pgdir, (void *) i, 0);
                  pte= wpgdir(d, (void*)i, 1);
                  *pte = *pteAux;
              }
            }
            procComparteMemoria->pgdir = d;
            
            pte_t *pte1, *pte2;
            int j;
            for (j=0; i<procComparteMemoria->sz; j += PGSIZE){
                pte1 = wpgdir(procComparteMemoria->pgdir, (void *) j, 0);
                pte2 = wpgdir(proc->pgdir, (void *) j, 0);
                cprintf("proc.c--->trapCOW() j = %d; procComparteMemoria = %d; proc = %d\n", j,*pte1,*pte2);
            }
        }else{
            
            //TODO no comparten directorio
            cprintf("proc.c--->trapCOW() no comparten directorio \n");
        }
        procComparteMemoria = recorrerTablaProcesos(rcr2(),&compartenDirectorio);
     }    
     release(&ptable.lock);
 }

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
  } 
  if (strncmp(proc->name,"sh",2)==0 || strncmp(proc->name,"init",2)==0){
/*
      cprintf("np->pid==%d\n",np->pid);
      cprintf("proc->pid==%d\n",proc->pid);
*/
        // Copy process state from p.
        if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
            kfree(np->kstack);
            np->kstack = 0;
            np->state = UNUSED;
            return -1;
        }
        
  }else {
/*
        cprintf("np->pid==%d\n",np->pid);
        cprintf("proc->pid==%d\n",proc->pid);
*/
        for(i = 0; i < proc->sz; i += PGSIZE){ //LAURA: que pasa si proc->sz==3 paginas? como esta aca la ultima no se copia, pero en otro caso si...
            clearptew(proc->pgdir,(char*)i);
        }
        //cprintf(" proc.c-->fork() Tamanio de proc= %d, i= %d \n",proc->sz, i);
        np->pgdir =proc->pgdir;
        
  }
  np->sz = proc->sz;
  np->parent = proc;
  *np->tf = *proc->tf;
  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);

  pid = np->pid;
  np->state = RUNNABLE;
  safestrcpy(np->name, proc->name, sizeof(proc->name));
  //cprintf("nombre %s pid %d ...", proc->name, pid);
  return pid;
}
/*
int
fork(void)
{
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
    return -1;

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = proc->sz;
  np->parent = proc;
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
 
  pid = np->pid;
  np->state = RUNNABLE;
  safestrcpy(np->name, proc->name, sizeof(proc->name));
  return pid;
}
*/

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
  cprintf("ENTRE AL EXIT\n");
  struct proc *p;
  int fd;

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd]){
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  iput(proc->cwd);
  proc->cwd = 0;

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == proc){
      p->parent = initproc;
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.+
          cprintf("proc.c--->wait() Encontre un hijo del proceso que esta zombie \n");
        pid = p->pid;
        kfree(p->kstack);
        p->kstack = 0;
        // cuidado, aca hay que ver que no libere memoria de los procesos hermanos
        //si nadie comparte el directorio liberamos pgdir
        int compartenDirectorio = 0;
        struct proc* resultado = recorrerTablaProcesos(rcr2(),&compartenDirectorio);
        if (!resultado){
                //freevm(p->pgdir);
        }else{
//            //TODO()
        }
        p->state = UNUSED;
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        release(&ptable.lock);
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
  }
  
}

//PAGEBREAK: 42
// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
      switchuvm(p);
      p->state = RUNNING;
      swtch(&cpu->scheduler, proc->context);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);

  }
}

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
  int intena;

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(cpu->ncli != 1)
    panic("sched locks");
  if(proc->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  intena = cpu->intena;
  swtch(&proc->context, cpu->scheduler);
  cpu->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  acquire(&ptable.lock);  //DOC: yieldlock
  proc->state = RUNNABLE;
  sched();
  release(&ptable.lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);

  if (first) {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
    initlog();
  }
  
  // Return to "caller", actually trapret (see allocproc).
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  if(proc == 0)
    panic("sleep");

  if(lk == 0)
    panic("sleep without lk");

  // Must acquire ptable.lock in order to
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
    acquire(&ptable.lock);  //DOC: sleeplock1
    release(lk);
  }

  // Go to sleep.
  proc->chan = chan;
  proc->state = SLEEPING;
  sched();

  // Tidy up.
  proc->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  }
}

//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
}

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}

//PAGEBREAK: 36
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [EMBRYO]    "embryo",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}


