
user/_policy:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user/user.h"
#include "kernel/fs.h"

// int change_policy(int p);

int main(int argc, char *argv[]) {
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
    if (argc !=2){
   c:	4789                	li	a5,2
   e:	04f51263          	bne	a0,a5,52 <main+0x52>
  12:	84ae                	mv	s1,a1
        printf("no argument inserted\n");
        return -1;
    }
    
    int i=set_policy(atoi(argv[1]));
  14:	6588                	ld	a0,8(a1)
  16:	00000097          	auipc	ra,0x0
  1a:	1e4080e7          	jalr	484(ra) # 1fa <atoi>
  1e:	00000097          	auipc	ra,0x0
  22:	398080e7          	jalr	920(ra) # 3b6 <set_policy>
  26:	892a                	mv	s2,a0
    printf("policy succecfuly changed to:%d\n",atoi(argv[1]));
  28:	6488                	ld	a0,8(s1)
  2a:	00000097          	auipc	ra,0x0
  2e:	1d0080e7          	jalr	464(ra) # 1fa <atoi>
  32:	85aa                	mv	a1,a0
  34:	00001517          	auipc	a0,0x1
  38:	82450513          	addi	a0,a0,-2012 # 858 <malloc+0x104>
  3c:	00000097          	auipc	ra,0x0
  40:	65a080e7          	jalr	1626(ra) # 696 <printf>
    return i;
    
  44:	854a                	mv	a0,s2
  46:	60e2                	ld	ra,24(sp)
  48:	6442                	ld	s0,16(sp)
  4a:	64a2                	ld	s1,8(sp)
  4c:	6902                	ld	s2,0(sp)
  4e:	6105                	addi	sp,sp,32
  50:	8082                	ret
        printf("no argument inserted\n");
  52:	00000517          	auipc	a0,0x0
  56:	7ee50513          	addi	a0,a0,2030 # 840 <malloc+0xec>
  5a:	00000097          	auipc	ra,0x0
  5e:	63c080e7          	jalr	1596(ra) # 696 <printf>
        return -1;
  62:	597d                	li	s2,-1
  64:	b7c5                	j	44 <main+0x44>

0000000000000066 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  66:	1141                	addi	sp,sp,-16
  68:	e406                	sd	ra,8(sp)
  6a:	e022                	sd	s0,0(sp)
  6c:	0800                	addi	s0,sp,16
  extern int main();
  main();
  6e:	00000097          	auipc	ra,0x0
  72:	f92080e7          	jalr	-110(ra) # 0 <main>
  exit(0,"");
  76:	00001597          	auipc	a1,0x1
  7a:	80258593          	addi	a1,a1,-2046 # 878 <malloc+0x124>
  7e:	4501                	li	a0,0
  80:	00000097          	auipc	ra,0x0
  84:	276080e7          	jalr	630(ra) # 2f6 <exit>

0000000000000088 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  88:	1141                	addi	sp,sp,-16
  8a:	e422                	sd	s0,8(sp)
  8c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  8e:	87aa                	mv	a5,a0
  90:	0585                	addi	a1,a1,1
  92:	0785                	addi	a5,a5,1
  94:	fff5c703          	lbu	a4,-1(a1)
  98:	fee78fa3          	sb	a4,-1(a5)
  9c:	fb75                	bnez	a4,90 <strcpy+0x8>
    ;
  return os;
}
  9e:	6422                	ld	s0,8(sp)
  a0:	0141                	addi	sp,sp,16
  a2:	8082                	ret

00000000000000a4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  a4:	1141                	addi	sp,sp,-16
  a6:	e422                	sd	s0,8(sp)
  a8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  aa:	00054783          	lbu	a5,0(a0)
  ae:	cb91                	beqz	a5,c2 <strcmp+0x1e>
  b0:	0005c703          	lbu	a4,0(a1)
  b4:	00f71763          	bne	a4,a5,c2 <strcmp+0x1e>
    p++, q++;
  b8:	0505                	addi	a0,a0,1
  ba:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  bc:	00054783          	lbu	a5,0(a0)
  c0:	fbe5                	bnez	a5,b0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  c2:	0005c503          	lbu	a0,0(a1)
}
  c6:	40a7853b          	subw	a0,a5,a0
  ca:	6422                	ld	s0,8(sp)
  cc:	0141                	addi	sp,sp,16
  ce:	8082                	ret

00000000000000d0 <strlen>:

uint
strlen(const char *s)
{
  d0:	1141                	addi	sp,sp,-16
  d2:	e422                	sd	s0,8(sp)
  d4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  d6:	00054783          	lbu	a5,0(a0)
  da:	cf91                	beqz	a5,f6 <strlen+0x26>
  dc:	0505                	addi	a0,a0,1
  de:	87aa                	mv	a5,a0
  e0:	4685                	li	a3,1
  e2:	9e89                	subw	a3,a3,a0
  e4:	00f6853b          	addw	a0,a3,a5
  e8:	0785                	addi	a5,a5,1
  ea:	fff7c703          	lbu	a4,-1(a5)
  ee:	fb7d                	bnez	a4,e4 <strlen+0x14>
    ;
  return n;
}
  f0:	6422                	ld	s0,8(sp)
  f2:	0141                	addi	sp,sp,16
  f4:	8082                	ret
  for(n = 0; s[n]; n++)
  f6:	4501                	li	a0,0
  f8:	bfe5                	j	f0 <strlen+0x20>

