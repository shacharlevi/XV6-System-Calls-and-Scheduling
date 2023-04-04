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
        // sleep(100);
        // fprintf(1, "Low priority child (pid %d) started\n",pid);
      } else if (i == 1) {
        set_cfs_priority(1);
        // sleep(100);
        // fprintf(1, "Normal priority child (pid %d) started\n", pid);
      } else if (i == 2) {
        set_cfs_priority(2);
        // sleep(100);
        // fprintf(1, "High priority child (pid %d) started\n", pid);
      }

      int j;
      for (j = 0; j < 1000000; j++) {
        if (j % 100000 == 0) {
          sleep(10); // sleep for 1 second
        }
      }
      int ans[4];
      // printf("pid in cfs=%d\n",pid);
      if (get_cfs_stats(ans,getpid()) < 0) {
        sleep(100);
        fprintf(1, "Error getting process statistics\n");
      } else {
        sleep(100);
        fprintf(1, "Child (pid %d) finished,CFS priority: %d,Run time: %d ticks,Sleep time: %d ticks, Runnable time: %d ticks \n", getpid(),ans[0],ans[1],ans[2],ans[3]);
        // sleep(100);
        // fprintf(1, "  CFS priority: %d\n", ans[0]);
        // sleep(100);
        // fprintf(1, "  Run time: %d ticks\n", ans[1]);
        // sleep(100);
        // fprintf(1, "  Sleep time: %d ticks\n", ans[2]);
        // sleep(100);
        // fprintf(1, "  Runnable time: %d ticks\n", ans[3]);
      }

      exit(0,"");
    } else if (pid < 0) {
      fprintf(1, "Fork failed\n");
    }
     wait(0,"");
  }

  // wait for all child processes to finish
  for (i = 0; i < 3; i++) {
    wait(0,"");
  }
    exit(0,"");
  return 0 ;
}