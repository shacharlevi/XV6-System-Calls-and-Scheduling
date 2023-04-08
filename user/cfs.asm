
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
        
      }

      exit(0,"");
    } else if (pid < 0) {
      fprintf(1, "Fork failed\n");
  14:	00001a97          	auipc	s5,0x1
  18:	9bca8a93          	addi	s5,s5,-1604 # 9d0 <malloc+0x190>
    }
     wait(0,"");
  1c:	00001a17          	auipc	s4,0x1
  20:	9aca0a13          	addi	s4,s4,-1620 # 9c8 <malloc+0x188>
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
  4e:	440080e7          	jalr	1088(ra) # 48a <set_cfs_priority>
  52:	b7dd                	j	38 <main+0x38>
        set_cfs_priority(1);
  54:	4505                	li	a0,1
  56:	00000097          	auipc	ra,0x0
  5a:	434080e7          	jalr	1076(ra) # 48a <set_cfs_priority>
  5e:	bfe9                	j	38 <main+0x38>
        set_cfs_priority(2);
  60:	4509                	li	a0,2
  62:	00000097          	auipc	ra,0x0
  66:	428080e7          	jalr	1064(ra) # 48a <set_cfs_priority>
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
  7e:	3f0080e7          	jalr	1008(ra) # 46a <sleep>
  82:	b7ed                	j	6c <main+0x6c>
      if (get_cfs_stats(ans,getpid()) < 0) {
  84:	00000097          	auipc	ra,0x0
  88:	3d6080e7          	jalr	982(ra) # 45a <getpid>
  8c:	85aa                	mv	a1,a0
  8e:	fb040513          	addi	a0,s0,-80
  92:	00000097          	auipc	ra,0x0
  96:	400080e7          	jalr	1024(ra) # 492 <get_cfs_stats>
  9a:	04054763          	bltz	a0,e8 <main+0xe8>
        sleep(100);
  9e:	06400513          	li	a0,100
  a2:	00000097          	auipc	ra,0x0
  a6:	3c8080e7          	jalr	968(ra) # 46a <sleep>
        fprintf(1, "Child (pid %d) finished,CFS priority: %d,Run time: %d ticks,Sleep time: %d ticks, Runnable time: %d ticks \n", getpid(),ans[0],ans[1],ans[2],ans[3]);
  aa:	00000097          	auipc	ra,0x0
  ae:	3b0080e7          	jalr	944(ra) # 45a <getpid>
  b2:	862a                	mv	a2,a0
  b4:	fbc42803          	lw	a6,-68(s0)
  b8:	fb842783          	lw	a5,-72(s0)
  bc:	fb442703          	lw	a4,-76(s0)
  c0:	fb042683          	lw	a3,-80(s0)
  c4:	00001597          	auipc	a1,0x1
  c8:	89458593          	addi	a1,a1,-1900 # 958 <malloc+0x118>
  cc:	4505                	li	a0,1
  ce:	00000097          	auipc	ra,0x0
  d2:	686080e7          	jalr	1670(ra) # 754 <fprintf>
      exit(0,"");
  d6:	00001597          	auipc	a1,0x1
  da:	8f258593          	addi	a1,a1,-1806 # 9c8 <malloc+0x188>
  de:	4501                	li	a0,0
  e0:	00000097          	auipc	ra,0x0
  e4:	2fa080e7          	jalr	762(ra) # 3da <exit>
        sleep(100);
  e8:	06400513          	li	a0,100
  ec:	00000097          	auipc	ra,0x0
  f0:	37e080e7          	jalr	894(ra) # 46a <sleep>
        fprintf(1, "Error getting process statistics\n");
  f4:	00001597          	auipc	a1,0x1
  f8:	83c58593          	addi	a1,a1,-1988 # 930 <malloc+0xf0>
  fc:	4505                	li	a0,1
  fe:	00000097          	auipc	ra,0x0
 102:	656080e7          	jalr	1622(ra) # 754 <fprintf>
 106:	bfc1                	j	d6 <main+0xd6>
     wait(0,"");
 108:	85d2                	mv	a1,s4
 10a:	4501                	li	a0,0
 10c:	00000097          	auipc	ra,0x0
 110:	2d6080e7          	jalr	726(ra) # 3e2 <wait>
  for (i = 0; i < 3; i++) {
 114:	2905                	addiw	s2,s2,1
 116:	03390163          	beq	s2,s3,138 <main+0x138>
    pid = fork();
 11a:	00000097          	auipc	ra,0x0
 11e:	2b8080e7          	jalr	696(ra) # 3d2 <fork>
 122:	84aa                	mv	s1,a0
    if (pid == 0) { // child process
 124:	d111                	beqz	a0,28 <main+0x28>
    } else if (pid < 0) {
 126:	fe0551e3          	bgez	a0,108 <main+0x108>
      fprintf(1, "Fork failed\n");
 12a:	85d6                	mv	a1,s5
 12c:	4505                	li	a0,1
 12e:	00000097          	auipc	ra,0x0
 132:	626080e7          	jalr	1574(ra) # 754 <fprintf>
 136:	bfc9                	j	108 <main+0x108>
  }
  exit(0,"");
 138:	00001597          	auipc	a1,0x1
 13c:	89058593          	addi	a1,a1,-1904 # 9c8 <malloc+0x188>
 140:	4501                	li	a0,0
 142:	00000097          	auipc	ra,0x0
 146:	298080e7          	jalr	664(ra) # 3da <exit>

000000000000014a <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 14a:	1141                	addi	sp,sp,-16
 14c:	e406                	sd	ra,8(sp)
 14e:	e022                	sd	s0,0(sp)
 150:	0800                	addi	s0,sp,16
  extern int main();
  main();
 152:	00000097          	auipc	ra,0x0
 156:	eae080e7          	jalr	-338(ra) # 0 <main>
  exit(0,"");
 15a:	00001597          	auipc	a1,0x1
 15e:	86e58593          	addi	a1,a1,-1938 # 9c8 <malloc+0x188>
 162:	4501                	li	a0,0
 164:	00000097          	auipc	ra,0x0
 168:	276080e7          	jalr	630(ra) # 3da <exit>

000000000000016c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 16c:	1141                	addi	sp,sp,-16
 16e:	e422                	sd	s0,8(sp)
 170:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 172:	87aa                	mv	a5,a0
 174:	0585                	addi	a1,a1,1
 176:	0785                	addi	a5,a5,1
 178:	fff5c703          	lbu	a4,-1(a1)
 17c:	fee78fa3          	sb	a4,-1(a5)
 180:	fb75                	bnez	a4,174 <strcpy+0x8>
    ;
  return os;
}
 182:	6422                	ld	s0,8(sp)
 184:	0141                	addi	sp,sp,16
 186:	8082                	ret

0000000000000188 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 188:	1141                	addi	sp,sp,-16
 18a:	e422                	sd	s0,8(sp)
 18c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 18e:	00054783          	lbu	a5,0(a0)
 192:	cb91                	beqz	a5,1a6 <strcmp+0x1e>
 194:	0005c703          	lbu	a4,0(a1)
 198:	00f71763          	bne	a4,a5,1a6 <strcmp+0x1e>
    p++, q++;
 19c:	0505                	addi	a0,a0,1
 19e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1a0:	00054783          	lbu	a5,0(a0)
 1a4:	fbe5                	bnez	a5,194 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1a6:	0005c503          	lbu	a0,0(a1)
}
 1aa:	40a7853b          	subw	a0,a5,a0
 1ae:	6422                	ld	s0,8(sp)
 1b0:	0141                	addi	sp,sp,16
 1b2:	8082                	ret

