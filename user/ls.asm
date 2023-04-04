
user/_ls:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <fmtname>:
#include "user/user.h"
#include "kernel/fs.h"

char*
fmtname(char *path)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	84aa                	mv	s1,a0
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
  10:	00000097          	auipc	ra,0x0
  14:	342080e7          	jalr	834(ra) # 352 <strlen>
  18:	02051793          	slli	a5,a0,0x20
  1c:	9381                	srli	a5,a5,0x20
  1e:	97a6                	add	a5,a5,s1
  20:	02f00693          	li	a3,47
  24:	0097e963          	bltu	a5,s1,36 <fmtname+0x36>
  28:	0007c703          	lbu	a4,0(a5)
  2c:	00d70563          	beq	a4,a3,36 <fmtname+0x36>
  30:	17fd                	addi	a5,a5,-1
  32:	fe97fbe3          	bgeu	a5,s1,28 <fmtname+0x28>
    ;
  p++;
  36:	00178493          	addi	s1,a5,1

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  3a:	8526                	mv	a0,s1
  3c:	00000097          	auipc	ra,0x0
  40:	316080e7          	jalr	790(ra) # 352 <strlen>
  44:	2501                	sext.w	a0,a0
  46:	47b5                	li	a5,13
  48:	00a7fa63          	bgeu	a5,a0,5c <fmtname+0x5c>
    return p;
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  return buf;
}
  4c:	8526                	mv	a0,s1
  4e:	70a2                	ld	ra,40(sp)
  50:	7402                	ld	s0,32(sp)
  52:	64e2                	ld	s1,24(sp)
  54:	6942                	ld	s2,16(sp)
  56:	69a2                	ld	s3,8(sp)
  58:	6145                	addi	sp,sp,48
  5a:	8082                	ret
  memmove(buf, p, strlen(p));
  5c:	8526                	mv	a0,s1
  5e:	00000097          	auipc	ra,0x0
  62:	2f4080e7          	jalr	756(ra) # 352 <strlen>
  66:	00001997          	auipc	s3,0x1
  6a:	faa98993          	addi	s3,s3,-86 # 1010 <buf.0>
  6e:	0005061b          	sext.w	a2,a0
  72:	85a6                	mv	a1,s1
  74:	854e                	mv	a0,s3
  76:	00000097          	auipc	ra,0x0
  7a:	450080e7          	jalr	1104(ra) # 4c6 <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  7e:	8526                	mv	a0,s1
  80:	00000097          	auipc	ra,0x0
  84:	2d2080e7          	jalr	722(ra) # 352 <strlen>
  88:	0005091b          	sext.w	s2,a0
  8c:	8526                	mv	a0,s1
  8e:	00000097          	auipc	ra,0x0
  92:	2c4080e7          	jalr	708(ra) # 352 <strlen>
  96:	1902                	slli	s2,s2,0x20
  98:	02095913          	srli	s2,s2,0x20
  9c:	4639                	li	a2,14
  9e:	9e09                	subw	a2,a2,a0
  a0:	02000593          	li	a1,32
  a4:	01298533          	add	a0,s3,s2
  a8:	00000097          	auipc	ra,0x0
  ac:	2d4080e7          	jalr	724(ra) # 37c <memset>
  return buf;
  b0:	84ce                	mv	s1,s3
  b2:	bf69                	j	4c <fmtname+0x4c>

00000000000000b4 <ls>:

void
ls(char *path)
{
  b4:	d9010113          	addi	sp,sp,-624
  b8:	26113423          	sd	ra,616(sp)
  bc:	26813023          	sd	s0,608(sp)
  c0:	24913c23          	sd	s1,600(sp)
  c4:	25213823          	sd	s2,592(sp)
  c8:	25313423          	sd	s3,584(sp)
  cc:	25413023          	sd	s4,576(sp)
  d0:	23513c23          	sd	s5,568(sp)
  d4:	1c80                	addi	s0,sp,624
  d6:	892a                	mv	s2,a0
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
  d8:	4581                	li	a1,0
  da:	00000097          	auipc	ra,0x0
  de:	4de080e7          	jalr	1246(ra) # 5b8 <open>
  e2:	08054163          	bltz	a0,164 <ls+0xb0>
  e6:	84aa                	mv	s1,a0
    fprintf(2, "ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
  e8:	d9840593          	addi	a1,s0,-616
  ec:	00000097          	auipc	ra,0x0
  f0:	4e4080e7          	jalr	1252(ra) # 5d0 <fstat>
  f4:	08054363          	bltz	a0,17a <ls+0xc6>
    fprintf(2, "ls: cannot stat %s\n", path);
    close(fd);
    return;
  }

  switch(st.type){
  f8:	da041783          	lh	a5,-608(s0)
  fc:	0007869b          	sext.w	a3,a5
 100:	4705                	li	a4,1
 102:	08e68c63          	beq	a3,a4,19a <ls+0xe6>
 106:	37f9                	addiw	a5,a5,-2
 108:	17c2                	slli	a5,a5,0x30
 10a:	93c1                	srli	a5,a5,0x30
 10c:	02f76663          	bltu	a4,a5,138 <ls+0x84>
  case T_DEVICE:
  case T_FILE:
    printf("%s %d %d %l\n", fmtname(path), st.type, st.ino, st.size);
 110:	854a                	mv	a0,s2
 112:	00000097          	auipc	ra,0x0
 116:	eee080e7          	jalr	-274(ra) # 0 <fmtname>
 11a:	85aa                	mv	a1,a0
 11c:	da843703          	ld	a4,-600(s0)
 120:	d9c42683          	lw	a3,-612(s0)
 124:	da041603          	lh	a2,-608(s0)
 128:	00001517          	auipc	a0,0x1
 12c:	9c850513          	addi	a0,a0,-1592 # af0 <malloc+0x11a>
 130:	00000097          	auipc	ra,0x0
 134:	7e8080e7          	jalr	2024(ra) # 918 <printf>
      }
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
    }
    break;
  }
  close(fd);
 138:	8526                	mv	a0,s1
 13a:	00000097          	auipc	ra,0x0
 13e:	466080e7          	jalr	1126(ra) # 5a0 <close>
}
 142:	26813083          	ld	ra,616(sp)
 146:	26013403          	ld	s0,608(sp)
 14a:	25813483          	ld	s1,600(sp)
 14e:	25013903          	ld	s2,592(sp)
 152:	24813983          	ld	s3,584(sp)
 156:	24013a03          	ld	s4,576(sp)
 15a:	23813a83          	ld	s5,568(sp)
 15e:	27010113          	addi	sp,sp,624
 162:	8082                	ret
    fprintf(2, "ls: cannot open %s\n", path);
 164:	864a                	mv	a2,s2
 166:	00001597          	auipc	a1,0x1
 16a:	95a58593          	addi	a1,a1,-1702 # ac0 <malloc+0xea>
 16e:	4509                	li	a0,2
 170:	00000097          	auipc	ra,0x0
 174:	77a080e7          	jalr	1914(ra) # 8ea <fprintf>
    return;
 178:	b7e9                	j	142 <ls+0x8e>
    fprintf(2, "ls: cannot stat %s\n", path);
 17a:	864a                	mv	a2,s2
 17c:	00001597          	auipc	a1,0x1
 180:	95c58593          	addi	a1,a1,-1700 # ad8 <malloc+0x102>
 184:	4509                	li	a0,2
 186:	00000097          	auipc	ra,0x0
 18a:	764080e7          	jalr	1892(ra) # 8ea <fprintf>
    close(fd);
 18e:	8526                	mv	a0,s1
 190:	00000097          	auipc	ra,0x0
 194:	410080e7          	jalr	1040(ra) # 5a0 <close>
    return;
 198:	b76d                	j	142 <ls+0x8e>
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 19a:	854a                	mv	a0,s2
 19c:	00000097          	auipc	ra,0x0
 1a0:	1b6080e7          	jalr	438(ra) # 352 <strlen>
 1a4:	2541                	addiw	a0,a0,16
 1a6:	20000793          	li	a5,512
 1aa:	00a7fb63          	bgeu	a5,a0,1c0 <ls+0x10c>
      printf("ls: path too long\n");
 1ae:	00001517          	auipc	a0,0x1
 1b2:	95250513          	addi	a0,a0,-1710 # b00 <malloc+0x12a>
 1b6:	00000097          	auipc	ra,0x0
 1ba:	762080e7          	jalr	1890(ra) # 918 <printf>
      break;
 1be:	bfad                	j	138 <ls+0x84>
    strcpy(buf, path);
 1c0:	85ca                	mv	a1,s2
 1c2:	dc040513          	addi	a0,s0,-576
 1c6:	00000097          	auipc	ra,0x0
 1ca:	144080e7          	jalr	324(ra) # 30a <strcpy>
    p = buf+strlen(buf);
 1ce:	dc040513          	addi	a0,s0,-576
 1d2:	00000097          	auipc	ra,0x0
 1d6:	180080e7          	jalr	384(ra) # 352 <strlen>
 1da:	02051913          	slli	s2,a0,0x20
 1de:	02095913          	srli	s2,s2,0x20
 1e2:	dc040793          	addi	a5,s0,-576
 1e6:	993e                	add	s2,s2,a5
    *p++ = '/';
 1e8:	00190993          	addi	s3,s2,1
 1ec:	02f00793          	li	a5,47
 1f0:	00f90023          	sb	a5,0(s2)
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 1f4:	00001a17          	auipc	s4,0x1
 1f8:	924a0a13          	addi	s4,s4,-1756 # b18 <malloc+0x142>
        printf("ls: cannot stat %s\n", buf);
 1fc:	00001a97          	auipc	s5,0x1
 200:	8dca8a93          	addi	s5,s5,-1828 # ad8 <malloc+0x102>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 204:	a801                	j	214 <ls+0x160>
        printf("ls: cannot stat %s\n", buf);
 206:	dc040593          	addi	a1,s0,-576
 20a:	8556                	mv	a0,s5
 20c:	00000097          	auipc	ra,0x0
 210:	70c080e7          	jalr	1804(ra) # 918 <printf>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 214:	4641                	li	a2,16
 216:	db040593          	addi	a1,s0,-592
 21a:	8526                	mv	a0,s1
 21c:	00000097          	auipc	ra,0x0
 220:	374080e7          	jalr	884(ra) # 590 <read>
 224:	47c1                	li	a5,16
 226:	f0f519e3          	bne	a0,a5,138 <ls+0x84>
      if(de.inum == 0)
 22a:	db045783          	lhu	a5,-592(s0)
 22e:	d3fd                	beqz	a5,214 <ls+0x160>
      memmove(p, de.name, DIRSIZ);
 230:	4639                	li	a2,14
 232:	db240593          	addi	a1,s0,-590
 236:	854e                	mv	a0,s3
 238:	00000097          	auipc	ra,0x0
 23c:	28e080e7          	jalr	654(ra) # 4c6 <memmove>
      p[DIRSIZ] = 0;
 240:	000907a3          	sb	zero,15(s2)
      if(stat(buf, &st) < 0){
 244:	d9840593          	addi	a1,s0,-616
 248:	dc040513          	addi	a0,s0,-576
 24c:	00000097          	auipc	ra,0x0
 250:	1ea080e7          	jalr	490(ra) # 436 <stat>
 254:	fa0549e3          	bltz	a0,206 <ls+0x152>
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 258:	dc040513          	addi	a0,s0,-576
 25c:	00000097          	auipc	ra,0x0
 260:	da4080e7          	jalr	-604(ra) # 0 <fmtname>
 264:	85aa                	mv	a1,a0
 266:	da843703          	ld	a4,-600(s0)
 26a:	d9c42683          	lw	a3,-612(s0)
 26e:	da041603          	lh	a2,-608(s0)
 272:	8552                	mv	a0,s4
 274:	00000097          	auipc	ra,0x0
 278:	6a4080e7          	jalr	1700(ra) # 918 <printf>
 27c:	bf61                	j	214 <ls+0x160>

000000000000027e <main>:

int
main(int argc, char *argv[])
{
 27e:	1101                	addi	sp,sp,-32
 280:	ec06                	sd	ra,24(sp)
 282:	e822                	sd	s0,16(sp)
 284:	e426                	sd	s1,8(sp)
 286:	e04a                	sd	s2,0(sp)
 288:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
 28a:	4785                	li	a5,1
 28c:	02a7dd63          	bge	a5,a0,2c6 <main+0x48>
 290:	00858493          	addi	s1,a1,8
 294:	ffe5091b          	addiw	s2,a0,-2
 298:	1902                	slli	s2,s2,0x20
 29a:	02095913          	srli	s2,s2,0x20
 29e:	090e                	slli	s2,s2,0x3
 2a0:	05c1                	addi	a1,a1,16
 2a2:	992e                	add	s2,s2,a1
    ls(".");
    exit(0,"");
  }
  for(i=1; i<argc; i++)
    ls(argv[i]);
 2a4:	6088                	ld	a0,0(s1)
 2a6:	00000097          	auipc	ra,0x0
 2aa:	e0e080e7          	jalr	-498(ra) # b4 <ls>
  for(i=1; i<argc; i++)
 2ae:	04a1                	addi	s1,s1,8
 2b0:	ff249ae3          	bne	s1,s2,2a4 <main+0x26>
  exit(0,"");
 2b4:	00001597          	auipc	a1,0x1
 2b8:	87c58593          	addi	a1,a1,-1924 # b30 <malloc+0x15a>
 2bc:	4501                	li	a0,0
 2be:	00000097          	auipc	ra,0x0
 2c2:	2ba080e7          	jalr	698(ra) # 578 <exit>
    ls(".");
 2c6:	00001517          	auipc	a0,0x1
 2ca:	86250513          	addi	a0,a0,-1950 # b28 <malloc+0x152>
 2ce:	00000097          	auipc	ra,0x0
 2d2:	de6080e7          	jalr	-538(ra) # b4 <ls>
    exit(0,"");
 2d6:	00001597          	auipc	a1,0x1
 2da:	85a58593          	addi	a1,a1,-1958 # b30 <malloc+0x15a>
 2de:	4501                	li	a0,0
 2e0:	00000097          	auipc	ra,0x0
 2e4:	298080e7          	jalr	664(ra) # 578 <exit>

00000000000002e8 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 2e8:	1141                	addi	sp,sp,-16
 2ea:	e406                	sd	ra,8(sp)
 2ec:	e022                	sd	s0,0(sp)
 2ee:	0800                	addi	s0,sp,16
  extern int main();
  main();
 2f0:	00000097          	auipc	ra,0x0
 2f4:	f8e080e7          	jalr	-114(ra) # 27e <main>
  exit(0,"");
 2f8:	00001597          	auipc	a1,0x1
 2fc:	83858593          	addi	a1,a1,-1992 # b30 <malloc+0x15a>
 300:	4501                	li	a0,0
 302:	00000097          	auipc	ra,0x0
 306:	276080e7          	jalr	630(ra) # 578 <exit>

000000000000030a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 30a:	1141                	addi	sp,sp,-16
 30c:	e422                	sd	s0,8(sp)
 30e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 310:	87aa                	mv	a5,a0
 312:	0585                	addi	a1,a1,1
 314:	0785                	addi	a5,a5,1
 316:	fff5c703          	lbu	a4,-1(a1)
 31a:	fee78fa3          	sb	a4,-1(a5)
 31e:	fb75                	bnez	a4,312 <strcpy+0x8>
    ;
  return os;
}
 320:	6422                	ld	s0,8(sp)
 322:	0141                	addi	sp,sp,16
 324:	8082                	ret