00000000000000fa <memset>:

void*
memset(void *dst, int c, uint n)
{
  fa:	1141                	addi	sp,sp,-16
  fc:	e422                	sd	s0,8(sp)
  fe:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 100:	ca19                	beqz	a2,116 <memset+0x1c>
 102:	87aa                	mv	a5,a0
 104:	1602                	slli	a2,a2,0x20
 106:	9201                	srli	a2,a2,0x20
 108:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 10c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 110:	0785                	addi	a5,a5,1
 112:	fee79de3          	bne	a5,a4,10c <memset+0x12>
  }
  return dst;
}
 116:	6422                	ld	s0,8(sp)
 118:	0141                	addi	sp,sp,16
 11a:	8082                	ret

000000000000011c <strchr>:

char*
strchr(const char *s, char c)
{
 11c:	1141                	addi	sp,sp,-16
 11e:	e422                	sd	s0,8(sp)
 120:	0800                	addi	s0,sp,16
  for(; *s; s++)
 122:	00054783          	lbu	a5,0(a0)
 126:	cb99                	beqz	a5,13c <strchr+0x20>
    if(*s == c)
 128:	00f58763          	beq	a1,a5,136 <strchr+0x1a>
  for(; *s; s++)
 12c:	0505                	addi	a0,a0,1
 12e:	00054783          	lbu	a5,0(a0)
 132:	fbfd                	bnez	a5,128 <strchr+0xc>
      return (char*)s;
  return 0;
 134:	4501                	li	a0,0
}
 136:	6422                	ld	s0,8(sp)
 138:	0141                	addi	sp,sp,16
 13a:	8082                	ret
  return 0;
 13c:	4501                	li	a0,0
 13e:	bfe5                	j	136 <strchr+0x1a>

0000000000000140 <gets>:

