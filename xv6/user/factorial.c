#include "types.h"
#include "stat.h"
#include "user.h"

 
int factorial(int n)
{
  if (n == 0)
    return 1;
  else
    return(n * factorial(n-1));
} 

int main(void)
{
  int n = 5;
  int f = 1;
 
    f = factorial(n);
    printf(1,"%d! = %d\n", n, f);
  
 
  return 0;
}
 

