
user/_helloworld:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
     write(1, "Hello World xv6", strlen("Hello World xv6"));
   8:	00001517          	auipc	a0,0x1
   c:	82850513          	addi	a0,a0,-2008 # 830 <malloc+0xee>
  10:	00000097          	auipc	ra,0x0
  14:	0ae080e7          	jalr	174(ra) # be <strlen>
  18:	0005061b          	sext.w	a2,a0
  1c:	00001597          	auipc	a1,0x1
  20:	81458593          	addi	a1,a1,-2028 # 830 <malloc+0xee>
  24:	4505                	li	a0,1
  26:	00000097          	auipc	ra,0x0
  2a:	2de080e7          	jalr	734(ra) # 304 <write>
     write(1, "\n", 1);
  2e:	4605                	li	a2,1
  30:	00001597          	auipc	a1,0x1
  34:	81058593          	addi	a1,a1,-2032 # 840 <malloc+0xfe>
  38:	4505                	li	a0,1
  3a:	00000097          	auipc	ra,0x0
  3e:	2ca080e7          	jalr	714(ra) # 304 <write>
  exit(0,"");
  42:	00001597          	auipc	a1,0x1
  46:	80658593          	addi	a1,a1,-2042 # 848 <malloc+0x106>
  4a:	4501                	li	a0,0
  4c:	00000097          	auipc	ra,0x0
  50:	298080e7          	jalr	664(ra) # 2e4 <exit>

0000000000000054 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  54:	1141                	addi	sp,sp,-16
  56:	e406                	sd	ra,8(sp)
  58:	e022                	sd	s0,0(sp)
  5a:	0800                	addi	s0,sp,16
  extern int main();
  main();
  5c:	00000097          	auipc	ra,0x0
  60:	fa4080e7          	jalr	-92(ra) # 0 <main>
  exit(0,"");
  64:	00000597          	auipc	a1,0x0
  68:	7e458593          	addi	a1,a1,2020 # 848 <malloc+0x106>
  6c:	4501                	li	a0,0
  6e:	00000097          	auipc	ra,0x0
  72:	276080e7          	jalr	630(ra) # 2e4 <exit>

0000000000000076 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  76:	1141                	addi	sp,sp,-16
  78:	e422                	sd	s0,8(sp)
  7a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  7c:	87aa                	mv	a5,a0
  7e:	0585                	addi	a1,a1,1
  80:	0785                	addi	a5,a5,1
  82:	fff5c703          	lbu	a4,-1(a1)
  86:	fee78fa3          	sb	a4,-1(a5)
  8a:	fb75                	bnez	a4,7e <strcpy+0x8>
    ;
  return os;
}
  8c:	6422                	ld	s0,8(sp)
  8e:	0141                	addi	sp,sp,16
  90:	8082                	ret

0000000000000092 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  92:	1141                	addi	sp,sp,-16
  94:	e422                	sd	s0,8(sp)
  96:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  98:	00054783          	lbu	a5,0(a0)
  9c:	cb91                	beqz	a5,b0 <strcmp+0x1e>
  9e:	0005c703          	lbu	a4,0(a1)
  a2:	00f71763          	bne	a4,a5,b0 <strcmp+0x1e>
    p++, q++;
  a6:	0505                	addi	a0,a0,1
  a8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  aa:	00054783          	lbu	a5,0(a0)
  ae:	fbe5                	bnez	a5,9e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  b0:	0005c503          	lbu	a0,0(a1)
}
  b4:	40a7853b          	subw	a0,a5,a0
  b8:	6422                	ld	s0,8(sp)
  ba:	0141                	addi	sp,sp,16
  bc:	8082                	ret

00000000000000be <strlen>:

uint
strlen(const char *s)
{
  be:	1141                	addi	sp,sp,-16
  c0:	e422                	sd	s0,8(sp)
  c2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  c4:	00054783          	lbu	a5,0(a0)
  c8:	cf91                	beqz	a5,e4 <strlen+0x26>
  ca:	0505                	addi	a0,a0,1
  cc:	87aa                	mv	a5,a0
  ce:	4685                	li	a3,1
  d0:	9e89                	subw	a3,a3,a0
  d2:	00f6853b          	addw	a0,a3,a5
  d6:	0785                	addi	a5,a5,1
  d8:	fff7c703          	lbu	a4,-1(a5)
  dc:	fb7d                	bnez	a4,d2 <strlen+0x14>
    ;
  return n;
}
  de:	6422                	ld	s0,8(sp)
  e0:	0141                	addi	sp,sp,16
  e2:	8082                	ret
  for(n = 0; s[n]; n++)
  e4:	4501                	li	a0,0
  e6:	bfe5                	j	de <strlen+0x20>

00000000000000e8 <memset>:

void*
memset(void *dst, int c, uint n)
{
  e8:	1141                	addi	sp,sp,-16
  ea:	e422                	sd	s0,8(sp)
  ec:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  ee:	ca19                	beqz	a2,104 <memset+0x1c>
  f0:	87aa                	mv	a5,a0
  f2:	1602                	slli	a2,a2,0x20
  f4:	9201                	srli	a2,a2,0x20
  f6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  fa:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  fe:	0785                	addi	a5,a5,1
 100:	fee79de3          	bne	a5,a4,fa <memset+0x12>
  }
  return dst;
}
 104:	6422                	ld	s0,8(sp)
 106:	0141                	addi	sp,sp,16
 108:	8082                	ret

