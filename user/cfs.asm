
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
  18:	9dca8a93          	addi	s5,s5,-1572 # 9f0 <malloc+0x18a>
    }
     wait(0,"");
  1c:	00001a17          	auipc	s4,0x1
  20:	9cca0a13          	addi	s4,s4,-1588 # 9e8 <malloc+0x182>
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
  c8:	8b458593          	addi	a1,a1,-1868 # 978 <malloc+0x112>
  cc:	4505                	li	a0,1
  ce:	00000097          	auipc	ra,0x0
  d2:	6ac080e7          	jalr	1708(ra) # 77a <fprintf>
      exit(0,"");
  d6:	00001597          	auipc	a1,0x1
  da:	91258593          	addi	a1,a1,-1774 # 9e8 <malloc+0x182>
  de:	4501                	li	a0,0
  e0:	00000097          	auipc	ra,0x0
  e4:	330080e7          	jalr	816(ra) # 410 <exit>
        sleep(100);
  e8:	06400513          	li	a0,100
  ec:	00000097          	auipc	ra,0x0
  f0:	3b4080e7          	jalr	948(ra) # 4a0 <sleep>
        fprintf(1, "Error getting process statistics\n");
  f4:	00001597          	auipc	a1,0x1
  f8:	85c58593          	addi	a1,a1,-1956 # 950 <malloc+0xea>
  fc:	4505                	li	a0,1
  fe:	00000097          	auipc	ra,0x0
 102:	67c080e7          	jalr	1660(ra) # 77a <fprintf>
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
 132:	64c080e7          	jalr	1612(ra) # 77a <fprintf>
 136:	bfc9                	j	108 <main+0x108>
  }

  // wait for all child processes to finish
  for (i = 0; i < 3; i++) {
    wait(0,"");
 138:	00001597          	auipc	a1,0x1
 13c:	8b058593          	addi	a1,a1,-1872 # 9e8 <malloc+0x182>
 140:	4501                	li	a0,0
 142:	00000097          	auipc	ra,0x0
 146:	2d6080e7          	jalr	726(ra) # 418 <wait>
 14a:	00001597          	auipc	a1,0x1
 14e:	89e58593          	addi	a1,a1,-1890 # 9e8 <malloc+0x182>
 152:	4501                	li	a0,0
 154:	00000097          	auipc	ra,0x0
 158:	2c4080e7          	jalr	708(ra) # 418 <wait>
 15c:	00001597          	auipc	a1,0x1
 160:	88c58593          	addi	a1,a1,-1908 # 9e8 <malloc+0x182>
 164:	4501                	li	a0,0
 166:	00000097          	auipc	ra,0x0
 16a:	2b2080e7          	jalr	690(ra) # 418 <wait>
  }
    exit(0,"");
 16e:	00001597          	auipc	a1,0x1
 172:	87a58593          	addi	a1,a1,-1926 # 9e8 <malloc+0x182>
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
 194:	85858593          	addi	a1,a1,-1960 # 9e8 <malloc+0x182>
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

00000000000004d0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4d0:	1101                	addi	sp,sp,-32
 4d2:	ec06                	sd	ra,24(sp)
 4d4:	e822                	sd	s0,16(sp)
 4d6:	1000                	addi	s0,sp,32
 4d8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4dc:	4605                	li	a2,1
 4de:	fef40593          	addi	a1,s0,-17
 4e2:	00000097          	auipc	ra,0x0
 4e6:	f4e080e7          	jalr	-178(ra) # 430 <write>
}
 4ea:	60e2                	ld	ra,24(sp)
 4ec:	6442                	ld	s0,16(sp)
 4ee:	6105                	addi	sp,sp,32
 4f0:	8082                	ret

