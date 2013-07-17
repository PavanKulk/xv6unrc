#include "types.h"
#include "stat.h"
#include "user.h"

int
main(void)
{
   int pid;
   pid = fork();
   switch(pid){
       
        case -1:
                printf(1,"forksimple.c---> error en el fork\n");
                break;
        case 0:
                printf(1,"forksimple.c---> Soy el hijo mi pid es: %d\n",pid);
                exit();
                break;
                
       default:
                printf(1,"forksimple.c---> Entre al Padre Antes del wait()\n");
                wait();
                printf(1,"forksimple.c---> Entre al Padre despues del wait() del Wait\n");
                printf(1,"forksimple.c---> soy el padre mi pid es: %d\n",pid);
                exit();
                break;
    }
    
   return 0;
}