000000000000010a <strchr>:

char*
strchr(const char *s, char c)
{
 10a:	1141                	addi	sp,sp,-16
 10c:	e422                	sd	s0,8(sp)
 10e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 110:	00054783          	lbu	a5,0(a0)
 114:	cb99                	beqz	a5,12a <strchr+0x20>
    if(*s == c)
 116:	00f58763          	beq	a1,a5,124 <strchr+0x1a>
  for(; *s; s++)
 11a:	0505                	addi	a0,a0,1
 11c:	00054783          	lbu	a5,0(a0)
 120:	fbfd                	bnez	a5,116 <strchr+0xc>
      return (char*)s;
  return 0;
 122:	4501                	li	a0,0
}
 124:	6422                	ld	s0,8(sp)
 126:	0141                	addi	sp,sp,16
 128:	8082                	ret
  return 0;
 12a:	4501                	li	a0,0
 12c:	bfe5                	j	124 <strchr+0x1a>

000000000000012e <gets>:

char*
gets(char *buf, int max)
{
 12e:	711d                	addi	sp,sp,-96
 130:	ec86                	sd	ra,88(sp)
 132:	e8a2                	sd	s0,80(sp)
 134:	e4a6                	sd	s1,72(sp)
 136:	e0ca                	sd	s2,64(sp)
 138:	fc4e                	sd	s3,56(sp)
 13a:	f852                	sd	s4,48(sp)
 13c:	f456                	sd	s5,40(sp)
 13e:	f05a                	sd	s6,32(sp)
 140:	ec5e                	sd	s7,24(sp)
 142:	1080                	addi	s0,sp,96
 144:	8baa                	mv	s7,a0
 146:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 148:	892a                	mv	s2,a0
 14a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 14c:	4aa9                	li	s5,10
 14e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 150:	89a6                	mv	s3,s1
 152:	2485                	addiw	s1,s1,1
 154:	0344d863          	bge	s1,s4,184 <gets+0x56>
    cc = read(0, &c, 1);
 158:	4605                	li	a2,1
 15a:	faf40593          	addi	a1,s0,-81
 15e:	4501                	li	a0,0
 160:	00000097          	auipc	ra,0x0
 164:	19c080e7          	jalr	412(ra) # 2fc <read>
    if(cc < 1)
 168:	00a05e63          	blez	a0,184 <gets+0x56>
    buf[i++] = c;
 16c:	faf44783          	lbu	a5,-81(s0)
 170:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 174:	01578763          	beq	a5,s5,182 <gets+0x54>
 178:	0905                	addi	s2,s2,1
 17a:	fd679be3          	bne	a5,s6,150 <gets+0x22>
  for(i=0; i+1 < max; ){
 17e:	89a6                	mv	s3,s1
 180:	a011                	j	184 <gets+0x56>
 182:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 184:	99de                	add	s3,s3,s7
 186:	00098023          	sb	zero,0(s3)
  return buf;
}
 18a:	855e                	mv	a0,s7
 18c:	60e6                	ld	ra,88(sp)
 18e:	6446                	ld	s0,80(sp)
 190:	64a6                	ld	s1,72(sp)
 192:	6906                	ld	s2,64(sp)
 194:	79e2                	ld	s3,56(sp)
 196:	7a42                	ld	s4,48(sp)
 198:	7aa2                	ld	s5,40(sp)
 19a:	7b02                	ld	s6,32(sp)
 19c:	6be2                	ld	s7,24(sp)
 19e:	6125                	addi	sp,sp,96
 1a0:	8082                	ret

00000000000001a2 <stat>:

int
stat(const char *n, struct stat *st)
{
 1a2:	1101                	addi	sp,sp,-32
 1a4:	ec06                	sd	ra,24(sp)
 1a6:	e822                	sd	s0,16(sp)
 1a8:	e426                	sd	s1,8(sp)
 1aa:	e04a                	sd	s2,0(sp)
 1ac:	1000                	addi	s0,sp,32
 1ae:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1b0:	4581                	li	a1,0
 1b2:	00000097          	auipc	ra,0x0
 1b6:	172080e7          	jalr	370(ra) # 324 <open>
  if(fd < 0)
 1ba:	02054563          	bltz	a0,1e4 <stat+0x42>
 1be:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1c0:	85ca                	mv	a1,s2
 1c2:	00000097          	auipc	ra,0x0
 1c6:	17a080e7          	jalr	378(ra) # 33c <fstat>
 1ca:	892a                	mv	s2,a0
  close(fd);
 1cc:	8526                	mv	a0,s1
 1ce:	00000097          	auipc	ra,0x0
 1d2:	13e080e7          	jalr	318(ra) # 30c <close>
  return r;
}
 1d6:	854a                	mv	a0,s2
 1d8:	60e2                	ld	ra,24(sp)
 1da:	6442                	ld	s0,16(sp)
 1dc:	64a2                	ld	s1,8(sp)
 1de:	6902                	ld	s2,0(sp)
 1e0:	6105                	addi	sp,sp,32
 1e2:	8082                	ret
    return -1;
 1e4:	597d                	li	s2,-1
 1e6:	bfc5                	j	1d6 <stat+0x34>

00000000000001e8 <atoi>:

int
atoi(const char *s)
{
 1e8:	1141                	addi	sp,sp,-16
 1ea:	e422                	sd	s0,8(sp)
 1ec:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1ee:	00054603          	lbu	a2,0(a0)
 1f2:	fd06079b          	addiw	a5,a2,-48
 1f6:	0ff7f793          	andi	a5,a5,255
 1fa:	4725                	li	a4,9
 1fc:	02f76963          	bltu	a4,a5,22e <atoi+0x46>
 200:	86aa                	mv	a3,a0
  n = 0;
 202:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 204:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 206:	0685                	addi	a3,a3,1
 208:	0025179b          	slliw	a5,a0,0x2
 20c:	9fa9                	addw	a5,a5,a0
 20e:	0017979b          	slliw	a5,a5,0x1
 212:	9fb1                	addw	a5,a5,a2
 214:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 218:	0006c603          	lbu	a2,0(a3)
 21c:	fd06071b          	addiw	a4,a2,-48
 220:	0ff77713          	andi	a4,a4,255
 224:	fee5f1e3          	bgeu	a1,a4,206 <atoi+0x1e>
  return n;
}
 228:	6422                	ld	s0,8(sp)
 22a:	0141                	addi	sp,sp,16
 22c:	8082                	ret
  n = 0;
 22e:	4501                	li	a0,0
 230:	bfe5                	j	228 <atoi+0x40>

0000000000000232 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 232:	1141                	addi	sp,sp,-16
 234:	e422                	sd	s0,8(sp)
 236:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 238:	02b57463          	bgeu	a0,a1,260 <memmove+0x2e>
    while(n-- > 0)
 23c:	00c05f63          	blez	a2,25a <memmove+0x28>
 240:	1602                	slli	a2,a2,0x20
 242:	9201                	srli	a2,a2,0x20
 244:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 248:	872a                	mv	a4,a0
      *dst++ = *src++;
 24a:	0585                	addi	a1,a1,1
 24c:	0705                	addi	a4,a4,1
 24e:	fff5c683          	lbu	a3,-1(a1)
 252:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 256:	fee79ae3          	bne	a5,a4,24a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 25a:	6422                	ld	s0,8(sp)
 25c:	0141                	addi	sp,sp,16
 25e:	8082                	ret
    dst += n;
 260:	00c50733          	add	a4,a0,a2
    src += n;
 264:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 266:	fec05ae3          	blez	a2,25a <memmove+0x28>
 26a:	fff6079b          	addiw	a5,a2,-1
 26e:	1782                	slli	a5,a5,0x20
 270:	9381                	srli	a5,a5,0x20
 272:	fff7c793          	not	a5,a5
 276:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 278:	15fd                	addi	a1,a1,-1
 27a:	177d                	addi	a4,a4,-1
 27c:	0005c683          	lbu	a3,0(a1)
 280:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 284:	fee79ae3          	bne	a5,a4,278 <memmove+0x46>
 288:	bfc9                	j	25a <memmove+0x28>

000000000000028a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 28a:	1141                	addi	sp,sp,-16
 28c:	e422                	sd	s0,8(sp)
 28e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 290:	ca05                	beqz	a2,2c0 <memcmp+0x36>
 292:	fff6069b          	addiw	a3,a2,-1
 296:	1682                	slli	a3,a3,0x20
 298:	9281                	srli	a3,a3,0x20
 29a:	0685                	addi	a3,a3,1
 29c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 29e:	00054783          	lbu	a5,0(a0)
 2a2:	0005c703          	lbu	a4,0(a1)
 2a6:	00e79863          	bne	a5,a4,2b6 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2aa:	0505                	addi	a0,a0,1
    p2++;
 2ac:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2ae:	fed518e3          	bne	a0,a3,29e <memcmp+0x14>
  }
  return 0;
 2b2:	4501                	li	a0,0
 2b4:	a019                	j	2ba <memcmp+0x30>
      return *p1 - *p2;
 2b6:	40e7853b          	subw	a0,a5,a4
}
 2ba:	6422                	ld	s0,8(sp)
 2bc:	0141                	addi	sp,sp,16
 2be:	8082                	ret
  return 0;
 2c0:	4501                	li	a0,0
 2c2:	bfe5                	j	2ba <memcmp+0x30>