00000000000004f2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4f2:	7139                	addi	sp,sp,-64
 4f4:	fc06                	sd	ra,56(sp)
 4f6:	f822                	sd	s0,48(sp)
 4f8:	f426                	sd	s1,40(sp)
 4fa:	f04a                	sd	s2,32(sp)
 4fc:	ec4e                	sd	s3,24(sp)
 4fe:	0080                	addi	s0,sp,64
 500:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 502:	c299                	beqz	a3,508 <printint+0x16>
 504:	0805c863          	bltz	a1,594 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 508:	2581                	sext.w	a1,a1
  neg = 0;
 50a:	4881                	li	a7,0
 50c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 510:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 512:	2601                	sext.w	a2,a2
 514:	00000517          	auipc	a0,0x0
 518:	4f450513          	addi	a0,a0,1268 # a08 <digits>
 51c:	883a                	mv	a6,a4
 51e:	2705                	addiw	a4,a4,1
 520:	02c5f7bb          	remuw	a5,a1,a2
 524:	1782                	slli	a5,a5,0x20
 526:	9381                	srli	a5,a5,0x20
 528:	97aa                	add	a5,a5,a0
 52a:	0007c783          	lbu	a5,0(a5)
 52e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 532:	0005879b          	sext.w	a5,a1
 536:	02c5d5bb          	divuw	a1,a1,a2
 53a:	0685                	addi	a3,a3,1
 53c:	fec7f0e3          	bgeu	a5,a2,51c <printint+0x2a>
  if(neg)
 540:	00088b63          	beqz	a7,556 <printint+0x64>
    buf[i++] = '-';
 544:	fd040793          	addi	a5,s0,-48
 548:	973e                	add	a4,a4,a5
 54a:	02d00793          	li	a5,45
 54e:	fef70823          	sb	a5,-16(a4)
 552:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 556:	02e05863          	blez	a4,586 <printint+0x94>
 55a:	fc040793          	addi	a5,s0,-64
 55e:	00e78933          	add	s2,a5,a4
 562:	fff78993          	addi	s3,a5,-1
 566:	99ba                	add	s3,s3,a4
 568:	377d                	addiw	a4,a4,-1
 56a:	1702                	slli	a4,a4,0x20
 56c:	9301                	srli	a4,a4,0x20
 56e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 572:	fff94583          	lbu	a1,-1(s2)
 576:	8526                	mv	a0,s1
 578:	00000097          	auipc	ra,0x0
 57c:	f58080e7          	jalr	-168(ra) # 4d0 <putc>
  while(--i >= 0)
 580:	197d                	addi	s2,s2,-1
 582:	ff3918e3          	bne	s2,s3,572 <printint+0x80>
}
 586:	70e2                	ld	ra,56(sp)
 588:	7442                	ld	s0,48(sp)
 58a:	74a2                	ld	s1,40(sp)
 58c:	7902                	ld	s2,32(sp)
 58e:	69e2                	ld	s3,24(sp)
 590:	6121                	addi	sp,sp,64
 592:	8082                	ret
    x = -xx;
 594:	40b005bb          	negw	a1,a1
    neg = 1;
 598:	4885                	li	a7,1
    x = -xx;
 59a:	bf8d                	j	50c <printint+0x1a>