00000000000001b4 <strlen>:

uint
strlen(const char *s)
{
 1b4:	1141                	addi	sp,sp,-16
 1b6:	e422                	sd	s0,8(sp)
 1b8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1ba:	00054783          	lbu	a5,0(a0)
 1be:	cf91                	beqz	a5,1da <strlen+0x26>
 1c0:	0505                	addi	a0,a0,1
 1c2:	87aa                	mv	a5,a0
 1c4:	4685                	li	a3,1
 1c6:	9e89                	subw	a3,a3,a0
 1c8:	00f6853b          	addw	a0,a3,a5
 1cc:	0785                	addi	a5,a5,1
 1ce:	fff7c703          	lbu	a4,-1(a5)
 1d2:	fb7d                	bnez	a4,1c8 <strlen+0x14>
    ;
  return n;
}
 1d4:	6422                	ld	s0,8(sp)
 1d6:	0141                	addi	sp,sp,16
 1d8:	8082                	ret
  for(n = 0; s[n]; n++)
 1da:	4501                	li	a0,0
 1dc:	bfe5                	j	1d4 <strlen+0x20>

00000000000001de <memset>:

void*
memset(void *dst, int c, uint n)
{
 1de:	1141                	addi	sp,sp,-16
 1e0:	e422                	sd	s0,8(sp)
 1e2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1e4:	ca19                	beqz	a2,1fa <memset+0x1c>
 1e6:	87aa                	mv	a5,a0
 1e8:	1602                	slli	a2,a2,0x20
 1ea:	9201                	srli	a2,a2,0x20
 1ec:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1f0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1f4:	0785                	addi	a5,a5,1
 1f6:	fee79de3          	bne	a5,a4,1f0 <memset+0x12>
  }
  return dst;
}
 1fa:	6422                	ld	s0,8(sp)
 1fc:	0141                	addi	sp,sp,16
 1fe:	8082                	ret