00000000000002c4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2c4:	1141                	addi	sp,sp,-16
 2c6:	e406                	sd	ra,8(sp)
 2c8:	e022                	sd	s0,0(sp)
 2ca:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2cc:	00000097          	auipc	ra,0x0
 2d0:	f66080e7          	jalr	-154(ra) # 232 <memmove>
}
 2d4:	60a2                	ld	ra,8(sp)
 2d6:	6402                	ld	s0,0(sp)
 2d8:	0141                	addi	sp,sp,16
 2da:	8082                	ret

00000000000002dc <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2dc:	4885                	li	a7,1
 ecall
 2de:	00000073          	ecall
 ret
 2e2:	8082                	ret

00000000000002e4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2e4:	4889                	li	a7,2
 ecall
 2e6:	00000073          	ecall
 ret
 2ea:	8082                	ret

00000000000002ec <wait>:
.global wait
wait:
 li a7, SYS_wait
 2ec:	488d                	li	a7,3
 ecall
 2ee:	00000073          	ecall
 ret
 2f2:	8082                	ret

00000000000002f4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2f4:	4891                	li	a7,4
 ecall
 2f6:	00000073          	ecall
 ret
 2fa:	8082                	ret

00000000000002fc <read>:
.global read
read:
 li a7, SYS_read
 2fc:	4895                	li	a7,5
 ecall
 2fe:	00000073          	ecall
 ret
 302:	8082                	ret

