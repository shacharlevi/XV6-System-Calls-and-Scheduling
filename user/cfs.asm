
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
  18:	9aca8a93          	addi	s5,s5,-1620 # 9c0 <malloc+0x188>
    }
     wait(0,"");
  1c:	00001a17          	auipc	s4,0x1
  20:	99ca0a13          	addi	s4,s4,-1636 # 9b8 <malloc+0x180>
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
  c8:	88458593          	addi	a1,a1,-1916 # 948 <malloc+0x110>
  cc:	4505                	li	a0,1
  ce:	00000097          	auipc	ra,0x0
  d2:	67e080e7          	jalr	1662(ra) # 74c <fprintf>
      exit(0,"");
  d6:	00001597          	auipc	a1,0x1
  da:	8e258593          	addi	a1,a1,-1822 # 9b8 <malloc+0x180>
  de:	4501                	li	a0,0
  e0:	00000097          	auipc	ra,0x0
  e4:	2fa080e7          	jalr	762(ra) # 3da <exit>
        sleep(100);
  e8:	06400513          	li	a0,100
  ec:	00000097          	auipc	ra,0x0
  f0:	37e080e7          	jalr	894(ra) # 46a <sleep>
        fprintf(1, "Error getting process statistics\n");
  f4:	00001597          	auipc	a1,0x1
  f8:	82c58593          	addi	a1,a1,-2004 # 920 <malloc+0xe8>
  fc:	4505                	li	a0,1
  fe:	00000097          	auipc	ra,0x0
 102:	64e080e7          	jalr	1614(ra) # 74c <fprintf>
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
 132:	61e080e7          	jalr	1566(ra) # 74c <fprintf>
 136:	bfc9                	j	108 <main+0x108>
  }
  exit(0,"");
 138:	00001597          	auipc	a1,0x1
 13c:	88058593          	addi	a1,a1,-1920 # 9b8 <malloc+0x180>
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
 15e:	85e58593          	addi	a1,a1,-1954 # 9b8 <malloc+0x180>
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

00000000000004a2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4a2:	1101                	addi	sp,sp,-32
 4a4:	ec06                	sd	ra,24(sp)
 4a6:	e822                	sd	s0,16(sp)
 4a8:	1000                	addi	s0,sp,32
 4aa:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4ae:	4605                	li	a2,1
 4b0:	fef40593          	addi	a1,s0,-17
 4b4:	00000097          	auipc	ra,0x0
 4b8:	f46080e7          	jalr	-186(ra) # 3fa <write>
}
 4bc:	60e2                	ld	ra,24(sp)
 4be:	6442                	ld	s0,16(sp)
 4c0:	6105                	addi	sp,sp,32
 4c2:	8082                	ret

