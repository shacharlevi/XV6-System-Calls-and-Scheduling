
user/_cfs:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
int main(int argc, char *argv[]) {
   0:	715d                	addi	sp,sp,-80
   2:	e486                	sd	ra,72(sp)
   4:	e0a2                	sd	s0,64(sp)
   6:	fc26                	sd	s1,56(sp)
   8:	f84a                	sd	s2,48(sp)
   a:	f44e                	sd	s3,40(sp)
   c:	f052                	sd	s4,32(sp)
   e:	ec56                	sd	s5,24(sp)
  10:	0880                	addi	s0,sp,80
  int pid, i;

  for (i = 0; i < 3; i++) {
  12:	4901                	li	s2,0
        // fprintf(1, "  Runnable time: %d ticks\n", ans[3]);
      }

      exit(0,"");
    } else if (pid < 0) {
      fprintf(1, "Fork failed\n");
  14:	00001a97          	auipc	s5,0x1
  18:	9eca8a93          	addi	s5,s5,-1556 # a00 <malloc+0x192>
    }
     wait(0,"");
  1c:	00001a17          	auipc	s4,0x1
  20:	9dca0a13          	addi	s4,s4,-1572 # 9f8 <malloc+0x18a>
  for (i = 0; i < 3; i++) {
  24:	498d                	li	s3,3
  26:	a8d5                	j	11a <main+0x11a>
      if (i == 0) {
  28:	02090063          	beqz	s2,48 <main+0x48>
      } else if (i == 1) {
  2c:	4785                	li	a5,1
  2e:	02f90363          	beq	s2,a5,54 <main+0x54>
      } else if (i == 2) {
  32:	4789                	li	a5,2
  34:	02f90663          	beq	s2,a5,60 <main+0x60>
        if (j % 100000 == 0) {
  38:	69e1                	lui	s3,0x18
  3a:	6a09899b          	addiw	s3,s3,1696
      for (j = 0; j < 1000000; j++) {
  3e:	000f4937          	lui	s2,0xf4
  42:	24090913          	addi	s2,s2,576 # f4240 <base+0xf3230>
  46:	a035                	j	72 <main+0x72>
        set_cfs_priority(0);
  48:	4501                	li	a0,0
  4a:	00000097          	auipc	ra,0x0
  4e:	476080e7          	jalr	1142(ra) # 4c0 <set_cfs_priority>
  52:	b7dd                	j	38 <main+0x38>
        set_cfs_priority(1);
  54:	4505                	li	a0,1
  56:	00000097          	auipc	ra,0x0
  5a:	46a080e7          	jalr	1130(ra) # 4c0 <set_cfs_priority>
  5e:	bfe9                	j	38 <main+0x38>
        set_cfs_priority(2);
  60:	4509                	li	a0,2
  62:	00000097          	auipc	ra,0x0
  66:	45e080e7          	jalr	1118(ra) # 4c0 <set_cfs_priority>
  6a:	b7f9                	j	38 <main+0x38>
      for (j = 0; j < 1000000; j++) {
  6c:	2485                	addiw	s1,s1,1
  6e:	01248b63          	beq	s1,s2,84 <main+0x84>
        if (j % 100000 == 0) {
  72:	0334e7bb          	remw	a5,s1,s3
  76:	fbfd                	bnez	a5,6c <main+0x6c>
          sleep(10); // sleep for 1 second
  78:	4529                	li	a0,10
  7a:	00000097          	auipc	ra,0x0
  7e:	426080e7          	jalr	1062(ra) # 4a0 <sleep>
  82:	b7ed                	j	6c <main+0x6c>
      if (get_cfs_stats(ans,getpid()) < 0) {
  84:	00000097          	auipc	ra,0x0
  88:	40c080e7          	jalr	1036(ra) # 490 <getpid>
  8c:	85aa                	mv	a1,a0
  8e:	fb040513          	addi	a0,s0,-80
  92:	00000097          	auipc	ra,0x0
  96:	436080e7          	jalr	1078(ra) # 4c8 <get_cfs_stats>
  9a:	04054763          	bltz	a0,e8 <main+0xe8>
        sleep(100);
  9e:	06400513          	li	a0,100
  a2:	00000097          	auipc	ra,0x0
  a6:	3fe080e7          	jalr	1022(ra) # 4a0 <sleep>
        fprintf(1, "Child (pid %d) finished,CFS priority: %d,Run time: %d ticks,Sleep time: %d ticks, Runnable time: %d ticks \n", getpid(),ans[0],ans[1],ans[2],ans[3]);
  aa:	00000097          	auipc	ra,0x0
  ae:	3e6080e7          	jalr	998(ra) # 490 <getpid>
  b2:	862a                	mv	a2,a0
  b4:	fbc42803          	lw	a6,-68(s0)
  b8:	fb842783          	lw	a5,-72(s0)
  bc:	fb442703          	lw	a4,-76(s0)
  c0:	fb042683          	lw	a3,-80(s0)
  c4:	00001597          	auipc	a1,0x1
  c8:	8c458593          	addi	a1,a1,-1852 # 988 <malloc+0x11a>
  cc:	4505                	li	a0,1
  ce:	00000097          	auipc	ra,0x0
  d2:	6b4080e7          	jalr	1716(ra) # 782 <fprintf>
      exit(0,"");
  d6:	00001597          	auipc	a1,0x1
  da:	92258593          	addi	a1,a1,-1758 # 9f8 <malloc+0x18a>
  de:	4501                	li	a0,0
  e0:	00000097          	auipc	ra,0x0
  e4:	330080e7          	jalr	816(ra) # 410 <exit>
        sleep(100);
  e8:	06400513          	li	a0,100
  ec:	00000097          	auipc	ra,0x0
  f0:	3b4080e7          	jalr	948(ra) # 4a0 <sleep>
        fprintf(1, "Error getting process statistics\n");
  f4:	00001597          	auipc	a1,0x1
  f8:	86c58593          	addi	a1,a1,-1940 # 960 <malloc+0xf2>
  fc:	4505                	li	a0,1
  fe:	00000097          	auipc	ra,0x0
 102:	684080e7          	jalr	1668(ra) # 782 <fprintf>
 106:	bfc1                	j	d6 <main+0xd6>
     wait(0,"");
 108:	85d2                	mv	a1,s4
 10a:	4501                	li	a0,0
 10c:	00000097          	auipc	ra,0x0
 110:	30c080e7          	jalr	780(ra) # 418 <wait>
  for (i = 0; i < 3; i++) {
 114:	2905                	addiw	s2,s2,1
 116:	03390163          	beq	s2,s3,138 <main+0x138>
    pid = fork();
 11a:	00000097          	auipc	ra,0x0
 11e:	2ee080e7          	jalr	750(ra) # 408 <fork>
 122:	84aa                	mv	s1,a0
    if (pid == 0) { // child process
 124:	d111                	beqz	a0,28 <main+0x28>
    } else if (pid < 0) {
 126:	fe0551e3          	bgez	a0,108 <main+0x108>
      fprintf(1, "Fork failed\n");
 12a:	85d6                	mv	a1,s5
 12c:	4505                	li	a0,1
 12e:	00000097          	auipc	ra,0x0
 132:	654080e7          	jalr	1620(ra) # 782 <fprintf>
 136:	bfc9                	j	108 <main+0x108>
  }

  // wait for all child processes to finish
  for (i = 0; i < 3; i++) {
    wait(0,"");
 138:	00001597          	auipc	a1,0x1
 13c:	8c058593          	addi	a1,a1,-1856 # 9f8 <malloc+0x18a>
 140:	4501                	li	a0,0
 142:	00000097          	auipc	ra,0x0
 146:	2d6080e7          	jalr	726(ra) # 418 <wait>
 14a:	00001597          	auipc	a1,0x1
 14e:	8ae58593          	addi	a1,a1,-1874 # 9f8 <malloc+0x18a>
 152:	4501                	li	a0,0
 154:	00000097          	auipc	ra,0x0
 158:	2c4080e7          	jalr	708(ra) # 418 <wait>
 15c:	00001597          	auipc	a1,0x1
 160:	89c58593          	addi	a1,a1,-1892 # 9f8 <malloc+0x18a>
 164:	4501                	li	a0,0
 166:	00000097          	auipc	ra,0x0
 16a:	2b2080e7          	jalr	690(ra) # 418 <wait>
  }
    exit(0,"");
 16e:	00001597          	auipc	a1,0x1
 172:	88a58593          	addi	a1,a1,-1910 # 9f8 <malloc+0x18a>
 176:	4501                	li	a0,0
 178:	00000097          	auipc	ra,0x0
 17c:	298080e7          	jalr	664(ra) # 410 <exit>

0000000000000180 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 180:	1141                	addi	sp,sp,-16
 182:	e406                	sd	ra,8(sp)
 184:	e022                	sd	s0,0(sp)
 186:	0800                	addi	s0,sp,16
  extern int main();
  main();
 188:	00000097          	auipc	ra,0x0
 18c:	e78080e7          	jalr	-392(ra) # 0 <main>
  exit(0,"");
 190:	00001597          	auipc	a1,0x1
 194:	86858593          	addi	a1,a1,-1944 # 9f8 <malloc+0x18a>
 198:	4501                	li	a0,0
 19a:	00000097          	auipc	ra,0x0
 19e:	276080e7          	jalr	630(ra) # 410 <exit>

00000000000001a2 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1a2:	1141                	addi	sp,sp,-16
 1a4:	e422                	sd	s0,8(sp)
 1a6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1a8:	87aa                	mv	a5,a0
 1aa:	0585                	addi	a1,a1,1
 1ac:	0785                	addi	a5,a5,1
 1ae:	fff5c703          	lbu	a4,-1(a1)
 1b2:	fee78fa3          	sb	a4,-1(a5)
 1b6:	fb75                	bnez	a4,1aa <strcpy+0x8>
    ;
  return os;
}
 1b8:	6422                	ld	s0,8(sp)
 1ba:	0141                	addi	sp,sp,16
 1bc:	8082                	ret

00000000000001be <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1be:	1141                	addi	sp,sp,-16
 1c0:	e422                	sd	s0,8(sp)
 1c2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1c4:	00054783          	lbu	a5,0(a0)
 1c8:	cb91                	beqz	a5,1dc <strcmp+0x1e>
 1ca:	0005c703          	lbu	a4,0(a1)
 1ce:	00f71763          	bne	a4,a5,1dc <strcmp+0x1e>
    p++, q++;
 1d2:	0505                	addi	a0,a0,1
 1d4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1d6:	00054783          	lbu	a5,0(a0)
 1da:	fbe5                	bnez	a5,1ca <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1dc:	0005c503          	lbu	a0,0(a1)
}
 1e0:	40a7853b          	subw	a0,a5,a0
 1e4:	6422                	ld	s0,8(sp)
 1e6:	0141                	addi	sp,sp,16
 1e8:	8082                	ret

00000000000001ea <strlen>:

uint
strlen(const char *s)
{
 1ea:	1141                	addi	sp,sp,-16
 1ec:	e422                	sd	s0,8(sp)
 1ee:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1f0:	00054783          	lbu	a5,0(a0)
 1f4:	cf91                	beqz	a5,210 <strlen+0x26>
 1f6:	0505                	addi	a0,a0,1
 1f8:	87aa                	mv	a5,a0
 1fa:	4685                	li	a3,1
 1fc:	9e89                	subw	a3,a3,a0
 1fe:	00f6853b          	addw	a0,a3,a5
 202:	0785                	addi	a5,a5,1
 204:	fff7c703          	lbu	a4,-1(a5)
 208:	fb7d                	bnez	a4,1fe <strlen+0x14>
    ;
  return n;
}
 20a:	6422                	ld	s0,8(sp)
 20c:	0141                	addi	sp,sp,16
 20e:	8082                	ret
  for(n = 0; s[n]; n++)
 210:	4501                	li	a0,0
 212:	bfe5                	j	20a <strlen+0x20>

0000000000000214 <memset>:

void*
memset(void *dst, int c, uint n)
{
 214:	1141                	addi	sp,sp,-16
 216:	e422                	sd	s0,8(sp)
 218:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 21a:	ca19                	beqz	a2,230 <memset+0x1c>
 21c:	87aa                	mv	a5,a0
 21e:	1602                	slli	a2,a2,0x20
 220:	9201                	srli	a2,a2,0x20
 222:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 226:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 22a:	0785                	addi	a5,a5,1
 22c:	fee79de3          	bne	a5,a4,226 <memset+0x12>
  }
  return dst;
}
 230:	6422                	ld	s0,8(sp)
 232:	0141                	addi	sp,sp,16
 234:	8082                	ret

0000000000000236 <strchr>:

char*
strchr(const char *s, char c)
{
 236:	1141                	addi	sp,sp,-16
 238:	e422                	sd	s0,8(sp)
 23a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 23c:	00054783          	lbu	a5,0(a0)
 240:	cb99                	beqz	a5,256 <strchr+0x20>
    if(*s == c)
 242:	00f58763          	beq	a1,a5,250 <strchr+0x1a>
  for(; *s; s++)
 246:	0505                	addi	a0,a0,1
 248:	00054783          	lbu	a5,0(a0)
 24c:	fbfd                	bnez	a5,242 <strchr+0xc>
      return (char*)s;
  return 0;
 24e:	4501                	li	a0,0
}
 250:	6422                	ld	s0,8(sp)
 252:	0141                	addi	sp,sp,16
 254:	8082                	ret
  return 0;
 256:	4501                	li	a0,0
 258:	bfe5                	j	250 <strchr+0x1a>

000000000000025a <gets>:

char*
gets(char *buf, int max)
{
 25a:	711d                	addi	sp,sp,-96
 25c:	ec86                	sd	ra,88(sp)
 25e:	e8a2                	sd	s0,80(sp)
 260:	e4a6                	sd	s1,72(sp)
 262:	e0ca                	sd	s2,64(sp)
 264:	fc4e                	sd	s3,56(sp)
 266:	f852                	sd	s4,48(sp)
 268:	f456                	sd	s5,40(sp)
 26a:	f05a                	sd	s6,32(sp)
 26c:	ec5e                	sd	s7,24(sp)
 26e:	1080                	addi	s0,sp,96
 270:	8baa                	mv	s7,a0
 272:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 274:	892a                	mv	s2,a0
 276:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 278:	4aa9                	li	s5,10
 27a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 27c:	89a6                	mv	s3,s1
 27e:	2485                	addiw	s1,s1,1
 280:	0344d863          	bge	s1,s4,2b0 <gets+0x56>
    cc = read(0, &c, 1);
 284:	4605                	li	a2,1
 286:	faf40593          	addi	a1,s0,-81
 28a:	4501                	li	a0,0
 28c:	00000097          	auipc	ra,0x0
 290:	19c080e7          	jalr	412(ra) # 428 <read>
    if(cc < 1)
 294:	00a05e63          	blez	a0,2b0 <gets+0x56>
    buf[i++] = c;
 298:	faf44783          	lbu	a5,-81(s0)
 29c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2a0:	01578763          	beq	a5,s5,2ae <gets+0x54>
 2a4:	0905                	addi	s2,s2,1
 2a6:	fd679be3          	bne	a5,s6,27c <gets+0x22>
  for(i=0; i+1 < max; ){
 2aa:	89a6                	mv	s3,s1
 2ac:	a011                	j	2b0 <gets+0x56>
 2ae:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2b0:	99de                	add	s3,s3,s7
 2b2:	00098023          	sb	zero,0(s3) # 18000 <base+0x16ff0>
  return buf;
}
 2b6:	855e                	mv	a0,s7
 2b8:	60e6                	ld	ra,88(sp)
 2ba:	6446                	ld	s0,80(sp)
 2bc:	64a6                	ld	s1,72(sp)
 2be:	6906                	ld	s2,64(sp)
 2c0:	79e2                	ld	s3,56(sp)
 2c2:	7a42                	ld	s4,48(sp)
 2c4:	7aa2                	ld	s5,40(sp)
 2c6:	7b02                	ld	s6,32(sp)
 2c8:	6be2                	ld	s7,24(sp)
 2ca:	6125                	addi	sp,sp,96
 2cc:	8082                	ret

00000000000002ce <stat>:

int
stat(const char *n, struct stat *st)
{
 2ce:	1101                	addi	sp,sp,-32
 2d0:	ec06                	sd	ra,24(sp)
 2d2:	e822                	sd	s0,16(sp)
 2d4:	e426                	sd	s1,8(sp)
 2d6:	e04a                	sd	s2,0(sp)
 2d8:	1000                	addi	s0,sp,32
 2da:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2dc:	4581                	li	a1,0
 2de:	00000097          	auipc	ra,0x0
 2e2:	172080e7          	jalr	370(ra) # 450 <open>
  if(fd < 0)
 2e6:	02054563          	bltz	a0,310 <stat+0x42>
 2ea:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2ec:	85ca                	mv	a1,s2
 2ee:	00000097          	auipc	ra,0x0
 2f2:	17a080e7          	jalr	378(ra) # 468 <fstat>
 2f6:	892a                	mv	s2,a0
  close(fd);
 2f8:	8526                	mv	a0,s1
 2fa:	00000097          	auipc	ra,0x0
 2fe:	13e080e7          	jalr	318(ra) # 438 <close>
  return r;
}
 302:	854a                	mv	a0,s2
 304:	60e2                	ld	ra,24(sp)
 306:	6442                	ld	s0,16(sp)
 308:	64a2                	ld	s1,8(sp)
 30a:	6902                	ld	s2,0(sp)
 30c:	6105                	addi	sp,sp,32
 30e:	8082                	ret
    return -1;
 310:	597d                	li	s2,-1
 312:	bfc5                	j	302 <stat+0x34>

0000000000000314 <atoi>:

int
atoi(const char *s)
{
 314:	1141                	addi	sp,sp,-16
 316:	e422                	sd	s0,8(sp)
 318:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 31a:	00054603          	lbu	a2,0(a0)
 31e:	fd06079b          	addiw	a5,a2,-48
 322:	0ff7f793          	andi	a5,a5,255
 326:	4725                	li	a4,9
 328:	02f76963          	bltu	a4,a5,35a <atoi+0x46>
 32c:	86aa                	mv	a3,a0
  n = 0;
 32e:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 330:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 332:	0685                	addi	a3,a3,1
 334:	0025179b          	slliw	a5,a0,0x2
 338:	9fa9                	addw	a5,a5,a0
 33a:	0017979b          	slliw	a5,a5,0x1
 33e:	9fb1                	addw	a5,a5,a2
 340:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 344:	0006c603          	lbu	a2,0(a3)
 348:	fd06071b          	addiw	a4,a2,-48
 34c:	0ff77713          	andi	a4,a4,255
 350:	fee5f1e3          	bgeu	a1,a4,332 <atoi+0x1e>
  return n;
}
 354:	6422                	ld	s0,8(sp)
 356:	0141                	addi	sp,sp,16
 358:	8082                	ret
  n = 0;
 35a:	4501                	li	a0,0
 35c:	bfe5                	j	354 <atoi+0x40>

000000000000035e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 35e:	1141                	addi	sp,sp,-16
 360:	e422                	sd	s0,8(sp)
 362:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 364:	02b57463          	bgeu	a0,a1,38c <memmove+0x2e>
    while(n-- > 0)
 368:	00c05f63          	blez	a2,386 <memmove+0x28>
 36c:	1602                	slli	a2,a2,0x20
 36e:	9201                	srli	a2,a2,0x20
 370:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 374:	872a                	mv	a4,a0
      *dst++ = *src++;
 376:	0585                	addi	a1,a1,1
 378:	0705                	addi	a4,a4,1
 37a:	fff5c683          	lbu	a3,-1(a1)
 37e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 382:	fee79ae3          	bne	a5,a4,376 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 386:	6422                	ld	s0,8(sp)
 388:	0141                	addi	sp,sp,16
 38a:	8082                	ret
    dst += n;
 38c:	00c50733          	add	a4,a0,a2
    src += n;
 390:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 392:	fec05ae3          	blez	a2,386 <memmove+0x28>
 396:	fff6079b          	addiw	a5,a2,-1
 39a:	1782                	slli	a5,a5,0x20
 39c:	9381                	srli	a5,a5,0x20
 39e:	fff7c793          	not	a5,a5
 3a2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3a4:	15fd                	addi	a1,a1,-1
 3a6:	177d                	addi	a4,a4,-1
 3a8:	0005c683          	lbu	a3,0(a1)
 3ac:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3b0:	fee79ae3          	bne	a5,a4,3a4 <memmove+0x46>
 3b4:	bfc9                	j	386 <memmove+0x28>

00000000000003b6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3b6:	1141                	addi	sp,sp,-16
 3b8:	e422                	sd	s0,8(sp)
 3ba:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3bc:	ca05                	beqz	a2,3ec <memcmp+0x36>
 3be:	fff6069b          	addiw	a3,a2,-1
 3c2:	1682                	slli	a3,a3,0x20
 3c4:	9281                	srli	a3,a3,0x20
 3c6:	0685                	addi	a3,a3,1
 3c8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3ca:	00054783          	lbu	a5,0(a0)
 3ce:	0005c703          	lbu	a4,0(a1)
 3d2:	00e79863          	bne	a5,a4,3e2 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3d6:	0505                	addi	a0,a0,1
    p2++;
 3d8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3da:	fed518e3          	bne	a0,a3,3ca <memcmp+0x14>
  }
  return 0;
 3de:	4501                	li	a0,0
 3e0:	a019                	j	3e6 <memcmp+0x30>
      return *p1 - *p2;
 3e2:	40e7853b          	subw	a0,a5,a4
}
 3e6:	6422                	ld	s0,8(sp)
 3e8:	0141                	addi	sp,sp,16
 3ea:	8082                	ret
  return 0;
 3ec:	4501                	li	a0,0
 3ee:	bfe5                	j	3e6 <memcmp+0x30>

00000000000003f0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3f0:	1141                	addi	sp,sp,-16
 3f2:	e406                	sd	ra,8(sp)
 3f4:	e022                	sd	s0,0(sp)
 3f6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3f8:	00000097          	auipc	ra,0x0
 3fc:	f66080e7          	jalr	-154(ra) # 35e <memmove>
}
 400:	60a2                	ld	ra,8(sp)
 402:	6402                	ld	s0,0(sp)
 404:	0141                	addi	sp,sp,16
 406:	8082                	ret

0000000000000408 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 408:	4885                	li	a7,1
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <exit>:
.global exit
exit:
 li a7, SYS_exit
 410:	4889                	li	a7,2
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <wait>:
.global wait
wait:
 li a7, SYS_wait
 418:	488d                	li	a7,3
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 420:	4891                	li	a7,4
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <read>:
.global read
read:
 li a7, SYS_read
 428:	4895                	li	a7,5
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <write>:
.global write
write:
 li a7, SYS_write
 430:	48c1                	li	a7,16
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <close>:
.global close
close:
 li a7, SYS_close
 438:	48d5                	li	a7,21
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <kill>:
.global kill
kill:
 li a7, SYS_kill
 440:	4899                	li	a7,6
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <exec>:
.global exec
exec:
 li a7, SYS_exec
 448:	489d                	li	a7,7
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <open>:
.global open
open:
 li a7, SYS_open
 450:	48bd                	li	a7,15
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 458:	48c5                	li	a7,17
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 460:	48c9                	li	a7,18
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 468:	48a1                	li	a7,8
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <link>:
.global link
link:
 li a7, SYS_link
 470:	48cd                	li	a7,19
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 478:	48d1                	li	a7,20
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 480:	48a5                	li	a7,9
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <dup>:
.global dup
dup:
 li a7, SYS_dup
 488:	48a9                	li	a7,10
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 490:	48ad                	li	a7,11
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 498:	48b1                	li	a7,12
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4a0:	48b5                	li	a7,13
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4a8:	48b9                	li	a7,14
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <memsize>:
.global memsize
memsize:
 li a7, SYS_memsize
 4b0:	48d9                	li	a7,22
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <set_ps_priority>:
.global set_ps_priority
set_ps_priority:
 li a7, SYS_set_ps_priority
 4b8:	48dd                	li	a7,23
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <set_cfs_priority>:
.global set_cfs_priority
set_cfs_priority:
 li a7, SYS_set_cfs_priority
 4c0:	48e1                	li	a7,24
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <get_cfs_stats>:
.global get_cfs_stats
get_cfs_stats:
 li a7, SYS_get_cfs_stats
 4c8:	48e5                	li	a7,25
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <set_policy>:
.global set_policy
set_policy:
 li a7, SYS_set_policy
 4d0:	48e9                	li	a7,26
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4d8:	1101                	addi	sp,sp,-32
 4da:	ec06                	sd	ra,24(sp)
 4dc:	e822                	sd	s0,16(sp)
 4de:	1000                	addi	s0,sp,32
 4e0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4e4:	4605                	li	a2,1
 4e6:	fef40593          	addi	a1,s0,-17
 4ea:	00000097          	auipc	ra,0x0
 4ee:	f46080e7          	jalr	-186(ra) # 430 <write>
}
 4f2:	60e2                	ld	ra,24(sp)
 4f4:	6442                	ld	s0,16(sp)
 4f6:	6105                	addi	sp,sp,32
 4f8:	8082                	ret

00000000000004fa <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4fa:	7139                	addi	sp,sp,-64
 4fc:	fc06                	sd	ra,56(sp)
 4fe:	f822                	sd	s0,48(sp)
 500:	f426                	sd	s1,40(sp)
 502:	f04a                	sd	s2,32(sp)
 504:	ec4e                	sd	s3,24(sp)
 506:	0080                	addi	s0,sp,64
 508:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 50a:	c299                	beqz	a3,510 <printint+0x16>
 50c:	0805c863          	bltz	a1,59c <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 510:	2581                	sext.w	a1,a1
  neg = 0;
 512:	4881                	li	a7,0
 514:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 518:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 51a:	2601                	sext.w	a2,a2
 51c:	00000517          	auipc	a0,0x0
 520:	4fc50513          	addi	a0,a0,1276 # a18 <digits>
 524:	883a                	mv	a6,a4
 526:	2705                	addiw	a4,a4,1
 528:	02c5f7bb          	remuw	a5,a1,a2
 52c:	1782                	slli	a5,a5,0x20
 52e:	9381                	srli	a5,a5,0x20
 530:	97aa                	add	a5,a5,a0
 532:	0007c783          	lbu	a5,0(a5)
 536:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 53a:	0005879b          	sext.w	a5,a1
 53e:	02c5d5bb          	divuw	a1,a1,a2
 542:	0685                	addi	a3,a3,1
 544:	fec7f0e3          	bgeu	a5,a2,524 <printint+0x2a>
  if(neg)
 548:	00088b63          	beqz	a7,55e <printint+0x64>
    buf[i++] = '-';
 54c:	fd040793          	addi	a5,s0,-48
 550:	973e                	add	a4,a4,a5
 552:	02d00793          	li	a5,45
 556:	fef70823          	sb	a5,-16(a4)
 55a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 55e:	02e05863          	blez	a4,58e <printint+0x94>
 562:	fc040793          	addi	a5,s0,-64
 566:	00e78933          	add	s2,a5,a4
 56a:	fff78993          	addi	s3,a5,-1
 56e:	99ba                	add	s3,s3,a4
 570:	377d                	addiw	a4,a4,-1
 572:	1702                	slli	a4,a4,0x20
 574:	9301                	srli	a4,a4,0x20
 576:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 57a:	fff94583          	lbu	a1,-1(s2)
 57e:	8526                	mv	a0,s1
 580:	00000097          	auipc	ra,0x0
 584:	f58080e7          	jalr	-168(ra) # 4d8 <putc>
  while(--i >= 0)
 588:	197d                	addi	s2,s2,-1
 58a:	ff3918e3          	bne	s2,s3,57a <printint+0x80>
}
 58e:	70e2                	ld	ra,56(sp)
 590:	7442                	ld	s0,48(sp)
 592:	74a2                	ld	s1,40(sp)
 594:	7902                	ld	s2,32(sp)
 596:	69e2                	ld	s3,24(sp)
 598:	6121                	addi	sp,sp,64
 59a:	8082                	ret
    x = -xx;
 59c:	40b005bb          	negw	a1,a1
    neg = 1;
 5a0:	4885                	li	a7,1
    x = -xx;
 5a2:	bf8d                	j	514 <printint+0x1a>

00000000000005a4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5a4:	7119                	addi	sp,sp,-128
 5a6:	fc86                	sd	ra,120(sp)
 5a8:	f8a2                	sd	s0,112(sp)
 5aa:	f4a6                	sd	s1,104(sp)
 5ac:	f0ca                	sd	s2,96(sp)
 5ae:	ecce                	sd	s3,88(sp)
 5b0:	e8d2                	sd	s4,80(sp)
 5b2:	e4d6                	sd	s5,72(sp)
 5b4:	e0da                	sd	s6,64(sp)
 5b6:	fc5e                	sd	s7,56(sp)
 5b8:	f862                	sd	s8,48(sp)
 5ba:	f466                	sd	s9,40(sp)
 5bc:	f06a                	sd	s10,32(sp)
 5be:	ec6e                	sd	s11,24(sp)
 5c0:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5c2:	0005c903          	lbu	s2,0(a1)
 5c6:	18090f63          	beqz	s2,764 <vprintf+0x1c0>
 5ca:	8aaa                	mv	s5,a0
 5cc:	8b32                	mv	s6,a2
 5ce:	00158493          	addi	s1,a1,1
  state = 0;
 5d2:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5d4:	02500a13          	li	s4,37
      if(c == 'd'){
 5d8:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 5dc:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 5e0:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 5e4:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5e8:	00000b97          	auipc	s7,0x0
 5ec:	430b8b93          	addi	s7,s7,1072 # a18 <digits>
 5f0:	a839                	j	60e <vprintf+0x6a>
        putc(fd, c);
 5f2:	85ca                	mv	a1,s2
 5f4:	8556                	mv	a0,s5
 5f6:	00000097          	auipc	ra,0x0
 5fa:	ee2080e7          	jalr	-286(ra) # 4d8 <putc>
 5fe:	a019                	j	604 <vprintf+0x60>
    } else if(state == '%'){
 600:	01498f63          	beq	s3,s4,61e <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 604:	0485                	addi	s1,s1,1
 606:	fff4c903          	lbu	s2,-1(s1)
 60a:	14090d63          	beqz	s2,764 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 60e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 612:	fe0997e3          	bnez	s3,600 <vprintf+0x5c>
      if(c == '%'){
 616:	fd479ee3          	bne	a5,s4,5f2 <vprintf+0x4e>
        state = '%';
 61a:	89be                	mv	s3,a5
 61c:	b7e5                	j	604 <vprintf+0x60>
      if(c == 'd'){
 61e:	05878063          	beq	a5,s8,65e <vprintf+0xba>
      } else if(c == 'l') {
 622:	05978c63          	beq	a5,s9,67a <vprintf+0xd6>
      } else if(c == 'x') {
 626:	07a78863          	beq	a5,s10,696 <vprintf+0xf2>
      } else if(c == 'p') {
 62a:	09b78463          	beq	a5,s11,6b2 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 62e:	07300713          	li	a4,115
 632:	0ce78663          	beq	a5,a4,6fe <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 636:	06300713          	li	a4,99
 63a:	0ee78e63          	beq	a5,a4,736 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 63e:	11478863          	beq	a5,s4,74e <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 642:	85d2                	mv	a1,s4
 644:	8556                	mv	a0,s5
 646:	00000097          	auipc	ra,0x0
 64a:	e92080e7          	jalr	-366(ra) # 4d8 <putc>
        putc(fd, c);
 64e:	85ca                	mv	a1,s2
 650:	8556                	mv	a0,s5
 652:	00000097          	auipc	ra,0x0
 656:	e86080e7          	jalr	-378(ra) # 4d8 <putc>
      }
      state = 0;
 65a:	4981                	li	s3,0
 65c:	b765                	j	604 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 65e:	008b0913          	addi	s2,s6,8
 662:	4685                	li	a3,1
 664:	4629                	li	a2,10
 666:	000b2583          	lw	a1,0(s6)
 66a:	8556                	mv	a0,s5
 66c:	00000097          	auipc	ra,0x0
 670:	e8e080e7          	jalr	-370(ra) # 4fa <printint>
 674:	8b4a                	mv	s6,s2
      state = 0;
 676:	4981                	li	s3,0
 678:	b771                	j	604 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 67a:	008b0913          	addi	s2,s6,8
 67e:	4681                	li	a3,0
 680:	4629                	li	a2,10
 682:	000b2583          	lw	a1,0(s6)
 686:	8556                	mv	a0,s5
 688:	00000097          	auipc	ra,0x0
 68c:	e72080e7          	jalr	-398(ra) # 4fa <printint>
 690:	8b4a                	mv	s6,s2
      state = 0;
 692:	4981                	li	s3,0
 694:	bf85                	j	604 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 696:	008b0913          	addi	s2,s6,8
 69a:	4681                	li	a3,0
 69c:	4641                	li	a2,16
 69e:	000b2583          	lw	a1,0(s6)
 6a2:	8556                	mv	a0,s5
 6a4:	00000097          	auipc	ra,0x0
 6a8:	e56080e7          	jalr	-426(ra) # 4fa <printint>
 6ac:	8b4a                	mv	s6,s2
      state = 0;
 6ae:	4981                	li	s3,0
 6b0:	bf91                	j	604 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6b2:	008b0793          	addi	a5,s6,8
 6b6:	f8f43423          	sd	a5,-120(s0)
 6ba:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6be:	03000593          	li	a1,48
 6c2:	8556                	mv	a0,s5
 6c4:	00000097          	auipc	ra,0x0
 6c8:	e14080e7          	jalr	-492(ra) # 4d8 <putc>
  putc(fd, 'x');
 6cc:	85ea                	mv	a1,s10
 6ce:	8556                	mv	a0,s5
 6d0:	00000097          	auipc	ra,0x0
 6d4:	e08080e7          	jalr	-504(ra) # 4d8 <putc>
 6d8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6da:	03c9d793          	srli	a5,s3,0x3c
 6de:	97de                	add	a5,a5,s7
 6e0:	0007c583          	lbu	a1,0(a5)
 6e4:	8556                	mv	a0,s5
 6e6:	00000097          	auipc	ra,0x0
 6ea:	df2080e7          	jalr	-526(ra) # 4d8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6ee:	0992                	slli	s3,s3,0x4
 6f0:	397d                	addiw	s2,s2,-1
 6f2:	fe0914e3          	bnez	s2,6da <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6f6:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6fa:	4981                	li	s3,0
 6fc:	b721                	j	604 <vprintf+0x60>
        s = va_arg(ap, char*);
 6fe:	008b0993          	addi	s3,s6,8
 702:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 706:	02090163          	beqz	s2,728 <vprintf+0x184>
        while(*s != 0){
 70a:	00094583          	lbu	a1,0(s2)
 70e:	c9a1                	beqz	a1,75e <vprintf+0x1ba>
          putc(fd, *s);
 710:	8556                	mv	a0,s5
 712:	00000097          	auipc	ra,0x0
 716:	dc6080e7          	jalr	-570(ra) # 4d8 <putc>
          s++;
 71a:	0905                	addi	s2,s2,1
        while(*s != 0){
 71c:	00094583          	lbu	a1,0(s2)
 720:	f9e5                	bnez	a1,710 <vprintf+0x16c>
        s = va_arg(ap, char*);
 722:	8b4e                	mv	s6,s3
      state = 0;
 724:	4981                	li	s3,0
 726:	bdf9                	j	604 <vprintf+0x60>
          s = "(null)";
 728:	00000917          	auipc	s2,0x0
 72c:	2e890913          	addi	s2,s2,744 # a10 <malloc+0x1a2>
        while(*s != 0){
 730:	02800593          	li	a1,40
 734:	bff1                	j	710 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 736:	008b0913          	addi	s2,s6,8
 73a:	000b4583          	lbu	a1,0(s6)
 73e:	8556                	mv	a0,s5
 740:	00000097          	auipc	ra,0x0
 744:	d98080e7          	jalr	-616(ra) # 4d8 <putc>
 748:	8b4a                	mv	s6,s2
      state = 0;
 74a:	4981                	li	s3,0
 74c:	bd65                	j	604 <vprintf+0x60>
        putc(fd, c);
 74e:	85d2                	mv	a1,s4
 750:	8556                	mv	a0,s5
 752:	00000097          	auipc	ra,0x0
 756:	d86080e7          	jalr	-634(ra) # 4d8 <putc>
      state = 0;
 75a:	4981                	li	s3,0
 75c:	b565                	j	604 <vprintf+0x60>
        s = va_arg(ap, char*);
 75e:	8b4e                	mv	s6,s3
      state = 0;
 760:	4981                	li	s3,0
 762:	b54d                	j	604 <vprintf+0x60>
    }
  }
}
 764:	70e6                	ld	ra,120(sp)
 766:	7446                	ld	s0,112(sp)
 768:	74a6                	ld	s1,104(sp)
 76a:	7906                	ld	s2,96(sp)
 76c:	69e6                	ld	s3,88(sp)
 76e:	6a46                	ld	s4,80(sp)
 770:	6aa6                	ld	s5,72(sp)
 772:	6b06                	ld	s6,64(sp)
 774:	7be2                	ld	s7,56(sp)
 776:	7c42                	ld	s8,48(sp)
 778:	7ca2                	ld	s9,40(sp)
 77a:	7d02                	ld	s10,32(sp)
 77c:	6de2                	ld	s11,24(sp)
 77e:	6109                	addi	sp,sp,128
 780:	8082                	ret

0000000000000782 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 782:	715d                	addi	sp,sp,-80
 784:	ec06                	sd	ra,24(sp)
 786:	e822                	sd	s0,16(sp)
 788:	1000                	addi	s0,sp,32
 78a:	e010                	sd	a2,0(s0)
 78c:	e414                	sd	a3,8(s0)
 78e:	e818                	sd	a4,16(s0)
 790:	ec1c                	sd	a5,24(s0)
 792:	03043023          	sd	a6,32(s0)
 796:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 79a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 79e:	8622                	mv	a2,s0
 7a0:	00000097          	auipc	ra,0x0
 7a4:	e04080e7          	jalr	-508(ra) # 5a4 <vprintf>
}
 7a8:	60e2                	ld	ra,24(sp)
 7aa:	6442                	ld	s0,16(sp)
 7ac:	6161                	addi	sp,sp,80
 7ae:	8082                	ret

00000000000007b0 <printf>:

void
printf(const char *fmt, ...)
{
 7b0:	711d                	addi	sp,sp,-96
 7b2:	ec06                	sd	ra,24(sp)
 7b4:	e822                	sd	s0,16(sp)
 7b6:	1000                	addi	s0,sp,32
 7b8:	e40c                	sd	a1,8(s0)
 7ba:	e810                	sd	a2,16(s0)
 7bc:	ec14                	sd	a3,24(s0)
 7be:	f018                	sd	a4,32(s0)
 7c0:	f41c                	sd	a5,40(s0)
 7c2:	03043823          	sd	a6,48(s0)
 7c6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7ca:	00840613          	addi	a2,s0,8
 7ce:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7d2:	85aa                	mv	a1,a0
 7d4:	4505                	li	a0,1
 7d6:	00000097          	auipc	ra,0x0
 7da:	dce080e7          	jalr	-562(ra) # 5a4 <vprintf>
}
 7de:	60e2                	ld	ra,24(sp)
 7e0:	6442                	ld	s0,16(sp)
 7e2:	6125                	addi	sp,sp,96
 7e4:	8082                	ret

00000000000007e6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7e6:	1141                	addi	sp,sp,-16
 7e8:	e422                	sd	s0,8(sp)
 7ea:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7ec:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f0:	00001797          	auipc	a5,0x1
 7f4:	8107b783          	ld	a5,-2032(a5) # 1000 <freep>
 7f8:	a805                	j	828 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7fa:	4618                	lw	a4,8(a2)
 7fc:	9db9                	addw	a1,a1,a4
 7fe:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 802:	6398                	ld	a4,0(a5)
 804:	6318                	ld	a4,0(a4)
 806:	fee53823          	sd	a4,-16(a0)
 80a:	a091                	j	84e <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 80c:	ff852703          	lw	a4,-8(a0)
 810:	9e39                	addw	a2,a2,a4
 812:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 814:	ff053703          	ld	a4,-16(a0)
 818:	e398                	sd	a4,0(a5)
 81a:	a099                	j	860 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 81c:	6398                	ld	a4,0(a5)
 81e:	00e7e463          	bltu	a5,a4,826 <free+0x40>
 822:	00e6ea63          	bltu	a3,a4,836 <free+0x50>
{
 826:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 828:	fed7fae3          	bgeu	a5,a3,81c <free+0x36>
 82c:	6398                	ld	a4,0(a5)
 82e:	00e6e463          	bltu	a3,a4,836 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 832:	fee7eae3          	bltu	a5,a4,826 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 836:	ff852583          	lw	a1,-8(a0)
 83a:	6390                	ld	a2,0(a5)
 83c:	02059713          	slli	a4,a1,0x20
 840:	9301                	srli	a4,a4,0x20
 842:	0712                	slli	a4,a4,0x4
 844:	9736                	add	a4,a4,a3
 846:	fae60ae3          	beq	a2,a4,7fa <free+0x14>
    bp->s.ptr = p->s.ptr;
 84a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 84e:	4790                	lw	a2,8(a5)
 850:	02061713          	slli	a4,a2,0x20
 854:	9301                	srli	a4,a4,0x20
 856:	0712                	slli	a4,a4,0x4
 858:	973e                	add	a4,a4,a5
 85a:	fae689e3          	beq	a3,a4,80c <free+0x26>
  } else
    p->s.ptr = bp;
 85e:	e394                	sd	a3,0(a5)
  freep = p;
 860:	00000717          	auipc	a4,0x0
 864:	7af73023          	sd	a5,1952(a4) # 1000 <freep>
}
 868:	6422                	ld	s0,8(sp)
 86a:	0141                	addi	sp,sp,16
 86c:	8082                	ret

000000000000086e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 86e:	7139                	addi	sp,sp,-64
 870:	fc06                	sd	ra,56(sp)
 872:	f822                	sd	s0,48(sp)
 874:	f426                	sd	s1,40(sp)
 876:	f04a                	sd	s2,32(sp)
 878:	ec4e                	sd	s3,24(sp)
 87a:	e852                	sd	s4,16(sp)
 87c:	e456                	sd	s5,8(sp)
 87e:	e05a                	sd	s6,0(sp)
 880:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 882:	02051493          	slli	s1,a0,0x20
 886:	9081                	srli	s1,s1,0x20
 888:	04bd                	addi	s1,s1,15
 88a:	8091                	srli	s1,s1,0x4
 88c:	0014899b          	addiw	s3,s1,1
 890:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 892:	00000517          	auipc	a0,0x0
 896:	76e53503          	ld	a0,1902(a0) # 1000 <freep>
 89a:	c515                	beqz	a0,8c6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 89c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 89e:	4798                	lw	a4,8(a5)
 8a0:	02977f63          	bgeu	a4,s1,8de <malloc+0x70>
 8a4:	8a4e                	mv	s4,s3
 8a6:	0009871b          	sext.w	a4,s3
 8aa:	6685                	lui	a3,0x1
 8ac:	00d77363          	bgeu	a4,a3,8b2 <malloc+0x44>
 8b0:	6a05                	lui	s4,0x1
 8b2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8b6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8ba:	00000917          	auipc	s2,0x0
 8be:	74690913          	addi	s2,s2,1862 # 1000 <freep>
  if(p == (char*)-1)
 8c2:	5afd                	li	s5,-1
 8c4:	a88d                	j	936 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 8c6:	00000797          	auipc	a5,0x0
 8ca:	74a78793          	addi	a5,a5,1866 # 1010 <base>
 8ce:	00000717          	auipc	a4,0x0
 8d2:	72f73923          	sd	a5,1842(a4) # 1000 <freep>
 8d6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8d8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8dc:	b7e1                	j	8a4 <malloc+0x36>
      if(p->s.size == nunits)
 8de:	02e48b63          	beq	s1,a4,914 <malloc+0xa6>
        p->s.size -= nunits;
 8e2:	4137073b          	subw	a4,a4,s3
 8e6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8e8:	1702                	slli	a4,a4,0x20
 8ea:	9301                	srli	a4,a4,0x20
 8ec:	0712                	slli	a4,a4,0x4
 8ee:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8f0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8f4:	00000717          	auipc	a4,0x0
 8f8:	70a73623          	sd	a0,1804(a4) # 1000 <freep>
      return (void*)(p + 1);
 8fc:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 900:	70e2                	ld	ra,56(sp)
 902:	7442                	ld	s0,48(sp)
 904:	74a2                	ld	s1,40(sp)
 906:	7902                	ld	s2,32(sp)
 908:	69e2                	ld	s3,24(sp)
 90a:	6a42                	ld	s4,16(sp)
 90c:	6aa2                	ld	s5,8(sp)
 90e:	6b02                	ld	s6,0(sp)
 910:	6121                	addi	sp,sp,64
 912:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 914:	6398                	ld	a4,0(a5)
 916:	e118                	sd	a4,0(a0)
 918:	bff1                	j	8f4 <malloc+0x86>
  hp->s.size = nu;
 91a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 91e:	0541                	addi	a0,a0,16
 920:	00000097          	auipc	ra,0x0
 924:	ec6080e7          	jalr	-314(ra) # 7e6 <free>
  return freep;
 928:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 92c:	d971                	beqz	a0,900 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 92e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 930:	4798                	lw	a4,8(a5)
 932:	fa9776e3          	bgeu	a4,s1,8de <malloc+0x70>
    if(p == freep)
 936:	00093703          	ld	a4,0(s2)
 93a:	853e                	mv	a0,a5
 93c:	fef719e3          	bne	a4,a5,92e <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 940:	8552                	mv	a0,s4
 942:	00000097          	auipc	ra,0x0
 946:	b56080e7          	jalr	-1194(ra) # 498 <sbrk>
  if(p == (char*)-1)
 94a:	fd5518e3          	bne	a0,s5,91a <malloc+0xac>
        return 0;
 94e:	4501                	li	a0,0
 950:	bf45                	j	900 <malloc+0x92>