char*
gets(char *buf, int max)
{
 140:	711d                	addi	sp,sp,-96
 142:	ec86                	sd	ra,88(sp)
 144:	e8a2                	sd	s0,80(sp)
 146:	e4a6                	sd	s1,72(sp)
 148:	e0ca                	sd	s2,64(sp)
 14a:	fc4e                	sd	s3,56(sp)
 14c:	f852                	sd	s4,48(sp)
 14e:	f456                	sd	s5,40(sp)
 150:	f05a                	sd	s6,32(sp)
 152:	ec5e                	sd	s7,24(sp)
 154:	1080                	addi	s0,sp,96
 156:	8baa                	mv	s7,a0
 158:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 15a:	892a                	mv	s2,a0
 15c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 15e:	4aa9                	li	s5,10
 160:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 162:	89a6                	mv	s3,s1
 164:	2485                	addiw	s1,s1,1
 166:	0344d863          	bge	s1,s4,196 <gets+0x56>
    cc = read(0, &c, 1);
 16a:	4605                	li	a2,1
 16c:	faf40593          	addi	a1,s0,-81
 170:	4501                	li	a0,0
 172:	00000097          	auipc	ra,0x0
 176:	19c080e7          	jalr	412(ra) # 30e <read>
    if(cc < 1)
 17a:	00a05e63          	blez	a0,196 <gets+0x56>
    buf[i++] = c;
 17e:	faf44783          	lbu	a5,-81(s0)
 182:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 186:	01578763          	beq	a5,s5,194 <gets+0x54>
 18a:	0905                	addi	s2,s2,1
 18c:	fd679be3          	bne	a5,s6,162 <gets+0x22>
  for(i=0; i+1 < max; ){
 190:	89a6                	mv	s3,s1
 192:	a011                	j	196 <gets+0x56>
 194:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 196:	99de                	add	s3,s3,s7
 198:	00098023          	sb	zero,0(s3)
  return buf;
}
 19c:	855e                	mv	a0,s7
 19e:	60e6                	ld	ra,88(sp)
 1a0:	6446                	ld	s0,80(sp)
 1a2:	64a6                	ld	s1,72(sp)
 1a4:	6906                	ld	s2,64(sp)
 1a6:	79e2                	ld	s3,56(sp)
 1a8:	7a42                	ld	s4,48(sp)
 1aa:	7aa2                	ld	s5,40(sp)
 1ac:	7b02                	ld	s6,32(sp)
 1ae:	6be2                	ld	s7,24(sp)
 1b0:	6125                	addi	sp,sp,96
 1b2:	8082                	ret

00000000000001b4 <stat>:

int
stat(const char *n, struct stat *st)
{
 1b4:	1101                	addi	sp,sp,-32
 1b6:	ec06                	sd	ra,24(sp)
 1b8:	e822                	sd	s0,16(sp)
 1ba:	e426                	sd	s1,8(sp)
 1bc:	e04a                	sd	s2,0(sp)
 1be:	1000                	addi	s0,sp,32
 1c0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1c2:	4581                	li	a1,0
 1c4:	00000097          	auipc	ra,0x0
 1c8:	172080e7          	jalr	370(ra) # 336 <open>
  if(fd < 0)
 1cc:	02054563          	bltz	a0,1f6 <stat+0x42>
 1d0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1d2:	85ca                	mv	a1,s2
 1d4:	00000097          	auipc	ra,0x0
 1d8:	17a080e7          	jalr	378(ra) # 34e <fstat>
 1dc:	892a                	mv	s2,a0
  close(fd);
 1de:	8526                	mv	a0,s1
 1e0:	00000097          	auipc	ra,0x0
 1e4:	13e080e7          	jalr	318(ra) # 31e <close>
  return r;
}
 1e8:	854a                	mv	a0,s2
 1ea:	60e2                	ld	ra,24(sp)
 1ec:	6442                	ld	s0,16(sp)
 1ee:	64a2                	ld	s1,8(sp)
 1f0:	6902                	ld	s2,0(sp)
 1f2:	6105                	addi	sp,sp,32
 1f4:	8082                	ret
    return -1;
 1f6:	597d                	li	s2,-1
 1f8:	bfc5                	j	1e8 <stat+0x34>

00000000000001fa <atoi>:

int
atoi(const char *s)
{
 1fa:	1141                	addi	sp,sp,-16
 1fc:	e422                	sd	s0,8(sp)
 1fe:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 200:	00054603          	lbu	a2,0(a0)
 204:	fd06079b          	addiw	a5,a2,-48
 208:	0ff7f793          	andi	a5,a5,255
 20c:	4725                	li	a4,9
 20e:	02f76963          	bltu	a4,a5,240 <atoi+0x46>
 212:	86aa                	mv	a3,a0
  n = 0;
 214:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 216:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 218:	0685                	addi	a3,a3,1
 21a:	0025179b          	slliw	a5,a0,0x2
 21e:	9fa9                	addw	a5,a5,a0
 220:	0017979b          	slliw	a5,a5,0x1
 224:	9fb1                	addw	a5,a5,a2
 226:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 22a:	0006c603          	lbu	a2,0(a3)
 22e:	fd06071b          	addiw	a4,a2,-48
 232:	0ff77713          	andi	a4,a4,255
 236:	fee5f1e3          	bgeu	a1,a4,218 <atoi+0x1e>
  return n;
}
 23a:	6422                	ld	s0,8(sp)
 23c:	0141                	addi	sp,sp,16
 23e:	8082                	ret
  n = 0;
 240:	4501                	li	a0,0
 242:	bfe5                	j	23a <atoi+0x40>

0000000000000244 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 244:	1141                	addi	sp,sp,-16
 246:	e422                	sd	s0,8(sp)
 248:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 24a:	02b57463          	bgeu	a0,a1,272 <memmove+0x2e>
    while(n-- > 0)
 24e:	00c05f63          	blez	a2,26c <memmove+0x28>
 252:	1602                	slli	a2,a2,0x20
 254:	9201                	srli	a2,a2,0x20
 256:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 25a:	872a                	mv	a4,a0
      *dst++ = *src++;
 25c:	0585                	addi	a1,a1,1
 25e:	0705                	addi	a4,a4,1
 260:	fff5c683          	lbu	a3,-1(a1)
 264:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 268:	fee79ae3          	bne	a5,a4,25c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 26c:	6422                	ld	s0,8(sp)
 26e:	0141                	addi	sp,sp,16
 270:	8082                	ret
    dst += n;
 272:	00c50733          	add	a4,a0,a2
    src += n;
 276:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 278:	fec05ae3          	blez	a2,26c <memmove+0x28>
 27c:	fff6079b          	addiw	a5,a2,-1
 280:	1782                	slli	a5,a5,0x20
 282:	9381                	srli	a5,a5,0x20
 284:	fff7c793          	not	a5,a5
 288:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 28a:	15fd                	addi	a1,a1,-1
 28c:	177d                	addi	a4,a4,-1
 28e:	0005c683          	lbu	a3,0(a1)
 292:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 296:	fee79ae3          	bne	a5,a4,28a <memmove+0x46>
 29a:	bfc9                	j	26c <memmove+0x28>

000000000000029c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 29c:	1141                	addi	sp,sp,-16
 29e:	e422                	sd	s0,8(sp)
 2a0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2a2:	ca05                	beqz	a2,2d2 <memcmp+0x36>
 2a4:	fff6069b          	addiw	a3,a2,-1
 2a8:	1682                	slli	a3,a3,0x20
 2aa:	9281                	srli	a3,a3,0x20
 2ac:	0685                	addi	a3,a3,1
 2ae:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2b0:	00054783          	lbu	a5,0(a0)
 2b4:	0005c703          	lbu	a4,0(a1)
 2b8:	00e79863          	bne	a5,a4,2c8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2bc:	0505                	addi	a0,a0,1
    p2++;
 2be:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2c0:	fed518e3          	bne	a0,a3,2b0 <memcmp+0x14>
  }
  return 0;
 2c4:	4501                	li	a0,0
 2c6:	a019                	j	2cc <memcmp+0x30>
      return *p1 - *p2;
 2c8:	40e7853b          	subw	a0,a5,a4
}
 2cc:	6422                	ld	s0,8(sp)
 2ce:	0141                	addi	sp,sp,16
 2d0:	8082                	ret
  return 0;
 2d2:	4501                	li	a0,0
 2d4:	bfe5                	j	2cc <memcmp+0x30>