00000000000004c4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4c4:	7139                	addi	sp,sp,-64
 4c6:	fc06                	sd	ra,56(sp)
 4c8:	f822                	sd	s0,48(sp)
 4ca:	f426                	sd	s1,40(sp)
 4cc:	f04a                	sd	s2,32(sp)
 4ce:	ec4e                	sd	s3,24(sp)
 4d0:	0080                	addi	s0,sp,64
 4d2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4d4:	c299                	beqz	a3,4da <printint+0x16>
 4d6:	0805c863          	bltz	a1,566 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4da:	2581                	sext.w	a1,a1
  neg = 0;
 4dc:	4881                	li	a7,0
 4de:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4e2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4e4:	2601                	sext.w	a2,a2
 4e6:	00000517          	auipc	a0,0x0
 4ea:	4f250513          	addi	a0,a0,1266 # 9d8 <digits>
 4ee:	883a                	mv	a6,a4
 4f0:	2705                	addiw	a4,a4,1
 4f2:	02c5f7bb          	remuw	a5,a1,a2
 4f6:	1782                	slli	a5,a5,0x20
 4f8:	9381                	srli	a5,a5,0x20
 4fa:	97aa                	add	a5,a5,a0
 4fc:	0007c783          	lbu	a5,0(a5)
 500:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 504:	0005879b          	sext.w	a5,a1
 508:	02c5d5bb          	divuw	a1,a1,a2
 50c:	0685                	addi	a3,a3,1
 50e:	fec7f0e3          	bgeu	a5,a2,4ee <printint+0x2a>
  if(neg)
 512:	00088b63          	beqz	a7,528 <printint+0x64>
    buf[i++] = '-';
 516:	fd040793          	addi	a5,s0,-48
 51a:	973e                	add	a4,a4,a5
 51c:	02d00793          	li	a5,45
 520:	fef70823          	sb	a5,-16(a4)
 524:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 528:	02e05863          	blez	a4,558 <printint+0x94>
 52c:	fc040793          	addi	a5,s0,-64
 530:	00e78933          	add	s2,a5,a4
 534:	fff78993          	addi	s3,a5,-1
 538:	99ba                	add	s3,s3,a4
 53a:	377d                	addiw	a4,a4,-1
 53c:	1702                	slli	a4,a4,0x20
 53e:	9301                	srli	a4,a4,0x20
 540:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 544:	fff94583          	lbu	a1,-1(s2)
 548:	8526                	mv	a0,s1
 54a:	00000097          	auipc	ra,0x0
 54e:	f58080e7          	jalr	-168(ra) # 4a2 <putc>
  while(--i >= 0)
 552:	197d                	addi	s2,s2,-1
 554:	ff3918e3          	bne	s2,s3,544 <printint+0x80>
}
 558:	70e2                	ld	ra,56(sp)
 55a:	7442                	ld	s0,48(sp)
 55c:	74a2                	ld	s1,40(sp)
 55e:	7902                	ld	s2,32(sp)
 560:	69e2                	ld	s3,24(sp)
 562:	6121                	addi	sp,sp,64
 564:	8082                	ret
    x = -xx;
 566:	40b005bb          	negw	a1,a1
    neg = 1;
 56a:	4885                	li	a7,1
    x = -xx;
 56c:	bf8d                	j	4de <printint+0x1a>

