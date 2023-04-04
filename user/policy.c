#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"

// int change_policy(int p);

int main(int argc, char *argv[]) {
    if (argc !=2){
        printf("no argument inserted\n");
        return -1;
    }
    
    int i=set_policy(atoi(argv[1]));
    printf("policy succecfuly changed to:%d\n",atoi(argv[1]));
    return i;
    
}