00000000000002d6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2d6:	1141                	addi	sp,sp,-16
 2d8:	e406                	sd	ra,8(sp)
 2da:	e022                	sd	s0,0(sp)
 2dc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2de:	00000097          	auipc	ra,0x0
 2e2:	f66080e7          	jalr	-154(ra) # 244 <memmove>
}
 2e6:	60a2                	ld	ra,8(sp)
 2e8:	6402                	ld	s0,0(sp)
 2ea:	0141                	addi	sp,sp,16
 2ec:	8082                	ret

00000000000002ee <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2ee:	4885                	li	a7,1
 ecall
 2f0:	00000073          	ecall
 ret
 2f4:	8082                	ret

00000000000002f6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2f6:	4889                	li	a7,2
 ecall
 2f8:	00000073          	ecall
 ret
 2fc:	8082                	ret

00000000000002fe <wait>:
.global wait
wait:
 li a7, SYS_wait
 2fe:	488d                	li	a7,3
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 306:	4891                	li	a7,4
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <read>:
.global read
read:
 li a7, SYS_read
 30e:	4895                	li	a7,5
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <write>:
.global write
write:
 li a7, SYS_write
 316:	48c1                	li	a7,16
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <close>:
.global close
close:
 li a7, SYS_close
 31e:	48d5                	li	a7,21
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <kill>:
.global kill
kill:
 li a7, SYS_kill
 326:	4899                	li	a7,6
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <exec>:
.global exec
exec:
 li a7, SYS_exec
 32e:	489d                	li	a7,7
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <open>:
.global open
open:
 li a7, SYS_open
 336:	48bd                	li	a7,15
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 33e:	48c5                	li	a7,17
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 346:	48c9                	li	a7,18
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 34e:	48a1                	li	a7,8
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <link>:
.global link
link:
 li a7, SYS_link
 356:	48cd                	li	a7,19
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 35e:	48d1                	li	a7,20
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 366:	48a5                	li	a7,9
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <dup>:
.global dup
dup:
 li a7, SYS_dup
 36e:	48a9                	li	a7,10
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 376:	48ad                	li	a7,11
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 37e:	48b1                	li	a7,12
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 386:	48b5                	li	a7,13
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 38e:	48b9                	li	a7,14
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <memsize>:
.global memsize
memsize:
 li a7, SYS_memsize
 396:	48d9                	li	a7,22
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <set_ps_priority>:
.global set_ps_priority
set_ps_priority:
 li a7, SYS_set_ps_priority
 39e:	48dd                	li	a7,23
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <set_cfs_priority>:
.global set_cfs_priority
set_cfs_priority:
 li a7, SYS_set_cfs_priority
 3a6:	48e1                	li	a7,24
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <get_cfs_stats>:
.global get_cfs_stats
get_cfs_stats:
 li a7, SYS_get_cfs_stats
 3ae:	48e5                	li	a7,25
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <set_policy>:
.global set_policy
set_policy:
 li a7, SYS_set_policy
 3b6:	48e9                	li	a7,26
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3be:	1101                	addi	sp,sp,-32
 3c0:	ec06                	sd	ra,24(sp)
 3c2:	e822                	sd	s0,16(sp)
 3c4:	1000                	addi	s0,sp,32
 3c6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3ca:	4605                	li	a2,1
 3cc:	fef40593          	addi	a1,s0,-17
 3d0:	00000097          	auipc	ra,0x0
 3d4:	f46080e7          	jalr	-186(ra) # 316 <write>
}
 3d8:	60e2                	ld	ra,24(sp)
 3da:	6442                	ld	s0,16(sp)
 3dc:	6105                	addi	sp,sp,32
 3de:	8082                	ret

