
user/_cfs:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
int main(int argc, char *argv[]) {
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	0080                	addi	s0,sp,64
  int pid, i;

  for (i = 0; i < 3; i++) {
  10:	4901                	li	s2,0
        // fprintf(1, "  Runnable time: %d ticks\n", ans[3]);
      }

      exit(0,"");
    } else if (pid < 0) {
      fprintf(1, "Fork failed\n");
  12:	00001a17          	auipc	s4,0x1
  16:	9bea0a13          	addi	s4,s4,-1602 # 9d0 <malloc+0x190>
  for (i = 0; i < 3; i++) {
  1a:	498d                	li	s3,3
  1c:	a8e1                	j	f4 <main+0xf4>
      if (i == 0) {
  1e:	02090063          	beqz	s2,3e <main+0x3e>
      } else if (i == 1) {
  22:	4785                	li	a5,1
  24:	02f90363          	beq	s2,a5,4a <main+0x4a>
      } else if (i == 2) {
  28:	4789                	li	a5,2
  2a:	02f90663          	beq	s2,a5,56 <main+0x56>
        if (j % 100000 == 0) {
  2e:	69e1                	lui	s3,0x18
  30:	6a09899b          	addiw	s3,s3,1696
      for (j = 0; j < 1000000; j++) {
  34:	000f4937          	lui	s2,0xf4
  38:	24090913          	addi	s2,s2,576 # f4240 <base+0xf3230>
  3c:	a035                	j	68 <main+0x68>
        set_cfs_priority(0);
  3e:	4501                	li	a0,0
  40:	00000097          	auipc	ra,0x0
  44:	45a080e7          	jalr	1114(ra) # 49a <set_cfs_priority>
  48:	b7dd                	j	2e <main+0x2e>
        set_cfs_priority(1);
  4a:	4505                	li	a0,1
  4c:	00000097          	auipc	ra,0x0
  50:	44e080e7          	jalr	1102(ra) # 49a <set_cfs_priority>
  54:	bfe9                	j	2e <main+0x2e>
        set_cfs_priority(2);
  56:	4509                	li	a0,2
  58:	00000097          	auipc	ra,0x0
  5c:	442080e7          	jalr	1090(ra) # 49a <set_cfs_priority>
  60:	b7f9                	j	2e <main+0x2e>
      for (j = 0; j < 1000000; j++) {
  62:	2485                	addiw	s1,s1,1
  64:	01248b63          	beq	s1,s2,7a <main+0x7a>
        if (j % 100000 == 0) {
  68:	0334e7bb          	remw	a5,s1,s3
  6c:	fbfd                	bnez	a5,62 <main+0x62>
          sleep(10); // sleep for 1 second
  6e:	4529                	li	a0,10
  70:	00000097          	auipc	ra,0x0
  74:	40a080e7          	jalr	1034(ra) # 47a <sleep>
  78:	b7ed                	j	62 <main+0x62>
      if (get_cfs_stats(ans,pid) < 0) {
  7a:	4581                	li	a1,0
  7c:	fc040513          	addi	a0,s0,-64
  80:	00000097          	auipc	ra,0x0
  84:	422080e7          	jalr	1058(ra) # 4a2 <get_cfs_stats>
  88:	04054363          	bltz	a0,ce <main+0xce>
        sleep(100);
  8c:	06400513          	li	a0,100
  90:	00000097          	auipc	ra,0x0
  94:	3ea080e7          	jalr	1002(ra) # 47a <sleep>
        fprintf(1, "Child (pid %d) finished,CFS priority: %d,Run time: %d ticks,Sleep time: %d ticks, Runnable time: %d ticks \n", pid,ans[0],ans[1],ans[2],ans[3]);
  98:	fcc42803          	lw	a6,-52(s0)
  9c:	fc842783          	lw	a5,-56(s0)
  a0:	fc442703          	lw	a4,-60(s0)
  a4:	fc042683          	lw	a3,-64(s0)
  a8:	4601                	li	a2,0
  aa:	00001597          	auipc	a1,0x1
  ae:	8ae58593          	addi	a1,a1,-1874 # 958 <malloc+0x118>
  b2:	4505                	li	a0,1
  b4:	00000097          	auipc	ra,0x0
  b8:	6a0080e7          	jalr	1696(ra) # 754 <fprintf>
      exit(0,"");
  bc:	00001597          	auipc	a1,0x1
  c0:	90c58593          	addi	a1,a1,-1780 # 9c8 <malloc+0x188>
  c4:	4501                	li	a0,0
  c6:	00000097          	auipc	ra,0x0
  ca:	324080e7          	jalr	804(ra) # 3ea <exit>
        sleep(100);
  ce:	06400513          	li	a0,100
  d2:	00000097          	auipc	ra,0x0
  d6:	3a8080e7          	jalr	936(ra) # 47a <sleep>
        fprintf(1, "Error getting process statistics\n");
  da:	00001597          	auipc	a1,0x1
  de:	85658593          	addi	a1,a1,-1962 # 930 <malloc+0xf0>
  e2:	4505                	li	a0,1
  e4:	00000097          	auipc	ra,0x0
  e8:	670080e7          	jalr	1648(ra) # 754 <fprintf>
  ec:	bfc1                	j	bc <main+0xbc>
  for (i = 0; i < 3; i++) {
  ee:	2905                	addiw	s2,s2,1
  f0:	03390163          	beq	s2,s3,112 <main+0x112>
    pid = fork();
  f4:	00000097          	auipc	ra,0x0
  f8:	2ee080e7          	jalr	750(ra) # 3e2 <fork>
  fc:	84aa                	mv	s1,a0
    if (pid == 0) { // child process
  fe:	d105                	beqz	a0,1e <main+0x1e>
    } else if (pid < 0) {
 100:	fe0557e3          	bgez	a0,ee <main+0xee>
      fprintf(1, "Fork failed\n");
 104:	85d2                	mv	a1,s4
 106:	4505                	li	a0,1
 108:	00000097          	auipc	ra,0x0
 10c:	64c080e7          	jalr	1612(ra) # 754 <fprintf>
 110:	bff9                	j	ee <main+0xee>
    }
  }

  // wait for all child processes to finish
  for (i = 0; i < 3; i++) {
    wait(0,"");
 112:	00001597          	auipc	a1,0x1
 116:	8b658593          	addi	a1,a1,-1866 # 9c8 <malloc+0x188>
 11a:	4501                	li	a0,0
 11c:	00000097          	auipc	ra,0x0
 120:	2d6080e7          	jalr	726(ra) # 3f2 <wait>
 124:	00001597          	auipc	a1,0x1
 128:	8a458593          	addi	a1,a1,-1884 # 9c8 <malloc+0x188>
 12c:	4501                	li	a0,0
 12e:	00000097          	auipc	ra,0x0
 132:	2c4080e7          	jalr	708(ra) # 3f2 <wait>
 136:	00001597          	auipc	a1,0x1
 13a:	89258593          	addi	a1,a1,-1902 # 9c8 <malloc+0x188>
 13e:	4501                	li	a0,0
 140:	00000097          	auipc	ra,0x0
 144:	2b2080e7          	jalr	690(ra) # 3f2 <wait>
  }
    exit(0,"");
 148:	00001597          	auipc	a1,0x1
 14c:	88058593          	addi	a1,a1,-1920 # 9c8 <malloc+0x188>
 150:	4501                	li	a0,0
 152:	00000097          	auipc	ra,0x0
 156:	298080e7          	jalr	664(ra) # 3ea <exit>

000000000000015a <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 15a:	1141                	addi	sp,sp,-16
 15c:	e406                	sd	ra,8(sp)
 15e:	e022                	sd	s0,0(sp)
 160:	0800                	addi	s0,sp,16
  extern int main();
  main();
 162:	00000097          	auipc	ra,0x0
 166:	e9e080e7          	jalr	-354(ra) # 0 <main>
  exit(0,"");
 16a:	00001597          	auipc	a1,0x1
 16e:	85e58593          	addi	a1,a1,-1954 # 9c8 <malloc+0x188>
 172:	4501                	li	a0,0
 174:	00000097          	auipc	ra,0x0
 178:	276080e7          	jalr	630(ra) # 3ea <exit>

000000000000017c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 17c:	1141                	addi	sp,sp,-16
 17e:	e422                	sd	s0,8(sp)
 180:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 182:	87aa                	mv	a5,a0
 184:	0585                	addi	a1,a1,1
 186:	0785                	addi	a5,a5,1
 188:	fff5c703          	lbu	a4,-1(a1)
 18c:	fee78fa3          	sb	a4,-1(a5)
 190:	fb75                	bnez	a4,184 <strcpy+0x8>
    ;
  return os;
}
 192:	6422                	ld	s0,8(sp)
 194:	0141                	addi	sp,sp,16
 196:	8082                	ret

0000000000000198 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 198:	1141                	addi	sp,sp,-16
 19a:	e422                	sd	s0,8(sp)
 19c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 19e:	00054783          	lbu	a5,0(a0)
 1a2:	cb91                	beqz	a5,1b6 <strcmp+0x1e>
 1a4:	0005c703          	lbu	a4,0(a1)
 1a8:	00f71763          	bne	a4,a5,1b6 <strcmp+0x1e>
    p++, q++;
 1ac:	0505                	addi	a0,a0,1
 1ae:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1b0:	00054783          	lbu	a5,0(a0)
 1b4:	fbe5                	bnez	a5,1a4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1b6:	0005c503          	lbu	a0,0(a1)
}
 1ba:	40a7853b          	subw	a0,a5,a0
 1be:	6422                	ld	s0,8(sp)
 1c0:	0141                	addi	sp,sp,16
 1c2:	8082                	ret

00000000000001c4 <strlen>:

uint
strlen(const char *s)
{
 1c4:	1141                	addi	sp,sp,-16
 1c6:	e422                	sd	s0,8(sp)
 1c8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1ca:	00054783          	lbu	a5,0(a0)
 1ce:	cf91                	beqz	a5,1ea <strlen+0x26>
 1d0:	0505                	addi	a0,a0,1
 1d2:	87aa                	mv	a5,a0
 1d4:	4685                	li	a3,1
 1d6:	9e89                	subw	a3,a3,a0
 1d8:	00f6853b          	addw	a0,a3,a5
 1dc:	0785                	addi	a5,a5,1
 1de:	fff7c703          	lbu	a4,-1(a5)
 1e2:	fb7d                	bnez	a4,1d8 <strlen+0x14>
    ;
  return n;
}
 1e4:	6422                	ld	s0,8(sp)
 1e6:	0141                	addi	sp,sp,16
 1e8:	8082                	ret
  for(n = 0; s[n]; n++)
 1ea:	4501                	li	a0,0
 1ec:	bfe5                	j	1e4 <strlen+0x20>

00000000000001ee <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ee:	1141                	addi	sp,sp,-16
 1f0:	e422                	sd	s0,8(sp)
 1f2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1f4:	ca19                	beqz	a2,20a <memset+0x1c>
 1f6:	87aa                	mv	a5,a0
 1f8:	1602                	slli	a2,a2,0x20
 1fa:	9201                	srli	a2,a2,0x20
 1fc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 200:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 204:	0785                	addi	a5,a5,1
 206:	fee79de3          	bne	a5,a4,200 <memset+0x12>
  }
  return dst;
}
 20a:	6422                	ld	s0,8(sp)
 20c:	0141                	addi	sp,sp,16
 20e:	8082                	ret

0000000000000210 <strchr>:

char*
strchr(const char *s, char c)
{
 210:	1141                	addi	sp,sp,-16
 212:	e422                	sd	s0,8(sp)
 214:	0800                	addi	s0,sp,16
  for(; *s; s++)
 216:	00054783          	lbu	a5,0(a0)
 21a:	cb99                	beqz	a5,230 <strchr+0x20>
    if(*s == c)
 21c:	00f58763          	beq	a1,a5,22a <strchr+0x1a>
  for(; *s; s++)
 220:	0505                	addi	a0,a0,1
 222:	00054783          	lbu	a5,0(a0)
 226:	fbfd                	bnez	a5,21c <strchr+0xc>
      return (char*)s;
  return 0;
 228:	4501                	li	a0,0
}
 22a:	6422                	ld	s0,8(sp)
 22c:	0141                	addi	sp,sp,16
 22e:	8082                	ret
  return 0;
 230:	4501                	li	a0,0
 232:	bfe5                	j	22a <strchr+0x1a>

0000000000000234 <gets>:

char*
gets(char *buf, int max)
{
 234:	711d                	addi	sp,sp,-96
 236:	ec86                	sd	ra,88(sp)
 238:	e8a2                	sd	s0,80(sp)
 23a:	e4a6                	sd	s1,72(sp)
 23c:	e0ca                	sd	s2,64(sp)
 23e:	fc4e                	sd	s3,56(sp)
 240:	f852                	sd	s4,48(sp)
 242:	f456                	sd	s5,40(sp)
 244:	f05a                	sd	s6,32(sp)
 246:	ec5e                	sd	s7,24(sp)
 248:	1080                	addi	s0,sp,96
 24a:	8baa                	mv	s7,a0
 24c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 24e:	892a                	mv	s2,a0
 250:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 252:	4aa9                	li	s5,10
 254:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 256:	89a6                	mv	s3,s1
 258:	2485                	addiw	s1,s1,1
 25a:	0344d863          	bge	s1,s4,28a <gets+0x56>
    cc = read(0, &c, 1);
 25e:	4605                	li	a2,1
 260:	faf40593          	addi	a1,s0,-81
 264:	4501                	li	a0,0
 266:	00000097          	auipc	ra,0x0
 26a:	19c080e7          	jalr	412(ra) # 402 <read>
    if(cc < 1)
 26e:	00a05e63          	blez	a0,28a <gets+0x56>
    buf[i++] = c;
 272:	faf44783          	lbu	a5,-81(s0)
 276:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 27a:	01578763          	beq	a5,s5,288 <gets+0x54>
 27e:	0905                	addi	s2,s2,1
 280:	fd679be3          	bne	a5,s6,256 <gets+0x22>
  for(i=0; i+1 < max; ){
 284:	89a6                	mv	s3,s1
 286:	a011                	j	28a <gets+0x56>
 288:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 28a:	99de                	add	s3,s3,s7
 28c:	00098023          	sb	zero,0(s3) # 18000 <base+0x16ff0>
  return buf;
}
 290:	855e                	mv	a0,s7
 292:	60e6                	ld	ra,88(sp)
 294:	6446                	ld	s0,80(sp)
 296:	64a6                	ld	s1,72(sp)
 298:	6906                	ld	s2,64(sp)
 29a:	79e2                	ld	s3,56(sp)
 29c:	7a42                	ld	s4,48(sp)
 29e:	7aa2                	ld	s5,40(sp)
 2a0:	7b02                	ld	s6,32(sp)
 2a2:	6be2                	ld	s7,24(sp)
 2a4:	6125                	addi	sp,sp,96
 2a6:	8082                	ret

00000000000002a8 <stat>:

int
stat(const char *n, struct stat *st)
{
 2a8:	1101                	addi	sp,sp,-32
 2aa:	ec06                	sd	ra,24(sp)
 2ac:	e822                	sd	s0,16(sp)
 2ae:	e426                	sd	s1,8(sp)
 2b0:	e04a                	sd	s2,0(sp)
 2b2:	1000                	addi	s0,sp,32
 2b4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2b6:	4581                	li	a1,0
 2b8:	00000097          	auipc	ra,0x0
 2bc:	172080e7          	jalr	370(ra) # 42a <open>
  if(fd < 0)
 2c0:	02054563          	bltz	a0,2ea <stat+0x42>
 2c4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2c6:	85ca                	mv	a1,s2
 2c8:	00000097          	auipc	ra,0x0
 2cc:	17a080e7          	jalr	378(ra) # 442 <fstat>
 2d0:	892a                	mv	s2,a0
  close(fd);
 2d2:	8526                	mv	a0,s1
 2d4:	00000097          	auipc	ra,0x0
 2d8:	13e080e7          	jalr	318(ra) # 412 <close>
  return r;
}
 2dc:	854a                	mv	a0,s2
 2de:	60e2                	ld	ra,24(sp)
 2e0:	6442                	ld	s0,16(sp)
 2e2:	64a2                	ld	s1,8(sp)
 2e4:	6902                	ld	s2,0(sp)
 2e6:	6105                	addi	sp,sp,32
 2e8:	8082                	ret
    return -1;
 2ea:	597d                	li	s2,-1
 2ec:	bfc5                	j	2dc <stat+0x34>

00000000000002ee <atoi>:

int
atoi(const char *s)
{
 2ee:	1141                	addi	sp,sp,-16
 2f0:	e422                	sd	s0,8(sp)
 2f2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2f4:	00054603          	lbu	a2,0(a0)
 2f8:	fd06079b          	addiw	a5,a2,-48
 2fc:	0ff7f793          	andi	a5,a5,255
 300:	4725                	li	a4,9
 302:	02f76963          	bltu	a4,a5,334 <atoi+0x46>
 306:	86aa                	mv	a3,a0
  n = 0;
 308:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 30a:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 30c:	0685                	addi	a3,a3,1
 30e:	0025179b          	slliw	a5,a0,0x2
 312:	9fa9                	addw	a5,a5,a0
 314:	0017979b          	slliw	a5,a5,0x1
 318:	9fb1                	addw	a5,a5,a2
 31a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 31e:	0006c603          	lbu	a2,0(a3)
 322:	fd06071b          	addiw	a4,a2,-48
 326:	0ff77713          	andi	a4,a4,255
 32a:	fee5f1e3          	bgeu	a1,a4,30c <atoi+0x1e>
  return n;
}
 32e:	6422                	ld	s0,8(sp)
 330:	0141                	addi	sp,sp,16
 332:	8082                	ret
  n = 0;
 334:	4501                	li	a0,0
 336:	bfe5                	j	32e <atoi+0x40>

0000000000000338 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 338:	1141                	addi	sp,sp,-16
 33a:	e422                	sd	s0,8(sp)
 33c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 33e:	02b57463          	bgeu	a0,a1,366 <memmove+0x2e>
    while(n-- > 0)
 342:	00c05f63          	blez	a2,360 <memmove+0x28>
 346:	1602                	slli	a2,a2,0x20
 348:	9201                	srli	a2,a2,0x20
 34a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 34e:	872a                	mv	a4,a0
      *dst++ = *src++;
 350:	0585                	addi	a1,a1,1
 352:	0705                	addi	a4,a4,1
 354:	fff5c683          	lbu	a3,-1(a1)
 358:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 35c:	fee79ae3          	bne	a5,a4,350 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 360:	6422                	ld	s0,8(sp)
 362:	0141                	addi	sp,sp,16
 364:	8082                	ret
    dst += n;
 366:	00c50733          	add	a4,a0,a2
    src += n;
 36a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 36c:	fec05ae3          	blez	a2,360 <memmove+0x28>
 370:	fff6079b          	addiw	a5,a2,-1
 374:	1782                	slli	a5,a5,0x20
 376:	9381                	srli	a5,a5,0x20
 378:	fff7c793          	not	a5,a5
 37c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 37e:	15fd                	addi	a1,a1,-1
 380:	177d                	addi	a4,a4,-1
 382:	0005c683          	lbu	a3,0(a1)
 386:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 38a:	fee79ae3          	bne	a5,a4,37e <memmove+0x46>
 38e:	bfc9                	j	360 <memmove+0x28>

0000000000000390 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 390:	1141                	addi	sp,sp,-16
 392:	e422                	sd	s0,8(sp)
 394:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 396:	ca05                	beqz	a2,3c6 <memcmp+0x36>
 398:	fff6069b          	addiw	a3,a2,-1
 39c:	1682                	slli	a3,a3,0x20
 39e:	9281                	srli	a3,a3,0x20
 3a0:	0685                	addi	a3,a3,1
 3a2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3a4:	00054783          	lbu	a5,0(a0)
 3a8:	0005c703          	lbu	a4,0(a1)
 3ac:	00e79863          	bne	a5,a4,3bc <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3b0:	0505                	addi	a0,a0,1
    p2++;
 3b2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3b4:	fed518e3          	bne	a0,a3,3a4 <memcmp+0x14>
  }
  return 0;
 3b8:	4501                	li	a0,0
 3ba:	a019                	j	3c0 <memcmp+0x30>
      return *p1 - *p2;
 3bc:	40e7853b          	subw	a0,a5,a4
}
 3c0:	6422                	ld	s0,8(sp)
 3c2:	0141                	addi	sp,sp,16
 3c4:	8082                	ret
  return 0;
 3c6:	4501                	li	a0,0
 3c8:	bfe5                	j	3c0 <memcmp+0x30>

00000000000003ca <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3ca:	1141                	addi	sp,sp,-16
 3cc:	e406                	sd	ra,8(sp)
 3ce:	e022                	sd	s0,0(sp)
 3d0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3d2:	00000097          	auipc	ra,0x0
 3d6:	f66080e7          	jalr	-154(ra) # 338 <memmove>
}
 3da:	60a2                	ld	ra,8(sp)
 3dc:	6402                	ld	s0,0(sp)
 3de:	0141                	addi	sp,sp,16
 3e0:	8082                	ret

00000000000003e2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3e2:	4885                	li	a7,1
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <exit>:
.global exit
exit:
 li a7, SYS_exit
 3ea:	4889                	li	a7,2
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3f2:	488d                	li	a7,3
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3fa:	4891                	li	a7,4
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <read>:
.global read
read:
 li a7, SYS_read
 402:	4895                	li	a7,5
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <write>:
.global write
write:
 li a7, SYS_write
 40a:	48c1                	li	a7,16
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <close>:
.global close
close:
 li a7, SYS_close
 412:	48d5                	li	a7,21
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <kill>:
.global kill
kill:
 li a7, SYS_kill
 41a:	4899                	li	a7,6
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <exec>:
.global exec
exec:
 li a7, SYS_exec
 422:	489d                	li	a7,7
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <open>:
.global open
open:
 li a7, SYS_open
 42a:	48bd                	li	a7,15
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 432:	48c5                	li	a7,17
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 43a:	48c9                	li	a7,18
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 442:	48a1                	li	a7,8
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <link>:
.global link
link:
 li a7, SYS_link
 44a:	48cd                	li	a7,19
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 452:	48d1                	li	a7,20
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 45a:	48a5                	li	a7,9
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <dup>:
.global dup
dup:
 li a7, SYS_dup
 462:	48a9                	li	a7,10
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 46a:	48ad                	li	a7,11
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 472:	48b1                	li	a7,12
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 47a:	48b5                	li	a7,13
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 482:	48b9                	li	a7,14
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <memsize>:
.global memsize
memsize:
 li a7, SYS_memsize
 48a:	48d9                	li	a7,22
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <set_ps_priority>:
.global set_ps_priority
set_ps_priority:
 li a7, SYS_set_ps_priority
 492:	48dd                	li	a7,23
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <set_cfs_priority>:
.global set_cfs_priority
set_cfs_priority:
 li a7, SYS_set_cfs_priority
 49a:	48e1                	li	a7,24
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <get_cfs_stats>:
.global get_cfs_stats
get_cfs_stats:
 li a7, SYS_get_cfs_stats
 4a2:	48e5                	li	a7,25
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4aa:	1101                	addi	sp,sp,-32
 4ac:	ec06                	sd	ra,24(sp)
 4ae:	e822                	sd	s0,16(sp)
 4b0:	1000                	addi	s0,sp,32
 4b2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4b6:	4605                	li	a2,1
 4b8:	fef40593          	addi	a1,s0,-17
 4bc:	00000097          	auipc	ra,0x0
 4c0:	f4e080e7          	jalr	-178(ra) # 40a <write>
}
 4c4:	60e2                	ld	ra,24(sp)
 4c6:	6442                	ld	s0,16(sp)
 4c8:	6105                	addi	sp,sp,32
 4ca:	8082                	ret

00000000000004cc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4cc:	7139                	addi	sp,sp,-64
 4ce:	fc06                	sd	ra,56(sp)
 4d0:	f822                	sd	s0,48(sp)
 4d2:	f426                	sd	s1,40(sp)
 4d4:	f04a                	sd	s2,32(sp)
 4d6:	ec4e                	sd	s3,24(sp)
 4d8:	0080                	addi	s0,sp,64
 4da:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4dc:	c299                	beqz	a3,4e2 <printint+0x16>
 4de:	0805c863          	bltz	a1,56e <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4e2:	2581                	sext.w	a1,a1
  neg = 0;
 4e4:	4881                	li	a7,0
 4e6:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4ea:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4ec:	2601                	sext.w	a2,a2
 4ee:	00000517          	auipc	a0,0x0
 4f2:	4fa50513          	addi	a0,a0,1274 # 9e8 <digits>
 4f6:	883a                	mv	a6,a4
 4f8:	2705                	addiw	a4,a4,1
 4fa:	02c5f7bb          	remuw	a5,a1,a2
 4fe:	1782                	slli	a5,a5,0x20
 500:	9381                	srli	a5,a5,0x20
 502:	97aa                	add	a5,a5,a0
 504:	0007c783          	lbu	a5,0(a5)
 508:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 50c:	0005879b          	sext.w	a5,a1
 510:	02c5d5bb          	divuw	a1,a1,a2
 514:	0685                	addi	a3,a3,1
 516:	fec7f0e3          	bgeu	a5,a2,4f6 <printint+0x2a>
  if(neg)
 51a:	00088b63          	beqz	a7,530 <printint+0x64>
    buf[i++] = '-';
 51e:	fd040793          	addi	a5,s0,-48
 522:	973e                	add	a4,a4,a5
 524:	02d00793          	li	a5,45
 528:	fef70823          	sb	a5,-16(a4)
 52c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 530:	02e05863          	blez	a4,560 <printint+0x94>
 534:	fc040793          	addi	a5,s0,-64
 538:	00e78933          	add	s2,a5,a4
 53c:	fff78993          	addi	s3,a5,-1
 540:	99ba                	add	s3,s3,a4
 542:	377d                	addiw	a4,a4,-1
 544:	1702                	slli	a4,a4,0x20
 546:	9301                	srli	a4,a4,0x20
 548:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 54c:	fff94583          	lbu	a1,-1(s2)
 550:	8526                	mv	a0,s1
 552:	00000097          	auipc	ra,0x0
 556:	f58080e7          	jalr	-168(ra) # 4aa <putc>
  while(--i >= 0)
 55a:	197d                	addi	s2,s2,-1
 55c:	ff3918e3          	bne	s2,s3,54c <printint+0x80>
}
 560:	70e2                	ld	ra,56(sp)
 562:	7442                	ld	s0,48(sp)
 564:	74a2                	ld	s1,40(sp)
 566:	7902                	ld	s2,32(sp)
 568:	69e2                	ld	s3,24(sp)
 56a:	6121                	addi	sp,sp,64
 56c:	8082                	ret
    x = -xx;
 56e:	40b005bb          	negw	a1,a1
    neg = 1;
 572:	4885                	li	a7,1
    x = -xx;
 574:	bf8d                	j	4e6 <printint+0x1a>