0000000000000326 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 326:	1141                	addi	sp,sp,-16
 328:	e422                	sd	s0,8(sp)
 32a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 32c:	00054783          	lbu	a5,0(a0)
 330:	cb91                	beqz	a5,344 <strcmp+0x1e>
 332:	0005c703          	lbu	a4,0(a1)
 336:	00f71763          	bne	a4,a5,344 <strcmp+0x1e>
    p++, q++;
 33a:	0505                	addi	a0,a0,1
 33c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 33e:	00054783          	lbu	a5,0(a0)
 342:	fbe5                	bnez	a5,332 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 344:	0005c503          	lbu	a0,0(a1)
}
 348:	40a7853b          	subw	a0,a5,a0
 34c:	6422                	ld	s0,8(sp)
 34e:	0141                	addi	sp,sp,16
 350:	8082                	ret

0000000000000352 <strlen>:

uint
strlen(const char *s)
{
 352:	1141                	addi	sp,sp,-16
 354:	e422                	sd	s0,8(sp)
 356:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 358:	00054783          	lbu	a5,0(a0)
 35c:	cf91                	beqz	a5,378 <strlen+0x26>
 35e:	0505                	addi	a0,a0,1
 360:	87aa                	mv	a5,a0
 362:	4685                	li	a3,1
 364:	9e89                	subw	a3,a3,a0
 366:	00f6853b          	addw	a0,a3,a5
 36a:	0785                	addi	a5,a5,1
 36c:	fff7c703          	lbu	a4,-1(a5)
 370:	fb7d                	bnez	a4,366 <strlen+0x14>
    ;
  return n;
}
 372:	6422                	ld	s0,8(sp)
 374:	0141                	addi	sp,sp,16
 376:	8082                	ret
  for(n = 0; s[n]; n++)
 378:	4501                	li	a0,0
 37a:	bfe5                	j	372 <strlen+0x20>

000000000000037c <memset>:

void*
memset(void *dst, int c, uint n)
{
 37c:	1141                	addi	sp,sp,-16
 37e:	e422                	sd	s0,8(sp)
 380:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 382:	ca19                	beqz	a2,398 <memset+0x1c>
 384:	87aa                	mv	a5,a0
 386:	1602                	slli	a2,a2,0x20
 388:	9201                	srli	a2,a2,0x20
 38a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 38e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 392:	0785                	addi	a5,a5,1
 394:	fee79de3          	bne	a5,a4,38e <memset+0x12>
  }
  return dst;
}
 398:	6422                	ld	s0,8(sp)
 39a:	0141                	addi	sp,sp,16
 39c:	8082                	ret

000000000000039e <strchr>:

char*
strchr(const char *s, char c)
{
 39e:	1141                	addi	sp,sp,-16
 3a0:	e422                	sd	s0,8(sp)
 3a2:	0800                	addi	s0,sp,16
  for(; *s; s++)
 3a4:	00054783          	lbu	a5,0(a0)
 3a8:	cb99                	beqz	a5,3be <strchr+0x20>
    if(*s == c)
 3aa:	00f58763          	beq	a1,a5,3b8 <strchr+0x1a>
  for(; *s; s++)
 3ae:	0505                	addi	a0,a0,1
 3b0:	00054783          	lbu	a5,0(a0)
 3b4:	fbfd                	bnez	a5,3aa <strchr+0xc>
      return (char*)s;
  return 0;
 3b6:	4501                	li	a0,0
}
 3b8:	6422                	ld	s0,8(sp)
 3ba:	0141                	addi	sp,sp,16
 3bc:	8082                	ret
  return 0;
 3be:	4501                	li	a0,0
 3c0:	bfe5                	j	3b8 <strchr+0x1a>

00000000000003c2 <gets>:

char*
gets(char *buf, int max)
{
 3c2:	711d                	addi	sp,sp,-96
 3c4:	ec86                	sd	ra,88(sp)
 3c6:	e8a2                	sd	s0,80(sp)
 3c8:	e4a6                	sd	s1,72(sp)
 3ca:	e0ca                	sd	s2,64(sp)
 3cc:	fc4e                	sd	s3,56(sp)
 3ce:	f852                	sd	s4,48(sp)
 3d0:	f456                	sd	s5,40(sp)
 3d2:	f05a                	sd	s6,32(sp)
 3d4:	ec5e                	sd	s7,24(sp)
 3d6:	1080                	addi	s0,sp,96
 3d8:	8baa                	mv	s7,a0
 3da:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3dc:	892a                	mv	s2,a0
 3de:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 3e0:	4aa9                	li	s5,10
 3e2:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 3e4:	89a6                	mv	s3,s1
 3e6:	2485                	addiw	s1,s1,1
 3e8:	0344d863          	bge	s1,s4,418 <gets+0x56>
    cc = read(0, &c, 1);
 3ec:	4605                	li	a2,1
 3ee:	faf40593          	addi	a1,s0,-81
 3f2:	4501                	li	a0,0
 3f4:	00000097          	auipc	ra,0x0
 3f8:	19c080e7          	jalr	412(ra) # 590 <read>
    if(cc < 1)
 3fc:	00a05e63          	blez	a0,418 <gets+0x56>
    buf[i++] = c;
 400:	faf44783          	lbu	a5,-81(s0)
 404:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 408:	01578763          	beq	a5,s5,416 <gets+0x54>
 40c:	0905                	addi	s2,s2,1
 40e:	fd679be3          	bne	a5,s6,3e4 <gets+0x22>
  for(i=0; i+1 < max; ){
 412:	89a6                	mv	s3,s1
 414:	a011                	j	418 <gets+0x56>
 416:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 418:	99de                	add	s3,s3,s7
 41a:	00098023          	sb	zero,0(s3)
  return buf;
}
 41e:	855e                	mv	a0,s7
 420:	60e6                	ld	ra,88(sp)
 422:	6446                	ld	s0,80(sp)
 424:	64a6                	ld	s1,72(sp)
 426:	6906                	ld	s2,64(sp)
 428:	79e2                	ld	s3,56(sp)
 42a:	7a42                	ld	s4,48(sp)
 42c:	7aa2                	ld	s5,40(sp)
 42e:	7b02                	ld	s6,32(sp)
 430:	6be2                	ld	s7,24(sp)
 432:	6125                	addi	sp,sp,96
 434:	8082                	ret

0000000000000436 <stat>:

int
stat(const char *n, struct stat *st)
{
 436:	1101                	addi	sp,sp,-32
 438:	ec06                	sd	ra,24(sp)
 43a:	e822                	sd	s0,16(sp)
 43c:	e426                	sd	s1,8(sp)
 43e:	e04a                	sd	s2,0(sp)
 440:	1000                	addi	s0,sp,32
 442:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 444:	4581                	li	a1,0
 446:	00000097          	auipc	ra,0x0
 44a:	172080e7          	jalr	370(ra) # 5b8 <open>
  if(fd < 0)
 44e:	02054563          	bltz	a0,478 <stat+0x42>
 452:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 454:	85ca                	mv	a1,s2
 456:	00000097          	auipc	ra,0x0
 45a:	17a080e7          	jalr	378(ra) # 5d0 <fstat>
 45e:	892a                	mv	s2,a0
  close(fd);
 460:	8526                	mv	a0,s1
 462:	00000097          	auipc	ra,0x0
 466:	13e080e7          	jalr	318(ra) # 5a0 <close>
  return r;
}
 46a:	854a                	mv	a0,s2
 46c:	60e2                	ld	ra,24(sp)
 46e:	6442                	ld	s0,16(sp)
 470:	64a2                	ld	s1,8(sp)
 472:	6902                	ld	s2,0(sp)
 474:	6105                	addi	sp,sp,32
 476:	8082                	ret
    return -1;
 478:	597d                	li	s2,-1
 47a:	bfc5                	j	46a <stat+0x34>

000000000000047c <atoi>:

int
atoi(const char *s)
{
 47c:	1141                	addi	sp,sp,-16
 47e:	e422                	sd	s0,8(sp)
 480:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 482:	00054603          	lbu	a2,0(a0)
 486:	fd06079b          	addiw	a5,a2,-48
 48a:	0ff7f793          	andi	a5,a5,255
 48e:	4725                	li	a4,9
 490:	02f76963          	bltu	a4,a5,4c2 <atoi+0x46>
 494:	86aa                	mv	a3,a0
  n = 0;
 496:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 498:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 49a:	0685                	addi	a3,a3,1
 49c:	0025179b          	slliw	a5,a0,0x2
 4a0:	9fa9                	addw	a5,a5,a0
 4a2:	0017979b          	slliw	a5,a5,0x1
 4a6:	9fb1                	addw	a5,a5,a2
 4a8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 4ac:	0006c603          	lbu	a2,0(a3)
 4b0:	fd06071b          	addiw	a4,a2,-48
 4b4:	0ff77713          	andi	a4,a4,255
 4b8:	fee5f1e3          	bgeu	a1,a4,49a <atoi+0x1e>
  return n;
}
 4bc:	6422                	ld	s0,8(sp)
 4be:	0141                	addi	sp,sp,16
 4c0:	8082                	ret
  n = 0;
 4c2:	4501                	li	a0,0
 4c4:	bfe5                	j	4bc <atoi+0x40>

00000000000004c6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4c6:	1141                	addi	sp,sp,-16
 4c8:	e422                	sd	s0,8(sp)
 4ca:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 4cc:	02b57463          	bgeu	a0,a1,4f4 <memmove+0x2e>
    while(n-- > 0)
 4d0:	00c05f63          	blez	a2,4ee <memmove+0x28>
 4d4:	1602                	slli	a2,a2,0x20
 4d6:	9201                	srli	a2,a2,0x20
 4d8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 4dc:	872a                	mv	a4,a0
      *dst++ = *src++;
 4de:	0585                	addi	a1,a1,1
 4e0:	0705                	addi	a4,a4,1
 4e2:	fff5c683          	lbu	a3,-1(a1)
 4e6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 4ea:	fee79ae3          	bne	a5,a4,4de <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4ee:	6422                	ld	s0,8(sp)
 4f0:	0141                	addi	sp,sp,16
 4f2:	8082                	ret
    dst += n;
 4f4:	00c50733          	add	a4,a0,a2
    src += n;
 4f8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 4fa:	fec05ae3          	blez	a2,4ee <memmove+0x28>
 4fe:	fff6079b          	addiw	a5,a2,-1
 502:	1782                	slli	a5,a5,0x20
 504:	9381                	srli	a5,a5,0x20
 506:	fff7c793          	not	a5,a5
 50a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 50c:	15fd                	addi	a1,a1,-1
 50e:	177d                	addi	a4,a4,-1
 510:	0005c683          	lbu	a3,0(a1)
 514:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 518:	fee79ae3          	bne	a5,a4,50c <memmove+0x46>
 51c:	bfc9                	j	4ee <memmove+0x28>

000000000000051e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 51e:	1141                	addi	sp,sp,-16
 520:	e422                	sd	s0,8(sp)
 522:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 524:	ca05                	beqz	a2,554 <memcmp+0x36>
 526:	fff6069b          	addiw	a3,a2,-1
 52a:	1682                	slli	a3,a3,0x20
 52c:	9281                	srli	a3,a3,0x20
 52e:	0685                	addi	a3,a3,1
 530:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 532:	00054783          	lbu	a5,0(a0)
 536:	0005c703          	lbu	a4,0(a1)
 53a:	00e79863          	bne	a5,a4,54a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 53e:	0505                	addi	a0,a0,1
    p2++;
 540:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 542:	fed518e3          	bne	a0,a3,532 <memcmp+0x14>
  }
  return 0;
 546:	4501                	li	a0,0
 548:	a019                	j	54e <memcmp+0x30>
      return *p1 - *p2;
 54a:	40e7853b          	subw	a0,a5,a4
}
 54e:	6422                	ld	s0,8(sp)
 550:	0141                	addi	sp,sp,16
 552:	8082                	ret
  return 0;
 554:	4501                	li	a0,0
 556:	bfe5                	j	54e <memcmp+0x30>

