
user/_sh:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <getcmd>:
}


int
getcmd(char *buf, int nbuf)
{
       0:	1101                	addi	sp,sp,-32
       2:	ec06                	sd	ra,24(sp)
       4:	e822                	sd	s0,16(sp)
       6:	e426                	sd	s1,8(sp)
       8:	e04a                	sd	s2,0(sp)
       a:	1000                	addi	s0,sp,32
       c:	84aa                	mv	s1,a0
       e:	892e                	mv	s2,a1
  write(2, "$ ", 2);
      10:	4609                	li	a2,2
      12:	00001597          	auipc	a1,0x1
      16:	38e58593          	addi	a1,a1,910 # 13a0 <malloc+0xe8>
      1a:	4509                	li	a0,2
      1c:	00001097          	auipc	ra,0x1
      20:	e56080e7          	jalr	-426(ra) # e72 <write>
  memset(buf, 0, nbuf);
      24:	864a                	mv	a2,s2
      26:	4581                	li	a1,0
      28:	8526                	mv	a0,s1
      2a:	00001097          	auipc	ra,0x1
      2e:	c2c080e7          	jalr	-980(ra) # c56 <memset>
  gets(buf, nbuf);
      32:	85ca                	mv	a1,s2
      34:	8526                	mv	a0,s1
      36:	00001097          	auipc	ra,0x1
      3a:	c66080e7          	jalr	-922(ra) # c9c <gets>
  if(buf[0] == 0) // EOF
      3e:	0004c503          	lbu	a0,0(s1)
      42:	00153513          	seqz	a0,a0
    return -1;
  return 0;
}
      46:	40a00533          	neg	a0,a0
      4a:	60e2                	ld	ra,24(sp)
      4c:	6442                	ld	s0,16(sp)
      4e:	64a2                	ld	s1,8(sp)
      50:	6902                	ld	s2,0(sp)
      52:	6105                	addi	sp,sp,32
      54:	8082                	ret

0000000000000056 <panic>:
  exit(0, "");
}

void
panic(char *s)
{
      56:	1141                	addi	sp,sp,-16
      58:	e406                	sd	ra,8(sp)
      5a:	e022                	sd	s0,0(sp)
      5c:	0800                	addi	s0,sp,16
      5e:	862a                	mv	a2,a0
  fprintf(2, "%s\n", s);
      60:	00001597          	auipc	a1,0x1
      64:	34858593          	addi	a1,a1,840 # 13a8 <malloc+0xf0>
      68:	4509                	li	a0,2
      6a:	00001097          	auipc	ra,0x1
      6e:	162080e7          	jalr	354(ra) # 11cc <fprintf>
  exit(1,"");
      72:	00001597          	auipc	a1,0x1
      76:	33e58593          	addi	a1,a1,830 # 13b0 <malloc+0xf8>
      7a:	4505                	li	a0,1
      7c:	00001097          	auipc	ra,0x1
      80:	dd6080e7          	jalr	-554(ra) # e52 <exit>

0000000000000084 <fork1>:
}

int
fork1(void)
{
      84:	1141                	addi	sp,sp,-16
      86:	e406                	sd	ra,8(sp)
      88:	e022                	sd	s0,0(sp)
      8a:	0800                	addi	s0,sp,16
  int pid;

  pid = fork();
      8c:	00001097          	auipc	ra,0x1
      90:	dbe080e7          	jalr	-578(ra) # e4a <fork>
  if(pid == -1)
      94:	57fd                	li	a5,-1
      96:	00f50663          	beq	a0,a5,a2 <fork1+0x1e>
    panic("fork");
  return pid;
}
      9a:	60a2                	ld	ra,8(sp)
      9c:	6402                	ld	s0,0(sp)
      9e:	0141                	addi	sp,sp,16
      a0:	8082                	ret
    panic("fork");
      a2:	00001517          	auipc	a0,0x1
      a6:	31650513          	addi	a0,a0,790 # 13b8 <malloc+0x100>
      aa:	00000097          	auipc	ra,0x0
      ae:	fac080e7          	jalr	-84(ra) # 56 <panic>