0000000000000304 <write>:
.global write
write:
 li a7, SYS_write
 304:	48c1                	li	a7,16
 ecall
 306:	00000073          	ecall
 ret
 30a:	8082                	ret

000000000000030c <close>:
.global close
close:
 li a7, SYS_close
 30c:	48d5                	li	a7,21
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <kill>:
.global kill
kill:
 li a7, SYS_kill
 314:	4899                	li	a7,6
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <exec>:
.global exec
exec:
 li a7, SYS_exec
 31c:	489d                	li	a7,7
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <open>:
.global open
open:
 li a7, SYS_open
 324:	48bd                	li	a7,15
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 32c:	48c5                	li	a7,17
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 334:	48c9                	li	a7,18
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 33c:	48a1                	li	a7,8
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <link>:
.global link
link:
 li a7, SYS_link
 344:	48cd                	li	a7,19
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 34c:	48d1                	li	a7,20
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 354:	48a5                	li	a7,9
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <dup>:
.global dup
dup:
 li a7, SYS_dup
 35c:	48a9                	li	a7,10
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 364:	48ad                	li	a7,11
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 36c:	48b1                	li	a7,12
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 374:	48b5                	li	a7,13
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 37c:	48b9                	li	a7,14
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <memsize>:
.global memsize
memsize:
 li a7, SYS_memsize
 384:	48d9                	li	a7,22
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <set_ps_priority>:
.global set_ps_priority
set_ps_priority:
 li a7, SYS_set_ps_priority
 38c:	48dd                	li	a7,23
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <set_cfs_priority>:
.global set_cfs_priority
set_cfs_priority:
 li a7, SYS_set_cfs_priority
 394:	48e1                	li	a7,24
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <get_cfs_stats>:
.global get_cfs_stats
get_cfs_stats:
 li a7, SYS_get_cfs_stats
 39c:	48e5                	li	a7,25
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <set_policy>:
.global set_policy
set_policy:
 li a7, SYS_set_policy
 3a4:	48e9                	li	a7,26
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3ac:	1101                	addi	sp,sp,-32
 3ae:	ec06                	sd	ra,24(sp)
 3b0:	e822                	sd	s0,16(sp)
 3b2:	1000                	addi	s0,sp,32
 3b4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3b8:	4605                	li	a2,1
 3ba:	fef40593          	addi	a1,s0,-17
 3be:	00000097          	auipc	ra,0x0
 3c2:	f46080e7          	jalr	-186(ra) # 304 <write>
}
 3c6:	60e2                	ld	ra,24(sp)
 3c8:	6442                	ld	s0,16(sp)
 3ca:	6105                	addi	sp,sp,32
 3cc:	8082                	ret