00000000000003e0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3e0:	7139                	addi	sp,sp,-64
 3e2:	fc06                	sd	ra,56(sp)
 3e4:	f822                	sd	s0,48(sp)
 3e6:	f426                	sd	s1,40(sp)
 3e8:	f04a                	sd	s2,32(sp)
 3ea:	ec4e                	sd	s3,24(sp)
 3ec:	0080                	addi	s0,sp,64
 3ee:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3f0:	c299                	beqz	a3,3f6 <printint+0x16>
 3f2:	0805c863          	bltz	a1,482 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3f6:	2581                	sext.w	a1,a1
  neg = 0;
 3f8:	4881                	li	a7,0
 3fa:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3fe:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 400:	2601                	sext.w	a2,a2
 402:	00000517          	auipc	a0,0x0
 406:	48650513          	addi	a0,a0,1158 # 888 <digits>
 40a:	883a                	mv	a6,a4
 40c:	2705                	addiw	a4,a4,1
 40e:	02c5f7bb          	remuw	a5,a1,a2
 412:	1782                	slli	a5,a5,0x20
 414:	9381                	srli	a5,a5,0x20
 416:	97aa                	add	a5,a5,a0
 418:	0007c783          	lbu	a5,0(a5)
 41c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 420:	0005879b          	sext.w	a5,a1
 424:	02c5d5bb          	divuw	a1,a1,a2
 428:	0685                	addi	a3,a3,1
 42a:	fec7f0e3          	bgeu	a5,a2,40a <printint+0x2a>
  if(neg)
 42e:	00088b63          	beqz	a7,444 <printint+0x64>
    buf[i++] = '-';
 432:	fd040793          	addi	a5,s0,-48
 436:	973e                	add	a4,a4,a5
 438:	02d00793          	li	a5,45
 43c:	fef70823          	sb	a5,-16(a4)
 440:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 444:	02e05863          	blez	a4,474 <printint+0x94>
 448:	fc040793          	addi	a5,s0,-64
 44c:	00e78933          	add	s2,a5,a4
 450:	fff78993          	addi	s3,a5,-1
 454:	99ba                	add	s3,s3,a4
 456:	377d                	addiw	a4,a4,-1
 458:	1702                	slli	a4,a4,0x20
 45a:	9301                	srli	a4,a4,0x20
 45c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 460:	fff94583          	lbu	a1,-1(s2)
 464:	8526                	mv	a0,s1
 466:	00000097          	auipc	ra,0x0
 46a:	f58080e7          	jalr	-168(ra) # 3be <putc>
  while(--i >= 0)
 46e:	197d                	addi	s2,s2,-1
 470:	ff3918e3          	bne	s2,s3,460 <printint+0x80>
}
 474:	70e2                	ld	ra,56(sp)
 476:	7442                	ld	s0,48(sp)
 478:	74a2                	ld	s1,40(sp)
 47a:	7902                	ld	s2,32(sp)
 47c:	69e2                	ld	s3,24(sp)
 47e:	6121                	addi	sp,sp,64
 480:	8082                	ret
    x = -xx;
 482:	40b005bb          	negw	a1,a1
    neg = 1;
 486:	4885                	li	a7,1
    x = -xx;
 488:	bf8d                	j	3fa <printint+0x1a>