0000000000000576 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 576:	7119                	addi	sp,sp,-128
 578:	fc86                	sd	ra,120(sp)
 57a:	f8a2                	sd	s0,112(sp)
 57c:	f4a6                	sd	s1,104(sp)
 57e:	f0ca                	sd	s2,96(sp)
 580:	ecce                	sd	s3,88(sp)
 582:	e8d2                	sd	s4,80(sp)
 584:	e4d6                	sd	s5,72(sp)
 586:	e0da                	sd	s6,64(sp)
 588:	fc5e                	sd	s7,56(sp)
 58a:	f862                	sd	s8,48(sp)
 58c:	f466                	sd	s9,40(sp)
 58e:	f06a                	sd	s10,32(sp)
 590:	ec6e                	sd	s11,24(sp)
 592:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 594:	0005c903          	lbu	s2,0(a1)
 598:	18090f63          	beqz	s2,736 <vprintf+0x1c0>
 59c:	8aaa                	mv	s5,a0
 59e:	8b32                	mv	s6,a2
 5a0:	00158493          	addi	s1,a1,1
  state = 0;
 5a4:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5a6:	02500a13          	li	s4,37
      if(c == 'd'){
 5aa:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 5ae:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 5b2:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 5b6:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5ba:	00000b97          	auipc	s7,0x0
 5be:	42eb8b93          	addi	s7,s7,1070 # 9e8 <digits>
 5c2:	a839                	j	5e0 <vprintf+0x6a>
        putc(fd, c);
 5c4:	85ca                	mv	a1,s2
 5c6:	8556                	mv	a0,s5
 5c8:	00000097          	auipc	ra,0x0
 5cc:	ee2080e7          	jalr	-286(ra) # 4aa <putc>
 5d0:	a019                	j	5d6 <vprintf+0x60>
    } else if(state == '%'){
 5d2:	01498f63          	beq	s3,s4,5f0 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5d6:	0485                	addi	s1,s1,1
 5d8:	fff4c903          	lbu	s2,-1(s1)
 5dc:	14090d63          	beqz	s2,736 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 5e0:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5e4:	fe0997e3          	bnez	s3,5d2 <vprintf+0x5c>
      if(c == '%'){
 5e8:	fd479ee3          	bne	a5,s4,5c4 <vprintf+0x4e>
        state = '%';
 5ec:	89be                	mv	s3,a5
 5ee:	b7e5                	j	5d6 <vprintf+0x60>
      if(c == 'd'){
 5f0:	05878063          	beq	a5,s8,630 <vprintf+0xba>
      } else if(c == 'l') {
 5f4:	05978c63          	beq	a5,s9,64c <vprintf+0xd6>
      } else if(c == 'x') {
 5f8:	07a78863          	beq	a5,s10,668 <vprintf+0xf2>
      } else if(c == 'p') {
 5fc:	09b78463          	beq	a5,s11,684 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 600:	07300713          	li	a4,115
 604:	0ce78663          	beq	a5,a4,6d0 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 608:	06300713          	li	a4,99
 60c:	0ee78e63          	beq	a5,a4,708 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 610:	11478863          	beq	a5,s4,720 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 614:	85d2                	mv	a1,s4
 616:	8556                	mv	a0,s5
 618:	00000097          	auipc	ra,0x0
 61c:	e92080e7          	jalr	-366(ra) # 4aa <putc>
        putc(fd, c);
 620:	85ca                	mv	a1,s2
 622:	8556                	mv	a0,s5
 624:	00000097          	auipc	ra,0x0
 628:	e86080e7          	jalr	-378(ra) # 4aa <putc>
      }
      state = 0;
 62c:	4981                	li	s3,0
 62e:	b765                	j	5d6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 630:	008b0913          	addi	s2,s6,8
 634:	4685                	li	a3,1
 636:	4629                	li	a2,10
 638:	000b2583          	lw	a1,0(s6)
 63c:	8556                	mv	a0,s5
 63e:	00000097          	auipc	ra,0x0
 642:	e8e080e7          	jalr	-370(ra) # 4cc <printint>
 646:	8b4a                	mv	s6,s2
      state = 0;
 648:	4981                	li	s3,0
 64a:	b771                	j	5d6 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 64c:	008b0913          	addi	s2,s6,8
 650:	4681                	li	a3,0
 652:	4629                	li	a2,10
 654:	000b2583          	lw	a1,0(s6)
 658:	8556                	mv	a0,s5
 65a:	00000097          	auipc	ra,0x0
 65e:	e72080e7          	jalr	-398(ra) # 4cc <printint>
 662:	8b4a                	mv	s6,s2
      state = 0;
 664:	4981                	li	s3,0
 666:	bf85                	j	5d6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 668:	008b0913          	addi	s2,s6,8
 66c:	4681                	li	a3,0
 66e:	4641                	li	a2,16
 670:	000b2583          	lw	a1,0(s6)
 674:	8556                	mv	a0,s5
 676:	00000097          	auipc	ra,0x0
 67a:	e56080e7          	jalr	-426(ra) # 4cc <printint>
 67e:	8b4a                	mv	s6,s2
      state = 0;
 680:	4981                	li	s3,0
 682:	bf91                	j	5d6 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 684:	008b0793          	addi	a5,s6,8
 688:	f8f43423          	sd	a5,-120(s0)
 68c:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 690:	03000593          	li	a1,48
 694:	8556                	mv	a0,s5
 696:	00000097          	auipc	ra,0x0
 69a:	e14080e7          	jalr	-492(ra) # 4aa <putc>
  putc(fd, 'x');
 69e:	85ea                	mv	a1,s10
 6a0:	8556                	mv	a0,s5
 6a2:	00000097          	auipc	ra,0x0
 6a6:	e08080e7          	jalr	-504(ra) # 4aa <putc>
 6aa:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6ac:	03c9d793          	srli	a5,s3,0x3c
 6b0:	97de                	add	a5,a5,s7
 6b2:	0007c583          	lbu	a1,0(a5)
 6b6:	8556                	mv	a0,s5
 6b8:	00000097          	auipc	ra,0x0
 6bc:	df2080e7          	jalr	-526(ra) # 4aa <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6c0:	0992                	slli	s3,s3,0x4
 6c2:	397d                	addiw	s2,s2,-1
 6c4:	fe0914e3          	bnez	s2,6ac <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6c8:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6cc:	4981                	li	s3,0
 6ce:	b721                	j	5d6 <vprintf+0x60>
        s = va_arg(ap, char*);
 6d0:	008b0993          	addi	s3,s6,8
 6d4:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 6d8:	02090163          	beqz	s2,6fa <vprintf+0x184>
        while(*s != 0){
 6dc:	00094583          	lbu	a1,0(s2)
 6e0:	c9a1                	beqz	a1,730 <vprintf+0x1ba>
          putc(fd, *s);
 6e2:	8556                	mv	a0,s5
 6e4:	00000097          	auipc	ra,0x0
 6e8:	dc6080e7          	jalr	-570(ra) # 4aa <putc>
          s++;
 6ec:	0905                	addi	s2,s2,1
        while(*s != 0){
 6ee:	00094583          	lbu	a1,0(s2)
 6f2:	f9e5                	bnez	a1,6e2 <vprintf+0x16c>
        s = va_arg(ap, char*);
 6f4:	8b4e                	mv	s6,s3
      state = 0;
 6f6:	4981                	li	s3,0
 6f8:	bdf9                	j	5d6 <vprintf+0x60>
          s = "(null)";
 6fa:	00000917          	auipc	s2,0x0
 6fe:	2e690913          	addi	s2,s2,742 # 9e0 <malloc+0x1a0>
        while(*s != 0){
 702:	02800593          	li	a1,40
 706:	bff1                	j	6e2 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 708:	008b0913          	addi	s2,s6,8
 70c:	000b4583          	lbu	a1,0(s6)
 710:	8556                	mv	a0,s5
 712:	00000097          	auipc	ra,0x0
 716:	d98080e7          	jalr	-616(ra) # 4aa <putc>
 71a:	8b4a                	mv	s6,s2
      state = 0;
 71c:	4981                	li	s3,0
 71e:	bd65                	j	5d6 <vprintf+0x60>
        putc(fd, c);
 720:	85d2                	mv	a1,s4
 722:	8556                	mv	a0,s5
 724:	00000097          	auipc	ra,0x0
 728:	d86080e7          	jalr	-634(ra) # 4aa <putc>
      state = 0;
 72c:	4981                	li	s3,0
 72e:	b565                	j	5d6 <vprintf+0x60>
        s = va_arg(ap, char*);
 730:	8b4e                	mv	s6,s3
      state = 0;
 732:	4981                	li	s3,0
 734:	b54d                	j	5d6 <vprintf+0x60>
    }
  }
}
 736:	70e6                	ld	ra,120(sp)
 738:	7446                	ld	s0,112(sp)
 73a:	74a6                	ld	s1,104(sp)
 73c:	7906                	ld	s2,96(sp)
 73e:	69e6                	ld	s3,88(sp)
 740:	6a46                	ld	s4,80(sp)
 742:	6aa6                	ld	s5,72(sp)
 744:	6b06                	ld	s6,64(sp)
 746:	7be2                	ld	s7,56(sp)
 748:	7c42                	ld	s8,48(sp)
 74a:	7ca2                	ld	s9,40(sp)
 74c:	7d02                	ld	s10,32(sp)
 74e:	6de2                	ld	s11,24(sp)
 750:	6109                	addi	sp,sp,128
 752:	8082                	ret

0000000000000754 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 754:	715d                	addi	sp,sp,-80
 756:	ec06                	sd	ra,24(sp)
 758:	e822                	sd	s0,16(sp)
 75a:	1000                	addi	s0,sp,32
 75c:	e010                	sd	a2,0(s0)
 75e:	e414                	sd	a3,8(s0)
 760:	e818                	sd	a4,16(s0)
 762:	ec1c                	sd	a5,24(s0)
 764:	03043023          	sd	a6,32(s0)
 768:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 76c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 770:	8622                	mv	a2,s0
 772:	00000097          	auipc	ra,0x0
 776:	e04080e7          	jalr	-508(ra) # 576 <vprintf>
}
 77a:	60e2                	ld	ra,24(sp)
 77c:	6442                	ld	s0,16(sp)
 77e:	6161                	addi	sp,sp,80
 780:	8082                	ret

0000000000000782 <printf>:

void
printf(const char *fmt, ...)
{
 782:	711d                	addi	sp,sp,-96
 784:	ec06                	sd	ra,24(sp)
 786:	e822                	sd	s0,16(sp)
 788:	1000                	addi	s0,sp,32
 78a:	e40c                	sd	a1,8(s0)
 78c:	e810                	sd	a2,16(s0)
 78e:	ec14                	sd	a3,24(s0)
 790:	f018                	sd	a4,32(s0)
 792:	f41c                	sd	a5,40(s0)
 794:	03043823          	sd	a6,48(s0)
 798:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 79c:	00840613          	addi	a2,s0,8
 7a0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7a4:	85aa                	mv	a1,a0
 7a6:	4505                	li	a0,1
 7a8:	00000097          	auipc	ra,0x0
 7ac:	dce080e7          	jalr	-562(ra) # 576 <vprintf>
}
 7b0:	60e2                	ld	ra,24(sp)
 7b2:	6442                	ld	s0,16(sp)
 7b4:	6125                	addi	sp,sp,96
 7b6:	8082                	ret

00000000000007b8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7b8:	1141                	addi	sp,sp,-16
 7ba:	e422                	sd	s0,8(sp)
 7bc:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7be:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c2:	00001797          	auipc	a5,0x1
 7c6:	83e7b783          	ld	a5,-1986(a5) # 1000 <freep>
 7ca:	a805                	j	7fa <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7cc:	4618                	lw	a4,8(a2)
 7ce:	9db9                	addw	a1,a1,a4
 7d0:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7d4:	6398                	ld	a4,0(a5)
 7d6:	6318                	ld	a4,0(a4)
 7d8:	fee53823          	sd	a4,-16(a0)
 7dc:	a091                	j	820 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7de:	ff852703          	lw	a4,-8(a0)
 7e2:	9e39                	addw	a2,a2,a4
 7e4:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7e6:	ff053703          	ld	a4,-16(a0)
 7ea:	e398                	sd	a4,0(a5)
 7ec:	a099                	j	832 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ee:	6398                	ld	a4,0(a5)
 7f0:	00e7e463          	bltu	a5,a4,7f8 <free+0x40>
 7f4:	00e6ea63          	bltu	a3,a4,808 <free+0x50>
{
 7f8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7fa:	fed7fae3          	bgeu	a5,a3,7ee <free+0x36>
 7fe:	6398                	ld	a4,0(a5)
 800:	00e6e463          	bltu	a3,a4,808 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 804:	fee7eae3          	bltu	a5,a4,7f8 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 808:	ff852583          	lw	a1,-8(a0)
 80c:	6390                	ld	a2,0(a5)
 80e:	02059713          	slli	a4,a1,0x20
 812:	9301                	srli	a4,a4,0x20
 814:	0712                	slli	a4,a4,0x4
 816:	9736                	add	a4,a4,a3
 818:	fae60ae3          	beq	a2,a4,7cc <free+0x14>
    bp->s.ptr = p->s.ptr;
 81c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 820:	4790                	lw	a2,8(a5)
 822:	02061713          	slli	a4,a2,0x20
 826:	9301                	srli	a4,a4,0x20
 828:	0712                	slli	a4,a4,0x4
 82a:	973e                	add	a4,a4,a5
 82c:	fae689e3          	beq	a3,a4,7de <free+0x26>
  } else
    p->s.ptr = bp;
 830:	e394                	sd	a3,0(a5)
  freep = p;
 832:	00000717          	auipc	a4,0x0
 836:	7cf73723          	sd	a5,1998(a4) # 1000 <freep>
}
 83a:	6422                	ld	s0,8(sp)
 83c:	0141                	addi	sp,sp,16
 83e:	8082                	ret