0000000000000558 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 558:	1141                	addi	sp,sp,-16
 55a:	e406                	sd	ra,8(sp)
 55c:	e022                	sd	s0,0(sp)
 55e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 560:	00000097          	auipc	ra,0x0
 564:	f66080e7          	jalr	-154(ra) # 4c6 <memmove>
}
 568:	60a2                	ld	ra,8(sp)
 56a:	6402                	ld	s0,0(sp)
 56c:	0141                	addi	sp,sp,16
 56e:	8082                	ret

0000000000000570 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 570:	4885                	li	a7,1
 ecall
 572:	00000073          	ecall
 ret
 576:	8082                	ret

0000000000000578 <exit>:
.global exit
exit:
 li a7, SYS_exit
 578:	4889                	li	a7,2
 ecall
 57a:	00000073          	ecall
 ret
 57e:	8082                	ret

0000000000000580 <wait>:
.global wait
wait:
 li a7, SYS_wait
 580:	488d                	li	a7,3
 ecall
 582:	00000073          	ecall
 ret
 586:	8082                	ret

0000000000000588 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 588:	4891                	li	a7,4
 ecall
 58a:	00000073          	ecall
 ret
 58e:	8082                	ret

0000000000000590 <read>:
.global read
read:
 li a7, SYS_read
 590:	4895                	li	a7,5
 ecall
 592:	00000073          	ecall
 ret
 596:	8082                	ret

0000000000000598 <write>:
.global write
write:
 li a7, SYS_write
 598:	48c1                	li	a7,16
 ecall
 59a:	00000073          	ecall
 ret
 59e:	8082                	ret

00000000000005a0 <close>:
.global close
close:
 li a7, SYS_close
 5a0:	48d5                	li	a7,21
 ecall
 5a2:	00000073          	ecall
 ret
 5a6:	8082                	ret

00000000000005a8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 5a8:	4899                	li	a7,6
 ecall
 5aa:	00000073          	ecall
 ret
 5ae:	8082                	ret

00000000000005b0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 5b0:	489d                	li	a7,7
 ecall
 5b2:	00000073          	ecall
 ret
 5b6:	8082                	ret

00000000000005b8 <open>:
.global open
open:
 li a7, SYS_open
 5b8:	48bd                	li	a7,15
 ecall
 5ba:	00000073          	ecall
 ret
 5be:	8082                	ret

00000000000005c0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5c0:	48c5                	li	a7,17
 ecall
 5c2:	00000073          	ecall
 ret
 5c6:	8082                	ret

00000000000005c8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5c8:	48c9                	li	a7,18
 ecall
 5ca:	00000073          	ecall
 ret
 5ce:	8082                	ret

00000000000005d0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5d0:	48a1                	li	a7,8
 ecall
 5d2:	00000073          	ecall
 ret
 5d6:	8082                	ret

00000000000005d8 <link>:
.global link
link:
 li a7, SYS_link
 5d8:	48cd                	li	a7,19
 ecall
 5da:	00000073          	ecall
 ret
 5de:	8082                	ret

00000000000005e0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5e0:	48d1                	li	a7,20
 ecall
 5e2:	00000073          	ecall
 ret
 5e6:	8082                	ret

00000000000005e8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5e8:	48a5                	li	a7,9
 ecall
 5ea:	00000073          	ecall
 ret
 5ee:	8082                	ret

00000000000005f0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 5f0:	48a9                	li	a7,10
 ecall
 5f2:	00000073          	ecall
 ret
 5f6:	8082                	ret

00000000000005f8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5f8:	48ad                	li	a7,11
 ecall
 5fa:	00000073          	ecall
 ret
 5fe:	8082                	ret

0000000000000600 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 600:	48b1                	li	a7,12
 ecall
 602:	00000073          	ecall
 ret
 606:	8082                	ret

0000000000000608 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 608:	48b5                	li	a7,13
 ecall
 60a:	00000073          	ecall
 ret
 60e:	8082                	ret

0000000000000610 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 610:	48b9                	li	a7,14
 ecall
 612:	00000073          	ecall
 ret
 616:	8082                	ret

0000000000000618 <memsize>:
.global memsize
memsize:
 li a7, SYS_memsize
 618:	48d9                	li	a7,22
 ecall
 61a:	00000073          	ecall
 ret
 61e:	8082                	ret

0000000000000620 <set_ps_priority>:
.global set_ps_priority
set_ps_priority:
 li a7, SYS_set_ps_priority
 620:	48dd                	li	a7,23
 ecall
 622:	00000073          	ecall
 ret
 626:	8082                	ret

0000000000000628 <set_cfs_priority>:
.global set_cfs_priority
set_cfs_priority:
 li a7, SYS_set_cfs_priority
 628:	48e1                	li	a7,24
 ecall
 62a:	00000073          	ecall
 ret
 62e:	8082                	ret

0000000000000630 <get_cfs_stats>:
.global get_cfs_stats
get_cfs_stats:
 li a7, SYS_get_cfs_stats
 630:	48e5                	li	a7,25
 ecall
 632:	00000073          	ecall
 ret
 636:	8082                	ret

0000000000000638 <set_policy>:
.global set_policy
set_policy:
 li a7, SYS_set_policy
 638:	48e9                	li	a7,26
 ecall
 63a:	00000073          	ecall
 ret
 63e:	8082                	ret

0000000000000640 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 640:	1101                	addi	sp,sp,-32
 642:	ec06                	sd	ra,24(sp)
 644:	e822                	sd	s0,16(sp)
 646:	1000                	addi	s0,sp,32
 648:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 64c:	4605                	li	a2,1
 64e:	fef40593          	addi	a1,s0,-17
 652:	00000097          	auipc	ra,0x0
 656:	f46080e7          	jalr	-186(ra) # 598 <write>
}
 65a:	60e2                	ld	ra,24(sp)
 65c:	6442                	ld	s0,16(sp)
 65e:	6105                	addi	sp,sp,32
 660:	8082                	ret

