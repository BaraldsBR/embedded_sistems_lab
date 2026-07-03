#include <stdio.h>

#include "time.h"

int main(int argc, char *argv[])
{
  int step;
  double a = 42069.0f;

  long time_loop_start;
  long time_loop_end;
  long elapsed_usec;

  printf("start time;end time;elapsed utime;\n");
  
  for (step = 0; step < 100000; step++) {
    time_loop_start = time_time();

    for(int i = 0; i < 10000; i++) {
        a = 1/a;
    }

    time_loop_end = time_time();

    elapsed_usec = time_loop_end - time_loop_start;
    
    printf("%ld;%ld;%ld;\n",
      time_loop_start % 1000000000,
      time_loop_end % 1000000000,
      elapsed_usec);

    precise_sleep(1000 - elapsed_usec);
  }

  return 0;
}