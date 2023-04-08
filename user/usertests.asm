
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <copyinstr1>:
}

// what if you pass ridiculous string pointers to system calls?
void
copyinstr1(char *s)
{
       0:	1141                	addi	sp,sp,-16
       2:	e406                	sd	ra,8(sp)
       4:	e022                	sd	s0,0(sp)
       6:	0800                	addi	s0,sp,16
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };

  for(int ai = 0; ai < 2; ai++){
    uint64 addr = addrs[ai];

    int fd = open((char *)addr, O_CREATE|O_WRONLY);
       8:	20100593          	li	a1,513
       c:	4505                	li	a0,1
       e:	057e                	slli	a0,a0,0x1f
      10:	00006097          	auipc	ra,0x6
      14:	7f6080e7          	jalr	2038(ra) # 6806 <open>
    if(fd >= 0){
      18:	02055063          	bgez	a0,38 <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
      1c:	20100593          	li	a1,513
      20:	557d                	li	a0,-1
      22:	00006097          	auipc	ra,0x6
      26:	7e4080e7          	jalr	2020(ra) # 6806 <open>
    uint64 addr = addrs[ai];
      2a:	55fd                	li	a1,-1
    if(fd >= 0){
      2c:	00055863          	bgez	a0,3c <copyinstr1+0x3c>
      printf("open(%p) returned %d, not -1\n", addr, fd);
      exit(1,"");
    }
  }
}
      30:	60a2                	ld	ra,8(sp)
      32:	6402                	ld	s0,0(sp)
      34:	0141                	addi	sp,sp,16
      36:	8082                	ret
    uint64 addr = addrs[ai];
      38:	4585                	li	a1,1
      3a:	05fe                	slli	a1,a1,0x1f
      printf("open(%p) returned %d, not -1\n", addr, fd);
      3c:	862a                	mv	a2,a0
      3e:	00007517          	auipc	a0,0x7
      42:	cf250513          	addi	a0,a0,-782 # 6d30 <malloc+0x104>
      46:	00007097          	auipc	ra,0x7
      4a:	b28080e7          	jalr	-1240(ra) # 6b6e <printf>
      exit(1,"");
      4e:	00008597          	auipc	a1,0x8
      52:	30a58593          	addi	a1,a1,778 # 8358 <malloc+0x172c>
      56:	4505                	li	a0,1
      58:	00006097          	auipc	ra,0x6
      5c:	76e080e7          	jalr	1902(ra) # 67c6 <exit>

0000000000000060 <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
      60:	0000b797          	auipc	a5,0xb
      64:	50878793          	addi	a5,a5,1288 # b568 <uninit>
      68:	0000e697          	auipc	a3,0xe
      6c:	c1068693          	addi	a3,a3,-1008 # dc78 <buf>
    if(uninit[i] != '\0'){
      70:	0007c703          	lbu	a4,0(a5)
      74:	e709                	bnez	a4,7e <bsstest+0x1e>
  for(i = 0; i < sizeof(uninit); i++){
      76:	0785                	addi	a5,a5,1
      78:	fed79ce3          	bne	a5,a3,70 <bsstest+0x10>
      7c:	8082                	ret
{
      7e:	1141                	addi	sp,sp,-16
      80:	e406                	sd	ra,8(sp)
      82:	e022                	sd	s0,0(sp)
      84:	0800                	addi	s0,sp,16
      printf("%s: bss test failed\n", s);
      86:	85aa                	mv	a1,a0
      88:	00007517          	auipc	a0,0x7
      8c:	cc850513          	addi	a0,a0,-824 # 6d50 <malloc+0x124>
      90:	00007097          	auipc	ra,0x7
      94:	ade080e7          	jalr	-1314(ra) # 6b6e <printf>
      exit(1,"");
      98:	00008597          	auipc	a1,0x8
      9c:	2c058593          	addi	a1,a1,704 # 8358 <malloc+0x172c>
      a0:	4505                	li	a0,1
      a2:	00006097          	auipc	ra,0x6
      a6:	724080e7          	jalr	1828(ra) # 67c6 <exit>

00000000000000aa <opentest>:
{
      aa:	1101                	addi	sp,sp,-32
      ac:	ec06                	sd	ra,24(sp)
      ae:	e822                	sd	s0,16(sp)
      b0:	e426                	sd	s1,8(sp)
      b2:	1000                	addi	s0,sp,32
      b4:	84aa                	mv	s1,a0
  fd = open("echo", 0);
      b6:	4581                	li	a1,0
      b8:	00007517          	auipc	a0,0x7
      bc:	cb050513          	addi	a0,a0,-848 # 6d68 <malloc+0x13c>
      c0:	00006097          	auipc	ra,0x6
      c4:	746080e7          	jalr	1862(ra) # 6806 <open>
  if(fd < 0){
      c8:	02054663          	bltz	a0,f4 <opentest+0x4a>
  close(fd);
      cc:	00006097          	auipc	ra,0x6
      d0:	722080e7          	jalr	1826(ra) # 67ee <close>
  fd = open("doesnotexist", 0);
      d4:	4581                	li	a1,0
      d6:	00007517          	auipc	a0,0x7
      da:	cb250513          	addi	a0,a0,-846 # 6d88 <malloc+0x15c>
      de:	00006097          	auipc	ra,0x6
      e2:	728080e7          	jalr	1832(ra) # 6806 <open>
  if(fd >= 0){
      e6:	02055963          	bgez	a0,118 <opentest+0x6e>
}
      ea:	60e2                	ld	ra,24(sp)
      ec:	6442                	ld	s0,16(sp)
      ee:	64a2                	ld	s1,8(sp)
      f0:	6105                	addi	sp,sp,32
      f2:	8082                	ret
    printf("%s: open echo failed!\n", s);
      f4:	85a6                	mv	a1,s1
      f6:	00007517          	auipc	a0,0x7
      fa:	c7a50513          	addi	a0,a0,-902 # 6d70 <malloc+0x144>
      fe:	00007097          	auipc	ra,0x7
     102:	a70080e7          	jalr	-1424(ra) # 6b6e <printf>
    exit(1,"");
     106:	00008597          	auipc	a1,0x8
     10a:	25258593          	addi	a1,a1,594 # 8358 <malloc+0x172c>
     10e:	4505                	li	a0,1
     110:	00006097          	auipc	ra,0x6
     114:	6b6080e7          	jalr	1718(ra) # 67c6 <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     118:	85a6                	mv	a1,s1
     11a:	00007517          	auipc	a0,0x7
     11e:	c7e50513          	addi	a0,a0,-898 # 6d98 <malloc+0x16c>
     122:	00007097          	auipc	ra,0x7
     126:	a4c080e7          	jalr	-1460(ra) # 6b6e <printf>
    exit(1,"");
     12a:	00008597          	auipc	a1,0x8
     12e:	22e58593          	addi	a1,a1,558 # 8358 <malloc+0x172c>
     132:	4505                	li	a0,1
     134:	00006097          	auipc	ra,0x6
     138:	692080e7          	jalr	1682(ra) # 67c6 <exit>

000000000000013c <truncate2>:
{
     13c:	7179                	addi	sp,sp,-48
     13e:	f406                	sd	ra,40(sp)
     140:	f022                	sd	s0,32(sp)
     142:	ec26                	sd	s1,24(sp)
     144:	e84a                	sd	s2,16(sp)
     146:	e44e                	sd	s3,8(sp)
     148:	1800                	addi	s0,sp,48
     14a:	89aa                	mv	s3,a0
  unlink("truncfile");
     14c:	00007517          	auipc	a0,0x7
     150:	c7450513          	addi	a0,a0,-908 # 6dc0 <malloc+0x194>
     154:	00006097          	auipc	ra,0x6
     158:	6c2080e7          	jalr	1730(ra) # 6816 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     15c:	60100593          	li	a1,1537
     160:	00007517          	auipc	a0,0x7
     164:	c6050513          	addi	a0,a0,-928 # 6dc0 <malloc+0x194>
     168:	00006097          	auipc	ra,0x6
     16c:	69e080e7          	jalr	1694(ra) # 6806 <open>
     170:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     172:	4611                	li	a2,4
     174:	00007597          	auipc	a1,0x7
     178:	c5c58593          	addi	a1,a1,-932 # 6dd0 <malloc+0x1a4>
     17c:	00006097          	auipc	ra,0x6
     180:	66a080e7          	jalr	1642(ra) # 67e6 <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     184:	40100593          	li	a1,1025
     188:	00007517          	auipc	a0,0x7
     18c:	c3850513          	addi	a0,a0,-968 # 6dc0 <malloc+0x194>
     190:	00006097          	auipc	ra,0x6
     194:	676080e7          	jalr	1654(ra) # 6806 <open>
     198:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     19a:	4605                	li	a2,1
     19c:	00007597          	auipc	a1,0x7
     1a0:	c3c58593          	addi	a1,a1,-964 # 6dd8 <malloc+0x1ac>
     1a4:	8526                	mv	a0,s1
     1a6:	00006097          	auipc	ra,0x6
     1aa:	640080e7          	jalr	1600(ra) # 67e6 <write>
  if(n != -1){
     1ae:	57fd                	li	a5,-1
     1b0:	02f51b63          	bne	a0,a5,1e6 <truncate2+0xaa>
  unlink("truncfile");
     1b4:	00007517          	auipc	a0,0x7
     1b8:	c0c50513          	addi	a0,a0,-1012 # 6dc0 <malloc+0x194>
     1bc:	00006097          	auipc	ra,0x6
     1c0:	65a080e7          	jalr	1626(ra) # 6816 <unlink>
  close(fd1);
     1c4:	8526                	mv	a0,s1
     1c6:	00006097          	auipc	ra,0x6
     1ca:	628080e7          	jalr	1576(ra) # 67ee <close>
  close(fd2);
     1ce:	854a                	mv	a0,s2
     1d0:	00006097          	auipc	ra,0x6
     1d4:	61e080e7          	jalr	1566(ra) # 67ee <close>
}
     1d8:	70a2                	ld	ra,40(sp)
     1da:	7402                	ld	s0,32(sp)
     1dc:	64e2                	ld	s1,24(sp)
     1de:	6942                	ld	s2,16(sp)
     1e0:	69a2                	ld	s3,8(sp)
     1e2:	6145                	addi	sp,sp,48
     1e4:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     1e6:	862a                	mv	a2,a0
     1e8:	85ce                	mv	a1,s3
     1ea:	00007517          	auipc	a0,0x7
     1ee:	bf650513          	addi	a0,a0,-1034 # 6de0 <malloc+0x1b4>
     1f2:	00007097          	auipc	ra,0x7
     1f6:	97c080e7          	jalr	-1668(ra) # 6b6e <printf>
    exit(1,"");
     1fa:	00008597          	auipc	a1,0x8
     1fe:	15e58593          	addi	a1,a1,350 # 8358 <malloc+0x172c>
     202:	4505                	li	a0,1
     204:	00006097          	auipc	ra,0x6
     208:	5c2080e7          	jalr	1474(ra) # 67c6 <exit>

000000000000020c <createtest>:
{
     20c:	7179                	addi	sp,sp,-48
     20e:	f406                	sd	ra,40(sp)
     210:	f022                	sd	s0,32(sp)
     212:	ec26                	sd	s1,24(sp)
     214:	e84a                	sd	s2,16(sp)
     216:	1800                	addi	s0,sp,48
  name[0] = 'a';
     218:	06100793          	li	a5,97
     21c:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     220:	fc040d23          	sb	zero,-38(s0)
     224:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     228:	06400913          	li	s2,100
    name[1] = '0' + i;
     22c:	fc940ca3          	sb	s1,-39(s0)
    fd = open(name, O_CREATE|O_RDWR);
     230:	20200593          	li	a1,514
     234:	fd840513          	addi	a0,s0,-40
     238:	00006097          	auipc	ra,0x6
     23c:	5ce080e7          	jalr	1486(ra) # 6806 <open>
    close(fd);
     240:	00006097          	auipc	ra,0x6
     244:	5ae080e7          	jalr	1454(ra) # 67ee <close>
  for(i = 0; i < N; i++){
     248:	2485                	addiw	s1,s1,1
     24a:	0ff4f493          	andi	s1,s1,255
     24e:	fd249fe3          	bne	s1,s2,22c <createtest+0x20>
  name[0] = 'a';
     252:	06100793          	li	a5,97
     256:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     25a:	fc040d23          	sb	zero,-38(s0)
     25e:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     262:	06400913          	li	s2,100
    name[1] = '0' + i;
     266:	fc940ca3          	sb	s1,-39(s0)
    unlink(name);
     26a:	fd840513          	addi	a0,s0,-40
     26e:	00006097          	auipc	ra,0x6
     272:	5a8080e7          	jalr	1448(ra) # 6816 <unlink>
  for(i = 0; i < N; i++){
     276:	2485                	addiw	s1,s1,1
     278:	0ff4f493          	andi	s1,s1,255
     27c:	ff2495e3          	bne	s1,s2,266 <createtest+0x5a>
}
     280:	70a2                	ld	ra,40(sp)
     282:	7402                	ld	s0,32(sp)
     284:	64e2                	ld	s1,24(sp)
     286:	6942                	ld	s2,16(sp)
     288:	6145                	addi	sp,sp,48
     28a:	8082                	ret

000000000000028c <bigwrite>:
{
     28c:	715d                	addi	sp,sp,-80
     28e:	e486                	sd	ra,72(sp)
     290:	e0a2                	sd	s0,64(sp)
     292:	fc26                	sd	s1,56(sp)
     294:	f84a                	sd	s2,48(sp)
     296:	f44e                	sd	s3,40(sp)
     298:	f052                	sd	s4,32(sp)
     29a:	ec56                	sd	s5,24(sp)
     29c:	e85a                	sd	s6,16(sp)
     29e:	e45e                	sd	s7,8(sp)
     2a0:	0880                	addi	s0,sp,80
     2a2:	8baa                	mv	s7,a0
  unlink("bigwrite");
     2a4:	00007517          	auipc	a0,0x7
     2a8:	b6450513          	addi	a0,a0,-1180 # 6e08 <malloc+0x1dc>
     2ac:	00006097          	auipc	ra,0x6
     2b0:	56a080e7          	jalr	1386(ra) # 6816 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2b4:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2b8:	00007a97          	auipc	s5,0x7
     2bc:	b50a8a93          	addi	s5,s5,-1200 # 6e08 <malloc+0x1dc>
      int cc = write(fd, buf, sz);
     2c0:	0000ea17          	auipc	s4,0xe
     2c4:	9b8a0a13          	addi	s4,s4,-1608 # dc78 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2c8:	6b0d                	lui	s6,0x3
     2ca:	1c9b0b13          	addi	s6,s6,457 # 31c9 <sbrkmuch+0x18b>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2ce:	20200593          	li	a1,514
     2d2:	8556                	mv	a0,s5
     2d4:	00006097          	auipc	ra,0x6
     2d8:	532080e7          	jalr	1330(ra) # 6806 <open>
     2dc:	892a                	mv	s2,a0
    if(fd < 0){
     2de:	04054d63          	bltz	a0,338 <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     2e2:	8626                	mv	a2,s1
     2e4:	85d2                	mv	a1,s4
     2e6:	00006097          	auipc	ra,0x6
     2ea:	500080e7          	jalr	1280(ra) # 67e6 <write>
     2ee:	89aa                	mv	s3,a0
      if(cc != sz){
     2f0:	06a49863          	bne	s1,a0,360 <bigwrite+0xd4>
      int cc = write(fd, buf, sz);
     2f4:	8626                	mv	a2,s1
     2f6:	85d2                	mv	a1,s4
     2f8:	854a                	mv	a0,s2
     2fa:	00006097          	auipc	ra,0x6
     2fe:	4ec080e7          	jalr	1260(ra) # 67e6 <write>
      if(cc != sz){
     302:	04951d63          	bne	a0,s1,35c <bigwrite+0xd0>
    close(fd);
     306:	854a                	mv	a0,s2
     308:	00006097          	auipc	ra,0x6
     30c:	4e6080e7          	jalr	1254(ra) # 67ee <close>
    unlink("bigwrite");
     310:	8556                	mv	a0,s5
     312:	00006097          	auipc	ra,0x6
     316:	504080e7          	jalr	1284(ra) # 6816 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     31a:	1d74849b          	addiw	s1,s1,471
     31e:	fb6498e3          	bne	s1,s6,2ce <bigwrite+0x42>
}
     322:	60a6                	ld	ra,72(sp)
     324:	6406                	ld	s0,64(sp)
     326:	74e2                	ld	s1,56(sp)
     328:	7942                	ld	s2,48(sp)
     32a:	79a2                	ld	s3,40(sp)
     32c:	7a02                	ld	s4,32(sp)
     32e:	6ae2                	ld	s5,24(sp)
     330:	6b42                	ld	s6,16(sp)
     332:	6ba2                	ld	s7,8(sp)
     334:	6161                	addi	sp,sp,80
     336:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     338:	85de                	mv	a1,s7
     33a:	00007517          	auipc	a0,0x7
     33e:	ade50513          	addi	a0,a0,-1314 # 6e18 <malloc+0x1ec>
     342:	00007097          	auipc	ra,0x7
     346:	82c080e7          	jalr	-2004(ra) # 6b6e <printf>
      exit(1,"");
     34a:	00008597          	auipc	a1,0x8
     34e:	00e58593          	addi	a1,a1,14 # 8358 <malloc+0x172c>
     352:	4505                	li	a0,1
     354:	00006097          	auipc	ra,0x6
     358:	472080e7          	jalr	1138(ra) # 67c6 <exit>
     35c:	84ce                	mv	s1,s3
      int cc = write(fd, buf, sz);
     35e:	89aa                	mv	s3,a0
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     360:	86ce                	mv	a3,s3
     362:	8626                	mv	a2,s1
     364:	85de                	mv	a1,s7
     366:	00007517          	auipc	a0,0x7
     36a:	ad250513          	addi	a0,a0,-1326 # 6e38 <malloc+0x20c>
     36e:	00007097          	auipc	ra,0x7
     372:	800080e7          	jalr	-2048(ra) # 6b6e <printf>
        exit(1,"");
     376:	00008597          	auipc	a1,0x8
     37a:	fe258593          	addi	a1,a1,-30 # 8358 <malloc+0x172c>
     37e:	4505                	li	a0,1
     380:	00006097          	auipc	ra,0x6
     384:	446080e7          	jalr	1094(ra) # 67c6 <exit>

0000000000000388 <badwrite>:
// file is deleted? if the kernel has this bug, it will panic: balloc:
// out of blocks. assumed_free may need to be raised to be more than
// the number of free blocks. this test takes a long time.
void
badwrite(char *s)
{
     388:	7179                	addi	sp,sp,-48
     38a:	f406                	sd	ra,40(sp)
     38c:	f022                	sd	s0,32(sp)
     38e:	ec26                	sd	s1,24(sp)
     390:	e84a                	sd	s2,16(sp)
     392:	e44e                	sd	s3,8(sp)
     394:	e052                	sd	s4,0(sp)
     396:	1800                	addi	s0,sp,48
  int assumed_free = 600;
  
  unlink("junk");
     398:	00007517          	auipc	a0,0x7
     39c:	ab850513          	addi	a0,a0,-1352 # 6e50 <malloc+0x224>
     3a0:	00006097          	auipc	ra,0x6
     3a4:	476080e7          	jalr	1142(ra) # 6816 <unlink>
     3a8:	25800913          	li	s2,600
  for(int i = 0; i < assumed_free; i++){
    int fd = open("junk", O_CREATE|O_WRONLY);
     3ac:	00007997          	auipc	s3,0x7
     3b0:	aa498993          	addi	s3,s3,-1372 # 6e50 <malloc+0x224>
    if(fd < 0){
      printf("open junk failed\n");
      exit(1,"");
    }
    write(fd, (char*)0xffffffffffL, 1);
     3b4:	5a7d                	li	s4,-1
     3b6:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
     3ba:	20100593          	li	a1,513
     3be:	854e                	mv	a0,s3
     3c0:	00006097          	auipc	ra,0x6
     3c4:	446080e7          	jalr	1094(ra) # 6806 <open>
     3c8:	84aa                	mv	s1,a0
    if(fd < 0){
     3ca:	06054f63          	bltz	a0,448 <badwrite+0xc0>
    write(fd, (char*)0xffffffffffL, 1);
     3ce:	4605                	li	a2,1
     3d0:	85d2                	mv	a1,s4
     3d2:	00006097          	auipc	ra,0x6
     3d6:	414080e7          	jalr	1044(ra) # 67e6 <write>
    close(fd);
     3da:	8526                	mv	a0,s1
     3dc:	00006097          	auipc	ra,0x6
     3e0:	412080e7          	jalr	1042(ra) # 67ee <close>
    unlink("junk");
     3e4:	854e                	mv	a0,s3
     3e6:	00006097          	auipc	ra,0x6
     3ea:	430080e7          	jalr	1072(ra) # 6816 <unlink>
  for(int i = 0; i < assumed_free; i++){
     3ee:	397d                	addiw	s2,s2,-1
     3f0:	fc0915e3          	bnez	s2,3ba <badwrite+0x32>
  }

  int fd = open("junk", O_CREATE|O_WRONLY);
     3f4:	20100593          	li	a1,513
     3f8:	00007517          	auipc	a0,0x7
     3fc:	a5850513          	addi	a0,a0,-1448 # 6e50 <malloc+0x224>
     400:	00006097          	auipc	ra,0x6
     404:	406080e7          	jalr	1030(ra) # 6806 <open>
     408:	84aa                	mv	s1,a0
  if(fd < 0){
     40a:	06054063          	bltz	a0,46a <badwrite+0xe2>
    printf("open junk failed\n");
    exit(1,"");
  }
  if(write(fd, "x", 1) != 1){
     40e:	4605                	li	a2,1
     410:	00007597          	auipc	a1,0x7
     414:	9c858593          	addi	a1,a1,-1592 # 6dd8 <malloc+0x1ac>
     418:	00006097          	auipc	ra,0x6
     41c:	3ce080e7          	jalr	974(ra) # 67e6 <write>
     420:	4785                	li	a5,1
     422:	06f50563          	beq	a0,a5,48c <badwrite+0x104>
    printf("write failed\n");
     426:	00007517          	auipc	a0,0x7
     42a:	a4a50513          	addi	a0,a0,-1462 # 6e70 <malloc+0x244>
     42e:	00006097          	auipc	ra,0x6
     432:	740080e7          	jalr	1856(ra) # 6b6e <printf>
    exit(1,"");
     436:	00008597          	auipc	a1,0x8
     43a:	f2258593          	addi	a1,a1,-222 # 8358 <malloc+0x172c>
     43e:	4505                	li	a0,1
     440:	00006097          	auipc	ra,0x6
     444:	386080e7          	jalr	902(ra) # 67c6 <exit>
      printf("open junk failed\n");
     448:	00007517          	auipc	a0,0x7
     44c:	a1050513          	addi	a0,a0,-1520 # 6e58 <malloc+0x22c>
     450:	00006097          	auipc	ra,0x6
     454:	71e080e7          	jalr	1822(ra) # 6b6e <printf>
      exit(1,"");
     458:	00008597          	auipc	a1,0x8
     45c:	f0058593          	addi	a1,a1,-256 # 8358 <malloc+0x172c>
     460:	4505                	li	a0,1
     462:	00006097          	auipc	ra,0x6
     466:	364080e7          	jalr	868(ra) # 67c6 <exit>
    printf("open junk failed\n");
     46a:	00007517          	auipc	a0,0x7
     46e:	9ee50513          	addi	a0,a0,-1554 # 6e58 <malloc+0x22c>
     472:	00006097          	auipc	ra,0x6
     476:	6fc080e7          	jalr	1788(ra) # 6b6e <printf>
    exit(1,"");
     47a:	00008597          	auipc	a1,0x8
     47e:	ede58593          	addi	a1,a1,-290 # 8358 <malloc+0x172c>
     482:	4505                	li	a0,1
     484:	00006097          	auipc	ra,0x6
     488:	342080e7          	jalr	834(ra) # 67c6 <exit>
  }
  close(fd);
     48c:	8526                	mv	a0,s1
     48e:	00006097          	auipc	ra,0x6
     492:	360080e7          	jalr	864(ra) # 67ee <close>
  unlink("junk");
     496:	00007517          	auipc	a0,0x7
     49a:	9ba50513          	addi	a0,a0,-1606 # 6e50 <malloc+0x224>
     49e:	00006097          	auipc	ra,0x6
     4a2:	378080e7          	jalr	888(ra) # 6816 <unlink>

  exit(0,"");
     4a6:	00008597          	auipc	a1,0x8
     4aa:	eb258593          	addi	a1,a1,-334 # 8358 <malloc+0x172c>
     4ae:	4501                	li	a0,0
     4b0:	00006097          	auipc	ra,0x6
     4b4:	316080e7          	jalr	790(ra) # 67c6 <exit>

00000000000004b8 <outofinodes>:
  }
}

void
outofinodes(char *s)
{
     4b8:	715d                	addi	sp,sp,-80
     4ba:	e486                	sd	ra,72(sp)
     4bc:	e0a2                	sd	s0,64(sp)
     4be:	fc26                	sd	s1,56(sp)
     4c0:	f84a                	sd	s2,48(sp)
     4c2:	f44e                	sd	s3,40(sp)
     4c4:	0880                	addi	s0,sp,80
  int nzz = 32*32;
  for(int i = 0; i < nzz; i++){
     4c6:	4481                	li	s1,0
    char name[32];
    name[0] = 'z';
     4c8:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
     4cc:	40000993          	li	s3,1024
    name[0] = 'z';
     4d0:	fb240823          	sb	s2,-80(s0)
    name[1] = 'z';
     4d4:	fb2408a3          	sb	s2,-79(s0)
    name[2] = '0' + (i / 32);
     4d8:	41f4d79b          	sraiw	a5,s1,0x1f
     4dc:	01b7d71b          	srliw	a4,a5,0x1b
     4e0:	009707bb          	addw	a5,a4,s1
     4e4:	4057d69b          	sraiw	a3,a5,0x5
     4e8:	0306869b          	addiw	a3,a3,48
     4ec:	fad40923          	sb	a3,-78(s0)
    name[3] = '0' + (i % 32);
     4f0:	8bfd                	andi	a5,a5,31
     4f2:	9f99                	subw	a5,a5,a4
     4f4:	0307879b          	addiw	a5,a5,48
     4f8:	faf409a3          	sb	a5,-77(s0)
    name[4] = '\0';
     4fc:	fa040a23          	sb	zero,-76(s0)
    unlink(name);
     500:	fb040513          	addi	a0,s0,-80
     504:	00006097          	auipc	ra,0x6
     508:	312080e7          	jalr	786(ra) # 6816 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
     50c:	60200593          	li	a1,1538
     510:	fb040513          	addi	a0,s0,-80
     514:	00006097          	auipc	ra,0x6
     518:	2f2080e7          	jalr	754(ra) # 6806 <open>
    if(fd < 0){
     51c:	00054963          	bltz	a0,52e <outofinodes+0x76>
      // failure is eventually expected.
      break;
    }
    close(fd);
     520:	00006097          	auipc	ra,0x6
     524:	2ce080e7          	jalr	718(ra) # 67ee <close>
  for(int i = 0; i < nzz; i++){
     528:	2485                	addiw	s1,s1,1
     52a:	fb3493e3          	bne	s1,s3,4d0 <outofinodes+0x18>
     52e:	4481                	li	s1,0
  }

  for(int i = 0; i < nzz; i++){
    char name[32];
    name[0] = 'z';
     530:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
     534:	40000993          	li	s3,1024
    name[0] = 'z';
     538:	fb240823          	sb	s2,-80(s0)
    name[1] = 'z';
     53c:	fb2408a3          	sb	s2,-79(s0)
    name[2] = '0' + (i / 32);
     540:	41f4d79b          	sraiw	a5,s1,0x1f
     544:	01b7d71b          	srliw	a4,a5,0x1b
     548:	009707bb          	addw	a5,a4,s1
     54c:	4057d69b          	sraiw	a3,a5,0x5
     550:	0306869b          	addiw	a3,a3,48
     554:	fad40923          	sb	a3,-78(s0)
    name[3] = '0' + (i % 32);
     558:	8bfd                	andi	a5,a5,31
     55a:	9f99                	subw	a5,a5,a4
     55c:	0307879b          	addiw	a5,a5,48
     560:	faf409a3          	sb	a5,-77(s0)
    name[4] = '\0';
     564:	fa040a23          	sb	zero,-76(s0)
    unlink(name);
     568:	fb040513          	addi	a0,s0,-80
     56c:	00006097          	auipc	ra,0x6
     570:	2aa080e7          	jalr	682(ra) # 6816 <unlink>
  for(int i = 0; i < nzz; i++){
     574:	2485                	addiw	s1,s1,1
     576:	fd3491e3          	bne	s1,s3,538 <outofinodes+0x80>
  }
}
     57a:	60a6                	ld	ra,72(sp)
     57c:	6406                	ld	s0,64(sp)
     57e:	74e2                	ld	s1,56(sp)
     580:	7942                	ld	s2,48(sp)
     582:	79a2                	ld	s3,40(sp)
     584:	6161                	addi	sp,sp,80
     586:	8082                	ret

0000000000000588 <copyin>:
{
     588:	715d                	addi	sp,sp,-80
     58a:	e486                	sd	ra,72(sp)
     58c:	e0a2                	sd	s0,64(sp)
     58e:	fc26                	sd	s1,56(sp)
     590:	f84a                	sd	s2,48(sp)
     592:	f44e                	sd	s3,40(sp)
     594:	f052                	sd	s4,32(sp)
     596:	0880                	addi	s0,sp,80
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     598:	4785                	li	a5,1
     59a:	07fe                	slli	a5,a5,0x1f
     59c:	fcf43023          	sd	a5,-64(s0)
     5a0:	57fd                	li	a5,-1
     5a2:	fcf43423          	sd	a5,-56(s0)
  for(int ai = 0; ai < 2; ai++){
     5a6:	fc040913          	addi	s2,s0,-64
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     5aa:	00007a17          	auipc	s4,0x7
     5ae:	8d6a0a13          	addi	s4,s4,-1834 # 6e80 <malloc+0x254>
    uint64 addr = addrs[ai];
     5b2:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     5b6:	20100593          	li	a1,513
     5ba:	8552                	mv	a0,s4
     5bc:	00006097          	auipc	ra,0x6
     5c0:	24a080e7          	jalr	586(ra) # 6806 <open>
     5c4:	84aa                	mv	s1,a0
    if(fd < 0){
     5c6:	08054863          	bltz	a0,656 <copyin+0xce>
    int n = write(fd, (void*)addr, 8192);
     5ca:	6609                	lui	a2,0x2
     5cc:	85ce                	mv	a1,s3
     5ce:	00006097          	auipc	ra,0x6
     5d2:	218080e7          	jalr	536(ra) # 67e6 <write>
    if(n >= 0){
     5d6:	0a055163          	bgez	a0,678 <copyin+0xf0>
    close(fd);
     5da:	8526                	mv	a0,s1
     5dc:	00006097          	auipc	ra,0x6
     5e0:	212080e7          	jalr	530(ra) # 67ee <close>
    unlink("copyin1");
     5e4:	8552                	mv	a0,s4
     5e6:	00006097          	auipc	ra,0x6
     5ea:	230080e7          	jalr	560(ra) # 6816 <unlink>
    n = write(1, (char*)addr, 8192);
     5ee:	6609                	lui	a2,0x2
     5f0:	85ce                	mv	a1,s3
     5f2:	4505                	li	a0,1
     5f4:	00006097          	auipc	ra,0x6
     5f8:	1f2080e7          	jalr	498(ra) # 67e6 <write>
    if(n > 0){
     5fc:	0aa04163          	bgtz	a0,69e <copyin+0x116>
    if(pipe(fds) < 0){
     600:	fb840513          	addi	a0,s0,-72
     604:	00006097          	auipc	ra,0x6
     608:	1d2080e7          	jalr	466(ra) # 67d6 <pipe>
     60c:	0a054c63          	bltz	a0,6c4 <copyin+0x13c>
    n = write(fds[1], (char*)addr, 8192);
     610:	6609                	lui	a2,0x2
     612:	85ce                	mv	a1,s3
     614:	fbc42503          	lw	a0,-68(s0)
     618:	00006097          	auipc	ra,0x6
     61c:	1ce080e7          	jalr	462(ra) # 67e6 <write>
    if(n > 0){
     620:	0ca04363          	bgtz	a0,6e6 <copyin+0x15e>
    close(fds[0]);
     624:	fb842503          	lw	a0,-72(s0)
     628:	00006097          	auipc	ra,0x6
     62c:	1c6080e7          	jalr	454(ra) # 67ee <close>
    close(fds[1]);
     630:	fbc42503          	lw	a0,-68(s0)
     634:	00006097          	auipc	ra,0x6
     638:	1ba080e7          	jalr	442(ra) # 67ee <close>
  for(int ai = 0; ai < 2; ai++){
     63c:	0921                	addi	s2,s2,8
     63e:	fd040793          	addi	a5,s0,-48
     642:	f6f918e3          	bne	s2,a5,5b2 <copyin+0x2a>
}
     646:	60a6                	ld	ra,72(sp)
     648:	6406                	ld	s0,64(sp)
     64a:	74e2                	ld	s1,56(sp)
     64c:	7942                	ld	s2,48(sp)
     64e:	79a2                	ld	s3,40(sp)
     650:	7a02                	ld	s4,32(sp)
     652:	6161                	addi	sp,sp,80
     654:	8082                	ret
      printf("open(copyin1) failed\n");
     656:	00007517          	auipc	a0,0x7
     65a:	83250513          	addi	a0,a0,-1998 # 6e88 <malloc+0x25c>
     65e:	00006097          	auipc	ra,0x6
     662:	510080e7          	jalr	1296(ra) # 6b6e <printf>
      exit(1,"");
     666:	00008597          	auipc	a1,0x8
     66a:	cf258593          	addi	a1,a1,-782 # 8358 <malloc+0x172c>
     66e:	4505                	li	a0,1
     670:	00006097          	auipc	ra,0x6
     674:	156080e7          	jalr	342(ra) # 67c6 <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
     678:	862a                	mv	a2,a0
     67a:	85ce                	mv	a1,s3
     67c:	00007517          	auipc	a0,0x7
     680:	82450513          	addi	a0,a0,-2012 # 6ea0 <malloc+0x274>
     684:	00006097          	auipc	ra,0x6
     688:	4ea080e7          	jalr	1258(ra) # 6b6e <printf>
      exit(1,"");
     68c:	00008597          	auipc	a1,0x8
     690:	ccc58593          	addi	a1,a1,-820 # 8358 <malloc+0x172c>
     694:	4505                	li	a0,1
     696:	00006097          	auipc	ra,0x6
     69a:	130080e7          	jalr	304(ra) # 67c6 <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     69e:	862a                	mv	a2,a0
     6a0:	85ce                	mv	a1,s3
     6a2:	00007517          	auipc	a0,0x7
     6a6:	82e50513          	addi	a0,a0,-2002 # 6ed0 <malloc+0x2a4>
     6aa:	00006097          	auipc	ra,0x6
     6ae:	4c4080e7          	jalr	1220(ra) # 6b6e <printf>
      exit(1,"");
     6b2:	00008597          	auipc	a1,0x8
     6b6:	ca658593          	addi	a1,a1,-858 # 8358 <malloc+0x172c>
     6ba:	4505                	li	a0,1
     6bc:	00006097          	auipc	ra,0x6
     6c0:	10a080e7          	jalr	266(ra) # 67c6 <exit>
      printf("pipe() failed\n");
     6c4:	00007517          	auipc	a0,0x7
     6c8:	83c50513          	addi	a0,a0,-1988 # 6f00 <malloc+0x2d4>
     6cc:	00006097          	auipc	ra,0x6
     6d0:	4a2080e7          	jalr	1186(ra) # 6b6e <printf>
      exit(1,"");
     6d4:	00008597          	auipc	a1,0x8
     6d8:	c8458593          	addi	a1,a1,-892 # 8358 <malloc+0x172c>
     6dc:	4505                	li	a0,1
     6de:	00006097          	auipc	ra,0x6
     6e2:	0e8080e7          	jalr	232(ra) # 67c6 <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     6e6:	862a                	mv	a2,a0
     6e8:	85ce                	mv	a1,s3
     6ea:	00007517          	auipc	a0,0x7
     6ee:	82650513          	addi	a0,a0,-2010 # 6f10 <malloc+0x2e4>
     6f2:	00006097          	auipc	ra,0x6
     6f6:	47c080e7          	jalr	1148(ra) # 6b6e <printf>
      exit(1,"");
     6fa:	00008597          	auipc	a1,0x8
     6fe:	c5e58593          	addi	a1,a1,-930 # 8358 <malloc+0x172c>
     702:	4505                	li	a0,1
     704:	00006097          	auipc	ra,0x6
     708:	0c2080e7          	jalr	194(ra) # 67c6 <exit>

000000000000070c <copyout>:
{
     70c:	711d                	addi	sp,sp,-96
     70e:	ec86                	sd	ra,88(sp)
     710:	e8a2                	sd	s0,80(sp)
     712:	e4a6                	sd	s1,72(sp)
     714:	e0ca                	sd	s2,64(sp)
     716:	fc4e                	sd	s3,56(sp)
     718:	f852                	sd	s4,48(sp)
     71a:	f456                	sd	s5,40(sp)
     71c:	1080                	addi	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     71e:	4785                	li	a5,1
     720:	07fe                	slli	a5,a5,0x1f
     722:	faf43823          	sd	a5,-80(s0)
     726:	57fd                	li	a5,-1
     728:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < 2; ai++){
     72c:	fb040913          	addi	s2,s0,-80
    int fd = open("README", 0);
     730:	00007a17          	auipc	s4,0x7
     734:	810a0a13          	addi	s4,s4,-2032 # 6f40 <malloc+0x314>
    n = write(fds[1], "x", 1);
     738:	00006a97          	auipc	s5,0x6
     73c:	6a0a8a93          	addi	s5,s5,1696 # 6dd8 <malloc+0x1ac>
    uint64 addr = addrs[ai];
     740:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     744:	4581                	li	a1,0
     746:	8552                	mv	a0,s4
     748:	00006097          	auipc	ra,0x6
     74c:	0be080e7          	jalr	190(ra) # 6806 <open>
     750:	84aa                	mv	s1,a0
    if(fd < 0){
     752:	08054663          	bltz	a0,7de <copyout+0xd2>
    int n = read(fd, (void*)addr, 8192);
     756:	6609                	lui	a2,0x2
     758:	85ce                	mv	a1,s3
     75a:	00006097          	auipc	ra,0x6
     75e:	084080e7          	jalr	132(ra) # 67de <read>
    if(n > 0){
     762:	08a04f63          	bgtz	a0,800 <copyout+0xf4>
    close(fd);
     766:	8526                	mv	a0,s1
     768:	00006097          	auipc	ra,0x6
     76c:	086080e7          	jalr	134(ra) # 67ee <close>
    if(pipe(fds) < 0){
     770:	fa840513          	addi	a0,s0,-88
     774:	00006097          	auipc	ra,0x6
     778:	062080e7          	jalr	98(ra) # 67d6 <pipe>
     77c:	0a054563          	bltz	a0,826 <copyout+0x11a>
    n = write(fds[1], "x", 1);
     780:	4605                	li	a2,1
     782:	85d6                	mv	a1,s5
     784:	fac42503          	lw	a0,-84(s0)
     788:	00006097          	auipc	ra,0x6
     78c:	05e080e7          	jalr	94(ra) # 67e6 <write>
    if(n != 1){
     790:	4785                	li	a5,1
     792:	0af51b63          	bne	a0,a5,848 <copyout+0x13c>
    n = read(fds[0], (void*)addr, 8192);
     796:	6609                	lui	a2,0x2
     798:	85ce                	mv	a1,s3
     79a:	fa842503          	lw	a0,-88(s0)
     79e:	00006097          	auipc	ra,0x6
     7a2:	040080e7          	jalr	64(ra) # 67de <read>
    if(n > 0){
     7a6:	0ca04263          	bgtz	a0,86a <copyout+0x15e>
    close(fds[0]);
     7aa:	fa842503          	lw	a0,-88(s0)
     7ae:	00006097          	auipc	ra,0x6
     7b2:	040080e7          	jalr	64(ra) # 67ee <close>
    close(fds[1]);
     7b6:	fac42503          	lw	a0,-84(s0)
     7ba:	00006097          	auipc	ra,0x6
     7be:	034080e7          	jalr	52(ra) # 67ee <close>
  for(int ai = 0; ai < 2; ai++){
     7c2:	0921                	addi	s2,s2,8
     7c4:	fc040793          	addi	a5,s0,-64
     7c8:	f6f91ce3          	bne	s2,a5,740 <copyout+0x34>
}
     7cc:	60e6                	ld	ra,88(sp)
     7ce:	6446                	ld	s0,80(sp)
     7d0:	64a6                	ld	s1,72(sp)
     7d2:	6906                	ld	s2,64(sp)
     7d4:	79e2                	ld	s3,56(sp)
     7d6:	7a42                	ld	s4,48(sp)
     7d8:	7aa2                	ld	s5,40(sp)
     7da:	6125                	addi	sp,sp,96
     7dc:	8082                	ret
      printf("open(README) failed\n");
     7de:	00006517          	auipc	a0,0x6
     7e2:	76a50513          	addi	a0,a0,1898 # 6f48 <malloc+0x31c>
     7e6:	00006097          	auipc	ra,0x6
     7ea:	388080e7          	jalr	904(ra) # 6b6e <printf>
      exit(1,"");
     7ee:	00008597          	auipc	a1,0x8
     7f2:	b6a58593          	addi	a1,a1,-1174 # 8358 <malloc+0x172c>
     7f6:	4505                	li	a0,1
     7f8:	00006097          	auipc	ra,0x6
     7fc:	fce080e7          	jalr	-50(ra) # 67c6 <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     800:	862a                	mv	a2,a0
     802:	85ce                	mv	a1,s3
     804:	00006517          	auipc	a0,0x6
     808:	75c50513          	addi	a0,a0,1884 # 6f60 <malloc+0x334>
     80c:	00006097          	auipc	ra,0x6
     810:	362080e7          	jalr	866(ra) # 6b6e <printf>
      exit(1,"");
     814:	00008597          	auipc	a1,0x8
     818:	b4458593          	addi	a1,a1,-1212 # 8358 <malloc+0x172c>
     81c:	4505                	li	a0,1
     81e:	00006097          	auipc	ra,0x6
     822:	fa8080e7          	jalr	-88(ra) # 67c6 <exit>
      printf("pipe() failed\n");
     826:	00006517          	auipc	a0,0x6
     82a:	6da50513          	addi	a0,a0,1754 # 6f00 <malloc+0x2d4>
     82e:	00006097          	auipc	ra,0x6
     832:	340080e7          	jalr	832(ra) # 6b6e <printf>
      exit(1,"");
     836:	00008597          	auipc	a1,0x8
     83a:	b2258593          	addi	a1,a1,-1246 # 8358 <malloc+0x172c>
     83e:	4505                	li	a0,1
     840:	00006097          	auipc	ra,0x6
     844:	f86080e7          	jalr	-122(ra) # 67c6 <exit>
      printf("pipe write failed\n");
     848:	00006517          	auipc	a0,0x6
     84c:	74850513          	addi	a0,a0,1864 # 6f90 <malloc+0x364>
     850:	00006097          	auipc	ra,0x6
     854:	31e080e7          	jalr	798(ra) # 6b6e <printf>
      exit(1,"");
     858:	00008597          	auipc	a1,0x8
     85c:	b0058593          	addi	a1,a1,-1280 # 8358 <malloc+0x172c>
     860:	4505                	li	a0,1
     862:	00006097          	auipc	ra,0x6
     866:	f64080e7          	jalr	-156(ra) # 67c6 <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     86a:	862a                	mv	a2,a0
     86c:	85ce                	mv	a1,s3
     86e:	00006517          	auipc	a0,0x6
     872:	73a50513          	addi	a0,a0,1850 # 6fa8 <malloc+0x37c>
     876:	00006097          	auipc	ra,0x6
     87a:	2f8080e7          	jalr	760(ra) # 6b6e <printf>
      exit(1,"");
     87e:	00008597          	auipc	a1,0x8
     882:	ada58593          	addi	a1,a1,-1318 # 8358 <malloc+0x172c>
     886:	4505                	li	a0,1
     888:	00006097          	auipc	ra,0x6
     88c:	f3e080e7          	jalr	-194(ra) # 67c6 <exit>

0000000000000890 <truncate1>:
{
     890:	711d                	addi	sp,sp,-96
     892:	ec86                	sd	ra,88(sp)
     894:	e8a2                	sd	s0,80(sp)
     896:	e4a6                	sd	s1,72(sp)
     898:	e0ca                	sd	s2,64(sp)
     89a:	fc4e                	sd	s3,56(sp)
     89c:	f852                	sd	s4,48(sp)
     89e:	f456                	sd	s5,40(sp)
     8a0:	1080                	addi	s0,sp,96
     8a2:	8aaa                	mv	s5,a0
  unlink("truncfile");
     8a4:	00006517          	auipc	a0,0x6
     8a8:	51c50513          	addi	a0,a0,1308 # 6dc0 <malloc+0x194>
     8ac:	00006097          	auipc	ra,0x6
     8b0:	f6a080e7          	jalr	-150(ra) # 6816 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     8b4:	60100593          	li	a1,1537
     8b8:	00006517          	auipc	a0,0x6
     8bc:	50850513          	addi	a0,a0,1288 # 6dc0 <malloc+0x194>
     8c0:	00006097          	auipc	ra,0x6
     8c4:	f46080e7          	jalr	-186(ra) # 6806 <open>
     8c8:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     8ca:	4611                	li	a2,4
     8cc:	00006597          	auipc	a1,0x6
     8d0:	50458593          	addi	a1,a1,1284 # 6dd0 <malloc+0x1a4>
     8d4:	00006097          	auipc	ra,0x6
     8d8:	f12080e7          	jalr	-238(ra) # 67e6 <write>
  close(fd1);
     8dc:	8526                	mv	a0,s1
     8de:	00006097          	auipc	ra,0x6
     8e2:	f10080e7          	jalr	-240(ra) # 67ee <close>
  int fd2 = open("truncfile", O_RDONLY);
     8e6:	4581                	li	a1,0
     8e8:	00006517          	auipc	a0,0x6
     8ec:	4d850513          	addi	a0,a0,1240 # 6dc0 <malloc+0x194>
     8f0:	00006097          	auipc	ra,0x6
     8f4:	f16080e7          	jalr	-234(ra) # 6806 <open>
     8f8:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     8fa:	02000613          	li	a2,32
     8fe:	fa040593          	addi	a1,s0,-96
     902:	00006097          	auipc	ra,0x6
     906:	edc080e7          	jalr	-292(ra) # 67de <read>
  if(n != 4){
     90a:	4791                	li	a5,4
     90c:	0cf51e63          	bne	a0,a5,9e8 <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     910:	40100593          	li	a1,1025
     914:	00006517          	auipc	a0,0x6
     918:	4ac50513          	addi	a0,a0,1196 # 6dc0 <malloc+0x194>
     91c:	00006097          	auipc	ra,0x6
     920:	eea080e7          	jalr	-278(ra) # 6806 <open>
     924:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     926:	4581                	li	a1,0
     928:	00006517          	auipc	a0,0x6
     92c:	49850513          	addi	a0,a0,1176 # 6dc0 <malloc+0x194>
     930:	00006097          	auipc	ra,0x6
     934:	ed6080e7          	jalr	-298(ra) # 6806 <open>
     938:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     93a:	02000613          	li	a2,32
     93e:	fa040593          	addi	a1,s0,-96
     942:	00006097          	auipc	ra,0x6
     946:	e9c080e7          	jalr	-356(ra) # 67de <read>
     94a:	8a2a                	mv	s4,a0
  if(n != 0){
     94c:	e169                	bnez	a0,a0e <truncate1+0x17e>
  n = read(fd2, buf, sizeof(buf));
     94e:	02000613          	li	a2,32
     952:	fa040593          	addi	a1,s0,-96
     956:	8526                	mv	a0,s1
     958:	00006097          	auipc	ra,0x6
     95c:	e86080e7          	jalr	-378(ra) # 67de <read>
     960:	8a2a                	mv	s4,a0
  if(n != 0){
     962:	e175                	bnez	a0,a46 <truncate1+0x1b6>
  write(fd1, "abcdef", 6);
     964:	4619                	li	a2,6
     966:	00006597          	auipc	a1,0x6
     96a:	6d258593          	addi	a1,a1,1746 # 7038 <malloc+0x40c>
     96e:	854e                	mv	a0,s3
     970:	00006097          	auipc	ra,0x6
     974:	e76080e7          	jalr	-394(ra) # 67e6 <write>
  n = read(fd3, buf, sizeof(buf));
     978:	02000613          	li	a2,32
     97c:	fa040593          	addi	a1,s0,-96
     980:	854a                	mv	a0,s2
     982:	00006097          	auipc	ra,0x6
     986:	e5c080e7          	jalr	-420(ra) # 67de <read>
  if(n != 6){
     98a:	4799                	li	a5,6
     98c:	0ef51963          	bne	a0,a5,a7e <truncate1+0x1ee>
  n = read(fd2, buf, sizeof(buf));
     990:	02000613          	li	a2,32
     994:	fa040593          	addi	a1,s0,-96
     998:	8526                	mv	a0,s1
     99a:	00006097          	auipc	ra,0x6
     99e:	e44080e7          	jalr	-444(ra) # 67de <read>
  if(n != 2){
     9a2:	4789                	li	a5,2
     9a4:	10f51063          	bne	a0,a5,aa4 <truncate1+0x214>
  unlink("truncfile");
     9a8:	00006517          	auipc	a0,0x6
     9ac:	41850513          	addi	a0,a0,1048 # 6dc0 <malloc+0x194>
     9b0:	00006097          	auipc	ra,0x6
     9b4:	e66080e7          	jalr	-410(ra) # 6816 <unlink>
  close(fd1);
     9b8:	854e                	mv	a0,s3
     9ba:	00006097          	auipc	ra,0x6
     9be:	e34080e7          	jalr	-460(ra) # 67ee <close>
  close(fd2);
     9c2:	8526                	mv	a0,s1
     9c4:	00006097          	auipc	ra,0x6
     9c8:	e2a080e7          	jalr	-470(ra) # 67ee <close>
  close(fd3);
     9cc:	854a                	mv	a0,s2
     9ce:	00006097          	auipc	ra,0x6
     9d2:	e20080e7          	jalr	-480(ra) # 67ee <close>
}
     9d6:	60e6                	ld	ra,88(sp)
     9d8:	6446                	ld	s0,80(sp)
     9da:	64a6                	ld	s1,72(sp)
     9dc:	6906                	ld	s2,64(sp)
     9de:	79e2                	ld	s3,56(sp)
     9e0:	7a42                	ld	s4,48(sp)
     9e2:	7aa2                	ld	s5,40(sp)
     9e4:	6125                	addi	sp,sp,96
     9e6:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     9e8:	862a                	mv	a2,a0
     9ea:	85d6                	mv	a1,s5
     9ec:	00006517          	auipc	a0,0x6
     9f0:	5ec50513          	addi	a0,a0,1516 # 6fd8 <malloc+0x3ac>
     9f4:	00006097          	auipc	ra,0x6
     9f8:	17a080e7          	jalr	378(ra) # 6b6e <printf>
    exit(1,"");
     9fc:	00008597          	auipc	a1,0x8
     a00:	95c58593          	addi	a1,a1,-1700 # 8358 <malloc+0x172c>
     a04:	4505                	li	a0,1
     a06:	00006097          	auipc	ra,0x6
     a0a:	dc0080e7          	jalr	-576(ra) # 67c6 <exit>
    printf("aaa fd3=%d\n", fd3);
     a0e:	85ca                	mv	a1,s2
     a10:	00006517          	auipc	a0,0x6
     a14:	5e850513          	addi	a0,a0,1512 # 6ff8 <malloc+0x3cc>
     a18:	00006097          	auipc	ra,0x6
     a1c:	156080e7          	jalr	342(ra) # 6b6e <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     a20:	8652                	mv	a2,s4
     a22:	85d6                	mv	a1,s5
     a24:	00006517          	auipc	a0,0x6
     a28:	5e450513          	addi	a0,a0,1508 # 7008 <malloc+0x3dc>
     a2c:	00006097          	auipc	ra,0x6
     a30:	142080e7          	jalr	322(ra) # 6b6e <printf>
    exit(1,"");
     a34:	00008597          	auipc	a1,0x8
     a38:	92458593          	addi	a1,a1,-1756 # 8358 <malloc+0x172c>
     a3c:	4505                	li	a0,1
     a3e:	00006097          	auipc	ra,0x6
     a42:	d88080e7          	jalr	-632(ra) # 67c6 <exit>
    printf("bbb fd2=%d\n", fd2);
     a46:	85a6                	mv	a1,s1
     a48:	00006517          	auipc	a0,0x6
     a4c:	5e050513          	addi	a0,a0,1504 # 7028 <malloc+0x3fc>
     a50:	00006097          	auipc	ra,0x6
     a54:	11e080e7          	jalr	286(ra) # 6b6e <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     a58:	8652                	mv	a2,s4
     a5a:	85d6                	mv	a1,s5
     a5c:	00006517          	auipc	a0,0x6
     a60:	5ac50513          	addi	a0,a0,1452 # 7008 <malloc+0x3dc>
     a64:	00006097          	auipc	ra,0x6
     a68:	10a080e7          	jalr	266(ra) # 6b6e <printf>
    exit(1,"");
     a6c:	00008597          	auipc	a1,0x8
     a70:	8ec58593          	addi	a1,a1,-1812 # 8358 <malloc+0x172c>
     a74:	4505                	li	a0,1
     a76:	00006097          	auipc	ra,0x6
     a7a:	d50080e7          	jalr	-688(ra) # 67c6 <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     a7e:	862a                	mv	a2,a0
     a80:	85d6                	mv	a1,s5
     a82:	00006517          	auipc	a0,0x6
     a86:	5be50513          	addi	a0,a0,1470 # 7040 <malloc+0x414>
     a8a:	00006097          	auipc	ra,0x6
     a8e:	0e4080e7          	jalr	228(ra) # 6b6e <printf>
    exit(1,"");
     a92:	00008597          	auipc	a1,0x8
     a96:	8c658593          	addi	a1,a1,-1850 # 8358 <malloc+0x172c>
     a9a:	4505                	li	a0,1
     a9c:	00006097          	auipc	ra,0x6
     aa0:	d2a080e7          	jalr	-726(ra) # 67c6 <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     aa4:	862a                	mv	a2,a0
     aa6:	85d6                	mv	a1,s5
     aa8:	00006517          	auipc	a0,0x6
     aac:	5b850513          	addi	a0,a0,1464 # 7060 <malloc+0x434>
     ab0:	00006097          	auipc	ra,0x6
     ab4:	0be080e7          	jalr	190(ra) # 6b6e <printf>
    exit(1,"");
     ab8:	00008597          	auipc	a1,0x8
     abc:	8a058593          	addi	a1,a1,-1888 # 8358 <malloc+0x172c>
     ac0:	4505                	li	a0,1
     ac2:	00006097          	auipc	ra,0x6
     ac6:	d04080e7          	jalr	-764(ra) # 67c6 <exit>

0000000000000aca <writetest>:
{
     aca:	7139                	addi	sp,sp,-64
     acc:	fc06                	sd	ra,56(sp)
     ace:	f822                	sd	s0,48(sp)
     ad0:	f426                	sd	s1,40(sp)
     ad2:	f04a                	sd	s2,32(sp)
     ad4:	ec4e                	sd	s3,24(sp)
     ad6:	e852                	sd	s4,16(sp)
     ad8:	e456                	sd	s5,8(sp)
     ada:	e05a                	sd	s6,0(sp)
     adc:	0080                	addi	s0,sp,64
     ade:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE|O_RDWR);
     ae0:	20200593          	li	a1,514
     ae4:	00006517          	auipc	a0,0x6
     ae8:	59c50513          	addi	a0,a0,1436 # 7080 <malloc+0x454>
     aec:	00006097          	auipc	ra,0x6
     af0:	d1a080e7          	jalr	-742(ra) # 6806 <open>
  if(fd < 0){
     af4:	0a054d63          	bltz	a0,bae <writetest+0xe4>
     af8:	892a                	mv	s2,a0
     afa:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     afc:	00006997          	auipc	s3,0x6
     b00:	5ac98993          	addi	s3,s3,1452 # 70a8 <malloc+0x47c>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     b04:	00006a97          	auipc	s5,0x6
     b08:	5dca8a93          	addi	s5,s5,1500 # 70e0 <malloc+0x4b4>
  for(i = 0; i < N; i++){
     b0c:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     b10:	4629                	li	a2,10
     b12:	85ce                	mv	a1,s3
     b14:	854a                	mv	a0,s2
     b16:	00006097          	auipc	ra,0x6
     b1a:	cd0080e7          	jalr	-816(ra) # 67e6 <write>
     b1e:	47a9                	li	a5,10
     b20:	0af51963          	bne	a0,a5,bd2 <writetest+0x108>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     b24:	4629                	li	a2,10
     b26:	85d6                	mv	a1,s5
     b28:	854a                	mv	a0,s2
     b2a:	00006097          	auipc	ra,0x6
     b2e:	cbc080e7          	jalr	-836(ra) # 67e6 <write>
     b32:	47a9                	li	a5,10
     b34:	0cf51263          	bne	a0,a5,bf8 <writetest+0x12e>
  for(i = 0; i < N; i++){
     b38:	2485                	addiw	s1,s1,1
     b3a:	fd449be3          	bne	s1,s4,b10 <writetest+0x46>
  close(fd);
     b3e:	854a                	mv	a0,s2
     b40:	00006097          	auipc	ra,0x6
     b44:	cae080e7          	jalr	-850(ra) # 67ee <close>
  fd = open("small", O_RDONLY);
     b48:	4581                	li	a1,0
     b4a:	00006517          	auipc	a0,0x6
     b4e:	53650513          	addi	a0,a0,1334 # 7080 <malloc+0x454>
     b52:	00006097          	auipc	ra,0x6
     b56:	cb4080e7          	jalr	-844(ra) # 6806 <open>
     b5a:	84aa                	mv	s1,a0
  if(fd < 0){
     b5c:	0c054163          	bltz	a0,c1e <writetest+0x154>
  i = read(fd, buf, N*SZ*2);
     b60:	7d000613          	li	a2,2000
     b64:	0000d597          	auipc	a1,0xd
     b68:	11458593          	addi	a1,a1,276 # dc78 <buf>
     b6c:	00006097          	auipc	ra,0x6
     b70:	c72080e7          	jalr	-910(ra) # 67de <read>
  if(i != N*SZ*2){
     b74:	7d000793          	li	a5,2000
     b78:	0cf51563          	bne	a0,a5,c42 <writetest+0x178>
  close(fd);
     b7c:	8526                	mv	a0,s1
     b7e:	00006097          	auipc	ra,0x6
     b82:	c70080e7          	jalr	-912(ra) # 67ee <close>
  if(unlink("small") < 0){
     b86:	00006517          	auipc	a0,0x6
     b8a:	4fa50513          	addi	a0,a0,1274 # 7080 <malloc+0x454>
     b8e:	00006097          	auipc	ra,0x6
     b92:	c88080e7          	jalr	-888(ra) # 6816 <unlink>
     b96:	0c054863          	bltz	a0,c66 <writetest+0x19c>
}
     b9a:	70e2                	ld	ra,56(sp)
     b9c:	7442                	ld	s0,48(sp)
     b9e:	74a2                	ld	s1,40(sp)
     ba0:	7902                	ld	s2,32(sp)
     ba2:	69e2                	ld	s3,24(sp)
     ba4:	6a42                	ld	s4,16(sp)
     ba6:	6aa2                	ld	s5,8(sp)
     ba8:	6b02                	ld	s6,0(sp)
     baa:	6121                	addi	sp,sp,64
     bac:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     bae:	85da                	mv	a1,s6
     bb0:	00006517          	auipc	a0,0x6
     bb4:	4d850513          	addi	a0,a0,1240 # 7088 <malloc+0x45c>
     bb8:	00006097          	auipc	ra,0x6
     bbc:	fb6080e7          	jalr	-74(ra) # 6b6e <printf>
    exit(1,"");
     bc0:	00007597          	auipc	a1,0x7
     bc4:	79858593          	addi	a1,a1,1944 # 8358 <malloc+0x172c>
     bc8:	4505                	li	a0,1
     bca:	00006097          	auipc	ra,0x6
     bce:	bfc080e7          	jalr	-1028(ra) # 67c6 <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
     bd2:	8626                	mv	a2,s1
     bd4:	85da                	mv	a1,s6
     bd6:	00006517          	auipc	a0,0x6
     bda:	4e250513          	addi	a0,a0,1250 # 70b8 <malloc+0x48c>
     bde:	00006097          	auipc	ra,0x6
     be2:	f90080e7          	jalr	-112(ra) # 6b6e <printf>
      exit(1,"");
     be6:	00007597          	auipc	a1,0x7
     bea:	77258593          	addi	a1,a1,1906 # 8358 <malloc+0x172c>
     bee:	4505                	li	a0,1
     bf0:	00006097          	auipc	ra,0x6
     bf4:	bd6080e7          	jalr	-1066(ra) # 67c6 <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
     bf8:	8626                	mv	a2,s1
     bfa:	85da                	mv	a1,s6
     bfc:	00006517          	auipc	a0,0x6
     c00:	4f450513          	addi	a0,a0,1268 # 70f0 <malloc+0x4c4>
     c04:	00006097          	auipc	ra,0x6
     c08:	f6a080e7          	jalr	-150(ra) # 6b6e <printf>
      exit(1,"");
     c0c:	00007597          	auipc	a1,0x7
     c10:	74c58593          	addi	a1,a1,1868 # 8358 <malloc+0x172c>
     c14:	4505                	li	a0,1
     c16:	00006097          	auipc	ra,0x6
     c1a:	bb0080e7          	jalr	-1104(ra) # 67c6 <exit>
    printf("%s: error: open small failed!\n", s);
     c1e:	85da                	mv	a1,s6
     c20:	00006517          	auipc	a0,0x6
     c24:	4f850513          	addi	a0,a0,1272 # 7118 <malloc+0x4ec>
     c28:	00006097          	auipc	ra,0x6
     c2c:	f46080e7          	jalr	-186(ra) # 6b6e <printf>
    exit(1,"");
     c30:	00007597          	auipc	a1,0x7
     c34:	72858593          	addi	a1,a1,1832 # 8358 <malloc+0x172c>
     c38:	4505                	li	a0,1
     c3a:	00006097          	auipc	ra,0x6
     c3e:	b8c080e7          	jalr	-1140(ra) # 67c6 <exit>
    printf("%s: read failed\n", s);
     c42:	85da                	mv	a1,s6
     c44:	00006517          	auipc	a0,0x6
     c48:	4f450513          	addi	a0,a0,1268 # 7138 <malloc+0x50c>
     c4c:	00006097          	auipc	ra,0x6
     c50:	f22080e7          	jalr	-222(ra) # 6b6e <printf>
    exit(1,"");
     c54:	00007597          	auipc	a1,0x7
     c58:	70458593          	addi	a1,a1,1796 # 8358 <malloc+0x172c>
     c5c:	4505                	li	a0,1
     c5e:	00006097          	auipc	ra,0x6
     c62:	b68080e7          	jalr	-1176(ra) # 67c6 <exit>
    printf("%s: unlink small failed\n", s);
     c66:	85da                	mv	a1,s6
     c68:	00006517          	auipc	a0,0x6
     c6c:	4e850513          	addi	a0,a0,1256 # 7150 <malloc+0x524>
     c70:	00006097          	auipc	ra,0x6
     c74:	efe080e7          	jalr	-258(ra) # 6b6e <printf>
    exit(1,"");
     c78:	00007597          	auipc	a1,0x7
     c7c:	6e058593          	addi	a1,a1,1760 # 8358 <malloc+0x172c>
     c80:	4505                	li	a0,1
     c82:	00006097          	auipc	ra,0x6
     c86:	b44080e7          	jalr	-1212(ra) # 67c6 <exit>

0000000000000c8a <writebig>:
{
     c8a:	7139                	addi	sp,sp,-64
     c8c:	fc06                	sd	ra,56(sp)
     c8e:	f822                	sd	s0,48(sp)
     c90:	f426                	sd	s1,40(sp)
     c92:	f04a                	sd	s2,32(sp)
     c94:	ec4e                	sd	s3,24(sp)
     c96:	e852                	sd	s4,16(sp)
     c98:	e456                	sd	s5,8(sp)
     c9a:	0080                	addi	s0,sp,64
     c9c:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE|O_RDWR);
     c9e:	20200593          	li	a1,514
     ca2:	00006517          	auipc	a0,0x6
     ca6:	4ce50513          	addi	a0,a0,1230 # 7170 <malloc+0x544>
     caa:	00006097          	auipc	ra,0x6
     cae:	b5c080e7          	jalr	-1188(ra) # 6806 <open>
     cb2:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
     cb4:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     cb6:	0000d917          	auipc	s2,0xd
     cba:	fc290913          	addi	s2,s2,-62 # dc78 <buf>
  for(i = 0; i < MAXFILE; i++){
     cbe:	10c00a13          	li	s4,268
  if(fd < 0){
     cc2:	06054c63          	bltz	a0,d3a <writebig+0xb0>
    ((int*)buf)[0] = i;
     cc6:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
     cca:	40000613          	li	a2,1024
     cce:	85ca                	mv	a1,s2
     cd0:	854e                	mv	a0,s3
     cd2:	00006097          	auipc	ra,0x6
     cd6:	b14080e7          	jalr	-1260(ra) # 67e6 <write>
     cda:	40000793          	li	a5,1024
     cde:	08f51063          	bne	a0,a5,d5e <writebig+0xd4>
  for(i = 0; i < MAXFILE; i++){
     ce2:	2485                	addiw	s1,s1,1
     ce4:	ff4491e3          	bne	s1,s4,cc6 <writebig+0x3c>
  close(fd);
     ce8:	854e                	mv	a0,s3
     cea:	00006097          	auipc	ra,0x6
     cee:	b04080e7          	jalr	-1276(ra) # 67ee <close>
  fd = open("big", O_RDONLY);
     cf2:	4581                	li	a1,0
     cf4:	00006517          	auipc	a0,0x6
     cf8:	47c50513          	addi	a0,a0,1148 # 7170 <malloc+0x544>
     cfc:	00006097          	auipc	ra,0x6
     d00:	b0a080e7          	jalr	-1270(ra) # 6806 <open>
     d04:	89aa                	mv	s3,a0
  n = 0;
     d06:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     d08:	0000d917          	auipc	s2,0xd
     d0c:	f7090913          	addi	s2,s2,-144 # dc78 <buf>
  if(fd < 0){
     d10:	06054a63          	bltz	a0,d84 <writebig+0xfa>
    i = read(fd, buf, BSIZE);
     d14:	40000613          	li	a2,1024
     d18:	85ca                	mv	a1,s2
     d1a:	854e                	mv	a0,s3
     d1c:	00006097          	auipc	ra,0x6
     d20:	ac2080e7          	jalr	-1342(ra) # 67de <read>
    if(i == 0){
     d24:	c151                	beqz	a0,da8 <writebig+0x11e>
    } else if(i != BSIZE){
     d26:	40000793          	li	a5,1024
     d2a:	0cf51f63          	bne	a0,a5,e08 <writebig+0x17e>
    if(((int*)buf)[0] != n){
     d2e:	00092683          	lw	a3,0(s2)
     d32:	0e969e63          	bne	a3,s1,e2e <writebig+0x1a4>
    n++;
     d36:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     d38:	bff1                	j	d14 <writebig+0x8a>
    printf("%s: error: creat big failed!\n", s);
     d3a:	85d6                	mv	a1,s5
     d3c:	00006517          	auipc	a0,0x6
     d40:	43c50513          	addi	a0,a0,1084 # 7178 <malloc+0x54c>
     d44:	00006097          	auipc	ra,0x6
     d48:	e2a080e7          	jalr	-470(ra) # 6b6e <printf>
    exit(1,"");
     d4c:	00007597          	auipc	a1,0x7
     d50:	60c58593          	addi	a1,a1,1548 # 8358 <malloc+0x172c>
     d54:	4505                	li	a0,1
     d56:	00006097          	auipc	ra,0x6
     d5a:	a70080e7          	jalr	-1424(ra) # 67c6 <exit>
      printf("%s: error: write big file failed\n", s, i);
     d5e:	8626                	mv	a2,s1
     d60:	85d6                	mv	a1,s5
     d62:	00006517          	auipc	a0,0x6
     d66:	43650513          	addi	a0,a0,1078 # 7198 <malloc+0x56c>
     d6a:	00006097          	auipc	ra,0x6
     d6e:	e04080e7          	jalr	-508(ra) # 6b6e <printf>
      exit(1,"");
     d72:	00007597          	auipc	a1,0x7
     d76:	5e658593          	addi	a1,a1,1510 # 8358 <malloc+0x172c>
     d7a:	4505                	li	a0,1
     d7c:	00006097          	auipc	ra,0x6
     d80:	a4a080e7          	jalr	-1462(ra) # 67c6 <exit>
    printf("%s: error: open big failed!\n", s);
     d84:	85d6                	mv	a1,s5
     d86:	00006517          	auipc	a0,0x6
     d8a:	43a50513          	addi	a0,a0,1082 # 71c0 <malloc+0x594>
     d8e:	00006097          	auipc	ra,0x6
     d92:	de0080e7          	jalr	-544(ra) # 6b6e <printf>
    exit(1,"");
     d96:	00007597          	auipc	a1,0x7
     d9a:	5c258593          	addi	a1,a1,1474 # 8358 <malloc+0x172c>
     d9e:	4505                	li	a0,1
     da0:	00006097          	auipc	ra,0x6
     da4:	a26080e7          	jalr	-1498(ra) # 67c6 <exit>
      if(n == MAXFILE - 1){
     da8:	10b00793          	li	a5,267
     dac:	02f48a63          	beq	s1,a5,de0 <writebig+0x156>
  close(fd);
     db0:	854e                	mv	a0,s3
     db2:	00006097          	auipc	ra,0x6
     db6:	a3c080e7          	jalr	-1476(ra) # 67ee <close>
  if(unlink("big") < 0){
     dba:	00006517          	auipc	a0,0x6
     dbe:	3b650513          	addi	a0,a0,950 # 7170 <malloc+0x544>
     dc2:	00006097          	auipc	ra,0x6
     dc6:	a54080e7          	jalr	-1452(ra) # 6816 <unlink>
     dca:	08054563          	bltz	a0,e54 <writebig+0x1ca>
}
     dce:	70e2                	ld	ra,56(sp)
     dd0:	7442                	ld	s0,48(sp)
     dd2:	74a2                	ld	s1,40(sp)
     dd4:	7902                	ld	s2,32(sp)
     dd6:	69e2                	ld	s3,24(sp)
     dd8:	6a42                	ld	s4,16(sp)
     dda:	6aa2                	ld	s5,8(sp)
     ddc:	6121                	addi	sp,sp,64
     dde:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
     de0:	10b00613          	li	a2,267
     de4:	85d6                	mv	a1,s5
     de6:	00006517          	auipc	a0,0x6
     dea:	3fa50513          	addi	a0,a0,1018 # 71e0 <malloc+0x5b4>
     dee:	00006097          	auipc	ra,0x6
     df2:	d80080e7          	jalr	-640(ra) # 6b6e <printf>
        exit(1,"");
     df6:	00007597          	auipc	a1,0x7
     dfa:	56258593          	addi	a1,a1,1378 # 8358 <malloc+0x172c>
     dfe:	4505                	li	a0,1
     e00:	00006097          	auipc	ra,0x6
     e04:	9c6080e7          	jalr	-1594(ra) # 67c6 <exit>
      printf("%s: read failed %d\n", s, i);
     e08:	862a                	mv	a2,a0
     e0a:	85d6                	mv	a1,s5
     e0c:	00006517          	auipc	a0,0x6
     e10:	3fc50513          	addi	a0,a0,1020 # 7208 <malloc+0x5dc>
     e14:	00006097          	auipc	ra,0x6
     e18:	d5a080e7          	jalr	-678(ra) # 6b6e <printf>
      exit(1,"");
     e1c:	00007597          	auipc	a1,0x7
     e20:	53c58593          	addi	a1,a1,1340 # 8358 <malloc+0x172c>
     e24:	4505                	li	a0,1
     e26:	00006097          	auipc	ra,0x6
     e2a:	9a0080e7          	jalr	-1632(ra) # 67c6 <exit>
      printf("%s: read content of block %d is %d\n", s,
     e2e:	8626                	mv	a2,s1
     e30:	85d6                	mv	a1,s5
     e32:	00006517          	auipc	a0,0x6
     e36:	3ee50513          	addi	a0,a0,1006 # 7220 <malloc+0x5f4>
     e3a:	00006097          	auipc	ra,0x6
     e3e:	d34080e7          	jalr	-716(ra) # 6b6e <printf>
      exit(1,"");
     e42:	00007597          	auipc	a1,0x7
     e46:	51658593          	addi	a1,a1,1302 # 8358 <malloc+0x172c>
     e4a:	4505                	li	a0,1
     e4c:	00006097          	auipc	ra,0x6
     e50:	97a080e7          	jalr	-1670(ra) # 67c6 <exit>
    printf("%s: unlink big failed\n", s);
     e54:	85d6                	mv	a1,s5
     e56:	00006517          	auipc	a0,0x6
     e5a:	3f250513          	addi	a0,a0,1010 # 7248 <malloc+0x61c>
     e5e:	00006097          	auipc	ra,0x6
     e62:	d10080e7          	jalr	-752(ra) # 6b6e <printf>
    exit(1,"");
     e66:	00007597          	auipc	a1,0x7
     e6a:	4f258593          	addi	a1,a1,1266 # 8358 <malloc+0x172c>
     e6e:	4505                	li	a0,1
     e70:	00006097          	auipc	ra,0x6
     e74:	956080e7          	jalr	-1706(ra) # 67c6 <exit>

0000000000000e78 <unlinkread>:
{
     e78:	7179                	addi	sp,sp,-48
     e7a:	f406                	sd	ra,40(sp)
     e7c:	f022                	sd	s0,32(sp)
     e7e:	ec26                	sd	s1,24(sp)
     e80:	e84a                	sd	s2,16(sp)
     e82:	e44e                	sd	s3,8(sp)
     e84:	1800                	addi	s0,sp,48
     e86:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     e88:	20200593          	li	a1,514
     e8c:	00006517          	auipc	a0,0x6
     e90:	3d450513          	addi	a0,a0,980 # 7260 <malloc+0x634>
     e94:	00006097          	auipc	ra,0x6
     e98:	972080e7          	jalr	-1678(ra) # 6806 <open>
  if(fd < 0){
     e9c:	0e054563          	bltz	a0,f86 <unlinkread+0x10e>
     ea0:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     ea2:	4615                	li	a2,5
     ea4:	00006597          	auipc	a1,0x6
     ea8:	3ec58593          	addi	a1,a1,1004 # 7290 <malloc+0x664>
     eac:	00006097          	auipc	ra,0x6
     eb0:	93a080e7          	jalr	-1734(ra) # 67e6 <write>
  close(fd);
     eb4:	8526                	mv	a0,s1
     eb6:	00006097          	auipc	ra,0x6
     eba:	938080e7          	jalr	-1736(ra) # 67ee <close>
  fd = open("unlinkread", O_RDWR);
     ebe:	4589                	li	a1,2
     ec0:	00006517          	auipc	a0,0x6
     ec4:	3a050513          	addi	a0,a0,928 # 7260 <malloc+0x634>
     ec8:	00006097          	auipc	ra,0x6
     ecc:	93e080e7          	jalr	-1730(ra) # 6806 <open>
     ed0:	84aa                	mv	s1,a0
  if(fd < 0){
     ed2:	0c054c63          	bltz	a0,faa <unlinkread+0x132>
  if(unlink("unlinkread") != 0){
     ed6:	00006517          	auipc	a0,0x6
     eda:	38a50513          	addi	a0,a0,906 # 7260 <malloc+0x634>
     ede:	00006097          	auipc	ra,0x6
     ee2:	938080e7          	jalr	-1736(ra) # 6816 <unlink>
     ee6:	e565                	bnez	a0,fce <unlinkread+0x156>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     ee8:	20200593          	li	a1,514
     eec:	00006517          	auipc	a0,0x6
     ef0:	37450513          	addi	a0,a0,884 # 7260 <malloc+0x634>
     ef4:	00006097          	auipc	ra,0x6
     ef8:	912080e7          	jalr	-1774(ra) # 6806 <open>
     efc:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     efe:	460d                	li	a2,3
     f00:	00006597          	auipc	a1,0x6
     f04:	3d858593          	addi	a1,a1,984 # 72d8 <malloc+0x6ac>
     f08:	00006097          	auipc	ra,0x6
     f0c:	8de080e7          	jalr	-1826(ra) # 67e6 <write>
  close(fd1);
     f10:	854a                	mv	a0,s2
     f12:	00006097          	auipc	ra,0x6
     f16:	8dc080e7          	jalr	-1828(ra) # 67ee <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
     f1a:	660d                	lui	a2,0x3
     f1c:	0000d597          	auipc	a1,0xd
     f20:	d5c58593          	addi	a1,a1,-676 # dc78 <buf>
     f24:	8526                	mv	a0,s1
     f26:	00006097          	auipc	ra,0x6
     f2a:	8b8080e7          	jalr	-1864(ra) # 67de <read>
     f2e:	4795                	li	a5,5
     f30:	0cf51163          	bne	a0,a5,ff2 <unlinkread+0x17a>
  if(buf[0] != 'h'){
     f34:	0000d717          	auipc	a4,0xd
     f38:	d4474703          	lbu	a4,-700(a4) # dc78 <buf>
     f3c:	06800793          	li	a5,104
     f40:	0cf71b63          	bne	a4,a5,1016 <unlinkread+0x19e>
  if(write(fd, buf, 10) != 10){
     f44:	4629                	li	a2,10
     f46:	0000d597          	auipc	a1,0xd
     f4a:	d3258593          	addi	a1,a1,-718 # dc78 <buf>
     f4e:	8526                	mv	a0,s1
     f50:	00006097          	auipc	ra,0x6
     f54:	896080e7          	jalr	-1898(ra) # 67e6 <write>
     f58:	47a9                	li	a5,10
     f5a:	0ef51063          	bne	a0,a5,103a <unlinkread+0x1c2>
  close(fd);
     f5e:	8526                	mv	a0,s1
     f60:	00006097          	auipc	ra,0x6
     f64:	88e080e7          	jalr	-1906(ra) # 67ee <close>
  unlink("unlinkread");
     f68:	00006517          	auipc	a0,0x6
     f6c:	2f850513          	addi	a0,a0,760 # 7260 <malloc+0x634>
     f70:	00006097          	auipc	ra,0x6
     f74:	8a6080e7          	jalr	-1882(ra) # 6816 <unlink>
}
     f78:	70a2                	ld	ra,40(sp)
     f7a:	7402                	ld	s0,32(sp)
     f7c:	64e2                	ld	s1,24(sp)
     f7e:	6942                	ld	s2,16(sp)
     f80:	69a2                	ld	s3,8(sp)
     f82:	6145                	addi	sp,sp,48
     f84:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     f86:	85ce                	mv	a1,s3
     f88:	00006517          	auipc	a0,0x6
     f8c:	2e850513          	addi	a0,a0,744 # 7270 <malloc+0x644>
     f90:	00006097          	auipc	ra,0x6
     f94:	bde080e7          	jalr	-1058(ra) # 6b6e <printf>
    exit(1,"");
     f98:	00007597          	auipc	a1,0x7
     f9c:	3c058593          	addi	a1,a1,960 # 8358 <malloc+0x172c>
     fa0:	4505                	li	a0,1
     fa2:	00006097          	auipc	ra,0x6
     fa6:	824080e7          	jalr	-2012(ra) # 67c6 <exit>
    printf("%s: open unlinkread failed\n", s);
     faa:	85ce                	mv	a1,s3
     fac:	00006517          	auipc	a0,0x6
     fb0:	2ec50513          	addi	a0,a0,748 # 7298 <malloc+0x66c>
     fb4:	00006097          	auipc	ra,0x6
     fb8:	bba080e7          	jalr	-1094(ra) # 6b6e <printf>
    exit(1,"");
     fbc:	00007597          	auipc	a1,0x7
     fc0:	39c58593          	addi	a1,a1,924 # 8358 <malloc+0x172c>
     fc4:	4505                	li	a0,1
     fc6:	00006097          	auipc	ra,0x6
     fca:	800080e7          	jalr	-2048(ra) # 67c6 <exit>
    printf("%s: unlink unlinkread failed\n", s);
     fce:	85ce                	mv	a1,s3
     fd0:	00006517          	auipc	a0,0x6
     fd4:	2e850513          	addi	a0,a0,744 # 72b8 <malloc+0x68c>
     fd8:	00006097          	auipc	ra,0x6
     fdc:	b96080e7          	jalr	-1130(ra) # 6b6e <printf>
    exit(1,"");
     fe0:	00007597          	auipc	a1,0x7
     fe4:	37858593          	addi	a1,a1,888 # 8358 <malloc+0x172c>
     fe8:	4505                	li	a0,1
     fea:	00005097          	auipc	ra,0x5
     fee:	7dc080e7          	jalr	2012(ra) # 67c6 <exit>
    printf("%s: unlinkread read failed", s);
     ff2:	85ce                	mv	a1,s3
     ff4:	00006517          	auipc	a0,0x6
     ff8:	2ec50513          	addi	a0,a0,748 # 72e0 <malloc+0x6b4>
     ffc:	00006097          	auipc	ra,0x6
    1000:	b72080e7          	jalr	-1166(ra) # 6b6e <printf>
    exit(1,"");
    1004:	00007597          	auipc	a1,0x7
    1008:	35458593          	addi	a1,a1,852 # 8358 <malloc+0x172c>
    100c:	4505                	li	a0,1
    100e:	00005097          	auipc	ra,0x5
    1012:	7b8080e7          	jalr	1976(ra) # 67c6 <exit>
    printf("%s: unlinkread wrong data\n", s);
    1016:	85ce                	mv	a1,s3
    1018:	00006517          	auipc	a0,0x6
    101c:	2e850513          	addi	a0,a0,744 # 7300 <malloc+0x6d4>
    1020:	00006097          	auipc	ra,0x6
    1024:	b4e080e7          	jalr	-1202(ra) # 6b6e <printf>
    exit(1,"");
    1028:	00007597          	auipc	a1,0x7
    102c:	33058593          	addi	a1,a1,816 # 8358 <malloc+0x172c>
    1030:	4505                	li	a0,1
    1032:	00005097          	auipc	ra,0x5
    1036:	794080e7          	jalr	1940(ra) # 67c6 <exit>
    printf("%s: unlinkread write failed\n", s);
    103a:	85ce                	mv	a1,s3
    103c:	00006517          	auipc	a0,0x6
    1040:	2e450513          	addi	a0,a0,740 # 7320 <malloc+0x6f4>
    1044:	00006097          	auipc	ra,0x6
    1048:	b2a080e7          	jalr	-1238(ra) # 6b6e <printf>
    exit(1,"");
    104c:	00007597          	auipc	a1,0x7
    1050:	30c58593          	addi	a1,a1,780 # 8358 <malloc+0x172c>
    1054:	4505                	li	a0,1
    1056:	00005097          	auipc	ra,0x5
    105a:	770080e7          	jalr	1904(ra) # 67c6 <exit>

000000000000105e <linktest>:
{
    105e:	1101                	addi	sp,sp,-32
    1060:	ec06                	sd	ra,24(sp)
    1062:	e822                	sd	s0,16(sp)
    1064:	e426                	sd	s1,8(sp)
    1066:	e04a                	sd	s2,0(sp)
    1068:	1000                	addi	s0,sp,32
    106a:	892a                	mv	s2,a0
  unlink("lf1");
    106c:	00006517          	auipc	a0,0x6
    1070:	2d450513          	addi	a0,a0,724 # 7340 <malloc+0x714>
    1074:	00005097          	auipc	ra,0x5
    1078:	7a2080e7          	jalr	1954(ra) # 6816 <unlink>
  unlink("lf2");
    107c:	00006517          	auipc	a0,0x6
    1080:	2cc50513          	addi	a0,a0,716 # 7348 <malloc+0x71c>
    1084:	00005097          	auipc	ra,0x5
    1088:	792080e7          	jalr	1938(ra) # 6816 <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
    108c:	20200593          	li	a1,514
    1090:	00006517          	auipc	a0,0x6
    1094:	2b050513          	addi	a0,a0,688 # 7340 <malloc+0x714>
    1098:	00005097          	auipc	ra,0x5
    109c:	76e080e7          	jalr	1902(ra) # 6806 <open>
  if(fd < 0){
    10a0:	10054763          	bltz	a0,11ae <linktest+0x150>
    10a4:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
    10a6:	4615                	li	a2,5
    10a8:	00006597          	auipc	a1,0x6
    10ac:	1e858593          	addi	a1,a1,488 # 7290 <malloc+0x664>
    10b0:	00005097          	auipc	ra,0x5
    10b4:	736080e7          	jalr	1846(ra) # 67e6 <write>
    10b8:	4795                	li	a5,5
    10ba:	10f51c63          	bne	a0,a5,11d2 <linktest+0x174>
  close(fd);
    10be:	8526                	mv	a0,s1
    10c0:	00005097          	auipc	ra,0x5
    10c4:	72e080e7          	jalr	1838(ra) # 67ee <close>
  if(link("lf1", "lf2") < 0){
    10c8:	00006597          	auipc	a1,0x6
    10cc:	28058593          	addi	a1,a1,640 # 7348 <malloc+0x71c>
    10d0:	00006517          	auipc	a0,0x6
    10d4:	27050513          	addi	a0,a0,624 # 7340 <malloc+0x714>
    10d8:	00005097          	auipc	ra,0x5
    10dc:	74e080e7          	jalr	1870(ra) # 6826 <link>
    10e0:	10054b63          	bltz	a0,11f6 <linktest+0x198>
  unlink("lf1");
    10e4:	00006517          	auipc	a0,0x6
    10e8:	25c50513          	addi	a0,a0,604 # 7340 <malloc+0x714>
    10ec:	00005097          	auipc	ra,0x5
    10f0:	72a080e7          	jalr	1834(ra) # 6816 <unlink>
  if(open("lf1", 0) >= 0){
    10f4:	4581                	li	a1,0
    10f6:	00006517          	auipc	a0,0x6
    10fa:	24a50513          	addi	a0,a0,586 # 7340 <malloc+0x714>
    10fe:	00005097          	auipc	ra,0x5
    1102:	708080e7          	jalr	1800(ra) # 6806 <open>
    1106:	10055a63          	bgez	a0,121a <linktest+0x1bc>
  fd = open("lf2", 0);
    110a:	4581                	li	a1,0
    110c:	00006517          	auipc	a0,0x6
    1110:	23c50513          	addi	a0,a0,572 # 7348 <malloc+0x71c>
    1114:	00005097          	auipc	ra,0x5
    1118:	6f2080e7          	jalr	1778(ra) # 6806 <open>
    111c:	84aa                	mv	s1,a0
  if(fd < 0){
    111e:	12054063          	bltz	a0,123e <linktest+0x1e0>
  if(read(fd, buf, sizeof(buf)) != SZ){
    1122:	660d                	lui	a2,0x3
    1124:	0000d597          	auipc	a1,0xd
    1128:	b5458593          	addi	a1,a1,-1196 # dc78 <buf>
    112c:	00005097          	auipc	ra,0x5
    1130:	6b2080e7          	jalr	1714(ra) # 67de <read>
    1134:	4795                	li	a5,5
    1136:	12f51663          	bne	a0,a5,1262 <linktest+0x204>
  close(fd);
    113a:	8526                	mv	a0,s1
    113c:	00005097          	auipc	ra,0x5
    1140:	6b2080e7          	jalr	1714(ra) # 67ee <close>
  if(link("lf2", "lf2") >= 0){
    1144:	00006597          	auipc	a1,0x6
    1148:	20458593          	addi	a1,a1,516 # 7348 <malloc+0x71c>
    114c:	852e                	mv	a0,a1
    114e:	00005097          	auipc	ra,0x5
    1152:	6d8080e7          	jalr	1752(ra) # 6826 <link>
    1156:	12055863          	bgez	a0,1286 <linktest+0x228>
  unlink("lf2");
    115a:	00006517          	auipc	a0,0x6
    115e:	1ee50513          	addi	a0,a0,494 # 7348 <malloc+0x71c>
    1162:	00005097          	auipc	ra,0x5
    1166:	6b4080e7          	jalr	1716(ra) # 6816 <unlink>
  if(link("lf2", "lf1") >= 0){
    116a:	00006597          	auipc	a1,0x6
    116e:	1d658593          	addi	a1,a1,470 # 7340 <malloc+0x714>
    1172:	00006517          	auipc	a0,0x6
    1176:	1d650513          	addi	a0,a0,470 # 7348 <malloc+0x71c>
    117a:	00005097          	auipc	ra,0x5
    117e:	6ac080e7          	jalr	1708(ra) # 6826 <link>
    1182:	12055463          	bgez	a0,12aa <linktest+0x24c>
  if(link(".", "lf1") >= 0){
    1186:	00006597          	auipc	a1,0x6
    118a:	1ba58593          	addi	a1,a1,442 # 7340 <malloc+0x714>
    118e:	00006517          	auipc	a0,0x6
    1192:	2c250513          	addi	a0,a0,706 # 7450 <malloc+0x824>
    1196:	00005097          	auipc	ra,0x5
    119a:	690080e7          	jalr	1680(ra) # 6826 <link>
    119e:	12055863          	bgez	a0,12ce <linktest+0x270>
}
    11a2:	60e2                	ld	ra,24(sp)
    11a4:	6442                	ld	s0,16(sp)
    11a6:	64a2                	ld	s1,8(sp)
    11a8:	6902                	ld	s2,0(sp)
    11aa:	6105                	addi	sp,sp,32
    11ac:	8082                	ret
    printf("%s: create lf1 failed\n", s);
    11ae:	85ca                	mv	a1,s2
    11b0:	00006517          	auipc	a0,0x6
    11b4:	1a050513          	addi	a0,a0,416 # 7350 <malloc+0x724>
    11b8:	00006097          	auipc	ra,0x6
    11bc:	9b6080e7          	jalr	-1610(ra) # 6b6e <printf>
    exit(1,"");
    11c0:	00007597          	auipc	a1,0x7
    11c4:	19858593          	addi	a1,a1,408 # 8358 <malloc+0x172c>
    11c8:	4505                	li	a0,1
    11ca:	00005097          	auipc	ra,0x5
    11ce:	5fc080e7          	jalr	1532(ra) # 67c6 <exit>
    printf("%s: write lf1 failed\n", s);
    11d2:	85ca                	mv	a1,s2
    11d4:	00006517          	auipc	a0,0x6
    11d8:	19450513          	addi	a0,a0,404 # 7368 <malloc+0x73c>
    11dc:	00006097          	auipc	ra,0x6
    11e0:	992080e7          	jalr	-1646(ra) # 6b6e <printf>
    exit(1,"");
    11e4:	00007597          	auipc	a1,0x7
    11e8:	17458593          	addi	a1,a1,372 # 8358 <malloc+0x172c>
    11ec:	4505                	li	a0,1
    11ee:	00005097          	auipc	ra,0x5
    11f2:	5d8080e7          	jalr	1496(ra) # 67c6 <exit>
    printf("%s: link lf1 lf2 failed\n", s);
    11f6:	85ca                	mv	a1,s2
    11f8:	00006517          	auipc	a0,0x6
    11fc:	18850513          	addi	a0,a0,392 # 7380 <malloc+0x754>
    1200:	00006097          	auipc	ra,0x6
    1204:	96e080e7          	jalr	-1682(ra) # 6b6e <printf>
    exit(1,"");
    1208:	00007597          	auipc	a1,0x7
    120c:	15058593          	addi	a1,a1,336 # 8358 <malloc+0x172c>
    1210:	4505                	li	a0,1
    1212:	00005097          	auipc	ra,0x5
    1216:	5b4080e7          	jalr	1460(ra) # 67c6 <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
    121a:	85ca                	mv	a1,s2
    121c:	00006517          	auipc	a0,0x6
    1220:	18450513          	addi	a0,a0,388 # 73a0 <malloc+0x774>
    1224:	00006097          	auipc	ra,0x6
    1228:	94a080e7          	jalr	-1718(ra) # 6b6e <printf>
    exit(1,"");
    122c:	00007597          	auipc	a1,0x7
    1230:	12c58593          	addi	a1,a1,300 # 8358 <malloc+0x172c>
    1234:	4505                	li	a0,1
    1236:	00005097          	auipc	ra,0x5
    123a:	590080e7          	jalr	1424(ra) # 67c6 <exit>
    printf("%s: open lf2 failed\n", s);
    123e:	85ca                	mv	a1,s2
    1240:	00006517          	auipc	a0,0x6
    1244:	19050513          	addi	a0,a0,400 # 73d0 <malloc+0x7a4>
    1248:	00006097          	auipc	ra,0x6
    124c:	926080e7          	jalr	-1754(ra) # 6b6e <printf>
    exit(1,"");
    1250:	00007597          	auipc	a1,0x7
    1254:	10858593          	addi	a1,a1,264 # 8358 <malloc+0x172c>
    1258:	4505                	li	a0,1
    125a:	00005097          	auipc	ra,0x5
    125e:	56c080e7          	jalr	1388(ra) # 67c6 <exit>
    printf("%s: read lf2 failed\n", s);
    1262:	85ca                	mv	a1,s2
    1264:	00006517          	auipc	a0,0x6
    1268:	18450513          	addi	a0,a0,388 # 73e8 <malloc+0x7bc>
    126c:	00006097          	auipc	ra,0x6
    1270:	902080e7          	jalr	-1790(ra) # 6b6e <printf>
    exit(1,"");
    1274:	00007597          	auipc	a1,0x7
    1278:	0e458593          	addi	a1,a1,228 # 8358 <malloc+0x172c>
    127c:	4505                	li	a0,1
    127e:	00005097          	auipc	ra,0x5
    1282:	548080e7          	jalr	1352(ra) # 67c6 <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
    1286:	85ca                	mv	a1,s2
    1288:	00006517          	auipc	a0,0x6
    128c:	17850513          	addi	a0,a0,376 # 7400 <malloc+0x7d4>
    1290:	00006097          	auipc	ra,0x6
    1294:	8de080e7          	jalr	-1826(ra) # 6b6e <printf>
    exit(1,"");
    1298:	00007597          	auipc	a1,0x7
    129c:	0c058593          	addi	a1,a1,192 # 8358 <malloc+0x172c>
    12a0:	4505                	li	a0,1
    12a2:	00005097          	auipc	ra,0x5
    12a6:	524080e7          	jalr	1316(ra) # 67c6 <exit>
    printf("%s: link non-existent succeeded! oops\n", s);
    12aa:	85ca                	mv	a1,s2
    12ac:	00006517          	auipc	a0,0x6
    12b0:	17c50513          	addi	a0,a0,380 # 7428 <malloc+0x7fc>
    12b4:	00006097          	auipc	ra,0x6
    12b8:	8ba080e7          	jalr	-1862(ra) # 6b6e <printf>
    exit(1,"");
    12bc:	00007597          	auipc	a1,0x7
    12c0:	09c58593          	addi	a1,a1,156 # 8358 <malloc+0x172c>
    12c4:	4505                	li	a0,1
    12c6:	00005097          	auipc	ra,0x5
    12ca:	500080e7          	jalr	1280(ra) # 67c6 <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
    12ce:	85ca                	mv	a1,s2
    12d0:	00006517          	auipc	a0,0x6
    12d4:	18850513          	addi	a0,a0,392 # 7458 <malloc+0x82c>
    12d8:	00006097          	auipc	ra,0x6
    12dc:	896080e7          	jalr	-1898(ra) # 6b6e <printf>
    exit(1,"");
    12e0:	00007597          	auipc	a1,0x7
    12e4:	07858593          	addi	a1,a1,120 # 8358 <malloc+0x172c>
    12e8:	4505                	li	a0,1
    12ea:	00005097          	auipc	ra,0x5
    12ee:	4dc080e7          	jalr	1244(ra) # 67c6 <exit>

00000000000012f2 <validatetest>:
{
    12f2:	7139                	addi	sp,sp,-64
    12f4:	fc06                	sd	ra,56(sp)
    12f6:	f822                	sd	s0,48(sp)
    12f8:	f426                	sd	s1,40(sp)
    12fa:	f04a                	sd	s2,32(sp)
    12fc:	ec4e                	sd	s3,24(sp)
    12fe:	e852                	sd	s4,16(sp)
    1300:	e456                	sd	s5,8(sp)
    1302:	e05a                	sd	s6,0(sp)
    1304:	0080                	addi	s0,sp,64
    1306:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    1308:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
    130a:	00006997          	auipc	s3,0x6
    130e:	16e98993          	addi	s3,s3,366 # 7478 <malloc+0x84c>
    1312:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    1314:	6a85                	lui	s5,0x1
    1316:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
    131a:	85a6                	mv	a1,s1
    131c:	854e                	mv	a0,s3
    131e:	00005097          	auipc	ra,0x5
    1322:	508080e7          	jalr	1288(ra) # 6826 <link>
    1326:	01251f63          	bne	a0,s2,1344 <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    132a:	94d6                	add	s1,s1,s5
    132c:	ff4497e3          	bne	s1,s4,131a <validatetest+0x28>
}
    1330:	70e2                	ld	ra,56(sp)
    1332:	7442                	ld	s0,48(sp)
    1334:	74a2                	ld	s1,40(sp)
    1336:	7902                	ld	s2,32(sp)
    1338:	69e2                	ld	s3,24(sp)
    133a:	6a42                	ld	s4,16(sp)
    133c:	6aa2                	ld	s5,8(sp)
    133e:	6b02                	ld	s6,0(sp)
    1340:	6121                	addi	sp,sp,64
    1342:	8082                	ret
      printf("%s: link should not succeed\n", s);
    1344:	85da                	mv	a1,s6
    1346:	00006517          	auipc	a0,0x6
    134a:	14250513          	addi	a0,a0,322 # 7488 <malloc+0x85c>
    134e:	00006097          	auipc	ra,0x6
    1352:	820080e7          	jalr	-2016(ra) # 6b6e <printf>
      exit(1,"");
    1356:	00007597          	auipc	a1,0x7
    135a:	00258593          	addi	a1,a1,2 # 8358 <malloc+0x172c>
    135e:	4505                	li	a0,1
    1360:	00005097          	auipc	ra,0x5
    1364:	466080e7          	jalr	1126(ra) # 67c6 <exit>

0000000000001368 <bigdir>:
{
    1368:	715d                	addi	sp,sp,-80
    136a:	e486                	sd	ra,72(sp)
    136c:	e0a2                	sd	s0,64(sp)
    136e:	fc26                	sd	s1,56(sp)
    1370:	f84a                	sd	s2,48(sp)
    1372:	f44e                	sd	s3,40(sp)
    1374:	f052                	sd	s4,32(sp)
    1376:	ec56                	sd	s5,24(sp)
    1378:	e85a                	sd	s6,16(sp)
    137a:	0880                	addi	s0,sp,80
    137c:	89aa                	mv	s3,a0
  unlink("bd");
    137e:	00006517          	auipc	a0,0x6
    1382:	12a50513          	addi	a0,a0,298 # 74a8 <malloc+0x87c>
    1386:	00005097          	auipc	ra,0x5
    138a:	490080e7          	jalr	1168(ra) # 6816 <unlink>
  fd = open("bd", O_CREATE);
    138e:	20000593          	li	a1,512
    1392:	00006517          	auipc	a0,0x6
    1396:	11650513          	addi	a0,a0,278 # 74a8 <malloc+0x87c>
    139a:	00005097          	auipc	ra,0x5
    139e:	46c080e7          	jalr	1132(ra) # 6806 <open>
  if(fd < 0){
    13a2:	0c054963          	bltz	a0,1474 <bigdir+0x10c>
  close(fd);
    13a6:	00005097          	auipc	ra,0x5
    13aa:	448080e7          	jalr	1096(ra) # 67ee <close>
  for(i = 0; i < N; i++){
    13ae:	4901                	li	s2,0
    name[0] = 'x';
    13b0:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
    13b4:	00006a17          	auipc	s4,0x6
    13b8:	0f4a0a13          	addi	s4,s4,244 # 74a8 <malloc+0x87c>
  for(i = 0; i < N; i++){
    13bc:	1f400b13          	li	s6,500
    name[0] = 'x';
    13c0:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
    13c4:	41f9579b          	sraiw	a5,s2,0x1f
    13c8:	01a7d71b          	srliw	a4,a5,0x1a
    13cc:	012707bb          	addw	a5,a4,s2
    13d0:	4067d69b          	sraiw	a3,a5,0x6
    13d4:	0306869b          	addiw	a3,a3,48
    13d8:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    13dc:	03f7f793          	andi	a5,a5,63
    13e0:	9f99                	subw	a5,a5,a4
    13e2:	0307879b          	addiw	a5,a5,48
    13e6:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    13ea:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
    13ee:	fb040593          	addi	a1,s0,-80
    13f2:	8552                	mv	a0,s4
    13f4:	00005097          	auipc	ra,0x5
    13f8:	432080e7          	jalr	1074(ra) # 6826 <link>
    13fc:	84aa                	mv	s1,a0
    13fe:	ed49                	bnez	a0,1498 <bigdir+0x130>
  for(i = 0; i < N; i++){
    1400:	2905                	addiw	s2,s2,1
    1402:	fb691fe3          	bne	s2,s6,13c0 <bigdir+0x58>
  unlink("bd");
    1406:	00006517          	auipc	a0,0x6
    140a:	0a250513          	addi	a0,a0,162 # 74a8 <malloc+0x87c>
    140e:	00005097          	auipc	ra,0x5
    1412:	408080e7          	jalr	1032(ra) # 6816 <unlink>
    name[0] = 'x';
    1416:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
    141a:	1f400a13          	li	s4,500
    name[0] = 'x';
    141e:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    1422:	41f4d79b          	sraiw	a5,s1,0x1f
    1426:	01a7d71b          	srliw	a4,a5,0x1a
    142a:	009707bb          	addw	a5,a4,s1
    142e:	4067d69b          	sraiw	a3,a5,0x6
    1432:	0306869b          	addiw	a3,a3,48
    1436:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    143a:	03f7f793          	andi	a5,a5,63
    143e:	9f99                	subw	a5,a5,a4
    1440:	0307879b          	addiw	a5,a5,48
    1444:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    1448:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
    144c:	fb040513          	addi	a0,s0,-80
    1450:	00005097          	auipc	ra,0x5
    1454:	3c6080e7          	jalr	966(ra) # 6816 <unlink>
    1458:	e525                	bnez	a0,14c0 <bigdir+0x158>
  for(i = 0; i < N; i++){
    145a:	2485                	addiw	s1,s1,1
    145c:	fd4491e3          	bne	s1,s4,141e <bigdir+0xb6>
}
    1460:	60a6                	ld	ra,72(sp)
    1462:	6406                	ld	s0,64(sp)
    1464:	74e2                	ld	s1,56(sp)
    1466:	7942                	ld	s2,48(sp)
    1468:	79a2                	ld	s3,40(sp)
    146a:	7a02                	ld	s4,32(sp)
    146c:	6ae2                	ld	s5,24(sp)
    146e:	6b42                	ld	s6,16(sp)
    1470:	6161                	addi	sp,sp,80
    1472:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    1474:	85ce                	mv	a1,s3
    1476:	00006517          	auipc	a0,0x6
    147a:	03a50513          	addi	a0,a0,58 # 74b0 <malloc+0x884>
    147e:	00005097          	auipc	ra,0x5
    1482:	6f0080e7          	jalr	1776(ra) # 6b6e <printf>
    exit(1,"");
    1486:	00007597          	auipc	a1,0x7
    148a:	ed258593          	addi	a1,a1,-302 # 8358 <malloc+0x172c>
    148e:	4505                	li	a0,1
    1490:	00005097          	auipc	ra,0x5
    1494:	336080e7          	jalr	822(ra) # 67c6 <exit>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
    1498:	fb040613          	addi	a2,s0,-80
    149c:	85ce                	mv	a1,s3
    149e:	00006517          	auipc	a0,0x6
    14a2:	03250513          	addi	a0,a0,50 # 74d0 <malloc+0x8a4>
    14a6:	00005097          	auipc	ra,0x5
    14aa:	6c8080e7          	jalr	1736(ra) # 6b6e <printf>
      exit(1,"");
    14ae:	00007597          	auipc	a1,0x7
    14b2:	eaa58593          	addi	a1,a1,-342 # 8358 <malloc+0x172c>
    14b6:	4505                	li	a0,1
    14b8:	00005097          	auipc	ra,0x5
    14bc:	30e080e7          	jalr	782(ra) # 67c6 <exit>
      printf("%s: bigdir unlink failed", s);
    14c0:	85ce                	mv	a1,s3
    14c2:	00006517          	auipc	a0,0x6
    14c6:	02e50513          	addi	a0,a0,46 # 74f0 <malloc+0x8c4>
    14ca:	00005097          	auipc	ra,0x5
    14ce:	6a4080e7          	jalr	1700(ra) # 6b6e <printf>
      exit(1,"");
    14d2:	00007597          	auipc	a1,0x7
    14d6:	e8658593          	addi	a1,a1,-378 # 8358 <malloc+0x172c>
    14da:	4505                	li	a0,1
    14dc:	00005097          	auipc	ra,0x5
    14e0:	2ea080e7          	jalr	746(ra) # 67c6 <exit>

00000000000014e4 <pgbug>:
{
    14e4:	7179                	addi	sp,sp,-48
    14e6:	f406                	sd	ra,40(sp)
    14e8:	f022                	sd	s0,32(sp)
    14ea:	ec26                	sd	s1,24(sp)
    14ec:	1800                	addi	s0,sp,48
  argv[0] = 0;
    14ee:	fc043c23          	sd	zero,-40(s0)
  exec(big, argv);
    14f2:	00009497          	auipc	s1,0x9
    14f6:	b0e48493          	addi	s1,s1,-1266 # a000 <big>
    14fa:	fd840593          	addi	a1,s0,-40
    14fe:	6088                	ld	a0,0(s1)
    1500:	00005097          	auipc	ra,0x5
    1504:	2fe080e7          	jalr	766(ra) # 67fe <exec>
  pipe(big);
    1508:	6088                	ld	a0,0(s1)
    150a:	00005097          	auipc	ra,0x5
    150e:	2cc080e7          	jalr	716(ra) # 67d6 <pipe>
  exit(0,"");
    1512:	00007597          	auipc	a1,0x7
    1516:	e4658593          	addi	a1,a1,-442 # 8358 <malloc+0x172c>
    151a:	4501                	li	a0,0
    151c:	00005097          	auipc	ra,0x5
    1520:	2aa080e7          	jalr	682(ra) # 67c6 <exit>

0000000000001524 <badarg>:
{
    1524:	7139                	addi	sp,sp,-64
    1526:	fc06                	sd	ra,56(sp)
    1528:	f822                	sd	s0,48(sp)
    152a:	f426                	sd	s1,40(sp)
    152c:	f04a                	sd	s2,32(sp)
    152e:	ec4e                	sd	s3,24(sp)
    1530:	0080                	addi	s0,sp,64
    1532:	64b1                	lui	s1,0xc
    1534:	35048493          	addi	s1,s1,848 # c350 <uninit+0xde8>
    argv[0] = (char*)0xffffffff;
    1538:	597d                	li	s2,-1
    153a:	02095913          	srli	s2,s2,0x20
    exec("echo", argv);
    153e:	00006997          	auipc	s3,0x6
    1542:	82a98993          	addi	s3,s3,-2006 # 6d68 <malloc+0x13c>
    argv[0] = (char*)0xffffffff;
    1546:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    154a:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    154e:	fc040593          	addi	a1,s0,-64
    1552:	854e                	mv	a0,s3
    1554:	00005097          	auipc	ra,0x5
    1558:	2aa080e7          	jalr	682(ra) # 67fe <exec>
  for(int i = 0; i < 50000; i++){
    155c:	34fd                	addiw	s1,s1,-1
    155e:	f4e5                	bnez	s1,1546 <badarg+0x22>
  exit(0,"");
    1560:	00007597          	auipc	a1,0x7
    1564:	df858593          	addi	a1,a1,-520 # 8358 <malloc+0x172c>
    1568:	4501                	li	a0,0
    156a:	00005097          	auipc	ra,0x5
    156e:	25c080e7          	jalr	604(ra) # 67c6 <exit>

0000000000001572 <copyinstr2>:
{
    1572:	7155                	addi	sp,sp,-208
    1574:	e586                	sd	ra,200(sp)
    1576:	e1a2                	sd	s0,192(sp)
    1578:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    157a:	f6840793          	addi	a5,s0,-152
    157e:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    1582:	07800713          	li	a4,120
    1586:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    158a:	0785                	addi	a5,a5,1
    158c:	fed79de3          	bne	a5,a3,1586 <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    1590:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    1594:	f6840513          	addi	a0,s0,-152
    1598:	00005097          	auipc	ra,0x5
    159c:	27e080e7          	jalr	638(ra) # 6816 <unlink>
  if(ret != -1){
    15a0:	57fd                	li	a5,-1
    15a2:	0ef51463          	bne	a0,a5,168a <copyinstr2+0x118>
  int fd = open(b, O_CREATE | O_WRONLY);
    15a6:	20100593          	li	a1,513
    15aa:	f6840513          	addi	a0,s0,-152
    15ae:	00005097          	auipc	ra,0x5
    15b2:	258080e7          	jalr	600(ra) # 6806 <open>
  if(fd != -1){
    15b6:	57fd                	li	a5,-1
    15b8:	0ef51d63          	bne	a0,a5,16b2 <copyinstr2+0x140>
  ret = link(b, b);
    15bc:	f6840593          	addi	a1,s0,-152
    15c0:	852e                	mv	a0,a1
    15c2:	00005097          	auipc	ra,0x5
    15c6:	264080e7          	jalr	612(ra) # 6826 <link>
  if(ret != -1){
    15ca:	57fd                	li	a5,-1
    15cc:	10f51763          	bne	a0,a5,16da <copyinstr2+0x168>
  char *args[] = { "xx", 0 };
    15d0:	00007797          	auipc	a5,0x7
    15d4:	17878793          	addi	a5,a5,376 # 8748 <malloc+0x1b1c>
    15d8:	f4f43c23          	sd	a5,-168(s0)
    15dc:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    15e0:	f5840593          	addi	a1,s0,-168
    15e4:	f6840513          	addi	a0,s0,-152
    15e8:	00005097          	auipc	ra,0x5
    15ec:	216080e7          	jalr	534(ra) # 67fe <exec>
  if(ret != -1){
    15f0:	57fd                	li	a5,-1
    15f2:	10f51963          	bne	a0,a5,1704 <copyinstr2+0x192>
  int pid = fork();
    15f6:	00005097          	auipc	ra,0x5
    15fa:	1c8080e7          	jalr	456(ra) # 67be <fork>
  if(pid < 0){
    15fe:	12054763          	bltz	a0,172c <copyinstr2+0x1ba>
  if(pid == 0){
    1602:	16051063          	bnez	a0,1762 <copyinstr2+0x1f0>
    1606:	00009797          	auipc	a5,0x9
    160a:	f5a78793          	addi	a5,a5,-166 # a560 <big.0>
    160e:	0000a697          	auipc	a3,0xa
    1612:	f5268693          	addi	a3,a3,-174 # b560 <big.0+0x1000>
      big[i] = 'x';
    1616:	07800713          	li	a4,120
    161a:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    161e:	0785                	addi	a5,a5,1
    1620:	fed79de3          	bne	a5,a3,161a <copyinstr2+0xa8>
    big[PGSIZE] = '\0';
    1624:	0000a797          	auipc	a5,0xa
    1628:	f2078e23          	sb	zero,-196(a5) # b560 <big.0+0x1000>
    char *args2[] = { big, big, big, 0 };
    162c:	00008797          	auipc	a5,0x8
    1630:	b3c78793          	addi	a5,a5,-1220 # 9168 <malloc+0x253c>
    1634:	6390                	ld	a2,0(a5)
    1636:	6794                	ld	a3,8(a5)
    1638:	6b98                	ld	a4,16(a5)
    163a:	6f9c                	ld	a5,24(a5)
    163c:	f2c43823          	sd	a2,-208(s0)
    1640:	f2d43c23          	sd	a3,-200(s0)
    1644:	f4e43023          	sd	a4,-192(s0)
    1648:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    164c:	f3040593          	addi	a1,s0,-208
    1650:	00005517          	auipc	a0,0x5
    1654:	71850513          	addi	a0,a0,1816 # 6d68 <malloc+0x13c>
    1658:	00005097          	auipc	ra,0x5
    165c:	1a6080e7          	jalr	422(ra) # 67fe <exec>
    if(ret != -1){
    1660:	57fd                	li	a5,-1
    1662:	0ef50663          	beq	a0,a5,174e <copyinstr2+0x1dc>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    1666:	55fd                	li	a1,-1
    1668:	00006517          	auipc	a0,0x6
    166c:	f3050513          	addi	a0,a0,-208 # 7598 <malloc+0x96c>
    1670:	00005097          	auipc	ra,0x5
    1674:	4fe080e7          	jalr	1278(ra) # 6b6e <printf>
      exit(1,"");
    1678:	00007597          	auipc	a1,0x7
    167c:	ce058593          	addi	a1,a1,-800 # 8358 <malloc+0x172c>
    1680:	4505                	li	a0,1
    1682:	00005097          	auipc	ra,0x5
    1686:	144080e7          	jalr	324(ra) # 67c6 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    168a:	862a                	mv	a2,a0
    168c:	f6840593          	addi	a1,s0,-152
    1690:	00006517          	auipc	a0,0x6
    1694:	e8050513          	addi	a0,a0,-384 # 7510 <malloc+0x8e4>
    1698:	00005097          	auipc	ra,0x5
    169c:	4d6080e7          	jalr	1238(ra) # 6b6e <printf>
    exit(1,"");
    16a0:	00007597          	auipc	a1,0x7
    16a4:	cb858593          	addi	a1,a1,-840 # 8358 <malloc+0x172c>
    16a8:	4505                	li	a0,1
    16aa:	00005097          	auipc	ra,0x5
    16ae:	11c080e7          	jalr	284(ra) # 67c6 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    16b2:	862a                	mv	a2,a0
    16b4:	f6840593          	addi	a1,s0,-152
    16b8:	00006517          	auipc	a0,0x6
    16bc:	e7850513          	addi	a0,a0,-392 # 7530 <malloc+0x904>
    16c0:	00005097          	auipc	ra,0x5
    16c4:	4ae080e7          	jalr	1198(ra) # 6b6e <printf>
    exit(1,"");
    16c8:	00007597          	auipc	a1,0x7
    16cc:	c9058593          	addi	a1,a1,-880 # 8358 <malloc+0x172c>
    16d0:	4505                	li	a0,1
    16d2:	00005097          	auipc	ra,0x5
    16d6:	0f4080e7          	jalr	244(ra) # 67c6 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    16da:	86aa                	mv	a3,a0
    16dc:	f6840613          	addi	a2,s0,-152
    16e0:	85b2                	mv	a1,a2
    16e2:	00006517          	auipc	a0,0x6
    16e6:	e6e50513          	addi	a0,a0,-402 # 7550 <malloc+0x924>
    16ea:	00005097          	auipc	ra,0x5
    16ee:	484080e7          	jalr	1156(ra) # 6b6e <printf>
    exit(1,"");
    16f2:	00007597          	auipc	a1,0x7
    16f6:	c6658593          	addi	a1,a1,-922 # 8358 <malloc+0x172c>
    16fa:	4505                	li	a0,1
    16fc:	00005097          	auipc	ra,0x5
    1700:	0ca080e7          	jalr	202(ra) # 67c6 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1704:	567d                	li	a2,-1
    1706:	f6840593          	addi	a1,s0,-152
    170a:	00006517          	auipc	a0,0x6
    170e:	e6e50513          	addi	a0,a0,-402 # 7578 <malloc+0x94c>
    1712:	00005097          	auipc	ra,0x5
    1716:	45c080e7          	jalr	1116(ra) # 6b6e <printf>
    exit(1,"");
    171a:	00007597          	auipc	a1,0x7
    171e:	c3e58593          	addi	a1,a1,-962 # 8358 <malloc+0x172c>
    1722:	4505                	li	a0,1
    1724:	00005097          	auipc	ra,0x5
    1728:	0a2080e7          	jalr	162(ra) # 67c6 <exit>
    printf("fork failed\n");
    172c:	00006517          	auipc	a0,0x6
    1730:	2cc50513          	addi	a0,a0,716 # 79f8 <malloc+0xdcc>
    1734:	00005097          	auipc	ra,0x5
    1738:	43a080e7          	jalr	1082(ra) # 6b6e <printf>
    exit(1,"");
    173c:	00007597          	auipc	a1,0x7
    1740:	c1c58593          	addi	a1,a1,-996 # 8358 <malloc+0x172c>
    1744:	4505                	li	a0,1
    1746:	00005097          	auipc	ra,0x5
    174a:	080080e7          	jalr	128(ra) # 67c6 <exit>
    exit(747,""); // OK
    174e:	00007597          	auipc	a1,0x7
    1752:	c0a58593          	addi	a1,a1,-1014 # 8358 <malloc+0x172c>
    1756:	2eb00513          	li	a0,747
    175a:	00005097          	auipc	ra,0x5
    175e:	06c080e7          	jalr	108(ra) # 67c6 <exit>
  int st = 0;
    1762:	f4042a23          	sw	zero,-172(s0)
  wait(&st,"");
    1766:	00007597          	auipc	a1,0x7
    176a:	bf258593          	addi	a1,a1,-1038 # 8358 <malloc+0x172c>
    176e:	f5440513          	addi	a0,s0,-172
    1772:	00005097          	auipc	ra,0x5
    1776:	05c080e7          	jalr	92(ra) # 67ce <wait>
  if(st != 747){
    177a:	f5442703          	lw	a4,-172(s0)
    177e:	2eb00793          	li	a5,747
    1782:	00f71663          	bne	a4,a5,178e <copyinstr2+0x21c>
}
    1786:	60ae                	ld	ra,200(sp)
    1788:	640e                	ld	s0,192(sp)
    178a:	6169                	addi	sp,sp,208
    178c:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    178e:	00006517          	auipc	a0,0x6
    1792:	e3250513          	addi	a0,a0,-462 # 75c0 <malloc+0x994>
    1796:	00005097          	auipc	ra,0x5
    179a:	3d8080e7          	jalr	984(ra) # 6b6e <printf>
    exit(1,"");
    179e:	00007597          	auipc	a1,0x7
    17a2:	bba58593          	addi	a1,a1,-1094 # 8358 <malloc+0x172c>
    17a6:	4505                	li	a0,1
    17a8:	00005097          	auipc	ra,0x5
    17ac:	01e080e7          	jalr	30(ra) # 67c6 <exit>

00000000000017b0 <truncate3>:
{
    17b0:	7159                	addi	sp,sp,-112
    17b2:	f486                	sd	ra,104(sp)
    17b4:	f0a2                	sd	s0,96(sp)
    17b6:	eca6                	sd	s1,88(sp)
    17b8:	e8ca                	sd	s2,80(sp)
    17ba:	e4ce                	sd	s3,72(sp)
    17bc:	e0d2                	sd	s4,64(sp)
    17be:	fc56                	sd	s5,56(sp)
    17c0:	1880                	addi	s0,sp,112
    17c2:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
    17c4:	60100593          	li	a1,1537
    17c8:	00005517          	auipc	a0,0x5
    17cc:	5f850513          	addi	a0,a0,1528 # 6dc0 <malloc+0x194>
    17d0:	00005097          	auipc	ra,0x5
    17d4:	036080e7          	jalr	54(ra) # 6806 <open>
    17d8:	00005097          	auipc	ra,0x5
    17dc:	016080e7          	jalr	22(ra) # 67ee <close>
  pid = fork();
    17e0:	00005097          	auipc	ra,0x5
    17e4:	fde080e7          	jalr	-34(ra) # 67be <fork>
  if(pid < 0){
    17e8:	08054463          	bltz	a0,1870 <truncate3+0xc0>
  if(pid == 0){
    17ec:	e96d                	bnez	a0,18de <truncate3+0x12e>
    17ee:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
    17f2:	00005a17          	auipc	s4,0x5
    17f6:	5cea0a13          	addi	s4,s4,1486 # 6dc0 <malloc+0x194>
      int n = write(fd, "1234567890", 10);
    17fa:	00006a97          	auipc	s5,0x6
    17fe:	e26a8a93          	addi	s5,s5,-474 # 7620 <malloc+0x9f4>
      int fd = open("truncfile", O_WRONLY);
    1802:	4585                	li	a1,1
    1804:	8552                	mv	a0,s4
    1806:	00005097          	auipc	ra,0x5
    180a:	000080e7          	jalr	ra # 6806 <open>
    180e:	84aa                	mv	s1,a0
      if(fd < 0){
    1810:	08054263          	bltz	a0,1894 <truncate3+0xe4>
      int n = write(fd, "1234567890", 10);
    1814:	4629                	li	a2,10
    1816:	85d6                	mv	a1,s5
    1818:	00005097          	auipc	ra,0x5
    181c:	fce080e7          	jalr	-50(ra) # 67e6 <write>
      if(n != 10){
    1820:	47a9                	li	a5,10
    1822:	08f51b63          	bne	a0,a5,18b8 <truncate3+0x108>
      close(fd);
    1826:	8526                	mv	a0,s1
    1828:	00005097          	auipc	ra,0x5
    182c:	fc6080e7          	jalr	-58(ra) # 67ee <close>
      fd = open("truncfile", O_RDONLY);
    1830:	4581                	li	a1,0
    1832:	8552                	mv	a0,s4
    1834:	00005097          	auipc	ra,0x5
    1838:	fd2080e7          	jalr	-46(ra) # 6806 <open>
    183c:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    183e:	02000613          	li	a2,32
    1842:	f9840593          	addi	a1,s0,-104
    1846:	00005097          	auipc	ra,0x5
    184a:	f98080e7          	jalr	-104(ra) # 67de <read>
      close(fd);
    184e:	8526                	mv	a0,s1
    1850:	00005097          	auipc	ra,0x5
    1854:	f9e080e7          	jalr	-98(ra) # 67ee <close>
    for(int i = 0; i < 100; i++){
    1858:	39fd                	addiw	s3,s3,-1
    185a:	fa0994e3          	bnez	s3,1802 <truncate3+0x52>
    exit(0,"");
    185e:	00007597          	auipc	a1,0x7
    1862:	afa58593          	addi	a1,a1,-1286 # 8358 <malloc+0x172c>
    1866:	4501                	li	a0,0
    1868:	00005097          	auipc	ra,0x5
    186c:	f5e080e7          	jalr	-162(ra) # 67c6 <exit>
    printf("%s: fork failed\n", s);
    1870:	85ca                	mv	a1,s2
    1872:	00006517          	auipc	a0,0x6
    1876:	d7e50513          	addi	a0,a0,-642 # 75f0 <malloc+0x9c4>
    187a:	00005097          	auipc	ra,0x5
    187e:	2f4080e7          	jalr	756(ra) # 6b6e <printf>
    exit(1,"");
    1882:	00007597          	auipc	a1,0x7
    1886:	ad658593          	addi	a1,a1,-1322 # 8358 <malloc+0x172c>
    188a:	4505                	li	a0,1
    188c:	00005097          	auipc	ra,0x5
    1890:	f3a080e7          	jalr	-198(ra) # 67c6 <exit>
        printf("%s: open failed\n", s);
    1894:	85ca                	mv	a1,s2
    1896:	00006517          	auipc	a0,0x6
    189a:	d7250513          	addi	a0,a0,-654 # 7608 <malloc+0x9dc>
    189e:	00005097          	auipc	ra,0x5
    18a2:	2d0080e7          	jalr	720(ra) # 6b6e <printf>
        exit(1,"");
    18a6:	00007597          	auipc	a1,0x7
    18aa:	ab258593          	addi	a1,a1,-1358 # 8358 <malloc+0x172c>
    18ae:	4505                	li	a0,1
    18b0:	00005097          	auipc	ra,0x5
    18b4:	f16080e7          	jalr	-234(ra) # 67c6 <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    18b8:	862a                	mv	a2,a0
    18ba:	85ca                	mv	a1,s2
    18bc:	00006517          	auipc	a0,0x6
    18c0:	d7450513          	addi	a0,a0,-652 # 7630 <malloc+0xa04>
    18c4:	00005097          	auipc	ra,0x5
    18c8:	2aa080e7          	jalr	682(ra) # 6b6e <printf>
        exit(1,"");
    18cc:	00007597          	auipc	a1,0x7
    18d0:	a8c58593          	addi	a1,a1,-1396 # 8358 <malloc+0x172c>
    18d4:	4505                	li	a0,1
    18d6:	00005097          	auipc	ra,0x5
    18da:	ef0080e7          	jalr	-272(ra) # 67c6 <exit>
    18de:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    18e2:	00005a17          	auipc	s4,0x5
    18e6:	4dea0a13          	addi	s4,s4,1246 # 6dc0 <malloc+0x194>
    int n = write(fd, "xxx", 3);
    18ea:	00006a97          	auipc	s5,0x6
    18ee:	d66a8a93          	addi	s5,s5,-666 # 7650 <malloc+0xa24>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    18f2:	60100593          	li	a1,1537
    18f6:	8552                	mv	a0,s4
    18f8:	00005097          	auipc	ra,0x5
    18fc:	f0e080e7          	jalr	-242(ra) # 6806 <open>
    1900:	84aa                	mv	s1,a0
    if(fd < 0){
    1902:	04054f63          	bltz	a0,1960 <truncate3+0x1b0>
    int n = write(fd, "xxx", 3);
    1906:	460d                	li	a2,3
    1908:	85d6                	mv	a1,s5
    190a:	00005097          	auipc	ra,0x5
    190e:	edc080e7          	jalr	-292(ra) # 67e6 <write>
    if(n != 3){
    1912:	478d                	li	a5,3
    1914:	06f51863          	bne	a0,a5,1984 <truncate3+0x1d4>
    close(fd);
    1918:	8526                	mv	a0,s1
    191a:	00005097          	auipc	ra,0x5
    191e:	ed4080e7          	jalr	-300(ra) # 67ee <close>
  for(int i = 0; i < 150; i++){
    1922:	39fd                	addiw	s3,s3,-1
    1924:	fc0997e3          	bnez	s3,18f2 <truncate3+0x142>
  wait(&xstatus,"");
    1928:	00007597          	auipc	a1,0x7
    192c:	a3058593          	addi	a1,a1,-1488 # 8358 <malloc+0x172c>
    1930:	fbc40513          	addi	a0,s0,-68
    1934:	00005097          	auipc	ra,0x5
    1938:	e9a080e7          	jalr	-358(ra) # 67ce <wait>
  unlink("truncfile");
    193c:	00005517          	auipc	a0,0x5
    1940:	48450513          	addi	a0,a0,1156 # 6dc0 <malloc+0x194>
    1944:	00005097          	auipc	ra,0x5
    1948:	ed2080e7          	jalr	-302(ra) # 6816 <unlink>
  exit(xstatus,"");
    194c:	00007597          	auipc	a1,0x7
    1950:	a0c58593          	addi	a1,a1,-1524 # 8358 <malloc+0x172c>
    1954:	fbc42503          	lw	a0,-68(s0)
    1958:	00005097          	auipc	ra,0x5
    195c:	e6e080e7          	jalr	-402(ra) # 67c6 <exit>
      printf("%s: open failed\n", s);
    1960:	85ca                	mv	a1,s2
    1962:	00006517          	auipc	a0,0x6
    1966:	ca650513          	addi	a0,a0,-858 # 7608 <malloc+0x9dc>
    196a:	00005097          	auipc	ra,0x5
    196e:	204080e7          	jalr	516(ra) # 6b6e <printf>
      exit(1,"");
    1972:	00007597          	auipc	a1,0x7
    1976:	9e658593          	addi	a1,a1,-1562 # 8358 <malloc+0x172c>
    197a:	4505                	li	a0,1
    197c:	00005097          	auipc	ra,0x5
    1980:	e4a080e7          	jalr	-438(ra) # 67c6 <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    1984:	862a                	mv	a2,a0
    1986:	85ca                	mv	a1,s2
    1988:	00006517          	auipc	a0,0x6
    198c:	cd050513          	addi	a0,a0,-816 # 7658 <malloc+0xa2c>
    1990:	00005097          	auipc	ra,0x5
    1994:	1de080e7          	jalr	478(ra) # 6b6e <printf>
      exit(1,"");
    1998:	00007597          	auipc	a1,0x7
    199c:	9c058593          	addi	a1,a1,-1600 # 8358 <malloc+0x172c>
    19a0:	4505                	li	a0,1
    19a2:	00005097          	auipc	ra,0x5
    19a6:	e24080e7          	jalr	-476(ra) # 67c6 <exit>

00000000000019aa <exectest>:
{
    19aa:	715d                	addi	sp,sp,-80
    19ac:	e486                	sd	ra,72(sp)
    19ae:	e0a2                	sd	s0,64(sp)
    19b0:	fc26                	sd	s1,56(sp)
    19b2:	f84a                	sd	s2,48(sp)
    19b4:	0880                	addi	s0,sp,80
    19b6:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    19b8:	00005797          	auipc	a5,0x5
    19bc:	3b078793          	addi	a5,a5,944 # 6d68 <malloc+0x13c>
    19c0:	fcf43023          	sd	a5,-64(s0)
    19c4:	00006797          	auipc	a5,0x6
    19c8:	cb478793          	addi	a5,a5,-844 # 7678 <malloc+0xa4c>
    19cc:	fcf43423          	sd	a5,-56(s0)
    19d0:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    19d4:	00006517          	auipc	a0,0x6
    19d8:	cac50513          	addi	a0,a0,-852 # 7680 <malloc+0xa54>
    19dc:	00005097          	auipc	ra,0x5
    19e0:	e3a080e7          	jalr	-454(ra) # 6816 <unlink>
  pid = fork();
    19e4:	00005097          	auipc	ra,0x5
    19e8:	dda080e7          	jalr	-550(ra) # 67be <fork>
  if(pid < 0) {
    19ec:	04054a63          	bltz	a0,1a40 <exectest+0x96>
    19f0:	84aa                	mv	s1,a0
  if(pid == 0) {
    19f2:	e55d                	bnez	a0,1aa0 <exectest+0xf6>
    close(1);
    19f4:	4505                	li	a0,1
    19f6:	00005097          	auipc	ra,0x5
    19fa:	df8080e7          	jalr	-520(ra) # 67ee <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    19fe:	20100593          	li	a1,513
    1a02:	00006517          	auipc	a0,0x6
    1a06:	c7e50513          	addi	a0,a0,-898 # 7680 <malloc+0xa54>
    1a0a:	00005097          	auipc	ra,0x5
    1a0e:	dfc080e7          	jalr	-516(ra) # 6806 <open>
    if(fd < 0) {
    1a12:	04054963          	bltz	a0,1a64 <exectest+0xba>
    if(fd != 1) {
    1a16:	4785                	li	a5,1
    1a18:	06f50863          	beq	a0,a5,1a88 <exectest+0xde>
      printf("%s: wrong fd\n", s);
    1a1c:	85ca                	mv	a1,s2
    1a1e:	00006517          	auipc	a0,0x6
    1a22:	c8250513          	addi	a0,a0,-894 # 76a0 <malloc+0xa74>
    1a26:	00005097          	auipc	ra,0x5
    1a2a:	148080e7          	jalr	328(ra) # 6b6e <printf>
      exit(1,"");
    1a2e:	00007597          	auipc	a1,0x7
    1a32:	92a58593          	addi	a1,a1,-1750 # 8358 <malloc+0x172c>
    1a36:	4505                	li	a0,1
    1a38:	00005097          	auipc	ra,0x5
    1a3c:	d8e080e7          	jalr	-626(ra) # 67c6 <exit>
     printf("%s: fork failed\n", s);
    1a40:	85ca                	mv	a1,s2
    1a42:	00006517          	auipc	a0,0x6
    1a46:	bae50513          	addi	a0,a0,-1106 # 75f0 <malloc+0x9c4>
    1a4a:	00005097          	auipc	ra,0x5
    1a4e:	124080e7          	jalr	292(ra) # 6b6e <printf>
     exit(1,"");
    1a52:	00007597          	auipc	a1,0x7
    1a56:	90658593          	addi	a1,a1,-1786 # 8358 <malloc+0x172c>
    1a5a:	4505                	li	a0,1
    1a5c:	00005097          	auipc	ra,0x5
    1a60:	d6a080e7          	jalr	-662(ra) # 67c6 <exit>
      printf("%s: create failed\n", s);
    1a64:	85ca                	mv	a1,s2
    1a66:	00006517          	auipc	a0,0x6
    1a6a:	c2250513          	addi	a0,a0,-990 # 7688 <malloc+0xa5c>
    1a6e:	00005097          	auipc	ra,0x5
    1a72:	100080e7          	jalr	256(ra) # 6b6e <printf>
      exit(1,"");
    1a76:	00007597          	auipc	a1,0x7
    1a7a:	8e258593          	addi	a1,a1,-1822 # 8358 <malloc+0x172c>
    1a7e:	4505                	li	a0,1
    1a80:	00005097          	auipc	ra,0x5
    1a84:	d46080e7          	jalr	-698(ra) # 67c6 <exit>
    if(exec("echo", echoargv) < 0){
    1a88:	fc040593          	addi	a1,s0,-64
    1a8c:	00005517          	auipc	a0,0x5
    1a90:	2dc50513          	addi	a0,a0,732 # 6d68 <malloc+0x13c>
    1a94:	00005097          	auipc	ra,0x5
    1a98:	d6a080e7          	jalr	-662(ra) # 67fe <exec>
    1a9c:	02054963          	bltz	a0,1ace <exectest+0x124>
  if (wait(&xstatus,"") != pid) {
    1aa0:	00007597          	auipc	a1,0x7
    1aa4:	8b858593          	addi	a1,a1,-1864 # 8358 <malloc+0x172c>
    1aa8:	fdc40513          	addi	a0,s0,-36
    1aac:	00005097          	auipc	ra,0x5
    1ab0:	d22080e7          	jalr	-734(ra) # 67ce <wait>
    1ab4:	02951f63          	bne	a0,s1,1af2 <exectest+0x148>
  if(xstatus != 0)
    1ab8:	fdc42503          	lw	a0,-36(s0)
    1abc:	c529                	beqz	a0,1b06 <exectest+0x15c>
    exit(xstatus,"");
    1abe:	00007597          	auipc	a1,0x7
    1ac2:	89a58593          	addi	a1,a1,-1894 # 8358 <malloc+0x172c>
    1ac6:	00005097          	auipc	ra,0x5
    1aca:	d00080e7          	jalr	-768(ra) # 67c6 <exit>
      printf("%s: exec echo failed\n", s);
    1ace:	85ca                	mv	a1,s2
    1ad0:	00006517          	auipc	a0,0x6
    1ad4:	be050513          	addi	a0,a0,-1056 # 76b0 <malloc+0xa84>
    1ad8:	00005097          	auipc	ra,0x5
    1adc:	096080e7          	jalr	150(ra) # 6b6e <printf>
      exit(1,"");
    1ae0:	00007597          	auipc	a1,0x7
    1ae4:	87858593          	addi	a1,a1,-1928 # 8358 <malloc+0x172c>
    1ae8:	4505                	li	a0,1
    1aea:	00005097          	auipc	ra,0x5
    1aee:	cdc080e7          	jalr	-804(ra) # 67c6 <exit>
    printf("%s: wait failed!\n", s);
    1af2:	85ca                	mv	a1,s2
    1af4:	00006517          	auipc	a0,0x6
    1af8:	bd450513          	addi	a0,a0,-1068 # 76c8 <malloc+0xa9c>
    1afc:	00005097          	auipc	ra,0x5
    1b00:	072080e7          	jalr	114(ra) # 6b6e <printf>
    1b04:	bf55                	j	1ab8 <exectest+0x10e>
  fd = open("echo-ok", O_RDONLY);
    1b06:	4581                	li	a1,0
    1b08:	00006517          	auipc	a0,0x6
    1b0c:	b7850513          	addi	a0,a0,-1160 # 7680 <malloc+0xa54>
    1b10:	00005097          	auipc	ra,0x5
    1b14:	cf6080e7          	jalr	-778(ra) # 6806 <open>
  if(fd < 0) {
    1b18:	02054e63          	bltz	a0,1b54 <exectest+0x1aa>
  if (read(fd, buf, 2) != 2) {
    1b1c:	4609                	li	a2,2
    1b1e:	fb840593          	addi	a1,s0,-72
    1b22:	00005097          	auipc	ra,0x5
    1b26:	cbc080e7          	jalr	-836(ra) # 67de <read>
    1b2a:	4789                	li	a5,2
    1b2c:	04f50663          	beq	a0,a5,1b78 <exectest+0x1ce>
    printf("%s: read failed\n", s);
    1b30:	85ca                	mv	a1,s2
    1b32:	00005517          	auipc	a0,0x5
    1b36:	60650513          	addi	a0,a0,1542 # 7138 <malloc+0x50c>
    1b3a:	00005097          	auipc	ra,0x5
    1b3e:	034080e7          	jalr	52(ra) # 6b6e <printf>
    exit(1,"");
    1b42:	00007597          	auipc	a1,0x7
    1b46:	81658593          	addi	a1,a1,-2026 # 8358 <malloc+0x172c>
    1b4a:	4505                	li	a0,1
    1b4c:	00005097          	auipc	ra,0x5
    1b50:	c7a080e7          	jalr	-902(ra) # 67c6 <exit>
    printf("%s: open failed\n", s);
    1b54:	85ca                	mv	a1,s2
    1b56:	00006517          	auipc	a0,0x6
    1b5a:	ab250513          	addi	a0,a0,-1358 # 7608 <malloc+0x9dc>
    1b5e:	00005097          	auipc	ra,0x5
    1b62:	010080e7          	jalr	16(ra) # 6b6e <printf>
    exit(1,"");
    1b66:	00006597          	auipc	a1,0x6
    1b6a:	7f258593          	addi	a1,a1,2034 # 8358 <malloc+0x172c>
    1b6e:	4505                	li	a0,1
    1b70:	00005097          	auipc	ra,0x5
    1b74:	c56080e7          	jalr	-938(ra) # 67c6 <exit>
  unlink("echo-ok");
    1b78:	00006517          	auipc	a0,0x6
    1b7c:	b0850513          	addi	a0,a0,-1272 # 7680 <malloc+0xa54>
    1b80:	00005097          	auipc	ra,0x5
    1b84:	c96080e7          	jalr	-874(ra) # 6816 <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    1b88:	fb844703          	lbu	a4,-72(s0)
    1b8c:	04f00793          	li	a5,79
    1b90:	00f71863          	bne	a4,a5,1ba0 <exectest+0x1f6>
    1b94:	fb944703          	lbu	a4,-71(s0)
    1b98:	04b00793          	li	a5,75
    1b9c:	02f70463          	beq	a4,a5,1bc4 <exectest+0x21a>
    printf("%s: wrong output\n", s);
    1ba0:	85ca                	mv	a1,s2
    1ba2:	00006517          	auipc	a0,0x6
    1ba6:	b3e50513          	addi	a0,a0,-1218 # 76e0 <malloc+0xab4>
    1baa:	00005097          	auipc	ra,0x5
    1bae:	fc4080e7          	jalr	-60(ra) # 6b6e <printf>
    exit(1,"");
    1bb2:	00006597          	auipc	a1,0x6
    1bb6:	7a658593          	addi	a1,a1,1958 # 8358 <malloc+0x172c>
    1bba:	4505                	li	a0,1
    1bbc:	00005097          	auipc	ra,0x5
    1bc0:	c0a080e7          	jalr	-1014(ra) # 67c6 <exit>
    exit(0,"");
    1bc4:	00006597          	auipc	a1,0x6
    1bc8:	79458593          	addi	a1,a1,1940 # 8358 <malloc+0x172c>
    1bcc:	4501                	li	a0,0
    1bce:	00005097          	auipc	ra,0x5
    1bd2:	bf8080e7          	jalr	-1032(ra) # 67c6 <exit>

0000000000001bd6 <pipe1>:
{
    1bd6:	711d                	addi	sp,sp,-96
    1bd8:	ec86                	sd	ra,88(sp)
    1bda:	e8a2                	sd	s0,80(sp)
    1bdc:	e4a6                	sd	s1,72(sp)
    1bde:	e0ca                	sd	s2,64(sp)
    1be0:	fc4e                	sd	s3,56(sp)
    1be2:	f852                	sd	s4,48(sp)
    1be4:	f456                	sd	s5,40(sp)
    1be6:	f05a                	sd	s6,32(sp)
    1be8:	ec5e                	sd	s7,24(sp)
    1bea:	1080                	addi	s0,sp,96
    1bec:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    1bee:	fa840513          	addi	a0,s0,-88
    1bf2:	00005097          	auipc	ra,0x5
    1bf6:	be4080e7          	jalr	-1052(ra) # 67d6 <pipe>
    1bfa:	ed25                	bnez	a0,1c72 <pipe1+0x9c>
    1bfc:	84aa                	mv	s1,a0
  pid = fork();
    1bfe:	00005097          	auipc	ra,0x5
    1c02:	bc0080e7          	jalr	-1088(ra) # 67be <fork>
    1c06:	8a2a                	mv	s4,a0
  if(pid == 0){
    1c08:	c559                	beqz	a0,1c96 <pipe1+0xc0>
  } else if(pid > 0){
    1c0a:	1aa05663          	blez	a0,1db6 <pipe1+0x1e0>
    close(fds[1]);
    1c0e:	fac42503          	lw	a0,-84(s0)
    1c12:	00005097          	auipc	ra,0x5
    1c16:	bdc080e7          	jalr	-1060(ra) # 67ee <close>
    total = 0;
    1c1a:	8a26                	mv	s4,s1
    cc = 1;
    1c1c:	4985                	li	s3,1
    while((n = read(fds[0], buf, cc)) > 0){
    1c1e:	0000ca97          	auipc	s5,0xc
    1c22:	05aa8a93          	addi	s5,s5,90 # dc78 <buf>
      if(cc > sizeof(buf))
    1c26:	6b0d                	lui	s6,0x3
    while((n = read(fds[0], buf, cc)) > 0){
    1c28:	864e                	mv	a2,s3
    1c2a:	85d6                	mv	a1,s5
    1c2c:	fa842503          	lw	a0,-88(s0)
    1c30:	00005097          	auipc	ra,0x5
    1c34:	bae080e7          	jalr	-1106(ra) # 67de <read>
    1c38:	10a05e63          	blez	a0,1d54 <pipe1+0x17e>
      for(i = 0; i < n; i++){
    1c3c:	0000c717          	auipc	a4,0xc
    1c40:	03c70713          	addi	a4,a4,60 # dc78 <buf>
    1c44:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    1c48:	00074683          	lbu	a3,0(a4)
    1c4c:	0ff4f793          	andi	a5,s1,255
    1c50:	2485                	addiw	s1,s1,1
    1c52:	0cf69d63          	bne	a3,a5,1d2c <pipe1+0x156>
      for(i = 0; i < n; i++){
    1c56:	0705                	addi	a4,a4,1
    1c58:	fec498e3          	bne	s1,a2,1c48 <pipe1+0x72>
      total += n;
    1c5c:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    1c60:	0019979b          	slliw	a5,s3,0x1
    1c64:	0007899b          	sext.w	s3,a5
      if(cc > sizeof(buf))
    1c68:	013b7363          	bgeu	s6,s3,1c6e <pipe1+0x98>
        cc = sizeof(buf);
    1c6c:	89da                	mv	s3,s6
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    1c6e:	84b2                	mv	s1,a2
    1c70:	bf65                	j	1c28 <pipe1+0x52>
    printf("%s: pipe() failed\n", s);
    1c72:	85ca                	mv	a1,s2
    1c74:	00006517          	auipc	a0,0x6
    1c78:	a8450513          	addi	a0,a0,-1404 # 76f8 <malloc+0xacc>
    1c7c:	00005097          	auipc	ra,0x5
    1c80:	ef2080e7          	jalr	-270(ra) # 6b6e <printf>
    exit(1,"");
    1c84:	00006597          	auipc	a1,0x6
    1c88:	6d458593          	addi	a1,a1,1748 # 8358 <malloc+0x172c>
    1c8c:	4505                	li	a0,1
    1c8e:	00005097          	auipc	ra,0x5
    1c92:	b38080e7          	jalr	-1224(ra) # 67c6 <exit>
    close(fds[0]);
    1c96:	fa842503          	lw	a0,-88(s0)
    1c9a:	00005097          	auipc	ra,0x5
    1c9e:	b54080e7          	jalr	-1196(ra) # 67ee <close>
    for(n = 0; n < N; n++){
    1ca2:	0000cb17          	auipc	s6,0xc
    1ca6:	fd6b0b13          	addi	s6,s6,-42 # dc78 <buf>
    1caa:	416004bb          	negw	s1,s6
    1cae:	0ff4f493          	andi	s1,s1,255
    1cb2:	409b0993          	addi	s3,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
    1cb6:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
    1cb8:	6a85                	lui	s5,0x1
    1cba:	42da8a93          	addi	s5,s5,1069 # 142d <bigdir+0xc5>
{
    1cbe:	87da                	mv	a5,s6
        buf[i] = seq++;
    1cc0:	0097873b          	addw	a4,a5,s1
    1cc4:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    1cc8:	0785                	addi	a5,a5,1
    1cca:	fef99be3          	bne	s3,a5,1cc0 <pipe1+0xea>
        buf[i] = seq++;
    1cce:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
    1cd2:	40900613          	li	a2,1033
    1cd6:	85de                	mv	a1,s7
    1cd8:	fac42503          	lw	a0,-84(s0)
    1cdc:	00005097          	auipc	ra,0x5
    1ce0:	b0a080e7          	jalr	-1270(ra) # 67e6 <write>
    1ce4:	40900793          	li	a5,1033
    1ce8:	02f51063          	bne	a0,a5,1d08 <pipe1+0x132>
    for(n = 0; n < N; n++){
    1cec:	24a5                	addiw	s1,s1,9
    1cee:	0ff4f493          	andi	s1,s1,255
    1cf2:	fd5a16e3          	bne	s4,s5,1cbe <pipe1+0xe8>
    exit(0,"");
    1cf6:	00006597          	auipc	a1,0x6
    1cfa:	66258593          	addi	a1,a1,1634 # 8358 <malloc+0x172c>
    1cfe:	4501                	li	a0,0
    1d00:	00005097          	auipc	ra,0x5
    1d04:	ac6080e7          	jalr	-1338(ra) # 67c6 <exit>
        printf("%s: pipe1 oops 1\n", s);
    1d08:	85ca                	mv	a1,s2
    1d0a:	00006517          	auipc	a0,0x6
    1d0e:	a0650513          	addi	a0,a0,-1530 # 7710 <malloc+0xae4>
    1d12:	00005097          	auipc	ra,0x5
    1d16:	e5c080e7          	jalr	-420(ra) # 6b6e <printf>
        exit(1,"");
    1d1a:	00006597          	auipc	a1,0x6
    1d1e:	63e58593          	addi	a1,a1,1598 # 8358 <malloc+0x172c>
    1d22:	4505                	li	a0,1
    1d24:	00005097          	auipc	ra,0x5
    1d28:	aa2080e7          	jalr	-1374(ra) # 67c6 <exit>
          printf("%s: pipe1 oops 2\n", s);
    1d2c:	85ca                	mv	a1,s2
    1d2e:	00006517          	auipc	a0,0x6
    1d32:	9fa50513          	addi	a0,a0,-1542 # 7728 <malloc+0xafc>
    1d36:	00005097          	auipc	ra,0x5
    1d3a:	e38080e7          	jalr	-456(ra) # 6b6e <printf>
}
    1d3e:	60e6                	ld	ra,88(sp)
    1d40:	6446                	ld	s0,80(sp)
    1d42:	64a6                	ld	s1,72(sp)
    1d44:	6906                	ld	s2,64(sp)
    1d46:	79e2                	ld	s3,56(sp)
    1d48:	7a42                	ld	s4,48(sp)
    1d4a:	7aa2                	ld	s5,40(sp)
    1d4c:	7b02                	ld	s6,32(sp)
    1d4e:	6be2                	ld	s7,24(sp)
    1d50:	6125                	addi	sp,sp,96
    1d52:	8082                	ret
    if(total != N * SZ){
    1d54:	6785                	lui	a5,0x1
    1d56:	42d78793          	addi	a5,a5,1069 # 142d <bigdir+0xc5>
    1d5a:	02fa0463          	beq	s4,a5,1d82 <pipe1+0x1ac>
      printf("%s: pipe1 oops 3 total %d\n", total);
    1d5e:	85d2                	mv	a1,s4
    1d60:	00006517          	auipc	a0,0x6
    1d64:	9e050513          	addi	a0,a0,-1568 # 7740 <malloc+0xb14>
    1d68:	00005097          	auipc	ra,0x5
    1d6c:	e06080e7          	jalr	-506(ra) # 6b6e <printf>
      exit(1,"");
    1d70:	00006597          	auipc	a1,0x6
    1d74:	5e858593          	addi	a1,a1,1512 # 8358 <malloc+0x172c>
    1d78:	4505                	li	a0,1
    1d7a:	00005097          	auipc	ra,0x5
    1d7e:	a4c080e7          	jalr	-1460(ra) # 67c6 <exit>
    close(fds[0]);
    1d82:	fa842503          	lw	a0,-88(s0)
    1d86:	00005097          	auipc	ra,0x5
    1d8a:	a68080e7          	jalr	-1432(ra) # 67ee <close>
    wait(&xstatus,"");
    1d8e:	00006597          	auipc	a1,0x6
    1d92:	5ca58593          	addi	a1,a1,1482 # 8358 <malloc+0x172c>
    1d96:	fa440513          	addi	a0,s0,-92
    1d9a:	00005097          	auipc	ra,0x5
    1d9e:	a34080e7          	jalr	-1484(ra) # 67ce <wait>
    exit(xstatus,"");
    1da2:	00006597          	auipc	a1,0x6
    1da6:	5b658593          	addi	a1,a1,1462 # 8358 <malloc+0x172c>
    1daa:	fa442503          	lw	a0,-92(s0)
    1dae:	00005097          	auipc	ra,0x5
    1db2:	a18080e7          	jalr	-1512(ra) # 67c6 <exit>
    printf("%s: fork() failed\n", s);
    1db6:	85ca                	mv	a1,s2
    1db8:	00006517          	auipc	a0,0x6
    1dbc:	9a850513          	addi	a0,a0,-1624 # 7760 <malloc+0xb34>
    1dc0:	00005097          	auipc	ra,0x5
    1dc4:	dae080e7          	jalr	-594(ra) # 6b6e <printf>
    exit(1,"");
    1dc8:	00006597          	auipc	a1,0x6
    1dcc:	59058593          	addi	a1,a1,1424 # 8358 <malloc+0x172c>
    1dd0:	4505                	li	a0,1
    1dd2:	00005097          	auipc	ra,0x5
    1dd6:	9f4080e7          	jalr	-1548(ra) # 67c6 <exit>

0000000000001dda <exitwait>:
{
    1dda:	715d                	addi	sp,sp,-80
    1ddc:	e486                	sd	ra,72(sp)
    1dde:	e0a2                	sd	s0,64(sp)
    1de0:	fc26                	sd	s1,56(sp)
    1de2:	f84a                	sd	s2,48(sp)
    1de4:	f44e                	sd	s3,40(sp)
    1de6:	f052                	sd	s4,32(sp)
    1de8:	ec56                	sd	s5,24(sp)
    1dea:	0880                	addi	s0,sp,80
    1dec:	8aaa                	mv	s5,a0
  for(i = 0; i < 100; i++){
    1dee:	4901                	li	s2,0
      if(wait(&xstate,"") != pid){
    1df0:	00006997          	auipc	s3,0x6
    1df4:	56898993          	addi	s3,s3,1384 # 8358 <malloc+0x172c>
  for(i = 0; i < 100; i++){
    1df8:	06400a13          	li	s4,100
    pid = fork();
    1dfc:	00005097          	auipc	ra,0x5
    1e00:	9c2080e7          	jalr	-1598(ra) # 67be <fork>
    1e04:	84aa                	mv	s1,a0
    if(pid < 0){
    1e06:	02054c63          	bltz	a0,1e3e <exitwait+0x64>
    if(pid){
    1e0a:	c145                	beqz	a0,1eaa <exitwait+0xd0>
      if(wait(&xstate,"") != pid){
    1e0c:	85ce                	mv	a1,s3
    1e0e:	fbc40513          	addi	a0,s0,-68
    1e12:	00005097          	auipc	ra,0x5
    1e16:	9bc080e7          	jalr	-1604(ra) # 67ce <wait>
    1e1a:	04951463          	bne	a0,s1,1e62 <exitwait+0x88>
      if(i != xstate) {
    1e1e:	fbc42783          	lw	a5,-68(s0)
    1e22:	07279263          	bne	a5,s2,1e86 <exitwait+0xac>
  for(i = 0; i < 100; i++){
    1e26:	2905                	addiw	s2,s2,1
    1e28:	fd491ae3          	bne	s2,s4,1dfc <exitwait+0x22>
}
    1e2c:	60a6                	ld	ra,72(sp)
    1e2e:	6406                	ld	s0,64(sp)
    1e30:	74e2                	ld	s1,56(sp)
    1e32:	7942                	ld	s2,48(sp)
    1e34:	79a2                	ld	s3,40(sp)
    1e36:	7a02                	ld	s4,32(sp)
    1e38:	6ae2                	ld	s5,24(sp)
    1e3a:	6161                	addi	sp,sp,80
    1e3c:	8082                	ret
      printf("%s: fork failed\n", s);
    1e3e:	85d6                	mv	a1,s5
    1e40:	00005517          	auipc	a0,0x5
    1e44:	7b050513          	addi	a0,a0,1968 # 75f0 <malloc+0x9c4>
    1e48:	00005097          	auipc	ra,0x5
    1e4c:	d26080e7          	jalr	-730(ra) # 6b6e <printf>
      exit(1,"");
    1e50:	00006597          	auipc	a1,0x6
    1e54:	50858593          	addi	a1,a1,1288 # 8358 <malloc+0x172c>
    1e58:	4505                	li	a0,1
    1e5a:	00005097          	auipc	ra,0x5
    1e5e:	96c080e7          	jalr	-1684(ra) # 67c6 <exit>
        printf("%s: wait wrong pid\n", s);
    1e62:	85d6                	mv	a1,s5
    1e64:	00006517          	auipc	a0,0x6
    1e68:	91450513          	addi	a0,a0,-1772 # 7778 <malloc+0xb4c>
    1e6c:	00005097          	auipc	ra,0x5
    1e70:	d02080e7          	jalr	-766(ra) # 6b6e <printf>
        exit(1,"");
    1e74:	00006597          	auipc	a1,0x6
    1e78:	4e458593          	addi	a1,a1,1252 # 8358 <malloc+0x172c>
    1e7c:	4505                	li	a0,1
    1e7e:	00005097          	auipc	ra,0x5
    1e82:	948080e7          	jalr	-1720(ra) # 67c6 <exit>
        printf("%s: wait wrong exit status\n", s);
    1e86:	85d6                	mv	a1,s5
    1e88:	00006517          	auipc	a0,0x6
    1e8c:	90850513          	addi	a0,a0,-1784 # 7790 <malloc+0xb64>
    1e90:	00005097          	auipc	ra,0x5
    1e94:	cde080e7          	jalr	-802(ra) # 6b6e <printf>
        exit(1,"");
    1e98:	00006597          	auipc	a1,0x6
    1e9c:	4c058593          	addi	a1,a1,1216 # 8358 <malloc+0x172c>
    1ea0:	4505                	li	a0,1
    1ea2:	00005097          	auipc	ra,0x5
    1ea6:	924080e7          	jalr	-1756(ra) # 67c6 <exit>
      exit(i,"");
    1eaa:	00006597          	auipc	a1,0x6
    1eae:	4ae58593          	addi	a1,a1,1198 # 8358 <malloc+0x172c>
    1eb2:	854a                	mv	a0,s2
    1eb4:	00005097          	auipc	ra,0x5
    1eb8:	912080e7          	jalr	-1774(ra) # 67c6 <exit>

0000000000001ebc <twochildren>:
{
    1ebc:	7179                	addi	sp,sp,-48
    1ebe:	f406                	sd	ra,40(sp)
    1ec0:	f022                	sd	s0,32(sp)
    1ec2:	ec26                	sd	s1,24(sp)
    1ec4:	e84a                	sd	s2,16(sp)
    1ec6:	e44e                	sd	s3,8(sp)
    1ec8:	1800                	addi	s0,sp,48
    1eca:	89aa                	mv	s3,a0
    1ecc:	3e800493          	li	s1,1000
        wait(0,"");
    1ed0:	00006917          	auipc	s2,0x6
    1ed4:	48890913          	addi	s2,s2,1160 # 8358 <malloc+0x172c>
    int pid1 = fork();
    1ed8:	00005097          	auipc	ra,0x5
    1edc:	8e6080e7          	jalr	-1818(ra) # 67be <fork>
    if(pid1 < 0){
    1ee0:	02054f63          	bltz	a0,1f1e <twochildren+0x62>
    if(pid1 == 0){
    1ee4:	cd39                	beqz	a0,1f42 <twochildren+0x86>
      int pid2 = fork();
    1ee6:	00005097          	auipc	ra,0x5
    1eea:	8d8080e7          	jalr	-1832(ra) # 67be <fork>
      if(pid2 < 0){
    1eee:	06054263          	bltz	a0,1f52 <twochildren+0x96>
      if(pid2 == 0){
    1ef2:	c151                	beqz	a0,1f76 <twochildren+0xba>
        wait(0,"");
    1ef4:	85ca                	mv	a1,s2
    1ef6:	4501                	li	a0,0
    1ef8:	00005097          	auipc	ra,0x5
    1efc:	8d6080e7          	jalr	-1834(ra) # 67ce <wait>
        wait(0,"");
    1f00:	85ca                	mv	a1,s2
    1f02:	4501                	li	a0,0
    1f04:	00005097          	auipc	ra,0x5
    1f08:	8ca080e7          	jalr	-1846(ra) # 67ce <wait>
  for(int i = 0; i < 1000; i++){
    1f0c:	34fd                	addiw	s1,s1,-1
    1f0e:	f4e9                	bnez	s1,1ed8 <twochildren+0x1c>
}
    1f10:	70a2                	ld	ra,40(sp)
    1f12:	7402                	ld	s0,32(sp)
    1f14:	64e2                	ld	s1,24(sp)
    1f16:	6942                	ld	s2,16(sp)
    1f18:	69a2                	ld	s3,8(sp)
    1f1a:	6145                	addi	sp,sp,48
    1f1c:	8082                	ret
      printf("%s: fork failed\n", s);
    1f1e:	85ce                	mv	a1,s3
    1f20:	00005517          	auipc	a0,0x5
    1f24:	6d050513          	addi	a0,a0,1744 # 75f0 <malloc+0x9c4>
    1f28:	00005097          	auipc	ra,0x5
    1f2c:	c46080e7          	jalr	-954(ra) # 6b6e <printf>
      exit(1,"");
    1f30:	00006597          	auipc	a1,0x6
    1f34:	42858593          	addi	a1,a1,1064 # 8358 <malloc+0x172c>
    1f38:	4505                	li	a0,1
    1f3a:	00005097          	auipc	ra,0x5
    1f3e:	88c080e7          	jalr	-1908(ra) # 67c6 <exit>
      exit(0,"");
    1f42:	00006597          	auipc	a1,0x6
    1f46:	41658593          	addi	a1,a1,1046 # 8358 <malloc+0x172c>
    1f4a:	00005097          	auipc	ra,0x5
    1f4e:	87c080e7          	jalr	-1924(ra) # 67c6 <exit>
        printf("%s: fork failed\n", s);
    1f52:	85ce                	mv	a1,s3
    1f54:	00005517          	auipc	a0,0x5
    1f58:	69c50513          	addi	a0,a0,1692 # 75f0 <malloc+0x9c4>
    1f5c:	00005097          	auipc	ra,0x5
    1f60:	c12080e7          	jalr	-1006(ra) # 6b6e <printf>
        exit(1,"");
    1f64:	00006597          	auipc	a1,0x6
    1f68:	3f458593          	addi	a1,a1,1012 # 8358 <malloc+0x172c>
    1f6c:	4505                	li	a0,1
    1f6e:	00005097          	auipc	ra,0x5
    1f72:	858080e7          	jalr	-1960(ra) # 67c6 <exit>
        exit(0,"");
    1f76:	00006597          	auipc	a1,0x6
    1f7a:	3e258593          	addi	a1,a1,994 # 8358 <malloc+0x172c>
    1f7e:	00005097          	auipc	ra,0x5
    1f82:	848080e7          	jalr	-1976(ra) # 67c6 <exit>

0000000000001f86 <forkfork>:
{
    1f86:	7179                	addi	sp,sp,-48
    1f88:	f406                	sd	ra,40(sp)
    1f8a:	f022                	sd	s0,32(sp)
    1f8c:	ec26                	sd	s1,24(sp)
    1f8e:	e84a                	sd	s2,16(sp)
    1f90:	1800                	addi	s0,sp,48
    1f92:	84aa                	mv	s1,a0
    int pid = fork();
    1f94:	00005097          	auipc	ra,0x5
    1f98:	82a080e7          	jalr	-2006(ra) # 67be <fork>
    if(pid < 0){
    1f9c:	04054a63          	bltz	a0,1ff0 <forkfork+0x6a>
    if(pid == 0){
    1fa0:	c935                	beqz	a0,2014 <forkfork+0x8e>
    int pid = fork();
    1fa2:	00005097          	auipc	ra,0x5
    1fa6:	81c080e7          	jalr	-2020(ra) # 67be <fork>
    if(pid < 0){
    1faa:	04054363          	bltz	a0,1ff0 <forkfork+0x6a>
    if(pid == 0){
    1fae:	c13d                	beqz	a0,2014 <forkfork+0x8e>
    wait(&xstatus,"");
    1fb0:	00006597          	auipc	a1,0x6
    1fb4:	3a858593          	addi	a1,a1,936 # 8358 <malloc+0x172c>
    1fb8:	fdc40513          	addi	a0,s0,-36
    1fbc:	00005097          	auipc	ra,0x5
    1fc0:	812080e7          	jalr	-2030(ra) # 67ce <wait>
    if(xstatus != 0) {
    1fc4:	fdc42783          	lw	a5,-36(s0)
    1fc8:	e7cd                	bnez	a5,2072 <forkfork+0xec>
    wait(&xstatus,"");
    1fca:	00006597          	auipc	a1,0x6
    1fce:	38e58593          	addi	a1,a1,910 # 8358 <malloc+0x172c>
    1fd2:	fdc40513          	addi	a0,s0,-36
    1fd6:	00004097          	auipc	ra,0x4
    1fda:	7f8080e7          	jalr	2040(ra) # 67ce <wait>
    if(xstatus != 0) {
    1fde:	fdc42783          	lw	a5,-36(s0)
    1fe2:	ebc1                	bnez	a5,2072 <forkfork+0xec>
}
    1fe4:	70a2                	ld	ra,40(sp)
    1fe6:	7402                	ld	s0,32(sp)
    1fe8:	64e2                	ld	s1,24(sp)
    1fea:	6942                	ld	s2,16(sp)
    1fec:	6145                	addi	sp,sp,48
    1fee:	8082                	ret
      printf("%s: fork failed", s);
    1ff0:	85a6                	mv	a1,s1
    1ff2:	00005517          	auipc	a0,0x5
    1ff6:	7be50513          	addi	a0,a0,1982 # 77b0 <malloc+0xb84>
    1ffa:	00005097          	auipc	ra,0x5
    1ffe:	b74080e7          	jalr	-1164(ra) # 6b6e <printf>
      exit(1,"");
    2002:	00006597          	auipc	a1,0x6
    2006:	35658593          	addi	a1,a1,854 # 8358 <malloc+0x172c>
    200a:	4505                	li	a0,1
    200c:	00004097          	auipc	ra,0x4
    2010:	7ba080e7          	jalr	1978(ra) # 67c6 <exit>
{
    2014:	0c800493          	li	s1,200
        wait(0,"");
    2018:	00006917          	auipc	s2,0x6
    201c:	34090913          	addi	s2,s2,832 # 8358 <malloc+0x172c>
        int pid1 = fork();
    2020:	00004097          	auipc	ra,0x4
    2024:	79e080e7          	jalr	1950(ra) # 67be <fork>
        if(pid1 < 0){
    2028:	02054463          	bltz	a0,2050 <forkfork+0xca>
        if(pid1 == 0){
    202c:	c91d                	beqz	a0,2062 <forkfork+0xdc>
        wait(0,"");
    202e:	85ca                	mv	a1,s2
    2030:	4501                	li	a0,0
    2032:	00004097          	auipc	ra,0x4
    2036:	79c080e7          	jalr	1948(ra) # 67ce <wait>
      for(int j = 0; j < 200; j++){
    203a:	34fd                	addiw	s1,s1,-1
    203c:	f0f5                	bnez	s1,2020 <forkfork+0x9a>
      exit(0,"");
    203e:	00006597          	auipc	a1,0x6
    2042:	31a58593          	addi	a1,a1,794 # 8358 <malloc+0x172c>
    2046:	4501                	li	a0,0
    2048:	00004097          	auipc	ra,0x4
    204c:	77e080e7          	jalr	1918(ra) # 67c6 <exit>
          exit(1,"");
    2050:	00006597          	auipc	a1,0x6
    2054:	30858593          	addi	a1,a1,776 # 8358 <malloc+0x172c>
    2058:	4505                	li	a0,1
    205a:	00004097          	auipc	ra,0x4
    205e:	76c080e7          	jalr	1900(ra) # 67c6 <exit>
          exit(0,"");
    2062:	00006597          	auipc	a1,0x6
    2066:	2f658593          	addi	a1,a1,758 # 8358 <malloc+0x172c>
    206a:	00004097          	auipc	ra,0x4
    206e:	75c080e7          	jalr	1884(ra) # 67c6 <exit>
      printf("%s: fork in child failed", s);
    2072:	85a6                	mv	a1,s1
    2074:	00005517          	auipc	a0,0x5
    2078:	74c50513          	addi	a0,a0,1868 # 77c0 <malloc+0xb94>
    207c:	00005097          	auipc	ra,0x5
    2080:	af2080e7          	jalr	-1294(ra) # 6b6e <printf>
      exit(1,"");
    2084:	00006597          	auipc	a1,0x6
    2088:	2d458593          	addi	a1,a1,724 # 8358 <malloc+0x172c>
    208c:	4505                	li	a0,1
    208e:	00004097          	auipc	ra,0x4
    2092:	738080e7          	jalr	1848(ra) # 67c6 <exit>

0000000000002096 <reparent2>:
{
    2096:	1101                	addi	sp,sp,-32
    2098:	ec06                	sd	ra,24(sp)
    209a:	e822                	sd	s0,16(sp)
    209c:	e426                	sd	s1,8(sp)
    209e:	e04a                	sd	s2,0(sp)
    20a0:	1000                	addi	s0,sp,32
    20a2:	32000493          	li	s1,800
    wait(0,"");
    20a6:	00006917          	auipc	s2,0x6
    20aa:	2b290913          	addi	s2,s2,690 # 8358 <malloc+0x172c>
    int pid1 = fork();
    20ae:	00004097          	auipc	ra,0x4
    20b2:	710080e7          	jalr	1808(ra) # 67be <fork>
    if(pid1 < 0){
    20b6:	02054463          	bltz	a0,20de <reparent2+0x48>
    if(pid1 == 0){
    20ba:	c139                	beqz	a0,2100 <reparent2+0x6a>
    wait(0,"");
    20bc:	85ca                	mv	a1,s2
    20be:	4501                	li	a0,0
    20c0:	00004097          	auipc	ra,0x4
    20c4:	70e080e7          	jalr	1806(ra) # 67ce <wait>
  for(int i = 0; i < 800; i++){
    20c8:	34fd                	addiw	s1,s1,-1
    20ca:	f0f5                	bnez	s1,20ae <reparent2+0x18>
  exit(0,"");
    20cc:	00006597          	auipc	a1,0x6
    20d0:	28c58593          	addi	a1,a1,652 # 8358 <malloc+0x172c>
    20d4:	4501                	li	a0,0
    20d6:	00004097          	auipc	ra,0x4
    20da:	6f0080e7          	jalr	1776(ra) # 67c6 <exit>
      printf("fork failed\n");
    20de:	00006517          	auipc	a0,0x6
    20e2:	91a50513          	addi	a0,a0,-1766 # 79f8 <malloc+0xdcc>
    20e6:	00005097          	auipc	ra,0x5
    20ea:	a88080e7          	jalr	-1400(ra) # 6b6e <printf>
      exit(1,"");
    20ee:	00006597          	auipc	a1,0x6
    20f2:	26a58593          	addi	a1,a1,618 # 8358 <malloc+0x172c>
    20f6:	4505                	li	a0,1
    20f8:	00004097          	auipc	ra,0x4
    20fc:	6ce080e7          	jalr	1742(ra) # 67c6 <exit>
      fork();
    2100:	00004097          	auipc	ra,0x4
    2104:	6be080e7          	jalr	1726(ra) # 67be <fork>
      fork();
    2108:	00004097          	auipc	ra,0x4
    210c:	6b6080e7          	jalr	1718(ra) # 67be <fork>
      exit(0,"");
    2110:	00006597          	auipc	a1,0x6
    2114:	24858593          	addi	a1,a1,584 # 8358 <malloc+0x172c>
    2118:	4501                	li	a0,0
    211a:	00004097          	auipc	ra,0x4
    211e:	6ac080e7          	jalr	1708(ra) # 67c6 <exit>

0000000000002122 <createdelete>:
{
    2122:	7175                	addi	sp,sp,-144
    2124:	e506                	sd	ra,136(sp)
    2126:	e122                	sd	s0,128(sp)
    2128:	fca6                	sd	s1,120(sp)
    212a:	f8ca                	sd	s2,112(sp)
    212c:	f4ce                	sd	s3,104(sp)
    212e:	f0d2                	sd	s4,96(sp)
    2130:	ecd6                	sd	s5,88(sp)
    2132:	e8da                	sd	s6,80(sp)
    2134:	e4de                	sd	s7,72(sp)
    2136:	e0e2                	sd	s8,64(sp)
    2138:	fc66                	sd	s9,56(sp)
    213a:	0900                	addi	s0,sp,144
    213c:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
    213e:	4901                	li	s2,0
    2140:	4991                	li	s3,4
    pid = fork();
    2142:	00004097          	auipc	ra,0x4
    2146:	67c080e7          	jalr	1660(ra) # 67be <fork>
    214a:	84aa                	mv	s1,a0
    if(pid < 0){
    214c:	04054463          	bltz	a0,2194 <createdelete+0x72>
    if(pid == 0){
    2150:	c525                	beqz	a0,21b8 <createdelete+0x96>
  for(pi = 0; pi < NCHILD; pi++){
    2152:	2905                	addiw	s2,s2,1
    2154:	ff3917e3          	bne	s2,s3,2142 <createdelete+0x20>
    2158:	4491                	li	s1,4
    wait(&xstatus,"");
    215a:	00006997          	auipc	s3,0x6
    215e:	1fe98993          	addi	s3,s3,510 # 8358 <malloc+0x172c>
    2162:	85ce                	mv	a1,s3
    2164:	f7c40513          	addi	a0,s0,-132
    2168:	00004097          	auipc	ra,0x4
    216c:	666080e7          	jalr	1638(ra) # 67ce <wait>
    if(xstatus != 0)
    2170:	f7c42903          	lw	s2,-132(s0)
    2174:	10091263          	bnez	s2,2278 <createdelete+0x156>
  for(pi = 0; pi < NCHILD; pi++){
    2178:	34fd                	addiw	s1,s1,-1
    217a:	f4e5                	bnez	s1,2162 <createdelete+0x40>
  name[0] = name[1] = name[2] = 0;
    217c:	f8040123          	sb	zero,-126(s0)
    2180:	03000993          	li	s3,48
    2184:	5a7d                	li	s4,-1
    2186:	07000c13          	li	s8,112
      } else if((i >= 1 && i < N/2) && fd >= 0){
    218a:	4b21                	li	s6,8
      if((i == 0 || i >= N/2) && fd < 0){
    218c:	4ba5                	li	s7,9
    for(pi = 0; pi < NCHILD; pi++){
    218e:	07400a93          	li	s5,116
    2192:	aa79                	j	2330 <createdelete+0x20e>
      printf("fork failed\n", s);
    2194:	85e6                	mv	a1,s9
    2196:	00006517          	auipc	a0,0x6
    219a:	86250513          	addi	a0,a0,-1950 # 79f8 <malloc+0xdcc>
    219e:	00005097          	auipc	ra,0x5
    21a2:	9d0080e7          	jalr	-1584(ra) # 6b6e <printf>
      exit(1,"");
    21a6:	00006597          	auipc	a1,0x6
    21aa:	1b258593          	addi	a1,a1,434 # 8358 <malloc+0x172c>
    21ae:	4505                	li	a0,1
    21b0:	00004097          	auipc	ra,0x4
    21b4:	616080e7          	jalr	1558(ra) # 67c6 <exit>
      name[0] = 'p' + pi;
    21b8:	0709091b          	addiw	s2,s2,112
    21bc:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    21c0:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
    21c4:	4951                	li	s2,20
    21c6:	a035                	j	21f2 <createdelete+0xd0>
          printf("%s: create failed\n", s);
    21c8:	85e6                	mv	a1,s9
    21ca:	00005517          	auipc	a0,0x5
    21ce:	4be50513          	addi	a0,a0,1214 # 7688 <malloc+0xa5c>
    21d2:	00005097          	auipc	ra,0x5
    21d6:	99c080e7          	jalr	-1636(ra) # 6b6e <printf>
          exit(1,"");
    21da:	00006597          	auipc	a1,0x6
    21de:	17e58593          	addi	a1,a1,382 # 8358 <malloc+0x172c>
    21e2:	4505                	li	a0,1
    21e4:	00004097          	auipc	ra,0x4
    21e8:	5e2080e7          	jalr	1506(ra) # 67c6 <exit>
      for(i = 0; i < N; i++){
    21ec:	2485                	addiw	s1,s1,1
    21ee:	07248c63          	beq	s1,s2,2266 <createdelete+0x144>
        name[1] = '0' + i;
    21f2:	0304879b          	addiw	a5,s1,48
    21f6:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    21fa:	20200593          	li	a1,514
    21fe:	f8040513          	addi	a0,s0,-128
    2202:	00004097          	auipc	ra,0x4
    2206:	604080e7          	jalr	1540(ra) # 6806 <open>
        if(fd < 0){
    220a:	fa054fe3          	bltz	a0,21c8 <createdelete+0xa6>
        close(fd);
    220e:	00004097          	auipc	ra,0x4
    2212:	5e0080e7          	jalr	1504(ra) # 67ee <close>
        if(i > 0 && (i % 2 ) == 0){
    2216:	fc905be3          	blez	s1,21ec <createdelete+0xca>
    221a:	0014f793          	andi	a5,s1,1
    221e:	f7f9                	bnez	a5,21ec <createdelete+0xca>
          name[1] = '0' + (i / 2);
    2220:	01f4d79b          	srliw	a5,s1,0x1f
    2224:	9fa5                	addw	a5,a5,s1
    2226:	4017d79b          	sraiw	a5,a5,0x1
    222a:	0307879b          	addiw	a5,a5,48
    222e:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    2232:	f8040513          	addi	a0,s0,-128
    2236:	00004097          	auipc	ra,0x4
    223a:	5e0080e7          	jalr	1504(ra) # 6816 <unlink>
    223e:	fa0557e3          	bgez	a0,21ec <createdelete+0xca>
            printf("%s: unlink failed\n", s);
    2242:	85e6                	mv	a1,s9
    2244:	00005517          	auipc	a0,0x5
    2248:	59c50513          	addi	a0,a0,1436 # 77e0 <malloc+0xbb4>
    224c:	00005097          	auipc	ra,0x5
    2250:	922080e7          	jalr	-1758(ra) # 6b6e <printf>
            exit(1,"");
    2254:	00006597          	auipc	a1,0x6
    2258:	10458593          	addi	a1,a1,260 # 8358 <malloc+0x172c>
    225c:	4505                	li	a0,1
    225e:	00004097          	auipc	ra,0x4
    2262:	568080e7          	jalr	1384(ra) # 67c6 <exit>
      exit(0,"");
    2266:	00006597          	auipc	a1,0x6
    226a:	0f258593          	addi	a1,a1,242 # 8358 <malloc+0x172c>
    226e:	4501                	li	a0,0
    2270:	00004097          	auipc	ra,0x4
    2274:	556080e7          	jalr	1366(ra) # 67c6 <exit>
      exit(1,"");
    2278:	00006597          	auipc	a1,0x6
    227c:	0e058593          	addi	a1,a1,224 # 8358 <malloc+0x172c>
    2280:	4505                	li	a0,1
    2282:	00004097          	auipc	ra,0x4
    2286:	544080e7          	jalr	1348(ra) # 67c6 <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    228a:	f8040613          	addi	a2,s0,-128
    228e:	85e6                	mv	a1,s9
    2290:	00005517          	auipc	a0,0x5
    2294:	56850513          	addi	a0,a0,1384 # 77f8 <malloc+0xbcc>
    2298:	00005097          	auipc	ra,0x5
    229c:	8d6080e7          	jalr	-1834(ra) # 6b6e <printf>
        exit(1,"");
    22a0:	00006597          	auipc	a1,0x6
    22a4:	0b858593          	addi	a1,a1,184 # 8358 <malloc+0x172c>
    22a8:	4505                	li	a0,1
    22aa:	00004097          	auipc	ra,0x4
    22ae:	51c080e7          	jalr	1308(ra) # 67c6 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    22b2:	054b7163          	bgeu	s6,s4,22f4 <createdelete+0x1d2>
      if(fd >= 0)
    22b6:	02055a63          	bgez	a0,22ea <createdelete+0x1c8>
    for(pi = 0; pi < NCHILD; pi++){
    22ba:	2485                	addiw	s1,s1,1
    22bc:	0ff4f493          	andi	s1,s1,255
    22c0:	07548063          	beq	s1,s5,2320 <createdelete+0x1fe>
      name[0] = 'p' + pi;
    22c4:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    22c8:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    22cc:	4581                	li	a1,0
    22ce:	f8040513          	addi	a0,s0,-128
    22d2:	00004097          	auipc	ra,0x4
    22d6:	534080e7          	jalr	1332(ra) # 6806 <open>
      if((i == 0 || i >= N/2) && fd < 0){
    22da:	00090463          	beqz	s2,22e2 <createdelete+0x1c0>
    22de:	fd2bdae3          	bge	s7,s2,22b2 <createdelete+0x190>
    22e2:	fa0544e3          	bltz	a0,228a <createdelete+0x168>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    22e6:	014b7963          	bgeu	s6,s4,22f8 <createdelete+0x1d6>
        close(fd);
    22ea:	00004097          	auipc	ra,0x4
    22ee:	504080e7          	jalr	1284(ra) # 67ee <close>
    22f2:	b7e1                	j	22ba <createdelete+0x198>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    22f4:	fc0543e3          	bltz	a0,22ba <createdelete+0x198>
        printf("%s: oops createdelete %s did exist\n", s, name);
    22f8:	f8040613          	addi	a2,s0,-128
    22fc:	85e6                	mv	a1,s9
    22fe:	00005517          	auipc	a0,0x5
    2302:	52250513          	addi	a0,a0,1314 # 7820 <malloc+0xbf4>
    2306:	00005097          	auipc	ra,0x5
    230a:	868080e7          	jalr	-1944(ra) # 6b6e <printf>
        exit(1,"");
    230e:	00006597          	auipc	a1,0x6
    2312:	04a58593          	addi	a1,a1,74 # 8358 <malloc+0x172c>
    2316:	4505                	li	a0,1
    2318:	00004097          	auipc	ra,0x4
    231c:	4ae080e7          	jalr	1198(ra) # 67c6 <exit>
  for(i = 0; i < N; i++){
    2320:	2905                	addiw	s2,s2,1
    2322:	2a05                	addiw	s4,s4,1
    2324:	2985                	addiw	s3,s3,1
    2326:	0ff9f993          	andi	s3,s3,255
    232a:	47d1                	li	a5,20
    232c:	02f90a63          	beq	s2,a5,2360 <createdelete+0x23e>
    for(pi = 0; pi < NCHILD; pi++){
    2330:	84e2                	mv	s1,s8
    2332:	bf49                	j	22c4 <createdelete+0x1a2>
  for(i = 0; i < N; i++){
    2334:	2905                	addiw	s2,s2,1
    2336:	0ff97913          	andi	s2,s2,255
    233a:	2985                	addiw	s3,s3,1
    233c:	0ff9f993          	andi	s3,s3,255
    2340:	03490863          	beq	s2,s4,2370 <createdelete+0x24e>
  name[0] = name[1] = name[2] = 0;
    2344:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
    2346:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    234a:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    234e:	f8040513          	addi	a0,s0,-128
    2352:	00004097          	auipc	ra,0x4
    2356:	4c4080e7          	jalr	1220(ra) # 6816 <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    235a:	34fd                	addiw	s1,s1,-1
    235c:	f4ed                	bnez	s1,2346 <createdelete+0x224>
    235e:	bfd9                	j	2334 <createdelete+0x212>
    2360:	03000993          	li	s3,48
    2364:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    2368:	4a91                	li	s5,4
  for(i = 0; i < N; i++){
    236a:	08400a13          	li	s4,132
    236e:	bfd9                	j	2344 <createdelete+0x222>
}
    2370:	60aa                	ld	ra,136(sp)
    2372:	640a                	ld	s0,128(sp)
    2374:	74e6                	ld	s1,120(sp)
    2376:	7946                	ld	s2,112(sp)
    2378:	79a6                	ld	s3,104(sp)
    237a:	7a06                	ld	s4,96(sp)
    237c:	6ae6                	ld	s5,88(sp)
    237e:	6b46                	ld	s6,80(sp)
    2380:	6ba6                	ld	s7,72(sp)
    2382:	6c06                	ld	s8,64(sp)
    2384:	7ce2                	ld	s9,56(sp)
    2386:	6149                	addi	sp,sp,144
    2388:	8082                	ret

000000000000238a <linkunlink>:
{
    238a:	711d                	addi	sp,sp,-96
    238c:	ec86                	sd	ra,88(sp)
    238e:	e8a2                	sd	s0,80(sp)
    2390:	e4a6                	sd	s1,72(sp)
    2392:	e0ca                	sd	s2,64(sp)
    2394:	fc4e                	sd	s3,56(sp)
    2396:	f852                	sd	s4,48(sp)
    2398:	f456                	sd	s5,40(sp)
    239a:	f05a                	sd	s6,32(sp)
    239c:	ec5e                	sd	s7,24(sp)
    239e:	e862                	sd	s8,16(sp)
    23a0:	e466                	sd	s9,8(sp)
    23a2:	1080                	addi	s0,sp,96
    23a4:	84aa                	mv	s1,a0
  unlink("x");
    23a6:	00005517          	auipc	a0,0x5
    23aa:	a3250513          	addi	a0,a0,-1486 # 6dd8 <malloc+0x1ac>
    23ae:	00004097          	auipc	ra,0x4
    23b2:	468080e7          	jalr	1128(ra) # 6816 <unlink>
  pid = fork();
    23b6:	00004097          	auipc	ra,0x4
    23ba:	408080e7          	jalr	1032(ra) # 67be <fork>
  if(pid < 0){
    23be:	02054b63          	bltz	a0,23f4 <linkunlink+0x6a>
    23c2:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    23c4:	4c85                	li	s9,1
    23c6:	e119                	bnez	a0,23cc <linkunlink+0x42>
    23c8:	06100c93          	li	s9,97
    23cc:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    23d0:	41c659b7          	lui	s3,0x41c65
    23d4:	e6d9899b          	addiw	s3,s3,-403
    23d8:	690d                	lui	s2,0x3
    23da:	0399091b          	addiw	s2,s2,57
    if((x % 3) == 0){
    23de:	4a0d                	li	s4,3
    } else if((x % 3) == 1){
    23e0:	4b05                	li	s6,1
      unlink("x");
    23e2:	00005a97          	auipc	s5,0x5
    23e6:	9f6a8a93          	addi	s5,s5,-1546 # 6dd8 <malloc+0x1ac>
      link("cat", "x");
    23ea:	00005b97          	auipc	s7,0x5
    23ee:	45eb8b93          	addi	s7,s7,1118 # 7848 <malloc+0xc1c>
    23f2:	a081                	j	2432 <linkunlink+0xa8>
    printf("%s: fork failed\n", s);
    23f4:	85a6                	mv	a1,s1
    23f6:	00005517          	auipc	a0,0x5
    23fa:	1fa50513          	addi	a0,a0,506 # 75f0 <malloc+0x9c4>
    23fe:	00004097          	auipc	ra,0x4
    2402:	770080e7          	jalr	1904(ra) # 6b6e <printf>
    exit(1,"");
    2406:	00006597          	auipc	a1,0x6
    240a:	f5258593          	addi	a1,a1,-174 # 8358 <malloc+0x172c>
    240e:	4505                	li	a0,1
    2410:	00004097          	auipc	ra,0x4
    2414:	3b6080e7          	jalr	950(ra) # 67c6 <exit>
      close(open("x", O_RDWR | O_CREATE));
    2418:	20200593          	li	a1,514
    241c:	8556                	mv	a0,s5
    241e:	00004097          	auipc	ra,0x4
    2422:	3e8080e7          	jalr	1000(ra) # 6806 <open>
    2426:	00004097          	auipc	ra,0x4
    242a:	3c8080e7          	jalr	968(ra) # 67ee <close>
  for(i = 0; i < 100; i++){
    242e:	34fd                	addiw	s1,s1,-1
    2430:	c88d                	beqz	s1,2462 <linkunlink+0xd8>
    x = x * 1103515245 + 12345;
    2432:	033c87bb          	mulw	a5,s9,s3
    2436:	012787bb          	addw	a5,a5,s2
    243a:	00078c9b          	sext.w	s9,a5
    if((x % 3) == 0){
    243e:	0347f7bb          	remuw	a5,a5,s4
    2442:	dbf9                	beqz	a5,2418 <linkunlink+0x8e>
    } else if((x % 3) == 1){
    2444:	01678863          	beq	a5,s6,2454 <linkunlink+0xca>
      unlink("x");
    2448:	8556                	mv	a0,s5
    244a:	00004097          	auipc	ra,0x4
    244e:	3cc080e7          	jalr	972(ra) # 6816 <unlink>
    2452:	bff1                	j	242e <linkunlink+0xa4>
      link("cat", "x");
    2454:	85d6                	mv	a1,s5
    2456:	855e                	mv	a0,s7
    2458:	00004097          	auipc	ra,0x4
    245c:	3ce080e7          	jalr	974(ra) # 6826 <link>
    2460:	b7f9                	j	242e <linkunlink+0xa4>
  if(pid)
    2462:	020c0863          	beqz	s8,2492 <linkunlink+0x108>
    wait(0,"");
    2466:	00006597          	auipc	a1,0x6
    246a:	ef258593          	addi	a1,a1,-270 # 8358 <malloc+0x172c>
    246e:	4501                	li	a0,0
    2470:	00004097          	auipc	ra,0x4
    2474:	35e080e7          	jalr	862(ra) # 67ce <wait>
}
    2478:	60e6                	ld	ra,88(sp)
    247a:	6446                	ld	s0,80(sp)
    247c:	64a6                	ld	s1,72(sp)
    247e:	6906                	ld	s2,64(sp)
    2480:	79e2                	ld	s3,56(sp)
    2482:	7a42                	ld	s4,48(sp)
    2484:	7aa2                	ld	s5,40(sp)
    2486:	7b02                	ld	s6,32(sp)
    2488:	6be2                	ld	s7,24(sp)
    248a:	6c42                	ld	s8,16(sp)
    248c:	6ca2                	ld	s9,8(sp)
    248e:	6125                	addi	sp,sp,96
    2490:	8082                	ret
    exit(0,"");
    2492:	00006597          	auipc	a1,0x6
    2496:	ec658593          	addi	a1,a1,-314 # 8358 <malloc+0x172c>
    249a:	4501                	li	a0,0
    249c:	00004097          	auipc	ra,0x4
    24a0:	32a080e7          	jalr	810(ra) # 67c6 <exit>

00000000000024a4 <forktest>:
{
    24a4:	7179                	addi	sp,sp,-48
    24a6:	f406                	sd	ra,40(sp)
    24a8:	f022                	sd	s0,32(sp)
    24aa:	ec26                	sd	s1,24(sp)
    24ac:	e84a                	sd	s2,16(sp)
    24ae:	e44e                	sd	s3,8(sp)
    24b0:	1800                	addi	s0,sp,48
    24b2:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    24b4:	4481                	li	s1,0
    24b6:	3e800913          	li	s2,1000
    pid = fork();
    24ba:	00004097          	auipc	ra,0x4
    24be:	304080e7          	jalr	772(ra) # 67be <fork>
    if(pid < 0)
    24c2:	04054063          	bltz	a0,2502 <forktest+0x5e>
    if(pid == 0)
    24c6:	c515                	beqz	a0,24f2 <forktest+0x4e>
  for(n=0; n<N; n++){
    24c8:	2485                	addiw	s1,s1,1
    24ca:	ff2498e3          	bne	s1,s2,24ba <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    24ce:	85ce                	mv	a1,s3
    24d0:	00005517          	auipc	a0,0x5
    24d4:	39850513          	addi	a0,a0,920 # 7868 <malloc+0xc3c>
    24d8:	00004097          	auipc	ra,0x4
    24dc:	696080e7          	jalr	1686(ra) # 6b6e <printf>
    exit(1,"");
    24e0:	00006597          	auipc	a1,0x6
    24e4:	e7858593          	addi	a1,a1,-392 # 8358 <malloc+0x172c>
    24e8:	4505                	li	a0,1
    24ea:	00004097          	auipc	ra,0x4
    24ee:	2dc080e7          	jalr	732(ra) # 67c6 <exit>
      exit(0,"");
    24f2:	00006597          	auipc	a1,0x6
    24f6:	e6658593          	addi	a1,a1,-410 # 8358 <malloc+0x172c>
    24fa:	00004097          	auipc	ra,0x4
    24fe:	2cc080e7          	jalr	716(ra) # 67c6 <exit>
  if (n == 0) {
    2502:	c8a1                	beqz	s1,2552 <forktest+0xae>
  if(n == N){
    2504:	3e800793          	li	a5,1000
    2508:	fcf483e3          	beq	s1,a5,24ce <forktest+0x2a>
    if(wait(0,"") < 0){
    250c:	00006917          	auipc	s2,0x6
    2510:	e4c90913          	addi	s2,s2,-436 # 8358 <malloc+0x172c>
  for(; n > 0; n--){
    2514:	00905c63          	blez	s1,252c <forktest+0x88>
    if(wait(0,"") < 0){
    2518:	85ca                	mv	a1,s2
    251a:	4501                	li	a0,0
    251c:	00004097          	auipc	ra,0x4
    2520:	2b2080e7          	jalr	690(ra) # 67ce <wait>
    2524:	04054963          	bltz	a0,2576 <forktest+0xd2>
  for(; n > 0; n--){
    2528:	34fd                	addiw	s1,s1,-1
    252a:	f4fd                	bnez	s1,2518 <forktest+0x74>
  if(wait(0,"") != -1){
    252c:	00006597          	auipc	a1,0x6
    2530:	e2c58593          	addi	a1,a1,-468 # 8358 <malloc+0x172c>
    2534:	4501                	li	a0,0
    2536:	00004097          	auipc	ra,0x4
    253a:	298080e7          	jalr	664(ra) # 67ce <wait>
    253e:	57fd                	li	a5,-1
    2540:	04f51d63          	bne	a0,a5,259a <forktest+0xf6>
}
    2544:	70a2                	ld	ra,40(sp)
    2546:	7402                	ld	s0,32(sp)
    2548:	64e2                	ld	s1,24(sp)
    254a:	6942                	ld	s2,16(sp)
    254c:	69a2                	ld	s3,8(sp)
    254e:	6145                	addi	sp,sp,48
    2550:	8082                	ret
    printf("%s: no fork at all!\n", s);
    2552:	85ce                	mv	a1,s3
    2554:	00005517          	auipc	a0,0x5
    2558:	2fc50513          	addi	a0,a0,764 # 7850 <malloc+0xc24>
    255c:	00004097          	auipc	ra,0x4
    2560:	612080e7          	jalr	1554(ra) # 6b6e <printf>
    exit(1,"");
    2564:	00006597          	auipc	a1,0x6
    2568:	df458593          	addi	a1,a1,-524 # 8358 <malloc+0x172c>
    256c:	4505                	li	a0,1
    256e:	00004097          	auipc	ra,0x4
    2572:	258080e7          	jalr	600(ra) # 67c6 <exit>
      printf("%s: wait stopped early\n", s);
    2576:	85ce                	mv	a1,s3
    2578:	00005517          	auipc	a0,0x5
    257c:	31850513          	addi	a0,a0,792 # 7890 <malloc+0xc64>
    2580:	00004097          	auipc	ra,0x4
    2584:	5ee080e7          	jalr	1518(ra) # 6b6e <printf>
      exit(1,"");
    2588:	00006597          	auipc	a1,0x6
    258c:	dd058593          	addi	a1,a1,-560 # 8358 <malloc+0x172c>
    2590:	4505                	li	a0,1
    2592:	00004097          	auipc	ra,0x4
    2596:	234080e7          	jalr	564(ra) # 67c6 <exit>
    printf("%s: wait got too many\n", s);
    259a:	85ce                	mv	a1,s3
    259c:	00005517          	auipc	a0,0x5
    25a0:	30c50513          	addi	a0,a0,780 # 78a8 <malloc+0xc7c>
    25a4:	00004097          	auipc	ra,0x4
    25a8:	5ca080e7          	jalr	1482(ra) # 6b6e <printf>
    exit(1,"");
    25ac:	00006597          	auipc	a1,0x6
    25b0:	dac58593          	addi	a1,a1,-596 # 8358 <malloc+0x172c>
    25b4:	4505                	li	a0,1
    25b6:	00004097          	auipc	ra,0x4
    25ba:	210080e7          	jalr	528(ra) # 67c6 <exit>

00000000000025be <kernmem>:
{
    25be:	715d                	addi	sp,sp,-80
    25c0:	e486                	sd	ra,72(sp)
    25c2:	e0a2                	sd	s0,64(sp)
    25c4:	fc26                	sd	s1,56(sp)
    25c6:	f84a                	sd	s2,48(sp)
    25c8:	f44e                	sd	s3,40(sp)
    25ca:	f052                	sd	s4,32(sp)
    25cc:	ec56                	sd	s5,24(sp)
    25ce:	e85a                	sd	s6,16(sp)
    25d0:	0880                	addi	s0,sp,80
    25d2:	8b2a                	mv	s6,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    25d4:	4485                	li	s1,1
    25d6:	04fe                	slli	s1,s1,0x1f
    wait(&xstatus,"");
    25d8:	00006a97          	auipc	s5,0x6
    25dc:	d80a8a93          	addi	s5,s5,-640 # 8358 <malloc+0x172c>
    if(xstatus != -1)  // did kernel kill child?
    25e0:	5a7d                	li	s4,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    25e2:	69b1                	lui	s3,0xc
    25e4:	35098993          	addi	s3,s3,848 # c350 <uninit+0xde8>
    25e8:	1003d937          	lui	s2,0x1003d
    25ec:	090e                	slli	s2,s2,0x3
    25ee:	48090913          	addi	s2,s2,1152 # 1003d480 <base+0x1002c808>
    pid = fork();
    25f2:	00004097          	auipc	ra,0x4
    25f6:	1cc080e7          	jalr	460(ra) # 67be <fork>
    if(pid < 0){
    25fa:	02054b63          	bltz	a0,2630 <kernmem+0x72>
    if(pid == 0){
    25fe:	c939                	beqz	a0,2654 <kernmem+0x96>
    wait(&xstatus,"");
    2600:	85d6                	mv	a1,s5
    2602:	fbc40513          	addi	a0,s0,-68
    2606:	00004097          	auipc	ra,0x4
    260a:	1c8080e7          	jalr	456(ra) # 67ce <wait>
    if(xstatus != -1)  // did kernel kill child?
    260e:	fbc42783          	lw	a5,-68(s0)
    2612:	07479663          	bne	a5,s4,267e <kernmem+0xc0>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    2616:	94ce                	add	s1,s1,s3
    2618:	fd249de3          	bne	s1,s2,25f2 <kernmem+0x34>
}
    261c:	60a6                	ld	ra,72(sp)
    261e:	6406                	ld	s0,64(sp)
    2620:	74e2                	ld	s1,56(sp)
    2622:	7942                	ld	s2,48(sp)
    2624:	79a2                	ld	s3,40(sp)
    2626:	7a02                	ld	s4,32(sp)
    2628:	6ae2                	ld	s5,24(sp)
    262a:	6b42                	ld	s6,16(sp)
    262c:	6161                	addi	sp,sp,80
    262e:	8082                	ret
      printf("%s: fork failed\n", s);
    2630:	85da                	mv	a1,s6
    2632:	00005517          	auipc	a0,0x5
    2636:	fbe50513          	addi	a0,a0,-66 # 75f0 <malloc+0x9c4>
    263a:	00004097          	auipc	ra,0x4
    263e:	534080e7          	jalr	1332(ra) # 6b6e <printf>
      exit(1,"");
    2642:	00006597          	auipc	a1,0x6
    2646:	d1658593          	addi	a1,a1,-746 # 8358 <malloc+0x172c>
    264a:	4505                	li	a0,1
    264c:	00004097          	auipc	ra,0x4
    2650:	17a080e7          	jalr	378(ra) # 67c6 <exit>
      printf("%s: oops could read %x = %x\n", s, a, *a);
    2654:	0004c683          	lbu	a3,0(s1)
    2658:	8626                	mv	a2,s1
    265a:	85da                	mv	a1,s6
    265c:	00005517          	auipc	a0,0x5
    2660:	26450513          	addi	a0,a0,612 # 78c0 <malloc+0xc94>
    2664:	00004097          	auipc	ra,0x4
    2668:	50a080e7          	jalr	1290(ra) # 6b6e <printf>
      exit(1,"");
    266c:	00006597          	auipc	a1,0x6
    2670:	cec58593          	addi	a1,a1,-788 # 8358 <malloc+0x172c>
    2674:	4505                	li	a0,1
    2676:	00004097          	auipc	ra,0x4
    267a:	150080e7          	jalr	336(ra) # 67c6 <exit>
      exit(1,"");
    267e:	00006597          	auipc	a1,0x6
    2682:	cda58593          	addi	a1,a1,-806 # 8358 <malloc+0x172c>
    2686:	4505                	li	a0,1
    2688:	00004097          	auipc	ra,0x4
    268c:	13e080e7          	jalr	318(ra) # 67c6 <exit>

0000000000002690 <MAXVAplus>:
{
    2690:	7139                	addi	sp,sp,-64
    2692:	fc06                	sd	ra,56(sp)
    2694:	f822                	sd	s0,48(sp)
    2696:	f426                	sd	s1,40(sp)
    2698:	f04a                	sd	s2,32(sp)
    269a:	ec4e                	sd	s3,24(sp)
    269c:	0080                	addi	s0,sp,64
  volatile uint64 a = MAXVA;
    269e:	4785                	li	a5,1
    26a0:	179a                	slli	a5,a5,0x26
    26a2:	fcf43423          	sd	a5,-56(s0)
  for( ; a != 0; a <<= 1){
    26a6:	fc843783          	ld	a5,-56(s0)
    26aa:	c3a9                	beqz	a5,26ec <MAXVAplus+0x5c>
    26ac:	89aa                	mv	s3,a0
    wait(&xstatus,"");
    26ae:	00006917          	auipc	s2,0x6
    26b2:	caa90913          	addi	s2,s2,-854 # 8358 <malloc+0x172c>
    if(xstatus != -1)  // did kernel kill child?
    26b6:	54fd                	li	s1,-1
    pid = fork();
    26b8:	00004097          	auipc	ra,0x4
    26bc:	106080e7          	jalr	262(ra) # 67be <fork>
    if(pid < 0){
    26c0:	02054d63          	bltz	a0,26fa <MAXVAplus+0x6a>
    if(pid == 0){
    26c4:	cd29                	beqz	a0,271e <MAXVAplus+0x8e>
    wait(&xstatus,"");
    26c6:	85ca                	mv	a1,s2
    26c8:	fc440513          	addi	a0,s0,-60
    26cc:	00004097          	auipc	ra,0x4
    26d0:	102080e7          	jalr	258(ra) # 67ce <wait>
    if(xstatus != -1)  // did kernel kill child?
    26d4:	fc442783          	lw	a5,-60(s0)
    26d8:	06979d63          	bne	a5,s1,2752 <MAXVAplus+0xc2>
  for( ; a != 0; a <<= 1){
    26dc:	fc843783          	ld	a5,-56(s0)
    26e0:	0786                	slli	a5,a5,0x1
    26e2:	fcf43423          	sd	a5,-56(s0)
    26e6:	fc843783          	ld	a5,-56(s0)
    26ea:	f7f9                	bnez	a5,26b8 <MAXVAplus+0x28>
}
    26ec:	70e2                	ld	ra,56(sp)
    26ee:	7442                	ld	s0,48(sp)
    26f0:	74a2                	ld	s1,40(sp)
    26f2:	7902                	ld	s2,32(sp)
    26f4:	69e2                	ld	s3,24(sp)
    26f6:	6121                	addi	sp,sp,64
    26f8:	8082                	ret
      printf("%s: fork failed\n", s);
    26fa:	85ce                	mv	a1,s3
    26fc:	00005517          	auipc	a0,0x5
    2700:	ef450513          	addi	a0,a0,-268 # 75f0 <malloc+0x9c4>
    2704:	00004097          	auipc	ra,0x4
    2708:	46a080e7          	jalr	1130(ra) # 6b6e <printf>
      exit(1,"");
    270c:	00006597          	auipc	a1,0x6
    2710:	c4c58593          	addi	a1,a1,-948 # 8358 <malloc+0x172c>
    2714:	4505                	li	a0,1
    2716:	00004097          	auipc	ra,0x4
    271a:	0b0080e7          	jalr	176(ra) # 67c6 <exit>
      *(char*)a = 99;
    271e:	fc843783          	ld	a5,-56(s0)
    2722:	06300713          	li	a4,99
    2726:	00e78023          	sb	a4,0(a5)
      printf("%s: oops wrote %x\n", s, a);
    272a:	fc843603          	ld	a2,-56(s0)
    272e:	85ce                	mv	a1,s3
    2730:	00005517          	auipc	a0,0x5
    2734:	1b050513          	addi	a0,a0,432 # 78e0 <malloc+0xcb4>
    2738:	00004097          	auipc	ra,0x4
    273c:	436080e7          	jalr	1078(ra) # 6b6e <printf>
      exit(1,"");
    2740:	00006597          	auipc	a1,0x6
    2744:	c1858593          	addi	a1,a1,-1000 # 8358 <malloc+0x172c>
    2748:	4505                	li	a0,1
    274a:	00004097          	auipc	ra,0x4
    274e:	07c080e7          	jalr	124(ra) # 67c6 <exit>
      exit(1,"");
    2752:	00006597          	auipc	a1,0x6
    2756:	c0658593          	addi	a1,a1,-1018 # 8358 <malloc+0x172c>
    275a:	4505                	li	a0,1
    275c:	00004097          	auipc	ra,0x4
    2760:	06a080e7          	jalr	106(ra) # 67c6 <exit>

0000000000002764 <bigargtest>:
{
    2764:	7179                	addi	sp,sp,-48
    2766:	f406                	sd	ra,40(sp)
    2768:	f022                	sd	s0,32(sp)
    276a:	ec26                	sd	s1,24(sp)
    276c:	1800                	addi	s0,sp,48
    276e:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    2770:	00005517          	auipc	a0,0x5
    2774:	18850513          	addi	a0,a0,392 # 78f8 <malloc+0xccc>
    2778:	00004097          	auipc	ra,0x4
    277c:	09e080e7          	jalr	158(ra) # 6816 <unlink>
  pid = fork();
    2780:	00004097          	auipc	ra,0x4
    2784:	03e080e7          	jalr	62(ra) # 67be <fork>
  if(pid == 0){
    2788:	c521                	beqz	a0,27d0 <bigargtest+0x6c>
  } else if(pid < 0){
    278a:	0a054863          	bltz	a0,283a <bigargtest+0xd6>
  wait(&xstatus,"");
    278e:	00006597          	auipc	a1,0x6
    2792:	bca58593          	addi	a1,a1,-1078 # 8358 <malloc+0x172c>
    2796:	fdc40513          	addi	a0,s0,-36
    279a:	00004097          	auipc	ra,0x4
    279e:	034080e7          	jalr	52(ra) # 67ce <wait>
  if(xstatus != 0)
    27a2:	fdc42503          	lw	a0,-36(s0)
    27a6:	ed45                	bnez	a0,285e <bigargtest+0xfa>
  fd = open("bigarg-ok", 0);
    27a8:	4581                	li	a1,0
    27aa:	00005517          	auipc	a0,0x5
    27ae:	14e50513          	addi	a0,a0,334 # 78f8 <malloc+0xccc>
    27b2:	00004097          	auipc	ra,0x4
    27b6:	054080e7          	jalr	84(ra) # 6806 <open>
  if(fd < 0){
    27ba:	0a054a63          	bltz	a0,286e <bigargtest+0x10a>
  close(fd);
    27be:	00004097          	auipc	ra,0x4
    27c2:	030080e7          	jalr	48(ra) # 67ee <close>
}
    27c6:	70a2                	ld	ra,40(sp)
    27c8:	7402                	ld	s0,32(sp)
    27ca:	64e2                	ld	s1,24(sp)
    27cc:	6145                	addi	sp,sp,48
    27ce:	8082                	ret
    27d0:	00008797          	auipc	a5,0x8
    27d4:	c9078793          	addi	a5,a5,-880 # a460 <args.1>
    27d8:	00008697          	auipc	a3,0x8
    27dc:	d8068693          	addi	a3,a3,-640 # a558 <args.1+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    27e0:	00005717          	auipc	a4,0x5
    27e4:	12870713          	addi	a4,a4,296 # 7908 <malloc+0xcdc>
    27e8:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    27ea:	07a1                	addi	a5,a5,8
    27ec:	fed79ee3          	bne	a5,a3,27e8 <bigargtest+0x84>
    args[MAXARG-1] = 0;
    27f0:	00008597          	auipc	a1,0x8
    27f4:	c7058593          	addi	a1,a1,-912 # a460 <args.1>
    27f8:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    27fc:	00004517          	auipc	a0,0x4
    2800:	56c50513          	addi	a0,a0,1388 # 6d68 <malloc+0x13c>
    2804:	00004097          	auipc	ra,0x4
    2808:	ffa080e7          	jalr	-6(ra) # 67fe <exec>
    fd = open("bigarg-ok", O_CREATE);
    280c:	20000593          	li	a1,512
    2810:	00005517          	auipc	a0,0x5
    2814:	0e850513          	addi	a0,a0,232 # 78f8 <malloc+0xccc>
    2818:	00004097          	auipc	ra,0x4
    281c:	fee080e7          	jalr	-18(ra) # 6806 <open>
    close(fd);
    2820:	00004097          	auipc	ra,0x4
    2824:	fce080e7          	jalr	-50(ra) # 67ee <close>
    exit(0,"");
    2828:	00006597          	auipc	a1,0x6
    282c:	b3058593          	addi	a1,a1,-1232 # 8358 <malloc+0x172c>
    2830:	4501                	li	a0,0
    2832:	00004097          	auipc	ra,0x4
    2836:	f94080e7          	jalr	-108(ra) # 67c6 <exit>
    printf("%s: bigargtest: fork failed\n", s);
    283a:	85a6                	mv	a1,s1
    283c:	00005517          	auipc	a0,0x5
    2840:	1ac50513          	addi	a0,a0,428 # 79e8 <malloc+0xdbc>
    2844:	00004097          	auipc	ra,0x4
    2848:	32a080e7          	jalr	810(ra) # 6b6e <printf>
    exit(1,"");
    284c:	00006597          	auipc	a1,0x6
    2850:	b0c58593          	addi	a1,a1,-1268 # 8358 <malloc+0x172c>
    2854:	4505                	li	a0,1
    2856:	00004097          	auipc	ra,0x4
    285a:	f70080e7          	jalr	-144(ra) # 67c6 <exit>
    exit(xstatus,"");
    285e:	00006597          	auipc	a1,0x6
    2862:	afa58593          	addi	a1,a1,-1286 # 8358 <malloc+0x172c>
    2866:	00004097          	auipc	ra,0x4
    286a:	f60080e7          	jalr	-160(ra) # 67c6 <exit>
    printf("%s: bigarg test failed!\n", s);
    286e:	85a6                	mv	a1,s1
    2870:	00005517          	auipc	a0,0x5
    2874:	19850513          	addi	a0,a0,408 # 7a08 <malloc+0xddc>
    2878:	00004097          	auipc	ra,0x4
    287c:	2f6080e7          	jalr	758(ra) # 6b6e <printf>
    exit(1,"");
    2880:	00006597          	auipc	a1,0x6
    2884:	ad858593          	addi	a1,a1,-1320 # 8358 <malloc+0x172c>
    2888:	4505                	li	a0,1
    288a:	00004097          	auipc	ra,0x4
    288e:	f3c080e7          	jalr	-196(ra) # 67c6 <exit>

0000000000002892 <stacktest>:
{
    2892:	7179                	addi	sp,sp,-48
    2894:	f406                	sd	ra,40(sp)
    2896:	f022                	sd	s0,32(sp)
    2898:	ec26                	sd	s1,24(sp)
    289a:	1800                	addi	s0,sp,48
    289c:	84aa                	mv	s1,a0
  pid = fork();
    289e:	00004097          	auipc	ra,0x4
    28a2:	f20080e7          	jalr	-224(ra) # 67be <fork>
  if(pid == 0) {
    28a6:	c915                	beqz	a0,28da <stacktest+0x48>
  } else if(pid < 0){
    28a8:	06054063          	bltz	a0,2908 <stacktest+0x76>
  wait(&xstatus,"");
    28ac:	00006597          	auipc	a1,0x6
    28b0:	aac58593          	addi	a1,a1,-1364 # 8358 <malloc+0x172c>
    28b4:	fdc40513          	addi	a0,s0,-36
    28b8:	00004097          	auipc	ra,0x4
    28bc:	f16080e7          	jalr	-234(ra) # 67ce <wait>
  if(xstatus == -1)  // kernel killed child?
    28c0:	fdc42503          	lw	a0,-36(s0)
    28c4:	57fd                	li	a5,-1
    28c6:	06f50363          	beq	a0,a5,292c <stacktest+0x9a>
    exit(xstatus,"");
    28ca:	00006597          	auipc	a1,0x6
    28ce:	a8e58593          	addi	a1,a1,-1394 # 8358 <malloc+0x172c>
    28d2:	00004097          	auipc	ra,0x4
    28d6:	ef4080e7          	jalr	-268(ra) # 67c6 <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    28da:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", s, *sp);
    28dc:	77fd                	lui	a5,0xfffff
    28de:	97ba                	add	a5,a5,a4
    28e0:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <base+0xfffffffffffee388>
    28e4:	85a6                	mv	a1,s1
    28e6:	00005517          	auipc	a0,0x5
    28ea:	14250513          	addi	a0,a0,322 # 7a28 <malloc+0xdfc>
    28ee:	00004097          	auipc	ra,0x4
    28f2:	280080e7          	jalr	640(ra) # 6b6e <printf>
    exit(1,"");
    28f6:	00006597          	auipc	a1,0x6
    28fa:	a6258593          	addi	a1,a1,-1438 # 8358 <malloc+0x172c>
    28fe:	4505                	li	a0,1
    2900:	00004097          	auipc	ra,0x4
    2904:	ec6080e7          	jalr	-314(ra) # 67c6 <exit>
    printf("%s: fork failed\n", s);
    2908:	85a6                	mv	a1,s1
    290a:	00005517          	auipc	a0,0x5
    290e:	ce650513          	addi	a0,a0,-794 # 75f0 <malloc+0x9c4>
    2912:	00004097          	auipc	ra,0x4
    2916:	25c080e7          	jalr	604(ra) # 6b6e <printf>
    exit(1,"");
    291a:	00006597          	auipc	a1,0x6
    291e:	a3e58593          	addi	a1,a1,-1474 # 8358 <malloc+0x172c>
    2922:	4505                	li	a0,1
    2924:	00004097          	auipc	ra,0x4
    2928:	ea2080e7          	jalr	-350(ra) # 67c6 <exit>
    exit(0,"");
    292c:	00006597          	auipc	a1,0x6
    2930:	a2c58593          	addi	a1,a1,-1492 # 8358 <malloc+0x172c>
    2934:	4501                	li	a0,0
    2936:	00004097          	auipc	ra,0x4
    293a:	e90080e7          	jalr	-368(ra) # 67c6 <exit>

000000000000293e <textwrite>:
{
    293e:	7179                	addi	sp,sp,-48
    2940:	f406                	sd	ra,40(sp)
    2942:	f022                	sd	s0,32(sp)
    2944:	ec26                	sd	s1,24(sp)
    2946:	1800                	addi	s0,sp,48
    2948:	84aa                	mv	s1,a0
  pid = fork();
    294a:	00004097          	auipc	ra,0x4
    294e:	e74080e7          	jalr	-396(ra) # 67be <fork>
  if(pid == 0) {
    2952:	c915                	beqz	a0,2986 <textwrite+0x48>
  } else if(pid < 0){
    2954:	04054563          	bltz	a0,299e <textwrite+0x60>
  wait(&xstatus,"");
    2958:	00006597          	auipc	a1,0x6
    295c:	a0058593          	addi	a1,a1,-1536 # 8358 <malloc+0x172c>
    2960:	fdc40513          	addi	a0,s0,-36
    2964:	00004097          	auipc	ra,0x4
    2968:	e6a080e7          	jalr	-406(ra) # 67ce <wait>
  if(xstatus == -1)  // kernel killed child?
    296c:	fdc42503          	lw	a0,-36(s0)
    2970:	57fd                	li	a5,-1
    2972:	04f50863          	beq	a0,a5,29c2 <textwrite+0x84>
    exit(xstatus,"");
    2976:	00006597          	auipc	a1,0x6
    297a:	9e258593          	addi	a1,a1,-1566 # 8358 <malloc+0x172c>
    297e:	00004097          	auipc	ra,0x4
    2982:	e48080e7          	jalr	-440(ra) # 67c6 <exit>
    *addr = 10;
    2986:	47a9                	li	a5,10
    2988:	00f02023          	sw	a5,0(zero) # 0 <copyinstr1>
    exit(1,"");
    298c:	00006597          	auipc	a1,0x6
    2990:	9cc58593          	addi	a1,a1,-1588 # 8358 <malloc+0x172c>
    2994:	4505                	li	a0,1
    2996:	00004097          	auipc	ra,0x4
    299a:	e30080e7          	jalr	-464(ra) # 67c6 <exit>
    printf("%s: fork failed\n", s);
    299e:	85a6                	mv	a1,s1
    29a0:	00005517          	auipc	a0,0x5
    29a4:	c5050513          	addi	a0,a0,-944 # 75f0 <malloc+0x9c4>
    29a8:	00004097          	auipc	ra,0x4
    29ac:	1c6080e7          	jalr	454(ra) # 6b6e <printf>
    exit(1,"");
    29b0:	00006597          	auipc	a1,0x6
    29b4:	9a858593          	addi	a1,a1,-1624 # 8358 <malloc+0x172c>
    29b8:	4505                	li	a0,1
    29ba:	00004097          	auipc	ra,0x4
    29be:	e0c080e7          	jalr	-500(ra) # 67c6 <exit>
    exit(0,"");
    29c2:	00006597          	auipc	a1,0x6
    29c6:	99658593          	addi	a1,a1,-1642 # 8358 <malloc+0x172c>
    29ca:	4501                	li	a0,0
    29cc:	00004097          	auipc	ra,0x4
    29d0:	dfa080e7          	jalr	-518(ra) # 67c6 <exit>

00000000000029d4 <manywrites>:
{
    29d4:	711d                	addi	sp,sp,-96
    29d6:	ec86                	sd	ra,88(sp)
    29d8:	e8a2                	sd	s0,80(sp)
    29da:	e4a6                	sd	s1,72(sp)
    29dc:	e0ca                	sd	s2,64(sp)
    29de:	fc4e                	sd	s3,56(sp)
    29e0:	f852                	sd	s4,48(sp)
    29e2:	f456                	sd	s5,40(sp)
    29e4:	f05a                	sd	s6,32(sp)
    29e6:	ec5e                	sd	s7,24(sp)
    29e8:	1080                	addi	s0,sp,96
    29ea:	8aaa                	mv	s5,a0
  for(int ci = 0; ci < nchildren; ci++){
    29ec:	4981                	li	s3,0
    29ee:	4911                	li	s2,4
    int pid = fork();
    29f0:	00004097          	auipc	ra,0x4
    29f4:	dce080e7          	jalr	-562(ra) # 67be <fork>
    29f8:	84aa                	mv	s1,a0
    if(pid < 0){
    29fa:	04054363          	bltz	a0,2a40 <manywrites+0x6c>
    if(pid == 0){
    29fe:	c135                	beqz	a0,2a62 <manywrites+0x8e>
  for(int ci = 0; ci < nchildren; ci++){
    2a00:	2985                	addiw	s3,s3,1
    2a02:	ff2997e3          	bne	s3,s2,29f0 <manywrites+0x1c>
    2a06:	4491                	li	s1,4
    wait(&st,"");
    2a08:	00006917          	auipc	s2,0x6
    2a0c:	95090913          	addi	s2,s2,-1712 # 8358 <malloc+0x172c>
    int st = 0;
    2a10:	fa042423          	sw	zero,-88(s0)
    wait(&st,"");
    2a14:	85ca                	mv	a1,s2
    2a16:	fa840513          	addi	a0,s0,-88
    2a1a:	00004097          	auipc	ra,0x4
    2a1e:	db4080e7          	jalr	-588(ra) # 67ce <wait>
    if(st != 0)
    2a22:	fa842503          	lw	a0,-88(s0)
    2a26:	12051263          	bnez	a0,2b4a <manywrites+0x176>
  for(int ci = 0; ci < nchildren; ci++){
    2a2a:	34fd                	addiw	s1,s1,-1
    2a2c:	f0f5                	bnez	s1,2a10 <manywrites+0x3c>
  exit(0,"");
    2a2e:	00006597          	auipc	a1,0x6
    2a32:	92a58593          	addi	a1,a1,-1750 # 8358 <malloc+0x172c>
    2a36:	4501                	li	a0,0
    2a38:	00004097          	auipc	ra,0x4
    2a3c:	d8e080e7          	jalr	-626(ra) # 67c6 <exit>
      printf("fork failed\n");
    2a40:	00005517          	auipc	a0,0x5
    2a44:	fb850513          	addi	a0,a0,-72 # 79f8 <malloc+0xdcc>
    2a48:	00004097          	auipc	ra,0x4
    2a4c:	126080e7          	jalr	294(ra) # 6b6e <printf>
      exit(1,"");
    2a50:	00006597          	auipc	a1,0x6
    2a54:	90858593          	addi	a1,a1,-1784 # 8358 <malloc+0x172c>
    2a58:	4505                	li	a0,1
    2a5a:	00004097          	auipc	ra,0x4
    2a5e:	d6c080e7          	jalr	-660(ra) # 67c6 <exit>
      name[0] = 'b';
    2a62:	06200793          	li	a5,98
    2a66:	faf40423          	sb	a5,-88(s0)
      name[1] = 'a' + ci;
    2a6a:	0619879b          	addiw	a5,s3,97
    2a6e:	faf404a3          	sb	a5,-87(s0)
      name[2] = '\0';
    2a72:	fa040523          	sb	zero,-86(s0)
      unlink(name);
    2a76:	fa840513          	addi	a0,s0,-88
    2a7a:	00004097          	auipc	ra,0x4
    2a7e:	d9c080e7          	jalr	-612(ra) # 6816 <unlink>
    2a82:	4bf9                	li	s7,30
          int cc = write(fd, buf, sz);
    2a84:	0000bb17          	auipc	s6,0xb
    2a88:	1f4b0b13          	addi	s6,s6,500 # dc78 <buf>
        for(int i = 0; i < ci+1; i++){
    2a8c:	8a26                	mv	s4,s1
    2a8e:	0209ce63          	bltz	s3,2aca <manywrites+0xf6>
          int fd = open(name, O_CREATE | O_RDWR);
    2a92:	20200593          	li	a1,514
    2a96:	fa840513          	addi	a0,s0,-88
    2a9a:	00004097          	auipc	ra,0x4
    2a9e:	d6c080e7          	jalr	-660(ra) # 6806 <open>
    2aa2:	892a                	mv	s2,a0
          if(fd < 0){
    2aa4:	04054b63          	bltz	a0,2afa <manywrites+0x126>
          int cc = write(fd, buf, sz);
    2aa8:	660d                	lui	a2,0x3
    2aaa:	85da                	mv	a1,s6
    2aac:	00004097          	auipc	ra,0x4
    2ab0:	d3a080e7          	jalr	-710(ra) # 67e6 <write>
          if(cc != sz){
    2ab4:	678d                	lui	a5,0x3
    2ab6:	06f51663          	bne	a0,a5,2b22 <manywrites+0x14e>
          close(fd);
    2aba:	854a                	mv	a0,s2
    2abc:	00004097          	auipc	ra,0x4
    2ac0:	d32080e7          	jalr	-718(ra) # 67ee <close>
        for(int i = 0; i < ci+1; i++){
    2ac4:	2a05                	addiw	s4,s4,1
    2ac6:	fd49d6e3          	bge	s3,s4,2a92 <manywrites+0xbe>
        unlink(name);
    2aca:	fa840513          	addi	a0,s0,-88
    2ace:	00004097          	auipc	ra,0x4
    2ad2:	d48080e7          	jalr	-696(ra) # 6816 <unlink>
      for(int iters = 0; iters < howmany; iters++){
    2ad6:	3bfd                	addiw	s7,s7,-1
    2ad8:	fa0b9ae3          	bnez	s7,2a8c <manywrites+0xb8>
      unlink(name);
    2adc:	fa840513          	addi	a0,s0,-88
    2ae0:	00004097          	auipc	ra,0x4
    2ae4:	d36080e7          	jalr	-714(ra) # 6816 <unlink>
      exit(0,"");
    2ae8:	00006597          	auipc	a1,0x6
    2aec:	87058593          	addi	a1,a1,-1936 # 8358 <malloc+0x172c>
    2af0:	4501                	li	a0,0
    2af2:	00004097          	auipc	ra,0x4
    2af6:	cd4080e7          	jalr	-812(ra) # 67c6 <exit>
            printf("%s: cannot create %s\n", s, name);
    2afa:	fa840613          	addi	a2,s0,-88
    2afe:	85d6                	mv	a1,s5
    2b00:	00005517          	auipc	a0,0x5
    2b04:	f5050513          	addi	a0,a0,-176 # 7a50 <malloc+0xe24>
    2b08:	00004097          	auipc	ra,0x4
    2b0c:	066080e7          	jalr	102(ra) # 6b6e <printf>
            exit(1,"");
    2b10:	00006597          	auipc	a1,0x6
    2b14:	84858593          	addi	a1,a1,-1976 # 8358 <malloc+0x172c>
    2b18:	4505                	li	a0,1
    2b1a:	00004097          	auipc	ra,0x4
    2b1e:	cac080e7          	jalr	-852(ra) # 67c6 <exit>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
    2b22:	86aa                	mv	a3,a0
    2b24:	660d                	lui	a2,0x3
    2b26:	85d6                	mv	a1,s5
    2b28:	00004517          	auipc	a0,0x4
    2b2c:	31050513          	addi	a0,a0,784 # 6e38 <malloc+0x20c>
    2b30:	00004097          	auipc	ra,0x4
    2b34:	03e080e7          	jalr	62(ra) # 6b6e <printf>
            exit(1,"");
    2b38:	00006597          	auipc	a1,0x6
    2b3c:	82058593          	addi	a1,a1,-2016 # 8358 <malloc+0x172c>
    2b40:	4505                	li	a0,1
    2b42:	00004097          	auipc	ra,0x4
    2b46:	c84080e7          	jalr	-892(ra) # 67c6 <exit>
      exit(st,"");
    2b4a:	00006597          	auipc	a1,0x6
    2b4e:	80e58593          	addi	a1,a1,-2034 # 8358 <malloc+0x172c>
    2b52:	00004097          	auipc	ra,0x4
    2b56:	c74080e7          	jalr	-908(ra) # 67c6 <exit>

0000000000002b5a <copyinstr3>:
{
    2b5a:	7179                	addi	sp,sp,-48
    2b5c:	f406                	sd	ra,40(sp)
    2b5e:	f022                	sd	s0,32(sp)
    2b60:	ec26                	sd	s1,24(sp)
    2b62:	1800                	addi	s0,sp,48
  sbrk(8192);
    2b64:	6509                	lui	a0,0x2
    2b66:	00004097          	auipc	ra,0x4
    2b6a:	ce8080e7          	jalr	-792(ra) # 684e <sbrk>
  uint64 top = (uint64) sbrk(0);
    2b6e:	4501                	li	a0,0
    2b70:	00004097          	auipc	ra,0x4
    2b74:	cde080e7          	jalr	-802(ra) # 684e <sbrk>
  if((top % PGSIZE) != 0){
    2b78:	03451793          	slli	a5,a0,0x34
    2b7c:	e3c9                	bnez	a5,2bfe <copyinstr3+0xa4>
  top = (uint64) sbrk(0);
    2b7e:	4501                	li	a0,0
    2b80:	00004097          	auipc	ra,0x4
    2b84:	cce080e7          	jalr	-818(ra) # 684e <sbrk>
  if(top % PGSIZE){
    2b88:	03451793          	slli	a5,a0,0x34
    2b8c:	e3d9                	bnez	a5,2c12 <copyinstr3+0xb8>
  char *b = (char *) (top - 1);
    2b8e:	fff50493          	addi	s1,a0,-1 # 1fff <forkfork+0x79>
  *b = 'x';
    2b92:	07800793          	li	a5,120
    2b96:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    2b9a:	8526                	mv	a0,s1
    2b9c:	00004097          	auipc	ra,0x4
    2ba0:	c7a080e7          	jalr	-902(ra) # 6816 <unlink>
  if(ret != -1){
    2ba4:	57fd                	li	a5,-1
    2ba6:	08f51763          	bne	a0,a5,2c34 <copyinstr3+0xda>
  int fd = open(b, O_CREATE | O_WRONLY);
    2baa:	20100593          	li	a1,513
    2bae:	8526                	mv	a0,s1
    2bb0:	00004097          	auipc	ra,0x4
    2bb4:	c56080e7          	jalr	-938(ra) # 6806 <open>
  if(fd != -1){
    2bb8:	57fd                	li	a5,-1
    2bba:	0af51063          	bne	a0,a5,2c5a <copyinstr3+0x100>
  ret = link(b, b);
    2bbe:	85a6                	mv	a1,s1
    2bc0:	8526                	mv	a0,s1
    2bc2:	00004097          	auipc	ra,0x4
    2bc6:	c64080e7          	jalr	-924(ra) # 6826 <link>
  if(ret != -1){
    2bca:	57fd                	li	a5,-1
    2bcc:	0af51a63          	bne	a0,a5,2c80 <copyinstr3+0x126>
  char *args[] = { "xx", 0 };
    2bd0:	00006797          	auipc	a5,0x6
    2bd4:	b7878793          	addi	a5,a5,-1160 # 8748 <malloc+0x1b1c>
    2bd8:	fcf43823          	sd	a5,-48(s0)
    2bdc:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    2be0:	fd040593          	addi	a1,s0,-48
    2be4:	8526                	mv	a0,s1
    2be6:	00004097          	auipc	ra,0x4
    2bea:	c18080e7          	jalr	-1000(ra) # 67fe <exec>
  if(ret != -1){
    2bee:	57fd                	li	a5,-1
    2bf0:	0af51c63          	bne	a0,a5,2ca8 <copyinstr3+0x14e>
}
    2bf4:	70a2                	ld	ra,40(sp)
    2bf6:	7402                	ld	s0,32(sp)
    2bf8:	64e2                	ld	s1,24(sp)
    2bfa:	6145                	addi	sp,sp,48
    2bfc:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    2bfe:	0347d513          	srli	a0,a5,0x34
    2c02:	6785                	lui	a5,0x1
    2c04:	40a7853b          	subw	a0,a5,a0
    2c08:	00004097          	auipc	ra,0x4
    2c0c:	c46080e7          	jalr	-954(ra) # 684e <sbrk>
    2c10:	b7bd                	j	2b7e <copyinstr3+0x24>
    printf("oops\n");
    2c12:	00005517          	auipc	a0,0x5
    2c16:	e5650513          	addi	a0,a0,-426 # 7a68 <malloc+0xe3c>
    2c1a:	00004097          	auipc	ra,0x4
    2c1e:	f54080e7          	jalr	-172(ra) # 6b6e <printf>
    exit(1,"");
    2c22:	00005597          	auipc	a1,0x5
    2c26:	73658593          	addi	a1,a1,1846 # 8358 <malloc+0x172c>
    2c2a:	4505                	li	a0,1
    2c2c:	00004097          	auipc	ra,0x4
    2c30:	b9a080e7          	jalr	-1126(ra) # 67c6 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    2c34:	862a                	mv	a2,a0
    2c36:	85a6                	mv	a1,s1
    2c38:	00005517          	auipc	a0,0x5
    2c3c:	8d850513          	addi	a0,a0,-1832 # 7510 <malloc+0x8e4>
    2c40:	00004097          	auipc	ra,0x4
    2c44:	f2e080e7          	jalr	-210(ra) # 6b6e <printf>
    exit(1,"");
    2c48:	00005597          	auipc	a1,0x5
    2c4c:	71058593          	addi	a1,a1,1808 # 8358 <malloc+0x172c>
    2c50:	4505                	li	a0,1
    2c52:	00004097          	auipc	ra,0x4
    2c56:	b74080e7          	jalr	-1164(ra) # 67c6 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    2c5a:	862a                	mv	a2,a0
    2c5c:	85a6                	mv	a1,s1
    2c5e:	00005517          	auipc	a0,0x5
    2c62:	8d250513          	addi	a0,a0,-1838 # 7530 <malloc+0x904>
    2c66:	00004097          	auipc	ra,0x4
    2c6a:	f08080e7          	jalr	-248(ra) # 6b6e <printf>
    exit(1,"");
    2c6e:	00005597          	auipc	a1,0x5
    2c72:	6ea58593          	addi	a1,a1,1770 # 8358 <malloc+0x172c>
    2c76:	4505                	li	a0,1
    2c78:	00004097          	auipc	ra,0x4
    2c7c:	b4e080e7          	jalr	-1202(ra) # 67c6 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    2c80:	86aa                	mv	a3,a0
    2c82:	8626                	mv	a2,s1
    2c84:	85a6                	mv	a1,s1
    2c86:	00005517          	auipc	a0,0x5
    2c8a:	8ca50513          	addi	a0,a0,-1846 # 7550 <malloc+0x924>
    2c8e:	00004097          	auipc	ra,0x4
    2c92:	ee0080e7          	jalr	-288(ra) # 6b6e <printf>
    exit(1,"");
    2c96:	00005597          	auipc	a1,0x5
    2c9a:	6c258593          	addi	a1,a1,1730 # 8358 <malloc+0x172c>
    2c9e:	4505                	li	a0,1
    2ca0:	00004097          	auipc	ra,0x4
    2ca4:	b26080e7          	jalr	-1242(ra) # 67c6 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    2ca8:	567d                	li	a2,-1
    2caa:	85a6                	mv	a1,s1
    2cac:	00005517          	auipc	a0,0x5
    2cb0:	8cc50513          	addi	a0,a0,-1844 # 7578 <malloc+0x94c>
    2cb4:	00004097          	auipc	ra,0x4
    2cb8:	eba080e7          	jalr	-326(ra) # 6b6e <printf>
    exit(1,"");
    2cbc:	00005597          	auipc	a1,0x5
    2cc0:	69c58593          	addi	a1,a1,1692 # 8358 <malloc+0x172c>
    2cc4:	4505                	li	a0,1
    2cc6:	00004097          	auipc	ra,0x4
    2cca:	b00080e7          	jalr	-1280(ra) # 67c6 <exit>

0000000000002cce <rwsbrk>:
{
    2cce:	1101                	addi	sp,sp,-32
    2cd0:	ec06                	sd	ra,24(sp)
    2cd2:	e822                	sd	s0,16(sp)
    2cd4:	e426                	sd	s1,8(sp)
    2cd6:	e04a                	sd	s2,0(sp)
    2cd8:	1000                	addi	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
    2cda:	6509                	lui	a0,0x2
    2cdc:	00004097          	auipc	ra,0x4
    2ce0:	b72080e7          	jalr	-1166(ra) # 684e <sbrk>
  if(a == 0xffffffffffffffffLL) {
    2ce4:	57fd                	li	a5,-1
    2ce6:	06f50763          	beq	a0,a5,2d54 <rwsbrk+0x86>
    2cea:	84aa                	mv	s1,a0
  if ((uint64) sbrk(-8192) ==  0xffffffffffffffffLL) {
    2cec:	7579                	lui	a0,0xffffe
    2cee:	00004097          	auipc	ra,0x4
    2cf2:	b60080e7          	jalr	-1184(ra) # 684e <sbrk>
    2cf6:	57fd                	li	a5,-1
    2cf8:	06f50f63          	beq	a0,a5,2d76 <rwsbrk+0xa8>
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
    2cfc:	20100593          	li	a1,513
    2d00:	00005517          	auipc	a0,0x5
    2d04:	da850513          	addi	a0,a0,-600 # 7aa8 <malloc+0xe7c>
    2d08:	00004097          	auipc	ra,0x4
    2d0c:	afe080e7          	jalr	-1282(ra) # 6806 <open>
    2d10:	892a                	mv	s2,a0
  if(fd < 0){
    2d12:	08054363          	bltz	a0,2d98 <rwsbrk+0xca>
  n = write(fd, (void*)(a+4096), 1024);
    2d16:	6505                	lui	a0,0x1
    2d18:	94aa                	add	s1,s1,a0
    2d1a:	40000613          	li	a2,1024
    2d1e:	85a6                	mv	a1,s1
    2d20:	854a                	mv	a0,s2
    2d22:	00004097          	auipc	ra,0x4
    2d26:	ac4080e7          	jalr	-1340(ra) # 67e6 <write>
    2d2a:	862a                	mv	a2,a0
  if(n >= 0){
    2d2c:	08054763          	bltz	a0,2dba <rwsbrk+0xec>
    printf("write(fd, %p, 1024) returned %d, not -1\n", a+4096, n);
    2d30:	85a6                	mv	a1,s1
    2d32:	00005517          	auipc	a0,0x5
    2d36:	d9650513          	addi	a0,a0,-618 # 7ac8 <malloc+0xe9c>
    2d3a:	00004097          	auipc	ra,0x4
    2d3e:	e34080e7          	jalr	-460(ra) # 6b6e <printf>
    exit(1,"");
    2d42:	00005597          	auipc	a1,0x5
    2d46:	61658593          	addi	a1,a1,1558 # 8358 <malloc+0x172c>
    2d4a:	4505                	li	a0,1
    2d4c:	00004097          	auipc	ra,0x4
    2d50:	a7a080e7          	jalr	-1414(ra) # 67c6 <exit>
    printf("sbrk(rwsbrk) failed\n");
    2d54:	00005517          	auipc	a0,0x5
    2d58:	d1c50513          	addi	a0,a0,-740 # 7a70 <malloc+0xe44>
    2d5c:	00004097          	auipc	ra,0x4
    2d60:	e12080e7          	jalr	-494(ra) # 6b6e <printf>
    exit(1,"");
    2d64:	00005597          	auipc	a1,0x5
    2d68:	5f458593          	addi	a1,a1,1524 # 8358 <malloc+0x172c>
    2d6c:	4505                	li	a0,1
    2d6e:	00004097          	auipc	ra,0x4
    2d72:	a58080e7          	jalr	-1448(ra) # 67c6 <exit>
    printf("sbrk(rwsbrk) shrink failed\n");
    2d76:	00005517          	auipc	a0,0x5
    2d7a:	d1250513          	addi	a0,a0,-750 # 7a88 <malloc+0xe5c>
    2d7e:	00004097          	auipc	ra,0x4
    2d82:	df0080e7          	jalr	-528(ra) # 6b6e <printf>
    exit(1,"");
    2d86:	00005597          	auipc	a1,0x5
    2d8a:	5d258593          	addi	a1,a1,1490 # 8358 <malloc+0x172c>
    2d8e:	4505                	li	a0,1
    2d90:	00004097          	auipc	ra,0x4
    2d94:	a36080e7          	jalr	-1482(ra) # 67c6 <exit>
    printf("open(rwsbrk) failed\n");
    2d98:	00005517          	auipc	a0,0x5
    2d9c:	d1850513          	addi	a0,a0,-744 # 7ab0 <malloc+0xe84>
    2da0:	00004097          	auipc	ra,0x4
    2da4:	dce080e7          	jalr	-562(ra) # 6b6e <printf>
    exit(1,"");
    2da8:	00005597          	auipc	a1,0x5
    2dac:	5b058593          	addi	a1,a1,1456 # 8358 <malloc+0x172c>
    2db0:	4505                	li	a0,1
    2db2:	00004097          	auipc	ra,0x4
    2db6:	a14080e7          	jalr	-1516(ra) # 67c6 <exit>
  close(fd);
    2dba:	854a                	mv	a0,s2
    2dbc:	00004097          	auipc	ra,0x4
    2dc0:	a32080e7          	jalr	-1486(ra) # 67ee <close>
  unlink("rwsbrk");
    2dc4:	00005517          	auipc	a0,0x5
    2dc8:	ce450513          	addi	a0,a0,-796 # 7aa8 <malloc+0xe7c>
    2dcc:	00004097          	auipc	ra,0x4
    2dd0:	a4a080e7          	jalr	-1462(ra) # 6816 <unlink>
  fd = open("README", O_RDONLY);
    2dd4:	4581                	li	a1,0
    2dd6:	00004517          	auipc	a0,0x4
    2dda:	16a50513          	addi	a0,a0,362 # 6f40 <malloc+0x314>
    2dde:	00004097          	auipc	ra,0x4
    2de2:	a28080e7          	jalr	-1496(ra) # 6806 <open>
    2de6:	892a                	mv	s2,a0
  if(fd < 0){
    2de8:	02054d63          	bltz	a0,2e22 <rwsbrk+0x154>
  n = read(fd, (void*)(a+4096), 10);
    2dec:	4629                	li	a2,10
    2dee:	85a6                	mv	a1,s1
    2df0:	00004097          	auipc	ra,0x4
    2df4:	9ee080e7          	jalr	-1554(ra) # 67de <read>
    2df8:	862a                	mv	a2,a0
  if(n >= 0){
    2dfa:	04054563          	bltz	a0,2e44 <rwsbrk+0x176>
    printf("read(fd, %p, 10) returned %d, not -1\n", a+4096, n);
    2dfe:	85a6                	mv	a1,s1
    2e00:	00005517          	auipc	a0,0x5
    2e04:	cf850513          	addi	a0,a0,-776 # 7af8 <malloc+0xecc>
    2e08:	00004097          	auipc	ra,0x4
    2e0c:	d66080e7          	jalr	-666(ra) # 6b6e <printf>
    exit(1,"");
    2e10:	00005597          	auipc	a1,0x5
    2e14:	54858593          	addi	a1,a1,1352 # 8358 <malloc+0x172c>
    2e18:	4505                	li	a0,1
    2e1a:	00004097          	auipc	ra,0x4
    2e1e:	9ac080e7          	jalr	-1620(ra) # 67c6 <exit>
    printf("open(rwsbrk) failed\n");
    2e22:	00005517          	auipc	a0,0x5
    2e26:	c8e50513          	addi	a0,a0,-882 # 7ab0 <malloc+0xe84>
    2e2a:	00004097          	auipc	ra,0x4
    2e2e:	d44080e7          	jalr	-700(ra) # 6b6e <printf>
    exit(1,"");
    2e32:	00005597          	auipc	a1,0x5
    2e36:	52658593          	addi	a1,a1,1318 # 8358 <malloc+0x172c>
    2e3a:	4505                	li	a0,1
    2e3c:	00004097          	auipc	ra,0x4
    2e40:	98a080e7          	jalr	-1654(ra) # 67c6 <exit>
  close(fd);
    2e44:	854a                	mv	a0,s2
    2e46:	00004097          	auipc	ra,0x4
    2e4a:	9a8080e7          	jalr	-1624(ra) # 67ee <close>
  exit(0,"");
    2e4e:	00005597          	auipc	a1,0x5
    2e52:	50a58593          	addi	a1,a1,1290 # 8358 <malloc+0x172c>
    2e56:	4501                	li	a0,0
    2e58:	00004097          	auipc	ra,0x4
    2e5c:	96e080e7          	jalr	-1682(ra) # 67c6 <exit>

0000000000002e60 <sbrkbasic>:
{
    2e60:	7139                	addi	sp,sp,-64
    2e62:	fc06                	sd	ra,56(sp)
    2e64:	f822                	sd	s0,48(sp)
    2e66:	f426                	sd	s1,40(sp)
    2e68:	f04a                	sd	s2,32(sp)
    2e6a:	ec4e                	sd	s3,24(sp)
    2e6c:	e852                	sd	s4,16(sp)
    2e6e:	0080                	addi	s0,sp,64
    2e70:	8a2a                	mv	s4,a0
  pid = fork();
    2e72:	00004097          	auipc	ra,0x4
    2e76:	94c080e7          	jalr	-1716(ra) # 67be <fork>
  if(pid < 0){
    2e7a:	04054063          	bltz	a0,2eba <sbrkbasic+0x5a>
  if(pid == 0){
    2e7e:	e925                	bnez	a0,2eee <sbrkbasic+0x8e>
    a = sbrk(TOOMUCH);
    2e80:	40000537          	lui	a0,0x40000
    2e84:	00004097          	auipc	ra,0x4
    2e88:	9ca080e7          	jalr	-1590(ra) # 684e <sbrk>
    if(a == (char*)0xffffffffffffffffL){
    2e8c:	57fd                	li	a5,-1
    2e8e:	04f50763          	beq	a0,a5,2edc <sbrkbasic+0x7c>
    for(b = a; b < a+TOOMUCH; b += 4096){
    2e92:	400007b7          	lui	a5,0x40000
    2e96:	97aa                	add	a5,a5,a0
      *b = 99;
    2e98:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += 4096){
    2e9c:	6705                	lui	a4,0x1
      *b = 99;
    2e9e:	00d50023          	sb	a3,0(a0) # 40000000 <base+0x3ffef388>
    for(b = a; b < a+TOOMUCH; b += 4096){
    2ea2:	953a                	add	a0,a0,a4
    2ea4:	fef51de3          	bne	a0,a5,2e9e <sbrkbasic+0x3e>
    exit(1,"");
    2ea8:	00005597          	auipc	a1,0x5
    2eac:	4b058593          	addi	a1,a1,1200 # 8358 <malloc+0x172c>
    2eb0:	4505                	li	a0,1
    2eb2:	00004097          	auipc	ra,0x4
    2eb6:	914080e7          	jalr	-1772(ra) # 67c6 <exit>
    printf("fork failed in sbrkbasic\n");
    2eba:	00005517          	auipc	a0,0x5
    2ebe:	c6650513          	addi	a0,a0,-922 # 7b20 <malloc+0xef4>
    2ec2:	00004097          	auipc	ra,0x4
    2ec6:	cac080e7          	jalr	-852(ra) # 6b6e <printf>
    exit(1,"");
    2eca:	00005597          	auipc	a1,0x5
    2ece:	48e58593          	addi	a1,a1,1166 # 8358 <malloc+0x172c>
    2ed2:	4505                	li	a0,1
    2ed4:	00004097          	auipc	ra,0x4
    2ed8:	8f2080e7          	jalr	-1806(ra) # 67c6 <exit>
      exit(0,"");
    2edc:	00005597          	auipc	a1,0x5
    2ee0:	47c58593          	addi	a1,a1,1148 # 8358 <malloc+0x172c>
    2ee4:	4501                	li	a0,0
    2ee6:	00004097          	auipc	ra,0x4
    2eea:	8e0080e7          	jalr	-1824(ra) # 67c6 <exit>
  wait(&xstatus,"");
    2eee:	00005597          	auipc	a1,0x5
    2ef2:	46a58593          	addi	a1,a1,1130 # 8358 <malloc+0x172c>
    2ef6:	fcc40513          	addi	a0,s0,-52
    2efa:	00004097          	auipc	ra,0x4
    2efe:	8d4080e7          	jalr	-1836(ra) # 67ce <wait>
  if(xstatus == 1){
    2f02:	fcc42703          	lw	a4,-52(s0)
    2f06:	4785                	li	a5,1
    2f08:	00f70d63          	beq	a4,a5,2f22 <sbrkbasic+0xc2>
  a = sbrk(0);
    2f0c:	4501                	li	a0,0
    2f0e:	00004097          	auipc	ra,0x4
    2f12:	940080e7          	jalr	-1728(ra) # 684e <sbrk>
    2f16:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    2f18:	4901                	li	s2,0
    2f1a:	6985                	lui	s3,0x1
    2f1c:	38898993          	addi	s3,s3,904 # 1388 <bigdir+0x20>
    2f20:	a025                	j	2f48 <sbrkbasic+0xe8>
    printf("%s: too much memory allocated!\n", s);
    2f22:	85d2                	mv	a1,s4
    2f24:	00005517          	auipc	a0,0x5
    2f28:	c1c50513          	addi	a0,a0,-996 # 7b40 <malloc+0xf14>
    2f2c:	00004097          	auipc	ra,0x4
    2f30:	c42080e7          	jalr	-958(ra) # 6b6e <printf>
    exit(1,"");
    2f34:	00005597          	auipc	a1,0x5
    2f38:	42458593          	addi	a1,a1,1060 # 8358 <malloc+0x172c>
    2f3c:	4505                	li	a0,1
    2f3e:	00004097          	auipc	ra,0x4
    2f42:	888080e7          	jalr	-1912(ra) # 67c6 <exit>
    a = b + 1;
    2f46:	84be                	mv	s1,a5
    b = sbrk(1);
    2f48:	4505                	li	a0,1
    2f4a:	00004097          	auipc	ra,0x4
    2f4e:	904080e7          	jalr	-1788(ra) # 684e <sbrk>
    if(b != a){
    2f52:	06951063          	bne	a0,s1,2fb2 <sbrkbasic+0x152>
    *b = 1;
    2f56:	4785                	li	a5,1
    2f58:	00f48023          	sb	a5,0(s1)
    a = b + 1;
    2f5c:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    2f60:	2905                	addiw	s2,s2,1
    2f62:	ff3912e3          	bne	s2,s3,2f46 <sbrkbasic+0xe6>
  pid = fork();
    2f66:	00004097          	auipc	ra,0x4
    2f6a:	858080e7          	jalr	-1960(ra) # 67be <fork>
    2f6e:	892a                	mv	s2,a0
  if(pid < 0){
    2f70:	06054663          	bltz	a0,2fdc <sbrkbasic+0x17c>
  c = sbrk(1);
    2f74:	4505                	li	a0,1
    2f76:	00004097          	auipc	ra,0x4
    2f7a:	8d8080e7          	jalr	-1832(ra) # 684e <sbrk>
  c = sbrk(1);
    2f7e:	4505                	li	a0,1
    2f80:	00004097          	auipc	ra,0x4
    2f84:	8ce080e7          	jalr	-1842(ra) # 684e <sbrk>
  if(c != a + 1){
    2f88:	0489                	addi	s1,s1,2
    2f8a:	06a48b63          	beq	s1,a0,3000 <sbrkbasic+0x1a0>
    printf("%s: sbrk test failed post-fork\n", s);
    2f8e:	85d2                	mv	a1,s4
    2f90:	00005517          	auipc	a0,0x5
    2f94:	c1050513          	addi	a0,a0,-1008 # 7ba0 <malloc+0xf74>
    2f98:	00004097          	auipc	ra,0x4
    2f9c:	bd6080e7          	jalr	-1066(ra) # 6b6e <printf>
    exit(1,"");
    2fa0:	00005597          	auipc	a1,0x5
    2fa4:	3b858593          	addi	a1,a1,952 # 8358 <malloc+0x172c>
    2fa8:	4505                	li	a0,1
    2faa:	00004097          	auipc	ra,0x4
    2fae:	81c080e7          	jalr	-2020(ra) # 67c6 <exit>
      printf("%s: sbrk test failed %d %x %x\n", s, i, a, b);
    2fb2:	872a                	mv	a4,a0
    2fb4:	86a6                	mv	a3,s1
    2fb6:	864a                	mv	a2,s2
    2fb8:	85d2                	mv	a1,s4
    2fba:	00005517          	auipc	a0,0x5
    2fbe:	ba650513          	addi	a0,a0,-1114 # 7b60 <malloc+0xf34>
    2fc2:	00004097          	auipc	ra,0x4
    2fc6:	bac080e7          	jalr	-1108(ra) # 6b6e <printf>
      exit(1,"");
    2fca:	00005597          	auipc	a1,0x5
    2fce:	38e58593          	addi	a1,a1,910 # 8358 <malloc+0x172c>
    2fd2:	4505                	li	a0,1
    2fd4:	00003097          	auipc	ra,0x3
    2fd8:	7f2080e7          	jalr	2034(ra) # 67c6 <exit>
    printf("%s: sbrk test fork failed\n", s);
    2fdc:	85d2                	mv	a1,s4
    2fde:	00005517          	auipc	a0,0x5
    2fe2:	ba250513          	addi	a0,a0,-1118 # 7b80 <malloc+0xf54>
    2fe6:	00004097          	auipc	ra,0x4
    2fea:	b88080e7          	jalr	-1144(ra) # 6b6e <printf>
    exit(1,"");
    2fee:	00005597          	auipc	a1,0x5
    2ff2:	36a58593          	addi	a1,a1,874 # 8358 <malloc+0x172c>
    2ff6:	4505                	li	a0,1
    2ff8:	00003097          	auipc	ra,0x3
    2ffc:	7ce080e7          	jalr	1998(ra) # 67c6 <exit>
  if(pid == 0)
    3000:	00091b63          	bnez	s2,3016 <sbrkbasic+0x1b6>
    exit(0,"");
    3004:	00005597          	auipc	a1,0x5
    3008:	35458593          	addi	a1,a1,852 # 8358 <malloc+0x172c>
    300c:	4501                	li	a0,0
    300e:	00003097          	auipc	ra,0x3
    3012:	7b8080e7          	jalr	1976(ra) # 67c6 <exit>
  wait(&xstatus,"");
    3016:	00005597          	auipc	a1,0x5
    301a:	34258593          	addi	a1,a1,834 # 8358 <malloc+0x172c>
    301e:	fcc40513          	addi	a0,s0,-52
    3022:	00003097          	auipc	ra,0x3
    3026:	7ac080e7          	jalr	1964(ra) # 67ce <wait>
  exit(xstatus,"");
    302a:	00005597          	auipc	a1,0x5
    302e:	32e58593          	addi	a1,a1,814 # 8358 <malloc+0x172c>
    3032:	fcc42503          	lw	a0,-52(s0)
    3036:	00003097          	auipc	ra,0x3
    303a:	790080e7          	jalr	1936(ra) # 67c6 <exit>

000000000000303e <sbrkmuch>:
{
    303e:	7179                	addi	sp,sp,-48
    3040:	f406                	sd	ra,40(sp)
    3042:	f022                	sd	s0,32(sp)
    3044:	ec26                	sd	s1,24(sp)
    3046:	e84a                	sd	s2,16(sp)
    3048:	e44e                	sd	s3,8(sp)
    304a:	e052                	sd	s4,0(sp)
    304c:	1800                	addi	s0,sp,48
    304e:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    3050:	4501                	li	a0,0
    3052:	00003097          	auipc	ra,0x3
    3056:	7fc080e7          	jalr	2044(ra) # 684e <sbrk>
    305a:	892a                	mv	s2,a0
  a = sbrk(0);
    305c:	4501                	li	a0,0
    305e:	00003097          	auipc	ra,0x3
    3062:	7f0080e7          	jalr	2032(ra) # 684e <sbrk>
    3066:	84aa                	mv	s1,a0
  p = sbrk(amt);
    3068:	06400537          	lui	a0,0x6400
    306c:	9d05                	subw	a0,a0,s1
    306e:	00003097          	auipc	ra,0x3
    3072:	7e0080e7          	jalr	2016(ra) # 684e <sbrk>
  if (p != a) {
    3076:	0ca49863          	bne	s1,a0,3146 <sbrkmuch+0x108>
  char *eee = sbrk(0);
    307a:	4501                	li	a0,0
    307c:	00003097          	auipc	ra,0x3
    3080:	7d2080e7          	jalr	2002(ra) # 684e <sbrk>
    3084:	87aa                	mv	a5,a0
  for(char *pp = a; pp < eee; pp += 4096)
    3086:	00a4f963          	bgeu	s1,a0,3098 <sbrkmuch+0x5a>
    *pp = 1;
    308a:	4685                	li	a3,1
  for(char *pp = a; pp < eee; pp += 4096)
    308c:	6705                	lui	a4,0x1
    *pp = 1;
    308e:	00d48023          	sb	a3,0(s1)
  for(char *pp = a; pp < eee; pp += 4096)
    3092:	94ba                	add	s1,s1,a4
    3094:	fef4ede3          	bltu	s1,a5,308e <sbrkmuch+0x50>
  *lastaddr = 99;
    3098:	064007b7          	lui	a5,0x6400
    309c:	06300713          	li	a4,99
    30a0:	fee78fa3          	sb	a4,-1(a5) # 63fffff <base+0x63ef387>
  a = sbrk(0);
    30a4:	4501                	li	a0,0
    30a6:	00003097          	auipc	ra,0x3
    30aa:	7a8080e7          	jalr	1960(ra) # 684e <sbrk>
    30ae:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    30b0:	757d                	lui	a0,0xfffff
    30b2:	00003097          	auipc	ra,0x3
    30b6:	79c080e7          	jalr	1948(ra) # 684e <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    30ba:	57fd                	li	a5,-1
    30bc:	0af50763          	beq	a0,a5,316a <sbrkmuch+0x12c>
  c = sbrk(0);
    30c0:	4501                	li	a0,0
    30c2:	00003097          	auipc	ra,0x3
    30c6:	78c080e7          	jalr	1932(ra) # 684e <sbrk>
  if(c != a - PGSIZE){
    30ca:	77fd                	lui	a5,0xfffff
    30cc:	97a6                	add	a5,a5,s1
    30ce:	0cf51063          	bne	a0,a5,318e <sbrkmuch+0x150>
  a = sbrk(0);
    30d2:	4501                	li	a0,0
    30d4:	00003097          	auipc	ra,0x3
    30d8:	77a080e7          	jalr	1914(ra) # 684e <sbrk>
    30dc:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    30de:	6505                	lui	a0,0x1
    30e0:	00003097          	auipc	ra,0x3
    30e4:	76e080e7          	jalr	1902(ra) # 684e <sbrk>
    30e8:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    30ea:	0ca49663          	bne	s1,a0,31b6 <sbrkmuch+0x178>
    30ee:	4501                	li	a0,0
    30f0:	00003097          	auipc	ra,0x3
    30f4:	75e080e7          	jalr	1886(ra) # 684e <sbrk>
    30f8:	6785                	lui	a5,0x1
    30fa:	97a6                	add	a5,a5,s1
    30fc:	0af51d63          	bne	a0,a5,31b6 <sbrkmuch+0x178>
  if(*lastaddr == 99){
    3100:	064007b7          	lui	a5,0x6400
    3104:	fff7c703          	lbu	a4,-1(a5) # 63fffff <base+0x63ef387>
    3108:	06300793          	li	a5,99
    310c:	0cf70963          	beq	a4,a5,31de <sbrkmuch+0x1a0>
  a = sbrk(0);
    3110:	4501                	li	a0,0
    3112:	00003097          	auipc	ra,0x3
    3116:	73c080e7          	jalr	1852(ra) # 684e <sbrk>
    311a:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    311c:	4501                	li	a0,0
    311e:	00003097          	auipc	ra,0x3
    3122:	730080e7          	jalr	1840(ra) # 684e <sbrk>
    3126:	40a9053b          	subw	a0,s2,a0
    312a:	00003097          	auipc	ra,0x3
    312e:	724080e7          	jalr	1828(ra) # 684e <sbrk>
  if(c != a){
    3132:	0ca49863          	bne	s1,a0,3202 <sbrkmuch+0x1c4>
}
    3136:	70a2                	ld	ra,40(sp)
    3138:	7402                	ld	s0,32(sp)
    313a:	64e2                	ld	s1,24(sp)
    313c:	6942                	ld	s2,16(sp)
    313e:	69a2                	ld	s3,8(sp)
    3140:	6a02                	ld	s4,0(sp)
    3142:	6145                	addi	sp,sp,48
    3144:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    3146:	85ce                	mv	a1,s3
    3148:	00005517          	auipc	a0,0x5
    314c:	a7850513          	addi	a0,a0,-1416 # 7bc0 <malloc+0xf94>
    3150:	00004097          	auipc	ra,0x4
    3154:	a1e080e7          	jalr	-1506(ra) # 6b6e <printf>
    exit(1,"");
    3158:	00005597          	auipc	a1,0x5
    315c:	20058593          	addi	a1,a1,512 # 8358 <malloc+0x172c>
    3160:	4505                	li	a0,1
    3162:	00003097          	auipc	ra,0x3
    3166:	664080e7          	jalr	1636(ra) # 67c6 <exit>
    printf("%s: sbrk could not deallocate\n", s);
    316a:	85ce                	mv	a1,s3
    316c:	00005517          	auipc	a0,0x5
    3170:	a9c50513          	addi	a0,a0,-1380 # 7c08 <malloc+0xfdc>
    3174:	00004097          	auipc	ra,0x4
    3178:	9fa080e7          	jalr	-1542(ra) # 6b6e <printf>
    exit(1,"");
    317c:	00005597          	auipc	a1,0x5
    3180:	1dc58593          	addi	a1,a1,476 # 8358 <malloc+0x172c>
    3184:	4505                	li	a0,1
    3186:	00003097          	auipc	ra,0x3
    318a:	640080e7          	jalr	1600(ra) # 67c6 <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", s, a, c);
    318e:	86aa                	mv	a3,a0
    3190:	8626                	mv	a2,s1
    3192:	85ce                	mv	a1,s3
    3194:	00005517          	auipc	a0,0x5
    3198:	a9450513          	addi	a0,a0,-1388 # 7c28 <malloc+0xffc>
    319c:	00004097          	auipc	ra,0x4
    31a0:	9d2080e7          	jalr	-1582(ra) # 6b6e <printf>
    exit(1,"");
    31a4:	00005597          	auipc	a1,0x5
    31a8:	1b458593          	addi	a1,a1,436 # 8358 <malloc+0x172c>
    31ac:	4505                	li	a0,1
    31ae:	00003097          	auipc	ra,0x3
    31b2:	618080e7          	jalr	1560(ra) # 67c6 <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", s, a, c);
    31b6:	86d2                	mv	a3,s4
    31b8:	8626                	mv	a2,s1
    31ba:	85ce                	mv	a1,s3
    31bc:	00005517          	auipc	a0,0x5
    31c0:	aac50513          	addi	a0,a0,-1364 # 7c68 <malloc+0x103c>
    31c4:	00004097          	auipc	ra,0x4
    31c8:	9aa080e7          	jalr	-1622(ra) # 6b6e <printf>
    exit(1,"");
    31cc:	00005597          	auipc	a1,0x5
    31d0:	18c58593          	addi	a1,a1,396 # 8358 <malloc+0x172c>
    31d4:	4505                	li	a0,1
    31d6:	00003097          	auipc	ra,0x3
    31da:	5f0080e7          	jalr	1520(ra) # 67c6 <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    31de:	85ce                	mv	a1,s3
    31e0:	00005517          	auipc	a0,0x5
    31e4:	ab850513          	addi	a0,a0,-1352 # 7c98 <malloc+0x106c>
    31e8:	00004097          	auipc	ra,0x4
    31ec:	986080e7          	jalr	-1658(ra) # 6b6e <printf>
    exit(1,"");
    31f0:	00005597          	auipc	a1,0x5
    31f4:	16858593          	addi	a1,a1,360 # 8358 <malloc+0x172c>
    31f8:	4505                	li	a0,1
    31fa:	00003097          	auipc	ra,0x3
    31fe:	5cc080e7          	jalr	1484(ra) # 67c6 <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", s, a, c);
    3202:	86aa                	mv	a3,a0
    3204:	8626                	mv	a2,s1
    3206:	85ce                	mv	a1,s3
    3208:	00005517          	auipc	a0,0x5
    320c:	ac850513          	addi	a0,a0,-1336 # 7cd0 <malloc+0x10a4>
    3210:	00004097          	auipc	ra,0x4
    3214:	95e080e7          	jalr	-1698(ra) # 6b6e <printf>
    exit(1,"");
    3218:	00005597          	auipc	a1,0x5
    321c:	14058593          	addi	a1,a1,320 # 8358 <malloc+0x172c>
    3220:	4505                	li	a0,1
    3222:	00003097          	auipc	ra,0x3
    3226:	5a4080e7          	jalr	1444(ra) # 67c6 <exit>

000000000000322a <sbrkarg>:
{
    322a:	7179                	addi	sp,sp,-48
    322c:	f406                	sd	ra,40(sp)
    322e:	f022                	sd	s0,32(sp)
    3230:	ec26                	sd	s1,24(sp)
    3232:	e84a                	sd	s2,16(sp)
    3234:	e44e                	sd	s3,8(sp)
    3236:	1800                	addi	s0,sp,48
    3238:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    323a:	6505                	lui	a0,0x1
    323c:	00003097          	auipc	ra,0x3
    3240:	612080e7          	jalr	1554(ra) # 684e <sbrk>
    3244:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    3246:	20100593          	li	a1,513
    324a:	00005517          	auipc	a0,0x5
    324e:	aae50513          	addi	a0,a0,-1362 # 7cf8 <malloc+0x10cc>
    3252:	00003097          	auipc	ra,0x3
    3256:	5b4080e7          	jalr	1460(ra) # 6806 <open>
    325a:	84aa                	mv	s1,a0
  unlink("sbrk");
    325c:	00005517          	auipc	a0,0x5
    3260:	a9c50513          	addi	a0,a0,-1380 # 7cf8 <malloc+0x10cc>
    3264:	00003097          	auipc	ra,0x3
    3268:	5b2080e7          	jalr	1458(ra) # 6816 <unlink>
  if(fd < 0)  {
    326c:	0404c163          	bltz	s1,32ae <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    3270:	6605                	lui	a2,0x1
    3272:	85ca                	mv	a1,s2
    3274:	8526                	mv	a0,s1
    3276:	00003097          	auipc	ra,0x3
    327a:	570080e7          	jalr	1392(ra) # 67e6 <write>
    327e:	04054a63          	bltz	a0,32d2 <sbrkarg+0xa8>
  close(fd);
    3282:	8526                	mv	a0,s1
    3284:	00003097          	auipc	ra,0x3
    3288:	56a080e7          	jalr	1386(ra) # 67ee <close>
  a = sbrk(PGSIZE);
    328c:	6505                	lui	a0,0x1
    328e:	00003097          	auipc	ra,0x3
    3292:	5c0080e7          	jalr	1472(ra) # 684e <sbrk>
  if(pipe((int *) a) != 0){
    3296:	00003097          	auipc	ra,0x3
    329a:	540080e7          	jalr	1344(ra) # 67d6 <pipe>
    329e:	ed21                	bnez	a0,32f6 <sbrkarg+0xcc>
}
    32a0:	70a2                	ld	ra,40(sp)
    32a2:	7402                	ld	s0,32(sp)
    32a4:	64e2                	ld	s1,24(sp)
    32a6:	6942                	ld	s2,16(sp)
    32a8:	69a2                	ld	s3,8(sp)
    32aa:	6145                	addi	sp,sp,48
    32ac:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    32ae:	85ce                	mv	a1,s3
    32b0:	00005517          	auipc	a0,0x5
    32b4:	a5050513          	addi	a0,a0,-1456 # 7d00 <malloc+0x10d4>
    32b8:	00004097          	auipc	ra,0x4
    32bc:	8b6080e7          	jalr	-1866(ra) # 6b6e <printf>
    exit(1,"");
    32c0:	00005597          	auipc	a1,0x5
    32c4:	09858593          	addi	a1,a1,152 # 8358 <malloc+0x172c>
    32c8:	4505                	li	a0,1
    32ca:	00003097          	auipc	ra,0x3
    32ce:	4fc080e7          	jalr	1276(ra) # 67c6 <exit>
    printf("%s: write sbrk failed\n", s);
    32d2:	85ce                	mv	a1,s3
    32d4:	00005517          	auipc	a0,0x5
    32d8:	a4450513          	addi	a0,a0,-1468 # 7d18 <malloc+0x10ec>
    32dc:	00004097          	auipc	ra,0x4
    32e0:	892080e7          	jalr	-1902(ra) # 6b6e <printf>
    exit(1,"");
    32e4:	00005597          	auipc	a1,0x5
    32e8:	07458593          	addi	a1,a1,116 # 8358 <malloc+0x172c>
    32ec:	4505                	li	a0,1
    32ee:	00003097          	auipc	ra,0x3
    32f2:	4d8080e7          	jalr	1240(ra) # 67c6 <exit>
    printf("%s: pipe() failed\n", s);
    32f6:	85ce                	mv	a1,s3
    32f8:	00004517          	auipc	a0,0x4
    32fc:	40050513          	addi	a0,a0,1024 # 76f8 <malloc+0xacc>
    3300:	00004097          	auipc	ra,0x4
    3304:	86e080e7          	jalr	-1938(ra) # 6b6e <printf>
    exit(1,"");
    3308:	00005597          	auipc	a1,0x5
    330c:	05058593          	addi	a1,a1,80 # 8358 <malloc+0x172c>
    3310:	4505                	li	a0,1
    3312:	00003097          	auipc	ra,0x3
    3316:	4b4080e7          	jalr	1204(ra) # 67c6 <exit>

000000000000331a <argptest>:
{
    331a:	1101                	addi	sp,sp,-32
    331c:	ec06                	sd	ra,24(sp)
    331e:	e822                	sd	s0,16(sp)
    3320:	e426                	sd	s1,8(sp)
    3322:	e04a                	sd	s2,0(sp)
    3324:	1000                	addi	s0,sp,32
    3326:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    3328:	4581                	li	a1,0
    332a:	00005517          	auipc	a0,0x5
    332e:	a0650513          	addi	a0,a0,-1530 # 7d30 <malloc+0x1104>
    3332:	00003097          	auipc	ra,0x3
    3336:	4d4080e7          	jalr	1236(ra) # 6806 <open>
  if (fd < 0) {
    333a:	02054b63          	bltz	a0,3370 <argptest+0x56>
    333e:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    3340:	4501                	li	a0,0
    3342:	00003097          	auipc	ra,0x3
    3346:	50c080e7          	jalr	1292(ra) # 684e <sbrk>
    334a:	567d                	li	a2,-1
    334c:	fff50593          	addi	a1,a0,-1
    3350:	8526                	mv	a0,s1
    3352:	00003097          	auipc	ra,0x3
    3356:	48c080e7          	jalr	1164(ra) # 67de <read>
  close(fd);
    335a:	8526                	mv	a0,s1
    335c:	00003097          	auipc	ra,0x3
    3360:	492080e7          	jalr	1170(ra) # 67ee <close>
}
    3364:	60e2                	ld	ra,24(sp)
    3366:	6442                	ld	s0,16(sp)
    3368:	64a2                	ld	s1,8(sp)
    336a:	6902                	ld	s2,0(sp)
    336c:	6105                	addi	sp,sp,32
    336e:	8082                	ret
    printf("%s: open failed\n", s);
    3370:	85ca                	mv	a1,s2
    3372:	00004517          	auipc	a0,0x4
    3376:	29650513          	addi	a0,a0,662 # 7608 <malloc+0x9dc>
    337a:	00003097          	auipc	ra,0x3
    337e:	7f4080e7          	jalr	2036(ra) # 6b6e <printf>
    exit(1,"");
    3382:	00005597          	auipc	a1,0x5
    3386:	fd658593          	addi	a1,a1,-42 # 8358 <malloc+0x172c>
    338a:	4505                	li	a0,1
    338c:	00003097          	auipc	ra,0x3
    3390:	43a080e7          	jalr	1082(ra) # 67c6 <exit>

0000000000003394 <sbrkbugs>:
{
    3394:	1141                	addi	sp,sp,-16
    3396:	e406                	sd	ra,8(sp)
    3398:	e022                	sd	s0,0(sp)
    339a:	0800                	addi	s0,sp,16
  int pid = fork();
    339c:	00003097          	auipc	ra,0x3
    33a0:	422080e7          	jalr	1058(ra) # 67be <fork>
  if(pid < 0){
    33a4:	02054663          	bltz	a0,33d0 <sbrkbugs+0x3c>
  if(pid == 0){
    33a8:	e529                	bnez	a0,33f2 <sbrkbugs+0x5e>
    int sz = (uint64) sbrk(0);
    33aa:	00003097          	auipc	ra,0x3
    33ae:	4a4080e7          	jalr	1188(ra) # 684e <sbrk>
    sbrk(-sz);
    33b2:	40a0053b          	negw	a0,a0
    33b6:	00003097          	auipc	ra,0x3
    33ba:	498080e7          	jalr	1176(ra) # 684e <sbrk>
    exit(0,"");
    33be:	00005597          	auipc	a1,0x5
    33c2:	f9a58593          	addi	a1,a1,-102 # 8358 <malloc+0x172c>
    33c6:	4501                	li	a0,0
    33c8:	00003097          	auipc	ra,0x3
    33cc:	3fe080e7          	jalr	1022(ra) # 67c6 <exit>
    printf("fork failed\n");
    33d0:	00004517          	auipc	a0,0x4
    33d4:	62850513          	addi	a0,a0,1576 # 79f8 <malloc+0xdcc>
    33d8:	00003097          	auipc	ra,0x3
    33dc:	796080e7          	jalr	1942(ra) # 6b6e <printf>
    exit(1,"");
    33e0:	00005597          	auipc	a1,0x5
    33e4:	f7858593          	addi	a1,a1,-136 # 8358 <malloc+0x172c>
    33e8:	4505                	li	a0,1
    33ea:	00003097          	auipc	ra,0x3
    33ee:	3dc080e7          	jalr	988(ra) # 67c6 <exit>
  wait(0,"");
    33f2:	00005597          	auipc	a1,0x5
    33f6:	f6658593          	addi	a1,a1,-154 # 8358 <malloc+0x172c>
    33fa:	4501                	li	a0,0
    33fc:	00003097          	auipc	ra,0x3
    3400:	3d2080e7          	jalr	978(ra) # 67ce <wait>
  pid = fork();
    3404:	00003097          	auipc	ra,0x3
    3408:	3ba080e7          	jalr	954(ra) # 67be <fork>
  if(pid < 0){
    340c:	02054963          	bltz	a0,343e <sbrkbugs+0xaa>
  if(pid == 0){
    3410:	e921                	bnez	a0,3460 <sbrkbugs+0xcc>
    int sz = (uint64) sbrk(0);
    3412:	00003097          	auipc	ra,0x3
    3416:	43c080e7          	jalr	1084(ra) # 684e <sbrk>
    sbrk(-(sz - 3500));
    341a:	6785                	lui	a5,0x1
    341c:	dac7879b          	addiw	a5,a5,-596
    3420:	40a7853b          	subw	a0,a5,a0
    3424:	00003097          	auipc	ra,0x3
    3428:	42a080e7          	jalr	1066(ra) # 684e <sbrk>
    exit(0,"");
    342c:	00005597          	auipc	a1,0x5
    3430:	f2c58593          	addi	a1,a1,-212 # 8358 <malloc+0x172c>
    3434:	4501                	li	a0,0
    3436:	00003097          	auipc	ra,0x3
    343a:	390080e7          	jalr	912(ra) # 67c6 <exit>
    printf("fork failed\n");
    343e:	00004517          	auipc	a0,0x4
    3442:	5ba50513          	addi	a0,a0,1466 # 79f8 <malloc+0xdcc>
    3446:	00003097          	auipc	ra,0x3
    344a:	728080e7          	jalr	1832(ra) # 6b6e <printf>
    exit(1,"");
    344e:	00005597          	auipc	a1,0x5
    3452:	f0a58593          	addi	a1,a1,-246 # 8358 <malloc+0x172c>
    3456:	4505                	li	a0,1
    3458:	00003097          	auipc	ra,0x3
    345c:	36e080e7          	jalr	878(ra) # 67c6 <exit>
  wait(0,"");
    3460:	00005597          	auipc	a1,0x5
    3464:	ef858593          	addi	a1,a1,-264 # 8358 <malloc+0x172c>
    3468:	4501                	li	a0,0
    346a:	00003097          	auipc	ra,0x3
    346e:	364080e7          	jalr	868(ra) # 67ce <wait>
  pid = fork();
    3472:	00003097          	auipc	ra,0x3
    3476:	34c080e7          	jalr	844(ra) # 67be <fork>
  if(pid < 0){
    347a:	02054e63          	bltz	a0,34b6 <sbrkbugs+0x122>
  if(pid == 0){
    347e:	ed29                	bnez	a0,34d8 <sbrkbugs+0x144>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    3480:	00003097          	auipc	ra,0x3
    3484:	3ce080e7          	jalr	974(ra) # 684e <sbrk>
    3488:	67ad                	lui	a5,0xb
    348a:	8007879b          	addiw	a5,a5,-2048
    348e:	40a7853b          	subw	a0,a5,a0
    3492:	00003097          	auipc	ra,0x3
    3496:	3bc080e7          	jalr	956(ra) # 684e <sbrk>
    sbrk(-10);
    349a:	5559                	li	a0,-10
    349c:	00003097          	auipc	ra,0x3
    34a0:	3b2080e7          	jalr	946(ra) # 684e <sbrk>
    exit(0,"");
    34a4:	00005597          	auipc	a1,0x5
    34a8:	eb458593          	addi	a1,a1,-332 # 8358 <malloc+0x172c>
    34ac:	4501                	li	a0,0
    34ae:	00003097          	auipc	ra,0x3
    34b2:	318080e7          	jalr	792(ra) # 67c6 <exit>
    printf("fork failed\n");
    34b6:	00004517          	auipc	a0,0x4
    34ba:	54250513          	addi	a0,a0,1346 # 79f8 <malloc+0xdcc>
    34be:	00003097          	auipc	ra,0x3
    34c2:	6b0080e7          	jalr	1712(ra) # 6b6e <printf>
    exit(1,"");
    34c6:	00005597          	auipc	a1,0x5
    34ca:	e9258593          	addi	a1,a1,-366 # 8358 <malloc+0x172c>
    34ce:	4505                	li	a0,1
    34d0:	00003097          	auipc	ra,0x3
    34d4:	2f6080e7          	jalr	758(ra) # 67c6 <exit>
  wait(0,"");
    34d8:	00005597          	auipc	a1,0x5
    34dc:	e8058593          	addi	a1,a1,-384 # 8358 <malloc+0x172c>
    34e0:	4501                	li	a0,0
    34e2:	00003097          	auipc	ra,0x3
    34e6:	2ec080e7          	jalr	748(ra) # 67ce <wait>
  exit(0,"");
    34ea:	00005597          	auipc	a1,0x5
    34ee:	e6e58593          	addi	a1,a1,-402 # 8358 <malloc+0x172c>
    34f2:	4501                	li	a0,0
    34f4:	00003097          	auipc	ra,0x3
    34f8:	2d2080e7          	jalr	722(ra) # 67c6 <exit>

00000000000034fc <sbrklast>:
{
    34fc:	7179                	addi	sp,sp,-48
    34fe:	f406                	sd	ra,40(sp)
    3500:	f022                	sd	s0,32(sp)
    3502:	ec26                	sd	s1,24(sp)
    3504:	e84a                	sd	s2,16(sp)
    3506:	e44e                	sd	s3,8(sp)
    3508:	e052                	sd	s4,0(sp)
    350a:	1800                	addi	s0,sp,48
  uint64 top = (uint64) sbrk(0);
    350c:	4501                	li	a0,0
    350e:	00003097          	auipc	ra,0x3
    3512:	340080e7          	jalr	832(ra) # 684e <sbrk>
  if((top % 4096) != 0)
    3516:	03451793          	slli	a5,a0,0x34
    351a:	ebd9                	bnez	a5,35b0 <sbrklast+0xb4>
  sbrk(4096);
    351c:	6505                	lui	a0,0x1
    351e:	00003097          	auipc	ra,0x3
    3522:	330080e7          	jalr	816(ra) # 684e <sbrk>
  sbrk(10);
    3526:	4529                	li	a0,10
    3528:	00003097          	auipc	ra,0x3
    352c:	326080e7          	jalr	806(ra) # 684e <sbrk>
  sbrk(-20);
    3530:	5531                	li	a0,-20
    3532:	00003097          	auipc	ra,0x3
    3536:	31c080e7          	jalr	796(ra) # 684e <sbrk>
  top = (uint64) sbrk(0);
    353a:	4501                	li	a0,0
    353c:	00003097          	auipc	ra,0x3
    3540:	312080e7          	jalr	786(ra) # 684e <sbrk>
    3544:	84aa                	mv	s1,a0
  char *p = (char *) (top - 64);
    3546:	fc050913          	addi	s2,a0,-64 # fc0 <unlinkread+0x148>
  p[0] = 'x';
    354a:	07800a13          	li	s4,120
    354e:	fd450023          	sb	s4,-64(a0)
  p[1] = '\0';
    3552:	fc0500a3          	sb	zero,-63(a0)
  int fd = open(p, O_RDWR|O_CREATE);
    3556:	20200593          	li	a1,514
    355a:	854a                	mv	a0,s2
    355c:	00003097          	auipc	ra,0x3
    3560:	2aa080e7          	jalr	682(ra) # 6806 <open>
    3564:	89aa                	mv	s3,a0
  write(fd, p, 1);
    3566:	4605                	li	a2,1
    3568:	85ca                	mv	a1,s2
    356a:	00003097          	auipc	ra,0x3
    356e:	27c080e7          	jalr	636(ra) # 67e6 <write>
  close(fd);
    3572:	854e                	mv	a0,s3
    3574:	00003097          	auipc	ra,0x3
    3578:	27a080e7          	jalr	634(ra) # 67ee <close>
  fd = open(p, O_RDWR);
    357c:	4589                	li	a1,2
    357e:	854a                	mv	a0,s2
    3580:	00003097          	auipc	ra,0x3
    3584:	286080e7          	jalr	646(ra) # 6806 <open>
  p[0] = '\0';
    3588:	fc048023          	sb	zero,-64(s1)
  read(fd, p, 1);
    358c:	4605                	li	a2,1
    358e:	85ca                	mv	a1,s2
    3590:	00003097          	auipc	ra,0x3
    3594:	24e080e7          	jalr	590(ra) # 67de <read>
  if(p[0] != 'x')
    3598:	fc04c783          	lbu	a5,-64(s1)
    359c:	03479463          	bne	a5,s4,35c4 <sbrklast+0xc8>
}
    35a0:	70a2                	ld	ra,40(sp)
    35a2:	7402                	ld	s0,32(sp)
    35a4:	64e2                	ld	s1,24(sp)
    35a6:	6942                	ld	s2,16(sp)
    35a8:	69a2                	ld	s3,8(sp)
    35aa:	6a02                	ld	s4,0(sp)
    35ac:	6145                	addi	sp,sp,48
    35ae:	8082                	ret
    sbrk(4096 - (top % 4096));
    35b0:	0347d513          	srli	a0,a5,0x34
    35b4:	6785                	lui	a5,0x1
    35b6:	40a7853b          	subw	a0,a5,a0
    35ba:	00003097          	auipc	ra,0x3
    35be:	294080e7          	jalr	660(ra) # 684e <sbrk>
    35c2:	bfa9                	j	351c <sbrklast+0x20>
    exit(1,"");
    35c4:	00005597          	auipc	a1,0x5
    35c8:	d9458593          	addi	a1,a1,-620 # 8358 <malloc+0x172c>
    35cc:	4505                	li	a0,1
    35ce:	00003097          	auipc	ra,0x3
    35d2:	1f8080e7          	jalr	504(ra) # 67c6 <exit>

00000000000035d6 <sbrk8000>:
{
    35d6:	1141                	addi	sp,sp,-16
    35d8:	e406                	sd	ra,8(sp)
    35da:	e022                	sd	s0,0(sp)
    35dc:	0800                	addi	s0,sp,16
  sbrk(0x80000004);
    35de:	80000537          	lui	a0,0x80000
    35e2:	0511                	addi	a0,a0,4
    35e4:	00003097          	auipc	ra,0x3
    35e8:	26a080e7          	jalr	618(ra) # 684e <sbrk>
  volatile char *top = sbrk(0);
    35ec:	4501                	li	a0,0
    35ee:	00003097          	auipc	ra,0x3
    35f2:	260080e7          	jalr	608(ra) # 684e <sbrk>
  *(top-1) = *(top-1) + 1;
    35f6:	fff54783          	lbu	a5,-1(a0) # ffffffff7fffffff <base+0xffffffff7ffef387>
    35fa:	0785                	addi	a5,a5,1
    35fc:	0ff7f793          	andi	a5,a5,255
    3600:	fef50fa3          	sb	a5,-1(a0)
}
    3604:	60a2                	ld	ra,8(sp)
    3606:	6402                	ld	s0,0(sp)
    3608:	0141                	addi	sp,sp,16
    360a:	8082                	ret

000000000000360c <execout>:
{
    360c:	715d                	addi	sp,sp,-80
    360e:	e486                	sd	ra,72(sp)
    3610:	e0a2                	sd	s0,64(sp)
    3612:	fc26                	sd	s1,56(sp)
    3614:	f84a                	sd	s2,48(sp)
    3616:	f44e                	sd	s3,40(sp)
    3618:	f052                	sd	s4,32(sp)
    361a:	0880                	addi	s0,sp,80
  for(int avail = 0; avail < 15; avail++){
    361c:	4901                	li	s2,0
      wait((int*)0,"");
    361e:	00005a17          	auipc	s4,0x5
    3622:	d3aa0a13          	addi	s4,s4,-710 # 8358 <malloc+0x172c>
  for(int avail = 0; avail < 15; avail++){
    3626:	49bd                	li	s3,15
    int pid = fork();
    3628:	00003097          	auipc	ra,0x3
    362c:	196080e7          	jalr	406(ra) # 67be <fork>
    3630:	84aa                	mv	s1,a0
    if(pid < 0){
    3632:	02054563          	bltz	a0,365c <execout+0x50>
    } else if(pid == 0){
    3636:	c521                	beqz	a0,367e <execout+0x72>
      wait((int*)0,"");
    3638:	85d2                	mv	a1,s4
    363a:	4501                	li	a0,0
    363c:	00003097          	auipc	ra,0x3
    3640:	192080e7          	jalr	402(ra) # 67ce <wait>
  for(int avail = 0; avail < 15; avail++){
    3644:	2905                	addiw	s2,s2,1
    3646:	ff3911e3          	bne	s2,s3,3628 <execout+0x1c>
  exit(0,"");
    364a:	00005597          	auipc	a1,0x5
    364e:	d0e58593          	addi	a1,a1,-754 # 8358 <malloc+0x172c>
    3652:	4501                	li	a0,0
    3654:	00003097          	auipc	ra,0x3
    3658:	172080e7          	jalr	370(ra) # 67c6 <exit>
      printf("fork failed\n");
    365c:	00004517          	auipc	a0,0x4
    3660:	39c50513          	addi	a0,a0,924 # 79f8 <malloc+0xdcc>
    3664:	00003097          	auipc	ra,0x3
    3668:	50a080e7          	jalr	1290(ra) # 6b6e <printf>
      exit(1,"");
    366c:	00005597          	auipc	a1,0x5
    3670:	cec58593          	addi	a1,a1,-788 # 8358 <malloc+0x172c>
    3674:	4505                	li	a0,1
    3676:	00003097          	auipc	ra,0x3
    367a:	150080e7          	jalr	336(ra) # 67c6 <exit>
        if(a == 0xffffffffffffffffLL)
    367e:	59fd                	li	s3,-1
        *(char*)(a + 4096 - 1) = 1;
    3680:	4a05                	li	s4,1
        uint64 a = (uint64) sbrk(4096);
    3682:	6505                	lui	a0,0x1
    3684:	00003097          	auipc	ra,0x3
    3688:	1ca080e7          	jalr	458(ra) # 684e <sbrk>
        if(a == 0xffffffffffffffffLL)
    368c:	01350763          	beq	a0,s3,369a <execout+0x8e>
        *(char*)(a + 4096 - 1) = 1;
    3690:	6785                	lui	a5,0x1
    3692:	953e                	add	a0,a0,a5
    3694:	ff450fa3          	sb	s4,-1(a0) # fff <unlinkread+0x187>
      while(1){
    3698:	b7ed                	j	3682 <execout+0x76>
      for(int i = 0; i < avail; i++)
    369a:	01205a63          	blez	s2,36ae <execout+0xa2>
        sbrk(-4096);
    369e:	757d                	lui	a0,0xfffff
    36a0:	00003097          	auipc	ra,0x3
    36a4:	1ae080e7          	jalr	430(ra) # 684e <sbrk>
      for(int i = 0; i < avail; i++)
    36a8:	2485                	addiw	s1,s1,1
    36aa:	ff249ae3          	bne	s1,s2,369e <execout+0x92>
      close(1);
    36ae:	4505                	li	a0,1
    36b0:	00003097          	auipc	ra,0x3
    36b4:	13e080e7          	jalr	318(ra) # 67ee <close>
      char *args[] = { "echo", "x", 0 };
    36b8:	00003517          	auipc	a0,0x3
    36bc:	6b050513          	addi	a0,a0,1712 # 6d68 <malloc+0x13c>
    36c0:	faa43c23          	sd	a0,-72(s0)
    36c4:	00003797          	auipc	a5,0x3
    36c8:	71478793          	addi	a5,a5,1812 # 6dd8 <malloc+0x1ac>
    36cc:	fcf43023          	sd	a5,-64(s0)
    36d0:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    36d4:	fb840593          	addi	a1,s0,-72
    36d8:	00003097          	auipc	ra,0x3
    36dc:	126080e7          	jalr	294(ra) # 67fe <exec>
      exit(0,"");
    36e0:	00005597          	auipc	a1,0x5
    36e4:	c7858593          	addi	a1,a1,-904 # 8358 <malloc+0x172c>
    36e8:	4501                	li	a0,0
    36ea:	00003097          	auipc	ra,0x3
    36ee:	0dc080e7          	jalr	220(ra) # 67c6 <exit>

00000000000036f2 <fourteen>:
{
    36f2:	1101                	addi	sp,sp,-32
    36f4:	ec06                	sd	ra,24(sp)
    36f6:	e822                	sd	s0,16(sp)
    36f8:	e426                	sd	s1,8(sp)
    36fa:	1000                	addi	s0,sp,32
    36fc:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    36fe:	00005517          	auipc	a0,0x5
    3702:	80a50513          	addi	a0,a0,-2038 # 7f08 <malloc+0x12dc>
    3706:	00003097          	auipc	ra,0x3
    370a:	128080e7          	jalr	296(ra) # 682e <mkdir>
    370e:	e175                	bnez	a0,37f2 <fourteen+0x100>
  if(mkdir("12345678901234/123456789012345") != 0){
    3710:	00004517          	auipc	a0,0x4
    3714:	65050513          	addi	a0,a0,1616 # 7d60 <malloc+0x1134>
    3718:	00003097          	auipc	ra,0x3
    371c:	116080e7          	jalr	278(ra) # 682e <mkdir>
    3720:	e97d                	bnez	a0,3816 <fourteen+0x124>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    3722:	20000593          	li	a1,512
    3726:	00004517          	auipc	a0,0x4
    372a:	69250513          	addi	a0,a0,1682 # 7db8 <malloc+0x118c>
    372e:	00003097          	auipc	ra,0x3
    3732:	0d8080e7          	jalr	216(ra) # 6806 <open>
  if(fd < 0){
    3736:	10054263          	bltz	a0,383a <fourteen+0x148>
  close(fd);
    373a:	00003097          	auipc	ra,0x3
    373e:	0b4080e7          	jalr	180(ra) # 67ee <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    3742:	4581                	li	a1,0
    3744:	00004517          	auipc	a0,0x4
    3748:	6ec50513          	addi	a0,a0,1772 # 7e30 <malloc+0x1204>
    374c:	00003097          	auipc	ra,0x3
    3750:	0ba080e7          	jalr	186(ra) # 6806 <open>
  if(fd < 0){
    3754:	10054563          	bltz	a0,385e <fourteen+0x16c>
  close(fd);
    3758:	00003097          	auipc	ra,0x3
    375c:	096080e7          	jalr	150(ra) # 67ee <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    3760:	00004517          	auipc	a0,0x4
    3764:	74050513          	addi	a0,a0,1856 # 7ea0 <malloc+0x1274>
    3768:	00003097          	auipc	ra,0x3
    376c:	0c6080e7          	jalr	198(ra) # 682e <mkdir>
    3770:	10050963          	beqz	a0,3882 <fourteen+0x190>
  if(mkdir("123456789012345/12345678901234") == 0){
    3774:	00004517          	auipc	a0,0x4
    3778:	78450513          	addi	a0,a0,1924 # 7ef8 <malloc+0x12cc>
    377c:	00003097          	auipc	ra,0x3
    3780:	0b2080e7          	jalr	178(ra) # 682e <mkdir>
    3784:	12050163          	beqz	a0,38a6 <fourteen+0x1b4>
  unlink("123456789012345/12345678901234");
    3788:	00004517          	auipc	a0,0x4
    378c:	77050513          	addi	a0,a0,1904 # 7ef8 <malloc+0x12cc>
    3790:	00003097          	auipc	ra,0x3
    3794:	086080e7          	jalr	134(ra) # 6816 <unlink>
  unlink("12345678901234/12345678901234");
    3798:	00004517          	auipc	a0,0x4
    379c:	70850513          	addi	a0,a0,1800 # 7ea0 <malloc+0x1274>
    37a0:	00003097          	auipc	ra,0x3
    37a4:	076080e7          	jalr	118(ra) # 6816 <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    37a8:	00004517          	auipc	a0,0x4
    37ac:	68850513          	addi	a0,a0,1672 # 7e30 <malloc+0x1204>
    37b0:	00003097          	auipc	ra,0x3
    37b4:	066080e7          	jalr	102(ra) # 6816 <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    37b8:	00004517          	auipc	a0,0x4
    37bc:	60050513          	addi	a0,a0,1536 # 7db8 <malloc+0x118c>
    37c0:	00003097          	auipc	ra,0x3
    37c4:	056080e7          	jalr	86(ra) # 6816 <unlink>
  unlink("12345678901234/123456789012345");
    37c8:	00004517          	auipc	a0,0x4
    37cc:	59850513          	addi	a0,a0,1432 # 7d60 <malloc+0x1134>
    37d0:	00003097          	auipc	ra,0x3
    37d4:	046080e7          	jalr	70(ra) # 6816 <unlink>
  unlink("12345678901234");
    37d8:	00004517          	auipc	a0,0x4
    37dc:	73050513          	addi	a0,a0,1840 # 7f08 <malloc+0x12dc>
    37e0:	00003097          	auipc	ra,0x3
    37e4:	036080e7          	jalr	54(ra) # 6816 <unlink>
}
    37e8:	60e2                	ld	ra,24(sp)
    37ea:	6442                	ld	s0,16(sp)
    37ec:	64a2                	ld	s1,8(sp)
    37ee:	6105                	addi	sp,sp,32
    37f0:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    37f2:	85a6                	mv	a1,s1
    37f4:	00004517          	auipc	a0,0x4
    37f8:	54450513          	addi	a0,a0,1348 # 7d38 <malloc+0x110c>
    37fc:	00003097          	auipc	ra,0x3
    3800:	372080e7          	jalr	882(ra) # 6b6e <printf>
    exit(1,"");
    3804:	00005597          	auipc	a1,0x5
    3808:	b5458593          	addi	a1,a1,-1196 # 8358 <malloc+0x172c>
    380c:	4505                	li	a0,1
    380e:	00003097          	auipc	ra,0x3
    3812:	fb8080e7          	jalr	-72(ra) # 67c6 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    3816:	85a6                	mv	a1,s1
    3818:	00004517          	auipc	a0,0x4
    381c:	56850513          	addi	a0,a0,1384 # 7d80 <malloc+0x1154>
    3820:	00003097          	auipc	ra,0x3
    3824:	34e080e7          	jalr	846(ra) # 6b6e <printf>
    exit(1,"");
    3828:	00005597          	auipc	a1,0x5
    382c:	b3058593          	addi	a1,a1,-1232 # 8358 <malloc+0x172c>
    3830:	4505                	li	a0,1
    3832:	00003097          	auipc	ra,0x3
    3836:	f94080e7          	jalr	-108(ra) # 67c6 <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    383a:	85a6                	mv	a1,s1
    383c:	00004517          	auipc	a0,0x4
    3840:	5ac50513          	addi	a0,a0,1452 # 7de8 <malloc+0x11bc>
    3844:	00003097          	auipc	ra,0x3
    3848:	32a080e7          	jalr	810(ra) # 6b6e <printf>
    exit(1,"");
    384c:	00005597          	auipc	a1,0x5
    3850:	b0c58593          	addi	a1,a1,-1268 # 8358 <malloc+0x172c>
    3854:	4505                	li	a0,1
    3856:	00003097          	auipc	ra,0x3
    385a:	f70080e7          	jalr	-144(ra) # 67c6 <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    385e:	85a6                	mv	a1,s1
    3860:	00004517          	auipc	a0,0x4
    3864:	60050513          	addi	a0,a0,1536 # 7e60 <malloc+0x1234>
    3868:	00003097          	auipc	ra,0x3
    386c:	306080e7          	jalr	774(ra) # 6b6e <printf>
    exit(1,"");
    3870:	00005597          	auipc	a1,0x5
    3874:	ae858593          	addi	a1,a1,-1304 # 8358 <malloc+0x172c>
    3878:	4505                	li	a0,1
    387a:	00003097          	auipc	ra,0x3
    387e:	f4c080e7          	jalr	-180(ra) # 67c6 <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    3882:	85a6                	mv	a1,s1
    3884:	00004517          	auipc	a0,0x4
    3888:	63c50513          	addi	a0,a0,1596 # 7ec0 <malloc+0x1294>
    388c:	00003097          	auipc	ra,0x3
    3890:	2e2080e7          	jalr	738(ra) # 6b6e <printf>
    exit(1,"");
    3894:	00005597          	auipc	a1,0x5
    3898:	ac458593          	addi	a1,a1,-1340 # 8358 <malloc+0x172c>
    389c:	4505                	li	a0,1
    389e:	00003097          	auipc	ra,0x3
    38a2:	f28080e7          	jalr	-216(ra) # 67c6 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    38a6:	85a6                	mv	a1,s1
    38a8:	00004517          	auipc	a0,0x4
    38ac:	67050513          	addi	a0,a0,1648 # 7f18 <malloc+0x12ec>
    38b0:	00003097          	auipc	ra,0x3
    38b4:	2be080e7          	jalr	702(ra) # 6b6e <printf>
    exit(1,"");
    38b8:	00005597          	auipc	a1,0x5
    38bc:	aa058593          	addi	a1,a1,-1376 # 8358 <malloc+0x172c>
    38c0:	4505                	li	a0,1
    38c2:	00003097          	auipc	ra,0x3
    38c6:	f04080e7          	jalr	-252(ra) # 67c6 <exit>

00000000000038ca <diskfull>:
{
    38ca:	b9010113          	addi	sp,sp,-1136
    38ce:	46113423          	sd	ra,1128(sp)
    38d2:	46813023          	sd	s0,1120(sp)
    38d6:	44913c23          	sd	s1,1112(sp)
    38da:	45213823          	sd	s2,1104(sp)
    38de:	45313423          	sd	s3,1096(sp)
    38e2:	45413023          	sd	s4,1088(sp)
    38e6:	43513c23          	sd	s5,1080(sp)
    38ea:	43613823          	sd	s6,1072(sp)
    38ee:	43713423          	sd	s7,1064(sp)
    38f2:	43813023          	sd	s8,1056(sp)
    38f6:	47010413          	addi	s0,sp,1136
    38fa:	8c2a                	mv	s8,a0
  unlink("diskfulldir");
    38fc:	00004517          	auipc	a0,0x4
    3900:	65450513          	addi	a0,a0,1620 # 7f50 <malloc+0x1324>
    3904:	00003097          	auipc	ra,0x3
    3908:	f12080e7          	jalr	-238(ra) # 6816 <unlink>
  for(fi = 0; done == 0; fi++){
    390c:	4a01                	li	s4,0
    name[0] = 'b';
    390e:	06200b13          	li	s6,98
    name[1] = 'i';
    3912:	06900a93          	li	s5,105
    name[2] = 'g';
    3916:	06700993          	li	s3,103
    391a:	10c00b93          	li	s7,268
    391e:	aabd                	j	3a9c <diskfull+0x1d2>
      printf("%s: could not create file %s\n", s, name);
    3920:	b9040613          	addi	a2,s0,-1136
    3924:	85e2                	mv	a1,s8
    3926:	00004517          	auipc	a0,0x4
    392a:	63a50513          	addi	a0,a0,1594 # 7f60 <malloc+0x1334>
    392e:	00003097          	auipc	ra,0x3
    3932:	240080e7          	jalr	576(ra) # 6b6e <printf>
      break;
    3936:	a821                	j	394e <diskfull+0x84>
        close(fd);
    3938:	854a                	mv	a0,s2
    393a:	00003097          	auipc	ra,0x3
    393e:	eb4080e7          	jalr	-332(ra) # 67ee <close>
    close(fd);
    3942:	854a                	mv	a0,s2
    3944:	00003097          	auipc	ra,0x3
    3948:	eaa080e7          	jalr	-342(ra) # 67ee <close>
  for(fi = 0; done == 0; fi++){
    394c:	2a05                	addiw	s4,s4,1
  for(int i = 0; i < nzz; i++){
    394e:	4481                	li	s1,0
    name[0] = 'z';
    3950:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
    3954:	08000993          	li	s3,128
    name[0] = 'z';
    3958:	bb240823          	sb	s2,-1104(s0)
    name[1] = 'z';
    395c:	bb2408a3          	sb	s2,-1103(s0)
    name[2] = '0' + (i / 32);
    3960:	41f4d79b          	sraiw	a5,s1,0x1f
    3964:	01b7d71b          	srliw	a4,a5,0x1b
    3968:	009707bb          	addw	a5,a4,s1
    396c:	4057d69b          	sraiw	a3,a5,0x5
    3970:	0306869b          	addiw	a3,a3,48
    3974:	bad40923          	sb	a3,-1102(s0)
    name[3] = '0' + (i % 32);
    3978:	8bfd                	andi	a5,a5,31
    397a:	9f99                	subw	a5,a5,a4
    397c:	0307879b          	addiw	a5,a5,48
    3980:	baf409a3          	sb	a5,-1101(s0)
    name[4] = '\0';
    3984:	ba040a23          	sb	zero,-1100(s0)
    unlink(name);
    3988:	bb040513          	addi	a0,s0,-1104
    398c:	00003097          	auipc	ra,0x3
    3990:	e8a080e7          	jalr	-374(ra) # 6816 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    3994:	60200593          	li	a1,1538
    3998:	bb040513          	addi	a0,s0,-1104
    399c:	00003097          	auipc	ra,0x3
    39a0:	e6a080e7          	jalr	-406(ra) # 6806 <open>
    if(fd < 0)
    39a4:	00054963          	bltz	a0,39b6 <diskfull+0xec>
    close(fd);
    39a8:	00003097          	auipc	ra,0x3
    39ac:	e46080e7          	jalr	-442(ra) # 67ee <close>
  for(int i = 0; i < nzz; i++){
    39b0:	2485                	addiw	s1,s1,1
    39b2:	fb3493e3          	bne	s1,s3,3958 <diskfull+0x8e>
  if(mkdir("diskfulldir") == 0)
    39b6:	00004517          	auipc	a0,0x4
    39ba:	59a50513          	addi	a0,a0,1434 # 7f50 <malloc+0x1324>
    39be:	00003097          	auipc	ra,0x3
    39c2:	e70080e7          	jalr	-400(ra) # 682e <mkdir>
    39c6:	12050963          	beqz	a0,3af8 <diskfull+0x22e>
  unlink("diskfulldir");
    39ca:	00004517          	auipc	a0,0x4
    39ce:	58650513          	addi	a0,a0,1414 # 7f50 <malloc+0x1324>
    39d2:	00003097          	auipc	ra,0x3
    39d6:	e44080e7          	jalr	-444(ra) # 6816 <unlink>
  for(int i = 0; i < nzz; i++){
    39da:	4481                	li	s1,0
    name[0] = 'z';
    39dc:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
    39e0:	08000993          	li	s3,128
    name[0] = 'z';
    39e4:	bb240823          	sb	s2,-1104(s0)
    name[1] = 'z';
    39e8:	bb2408a3          	sb	s2,-1103(s0)
    name[2] = '0' + (i / 32);
    39ec:	41f4d79b          	sraiw	a5,s1,0x1f
    39f0:	01b7d71b          	srliw	a4,a5,0x1b
    39f4:	009707bb          	addw	a5,a4,s1
    39f8:	4057d69b          	sraiw	a3,a5,0x5
    39fc:	0306869b          	addiw	a3,a3,48
    3a00:	bad40923          	sb	a3,-1102(s0)
    name[3] = '0' + (i % 32);
    3a04:	8bfd                	andi	a5,a5,31
    3a06:	9f99                	subw	a5,a5,a4
    3a08:	0307879b          	addiw	a5,a5,48
    3a0c:	baf409a3          	sb	a5,-1101(s0)
    name[4] = '\0';
    3a10:	ba040a23          	sb	zero,-1100(s0)
    unlink(name);
    3a14:	bb040513          	addi	a0,s0,-1104
    3a18:	00003097          	auipc	ra,0x3
    3a1c:	dfe080e7          	jalr	-514(ra) # 6816 <unlink>
  for(int i = 0; i < nzz; i++){
    3a20:	2485                	addiw	s1,s1,1
    3a22:	fd3491e3          	bne	s1,s3,39e4 <diskfull+0x11a>
  for(int i = 0; i < fi; i++){
    3a26:	03405e63          	blez	s4,3a62 <diskfull+0x198>
    3a2a:	4481                	li	s1,0
    name[0] = 'b';
    3a2c:	06200a93          	li	s5,98
    name[1] = 'i';
    3a30:	06900993          	li	s3,105
    name[2] = 'g';
    3a34:	06700913          	li	s2,103
    name[0] = 'b';
    3a38:	bb540823          	sb	s5,-1104(s0)
    name[1] = 'i';
    3a3c:	bb3408a3          	sb	s3,-1103(s0)
    name[2] = 'g';
    3a40:	bb240923          	sb	s2,-1102(s0)
    name[3] = '0' + i;
    3a44:	0304879b          	addiw	a5,s1,48
    3a48:	baf409a3          	sb	a5,-1101(s0)
    name[4] = '\0';
    3a4c:	ba040a23          	sb	zero,-1100(s0)
    unlink(name);
    3a50:	bb040513          	addi	a0,s0,-1104
    3a54:	00003097          	auipc	ra,0x3
    3a58:	dc2080e7          	jalr	-574(ra) # 6816 <unlink>
  for(int i = 0; i < fi; i++){
    3a5c:	2485                	addiw	s1,s1,1
    3a5e:	fd449de3          	bne	s1,s4,3a38 <diskfull+0x16e>
}
    3a62:	46813083          	ld	ra,1128(sp)
    3a66:	46013403          	ld	s0,1120(sp)
    3a6a:	45813483          	ld	s1,1112(sp)
    3a6e:	45013903          	ld	s2,1104(sp)
    3a72:	44813983          	ld	s3,1096(sp)
    3a76:	44013a03          	ld	s4,1088(sp)
    3a7a:	43813a83          	ld	s5,1080(sp)
    3a7e:	43013b03          	ld	s6,1072(sp)
    3a82:	42813b83          	ld	s7,1064(sp)
    3a86:	42013c03          	ld	s8,1056(sp)
    3a8a:	47010113          	addi	sp,sp,1136
    3a8e:	8082                	ret
    close(fd);
    3a90:	854a                	mv	a0,s2
    3a92:	00003097          	auipc	ra,0x3
    3a96:	d5c080e7          	jalr	-676(ra) # 67ee <close>
  for(fi = 0; done == 0; fi++){
    3a9a:	2a05                	addiw	s4,s4,1
    name[0] = 'b';
    3a9c:	b9640823          	sb	s6,-1136(s0)
    name[1] = 'i';
    3aa0:	b95408a3          	sb	s5,-1135(s0)
    name[2] = 'g';
    3aa4:	b9340923          	sb	s3,-1134(s0)
    name[3] = '0' + fi;
    3aa8:	030a079b          	addiw	a5,s4,48
    3aac:	b8f409a3          	sb	a5,-1133(s0)
    name[4] = '\0';
    3ab0:	b8040a23          	sb	zero,-1132(s0)
    unlink(name);
    3ab4:	b9040513          	addi	a0,s0,-1136
    3ab8:	00003097          	auipc	ra,0x3
    3abc:	d5e080e7          	jalr	-674(ra) # 6816 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    3ac0:	60200593          	li	a1,1538
    3ac4:	b9040513          	addi	a0,s0,-1136
    3ac8:	00003097          	auipc	ra,0x3
    3acc:	d3e080e7          	jalr	-706(ra) # 6806 <open>
    3ad0:	892a                	mv	s2,a0
    if(fd < 0){
    3ad2:	e40547e3          	bltz	a0,3920 <diskfull+0x56>
    3ad6:	84de                	mv	s1,s7
      if(write(fd, buf, BSIZE) != BSIZE){
    3ad8:	40000613          	li	a2,1024
    3adc:	bb040593          	addi	a1,s0,-1104
    3ae0:	854a                	mv	a0,s2
    3ae2:	00003097          	auipc	ra,0x3
    3ae6:	d04080e7          	jalr	-764(ra) # 67e6 <write>
    3aea:	40000793          	li	a5,1024
    3aee:	e4f515e3          	bne	a0,a5,3938 <diskfull+0x6e>
    for(int i = 0; i < MAXFILE; i++){
    3af2:	34fd                	addiw	s1,s1,-1
    3af4:	f0f5                	bnez	s1,3ad8 <diskfull+0x20e>
    3af6:	bf69                	j	3a90 <diskfull+0x1c6>
    printf("%s: mkdir(diskfulldir) unexpectedly succeeded!\n");
    3af8:	00004517          	auipc	a0,0x4
    3afc:	48850513          	addi	a0,a0,1160 # 7f80 <malloc+0x1354>
    3b00:	00003097          	auipc	ra,0x3
    3b04:	06e080e7          	jalr	110(ra) # 6b6e <printf>
    3b08:	b5c9                	j	39ca <diskfull+0x100>

0000000000003b0a <iputtest>:
{
    3b0a:	1101                	addi	sp,sp,-32
    3b0c:	ec06                	sd	ra,24(sp)
    3b0e:	e822                	sd	s0,16(sp)
    3b10:	e426                	sd	s1,8(sp)
    3b12:	1000                	addi	s0,sp,32
    3b14:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    3b16:	00004517          	auipc	a0,0x4
    3b1a:	49a50513          	addi	a0,a0,1178 # 7fb0 <malloc+0x1384>
    3b1e:	00003097          	auipc	ra,0x3
    3b22:	d10080e7          	jalr	-752(ra) # 682e <mkdir>
    3b26:	04054563          	bltz	a0,3b70 <iputtest+0x66>
  if(chdir("iputdir") < 0){
    3b2a:	00004517          	auipc	a0,0x4
    3b2e:	48650513          	addi	a0,a0,1158 # 7fb0 <malloc+0x1384>
    3b32:	00003097          	auipc	ra,0x3
    3b36:	d04080e7          	jalr	-764(ra) # 6836 <chdir>
    3b3a:	04054d63          	bltz	a0,3b94 <iputtest+0x8a>
  if(unlink("../iputdir") < 0){
    3b3e:	00004517          	auipc	a0,0x4
    3b42:	4b250513          	addi	a0,a0,1202 # 7ff0 <malloc+0x13c4>
    3b46:	00003097          	auipc	ra,0x3
    3b4a:	cd0080e7          	jalr	-816(ra) # 6816 <unlink>
    3b4e:	06054563          	bltz	a0,3bb8 <iputtest+0xae>
  if(chdir("/") < 0){
    3b52:	00004517          	auipc	a0,0x4
    3b56:	4ce50513          	addi	a0,a0,1230 # 8020 <malloc+0x13f4>
    3b5a:	00003097          	auipc	ra,0x3
    3b5e:	cdc080e7          	jalr	-804(ra) # 6836 <chdir>
    3b62:	06054d63          	bltz	a0,3bdc <iputtest+0xd2>
}
    3b66:	60e2                	ld	ra,24(sp)
    3b68:	6442                	ld	s0,16(sp)
    3b6a:	64a2                	ld	s1,8(sp)
    3b6c:	6105                	addi	sp,sp,32
    3b6e:	8082                	ret
    printf("%s: mkdir failed\n", s);
    3b70:	85a6                	mv	a1,s1
    3b72:	00004517          	auipc	a0,0x4
    3b76:	44650513          	addi	a0,a0,1094 # 7fb8 <malloc+0x138c>
    3b7a:	00003097          	auipc	ra,0x3
    3b7e:	ff4080e7          	jalr	-12(ra) # 6b6e <printf>
    exit(1,"");
    3b82:	00004597          	auipc	a1,0x4
    3b86:	7d658593          	addi	a1,a1,2006 # 8358 <malloc+0x172c>
    3b8a:	4505                	li	a0,1
    3b8c:	00003097          	auipc	ra,0x3
    3b90:	c3a080e7          	jalr	-966(ra) # 67c6 <exit>
    printf("%s: chdir iputdir failed\n", s);
    3b94:	85a6                	mv	a1,s1
    3b96:	00004517          	auipc	a0,0x4
    3b9a:	43a50513          	addi	a0,a0,1082 # 7fd0 <malloc+0x13a4>
    3b9e:	00003097          	auipc	ra,0x3
    3ba2:	fd0080e7          	jalr	-48(ra) # 6b6e <printf>
    exit(1,"");
    3ba6:	00004597          	auipc	a1,0x4
    3baa:	7b258593          	addi	a1,a1,1970 # 8358 <malloc+0x172c>
    3bae:	4505                	li	a0,1
    3bb0:	00003097          	auipc	ra,0x3
    3bb4:	c16080e7          	jalr	-1002(ra) # 67c6 <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    3bb8:	85a6                	mv	a1,s1
    3bba:	00004517          	auipc	a0,0x4
    3bbe:	44650513          	addi	a0,a0,1094 # 8000 <malloc+0x13d4>
    3bc2:	00003097          	auipc	ra,0x3
    3bc6:	fac080e7          	jalr	-84(ra) # 6b6e <printf>
    exit(1,"");
    3bca:	00004597          	auipc	a1,0x4
    3bce:	78e58593          	addi	a1,a1,1934 # 8358 <malloc+0x172c>
    3bd2:	4505                	li	a0,1
    3bd4:	00003097          	auipc	ra,0x3
    3bd8:	bf2080e7          	jalr	-1038(ra) # 67c6 <exit>
    printf("%s: chdir / failed\n", s);
    3bdc:	85a6                	mv	a1,s1
    3bde:	00004517          	auipc	a0,0x4
    3be2:	44a50513          	addi	a0,a0,1098 # 8028 <malloc+0x13fc>
    3be6:	00003097          	auipc	ra,0x3
    3bea:	f88080e7          	jalr	-120(ra) # 6b6e <printf>
    exit(1,"");
    3bee:	00004597          	auipc	a1,0x4
    3bf2:	76a58593          	addi	a1,a1,1898 # 8358 <malloc+0x172c>
    3bf6:	4505                	li	a0,1
    3bf8:	00003097          	auipc	ra,0x3
    3bfc:	bce080e7          	jalr	-1074(ra) # 67c6 <exit>

0000000000003c00 <exitiputtest>:
{
    3c00:	7179                	addi	sp,sp,-48
    3c02:	f406                	sd	ra,40(sp)
    3c04:	f022                	sd	s0,32(sp)
    3c06:	ec26                	sd	s1,24(sp)
    3c08:	1800                	addi	s0,sp,48
    3c0a:	84aa                	mv	s1,a0
  pid = fork();
    3c0c:	00003097          	auipc	ra,0x3
    3c10:	bb2080e7          	jalr	-1102(ra) # 67be <fork>
  if(pid < 0){
    3c14:	04054a63          	bltz	a0,3c68 <exitiputtest+0x68>
  if(pid == 0){
    3c18:	e165                	bnez	a0,3cf8 <exitiputtest+0xf8>
    if(mkdir("iputdir") < 0){
    3c1a:	00004517          	auipc	a0,0x4
    3c1e:	39650513          	addi	a0,a0,918 # 7fb0 <malloc+0x1384>
    3c22:	00003097          	auipc	ra,0x3
    3c26:	c0c080e7          	jalr	-1012(ra) # 682e <mkdir>
    3c2a:	06054163          	bltz	a0,3c8c <exitiputtest+0x8c>
    if(chdir("iputdir") < 0){
    3c2e:	00004517          	auipc	a0,0x4
    3c32:	38250513          	addi	a0,a0,898 # 7fb0 <malloc+0x1384>
    3c36:	00003097          	auipc	ra,0x3
    3c3a:	c00080e7          	jalr	-1024(ra) # 6836 <chdir>
    3c3e:	06054963          	bltz	a0,3cb0 <exitiputtest+0xb0>
    if(unlink("../iputdir") < 0){
    3c42:	00004517          	auipc	a0,0x4
    3c46:	3ae50513          	addi	a0,a0,942 # 7ff0 <malloc+0x13c4>
    3c4a:	00003097          	auipc	ra,0x3
    3c4e:	bcc080e7          	jalr	-1076(ra) # 6816 <unlink>
    3c52:	08054163          	bltz	a0,3cd4 <exitiputtest+0xd4>
    exit(0,"");
    3c56:	00004597          	auipc	a1,0x4
    3c5a:	70258593          	addi	a1,a1,1794 # 8358 <malloc+0x172c>
    3c5e:	4501                	li	a0,0
    3c60:	00003097          	auipc	ra,0x3
    3c64:	b66080e7          	jalr	-1178(ra) # 67c6 <exit>
    printf("%s: fork failed\n", s);
    3c68:	85a6                	mv	a1,s1
    3c6a:	00004517          	auipc	a0,0x4
    3c6e:	98650513          	addi	a0,a0,-1658 # 75f0 <malloc+0x9c4>
    3c72:	00003097          	auipc	ra,0x3
    3c76:	efc080e7          	jalr	-260(ra) # 6b6e <printf>
    exit(1,"");
    3c7a:	00004597          	auipc	a1,0x4
    3c7e:	6de58593          	addi	a1,a1,1758 # 8358 <malloc+0x172c>
    3c82:	4505                	li	a0,1
    3c84:	00003097          	auipc	ra,0x3
    3c88:	b42080e7          	jalr	-1214(ra) # 67c6 <exit>
      printf("%s: mkdir failed\n", s);
    3c8c:	85a6                	mv	a1,s1
    3c8e:	00004517          	auipc	a0,0x4
    3c92:	32a50513          	addi	a0,a0,810 # 7fb8 <malloc+0x138c>
    3c96:	00003097          	auipc	ra,0x3
    3c9a:	ed8080e7          	jalr	-296(ra) # 6b6e <printf>
      exit(1,"");
    3c9e:	00004597          	auipc	a1,0x4
    3ca2:	6ba58593          	addi	a1,a1,1722 # 8358 <malloc+0x172c>
    3ca6:	4505                	li	a0,1
    3ca8:	00003097          	auipc	ra,0x3
    3cac:	b1e080e7          	jalr	-1250(ra) # 67c6 <exit>
      printf("%s: child chdir failed\n", s);
    3cb0:	85a6                	mv	a1,s1
    3cb2:	00004517          	auipc	a0,0x4
    3cb6:	38e50513          	addi	a0,a0,910 # 8040 <malloc+0x1414>
    3cba:	00003097          	auipc	ra,0x3
    3cbe:	eb4080e7          	jalr	-332(ra) # 6b6e <printf>
      exit(1,"");
    3cc2:	00004597          	auipc	a1,0x4
    3cc6:	69658593          	addi	a1,a1,1686 # 8358 <malloc+0x172c>
    3cca:	4505                	li	a0,1
    3ccc:	00003097          	auipc	ra,0x3
    3cd0:	afa080e7          	jalr	-1286(ra) # 67c6 <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    3cd4:	85a6                	mv	a1,s1
    3cd6:	00004517          	auipc	a0,0x4
    3cda:	32a50513          	addi	a0,a0,810 # 8000 <malloc+0x13d4>
    3cde:	00003097          	auipc	ra,0x3
    3ce2:	e90080e7          	jalr	-368(ra) # 6b6e <printf>
      exit(1,"");
    3ce6:	00004597          	auipc	a1,0x4
    3cea:	67258593          	addi	a1,a1,1650 # 8358 <malloc+0x172c>
    3cee:	4505                	li	a0,1
    3cf0:	00003097          	auipc	ra,0x3
    3cf4:	ad6080e7          	jalr	-1322(ra) # 67c6 <exit>
  wait(&xstatus,"");
    3cf8:	00004597          	auipc	a1,0x4
    3cfc:	66058593          	addi	a1,a1,1632 # 8358 <malloc+0x172c>
    3d00:	fdc40513          	addi	a0,s0,-36
    3d04:	00003097          	auipc	ra,0x3
    3d08:	aca080e7          	jalr	-1334(ra) # 67ce <wait>
  exit(xstatus,"");
    3d0c:	00004597          	auipc	a1,0x4
    3d10:	64c58593          	addi	a1,a1,1612 # 8358 <malloc+0x172c>
    3d14:	fdc42503          	lw	a0,-36(s0)
    3d18:	00003097          	auipc	ra,0x3
    3d1c:	aae080e7          	jalr	-1362(ra) # 67c6 <exit>

0000000000003d20 <dirtest>:
{
    3d20:	1101                	addi	sp,sp,-32
    3d22:	ec06                	sd	ra,24(sp)
    3d24:	e822                	sd	s0,16(sp)
    3d26:	e426                	sd	s1,8(sp)
    3d28:	1000                	addi	s0,sp,32
    3d2a:	84aa                	mv	s1,a0
  if(mkdir("dir0") < 0){
    3d2c:	00004517          	auipc	a0,0x4
    3d30:	32c50513          	addi	a0,a0,812 # 8058 <malloc+0x142c>
    3d34:	00003097          	auipc	ra,0x3
    3d38:	afa080e7          	jalr	-1286(ra) # 682e <mkdir>
    3d3c:	04054563          	bltz	a0,3d86 <dirtest+0x66>
  if(chdir("dir0") < 0){
    3d40:	00004517          	auipc	a0,0x4
    3d44:	31850513          	addi	a0,a0,792 # 8058 <malloc+0x142c>
    3d48:	00003097          	auipc	ra,0x3
    3d4c:	aee080e7          	jalr	-1298(ra) # 6836 <chdir>
    3d50:	04054d63          	bltz	a0,3daa <dirtest+0x8a>
  if(chdir("..") < 0){
    3d54:	00004517          	auipc	a0,0x4
    3d58:	32450513          	addi	a0,a0,804 # 8078 <malloc+0x144c>
    3d5c:	00003097          	auipc	ra,0x3
    3d60:	ada080e7          	jalr	-1318(ra) # 6836 <chdir>
    3d64:	06054563          	bltz	a0,3dce <dirtest+0xae>
  if(unlink("dir0") < 0){
    3d68:	00004517          	auipc	a0,0x4
    3d6c:	2f050513          	addi	a0,a0,752 # 8058 <malloc+0x142c>
    3d70:	00003097          	auipc	ra,0x3
    3d74:	aa6080e7          	jalr	-1370(ra) # 6816 <unlink>
    3d78:	06054d63          	bltz	a0,3df2 <dirtest+0xd2>
}
    3d7c:	60e2                	ld	ra,24(sp)
    3d7e:	6442                	ld	s0,16(sp)
    3d80:	64a2                	ld	s1,8(sp)
    3d82:	6105                	addi	sp,sp,32
    3d84:	8082                	ret
    printf("%s: mkdir failed\n", s);
    3d86:	85a6                	mv	a1,s1
    3d88:	00004517          	auipc	a0,0x4
    3d8c:	23050513          	addi	a0,a0,560 # 7fb8 <malloc+0x138c>
    3d90:	00003097          	auipc	ra,0x3
    3d94:	dde080e7          	jalr	-546(ra) # 6b6e <printf>
    exit(1,"");
    3d98:	00004597          	auipc	a1,0x4
    3d9c:	5c058593          	addi	a1,a1,1472 # 8358 <malloc+0x172c>
    3da0:	4505                	li	a0,1
    3da2:	00003097          	auipc	ra,0x3
    3da6:	a24080e7          	jalr	-1500(ra) # 67c6 <exit>
    printf("%s: chdir dir0 failed\n", s);
    3daa:	85a6                	mv	a1,s1
    3dac:	00004517          	auipc	a0,0x4
    3db0:	2b450513          	addi	a0,a0,692 # 8060 <malloc+0x1434>
    3db4:	00003097          	auipc	ra,0x3
    3db8:	dba080e7          	jalr	-582(ra) # 6b6e <printf>
    exit(1,"");
    3dbc:	00004597          	auipc	a1,0x4
    3dc0:	59c58593          	addi	a1,a1,1436 # 8358 <malloc+0x172c>
    3dc4:	4505                	li	a0,1
    3dc6:	00003097          	auipc	ra,0x3
    3dca:	a00080e7          	jalr	-1536(ra) # 67c6 <exit>
    printf("%s: chdir .. failed\n", s);
    3dce:	85a6                	mv	a1,s1
    3dd0:	00004517          	auipc	a0,0x4
    3dd4:	2b050513          	addi	a0,a0,688 # 8080 <malloc+0x1454>
    3dd8:	00003097          	auipc	ra,0x3
    3ddc:	d96080e7          	jalr	-618(ra) # 6b6e <printf>
    exit(1,"");
    3de0:	00004597          	auipc	a1,0x4
    3de4:	57858593          	addi	a1,a1,1400 # 8358 <malloc+0x172c>
    3de8:	4505                	li	a0,1
    3dea:	00003097          	auipc	ra,0x3
    3dee:	9dc080e7          	jalr	-1572(ra) # 67c6 <exit>
    printf("%s: unlink dir0 failed\n", s);
    3df2:	85a6                	mv	a1,s1
    3df4:	00004517          	auipc	a0,0x4
    3df8:	2a450513          	addi	a0,a0,676 # 8098 <malloc+0x146c>
    3dfc:	00003097          	auipc	ra,0x3
    3e00:	d72080e7          	jalr	-654(ra) # 6b6e <printf>
    exit(1,"");
    3e04:	00004597          	auipc	a1,0x4
    3e08:	55458593          	addi	a1,a1,1364 # 8358 <malloc+0x172c>
    3e0c:	4505                	li	a0,1
    3e0e:	00003097          	auipc	ra,0x3
    3e12:	9b8080e7          	jalr	-1608(ra) # 67c6 <exit>

0000000000003e16 <subdir>:
{
    3e16:	1101                	addi	sp,sp,-32
    3e18:	ec06                	sd	ra,24(sp)
    3e1a:	e822                	sd	s0,16(sp)
    3e1c:	e426                	sd	s1,8(sp)
    3e1e:	e04a                	sd	s2,0(sp)
    3e20:	1000                	addi	s0,sp,32
    3e22:	892a                	mv	s2,a0
  unlink("ff");
    3e24:	00004517          	auipc	a0,0x4
    3e28:	3bc50513          	addi	a0,a0,956 # 81e0 <malloc+0x15b4>
    3e2c:	00003097          	auipc	ra,0x3
    3e30:	9ea080e7          	jalr	-1558(ra) # 6816 <unlink>
  if(mkdir("dd") != 0){
    3e34:	00004517          	auipc	a0,0x4
    3e38:	27c50513          	addi	a0,a0,636 # 80b0 <malloc+0x1484>
    3e3c:	00003097          	auipc	ra,0x3
    3e40:	9f2080e7          	jalr	-1550(ra) # 682e <mkdir>
    3e44:	38051663          	bnez	a0,41d0 <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    3e48:	20200593          	li	a1,514
    3e4c:	00004517          	auipc	a0,0x4
    3e50:	28450513          	addi	a0,a0,644 # 80d0 <malloc+0x14a4>
    3e54:	00003097          	auipc	ra,0x3
    3e58:	9b2080e7          	jalr	-1614(ra) # 6806 <open>
    3e5c:	84aa                	mv	s1,a0
  if(fd < 0){
    3e5e:	38054b63          	bltz	a0,41f4 <subdir+0x3de>
  write(fd, "ff", 2);
    3e62:	4609                	li	a2,2
    3e64:	00004597          	auipc	a1,0x4
    3e68:	37c58593          	addi	a1,a1,892 # 81e0 <malloc+0x15b4>
    3e6c:	00003097          	auipc	ra,0x3
    3e70:	97a080e7          	jalr	-1670(ra) # 67e6 <write>
  close(fd);
    3e74:	8526                	mv	a0,s1
    3e76:	00003097          	auipc	ra,0x3
    3e7a:	978080e7          	jalr	-1672(ra) # 67ee <close>
  if(unlink("dd") >= 0){
    3e7e:	00004517          	auipc	a0,0x4
    3e82:	23250513          	addi	a0,a0,562 # 80b0 <malloc+0x1484>
    3e86:	00003097          	auipc	ra,0x3
    3e8a:	990080e7          	jalr	-1648(ra) # 6816 <unlink>
    3e8e:	38055563          	bgez	a0,4218 <subdir+0x402>
  if(mkdir("/dd/dd") != 0){
    3e92:	00004517          	auipc	a0,0x4
    3e96:	29650513          	addi	a0,a0,662 # 8128 <malloc+0x14fc>
    3e9a:	00003097          	auipc	ra,0x3
    3e9e:	994080e7          	jalr	-1644(ra) # 682e <mkdir>
    3ea2:	38051d63          	bnez	a0,423c <subdir+0x426>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    3ea6:	20200593          	li	a1,514
    3eaa:	00004517          	auipc	a0,0x4
    3eae:	2a650513          	addi	a0,a0,678 # 8150 <malloc+0x1524>
    3eb2:	00003097          	auipc	ra,0x3
    3eb6:	954080e7          	jalr	-1708(ra) # 6806 <open>
    3eba:	84aa                	mv	s1,a0
  if(fd < 0){
    3ebc:	3a054263          	bltz	a0,4260 <subdir+0x44a>
  write(fd, "FF", 2);
    3ec0:	4609                	li	a2,2
    3ec2:	00004597          	auipc	a1,0x4
    3ec6:	2be58593          	addi	a1,a1,702 # 8180 <malloc+0x1554>
    3eca:	00003097          	auipc	ra,0x3
    3ece:	91c080e7          	jalr	-1764(ra) # 67e6 <write>
  close(fd);
    3ed2:	8526                	mv	a0,s1
    3ed4:	00003097          	auipc	ra,0x3
    3ed8:	91a080e7          	jalr	-1766(ra) # 67ee <close>
  fd = open("dd/dd/../ff", 0);
    3edc:	4581                	li	a1,0
    3ede:	00004517          	auipc	a0,0x4
    3ee2:	2aa50513          	addi	a0,a0,682 # 8188 <malloc+0x155c>
    3ee6:	00003097          	auipc	ra,0x3
    3eea:	920080e7          	jalr	-1760(ra) # 6806 <open>
    3eee:	84aa                	mv	s1,a0
  if(fd < 0){
    3ef0:	38054a63          	bltz	a0,4284 <subdir+0x46e>
  cc = read(fd, buf, sizeof(buf));
    3ef4:	660d                	lui	a2,0x3
    3ef6:	0000a597          	auipc	a1,0xa
    3efa:	d8258593          	addi	a1,a1,-638 # dc78 <buf>
    3efe:	00003097          	auipc	ra,0x3
    3f02:	8e0080e7          	jalr	-1824(ra) # 67de <read>
  if(cc != 2 || buf[0] != 'f'){
    3f06:	4789                	li	a5,2
    3f08:	3af51063          	bne	a0,a5,42a8 <subdir+0x492>
    3f0c:	0000a717          	auipc	a4,0xa
    3f10:	d6c74703          	lbu	a4,-660(a4) # dc78 <buf>
    3f14:	06600793          	li	a5,102
    3f18:	38f71863          	bne	a4,a5,42a8 <subdir+0x492>
  close(fd);
    3f1c:	8526                	mv	a0,s1
    3f1e:	00003097          	auipc	ra,0x3
    3f22:	8d0080e7          	jalr	-1840(ra) # 67ee <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    3f26:	00004597          	auipc	a1,0x4
    3f2a:	2b258593          	addi	a1,a1,690 # 81d8 <malloc+0x15ac>
    3f2e:	00004517          	auipc	a0,0x4
    3f32:	22250513          	addi	a0,a0,546 # 8150 <malloc+0x1524>
    3f36:	00003097          	auipc	ra,0x3
    3f3a:	8f0080e7          	jalr	-1808(ra) # 6826 <link>
    3f3e:	38051763          	bnez	a0,42cc <subdir+0x4b6>
  if(unlink("dd/dd/ff") != 0){
    3f42:	00004517          	auipc	a0,0x4
    3f46:	20e50513          	addi	a0,a0,526 # 8150 <malloc+0x1524>
    3f4a:	00003097          	auipc	ra,0x3
    3f4e:	8cc080e7          	jalr	-1844(ra) # 6816 <unlink>
    3f52:	38051f63          	bnez	a0,42f0 <subdir+0x4da>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    3f56:	4581                	li	a1,0
    3f58:	00004517          	auipc	a0,0x4
    3f5c:	1f850513          	addi	a0,a0,504 # 8150 <malloc+0x1524>
    3f60:	00003097          	auipc	ra,0x3
    3f64:	8a6080e7          	jalr	-1882(ra) # 6806 <open>
    3f68:	3a055663          	bgez	a0,4314 <subdir+0x4fe>
  if(chdir("dd") != 0){
    3f6c:	00004517          	auipc	a0,0x4
    3f70:	14450513          	addi	a0,a0,324 # 80b0 <malloc+0x1484>
    3f74:	00003097          	auipc	ra,0x3
    3f78:	8c2080e7          	jalr	-1854(ra) # 6836 <chdir>
    3f7c:	3a051e63          	bnez	a0,4338 <subdir+0x522>
  if(chdir("dd/../../dd") != 0){
    3f80:	00004517          	auipc	a0,0x4
    3f84:	2f050513          	addi	a0,a0,752 # 8270 <malloc+0x1644>
    3f88:	00003097          	auipc	ra,0x3
    3f8c:	8ae080e7          	jalr	-1874(ra) # 6836 <chdir>
    3f90:	3c051663          	bnez	a0,435c <subdir+0x546>
  if(chdir("dd/../../../dd") != 0){
    3f94:	00004517          	auipc	a0,0x4
    3f98:	30c50513          	addi	a0,a0,780 # 82a0 <malloc+0x1674>
    3f9c:	00003097          	auipc	ra,0x3
    3fa0:	89a080e7          	jalr	-1894(ra) # 6836 <chdir>
    3fa4:	3c051e63          	bnez	a0,4380 <subdir+0x56a>
  if(chdir("./..") != 0){
    3fa8:	00004517          	auipc	a0,0x4
    3fac:	32850513          	addi	a0,a0,808 # 82d0 <malloc+0x16a4>
    3fb0:	00003097          	auipc	ra,0x3
    3fb4:	886080e7          	jalr	-1914(ra) # 6836 <chdir>
    3fb8:	3e051663          	bnez	a0,43a4 <subdir+0x58e>
  fd = open("dd/dd/ffff", 0);
    3fbc:	4581                	li	a1,0
    3fbe:	00004517          	auipc	a0,0x4
    3fc2:	21a50513          	addi	a0,a0,538 # 81d8 <malloc+0x15ac>
    3fc6:	00003097          	auipc	ra,0x3
    3fca:	840080e7          	jalr	-1984(ra) # 6806 <open>
    3fce:	84aa                	mv	s1,a0
  if(fd < 0){
    3fd0:	3e054c63          	bltz	a0,43c8 <subdir+0x5b2>
  if(read(fd, buf, sizeof(buf)) != 2){
    3fd4:	660d                	lui	a2,0x3
    3fd6:	0000a597          	auipc	a1,0xa
    3fda:	ca258593          	addi	a1,a1,-862 # dc78 <buf>
    3fde:	00003097          	auipc	ra,0x3
    3fe2:	800080e7          	jalr	-2048(ra) # 67de <read>
    3fe6:	4789                	li	a5,2
    3fe8:	40f51263          	bne	a0,a5,43ec <subdir+0x5d6>
  close(fd);
    3fec:	8526                	mv	a0,s1
    3fee:	00003097          	auipc	ra,0x3
    3ff2:	800080e7          	jalr	-2048(ra) # 67ee <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    3ff6:	4581                	li	a1,0
    3ff8:	00004517          	auipc	a0,0x4
    3ffc:	15850513          	addi	a0,a0,344 # 8150 <malloc+0x1524>
    4000:	00003097          	auipc	ra,0x3
    4004:	806080e7          	jalr	-2042(ra) # 6806 <open>
    4008:	40055463          	bgez	a0,4410 <subdir+0x5fa>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    400c:	20200593          	li	a1,514
    4010:	00004517          	auipc	a0,0x4
    4014:	35050513          	addi	a0,a0,848 # 8360 <malloc+0x1734>
    4018:	00002097          	auipc	ra,0x2
    401c:	7ee080e7          	jalr	2030(ra) # 6806 <open>
    4020:	40055a63          	bgez	a0,4434 <subdir+0x61e>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    4024:	20200593          	li	a1,514
    4028:	00004517          	auipc	a0,0x4
    402c:	36850513          	addi	a0,a0,872 # 8390 <malloc+0x1764>
    4030:	00002097          	auipc	ra,0x2
    4034:	7d6080e7          	jalr	2006(ra) # 6806 <open>
    4038:	42055063          	bgez	a0,4458 <subdir+0x642>
  if(open("dd", O_CREATE) >= 0){
    403c:	20000593          	li	a1,512
    4040:	00004517          	auipc	a0,0x4
    4044:	07050513          	addi	a0,a0,112 # 80b0 <malloc+0x1484>
    4048:	00002097          	auipc	ra,0x2
    404c:	7be080e7          	jalr	1982(ra) # 6806 <open>
    4050:	42055663          	bgez	a0,447c <subdir+0x666>
  if(open("dd", O_RDWR) >= 0){
    4054:	4589                	li	a1,2
    4056:	00004517          	auipc	a0,0x4
    405a:	05a50513          	addi	a0,a0,90 # 80b0 <malloc+0x1484>
    405e:	00002097          	auipc	ra,0x2
    4062:	7a8080e7          	jalr	1960(ra) # 6806 <open>
    4066:	42055d63          	bgez	a0,44a0 <subdir+0x68a>
  if(open("dd", O_WRONLY) >= 0){
    406a:	4585                	li	a1,1
    406c:	00004517          	auipc	a0,0x4
    4070:	04450513          	addi	a0,a0,68 # 80b0 <malloc+0x1484>
    4074:	00002097          	auipc	ra,0x2
    4078:	792080e7          	jalr	1938(ra) # 6806 <open>
    407c:	44055463          	bgez	a0,44c4 <subdir+0x6ae>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    4080:	00004597          	auipc	a1,0x4
    4084:	3a058593          	addi	a1,a1,928 # 8420 <malloc+0x17f4>
    4088:	00004517          	auipc	a0,0x4
    408c:	2d850513          	addi	a0,a0,728 # 8360 <malloc+0x1734>
    4090:	00002097          	auipc	ra,0x2
    4094:	796080e7          	jalr	1942(ra) # 6826 <link>
    4098:	44050863          	beqz	a0,44e8 <subdir+0x6d2>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    409c:	00004597          	auipc	a1,0x4
    40a0:	38458593          	addi	a1,a1,900 # 8420 <malloc+0x17f4>
    40a4:	00004517          	auipc	a0,0x4
    40a8:	2ec50513          	addi	a0,a0,748 # 8390 <malloc+0x1764>
    40ac:	00002097          	auipc	ra,0x2
    40b0:	77a080e7          	jalr	1914(ra) # 6826 <link>
    40b4:	44050c63          	beqz	a0,450c <subdir+0x6f6>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    40b8:	00004597          	auipc	a1,0x4
    40bc:	12058593          	addi	a1,a1,288 # 81d8 <malloc+0x15ac>
    40c0:	00004517          	auipc	a0,0x4
    40c4:	01050513          	addi	a0,a0,16 # 80d0 <malloc+0x14a4>
    40c8:	00002097          	auipc	ra,0x2
    40cc:	75e080e7          	jalr	1886(ra) # 6826 <link>
    40d0:	46050063          	beqz	a0,4530 <subdir+0x71a>
  if(mkdir("dd/ff/ff") == 0){
    40d4:	00004517          	auipc	a0,0x4
    40d8:	28c50513          	addi	a0,a0,652 # 8360 <malloc+0x1734>
    40dc:	00002097          	auipc	ra,0x2
    40e0:	752080e7          	jalr	1874(ra) # 682e <mkdir>
    40e4:	46050863          	beqz	a0,4554 <subdir+0x73e>
  if(mkdir("dd/xx/ff") == 0){
    40e8:	00004517          	auipc	a0,0x4
    40ec:	2a850513          	addi	a0,a0,680 # 8390 <malloc+0x1764>
    40f0:	00002097          	auipc	ra,0x2
    40f4:	73e080e7          	jalr	1854(ra) # 682e <mkdir>
    40f8:	48050063          	beqz	a0,4578 <subdir+0x762>
  if(mkdir("dd/dd/ffff") == 0){
    40fc:	00004517          	auipc	a0,0x4
    4100:	0dc50513          	addi	a0,a0,220 # 81d8 <malloc+0x15ac>
    4104:	00002097          	auipc	ra,0x2
    4108:	72a080e7          	jalr	1834(ra) # 682e <mkdir>
    410c:	48050863          	beqz	a0,459c <subdir+0x786>
  if(unlink("dd/xx/ff") == 0){
    4110:	00004517          	auipc	a0,0x4
    4114:	28050513          	addi	a0,a0,640 # 8390 <malloc+0x1764>
    4118:	00002097          	auipc	ra,0x2
    411c:	6fe080e7          	jalr	1790(ra) # 6816 <unlink>
    4120:	4a050063          	beqz	a0,45c0 <subdir+0x7aa>
  if(unlink("dd/ff/ff") == 0){
    4124:	00004517          	auipc	a0,0x4
    4128:	23c50513          	addi	a0,a0,572 # 8360 <malloc+0x1734>
    412c:	00002097          	auipc	ra,0x2
    4130:	6ea080e7          	jalr	1770(ra) # 6816 <unlink>
    4134:	4a050863          	beqz	a0,45e4 <subdir+0x7ce>
  if(chdir("dd/ff") == 0){
    4138:	00004517          	auipc	a0,0x4
    413c:	f9850513          	addi	a0,a0,-104 # 80d0 <malloc+0x14a4>
    4140:	00002097          	auipc	ra,0x2
    4144:	6f6080e7          	jalr	1782(ra) # 6836 <chdir>
    4148:	4c050063          	beqz	a0,4608 <subdir+0x7f2>
  if(chdir("dd/xx") == 0){
    414c:	00004517          	auipc	a0,0x4
    4150:	42450513          	addi	a0,a0,1060 # 8570 <malloc+0x1944>
    4154:	00002097          	auipc	ra,0x2
    4158:	6e2080e7          	jalr	1762(ra) # 6836 <chdir>
    415c:	4c050863          	beqz	a0,462c <subdir+0x816>
  if(unlink("dd/dd/ffff") != 0){
    4160:	00004517          	auipc	a0,0x4
    4164:	07850513          	addi	a0,a0,120 # 81d8 <malloc+0x15ac>
    4168:	00002097          	auipc	ra,0x2
    416c:	6ae080e7          	jalr	1710(ra) # 6816 <unlink>
    4170:	4e051063          	bnez	a0,4650 <subdir+0x83a>
  if(unlink("dd/ff") != 0){
    4174:	00004517          	auipc	a0,0x4
    4178:	f5c50513          	addi	a0,a0,-164 # 80d0 <malloc+0x14a4>
    417c:	00002097          	auipc	ra,0x2
    4180:	69a080e7          	jalr	1690(ra) # 6816 <unlink>
    4184:	4e051863          	bnez	a0,4674 <subdir+0x85e>
  if(unlink("dd") == 0){
    4188:	00004517          	auipc	a0,0x4
    418c:	f2850513          	addi	a0,a0,-216 # 80b0 <malloc+0x1484>
    4190:	00002097          	auipc	ra,0x2
    4194:	686080e7          	jalr	1670(ra) # 6816 <unlink>
    4198:	50050063          	beqz	a0,4698 <subdir+0x882>
  if(unlink("dd/dd") < 0){
    419c:	00004517          	auipc	a0,0x4
    41a0:	44450513          	addi	a0,a0,1092 # 85e0 <malloc+0x19b4>
    41a4:	00002097          	auipc	ra,0x2
    41a8:	672080e7          	jalr	1650(ra) # 6816 <unlink>
    41ac:	50054863          	bltz	a0,46bc <subdir+0x8a6>
  if(unlink("dd") < 0){
    41b0:	00004517          	auipc	a0,0x4
    41b4:	f0050513          	addi	a0,a0,-256 # 80b0 <malloc+0x1484>
    41b8:	00002097          	auipc	ra,0x2
    41bc:	65e080e7          	jalr	1630(ra) # 6816 <unlink>
    41c0:	52054063          	bltz	a0,46e0 <subdir+0x8ca>
}
    41c4:	60e2                	ld	ra,24(sp)
    41c6:	6442                	ld	s0,16(sp)
    41c8:	64a2                	ld	s1,8(sp)
    41ca:	6902                	ld	s2,0(sp)
    41cc:	6105                	addi	sp,sp,32
    41ce:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    41d0:	85ca                	mv	a1,s2
    41d2:	00004517          	auipc	a0,0x4
    41d6:	ee650513          	addi	a0,a0,-282 # 80b8 <malloc+0x148c>
    41da:	00003097          	auipc	ra,0x3
    41de:	994080e7          	jalr	-1644(ra) # 6b6e <printf>
    exit(1,"");
    41e2:	00004597          	auipc	a1,0x4
    41e6:	17658593          	addi	a1,a1,374 # 8358 <malloc+0x172c>
    41ea:	4505                	li	a0,1
    41ec:	00002097          	auipc	ra,0x2
    41f0:	5da080e7          	jalr	1498(ra) # 67c6 <exit>
    printf("%s: create dd/ff failed\n", s);
    41f4:	85ca                	mv	a1,s2
    41f6:	00004517          	auipc	a0,0x4
    41fa:	ee250513          	addi	a0,a0,-286 # 80d8 <malloc+0x14ac>
    41fe:	00003097          	auipc	ra,0x3
    4202:	970080e7          	jalr	-1680(ra) # 6b6e <printf>
    exit(1,"");
    4206:	00004597          	auipc	a1,0x4
    420a:	15258593          	addi	a1,a1,338 # 8358 <malloc+0x172c>
    420e:	4505                	li	a0,1
    4210:	00002097          	auipc	ra,0x2
    4214:	5b6080e7          	jalr	1462(ra) # 67c6 <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    4218:	85ca                	mv	a1,s2
    421a:	00004517          	auipc	a0,0x4
    421e:	ede50513          	addi	a0,a0,-290 # 80f8 <malloc+0x14cc>
    4222:	00003097          	auipc	ra,0x3
    4226:	94c080e7          	jalr	-1716(ra) # 6b6e <printf>
    exit(1,"");
    422a:	00004597          	auipc	a1,0x4
    422e:	12e58593          	addi	a1,a1,302 # 8358 <malloc+0x172c>
    4232:	4505                	li	a0,1
    4234:	00002097          	auipc	ra,0x2
    4238:	592080e7          	jalr	1426(ra) # 67c6 <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    423c:	85ca                	mv	a1,s2
    423e:	00004517          	auipc	a0,0x4
    4242:	ef250513          	addi	a0,a0,-270 # 8130 <malloc+0x1504>
    4246:	00003097          	auipc	ra,0x3
    424a:	928080e7          	jalr	-1752(ra) # 6b6e <printf>
    exit(1,"");
    424e:	00004597          	auipc	a1,0x4
    4252:	10a58593          	addi	a1,a1,266 # 8358 <malloc+0x172c>
    4256:	4505                	li	a0,1
    4258:	00002097          	auipc	ra,0x2
    425c:	56e080e7          	jalr	1390(ra) # 67c6 <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    4260:	85ca                	mv	a1,s2
    4262:	00004517          	auipc	a0,0x4
    4266:	efe50513          	addi	a0,a0,-258 # 8160 <malloc+0x1534>
    426a:	00003097          	auipc	ra,0x3
    426e:	904080e7          	jalr	-1788(ra) # 6b6e <printf>
    exit(1,"");
    4272:	00004597          	auipc	a1,0x4
    4276:	0e658593          	addi	a1,a1,230 # 8358 <malloc+0x172c>
    427a:	4505                	li	a0,1
    427c:	00002097          	auipc	ra,0x2
    4280:	54a080e7          	jalr	1354(ra) # 67c6 <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    4284:	85ca                	mv	a1,s2
    4286:	00004517          	auipc	a0,0x4
    428a:	f1250513          	addi	a0,a0,-238 # 8198 <malloc+0x156c>
    428e:	00003097          	auipc	ra,0x3
    4292:	8e0080e7          	jalr	-1824(ra) # 6b6e <printf>
    exit(1,"");
    4296:	00004597          	auipc	a1,0x4
    429a:	0c258593          	addi	a1,a1,194 # 8358 <malloc+0x172c>
    429e:	4505                	li	a0,1
    42a0:	00002097          	auipc	ra,0x2
    42a4:	526080e7          	jalr	1318(ra) # 67c6 <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    42a8:	85ca                	mv	a1,s2
    42aa:	00004517          	auipc	a0,0x4
    42ae:	f0e50513          	addi	a0,a0,-242 # 81b8 <malloc+0x158c>
    42b2:	00003097          	auipc	ra,0x3
    42b6:	8bc080e7          	jalr	-1860(ra) # 6b6e <printf>
    exit(1,"");
    42ba:	00004597          	auipc	a1,0x4
    42be:	09e58593          	addi	a1,a1,158 # 8358 <malloc+0x172c>
    42c2:	4505                	li	a0,1
    42c4:	00002097          	auipc	ra,0x2
    42c8:	502080e7          	jalr	1282(ra) # 67c6 <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    42cc:	85ca                	mv	a1,s2
    42ce:	00004517          	auipc	a0,0x4
    42d2:	f1a50513          	addi	a0,a0,-230 # 81e8 <malloc+0x15bc>
    42d6:	00003097          	auipc	ra,0x3
    42da:	898080e7          	jalr	-1896(ra) # 6b6e <printf>
    exit(1,"");
    42de:	00004597          	auipc	a1,0x4
    42e2:	07a58593          	addi	a1,a1,122 # 8358 <malloc+0x172c>
    42e6:	4505                	li	a0,1
    42e8:	00002097          	auipc	ra,0x2
    42ec:	4de080e7          	jalr	1246(ra) # 67c6 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    42f0:	85ca                	mv	a1,s2
    42f2:	00004517          	auipc	a0,0x4
    42f6:	f1e50513          	addi	a0,a0,-226 # 8210 <malloc+0x15e4>
    42fa:	00003097          	auipc	ra,0x3
    42fe:	874080e7          	jalr	-1932(ra) # 6b6e <printf>
    exit(1,"");
    4302:	00004597          	auipc	a1,0x4
    4306:	05658593          	addi	a1,a1,86 # 8358 <malloc+0x172c>
    430a:	4505                	li	a0,1
    430c:	00002097          	auipc	ra,0x2
    4310:	4ba080e7          	jalr	1210(ra) # 67c6 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    4314:	85ca                	mv	a1,s2
    4316:	00004517          	auipc	a0,0x4
    431a:	f1a50513          	addi	a0,a0,-230 # 8230 <malloc+0x1604>
    431e:	00003097          	auipc	ra,0x3
    4322:	850080e7          	jalr	-1968(ra) # 6b6e <printf>
    exit(1,"");
    4326:	00004597          	auipc	a1,0x4
    432a:	03258593          	addi	a1,a1,50 # 8358 <malloc+0x172c>
    432e:	4505                	li	a0,1
    4330:	00002097          	auipc	ra,0x2
    4334:	496080e7          	jalr	1174(ra) # 67c6 <exit>
    printf("%s: chdir dd failed\n", s);
    4338:	85ca                	mv	a1,s2
    433a:	00004517          	auipc	a0,0x4
    433e:	f1e50513          	addi	a0,a0,-226 # 8258 <malloc+0x162c>
    4342:	00003097          	auipc	ra,0x3
    4346:	82c080e7          	jalr	-2004(ra) # 6b6e <printf>
    exit(1,"");
    434a:	00004597          	auipc	a1,0x4
    434e:	00e58593          	addi	a1,a1,14 # 8358 <malloc+0x172c>
    4352:	4505                	li	a0,1
    4354:	00002097          	auipc	ra,0x2
    4358:	472080e7          	jalr	1138(ra) # 67c6 <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    435c:	85ca                	mv	a1,s2
    435e:	00004517          	auipc	a0,0x4
    4362:	f2250513          	addi	a0,a0,-222 # 8280 <malloc+0x1654>
    4366:	00003097          	auipc	ra,0x3
    436a:	808080e7          	jalr	-2040(ra) # 6b6e <printf>
    exit(1,"");
    436e:	00004597          	auipc	a1,0x4
    4372:	fea58593          	addi	a1,a1,-22 # 8358 <malloc+0x172c>
    4376:	4505                	li	a0,1
    4378:	00002097          	auipc	ra,0x2
    437c:	44e080e7          	jalr	1102(ra) # 67c6 <exit>
    printf("chdir dd/../../dd failed\n", s);
    4380:	85ca                	mv	a1,s2
    4382:	00004517          	auipc	a0,0x4
    4386:	f2e50513          	addi	a0,a0,-210 # 82b0 <malloc+0x1684>
    438a:	00002097          	auipc	ra,0x2
    438e:	7e4080e7          	jalr	2020(ra) # 6b6e <printf>
    exit(1,"");
    4392:	00004597          	auipc	a1,0x4
    4396:	fc658593          	addi	a1,a1,-58 # 8358 <malloc+0x172c>
    439a:	4505                	li	a0,1
    439c:	00002097          	auipc	ra,0x2
    43a0:	42a080e7          	jalr	1066(ra) # 67c6 <exit>
    printf("%s: chdir ./.. failed\n", s);
    43a4:	85ca                	mv	a1,s2
    43a6:	00004517          	auipc	a0,0x4
    43aa:	f3250513          	addi	a0,a0,-206 # 82d8 <malloc+0x16ac>
    43ae:	00002097          	auipc	ra,0x2
    43b2:	7c0080e7          	jalr	1984(ra) # 6b6e <printf>
    exit(1,"");
    43b6:	00004597          	auipc	a1,0x4
    43ba:	fa258593          	addi	a1,a1,-94 # 8358 <malloc+0x172c>
    43be:	4505                	li	a0,1
    43c0:	00002097          	auipc	ra,0x2
    43c4:	406080e7          	jalr	1030(ra) # 67c6 <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    43c8:	85ca                	mv	a1,s2
    43ca:	00004517          	auipc	a0,0x4
    43ce:	f2650513          	addi	a0,a0,-218 # 82f0 <malloc+0x16c4>
    43d2:	00002097          	auipc	ra,0x2
    43d6:	79c080e7          	jalr	1948(ra) # 6b6e <printf>
    exit(1,"");
    43da:	00004597          	auipc	a1,0x4
    43de:	f7e58593          	addi	a1,a1,-130 # 8358 <malloc+0x172c>
    43e2:	4505                	li	a0,1
    43e4:	00002097          	auipc	ra,0x2
    43e8:	3e2080e7          	jalr	994(ra) # 67c6 <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    43ec:	85ca                	mv	a1,s2
    43ee:	00004517          	auipc	a0,0x4
    43f2:	f2250513          	addi	a0,a0,-222 # 8310 <malloc+0x16e4>
    43f6:	00002097          	auipc	ra,0x2
    43fa:	778080e7          	jalr	1912(ra) # 6b6e <printf>
    exit(1,"");
    43fe:	00004597          	auipc	a1,0x4
    4402:	f5a58593          	addi	a1,a1,-166 # 8358 <malloc+0x172c>
    4406:	4505                	li	a0,1
    4408:	00002097          	auipc	ra,0x2
    440c:	3be080e7          	jalr	958(ra) # 67c6 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    4410:	85ca                	mv	a1,s2
    4412:	00004517          	auipc	a0,0x4
    4416:	f1e50513          	addi	a0,a0,-226 # 8330 <malloc+0x1704>
    441a:	00002097          	auipc	ra,0x2
    441e:	754080e7          	jalr	1876(ra) # 6b6e <printf>
    exit(1,"");
    4422:	00004597          	auipc	a1,0x4
    4426:	f3658593          	addi	a1,a1,-202 # 8358 <malloc+0x172c>
    442a:	4505                	li	a0,1
    442c:	00002097          	auipc	ra,0x2
    4430:	39a080e7          	jalr	922(ra) # 67c6 <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    4434:	85ca                	mv	a1,s2
    4436:	00004517          	auipc	a0,0x4
    443a:	f3a50513          	addi	a0,a0,-198 # 8370 <malloc+0x1744>
    443e:	00002097          	auipc	ra,0x2
    4442:	730080e7          	jalr	1840(ra) # 6b6e <printf>
    exit(1,"");
    4446:	00004597          	auipc	a1,0x4
    444a:	f1258593          	addi	a1,a1,-238 # 8358 <malloc+0x172c>
    444e:	4505                	li	a0,1
    4450:	00002097          	auipc	ra,0x2
    4454:	376080e7          	jalr	886(ra) # 67c6 <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    4458:	85ca                	mv	a1,s2
    445a:	00004517          	auipc	a0,0x4
    445e:	f4650513          	addi	a0,a0,-186 # 83a0 <malloc+0x1774>
    4462:	00002097          	auipc	ra,0x2
    4466:	70c080e7          	jalr	1804(ra) # 6b6e <printf>
    exit(1,"");
    446a:	00004597          	auipc	a1,0x4
    446e:	eee58593          	addi	a1,a1,-274 # 8358 <malloc+0x172c>
    4472:	4505                	li	a0,1
    4474:	00002097          	auipc	ra,0x2
    4478:	352080e7          	jalr	850(ra) # 67c6 <exit>
    printf("%s: create dd succeeded!\n", s);
    447c:	85ca                	mv	a1,s2
    447e:	00004517          	auipc	a0,0x4
    4482:	f4250513          	addi	a0,a0,-190 # 83c0 <malloc+0x1794>
    4486:	00002097          	auipc	ra,0x2
    448a:	6e8080e7          	jalr	1768(ra) # 6b6e <printf>
    exit(1,"");
    448e:	00004597          	auipc	a1,0x4
    4492:	eca58593          	addi	a1,a1,-310 # 8358 <malloc+0x172c>
    4496:	4505                	li	a0,1
    4498:	00002097          	auipc	ra,0x2
    449c:	32e080e7          	jalr	814(ra) # 67c6 <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    44a0:	85ca                	mv	a1,s2
    44a2:	00004517          	auipc	a0,0x4
    44a6:	f3e50513          	addi	a0,a0,-194 # 83e0 <malloc+0x17b4>
    44aa:	00002097          	auipc	ra,0x2
    44ae:	6c4080e7          	jalr	1732(ra) # 6b6e <printf>
    exit(1,"");
    44b2:	00004597          	auipc	a1,0x4
    44b6:	ea658593          	addi	a1,a1,-346 # 8358 <malloc+0x172c>
    44ba:	4505                	li	a0,1
    44bc:	00002097          	auipc	ra,0x2
    44c0:	30a080e7          	jalr	778(ra) # 67c6 <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    44c4:	85ca                	mv	a1,s2
    44c6:	00004517          	auipc	a0,0x4
    44ca:	f3a50513          	addi	a0,a0,-198 # 8400 <malloc+0x17d4>
    44ce:	00002097          	auipc	ra,0x2
    44d2:	6a0080e7          	jalr	1696(ra) # 6b6e <printf>
    exit(1,"");
    44d6:	00004597          	auipc	a1,0x4
    44da:	e8258593          	addi	a1,a1,-382 # 8358 <malloc+0x172c>
    44de:	4505                	li	a0,1
    44e0:	00002097          	auipc	ra,0x2
    44e4:	2e6080e7          	jalr	742(ra) # 67c6 <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    44e8:	85ca                	mv	a1,s2
    44ea:	00004517          	auipc	a0,0x4
    44ee:	f4650513          	addi	a0,a0,-186 # 8430 <malloc+0x1804>
    44f2:	00002097          	auipc	ra,0x2
    44f6:	67c080e7          	jalr	1660(ra) # 6b6e <printf>
    exit(1,"");
    44fa:	00004597          	auipc	a1,0x4
    44fe:	e5e58593          	addi	a1,a1,-418 # 8358 <malloc+0x172c>
    4502:	4505                	li	a0,1
    4504:	00002097          	auipc	ra,0x2
    4508:	2c2080e7          	jalr	706(ra) # 67c6 <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    450c:	85ca                	mv	a1,s2
    450e:	00004517          	auipc	a0,0x4
    4512:	f4a50513          	addi	a0,a0,-182 # 8458 <malloc+0x182c>
    4516:	00002097          	auipc	ra,0x2
    451a:	658080e7          	jalr	1624(ra) # 6b6e <printf>
    exit(1,"");
    451e:	00004597          	auipc	a1,0x4
    4522:	e3a58593          	addi	a1,a1,-454 # 8358 <malloc+0x172c>
    4526:	4505                	li	a0,1
    4528:	00002097          	auipc	ra,0x2
    452c:	29e080e7          	jalr	670(ra) # 67c6 <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    4530:	85ca                	mv	a1,s2
    4532:	00004517          	auipc	a0,0x4
    4536:	f4e50513          	addi	a0,a0,-178 # 8480 <malloc+0x1854>
    453a:	00002097          	auipc	ra,0x2
    453e:	634080e7          	jalr	1588(ra) # 6b6e <printf>
    exit(1,"");
    4542:	00004597          	auipc	a1,0x4
    4546:	e1658593          	addi	a1,a1,-490 # 8358 <malloc+0x172c>
    454a:	4505                	li	a0,1
    454c:	00002097          	auipc	ra,0x2
    4550:	27a080e7          	jalr	634(ra) # 67c6 <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    4554:	85ca                	mv	a1,s2
    4556:	00004517          	auipc	a0,0x4
    455a:	f5250513          	addi	a0,a0,-174 # 84a8 <malloc+0x187c>
    455e:	00002097          	auipc	ra,0x2
    4562:	610080e7          	jalr	1552(ra) # 6b6e <printf>
    exit(1,"");
    4566:	00004597          	auipc	a1,0x4
    456a:	df258593          	addi	a1,a1,-526 # 8358 <malloc+0x172c>
    456e:	4505                	li	a0,1
    4570:	00002097          	auipc	ra,0x2
    4574:	256080e7          	jalr	598(ra) # 67c6 <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    4578:	85ca                	mv	a1,s2
    457a:	00004517          	auipc	a0,0x4
    457e:	f4e50513          	addi	a0,a0,-178 # 84c8 <malloc+0x189c>
    4582:	00002097          	auipc	ra,0x2
    4586:	5ec080e7          	jalr	1516(ra) # 6b6e <printf>
    exit(1,"");
    458a:	00004597          	auipc	a1,0x4
    458e:	dce58593          	addi	a1,a1,-562 # 8358 <malloc+0x172c>
    4592:	4505                	li	a0,1
    4594:	00002097          	auipc	ra,0x2
    4598:	232080e7          	jalr	562(ra) # 67c6 <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    459c:	85ca                	mv	a1,s2
    459e:	00004517          	auipc	a0,0x4
    45a2:	f4a50513          	addi	a0,a0,-182 # 84e8 <malloc+0x18bc>
    45a6:	00002097          	auipc	ra,0x2
    45aa:	5c8080e7          	jalr	1480(ra) # 6b6e <printf>
    exit(1,"");
    45ae:	00004597          	auipc	a1,0x4
    45b2:	daa58593          	addi	a1,a1,-598 # 8358 <malloc+0x172c>
    45b6:	4505                	li	a0,1
    45b8:	00002097          	auipc	ra,0x2
    45bc:	20e080e7          	jalr	526(ra) # 67c6 <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    45c0:	85ca                	mv	a1,s2
    45c2:	00004517          	auipc	a0,0x4
    45c6:	f4e50513          	addi	a0,a0,-178 # 8510 <malloc+0x18e4>
    45ca:	00002097          	auipc	ra,0x2
    45ce:	5a4080e7          	jalr	1444(ra) # 6b6e <printf>
    exit(1,"");
    45d2:	00004597          	auipc	a1,0x4
    45d6:	d8658593          	addi	a1,a1,-634 # 8358 <malloc+0x172c>
    45da:	4505                	li	a0,1
    45dc:	00002097          	auipc	ra,0x2
    45e0:	1ea080e7          	jalr	490(ra) # 67c6 <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    45e4:	85ca                	mv	a1,s2
    45e6:	00004517          	auipc	a0,0x4
    45ea:	f4a50513          	addi	a0,a0,-182 # 8530 <malloc+0x1904>
    45ee:	00002097          	auipc	ra,0x2
    45f2:	580080e7          	jalr	1408(ra) # 6b6e <printf>
    exit(1,"");
    45f6:	00004597          	auipc	a1,0x4
    45fa:	d6258593          	addi	a1,a1,-670 # 8358 <malloc+0x172c>
    45fe:	4505                	li	a0,1
    4600:	00002097          	auipc	ra,0x2
    4604:	1c6080e7          	jalr	454(ra) # 67c6 <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    4608:	85ca                	mv	a1,s2
    460a:	00004517          	auipc	a0,0x4
    460e:	f4650513          	addi	a0,a0,-186 # 8550 <malloc+0x1924>
    4612:	00002097          	auipc	ra,0x2
    4616:	55c080e7          	jalr	1372(ra) # 6b6e <printf>
    exit(1,"");
    461a:	00004597          	auipc	a1,0x4
    461e:	d3e58593          	addi	a1,a1,-706 # 8358 <malloc+0x172c>
    4622:	4505                	li	a0,1
    4624:	00002097          	auipc	ra,0x2
    4628:	1a2080e7          	jalr	418(ra) # 67c6 <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    462c:	85ca                	mv	a1,s2
    462e:	00004517          	auipc	a0,0x4
    4632:	f4a50513          	addi	a0,a0,-182 # 8578 <malloc+0x194c>
    4636:	00002097          	auipc	ra,0x2
    463a:	538080e7          	jalr	1336(ra) # 6b6e <printf>
    exit(1,"");
    463e:	00004597          	auipc	a1,0x4
    4642:	d1a58593          	addi	a1,a1,-742 # 8358 <malloc+0x172c>
    4646:	4505                	li	a0,1
    4648:	00002097          	auipc	ra,0x2
    464c:	17e080e7          	jalr	382(ra) # 67c6 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    4650:	85ca                	mv	a1,s2
    4652:	00004517          	auipc	a0,0x4
    4656:	bbe50513          	addi	a0,a0,-1090 # 8210 <malloc+0x15e4>
    465a:	00002097          	auipc	ra,0x2
    465e:	514080e7          	jalr	1300(ra) # 6b6e <printf>
    exit(1,"");
    4662:	00004597          	auipc	a1,0x4
    4666:	cf658593          	addi	a1,a1,-778 # 8358 <malloc+0x172c>
    466a:	4505                	li	a0,1
    466c:	00002097          	auipc	ra,0x2
    4670:	15a080e7          	jalr	346(ra) # 67c6 <exit>
    printf("%s: unlink dd/ff failed\n", s);
    4674:	85ca                	mv	a1,s2
    4676:	00004517          	auipc	a0,0x4
    467a:	f2250513          	addi	a0,a0,-222 # 8598 <malloc+0x196c>
    467e:	00002097          	auipc	ra,0x2
    4682:	4f0080e7          	jalr	1264(ra) # 6b6e <printf>
    exit(1,"");
    4686:	00004597          	auipc	a1,0x4
    468a:	cd258593          	addi	a1,a1,-814 # 8358 <malloc+0x172c>
    468e:	4505                	li	a0,1
    4690:	00002097          	auipc	ra,0x2
    4694:	136080e7          	jalr	310(ra) # 67c6 <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    4698:	85ca                	mv	a1,s2
    469a:	00004517          	auipc	a0,0x4
    469e:	f1e50513          	addi	a0,a0,-226 # 85b8 <malloc+0x198c>
    46a2:	00002097          	auipc	ra,0x2
    46a6:	4cc080e7          	jalr	1228(ra) # 6b6e <printf>
    exit(1,"");
    46aa:	00004597          	auipc	a1,0x4
    46ae:	cae58593          	addi	a1,a1,-850 # 8358 <malloc+0x172c>
    46b2:	4505                	li	a0,1
    46b4:	00002097          	auipc	ra,0x2
    46b8:	112080e7          	jalr	274(ra) # 67c6 <exit>
    printf("%s: unlink dd/dd failed\n", s);
    46bc:	85ca                	mv	a1,s2
    46be:	00004517          	auipc	a0,0x4
    46c2:	f2a50513          	addi	a0,a0,-214 # 85e8 <malloc+0x19bc>
    46c6:	00002097          	auipc	ra,0x2
    46ca:	4a8080e7          	jalr	1192(ra) # 6b6e <printf>
    exit(1,"");
    46ce:	00004597          	auipc	a1,0x4
    46d2:	c8a58593          	addi	a1,a1,-886 # 8358 <malloc+0x172c>
    46d6:	4505                	li	a0,1
    46d8:	00002097          	auipc	ra,0x2
    46dc:	0ee080e7          	jalr	238(ra) # 67c6 <exit>
    printf("%s: unlink dd failed\n", s);
    46e0:	85ca                	mv	a1,s2
    46e2:	00004517          	auipc	a0,0x4
    46e6:	f2650513          	addi	a0,a0,-218 # 8608 <malloc+0x19dc>
    46ea:	00002097          	auipc	ra,0x2
    46ee:	484080e7          	jalr	1156(ra) # 6b6e <printf>
    exit(1,"");
    46f2:	00004597          	auipc	a1,0x4
    46f6:	c6658593          	addi	a1,a1,-922 # 8358 <malloc+0x172c>
    46fa:	4505                	li	a0,1
    46fc:	00002097          	auipc	ra,0x2
    4700:	0ca080e7          	jalr	202(ra) # 67c6 <exit>

0000000000004704 <rmdot>:
{
    4704:	1101                	addi	sp,sp,-32
    4706:	ec06                	sd	ra,24(sp)
    4708:	e822                	sd	s0,16(sp)
    470a:	e426                	sd	s1,8(sp)
    470c:	1000                	addi	s0,sp,32
    470e:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    4710:	00004517          	auipc	a0,0x4
    4714:	f1050513          	addi	a0,a0,-240 # 8620 <malloc+0x19f4>
    4718:	00002097          	auipc	ra,0x2
    471c:	116080e7          	jalr	278(ra) # 682e <mkdir>
    4720:	e551                	bnez	a0,47ac <rmdot+0xa8>
  if(chdir("dots") != 0){
    4722:	00004517          	auipc	a0,0x4
    4726:	efe50513          	addi	a0,a0,-258 # 8620 <malloc+0x19f4>
    472a:	00002097          	auipc	ra,0x2
    472e:	10c080e7          	jalr	268(ra) # 6836 <chdir>
    4732:	ed59                	bnez	a0,47d0 <rmdot+0xcc>
  if(unlink(".") == 0){
    4734:	00003517          	auipc	a0,0x3
    4738:	d1c50513          	addi	a0,a0,-740 # 7450 <malloc+0x824>
    473c:	00002097          	auipc	ra,0x2
    4740:	0da080e7          	jalr	218(ra) # 6816 <unlink>
    4744:	c945                	beqz	a0,47f4 <rmdot+0xf0>
  if(unlink("..") == 0){
    4746:	00004517          	auipc	a0,0x4
    474a:	93250513          	addi	a0,a0,-1742 # 8078 <malloc+0x144c>
    474e:	00002097          	auipc	ra,0x2
    4752:	0c8080e7          	jalr	200(ra) # 6816 <unlink>
    4756:	c169                	beqz	a0,4818 <rmdot+0x114>
  if(chdir("/") != 0){
    4758:	00004517          	auipc	a0,0x4
    475c:	8c850513          	addi	a0,a0,-1848 # 8020 <malloc+0x13f4>
    4760:	00002097          	auipc	ra,0x2
    4764:	0d6080e7          	jalr	214(ra) # 6836 <chdir>
    4768:	e971                	bnez	a0,483c <rmdot+0x138>
  if(unlink("dots/.") == 0){
    476a:	00004517          	auipc	a0,0x4
    476e:	f1e50513          	addi	a0,a0,-226 # 8688 <malloc+0x1a5c>
    4772:	00002097          	auipc	ra,0x2
    4776:	0a4080e7          	jalr	164(ra) # 6816 <unlink>
    477a:	c17d                	beqz	a0,4860 <rmdot+0x15c>
  if(unlink("dots/..") == 0){
    477c:	00004517          	auipc	a0,0x4
    4780:	f3450513          	addi	a0,a0,-204 # 86b0 <malloc+0x1a84>
    4784:	00002097          	auipc	ra,0x2
    4788:	092080e7          	jalr	146(ra) # 6816 <unlink>
    478c:	cd65                	beqz	a0,4884 <rmdot+0x180>
  if(unlink("dots") != 0){
    478e:	00004517          	auipc	a0,0x4
    4792:	e9250513          	addi	a0,a0,-366 # 8620 <malloc+0x19f4>
    4796:	00002097          	auipc	ra,0x2
    479a:	080080e7          	jalr	128(ra) # 6816 <unlink>
    479e:	10051563          	bnez	a0,48a8 <rmdot+0x1a4>
}
    47a2:	60e2                	ld	ra,24(sp)
    47a4:	6442                	ld	s0,16(sp)
    47a6:	64a2                	ld	s1,8(sp)
    47a8:	6105                	addi	sp,sp,32
    47aa:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    47ac:	85a6                	mv	a1,s1
    47ae:	00004517          	auipc	a0,0x4
    47b2:	e7a50513          	addi	a0,a0,-390 # 8628 <malloc+0x19fc>
    47b6:	00002097          	auipc	ra,0x2
    47ba:	3b8080e7          	jalr	952(ra) # 6b6e <printf>
    exit(1,"");
    47be:	00004597          	auipc	a1,0x4
    47c2:	b9a58593          	addi	a1,a1,-1126 # 8358 <malloc+0x172c>
    47c6:	4505                	li	a0,1
    47c8:	00002097          	auipc	ra,0x2
    47cc:	ffe080e7          	jalr	-2(ra) # 67c6 <exit>
    printf("%s: chdir dots failed\n", s);
    47d0:	85a6                	mv	a1,s1
    47d2:	00004517          	auipc	a0,0x4
    47d6:	e6e50513          	addi	a0,a0,-402 # 8640 <malloc+0x1a14>
    47da:	00002097          	auipc	ra,0x2
    47de:	394080e7          	jalr	916(ra) # 6b6e <printf>
    exit(1,"");
    47e2:	00004597          	auipc	a1,0x4
    47e6:	b7658593          	addi	a1,a1,-1162 # 8358 <malloc+0x172c>
    47ea:	4505                	li	a0,1
    47ec:	00002097          	auipc	ra,0x2
    47f0:	fda080e7          	jalr	-38(ra) # 67c6 <exit>
    printf("%s: rm . worked!\n", s);
    47f4:	85a6                	mv	a1,s1
    47f6:	00004517          	auipc	a0,0x4
    47fa:	e6250513          	addi	a0,a0,-414 # 8658 <malloc+0x1a2c>
    47fe:	00002097          	auipc	ra,0x2
    4802:	370080e7          	jalr	880(ra) # 6b6e <printf>
    exit(1,"");
    4806:	00004597          	auipc	a1,0x4
    480a:	b5258593          	addi	a1,a1,-1198 # 8358 <malloc+0x172c>
    480e:	4505                	li	a0,1
    4810:	00002097          	auipc	ra,0x2
    4814:	fb6080e7          	jalr	-74(ra) # 67c6 <exit>
    printf("%s: rm .. worked!\n", s);
    4818:	85a6                	mv	a1,s1
    481a:	00004517          	auipc	a0,0x4
    481e:	e5650513          	addi	a0,a0,-426 # 8670 <malloc+0x1a44>
    4822:	00002097          	auipc	ra,0x2
    4826:	34c080e7          	jalr	844(ra) # 6b6e <printf>
    exit(1,"");
    482a:	00004597          	auipc	a1,0x4
    482e:	b2e58593          	addi	a1,a1,-1234 # 8358 <malloc+0x172c>
    4832:	4505                	li	a0,1
    4834:	00002097          	auipc	ra,0x2
    4838:	f92080e7          	jalr	-110(ra) # 67c6 <exit>
    printf("%s: chdir / failed\n", s);
    483c:	85a6                	mv	a1,s1
    483e:	00003517          	auipc	a0,0x3
    4842:	7ea50513          	addi	a0,a0,2026 # 8028 <malloc+0x13fc>
    4846:	00002097          	auipc	ra,0x2
    484a:	328080e7          	jalr	808(ra) # 6b6e <printf>
    exit(1,"");
    484e:	00004597          	auipc	a1,0x4
    4852:	b0a58593          	addi	a1,a1,-1270 # 8358 <malloc+0x172c>
    4856:	4505                	li	a0,1
    4858:	00002097          	auipc	ra,0x2
    485c:	f6e080e7          	jalr	-146(ra) # 67c6 <exit>
    printf("%s: unlink dots/. worked!\n", s);
    4860:	85a6                	mv	a1,s1
    4862:	00004517          	auipc	a0,0x4
    4866:	e2e50513          	addi	a0,a0,-466 # 8690 <malloc+0x1a64>
    486a:	00002097          	auipc	ra,0x2
    486e:	304080e7          	jalr	772(ra) # 6b6e <printf>
    exit(1,"");
    4872:	00004597          	auipc	a1,0x4
    4876:	ae658593          	addi	a1,a1,-1306 # 8358 <malloc+0x172c>
    487a:	4505                	li	a0,1
    487c:	00002097          	auipc	ra,0x2
    4880:	f4a080e7          	jalr	-182(ra) # 67c6 <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    4884:	85a6                	mv	a1,s1
    4886:	00004517          	auipc	a0,0x4
    488a:	e3250513          	addi	a0,a0,-462 # 86b8 <malloc+0x1a8c>
    488e:	00002097          	auipc	ra,0x2
    4892:	2e0080e7          	jalr	736(ra) # 6b6e <printf>
    exit(1,"");
    4896:	00004597          	auipc	a1,0x4
    489a:	ac258593          	addi	a1,a1,-1342 # 8358 <malloc+0x172c>
    489e:	4505                	li	a0,1
    48a0:	00002097          	auipc	ra,0x2
    48a4:	f26080e7          	jalr	-218(ra) # 67c6 <exit>
    printf("%s: unlink dots failed!\n", s);
    48a8:	85a6                	mv	a1,s1
    48aa:	00004517          	auipc	a0,0x4
    48ae:	e2e50513          	addi	a0,a0,-466 # 86d8 <malloc+0x1aac>
    48b2:	00002097          	auipc	ra,0x2
    48b6:	2bc080e7          	jalr	700(ra) # 6b6e <printf>
    exit(1,"");
    48ba:	00004597          	auipc	a1,0x4
    48be:	a9e58593          	addi	a1,a1,-1378 # 8358 <malloc+0x172c>
    48c2:	4505                	li	a0,1
    48c4:	00002097          	auipc	ra,0x2
    48c8:	f02080e7          	jalr	-254(ra) # 67c6 <exit>

00000000000048cc <dirfile>:
{
    48cc:	1101                	addi	sp,sp,-32
    48ce:	ec06                	sd	ra,24(sp)
    48d0:	e822                	sd	s0,16(sp)
    48d2:	e426                	sd	s1,8(sp)
    48d4:	e04a                	sd	s2,0(sp)
    48d6:	1000                	addi	s0,sp,32
    48d8:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    48da:	20000593          	li	a1,512
    48de:	00004517          	auipc	a0,0x4
    48e2:	e1a50513          	addi	a0,a0,-486 # 86f8 <malloc+0x1acc>
    48e6:	00002097          	auipc	ra,0x2
    48ea:	f20080e7          	jalr	-224(ra) # 6806 <open>
  if(fd < 0){
    48ee:	0e054e63          	bltz	a0,49ea <dirfile+0x11e>
  close(fd);
    48f2:	00002097          	auipc	ra,0x2
    48f6:	efc080e7          	jalr	-260(ra) # 67ee <close>
  if(chdir("dirfile") == 0){
    48fa:	00004517          	auipc	a0,0x4
    48fe:	dfe50513          	addi	a0,a0,-514 # 86f8 <malloc+0x1acc>
    4902:	00002097          	auipc	ra,0x2
    4906:	f34080e7          	jalr	-204(ra) # 6836 <chdir>
    490a:	10050263          	beqz	a0,4a0e <dirfile+0x142>
  fd = open("dirfile/xx", 0);
    490e:	4581                	li	a1,0
    4910:	00004517          	auipc	a0,0x4
    4914:	e3050513          	addi	a0,a0,-464 # 8740 <malloc+0x1b14>
    4918:	00002097          	auipc	ra,0x2
    491c:	eee080e7          	jalr	-274(ra) # 6806 <open>
  if(fd >= 0){
    4920:	10055963          	bgez	a0,4a32 <dirfile+0x166>
  fd = open("dirfile/xx", O_CREATE);
    4924:	20000593          	li	a1,512
    4928:	00004517          	auipc	a0,0x4
    492c:	e1850513          	addi	a0,a0,-488 # 8740 <malloc+0x1b14>
    4930:	00002097          	auipc	ra,0x2
    4934:	ed6080e7          	jalr	-298(ra) # 6806 <open>
  if(fd >= 0){
    4938:	10055f63          	bgez	a0,4a56 <dirfile+0x18a>
  if(mkdir("dirfile/xx") == 0){
    493c:	00004517          	auipc	a0,0x4
    4940:	e0450513          	addi	a0,a0,-508 # 8740 <malloc+0x1b14>
    4944:	00002097          	auipc	ra,0x2
    4948:	eea080e7          	jalr	-278(ra) # 682e <mkdir>
    494c:	12050763          	beqz	a0,4a7a <dirfile+0x1ae>
  if(unlink("dirfile/xx") == 0){
    4950:	00004517          	auipc	a0,0x4
    4954:	df050513          	addi	a0,a0,-528 # 8740 <malloc+0x1b14>
    4958:	00002097          	auipc	ra,0x2
    495c:	ebe080e7          	jalr	-322(ra) # 6816 <unlink>
    4960:	12050f63          	beqz	a0,4a9e <dirfile+0x1d2>
  if(link("README", "dirfile/xx") == 0){
    4964:	00004597          	auipc	a1,0x4
    4968:	ddc58593          	addi	a1,a1,-548 # 8740 <malloc+0x1b14>
    496c:	00002517          	auipc	a0,0x2
    4970:	5d450513          	addi	a0,a0,1492 # 6f40 <malloc+0x314>
    4974:	00002097          	auipc	ra,0x2
    4978:	eb2080e7          	jalr	-334(ra) # 6826 <link>
    497c:	14050363          	beqz	a0,4ac2 <dirfile+0x1f6>
  if(unlink("dirfile") != 0){
    4980:	00004517          	auipc	a0,0x4
    4984:	d7850513          	addi	a0,a0,-648 # 86f8 <malloc+0x1acc>
    4988:	00002097          	auipc	ra,0x2
    498c:	e8e080e7          	jalr	-370(ra) # 6816 <unlink>
    4990:	14051b63          	bnez	a0,4ae6 <dirfile+0x21a>
  fd = open(".", O_RDWR);
    4994:	4589                	li	a1,2
    4996:	00003517          	auipc	a0,0x3
    499a:	aba50513          	addi	a0,a0,-1350 # 7450 <malloc+0x824>
    499e:	00002097          	auipc	ra,0x2
    49a2:	e68080e7          	jalr	-408(ra) # 6806 <open>
  if(fd >= 0){
    49a6:	16055263          	bgez	a0,4b0a <dirfile+0x23e>
  fd = open(".", 0);
    49aa:	4581                	li	a1,0
    49ac:	00003517          	auipc	a0,0x3
    49b0:	aa450513          	addi	a0,a0,-1372 # 7450 <malloc+0x824>
    49b4:	00002097          	auipc	ra,0x2
    49b8:	e52080e7          	jalr	-430(ra) # 6806 <open>
    49bc:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    49be:	4605                	li	a2,1
    49c0:	00002597          	auipc	a1,0x2
    49c4:	41858593          	addi	a1,a1,1048 # 6dd8 <malloc+0x1ac>
    49c8:	00002097          	auipc	ra,0x2
    49cc:	e1e080e7          	jalr	-482(ra) # 67e6 <write>
    49d0:	14a04f63          	bgtz	a0,4b2e <dirfile+0x262>
  close(fd);
    49d4:	8526                	mv	a0,s1
    49d6:	00002097          	auipc	ra,0x2
    49da:	e18080e7          	jalr	-488(ra) # 67ee <close>
}
    49de:	60e2                	ld	ra,24(sp)
    49e0:	6442                	ld	s0,16(sp)
    49e2:	64a2                	ld	s1,8(sp)
    49e4:	6902                	ld	s2,0(sp)
    49e6:	6105                	addi	sp,sp,32
    49e8:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    49ea:	85ca                	mv	a1,s2
    49ec:	00004517          	auipc	a0,0x4
    49f0:	d1450513          	addi	a0,a0,-748 # 8700 <malloc+0x1ad4>
    49f4:	00002097          	auipc	ra,0x2
    49f8:	17a080e7          	jalr	378(ra) # 6b6e <printf>
    exit(1,"");
    49fc:	00004597          	auipc	a1,0x4
    4a00:	95c58593          	addi	a1,a1,-1700 # 8358 <malloc+0x172c>
    4a04:	4505                	li	a0,1
    4a06:	00002097          	auipc	ra,0x2
    4a0a:	dc0080e7          	jalr	-576(ra) # 67c6 <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    4a0e:	85ca                	mv	a1,s2
    4a10:	00004517          	auipc	a0,0x4
    4a14:	d1050513          	addi	a0,a0,-752 # 8720 <malloc+0x1af4>
    4a18:	00002097          	auipc	ra,0x2
    4a1c:	156080e7          	jalr	342(ra) # 6b6e <printf>
    exit(1,"");
    4a20:	00004597          	auipc	a1,0x4
    4a24:	93858593          	addi	a1,a1,-1736 # 8358 <malloc+0x172c>
    4a28:	4505                	li	a0,1
    4a2a:	00002097          	auipc	ra,0x2
    4a2e:	d9c080e7          	jalr	-612(ra) # 67c6 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    4a32:	85ca                	mv	a1,s2
    4a34:	00004517          	auipc	a0,0x4
    4a38:	d1c50513          	addi	a0,a0,-740 # 8750 <malloc+0x1b24>
    4a3c:	00002097          	auipc	ra,0x2
    4a40:	132080e7          	jalr	306(ra) # 6b6e <printf>
    exit(1,"");
    4a44:	00004597          	auipc	a1,0x4
    4a48:	91458593          	addi	a1,a1,-1772 # 8358 <malloc+0x172c>
    4a4c:	4505                	li	a0,1
    4a4e:	00002097          	auipc	ra,0x2
    4a52:	d78080e7          	jalr	-648(ra) # 67c6 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    4a56:	85ca                	mv	a1,s2
    4a58:	00004517          	auipc	a0,0x4
    4a5c:	cf850513          	addi	a0,a0,-776 # 8750 <malloc+0x1b24>
    4a60:	00002097          	auipc	ra,0x2
    4a64:	10e080e7          	jalr	270(ra) # 6b6e <printf>
    exit(1,"");
    4a68:	00004597          	auipc	a1,0x4
    4a6c:	8f058593          	addi	a1,a1,-1808 # 8358 <malloc+0x172c>
    4a70:	4505                	li	a0,1
    4a72:	00002097          	auipc	ra,0x2
    4a76:	d54080e7          	jalr	-684(ra) # 67c6 <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    4a7a:	85ca                	mv	a1,s2
    4a7c:	00004517          	auipc	a0,0x4
    4a80:	cfc50513          	addi	a0,a0,-772 # 8778 <malloc+0x1b4c>
    4a84:	00002097          	auipc	ra,0x2
    4a88:	0ea080e7          	jalr	234(ra) # 6b6e <printf>
    exit(1,"");
    4a8c:	00004597          	auipc	a1,0x4
    4a90:	8cc58593          	addi	a1,a1,-1844 # 8358 <malloc+0x172c>
    4a94:	4505                	li	a0,1
    4a96:	00002097          	auipc	ra,0x2
    4a9a:	d30080e7          	jalr	-720(ra) # 67c6 <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    4a9e:	85ca                	mv	a1,s2
    4aa0:	00004517          	auipc	a0,0x4
    4aa4:	d0050513          	addi	a0,a0,-768 # 87a0 <malloc+0x1b74>
    4aa8:	00002097          	auipc	ra,0x2
    4aac:	0c6080e7          	jalr	198(ra) # 6b6e <printf>
    exit(1,"");
    4ab0:	00004597          	auipc	a1,0x4
    4ab4:	8a858593          	addi	a1,a1,-1880 # 8358 <malloc+0x172c>
    4ab8:	4505                	li	a0,1
    4aba:	00002097          	auipc	ra,0x2
    4abe:	d0c080e7          	jalr	-756(ra) # 67c6 <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    4ac2:	85ca                	mv	a1,s2
    4ac4:	00004517          	auipc	a0,0x4
    4ac8:	d0450513          	addi	a0,a0,-764 # 87c8 <malloc+0x1b9c>
    4acc:	00002097          	auipc	ra,0x2
    4ad0:	0a2080e7          	jalr	162(ra) # 6b6e <printf>
    exit(1,"");
    4ad4:	00004597          	auipc	a1,0x4
    4ad8:	88458593          	addi	a1,a1,-1916 # 8358 <malloc+0x172c>
    4adc:	4505                	li	a0,1
    4ade:	00002097          	auipc	ra,0x2
    4ae2:	ce8080e7          	jalr	-792(ra) # 67c6 <exit>
    printf("%s: unlink dirfile failed!\n", s);
    4ae6:	85ca                	mv	a1,s2
    4ae8:	00004517          	auipc	a0,0x4
    4aec:	d0850513          	addi	a0,a0,-760 # 87f0 <malloc+0x1bc4>
    4af0:	00002097          	auipc	ra,0x2
    4af4:	07e080e7          	jalr	126(ra) # 6b6e <printf>
    exit(1,"");
    4af8:	00004597          	auipc	a1,0x4
    4afc:	86058593          	addi	a1,a1,-1952 # 8358 <malloc+0x172c>
    4b00:	4505                	li	a0,1
    4b02:	00002097          	auipc	ra,0x2
    4b06:	cc4080e7          	jalr	-828(ra) # 67c6 <exit>
    printf("%s: open . for writing succeeded!\n", s);
    4b0a:	85ca                	mv	a1,s2
    4b0c:	00004517          	auipc	a0,0x4
    4b10:	d0450513          	addi	a0,a0,-764 # 8810 <malloc+0x1be4>
    4b14:	00002097          	auipc	ra,0x2
    4b18:	05a080e7          	jalr	90(ra) # 6b6e <printf>
    exit(1,"");
    4b1c:	00004597          	auipc	a1,0x4
    4b20:	83c58593          	addi	a1,a1,-1988 # 8358 <malloc+0x172c>
    4b24:	4505                	li	a0,1
    4b26:	00002097          	auipc	ra,0x2
    4b2a:	ca0080e7          	jalr	-864(ra) # 67c6 <exit>
    printf("%s: write . succeeded!\n", s);
    4b2e:	85ca                	mv	a1,s2
    4b30:	00004517          	auipc	a0,0x4
    4b34:	d0850513          	addi	a0,a0,-760 # 8838 <malloc+0x1c0c>
    4b38:	00002097          	auipc	ra,0x2
    4b3c:	036080e7          	jalr	54(ra) # 6b6e <printf>
    exit(1,"");
    4b40:	00004597          	auipc	a1,0x4
    4b44:	81858593          	addi	a1,a1,-2024 # 8358 <malloc+0x172c>
    4b48:	4505                	li	a0,1
    4b4a:	00002097          	auipc	ra,0x2
    4b4e:	c7c080e7          	jalr	-900(ra) # 67c6 <exit>

0000000000004b52 <iref>:
{
    4b52:	7139                	addi	sp,sp,-64
    4b54:	fc06                	sd	ra,56(sp)
    4b56:	f822                	sd	s0,48(sp)
    4b58:	f426                	sd	s1,40(sp)
    4b5a:	f04a                	sd	s2,32(sp)
    4b5c:	ec4e                	sd	s3,24(sp)
    4b5e:	e852                	sd	s4,16(sp)
    4b60:	e456                	sd	s5,8(sp)
    4b62:	e05a                	sd	s6,0(sp)
    4b64:	0080                	addi	s0,sp,64
    4b66:	8b2a                	mv	s6,a0
    4b68:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    4b6c:	00004a17          	auipc	s4,0x4
    4b70:	ce4a0a13          	addi	s4,s4,-796 # 8850 <malloc+0x1c24>
    mkdir("");
    4b74:	00003497          	auipc	s1,0x3
    4b78:	7e448493          	addi	s1,s1,2020 # 8358 <malloc+0x172c>
    link("README", "");
    4b7c:	00002a97          	auipc	s5,0x2
    4b80:	3c4a8a93          	addi	s5,s5,964 # 6f40 <malloc+0x314>
    fd = open("xx", O_CREATE);
    4b84:	00004997          	auipc	s3,0x4
    4b88:	bc498993          	addi	s3,s3,-1084 # 8748 <malloc+0x1b1c>
    4b8c:	a095                	j	4bf0 <iref+0x9e>
      printf("%s: mkdir irefd failed\n", s);
    4b8e:	85da                	mv	a1,s6
    4b90:	00004517          	auipc	a0,0x4
    4b94:	cc850513          	addi	a0,a0,-824 # 8858 <malloc+0x1c2c>
    4b98:	00002097          	auipc	ra,0x2
    4b9c:	fd6080e7          	jalr	-42(ra) # 6b6e <printf>
      exit(1,"");
    4ba0:	00003597          	auipc	a1,0x3
    4ba4:	7b858593          	addi	a1,a1,1976 # 8358 <malloc+0x172c>
    4ba8:	4505                	li	a0,1
    4baa:	00002097          	auipc	ra,0x2
    4bae:	c1c080e7          	jalr	-996(ra) # 67c6 <exit>
      printf("%s: chdir irefd failed\n", s);
    4bb2:	85da                	mv	a1,s6
    4bb4:	00004517          	auipc	a0,0x4
    4bb8:	cbc50513          	addi	a0,a0,-836 # 8870 <malloc+0x1c44>
    4bbc:	00002097          	auipc	ra,0x2
    4bc0:	fb2080e7          	jalr	-78(ra) # 6b6e <printf>
      exit(1,"");
    4bc4:	00003597          	auipc	a1,0x3
    4bc8:	79458593          	addi	a1,a1,1940 # 8358 <malloc+0x172c>
    4bcc:	4505                	li	a0,1
    4bce:	00002097          	auipc	ra,0x2
    4bd2:	bf8080e7          	jalr	-1032(ra) # 67c6 <exit>
      close(fd);
    4bd6:	00002097          	auipc	ra,0x2
    4bda:	c18080e7          	jalr	-1000(ra) # 67ee <close>
    4bde:	a889                	j	4c30 <iref+0xde>
    unlink("xx");
    4be0:	854e                	mv	a0,s3
    4be2:	00002097          	auipc	ra,0x2
    4be6:	c34080e7          	jalr	-972(ra) # 6816 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    4bea:	397d                	addiw	s2,s2,-1
    4bec:	06090063          	beqz	s2,4c4c <iref+0xfa>
    if(mkdir("irefd") != 0){
    4bf0:	8552                	mv	a0,s4
    4bf2:	00002097          	auipc	ra,0x2
    4bf6:	c3c080e7          	jalr	-964(ra) # 682e <mkdir>
    4bfa:	f951                	bnez	a0,4b8e <iref+0x3c>
    if(chdir("irefd") != 0){
    4bfc:	8552                	mv	a0,s4
    4bfe:	00002097          	auipc	ra,0x2
    4c02:	c38080e7          	jalr	-968(ra) # 6836 <chdir>
    4c06:	f555                	bnez	a0,4bb2 <iref+0x60>
    mkdir("");
    4c08:	8526                	mv	a0,s1
    4c0a:	00002097          	auipc	ra,0x2
    4c0e:	c24080e7          	jalr	-988(ra) # 682e <mkdir>
    link("README", "");
    4c12:	85a6                	mv	a1,s1
    4c14:	8556                	mv	a0,s5
    4c16:	00002097          	auipc	ra,0x2
    4c1a:	c10080e7          	jalr	-1008(ra) # 6826 <link>
    fd = open("", O_CREATE);
    4c1e:	20000593          	li	a1,512
    4c22:	8526                	mv	a0,s1
    4c24:	00002097          	auipc	ra,0x2
    4c28:	be2080e7          	jalr	-1054(ra) # 6806 <open>
    if(fd >= 0)
    4c2c:	fa0555e3          	bgez	a0,4bd6 <iref+0x84>
    fd = open("xx", O_CREATE);
    4c30:	20000593          	li	a1,512
    4c34:	854e                	mv	a0,s3
    4c36:	00002097          	auipc	ra,0x2
    4c3a:	bd0080e7          	jalr	-1072(ra) # 6806 <open>
    if(fd >= 0)
    4c3e:	fa0541e3          	bltz	a0,4be0 <iref+0x8e>
      close(fd);
    4c42:	00002097          	auipc	ra,0x2
    4c46:	bac080e7          	jalr	-1108(ra) # 67ee <close>
    4c4a:	bf59                	j	4be0 <iref+0x8e>
    4c4c:	03300493          	li	s1,51
    chdir("..");
    4c50:	00003997          	auipc	s3,0x3
    4c54:	42898993          	addi	s3,s3,1064 # 8078 <malloc+0x144c>
    unlink("irefd");
    4c58:	00004917          	auipc	s2,0x4
    4c5c:	bf890913          	addi	s2,s2,-1032 # 8850 <malloc+0x1c24>
    chdir("..");
    4c60:	854e                	mv	a0,s3
    4c62:	00002097          	auipc	ra,0x2
    4c66:	bd4080e7          	jalr	-1068(ra) # 6836 <chdir>
    unlink("irefd");
    4c6a:	854a                	mv	a0,s2
    4c6c:	00002097          	auipc	ra,0x2
    4c70:	baa080e7          	jalr	-1110(ra) # 6816 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    4c74:	34fd                	addiw	s1,s1,-1
    4c76:	f4ed                	bnez	s1,4c60 <iref+0x10e>
  chdir("/");
    4c78:	00003517          	auipc	a0,0x3
    4c7c:	3a850513          	addi	a0,a0,936 # 8020 <malloc+0x13f4>
    4c80:	00002097          	auipc	ra,0x2
    4c84:	bb6080e7          	jalr	-1098(ra) # 6836 <chdir>
}
    4c88:	70e2                	ld	ra,56(sp)
    4c8a:	7442                	ld	s0,48(sp)
    4c8c:	74a2                	ld	s1,40(sp)
    4c8e:	7902                	ld	s2,32(sp)
    4c90:	69e2                	ld	s3,24(sp)
    4c92:	6a42                	ld	s4,16(sp)
    4c94:	6aa2                	ld	s5,8(sp)
    4c96:	6b02                	ld	s6,0(sp)
    4c98:	6121                	addi	sp,sp,64
    4c9a:	8082                	ret

0000000000004c9c <openiputtest>:
{
    4c9c:	7179                	addi	sp,sp,-48
    4c9e:	f406                	sd	ra,40(sp)
    4ca0:	f022                	sd	s0,32(sp)
    4ca2:	ec26                	sd	s1,24(sp)
    4ca4:	1800                	addi	s0,sp,48
    4ca6:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    4ca8:	00004517          	auipc	a0,0x4
    4cac:	be050513          	addi	a0,a0,-1056 # 8888 <malloc+0x1c5c>
    4cb0:	00002097          	auipc	ra,0x2
    4cb4:	b7e080e7          	jalr	-1154(ra) # 682e <mkdir>
    4cb8:	04054663          	bltz	a0,4d04 <openiputtest+0x68>
  pid = fork();
    4cbc:	00002097          	auipc	ra,0x2
    4cc0:	b02080e7          	jalr	-1278(ra) # 67be <fork>
  if(pid < 0){
    4cc4:	06054263          	bltz	a0,4d28 <openiputtest+0x8c>
  if(pid == 0){
    4cc8:	e959                	bnez	a0,4d5e <openiputtest+0xc2>
    int fd = open("oidir", O_RDWR);
    4cca:	4589                	li	a1,2
    4ccc:	00004517          	auipc	a0,0x4
    4cd0:	bbc50513          	addi	a0,a0,-1092 # 8888 <malloc+0x1c5c>
    4cd4:	00002097          	auipc	ra,0x2
    4cd8:	b32080e7          	jalr	-1230(ra) # 6806 <open>
    if(fd >= 0){
    4cdc:	06054863          	bltz	a0,4d4c <openiputtest+0xb0>
      printf("%s: open directory for write succeeded\n", s);
    4ce0:	85a6                	mv	a1,s1
    4ce2:	00004517          	auipc	a0,0x4
    4ce6:	bc650513          	addi	a0,a0,-1082 # 88a8 <malloc+0x1c7c>
    4cea:	00002097          	auipc	ra,0x2
    4cee:	e84080e7          	jalr	-380(ra) # 6b6e <printf>
      exit(1,"");
    4cf2:	00003597          	auipc	a1,0x3
    4cf6:	66658593          	addi	a1,a1,1638 # 8358 <malloc+0x172c>
    4cfa:	4505                	li	a0,1
    4cfc:	00002097          	auipc	ra,0x2
    4d00:	aca080e7          	jalr	-1334(ra) # 67c6 <exit>
    printf("%s: mkdir oidir failed\n", s);
    4d04:	85a6                	mv	a1,s1
    4d06:	00004517          	auipc	a0,0x4
    4d0a:	b8a50513          	addi	a0,a0,-1142 # 8890 <malloc+0x1c64>
    4d0e:	00002097          	auipc	ra,0x2
    4d12:	e60080e7          	jalr	-416(ra) # 6b6e <printf>
    exit(1,"");
    4d16:	00003597          	auipc	a1,0x3
    4d1a:	64258593          	addi	a1,a1,1602 # 8358 <malloc+0x172c>
    4d1e:	4505                	li	a0,1
    4d20:	00002097          	auipc	ra,0x2
    4d24:	aa6080e7          	jalr	-1370(ra) # 67c6 <exit>
    printf("%s: fork failed\n", s);
    4d28:	85a6                	mv	a1,s1
    4d2a:	00003517          	auipc	a0,0x3
    4d2e:	8c650513          	addi	a0,a0,-1850 # 75f0 <malloc+0x9c4>
    4d32:	00002097          	auipc	ra,0x2
    4d36:	e3c080e7          	jalr	-452(ra) # 6b6e <printf>
    exit(1,"");
    4d3a:	00003597          	auipc	a1,0x3
    4d3e:	61e58593          	addi	a1,a1,1566 # 8358 <malloc+0x172c>
    4d42:	4505                	li	a0,1
    4d44:	00002097          	auipc	ra,0x2
    4d48:	a82080e7          	jalr	-1406(ra) # 67c6 <exit>
    exit(0,"");
    4d4c:	00003597          	auipc	a1,0x3
    4d50:	60c58593          	addi	a1,a1,1548 # 8358 <malloc+0x172c>
    4d54:	4501                	li	a0,0
    4d56:	00002097          	auipc	ra,0x2
    4d5a:	a70080e7          	jalr	-1424(ra) # 67c6 <exit>
  sleep(1);
    4d5e:	4505                	li	a0,1
    4d60:	00002097          	auipc	ra,0x2
    4d64:	af6080e7          	jalr	-1290(ra) # 6856 <sleep>
  if(unlink("oidir") != 0){
    4d68:	00004517          	auipc	a0,0x4
    4d6c:	b2050513          	addi	a0,a0,-1248 # 8888 <malloc+0x1c5c>
    4d70:	00002097          	auipc	ra,0x2
    4d74:	aa6080e7          	jalr	-1370(ra) # 6816 <unlink>
    4d78:	c11d                	beqz	a0,4d9e <openiputtest+0x102>
    printf("%s: unlink failed\n", s);
    4d7a:	85a6                	mv	a1,s1
    4d7c:	00003517          	auipc	a0,0x3
    4d80:	a6450513          	addi	a0,a0,-1436 # 77e0 <malloc+0xbb4>
    4d84:	00002097          	auipc	ra,0x2
    4d88:	dea080e7          	jalr	-534(ra) # 6b6e <printf>
    exit(1,"");
    4d8c:	00003597          	auipc	a1,0x3
    4d90:	5cc58593          	addi	a1,a1,1484 # 8358 <malloc+0x172c>
    4d94:	4505                	li	a0,1
    4d96:	00002097          	auipc	ra,0x2
    4d9a:	a30080e7          	jalr	-1488(ra) # 67c6 <exit>
  wait(&xstatus,"");
    4d9e:	00003597          	auipc	a1,0x3
    4da2:	5ba58593          	addi	a1,a1,1466 # 8358 <malloc+0x172c>
    4da6:	fdc40513          	addi	a0,s0,-36
    4daa:	00002097          	auipc	ra,0x2
    4dae:	a24080e7          	jalr	-1500(ra) # 67ce <wait>
  exit(xstatus,"");
    4db2:	00003597          	auipc	a1,0x3
    4db6:	5a658593          	addi	a1,a1,1446 # 8358 <malloc+0x172c>
    4dba:	fdc42503          	lw	a0,-36(s0)
    4dbe:	00002097          	auipc	ra,0x2
    4dc2:	a08080e7          	jalr	-1528(ra) # 67c6 <exit>

0000000000004dc6 <forkforkfork>:
{
    4dc6:	1101                	addi	sp,sp,-32
    4dc8:	ec06                	sd	ra,24(sp)
    4dca:	e822                	sd	s0,16(sp)
    4dcc:	e426                	sd	s1,8(sp)
    4dce:	1000                	addi	s0,sp,32
    4dd0:	84aa                	mv	s1,a0
  unlink("stopforking");
    4dd2:	00004517          	auipc	a0,0x4
    4dd6:	afe50513          	addi	a0,a0,-1282 # 88d0 <malloc+0x1ca4>
    4dda:	00002097          	auipc	ra,0x2
    4dde:	a3c080e7          	jalr	-1476(ra) # 6816 <unlink>
  int pid = fork();
    4de2:	00002097          	auipc	ra,0x2
    4de6:	9dc080e7          	jalr	-1572(ra) # 67be <fork>
  if(pid < 0){
    4dea:	04054963          	bltz	a0,4e3c <forkforkfork+0x76>
  if(pid == 0){
    4dee:	c92d                	beqz	a0,4e60 <forkforkfork+0x9a>
  sleep(20); // two seconds
    4df0:	4551                	li	a0,20
    4df2:	00002097          	auipc	ra,0x2
    4df6:	a64080e7          	jalr	-1436(ra) # 6856 <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
    4dfa:	20200593          	li	a1,514
    4dfe:	00004517          	auipc	a0,0x4
    4e02:	ad250513          	addi	a0,a0,-1326 # 88d0 <malloc+0x1ca4>
    4e06:	00002097          	auipc	ra,0x2
    4e0a:	a00080e7          	jalr	-1536(ra) # 6806 <open>
    4e0e:	00002097          	auipc	ra,0x2
    4e12:	9e0080e7          	jalr	-1568(ra) # 67ee <close>
  wait(0,"");
    4e16:	00003597          	auipc	a1,0x3
    4e1a:	54258593          	addi	a1,a1,1346 # 8358 <malloc+0x172c>
    4e1e:	4501                	li	a0,0
    4e20:	00002097          	auipc	ra,0x2
    4e24:	9ae080e7          	jalr	-1618(ra) # 67ce <wait>
  sleep(10); // one second
    4e28:	4529                	li	a0,10
    4e2a:	00002097          	auipc	ra,0x2
    4e2e:	a2c080e7          	jalr	-1492(ra) # 6856 <sleep>
}
    4e32:	60e2                	ld	ra,24(sp)
    4e34:	6442                	ld	s0,16(sp)
    4e36:	64a2                	ld	s1,8(sp)
    4e38:	6105                	addi	sp,sp,32
    4e3a:	8082                	ret
    printf("%s: fork failed", s);
    4e3c:	85a6                	mv	a1,s1
    4e3e:	00003517          	auipc	a0,0x3
    4e42:	97250513          	addi	a0,a0,-1678 # 77b0 <malloc+0xb84>
    4e46:	00002097          	auipc	ra,0x2
    4e4a:	d28080e7          	jalr	-728(ra) # 6b6e <printf>
    exit(1,"");
    4e4e:	00003597          	auipc	a1,0x3
    4e52:	50a58593          	addi	a1,a1,1290 # 8358 <malloc+0x172c>
    4e56:	4505                	li	a0,1
    4e58:	00002097          	auipc	ra,0x2
    4e5c:	96e080e7          	jalr	-1682(ra) # 67c6 <exit>
      int fd = open("stopforking", 0);
    4e60:	00004497          	auipc	s1,0x4
    4e64:	a7048493          	addi	s1,s1,-1424 # 88d0 <malloc+0x1ca4>
    4e68:	4581                	li	a1,0
    4e6a:	8526                	mv	a0,s1
    4e6c:	00002097          	auipc	ra,0x2
    4e70:	99a080e7          	jalr	-1638(ra) # 6806 <open>
      if(fd >= 0){
    4e74:	02055463          	bgez	a0,4e9c <forkforkfork+0xd6>
      if(fork() < 0){
    4e78:	00002097          	auipc	ra,0x2
    4e7c:	946080e7          	jalr	-1722(ra) # 67be <fork>
    4e80:	fe0554e3          	bgez	a0,4e68 <forkforkfork+0xa2>
        close(open("stopforking", O_CREATE|O_RDWR));
    4e84:	20200593          	li	a1,514
    4e88:	8526                	mv	a0,s1
    4e8a:	00002097          	auipc	ra,0x2
    4e8e:	97c080e7          	jalr	-1668(ra) # 6806 <open>
    4e92:	00002097          	auipc	ra,0x2
    4e96:	95c080e7          	jalr	-1700(ra) # 67ee <close>
    4e9a:	b7f9                	j	4e68 <forkforkfork+0xa2>
        exit(0,"");
    4e9c:	00003597          	auipc	a1,0x3
    4ea0:	4bc58593          	addi	a1,a1,1212 # 8358 <malloc+0x172c>
    4ea4:	4501                	li	a0,0
    4ea6:	00002097          	auipc	ra,0x2
    4eaa:	920080e7          	jalr	-1760(ra) # 67c6 <exit>

0000000000004eae <killstatus>:
{
    4eae:	715d                	addi	sp,sp,-80
    4eb0:	e486                	sd	ra,72(sp)
    4eb2:	e0a2                	sd	s0,64(sp)
    4eb4:	fc26                	sd	s1,56(sp)
    4eb6:	f84a                	sd	s2,48(sp)
    4eb8:	f44e                	sd	s3,40(sp)
    4eba:	f052                	sd	s4,32(sp)
    4ebc:	ec56                	sd	s5,24(sp)
    4ebe:	0880                	addi	s0,sp,80
    4ec0:	8aaa                	mv	s5,a0
    4ec2:	06400913          	li	s2,100
    wait(&xst,"");
    4ec6:	00003a17          	auipc	s4,0x3
    4eca:	492a0a13          	addi	s4,s4,1170 # 8358 <malloc+0x172c>
    if(xst != -1) {
    4ece:	59fd                	li	s3,-1
    int pid1 = fork();
    4ed0:	00002097          	auipc	ra,0x2
    4ed4:	8ee080e7          	jalr	-1810(ra) # 67be <fork>
    4ed8:	84aa                	mv	s1,a0
    if(pid1 < 0){
    4eda:	04054463          	bltz	a0,4f22 <killstatus+0x74>
    if(pid1 == 0){
    4ede:	c525                	beqz	a0,4f46 <killstatus+0x98>
    sleep(1);
    4ee0:	4505                	li	a0,1
    4ee2:	00002097          	auipc	ra,0x2
    4ee6:	974080e7          	jalr	-1676(ra) # 6856 <sleep>
    kill(pid1);
    4eea:	8526                	mv	a0,s1
    4eec:	00002097          	auipc	ra,0x2
    4ef0:	90a080e7          	jalr	-1782(ra) # 67f6 <kill>
    wait(&xst,"");
    4ef4:	85d2                	mv	a1,s4
    4ef6:	fbc40513          	addi	a0,s0,-68
    4efa:	00002097          	auipc	ra,0x2
    4efe:	8d4080e7          	jalr	-1836(ra) # 67ce <wait>
    if(xst != -1) {
    4f02:	fbc42783          	lw	a5,-68(s0)
    4f06:	05379563          	bne	a5,s3,4f50 <killstatus+0xa2>
  for(int i = 0; i < 100; i++){
    4f0a:	397d                	addiw	s2,s2,-1
    4f0c:	fc0912e3          	bnez	s2,4ed0 <killstatus+0x22>
  exit(0,"");
    4f10:	00003597          	auipc	a1,0x3
    4f14:	44858593          	addi	a1,a1,1096 # 8358 <malloc+0x172c>
    4f18:	4501                	li	a0,0
    4f1a:	00002097          	auipc	ra,0x2
    4f1e:	8ac080e7          	jalr	-1876(ra) # 67c6 <exit>
      printf("%s: fork failed\n", s);
    4f22:	85d6                	mv	a1,s5
    4f24:	00002517          	auipc	a0,0x2
    4f28:	6cc50513          	addi	a0,a0,1740 # 75f0 <malloc+0x9c4>
    4f2c:	00002097          	auipc	ra,0x2
    4f30:	c42080e7          	jalr	-958(ra) # 6b6e <printf>
      exit(1,"");
    4f34:	00003597          	auipc	a1,0x3
    4f38:	42458593          	addi	a1,a1,1060 # 8358 <malloc+0x172c>
    4f3c:	4505                	li	a0,1
    4f3e:	00002097          	auipc	ra,0x2
    4f42:	888080e7          	jalr	-1912(ra) # 67c6 <exit>
        getpid();
    4f46:	00002097          	auipc	ra,0x2
    4f4a:	900080e7          	jalr	-1792(ra) # 6846 <getpid>
      while(1) {
    4f4e:	bfe5                	j	4f46 <killstatus+0x98>
       printf("%s: status should be -1\n", s);
    4f50:	85d6                	mv	a1,s5
    4f52:	00004517          	auipc	a0,0x4
    4f56:	98e50513          	addi	a0,a0,-1650 # 88e0 <malloc+0x1cb4>
    4f5a:	00002097          	auipc	ra,0x2
    4f5e:	c14080e7          	jalr	-1004(ra) # 6b6e <printf>
       exit(1,"");
    4f62:	00003597          	auipc	a1,0x3
    4f66:	3f658593          	addi	a1,a1,1014 # 8358 <malloc+0x172c>
    4f6a:	4505                	li	a0,1
    4f6c:	00002097          	auipc	ra,0x2
    4f70:	85a080e7          	jalr	-1958(ra) # 67c6 <exit>

0000000000004f74 <preempt>:
{
    4f74:	7139                	addi	sp,sp,-64
    4f76:	fc06                	sd	ra,56(sp)
    4f78:	f822                	sd	s0,48(sp)
    4f7a:	f426                	sd	s1,40(sp)
    4f7c:	f04a                	sd	s2,32(sp)
    4f7e:	ec4e                	sd	s3,24(sp)
    4f80:	e852                	sd	s4,16(sp)
    4f82:	0080                	addi	s0,sp,64
    4f84:	892a                	mv	s2,a0
  pid1 = fork();
    4f86:	00002097          	auipc	ra,0x2
    4f8a:	838080e7          	jalr	-1992(ra) # 67be <fork>
  if(pid1 < 0) {
    4f8e:	00054563          	bltz	a0,4f98 <preempt+0x24>
    4f92:	84aa                	mv	s1,a0
  if(pid1 == 0)
    4f94:	e505                	bnez	a0,4fbc <preempt+0x48>
    for(;;)
    4f96:	a001                	j	4f96 <preempt+0x22>
    printf("%s: fork failed", s);
    4f98:	85ca                	mv	a1,s2
    4f9a:	00003517          	auipc	a0,0x3
    4f9e:	81650513          	addi	a0,a0,-2026 # 77b0 <malloc+0xb84>
    4fa2:	00002097          	auipc	ra,0x2
    4fa6:	bcc080e7          	jalr	-1076(ra) # 6b6e <printf>
    exit(1,"");
    4faa:	00003597          	auipc	a1,0x3
    4fae:	3ae58593          	addi	a1,a1,942 # 8358 <malloc+0x172c>
    4fb2:	4505                	li	a0,1
    4fb4:	00002097          	auipc	ra,0x2
    4fb8:	812080e7          	jalr	-2030(ra) # 67c6 <exit>
  pid2 = fork();
    4fbc:	00002097          	auipc	ra,0x2
    4fc0:	802080e7          	jalr	-2046(ra) # 67be <fork>
    4fc4:	89aa                	mv	s3,a0
  if(pid2 < 0) {
    4fc6:	00054463          	bltz	a0,4fce <preempt+0x5a>
  if(pid2 == 0)
    4fca:	e505                	bnez	a0,4ff2 <preempt+0x7e>
    for(;;)
    4fcc:	a001                	j	4fcc <preempt+0x58>
    printf("%s: fork failed\n", s);
    4fce:	85ca                	mv	a1,s2
    4fd0:	00002517          	auipc	a0,0x2
    4fd4:	62050513          	addi	a0,a0,1568 # 75f0 <malloc+0x9c4>
    4fd8:	00002097          	auipc	ra,0x2
    4fdc:	b96080e7          	jalr	-1130(ra) # 6b6e <printf>
    exit(1,"");
    4fe0:	00003597          	auipc	a1,0x3
    4fe4:	37858593          	addi	a1,a1,888 # 8358 <malloc+0x172c>
    4fe8:	4505                	li	a0,1
    4fea:	00001097          	auipc	ra,0x1
    4fee:	7dc080e7          	jalr	2012(ra) # 67c6 <exit>
  pipe(pfds);
    4ff2:	fc840513          	addi	a0,s0,-56
    4ff6:	00001097          	auipc	ra,0x1
    4ffa:	7e0080e7          	jalr	2016(ra) # 67d6 <pipe>
  pid3 = fork();
    4ffe:	00001097          	auipc	ra,0x1
    5002:	7c0080e7          	jalr	1984(ra) # 67be <fork>
    5006:	8a2a                	mv	s4,a0
  if(pid3 < 0) {
    5008:	02054e63          	bltz	a0,5044 <preempt+0xd0>
  if(pid3 == 0){
    500c:	e925                	bnez	a0,507c <preempt+0x108>
    close(pfds[0]);
    500e:	fc842503          	lw	a0,-56(s0)
    5012:	00001097          	auipc	ra,0x1
    5016:	7dc080e7          	jalr	2012(ra) # 67ee <close>
    if(write(pfds[1], "x", 1) != 1)
    501a:	4605                	li	a2,1
    501c:	00002597          	auipc	a1,0x2
    5020:	dbc58593          	addi	a1,a1,-580 # 6dd8 <malloc+0x1ac>
    5024:	fcc42503          	lw	a0,-52(s0)
    5028:	00001097          	auipc	ra,0x1
    502c:	7be080e7          	jalr	1982(ra) # 67e6 <write>
    5030:	4785                	li	a5,1
    5032:	02f51b63          	bne	a0,a5,5068 <preempt+0xf4>
    close(pfds[1]);
    5036:	fcc42503          	lw	a0,-52(s0)
    503a:	00001097          	auipc	ra,0x1
    503e:	7b4080e7          	jalr	1972(ra) # 67ee <close>
    for(;;)
    5042:	a001                	j	5042 <preempt+0xce>
     printf("%s: fork failed\n", s);
    5044:	85ca                	mv	a1,s2
    5046:	00002517          	auipc	a0,0x2
    504a:	5aa50513          	addi	a0,a0,1450 # 75f0 <malloc+0x9c4>
    504e:	00002097          	auipc	ra,0x2
    5052:	b20080e7          	jalr	-1248(ra) # 6b6e <printf>
     exit(1,"");
    5056:	00003597          	auipc	a1,0x3
    505a:	30258593          	addi	a1,a1,770 # 8358 <malloc+0x172c>
    505e:	4505                	li	a0,1
    5060:	00001097          	auipc	ra,0x1
    5064:	766080e7          	jalr	1894(ra) # 67c6 <exit>
      printf("%s: preempt write error", s);
    5068:	85ca                	mv	a1,s2
    506a:	00004517          	auipc	a0,0x4
    506e:	89650513          	addi	a0,a0,-1898 # 8900 <malloc+0x1cd4>
    5072:	00002097          	auipc	ra,0x2
    5076:	afc080e7          	jalr	-1284(ra) # 6b6e <printf>
    507a:	bf75                	j	5036 <preempt+0xc2>
  close(pfds[1]);
    507c:	fcc42503          	lw	a0,-52(s0)
    5080:	00001097          	auipc	ra,0x1
    5084:	76e080e7          	jalr	1902(ra) # 67ee <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    5088:	660d                	lui	a2,0x3
    508a:	00009597          	auipc	a1,0x9
    508e:	bee58593          	addi	a1,a1,-1042 # dc78 <buf>
    5092:	fc842503          	lw	a0,-56(s0)
    5096:	00001097          	auipc	ra,0x1
    509a:	748080e7          	jalr	1864(ra) # 67de <read>
    509e:	4785                	li	a5,1
    50a0:	02f50363          	beq	a0,a5,50c6 <preempt+0x152>
    printf("%s: preempt read error", s);
    50a4:	85ca                	mv	a1,s2
    50a6:	00004517          	auipc	a0,0x4
    50aa:	87250513          	addi	a0,a0,-1934 # 8918 <malloc+0x1cec>
    50ae:	00002097          	auipc	ra,0x2
    50b2:	ac0080e7          	jalr	-1344(ra) # 6b6e <printf>
}
    50b6:	70e2                	ld	ra,56(sp)
    50b8:	7442                	ld	s0,48(sp)
    50ba:	74a2                	ld	s1,40(sp)
    50bc:	7902                	ld	s2,32(sp)
    50be:	69e2                	ld	s3,24(sp)
    50c0:	6a42                	ld	s4,16(sp)
    50c2:	6121                	addi	sp,sp,64
    50c4:	8082                	ret
  close(pfds[0]);
    50c6:	fc842503          	lw	a0,-56(s0)
    50ca:	00001097          	auipc	ra,0x1
    50ce:	724080e7          	jalr	1828(ra) # 67ee <close>
  printf("kill... ");
    50d2:	00004517          	auipc	a0,0x4
    50d6:	85e50513          	addi	a0,a0,-1954 # 8930 <malloc+0x1d04>
    50da:	00002097          	auipc	ra,0x2
    50de:	a94080e7          	jalr	-1388(ra) # 6b6e <printf>
  kill(pid1);
    50e2:	8526                	mv	a0,s1
    50e4:	00001097          	auipc	ra,0x1
    50e8:	712080e7          	jalr	1810(ra) # 67f6 <kill>
  kill(pid2);
    50ec:	854e                	mv	a0,s3
    50ee:	00001097          	auipc	ra,0x1
    50f2:	708080e7          	jalr	1800(ra) # 67f6 <kill>
  kill(pid3);
    50f6:	8552                	mv	a0,s4
    50f8:	00001097          	auipc	ra,0x1
    50fc:	6fe080e7          	jalr	1790(ra) # 67f6 <kill>
  printf("wait... ");
    5100:	00004517          	auipc	a0,0x4
    5104:	84050513          	addi	a0,a0,-1984 # 8940 <malloc+0x1d14>
    5108:	00002097          	auipc	ra,0x2
    510c:	a66080e7          	jalr	-1434(ra) # 6b6e <printf>
  wait(0,"");
    5110:	00003597          	auipc	a1,0x3
    5114:	24858593          	addi	a1,a1,584 # 8358 <malloc+0x172c>
    5118:	4501                	li	a0,0
    511a:	00001097          	auipc	ra,0x1
    511e:	6b4080e7          	jalr	1716(ra) # 67ce <wait>
  wait(0,"");
    5122:	00003597          	auipc	a1,0x3
    5126:	23658593          	addi	a1,a1,566 # 8358 <malloc+0x172c>
    512a:	4501                	li	a0,0
    512c:	00001097          	auipc	ra,0x1
    5130:	6a2080e7          	jalr	1698(ra) # 67ce <wait>
  wait(0,"");
    5134:	00003597          	auipc	a1,0x3
    5138:	22458593          	addi	a1,a1,548 # 8358 <malloc+0x172c>
    513c:	4501                	li	a0,0
    513e:	00001097          	auipc	ra,0x1
    5142:	690080e7          	jalr	1680(ra) # 67ce <wait>
    5146:	bf85                	j	50b6 <preempt+0x142>

0000000000005148 <reparent>:
{
    5148:	7139                	addi	sp,sp,-64
    514a:	fc06                	sd	ra,56(sp)
    514c:	f822                	sd	s0,48(sp)
    514e:	f426                	sd	s1,40(sp)
    5150:	f04a                	sd	s2,32(sp)
    5152:	ec4e                	sd	s3,24(sp)
    5154:	e852                	sd	s4,16(sp)
    5156:	e456                	sd	s5,8(sp)
    5158:	0080                	addi	s0,sp,64
    515a:	8a2a                	mv	s4,a0
  int master_pid = getpid();
    515c:	00001097          	auipc	ra,0x1
    5160:	6ea080e7          	jalr	1770(ra) # 6846 <getpid>
    5164:	8aaa                	mv	s5,a0
    5166:	0c800913          	li	s2,200
      if(wait(0,"") != pid){
    516a:	00003997          	auipc	s3,0x3
    516e:	1ee98993          	addi	s3,s3,494 # 8358 <malloc+0x172c>
    int pid = fork();
    5172:	00001097          	auipc	ra,0x1
    5176:	64c080e7          	jalr	1612(ra) # 67be <fork>
    517a:	84aa                	mv	s1,a0
    if(pid < 0){
    517c:	02054763          	bltz	a0,51aa <reparent+0x62>
    if(pid){
    5180:	c92d                	beqz	a0,51f2 <reparent+0xaa>
      if(wait(0,"") != pid){
    5182:	85ce                	mv	a1,s3
    5184:	4501                	li	a0,0
    5186:	00001097          	auipc	ra,0x1
    518a:	648080e7          	jalr	1608(ra) # 67ce <wait>
    518e:	04951063          	bne	a0,s1,51ce <reparent+0x86>
  for(int i = 0; i < 200; i++){
    5192:	397d                	addiw	s2,s2,-1
    5194:	fc091fe3          	bnez	s2,5172 <reparent+0x2a>
  exit(0,"");
    5198:	00003597          	auipc	a1,0x3
    519c:	1c058593          	addi	a1,a1,448 # 8358 <malloc+0x172c>
    51a0:	4501                	li	a0,0
    51a2:	00001097          	auipc	ra,0x1
    51a6:	624080e7          	jalr	1572(ra) # 67c6 <exit>
      printf("%s: fork failed\n", s);
    51aa:	85d2                	mv	a1,s4
    51ac:	00002517          	auipc	a0,0x2
    51b0:	44450513          	addi	a0,a0,1092 # 75f0 <malloc+0x9c4>
    51b4:	00002097          	auipc	ra,0x2
    51b8:	9ba080e7          	jalr	-1606(ra) # 6b6e <printf>
      exit(1,"");
    51bc:	00003597          	auipc	a1,0x3
    51c0:	19c58593          	addi	a1,a1,412 # 8358 <malloc+0x172c>
    51c4:	4505                	li	a0,1
    51c6:	00001097          	auipc	ra,0x1
    51ca:	600080e7          	jalr	1536(ra) # 67c6 <exit>
        printf("%s: wait wrong pid\n", s);
    51ce:	85d2                	mv	a1,s4
    51d0:	00002517          	auipc	a0,0x2
    51d4:	5a850513          	addi	a0,a0,1448 # 7778 <malloc+0xb4c>
    51d8:	00002097          	auipc	ra,0x2
    51dc:	996080e7          	jalr	-1642(ra) # 6b6e <printf>
        exit(1,"");
    51e0:	00003597          	auipc	a1,0x3
    51e4:	17858593          	addi	a1,a1,376 # 8358 <malloc+0x172c>
    51e8:	4505                	li	a0,1
    51ea:	00001097          	auipc	ra,0x1
    51ee:	5dc080e7          	jalr	1500(ra) # 67c6 <exit>
      int pid2 = fork();
    51f2:	00001097          	auipc	ra,0x1
    51f6:	5cc080e7          	jalr	1484(ra) # 67be <fork>
      if(pid2 < 0){
    51fa:	00054b63          	bltz	a0,5210 <reparent+0xc8>
      exit(0,"");
    51fe:	00003597          	auipc	a1,0x3
    5202:	15a58593          	addi	a1,a1,346 # 8358 <malloc+0x172c>
    5206:	4501                	li	a0,0
    5208:	00001097          	auipc	ra,0x1
    520c:	5be080e7          	jalr	1470(ra) # 67c6 <exit>
        kill(master_pid);
    5210:	8556                	mv	a0,s5
    5212:	00001097          	auipc	ra,0x1
    5216:	5e4080e7          	jalr	1508(ra) # 67f6 <kill>
        exit(1,"");
    521a:	00003597          	auipc	a1,0x3
    521e:	13e58593          	addi	a1,a1,318 # 8358 <malloc+0x172c>
    5222:	4505                	li	a0,1
    5224:	00001097          	auipc	ra,0x1
    5228:	5a2080e7          	jalr	1442(ra) # 67c6 <exit>

000000000000522c <sbrkfail>:
{
    522c:	7119                	addi	sp,sp,-128
    522e:	fc86                	sd	ra,120(sp)
    5230:	f8a2                	sd	s0,112(sp)
    5232:	f4a6                	sd	s1,104(sp)
    5234:	f0ca                	sd	s2,96(sp)
    5236:	ecce                	sd	s3,88(sp)
    5238:	e8d2                	sd	s4,80(sp)
    523a:	e4d6                	sd	s5,72(sp)
    523c:	e0da                	sd	s6,64(sp)
    523e:	0100                	addi	s0,sp,128
    5240:	8aaa                	mv	s5,a0
  if(pipe(fds) != 0){
    5242:	fb040513          	addi	a0,s0,-80
    5246:	00001097          	auipc	ra,0x1
    524a:	590080e7          	jalr	1424(ra) # 67d6 <pipe>
    524e:	e901                	bnez	a0,525e <sbrkfail+0x32>
    5250:	f8040493          	addi	s1,s0,-128
    5254:	fa840993          	addi	s3,s0,-88
    5258:	8926                	mv	s2,s1
    if(pids[i] != -1)
    525a:	5a7d                	li	s4,-1
    525c:	a0a5                	j	52c4 <sbrkfail+0x98>
    printf("%s: pipe() failed\n", s);
    525e:	85d6                	mv	a1,s5
    5260:	00002517          	auipc	a0,0x2
    5264:	49850513          	addi	a0,a0,1176 # 76f8 <malloc+0xacc>
    5268:	00002097          	auipc	ra,0x2
    526c:	906080e7          	jalr	-1786(ra) # 6b6e <printf>
    exit(1,"");
    5270:	00003597          	auipc	a1,0x3
    5274:	0e858593          	addi	a1,a1,232 # 8358 <malloc+0x172c>
    5278:	4505                	li	a0,1
    527a:	00001097          	auipc	ra,0x1
    527e:	54c080e7          	jalr	1356(ra) # 67c6 <exit>
      sbrk(BIG - (uint64)sbrk(0));
    5282:	00001097          	auipc	ra,0x1
    5286:	5cc080e7          	jalr	1484(ra) # 684e <sbrk>
    528a:	064007b7          	lui	a5,0x6400
    528e:	40a7853b          	subw	a0,a5,a0
    5292:	00001097          	auipc	ra,0x1
    5296:	5bc080e7          	jalr	1468(ra) # 684e <sbrk>
      write(fds[1], "x", 1);
    529a:	4605                	li	a2,1
    529c:	00002597          	auipc	a1,0x2
    52a0:	b3c58593          	addi	a1,a1,-1220 # 6dd8 <malloc+0x1ac>
    52a4:	fb442503          	lw	a0,-76(s0)
    52a8:	00001097          	auipc	ra,0x1
    52ac:	53e080e7          	jalr	1342(ra) # 67e6 <write>
      for(;;) sleep(1000);
    52b0:	3e800513          	li	a0,1000
    52b4:	00001097          	auipc	ra,0x1
    52b8:	5a2080e7          	jalr	1442(ra) # 6856 <sleep>
    52bc:	bfd5                	j	52b0 <sbrkfail+0x84>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    52be:	0911                	addi	s2,s2,4
    52c0:	03390563          	beq	s2,s3,52ea <sbrkfail+0xbe>
    if((pids[i] = fork()) == 0){
    52c4:	00001097          	auipc	ra,0x1
    52c8:	4fa080e7          	jalr	1274(ra) # 67be <fork>
    52cc:	00a92023          	sw	a0,0(s2)
    52d0:	d94d                	beqz	a0,5282 <sbrkfail+0x56>
    if(pids[i] != -1)
    52d2:	ff4506e3          	beq	a0,s4,52be <sbrkfail+0x92>
      read(fds[0], &scratch, 1);
    52d6:	4605                	li	a2,1
    52d8:	faf40593          	addi	a1,s0,-81
    52dc:	fb042503          	lw	a0,-80(s0)
    52e0:	00001097          	auipc	ra,0x1
    52e4:	4fe080e7          	jalr	1278(ra) # 67de <read>
    52e8:	bfd9                	j	52be <sbrkfail+0x92>
  c = sbrk(PGSIZE);
    52ea:	6505                	lui	a0,0x1
    52ec:	00001097          	auipc	ra,0x1
    52f0:	562080e7          	jalr	1378(ra) # 684e <sbrk>
    52f4:	8b2a                	mv	s6,a0
    if(pids[i] == -1)
    52f6:	597d                	li	s2,-1
    wait(0,"");
    52f8:	00003a17          	auipc	s4,0x3
    52fc:	060a0a13          	addi	s4,s4,96 # 8358 <malloc+0x172c>
    5300:	a021                	j	5308 <sbrkfail+0xdc>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    5302:	0491                	addi	s1,s1,4
    5304:	03348063          	beq	s1,s3,5324 <sbrkfail+0xf8>
    if(pids[i] == -1)
    5308:	4088                	lw	a0,0(s1)
    530a:	ff250ce3          	beq	a0,s2,5302 <sbrkfail+0xd6>
    kill(pids[i]);
    530e:	00001097          	auipc	ra,0x1
    5312:	4e8080e7          	jalr	1256(ra) # 67f6 <kill>
    wait(0,"");
    5316:	85d2                	mv	a1,s4
    5318:	4501                	li	a0,0
    531a:	00001097          	auipc	ra,0x1
    531e:	4b4080e7          	jalr	1204(ra) # 67ce <wait>
    5322:	b7c5                	j	5302 <sbrkfail+0xd6>
  if(c == (char*)0xffffffffffffffffL){
    5324:	57fd                	li	a5,-1
    5326:	04fb0663          	beq	s6,a5,5372 <sbrkfail+0x146>
  pid = fork();
    532a:	00001097          	auipc	ra,0x1
    532e:	494080e7          	jalr	1172(ra) # 67be <fork>
    5332:	84aa                	mv	s1,a0
  if(pid < 0){
    5334:	06054163          	bltz	a0,5396 <sbrkfail+0x16a>
  if(pid == 0){
    5338:	c149                	beqz	a0,53ba <sbrkfail+0x18e>
  wait(&xstatus,"");
    533a:	00003597          	auipc	a1,0x3
    533e:	01e58593          	addi	a1,a1,30 # 8358 <malloc+0x172c>
    5342:	fbc40513          	addi	a0,s0,-68
    5346:	00001097          	auipc	ra,0x1
    534a:	488080e7          	jalr	1160(ra) # 67ce <wait>
  if(xstatus != -1 && xstatus != 2)
    534e:	fbc42783          	lw	a5,-68(s0)
    5352:	577d                	li	a4,-1
    5354:	00e78563          	beq	a5,a4,535e <sbrkfail+0x132>
    5358:	4709                	li	a4,2
    535a:	0ae79a63          	bne	a5,a4,540e <sbrkfail+0x1e2>
}
    535e:	70e6                	ld	ra,120(sp)
    5360:	7446                	ld	s0,112(sp)
    5362:	74a6                	ld	s1,104(sp)
    5364:	7906                	ld	s2,96(sp)
    5366:	69e6                	ld	s3,88(sp)
    5368:	6a46                	ld	s4,80(sp)
    536a:	6aa6                	ld	s5,72(sp)
    536c:	6b06                	ld	s6,64(sp)
    536e:	6109                	addi	sp,sp,128
    5370:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    5372:	85d6                	mv	a1,s5
    5374:	00003517          	auipc	a0,0x3
    5378:	5dc50513          	addi	a0,a0,1500 # 8950 <malloc+0x1d24>
    537c:	00001097          	auipc	ra,0x1
    5380:	7f2080e7          	jalr	2034(ra) # 6b6e <printf>
    exit(1,"");
    5384:	00003597          	auipc	a1,0x3
    5388:	fd458593          	addi	a1,a1,-44 # 8358 <malloc+0x172c>
    538c:	4505                	li	a0,1
    538e:	00001097          	auipc	ra,0x1
    5392:	438080e7          	jalr	1080(ra) # 67c6 <exit>
    printf("%s: fork failed\n", s);
    5396:	85d6                	mv	a1,s5
    5398:	00002517          	auipc	a0,0x2
    539c:	25850513          	addi	a0,a0,600 # 75f0 <malloc+0x9c4>
    53a0:	00001097          	auipc	ra,0x1
    53a4:	7ce080e7          	jalr	1998(ra) # 6b6e <printf>
    exit(1,"");
    53a8:	00003597          	auipc	a1,0x3
    53ac:	fb058593          	addi	a1,a1,-80 # 8358 <malloc+0x172c>
    53b0:	4505                	li	a0,1
    53b2:	00001097          	auipc	ra,0x1
    53b6:	414080e7          	jalr	1044(ra) # 67c6 <exit>
    a = sbrk(0);
    53ba:	4501                	li	a0,0
    53bc:	00001097          	auipc	ra,0x1
    53c0:	492080e7          	jalr	1170(ra) # 684e <sbrk>
    53c4:	892a                	mv	s2,a0
    sbrk(10*BIG);
    53c6:	3e800537          	lui	a0,0x3e800
    53ca:	00001097          	auipc	ra,0x1
    53ce:	484080e7          	jalr	1156(ra) # 684e <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    53d2:	87ca                	mv	a5,s2
    53d4:	3e800737          	lui	a4,0x3e800
    53d8:	993a                	add	s2,s2,a4
    53da:	6705                	lui	a4,0x1
      n += *(a+i);
    53dc:	0007c683          	lbu	a3,0(a5) # 6400000 <base+0x63ef388>
    53e0:	9cb5                	addw	s1,s1,a3
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    53e2:	97ba                	add	a5,a5,a4
    53e4:	ff279ce3          	bne	a5,s2,53dc <sbrkfail+0x1b0>
    printf("%s: allocate a lot of memory succeeded %d\n", s, n);
    53e8:	8626                	mv	a2,s1
    53ea:	85d6                	mv	a1,s5
    53ec:	00003517          	auipc	a0,0x3
    53f0:	58450513          	addi	a0,a0,1412 # 8970 <malloc+0x1d44>
    53f4:	00001097          	auipc	ra,0x1
    53f8:	77a080e7          	jalr	1914(ra) # 6b6e <printf>
    exit(1,"");
    53fc:	00003597          	auipc	a1,0x3
    5400:	f5c58593          	addi	a1,a1,-164 # 8358 <malloc+0x172c>
    5404:	4505                	li	a0,1
    5406:	00001097          	auipc	ra,0x1
    540a:	3c0080e7          	jalr	960(ra) # 67c6 <exit>
    exit(1,"");
    540e:	00003597          	auipc	a1,0x3
    5412:	f4a58593          	addi	a1,a1,-182 # 8358 <malloc+0x172c>
    5416:	4505                	li	a0,1
    5418:	00001097          	auipc	ra,0x1
    541c:	3ae080e7          	jalr	942(ra) # 67c6 <exit>

0000000000005420 <mem>:
{
    5420:	7139                	addi	sp,sp,-64
    5422:	fc06                	sd	ra,56(sp)
    5424:	f822                	sd	s0,48(sp)
    5426:	f426                	sd	s1,40(sp)
    5428:	f04a                	sd	s2,32(sp)
    542a:	ec4e                	sd	s3,24(sp)
    542c:	0080                	addi	s0,sp,64
    542e:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    5430:	00001097          	auipc	ra,0x1
    5434:	38e080e7          	jalr	910(ra) # 67be <fork>
    m1 = 0;
    5438:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    543a:	6909                	lui	s2,0x2
    543c:	71190913          	addi	s2,s2,1809 # 2711 <MAXVAplus+0x81>
  if((pid = fork()) == 0){
    5440:	c915                	beqz	a0,5474 <mem+0x54>
    wait(&xstatus,"");
    5442:	00003597          	auipc	a1,0x3
    5446:	f1658593          	addi	a1,a1,-234 # 8358 <malloc+0x172c>
    544a:	fcc40513          	addi	a0,s0,-52
    544e:	00001097          	auipc	ra,0x1
    5452:	380080e7          	jalr	896(ra) # 67ce <wait>
    if(xstatus == -1){
    5456:	fcc42503          	lw	a0,-52(s0)
    545a:	57fd                	li	a5,-1
    545c:	06f50f63          	beq	a0,a5,54da <mem+0xba>
    exit(xstatus,"");
    5460:	00003597          	auipc	a1,0x3
    5464:	ef858593          	addi	a1,a1,-264 # 8358 <malloc+0x172c>
    5468:	00001097          	auipc	ra,0x1
    546c:	35e080e7          	jalr	862(ra) # 67c6 <exit>
      *(char**)m2 = m1;
    5470:	e104                	sd	s1,0(a0)
      m1 = m2;
    5472:	84aa                	mv	s1,a0
    while((m2 = malloc(10001)) != 0){
    5474:	854a                	mv	a0,s2
    5476:	00001097          	auipc	ra,0x1
    547a:	7b6080e7          	jalr	1974(ra) # 6c2c <malloc>
    547e:	f96d                	bnez	a0,5470 <mem+0x50>
    while(m1){
    5480:	c881                	beqz	s1,5490 <mem+0x70>
      m2 = *(char**)m1;
    5482:	8526                	mv	a0,s1
    5484:	6084                	ld	s1,0(s1)
      free(m1);
    5486:	00001097          	auipc	ra,0x1
    548a:	71e080e7          	jalr	1822(ra) # 6ba4 <free>
    while(m1){
    548e:	f8f5                	bnez	s1,5482 <mem+0x62>
    m1 = malloc(1024*20);
    5490:	6515                	lui	a0,0x5
    5492:	00001097          	auipc	ra,0x1
    5496:	79a080e7          	jalr	1946(ra) # 6c2c <malloc>
    if(m1 == 0){
    549a:	cd11                	beqz	a0,54b6 <mem+0x96>
    free(m1);
    549c:	00001097          	auipc	ra,0x1
    54a0:	708080e7          	jalr	1800(ra) # 6ba4 <free>
    exit(0,"");
    54a4:	00003597          	auipc	a1,0x3
    54a8:	eb458593          	addi	a1,a1,-332 # 8358 <malloc+0x172c>
    54ac:	4501                	li	a0,0
    54ae:	00001097          	auipc	ra,0x1
    54b2:	318080e7          	jalr	792(ra) # 67c6 <exit>
      printf("couldn't allocate mem?!!\n", s);
    54b6:	85ce                	mv	a1,s3
    54b8:	00003517          	auipc	a0,0x3
    54bc:	4e850513          	addi	a0,a0,1256 # 89a0 <malloc+0x1d74>
    54c0:	00001097          	auipc	ra,0x1
    54c4:	6ae080e7          	jalr	1710(ra) # 6b6e <printf>
      exit(1,"");
    54c8:	00003597          	auipc	a1,0x3
    54cc:	e9058593          	addi	a1,a1,-368 # 8358 <malloc+0x172c>
    54d0:	4505                	li	a0,1
    54d2:	00001097          	auipc	ra,0x1
    54d6:	2f4080e7          	jalr	756(ra) # 67c6 <exit>
      exit(0,"");
    54da:	00003597          	auipc	a1,0x3
    54de:	e7e58593          	addi	a1,a1,-386 # 8358 <malloc+0x172c>
    54e2:	4501                	li	a0,0
    54e4:	00001097          	auipc	ra,0x1
    54e8:	2e2080e7          	jalr	738(ra) # 67c6 <exit>

00000000000054ec <sharedfd>:
{
    54ec:	7159                	addi	sp,sp,-112
    54ee:	f486                	sd	ra,104(sp)
    54f0:	f0a2                	sd	s0,96(sp)
    54f2:	eca6                	sd	s1,88(sp)
    54f4:	e8ca                	sd	s2,80(sp)
    54f6:	e4ce                	sd	s3,72(sp)
    54f8:	e0d2                	sd	s4,64(sp)
    54fa:	fc56                	sd	s5,56(sp)
    54fc:	f85a                	sd	s6,48(sp)
    54fe:	f45e                	sd	s7,40(sp)
    5500:	1880                	addi	s0,sp,112
    5502:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    5504:	00003517          	auipc	a0,0x3
    5508:	4bc50513          	addi	a0,a0,1212 # 89c0 <malloc+0x1d94>
    550c:	00001097          	auipc	ra,0x1
    5510:	30a080e7          	jalr	778(ra) # 6816 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    5514:	20200593          	li	a1,514
    5518:	00003517          	auipc	a0,0x3
    551c:	4a850513          	addi	a0,a0,1192 # 89c0 <malloc+0x1d94>
    5520:	00001097          	auipc	ra,0x1
    5524:	2e6080e7          	jalr	742(ra) # 6806 <open>
  if(fd < 0){
    5528:	04054e63          	bltz	a0,5584 <sharedfd+0x98>
    552c:	892a                	mv	s2,a0
  pid = fork();
    552e:	00001097          	auipc	ra,0x1
    5532:	290080e7          	jalr	656(ra) # 67be <fork>
    5536:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    5538:	06300593          	li	a1,99
    553c:	c119                	beqz	a0,5542 <sharedfd+0x56>
    553e:	07000593          	li	a1,112
    5542:	4629                	li	a2,10
    5544:	fa040513          	addi	a0,s0,-96
    5548:	00001097          	auipc	ra,0x1
    554c:	082080e7          	jalr	130(ra) # 65ca <memset>
    5550:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    5554:	4629                	li	a2,10
    5556:	fa040593          	addi	a1,s0,-96
    555a:	854a                	mv	a0,s2
    555c:	00001097          	auipc	ra,0x1
    5560:	28a080e7          	jalr	650(ra) # 67e6 <write>
    5564:	47a9                	li	a5,10
    5566:	04f51163          	bne	a0,a5,55a8 <sharedfd+0xbc>
  for(i = 0; i < N; i++){
    556a:	34fd                	addiw	s1,s1,-1
    556c:	f4e5                	bnez	s1,5554 <sharedfd+0x68>
  if(pid == 0) {
    556e:	04099f63          	bnez	s3,55cc <sharedfd+0xe0>
    exit(0,"");
    5572:	00003597          	auipc	a1,0x3
    5576:	de658593          	addi	a1,a1,-538 # 8358 <malloc+0x172c>
    557a:	4501                	li	a0,0
    557c:	00001097          	auipc	ra,0x1
    5580:	24a080e7          	jalr	586(ra) # 67c6 <exit>
    printf("%s: cannot open sharedfd for writing", s);
    5584:	85d2                	mv	a1,s4
    5586:	00003517          	auipc	a0,0x3
    558a:	44a50513          	addi	a0,a0,1098 # 89d0 <malloc+0x1da4>
    558e:	00001097          	auipc	ra,0x1
    5592:	5e0080e7          	jalr	1504(ra) # 6b6e <printf>
    exit(1,"");
    5596:	00003597          	auipc	a1,0x3
    559a:	dc258593          	addi	a1,a1,-574 # 8358 <malloc+0x172c>
    559e:	4505                	li	a0,1
    55a0:	00001097          	auipc	ra,0x1
    55a4:	226080e7          	jalr	550(ra) # 67c6 <exit>
      printf("%s: write sharedfd failed\n", s);
    55a8:	85d2                	mv	a1,s4
    55aa:	00003517          	auipc	a0,0x3
    55ae:	44e50513          	addi	a0,a0,1102 # 89f8 <malloc+0x1dcc>
    55b2:	00001097          	auipc	ra,0x1
    55b6:	5bc080e7          	jalr	1468(ra) # 6b6e <printf>
      exit(1,"");
    55ba:	00003597          	auipc	a1,0x3
    55be:	d9e58593          	addi	a1,a1,-610 # 8358 <malloc+0x172c>
    55c2:	4505                	li	a0,1
    55c4:	00001097          	auipc	ra,0x1
    55c8:	202080e7          	jalr	514(ra) # 67c6 <exit>
    wait(&xstatus,"");
    55cc:	00003597          	auipc	a1,0x3
    55d0:	d8c58593          	addi	a1,a1,-628 # 8358 <malloc+0x172c>
    55d4:	f9c40513          	addi	a0,s0,-100
    55d8:	00001097          	auipc	ra,0x1
    55dc:	1f6080e7          	jalr	502(ra) # 67ce <wait>
    if(xstatus != 0)
    55e0:	f9c42983          	lw	s3,-100(s0)
    55e4:	00098b63          	beqz	s3,55fa <sharedfd+0x10e>
      exit(xstatus,"");
    55e8:	00003597          	auipc	a1,0x3
    55ec:	d7058593          	addi	a1,a1,-656 # 8358 <malloc+0x172c>
    55f0:	854e                	mv	a0,s3
    55f2:	00001097          	auipc	ra,0x1
    55f6:	1d4080e7          	jalr	468(ra) # 67c6 <exit>
  close(fd);
    55fa:	854a                	mv	a0,s2
    55fc:	00001097          	auipc	ra,0x1
    5600:	1f2080e7          	jalr	498(ra) # 67ee <close>
  fd = open("sharedfd", 0);
    5604:	4581                	li	a1,0
    5606:	00003517          	auipc	a0,0x3
    560a:	3ba50513          	addi	a0,a0,954 # 89c0 <malloc+0x1d94>
    560e:	00001097          	auipc	ra,0x1
    5612:	1f8080e7          	jalr	504(ra) # 6806 <open>
    5616:	8baa                	mv	s7,a0
  nc = np = 0;
    5618:	8ace                	mv	s5,s3
  if(fd < 0){
    561a:	02054563          	bltz	a0,5644 <sharedfd+0x158>
    561e:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    5622:	06300493          	li	s1,99
      if(buf[i] == 'p')
    5626:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    562a:	4629                	li	a2,10
    562c:	fa040593          	addi	a1,s0,-96
    5630:	855e                	mv	a0,s7
    5632:	00001097          	auipc	ra,0x1
    5636:	1ac080e7          	jalr	428(ra) # 67de <read>
    563a:	04a05363          	blez	a0,5680 <sharedfd+0x194>
    563e:	fa040793          	addi	a5,s0,-96
    5642:	a03d                	j	5670 <sharedfd+0x184>
    printf("%s: cannot open sharedfd for reading\n", s);
    5644:	85d2                	mv	a1,s4
    5646:	00003517          	auipc	a0,0x3
    564a:	3d250513          	addi	a0,a0,978 # 8a18 <malloc+0x1dec>
    564e:	00001097          	auipc	ra,0x1
    5652:	520080e7          	jalr	1312(ra) # 6b6e <printf>
    exit(1,"");
    5656:	00003597          	auipc	a1,0x3
    565a:	d0258593          	addi	a1,a1,-766 # 8358 <malloc+0x172c>
    565e:	4505                	li	a0,1
    5660:	00001097          	auipc	ra,0x1
    5664:	166080e7          	jalr	358(ra) # 67c6 <exit>
        nc++;
    5668:	2985                	addiw	s3,s3,1
    for(i = 0; i < sizeof(buf); i++){
    566a:	0785                	addi	a5,a5,1
    566c:	fb278fe3          	beq	a5,s2,562a <sharedfd+0x13e>
      if(buf[i] == 'c')
    5670:	0007c703          	lbu	a4,0(a5)
    5674:	fe970ae3          	beq	a4,s1,5668 <sharedfd+0x17c>
      if(buf[i] == 'p')
    5678:	ff6719e3          	bne	a4,s6,566a <sharedfd+0x17e>
        np++;
    567c:	2a85                	addiw	s5,s5,1
    567e:	b7f5                	j	566a <sharedfd+0x17e>
  close(fd);
    5680:	855e                	mv	a0,s7
    5682:	00001097          	auipc	ra,0x1
    5686:	16c080e7          	jalr	364(ra) # 67ee <close>
  unlink("sharedfd");
    568a:	00003517          	auipc	a0,0x3
    568e:	33650513          	addi	a0,a0,822 # 89c0 <malloc+0x1d94>
    5692:	00001097          	auipc	ra,0x1
    5696:	184080e7          	jalr	388(ra) # 6816 <unlink>
  if(nc == N*SZ && np == N*SZ){
    569a:	6789                	lui	a5,0x2
    569c:	71078793          	addi	a5,a5,1808 # 2710 <MAXVAplus+0x80>
    56a0:	00f99763          	bne	s3,a5,56ae <sharedfd+0x1c2>
    56a4:	6789                	lui	a5,0x2
    56a6:	71078793          	addi	a5,a5,1808 # 2710 <MAXVAplus+0x80>
    56aa:	02fa8463          	beq	s5,a5,56d2 <sharedfd+0x1e6>
    printf("%s: nc/np test fails\n", s);
    56ae:	85d2                	mv	a1,s4
    56b0:	00003517          	auipc	a0,0x3
    56b4:	39050513          	addi	a0,a0,912 # 8a40 <malloc+0x1e14>
    56b8:	00001097          	auipc	ra,0x1
    56bc:	4b6080e7          	jalr	1206(ra) # 6b6e <printf>
    exit(1,"");
    56c0:	00003597          	auipc	a1,0x3
    56c4:	c9858593          	addi	a1,a1,-872 # 8358 <malloc+0x172c>
    56c8:	4505                	li	a0,1
    56ca:	00001097          	auipc	ra,0x1
    56ce:	0fc080e7          	jalr	252(ra) # 67c6 <exit>
    exit(0,"");
    56d2:	00003597          	auipc	a1,0x3
    56d6:	c8658593          	addi	a1,a1,-890 # 8358 <malloc+0x172c>
    56da:	4501                	li	a0,0
    56dc:	00001097          	auipc	ra,0x1
    56e0:	0ea080e7          	jalr	234(ra) # 67c6 <exit>

00000000000056e4 <fourfiles>:
{
    56e4:	7171                	addi	sp,sp,-176
    56e6:	f506                	sd	ra,168(sp)
    56e8:	f122                	sd	s0,160(sp)
    56ea:	ed26                	sd	s1,152(sp)
    56ec:	e94a                	sd	s2,144(sp)
    56ee:	e54e                	sd	s3,136(sp)
    56f0:	e152                	sd	s4,128(sp)
    56f2:	fcd6                	sd	s5,120(sp)
    56f4:	f8da                	sd	s6,112(sp)
    56f6:	f4de                	sd	s7,104(sp)
    56f8:	f0e2                	sd	s8,96(sp)
    56fa:	ece6                	sd	s9,88(sp)
    56fc:	e8ea                	sd	s10,80(sp)
    56fe:	e4ee                	sd	s11,72(sp)
    5700:	1900                	addi	s0,sp,176
    5702:	f4a43c23          	sd	a0,-168(s0)
  char *names[] = { "f0", "f1", "f2", "f3" };
    5706:	00001797          	auipc	a5,0x1
    570a:	60a78793          	addi	a5,a5,1546 # 6d10 <malloc+0xe4>
    570e:	f6f43823          	sd	a5,-144(s0)
    5712:	00001797          	auipc	a5,0x1
    5716:	60678793          	addi	a5,a5,1542 # 6d18 <malloc+0xec>
    571a:	f6f43c23          	sd	a5,-136(s0)
    571e:	00001797          	auipc	a5,0x1
    5722:	60278793          	addi	a5,a5,1538 # 6d20 <malloc+0xf4>
    5726:	f8f43023          	sd	a5,-128(s0)
    572a:	00001797          	auipc	a5,0x1
    572e:	5fe78793          	addi	a5,a5,1534 # 6d28 <malloc+0xfc>
    5732:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    5736:	f7040c13          	addi	s8,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    573a:	8962                	mv	s2,s8
  for(pi = 0; pi < NCHILD; pi++){
    573c:	4481                	li	s1,0
    573e:	4a11                	li	s4,4
    fname = names[pi];
    5740:	00093983          	ld	s3,0(s2)
    unlink(fname);
    5744:	854e                	mv	a0,s3
    5746:	00001097          	auipc	ra,0x1
    574a:	0d0080e7          	jalr	208(ra) # 6816 <unlink>
    pid = fork();
    574e:	00001097          	auipc	ra,0x1
    5752:	070080e7          	jalr	112(ra) # 67be <fork>
    if(pid < 0){
    5756:	04054963          	bltz	a0,57a8 <fourfiles+0xc4>
    if(pid == 0){
    575a:	c935                	beqz	a0,57ce <fourfiles+0xea>
  for(pi = 0; pi < NCHILD; pi++){
    575c:	2485                	addiw	s1,s1,1
    575e:	0921                	addi	s2,s2,8
    5760:	ff4490e3          	bne	s1,s4,5740 <fourfiles+0x5c>
    5764:	4491                	li	s1,4
    wait(&xstatus,"");
    5766:	00003917          	auipc	s2,0x3
    576a:	bf290913          	addi	s2,s2,-1038 # 8358 <malloc+0x172c>
    576e:	85ca                	mv	a1,s2
    5770:	f6c40513          	addi	a0,s0,-148
    5774:	00001097          	auipc	ra,0x1
    5778:	05a080e7          	jalr	90(ra) # 67ce <wait>
    if(xstatus != 0)
    577c:	f6c42b03          	lw	s6,-148(s0)
    5780:	0e0b1e63          	bnez	s6,587c <fourfiles+0x198>
  for(pi = 0; pi < NCHILD; pi++){
    5784:	34fd                	addiw	s1,s1,-1
    5786:	f4e5                	bnez	s1,576e <fourfiles+0x8a>
    5788:	03000b93          	li	s7,48
    while((n = read(fd, buf, sizeof(buf))) > 0){
    578c:	00008a17          	auipc	s4,0x8
    5790:	4eca0a13          	addi	s4,s4,1260 # dc78 <buf>
    5794:	00008a97          	auipc	s5,0x8
    5798:	4e5a8a93          	addi	s5,s5,1253 # dc79 <buf+0x1>
    if(total != N*SZ){
    579c:	6d85                	lui	s11,0x1
    579e:	770d8d93          	addi	s11,s11,1904 # 1770 <copyinstr2+0x1fe>
  for(i = 0; i < NCHILD; i++){
    57a2:	03400d13          	li	s10,52
    57a6:	a29d                	j	590c <fourfiles+0x228>
      printf("fork failed\n", s);
    57a8:	f5843583          	ld	a1,-168(s0)
    57ac:	00002517          	auipc	a0,0x2
    57b0:	24c50513          	addi	a0,a0,588 # 79f8 <malloc+0xdcc>
    57b4:	00001097          	auipc	ra,0x1
    57b8:	3ba080e7          	jalr	954(ra) # 6b6e <printf>
      exit(1,"");
    57bc:	00003597          	auipc	a1,0x3
    57c0:	b9c58593          	addi	a1,a1,-1124 # 8358 <malloc+0x172c>
    57c4:	4505                	li	a0,1
    57c6:	00001097          	auipc	ra,0x1
    57ca:	000080e7          	jalr	ra # 67c6 <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    57ce:	20200593          	li	a1,514
    57d2:	854e                	mv	a0,s3
    57d4:	00001097          	auipc	ra,0x1
    57d8:	032080e7          	jalr	50(ra) # 6806 <open>
    57dc:	892a                	mv	s2,a0
      if(fd < 0){
    57de:	04054b63          	bltz	a0,5834 <fourfiles+0x150>
      memset(buf, '0'+pi, SZ);
    57e2:	1f400613          	li	a2,500
    57e6:	0304859b          	addiw	a1,s1,48
    57ea:	00008517          	auipc	a0,0x8
    57ee:	48e50513          	addi	a0,a0,1166 # dc78 <buf>
    57f2:	00001097          	auipc	ra,0x1
    57f6:	dd8080e7          	jalr	-552(ra) # 65ca <memset>
    57fa:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    57fc:	00008997          	auipc	s3,0x8
    5800:	47c98993          	addi	s3,s3,1148 # dc78 <buf>
    5804:	1f400613          	li	a2,500
    5808:	85ce                	mv	a1,s3
    580a:	854a                	mv	a0,s2
    580c:	00001097          	auipc	ra,0x1
    5810:	fda080e7          	jalr	-38(ra) # 67e6 <write>
    5814:	85aa                	mv	a1,a0
    5816:	1f400793          	li	a5,500
    581a:	04f51063          	bne	a0,a5,585a <fourfiles+0x176>
      for(i = 0; i < N; i++){
    581e:	34fd                	addiw	s1,s1,-1
    5820:	f0f5                	bnez	s1,5804 <fourfiles+0x120>
      exit(0,"");
    5822:	00003597          	auipc	a1,0x3
    5826:	b3658593          	addi	a1,a1,-1226 # 8358 <malloc+0x172c>
    582a:	4501                	li	a0,0
    582c:	00001097          	auipc	ra,0x1
    5830:	f9a080e7          	jalr	-102(ra) # 67c6 <exit>
        printf("create failed\n", s);
    5834:	f5843583          	ld	a1,-168(s0)
    5838:	00003517          	auipc	a0,0x3
    583c:	22050513          	addi	a0,a0,544 # 8a58 <malloc+0x1e2c>
    5840:	00001097          	auipc	ra,0x1
    5844:	32e080e7          	jalr	814(ra) # 6b6e <printf>
        exit(1,"");
    5848:	00003597          	auipc	a1,0x3
    584c:	b1058593          	addi	a1,a1,-1264 # 8358 <malloc+0x172c>
    5850:	4505                	li	a0,1
    5852:	00001097          	auipc	ra,0x1
    5856:	f74080e7          	jalr	-140(ra) # 67c6 <exit>
          printf("write failed %d\n", n);
    585a:	00003517          	auipc	a0,0x3
    585e:	20e50513          	addi	a0,a0,526 # 8a68 <malloc+0x1e3c>
    5862:	00001097          	auipc	ra,0x1
    5866:	30c080e7          	jalr	780(ra) # 6b6e <printf>
          exit(1,"");
    586a:	00003597          	auipc	a1,0x3
    586e:	aee58593          	addi	a1,a1,-1298 # 8358 <malloc+0x172c>
    5872:	4505                	li	a0,1
    5874:	00001097          	auipc	ra,0x1
    5878:	f52080e7          	jalr	-174(ra) # 67c6 <exit>
      exit(xstatus,"");
    587c:	00003597          	auipc	a1,0x3
    5880:	adc58593          	addi	a1,a1,-1316 # 8358 <malloc+0x172c>
    5884:	855a                	mv	a0,s6
    5886:	00001097          	auipc	ra,0x1
    588a:	f40080e7          	jalr	-192(ra) # 67c6 <exit>
          printf("wrong char\n", s);
    588e:	f5843583          	ld	a1,-168(s0)
    5892:	00003517          	auipc	a0,0x3
    5896:	1ee50513          	addi	a0,a0,494 # 8a80 <malloc+0x1e54>
    589a:	00001097          	auipc	ra,0x1
    589e:	2d4080e7          	jalr	724(ra) # 6b6e <printf>
          exit(1,"");
    58a2:	00003597          	auipc	a1,0x3
    58a6:	ab658593          	addi	a1,a1,-1354 # 8358 <malloc+0x172c>
    58aa:	4505                	li	a0,1
    58ac:	00001097          	auipc	ra,0x1
    58b0:	f1a080e7          	jalr	-230(ra) # 67c6 <exit>
      total += n;
    58b4:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    58b8:	660d                	lui	a2,0x3
    58ba:	85d2                	mv	a1,s4
    58bc:	854e                	mv	a0,s3
    58be:	00001097          	auipc	ra,0x1
    58c2:	f20080e7          	jalr	-224(ra) # 67de <read>
    58c6:	02a05363          	blez	a0,58ec <fourfiles+0x208>
    58ca:	00008797          	auipc	a5,0x8
    58ce:	3ae78793          	addi	a5,a5,942 # dc78 <buf>
    58d2:	fff5069b          	addiw	a3,a0,-1
    58d6:	1682                	slli	a3,a3,0x20
    58d8:	9281                	srli	a3,a3,0x20
    58da:	96d6                	add	a3,a3,s5
        if(buf[j] != '0'+i){
    58dc:	0007c703          	lbu	a4,0(a5)
    58e0:	fa9717e3          	bne	a4,s1,588e <fourfiles+0x1aa>
      for(j = 0; j < n; j++){
    58e4:	0785                	addi	a5,a5,1
    58e6:	fed79be3          	bne	a5,a3,58dc <fourfiles+0x1f8>
    58ea:	b7e9                	j	58b4 <fourfiles+0x1d0>
    close(fd);
    58ec:	854e                	mv	a0,s3
    58ee:	00001097          	auipc	ra,0x1
    58f2:	f00080e7          	jalr	-256(ra) # 67ee <close>
    if(total != N*SZ){
    58f6:	03b91863          	bne	s2,s11,5926 <fourfiles+0x242>
    unlink(fname);
    58fa:	8566                	mv	a0,s9
    58fc:	00001097          	auipc	ra,0x1
    5900:	f1a080e7          	jalr	-230(ra) # 6816 <unlink>
  for(i = 0; i < NCHILD; i++){
    5904:	0c21                	addi	s8,s8,8
    5906:	2b85                	addiw	s7,s7,1
    5908:	05ab8163          	beq	s7,s10,594a <fourfiles+0x266>
    fname = names[i];
    590c:	000c3c83          	ld	s9,0(s8)
    fd = open(fname, 0);
    5910:	4581                	li	a1,0
    5912:	8566                	mv	a0,s9
    5914:	00001097          	auipc	ra,0x1
    5918:	ef2080e7          	jalr	-270(ra) # 6806 <open>
    591c:	89aa                	mv	s3,a0
    total = 0;
    591e:	895a                	mv	s2,s6
        if(buf[j] != '0'+i){
    5920:	000b849b          	sext.w	s1,s7
    while((n = read(fd, buf, sizeof(buf))) > 0){
    5924:	bf51                	j	58b8 <fourfiles+0x1d4>
      printf("wrong length %d\n", total);
    5926:	85ca                	mv	a1,s2
    5928:	00003517          	auipc	a0,0x3
    592c:	16850513          	addi	a0,a0,360 # 8a90 <malloc+0x1e64>
    5930:	00001097          	auipc	ra,0x1
    5934:	23e080e7          	jalr	574(ra) # 6b6e <printf>
      exit(1,"");
    5938:	00003597          	auipc	a1,0x3
    593c:	a2058593          	addi	a1,a1,-1504 # 8358 <malloc+0x172c>
    5940:	4505                	li	a0,1
    5942:	00001097          	auipc	ra,0x1
    5946:	e84080e7          	jalr	-380(ra) # 67c6 <exit>
}
    594a:	70aa                	ld	ra,168(sp)
    594c:	740a                	ld	s0,160(sp)
    594e:	64ea                	ld	s1,152(sp)
    5950:	694a                	ld	s2,144(sp)
    5952:	69aa                	ld	s3,136(sp)
    5954:	6a0a                	ld	s4,128(sp)
    5956:	7ae6                	ld	s5,120(sp)
    5958:	7b46                	ld	s6,112(sp)
    595a:	7ba6                	ld	s7,104(sp)
    595c:	7c06                	ld	s8,96(sp)
    595e:	6ce6                	ld	s9,88(sp)
    5960:	6d46                	ld	s10,80(sp)
    5962:	6da6                	ld	s11,72(sp)
    5964:	614d                	addi	sp,sp,176
    5966:	8082                	ret

0000000000005968 <concreate>:
{
    5968:	7135                	addi	sp,sp,-160
    596a:	ed06                	sd	ra,152(sp)
    596c:	e922                	sd	s0,144(sp)
    596e:	e526                	sd	s1,136(sp)
    5970:	e14a                	sd	s2,128(sp)
    5972:	fcce                	sd	s3,120(sp)
    5974:	f8d2                	sd	s4,112(sp)
    5976:	f4d6                	sd	s5,104(sp)
    5978:	f0da                	sd	s6,96(sp)
    597a:	ecde                	sd	s7,88(sp)
    597c:	e8e2                	sd	s8,80(sp)
    597e:	1100                	addi	s0,sp,160
    5980:	89aa                	mv	s3,a0
  file[0] = 'C';
    5982:	04300793          	li	a5,67
    5986:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    598a:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    598e:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    5990:	4b8d                	li	s7,3
    5992:	4b05                	li	s6,1
      link("C0", file);
    5994:	00003c17          	auipc	s8,0x3
    5998:	114c0c13          	addi	s8,s8,276 # 8aa8 <malloc+0x1e7c>
      wait(&xstatus,"");
    599c:	00003a97          	auipc	s5,0x3
    59a0:	9bca8a93          	addi	s5,s5,-1604 # 8358 <malloc+0x172c>
  for(i = 0; i < N; i++){
    59a4:	02800a13          	li	s4,40
    59a8:	ae31                	j	5cc4 <concreate+0x35c>
      link("C0", file);
    59aa:	fa840593          	addi	a1,s0,-88
    59ae:	8562                	mv	a0,s8
    59b0:	00001097          	auipc	ra,0x1
    59b4:	e76080e7          	jalr	-394(ra) # 6826 <link>
    if(pid == 0) {
    59b8:	acc5                	j	5ca8 <concreate+0x340>
    } else if(pid == 0 && (i % 5) == 1){
    59ba:	4795                	li	a5,5
    59bc:	02f9693b          	remw	s2,s2,a5
    59c0:	4785                	li	a5,1
    59c2:	02f90f63          	beq	s2,a5,5a00 <concreate+0x98>
      fd = open(file, O_CREATE | O_RDWR);
    59c6:	20200593          	li	a1,514
    59ca:	fa840513          	addi	a0,s0,-88
    59ce:	00001097          	auipc	ra,0x1
    59d2:	e38080e7          	jalr	-456(ra) # 6806 <open>
      if(fd < 0){
    59d6:	2c055063          	bgez	a0,5c96 <concreate+0x32e>
        printf("concreate create %s failed\n", file);
    59da:	fa840593          	addi	a1,s0,-88
    59de:	00003517          	auipc	a0,0x3
    59e2:	0d250513          	addi	a0,a0,210 # 8ab0 <malloc+0x1e84>
    59e6:	00001097          	auipc	ra,0x1
    59ea:	188080e7          	jalr	392(ra) # 6b6e <printf>
        exit(1,"");
    59ee:	00003597          	auipc	a1,0x3
    59f2:	96a58593          	addi	a1,a1,-1686 # 8358 <malloc+0x172c>
    59f6:	4505                	li	a0,1
    59f8:	00001097          	auipc	ra,0x1
    59fc:	dce080e7          	jalr	-562(ra) # 67c6 <exit>
      link("C0", file);
    5a00:	fa840593          	addi	a1,s0,-88
    5a04:	00003517          	auipc	a0,0x3
    5a08:	0a450513          	addi	a0,a0,164 # 8aa8 <malloc+0x1e7c>
    5a0c:	00001097          	auipc	ra,0x1
    5a10:	e1a080e7          	jalr	-486(ra) # 6826 <link>
      exit(0,"");
    5a14:	00003597          	auipc	a1,0x3
    5a18:	94458593          	addi	a1,a1,-1724 # 8358 <malloc+0x172c>
    5a1c:	4501                	li	a0,0
    5a1e:	00001097          	auipc	ra,0x1
    5a22:	da8080e7          	jalr	-600(ra) # 67c6 <exit>
        exit(1,"");
    5a26:	00003597          	auipc	a1,0x3
    5a2a:	93258593          	addi	a1,a1,-1742 # 8358 <malloc+0x172c>
    5a2e:	4505                	li	a0,1
    5a30:	00001097          	auipc	ra,0x1
    5a34:	d96080e7          	jalr	-618(ra) # 67c6 <exit>
  memset(fa, 0, sizeof(fa));
    5a38:	02800613          	li	a2,40
    5a3c:	4581                	li	a1,0
    5a3e:	f8040513          	addi	a0,s0,-128
    5a42:	00001097          	auipc	ra,0x1
    5a46:	b88080e7          	jalr	-1144(ra) # 65ca <memset>
  fd = open(".", 0);
    5a4a:	4581                	li	a1,0
    5a4c:	00002517          	auipc	a0,0x2
    5a50:	a0450513          	addi	a0,a0,-1532 # 7450 <malloc+0x824>
    5a54:	00001097          	auipc	ra,0x1
    5a58:	db2080e7          	jalr	-590(ra) # 6806 <open>
    5a5c:	892a                	mv	s2,a0
  n = 0;
    5a5e:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    5a60:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    5a64:	02700b13          	li	s6,39
      fa[i] = 1;
    5a68:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    5a6a:	4641                	li	a2,16
    5a6c:	f7040593          	addi	a1,s0,-144
    5a70:	854a                	mv	a0,s2
    5a72:	00001097          	auipc	ra,0x1
    5a76:	d6c080e7          	jalr	-660(ra) # 67de <read>
    5a7a:	08a05963          	blez	a0,5b0c <concreate+0x1a4>
    if(de.inum == 0)
    5a7e:	f7045783          	lhu	a5,-144(s0)
    5a82:	d7e5                	beqz	a5,5a6a <concreate+0x102>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    5a84:	f7244783          	lbu	a5,-142(s0)
    5a88:	ff4791e3          	bne	a5,s4,5a6a <concreate+0x102>
    5a8c:	f7444783          	lbu	a5,-140(s0)
    5a90:	ffe9                	bnez	a5,5a6a <concreate+0x102>
      i = de.name[1] - '0';
    5a92:	f7344783          	lbu	a5,-141(s0)
    5a96:	fd07879b          	addiw	a5,a5,-48
    5a9a:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    5a9e:	00eb6f63          	bltu	s6,a4,5abc <concreate+0x154>
      if(fa[i]){
    5aa2:	fb040793          	addi	a5,s0,-80
    5aa6:	97ba                	add	a5,a5,a4
    5aa8:	fd07c783          	lbu	a5,-48(a5)
    5aac:	ef85                	bnez	a5,5ae4 <concreate+0x17c>
      fa[i] = 1;
    5aae:	fb040793          	addi	a5,s0,-80
    5ab2:	973e                	add	a4,a4,a5
    5ab4:	fd770823          	sb	s7,-48(a4) # fd0 <unlinkread+0x158>
      n++;
    5ab8:	2a85                	addiw	s5,s5,1
    5aba:	bf45                	j	5a6a <concreate+0x102>
        printf("%s: concreate weird file %s\n", s, de.name);
    5abc:	f7240613          	addi	a2,s0,-142
    5ac0:	85ce                	mv	a1,s3
    5ac2:	00003517          	auipc	a0,0x3
    5ac6:	00e50513          	addi	a0,a0,14 # 8ad0 <malloc+0x1ea4>
    5aca:	00001097          	auipc	ra,0x1
    5ace:	0a4080e7          	jalr	164(ra) # 6b6e <printf>
        exit(1,"");
    5ad2:	00003597          	auipc	a1,0x3
    5ad6:	88658593          	addi	a1,a1,-1914 # 8358 <malloc+0x172c>
    5ada:	4505                	li	a0,1
    5adc:	00001097          	auipc	ra,0x1
    5ae0:	cea080e7          	jalr	-790(ra) # 67c6 <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    5ae4:	f7240613          	addi	a2,s0,-142
    5ae8:	85ce                	mv	a1,s3
    5aea:	00003517          	auipc	a0,0x3
    5aee:	00650513          	addi	a0,a0,6 # 8af0 <malloc+0x1ec4>
    5af2:	00001097          	auipc	ra,0x1
    5af6:	07c080e7          	jalr	124(ra) # 6b6e <printf>
        exit(1,"");
    5afa:	00003597          	auipc	a1,0x3
    5afe:	85e58593          	addi	a1,a1,-1954 # 8358 <malloc+0x172c>
    5b02:	4505                	li	a0,1
    5b04:	00001097          	auipc	ra,0x1
    5b08:	cc2080e7          	jalr	-830(ra) # 67c6 <exit>
  close(fd);
    5b0c:	854a                	mv	a0,s2
    5b0e:	00001097          	auipc	ra,0x1
    5b12:	ce0080e7          	jalr	-800(ra) # 67ee <close>
  if(n != N){
    5b16:	02800793          	li	a5,40
    5b1a:	00fa9b63          	bne	s5,a5,5b30 <concreate+0x1c8>
    if(((i % 3) == 0 && pid == 0) ||
    5b1e:	4b0d                	li	s6,3
    5b20:	4b85                	li	s7,1
      wait(0,"");
    5b22:	00003a97          	auipc	s5,0x3
    5b26:	836a8a93          	addi	s5,s5,-1994 # 8358 <malloc+0x172c>
  for(i = 0; i < N; i++){
    5b2a:	02800a13          	li	s4,40
    5b2e:	a0d5                	j	5c12 <concreate+0x2aa>
    printf("%s: concreate not enough files in directory listing\n", s);
    5b30:	85ce                	mv	a1,s3
    5b32:	00003517          	auipc	a0,0x3
    5b36:	fe650513          	addi	a0,a0,-26 # 8b18 <malloc+0x1eec>
    5b3a:	00001097          	auipc	ra,0x1
    5b3e:	034080e7          	jalr	52(ra) # 6b6e <printf>
    exit(1,"");
    5b42:	00003597          	auipc	a1,0x3
    5b46:	81658593          	addi	a1,a1,-2026 # 8358 <malloc+0x172c>
    5b4a:	4505                	li	a0,1
    5b4c:	00001097          	auipc	ra,0x1
    5b50:	c7a080e7          	jalr	-902(ra) # 67c6 <exit>
      printf("%s: fork failed\n", s);
    5b54:	85ce                	mv	a1,s3
    5b56:	00002517          	auipc	a0,0x2
    5b5a:	a9a50513          	addi	a0,a0,-1382 # 75f0 <malloc+0x9c4>
    5b5e:	00001097          	auipc	ra,0x1
    5b62:	010080e7          	jalr	16(ra) # 6b6e <printf>
      exit(1,"");
    5b66:	00002597          	auipc	a1,0x2
    5b6a:	7f258593          	addi	a1,a1,2034 # 8358 <malloc+0x172c>
    5b6e:	4505                	li	a0,1
    5b70:	00001097          	auipc	ra,0x1
    5b74:	c56080e7          	jalr	-938(ra) # 67c6 <exit>
      close(open(file, 0));
    5b78:	4581                	li	a1,0
    5b7a:	fa840513          	addi	a0,s0,-88
    5b7e:	00001097          	auipc	ra,0x1
    5b82:	c88080e7          	jalr	-888(ra) # 6806 <open>
    5b86:	00001097          	auipc	ra,0x1
    5b8a:	c68080e7          	jalr	-920(ra) # 67ee <close>
      close(open(file, 0));
    5b8e:	4581                	li	a1,0
    5b90:	fa840513          	addi	a0,s0,-88
    5b94:	00001097          	auipc	ra,0x1
    5b98:	c72080e7          	jalr	-910(ra) # 6806 <open>
    5b9c:	00001097          	auipc	ra,0x1
    5ba0:	c52080e7          	jalr	-942(ra) # 67ee <close>
      close(open(file, 0));
    5ba4:	4581                	li	a1,0
    5ba6:	fa840513          	addi	a0,s0,-88
    5baa:	00001097          	auipc	ra,0x1
    5bae:	c5c080e7          	jalr	-932(ra) # 6806 <open>
    5bb2:	00001097          	auipc	ra,0x1
    5bb6:	c3c080e7          	jalr	-964(ra) # 67ee <close>
      close(open(file, 0));
    5bba:	4581                	li	a1,0
    5bbc:	fa840513          	addi	a0,s0,-88
    5bc0:	00001097          	auipc	ra,0x1
    5bc4:	c46080e7          	jalr	-954(ra) # 6806 <open>
    5bc8:	00001097          	auipc	ra,0x1
    5bcc:	c26080e7          	jalr	-986(ra) # 67ee <close>
      close(open(file, 0));
    5bd0:	4581                	li	a1,0
    5bd2:	fa840513          	addi	a0,s0,-88
    5bd6:	00001097          	auipc	ra,0x1
    5bda:	c30080e7          	jalr	-976(ra) # 6806 <open>
    5bde:	00001097          	auipc	ra,0x1
    5be2:	c10080e7          	jalr	-1008(ra) # 67ee <close>
      close(open(file, 0));
    5be6:	4581                	li	a1,0
    5be8:	fa840513          	addi	a0,s0,-88
    5bec:	00001097          	auipc	ra,0x1
    5bf0:	c1a080e7          	jalr	-998(ra) # 6806 <open>
    5bf4:	00001097          	auipc	ra,0x1
    5bf8:	bfa080e7          	jalr	-1030(ra) # 67ee <close>
    if(pid == 0)
    5bfc:	08090463          	beqz	s2,5c84 <concreate+0x31c>
      wait(0,"");
    5c00:	85d6                	mv	a1,s5
    5c02:	4501                	li	a0,0
    5c04:	00001097          	auipc	ra,0x1
    5c08:	bca080e7          	jalr	-1078(ra) # 67ce <wait>
  for(i = 0; i < N; i++){
    5c0c:	2485                	addiw	s1,s1,1
    5c0e:	0f448a63          	beq	s1,s4,5d02 <concreate+0x39a>
    file[1] = '0' + i;
    5c12:	0304879b          	addiw	a5,s1,48
    5c16:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    5c1a:	00001097          	auipc	ra,0x1
    5c1e:	ba4080e7          	jalr	-1116(ra) # 67be <fork>
    5c22:	892a                	mv	s2,a0
    if(pid < 0){
    5c24:	f20548e3          	bltz	a0,5b54 <concreate+0x1ec>
    if(((i % 3) == 0 && pid == 0) ||
    5c28:	0364e73b          	remw	a4,s1,s6
    5c2c:	00a767b3          	or	a5,a4,a0
    5c30:	2781                	sext.w	a5,a5
    5c32:	d3b9                	beqz	a5,5b78 <concreate+0x210>
    5c34:	01771363          	bne	a4,s7,5c3a <concreate+0x2d2>
       ((i % 3) == 1 && pid != 0)){
    5c38:	f121                	bnez	a0,5b78 <concreate+0x210>
      unlink(file);
    5c3a:	fa840513          	addi	a0,s0,-88
    5c3e:	00001097          	auipc	ra,0x1
    5c42:	bd8080e7          	jalr	-1064(ra) # 6816 <unlink>
      unlink(file);
    5c46:	fa840513          	addi	a0,s0,-88
    5c4a:	00001097          	auipc	ra,0x1
    5c4e:	bcc080e7          	jalr	-1076(ra) # 6816 <unlink>
      unlink(file);
    5c52:	fa840513          	addi	a0,s0,-88
    5c56:	00001097          	auipc	ra,0x1
    5c5a:	bc0080e7          	jalr	-1088(ra) # 6816 <unlink>
      unlink(file);
    5c5e:	fa840513          	addi	a0,s0,-88
    5c62:	00001097          	auipc	ra,0x1
    5c66:	bb4080e7          	jalr	-1100(ra) # 6816 <unlink>
      unlink(file);
    5c6a:	fa840513          	addi	a0,s0,-88
    5c6e:	00001097          	auipc	ra,0x1
    5c72:	ba8080e7          	jalr	-1112(ra) # 6816 <unlink>
      unlink(file);
    5c76:	fa840513          	addi	a0,s0,-88
    5c7a:	00001097          	auipc	ra,0x1
    5c7e:	b9c080e7          	jalr	-1124(ra) # 6816 <unlink>
    5c82:	bfad                	j	5bfc <concreate+0x294>
      exit(0,"");
    5c84:	00002597          	auipc	a1,0x2
    5c88:	6d458593          	addi	a1,a1,1748 # 8358 <malloc+0x172c>
    5c8c:	4501                	li	a0,0
    5c8e:	00001097          	auipc	ra,0x1
    5c92:	b38080e7          	jalr	-1224(ra) # 67c6 <exit>
      close(fd);
    5c96:	00001097          	auipc	ra,0x1
    5c9a:	b58080e7          	jalr	-1192(ra) # 67ee <close>
    if(pid == 0) {
    5c9e:	bb9d                	j	5a14 <concreate+0xac>
      close(fd);
    5ca0:	00001097          	auipc	ra,0x1
    5ca4:	b4e080e7          	jalr	-1202(ra) # 67ee <close>
      wait(&xstatus,"");
    5ca8:	85d6                	mv	a1,s5
    5caa:	f6c40513          	addi	a0,s0,-148
    5cae:	00001097          	auipc	ra,0x1
    5cb2:	b20080e7          	jalr	-1248(ra) # 67ce <wait>
      if(xstatus != 0)
    5cb6:	f6c42483          	lw	s1,-148(s0)
    5cba:	d60496e3          	bnez	s1,5a26 <concreate+0xbe>
  for(i = 0; i < N; i++){
    5cbe:	2905                	addiw	s2,s2,1
    5cc0:	d7490ce3          	beq	s2,s4,5a38 <concreate+0xd0>
    file[1] = '0' + i;
    5cc4:	0309079b          	addiw	a5,s2,48
    5cc8:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    5ccc:	fa840513          	addi	a0,s0,-88
    5cd0:	00001097          	auipc	ra,0x1
    5cd4:	b46080e7          	jalr	-1210(ra) # 6816 <unlink>
    pid = fork();
    5cd8:	00001097          	auipc	ra,0x1
    5cdc:	ae6080e7          	jalr	-1306(ra) # 67be <fork>
    if(pid && (i % 3) == 1){
    5ce0:	cc050de3          	beqz	a0,59ba <concreate+0x52>
    5ce4:	037967bb          	remw	a5,s2,s7
    5ce8:	cd6781e3          	beq	a5,s6,59aa <concreate+0x42>
      fd = open(file, O_CREATE | O_RDWR);
    5cec:	20200593          	li	a1,514
    5cf0:	fa840513          	addi	a0,s0,-88
    5cf4:	00001097          	auipc	ra,0x1
    5cf8:	b12080e7          	jalr	-1262(ra) # 6806 <open>
      if(fd < 0){
    5cfc:	fa0552e3          	bgez	a0,5ca0 <concreate+0x338>
    5d00:	b9e9                	j	59da <concreate+0x72>
}
    5d02:	60ea                	ld	ra,152(sp)
    5d04:	644a                	ld	s0,144(sp)
    5d06:	64aa                	ld	s1,136(sp)
    5d08:	690a                	ld	s2,128(sp)
    5d0a:	79e6                	ld	s3,120(sp)
    5d0c:	7a46                	ld	s4,112(sp)
    5d0e:	7aa6                	ld	s5,104(sp)
    5d10:	7b06                	ld	s6,96(sp)
    5d12:	6be6                	ld	s7,88(sp)
    5d14:	6c46                	ld	s8,80(sp)
    5d16:	610d                	addi	sp,sp,160
    5d18:	8082                	ret

0000000000005d1a <bigfile>:
{
    5d1a:	7139                	addi	sp,sp,-64
    5d1c:	fc06                	sd	ra,56(sp)
    5d1e:	f822                	sd	s0,48(sp)
    5d20:	f426                	sd	s1,40(sp)
    5d22:	f04a                	sd	s2,32(sp)
    5d24:	ec4e                	sd	s3,24(sp)
    5d26:	e852                	sd	s4,16(sp)
    5d28:	e456                	sd	s5,8(sp)
    5d2a:	0080                	addi	s0,sp,64
    5d2c:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    5d2e:	00003517          	auipc	a0,0x3
    5d32:	e2250513          	addi	a0,a0,-478 # 8b50 <malloc+0x1f24>
    5d36:	00001097          	auipc	ra,0x1
    5d3a:	ae0080e7          	jalr	-1312(ra) # 6816 <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    5d3e:	20200593          	li	a1,514
    5d42:	00003517          	auipc	a0,0x3
    5d46:	e0e50513          	addi	a0,a0,-498 # 8b50 <malloc+0x1f24>
    5d4a:	00001097          	auipc	ra,0x1
    5d4e:	abc080e7          	jalr	-1348(ra) # 6806 <open>
    5d52:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    5d54:	4481                	li	s1,0
    memset(buf, i, SZ);
    5d56:	00008917          	auipc	s2,0x8
    5d5a:	f2290913          	addi	s2,s2,-222 # dc78 <buf>
  for(i = 0; i < N; i++){
    5d5e:	4a51                	li	s4,20
  if(fd < 0){
    5d60:	0a054163          	bltz	a0,5e02 <bigfile+0xe8>
    memset(buf, i, SZ);
    5d64:	25800613          	li	a2,600
    5d68:	85a6                	mv	a1,s1
    5d6a:	854a                	mv	a0,s2
    5d6c:	00001097          	auipc	ra,0x1
    5d70:	85e080e7          	jalr	-1954(ra) # 65ca <memset>
    if(write(fd, buf, SZ) != SZ){
    5d74:	25800613          	li	a2,600
    5d78:	85ca                	mv	a1,s2
    5d7a:	854e                	mv	a0,s3
    5d7c:	00001097          	auipc	ra,0x1
    5d80:	a6a080e7          	jalr	-1430(ra) # 67e6 <write>
    5d84:	25800793          	li	a5,600
    5d88:	08f51f63          	bne	a0,a5,5e26 <bigfile+0x10c>
  for(i = 0; i < N; i++){
    5d8c:	2485                	addiw	s1,s1,1
    5d8e:	fd449be3          	bne	s1,s4,5d64 <bigfile+0x4a>
  close(fd);
    5d92:	854e                	mv	a0,s3
    5d94:	00001097          	auipc	ra,0x1
    5d98:	a5a080e7          	jalr	-1446(ra) # 67ee <close>
  fd = open("bigfile.dat", 0);
    5d9c:	4581                	li	a1,0
    5d9e:	00003517          	auipc	a0,0x3
    5da2:	db250513          	addi	a0,a0,-590 # 8b50 <malloc+0x1f24>
    5da6:	00001097          	auipc	ra,0x1
    5daa:	a60080e7          	jalr	-1440(ra) # 6806 <open>
    5dae:	8a2a                	mv	s4,a0
  total = 0;
    5db0:	4981                	li	s3,0
  for(i = 0; ; i++){
    5db2:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    5db4:	00008917          	auipc	s2,0x8
    5db8:	ec490913          	addi	s2,s2,-316 # dc78 <buf>
  if(fd < 0){
    5dbc:	08054763          	bltz	a0,5e4a <bigfile+0x130>
    cc = read(fd, buf, SZ/2);
    5dc0:	12c00613          	li	a2,300
    5dc4:	85ca                	mv	a1,s2
    5dc6:	8552                	mv	a0,s4
    5dc8:	00001097          	auipc	ra,0x1
    5dcc:	a16080e7          	jalr	-1514(ra) # 67de <read>
    if(cc < 0){
    5dd0:	08054f63          	bltz	a0,5e6e <bigfile+0x154>
    if(cc == 0)
    5dd4:	10050363          	beqz	a0,5eda <bigfile+0x1c0>
    if(cc != SZ/2){
    5dd8:	12c00793          	li	a5,300
    5ddc:	0af51b63          	bne	a0,a5,5e92 <bigfile+0x178>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    5de0:	01f4d79b          	srliw	a5,s1,0x1f
    5de4:	9fa5                	addw	a5,a5,s1
    5de6:	4017d79b          	sraiw	a5,a5,0x1
    5dea:	00094703          	lbu	a4,0(s2)
    5dee:	0cf71463          	bne	a4,a5,5eb6 <bigfile+0x19c>
    5df2:	12b94703          	lbu	a4,299(s2)
    5df6:	0cf71063          	bne	a4,a5,5eb6 <bigfile+0x19c>
    total += cc;
    5dfa:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    5dfe:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    5e00:	b7c1                	j	5dc0 <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    5e02:	85d6                	mv	a1,s5
    5e04:	00003517          	auipc	a0,0x3
    5e08:	d5c50513          	addi	a0,a0,-676 # 8b60 <malloc+0x1f34>
    5e0c:	00001097          	auipc	ra,0x1
    5e10:	d62080e7          	jalr	-670(ra) # 6b6e <printf>
    exit(1,"");
    5e14:	00002597          	auipc	a1,0x2
    5e18:	54458593          	addi	a1,a1,1348 # 8358 <malloc+0x172c>
    5e1c:	4505                	li	a0,1
    5e1e:	00001097          	auipc	ra,0x1
    5e22:	9a8080e7          	jalr	-1624(ra) # 67c6 <exit>
      printf("%s: write bigfile failed\n", s);
    5e26:	85d6                	mv	a1,s5
    5e28:	00003517          	auipc	a0,0x3
    5e2c:	d5850513          	addi	a0,a0,-680 # 8b80 <malloc+0x1f54>
    5e30:	00001097          	auipc	ra,0x1
    5e34:	d3e080e7          	jalr	-706(ra) # 6b6e <printf>
      exit(1,"");
    5e38:	00002597          	auipc	a1,0x2
    5e3c:	52058593          	addi	a1,a1,1312 # 8358 <malloc+0x172c>
    5e40:	4505                	li	a0,1
    5e42:	00001097          	auipc	ra,0x1
    5e46:	984080e7          	jalr	-1660(ra) # 67c6 <exit>
    printf("%s: cannot open bigfile\n", s);
    5e4a:	85d6                	mv	a1,s5
    5e4c:	00003517          	auipc	a0,0x3
    5e50:	d5450513          	addi	a0,a0,-684 # 8ba0 <malloc+0x1f74>
    5e54:	00001097          	auipc	ra,0x1
    5e58:	d1a080e7          	jalr	-742(ra) # 6b6e <printf>
    exit(1,"");
    5e5c:	00002597          	auipc	a1,0x2
    5e60:	4fc58593          	addi	a1,a1,1276 # 8358 <malloc+0x172c>
    5e64:	4505                	li	a0,1
    5e66:	00001097          	auipc	ra,0x1
    5e6a:	960080e7          	jalr	-1696(ra) # 67c6 <exit>
      printf("%s: read bigfile failed\n", s);
    5e6e:	85d6                	mv	a1,s5
    5e70:	00003517          	auipc	a0,0x3
    5e74:	d5050513          	addi	a0,a0,-688 # 8bc0 <malloc+0x1f94>
    5e78:	00001097          	auipc	ra,0x1
    5e7c:	cf6080e7          	jalr	-778(ra) # 6b6e <printf>
      exit(1,"");
    5e80:	00002597          	auipc	a1,0x2
    5e84:	4d858593          	addi	a1,a1,1240 # 8358 <malloc+0x172c>
    5e88:	4505                	li	a0,1
    5e8a:	00001097          	auipc	ra,0x1
    5e8e:	93c080e7          	jalr	-1732(ra) # 67c6 <exit>
      printf("%s: short read bigfile\n", s);
    5e92:	85d6                	mv	a1,s5
    5e94:	00003517          	auipc	a0,0x3
    5e98:	d4c50513          	addi	a0,a0,-692 # 8be0 <malloc+0x1fb4>
    5e9c:	00001097          	auipc	ra,0x1
    5ea0:	cd2080e7          	jalr	-814(ra) # 6b6e <printf>
      exit(1,"");
    5ea4:	00002597          	auipc	a1,0x2
    5ea8:	4b458593          	addi	a1,a1,1204 # 8358 <malloc+0x172c>
    5eac:	4505                	li	a0,1
    5eae:	00001097          	auipc	ra,0x1
    5eb2:	918080e7          	jalr	-1768(ra) # 67c6 <exit>
      printf("%s: read bigfile wrong data\n", s);
    5eb6:	85d6                	mv	a1,s5
    5eb8:	00003517          	auipc	a0,0x3
    5ebc:	d4050513          	addi	a0,a0,-704 # 8bf8 <malloc+0x1fcc>
    5ec0:	00001097          	auipc	ra,0x1
    5ec4:	cae080e7          	jalr	-850(ra) # 6b6e <printf>
      exit(1,"");
    5ec8:	00002597          	auipc	a1,0x2
    5ecc:	49058593          	addi	a1,a1,1168 # 8358 <malloc+0x172c>
    5ed0:	4505                	li	a0,1
    5ed2:	00001097          	auipc	ra,0x1
    5ed6:	8f4080e7          	jalr	-1804(ra) # 67c6 <exit>
  close(fd);
    5eda:	8552                	mv	a0,s4
    5edc:	00001097          	auipc	ra,0x1
    5ee0:	912080e7          	jalr	-1774(ra) # 67ee <close>
  if(total != N*SZ){
    5ee4:	678d                	lui	a5,0x3
    5ee6:	ee078793          	addi	a5,a5,-288 # 2ee0 <sbrkbasic+0x80>
    5eea:	02f99363          	bne	s3,a5,5f10 <bigfile+0x1f6>
  unlink("bigfile.dat");
    5eee:	00003517          	auipc	a0,0x3
    5ef2:	c6250513          	addi	a0,a0,-926 # 8b50 <malloc+0x1f24>
    5ef6:	00001097          	auipc	ra,0x1
    5efa:	920080e7          	jalr	-1760(ra) # 6816 <unlink>
}
    5efe:	70e2                	ld	ra,56(sp)
    5f00:	7442                	ld	s0,48(sp)
    5f02:	74a2                	ld	s1,40(sp)
    5f04:	7902                	ld	s2,32(sp)
    5f06:	69e2                	ld	s3,24(sp)
    5f08:	6a42                	ld	s4,16(sp)
    5f0a:	6aa2                	ld	s5,8(sp)
    5f0c:	6121                	addi	sp,sp,64
    5f0e:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    5f10:	85d6                	mv	a1,s5
    5f12:	00003517          	auipc	a0,0x3
    5f16:	d0650513          	addi	a0,a0,-762 # 8c18 <malloc+0x1fec>
    5f1a:	00001097          	auipc	ra,0x1
    5f1e:	c54080e7          	jalr	-940(ra) # 6b6e <printf>
    exit(1,"");
    5f22:	00002597          	auipc	a1,0x2
    5f26:	43658593          	addi	a1,a1,1078 # 8358 <malloc+0x172c>
    5f2a:	4505                	li	a0,1
    5f2c:	00001097          	auipc	ra,0x1
    5f30:	89a080e7          	jalr	-1894(ra) # 67c6 <exit>

0000000000005f34 <fsfull>:
{
    5f34:	7171                	addi	sp,sp,-176
    5f36:	f506                	sd	ra,168(sp)
    5f38:	f122                	sd	s0,160(sp)
    5f3a:	ed26                	sd	s1,152(sp)
    5f3c:	e94a                	sd	s2,144(sp)
    5f3e:	e54e                	sd	s3,136(sp)
    5f40:	e152                	sd	s4,128(sp)
    5f42:	fcd6                	sd	s5,120(sp)
    5f44:	f8da                	sd	s6,112(sp)
    5f46:	f4de                	sd	s7,104(sp)
    5f48:	f0e2                	sd	s8,96(sp)
    5f4a:	ece6                	sd	s9,88(sp)
    5f4c:	e8ea                	sd	s10,80(sp)
    5f4e:	e4ee                	sd	s11,72(sp)
    5f50:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    5f52:	00003517          	auipc	a0,0x3
    5f56:	ce650513          	addi	a0,a0,-794 # 8c38 <malloc+0x200c>
    5f5a:	00001097          	auipc	ra,0x1
    5f5e:	c14080e7          	jalr	-1004(ra) # 6b6e <printf>
  for(nfiles = 0; ; nfiles++){
    5f62:	4481                	li	s1,0
    name[0] = 'f';
    5f64:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    5f68:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    5f6c:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    5f70:	4b29                	li	s6,10
    printf("writing %s\n", name);
    5f72:	00003c97          	auipc	s9,0x3
    5f76:	cd6c8c93          	addi	s9,s9,-810 # 8c48 <malloc+0x201c>
    int total = 0;
    5f7a:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    5f7c:	00008a17          	auipc	s4,0x8
    5f80:	cfca0a13          	addi	s4,s4,-772 # dc78 <buf>
    name[0] = 'f';
    5f84:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    5f88:	0384c7bb          	divw	a5,s1,s8
    5f8c:	0307879b          	addiw	a5,a5,48
    5f90:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    5f94:	0384e7bb          	remw	a5,s1,s8
    5f98:	0377c7bb          	divw	a5,a5,s7
    5f9c:	0307879b          	addiw	a5,a5,48
    5fa0:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    5fa4:	0374e7bb          	remw	a5,s1,s7
    5fa8:	0367c7bb          	divw	a5,a5,s6
    5fac:	0307879b          	addiw	a5,a5,48
    5fb0:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    5fb4:	0364e7bb          	remw	a5,s1,s6
    5fb8:	0307879b          	addiw	a5,a5,48
    5fbc:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    5fc0:	f4040aa3          	sb	zero,-171(s0)
    printf("writing %s\n", name);
    5fc4:	f5040593          	addi	a1,s0,-176
    5fc8:	8566                	mv	a0,s9
    5fca:	00001097          	auipc	ra,0x1
    5fce:	ba4080e7          	jalr	-1116(ra) # 6b6e <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    5fd2:	20200593          	li	a1,514
    5fd6:	f5040513          	addi	a0,s0,-176
    5fda:	00001097          	auipc	ra,0x1
    5fde:	82c080e7          	jalr	-2004(ra) # 6806 <open>
    5fe2:	892a                	mv	s2,a0
    if(fd < 0){
    5fe4:	0a055663          	bgez	a0,6090 <fsfull+0x15c>
      printf("open %s failed\n", name);
    5fe8:	f5040593          	addi	a1,s0,-176
    5fec:	00003517          	auipc	a0,0x3
    5ff0:	c6c50513          	addi	a0,a0,-916 # 8c58 <malloc+0x202c>
    5ff4:	00001097          	auipc	ra,0x1
    5ff8:	b7a080e7          	jalr	-1158(ra) # 6b6e <printf>
  while(nfiles >= 0){
    5ffc:	0604c363          	bltz	s1,6062 <fsfull+0x12e>
    name[0] = 'f';
    6000:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    6004:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    6008:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    600c:	4929                	li	s2,10
  while(nfiles >= 0){
    600e:	5afd                	li	s5,-1
    name[0] = 'f';
    6010:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    6014:	0344c7bb          	divw	a5,s1,s4
    6018:	0307879b          	addiw	a5,a5,48
    601c:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    6020:	0344e7bb          	remw	a5,s1,s4
    6024:	0337c7bb          	divw	a5,a5,s3
    6028:	0307879b          	addiw	a5,a5,48
    602c:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    6030:	0334e7bb          	remw	a5,s1,s3
    6034:	0327c7bb          	divw	a5,a5,s2
    6038:	0307879b          	addiw	a5,a5,48
    603c:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    6040:	0324e7bb          	remw	a5,s1,s2
    6044:	0307879b          	addiw	a5,a5,48
    6048:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    604c:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    6050:	f5040513          	addi	a0,s0,-176
    6054:	00000097          	auipc	ra,0x0
    6058:	7c2080e7          	jalr	1986(ra) # 6816 <unlink>
    nfiles--;
    605c:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    605e:	fb5499e3          	bne	s1,s5,6010 <fsfull+0xdc>
  printf("fsfull test finished\n");
    6062:	00003517          	auipc	a0,0x3
    6066:	c1650513          	addi	a0,a0,-1002 # 8c78 <malloc+0x204c>
    606a:	00001097          	auipc	ra,0x1
    606e:	b04080e7          	jalr	-1276(ra) # 6b6e <printf>
}
    6072:	70aa                	ld	ra,168(sp)
    6074:	740a                	ld	s0,160(sp)
    6076:	64ea                	ld	s1,152(sp)
    6078:	694a                	ld	s2,144(sp)
    607a:	69aa                	ld	s3,136(sp)
    607c:	6a0a                	ld	s4,128(sp)
    607e:	7ae6                	ld	s5,120(sp)
    6080:	7b46                	ld	s6,112(sp)
    6082:	7ba6                	ld	s7,104(sp)
    6084:	7c06                	ld	s8,96(sp)
    6086:	6ce6                	ld	s9,88(sp)
    6088:	6d46                	ld	s10,80(sp)
    608a:	6da6                	ld	s11,72(sp)
    608c:	614d                	addi	sp,sp,176
    608e:	8082                	ret
    int total = 0;
    6090:	89ee                	mv	s3,s11
      if(cc < BSIZE)
    6092:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    6096:	40000613          	li	a2,1024
    609a:	85d2                	mv	a1,s4
    609c:	854a                	mv	a0,s2
    609e:	00000097          	auipc	ra,0x0
    60a2:	748080e7          	jalr	1864(ra) # 67e6 <write>
      if(cc < BSIZE)
    60a6:	00aad563          	bge	s5,a0,60b0 <fsfull+0x17c>
      total += cc;
    60aa:	00a989bb          	addw	s3,s3,a0
    while(1){
    60ae:	b7e5                	j	6096 <fsfull+0x162>
    printf("wrote %d bytes\n", total);
    60b0:	85ce                	mv	a1,s3
    60b2:	00003517          	auipc	a0,0x3
    60b6:	bb650513          	addi	a0,a0,-1098 # 8c68 <malloc+0x203c>
    60ba:	00001097          	auipc	ra,0x1
    60be:	ab4080e7          	jalr	-1356(ra) # 6b6e <printf>
    close(fd);
    60c2:	854a                	mv	a0,s2
    60c4:	00000097          	auipc	ra,0x0
    60c8:	72a080e7          	jalr	1834(ra) # 67ee <close>
    if(total == 0)
    60cc:	f20988e3          	beqz	s3,5ffc <fsfull+0xc8>
  for(nfiles = 0; ; nfiles++){
    60d0:	2485                	addiw	s1,s1,1
    60d2:	bd4d                	j	5f84 <fsfull+0x50>

00000000000060d4 <run>:
//

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    60d4:	7179                	addi	sp,sp,-48
    60d6:	f406                	sd	ra,40(sp)
    60d8:	f022                	sd	s0,32(sp)
    60da:	ec26                	sd	s1,24(sp)
    60dc:	e84a                	sd	s2,16(sp)
    60de:	1800                	addi	s0,sp,48
    60e0:	84aa                	mv	s1,a0
    60e2:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    60e4:	00003517          	auipc	a0,0x3
    60e8:	bac50513          	addi	a0,a0,-1108 # 8c90 <malloc+0x2064>
    60ec:	00001097          	auipc	ra,0x1
    60f0:	a82080e7          	jalr	-1406(ra) # 6b6e <printf>
  if((pid = fork()) < 0) {
    60f4:	00000097          	auipc	ra,0x0
    60f8:	6ca080e7          	jalr	1738(ra) # 67be <fork>
    60fc:	04054263          	bltz	a0,6140 <run+0x6c>
    printf("runtest: fork error\n");
    exit(1,"");
  }
  if(pid == 0) {
    6100:	c12d                	beqz	a0,6162 <run+0x8e>
    f(s);
    exit(0,"");
  } else {
    wait(&xstatus,"");
    6102:	00002597          	auipc	a1,0x2
    6106:	25658593          	addi	a1,a1,598 # 8358 <malloc+0x172c>
    610a:	fdc40513          	addi	a0,s0,-36
    610e:	00000097          	auipc	ra,0x0
    6112:	6c0080e7          	jalr	1728(ra) # 67ce <wait>
    if(xstatus != 0) 
    6116:	fdc42783          	lw	a5,-36(s0)
    611a:	cfb9                	beqz	a5,6178 <run+0xa4>
      printf("FAILED\n");
    611c:	00003517          	auipc	a0,0x3
    6120:	b9c50513          	addi	a0,a0,-1124 # 8cb8 <malloc+0x208c>
    6124:	00001097          	auipc	ra,0x1
    6128:	a4a080e7          	jalr	-1462(ra) # 6b6e <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    612c:	fdc42503          	lw	a0,-36(s0)
  }
}
    6130:	00153513          	seqz	a0,a0
    6134:	70a2                	ld	ra,40(sp)
    6136:	7402                	ld	s0,32(sp)
    6138:	64e2                	ld	s1,24(sp)
    613a:	6942                	ld	s2,16(sp)
    613c:	6145                	addi	sp,sp,48
    613e:	8082                	ret
    printf("runtest: fork error\n");
    6140:	00003517          	auipc	a0,0x3
    6144:	b6050513          	addi	a0,a0,-1184 # 8ca0 <malloc+0x2074>
    6148:	00001097          	auipc	ra,0x1
    614c:	a26080e7          	jalr	-1498(ra) # 6b6e <printf>
    exit(1,"");
    6150:	00002597          	auipc	a1,0x2
    6154:	20858593          	addi	a1,a1,520 # 8358 <malloc+0x172c>
    6158:	4505                	li	a0,1
    615a:	00000097          	auipc	ra,0x0
    615e:	66c080e7          	jalr	1644(ra) # 67c6 <exit>
    f(s);
    6162:	854a                	mv	a0,s2
    6164:	9482                	jalr	s1
    exit(0,"");
    6166:	00002597          	auipc	a1,0x2
    616a:	1f258593          	addi	a1,a1,498 # 8358 <malloc+0x172c>
    616e:	4501                	li	a0,0
    6170:	00000097          	auipc	ra,0x0
    6174:	656080e7          	jalr	1622(ra) # 67c6 <exit>
      printf("OK\n");
    6178:	00003517          	auipc	a0,0x3
    617c:	b4850513          	addi	a0,a0,-1208 # 8cc0 <malloc+0x2094>
    6180:	00001097          	auipc	ra,0x1
    6184:	9ee080e7          	jalr	-1554(ra) # 6b6e <printf>
    6188:	b755                	j	612c <run+0x58>

000000000000618a <runtests>:

int
runtests(struct test *tests, char *justone) {
    618a:	1101                	addi	sp,sp,-32
    618c:	ec06                	sd	ra,24(sp)
    618e:	e822                	sd	s0,16(sp)
    6190:	e426                	sd	s1,8(sp)
    6192:	e04a                	sd	s2,0(sp)
    6194:	1000                	addi	s0,sp,32
    6196:	84aa                	mv	s1,a0
    6198:	892e                	mv	s2,a1
  for (struct test *t = tests; t->s != 0; t++) {
    619a:	6508                	ld	a0,8(a0)
    619c:	ed09                	bnez	a0,61b6 <runtests+0x2c>
        printf("SOME TESTS FAILED\n");
        return 1;
      }
    }
  }
  return 0;
    619e:	4501                	li	a0,0
    61a0:	a82d                	j	61da <runtests+0x50>
      if(!run(t->f, t->s)){
    61a2:	648c                	ld	a1,8(s1)
    61a4:	6088                	ld	a0,0(s1)
    61a6:	00000097          	auipc	ra,0x0
    61aa:	f2e080e7          	jalr	-210(ra) # 60d4 <run>
    61ae:	cd09                	beqz	a0,61c8 <runtests+0x3e>
  for (struct test *t = tests; t->s != 0; t++) {
    61b0:	04c1                	addi	s1,s1,16
    61b2:	6488                	ld	a0,8(s1)
    61b4:	c11d                	beqz	a0,61da <runtests+0x50>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    61b6:	fe0906e3          	beqz	s2,61a2 <runtests+0x18>
    61ba:	85ca                	mv	a1,s2
    61bc:	00000097          	auipc	ra,0x0
    61c0:	3b8080e7          	jalr	952(ra) # 6574 <strcmp>
    61c4:	f575                	bnez	a0,61b0 <runtests+0x26>
    61c6:	bff1                	j	61a2 <runtests+0x18>
        printf("SOME TESTS FAILED\n");
    61c8:	00003517          	auipc	a0,0x3
    61cc:	b0050513          	addi	a0,a0,-1280 # 8cc8 <malloc+0x209c>
    61d0:	00001097          	auipc	ra,0x1
    61d4:	99e080e7          	jalr	-1634(ra) # 6b6e <printf>
        return 1;
    61d8:	4505                	li	a0,1
}
    61da:	60e2                	ld	ra,24(sp)
    61dc:	6442                	ld	s0,16(sp)
    61de:	64a2                	ld	s1,8(sp)
    61e0:	6902                	ld	s2,0(sp)
    61e2:	6105                	addi	sp,sp,32
    61e4:	8082                	ret

00000000000061e6 <countfree>:
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int
countfree()
{
    61e6:	7139                	addi	sp,sp,-64
    61e8:	fc06                	sd	ra,56(sp)
    61ea:	f822                	sd	s0,48(sp)
    61ec:	f426                	sd	s1,40(sp)
    61ee:	f04a                	sd	s2,32(sp)
    61f0:	ec4e                	sd	s3,24(sp)
    61f2:	0080                	addi	s0,sp,64
  int fds[2];

  if(pipe(fds) < 0){
    61f4:	fc840513          	addi	a0,s0,-56
    61f8:	00000097          	auipc	ra,0x0
    61fc:	5de080e7          	jalr	1502(ra) # 67d6 <pipe>
    6200:	06054b63          	bltz	a0,6276 <countfree+0x90>
    printf("pipe() failed in countfree()\n");
    exit(1,"");
  }
  
  int pid = fork();
    6204:	00000097          	auipc	ra,0x0
    6208:	5ba080e7          	jalr	1466(ra) # 67be <fork>

  if(pid < 0){
    620c:	08054663          	bltz	a0,6298 <countfree+0xb2>
    printf("fork failed in countfree()\n");
    exit(1,"");
  }

  if(pid == 0){
    6210:	ed55                	bnez	a0,62cc <countfree+0xe6>
    close(fds[0]);
    6212:	fc842503          	lw	a0,-56(s0)
    6216:	00000097          	auipc	ra,0x0
    621a:	5d8080e7          	jalr	1496(ra) # 67ee <close>
    
    while(1){
      uint64 a = (uint64) sbrk(4096);
      if(a == 0xffffffffffffffff){
    621e:	597d                	li	s2,-1
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    6220:	4485                	li	s1,1

      // report back one more page.
      if(write(fds[1], "x", 1) != 1){
    6222:	00001997          	auipc	s3,0x1
    6226:	bb698993          	addi	s3,s3,-1098 # 6dd8 <malloc+0x1ac>
      uint64 a = (uint64) sbrk(4096);
    622a:	6505                	lui	a0,0x1
    622c:	00000097          	auipc	ra,0x0
    6230:	622080e7          	jalr	1570(ra) # 684e <sbrk>
      if(a == 0xffffffffffffffff){
    6234:	09250363          	beq	a0,s2,62ba <countfree+0xd4>
      *(char *)(a + 4096 - 1) = 1;
    6238:	6785                	lui	a5,0x1
    623a:	953e                	add	a0,a0,a5
    623c:	fe950fa3          	sb	s1,-1(a0) # fff <unlinkread+0x187>
      if(write(fds[1], "x", 1) != 1){
    6240:	8626                	mv	a2,s1
    6242:	85ce                	mv	a1,s3
    6244:	fcc42503          	lw	a0,-52(s0)
    6248:	00000097          	auipc	ra,0x0
    624c:	59e080e7          	jalr	1438(ra) # 67e6 <write>
    6250:	fc950de3          	beq	a0,s1,622a <countfree+0x44>
        printf("write() failed in countfree()\n");
    6254:	00003517          	auipc	a0,0x3
    6258:	acc50513          	addi	a0,a0,-1332 # 8d20 <malloc+0x20f4>
    625c:	00001097          	auipc	ra,0x1
    6260:	912080e7          	jalr	-1774(ra) # 6b6e <printf>
        exit(1,"");
    6264:	00002597          	auipc	a1,0x2
    6268:	0f458593          	addi	a1,a1,244 # 8358 <malloc+0x172c>
    626c:	4505                	li	a0,1
    626e:	00000097          	auipc	ra,0x0
    6272:	558080e7          	jalr	1368(ra) # 67c6 <exit>
    printf("pipe() failed in countfree()\n");
    6276:	00003517          	auipc	a0,0x3
    627a:	a6a50513          	addi	a0,a0,-1430 # 8ce0 <malloc+0x20b4>
    627e:	00001097          	auipc	ra,0x1
    6282:	8f0080e7          	jalr	-1808(ra) # 6b6e <printf>
    exit(1,"");
    6286:	00002597          	auipc	a1,0x2
    628a:	0d258593          	addi	a1,a1,210 # 8358 <malloc+0x172c>
    628e:	4505                	li	a0,1
    6290:	00000097          	auipc	ra,0x0
    6294:	536080e7          	jalr	1334(ra) # 67c6 <exit>
    printf("fork failed in countfree()\n");
    6298:	00003517          	auipc	a0,0x3
    629c:	a6850513          	addi	a0,a0,-1432 # 8d00 <malloc+0x20d4>
    62a0:	00001097          	auipc	ra,0x1
    62a4:	8ce080e7          	jalr	-1842(ra) # 6b6e <printf>
    exit(1,"");
    62a8:	00002597          	auipc	a1,0x2
    62ac:	0b058593          	addi	a1,a1,176 # 8358 <malloc+0x172c>
    62b0:	4505                	li	a0,1
    62b2:	00000097          	auipc	ra,0x0
    62b6:	514080e7          	jalr	1300(ra) # 67c6 <exit>
      }
    }

    exit(0,"");
    62ba:	00002597          	auipc	a1,0x2
    62be:	09e58593          	addi	a1,a1,158 # 8358 <malloc+0x172c>
    62c2:	4501                	li	a0,0
    62c4:	00000097          	auipc	ra,0x0
    62c8:	502080e7          	jalr	1282(ra) # 67c6 <exit>
  }

  close(fds[1]);
    62cc:	fcc42503          	lw	a0,-52(s0)
    62d0:	00000097          	auipc	ra,0x0
    62d4:	51e080e7          	jalr	1310(ra) # 67ee <close>

  int n = 0;
    62d8:	4481                	li	s1,0
  while(1){
    char c;
    int cc = read(fds[0], &c, 1);
    62da:	4605                	li	a2,1
    62dc:	fc740593          	addi	a1,s0,-57
    62e0:	fc842503          	lw	a0,-56(s0)
    62e4:	00000097          	auipc	ra,0x0
    62e8:	4fa080e7          	jalr	1274(ra) # 67de <read>
    if(cc < 0){
    62ec:	00054563          	bltz	a0,62f6 <countfree+0x110>
      printf("read() failed in countfree()\n");
      exit(1,"");
    }
    if(cc == 0)
    62f0:	c505                	beqz	a0,6318 <countfree+0x132>
      break;
    n += 1;
    62f2:	2485                	addiw	s1,s1,1
  while(1){
    62f4:	b7dd                	j	62da <countfree+0xf4>
      printf("read() failed in countfree()\n");
    62f6:	00003517          	auipc	a0,0x3
    62fa:	a4a50513          	addi	a0,a0,-1462 # 8d40 <malloc+0x2114>
    62fe:	00001097          	auipc	ra,0x1
    6302:	870080e7          	jalr	-1936(ra) # 6b6e <printf>
      exit(1,"");
    6306:	00002597          	auipc	a1,0x2
    630a:	05258593          	addi	a1,a1,82 # 8358 <malloc+0x172c>
    630e:	4505                	li	a0,1
    6310:	00000097          	auipc	ra,0x0
    6314:	4b6080e7          	jalr	1206(ra) # 67c6 <exit>
  }

  close(fds[0]);
    6318:	fc842503          	lw	a0,-56(s0)
    631c:	00000097          	auipc	ra,0x0
    6320:	4d2080e7          	jalr	1234(ra) # 67ee <close>
  wait((int*)0,"");
    6324:	00002597          	auipc	a1,0x2
    6328:	03458593          	addi	a1,a1,52 # 8358 <malloc+0x172c>
    632c:	4501                	li	a0,0
    632e:	00000097          	auipc	ra,0x0
    6332:	4a0080e7          	jalr	1184(ra) # 67ce <wait>
  
  return n;
}
    6336:	8526                	mv	a0,s1
    6338:	70e2                	ld	ra,56(sp)
    633a:	7442                	ld	s0,48(sp)
    633c:	74a2                	ld	s1,40(sp)
    633e:	7902                	ld	s2,32(sp)
    6340:	69e2                	ld	s3,24(sp)
    6342:	6121                	addi	sp,sp,64
    6344:	8082                	ret

0000000000006346 <drivetests>:

int
drivetests(int quick, int continuous, char *justone) {
    6346:	711d                	addi	sp,sp,-96
    6348:	ec86                	sd	ra,88(sp)
    634a:	e8a2                	sd	s0,80(sp)
    634c:	e4a6                	sd	s1,72(sp)
    634e:	e0ca                	sd	s2,64(sp)
    6350:	fc4e                	sd	s3,56(sp)
    6352:	f852                	sd	s4,48(sp)
    6354:	f456                	sd	s5,40(sp)
    6356:	f05a                	sd	s6,32(sp)
    6358:	ec5e                	sd	s7,24(sp)
    635a:	e862                	sd	s8,16(sp)
    635c:	e466                	sd	s9,8(sp)
    635e:	e06a                	sd	s10,0(sp)
    6360:	1080                	addi	s0,sp,96
    6362:	8a2a                	mv	s4,a0
    6364:	89ae                	mv	s3,a1
    6366:	8932                	mv	s2,a2
  do {
    printf("usertests starting\n");
    6368:	00003b97          	auipc	s7,0x3
    636c:	9f8b8b93          	addi	s7,s7,-1544 # 8d60 <malloc+0x2134>
    int free0 = countfree();
    int free1 = 0;
    if (runtests(quicktests, justone)) {
    6370:	00004b17          	auipc	s6,0x4
    6374:	ca0b0b13          	addi	s6,s6,-864 # a010 <quicktests>
      if(continuous != 2) {
    6378:	4a89                	li	s5,2
          return 1;
        }
      }
    }
    if((free1 = countfree()) < free0) {
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    637a:	00003c97          	auipc	s9,0x3
    637e:	a1ec8c93          	addi	s9,s9,-1506 # 8d98 <malloc+0x216c>
      if (runtests(slowtests, justone)) {
    6382:	00004c17          	auipc	s8,0x4
    6386:	05ec0c13          	addi	s8,s8,94 # a3e0 <slowtests>
        printf("usertests slow tests starting\n");
    638a:	00003d17          	auipc	s10,0x3
    638e:	9eed0d13          	addi	s10,s10,-1554 # 8d78 <malloc+0x214c>
    6392:	a839                	j	63b0 <drivetests+0x6a>
    6394:	856a                	mv	a0,s10
    6396:	00000097          	auipc	ra,0x0
    639a:	7d8080e7          	jalr	2008(ra) # 6b6e <printf>
    639e:	a081                	j	63de <drivetests+0x98>
    if((free1 = countfree()) < free0) {
    63a0:	00000097          	auipc	ra,0x0
    63a4:	e46080e7          	jalr	-442(ra) # 61e6 <countfree>
    63a8:	06954263          	blt	a0,s1,640c <drivetests+0xc6>
      if(continuous != 2) {
        return 1;
      }
    }
  } while(continuous);
    63ac:	06098f63          	beqz	s3,642a <drivetests+0xe4>
    printf("usertests starting\n");
    63b0:	855e                	mv	a0,s7
    63b2:	00000097          	auipc	ra,0x0
    63b6:	7bc080e7          	jalr	1980(ra) # 6b6e <printf>
    int free0 = countfree();
    63ba:	00000097          	auipc	ra,0x0
    63be:	e2c080e7          	jalr	-468(ra) # 61e6 <countfree>
    63c2:	84aa                	mv	s1,a0
    if (runtests(quicktests, justone)) {
    63c4:	85ca                	mv	a1,s2
    63c6:	855a                	mv	a0,s6
    63c8:	00000097          	auipc	ra,0x0
    63cc:	dc2080e7          	jalr	-574(ra) # 618a <runtests>
    63d0:	c119                	beqz	a0,63d6 <drivetests+0x90>
      if(continuous != 2) {
    63d2:	05599863          	bne	s3,s5,6422 <drivetests+0xdc>
    if(!quick) {
    63d6:	fc0a15e3          	bnez	s4,63a0 <drivetests+0x5a>
      if (justone == 0)
    63da:	fa090de3          	beqz	s2,6394 <drivetests+0x4e>
      if (runtests(slowtests, justone)) {
    63de:	85ca                	mv	a1,s2
    63e0:	8562                	mv	a0,s8
    63e2:	00000097          	auipc	ra,0x0
    63e6:	da8080e7          	jalr	-600(ra) # 618a <runtests>
    63ea:	d95d                	beqz	a0,63a0 <drivetests+0x5a>
        if(continuous != 2) {
    63ec:	03599d63          	bne	s3,s5,6426 <drivetests+0xe0>
    if((free1 = countfree()) < free0) {
    63f0:	00000097          	auipc	ra,0x0
    63f4:	df6080e7          	jalr	-522(ra) # 61e6 <countfree>
    63f8:	fa955ae3          	bge	a0,s1,63ac <drivetests+0x66>
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    63fc:	8626                	mv	a2,s1
    63fe:	85aa                	mv	a1,a0
    6400:	8566                	mv	a0,s9
    6402:	00000097          	auipc	ra,0x0
    6406:	76c080e7          	jalr	1900(ra) # 6b6e <printf>
      if(continuous != 2) {
    640a:	b75d                	j	63b0 <drivetests+0x6a>
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    640c:	8626                	mv	a2,s1
    640e:	85aa                	mv	a1,a0
    6410:	8566                	mv	a0,s9
    6412:	00000097          	auipc	ra,0x0
    6416:	75c080e7          	jalr	1884(ra) # 6b6e <printf>
      if(continuous != 2) {
    641a:	f9598be3          	beq	s3,s5,63b0 <drivetests+0x6a>
        return 1;
    641e:	4505                	li	a0,1
    6420:	a031                	j	642c <drivetests+0xe6>
        return 1;
    6422:	4505                	li	a0,1
    6424:	a021                	j	642c <drivetests+0xe6>
          return 1;
    6426:	4505                	li	a0,1
    6428:	a011                	j	642c <drivetests+0xe6>
  return 0;
    642a:	854e                	mv	a0,s3
}
    642c:	60e6                	ld	ra,88(sp)
    642e:	6446                	ld	s0,80(sp)
    6430:	64a6                	ld	s1,72(sp)
    6432:	6906                	ld	s2,64(sp)
    6434:	79e2                	ld	s3,56(sp)
    6436:	7a42                	ld	s4,48(sp)
    6438:	7aa2                	ld	s5,40(sp)
    643a:	7b02                	ld	s6,32(sp)
    643c:	6be2                	ld	s7,24(sp)
    643e:	6c42                	ld	s8,16(sp)
    6440:	6ca2                	ld	s9,8(sp)
    6442:	6d02                	ld	s10,0(sp)
    6444:	6125                	addi	sp,sp,96
    6446:	8082                	ret

0000000000006448 <main>:

int
main(int argc, char *argv[])
{
    6448:	1101                	addi	sp,sp,-32
    644a:	ec06                	sd	ra,24(sp)
    644c:	e822                	sd	s0,16(sp)
    644e:	e426                	sd	s1,8(sp)
    6450:	e04a                	sd	s2,0(sp)
    6452:	1000                	addi	s0,sp,32
    6454:	84aa                	mv	s1,a0
  int continuous = 0;
  int quick = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-q") == 0){
    6456:	4789                	li	a5,2
    6458:	02f50763          	beq	a0,a5,6486 <main+0x3e>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    645c:	4785                	li	a5,1
    645e:	08a7c163          	blt	a5,a0,64e0 <main+0x98>
  char *justone = 0;
    6462:	4601                	li	a2,0
  int quick = 0;
    6464:	4501                	li	a0,0
  int continuous = 0;
    6466:	4481                	li	s1,0
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    exit(1,"");
  }
  if (drivetests(quick, continuous, justone)) {
    6468:	85a6                	mv	a1,s1
    646a:	00000097          	auipc	ra,0x0
    646e:	edc080e7          	jalr	-292(ra) # 6346 <drivetests>
    6472:	c14d                	beqz	a0,6514 <main+0xcc>
    exit(1,"");
    6474:	00002597          	auipc	a1,0x2
    6478:	ee458593          	addi	a1,a1,-284 # 8358 <malloc+0x172c>
    647c:	4505                	li	a0,1
    647e:	00000097          	auipc	ra,0x0
    6482:	348080e7          	jalr	840(ra) # 67c6 <exit>
    6486:	892e                	mv	s2,a1
  if(argc == 2 && strcmp(argv[1], "-q") == 0){
    6488:	00003597          	auipc	a1,0x3
    648c:	94058593          	addi	a1,a1,-1728 # 8dc8 <malloc+0x219c>
    6490:	00893503          	ld	a0,8(s2)
    6494:	00000097          	auipc	ra,0x0
    6498:	0e0080e7          	jalr	224(ra) # 6574 <strcmp>
    649c:	c13d                	beqz	a0,6502 <main+0xba>
  } else if(argc == 2 && strcmp(argv[1], "-c") == 0){
    649e:	00003597          	auipc	a1,0x3
    64a2:	98258593          	addi	a1,a1,-1662 # 8e20 <malloc+0x21f4>
    64a6:	00893503          	ld	a0,8(s2)
    64aa:	00000097          	auipc	ra,0x0
    64ae:	0ca080e7          	jalr	202(ra) # 6574 <strcmp>
    64b2:	cd31                	beqz	a0,650e <main+0xc6>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    64b4:	00003597          	auipc	a1,0x3
    64b8:	96458593          	addi	a1,a1,-1692 # 8e18 <malloc+0x21ec>
    64bc:	00893503          	ld	a0,8(s2)
    64c0:	00000097          	auipc	ra,0x0
    64c4:	0b4080e7          	jalr	180(ra) # 6574 <strcmp>
    64c8:	c129                	beqz	a0,650a <main+0xc2>
  } else if(argc == 2 && argv[1][0] != '-'){
    64ca:	00893603          	ld	a2,8(s2)
    64ce:	00064703          	lbu	a4,0(a2) # 3000 <sbrkbasic+0x1a0>
    64d2:	02d00793          	li	a5,45
    64d6:	00f70563          	beq	a4,a5,64e0 <main+0x98>
  int quick = 0;
    64da:	4501                	li	a0,0
  int continuous = 0;
    64dc:	4481                	li	s1,0
    64de:	b769                	j	6468 <main+0x20>
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    64e0:	00003517          	auipc	a0,0x3
    64e4:	8f050513          	addi	a0,a0,-1808 # 8dd0 <malloc+0x21a4>
    64e8:	00000097          	auipc	ra,0x0
    64ec:	686080e7          	jalr	1670(ra) # 6b6e <printf>
    exit(1,"");
    64f0:	00002597          	auipc	a1,0x2
    64f4:	e6858593          	addi	a1,a1,-408 # 8358 <malloc+0x172c>
    64f8:	4505                	li	a0,1
    64fa:	00000097          	auipc	ra,0x0
    64fe:	2cc080e7          	jalr	716(ra) # 67c6 <exit>
  int continuous = 0;
    6502:	84aa                	mv	s1,a0
  char *justone = 0;
    6504:	4601                	li	a2,0
    quick = 1;
    6506:	4505                	li	a0,1
    6508:	b785                	j	6468 <main+0x20>
  char *justone = 0;
    650a:	4601                	li	a2,0
    650c:	bfb1                	j	6468 <main+0x20>
    650e:	4601                	li	a2,0
    continuous = 1;
    6510:	4485                	li	s1,1
    6512:	bf99                	j	6468 <main+0x20>
  }
  printf("ALL TESTS PASSED\n");
    6514:	00003517          	auipc	a0,0x3
    6518:	8ec50513          	addi	a0,a0,-1812 # 8e00 <malloc+0x21d4>
    651c:	00000097          	auipc	ra,0x0
    6520:	652080e7          	jalr	1618(ra) # 6b6e <printf>
  exit(0,"");
    6524:	00002597          	auipc	a1,0x2
    6528:	e3458593          	addi	a1,a1,-460 # 8358 <malloc+0x172c>
    652c:	4501                	li	a0,0
    652e:	00000097          	auipc	ra,0x0
    6532:	298080e7          	jalr	664(ra) # 67c6 <exit>

0000000000006536 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
    6536:	1141                	addi	sp,sp,-16
    6538:	e406                	sd	ra,8(sp)
    653a:	e022                	sd	s0,0(sp)
    653c:	0800                	addi	s0,sp,16
  extern int main();
  main();
    653e:	00000097          	auipc	ra,0x0
    6542:	f0a080e7          	jalr	-246(ra) # 6448 <main>
  exit(0,"");
    6546:	00002597          	auipc	a1,0x2
    654a:	e1258593          	addi	a1,a1,-494 # 8358 <malloc+0x172c>
    654e:	4501                	li	a0,0
    6550:	00000097          	auipc	ra,0x0
    6554:	276080e7          	jalr	630(ra) # 67c6 <exit>

0000000000006558 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
    6558:	1141                	addi	sp,sp,-16
    655a:	e422                	sd	s0,8(sp)
    655c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    655e:	87aa                	mv	a5,a0
    6560:	0585                	addi	a1,a1,1
    6562:	0785                	addi	a5,a5,1
    6564:	fff5c703          	lbu	a4,-1(a1)
    6568:	fee78fa3          	sb	a4,-1(a5) # fff <unlinkread+0x187>
    656c:	fb75                	bnez	a4,6560 <strcpy+0x8>
    ;
  return os;
}
    656e:	6422                	ld	s0,8(sp)
    6570:	0141                	addi	sp,sp,16
    6572:	8082                	ret

0000000000006574 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    6574:	1141                	addi	sp,sp,-16
    6576:	e422                	sd	s0,8(sp)
    6578:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    657a:	00054783          	lbu	a5,0(a0)
    657e:	cb91                	beqz	a5,6592 <strcmp+0x1e>
    6580:	0005c703          	lbu	a4,0(a1)
    6584:	00f71763          	bne	a4,a5,6592 <strcmp+0x1e>
    p++, q++;
    6588:	0505                	addi	a0,a0,1
    658a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    658c:	00054783          	lbu	a5,0(a0)
    6590:	fbe5                	bnez	a5,6580 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    6592:	0005c503          	lbu	a0,0(a1)
}
    6596:	40a7853b          	subw	a0,a5,a0
    659a:	6422                	ld	s0,8(sp)
    659c:	0141                	addi	sp,sp,16
    659e:	8082                	ret

00000000000065a0 <strlen>:

uint
strlen(const char *s)
{
    65a0:	1141                	addi	sp,sp,-16
    65a2:	e422                	sd	s0,8(sp)
    65a4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    65a6:	00054783          	lbu	a5,0(a0)
    65aa:	cf91                	beqz	a5,65c6 <strlen+0x26>
    65ac:	0505                	addi	a0,a0,1
    65ae:	87aa                	mv	a5,a0
    65b0:	4685                	li	a3,1
    65b2:	9e89                	subw	a3,a3,a0
    65b4:	00f6853b          	addw	a0,a3,a5
    65b8:	0785                	addi	a5,a5,1
    65ba:	fff7c703          	lbu	a4,-1(a5)
    65be:	fb7d                	bnez	a4,65b4 <strlen+0x14>
    ;
  return n;
}
    65c0:	6422                	ld	s0,8(sp)
    65c2:	0141                	addi	sp,sp,16
    65c4:	8082                	ret
  for(n = 0; s[n]; n++)
    65c6:	4501                	li	a0,0
    65c8:	bfe5                	j	65c0 <strlen+0x20>

00000000000065ca <memset>:

void*
memset(void *dst, int c, uint n)
{
    65ca:	1141                	addi	sp,sp,-16
    65cc:	e422                	sd	s0,8(sp)
    65ce:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    65d0:	ca19                	beqz	a2,65e6 <memset+0x1c>
    65d2:	87aa                	mv	a5,a0
    65d4:	1602                	slli	a2,a2,0x20
    65d6:	9201                	srli	a2,a2,0x20
    65d8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    65dc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    65e0:	0785                	addi	a5,a5,1
    65e2:	fee79de3          	bne	a5,a4,65dc <memset+0x12>
  }
  return dst;
}
    65e6:	6422                	ld	s0,8(sp)
    65e8:	0141                	addi	sp,sp,16
    65ea:	8082                	ret

00000000000065ec <strchr>:

char*
strchr(const char *s, char c)
{
    65ec:	1141                	addi	sp,sp,-16
    65ee:	e422                	sd	s0,8(sp)
    65f0:	0800                	addi	s0,sp,16
  for(; *s; s++)
    65f2:	00054783          	lbu	a5,0(a0)
    65f6:	cb99                	beqz	a5,660c <strchr+0x20>
    if(*s == c)
    65f8:	00f58763          	beq	a1,a5,6606 <strchr+0x1a>
  for(; *s; s++)
    65fc:	0505                	addi	a0,a0,1
    65fe:	00054783          	lbu	a5,0(a0)
    6602:	fbfd                	bnez	a5,65f8 <strchr+0xc>
      return (char*)s;
  return 0;
    6604:	4501                	li	a0,0
}
    6606:	6422                	ld	s0,8(sp)
    6608:	0141                	addi	sp,sp,16
    660a:	8082                	ret
  return 0;
    660c:	4501                	li	a0,0
    660e:	bfe5                	j	6606 <strchr+0x1a>

0000000000006610 <gets>:

char*
gets(char *buf, int max)
{
    6610:	711d                	addi	sp,sp,-96
    6612:	ec86                	sd	ra,88(sp)
    6614:	e8a2                	sd	s0,80(sp)
    6616:	e4a6                	sd	s1,72(sp)
    6618:	e0ca                	sd	s2,64(sp)
    661a:	fc4e                	sd	s3,56(sp)
    661c:	f852                	sd	s4,48(sp)
    661e:	f456                	sd	s5,40(sp)
    6620:	f05a                	sd	s6,32(sp)
    6622:	ec5e                	sd	s7,24(sp)
    6624:	1080                	addi	s0,sp,96
    6626:	8baa                	mv	s7,a0
    6628:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    662a:	892a                	mv	s2,a0
    662c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    662e:	4aa9                	li	s5,10
    6630:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    6632:	89a6                	mv	s3,s1
    6634:	2485                	addiw	s1,s1,1
    6636:	0344d863          	bge	s1,s4,6666 <gets+0x56>
    cc = read(0, &c, 1);
    663a:	4605                	li	a2,1
    663c:	faf40593          	addi	a1,s0,-81
    6640:	4501                	li	a0,0
    6642:	00000097          	auipc	ra,0x0
    6646:	19c080e7          	jalr	412(ra) # 67de <read>
    if(cc < 1)
    664a:	00a05e63          	blez	a0,6666 <gets+0x56>
    buf[i++] = c;
    664e:	faf44783          	lbu	a5,-81(s0)
    6652:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    6656:	01578763          	beq	a5,s5,6664 <gets+0x54>
    665a:	0905                	addi	s2,s2,1
    665c:	fd679be3          	bne	a5,s6,6632 <gets+0x22>
  for(i=0; i+1 < max; ){
    6660:	89a6                	mv	s3,s1
    6662:	a011                	j	6666 <gets+0x56>
    6664:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    6666:	99de                	add	s3,s3,s7
    6668:	00098023          	sb	zero,0(s3)
  return buf;
}
    666c:	855e                	mv	a0,s7
    666e:	60e6                	ld	ra,88(sp)
    6670:	6446                	ld	s0,80(sp)
    6672:	64a6                	ld	s1,72(sp)
    6674:	6906                	ld	s2,64(sp)
    6676:	79e2                	ld	s3,56(sp)
    6678:	7a42                	ld	s4,48(sp)
    667a:	7aa2                	ld	s5,40(sp)
    667c:	7b02                	ld	s6,32(sp)
    667e:	6be2                	ld	s7,24(sp)
    6680:	6125                	addi	sp,sp,96
    6682:	8082                	ret

0000000000006684 <stat>:

int
stat(const char *n, struct stat *st)
{
    6684:	1101                	addi	sp,sp,-32
    6686:	ec06                	sd	ra,24(sp)
    6688:	e822                	sd	s0,16(sp)
    668a:	e426                	sd	s1,8(sp)
    668c:	e04a                	sd	s2,0(sp)
    668e:	1000                	addi	s0,sp,32
    6690:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    6692:	4581                	li	a1,0
    6694:	00000097          	auipc	ra,0x0
    6698:	172080e7          	jalr	370(ra) # 6806 <open>
  if(fd < 0)
    669c:	02054563          	bltz	a0,66c6 <stat+0x42>
    66a0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    66a2:	85ca                	mv	a1,s2
    66a4:	00000097          	auipc	ra,0x0
    66a8:	17a080e7          	jalr	378(ra) # 681e <fstat>
    66ac:	892a                	mv	s2,a0
  close(fd);
    66ae:	8526                	mv	a0,s1
    66b0:	00000097          	auipc	ra,0x0
    66b4:	13e080e7          	jalr	318(ra) # 67ee <close>
  return r;
}
    66b8:	854a                	mv	a0,s2
    66ba:	60e2                	ld	ra,24(sp)
    66bc:	6442                	ld	s0,16(sp)
    66be:	64a2                	ld	s1,8(sp)
    66c0:	6902                	ld	s2,0(sp)
    66c2:	6105                	addi	sp,sp,32
    66c4:	8082                	ret
    return -1;
    66c6:	597d                	li	s2,-1
    66c8:	bfc5                	j	66b8 <stat+0x34>

00000000000066ca <atoi>:

int
atoi(const char *s)
{
    66ca:	1141                	addi	sp,sp,-16
    66cc:	e422                	sd	s0,8(sp)
    66ce:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    66d0:	00054603          	lbu	a2,0(a0)
    66d4:	fd06079b          	addiw	a5,a2,-48
    66d8:	0ff7f793          	andi	a5,a5,255
    66dc:	4725                	li	a4,9
    66de:	02f76963          	bltu	a4,a5,6710 <atoi+0x46>
    66e2:	86aa                	mv	a3,a0
  n = 0;
    66e4:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    66e6:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    66e8:	0685                	addi	a3,a3,1
    66ea:	0025179b          	slliw	a5,a0,0x2
    66ee:	9fa9                	addw	a5,a5,a0
    66f0:	0017979b          	slliw	a5,a5,0x1
    66f4:	9fb1                	addw	a5,a5,a2
    66f6:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    66fa:	0006c603          	lbu	a2,0(a3)
    66fe:	fd06071b          	addiw	a4,a2,-48
    6702:	0ff77713          	andi	a4,a4,255
    6706:	fee5f1e3          	bgeu	a1,a4,66e8 <atoi+0x1e>
  return n;
}
    670a:	6422                	ld	s0,8(sp)
    670c:	0141                	addi	sp,sp,16
    670e:	8082                	ret
  n = 0;
    6710:	4501                	li	a0,0
    6712:	bfe5                	j	670a <atoi+0x40>

0000000000006714 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    6714:	1141                	addi	sp,sp,-16
    6716:	e422                	sd	s0,8(sp)
    6718:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    671a:	02b57463          	bgeu	a0,a1,6742 <memmove+0x2e>
    while(n-- > 0)
    671e:	00c05f63          	blez	a2,673c <memmove+0x28>
    6722:	1602                	slli	a2,a2,0x20
    6724:	9201                	srli	a2,a2,0x20
    6726:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    672a:	872a                	mv	a4,a0
      *dst++ = *src++;
    672c:	0585                	addi	a1,a1,1
    672e:	0705                	addi	a4,a4,1
    6730:	fff5c683          	lbu	a3,-1(a1)
    6734:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    6738:	fee79ae3          	bne	a5,a4,672c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    673c:	6422                	ld	s0,8(sp)
    673e:	0141                	addi	sp,sp,16
    6740:	8082                	ret
    dst += n;
    6742:	00c50733          	add	a4,a0,a2
    src += n;
    6746:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    6748:	fec05ae3          	blez	a2,673c <memmove+0x28>
    674c:	fff6079b          	addiw	a5,a2,-1
    6750:	1782                	slli	a5,a5,0x20
    6752:	9381                	srli	a5,a5,0x20
    6754:	fff7c793          	not	a5,a5
    6758:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    675a:	15fd                	addi	a1,a1,-1
    675c:	177d                	addi	a4,a4,-1
    675e:	0005c683          	lbu	a3,0(a1)
    6762:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    6766:	fee79ae3          	bne	a5,a4,675a <memmove+0x46>
    676a:	bfc9                	j	673c <memmove+0x28>

000000000000676c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    676c:	1141                	addi	sp,sp,-16
    676e:	e422                	sd	s0,8(sp)
    6770:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    6772:	ca05                	beqz	a2,67a2 <memcmp+0x36>
    6774:	fff6069b          	addiw	a3,a2,-1
    6778:	1682                	slli	a3,a3,0x20
    677a:	9281                	srli	a3,a3,0x20
    677c:	0685                	addi	a3,a3,1
    677e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    6780:	00054783          	lbu	a5,0(a0)
    6784:	0005c703          	lbu	a4,0(a1)
    6788:	00e79863          	bne	a5,a4,6798 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    678c:	0505                	addi	a0,a0,1
    p2++;
    678e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    6790:	fed518e3          	bne	a0,a3,6780 <memcmp+0x14>
  }
  return 0;
    6794:	4501                	li	a0,0
    6796:	a019                	j	679c <memcmp+0x30>
      return *p1 - *p2;
    6798:	40e7853b          	subw	a0,a5,a4
}
    679c:	6422                	ld	s0,8(sp)
    679e:	0141                	addi	sp,sp,16
    67a0:	8082                	ret
  return 0;
    67a2:	4501                	li	a0,0
    67a4:	bfe5                	j	679c <memcmp+0x30>

00000000000067a6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    67a6:	1141                	addi	sp,sp,-16
    67a8:	e406                	sd	ra,8(sp)
    67aa:	e022                	sd	s0,0(sp)
    67ac:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    67ae:	00000097          	auipc	ra,0x0
    67b2:	f66080e7          	jalr	-154(ra) # 6714 <memmove>
}
    67b6:	60a2                	ld	ra,8(sp)
    67b8:	6402                	ld	s0,0(sp)
    67ba:	0141                	addi	sp,sp,16
    67bc:	8082                	ret

00000000000067be <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    67be:	4885                	li	a7,1
 ecall
    67c0:	00000073          	ecall
 ret
    67c4:	8082                	ret

00000000000067c6 <exit>:
.global exit
exit:
 li a7, SYS_exit
    67c6:	4889                	li	a7,2
 ecall
    67c8:	00000073          	ecall
 ret
    67cc:	8082                	ret

00000000000067ce <wait>:
.global wait
wait:
 li a7, SYS_wait
    67ce:	488d                	li	a7,3
 ecall
    67d0:	00000073          	ecall
 ret
    67d4:	8082                	ret

00000000000067d6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    67d6:	4891                	li	a7,4
 ecall
    67d8:	00000073          	ecall
 ret
    67dc:	8082                	ret

00000000000067de <read>:
.global read
read:
 li a7, SYS_read
    67de:	4895                	li	a7,5
 ecall
    67e0:	00000073          	ecall
 ret
    67e4:	8082                	ret

00000000000067e6 <write>:
.global write
write:
 li a7, SYS_write
    67e6:	48c1                	li	a7,16
 ecall
    67e8:	00000073          	ecall
 ret
    67ec:	8082                	ret

00000000000067ee <close>:
.global close
close:
 li a7, SYS_close
    67ee:	48d5                	li	a7,21
 ecall
    67f0:	00000073          	ecall
 ret
    67f4:	8082                	ret

00000000000067f6 <kill>:
.global kill
kill:
 li a7, SYS_kill
    67f6:	4899                	li	a7,6
 ecall
    67f8:	00000073          	ecall
 ret
    67fc:	8082                	ret

00000000000067fe <exec>:
.global exec
exec:
 li a7, SYS_exec
    67fe:	489d                	li	a7,7
 ecall
    6800:	00000073          	ecall
 ret
    6804:	8082                	ret

0000000000006806 <open>:
.global open
open:
 li a7, SYS_open
    6806:	48bd                	li	a7,15
 ecall
    6808:	00000073          	ecall
 ret
    680c:	8082                	ret

000000000000680e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    680e:	48c5                	li	a7,17
 ecall
    6810:	00000073          	ecall
 ret
    6814:	8082                	ret

0000000000006816 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    6816:	48c9                	li	a7,18
 ecall
    6818:	00000073          	ecall
 ret
    681c:	8082                	ret

000000000000681e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    681e:	48a1                	li	a7,8
 ecall
    6820:	00000073          	ecall
 ret
    6824:	8082                	ret

0000000000006826 <link>:
.global link
link:
 li a7, SYS_link
    6826:	48cd                	li	a7,19
 ecall
    6828:	00000073          	ecall
 ret
    682c:	8082                	ret

000000000000682e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    682e:	48d1                	li	a7,20
 ecall
    6830:	00000073          	ecall
 ret
    6834:	8082                	ret

0000000000006836 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    6836:	48a5                	li	a7,9
 ecall
    6838:	00000073          	ecall
 ret
    683c:	8082                	ret

000000000000683e <dup>:
.global dup
dup:
 li a7, SYS_dup
    683e:	48a9                	li	a7,10
 ecall
    6840:	00000073          	ecall
 ret
    6844:	8082                	ret

0000000000006846 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    6846:	48ad                	li	a7,11
 ecall
    6848:	00000073          	ecall
 ret
    684c:	8082                	ret

000000000000684e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    684e:	48b1                	li	a7,12
 ecall
    6850:	00000073          	ecall
 ret
    6854:	8082                	ret

0000000000006856 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    6856:	48b5                	li	a7,13
 ecall
    6858:	00000073          	ecall
 ret
    685c:	8082                	ret

000000000000685e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    685e:	48b9                	li	a7,14
 ecall
    6860:	00000073          	ecall
 ret
    6864:	8082                	ret

0000000000006866 <memsize>:
.global memsize
memsize:
 li a7, SYS_memsize
    6866:	48d9                	li	a7,22
 ecall
    6868:	00000073          	ecall
 ret
    686c:	8082                	ret

000000000000686e <set_ps_priority>:
.global set_ps_priority
set_ps_priority:
 li a7, SYS_set_ps_priority
    686e:	48dd                	li	a7,23
 ecall
    6870:	00000073          	ecall
 ret
    6874:	8082                	ret

0000000000006876 <set_cfs_priority>:
.global set_cfs_priority
set_cfs_priority:
 li a7, SYS_set_cfs_priority
    6876:	48e1                	li	a7,24
 ecall
    6878:	00000073          	ecall
 ret
    687c:	8082                	ret

000000000000687e <get_cfs_stats>:
.global get_cfs_stats
get_cfs_stats:
 li a7, SYS_get_cfs_stats
    687e:	48e5                	li	a7,25
 ecall
    6880:	00000073          	ecall
 ret
    6884:	8082                	ret

0000000000006886 <set_policy>:
.global set_policy
set_policy:
 li a7, SYS_set_policy
    6886:	48e9                	li	a7,26
 ecall
    6888:	00000073          	ecall
 ret
    688c:	8082                	ret

000000000000688e <get_ps_priority>:
.global get_ps_priority
get_ps_priority:
 li a7, SYS_get_ps_priority
    688e:	48ed                	li	a7,27
 ecall
    6890:	00000073          	ecall
 ret
    6894:	8082                	ret

0000000000006896 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    6896:	1101                	addi	sp,sp,-32
    6898:	ec06                	sd	ra,24(sp)
    689a:	e822                	sd	s0,16(sp)
    689c:	1000                	addi	s0,sp,32
    689e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    68a2:	4605                	li	a2,1
    68a4:	fef40593          	addi	a1,s0,-17
    68a8:	00000097          	auipc	ra,0x0
    68ac:	f3e080e7          	jalr	-194(ra) # 67e6 <write>
}
    68b0:	60e2                	ld	ra,24(sp)
    68b2:	6442                	ld	s0,16(sp)
    68b4:	6105                	addi	sp,sp,32
    68b6:	8082                	ret

00000000000068b8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    68b8:	7139                	addi	sp,sp,-64
    68ba:	fc06                	sd	ra,56(sp)
    68bc:	f822                	sd	s0,48(sp)
    68be:	f426                	sd	s1,40(sp)
    68c0:	f04a                	sd	s2,32(sp)
    68c2:	ec4e                	sd	s3,24(sp)
    68c4:	0080                	addi	s0,sp,64
    68c6:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    68c8:	c299                	beqz	a3,68ce <printint+0x16>
    68ca:	0805c863          	bltz	a1,695a <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    68ce:	2581                	sext.w	a1,a1
  neg = 0;
    68d0:	4881                	li	a7,0
    68d2:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    68d6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    68d8:	2601                	sext.w	a2,a2
    68da:	00003517          	auipc	a0,0x3
    68de:	8b650513          	addi	a0,a0,-1866 # 9190 <digits>
    68e2:	883a                	mv	a6,a4
    68e4:	2705                	addiw	a4,a4,1
    68e6:	02c5f7bb          	remuw	a5,a1,a2
    68ea:	1782                	slli	a5,a5,0x20
    68ec:	9381                	srli	a5,a5,0x20
    68ee:	97aa                	add	a5,a5,a0
    68f0:	0007c783          	lbu	a5,0(a5)
    68f4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    68f8:	0005879b          	sext.w	a5,a1
    68fc:	02c5d5bb          	divuw	a1,a1,a2
    6900:	0685                	addi	a3,a3,1
    6902:	fec7f0e3          	bgeu	a5,a2,68e2 <printint+0x2a>
  if(neg)
    6906:	00088b63          	beqz	a7,691c <printint+0x64>
    buf[i++] = '-';
    690a:	fd040793          	addi	a5,s0,-48
    690e:	973e                	add	a4,a4,a5
    6910:	02d00793          	li	a5,45
    6914:	fef70823          	sb	a5,-16(a4)
    6918:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    691c:	02e05863          	blez	a4,694c <printint+0x94>
    6920:	fc040793          	addi	a5,s0,-64
    6924:	00e78933          	add	s2,a5,a4
    6928:	fff78993          	addi	s3,a5,-1
    692c:	99ba                	add	s3,s3,a4
    692e:	377d                	addiw	a4,a4,-1
    6930:	1702                	slli	a4,a4,0x20
    6932:	9301                	srli	a4,a4,0x20
    6934:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    6938:	fff94583          	lbu	a1,-1(s2)
    693c:	8526                	mv	a0,s1
    693e:	00000097          	auipc	ra,0x0
    6942:	f58080e7          	jalr	-168(ra) # 6896 <putc>
  while(--i >= 0)
    6946:	197d                	addi	s2,s2,-1
    6948:	ff3918e3          	bne	s2,s3,6938 <printint+0x80>
}
    694c:	70e2                	ld	ra,56(sp)
    694e:	7442                	ld	s0,48(sp)
    6950:	74a2                	ld	s1,40(sp)
    6952:	7902                	ld	s2,32(sp)
    6954:	69e2                	ld	s3,24(sp)
    6956:	6121                	addi	sp,sp,64
    6958:	8082                	ret
    x = -xx;
    695a:	40b005bb          	negw	a1,a1
    neg = 1;
    695e:	4885                	li	a7,1
    x = -xx;
    6960:	bf8d                	j	68d2 <printint+0x1a>

0000000000006962 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    6962:	7119                	addi	sp,sp,-128
    6964:	fc86                	sd	ra,120(sp)
    6966:	f8a2                	sd	s0,112(sp)
    6968:	f4a6                	sd	s1,104(sp)
    696a:	f0ca                	sd	s2,96(sp)
    696c:	ecce                	sd	s3,88(sp)
    696e:	e8d2                	sd	s4,80(sp)
    6970:	e4d6                	sd	s5,72(sp)
    6972:	e0da                	sd	s6,64(sp)
    6974:	fc5e                	sd	s7,56(sp)
    6976:	f862                	sd	s8,48(sp)
    6978:	f466                	sd	s9,40(sp)
    697a:	f06a                	sd	s10,32(sp)
    697c:	ec6e                	sd	s11,24(sp)
    697e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    6980:	0005c903          	lbu	s2,0(a1)
    6984:	18090f63          	beqz	s2,6b22 <vprintf+0x1c0>
    6988:	8aaa                	mv	s5,a0
    698a:	8b32                	mv	s6,a2
    698c:	00158493          	addi	s1,a1,1
  state = 0;
    6990:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    6992:	02500a13          	li	s4,37
      if(c == 'd'){
    6996:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    699a:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    699e:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    69a2:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    69a6:	00002b97          	auipc	s7,0x2
    69aa:	7eab8b93          	addi	s7,s7,2026 # 9190 <digits>
    69ae:	a839                	j	69cc <vprintf+0x6a>
        putc(fd, c);
    69b0:	85ca                	mv	a1,s2
    69b2:	8556                	mv	a0,s5
    69b4:	00000097          	auipc	ra,0x0
    69b8:	ee2080e7          	jalr	-286(ra) # 6896 <putc>
    69bc:	a019                	j	69c2 <vprintf+0x60>
    } else if(state == '%'){
    69be:	01498f63          	beq	s3,s4,69dc <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    69c2:	0485                	addi	s1,s1,1
    69c4:	fff4c903          	lbu	s2,-1(s1)
    69c8:	14090d63          	beqz	s2,6b22 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    69cc:	0009079b          	sext.w	a5,s2
    if(state == 0){
    69d0:	fe0997e3          	bnez	s3,69be <vprintf+0x5c>
      if(c == '%'){
    69d4:	fd479ee3          	bne	a5,s4,69b0 <vprintf+0x4e>
        state = '%';
    69d8:	89be                	mv	s3,a5
    69da:	b7e5                	j	69c2 <vprintf+0x60>
      if(c == 'd'){
    69dc:	05878063          	beq	a5,s8,6a1c <vprintf+0xba>
      } else if(c == 'l') {
    69e0:	05978c63          	beq	a5,s9,6a38 <vprintf+0xd6>
      } else if(c == 'x') {
    69e4:	07a78863          	beq	a5,s10,6a54 <vprintf+0xf2>
      } else if(c == 'p') {
    69e8:	09b78463          	beq	a5,s11,6a70 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    69ec:	07300713          	li	a4,115
    69f0:	0ce78663          	beq	a5,a4,6abc <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    69f4:	06300713          	li	a4,99
    69f8:	0ee78e63          	beq	a5,a4,6af4 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    69fc:	11478863          	beq	a5,s4,6b0c <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    6a00:	85d2                	mv	a1,s4
    6a02:	8556                	mv	a0,s5
    6a04:	00000097          	auipc	ra,0x0
    6a08:	e92080e7          	jalr	-366(ra) # 6896 <putc>
        putc(fd, c);
    6a0c:	85ca                	mv	a1,s2
    6a0e:	8556                	mv	a0,s5
    6a10:	00000097          	auipc	ra,0x0
    6a14:	e86080e7          	jalr	-378(ra) # 6896 <putc>
      }
      state = 0;
    6a18:	4981                	li	s3,0
    6a1a:	b765                	j	69c2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    6a1c:	008b0913          	addi	s2,s6,8
    6a20:	4685                	li	a3,1
    6a22:	4629                	li	a2,10
    6a24:	000b2583          	lw	a1,0(s6)
    6a28:	8556                	mv	a0,s5
    6a2a:	00000097          	auipc	ra,0x0
    6a2e:	e8e080e7          	jalr	-370(ra) # 68b8 <printint>
    6a32:	8b4a                	mv	s6,s2
      state = 0;
    6a34:	4981                	li	s3,0
    6a36:	b771                	j	69c2 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    6a38:	008b0913          	addi	s2,s6,8
    6a3c:	4681                	li	a3,0
    6a3e:	4629                	li	a2,10
    6a40:	000b2583          	lw	a1,0(s6)
    6a44:	8556                	mv	a0,s5
    6a46:	00000097          	auipc	ra,0x0
    6a4a:	e72080e7          	jalr	-398(ra) # 68b8 <printint>
    6a4e:	8b4a                	mv	s6,s2
      state = 0;
    6a50:	4981                	li	s3,0
    6a52:	bf85                	j	69c2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    6a54:	008b0913          	addi	s2,s6,8
    6a58:	4681                	li	a3,0
    6a5a:	4641                	li	a2,16
    6a5c:	000b2583          	lw	a1,0(s6)
    6a60:	8556                	mv	a0,s5
    6a62:	00000097          	auipc	ra,0x0
    6a66:	e56080e7          	jalr	-426(ra) # 68b8 <printint>
    6a6a:	8b4a                	mv	s6,s2
      state = 0;
    6a6c:	4981                	li	s3,0
    6a6e:	bf91                	j	69c2 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    6a70:	008b0793          	addi	a5,s6,8
    6a74:	f8f43423          	sd	a5,-120(s0)
    6a78:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    6a7c:	03000593          	li	a1,48
    6a80:	8556                	mv	a0,s5
    6a82:	00000097          	auipc	ra,0x0
    6a86:	e14080e7          	jalr	-492(ra) # 6896 <putc>
  putc(fd, 'x');
    6a8a:	85ea                	mv	a1,s10
    6a8c:	8556                	mv	a0,s5
    6a8e:	00000097          	auipc	ra,0x0
    6a92:	e08080e7          	jalr	-504(ra) # 6896 <putc>
    6a96:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    6a98:	03c9d793          	srli	a5,s3,0x3c
    6a9c:	97de                	add	a5,a5,s7
    6a9e:	0007c583          	lbu	a1,0(a5)
    6aa2:	8556                	mv	a0,s5
    6aa4:	00000097          	auipc	ra,0x0
    6aa8:	df2080e7          	jalr	-526(ra) # 6896 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    6aac:	0992                	slli	s3,s3,0x4
    6aae:	397d                	addiw	s2,s2,-1
    6ab0:	fe0914e3          	bnez	s2,6a98 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    6ab4:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    6ab8:	4981                	li	s3,0
    6aba:	b721                	j	69c2 <vprintf+0x60>
        s = va_arg(ap, char*);
    6abc:	008b0993          	addi	s3,s6,8
    6ac0:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    6ac4:	02090163          	beqz	s2,6ae6 <vprintf+0x184>
        while(*s != 0){
    6ac8:	00094583          	lbu	a1,0(s2)
    6acc:	c9a1                	beqz	a1,6b1c <vprintf+0x1ba>
          putc(fd, *s);
    6ace:	8556                	mv	a0,s5
    6ad0:	00000097          	auipc	ra,0x0
    6ad4:	dc6080e7          	jalr	-570(ra) # 6896 <putc>
          s++;
    6ad8:	0905                	addi	s2,s2,1
        while(*s != 0){
    6ada:	00094583          	lbu	a1,0(s2)
    6ade:	f9e5                	bnez	a1,6ace <vprintf+0x16c>
        s = va_arg(ap, char*);
    6ae0:	8b4e                	mv	s6,s3
      state = 0;
    6ae2:	4981                	li	s3,0
    6ae4:	bdf9                	j	69c2 <vprintf+0x60>
          s = "(null)";
    6ae6:	00002917          	auipc	s2,0x2
    6aea:	6a290913          	addi	s2,s2,1698 # 9188 <malloc+0x255c>
        while(*s != 0){
    6aee:	02800593          	li	a1,40
    6af2:	bff1                	j	6ace <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    6af4:	008b0913          	addi	s2,s6,8
    6af8:	000b4583          	lbu	a1,0(s6)
    6afc:	8556                	mv	a0,s5
    6afe:	00000097          	auipc	ra,0x0
    6b02:	d98080e7          	jalr	-616(ra) # 6896 <putc>
    6b06:	8b4a                	mv	s6,s2
      state = 0;
    6b08:	4981                	li	s3,0
    6b0a:	bd65                	j	69c2 <vprintf+0x60>
        putc(fd, c);
    6b0c:	85d2                	mv	a1,s4
    6b0e:	8556                	mv	a0,s5
    6b10:	00000097          	auipc	ra,0x0
    6b14:	d86080e7          	jalr	-634(ra) # 6896 <putc>
      state = 0;
    6b18:	4981                	li	s3,0
    6b1a:	b565                	j	69c2 <vprintf+0x60>
        s = va_arg(ap, char*);
    6b1c:	8b4e                	mv	s6,s3
      state = 0;
    6b1e:	4981                	li	s3,0
    6b20:	b54d                	j	69c2 <vprintf+0x60>
    }
  }
}
    6b22:	70e6                	ld	ra,120(sp)
    6b24:	7446                	ld	s0,112(sp)
    6b26:	74a6                	ld	s1,104(sp)
    6b28:	7906                	ld	s2,96(sp)
    6b2a:	69e6                	ld	s3,88(sp)
    6b2c:	6a46                	ld	s4,80(sp)
    6b2e:	6aa6                	ld	s5,72(sp)
    6b30:	6b06                	ld	s6,64(sp)
    6b32:	7be2                	ld	s7,56(sp)
    6b34:	7c42                	ld	s8,48(sp)
    6b36:	7ca2                	ld	s9,40(sp)
    6b38:	7d02                	ld	s10,32(sp)
    6b3a:	6de2                	ld	s11,24(sp)
    6b3c:	6109                	addi	sp,sp,128
    6b3e:	8082                	ret

0000000000006b40 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    6b40:	715d                	addi	sp,sp,-80
    6b42:	ec06                	sd	ra,24(sp)
    6b44:	e822                	sd	s0,16(sp)
    6b46:	1000                	addi	s0,sp,32
    6b48:	e010                	sd	a2,0(s0)
    6b4a:	e414                	sd	a3,8(s0)
    6b4c:	e818                	sd	a4,16(s0)
    6b4e:	ec1c                	sd	a5,24(s0)
    6b50:	03043023          	sd	a6,32(s0)
    6b54:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    6b58:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    6b5c:	8622                	mv	a2,s0
    6b5e:	00000097          	auipc	ra,0x0
    6b62:	e04080e7          	jalr	-508(ra) # 6962 <vprintf>
}
    6b66:	60e2                	ld	ra,24(sp)
    6b68:	6442                	ld	s0,16(sp)
    6b6a:	6161                	addi	sp,sp,80
    6b6c:	8082                	ret

0000000000006b6e <printf>:

void
printf(const char *fmt, ...)
{
    6b6e:	711d                	addi	sp,sp,-96
    6b70:	ec06                	sd	ra,24(sp)
    6b72:	e822                	sd	s0,16(sp)
    6b74:	1000                	addi	s0,sp,32
    6b76:	e40c                	sd	a1,8(s0)
    6b78:	e810                	sd	a2,16(s0)
    6b7a:	ec14                	sd	a3,24(s0)
    6b7c:	f018                	sd	a4,32(s0)
    6b7e:	f41c                	sd	a5,40(s0)
    6b80:	03043823          	sd	a6,48(s0)
    6b84:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    6b88:	00840613          	addi	a2,s0,8
    6b8c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    6b90:	85aa                	mv	a1,a0
    6b92:	4505                	li	a0,1
    6b94:	00000097          	auipc	ra,0x0
    6b98:	dce080e7          	jalr	-562(ra) # 6962 <vprintf>
}
    6b9c:	60e2                	ld	ra,24(sp)
    6b9e:	6442                	ld	s0,16(sp)
    6ba0:	6125                	addi	sp,sp,96
    6ba2:	8082                	ret

0000000000006ba4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    6ba4:	1141                	addi	sp,sp,-16
    6ba6:	e422                	sd	s0,8(sp)
    6ba8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    6baa:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    6bae:	00004797          	auipc	a5,0x4
    6bb2:	8a27b783          	ld	a5,-1886(a5) # a450 <freep>
    6bb6:	a805                	j	6be6 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    6bb8:	4618                	lw	a4,8(a2)
    6bba:	9db9                	addw	a1,a1,a4
    6bbc:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    6bc0:	6398                	ld	a4,0(a5)
    6bc2:	6318                	ld	a4,0(a4)
    6bc4:	fee53823          	sd	a4,-16(a0)
    6bc8:	a091                	j	6c0c <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    6bca:	ff852703          	lw	a4,-8(a0)
    6bce:	9e39                	addw	a2,a2,a4
    6bd0:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    6bd2:	ff053703          	ld	a4,-16(a0)
    6bd6:	e398                	sd	a4,0(a5)
    6bd8:	a099                	j	6c1e <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    6bda:	6398                	ld	a4,0(a5)
    6bdc:	00e7e463          	bltu	a5,a4,6be4 <free+0x40>
    6be0:	00e6ea63          	bltu	a3,a4,6bf4 <free+0x50>
{
    6be4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    6be6:	fed7fae3          	bgeu	a5,a3,6bda <free+0x36>
    6bea:	6398                	ld	a4,0(a5)
    6bec:	00e6e463          	bltu	a3,a4,6bf4 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    6bf0:	fee7eae3          	bltu	a5,a4,6be4 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    6bf4:	ff852583          	lw	a1,-8(a0)
    6bf8:	6390                	ld	a2,0(a5)
    6bfa:	02059713          	slli	a4,a1,0x20
    6bfe:	9301                	srli	a4,a4,0x20
    6c00:	0712                	slli	a4,a4,0x4
    6c02:	9736                	add	a4,a4,a3
    6c04:	fae60ae3          	beq	a2,a4,6bb8 <free+0x14>
    bp->s.ptr = p->s.ptr;
    6c08:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    6c0c:	4790                	lw	a2,8(a5)
    6c0e:	02061713          	slli	a4,a2,0x20
    6c12:	9301                	srli	a4,a4,0x20
    6c14:	0712                	slli	a4,a4,0x4
    6c16:	973e                	add	a4,a4,a5
    6c18:	fae689e3          	beq	a3,a4,6bca <free+0x26>
  } else
    p->s.ptr = bp;
    6c1c:	e394                	sd	a3,0(a5)
  freep = p;
    6c1e:	00004717          	auipc	a4,0x4
    6c22:	82f73923          	sd	a5,-1998(a4) # a450 <freep>
}
    6c26:	6422                	ld	s0,8(sp)
    6c28:	0141                	addi	sp,sp,16
    6c2a:	8082                	ret

0000000000006c2c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    6c2c:	7139                	addi	sp,sp,-64
    6c2e:	fc06                	sd	ra,56(sp)
    6c30:	f822                	sd	s0,48(sp)
    6c32:	f426                	sd	s1,40(sp)
    6c34:	f04a                	sd	s2,32(sp)
    6c36:	ec4e                	sd	s3,24(sp)
    6c38:	e852                	sd	s4,16(sp)
    6c3a:	e456                	sd	s5,8(sp)
    6c3c:	e05a                	sd	s6,0(sp)
    6c3e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    6c40:	02051493          	slli	s1,a0,0x20
    6c44:	9081                	srli	s1,s1,0x20
    6c46:	04bd                	addi	s1,s1,15
    6c48:	8091                	srli	s1,s1,0x4
    6c4a:	0014899b          	addiw	s3,s1,1
    6c4e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    6c50:	00004517          	auipc	a0,0x4
    6c54:	80053503          	ld	a0,-2048(a0) # a450 <freep>
    6c58:	c515                	beqz	a0,6c84 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    6c5a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    6c5c:	4798                	lw	a4,8(a5)
    6c5e:	02977f63          	bgeu	a4,s1,6c9c <malloc+0x70>
    6c62:	8a4e                	mv	s4,s3
    6c64:	0009871b          	sext.w	a4,s3
    6c68:	6685                	lui	a3,0x1
    6c6a:	00d77363          	bgeu	a4,a3,6c70 <malloc+0x44>
    6c6e:	6a05                	lui	s4,0x1
    6c70:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    6c74:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    6c78:	00003917          	auipc	s2,0x3
    6c7c:	7d890913          	addi	s2,s2,2008 # a450 <freep>
  if(p == (char*)-1)
    6c80:	5afd                	li	s5,-1
    6c82:	a88d                	j	6cf4 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    6c84:	0000a797          	auipc	a5,0xa
    6c88:	ff478793          	addi	a5,a5,-12 # 10c78 <base>
    6c8c:	00003717          	auipc	a4,0x3
    6c90:	7cf73223          	sd	a5,1988(a4) # a450 <freep>
    6c94:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    6c96:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    6c9a:	b7e1                	j	6c62 <malloc+0x36>
      if(p->s.size == nunits)
    6c9c:	02e48b63          	beq	s1,a4,6cd2 <malloc+0xa6>
        p->s.size -= nunits;
    6ca0:	4137073b          	subw	a4,a4,s3
    6ca4:	c798                	sw	a4,8(a5)
        p += p->s.size;
    6ca6:	1702                	slli	a4,a4,0x20
    6ca8:	9301                	srli	a4,a4,0x20
    6caa:	0712                	slli	a4,a4,0x4
    6cac:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    6cae:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    6cb2:	00003717          	auipc	a4,0x3
    6cb6:	78a73f23          	sd	a0,1950(a4) # a450 <freep>
      return (void*)(p + 1);
    6cba:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    6cbe:	70e2                	ld	ra,56(sp)
    6cc0:	7442                	ld	s0,48(sp)
    6cc2:	74a2                	ld	s1,40(sp)
    6cc4:	7902                	ld	s2,32(sp)
    6cc6:	69e2                	ld	s3,24(sp)
    6cc8:	6a42                	ld	s4,16(sp)
    6cca:	6aa2                	ld	s5,8(sp)
    6ccc:	6b02                	ld	s6,0(sp)
    6cce:	6121                	addi	sp,sp,64
    6cd0:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    6cd2:	6398                	ld	a4,0(a5)
    6cd4:	e118                	sd	a4,0(a0)
    6cd6:	bff1                	j	6cb2 <malloc+0x86>
  hp->s.size = nu;
    6cd8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    6cdc:	0541                	addi	a0,a0,16
    6cde:	00000097          	auipc	ra,0x0
    6ce2:	ec6080e7          	jalr	-314(ra) # 6ba4 <free>
  return freep;
    6ce6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    6cea:	d971                	beqz	a0,6cbe <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    6cec:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    6cee:	4798                	lw	a4,8(a5)
    6cf0:	fa9776e3          	bgeu	a4,s1,6c9c <malloc+0x70>
    if(p == freep)
    6cf4:	00093703          	ld	a4,0(s2)
    6cf8:	853e                	mv	a0,a5
    6cfa:	fef719e3          	bne	a4,a5,6cec <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    6cfe:	8552                	mv	a0,s4
    6d00:	00000097          	auipc	ra,0x0
    6d04:	b4e080e7          	jalr	-1202(ra) # 684e <sbrk>
  if(p == (char*)-1)
    6d08:	fd5518e3          	bne	a0,s5,6cd8 <malloc+0xac>
        return 0;
    6d0c:	4501                	li	a0,0
    6d0e:	bf45                	j	6cbe <malloc+0x92>