000000000000048a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 48a:	7119                	addi	sp,sp,-128
 48c:	fc86                	sd	ra,120(sp)
 48e:	f8a2                	sd	s0,112(sp)
 490:	f4a6                	sd	s1,104(sp)
 492:	f0ca                	sd	s2,96(sp)
 494:	ecce                	sd	s3,88(sp)
 496:	e8d2                	sd	s4,80(sp)
 498:	e4d6                	sd	s5,72(sp)
 49a:	e0da                	sd	s6,64(sp)
 49c:	fc5e                	sd	s7,56(sp)
 49e:	f862                	sd	s8,48(sp)
 4a0:	f466                	sd	s9,40(sp)
 4a2:	f06a                	sd	s10,32(sp)
 4a4:	ec6e                	sd	s11,24(sp)
 4a6:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4a8:	0005c903          	lbu	s2,0(a1)
 4ac:	18090f63          	beqz	s2,64a <vprintf+0x1c0>
 4b0:	8aaa                	mv	s5,a0
 4b2:	8b32                	mv	s6,a2
 4b4:	00158493          	addi	s1,a1,1
  state = 0;
 4b8:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4ba:	02500a13          	li	s4,37
      if(c == 'd'){
 4be:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 4c2:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 4c6:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 4ca:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4ce:	00000b97          	auipc	s7,0x0
 4d2:	3bab8b93          	addi	s7,s7,954 # 888 <digits>
 4d6:	a839                	j	4f4 <vprintf+0x6a>
        putc(fd, c);
 4d8:	85ca                	mv	a1,s2
 4da:	8556                	mv	a0,s5
 4dc:	00000097          	auipc	ra,0x0
 4e0:	ee2080e7          	jalr	-286(ra) # 3be <putc>
 4e4:	a019                	j	4ea <vprintf+0x60>
    } else if(state == '%'){
 4e6:	01498f63          	beq	s3,s4,504 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4ea:	0485                	addi	s1,s1,1
 4ec:	fff4c903          	lbu	s2,-1(s1)
 4f0:	14090d63          	beqz	s2,64a <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 4f4:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4f8:	fe0997e3          	bnez	s3,4e6 <vprintf+0x5c>
      if(c == '%'){
 4fc:	fd479ee3          	bne	a5,s4,4d8 <vprintf+0x4e>
        state = '%';
 500:	89be                	mv	s3,a5
 502:	b7e5                	j	4ea <vprintf+0x60>
      if(c == 'd'){
 504:	05878063          	beq	a5,s8,544 <vprintf+0xba>
      } else if(c == 'l') {
 508:	05978c63          	beq	a5,s9,560 <vprintf+0xd6>
      } else if(c == 'x') {
 50c:	07a78863          	beq	a5,s10,57c <vprintf+0xf2>
      } else if(c == 'p') {
 510:	09b78463          	beq	a5,s11,598 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 514:	07300713          	li	a4,115
 518:	0ce78663          	beq	a5,a4,5e4 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 51c:	06300713          	li	a4,99
 520:	0ee78e63          	beq	a5,a4,61c <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 524:	11478863          	beq	a5,s4,634 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 528:	85d2                	mv	a1,s4
 52a:	8556                	mv	a0,s5
 52c:	00000097          	auipc	ra,0x0
 530:	e92080e7          	jalr	-366(ra) # 3be <putc>
        putc(fd, c);
 534:	85ca                	mv	a1,s2
 536:	8556                	mv	a0,s5
 538:	00000097          	auipc	ra,0x0
 53c:	e86080e7          	jalr	-378(ra) # 3be <putc>
      }
      state = 0;
 540:	4981                	li	s3,0
 542:	b765                	j	4ea <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 544:	008b0913          	addi	s2,s6,8
 548:	4685                	li	a3,1
 54a:	4629                	li	a2,10
 54c:	000b2583          	lw	a1,0(s6)
 550:	8556                	mv	a0,s5
 552:	00000097          	auipc	ra,0x0
 556:	e8e080e7          	jalr	-370(ra) # 3e0 <printint>
 55a:	8b4a                	mv	s6,s2
      state = 0;
 55c:	4981                	li	s3,0
 55e:	b771                	j	4ea <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 560:	008b0913          	addi	s2,s6,8
 564:	4681                	li	a3,0
 566:	4629                	li	a2,10
 568:	000b2583          	lw	a1,0(s6)
 56c:	8556                	mv	a0,s5
 56e:	00000097          	auipc	ra,0x0
 572:	e72080e7          	jalr	-398(ra) # 3e0 <printint>
 576:	8b4a                	mv	s6,s2
      state = 0;
 578:	4981                	li	s3,0
 57a:	bf85                	j	4ea <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 57c:	008b0913          	addi	s2,s6,8
 580:	4681                	li	a3,0
 582:	4641                	li	a2,16
 584:	000b2583          	lw	a1,0(s6)
 588:	8556                	mv	a0,s5
 58a:	00000097          	auipc	ra,0x0
 58e:	e56080e7          	jalr	-426(ra) # 3e0 <printint>
 592:	8b4a                	mv	s6,s2
      state = 0;
 594:	4981                	li	s3,0
 596:	bf91                	j	4ea <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 598:	008b0793          	addi	a5,s6,8
 59c:	f8f43423          	sd	a5,-120(s0)
 5a0:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 5a4:	03000593          	li	a1,48
 5a8:	8556                	mv	a0,s5
 5aa:	00000097          	auipc	ra,0x0
 5ae:	e14080e7          	jalr	-492(ra) # 3be <putc>
  putc(fd, 'x');
 5b2:	85ea                	mv	a1,s10
 5b4:	8556                	mv	a0,s5
 5b6:	00000097          	auipc	ra,0x0
 5ba:	e08080e7          	jalr	-504(ra) # 3be <putc>
 5be:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5c0:	03c9d793          	srli	a5,s3,0x3c
 5c4:	97de                	add	a5,a5,s7
 5c6:	0007c583          	lbu	a1,0(a5)
 5ca:	8556                	mv	a0,s5
 5cc:	00000097          	auipc	ra,0x0
 5d0:	df2080e7          	jalr	-526(ra) # 3be <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5d4:	0992                	slli	s3,s3,0x4
 5d6:	397d                	addiw	s2,s2,-1
 5d8:	fe0914e3          	bnez	s2,5c0 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 5dc:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 5e0:	4981                	li	s3,0
 5e2:	b721                	j	4ea <vprintf+0x60>
        s = va_arg(ap, char*);
 5e4:	008b0993          	addi	s3,s6,8
 5e8:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 5ec:	02090163          	beqz	s2,60e <vprintf+0x184>
        while(*s != 0){
 5f0:	00094583          	lbu	a1,0(s2)
 5f4:	c9a1                	beqz	a1,644 <vprintf+0x1ba>
          putc(fd, *s);
 5f6:	8556                	mv	a0,s5
 5f8:	00000097          	auipc	ra,0x0
 5fc:	dc6080e7          	jalr	-570(ra) # 3be <putc>
          s++;
 600:	0905                	addi	s2,s2,1
        while(*s != 0){
 602:	00094583          	lbu	a1,0(s2)
 606:	f9e5                	bnez	a1,5f6 <vprintf+0x16c>
        s = va_arg(ap, char*);
 608:	8b4e                	mv	s6,s3
      state = 0;
 60a:	4981                	li	s3,0
 60c:	bdf9                	j	4ea <vprintf+0x60>
          s = "(null)";
 60e:	00000917          	auipc	s2,0x0
 612:	27290913          	addi	s2,s2,626 # 880 <malloc+0x12c>
        while(*s != 0){
 616:	02800593          	li	a1,40
 61a:	bff1                	j	5f6 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 61c:	008b0913          	addi	s2,s6,8
 620:	000b4583          	lbu	a1,0(s6)
 624:	8556                	mv	a0,s5
 626:	00000097          	auipc	ra,0x0
 62a:	d98080e7          	jalr	-616(ra) # 3be <putc>
 62e:	8b4a                	mv	s6,s2
      state = 0;
 630:	4981                	li	s3,0
 632:	bd65                	j	4ea <vprintf+0x60>
        putc(fd, c);
 634:	85d2                	mv	a1,s4
 636:	8556                	mv	a0,s5
 638:	00000097          	auipc	ra,0x0
 63c:	d86080e7          	jalr	-634(ra) # 3be <putc>
      state = 0;
 640:	4981                	li	s3,0
 642:	b565                	j	4ea <vprintf+0x60>
        s = va_arg(ap, char*);
 644:	8b4e                	mv	s6,s3
      state = 0;
 646:	4981                	li	s3,0
 648:	b54d                	j	4ea <vprintf+0x60>
    }
  }
}
 64a:	70e6                	ld	ra,120(sp)
 64c:	7446                	ld	s0,112(sp)
 64e:	74a6                	ld	s1,104(sp)
 650:	7906                	ld	s2,96(sp)
 652:	69e6                	ld	s3,88(sp)
 654:	6a46                	ld	s4,80(sp)
 656:	6aa6                	ld	s5,72(sp)
 658:	6b06                	ld	s6,64(sp)
 65a:	7be2                	ld	s7,56(sp)
 65c:	7c42                	ld	s8,48(sp)
 65e:	7ca2                	ld	s9,40(sp)
 660:	7d02                	ld	s10,32(sp)
 662:	6de2                	ld	s11,24(sp)
 664:	6109                	addi	sp,sp,128
 666:	8082                	ret

0000000000000668 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 668:	715d                	addi	sp,sp,-80
 66a:	ec06                	sd	ra,24(sp)
 66c:	e822                	sd	s0,16(sp)
 66e:	1000                	addi	s0,sp,32
 670:	e010                	sd	a2,0(s0)
 672:	e414                	sd	a3,8(s0)
 674:	e818                	sd	a4,16(s0)
 676:	ec1c                	sd	a5,24(s0)
 678:	03043023          	sd	a6,32(s0)
 67c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 680:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 684:	8622                	mv	a2,s0
 686:	00000097          	auipc	ra,0x0
 68a:	e04080e7          	jalr	-508(ra) # 48a <vprintf>
}
 68e:	60e2                	ld	ra,24(sp)
 690:	6442                	ld	s0,16(sp)
 692:	6161                	addi	sp,sp,80
 694:	8082                	ret

0000000000000696 <printf>:

void
printf(const char *fmt, ...)
{
 696:	711d                	addi	sp,sp,-96
 698:	ec06                	sd	ra,24(sp)
 69a:	e822                	sd	s0,16(sp)
 69c:	1000                	addi	s0,sp,32
 69e:	e40c                	sd	a1,8(s0)
 6a0:	e810                	sd	a2,16(s0)
 6a2:	ec14                	sd	a3,24(s0)
 6a4:	f018                	sd	a4,32(s0)
 6a6:	f41c                	sd	a5,40(s0)
 6a8:	03043823          	sd	a6,48(s0)
 6ac:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6b0:	00840613          	addi	a2,s0,8
 6b4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6b8:	85aa                	mv	a1,a0
 6ba:	4505                	li	a0,1
 6bc:	00000097          	auipc	ra,0x0
 6c0:	dce080e7          	jalr	-562(ra) # 48a <vprintf>
}
 6c4:	60e2                	ld	ra,24(sp)
 6c6:	6442                	ld	s0,16(sp)
 6c8:	6125                	addi	sp,sp,96
 6ca:	8082                	ret

00000000000006cc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6cc:	1141                	addi	sp,sp,-16
 6ce:	e422                	sd	s0,8(sp)
 6d0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6d2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6d6:	00001797          	auipc	a5,0x1
 6da:	92a7b783          	ld	a5,-1750(a5) # 1000 <freep>
 6de:	a805                	j	70e <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6e0:	4618                	lw	a4,8(a2)
 6e2:	9db9                	addw	a1,a1,a4
 6e4:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6e8:	6398                	ld	a4,0(a5)
 6ea:	6318                	ld	a4,0(a4)
 6ec:	fee53823          	sd	a4,-16(a0)
 6f0:	a091                	j	734 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6f2:	ff852703          	lw	a4,-8(a0)
 6f6:	9e39                	addw	a2,a2,a4
 6f8:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 6fa:	ff053703          	ld	a4,-16(a0)
 6fe:	e398                	sd	a4,0(a5)
 700:	a099                	j	746 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 702:	6398                	ld	a4,0(a5)
 704:	00e7e463          	bltu	a5,a4,70c <free+0x40>
 708:	00e6ea63          	bltu	a3,a4,71c <free+0x50>
{
 70c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 70e:	fed7fae3          	bgeu	a5,a3,702 <free+0x36>
 712:	6398                	ld	a4,0(a5)
 714:	00e6e463          	bltu	a3,a4,71c <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 718:	fee7eae3          	bltu	a5,a4,70c <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 71c:	ff852583          	lw	a1,-8(a0)
 720:	6390                	ld	a2,0(a5)
 722:	02059713          	slli	a4,a1,0x20
 726:	9301                	srli	a4,a4,0x20
 728:	0712                	slli	a4,a4,0x4
 72a:	9736                	add	a4,a4,a3
 72c:	fae60ae3          	beq	a2,a4,6e0 <free+0x14>
    bp->s.ptr = p->s.ptr;
 730:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 734:	4790                	lw	a2,8(a5)
 736:	02061713          	slli	a4,a2,0x20
 73a:	9301                	srli	a4,a4,0x20
 73c:	0712                	slli	a4,a4,0x4
 73e:	973e                	add	a4,a4,a5
 740:	fae689e3          	beq	a3,a4,6f2 <free+0x26>
  } else
    p->s.ptr = bp;
 744:	e394                	sd	a3,0(a5)
  freep = p;
 746:	00001717          	auipc	a4,0x1
 74a:	8af73d23          	sd	a5,-1862(a4) # 1000 <freep>
}
 74e:	6422                	ld	s0,8(sp)
 750:	0141                	addi	sp,sp,16
 752:	8082                	ret