0000000000000200 <strchr>:

char*
strchr(const char *s, char c)
{
 200:	1141                	addi	sp,sp,-16
 202:	e422                	sd	s0,8(sp)
 204:	0800                	addi	s0,sp,16
  for(; *s; s++)
 206:	00054783          	lbu	a5,0(a0)
 20a:	cb99                	beqz	a5,220 <strchr+0x20>
    if(*s == c)
 20c:	00f58763          	beq	a1,a5,21a <strchr+0x1a>
  for(; *s; s++)
 210:	0505                	addi	a0,a0,1
 212:	00054783          	lbu	a5,0(a0)
 216:	fbfd                	bnez	a5,20c <strchr+0xc>
      return (char*)s;
  return 0;
 218:	4501                	li	a0,0
}
 21a:	6422                	ld	s0,8(sp)
 21c:	0141                	addi	sp,sp,16
 21e:	8082                	ret
  return 0;
 220:	4501                	li	a0,0
 222:	bfe5                	j	21a <strchr+0x1a>

0000000000000224 <gets>:

char*
gets(char *buf, int max)
{
 224:	711d                	addi	sp,sp,-96
 226:	ec86                	sd	ra,88(sp)
 228:	e8a2                	sd	s0,80(sp)
 22a:	e4a6                	sd	s1,72(sp)
 22c:	e0ca                	sd	s2,64(sp)
 22e:	fc4e                	sd	s3,56(sp)
 230:	f852                	sd	s4,48(sp)
 232:	f456                	sd	s5,40(sp)
 234:	f05a                	sd	s6,32(sp)
 236:	ec5e                	sd	s7,24(sp)
 238:	1080                	addi	s0,sp,96
 23a:	8baa                	mv	s7,a0
 23c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 23e:	892a                	mv	s2,a0
 240:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 242:	4aa9                	li	s5,10
 244:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 246:	89a6                	mv	s3,s1
 248:	2485                	addiw	s1,s1,1
 24a:	0344d863          	bge	s1,s4,27a <gets+0x56>
    cc = read(0, &c, 1);
 24e:	4605                	li	a2,1
 250:	faf40593          	addi	a1,s0,-81
 254:	4501                	li	a0,0
 256:	00000097          	auipc	ra,0x0
 25a:	19c080e7          	jalr	412(ra) # 3f2 <read>
    if(cc < 1)
 25e:	00a05e63          	blez	a0,27a <gets+0x56>
    buf[i++] = c;
 262:	faf44783          	lbu	a5,-81(s0)
 266:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 26a:	01578763          	beq	a5,s5,278 <gets+0x54>
 26e:	0905                	addi	s2,s2,1
 270:	fd679be3          	bne	a5,s6,246 <gets+0x22>
  for(i=0; i+1 < max; ){
 274:	89a6                	mv	s3,s1
 276:	a011                	j	27a <gets+0x56>
 278:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 27a:	99de                	add	s3,s3,s7
 27c:	00098023          	sb	zero,0(s3) # 18000 <base+0x16ff0>
  return buf;
}
 280:	855e                	mv	a0,s7
 282:	60e6                	ld	ra,88(sp)
 284:	6446                	ld	s0,80(sp)
 286:	64a6                	ld	s1,72(sp)
 288:	6906                	ld	s2,64(sp)
 28a:	79e2                	ld	s3,56(sp)
 28c:	7a42                	ld	s4,48(sp)
 28e:	7aa2                	ld	s5,40(sp)
 290:	7b02                	ld	s6,32(sp)
 292:	6be2                	ld	s7,24(sp)
 294:	6125                	addi	sp,sp,96
 296:	8082                	ret

0000000000000298 <stat>:

int
stat(const char *n, struct stat *st)
{
 298:	1101                	addi	sp,sp,-32
 29a:	ec06                	sd	ra,24(sp)
 29c:	e822                	sd	s0,16(sp)
 29e:	e426                	sd	s1,8(sp)
 2a0:	e04a                	sd	s2,0(sp)
 2a2:	1000                	addi	s0,sp,32
 2a4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2a6:	4581                	li	a1,0
 2a8:	00000097          	auipc	ra,0x0
 2ac:	172080e7          	jalr	370(ra) # 41a <open>
  if(fd < 0)
 2b0:	02054563          	bltz	a0,2da <stat+0x42>
 2b4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2b6:	85ca                	mv	a1,s2
 2b8:	00000097          	auipc	ra,0x0
 2bc:	17a080e7          	jalr	378(ra) # 432 <fstat>
 2c0:	892a                	mv	s2,a0
  close(fd);
 2c2:	8526                	mv	a0,s1
 2c4:	00000097          	auipc	ra,0x0
 2c8:	13e080e7          	jalr	318(ra) # 402 <close>
  return r;
}
 2cc:	854a                	mv	a0,s2
 2ce:	60e2                	ld	ra,24(sp)
 2d0:	6442                	ld	s0,16(sp)
 2d2:	64a2                	ld	s1,8(sp)
 2d4:	6902                	ld	s2,0(sp)
 2d6:	6105                	addi	sp,sp,32
 2d8:	8082                	ret
    return -1;
 2da:	597d                	li	s2,-1
 2dc:	bfc5                	j	2cc <stat+0x34>

00000000000002de <atoi>:

int
atoi(const char *s)
{
 2de:	1141                	addi	sp,sp,-16
 2e0:	e422                	sd	s0,8(sp)
 2e2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2e4:	00054603          	lbu	a2,0(a0)
 2e8:	fd06079b          	addiw	a5,a2,-48
 2ec:	0ff7f793          	andi	a5,a5,255
 2f0:	4725                	li	a4,9
 2f2:	02f76963          	bltu	a4,a5,324 <atoi+0x46>
 2f6:	86aa                	mv	a3,a0
  n = 0;
 2f8:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2fa:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2fc:	0685                	addi	a3,a3,1
 2fe:	0025179b          	slliw	a5,a0,0x2
 302:	9fa9                	addw	a5,a5,a0
 304:	0017979b          	slliw	a5,a5,0x1
 308:	9fb1                	addw	a5,a5,a2
 30a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 30e:	0006c603          	lbu	a2,0(a3)
 312:	fd06071b          	addiw	a4,a2,-48
 316:	0ff77713          	andi	a4,a4,255
 31a:	fee5f1e3          	bgeu	a1,a4,2fc <atoi+0x1e>
  return n;
}
 31e:	6422                	ld	s0,8(sp)
 320:	0141                	addi	sp,sp,16
 322:	8082                	ret
  n = 0;
 324:	4501                	li	a0,0
 326:	bfe5                	j	31e <atoi+0x40>

0000000000000328 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 328:	1141                	addi	sp,sp,-16
 32a:	e422                	sd	s0,8(sp)
 32c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 32e:	02b57463          	bgeu	a0,a1,356 <memmove+0x2e>
    while(n-- > 0)
 332:	00c05f63          	blez	a2,350 <memmove+0x28>
 336:	1602                	slli	a2,a2,0x20
 338:	9201                	srli	a2,a2,0x20
 33a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 33e:	872a                	mv	a4,a0
      *dst++ = *src++;
 340:	0585                	addi	a1,a1,1
 342:	0705                	addi	a4,a4,1
 344:	fff5c683          	lbu	a3,-1(a1)
 348:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 34c:	fee79ae3          	bne	a5,a4,340 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 350:	6422                	ld	s0,8(sp)
 352:	0141                	addi	sp,sp,16
 354:	8082                	ret
    dst += n;
 356:	00c50733          	add	a4,a0,a2
    src += n;
 35a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 35c:	fec05ae3          	blez	a2,350 <memmove+0x28>
 360:	fff6079b          	addiw	a5,a2,-1
 364:	1782                	slli	a5,a5,0x20
 366:	9381                	srli	a5,a5,0x20
 368:	fff7c793          	not	a5,a5
 36c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 36e:	15fd                	addi	a1,a1,-1
 370:	177d                	addi	a4,a4,-1
 372:	0005c683          	lbu	a3,0(a1)
 376:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 37a:	fee79ae3          	bne	a5,a4,36e <memmove+0x46>
 37e:	bfc9                	j	350 <memmove+0x28>

0000000000000380 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 380:	1141                	addi	sp,sp,-16
 382:	e422                	sd	s0,8(sp)
 384:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 386:	ca05                	beqz	a2,3b6 <memcmp+0x36>
 388:	fff6069b          	addiw	a3,a2,-1
 38c:	1682                	slli	a3,a3,0x20
 38e:	9281                	srli	a3,a3,0x20
 390:	0685                	addi	a3,a3,1
 392:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 394:	00054783          	lbu	a5,0(a0)
 398:	0005c703          	lbu	a4,0(a1)
 39c:	00e79863          	bne	a5,a4,3ac <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3a0:	0505                	addi	a0,a0,1
    p2++;
 3a2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3a4:	fed518e3          	bne	a0,a3,394 <memcmp+0x14>
  }
  return 0;
 3a8:	4501                	li	a0,0
 3aa:	a019                	j	3b0 <memcmp+0x30>
      return *p1 - *p2;
 3ac:	40e7853b          	subw	a0,a5,a4
}
 3b0:	6422                	ld	s0,8(sp)
 3b2:	0141                	addi	sp,sp,16
 3b4:	8082                	ret
  return 0;
 3b6:	4501                	li	a0,0
 3b8:	bfe5                	j	3b0 <memcmp+0x30>