0000000000000662 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 662:	7139                	addi	sp,sp,-64
 664:	fc06                	sd	ra,56(sp)
 666:	f822                	sd	s0,48(sp)
 668:	f426                	sd	s1,40(sp)
 66a:	f04a                	sd	s2,32(sp)
 66c:	ec4e                	sd	s3,24(sp)
 66e:	0080                	addi	s0,sp,64
 670:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 672:	c299                	beqz	a3,678 <printint+0x16>
 674:	0805c863          	bltz	a1,704 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 678:	2581                	sext.w	a1,a1
  neg = 0;
 67a:	4881                	li	a7,0
 67c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 680:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 682:	2601                	sext.w	a2,a2
 684:	00000517          	auipc	a0,0x0
 688:	4bc50513          	addi	a0,a0,1212 # b40 <digits>
 68c:	883a                	mv	a6,a4
 68e:	2705                	addiw	a4,a4,1
 690:	02c5f7bb          	remuw	a5,a1,a2
 694:	1782                	slli	a5,a5,0x20
 696:	9381                	srli	a5,a5,0x20
 698:	97aa                	add	a5,a5,a0
 69a:	0007c783          	lbu	a5,0(a5)
 69e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 6a2:	0005879b          	sext.w	a5,a1
 6a6:	02c5d5bb          	divuw	a1,a1,a2
 6aa:	0685                	addi	a3,a3,1
 6ac:	fec7f0e3          	bgeu	a5,a2,68c <printint+0x2a>
  if(neg)
 6b0:	00088b63          	beqz	a7,6c6 <printint+0x64>
    buf[i++] = '-';
 6b4:	fd040793          	addi	a5,s0,-48
 6b8:	973e                	add	a4,a4,a5
 6ba:	02d00793          	li	a5,45
 6be:	fef70823          	sb	a5,-16(a4)
 6c2:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 6c6:	02e05863          	blez	a4,6f6 <printint+0x94>
 6ca:	fc040793          	addi	a5,s0,-64
 6ce:	00e78933          	add	s2,a5,a4
 6d2:	fff78993          	addi	s3,a5,-1
 6d6:	99ba                	add	s3,s3,a4
 6d8:	377d                	addiw	a4,a4,-1
 6da:	1702                	slli	a4,a4,0x20
 6dc:	9301                	srli	a4,a4,0x20
 6de:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 6e2:	fff94583          	lbu	a1,-1(s2)
 6e6:	8526                	mv	a0,s1
 6e8:	00000097          	auipc	ra,0x0
 6ec:	f58080e7          	jalr	-168(ra) # 640 <putc>
  while(--i >= 0)
 6f0:	197d                	addi	s2,s2,-1
 6f2:	ff3918e3          	bne	s2,s3,6e2 <printint+0x80>
}
 6f6:	70e2                	ld	ra,56(sp)
 6f8:	7442                	ld	s0,48(sp)
 6fa:	74a2                	ld	s1,40(sp)
 6fc:	7902                	ld	s2,32(sp)
 6fe:	69e2                	ld	s3,24(sp)
 700:	6121                	addi	sp,sp,64
 702:	8082                	ret
    x = -xx;
 704:	40b005bb          	negw	a1,a1
    neg = 1;
 708:	4885                	li	a7,1
    x = -xx;
 70a:	bf8d                	j	67c <printint+0x1a>