000000000000056e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 56e:	7119                	addi	sp,sp,-128
 570:	fc86                	sd	ra,120(sp)
 572:	f8a2                	sd	s0,112(sp)
 574:	f4a6                	sd	s1,104(sp)
 576:	f0ca                	sd	s2,96(sp)
 578:	ecce                	sd	s3,88(sp)
 57a:	e8d2                	sd	s4,80(sp)
 57c:	e4d6                	sd	s5,72(sp)
 57e:	e0da                	sd	s6,64(sp)
 580:	fc5e                	sd	s7,56(sp)
 582:	f862                	sd	s8,48(sp)
 584:	f466                	sd	s9,40(sp)
 586:	f06a                	sd	s10,32(sp)
 588:	ec6e                	sd	s11,24(sp)
 58a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 58c:	0005c903          	lbu	s2,0(a1)
 590:	18090f63          	beqz	s2,72e <vprintf+0x1c0>
 594:	8aaa                	mv	s5,a0
 596:	8b32                	mv	s6,a2
 598:	00158493          	addi	s1,a1,1
  state = 0;
 59c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 59e:	02500a13          	li	s4,37
      if(c == 'd'){
 5a2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 5a6:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 5aa:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 5ae:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5b2:	00000b97          	auipc	s7,0x0
 5b6:	426b8b93          	addi	s7,s7,1062 # 9d8 <digits>
 5ba:	a839                	j	5d8 <vprintf+0x6a>
        putc(fd, c);
 5bc:	85ca                	mv	a1,s2
 5be:	8556                	mv	a0,s5
 5c0:	00000097          	auipc	ra,0x0
 5c4:	ee2080e7          	jalr	-286(ra) # 4a2 <putc>
 5c8:	a019                	j	5ce <vprintf+0x60>
    } else if(state == '%'){
 5ca:	01498f63          	beq	s3,s4,5e8 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5ce:	0485                	addi	s1,s1,1
 5d0:	fff4c903          	lbu	s2,-1(s1)
 5d4:	14090d63          	beqz	s2,72e <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 5d8:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5dc:	fe0997e3          	bnez	s3,5ca <vprintf+0x5c>
      if(c == '%'){
 5e0:	fd479ee3          	bne	a5,s4,5bc <vprintf+0x4e>
        state = '%';
 5e4:	89be                	mv	s3,a5
 5e6:	b7e5                	j	5ce <vprintf+0x60>
      if(c == 'd'){
 5e8:	05878063          	beq	a5,s8,628 <vprintf+0xba>
      } else if(c == 'l') {
 5ec:	05978c63          	beq	a5,s9,644 <vprintf+0xd6>
      } else if(c == 'x') {
 5f0:	07a78863          	beq	a5,s10,660 <vprintf+0xf2>
      } else if(c == 'p') {
 5f4:	09b78463          	beq	a5,s11,67c <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5f8:	07300713          	li	a4,115
 5fc:	0ce78663          	beq	a5,a4,6c8 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 600:	06300713          	li	a4,99
 604:	0ee78e63          	beq	a5,a4,700 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 608:	11478863          	beq	a5,s4,718 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 60c:	85d2                	mv	a1,s4
 60e:	8556                	mv	a0,s5
 610:	00000097          	auipc	ra,0x0
 614:	e92080e7          	jalr	-366(ra) # 4a2 <putc>
        putc(fd, c);
 618:	85ca                	mv	a1,s2
 61a:	8556                	mv	a0,s5
 61c:	00000097          	auipc	ra,0x0
 620:	e86080e7          	jalr	-378(ra) # 4a2 <putc>
      }
      state = 0;
 624:	4981                	li	s3,0
 626:	b765                	j	5ce <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 628:	008b0913          	addi	s2,s6,8
 62c:	4685                	li	a3,1
 62e:	4629                	li	a2,10
 630:	000b2583          	lw	a1,0(s6)
 634:	8556                	mv	a0,s5
 636:	00000097          	auipc	ra,0x0
 63a:	e8e080e7          	jalr	-370(ra) # 4c4 <printint>
 63e:	8b4a                	mv	s6,s2
      state = 0;
 640:	4981                	li	s3,0
 642:	b771                	j	5ce <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 644:	008b0913          	addi	s2,s6,8
 648:	4681                	li	a3,0
 64a:	4629                	li	a2,10
 64c:	000b2583          	lw	a1,0(s6)
 650:	8556                	mv	a0,s5
 652:	00000097          	auipc	ra,0x0
 656:	e72080e7          	jalr	-398(ra) # 4c4 <printint>
 65a:	8b4a                	mv	s6,s2
      state = 0;
 65c:	4981                	li	s3,0
 65e:	bf85                	j	5ce <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 660:	008b0913          	addi	s2,s6,8
 664:	4681                	li	a3,0
 666:	4641                	li	a2,16
 668:	000b2583          	lw	a1,0(s6)
 66c:	8556                	mv	a0,s5
 66e:	00000097          	auipc	ra,0x0
 672:	e56080e7          	jalr	-426(ra) # 4c4 <printint>
 676:	8b4a                	mv	s6,s2
      state = 0;
 678:	4981                	li	s3,0
 67a:	bf91                	j	5ce <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 67c:	008b0793          	addi	a5,s6,8
 680:	f8f43423          	sd	a5,-120(s0)
 684:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 688:	03000593          	li	a1,48
 68c:	8556                	mv	a0,s5
 68e:	00000097          	auipc	ra,0x0
 692:	e14080e7          	jalr	-492(ra) # 4a2 <putc>
  putc(fd, 'x');
 696:	85ea                	mv	a1,s10
 698:	8556                	mv	a0,s5
 69a:	00000097          	auipc	ra,0x0
 69e:	e08080e7          	jalr	-504(ra) # 4a2 <putc>
 6a2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6a4:	03c9d793          	srli	a5,s3,0x3c
 6a8:	97de                	add	a5,a5,s7
 6aa:	0007c583          	lbu	a1,0(a5)
 6ae:	8556                	mv	a0,s5
 6b0:	00000097          	auipc	ra,0x0
 6b4:	df2080e7          	jalr	-526(ra) # 4a2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6b8:	0992                	slli	s3,s3,0x4
 6ba:	397d                	addiw	s2,s2,-1
 6bc:	fe0914e3          	bnez	s2,6a4 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6c0:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6c4:	4981                	li	s3,0
 6c6:	b721                	j	5ce <vprintf+0x60>
        s = va_arg(ap, char*);
 6c8:	008b0993          	addi	s3,s6,8
 6cc:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 6d0:	02090163          	beqz	s2,6f2 <vprintf+0x184>
        while(*s != 0){
 6d4:	00094583          	lbu	a1,0(s2)
 6d8:	c9a1                	beqz	a1,728 <vprintf+0x1ba>
          putc(fd, *s);
 6da:	8556                	mv	a0,s5
 6dc:	00000097          	auipc	ra,0x0
 6e0:	dc6080e7          	jalr	-570(ra) # 4a2 <putc>
          s++;
 6e4:	0905                	addi	s2,s2,1
        while(*s != 0){
 6e6:	00094583          	lbu	a1,0(s2)
 6ea:	f9e5                	bnez	a1,6da <vprintf+0x16c>
        s = va_arg(ap, char*);
 6ec:	8b4e                	mv	s6,s3
      state = 0;
 6ee:	4981                	li	s3,0
 6f0:	bdf9                	j	5ce <vprintf+0x60>
          s = "(null)";
 6f2:	00000917          	auipc	s2,0x0
 6f6:	2de90913          	addi	s2,s2,734 # 9d0 <malloc+0x198>
        while(*s != 0){
 6fa:	02800593          	li	a1,40
 6fe:	bff1                	j	6da <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 700:	008b0913          	addi	s2,s6,8
 704:	000b4583          	lbu	a1,0(s6)
 708:	8556                	mv	a0,s5
 70a:	00000097          	auipc	ra,0x0
 70e:	d98080e7          	jalr	-616(ra) # 4a2 <putc>
 712:	8b4a                	mv	s6,s2
      state = 0;
 714:	4981                	li	s3,0
 716:	bd65                	j	5ce <vprintf+0x60>
        putc(fd, c);
 718:	85d2                	mv	a1,s4
 71a:	8556                	mv	a0,s5
 71c:	00000097          	auipc	ra,0x0
 720:	d86080e7          	jalr	-634(ra) # 4a2 <putc>
      state = 0;
 724:	4981                	li	s3,0
 726:	b565                	j	5ce <vprintf+0x60>
        s = va_arg(ap, char*);
 728:	8b4e                	mv	s6,s3
      state = 0;
 72a:	4981                	li	s3,0
 72c:	b54d                	j	5ce <vprintf+0x60>
    }
  }
}
 72e:	70e6                	ld	ra,120(sp)
 730:	7446                	ld	s0,112(sp)
 732:	74a6                	ld	s1,104(sp)
 734:	7906                	ld	s2,96(sp)
 736:	69e6                	ld	s3,88(sp)
 738:	6a46                	ld	s4,80(sp)
 73a:	6aa6                	ld	s5,72(sp)
 73c:	6b06                	ld	s6,64(sp)
 73e:	7be2                	ld	s7,56(sp)
 740:	7c42                	ld	s8,48(sp)
 742:	7ca2                	ld	s9,40(sp)
 744:	7d02                	ld	s10,32(sp)
 746:	6de2                	ld	s11,24(sp)
 748:	6109                	addi	sp,sp,128
 74a:	8082                	ret

000000000000074c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 74c:	715d                	addi	sp,sp,-80
 74e:	ec06                	sd	ra,24(sp)
 750:	e822                	sd	s0,16(sp)
 752:	1000                	addi	s0,sp,32
 754:	e010                	sd	a2,0(s0)
 756:	e414                	sd	a3,8(s0)
 758:	e818                	sd	a4,16(s0)
 75a:	ec1c                	sd	a5,24(s0)
 75c:	03043023          	sd	a6,32(s0)
 760:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 764:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 768:	8622                	mv	a2,s0
 76a:	00000097          	auipc	ra,0x0
 76e:	e04080e7          	jalr	-508(ra) # 56e <vprintf>
}
 772:	60e2                	ld	ra,24(sp)
 774:	6442                	ld	s0,16(sp)
 776:	6161                	addi	sp,sp,80
 778:	8082                	ret

000000000000077a <printf>:

void
printf(const char *fmt, ...)
{
 77a:	711d                	addi	sp,sp,-96
 77c:	ec06                	sd	ra,24(sp)
 77e:	e822                	sd	s0,16(sp)
 780:	1000                	addi	s0,sp,32
 782:	e40c                	sd	a1,8(s0)
 784:	e810                	sd	a2,16(s0)
 786:	ec14                	sd	a3,24(s0)
 788:	f018                	sd	a4,32(s0)
 78a:	f41c                	sd	a5,40(s0)
 78c:	03043823          	sd	a6,48(s0)
 790:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 794:	00840613          	addi	a2,s0,8
 798:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 79c:	85aa                	mv	a1,a0
 79e:	4505                	li	a0,1
 7a0:	00000097          	auipc	ra,0x0
 7a4:	dce080e7          	jalr	-562(ra) # 56e <vprintf>
}
 7a8:	60e2                	ld	ra,24(sp)
 7aa:	6442                	ld	s0,16(sp)
 7ac:	6125                	addi	sp,sp,96
 7ae:	8082                	ret

00000000000007b0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7b0:	1141                	addi	sp,sp,-16
 7b2:	e422                	sd	s0,8(sp)
 7b4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7b6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ba:	00001797          	auipc	a5,0x1
 7be:	8467b783          	ld	a5,-1978(a5) # 1000 <freep>
 7c2:	a805                	j	7f2 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7c4:	4618                	lw	a4,8(a2)
 7c6:	9db9                	addw	a1,a1,a4
 7c8:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7cc:	6398                	ld	a4,0(a5)
 7ce:	6318                	ld	a4,0(a4)
 7d0:	fee53823          	sd	a4,-16(a0)
 7d4:	a091                	j	818 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7d6:	ff852703          	lw	a4,-8(a0)
 7da:	9e39                	addw	a2,a2,a4
 7dc:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7de:	ff053703          	ld	a4,-16(a0)
 7e2:	e398                	sd	a4,0(a5)
 7e4:	a099                	j	82a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e6:	6398                	ld	a4,0(a5)
 7e8:	00e7e463          	bltu	a5,a4,7f0 <free+0x40>
 7ec:	00e6ea63          	bltu	a3,a4,800 <free+0x50>
{
 7f0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f2:	fed7fae3          	bgeu	a5,a3,7e6 <free+0x36>
 7f6:	6398                	ld	a4,0(a5)
 7f8:	00e6e463          	bltu	a3,a4,800 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7fc:	fee7eae3          	bltu	a5,a4,7f0 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 800:	ff852583          	lw	a1,-8(a0)
 804:	6390                	ld	a2,0(a5)
 806:	02059713          	slli	a4,a1,0x20
 80a:	9301                	srli	a4,a4,0x20
 80c:	0712                	slli	a4,a4,0x4
 80e:	9736                	add	a4,a4,a3
 810:	fae60ae3          	beq	a2,a4,7c4 <free+0x14>
    bp->s.ptr = p->s.ptr;
 814:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 818:	4790                	lw	a2,8(a5)
 81a:	02061713          	slli	a4,a2,0x20
 81e:	9301                	srli	a4,a4,0x20
 820:	0712                	slli	a4,a4,0x4
 822:	973e                	add	a4,a4,a5
 824:	fae689e3          	beq	a3,a4,7d6 <free+0x26>
  } else
    p->s.ptr = bp;
 828:	e394                	sd	a3,0(a5)
  freep = p;
 82a:	00000717          	auipc	a4,0x0
 82e:	7cf73b23          	sd	a5,2006(a4) # 1000 <freep>
}
 832:	6422                	ld	s0,8(sp)
 834:	0141                	addi	sp,sp,16
 836:	8082                	ret