00000000000003ce <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3ce:	7139                	addi	sp,sp,-64
 3d0:	fc06                	sd	ra,56(sp)
 3d2:	f822                	sd	s0,48(sp)
 3d4:	f426                	sd	s1,40(sp)
 3d6:	f04a                	sd	s2,32(sp)
 3d8:	ec4e                	sd	s3,24(sp)
 3da:	0080                	addi	s0,sp,64
 3dc:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3de:	c299                	beqz	a3,3e4 <printint+0x16>
 3e0:	0805c863          	bltz	a1,470 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3e4:	2581                	sext.w	a1,a1
  neg = 0;
 3e6:	4881                	li	a7,0
 3e8:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3ec:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3ee:	2601                	sext.w	a2,a2
 3f0:	00000517          	auipc	a0,0x0
 3f4:	46850513          	addi	a0,a0,1128 # 858 <digits>
 3f8:	883a                	mv	a6,a4
 3fa:	2705                	addiw	a4,a4,1
 3fc:	02c5f7bb          	remuw	a5,a1,a2
 400:	1782                	slli	a5,a5,0x20
 402:	9381                	srli	a5,a5,0x20
 404:	97aa                	add	a5,a5,a0
 406:	0007c783          	lbu	a5,0(a5)
 40a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 40e:	0005879b          	sext.w	a5,a1
 412:	02c5d5bb          	divuw	a1,a1,a2
 416:	0685                	addi	a3,a3,1
 418:	fec7f0e3          	bgeu	a5,a2,3f8 <printint+0x2a>
  if(neg)
 41c:	00088b63          	beqz	a7,432 <printint+0x64>
    buf[i++] = '-';
 420:	fd040793          	addi	a5,s0,-48
 424:	973e                	add	a4,a4,a5
 426:	02d00793          	li	a5,45
 42a:	fef70823          	sb	a5,-16(a4)
 42e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 432:	02e05863          	blez	a4,462 <printint+0x94>
 436:	fc040793          	addi	a5,s0,-64
 43a:	00e78933          	add	s2,a5,a4
 43e:	fff78993          	addi	s3,a5,-1
 442:	99ba                	add	s3,s3,a4
 444:	377d                	addiw	a4,a4,-1
 446:	1702                	slli	a4,a4,0x20
 448:	9301                	srli	a4,a4,0x20
 44a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 44e:	fff94583          	lbu	a1,-1(s2)
 452:	8526                	mv	a0,s1
 454:	00000097          	auipc	ra,0x0
 458:	f58080e7          	jalr	-168(ra) # 3ac <putc>
  while(--i >= 0)
 45c:	197d                	addi	s2,s2,-1
 45e:	ff3918e3          	bne	s2,s3,44e <printint+0x80>
}
 462:	70e2                	ld	ra,56(sp)
 464:	7442                	ld	s0,48(sp)
 466:	74a2                	ld	s1,40(sp)
 468:	7902                	ld	s2,32(sp)
 46a:	69e2                	ld	s3,24(sp)
 46c:	6121                	addi	sp,sp,64
 46e:	8082                	ret
    x = -xx;
 470:	40b005bb          	negw	a1,a1
    neg = 1;
 474:	4885                	li	a7,1
    x = -xx;
 476:	bf8d                	j	3e8 <printint+0x1a>

