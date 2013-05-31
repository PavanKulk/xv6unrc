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
                printf(1,"error en el fork\n");
                break;
        case 0:
                printf(1,"soy el hijo mi pid es: %d\n",pid);
                exit();
                break;
                
       default:
                printf(1,"entreeeeeeeeeeee \n");
                wait();
                printf(1,"entreeeeeeeeeeee 2323232\n");
                printf(1,"soy el padre mi pid es: %d\n",pid);
                exit();
                break;
    }
    
   return 0;
}

