
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8c013103          	ld	sp,-1856(sp) # 800088c0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	8ce70713          	addi	a4,a4,-1842 # 80008920 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	19c78793          	addi	a5,a5,412 # 80006200 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdba6f>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	dca78793          	addi	a5,a5,-566 # 80000e78 <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	715d                	addi	sp,sp,-80
    80000104:	e486                	sd	ra,72(sp)
    80000106:	e0a2                	sd	s0,64(sp)
    80000108:	fc26                	sd	s1,56(sp)
    8000010a:	f84a                	sd	s2,48(sp)
    8000010c:	f44e                	sd	s3,40(sp)
    8000010e:	f052                	sd	s4,32(sp)
    80000110:	ec56                	sd	s5,24(sp)
    80000112:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000114:	04c05663          	blez	a2,80000160 <consolewrite+0x5e>
    80000118:	8a2a                	mv	s4,a0
    8000011a:	84ae                	mv	s1,a1
    8000011c:	89b2                	mv	s3,a2
    8000011e:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000120:	5afd                	li	s5,-1
    80000122:	4685                	li	a3,1
    80000124:	8626                	mv	a2,s1
    80000126:	85d2                	mv	a1,s4
    80000128:	fbf40513          	addi	a0,s0,-65
    8000012c:	00002097          	auipc	ra,0x2
    80000130:	6ec080e7          	jalr	1772(ra) # 80002818 <either_copyin>
    80000134:	01550c63          	beq	a0,s5,8000014c <consolewrite+0x4a>
      break;
    uartputc(c);
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00000097          	auipc	ra,0x0
    80000140:	780080e7          	jalr	1920(ra) # 800008bc <uartputc>
  for(i = 0; i < n; i++){
    80000144:	2905                	addiw	s2,s2,1
    80000146:	0485                	addi	s1,s1,1
    80000148:	fd299de3          	bne	s3,s2,80000122 <consolewrite+0x20>
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4a>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	8d650513          	addi	a0,a0,-1834 # 80010a60 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	8c648493          	addi	s1,s1,-1850 # 80010a60 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	95690913          	addi	s2,s2,-1706 # 80010af8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ae:	4ca9                	li	s9,10
  while(n > 0){
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
    while(cons.r == cons.w){
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
      if(killed(myproc())){
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	820080e7          	jalr	-2016(ra) # 800019e0 <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	458080e7          	jalr	1112(ra) # 80002620 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	0f6080e7          	jalr	246(ra) # 800022cc <sleep>
    while(cons.r == cons.w){
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
    cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	5b0080e7          	jalr	1456(ra) # 800027c2 <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	83a50513          	addi	a0,a0,-1990 # 80010a60 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	82450513          	addi	a0,a0,-2012 # 80010a60 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	a46080e7          	jalr	-1466(ra) # 80000c8a <release>
        return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
      if(n < target){
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	88f72323          	sw	a5,-1914(a4) # 80010af8 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	55e080e7          	jalr	1374(ra) # 800007ea <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	54c080e7          	jalr	1356(ra) # 800007ea <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	540080e7          	jalr	1344(ra) # 800007ea <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	536080e7          	jalr	1334(ra) # 800007ea <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00010517          	auipc	a0,0x10
    800002d0:	79450513          	addi	a0,a0,1940 # 80010a60 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	902080e7          	jalr	-1790(ra) # 80000bd6 <acquire>

  switch(c){
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	61e080e7          	jalr	1566(ra) # 80002910 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	76650513          	addi	a0,a0,1894 # 80010a60 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	988080e7          	jalr	-1656(ra) # 80000c8a <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch(c){
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031e:	00010717          	auipc	a4,0x10
    80000322:	74270713          	addi	a4,a4,1858 # 80010a60 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00010797          	auipc	a5,0x10
    8000034c:	71878793          	addi	a5,a5,1816 # 80010a60 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00010797          	auipc	a5,0x10
    8000037a:	7827a783          	lw	a5,1922(a5) # 80010af8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	6d670713          	addi	a4,a4,1750 # 80010a60 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	6c648493          	addi	s1,s1,1734 # 80010a60 <cons>
    while(cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while(cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d6:	00010717          	auipc	a4,0x10
    800003da:	68a70713          	addi	a4,a4,1674 # 80010a60 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	70f72a23          	sw	a5,1812(a4) # 80010b00 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00010797          	auipc	a5,0x10
    80000416:	64e78793          	addi	a5,a5,1614 # 80010a60 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00010797          	auipc	a5,0x10
    8000043a:	6cc7a323          	sw	a2,1734(a5) # 80010afc <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	6ba50513          	addi	a0,a0,1722 # 80010af8 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	f6e080e7          	jalr	-146(ra) # 800023b4 <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void
consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00010517          	auipc	a0,0x10
    80000464:	60050513          	addi	a0,a0,1536 # 80010a60 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32a080e7          	jalr	810(ra) # 8000079a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00021797          	auipc	a5,0x21
    8000047c:	78078793          	addi	a5,a5,1920 # 80021bf8 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7870713          	addi	a4,a4,-904 # 80000102 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054663          	bltz	a0,80000536 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088b63          	beqz	a7,800004fc <printint+0x60>
    buf[i++] = '-';
    800004ea:	fe040793          	addi	a5,s0,-32
    800004ee:	973e                	add	a4,a4,a5
    800004f0:	02d00793          	li	a5,45
    800004f4:	fef70823          	sb	a5,-16(a4)
    800004f8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fc:	02e05763          	blez	a4,8000052a <printint+0x8e>
    80000500:	fd040793          	addi	a5,s0,-48
    80000504:	00e784b3          	add	s1,a5,a4
    80000508:	fff78913          	addi	s2,a5,-1
    8000050c:	993a                	add	s2,s2,a4
    8000050e:	377d                	addiw	a4,a4,-1
    80000510:	1702                	slli	a4,a4,0x20
    80000512:	9301                	srli	a4,a4,0x20
    80000514:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000518:	fff4c503          	lbu	a0,-1(s1)
    8000051c:	00000097          	auipc	ra,0x0
    80000520:	d60080e7          	jalr	-672(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000524:	14fd                	addi	s1,s1,-1
    80000526:	ff2499e3          	bne	s1,s2,80000518 <printint+0x7c>
}
    8000052a:	70a2                	ld	ra,40(sp)
    8000052c:	7402                	ld	s0,32(sp)
    8000052e:	64e2                	ld	s1,24(sp)
    80000530:	6942                	ld	s2,16(sp)
    80000532:	6145                	addi	sp,sp,48
    80000534:	8082                	ret
    x = -xx;
    80000536:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053a:	4885                	li	a7,1
    x = -xx;
    8000053c:	bf9d                	j	800004b2 <printint+0x16>

000000008000053e <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053e:	1101                	addi	sp,sp,-32
    80000540:	ec06                	sd	ra,24(sp)
    80000542:	e822                	sd	s0,16(sp)
    80000544:	e426                	sd	s1,8(sp)
    80000546:	1000                	addi	s0,sp,32
    80000548:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054a:	00010797          	auipc	a5,0x10
    8000054e:	5c07ab23          	sw	zero,1494(a5) # 80010b20 <pr+0x18>
  printf("panic: ");
    80000552:	00008517          	auipc	a0,0x8
    80000556:	ac650513          	addi	a0,a0,-1338 # 80008018 <etext+0x18>
    8000055a:	00000097          	auipc	ra,0x0
    8000055e:	02e080e7          	jalr	46(ra) # 80000588 <printf>
  printf(s);
    80000562:	8526                	mv	a0,s1
    80000564:	00000097          	auipc	ra,0x0
    80000568:	024080e7          	jalr	36(ra) # 80000588 <printf>
  printf("\n");
    8000056c:	00008517          	auipc	a0,0x8
    80000570:	b5c50513          	addi	a0,a0,-1188 # 800080c8 <digits+0x88>
    80000574:	00000097          	auipc	ra,0x0
    80000578:	014080e7          	jalr	20(ra) # 80000588 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057c:	4785                	li	a5,1
    8000057e:	00008717          	auipc	a4,0x8
    80000582:	36f72123          	sw	a5,866(a4) # 800088e0 <panicked>
  for(;;)
    80000586:	a001                	j	80000586 <panic+0x48>

0000000080000588 <printf>:
{
    80000588:	7131                	addi	sp,sp,-192
    8000058a:	fc86                	sd	ra,120(sp)
    8000058c:	f8a2                	sd	s0,112(sp)
    8000058e:	f4a6                	sd	s1,104(sp)
    80000590:	f0ca                	sd	s2,96(sp)
    80000592:	ecce                	sd	s3,88(sp)
    80000594:	e8d2                	sd	s4,80(sp)
    80000596:	e4d6                	sd	s5,72(sp)
    80000598:	e0da                	sd	s6,64(sp)
    8000059a:	fc5e                	sd	s7,56(sp)
    8000059c:	f862                	sd	s8,48(sp)
    8000059e:	f466                	sd	s9,40(sp)
    800005a0:	f06a                	sd	s10,32(sp)
    800005a2:	ec6e                	sd	s11,24(sp)
    800005a4:	0100                	addi	s0,sp,128
    800005a6:	8a2a                	mv	s4,a0
    800005a8:	e40c                	sd	a1,8(s0)
    800005aa:	e810                	sd	a2,16(s0)
    800005ac:	ec14                	sd	a3,24(s0)
    800005ae:	f018                	sd	a4,32(s0)
    800005b0:	f41c                	sd	a5,40(s0)
    800005b2:	03043823          	sd	a6,48(s0)
    800005b6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ba:	00010d97          	auipc	s11,0x10
    800005be:	566dad83          	lw	s11,1382(s11) # 80010b20 <pr+0x18>
  if(locking)
    800005c2:	020d9b63          	bnez	s11,800005f8 <printf+0x70>
  if (fmt == 0)
    800005c6:	040a0263          	beqz	s4,8000060a <printf+0x82>
  va_start(ap, fmt);
    800005ca:	00840793          	addi	a5,s0,8
    800005ce:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d2:	000a4503          	lbu	a0,0(s4)
    800005d6:	14050f63          	beqz	a0,80000734 <printf+0x1ac>
    800005da:	4981                	li	s3,0
    if(c != '%'){
    800005dc:	02500a93          	li	s5,37
    switch(c){
    800005e0:	07000b93          	li	s7,112
  consputc('x');
    800005e4:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e6:	00008b17          	auipc	s6,0x8
    800005ea:	a5ab0b13          	addi	s6,s6,-1446 # 80008040 <digits>
    switch(c){
    800005ee:	07300c93          	li	s9,115
    800005f2:	06400c13          	li	s8,100
    800005f6:	a82d                	j	80000630 <printf+0xa8>
    acquire(&pr.lock);
    800005f8:	00010517          	auipc	a0,0x10
    800005fc:	51050513          	addi	a0,a0,1296 # 80010b08 <pr>
    80000600:	00000097          	auipc	ra,0x0
    80000604:	5d6080e7          	jalr	1494(ra) # 80000bd6 <acquire>
    80000608:	bf7d                	j	800005c6 <printf+0x3e>
    panic("null fmt");
    8000060a:	00008517          	auipc	a0,0x8
    8000060e:	a1e50513          	addi	a0,a0,-1506 # 80008028 <etext+0x28>
    80000612:	00000097          	auipc	ra,0x0
    80000616:	f2c080e7          	jalr	-212(ra) # 8000053e <panic>
      consputc(c);
    8000061a:	00000097          	auipc	ra,0x0
    8000061e:	c62080e7          	jalr	-926(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000622:	2985                	addiw	s3,s3,1
    80000624:	013a07b3          	add	a5,s4,s3
    80000628:	0007c503          	lbu	a0,0(a5)
    8000062c:	10050463          	beqz	a0,80000734 <printf+0x1ac>
    if(c != '%'){
    80000630:	ff5515e3          	bne	a0,s5,8000061a <printf+0x92>
    c = fmt[++i] & 0xff;
    80000634:	2985                	addiw	s3,s3,1
    80000636:	013a07b3          	add	a5,s4,s3
    8000063a:	0007c783          	lbu	a5,0(a5)
    8000063e:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000642:	cbed                	beqz	a5,80000734 <printf+0x1ac>
    switch(c){
    80000644:	05778a63          	beq	a5,s7,80000698 <printf+0x110>
    80000648:	02fbf663          	bgeu	s7,a5,80000674 <printf+0xec>
    8000064c:	09978863          	beq	a5,s9,800006dc <printf+0x154>
    80000650:	07800713          	li	a4,120
    80000654:	0ce79563          	bne	a5,a4,8000071e <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000658:	f8843783          	ld	a5,-120(s0)
    8000065c:	00878713          	addi	a4,a5,8
    80000660:	f8e43423          	sd	a4,-120(s0)
    80000664:	4605                	li	a2,1
    80000666:	85ea                	mv	a1,s10
    80000668:	4388                	lw	a0,0(a5)
    8000066a:	00000097          	auipc	ra,0x0
    8000066e:	e32080e7          	jalr	-462(ra) # 8000049c <printint>
      break;
    80000672:	bf45                	j	80000622 <printf+0x9a>
    switch(c){
    80000674:	09578f63          	beq	a5,s5,80000712 <printf+0x18a>
    80000678:	0b879363          	bne	a5,s8,8000071e <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4605                	li	a2,1
    8000068a:	45a9                	li	a1,10
    8000068c:	4388                	lw	a0,0(a5)
    8000068e:	00000097          	auipc	ra,0x0
    80000692:	e0e080e7          	jalr	-498(ra) # 8000049c <printint>
      break;
    80000696:	b771                	j	80000622 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000698:	f8843783          	ld	a5,-120(s0)
    8000069c:	00878713          	addi	a4,a5,8
    800006a0:	f8e43423          	sd	a4,-120(s0)
    800006a4:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a8:	03000513          	li	a0,48
    800006ac:	00000097          	auipc	ra,0x0
    800006b0:	bd0080e7          	jalr	-1072(ra) # 8000027c <consputc>
  consputc('x');
    800006b4:	07800513          	li	a0,120
    800006b8:	00000097          	auipc	ra,0x0
    800006bc:	bc4080e7          	jalr	-1084(ra) # 8000027c <consputc>
    800006c0:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c2:	03c95793          	srli	a5,s2,0x3c
    800006c6:	97da                	add	a5,a5,s6
    800006c8:	0007c503          	lbu	a0,0(a5)
    800006cc:	00000097          	auipc	ra,0x0
    800006d0:	bb0080e7          	jalr	-1104(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d4:	0912                	slli	s2,s2,0x4
    800006d6:	34fd                	addiw	s1,s1,-1
    800006d8:	f4ed                	bnez	s1,800006c2 <printf+0x13a>
    800006da:	b7a1                	j	80000622 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006dc:	f8843783          	ld	a5,-120(s0)
    800006e0:	00878713          	addi	a4,a5,8
    800006e4:	f8e43423          	sd	a4,-120(s0)
    800006e8:	6384                	ld	s1,0(a5)
    800006ea:	cc89                	beqz	s1,80000704 <printf+0x17c>
      for(; *s; s++)
    800006ec:	0004c503          	lbu	a0,0(s1)
    800006f0:	d90d                	beqz	a0,80000622 <printf+0x9a>
        consputc(*s);
    800006f2:	00000097          	auipc	ra,0x0
    800006f6:	b8a080e7          	jalr	-1142(ra) # 8000027c <consputc>
      for(; *s; s++)
    800006fa:	0485                	addi	s1,s1,1
    800006fc:	0004c503          	lbu	a0,0(s1)
    80000700:	f96d                	bnez	a0,800006f2 <printf+0x16a>
    80000702:	b705                	j	80000622 <printf+0x9a>
        s = "(null)";
    80000704:	00008497          	auipc	s1,0x8
    80000708:	91c48493          	addi	s1,s1,-1764 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070c:	02800513          	li	a0,40
    80000710:	b7cd                	j	800006f2 <printf+0x16a>
      consputc('%');
    80000712:	8556                	mv	a0,s5
    80000714:	00000097          	auipc	ra,0x0
    80000718:	b68080e7          	jalr	-1176(ra) # 8000027c <consputc>
      break;
    8000071c:	b719                	j	80000622 <printf+0x9a>
      consputc('%');
    8000071e:	8556                	mv	a0,s5
    80000720:	00000097          	auipc	ra,0x0
    80000724:	b5c080e7          	jalr	-1188(ra) # 8000027c <consputc>
      consputc(c);
    80000728:	8526                	mv	a0,s1
    8000072a:	00000097          	auipc	ra,0x0
    8000072e:	b52080e7          	jalr	-1198(ra) # 8000027c <consputc>
      break;
    80000732:	bdc5                	j	80000622 <printf+0x9a>
  if(locking)
    80000734:	020d9163          	bnez	s11,80000756 <printf+0x1ce>
}
    80000738:	70e6                	ld	ra,120(sp)
    8000073a:	7446                	ld	s0,112(sp)
    8000073c:	74a6                	ld	s1,104(sp)
    8000073e:	7906                	ld	s2,96(sp)
    80000740:	69e6                	ld	s3,88(sp)
    80000742:	6a46                	ld	s4,80(sp)
    80000744:	6aa6                	ld	s5,72(sp)
    80000746:	6b06                	ld	s6,64(sp)
    80000748:	7be2                	ld	s7,56(sp)
    8000074a:	7c42                	ld	s8,48(sp)
    8000074c:	7ca2                	ld	s9,40(sp)
    8000074e:	7d02                	ld	s10,32(sp)
    80000750:	6de2                	ld	s11,24(sp)
    80000752:	6129                	addi	sp,sp,192
    80000754:	8082                	ret
    release(&pr.lock);
    80000756:	00010517          	auipc	a0,0x10
    8000075a:	3b250513          	addi	a0,a0,946 # 80010b08 <pr>
    8000075e:	00000097          	auipc	ra,0x0
    80000762:	52c080e7          	jalr	1324(ra) # 80000c8a <release>
}
    80000766:	bfc9                	j	80000738 <printf+0x1b0>

0000000080000768 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000768:	1101                	addi	sp,sp,-32
    8000076a:	ec06                	sd	ra,24(sp)
    8000076c:	e822                	sd	s0,16(sp)
    8000076e:	e426                	sd	s1,8(sp)
    80000770:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000772:	00010497          	auipc	s1,0x10
    80000776:	39648493          	addi	s1,s1,918 # 80010b08 <pr>
    8000077a:	00008597          	auipc	a1,0x8
    8000077e:	8be58593          	addi	a1,a1,-1858 # 80008038 <etext+0x38>
    80000782:	8526                	mv	a0,s1
    80000784:	00000097          	auipc	ra,0x0
    80000788:	3c2080e7          	jalr	962(ra) # 80000b46 <initlock>
  pr.locking = 1;
    8000078c:	4785                	li	a5,1
    8000078e:	cc9c                	sw	a5,24(s1)
}
    80000790:	60e2                	ld	ra,24(sp)
    80000792:	6442                	ld	s0,16(sp)
    80000794:	64a2                	ld	s1,8(sp)
    80000796:	6105                	addi	sp,sp,32
    80000798:	8082                	ret

000000008000079a <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079a:	1141                	addi	sp,sp,-16
    8000079c:	e406                	sd	ra,8(sp)
    8000079e:	e022                	sd	s0,0(sp)
    800007a0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a2:	100007b7          	lui	a5,0x10000
    800007a6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007aa:	f8000713          	li	a4,-128
    800007ae:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b2:	470d                	li	a4,3
    800007b4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007bc:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c0:	469d                	li	a3,7
    800007c2:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c6:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007ca:	00008597          	auipc	a1,0x8
    800007ce:	88e58593          	addi	a1,a1,-1906 # 80008058 <digits+0x18>
    800007d2:	00010517          	auipc	a0,0x10
    800007d6:	35650513          	addi	a0,a0,854 # 80010b28 <uart_tx_lock>
    800007da:	00000097          	auipc	ra,0x0
    800007de:	36c080e7          	jalr	876(ra) # 80000b46 <initlock>
}
    800007e2:	60a2                	ld	ra,8(sp)
    800007e4:	6402                	ld	s0,0(sp)
    800007e6:	0141                	addi	sp,sp,16
    800007e8:	8082                	ret

00000000800007ea <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ea:	1101                	addi	sp,sp,-32
    800007ec:	ec06                	sd	ra,24(sp)
    800007ee:	e822                	sd	s0,16(sp)
    800007f0:	e426                	sd	s1,8(sp)
    800007f2:	1000                	addi	s0,sp,32
    800007f4:	84aa                	mv	s1,a0
  push_off();
    800007f6:	00000097          	auipc	ra,0x0
    800007fa:	394080e7          	jalr	916(ra) # 80000b8a <push_off>

  if(panicked){
    800007fe:	00008797          	auipc	a5,0x8
    80000802:	0e27a783          	lw	a5,226(a5) # 800088e0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000806:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080a:	c391                	beqz	a5,8000080e <uartputc_sync+0x24>
    for(;;)
    8000080c:	a001                	j	8000080c <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080e:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000812:	0207f793          	andi	a5,a5,32
    80000816:	dfe5                	beqz	a5,8000080e <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000818:	0ff4f513          	andi	a0,s1,255
    8000081c:	100007b7          	lui	a5,0x10000
    80000820:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000824:	00000097          	auipc	ra,0x0
    80000828:	406080e7          	jalr	1030(ra) # 80000c2a <pop_off>
}
    8000082c:	60e2                	ld	ra,24(sp)
    8000082e:	6442                	ld	s0,16(sp)
    80000830:	64a2                	ld	s1,8(sp)
    80000832:	6105                	addi	sp,sp,32
    80000834:	8082                	ret

0000000080000836 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000836:	00008797          	auipc	a5,0x8
    8000083a:	0b27b783          	ld	a5,178(a5) # 800088e8 <uart_tx_r>
    8000083e:	00008717          	auipc	a4,0x8
    80000842:	0b273703          	ld	a4,178(a4) # 800088f0 <uart_tx_w>
    80000846:	06f70a63          	beq	a4,a5,800008ba <uartstart+0x84>
{
    8000084a:	7139                	addi	sp,sp,-64
    8000084c:	fc06                	sd	ra,56(sp)
    8000084e:	f822                	sd	s0,48(sp)
    80000850:	f426                	sd	s1,40(sp)
    80000852:	f04a                	sd	s2,32(sp)
    80000854:	ec4e                	sd	s3,24(sp)
    80000856:	e852                	sd	s4,16(sp)
    80000858:	e456                	sd	s5,8(sp)
    8000085a:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085c:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000860:	00010a17          	auipc	s4,0x10
    80000864:	2c8a0a13          	addi	s4,s4,712 # 80010b28 <uart_tx_lock>
    uart_tx_r += 1;
    80000868:	00008497          	auipc	s1,0x8
    8000086c:	08048493          	addi	s1,s1,128 # 800088e8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000870:	00008997          	auipc	s3,0x8
    80000874:	08098993          	addi	s3,s3,128 # 800088f0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000878:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087c:	02077713          	andi	a4,a4,32
    80000880:	c705                	beqz	a4,800008a8 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000882:	01f7f713          	andi	a4,a5,31
    80000886:	9752                	add	a4,a4,s4
    80000888:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088c:	0785                	addi	a5,a5,1
    8000088e:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000890:	8526                	mv	a0,s1
    80000892:	00002097          	auipc	ra,0x2
    80000896:	b22080e7          	jalr	-1246(ra) # 800023b4 <wakeup>
    
    WriteReg(THR, c);
    8000089a:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089e:	609c                	ld	a5,0(s1)
    800008a0:	0009b703          	ld	a4,0(s3)
    800008a4:	fcf71ae3          	bne	a4,a5,80000878 <uartstart+0x42>
  }
}
    800008a8:	70e2                	ld	ra,56(sp)
    800008aa:	7442                	ld	s0,48(sp)
    800008ac:	74a2                	ld	s1,40(sp)
    800008ae:	7902                	ld	s2,32(sp)
    800008b0:	69e2                	ld	s3,24(sp)
    800008b2:	6a42                	ld	s4,16(sp)
    800008b4:	6aa2                	ld	s5,8(sp)
    800008b6:	6121                	addi	sp,sp,64
    800008b8:	8082                	ret
    800008ba:	8082                	ret

00000000800008bc <uartputc>:
{
    800008bc:	7179                	addi	sp,sp,-48
    800008be:	f406                	sd	ra,40(sp)
    800008c0:	f022                	sd	s0,32(sp)
    800008c2:	ec26                	sd	s1,24(sp)
    800008c4:	e84a                	sd	s2,16(sp)
    800008c6:	e44e                	sd	s3,8(sp)
    800008c8:	e052                	sd	s4,0(sp)
    800008ca:	1800                	addi	s0,sp,48
    800008cc:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008ce:	00010517          	auipc	a0,0x10
    800008d2:	25a50513          	addi	a0,a0,602 # 80010b28 <uart_tx_lock>
    800008d6:	00000097          	auipc	ra,0x0
    800008da:	300080e7          	jalr	768(ra) # 80000bd6 <acquire>
  if(panicked){
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	0027a783          	lw	a5,2(a5) # 800088e0 <panicked>
    800008e6:	e7c9                	bnez	a5,80000970 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e8:	00008717          	auipc	a4,0x8
    800008ec:	00873703          	ld	a4,8(a4) # 800088f0 <uart_tx_w>
    800008f0:	00008797          	auipc	a5,0x8
    800008f4:	ff87b783          	ld	a5,-8(a5) # 800088e8 <uart_tx_r>
    800008f8:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fc:	00010997          	auipc	s3,0x10
    80000900:	22c98993          	addi	s3,s3,556 # 80010b28 <uart_tx_lock>
    80000904:	00008497          	auipc	s1,0x8
    80000908:	fe448493          	addi	s1,s1,-28 # 800088e8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090c:	00008917          	auipc	s2,0x8
    80000910:	fe490913          	addi	s2,s2,-28 # 800088f0 <uart_tx_w>
    80000914:	00e79f63          	bne	a5,a4,80000932 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000918:	85ce                	mv	a1,s3
    8000091a:	8526                	mv	a0,s1
    8000091c:	00002097          	auipc	ra,0x2
    80000920:	9b0080e7          	jalr	-1616(ra) # 800022cc <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000924:	00093703          	ld	a4,0(s2)
    80000928:	609c                	ld	a5,0(s1)
    8000092a:	02078793          	addi	a5,a5,32
    8000092e:	fee785e3          	beq	a5,a4,80000918 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000932:	00010497          	auipc	s1,0x10
    80000936:	1f648493          	addi	s1,s1,502 # 80010b28 <uart_tx_lock>
    8000093a:	01f77793          	andi	a5,a4,31
    8000093e:	97a6                	add	a5,a5,s1
    80000940:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000944:	0705                	addi	a4,a4,1
    80000946:	00008797          	auipc	a5,0x8
    8000094a:	fae7b523          	sd	a4,-86(a5) # 800088f0 <uart_tx_w>
  uartstart();
    8000094e:	00000097          	auipc	ra,0x0
    80000952:	ee8080e7          	jalr	-280(ra) # 80000836 <uartstart>
  release(&uart_tx_lock);
    80000956:	8526                	mv	a0,s1
    80000958:	00000097          	auipc	ra,0x0
    8000095c:	332080e7          	jalr	818(ra) # 80000c8a <release>
}
    80000960:	70a2                	ld	ra,40(sp)
    80000962:	7402                	ld	s0,32(sp)
    80000964:	64e2                	ld	s1,24(sp)
    80000966:	6942                	ld	s2,16(sp)
    80000968:	69a2                	ld	s3,8(sp)
    8000096a:	6a02                	ld	s4,0(sp)
    8000096c:	6145                	addi	sp,sp,48
    8000096e:	8082                	ret
    for(;;)
    80000970:	a001                	j	80000970 <uartputc+0xb4>

0000000080000972 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000972:	1141                	addi	sp,sp,-16
    80000974:	e422                	sd	s0,8(sp)
    80000976:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000978:	100007b7          	lui	a5,0x10000
    8000097c:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000980:	8b85                	andi	a5,a5,1
    80000982:	cb91                	beqz	a5,80000996 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000984:	100007b7          	lui	a5,0x10000
    80000988:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000098c:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80000990:	6422                	ld	s0,8(sp)
    80000992:	0141                	addi	sp,sp,16
    80000994:	8082                	ret
    return -1;
    80000996:	557d                	li	a0,-1
    80000998:	bfe5                	j	80000990 <uartgetc+0x1e>

000000008000099a <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    8000099a:	1101                	addi	sp,sp,-32
    8000099c:	ec06                	sd	ra,24(sp)
    8000099e:	e822                	sd	s0,16(sp)
    800009a0:	e426                	sd	s1,8(sp)
    800009a2:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009a4:	54fd                	li	s1,-1
    800009a6:	a029                	j	800009b0 <uartintr+0x16>
      break;
    consoleintr(c);
    800009a8:	00000097          	auipc	ra,0x0
    800009ac:	916080e7          	jalr	-1770(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009b0:	00000097          	auipc	ra,0x0
    800009b4:	fc2080e7          	jalr	-62(ra) # 80000972 <uartgetc>
    if(c == -1)
    800009b8:	fe9518e3          	bne	a0,s1,800009a8 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009bc:	00010497          	auipc	s1,0x10
    800009c0:	16c48493          	addi	s1,s1,364 # 80010b28 <uart_tx_lock>
    800009c4:	8526                	mv	a0,s1
    800009c6:	00000097          	auipc	ra,0x0
    800009ca:	210080e7          	jalr	528(ra) # 80000bd6 <acquire>
  uartstart();
    800009ce:	00000097          	auipc	ra,0x0
    800009d2:	e68080e7          	jalr	-408(ra) # 80000836 <uartstart>
  release(&uart_tx_lock);
    800009d6:	8526                	mv	a0,s1
    800009d8:	00000097          	auipc	ra,0x0
    800009dc:	2b2080e7          	jalr	690(ra) # 80000c8a <release>
}
    800009e0:	60e2                	ld	ra,24(sp)
    800009e2:	6442                	ld	s0,16(sp)
    800009e4:	64a2                	ld	s1,8(sp)
    800009e6:	6105                	addi	sp,sp,32
    800009e8:	8082                	ret

00000000800009ea <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009ea:	1101                	addi	sp,sp,-32
    800009ec:	ec06                	sd	ra,24(sp)
    800009ee:	e822                	sd	s0,16(sp)
    800009f0:	e426                	sd	s1,8(sp)
    800009f2:	e04a                	sd	s2,0(sp)
    800009f4:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f6:	03451793          	slli	a5,a0,0x34
    800009fa:	ebb9                	bnez	a5,80000a50 <kfree+0x66>
    800009fc:	84aa                	mv	s1,a0
    800009fe:	00022797          	auipc	a5,0x22
    80000a02:	39278793          	addi	a5,a5,914 # 80022d90 <end>
    80000a06:	04f56563          	bltu	a0,a5,80000a50 <kfree+0x66>
    80000a0a:	47c5                	li	a5,17
    80000a0c:	07ee                	slli	a5,a5,0x1b
    80000a0e:	04f57163          	bgeu	a0,a5,80000a50 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a12:	6605                	lui	a2,0x1
    80000a14:	4585                	li	a1,1
    80000a16:	00000097          	auipc	ra,0x0
    80000a1a:	2bc080e7          	jalr	700(ra) # 80000cd2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a1e:	00010917          	auipc	s2,0x10
    80000a22:	14290913          	addi	s2,s2,322 # 80010b60 <kmem>
    80000a26:	854a                	mv	a0,s2
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	1ae080e7          	jalr	430(ra) # 80000bd6 <acquire>
  r->next = kmem.freelist;
    80000a30:	01893783          	ld	a5,24(s2)
    80000a34:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a36:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a3a:	854a                	mv	a0,s2
    80000a3c:	00000097          	auipc	ra,0x0
    80000a40:	24e080e7          	jalr	590(ra) # 80000c8a <release>
}
    80000a44:	60e2                	ld	ra,24(sp)
    80000a46:	6442                	ld	s0,16(sp)
    80000a48:	64a2                	ld	s1,8(sp)
    80000a4a:	6902                	ld	s2,0(sp)
    80000a4c:	6105                	addi	sp,sp,32
    80000a4e:	8082                	ret
    panic("kfree");
    80000a50:	00007517          	auipc	a0,0x7
    80000a54:	61050513          	addi	a0,a0,1552 # 80008060 <digits+0x20>
    80000a58:	00000097          	auipc	ra,0x0
    80000a5c:	ae6080e7          	jalr	-1306(ra) # 8000053e <panic>

0000000080000a60 <freerange>:
{
    80000a60:	7179                	addi	sp,sp,-48
    80000a62:	f406                	sd	ra,40(sp)
    80000a64:	f022                	sd	s0,32(sp)
    80000a66:	ec26                	sd	s1,24(sp)
    80000a68:	e84a                	sd	s2,16(sp)
    80000a6a:	e44e                	sd	s3,8(sp)
    80000a6c:	e052                	sd	s4,0(sp)
    80000a6e:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a70:	6785                	lui	a5,0x1
    80000a72:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a76:	94aa                	add	s1,s1,a0
    80000a78:	757d                	lui	a0,0xfffff
    80000a7a:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a7c:	94be                	add	s1,s1,a5
    80000a7e:	0095ee63          	bltu	a1,s1,80000a9a <freerange+0x3a>
    80000a82:	892e                	mv	s2,a1
    kfree(p);
    80000a84:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a86:	6985                	lui	s3,0x1
    kfree(p);
    80000a88:	01448533          	add	a0,s1,s4
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	f5e080e7          	jalr	-162(ra) # 800009ea <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	94ce                	add	s1,s1,s3
    80000a96:	fe9979e3          	bgeu	s2,s1,80000a88 <freerange+0x28>
}
    80000a9a:	70a2                	ld	ra,40(sp)
    80000a9c:	7402                	ld	s0,32(sp)
    80000a9e:	64e2                	ld	s1,24(sp)
    80000aa0:	6942                	ld	s2,16(sp)
    80000aa2:	69a2                	ld	s3,8(sp)
    80000aa4:	6a02                	ld	s4,0(sp)
    80000aa6:	6145                	addi	sp,sp,48
    80000aa8:	8082                	ret

0000000080000aaa <kinit>:
{
    80000aaa:	1141                	addi	sp,sp,-16
    80000aac:	e406                	sd	ra,8(sp)
    80000aae:	e022                	sd	s0,0(sp)
    80000ab0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ab2:	00007597          	auipc	a1,0x7
    80000ab6:	5b658593          	addi	a1,a1,1462 # 80008068 <digits+0x28>
    80000aba:	00010517          	auipc	a0,0x10
    80000abe:	0a650513          	addi	a0,a0,166 # 80010b60 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00022517          	auipc	a0,0x22
    80000ad2:	2c250513          	addi	a0,a0,706 # 80022d90 <end>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	f8a080e7          	jalr	-118(ra) # 80000a60 <freerange>
}
    80000ade:	60a2                	ld	ra,8(sp)
    80000ae0:	6402                	ld	s0,0(sp)
    80000ae2:	0141                	addi	sp,sp,16
    80000ae4:	8082                	ret

0000000080000ae6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae6:	1101                	addi	sp,sp,-32
    80000ae8:	ec06                	sd	ra,24(sp)
    80000aea:	e822                	sd	s0,16(sp)
    80000aec:	e426                	sd	s1,8(sp)
    80000aee:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000af0:	00010497          	auipc	s1,0x10
    80000af4:	07048493          	addi	s1,s1,112 # 80010b60 <kmem>
    80000af8:	8526                	mv	a0,s1
    80000afa:	00000097          	auipc	ra,0x0
    80000afe:	0dc080e7          	jalr	220(ra) # 80000bd6 <acquire>
  r = kmem.freelist;
    80000b02:	6c84                	ld	s1,24(s1)
  if(r)
    80000b04:	c885                	beqz	s1,80000b34 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b06:	609c                	ld	a5,0(s1)
    80000b08:	00010517          	auipc	a0,0x10
    80000b0c:	05850513          	addi	a0,a0,88 # 80010b60 <kmem>
    80000b10:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b12:	00000097          	auipc	ra,0x0
    80000b16:	178080e7          	jalr	376(ra) # 80000c8a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b1a:	6605                	lui	a2,0x1
    80000b1c:	4595                	li	a1,5
    80000b1e:	8526                	mv	a0,s1
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	1b2080e7          	jalr	434(ra) # 80000cd2 <memset>
  return (void*)r;
}
    80000b28:	8526                	mv	a0,s1
    80000b2a:	60e2                	ld	ra,24(sp)
    80000b2c:	6442                	ld	s0,16(sp)
    80000b2e:	64a2                	ld	s1,8(sp)
    80000b30:	6105                	addi	sp,sp,32
    80000b32:	8082                	ret
  release(&kmem.lock);
    80000b34:	00010517          	auipc	a0,0x10
    80000b38:	02c50513          	addi	a0,a0,44 # 80010b60 <kmem>
    80000b3c:	00000097          	auipc	ra,0x0
    80000b40:	14e080e7          	jalr	334(ra) # 80000c8a <release>
  if(r)
    80000b44:	b7d5                	j	80000b28 <kalloc+0x42>

0000000080000b46 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b46:	1141                	addi	sp,sp,-16
    80000b48:	e422                	sd	s0,8(sp)
    80000b4a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b4c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b52:	00053823          	sd	zero,16(a0)
}
    80000b56:	6422                	ld	s0,8(sp)
    80000b58:	0141                	addi	sp,sp,16
    80000b5a:	8082                	ret

0000000080000b5c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b5c:	411c                	lw	a5,0(a0)
    80000b5e:	e399                	bnez	a5,80000b64 <holding+0x8>
    80000b60:	4501                	li	a0,0
  return r;
}
    80000b62:	8082                	ret
{
    80000b64:	1101                	addi	sp,sp,-32
    80000b66:	ec06                	sd	ra,24(sp)
    80000b68:	e822                	sd	s0,16(sp)
    80000b6a:	e426                	sd	s1,8(sp)
    80000b6c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6e:	6904                	ld	s1,16(a0)
    80000b70:	00001097          	auipc	ra,0x1
    80000b74:	e3e080e7          	jalr	-450(ra) # 800019ae <mycpu>
    80000b78:	40a48533          	sub	a0,s1,a0
    80000b7c:	00153513          	seqz	a0,a0
}
    80000b80:	60e2                	ld	ra,24(sp)
    80000b82:	6442                	ld	s0,16(sp)
    80000b84:	64a2                	ld	s1,8(sp)
    80000b86:	6105                	addi	sp,sp,32
    80000b88:	8082                	ret

0000000080000b8a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8a:	1101                	addi	sp,sp,-32
    80000b8c:	ec06                	sd	ra,24(sp)
    80000b8e:	e822                	sd	s0,16(sp)
    80000b90:	e426                	sd	s1,8(sp)
    80000b92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b94:	100024f3          	csrr	s1,sstatus
    80000b98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b9c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000ba2:	00001097          	auipc	ra,0x1
    80000ba6:	e0c080e7          	jalr	-500(ra) # 800019ae <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	e00080e7          	jalr	-512(ra) # 800019ae <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	2785                	addiw	a5,a5,1
    80000bba:	dd3c                	sw	a5,120(a0)
}
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
    mycpu()->intena = old;
    80000bc6:	00001097          	auipc	ra,0x1
    80000bca:	de8080e7          	jalr	-536(ra) # 800019ae <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bce:	8085                	srli	s1,s1,0x1
    80000bd0:	8885                	andi	s1,s1,1
    80000bd2:	dd64                	sw	s1,124(a0)
    80000bd4:	bfe9                	j	80000bae <push_off+0x24>

0000000080000bd6 <acquire>:
{
    80000bd6:	1101                	addi	sp,sp,-32
    80000bd8:	ec06                	sd	ra,24(sp)
    80000bda:	e822                	sd	s0,16(sp)
    80000bdc:	e426                	sd	s1,8(sp)
    80000bde:	1000                	addi	s0,sp,32
    80000be0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000be2:	00000097          	auipc	ra,0x0
    80000be6:	fa8080e7          	jalr	-88(ra) # 80000b8a <push_off>
  if(holding(lk))
    80000bea:	8526                	mv	a0,s1
    80000bec:	00000097          	auipc	ra,0x0
    80000bf0:	f70080e7          	jalr	-144(ra) # 80000b5c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	4705                	li	a4,1
  if(holding(lk))
    80000bf6:	e115                	bnez	a0,80000c1a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf8:	87ba                	mv	a5,a4
    80000bfa:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfe:	2781                	sext.w	a5,a5
    80000c00:	ffe5                	bnez	a5,80000bf8 <acquire+0x22>
  __sync_synchronize();
    80000c02:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c06:	00001097          	auipc	ra,0x1
    80000c0a:	da8080e7          	jalr	-600(ra) # 800019ae <mycpu>
    80000c0e:	e888                	sd	a0,16(s1)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    panic("acquire");
    80000c1a:	00007517          	auipc	a0,0x7
    80000c1e:	45650513          	addi	a0,a0,1110 # 80008070 <digits+0x30>
    80000c22:	00000097          	auipc	ra,0x0
    80000c26:	91c080e7          	jalr	-1764(ra) # 8000053e <panic>

0000000080000c2a <pop_off>:

void
pop_off(void)
{
    80000c2a:	1141                	addi	sp,sp,-16
    80000c2c:	e406                	sd	ra,8(sp)
    80000c2e:	e022                	sd	s0,0(sp)
    80000c30:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	d7c080e7          	jalr	-644(ra) # 800019ae <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c40:	e78d                	bnez	a5,80000c6a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c42:	5d3c                	lw	a5,120(a0)
    80000c44:	02f05b63          	blez	a5,80000c7a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c48:	37fd                	addiw	a5,a5,-1
    80000c4a:	0007871b          	sext.w	a4,a5
    80000c4e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c50:	eb09                	bnez	a4,80000c62 <pop_off+0x38>
    80000c52:	5d7c                	lw	a5,124(a0)
    80000c54:	c799                	beqz	a5,80000c62 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c5a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c62:	60a2                	ld	ra,8(sp)
    80000c64:	6402                	ld	s0,0(sp)
    80000c66:	0141                	addi	sp,sp,16
    80000c68:	8082                	ret
    panic("pop_off - interruptible");
    80000c6a:	00007517          	auipc	a0,0x7
    80000c6e:	40e50513          	addi	a0,a0,1038 # 80008078 <digits+0x38>
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	8cc080e7          	jalr	-1844(ra) # 8000053e <panic>
    panic("pop_off");
    80000c7a:	00007517          	auipc	a0,0x7
    80000c7e:	41650513          	addi	a0,a0,1046 # 80008090 <digits+0x50>
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	8bc080e7          	jalr	-1860(ra) # 8000053e <panic>

0000000080000c8a <release>:
{
    80000c8a:	1101                	addi	sp,sp,-32
    80000c8c:	ec06                	sd	ra,24(sp)
    80000c8e:	e822                	sd	s0,16(sp)
    80000c90:	e426                	sd	s1,8(sp)
    80000c92:	1000                	addi	s0,sp,32
    80000c94:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	ec6080e7          	jalr	-314(ra) # 80000b5c <holding>
    80000c9e:	c115                	beqz	a0,80000cc2 <release+0x38>
  lk->cpu = 0;
    80000ca0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca8:	0f50000f          	fence	iorw,ow
    80000cac:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	f7a080e7          	jalr	-134(ra) # 80000c2a <pop_off>
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret
    panic("release");
    80000cc2:	00007517          	auipc	a0,0x7
    80000cc6:	3d650513          	addi	a0,a0,982 # 80008098 <digits+0x58>
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	874080e7          	jalr	-1932(ra) # 8000053e <panic>

0000000080000cd2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cd2:	1141                	addi	sp,sp,-16
    80000cd4:	e422                	sd	s0,8(sp)
    80000cd6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd8:	ca19                	beqz	a2,80000cee <memset+0x1c>
    80000cda:	87aa                	mv	a5,a0
    80000cdc:	1602                	slli	a2,a2,0x20
    80000cde:	9201                	srli	a2,a2,0x20
    80000ce0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce8:	0785                	addi	a5,a5,1
    80000cea:	fee79de3          	bne	a5,a4,80000ce4 <memset+0x12>
  }
  return dst;
}
    80000cee:	6422                	ld	s0,8(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e422                	sd	s0,8(sp)
    80000cf8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfa:	ca05                	beqz	a2,80000d2a <memcmp+0x36>
    80000cfc:	fff6069b          	addiw	a3,a2,-1
    80000d00:	1682                	slli	a3,a3,0x20
    80000d02:	9281                	srli	a3,a3,0x20
    80000d04:	0685                	addi	a3,a3,1
    80000d06:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d08:	00054783          	lbu	a5,0(a0)
    80000d0c:	0005c703          	lbu	a4,0(a1)
    80000d10:	00e79863          	bne	a5,a4,80000d20 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d14:	0505                	addi	a0,a0,1
    80000d16:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d18:	fed518e3          	bne	a0,a3,80000d08 <memcmp+0x14>
  }

  return 0;
    80000d1c:	4501                	li	a0,0
    80000d1e:	a019                	j	80000d24 <memcmp+0x30>
      return *s1 - *s2;
    80000d20:	40e7853b          	subw	a0,a5,a4
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  return 0;
    80000d2a:	4501                	li	a0,0
    80000d2c:	bfe5                	j	80000d24 <memcmp+0x30>

0000000080000d2e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2e:	1141                	addi	sp,sp,-16
    80000d30:	e422                	sd	s0,8(sp)
    80000d32:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d34:	c205                	beqz	a2,80000d54 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d36:	02a5e263          	bltu	a1,a0,80000d5a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d3a:	1602                	slli	a2,a2,0x20
    80000d3c:	9201                	srli	a2,a2,0x20
    80000d3e:	00c587b3          	add	a5,a1,a2
{
    80000d42:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d44:	0585                	addi	a1,a1,1
    80000d46:	0705                	addi	a4,a4,1
    80000d48:	fff5c683          	lbu	a3,-1(a1)
    80000d4c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d50:	fef59ae3          	bne	a1,a5,80000d44 <memmove+0x16>

  return dst;
}
    80000d54:	6422                	ld	s0,8(sp)
    80000d56:	0141                	addi	sp,sp,16
    80000d58:	8082                	ret
  if(s < d && s + n > d){
    80000d5a:	02061693          	slli	a3,a2,0x20
    80000d5e:	9281                	srli	a3,a3,0x20
    80000d60:	00d58733          	add	a4,a1,a3
    80000d64:	fce57be3          	bgeu	a0,a4,80000d3a <memmove+0xc>
    d += n;
    80000d68:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d6a:	fff6079b          	addiw	a5,a2,-1
    80000d6e:	1782                	slli	a5,a5,0x20
    80000d70:	9381                	srli	a5,a5,0x20
    80000d72:	fff7c793          	not	a5,a5
    80000d76:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d78:	177d                	addi	a4,a4,-1
    80000d7a:	16fd                	addi	a3,a3,-1
    80000d7c:	00074603          	lbu	a2,0(a4)
    80000d80:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d84:	fee79ae3          	bne	a5,a4,80000d78 <memmove+0x4a>
    80000d88:	b7f1                	j	80000d54 <memmove+0x26>

0000000080000d8a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d8a:	1141                	addi	sp,sp,-16
    80000d8c:	e406                	sd	ra,8(sp)
    80000d8e:	e022                	sd	s0,0(sp)
    80000d90:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d92:	00000097          	auipc	ra,0x0
    80000d96:	f9c080e7          	jalr	-100(ra) # 80000d2e <memmove>
}
    80000d9a:	60a2                	ld	ra,8(sp)
    80000d9c:	6402                	ld	s0,0(sp)
    80000d9e:	0141                	addi	sp,sp,16
    80000da0:	8082                	ret

0000000080000da2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da2:	1141                	addi	sp,sp,-16
    80000da4:	e422                	sd	s0,8(sp)
    80000da6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da8:	ce11                	beqz	a2,80000dc4 <strncmp+0x22>
    80000daa:	00054783          	lbu	a5,0(a0)
    80000dae:	cf89                	beqz	a5,80000dc8 <strncmp+0x26>
    80000db0:	0005c703          	lbu	a4,0(a1)
    80000db4:	00f71a63          	bne	a4,a5,80000dc8 <strncmp+0x26>
    n--, p++, q++;
    80000db8:	367d                	addiw	a2,a2,-1
    80000dba:	0505                	addi	a0,a0,1
    80000dbc:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dbe:	f675                	bnez	a2,80000daa <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dc0:	4501                	li	a0,0
    80000dc2:	a809                	j	80000dd4 <strncmp+0x32>
    80000dc4:	4501                	li	a0,0
    80000dc6:	a039                	j	80000dd4 <strncmp+0x32>
  if(n == 0)
    80000dc8:	ca09                	beqz	a2,80000dda <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dca:	00054503          	lbu	a0,0(a0)
    80000dce:	0005c783          	lbu	a5,0(a1)
    80000dd2:	9d1d                	subw	a0,a0,a5
}
    80000dd4:	6422                	ld	s0,8(sp)
    80000dd6:	0141                	addi	sp,sp,16
    80000dd8:	8082                	ret
    return 0;
    80000dda:	4501                	li	a0,0
    80000ddc:	bfe5                	j	80000dd4 <strncmp+0x32>

0000000080000dde <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dde:	1141                	addi	sp,sp,-16
    80000de0:	e422                	sd	s0,8(sp)
    80000de2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de4:	872a                	mv	a4,a0
    80000de6:	8832                	mv	a6,a2
    80000de8:	367d                	addiw	a2,a2,-1
    80000dea:	01005963          	blez	a6,80000dfc <strncpy+0x1e>
    80000dee:	0705                	addi	a4,a4,1
    80000df0:	0005c783          	lbu	a5,0(a1)
    80000df4:	fef70fa3          	sb	a5,-1(a4)
    80000df8:	0585                	addi	a1,a1,1
    80000dfa:	f7f5                	bnez	a5,80000de6 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dfc:	86ba                	mv	a3,a4
    80000dfe:	00c05c63          	blez	a2,80000e16 <strncpy+0x38>
    *s++ = 0;
    80000e02:	0685                	addi	a3,a3,1
    80000e04:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e08:	fff6c793          	not	a5,a3
    80000e0c:	9fb9                	addw	a5,a5,a4
    80000e0e:	010787bb          	addw	a5,a5,a6
    80000e12:	fef048e3          	bgtz	a5,80000e02 <strncpy+0x24>
  return os;
}
    80000e16:	6422                	ld	s0,8(sp)
    80000e18:	0141                	addi	sp,sp,16
    80000e1a:	8082                	ret

0000000080000e1c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e1c:	1141                	addi	sp,sp,-16
    80000e1e:	e422                	sd	s0,8(sp)
    80000e20:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e22:	02c05363          	blez	a2,80000e48 <safestrcpy+0x2c>
    80000e26:	fff6069b          	addiw	a3,a2,-1
    80000e2a:	1682                	slli	a3,a3,0x20
    80000e2c:	9281                	srli	a3,a3,0x20
    80000e2e:	96ae                	add	a3,a3,a1
    80000e30:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e32:	00d58963          	beq	a1,a3,80000e44 <safestrcpy+0x28>
    80000e36:	0585                	addi	a1,a1,1
    80000e38:	0785                	addi	a5,a5,1
    80000e3a:	fff5c703          	lbu	a4,-1(a1)
    80000e3e:	fee78fa3          	sb	a4,-1(a5)
    80000e42:	fb65                	bnez	a4,80000e32 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e44:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e48:	6422                	ld	s0,8(sp)
    80000e4a:	0141                	addi	sp,sp,16
    80000e4c:	8082                	ret

0000000080000e4e <strlen>:

int
strlen(const char *s)
{
    80000e4e:	1141                	addi	sp,sp,-16
    80000e50:	e422                	sd	s0,8(sp)
    80000e52:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e54:	00054783          	lbu	a5,0(a0)
    80000e58:	cf91                	beqz	a5,80000e74 <strlen+0x26>
    80000e5a:	0505                	addi	a0,a0,1
    80000e5c:	87aa                	mv	a5,a0
    80000e5e:	4685                	li	a3,1
    80000e60:	9e89                	subw	a3,a3,a0
    80000e62:	00f6853b          	addw	a0,a3,a5
    80000e66:	0785                	addi	a5,a5,1
    80000e68:	fff7c703          	lbu	a4,-1(a5)
    80000e6c:	fb7d                	bnez	a4,80000e62 <strlen+0x14>
    ;
  return n;
}
    80000e6e:	6422                	ld	s0,8(sp)
    80000e70:	0141                	addi	sp,sp,16
    80000e72:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e74:	4501                	li	a0,0
    80000e76:	bfe5                	j	80000e6e <strlen+0x20>

0000000080000e78 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e78:	1141                	addi	sp,sp,-16
    80000e7a:	e406                	sd	ra,8(sp)
    80000e7c:	e022                	sd	s0,0(sp)
    80000e7e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e80:	00001097          	auipc	ra,0x1
    80000e84:	b1e080e7          	jalr	-1250(ra) # 8000199e <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e88:	00008717          	auipc	a4,0x8
    80000e8c:	a7070713          	addi	a4,a4,-1424 # 800088f8 <started>
  if(cpuid() == 0){
    80000e90:	c139                	beqz	a0,80000ed6 <main+0x5e>
    while(started == 0)
    80000e92:	431c                	lw	a5,0(a4)
    80000e94:	2781                	sext.w	a5,a5
    80000e96:	dff5                	beqz	a5,80000e92 <main+0x1a>
      ;
    __sync_synchronize();
    80000e98:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e9c:	00001097          	auipc	ra,0x1
    80000ea0:	b02080e7          	jalr	-1278(ra) # 8000199e <cpuid>
    80000ea4:	85aa                	mv	a1,a0
    80000ea6:	00007517          	auipc	a0,0x7
    80000eaa:	21250513          	addi	a0,a0,530 # 800080b8 <digits+0x78>
    80000eae:	fffff097          	auipc	ra,0xfffff
    80000eb2:	6da080e7          	jalr	1754(ra) # 80000588 <printf>
    kvminithart();    // turn on paging
    80000eb6:	00000097          	auipc	ra,0x0
    80000eba:	0d8080e7          	jalr	216(ra) # 80000f8e <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ebe:	00002097          	auipc	ra,0x2
    80000ec2:	b92080e7          	jalr	-1134(ra) # 80002a50 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	37a080e7          	jalr	890(ra) # 80006240 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	066080e7          	jalr	102(ra) # 80001f34 <scheduler>
    consoleinit();
    80000ed6:	fffff097          	auipc	ra,0xfffff
    80000eda:	57a080e7          	jalr	1402(ra) # 80000450 <consoleinit>
    printfinit();
    80000ede:	00000097          	auipc	ra,0x0
    80000ee2:	88a080e7          	jalr	-1910(ra) # 80000768 <printfinit>
    printf("\n");
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	1e250513          	addi	a0,a0,482 # 800080c8 <digits+0x88>
    80000eee:	fffff097          	auipc	ra,0xfffff
    80000ef2:	69a080e7          	jalr	1690(ra) # 80000588 <printf>
    printf("xv6 kernel is booting\n");
    80000ef6:	00007517          	auipc	a0,0x7
    80000efa:	1aa50513          	addi	a0,a0,426 # 800080a0 <digits+0x60>
    80000efe:	fffff097          	auipc	ra,0xfffff
    80000f02:	68a080e7          	jalr	1674(ra) # 80000588 <printf>
    printf("\n");
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	1c250513          	addi	a0,a0,450 # 800080c8 <digits+0x88>
    80000f0e:	fffff097          	auipc	ra,0xfffff
    80000f12:	67a080e7          	jalr	1658(ra) # 80000588 <printf>
    kinit();         // physical page allocator
    80000f16:	00000097          	auipc	ra,0x0
    80000f1a:	b94080e7          	jalr	-1132(ra) # 80000aaa <kinit>
    kvminit();       // create kernel page table
    80000f1e:	00000097          	auipc	ra,0x0
    80000f22:	326080e7          	jalr	806(ra) # 80001244 <kvminit>
    kvminithart();   // turn on paging
    80000f26:	00000097          	auipc	ra,0x0
    80000f2a:	068080e7          	jalr	104(ra) # 80000f8e <kvminithart>
    procinit();      // process table
    80000f2e:	00001097          	auipc	ra,0x1
    80000f32:	99e080e7          	jalr	-1634(ra) # 800018cc <procinit>
    trapinit();      // trap vectors
    80000f36:	00002097          	auipc	ra,0x2
    80000f3a:	af2080e7          	jalr	-1294(ra) # 80002a28 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	b12080e7          	jalr	-1262(ra) # 80002a50 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	2e4080e7          	jalr	740(ra) # 8000622a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	2f2080e7          	jalr	754(ra) # 80006240 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	486080e7          	jalr	1158(ra) # 800033dc <binit>
    iinit();         // inode table
    80000f5e:	00003097          	auipc	ra,0x3
    80000f62:	b2a080e7          	jalr	-1238(ra) # 80003a88 <iinit>
    fileinit();      // file table
    80000f66:	00004097          	auipc	ra,0x4
    80000f6a:	ac8080e7          	jalr	-1336(ra) # 80004a2e <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	3da080e7          	jalr	986(ra) # 80006348 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	d42080e7          	jalr	-702(ra) # 80001cb8 <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	96f72a23          	sw	a5,-1676(a4) # 800088f8 <started>
    80000f8c:	b789                	j	80000ece <main+0x56>

0000000080000f8e <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f8e:	1141                	addi	sp,sp,-16
    80000f90:	e422                	sd	s0,8(sp)
    80000f92:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f94:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f98:	00008797          	auipc	a5,0x8
    80000f9c:	9687b783          	ld	a5,-1688(a5) # 80008900 <kernel_pagetable>
    80000fa0:	83b1                	srli	a5,a5,0xc
    80000fa2:	577d                	li	a4,-1
    80000fa4:	177e                	slli	a4,a4,0x3f
    80000fa6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fac:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fb0:	6422                	ld	s0,8(sp)
    80000fb2:	0141                	addi	sp,sp,16
    80000fb4:	8082                	ret

0000000080000fb6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb6:	7139                	addi	sp,sp,-64
    80000fb8:	fc06                	sd	ra,56(sp)
    80000fba:	f822                	sd	s0,48(sp)
    80000fbc:	f426                	sd	s1,40(sp)
    80000fbe:	f04a                	sd	s2,32(sp)
    80000fc0:	ec4e                	sd	s3,24(sp)
    80000fc2:	e852                	sd	s4,16(sp)
    80000fc4:	e456                	sd	s5,8(sp)
    80000fc6:	e05a                	sd	s6,0(sp)
    80000fc8:	0080                	addi	s0,sp,64
    80000fca:	84aa                	mv	s1,a0
    80000fcc:	89ae                	mv	s3,a1
    80000fce:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fd0:	57fd                	li	a5,-1
    80000fd2:	83e9                	srli	a5,a5,0x1a
    80000fd4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd8:	04b7f263          	bgeu	a5,a1,8000101c <walk+0x66>
    panic("walk");
    80000fdc:	00007517          	auipc	a0,0x7
    80000fe0:	0f450513          	addi	a0,a0,244 # 800080d0 <digits+0x90>
    80000fe4:	fffff097          	auipc	ra,0xfffff
    80000fe8:	55a080e7          	jalr	1370(ra) # 8000053e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fec:	060a8663          	beqz	s5,80001058 <walk+0xa2>
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	af6080e7          	jalr	-1290(ra) # 80000ae6 <kalloc>
    80000ff8:	84aa                	mv	s1,a0
    80000ffa:	c529                	beqz	a0,80001044 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ffc:	6605                	lui	a2,0x1
    80000ffe:	4581                	li	a1,0
    80001000:	00000097          	auipc	ra,0x0
    80001004:	cd2080e7          	jalr	-814(ra) # 80000cd2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001008:	00c4d793          	srli	a5,s1,0xc
    8000100c:	07aa                	slli	a5,a5,0xa
    8000100e:	0017e793          	ori	a5,a5,1
    80001012:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001016:	3a5d                	addiw	s4,s4,-9
    80001018:	036a0063          	beq	s4,s6,80001038 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000101c:	0149d933          	srl	s2,s3,s4
    80001020:	1ff97913          	andi	s2,s2,511
    80001024:	090e                	slli	s2,s2,0x3
    80001026:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001028:	00093483          	ld	s1,0(s2)
    8000102c:	0014f793          	andi	a5,s1,1
    80001030:	dfd5                	beqz	a5,80000fec <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001032:	80a9                	srli	s1,s1,0xa
    80001034:	04b2                	slli	s1,s1,0xc
    80001036:	b7c5                	j	80001016 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001038:	00c9d513          	srli	a0,s3,0xc
    8000103c:	1ff57513          	andi	a0,a0,511
    80001040:	050e                	slli	a0,a0,0x3
    80001042:	9526                	add	a0,a0,s1
}
    80001044:	70e2                	ld	ra,56(sp)
    80001046:	7442                	ld	s0,48(sp)
    80001048:	74a2                	ld	s1,40(sp)
    8000104a:	7902                	ld	s2,32(sp)
    8000104c:	69e2                	ld	s3,24(sp)
    8000104e:	6a42                	ld	s4,16(sp)
    80001050:	6aa2                	ld	s5,8(sp)
    80001052:	6b02                	ld	s6,0(sp)
    80001054:	6121                	addi	sp,sp,64
    80001056:	8082                	ret
        return 0;
    80001058:	4501                	li	a0,0
    8000105a:	b7ed                	j	80001044 <walk+0x8e>

000000008000105c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000105c:	57fd                	li	a5,-1
    8000105e:	83e9                	srli	a5,a5,0x1a
    80001060:	00b7f463          	bgeu	a5,a1,80001068 <walkaddr+0xc>
    return 0;
    80001064:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001066:	8082                	ret
{
    80001068:	1141                	addi	sp,sp,-16
    8000106a:	e406                	sd	ra,8(sp)
    8000106c:	e022                	sd	s0,0(sp)
    8000106e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001070:	4601                	li	a2,0
    80001072:	00000097          	auipc	ra,0x0
    80001076:	f44080e7          	jalr	-188(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000107a:	c105                	beqz	a0,8000109a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000107c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000107e:	0117f693          	andi	a3,a5,17
    80001082:	4745                	li	a4,17
    return 0;
    80001084:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001086:	00e68663          	beq	a3,a4,80001092 <walkaddr+0x36>
}
    8000108a:	60a2                	ld	ra,8(sp)
    8000108c:	6402                	ld	s0,0(sp)
    8000108e:	0141                	addi	sp,sp,16
    80001090:	8082                	ret
  pa = PTE2PA(*pte);
    80001092:	00a7d513          	srli	a0,a5,0xa
    80001096:	0532                	slli	a0,a0,0xc
  return pa;
    80001098:	bfcd                	j	8000108a <walkaddr+0x2e>
    return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7fd                	j	8000108a <walkaddr+0x2e>

000000008000109e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000109e:	715d                	addi	sp,sp,-80
    800010a0:	e486                	sd	ra,72(sp)
    800010a2:	e0a2                	sd	s0,64(sp)
    800010a4:	fc26                	sd	s1,56(sp)
    800010a6:	f84a                	sd	s2,48(sp)
    800010a8:	f44e                	sd	s3,40(sp)
    800010aa:	f052                	sd	s4,32(sp)
    800010ac:	ec56                	sd	s5,24(sp)
    800010ae:	e85a                	sd	s6,16(sp)
    800010b0:	e45e                	sd	s7,8(sp)
    800010b2:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010b4:	c639                	beqz	a2,80001102 <mappages+0x64>
    800010b6:	8aaa                	mv	s5,a0
    800010b8:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010ba:	77fd                	lui	a5,0xfffff
    800010bc:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800010c0:	15fd                	addi	a1,a1,-1
    800010c2:	00c589b3          	add	s3,a1,a2
    800010c6:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800010ca:	8952                	mv	s2,s4
    800010cc:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d0:	6b85                	lui	s7,0x1
    800010d2:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d6:	4605                	li	a2,1
    800010d8:	85ca                	mv	a1,s2
    800010da:	8556                	mv	a0,s5
    800010dc:	00000097          	auipc	ra,0x0
    800010e0:	eda080e7          	jalr	-294(ra) # 80000fb6 <walk>
    800010e4:	cd1d                	beqz	a0,80001122 <mappages+0x84>
    if(*pte & PTE_V)
    800010e6:	611c                	ld	a5,0(a0)
    800010e8:	8b85                	andi	a5,a5,1
    800010ea:	e785                	bnez	a5,80001112 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010ec:	80b1                	srli	s1,s1,0xc
    800010ee:	04aa                	slli	s1,s1,0xa
    800010f0:	0164e4b3          	or	s1,s1,s6
    800010f4:	0014e493          	ori	s1,s1,1
    800010f8:	e104                	sd	s1,0(a0)
    if(a == last)
    800010fa:	05390063          	beq	s2,s3,8000113a <mappages+0x9c>
    a += PGSIZE;
    800010fe:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001100:	bfc9                	j	800010d2 <mappages+0x34>
    panic("mappages: size");
    80001102:	00007517          	auipc	a0,0x7
    80001106:	fd650513          	addi	a0,a0,-42 # 800080d8 <digits+0x98>
    8000110a:	fffff097          	auipc	ra,0xfffff
    8000110e:	434080e7          	jalr	1076(ra) # 8000053e <panic>
      panic("mappages: remap");
    80001112:	00007517          	auipc	a0,0x7
    80001116:	fd650513          	addi	a0,a0,-42 # 800080e8 <digits+0xa8>
    8000111a:	fffff097          	auipc	ra,0xfffff
    8000111e:	424080e7          	jalr	1060(ra) # 8000053e <panic>
      return -1;
    80001122:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001124:	60a6                	ld	ra,72(sp)
    80001126:	6406                	ld	s0,64(sp)
    80001128:	74e2                	ld	s1,56(sp)
    8000112a:	7942                	ld	s2,48(sp)
    8000112c:	79a2                	ld	s3,40(sp)
    8000112e:	7a02                	ld	s4,32(sp)
    80001130:	6ae2                	ld	s5,24(sp)
    80001132:	6b42                	ld	s6,16(sp)
    80001134:	6ba2                	ld	s7,8(sp)
    80001136:	6161                	addi	sp,sp,80
    80001138:	8082                	ret
  return 0;
    8000113a:	4501                	li	a0,0
    8000113c:	b7e5                	j	80001124 <mappages+0x86>

000000008000113e <kvmmap>:
{
    8000113e:	1141                	addi	sp,sp,-16
    80001140:	e406                	sd	ra,8(sp)
    80001142:	e022                	sd	s0,0(sp)
    80001144:	0800                	addi	s0,sp,16
    80001146:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001148:	86b2                	mv	a3,a2
    8000114a:	863e                	mv	a2,a5
    8000114c:	00000097          	auipc	ra,0x0
    80001150:	f52080e7          	jalr	-174(ra) # 8000109e <mappages>
    80001154:	e509                	bnez	a0,8000115e <kvmmap+0x20>
}
    80001156:	60a2                	ld	ra,8(sp)
    80001158:	6402                	ld	s0,0(sp)
    8000115a:	0141                	addi	sp,sp,16
    8000115c:	8082                	ret
    panic("kvmmap");
    8000115e:	00007517          	auipc	a0,0x7
    80001162:	f9a50513          	addi	a0,a0,-102 # 800080f8 <digits+0xb8>
    80001166:	fffff097          	auipc	ra,0xfffff
    8000116a:	3d8080e7          	jalr	984(ra) # 8000053e <panic>

000000008000116e <kvmmake>:
{
    8000116e:	1101                	addi	sp,sp,-32
    80001170:	ec06                	sd	ra,24(sp)
    80001172:	e822                	sd	s0,16(sp)
    80001174:	e426                	sd	s1,8(sp)
    80001176:	e04a                	sd	s2,0(sp)
    80001178:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000117a:	00000097          	auipc	ra,0x0
    8000117e:	96c080e7          	jalr	-1684(ra) # 80000ae6 <kalloc>
    80001182:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001184:	6605                	lui	a2,0x1
    80001186:	4581                	li	a1,0
    80001188:	00000097          	auipc	ra,0x0
    8000118c:	b4a080e7          	jalr	-1206(ra) # 80000cd2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001190:	4719                	li	a4,6
    80001192:	6685                	lui	a3,0x1
    80001194:	10000637          	lui	a2,0x10000
    80001198:	100005b7          	lui	a1,0x10000
    8000119c:	8526                	mv	a0,s1
    8000119e:	00000097          	auipc	ra,0x0
    800011a2:	fa0080e7          	jalr	-96(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a6:	4719                	li	a4,6
    800011a8:	6685                	lui	a3,0x1
    800011aa:	10001637          	lui	a2,0x10001
    800011ae:	100015b7          	lui	a1,0x10001
    800011b2:	8526                	mv	a0,s1
    800011b4:	00000097          	auipc	ra,0x0
    800011b8:	f8a080e7          	jalr	-118(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011bc:	4719                	li	a4,6
    800011be:	004006b7          	lui	a3,0x400
    800011c2:	0c000637          	lui	a2,0xc000
    800011c6:	0c0005b7          	lui	a1,0xc000
    800011ca:	8526                	mv	a0,s1
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f72080e7          	jalr	-142(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011d4:	00007917          	auipc	s2,0x7
    800011d8:	e2c90913          	addi	s2,s2,-468 # 80008000 <etext>
    800011dc:	4729                	li	a4,10
    800011de:	80007697          	auipc	a3,0x80007
    800011e2:	e2268693          	addi	a3,a3,-478 # 8000 <_entry-0x7fff8000>
    800011e6:	4605                	li	a2,1
    800011e8:	067e                	slli	a2,a2,0x1f
    800011ea:	85b2                	mv	a1,a2
    800011ec:	8526                	mv	a0,s1
    800011ee:	00000097          	auipc	ra,0x0
    800011f2:	f50080e7          	jalr	-176(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f6:	4719                	li	a4,6
    800011f8:	46c5                	li	a3,17
    800011fa:	06ee                	slli	a3,a3,0x1b
    800011fc:	412686b3          	sub	a3,a3,s2
    80001200:	864a                	mv	a2,s2
    80001202:	85ca                	mv	a1,s2
    80001204:	8526                	mv	a0,s1
    80001206:	00000097          	auipc	ra,0x0
    8000120a:	f38080e7          	jalr	-200(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000120e:	4729                	li	a4,10
    80001210:	6685                	lui	a3,0x1
    80001212:	00006617          	auipc	a2,0x6
    80001216:	dee60613          	addi	a2,a2,-530 # 80007000 <_trampoline>
    8000121a:	040005b7          	lui	a1,0x4000
    8000121e:	15fd                	addi	a1,a1,-1
    80001220:	05b2                	slli	a1,a1,0xc
    80001222:	8526                	mv	a0,s1
    80001224:	00000097          	auipc	ra,0x0
    80001228:	f1a080e7          	jalr	-230(ra) # 8000113e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000122c:	8526                	mv	a0,s1
    8000122e:	00000097          	auipc	ra,0x0
    80001232:	608080e7          	jalr	1544(ra) # 80001836 <proc_mapstacks>
}
    80001236:	8526                	mv	a0,s1
    80001238:	60e2                	ld	ra,24(sp)
    8000123a:	6442                	ld	s0,16(sp)
    8000123c:	64a2                	ld	s1,8(sp)
    8000123e:	6902                	ld	s2,0(sp)
    80001240:	6105                	addi	sp,sp,32
    80001242:	8082                	ret

0000000080001244 <kvminit>:
{
    80001244:	1141                	addi	sp,sp,-16
    80001246:	e406                	sd	ra,8(sp)
    80001248:	e022                	sd	s0,0(sp)
    8000124a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	f22080e7          	jalr	-222(ra) # 8000116e <kvmmake>
    80001254:	00007797          	auipc	a5,0x7
    80001258:	6aa7b623          	sd	a0,1708(a5) # 80008900 <kernel_pagetable>
}
    8000125c:	60a2                	ld	ra,8(sp)
    8000125e:	6402                	ld	s0,0(sp)
    80001260:	0141                	addi	sp,sp,16
    80001262:	8082                	ret

0000000080001264 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001264:	715d                	addi	sp,sp,-80
    80001266:	e486                	sd	ra,72(sp)
    80001268:	e0a2                	sd	s0,64(sp)
    8000126a:	fc26                	sd	s1,56(sp)
    8000126c:	f84a                	sd	s2,48(sp)
    8000126e:	f44e                	sd	s3,40(sp)
    80001270:	f052                	sd	s4,32(sp)
    80001272:	ec56                	sd	s5,24(sp)
    80001274:	e85a                	sd	s6,16(sp)
    80001276:	e45e                	sd	s7,8(sp)
    80001278:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000127a:	03459793          	slli	a5,a1,0x34
    8000127e:	e795                	bnez	a5,800012aa <uvmunmap+0x46>
    80001280:	8a2a                	mv	s4,a0
    80001282:	892e                	mv	s2,a1
    80001284:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001286:	0632                	slli	a2,a2,0xc
    80001288:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000128c:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000128e:	6b05                	lui	s6,0x1
    80001290:	0735e263          	bltu	a1,s3,800012f4 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001294:	60a6                	ld	ra,72(sp)
    80001296:	6406                	ld	s0,64(sp)
    80001298:	74e2                	ld	s1,56(sp)
    8000129a:	7942                	ld	s2,48(sp)
    8000129c:	79a2                	ld	s3,40(sp)
    8000129e:	7a02                	ld	s4,32(sp)
    800012a0:	6ae2                	ld	s5,24(sp)
    800012a2:	6b42                	ld	s6,16(sp)
    800012a4:	6ba2                	ld	s7,8(sp)
    800012a6:	6161                	addi	sp,sp,80
    800012a8:	8082                	ret
    panic("uvmunmap: not aligned");
    800012aa:	00007517          	auipc	a0,0x7
    800012ae:	e5650513          	addi	a0,a0,-426 # 80008100 <digits+0xc0>
    800012b2:	fffff097          	auipc	ra,0xfffff
    800012b6:	28c080e7          	jalr	652(ra) # 8000053e <panic>
      panic("uvmunmap: walk");
    800012ba:	00007517          	auipc	a0,0x7
    800012be:	e5e50513          	addi	a0,a0,-418 # 80008118 <digits+0xd8>
    800012c2:	fffff097          	auipc	ra,0xfffff
    800012c6:	27c080e7          	jalr	636(ra) # 8000053e <panic>
      panic("uvmunmap: not mapped");
    800012ca:	00007517          	auipc	a0,0x7
    800012ce:	e5e50513          	addi	a0,a0,-418 # 80008128 <digits+0xe8>
    800012d2:	fffff097          	auipc	ra,0xfffff
    800012d6:	26c080e7          	jalr	620(ra) # 8000053e <panic>
      panic("uvmunmap: not a leaf");
    800012da:	00007517          	auipc	a0,0x7
    800012de:	e6650513          	addi	a0,a0,-410 # 80008140 <digits+0x100>
    800012e2:	fffff097          	auipc	ra,0xfffff
    800012e6:	25c080e7          	jalr	604(ra) # 8000053e <panic>
    *pte = 0;
    800012ea:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ee:	995a                	add	s2,s2,s6
    800012f0:	fb3972e3          	bgeu	s2,s3,80001294 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012f4:	4601                	li	a2,0
    800012f6:	85ca                	mv	a1,s2
    800012f8:	8552                	mv	a0,s4
    800012fa:	00000097          	auipc	ra,0x0
    800012fe:	cbc080e7          	jalr	-836(ra) # 80000fb6 <walk>
    80001302:	84aa                	mv	s1,a0
    80001304:	d95d                	beqz	a0,800012ba <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001306:	6108                	ld	a0,0(a0)
    80001308:	00157793          	andi	a5,a0,1
    8000130c:	dfdd                	beqz	a5,800012ca <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000130e:	3ff57793          	andi	a5,a0,1023
    80001312:	fd7784e3          	beq	a5,s7,800012da <uvmunmap+0x76>
    if(do_free){
    80001316:	fc0a8ae3          	beqz	s5,800012ea <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000131a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000131c:	0532                	slli	a0,a0,0xc
    8000131e:	fffff097          	auipc	ra,0xfffff
    80001322:	6cc080e7          	jalr	1740(ra) # 800009ea <kfree>
    80001326:	b7d1                	j	800012ea <uvmunmap+0x86>

0000000080001328 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001328:	1101                	addi	sp,sp,-32
    8000132a:	ec06                	sd	ra,24(sp)
    8000132c:	e822                	sd	s0,16(sp)
    8000132e:	e426                	sd	s1,8(sp)
    80001330:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001332:	fffff097          	auipc	ra,0xfffff
    80001336:	7b4080e7          	jalr	1972(ra) # 80000ae6 <kalloc>
    8000133a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000133c:	c519                	beqz	a0,8000134a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000133e:	6605                	lui	a2,0x1
    80001340:	4581                	li	a1,0
    80001342:	00000097          	auipc	ra,0x0
    80001346:	990080e7          	jalr	-1648(ra) # 80000cd2 <memset>
  return pagetable;
}
    8000134a:	8526                	mv	a0,s1
    8000134c:	60e2                	ld	ra,24(sp)
    8000134e:	6442                	ld	s0,16(sp)
    80001350:	64a2                	ld	s1,8(sp)
    80001352:	6105                	addi	sp,sp,32
    80001354:	8082                	ret

0000000080001356 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001356:	7179                	addi	sp,sp,-48
    80001358:	f406                	sd	ra,40(sp)
    8000135a:	f022                	sd	s0,32(sp)
    8000135c:	ec26                	sd	s1,24(sp)
    8000135e:	e84a                	sd	s2,16(sp)
    80001360:	e44e                	sd	s3,8(sp)
    80001362:	e052                	sd	s4,0(sp)
    80001364:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001366:	6785                	lui	a5,0x1
    80001368:	04f67863          	bgeu	a2,a5,800013b8 <uvmfirst+0x62>
    8000136c:	8a2a                	mv	s4,a0
    8000136e:	89ae                	mv	s3,a1
    80001370:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	774080e7          	jalr	1908(ra) # 80000ae6 <kalloc>
    8000137a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000137c:	6605                	lui	a2,0x1
    8000137e:	4581                	li	a1,0
    80001380:	00000097          	auipc	ra,0x0
    80001384:	952080e7          	jalr	-1710(ra) # 80000cd2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001388:	4779                	li	a4,30
    8000138a:	86ca                	mv	a3,s2
    8000138c:	6605                	lui	a2,0x1
    8000138e:	4581                	li	a1,0
    80001390:	8552                	mv	a0,s4
    80001392:	00000097          	auipc	ra,0x0
    80001396:	d0c080e7          	jalr	-756(ra) # 8000109e <mappages>
  memmove(mem, src, sz);
    8000139a:	8626                	mv	a2,s1
    8000139c:	85ce                	mv	a1,s3
    8000139e:	854a                	mv	a0,s2
    800013a0:	00000097          	auipc	ra,0x0
    800013a4:	98e080e7          	jalr	-1650(ra) # 80000d2e <memmove>
}
    800013a8:	70a2                	ld	ra,40(sp)
    800013aa:	7402                	ld	s0,32(sp)
    800013ac:	64e2                	ld	s1,24(sp)
    800013ae:	6942                	ld	s2,16(sp)
    800013b0:	69a2                	ld	s3,8(sp)
    800013b2:	6a02                	ld	s4,0(sp)
    800013b4:	6145                	addi	sp,sp,48
    800013b6:	8082                	ret
    panic("uvmfirst: more than a page");
    800013b8:	00007517          	auipc	a0,0x7
    800013bc:	da050513          	addi	a0,a0,-608 # 80008158 <digits+0x118>
    800013c0:	fffff097          	auipc	ra,0xfffff
    800013c4:	17e080e7          	jalr	382(ra) # 8000053e <panic>

00000000800013c8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c8:	1101                	addi	sp,sp,-32
    800013ca:	ec06                	sd	ra,24(sp)
    800013cc:	e822                	sd	s0,16(sp)
    800013ce:	e426                	sd	s1,8(sp)
    800013d0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013d2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013d4:	00b67d63          	bgeu	a2,a1,800013ee <uvmdealloc+0x26>
    800013d8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013da:	6785                	lui	a5,0x1
    800013dc:	17fd                	addi	a5,a5,-1
    800013de:	00f60733          	add	a4,a2,a5
    800013e2:	767d                	lui	a2,0xfffff
    800013e4:	8f71                	and	a4,a4,a2
    800013e6:	97ae                	add	a5,a5,a1
    800013e8:	8ff1                	and	a5,a5,a2
    800013ea:	00f76863          	bltu	a4,a5,800013fa <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013ee:	8526                	mv	a0,s1
    800013f0:	60e2                	ld	ra,24(sp)
    800013f2:	6442                	ld	s0,16(sp)
    800013f4:	64a2                	ld	s1,8(sp)
    800013f6:	6105                	addi	sp,sp,32
    800013f8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013fa:	8f99                	sub	a5,a5,a4
    800013fc:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013fe:	4685                	li	a3,1
    80001400:	0007861b          	sext.w	a2,a5
    80001404:	85ba                	mv	a1,a4
    80001406:	00000097          	auipc	ra,0x0
    8000140a:	e5e080e7          	jalr	-418(ra) # 80001264 <uvmunmap>
    8000140e:	b7c5                	j	800013ee <uvmdealloc+0x26>

0000000080001410 <uvmalloc>:
  if(newsz < oldsz)
    80001410:	0ab66563          	bltu	a2,a1,800014ba <uvmalloc+0xaa>
{
    80001414:	7139                	addi	sp,sp,-64
    80001416:	fc06                	sd	ra,56(sp)
    80001418:	f822                	sd	s0,48(sp)
    8000141a:	f426                	sd	s1,40(sp)
    8000141c:	f04a                	sd	s2,32(sp)
    8000141e:	ec4e                	sd	s3,24(sp)
    80001420:	e852                	sd	s4,16(sp)
    80001422:	e456                	sd	s5,8(sp)
    80001424:	e05a                	sd	s6,0(sp)
    80001426:	0080                	addi	s0,sp,64
    80001428:	8aaa                	mv	s5,a0
    8000142a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000142c:	6985                	lui	s3,0x1
    8000142e:	19fd                	addi	s3,s3,-1
    80001430:	95ce                	add	a1,a1,s3
    80001432:	79fd                	lui	s3,0xfffff
    80001434:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001438:	08c9f363          	bgeu	s3,a2,800014be <uvmalloc+0xae>
    8000143c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000143e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001442:	fffff097          	auipc	ra,0xfffff
    80001446:	6a4080e7          	jalr	1700(ra) # 80000ae6 <kalloc>
    8000144a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000144c:	c51d                	beqz	a0,8000147a <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000144e:	6605                	lui	a2,0x1
    80001450:	4581                	li	a1,0
    80001452:	00000097          	auipc	ra,0x0
    80001456:	880080e7          	jalr	-1920(ra) # 80000cd2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000145a:	875a                	mv	a4,s6
    8000145c:	86a6                	mv	a3,s1
    8000145e:	6605                	lui	a2,0x1
    80001460:	85ca                	mv	a1,s2
    80001462:	8556                	mv	a0,s5
    80001464:	00000097          	auipc	ra,0x0
    80001468:	c3a080e7          	jalr	-966(ra) # 8000109e <mappages>
    8000146c:	e90d                	bnez	a0,8000149e <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000146e:	6785                	lui	a5,0x1
    80001470:	993e                	add	s2,s2,a5
    80001472:	fd4968e3          	bltu	s2,s4,80001442 <uvmalloc+0x32>
  return newsz;
    80001476:	8552                	mv	a0,s4
    80001478:	a809                	j	8000148a <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000147a:	864e                	mv	a2,s3
    8000147c:	85ca                	mv	a1,s2
    8000147e:	8556                	mv	a0,s5
    80001480:	00000097          	auipc	ra,0x0
    80001484:	f48080e7          	jalr	-184(ra) # 800013c8 <uvmdealloc>
      return 0;
    80001488:	4501                	li	a0,0
}
    8000148a:	70e2                	ld	ra,56(sp)
    8000148c:	7442                	ld	s0,48(sp)
    8000148e:	74a2                	ld	s1,40(sp)
    80001490:	7902                	ld	s2,32(sp)
    80001492:	69e2                	ld	s3,24(sp)
    80001494:	6a42                	ld	s4,16(sp)
    80001496:	6aa2                	ld	s5,8(sp)
    80001498:	6b02                	ld	s6,0(sp)
    8000149a:	6121                	addi	sp,sp,64
    8000149c:	8082                	ret
      kfree(mem);
    8000149e:	8526                	mv	a0,s1
    800014a0:	fffff097          	auipc	ra,0xfffff
    800014a4:	54a080e7          	jalr	1354(ra) # 800009ea <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a8:	864e                	mv	a2,s3
    800014aa:	85ca                	mv	a1,s2
    800014ac:	8556                	mv	a0,s5
    800014ae:	00000097          	auipc	ra,0x0
    800014b2:	f1a080e7          	jalr	-230(ra) # 800013c8 <uvmdealloc>
      return 0;
    800014b6:	4501                	li	a0,0
    800014b8:	bfc9                	j	8000148a <uvmalloc+0x7a>
    return oldsz;
    800014ba:	852e                	mv	a0,a1
}
    800014bc:	8082                	ret
  return newsz;
    800014be:	8532                	mv	a0,a2
    800014c0:	b7e9                	j	8000148a <uvmalloc+0x7a>

00000000800014c2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014c2:	7179                	addi	sp,sp,-48
    800014c4:	f406                	sd	ra,40(sp)
    800014c6:	f022                	sd	s0,32(sp)
    800014c8:	ec26                	sd	s1,24(sp)
    800014ca:	e84a                	sd	s2,16(sp)
    800014cc:	e44e                	sd	s3,8(sp)
    800014ce:	e052                	sd	s4,0(sp)
    800014d0:	1800                	addi	s0,sp,48
    800014d2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014d4:	84aa                	mv	s1,a0
    800014d6:	6905                	lui	s2,0x1
    800014d8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014da:	4985                	li	s3,1
    800014dc:	a821                	j	800014f4 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014de:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014e0:	0532                	slli	a0,a0,0xc
    800014e2:	00000097          	auipc	ra,0x0
    800014e6:	fe0080e7          	jalr	-32(ra) # 800014c2 <freewalk>
      pagetable[i] = 0;
    800014ea:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014ee:	04a1                	addi	s1,s1,8
    800014f0:	03248163          	beq	s1,s2,80001512 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014f4:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f6:	00f57793          	andi	a5,a0,15
    800014fa:	ff3782e3          	beq	a5,s3,800014de <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014fe:	8905                	andi	a0,a0,1
    80001500:	d57d                	beqz	a0,800014ee <freewalk+0x2c>
      panic("freewalk: leaf");
    80001502:	00007517          	auipc	a0,0x7
    80001506:	c7650513          	addi	a0,a0,-906 # 80008178 <digits+0x138>
    8000150a:	fffff097          	auipc	ra,0xfffff
    8000150e:	034080e7          	jalr	52(ra) # 8000053e <panic>
    }
  }
  kfree((void*)pagetable);
    80001512:	8552                	mv	a0,s4
    80001514:	fffff097          	auipc	ra,0xfffff
    80001518:	4d6080e7          	jalr	1238(ra) # 800009ea <kfree>
}
    8000151c:	70a2                	ld	ra,40(sp)
    8000151e:	7402                	ld	s0,32(sp)
    80001520:	64e2                	ld	s1,24(sp)
    80001522:	6942                	ld	s2,16(sp)
    80001524:	69a2                	ld	s3,8(sp)
    80001526:	6a02                	ld	s4,0(sp)
    80001528:	6145                	addi	sp,sp,48
    8000152a:	8082                	ret

000000008000152c <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000152c:	1101                	addi	sp,sp,-32
    8000152e:	ec06                	sd	ra,24(sp)
    80001530:	e822                	sd	s0,16(sp)
    80001532:	e426                	sd	s1,8(sp)
    80001534:	1000                	addi	s0,sp,32
    80001536:	84aa                	mv	s1,a0
  if(sz > 0)
    80001538:	e999                	bnez	a1,8000154e <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000153a:	8526                	mv	a0,s1
    8000153c:	00000097          	auipc	ra,0x0
    80001540:	f86080e7          	jalr	-122(ra) # 800014c2 <freewalk>
}
    80001544:	60e2                	ld	ra,24(sp)
    80001546:	6442                	ld	s0,16(sp)
    80001548:	64a2                	ld	s1,8(sp)
    8000154a:	6105                	addi	sp,sp,32
    8000154c:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000154e:	6605                	lui	a2,0x1
    80001550:	167d                	addi	a2,a2,-1
    80001552:	962e                	add	a2,a2,a1
    80001554:	4685                	li	a3,1
    80001556:	8231                	srli	a2,a2,0xc
    80001558:	4581                	li	a1,0
    8000155a:	00000097          	auipc	ra,0x0
    8000155e:	d0a080e7          	jalr	-758(ra) # 80001264 <uvmunmap>
    80001562:	bfe1                	j	8000153a <uvmfree+0xe>

0000000080001564 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001564:	c679                	beqz	a2,80001632 <uvmcopy+0xce>
{
    80001566:	715d                	addi	sp,sp,-80
    80001568:	e486                	sd	ra,72(sp)
    8000156a:	e0a2                	sd	s0,64(sp)
    8000156c:	fc26                	sd	s1,56(sp)
    8000156e:	f84a                	sd	s2,48(sp)
    80001570:	f44e                	sd	s3,40(sp)
    80001572:	f052                	sd	s4,32(sp)
    80001574:	ec56                	sd	s5,24(sp)
    80001576:	e85a                	sd	s6,16(sp)
    80001578:	e45e                	sd	s7,8(sp)
    8000157a:	0880                	addi	s0,sp,80
    8000157c:	8b2a                	mv	s6,a0
    8000157e:	8aae                	mv	s5,a1
    80001580:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001582:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001584:	4601                	li	a2,0
    80001586:	85ce                	mv	a1,s3
    80001588:	855a                	mv	a0,s6
    8000158a:	00000097          	auipc	ra,0x0
    8000158e:	a2c080e7          	jalr	-1492(ra) # 80000fb6 <walk>
    80001592:	c531                	beqz	a0,800015de <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001594:	6118                	ld	a4,0(a0)
    80001596:	00177793          	andi	a5,a4,1
    8000159a:	cbb1                	beqz	a5,800015ee <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000159c:	00a75593          	srli	a1,a4,0xa
    800015a0:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a4:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015a8:	fffff097          	auipc	ra,0xfffff
    800015ac:	53e080e7          	jalr	1342(ra) # 80000ae6 <kalloc>
    800015b0:	892a                	mv	s2,a0
    800015b2:	c939                	beqz	a0,80001608 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b4:	6605                	lui	a2,0x1
    800015b6:	85de                	mv	a1,s7
    800015b8:	fffff097          	auipc	ra,0xfffff
    800015bc:	776080e7          	jalr	1910(ra) # 80000d2e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015c0:	8726                	mv	a4,s1
    800015c2:	86ca                	mv	a3,s2
    800015c4:	6605                	lui	a2,0x1
    800015c6:	85ce                	mv	a1,s3
    800015c8:	8556                	mv	a0,s5
    800015ca:	00000097          	auipc	ra,0x0
    800015ce:	ad4080e7          	jalr	-1324(ra) # 8000109e <mappages>
    800015d2:	e515                	bnez	a0,800015fe <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d4:	6785                	lui	a5,0x1
    800015d6:	99be                	add	s3,s3,a5
    800015d8:	fb49e6e3          	bltu	s3,s4,80001584 <uvmcopy+0x20>
    800015dc:	a081                	j	8000161c <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015de:	00007517          	auipc	a0,0x7
    800015e2:	baa50513          	addi	a0,a0,-1110 # 80008188 <digits+0x148>
    800015e6:	fffff097          	auipc	ra,0xfffff
    800015ea:	f58080e7          	jalr	-168(ra) # 8000053e <panic>
      panic("uvmcopy: page not present");
    800015ee:	00007517          	auipc	a0,0x7
    800015f2:	bba50513          	addi	a0,a0,-1094 # 800081a8 <digits+0x168>
    800015f6:	fffff097          	auipc	ra,0xfffff
    800015fa:	f48080e7          	jalr	-184(ra) # 8000053e <panic>
      kfree(mem);
    800015fe:	854a                	mv	a0,s2
    80001600:	fffff097          	auipc	ra,0xfffff
    80001604:	3ea080e7          	jalr	1002(ra) # 800009ea <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001608:	4685                	li	a3,1
    8000160a:	00c9d613          	srli	a2,s3,0xc
    8000160e:	4581                	li	a1,0
    80001610:	8556                	mv	a0,s5
    80001612:	00000097          	auipc	ra,0x0
    80001616:	c52080e7          	jalr	-942(ra) # 80001264 <uvmunmap>
  return -1;
    8000161a:	557d                	li	a0,-1
}
    8000161c:	60a6                	ld	ra,72(sp)
    8000161e:	6406                	ld	s0,64(sp)
    80001620:	74e2                	ld	s1,56(sp)
    80001622:	7942                	ld	s2,48(sp)
    80001624:	79a2                	ld	s3,40(sp)
    80001626:	7a02                	ld	s4,32(sp)
    80001628:	6ae2                	ld	s5,24(sp)
    8000162a:	6b42                	ld	s6,16(sp)
    8000162c:	6ba2                	ld	s7,8(sp)
    8000162e:	6161                	addi	sp,sp,80
    80001630:	8082                	ret
  return 0;
    80001632:	4501                	li	a0,0
}
    80001634:	8082                	ret

0000000080001636 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001636:	1141                	addi	sp,sp,-16
    80001638:	e406                	sd	ra,8(sp)
    8000163a:	e022                	sd	s0,0(sp)
    8000163c:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000163e:	4601                	li	a2,0
    80001640:	00000097          	auipc	ra,0x0
    80001644:	976080e7          	jalr	-1674(ra) # 80000fb6 <walk>
  if(pte == 0)
    80001648:	c901                	beqz	a0,80001658 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000164a:	611c                	ld	a5,0(a0)
    8000164c:	9bbd                	andi	a5,a5,-17
    8000164e:	e11c                	sd	a5,0(a0)
}
    80001650:	60a2                	ld	ra,8(sp)
    80001652:	6402                	ld	s0,0(sp)
    80001654:	0141                	addi	sp,sp,16
    80001656:	8082                	ret
    panic("uvmclear");
    80001658:	00007517          	auipc	a0,0x7
    8000165c:	b7050513          	addi	a0,a0,-1168 # 800081c8 <digits+0x188>
    80001660:	fffff097          	auipc	ra,0xfffff
    80001664:	ede080e7          	jalr	-290(ra) # 8000053e <panic>

0000000080001668 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001668:	c6bd                	beqz	a3,800016d6 <copyout+0x6e>
{
    8000166a:	715d                	addi	sp,sp,-80
    8000166c:	e486                	sd	ra,72(sp)
    8000166e:	e0a2                	sd	s0,64(sp)
    80001670:	fc26                	sd	s1,56(sp)
    80001672:	f84a                	sd	s2,48(sp)
    80001674:	f44e                	sd	s3,40(sp)
    80001676:	f052                	sd	s4,32(sp)
    80001678:	ec56                	sd	s5,24(sp)
    8000167a:	e85a                	sd	s6,16(sp)
    8000167c:	e45e                	sd	s7,8(sp)
    8000167e:	e062                	sd	s8,0(sp)
    80001680:	0880                	addi	s0,sp,80
    80001682:	8b2a                	mv	s6,a0
    80001684:	8c2e                	mv	s8,a1
    80001686:	8a32                	mv	s4,a2
    80001688:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000168a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000168c:	6a85                	lui	s5,0x1
    8000168e:	a015                	j	800016b2 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001690:	9562                	add	a0,a0,s8
    80001692:	0004861b          	sext.w	a2,s1
    80001696:	85d2                	mv	a1,s4
    80001698:	41250533          	sub	a0,a0,s2
    8000169c:	fffff097          	auipc	ra,0xfffff
    800016a0:	692080e7          	jalr	1682(ra) # 80000d2e <memmove>

    len -= n;
    800016a4:	409989b3          	sub	s3,s3,s1
    src += n;
    800016a8:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016aa:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016ae:	02098263          	beqz	s3,800016d2 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b2:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016b6:	85ca                	mv	a1,s2
    800016b8:	855a                	mv	a0,s6
    800016ba:	00000097          	auipc	ra,0x0
    800016be:	9a2080e7          	jalr	-1630(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800016c2:	cd01                	beqz	a0,800016da <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c4:	418904b3          	sub	s1,s2,s8
    800016c8:	94d6                	add	s1,s1,s5
    if(n > len)
    800016ca:	fc99f3e3          	bgeu	s3,s1,80001690 <copyout+0x28>
    800016ce:	84ce                	mv	s1,s3
    800016d0:	b7c1                	j	80001690 <copyout+0x28>
  }
  return 0;
    800016d2:	4501                	li	a0,0
    800016d4:	a021                	j	800016dc <copyout+0x74>
    800016d6:	4501                	li	a0,0
}
    800016d8:	8082                	ret
      return -1;
    800016da:	557d                	li	a0,-1
}
    800016dc:	60a6                	ld	ra,72(sp)
    800016de:	6406                	ld	s0,64(sp)
    800016e0:	74e2                	ld	s1,56(sp)
    800016e2:	7942                	ld	s2,48(sp)
    800016e4:	79a2                	ld	s3,40(sp)
    800016e6:	7a02                	ld	s4,32(sp)
    800016e8:	6ae2                	ld	s5,24(sp)
    800016ea:	6b42                	ld	s6,16(sp)
    800016ec:	6ba2                	ld	s7,8(sp)
    800016ee:	6c02                	ld	s8,0(sp)
    800016f0:	6161                	addi	sp,sp,80
    800016f2:	8082                	ret

00000000800016f4 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f4:	caa5                	beqz	a3,80001764 <copyin+0x70>
{
    800016f6:	715d                	addi	sp,sp,-80
    800016f8:	e486                	sd	ra,72(sp)
    800016fa:	e0a2                	sd	s0,64(sp)
    800016fc:	fc26                	sd	s1,56(sp)
    800016fe:	f84a                	sd	s2,48(sp)
    80001700:	f44e                	sd	s3,40(sp)
    80001702:	f052                	sd	s4,32(sp)
    80001704:	ec56                	sd	s5,24(sp)
    80001706:	e85a                	sd	s6,16(sp)
    80001708:	e45e                	sd	s7,8(sp)
    8000170a:	e062                	sd	s8,0(sp)
    8000170c:	0880                	addi	s0,sp,80
    8000170e:	8b2a                	mv	s6,a0
    80001710:	8a2e                	mv	s4,a1
    80001712:	8c32                	mv	s8,a2
    80001714:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001716:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001718:	6a85                	lui	s5,0x1
    8000171a:	a01d                	j	80001740 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000171c:	018505b3          	add	a1,a0,s8
    80001720:	0004861b          	sext.w	a2,s1
    80001724:	412585b3          	sub	a1,a1,s2
    80001728:	8552                	mv	a0,s4
    8000172a:	fffff097          	auipc	ra,0xfffff
    8000172e:	604080e7          	jalr	1540(ra) # 80000d2e <memmove>

    len -= n;
    80001732:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001736:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001738:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000173c:	02098263          	beqz	s3,80001760 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001740:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001744:	85ca                	mv	a1,s2
    80001746:	855a                	mv	a0,s6
    80001748:	00000097          	auipc	ra,0x0
    8000174c:	914080e7          	jalr	-1772(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    80001750:	cd01                	beqz	a0,80001768 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001752:	418904b3          	sub	s1,s2,s8
    80001756:	94d6                	add	s1,s1,s5
    if(n > len)
    80001758:	fc99f2e3          	bgeu	s3,s1,8000171c <copyin+0x28>
    8000175c:	84ce                	mv	s1,s3
    8000175e:	bf7d                	j	8000171c <copyin+0x28>
  }
  return 0;
    80001760:	4501                	li	a0,0
    80001762:	a021                	j	8000176a <copyin+0x76>
    80001764:	4501                	li	a0,0
}
    80001766:	8082                	ret
      return -1;
    80001768:	557d                	li	a0,-1
}
    8000176a:	60a6                	ld	ra,72(sp)
    8000176c:	6406                	ld	s0,64(sp)
    8000176e:	74e2                	ld	s1,56(sp)
    80001770:	7942                	ld	s2,48(sp)
    80001772:	79a2                	ld	s3,40(sp)
    80001774:	7a02                	ld	s4,32(sp)
    80001776:	6ae2                	ld	s5,24(sp)
    80001778:	6b42                	ld	s6,16(sp)
    8000177a:	6ba2                	ld	s7,8(sp)
    8000177c:	6c02                	ld	s8,0(sp)
    8000177e:	6161                	addi	sp,sp,80
    80001780:	8082                	ret

0000000080001782 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001782:	c6c5                	beqz	a3,8000182a <copyinstr+0xa8>
{
    80001784:	715d                	addi	sp,sp,-80
    80001786:	e486                	sd	ra,72(sp)
    80001788:	e0a2                	sd	s0,64(sp)
    8000178a:	fc26                	sd	s1,56(sp)
    8000178c:	f84a                	sd	s2,48(sp)
    8000178e:	f44e                	sd	s3,40(sp)
    80001790:	f052                	sd	s4,32(sp)
    80001792:	ec56                	sd	s5,24(sp)
    80001794:	e85a                	sd	s6,16(sp)
    80001796:	e45e                	sd	s7,8(sp)
    80001798:	0880                	addi	s0,sp,80
    8000179a:	8a2a                	mv	s4,a0
    8000179c:	8b2e                	mv	s6,a1
    8000179e:	8bb2                	mv	s7,a2
    800017a0:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a2:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a4:	6985                	lui	s3,0x1
    800017a6:	a035                	j	800017d2 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017a8:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017ac:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017ae:	0017b793          	seqz	a5,a5
    800017b2:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b6:	60a6                	ld	ra,72(sp)
    800017b8:	6406                	ld	s0,64(sp)
    800017ba:	74e2                	ld	s1,56(sp)
    800017bc:	7942                	ld	s2,48(sp)
    800017be:	79a2                	ld	s3,40(sp)
    800017c0:	7a02                	ld	s4,32(sp)
    800017c2:	6ae2                	ld	s5,24(sp)
    800017c4:	6b42                	ld	s6,16(sp)
    800017c6:	6ba2                	ld	s7,8(sp)
    800017c8:	6161                	addi	sp,sp,80
    800017ca:	8082                	ret
    srcva = va0 + PGSIZE;
    800017cc:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d0:	c8a9                	beqz	s1,80001822 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017d2:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d6:	85ca                	mv	a1,s2
    800017d8:	8552                	mv	a0,s4
    800017da:	00000097          	auipc	ra,0x0
    800017de:	882080e7          	jalr	-1918(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800017e2:	c131                	beqz	a0,80001826 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017e4:	41790833          	sub	a6,s2,s7
    800017e8:	984e                	add	a6,a6,s3
    if(n > max)
    800017ea:	0104f363          	bgeu	s1,a6,800017f0 <copyinstr+0x6e>
    800017ee:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f0:	955e                	add	a0,a0,s7
    800017f2:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f6:	fc080be3          	beqz	a6,800017cc <copyinstr+0x4a>
    800017fa:	985a                	add	a6,a6,s6
    800017fc:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017fe:	41650633          	sub	a2,a0,s6
    80001802:	14fd                	addi	s1,s1,-1
    80001804:	9b26                	add	s6,s6,s1
    80001806:	00f60733          	add	a4,a2,a5
    8000180a:	00074703          	lbu	a4,0(a4)
    8000180e:	df49                	beqz	a4,800017a8 <copyinstr+0x26>
        *dst = *p;
    80001810:	00e78023          	sb	a4,0(a5)
      --max;
    80001814:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001818:	0785                	addi	a5,a5,1
    while(n > 0){
    8000181a:	ff0796e3          	bne	a5,a6,80001806 <copyinstr+0x84>
      dst++;
    8000181e:	8b42                	mv	s6,a6
    80001820:	b775                	j	800017cc <copyinstr+0x4a>
    80001822:	4781                	li	a5,0
    80001824:	b769                	j	800017ae <copyinstr+0x2c>
      return -1;
    80001826:	557d                	li	a0,-1
    80001828:	b779                	j	800017b6 <copyinstr+0x34>
  int got_null = 0;
    8000182a:	4781                	li	a5,0
  if(got_null){
    8000182c:	0017b793          	seqz	a5,a5
    80001830:	40f00533          	neg	a0,a5
}
    80001834:	8082                	ret

0000000080001836 <proc_mapstacks>:
// }
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    80001836:	7139                	addi	sp,sp,-64
    80001838:	fc06                	sd	ra,56(sp)
    8000183a:	f822                	sd	s0,48(sp)
    8000183c:	f426                	sd	s1,40(sp)
    8000183e:	f04a                	sd	s2,32(sp)
    80001840:	ec4e                	sd	s3,24(sp)
    80001842:	e852                	sd	s4,16(sp)
    80001844:	e456                	sd	s5,8(sp)
    80001846:	e05a                	sd	s6,0(sp)
    80001848:	0080                	addi	s0,sp,64
    8000184a:	89aa                	mv	s3,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000184c:	0000f497          	auipc	s1,0xf
    80001850:	76448493          	addi	s1,s1,1892 # 80010fb0 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001854:	8b26                	mv	s6,s1
    80001856:	00006a97          	auipc	s5,0x6
    8000185a:	7aaa8a93          	addi	s5,s5,1962 # 80008000 <etext>
    8000185e:	04000937          	lui	s2,0x4000
    80001862:	197d                	addi	s2,s2,-1
    80001864:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001866:	00016a17          	auipc	s4,0x16
    8000186a:	14aa0a13          	addi	s4,s4,330 # 800179b0 <tickslock>
    char *pa = kalloc();
    8000186e:	fffff097          	auipc	ra,0xfffff
    80001872:	278080e7          	jalr	632(ra) # 80000ae6 <kalloc>
    80001876:	862a                	mv	a2,a0
    if (pa == 0)
    80001878:	c131                	beqz	a0,800018bc <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    8000187a:	416485b3          	sub	a1,s1,s6
    8000187e:	858d                	srai	a1,a1,0x3
    80001880:	000ab783          	ld	a5,0(s5)
    80001884:	02f585b3          	mul	a1,a1,a5
    80001888:	2585                	addiw	a1,a1,1
    8000188a:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000188e:	4719                	li	a4,6
    80001890:	6685                	lui	a3,0x1
    80001892:	40b905b3          	sub	a1,s2,a1
    80001896:	854e                	mv	a0,s3
    80001898:	00000097          	auipc	ra,0x0
    8000189c:	8a6080e7          	jalr	-1882(ra) # 8000113e <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    800018a0:	1a848493          	addi	s1,s1,424
    800018a4:	fd4495e3          	bne	s1,s4,8000186e <proc_mapstacks+0x38>
  }
}
    800018a8:	70e2                	ld	ra,56(sp)
    800018aa:	7442                	ld	s0,48(sp)
    800018ac:	74a2                	ld	s1,40(sp)
    800018ae:	7902                	ld	s2,32(sp)
    800018b0:	69e2                	ld	s3,24(sp)
    800018b2:	6a42                	ld	s4,16(sp)
    800018b4:	6aa2                	ld	s5,8(sp)
    800018b6:	6b02                	ld	s6,0(sp)
    800018b8:	6121                	addi	sp,sp,64
    800018ba:	8082                	ret
      panic("kalloc");
    800018bc:	00007517          	auipc	a0,0x7
    800018c0:	91c50513          	addi	a0,a0,-1764 # 800081d8 <digits+0x198>
    800018c4:	fffff097          	auipc	ra,0xfffff
    800018c8:	c7a080e7          	jalr	-902(ra) # 8000053e <panic>

00000000800018cc <procinit>:

// initialize the proc table.
void procinit(void)
{
    800018cc:	715d                	addi	sp,sp,-80
    800018ce:	e486                	sd	ra,72(sp)
    800018d0:	e0a2                	sd	s0,64(sp)
    800018d2:	fc26                	sd	s1,56(sp)
    800018d4:	f84a                	sd	s2,48(sp)
    800018d6:	f44e                	sd	s3,40(sp)
    800018d8:	f052                	sd	s4,32(sp)
    800018da:	ec56                	sd	s5,24(sp)
    800018dc:	e85a                	sd	s6,16(sp)
    800018de:	e45e                	sd	s7,8(sp)
    800018e0:	0880                	addi	s0,sp,80
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    800018e2:	00007597          	auipc	a1,0x7
    800018e6:	8fe58593          	addi	a1,a1,-1794 # 800081e0 <digits+0x1a0>
    800018ea:	0000f517          	auipc	a0,0xf
    800018ee:	29650513          	addi	a0,a0,662 # 80010b80 <pid_lock>
    800018f2:	fffff097          	auipc	ra,0xfffff
    800018f6:	254080e7          	jalr	596(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018fa:	00007597          	auipc	a1,0x7
    800018fe:	8ee58593          	addi	a1,a1,-1810 # 800081e8 <digits+0x1a8>
    80001902:	0000f517          	auipc	a0,0xf
    80001906:	29650513          	addi	a0,a0,662 # 80010b98 <wait_lock>
    8000190a:	fffff097          	auipc	ra,0xfffff
    8000190e:	23c080e7          	jalr	572(ra) # 80000b46 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001912:	0000f497          	auipc	s1,0xf
    80001916:	69e48493          	addi	s1,s1,1694 # 80010fb0 <proc>
  {
    initlock(&p->lock, "proc");
    8000191a:	00007b97          	auipc	s7,0x7
    8000191e:	8deb8b93          	addi	s7,s7,-1826 # 800081f8 <digits+0x1b8>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001922:	8b26                	mv	s6,s1
    80001924:	00006a97          	auipc	s5,0x6
    80001928:	6dca8a93          	addi	s5,s5,1756 # 80008000 <etext>
    8000192c:	04000937          	lui	s2,0x4000
    80001930:	197d                	addi	s2,s2,-1
    80001932:	0932                	slli	s2,s2,0xc
    p->accumulator = 0;
    p->ps_priority = 5;
    80001934:	4a15                	li	s4,5
  for (p = proc; p < &proc[NPROC]; p++)
    80001936:	00016997          	auipc	s3,0x16
    8000193a:	07a98993          	addi	s3,s3,122 # 800179b0 <tickslock>
    initlock(&p->lock, "proc");
    8000193e:	85de                	mv	a1,s7
    80001940:	8526                	mv	a0,s1
    80001942:	fffff097          	auipc	ra,0xfffff
    80001946:	204080e7          	jalr	516(ra) # 80000b46 <initlock>
    p->state = UNUSED;
    8000194a:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    8000194e:	416487b3          	sub	a5,s1,s6
    80001952:	878d                	srai	a5,a5,0x3
    80001954:	000ab703          	ld	a4,0(s5)
    80001958:	02e787b3          	mul	a5,a5,a4
    8000195c:	2785                	addiw	a5,a5,1
    8000195e:	00d7979b          	slliw	a5,a5,0xd
    80001962:	40f907b3          	sub	a5,s2,a5
    80001966:	e0dc                	sd	a5,128(s1)
    p->accumulator = 0;
    80001968:	0604b023          	sd	zero,96(s1)
    p->ps_priority = 5;
    8000196c:	0744b423          	sd	s4,104(s1)
    p->cfs_priority = 0;
    80001970:	0604a823          	sw	zero,112(s1)
    p->rtime = 0;
    80001974:	0604aa23          	sw	zero,116(s1)
    p->retime = 0;
    80001978:	0604ae23          	sw	zero,124(s1)
    p->stime = 0;
    8000197c:	0604ac23          	sw	zero,120(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001980:	1a848493          	addi	s1,s1,424
    80001984:	fb349de3          	bne	s1,s3,8000193e <procinit+0x72>
  }
}
    80001988:	60a6                	ld	ra,72(sp)
    8000198a:	6406                	ld	s0,64(sp)
    8000198c:	74e2                	ld	s1,56(sp)
    8000198e:	7942                	ld	s2,48(sp)
    80001990:	79a2                	ld	s3,40(sp)
    80001992:	7a02                	ld	s4,32(sp)
    80001994:	6ae2                	ld	s5,24(sp)
    80001996:	6b42                	ld	s6,16(sp)
    80001998:	6ba2                	ld	s7,8(sp)
    8000199a:	6161                	addi	sp,sp,80
    8000199c:	8082                	ret

000000008000199e <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    8000199e:	1141                	addi	sp,sp,-16
    800019a0:	e422                	sd	s0,8(sp)
    800019a2:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019a4:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800019a6:	2501                	sext.w	a0,a0
    800019a8:	6422                	ld	s0,8(sp)
    800019aa:	0141                	addi	sp,sp,16
    800019ac:	8082                	ret

00000000800019ae <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    800019ae:	1141                	addi	sp,sp,-16
    800019b0:	e422                	sd	s0,8(sp)
    800019b2:	0800                	addi	s0,sp,16
    800019b4:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019b6:	2781                	sext.w	a5,a5
    800019b8:	079e                	slli	a5,a5,0x7
  return c;
}
    800019ba:	0000f517          	auipc	a0,0xf
    800019be:	1f650513          	addi	a0,a0,502 # 80010bb0 <cpus>
    800019c2:	953e                	add	a0,a0,a5
    800019c4:	6422                	ld	s0,8(sp)
    800019c6:	0141                	addi	sp,sp,16
    800019c8:	8082                	ret

00000000800019ca <set_policy>:
int set_policy(int policy){
    800019ca:	1141                	addi	sp,sp,-16
    800019cc:	e422                	sd	s0,8(sp)
    800019ce:	0800                	addi	s0,sp,16
  sched_policy=policy;
    800019d0:	00007797          	auipc	a5,0x7
    800019d4:	f2a7ac23          	sw	a0,-200(a5) # 80008908 <sched_policy>
  // printf("policy succecfuly changed in proc.c to%d\n",sched_policy);
  return 0;
}
    800019d8:	4501                	li	a0,0
    800019da:	6422                	ld	s0,8(sp)
    800019dc:	0141                	addi	sp,sp,16
    800019de:	8082                	ret

00000000800019e0 <myproc>:
// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    800019e0:	1101                	addi	sp,sp,-32
    800019e2:	ec06                	sd	ra,24(sp)
    800019e4:	e822                	sd	s0,16(sp)
    800019e6:	e426                	sd	s1,8(sp)
    800019e8:	1000                	addi	s0,sp,32
  push_off();
    800019ea:	fffff097          	auipc	ra,0xfffff
    800019ee:	1a0080e7          	jalr	416(ra) # 80000b8a <push_off>
    800019f2:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019f4:	2781                	sext.w	a5,a5
    800019f6:	079e                	slli	a5,a5,0x7
    800019f8:	0000f717          	auipc	a4,0xf
    800019fc:	18870713          	addi	a4,a4,392 # 80010b80 <pid_lock>
    80001a00:	97ba                	add	a5,a5,a4
    80001a02:	7b84                	ld	s1,48(a5)
  pop_off();
    80001a04:	fffff097          	auipc	ra,0xfffff
    80001a08:	226080e7          	jalr	550(ra) # 80000c2a <pop_off>
  return p;
}
    80001a0c:	8526                	mv	a0,s1
    80001a0e:	60e2                	ld	ra,24(sp)
    80001a10:	6442                	ld	s0,16(sp)
    80001a12:	64a2                	ld	s1,8(sp)
    80001a14:	6105                	addi	sp,sp,32
    80001a16:	8082                	ret

0000000080001a18 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001a18:	1141                	addi	sp,sp,-16
    80001a1a:	e406                	sd	ra,8(sp)
    80001a1c:	e022                	sd	s0,0(sp)
    80001a1e:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a20:	00000097          	auipc	ra,0x0
    80001a24:	fc0080e7          	jalr	-64(ra) # 800019e0 <myproc>
    80001a28:	fffff097          	auipc	ra,0xfffff
    80001a2c:	262080e7          	jalr	610(ra) # 80000c8a <release>

  if (first)
    80001a30:	00007797          	auipc	a5,0x7
    80001a34:	e407a783          	lw	a5,-448(a5) # 80008870 <first.1>
    80001a38:	eb89                	bnez	a5,80001a4a <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a3a:	00001097          	auipc	ra,0x1
    80001a3e:	02e080e7          	jalr	46(ra) # 80002a68 <usertrapret>
}
    80001a42:	60a2                	ld	ra,8(sp)
    80001a44:	6402                	ld	s0,0(sp)
    80001a46:	0141                	addi	sp,sp,16
    80001a48:	8082                	ret
    first = 0;
    80001a4a:	00007797          	auipc	a5,0x7
    80001a4e:	e207a323          	sw	zero,-474(a5) # 80008870 <first.1>
    fsinit(ROOTDEV);
    80001a52:	4505                	li	a0,1
    80001a54:	00002097          	auipc	ra,0x2
    80001a58:	fb4080e7          	jalr	-76(ra) # 80003a08 <fsinit>
    80001a5c:	bff9                	j	80001a3a <forkret+0x22>

0000000080001a5e <allocpid>:
{
    80001a5e:	1101                	addi	sp,sp,-32
    80001a60:	ec06                	sd	ra,24(sp)
    80001a62:	e822                	sd	s0,16(sp)
    80001a64:	e426                	sd	s1,8(sp)
    80001a66:	e04a                	sd	s2,0(sp)
    80001a68:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a6a:	0000f917          	auipc	s2,0xf
    80001a6e:	11690913          	addi	s2,s2,278 # 80010b80 <pid_lock>
    80001a72:	854a                	mv	a0,s2
    80001a74:	fffff097          	auipc	ra,0xfffff
    80001a78:	162080e7          	jalr	354(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001a7c:	00007797          	auipc	a5,0x7
    80001a80:	df878793          	addi	a5,a5,-520 # 80008874 <nextpid>
    80001a84:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a86:	0014871b          	addiw	a4,s1,1
    80001a8a:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a8c:	854a                	mv	a0,s2
    80001a8e:	fffff097          	auipc	ra,0xfffff
    80001a92:	1fc080e7          	jalr	508(ra) # 80000c8a <release>
}
    80001a96:	8526                	mv	a0,s1
    80001a98:	60e2                	ld	ra,24(sp)
    80001a9a:	6442                	ld	s0,16(sp)
    80001a9c:	64a2                	ld	s1,8(sp)
    80001a9e:	6902                	ld	s2,0(sp)
    80001aa0:	6105                	addi	sp,sp,32
    80001aa2:	8082                	ret

0000000080001aa4 <proc_pagetable>:
{
    80001aa4:	1101                	addi	sp,sp,-32
    80001aa6:	ec06                	sd	ra,24(sp)
    80001aa8:	e822                	sd	s0,16(sp)
    80001aaa:	e426                	sd	s1,8(sp)
    80001aac:	e04a                	sd	s2,0(sp)
    80001aae:	1000                	addi	s0,sp,32
    80001ab0:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001ab2:	00000097          	auipc	ra,0x0
    80001ab6:	876080e7          	jalr	-1930(ra) # 80001328 <uvmcreate>
    80001aba:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001abc:	c121                	beqz	a0,80001afc <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001abe:	4729                	li	a4,10
    80001ac0:	00005697          	auipc	a3,0x5
    80001ac4:	54068693          	addi	a3,a3,1344 # 80007000 <_trampoline>
    80001ac8:	6605                	lui	a2,0x1
    80001aca:	040005b7          	lui	a1,0x4000
    80001ace:	15fd                	addi	a1,a1,-1
    80001ad0:	05b2                	slli	a1,a1,0xc
    80001ad2:	fffff097          	auipc	ra,0xfffff
    80001ad6:	5cc080e7          	jalr	1484(ra) # 8000109e <mappages>
    80001ada:	02054863          	bltz	a0,80001b0a <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ade:	4719                	li	a4,6
    80001ae0:	09893683          	ld	a3,152(s2)
    80001ae4:	6605                	lui	a2,0x1
    80001ae6:	020005b7          	lui	a1,0x2000
    80001aea:	15fd                	addi	a1,a1,-1
    80001aec:	05b6                	slli	a1,a1,0xd
    80001aee:	8526                	mv	a0,s1
    80001af0:	fffff097          	auipc	ra,0xfffff
    80001af4:	5ae080e7          	jalr	1454(ra) # 8000109e <mappages>
    80001af8:	02054163          	bltz	a0,80001b1a <proc_pagetable+0x76>
}
    80001afc:	8526                	mv	a0,s1
    80001afe:	60e2                	ld	ra,24(sp)
    80001b00:	6442                	ld	s0,16(sp)
    80001b02:	64a2                	ld	s1,8(sp)
    80001b04:	6902                	ld	s2,0(sp)
    80001b06:	6105                	addi	sp,sp,32
    80001b08:	8082                	ret
    uvmfree(pagetable, 0);
    80001b0a:	4581                	li	a1,0
    80001b0c:	8526                	mv	a0,s1
    80001b0e:	00000097          	auipc	ra,0x0
    80001b12:	a1e080e7          	jalr	-1506(ra) # 8000152c <uvmfree>
    return 0;
    80001b16:	4481                	li	s1,0
    80001b18:	b7d5                	j	80001afc <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b1a:	4681                	li	a3,0
    80001b1c:	4605                	li	a2,1
    80001b1e:	040005b7          	lui	a1,0x4000
    80001b22:	15fd                	addi	a1,a1,-1
    80001b24:	05b2                	slli	a1,a1,0xc
    80001b26:	8526                	mv	a0,s1
    80001b28:	fffff097          	auipc	ra,0xfffff
    80001b2c:	73c080e7          	jalr	1852(ra) # 80001264 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b30:	4581                	li	a1,0
    80001b32:	8526                	mv	a0,s1
    80001b34:	00000097          	auipc	ra,0x0
    80001b38:	9f8080e7          	jalr	-1544(ra) # 8000152c <uvmfree>
    return 0;
    80001b3c:	4481                	li	s1,0
    80001b3e:	bf7d                	j	80001afc <proc_pagetable+0x58>

0000000080001b40 <proc_freepagetable>:
{
    80001b40:	1101                	addi	sp,sp,-32
    80001b42:	ec06                	sd	ra,24(sp)
    80001b44:	e822                	sd	s0,16(sp)
    80001b46:	e426                	sd	s1,8(sp)
    80001b48:	e04a                	sd	s2,0(sp)
    80001b4a:	1000                	addi	s0,sp,32
    80001b4c:	84aa                	mv	s1,a0
    80001b4e:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b50:	4681                	li	a3,0
    80001b52:	4605                	li	a2,1
    80001b54:	040005b7          	lui	a1,0x4000
    80001b58:	15fd                	addi	a1,a1,-1
    80001b5a:	05b2                	slli	a1,a1,0xc
    80001b5c:	fffff097          	auipc	ra,0xfffff
    80001b60:	708080e7          	jalr	1800(ra) # 80001264 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b64:	4681                	li	a3,0
    80001b66:	4605                	li	a2,1
    80001b68:	020005b7          	lui	a1,0x2000
    80001b6c:	15fd                	addi	a1,a1,-1
    80001b6e:	05b6                	slli	a1,a1,0xd
    80001b70:	8526                	mv	a0,s1
    80001b72:	fffff097          	auipc	ra,0xfffff
    80001b76:	6f2080e7          	jalr	1778(ra) # 80001264 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b7a:	85ca                	mv	a1,s2
    80001b7c:	8526                	mv	a0,s1
    80001b7e:	00000097          	auipc	ra,0x0
    80001b82:	9ae080e7          	jalr	-1618(ra) # 8000152c <uvmfree>
}
    80001b86:	60e2                	ld	ra,24(sp)
    80001b88:	6442                	ld	s0,16(sp)
    80001b8a:	64a2                	ld	s1,8(sp)
    80001b8c:	6902                	ld	s2,0(sp)
    80001b8e:	6105                	addi	sp,sp,32
    80001b90:	8082                	ret

0000000080001b92 <freeproc>:
{
    80001b92:	1101                	addi	sp,sp,-32
    80001b94:	ec06                	sd	ra,24(sp)
    80001b96:	e822                	sd	s0,16(sp)
    80001b98:	e426                	sd	s1,8(sp)
    80001b9a:	1000                	addi	s0,sp,32
    80001b9c:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001b9e:	6d48                	ld	a0,152(a0)
    80001ba0:	c509                	beqz	a0,80001baa <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001ba2:	fffff097          	auipc	ra,0xfffff
    80001ba6:	e48080e7          	jalr	-440(ra) # 800009ea <kfree>
  p->trapframe = 0;
    80001baa:	0804bc23          	sd	zero,152(s1)
  if (p->pagetable)
    80001bae:	68c8                	ld	a0,144(s1)
    80001bb0:	c511                	beqz	a0,80001bbc <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001bb2:	64cc                	ld	a1,136(s1)
    80001bb4:	00000097          	auipc	ra,0x0
    80001bb8:	f8c080e7          	jalr	-116(ra) # 80001b40 <proc_freepagetable>
  p->pagetable = 0;
    80001bbc:	0804b823          	sd	zero,144(s1)
  p->sz = 0;
    80001bc0:	0804b423          	sd	zero,136(s1)
  p->pid = 0;
    80001bc4:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001bc8:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001bcc:	18048c23          	sb	zero,408(s1)
  p->chan = 0;
    80001bd0:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bd4:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bd8:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bdc:	0004ac23          	sw	zero,24(s1)
}
    80001be0:	60e2                	ld	ra,24(sp)
    80001be2:	6442                	ld	s0,16(sp)
    80001be4:	64a2                	ld	s1,8(sp)
    80001be6:	6105                	addi	sp,sp,32
    80001be8:	8082                	ret

0000000080001bea <allocproc>:
{
    80001bea:	1101                	addi	sp,sp,-32
    80001bec:	ec06                	sd	ra,24(sp)
    80001bee:	e822                	sd	s0,16(sp)
    80001bf0:	e426                	sd	s1,8(sp)
    80001bf2:	e04a                	sd	s2,0(sp)
    80001bf4:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001bf6:	0000f497          	auipc	s1,0xf
    80001bfa:	3ba48493          	addi	s1,s1,954 # 80010fb0 <proc>
    80001bfe:	00016917          	auipc	s2,0x16
    80001c02:	db290913          	addi	s2,s2,-590 # 800179b0 <tickslock>
    acquire(&p->lock);
    80001c06:	8526                	mv	a0,s1
    80001c08:	fffff097          	auipc	ra,0xfffff
    80001c0c:	fce080e7          	jalr	-50(ra) # 80000bd6 <acquire>
    if (p->state == UNUSED)
    80001c10:	4c9c                	lw	a5,24(s1)
    80001c12:	cf81                	beqz	a5,80001c2a <allocproc+0x40>
      release(&p->lock);
    80001c14:	8526                	mv	a0,s1
    80001c16:	fffff097          	auipc	ra,0xfffff
    80001c1a:	074080e7          	jalr	116(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001c1e:	1a848493          	addi	s1,s1,424
    80001c22:	ff2492e3          	bne	s1,s2,80001c06 <allocproc+0x1c>
  return 0;
    80001c26:	4481                	li	s1,0
    80001c28:	a889                	j	80001c7a <allocproc+0x90>
  p->pid = allocpid();
    80001c2a:	00000097          	auipc	ra,0x0
    80001c2e:	e34080e7          	jalr	-460(ra) # 80001a5e <allocpid>
    80001c32:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c34:	4785                	li	a5,1
    80001c36:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001c38:	fffff097          	auipc	ra,0xfffff
    80001c3c:	eae080e7          	jalr	-338(ra) # 80000ae6 <kalloc>
    80001c40:	892a                	mv	s2,a0
    80001c42:	ecc8                	sd	a0,152(s1)
    80001c44:	c131                	beqz	a0,80001c88 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001c46:	8526                	mv	a0,s1
    80001c48:	00000097          	auipc	ra,0x0
    80001c4c:	e5c080e7          	jalr	-420(ra) # 80001aa4 <proc_pagetable>
    80001c50:	892a                	mv	s2,a0
    80001c52:	e8c8                	sd	a0,144(s1)
  if (p->pagetable == 0)
    80001c54:	c531                	beqz	a0,80001ca0 <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001c56:	07000613          	li	a2,112
    80001c5a:	4581                	li	a1,0
    80001c5c:	0a048513          	addi	a0,s1,160
    80001c60:	fffff097          	auipc	ra,0xfffff
    80001c64:	072080e7          	jalr	114(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001c68:	00000797          	auipc	a5,0x0
    80001c6c:	db078793          	addi	a5,a5,-592 # 80001a18 <forkret>
    80001c70:	f0dc                	sd	a5,160(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c72:	60dc                	ld	a5,128(s1)
    80001c74:	6705                	lui	a4,0x1
    80001c76:	97ba                	add	a5,a5,a4
    80001c78:	f4dc                	sd	a5,168(s1)
}
    80001c7a:	8526                	mv	a0,s1
    80001c7c:	60e2                	ld	ra,24(sp)
    80001c7e:	6442                	ld	s0,16(sp)
    80001c80:	64a2                	ld	s1,8(sp)
    80001c82:	6902                	ld	s2,0(sp)
    80001c84:	6105                	addi	sp,sp,32
    80001c86:	8082                	ret
    freeproc(p);
    80001c88:	8526                	mv	a0,s1
    80001c8a:	00000097          	auipc	ra,0x0
    80001c8e:	f08080e7          	jalr	-248(ra) # 80001b92 <freeproc>
    release(&p->lock);
    80001c92:	8526                	mv	a0,s1
    80001c94:	fffff097          	auipc	ra,0xfffff
    80001c98:	ff6080e7          	jalr	-10(ra) # 80000c8a <release>
    return 0;
    80001c9c:	84ca                	mv	s1,s2
    80001c9e:	bff1                	j	80001c7a <allocproc+0x90>
    freeproc(p);
    80001ca0:	8526                	mv	a0,s1
    80001ca2:	00000097          	auipc	ra,0x0
    80001ca6:	ef0080e7          	jalr	-272(ra) # 80001b92 <freeproc>
    release(&p->lock);
    80001caa:	8526                	mv	a0,s1
    80001cac:	fffff097          	auipc	ra,0xfffff
    80001cb0:	fde080e7          	jalr	-34(ra) # 80000c8a <release>
    return 0;
    80001cb4:	84ca                	mv	s1,s2
    80001cb6:	b7d1                	j	80001c7a <allocproc+0x90>

0000000080001cb8 <userinit>:
{
    80001cb8:	1101                	addi	sp,sp,-32
    80001cba:	ec06                	sd	ra,24(sp)
    80001cbc:	e822                	sd	s0,16(sp)
    80001cbe:	e426                	sd	s1,8(sp)
    80001cc0:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cc2:	00000097          	auipc	ra,0x0
    80001cc6:	f28080e7          	jalr	-216(ra) # 80001bea <allocproc>
    80001cca:	84aa                	mv	s1,a0
  initproc = p;
    80001ccc:	00007797          	auipc	a5,0x7
    80001cd0:	c4a7b223          	sd	a0,-956(a5) # 80008910 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cd4:	03400613          	li	a2,52
    80001cd8:	00007597          	auipc	a1,0x7
    80001cdc:	ba858593          	addi	a1,a1,-1112 # 80008880 <initcode>
    80001ce0:	6948                	ld	a0,144(a0)
    80001ce2:	fffff097          	auipc	ra,0xfffff
    80001ce6:	674080e7          	jalr	1652(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80001cea:	6785                	lui	a5,0x1
    80001cec:	e4dc                	sd	a5,136(s1)
  p->trapframe->epc = 0;     // user program counter
    80001cee:	6cd8                	ld	a4,152(s1)
    80001cf0:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001cf4:	6cd8                	ld	a4,152(s1)
    80001cf6:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cf8:	4641                	li	a2,16
    80001cfa:	00006597          	auipc	a1,0x6
    80001cfe:	50658593          	addi	a1,a1,1286 # 80008200 <digits+0x1c0>
    80001d02:	19848513          	addi	a0,s1,408
    80001d06:	fffff097          	auipc	ra,0xfffff
    80001d0a:	116080e7          	jalr	278(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001d0e:	00006517          	auipc	a0,0x6
    80001d12:	50250513          	addi	a0,a0,1282 # 80008210 <digits+0x1d0>
    80001d16:	00002097          	auipc	ra,0x2
    80001d1a:	714080e7          	jalr	1812(ra) # 8000442a <namei>
    80001d1e:	18a4b823          	sd	a0,400(s1)
  p->state = RUNNABLE;
    80001d22:	478d                	li	a5,3
    80001d24:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d26:	8526                	mv	a0,s1
    80001d28:	fffff097          	auipc	ra,0xfffff
    80001d2c:	f62080e7          	jalr	-158(ra) # 80000c8a <release>
}
    80001d30:	60e2                	ld	ra,24(sp)
    80001d32:	6442                	ld	s0,16(sp)
    80001d34:	64a2                	ld	s1,8(sp)
    80001d36:	6105                	addi	sp,sp,32
    80001d38:	8082                	ret

0000000080001d3a <growproc>:
{
    80001d3a:	1101                	addi	sp,sp,-32
    80001d3c:	ec06                	sd	ra,24(sp)
    80001d3e:	e822                	sd	s0,16(sp)
    80001d40:	e426                	sd	s1,8(sp)
    80001d42:	e04a                	sd	s2,0(sp)
    80001d44:	1000                	addi	s0,sp,32
    80001d46:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d48:	00000097          	auipc	ra,0x0
    80001d4c:	c98080e7          	jalr	-872(ra) # 800019e0 <myproc>
    80001d50:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d52:	654c                	ld	a1,136(a0)
  if (n > 0)
    80001d54:	01204c63          	bgtz	s2,80001d6c <growproc+0x32>
  else if (n < 0)
    80001d58:	02094663          	bltz	s2,80001d84 <growproc+0x4a>
  p->sz = sz;
    80001d5c:	e4cc                	sd	a1,136(s1)
  return 0;
    80001d5e:	4501                	li	a0,0
}
    80001d60:	60e2                	ld	ra,24(sp)
    80001d62:	6442                	ld	s0,16(sp)
    80001d64:	64a2                	ld	s1,8(sp)
    80001d66:	6902                	ld	s2,0(sp)
    80001d68:	6105                	addi	sp,sp,32
    80001d6a:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001d6c:	4691                	li	a3,4
    80001d6e:	00b90633          	add	a2,s2,a1
    80001d72:	6948                	ld	a0,144(a0)
    80001d74:	fffff097          	auipc	ra,0xfffff
    80001d78:	69c080e7          	jalr	1692(ra) # 80001410 <uvmalloc>
    80001d7c:	85aa                	mv	a1,a0
    80001d7e:	fd79                	bnez	a0,80001d5c <growproc+0x22>
      return -1;
    80001d80:	557d                	li	a0,-1
    80001d82:	bff9                	j	80001d60 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d84:	00b90633          	add	a2,s2,a1
    80001d88:	6948                	ld	a0,144(a0)
    80001d8a:	fffff097          	auipc	ra,0xfffff
    80001d8e:	63e080e7          	jalr	1598(ra) # 800013c8 <uvmdealloc>
    80001d92:	85aa                	mv	a1,a0
    80001d94:	b7e1                	j	80001d5c <growproc+0x22>

0000000080001d96 <fork>:
{
    80001d96:	7139                	addi	sp,sp,-64
    80001d98:	fc06                	sd	ra,56(sp)
    80001d9a:	f822                	sd	s0,48(sp)
    80001d9c:	f426                	sd	s1,40(sp)
    80001d9e:	f04a                	sd	s2,32(sp)
    80001da0:	ec4e                	sd	s3,24(sp)
    80001da2:	e852                	sd	s4,16(sp)
    80001da4:	e456                	sd	s5,8(sp)
    80001da6:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001da8:	00000097          	auipc	ra,0x0
    80001dac:	c38080e7          	jalr	-968(ra) # 800019e0 <myproc>
    80001db0:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80001db2:	00000097          	auipc	ra,0x0
    80001db6:	e38080e7          	jalr	-456(ra) # 80001bea <allocproc>
    80001dba:	10050c63          	beqz	a0,80001ed2 <fork+0x13c>
    80001dbe:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001dc0:	088ab603          	ld	a2,136(s5)
    80001dc4:	694c                	ld	a1,144(a0)
    80001dc6:	090ab503          	ld	a0,144(s5)
    80001dca:	fffff097          	auipc	ra,0xfffff
    80001dce:	79a080e7          	jalr	1946(ra) # 80001564 <uvmcopy>
    80001dd2:	04054863          	bltz	a0,80001e22 <fork+0x8c>
  np->sz = p->sz;
    80001dd6:	088ab783          	ld	a5,136(s5)
    80001dda:	08fa3423          	sd	a5,136(s4)
  *(np->trapframe) = *(p->trapframe);
    80001dde:	098ab683          	ld	a3,152(s5)
    80001de2:	87b6                	mv	a5,a3
    80001de4:	098a3703          	ld	a4,152(s4)
    80001de8:	12068693          	addi	a3,a3,288
    80001dec:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001df0:	6788                	ld	a0,8(a5)
    80001df2:	6b8c                	ld	a1,16(a5)
    80001df4:	6f90                	ld	a2,24(a5)
    80001df6:	01073023          	sd	a6,0(a4)
    80001dfa:	e708                	sd	a0,8(a4)
    80001dfc:	eb0c                	sd	a1,16(a4)
    80001dfe:	ef10                	sd	a2,24(a4)
    80001e00:	02078793          	addi	a5,a5,32
    80001e04:	02070713          	addi	a4,a4,32
    80001e08:	fed792e3          	bne	a5,a3,80001dec <fork+0x56>
  np->trapframe->a0 = 0;
    80001e0c:	098a3783          	ld	a5,152(s4)
    80001e10:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001e14:	110a8493          	addi	s1,s5,272
    80001e18:	110a0913          	addi	s2,s4,272
    80001e1c:	190a8993          	addi	s3,s5,400
    80001e20:	a00d                	j	80001e42 <fork+0xac>
    freeproc(np);
    80001e22:	8552                	mv	a0,s4
    80001e24:	00000097          	auipc	ra,0x0
    80001e28:	d6e080e7          	jalr	-658(ra) # 80001b92 <freeproc>
    release(&np->lock);
    80001e2c:	8552                	mv	a0,s4
    80001e2e:	fffff097          	auipc	ra,0xfffff
    80001e32:	e5c080e7          	jalr	-420(ra) # 80000c8a <release>
    return -1;
    80001e36:	597d                	li	s2,-1
    80001e38:	a059                	j	80001ebe <fork+0x128>
  for (i = 0; i < NOFILE; i++)
    80001e3a:	04a1                	addi	s1,s1,8
    80001e3c:	0921                	addi	s2,s2,8
    80001e3e:	01348b63          	beq	s1,s3,80001e54 <fork+0xbe>
    if (p->ofile[i])
    80001e42:	6088                	ld	a0,0(s1)
    80001e44:	d97d                	beqz	a0,80001e3a <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e46:	00003097          	auipc	ra,0x3
    80001e4a:	c7a080e7          	jalr	-902(ra) # 80004ac0 <filedup>
    80001e4e:	00a93023          	sd	a0,0(s2)
    80001e52:	b7e5                	j	80001e3a <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e54:	190ab503          	ld	a0,400(s5)
    80001e58:	00002097          	auipc	ra,0x2
    80001e5c:	dee080e7          	jalr	-530(ra) # 80003c46 <idup>
    80001e60:	18aa3823          	sd	a0,400(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e64:	4641                	li	a2,16
    80001e66:	198a8593          	addi	a1,s5,408
    80001e6a:	198a0513          	addi	a0,s4,408
    80001e6e:	fffff097          	auipc	ra,0xfffff
    80001e72:	fae080e7          	jalr	-82(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    80001e76:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e7a:	8552                	mv	a0,s4
    80001e7c:	fffff097          	auipc	ra,0xfffff
    80001e80:	e0e080e7          	jalr	-498(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80001e84:	0000f497          	auipc	s1,0xf
    80001e88:	d1448493          	addi	s1,s1,-748 # 80010b98 <wait_lock>
    80001e8c:	8526                	mv	a0,s1
    80001e8e:	fffff097          	auipc	ra,0xfffff
    80001e92:	d48080e7          	jalr	-696(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001e96:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001e9a:	8526                	mv	a0,s1
    80001e9c:	fffff097          	auipc	ra,0xfffff
    80001ea0:	dee080e7          	jalr	-530(ra) # 80000c8a <release>
  acquire(&np->lock);
    80001ea4:	8552                	mv	a0,s4
    80001ea6:	fffff097          	auipc	ra,0xfffff
    80001eaa:	d30080e7          	jalr	-720(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80001eae:	478d                	li	a5,3
    80001eb0:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001eb4:	8552                	mv	a0,s4
    80001eb6:	fffff097          	auipc	ra,0xfffff
    80001eba:	dd4080e7          	jalr	-556(ra) # 80000c8a <release>
}
    80001ebe:	854a                	mv	a0,s2
    80001ec0:	70e2                	ld	ra,56(sp)
    80001ec2:	7442                	ld	s0,48(sp)
    80001ec4:	74a2                	ld	s1,40(sp)
    80001ec6:	7902                	ld	s2,32(sp)
    80001ec8:	69e2                	ld	s3,24(sp)
    80001eca:	6a42                	ld	s4,16(sp)
    80001ecc:	6aa2                	ld	s5,8(sp)
    80001ece:	6121                	addi	sp,sp,64
    80001ed0:	8082                	ret
    return -1;
    80001ed2:	597d                	li	s2,-1
    80001ed4:	b7ed                	j	80001ebe <fork+0x128>

0000000080001ed6 <get_ps_priority>:
struct proc* get_ps_priority(int id) {
    80001ed6:	7179                	addi	sp,sp,-48
    80001ed8:	f406                	sd	ra,40(sp)
    80001eda:	f022                	sd	s0,32(sp)
    80001edc:	ec26                	sd	s1,24(sp)
    80001ede:	e84a                	sd	s2,16(sp)
    80001ee0:	e44e                	sd	s3,8(sp)
    80001ee2:	e052                	sd	s4,0(sp)
    80001ee4:	1800                	addi	s0,sp,48
    80001ee6:	892a                	mv	s2,a0
  struct proc *toreturn = 0;
    80001ee8:	4a01                	li	s4,0
  for (p = proc; p < &proc[NPROC]; p++) {
    80001eea:	0000f497          	auipc	s1,0xf
    80001eee:	0c648493          	addi	s1,s1,198 # 80010fb0 <proc>
    80001ef2:	00016997          	auipc	s3,0x16
    80001ef6:	abe98993          	addi	s3,s3,-1346 # 800179b0 <tickslock>
    80001efa:	a811                	j	80001f0e <get_ps_priority+0x38>
    release(&p->lock);
    80001efc:	8526                	mv	a0,s1
    80001efe:	fffff097          	auipc	ra,0xfffff
    80001f02:	d8c080e7          	jalr	-628(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001f06:	1a848493          	addi	s1,s1,424
    80001f0a:	01348c63          	beq	s1,s3,80001f22 <get_ps_priority+0x4c>
    acquire(&p->lock);
    80001f0e:	8526                	mv	a0,s1
    80001f10:	fffff097          	auipc	ra,0xfffff
    80001f14:	cc6080e7          	jalr	-826(ra) # 80000bd6 <acquire>
    if (p->pid == id) {
    80001f18:	589c                	lw	a5,48(s1)
    80001f1a:	ff2791e3          	bne	a5,s2,80001efc <get_ps_priority+0x26>
    80001f1e:	8a26                	mv	s4,s1
    80001f20:	bff1                	j	80001efc <get_ps_priority+0x26>
}
    80001f22:	8552                	mv	a0,s4
    80001f24:	70a2                	ld	ra,40(sp)
    80001f26:	7402                	ld	s0,32(sp)
    80001f28:	64e2                	ld	s1,24(sp)
    80001f2a:	6942                	ld	s2,16(sp)
    80001f2c:	69a2                	ld	s3,8(sp)
    80001f2e:	6a02                	ld	s4,0(sp)
    80001f30:	6145                	addi	sp,sp,48
    80001f32:	8082                	ret

0000000080001f34 <scheduler>:
{
    80001f34:	7135                	addi	sp,sp,-160
    80001f36:	ed06                	sd	ra,152(sp)
    80001f38:	e922                	sd	s0,144(sp)
    80001f3a:	e526                	sd	s1,136(sp)
    80001f3c:	e14a                	sd	s2,128(sp)
    80001f3e:	fcce                	sd	s3,120(sp)
    80001f40:	f8d2                	sd	s4,112(sp)
    80001f42:	f4d6                	sd	s5,104(sp)
    80001f44:	f0da                	sd	s6,96(sp)
    80001f46:	ecde                	sd	s7,88(sp)
    80001f48:	e8e2                	sd	s8,80(sp)
    80001f4a:	e4e6                	sd	s9,72(sp)
    80001f4c:	e0ea                	sd	s10,64(sp)
    80001f4e:	fc6e                	sd	s11,56(sp)
    80001f50:	1100                	addi	s0,sp,160
    80001f52:	8492                	mv	s1,tp
  int id = r_tp();
    80001f54:	2481                	sext.w	s1,s1
  initlock(&counter, "counter");
    80001f56:	00006597          	auipc	a1,0x6
    80001f5a:	2c258593          	addi	a1,a1,706 # 80008218 <digits+0x1d8>
    80001f5e:	f7840513          	addi	a0,s0,-136
    80001f62:	fffff097          	auipc	ra,0xfffff
    80001f66:	be4080e7          	jalr	-1052(ra) # 80000b46 <initlock>
            swtch(&c->context, &min_proc->context);
    80001f6a:	00749d13          	slli	s10,s1,0x7
    80001f6e:	0000f797          	auipc	a5,0xf
    80001f72:	c4a78793          	addi	a5,a5,-950 # 80010bb8 <cpus+0x8>
    80001f76:	9d3e                	add	s10,s10,a5
  int decay_factor = 100;
    80001f78:	06400913          	li	s2,100
        min_acc = LLONG_MAX;
    80001f7c:	57fd                	li	a5,-1
    80001f7e:	8385                	srli	a5,a5,0x1
    80001f80:	f6f43023          	sd	a5,-160(s0)
              min_accumulator=min_acc;
    80001f84:	00007d97          	auipc	s11,0x7
    80001f88:	8f4d8d93          	addi	s11,s11,-1804 # 80008878 <min_accumulator>
            c->proc = min_proc;
    80001f8c:	049e                	slli	s1,s1,0x7
    80001f8e:	0000fc17          	auipc	s8,0xf
    80001f92:	bf2c0c13          	addi	s8,s8,-1038 # 80010b80 <pid_lock>
    80001f96:	9c26                	add	s8,s8,s1
    80001f98:	a8e1                	j	80002070 <scheduler+0x13c>
          release(&p->lock);
    80001f9a:	8526                	mv	a0,s1
    80001f9c:	fffff097          	auipc	ra,0xfffff
    80001fa0:	cee080e7          	jalr	-786(ra) # 80000c8a <release>
        for (p = proc; p < &proc[NPROC]; p++)
    80001fa4:	1a848493          	addi	s1,s1,424
    80001fa8:	0d348463          	beq	s1,s3,80002070 <scheduler+0x13c>
          acquire(&p->lock);
    80001fac:	8526                	mv	a0,s1
    80001fae:	fffff097          	auipc	ra,0xfffff
    80001fb2:	c28080e7          	jalr	-984(ra) # 80000bd6 <acquire>
          if (p->state == RUNNABLE)
    80001fb6:	4c9c                	lw	a5,24(s1)
    80001fb8:	ff4791e3          	bne	a5,s4,80001f9a <scheduler+0x66>
            p->state = RUNNING;
    80001fbc:	0154ac23          	sw	s5,24(s1)
            c->proc = p;
    80001fc0:	029c3823          	sd	s1,48(s8)
            swtch(&c->context, &p->context);
    80001fc4:	0a048593          	addi	a1,s1,160
    80001fc8:	856a                	mv	a0,s10
    80001fca:	00001097          	auipc	ra,0x1
    80001fce:	9f4080e7          	jalr	-1548(ra) # 800029be <swtch>
            c->proc = 0;
    80001fd2:	020c3823          	sd	zero,48(s8)
    80001fd6:	b7d1                	j	80001f9a <scheduler+0x66>
        min_acc = LLONG_MAX;
    80001fd8:	f6043b03          	ld	s6,-160(s0)
    proc_counter=0;
    80001fdc:	4a81                	li	s5,0
        min_proc = 0;
    80001fde:	4b81                	li	s7,0
        for (p = proc; p < &proc[NPROC]; p++){
    80001fe0:	0000f497          	auipc	s1,0xf
    80001fe4:	fd048493          	addi	s1,s1,-48 # 80010fb0 <proc>
          if (p->state == RUNNABLE||p->state == RUNNING){
    80001fe8:	4a05                	li	s4,1
        for (p = proc; p < &proc[NPROC]; p++){
    80001fea:	00016997          	auipc	s3,0x16
    80001fee:	9c698993          	addi	s3,s3,-1594 # 800179b0 <tickslock>
    80001ff2:	a831                	j	8000200e <scheduler+0xda>
              min_accumulator=min_acc;
    80001ff4:	00fdb023          	sd	a5,0(s11)
              min_acc= p->accumulator;
    80001ff8:	8b3e                	mv	s6,a5
              min_accumulator=min_acc;
    80001ffa:	8ba6                	mv	s7,s1
          release(&p->lock);
    80001ffc:	8526                	mv	a0,s1
    80001ffe:	fffff097          	auipc	ra,0xfffff
    80002002:	c8c080e7          	jalr	-884(ra) # 80000c8a <release>
        for (p = proc; p < &proc[NPROC]; p++){
    80002006:	1a848493          	addi	s1,s1,424
    8000200a:	03348e63          	beq	s1,s3,80002046 <scheduler+0x112>
          acquire(&p->lock);
    8000200e:	8526                	mv	a0,s1
    80002010:	fffff097          	auipc	ra,0xfffff
    80002014:	bc6080e7          	jalr	-1082(ra) # 80000bd6 <acquire>
          if (p->state == RUNNABLE||p->state == RUNNING){
    80002018:	4c9c                	lw	a5,24(s1)
    8000201a:	37f5                	addiw	a5,a5,-3
    8000201c:	fefa60e3          	bltu	s4,a5,80001ffc <scheduler+0xc8>
            acquire(&counter);
    80002020:	f7840513          	addi	a0,s0,-136
    80002024:	fffff097          	auipc	ra,0xfffff
    80002028:	bb2080e7          	jalr	-1102(ra) # 80000bd6 <acquire>
            proc_counter++;
    8000202c:	2a85                	addiw	s5,s5,1
            release(&counter);
    8000202e:	f7840513          	addi	a0,s0,-136
    80002032:	fffff097          	auipc	ra,0xfffff
    80002036:	c58080e7          	jalr	-936(ra) # 80000c8a <release>
            if ((p->accumulator < min_acc || proc_counter == 0)){ 
    8000203a:	70bc                	ld	a5,96(s1)
    8000203c:	fb67cce3          	blt	a5,s6,80001ff4 <scheduler+0xc0>
    80002040:	fa0a9ee3          	bnez	s5,80001ffc <scheduler+0xc8>
    80002044:	bf45                	j	80001ff4 <scheduler+0xc0>
        if (min_proc != 0){          
    80002046:	020b8563          	beqz	s7,80002070 <scheduler+0x13c>
          acquire(&min_proc->lock);
    8000204a:	84de                	mv	s1,s7
    8000204c:	855e                	mv	a0,s7
    8000204e:	fffff097          	auipc	ra,0xfffff
    80002052:	b88080e7          	jalr	-1144(ra) # 80000bd6 <acquire>
          if (proc_counter == 1){
    80002056:	4785                	li	a5,1
    80002058:	06fa8663          	beq	s5,a5,800020c4 <scheduler+0x190>
          if (min_proc->state == RUNNABLE){
    8000205c:	018ba703          	lw	a4,24(s7)
    80002060:	478d                	li	a5,3
    80002062:	06f70663          	beq	a4,a5,800020ce <scheduler+0x19a>
          release(&min_proc->lock);
    80002066:	8526                	mv	a0,s1
    80002068:	fffff097          	auipc	ra,0xfffff
    8000206c:	c22080e7          	jalr	-990(ra) # 80000c8a <release>
    switch (sched_policy)
    80002070:	00007a17          	auipc	s4,0x7
    80002074:	898a0a13          	addi	s4,s4,-1896 # 80008908 <sched_policy>
    80002078:	4985                	li	s3,1
    8000207a:	4489                	li	s1,2
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000207c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002080:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002084:	10079073          	csrw	sstatus,a5
    acquire(&counter);
    80002088:	f7840513          	addi	a0,s0,-136
    8000208c:	fffff097          	auipc	ra,0xfffff
    80002090:	b4a080e7          	jalr	-1206(ra) # 80000bd6 <acquire>
    release(&counter);
    80002094:	f7840513          	addi	a0,s0,-136
    80002098:	fffff097          	auipc	ra,0xfffff
    8000209c:	bf2080e7          	jalr	-1038(ra) # 80000c8a <release>
    switch (sched_policy)
    800020a0:	000a2783          	lw	a5,0(s4)
    800020a4:	f3378ae3          	beq	a5,s3,80001fd8 <scheduler+0xa4>
    800020a8:	04978263          	beq	a5,s1,800020ec <scheduler+0x1b8>
    800020ac:	fbe1                	bnez	a5,8000207c <scheduler+0x148>
        for (p = proc; p < &proc[NPROC]; p++)
    800020ae:	0000f497          	auipc	s1,0xf
    800020b2:	f0248493          	addi	s1,s1,-254 # 80010fb0 <proc>
          if (p->state == RUNNABLE)
    800020b6:	4a0d                	li	s4,3
            p->state = RUNNING;
    800020b8:	4a91                	li	s5,4
        for (p = proc; p < &proc[NPROC]; p++)
    800020ba:	00016997          	auipc	s3,0x16
    800020be:	8f698993          	addi	s3,s3,-1802 # 800179b0 <tickslock>
    800020c2:	b5ed                	j	80001fac <scheduler+0x78>
            min_proc->accumulator = 0;
    800020c4:	060bb023          	sd	zero,96(s7)
            min_accumulator=0;
    800020c8:	000db023          	sd	zero,0(s11)
    800020cc:	bf41                	j	8000205c <scheduler+0x128>
            min_proc->state = RUNNING;
    800020ce:	4791                	li	a5,4
    800020d0:	00fbac23          	sw	a5,24(s7)
            c->proc = min_proc;
    800020d4:	037c3823          	sd	s7,48(s8)
            swtch(&c->context, &min_proc->context);
    800020d8:	0a0b8593          	addi	a1,s7,160
    800020dc:	856a                	mv	a0,s10
    800020de:	00001097          	auipc	ra,0x1
    800020e2:	8e0080e7          	jalr	-1824(ra) # 800029be <swtch>
            c->proc = 0;
    800020e6:	020c3823          	sd	zero,48(s8)
    800020ea:	bfb5                	j	80002066 <scheduler+0x132>
        min_vruntime = __INT_MAX__;
    800020ec:	80000bb7          	lui	s7,0x80000
    800020f0:	fffbcb93          	not	s7,s7
        min_proc = 0;
    800020f4:	f6043423          	sd	zero,-152(s0)
        for (p = proc; p < &proc[NPROC]; p++)
    800020f8:	0000f497          	auipc	s1,0xf
    800020fc:	eb848493          	addi	s1,s1,-328 # 80010fb0 <proc>
    80002100:	4b05                	li	s6,1
    80002102:	4a89                	li	s5,2
              decay_factor = 125;
    80002104:	07d00c93          	li	s9,125
          if (p->state == RUNNABLE && vruntime < min_vruntime)
    80002108:	4a0d                	li	s4,3
        for (p = proc; p < &proc[NPROC]; p++)
    8000210a:	00016997          	auipc	s3,0x16
    8000210e:	8a698993          	addi	s3,s3,-1882 # 800179b0 <tickslock>
    80002112:	a015                	j	80002136 <scheduler+0x202>
    80002114:	04b00913          	li	s2,75
    80002118:	a815                	j	8000214c <scheduler+0x218>
              decay_factor = 100;
    8000211a:	06400913          	li	s2,100
    8000211e:	a03d                	j	8000214c <scheduler+0x218>
              decay_factor = 125;
    80002120:	8966                	mv	s2,s9
    80002122:	a02d                	j	8000214c <scheduler+0x218>
          release(&p->lock);
    80002124:	8526                	mv	a0,s1
    80002126:	fffff097          	auipc	ra,0xfffff
    8000212a:	b64080e7          	jalr	-1180(ra) # 80000c8a <release>
        for (p = proc; p < &proc[NPROC]; p++)
    8000212e:	1a848493          	addi	s1,s1,424
    80002132:	03348f63          	beq	s1,s3,80002170 <scheduler+0x23c>
          acquire(&p->lock);
    80002136:	8526                	mv	a0,s1
    80002138:	fffff097          	auipc	ra,0xfffff
    8000213c:	a9e080e7          	jalr	-1378(ra) # 80000bd6 <acquire>
          switch (p->cfs_priority)
    80002140:	58bc                	lw	a5,112(s1)
    80002142:	fd678ce3          	beq	a5,s6,8000211a <scheduler+0x1e6>
    80002146:	fd578de3          	beq	a5,s5,80002120 <scheduler+0x1ec>
    8000214a:	d7e9                	beqz	a5,80002114 <scheduler+0x1e0>
          vruntime = decay_factor * ((p->rtime) / (p->rtime + p->stime + p->retime));
    8000214c:	58fc                	lw	a5,116(s1)
    8000214e:	5cb8                	lw	a4,120(s1)
    80002150:	5cf0                	lw	a2,124(s1)
          if (p->state == RUNNABLE && vruntime < min_vruntime)
    80002152:	4c94                	lw	a3,24(s1)
    80002154:	fd4698e3          	bne	a3,s4,80002124 <scheduler+0x1f0>
          vruntime = decay_factor * ((p->rtime) / (p->rtime + p->stime + p->retime));
    80002158:	9f3d                	addw	a4,a4,a5
    8000215a:	9f31                	addw	a4,a4,a2
    8000215c:	02e7c7bb          	divw	a5,a5,a4
    80002160:	032787bb          	mulw	a5,a5,s2
          if (p->state == RUNNABLE && vruntime < min_vruntime)
    80002164:	fd77d0e3          	bge	a5,s7,80002124 <scheduler+0x1f0>
            min_vruntime = vruntime;
    80002168:	8bbe                	mv	s7,a5
          if (p->state == RUNNABLE && vruntime < min_vruntime)
    8000216a:	f6943423          	sd	s1,-152(s0)
    8000216e:	bf5d                	j	80002124 <scheduler+0x1f0>
        if (min_proc != 0)
    80002170:	f6843983          	ld	s3,-152(s0)
    80002174:	ee098ee3          	beqz	s3,80002070 <scheduler+0x13c>
          acquire(&min_proc->lock);
    80002178:	84ce                	mv	s1,s3
    8000217a:	854e                	mv	a0,s3
    8000217c:	fffff097          	auipc	ra,0xfffff
    80002180:	a5a080e7          	jalr	-1446(ra) # 80000bd6 <acquire>
          if (min_proc->state == RUNNABLE)
    80002184:	0189a703          	lw	a4,24(s3)
    80002188:	478d                	li	a5,3
    8000218a:	00f70863          	beq	a4,a5,8000219a <scheduler+0x266>
          release(&min_proc->lock);
    8000218e:	8526                	mv	a0,s1
    80002190:	fffff097          	auipc	ra,0xfffff
    80002194:	afa080e7          	jalr	-1286(ra) # 80000c8a <release>
    80002198:	bde1                	j	80002070 <scheduler+0x13c>
            min_proc->state = RUNNING;
    8000219a:	4791                	li	a5,4
    8000219c:	f6843703          	ld	a4,-152(s0)
    800021a0:	cf1c                	sw	a5,24(a4)
            c->proc = min_proc;
    800021a2:	02ec3823          	sd	a4,48(s8)
            swtch(&c->context, &min_proc->context);
    800021a6:	0a070593          	addi	a1,a4,160
    800021aa:	856a                	mv	a0,s10
    800021ac:	00001097          	auipc	ra,0x1
    800021b0:	812080e7          	jalr	-2030(ra) # 800029be <swtch>
            c->proc = 0;
    800021b4:	020c3823          	sd	zero,48(s8)
    800021b8:	bfd9                	j	8000218e <scheduler+0x25a>

00000000800021ba <sched>:
{
    800021ba:	7179                	addi	sp,sp,-48
    800021bc:	f406                	sd	ra,40(sp)
    800021be:	f022                	sd	s0,32(sp)
    800021c0:	ec26                	sd	s1,24(sp)
    800021c2:	e84a                	sd	s2,16(sp)
    800021c4:	e44e                	sd	s3,8(sp)
    800021c6:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800021c8:	00000097          	auipc	ra,0x0
    800021cc:	818080e7          	jalr	-2024(ra) # 800019e0 <myproc>
    800021d0:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    800021d2:	fffff097          	auipc	ra,0xfffff
    800021d6:	98a080e7          	jalr	-1654(ra) # 80000b5c <holding>
    800021da:	c93d                	beqz	a0,80002250 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800021dc:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    800021de:	2781                	sext.w	a5,a5
    800021e0:	079e                	slli	a5,a5,0x7
    800021e2:	0000f717          	auipc	a4,0xf
    800021e6:	99e70713          	addi	a4,a4,-1634 # 80010b80 <pid_lock>
    800021ea:	97ba                	add	a5,a5,a4
    800021ec:	0a87a703          	lw	a4,168(a5)
    800021f0:	4785                	li	a5,1
    800021f2:	06f71763          	bne	a4,a5,80002260 <sched+0xa6>
  if (p->state == RUNNING)
    800021f6:	4c98                	lw	a4,24(s1)
    800021f8:	4791                	li	a5,4
    800021fa:	06f70b63          	beq	a4,a5,80002270 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800021fe:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002202:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002204:	efb5                	bnez	a5,80002280 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002206:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002208:	0000f917          	auipc	s2,0xf
    8000220c:	97890913          	addi	s2,s2,-1672 # 80010b80 <pid_lock>
    80002210:	2781                	sext.w	a5,a5
    80002212:	079e                	slli	a5,a5,0x7
    80002214:	97ca                	add	a5,a5,s2
    80002216:	0ac7a983          	lw	s3,172(a5)
    8000221a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000221c:	2781                	sext.w	a5,a5
    8000221e:	079e                	slli	a5,a5,0x7
    80002220:	0000f597          	auipc	a1,0xf
    80002224:	99858593          	addi	a1,a1,-1640 # 80010bb8 <cpus+0x8>
    80002228:	95be                	add	a1,a1,a5
    8000222a:	0a048513          	addi	a0,s1,160
    8000222e:	00000097          	auipc	ra,0x0
    80002232:	790080e7          	jalr	1936(ra) # 800029be <swtch>
    80002236:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002238:	2781                	sext.w	a5,a5
    8000223a:	079e                	slli	a5,a5,0x7
    8000223c:	97ca                	add	a5,a5,s2
    8000223e:	0b37a623          	sw	s3,172(a5)
}
    80002242:	70a2                	ld	ra,40(sp)
    80002244:	7402                	ld	s0,32(sp)
    80002246:	64e2                	ld	s1,24(sp)
    80002248:	6942                	ld	s2,16(sp)
    8000224a:	69a2                	ld	s3,8(sp)
    8000224c:	6145                	addi	sp,sp,48
    8000224e:	8082                	ret
    panic("sched p->lock");
    80002250:	00006517          	auipc	a0,0x6
    80002254:	fd050513          	addi	a0,a0,-48 # 80008220 <digits+0x1e0>
    80002258:	ffffe097          	auipc	ra,0xffffe
    8000225c:	2e6080e7          	jalr	742(ra) # 8000053e <panic>
    panic("sched locks");
    80002260:	00006517          	auipc	a0,0x6
    80002264:	fd050513          	addi	a0,a0,-48 # 80008230 <digits+0x1f0>
    80002268:	ffffe097          	auipc	ra,0xffffe
    8000226c:	2d6080e7          	jalr	726(ra) # 8000053e <panic>
    panic("sched running");
    80002270:	00006517          	auipc	a0,0x6
    80002274:	fd050513          	addi	a0,a0,-48 # 80008240 <digits+0x200>
    80002278:	ffffe097          	auipc	ra,0xffffe
    8000227c:	2c6080e7          	jalr	710(ra) # 8000053e <panic>
    panic("sched interruptible");
    80002280:	00006517          	auipc	a0,0x6
    80002284:	fd050513          	addi	a0,a0,-48 # 80008250 <digits+0x210>
    80002288:	ffffe097          	auipc	ra,0xffffe
    8000228c:	2b6080e7          	jalr	694(ra) # 8000053e <panic>

0000000080002290 <yield>:
{
    80002290:	1101                	addi	sp,sp,-32
    80002292:	ec06                	sd	ra,24(sp)
    80002294:	e822                	sd	s0,16(sp)
    80002296:	e426                	sd	s1,8(sp)
    80002298:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000229a:	fffff097          	auipc	ra,0xfffff
    8000229e:	746080e7          	jalr	1862(ra) # 800019e0 <myproc>
    800022a2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022a4:	fffff097          	auipc	ra,0xfffff
    800022a8:	932080e7          	jalr	-1742(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    800022ac:	478d                	li	a5,3
    800022ae:	cc9c                	sw	a5,24(s1)
  sched();
    800022b0:	00000097          	auipc	ra,0x0
    800022b4:	f0a080e7          	jalr	-246(ra) # 800021ba <sched>
  release(&p->lock);
    800022b8:	8526                	mv	a0,s1
    800022ba:	fffff097          	auipc	ra,0xfffff
    800022be:	9d0080e7          	jalr	-1584(ra) # 80000c8a <release>
}
    800022c2:	60e2                	ld	ra,24(sp)
    800022c4:	6442                	ld	s0,16(sp)
    800022c6:	64a2                	ld	s1,8(sp)
    800022c8:	6105                	addi	sp,sp,32
    800022ca:	8082                	ret

00000000800022cc <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    800022cc:	7179                	addi	sp,sp,-48
    800022ce:	f406                	sd	ra,40(sp)
    800022d0:	f022                	sd	s0,32(sp)
    800022d2:	ec26                	sd	s1,24(sp)
    800022d4:	e84a                	sd	s2,16(sp)
    800022d6:	e44e                	sd	s3,8(sp)
    800022d8:	1800                	addi	s0,sp,48
    800022da:	89aa                	mv	s3,a0
    800022dc:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800022de:	fffff097          	auipc	ra,0xfffff
    800022e2:	702080e7          	jalr	1794(ra) # 800019e0 <myproc>
    800022e6:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    800022e8:	fffff097          	auipc	ra,0xfffff
    800022ec:	8ee080e7          	jalr	-1810(ra) # 80000bd6 <acquire>
  release(lk);
    800022f0:	854a                	mv	a0,s2
    800022f2:	fffff097          	auipc	ra,0xfffff
    800022f6:	998080e7          	jalr	-1640(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    800022fa:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800022fe:	4789                	li	a5,2
    80002300:	cc9c                	sw	a5,24(s1)

  sched();
    80002302:	00000097          	auipc	ra,0x0
    80002306:	eb8080e7          	jalr	-328(ra) # 800021ba <sched>

  // Tidy up.
  p->chan = 0;
    8000230a:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000230e:	8526                	mv	a0,s1
    80002310:	fffff097          	auipc	ra,0xfffff
    80002314:	97a080e7          	jalr	-1670(ra) # 80000c8a <release>
  acquire(lk);
    80002318:	854a                	mv	a0,s2
    8000231a:	fffff097          	auipc	ra,0xfffff
    8000231e:	8bc080e7          	jalr	-1860(ra) # 80000bd6 <acquire>
}
    80002322:	70a2                	ld	ra,40(sp)
    80002324:	7402                	ld	s0,32(sp)
    80002326:	64e2                	ld	s1,24(sp)
    80002328:	6942                	ld	s2,16(sp)
    8000232a:	69a2                	ld	s3,8(sp)
    8000232c:	6145                	addi	sp,sp,48
    8000232e:	8082                	ret

0000000080002330 <cfs_update>:

void cfs_update()
{
    80002330:	7139                	addi	sp,sp,-64
    80002332:	fc06                	sd	ra,56(sp)
    80002334:	f822                	sd	s0,48(sp)
    80002336:	f426                	sd	s1,40(sp)
    80002338:	f04a                	sd	s2,32(sp)
    8000233a:	ec4e                	sd	s3,24(sp)
    8000233c:	e852                	sd	s4,16(sp)
    8000233e:	e456                	sd	s5,8(sp)
    80002340:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002342:	fffff097          	auipc	ra,0xfffff
    80002346:	69e080e7          	jalr	1694(ra) # 800019e0 <myproc>

  for (p = proc; p < &proc[NPROC]; p++)
    8000234a:	0000f497          	auipc	s1,0xf
    8000234e:	c6648493          	addi	s1,s1,-922 # 80010fb0 <proc>
  {
    acquire(&p->lock);
    if (p->state == RUNNABLE)
    80002352:	498d                	li	s3,3
    {
      p->retime++;
    }
    else if (p->state == SLEEPING)
    80002354:	4a09                	li	s4,2
    {
      p->stime++;
    }
    else if (p->state == RUNNING)
    80002356:	4a91                	li	s5,4
  for (p = proc; p < &proc[NPROC]; p++)
    80002358:	00015917          	auipc	s2,0x15
    8000235c:	65890913          	addi	s2,s2,1624 # 800179b0 <tickslock>
    80002360:	a829                	j	8000237a <cfs_update+0x4a>
      p->retime++;
    80002362:	5cfc                	lw	a5,124(s1)
    80002364:	2785                	addiw	a5,a5,1
    80002366:	dcfc                	sw	a5,124(s1)
    {
      p->rtime++;
    }
    release(&p->lock);
    80002368:	8526                	mv	a0,s1
    8000236a:	fffff097          	auipc	ra,0xfffff
    8000236e:	920080e7          	jalr	-1760(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002372:	1a848493          	addi	s1,s1,424
    80002376:	03248663          	beq	s1,s2,800023a2 <cfs_update+0x72>
    acquire(&p->lock);
    8000237a:	8526                	mv	a0,s1
    8000237c:	fffff097          	auipc	ra,0xfffff
    80002380:	85a080e7          	jalr	-1958(ra) # 80000bd6 <acquire>
    if (p->state == RUNNABLE)
    80002384:	4c9c                	lw	a5,24(s1)
    80002386:	fd378ee3          	beq	a5,s3,80002362 <cfs_update+0x32>
    else if (p->state == SLEEPING)
    8000238a:	01478863          	beq	a5,s4,8000239a <cfs_update+0x6a>
    else if (p->state == RUNNING)
    8000238e:	fd579de3          	bne	a5,s5,80002368 <cfs_update+0x38>
      p->rtime++;
    80002392:	58fc                	lw	a5,116(s1)
    80002394:	2785                	addiw	a5,a5,1
    80002396:	d8fc                	sw	a5,116(s1)
    80002398:	bfc1                	j	80002368 <cfs_update+0x38>
      p->stime++;
    8000239a:	5cbc                	lw	a5,120(s1)
    8000239c:	2785                	addiw	a5,a5,1
    8000239e:	dcbc                	sw	a5,120(s1)
    800023a0:	b7e1                	j	80002368 <cfs_update+0x38>
  }
}
    800023a2:	70e2                	ld	ra,56(sp)
    800023a4:	7442                	ld	s0,48(sp)
    800023a6:	74a2                	ld	s1,40(sp)
    800023a8:	7902                	ld	s2,32(sp)
    800023aa:	69e2                	ld	s3,24(sp)
    800023ac:	6a42                	ld	s4,16(sp)
    800023ae:	6aa2                	ld	s5,8(sp)
    800023b0:	6121                	addi	sp,sp,64
    800023b2:	8082                	ret

00000000800023b4 <wakeup>:
// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    800023b4:	7139                	addi	sp,sp,-64
    800023b6:	fc06                	sd	ra,56(sp)
    800023b8:	f822                	sd	s0,48(sp)
    800023ba:	f426                	sd	s1,40(sp)
    800023bc:	f04a                	sd	s2,32(sp)
    800023be:	ec4e                	sd	s3,24(sp)
    800023c0:	e852                	sd	s4,16(sp)
    800023c2:	e456                	sd	s5,8(sp)
    800023c4:	e05a                	sd	s6,0(sp)
    800023c6:	0080                	addi	s0,sp,64
    800023c8:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800023ca:	0000f497          	auipc	s1,0xf
    800023ce:	be648493          	addi	s1,s1,-1050 # 80010fb0 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    800023d2:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    800023d4:	4b0d                	li	s6,3
        p->accumulator = min_accumulator;
    800023d6:	00006a97          	auipc	s5,0x6
    800023da:	4a2a8a93          	addi	s5,s5,1186 # 80008878 <min_accumulator>
  for (p = proc; p < &proc[NPROC]; p++)
    800023de:	00015917          	auipc	s2,0x15
    800023e2:	5d290913          	addi	s2,s2,1490 # 800179b0 <tickslock>
    800023e6:	a811                	j	800023fa <wakeup+0x46>
      }
      
      release(&p->lock);
    800023e8:	8526                	mv	a0,s1
    800023ea:	fffff097          	auipc	ra,0xfffff
    800023ee:	8a0080e7          	jalr	-1888(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800023f2:	1a848493          	addi	s1,s1,424
    800023f6:	03248963          	beq	s1,s2,80002428 <wakeup+0x74>
    if (p != myproc())
    800023fa:	fffff097          	auipc	ra,0xfffff
    800023fe:	5e6080e7          	jalr	1510(ra) # 800019e0 <myproc>
    80002402:	fea488e3          	beq	s1,a0,800023f2 <wakeup+0x3e>
      acquire(&p->lock);
    80002406:	8526                	mv	a0,s1
    80002408:	ffffe097          	auipc	ra,0xffffe
    8000240c:	7ce080e7          	jalr	1998(ra) # 80000bd6 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    80002410:	4c9c                	lw	a5,24(s1)
    80002412:	fd379be3          	bne	a5,s3,800023e8 <wakeup+0x34>
    80002416:	709c                	ld	a5,32(s1)
    80002418:	fd4798e3          	bne	a5,s4,800023e8 <wakeup+0x34>
        p->state = RUNNABLE;
    8000241c:	0164ac23          	sw	s6,24(s1)
        p->accumulator = min_accumulator;
    80002420:	000ab783          	ld	a5,0(s5)
    80002424:	f0bc                	sd	a5,96(s1)
    80002426:	b7c9                	j	800023e8 <wakeup+0x34>
    }
  }
}
    80002428:	70e2                	ld	ra,56(sp)
    8000242a:	7442                	ld	s0,48(sp)
    8000242c:	74a2                	ld	s1,40(sp)
    8000242e:	7902                	ld	s2,32(sp)
    80002430:	69e2                	ld	s3,24(sp)
    80002432:	6a42                	ld	s4,16(sp)
    80002434:	6aa2                	ld	s5,8(sp)
    80002436:	6b02                	ld	s6,0(sp)
    80002438:	6121                	addi	sp,sp,64
    8000243a:	8082                	ret

000000008000243c <reparent>:
{
    8000243c:	7179                	addi	sp,sp,-48
    8000243e:	f406                	sd	ra,40(sp)
    80002440:	f022                	sd	s0,32(sp)
    80002442:	ec26                	sd	s1,24(sp)
    80002444:	e84a                	sd	s2,16(sp)
    80002446:	e44e                	sd	s3,8(sp)
    80002448:	e052                	sd	s4,0(sp)
    8000244a:	1800                	addi	s0,sp,48
    8000244c:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    8000244e:	0000f497          	auipc	s1,0xf
    80002452:	b6248493          	addi	s1,s1,-1182 # 80010fb0 <proc>
      pp->parent = initproc;
    80002456:	00006a17          	auipc	s4,0x6
    8000245a:	4baa0a13          	addi	s4,s4,1210 # 80008910 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    8000245e:	00015997          	auipc	s3,0x15
    80002462:	55298993          	addi	s3,s3,1362 # 800179b0 <tickslock>
    80002466:	a029                	j	80002470 <reparent+0x34>
    80002468:	1a848493          	addi	s1,s1,424
    8000246c:	01348d63          	beq	s1,s3,80002486 <reparent+0x4a>
    if (pp->parent == p)
    80002470:	7c9c                	ld	a5,56(s1)
    80002472:	ff279be3          	bne	a5,s2,80002468 <reparent+0x2c>
      pp->parent = initproc;
    80002476:	000a3503          	ld	a0,0(s4)
    8000247a:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000247c:	00000097          	auipc	ra,0x0
    80002480:	f38080e7          	jalr	-200(ra) # 800023b4 <wakeup>
    80002484:	b7d5                	j	80002468 <reparent+0x2c>
}
    80002486:	70a2                	ld	ra,40(sp)
    80002488:	7402                	ld	s0,32(sp)
    8000248a:	64e2                	ld	s1,24(sp)
    8000248c:	6942                	ld	s2,16(sp)
    8000248e:	69a2                	ld	s3,8(sp)
    80002490:	6a02                	ld	s4,0(sp)
    80002492:	6145                	addi	sp,sp,48
    80002494:	8082                	ret

0000000080002496 <exit>:
{
    80002496:	7139                	addi	sp,sp,-64
    80002498:	fc06                	sd	ra,56(sp)
    8000249a:	f822                	sd	s0,48(sp)
    8000249c:	f426                	sd	s1,40(sp)
    8000249e:	f04a                	sd	s2,32(sp)
    800024a0:	ec4e                	sd	s3,24(sp)
    800024a2:	e852                	sd	s4,16(sp)
    800024a4:	e456                	sd	s5,8(sp)
    800024a6:	0080                	addi	s0,sp,64
    800024a8:	8a2a                	mv	s4,a0
    800024aa:	8aae                	mv	s5,a1
  struct proc *p = myproc();
    800024ac:	fffff097          	auipc	ra,0xfffff
    800024b0:	534080e7          	jalr	1332(ra) # 800019e0 <myproc>
    800024b4:	89aa                	mv	s3,a0
  if (p == initproc)
    800024b6:	00006797          	auipc	a5,0x6
    800024ba:	45a7b783          	ld	a5,1114(a5) # 80008910 <initproc>
    800024be:	11050493          	addi	s1,a0,272
    800024c2:	19050913          	addi	s2,a0,400
    800024c6:	02a79363          	bne	a5,a0,800024ec <exit+0x56>
    panic("init exiting");
    800024ca:	00006517          	auipc	a0,0x6
    800024ce:	d9e50513          	addi	a0,a0,-610 # 80008268 <digits+0x228>
    800024d2:	ffffe097          	auipc	ra,0xffffe
    800024d6:	06c080e7          	jalr	108(ra) # 8000053e <panic>
      fileclose(f);
    800024da:	00002097          	auipc	ra,0x2
    800024de:	638080e7          	jalr	1592(ra) # 80004b12 <fileclose>
      p->ofile[fd] = 0;
    800024e2:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    800024e6:	04a1                	addi	s1,s1,8
    800024e8:	01248563          	beq	s1,s2,800024f2 <exit+0x5c>
    if (p->ofile[fd])
    800024ec:	6088                	ld	a0,0(s1)
    800024ee:	f575                	bnez	a0,800024da <exit+0x44>
    800024f0:	bfdd                	j	800024e6 <exit+0x50>
  begin_op();
    800024f2:	00002097          	auipc	ra,0x2
    800024f6:	154080e7          	jalr	340(ra) # 80004646 <begin_op>
  iput(p->cwd);
    800024fa:	1909b503          	ld	a0,400(s3)
    800024fe:	00002097          	auipc	ra,0x2
    80002502:	940080e7          	jalr	-1728(ra) # 80003e3e <iput>
  end_op();
    80002506:	00002097          	auipc	ra,0x2
    8000250a:	1c0080e7          	jalr	448(ra) # 800046c6 <end_op>
  p->cwd = 0;
    8000250e:	1809b823          	sd	zero,400(s3)
  acquire(&wait_lock);
    80002512:	0000e497          	auipc	s1,0xe
    80002516:	68648493          	addi	s1,s1,1670 # 80010b98 <wait_lock>
    8000251a:	8526                	mv	a0,s1
    8000251c:	ffffe097          	auipc	ra,0xffffe
    80002520:	6ba080e7          	jalr	1722(ra) # 80000bd6 <acquire>
  reparent(p);
    80002524:	854e                	mv	a0,s3
    80002526:	00000097          	auipc	ra,0x0
    8000252a:	f16080e7          	jalr	-234(ra) # 8000243c <reparent>
  wakeup(p->parent);
    8000252e:	0389b503          	ld	a0,56(s3)
    80002532:	00000097          	auipc	ra,0x0
    80002536:	e82080e7          	jalr	-382(ra) # 800023b4 <wakeup>
  acquire(&p->lock);
    8000253a:	854e                	mv	a0,s3
    8000253c:	ffffe097          	auipc	ra,0xffffe
    80002540:	69a080e7          	jalr	1690(ra) # 80000bd6 <acquire>
  safestrcpy(p->exit_msg, msg, sizeof(p->exit_msg)); // Copy string to process PCB
    80002544:	02000613          	li	a2,32
    80002548:	85d6                	mv	a1,s5
    8000254a:	04098513          	addi	a0,s3,64
    8000254e:	fffff097          	auipc	ra,0xfffff
    80002552:	8ce080e7          	jalr	-1842(ra) # 80000e1c <safestrcpy>
  p->xstate = status;
    80002556:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000255a:	4795                	li	a5,5
    8000255c:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002560:	8526                	mv	a0,s1
    80002562:	ffffe097          	auipc	ra,0xffffe
    80002566:	728080e7          	jalr	1832(ra) # 80000c8a <release>
  sched();
    8000256a:	00000097          	auipc	ra,0x0
    8000256e:	c50080e7          	jalr	-944(ra) # 800021ba <sched>
  panic("zombie exit");
    80002572:	00006517          	auipc	a0,0x6
    80002576:	d0650513          	addi	a0,a0,-762 # 80008278 <digits+0x238>
    8000257a:	ffffe097          	auipc	ra,0xffffe
    8000257e:	fc4080e7          	jalr	-60(ra) # 8000053e <panic>

0000000080002582 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002582:	7179                	addi	sp,sp,-48
    80002584:	f406                	sd	ra,40(sp)
    80002586:	f022                	sd	s0,32(sp)
    80002588:	ec26                	sd	s1,24(sp)
    8000258a:	e84a                	sd	s2,16(sp)
    8000258c:	e44e                	sd	s3,8(sp)
    8000258e:	1800                	addi	s0,sp,48
    80002590:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002592:	0000f497          	auipc	s1,0xf
    80002596:	a1e48493          	addi	s1,s1,-1506 # 80010fb0 <proc>
    8000259a:	00015997          	auipc	s3,0x15
    8000259e:	41698993          	addi	s3,s3,1046 # 800179b0 <tickslock>
  {
    acquire(&p->lock);
    800025a2:	8526                	mv	a0,s1
    800025a4:	ffffe097          	auipc	ra,0xffffe
    800025a8:	632080e7          	jalr	1586(ra) # 80000bd6 <acquire>
    if (p->pid == pid)
    800025ac:	589c                	lw	a5,48(s1)
    800025ae:	01278d63          	beq	a5,s2,800025c8 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800025b2:	8526                	mv	a0,s1
    800025b4:	ffffe097          	auipc	ra,0xffffe
    800025b8:	6d6080e7          	jalr	1750(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800025bc:	1a848493          	addi	s1,s1,424
    800025c0:	ff3491e3          	bne	s1,s3,800025a2 <kill+0x20>
  }
  return -1;
    800025c4:	557d                	li	a0,-1
    800025c6:	a829                	j	800025e0 <kill+0x5e>
      p->killed = 1;
    800025c8:	4785                	li	a5,1
    800025ca:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    800025cc:	4c98                	lw	a4,24(s1)
    800025ce:	4789                	li	a5,2
    800025d0:	00f70f63          	beq	a4,a5,800025ee <kill+0x6c>
      release(&p->lock);
    800025d4:	8526                	mv	a0,s1
    800025d6:	ffffe097          	auipc	ra,0xffffe
    800025da:	6b4080e7          	jalr	1716(ra) # 80000c8a <release>
      return 0;
    800025de:	4501                	li	a0,0
}
    800025e0:	70a2                	ld	ra,40(sp)
    800025e2:	7402                	ld	s0,32(sp)
    800025e4:	64e2                	ld	s1,24(sp)
    800025e6:	6942                	ld	s2,16(sp)
    800025e8:	69a2                	ld	s3,8(sp)
    800025ea:	6145                	addi	sp,sp,48
    800025ec:	8082                	ret
        p->state = RUNNABLE;
    800025ee:	478d                	li	a5,3
    800025f0:	cc9c                	sw	a5,24(s1)
    800025f2:	b7cd                	j	800025d4 <kill+0x52>

00000000800025f4 <setkilled>:

void setkilled(struct proc *p)
{
    800025f4:	1101                	addi	sp,sp,-32
    800025f6:	ec06                	sd	ra,24(sp)
    800025f8:	e822                	sd	s0,16(sp)
    800025fa:	e426                	sd	s1,8(sp)
    800025fc:	1000                	addi	s0,sp,32
    800025fe:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002600:	ffffe097          	auipc	ra,0xffffe
    80002604:	5d6080e7          	jalr	1494(ra) # 80000bd6 <acquire>
  p->killed = 1;
    80002608:	4785                	li	a5,1
    8000260a:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000260c:	8526                	mv	a0,s1
    8000260e:	ffffe097          	auipc	ra,0xffffe
    80002612:	67c080e7          	jalr	1660(ra) # 80000c8a <release>
}
    80002616:	60e2                	ld	ra,24(sp)
    80002618:	6442                	ld	s0,16(sp)
    8000261a:	64a2                	ld	s1,8(sp)
    8000261c:	6105                	addi	sp,sp,32
    8000261e:	8082                	ret

0000000080002620 <killed>:

int killed(struct proc *p)
{
    80002620:	1101                	addi	sp,sp,-32
    80002622:	ec06                	sd	ra,24(sp)
    80002624:	e822                	sd	s0,16(sp)
    80002626:	e426                	sd	s1,8(sp)
    80002628:	e04a                	sd	s2,0(sp)
    8000262a:	1000                	addi	s0,sp,32
    8000262c:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    8000262e:	ffffe097          	auipc	ra,0xffffe
    80002632:	5a8080e7          	jalr	1448(ra) # 80000bd6 <acquire>
  k = p->killed;
    80002636:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000263a:	8526                	mv	a0,s1
    8000263c:	ffffe097          	auipc	ra,0xffffe
    80002640:	64e080e7          	jalr	1614(ra) # 80000c8a <release>
  return k;
}
    80002644:	854a                	mv	a0,s2
    80002646:	60e2                	ld	ra,24(sp)
    80002648:	6442                	ld	s0,16(sp)
    8000264a:	64a2                	ld	s1,8(sp)
    8000264c:	6902                	ld	s2,0(sp)
    8000264e:	6105                	addi	sp,sp,32
    80002650:	8082                	ret

0000000080002652 <wait>:
{
    80002652:	711d                	addi	sp,sp,-96
    80002654:	ec86                	sd	ra,88(sp)
    80002656:	e8a2                	sd	s0,80(sp)
    80002658:	e4a6                	sd	s1,72(sp)
    8000265a:	e0ca                	sd	s2,64(sp)
    8000265c:	fc4e                	sd	s3,56(sp)
    8000265e:	f852                	sd	s4,48(sp)
    80002660:	f456                	sd	s5,40(sp)
    80002662:	f05a                	sd	s6,32(sp)
    80002664:	ec5e                	sd	s7,24(sp)
    80002666:	e862                	sd	s8,16(sp)
    80002668:	e466                	sd	s9,8(sp)
    8000266a:	1080                	addi	s0,sp,96
    8000266c:	8baa                	mv	s7,a0
    8000266e:	8b2e                	mv	s6,a1
  struct proc *p = myproc();
    80002670:	fffff097          	auipc	ra,0xfffff
    80002674:	370080e7          	jalr	880(ra) # 800019e0 <myproc>
    80002678:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000267a:	0000e517          	auipc	a0,0xe
    8000267e:	51e50513          	addi	a0,a0,1310 # 80010b98 <wait_lock>
    80002682:	ffffe097          	auipc	ra,0xffffe
    80002686:	554080e7          	jalr	1364(ra) # 80000bd6 <acquire>
    havekids = 0;
    8000268a:	4c01                	li	s8,0
        if (pp->state == ZOMBIE)
    8000268c:	4a15                	li	s4,5
        havekids = 1;
    8000268e:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002690:	00015997          	auipc	s3,0x15
    80002694:	32098993          	addi	s3,s3,800 # 800179b0 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002698:	0000ec97          	auipc	s9,0xe
    8000269c:	500c8c93          	addi	s9,s9,1280 # 80010b98 <wait_lock>
    havekids = 0;
    800026a0:	8762                	mv	a4,s8
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800026a2:	0000f497          	auipc	s1,0xf
    800026a6:	90e48493          	addi	s1,s1,-1778 # 80010fb0 <proc>
    800026aa:	a06d                	j	80002754 <wait+0x102>
          pid = pp->pid;
    800026ac:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800026b0:	040b9463          	bnez	s7,800026f8 <wait+0xa6>
          if (dst != 0 && copyout(p->pagetable, dst, (char *)&pp->exit_msg,
    800026b4:	000b0f63          	beqz	s6,800026d2 <wait+0x80>
    800026b8:	02000693          	li	a3,32
    800026bc:	04048613          	addi	a2,s1,64
    800026c0:	85da                	mv	a1,s6
    800026c2:	09093503          	ld	a0,144(s2)
    800026c6:	fffff097          	auipc	ra,0xfffff
    800026ca:	fa2080e7          	jalr	-94(ra) # 80001668 <copyout>
    800026ce:	06054063          	bltz	a0,8000272e <wait+0xdc>
          freeproc(pp);
    800026d2:	8526                	mv	a0,s1
    800026d4:	fffff097          	auipc	ra,0xfffff
    800026d8:	4be080e7          	jalr	1214(ra) # 80001b92 <freeproc>
          release(&pp->lock);
    800026dc:	8526                	mv	a0,s1
    800026de:	ffffe097          	auipc	ra,0xffffe
    800026e2:	5ac080e7          	jalr	1452(ra) # 80000c8a <release>
          release(&wait_lock);
    800026e6:	0000e517          	auipc	a0,0xe
    800026ea:	4b250513          	addi	a0,a0,1202 # 80010b98 <wait_lock>
    800026ee:	ffffe097          	auipc	ra,0xffffe
    800026f2:	59c080e7          	jalr	1436(ra) # 80000c8a <release>
          return pid;
    800026f6:	a04d                	j	80002798 <wait+0x146>
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800026f8:	4691                	li	a3,4
    800026fa:	02c48613          	addi	a2,s1,44
    800026fe:	85de                	mv	a1,s7
    80002700:	09093503          	ld	a0,144(s2)
    80002704:	fffff097          	auipc	ra,0xfffff
    80002708:	f64080e7          	jalr	-156(ra) # 80001668 <copyout>
    8000270c:	fa0554e3          	bgez	a0,800026b4 <wait+0x62>
            release(&pp->lock);
    80002710:	8526                	mv	a0,s1
    80002712:	ffffe097          	auipc	ra,0xffffe
    80002716:	578080e7          	jalr	1400(ra) # 80000c8a <release>
            release(&wait_lock);
    8000271a:	0000e517          	auipc	a0,0xe
    8000271e:	47e50513          	addi	a0,a0,1150 # 80010b98 <wait_lock>
    80002722:	ffffe097          	auipc	ra,0xffffe
    80002726:	568080e7          	jalr	1384(ra) # 80000c8a <release>
            return -1;
    8000272a:	59fd                	li	s3,-1
    8000272c:	a0b5                	j	80002798 <wait+0x146>
            release(&pp->lock);
    8000272e:	8526                	mv	a0,s1
    80002730:	ffffe097          	auipc	ra,0xffffe
    80002734:	55a080e7          	jalr	1370(ra) # 80000c8a <release>
            release(&wait_lock);
    80002738:	0000e517          	auipc	a0,0xe
    8000273c:	46050513          	addi	a0,a0,1120 # 80010b98 <wait_lock>
    80002740:	ffffe097          	auipc	ra,0xffffe
    80002744:	54a080e7          	jalr	1354(ra) # 80000c8a <release>
            return -1;
    80002748:	59fd                	li	s3,-1
    8000274a:	a0b9                	j	80002798 <wait+0x146>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000274c:	1a848493          	addi	s1,s1,424
    80002750:	03348463          	beq	s1,s3,80002778 <wait+0x126>
      if (pp->parent == p)
    80002754:	7c9c                	ld	a5,56(s1)
    80002756:	ff279be3          	bne	a5,s2,8000274c <wait+0xfa>
        acquire(&pp->lock);
    8000275a:	8526                	mv	a0,s1
    8000275c:	ffffe097          	auipc	ra,0xffffe
    80002760:	47a080e7          	jalr	1146(ra) # 80000bd6 <acquire>
        if (pp->state == ZOMBIE)
    80002764:	4c9c                	lw	a5,24(s1)
    80002766:	f54783e3          	beq	a5,s4,800026ac <wait+0x5a>
        release(&pp->lock);
    8000276a:	8526                	mv	a0,s1
    8000276c:	ffffe097          	auipc	ra,0xffffe
    80002770:	51e080e7          	jalr	1310(ra) # 80000c8a <release>
        havekids = 1;
    80002774:	8756                	mv	a4,s5
    80002776:	bfd9                	j	8000274c <wait+0xfa>
    if (!havekids || killed(p))
    80002778:	c719                	beqz	a4,80002786 <wait+0x134>
    8000277a:	854a                	mv	a0,s2
    8000277c:	00000097          	auipc	ra,0x0
    80002780:	ea4080e7          	jalr	-348(ra) # 80002620 <killed>
    80002784:	c905                	beqz	a0,800027b4 <wait+0x162>
      release(&wait_lock);
    80002786:	0000e517          	auipc	a0,0xe
    8000278a:	41250513          	addi	a0,a0,1042 # 80010b98 <wait_lock>
    8000278e:	ffffe097          	auipc	ra,0xffffe
    80002792:	4fc080e7          	jalr	1276(ra) # 80000c8a <release>
      return -1;
    80002796:	59fd                	li	s3,-1
}
    80002798:	854e                	mv	a0,s3
    8000279a:	60e6                	ld	ra,88(sp)
    8000279c:	6446                	ld	s0,80(sp)
    8000279e:	64a6                	ld	s1,72(sp)
    800027a0:	6906                	ld	s2,64(sp)
    800027a2:	79e2                	ld	s3,56(sp)
    800027a4:	7a42                	ld	s4,48(sp)
    800027a6:	7aa2                	ld	s5,40(sp)
    800027a8:	7b02                	ld	s6,32(sp)
    800027aa:	6be2                	ld	s7,24(sp)
    800027ac:	6c42                	ld	s8,16(sp)
    800027ae:	6ca2                	ld	s9,8(sp)
    800027b0:	6125                	addi	sp,sp,96
    800027b2:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    800027b4:	85e6                	mv	a1,s9
    800027b6:	854a                	mv	a0,s2
    800027b8:	00000097          	auipc	ra,0x0
    800027bc:	b14080e7          	jalr	-1260(ra) # 800022cc <sleep>
    havekids = 0;
    800027c0:	b5c5                	j	800026a0 <wait+0x4e>

00000000800027c2 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800027c2:	7179                	addi	sp,sp,-48
    800027c4:	f406                	sd	ra,40(sp)
    800027c6:	f022                	sd	s0,32(sp)
    800027c8:	ec26                	sd	s1,24(sp)
    800027ca:	e84a                	sd	s2,16(sp)
    800027cc:	e44e                	sd	s3,8(sp)
    800027ce:	e052                	sd	s4,0(sp)
    800027d0:	1800                	addi	s0,sp,48
    800027d2:	84aa                	mv	s1,a0
    800027d4:	892e                	mv	s2,a1
    800027d6:	89b2                	mv	s3,a2
    800027d8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800027da:	fffff097          	auipc	ra,0xfffff
    800027de:	206080e7          	jalr	518(ra) # 800019e0 <myproc>
  if (user_dst)
    800027e2:	c08d                	beqz	s1,80002804 <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    800027e4:	86d2                	mv	a3,s4
    800027e6:	864e                	mv	a2,s3
    800027e8:	85ca                	mv	a1,s2
    800027ea:	6948                	ld	a0,144(a0)
    800027ec:	fffff097          	auipc	ra,0xfffff
    800027f0:	e7c080e7          	jalr	-388(ra) # 80001668 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800027f4:	70a2                	ld	ra,40(sp)
    800027f6:	7402                	ld	s0,32(sp)
    800027f8:	64e2                	ld	s1,24(sp)
    800027fa:	6942                	ld	s2,16(sp)
    800027fc:	69a2                	ld	s3,8(sp)
    800027fe:	6a02                	ld	s4,0(sp)
    80002800:	6145                	addi	sp,sp,48
    80002802:	8082                	ret
    memmove((char *)dst, src, len);
    80002804:	000a061b          	sext.w	a2,s4
    80002808:	85ce                	mv	a1,s3
    8000280a:	854a                	mv	a0,s2
    8000280c:	ffffe097          	auipc	ra,0xffffe
    80002810:	522080e7          	jalr	1314(ra) # 80000d2e <memmove>
    return 0;
    80002814:	8526                	mv	a0,s1
    80002816:	bff9                	j	800027f4 <either_copyout+0x32>

0000000080002818 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002818:	7179                	addi	sp,sp,-48
    8000281a:	f406                	sd	ra,40(sp)
    8000281c:	f022                	sd	s0,32(sp)
    8000281e:	ec26                	sd	s1,24(sp)
    80002820:	e84a                	sd	s2,16(sp)
    80002822:	e44e                	sd	s3,8(sp)
    80002824:	e052                	sd	s4,0(sp)
    80002826:	1800                	addi	s0,sp,48
    80002828:	892a                	mv	s2,a0
    8000282a:	84ae                	mv	s1,a1
    8000282c:	89b2                	mv	s3,a2
    8000282e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002830:	fffff097          	auipc	ra,0xfffff
    80002834:	1b0080e7          	jalr	432(ra) # 800019e0 <myproc>
  if (user_src)
    80002838:	c08d                	beqz	s1,8000285a <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    8000283a:	86d2                	mv	a3,s4
    8000283c:	864e                	mv	a2,s3
    8000283e:	85ca                	mv	a1,s2
    80002840:	6948                	ld	a0,144(a0)
    80002842:	fffff097          	auipc	ra,0xfffff
    80002846:	eb2080e7          	jalr	-334(ra) # 800016f4 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    8000284a:	70a2                	ld	ra,40(sp)
    8000284c:	7402                	ld	s0,32(sp)
    8000284e:	64e2                	ld	s1,24(sp)
    80002850:	6942                	ld	s2,16(sp)
    80002852:	69a2                	ld	s3,8(sp)
    80002854:	6a02                	ld	s4,0(sp)
    80002856:	6145                	addi	sp,sp,48
    80002858:	8082                	ret
    memmove(dst, (char *)src, len);
    8000285a:	000a061b          	sext.w	a2,s4
    8000285e:	85ce                	mv	a1,s3
    80002860:	854a                	mv	a0,s2
    80002862:	ffffe097          	auipc	ra,0xffffe
    80002866:	4cc080e7          	jalr	1228(ra) # 80000d2e <memmove>
    return 0;
    8000286a:	8526                	mv	a0,s1
    8000286c:	bff9                	j	8000284a <either_copyin+0x32>

000000008000286e <get_cfs_stats>:
int get_cfs_stats(uint64 add, int pid)
{
    8000286e:	7139                	addi	sp,sp,-64
    80002870:	fc06                	sd	ra,56(sp)
    80002872:	f822                	sd	s0,48(sp)
    80002874:	f426                	sd	s1,40(sp)
    80002876:	f04a                	sd	s2,32(sp)
    80002878:	ec4e                	sd	s3,24(sp)
    8000287a:	e852                	sd	s4,16(sp)
    8000287c:	0080                	addi	s0,sp,64
    8000287e:	8a2a                	mv	s4,a0
    80002880:	892e                	mv	s2,a1
  struct proc *p;

  int values[4];
  for (p = proc; p < &proc[NPROC]; p++)
    80002882:	0000e497          	auipc	s1,0xe
    80002886:	72e48493          	addi	s1,s1,1838 # 80010fb0 <proc>
    8000288a:	00015997          	auipc	s3,0x15
    8000288e:	12698993          	addi	s3,s3,294 # 800179b0 <tickslock>
  {
    acquire(&p->lock);
    80002892:	8526                	mv	a0,s1
    80002894:	ffffe097          	auipc	ra,0xffffe
    80002898:	342080e7          	jalr	834(ra) # 80000bd6 <acquire>
    if (p->pid == pid)
    8000289c:	589c                	lw	a5,48(s1)
    8000289e:	01278d63          	beq	a5,s2,800028b8 <get_cfs_stats+0x4a>
        return -1;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800028a2:	8526                	mv	a0,s1
    800028a4:	ffffe097          	auipc	ra,0xffffe
    800028a8:	3e6080e7          	jalr	998(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800028ac:	1a848493          	addi	s1,s1,424
    800028b0:	ff3491e3          	bne	s1,s3,80002892 <get_cfs_stats+0x24>
  }
  return -1;
    800028b4:	557d                	li	a0,-1
    800028b6:	a835                	j	800028f2 <get_cfs_stats+0x84>
      values[0] = p->cfs_priority;
    800028b8:	58bc                	lw	a5,112(s1)
    800028ba:	fcf42023          	sw	a5,-64(s0)
      values[1] = p->rtime;
    800028be:	58fc                	lw	a5,116(s1)
    800028c0:	fcf42223          	sw	a5,-60(s0)
      values[2] = p->stime;
    800028c4:	5cbc                	lw	a5,120(s1)
    800028c6:	fcf42423          	sw	a5,-56(s0)
      values[3] = p->retime;
    800028ca:	5cfc                	lw	a5,124(s1)
    800028cc:	fcf42623          	sw	a5,-52(s0)
      if (copyout(p->pagetable, add, (char *)values,
    800028d0:	46c1                	li	a3,16
    800028d2:	fc040613          	addi	a2,s0,-64
    800028d6:	85d2                	mv	a1,s4
    800028d8:	68c8                	ld	a0,144(s1)
    800028da:	fffff097          	auipc	ra,0xfffff
    800028de:	d8e080e7          	jalr	-626(ra) # 80001668 <copyout>
    800028e2:	02054063          	bltz	a0,80002902 <get_cfs_stats+0x94>
      release(&p->lock);
    800028e6:	8526                	mv	a0,s1
    800028e8:	ffffe097          	auipc	ra,0xffffe
    800028ec:	3a2080e7          	jalr	930(ra) # 80000c8a <release>
      return 0;
    800028f0:	4501                	li	a0,0
}
    800028f2:	70e2                	ld	ra,56(sp)
    800028f4:	7442                	ld	s0,48(sp)
    800028f6:	74a2                	ld	s1,40(sp)
    800028f8:	7902                	ld	s2,32(sp)
    800028fa:	69e2                	ld	s3,24(sp)
    800028fc:	6a42                	ld	s4,16(sp)
    800028fe:	6121                	addi	sp,sp,64
    80002900:	8082                	ret
        release(&p->lock);
    80002902:	8526                	mv	a0,s1
    80002904:	ffffe097          	auipc	ra,0xffffe
    80002908:	386080e7          	jalr	902(ra) # 80000c8a <release>
        return -1;
    8000290c:	557d                	li	a0,-1
    8000290e:	b7d5                	j	800028f2 <get_cfs_stats+0x84>

0000000080002910 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002910:	715d                	addi	sp,sp,-80
    80002912:	e486                	sd	ra,72(sp)
    80002914:	e0a2                	sd	s0,64(sp)
    80002916:	fc26                	sd	s1,56(sp)
    80002918:	f84a                	sd	s2,48(sp)
    8000291a:	f44e                	sd	s3,40(sp)
    8000291c:	f052                	sd	s4,32(sp)
    8000291e:	ec56                	sd	s5,24(sp)
    80002920:	e85a                	sd	s6,16(sp)
    80002922:	e45e                	sd	s7,8(sp)
    80002924:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002926:	00005517          	auipc	a0,0x5
    8000292a:	7a250513          	addi	a0,a0,1954 # 800080c8 <digits+0x88>
    8000292e:	ffffe097          	auipc	ra,0xffffe
    80002932:	c5a080e7          	jalr	-934(ra) # 80000588 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002936:	0000f497          	auipc	s1,0xf
    8000293a:	81248493          	addi	s1,s1,-2030 # 80011148 <proc+0x198>
    8000293e:	00015917          	auipc	s2,0x15
    80002942:	20a90913          	addi	s2,s2,522 # 80017b48 <bcache+0x180>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002946:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002948:	00006997          	auipc	s3,0x6
    8000294c:	94098993          	addi	s3,s3,-1728 # 80008288 <digits+0x248>
    printf("%d %s %s", p->pid, state, p->name);
    80002950:	00006a97          	auipc	s5,0x6
    80002954:	940a8a93          	addi	s5,s5,-1728 # 80008290 <digits+0x250>
    printf("\n");
    80002958:	00005a17          	auipc	s4,0x5
    8000295c:	770a0a13          	addi	s4,s4,1904 # 800080c8 <digits+0x88>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002960:	00006b97          	auipc	s7,0x6
    80002964:	970b8b93          	addi	s7,s7,-1680 # 800082d0 <states.0>
    80002968:	a00d                	j	8000298a <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000296a:	e986a583          	lw	a1,-360(a3)
    8000296e:	8556                	mv	a0,s5
    80002970:	ffffe097          	auipc	ra,0xffffe
    80002974:	c18080e7          	jalr	-1000(ra) # 80000588 <printf>
    printf("\n");
    80002978:	8552                	mv	a0,s4
    8000297a:	ffffe097          	auipc	ra,0xffffe
    8000297e:	c0e080e7          	jalr	-1010(ra) # 80000588 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002982:	1a848493          	addi	s1,s1,424
    80002986:	03248163          	beq	s1,s2,800029a8 <procdump+0x98>
    if (p->state == UNUSED)
    8000298a:	86a6                	mv	a3,s1
    8000298c:	e804a783          	lw	a5,-384(s1)
    80002990:	dbed                	beqz	a5,80002982 <procdump+0x72>
      state = "???";
    80002992:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002994:	fcfb6be3          	bltu	s6,a5,8000296a <procdump+0x5a>
    80002998:	1782                	slli	a5,a5,0x20
    8000299a:	9381                	srli	a5,a5,0x20
    8000299c:	078e                	slli	a5,a5,0x3
    8000299e:	97de                	add	a5,a5,s7
    800029a0:	6390                	ld	a2,0(a5)
    800029a2:	f661                	bnez	a2,8000296a <procdump+0x5a>
      state = "???";
    800029a4:	864e                	mv	a2,s3
    800029a6:	b7d1                	j	8000296a <procdump+0x5a>
  }
}
    800029a8:	60a6                	ld	ra,72(sp)
    800029aa:	6406                	ld	s0,64(sp)
    800029ac:	74e2                	ld	s1,56(sp)
    800029ae:	7942                	ld	s2,48(sp)
    800029b0:	79a2                	ld	s3,40(sp)
    800029b2:	7a02                	ld	s4,32(sp)
    800029b4:	6ae2                	ld	s5,24(sp)
    800029b6:	6b42                	ld	s6,16(sp)
    800029b8:	6ba2                	ld	s7,8(sp)
    800029ba:	6161                	addi	sp,sp,80
    800029bc:	8082                	ret

00000000800029be <swtch>:
    800029be:	00153023          	sd	ra,0(a0)
    800029c2:	00253423          	sd	sp,8(a0)
    800029c6:	e900                	sd	s0,16(a0)
    800029c8:	ed04                	sd	s1,24(a0)
    800029ca:	03253023          	sd	s2,32(a0)
    800029ce:	03353423          	sd	s3,40(a0)
    800029d2:	03453823          	sd	s4,48(a0)
    800029d6:	03553c23          	sd	s5,56(a0)
    800029da:	05653023          	sd	s6,64(a0)
    800029de:	05753423          	sd	s7,72(a0)
    800029e2:	05853823          	sd	s8,80(a0)
    800029e6:	05953c23          	sd	s9,88(a0)
    800029ea:	07a53023          	sd	s10,96(a0)
    800029ee:	07b53423          	sd	s11,104(a0)
    800029f2:	0005b083          	ld	ra,0(a1)
    800029f6:	0085b103          	ld	sp,8(a1)
    800029fa:	6980                	ld	s0,16(a1)
    800029fc:	6d84                	ld	s1,24(a1)
    800029fe:	0205b903          	ld	s2,32(a1)
    80002a02:	0285b983          	ld	s3,40(a1)
    80002a06:	0305ba03          	ld	s4,48(a1)
    80002a0a:	0385ba83          	ld	s5,56(a1)
    80002a0e:	0405bb03          	ld	s6,64(a1)
    80002a12:	0485bb83          	ld	s7,72(a1)
    80002a16:	0505bc03          	ld	s8,80(a1)
    80002a1a:	0585bc83          	ld	s9,88(a1)
    80002a1e:	0605bd03          	ld	s10,96(a1)
    80002a22:	0685bd83          	ld	s11,104(a1)
    80002a26:	8082                	ret

0000000080002a28 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002a28:	1141                	addi	sp,sp,-16
    80002a2a:	e406                	sd	ra,8(sp)
    80002a2c:	e022                	sd	s0,0(sp)
    80002a2e:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002a30:	00006597          	auipc	a1,0x6
    80002a34:	8d058593          	addi	a1,a1,-1840 # 80008300 <states.0+0x30>
    80002a38:	00015517          	auipc	a0,0x15
    80002a3c:	f7850513          	addi	a0,a0,-136 # 800179b0 <tickslock>
    80002a40:	ffffe097          	auipc	ra,0xffffe
    80002a44:	106080e7          	jalr	262(ra) # 80000b46 <initlock>
}
    80002a48:	60a2                	ld	ra,8(sp)
    80002a4a:	6402                	ld	s0,0(sp)
    80002a4c:	0141                	addi	sp,sp,16
    80002a4e:	8082                	ret

0000000080002a50 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002a50:	1141                	addi	sp,sp,-16
    80002a52:	e422                	sd	s0,8(sp)
    80002a54:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a56:	00003797          	auipc	a5,0x3
    80002a5a:	71a78793          	addi	a5,a5,1818 # 80006170 <kernelvec>
    80002a5e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002a62:	6422                	ld	s0,8(sp)
    80002a64:	0141                	addi	sp,sp,16
    80002a66:	8082                	ret

0000000080002a68 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002a68:	1141                	addi	sp,sp,-16
    80002a6a:	e406                	sd	ra,8(sp)
    80002a6c:	e022                	sd	s0,0(sp)
    80002a6e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002a70:	fffff097          	auipc	ra,0xfffff
    80002a74:	f70080e7          	jalr	-144(ra) # 800019e0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a78:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002a7c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a7e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002a82:	00004617          	auipc	a2,0x4
    80002a86:	57e60613          	addi	a2,a2,1406 # 80007000 <_trampoline>
    80002a8a:	00004697          	auipc	a3,0x4
    80002a8e:	57668693          	addi	a3,a3,1398 # 80007000 <_trampoline>
    80002a92:	8e91                	sub	a3,a3,a2
    80002a94:	040007b7          	lui	a5,0x4000
    80002a98:	17fd                	addi	a5,a5,-1
    80002a9a:	07b2                	slli	a5,a5,0xc
    80002a9c:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a9e:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002aa2:	6d58                	ld	a4,152(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002aa4:	180026f3          	csrr	a3,satp
    80002aa8:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002aaa:	6d58                	ld	a4,152(a0)
    80002aac:	6154                	ld	a3,128(a0)
    80002aae:	6585                	lui	a1,0x1
    80002ab0:	96ae                	add	a3,a3,a1
    80002ab2:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002ab4:	6d58                	ld	a4,152(a0)
    80002ab6:	00000697          	auipc	a3,0x0
    80002aba:	13068693          	addi	a3,a3,304 # 80002be6 <usertrap>
    80002abe:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002ac0:	6d58                	ld	a4,152(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002ac2:	8692                	mv	a3,tp
    80002ac4:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ac6:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002aca:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002ace:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ad2:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002ad6:	6d58                	ld	a4,152(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002ad8:	6f18                	ld	a4,24(a4)
    80002ada:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002ade:	6948                	ld	a0,144(a0)
    80002ae0:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002ae2:	00004717          	auipc	a4,0x4
    80002ae6:	5ba70713          	addi	a4,a4,1466 # 8000709c <userret>
    80002aea:	8f11                	sub	a4,a4,a2
    80002aec:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002aee:	577d                	li	a4,-1
    80002af0:	177e                	slli	a4,a4,0x3f
    80002af2:	8d59                	or	a0,a0,a4
    80002af4:	9782                	jalr	a5
}
    80002af6:	60a2                	ld	ra,8(sp)
    80002af8:	6402                	ld	s0,0(sp)
    80002afa:	0141                	addi	sp,sp,16
    80002afc:	8082                	ret

0000000080002afe <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002afe:	1101                	addi	sp,sp,-32
    80002b00:	ec06                	sd	ra,24(sp)
    80002b02:	e822                	sd	s0,16(sp)
    80002b04:	e426                	sd	s1,8(sp)
    80002b06:	1000                	addi	s0,sp,32
  // cfs_update();
  acquire(&tickslock);
    80002b08:	00015497          	auipc	s1,0x15
    80002b0c:	ea848493          	addi	s1,s1,-344 # 800179b0 <tickslock>
    80002b10:	8526                	mv	a0,s1
    80002b12:	ffffe097          	auipc	ra,0xffffe
    80002b16:	0c4080e7          	jalr	196(ra) # 80000bd6 <acquire>
  ticks++;
    80002b1a:	00006517          	auipc	a0,0x6
    80002b1e:	dfe50513          	addi	a0,a0,-514 # 80008918 <ticks>
    80002b22:	411c                	lw	a5,0(a0)
    80002b24:	2785                	addiw	a5,a5,1
    80002b26:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002b28:	00000097          	auipc	ra,0x0
    80002b2c:	88c080e7          	jalr	-1908(ra) # 800023b4 <wakeup>
  release(&tickslock);
    80002b30:	8526                	mv	a0,s1
    80002b32:	ffffe097          	auipc	ra,0xffffe
    80002b36:	158080e7          	jalr	344(ra) # 80000c8a <release>
  // cfs_update();
}
    80002b3a:	60e2                	ld	ra,24(sp)
    80002b3c:	6442                	ld	s0,16(sp)
    80002b3e:	64a2                	ld	s1,8(sp)
    80002b40:	6105                	addi	sp,sp,32
    80002b42:	8082                	ret

0000000080002b44 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002b44:	1101                	addi	sp,sp,-32
    80002b46:	ec06                	sd	ra,24(sp)
    80002b48:	e822                	sd	s0,16(sp)
    80002b4a:	e426                	sd	s1,8(sp)
    80002b4c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b4e:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002b52:	00074d63          	bltz	a4,80002b6c <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002b56:	57fd                	li	a5,-1
    80002b58:	17fe                	slli	a5,a5,0x3f
    80002b5a:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002b5c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002b5e:	06f70363          	beq	a4,a5,80002bc4 <devintr+0x80>
  }
}
    80002b62:	60e2                	ld	ra,24(sp)
    80002b64:	6442                	ld	s0,16(sp)
    80002b66:	64a2                	ld	s1,8(sp)
    80002b68:	6105                	addi	sp,sp,32
    80002b6a:	8082                	ret
     (scause & 0xff) == 9){
    80002b6c:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002b70:	46a5                	li	a3,9
    80002b72:	fed792e3          	bne	a5,a3,80002b56 <devintr+0x12>
    int irq = plic_claim();
    80002b76:	00003097          	auipc	ra,0x3
    80002b7a:	702080e7          	jalr	1794(ra) # 80006278 <plic_claim>
    80002b7e:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002b80:	47a9                	li	a5,10
    80002b82:	02f50763          	beq	a0,a5,80002bb0 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002b86:	4785                	li	a5,1
    80002b88:	02f50963          	beq	a0,a5,80002bba <devintr+0x76>
    return 1;
    80002b8c:	4505                	li	a0,1
    } else if(irq){
    80002b8e:	d8f1                	beqz	s1,80002b62 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002b90:	85a6                	mv	a1,s1
    80002b92:	00005517          	auipc	a0,0x5
    80002b96:	77650513          	addi	a0,a0,1910 # 80008308 <states.0+0x38>
    80002b9a:	ffffe097          	auipc	ra,0xffffe
    80002b9e:	9ee080e7          	jalr	-1554(ra) # 80000588 <printf>
      plic_complete(irq);
    80002ba2:	8526                	mv	a0,s1
    80002ba4:	00003097          	auipc	ra,0x3
    80002ba8:	6f8080e7          	jalr	1784(ra) # 8000629c <plic_complete>
    return 1;
    80002bac:	4505                	li	a0,1
    80002bae:	bf55                	j	80002b62 <devintr+0x1e>
      uartintr();
    80002bb0:	ffffe097          	auipc	ra,0xffffe
    80002bb4:	dea080e7          	jalr	-534(ra) # 8000099a <uartintr>
    80002bb8:	b7ed                	j	80002ba2 <devintr+0x5e>
      virtio_disk_intr();
    80002bba:	00004097          	auipc	ra,0x4
    80002bbe:	bae080e7          	jalr	-1106(ra) # 80006768 <virtio_disk_intr>
    80002bc2:	b7c5                	j	80002ba2 <devintr+0x5e>
    if(cpuid() == 0){
    80002bc4:	fffff097          	auipc	ra,0xfffff
    80002bc8:	dda080e7          	jalr	-550(ra) # 8000199e <cpuid>
    80002bcc:	c901                	beqz	a0,80002bdc <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002bce:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002bd2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002bd4:	14479073          	csrw	sip,a5
    return 2;
    80002bd8:	4509                	li	a0,2
    80002bda:	b761                	j	80002b62 <devintr+0x1e>
      clockintr();
    80002bdc:	00000097          	auipc	ra,0x0
    80002be0:	f22080e7          	jalr	-222(ra) # 80002afe <clockintr>
    80002be4:	b7ed                	j	80002bce <devintr+0x8a>

0000000080002be6 <usertrap>:
{
    80002be6:	1101                	addi	sp,sp,-32
    80002be8:	ec06                	sd	ra,24(sp)
    80002bea:	e822                	sd	s0,16(sp)
    80002bec:	e426                	sd	s1,8(sp)
    80002bee:	e04a                	sd	s2,0(sp)
    80002bf0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bf2:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002bf6:	1007f793          	andi	a5,a5,256
    80002bfa:	e3b1                	bnez	a5,80002c3e <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002bfc:	00003797          	auipc	a5,0x3
    80002c00:	57478793          	addi	a5,a5,1396 # 80006170 <kernelvec>
    80002c04:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002c08:	fffff097          	auipc	ra,0xfffff
    80002c0c:	dd8080e7          	jalr	-552(ra) # 800019e0 <myproc>
    80002c10:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002c12:	6d5c                	ld	a5,152(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c14:	14102773          	csrr	a4,sepc
    80002c18:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c1a:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002c1e:	47a1                	li	a5,8
    80002c20:	02f70763          	beq	a4,a5,80002c4e <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002c24:	00000097          	auipc	ra,0x0
    80002c28:	f20080e7          	jalr	-224(ra) # 80002b44 <devintr>
    80002c2c:	892a                	mv	s2,a0
    80002c2e:	c551                	beqz	a0,80002cba <usertrap+0xd4>
  if(killed(p))
    80002c30:	8526                	mv	a0,s1
    80002c32:	00000097          	auipc	ra,0x0
    80002c36:	9ee080e7          	jalr	-1554(ra) # 80002620 <killed>
    80002c3a:	c939                	beqz	a0,80002c90 <usertrap+0xaa>
    80002c3c:	a099                	j	80002c82 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002c3e:	00005517          	auipc	a0,0x5
    80002c42:	6ea50513          	addi	a0,a0,1770 # 80008328 <states.0+0x58>
    80002c46:	ffffe097          	auipc	ra,0xffffe
    80002c4a:	8f8080e7          	jalr	-1800(ra) # 8000053e <panic>
    if(killed(p))
    80002c4e:	00000097          	auipc	ra,0x0
    80002c52:	9d2080e7          	jalr	-1582(ra) # 80002620 <killed>
    80002c56:	e931                	bnez	a0,80002caa <usertrap+0xc4>
    p->trapframe->epc += 4;
    80002c58:	6cd8                	ld	a4,152(s1)
    80002c5a:	6f1c                	ld	a5,24(a4)
    80002c5c:	0791                	addi	a5,a5,4
    80002c5e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c60:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002c64:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c68:	10079073          	csrw	sstatus,a5
    syscall();
    80002c6c:	00000097          	auipc	ra,0x0
    80002c70:	382080e7          	jalr	898(ra) # 80002fee <syscall>
  if(killed(p))
    80002c74:	8526                	mv	a0,s1
    80002c76:	00000097          	auipc	ra,0x0
    80002c7a:	9aa080e7          	jalr	-1622(ra) # 80002620 <killed>
    80002c7e:	cd01                	beqz	a0,80002c96 <usertrap+0xb0>
    80002c80:	4901                	li	s2,0
    exit(-1,p->exit_msg);
    80002c82:	04048593          	addi	a1,s1,64
    80002c86:	557d                	li	a0,-1
    80002c88:	00000097          	auipc	ra,0x0
    80002c8c:	80e080e7          	jalr	-2034(ra) # 80002496 <exit>
  if(which_dev == 2){
    80002c90:	4789                	li	a5,2
    80002c92:	06f90163          	beq	s2,a5,80002cf4 <usertrap+0x10e>
  usertrapret();
    80002c96:	00000097          	auipc	ra,0x0
    80002c9a:	dd2080e7          	jalr	-558(ra) # 80002a68 <usertrapret>
}
    80002c9e:	60e2                	ld	ra,24(sp)
    80002ca0:	6442                	ld	s0,16(sp)
    80002ca2:	64a2                	ld	s1,8(sp)
    80002ca4:	6902                	ld	s2,0(sp)
    80002ca6:	6105                	addi	sp,sp,32
    80002ca8:	8082                	ret
      exit(-1,p->exit_msg);
    80002caa:	04048593          	addi	a1,s1,64
    80002cae:	557d                	li	a0,-1
    80002cb0:	fffff097          	auipc	ra,0xfffff
    80002cb4:	7e6080e7          	jalr	2022(ra) # 80002496 <exit>
    80002cb8:	b745                	j	80002c58 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cba:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002cbe:	5890                	lw	a2,48(s1)
    80002cc0:	00005517          	auipc	a0,0x5
    80002cc4:	68850513          	addi	a0,a0,1672 # 80008348 <states.0+0x78>
    80002cc8:	ffffe097          	auipc	ra,0xffffe
    80002ccc:	8c0080e7          	jalr	-1856(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cd0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002cd4:	14302673          	csrr	a2,stval
    printf(" sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002cd8:	00005517          	auipc	a0,0x5
    80002cdc:	6a050513          	addi	a0,a0,1696 # 80008378 <states.0+0xa8>
    80002ce0:	ffffe097          	auipc	ra,0xffffe
    80002ce4:	8a8080e7          	jalr	-1880(ra) # 80000588 <printf>
    setkilled(p);
    80002ce8:	8526                	mv	a0,s1
    80002cea:	00000097          	auipc	ra,0x0
    80002cee:	90a080e7          	jalr	-1782(ra) # 800025f4 <setkilled>
    80002cf2:	b749                	j	80002c74 <usertrap+0x8e>
    acquire(&myproc()->lock);
    80002cf4:	fffff097          	auipc	ra,0xfffff
    80002cf8:	cec080e7          	jalr	-788(ra) # 800019e0 <myproc>
    80002cfc:	ffffe097          	auipc	ra,0xffffe
    80002d00:	eda080e7          	jalr	-294(ra) # 80000bd6 <acquire>
    if ( myproc()->accumulator<10)
    80002d04:	fffff097          	auipc	ra,0xfffff
    80002d08:	cdc080e7          	jalr	-804(ra) # 800019e0 <myproc>
    80002d0c:	7138                	ld	a4,96(a0)
    80002d0e:	47a5                	li	a5,9
    80002d10:	02e7d363          	bge	a5,a4,80002d36 <usertrap+0x150>
    release(&myproc()->lock);
    80002d14:	fffff097          	auipc	ra,0xfffff
    80002d18:	ccc080e7          	jalr	-820(ra) # 800019e0 <myproc>
    80002d1c:	ffffe097          	auipc	ra,0xffffe
    80002d20:	f6e080e7          	jalr	-146(ra) # 80000c8a <release>
    cfs_update();
    80002d24:	fffff097          	auipc	ra,0xfffff
    80002d28:	60c080e7          	jalr	1548(ra) # 80002330 <cfs_update>
    yield();
    80002d2c:	fffff097          	auipc	ra,0xfffff
    80002d30:	564080e7          	jalr	1380(ra) # 80002290 <yield>
    80002d34:	b78d                	j	80002c96 <usertrap+0xb0>
      myproc()->accumulator+=myproc()->ps_priority;
    80002d36:	fffff097          	auipc	ra,0xfffff
    80002d3a:	caa080e7          	jalr	-854(ra) # 800019e0 <myproc>
    80002d3e:	7524                	ld	s1,104(a0)
    80002d40:	fffff097          	auipc	ra,0xfffff
    80002d44:	ca0080e7          	jalr	-864(ra) # 800019e0 <myproc>
    80002d48:	713c                	ld	a5,96(a0)
    80002d4a:	97a6                	add	a5,a5,s1
    80002d4c:	f13c                	sd	a5,96(a0)
    80002d4e:	b7d9                	j	80002d14 <usertrap+0x12e>

0000000080002d50 <kerneltrap>:
{
    80002d50:	7179                	addi	sp,sp,-48
    80002d52:	f406                	sd	ra,40(sp)
    80002d54:	f022                	sd	s0,32(sp)
    80002d56:	ec26                	sd	s1,24(sp)
    80002d58:	e84a                	sd	s2,16(sp)
    80002d5a:	e44e                	sd	s3,8(sp)
    80002d5c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d5e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d62:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d66:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002d6a:	1004f793          	andi	a5,s1,256
    80002d6e:	cb85                	beqz	a5,80002d9e <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d70:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002d74:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002d76:	ef85                	bnez	a5,80002dae <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002d78:	00000097          	auipc	ra,0x0
    80002d7c:	dcc080e7          	jalr	-564(ra) # 80002b44 <devintr>
    80002d80:	cd1d                	beqz	a0,80002dbe <kerneltrap+0x6e>
  if(which_dev == 2){
    80002d82:	4789                	li	a5,2
    80002d84:	06f50a63          	beq	a0,a5,80002df8 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002d88:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d8c:	10049073          	csrw	sstatus,s1
}
    80002d90:	70a2                	ld	ra,40(sp)
    80002d92:	7402                	ld	s0,32(sp)
    80002d94:	64e2                	ld	s1,24(sp)
    80002d96:	6942                	ld	s2,16(sp)
    80002d98:	69a2                	ld	s3,8(sp)
    80002d9a:	6145                	addi	sp,sp,48
    80002d9c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002d9e:	00005517          	auipc	a0,0x5
    80002da2:	5f250513          	addi	a0,a0,1522 # 80008390 <states.0+0xc0>
    80002da6:	ffffd097          	auipc	ra,0xffffd
    80002daa:	798080e7          	jalr	1944(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002dae:	00005517          	auipc	a0,0x5
    80002db2:	60a50513          	addi	a0,a0,1546 # 800083b8 <states.0+0xe8>
    80002db6:	ffffd097          	auipc	ra,0xffffd
    80002dba:	788080e7          	jalr	1928(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002dbe:	85ce                	mv	a1,s3
    80002dc0:	00005517          	auipc	a0,0x5
    80002dc4:	61850513          	addi	a0,a0,1560 # 800083d8 <states.0+0x108>
    80002dc8:	ffffd097          	auipc	ra,0xffffd
    80002dcc:	7c0080e7          	jalr	1984(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002dd0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002dd4:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002dd8:	00005517          	auipc	a0,0x5
    80002ddc:	61050513          	addi	a0,a0,1552 # 800083e8 <states.0+0x118>
    80002de0:	ffffd097          	auipc	ra,0xffffd
    80002de4:	7a8080e7          	jalr	1960(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002de8:	00005517          	auipc	a0,0x5
    80002dec:	61850513          	addi	a0,a0,1560 # 80008400 <states.0+0x130>
    80002df0:	ffffd097          	auipc	ra,0xffffd
    80002df4:	74e080e7          	jalr	1870(ra) # 8000053e <panic>
    cfs_update();
    80002df8:	fffff097          	auipc	ra,0xfffff
    80002dfc:	538080e7          	jalr	1336(ra) # 80002330 <cfs_update>
    if(myproc() != 0 && myproc()->state == RUNNING){
    80002e00:	fffff097          	auipc	ra,0xfffff
    80002e04:	be0080e7          	jalr	-1056(ra) # 800019e0 <myproc>
    80002e08:	d141                	beqz	a0,80002d88 <kerneltrap+0x38>
    80002e0a:	fffff097          	auipc	ra,0xfffff
    80002e0e:	bd6080e7          	jalr	-1066(ra) # 800019e0 <myproc>
    80002e12:	4d18                	lw	a4,24(a0)
    80002e14:	4791                	li	a5,4
    80002e16:	f6f719e3          	bne	a4,a5,80002d88 <kerneltrap+0x38>
      acquire(&myproc()->lock);
    80002e1a:	fffff097          	auipc	ra,0xfffff
    80002e1e:	bc6080e7          	jalr	-1082(ra) # 800019e0 <myproc>
    80002e22:	ffffe097          	auipc	ra,0xffffe
    80002e26:	db4080e7          	jalr	-588(ra) # 80000bd6 <acquire>
      if (myproc()->accumulator<10)
    80002e2a:	fffff097          	auipc	ra,0xfffff
    80002e2e:	bb6080e7          	jalr	-1098(ra) # 800019e0 <myproc>
    80002e32:	7138                	ld	a4,96(a0)
    80002e34:	47a5                	li	a5,9
    80002e36:	00e7df63          	bge	a5,a4,80002e54 <kerneltrap+0x104>
      release(&myproc()->lock);
    80002e3a:	fffff097          	auipc	ra,0xfffff
    80002e3e:	ba6080e7          	jalr	-1114(ra) # 800019e0 <myproc>
    80002e42:	ffffe097          	auipc	ra,0xffffe
    80002e46:	e48080e7          	jalr	-440(ra) # 80000c8a <release>
      yield();
    80002e4a:	fffff097          	auipc	ra,0xfffff
    80002e4e:	446080e7          	jalr	1094(ra) # 80002290 <yield>
    80002e52:	bf1d                	j	80002d88 <kerneltrap+0x38>
        myproc()->accumulator+=myproc()->ps_priority;
    80002e54:	fffff097          	auipc	ra,0xfffff
    80002e58:	b8c080e7          	jalr	-1140(ra) # 800019e0 <myproc>
    80002e5c:	06853983          	ld	s3,104(a0)
    80002e60:	fffff097          	auipc	ra,0xfffff
    80002e64:	b80080e7          	jalr	-1152(ra) # 800019e0 <myproc>
    80002e68:	713c                	ld	a5,96(a0)
    80002e6a:	97ce                	add	a5,a5,s3
    80002e6c:	f13c                	sd	a5,96(a0)
    80002e6e:	b7f1                	j	80002e3a <kerneltrap+0xea>

0000000080002e70 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002e70:	1101                	addi	sp,sp,-32
    80002e72:	ec06                	sd	ra,24(sp)
    80002e74:	e822                	sd	s0,16(sp)
    80002e76:	e426                	sd	s1,8(sp)
    80002e78:	1000                	addi	s0,sp,32
    80002e7a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002e7c:	fffff097          	auipc	ra,0xfffff
    80002e80:	b64080e7          	jalr	-1180(ra) # 800019e0 <myproc>
  switch (n) {
    80002e84:	4795                	li	a5,5
    80002e86:	0497e163          	bltu	a5,s1,80002ec8 <argraw+0x58>
    80002e8a:	048a                	slli	s1,s1,0x2
    80002e8c:	00005717          	auipc	a4,0x5
    80002e90:	5ac70713          	addi	a4,a4,1452 # 80008438 <states.0+0x168>
    80002e94:	94ba                	add	s1,s1,a4
    80002e96:	409c                	lw	a5,0(s1)
    80002e98:	97ba                	add	a5,a5,a4
    80002e9a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002e9c:	6d5c                	ld	a5,152(a0)
    80002e9e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002ea0:	60e2                	ld	ra,24(sp)
    80002ea2:	6442                	ld	s0,16(sp)
    80002ea4:	64a2                	ld	s1,8(sp)
    80002ea6:	6105                	addi	sp,sp,32
    80002ea8:	8082                	ret
    return p->trapframe->a1;
    80002eaa:	6d5c                	ld	a5,152(a0)
    80002eac:	7fa8                	ld	a0,120(a5)
    80002eae:	bfcd                	j	80002ea0 <argraw+0x30>
    return p->trapframe->a2;
    80002eb0:	6d5c                	ld	a5,152(a0)
    80002eb2:	63c8                	ld	a0,128(a5)
    80002eb4:	b7f5                	j	80002ea0 <argraw+0x30>
    return p->trapframe->a3;
    80002eb6:	6d5c                	ld	a5,152(a0)
    80002eb8:	67c8                	ld	a0,136(a5)
    80002eba:	b7dd                	j	80002ea0 <argraw+0x30>
    return p->trapframe->a4;
    80002ebc:	6d5c                	ld	a5,152(a0)
    80002ebe:	6bc8                	ld	a0,144(a5)
    80002ec0:	b7c5                	j	80002ea0 <argraw+0x30>
    return p->trapframe->a5;
    80002ec2:	6d5c                	ld	a5,152(a0)
    80002ec4:	6fc8                	ld	a0,152(a5)
    80002ec6:	bfe9                	j	80002ea0 <argraw+0x30>
  panic("argraw");
    80002ec8:	00005517          	auipc	a0,0x5
    80002ecc:	54850513          	addi	a0,a0,1352 # 80008410 <states.0+0x140>
    80002ed0:	ffffd097          	auipc	ra,0xffffd
    80002ed4:	66e080e7          	jalr	1646(ra) # 8000053e <panic>

0000000080002ed8 <fetchaddr>:
{
    80002ed8:	1101                	addi	sp,sp,-32
    80002eda:	ec06                	sd	ra,24(sp)
    80002edc:	e822                	sd	s0,16(sp)
    80002ede:	e426                	sd	s1,8(sp)
    80002ee0:	e04a                	sd	s2,0(sp)
    80002ee2:	1000                	addi	s0,sp,32
    80002ee4:	84aa                	mv	s1,a0
    80002ee6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002ee8:	fffff097          	auipc	ra,0xfffff
    80002eec:	af8080e7          	jalr	-1288(ra) # 800019e0 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002ef0:	655c                	ld	a5,136(a0)
    80002ef2:	02f4f863          	bgeu	s1,a5,80002f22 <fetchaddr+0x4a>
    80002ef6:	00848713          	addi	a4,s1,8
    80002efa:	02e7e663          	bltu	a5,a4,80002f26 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002efe:	46a1                	li	a3,8
    80002f00:	8626                	mv	a2,s1
    80002f02:	85ca                	mv	a1,s2
    80002f04:	6948                	ld	a0,144(a0)
    80002f06:	ffffe097          	auipc	ra,0xffffe
    80002f0a:	7ee080e7          	jalr	2030(ra) # 800016f4 <copyin>
    80002f0e:	00a03533          	snez	a0,a0
    80002f12:	40a00533          	neg	a0,a0
}
    80002f16:	60e2                	ld	ra,24(sp)
    80002f18:	6442                	ld	s0,16(sp)
    80002f1a:	64a2                	ld	s1,8(sp)
    80002f1c:	6902                	ld	s2,0(sp)
    80002f1e:	6105                	addi	sp,sp,32
    80002f20:	8082                	ret
    return -1;
    80002f22:	557d                	li	a0,-1
    80002f24:	bfcd                	j	80002f16 <fetchaddr+0x3e>
    80002f26:	557d                	li	a0,-1
    80002f28:	b7fd                	j	80002f16 <fetchaddr+0x3e>

0000000080002f2a <fetchstr>:
{
    80002f2a:	7179                	addi	sp,sp,-48
    80002f2c:	f406                	sd	ra,40(sp)
    80002f2e:	f022                	sd	s0,32(sp)
    80002f30:	ec26                	sd	s1,24(sp)
    80002f32:	e84a                	sd	s2,16(sp)
    80002f34:	e44e                	sd	s3,8(sp)
    80002f36:	1800                	addi	s0,sp,48
    80002f38:	892a                	mv	s2,a0
    80002f3a:	84ae                	mv	s1,a1
    80002f3c:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002f3e:	fffff097          	auipc	ra,0xfffff
    80002f42:	aa2080e7          	jalr	-1374(ra) # 800019e0 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002f46:	86ce                	mv	a3,s3
    80002f48:	864a                	mv	a2,s2
    80002f4a:	85a6                	mv	a1,s1
    80002f4c:	6948                	ld	a0,144(a0)
    80002f4e:	fffff097          	auipc	ra,0xfffff
    80002f52:	834080e7          	jalr	-1996(ra) # 80001782 <copyinstr>
    80002f56:	00054e63          	bltz	a0,80002f72 <fetchstr+0x48>
  return strlen(buf);
    80002f5a:	8526                	mv	a0,s1
    80002f5c:	ffffe097          	auipc	ra,0xffffe
    80002f60:	ef2080e7          	jalr	-270(ra) # 80000e4e <strlen>
}
    80002f64:	70a2                	ld	ra,40(sp)
    80002f66:	7402                	ld	s0,32(sp)
    80002f68:	64e2                	ld	s1,24(sp)
    80002f6a:	6942                	ld	s2,16(sp)
    80002f6c:	69a2                	ld	s3,8(sp)
    80002f6e:	6145                	addi	sp,sp,48
    80002f70:	8082                	ret
    return -1;
    80002f72:	557d                	li	a0,-1
    80002f74:	bfc5                	j	80002f64 <fetchstr+0x3a>

0000000080002f76 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002f76:	1101                	addi	sp,sp,-32
    80002f78:	ec06                	sd	ra,24(sp)
    80002f7a:	e822                	sd	s0,16(sp)
    80002f7c:	e426                	sd	s1,8(sp)
    80002f7e:	1000                	addi	s0,sp,32
    80002f80:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002f82:	00000097          	auipc	ra,0x0
    80002f86:	eee080e7          	jalr	-274(ra) # 80002e70 <argraw>
    80002f8a:	c088                	sw	a0,0(s1)
}
    80002f8c:	60e2                	ld	ra,24(sp)
    80002f8e:	6442                	ld	s0,16(sp)
    80002f90:	64a2                	ld	s1,8(sp)
    80002f92:	6105                	addi	sp,sp,32
    80002f94:	8082                	ret

0000000080002f96 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002f96:	1101                	addi	sp,sp,-32
    80002f98:	ec06                	sd	ra,24(sp)
    80002f9a:	e822                	sd	s0,16(sp)
    80002f9c:	e426                	sd	s1,8(sp)
    80002f9e:	1000                	addi	s0,sp,32
    80002fa0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002fa2:	00000097          	auipc	ra,0x0
    80002fa6:	ece080e7          	jalr	-306(ra) # 80002e70 <argraw>
    80002faa:	e088                	sd	a0,0(s1)
}
    80002fac:	60e2                	ld	ra,24(sp)
    80002fae:	6442                	ld	s0,16(sp)
    80002fb0:	64a2                	ld	s1,8(sp)
    80002fb2:	6105                	addi	sp,sp,32
    80002fb4:	8082                	ret

0000000080002fb6 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002fb6:	7179                	addi	sp,sp,-48
    80002fb8:	f406                	sd	ra,40(sp)
    80002fba:	f022                	sd	s0,32(sp)
    80002fbc:	ec26                	sd	s1,24(sp)
    80002fbe:	e84a                	sd	s2,16(sp)
    80002fc0:	1800                	addi	s0,sp,48
    80002fc2:	84ae                	mv	s1,a1
    80002fc4:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002fc6:	fd840593          	addi	a1,s0,-40
    80002fca:	00000097          	auipc	ra,0x0
    80002fce:	fcc080e7          	jalr	-52(ra) # 80002f96 <argaddr>
  return fetchstr(addr, buf, max);
    80002fd2:	864a                	mv	a2,s2
    80002fd4:	85a6                	mv	a1,s1
    80002fd6:	fd843503          	ld	a0,-40(s0)
    80002fda:	00000097          	auipc	ra,0x0
    80002fde:	f50080e7          	jalr	-176(ra) # 80002f2a <fetchstr>
}
    80002fe2:	70a2                	ld	ra,40(sp)
    80002fe4:	7402                	ld	s0,32(sp)
    80002fe6:	64e2                	ld	s1,24(sp)
    80002fe8:	6942                	ld	s2,16(sp)
    80002fea:	6145                	addi	sp,sp,48
    80002fec:	8082                	ret

0000000080002fee <syscall>:
[SYS_get_ps_priority] sys_get_ps_priority,
};

void
syscall(void)
{
    80002fee:	1101                	addi	sp,sp,-32
    80002ff0:	ec06                	sd	ra,24(sp)
    80002ff2:	e822                	sd	s0,16(sp)
    80002ff4:	e426                	sd	s1,8(sp)
    80002ff6:	e04a                	sd	s2,0(sp)
    80002ff8:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002ffa:	fffff097          	auipc	ra,0xfffff
    80002ffe:	9e6080e7          	jalr	-1562(ra) # 800019e0 <myproc>
    80003002:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80003004:	09853903          	ld	s2,152(a0)
    80003008:	0a893783          	ld	a5,168(s2)
    8000300c:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003010:	37fd                	addiw	a5,a5,-1
    80003012:	4769                	li	a4,26
    80003014:	00f76f63          	bltu	a4,a5,80003032 <syscall+0x44>
    80003018:	00369713          	slli	a4,a3,0x3
    8000301c:	00005797          	auipc	a5,0x5
    80003020:	43478793          	addi	a5,a5,1076 # 80008450 <syscalls>
    80003024:	97ba                	add	a5,a5,a4
    80003026:	639c                	ld	a5,0(a5)
    80003028:	c789                	beqz	a5,80003032 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    8000302a:	9782                	jalr	a5
    8000302c:	06a93823          	sd	a0,112(s2)
    80003030:	a839                	j	8000304e <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003032:	19848613          	addi	a2,s1,408
    80003036:	588c                	lw	a1,48(s1)
    80003038:	00005517          	auipc	a0,0x5
    8000303c:	3e050513          	addi	a0,a0,992 # 80008418 <states.0+0x148>
    80003040:	ffffd097          	auipc	ra,0xffffd
    80003044:	548080e7          	jalr	1352(ra) # 80000588 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003048:	6cdc                	ld	a5,152(s1)
    8000304a:	577d                	li	a4,-1
    8000304c:	fbb8                	sd	a4,112(a5)
  }
}
    8000304e:	60e2                	ld	ra,24(sp)
    80003050:	6442                	ld	s0,16(sp)
    80003052:	64a2                	ld	s1,8(sp)
    80003054:	6902                	ld	s2,0(sp)
    80003056:	6105                	addi	sp,sp,32
    80003058:	8082                	ret

000000008000305a <sys_memsize>:
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
uint64
sys_memsize(void)
{
    8000305a:	1141                	addi	sp,sp,-16
    8000305c:	e406                	sd	ra,8(sp)
    8000305e:	e022                	sd	s0,0(sp)
    80003060:	0800                	addi	s0,sp,16
  return myproc()->sz;
    80003062:	fffff097          	auipc	ra,0xfffff
    80003066:	97e080e7          	jalr	-1666(ra) # 800019e0 <myproc>
}
    8000306a:	6548                	ld	a0,136(a0)
    8000306c:	60a2                	ld	ra,8(sp)
    8000306e:	6402                	ld	s0,0(sp)
    80003070:	0141                	addi	sp,sp,16
    80003072:	8082                	ret

0000000080003074 <sys_exit>:
uint64
sys_exit(void)
{
    80003074:	7139                	addi	sp,sp,-64
    80003076:	fc06                	sd	ra,56(sp)
    80003078:	f822                	sd	s0,48(sp)
    8000307a:	0080                	addi	s0,sp,64
  int n;
  char msg[32];
  argint(0, &n);
    8000307c:	fec40593          	addi	a1,s0,-20
    80003080:	4501                	li	a0,0
    80003082:	00000097          	auipc	ra,0x0
    80003086:	ef4080e7          	jalr	-268(ra) # 80002f76 <argint>
  argstr(1,msg,32);
    8000308a:	02000613          	li	a2,32
    8000308e:	fc840593          	addi	a1,s0,-56
    80003092:	4505                	li	a0,1
    80003094:	00000097          	auipc	ra,0x0
    80003098:	f22080e7          	jalr	-222(ra) # 80002fb6 <argstr>
  exit(n, msg);
    8000309c:	fc840593          	addi	a1,s0,-56
    800030a0:	fec42503          	lw	a0,-20(s0)
    800030a4:	fffff097          	auipc	ra,0xfffff
    800030a8:	3f2080e7          	jalr	1010(ra) # 80002496 <exit>
  return 0;  // not reached
}
    800030ac:	4501                	li	a0,0
    800030ae:	70e2                	ld	ra,56(sp)
    800030b0:	7442                	ld	s0,48(sp)
    800030b2:	6121                	addi	sp,sp,64
    800030b4:	8082                	ret

00000000800030b6 <sys_set_cfs_priority>:
uint64 
sys_set_cfs_priority(void) { //task6
    800030b6:	1101                	addi	sp,sp,-32
    800030b8:	ec06                	sd	ra,24(sp)
    800030ba:	e822                	sd	s0,16(sp)
    800030bc:	1000                	addi	s0,sp,32
  int priority;
  argint(0, &priority);
    800030be:	fec40593          	addi	a1,s0,-20
    800030c2:	4501                	li	a0,0
    800030c4:	00000097          	auipc	ra,0x0
    800030c8:	eb2080e7          	jalr	-334(ra) # 80002f76 <argint>
  if (priority >2 || priority<0){
    800030cc:	fec42703          	lw	a4,-20(s0)
    800030d0:	4789                	li	a5,2
    return -1;
    800030d2:	557d                	li	a0,-1
  if (priority >2 || priority<0){
    800030d4:	02e7ea63          	bltu	a5,a4,80003108 <sys_set_cfs_priority+0x52>
  }
  acquire(& myproc()->lock);
    800030d8:	fffff097          	auipc	ra,0xfffff
    800030dc:	908080e7          	jalr	-1784(ra) # 800019e0 <myproc>
    800030e0:	ffffe097          	auipc	ra,0xffffe
    800030e4:	af6080e7          	jalr	-1290(ra) # 80000bd6 <acquire>
  myproc()->cfs_priority=priority;
    800030e8:	fffff097          	auipc	ra,0xfffff
    800030ec:	8f8080e7          	jalr	-1800(ra) # 800019e0 <myproc>
    800030f0:	fec42783          	lw	a5,-20(s0)
    800030f4:	d93c                	sw	a5,112(a0)
  release(& myproc()->lock);
    800030f6:	fffff097          	auipc	ra,0xfffff
    800030fa:	8ea080e7          	jalr	-1814(ra) # 800019e0 <myproc>
    800030fe:	ffffe097          	auipc	ra,0xffffe
    80003102:	b8c080e7          	jalr	-1140(ra) # 80000c8a <release>
  return 0;
    80003106:	4501                	li	a0,0
}
    80003108:	60e2                	ld	ra,24(sp)
    8000310a:	6442                	ld	s0,16(sp)
    8000310c:	6105                	addi	sp,sp,32
    8000310e:	8082                	ret

0000000080003110 <sys_get_cfs_stats>:

uint64
sys_get_cfs_stats(void){//task6
    80003110:	1101                	addi	sp,sp,-32
    80003112:	ec06                	sd	ra,24(sp)
    80003114:	e822                	sd	s0,16(sp)
    80003116:	1000                	addi	s0,sp,32
  uint64 add;
  argaddr(0, &add);
    80003118:	fe840593          	addi	a1,s0,-24
    8000311c:	4501                	li	a0,0
    8000311e:	00000097          	auipc	ra,0x0
    80003122:	e78080e7          	jalr	-392(ra) # 80002f96 <argaddr>
  int pid;
  argint(1,&pid);
    80003126:	fe440593          	addi	a1,s0,-28
    8000312a:	4505                	li	a0,1
    8000312c:	00000097          	auipc	ra,0x0
    80003130:	e4a080e7          	jalr	-438(ra) # 80002f76 <argint>
  return get_cfs_stats(add,pid);
    80003134:	fe442583          	lw	a1,-28(s0)
    80003138:	fe843503          	ld	a0,-24(s0)
    8000313c:	fffff097          	auipc	ra,0xfffff
    80003140:	732080e7          	jalr	1842(ra) # 8000286e <get_cfs_stats>
}
    80003144:	60e2                	ld	ra,24(sp)
    80003146:	6442                	ld	s0,16(sp)
    80003148:	6105                	addi	sp,sp,32
    8000314a:	8082                	ret

000000008000314c <sys_set_policy>:

uint64
sys_set_policy(void){//task7 
    8000314c:	1101                	addi	sp,sp,-32
    8000314e:	ec06                	sd	ra,24(sp)
    80003150:	e822                	sd	s0,16(sp)
    80003152:	1000                	addi	s0,sp,32
  int policy;
  argint(0,&policy);
    80003154:	fec40593          	addi	a1,s0,-20
    80003158:	4501                	li	a0,0
    8000315a:	00000097          	auipc	ra,0x0
    8000315e:	e1c080e7          	jalr	-484(ra) # 80002f76 <argint>
  if (policy >2 || policy<0){
    80003162:	fec42783          	lw	a5,-20(s0)
    80003166:	0007869b          	sext.w	a3,a5
    8000316a:	4709                	li	a4,2
    return -1;
    8000316c:	557d                	li	a0,-1
  if (policy >2 || policy<0){
    8000316e:	00d76763          	bltu	a4,a3,8000317c <sys_set_policy+0x30>
  }
  return set_policy(policy);
    80003172:	853e                	mv	a0,a5
    80003174:	fffff097          	auipc	ra,0xfffff
    80003178:	856080e7          	jalr	-1962(ra) # 800019ca <set_policy>
}
    8000317c:	60e2                	ld	ra,24(sp)
    8000317e:	6442                	ld	s0,16(sp)
    80003180:	6105                	addi	sp,sp,32
    80003182:	8082                	ret

0000000080003184 <sys_set_ps_priority>:
// uint64
// get_ps_priority(void){

// }
uint64 
sys_set_ps_priority(void) {//task5
    80003184:	7179                	addi	sp,sp,-48
    80003186:	f406                	sd	ra,40(sp)
    80003188:	f022                	sd	s0,32(sp)
    8000318a:	ec26                	sd	s1,24(sp)
    8000318c:	1800                	addi	s0,sp,48
  int priority;
  argint(0, &priority);
    8000318e:	fdc40593          	addi	a1,s0,-36
    80003192:	4501                	li	a0,0
    80003194:	00000097          	auipc	ra,0x0
    80003198:	de2080e7          	jalr	-542(ra) # 80002f76 <argint>
  if (priority < 1 || priority > 10) {
    8000319c:	fdc42783          	lw	a5,-36(s0)
    800031a0:	37fd                	addiw	a5,a5,-1
    800031a2:	4725                	li	a4,9
    return -1;
    800031a4:	557d                	li	a0,-1
  if (priority < 1 || priority > 10) {
    800031a6:	02f76a63          	bltu	a4,a5,800031da <sys_set_ps_priority+0x56>
  }
  acquire(&myproc()->lock);
    800031aa:	fffff097          	auipc	ra,0xfffff
    800031ae:	836080e7          	jalr	-1994(ra) # 800019e0 <myproc>
    800031b2:	ffffe097          	auipc	ra,0xffffe
    800031b6:	a24080e7          	jalr	-1500(ra) # 80000bd6 <acquire>
  myproc()->ps_priority = priority;
    800031ba:	fdc42483          	lw	s1,-36(s0)
    800031be:	fffff097          	auipc	ra,0xfffff
    800031c2:	822080e7          	jalr	-2014(ra) # 800019e0 <myproc>
    800031c6:	f524                	sd	s1,104(a0)
  release(&myproc()->lock);
    800031c8:	fffff097          	auipc	ra,0xfffff
    800031cc:	818080e7          	jalr	-2024(ra) # 800019e0 <myproc>
    800031d0:	ffffe097          	auipc	ra,0xffffe
    800031d4:	aba080e7          	jalr	-1350(ra) # 80000c8a <release>
  // print the current process's priority
  // printf("Process %d priority set to %d in sysproc.c\n", myproc()->pid, priority);
  return 0;
    800031d8:	4501                	li	a0,0
}
    800031da:	70a2                	ld	ra,40(sp)
    800031dc:	7402                	ld	s0,32(sp)
    800031de:	64e2                	ld	s1,24(sp)
    800031e0:	6145                	addi	sp,sp,48
    800031e2:	8082                	ret

00000000800031e4 <sys_get_ps_priority>:
int
sys_get_ps_priority(void)//test 5
{
    800031e4:	1101                	addi	sp,sp,-32
    800031e6:	ec06                	sd	ra,24(sp)
    800031e8:	e822                	sd	s0,16(sp)
    800031ea:	1000                	addi	s0,sp,32
  int pid;
  argint(0, &pid);
    800031ec:	fec40593          	addi	a1,s0,-20
    800031f0:	4501                	li	a0,0
    800031f2:	00000097          	auipc	ra,0x0
    800031f6:	d84080e7          	jalr	-636(ra) # 80002f76 <argint>
  struct proc *p = get_ps_priority(pid);
    800031fa:	fec42503          	lw	a0,-20(s0)
    800031fe:	fffff097          	auipc	ra,0xfffff
    80003202:	cd8080e7          	jalr	-808(ra) # 80001ed6 <get_ps_priority>
  if (p == 0) {
    80003206:	c511                	beqz	a0,80003212 <sys_get_ps_priority+0x2e>
    return -1;
  }
  return p->ps_priority;
    80003208:	5528                	lw	a0,104(a0)
}
    8000320a:	60e2                	ld	ra,24(sp)
    8000320c:	6442                	ld	s0,16(sp)
    8000320e:	6105                	addi	sp,sp,32
    80003210:	8082                	ret
    return -1;
    80003212:	557d                	li	a0,-1
    80003214:	bfdd                	j	8000320a <sys_get_ps_priority+0x26>

0000000080003216 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003216:	1141                	addi	sp,sp,-16
    80003218:	e406                	sd	ra,8(sp)
    8000321a:	e022                	sd	s0,0(sp)
    8000321c:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000321e:	ffffe097          	auipc	ra,0xffffe
    80003222:	7c2080e7          	jalr	1986(ra) # 800019e0 <myproc>
}
    80003226:	5908                	lw	a0,48(a0)
    80003228:	60a2                	ld	ra,8(sp)
    8000322a:	6402                	ld	s0,0(sp)
    8000322c:	0141                	addi	sp,sp,16
    8000322e:	8082                	ret

0000000080003230 <sys_fork>:

uint64
sys_fork(void)
{
    80003230:	1141                	addi	sp,sp,-16
    80003232:	e406                	sd	ra,8(sp)
    80003234:	e022                	sd	s0,0(sp)
    80003236:	0800                	addi	s0,sp,16
  return fork();
    80003238:	fffff097          	auipc	ra,0xfffff
    8000323c:	b5e080e7          	jalr	-1186(ra) # 80001d96 <fork>
}
    80003240:	60a2                	ld	ra,8(sp)
    80003242:	6402                	ld	s0,0(sp)
    80003244:	0141                	addi	sp,sp,16
    80003246:	8082                	ret

0000000080003248 <sys_wait>:

uint64
sys_wait(void)
{
    80003248:	1101                	addi	sp,sp,-32
    8000324a:	ec06                	sd	ra,24(sp)
    8000324c:	e822                	sd	s0,16(sp)
    8000324e:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80003250:	fe840593          	addi	a1,s0,-24
    80003254:	4501                	li	a0,0
    80003256:	00000097          	auipc	ra,0x0
    8000325a:	d40080e7          	jalr	-704(ra) # 80002f96 <argaddr>
  uint64 p2;
  argaddr(1, &p2);
    8000325e:	fe040593          	addi	a1,s0,-32
    80003262:	4505                	li	a0,1
    80003264:	00000097          	auipc	ra,0x0
    80003268:	d32080e7          	jalr	-718(ra) # 80002f96 <argaddr>
  return wait(p,p2);
    8000326c:	fe043583          	ld	a1,-32(s0)
    80003270:	fe843503          	ld	a0,-24(s0)
    80003274:	fffff097          	auipc	ra,0xfffff
    80003278:	3de080e7          	jalr	990(ra) # 80002652 <wait>
}
    8000327c:	60e2                	ld	ra,24(sp)
    8000327e:	6442                	ld	s0,16(sp)
    80003280:	6105                	addi	sp,sp,32
    80003282:	8082                	ret

0000000080003284 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003284:	7179                	addi	sp,sp,-48
    80003286:	f406                	sd	ra,40(sp)
    80003288:	f022                	sd	s0,32(sp)
    8000328a:	ec26                	sd	s1,24(sp)
    8000328c:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    8000328e:	fdc40593          	addi	a1,s0,-36
    80003292:	4501                	li	a0,0
    80003294:	00000097          	auipc	ra,0x0
    80003298:	ce2080e7          	jalr	-798(ra) # 80002f76 <argint>
  addr = myproc()->sz;
    8000329c:	ffffe097          	auipc	ra,0xffffe
    800032a0:	744080e7          	jalr	1860(ra) # 800019e0 <myproc>
    800032a4:	6544                	ld	s1,136(a0)
  if(growproc(n) < 0)
    800032a6:	fdc42503          	lw	a0,-36(s0)
    800032aa:	fffff097          	auipc	ra,0xfffff
    800032ae:	a90080e7          	jalr	-1392(ra) # 80001d3a <growproc>
    800032b2:	00054863          	bltz	a0,800032c2 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    800032b6:	8526                	mv	a0,s1
    800032b8:	70a2                	ld	ra,40(sp)
    800032ba:	7402                	ld	s0,32(sp)
    800032bc:	64e2                	ld	s1,24(sp)
    800032be:	6145                	addi	sp,sp,48
    800032c0:	8082                	ret
    return -1;
    800032c2:	54fd                	li	s1,-1
    800032c4:	bfcd                	j	800032b6 <sys_sbrk+0x32>

00000000800032c6 <sys_sleep>:

uint64
sys_sleep(void)
{
    800032c6:	7139                	addi	sp,sp,-64
    800032c8:	fc06                	sd	ra,56(sp)
    800032ca:	f822                	sd	s0,48(sp)
    800032cc:	f426                	sd	s1,40(sp)
    800032ce:	f04a                	sd	s2,32(sp)
    800032d0:	ec4e                	sd	s3,24(sp)
    800032d2:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800032d4:	fcc40593          	addi	a1,s0,-52
    800032d8:	4501                	li	a0,0
    800032da:	00000097          	auipc	ra,0x0
    800032de:	c9c080e7          	jalr	-868(ra) # 80002f76 <argint>
  acquire(&tickslock);
    800032e2:	00014517          	auipc	a0,0x14
    800032e6:	6ce50513          	addi	a0,a0,1742 # 800179b0 <tickslock>
    800032ea:	ffffe097          	auipc	ra,0xffffe
    800032ee:	8ec080e7          	jalr	-1812(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    800032f2:	00005917          	auipc	s2,0x5
    800032f6:	62692903          	lw	s2,1574(s2) # 80008918 <ticks>
  while(ticks - ticks0 < n){
    800032fa:	fcc42783          	lw	a5,-52(s0)
    800032fe:	cf9d                	beqz	a5,8000333c <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003300:	00014997          	auipc	s3,0x14
    80003304:	6b098993          	addi	s3,s3,1712 # 800179b0 <tickslock>
    80003308:	00005497          	auipc	s1,0x5
    8000330c:	61048493          	addi	s1,s1,1552 # 80008918 <ticks>
    if(killed(myproc())){
    80003310:	ffffe097          	auipc	ra,0xffffe
    80003314:	6d0080e7          	jalr	1744(ra) # 800019e0 <myproc>
    80003318:	fffff097          	auipc	ra,0xfffff
    8000331c:	308080e7          	jalr	776(ra) # 80002620 <killed>
    80003320:	ed15                	bnez	a0,8000335c <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80003322:	85ce                	mv	a1,s3
    80003324:	8526                	mv	a0,s1
    80003326:	fffff097          	auipc	ra,0xfffff
    8000332a:	fa6080e7          	jalr	-90(ra) # 800022cc <sleep>
  while(ticks - ticks0 < n){
    8000332e:	409c                	lw	a5,0(s1)
    80003330:	412787bb          	subw	a5,a5,s2
    80003334:	fcc42703          	lw	a4,-52(s0)
    80003338:	fce7ece3          	bltu	a5,a4,80003310 <sys_sleep+0x4a>
  }
  release(&tickslock);
    8000333c:	00014517          	auipc	a0,0x14
    80003340:	67450513          	addi	a0,a0,1652 # 800179b0 <tickslock>
    80003344:	ffffe097          	auipc	ra,0xffffe
    80003348:	946080e7          	jalr	-1722(ra) # 80000c8a <release>
  return 0;
    8000334c:	4501                	li	a0,0
}
    8000334e:	70e2                	ld	ra,56(sp)
    80003350:	7442                	ld	s0,48(sp)
    80003352:	74a2                	ld	s1,40(sp)
    80003354:	7902                	ld	s2,32(sp)
    80003356:	69e2                	ld	s3,24(sp)
    80003358:	6121                	addi	sp,sp,64
    8000335a:	8082                	ret
      release(&tickslock);
    8000335c:	00014517          	auipc	a0,0x14
    80003360:	65450513          	addi	a0,a0,1620 # 800179b0 <tickslock>
    80003364:	ffffe097          	auipc	ra,0xffffe
    80003368:	926080e7          	jalr	-1754(ra) # 80000c8a <release>
      return -1;
    8000336c:	557d                	li	a0,-1
    8000336e:	b7c5                	j	8000334e <sys_sleep+0x88>

0000000080003370 <sys_kill>:

uint64
sys_kill(void)
{
    80003370:	1101                	addi	sp,sp,-32
    80003372:	ec06                	sd	ra,24(sp)
    80003374:	e822                	sd	s0,16(sp)
    80003376:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003378:	fec40593          	addi	a1,s0,-20
    8000337c:	4501                	li	a0,0
    8000337e:	00000097          	auipc	ra,0x0
    80003382:	bf8080e7          	jalr	-1032(ra) # 80002f76 <argint>
  return kill(pid);
    80003386:	fec42503          	lw	a0,-20(s0)
    8000338a:	fffff097          	auipc	ra,0xfffff
    8000338e:	1f8080e7          	jalr	504(ra) # 80002582 <kill>
}
    80003392:	60e2                	ld	ra,24(sp)
    80003394:	6442                	ld	s0,16(sp)
    80003396:	6105                	addi	sp,sp,32
    80003398:	8082                	ret

000000008000339a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000339a:	1101                	addi	sp,sp,-32
    8000339c:	ec06                	sd	ra,24(sp)
    8000339e:	e822                	sd	s0,16(sp)
    800033a0:	e426                	sd	s1,8(sp)
    800033a2:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800033a4:	00014517          	auipc	a0,0x14
    800033a8:	60c50513          	addi	a0,a0,1548 # 800179b0 <tickslock>
    800033ac:	ffffe097          	auipc	ra,0xffffe
    800033b0:	82a080e7          	jalr	-2006(ra) # 80000bd6 <acquire>
  xticks = ticks;
    800033b4:	00005497          	auipc	s1,0x5
    800033b8:	5644a483          	lw	s1,1380(s1) # 80008918 <ticks>
  release(&tickslock);
    800033bc:	00014517          	auipc	a0,0x14
    800033c0:	5f450513          	addi	a0,a0,1524 # 800179b0 <tickslock>
    800033c4:	ffffe097          	auipc	ra,0xffffe
    800033c8:	8c6080e7          	jalr	-1850(ra) # 80000c8a <release>
  return xticks;
}
    800033cc:	02049513          	slli	a0,s1,0x20
    800033d0:	9101                	srli	a0,a0,0x20
    800033d2:	60e2                	ld	ra,24(sp)
    800033d4:	6442                	ld	s0,16(sp)
    800033d6:	64a2                	ld	s1,8(sp)
    800033d8:	6105                	addi	sp,sp,32
    800033da:	8082                	ret

00000000800033dc <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800033dc:	7179                	addi	sp,sp,-48
    800033de:	f406                	sd	ra,40(sp)
    800033e0:	f022                	sd	s0,32(sp)
    800033e2:	ec26                	sd	s1,24(sp)
    800033e4:	e84a                	sd	s2,16(sp)
    800033e6:	e44e                	sd	s3,8(sp)
    800033e8:	e052                	sd	s4,0(sp)
    800033ea:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800033ec:	00005597          	auipc	a1,0x5
    800033f0:	14458593          	addi	a1,a1,324 # 80008530 <syscalls+0xe0>
    800033f4:	00014517          	auipc	a0,0x14
    800033f8:	5d450513          	addi	a0,a0,1492 # 800179c8 <bcache>
    800033fc:	ffffd097          	auipc	ra,0xffffd
    80003400:	74a080e7          	jalr	1866(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003404:	0001c797          	auipc	a5,0x1c
    80003408:	5c478793          	addi	a5,a5,1476 # 8001f9c8 <bcache+0x8000>
    8000340c:	0001d717          	auipc	a4,0x1d
    80003410:	82470713          	addi	a4,a4,-2012 # 8001fc30 <bcache+0x8268>
    80003414:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003418:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000341c:	00014497          	auipc	s1,0x14
    80003420:	5c448493          	addi	s1,s1,1476 # 800179e0 <bcache+0x18>
    b->next = bcache.head.next;
    80003424:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003426:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003428:	00005a17          	auipc	s4,0x5
    8000342c:	110a0a13          	addi	s4,s4,272 # 80008538 <syscalls+0xe8>
    b->next = bcache.head.next;
    80003430:	2b893783          	ld	a5,696(s2)
    80003434:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003436:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000343a:	85d2                	mv	a1,s4
    8000343c:	01048513          	addi	a0,s1,16
    80003440:	00001097          	auipc	ra,0x1
    80003444:	4c4080e7          	jalr	1220(ra) # 80004904 <initsleeplock>
    bcache.head.next->prev = b;
    80003448:	2b893783          	ld	a5,696(s2)
    8000344c:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000344e:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003452:	45848493          	addi	s1,s1,1112
    80003456:	fd349de3          	bne	s1,s3,80003430 <binit+0x54>
  }
}
    8000345a:	70a2                	ld	ra,40(sp)
    8000345c:	7402                	ld	s0,32(sp)
    8000345e:	64e2                	ld	s1,24(sp)
    80003460:	6942                	ld	s2,16(sp)
    80003462:	69a2                	ld	s3,8(sp)
    80003464:	6a02                	ld	s4,0(sp)
    80003466:	6145                	addi	sp,sp,48
    80003468:	8082                	ret

000000008000346a <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000346a:	7179                	addi	sp,sp,-48
    8000346c:	f406                	sd	ra,40(sp)
    8000346e:	f022                	sd	s0,32(sp)
    80003470:	ec26                	sd	s1,24(sp)
    80003472:	e84a                	sd	s2,16(sp)
    80003474:	e44e                	sd	s3,8(sp)
    80003476:	1800                	addi	s0,sp,48
    80003478:	892a                	mv	s2,a0
    8000347a:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000347c:	00014517          	auipc	a0,0x14
    80003480:	54c50513          	addi	a0,a0,1356 # 800179c8 <bcache>
    80003484:	ffffd097          	auipc	ra,0xffffd
    80003488:	752080e7          	jalr	1874(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000348c:	0001c497          	auipc	s1,0x1c
    80003490:	7f44b483          	ld	s1,2036(s1) # 8001fc80 <bcache+0x82b8>
    80003494:	0001c797          	auipc	a5,0x1c
    80003498:	79c78793          	addi	a5,a5,1948 # 8001fc30 <bcache+0x8268>
    8000349c:	02f48f63          	beq	s1,a5,800034da <bread+0x70>
    800034a0:	873e                	mv	a4,a5
    800034a2:	a021                	j	800034aa <bread+0x40>
    800034a4:	68a4                	ld	s1,80(s1)
    800034a6:	02e48a63          	beq	s1,a4,800034da <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800034aa:	449c                	lw	a5,8(s1)
    800034ac:	ff279ce3          	bne	a5,s2,800034a4 <bread+0x3a>
    800034b0:	44dc                	lw	a5,12(s1)
    800034b2:	ff3799e3          	bne	a5,s3,800034a4 <bread+0x3a>
      b->refcnt++;
    800034b6:	40bc                	lw	a5,64(s1)
    800034b8:	2785                	addiw	a5,a5,1
    800034ba:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800034bc:	00014517          	auipc	a0,0x14
    800034c0:	50c50513          	addi	a0,a0,1292 # 800179c8 <bcache>
    800034c4:	ffffd097          	auipc	ra,0xffffd
    800034c8:	7c6080e7          	jalr	1990(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    800034cc:	01048513          	addi	a0,s1,16
    800034d0:	00001097          	auipc	ra,0x1
    800034d4:	46e080e7          	jalr	1134(ra) # 8000493e <acquiresleep>
      return b;
    800034d8:	a8b9                	j	80003536 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800034da:	0001c497          	auipc	s1,0x1c
    800034de:	79e4b483          	ld	s1,1950(s1) # 8001fc78 <bcache+0x82b0>
    800034e2:	0001c797          	auipc	a5,0x1c
    800034e6:	74e78793          	addi	a5,a5,1870 # 8001fc30 <bcache+0x8268>
    800034ea:	00f48863          	beq	s1,a5,800034fa <bread+0x90>
    800034ee:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800034f0:	40bc                	lw	a5,64(s1)
    800034f2:	cf81                	beqz	a5,8000350a <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800034f4:	64a4                	ld	s1,72(s1)
    800034f6:	fee49de3          	bne	s1,a4,800034f0 <bread+0x86>
  panic("bget: no buffers");
    800034fa:	00005517          	auipc	a0,0x5
    800034fe:	04650513          	addi	a0,a0,70 # 80008540 <syscalls+0xf0>
    80003502:	ffffd097          	auipc	ra,0xffffd
    80003506:	03c080e7          	jalr	60(ra) # 8000053e <panic>
      b->dev = dev;
    8000350a:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000350e:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003512:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003516:	4785                	li	a5,1
    80003518:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000351a:	00014517          	auipc	a0,0x14
    8000351e:	4ae50513          	addi	a0,a0,1198 # 800179c8 <bcache>
    80003522:	ffffd097          	auipc	ra,0xffffd
    80003526:	768080e7          	jalr	1896(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    8000352a:	01048513          	addi	a0,s1,16
    8000352e:	00001097          	auipc	ra,0x1
    80003532:	410080e7          	jalr	1040(ra) # 8000493e <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003536:	409c                	lw	a5,0(s1)
    80003538:	cb89                	beqz	a5,8000354a <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000353a:	8526                	mv	a0,s1
    8000353c:	70a2                	ld	ra,40(sp)
    8000353e:	7402                	ld	s0,32(sp)
    80003540:	64e2                	ld	s1,24(sp)
    80003542:	6942                	ld	s2,16(sp)
    80003544:	69a2                	ld	s3,8(sp)
    80003546:	6145                	addi	sp,sp,48
    80003548:	8082                	ret
    virtio_disk_rw(b, 0);
    8000354a:	4581                	li	a1,0
    8000354c:	8526                	mv	a0,s1
    8000354e:	00003097          	auipc	ra,0x3
    80003552:	fe6080e7          	jalr	-26(ra) # 80006534 <virtio_disk_rw>
    b->valid = 1;
    80003556:	4785                	li	a5,1
    80003558:	c09c                	sw	a5,0(s1)
  return b;
    8000355a:	b7c5                	j	8000353a <bread+0xd0>

000000008000355c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000355c:	1101                	addi	sp,sp,-32
    8000355e:	ec06                	sd	ra,24(sp)
    80003560:	e822                	sd	s0,16(sp)
    80003562:	e426                	sd	s1,8(sp)
    80003564:	1000                	addi	s0,sp,32
    80003566:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003568:	0541                	addi	a0,a0,16
    8000356a:	00001097          	auipc	ra,0x1
    8000356e:	46e080e7          	jalr	1134(ra) # 800049d8 <holdingsleep>
    80003572:	cd01                	beqz	a0,8000358a <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003574:	4585                	li	a1,1
    80003576:	8526                	mv	a0,s1
    80003578:	00003097          	auipc	ra,0x3
    8000357c:	fbc080e7          	jalr	-68(ra) # 80006534 <virtio_disk_rw>
}
    80003580:	60e2                	ld	ra,24(sp)
    80003582:	6442                	ld	s0,16(sp)
    80003584:	64a2                	ld	s1,8(sp)
    80003586:	6105                	addi	sp,sp,32
    80003588:	8082                	ret
    panic("bwrite");
    8000358a:	00005517          	auipc	a0,0x5
    8000358e:	fce50513          	addi	a0,a0,-50 # 80008558 <syscalls+0x108>
    80003592:	ffffd097          	auipc	ra,0xffffd
    80003596:	fac080e7          	jalr	-84(ra) # 8000053e <panic>

000000008000359a <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000359a:	1101                	addi	sp,sp,-32
    8000359c:	ec06                	sd	ra,24(sp)
    8000359e:	e822                	sd	s0,16(sp)
    800035a0:	e426                	sd	s1,8(sp)
    800035a2:	e04a                	sd	s2,0(sp)
    800035a4:	1000                	addi	s0,sp,32
    800035a6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800035a8:	01050913          	addi	s2,a0,16
    800035ac:	854a                	mv	a0,s2
    800035ae:	00001097          	auipc	ra,0x1
    800035b2:	42a080e7          	jalr	1066(ra) # 800049d8 <holdingsleep>
    800035b6:	c92d                	beqz	a0,80003628 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800035b8:	854a                	mv	a0,s2
    800035ba:	00001097          	auipc	ra,0x1
    800035be:	3da080e7          	jalr	986(ra) # 80004994 <releasesleep>

  acquire(&bcache.lock);
    800035c2:	00014517          	auipc	a0,0x14
    800035c6:	40650513          	addi	a0,a0,1030 # 800179c8 <bcache>
    800035ca:	ffffd097          	auipc	ra,0xffffd
    800035ce:	60c080e7          	jalr	1548(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800035d2:	40bc                	lw	a5,64(s1)
    800035d4:	37fd                	addiw	a5,a5,-1
    800035d6:	0007871b          	sext.w	a4,a5
    800035da:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800035dc:	eb05                	bnez	a4,8000360c <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800035de:	68bc                	ld	a5,80(s1)
    800035e0:	64b8                	ld	a4,72(s1)
    800035e2:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800035e4:	64bc                	ld	a5,72(s1)
    800035e6:	68b8                	ld	a4,80(s1)
    800035e8:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800035ea:	0001c797          	auipc	a5,0x1c
    800035ee:	3de78793          	addi	a5,a5,990 # 8001f9c8 <bcache+0x8000>
    800035f2:	2b87b703          	ld	a4,696(a5)
    800035f6:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800035f8:	0001c717          	auipc	a4,0x1c
    800035fc:	63870713          	addi	a4,a4,1592 # 8001fc30 <bcache+0x8268>
    80003600:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003602:	2b87b703          	ld	a4,696(a5)
    80003606:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003608:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000360c:	00014517          	auipc	a0,0x14
    80003610:	3bc50513          	addi	a0,a0,956 # 800179c8 <bcache>
    80003614:	ffffd097          	auipc	ra,0xffffd
    80003618:	676080e7          	jalr	1654(ra) # 80000c8a <release>
}
    8000361c:	60e2                	ld	ra,24(sp)
    8000361e:	6442                	ld	s0,16(sp)
    80003620:	64a2                	ld	s1,8(sp)
    80003622:	6902                	ld	s2,0(sp)
    80003624:	6105                	addi	sp,sp,32
    80003626:	8082                	ret
    panic("brelse");
    80003628:	00005517          	auipc	a0,0x5
    8000362c:	f3850513          	addi	a0,a0,-200 # 80008560 <syscalls+0x110>
    80003630:	ffffd097          	auipc	ra,0xffffd
    80003634:	f0e080e7          	jalr	-242(ra) # 8000053e <panic>

0000000080003638 <bpin>:

void
bpin(struct buf *b) {
    80003638:	1101                	addi	sp,sp,-32
    8000363a:	ec06                	sd	ra,24(sp)
    8000363c:	e822                	sd	s0,16(sp)
    8000363e:	e426                	sd	s1,8(sp)
    80003640:	1000                	addi	s0,sp,32
    80003642:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003644:	00014517          	auipc	a0,0x14
    80003648:	38450513          	addi	a0,a0,900 # 800179c8 <bcache>
    8000364c:	ffffd097          	auipc	ra,0xffffd
    80003650:	58a080e7          	jalr	1418(ra) # 80000bd6 <acquire>
  b->refcnt++;
    80003654:	40bc                	lw	a5,64(s1)
    80003656:	2785                	addiw	a5,a5,1
    80003658:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000365a:	00014517          	auipc	a0,0x14
    8000365e:	36e50513          	addi	a0,a0,878 # 800179c8 <bcache>
    80003662:	ffffd097          	auipc	ra,0xffffd
    80003666:	628080e7          	jalr	1576(ra) # 80000c8a <release>
}
    8000366a:	60e2                	ld	ra,24(sp)
    8000366c:	6442                	ld	s0,16(sp)
    8000366e:	64a2                	ld	s1,8(sp)
    80003670:	6105                	addi	sp,sp,32
    80003672:	8082                	ret

0000000080003674 <bunpin>:

void
bunpin(struct buf *b) {
    80003674:	1101                	addi	sp,sp,-32
    80003676:	ec06                	sd	ra,24(sp)
    80003678:	e822                	sd	s0,16(sp)
    8000367a:	e426                	sd	s1,8(sp)
    8000367c:	1000                	addi	s0,sp,32
    8000367e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003680:	00014517          	auipc	a0,0x14
    80003684:	34850513          	addi	a0,a0,840 # 800179c8 <bcache>
    80003688:	ffffd097          	auipc	ra,0xffffd
    8000368c:	54e080e7          	jalr	1358(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80003690:	40bc                	lw	a5,64(s1)
    80003692:	37fd                	addiw	a5,a5,-1
    80003694:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003696:	00014517          	auipc	a0,0x14
    8000369a:	33250513          	addi	a0,a0,818 # 800179c8 <bcache>
    8000369e:	ffffd097          	auipc	ra,0xffffd
    800036a2:	5ec080e7          	jalr	1516(ra) # 80000c8a <release>
}
    800036a6:	60e2                	ld	ra,24(sp)
    800036a8:	6442                	ld	s0,16(sp)
    800036aa:	64a2                	ld	s1,8(sp)
    800036ac:	6105                	addi	sp,sp,32
    800036ae:	8082                	ret

00000000800036b0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800036b0:	1101                	addi	sp,sp,-32
    800036b2:	ec06                	sd	ra,24(sp)
    800036b4:	e822                	sd	s0,16(sp)
    800036b6:	e426                	sd	s1,8(sp)
    800036b8:	e04a                	sd	s2,0(sp)
    800036ba:	1000                	addi	s0,sp,32
    800036bc:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800036be:	00d5d59b          	srliw	a1,a1,0xd
    800036c2:	0001d797          	auipc	a5,0x1d
    800036c6:	9e27a783          	lw	a5,-1566(a5) # 800200a4 <sb+0x1c>
    800036ca:	9dbd                	addw	a1,a1,a5
    800036cc:	00000097          	auipc	ra,0x0
    800036d0:	d9e080e7          	jalr	-610(ra) # 8000346a <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800036d4:	0074f713          	andi	a4,s1,7
    800036d8:	4785                	li	a5,1
    800036da:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800036de:	14ce                	slli	s1,s1,0x33
    800036e0:	90d9                	srli	s1,s1,0x36
    800036e2:	00950733          	add	a4,a0,s1
    800036e6:	05874703          	lbu	a4,88(a4)
    800036ea:	00e7f6b3          	and	a3,a5,a4
    800036ee:	c69d                	beqz	a3,8000371c <bfree+0x6c>
    800036f0:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800036f2:	94aa                	add	s1,s1,a0
    800036f4:	fff7c793          	not	a5,a5
    800036f8:	8ff9                	and	a5,a5,a4
    800036fa:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800036fe:	00001097          	auipc	ra,0x1
    80003702:	120080e7          	jalr	288(ra) # 8000481e <log_write>
  brelse(bp);
    80003706:	854a                	mv	a0,s2
    80003708:	00000097          	auipc	ra,0x0
    8000370c:	e92080e7          	jalr	-366(ra) # 8000359a <brelse>
}
    80003710:	60e2                	ld	ra,24(sp)
    80003712:	6442                	ld	s0,16(sp)
    80003714:	64a2                	ld	s1,8(sp)
    80003716:	6902                	ld	s2,0(sp)
    80003718:	6105                	addi	sp,sp,32
    8000371a:	8082                	ret
    panic("freeing free block");
    8000371c:	00005517          	auipc	a0,0x5
    80003720:	e4c50513          	addi	a0,a0,-436 # 80008568 <syscalls+0x118>
    80003724:	ffffd097          	auipc	ra,0xffffd
    80003728:	e1a080e7          	jalr	-486(ra) # 8000053e <panic>

000000008000372c <balloc>:
{
    8000372c:	711d                	addi	sp,sp,-96
    8000372e:	ec86                	sd	ra,88(sp)
    80003730:	e8a2                	sd	s0,80(sp)
    80003732:	e4a6                	sd	s1,72(sp)
    80003734:	e0ca                	sd	s2,64(sp)
    80003736:	fc4e                	sd	s3,56(sp)
    80003738:	f852                	sd	s4,48(sp)
    8000373a:	f456                	sd	s5,40(sp)
    8000373c:	f05a                	sd	s6,32(sp)
    8000373e:	ec5e                	sd	s7,24(sp)
    80003740:	e862                	sd	s8,16(sp)
    80003742:	e466                	sd	s9,8(sp)
    80003744:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003746:	0001d797          	auipc	a5,0x1d
    8000374a:	9467a783          	lw	a5,-1722(a5) # 8002008c <sb+0x4>
    8000374e:	10078163          	beqz	a5,80003850 <balloc+0x124>
    80003752:	8baa                	mv	s7,a0
    80003754:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003756:	0001db17          	auipc	s6,0x1d
    8000375a:	932b0b13          	addi	s6,s6,-1742 # 80020088 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000375e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003760:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003762:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003764:	6c89                	lui	s9,0x2
    80003766:	a061                	j	800037ee <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003768:	974a                	add	a4,a4,s2
    8000376a:	8fd5                	or	a5,a5,a3
    8000376c:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003770:	854a                	mv	a0,s2
    80003772:	00001097          	auipc	ra,0x1
    80003776:	0ac080e7          	jalr	172(ra) # 8000481e <log_write>
        brelse(bp);
    8000377a:	854a                	mv	a0,s2
    8000377c:	00000097          	auipc	ra,0x0
    80003780:	e1e080e7          	jalr	-482(ra) # 8000359a <brelse>
  bp = bread(dev, bno);
    80003784:	85a6                	mv	a1,s1
    80003786:	855e                	mv	a0,s7
    80003788:	00000097          	auipc	ra,0x0
    8000378c:	ce2080e7          	jalr	-798(ra) # 8000346a <bread>
    80003790:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003792:	40000613          	li	a2,1024
    80003796:	4581                	li	a1,0
    80003798:	05850513          	addi	a0,a0,88
    8000379c:	ffffd097          	auipc	ra,0xffffd
    800037a0:	536080e7          	jalr	1334(ra) # 80000cd2 <memset>
  log_write(bp);
    800037a4:	854a                	mv	a0,s2
    800037a6:	00001097          	auipc	ra,0x1
    800037aa:	078080e7          	jalr	120(ra) # 8000481e <log_write>
  brelse(bp);
    800037ae:	854a                	mv	a0,s2
    800037b0:	00000097          	auipc	ra,0x0
    800037b4:	dea080e7          	jalr	-534(ra) # 8000359a <brelse>
}
    800037b8:	8526                	mv	a0,s1
    800037ba:	60e6                	ld	ra,88(sp)
    800037bc:	6446                	ld	s0,80(sp)
    800037be:	64a6                	ld	s1,72(sp)
    800037c0:	6906                	ld	s2,64(sp)
    800037c2:	79e2                	ld	s3,56(sp)
    800037c4:	7a42                	ld	s4,48(sp)
    800037c6:	7aa2                	ld	s5,40(sp)
    800037c8:	7b02                	ld	s6,32(sp)
    800037ca:	6be2                	ld	s7,24(sp)
    800037cc:	6c42                	ld	s8,16(sp)
    800037ce:	6ca2                	ld	s9,8(sp)
    800037d0:	6125                	addi	sp,sp,96
    800037d2:	8082                	ret
    brelse(bp);
    800037d4:	854a                	mv	a0,s2
    800037d6:	00000097          	auipc	ra,0x0
    800037da:	dc4080e7          	jalr	-572(ra) # 8000359a <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800037de:	015c87bb          	addw	a5,s9,s5
    800037e2:	00078a9b          	sext.w	s5,a5
    800037e6:	004b2703          	lw	a4,4(s6)
    800037ea:	06eaf363          	bgeu	s5,a4,80003850 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    800037ee:	41fad79b          	sraiw	a5,s5,0x1f
    800037f2:	0137d79b          	srliw	a5,a5,0x13
    800037f6:	015787bb          	addw	a5,a5,s5
    800037fa:	40d7d79b          	sraiw	a5,a5,0xd
    800037fe:	01cb2583          	lw	a1,28(s6)
    80003802:	9dbd                	addw	a1,a1,a5
    80003804:	855e                	mv	a0,s7
    80003806:	00000097          	auipc	ra,0x0
    8000380a:	c64080e7          	jalr	-924(ra) # 8000346a <bread>
    8000380e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003810:	004b2503          	lw	a0,4(s6)
    80003814:	000a849b          	sext.w	s1,s5
    80003818:	8662                	mv	a2,s8
    8000381a:	faa4fde3          	bgeu	s1,a0,800037d4 <balloc+0xa8>
      m = 1 << (bi % 8);
    8000381e:	41f6579b          	sraiw	a5,a2,0x1f
    80003822:	01d7d69b          	srliw	a3,a5,0x1d
    80003826:	00c6873b          	addw	a4,a3,a2
    8000382a:	00777793          	andi	a5,a4,7
    8000382e:	9f95                	subw	a5,a5,a3
    80003830:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003834:	4037571b          	sraiw	a4,a4,0x3
    80003838:	00e906b3          	add	a3,s2,a4
    8000383c:	0586c683          	lbu	a3,88(a3)
    80003840:	00d7f5b3          	and	a1,a5,a3
    80003844:	d195                	beqz	a1,80003768 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003846:	2605                	addiw	a2,a2,1
    80003848:	2485                	addiw	s1,s1,1
    8000384a:	fd4618e3          	bne	a2,s4,8000381a <balloc+0xee>
    8000384e:	b759                	j	800037d4 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003850:	00005517          	auipc	a0,0x5
    80003854:	d3050513          	addi	a0,a0,-720 # 80008580 <syscalls+0x130>
    80003858:	ffffd097          	auipc	ra,0xffffd
    8000385c:	d30080e7          	jalr	-720(ra) # 80000588 <printf>
  return 0;
    80003860:	4481                	li	s1,0
    80003862:	bf99                	j	800037b8 <balloc+0x8c>

0000000080003864 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003864:	7179                	addi	sp,sp,-48
    80003866:	f406                	sd	ra,40(sp)
    80003868:	f022                	sd	s0,32(sp)
    8000386a:	ec26                	sd	s1,24(sp)
    8000386c:	e84a                	sd	s2,16(sp)
    8000386e:	e44e                	sd	s3,8(sp)
    80003870:	e052                	sd	s4,0(sp)
    80003872:	1800                	addi	s0,sp,48
    80003874:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003876:	47ad                	li	a5,11
    80003878:	02b7e763          	bltu	a5,a1,800038a6 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    8000387c:	02059493          	slli	s1,a1,0x20
    80003880:	9081                	srli	s1,s1,0x20
    80003882:	048a                	slli	s1,s1,0x2
    80003884:	94aa                	add	s1,s1,a0
    80003886:	0504a903          	lw	s2,80(s1)
    8000388a:	06091e63          	bnez	s2,80003906 <bmap+0xa2>
      addr = balloc(ip->dev);
    8000388e:	4108                	lw	a0,0(a0)
    80003890:	00000097          	auipc	ra,0x0
    80003894:	e9c080e7          	jalr	-356(ra) # 8000372c <balloc>
    80003898:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000389c:	06090563          	beqz	s2,80003906 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    800038a0:	0524a823          	sw	s2,80(s1)
    800038a4:	a08d                	j	80003906 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    800038a6:	ff45849b          	addiw	s1,a1,-12
    800038aa:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800038ae:	0ff00793          	li	a5,255
    800038b2:	08e7e563          	bltu	a5,a4,8000393c <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800038b6:	08052903          	lw	s2,128(a0)
    800038ba:	00091d63          	bnez	s2,800038d4 <bmap+0x70>
      addr = balloc(ip->dev);
    800038be:	4108                	lw	a0,0(a0)
    800038c0:	00000097          	auipc	ra,0x0
    800038c4:	e6c080e7          	jalr	-404(ra) # 8000372c <balloc>
    800038c8:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800038cc:	02090d63          	beqz	s2,80003906 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800038d0:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800038d4:	85ca                	mv	a1,s2
    800038d6:	0009a503          	lw	a0,0(s3)
    800038da:	00000097          	auipc	ra,0x0
    800038de:	b90080e7          	jalr	-1136(ra) # 8000346a <bread>
    800038e2:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800038e4:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800038e8:	02049593          	slli	a1,s1,0x20
    800038ec:	9181                	srli	a1,a1,0x20
    800038ee:	058a                	slli	a1,a1,0x2
    800038f0:	00b784b3          	add	s1,a5,a1
    800038f4:	0004a903          	lw	s2,0(s1)
    800038f8:	02090063          	beqz	s2,80003918 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800038fc:	8552                	mv	a0,s4
    800038fe:	00000097          	auipc	ra,0x0
    80003902:	c9c080e7          	jalr	-868(ra) # 8000359a <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003906:	854a                	mv	a0,s2
    80003908:	70a2                	ld	ra,40(sp)
    8000390a:	7402                	ld	s0,32(sp)
    8000390c:	64e2                	ld	s1,24(sp)
    8000390e:	6942                	ld	s2,16(sp)
    80003910:	69a2                	ld	s3,8(sp)
    80003912:	6a02                	ld	s4,0(sp)
    80003914:	6145                	addi	sp,sp,48
    80003916:	8082                	ret
      addr = balloc(ip->dev);
    80003918:	0009a503          	lw	a0,0(s3)
    8000391c:	00000097          	auipc	ra,0x0
    80003920:	e10080e7          	jalr	-496(ra) # 8000372c <balloc>
    80003924:	0005091b          	sext.w	s2,a0
      if(addr){
    80003928:	fc090ae3          	beqz	s2,800038fc <bmap+0x98>
        a[bn] = addr;
    8000392c:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003930:	8552                	mv	a0,s4
    80003932:	00001097          	auipc	ra,0x1
    80003936:	eec080e7          	jalr	-276(ra) # 8000481e <log_write>
    8000393a:	b7c9                	j	800038fc <bmap+0x98>
  panic("bmap: out of range");
    8000393c:	00005517          	auipc	a0,0x5
    80003940:	c5c50513          	addi	a0,a0,-932 # 80008598 <syscalls+0x148>
    80003944:	ffffd097          	auipc	ra,0xffffd
    80003948:	bfa080e7          	jalr	-1030(ra) # 8000053e <panic>

000000008000394c <iget>:
{
    8000394c:	7179                	addi	sp,sp,-48
    8000394e:	f406                	sd	ra,40(sp)
    80003950:	f022                	sd	s0,32(sp)
    80003952:	ec26                	sd	s1,24(sp)
    80003954:	e84a                	sd	s2,16(sp)
    80003956:	e44e                	sd	s3,8(sp)
    80003958:	e052                	sd	s4,0(sp)
    8000395a:	1800                	addi	s0,sp,48
    8000395c:	89aa                	mv	s3,a0
    8000395e:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003960:	0001c517          	auipc	a0,0x1c
    80003964:	74850513          	addi	a0,a0,1864 # 800200a8 <itable>
    80003968:	ffffd097          	auipc	ra,0xffffd
    8000396c:	26e080e7          	jalr	622(ra) # 80000bd6 <acquire>
  empty = 0;
    80003970:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003972:	0001c497          	auipc	s1,0x1c
    80003976:	74e48493          	addi	s1,s1,1870 # 800200c0 <itable+0x18>
    8000397a:	0001e697          	auipc	a3,0x1e
    8000397e:	1d668693          	addi	a3,a3,470 # 80021b50 <log>
    80003982:	a039                	j	80003990 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003984:	02090b63          	beqz	s2,800039ba <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003988:	08848493          	addi	s1,s1,136
    8000398c:	02d48a63          	beq	s1,a3,800039c0 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003990:	449c                	lw	a5,8(s1)
    80003992:	fef059e3          	blez	a5,80003984 <iget+0x38>
    80003996:	4098                	lw	a4,0(s1)
    80003998:	ff3716e3          	bne	a4,s3,80003984 <iget+0x38>
    8000399c:	40d8                	lw	a4,4(s1)
    8000399e:	ff4713e3          	bne	a4,s4,80003984 <iget+0x38>
      ip->ref++;
    800039a2:	2785                	addiw	a5,a5,1
    800039a4:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800039a6:	0001c517          	auipc	a0,0x1c
    800039aa:	70250513          	addi	a0,a0,1794 # 800200a8 <itable>
    800039ae:	ffffd097          	auipc	ra,0xffffd
    800039b2:	2dc080e7          	jalr	732(ra) # 80000c8a <release>
      return ip;
    800039b6:	8926                	mv	s2,s1
    800039b8:	a03d                	j	800039e6 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800039ba:	f7f9                	bnez	a5,80003988 <iget+0x3c>
    800039bc:	8926                	mv	s2,s1
    800039be:	b7e9                	j	80003988 <iget+0x3c>
  if(empty == 0)
    800039c0:	02090c63          	beqz	s2,800039f8 <iget+0xac>
  ip->dev = dev;
    800039c4:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800039c8:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800039cc:	4785                	li	a5,1
    800039ce:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800039d2:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800039d6:	0001c517          	auipc	a0,0x1c
    800039da:	6d250513          	addi	a0,a0,1746 # 800200a8 <itable>
    800039de:	ffffd097          	auipc	ra,0xffffd
    800039e2:	2ac080e7          	jalr	684(ra) # 80000c8a <release>
}
    800039e6:	854a                	mv	a0,s2
    800039e8:	70a2                	ld	ra,40(sp)
    800039ea:	7402                	ld	s0,32(sp)
    800039ec:	64e2                	ld	s1,24(sp)
    800039ee:	6942                	ld	s2,16(sp)
    800039f0:	69a2                	ld	s3,8(sp)
    800039f2:	6a02                	ld	s4,0(sp)
    800039f4:	6145                	addi	sp,sp,48
    800039f6:	8082                	ret
    panic("iget: no inodes");
    800039f8:	00005517          	auipc	a0,0x5
    800039fc:	bb850513          	addi	a0,a0,-1096 # 800085b0 <syscalls+0x160>
    80003a00:	ffffd097          	auipc	ra,0xffffd
    80003a04:	b3e080e7          	jalr	-1218(ra) # 8000053e <panic>

0000000080003a08 <fsinit>:
fsinit(int dev) {
    80003a08:	7179                	addi	sp,sp,-48
    80003a0a:	f406                	sd	ra,40(sp)
    80003a0c:	f022                	sd	s0,32(sp)
    80003a0e:	ec26                	sd	s1,24(sp)
    80003a10:	e84a                	sd	s2,16(sp)
    80003a12:	e44e                	sd	s3,8(sp)
    80003a14:	1800                	addi	s0,sp,48
    80003a16:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003a18:	4585                	li	a1,1
    80003a1a:	00000097          	auipc	ra,0x0
    80003a1e:	a50080e7          	jalr	-1456(ra) # 8000346a <bread>
    80003a22:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003a24:	0001c997          	auipc	s3,0x1c
    80003a28:	66498993          	addi	s3,s3,1636 # 80020088 <sb>
    80003a2c:	02000613          	li	a2,32
    80003a30:	05850593          	addi	a1,a0,88
    80003a34:	854e                	mv	a0,s3
    80003a36:	ffffd097          	auipc	ra,0xffffd
    80003a3a:	2f8080e7          	jalr	760(ra) # 80000d2e <memmove>
  brelse(bp);
    80003a3e:	8526                	mv	a0,s1
    80003a40:	00000097          	auipc	ra,0x0
    80003a44:	b5a080e7          	jalr	-1190(ra) # 8000359a <brelse>
  if(sb.magic != FSMAGIC)
    80003a48:	0009a703          	lw	a4,0(s3)
    80003a4c:	102037b7          	lui	a5,0x10203
    80003a50:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003a54:	02f71263          	bne	a4,a5,80003a78 <fsinit+0x70>
  initlog(dev, &sb);
    80003a58:	0001c597          	auipc	a1,0x1c
    80003a5c:	63058593          	addi	a1,a1,1584 # 80020088 <sb>
    80003a60:	854a                	mv	a0,s2
    80003a62:	00001097          	auipc	ra,0x1
    80003a66:	b40080e7          	jalr	-1216(ra) # 800045a2 <initlog>
}
    80003a6a:	70a2                	ld	ra,40(sp)
    80003a6c:	7402                	ld	s0,32(sp)
    80003a6e:	64e2                	ld	s1,24(sp)
    80003a70:	6942                	ld	s2,16(sp)
    80003a72:	69a2                	ld	s3,8(sp)
    80003a74:	6145                	addi	sp,sp,48
    80003a76:	8082                	ret
    panic("invalid file system");
    80003a78:	00005517          	auipc	a0,0x5
    80003a7c:	b4850513          	addi	a0,a0,-1208 # 800085c0 <syscalls+0x170>
    80003a80:	ffffd097          	auipc	ra,0xffffd
    80003a84:	abe080e7          	jalr	-1346(ra) # 8000053e <panic>

0000000080003a88 <iinit>:
{
    80003a88:	7179                	addi	sp,sp,-48
    80003a8a:	f406                	sd	ra,40(sp)
    80003a8c:	f022                	sd	s0,32(sp)
    80003a8e:	ec26                	sd	s1,24(sp)
    80003a90:	e84a                	sd	s2,16(sp)
    80003a92:	e44e                	sd	s3,8(sp)
    80003a94:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003a96:	00005597          	auipc	a1,0x5
    80003a9a:	b4258593          	addi	a1,a1,-1214 # 800085d8 <syscalls+0x188>
    80003a9e:	0001c517          	auipc	a0,0x1c
    80003aa2:	60a50513          	addi	a0,a0,1546 # 800200a8 <itable>
    80003aa6:	ffffd097          	auipc	ra,0xffffd
    80003aaa:	0a0080e7          	jalr	160(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003aae:	0001c497          	auipc	s1,0x1c
    80003ab2:	62248493          	addi	s1,s1,1570 # 800200d0 <itable+0x28>
    80003ab6:	0001e997          	auipc	s3,0x1e
    80003aba:	0aa98993          	addi	s3,s3,170 # 80021b60 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003abe:	00005917          	auipc	s2,0x5
    80003ac2:	b2290913          	addi	s2,s2,-1246 # 800085e0 <syscalls+0x190>
    80003ac6:	85ca                	mv	a1,s2
    80003ac8:	8526                	mv	a0,s1
    80003aca:	00001097          	auipc	ra,0x1
    80003ace:	e3a080e7          	jalr	-454(ra) # 80004904 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003ad2:	08848493          	addi	s1,s1,136
    80003ad6:	ff3498e3          	bne	s1,s3,80003ac6 <iinit+0x3e>
}
    80003ada:	70a2                	ld	ra,40(sp)
    80003adc:	7402                	ld	s0,32(sp)
    80003ade:	64e2                	ld	s1,24(sp)
    80003ae0:	6942                	ld	s2,16(sp)
    80003ae2:	69a2                	ld	s3,8(sp)
    80003ae4:	6145                	addi	sp,sp,48
    80003ae6:	8082                	ret

0000000080003ae8 <ialloc>:
{
    80003ae8:	715d                	addi	sp,sp,-80
    80003aea:	e486                	sd	ra,72(sp)
    80003aec:	e0a2                	sd	s0,64(sp)
    80003aee:	fc26                	sd	s1,56(sp)
    80003af0:	f84a                	sd	s2,48(sp)
    80003af2:	f44e                	sd	s3,40(sp)
    80003af4:	f052                	sd	s4,32(sp)
    80003af6:	ec56                	sd	s5,24(sp)
    80003af8:	e85a                	sd	s6,16(sp)
    80003afa:	e45e                	sd	s7,8(sp)
    80003afc:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003afe:	0001c717          	auipc	a4,0x1c
    80003b02:	59672703          	lw	a4,1430(a4) # 80020094 <sb+0xc>
    80003b06:	4785                	li	a5,1
    80003b08:	04e7fa63          	bgeu	a5,a4,80003b5c <ialloc+0x74>
    80003b0c:	8aaa                	mv	s5,a0
    80003b0e:	8bae                	mv	s7,a1
    80003b10:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003b12:	0001ca17          	auipc	s4,0x1c
    80003b16:	576a0a13          	addi	s4,s4,1398 # 80020088 <sb>
    80003b1a:	00048b1b          	sext.w	s6,s1
    80003b1e:	0044d793          	srli	a5,s1,0x4
    80003b22:	018a2583          	lw	a1,24(s4)
    80003b26:	9dbd                	addw	a1,a1,a5
    80003b28:	8556                	mv	a0,s5
    80003b2a:	00000097          	auipc	ra,0x0
    80003b2e:	940080e7          	jalr	-1728(ra) # 8000346a <bread>
    80003b32:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003b34:	05850993          	addi	s3,a0,88
    80003b38:	00f4f793          	andi	a5,s1,15
    80003b3c:	079a                	slli	a5,a5,0x6
    80003b3e:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003b40:	00099783          	lh	a5,0(s3)
    80003b44:	c3a1                	beqz	a5,80003b84 <ialloc+0x9c>
    brelse(bp);
    80003b46:	00000097          	auipc	ra,0x0
    80003b4a:	a54080e7          	jalr	-1452(ra) # 8000359a <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b4e:	0485                	addi	s1,s1,1
    80003b50:	00ca2703          	lw	a4,12(s4)
    80003b54:	0004879b          	sext.w	a5,s1
    80003b58:	fce7e1e3          	bltu	a5,a4,80003b1a <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003b5c:	00005517          	auipc	a0,0x5
    80003b60:	a8c50513          	addi	a0,a0,-1396 # 800085e8 <syscalls+0x198>
    80003b64:	ffffd097          	auipc	ra,0xffffd
    80003b68:	a24080e7          	jalr	-1500(ra) # 80000588 <printf>
  return 0;
    80003b6c:	4501                	li	a0,0
}
    80003b6e:	60a6                	ld	ra,72(sp)
    80003b70:	6406                	ld	s0,64(sp)
    80003b72:	74e2                	ld	s1,56(sp)
    80003b74:	7942                	ld	s2,48(sp)
    80003b76:	79a2                	ld	s3,40(sp)
    80003b78:	7a02                	ld	s4,32(sp)
    80003b7a:	6ae2                	ld	s5,24(sp)
    80003b7c:	6b42                	ld	s6,16(sp)
    80003b7e:	6ba2                	ld	s7,8(sp)
    80003b80:	6161                	addi	sp,sp,80
    80003b82:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003b84:	04000613          	li	a2,64
    80003b88:	4581                	li	a1,0
    80003b8a:	854e                	mv	a0,s3
    80003b8c:	ffffd097          	auipc	ra,0xffffd
    80003b90:	146080e7          	jalr	326(ra) # 80000cd2 <memset>
      dip->type = type;
    80003b94:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003b98:	854a                	mv	a0,s2
    80003b9a:	00001097          	auipc	ra,0x1
    80003b9e:	c84080e7          	jalr	-892(ra) # 8000481e <log_write>
      brelse(bp);
    80003ba2:	854a                	mv	a0,s2
    80003ba4:	00000097          	auipc	ra,0x0
    80003ba8:	9f6080e7          	jalr	-1546(ra) # 8000359a <brelse>
      return iget(dev, inum);
    80003bac:	85da                	mv	a1,s6
    80003bae:	8556                	mv	a0,s5
    80003bb0:	00000097          	auipc	ra,0x0
    80003bb4:	d9c080e7          	jalr	-612(ra) # 8000394c <iget>
    80003bb8:	bf5d                	j	80003b6e <ialloc+0x86>

0000000080003bba <iupdate>:
{
    80003bba:	1101                	addi	sp,sp,-32
    80003bbc:	ec06                	sd	ra,24(sp)
    80003bbe:	e822                	sd	s0,16(sp)
    80003bc0:	e426                	sd	s1,8(sp)
    80003bc2:	e04a                	sd	s2,0(sp)
    80003bc4:	1000                	addi	s0,sp,32
    80003bc6:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003bc8:	415c                	lw	a5,4(a0)
    80003bca:	0047d79b          	srliw	a5,a5,0x4
    80003bce:	0001c597          	auipc	a1,0x1c
    80003bd2:	4d25a583          	lw	a1,1234(a1) # 800200a0 <sb+0x18>
    80003bd6:	9dbd                	addw	a1,a1,a5
    80003bd8:	4108                	lw	a0,0(a0)
    80003bda:	00000097          	auipc	ra,0x0
    80003bde:	890080e7          	jalr	-1904(ra) # 8000346a <bread>
    80003be2:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003be4:	05850793          	addi	a5,a0,88
    80003be8:	40c8                	lw	a0,4(s1)
    80003bea:	893d                	andi	a0,a0,15
    80003bec:	051a                	slli	a0,a0,0x6
    80003bee:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003bf0:	04449703          	lh	a4,68(s1)
    80003bf4:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003bf8:	04649703          	lh	a4,70(s1)
    80003bfc:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003c00:	04849703          	lh	a4,72(s1)
    80003c04:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003c08:	04a49703          	lh	a4,74(s1)
    80003c0c:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003c10:	44f8                	lw	a4,76(s1)
    80003c12:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003c14:	03400613          	li	a2,52
    80003c18:	05048593          	addi	a1,s1,80
    80003c1c:	0531                	addi	a0,a0,12
    80003c1e:	ffffd097          	auipc	ra,0xffffd
    80003c22:	110080e7          	jalr	272(ra) # 80000d2e <memmove>
  log_write(bp);
    80003c26:	854a                	mv	a0,s2
    80003c28:	00001097          	auipc	ra,0x1
    80003c2c:	bf6080e7          	jalr	-1034(ra) # 8000481e <log_write>
  brelse(bp);
    80003c30:	854a                	mv	a0,s2
    80003c32:	00000097          	auipc	ra,0x0
    80003c36:	968080e7          	jalr	-1688(ra) # 8000359a <brelse>
}
    80003c3a:	60e2                	ld	ra,24(sp)
    80003c3c:	6442                	ld	s0,16(sp)
    80003c3e:	64a2                	ld	s1,8(sp)
    80003c40:	6902                	ld	s2,0(sp)
    80003c42:	6105                	addi	sp,sp,32
    80003c44:	8082                	ret

0000000080003c46 <idup>:
{
    80003c46:	1101                	addi	sp,sp,-32
    80003c48:	ec06                	sd	ra,24(sp)
    80003c4a:	e822                	sd	s0,16(sp)
    80003c4c:	e426                	sd	s1,8(sp)
    80003c4e:	1000                	addi	s0,sp,32
    80003c50:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003c52:	0001c517          	auipc	a0,0x1c
    80003c56:	45650513          	addi	a0,a0,1110 # 800200a8 <itable>
    80003c5a:	ffffd097          	auipc	ra,0xffffd
    80003c5e:	f7c080e7          	jalr	-132(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003c62:	449c                	lw	a5,8(s1)
    80003c64:	2785                	addiw	a5,a5,1
    80003c66:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003c68:	0001c517          	auipc	a0,0x1c
    80003c6c:	44050513          	addi	a0,a0,1088 # 800200a8 <itable>
    80003c70:	ffffd097          	auipc	ra,0xffffd
    80003c74:	01a080e7          	jalr	26(ra) # 80000c8a <release>
}
    80003c78:	8526                	mv	a0,s1
    80003c7a:	60e2                	ld	ra,24(sp)
    80003c7c:	6442                	ld	s0,16(sp)
    80003c7e:	64a2                	ld	s1,8(sp)
    80003c80:	6105                	addi	sp,sp,32
    80003c82:	8082                	ret

0000000080003c84 <ilock>:
{
    80003c84:	1101                	addi	sp,sp,-32
    80003c86:	ec06                	sd	ra,24(sp)
    80003c88:	e822                	sd	s0,16(sp)
    80003c8a:	e426                	sd	s1,8(sp)
    80003c8c:	e04a                	sd	s2,0(sp)
    80003c8e:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003c90:	c115                	beqz	a0,80003cb4 <ilock+0x30>
    80003c92:	84aa                	mv	s1,a0
    80003c94:	451c                	lw	a5,8(a0)
    80003c96:	00f05f63          	blez	a5,80003cb4 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003c9a:	0541                	addi	a0,a0,16
    80003c9c:	00001097          	auipc	ra,0x1
    80003ca0:	ca2080e7          	jalr	-862(ra) # 8000493e <acquiresleep>
  if(ip->valid == 0){
    80003ca4:	40bc                	lw	a5,64(s1)
    80003ca6:	cf99                	beqz	a5,80003cc4 <ilock+0x40>
}
    80003ca8:	60e2                	ld	ra,24(sp)
    80003caa:	6442                	ld	s0,16(sp)
    80003cac:	64a2                	ld	s1,8(sp)
    80003cae:	6902                	ld	s2,0(sp)
    80003cb0:	6105                	addi	sp,sp,32
    80003cb2:	8082                	ret
    panic("ilock");
    80003cb4:	00005517          	auipc	a0,0x5
    80003cb8:	94c50513          	addi	a0,a0,-1716 # 80008600 <syscalls+0x1b0>
    80003cbc:	ffffd097          	auipc	ra,0xffffd
    80003cc0:	882080e7          	jalr	-1918(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003cc4:	40dc                	lw	a5,4(s1)
    80003cc6:	0047d79b          	srliw	a5,a5,0x4
    80003cca:	0001c597          	auipc	a1,0x1c
    80003cce:	3d65a583          	lw	a1,982(a1) # 800200a0 <sb+0x18>
    80003cd2:	9dbd                	addw	a1,a1,a5
    80003cd4:	4088                	lw	a0,0(s1)
    80003cd6:	fffff097          	auipc	ra,0xfffff
    80003cda:	794080e7          	jalr	1940(ra) # 8000346a <bread>
    80003cde:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003ce0:	05850593          	addi	a1,a0,88
    80003ce4:	40dc                	lw	a5,4(s1)
    80003ce6:	8bbd                	andi	a5,a5,15
    80003ce8:	079a                	slli	a5,a5,0x6
    80003cea:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003cec:	00059783          	lh	a5,0(a1)
    80003cf0:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003cf4:	00259783          	lh	a5,2(a1)
    80003cf8:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003cfc:	00459783          	lh	a5,4(a1)
    80003d00:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003d04:	00659783          	lh	a5,6(a1)
    80003d08:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003d0c:	459c                	lw	a5,8(a1)
    80003d0e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003d10:	03400613          	li	a2,52
    80003d14:	05b1                	addi	a1,a1,12
    80003d16:	05048513          	addi	a0,s1,80
    80003d1a:	ffffd097          	auipc	ra,0xffffd
    80003d1e:	014080e7          	jalr	20(ra) # 80000d2e <memmove>
    brelse(bp);
    80003d22:	854a                	mv	a0,s2
    80003d24:	00000097          	auipc	ra,0x0
    80003d28:	876080e7          	jalr	-1930(ra) # 8000359a <brelse>
    ip->valid = 1;
    80003d2c:	4785                	li	a5,1
    80003d2e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003d30:	04449783          	lh	a5,68(s1)
    80003d34:	fbb5                	bnez	a5,80003ca8 <ilock+0x24>
      panic("ilock: no type");
    80003d36:	00005517          	auipc	a0,0x5
    80003d3a:	8d250513          	addi	a0,a0,-1838 # 80008608 <syscalls+0x1b8>
    80003d3e:	ffffd097          	auipc	ra,0xffffd
    80003d42:	800080e7          	jalr	-2048(ra) # 8000053e <panic>

0000000080003d46 <iunlock>:
{
    80003d46:	1101                	addi	sp,sp,-32
    80003d48:	ec06                	sd	ra,24(sp)
    80003d4a:	e822                	sd	s0,16(sp)
    80003d4c:	e426                	sd	s1,8(sp)
    80003d4e:	e04a                	sd	s2,0(sp)
    80003d50:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003d52:	c905                	beqz	a0,80003d82 <iunlock+0x3c>
    80003d54:	84aa                	mv	s1,a0
    80003d56:	01050913          	addi	s2,a0,16
    80003d5a:	854a                	mv	a0,s2
    80003d5c:	00001097          	auipc	ra,0x1
    80003d60:	c7c080e7          	jalr	-900(ra) # 800049d8 <holdingsleep>
    80003d64:	cd19                	beqz	a0,80003d82 <iunlock+0x3c>
    80003d66:	449c                	lw	a5,8(s1)
    80003d68:	00f05d63          	blez	a5,80003d82 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003d6c:	854a                	mv	a0,s2
    80003d6e:	00001097          	auipc	ra,0x1
    80003d72:	c26080e7          	jalr	-986(ra) # 80004994 <releasesleep>
}
    80003d76:	60e2                	ld	ra,24(sp)
    80003d78:	6442                	ld	s0,16(sp)
    80003d7a:	64a2                	ld	s1,8(sp)
    80003d7c:	6902                	ld	s2,0(sp)
    80003d7e:	6105                	addi	sp,sp,32
    80003d80:	8082                	ret
    panic("iunlock");
    80003d82:	00005517          	auipc	a0,0x5
    80003d86:	89650513          	addi	a0,a0,-1898 # 80008618 <syscalls+0x1c8>
    80003d8a:	ffffc097          	auipc	ra,0xffffc
    80003d8e:	7b4080e7          	jalr	1972(ra) # 8000053e <panic>

0000000080003d92 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003d92:	7179                	addi	sp,sp,-48
    80003d94:	f406                	sd	ra,40(sp)
    80003d96:	f022                	sd	s0,32(sp)
    80003d98:	ec26                	sd	s1,24(sp)
    80003d9a:	e84a                	sd	s2,16(sp)
    80003d9c:	e44e                	sd	s3,8(sp)
    80003d9e:	e052                	sd	s4,0(sp)
    80003da0:	1800                	addi	s0,sp,48
    80003da2:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003da4:	05050493          	addi	s1,a0,80
    80003da8:	08050913          	addi	s2,a0,128
    80003dac:	a021                	j	80003db4 <itrunc+0x22>
    80003dae:	0491                	addi	s1,s1,4
    80003db0:	01248d63          	beq	s1,s2,80003dca <itrunc+0x38>
    if(ip->addrs[i]){
    80003db4:	408c                	lw	a1,0(s1)
    80003db6:	dde5                	beqz	a1,80003dae <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003db8:	0009a503          	lw	a0,0(s3)
    80003dbc:	00000097          	auipc	ra,0x0
    80003dc0:	8f4080e7          	jalr	-1804(ra) # 800036b0 <bfree>
      ip->addrs[i] = 0;
    80003dc4:	0004a023          	sw	zero,0(s1)
    80003dc8:	b7dd                	j	80003dae <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003dca:	0809a583          	lw	a1,128(s3)
    80003dce:	e185                	bnez	a1,80003dee <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003dd0:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003dd4:	854e                	mv	a0,s3
    80003dd6:	00000097          	auipc	ra,0x0
    80003dda:	de4080e7          	jalr	-540(ra) # 80003bba <iupdate>
}
    80003dde:	70a2                	ld	ra,40(sp)
    80003de0:	7402                	ld	s0,32(sp)
    80003de2:	64e2                	ld	s1,24(sp)
    80003de4:	6942                	ld	s2,16(sp)
    80003de6:	69a2                	ld	s3,8(sp)
    80003de8:	6a02                	ld	s4,0(sp)
    80003dea:	6145                	addi	sp,sp,48
    80003dec:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003dee:	0009a503          	lw	a0,0(s3)
    80003df2:	fffff097          	auipc	ra,0xfffff
    80003df6:	678080e7          	jalr	1656(ra) # 8000346a <bread>
    80003dfa:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003dfc:	05850493          	addi	s1,a0,88
    80003e00:	45850913          	addi	s2,a0,1112
    80003e04:	a021                	j	80003e0c <itrunc+0x7a>
    80003e06:	0491                	addi	s1,s1,4
    80003e08:	01248b63          	beq	s1,s2,80003e1e <itrunc+0x8c>
      if(a[j])
    80003e0c:	408c                	lw	a1,0(s1)
    80003e0e:	dde5                	beqz	a1,80003e06 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003e10:	0009a503          	lw	a0,0(s3)
    80003e14:	00000097          	auipc	ra,0x0
    80003e18:	89c080e7          	jalr	-1892(ra) # 800036b0 <bfree>
    80003e1c:	b7ed                	j	80003e06 <itrunc+0x74>
    brelse(bp);
    80003e1e:	8552                	mv	a0,s4
    80003e20:	fffff097          	auipc	ra,0xfffff
    80003e24:	77a080e7          	jalr	1914(ra) # 8000359a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003e28:	0809a583          	lw	a1,128(s3)
    80003e2c:	0009a503          	lw	a0,0(s3)
    80003e30:	00000097          	auipc	ra,0x0
    80003e34:	880080e7          	jalr	-1920(ra) # 800036b0 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003e38:	0809a023          	sw	zero,128(s3)
    80003e3c:	bf51                	j	80003dd0 <itrunc+0x3e>

0000000080003e3e <iput>:
{
    80003e3e:	1101                	addi	sp,sp,-32
    80003e40:	ec06                	sd	ra,24(sp)
    80003e42:	e822                	sd	s0,16(sp)
    80003e44:	e426                	sd	s1,8(sp)
    80003e46:	e04a                	sd	s2,0(sp)
    80003e48:	1000                	addi	s0,sp,32
    80003e4a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003e4c:	0001c517          	auipc	a0,0x1c
    80003e50:	25c50513          	addi	a0,a0,604 # 800200a8 <itable>
    80003e54:	ffffd097          	auipc	ra,0xffffd
    80003e58:	d82080e7          	jalr	-638(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e5c:	4498                	lw	a4,8(s1)
    80003e5e:	4785                	li	a5,1
    80003e60:	02f70363          	beq	a4,a5,80003e86 <iput+0x48>
  ip->ref--;
    80003e64:	449c                	lw	a5,8(s1)
    80003e66:	37fd                	addiw	a5,a5,-1
    80003e68:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003e6a:	0001c517          	auipc	a0,0x1c
    80003e6e:	23e50513          	addi	a0,a0,574 # 800200a8 <itable>
    80003e72:	ffffd097          	auipc	ra,0xffffd
    80003e76:	e18080e7          	jalr	-488(ra) # 80000c8a <release>
}
    80003e7a:	60e2                	ld	ra,24(sp)
    80003e7c:	6442                	ld	s0,16(sp)
    80003e7e:	64a2                	ld	s1,8(sp)
    80003e80:	6902                	ld	s2,0(sp)
    80003e82:	6105                	addi	sp,sp,32
    80003e84:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e86:	40bc                	lw	a5,64(s1)
    80003e88:	dff1                	beqz	a5,80003e64 <iput+0x26>
    80003e8a:	04a49783          	lh	a5,74(s1)
    80003e8e:	fbf9                	bnez	a5,80003e64 <iput+0x26>
    acquiresleep(&ip->lock);
    80003e90:	01048913          	addi	s2,s1,16
    80003e94:	854a                	mv	a0,s2
    80003e96:	00001097          	auipc	ra,0x1
    80003e9a:	aa8080e7          	jalr	-1368(ra) # 8000493e <acquiresleep>
    release(&itable.lock);
    80003e9e:	0001c517          	auipc	a0,0x1c
    80003ea2:	20a50513          	addi	a0,a0,522 # 800200a8 <itable>
    80003ea6:	ffffd097          	auipc	ra,0xffffd
    80003eaa:	de4080e7          	jalr	-540(ra) # 80000c8a <release>
    itrunc(ip);
    80003eae:	8526                	mv	a0,s1
    80003eb0:	00000097          	auipc	ra,0x0
    80003eb4:	ee2080e7          	jalr	-286(ra) # 80003d92 <itrunc>
    ip->type = 0;
    80003eb8:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003ebc:	8526                	mv	a0,s1
    80003ebe:	00000097          	auipc	ra,0x0
    80003ec2:	cfc080e7          	jalr	-772(ra) # 80003bba <iupdate>
    ip->valid = 0;
    80003ec6:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003eca:	854a                	mv	a0,s2
    80003ecc:	00001097          	auipc	ra,0x1
    80003ed0:	ac8080e7          	jalr	-1336(ra) # 80004994 <releasesleep>
    acquire(&itable.lock);
    80003ed4:	0001c517          	auipc	a0,0x1c
    80003ed8:	1d450513          	addi	a0,a0,468 # 800200a8 <itable>
    80003edc:	ffffd097          	auipc	ra,0xffffd
    80003ee0:	cfa080e7          	jalr	-774(ra) # 80000bd6 <acquire>
    80003ee4:	b741                	j	80003e64 <iput+0x26>

0000000080003ee6 <iunlockput>:
{
    80003ee6:	1101                	addi	sp,sp,-32
    80003ee8:	ec06                	sd	ra,24(sp)
    80003eea:	e822                	sd	s0,16(sp)
    80003eec:	e426                	sd	s1,8(sp)
    80003eee:	1000                	addi	s0,sp,32
    80003ef0:	84aa                	mv	s1,a0
  iunlock(ip);
    80003ef2:	00000097          	auipc	ra,0x0
    80003ef6:	e54080e7          	jalr	-428(ra) # 80003d46 <iunlock>
  iput(ip);
    80003efa:	8526                	mv	a0,s1
    80003efc:	00000097          	auipc	ra,0x0
    80003f00:	f42080e7          	jalr	-190(ra) # 80003e3e <iput>
}
    80003f04:	60e2                	ld	ra,24(sp)
    80003f06:	6442                	ld	s0,16(sp)
    80003f08:	64a2                	ld	s1,8(sp)
    80003f0a:	6105                	addi	sp,sp,32
    80003f0c:	8082                	ret

0000000080003f0e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003f0e:	1141                	addi	sp,sp,-16
    80003f10:	e422                	sd	s0,8(sp)
    80003f12:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003f14:	411c                	lw	a5,0(a0)
    80003f16:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003f18:	415c                	lw	a5,4(a0)
    80003f1a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003f1c:	04451783          	lh	a5,68(a0)
    80003f20:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003f24:	04a51783          	lh	a5,74(a0)
    80003f28:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003f2c:	04c56783          	lwu	a5,76(a0)
    80003f30:	e99c                	sd	a5,16(a1)
}
    80003f32:	6422                	ld	s0,8(sp)
    80003f34:	0141                	addi	sp,sp,16
    80003f36:	8082                	ret

0000000080003f38 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f38:	457c                	lw	a5,76(a0)
    80003f3a:	0ed7e963          	bltu	a5,a3,8000402c <readi+0xf4>
{
    80003f3e:	7159                	addi	sp,sp,-112
    80003f40:	f486                	sd	ra,104(sp)
    80003f42:	f0a2                	sd	s0,96(sp)
    80003f44:	eca6                	sd	s1,88(sp)
    80003f46:	e8ca                	sd	s2,80(sp)
    80003f48:	e4ce                	sd	s3,72(sp)
    80003f4a:	e0d2                	sd	s4,64(sp)
    80003f4c:	fc56                	sd	s5,56(sp)
    80003f4e:	f85a                	sd	s6,48(sp)
    80003f50:	f45e                	sd	s7,40(sp)
    80003f52:	f062                	sd	s8,32(sp)
    80003f54:	ec66                	sd	s9,24(sp)
    80003f56:	e86a                	sd	s10,16(sp)
    80003f58:	e46e                	sd	s11,8(sp)
    80003f5a:	1880                	addi	s0,sp,112
    80003f5c:	8b2a                	mv	s6,a0
    80003f5e:	8bae                	mv	s7,a1
    80003f60:	8a32                	mv	s4,a2
    80003f62:	84b6                	mv	s1,a3
    80003f64:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003f66:	9f35                	addw	a4,a4,a3
    return 0;
    80003f68:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003f6a:	0ad76063          	bltu	a4,a3,8000400a <readi+0xd2>
  if(off + n > ip->size)
    80003f6e:	00e7f463          	bgeu	a5,a4,80003f76 <readi+0x3e>
    n = ip->size - off;
    80003f72:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f76:	0a0a8963          	beqz	s5,80004028 <readi+0xf0>
    80003f7a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f7c:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003f80:	5c7d                	li	s8,-1
    80003f82:	a82d                	j	80003fbc <readi+0x84>
    80003f84:	020d1d93          	slli	s11,s10,0x20
    80003f88:	020ddd93          	srli	s11,s11,0x20
    80003f8c:	05890793          	addi	a5,s2,88
    80003f90:	86ee                	mv	a3,s11
    80003f92:	963e                	add	a2,a2,a5
    80003f94:	85d2                	mv	a1,s4
    80003f96:	855e                	mv	a0,s7
    80003f98:	fffff097          	auipc	ra,0xfffff
    80003f9c:	82a080e7          	jalr	-2006(ra) # 800027c2 <either_copyout>
    80003fa0:	05850d63          	beq	a0,s8,80003ffa <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003fa4:	854a                	mv	a0,s2
    80003fa6:	fffff097          	auipc	ra,0xfffff
    80003faa:	5f4080e7          	jalr	1524(ra) # 8000359a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003fae:	013d09bb          	addw	s3,s10,s3
    80003fb2:	009d04bb          	addw	s1,s10,s1
    80003fb6:	9a6e                	add	s4,s4,s11
    80003fb8:	0559f763          	bgeu	s3,s5,80004006 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003fbc:	00a4d59b          	srliw	a1,s1,0xa
    80003fc0:	855a                	mv	a0,s6
    80003fc2:	00000097          	auipc	ra,0x0
    80003fc6:	8a2080e7          	jalr	-1886(ra) # 80003864 <bmap>
    80003fca:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003fce:	cd85                	beqz	a1,80004006 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003fd0:	000b2503          	lw	a0,0(s6)
    80003fd4:	fffff097          	auipc	ra,0xfffff
    80003fd8:	496080e7          	jalr	1174(ra) # 8000346a <bread>
    80003fdc:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fde:	3ff4f613          	andi	a2,s1,1023
    80003fe2:	40cc87bb          	subw	a5,s9,a2
    80003fe6:	413a873b          	subw	a4,s5,s3
    80003fea:	8d3e                	mv	s10,a5
    80003fec:	2781                	sext.w	a5,a5
    80003fee:	0007069b          	sext.w	a3,a4
    80003ff2:	f8f6f9e3          	bgeu	a3,a5,80003f84 <readi+0x4c>
    80003ff6:	8d3a                	mv	s10,a4
    80003ff8:	b771                	j	80003f84 <readi+0x4c>
      brelse(bp);
    80003ffa:	854a                	mv	a0,s2
    80003ffc:	fffff097          	auipc	ra,0xfffff
    80004000:	59e080e7          	jalr	1438(ra) # 8000359a <brelse>
      tot = -1;
    80004004:	59fd                	li	s3,-1
  }
  return tot;
    80004006:	0009851b          	sext.w	a0,s3
}
    8000400a:	70a6                	ld	ra,104(sp)
    8000400c:	7406                	ld	s0,96(sp)
    8000400e:	64e6                	ld	s1,88(sp)
    80004010:	6946                	ld	s2,80(sp)
    80004012:	69a6                	ld	s3,72(sp)
    80004014:	6a06                	ld	s4,64(sp)
    80004016:	7ae2                	ld	s5,56(sp)
    80004018:	7b42                	ld	s6,48(sp)
    8000401a:	7ba2                	ld	s7,40(sp)
    8000401c:	7c02                	ld	s8,32(sp)
    8000401e:	6ce2                	ld	s9,24(sp)
    80004020:	6d42                	ld	s10,16(sp)
    80004022:	6da2                	ld	s11,8(sp)
    80004024:	6165                	addi	sp,sp,112
    80004026:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004028:	89d6                	mv	s3,s5
    8000402a:	bff1                	j	80004006 <readi+0xce>
    return 0;
    8000402c:	4501                	li	a0,0
}
    8000402e:	8082                	ret

0000000080004030 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004030:	457c                	lw	a5,76(a0)
    80004032:	10d7e863          	bltu	a5,a3,80004142 <writei+0x112>
{
    80004036:	7159                	addi	sp,sp,-112
    80004038:	f486                	sd	ra,104(sp)
    8000403a:	f0a2                	sd	s0,96(sp)
    8000403c:	eca6                	sd	s1,88(sp)
    8000403e:	e8ca                	sd	s2,80(sp)
    80004040:	e4ce                	sd	s3,72(sp)
    80004042:	e0d2                	sd	s4,64(sp)
    80004044:	fc56                	sd	s5,56(sp)
    80004046:	f85a                	sd	s6,48(sp)
    80004048:	f45e                	sd	s7,40(sp)
    8000404a:	f062                	sd	s8,32(sp)
    8000404c:	ec66                	sd	s9,24(sp)
    8000404e:	e86a                	sd	s10,16(sp)
    80004050:	e46e                	sd	s11,8(sp)
    80004052:	1880                	addi	s0,sp,112
    80004054:	8aaa                	mv	s5,a0
    80004056:	8bae                	mv	s7,a1
    80004058:	8a32                	mv	s4,a2
    8000405a:	8936                	mv	s2,a3
    8000405c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000405e:	00e687bb          	addw	a5,a3,a4
    80004062:	0ed7e263          	bltu	a5,a3,80004146 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004066:	00043737          	lui	a4,0x43
    8000406a:	0ef76063          	bltu	a4,a5,8000414a <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000406e:	0c0b0863          	beqz	s6,8000413e <writei+0x10e>
    80004072:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004074:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004078:	5c7d                	li	s8,-1
    8000407a:	a091                	j	800040be <writei+0x8e>
    8000407c:	020d1d93          	slli	s11,s10,0x20
    80004080:	020ddd93          	srli	s11,s11,0x20
    80004084:	05848793          	addi	a5,s1,88
    80004088:	86ee                	mv	a3,s11
    8000408a:	8652                	mv	a2,s4
    8000408c:	85de                	mv	a1,s7
    8000408e:	953e                	add	a0,a0,a5
    80004090:	ffffe097          	auipc	ra,0xffffe
    80004094:	788080e7          	jalr	1928(ra) # 80002818 <either_copyin>
    80004098:	07850263          	beq	a0,s8,800040fc <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000409c:	8526                	mv	a0,s1
    8000409e:	00000097          	auipc	ra,0x0
    800040a2:	780080e7          	jalr	1920(ra) # 8000481e <log_write>
    brelse(bp);
    800040a6:	8526                	mv	a0,s1
    800040a8:	fffff097          	auipc	ra,0xfffff
    800040ac:	4f2080e7          	jalr	1266(ra) # 8000359a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800040b0:	013d09bb          	addw	s3,s10,s3
    800040b4:	012d093b          	addw	s2,s10,s2
    800040b8:	9a6e                	add	s4,s4,s11
    800040ba:	0569f663          	bgeu	s3,s6,80004106 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    800040be:	00a9559b          	srliw	a1,s2,0xa
    800040c2:	8556                	mv	a0,s5
    800040c4:	fffff097          	auipc	ra,0xfffff
    800040c8:	7a0080e7          	jalr	1952(ra) # 80003864 <bmap>
    800040cc:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800040d0:	c99d                	beqz	a1,80004106 <writei+0xd6>
    bp = bread(ip->dev, addr);
    800040d2:	000aa503          	lw	a0,0(s5)
    800040d6:	fffff097          	auipc	ra,0xfffff
    800040da:	394080e7          	jalr	916(ra) # 8000346a <bread>
    800040de:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800040e0:	3ff97513          	andi	a0,s2,1023
    800040e4:	40ac87bb          	subw	a5,s9,a0
    800040e8:	413b073b          	subw	a4,s6,s3
    800040ec:	8d3e                	mv	s10,a5
    800040ee:	2781                	sext.w	a5,a5
    800040f0:	0007069b          	sext.w	a3,a4
    800040f4:	f8f6f4e3          	bgeu	a3,a5,8000407c <writei+0x4c>
    800040f8:	8d3a                	mv	s10,a4
    800040fa:	b749                	j	8000407c <writei+0x4c>
      brelse(bp);
    800040fc:	8526                	mv	a0,s1
    800040fe:	fffff097          	auipc	ra,0xfffff
    80004102:	49c080e7          	jalr	1180(ra) # 8000359a <brelse>
  }

  if(off > ip->size)
    80004106:	04caa783          	lw	a5,76(s5)
    8000410a:	0127f463          	bgeu	a5,s2,80004112 <writei+0xe2>
    ip->size = off;
    8000410e:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004112:	8556                	mv	a0,s5
    80004114:	00000097          	auipc	ra,0x0
    80004118:	aa6080e7          	jalr	-1370(ra) # 80003bba <iupdate>

  return tot;
    8000411c:	0009851b          	sext.w	a0,s3
}
    80004120:	70a6                	ld	ra,104(sp)
    80004122:	7406                	ld	s0,96(sp)
    80004124:	64e6                	ld	s1,88(sp)
    80004126:	6946                	ld	s2,80(sp)
    80004128:	69a6                	ld	s3,72(sp)
    8000412a:	6a06                	ld	s4,64(sp)
    8000412c:	7ae2                	ld	s5,56(sp)
    8000412e:	7b42                	ld	s6,48(sp)
    80004130:	7ba2                	ld	s7,40(sp)
    80004132:	7c02                	ld	s8,32(sp)
    80004134:	6ce2                	ld	s9,24(sp)
    80004136:	6d42                	ld	s10,16(sp)
    80004138:	6da2                	ld	s11,8(sp)
    8000413a:	6165                	addi	sp,sp,112
    8000413c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000413e:	89da                	mv	s3,s6
    80004140:	bfc9                	j	80004112 <writei+0xe2>
    return -1;
    80004142:	557d                	li	a0,-1
}
    80004144:	8082                	ret
    return -1;
    80004146:	557d                	li	a0,-1
    80004148:	bfe1                	j	80004120 <writei+0xf0>
    return -1;
    8000414a:	557d                	li	a0,-1
    8000414c:	bfd1                	j	80004120 <writei+0xf0>

000000008000414e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000414e:	1141                	addi	sp,sp,-16
    80004150:	e406                	sd	ra,8(sp)
    80004152:	e022                	sd	s0,0(sp)
    80004154:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004156:	4639                	li	a2,14
    80004158:	ffffd097          	auipc	ra,0xffffd
    8000415c:	c4a080e7          	jalr	-950(ra) # 80000da2 <strncmp>
}
    80004160:	60a2                	ld	ra,8(sp)
    80004162:	6402                	ld	s0,0(sp)
    80004164:	0141                	addi	sp,sp,16
    80004166:	8082                	ret

0000000080004168 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004168:	7139                	addi	sp,sp,-64
    8000416a:	fc06                	sd	ra,56(sp)
    8000416c:	f822                	sd	s0,48(sp)
    8000416e:	f426                	sd	s1,40(sp)
    80004170:	f04a                	sd	s2,32(sp)
    80004172:	ec4e                	sd	s3,24(sp)
    80004174:	e852                	sd	s4,16(sp)
    80004176:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004178:	04451703          	lh	a4,68(a0)
    8000417c:	4785                	li	a5,1
    8000417e:	00f71a63          	bne	a4,a5,80004192 <dirlookup+0x2a>
    80004182:	892a                	mv	s2,a0
    80004184:	89ae                	mv	s3,a1
    80004186:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004188:	457c                	lw	a5,76(a0)
    8000418a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000418c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000418e:	e79d                	bnez	a5,800041bc <dirlookup+0x54>
    80004190:	a8a5                	j	80004208 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004192:	00004517          	auipc	a0,0x4
    80004196:	48e50513          	addi	a0,a0,1166 # 80008620 <syscalls+0x1d0>
    8000419a:	ffffc097          	auipc	ra,0xffffc
    8000419e:	3a4080e7          	jalr	932(ra) # 8000053e <panic>
      panic("dirlookup read");
    800041a2:	00004517          	auipc	a0,0x4
    800041a6:	49650513          	addi	a0,a0,1174 # 80008638 <syscalls+0x1e8>
    800041aa:	ffffc097          	auipc	ra,0xffffc
    800041ae:	394080e7          	jalr	916(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041b2:	24c1                	addiw	s1,s1,16
    800041b4:	04c92783          	lw	a5,76(s2)
    800041b8:	04f4f763          	bgeu	s1,a5,80004206 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041bc:	4741                	li	a4,16
    800041be:	86a6                	mv	a3,s1
    800041c0:	fc040613          	addi	a2,s0,-64
    800041c4:	4581                	li	a1,0
    800041c6:	854a                	mv	a0,s2
    800041c8:	00000097          	auipc	ra,0x0
    800041cc:	d70080e7          	jalr	-656(ra) # 80003f38 <readi>
    800041d0:	47c1                	li	a5,16
    800041d2:	fcf518e3          	bne	a0,a5,800041a2 <dirlookup+0x3a>
    if(de.inum == 0)
    800041d6:	fc045783          	lhu	a5,-64(s0)
    800041da:	dfe1                	beqz	a5,800041b2 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800041dc:	fc240593          	addi	a1,s0,-62
    800041e0:	854e                	mv	a0,s3
    800041e2:	00000097          	auipc	ra,0x0
    800041e6:	f6c080e7          	jalr	-148(ra) # 8000414e <namecmp>
    800041ea:	f561                	bnez	a0,800041b2 <dirlookup+0x4a>
      if(poff)
    800041ec:	000a0463          	beqz	s4,800041f4 <dirlookup+0x8c>
        *poff = off;
    800041f0:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800041f4:	fc045583          	lhu	a1,-64(s0)
    800041f8:	00092503          	lw	a0,0(s2)
    800041fc:	fffff097          	auipc	ra,0xfffff
    80004200:	750080e7          	jalr	1872(ra) # 8000394c <iget>
    80004204:	a011                	j	80004208 <dirlookup+0xa0>
  return 0;
    80004206:	4501                	li	a0,0
}
    80004208:	70e2                	ld	ra,56(sp)
    8000420a:	7442                	ld	s0,48(sp)
    8000420c:	74a2                	ld	s1,40(sp)
    8000420e:	7902                	ld	s2,32(sp)
    80004210:	69e2                	ld	s3,24(sp)
    80004212:	6a42                	ld	s4,16(sp)
    80004214:	6121                	addi	sp,sp,64
    80004216:	8082                	ret

0000000080004218 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004218:	711d                	addi	sp,sp,-96
    8000421a:	ec86                	sd	ra,88(sp)
    8000421c:	e8a2                	sd	s0,80(sp)
    8000421e:	e4a6                	sd	s1,72(sp)
    80004220:	e0ca                	sd	s2,64(sp)
    80004222:	fc4e                	sd	s3,56(sp)
    80004224:	f852                	sd	s4,48(sp)
    80004226:	f456                	sd	s5,40(sp)
    80004228:	f05a                	sd	s6,32(sp)
    8000422a:	ec5e                	sd	s7,24(sp)
    8000422c:	e862                	sd	s8,16(sp)
    8000422e:	e466                	sd	s9,8(sp)
    80004230:	1080                	addi	s0,sp,96
    80004232:	84aa                	mv	s1,a0
    80004234:	8aae                	mv	s5,a1
    80004236:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004238:	00054703          	lbu	a4,0(a0)
    8000423c:	02f00793          	li	a5,47
    80004240:	02f70363          	beq	a4,a5,80004266 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004244:	ffffd097          	auipc	ra,0xffffd
    80004248:	79c080e7          	jalr	1948(ra) # 800019e0 <myproc>
    8000424c:	19053503          	ld	a0,400(a0)
    80004250:	00000097          	auipc	ra,0x0
    80004254:	9f6080e7          	jalr	-1546(ra) # 80003c46 <idup>
    80004258:	89aa                	mv	s3,a0
  while(*path == '/')
    8000425a:	02f00913          	li	s2,47
  len = path - s;
    8000425e:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004260:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004262:	4b85                	li	s7,1
    80004264:	a865                	j	8000431c <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004266:	4585                	li	a1,1
    80004268:	4505                	li	a0,1
    8000426a:	fffff097          	auipc	ra,0xfffff
    8000426e:	6e2080e7          	jalr	1762(ra) # 8000394c <iget>
    80004272:	89aa                	mv	s3,a0
    80004274:	b7dd                	j	8000425a <namex+0x42>
      iunlockput(ip);
    80004276:	854e                	mv	a0,s3
    80004278:	00000097          	auipc	ra,0x0
    8000427c:	c6e080e7          	jalr	-914(ra) # 80003ee6 <iunlockput>
      return 0;
    80004280:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004282:	854e                	mv	a0,s3
    80004284:	60e6                	ld	ra,88(sp)
    80004286:	6446                	ld	s0,80(sp)
    80004288:	64a6                	ld	s1,72(sp)
    8000428a:	6906                	ld	s2,64(sp)
    8000428c:	79e2                	ld	s3,56(sp)
    8000428e:	7a42                	ld	s4,48(sp)
    80004290:	7aa2                	ld	s5,40(sp)
    80004292:	7b02                	ld	s6,32(sp)
    80004294:	6be2                	ld	s7,24(sp)
    80004296:	6c42                	ld	s8,16(sp)
    80004298:	6ca2                	ld	s9,8(sp)
    8000429a:	6125                	addi	sp,sp,96
    8000429c:	8082                	ret
      iunlock(ip);
    8000429e:	854e                	mv	a0,s3
    800042a0:	00000097          	auipc	ra,0x0
    800042a4:	aa6080e7          	jalr	-1370(ra) # 80003d46 <iunlock>
      return ip;
    800042a8:	bfe9                	j	80004282 <namex+0x6a>
      iunlockput(ip);
    800042aa:	854e                	mv	a0,s3
    800042ac:	00000097          	auipc	ra,0x0
    800042b0:	c3a080e7          	jalr	-966(ra) # 80003ee6 <iunlockput>
      return 0;
    800042b4:	89e6                	mv	s3,s9
    800042b6:	b7f1                	j	80004282 <namex+0x6a>
  len = path - s;
    800042b8:	40b48633          	sub	a2,s1,a1
    800042bc:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800042c0:	099c5463          	bge	s8,s9,80004348 <namex+0x130>
    memmove(name, s, DIRSIZ);
    800042c4:	4639                	li	a2,14
    800042c6:	8552                	mv	a0,s4
    800042c8:	ffffd097          	auipc	ra,0xffffd
    800042cc:	a66080e7          	jalr	-1434(ra) # 80000d2e <memmove>
  while(*path == '/')
    800042d0:	0004c783          	lbu	a5,0(s1)
    800042d4:	01279763          	bne	a5,s2,800042e2 <namex+0xca>
    path++;
    800042d8:	0485                	addi	s1,s1,1
  while(*path == '/')
    800042da:	0004c783          	lbu	a5,0(s1)
    800042de:	ff278de3          	beq	a5,s2,800042d8 <namex+0xc0>
    ilock(ip);
    800042e2:	854e                	mv	a0,s3
    800042e4:	00000097          	auipc	ra,0x0
    800042e8:	9a0080e7          	jalr	-1632(ra) # 80003c84 <ilock>
    if(ip->type != T_DIR){
    800042ec:	04499783          	lh	a5,68(s3)
    800042f0:	f97793e3          	bne	a5,s7,80004276 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800042f4:	000a8563          	beqz	s5,800042fe <namex+0xe6>
    800042f8:	0004c783          	lbu	a5,0(s1)
    800042fc:	d3cd                	beqz	a5,8000429e <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800042fe:	865a                	mv	a2,s6
    80004300:	85d2                	mv	a1,s4
    80004302:	854e                	mv	a0,s3
    80004304:	00000097          	auipc	ra,0x0
    80004308:	e64080e7          	jalr	-412(ra) # 80004168 <dirlookup>
    8000430c:	8caa                	mv	s9,a0
    8000430e:	dd51                	beqz	a0,800042aa <namex+0x92>
    iunlockput(ip);
    80004310:	854e                	mv	a0,s3
    80004312:	00000097          	auipc	ra,0x0
    80004316:	bd4080e7          	jalr	-1068(ra) # 80003ee6 <iunlockput>
    ip = next;
    8000431a:	89e6                	mv	s3,s9
  while(*path == '/')
    8000431c:	0004c783          	lbu	a5,0(s1)
    80004320:	05279763          	bne	a5,s2,8000436e <namex+0x156>
    path++;
    80004324:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004326:	0004c783          	lbu	a5,0(s1)
    8000432a:	ff278de3          	beq	a5,s2,80004324 <namex+0x10c>
  if(*path == 0)
    8000432e:	c79d                	beqz	a5,8000435c <namex+0x144>
    path++;
    80004330:	85a6                	mv	a1,s1
  len = path - s;
    80004332:	8cda                	mv	s9,s6
    80004334:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004336:	01278963          	beq	a5,s2,80004348 <namex+0x130>
    8000433a:	dfbd                	beqz	a5,800042b8 <namex+0xa0>
    path++;
    8000433c:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000433e:	0004c783          	lbu	a5,0(s1)
    80004342:	ff279ce3          	bne	a5,s2,8000433a <namex+0x122>
    80004346:	bf8d                	j	800042b8 <namex+0xa0>
    memmove(name, s, len);
    80004348:	2601                	sext.w	a2,a2
    8000434a:	8552                	mv	a0,s4
    8000434c:	ffffd097          	auipc	ra,0xffffd
    80004350:	9e2080e7          	jalr	-1566(ra) # 80000d2e <memmove>
    name[len] = 0;
    80004354:	9cd2                	add	s9,s9,s4
    80004356:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000435a:	bf9d                	j	800042d0 <namex+0xb8>
  if(nameiparent){
    8000435c:	f20a83e3          	beqz	s5,80004282 <namex+0x6a>
    iput(ip);
    80004360:	854e                	mv	a0,s3
    80004362:	00000097          	auipc	ra,0x0
    80004366:	adc080e7          	jalr	-1316(ra) # 80003e3e <iput>
    return 0;
    8000436a:	4981                	li	s3,0
    8000436c:	bf19                	j	80004282 <namex+0x6a>
  if(*path == 0)
    8000436e:	d7fd                	beqz	a5,8000435c <namex+0x144>
  while(*path != '/' && *path != 0)
    80004370:	0004c783          	lbu	a5,0(s1)
    80004374:	85a6                	mv	a1,s1
    80004376:	b7d1                	j	8000433a <namex+0x122>

0000000080004378 <dirlink>:
{
    80004378:	7139                	addi	sp,sp,-64
    8000437a:	fc06                	sd	ra,56(sp)
    8000437c:	f822                	sd	s0,48(sp)
    8000437e:	f426                	sd	s1,40(sp)
    80004380:	f04a                	sd	s2,32(sp)
    80004382:	ec4e                	sd	s3,24(sp)
    80004384:	e852                	sd	s4,16(sp)
    80004386:	0080                	addi	s0,sp,64
    80004388:	892a                	mv	s2,a0
    8000438a:	8a2e                	mv	s4,a1
    8000438c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000438e:	4601                	li	a2,0
    80004390:	00000097          	auipc	ra,0x0
    80004394:	dd8080e7          	jalr	-552(ra) # 80004168 <dirlookup>
    80004398:	e93d                	bnez	a0,8000440e <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000439a:	04c92483          	lw	s1,76(s2)
    8000439e:	c49d                	beqz	s1,800043cc <dirlink+0x54>
    800043a0:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043a2:	4741                	li	a4,16
    800043a4:	86a6                	mv	a3,s1
    800043a6:	fc040613          	addi	a2,s0,-64
    800043aa:	4581                	li	a1,0
    800043ac:	854a                	mv	a0,s2
    800043ae:	00000097          	auipc	ra,0x0
    800043b2:	b8a080e7          	jalr	-1142(ra) # 80003f38 <readi>
    800043b6:	47c1                	li	a5,16
    800043b8:	06f51163          	bne	a0,a5,8000441a <dirlink+0xa2>
    if(de.inum == 0)
    800043bc:	fc045783          	lhu	a5,-64(s0)
    800043c0:	c791                	beqz	a5,800043cc <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043c2:	24c1                	addiw	s1,s1,16
    800043c4:	04c92783          	lw	a5,76(s2)
    800043c8:	fcf4ede3          	bltu	s1,a5,800043a2 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800043cc:	4639                	li	a2,14
    800043ce:	85d2                	mv	a1,s4
    800043d0:	fc240513          	addi	a0,s0,-62
    800043d4:	ffffd097          	auipc	ra,0xffffd
    800043d8:	a0a080e7          	jalr	-1526(ra) # 80000dde <strncpy>
  de.inum = inum;
    800043dc:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043e0:	4741                	li	a4,16
    800043e2:	86a6                	mv	a3,s1
    800043e4:	fc040613          	addi	a2,s0,-64
    800043e8:	4581                	li	a1,0
    800043ea:	854a                	mv	a0,s2
    800043ec:	00000097          	auipc	ra,0x0
    800043f0:	c44080e7          	jalr	-956(ra) # 80004030 <writei>
    800043f4:	1541                	addi	a0,a0,-16
    800043f6:	00a03533          	snez	a0,a0
    800043fa:	40a00533          	neg	a0,a0
}
    800043fe:	70e2                	ld	ra,56(sp)
    80004400:	7442                	ld	s0,48(sp)
    80004402:	74a2                	ld	s1,40(sp)
    80004404:	7902                	ld	s2,32(sp)
    80004406:	69e2                	ld	s3,24(sp)
    80004408:	6a42                	ld	s4,16(sp)
    8000440a:	6121                	addi	sp,sp,64
    8000440c:	8082                	ret
    iput(ip);
    8000440e:	00000097          	auipc	ra,0x0
    80004412:	a30080e7          	jalr	-1488(ra) # 80003e3e <iput>
    return -1;
    80004416:	557d                	li	a0,-1
    80004418:	b7dd                	j	800043fe <dirlink+0x86>
      panic("dirlink read");
    8000441a:	00004517          	auipc	a0,0x4
    8000441e:	22e50513          	addi	a0,a0,558 # 80008648 <syscalls+0x1f8>
    80004422:	ffffc097          	auipc	ra,0xffffc
    80004426:	11c080e7          	jalr	284(ra) # 8000053e <panic>

000000008000442a <namei>:

struct inode*
namei(char *path)
{
    8000442a:	1101                	addi	sp,sp,-32
    8000442c:	ec06                	sd	ra,24(sp)
    8000442e:	e822                	sd	s0,16(sp)
    80004430:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004432:	fe040613          	addi	a2,s0,-32
    80004436:	4581                	li	a1,0
    80004438:	00000097          	auipc	ra,0x0
    8000443c:	de0080e7          	jalr	-544(ra) # 80004218 <namex>
}
    80004440:	60e2                	ld	ra,24(sp)
    80004442:	6442                	ld	s0,16(sp)
    80004444:	6105                	addi	sp,sp,32
    80004446:	8082                	ret

0000000080004448 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004448:	1141                	addi	sp,sp,-16
    8000444a:	e406                	sd	ra,8(sp)
    8000444c:	e022                	sd	s0,0(sp)
    8000444e:	0800                	addi	s0,sp,16
    80004450:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004452:	4585                	li	a1,1
    80004454:	00000097          	auipc	ra,0x0
    80004458:	dc4080e7          	jalr	-572(ra) # 80004218 <namex>
}
    8000445c:	60a2                	ld	ra,8(sp)
    8000445e:	6402                	ld	s0,0(sp)
    80004460:	0141                	addi	sp,sp,16
    80004462:	8082                	ret

0000000080004464 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004464:	1101                	addi	sp,sp,-32
    80004466:	ec06                	sd	ra,24(sp)
    80004468:	e822                	sd	s0,16(sp)
    8000446a:	e426                	sd	s1,8(sp)
    8000446c:	e04a                	sd	s2,0(sp)
    8000446e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004470:	0001d917          	auipc	s2,0x1d
    80004474:	6e090913          	addi	s2,s2,1760 # 80021b50 <log>
    80004478:	01892583          	lw	a1,24(s2)
    8000447c:	02892503          	lw	a0,40(s2)
    80004480:	fffff097          	auipc	ra,0xfffff
    80004484:	fea080e7          	jalr	-22(ra) # 8000346a <bread>
    80004488:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000448a:	02c92683          	lw	a3,44(s2)
    8000448e:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004490:	02d05763          	blez	a3,800044be <write_head+0x5a>
    80004494:	0001d797          	auipc	a5,0x1d
    80004498:	6ec78793          	addi	a5,a5,1772 # 80021b80 <log+0x30>
    8000449c:	05c50713          	addi	a4,a0,92
    800044a0:	36fd                	addiw	a3,a3,-1
    800044a2:	1682                	slli	a3,a3,0x20
    800044a4:	9281                	srli	a3,a3,0x20
    800044a6:	068a                	slli	a3,a3,0x2
    800044a8:	0001d617          	auipc	a2,0x1d
    800044ac:	6dc60613          	addi	a2,a2,1756 # 80021b84 <log+0x34>
    800044b0:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800044b2:	4390                	lw	a2,0(a5)
    800044b4:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800044b6:	0791                	addi	a5,a5,4
    800044b8:	0711                	addi	a4,a4,4
    800044ba:	fed79ce3          	bne	a5,a3,800044b2 <write_head+0x4e>
  }
  bwrite(buf);
    800044be:	8526                	mv	a0,s1
    800044c0:	fffff097          	auipc	ra,0xfffff
    800044c4:	09c080e7          	jalr	156(ra) # 8000355c <bwrite>
  brelse(buf);
    800044c8:	8526                	mv	a0,s1
    800044ca:	fffff097          	auipc	ra,0xfffff
    800044ce:	0d0080e7          	jalr	208(ra) # 8000359a <brelse>
}
    800044d2:	60e2                	ld	ra,24(sp)
    800044d4:	6442                	ld	s0,16(sp)
    800044d6:	64a2                	ld	s1,8(sp)
    800044d8:	6902                	ld	s2,0(sp)
    800044da:	6105                	addi	sp,sp,32
    800044dc:	8082                	ret

00000000800044de <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800044de:	0001d797          	auipc	a5,0x1d
    800044e2:	69e7a783          	lw	a5,1694(a5) # 80021b7c <log+0x2c>
    800044e6:	0af05d63          	blez	a5,800045a0 <install_trans+0xc2>
{
    800044ea:	7139                	addi	sp,sp,-64
    800044ec:	fc06                	sd	ra,56(sp)
    800044ee:	f822                	sd	s0,48(sp)
    800044f0:	f426                	sd	s1,40(sp)
    800044f2:	f04a                	sd	s2,32(sp)
    800044f4:	ec4e                	sd	s3,24(sp)
    800044f6:	e852                	sd	s4,16(sp)
    800044f8:	e456                	sd	s5,8(sp)
    800044fa:	e05a                	sd	s6,0(sp)
    800044fc:	0080                	addi	s0,sp,64
    800044fe:	8b2a                	mv	s6,a0
    80004500:	0001da97          	auipc	s5,0x1d
    80004504:	680a8a93          	addi	s5,s5,1664 # 80021b80 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004508:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000450a:	0001d997          	auipc	s3,0x1d
    8000450e:	64698993          	addi	s3,s3,1606 # 80021b50 <log>
    80004512:	a00d                	j	80004534 <install_trans+0x56>
    brelse(lbuf);
    80004514:	854a                	mv	a0,s2
    80004516:	fffff097          	auipc	ra,0xfffff
    8000451a:	084080e7          	jalr	132(ra) # 8000359a <brelse>
    brelse(dbuf);
    8000451e:	8526                	mv	a0,s1
    80004520:	fffff097          	auipc	ra,0xfffff
    80004524:	07a080e7          	jalr	122(ra) # 8000359a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004528:	2a05                	addiw	s4,s4,1
    8000452a:	0a91                	addi	s5,s5,4
    8000452c:	02c9a783          	lw	a5,44(s3)
    80004530:	04fa5e63          	bge	s4,a5,8000458c <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004534:	0189a583          	lw	a1,24(s3)
    80004538:	014585bb          	addw	a1,a1,s4
    8000453c:	2585                	addiw	a1,a1,1
    8000453e:	0289a503          	lw	a0,40(s3)
    80004542:	fffff097          	auipc	ra,0xfffff
    80004546:	f28080e7          	jalr	-216(ra) # 8000346a <bread>
    8000454a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000454c:	000aa583          	lw	a1,0(s5)
    80004550:	0289a503          	lw	a0,40(s3)
    80004554:	fffff097          	auipc	ra,0xfffff
    80004558:	f16080e7          	jalr	-234(ra) # 8000346a <bread>
    8000455c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000455e:	40000613          	li	a2,1024
    80004562:	05890593          	addi	a1,s2,88
    80004566:	05850513          	addi	a0,a0,88
    8000456a:	ffffc097          	auipc	ra,0xffffc
    8000456e:	7c4080e7          	jalr	1988(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    80004572:	8526                	mv	a0,s1
    80004574:	fffff097          	auipc	ra,0xfffff
    80004578:	fe8080e7          	jalr	-24(ra) # 8000355c <bwrite>
    if(recovering == 0)
    8000457c:	f80b1ce3          	bnez	s6,80004514 <install_trans+0x36>
      bunpin(dbuf);
    80004580:	8526                	mv	a0,s1
    80004582:	fffff097          	auipc	ra,0xfffff
    80004586:	0f2080e7          	jalr	242(ra) # 80003674 <bunpin>
    8000458a:	b769                	j	80004514 <install_trans+0x36>
}
    8000458c:	70e2                	ld	ra,56(sp)
    8000458e:	7442                	ld	s0,48(sp)
    80004590:	74a2                	ld	s1,40(sp)
    80004592:	7902                	ld	s2,32(sp)
    80004594:	69e2                	ld	s3,24(sp)
    80004596:	6a42                	ld	s4,16(sp)
    80004598:	6aa2                	ld	s5,8(sp)
    8000459a:	6b02                	ld	s6,0(sp)
    8000459c:	6121                	addi	sp,sp,64
    8000459e:	8082                	ret
    800045a0:	8082                	ret

00000000800045a2 <initlog>:
{
    800045a2:	7179                	addi	sp,sp,-48
    800045a4:	f406                	sd	ra,40(sp)
    800045a6:	f022                	sd	s0,32(sp)
    800045a8:	ec26                	sd	s1,24(sp)
    800045aa:	e84a                	sd	s2,16(sp)
    800045ac:	e44e                	sd	s3,8(sp)
    800045ae:	1800                	addi	s0,sp,48
    800045b0:	892a                	mv	s2,a0
    800045b2:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800045b4:	0001d497          	auipc	s1,0x1d
    800045b8:	59c48493          	addi	s1,s1,1436 # 80021b50 <log>
    800045bc:	00004597          	auipc	a1,0x4
    800045c0:	09c58593          	addi	a1,a1,156 # 80008658 <syscalls+0x208>
    800045c4:	8526                	mv	a0,s1
    800045c6:	ffffc097          	auipc	ra,0xffffc
    800045ca:	580080e7          	jalr	1408(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    800045ce:	0149a583          	lw	a1,20(s3)
    800045d2:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800045d4:	0109a783          	lw	a5,16(s3)
    800045d8:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800045da:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800045de:	854a                	mv	a0,s2
    800045e0:	fffff097          	auipc	ra,0xfffff
    800045e4:	e8a080e7          	jalr	-374(ra) # 8000346a <bread>
  log.lh.n = lh->n;
    800045e8:	4d34                	lw	a3,88(a0)
    800045ea:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800045ec:	02d05563          	blez	a3,80004616 <initlog+0x74>
    800045f0:	05c50793          	addi	a5,a0,92
    800045f4:	0001d717          	auipc	a4,0x1d
    800045f8:	58c70713          	addi	a4,a4,1420 # 80021b80 <log+0x30>
    800045fc:	36fd                	addiw	a3,a3,-1
    800045fe:	1682                	slli	a3,a3,0x20
    80004600:	9281                	srli	a3,a3,0x20
    80004602:	068a                	slli	a3,a3,0x2
    80004604:	06050613          	addi	a2,a0,96
    80004608:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000460a:	4390                	lw	a2,0(a5)
    8000460c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000460e:	0791                	addi	a5,a5,4
    80004610:	0711                	addi	a4,a4,4
    80004612:	fed79ce3          	bne	a5,a3,8000460a <initlog+0x68>
  brelse(buf);
    80004616:	fffff097          	auipc	ra,0xfffff
    8000461a:	f84080e7          	jalr	-124(ra) # 8000359a <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000461e:	4505                	li	a0,1
    80004620:	00000097          	auipc	ra,0x0
    80004624:	ebe080e7          	jalr	-322(ra) # 800044de <install_trans>
  log.lh.n = 0;
    80004628:	0001d797          	auipc	a5,0x1d
    8000462c:	5407aa23          	sw	zero,1364(a5) # 80021b7c <log+0x2c>
  write_head(); // clear the log
    80004630:	00000097          	auipc	ra,0x0
    80004634:	e34080e7          	jalr	-460(ra) # 80004464 <write_head>
}
    80004638:	70a2                	ld	ra,40(sp)
    8000463a:	7402                	ld	s0,32(sp)
    8000463c:	64e2                	ld	s1,24(sp)
    8000463e:	6942                	ld	s2,16(sp)
    80004640:	69a2                	ld	s3,8(sp)
    80004642:	6145                	addi	sp,sp,48
    80004644:	8082                	ret

0000000080004646 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004646:	1101                	addi	sp,sp,-32
    80004648:	ec06                	sd	ra,24(sp)
    8000464a:	e822                	sd	s0,16(sp)
    8000464c:	e426                	sd	s1,8(sp)
    8000464e:	e04a                	sd	s2,0(sp)
    80004650:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004652:	0001d517          	auipc	a0,0x1d
    80004656:	4fe50513          	addi	a0,a0,1278 # 80021b50 <log>
    8000465a:	ffffc097          	auipc	ra,0xffffc
    8000465e:	57c080e7          	jalr	1404(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    80004662:	0001d497          	auipc	s1,0x1d
    80004666:	4ee48493          	addi	s1,s1,1262 # 80021b50 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000466a:	4979                	li	s2,30
    8000466c:	a039                	j	8000467a <begin_op+0x34>
      sleep(&log, &log.lock);
    8000466e:	85a6                	mv	a1,s1
    80004670:	8526                	mv	a0,s1
    80004672:	ffffe097          	auipc	ra,0xffffe
    80004676:	c5a080e7          	jalr	-934(ra) # 800022cc <sleep>
    if(log.committing){
    8000467a:	50dc                	lw	a5,36(s1)
    8000467c:	fbed                	bnez	a5,8000466e <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000467e:	509c                	lw	a5,32(s1)
    80004680:	0017871b          	addiw	a4,a5,1
    80004684:	0007069b          	sext.w	a3,a4
    80004688:	0027179b          	slliw	a5,a4,0x2
    8000468c:	9fb9                	addw	a5,a5,a4
    8000468e:	0017979b          	slliw	a5,a5,0x1
    80004692:	54d8                	lw	a4,44(s1)
    80004694:	9fb9                	addw	a5,a5,a4
    80004696:	00f95963          	bge	s2,a5,800046a8 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000469a:	85a6                	mv	a1,s1
    8000469c:	8526                	mv	a0,s1
    8000469e:	ffffe097          	auipc	ra,0xffffe
    800046a2:	c2e080e7          	jalr	-978(ra) # 800022cc <sleep>
    800046a6:	bfd1                	j	8000467a <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800046a8:	0001d517          	auipc	a0,0x1d
    800046ac:	4a850513          	addi	a0,a0,1192 # 80021b50 <log>
    800046b0:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800046b2:	ffffc097          	auipc	ra,0xffffc
    800046b6:	5d8080e7          	jalr	1496(ra) # 80000c8a <release>
      break;
    }
  }
}
    800046ba:	60e2                	ld	ra,24(sp)
    800046bc:	6442                	ld	s0,16(sp)
    800046be:	64a2                	ld	s1,8(sp)
    800046c0:	6902                	ld	s2,0(sp)
    800046c2:	6105                	addi	sp,sp,32
    800046c4:	8082                	ret

00000000800046c6 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800046c6:	7139                	addi	sp,sp,-64
    800046c8:	fc06                	sd	ra,56(sp)
    800046ca:	f822                	sd	s0,48(sp)
    800046cc:	f426                	sd	s1,40(sp)
    800046ce:	f04a                	sd	s2,32(sp)
    800046d0:	ec4e                	sd	s3,24(sp)
    800046d2:	e852                	sd	s4,16(sp)
    800046d4:	e456                	sd	s5,8(sp)
    800046d6:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800046d8:	0001d497          	auipc	s1,0x1d
    800046dc:	47848493          	addi	s1,s1,1144 # 80021b50 <log>
    800046e0:	8526                	mv	a0,s1
    800046e2:	ffffc097          	auipc	ra,0xffffc
    800046e6:	4f4080e7          	jalr	1268(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    800046ea:	509c                	lw	a5,32(s1)
    800046ec:	37fd                	addiw	a5,a5,-1
    800046ee:	0007891b          	sext.w	s2,a5
    800046f2:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800046f4:	50dc                	lw	a5,36(s1)
    800046f6:	e7b9                	bnez	a5,80004744 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800046f8:	04091e63          	bnez	s2,80004754 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800046fc:	0001d497          	auipc	s1,0x1d
    80004700:	45448493          	addi	s1,s1,1108 # 80021b50 <log>
    80004704:	4785                	li	a5,1
    80004706:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004708:	8526                	mv	a0,s1
    8000470a:	ffffc097          	auipc	ra,0xffffc
    8000470e:	580080e7          	jalr	1408(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004712:	54dc                	lw	a5,44(s1)
    80004714:	06f04763          	bgtz	a5,80004782 <end_op+0xbc>
    acquire(&log.lock);
    80004718:	0001d497          	auipc	s1,0x1d
    8000471c:	43848493          	addi	s1,s1,1080 # 80021b50 <log>
    80004720:	8526                	mv	a0,s1
    80004722:	ffffc097          	auipc	ra,0xffffc
    80004726:	4b4080e7          	jalr	1204(ra) # 80000bd6 <acquire>
    log.committing = 0;
    8000472a:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000472e:	8526                	mv	a0,s1
    80004730:	ffffe097          	auipc	ra,0xffffe
    80004734:	c84080e7          	jalr	-892(ra) # 800023b4 <wakeup>
    release(&log.lock);
    80004738:	8526                	mv	a0,s1
    8000473a:	ffffc097          	auipc	ra,0xffffc
    8000473e:	550080e7          	jalr	1360(ra) # 80000c8a <release>
}
    80004742:	a03d                	j	80004770 <end_op+0xaa>
    panic("log.committing");
    80004744:	00004517          	auipc	a0,0x4
    80004748:	f1c50513          	addi	a0,a0,-228 # 80008660 <syscalls+0x210>
    8000474c:	ffffc097          	auipc	ra,0xffffc
    80004750:	df2080e7          	jalr	-526(ra) # 8000053e <panic>
    wakeup(&log);
    80004754:	0001d497          	auipc	s1,0x1d
    80004758:	3fc48493          	addi	s1,s1,1020 # 80021b50 <log>
    8000475c:	8526                	mv	a0,s1
    8000475e:	ffffe097          	auipc	ra,0xffffe
    80004762:	c56080e7          	jalr	-938(ra) # 800023b4 <wakeup>
  release(&log.lock);
    80004766:	8526                	mv	a0,s1
    80004768:	ffffc097          	auipc	ra,0xffffc
    8000476c:	522080e7          	jalr	1314(ra) # 80000c8a <release>
}
    80004770:	70e2                	ld	ra,56(sp)
    80004772:	7442                	ld	s0,48(sp)
    80004774:	74a2                	ld	s1,40(sp)
    80004776:	7902                	ld	s2,32(sp)
    80004778:	69e2                	ld	s3,24(sp)
    8000477a:	6a42                	ld	s4,16(sp)
    8000477c:	6aa2                	ld	s5,8(sp)
    8000477e:	6121                	addi	sp,sp,64
    80004780:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004782:	0001da97          	auipc	s5,0x1d
    80004786:	3fea8a93          	addi	s5,s5,1022 # 80021b80 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000478a:	0001da17          	auipc	s4,0x1d
    8000478e:	3c6a0a13          	addi	s4,s4,966 # 80021b50 <log>
    80004792:	018a2583          	lw	a1,24(s4)
    80004796:	012585bb          	addw	a1,a1,s2
    8000479a:	2585                	addiw	a1,a1,1
    8000479c:	028a2503          	lw	a0,40(s4)
    800047a0:	fffff097          	auipc	ra,0xfffff
    800047a4:	cca080e7          	jalr	-822(ra) # 8000346a <bread>
    800047a8:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800047aa:	000aa583          	lw	a1,0(s5)
    800047ae:	028a2503          	lw	a0,40(s4)
    800047b2:	fffff097          	auipc	ra,0xfffff
    800047b6:	cb8080e7          	jalr	-840(ra) # 8000346a <bread>
    800047ba:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800047bc:	40000613          	li	a2,1024
    800047c0:	05850593          	addi	a1,a0,88
    800047c4:	05848513          	addi	a0,s1,88
    800047c8:	ffffc097          	auipc	ra,0xffffc
    800047cc:	566080e7          	jalr	1382(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    800047d0:	8526                	mv	a0,s1
    800047d2:	fffff097          	auipc	ra,0xfffff
    800047d6:	d8a080e7          	jalr	-630(ra) # 8000355c <bwrite>
    brelse(from);
    800047da:	854e                	mv	a0,s3
    800047dc:	fffff097          	auipc	ra,0xfffff
    800047e0:	dbe080e7          	jalr	-578(ra) # 8000359a <brelse>
    brelse(to);
    800047e4:	8526                	mv	a0,s1
    800047e6:	fffff097          	auipc	ra,0xfffff
    800047ea:	db4080e7          	jalr	-588(ra) # 8000359a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800047ee:	2905                	addiw	s2,s2,1
    800047f0:	0a91                	addi	s5,s5,4
    800047f2:	02ca2783          	lw	a5,44(s4)
    800047f6:	f8f94ee3          	blt	s2,a5,80004792 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800047fa:	00000097          	auipc	ra,0x0
    800047fe:	c6a080e7          	jalr	-918(ra) # 80004464 <write_head>
    install_trans(0); // Now install writes to home locations
    80004802:	4501                	li	a0,0
    80004804:	00000097          	auipc	ra,0x0
    80004808:	cda080e7          	jalr	-806(ra) # 800044de <install_trans>
    log.lh.n = 0;
    8000480c:	0001d797          	auipc	a5,0x1d
    80004810:	3607a823          	sw	zero,880(a5) # 80021b7c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004814:	00000097          	auipc	ra,0x0
    80004818:	c50080e7          	jalr	-944(ra) # 80004464 <write_head>
    8000481c:	bdf5                	j	80004718 <end_op+0x52>

000000008000481e <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000481e:	1101                	addi	sp,sp,-32
    80004820:	ec06                	sd	ra,24(sp)
    80004822:	e822                	sd	s0,16(sp)
    80004824:	e426                	sd	s1,8(sp)
    80004826:	e04a                	sd	s2,0(sp)
    80004828:	1000                	addi	s0,sp,32
    8000482a:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000482c:	0001d917          	auipc	s2,0x1d
    80004830:	32490913          	addi	s2,s2,804 # 80021b50 <log>
    80004834:	854a                	mv	a0,s2
    80004836:	ffffc097          	auipc	ra,0xffffc
    8000483a:	3a0080e7          	jalr	928(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000483e:	02c92603          	lw	a2,44(s2)
    80004842:	47f5                	li	a5,29
    80004844:	06c7c563          	blt	a5,a2,800048ae <log_write+0x90>
    80004848:	0001d797          	auipc	a5,0x1d
    8000484c:	3247a783          	lw	a5,804(a5) # 80021b6c <log+0x1c>
    80004850:	37fd                	addiw	a5,a5,-1
    80004852:	04f65e63          	bge	a2,a5,800048ae <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004856:	0001d797          	auipc	a5,0x1d
    8000485a:	31a7a783          	lw	a5,794(a5) # 80021b70 <log+0x20>
    8000485e:	06f05063          	blez	a5,800048be <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004862:	4781                	li	a5,0
    80004864:	06c05563          	blez	a2,800048ce <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004868:	44cc                	lw	a1,12(s1)
    8000486a:	0001d717          	auipc	a4,0x1d
    8000486e:	31670713          	addi	a4,a4,790 # 80021b80 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004872:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004874:	4314                	lw	a3,0(a4)
    80004876:	04b68c63          	beq	a3,a1,800048ce <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000487a:	2785                	addiw	a5,a5,1
    8000487c:	0711                	addi	a4,a4,4
    8000487e:	fef61be3          	bne	a2,a5,80004874 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004882:	0621                	addi	a2,a2,8
    80004884:	060a                	slli	a2,a2,0x2
    80004886:	0001d797          	auipc	a5,0x1d
    8000488a:	2ca78793          	addi	a5,a5,714 # 80021b50 <log>
    8000488e:	963e                	add	a2,a2,a5
    80004890:	44dc                	lw	a5,12(s1)
    80004892:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004894:	8526                	mv	a0,s1
    80004896:	fffff097          	auipc	ra,0xfffff
    8000489a:	da2080e7          	jalr	-606(ra) # 80003638 <bpin>
    log.lh.n++;
    8000489e:	0001d717          	auipc	a4,0x1d
    800048a2:	2b270713          	addi	a4,a4,690 # 80021b50 <log>
    800048a6:	575c                	lw	a5,44(a4)
    800048a8:	2785                	addiw	a5,a5,1
    800048aa:	d75c                	sw	a5,44(a4)
    800048ac:	a835                	j	800048e8 <log_write+0xca>
    panic("too big a transaction");
    800048ae:	00004517          	auipc	a0,0x4
    800048b2:	dc250513          	addi	a0,a0,-574 # 80008670 <syscalls+0x220>
    800048b6:	ffffc097          	auipc	ra,0xffffc
    800048ba:	c88080e7          	jalr	-888(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    800048be:	00004517          	auipc	a0,0x4
    800048c2:	dca50513          	addi	a0,a0,-566 # 80008688 <syscalls+0x238>
    800048c6:	ffffc097          	auipc	ra,0xffffc
    800048ca:	c78080e7          	jalr	-904(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    800048ce:	00878713          	addi	a4,a5,8
    800048d2:	00271693          	slli	a3,a4,0x2
    800048d6:	0001d717          	auipc	a4,0x1d
    800048da:	27a70713          	addi	a4,a4,634 # 80021b50 <log>
    800048de:	9736                	add	a4,a4,a3
    800048e0:	44d4                	lw	a3,12(s1)
    800048e2:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800048e4:	faf608e3          	beq	a2,a5,80004894 <log_write+0x76>
  }
  release(&log.lock);
    800048e8:	0001d517          	auipc	a0,0x1d
    800048ec:	26850513          	addi	a0,a0,616 # 80021b50 <log>
    800048f0:	ffffc097          	auipc	ra,0xffffc
    800048f4:	39a080e7          	jalr	922(ra) # 80000c8a <release>
}
    800048f8:	60e2                	ld	ra,24(sp)
    800048fa:	6442                	ld	s0,16(sp)
    800048fc:	64a2                	ld	s1,8(sp)
    800048fe:	6902                	ld	s2,0(sp)
    80004900:	6105                	addi	sp,sp,32
    80004902:	8082                	ret

0000000080004904 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004904:	1101                	addi	sp,sp,-32
    80004906:	ec06                	sd	ra,24(sp)
    80004908:	e822                	sd	s0,16(sp)
    8000490a:	e426                	sd	s1,8(sp)
    8000490c:	e04a                	sd	s2,0(sp)
    8000490e:	1000                	addi	s0,sp,32
    80004910:	84aa                	mv	s1,a0
    80004912:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004914:	00004597          	auipc	a1,0x4
    80004918:	d9458593          	addi	a1,a1,-620 # 800086a8 <syscalls+0x258>
    8000491c:	0521                	addi	a0,a0,8
    8000491e:	ffffc097          	auipc	ra,0xffffc
    80004922:	228080e7          	jalr	552(ra) # 80000b46 <initlock>
  lk->name = name;
    80004926:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000492a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000492e:	0204a423          	sw	zero,40(s1)
}
    80004932:	60e2                	ld	ra,24(sp)
    80004934:	6442                	ld	s0,16(sp)
    80004936:	64a2                	ld	s1,8(sp)
    80004938:	6902                	ld	s2,0(sp)
    8000493a:	6105                	addi	sp,sp,32
    8000493c:	8082                	ret

000000008000493e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000493e:	1101                	addi	sp,sp,-32
    80004940:	ec06                	sd	ra,24(sp)
    80004942:	e822                	sd	s0,16(sp)
    80004944:	e426                	sd	s1,8(sp)
    80004946:	e04a                	sd	s2,0(sp)
    80004948:	1000                	addi	s0,sp,32
    8000494a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000494c:	00850913          	addi	s2,a0,8
    80004950:	854a                	mv	a0,s2
    80004952:	ffffc097          	auipc	ra,0xffffc
    80004956:	284080e7          	jalr	644(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    8000495a:	409c                	lw	a5,0(s1)
    8000495c:	cb89                	beqz	a5,8000496e <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000495e:	85ca                	mv	a1,s2
    80004960:	8526                	mv	a0,s1
    80004962:	ffffe097          	auipc	ra,0xffffe
    80004966:	96a080e7          	jalr	-1686(ra) # 800022cc <sleep>
  while (lk->locked) {
    8000496a:	409c                	lw	a5,0(s1)
    8000496c:	fbed                	bnez	a5,8000495e <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000496e:	4785                	li	a5,1
    80004970:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004972:	ffffd097          	auipc	ra,0xffffd
    80004976:	06e080e7          	jalr	110(ra) # 800019e0 <myproc>
    8000497a:	591c                	lw	a5,48(a0)
    8000497c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000497e:	854a                	mv	a0,s2
    80004980:	ffffc097          	auipc	ra,0xffffc
    80004984:	30a080e7          	jalr	778(ra) # 80000c8a <release>
}
    80004988:	60e2                	ld	ra,24(sp)
    8000498a:	6442                	ld	s0,16(sp)
    8000498c:	64a2                	ld	s1,8(sp)
    8000498e:	6902                	ld	s2,0(sp)
    80004990:	6105                	addi	sp,sp,32
    80004992:	8082                	ret

0000000080004994 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004994:	1101                	addi	sp,sp,-32
    80004996:	ec06                	sd	ra,24(sp)
    80004998:	e822                	sd	s0,16(sp)
    8000499a:	e426                	sd	s1,8(sp)
    8000499c:	e04a                	sd	s2,0(sp)
    8000499e:	1000                	addi	s0,sp,32
    800049a0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800049a2:	00850913          	addi	s2,a0,8
    800049a6:	854a                	mv	a0,s2
    800049a8:	ffffc097          	auipc	ra,0xffffc
    800049ac:	22e080e7          	jalr	558(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    800049b0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800049b4:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800049b8:	8526                	mv	a0,s1
    800049ba:	ffffe097          	auipc	ra,0xffffe
    800049be:	9fa080e7          	jalr	-1542(ra) # 800023b4 <wakeup>
  release(&lk->lk);
    800049c2:	854a                	mv	a0,s2
    800049c4:	ffffc097          	auipc	ra,0xffffc
    800049c8:	2c6080e7          	jalr	710(ra) # 80000c8a <release>
}
    800049cc:	60e2                	ld	ra,24(sp)
    800049ce:	6442                	ld	s0,16(sp)
    800049d0:	64a2                	ld	s1,8(sp)
    800049d2:	6902                	ld	s2,0(sp)
    800049d4:	6105                	addi	sp,sp,32
    800049d6:	8082                	ret

00000000800049d8 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800049d8:	7179                	addi	sp,sp,-48
    800049da:	f406                	sd	ra,40(sp)
    800049dc:	f022                	sd	s0,32(sp)
    800049de:	ec26                	sd	s1,24(sp)
    800049e0:	e84a                	sd	s2,16(sp)
    800049e2:	e44e                	sd	s3,8(sp)
    800049e4:	1800                	addi	s0,sp,48
    800049e6:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800049e8:	00850913          	addi	s2,a0,8
    800049ec:	854a                	mv	a0,s2
    800049ee:	ffffc097          	auipc	ra,0xffffc
    800049f2:	1e8080e7          	jalr	488(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800049f6:	409c                	lw	a5,0(s1)
    800049f8:	ef99                	bnez	a5,80004a16 <holdingsleep+0x3e>
    800049fa:	4481                	li	s1,0
  release(&lk->lk);
    800049fc:	854a                	mv	a0,s2
    800049fe:	ffffc097          	auipc	ra,0xffffc
    80004a02:	28c080e7          	jalr	652(ra) # 80000c8a <release>
  return r;
}
    80004a06:	8526                	mv	a0,s1
    80004a08:	70a2                	ld	ra,40(sp)
    80004a0a:	7402                	ld	s0,32(sp)
    80004a0c:	64e2                	ld	s1,24(sp)
    80004a0e:	6942                	ld	s2,16(sp)
    80004a10:	69a2                	ld	s3,8(sp)
    80004a12:	6145                	addi	sp,sp,48
    80004a14:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004a16:	0284a983          	lw	s3,40(s1)
    80004a1a:	ffffd097          	auipc	ra,0xffffd
    80004a1e:	fc6080e7          	jalr	-58(ra) # 800019e0 <myproc>
    80004a22:	5904                	lw	s1,48(a0)
    80004a24:	413484b3          	sub	s1,s1,s3
    80004a28:	0014b493          	seqz	s1,s1
    80004a2c:	bfc1                	j	800049fc <holdingsleep+0x24>

0000000080004a2e <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004a2e:	1141                	addi	sp,sp,-16
    80004a30:	e406                	sd	ra,8(sp)
    80004a32:	e022                	sd	s0,0(sp)
    80004a34:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004a36:	00004597          	auipc	a1,0x4
    80004a3a:	c8258593          	addi	a1,a1,-894 # 800086b8 <syscalls+0x268>
    80004a3e:	0001d517          	auipc	a0,0x1d
    80004a42:	25a50513          	addi	a0,a0,602 # 80021c98 <ftable>
    80004a46:	ffffc097          	auipc	ra,0xffffc
    80004a4a:	100080e7          	jalr	256(ra) # 80000b46 <initlock>
}
    80004a4e:	60a2                	ld	ra,8(sp)
    80004a50:	6402                	ld	s0,0(sp)
    80004a52:	0141                	addi	sp,sp,16
    80004a54:	8082                	ret

0000000080004a56 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004a56:	1101                	addi	sp,sp,-32
    80004a58:	ec06                	sd	ra,24(sp)
    80004a5a:	e822                	sd	s0,16(sp)
    80004a5c:	e426                	sd	s1,8(sp)
    80004a5e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004a60:	0001d517          	auipc	a0,0x1d
    80004a64:	23850513          	addi	a0,a0,568 # 80021c98 <ftable>
    80004a68:	ffffc097          	auipc	ra,0xffffc
    80004a6c:	16e080e7          	jalr	366(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a70:	0001d497          	auipc	s1,0x1d
    80004a74:	24048493          	addi	s1,s1,576 # 80021cb0 <ftable+0x18>
    80004a78:	0001e717          	auipc	a4,0x1e
    80004a7c:	1d870713          	addi	a4,a4,472 # 80022c50 <disk>
    if(f->ref == 0){
    80004a80:	40dc                	lw	a5,4(s1)
    80004a82:	cf99                	beqz	a5,80004aa0 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a84:	02848493          	addi	s1,s1,40
    80004a88:	fee49ce3          	bne	s1,a4,80004a80 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004a8c:	0001d517          	auipc	a0,0x1d
    80004a90:	20c50513          	addi	a0,a0,524 # 80021c98 <ftable>
    80004a94:	ffffc097          	auipc	ra,0xffffc
    80004a98:	1f6080e7          	jalr	502(ra) # 80000c8a <release>
  return 0;
    80004a9c:	4481                	li	s1,0
    80004a9e:	a819                	j	80004ab4 <filealloc+0x5e>
      f->ref = 1;
    80004aa0:	4785                	li	a5,1
    80004aa2:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004aa4:	0001d517          	auipc	a0,0x1d
    80004aa8:	1f450513          	addi	a0,a0,500 # 80021c98 <ftable>
    80004aac:	ffffc097          	auipc	ra,0xffffc
    80004ab0:	1de080e7          	jalr	478(ra) # 80000c8a <release>
}
    80004ab4:	8526                	mv	a0,s1
    80004ab6:	60e2                	ld	ra,24(sp)
    80004ab8:	6442                	ld	s0,16(sp)
    80004aba:	64a2                	ld	s1,8(sp)
    80004abc:	6105                	addi	sp,sp,32
    80004abe:	8082                	ret

0000000080004ac0 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004ac0:	1101                	addi	sp,sp,-32
    80004ac2:	ec06                	sd	ra,24(sp)
    80004ac4:	e822                	sd	s0,16(sp)
    80004ac6:	e426                	sd	s1,8(sp)
    80004ac8:	1000                	addi	s0,sp,32
    80004aca:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004acc:	0001d517          	auipc	a0,0x1d
    80004ad0:	1cc50513          	addi	a0,a0,460 # 80021c98 <ftable>
    80004ad4:	ffffc097          	auipc	ra,0xffffc
    80004ad8:	102080e7          	jalr	258(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004adc:	40dc                	lw	a5,4(s1)
    80004ade:	02f05263          	blez	a5,80004b02 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004ae2:	2785                	addiw	a5,a5,1
    80004ae4:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004ae6:	0001d517          	auipc	a0,0x1d
    80004aea:	1b250513          	addi	a0,a0,434 # 80021c98 <ftable>
    80004aee:	ffffc097          	auipc	ra,0xffffc
    80004af2:	19c080e7          	jalr	412(ra) # 80000c8a <release>
  return f;
}
    80004af6:	8526                	mv	a0,s1
    80004af8:	60e2                	ld	ra,24(sp)
    80004afa:	6442                	ld	s0,16(sp)
    80004afc:	64a2                	ld	s1,8(sp)
    80004afe:	6105                	addi	sp,sp,32
    80004b00:	8082                	ret
    panic("filedup");
    80004b02:	00004517          	auipc	a0,0x4
    80004b06:	bbe50513          	addi	a0,a0,-1090 # 800086c0 <syscalls+0x270>
    80004b0a:	ffffc097          	auipc	ra,0xffffc
    80004b0e:	a34080e7          	jalr	-1484(ra) # 8000053e <panic>

0000000080004b12 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004b12:	7139                	addi	sp,sp,-64
    80004b14:	fc06                	sd	ra,56(sp)
    80004b16:	f822                	sd	s0,48(sp)
    80004b18:	f426                	sd	s1,40(sp)
    80004b1a:	f04a                	sd	s2,32(sp)
    80004b1c:	ec4e                	sd	s3,24(sp)
    80004b1e:	e852                	sd	s4,16(sp)
    80004b20:	e456                	sd	s5,8(sp)
    80004b22:	0080                	addi	s0,sp,64
    80004b24:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004b26:	0001d517          	auipc	a0,0x1d
    80004b2a:	17250513          	addi	a0,a0,370 # 80021c98 <ftable>
    80004b2e:	ffffc097          	auipc	ra,0xffffc
    80004b32:	0a8080e7          	jalr	168(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004b36:	40dc                	lw	a5,4(s1)
    80004b38:	06f05163          	blez	a5,80004b9a <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004b3c:	37fd                	addiw	a5,a5,-1
    80004b3e:	0007871b          	sext.w	a4,a5
    80004b42:	c0dc                	sw	a5,4(s1)
    80004b44:	06e04363          	bgtz	a4,80004baa <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004b48:	0004a903          	lw	s2,0(s1)
    80004b4c:	0094ca83          	lbu	s5,9(s1)
    80004b50:	0104ba03          	ld	s4,16(s1)
    80004b54:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004b58:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004b5c:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004b60:	0001d517          	auipc	a0,0x1d
    80004b64:	13850513          	addi	a0,a0,312 # 80021c98 <ftable>
    80004b68:	ffffc097          	auipc	ra,0xffffc
    80004b6c:	122080e7          	jalr	290(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    80004b70:	4785                	li	a5,1
    80004b72:	04f90d63          	beq	s2,a5,80004bcc <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004b76:	3979                	addiw	s2,s2,-2
    80004b78:	4785                	li	a5,1
    80004b7a:	0527e063          	bltu	a5,s2,80004bba <fileclose+0xa8>
    begin_op();
    80004b7e:	00000097          	auipc	ra,0x0
    80004b82:	ac8080e7          	jalr	-1336(ra) # 80004646 <begin_op>
    iput(ff.ip);
    80004b86:	854e                	mv	a0,s3
    80004b88:	fffff097          	auipc	ra,0xfffff
    80004b8c:	2b6080e7          	jalr	694(ra) # 80003e3e <iput>
    end_op();
    80004b90:	00000097          	auipc	ra,0x0
    80004b94:	b36080e7          	jalr	-1226(ra) # 800046c6 <end_op>
    80004b98:	a00d                	j	80004bba <fileclose+0xa8>
    panic("fileclose");
    80004b9a:	00004517          	auipc	a0,0x4
    80004b9e:	b2e50513          	addi	a0,a0,-1234 # 800086c8 <syscalls+0x278>
    80004ba2:	ffffc097          	auipc	ra,0xffffc
    80004ba6:	99c080e7          	jalr	-1636(ra) # 8000053e <panic>
    release(&ftable.lock);
    80004baa:	0001d517          	auipc	a0,0x1d
    80004bae:	0ee50513          	addi	a0,a0,238 # 80021c98 <ftable>
    80004bb2:	ffffc097          	auipc	ra,0xffffc
    80004bb6:	0d8080e7          	jalr	216(ra) # 80000c8a <release>
  }
}
    80004bba:	70e2                	ld	ra,56(sp)
    80004bbc:	7442                	ld	s0,48(sp)
    80004bbe:	74a2                	ld	s1,40(sp)
    80004bc0:	7902                	ld	s2,32(sp)
    80004bc2:	69e2                	ld	s3,24(sp)
    80004bc4:	6a42                	ld	s4,16(sp)
    80004bc6:	6aa2                	ld	s5,8(sp)
    80004bc8:	6121                	addi	sp,sp,64
    80004bca:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004bcc:	85d6                	mv	a1,s5
    80004bce:	8552                	mv	a0,s4
    80004bd0:	00000097          	auipc	ra,0x0
    80004bd4:	34c080e7          	jalr	844(ra) # 80004f1c <pipeclose>
    80004bd8:	b7cd                	j	80004bba <fileclose+0xa8>

0000000080004bda <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004bda:	715d                	addi	sp,sp,-80
    80004bdc:	e486                	sd	ra,72(sp)
    80004bde:	e0a2                	sd	s0,64(sp)
    80004be0:	fc26                	sd	s1,56(sp)
    80004be2:	f84a                	sd	s2,48(sp)
    80004be4:	f44e                	sd	s3,40(sp)
    80004be6:	0880                	addi	s0,sp,80
    80004be8:	84aa                	mv	s1,a0
    80004bea:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004bec:	ffffd097          	auipc	ra,0xffffd
    80004bf0:	df4080e7          	jalr	-524(ra) # 800019e0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004bf4:	409c                	lw	a5,0(s1)
    80004bf6:	37f9                	addiw	a5,a5,-2
    80004bf8:	4705                	li	a4,1
    80004bfa:	04f76763          	bltu	a4,a5,80004c48 <filestat+0x6e>
    80004bfe:	892a                	mv	s2,a0
    ilock(f->ip);
    80004c00:	6c88                	ld	a0,24(s1)
    80004c02:	fffff097          	auipc	ra,0xfffff
    80004c06:	082080e7          	jalr	130(ra) # 80003c84 <ilock>
    stati(f->ip, &st);
    80004c0a:	fb840593          	addi	a1,s0,-72
    80004c0e:	6c88                	ld	a0,24(s1)
    80004c10:	fffff097          	auipc	ra,0xfffff
    80004c14:	2fe080e7          	jalr	766(ra) # 80003f0e <stati>
    iunlock(f->ip);
    80004c18:	6c88                	ld	a0,24(s1)
    80004c1a:	fffff097          	auipc	ra,0xfffff
    80004c1e:	12c080e7          	jalr	300(ra) # 80003d46 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004c22:	46e1                	li	a3,24
    80004c24:	fb840613          	addi	a2,s0,-72
    80004c28:	85ce                	mv	a1,s3
    80004c2a:	09093503          	ld	a0,144(s2)
    80004c2e:	ffffd097          	auipc	ra,0xffffd
    80004c32:	a3a080e7          	jalr	-1478(ra) # 80001668 <copyout>
    80004c36:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004c3a:	60a6                	ld	ra,72(sp)
    80004c3c:	6406                	ld	s0,64(sp)
    80004c3e:	74e2                	ld	s1,56(sp)
    80004c40:	7942                	ld	s2,48(sp)
    80004c42:	79a2                	ld	s3,40(sp)
    80004c44:	6161                	addi	sp,sp,80
    80004c46:	8082                	ret
  return -1;
    80004c48:	557d                	li	a0,-1
    80004c4a:	bfc5                	j	80004c3a <filestat+0x60>

0000000080004c4c <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004c4c:	7179                	addi	sp,sp,-48
    80004c4e:	f406                	sd	ra,40(sp)
    80004c50:	f022                	sd	s0,32(sp)
    80004c52:	ec26                	sd	s1,24(sp)
    80004c54:	e84a                	sd	s2,16(sp)
    80004c56:	e44e                	sd	s3,8(sp)
    80004c58:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004c5a:	00854783          	lbu	a5,8(a0)
    80004c5e:	c3d5                	beqz	a5,80004d02 <fileread+0xb6>
    80004c60:	84aa                	mv	s1,a0
    80004c62:	89ae                	mv	s3,a1
    80004c64:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004c66:	411c                	lw	a5,0(a0)
    80004c68:	4705                	li	a4,1
    80004c6a:	04e78963          	beq	a5,a4,80004cbc <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004c6e:	470d                	li	a4,3
    80004c70:	04e78d63          	beq	a5,a4,80004cca <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c74:	4709                	li	a4,2
    80004c76:	06e79e63          	bne	a5,a4,80004cf2 <fileread+0xa6>
    ilock(f->ip);
    80004c7a:	6d08                	ld	a0,24(a0)
    80004c7c:	fffff097          	auipc	ra,0xfffff
    80004c80:	008080e7          	jalr	8(ra) # 80003c84 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004c84:	874a                	mv	a4,s2
    80004c86:	5094                	lw	a3,32(s1)
    80004c88:	864e                	mv	a2,s3
    80004c8a:	4585                	li	a1,1
    80004c8c:	6c88                	ld	a0,24(s1)
    80004c8e:	fffff097          	auipc	ra,0xfffff
    80004c92:	2aa080e7          	jalr	682(ra) # 80003f38 <readi>
    80004c96:	892a                	mv	s2,a0
    80004c98:	00a05563          	blez	a0,80004ca2 <fileread+0x56>
      f->off += r;
    80004c9c:	509c                	lw	a5,32(s1)
    80004c9e:	9fa9                	addw	a5,a5,a0
    80004ca0:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004ca2:	6c88                	ld	a0,24(s1)
    80004ca4:	fffff097          	auipc	ra,0xfffff
    80004ca8:	0a2080e7          	jalr	162(ra) # 80003d46 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004cac:	854a                	mv	a0,s2
    80004cae:	70a2                	ld	ra,40(sp)
    80004cb0:	7402                	ld	s0,32(sp)
    80004cb2:	64e2                	ld	s1,24(sp)
    80004cb4:	6942                	ld	s2,16(sp)
    80004cb6:	69a2                	ld	s3,8(sp)
    80004cb8:	6145                	addi	sp,sp,48
    80004cba:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004cbc:	6908                	ld	a0,16(a0)
    80004cbe:	00000097          	auipc	ra,0x0
    80004cc2:	3c6080e7          	jalr	966(ra) # 80005084 <piperead>
    80004cc6:	892a                	mv	s2,a0
    80004cc8:	b7d5                	j	80004cac <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004cca:	02451783          	lh	a5,36(a0)
    80004cce:	03079693          	slli	a3,a5,0x30
    80004cd2:	92c1                	srli	a3,a3,0x30
    80004cd4:	4725                	li	a4,9
    80004cd6:	02d76863          	bltu	a4,a3,80004d06 <fileread+0xba>
    80004cda:	0792                	slli	a5,a5,0x4
    80004cdc:	0001d717          	auipc	a4,0x1d
    80004ce0:	f1c70713          	addi	a4,a4,-228 # 80021bf8 <devsw>
    80004ce4:	97ba                	add	a5,a5,a4
    80004ce6:	639c                	ld	a5,0(a5)
    80004ce8:	c38d                	beqz	a5,80004d0a <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004cea:	4505                	li	a0,1
    80004cec:	9782                	jalr	a5
    80004cee:	892a                	mv	s2,a0
    80004cf0:	bf75                	j	80004cac <fileread+0x60>
    panic("fileread");
    80004cf2:	00004517          	auipc	a0,0x4
    80004cf6:	9e650513          	addi	a0,a0,-1562 # 800086d8 <syscalls+0x288>
    80004cfa:	ffffc097          	auipc	ra,0xffffc
    80004cfe:	844080e7          	jalr	-1980(ra) # 8000053e <panic>
    return -1;
    80004d02:	597d                	li	s2,-1
    80004d04:	b765                	j	80004cac <fileread+0x60>
      return -1;
    80004d06:	597d                	li	s2,-1
    80004d08:	b755                	j	80004cac <fileread+0x60>
    80004d0a:	597d                	li	s2,-1
    80004d0c:	b745                	j	80004cac <fileread+0x60>

0000000080004d0e <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004d0e:	715d                	addi	sp,sp,-80
    80004d10:	e486                	sd	ra,72(sp)
    80004d12:	e0a2                	sd	s0,64(sp)
    80004d14:	fc26                	sd	s1,56(sp)
    80004d16:	f84a                	sd	s2,48(sp)
    80004d18:	f44e                	sd	s3,40(sp)
    80004d1a:	f052                	sd	s4,32(sp)
    80004d1c:	ec56                	sd	s5,24(sp)
    80004d1e:	e85a                	sd	s6,16(sp)
    80004d20:	e45e                	sd	s7,8(sp)
    80004d22:	e062                	sd	s8,0(sp)
    80004d24:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004d26:	00954783          	lbu	a5,9(a0)
    80004d2a:	10078663          	beqz	a5,80004e36 <filewrite+0x128>
    80004d2e:	892a                	mv	s2,a0
    80004d30:	8aae                	mv	s5,a1
    80004d32:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004d34:	411c                	lw	a5,0(a0)
    80004d36:	4705                	li	a4,1
    80004d38:	02e78263          	beq	a5,a4,80004d5c <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004d3c:	470d                	li	a4,3
    80004d3e:	02e78663          	beq	a5,a4,80004d6a <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004d42:	4709                	li	a4,2
    80004d44:	0ee79163          	bne	a5,a4,80004e26 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004d48:	0ac05d63          	blez	a2,80004e02 <filewrite+0xf4>
    int i = 0;
    80004d4c:	4981                	li	s3,0
    80004d4e:	6b05                	lui	s6,0x1
    80004d50:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004d54:	6b85                	lui	s7,0x1
    80004d56:	c00b8b9b          	addiw	s7,s7,-1024
    80004d5a:	a861                	j	80004df2 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004d5c:	6908                	ld	a0,16(a0)
    80004d5e:	00000097          	auipc	ra,0x0
    80004d62:	22e080e7          	jalr	558(ra) # 80004f8c <pipewrite>
    80004d66:	8a2a                	mv	s4,a0
    80004d68:	a045                	j	80004e08 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004d6a:	02451783          	lh	a5,36(a0)
    80004d6e:	03079693          	slli	a3,a5,0x30
    80004d72:	92c1                	srli	a3,a3,0x30
    80004d74:	4725                	li	a4,9
    80004d76:	0cd76263          	bltu	a4,a3,80004e3a <filewrite+0x12c>
    80004d7a:	0792                	slli	a5,a5,0x4
    80004d7c:	0001d717          	auipc	a4,0x1d
    80004d80:	e7c70713          	addi	a4,a4,-388 # 80021bf8 <devsw>
    80004d84:	97ba                	add	a5,a5,a4
    80004d86:	679c                	ld	a5,8(a5)
    80004d88:	cbdd                	beqz	a5,80004e3e <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004d8a:	4505                	li	a0,1
    80004d8c:	9782                	jalr	a5
    80004d8e:	8a2a                	mv	s4,a0
    80004d90:	a8a5                	j	80004e08 <filewrite+0xfa>
    80004d92:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004d96:	00000097          	auipc	ra,0x0
    80004d9a:	8b0080e7          	jalr	-1872(ra) # 80004646 <begin_op>
      ilock(f->ip);
    80004d9e:	01893503          	ld	a0,24(s2)
    80004da2:	fffff097          	auipc	ra,0xfffff
    80004da6:	ee2080e7          	jalr	-286(ra) # 80003c84 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004daa:	8762                	mv	a4,s8
    80004dac:	02092683          	lw	a3,32(s2)
    80004db0:	01598633          	add	a2,s3,s5
    80004db4:	4585                	li	a1,1
    80004db6:	01893503          	ld	a0,24(s2)
    80004dba:	fffff097          	auipc	ra,0xfffff
    80004dbe:	276080e7          	jalr	630(ra) # 80004030 <writei>
    80004dc2:	84aa                	mv	s1,a0
    80004dc4:	00a05763          	blez	a0,80004dd2 <filewrite+0xc4>
        f->off += r;
    80004dc8:	02092783          	lw	a5,32(s2)
    80004dcc:	9fa9                	addw	a5,a5,a0
    80004dce:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004dd2:	01893503          	ld	a0,24(s2)
    80004dd6:	fffff097          	auipc	ra,0xfffff
    80004dda:	f70080e7          	jalr	-144(ra) # 80003d46 <iunlock>
      end_op();
    80004dde:	00000097          	auipc	ra,0x0
    80004de2:	8e8080e7          	jalr	-1816(ra) # 800046c6 <end_op>

      if(r != n1){
    80004de6:	009c1f63          	bne	s8,s1,80004e04 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004dea:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004dee:	0149db63          	bge	s3,s4,80004e04 <filewrite+0xf6>
      int n1 = n - i;
    80004df2:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004df6:	84be                	mv	s1,a5
    80004df8:	2781                	sext.w	a5,a5
    80004dfa:	f8fb5ce3          	bge	s6,a5,80004d92 <filewrite+0x84>
    80004dfe:	84de                	mv	s1,s7
    80004e00:	bf49                	j	80004d92 <filewrite+0x84>
    int i = 0;
    80004e02:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004e04:	013a1f63          	bne	s4,s3,80004e22 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004e08:	8552                	mv	a0,s4
    80004e0a:	60a6                	ld	ra,72(sp)
    80004e0c:	6406                	ld	s0,64(sp)
    80004e0e:	74e2                	ld	s1,56(sp)
    80004e10:	7942                	ld	s2,48(sp)
    80004e12:	79a2                	ld	s3,40(sp)
    80004e14:	7a02                	ld	s4,32(sp)
    80004e16:	6ae2                	ld	s5,24(sp)
    80004e18:	6b42                	ld	s6,16(sp)
    80004e1a:	6ba2                	ld	s7,8(sp)
    80004e1c:	6c02                	ld	s8,0(sp)
    80004e1e:	6161                	addi	sp,sp,80
    80004e20:	8082                	ret
    ret = (i == n ? n : -1);
    80004e22:	5a7d                	li	s4,-1
    80004e24:	b7d5                	j	80004e08 <filewrite+0xfa>
    panic("filewrite");
    80004e26:	00004517          	auipc	a0,0x4
    80004e2a:	8c250513          	addi	a0,a0,-1854 # 800086e8 <syscalls+0x298>
    80004e2e:	ffffb097          	auipc	ra,0xffffb
    80004e32:	710080e7          	jalr	1808(ra) # 8000053e <panic>
    return -1;
    80004e36:	5a7d                	li	s4,-1
    80004e38:	bfc1                	j	80004e08 <filewrite+0xfa>
      return -1;
    80004e3a:	5a7d                	li	s4,-1
    80004e3c:	b7f1                	j	80004e08 <filewrite+0xfa>
    80004e3e:	5a7d                	li	s4,-1
    80004e40:	b7e1                	j	80004e08 <filewrite+0xfa>

0000000080004e42 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004e42:	7179                	addi	sp,sp,-48
    80004e44:	f406                	sd	ra,40(sp)
    80004e46:	f022                	sd	s0,32(sp)
    80004e48:	ec26                	sd	s1,24(sp)
    80004e4a:	e84a                	sd	s2,16(sp)
    80004e4c:	e44e                	sd	s3,8(sp)
    80004e4e:	e052                	sd	s4,0(sp)
    80004e50:	1800                	addi	s0,sp,48
    80004e52:	84aa                	mv	s1,a0
    80004e54:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004e56:	0005b023          	sd	zero,0(a1)
    80004e5a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004e5e:	00000097          	auipc	ra,0x0
    80004e62:	bf8080e7          	jalr	-1032(ra) # 80004a56 <filealloc>
    80004e66:	e088                	sd	a0,0(s1)
    80004e68:	c551                	beqz	a0,80004ef4 <pipealloc+0xb2>
    80004e6a:	00000097          	auipc	ra,0x0
    80004e6e:	bec080e7          	jalr	-1044(ra) # 80004a56 <filealloc>
    80004e72:	00aa3023          	sd	a0,0(s4)
    80004e76:	c92d                	beqz	a0,80004ee8 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004e78:	ffffc097          	auipc	ra,0xffffc
    80004e7c:	c6e080e7          	jalr	-914(ra) # 80000ae6 <kalloc>
    80004e80:	892a                	mv	s2,a0
    80004e82:	c125                	beqz	a0,80004ee2 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004e84:	4985                	li	s3,1
    80004e86:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004e8a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004e8e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004e92:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004e96:	00004597          	auipc	a1,0x4
    80004e9a:	86258593          	addi	a1,a1,-1950 # 800086f8 <syscalls+0x2a8>
    80004e9e:	ffffc097          	auipc	ra,0xffffc
    80004ea2:	ca8080e7          	jalr	-856(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004ea6:	609c                	ld	a5,0(s1)
    80004ea8:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004eac:	609c                	ld	a5,0(s1)
    80004eae:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004eb2:	609c                	ld	a5,0(s1)
    80004eb4:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004eb8:	609c                	ld	a5,0(s1)
    80004eba:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004ebe:	000a3783          	ld	a5,0(s4)
    80004ec2:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004ec6:	000a3783          	ld	a5,0(s4)
    80004eca:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004ece:	000a3783          	ld	a5,0(s4)
    80004ed2:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004ed6:	000a3783          	ld	a5,0(s4)
    80004eda:	0127b823          	sd	s2,16(a5)
  return 0;
    80004ede:	4501                	li	a0,0
    80004ee0:	a025                	j	80004f08 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004ee2:	6088                	ld	a0,0(s1)
    80004ee4:	e501                	bnez	a0,80004eec <pipealloc+0xaa>
    80004ee6:	a039                	j	80004ef4 <pipealloc+0xb2>
    80004ee8:	6088                	ld	a0,0(s1)
    80004eea:	c51d                	beqz	a0,80004f18 <pipealloc+0xd6>
    fileclose(*f0);
    80004eec:	00000097          	auipc	ra,0x0
    80004ef0:	c26080e7          	jalr	-986(ra) # 80004b12 <fileclose>
  if(*f1)
    80004ef4:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004ef8:	557d                	li	a0,-1
  if(*f1)
    80004efa:	c799                	beqz	a5,80004f08 <pipealloc+0xc6>
    fileclose(*f1);
    80004efc:	853e                	mv	a0,a5
    80004efe:	00000097          	auipc	ra,0x0
    80004f02:	c14080e7          	jalr	-1004(ra) # 80004b12 <fileclose>
  return -1;
    80004f06:	557d                	li	a0,-1
}
    80004f08:	70a2                	ld	ra,40(sp)
    80004f0a:	7402                	ld	s0,32(sp)
    80004f0c:	64e2                	ld	s1,24(sp)
    80004f0e:	6942                	ld	s2,16(sp)
    80004f10:	69a2                	ld	s3,8(sp)
    80004f12:	6a02                	ld	s4,0(sp)
    80004f14:	6145                	addi	sp,sp,48
    80004f16:	8082                	ret
  return -1;
    80004f18:	557d                	li	a0,-1
    80004f1a:	b7fd                	j	80004f08 <pipealloc+0xc6>

0000000080004f1c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004f1c:	1101                	addi	sp,sp,-32
    80004f1e:	ec06                	sd	ra,24(sp)
    80004f20:	e822                	sd	s0,16(sp)
    80004f22:	e426                	sd	s1,8(sp)
    80004f24:	e04a                	sd	s2,0(sp)
    80004f26:	1000                	addi	s0,sp,32
    80004f28:	84aa                	mv	s1,a0
    80004f2a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004f2c:	ffffc097          	auipc	ra,0xffffc
    80004f30:	caa080e7          	jalr	-854(ra) # 80000bd6 <acquire>
  if(writable){
    80004f34:	02090d63          	beqz	s2,80004f6e <pipeclose+0x52>
    pi->writeopen = 0;
    80004f38:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004f3c:	21848513          	addi	a0,s1,536
    80004f40:	ffffd097          	auipc	ra,0xffffd
    80004f44:	474080e7          	jalr	1140(ra) # 800023b4 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004f48:	2204b783          	ld	a5,544(s1)
    80004f4c:	eb95                	bnez	a5,80004f80 <pipeclose+0x64>
    release(&pi->lock);
    80004f4e:	8526                	mv	a0,s1
    80004f50:	ffffc097          	auipc	ra,0xffffc
    80004f54:	d3a080e7          	jalr	-710(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004f58:	8526                	mv	a0,s1
    80004f5a:	ffffc097          	auipc	ra,0xffffc
    80004f5e:	a90080e7          	jalr	-1392(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    80004f62:	60e2                	ld	ra,24(sp)
    80004f64:	6442                	ld	s0,16(sp)
    80004f66:	64a2                	ld	s1,8(sp)
    80004f68:	6902                	ld	s2,0(sp)
    80004f6a:	6105                	addi	sp,sp,32
    80004f6c:	8082                	ret
    pi->readopen = 0;
    80004f6e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004f72:	21c48513          	addi	a0,s1,540
    80004f76:	ffffd097          	auipc	ra,0xffffd
    80004f7a:	43e080e7          	jalr	1086(ra) # 800023b4 <wakeup>
    80004f7e:	b7e9                	j	80004f48 <pipeclose+0x2c>
    release(&pi->lock);
    80004f80:	8526                	mv	a0,s1
    80004f82:	ffffc097          	auipc	ra,0xffffc
    80004f86:	d08080e7          	jalr	-760(ra) # 80000c8a <release>
}
    80004f8a:	bfe1                	j	80004f62 <pipeclose+0x46>

0000000080004f8c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004f8c:	711d                	addi	sp,sp,-96
    80004f8e:	ec86                	sd	ra,88(sp)
    80004f90:	e8a2                	sd	s0,80(sp)
    80004f92:	e4a6                	sd	s1,72(sp)
    80004f94:	e0ca                	sd	s2,64(sp)
    80004f96:	fc4e                	sd	s3,56(sp)
    80004f98:	f852                	sd	s4,48(sp)
    80004f9a:	f456                	sd	s5,40(sp)
    80004f9c:	f05a                	sd	s6,32(sp)
    80004f9e:	ec5e                	sd	s7,24(sp)
    80004fa0:	e862                	sd	s8,16(sp)
    80004fa2:	1080                	addi	s0,sp,96
    80004fa4:	84aa                	mv	s1,a0
    80004fa6:	8aae                	mv	s5,a1
    80004fa8:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004faa:	ffffd097          	auipc	ra,0xffffd
    80004fae:	a36080e7          	jalr	-1482(ra) # 800019e0 <myproc>
    80004fb2:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004fb4:	8526                	mv	a0,s1
    80004fb6:	ffffc097          	auipc	ra,0xffffc
    80004fba:	c20080e7          	jalr	-992(ra) # 80000bd6 <acquire>
  while(i < n){
    80004fbe:	0b405663          	blez	s4,8000506a <pipewrite+0xde>
  int i = 0;
    80004fc2:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004fc4:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004fc6:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004fca:	21c48b93          	addi	s7,s1,540
    80004fce:	a089                	j	80005010 <pipewrite+0x84>
      release(&pi->lock);
    80004fd0:	8526                	mv	a0,s1
    80004fd2:	ffffc097          	auipc	ra,0xffffc
    80004fd6:	cb8080e7          	jalr	-840(ra) # 80000c8a <release>
      return -1;
    80004fda:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004fdc:	854a                	mv	a0,s2
    80004fde:	60e6                	ld	ra,88(sp)
    80004fe0:	6446                	ld	s0,80(sp)
    80004fe2:	64a6                	ld	s1,72(sp)
    80004fe4:	6906                	ld	s2,64(sp)
    80004fe6:	79e2                	ld	s3,56(sp)
    80004fe8:	7a42                	ld	s4,48(sp)
    80004fea:	7aa2                	ld	s5,40(sp)
    80004fec:	7b02                	ld	s6,32(sp)
    80004fee:	6be2                	ld	s7,24(sp)
    80004ff0:	6c42                	ld	s8,16(sp)
    80004ff2:	6125                	addi	sp,sp,96
    80004ff4:	8082                	ret
      wakeup(&pi->nread);
    80004ff6:	8562                	mv	a0,s8
    80004ff8:	ffffd097          	auipc	ra,0xffffd
    80004ffc:	3bc080e7          	jalr	956(ra) # 800023b4 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005000:	85a6                	mv	a1,s1
    80005002:	855e                	mv	a0,s7
    80005004:	ffffd097          	auipc	ra,0xffffd
    80005008:	2c8080e7          	jalr	712(ra) # 800022cc <sleep>
  while(i < n){
    8000500c:	07495063          	bge	s2,s4,8000506c <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80005010:	2204a783          	lw	a5,544(s1)
    80005014:	dfd5                	beqz	a5,80004fd0 <pipewrite+0x44>
    80005016:	854e                	mv	a0,s3
    80005018:	ffffd097          	auipc	ra,0xffffd
    8000501c:	608080e7          	jalr	1544(ra) # 80002620 <killed>
    80005020:	f945                	bnez	a0,80004fd0 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005022:	2184a783          	lw	a5,536(s1)
    80005026:	21c4a703          	lw	a4,540(s1)
    8000502a:	2007879b          	addiw	a5,a5,512
    8000502e:	fcf704e3          	beq	a4,a5,80004ff6 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005032:	4685                	li	a3,1
    80005034:	01590633          	add	a2,s2,s5
    80005038:	faf40593          	addi	a1,s0,-81
    8000503c:	0909b503          	ld	a0,144(s3)
    80005040:	ffffc097          	auipc	ra,0xffffc
    80005044:	6b4080e7          	jalr	1716(ra) # 800016f4 <copyin>
    80005048:	03650263          	beq	a0,s6,8000506c <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000504c:	21c4a783          	lw	a5,540(s1)
    80005050:	0017871b          	addiw	a4,a5,1
    80005054:	20e4ae23          	sw	a4,540(s1)
    80005058:	1ff7f793          	andi	a5,a5,511
    8000505c:	97a6                	add	a5,a5,s1
    8000505e:	faf44703          	lbu	a4,-81(s0)
    80005062:	00e78c23          	sb	a4,24(a5)
      i++;
    80005066:	2905                	addiw	s2,s2,1
    80005068:	b755                	j	8000500c <pipewrite+0x80>
  int i = 0;
    8000506a:	4901                	li	s2,0
  wakeup(&pi->nread);
    8000506c:	21848513          	addi	a0,s1,536
    80005070:	ffffd097          	auipc	ra,0xffffd
    80005074:	344080e7          	jalr	836(ra) # 800023b4 <wakeup>
  release(&pi->lock);
    80005078:	8526                	mv	a0,s1
    8000507a:	ffffc097          	auipc	ra,0xffffc
    8000507e:	c10080e7          	jalr	-1008(ra) # 80000c8a <release>
  return i;
    80005082:	bfa9                	j	80004fdc <pipewrite+0x50>

0000000080005084 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005084:	715d                	addi	sp,sp,-80
    80005086:	e486                	sd	ra,72(sp)
    80005088:	e0a2                	sd	s0,64(sp)
    8000508a:	fc26                	sd	s1,56(sp)
    8000508c:	f84a                	sd	s2,48(sp)
    8000508e:	f44e                	sd	s3,40(sp)
    80005090:	f052                	sd	s4,32(sp)
    80005092:	ec56                	sd	s5,24(sp)
    80005094:	e85a                	sd	s6,16(sp)
    80005096:	0880                	addi	s0,sp,80
    80005098:	84aa                	mv	s1,a0
    8000509a:	892e                	mv	s2,a1
    8000509c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000509e:	ffffd097          	auipc	ra,0xffffd
    800050a2:	942080e7          	jalr	-1726(ra) # 800019e0 <myproc>
    800050a6:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800050a8:	8526                	mv	a0,s1
    800050aa:	ffffc097          	auipc	ra,0xffffc
    800050ae:	b2c080e7          	jalr	-1236(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800050b2:	2184a703          	lw	a4,536(s1)
    800050b6:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800050ba:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800050be:	02f71763          	bne	a4,a5,800050ec <piperead+0x68>
    800050c2:	2244a783          	lw	a5,548(s1)
    800050c6:	c39d                	beqz	a5,800050ec <piperead+0x68>
    if(killed(pr)){
    800050c8:	8552                	mv	a0,s4
    800050ca:	ffffd097          	auipc	ra,0xffffd
    800050ce:	556080e7          	jalr	1366(ra) # 80002620 <killed>
    800050d2:	e941                	bnez	a0,80005162 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800050d4:	85a6                	mv	a1,s1
    800050d6:	854e                	mv	a0,s3
    800050d8:	ffffd097          	auipc	ra,0xffffd
    800050dc:	1f4080e7          	jalr	500(ra) # 800022cc <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800050e0:	2184a703          	lw	a4,536(s1)
    800050e4:	21c4a783          	lw	a5,540(s1)
    800050e8:	fcf70de3          	beq	a4,a5,800050c2 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050ec:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800050ee:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050f0:	05505363          	blez	s5,80005136 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    800050f4:	2184a783          	lw	a5,536(s1)
    800050f8:	21c4a703          	lw	a4,540(s1)
    800050fc:	02f70d63          	beq	a4,a5,80005136 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005100:	0017871b          	addiw	a4,a5,1
    80005104:	20e4ac23          	sw	a4,536(s1)
    80005108:	1ff7f793          	andi	a5,a5,511
    8000510c:	97a6                	add	a5,a5,s1
    8000510e:	0187c783          	lbu	a5,24(a5)
    80005112:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005116:	4685                	li	a3,1
    80005118:	fbf40613          	addi	a2,s0,-65
    8000511c:	85ca                	mv	a1,s2
    8000511e:	090a3503          	ld	a0,144(s4)
    80005122:	ffffc097          	auipc	ra,0xffffc
    80005126:	546080e7          	jalr	1350(ra) # 80001668 <copyout>
    8000512a:	01650663          	beq	a0,s6,80005136 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000512e:	2985                	addiw	s3,s3,1
    80005130:	0905                	addi	s2,s2,1
    80005132:	fd3a91e3          	bne	s5,s3,800050f4 <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005136:	21c48513          	addi	a0,s1,540
    8000513a:	ffffd097          	auipc	ra,0xffffd
    8000513e:	27a080e7          	jalr	634(ra) # 800023b4 <wakeup>
  release(&pi->lock);
    80005142:	8526                	mv	a0,s1
    80005144:	ffffc097          	auipc	ra,0xffffc
    80005148:	b46080e7          	jalr	-1210(ra) # 80000c8a <release>
  return i;
}
    8000514c:	854e                	mv	a0,s3
    8000514e:	60a6                	ld	ra,72(sp)
    80005150:	6406                	ld	s0,64(sp)
    80005152:	74e2                	ld	s1,56(sp)
    80005154:	7942                	ld	s2,48(sp)
    80005156:	79a2                	ld	s3,40(sp)
    80005158:	7a02                	ld	s4,32(sp)
    8000515a:	6ae2                	ld	s5,24(sp)
    8000515c:	6b42                	ld	s6,16(sp)
    8000515e:	6161                	addi	sp,sp,80
    80005160:	8082                	ret
      release(&pi->lock);
    80005162:	8526                	mv	a0,s1
    80005164:	ffffc097          	auipc	ra,0xffffc
    80005168:	b26080e7          	jalr	-1242(ra) # 80000c8a <release>
      return -1;
    8000516c:	59fd                	li	s3,-1
    8000516e:	bff9                	j	8000514c <piperead+0xc8>

0000000080005170 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80005170:	1141                	addi	sp,sp,-16
    80005172:	e422                	sd	s0,8(sp)
    80005174:	0800                	addi	s0,sp,16
    80005176:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80005178:	8905                	andi	a0,a0,1
    8000517a:	c111                	beqz	a0,8000517e <flags2perm+0xe>
      perm = PTE_X;
    8000517c:	4521                	li	a0,8
    if(flags & 0x2)
    8000517e:	8b89                	andi	a5,a5,2
    80005180:	c399                	beqz	a5,80005186 <flags2perm+0x16>
      perm |= PTE_W;
    80005182:	00456513          	ori	a0,a0,4
    return perm;
}
    80005186:	6422                	ld	s0,8(sp)
    80005188:	0141                	addi	sp,sp,16
    8000518a:	8082                	ret

000000008000518c <exec>:

int
exec(char *path, char **argv)
{
    8000518c:	de010113          	addi	sp,sp,-544
    80005190:	20113c23          	sd	ra,536(sp)
    80005194:	20813823          	sd	s0,528(sp)
    80005198:	20913423          	sd	s1,520(sp)
    8000519c:	21213023          	sd	s2,512(sp)
    800051a0:	ffce                	sd	s3,504(sp)
    800051a2:	fbd2                	sd	s4,496(sp)
    800051a4:	f7d6                	sd	s5,488(sp)
    800051a6:	f3da                	sd	s6,480(sp)
    800051a8:	efde                	sd	s7,472(sp)
    800051aa:	ebe2                	sd	s8,464(sp)
    800051ac:	e7e6                	sd	s9,456(sp)
    800051ae:	e3ea                	sd	s10,448(sp)
    800051b0:	ff6e                	sd	s11,440(sp)
    800051b2:	1400                	addi	s0,sp,544
    800051b4:	892a                	mv	s2,a0
    800051b6:	dea43423          	sd	a0,-536(s0)
    800051ba:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800051be:	ffffd097          	auipc	ra,0xffffd
    800051c2:	822080e7          	jalr	-2014(ra) # 800019e0 <myproc>
    800051c6:	84aa                	mv	s1,a0

  begin_op();
    800051c8:	fffff097          	auipc	ra,0xfffff
    800051cc:	47e080e7          	jalr	1150(ra) # 80004646 <begin_op>

  if((ip = namei(path)) == 0){
    800051d0:	854a                	mv	a0,s2
    800051d2:	fffff097          	auipc	ra,0xfffff
    800051d6:	258080e7          	jalr	600(ra) # 8000442a <namei>
    800051da:	c93d                	beqz	a0,80005250 <exec+0xc4>
    800051dc:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800051de:	fffff097          	auipc	ra,0xfffff
    800051e2:	aa6080e7          	jalr	-1370(ra) # 80003c84 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800051e6:	04000713          	li	a4,64
    800051ea:	4681                	li	a3,0
    800051ec:	e5040613          	addi	a2,s0,-432
    800051f0:	4581                	li	a1,0
    800051f2:	8556                	mv	a0,s5
    800051f4:	fffff097          	auipc	ra,0xfffff
    800051f8:	d44080e7          	jalr	-700(ra) # 80003f38 <readi>
    800051fc:	04000793          	li	a5,64
    80005200:	00f51a63          	bne	a0,a5,80005214 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80005204:	e5042703          	lw	a4,-432(s0)
    80005208:	464c47b7          	lui	a5,0x464c4
    8000520c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005210:	04f70663          	beq	a4,a5,8000525c <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005214:	8556                	mv	a0,s5
    80005216:	fffff097          	auipc	ra,0xfffff
    8000521a:	cd0080e7          	jalr	-816(ra) # 80003ee6 <iunlockput>
    end_op();
    8000521e:	fffff097          	auipc	ra,0xfffff
    80005222:	4a8080e7          	jalr	1192(ra) # 800046c6 <end_op>
  }
  return -1;
    80005226:	557d                	li	a0,-1
}
    80005228:	21813083          	ld	ra,536(sp)
    8000522c:	21013403          	ld	s0,528(sp)
    80005230:	20813483          	ld	s1,520(sp)
    80005234:	20013903          	ld	s2,512(sp)
    80005238:	79fe                	ld	s3,504(sp)
    8000523a:	7a5e                	ld	s4,496(sp)
    8000523c:	7abe                	ld	s5,488(sp)
    8000523e:	7b1e                	ld	s6,480(sp)
    80005240:	6bfe                	ld	s7,472(sp)
    80005242:	6c5e                	ld	s8,464(sp)
    80005244:	6cbe                	ld	s9,456(sp)
    80005246:	6d1e                	ld	s10,448(sp)
    80005248:	7dfa                	ld	s11,440(sp)
    8000524a:	22010113          	addi	sp,sp,544
    8000524e:	8082                	ret
    end_op();
    80005250:	fffff097          	auipc	ra,0xfffff
    80005254:	476080e7          	jalr	1142(ra) # 800046c6 <end_op>
    return -1;
    80005258:	557d                	li	a0,-1
    8000525a:	b7f9                	j	80005228 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    8000525c:	8526                	mv	a0,s1
    8000525e:	ffffd097          	auipc	ra,0xffffd
    80005262:	846080e7          	jalr	-1978(ra) # 80001aa4 <proc_pagetable>
    80005266:	8b2a                	mv	s6,a0
    80005268:	d555                	beqz	a0,80005214 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000526a:	e7042783          	lw	a5,-400(s0)
    8000526e:	e8845703          	lhu	a4,-376(s0)
    80005272:	c735                	beqz	a4,800052de <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005274:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005276:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    8000527a:	6a05                	lui	s4,0x1
    8000527c:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005280:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80005284:	6d85                	lui	s11,0x1
    80005286:	7d7d                	lui	s10,0xfffff
    80005288:	a481                	j	800054c8 <exec+0x33c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000528a:	00003517          	auipc	a0,0x3
    8000528e:	47650513          	addi	a0,a0,1142 # 80008700 <syscalls+0x2b0>
    80005292:	ffffb097          	auipc	ra,0xffffb
    80005296:	2ac080e7          	jalr	684(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000529a:	874a                	mv	a4,s2
    8000529c:	009c86bb          	addw	a3,s9,s1
    800052a0:	4581                	li	a1,0
    800052a2:	8556                	mv	a0,s5
    800052a4:	fffff097          	auipc	ra,0xfffff
    800052a8:	c94080e7          	jalr	-876(ra) # 80003f38 <readi>
    800052ac:	2501                	sext.w	a0,a0
    800052ae:	1aa91a63          	bne	s2,a0,80005462 <exec+0x2d6>
  for(i = 0; i < sz; i += PGSIZE){
    800052b2:	009d84bb          	addw	s1,s11,s1
    800052b6:	013d09bb          	addw	s3,s10,s3
    800052ba:	1f74f763          	bgeu	s1,s7,800054a8 <exec+0x31c>
    pa = walkaddr(pagetable, va + i);
    800052be:	02049593          	slli	a1,s1,0x20
    800052c2:	9181                	srli	a1,a1,0x20
    800052c4:	95e2                	add	a1,a1,s8
    800052c6:	855a                	mv	a0,s6
    800052c8:	ffffc097          	auipc	ra,0xffffc
    800052cc:	d94080e7          	jalr	-620(ra) # 8000105c <walkaddr>
    800052d0:	862a                	mv	a2,a0
    if(pa == 0)
    800052d2:	dd45                	beqz	a0,8000528a <exec+0xfe>
      n = PGSIZE;
    800052d4:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    800052d6:	fd49f2e3          	bgeu	s3,s4,8000529a <exec+0x10e>
      n = sz - i;
    800052da:	894e                	mv	s2,s3
    800052dc:	bf7d                	j	8000529a <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800052de:	4901                	li	s2,0
  iunlockput(ip);
    800052e0:	8556                	mv	a0,s5
    800052e2:	fffff097          	auipc	ra,0xfffff
    800052e6:	c04080e7          	jalr	-1020(ra) # 80003ee6 <iunlockput>
  end_op();
    800052ea:	fffff097          	auipc	ra,0xfffff
    800052ee:	3dc080e7          	jalr	988(ra) # 800046c6 <end_op>
  p = myproc();
    800052f2:	ffffc097          	auipc	ra,0xffffc
    800052f6:	6ee080e7          	jalr	1774(ra) # 800019e0 <myproc>
    800052fa:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    800052fc:	08853d03          	ld	s10,136(a0)
  sz = PGROUNDUP(sz);
    80005300:	6785                	lui	a5,0x1
    80005302:	17fd                	addi	a5,a5,-1
    80005304:	993e                	add	s2,s2,a5
    80005306:	77fd                	lui	a5,0xfffff
    80005308:	00f977b3          	and	a5,s2,a5
    8000530c:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005310:	4691                	li	a3,4
    80005312:	6609                	lui	a2,0x2
    80005314:	963e                	add	a2,a2,a5
    80005316:	85be                	mv	a1,a5
    80005318:	855a                	mv	a0,s6
    8000531a:	ffffc097          	auipc	ra,0xffffc
    8000531e:	0f6080e7          	jalr	246(ra) # 80001410 <uvmalloc>
    80005322:	8c2a                	mv	s8,a0
  ip = 0;
    80005324:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005326:	12050e63          	beqz	a0,80005462 <exec+0x2d6>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000532a:	75f9                	lui	a1,0xffffe
    8000532c:	95aa                	add	a1,a1,a0
    8000532e:	855a                	mv	a0,s6
    80005330:	ffffc097          	auipc	ra,0xffffc
    80005334:	306080e7          	jalr	774(ra) # 80001636 <uvmclear>
  stackbase = sp - PGSIZE;
    80005338:	7afd                	lui	s5,0xfffff
    8000533a:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    8000533c:	df043783          	ld	a5,-528(s0)
    80005340:	6388                	ld	a0,0(a5)
    80005342:	c925                	beqz	a0,800053b2 <exec+0x226>
    80005344:	e9040993          	addi	s3,s0,-368
    80005348:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    8000534c:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000534e:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005350:	ffffc097          	auipc	ra,0xffffc
    80005354:	afe080e7          	jalr	-1282(ra) # 80000e4e <strlen>
    80005358:	0015079b          	addiw	a5,a0,1
    8000535c:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005360:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005364:	13596663          	bltu	s2,s5,80005490 <exec+0x304>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005368:	df043d83          	ld	s11,-528(s0)
    8000536c:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005370:	8552                	mv	a0,s4
    80005372:	ffffc097          	auipc	ra,0xffffc
    80005376:	adc080e7          	jalr	-1316(ra) # 80000e4e <strlen>
    8000537a:	0015069b          	addiw	a3,a0,1
    8000537e:	8652                	mv	a2,s4
    80005380:	85ca                	mv	a1,s2
    80005382:	855a                	mv	a0,s6
    80005384:	ffffc097          	auipc	ra,0xffffc
    80005388:	2e4080e7          	jalr	740(ra) # 80001668 <copyout>
    8000538c:	10054663          	bltz	a0,80005498 <exec+0x30c>
    ustack[argc] = sp;
    80005390:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005394:	0485                	addi	s1,s1,1
    80005396:	008d8793          	addi	a5,s11,8
    8000539a:	def43823          	sd	a5,-528(s0)
    8000539e:	008db503          	ld	a0,8(s11)
    800053a2:	c911                	beqz	a0,800053b6 <exec+0x22a>
    if(argc >= MAXARG)
    800053a4:	09a1                	addi	s3,s3,8
    800053a6:	fb3c95e3          	bne	s9,s3,80005350 <exec+0x1c4>
  sz = sz1;
    800053aa:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800053ae:	4a81                	li	s5,0
    800053b0:	a84d                	j	80005462 <exec+0x2d6>
  sp = sz;
    800053b2:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800053b4:	4481                	li	s1,0
  ustack[argc] = 0;
    800053b6:	00349793          	slli	a5,s1,0x3
    800053ba:	f9040713          	addi	a4,s0,-112
    800053be:	97ba                	add	a5,a5,a4
    800053c0:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffdc170>
  sp -= (argc+1) * sizeof(uint64);
    800053c4:	00148693          	addi	a3,s1,1
    800053c8:	068e                	slli	a3,a3,0x3
    800053ca:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800053ce:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800053d2:	01597663          	bgeu	s2,s5,800053de <exec+0x252>
  sz = sz1;
    800053d6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800053da:	4a81                	li	s5,0
    800053dc:	a059                	j	80005462 <exec+0x2d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800053de:	e9040613          	addi	a2,s0,-368
    800053e2:	85ca                	mv	a1,s2
    800053e4:	855a                	mv	a0,s6
    800053e6:	ffffc097          	auipc	ra,0xffffc
    800053ea:	282080e7          	jalr	642(ra) # 80001668 <copyout>
    800053ee:	0a054963          	bltz	a0,800054a0 <exec+0x314>
  p->trapframe->a1 = sp;
    800053f2:	098bb783          	ld	a5,152(s7) # 1098 <_entry-0x7fffef68>
    800053f6:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800053fa:	de843783          	ld	a5,-536(s0)
    800053fe:	0007c703          	lbu	a4,0(a5)
    80005402:	cf11                	beqz	a4,8000541e <exec+0x292>
    80005404:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005406:	02f00693          	li	a3,47
    8000540a:	a039                	j	80005418 <exec+0x28c>
      last = s+1;
    8000540c:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005410:	0785                	addi	a5,a5,1
    80005412:	fff7c703          	lbu	a4,-1(a5)
    80005416:	c701                	beqz	a4,8000541e <exec+0x292>
    if(*s == '/')
    80005418:	fed71ce3          	bne	a4,a3,80005410 <exec+0x284>
    8000541c:	bfc5                	j	8000540c <exec+0x280>
  safestrcpy(p->name, last, sizeof(p->name));
    8000541e:	4641                	li	a2,16
    80005420:	de843583          	ld	a1,-536(s0)
    80005424:	198b8513          	addi	a0,s7,408
    80005428:	ffffc097          	auipc	ra,0xffffc
    8000542c:	9f4080e7          	jalr	-1548(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    80005430:	090bb503          	ld	a0,144(s7)
  p->pagetable = pagetable;
    80005434:	096bb823          	sd	s6,144(s7)
  p->sz = sz;
    80005438:	098bb423          	sd	s8,136(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000543c:	098bb783          	ld	a5,152(s7)
    80005440:	e6843703          	ld	a4,-408(s0)
    80005444:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005446:	098bb783          	ld	a5,152(s7)
    8000544a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000544e:	85ea                	mv	a1,s10
    80005450:	ffffc097          	auipc	ra,0xffffc
    80005454:	6f0080e7          	jalr	1776(ra) # 80001b40 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005458:	0004851b          	sext.w	a0,s1
    8000545c:	b3f1                	j	80005228 <exec+0x9c>
    8000545e:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005462:	df843583          	ld	a1,-520(s0)
    80005466:	855a                	mv	a0,s6
    80005468:	ffffc097          	auipc	ra,0xffffc
    8000546c:	6d8080e7          	jalr	1752(ra) # 80001b40 <proc_freepagetable>
  if(ip){
    80005470:	da0a92e3          	bnez	s5,80005214 <exec+0x88>
  return -1;
    80005474:	557d                	li	a0,-1
    80005476:	bb4d                	j	80005228 <exec+0x9c>
    80005478:	df243c23          	sd	s2,-520(s0)
    8000547c:	b7dd                	j	80005462 <exec+0x2d6>
    8000547e:	df243c23          	sd	s2,-520(s0)
    80005482:	b7c5                	j	80005462 <exec+0x2d6>
    80005484:	df243c23          	sd	s2,-520(s0)
    80005488:	bfe9                	j	80005462 <exec+0x2d6>
    8000548a:	df243c23          	sd	s2,-520(s0)
    8000548e:	bfd1                	j	80005462 <exec+0x2d6>
  sz = sz1;
    80005490:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005494:	4a81                	li	s5,0
    80005496:	b7f1                	j	80005462 <exec+0x2d6>
  sz = sz1;
    80005498:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000549c:	4a81                	li	s5,0
    8000549e:	b7d1                	j	80005462 <exec+0x2d6>
  sz = sz1;
    800054a0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800054a4:	4a81                	li	s5,0
    800054a6:	bf75                	j	80005462 <exec+0x2d6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800054a8:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800054ac:	e0843783          	ld	a5,-504(s0)
    800054b0:	0017869b          	addiw	a3,a5,1
    800054b4:	e0d43423          	sd	a3,-504(s0)
    800054b8:	e0043783          	ld	a5,-512(s0)
    800054bc:	0387879b          	addiw	a5,a5,56
    800054c0:	e8845703          	lhu	a4,-376(s0)
    800054c4:	e0e6dee3          	bge	a3,a4,800052e0 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800054c8:	2781                	sext.w	a5,a5
    800054ca:	e0f43023          	sd	a5,-512(s0)
    800054ce:	03800713          	li	a4,56
    800054d2:	86be                	mv	a3,a5
    800054d4:	e1840613          	addi	a2,s0,-488
    800054d8:	4581                	li	a1,0
    800054da:	8556                	mv	a0,s5
    800054dc:	fffff097          	auipc	ra,0xfffff
    800054e0:	a5c080e7          	jalr	-1444(ra) # 80003f38 <readi>
    800054e4:	03800793          	li	a5,56
    800054e8:	f6f51be3          	bne	a0,a5,8000545e <exec+0x2d2>
    if(ph.type != ELF_PROG_LOAD)
    800054ec:	e1842783          	lw	a5,-488(s0)
    800054f0:	4705                	li	a4,1
    800054f2:	fae79de3          	bne	a5,a4,800054ac <exec+0x320>
    if(ph.memsz < ph.filesz)
    800054f6:	e4043483          	ld	s1,-448(s0)
    800054fa:	e3843783          	ld	a5,-456(s0)
    800054fe:	f6f4ede3          	bltu	s1,a5,80005478 <exec+0x2ec>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005502:	e2843783          	ld	a5,-472(s0)
    80005506:	94be                	add	s1,s1,a5
    80005508:	f6f4ebe3          	bltu	s1,a5,8000547e <exec+0x2f2>
    if(ph.vaddr % PGSIZE != 0)
    8000550c:	de043703          	ld	a4,-544(s0)
    80005510:	8ff9                	and	a5,a5,a4
    80005512:	fbad                	bnez	a5,80005484 <exec+0x2f8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005514:	e1c42503          	lw	a0,-484(s0)
    80005518:	00000097          	auipc	ra,0x0
    8000551c:	c58080e7          	jalr	-936(ra) # 80005170 <flags2perm>
    80005520:	86aa                	mv	a3,a0
    80005522:	8626                	mv	a2,s1
    80005524:	85ca                	mv	a1,s2
    80005526:	855a                	mv	a0,s6
    80005528:	ffffc097          	auipc	ra,0xffffc
    8000552c:	ee8080e7          	jalr	-280(ra) # 80001410 <uvmalloc>
    80005530:	dea43c23          	sd	a0,-520(s0)
    80005534:	d939                	beqz	a0,8000548a <exec+0x2fe>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005536:	e2843c03          	ld	s8,-472(s0)
    8000553a:	e2042c83          	lw	s9,-480(s0)
    8000553e:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005542:	f60b83e3          	beqz	s7,800054a8 <exec+0x31c>
    80005546:	89de                	mv	s3,s7
    80005548:	4481                	li	s1,0
    8000554a:	bb95                	j	800052be <exec+0x132>

000000008000554c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000554c:	7179                	addi	sp,sp,-48
    8000554e:	f406                	sd	ra,40(sp)
    80005550:	f022                	sd	s0,32(sp)
    80005552:	ec26                	sd	s1,24(sp)
    80005554:	e84a                	sd	s2,16(sp)
    80005556:	1800                	addi	s0,sp,48
    80005558:	892e                	mv	s2,a1
    8000555a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000555c:	fdc40593          	addi	a1,s0,-36
    80005560:	ffffe097          	auipc	ra,0xffffe
    80005564:	a16080e7          	jalr	-1514(ra) # 80002f76 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005568:	fdc42703          	lw	a4,-36(s0)
    8000556c:	47bd                	li	a5,15
    8000556e:	02e7eb63          	bltu	a5,a4,800055a4 <argfd+0x58>
    80005572:	ffffc097          	auipc	ra,0xffffc
    80005576:	46e080e7          	jalr	1134(ra) # 800019e0 <myproc>
    8000557a:	fdc42703          	lw	a4,-36(s0)
    8000557e:	02270793          	addi	a5,a4,34
    80005582:	078e                	slli	a5,a5,0x3
    80005584:	953e                	add	a0,a0,a5
    80005586:	611c                	ld	a5,0(a0)
    80005588:	c385                	beqz	a5,800055a8 <argfd+0x5c>
    return -1;
  if(pfd)
    8000558a:	00090463          	beqz	s2,80005592 <argfd+0x46>
    *pfd = fd;
    8000558e:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005592:	4501                	li	a0,0
  if(pf)
    80005594:	c091                	beqz	s1,80005598 <argfd+0x4c>
    *pf = f;
    80005596:	e09c                	sd	a5,0(s1)
}
    80005598:	70a2                	ld	ra,40(sp)
    8000559a:	7402                	ld	s0,32(sp)
    8000559c:	64e2                	ld	s1,24(sp)
    8000559e:	6942                	ld	s2,16(sp)
    800055a0:	6145                	addi	sp,sp,48
    800055a2:	8082                	ret
    return -1;
    800055a4:	557d                	li	a0,-1
    800055a6:	bfcd                	j	80005598 <argfd+0x4c>
    800055a8:	557d                	li	a0,-1
    800055aa:	b7fd                	j	80005598 <argfd+0x4c>

00000000800055ac <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800055ac:	1101                	addi	sp,sp,-32
    800055ae:	ec06                	sd	ra,24(sp)
    800055b0:	e822                	sd	s0,16(sp)
    800055b2:	e426                	sd	s1,8(sp)
    800055b4:	1000                	addi	s0,sp,32
    800055b6:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800055b8:	ffffc097          	auipc	ra,0xffffc
    800055bc:	428080e7          	jalr	1064(ra) # 800019e0 <myproc>
    800055c0:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800055c2:	11050793          	addi	a5,a0,272
    800055c6:	4501                	li	a0,0
    800055c8:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800055ca:	6398                	ld	a4,0(a5)
    800055cc:	cb19                	beqz	a4,800055e2 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800055ce:	2505                	addiw	a0,a0,1
    800055d0:	07a1                	addi	a5,a5,8
    800055d2:	fed51ce3          	bne	a0,a3,800055ca <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800055d6:	557d                	li	a0,-1
}
    800055d8:	60e2                	ld	ra,24(sp)
    800055da:	6442                	ld	s0,16(sp)
    800055dc:	64a2                	ld	s1,8(sp)
    800055de:	6105                	addi	sp,sp,32
    800055e0:	8082                	ret
      p->ofile[fd] = f;
    800055e2:	02250793          	addi	a5,a0,34
    800055e6:	078e                	slli	a5,a5,0x3
    800055e8:	963e                	add	a2,a2,a5
    800055ea:	e204                	sd	s1,0(a2)
      return fd;
    800055ec:	b7f5                	j	800055d8 <fdalloc+0x2c>

00000000800055ee <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800055ee:	715d                	addi	sp,sp,-80
    800055f0:	e486                	sd	ra,72(sp)
    800055f2:	e0a2                	sd	s0,64(sp)
    800055f4:	fc26                	sd	s1,56(sp)
    800055f6:	f84a                	sd	s2,48(sp)
    800055f8:	f44e                	sd	s3,40(sp)
    800055fa:	f052                	sd	s4,32(sp)
    800055fc:	ec56                	sd	s5,24(sp)
    800055fe:	e85a                	sd	s6,16(sp)
    80005600:	0880                	addi	s0,sp,80
    80005602:	8b2e                	mv	s6,a1
    80005604:	89b2                	mv	s3,a2
    80005606:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005608:	fb040593          	addi	a1,s0,-80
    8000560c:	fffff097          	auipc	ra,0xfffff
    80005610:	e3c080e7          	jalr	-452(ra) # 80004448 <nameiparent>
    80005614:	84aa                	mv	s1,a0
    80005616:	14050f63          	beqz	a0,80005774 <create+0x186>
    return 0;

  ilock(dp);
    8000561a:	ffffe097          	auipc	ra,0xffffe
    8000561e:	66a080e7          	jalr	1642(ra) # 80003c84 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005622:	4601                	li	a2,0
    80005624:	fb040593          	addi	a1,s0,-80
    80005628:	8526                	mv	a0,s1
    8000562a:	fffff097          	auipc	ra,0xfffff
    8000562e:	b3e080e7          	jalr	-1218(ra) # 80004168 <dirlookup>
    80005632:	8aaa                	mv	s5,a0
    80005634:	c931                	beqz	a0,80005688 <create+0x9a>
    iunlockput(dp);
    80005636:	8526                	mv	a0,s1
    80005638:	fffff097          	auipc	ra,0xfffff
    8000563c:	8ae080e7          	jalr	-1874(ra) # 80003ee6 <iunlockput>
    ilock(ip);
    80005640:	8556                	mv	a0,s5
    80005642:	ffffe097          	auipc	ra,0xffffe
    80005646:	642080e7          	jalr	1602(ra) # 80003c84 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000564a:	000b059b          	sext.w	a1,s6
    8000564e:	4789                	li	a5,2
    80005650:	02f59563          	bne	a1,a5,8000567a <create+0x8c>
    80005654:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdc2b4>
    80005658:	37f9                	addiw	a5,a5,-2
    8000565a:	17c2                	slli	a5,a5,0x30
    8000565c:	93c1                	srli	a5,a5,0x30
    8000565e:	4705                	li	a4,1
    80005660:	00f76d63          	bltu	a4,a5,8000567a <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005664:	8556                	mv	a0,s5
    80005666:	60a6                	ld	ra,72(sp)
    80005668:	6406                	ld	s0,64(sp)
    8000566a:	74e2                	ld	s1,56(sp)
    8000566c:	7942                	ld	s2,48(sp)
    8000566e:	79a2                	ld	s3,40(sp)
    80005670:	7a02                	ld	s4,32(sp)
    80005672:	6ae2                	ld	s5,24(sp)
    80005674:	6b42                	ld	s6,16(sp)
    80005676:	6161                	addi	sp,sp,80
    80005678:	8082                	ret
    iunlockput(ip);
    8000567a:	8556                	mv	a0,s5
    8000567c:	fffff097          	auipc	ra,0xfffff
    80005680:	86a080e7          	jalr	-1942(ra) # 80003ee6 <iunlockput>
    return 0;
    80005684:	4a81                	li	s5,0
    80005686:	bff9                	j	80005664 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005688:	85da                	mv	a1,s6
    8000568a:	4088                	lw	a0,0(s1)
    8000568c:	ffffe097          	auipc	ra,0xffffe
    80005690:	45c080e7          	jalr	1116(ra) # 80003ae8 <ialloc>
    80005694:	8a2a                	mv	s4,a0
    80005696:	c539                	beqz	a0,800056e4 <create+0xf6>
  ilock(ip);
    80005698:	ffffe097          	auipc	ra,0xffffe
    8000569c:	5ec080e7          	jalr	1516(ra) # 80003c84 <ilock>
  ip->major = major;
    800056a0:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800056a4:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800056a8:	4905                	li	s2,1
    800056aa:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800056ae:	8552                	mv	a0,s4
    800056b0:	ffffe097          	auipc	ra,0xffffe
    800056b4:	50a080e7          	jalr	1290(ra) # 80003bba <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800056b8:	000b059b          	sext.w	a1,s6
    800056bc:	03258b63          	beq	a1,s2,800056f2 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    800056c0:	004a2603          	lw	a2,4(s4)
    800056c4:	fb040593          	addi	a1,s0,-80
    800056c8:	8526                	mv	a0,s1
    800056ca:	fffff097          	auipc	ra,0xfffff
    800056ce:	cae080e7          	jalr	-850(ra) # 80004378 <dirlink>
    800056d2:	06054f63          	bltz	a0,80005750 <create+0x162>
  iunlockput(dp);
    800056d6:	8526                	mv	a0,s1
    800056d8:	fffff097          	auipc	ra,0xfffff
    800056dc:	80e080e7          	jalr	-2034(ra) # 80003ee6 <iunlockput>
  return ip;
    800056e0:	8ad2                	mv	s5,s4
    800056e2:	b749                	j	80005664 <create+0x76>
    iunlockput(dp);
    800056e4:	8526                	mv	a0,s1
    800056e6:	fffff097          	auipc	ra,0xfffff
    800056ea:	800080e7          	jalr	-2048(ra) # 80003ee6 <iunlockput>
    return 0;
    800056ee:	8ad2                	mv	s5,s4
    800056f0:	bf95                	j	80005664 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800056f2:	004a2603          	lw	a2,4(s4)
    800056f6:	00003597          	auipc	a1,0x3
    800056fa:	02a58593          	addi	a1,a1,42 # 80008720 <syscalls+0x2d0>
    800056fe:	8552                	mv	a0,s4
    80005700:	fffff097          	auipc	ra,0xfffff
    80005704:	c78080e7          	jalr	-904(ra) # 80004378 <dirlink>
    80005708:	04054463          	bltz	a0,80005750 <create+0x162>
    8000570c:	40d0                	lw	a2,4(s1)
    8000570e:	00003597          	auipc	a1,0x3
    80005712:	01a58593          	addi	a1,a1,26 # 80008728 <syscalls+0x2d8>
    80005716:	8552                	mv	a0,s4
    80005718:	fffff097          	auipc	ra,0xfffff
    8000571c:	c60080e7          	jalr	-928(ra) # 80004378 <dirlink>
    80005720:	02054863          	bltz	a0,80005750 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    80005724:	004a2603          	lw	a2,4(s4)
    80005728:	fb040593          	addi	a1,s0,-80
    8000572c:	8526                	mv	a0,s1
    8000572e:	fffff097          	auipc	ra,0xfffff
    80005732:	c4a080e7          	jalr	-950(ra) # 80004378 <dirlink>
    80005736:	00054d63          	bltz	a0,80005750 <create+0x162>
    dp->nlink++;  // for ".."
    8000573a:	04a4d783          	lhu	a5,74(s1)
    8000573e:	2785                	addiw	a5,a5,1
    80005740:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005744:	8526                	mv	a0,s1
    80005746:	ffffe097          	auipc	ra,0xffffe
    8000574a:	474080e7          	jalr	1140(ra) # 80003bba <iupdate>
    8000574e:	b761                	j	800056d6 <create+0xe8>
  ip->nlink = 0;
    80005750:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005754:	8552                	mv	a0,s4
    80005756:	ffffe097          	auipc	ra,0xffffe
    8000575a:	464080e7          	jalr	1124(ra) # 80003bba <iupdate>
  iunlockput(ip);
    8000575e:	8552                	mv	a0,s4
    80005760:	ffffe097          	auipc	ra,0xffffe
    80005764:	786080e7          	jalr	1926(ra) # 80003ee6 <iunlockput>
  iunlockput(dp);
    80005768:	8526                	mv	a0,s1
    8000576a:	ffffe097          	auipc	ra,0xffffe
    8000576e:	77c080e7          	jalr	1916(ra) # 80003ee6 <iunlockput>
  return 0;
    80005772:	bdcd                	j	80005664 <create+0x76>
    return 0;
    80005774:	8aaa                	mv	s5,a0
    80005776:	b5fd                	j	80005664 <create+0x76>

0000000080005778 <sys_dup>:
{
    80005778:	7179                	addi	sp,sp,-48
    8000577a:	f406                	sd	ra,40(sp)
    8000577c:	f022                	sd	s0,32(sp)
    8000577e:	ec26                	sd	s1,24(sp)
    80005780:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005782:	fd840613          	addi	a2,s0,-40
    80005786:	4581                	li	a1,0
    80005788:	4501                	li	a0,0
    8000578a:	00000097          	auipc	ra,0x0
    8000578e:	dc2080e7          	jalr	-574(ra) # 8000554c <argfd>
    return -1;
    80005792:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005794:	02054363          	bltz	a0,800057ba <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005798:	fd843503          	ld	a0,-40(s0)
    8000579c:	00000097          	auipc	ra,0x0
    800057a0:	e10080e7          	jalr	-496(ra) # 800055ac <fdalloc>
    800057a4:	84aa                	mv	s1,a0
    return -1;
    800057a6:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800057a8:	00054963          	bltz	a0,800057ba <sys_dup+0x42>
  filedup(f);
    800057ac:	fd843503          	ld	a0,-40(s0)
    800057b0:	fffff097          	auipc	ra,0xfffff
    800057b4:	310080e7          	jalr	784(ra) # 80004ac0 <filedup>
  return fd;
    800057b8:	87a6                	mv	a5,s1
}
    800057ba:	853e                	mv	a0,a5
    800057bc:	70a2                	ld	ra,40(sp)
    800057be:	7402                	ld	s0,32(sp)
    800057c0:	64e2                	ld	s1,24(sp)
    800057c2:	6145                	addi	sp,sp,48
    800057c4:	8082                	ret

00000000800057c6 <sys_read>:
{
    800057c6:	7179                	addi	sp,sp,-48
    800057c8:	f406                	sd	ra,40(sp)
    800057ca:	f022                	sd	s0,32(sp)
    800057cc:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800057ce:	fd840593          	addi	a1,s0,-40
    800057d2:	4505                	li	a0,1
    800057d4:	ffffd097          	auipc	ra,0xffffd
    800057d8:	7c2080e7          	jalr	1986(ra) # 80002f96 <argaddr>
  argint(2, &n);
    800057dc:	fe440593          	addi	a1,s0,-28
    800057e0:	4509                	li	a0,2
    800057e2:	ffffd097          	auipc	ra,0xffffd
    800057e6:	794080e7          	jalr	1940(ra) # 80002f76 <argint>
  if(argfd(0, 0, &f) < 0)
    800057ea:	fe840613          	addi	a2,s0,-24
    800057ee:	4581                	li	a1,0
    800057f0:	4501                	li	a0,0
    800057f2:	00000097          	auipc	ra,0x0
    800057f6:	d5a080e7          	jalr	-678(ra) # 8000554c <argfd>
    800057fa:	87aa                	mv	a5,a0
    return -1;
    800057fc:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800057fe:	0007cc63          	bltz	a5,80005816 <sys_read+0x50>
  return fileread(f, p, n);
    80005802:	fe442603          	lw	a2,-28(s0)
    80005806:	fd843583          	ld	a1,-40(s0)
    8000580a:	fe843503          	ld	a0,-24(s0)
    8000580e:	fffff097          	auipc	ra,0xfffff
    80005812:	43e080e7          	jalr	1086(ra) # 80004c4c <fileread>
}
    80005816:	70a2                	ld	ra,40(sp)
    80005818:	7402                	ld	s0,32(sp)
    8000581a:	6145                	addi	sp,sp,48
    8000581c:	8082                	ret

000000008000581e <sys_write>:
{
    8000581e:	7179                	addi	sp,sp,-48
    80005820:	f406                	sd	ra,40(sp)
    80005822:	f022                	sd	s0,32(sp)
    80005824:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005826:	fd840593          	addi	a1,s0,-40
    8000582a:	4505                	li	a0,1
    8000582c:	ffffd097          	auipc	ra,0xffffd
    80005830:	76a080e7          	jalr	1898(ra) # 80002f96 <argaddr>
  argint(2, &n);
    80005834:	fe440593          	addi	a1,s0,-28
    80005838:	4509                	li	a0,2
    8000583a:	ffffd097          	auipc	ra,0xffffd
    8000583e:	73c080e7          	jalr	1852(ra) # 80002f76 <argint>
  if(argfd(0, 0, &f) < 0)
    80005842:	fe840613          	addi	a2,s0,-24
    80005846:	4581                	li	a1,0
    80005848:	4501                	li	a0,0
    8000584a:	00000097          	auipc	ra,0x0
    8000584e:	d02080e7          	jalr	-766(ra) # 8000554c <argfd>
    80005852:	87aa                	mv	a5,a0
    return -1;
    80005854:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005856:	0007cc63          	bltz	a5,8000586e <sys_write+0x50>
  return filewrite(f, p, n);
    8000585a:	fe442603          	lw	a2,-28(s0)
    8000585e:	fd843583          	ld	a1,-40(s0)
    80005862:	fe843503          	ld	a0,-24(s0)
    80005866:	fffff097          	auipc	ra,0xfffff
    8000586a:	4a8080e7          	jalr	1192(ra) # 80004d0e <filewrite>
}
    8000586e:	70a2                	ld	ra,40(sp)
    80005870:	7402                	ld	s0,32(sp)
    80005872:	6145                	addi	sp,sp,48
    80005874:	8082                	ret

0000000080005876 <sys_close>:
{
    80005876:	1101                	addi	sp,sp,-32
    80005878:	ec06                	sd	ra,24(sp)
    8000587a:	e822                	sd	s0,16(sp)
    8000587c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000587e:	fe040613          	addi	a2,s0,-32
    80005882:	fec40593          	addi	a1,s0,-20
    80005886:	4501                	li	a0,0
    80005888:	00000097          	auipc	ra,0x0
    8000588c:	cc4080e7          	jalr	-828(ra) # 8000554c <argfd>
    return -1;
    80005890:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005892:	02054563          	bltz	a0,800058bc <sys_close+0x46>
  myproc()->ofile[fd] = 0;
    80005896:	ffffc097          	auipc	ra,0xffffc
    8000589a:	14a080e7          	jalr	330(ra) # 800019e0 <myproc>
    8000589e:	fec42783          	lw	a5,-20(s0)
    800058a2:	02278793          	addi	a5,a5,34
    800058a6:	078e                	slli	a5,a5,0x3
    800058a8:	97aa                	add	a5,a5,a0
    800058aa:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800058ae:	fe043503          	ld	a0,-32(s0)
    800058b2:	fffff097          	auipc	ra,0xfffff
    800058b6:	260080e7          	jalr	608(ra) # 80004b12 <fileclose>
  return 0;
    800058ba:	4781                	li	a5,0
}
    800058bc:	853e                	mv	a0,a5
    800058be:	60e2                	ld	ra,24(sp)
    800058c0:	6442                	ld	s0,16(sp)
    800058c2:	6105                	addi	sp,sp,32
    800058c4:	8082                	ret

00000000800058c6 <sys_fstat>:
{
    800058c6:	1101                	addi	sp,sp,-32
    800058c8:	ec06                	sd	ra,24(sp)
    800058ca:	e822                	sd	s0,16(sp)
    800058cc:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800058ce:	fe040593          	addi	a1,s0,-32
    800058d2:	4505                	li	a0,1
    800058d4:	ffffd097          	auipc	ra,0xffffd
    800058d8:	6c2080e7          	jalr	1730(ra) # 80002f96 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800058dc:	fe840613          	addi	a2,s0,-24
    800058e0:	4581                	li	a1,0
    800058e2:	4501                	li	a0,0
    800058e4:	00000097          	auipc	ra,0x0
    800058e8:	c68080e7          	jalr	-920(ra) # 8000554c <argfd>
    800058ec:	87aa                	mv	a5,a0
    return -1;
    800058ee:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800058f0:	0007ca63          	bltz	a5,80005904 <sys_fstat+0x3e>
  return filestat(f, st);
    800058f4:	fe043583          	ld	a1,-32(s0)
    800058f8:	fe843503          	ld	a0,-24(s0)
    800058fc:	fffff097          	auipc	ra,0xfffff
    80005900:	2de080e7          	jalr	734(ra) # 80004bda <filestat>
}
    80005904:	60e2                	ld	ra,24(sp)
    80005906:	6442                	ld	s0,16(sp)
    80005908:	6105                	addi	sp,sp,32
    8000590a:	8082                	ret

000000008000590c <sys_link>:
{
    8000590c:	7169                	addi	sp,sp,-304
    8000590e:	f606                	sd	ra,296(sp)
    80005910:	f222                	sd	s0,288(sp)
    80005912:	ee26                	sd	s1,280(sp)
    80005914:	ea4a                	sd	s2,272(sp)
    80005916:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005918:	08000613          	li	a2,128
    8000591c:	ed040593          	addi	a1,s0,-304
    80005920:	4501                	li	a0,0
    80005922:	ffffd097          	auipc	ra,0xffffd
    80005926:	694080e7          	jalr	1684(ra) # 80002fb6 <argstr>
    return -1;
    8000592a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000592c:	10054e63          	bltz	a0,80005a48 <sys_link+0x13c>
    80005930:	08000613          	li	a2,128
    80005934:	f5040593          	addi	a1,s0,-176
    80005938:	4505                	li	a0,1
    8000593a:	ffffd097          	auipc	ra,0xffffd
    8000593e:	67c080e7          	jalr	1660(ra) # 80002fb6 <argstr>
    return -1;
    80005942:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005944:	10054263          	bltz	a0,80005a48 <sys_link+0x13c>
  begin_op();
    80005948:	fffff097          	auipc	ra,0xfffff
    8000594c:	cfe080e7          	jalr	-770(ra) # 80004646 <begin_op>
  if((ip = namei(old)) == 0){
    80005950:	ed040513          	addi	a0,s0,-304
    80005954:	fffff097          	auipc	ra,0xfffff
    80005958:	ad6080e7          	jalr	-1322(ra) # 8000442a <namei>
    8000595c:	84aa                	mv	s1,a0
    8000595e:	c551                	beqz	a0,800059ea <sys_link+0xde>
  ilock(ip);
    80005960:	ffffe097          	auipc	ra,0xffffe
    80005964:	324080e7          	jalr	804(ra) # 80003c84 <ilock>
  if(ip->type == T_DIR){
    80005968:	04449703          	lh	a4,68(s1)
    8000596c:	4785                	li	a5,1
    8000596e:	08f70463          	beq	a4,a5,800059f6 <sys_link+0xea>
  ip->nlink++;
    80005972:	04a4d783          	lhu	a5,74(s1)
    80005976:	2785                	addiw	a5,a5,1
    80005978:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000597c:	8526                	mv	a0,s1
    8000597e:	ffffe097          	auipc	ra,0xffffe
    80005982:	23c080e7          	jalr	572(ra) # 80003bba <iupdate>
  iunlock(ip);
    80005986:	8526                	mv	a0,s1
    80005988:	ffffe097          	auipc	ra,0xffffe
    8000598c:	3be080e7          	jalr	958(ra) # 80003d46 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005990:	fd040593          	addi	a1,s0,-48
    80005994:	f5040513          	addi	a0,s0,-176
    80005998:	fffff097          	auipc	ra,0xfffff
    8000599c:	ab0080e7          	jalr	-1360(ra) # 80004448 <nameiparent>
    800059a0:	892a                	mv	s2,a0
    800059a2:	c935                	beqz	a0,80005a16 <sys_link+0x10a>
  ilock(dp);
    800059a4:	ffffe097          	auipc	ra,0xffffe
    800059a8:	2e0080e7          	jalr	736(ra) # 80003c84 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800059ac:	00092703          	lw	a4,0(s2)
    800059b0:	409c                	lw	a5,0(s1)
    800059b2:	04f71d63          	bne	a4,a5,80005a0c <sys_link+0x100>
    800059b6:	40d0                	lw	a2,4(s1)
    800059b8:	fd040593          	addi	a1,s0,-48
    800059bc:	854a                	mv	a0,s2
    800059be:	fffff097          	auipc	ra,0xfffff
    800059c2:	9ba080e7          	jalr	-1606(ra) # 80004378 <dirlink>
    800059c6:	04054363          	bltz	a0,80005a0c <sys_link+0x100>
  iunlockput(dp);
    800059ca:	854a                	mv	a0,s2
    800059cc:	ffffe097          	auipc	ra,0xffffe
    800059d0:	51a080e7          	jalr	1306(ra) # 80003ee6 <iunlockput>
  iput(ip);
    800059d4:	8526                	mv	a0,s1
    800059d6:	ffffe097          	auipc	ra,0xffffe
    800059da:	468080e7          	jalr	1128(ra) # 80003e3e <iput>
  end_op();
    800059de:	fffff097          	auipc	ra,0xfffff
    800059e2:	ce8080e7          	jalr	-792(ra) # 800046c6 <end_op>
  return 0;
    800059e6:	4781                	li	a5,0
    800059e8:	a085                	j	80005a48 <sys_link+0x13c>
    end_op();
    800059ea:	fffff097          	auipc	ra,0xfffff
    800059ee:	cdc080e7          	jalr	-804(ra) # 800046c6 <end_op>
    return -1;
    800059f2:	57fd                	li	a5,-1
    800059f4:	a891                	j	80005a48 <sys_link+0x13c>
    iunlockput(ip);
    800059f6:	8526                	mv	a0,s1
    800059f8:	ffffe097          	auipc	ra,0xffffe
    800059fc:	4ee080e7          	jalr	1262(ra) # 80003ee6 <iunlockput>
    end_op();
    80005a00:	fffff097          	auipc	ra,0xfffff
    80005a04:	cc6080e7          	jalr	-826(ra) # 800046c6 <end_op>
    return -1;
    80005a08:	57fd                	li	a5,-1
    80005a0a:	a83d                	j	80005a48 <sys_link+0x13c>
    iunlockput(dp);
    80005a0c:	854a                	mv	a0,s2
    80005a0e:	ffffe097          	auipc	ra,0xffffe
    80005a12:	4d8080e7          	jalr	1240(ra) # 80003ee6 <iunlockput>
  ilock(ip);
    80005a16:	8526                	mv	a0,s1
    80005a18:	ffffe097          	auipc	ra,0xffffe
    80005a1c:	26c080e7          	jalr	620(ra) # 80003c84 <ilock>
  ip->nlink--;
    80005a20:	04a4d783          	lhu	a5,74(s1)
    80005a24:	37fd                	addiw	a5,a5,-1
    80005a26:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005a2a:	8526                	mv	a0,s1
    80005a2c:	ffffe097          	auipc	ra,0xffffe
    80005a30:	18e080e7          	jalr	398(ra) # 80003bba <iupdate>
  iunlockput(ip);
    80005a34:	8526                	mv	a0,s1
    80005a36:	ffffe097          	auipc	ra,0xffffe
    80005a3a:	4b0080e7          	jalr	1200(ra) # 80003ee6 <iunlockput>
  end_op();
    80005a3e:	fffff097          	auipc	ra,0xfffff
    80005a42:	c88080e7          	jalr	-888(ra) # 800046c6 <end_op>
  return -1;
    80005a46:	57fd                	li	a5,-1
}
    80005a48:	853e                	mv	a0,a5
    80005a4a:	70b2                	ld	ra,296(sp)
    80005a4c:	7412                	ld	s0,288(sp)
    80005a4e:	64f2                	ld	s1,280(sp)
    80005a50:	6952                	ld	s2,272(sp)
    80005a52:	6155                	addi	sp,sp,304
    80005a54:	8082                	ret

0000000080005a56 <sys_unlink>:
{
    80005a56:	7151                	addi	sp,sp,-240
    80005a58:	f586                	sd	ra,232(sp)
    80005a5a:	f1a2                	sd	s0,224(sp)
    80005a5c:	eda6                	sd	s1,216(sp)
    80005a5e:	e9ca                	sd	s2,208(sp)
    80005a60:	e5ce                	sd	s3,200(sp)
    80005a62:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005a64:	08000613          	li	a2,128
    80005a68:	f3040593          	addi	a1,s0,-208
    80005a6c:	4501                	li	a0,0
    80005a6e:	ffffd097          	auipc	ra,0xffffd
    80005a72:	548080e7          	jalr	1352(ra) # 80002fb6 <argstr>
    80005a76:	18054163          	bltz	a0,80005bf8 <sys_unlink+0x1a2>
  begin_op();
    80005a7a:	fffff097          	auipc	ra,0xfffff
    80005a7e:	bcc080e7          	jalr	-1076(ra) # 80004646 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005a82:	fb040593          	addi	a1,s0,-80
    80005a86:	f3040513          	addi	a0,s0,-208
    80005a8a:	fffff097          	auipc	ra,0xfffff
    80005a8e:	9be080e7          	jalr	-1602(ra) # 80004448 <nameiparent>
    80005a92:	84aa                	mv	s1,a0
    80005a94:	c979                	beqz	a0,80005b6a <sys_unlink+0x114>
  ilock(dp);
    80005a96:	ffffe097          	auipc	ra,0xffffe
    80005a9a:	1ee080e7          	jalr	494(ra) # 80003c84 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005a9e:	00003597          	auipc	a1,0x3
    80005aa2:	c8258593          	addi	a1,a1,-894 # 80008720 <syscalls+0x2d0>
    80005aa6:	fb040513          	addi	a0,s0,-80
    80005aaa:	ffffe097          	auipc	ra,0xffffe
    80005aae:	6a4080e7          	jalr	1700(ra) # 8000414e <namecmp>
    80005ab2:	14050a63          	beqz	a0,80005c06 <sys_unlink+0x1b0>
    80005ab6:	00003597          	auipc	a1,0x3
    80005aba:	c7258593          	addi	a1,a1,-910 # 80008728 <syscalls+0x2d8>
    80005abe:	fb040513          	addi	a0,s0,-80
    80005ac2:	ffffe097          	auipc	ra,0xffffe
    80005ac6:	68c080e7          	jalr	1676(ra) # 8000414e <namecmp>
    80005aca:	12050e63          	beqz	a0,80005c06 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005ace:	f2c40613          	addi	a2,s0,-212
    80005ad2:	fb040593          	addi	a1,s0,-80
    80005ad6:	8526                	mv	a0,s1
    80005ad8:	ffffe097          	auipc	ra,0xffffe
    80005adc:	690080e7          	jalr	1680(ra) # 80004168 <dirlookup>
    80005ae0:	892a                	mv	s2,a0
    80005ae2:	12050263          	beqz	a0,80005c06 <sys_unlink+0x1b0>
  ilock(ip);
    80005ae6:	ffffe097          	auipc	ra,0xffffe
    80005aea:	19e080e7          	jalr	414(ra) # 80003c84 <ilock>
  if(ip->nlink < 1)
    80005aee:	04a91783          	lh	a5,74(s2)
    80005af2:	08f05263          	blez	a5,80005b76 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005af6:	04491703          	lh	a4,68(s2)
    80005afa:	4785                	li	a5,1
    80005afc:	08f70563          	beq	a4,a5,80005b86 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005b00:	4641                	li	a2,16
    80005b02:	4581                	li	a1,0
    80005b04:	fc040513          	addi	a0,s0,-64
    80005b08:	ffffb097          	auipc	ra,0xffffb
    80005b0c:	1ca080e7          	jalr	458(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b10:	4741                	li	a4,16
    80005b12:	f2c42683          	lw	a3,-212(s0)
    80005b16:	fc040613          	addi	a2,s0,-64
    80005b1a:	4581                	li	a1,0
    80005b1c:	8526                	mv	a0,s1
    80005b1e:	ffffe097          	auipc	ra,0xffffe
    80005b22:	512080e7          	jalr	1298(ra) # 80004030 <writei>
    80005b26:	47c1                	li	a5,16
    80005b28:	0af51563          	bne	a0,a5,80005bd2 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005b2c:	04491703          	lh	a4,68(s2)
    80005b30:	4785                	li	a5,1
    80005b32:	0af70863          	beq	a4,a5,80005be2 <sys_unlink+0x18c>
  iunlockput(dp);
    80005b36:	8526                	mv	a0,s1
    80005b38:	ffffe097          	auipc	ra,0xffffe
    80005b3c:	3ae080e7          	jalr	942(ra) # 80003ee6 <iunlockput>
  ip->nlink--;
    80005b40:	04a95783          	lhu	a5,74(s2)
    80005b44:	37fd                	addiw	a5,a5,-1
    80005b46:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005b4a:	854a                	mv	a0,s2
    80005b4c:	ffffe097          	auipc	ra,0xffffe
    80005b50:	06e080e7          	jalr	110(ra) # 80003bba <iupdate>
  iunlockput(ip);
    80005b54:	854a                	mv	a0,s2
    80005b56:	ffffe097          	auipc	ra,0xffffe
    80005b5a:	390080e7          	jalr	912(ra) # 80003ee6 <iunlockput>
  end_op();
    80005b5e:	fffff097          	auipc	ra,0xfffff
    80005b62:	b68080e7          	jalr	-1176(ra) # 800046c6 <end_op>
  return 0;
    80005b66:	4501                	li	a0,0
    80005b68:	a84d                	j	80005c1a <sys_unlink+0x1c4>
    end_op();
    80005b6a:	fffff097          	auipc	ra,0xfffff
    80005b6e:	b5c080e7          	jalr	-1188(ra) # 800046c6 <end_op>
    return -1;
    80005b72:	557d                	li	a0,-1
    80005b74:	a05d                	j	80005c1a <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005b76:	00003517          	auipc	a0,0x3
    80005b7a:	bba50513          	addi	a0,a0,-1094 # 80008730 <syscalls+0x2e0>
    80005b7e:	ffffb097          	auipc	ra,0xffffb
    80005b82:	9c0080e7          	jalr	-1600(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b86:	04c92703          	lw	a4,76(s2)
    80005b8a:	02000793          	li	a5,32
    80005b8e:	f6e7f9e3          	bgeu	a5,a4,80005b00 <sys_unlink+0xaa>
    80005b92:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b96:	4741                	li	a4,16
    80005b98:	86ce                	mv	a3,s3
    80005b9a:	f1840613          	addi	a2,s0,-232
    80005b9e:	4581                	li	a1,0
    80005ba0:	854a                	mv	a0,s2
    80005ba2:	ffffe097          	auipc	ra,0xffffe
    80005ba6:	396080e7          	jalr	918(ra) # 80003f38 <readi>
    80005baa:	47c1                	li	a5,16
    80005bac:	00f51b63          	bne	a0,a5,80005bc2 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005bb0:	f1845783          	lhu	a5,-232(s0)
    80005bb4:	e7a1                	bnez	a5,80005bfc <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005bb6:	29c1                	addiw	s3,s3,16
    80005bb8:	04c92783          	lw	a5,76(s2)
    80005bbc:	fcf9ede3          	bltu	s3,a5,80005b96 <sys_unlink+0x140>
    80005bc0:	b781                	j	80005b00 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005bc2:	00003517          	auipc	a0,0x3
    80005bc6:	b8650513          	addi	a0,a0,-1146 # 80008748 <syscalls+0x2f8>
    80005bca:	ffffb097          	auipc	ra,0xffffb
    80005bce:	974080e7          	jalr	-1676(ra) # 8000053e <panic>
    panic("unlink: writei");
    80005bd2:	00003517          	auipc	a0,0x3
    80005bd6:	b8e50513          	addi	a0,a0,-1138 # 80008760 <syscalls+0x310>
    80005bda:	ffffb097          	auipc	ra,0xffffb
    80005bde:	964080e7          	jalr	-1692(ra) # 8000053e <panic>
    dp->nlink--;
    80005be2:	04a4d783          	lhu	a5,74(s1)
    80005be6:	37fd                	addiw	a5,a5,-1
    80005be8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005bec:	8526                	mv	a0,s1
    80005bee:	ffffe097          	auipc	ra,0xffffe
    80005bf2:	fcc080e7          	jalr	-52(ra) # 80003bba <iupdate>
    80005bf6:	b781                	j	80005b36 <sys_unlink+0xe0>
    return -1;
    80005bf8:	557d                	li	a0,-1
    80005bfa:	a005                	j	80005c1a <sys_unlink+0x1c4>
    iunlockput(ip);
    80005bfc:	854a                	mv	a0,s2
    80005bfe:	ffffe097          	auipc	ra,0xffffe
    80005c02:	2e8080e7          	jalr	744(ra) # 80003ee6 <iunlockput>
  iunlockput(dp);
    80005c06:	8526                	mv	a0,s1
    80005c08:	ffffe097          	auipc	ra,0xffffe
    80005c0c:	2de080e7          	jalr	734(ra) # 80003ee6 <iunlockput>
  end_op();
    80005c10:	fffff097          	auipc	ra,0xfffff
    80005c14:	ab6080e7          	jalr	-1354(ra) # 800046c6 <end_op>
  return -1;
    80005c18:	557d                	li	a0,-1
}
    80005c1a:	70ae                	ld	ra,232(sp)
    80005c1c:	740e                	ld	s0,224(sp)
    80005c1e:	64ee                	ld	s1,216(sp)
    80005c20:	694e                	ld	s2,208(sp)
    80005c22:	69ae                	ld	s3,200(sp)
    80005c24:	616d                	addi	sp,sp,240
    80005c26:	8082                	ret

0000000080005c28 <sys_open>:

uint64
sys_open(void)
{
    80005c28:	7131                	addi	sp,sp,-192
    80005c2a:	fd06                	sd	ra,184(sp)
    80005c2c:	f922                	sd	s0,176(sp)
    80005c2e:	f526                	sd	s1,168(sp)
    80005c30:	f14a                	sd	s2,160(sp)
    80005c32:	ed4e                	sd	s3,152(sp)
    80005c34:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005c36:	f4c40593          	addi	a1,s0,-180
    80005c3a:	4505                	li	a0,1
    80005c3c:	ffffd097          	auipc	ra,0xffffd
    80005c40:	33a080e7          	jalr	826(ra) # 80002f76 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005c44:	08000613          	li	a2,128
    80005c48:	f5040593          	addi	a1,s0,-176
    80005c4c:	4501                	li	a0,0
    80005c4e:	ffffd097          	auipc	ra,0xffffd
    80005c52:	368080e7          	jalr	872(ra) # 80002fb6 <argstr>
    80005c56:	87aa                	mv	a5,a0
    return -1;
    80005c58:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005c5a:	0a07c963          	bltz	a5,80005d0c <sys_open+0xe4>

  begin_op();
    80005c5e:	fffff097          	auipc	ra,0xfffff
    80005c62:	9e8080e7          	jalr	-1560(ra) # 80004646 <begin_op>

  if(omode & O_CREATE){
    80005c66:	f4c42783          	lw	a5,-180(s0)
    80005c6a:	2007f793          	andi	a5,a5,512
    80005c6e:	cfc5                	beqz	a5,80005d26 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005c70:	4681                	li	a3,0
    80005c72:	4601                	li	a2,0
    80005c74:	4589                	li	a1,2
    80005c76:	f5040513          	addi	a0,s0,-176
    80005c7a:	00000097          	auipc	ra,0x0
    80005c7e:	974080e7          	jalr	-1676(ra) # 800055ee <create>
    80005c82:	84aa                	mv	s1,a0
    if(ip == 0){
    80005c84:	c959                	beqz	a0,80005d1a <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005c86:	04449703          	lh	a4,68(s1)
    80005c8a:	478d                	li	a5,3
    80005c8c:	00f71763          	bne	a4,a5,80005c9a <sys_open+0x72>
    80005c90:	0464d703          	lhu	a4,70(s1)
    80005c94:	47a5                	li	a5,9
    80005c96:	0ce7ed63          	bltu	a5,a4,80005d70 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005c9a:	fffff097          	auipc	ra,0xfffff
    80005c9e:	dbc080e7          	jalr	-580(ra) # 80004a56 <filealloc>
    80005ca2:	89aa                	mv	s3,a0
    80005ca4:	10050363          	beqz	a0,80005daa <sys_open+0x182>
    80005ca8:	00000097          	auipc	ra,0x0
    80005cac:	904080e7          	jalr	-1788(ra) # 800055ac <fdalloc>
    80005cb0:	892a                	mv	s2,a0
    80005cb2:	0e054763          	bltz	a0,80005da0 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005cb6:	04449703          	lh	a4,68(s1)
    80005cba:	478d                	li	a5,3
    80005cbc:	0cf70563          	beq	a4,a5,80005d86 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005cc0:	4789                	li	a5,2
    80005cc2:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005cc6:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005cca:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005cce:	f4c42783          	lw	a5,-180(s0)
    80005cd2:	0017c713          	xori	a4,a5,1
    80005cd6:	8b05                	andi	a4,a4,1
    80005cd8:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005cdc:	0037f713          	andi	a4,a5,3
    80005ce0:	00e03733          	snez	a4,a4
    80005ce4:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005ce8:	4007f793          	andi	a5,a5,1024
    80005cec:	c791                	beqz	a5,80005cf8 <sys_open+0xd0>
    80005cee:	04449703          	lh	a4,68(s1)
    80005cf2:	4789                	li	a5,2
    80005cf4:	0af70063          	beq	a4,a5,80005d94 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005cf8:	8526                	mv	a0,s1
    80005cfa:	ffffe097          	auipc	ra,0xffffe
    80005cfe:	04c080e7          	jalr	76(ra) # 80003d46 <iunlock>
  end_op();
    80005d02:	fffff097          	auipc	ra,0xfffff
    80005d06:	9c4080e7          	jalr	-1596(ra) # 800046c6 <end_op>

  return fd;
    80005d0a:	854a                	mv	a0,s2
}
    80005d0c:	70ea                	ld	ra,184(sp)
    80005d0e:	744a                	ld	s0,176(sp)
    80005d10:	74aa                	ld	s1,168(sp)
    80005d12:	790a                	ld	s2,160(sp)
    80005d14:	69ea                	ld	s3,152(sp)
    80005d16:	6129                	addi	sp,sp,192
    80005d18:	8082                	ret
      end_op();
    80005d1a:	fffff097          	auipc	ra,0xfffff
    80005d1e:	9ac080e7          	jalr	-1620(ra) # 800046c6 <end_op>
      return -1;
    80005d22:	557d                	li	a0,-1
    80005d24:	b7e5                	j	80005d0c <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005d26:	f5040513          	addi	a0,s0,-176
    80005d2a:	ffffe097          	auipc	ra,0xffffe
    80005d2e:	700080e7          	jalr	1792(ra) # 8000442a <namei>
    80005d32:	84aa                	mv	s1,a0
    80005d34:	c905                	beqz	a0,80005d64 <sys_open+0x13c>
    ilock(ip);
    80005d36:	ffffe097          	auipc	ra,0xffffe
    80005d3a:	f4e080e7          	jalr	-178(ra) # 80003c84 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005d3e:	04449703          	lh	a4,68(s1)
    80005d42:	4785                	li	a5,1
    80005d44:	f4f711e3          	bne	a4,a5,80005c86 <sys_open+0x5e>
    80005d48:	f4c42783          	lw	a5,-180(s0)
    80005d4c:	d7b9                	beqz	a5,80005c9a <sys_open+0x72>
      iunlockput(ip);
    80005d4e:	8526                	mv	a0,s1
    80005d50:	ffffe097          	auipc	ra,0xffffe
    80005d54:	196080e7          	jalr	406(ra) # 80003ee6 <iunlockput>
      end_op();
    80005d58:	fffff097          	auipc	ra,0xfffff
    80005d5c:	96e080e7          	jalr	-1682(ra) # 800046c6 <end_op>
      return -1;
    80005d60:	557d                	li	a0,-1
    80005d62:	b76d                	j	80005d0c <sys_open+0xe4>
      end_op();
    80005d64:	fffff097          	auipc	ra,0xfffff
    80005d68:	962080e7          	jalr	-1694(ra) # 800046c6 <end_op>
      return -1;
    80005d6c:	557d                	li	a0,-1
    80005d6e:	bf79                	j	80005d0c <sys_open+0xe4>
    iunlockput(ip);
    80005d70:	8526                	mv	a0,s1
    80005d72:	ffffe097          	auipc	ra,0xffffe
    80005d76:	174080e7          	jalr	372(ra) # 80003ee6 <iunlockput>
    end_op();
    80005d7a:	fffff097          	auipc	ra,0xfffff
    80005d7e:	94c080e7          	jalr	-1716(ra) # 800046c6 <end_op>
    return -1;
    80005d82:	557d                	li	a0,-1
    80005d84:	b761                	j	80005d0c <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005d86:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005d8a:	04649783          	lh	a5,70(s1)
    80005d8e:	02f99223          	sh	a5,36(s3)
    80005d92:	bf25                	j	80005cca <sys_open+0xa2>
    itrunc(ip);
    80005d94:	8526                	mv	a0,s1
    80005d96:	ffffe097          	auipc	ra,0xffffe
    80005d9a:	ffc080e7          	jalr	-4(ra) # 80003d92 <itrunc>
    80005d9e:	bfa9                	j	80005cf8 <sys_open+0xd0>
      fileclose(f);
    80005da0:	854e                	mv	a0,s3
    80005da2:	fffff097          	auipc	ra,0xfffff
    80005da6:	d70080e7          	jalr	-656(ra) # 80004b12 <fileclose>
    iunlockput(ip);
    80005daa:	8526                	mv	a0,s1
    80005dac:	ffffe097          	auipc	ra,0xffffe
    80005db0:	13a080e7          	jalr	314(ra) # 80003ee6 <iunlockput>
    end_op();
    80005db4:	fffff097          	auipc	ra,0xfffff
    80005db8:	912080e7          	jalr	-1774(ra) # 800046c6 <end_op>
    return -1;
    80005dbc:	557d                	li	a0,-1
    80005dbe:	b7b9                	j	80005d0c <sys_open+0xe4>

0000000080005dc0 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005dc0:	7175                	addi	sp,sp,-144
    80005dc2:	e506                	sd	ra,136(sp)
    80005dc4:	e122                	sd	s0,128(sp)
    80005dc6:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005dc8:	fffff097          	auipc	ra,0xfffff
    80005dcc:	87e080e7          	jalr	-1922(ra) # 80004646 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005dd0:	08000613          	li	a2,128
    80005dd4:	f7040593          	addi	a1,s0,-144
    80005dd8:	4501                	li	a0,0
    80005dda:	ffffd097          	auipc	ra,0xffffd
    80005dde:	1dc080e7          	jalr	476(ra) # 80002fb6 <argstr>
    80005de2:	02054963          	bltz	a0,80005e14 <sys_mkdir+0x54>
    80005de6:	4681                	li	a3,0
    80005de8:	4601                	li	a2,0
    80005dea:	4585                	li	a1,1
    80005dec:	f7040513          	addi	a0,s0,-144
    80005df0:	fffff097          	auipc	ra,0xfffff
    80005df4:	7fe080e7          	jalr	2046(ra) # 800055ee <create>
    80005df8:	cd11                	beqz	a0,80005e14 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005dfa:	ffffe097          	auipc	ra,0xffffe
    80005dfe:	0ec080e7          	jalr	236(ra) # 80003ee6 <iunlockput>
  end_op();
    80005e02:	fffff097          	auipc	ra,0xfffff
    80005e06:	8c4080e7          	jalr	-1852(ra) # 800046c6 <end_op>
  return 0;
    80005e0a:	4501                	li	a0,0
}
    80005e0c:	60aa                	ld	ra,136(sp)
    80005e0e:	640a                	ld	s0,128(sp)
    80005e10:	6149                	addi	sp,sp,144
    80005e12:	8082                	ret
    end_op();
    80005e14:	fffff097          	auipc	ra,0xfffff
    80005e18:	8b2080e7          	jalr	-1870(ra) # 800046c6 <end_op>
    return -1;
    80005e1c:	557d                	li	a0,-1
    80005e1e:	b7fd                	j	80005e0c <sys_mkdir+0x4c>

0000000080005e20 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005e20:	7135                	addi	sp,sp,-160
    80005e22:	ed06                	sd	ra,152(sp)
    80005e24:	e922                	sd	s0,144(sp)
    80005e26:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005e28:	fffff097          	auipc	ra,0xfffff
    80005e2c:	81e080e7          	jalr	-2018(ra) # 80004646 <begin_op>
  argint(1, &major);
    80005e30:	f6c40593          	addi	a1,s0,-148
    80005e34:	4505                	li	a0,1
    80005e36:	ffffd097          	auipc	ra,0xffffd
    80005e3a:	140080e7          	jalr	320(ra) # 80002f76 <argint>
  argint(2, &minor);
    80005e3e:	f6840593          	addi	a1,s0,-152
    80005e42:	4509                	li	a0,2
    80005e44:	ffffd097          	auipc	ra,0xffffd
    80005e48:	132080e7          	jalr	306(ra) # 80002f76 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e4c:	08000613          	li	a2,128
    80005e50:	f7040593          	addi	a1,s0,-144
    80005e54:	4501                	li	a0,0
    80005e56:	ffffd097          	auipc	ra,0xffffd
    80005e5a:	160080e7          	jalr	352(ra) # 80002fb6 <argstr>
    80005e5e:	02054b63          	bltz	a0,80005e94 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005e62:	f6841683          	lh	a3,-152(s0)
    80005e66:	f6c41603          	lh	a2,-148(s0)
    80005e6a:	458d                	li	a1,3
    80005e6c:	f7040513          	addi	a0,s0,-144
    80005e70:	fffff097          	auipc	ra,0xfffff
    80005e74:	77e080e7          	jalr	1918(ra) # 800055ee <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e78:	cd11                	beqz	a0,80005e94 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005e7a:	ffffe097          	auipc	ra,0xffffe
    80005e7e:	06c080e7          	jalr	108(ra) # 80003ee6 <iunlockput>
  end_op();
    80005e82:	fffff097          	auipc	ra,0xfffff
    80005e86:	844080e7          	jalr	-1980(ra) # 800046c6 <end_op>
  return 0;
    80005e8a:	4501                	li	a0,0
}
    80005e8c:	60ea                	ld	ra,152(sp)
    80005e8e:	644a                	ld	s0,144(sp)
    80005e90:	610d                	addi	sp,sp,160
    80005e92:	8082                	ret
    end_op();
    80005e94:	fffff097          	auipc	ra,0xfffff
    80005e98:	832080e7          	jalr	-1998(ra) # 800046c6 <end_op>
    return -1;
    80005e9c:	557d                	li	a0,-1
    80005e9e:	b7fd                	j	80005e8c <sys_mknod+0x6c>

0000000080005ea0 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005ea0:	7135                	addi	sp,sp,-160
    80005ea2:	ed06                	sd	ra,152(sp)
    80005ea4:	e922                	sd	s0,144(sp)
    80005ea6:	e526                	sd	s1,136(sp)
    80005ea8:	e14a                	sd	s2,128(sp)
    80005eaa:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005eac:	ffffc097          	auipc	ra,0xffffc
    80005eb0:	b34080e7          	jalr	-1228(ra) # 800019e0 <myproc>
    80005eb4:	892a                	mv	s2,a0
  
  begin_op();
    80005eb6:	ffffe097          	auipc	ra,0xffffe
    80005eba:	790080e7          	jalr	1936(ra) # 80004646 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005ebe:	08000613          	li	a2,128
    80005ec2:	f6040593          	addi	a1,s0,-160
    80005ec6:	4501                	li	a0,0
    80005ec8:	ffffd097          	auipc	ra,0xffffd
    80005ecc:	0ee080e7          	jalr	238(ra) # 80002fb6 <argstr>
    80005ed0:	04054b63          	bltz	a0,80005f26 <sys_chdir+0x86>
    80005ed4:	f6040513          	addi	a0,s0,-160
    80005ed8:	ffffe097          	auipc	ra,0xffffe
    80005edc:	552080e7          	jalr	1362(ra) # 8000442a <namei>
    80005ee0:	84aa                	mv	s1,a0
    80005ee2:	c131                	beqz	a0,80005f26 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005ee4:	ffffe097          	auipc	ra,0xffffe
    80005ee8:	da0080e7          	jalr	-608(ra) # 80003c84 <ilock>
  if(ip->type != T_DIR){
    80005eec:	04449703          	lh	a4,68(s1)
    80005ef0:	4785                	li	a5,1
    80005ef2:	04f71063          	bne	a4,a5,80005f32 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005ef6:	8526                	mv	a0,s1
    80005ef8:	ffffe097          	auipc	ra,0xffffe
    80005efc:	e4e080e7          	jalr	-434(ra) # 80003d46 <iunlock>
  iput(p->cwd);
    80005f00:	19093503          	ld	a0,400(s2)
    80005f04:	ffffe097          	auipc	ra,0xffffe
    80005f08:	f3a080e7          	jalr	-198(ra) # 80003e3e <iput>
  end_op();
    80005f0c:	ffffe097          	auipc	ra,0xffffe
    80005f10:	7ba080e7          	jalr	1978(ra) # 800046c6 <end_op>
  p->cwd = ip;
    80005f14:	18993823          	sd	s1,400(s2)
  return 0;
    80005f18:	4501                	li	a0,0
}
    80005f1a:	60ea                	ld	ra,152(sp)
    80005f1c:	644a                	ld	s0,144(sp)
    80005f1e:	64aa                	ld	s1,136(sp)
    80005f20:	690a                	ld	s2,128(sp)
    80005f22:	610d                	addi	sp,sp,160
    80005f24:	8082                	ret
    end_op();
    80005f26:	ffffe097          	auipc	ra,0xffffe
    80005f2a:	7a0080e7          	jalr	1952(ra) # 800046c6 <end_op>
    return -1;
    80005f2e:	557d                	li	a0,-1
    80005f30:	b7ed                	j	80005f1a <sys_chdir+0x7a>
    iunlockput(ip);
    80005f32:	8526                	mv	a0,s1
    80005f34:	ffffe097          	auipc	ra,0xffffe
    80005f38:	fb2080e7          	jalr	-78(ra) # 80003ee6 <iunlockput>
    end_op();
    80005f3c:	ffffe097          	auipc	ra,0xffffe
    80005f40:	78a080e7          	jalr	1930(ra) # 800046c6 <end_op>
    return -1;
    80005f44:	557d                	li	a0,-1
    80005f46:	bfd1                	j	80005f1a <sys_chdir+0x7a>

0000000080005f48 <sys_exec>:

uint64
sys_exec(void)
{
    80005f48:	7145                	addi	sp,sp,-464
    80005f4a:	e786                	sd	ra,456(sp)
    80005f4c:	e3a2                	sd	s0,448(sp)
    80005f4e:	ff26                	sd	s1,440(sp)
    80005f50:	fb4a                	sd	s2,432(sp)
    80005f52:	f74e                	sd	s3,424(sp)
    80005f54:	f352                	sd	s4,416(sp)
    80005f56:	ef56                	sd	s5,408(sp)
    80005f58:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005f5a:	e3840593          	addi	a1,s0,-456
    80005f5e:	4505                	li	a0,1
    80005f60:	ffffd097          	auipc	ra,0xffffd
    80005f64:	036080e7          	jalr	54(ra) # 80002f96 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005f68:	08000613          	li	a2,128
    80005f6c:	f4040593          	addi	a1,s0,-192
    80005f70:	4501                	li	a0,0
    80005f72:	ffffd097          	auipc	ra,0xffffd
    80005f76:	044080e7          	jalr	68(ra) # 80002fb6 <argstr>
    80005f7a:	87aa                	mv	a5,a0
    return -1;
    80005f7c:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005f7e:	0c07c263          	bltz	a5,80006042 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005f82:	10000613          	li	a2,256
    80005f86:	4581                	li	a1,0
    80005f88:	e4040513          	addi	a0,s0,-448
    80005f8c:	ffffb097          	auipc	ra,0xffffb
    80005f90:	d46080e7          	jalr	-698(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005f94:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005f98:	89a6                	mv	s3,s1
    80005f9a:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005f9c:	02000a13          	li	s4,32
    80005fa0:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005fa4:	00391793          	slli	a5,s2,0x3
    80005fa8:	e3040593          	addi	a1,s0,-464
    80005fac:	e3843503          	ld	a0,-456(s0)
    80005fb0:	953e                	add	a0,a0,a5
    80005fb2:	ffffd097          	auipc	ra,0xffffd
    80005fb6:	f26080e7          	jalr	-218(ra) # 80002ed8 <fetchaddr>
    80005fba:	02054a63          	bltz	a0,80005fee <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005fbe:	e3043783          	ld	a5,-464(s0)
    80005fc2:	c3b9                	beqz	a5,80006008 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005fc4:	ffffb097          	auipc	ra,0xffffb
    80005fc8:	b22080e7          	jalr	-1246(ra) # 80000ae6 <kalloc>
    80005fcc:	85aa                	mv	a1,a0
    80005fce:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005fd2:	cd11                	beqz	a0,80005fee <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005fd4:	6605                	lui	a2,0x1
    80005fd6:	e3043503          	ld	a0,-464(s0)
    80005fda:	ffffd097          	auipc	ra,0xffffd
    80005fde:	f50080e7          	jalr	-176(ra) # 80002f2a <fetchstr>
    80005fe2:	00054663          	bltz	a0,80005fee <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005fe6:	0905                	addi	s2,s2,1
    80005fe8:	09a1                	addi	s3,s3,8
    80005fea:	fb491be3          	bne	s2,s4,80005fa0 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fee:	10048913          	addi	s2,s1,256
    80005ff2:	6088                	ld	a0,0(s1)
    80005ff4:	c531                	beqz	a0,80006040 <sys_exec+0xf8>
    kfree(argv[i]);
    80005ff6:	ffffb097          	auipc	ra,0xffffb
    80005ffa:	9f4080e7          	jalr	-1548(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ffe:	04a1                	addi	s1,s1,8
    80006000:	ff2499e3          	bne	s1,s2,80005ff2 <sys_exec+0xaa>
  return -1;
    80006004:	557d                	li	a0,-1
    80006006:	a835                	j	80006042 <sys_exec+0xfa>
      argv[i] = 0;
    80006008:	0a8e                	slli	s5,s5,0x3
    8000600a:	fc040793          	addi	a5,s0,-64
    8000600e:	9abe                	add	s5,s5,a5
    80006010:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80006014:	e4040593          	addi	a1,s0,-448
    80006018:	f4040513          	addi	a0,s0,-192
    8000601c:	fffff097          	auipc	ra,0xfffff
    80006020:	170080e7          	jalr	368(ra) # 8000518c <exec>
    80006024:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006026:	10048993          	addi	s3,s1,256
    8000602a:	6088                	ld	a0,0(s1)
    8000602c:	c901                	beqz	a0,8000603c <sys_exec+0xf4>
    kfree(argv[i]);
    8000602e:	ffffb097          	auipc	ra,0xffffb
    80006032:	9bc080e7          	jalr	-1604(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006036:	04a1                	addi	s1,s1,8
    80006038:	ff3499e3          	bne	s1,s3,8000602a <sys_exec+0xe2>
  return ret;
    8000603c:	854a                	mv	a0,s2
    8000603e:	a011                	j	80006042 <sys_exec+0xfa>
  return -1;
    80006040:	557d                	li	a0,-1
}
    80006042:	60be                	ld	ra,456(sp)
    80006044:	641e                	ld	s0,448(sp)
    80006046:	74fa                	ld	s1,440(sp)
    80006048:	795a                	ld	s2,432(sp)
    8000604a:	79ba                	ld	s3,424(sp)
    8000604c:	7a1a                	ld	s4,416(sp)
    8000604e:	6afa                	ld	s5,408(sp)
    80006050:	6179                	addi	sp,sp,464
    80006052:	8082                	ret

0000000080006054 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006054:	7139                	addi	sp,sp,-64
    80006056:	fc06                	sd	ra,56(sp)
    80006058:	f822                	sd	s0,48(sp)
    8000605a:	f426                	sd	s1,40(sp)
    8000605c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000605e:	ffffc097          	auipc	ra,0xffffc
    80006062:	982080e7          	jalr	-1662(ra) # 800019e0 <myproc>
    80006066:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80006068:	fd840593          	addi	a1,s0,-40
    8000606c:	4501                	li	a0,0
    8000606e:	ffffd097          	auipc	ra,0xffffd
    80006072:	f28080e7          	jalr	-216(ra) # 80002f96 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80006076:	fc840593          	addi	a1,s0,-56
    8000607a:	fd040513          	addi	a0,s0,-48
    8000607e:	fffff097          	auipc	ra,0xfffff
    80006082:	dc4080e7          	jalr	-572(ra) # 80004e42 <pipealloc>
    return -1;
    80006086:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006088:	0c054763          	bltz	a0,80006156 <sys_pipe+0x102>
  fd0 = -1;
    8000608c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006090:	fd043503          	ld	a0,-48(s0)
    80006094:	fffff097          	auipc	ra,0xfffff
    80006098:	518080e7          	jalr	1304(ra) # 800055ac <fdalloc>
    8000609c:	fca42223          	sw	a0,-60(s0)
    800060a0:	08054e63          	bltz	a0,8000613c <sys_pipe+0xe8>
    800060a4:	fc843503          	ld	a0,-56(s0)
    800060a8:	fffff097          	auipc	ra,0xfffff
    800060ac:	504080e7          	jalr	1284(ra) # 800055ac <fdalloc>
    800060b0:	fca42023          	sw	a0,-64(s0)
    800060b4:	06054a63          	bltz	a0,80006128 <sys_pipe+0xd4>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800060b8:	4691                	li	a3,4
    800060ba:	fc440613          	addi	a2,s0,-60
    800060be:	fd843583          	ld	a1,-40(s0)
    800060c2:	68c8                	ld	a0,144(s1)
    800060c4:	ffffb097          	auipc	ra,0xffffb
    800060c8:	5a4080e7          	jalr	1444(ra) # 80001668 <copyout>
    800060cc:	02054063          	bltz	a0,800060ec <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800060d0:	4691                	li	a3,4
    800060d2:	fc040613          	addi	a2,s0,-64
    800060d6:	fd843583          	ld	a1,-40(s0)
    800060da:	0591                	addi	a1,a1,4
    800060dc:	68c8                	ld	a0,144(s1)
    800060de:	ffffb097          	auipc	ra,0xffffb
    800060e2:	58a080e7          	jalr	1418(ra) # 80001668 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800060e6:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800060e8:	06055763          	bgez	a0,80006156 <sys_pipe+0x102>
    p->ofile[fd0] = 0;
    800060ec:	fc442783          	lw	a5,-60(s0)
    800060f0:	02278793          	addi	a5,a5,34
    800060f4:	078e                	slli	a5,a5,0x3
    800060f6:	97a6                	add	a5,a5,s1
    800060f8:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800060fc:	fc042503          	lw	a0,-64(s0)
    80006100:	02250513          	addi	a0,a0,34
    80006104:	050e                	slli	a0,a0,0x3
    80006106:	94aa                	add	s1,s1,a0
    80006108:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000610c:	fd043503          	ld	a0,-48(s0)
    80006110:	fffff097          	auipc	ra,0xfffff
    80006114:	a02080e7          	jalr	-1534(ra) # 80004b12 <fileclose>
    fileclose(wf);
    80006118:	fc843503          	ld	a0,-56(s0)
    8000611c:	fffff097          	auipc	ra,0xfffff
    80006120:	9f6080e7          	jalr	-1546(ra) # 80004b12 <fileclose>
    return -1;
    80006124:	57fd                	li	a5,-1
    80006126:	a805                	j	80006156 <sys_pipe+0x102>
    if(fd0 >= 0)
    80006128:	fc442783          	lw	a5,-60(s0)
    8000612c:	0007c863          	bltz	a5,8000613c <sys_pipe+0xe8>
      p->ofile[fd0] = 0;
    80006130:	02278793          	addi	a5,a5,34
    80006134:	078e                	slli	a5,a5,0x3
    80006136:	94be                	add	s1,s1,a5
    80006138:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000613c:	fd043503          	ld	a0,-48(s0)
    80006140:	fffff097          	auipc	ra,0xfffff
    80006144:	9d2080e7          	jalr	-1582(ra) # 80004b12 <fileclose>
    fileclose(wf);
    80006148:	fc843503          	ld	a0,-56(s0)
    8000614c:	fffff097          	auipc	ra,0xfffff
    80006150:	9c6080e7          	jalr	-1594(ra) # 80004b12 <fileclose>
    return -1;
    80006154:	57fd                	li	a5,-1
}
    80006156:	853e                	mv	a0,a5
    80006158:	70e2                	ld	ra,56(sp)
    8000615a:	7442                	ld	s0,48(sp)
    8000615c:	74a2                	ld	s1,40(sp)
    8000615e:	6121                	addi	sp,sp,64
    80006160:	8082                	ret
	...

0000000080006170 <kernelvec>:
    80006170:	7111                	addi	sp,sp,-256
    80006172:	e006                	sd	ra,0(sp)
    80006174:	e40a                	sd	sp,8(sp)
    80006176:	e80e                	sd	gp,16(sp)
    80006178:	ec12                	sd	tp,24(sp)
    8000617a:	f016                	sd	t0,32(sp)
    8000617c:	f41a                	sd	t1,40(sp)
    8000617e:	f81e                	sd	t2,48(sp)
    80006180:	fc22                	sd	s0,56(sp)
    80006182:	e0a6                	sd	s1,64(sp)
    80006184:	e4aa                	sd	a0,72(sp)
    80006186:	e8ae                	sd	a1,80(sp)
    80006188:	ecb2                	sd	a2,88(sp)
    8000618a:	f0b6                	sd	a3,96(sp)
    8000618c:	f4ba                	sd	a4,104(sp)
    8000618e:	f8be                	sd	a5,112(sp)
    80006190:	fcc2                	sd	a6,120(sp)
    80006192:	e146                	sd	a7,128(sp)
    80006194:	e54a                	sd	s2,136(sp)
    80006196:	e94e                	sd	s3,144(sp)
    80006198:	ed52                	sd	s4,152(sp)
    8000619a:	f156                	sd	s5,160(sp)
    8000619c:	f55a                	sd	s6,168(sp)
    8000619e:	f95e                	sd	s7,176(sp)
    800061a0:	fd62                	sd	s8,184(sp)
    800061a2:	e1e6                	sd	s9,192(sp)
    800061a4:	e5ea                	sd	s10,200(sp)
    800061a6:	e9ee                	sd	s11,208(sp)
    800061a8:	edf2                	sd	t3,216(sp)
    800061aa:	f1f6                	sd	t4,224(sp)
    800061ac:	f5fa                	sd	t5,232(sp)
    800061ae:	f9fe                	sd	t6,240(sp)
    800061b0:	ba1fc0ef          	jal	ra,80002d50 <kerneltrap>
    800061b4:	6082                	ld	ra,0(sp)
    800061b6:	6122                	ld	sp,8(sp)
    800061b8:	61c2                	ld	gp,16(sp)
    800061ba:	7282                	ld	t0,32(sp)
    800061bc:	7322                	ld	t1,40(sp)
    800061be:	73c2                	ld	t2,48(sp)
    800061c0:	7462                	ld	s0,56(sp)
    800061c2:	6486                	ld	s1,64(sp)
    800061c4:	6526                	ld	a0,72(sp)
    800061c6:	65c6                	ld	a1,80(sp)
    800061c8:	6666                	ld	a2,88(sp)
    800061ca:	7686                	ld	a3,96(sp)
    800061cc:	7726                	ld	a4,104(sp)
    800061ce:	77c6                	ld	a5,112(sp)
    800061d0:	7866                	ld	a6,120(sp)
    800061d2:	688a                	ld	a7,128(sp)
    800061d4:	692a                	ld	s2,136(sp)
    800061d6:	69ca                	ld	s3,144(sp)
    800061d8:	6a6a                	ld	s4,152(sp)
    800061da:	7a8a                	ld	s5,160(sp)
    800061dc:	7b2a                	ld	s6,168(sp)
    800061de:	7bca                	ld	s7,176(sp)
    800061e0:	7c6a                	ld	s8,184(sp)
    800061e2:	6c8e                	ld	s9,192(sp)
    800061e4:	6d2e                	ld	s10,200(sp)
    800061e6:	6dce                	ld	s11,208(sp)
    800061e8:	6e6e                	ld	t3,216(sp)
    800061ea:	7e8e                	ld	t4,224(sp)
    800061ec:	7f2e                	ld	t5,232(sp)
    800061ee:	7fce                	ld	t6,240(sp)
    800061f0:	6111                	addi	sp,sp,256
    800061f2:	10200073          	sret
    800061f6:	00000013          	nop
    800061fa:	00000013          	nop
    800061fe:	0001                	nop

0000000080006200 <timervec>:
    80006200:	34051573          	csrrw	a0,mscratch,a0
    80006204:	e10c                	sd	a1,0(a0)
    80006206:	e510                	sd	a2,8(a0)
    80006208:	e914                	sd	a3,16(a0)
    8000620a:	6d0c                	ld	a1,24(a0)
    8000620c:	7110                	ld	a2,32(a0)
    8000620e:	6194                	ld	a3,0(a1)
    80006210:	96b2                	add	a3,a3,a2
    80006212:	e194                	sd	a3,0(a1)
    80006214:	4589                	li	a1,2
    80006216:	14459073          	csrw	sip,a1
    8000621a:	6914                	ld	a3,16(a0)
    8000621c:	6510                	ld	a2,8(a0)
    8000621e:	610c                	ld	a1,0(a0)
    80006220:	34051573          	csrrw	a0,mscratch,a0
    80006224:	30200073          	mret
	...

000000008000622a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000622a:	1141                	addi	sp,sp,-16
    8000622c:	e422                	sd	s0,8(sp)
    8000622e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006230:	0c0007b7          	lui	a5,0xc000
    80006234:	4705                	li	a4,1
    80006236:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006238:	c3d8                	sw	a4,4(a5)
}
    8000623a:	6422                	ld	s0,8(sp)
    8000623c:	0141                	addi	sp,sp,16
    8000623e:	8082                	ret

0000000080006240 <plicinithart>:

void
plicinithart(void)
{
    80006240:	1141                	addi	sp,sp,-16
    80006242:	e406                	sd	ra,8(sp)
    80006244:	e022                	sd	s0,0(sp)
    80006246:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006248:	ffffb097          	auipc	ra,0xffffb
    8000624c:	756080e7          	jalr	1878(ra) # 8000199e <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006250:	0085171b          	slliw	a4,a0,0x8
    80006254:	0c0027b7          	lui	a5,0xc002
    80006258:	97ba                	add	a5,a5,a4
    8000625a:	40200713          	li	a4,1026
    8000625e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006262:	00d5151b          	slliw	a0,a0,0xd
    80006266:	0c2017b7          	lui	a5,0xc201
    8000626a:	953e                	add	a0,a0,a5
    8000626c:	00052023          	sw	zero,0(a0)
}
    80006270:	60a2                	ld	ra,8(sp)
    80006272:	6402                	ld	s0,0(sp)
    80006274:	0141                	addi	sp,sp,16
    80006276:	8082                	ret

0000000080006278 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006278:	1141                	addi	sp,sp,-16
    8000627a:	e406                	sd	ra,8(sp)
    8000627c:	e022                	sd	s0,0(sp)
    8000627e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006280:	ffffb097          	auipc	ra,0xffffb
    80006284:	71e080e7          	jalr	1822(ra) # 8000199e <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006288:	00d5179b          	slliw	a5,a0,0xd
    8000628c:	0c201537          	lui	a0,0xc201
    80006290:	953e                	add	a0,a0,a5
  return irq;
}
    80006292:	4148                	lw	a0,4(a0)
    80006294:	60a2                	ld	ra,8(sp)
    80006296:	6402                	ld	s0,0(sp)
    80006298:	0141                	addi	sp,sp,16
    8000629a:	8082                	ret

000000008000629c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000629c:	1101                	addi	sp,sp,-32
    8000629e:	ec06                	sd	ra,24(sp)
    800062a0:	e822                	sd	s0,16(sp)
    800062a2:	e426                	sd	s1,8(sp)
    800062a4:	1000                	addi	s0,sp,32
    800062a6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800062a8:	ffffb097          	auipc	ra,0xffffb
    800062ac:	6f6080e7          	jalr	1782(ra) # 8000199e <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800062b0:	00d5151b          	slliw	a0,a0,0xd
    800062b4:	0c2017b7          	lui	a5,0xc201
    800062b8:	97aa                	add	a5,a5,a0
    800062ba:	c3c4                	sw	s1,4(a5)
}
    800062bc:	60e2                	ld	ra,24(sp)
    800062be:	6442                	ld	s0,16(sp)
    800062c0:	64a2                	ld	s1,8(sp)
    800062c2:	6105                	addi	sp,sp,32
    800062c4:	8082                	ret

00000000800062c6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800062c6:	1141                	addi	sp,sp,-16
    800062c8:	e406                	sd	ra,8(sp)
    800062ca:	e022                	sd	s0,0(sp)
    800062cc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800062ce:	479d                	li	a5,7
    800062d0:	04a7cc63          	blt	a5,a0,80006328 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800062d4:	0001d797          	auipc	a5,0x1d
    800062d8:	97c78793          	addi	a5,a5,-1668 # 80022c50 <disk>
    800062dc:	97aa                	add	a5,a5,a0
    800062de:	0187c783          	lbu	a5,24(a5)
    800062e2:	ebb9                	bnez	a5,80006338 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800062e4:	00451613          	slli	a2,a0,0x4
    800062e8:	0001d797          	auipc	a5,0x1d
    800062ec:	96878793          	addi	a5,a5,-1688 # 80022c50 <disk>
    800062f0:	6394                	ld	a3,0(a5)
    800062f2:	96b2                	add	a3,a3,a2
    800062f4:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800062f8:	6398                	ld	a4,0(a5)
    800062fa:	9732                	add	a4,a4,a2
    800062fc:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006300:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006304:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006308:	953e                	add	a0,a0,a5
    8000630a:	4785                	li	a5,1
    8000630c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006310:	0001d517          	auipc	a0,0x1d
    80006314:	95850513          	addi	a0,a0,-1704 # 80022c68 <disk+0x18>
    80006318:	ffffc097          	auipc	ra,0xffffc
    8000631c:	09c080e7          	jalr	156(ra) # 800023b4 <wakeup>
}
    80006320:	60a2                	ld	ra,8(sp)
    80006322:	6402                	ld	s0,0(sp)
    80006324:	0141                	addi	sp,sp,16
    80006326:	8082                	ret
    panic("free_desc 1");
    80006328:	00002517          	auipc	a0,0x2
    8000632c:	44850513          	addi	a0,a0,1096 # 80008770 <syscalls+0x320>
    80006330:	ffffa097          	auipc	ra,0xffffa
    80006334:	20e080e7          	jalr	526(ra) # 8000053e <panic>
    panic("free_desc 2");
    80006338:	00002517          	auipc	a0,0x2
    8000633c:	44850513          	addi	a0,a0,1096 # 80008780 <syscalls+0x330>
    80006340:	ffffa097          	auipc	ra,0xffffa
    80006344:	1fe080e7          	jalr	510(ra) # 8000053e <panic>

0000000080006348 <virtio_disk_init>:
{
    80006348:	1101                	addi	sp,sp,-32
    8000634a:	ec06                	sd	ra,24(sp)
    8000634c:	e822                	sd	s0,16(sp)
    8000634e:	e426                	sd	s1,8(sp)
    80006350:	e04a                	sd	s2,0(sp)
    80006352:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006354:	00002597          	auipc	a1,0x2
    80006358:	43c58593          	addi	a1,a1,1084 # 80008790 <syscalls+0x340>
    8000635c:	0001d517          	auipc	a0,0x1d
    80006360:	a1c50513          	addi	a0,a0,-1508 # 80022d78 <disk+0x128>
    80006364:	ffffa097          	auipc	ra,0xffffa
    80006368:	7e2080e7          	jalr	2018(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000636c:	100017b7          	lui	a5,0x10001
    80006370:	4398                	lw	a4,0(a5)
    80006372:	2701                	sext.w	a4,a4
    80006374:	747277b7          	lui	a5,0x74727
    80006378:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000637c:	14f71c63          	bne	a4,a5,800064d4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006380:	100017b7          	lui	a5,0x10001
    80006384:	43dc                	lw	a5,4(a5)
    80006386:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006388:	4709                	li	a4,2
    8000638a:	14e79563          	bne	a5,a4,800064d4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000638e:	100017b7          	lui	a5,0x10001
    80006392:	479c                	lw	a5,8(a5)
    80006394:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006396:	12e79f63          	bne	a5,a4,800064d4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000639a:	100017b7          	lui	a5,0x10001
    8000639e:	47d8                	lw	a4,12(a5)
    800063a0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800063a2:	554d47b7          	lui	a5,0x554d4
    800063a6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800063aa:	12f71563          	bne	a4,a5,800064d4 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    800063ae:	100017b7          	lui	a5,0x10001
    800063b2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800063b6:	4705                	li	a4,1
    800063b8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800063ba:	470d                	li	a4,3
    800063bc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800063be:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800063c0:	c7ffe737          	lui	a4,0xc7ffe
    800063c4:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb9cf>
    800063c8:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800063ca:	2701                	sext.w	a4,a4
    800063cc:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800063ce:	472d                	li	a4,11
    800063d0:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800063d2:	5bbc                	lw	a5,112(a5)
    800063d4:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800063d8:	8ba1                	andi	a5,a5,8
    800063da:	10078563          	beqz	a5,800064e4 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800063de:	100017b7          	lui	a5,0x10001
    800063e2:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800063e6:	43fc                	lw	a5,68(a5)
    800063e8:	2781                	sext.w	a5,a5
    800063ea:	10079563          	bnez	a5,800064f4 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800063ee:	100017b7          	lui	a5,0x10001
    800063f2:	5bdc                	lw	a5,52(a5)
    800063f4:	2781                	sext.w	a5,a5
  if(max == 0)
    800063f6:	10078763          	beqz	a5,80006504 <virtio_disk_init+0x1bc>
  if(max < NUM)
    800063fa:	471d                	li	a4,7
    800063fc:	10f77c63          	bgeu	a4,a5,80006514 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    80006400:	ffffa097          	auipc	ra,0xffffa
    80006404:	6e6080e7          	jalr	1766(ra) # 80000ae6 <kalloc>
    80006408:	0001d497          	auipc	s1,0x1d
    8000640c:	84848493          	addi	s1,s1,-1976 # 80022c50 <disk>
    80006410:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006412:	ffffa097          	auipc	ra,0xffffa
    80006416:	6d4080e7          	jalr	1748(ra) # 80000ae6 <kalloc>
    8000641a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000641c:	ffffa097          	auipc	ra,0xffffa
    80006420:	6ca080e7          	jalr	1738(ra) # 80000ae6 <kalloc>
    80006424:	87aa                	mv	a5,a0
    80006426:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006428:	6088                	ld	a0,0(s1)
    8000642a:	cd6d                	beqz	a0,80006524 <virtio_disk_init+0x1dc>
    8000642c:	0001d717          	auipc	a4,0x1d
    80006430:	82c73703          	ld	a4,-2004(a4) # 80022c58 <disk+0x8>
    80006434:	cb65                	beqz	a4,80006524 <virtio_disk_init+0x1dc>
    80006436:	c7fd                	beqz	a5,80006524 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    80006438:	6605                	lui	a2,0x1
    8000643a:	4581                	li	a1,0
    8000643c:	ffffb097          	auipc	ra,0xffffb
    80006440:	896080e7          	jalr	-1898(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006444:	0001d497          	auipc	s1,0x1d
    80006448:	80c48493          	addi	s1,s1,-2036 # 80022c50 <disk>
    8000644c:	6605                	lui	a2,0x1
    8000644e:	4581                	li	a1,0
    80006450:	6488                	ld	a0,8(s1)
    80006452:	ffffb097          	auipc	ra,0xffffb
    80006456:	880080e7          	jalr	-1920(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    8000645a:	6605                	lui	a2,0x1
    8000645c:	4581                	li	a1,0
    8000645e:	6888                	ld	a0,16(s1)
    80006460:	ffffb097          	auipc	ra,0xffffb
    80006464:	872080e7          	jalr	-1934(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006468:	100017b7          	lui	a5,0x10001
    8000646c:	4721                	li	a4,8
    8000646e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006470:	4098                	lw	a4,0(s1)
    80006472:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006476:	40d8                	lw	a4,4(s1)
    80006478:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000647c:	6498                	ld	a4,8(s1)
    8000647e:	0007069b          	sext.w	a3,a4
    80006482:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006486:	9701                	srai	a4,a4,0x20
    80006488:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000648c:	6898                	ld	a4,16(s1)
    8000648e:	0007069b          	sext.w	a3,a4
    80006492:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006496:	9701                	srai	a4,a4,0x20
    80006498:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000649c:	4705                	li	a4,1
    8000649e:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800064a0:	00e48c23          	sb	a4,24(s1)
    800064a4:	00e48ca3          	sb	a4,25(s1)
    800064a8:	00e48d23          	sb	a4,26(s1)
    800064ac:	00e48da3          	sb	a4,27(s1)
    800064b0:	00e48e23          	sb	a4,28(s1)
    800064b4:	00e48ea3          	sb	a4,29(s1)
    800064b8:	00e48f23          	sb	a4,30(s1)
    800064bc:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800064c0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800064c4:	0727a823          	sw	s2,112(a5)
}
    800064c8:	60e2                	ld	ra,24(sp)
    800064ca:	6442                	ld	s0,16(sp)
    800064cc:	64a2                	ld	s1,8(sp)
    800064ce:	6902                	ld	s2,0(sp)
    800064d0:	6105                	addi	sp,sp,32
    800064d2:	8082                	ret
    panic("could not find virtio disk");
    800064d4:	00002517          	auipc	a0,0x2
    800064d8:	2cc50513          	addi	a0,a0,716 # 800087a0 <syscalls+0x350>
    800064dc:	ffffa097          	auipc	ra,0xffffa
    800064e0:	062080e7          	jalr	98(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    800064e4:	00002517          	auipc	a0,0x2
    800064e8:	2dc50513          	addi	a0,a0,732 # 800087c0 <syscalls+0x370>
    800064ec:	ffffa097          	auipc	ra,0xffffa
    800064f0:	052080e7          	jalr	82(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    800064f4:	00002517          	auipc	a0,0x2
    800064f8:	2ec50513          	addi	a0,a0,748 # 800087e0 <syscalls+0x390>
    800064fc:	ffffa097          	auipc	ra,0xffffa
    80006500:	042080e7          	jalr	66(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    80006504:	00002517          	auipc	a0,0x2
    80006508:	2fc50513          	addi	a0,a0,764 # 80008800 <syscalls+0x3b0>
    8000650c:	ffffa097          	auipc	ra,0xffffa
    80006510:	032080e7          	jalr	50(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    80006514:	00002517          	auipc	a0,0x2
    80006518:	30c50513          	addi	a0,a0,780 # 80008820 <syscalls+0x3d0>
    8000651c:	ffffa097          	auipc	ra,0xffffa
    80006520:	022080e7          	jalr	34(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    80006524:	00002517          	auipc	a0,0x2
    80006528:	31c50513          	addi	a0,a0,796 # 80008840 <syscalls+0x3f0>
    8000652c:	ffffa097          	auipc	ra,0xffffa
    80006530:	012080e7          	jalr	18(ra) # 8000053e <panic>

0000000080006534 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006534:	7119                	addi	sp,sp,-128
    80006536:	fc86                	sd	ra,120(sp)
    80006538:	f8a2                	sd	s0,112(sp)
    8000653a:	f4a6                	sd	s1,104(sp)
    8000653c:	f0ca                	sd	s2,96(sp)
    8000653e:	ecce                	sd	s3,88(sp)
    80006540:	e8d2                	sd	s4,80(sp)
    80006542:	e4d6                	sd	s5,72(sp)
    80006544:	e0da                	sd	s6,64(sp)
    80006546:	fc5e                	sd	s7,56(sp)
    80006548:	f862                	sd	s8,48(sp)
    8000654a:	f466                	sd	s9,40(sp)
    8000654c:	f06a                	sd	s10,32(sp)
    8000654e:	ec6e                	sd	s11,24(sp)
    80006550:	0100                	addi	s0,sp,128
    80006552:	8aaa                	mv	s5,a0
    80006554:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006556:	00c52d03          	lw	s10,12(a0)
    8000655a:	001d1d1b          	slliw	s10,s10,0x1
    8000655e:	1d02                	slli	s10,s10,0x20
    80006560:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006564:	0001d517          	auipc	a0,0x1d
    80006568:	81450513          	addi	a0,a0,-2028 # 80022d78 <disk+0x128>
    8000656c:	ffffa097          	auipc	ra,0xffffa
    80006570:	66a080e7          	jalr	1642(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80006574:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006576:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006578:	0001cb97          	auipc	s7,0x1c
    8000657c:	6d8b8b93          	addi	s7,s7,1752 # 80022c50 <disk>
  for(int i = 0; i < 3; i++){
    80006580:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006582:	0001cc97          	auipc	s9,0x1c
    80006586:	7f6c8c93          	addi	s9,s9,2038 # 80022d78 <disk+0x128>
    8000658a:	a08d                	j	800065ec <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000658c:	00fb8733          	add	a4,s7,a5
    80006590:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006594:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006596:	0207c563          	bltz	a5,800065c0 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000659a:	2905                	addiw	s2,s2,1
    8000659c:	0611                	addi	a2,a2,4
    8000659e:	05690c63          	beq	s2,s6,800065f6 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    800065a2:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800065a4:	0001c717          	auipc	a4,0x1c
    800065a8:	6ac70713          	addi	a4,a4,1708 # 80022c50 <disk>
    800065ac:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800065ae:	01874683          	lbu	a3,24(a4)
    800065b2:	fee9                	bnez	a3,8000658c <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800065b4:	2785                	addiw	a5,a5,1
    800065b6:	0705                	addi	a4,a4,1
    800065b8:	fe979be3          	bne	a5,s1,800065ae <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800065bc:	57fd                	li	a5,-1
    800065be:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800065c0:	01205d63          	blez	s2,800065da <virtio_disk_rw+0xa6>
    800065c4:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800065c6:	000a2503          	lw	a0,0(s4)
    800065ca:	00000097          	auipc	ra,0x0
    800065ce:	cfc080e7          	jalr	-772(ra) # 800062c6 <free_desc>
      for(int j = 0; j < i; j++)
    800065d2:	2d85                	addiw	s11,s11,1
    800065d4:	0a11                	addi	s4,s4,4
    800065d6:	ffb918e3          	bne	s2,s11,800065c6 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800065da:	85e6                	mv	a1,s9
    800065dc:	0001c517          	auipc	a0,0x1c
    800065e0:	68c50513          	addi	a0,a0,1676 # 80022c68 <disk+0x18>
    800065e4:	ffffc097          	auipc	ra,0xffffc
    800065e8:	ce8080e7          	jalr	-792(ra) # 800022cc <sleep>
  for(int i = 0; i < 3; i++){
    800065ec:	f8040a13          	addi	s4,s0,-128
{
    800065f0:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800065f2:	894e                	mv	s2,s3
    800065f4:	b77d                	j	800065a2 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800065f6:	f8042583          	lw	a1,-128(s0)
    800065fa:	00a58793          	addi	a5,a1,10
    800065fe:	0792                	slli	a5,a5,0x4

  if(write)
    80006600:	0001c617          	auipc	a2,0x1c
    80006604:	65060613          	addi	a2,a2,1616 # 80022c50 <disk>
    80006608:	00f60733          	add	a4,a2,a5
    8000660c:	018036b3          	snez	a3,s8
    80006610:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006612:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006616:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000661a:	f6078693          	addi	a3,a5,-160
    8000661e:	6218                	ld	a4,0(a2)
    80006620:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006622:	00878513          	addi	a0,a5,8
    80006626:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006628:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000662a:	6208                	ld	a0,0(a2)
    8000662c:	96aa                	add	a3,a3,a0
    8000662e:	4741                	li	a4,16
    80006630:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006632:	4705                	li	a4,1
    80006634:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006638:	f8442703          	lw	a4,-124(s0)
    8000663c:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006640:	0712                	slli	a4,a4,0x4
    80006642:	953a                	add	a0,a0,a4
    80006644:	058a8693          	addi	a3,s5,88
    80006648:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000664a:	6208                	ld	a0,0(a2)
    8000664c:	972a                	add	a4,a4,a0
    8000664e:	40000693          	li	a3,1024
    80006652:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006654:	001c3c13          	seqz	s8,s8
    80006658:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000665a:	001c6c13          	ori	s8,s8,1
    8000665e:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006662:	f8842603          	lw	a2,-120(s0)
    80006666:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000666a:	0001c697          	auipc	a3,0x1c
    8000666e:	5e668693          	addi	a3,a3,1510 # 80022c50 <disk>
    80006672:	00258713          	addi	a4,a1,2
    80006676:	0712                	slli	a4,a4,0x4
    80006678:	9736                	add	a4,a4,a3
    8000667a:	587d                	li	a6,-1
    8000667c:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006680:	0612                	slli	a2,a2,0x4
    80006682:	9532                	add	a0,a0,a2
    80006684:	f9078793          	addi	a5,a5,-112
    80006688:	97b6                	add	a5,a5,a3
    8000668a:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    8000668c:	629c                	ld	a5,0(a3)
    8000668e:	97b2                	add	a5,a5,a2
    80006690:	4605                	li	a2,1
    80006692:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006694:	4509                	li	a0,2
    80006696:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    8000669a:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000669e:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800066a2:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800066a6:	6698                	ld	a4,8(a3)
    800066a8:	00275783          	lhu	a5,2(a4)
    800066ac:	8b9d                	andi	a5,a5,7
    800066ae:	0786                	slli	a5,a5,0x1
    800066b0:	97ba                	add	a5,a5,a4
    800066b2:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    800066b6:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800066ba:	6698                	ld	a4,8(a3)
    800066bc:	00275783          	lhu	a5,2(a4)
    800066c0:	2785                	addiw	a5,a5,1
    800066c2:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800066c6:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800066ca:	100017b7          	lui	a5,0x10001
    800066ce:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800066d2:	004aa783          	lw	a5,4(s5)
    800066d6:	02c79163          	bne	a5,a2,800066f8 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    800066da:	0001c917          	auipc	s2,0x1c
    800066de:	69e90913          	addi	s2,s2,1694 # 80022d78 <disk+0x128>
  while(b->disk == 1) {
    800066e2:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800066e4:	85ca                	mv	a1,s2
    800066e6:	8556                	mv	a0,s5
    800066e8:	ffffc097          	auipc	ra,0xffffc
    800066ec:	be4080e7          	jalr	-1052(ra) # 800022cc <sleep>
  while(b->disk == 1) {
    800066f0:	004aa783          	lw	a5,4(s5)
    800066f4:	fe9788e3          	beq	a5,s1,800066e4 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800066f8:	f8042903          	lw	s2,-128(s0)
    800066fc:	00290793          	addi	a5,s2,2
    80006700:	00479713          	slli	a4,a5,0x4
    80006704:	0001c797          	auipc	a5,0x1c
    80006708:	54c78793          	addi	a5,a5,1356 # 80022c50 <disk>
    8000670c:	97ba                	add	a5,a5,a4
    8000670e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006712:	0001c997          	auipc	s3,0x1c
    80006716:	53e98993          	addi	s3,s3,1342 # 80022c50 <disk>
    8000671a:	00491713          	slli	a4,s2,0x4
    8000671e:	0009b783          	ld	a5,0(s3)
    80006722:	97ba                	add	a5,a5,a4
    80006724:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006728:	854a                	mv	a0,s2
    8000672a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000672e:	00000097          	auipc	ra,0x0
    80006732:	b98080e7          	jalr	-1128(ra) # 800062c6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006736:	8885                	andi	s1,s1,1
    80006738:	f0ed                	bnez	s1,8000671a <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000673a:	0001c517          	auipc	a0,0x1c
    8000673e:	63e50513          	addi	a0,a0,1598 # 80022d78 <disk+0x128>
    80006742:	ffffa097          	auipc	ra,0xffffa
    80006746:	548080e7          	jalr	1352(ra) # 80000c8a <release>
}
    8000674a:	70e6                	ld	ra,120(sp)
    8000674c:	7446                	ld	s0,112(sp)
    8000674e:	74a6                	ld	s1,104(sp)
    80006750:	7906                	ld	s2,96(sp)
    80006752:	69e6                	ld	s3,88(sp)
    80006754:	6a46                	ld	s4,80(sp)
    80006756:	6aa6                	ld	s5,72(sp)
    80006758:	6b06                	ld	s6,64(sp)
    8000675a:	7be2                	ld	s7,56(sp)
    8000675c:	7c42                	ld	s8,48(sp)
    8000675e:	7ca2                	ld	s9,40(sp)
    80006760:	7d02                	ld	s10,32(sp)
    80006762:	6de2                	ld	s11,24(sp)
    80006764:	6109                	addi	sp,sp,128
    80006766:	8082                	ret

0000000080006768 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006768:	1101                	addi	sp,sp,-32
    8000676a:	ec06                	sd	ra,24(sp)
    8000676c:	e822                	sd	s0,16(sp)
    8000676e:	e426                	sd	s1,8(sp)
    80006770:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006772:	0001c497          	auipc	s1,0x1c
    80006776:	4de48493          	addi	s1,s1,1246 # 80022c50 <disk>
    8000677a:	0001c517          	auipc	a0,0x1c
    8000677e:	5fe50513          	addi	a0,a0,1534 # 80022d78 <disk+0x128>
    80006782:	ffffa097          	auipc	ra,0xffffa
    80006786:	454080e7          	jalr	1108(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000678a:	10001737          	lui	a4,0x10001
    8000678e:	533c                	lw	a5,96(a4)
    80006790:	8b8d                	andi	a5,a5,3
    80006792:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006794:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006798:	689c                	ld	a5,16(s1)
    8000679a:	0204d703          	lhu	a4,32(s1)
    8000679e:	0027d783          	lhu	a5,2(a5)
    800067a2:	04f70863          	beq	a4,a5,800067f2 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800067a6:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800067aa:	6898                	ld	a4,16(s1)
    800067ac:	0204d783          	lhu	a5,32(s1)
    800067b0:	8b9d                	andi	a5,a5,7
    800067b2:	078e                	slli	a5,a5,0x3
    800067b4:	97ba                	add	a5,a5,a4
    800067b6:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800067b8:	00278713          	addi	a4,a5,2
    800067bc:	0712                	slli	a4,a4,0x4
    800067be:	9726                	add	a4,a4,s1
    800067c0:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800067c4:	e721                	bnez	a4,8000680c <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800067c6:	0789                	addi	a5,a5,2
    800067c8:	0792                	slli	a5,a5,0x4
    800067ca:	97a6                	add	a5,a5,s1
    800067cc:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800067ce:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800067d2:	ffffc097          	auipc	ra,0xffffc
    800067d6:	be2080e7          	jalr	-1054(ra) # 800023b4 <wakeup>

    disk.used_idx += 1;
    800067da:	0204d783          	lhu	a5,32(s1)
    800067de:	2785                	addiw	a5,a5,1
    800067e0:	17c2                	slli	a5,a5,0x30
    800067e2:	93c1                	srli	a5,a5,0x30
    800067e4:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800067e8:	6898                	ld	a4,16(s1)
    800067ea:	00275703          	lhu	a4,2(a4)
    800067ee:	faf71ce3          	bne	a4,a5,800067a6 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800067f2:	0001c517          	auipc	a0,0x1c
    800067f6:	58650513          	addi	a0,a0,1414 # 80022d78 <disk+0x128>
    800067fa:	ffffa097          	auipc	ra,0xffffa
    800067fe:	490080e7          	jalr	1168(ra) # 80000c8a <release>
}
    80006802:	60e2                	ld	ra,24(sp)
    80006804:	6442                	ld	s0,16(sp)
    80006806:	64a2                	ld	s1,8(sp)
    80006808:	6105                	addi	sp,sp,32
    8000680a:	8082                	ret
      panic("virtio_disk_intr status");
    8000680c:	00002517          	auipc	a0,0x2
    80006810:	04c50513          	addi	a0,a0,76 # 80008858 <syscalls+0x408>
    80006814:	ffffa097          	auipc	ra,0xffffa
    80006818:	d2a080e7          	jalr	-726(ra) # 8000053e <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