0000000000000838 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 838:	7139                	addi	sp,sp,-64
 83a:	fc06                	sd	ra,56(sp)
 83c:	f822                	sd	s0,48(sp)
 83e:	f426                	sd	s1,40(sp)
 840:	f04a                	sd	s2,32(sp)
 842:	ec4e                	sd	s3,24(sp)
 844:	e852                	sd	s4,16(sp)
 846:	e456                	sd	s5,8(sp)
 848:	e05a                	sd	s6,0(sp)
 84a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 84c:	02051493          	slli	s1,a0,0x20
 850:	9081                	srli	s1,s1,0x20
 852:	04bd                	addi	s1,s1,15
 854:	8091                	srli	s1,s1,0x4
 856:	0014899b          	addiw	s3,s1,1
 85a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 85c:	00000517          	auipc	a0,0x0
 860:	7a453503          	ld	a0,1956(a0) # 1000 <freep>
 864:	c515                	beqz	a0,890 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 866:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 868:	4798                	lw	a4,8(a5)
 86a:	02977f63          	bgeu	a4,s1,8a8 <malloc+0x70>
 86e:	8a4e                	mv	s4,s3
 870:	0009871b          	sext.w	a4,s3
 874:	6685                	lui	a3,0x1
 876:	00d77363          	bgeu	a4,a3,87c <malloc+0x44>
 87a:	6a05                	lui	s4,0x1
 87c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 880:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 884:	00000917          	auipc	s2,0x0
 888:	77c90913          	addi	s2,s2,1916 # 1000 <freep>
  if(p == (char*)-1)
 88c:	5afd                	li	s5,-1
 88e:	a88d                	j	900 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 890:	00000797          	auipc	a5,0x0
 894:	78078793          	addi	a5,a5,1920 # 1010 <base>
 898:	00000717          	auipc	a4,0x0
 89c:	76f73423          	sd	a5,1896(a4) # 1000 <freep>
 8a0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8a2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8a6:	b7e1                	j	86e <malloc+0x36>
      if(p->s.size == nunits)
 8a8:	02e48b63          	beq	s1,a4,8de <malloc+0xa6>
        p->s.size -= nunits;
 8ac:	4137073b          	subw	a4,a4,s3
 8b0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8b2:	1702                	slli	a4,a4,0x20
 8b4:	9301                	srli	a4,a4,0x20
 8b6:	0712                	slli	a4,a4,0x4
 8b8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8ba:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8be:	00000717          	auipc	a4,0x0
 8c2:	74a73123          	sd	a0,1858(a4) # 1000 <freep>
      return (void*)(p + 1);
 8c6:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8ca:	70e2                	ld	ra,56(sp)
 8cc:	7442                	ld	s0,48(sp)
 8ce:	74a2                	ld	s1,40(sp)
 8d0:	7902                	ld	s2,32(sp)
 8d2:	69e2                	ld	s3,24(sp)
 8d4:	6a42                	ld	s4,16(sp)
 8d6:	6aa2                	ld	s5,8(sp)
 8d8:	6b02                	ld	s6,0(sp)
 8da:	6121                	addi	sp,sp,64
 8dc:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8de:	6398                	ld	a4,0(a5)
 8e0:	e118                	sd	a4,0(a0)
 8e2:	bff1                	j	8be <malloc+0x86>
  hp->s.size = nu;
 8e4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8e8:	0541                	addi	a0,a0,16
 8ea:	00000097          	auipc	ra,0x0
 8ee:	ec6080e7          	jalr	-314(ra) # 7b0 <free>
  return freep;
 8f2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8f6:	d971                	beqz	a0,8ca <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8f8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8fa:	4798                	lw	a4,8(a5)
 8fc:	fa9776e3          	bgeu	a4,s1,8a8 <malloc+0x70>
    if(p == freep)
 900:	00093703          	ld	a4,0(s2)
 904:	853e                	mv	a0,a5
 906:	fef719e3          	bne	a4,a5,8f8 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 90a:	8552                	mv	a0,s4
 90c:	00000097          	auipc	ra,0x0
 910:	b56080e7          	jalr	-1194(ra) # 462 <sbrk>
  if(p == (char*)-1)
 914:	fd5518e3          	bne	a0,s5,8e4 <malloc+0xac>
        return 0;
 918:	4501                	li	a0,0
 91a:	bf45                	j	8ca <malloc+0x92>
