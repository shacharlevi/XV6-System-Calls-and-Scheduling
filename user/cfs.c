#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
int main(int argc, char *argv[]) {
  int pid, i;

  for (i = 0; i < 3; i++) {
    pid = fork();
    if (pid == 0) { // child process
      if (i == 0) {
        set_cfs_priority(0);
      } else if (i == 1) {
        set_cfs_priority(1);
      } else if (i == 2) {
        set_cfs_priority(2);
      }

      int j;
      for (j = 0; j < 1000000; j++) {
        if (j % 100000 == 0) {
          sleep(10); // sleep for 1 second
        }
      }
      int ans[4];

      if (get_cfs_stats(ans,getpid()) < 0) {
        sleep(100);
        fprintf(1, "Error getting process statistics\n");
      } else {
        sleep(100);
        fprintf(1, "Child (pid %d) finished,CFS priority: %d,Run time: %d ticks,Sleep time: %d ticks, Runnable time: %d ticks \n", getpid(),ans[0],ans[1],ans[2],ans[3]);
        
      }

      exit(0,"");
    } else if (pid < 0) {
      fprintf(1, "Fork failed\n");
    }
     wait(0,"");
  }
  exit(0,"");
  return 0 ;
}