0000000000000754 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 754:	7139                	addi	sp,sp,-64
 756:	fc06                	sd	ra,56(sp)
 758:	f822                	sd	s0,48(sp)
 75a:	f426                	sd	s1,40(sp)
 75c:	f04a                	sd	s2,32(sp)
 75e:	ec4e                	sd	s3,24(sp)
 760:	e852                	sd	s4,16(sp)
 762:	e456                	sd	s5,8(sp)
 764:	e05a                	sd	s6,0(sp)
 766:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 768:	02051493          	slli	s1,a0,0x20
 76c:	9081                	srli	s1,s1,0x20
 76e:	04bd                	addi	s1,s1,15
 770:	8091                	srli	s1,s1,0x4
 772:	0014899b          	addiw	s3,s1,1
 776:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 778:	00001517          	auipc	a0,0x1
 77c:	88853503          	ld	a0,-1912(a0) # 1000 <freep>
 780:	c515                	beqz	a0,7ac <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 782:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 784:	4798                	lw	a4,8(a5)
 786:	02977f63          	bgeu	a4,s1,7c4 <malloc+0x70>
 78a:	8a4e                	mv	s4,s3
 78c:	0009871b          	sext.w	a4,s3
 790:	6685                	lui	a3,0x1
 792:	00d77363          	bgeu	a4,a3,798 <malloc+0x44>
 796:	6a05                	lui	s4,0x1
 798:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 79c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7a0:	00001917          	auipc	s2,0x1
 7a4:	86090913          	addi	s2,s2,-1952 # 1000 <freep>
  if(p == (char*)-1)
 7a8:	5afd                	li	s5,-1
 7aa:	a88d                	j	81c <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 7ac:	00001797          	auipc	a5,0x1
 7b0:	86478793          	addi	a5,a5,-1948 # 1010 <base>
 7b4:	00001717          	auipc	a4,0x1
 7b8:	84f73623          	sd	a5,-1972(a4) # 1000 <freep>
 7bc:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7be:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7c2:	b7e1                	j	78a <malloc+0x36>
      if(p->s.size == nunits)
 7c4:	02e48b63          	beq	s1,a4,7fa <malloc+0xa6>
        p->s.size -= nunits;
 7c8:	4137073b          	subw	a4,a4,s3
 7cc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7ce:	1702                	slli	a4,a4,0x20
 7d0:	9301                	srli	a4,a4,0x20
 7d2:	0712                	slli	a4,a4,0x4
 7d4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7d6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7da:	00001717          	auipc	a4,0x1
 7de:	82a73323          	sd	a0,-2010(a4) # 1000 <freep>
      return (void*)(p + 1);
 7e2:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7e6:	70e2                	ld	ra,56(sp)
 7e8:	7442                	ld	s0,48(sp)
 7ea:	74a2                	ld	s1,40(sp)
 7ec:	7902                	ld	s2,32(sp)
 7ee:	69e2                	ld	s3,24(sp)
 7f0:	6a42                	ld	s4,16(sp)
 7f2:	6aa2                	ld	s5,8(sp)
 7f4:	6b02                	ld	s6,0(sp)
 7f6:	6121                	addi	sp,sp,64
 7f8:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7fa:	6398                	ld	a4,0(a5)
 7fc:	e118                	sd	a4,0(a0)
 7fe:	bff1                	j	7da <malloc+0x86>
  hp->s.size = nu;
 800:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 804:	0541                	addi	a0,a0,16
 806:	00000097          	auipc	ra,0x0
 80a:	ec6080e7          	jalr	-314(ra) # 6cc <free>
  return freep;
 80e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 812:	d971                	beqz	a0,7e6 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 814:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 816:	4798                	lw	a4,8(a5)
 818:	fa9776e3          	bgeu	a4,s1,7c4 <malloc+0x70>
    if(p == freep)
 81c:	00093703          	ld	a4,0(s2)
 820:	853e                	mv	a0,a5
 822:	fef719e3          	bne	a4,a5,814 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 826:	8552                	mv	a0,s4
 828:	00000097          	auipc	ra,0x0
 82c:	b56080e7          	jalr	-1194(ra) # 37e <sbrk>
  if(p == (char*)-1)
 830:	fd5518e3          	bne	a0,s5,800 <malloc+0xac>
        return 0;
 834:	4501                	li	a0,0
 836:	bf45                	j	7e6 <malloc+0x92>