0000000000000478 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 478:	7119                	addi	sp,sp,-128
 47a:	fc86                	sd	ra,120(sp)
 47c:	f8a2                	sd	s0,112(sp)
 47e:	f4a6                	sd	s1,104(sp)
 480:	f0ca                	sd	s2,96(sp)
 482:	ecce                	sd	s3,88(sp)
 484:	e8d2                	sd	s4,80(sp)
 486:	e4d6                	sd	s5,72(sp)
 488:	e0da                	sd	s6,64(sp)
 48a:	fc5e                	sd	s7,56(sp)
 48c:	f862                	sd	s8,48(sp)
 48e:	f466                	sd	s9,40(sp)
 490:	f06a                	sd	s10,32(sp)
 492:	ec6e                	sd	s11,24(sp)
 494:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 496:	0005c903          	lbu	s2,0(a1)
 49a:	18090f63          	beqz	s2,638 <vprintf+0x1c0>
 49e:	8aaa                	mv	s5,a0
 4a0:	8b32                	mv	s6,a2
 4a2:	00158493          	addi	s1,a1,1
  state = 0;
 4a6:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4a8:	02500a13          	li	s4,37
      if(c == 'd'){
 4ac:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 4b0:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 4b4:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 4b8:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4bc:	00000b97          	auipc	s7,0x0
 4c0:	39cb8b93          	addi	s7,s7,924 # 858 <digits>
 4c4:	a839                	j	4e2 <vprintf+0x6a>
        putc(fd, c);
 4c6:	85ca                	mv	a1,s2
 4c8:	8556                	mv	a0,s5
 4ca:	00000097          	auipc	ra,0x0
 4ce:	ee2080e7          	jalr	-286(ra) # 3ac <putc>
 4d2:	a019                	j	4d8 <vprintf+0x60>
    } else if(state == '%'){
 4d4:	01498f63          	beq	s3,s4,4f2 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4d8:	0485                	addi	s1,s1,1
 4da:	fff4c903          	lbu	s2,-1(s1)
 4de:	14090d63          	beqz	s2,638 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 4e2:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4e6:	fe0997e3          	bnez	s3,4d4 <vprintf+0x5c>
      if(c == '%'){
 4ea:	fd479ee3          	bne	a5,s4,4c6 <vprintf+0x4e>
        state = '%';
 4ee:	89be                	mv	s3,a5
 4f0:	b7e5                	j	4d8 <vprintf+0x60>
      if(c == 'd'){
 4f2:	05878063          	beq	a5,s8,532 <vprintf+0xba>
      } else if(c == 'l') {
 4f6:	05978c63          	beq	a5,s9,54e <vprintf+0xd6>
      } else if(c == 'x') {
 4fa:	07a78863          	beq	a5,s10,56a <vprintf+0xf2>
      } else if(c == 'p') {
 4fe:	09b78463          	beq	a5,s11,586 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 502:	07300713          	li	a4,115
 506:	0ce78663          	beq	a5,a4,5d2 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 50a:	06300713          	li	a4,99
 50e:	0ee78e63          	beq	a5,a4,60a <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 512:	11478863          	beq	a5,s4,622 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 516:	85d2                	mv	a1,s4
 518:	8556                	mv	a0,s5
 51a:	00000097          	auipc	ra,0x0
 51e:	e92080e7          	jalr	-366(ra) # 3ac <putc>
        putc(fd, c);
 522:	85ca                	mv	a1,s2
 524:	8556                	mv	a0,s5
 526:	00000097          	auipc	ra,0x0
 52a:	e86080e7          	jalr	-378(ra) # 3ac <putc>
      }
      state = 0;
 52e:	4981                	li	s3,0
 530:	b765                	j	4d8 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 532:	008b0913          	addi	s2,s6,8
 536:	4685                	li	a3,1
 538:	4629                	li	a2,10
 53a:	000b2583          	lw	a1,0(s6)
 53e:	8556                	mv	a0,s5
 540:	00000097          	auipc	ra,0x0
 544:	e8e080e7          	jalr	-370(ra) # 3ce <printint>
 548:	8b4a                	mv	s6,s2
      state = 0;
 54a:	4981                	li	s3,0
 54c:	b771                	j	4d8 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 54e:	008b0913          	addi	s2,s6,8
 552:	4681                	li	a3,0
 554:	4629                	li	a2,10
 556:	000b2583          	lw	a1,0(s6)
 55a:	8556                	mv	a0,s5
 55c:	00000097          	auipc	ra,0x0
 560:	e72080e7          	jalr	-398(ra) # 3ce <printint>
 564:	8b4a                	mv	s6,s2
      state = 0;
 566:	4981                	li	s3,0
 568:	bf85                	j	4d8 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 56a:	008b0913          	addi	s2,s6,8
 56e:	4681                	li	a3,0
 570:	4641                	li	a2,16
 572:	000b2583          	lw	a1,0(s6)
 576:	8556                	mv	a0,s5
 578:	00000097          	auipc	ra,0x0
 57c:	e56080e7          	jalr	-426(ra) # 3ce <printint>
 580:	8b4a                	mv	s6,s2
      state = 0;
 582:	4981                	li	s3,0
 584:	bf91                	j	4d8 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 586:	008b0793          	addi	a5,s6,8
 58a:	f8f43423          	sd	a5,-120(s0)
 58e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 592:	03000593          	li	a1,48
 596:	8556                	mv	a0,s5
 598:	00000097          	auipc	ra,0x0
 59c:	e14080e7          	jalr	-492(ra) # 3ac <putc>
  putc(fd, 'x');
 5a0:	85ea                	mv	a1,s10
 5a2:	8556                	mv	a0,s5
 5a4:	00000097          	auipc	ra,0x0
 5a8:	e08080e7          	jalr	-504(ra) # 3ac <putc>
 5ac:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5ae:	03c9d793          	srli	a5,s3,0x3c
 5b2:	97de                	add	a5,a5,s7
 5b4:	0007c583          	lbu	a1,0(a5)
 5b8:	8556                	mv	a0,s5
 5ba:	00000097          	auipc	ra,0x0
 5be:	df2080e7          	jalr	-526(ra) # 3ac <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5c2:	0992                	slli	s3,s3,0x4
 5c4:	397d                	addiw	s2,s2,-1
 5c6:	fe0914e3          	bnez	s2,5ae <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 5ca:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 5ce:	4981                	li	s3,0
 5d0:	b721                	j	4d8 <vprintf+0x60>
        s = va_arg(ap, char*);
 5d2:	008b0993          	addi	s3,s6,8
 5d6:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 5da:	02090163          	beqz	s2,5fc <vprintf+0x184>
        while(*s != 0){
 5de:	00094583          	lbu	a1,0(s2)
 5e2:	c9a1                	beqz	a1,632 <vprintf+0x1ba>
          putc(fd, *s);
 5e4:	8556                	mv	a0,s5
 5e6:	00000097          	auipc	ra,0x0
 5ea:	dc6080e7          	jalr	-570(ra) # 3ac <putc>
          s++;
 5ee:	0905                	addi	s2,s2,1
        while(*s != 0){
 5f0:	00094583          	lbu	a1,0(s2)
 5f4:	f9e5                	bnez	a1,5e4 <vprintf+0x16c>
        s = va_arg(ap, char*);
 5f6:	8b4e                	mv	s6,s3
      state = 0;
 5f8:	4981                	li	s3,0
 5fa:	bdf9                	j	4d8 <vprintf+0x60>
          s = "(null)";
 5fc:	00000917          	auipc	s2,0x0
 600:	25490913          	addi	s2,s2,596 # 850 <malloc+0x10e>
        while(*s != 0){
 604:	02800593          	li	a1,40
 608:	bff1                	j	5e4 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 60a:	008b0913          	addi	s2,s6,8
 60e:	000b4583          	lbu	a1,0(s6)
 612:	8556                	mv	a0,s5
 614:	00000097          	auipc	ra,0x0
 618:	d98080e7          	jalr	-616(ra) # 3ac <putc>
 61c:	8b4a                	mv	s6,s2
      state = 0;
 61e:	4981                	li	s3,0
 620:	bd65                	j	4d8 <vprintf+0x60>
        putc(fd, c);
 622:	85d2                	mv	a1,s4
 624:	8556                	mv	a0,s5
 626:	00000097          	auipc	ra,0x0
 62a:	d86080e7          	jalr	-634(ra) # 3ac <putc>
      state = 0;
 62e:	4981                	li	s3,0
 630:	b565                	j	4d8 <vprintf+0x60>
        s = va_arg(ap, char*);
 632:	8b4e                	mv	s6,s3
      state = 0;
 634:	4981                	li	s3,0
 636:	b54d                	j	4d8 <vprintf+0x60>
    }
  }
}
 638:	70e6                	ld	ra,120(sp)
 63a:	7446                	ld	s0,112(sp)
 63c:	74a6                	ld	s1,104(sp)
 63e:	7906                	ld	s2,96(sp)
 640:	69e6                	ld	s3,88(sp)
 642:	6a46                	ld	s4,80(sp)
 644:	6aa6                	ld	s5,72(sp)
 646:	6b06                	ld	s6,64(sp)
 648:	7be2                	ld	s7,56(sp)
 64a:	7c42                	ld	s8,48(sp)
 64c:	7ca2                	ld	s9,40(sp)
 64e:	7d02                	ld	s10,32(sp)
 650:	6de2                	ld	s11,24(sp)
 652:	6109                	addi	sp,sp,128
 654:	8082                	ret

0000000000000656 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 656:	715d                	addi	sp,sp,-80
 658:	ec06                	sd	ra,24(sp)
 65a:	e822                	sd	s0,16(sp)
 65c:	1000                	addi	s0,sp,32
 65e:	e010                	sd	a2,0(s0)
 660:	e414                	sd	a3,8(s0)
 662:	e818                	sd	a4,16(s0)
 664:	ec1c                	sd	a5,24(s0)
 666:	03043023          	sd	a6,32(s0)
 66a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 66e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 672:	8622                	mv	a2,s0
 674:	00000097          	auipc	ra,0x0
 678:	e04080e7          	jalr	-508(ra) # 478 <vprintf>
}
 67c:	60e2                	ld	ra,24(sp)
 67e:	6442                	ld	s0,16(sp)
 680:	6161                	addi	sp,sp,80
 682:	8082                	ret

0000000000000684 <printf>:

void
printf(const char *fmt, ...)
{
 684:	711d                	addi	sp,sp,-96
 686:	ec06                	sd	ra,24(sp)
 688:	e822                	sd	s0,16(sp)
 68a:	1000                	addi	s0,sp,32
 68c:	e40c                	sd	a1,8(s0)
 68e:	e810                	sd	a2,16(s0)
 690:	ec14                	sd	a3,24(s0)
 692:	f018                	sd	a4,32(s0)
 694:	f41c                	sd	a5,40(s0)
 696:	03043823          	sd	a6,48(s0)
 69a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 69e:	00840613          	addi	a2,s0,8
 6a2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6a6:	85aa                	mv	a1,a0
 6a8:	4505                	li	a0,1
 6aa:	00000097          	auipc	ra,0x0
 6ae:	dce080e7          	jalr	-562(ra) # 478 <vprintf>
}
 6b2:	60e2                	ld	ra,24(sp)
 6b4:	6442                	ld	s0,16(sp)
 6b6:	6125                	addi	sp,sp,96
 6b8:	8082                	ret

00000000000006ba <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6ba:	1141                	addi	sp,sp,-16
 6bc:	e422                	sd	s0,8(sp)
 6be:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6c0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6c4:	00001797          	auipc	a5,0x1
 6c8:	93c7b783          	ld	a5,-1732(a5) # 1000 <freep>
 6cc:	a805                	j	6fc <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6ce:	4618                	lw	a4,8(a2)
 6d0:	9db9                	addw	a1,a1,a4
 6d2:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6d6:	6398                	ld	a4,0(a5)
 6d8:	6318                	ld	a4,0(a4)
 6da:	fee53823          	sd	a4,-16(a0)
 6de:	a091                	j	722 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6e0:	ff852703          	lw	a4,-8(a0)
 6e4:	9e39                	addw	a2,a2,a4
 6e6:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 6e8:	ff053703          	ld	a4,-16(a0)
 6ec:	e398                	sd	a4,0(a5)
 6ee:	a099                	j	734 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6f0:	6398                	ld	a4,0(a5)
 6f2:	00e7e463          	bltu	a5,a4,6fa <free+0x40>
 6f6:	00e6ea63          	bltu	a3,a4,70a <free+0x50>
{
 6fa:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6fc:	fed7fae3          	bgeu	a5,a3,6f0 <free+0x36>
 700:	6398                	ld	a4,0(a5)
 702:	00e6e463          	bltu	a3,a4,70a <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 706:	fee7eae3          	bltu	a5,a4,6fa <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 70a:	ff852583          	lw	a1,-8(a0)
 70e:	6390                	ld	a2,0(a5)
 710:	02059713          	slli	a4,a1,0x20
 714:	9301                	srli	a4,a4,0x20
 716:	0712                	slli	a4,a4,0x4
 718:	9736                	add	a4,a4,a3
 71a:	fae60ae3          	beq	a2,a4,6ce <free+0x14>
    bp->s.ptr = p->s.ptr;
 71e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 722:	4790                	lw	a2,8(a5)
 724:	02061713          	slli	a4,a2,0x20
 728:	9301                	srli	a4,a4,0x20
 72a:	0712                	slli	a4,a4,0x4
 72c:	973e                	add	a4,a4,a5
 72e:	fae689e3          	beq	a3,a4,6e0 <free+0x26>
  } else
    p->s.ptr = bp;
 732:	e394                	sd	a3,0(a5)
  freep = p;
 734:	00001717          	auipc	a4,0x1
 738:	8cf73623          	sd	a5,-1844(a4) # 1000 <freep>
}
 73c:	6422                	ld	s0,8(sp)
 73e:	0141                	addi	sp,sp,16
 740:	8082                	ret