0000000000000840 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 840:	7139                	addi	sp,sp,-64
 842:	fc06                	sd	ra,56(sp)
 844:	f822                	sd	s0,48(sp)
 846:	f426                	sd	s1,40(sp)
 848:	f04a                	sd	s2,32(sp)
 84a:	ec4e                	sd	s3,24(sp)
 84c:	e852                	sd	s4,16(sp)
 84e:	e456                	sd	s5,8(sp)
 850:	e05a                	sd	s6,0(sp)
 852:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 854:	02051493          	slli	s1,a0,0x20
 858:	9081                	srli	s1,s1,0x20
 85a:	04bd                	addi	s1,s1,15
 85c:	8091                	srli	s1,s1,0x4
 85e:	0014899b          	addiw	s3,s1,1
 862:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 864:	00000517          	auipc	a0,0x0
 868:	79c53503          	ld	a0,1948(a0) # 1000 <freep>
 86c:	c515                	beqz	a0,898 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 86e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 870:	4798                	lw	a4,8(a5)
 872:	02977f63          	bgeu	a4,s1,8b0 <malloc+0x70>
 876:	8a4e                	mv	s4,s3
 878:	0009871b          	sext.w	a4,s3
 87c:	6685                	lui	a3,0x1
 87e:	00d77363          	bgeu	a4,a3,884 <malloc+0x44>
 882:	6a05                	lui	s4,0x1
 884:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 888:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 88c:	00000917          	auipc	s2,0x0
 890:	77490913          	addi	s2,s2,1908 # 1000 <freep>
  if(p == (char*)-1)
 894:	5afd                	li	s5,-1
 896:	a88d                	j	908 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 898:	00000797          	auipc	a5,0x0
 89c:	77878793          	addi	a5,a5,1912 # 1010 <base>
 8a0:	00000717          	auipc	a4,0x0
 8a4:	76f73023          	sd	a5,1888(a4) # 1000 <freep>
 8a8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8aa:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8ae:	b7e1                	j	876 <malloc+0x36>
      if(p->s.size == nunits)
 8b0:	02e48b63          	beq	s1,a4,8e6 <malloc+0xa6>
        p->s.size -= nunits;
 8b4:	4137073b          	subw	a4,a4,s3
 8b8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8ba:	1702                	slli	a4,a4,0x20
 8bc:	9301                	srli	a4,a4,0x20
 8be:	0712                	slli	a4,a4,0x4
 8c0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8c2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8c6:	00000717          	auipc	a4,0x0
 8ca:	72a73d23          	sd	a0,1850(a4) # 1000 <freep>
      return (void*)(p + 1);
 8ce:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8d2:	70e2                	ld	ra,56(sp)
 8d4:	7442                	ld	s0,48(sp)
 8d6:	74a2                	ld	s1,40(sp)
 8d8:	7902                	ld	s2,32(sp)
 8da:	69e2                	ld	s3,24(sp)
 8dc:	6a42                	ld	s4,16(sp)
 8de:	6aa2                	ld	s5,8(sp)
 8e0:	6b02                	ld	s6,0(sp)
 8e2:	6121                	addi	sp,sp,64
 8e4:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8e6:	6398                	ld	a4,0(a5)
 8e8:	e118                	sd	a4,0(a0)
 8ea:	bff1                	j	8c6 <malloc+0x86>
  hp->s.size = nu;
 8ec:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8f0:	0541                	addi	a0,a0,16
 8f2:	00000097          	auipc	ra,0x0
 8f6:	ec6080e7          	jalr	-314(ra) # 7b8 <free>
  return freep;
 8fa:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8fe:	d971                	beqz	a0,8d2 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 900:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 902:	4798                	lw	a4,8(a5)
 904:	fa9776e3          	bgeu	a4,s1,8b0 <malloc+0x70>
    if(p == freep)
 908:	00093703          	ld	a4,0(s2)
 90c:	853e                	mv	a0,a5
 90e:	fef719e3          	bne	a4,a5,900 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 912:	8552                	mv	a0,s4
 914:	00000097          	auipc	ra,0x0
 918:	b5e080e7          	jalr	-1186(ra) # 472 <sbrk>
  if(p == (char*)-1)
 91c:	fd5518e3          	bne	a0,s5,8ec <malloc+0xac>
        return 0;
 920:	4501                	li	a0,0
 922:	bf45                	j	8d2 <malloc+0x92>