00000000000000b2 <runcmd>:
{
      b2:	7179                	addi	sp,sp,-48
      b4:	f406                	sd	ra,40(sp)
      b6:	f022                	sd	s0,32(sp)
      b8:	ec26                	sd	s1,24(sp)
      ba:	1800                	addi	s0,sp,48
  if(cmd == 0)
      bc:	c10d                	beqz	a0,de <runcmd+0x2c>
      be:	84aa                	mv	s1,a0
  switch(cmd->type){
      c0:	4118                	lw	a4,0(a0)
      c2:	4795                	li	a5,5
      c4:	02e7e663          	bltu	a5,a4,f0 <runcmd+0x3e>
      c8:	00056783          	lwu	a5,0(a0)
      cc:	078a                	slli	a5,a5,0x2
      ce:	00001717          	auipc	a4,0x1
      d2:	41270713          	addi	a4,a4,1042 # 14e0 <malloc+0x228>
      d6:	97ba                	add	a5,a5,a4
      d8:	439c                	lw	a5,0(a5)
      da:	97ba                	add	a5,a5,a4
      dc:	8782                	jr	a5
    exit(1,"");
      de:	00001597          	auipc	a1,0x1
      e2:	2d258593          	addi	a1,a1,722 # 13b0 <malloc+0xf8>
      e6:	4505                	li	a0,1
      e8:	00001097          	auipc	ra,0x1
      ec:	d6a080e7          	jalr	-662(ra) # e52 <exit>
    panic("runcmd");
      f0:	00001517          	auipc	a0,0x1
      f4:	2d050513          	addi	a0,a0,720 # 13c0 <malloc+0x108>
      f8:	00000097          	auipc	ra,0x0
      fc:	f5e080e7          	jalr	-162(ra) # 56 <panic>
    if(ecmd->argv[0] == 0)
     100:	6508                	ld	a0,8(a0)
     102:	c915                	beqz	a0,136 <runcmd+0x84>
    exec(ecmd->argv[0], ecmd->argv);
     104:	00848593          	addi	a1,s1,8
     108:	00001097          	auipc	ra,0x1
     10c:	d82080e7          	jalr	-638(ra) # e8a <exec>
    fprintf(2, "exec %s failed\n", ecmd->argv[0]);
     110:	6490                	ld	a2,8(s1)
     112:	00001597          	auipc	a1,0x1
     116:	2b658593          	addi	a1,a1,694 # 13c8 <malloc+0x110>
     11a:	4509                	li	a0,2
     11c:	00001097          	auipc	ra,0x1
     120:	0b0080e7          	jalr	176(ra) # 11cc <fprintf>
  exit(0,"");
     124:	00001597          	auipc	a1,0x1
     128:	28c58593          	addi	a1,a1,652 # 13b0 <malloc+0xf8>
     12c:	4501                	li	a0,0
     12e:	00001097          	auipc	ra,0x1
     132:	d24080e7          	jalr	-732(ra) # e52 <exit>
      exit(1,"");
     136:	00001597          	auipc	a1,0x1
     13a:	27a58593          	addi	a1,a1,634 # 13b0 <malloc+0xf8>
     13e:	4505                	li	a0,1
     140:	00001097          	auipc	ra,0x1
     144:	d12080e7          	jalr	-750(ra) # e52 <exit>
    close(rcmd->fd);
     148:	5148                	lw	a0,36(a0)
     14a:	00001097          	auipc	ra,0x1
     14e:	d30080e7          	jalr	-720(ra) # e7a <close>
    if(open(rcmd->file, rcmd->mode) < 0){
     152:	508c                	lw	a1,32(s1)
     154:	6888                	ld	a0,16(s1)
     156:	00001097          	auipc	ra,0x1
     15a:	d3c080e7          	jalr	-708(ra) # e92 <open>
     15e:	00054763          	bltz	a0,16c <runcmd+0xba>
    runcmd(rcmd->cmd);
     162:	6488                	ld	a0,8(s1)
     164:	00000097          	auipc	ra,0x0
     168:	f4e080e7          	jalr	-178(ra) # b2 <runcmd>
      fprintf(2, "open %s failed\n", rcmd->file);
     16c:	6890                	ld	a2,16(s1)
     16e:	00001597          	auipc	a1,0x1
     172:	26a58593          	addi	a1,a1,618 # 13d8 <malloc+0x120>
     176:	4509                	li	a0,2
     178:	00001097          	auipc	ra,0x1
     17c:	054080e7          	jalr	84(ra) # 11cc <fprintf>
      exit(1,"");
     180:	00001597          	auipc	a1,0x1
     184:	23058593          	addi	a1,a1,560 # 13b0 <malloc+0xf8>
     188:	4505                	li	a0,1
     18a:	00001097          	auipc	ra,0x1
     18e:	cc8080e7          	jalr	-824(ra) # e52 <exit>
    if(fork1() == 0)
     192:	00000097          	auipc	ra,0x0
     196:	ef2080e7          	jalr	-270(ra) # 84 <fork1>
     19a:	e511                	bnez	a0,1a6 <runcmd+0xf4>
      runcmd(lcmd->left);
     19c:	6488                	ld	a0,8(s1)
     19e:	00000097          	auipc	ra,0x0
     1a2:	f14080e7          	jalr	-236(ra) # b2 <runcmd>
    wait(0,"");
     1a6:	00001597          	auipc	a1,0x1
     1aa:	20a58593          	addi	a1,a1,522 # 13b0 <malloc+0xf8>
     1ae:	4501                	li	a0,0
     1b0:	00001097          	auipc	ra,0x1
     1b4:	caa080e7          	jalr	-854(ra) # e5a <wait>
    runcmd(lcmd->right);
     1b8:	6888                	ld	a0,16(s1)
     1ba:	00000097          	auipc	ra,0x0
     1be:	ef8080e7          	jalr	-264(ra) # b2 <runcmd>
    if(pipe(p) < 0)
     1c2:	fd840513          	addi	a0,s0,-40
     1c6:	00001097          	auipc	ra,0x1
     1ca:	c9c080e7          	jalr	-868(ra) # e62 <pipe>
     1ce:	04054363          	bltz	a0,214 <runcmd+0x162>
    if(fork1() == 0){
     1d2:	00000097          	auipc	ra,0x0
     1d6:	eb2080e7          	jalr	-334(ra) # 84 <fork1>
     1da:	e529                	bnez	a0,224 <runcmd+0x172>
      close(1);
     1dc:	4505                	li	a0,1
     1de:	00001097          	auipc	ra,0x1
     1e2:	c9c080e7          	jalr	-868(ra) # e7a <close>
      dup(p[1]);
     1e6:	fdc42503          	lw	a0,-36(s0)
     1ea:	00001097          	auipc	ra,0x1
     1ee:	ce0080e7          	jalr	-800(ra) # eca <dup>
      close(p[0]);
     1f2:	fd842503          	lw	a0,-40(s0)
     1f6:	00001097          	auipc	ra,0x1
     1fa:	c84080e7          	jalr	-892(ra) # e7a <close>
      close(p[1]);
     1fe:	fdc42503          	lw	a0,-36(s0)
     202:	00001097          	auipc	ra,0x1
     206:	c78080e7          	jalr	-904(ra) # e7a <close>
      runcmd(pcmd->left);
     20a:	6488                	ld	a0,8(s1)
     20c:	00000097          	auipc	ra,0x0
     210:	ea6080e7          	jalr	-346(ra) # b2 <runcmd>
      panic("pipe");
     214:	00001517          	auipc	a0,0x1
     218:	1d450513          	addi	a0,a0,468 # 13e8 <malloc+0x130>
     21c:	00000097          	auipc	ra,0x0
     220:	e3a080e7          	jalr	-454(ra) # 56 <panic>
    if(fork1() == 0){
     224:	00000097          	auipc	ra,0x0
     228:	e60080e7          	jalr	-416(ra) # 84 <fork1>
     22c:	ed05                	bnez	a0,264 <runcmd+0x1b2>
      close(0);
     22e:	00001097          	auipc	ra,0x1
     232:	c4c080e7          	jalr	-948(ra) # e7a <close>
      dup(p[0]);
     236:	fd842503          	lw	a0,-40(s0)
     23a:	00001097          	auipc	ra,0x1
     23e:	c90080e7          	jalr	-880(ra) # eca <dup>
      close(p[0]);
     242:	fd842503          	lw	a0,-40(s0)
     246:	00001097          	auipc	ra,0x1
     24a:	c34080e7          	jalr	-972(ra) # e7a <close>
      close(p[1]);
     24e:	fdc42503          	lw	a0,-36(s0)
     252:	00001097          	auipc	ra,0x1
     256:	c28080e7          	jalr	-984(ra) # e7a <close>
      runcmd(pcmd->right);
     25a:	6888                	ld	a0,16(s1)
     25c:	00000097          	auipc	ra,0x0
     260:	e56080e7          	jalr	-426(ra) # b2 <runcmd>
    close(p[0]);
     264:	fd842503          	lw	a0,-40(s0)
     268:	00001097          	auipc	ra,0x1
     26c:	c12080e7          	jalr	-1006(ra) # e7a <close>
    close(p[1]);
     270:	fdc42503          	lw	a0,-36(s0)
     274:	00001097          	auipc	ra,0x1
     278:	c06080e7          	jalr	-1018(ra) # e7a <close>
    wait(0,"");
     27c:	00001597          	auipc	a1,0x1
     280:	13458593          	addi	a1,a1,308 # 13b0 <malloc+0xf8>
     284:	4501                	li	a0,0
     286:	00001097          	auipc	ra,0x1
     28a:	bd4080e7          	jalr	-1068(ra) # e5a <wait>
    wait(0,"");
     28e:	00001597          	auipc	a1,0x1
     292:	12258593          	addi	a1,a1,290 # 13b0 <malloc+0xf8>
     296:	4501                	li	a0,0
     298:	00001097          	auipc	ra,0x1
     29c:	bc2080e7          	jalr	-1086(ra) # e5a <wait>
    break;
     2a0:	b551                	j	124 <runcmd+0x72>
    if(fork1() == 0)
     2a2:	00000097          	auipc	ra,0x0
     2a6:	de2080e7          	jalr	-542(ra) # 84 <fork1>
     2aa:	e6051de3          	bnez	a0,124 <runcmd+0x72>
      runcmd(bcmd->cmd);
     2ae:	6488                	ld	a0,8(s1)
     2b0:	00000097          	auipc	ra,0x0
     2b4:	e02080e7          	jalr	-510(ra) # b2 <runcmd>

00000000000002b8 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     2b8:	1101                	addi	sp,sp,-32
     2ba:	ec06                	sd	ra,24(sp)
     2bc:	e822                	sd	s0,16(sp)
     2be:	e426                	sd	s1,8(sp)
     2c0:	1000                	addi	s0,sp,32
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     2c2:	0a800513          	li	a0,168
     2c6:	00001097          	auipc	ra,0x1
     2ca:	ff2080e7          	jalr	-14(ra) # 12b8 <malloc>
     2ce:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     2d0:	0a800613          	li	a2,168
     2d4:	4581                	li	a1,0
     2d6:	00001097          	auipc	ra,0x1
     2da:	980080e7          	jalr	-1664(ra) # c56 <memset>
  cmd->type = EXEC;
     2de:	4785                	li	a5,1
     2e0:	c09c                	sw	a5,0(s1)
  return (struct cmd*)cmd;
}
     2e2:	8526                	mv	a0,s1
     2e4:	60e2                	ld	ra,24(sp)
     2e6:	6442                	ld	s0,16(sp)
     2e8:	64a2                	ld	s1,8(sp)
     2ea:	6105                	addi	sp,sp,32
     2ec:	8082                	ret

00000000000002ee <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     2ee:	7139                	addi	sp,sp,-64
     2f0:	fc06                	sd	ra,56(sp)
     2f2:	f822                	sd	s0,48(sp)
     2f4:	f426                	sd	s1,40(sp)
     2f6:	f04a                	sd	s2,32(sp)
     2f8:	ec4e                	sd	s3,24(sp)
     2fa:	e852                	sd	s4,16(sp)
     2fc:	e456                	sd	s5,8(sp)
     2fe:	e05a                	sd	s6,0(sp)
     300:	0080                	addi	s0,sp,64
     302:	8b2a                	mv	s6,a0
     304:	8aae                	mv	s5,a1
     306:	8a32                	mv	s4,a2
     308:	89b6                	mv	s3,a3
     30a:	893a                	mv	s2,a4
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     30c:	02800513          	li	a0,40
     310:	00001097          	auipc	ra,0x1
     314:	fa8080e7          	jalr	-88(ra) # 12b8 <malloc>
     318:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     31a:	02800613          	li	a2,40
     31e:	4581                	li	a1,0
     320:	00001097          	auipc	ra,0x1
     324:	936080e7          	jalr	-1738(ra) # c56 <memset>
  cmd->type = REDIR;
     328:	4789                	li	a5,2
     32a:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     32c:	0164b423          	sd	s6,8(s1)
  cmd->file = file;
     330:	0154b823          	sd	s5,16(s1)
  cmd->efile = efile;
     334:	0144bc23          	sd	s4,24(s1)
  cmd->mode = mode;
     338:	0334a023          	sw	s3,32(s1)
  cmd->fd = fd;
     33c:	0324a223          	sw	s2,36(s1)
  return (struct cmd*)cmd;
}
     340:	8526                	mv	a0,s1
     342:	70e2                	ld	ra,56(sp)
     344:	7442                	ld	s0,48(sp)
     346:	74a2                	ld	s1,40(sp)
     348:	7902                	ld	s2,32(sp)
     34a:	69e2                	ld	s3,24(sp)
     34c:	6a42                	ld	s4,16(sp)
     34e:	6aa2                	ld	s5,8(sp)
     350:	6b02                	ld	s6,0(sp)
     352:	6121                	addi	sp,sp,64
     354:	8082                	ret

0000000000000356 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     356:	7179                	addi	sp,sp,-48
     358:	f406                	sd	ra,40(sp)
     35a:	f022                	sd	s0,32(sp)
     35c:	ec26                	sd	s1,24(sp)
     35e:	e84a                	sd	s2,16(sp)
     360:	e44e                	sd	s3,8(sp)
     362:	1800                	addi	s0,sp,48
     364:	89aa                	mv	s3,a0
     366:	892e                	mv	s2,a1
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     368:	4561                	li	a0,24
     36a:	00001097          	auipc	ra,0x1
     36e:	f4e080e7          	jalr	-178(ra) # 12b8 <malloc>
     372:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     374:	4661                	li	a2,24
     376:	4581                	li	a1,0
     378:	00001097          	auipc	ra,0x1
     37c:	8de080e7          	jalr	-1826(ra) # c56 <memset>
  cmd->type = PIPE;
     380:	478d                	li	a5,3
     382:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     384:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     388:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     38c:	8526                	mv	a0,s1
     38e:	70a2                	ld	ra,40(sp)
     390:	7402                	ld	s0,32(sp)
     392:	64e2                	ld	s1,24(sp)
     394:	6942                	ld	s2,16(sp)
     396:	69a2                	ld	s3,8(sp)
     398:	6145                	addi	sp,sp,48
     39a:	8082                	ret

000000000000039c <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     39c:	7179                	addi	sp,sp,-48
     39e:	f406                	sd	ra,40(sp)
     3a0:	f022                	sd	s0,32(sp)
     3a2:	ec26                	sd	s1,24(sp)
     3a4:	e84a                	sd	s2,16(sp)
     3a6:	e44e                	sd	s3,8(sp)
     3a8:	1800                	addi	s0,sp,48
     3aa:	89aa                	mv	s3,a0
     3ac:	892e                	mv	s2,a1
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     3ae:	4561                	li	a0,24
     3b0:	00001097          	auipc	ra,0x1
     3b4:	f08080e7          	jalr	-248(ra) # 12b8 <malloc>
     3b8:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     3ba:	4661                	li	a2,24
     3bc:	4581                	li	a1,0
     3be:	00001097          	auipc	ra,0x1
     3c2:	898080e7          	jalr	-1896(ra) # c56 <memset>
  cmd->type = LIST;
     3c6:	4791                	li	a5,4
     3c8:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     3ca:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     3ce:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     3d2:	8526                	mv	a0,s1
     3d4:	70a2                	ld	ra,40(sp)
     3d6:	7402                	ld	s0,32(sp)
     3d8:	64e2                	ld	s1,24(sp)
     3da:	6942                	ld	s2,16(sp)
     3dc:	69a2                	ld	s3,8(sp)
     3de:	6145                	addi	sp,sp,48
     3e0:	8082                	ret

00000000000003e2 <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     3e2:	1101                	addi	sp,sp,-32
     3e4:	ec06                	sd	ra,24(sp)
     3e6:	e822                	sd	s0,16(sp)
     3e8:	e426                	sd	s1,8(sp)
     3ea:	e04a                	sd	s2,0(sp)
     3ec:	1000                	addi	s0,sp,32
     3ee:	892a                	mv	s2,a0
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     3f0:	4541                	li	a0,16
     3f2:	00001097          	auipc	ra,0x1
     3f6:	ec6080e7          	jalr	-314(ra) # 12b8 <malloc>
     3fa:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     3fc:	4641                	li	a2,16
     3fe:	4581                	li	a1,0
     400:	00001097          	auipc	ra,0x1
     404:	856080e7          	jalr	-1962(ra) # c56 <memset>
  cmd->type = BACK;
     408:	4795                	li	a5,5
     40a:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     40c:	0124b423          	sd	s2,8(s1)
  return (struct cmd*)cmd;
}
     410:	8526                	mv	a0,s1
     412:	60e2                	ld	ra,24(sp)
     414:	6442                	ld	s0,16(sp)
     416:	64a2                	ld	s1,8(sp)
     418:	6902                	ld	s2,0(sp)
     41a:	6105                	addi	sp,sp,32
     41c:	8082                	ret

000000000000041e <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     41e:	7139                	addi	sp,sp,-64
     420:	fc06                	sd	ra,56(sp)
     422:	f822                	sd	s0,48(sp)
     424:	f426                	sd	s1,40(sp)
     426:	f04a                	sd	s2,32(sp)
     428:	ec4e                	sd	s3,24(sp)
     42a:	e852                	sd	s4,16(sp)
     42c:	e456                	sd	s5,8(sp)
     42e:	e05a                	sd	s6,0(sp)
     430:	0080                	addi	s0,sp,64
     432:	8a2a                	mv	s4,a0
     434:	892e                	mv	s2,a1
     436:	8ab2                	mv	s5,a2
     438:	8b36                	mv	s6,a3
  char *s;
  int ret;

  s = *ps;
     43a:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     43c:	00002997          	auipc	s3,0x2
     440:	bcc98993          	addi	s3,s3,-1076 # 2008 <whitespace>
     444:	00b4fd63          	bgeu	s1,a1,45e <gettoken+0x40>
     448:	0004c583          	lbu	a1,0(s1)
     44c:	854e                	mv	a0,s3
     44e:	00001097          	auipc	ra,0x1
     452:	82a080e7          	jalr	-2006(ra) # c78 <strchr>
     456:	c501                	beqz	a0,45e <gettoken+0x40>
    s++;
     458:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     45a:	fe9917e3          	bne	s2,s1,448 <gettoken+0x2a>
  if(q)
     45e:	000a8463          	beqz	s5,466 <gettoken+0x48>
    *q = s;
     462:	009ab023          	sd	s1,0(s5)
  ret = *s;
     466:	0004c783          	lbu	a5,0(s1)
     46a:	00078a9b          	sext.w	s5,a5
  switch(*s){
     46e:	03c00713          	li	a4,60
     472:	06f76563          	bltu	a4,a5,4dc <gettoken+0xbe>
     476:	03a00713          	li	a4,58
     47a:	00f76e63          	bltu	a4,a5,496 <gettoken+0x78>
     47e:	cf89                	beqz	a5,498 <gettoken+0x7a>
     480:	02600713          	li	a4,38
     484:	00e78963          	beq	a5,a4,496 <gettoken+0x78>
     488:	fd87879b          	addiw	a5,a5,-40
     48c:	0ff7f793          	andi	a5,a5,255
     490:	4705                	li	a4,1
     492:	06f76c63          	bltu	a4,a5,50a <gettoken+0xec>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     496:	0485                	addi	s1,s1,1
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
  }
  if(eq)
     498:	000b0463          	beqz	s6,4a0 <gettoken+0x82>
    *eq = s;
     49c:	009b3023          	sd	s1,0(s6)

  while(s < es && strchr(whitespace, *s))
     4a0:	00002997          	auipc	s3,0x2
     4a4:	b6898993          	addi	s3,s3,-1176 # 2008 <whitespace>
     4a8:	0124fd63          	bgeu	s1,s2,4c2 <gettoken+0xa4>
     4ac:	0004c583          	lbu	a1,0(s1)
     4b0:	854e                	mv	a0,s3
     4b2:	00000097          	auipc	ra,0x0
     4b6:	7c6080e7          	jalr	1990(ra) # c78 <strchr>
     4ba:	c501                	beqz	a0,4c2 <gettoken+0xa4>
    s++;
     4bc:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     4be:	fe9917e3          	bne	s2,s1,4ac <gettoken+0x8e>
  *ps = s;
     4c2:	009a3023          	sd	s1,0(s4)
  return ret;
}
     4c6:	8556                	mv	a0,s5
     4c8:	70e2                	ld	ra,56(sp)
     4ca:	7442                	ld	s0,48(sp)
     4cc:	74a2                	ld	s1,40(sp)
     4ce:	7902                	ld	s2,32(sp)
     4d0:	69e2                	ld	s3,24(sp)
     4d2:	6a42                	ld	s4,16(sp)
     4d4:	6aa2                	ld	s5,8(sp)
     4d6:	6b02                	ld	s6,0(sp)
     4d8:	6121                	addi	sp,sp,64
     4da:	8082                	ret
  switch(*s){
     4dc:	03e00713          	li	a4,62
     4e0:	02e79163          	bne	a5,a4,502 <gettoken+0xe4>
    s++;
     4e4:	00148693          	addi	a3,s1,1
    if(*s == '>'){
     4e8:	0014c703          	lbu	a4,1(s1)
     4ec:	03e00793          	li	a5,62
      s++;
     4f0:	0489                	addi	s1,s1,2
      ret = '+';
     4f2:	02b00a93          	li	s5,43
    if(*s == '>'){
     4f6:	faf701e3          	beq	a4,a5,498 <gettoken+0x7a>
    s++;
     4fa:	84b6                	mv	s1,a3
  ret = *s;
     4fc:	03e00a93          	li	s5,62
     500:	bf61                	j	498 <gettoken+0x7a>
  switch(*s){
     502:	07c00713          	li	a4,124
     506:	f8e788e3          	beq	a5,a4,496 <gettoken+0x78>
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     50a:	00002997          	auipc	s3,0x2
     50e:	afe98993          	addi	s3,s3,-1282 # 2008 <whitespace>
     512:	00002a97          	auipc	s5,0x2
     516:	aeea8a93          	addi	s5,s5,-1298 # 2000 <symbols>
     51a:	0324f563          	bgeu	s1,s2,544 <gettoken+0x126>
     51e:	0004c583          	lbu	a1,0(s1)
     522:	854e                	mv	a0,s3
     524:	00000097          	auipc	ra,0x0
     528:	754080e7          	jalr	1876(ra) # c78 <strchr>
     52c:	e505                	bnez	a0,554 <gettoken+0x136>
     52e:	0004c583          	lbu	a1,0(s1)
     532:	8556                	mv	a0,s5
     534:	00000097          	auipc	ra,0x0
     538:	744080e7          	jalr	1860(ra) # c78 <strchr>
     53c:	e909                	bnez	a0,54e <gettoken+0x130>
      s++;
     53e:	0485                	addi	s1,s1,1
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     540:	fc991fe3          	bne	s2,s1,51e <gettoken+0x100>
  if(eq)
     544:	06100a93          	li	s5,97
     548:	f40b1ae3          	bnez	s6,49c <gettoken+0x7e>
     54c:	bf9d                	j	4c2 <gettoken+0xa4>
    ret = 'a';
     54e:	06100a93          	li	s5,97
     552:	b799                	j	498 <gettoken+0x7a>
     554:	06100a93          	li	s5,97
     558:	b781                	j	498 <gettoken+0x7a>

000000000000055a <peek>:

int
peek(char **ps, char *es, char *toks)
{
     55a:	7139                	addi	sp,sp,-64
     55c:	fc06                	sd	ra,56(sp)
     55e:	f822                	sd	s0,48(sp)
     560:	f426                	sd	s1,40(sp)
     562:	f04a                	sd	s2,32(sp)
     564:	ec4e                	sd	s3,24(sp)
     566:	e852                	sd	s4,16(sp)
     568:	e456                	sd	s5,8(sp)
     56a:	0080                	addi	s0,sp,64
     56c:	8a2a                	mv	s4,a0
     56e:	892e                	mv	s2,a1
     570:	8ab2                	mv	s5,a2
  char *s;

  s = *ps;
     572:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     574:	00002997          	auipc	s3,0x2
     578:	a9498993          	addi	s3,s3,-1388 # 2008 <whitespace>
     57c:	00b4fd63          	bgeu	s1,a1,596 <peek+0x3c>
     580:	0004c583          	lbu	a1,0(s1)
     584:	854e                	mv	a0,s3
     586:	00000097          	auipc	ra,0x0
     58a:	6f2080e7          	jalr	1778(ra) # c78 <strchr>
     58e:	c501                	beqz	a0,596 <peek+0x3c>
    s++;
     590:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     592:	fe9917e3          	bne	s2,s1,580 <peek+0x26>
  *ps = s;
     596:	009a3023          	sd	s1,0(s4)
  return *s && strchr(toks, *s);
     59a:	0004c583          	lbu	a1,0(s1)
     59e:	4501                	li	a0,0
     5a0:	e991                	bnez	a1,5b4 <peek+0x5a>
}
     5a2:	70e2                	ld	ra,56(sp)
     5a4:	7442                	ld	s0,48(sp)
     5a6:	74a2                	ld	s1,40(sp)
     5a8:	7902                	ld	s2,32(sp)
     5aa:	69e2                	ld	s3,24(sp)
     5ac:	6a42                	ld	s4,16(sp)
     5ae:	6aa2                	ld	s5,8(sp)
     5b0:	6121                	addi	sp,sp,64
     5b2:	8082                	ret
  return *s && strchr(toks, *s);
     5b4:	8556                	mv	a0,s5
     5b6:	00000097          	auipc	ra,0x0
     5ba:	6c2080e7          	jalr	1730(ra) # c78 <strchr>
     5be:	00a03533          	snez	a0,a0
     5c2:	b7c5                	j	5a2 <peek+0x48>

00000000000005c4 <parseredirs>:
  return cmd;
}

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     5c4:	7159                	addi	sp,sp,-112
     5c6:	f486                	sd	ra,104(sp)
     5c8:	f0a2                	sd	s0,96(sp)
     5ca:	eca6                	sd	s1,88(sp)
     5cc:	e8ca                	sd	s2,80(sp)
     5ce:	e4ce                	sd	s3,72(sp)
     5d0:	e0d2                	sd	s4,64(sp)
     5d2:	fc56                	sd	s5,56(sp)
     5d4:	f85a                	sd	s6,48(sp)
     5d6:	f45e                	sd	s7,40(sp)
     5d8:	f062                	sd	s8,32(sp)
     5da:	ec66                	sd	s9,24(sp)
     5dc:	1880                	addi	s0,sp,112
     5de:	8a2a                	mv	s4,a0
     5e0:	89ae                	mv	s3,a1
     5e2:	8932                	mv	s2,a2
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     5e4:	00001b97          	auipc	s7,0x1
     5e8:	e2cb8b93          	addi	s7,s7,-468 # 1410 <malloc+0x158>
    tok = gettoken(ps, es, 0, 0);
    if(gettoken(ps, es, &q, &eq) != 'a')
     5ec:	06100c13          	li	s8,97
      panic("missing file for redirection");
    switch(tok){
     5f0:	03c00c93          	li	s9,60
  while(peek(ps, es, "<>")){
     5f4:	a02d                	j	61e <parseredirs+0x5a>
      panic("missing file for redirection");
     5f6:	00001517          	auipc	a0,0x1
     5fa:	dfa50513          	addi	a0,a0,-518 # 13f0 <malloc+0x138>
     5fe:	00000097          	auipc	ra,0x0
     602:	a58080e7          	jalr	-1448(ra) # 56 <panic>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     606:	4701                	li	a4,0
     608:	4681                	li	a3,0
     60a:	f9043603          	ld	a2,-112(s0)
     60e:	f9843583          	ld	a1,-104(s0)
     612:	8552                	mv	a0,s4
     614:	00000097          	auipc	ra,0x0
     618:	cda080e7          	jalr	-806(ra) # 2ee <redircmd>
     61c:	8a2a                	mv	s4,a0
    switch(tok){
     61e:	03e00b13          	li	s6,62
     622:	02b00a93          	li	s5,43
  while(peek(ps, es, "<>")){
     626:	865e                	mv	a2,s7
     628:	85ca                	mv	a1,s2
     62a:	854e                	mv	a0,s3
     62c:	00000097          	auipc	ra,0x0
     630:	f2e080e7          	jalr	-210(ra) # 55a <peek>
     634:	c925                	beqz	a0,6a4 <parseredirs+0xe0>
    tok = gettoken(ps, es, 0, 0);
     636:	4681                	li	a3,0
     638:	4601                	li	a2,0
     63a:	85ca                	mv	a1,s2
     63c:	854e                	mv	a0,s3
     63e:	00000097          	auipc	ra,0x0
     642:	de0080e7          	jalr	-544(ra) # 41e <gettoken>
     646:	84aa                	mv	s1,a0
    if(gettoken(ps, es, &q, &eq) != 'a')
     648:	f9040693          	addi	a3,s0,-112
     64c:	f9840613          	addi	a2,s0,-104
     650:	85ca                	mv	a1,s2
     652:	854e                	mv	a0,s3
     654:	00000097          	auipc	ra,0x0
     658:	dca080e7          	jalr	-566(ra) # 41e <gettoken>
     65c:	f9851de3          	bne	a0,s8,5f6 <parseredirs+0x32>
    switch(tok){
     660:	fb9483e3          	beq	s1,s9,606 <parseredirs+0x42>
     664:	03648263          	beq	s1,s6,688 <parseredirs+0xc4>
     668:	fb549fe3          	bne	s1,s5,626 <parseredirs+0x62>
      break;
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
      break;
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     66c:	4705                	li	a4,1
     66e:	20100693          	li	a3,513
     672:	f9043603          	ld	a2,-112(s0)
     676:	f9843583          	ld	a1,-104(s0)
     67a:	8552                	mv	a0,s4
     67c:	00000097          	auipc	ra,0x0
     680:	c72080e7          	jalr	-910(ra) # 2ee <redircmd>
     684:	8a2a                	mv	s4,a0
      break;
     686:	bf61                	j	61e <parseredirs+0x5a>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
     688:	4705                	li	a4,1
     68a:	60100693          	li	a3,1537
     68e:	f9043603          	ld	a2,-112(s0)
     692:	f9843583          	ld	a1,-104(s0)
     696:	8552                	mv	a0,s4
     698:	00000097          	auipc	ra,0x0
     69c:	c56080e7          	jalr	-938(ra) # 2ee <redircmd>
     6a0:	8a2a                	mv	s4,a0
      break;
     6a2:	bfb5                	j	61e <parseredirs+0x5a>
    }
  }
  return cmd;
}
     6a4:	8552                	mv	a0,s4
     6a6:	70a6                	ld	ra,104(sp)
     6a8:	7406                	ld	s0,96(sp)
     6aa:	64e6                	ld	s1,88(sp)
     6ac:	6946                	ld	s2,80(sp)
     6ae:	69a6                	ld	s3,72(sp)
     6b0:	6a06                	ld	s4,64(sp)
     6b2:	7ae2                	ld	s5,56(sp)
     6b4:	7b42                	ld	s6,48(sp)
     6b6:	7ba2                	ld	s7,40(sp)
     6b8:	7c02                	ld	s8,32(sp)
     6ba:	6ce2                	ld	s9,24(sp)
     6bc:	6165                	addi	sp,sp,112
     6be:	8082                	ret

00000000000006c0 <parseexec>:
  return cmd;
}

struct cmd*
parseexec(char **ps, char *es)
{
     6c0:	7159                	addi	sp,sp,-112
     6c2:	f486                	sd	ra,104(sp)
     6c4:	f0a2                	sd	s0,96(sp)
     6c6:	eca6                	sd	s1,88(sp)
     6c8:	e8ca                	sd	s2,80(sp)
     6ca:	e4ce                	sd	s3,72(sp)
     6cc:	e0d2                	sd	s4,64(sp)
     6ce:	fc56                	sd	s5,56(sp)
     6d0:	f85a                	sd	s6,48(sp)
     6d2:	f45e                	sd	s7,40(sp)
     6d4:	f062                	sd	s8,32(sp)
     6d6:	ec66                	sd	s9,24(sp)
     6d8:	1880                	addi	s0,sp,112
     6da:	8a2a                	mv	s4,a0
     6dc:	8aae                	mv	s5,a1
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;

  if(peek(ps, es, "("))
     6de:	00001617          	auipc	a2,0x1
     6e2:	d3a60613          	addi	a2,a2,-710 # 1418 <malloc+0x160>
     6e6:	00000097          	auipc	ra,0x0
     6ea:	e74080e7          	jalr	-396(ra) # 55a <peek>
     6ee:	e905                	bnez	a0,71e <parseexec+0x5e>
     6f0:	89aa                	mv	s3,a0
    return parseblock(ps, es);

  ret = execcmd();
     6f2:	00000097          	auipc	ra,0x0
     6f6:	bc6080e7          	jalr	-1082(ra) # 2b8 <execcmd>
     6fa:	8c2a                	mv	s8,a0
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
     6fc:	8656                	mv	a2,s5
     6fe:	85d2                	mv	a1,s4
     700:	00000097          	auipc	ra,0x0
     704:	ec4080e7          	jalr	-316(ra) # 5c4 <parseredirs>
     708:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     70a:	008c0913          	addi	s2,s8,8
     70e:	00001b17          	auipc	s6,0x1
     712:	d2ab0b13          	addi	s6,s6,-726 # 1438 <malloc+0x180>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
    if(tok != 'a')
     716:	06100c93          	li	s9,97
      panic("syntax");
    cmd->argv[argc] = q;
    cmd->eargv[argc] = eq;
    argc++;
    if(argc >= MAXARGS)
     71a:	4ba9                	li	s7,10
  while(!peek(ps, es, "|)&;")){
     71c:	a0b1                	j	768 <parseexec+0xa8>
    return parseblock(ps, es);
     71e:	85d6                	mv	a1,s5
     720:	8552                	mv	a0,s4
     722:	00000097          	auipc	ra,0x0
     726:	1bc080e7          	jalr	444(ra) # 8de <parseblock>
     72a:	84aa                	mv	s1,a0
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
  cmd->eargv[argc] = 0;
  return ret;
}
     72c:	8526                	mv	a0,s1
     72e:	70a6                	ld	ra,104(sp)
     730:	7406                	ld	s0,96(sp)
     732:	64e6                	ld	s1,88(sp)
     734:	6946                	ld	s2,80(sp)
     736:	69a6                	ld	s3,72(sp)
     738:	6a06                	ld	s4,64(sp)
     73a:	7ae2                	ld	s5,56(sp)
     73c:	7b42                	ld	s6,48(sp)
     73e:	7ba2                	ld	s7,40(sp)
     740:	7c02                	ld	s8,32(sp)
     742:	6ce2                	ld	s9,24(sp)
     744:	6165                	addi	sp,sp,112
     746:	8082                	ret
      panic("syntax");
     748:	00001517          	auipc	a0,0x1
     74c:	cd850513          	addi	a0,a0,-808 # 1420 <malloc+0x168>
     750:	00000097          	auipc	ra,0x0
     754:	906080e7          	jalr	-1786(ra) # 56 <panic>
    ret = parseredirs(ret, ps, es);
     758:	8656                	mv	a2,s5
     75a:	85d2                	mv	a1,s4
     75c:	8526                	mv	a0,s1
     75e:	00000097          	auipc	ra,0x0
     762:	e66080e7          	jalr	-410(ra) # 5c4 <parseredirs>
     766:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     768:	865a                	mv	a2,s6
     76a:	85d6                	mv	a1,s5
     76c:	8552                	mv	a0,s4
     76e:	00000097          	auipc	ra,0x0
     772:	dec080e7          	jalr	-532(ra) # 55a <peek>
     776:	e131                	bnez	a0,7ba <parseexec+0xfa>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     778:	f9040693          	addi	a3,s0,-112
     77c:	f9840613          	addi	a2,s0,-104
     780:	85d6                	mv	a1,s5
     782:	8552                	mv	a0,s4
     784:	00000097          	auipc	ra,0x0
     788:	c9a080e7          	jalr	-870(ra) # 41e <gettoken>
     78c:	c51d                	beqz	a0,7ba <parseexec+0xfa>
    if(tok != 'a')
     78e:	fb951de3          	bne	a0,s9,748 <parseexec+0x88>
    cmd->argv[argc] = q;
     792:	f9843783          	ld	a5,-104(s0)
     796:	00f93023          	sd	a5,0(s2)
    cmd->eargv[argc] = eq;
     79a:	f9043783          	ld	a5,-112(s0)
     79e:	04f93823          	sd	a5,80(s2)
    argc++;
     7a2:	2985                	addiw	s3,s3,1
    if(argc >= MAXARGS)
     7a4:	0921                	addi	s2,s2,8
     7a6:	fb7999e3          	bne	s3,s7,758 <parseexec+0x98>
      panic("too many args");
     7aa:	00001517          	auipc	a0,0x1
     7ae:	c7e50513          	addi	a0,a0,-898 # 1428 <malloc+0x170>
     7b2:	00000097          	auipc	ra,0x0
     7b6:	8a4080e7          	jalr	-1884(ra) # 56 <panic>
  cmd->argv[argc] = 0;
     7ba:	098e                	slli	s3,s3,0x3
     7bc:	99e2                	add	s3,s3,s8
     7be:	0009b423          	sd	zero,8(s3)
  cmd->eargv[argc] = 0;
     7c2:	0409bc23          	sd	zero,88(s3)
  return ret;
     7c6:	b79d                	j	72c <parseexec+0x6c>

00000000000007c8 <parsepipe>:
{
     7c8:	7179                	addi	sp,sp,-48
     7ca:	f406                	sd	ra,40(sp)
     7cc:	f022                	sd	s0,32(sp)
     7ce:	ec26                	sd	s1,24(sp)
     7d0:	e84a                	sd	s2,16(sp)
     7d2:	e44e                	sd	s3,8(sp)
     7d4:	1800                	addi	s0,sp,48
     7d6:	892a                	mv	s2,a0
     7d8:	89ae                	mv	s3,a1
  cmd = parseexec(ps, es);
     7da:	00000097          	auipc	ra,0x0
     7de:	ee6080e7          	jalr	-282(ra) # 6c0 <parseexec>
     7e2:	84aa                	mv	s1,a0
  if(peek(ps, es, "|")){
     7e4:	00001617          	auipc	a2,0x1
     7e8:	c5c60613          	addi	a2,a2,-932 # 1440 <malloc+0x188>
     7ec:	85ce                	mv	a1,s3
     7ee:	854a                	mv	a0,s2
     7f0:	00000097          	auipc	ra,0x0
     7f4:	d6a080e7          	jalr	-662(ra) # 55a <peek>
     7f8:	e909                	bnez	a0,80a <parsepipe+0x42>
}
     7fa:	8526                	mv	a0,s1
     7fc:	70a2                	ld	ra,40(sp)
     7fe:	7402                	ld	s0,32(sp)
     800:	64e2                	ld	s1,24(sp)
     802:	6942                	ld	s2,16(sp)
     804:	69a2                	ld	s3,8(sp)
     806:	6145                	addi	sp,sp,48
     808:	8082                	ret
    gettoken(ps, es, 0, 0);
     80a:	4681                	li	a3,0
     80c:	4601                	li	a2,0
     80e:	85ce                	mv	a1,s3
     810:	854a                	mv	a0,s2
     812:	00000097          	auipc	ra,0x0
     816:	c0c080e7          	jalr	-1012(ra) # 41e <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     81a:	85ce                	mv	a1,s3
     81c:	854a                	mv	a0,s2
     81e:	00000097          	auipc	ra,0x0
     822:	faa080e7          	jalr	-86(ra) # 7c8 <parsepipe>
     826:	85aa                	mv	a1,a0
     828:	8526                	mv	a0,s1
     82a:	00000097          	auipc	ra,0x0
     82e:	b2c080e7          	jalr	-1236(ra) # 356 <pipecmd>
     832:	84aa                	mv	s1,a0
  return cmd;
     834:	b7d9                	j	7fa <parsepipe+0x32>

0000000000000836 <parseline>:
{
     836:	7179                	addi	sp,sp,-48
     838:	f406                	sd	ra,40(sp)
     83a:	f022                	sd	s0,32(sp)
     83c:	ec26                	sd	s1,24(sp)
     83e:	e84a                	sd	s2,16(sp)
     840:	e44e                	sd	s3,8(sp)
     842:	e052                	sd	s4,0(sp)
     844:	1800                	addi	s0,sp,48
     846:	892a                	mv	s2,a0
     848:	89ae                	mv	s3,a1
  cmd = parsepipe(ps, es);
     84a:	00000097          	auipc	ra,0x0
     84e:	f7e080e7          	jalr	-130(ra) # 7c8 <parsepipe>
     852:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     854:	00001a17          	auipc	s4,0x1
     858:	bf4a0a13          	addi	s4,s4,-1036 # 1448 <malloc+0x190>
     85c:	a839                	j	87a <parseline+0x44>
    gettoken(ps, es, 0, 0);
     85e:	4681                	li	a3,0
     860:	4601                	li	a2,0
     862:	85ce                	mv	a1,s3
     864:	854a                	mv	a0,s2
     866:	00000097          	auipc	ra,0x0
     86a:	bb8080e7          	jalr	-1096(ra) # 41e <gettoken>
    cmd = backcmd(cmd);
     86e:	8526                	mv	a0,s1
     870:	00000097          	auipc	ra,0x0
     874:	b72080e7          	jalr	-1166(ra) # 3e2 <backcmd>
     878:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     87a:	8652                	mv	a2,s4
     87c:	85ce                	mv	a1,s3
     87e:	854a                	mv	a0,s2
     880:	00000097          	auipc	ra,0x0
     884:	cda080e7          	jalr	-806(ra) # 55a <peek>
     888:	f979                	bnez	a0,85e <parseline+0x28>
  if(peek(ps, es, ";")){
     88a:	00001617          	auipc	a2,0x1
     88e:	bc660613          	addi	a2,a2,-1082 # 1450 <malloc+0x198>
     892:	85ce                	mv	a1,s3
     894:	854a                	mv	a0,s2
     896:	00000097          	auipc	ra,0x0
     89a:	cc4080e7          	jalr	-828(ra) # 55a <peek>
     89e:	e911                	bnez	a0,8b2 <parseline+0x7c>
}
     8a0:	8526                	mv	a0,s1
     8a2:	70a2                	ld	ra,40(sp)
     8a4:	7402                	ld	s0,32(sp)
     8a6:	64e2                	ld	s1,24(sp)
     8a8:	6942                	ld	s2,16(sp)
     8aa:	69a2                	ld	s3,8(sp)
     8ac:	6a02                	ld	s4,0(sp)
     8ae:	6145                	addi	sp,sp,48
     8b0:	8082                	ret
    gettoken(ps, es, 0, 0);
     8b2:	4681                	li	a3,0
     8b4:	4601                	li	a2,0
     8b6:	85ce                	mv	a1,s3
     8b8:	854a                	mv	a0,s2
     8ba:	00000097          	auipc	ra,0x0
     8be:	b64080e7          	jalr	-1180(ra) # 41e <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     8c2:	85ce                	mv	a1,s3
     8c4:	854a                	mv	a0,s2
     8c6:	00000097          	auipc	ra,0x0
     8ca:	f70080e7          	jalr	-144(ra) # 836 <parseline>
     8ce:	85aa                	mv	a1,a0
     8d0:	8526                	mv	a0,s1
     8d2:	00000097          	auipc	ra,0x0
     8d6:	aca080e7          	jalr	-1334(ra) # 39c <listcmd>
     8da:	84aa                	mv	s1,a0
  return cmd;
     8dc:	b7d1                	j	8a0 <parseline+0x6a>

00000000000008de <parseblock>:
{
     8de:	7179                	addi	sp,sp,-48
     8e0:	f406                	sd	ra,40(sp)
     8e2:	f022                	sd	s0,32(sp)
     8e4:	ec26                	sd	s1,24(sp)
     8e6:	e84a                	sd	s2,16(sp)
     8e8:	e44e                	sd	s3,8(sp)
     8ea:	1800                	addi	s0,sp,48
     8ec:	84aa                	mv	s1,a0
     8ee:	892e                	mv	s2,a1
  if(!peek(ps, es, "("))
     8f0:	00001617          	auipc	a2,0x1
     8f4:	b2860613          	addi	a2,a2,-1240 # 1418 <malloc+0x160>
     8f8:	00000097          	auipc	ra,0x0
     8fc:	c62080e7          	jalr	-926(ra) # 55a <peek>
     900:	c12d                	beqz	a0,962 <parseblock+0x84>
  gettoken(ps, es, 0, 0);
     902:	4681                	li	a3,0
     904:	4601                	li	a2,0
     906:	85ca                	mv	a1,s2
     908:	8526                	mv	a0,s1
     90a:	00000097          	auipc	ra,0x0
     90e:	b14080e7          	jalr	-1260(ra) # 41e <gettoken>
  cmd = parseline(ps, es);
     912:	85ca                	mv	a1,s2
     914:	8526                	mv	a0,s1
     916:	00000097          	auipc	ra,0x0
     91a:	f20080e7          	jalr	-224(ra) # 836 <parseline>
     91e:	89aa                	mv	s3,a0
  if(!peek(ps, es, ")"))
     920:	00001617          	auipc	a2,0x1
     924:	b4860613          	addi	a2,a2,-1208 # 1468 <malloc+0x1b0>
     928:	85ca                	mv	a1,s2
     92a:	8526                	mv	a0,s1
     92c:	00000097          	auipc	ra,0x0
     930:	c2e080e7          	jalr	-978(ra) # 55a <peek>
     934:	cd1d                	beqz	a0,972 <parseblock+0x94>
  gettoken(ps, es, 0, 0);
     936:	4681                	li	a3,0
     938:	4601                	li	a2,0
     93a:	85ca                	mv	a1,s2
     93c:	8526                	mv	a0,s1
     93e:	00000097          	auipc	ra,0x0
     942:	ae0080e7          	jalr	-1312(ra) # 41e <gettoken>
  cmd = parseredirs(cmd, ps, es);
     946:	864a                	mv	a2,s2
     948:	85a6                	mv	a1,s1
     94a:	854e                	mv	a0,s3
     94c:	00000097          	auipc	ra,0x0
     950:	c78080e7          	jalr	-904(ra) # 5c4 <parseredirs>
}
     954:	70a2                	ld	ra,40(sp)
     956:	7402                	ld	s0,32(sp)
     958:	64e2                	ld	s1,24(sp)
     95a:	6942                	ld	s2,16(sp)
     95c:	69a2                	ld	s3,8(sp)
     95e:	6145                	addi	sp,sp,48
     960:	8082                	ret
    panic("parseblock");
     962:	00001517          	auipc	a0,0x1
     966:	af650513          	addi	a0,a0,-1290 # 1458 <malloc+0x1a0>
     96a:	fffff097          	auipc	ra,0xfffff
     96e:	6ec080e7          	jalr	1772(ra) # 56 <panic>
    panic("syntax - missing )");
     972:	00001517          	auipc	a0,0x1
     976:	afe50513          	addi	a0,a0,-1282 # 1470 <malloc+0x1b8>
     97a:	fffff097          	auipc	ra,0xfffff
     97e:	6dc080e7          	jalr	1756(ra) # 56 <panic>

0000000000000982 <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     982:	1101                	addi	sp,sp,-32
     984:	ec06                	sd	ra,24(sp)
     986:	e822                	sd	s0,16(sp)
     988:	e426                	sd	s1,8(sp)
     98a:	1000                	addi	s0,sp,32
     98c:	84aa                	mv	s1,a0
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     98e:	c521                	beqz	a0,9d6 <nulterminate+0x54>
    return 0;

  switch(cmd->type){
     990:	4118                	lw	a4,0(a0)
     992:	4795                	li	a5,5
     994:	04e7e163          	bltu	a5,a4,9d6 <nulterminate+0x54>
     998:	00056783          	lwu	a5,0(a0)
     99c:	078a                	slli	a5,a5,0x2
     99e:	00001717          	auipc	a4,0x1
     9a2:	b5a70713          	addi	a4,a4,-1190 # 14f8 <malloc+0x240>
     9a6:	97ba                	add	a5,a5,a4
     9a8:	439c                	lw	a5,0(a5)
     9aa:	97ba                	add	a5,a5,a4
     9ac:	8782                	jr	a5
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     9ae:	651c                	ld	a5,8(a0)
     9b0:	c39d                	beqz	a5,9d6 <nulterminate+0x54>
     9b2:	01050793          	addi	a5,a0,16
      *ecmd->eargv[i] = 0;
     9b6:	67b8                	ld	a4,72(a5)
     9b8:	00070023          	sb	zero,0(a4)
    for(i=0; ecmd->argv[i]; i++)
     9bc:	07a1                	addi	a5,a5,8
     9be:	ff87b703          	ld	a4,-8(a5)
     9c2:	fb75                	bnez	a4,9b6 <nulterminate+0x34>
     9c4:	a809                	j	9d6 <nulterminate+0x54>
    break;

  case REDIR:
    rcmd = (struct redircmd*)cmd;
    nulterminate(rcmd->cmd);
     9c6:	6508                	ld	a0,8(a0)
     9c8:	00000097          	auipc	ra,0x0
     9cc:	fba080e7          	jalr	-70(ra) # 982 <nulterminate>
    *rcmd->efile = 0;
     9d0:	6c9c                	ld	a5,24(s1)
     9d2:	00078023          	sb	zero,0(a5)
    bcmd = (struct backcmd*)cmd;
    nulterminate(bcmd->cmd);
    break;
  }
  return cmd;
}
     9d6:	8526                	mv	a0,s1
     9d8:	60e2                	ld	ra,24(sp)
     9da:	6442                	ld	s0,16(sp)
     9dc:	64a2                	ld	s1,8(sp)
     9de:	6105                	addi	sp,sp,32
     9e0:	8082                	ret
    nulterminate(pcmd->left);
     9e2:	6508                	ld	a0,8(a0)
     9e4:	00000097          	auipc	ra,0x0
     9e8:	f9e080e7          	jalr	-98(ra) # 982 <nulterminate>
    nulterminate(pcmd->right);
     9ec:	6888                	ld	a0,16(s1)
     9ee:	00000097          	auipc	ra,0x0
     9f2:	f94080e7          	jalr	-108(ra) # 982 <nulterminate>
    break;
     9f6:	b7c5                	j	9d6 <nulterminate+0x54>
    nulterminate(lcmd->left);
     9f8:	6508                	ld	a0,8(a0)
     9fa:	00000097          	auipc	ra,0x0
     9fe:	f88080e7          	jalr	-120(ra) # 982 <nulterminate>
    nulterminate(lcmd->right);
     a02:	6888                	ld	a0,16(s1)
     a04:	00000097          	auipc	ra,0x0
     a08:	f7e080e7          	jalr	-130(ra) # 982 <nulterminate>
    break;
     a0c:	b7e9                	j	9d6 <nulterminate+0x54>
    nulterminate(bcmd->cmd);
     a0e:	6508                	ld	a0,8(a0)
     a10:	00000097          	auipc	ra,0x0
     a14:	f72080e7          	jalr	-142(ra) # 982 <nulterminate>
    break;
     a18:	bf7d                	j	9d6 <nulterminate+0x54>

0000000000000a1a <parsecmd>:
{
     a1a:	7179                	addi	sp,sp,-48
     a1c:	f406                	sd	ra,40(sp)
     a1e:	f022                	sd	s0,32(sp)
     a20:	ec26                	sd	s1,24(sp)
     a22:	e84a                	sd	s2,16(sp)
     a24:	1800                	addi	s0,sp,48
     a26:	fca43c23          	sd	a0,-40(s0)
  es = s + strlen(s);
     a2a:	84aa                	mv	s1,a0
     a2c:	00000097          	auipc	ra,0x0
     a30:	200080e7          	jalr	512(ra) # c2c <strlen>
     a34:	1502                	slli	a0,a0,0x20
     a36:	9101                	srli	a0,a0,0x20
     a38:	94aa                	add	s1,s1,a0
  cmd = parseline(&s, es);
     a3a:	85a6                	mv	a1,s1
     a3c:	fd840513          	addi	a0,s0,-40
     a40:	00000097          	auipc	ra,0x0
     a44:	df6080e7          	jalr	-522(ra) # 836 <parseline>
     a48:	892a                	mv	s2,a0
  peek(&s, es, "");
     a4a:	00001617          	auipc	a2,0x1
     a4e:	96660613          	addi	a2,a2,-1690 # 13b0 <malloc+0xf8>
     a52:	85a6                	mv	a1,s1
     a54:	fd840513          	addi	a0,s0,-40
     a58:	00000097          	auipc	ra,0x0
     a5c:	b02080e7          	jalr	-1278(ra) # 55a <peek>
  if(s != es){
     a60:	fd843603          	ld	a2,-40(s0)
     a64:	00961e63          	bne	a2,s1,a80 <parsecmd+0x66>
  nulterminate(cmd);
     a68:	854a                	mv	a0,s2
     a6a:	00000097          	auipc	ra,0x0
     a6e:	f18080e7          	jalr	-232(ra) # 982 <nulterminate>
}
     a72:	854a                	mv	a0,s2
     a74:	70a2                	ld	ra,40(sp)
     a76:	7402                	ld	s0,32(sp)
     a78:	64e2                	ld	s1,24(sp)
     a7a:	6942                	ld	s2,16(sp)
     a7c:	6145                	addi	sp,sp,48
     a7e:	8082                	ret
    fprintf(2, "leftovers: %s\n", s);
     a80:	00001597          	auipc	a1,0x1
     a84:	a0858593          	addi	a1,a1,-1528 # 1488 <malloc+0x1d0>
     a88:	4509                	li	a0,2
     a8a:	00000097          	auipc	ra,0x0
     a8e:	742080e7          	jalr	1858(ra) # 11cc <fprintf>
    panic("syntax");
     a92:	00001517          	auipc	a0,0x1
     a96:	98e50513          	addi	a0,a0,-1650 # 1420 <malloc+0x168>
     a9a:	fffff097          	auipc	ra,0xfffff
     a9e:	5bc080e7          	jalr	1468(ra) # 56 <panic>

0000000000000aa2 <main>:
{
     aa2:	7159                	addi	sp,sp,-112
     aa4:	f486                	sd	ra,104(sp)
     aa6:	f0a2                	sd	s0,96(sp)
     aa8:	eca6                	sd	s1,88(sp)
     aaa:	e8ca                	sd	s2,80(sp)
     aac:	e4ce                	sd	s3,72(sp)
     aae:	e0d2                	sd	s4,64(sp)
     ab0:	fc56                	sd	s5,56(sp)
     ab2:	f85a                	sd	s6,48(sp)
     ab4:	1880                	addi	s0,sp,112
  while((fd = open("console", O_RDWR)) >= 0){
     ab6:	00001497          	auipc	s1,0x1
     aba:	9e248493          	addi	s1,s1,-1566 # 1498 <malloc+0x1e0>
     abe:	4589                	li	a1,2
     ac0:	8526                	mv	a0,s1
     ac2:	00000097          	auipc	ra,0x0
     ac6:	3d0080e7          	jalr	976(ra) # e92 <open>
     aca:	00054963          	bltz	a0,adc <main+0x3a>
    if(fd >= 3){
     ace:	4789                	li	a5,2
     ad0:	fea7d7e3          	bge	a5,a0,abe <main+0x1c>
      close(fd);
     ad4:	00000097          	auipc	ra,0x0
     ad8:	3a6080e7          	jalr	934(ra) # e7a <close>
  while(getcmd(buf, sizeof(buf)) >= 0){
     adc:	00001497          	auipc	s1,0x1
     ae0:	54448493          	addi	s1,s1,1348 # 2020 <buf.0>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     ae4:	06300913          	li	s2,99
    printf("pid=%d: exited with status %d and message '%s'\n", pid, exit_status, exit_msg);
     ae8:	00001997          	auipc	s3,0x1
     aec:	9c898993          	addi	s3,s3,-1592 # 14b0 <malloc+0x1f8>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     af0:	02000a13          	li	s4,32
      if(chdir(buf+3) < 0)
     af4:	00001a97          	auipc	s5,0x1
     af8:	52fa8a93          	addi	s5,s5,1327 # 2023 <buf.0+0x3>
        fprintf(2, "cannot cd %s\n", buf+3);
     afc:	00001b17          	auipc	s6,0x1
     b00:	9a4b0b13          	addi	s6,s6,-1628 # 14a0 <malloc+0x1e8>
     b04:	a805                	j	b34 <main+0x92>
      if ((pid = fork1()) == 0) {
     b06:	fffff097          	auipc	ra,0xfffff
     b0a:	57e080e7          	jalr	1406(ra) # 84 <fork1>
     b0e:	c549                	beqz	a0,b98 <main+0xf6>
    pid = wait((int*)&exit_status, exit_msg);
     b10:	fa040593          	addi	a1,s0,-96
     b14:	f9c40513          	addi	a0,s0,-100
     b18:	00000097          	auipc	ra,0x0
     b1c:	342080e7          	jalr	834(ra) # e5a <wait>
     b20:	85aa                	mv	a1,a0
    printf("pid=%d: exited with status %d and message '%s'\n", pid, exit_status, exit_msg);
     b22:	fa040693          	addi	a3,s0,-96
     b26:	f9c42603          	lw	a2,-100(s0)
     b2a:	854e                	mv	a0,s3
     b2c:	00000097          	auipc	ra,0x0
     b30:	6ce080e7          	jalr	1742(ra) # 11fa <printf>
  while(getcmd(buf, sizeof(buf)) >= 0){
     b34:	06400593          	li	a1,100
     b38:	8526                	mv	a0,s1
     b3a:	fffff097          	auipc	ra,0xfffff
     b3e:	4c6080e7          	jalr	1222(ra) # 0 <getcmd>
     b42:	06054763          	bltz	a0,bb0 <main+0x10e>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     b46:	0004c783          	lbu	a5,0(s1)
     b4a:	fb279ee3          	bne	a5,s2,b06 <main+0x64>
     b4e:	0014c703          	lbu	a4,1(s1)
     b52:	06400793          	li	a5,100
     b56:	faf718e3          	bne	a4,a5,b06 <main+0x64>
     b5a:	0024c783          	lbu	a5,2(s1)
     b5e:	fb4794e3          	bne	a5,s4,b06 <main+0x64>
      buf[strlen(buf)-1] = 0;  // chop \n
     b62:	8526                	mv	a0,s1
     b64:	00000097          	auipc	ra,0x0
     b68:	0c8080e7          	jalr	200(ra) # c2c <strlen>
     b6c:	fff5079b          	addiw	a5,a0,-1
     b70:	1782                	slli	a5,a5,0x20
     b72:	9381                	srli	a5,a5,0x20
     b74:	97a6                	add	a5,a5,s1
     b76:	00078023          	sb	zero,0(a5)
      if(chdir(buf+3) < 0)
     b7a:	8556                	mv	a0,s5
     b7c:	00000097          	auipc	ra,0x0
     b80:	346080e7          	jalr	838(ra) # ec2 <chdir>
     b84:	fa0558e3          	bgez	a0,b34 <main+0x92>
        fprintf(2, "cannot cd %s\n", buf+3);
     b88:	8656                	mv	a2,s5
     b8a:	85da                	mv	a1,s6
     b8c:	4509                	li	a0,2
     b8e:	00000097          	auipc	ra,0x0
     b92:	63e080e7          	jalr	1598(ra) # 11cc <fprintf>
      continue;
     b96:	bf79                	j	b34 <main+0x92>
        runcmd(parsecmd(buf));
     b98:	00001517          	auipc	a0,0x1
     b9c:	48850513          	addi	a0,a0,1160 # 2020 <buf.0>
     ba0:	00000097          	auipc	ra,0x0
     ba4:	e7a080e7          	jalr	-390(ra) # a1a <parsecmd>
     ba8:	fffff097          	auipc	ra,0xfffff
     bac:	50a080e7          	jalr	1290(ra) # b2 <runcmd>
  exit(0, "");
     bb0:	00001597          	auipc	a1,0x1
     bb4:	80058593          	addi	a1,a1,-2048 # 13b0 <malloc+0xf8>
     bb8:	4501                	li	a0,0
     bba:	00000097          	auipc	ra,0x0
     bbe:	298080e7          	jalr	664(ra) # e52 <exit>

0000000000000bc2 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
     bc2:	1141                	addi	sp,sp,-16
     bc4:	e406                	sd	ra,8(sp)
     bc6:	e022                	sd	s0,0(sp)
     bc8:	0800                	addi	s0,sp,16
  extern int main();
  main();
     bca:	00000097          	auipc	ra,0x0
     bce:	ed8080e7          	jalr	-296(ra) # aa2 <main>
  exit(0,"");
     bd2:	00000597          	auipc	a1,0x0
     bd6:	7de58593          	addi	a1,a1,2014 # 13b0 <malloc+0xf8>
     bda:	4501                	li	a0,0
     bdc:	00000097          	auipc	ra,0x0
     be0:	276080e7          	jalr	630(ra) # e52 <exit>

0000000000000be4 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     be4:	1141                	addi	sp,sp,-16
     be6:	e422                	sd	s0,8(sp)
     be8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     bea:	87aa                	mv	a5,a0
     bec:	0585                	addi	a1,a1,1
     bee:	0785                	addi	a5,a5,1
     bf0:	fff5c703          	lbu	a4,-1(a1)
     bf4:	fee78fa3          	sb	a4,-1(a5)
     bf8:	fb75                	bnez	a4,bec <strcpy+0x8>
    ;
  return os;
}
     bfa:	6422                	ld	s0,8(sp)
     bfc:	0141                	addi	sp,sp,16
     bfe:	8082                	ret

0000000000000c00 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     c00:	1141                	addi	sp,sp,-16
     c02:	e422                	sd	s0,8(sp)
     c04:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     c06:	00054783          	lbu	a5,0(a0)
     c0a:	cb91                	beqz	a5,c1e <strcmp+0x1e>
     c0c:	0005c703          	lbu	a4,0(a1)
     c10:	00f71763          	bne	a4,a5,c1e <strcmp+0x1e>
    p++, q++;
     c14:	0505                	addi	a0,a0,1
     c16:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     c18:	00054783          	lbu	a5,0(a0)
     c1c:	fbe5                	bnez	a5,c0c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     c1e:	0005c503          	lbu	a0,0(a1)
}
     c22:	40a7853b          	subw	a0,a5,a0
     c26:	6422                	ld	s0,8(sp)
     c28:	0141                	addi	sp,sp,16
     c2a:	8082                	ret

0000000000000c2c <strlen>:

uint
strlen(const char *s)
{
     c2c:	1141                	addi	sp,sp,-16
     c2e:	e422                	sd	s0,8(sp)
     c30:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     c32:	00054783          	lbu	a5,0(a0)
     c36:	cf91                	beqz	a5,c52 <strlen+0x26>
     c38:	0505                	addi	a0,a0,1
     c3a:	87aa                	mv	a5,a0
     c3c:	4685                	li	a3,1
     c3e:	9e89                	subw	a3,a3,a0
     c40:	00f6853b          	addw	a0,a3,a5
     c44:	0785                	addi	a5,a5,1
     c46:	fff7c703          	lbu	a4,-1(a5)
     c4a:	fb7d                	bnez	a4,c40 <strlen+0x14>
    ;
  return n;
}
     c4c:	6422                	ld	s0,8(sp)
     c4e:	0141                	addi	sp,sp,16
     c50:	8082                	ret
  for(n = 0; s[n]; n++)
     c52:	4501                	li	a0,0
     c54:	bfe5                	j	c4c <strlen+0x20>

0000000000000c56 <memset>:

void*
memset(void *dst, int c, uint n)
{
     c56:	1141                	addi	sp,sp,-16
     c58:	e422                	sd	s0,8(sp)
     c5a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     c5c:	ca19                	beqz	a2,c72 <memset+0x1c>
     c5e:	87aa                	mv	a5,a0
     c60:	1602                	slli	a2,a2,0x20
     c62:	9201                	srli	a2,a2,0x20
     c64:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     c68:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     c6c:	0785                	addi	a5,a5,1
     c6e:	fee79de3          	bne	a5,a4,c68 <memset+0x12>
  }
  return dst;
}
     c72:	6422                	ld	s0,8(sp)
     c74:	0141                	addi	sp,sp,16
     c76:	8082                	ret

0000000000000c78 <strchr>:

char*
strchr(const char *s, char c)
{
     c78:	1141                	addi	sp,sp,-16
     c7a:	e422                	sd	s0,8(sp)
     c7c:	0800                	addi	s0,sp,16
  for(; *s; s++)
     c7e:	00054783          	lbu	a5,0(a0)
     c82:	cb99                	beqz	a5,c98 <strchr+0x20>
    if(*s == c)
     c84:	00f58763          	beq	a1,a5,c92 <strchr+0x1a>
  for(; *s; s++)
     c88:	0505                	addi	a0,a0,1
     c8a:	00054783          	lbu	a5,0(a0)
     c8e:	fbfd                	bnez	a5,c84 <strchr+0xc>
      return (char*)s;
  return 0;
     c90:	4501                	li	a0,0
}
     c92:	6422                	ld	s0,8(sp)
     c94:	0141                	addi	sp,sp,16
     c96:	8082                	ret
  return 0;
     c98:	4501                	li	a0,0
     c9a:	bfe5                	j	c92 <strchr+0x1a>

0000000000000c9c <gets>:

char*
gets(char *buf, int max)
{
     c9c:	711d                	addi	sp,sp,-96
     c9e:	ec86                	sd	ra,88(sp)
     ca0:	e8a2                	sd	s0,80(sp)
     ca2:	e4a6                	sd	s1,72(sp)
     ca4:	e0ca                	sd	s2,64(sp)
     ca6:	fc4e                	sd	s3,56(sp)
     ca8:	f852                	sd	s4,48(sp)
     caa:	f456                	sd	s5,40(sp)
     cac:	f05a                	sd	s6,32(sp)
     cae:	ec5e                	sd	s7,24(sp)
     cb0:	1080                	addi	s0,sp,96
     cb2:	8baa                	mv	s7,a0
     cb4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     cb6:	892a                	mv	s2,a0
     cb8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     cba:	4aa9                	li	s5,10
     cbc:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     cbe:	89a6                	mv	s3,s1
     cc0:	2485                	addiw	s1,s1,1
     cc2:	0344d863          	bge	s1,s4,cf2 <gets+0x56>
    cc = read(0, &c, 1);
     cc6:	4605                	li	a2,1
     cc8:	faf40593          	addi	a1,s0,-81
     ccc:	4501                	li	a0,0
     cce:	00000097          	auipc	ra,0x0
     cd2:	19c080e7          	jalr	412(ra) # e6a <read>
    if(cc < 1)
     cd6:	00a05e63          	blez	a0,cf2 <gets+0x56>
    buf[i++] = c;
     cda:	faf44783          	lbu	a5,-81(s0)
     cde:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     ce2:	01578763          	beq	a5,s5,cf0 <gets+0x54>
     ce6:	0905                	addi	s2,s2,1
     ce8:	fd679be3          	bne	a5,s6,cbe <gets+0x22>
  for(i=0; i+1 < max; ){
     cec:	89a6                	mv	s3,s1
     cee:	a011                	j	cf2 <gets+0x56>
     cf0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     cf2:	99de                	add	s3,s3,s7
     cf4:	00098023          	sb	zero,0(s3)
  return buf;
}
     cf8:	855e                	mv	a0,s7
     cfa:	60e6                	ld	ra,88(sp)
     cfc:	6446                	ld	s0,80(sp)
     cfe:	64a6                	ld	s1,72(sp)
     d00:	6906                	ld	s2,64(sp)
     d02:	79e2                	ld	s3,56(sp)
     d04:	7a42                	ld	s4,48(sp)
     d06:	7aa2                	ld	s5,40(sp)
     d08:	7b02                	ld	s6,32(sp)
     d0a:	6be2                	ld	s7,24(sp)
     d0c:	6125                	addi	sp,sp,96
     d0e:	8082                	ret

0000000000000d10 <stat>:

int
stat(const char *n, struct stat *st)
{
     d10:	1101                	addi	sp,sp,-32
     d12:	ec06                	sd	ra,24(sp)
     d14:	e822                	sd	s0,16(sp)
     d16:	e426                	sd	s1,8(sp)
     d18:	e04a                	sd	s2,0(sp)
     d1a:	1000                	addi	s0,sp,32
     d1c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     d1e:	4581                	li	a1,0
     d20:	00000097          	auipc	ra,0x0
     d24:	172080e7          	jalr	370(ra) # e92 <open>
  if(fd < 0)
     d28:	02054563          	bltz	a0,d52 <stat+0x42>
     d2c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     d2e:	85ca                	mv	a1,s2
     d30:	00000097          	auipc	ra,0x0
     d34:	17a080e7          	jalr	378(ra) # eaa <fstat>
     d38:	892a                	mv	s2,a0
  close(fd);
     d3a:	8526                	mv	a0,s1
     d3c:	00000097          	auipc	ra,0x0
     d40:	13e080e7          	jalr	318(ra) # e7a <close>
  return r;
}
     d44:	854a                	mv	a0,s2
     d46:	60e2                	ld	ra,24(sp)
     d48:	6442                	ld	s0,16(sp)
     d4a:	64a2                	ld	s1,8(sp)
     d4c:	6902                	ld	s2,0(sp)
     d4e:	6105                	addi	sp,sp,32
     d50:	8082                	ret
    return -1;
     d52:	597d                	li	s2,-1
     d54:	bfc5                	j	d44 <stat+0x34>

0000000000000d56 <atoi>:

int
atoi(const char *s)
{
     d56:	1141                	addi	sp,sp,-16
     d58:	e422                	sd	s0,8(sp)
     d5a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     d5c:	00054603          	lbu	a2,0(a0)
     d60:	fd06079b          	addiw	a5,a2,-48
     d64:	0ff7f793          	andi	a5,a5,255
     d68:	4725                	li	a4,9
     d6a:	02f76963          	bltu	a4,a5,d9c <atoi+0x46>
     d6e:	86aa                	mv	a3,a0
  n = 0;
     d70:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     d72:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     d74:	0685                	addi	a3,a3,1
     d76:	0025179b          	slliw	a5,a0,0x2
     d7a:	9fa9                	addw	a5,a5,a0
     d7c:	0017979b          	slliw	a5,a5,0x1
     d80:	9fb1                	addw	a5,a5,a2
     d82:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     d86:	0006c603          	lbu	a2,0(a3)
     d8a:	fd06071b          	addiw	a4,a2,-48
     d8e:	0ff77713          	andi	a4,a4,255
     d92:	fee5f1e3          	bgeu	a1,a4,d74 <atoi+0x1e>
  return n;
}
     d96:	6422                	ld	s0,8(sp)
     d98:	0141                	addi	sp,sp,16
     d9a:	8082                	ret
  n = 0;
     d9c:	4501                	li	a0,0
     d9e:	bfe5                	j	d96 <atoi+0x40>

0000000000000da0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     da0:	1141                	addi	sp,sp,-16
     da2:	e422                	sd	s0,8(sp)
     da4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     da6:	02b57463          	bgeu	a0,a1,dce <memmove+0x2e>
    while(n-- > 0)
     daa:	00c05f63          	blez	a2,dc8 <memmove+0x28>
     dae:	1602                	slli	a2,a2,0x20
     db0:	9201                	srli	a2,a2,0x20
     db2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     db6:	872a                	mv	a4,a0
      *dst++ = *src++;
     db8:	0585                	addi	a1,a1,1
     dba:	0705                	addi	a4,a4,1
     dbc:	fff5c683          	lbu	a3,-1(a1)
     dc0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     dc4:	fee79ae3          	bne	a5,a4,db8 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     dc8:	6422                	ld	s0,8(sp)
     dca:	0141                	addi	sp,sp,16
     dcc:	8082                	ret
    dst += n;
     dce:	00c50733          	add	a4,a0,a2
    src += n;
     dd2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     dd4:	fec05ae3          	blez	a2,dc8 <memmove+0x28>
     dd8:	fff6079b          	addiw	a5,a2,-1
     ddc:	1782                	slli	a5,a5,0x20
     dde:	9381                	srli	a5,a5,0x20
     de0:	fff7c793          	not	a5,a5
     de4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     de6:	15fd                	addi	a1,a1,-1
     de8:	177d                	addi	a4,a4,-1
     dea:	0005c683          	lbu	a3,0(a1)
     dee:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     df2:	fee79ae3          	bne	a5,a4,de6 <memmove+0x46>
     df6:	bfc9                	j	dc8 <memmove+0x28>

0000000000000df8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     df8:	1141                	addi	sp,sp,-16
     dfa:	e422                	sd	s0,8(sp)
     dfc:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     dfe:	ca05                	beqz	a2,e2e <memcmp+0x36>
     e00:	fff6069b          	addiw	a3,a2,-1
     e04:	1682                	slli	a3,a3,0x20
     e06:	9281                	srli	a3,a3,0x20
     e08:	0685                	addi	a3,a3,1
     e0a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     e0c:	00054783          	lbu	a5,0(a0)
     e10:	0005c703          	lbu	a4,0(a1)
     e14:	00e79863          	bne	a5,a4,e24 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     e18:	0505                	addi	a0,a0,1
    p2++;
     e1a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     e1c:	fed518e3          	bne	a0,a3,e0c <memcmp+0x14>
  }
  return 0;
     e20:	4501                	li	a0,0
     e22:	a019                	j	e28 <memcmp+0x30>
      return *p1 - *p2;
     e24:	40e7853b          	subw	a0,a5,a4
}
     e28:	6422                	ld	s0,8(sp)
     e2a:	0141                	addi	sp,sp,16
     e2c:	8082                	ret
  return 0;
     e2e:	4501                	li	a0,0
     e30:	bfe5                	j	e28 <memcmp+0x30>

0000000000000e32 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     e32:	1141                	addi	sp,sp,-16
     e34:	e406                	sd	ra,8(sp)
     e36:	e022                	sd	s0,0(sp)
     e38:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     e3a:	00000097          	auipc	ra,0x0
     e3e:	f66080e7          	jalr	-154(ra) # da0 <memmove>
}
     e42:	60a2                	ld	ra,8(sp)
     e44:	6402                	ld	s0,0(sp)
     e46:	0141                	addi	sp,sp,16
     e48:	8082                	ret

0000000000000e4a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     e4a:	4885                	li	a7,1
 ecall
     e4c:	00000073          	ecall
 ret
     e50:	8082                	ret

0000000000000e52 <exit>:
.global exit
exit:
 li a7, SYS_exit
     e52:	4889                	li	a7,2
 ecall
     e54:	00000073          	ecall
 ret
     e58:	8082                	ret

0000000000000e5a <wait>:
.global wait
wait:
 li a7, SYS_wait
     e5a:	488d                	li	a7,3
 ecall
     e5c:	00000073          	ecall
 ret
     e60:	8082                	ret

0000000000000e62 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     e62:	4891                	li	a7,4
 ecall
     e64:	00000073          	ecall
 ret
     e68:	8082                	ret

0000000000000e6a <read>:
.global read
read:
 li a7, SYS_read
     e6a:	4895                	li	a7,5
 ecall
     e6c:	00000073          	ecall
 ret
     e70:	8082                	ret

0000000000000e72 <write>:
.global write
write:
 li a7, SYS_write
     e72:	48c1                	li	a7,16
 ecall
     e74:	00000073          	ecall
 ret
     e78:	8082                	ret

0000000000000e7a <close>:
.global close
close:
 li a7, SYS_close
     e7a:	48d5                	li	a7,21
 ecall
     e7c:	00000073          	ecall
 ret
     e80:	8082                	ret

0000000000000e82 <kill>:
.global kill
kill:
 li a7, SYS_kill
     e82:	4899                	li	a7,6
 ecall
     e84:	00000073          	ecall
 ret
     e88:	8082                	ret

0000000000000e8a <exec>:
.global exec
exec:
 li a7, SYS_exec
     e8a:	489d                	li	a7,7
 ecall
     e8c:	00000073          	ecall
 ret
     e90:	8082                	ret

0000000000000e92 <open>:
.global open
open:
 li a7, SYS_open
     e92:	48bd                	li	a7,15
 ecall
     e94:	00000073          	ecall
 ret
     e98:	8082                	ret

0000000000000e9a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     e9a:	48c5                	li	a7,17
 ecall
     e9c:	00000073          	ecall
 ret
     ea0:	8082                	ret

0000000000000ea2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     ea2:	48c9                	li	a7,18
 ecall
     ea4:	00000073          	ecall
 ret
     ea8:	8082                	ret

0000000000000eaa <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     eaa:	48a1                	li	a7,8
 ecall
     eac:	00000073          	ecall
 ret
     eb0:	8082                	ret

0000000000000eb2 <link>:
.global link
link:
 li a7, SYS_link
     eb2:	48cd                	li	a7,19
 ecall
     eb4:	00000073          	ecall
 ret
     eb8:	8082                	ret

0000000000000eba <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     eba:	48d1                	li	a7,20
 ecall
     ebc:	00000073          	ecall
 ret
     ec0:	8082                	ret

0000000000000ec2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     ec2:	48a5                	li	a7,9
 ecall
     ec4:	00000073          	ecall
 ret
     ec8:	8082                	ret

0000000000000eca <dup>:
.global dup
dup:
 li a7, SYS_dup
     eca:	48a9                	li	a7,10
 ecall
     ecc:	00000073          	ecall
 ret
     ed0:	8082                	ret

0000000000000ed2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     ed2:	48ad                	li	a7,11
 ecall
     ed4:	00000073          	ecall
 ret
     ed8:	8082                	ret

0000000000000eda <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     eda:	48b1                	li	a7,12
 ecall
     edc:	00000073          	ecall
 ret
     ee0:	8082                	ret

0000000000000ee2 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     ee2:	48b5                	li	a7,13
 ecall
     ee4:	00000073          	ecall
 ret
     ee8:	8082                	ret

0000000000000eea <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     eea:	48b9                	li	a7,14
 ecall
     eec:	00000073          	ecall
 ret
     ef0:	8082                	ret

0000000000000ef2 <memsize>:
.global memsize
memsize:
 li a7, SYS_memsize
     ef2:	48d9                	li	a7,22
 ecall
     ef4:	00000073          	ecall
 ret
     ef8:	8082                	ret

0000000000000efa <set_ps_priority>:
.global set_ps_priority
set_ps_priority:
 li a7, SYS_set_ps_priority
     efa:	48dd                	li	a7,23
 ecall
     efc:	00000073          	ecall
 ret
     f00:	8082                	ret

0000000000000f02 <set_cfs_priority>:
.global set_cfs_priority
set_cfs_priority:
 li a7, SYS_set_cfs_priority
     f02:	48e1                	li	a7,24
 ecall
     f04:	00000073          	ecall
 ret
     f08:	8082                	ret

0000000000000f0a <get_cfs_stats>:
.global get_cfs_stats
get_cfs_stats:
 li a7, SYS_get_cfs_stats
     f0a:	48e5                	li	a7,25
 ecall
     f0c:	00000073          	ecall
 ret
     f10:	8082                	ret

0000000000000f12 <set_policy>:
.global set_policy
set_policy:
 li a7, SYS_set_policy
     f12:	48e9                	li	a7,26
 ecall
     f14:	00000073          	ecall
 ret
     f18:	8082                	ret

0000000000000f1a <get_ps_priority>:
.global get_ps_priority
get_ps_priority:
 li a7, SYS_get_ps_priority
     f1a:	48ed                	li	a7,27
 ecall
     f1c:	00000073          	ecall
 ret
     f20:	8082                	ret

0000000000000f22 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     f22:	1101                	addi	sp,sp,-32
     f24:	ec06                	sd	ra,24(sp)
     f26:	e822                	sd	s0,16(sp)
     f28:	1000                	addi	s0,sp,32
     f2a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     f2e:	4605                	li	a2,1
     f30:	fef40593          	addi	a1,s0,-17
     f34:	00000097          	auipc	ra,0x0
     f38:	f3e080e7          	jalr	-194(ra) # e72 <write>
}
     f3c:	60e2                	ld	ra,24(sp)
     f3e:	6442                	ld	s0,16(sp)
     f40:	6105                	addi	sp,sp,32
     f42:	8082                	ret

0000000000000f44 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     f44:	7139                	addi	sp,sp,-64
     f46:	fc06                	sd	ra,56(sp)
     f48:	f822                	sd	s0,48(sp)
     f4a:	f426                	sd	s1,40(sp)
     f4c:	f04a                	sd	s2,32(sp)
     f4e:	ec4e                	sd	s3,24(sp)
     f50:	0080                	addi	s0,sp,64
     f52:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     f54:	c299                	beqz	a3,f5a <printint+0x16>
     f56:	0805c863          	bltz	a1,fe6 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     f5a:	2581                	sext.w	a1,a1
  neg = 0;
     f5c:	4881                	li	a7,0
     f5e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     f62:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     f64:	2601                	sext.w	a2,a2
     f66:	00000517          	auipc	a0,0x0
     f6a:	5b250513          	addi	a0,a0,1458 # 1518 <digits>
     f6e:	883a                	mv	a6,a4
     f70:	2705                	addiw	a4,a4,1
     f72:	02c5f7bb          	remuw	a5,a1,a2
     f76:	1782                	slli	a5,a5,0x20
     f78:	9381                	srli	a5,a5,0x20
     f7a:	97aa                	add	a5,a5,a0
     f7c:	0007c783          	lbu	a5,0(a5)
     f80:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     f84:	0005879b          	sext.w	a5,a1
     f88:	02c5d5bb          	divuw	a1,a1,a2
     f8c:	0685                	addi	a3,a3,1
     f8e:	fec7f0e3          	bgeu	a5,a2,f6e <printint+0x2a>
  if(neg)
     f92:	00088b63          	beqz	a7,fa8 <printint+0x64>
    buf[i++] = '-';
     f96:	fd040793          	addi	a5,s0,-48
     f9a:	973e                	add	a4,a4,a5
     f9c:	02d00793          	li	a5,45
     fa0:	fef70823          	sb	a5,-16(a4)
     fa4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     fa8:	02e05863          	blez	a4,fd8 <printint+0x94>
     fac:	fc040793          	addi	a5,s0,-64
     fb0:	00e78933          	add	s2,a5,a4
     fb4:	fff78993          	addi	s3,a5,-1
     fb8:	99ba                	add	s3,s3,a4
     fba:	377d                	addiw	a4,a4,-1
     fbc:	1702                	slli	a4,a4,0x20
     fbe:	9301                	srli	a4,a4,0x20
     fc0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     fc4:	fff94583          	lbu	a1,-1(s2)
     fc8:	8526                	mv	a0,s1
     fca:	00000097          	auipc	ra,0x0
     fce:	f58080e7          	jalr	-168(ra) # f22 <putc>
  while(--i >= 0)
     fd2:	197d                	addi	s2,s2,-1
     fd4:	ff3918e3          	bne	s2,s3,fc4 <printint+0x80>
}
     fd8:	70e2                	ld	ra,56(sp)
     fda:	7442                	ld	s0,48(sp)
     fdc:	74a2                	ld	s1,40(sp)
     fde:	7902                	ld	s2,32(sp)
     fe0:	69e2                	ld	s3,24(sp)
     fe2:	6121                	addi	sp,sp,64
     fe4:	8082                	ret
    x = -xx;
     fe6:	40b005bb          	negw	a1,a1
    neg = 1;
     fea:	4885                	li	a7,1
    x = -xx;
     fec:	bf8d                	j	f5e <printint+0x1a>

0000000000000fee <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     fee:	7119                	addi	sp,sp,-128
     ff0:	fc86                	sd	ra,120(sp)
     ff2:	f8a2                	sd	s0,112(sp)
     ff4:	f4a6                	sd	s1,104(sp)
     ff6:	f0ca                	sd	s2,96(sp)
     ff8:	ecce                	sd	s3,88(sp)
     ffa:	e8d2                	sd	s4,80(sp)
     ffc:	e4d6                	sd	s5,72(sp)
     ffe:	e0da                	sd	s6,64(sp)
    1000:	fc5e                	sd	s7,56(sp)
    1002:	f862                	sd	s8,48(sp)
    1004:	f466                	sd	s9,40(sp)
    1006:	f06a                	sd	s10,32(sp)
    1008:	ec6e                	sd	s11,24(sp)
    100a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    100c:	0005c903          	lbu	s2,0(a1)
    1010:	18090f63          	beqz	s2,11ae <vprintf+0x1c0>
    1014:	8aaa                	mv	s5,a0
    1016:	8b32                	mv	s6,a2
    1018:	00158493          	addi	s1,a1,1
  state = 0;
    101c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    101e:	02500a13          	li	s4,37
      if(c == 'd'){
    1022:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    1026:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    102a:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    102e:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1032:	00000b97          	auipc	s7,0x0
    1036:	4e6b8b93          	addi	s7,s7,1254 # 1518 <digits>
    103a:	a839                	j	1058 <vprintf+0x6a>
        putc(fd, c);
    103c:	85ca                	mv	a1,s2
    103e:	8556                	mv	a0,s5
    1040:	00000097          	auipc	ra,0x0
    1044:	ee2080e7          	jalr	-286(ra) # f22 <putc>
    1048:	a019                	j	104e <vprintf+0x60>
    } else if(state == '%'){
    104a:	01498f63          	beq	s3,s4,1068 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    104e:	0485                	addi	s1,s1,1
    1050:	fff4c903          	lbu	s2,-1(s1)
    1054:	14090d63          	beqz	s2,11ae <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    1058:	0009079b          	sext.w	a5,s2
    if(state == 0){
    105c:	fe0997e3          	bnez	s3,104a <vprintf+0x5c>
      if(c == '%'){
    1060:	fd479ee3          	bne	a5,s4,103c <vprintf+0x4e>
        state = '%';
    1064:	89be                	mv	s3,a5
    1066:	b7e5                	j	104e <vprintf+0x60>
      if(c == 'd'){
    1068:	05878063          	beq	a5,s8,10a8 <vprintf+0xba>
      } else if(c == 'l') {
    106c:	05978c63          	beq	a5,s9,10c4 <vprintf+0xd6>
      } else if(c == 'x') {
    1070:	07a78863          	beq	a5,s10,10e0 <vprintf+0xf2>
      } else if(c == 'p') {
    1074:	09b78463          	beq	a5,s11,10fc <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    1078:	07300713          	li	a4,115
    107c:	0ce78663          	beq	a5,a4,1148 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1080:	06300713          	li	a4,99
    1084:	0ee78e63          	beq	a5,a4,1180 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    1088:	11478863          	beq	a5,s4,1198 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    108c:	85d2                	mv	a1,s4
    108e:	8556                	mv	a0,s5
    1090:	00000097          	auipc	ra,0x0
    1094:	e92080e7          	jalr	-366(ra) # f22 <putc>
        putc(fd, c);
    1098:	85ca                	mv	a1,s2
    109a:	8556                	mv	a0,s5
    109c:	00000097          	auipc	ra,0x0
    10a0:	e86080e7          	jalr	-378(ra) # f22 <putc>
      }
      state = 0;
    10a4:	4981                	li	s3,0
    10a6:	b765                	j	104e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    10a8:	008b0913          	addi	s2,s6,8
    10ac:	4685                	li	a3,1
    10ae:	4629                	li	a2,10
    10b0:	000b2583          	lw	a1,0(s6)
    10b4:	8556                	mv	a0,s5
    10b6:	00000097          	auipc	ra,0x0
    10ba:	e8e080e7          	jalr	-370(ra) # f44 <printint>
    10be:	8b4a                	mv	s6,s2
      state = 0;
    10c0:	4981                	li	s3,0
    10c2:	b771                	j	104e <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    10c4:	008b0913          	addi	s2,s6,8
    10c8:	4681                	li	a3,0
    10ca:	4629                	li	a2,10
    10cc:	000b2583          	lw	a1,0(s6)
    10d0:	8556                	mv	a0,s5
    10d2:	00000097          	auipc	ra,0x0
    10d6:	e72080e7          	jalr	-398(ra) # f44 <printint>
    10da:	8b4a                	mv	s6,s2
      state = 0;
    10dc:	4981                	li	s3,0
    10de:	bf85                	j	104e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    10e0:	008b0913          	addi	s2,s6,8
    10e4:	4681                	li	a3,0
    10e6:	4641                	li	a2,16
    10e8:	000b2583          	lw	a1,0(s6)
    10ec:	8556                	mv	a0,s5
    10ee:	00000097          	auipc	ra,0x0
    10f2:	e56080e7          	jalr	-426(ra) # f44 <printint>
    10f6:	8b4a                	mv	s6,s2
      state = 0;
    10f8:	4981                	li	s3,0
    10fa:	bf91                	j	104e <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    10fc:	008b0793          	addi	a5,s6,8
    1100:	f8f43423          	sd	a5,-120(s0)
    1104:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    1108:	03000593          	li	a1,48
    110c:	8556                	mv	a0,s5
    110e:	00000097          	auipc	ra,0x0
    1112:	e14080e7          	jalr	-492(ra) # f22 <putc>
  putc(fd, 'x');
    1116:	85ea                	mv	a1,s10
    1118:	8556                	mv	a0,s5
    111a:	00000097          	auipc	ra,0x0
    111e:	e08080e7          	jalr	-504(ra) # f22 <putc>
    1122:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1124:	03c9d793          	srli	a5,s3,0x3c
    1128:	97de                	add	a5,a5,s7
    112a:	0007c583          	lbu	a1,0(a5)
    112e:	8556                	mv	a0,s5
    1130:	00000097          	auipc	ra,0x0
    1134:	df2080e7          	jalr	-526(ra) # f22 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    1138:	0992                	slli	s3,s3,0x4
    113a:	397d                	addiw	s2,s2,-1
    113c:	fe0914e3          	bnez	s2,1124 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    1140:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    1144:	4981                	li	s3,0
    1146:	b721                	j	104e <vprintf+0x60>
        s = va_arg(ap, char*);
    1148:	008b0993          	addi	s3,s6,8
    114c:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    1150:	02090163          	beqz	s2,1172 <vprintf+0x184>
        while(*s != 0){
    1154:	00094583          	lbu	a1,0(s2)
    1158:	c9a1                	beqz	a1,11a8 <vprintf+0x1ba>
          putc(fd, *s);
    115a:	8556                	mv	a0,s5
    115c:	00000097          	auipc	ra,0x0
    1160:	dc6080e7          	jalr	-570(ra) # f22 <putc>
          s++;
    1164:	0905                	addi	s2,s2,1
        while(*s != 0){
    1166:	00094583          	lbu	a1,0(s2)
    116a:	f9e5                	bnez	a1,115a <vprintf+0x16c>
        s = va_arg(ap, char*);
    116c:	8b4e                	mv	s6,s3
      state = 0;
    116e:	4981                	li	s3,0
    1170:	bdf9                	j	104e <vprintf+0x60>
          s = "(null)";
    1172:	00000917          	auipc	s2,0x0
    1176:	39e90913          	addi	s2,s2,926 # 1510 <malloc+0x258>
        while(*s != 0){
    117a:	02800593          	li	a1,40
    117e:	bff1                	j	115a <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    1180:	008b0913          	addi	s2,s6,8
    1184:	000b4583          	lbu	a1,0(s6)
    1188:	8556                	mv	a0,s5
    118a:	00000097          	auipc	ra,0x0
    118e:	d98080e7          	jalr	-616(ra) # f22 <putc>
    1192:	8b4a                	mv	s6,s2
      state = 0;
    1194:	4981                	li	s3,0
    1196:	bd65                	j	104e <vprintf+0x60>
        putc(fd, c);
    1198:	85d2                	mv	a1,s4
    119a:	8556                	mv	a0,s5
    119c:	00000097          	auipc	ra,0x0
    11a0:	d86080e7          	jalr	-634(ra) # f22 <putc>
      state = 0;
    11a4:	4981                	li	s3,0
    11a6:	b565                	j	104e <vprintf+0x60>
        s = va_arg(ap, char*);
    11a8:	8b4e                	mv	s6,s3
      state = 0;
    11aa:	4981                	li	s3,0
    11ac:	b54d                	j	104e <vprintf+0x60>
    }
  }
}
    11ae:	70e6                	ld	ra,120(sp)
    11b0:	7446                	ld	s0,112(sp)
    11b2:	74a6                	ld	s1,104(sp)
    11b4:	7906                	ld	s2,96(sp)
    11b6:	69e6                	ld	s3,88(sp)
    11b8:	6a46                	ld	s4,80(sp)
    11ba:	6aa6                	ld	s5,72(sp)
    11bc:	6b06                	ld	s6,64(sp)
    11be:	7be2                	ld	s7,56(sp)
    11c0:	7c42                	ld	s8,48(sp)
    11c2:	7ca2                	ld	s9,40(sp)
    11c4:	7d02                	ld	s10,32(sp)
    11c6:	6de2                	ld	s11,24(sp)
    11c8:	6109                	addi	sp,sp,128
    11ca:	8082                	ret

00000000000011cc <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    11cc:	715d                	addi	sp,sp,-80
    11ce:	ec06                	sd	ra,24(sp)
    11d0:	e822                	sd	s0,16(sp)
    11d2:	1000                	addi	s0,sp,32
    11d4:	e010                	sd	a2,0(s0)
    11d6:	e414                	sd	a3,8(s0)
    11d8:	e818                	sd	a4,16(s0)
    11da:	ec1c                	sd	a5,24(s0)
    11dc:	03043023          	sd	a6,32(s0)
    11e0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    11e4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    11e8:	8622                	mv	a2,s0
    11ea:	00000097          	auipc	ra,0x0
    11ee:	e04080e7          	jalr	-508(ra) # fee <vprintf>
}
    11f2:	60e2                	ld	ra,24(sp)
    11f4:	6442                	ld	s0,16(sp)
    11f6:	6161                	addi	sp,sp,80
    11f8:	8082                	ret

00000000000011fa <printf>:

void
printf(const char *fmt, ...)
{
    11fa:	711d                	addi	sp,sp,-96
    11fc:	ec06                	sd	ra,24(sp)
    11fe:	e822                	sd	s0,16(sp)
    1200:	1000                	addi	s0,sp,32
    1202:	e40c                	sd	a1,8(s0)
    1204:	e810                	sd	a2,16(s0)
    1206:	ec14                	sd	a3,24(s0)
    1208:	f018                	sd	a4,32(s0)
    120a:	f41c                	sd	a5,40(s0)
    120c:	03043823          	sd	a6,48(s0)
    1210:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    1214:	00840613          	addi	a2,s0,8
    1218:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    121c:	85aa                	mv	a1,a0
    121e:	4505                	li	a0,1
    1220:	00000097          	auipc	ra,0x0
    1224:	dce080e7          	jalr	-562(ra) # fee <vprintf>
}
    1228:	60e2                	ld	ra,24(sp)
    122a:	6442                	ld	s0,16(sp)
    122c:	6125                	addi	sp,sp,96
    122e:	8082                	ret

0000000000001230 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1230:	1141                	addi	sp,sp,-16
    1232:	e422                	sd	s0,8(sp)
    1234:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1236:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    123a:	00001797          	auipc	a5,0x1
    123e:	dd67b783          	ld	a5,-554(a5) # 2010 <freep>
    1242:	a805                	j	1272 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    1244:	4618                	lw	a4,8(a2)
    1246:	9db9                	addw	a1,a1,a4
    1248:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    124c:	6398                	ld	a4,0(a5)
    124e:	6318                	ld	a4,0(a4)
    1250:	fee53823          	sd	a4,-16(a0)
    1254:	a091                	j	1298 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    1256:	ff852703          	lw	a4,-8(a0)
    125a:	9e39                	addw	a2,a2,a4
    125c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    125e:	ff053703          	ld	a4,-16(a0)
    1262:	e398                	sd	a4,0(a5)
    1264:	a099                	j	12aa <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1266:	6398                	ld	a4,0(a5)
    1268:	00e7e463          	bltu	a5,a4,1270 <free+0x40>
    126c:	00e6ea63          	bltu	a3,a4,1280 <free+0x50>
{
    1270:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1272:	fed7fae3          	bgeu	a5,a3,1266 <free+0x36>
    1276:	6398                	ld	a4,0(a5)
    1278:	00e6e463          	bltu	a3,a4,1280 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    127c:	fee7eae3          	bltu	a5,a4,1270 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    1280:	ff852583          	lw	a1,-8(a0)
    1284:	6390                	ld	a2,0(a5)
    1286:	02059713          	slli	a4,a1,0x20
    128a:	9301                	srli	a4,a4,0x20
    128c:	0712                	slli	a4,a4,0x4
    128e:	9736                	add	a4,a4,a3
    1290:	fae60ae3          	beq	a2,a4,1244 <free+0x14>
    bp->s.ptr = p->s.ptr;
    1294:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    1298:	4790                	lw	a2,8(a5)
    129a:	02061713          	slli	a4,a2,0x20
    129e:	9301                	srli	a4,a4,0x20
    12a0:	0712                	slli	a4,a4,0x4
    12a2:	973e                	add	a4,a4,a5
    12a4:	fae689e3          	beq	a3,a4,1256 <free+0x26>
  } else
    p->s.ptr = bp;
    12a8:	e394                	sd	a3,0(a5)
  freep = p;
    12aa:	00001717          	auipc	a4,0x1
    12ae:	d6f73323          	sd	a5,-666(a4) # 2010 <freep>
}
    12b2:	6422                	ld	s0,8(sp)
    12b4:	0141                	addi	sp,sp,16
    12b6:	8082                	ret

00000000000012b8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    12b8:	7139                	addi	sp,sp,-64
    12ba:	fc06                	sd	ra,56(sp)
    12bc:	f822                	sd	s0,48(sp)
    12be:	f426                	sd	s1,40(sp)
    12c0:	f04a                	sd	s2,32(sp)
    12c2:	ec4e                	sd	s3,24(sp)
    12c4:	e852                	sd	s4,16(sp)
    12c6:	e456                	sd	s5,8(sp)
    12c8:	e05a                	sd	s6,0(sp)
    12ca:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    12cc:	02051493          	slli	s1,a0,0x20
    12d0:	9081                	srli	s1,s1,0x20
    12d2:	04bd                	addi	s1,s1,15
    12d4:	8091                	srli	s1,s1,0x4
    12d6:	0014899b          	addiw	s3,s1,1
    12da:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    12dc:	00001517          	auipc	a0,0x1
    12e0:	d3453503          	ld	a0,-716(a0) # 2010 <freep>
    12e4:	c515                	beqz	a0,1310 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    12e6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    12e8:	4798                	lw	a4,8(a5)
    12ea:	02977f63          	bgeu	a4,s1,1328 <malloc+0x70>
    12ee:	8a4e                	mv	s4,s3
    12f0:	0009871b          	sext.w	a4,s3
    12f4:	6685                	lui	a3,0x1
    12f6:	00d77363          	bgeu	a4,a3,12fc <malloc+0x44>
    12fa:	6a05                	lui	s4,0x1
    12fc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    1300:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    1304:	00001917          	auipc	s2,0x1
    1308:	d0c90913          	addi	s2,s2,-756 # 2010 <freep>
  if(p == (char*)-1)
    130c:	5afd                	li	s5,-1
    130e:	a88d                	j	1380 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    1310:	00001797          	auipc	a5,0x1
    1314:	d7878793          	addi	a5,a5,-648 # 2088 <base>
    1318:	00001717          	auipc	a4,0x1
    131c:	cef73c23          	sd	a5,-776(a4) # 2010 <freep>
    1320:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    1322:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    1326:	b7e1                	j	12ee <malloc+0x36>
      if(p->s.size == nunits)
    1328:	02e48b63          	beq	s1,a4,135e <malloc+0xa6>
        p->s.size -= nunits;
    132c:	4137073b          	subw	a4,a4,s3
    1330:	c798                	sw	a4,8(a5)
        p += p->s.size;
    1332:	1702                	slli	a4,a4,0x20
    1334:	9301                	srli	a4,a4,0x20
    1336:	0712                	slli	a4,a4,0x4
    1338:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    133a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    133e:	00001717          	auipc	a4,0x1
    1342:	cca73923          	sd	a0,-814(a4) # 2010 <freep>
      return (void*)(p + 1);
    1346:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    134a:	70e2                	ld	ra,56(sp)
    134c:	7442                	ld	s0,48(sp)
    134e:	74a2                	ld	s1,40(sp)
    1350:	7902                	ld	s2,32(sp)
    1352:	69e2                	ld	s3,24(sp)
    1354:	6a42                	ld	s4,16(sp)
    1356:	6aa2                	ld	s5,8(sp)
    1358:	6b02                	ld	s6,0(sp)
    135a:	6121                	addi	sp,sp,64
    135c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    135e:	6398                	ld	a4,0(a5)
    1360:	e118                	sd	a4,0(a0)
    1362:	bff1                	j	133e <malloc+0x86>
  hp->s.size = nu;
    1364:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    1368:	0541                	addi	a0,a0,16
    136a:	00000097          	auipc	ra,0x0
    136e:	ec6080e7          	jalr	-314(ra) # 1230 <free>
  return freep;
    1372:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    1376:	d971                	beqz	a0,134a <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1378:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    137a:	4798                	lw	a4,8(a5)
    137c:	fa9776e3          	bgeu	a4,s1,1328 <malloc+0x70>
    if(p == freep)
    1380:	00093703          	ld	a4,0(s2)
    1384:	853e                	mv	a0,a5
    1386:	fef719e3          	bne	a4,a5,1378 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    138a:	8552                	mv	a0,s4
    138c:	00000097          	auipc	ra,0x0
    1390:	b4e080e7          	jalr	-1202(ra) # eda <sbrk>
  if(p == (char*)-1)
    1394:	fd5518e3          	bne	a0,s5,1364 <malloc+0xac>
        return 0;
    1398:	4501                	li	a0,0
    139a:	bf45                	j	134a <malloc+0x92>