0000000000000742 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 742:	7139                	addi	sp,sp,-64
 744:	fc06                	sd	ra,56(sp)
 746:	f822                	sd	s0,48(sp)
 748:	f426                	sd	s1,40(sp)
 74a:	f04a                	sd	s2,32(sp)
 74c:	ec4e                	sd	s3,24(sp)
 74e:	e852                	sd	s4,16(sp)
 750:	e456                	sd	s5,8(sp)
 752:	e05a                	sd	s6,0(sp)
 754:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 756:	02051493          	slli	s1,a0,0x20
 75a:	9081                	srli	s1,s1,0x20
 75c:	04bd                	addi	s1,s1,15
 75e:	8091                	srli	s1,s1,0x4
 760:	0014899b          	addiw	s3,s1,1
 764:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 766:	00001517          	auipc	a0,0x1
 76a:	89a53503          	ld	a0,-1894(a0) # 1000 <freep>
 76e:	c515                	beqz	a0,79a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 770:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 772:	4798                	lw	a4,8(a5)
 774:	02977f63          	bgeu	a4,s1,7b2 <malloc+0x70>
 778:	8a4e                	mv	s4,s3
 77a:	0009871b          	sext.w	a4,s3
 77e:	6685                	lui	a3,0x1
 780:	00d77363          	bgeu	a4,a3,786 <malloc+0x44>
 784:	6a05                	lui	s4,0x1
 786:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 78a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 78e:	00001917          	auipc	s2,0x1
 792:	87290913          	addi	s2,s2,-1934 # 1000 <freep>
  if(p == (char*)-1)
 796:	5afd                	li	s5,-1
 798:	a88d                	j	80a <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 79a:	00001797          	auipc	a5,0x1
 79e:	87678793          	addi	a5,a5,-1930 # 1010 <base>
 7a2:	00001717          	auipc	a4,0x1
 7a6:	84f73f23          	sd	a5,-1954(a4) # 1000 <freep>
 7aa:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7ac:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7b0:	b7e1                	j	778 <malloc+0x36>
      if(p->s.size == nunits)
 7b2:	02e48b63          	beq	s1,a4,7e8 <malloc+0xa6>
        p->s.size -= nunits;
 7b6:	4137073b          	subw	a4,a4,s3
 7ba:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7bc:	1702                	slli	a4,a4,0x20
 7be:	9301                	srli	a4,a4,0x20
 7c0:	0712                	slli	a4,a4,0x4
 7c2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7c4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7c8:	00001717          	auipc	a4,0x1
 7cc:	82a73c23          	sd	a0,-1992(a4) # 1000 <freep>
      return (void*)(p + 1);
 7d0:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7d4:	70e2                	ld	ra,56(sp)
 7d6:	7442                	ld	s0,48(sp)
 7d8:	74a2                	ld	s1,40(sp)
 7da:	7902                	ld	s2,32(sp)
 7dc:	69e2                	ld	s3,24(sp)
 7de:	6a42                	ld	s4,16(sp)
 7e0:	6aa2                	ld	s5,8(sp)
 7e2:	6b02                	ld	s6,0(sp)
 7e4:	6121                	addi	sp,sp,64
 7e6:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7e8:	6398                	ld	a4,0(a5)
 7ea:	e118                	sd	a4,0(a0)
 7ec:	bff1                	j	7c8 <malloc+0x86>
  hp->s.size = nu;
 7ee:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7f2:	0541                	addi	a0,a0,16
 7f4:	00000097          	auipc	ra,0x0
 7f8:	ec6080e7          	jalr	-314(ra) # 6ba <free>
  return freep;
 7fc:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 800:	d971                	beqz	a0,7d4 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 802:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 804:	4798                	lw	a4,8(a5)
 806:	fa9776e3          	bgeu	a4,s1,7b2 <malloc+0x70>
    if(p == freep)
 80a:	00093703          	ld	a4,0(s2)
 80e:	853e                	mv	a0,a5
 810:	fef719e3          	bne	a4,a5,802 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 814:	8552                	mv	a0,s4
 816:	00000097          	auipc	ra,0x0
 81a:	b56080e7          	jalr	-1194(ra) # 36c <sbrk>
  if(p == (char*)-1)
 81e:	fd5518e3          	bne	a0,s5,7ee <malloc+0xac>
        return 0;
 822:	4501                	li	a0,0
 824:	bf45                	j	7d4 <malloc+0x92>