00000000000003ba <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3ba:	1141                	addi	sp,sp,-16
 3bc:	e406                	sd	ra,8(sp)
 3be:	e022                	sd	s0,0(sp)
 3c0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3c2:	00000097          	auipc	ra,0x0
 3c6:	f66080e7          	jalr	-154(ra) # 328 <memmove>
}
 3ca:	60a2                	ld	ra,8(sp)
 3cc:	6402                	ld	s0,0(sp)
 3ce:	0141                	addi	sp,sp,16
 3d0:	8082                	ret

00000000000003d2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3d2:	4885                	li	a7,1
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <exit>:
.global exit
exit:
 li a7, SYS_exit
 3da:	4889                	li	a7,2
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3e2:	488d                	li	a7,3
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3ea:	4891                	li	a7,4
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <read>:
.global read
read:
 li a7, SYS_read
 3f2:	4895                	li	a7,5
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <write>:
.global write
write:
 li a7, SYS_write
 3fa:	48c1                	li	a7,16
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <close>:
.global close
close:
 li a7, SYS_close
 402:	48d5                	li	a7,21
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <kill>:
.global kill
kill:
 li a7, SYS_kill
 40a:	4899                	li	a7,6
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <exec>:
.global exec
exec:
 li a7, SYS_exec
 412:	489d                	li	a7,7
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <open>:
.global open
open:
 li a7, SYS_open
 41a:	48bd                	li	a7,15
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 422:	48c5                	li	a7,17
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 42a:	48c9                	li	a7,18
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 432:	48a1                	li	a7,8
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <link>:
.global link
link:
 li a7, SYS_link
 43a:	48cd                	li	a7,19
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 442:	48d1                	li	a7,20
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 44a:	48a5                	li	a7,9
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <dup>:
.global dup
dup:
 li a7, SYS_dup
 452:	48a9                	li	a7,10
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 45a:	48ad                	li	a7,11
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 462:	48b1                	li	a7,12
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 46a:	48b5                	li	a7,13
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 472:	48b9                	li	a7,14
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <memsize>:
.global memsize
memsize:
 li a7, SYS_memsize
 47a:	48d9                	li	a7,22
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <set_ps_priority>:
.global set_ps_priority
set_ps_priority:
 li a7, SYS_set_ps_priority
 482:	48dd                	li	a7,23
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <set_cfs_priority>:
.global set_cfs_priority
set_cfs_priority:
 li a7, SYS_set_cfs_priority
 48a:	48e1                	li	a7,24
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <get_cfs_stats>:
.global get_cfs_stats
get_cfs_stats:
 li a7, SYS_get_cfs_stats
 492:	48e5                	li	a7,25
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <set_policy>:
.global set_policy
set_policy:
 li a7, SYS_set_policy
 49a:	48e9                	li	a7,26
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <get_ps_priority>:
.global get_ps_priority
get_ps_priority:
 li a7, SYS_get_ps_priority
 4a2:	48ed                	li	a7,27
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
 4c0:	f3e080e7          	jalr	-194(ra) # 3fa <write>
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
 918:	b4e080e7          	jalr	-1202(ra) # 462 <sbrk>
  if(p == (char*)-1)
 91c:	fd5518e3          	bne	a0,s5,8ec <malloc+0xac>
        return 0;
 920:	4501                	li	a0,0
 922:	bf45                	j	8d2 <malloc+0x92>
