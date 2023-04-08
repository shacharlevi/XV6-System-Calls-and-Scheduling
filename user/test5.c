#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
// #include "kernel/proc.h"
// void set_ps_priority(int priority);

// int main()
// {
// //     // Set up process priority values
// //     int p1_priority = 10;
// //     int p2_priority = 5;
// //     int p3_priority = 1;
// //     // Create 3 child processes
// //     int pid1 = fork();
// //     if (pid1 == 0) {
// //         // Child process 1
//         // printf("child1 process priority before set: %d\n", get_ps_priority(getpid()));
// //         set_ps_priority(p1_priority);
// //         printf("Child 1 (pid %d) created and set with priority %d\n", getpid(), get_ps_priority( getpid()));
// //         for (int i = 0; i < 100000000; i++) {
// //             // Do some work
// //         }
// //         printf("Child 1 (pid %d) finished\n", getpid());
// //         exit(0,"");
// //     }

// //     int pid2 = fork();
// //     if (pid2 == 0) {
// //         // Child process 2
// //         printf("child2 process priority before set: %d\n", get_ps_priority(getpid()));
// //         set_ps_priority(p2_priority);
// //         printf("Child 2 (pid %d) created and set with priority %d\n", getpid(),get_ps_priority( getpid()));
// //         for (int i = 0; i < 100000000; i++) {
// //             // Do some work
// //         }
// //         printf("Child 2 (pid %d) finished\n", getpid());
// //         exit(0,"");
// //     }

// //     int pid3 = fork();
// //     if (pid3 == 0) {
// //         printf("child3 process priority before set: %d\n", get_ps_priority(getpid()));
// //         // Child process 3
// //         set_ps_priority(p3_priority);
// //         printf("Child 3 (pid %d) created and set with priority %d\n", getpid(),get_ps_priority( getpid()));
// //         for (int i = 0; i < 100000000; i++) {
// //             // Do some work
// //         }
// //         printf("Child 3 (pid %d) finished\n", getpid());
// //         exit(0,"");
// //     }

// //     // Wait for all child processes to finish
// //     int status;
// //     wait(&status,"");
// //     wait(&status,"");
// //     wait(&status,"");
// //         exit(0,"");

// //     return 0;
// // }
int main(int argc, char *argv[]) {
  // int pid;
if(fork()==0){
    set_ps_priority(10);
    for(;;){
        // printf("child1(pid=%d) process priority before set: %d\n",  getpid(),get_ps_priority(getpid()));
    }
}
else{
    set_ps_priority(1);
    for(;;){
        // printf("parent(pid=%d) process priority before set: %d\n",  getpid(),get_ps_priority(getpid()));
}
}
//     int p1_priority = 10;
//     int p2_priority = 5;
//     int p3_priority = 1;

//   for (int i = 0; i < 3; i++) {
//     int pid = fork();
//     if (pid == 0) { // child process
//       if (i == 0) {
//         // printf("child1(pid=%d) process priority before set: %d\n",  getpid(),get_ps_priority(getpid()));
//         set_ps_priority(p1_priority);
//         // printf("Child 1 (pid %d) created and set with priority %d\n", getpid(), get_ps_priority(getpid()));
//       } else if (i == 1) {
//         // printf("child2 (pid=%d) process priority before set: %d\n",  getpid(),get_ps_priority(getpid()));
//         set_ps_priority(p2_priority);
//         // printf("Child 2 (pid %d) created and set with priority %d\n", getpid(),get_ps_priority( getpid()));
//       } else if (i == 2) {
//             // printf("child3 (pid=%d) process priority before set: %d\n",  getpid(),get_ps_priority(getpid()));
//         set_ps_priority(p3_priority);
//       // //   for (int j = 0; j < 1000000; j++) {
//       // //   if (j % 100000 == 0) {
//       // //     sleep(10); // sleep for 1 second
//       // //   }
//       // // }
//       //   // printf("Child 3 (pid %d) created and set with priority %d\n", getpid(),get_ps_priority( getpid()));      
//       }
      
      
      
//         // sleep(100);
     
//         printf("Child (pid %d) finished\n", getpid());
       
//         exit(0,"");
//       } else if (pid < 0) {
//             fprintf(1, "Fork failed\n");
//     }
//      wait(0,"");
//   }
//   wait(0,"");
//   wait(0,"");
//   wait(0,"");
//   exit(0,"");
  return 0 ;
}