000000000000059c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 59c:	7119                	addi	sp,sp,-128
 59e:	fc86                	sd	ra,120(sp)
 5a0:	f8a2                	sd	s0,112(sp)
 5a2:	f4a6                	sd	s1,104(sp)
 5a4:	f0ca                	sd	s2,96(sp)
 5a6:	ecce                	sd	s3,88(sp)
 5a8:	e8d2                	sd	s4,80(sp)
 5aa:	e4d6                	sd	s5,72(sp)
 5ac:	e0da                	sd	s6,64(sp)
 5ae:	fc5e                	sd	s7,56(sp)
 5b0:	f862                	sd	s8,48(sp)
 5b2:	f466                	sd	s9,40(sp)
 5b4:	f06a                	sd	s10,32(sp)
 5b6:	ec6e                	sd	s11,24(sp)
 5b8:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5ba:	0005c903          	lbu	s2,0(a1)
 5be:	18090f63          	beqz	s2,75c <vprintf+0x1c0>
 5c2:	8aaa                	mv	s5,a0
 5c4:	8b32                	mv	s6,a2
 5c6:	00158493          	addi	s1,a1,1
  state = 0;
 5ca:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5cc:	02500a13          	li	s4,37
      if(c == 'd'){
 5d0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 5d4:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 5d8:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 5dc:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5e0:	00000b97          	auipc	s7,0x0
 5e4:	428b8b93          	addi	s7,s7,1064 # a08 <digits>
 5e8:	a839                	j	606 <vprintf+0x6a>
        putc(fd, c);
 5ea:	85ca                	mv	a1,s2
 5ec:	8556                	mv	a0,s5
 5ee:	00000097          	auipc	ra,0x0
 5f2:	ee2080e7          	jalr	-286(ra) # 4d0 <putc>
 5f6:	a019                	j	5fc <vprintf+0x60>
    } else if(state == '%'){
 5f8:	01498f63          	beq	s3,s4,616 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5fc:	0485                	addi	s1,s1,1
 5fe:	fff4c903          	lbu	s2,-1(s1)
 602:	14090d63          	beqz	s2,75c <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 606:	0009079b          	sext.w	a5,s2
    if(state == 0){
 60a:	fe0997e3          	bnez	s3,5f8 <vprintf+0x5c>
      if(c == '%'){
 60e:	fd479ee3          	bne	a5,s4,5ea <vprintf+0x4e>
        state = '%';
 612:	89be                	mv	s3,a5
 614:	b7e5                	j	5fc <vprintf+0x60>
      if(c == 'd'){
 616:	05878063          	beq	a5,s8,656 <vprintf+0xba>
      } else if(c == 'l') {
 61a:	05978c63          	beq	a5,s9,672 <vprintf+0xd6>
      } else if(c == 'x') {
 61e:	07a78863          	beq	a5,s10,68e <vprintf+0xf2>
      } else if(c == 'p') {
 622:	09b78463          	beq	a5,s11,6aa <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 626:	07300713          	li	a4,115
 62a:	0ce78663          	beq	a5,a4,6f6 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 62e:	06300713          	li	a4,99
 632:	0ee78e63          	beq	a5,a4,72e <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 636:	11478863          	beq	a5,s4,746 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 63a:	85d2                	mv	a1,s4
 63c:	8556                	mv	a0,s5
 63e:	00000097          	auipc	ra,0x0
 642:	e92080e7          	jalr	-366(ra) # 4d0 <putc>
        putc(fd, c);
 646:	85ca                	mv	a1,s2
 648:	8556                	mv	a0,s5
 64a:	00000097          	auipc	ra,0x0
 64e:	e86080e7          	jalr	-378(ra) # 4d0 <putc>
      }
      state = 0;
 652:	4981                	li	s3,0
 654:	b765                	j	5fc <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 656:	008b0913          	addi	s2,s6,8
 65a:	4685                	li	a3,1
 65c:	4629                	li	a2,10
 65e:	000b2583          	lw	a1,0(s6)
 662:	8556                	mv	a0,s5
 664:	00000097          	auipc	ra,0x0
 668:	e8e080e7          	jalr	-370(ra) # 4f2 <printint>
 66c:	8b4a                	mv	s6,s2
      state = 0;
 66e:	4981                	li	s3,0
 670:	b771                	j	5fc <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 672:	008b0913          	addi	s2,s6,8
 676:	4681                	li	a3,0
 678:	4629                	li	a2,10
 67a:	000b2583          	lw	a1,0(s6)
 67e:	8556                	mv	a0,s5
 680:	00000097          	auipc	ra,0x0
 684:	e72080e7          	jalr	-398(ra) # 4f2 <printint>
 688:	8b4a                	mv	s6,s2
      state = 0;
 68a:	4981                	li	s3,0
 68c:	bf85                	j	5fc <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 68e:	008b0913          	addi	s2,s6,8
 692:	4681                	li	a3,0
 694:	4641                	li	a2,16
 696:	000b2583          	lw	a1,0(s6)
 69a:	8556                	mv	a0,s5
 69c:	00000097          	auipc	ra,0x0
 6a0:	e56080e7          	jalr	-426(ra) # 4f2 <printint>
 6a4:	8b4a                	mv	s6,s2
      state = 0;
 6a6:	4981                	li	s3,0
 6a8:	bf91                	j	5fc <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6aa:	008b0793          	addi	a5,s6,8
 6ae:	f8f43423          	sd	a5,-120(s0)
 6b2:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6b6:	03000593          	li	a1,48
 6ba:	8556                	mv	a0,s5
 6bc:	00000097          	auipc	ra,0x0
 6c0:	e14080e7          	jalr	-492(ra) # 4d0 <putc>
  putc(fd, 'x');
 6c4:	85ea                	mv	a1,s10
 6c6:	8556                	mv	a0,s5
 6c8:	00000097          	auipc	ra,0x0
 6cc:	e08080e7          	jalr	-504(ra) # 4d0 <putc>
 6d0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6d2:	03c9d793          	srli	a5,s3,0x3c
 6d6:	97de                	add	a5,a5,s7
 6d8:	0007c583          	lbu	a1,0(a5)
 6dc:	8556                	mv	a0,s5
 6de:	00000097          	auipc	ra,0x0
 6e2:	df2080e7          	jalr	-526(ra) # 4d0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6e6:	0992                	slli	s3,s3,0x4
 6e8:	397d                	addiw	s2,s2,-1
 6ea:	fe0914e3          	bnez	s2,6d2 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6ee:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6f2:	4981                	li	s3,0
 6f4:	b721                	j	5fc <vprintf+0x60>
        s = va_arg(ap, char*);
 6f6:	008b0993          	addi	s3,s6,8
 6fa:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 6fe:	02090163          	beqz	s2,720 <vprintf+0x184>
        while(*s != 0){
 702:	00094583          	lbu	a1,0(s2)
 706:	c9a1                	beqz	a1,756 <vprintf+0x1ba>
          putc(fd, *s);
 708:	8556                	mv	a0,s5
 70a:	00000097          	auipc	ra,0x0
 70e:	dc6080e7          	jalr	-570(ra) # 4d0 <putc>
          s++;
 712:	0905                	addi	s2,s2,1
        while(*s != 0){
 714:	00094583          	lbu	a1,0(s2)
 718:	f9e5                	bnez	a1,708 <vprintf+0x16c>
        s = va_arg(ap, char*);
 71a:	8b4e                	mv	s6,s3
      state = 0;
 71c:	4981                	li	s3,0
 71e:	bdf9                	j	5fc <vprintf+0x60>
          s = "(null)";
 720:	00000917          	auipc	s2,0x0
 724:	2e090913          	addi	s2,s2,736 # a00 <malloc+0x19a>
        while(*s != 0){
 728:	02800593          	li	a1,40
 72c:	bff1                	j	708 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 72e:	008b0913          	addi	s2,s6,8
 732:	000b4583          	lbu	a1,0(s6)
 736:	8556                	mv	a0,s5
 738:	00000097          	auipc	ra,0x0
 73c:	d98080e7          	jalr	-616(ra) # 4d0 <putc>
 740:	8b4a                	mv	s6,s2
      state = 0;
 742:	4981                	li	s3,0
 744:	bd65                	j	5fc <vprintf+0x60>
        putc(fd, c);
 746:	85d2                	mv	a1,s4
 748:	8556                	mv	a0,s5
 74a:	00000097          	auipc	ra,0x0
 74e:	d86080e7          	jalr	-634(ra) # 4d0 <putc>
      state = 0;
 752:	4981                	li	s3,0
 754:	b565                	j	5fc <vprintf+0x60>
        s = va_arg(ap, char*);
 756:	8b4e                	mv	s6,s3
      state = 0;
 758:	4981                	li	s3,0
 75a:	b54d                	j	5fc <vprintf+0x60>
    }
  }
}
 75c:	70e6                	ld	ra,120(sp)
 75e:	7446                	ld	s0,112(sp)
 760:	74a6                	ld	s1,104(sp)
 762:	7906                	ld	s2,96(sp)
 764:	69e6                	ld	s3,88(sp)
 766:	6a46                	ld	s4,80(sp)
 768:	6aa6                	ld	s5,72(sp)
 76a:	6b06                	ld	s6,64(sp)
 76c:	7be2                	ld	s7,56(sp)
 76e:	7c42                	ld	s8,48(sp)
 770:	7ca2                	ld	s9,40(sp)
 772:	7d02                	ld	s10,32(sp)
 774:	6de2                	ld	s11,24(sp)
 776:	6109                	addi	sp,sp,128
 778:	8082                	ret

000000000000077a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 77a:	715d                	addi	sp,sp,-80
 77c:	ec06                	sd	ra,24(sp)
 77e:	e822                	sd	s0,16(sp)
 780:	1000                	addi	s0,sp,32
 782:	e010                	sd	a2,0(s0)
 784:	e414                	sd	a3,8(s0)
 786:	e818                	sd	a4,16(s0)
 788:	ec1c                	sd	a5,24(s0)
 78a:	03043023          	sd	a6,32(s0)
 78e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 792:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 796:	8622                	mv	a2,s0
 798:	00000097          	auipc	ra,0x0
 79c:	e04080e7          	jalr	-508(ra) # 59c <vprintf>
}
 7a0:	60e2                	ld	ra,24(sp)
 7a2:	6442                	ld	s0,16(sp)
 7a4:	6161                	addi	sp,sp,80
 7a6:	8082                	ret

00000000000007a8 <printf>:

void
printf(const char *fmt, ...)
{
 7a8:	711d                	addi	sp,sp,-96
 7aa:	ec06                	sd	ra,24(sp)
 7ac:	e822                	sd	s0,16(sp)
 7ae:	1000                	addi	s0,sp,32
 7b0:	e40c                	sd	a1,8(s0)
 7b2:	e810                	sd	a2,16(s0)
 7b4:	ec14                	sd	a3,24(s0)
 7b6:	f018                	sd	a4,32(s0)
 7b8:	f41c                	sd	a5,40(s0)
 7ba:	03043823          	sd	a6,48(s0)
 7be:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7c2:	00840613          	addi	a2,s0,8
 7c6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7ca:	85aa                	mv	a1,a0
 7cc:	4505                	li	a0,1
 7ce:	00000097          	auipc	ra,0x0
 7d2:	dce080e7          	jalr	-562(ra) # 59c <vprintf>
}
 7d6:	60e2                	ld	ra,24(sp)
 7d8:	6442                	ld	s0,16(sp)
 7da:	6125                	addi	sp,sp,96
 7dc:	8082                	ret

00000000000007de <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7de:	1141                	addi	sp,sp,-16
 7e0:	e422                	sd	s0,8(sp)
 7e2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7e4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e8:	00001797          	auipc	a5,0x1
 7ec:	8187b783          	ld	a5,-2024(a5) # 1000 <freep>
 7f0:	a805                	j	820 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7f2:	4618                	lw	a4,8(a2)
 7f4:	9db9                	addw	a1,a1,a4
 7f6:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7fa:	6398                	ld	a4,0(a5)
 7fc:	6318                	ld	a4,0(a4)
 7fe:	fee53823          	sd	a4,-16(a0)
 802:	a091                	j	846 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 804:	ff852703          	lw	a4,-8(a0)
 808:	9e39                	addw	a2,a2,a4
 80a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 80c:	ff053703          	ld	a4,-16(a0)
 810:	e398                	sd	a4,0(a5)
 812:	a099                	j	858 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 814:	6398                	ld	a4,0(a5)
 816:	00e7e463          	bltu	a5,a4,81e <free+0x40>
 81a:	00e6ea63          	bltu	a3,a4,82e <free+0x50>
{
 81e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 820:	fed7fae3          	bgeu	a5,a3,814 <free+0x36>
 824:	6398                	ld	a4,0(a5)
 826:	00e6e463          	bltu	a3,a4,82e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 82a:	fee7eae3          	bltu	a5,a4,81e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 82e:	ff852583          	lw	a1,-8(a0)
 832:	6390                	ld	a2,0(a5)
 834:	02059713          	slli	a4,a1,0x20
 838:	9301                	srli	a4,a4,0x20
 83a:	0712                	slli	a4,a4,0x4
 83c:	9736                	add	a4,a4,a3
 83e:	fae60ae3          	beq	a2,a4,7f2 <free+0x14>
    bp->s.ptr = p->s.ptr;
 842:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 846:	4790                	lw	a2,8(a5)
 848:	02061713          	slli	a4,a2,0x20
 84c:	9301                	srli	a4,a4,0x20
 84e:	0712                	slli	a4,a4,0x4
 850:	973e                	add	a4,a4,a5
 852:	fae689e3          	beq	a3,a4,804 <free+0x26>
  } else
    p->s.ptr = bp;
 856:	e394                	sd	a3,0(a5)
  freep = p;
 858:	00000717          	auipc	a4,0x0
 85c:	7af73423          	sd	a5,1960(a4) # 1000 <freep>
}
 860:	6422                	ld	s0,8(sp)
 862:	0141                	addi	sp,sp,16
 864:	8082                	ret

0000000000000866 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 866:	7139                	addi	sp,sp,-64
 868:	fc06                	sd	ra,56(sp)
 86a:	f822                	sd	s0,48(sp)
 86c:	f426                	sd	s1,40(sp)
 86e:	f04a                	sd	s2,32(sp)
 870:	ec4e                	sd	s3,24(sp)
 872:	e852                	sd	s4,16(sp)
 874:	e456                	sd	s5,8(sp)
 876:	e05a                	sd	s6,0(sp)
 878:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 87a:	02051493          	slli	s1,a0,0x20
 87e:	9081                	srli	s1,s1,0x20
 880:	04bd                	addi	s1,s1,15
 882:	8091                	srli	s1,s1,0x4
 884:	0014899b          	addiw	s3,s1,1
 888:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 88a:	00000517          	auipc	a0,0x0
 88e:	77653503          	ld	a0,1910(a0) # 1000 <freep>
 892:	c515                	beqz	a0,8be <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 894:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 896:	4798                	lw	a4,8(a5)
 898:	02977f63          	bgeu	a4,s1,8d6 <malloc+0x70>
 89c:	8a4e                	mv	s4,s3
 89e:	0009871b          	sext.w	a4,s3
 8a2:	6685                	lui	a3,0x1
 8a4:	00d77363          	bgeu	a4,a3,8aa <malloc+0x44>
 8a8:	6a05                	lui	s4,0x1
 8aa:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8ae:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8b2:	00000917          	auipc	s2,0x0
 8b6:	74e90913          	addi	s2,s2,1870 # 1000 <freep>
  if(p == (char*)-1)
 8ba:	5afd                	li	s5,-1
 8bc:	a88d                	j	92e <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 8be:	00000797          	auipc	a5,0x0
 8c2:	75278793          	addi	a5,a5,1874 # 1010 <base>
 8c6:	00000717          	auipc	a4,0x0
 8ca:	72f73d23          	sd	a5,1850(a4) # 1000 <freep>
 8ce:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8d0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8d4:	b7e1                	j	89c <malloc+0x36>
      if(p->s.size == nunits)
 8d6:	02e48b63          	beq	s1,a4,90c <malloc+0xa6>
        p->s.size -= nunits;
 8da:	4137073b          	subw	a4,a4,s3
 8de:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8e0:	1702                	slli	a4,a4,0x20
 8e2:	9301                	srli	a4,a4,0x20
 8e4:	0712                	slli	a4,a4,0x4
 8e6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8e8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8ec:	00000717          	auipc	a4,0x0
 8f0:	70a73a23          	sd	a0,1812(a4) # 1000 <freep>
      return (void*)(p + 1);
 8f4:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8f8:	70e2                	ld	ra,56(sp)
 8fa:	7442                	ld	s0,48(sp)
 8fc:	74a2                	ld	s1,40(sp)
 8fe:	7902                	ld	s2,32(sp)
 900:	69e2                	ld	s3,24(sp)
 902:	6a42                	ld	s4,16(sp)
 904:	6aa2                	ld	s5,8(sp)
 906:	6b02                	ld	s6,0(sp)
 908:	6121                	addi	sp,sp,64
 90a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 90c:	6398                	ld	a4,0(a5)
 90e:	e118                	sd	a4,0(a0)
 910:	bff1                	j	8ec <malloc+0x86>
  hp->s.size = nu;
 912:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 916:	0541                	addi	a0,a0,16
 918:	00000097          	auipc	ra,0x0
 91c:	ec6080e7          	jalr	-314(ra) # 7de <free>
  return freep;
 920:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 924:	d971                	beqz	a0,8f8 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 926:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 928:	4798                	lw	a4,8(a5)
 92a:	fa9776e3          	bgeu	a4,s1,8d6 <malloc+0x70>
    if(p == freep)
 92e:	00093703          	ld	a4,0(s2)
 932:	853e                	mv	a0,a5
 934:	fef719e3          	bne	a4,a5,926 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 938:	8552                	mv	a0,s4
 93a:	00000097          	auipc	ra,0x0
 93e:	b5e080e7          	jalr	-1186(ra) # 498 <sbrk>
  if(p == (char*)-1)
 942:	fd5518e3          	bne	a0,s5,912 <malloc+0xac>
        return 0;
 946:	4501                	li	a0,0
 948:	bf45                	j	8f8 <malloc+0x92>
