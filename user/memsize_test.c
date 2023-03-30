#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"

 int main(int argc, char** argv){
    fprintf(1,"The process starting size: %d\n",memsize());
    int* ptr=(int*)malloc(20000);
    if (ptr<0){
        fprintf(1,"ERROR\n");
        exit(-1,"");
    }
    fprintf(1,"The process size after allocation: %d\n",memsize());
    free(ptr);
    fprintf(1,"The process size after allocation and free:%d\n",memsize());
    exit(0,"");
 }