000000000000070c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 70c:	7119                	addi	sp,sp,-128
 70e:	fc86                	sd	ra,120(sp)
 710:	f8a2                	sd	s0,112(sp)
 712:	f4a6                	sd	s1,104(sp)
 714:	f0ca                	sd	s2,96(sp)
 716:	ecce                	sd	s3,88(sp)
 718:	e8d2                	sd	s4,80(sp)
 71a:	e4d6                	sd	s5,72(sp)
 71c:	e0da                	sd	s6,64(sp)
 71e:	fc5e                	sd	s7,56(sp)
 720:	f862                	sd	s8,48(sp)
 722:	f466                	sd	s9,40(sp)
 724:	f06a                	sd	s10,32(sp)
 726:	ec6e                	sd	s11,24(sp)
 728:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 72a:	0005c903          	lbu	s2,0(a1)
 72e:	18090f63          	beqz	s2,8cc <vprintf+0x1c0>
 732:	8aaa                	mv	s5,a0
 734:	8b32                	mv	s6,a2
 736:	00158493          	addi	s1,a1,1
  state = 0;
 73a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 73c:	02500a13          	li	s4,37
      if(c == 'd'){
 740:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 744:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 748:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 74c:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 750:	00000b97          	auipc	s7,0x0
 754:	3f0b8b93          	addi	s7,s7,1008 # b40 <digits>
 758:	a839                	j	776 <vprintf+0x6a>
        putc(fd, c);
 75a:	85ca                	mv	a1,s2
 75c:	8556                	mv	a0,s5
 75e:	00000097          	auipc	ra,0x0
 762:	ee2080e7          	jalr	-286(ra) # 640 <putc>
 766:	a019                	j	76c <vprintf+0x60>
    } else if(state == '%'){
 768:	01498f63          	beq	s3,s4,786 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 76c:	0485                	addi	s1,s1,1
 76e:	fff4c903          	lbu	s2,-1(s1)
 772:	14090d63          	beqz	s2,8cc <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 776:	0009079b          	sext.w	a5,s2
    if(state == 0){
 77a:	fe0997e3          	bnez	s3,768 <vprintf+0x5c>
      if(c == '%'){
 77e:	fd479ee3          	bne	a5,s4,75a <vprintf+0x4e>
        state = '%';
 782:	89be                	mv	s3,a5
 784:	b7e5                	j	76c <vprintf+0x60>
      if(c == 'd'){
 786:	05878063          	beq	a5,s8,7c6 <vprintf+0xba>
      } else if(c == 'l') {
 78a:	05978c63          	beq	a5,s9,7e2 <vprintf+0xd6>
      } else if(c == 'x') {
 78e:	07a78863          	beq	a5,s10,7fe <vprintf+0xf2>
      } else if(c == 'p') {
 792:	09b78463          	beq	a5,s11,81a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 796:	07300713          	li	a4,115
 79a:	0ce78663          	beq	a5,a4,866 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 79e:	06300713          	li	a4,99
 7a2:	0ee78e63          	beq	a5,a4,89e <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 7a6:	11478863          	beq	a5,s4,8b6 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7aa:	85d2                	mv	a1,s4
 7ac:	8556                	mv	a0,s5
 7ae:	00000097          	auipc	ra,0x0
 7b2:	e92080e7          	jalr	-366(ra) # 640 <putc>
        putc(fd, c);
 7b6:	85ca                	mv	a1,s2
 7b8:	8556                	mv	a0,s5
 7ba:	00000097          	auipc	ra,0x0
 7be:	e86080e7          	jalr	-378(ra) # 640 <putc>
      }
      state = 0;
 7c2:	4981                	li	s3,0
 7c4:	b765                	j	76c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 7c6:	008b0913          	addi	s2,s6,8
 7ca:	4685                	li	a3,1
 7cc:	4629                	li	a2,10
 7ce:	000b2583          	lw	a1,0(s6)
 7d2:	8556                	mv	a0,s5
 7d4:	00000097          	auipc	ra,0x0
 7d8:	e8e080e7          	jalr	-370(ra) # 662 <printint>
 7dc:	8b4a                	mv	s6,s2
      state = 0;
 7de:	4981                	li	s3,0
 7e0:	b771                	j	76c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7e2:	008b0913          	addi	s2,s6,8
 7e6:	4681                	li	a3,0
 7e8:	4629                	li	a2,10
 7ea:	000b2583          	lw	a1,0(s6)
 7ee:	8556                	mv	a0,s5
 7f0:	00000097          	auipc	ra,0x0
 7f4:	e72080e7          	jalr	-398(ra) # 662 <printint>
 7f8:	8b4a                	mv	s6,s2
      state = 0;
 7fa:	4981                	li	s3,0
 7fc:	bf85                	j	76c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 7fe:	008b0913          	addi	s2,s6,8
 802:	4681                	li	a3,0
 804:	4641                	li	a2,16
 806:	000b2583          	lw	a1,0(s6)
 80a:	8556                	mv	a0,s5
 80c:	00000097          	auipc	ra,0x0
 810:	e56080e7          	jalr	-426(ra) # 662 <printint>
 814:	8b4a                	mv	s6,s2
      state = 0;
 816:	4981                	li	s3,0
 818:	bf91                	j	76c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 81a:	008b0793          	addi	a5,s6,8
 81e:	f8f43423          	sd	a5,-120(s0)
 822:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 826:	03000593          	li	a1,48
 82a:	8556                	mv	a0,s5
 82c:	00000097          	auipc	ra,0x0
 830:	e14080e7          	jalr	-492(ra) # 640 <putc>
  putc(fd, 'x');
 834:	85ea                	mv	a1,s10
 836:	8556                	mv	a0,s5
 838:	00000097          	auipc	ra,0x0
 83c:	e08080e7          	jalr	-504(ra) # 640 <putc>
 840:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 842:	03c9d793          	srli	a5,s3,0x3c
 846:	97de                	add	a5,a5,s7
 848:	0007c583          	lbu	a1,0(a5)
 84c:	8556                	mv	a0,s5
 84e:	00000097          	auipc	ra,0x0
 852:	df2080e7          	jalr	-526(ra) # 640 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 856:	0992                	slli	s3,s3,0x4
 858:	397d                	addiw	s2,s2,-1
 85a:	fe0914e3          	bnez	s2,842 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 85e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 862:	4981                	li	s3,0
 864:	b721                	j	76c <vprintf+0x60>
        s = va_arg(ap, char*);
 866:	008b0993          	addi	s3,s6,8
 86a:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 86e:	02090163          	beqz	s2,890 <vprintf+0x184>
        while(*s != 0){
 872:	00094583          	lbu	a1,0(s2)
 876:	c9a1                	beqz	a1,8c6 <vprintf+0x1ba>
          putc(fd, *s);
 878:	8556                	mv	a0,s5
 87a:	00000097          	auipc	ra,0x0
 87e:	dc6080e7          	jalr	-570(ra) # 640 <putc>
          s++;
 882:	0905                	addi	s2,s2,1
        while(*s != 0){
 884:	00094583          	lbu	a1,0(s2)
 888:	f9e5                	bnez	a1,878 <vprintf+0x16c>
        s = va_arg(ap, char*);
 88a:	8b4e                	mv	s6,s3
      state = 0;
 88c:	4981                	li	s3,0
 88e:	bdf9                	j	76c <vprintf+0x60>
          s = "(null)";
 890:	00000917          	auipc	s2,0x0
 894:	2a890913          	addi	s2,s2,680 # b38 <malloc+0x162>
        while(*s != 0){
 898:	02800593          	li	a1,40
 89c:	bff1                	j	878 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 89e:	008b0913          	addi	s2,s6,8
 8a2:	000b4583          	lbu	a1,0(s6)
 8a6:	8556                	mv	a0,s5
 8a8:	00000097          	auipc	ra,0x0
 8ac:	d98080e7          	jalr	-616(ra) # 640 <putc>
 8b0:	8b4a                	mv	s6,s2
      state = 0;
 8b2:	4981                	li	s3,0
 8b4:	bd65                	j	76c <vprintf+0x60>
        putc(fd, c);
 8b6:	85d2                	mv	a1,s4
 8b8:	8556                	mv	a0,s5
 8ba:	00000097          	auipc	ra,0x0
 8be:	d86080e7          	jalr	-634(ra) # 640 <putc>
      state = 0;
 8c2:	4981                	li	s3,0
 8c4:	b565                	j	76c <vprintf+0x60>
        s = va_arg(ap, char*);
 8c6:	8b4e                	mv	s6,s3
      state = 0;
 8c8:	4981                	li	s3,0
 8ca:	b54d                	j	76c <vprintf+0x60>
    }
  }
}
 8cc:	70e6                	ld	ra,120(sp)
 8ce:	7446                	ld	s0,112(sp)
 8d0:	74a6                	ld	s1,104(sp)
 8d2:	7906                	ld	s2,96(sp)
 8d4:	69e6                	ld	s3,88(sp)
 8d6:	6a46                	ld	s4,80(sp)
 8d8:	6aa6                	ld	s5,72(sp)
 8da:	6b06                	ld	s6,64(sp)
 8dc:	7be2                	ld	s7,56(sp)
 8de:	7c42                	ld	s8,48(sp)
 8e0:	7ca2                	ld	s9,40(sp)
 8e2:	7d02                	ld	s10,32(sp)
 8e4:	6de2                	ld	s11,24(sp)
 8e6:	6109                	addi	sp,sp,128
 8e8:	8082                	ret

00000000000008ea <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8ea:	715d                	addi	sp,sp,-80
 8ec:	ec06                	sd	ra,24(sp)
 8ee:	e822                	sd	s0,16(sp)
 8f0:	1000                	addi	s0,sp,32
 8f2:	e010                	sd	a2,0(s0)
 8f4:	e414                	sd	a3,8(s0)
 8f6:	e818                	sd	a4,16(s0)
 8f8:	ec1c                	sd	a5,24(s0)
 8fa:	03043023          	sd	a6,32(s0)
 8fe:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 902:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 906:	8622                	mv	a2,s0
 908:	00000097          	auipc	ra,0x0
 90c:	e04080e7          	jalr	-508(ra) # 70c <vprintf>
}
 910:	60e2                	ld	ra,24(sp)
 912:	6442                	ld	s0,16(sp)
 914:	6161                	addi	sp,sp,80
 916:	8082                	ret

0000000000000918 <printf>:

void
printf(const char *fmt, ...)
{
 918:	711d                	addi	sp,sp,-96
 91a:	ec06                	sd	ra,24(sp)
 91c:	e822                	sd	s0,16(sp)
 91e:	1000                	addi	s0,sp,32
 920:	e40c                	sd	a1,8(s0)
 922:	e810                	sd	a2,16(s0)
 924:	ec14                	sd	a3,24(s0)
 926:	f018                	sd	a4,32(s0)
 928:	f41c                	sd	a5,40(s0)
 92a:	03043823          	sd	a6,48(s0)
 92e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 932:	00840613          	addi	a2,s0,8
 936:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 93a:	85aa                	mv	a1,a0
 93c:	4505                	li	a0,1
 93e:	00000097          	auipc	ra,0x0
 942:	dce080e7          	jalr	-562(ra) # 70c <vprintf>
}
 946:	60e2                	ld	ra,24(sp)
 948:	6442                	ld	s0,16(sp)
 94a:	6125                	addi	sp,sp,96
 94c:	8082                	ret

000000000000094e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 94e:	1141                	addi	sp,sp,-16
 950:	e422                	sd	s0,8(sp)
 952:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 954:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 958:	00000797          	auipc	a5,0x0
 95c:	6a87b783          	ld	a5,1704(a5) # 1000 <freep>
 960:	a805                	j	990 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 962:	4618                	lw	a4,8(a2)
 964:	9db9                	addw	a1,a1,a4
 966:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 96a:	6398                	ld	a4,0(a5)
 96c:	6318                	ld	a4,0(a4)
 96e:	fee53823          	sd	a4,-16(a0)
 972:	a091                	j	9b6 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 974:	ff852703          	lw	a4,-8(a0)
 978:	9e39                	addw	a2,a2,a4
 97a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 97c:	ff053703          	ld	a4,-16(a0)
 980:	e398                	sd	a4,0(a5)
 982:	a099                	j	9c8 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 984:	6398                	ld	a4,0(a5)
 986:	00e7e463          	bltu	a5,a4,98e <free+0x40>
 98a:	00e6ea63          	bltu	a3,a4,99e <free+0x50>
{
 98e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 990:	fed7fae3          	bgeu	a5,a3,984 <free+0x36>
 994:	6398                	ld	a4,0(a5)
 996:	00e6e463          	bltu	a3,a4,99e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 99a:	fee7eae3          	bltu	a5,a4,98e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 99e:	ff852583          	lw	a1,-8(a0)
 9a2:	6390                	ld	a2,0(a5)
 9a4:	02059713          	slli	a4,a1,0x20
 9a8:	9301                	srli	a4,a4,0x20
 9aa:	0712                	slli	a4,a4,0x4
 9ac:	9736                	add	a4,a4,a3
 9ae:	fae60ae3          	beq	a2,a4,962 <free+0x14>
    bp->s.ptr = p->s.ptr;
 9b2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9b6:	4790                	lw	a2,8(a5)
 9b8:	02061713          	slli	a4,a2,0x20
 9bc:	9301                	srli	a4,a4,0x20
 9be:	0712                	slli	a4,a4,0x4
 9c0:	973e                	add	a4,a4,a5
 9c2:	fae689e3          	beq	a3,a4,974 <free+0x26>
  } else
    p->s.ptr = bp;
 9c6:	e394                	sd	a3,0(a5)
  freep = p;
 9c8:	00000717          	auipc	a4,0x0
 9cc:	62f73c23          	sd	a5,1592(a4) # 1000 <freep>
}
 9d0:	6422                	ld	s0,8(sp)
 9d2:	0141                	addi	sp,sp,16
 9d4:	8082                	ret

00000000000009d6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9d6:	7139                	addi	sp,sp,-64
 9d8:	fc06                	sd	ra,56(sp)
 9da:	f822                	sd	s0,48(sp)
 9dc:	f426                	sd	s1,40(sp)
 9de:	f04a                	sd	s2,32(sp)
 9e0:	ec4e                	sd	s3,24(sp)
 9e2:	e852                	sd	s4,16(sp)
 9e4:	e456                	sd	s5,8(sp)
 9e6:	e05a                	sd	s6,0(sp)
 9e8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9ea:	02051493          	slli	s1,a0,0x20
 9ee:	9081                	srli	s1,s1,0x20
 9f0:	04bd                	addi	s1,s1,15
 9f2:	8091                	srli	s1,s1,0x4
 9f4:	0014899b          	addiw	s3,s1,1
 9f8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9fa:	00000517          	auipc	a0,0x0
 9fe:	60653503          	ld	a0,1542(a0) # 1000 <freep>
 a02:	c515                	beqz	a0,a2e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a04:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a06:	4798                	lw	a4,8(a5)
 a08:	02977f63          	bgeu	a4,s1,a46 <malloc+0x70>
 a0c:	8a4e                	mv	s4,s3
 a0e:	0009871b          	sext.w	a4,s3
 a12:	6685                	lui	a3,0x1
 a14:	00d77363          	bgeu	a4,a3,a1a <malloc+0x44>
 a18:	6a05                	lui	s4,0x1
 a1a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a1e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a22:	00000917          	auipc	s2,0x0
 a26:	5de90913          	addi	s2,s2,1502 # 1000 <freep>
  if(p == (char*)-1)
 a2a:	5afd                	li	s5,-1
 a2c:	a88d                	j	a9e <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 a2e:	00000797          	auipc	a5,0x0
 a32:	5f278793          	addi	a5,a5,1522 # 1020 <base>
 a36:	00000717          	auipc	a4,0x0
 a3a:	5cf73523          	sd	a5,1482(a4) # 1000 <freep>
 a3e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a40:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a44:	b7e1                	j	a0c <malloc+0x36>
      if(p->s.size == nunits)
 a46:	02e48b63          	beq	s1,a4,a7c <malloc+0xa6>
        p->s.size -= nunits;
 a4a:	4137073b          	subw	a4,a4,s3
 a4e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a50:	1702                	slli	a4,a4,0x20
 a52:	9301                	srli	a4,a4,0x20
 a54:	0712                	slli	a4,a4,0x4
 a56:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a58:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a5c:	00000717          	auipc	a4,0x0
 a60:	5aa73223          	sd	a0,1444(a4) # 1000 <freep>
      return (void*)(p + 1);
 a64:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a68:	70e2                	ld	ra,56(sp)
 a6a:	7442                	ld	s0,48(sp)
 a6c:	74a2                	ld	s1,40(sp)
 a6e:	7902                	ld	s2,32(sp)
 a70:	69e2                	ld	s3,24(sp)
 a72:	6a42                	ld	s4,16(sp)
 a74:	6aa2                	ld	s5,8(sp)
 a76:	6b02                	ld	s6,0(sp)
 a78:	6121                	addi	sp,sp,64
 a7a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a7c:	6398                	ld	a4,0(a5)
 a7e:	e118                	sd	a4,0(a0)
 a80:	bff1                	j	a5c <malloc+0x86>
  hp->s.size = nu;
 a82:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a86:	0541                	addi	a0,a0,16
 a88:	00000097          	auipc	ra,0x0
 a8c:	ec6080e7          	jalr	-314(ra) # 94e <free>
  return freep;
 a90:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a94:	d971                	beqz	a0,a68 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a96:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a98:	4798                	lw	a4,8(a5)
 a9a:	fa9776e3          	bgeu	a4,s1,a46 <malloc+0x70>
    if(p == freep)
 a9e:	00093703          	ld	a4,0(s2)
 aa2:	853e                	mv	a0,a5
 aa4:	fef719e3          	bne	a4,a5,a96 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 aa8:	8552                	mv	a0,s4
 aaa:	00000097          	auipc	ra,0x0
 aae:	b56080e7          	jalr	-1194(ra) # 600 <sbrk>
  if(p == (char*)-1)
 ab2:	fd5518e3          	bne	a0,s5,a82 <malloc+0xac>
        return 0;
 ab6:	4501                	li	a0,0
 ab8:	bf45                	j	a68 <malloc+0x92>
