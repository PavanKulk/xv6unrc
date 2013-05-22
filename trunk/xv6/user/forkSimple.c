// Test that fork fails gracefully.
// Tiny executable so that the limit can be filling the proc table.


#include "types.h"
#include "stat.h"
#include "user.h"


/*
void
printf(int fd, char *s, ...)
{
  write(fd, s, strlen(s));
}
*/

int
main(void)
{
   int pid;
   pid = fork();
    if(pid < 0){
        printf(1, "fork simple Error en el fork\n");
    }else{
        if(pid > 0){
        printf(1, "Soy el Padre :) \n");
        wait();
        }else{      //(pid == 0)
            printf(1, "Soy el hijo :P \n");
            exit();
        }
    }
   return 0;
}

