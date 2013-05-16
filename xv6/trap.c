#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "x86.h"
#include "traps.h"
#include "spinlock.h"

// Interrupt descriptor table (shared by all CPUs).
struct gatedesc idt[256];
extern uint vectors[];  // in vectors.S: array of 256 entry pointers
struct spinlock tickslock;
uint ticks;
extern struct proc* recorrerTablaProcesos(struct proc* proceso, uint pageFault,int* compartenDirectorio);
extern void setptew(pde_t* pgdir, char* uva);

void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
  
  initlock(&tickslock, "time");
}

void
idtinit(void)
{
  lidt(idt, sizeof(idt));
}

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
  if(tf->trapno == T_SYSCALL){
    if(proc->killed)
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
  }

  switch(tf->trapno){
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE:
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_COM1:
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
    break;
  case T_PGFLT:
      /* 0- Controlar que el fallo de pagina sea porque un usuario quiso 
       *        modificar una pagina del padre que estaba protegida con
       *        escritura. Si no es asi continuar a default...
       * 1- Ver como recuperar la pagina que quiere escribir el proceso. En la
       *        estructura proc tenemos el directorio de pagina, pero hay que 
       *        saber en que tabla esta y cual es la pagina... tal vez este en 
       *        algun registro del micro cr2 tal vez?
       * 2- Ver como hacer cuando tiene mas de un hijo o cuando el padre quiere
       *        modificar esa pagina... contador de referencias?
       * 3- Copiar paginas, actualizar pde y restaurar bits de escritura
       *        donde corresponda
       */
      if (tf->err== 7){
        int compartenDirectorio = 0;
        struct proc* resultado = recorrerTablaProcesos(proc,rcr2(),&compartenDirectorio);
        if (resultado){
            if (compartenDirectorio){ //debemos copiarle todo directorio tabla y pagina
                int i;
                for(i = 0; i < proc->sz; i += PGSIZE){
                    setptew(proc->pgdir,(char*)i);
                }
                cprintf("resultado->pgdir %d, resultado->sz %d\n",resultado->pgdir,resultado->sz);
                cprintf("proc->pgdir %d, proc->sz %d\n",proc->pgdir,proc->sz);
                if((resultado->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
                    kfree(resultado->kstack);
                    resultado->kstack = 0;
                    resultado->state = UNUSED;
                    panic("ERROR COPIANDO MEMORIA EN FALLO DE PAGINA....");
                    //return -1;
                }
                cprintf("resultado->pgdir %d, resultado->sz %d\n",resultado->pgdir,resultado->sz);
                cprintf("proc->pgdir %d, proc->sz %d\n",proc->pgdir,proc->sz);

                
            }else{
                cprintf("PASA POR ACA !!!\n");
            }
        }else
            cprintf(" NO ENCONTRO PROCESO!!!\n");
        break;
      }
      
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    
    //deberiamos atrapar el trap y cargar las demas paginas
    cprintf("pid %d %s: trap %d err %d on cpu %d "
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
