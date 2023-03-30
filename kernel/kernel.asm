
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8b013103          	ld	sp,-1872(sp) # 800088b0 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000056:	8be70713          	addi	a4,a4,-1858 # 80008910 <timer_scratch>
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
    80000068:	e2c78793          	addi	a5,a5,-468 # 80005e90 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdba7f>
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
    80000130:	582080e7          	jalr	1410(ra) # 800026ae <either_copyin>
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
    8000018e:	8c650513          	addi	a0,a0,-1850 # 80010a50 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	8b648493          	addi	s1,s1,-1866 # 80010a50 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	94690913          	addi	s2,s2,-1722 # 80010ae8 <cons+0x98>
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
    800001c4:	80a080e7          	jalr	-2038(ra) # 800019ca <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	2ee080e7          	jalr	750(ra) # 800024b6 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	fee080e7          	jalr	-18(ra) # 800021c4 <sleep>
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
    80000216:	446080e7          	jalr	1094(ra) # 80002658 <either_copyout>
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
    8000022a:	82a50513          	addi	a0,a0,-2006 # 80010a50 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	81450513          	addi	a0,a0,-2028 # 80010a50 <cons>
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
    80000276:	86f72b23          	sw	a5,-1930(a4) # 80010ae8 <cons+0x98>
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
    800002d0:	78450513          	addi	a0,a0,1924 # 80010a50 <cons>
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
    800002f6:	412080e7          	jalr	1042(ra) # 80002704 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	75650513          	addi	a0,a0,1878 # 80010a50 <cons>
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
    80000322:	73270713          	addi	a4,a4,1842 # 80010a50 <cons>
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
    8000034c:	70878793          	addi	a5,a5,1800 # 80010a50 <cons>
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
    8000037a:	7727a783          	lw	a5,1906(a5) # 80010ae8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	6c670713          	addi	a4,a4,1734 # 80010a50 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	6b648493          	addi	s1,s1,1718 # 80010a50 <cons>
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
    800003da:	67a70713          	addi	a4,a4,1658 # 80010a50 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	70f72223          	sw	a5,1796(a4) # 80010af0 <cons+0xa0>
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
    80000416:	63e78793          	addi	a5,a5,1598 # 80010a50 <cons>
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
    8000043a:	6ac7ab23          	sw	a2,1718(a5) # 80010aec <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	6aa50513          	addi	a0,a0,1706 # 80010ae8 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	de2080e7          	jalr	-542(ra) # 80002228 <wakeup>
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
    80000464:	5f050513          	addi	a0,a0,1520 # 80010a50 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32a080e7          	jalr	810(ra) # 8000079a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00021797          	auipc	a5,0x21
    8000047c:	77078793          	addi	a5,a5,1904 # 80021be8 <devsw>
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
    8000054e:	5c07a323          	sw	zero,1478(a5) # 80010b10 <pr+0x18>
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
    80000582:	34f72923          	sw	a5,850(a4) # 800088d0 <panicked>
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
    800005be:	556dad83          	lw	s11,1366(s11) # 80010b10 <pr+0x18>
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
    800005fc:	50050513          	addi	a0,a0,1280 # 80010af8 <pr>
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
    8000075a:	3a250513          	addi	a0,a0,930 # 80010af8 <pr>
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
    80000776:	38648493          	addi	s1,s1,902 # 80010af8 <pr>
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
    800007d6:	34650513          	addi	a0,a0,838 # 80010b18 <uart_tx_lock>
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
    80000802:	0d27a783          	lw	a5,210(a5) # 800088d0 <panicked>
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
    8000083a:	0a27b783          	ld	a5,162(a5) # 800088d8 <uart_tx_r>
    8000083e:	00008717          	auipc	a4,0x8
    80000842:	0a273703          	ld	a4,162(a4) # 800088e0 <uart_tx_w>
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
    80000864:	2b8a0a13          	addi	s4,s4,696 # 80010b18 <uart_tx_lock>
    uart_tx_r += 1;
    80000868:	00008497          	auipc	s1,0x8
    8000086c:	07048493          	addi	s1,s1,112 # 800088d8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000870:	00008997          	auipc	s3,0x8
    80000874:	07098993          	addi	s3,s3,112 # 800088e0 <uart_tx_w>
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
    80000896:	996080e7          	jalr	-1642(ra) # 80002228 <wakeup>
    
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
    800008d2:	24a50513          	addi	a0,a0,586 # 80010b18 <uart_tx_lock>
    800008d6:	00000097          	auipc	ra,0x0
    800008da:	300080e7          	jalr	768(ra) # 80000bd6 <acquire>
  if(panicked){
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	ff27a783          	lw	a5,-14(a5) # 800088d0 <panicked>
    800008e6:	e7c9                	bnez	a5,80000970 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e8:	00008717          	auipc	a4,0x8
    800008ec:	ff873703          	ld	a4,-8(a4) # 800088e0 <uart_tx_w>
    800008f0:	00008797          	auipc	a5,0x8
    800008f4:	fe87b783          	ld	a5,-24(a5) # 800088d8 <uart_tx_r>
    800008f8:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fc:	00010997          	auipc	s3,0x10
    80000900:	21c98993          	addi	s3,s3,540 # 80010b18 <uart_tx_lock>
    80000904:	00008497          	auipc	s1,0x8
    80000908:	fd448493          	addi	s1,s1,-44 # 800088d8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090c:	00008917          	auipc	s2,0x8
    80000910:	fd490913          	addi	s2,s2,-44 # 800088e0 <uart_tx_w>
    80000914:	00e79f63          	bne	a5,a4,80000932 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000918:	85ce                	mv	a1,s3
    8000091a:	8526                	mv	a0,s1
    8000091c:	00002097          	auipc	ra,0x2
    80000920:	8a8080e7          	jalr	-1880(ra) # 800021c4 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000924:	00093703          	ld	a4,0(s2)
    80000928:	609c                	ld	a5,0(s1)
    8000092a:	02078793          	addi	a5,a5,32
    8000092e:	fee785e3          	beq	a5,a4,80000918 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000932:	00010497          	auipc	s1,0x10
    80000936:	1e648493          	addi	s1,s1,486 # 80010b18 <uart_tx_lock>
    8000093a:	01f77793          	andi	a5,a4,31
    8000093e:	97a6                	add	a5,a5,s1
    80000940:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000944:	0705                	addi	a4,a4,1
    80000946:	00008797          	auipc	a5,0x8
    8000094a:	f8e7bd23          	sd	a4,-102(a5) # 800088e0 <uart_tx_w>
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
    800009c0:	15c48493          	addi	s1,s1,348 # 80010b18 <uart_tx_lock>
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
    80000a02:	38278793          	addi	a5,a5,898 # 80022d80 <end>
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
    80000a22:	13290913          	addi	s2,s2,306 # 80010b50 <kmem>
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
    80000abe:	09650513          	addi	a0,a0,150 # 80010b50 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00022517          	auipc	a0,0x22
    80000ad2:	2b250513          	addi	a0,a0,690 # 80022d80 <end>
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
    80000af4:	06048493          	addi	s1,s1,96 # 80010b50 <kmem>
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
    80000b0c:	04850513          	addi	a0,a0,72 # 80010b50 <kmem>
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
    80000b38:	01c50513          	addi	a0,a0,28 # 80010b50 <kmem>
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
    80000e8c:	a6070713          	addi	a4,a4,-1440 # 800088e8 <started>
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
    80000ec2:	986080e7          	jalr	-1658(ra) # 80002844 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	00a080e7          	jalr	10(ra) # 80005ed0 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	ff2080e7          	jalr	-14(ra) # 80001ec0 <scheduler>
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
    80000f3a:	8e6080e7          	jalr	-1818(ra) # 8000281c <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	906080e7          	jalr	-1786(ra) # 80002844 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	f74080e7          	jalr	-140(ra) # 80005eba <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	f82080e7          	jalr	-126(ra) # 80005ed0 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	11e080e7          	jalr	286(ra) # 80003074 <binit>
    iinit();         // inode table
    80000f5e:	00002097          	auipc	ra,0x2
    80000f62:	7c2080e7          	jalr	1986(ra) # 80003720 <iinit>
    fileinit();      // file table
    80000f66:	00003097          	auipc	ra,0x3
    80000f6a:	760080e7          	jalr	1888(ra) # 800046c6 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	06a080e7          	jalr	106(ra) # 80005fd8 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	d2c080e7          	jalr	-724(ra) # 80001ca2 <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	96f72223          	sw	a5,-1692(a4) # 800088e8 <started>
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
    80000f9c:	9587b783          	ld	a5,-1704(a5) # 800088f0 <kernel_pagetable>
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
    80001258:	68a7be23          	sd	a0,1692(a5) # 800088f0 <kernel_pagetable>
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
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
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
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000184c:	0000f497          	auipc	s1,0xf
    80001850:	75448493          	addi	s1,s1,1876 # 80010fa0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001854:	8b26                	mv	s6,s1
    80001856:	00006a97          	auipc	s5,0x6
    8000185a:	7aaa8a93          	addi	s5,s5,1962 # 80008000 <etext>
    8000185e:	04000937          	lui	s2,0x4000
    80001862:	197d                	addi	s2,s2,-1
    80001864:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001866:	00016a17          	auipc	s4,0x16
    8000186a:	13aa0a13          	addi	s4,s4,314 # 800179a0 <tickslock>
    char *pa = kalloc();
    8000186e:	fffff097          	auipc	ra,0xfffff
    80001872:	278080e7          	jalr	632(ra) # 80000ae6 <kalloc>
    80001876:	862a                	mv	a2,a0
    if(pa == 0)
    80001878:	c131                	beqz	a0,800018bc <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
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
  for(p = proc; p < &proc[NPROC]; p++) {
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
void
procinit(void)
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
    800018ee:	28650513          	addi	a0,a0,646 # 80010b70 <pid_lock>
    800018f2:	fffff097          	auipc	ra,0xfffff
    800018f6:	254080e7          	jalr	596(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018fa:	00007597          	auipc	a1,0x7
    800018fe:	8ee58593          	addi	a1,a1,-1810 # 800081e8 <digits+0x1a8>
    80001902:	0000f517          	auipc	a0,0xf
    80001906:	28650513          	addi	a0,a0,646 # 80010b88 <wait_lock>
    8000190a:	fffff097          	auipc	ra,0xfffff
    8000190e:	23c080e7          	jalr	572(ra) # 80000b46 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001912:	0000f497          	auipc	s1,0xf
    80001916:	68e48493          	addi	s1,s1,1678 # 80010fa0 <proc>
      initlock(&p->lock, "proc");
    8000191a:	00007b97          	auipc	s7,0x7
    8000191e:	8deb8b93          	addi	s7,s7,-1826 # 800081f8 <digits+0x1b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001922:	8b26                	mv	s6,s1
    80001924:	00006a97          	auipc	s5,0x6
    80001928:	6dca8a93          	addi	s5,s5,1756 # 80008000 <etext>
    8000192c:	04000937          	lui	s2,0x4000
    80001930:	197d                	addi	s2,s2,-1
    80001932:	0932                	slli	s2,s2,0xc
      p->accumulator=0;
      p->ps_priority=5;
    80001934:	4a15                	li	s4,5
  for(p = proc; p < &proc[NPROC]; p++) {
    80001936:	00016997          	auipc	s3,0x16
    8000193a:	06a98993          	addi	s3,s3,106 # 800179a0 <tickslock>
      initlock(&p->lock, "proc");
    8000193e:	85de                	mv	a1,s7
    80001940:	8526                	mv	a0,s1
    80001942:	fffff097          	auipc	ra,0xfffff
    80001946:	204080e7          	jalr	516(ra) # 80000b46 <initlock>
      p->state = UNUSED;
    8000194a:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    8000194e:	416487b3          	sub	a5,s1,s6
    80001952:	878d                	srai	a5,a5,0x3
    80001954:	000ab703          	ld	a4,0(s5)
    80001958:	02e787b3          	mul	a5,a5,a4
    8000195c:	2785                	addiw	a5,a5,1
    8000195e:	00d7979b          	slliw	a5,a5,0xd
    80001962:	40f907b3          	sub	a5,s2,a5
    80001966:	e0dc                	sd	a5,128(s1)
      p->accumulator=0;
    80001968:	0604b023          	sd	zero,96(s1)
      p->ps_priority=5;
    8000196c:	0744b423          	sd	s4,104(s1)
      p->cfs_priority=0;
    80001970:	0604a823          	sw	zero,112(s1)
      p->rtime=0;
    80001974:	0604aa23          	sw	zero,116(s1)
      p->retime=0;
    80001978:	0604ae23          	sw	zero,124(s1)
      p->stime=0;
    8000197c:	0604ac23          	sw	zero,120(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
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
int
cpuid()
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
struct cpu*
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
    800019be:	1e650513          	addi	a0,a0,486 # 80010ba0 <cpus>
    800019c2:	953e                	add	a0,a0,a5
    800019c4:	6422                	ld	s0,8(sp)
    800019c6:	0141                	addi	sp,sp,16
    800019c8:	8082                	ret

00000000800019ca <myproc>:

// Return the current struct proc *, or zero if none.
struct proc* 
myproc(void)
{
    800019ca:	1101                	addi	sp,sp,-32
    800019cc:	ec06                	sd	ra,24(sp)
    800019ce:	e822                	sd	s0,16(sp)
    800019d0:	e426                	sd	s1,8(sp)
    800019d2:	1000                	addi	s0,sp,32
  push_off();
    800019d4:	fffff097          	auipc	ra,0xfffff
    800019d8:	1b6080e7          	jalr	438(ra) # 80000b8a <push_off>
    800019dc:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019de:	2781                	sext.w	a5,a5
    800019e0:	079e                	slli	a5,a5,0x7
    800019e2:	0000f717          	auipc	a4,0xf
    800019e6:	18e70713          	addi	a4,a4,398 # 80010b70 <pid_lock>
    800019ea:	97ba                	add	a5,a5,a4
    800019ec:	7b84                	ld	s1,48(a5)
  pop_off();
    800019ee:	fffff097          	auipc	ra,0xfffff
    800019f2:	23c080e7          	jalr	572(ra) # 80000c2a <pop_off>
  return p;
}
    800019f6:	8526                	mv	a0,s1
    800019f8:	60e2                	ld	ra,24(sp)
    800019fa:	6442                	ld	s0,16(sp)
    800019fc:	64a2                	ld	s1,8(sp)
    800019fe:	6105                	addi	sp,sp,32
    80001a00:	8082                	ret

0000000080001a02 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a02:	1141                	addi	sp,sp,-16
    80001a04:	e406                	sd	ra,8(sp)
    80001a06:	e022                	sd	s0,0(sp)
    80001a08:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a0a:	00000097          	auipc	ra,0x0
    80001a0e:	fc0080e7          	jalr	-64(ra) # 800019ca <myproc>
    80001a12:	fffff097          	auipc	ra,0xfffff
    80001a16:	278080e7          	jalr	632(ra) # 80000c8a <release>

  if (first) {
    80001a1a:	00007797          	auipc	a5,0x7
    80001a1e:	e467a783          	lw	a5,-442(a5) # 80008860 <first.1>
    80001a22:	eb89                	bnez	a5,80001a34 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a24:	00001097          	auipc	ra,0x1
    80001a28:	e38080e7          	jalr	-456(ra) # 8000285c <usertrapret>
}
    80001a2c:	60a2                	ld	ra,8(sp)
    80001a2e:	6402                	ld	s0,0(sp)
    80001a30:	0141                	addi	sp,sp,16
    80001a32:	8082                	ret
    first = 0;
    80001a34:	00007797          	auipc	a5,0x7
    80001a38:	e207a623          	sw	zero,-468(a5) # 80008860 <first.1>
    fsinit(ROOTDEV);
    80001a3c:	4505                	li	a0,1
    80001a3e:	00002097          	auipc	ra,0x2
    80001a42:	c62080e7          	jalr	-926(ra) # 800036a0 <fsinit>
    80001a46:	bff9                	j	80001a24 <forkret+0x22>

0000000080001a48 <allocpid>:
{
    80001a48:	1101                	addi	sp,sp,-32
    80001a4a:	ec06                	sd	ra,24(sp)
    80001a4c:	e822                	sd	s0,16(sp)
    80001a4e:	e426                	sd	s1,8(sp)
    80001a50:	e04a                	sd	s2,0(sp)
    80001a52:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a54:	0000f917          	auipc	s2,0xf
    80001a58:	11c90913          	addi	s2,s2,284 # 80010b70 <pid_lock>
    80001a5c:	854a                	mv	a0,s2
    80001a5e:	fffff097          	auipc	ra,0xfffff
    80001a62:	178080e7          	jalr	376(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001a66:	00007797          	auipc	a5,0x7
    80001a6a:	dfe78793          	addi	a5,a5,-514 # 80008864 <nextpid>
    80001a6e:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a70:	0014871b          	addiw	a4,s1,1
    80001a74:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a76:	854a                	mv	a0,s2
    80001a78:	fffff097          	auipc	ra,0xfffff
    80001a7c:	212080e7          	jalr	530(ra) # 80000c8a <release>
}
    80001a80:	8526                	mv	a0,s1
    80001a82:	60e2                	ld	ra,24(sp)
    80001a84:	6442                	ld	s0,16(sp)
    80001a86:	64a2                	ld	s1,8(sp)
    80001a88:	6902                	ld	s2,0(sp)
    80001a8a:	6105                	addi	sp,sp,32
    80001a8c:	8082                	ret

0000000080001a8e <proc_pagetable>:
{
    80001a8e:	1101                	addi	sp,sp,-32
    80001a90:	ec06                	sd	ra,24(sp)
    80001a92:	e822                	sd	s0,16(sp)
    80001a94:	e426                	sd	s1,8(sp)
    80001a96:	e04a                	sd	s2,0(sp)
    80001a98:	1000                	addi	s0,sp,32
    80001a9a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a9c:	00000097          	auipc	ra,0x0
    80001aa0:	88c080e7          	jalr	-1908(ra) # 80001328 <uvmcreate>
    80001aa4:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001aa6:	c121                	beqz	a0,80001ae6 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001aa8:	4729                	li	a4,10
    80001aaa:	00005697          	auipc	a3,0x5
    80001aae:	55668693          	addi	a3,a3,1366 # 80007000 <_trampoline>
    80001ab2:	6605                	lui	a2,0x1
    80001ab4:	040005b7          	lui	a1,0x4000
    80001ab8:	15fd                	addi	a1,a1,-1
    80001aba:	05b2                	slli	a1,a1,0xc
    80001abc:	fffff097          	auipc	ra,0xfffff
    80001ac0:	5e2080e7          	jalr	1506(ra) # 8000109e <mappages>
    80001ac4:	02054863          	bltz	a0,80001af4 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ac8:	4719                	li	a4,6
    80001aca:	09893683          	ld	a3,152(s2)
    80001ace:	6605                	lui	a2,0x1
    80001ad0:	020005b7          	lui	a1,0x2000
    80001ad4:	15fd                	addi	a1,a1,-1
    80001ad6:	05b6                	slli	a1,a1,0xd
    80001ad8:	8526                	mv	a0,s1
    80001ada:	fffff097          	auipc	ra,0xfffff
    80001ade:	5c4080e7          	jalr	1476(ra) # 8000109e <mappages>
    80001ae2:	02054163          	bltz	a0,80001b04 <proc_pagetable+0x76>
}
    80001ae6:	8526                	mv	a0,s1
    80001ae8:	60e2                	ld	ra,24(sp)
    80001aea:	6442                	ld	s0,16(sp)
    80001aec:	64a2                	ld	s1,8(sp)
    80001aee:	6902                	ld	s2,0(sp)
    80001af0:	6105                	addi	sp,sp,32
    80001af2:	8082                	ret
    uvmfree(pagetable, 0);
    80001af4:	4581                	li	a1,0
    80001af6:	8526                	mv	a0,s1
    80001af8:	00000097          	auipc	ra,0x0
    80001afc:	a34080e7          	jalr	-1484(ra) # 8000152c <uvmfree>
    return 0;
    80001b00:	4481                	li	s1,0
    80001b02:	b7d5                	j	80001ae6 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b04:	4681                	li	a3,0
    80001b06:	4605                	li	a2,1
    80001b08:	040005b7          	lui	a1,0x4000
    80001b0c:	15fd                	addi	a1,a1,-1
    80001b0e:	05b2                	slli	a1,a1,0xc
    80001b10:	8526                	mv	a0,s1
    80001b12:	fffff097          	auipc	ra,0xfffff
    80001b16:	752080e7          	jalr	1874(ra) # 80001264 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b1a:	4581                	li	a1,0
    80001b1c:	8526                	mv	a0,s1
    80001b1e:	00000097          	auipc	ra,0x0
    80001b22:	a0e080e7          	jalr	-1522(ra) # 8000152c <uvmfree>
    return 0;
    80001b26:	4481                	li	s1,0
    80001b28:	bf7d                	j	80001ae6 <proc_pagetable+0x58>

0000000080001b2a <proc_freepagetable>:
{
    80001b2a:	1101                	addi	sp,sp,-32
    80001b2c:	ec06                	sd	ra,24(sp)
    80001b2e:	e822                	sd	s0,16(sp)
    80001b30:	e426                	sd	s1,8(sp)
    80001b32:	e04a                	sd	s2,0(sp)
    80001b34:	1000                	addi	s0,sp,32
    80001b36:	84aa                	mv	s1,a0
    80001b38:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b3a:	4681                	li	a3,0
    80001b3c:	4605                	li	a2,1
    80001b3e:	040005b7          	lui	a1,0x4000
    80001b42:	15fd                	addi	a1,a1,-1
    80001b44:	05b2                	slli	a1,a1,0xc
    80001b46:	fffff097          	auipc	ra,0xfffff
    80001b4a:	71e080e7          	jalr	1822(ra) # 80001264 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b4e:	4681                	li	a3,0
    80001b50:	4605                	li	a2,1
    80001b52:	020005b7          	lui	a1,0x2000
    80001b56:	15fd                	addi	a1,a1,-1
    80001b58:	05b6                	slli	a1,a1,0xd
    80001b5a:	8526                	mv	a0,s1
    80001b5c:	fffff097          	auipc	ra,0xfffff
    80001b60:	708080e7          	jalr	1800(ra) # 80001264 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b64:	85ca                	mv	a1,s2
    80001b66:	8526                	mv	a0,s1
    80001b68:	00000097          	auipc	ra,0x0
    80001b6c:	9c4080e7          	jalr	-1596(ra) # 8000152c <uvmfree>
}
    80001b70:	60e2                	ld	ra,24(sp)
    80001b72:	6442                	ld	s0,16(sp)
    80001b74:	64a2                	ld	s1,8(sp)
    80001b76:	6902                	ld	s2,0(sp)
    80001b78:	6105                	addi	sp,sp,32
    80001b7a:	8082                	ret

0000000080001b7c <freeproc>:
{
    80001b7c:	1101                	addi	sp,sp,-32
    80001b7e:	ec06                	sd	ra,24(sp)
    80001b80:	e822                	sd	s0,16(sp)
    80001b82:	e426                	sd	s1,8(sp)
    80001b84:	1000                	addi	s0,sp,32
    80001b86:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b88:	6d48                	ld	a0,152(a0)
    80001b8a:	c509                	beqz	a0,80001b94 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b8c:	fffff097          	auipc	ra,0xfffff
    80001b90:	e5e080e7          	jalr	-418(ra) # 800009ea <kfree>
  p->trapframe = 0;
    80001b94:	0804bc23          	sd	zero,152(s1)
  if(p->pagetable)
    80001b98:	68c8                	ld	a0,144(s1)
    80001b9a:	c511                	beqz	a0,80001ba6 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b9c:	64cc                	ld	a1,136(s1)
    80001b9e:	00000097          	auipc	ra,0x0
    80001ba2:	f8c080e7          	jalr	-116(ra) # 80001b2a <proc_freepagetable>
  p->pagetable = 0;
    80001ba6:	0804b823          	sd	zero,144(s1)
  p->sz = 0;
    80001baa:	0804b423          	sd	zero,136(s1)
  p->pid = 0;
    80001bae:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001bb2:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001bb6:	18048c23          	sb	zero,408(s1)
  p->chan = 0;
    80001bba:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bbe:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bc2:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bc6:	0004ac23          	sw	zero,24(s1)
}
    80001bca:	60e2                	ld	ra,24(sp)
    80001bcc:	6442                	ld	s0,16(sp)
    80001bce:	64a2                	ld	s1,8(sp)
    80001bd0:	6105                	addi	sp,sp,32
    80001bd2:	8082                	ret

0000000080001bd4 <allocproc>:
{
    80001bd4:	1101                	addi	sp,sp,-32
    80001bd6:	ec06                	sd	ra,24(sp)
    80001bd8:	e822                	sd	s0,16(sp)
    80001bda:	e426                	sd	s1,8(sp)
    80001bdc:	e04a                	sd	s2,0(sp)
    80001bde:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001be0:	0000f497          	auipc	s1,0xf
    80001be4:	3c048493          	addi	s1,s1,960 # 80010fa0 <proc>
    80001be8:	00016917          	auipc	s2,0x16
    80001bec:	db890913          	addi	s2,s2,-584 # 800179a0 <tickslock>
    acquire(&p->lock);
    80001bf0:	8526                	mv	a0,s1
    80001bf2:	fffff097          	auipc	ra,0xfffff
    80001bf6:	fe4080e7          	jalr	-28(ra) # 80000bd6 <acquire>
    if(p->state == UNUSED) {
    80001bfa:	4c9c                	lw	a5,24(s1)
    80001bfc:	cf81                	beqz	a5,80001c14 <allocproc+0x40>
      release(&p->lock);
    80001bfe:	8526                	mv	a0,s1
    80001c00:	fffff097          	auipc	ra,0xfffff
    80001c04:	08a080e7          	jalr	138(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c08:	1a848493          	addi	s1,s1,424
    80001c0c:	ff2492e3          	bne	s1,s2,80001bf0 <allocproc+0x1c>
  return 0;
    80001c10:	4481                	li	s1,0
    80001c12:	a889                	j	80001c64 <allocproc+0x90>
  p->pid = allocpid();
    80001c14:	00000097          	auipc	ra,0x0
    80001c18:	e34080e7          	jalr	-460(ra) # 80001a48 <allocpid>
    80001c1c:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c1e:	4785                	li	a5,1
    80001c20:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c22:	fffff097          	auipc	ra,0xfffff
    80001c26:	ec4080e7          	jalr	-316(ra) # 80000ae6 <kalloc>
    80001c2a:	892a                	mv	s2,a0
    80001c2c:	ecc8                	sd	a0,152(s1)
    80001c2e:	c131                	beqz	a0,80001c72 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001c30:	8526                	mv	a0,s1
    80001c32:	00000097          	auipc	ra,0x0
    80001c36:	e5c080e7          	jalr	-420(ra) # 80001a8e <proc_pagetable>
    80001c3a:	892a                	mv	s2,a0
    80001c3c:	e8c8                	sd	a0,144(s1)
  if(p->pagetable == 0){
    80001c3e:	c531                	beqz	a0,80001c8a <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001c40:	07000613          	li	a2,112
    80001c44:	4581                	li	a1,0
    80001c46:	0a048513          	addi	a0,s1,160
    80001c4a:	fffff097          	auipc	ra,0xfffff
    80001c4e:	088080e7          	jalr	136(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001c52:	00000797          	auipc	a5,0x0
    80001c56:	db078793          	addi	a5,a5,-592 # 80001a02 <forkret>
    80001c5a:	f0dc                	sd	a5,160(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c5c:	60dc                	ld	a5,128(s1)
    80001c5e:	6705                	lui	a4,0x1
    80001c60:	97ba                	add	a5,a5,a4
    80001c62:	f4dc                	sd	a5,168(s1)
}
    80001c64:	8526                	mv	a0,s1
    80001c66:	60e2                	ld	ra,24(sp)
    80001c68:	6442                	ld	s0,16(sp)
    80001c6a:	64a2                	ld	s1,8(sp)
    80001c6c:	6902                	ld	s2,0(sp)
    80001c6e:	6105                	addi	sp,sp,32
    80001c70:	8082                	ret
    freeproc(p);
    80001c72:	8526                	mv	a0,s1
    80001c74:	00000097          	auipc	ra,0x0
    80001c78:	f08080e7          	jalr	-248(ra) # 80001b7c <freeproc>
    release(&p->lock);
    80001c7c:	8526                	mv	a0,s1
    80001c7e:	fffff097          	auipc	ra,0xfffff
    80001c82:	00c080e7          	jalr	12(ra) # 80000c8a <release>
    return 0;
    80001c86:	84ca                	mv	s1,s2
    80001c88:	bff1                	j	80001c64 <allocproc+0x90>
    freeproc(p);
    80001c8a:	8526                	mv	a0,s1
    80001c8c:	00000097          	auipc	ra,0x0
    80001c90:	ef0080e7          	jalr	-272(ra) # 80001b7c <freeproc>
    release(&p->lock);
    80001c94:	8526                	mv	a0,s1
    80001c96:	fffff097          	auipc	ra,0xfffff
    80001c9a:	ff4080e7          	jalr	-12(ra) # 80000c8a <release>
    return 0;
    80001c9e:	84ca                	mv	s1,s2
    80001ca0:	b7d1                	j	80001c64 <allocproc+0x90>

0000000080001ca2 <userinit>:
{
    80001ca2:	1101                	addi	sp,sp,-32
    80001ca4:	ec06                	sd	ra,24(sp)
    80001ca6:	e822                	sd	s0,16(sp)
    80001ca8:	e426                	sd	s1,8(sp)
    80001caa:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cac:	00000097          	auipc	ra,0x0
    80001cb0:	f28080e7          	jalr	-216(ra) # 80001bd4 <allocproc>
    80001cb4:	84aa                	mv	s1,a0
  initproc = p;
    80001cb6:	00007797          	auipc	a5,0x7
    80001cba:	c4a7b123          	sd	a0,-958(a5) # 800088f8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cbe:	03400613          	li	a2,52
    80001cc2:	00007597          	auipc	a1,0x7
    80001cc6:	bae58593          	addi	a1,a1,-1106 # 80008870 <initcode>
    80001cca:	6948                	ld	a0,144(a0)
    80001ccc:	fffff097          	auipc	ra,0xfffff
    80001cd0:	68a080e7          	jalr	1674(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80001cd4:	6785                	lui	a5,0x1
    80001cd6:	e4dc                	sd	a5,136(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cd8:	6cd8                	ld	a4,152(s1)
    80001cda:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cde:	6cd8                	ld	a4,152(s1)
    80001ce0:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001ce2:	4641                	li	a2,16
    80001ce4:	00006597          	auipc	a1,0x6
    80001ce8:	51c58593          	addi	a1,a1,1308 # 80008200 <digits+0x1c0>
    80001cec:	19848513          	addi	a0,s1,408
    80001cf0:	fffff097          	auipc	ra,0xfffff
    80001cf4:	12c080e7          	jalr	300(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001cf8:	00006517          	auipc	a0,0x6
    80001cfc:	51850513          	addi	a0,a0,1304 # 80008210 <digits+0x1d0>
    80001d00:	00002097          	auipc	ra,0x2
    80001d04:	3c2080e7          	jalr	962(ra) # 800040c2 <namei>
    80001d08:	18a4b823          	sd	a0,400(s1)
  p->state = RUNNABLE;
    80001d0c:	478d                	li	a5,3
    80001d0e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d10:	8526                	mv	a0,s1
    80001d12:	fffff097          	auipc	ra,0xfffff
    80001d16:	f78080e7          	jalr	-136(ra) # 80000c8a <release>
}
    80001d1a:	60e2                	ld	ra,24(sp)
    80001d1c:	6442                	ld	s0,16(sp)
    80001d1e:	64a2                	ld	s1,8(sp)
    80001d20:	6105                	addi	sp,sp,32
    80001d22:	8082                	ret

0000000080001d24 <growproc>:
{
    80001d24:	1101                	addi	sp,sp,-32
    80001d26:	ec06                	sd	ra,24(sp)
    80001d28:	e822                	sd	s0,16(sp)
    80001d2a:	e426                	sd	s1,8(sp)
    80001d2c:	e04a                	sd	s2,0(sp)
    80001d2e:	1000                	addi	s0,sp,32
    80001d30:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d32:	00000097          	auipc	ra,0x0
    80001d36:	c98080e7          	jalr	-872(ra) # 800019ca <myproc>
    80001d3a:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d3c:	654c                	ld	a1,136(a0)
  if(n > 0){
    80001d3e:	01204c63          	bgtz	s2,80001d56 <growproc+0x32>
  } else if(n < 0){
    80001d42:	02094663          	bltz	s2,80001d6e <growproc+0x4a>
  p->sz = sz;
    80001d46:	e4cc                	sd	a1,136(s1)
  return 0;
    80001d48:	4501                	li	a0,0
}
    80001d4a:	60e2                	ld	ra,24(sp)
    80001d4c:	6442                	ld	s0,16(sp)
    80001d4e:	64a2                	ld	s1,8(sp)
    80001d50:	6902                	ld	s2,0(sp)
    80001d52:	6105                	addi	sp,sp,32
    80001d54:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d56:	4691                	li	a3,4
    80001d58:	00b90633          	add	a2,s2,a1
    80001d5c:	6948                	ld	a0,144(a0)
    80001d5e:	fffff097          	auipc	ra,0xfffff
    80001d62:	6b2080e7          	jalr	1714(ra) # 80001410 <uvmalloc>
    80001d66:	85aa                	mv	a1,a0
    80001d68:	fd79                	bnez	a0,80001d46 <growproc+0x22>
      return -1;
    80001d6a:	557d                	li	a0,-1
    80001d6c:	bff9                	j	80001d4a <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d6e:	00b90633          	add	a2,s2,a1
    80001d72:	6948                	ld	a0,144(a0)
    80001d74:	fffff097          	auipc	ra,0xfffff
    80001d78:	654080e7          	jalr	1620(ra) # 800013c8 <uvmdealloc>
    80001d7c:	85aa                	mv	a1,a0
    80001d7e:	b7e1                	j	80001d46 <growproc+0x22>

0000000080001d80 <fork>:
{
    80001d80:	7139                	addi	sp,sp,-64
    80001d82:	fc06                	sd	ra,56(sp)
    80001d84:	f822                	sd	s0,48(sp)
    80001d86:	f426                	sd	s1,40(sp)
    80001d88:	f04a                	sd	s2,32(sp)
    80001d8a:	ec4e                	sd	s3,24(sp)
    80001d8c:	e852                	sd	s4,16(sp)
    80001d8e:	e456                	sd	s5,8(sp)
    80001d90:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d92:	00000097          	auipc	ra,0x0
    80001d96:	c38080e7          	jalr	-968(ra) # 800019ca <myproc>
    80001d9a:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001d9c:	00000097          	auipc	ra,0x0
    80001da0:	e38080e7          	jalr	-456(ra) # 80001bd4 <allocproc>
    80001da4:	10050c63          	beqz	a0,80001ebc <fork+0x13c>
    80001da8:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001daa:	088ab603          	ld	a2,136(s5)
    80001dae:	694c                	ld	a1,144(a0)
    80001db0:	090ab503          	ld	a0,144(s5)
    80001db4:	fffff097          	auipc	ra,0xfffff
    80001db8:	7b0080e7          	jalr	1968(ra) # 80001564 <uvmcopy>
    80001dbc:	04054863          	bltz	a0,80001e0c <fork+0x8c>
  np->sz = p->sz;
    80001dc0:	088ab783          	ld	a5,136(s5)
    80001dc4:	08fa3423          	sd	a5,136(s4)
  *(np->trapframe) = *(p->trapframe);
    80001dc8:	098ab683          	ld	a3,152(s5)
    80001dcc:	87b6                	mv	a5,a3
    80001dce:	098a3703          	ld	a4,152(s4)
    80001dd2:	12068693          	addi	a3,a3,288
    80001dd6:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001dda:	6788                	ld	a0,8(a5)
    80001ddc:	6b8c                	ld	a1,16(a5)
    80001dde:	6f90                	ld	a2,24(a5)
    80001de0:	01073023          	sd	a6,0(a4)
    80001de4:	e708                	sd	a0,8(a4)
    80001de6:	eb0c                	sd	a1,16(a4)
    80001de8:	ef10                	sd	a2,24(a4)
    80001dea:	02078793          	addi	a5,a5,32
    80001dee:	02070713          	addi	a4,a4,32
    80001df2:	fed792e3          	bne	a5,a3,80001dd6 <fork+0x56>
  np->trapframe->a0 = 0;
    80001df6:	098a3783          	ld	a5,152(s4)
    80001dfa:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001dfe:	110a8493          	addi	s1,s5,272
    80001e02:	110a0913          	addi	s2,s4,272
    80001e06:	190a8993          	addi	s3,s5,400
    80001e0a:	a00d                	j	80001e2c <fork+0xac>
    freeproc(np);
    80001e0c:	8552                	mv	a0,s4
    80001e0e:	00000097          	auipc	ra,0x0
    80001e12:	d6e080e7          	jalr	-658(ra) # 80001b7c <freeproc>
    release(&np->lock);
    80001e16:	8552                	mv	a0,s4
    80001e18:	fffff097          	auipc	ra,0xfffff
    80001e1c:	e72080e7          	jalr	-398(ra) # 80000c8a <release>
    return -1;
    80001e20:	597d                	li	s2,-1
    80001e22:	a059                	j	80001ea8 <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001e24:	04a1                	addi	s1,s1,8
    80001e26:	0921                	addi	s2,s2,8
    80001e28:	01348b63          	beq	s1,s3,80001e3e <fork+0xbe>
    if(p->ofile[i])
    80001e2c:	6088                	ld	a0,0(s1)
    80001e2e:	d97d                	beqz	a0,80001e24 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e30:	00003097          	auipc	ra,0x3
    80001e34:	928080e7          	jalr	-1752(ra) # 80004758 <filedup>
    80001e38:	00a93023          	sd	a0,0(s2)
    80001e3c:	b7e5                	j	80001e24 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e3e:	190ab503          	ld	a0,400(s5)
    80001e42:	00002097          	auipc	ra,0x2
    80001e46:	a9c080e7          	jalr	-1380(ra) # 800038de <idup>
    80001e4a:	18aa3823          	sd	a0,400(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e4e:	4641                	li	a2,16
    80001e50:	198a8593          	addi	a1,s5,408
    80001e54:	198a0513          	addi	a0,s4,408
    80001e58:	fffff097          	auipc	ra,0xfffff
    80001e5c:	fc4080e7          	jalr	-60(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    80001e60:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e64:	8552                	mv	a0,s4
    80001e66:	fffff097          	auipc	ra,0xfffff
    80001e6a:	e24080e7          	jalr	-476(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80001e6e:	0000f497          	auipc	s1,0xf
    80001e72:	d1a48493          	addi	s1,s1,-742 # 80010b88 <wait_lock>
    80001e76:	8526                	mv	a0,s1
    80001e78:	fffff097          	auipc	ra,0xfffff
    80001e7c:	d5e080e7          	jalr	-674(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001e80:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001e84:	8526                	mv	a0,s1
    80001e86:	fffff097          	auipc	ra,0xfffff
    80001e8a:	e04080e7          	jalr	-508(ra) # 80000c8a <release>
  acquire(&np->lock);
    80001e8e:	8552                	mv	a0,s4
    80001e90:	fffff097          	auipc	ra,0xfffff
    80001e94:	d46080e7          	jalr	-698(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80001e98:	478d                	li	a5,3
    80001e9a:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001e9e:	8552                	mv	a0,s4
    80001ea0:	fffff097          	auipc	ra,0xfffff
    80001ea4:	dea080e7          	jalr	-534(ra) # 80000c8a <release>
}
    80001ea8:	854a                	mv	a0,s2
    80001eaa:	70e2                	ld	ra,56(sp)
    80001eac:	7442                	ld	s0,48(sp)
    80001eae:	74a2                	ld	s1,40(sp)
    80001eb0:	7902                	ld	s2,32(sp)
    80001eb2:	69e2                	ld	s3,24(sp)
    80001eb4:	6a42                	ld	s4,16(sp)
    80001eb6:	6aa2                	ld	s5,8(sp)
    80001eb8:	6121                	addi	sp,sp,64
    80001eba:	8082                	ret
    return -1;
    80001ebc:	597d                	li	s2,-1
    80001ebe:	b7ed                	j	80001ea8 <fork+0x128>

0000000080001ec0 <scheduler>:
{
    80001ec0:	7135                	addi	sp,sp,-160
    80001ec2:	ed06                	sd	ra,152(sp)
    80001ec4:	e922                	sd	s0,144(sp)
    80001ec6:	e526                	sd	s1,136(sp)
    80001ec8:	e14a                	sd	s2,128(sp)
    80001eca:	fcce                	sd	s3,120(sp)
    80001ecc:	f8d2                	sd	s4,112(sp)
    80001ece:	f4d6                	sd	s5,104(sp)
    80001ed0:	f0da                	sd	s6,96(sp)
    80001ed2:	ecde                	sd	s7,88(sp)
    80001ed4:	e8e2                	sd	s8,80(sp)
    80001ed6:	e4e6                	sd	s9,72(sp)
    80001ed8:	e0ea                	sd	s10,64(sp)
    80001eda:	fc6e                	sd	s11,56(sp)
    80001edc:	1100                	addi	s0,sp,160
    80001ede:	8492                	mv	s1,tp
  int id = r_tp();
    80001ee0:	2481                	sext.w	s1,s1
  initlock(&counter,"counter");
    80001ee2:	00006597          	auipc	a1,0x6
    80001ee6:	33658593          	addi	a1,a1,822 # 80008218 <digits+0x1d8>
    80001eea:	f7840513          	addi	a0,s0,-136
    80001eee:	fffff097          	auipc	ra,0xfffff
    80001ef2:	c58080e7          	jalr	-936(ra) # 80000b46 <initlock>
  c->proc = 0;
    80001ef6:	00749713          	slli	a4,s1,0x7
    80001efa:	0000f797          	auipc	a5,0xf
    80001efe:	c7678793          	addi	a5,a5,-906 # 80010b70 <pid_lock>
    80001f02:	97ba                	add	a5,a5,a4
    80001f04:	0207b823          	sd	zero,48(a5)
        swtch(&c->context, &min_proc->context);
    80001f08:	0000f797          	auipc	a5,0xf
    80001f0c:	ca078793          	addi	a5,a5,-864 # 80010ba8 <cpus+0x8>
    80001f10:	97ba                	add	a5,a5,a4
    80001f12:	f6f43423          	sd	a5,-152(s0)
  int min_vruntime=__INT_MAX__;
    80001f16:	80000cb7          	lui	s9,0x80000
    80001f1a:	fffccc93          	not	s9,s9
  int decay_factor=100;
    80001f1e:	06400993          	li	s3,100
    if (sched_policy==0){
    80001f22:	00007d97          	auipc	s11,0x7
    80001f26:	946d8d93          	addi	s11,s11,-1722 # 80008868 <sched_policy>
        c->proc = min_proc;
    80001f2a:	0000f797          	auipc	a5,0xf
    80001f2e:	c4678793          	addi	a5,a5,-954 # 80010b70 <pid_lock>
    80001f32:	97ba                	add	a5,a5,a4
    80001f34:	f6f43023          	sd	a5,-160(s0)
      for (p = proc; p < &proc[NPROC]; p++){
    80001f38:	00016917          	auipc	s2,0x16
    80001f3c:	a6890913          	addi	s2,s2,-1432 # 800179a0 <tickslock>
      if (p->state == RUNNABLE && (p->accumulator < min_accumulator||proc_counter==0)) {
    80001f40:	00007c17          	auipc	s8,0x7
    80001f44:	92cc0c13          	addi	s8,s8,-1748 # 8000886c <min_accumulator>
    80001f48:	aa1d                	j	8000207e <scheduler+0x1be>
    acquire(&counter);
    80001f4a:	f7840513          	addi	a0,s0,-136
    80001f4e:	fffff097          	auipc	ra,0xfffff
    80001f52:	c88080e7          	jalr	-888(ra) # 80000bd6 <acquire>
    release(&counter);
    80001f56:	f7840513          	addi	a0,s0,-136
    80001f5a:	fffff097          	auipc	ra,0xfffff
    80001f5e:	d30080e7          	jalr	-720(ra) # 80000c8a <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001f62:	0000f497          	auipc	s1,0xf
    80001f66:	03e48493          	addi	s1,s1,62 # 80010fa0 <proc>
      if (p->state == RUNNABLE && (p->accumulator < min_accumulator||proc_counter==0)) {
    80001f6a:	4a0d                	li	s4,3
    80001f6c:	a81d                	j	80001fa2 <scheduler+0xe2>
        acquire(&counter);
    80001f6e:	f7840513          	addi	a0,s0,-136
    80001f72:	fffff097          	auipc	ra,0xfffff
    80001f76:	c64080e7          	jalr	-924(ra) # 80000bd6 <acquire>
        proc_counter++;
    80001f7a:	2a85                	addiw	s5,s5,1
        release(&counter);
    80001f7c:	f7840513          	addi	a0,s0,-136
    80001f80:	fffff097          	auipc	ra,0xfffff
    80001f84:	d0a080e7          	jalr	-758(ra) # 80000c8a <release>
        min_accumulator = p->accumulator;
    80001f88:	70bc                	ld	a5,96(s1)
    80001f8a:	00fc2023          	sw	a5,0(s8)
    80001f8e:	8ba6                	mv	s7,s1
      release(&p->lock);
    80001f90:	8526                	mv	a0,s1
    80001f92:	fffff097          	auipc	ra,0xfffff
    80001f96:	cf8080e7          	jalr	-776(ra) # 80000c8a <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001f9a:	1a848493          	addi	s1,s1,424
    80001f9e:	03248263          	beq	s1,s2,80001fc2 <scheduler+0x102>
      acquire(&p->lock);
    80001fa2:	8526                	mv	a0,s1
    80001fa4:	fffff097          	auipc	ra,0xfffff
    80001fa8:	c32080e7          	jalr	-974(ra) # 80000bd6 <acquire>
      if (p->state == RUNNABLE && (p->accumulator < min_accumulator||proc_counter==0)) {
    80001fac:	4c9c                	lw	a5,24(s1)
    80001fae:	ff4791e3          	bne	a5,s4,80001f90 <scheduler+0xd0>
    80001fb2:	000c2783          	lw	a5,0(s8)
    80001fb6:	70b8                	ld	a4,96(s1)
    80001fb8:	faf74be3          	blt	a4,a5,80001f6e <scheduler+0xae>
    80001fbc:	fc0a9ae3          	bnez	s5,80001f90 <scheduler+0xd0>
    80001fc0:	b77d                	j	80001f6e <scheduler+0xae>
    if(min_proc!=0){
    80001fc2:	0c0b8963          	beqz	s7,80002094 <scheduler+0x1d4>
      if(proc_counter==1){
    80001fc6:	4785                	li	a5,1
    80001fc8:	00fa8863          	beq	s5,a5,80001fd8 <scheduler+0x118>
    if (sched_policy==1){
    80001fcc:	000da703          	lw	a4,0(s11)
    80001fd0:	4785                	li	a5,1
    80001fd2:	06f71563          	bne	a4,a5,8000203c <scheduler+0x17c>
    80001fd6:	a0e1                	j	8000209e <scheduler+0x1de>
        min_proc->accumulator=0;
    80001fd8:	060bb023          	sd	zero,96(s7)
    80001fdc:	bfc5                	j	80001fcc <scheduler+0x10c>
        switch(p->cfs_priority){
    80001fde:	04b00993          	li	s3,75
    80001fe2:	a815                	j	80002016 <scheduler+0x156>
            decay_factor=100;
    80001fe4:	06400993          	li	s3,100
    80001fe8:	a03d                	j	80002016 <scheduler+0x156>
            decay_factor=125;
    80001fea:	89ea                	mv	s3,s10
    80001fec:	a02d                	j	80002016 <scheduler+0x156>
        release(&p->lock);
    80001fee:	8526                	mv	a0,s1
    80001ff0:	fffff097          	auipc	ra,0xfffff
    80001ff4:	c9a080e7          	jalr	-870(ra) # 80000c8a <release>
      for (p = proc; p < &proc[NPROC]; p++){
    80001ff8:	1a848493          	addi	s1,s1,424
    80001ffc:	03248e63          	beq	s1,s2,80002038 <scheduler+0x178>
        acquire(&p->lock);
    80002000:	8526                	mv	a0,s1
    80002002:	fffff097          	auipc	ra,0xfffff
    80002006:	bd4080e7          	jalr	-1068(ra) # 80000bd6 <acquire>
        switch(p->cfs_priority){
    8000200a:	58bc                	lw	a5,112(s1)
    8000200c:	fd678ce3          	beq	a5,s6,80001fe4 <scheduler+0x124>
    80002010:	fd578de3          	beq	a5,s5,80001fea <scheduler+0x12a>
    80002014:	d7e9                	beqz	a5,80001fde <scheduler+0x11e>
        vruntime=decay_factor*(p->rtime)/(p->rtime+p->stime+p->retime);
    80002016:	58fc                	lw	a5,116(s1)
    80002018:	5cb0                	lw	a2,120(s1)
    8000201a:	5cf4                	lw	a3,124(s1)
        if(p->state==RUNNABLE && vruntime<=min_vruntime){
    8000201c:	4c98                	lw	a4,24(s1)
    8000201e:	fd4718e3          	bne	a4,s4,80001fee <scheduler+0x12e>
        vruntime=decay_factor*(p->rtime)/(p->rtime+p->stime+p->retime);
    80002022:	0337873b          	mulw	a4,a5,s3
    80002026:	9fb1                	addw	a5,a5,a2
    80002028:	9fb5                	addw	a5,a5,a3
    8000202a:	02f747bb          	divw	a5,a4,a5
        if(p->state==RUNNABLE && vruntime<=min_vruntime){
    8000202e:	fcfcc0e3          	blt	s9,a5,80001fee <scheduler+0x12e>
          min_vruntime=vruntime;
    80002032:	8cbe                	mv	s9,a5
        if(p->state==RUNNABLE && vruntime<=min_vruntime){
    80002034:	8ba6                	mv	s7,s1
    80002036:	bf65                	j	80001fee <scheduler+0x12e>
    if(min_proc!=0){
    80002038:	040b8363          	beqz	s7,8000207e <scheduler+0x1be>
      acquire(&min_proc->lock);
    8000203c:	84de                	mv	s1,s7
    8000203e:	855e                	mv	a0,s7
    80002040:	fffff097          	auipc	ra,0xfffff
    80002044:	b96080e7          	jalr	-1130(ra) # 80000bd6 <acquire>
      if (min_proc->state==RUNNABLE){
    80002048:	018ba703          	lw	a4,24(s7)
    8000204c:	478d                	li	a5,3
    8000204e:	02f71363          	bne	a4,a5,80002074 <scheduler+0x1b4>
        min_proc->state = RUNNING;
    80002052:	4791                	li	a5,4
    80002054:	00fbac23          	sw	a5,24(s7)
        c->proc = min_proc;
    80002058:	f6043a03          	ld	s4,-160(s0)
    8000205c:	037a3823          	sd	s7,48(s4)
        swtch(&c->context, &min_proc->context);
    80002060:	0a0b8593          	addi	a1,s7,160
    80002064:	f6843503          	ld	a0,-152(s0)
    80002068:	00000097          	auipc	ra,0x0
    8000206c:	74a080e7          	jalr	1866(ra) # 800027b2 <swtch>
        c->proc = 0;
    80002070:	020a3823          	sd	zero,48(s4)
      release(&min_proc->lock);
    80002074:	8526                	mv	a0,s1
    80002076:	fffff097          	auipc	ra,0xfffff
    8000207a:	c14080e7          	jalr	-1004(ra) # 80000c8a <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000207e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002082:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002086:	10079073          	csrw	sstatus,a5
    if (sched_policy==0){
    8000208a:	000daa83          	lw	s5,0(s11)
    min_proc = 0;
    8000208e:	4b81                	li	s7,0
    if (sched_policy==0){
    80002090:	ea0a8de3          	beqz	s5,80001f4a <scheduler+0x8a>
    if (sched_policy==1){
    80002094:	000da703          	lw	a4,0(s11)
    80002098:	4785                	li	a5,1
    8000209a:	fef712e3          	bne	a4,a5,8000207e <scheduler+0x1be>
      for (p = proc; p < &proc[NPROC]; p++){
    8000209e:	0000f497          	auipc	s1,0xf
    800020a2:	f0248493          	addi	s1,s1,-254 # 80010fa0 <proc>
        switch(p->cfs_priority){
    800020a6:	4b05                	li	s6,1
    800020a8:	4a89                	li	s5,2
            decay_factor=125;
    800020aa:	07d00d13          	li	s10,125
        if(p->state==RUNNABLE && vruntime<=min_vruntime){
    800020ae:	4a0d                	li	s4,3
    800020b0:	bf81                	j	80002000 <scheduler+0x140>

00000000800020b2 <sched>:
{
    800020b2:	7179                	addi	sp,sp,-48
    800020b4:	f406                	sd	ra,40(sp)
    800020b6:	f022                	sd	s0,32(sp)
    800020b8:	ec26                	sd	s1,24(sp)
    800020ba:	e84a                	sd	s2,16(sp)
    800020bc:	e44e                	sd	s3,8(sp)
    800020be:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800020c0:	00000097          	auipc	ra,0x0
    800020c4:	90a080e7          	jalr	-1782(ra) # 800019ca <myproc>
    800020c8:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800020ca:	fffff097          	auipc	ra,0xfffff
    800020ce:	a92080e7          	jalr	-1390(ra) # 80000b5c <holding>
    800020d2:	c93d                	beqz	a0,80002148 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020d4:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800020d6:	2781                	sext.w	a5,a5
    800020d8:	079e                	slli	a5,a5,0x7
    800020da:	0000f717          	auipc	a4,0xf
    800020de:	a9670713          	addi	a4,a4,-1386 # 80010b70 <pid_lock>
    800020e2:	97ba                	add	a5,a5,a4
    800020e4:	0a87a703          	lw	a4,168(a5)
    800020e8:	4785                	li	a5,1
    800020ea:	06f71763          	bne	a4,a5,80002158 <sched+0xa6>
  if(p->state == RUNNING)
    800020ee:	4c98                	lw	a4,24(s1)
    800020f0:	4791                	li	a5,4
    800020f2:	06f70b63          	beq	a4,a5,80002168 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020f6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800020fa:	8b89                	andi	a5,a5,2
  if(intr_get())
    800020fc:	efb5                	bnez	a5,80002178 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020fe:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002100:	0000f917          	auipc	s2,0xf
    80002104:	a7090913          	addi	s2,s2,-1424 # 80010b70 <pid_lock>
    80002108:	2781                	sext.w	a5,a5
    8000210a:	079e                	slli	a5,a5,0x7
    8000210c:	97ca                	add	a5,a5,s2
    8000210e:	0ac7a983          	lw	s3,172(a5)
    80002112:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002114:	2781                	sext.w	a5,a5
    80002116:	079e                	slli	a5,a5,0x7
    80002118:	0000f597          	auipc	a1,0xf
    8000211c:	a9058593          	addi	a1,a1,-1392 # 80010ba8 <cpus+0x8>
    80002120:	95be                	add	a1,a1,a5
    80002122:	0a048513          	addi	a0,s1,160
    80002126:	00000097          	auipc	ra,0x0
    8000212a:	68c080e7          	jalr	1676(ra) # 800027b2 <swtch>
    8000212e:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002130:	2781                	sext.w	a5,a5
    80002132:	079e                	slli	a5,a5,0x7
    80002134:	97ca                	add	a5,a5,s2
    80002136:	0b37a623          	sw	s3,172(a5)
}
    8000213a:	70a2                	ld	ra,40(sp)
    8000213c:	7402                	ld	s0,32(sp)
    8000213e:	64e2                	ld	s1,24(sp)
    80002140:	6942                	ld	s2,16(sp)
    80002142:	69a2                	ld	s3,8(sp)
    80002144:	6145                	addi	sp,sp,48
    80002146:	8082                	ret
    panic("sched p->lock");
    80002148:	00006517          	auipc	a0,0x6
    8000214c:	0d850513          	addi	a0,a0,216 # 80008220 <digits+0x1e0>
    80002150:	ffffe097          	auipc	ra,0xffffe
    80002154:	3ee080e7          	jalr	1006(ra) # 8000053e <panic>
    panic("sched locks");
    80002158:	00006517          	auipc	a0,0x6
    8000215c:	0d850513          	addi	a0,a0,216 # 80008230 <digits+0x1f0>
    80002160:	ffffe097          	auipc	ra,0xffffe
    80002164:	3de080e7          	jalr	990(ra) # 8000053e <panic>
    panic("sched running");
    80002168:	00006517          	auipc	a0,0x6
    8000216c:	0d850513          	addi	a0,a0,216 # 80008240 <digits+0x200>
    80002170:	ffffe097          	auipc	ra,0xffffe
    80002174:	3ce080e7          	jalr	974(ra) # 8000053e <panic>
    panic("sched interruptible");
    80002178:	00006517          	auipc	a0,0x6
    8000217c:	0d850513          	addi	a0,a0,216 # 80008250 <digits+0x210>
    80002180:	ffffe097          	auipc	ra,0xffffe
    80002184:	3be080e7          	jalr	958(ra) # 8000053e <panic>

0000000080002188 <yield>:
{
    80002188:	1101                	addi	sp,sp,-32
    8000218a:	ec06                	sd	ra,24(sp)
    8000218c:	e822                	sd	s0,16(sp)
    8000218e:	e426                	sd	s1,8(sp)
    80002190:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002192:	00000097          	auipc	ra,0x0
    80002196:	838080e7          	jalr	-1992(ra) # 800019ca <myproc>
    8000219a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000219c:	fffff097          	auipc	ra,0xfffff
    800021a0:	a3a080e7          	jalr	-1478(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    800021a4:	478d                	li	a5,3
    800021a6:	cc9c                	sw	a5,24(s1)
  sched();
    800021a8:	00000097          	auipc	ra,0x0
    800021ac:	f0a080e7          	jalr	-246(ra) # 800020b2 <sched>
  release(&p->lock);
    800021b0:	8526                	mv	a0,s1
    800021b2:	fffff097          	auipc	ra,0xfffff
    800021b6:	ad8080e7          	jalr	-1320(ra) # 80000c8a <release>
}
    800021ba:	60e2                	ld	ra,24(sp)
    800021bc:	6442                	ld	s0,16(sp)
    800021be:	64a2                	ld	s1,8(sp)
    800021c0:	6105                	addi	sp,sp,32
    800021c2:	8082                	ret

00000000800021c4 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800021c4:	7179                	addi	sp,sp,-48
    800021c6:	f406                	sd	ra,40(sp)
    800021c8:	f022                	sd	s0,32(sp)
    800021ca:	ec26                	sd	s1,24(sp)
    800021cc:	e84a                	sd	s2,16(sp)
    800021ce:	e44e                	sd	s3,8(sp)
    800021d0:	1800                	addi	s0,sp,48
    800021d2:	89aa                	mv	s3,a0
    800021d4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800021d6:	fffff097          	auipc	ra,0xfffff
    800021da:	7f4080e7          	jalr	2036(ra) # 800019ca <myproc>
    800021de:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800021e0:	fffff097          	auipc	ra,0xfffff
    800021e4:	9f6080e7          	jalr	-1546(ra) # 80000bd6 <acquire>
  release(lk);
    800021e8:	854a                	mv	a0,s2
    800021ea:	fffff097          	auipc	ra,0xfffff
    800021ee:	aa0080e7          	jalr	-1376(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    800021f2:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800021f6:	4789                	li	a5,2
    800021f8:	cc9c                	sw	a5,24(s1)

  sched();
    800021fa:	00000097          	auipc	ra,0x0
    800021fe:	eb8080e7          	jalr	-328(ra) # 800020b2 <sched>

  // Tidy up.
  p->chan = 0;
    80002202:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002206:	8526                	mv	a0,s1
    80002208:	fffff097          	auipc	ra,0xfffff
    8000220c:	a82080e7          	jalr	-1406(ra) # 80000c8a <release>
  acquire(lk);
    80002210:	854a                	mv	a0,s2
    80002212:	fffff097          	auipc	ra,0xfffff
    80002216:	9c4080e7          	jalr	-1596(ra) # 80000bd6 <acquire>
}
    8000221a:	70a2                	ld	ra,40(sp)
    8000221c:	7402                	ld	s0,32(sp)
    8000221e:	64e2                	ld	s1,24(sp)
    80002220:	6942                	ld	s2,16(sp)
    80002222:	69a2                	ld	s3,8(sp)
    80002224:	6145                	addi	sp,sp,48
    80002226:	8082                	ret

0000000080002228 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002228:	715d                	addi	sp,sp,-80
    8000222a:	e486                	sd	ra,72(sp)
    8000222c:	e0a2                	sd	s0,64(sp)
    8000222e:	fc26                	sd	s1,56(sp)
    80002230:	f84a                	sd	s2,48(sp)
    80002232:	f44e                	sd	s3,40(sp)
    80002234:	f052                	sd	s4,32(sp)
    80002236:	ec56                	sd	s5,24(sp)
    80002238:	e85a                	sd	s6,16(sp)
    8000223a:	e45e                	sd	s7,8(sp)
    8000223c:	0880                	addi	s0,sp,80
    8000223e:	8b2a                	mv	s6,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002240:	0000f497          	auipc	s1,0xf
    80002244:	d6048493          	addi	s1,s1,-672 # 80010fa0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002248:	4989                	li	s3,2
        p->state = RUNNABLE;
        p->accumulator=min_accumulator;
      }
      if (p->state==RUNNABLE){
    8000224a:	4a0d                	li	s4,3
        p->retime++;
      }
      else if(p->state==SLEEPING){
        p->stime++;
      }
      else if (p->state==RUNNING){
    8000224c:	4a91                	li	s5,4
        p->accumulator=min_accumulator;
    8000224e:	00006b97          	auipc	s7,0x6
    80002252:	61eb8b93          	addi	s7,s7,1566 # 8000886c <min_accumulator>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002256:	00015917          	auipc	s2,0x15
    8000225a:	74a90913          	addi	s2,s2,1866 # 800179a0 <tickslock>
    8000225e:	a80d                	j	80002290 <wakeup+0x68>
      if(p->state == SLEEPING && p->chan == chan) {
    80002260:	709c                	ld	a5,32(s1)
    80002262:	01678663          	beq	a5,s6,8000226e <wakeup+0x46>
        p->stime++;
    80002266:	5cbc                	lw	a5,120(s1)
    80002268:	2785                	addiw	a5,a5,1
    8000226a:	dcbc                	sw	a5,120(s1)
    8000226c:	a809                	j	8000227e <wakeup+0x56>
        p->state = RUNNABLE;
    8000226e:	0144ac23          	sw	s4,24(s1)
        p->accumulator=min_accumulator;
    80002272:	000ba783          	lw	a5,0(s7)
    80002276:	f0bc                	sd	a5,96(s1)
        p->retime++;
    80002278:	5cfc                	lw	a5,124(s1)
    8000227a:	2785                	addiw	a5,a5,1
    8000227c:	dcfc                	sw	a5,124(s1)
        p->rtime++;
      }
      release(&p->lock);
    8000227e:	8526                	mv	a0,s1
    80002280:	fffff097          	auipc	ra,0xfffff
    80002284:	a0a080e7          	jalr	-1526(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002288:	1a848493          	addi	s1,s1,424
    8000228c:	03248863          	beq	s1,s2,800022bc <wakeup+0x94>
    if(p != myproc()){
    80002290:	fffff097          	auipc	ra,0xfffff
    80002294:	73a080e7          	jalr	1850(ra) # 800019ca <myproc>
    80002298:	fea488e3          	beq	s1,a0,80002288 <wakeup+0x60>
      acquire(&p->lock);
    8000229c:	8526                	mv	a0,s1
    8000229e:	fffff097          	auipc	ra,0xfffff
    800022a2:	938080e7          	jalr	-1736(ra) # 80000bd6 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800022a6:	4c9c                	lw	a5,24(s1)
    800022a8:	fb378ce3          	beq	a5,s3,80002260 <wakeup+0x38>
      if (p->state==RUNNABLE){
    800022ac:	fd4786e3          	beq	a5,s4,80002278 <wakeup+0x50>
      else if (p->state==RUNNING){
    800022b0:	fd5797e3          	bne	a5,s5,8000227e <wakeup+0x56>
        p->rtime++;
    800022b4:	58fc                	lw	a5,116(s1)
    800022b6:	2785                	addiw	a5,a5,1
    800022b8:	d8fc                	sw	a5,116(s1)
    800022ba:	b7d1                	j	8000227e <wakeup+0x56>
    }
  }
}
    800022bc:	60a6                	ld	ra,72(sp)
    800022be:	6406                	ld	s0,64(sp)
    800022c0:	74e2                	ld	s1,56(sp)
    800022c2:	7942                	ld	s2,48(sp)
    800022c4:	79a2                	ld	s3,40(sp)
    800022c6:	7a02                	ld	s4,32(sp)
    800022c8:	6ae2                	ld	s5,24(sp)
    800022ca:	6b42                	ld	s6,16(sp)
    800022cc:	6ba2                	ld	s7,8(sp)
    800022ce:	6161                	addi	sp,sp,80
    800022d0:	8082                	ret

00000000800022d2 <reparent>:
{
    800022d2:	7179                	addi	sp,sp,-48
    800022d4:	f406                	sd	ra,40(sp)
    800022d6:	f022                	sd	s0,32(sp)
    800022d8:	ec26                	sd	s1,24(sp)
    800022da:	e84a                	sd	s2,16(sp)
    800022dc:	e44e                	sd	s3,8(sp)
    800022de:	e052                	sd	s4,0(sp)
    800022e0:	1800                	addi	s0,sp,48
    800022e2:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800022e4:	0000f497          	auipc	s1,0xf
    800022e8:	cbc48493          	addi	s1,s1,-836 # 80010fa0 <proc>
      pp->parent = initproc;
    800022ec:	00006a17          	auipc	s4,0x6
    800022f0:	60ca0a13          	addi	s4,s4,1548 # 800088f8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800022f4:	00015997          	auipc	s3,0x15
    800022f8:	6ac98993          	addi	s3,s3,1708 # 800179a0 <tickslock>
    800022fc:	a029                	j	80002306 <reparent+0x34>
    800022fe:	1a848493          	addi	s1,s1,424
    80002302:	01348d63          	beq	s1,s3,8000231c <reparent+0x4a>
    if(pp->parent == p){
    80002306:	7c9c                	ld	a5,56(s1)
    80002308:	ff279be3          	bne	a5,s2,800022fe <reparent+0x2c>
      pp->parent = initproc;
    8000230c:	000a3503          	ld	a0,0(s4)
    80002310:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002312:	00000097          	auipc	ra,0x0
    80002316:	f16080e7          	jalr	-234(ra) # 80002228 <wakeup>
    8000231a:	b7d5                	j	800022fe <reparent+0x2c>
}
    8000231c:	70a2                	ld	ra,40(sp)
    8000231e:	7402                	ld	s0,32(sp)
    80002320:	64e2                	ld	s1,24(sp)
    80002322:	6942                	ld	s2,16(sp)
    80002324:	69a2                	ld	s3,8(sp)
    80002326:	6a02                	ld	s4,0(sp)
    80002328:	6145                	addi	sp,sp,48
    8000232a:	8082                	ret

000000008000232c <exit>:
{
    8000232c:	7139                	addi	sp,sp,-64
    8000232e:	fc06                	sd	ra,56(sp)
    80002330:	f822                	sd	s0,48(sp)
    80002332:	f426                	sd	s1,40(sp)
    80002334:	f04a                	sd	s2,32(sp)
    80002336:	ec4e                	sd	s3,24(sp)
    80002338:	e852                	sd	s4,16(sp)
    8000233a:	e456                	sd	s5,8(sp)
    8000233c:	0080                	addi	s0,sp,64
    8000233e:	8a2a                	mv	s4,a0
    80002340:	8aae                	mv	s5,a1
  struct proc *p = myproc();
    80002342:	fffff097          	auipc	ra,0xfffff
    80002346:	688080e7          	jalr	1672(ra) # 800019ca <myproc>
    8000234a:	89aa                	mv	s3,a0
  if(p == initproc)
    8000234c:	00006797          	auipc	a5,0x6
    80002350:	5ac7b783          	ld	a5,1452(a5) # 800088f8 <initproc>
    80002354:	11050493          	addi	s1,a0,272
    80002358:	19050913          	addi	s2,a0,400
    8000235c:	02a79363          	bne	a5,a0,80002382 <exit+0x56>
    panic("init exiting");
    80002360:	00006517          	auipc	a0,0x6
    80002364:	f0850513          	addi	a0,a0,-248 # 80008268 <digits+0x228>
    80002368:	ffffe097          	auipc	ra,0xffffe
    8000236c:	1d6080e7          	jalr	470(ra) # 8000053e <panic>
      fileclose(f);
    80002370:	00002097          	auipc	ra,0x2
    80002374:	43a080e7          	jalr	1082(ra) # 800047aa <fileclose>
      p->ofile[fd] = 0;
    80002378:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000237c:	04a1                	addi	s1,s1,8
    8000237e:	01248563          	beq	s1,s2,80002388 <exit+0x5c>
    if(p->ofile[fd]){
    80002382:	6088                	ld	a0,0(s1)
    80002384:	f575                	bnez	a0,80002370 <exit+0x44>
    80002386:	bfdd                	j	8000237c <exit+0x50>
  begin_op();
    80002388:	00002097          	auipc	ra,0x2
    8000238c:	f56080e7          	jalr	-170(ra) # 800042de <begin_op>
  iput(p->cwd);
    80002390:	1909b503          	ld	a0,400(s3)
    80002394:	00001097          	auipc	ra,0x1
    80002398:	742080e7          	jalr	1858(ra) # 80003ad6 <iput>
  end_op();
    8000239c:	00002097          	auipc	ra,0x2
    800023a0:	fc2080e7          	jalr	-62(ra) # 8000435e <end_op>
  p->cwd = 0;
    800023a4:	1809b823          	sd	zero,400(s3)
  acquire(&wait_lock);
    800023a8:	0000e497          	auipc	s1,0xe
    800023ac:	7e048493          	addi	s1,s1,2016 # 80010b88 <wait_lock>
    800023b0:	8526                	mv	a0,s1
    800023b2:	fffff097          	auipc	ra,0xfffff
    800023b6:	824080e7          	jalr	-2012(ra) # 80000bd6 <acquire>
  reparent(p);
    800023ba:	854e                	mv	a0,s3
    800023bc:	00000097          	auipc	ra,0x0
    800023c0:	f16080e7          	jalr	-234(ra) # 800022d2 <reparent>
  wakeup(p->parent);
    800023c4:	0389b503          	ld	a0,56(s3)
    800023c8:	00000097          	auipc	ra,0x0
    800023cc:	e60080e7          	jalr	-416(ra) # 80002228 <wakeup>
  acquire(&p->lock);
    800023d0:	854e                	mv	a0,s3
    800023d2:	fffff097          	auipc	ra,0xfffff
    800023d6:	804080e7          	jalr	-2044(ra) # 80000bd6 <acquire>
  safestrcpy(p->exit_msg, msg, sizeof(p->exit_msg)); // Copy string to process PCB
    800023da:	02000613          	li	a2,32
    800023de:	85d6                	mv	a1,s5
    800023e0:	04098513          	addi	a0,s3,64
    800023e4:	fffff097          	auipc	ra,0xfffff
    800023e8:	a38080e7          	jalr	-1480(ra) # 80000e1c <safestrcpy>
  p->xstate = status;
    800023ec:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800023f0:	4795                	li	a5,5
    800023f2:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800023f6:	8526                	mv	a0,s1
    800023f8:	fffff097          	auipc	ra,0xfffff
    800023fc:	892080e7          	jalr	-1902(ra) # 80000c8a <release>
  sched();
    80002400:	00000097          	auipc	ra,0x0
    80002404:	cb2080e7          	jalr	-846(ra) # 800020b2 <sched>
  panic("zombie exit");
    80002408:	00006517          	auipc	a0,0x6
    8000240c:	e7050513          	addi	a0,a0,-400 # 80008278 <digits+0x238>
    80002410:	ffffe097          	auipc	ra,0xffffe
    80002414:	12e080e7          	jalr	302(ra) # 8000053e <panic>

0000000080002418 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002418:	7179                	addi	sp,sp,-48
    8000241a:	f406                	sd	ra,40(sp)
    8000241c:	f022                	sd	s0,32(sp)
    8000241e:	ec26                	sd	s1,24(sp)
    80002420:	e84a                	sd	s2,16(sp)
    80002422:	e44e                	sd	s3,8(sp)
    80002424:	1800                	addi	s0,sp,48
    80002426:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002428:	0000f497          	auipc	s1,0xf
    8000242c:	b7848493          	addi	s1,s1,-1160 # 80010fa0 <proc>
    80002430:	00015997          	auipc	s3,0x15
    80002434:	57098993          	addi	s3,s3,1392 # 800179a0 <tickslock>
    acquire(&p->lock);
    80002438:	8526                	mv	a0,s1
    8000243a:	ffffe097          	auipc	ra,0xffffe
    8000243e:	79c080e7          	jalr	1948(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    80002442:	589c                	lw	a5,48(s1)
    80002444:	01278d63          	beq	a5,s2,8000245e <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002448:	8526                	mv	a0,s1
    8000244a:	fffff097          	auipc	ra,0xfffff
    8000244e:	840080e7          	jalr	-1984(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002452:	1a848493          	addi	s1,s1,424
    80002456:	ff3491e3          	bne	s1,s3,80002438 <kill+0x20>
  }
  return -1;
    8000245a:	557d                	li	a0,-1
    8000245c:	a829                	j	80002476 <kill+0x5e>
      p->killed = 1;
    8000245e:	4785                	li	a5,1
    80002460:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002462:	4c98                	lw	a4,24(s1)
    80002464:	4789                	li	a5,2
    80002466:	00f70f63          	beq	a4,a5,80002484 <kill+0x6c>
      release(&p->lock);
    8000246a:	8526                	mv	a0,s1
    8000246c:	fffff097          	auipc	ra,0xfffff
    80002470:	81e080e7          	jalr	-2018(ra) # 80000c8a <release>
      return 0;
    80002474:	4501                	li	a0,0
}
    80002476:	70a2                	ld	ra,40(sp)
    80002478:	7402                	ld	s0,32(sp)
    8000247a:	64e2                	ld	s1,24(sp)
    8000247c:	6942                	ld	s2,16(sp)
    8000247e:	69a2                	ld	s3,8(sp)
    80002480:	6145                	addi	sp,sp,48
    80002482:	8082                	ret
        p->state = RUNNABLE;
    80002484:	478d                	li	a5,3
    80002486:	cc9c                	sw	a5,24(s1)
    80002488:	b7cd                	j	8000246a <kill+0x52>

000000008000248a <setkilled>:


void
setkilled(struct proc *p)
{
    8000248a:	1101                	addi	sp,sp,-32
    8000248c:	ec06                	sd	ra,24(sp)
    8000248e:	e822                	sd	s0,16(sp)
    80002490:	e426                	sd	s1,8(sp)
    80002492:	1000                	addi	s0,sp,32
    80002494:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002496:	ffffe097          	auipc	ra,0xffffe
    8000249a:	740080e7          	jalr	1856(ra) # 80000bd6 <acquire>
  p->killed = 1;
    8000249e:	4785                	li	a5,1
    800024a0:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800024a2:	8526                	mv	a0,s1
    800024a4:	ffffe097          	auipc	ra,0xffffe
    800024a8:	7e6080e7          	jalr	2022(ra) # 80000c8a <release>
}
    800024ac:	60e2                	ld	ra,24(sp)
    800024ae:	6442                	ld	s0,16(sp)
    800024b0:	64a2                	ld	s1,8(sp)
    800024b2:	6105                	addi	sp,sp,32
    800024b4:	8082                	ret

00000000800024b6 <killed>:

int
killed(struct proc *p)
{
    800024b6:	1101                	addi	sp,sp,-32
    800024b8:	ec06                	sd	ra,24(sp)
    800024ba:	e822                	sd	s0,16(sp)
    800024bc:	e426                	sd	s1,8(sp)
    800024be:	e04a                	sd	s2,0(sp)
    800024c0:	1000                	addi	s0,sp,32
    800024c2:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800024c4:	ffffe097          	auipc	ra,0xffffe
    800024c8:	712080e7          	jalr	1810(ra) # 80000bd6 <acquire>
  k = p->killed;
    800024cc:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800024d0:	8526                	mv	a0,s1
    800024d2:	ffffe097          	auipc	ra,0xffffe
    800024d6:	7b8080e7          	jalr	1976(ra) # 80000c8a <release>
  return k;
}
    800024da:	854a                	mv	a0,s2
    800024dc:	60e2                	ld	ra,24(sp)
    800024de:	6442                	ld	s0,16(sp)
    800024e0:	64a2                	ld	s1,8(sp)
    800024e2:	6902                	ld	s2,0(sp)
    800024e4:	6105                	addi	sp,sp,32
    800024e6:	8082                	ret

00000000800024e8 <wait>:
{
    800024e8:	711d                	addi	sp,sp,-96
    800024ea:	ec86                	sd	ra,88(sp)
    800024ec:	e8a2                	sd	s0,80(sp)
    800024ee:	e4a6                	sd	s1,72(sp)
    800024f0:	e0ca                	sd	s2,64(sp)
    800024f2:	fc4e                	sd	s3,56(sp)
    800024f4:	f852                	sd	s4,48(sp)
    800024f6:	f456                	sd	s5,40(sp)
    800024f8:	f05a                	sd	s6,32(sp)
    800024fa:	ec5e                	sd	s7,24(sp)
    800024fc:	e862                	sd	s8,16(sp)
    800024fe:	e466                	sd	s9,8(sp)
    80002500:	1080                	addi	s0,sp,96
    80002502:	8baa                	mv	s7,a0
    80002504:	8b2e                	mv	s6,a1
  struct proc *p = myproc();
    80002506:	fffff097          	auipc	ra,0xfffff
    8000250a:	4c4080e7          	jalr	1220(ra) # 800019ca <myproc>
    8000250e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002510:	0000e517          	auipc	a0,0xe
    80002514:	67850513          	addi	a0,a0,1656 # 80010b88 <wait_lock>
    80002518:	ffffe097          	auipc	ra,0xffffe
    8000251c:	6be080e7          	jalr	1726(ra) # 80000bd6 <acquire>
    havekids = 0;
    80002520:	4c01                	li	s8,0
        if(pp->state == ZOMBIE){
    80002522:	4a15                	li	s4,5
        havekids = 1;
    80002524:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002526:	00015997          	auipc	s3,0x15
    8000252a:	47a98993          	addi	s3,s3,1146 # 800179a0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000252e:	0000ec97          	auipc	s9,0xe
    80002532:	65ac8c93          	addi	s9,s9,1626 # 80010b88 <wait_lock>
    havekids = 0;
    80002536:	8762                	mv	a4,s8
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002538:	0000f497          	auipc	s1,0xf
    8000253c:	a6848493          	addi	s1,s1,-1432 # 80010fa0 <proc>
    80002540:	a06d                	j	800025ea <wait+0x102>
          pid = pp->pid;
    80002542:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002546:	040b9463          	bnez	s7,8000258e <wait+0xa6>
          if(dst != 0 && copyout(p->pagetable, dst, (char *)&pp->exit_msg,
    8000254a:	000b0f63          	beqz	s6,80002568 <wait+0x80>
    8000254e:	02000693          	li	a3,32
    80002552:	04048613          	addi	a2,s1,64
    80002556:	85da                	mv	a1,s6
    80002558:	09093503          	ld	a0,144(s2)
    8000255c:	fffff097          	auipc	ra,0xfffff
    80002560:	10c080e7          	jalr	268(ra) # 80001668 <copyout>
    80002564:	06054063          	bltz	a0,800025c4 <wait+0xdc>
          freeproc(pp);
    80002568:	8526                	mv	a0,s1
    8000256a:	fffff097          	auipc	ra,0xfffff
    8000256e:	612080e7          	jalr	1554(ra) # 80001b7c <freeproc>
          release(&pp->lock);
    80002572:	8526                	mv	a0,s1
    80002574:	ffffe097          	auipc	ra,0xffffe
    80002578:	716080e7          	jalr	1814(ra) # 80000c8a <release>
          release(&wait_lock);
    8000257c:	0000e517          	auipc	a0,0xe
    80002580:	60c50513          	addi	a0,a0,1548 # 80010b88 <wait_lock>
    80002584:	ffffe097          	auipc	ra,0xffffe
    80002588:	706080e7          	jalr	1798(ra) # 80000c8a <release>
          return pid;
    8000258c:	a04d                	j	8000262e <wait+0x146>
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000258e:	4691                	li	a3,4
    80002590:	02c48613          	addi	a2,s1,44
    80002594:	85de                	mv	a1,s7
    80002596:	09093503          	ld	a0,144(s2)
    8000259a:	fffff097          	auipc	ra,0xfffff
    8000259e:	0ce080e7          	jalr	206(ra) # 80001668 <copyout>
    800025a2:	fa0554e3          	bgez	a0,8000254a <wait+0x62>
            release(&pp->lock);
    800025a6:	8526                	mv	a0,s1
    800025a8:	ffffe097          	auipc	ra,0xffffe
    800025ac:	6e2080e7          	jalr	1762(ra) # 80000c8a <release>
            release(&wait_lock);
    800025b0:	0000e517          	auipc	a0,0xe
    800025b4:	5d850513          	addi	a0,a0,1496 # 80010b88 <wait_lock>
    800025b8:	ffffe097          	auipc	ra,0xffffe
    800025bc:	6d2080e7          	jalr	1746(ra) # 80000c8a <release>
            return -1;
    800025c0:	59fd                	li	s3,-1
    800025c2:	a0b5                	j	8000262e <wait+0x146>
            release(&pp->lock);
    800025c4:	8526                	mv	a0,s1
    800025c6:	ffffe097          	auipc	ra,0xffffe
    800025ca:	6c4080e7          	jalr	1732(ra) # 80000c8a <release>
            release(&wait_lock);
    800025ce:	0000e517          	auipc	a0,0xe
    800025d2:	5ba50513          	addi	a0,a0,1466 # 80010b88 <wait_lock>
    800025d6:	ffffe097          	auipc	ra,0xffffe
    800025da:	6b4080e7          	jalr	1716(ra) # 80000c8a <release>
            return -1;
    800025de:	59fd                	li	s3,-1
    800025e0:	a0b9                	j	8000262e <wait+0x146>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800025e2:	1a848493          	addi	s1,s1,424
    800025e6:	03348463          	beq	s1,s3,8000260e <wait+0x126>
      if(pp->parent == p){
    800025ea:	7c9c                	ld	a5,56(s1)
    800025ec:	ff279be3          	bne	a5,s2,800025e2 <wait+0xfa>
        acquire(&pp->lock);
    800025f0:	8526                	mv	a0,s1
    800025f2:	ffffe097          	auipc	ra,0xffffe
    800025f6:	5e4080e7          	jalr	1508(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    800025fa:	4c9c                	lw	a5,24(s1)
    800025fc:	f54783e3          	beq	a5,s4,80002542 <wait+0x5a>
        release(&pp->lock);
    80002600:	8526                	mv	a0,s1
    80002602:	ffffe097          	auipc	ra,0xffffe
    80002606:	688080e7          	jalr	1672(ra) # 80000c8a <release>
        havekids = 1;
    8000260a:	8756                	mv	a4,s5
    8000260c:	bfd9                	j	800025e2 <wait+0xfa>
    if(!havekids || killed(p)){
    8000260e:	c719                	beqz	a4,8000261c <wait+0x134>
    80002610:	854a                	mv	a0,s2
    80002612:	00000097          	auipc	ra,0x0
    80002616:	ea4080e7          	jalr	-348(ra) # 800024b6 <killed>
    8000261a:	c905                	beqz	a0,8000264a <wait+0x162>
      release(&wait_lock);
    8000261c:	0000e517          	auipc	a0,0xe
    80002620:	56c50513          	addi	a0,a0,1388 # 80010b88 <wait_lock>
    80002624:	ffffe097          	auipc	ra,0xffffe
    80002628:	666080e7          	jalr	1638(ra) # 80000c8a <release>
      return -1;
    8000262c:	59fd                	li	s3,-1
}
    8000262e:	854e                	mv	a0,s3
    80002630:	60e6                	ld	ra,88(sp)
    80002632:	6446                	ld	s0,80(sp)
    80002634:	64a6                	ld	s1,72(sp)
    80002636:	6906                	ld	s2,64(sp)
    80002638:	79e2                	ld	s3,56(sp)
    8000263a:	7a42                	ld	s4,48(sp)
    8000263c:	7aa2                	ld	s5,40(sp)
    8000263e:	7b02                	ld	s6,32(sp)
    80002640:	6be2                	ld	s7,24(sp)
    80002642:	6c42                	ld	s8,16(sp)
    80002644:	6ca2                	ld	s9,8(sp)
    80002646:	6125                	addi	sp,sp,96
    80002648:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000264a:	85e6                	mv	a1,s9
    8000264c:	854a                	mv	a0,s2
    8000264e:	00000097          	auipc	ra,0x0
    80002652:	b76080e7          	jalr	-1162(ra) # 800021c4 <sleep>
    havekids = 0;
    80002656:	b5c5                	j	80002536 <wait+0x4e>

0000000080002658 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002658:	7179                	addi	sp,sp,-48
    8000265a:	f406                	sd	ra,40(sp)
    8000265c:	f022                	sd	s0,32(sp)
    8000265e:	ec26                	sd	s1,24(sp)
    80002660:	e84a                	sd	s2,16(sp)
    80002662:	e44e                	sd	s3,8(sp)
    80002664:	e052                	sd	s4,0(sp)
    80002666:	1800                	addi	s0,sp,48
    80002668:	84aa                	mv	s1,a0
    8000266a:	892e                	mv	s2,a1
    8000266c:	89b2                	mv	s3,a2
    8000266e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002670:	fffff097          	auipc	ra,0xfffff
    80002674:	35a080e7          	jalr	858(ra) # 800019ca <myproc>
  if(user_dst){
    80002678:	c08d                	beqz	s1,8000269a <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000267a:	86d2                	mv	a3,s4
    8000267c:	864e                	mv	a2,s3
    8000267e:	85ca                	mv	a1,s2
    80002680:	6948                	ld	a0,144(a0)
    80002682:	fffff097          	auipc	ra,0xfffff
    80002686:	fe6080e7          	jalr	-26(ra) # 80001668 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000268a:	70a2                	ld	ra,40(sp)
    8000268c:	7402                	ld	s0,32(sp)
    8000268e:	64e2                	ld	s1,24(sp)
    80002690:	6942                	ld	s2,16(sp)
    80002692:	69a2                	ld	s3,8(sp)
    80002694:	6a02                	ld	s4,0(sp)
    80002696:	6145                	addi	sp,sp,48
    80002698:	8082                	ret
    memmove((char *)dst, src, len);
    8000269a:	000a061b          	sext.w	a2,s4
    8000269e:	85ce                	mv	a1,s3
    800026a0:	854a                	mv	a0,s2
    800026a2:	ffffe097          	auipc	ra,0xffffe
    800026a6:	68c080e7          	jalr	1676(ra) # 80000d2e <memmove>
    return 0;
    800026aa:	8526                	mv	a0,s1
    800026ac:	bff9                	j	8000268a <either_copyout+0x32>

00000000800026ae <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800026ae:	7179                	addi	sp,sp,-48
    800026b0:	f406                	sd	ra,40(sp)
    800026b2:	f022                	sd	s0,32(sp)
    800026b4:	ec26                	sd	s1,24(sp)
    800026b6:	e84a                	sd	s2,16(sp)
    800026b8:	e44e                	sd	s3,8(sp)
    800026ba:	e052                	sd	s4,0(sp)
    800026bc:	1800                	addi	s0,sp,48
    800026be:	892a                	mv	s2,a0
    800026c0:	84ae                	mv	s1,a1
    800026c2:	89b2                	mv	s3,a2
    800026c4:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800026c6:	fffff097          	auipc	ra,0xfffff
    800026ca:	304080e7          	jalr	772(ra) # 800019ca <myproc>
  if(user_src){
    800026ce:	c08d                	beqz	s1,800026f0 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800026d0:	86d2                	mv	a3,s4
    800026d2:	864e                	mv	a2,s3
    800026d4:	85ca                	mv	a1,s2
    800026d6:	6948                	ld	a0,144(a0)
    800026d8:	fffff097          	auipc	ra,0xfffff
    800026dc:	01c080e7          	jalr	28(ra) # 800016f4 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800026e0:	70a2                	ld	ra,40(sp)
    800026e2:	7402                	ld	s0,32(sp)
    800026e4:	64e2                	ld	s1,24(sp)
    800026e6:	6942                	ld	s2,16(sp)
    800026e8:	69a2                	ld	s3,8(sp)
    800026ea:	6a02                	ld	s4,0(sp)
    800026ec:	6145                	addi	sp,sp,48
    800026ee:	8082                	ret
    memmove(dst, (char*)src, len);
    800026f0:	000a061b          	sext.w	a2,s4
    800026f4:	85ce                	mv	a1,s3
    800026f6:	854a                	mv	a0,s2
    800026f8:	ffffe097          	auipc	ra,0xffffe
    800026fc:	636080e7          	jalr	1590(ra) # 80000d2e <memmove>
    return 0;
    80002700:	8526                	mv	a0,s1
    80002702:	bff9                	j	800026e0 <either_copyin+0x32>

0000000080002704 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002704:	715d                	addi	sp,sp,-80
    80002706:	e486                	sd	ra,72(sp)
    80002708:	e0a2                	sd	s0,64(sp)
    8000270a:	fc26                	sd	s1,56(sp)
    8000270c:	f84a                	sd	s2,48(sp)
    8000270e:	f44e                	sd	s3,40(sp)
    80002710:	f052                	sd	s4,32(sp)
    80002712:	ec56                	sd	s5,24(sp)
    80002714:	e85a                	sd	s6,16(sp)
    80002716:	e45e                	sd	s7,8(sp)
    80002718:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000271a:	00006517          	auipc	a0,0x6
    8000271e:	9ae50513          	addi	a0,a0,-1618 # 800080c8 <digits+0x88>
    80002722:	ffffe097          	auipc	ra,0xffffe
    80002726:	e66080e7          	jalr	-410(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000272a:	0000f497          	auipc	s1,0xf
    8000272e:	a0e48493          	addi	s1,s1,-1522 # 80011138 <proc+0x198>
    80002732:	00015917          	auipc	s2,0x15
    80002736:	40690913          	addi	s2,s2,1030 # 80017b38 <bcache+0x180>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000273a:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000273c:	00006997          	auipc	s3,0x6
    80002740:	b4c98993          	addi	s3,s3,-1204 # 80008288 <digits+0x248>
    printf("%d %s %s", p->pid, state, p->name);
    80002744:	00006a97          	auipc	s5,0x6
    80002748:	b4ca8a93          	addi	s5,s5,-1204 # 80008290 <digits+0x250>
    printf("\n");
    8000274c:	00006a17          	auipc	s4,0x6
    80002750:	97ca0a13          	addi	s4,s4,-1668 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002754:	00006b97          	auipc	s7,0x6
    80002758:	b7cb8b93          	addi	s7,s7,-1156 # 800082d0 <states.0>
    8000275c:	a00d                	j	8000277e <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000275e:	e986a583          	lw	a1,-360(a3)
    80002762:	8556                	mv	a0,s5
    80002764:	ffffe097          	auipc	ra,0xffffe
    80002768:	e24080e7          	jalr	-476(ra) # 80000588 <printf>
    printf("\n");
    8000276c:	8552                	mv	a0,s4
    8000276e:	ffffe097          	auipc	ra,0xffffe
    80002772:	e1a080e7          	jalr	-486(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002776:	1a848493          	addi	s1,s1,424
    8000277a:	03248163          	beq	s1,s2,8000279c <procdump+0x98>
    if(p->state == UNUSED)
    8000277e:	86a6                	mv	a3,s1
    80002780:	e804a783          	lw	a5,-384(s1)
    80002784:	dbed                	beqz	a5,80002776 <procdump+0x72>
      state = "???";
    80002786:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002788:	fcfb6be3          	bltu	s6,a5,8000275e <procdump+0x5a>
    8000278c:	1782                	slli	a5,a5,0x20
    8000278e:	9381                	srli	a5,a5,0x20
    80002790:	078e                	slli	a5,a5,0x3
    80002792:	97de                	add	a5,a5,s7
    80002794:	6390                	ld	a2,0(a5)
    80002796:	f661                	bnez	a2,8000275e <procdump+0x5a>
      state = "???";
    80002798:	864e                	mv	a2,s3
    8000279a:	b7d1                	j	8000275e <procdump+0x5a>
  }
}
    8000279c:	60a6                	ld	ra,72(sp)
    8000279e:	6406                	ld	s0,64(sp)
    800027a0:	74e2                	ld	s1,56(sp)
    800027a2:	7942                	ld	s2,48(sp)
    800027a4:	79a2                	ld	s3,40(sp)
    800027a6:	7a02                	ld	s4,32(sp)
    800027a8:	6ae2                	ld	s5,24(sp)
    800027aa:	6b42                	ld	s6,16(sp)
    800027ac:	6ba2                	ld	s7,8(sp)
    800027ae:	6161                	addi	sp,sp,80
    800027b0:	8082                	ret

00000000800027b2 <swtch>:
    800027b2:	00153023          	sd	ra,0(a0)
    800027b6:	00253423          	sd	sp,8(a0)
    800027ba:	e900                	sd	s0,16(a0)
    800027bc:	ed04                	sd	s1,24(a0)
    800027be:	03253023          	sd	s2,32(a0)
    800027c2:	03353423          	sd	s3,40(a0)
    800027c6:	03453823          	sd	s4,48(a0)
    800027ca:	03553c23          	sd	s5,56(a0)
    800027ce:	05653023          	sd	s6,64(a0)
    800027d2:	05753423          	sd	s7,72(a0)
    800027d6:	05853823          	sd	s8,80(a0)
    800027da:	05953c23          	sd	s9,88(a0)
    800027de:	07a53023          	sd	s10,96(a0)
    800027e2:	07b53423          	sd	s11,104(a0)
    800027e6:	0005b083          	ld	ra,0(a1)
    800027ea:	0085b103          	ld	sp,8(a1)
    800027ee:	6980                	ld	s0,16(a1)
    800027f0:	6d84                	ld	s1,24(a1)
    800027f2:	0205b903          	ld	s2,32(a1)
    800027f6:	0285b983          	ld	s3,40(a1)
    800027fa:	0305ba03          	ld	s4,48(a1)
    800027fe:	0385ba83          	ld	s5,56(a1)
    80002802:	0405bb03          	ld	s6,64(a1)
    80002806:	0485bb83          	ld	s7,72(a1)
    8000280a:	0505bc03          	ld	s8,80(a1)
    8000280e:	0585bc83          	ld	s9,88(a1)
    80002812:	0605bd03          	ld	s10,96(a1)
    80002816:	0685bd83          	ld	s11,104(a1)
    8000281a:	8082                	ret

000000008000281c <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000281c:	1141                	addi	sp,sp,-16
    8000281e:	e406                	sd	ra,8(sp)
    80002820:	e022                	sd	s0,0(sp)
    80002822:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002824:	00006597          	auipc	a1,0x6
    80002828:	adc58593          	addi	a1,a1,-1316 # 80008300 <states.0+0x30>
    8000282c:	00015517          	auipc	a0,0x15
    80002830:	17450513          	addi	a0,a0,372 # 800179a0 <tickslock>
    80002834:	ffffe097          	auipc	ra,0xffffe
    80002838:	312080e7          	jalr	786(ra) # 80000b46 <initlock>
}
    8000283c:	60a2                	ld	ra,8(sp)
    8000283e:	6402                	ld	s0,0(sp)
    80002840:	0141                	addi	sp,sp,16
    80002842:	8082                	ret

0000000080002844 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002844:	1141                	addi	sp,sp,-16
    80002846:	e422                	sd	s0,8(sp)
    80002848:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000284a:	00003797          	auipc	a5,0x3
    8000284e:	5b678793          	addi	a5,a5,1462 # 80005e00 <kernelvec>
    80002852:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002856:	6422                	ld	s0,8(sp)
    80002858:	0141                	addi	sp,sp,16
    8000285a:	8082                	ret

000000008000285c <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000285c:	1141                	addi	sp,sp,-16
    8000285e:	e406                	sd	ra,8(sp)
    80002860:	e022                	sd	s0,0(sp)
    80002862:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002864:	fffff097          	auipc	ra,0xfffff
    80002868:	166080e7          	jalr	358(ra) # 800019ca <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000286c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002870:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002872:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002876:	00004617          	auipc	a2,0x4
    8000287a:	78a60613          	addi	a2,a2,1930 # 80007000 <_trampoline>
    8000287e:	00004697          	auipc	a3,0x4
    80002882:	78268693          	addi	a3,a3,1922 # 80007000 <_trampoline>
    80002886:	8e91                	sub	a3,a3,a2
    80002888:	040007b7          	lui	a5,0x4000
    8000288c:	17fd                	addi	a5,a5,-1
    8000288e:	07b2                	slli	a5,a5,0xc
    80002890:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002892:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002896:	6d58                	ld	a4,152(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002898:	180026f3          	csrr	a3,satp
    8000289c:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000289e:	6d58                	ld	a4,152(a0)
    800028a0:	6154                	ld	a3,128(a0)
    800028a2:	6585                	lui	a1,0x1
    800028a4:	96ae                	add	a3,a3,a1
    800028a6:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800028a8:	6d58                	ld	a4,152(a0)
    800028aa:	00000697          	auipc	a3,0x0
    800028ae:	13068693          	addi	a3,a3,304 # 800029da <usertrap>
    800028b2:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800028b4:	6d58                	ld	a4,152(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800028b6:	8692                	mv	a3,tp
    800028b8:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028ba:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800028be:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800028c2:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028c6:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800028ca:	6d58                	ld	a4,152(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800028cc:	6f18                	ld	a4,24(a4)
    800028ce:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800028d2:	6948                	ld	a0,144(a0)
    800028d4:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800028d6:	00004717          	auipc	a4,0x4
    800028da:	7c670713          	addi	a4,a4,1990 # 8000709c <userret>
    800028de:	8f11                	sub	a4,a4,a2
    800028e0:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800028e2:	577d                	li	a4,-1
    800028e4:	177e                	slli	a4,a4,0x3f
    800028e6:	8d59                	or	a0,a0,a4
    800028e8:	9782                	jalr	a5
}
    800028ea:	60a2                	ld	ra,8(sp)
    800028ec:	6402                	ld	s0,0(sp)
    800028ee:	0141                	addi	sp,sp,16
    800028f0:	8082                	ret

00000000800028f2 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800028f2:	1101                	addi	sp,sp,-32
    800028f4:	ec06                	sd	ra,24(sp)
    800028f6:	e822                	sd	s0,16(sp)
    800028f8:	e426                	sd	s1,8(sp)
    800028fa:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800028fc:	00015497          	auipc	s1,0x15
    80002900:	0a448493          	addi	s1,s1,164 # 800179a0 <tickslock>
    80002904:	8526                	mv	a0,s1
    80002906:	ffffe097          	auipc	ra,0xffffe
    8000290a:	2d0080e7          	jalr	720(ra) # 80000bd6 <acquire>
  ticks++;
    8000290e:	00006517          	auipc	a0,0x6
    80002912:	ff250513          	addi	a0,a0,-14 # 80008900 <ticks>
    80002916:	411c                	lw	a5,0(a0)
    80002918:	2785                	addiw	a5,a5,1
    8000291a:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000291c:	00000097          	auipc	ra,0x0
    80002920:	90c080e7          	jalr	-1780(ra) # 80002228 <wakeup>
  release(&tickslock);
    80002924:	8526                	mv	a0,s1
    80002926:	ffffe097          	auipc	ra,0xffffe
    8000292a:	364080e7          	jalr	868(ra) # 80000c8a <release>
}
    8000292e:	60e2                	ld	ra,24(sp)
    80002930:	6442                	ld	s0,16(sp)
    80002932:	64a2                	ld	s1,8(sp)
    80002934:	6105                	addi	sp,sp,32
    80002936:	8082                	ret

0000000080002938 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002938:	1101                	addi	sp,sp,-32
    8000293a:	ec06                	sd	ra,24(sp)
    8000293c:	e822                	sd	s0,16(sp)
    8000293e:	e426                	sd	s1,8(sp)
    80002940:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002942:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002946:	00074d63          	bltz	a4,80002960 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    8000294a:	57fd                	li	a5,-1
    8000294c:	17fe                	slli	a5,a5,0x3f
    8000294e:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002950:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002952:	06f70363          	beq	a4,a5,800029b8 <devintr+0x80>
  }
}
    80002956:	60e2                	ld	ra,24(sp)
    80002958:	6442                	ld	s0,16(sp)
    8000295a:	64a2                	ld	s1,8(sp)
    8000295c:	6105                	addi	sp,sp,32
    8000295e:	8082                	ret
     (scause & 0xff) == 9){
    80002960:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002964:	46a5                	li	a3,9
    80002966:	fed792e3          	bne	a5,a3,8000294a <devintr+0x12>
    int irq = plic_claim();
    8000296a:	00003097          	auipc	ra,0x3
    8000296e:	59e080e7          	jalr	1438(ra) # 80005f08 <plic_claim>
    80002972:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002974:	47a9                	li	a5,10
    80002976:	02f50763          	beq	a0,a5,800029a4 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    8000297a:	4785                	li	a5,1
    8000297c:	02f50963          	beq	a0,a5,800029ae <devintr+0x76>
    return 1;
    80002980:	4505                	li	a0,1
    } else if(irq){
    80002982:	d8f1                	beqz	s1,80002956 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002984:	85a6                	mv	a1,s1
    80002986:	00006517          	auipc	a0,0x6
    8000298a:	98250513          	addi	a0,a0,-1662 # 80008308 <states.0+0x38>
    8000298e:	ffffe097          	auipc	ra,0xffffe
    80002992:	bfa080e7          	jalr	-1030(ra) # 80000588 <printf>
      plic_complete(irq);
    80002996:	8526                	mv	a0,s1
    80002998:	00003097          	auipc	ra,0x3
    8000299c:	594080e7          	jalr	1428(ra) # 80005f2c <plic_complete>
    return 1;
    800029a0:	4505                	li	a0,1
    800029a2:	bf55                	j	80002956 <devintr+0x1e>
      uartintr();
    800029a4:	ffffe097          	auipc	ra,0xffffe
    800029a8:	ff6080e7          	jalr	-10(ra) # 8000099a <uartintr>
    800029ac:	b7ed                	j	80002996 <devintr+0x5e>
      virtio_disk_intr();
    800029ae:	00004097          	auipc	ra,0x4
    800029b2:	a4a080e7          	jalr	-1462(ra) # 800063f8 <virtio_disk_intr>
    800029b6:	b7c5                	j	80002996 <devintr+0x5e>
    if(cpuid() == 0){
    800029b8:	fffff097          	auipc	ra,0xfffff
    800029bc:	fe6080e7          	jalr	-26(ra) # 8000199e <cpuid>
    800029c0:	c901                	beqz	a0,800029d0 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800029c2:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800029c6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800029c8:	14479073          	csrw	sip,a5
    return 2;
    800029cc:	4509                	li	a0,2
    800029ce:	b761                	j	80002956 <devintr+0x1e>
      clockintr();
    800029d0:	00000097          	auipc	ra,0x0
    800029d4:	f22080e7          	jalr	-222(ra) # 800028f2 <clockintr>
    800029d8:	b7ed                	j	800029c2 <devintr+0x8a>

00000000800029da <usertrap>:
{
    800029da:	1101                	addi	sp,sp,-32
    800029dc:	ec06                	sd	ra,24(sp)
    800029de:	e822                	sd	s0,16(sp)
    800029e0:	e426                	sd	s1,8(sp)
    800029e2:	e04a                	sd	s2,0(sp)
    800029e4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029e6:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800029ea:	1007f793          	andi	a5,a5,256
    800029ee:	e3b1                	bnez	a5,80002a32 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029f0:	00003797          	auipc	a5,0x3
    800029f4:	41078793          	addi	a5,a5,1040 # 80005e00 <kernelvec>
    800029f8:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800029fc:	fffff097          	auipc	ra,0xfffff
    80002a00:	fce080e7          	jalr	-50(ra) # 800019ca <myproc>
    80002a04:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002a06:	6d5c                	ld	a5,152(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a08:	14102773          	csrr	a4,sepc
    80002a0c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a0e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002a12:	47a1                	li	a5,8
    80002a14:	02f70763          	beq	a4,a5,80002a42 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002a18:	00000097          	auipc	ra,0x0
    80002a1c:	f20080e7          	jalr	-224(ra) # 80002938 <devintr>
    80002a20:	892a                	mv	s2,a0
    80002a22:	c551                	beqz	a0,80002aae <usertrap+0xd4>
  if(killed(p))
    80002a24:	8526                	mv	a0,s1
    80002a26:	00000097          	auipc	ra,0x0
    80002a2a:	a90080e7          	jalr	-1392(ra) # 800024b6 <killed>
    80002a2e:	c939                	beqz	a0,80002a84 <usertrap+0xaa>
    80002a30:	a099                	j	80002a76 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002a32:	00006517          	auipc	a0,0x6
    80002a36:	8f650513          	addi	a0,a0,-1802 # 80008328 <states.0+0x58>
    80002a3a:	ffffe097          	auipc	ra,0xffffe
    80002a3e:	b04080e7          	jalr	-1276(ra) # 8000053e <panic>
    if(killed(p))
    80002a42:	00000097          	auipc	ra,0x0
    80002a46:	a74080e7          	jalr	-1420(ra) # 800024b6 <killed>
    80002a4a:	e931                	bnez	a0,80002a9e <usertrap+0xc4>
    p->trapframe->epc += 4;
    80002a4c:	6cd8                	ld	a4,152(s1)
    80002a4e:	6f1c                	ld	a5,24(a4)
    80002a50:	0791                	addi	a5,a5,4
    80002a52:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a54:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002a58:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a5c:	10079073          	csrw	sstatus,a5
    syscall();
    80002a60:	00000097          	auipc	ra,0x0
    80002a64:	30e080e7          	jalr	782(ra) # 80002d6e <syscall>
  if(killed(p))
    80002a68:	8526                	mv	a0,s1
    80002a6a:	00000097          	auipc	ra,0x0
    80002a6e:	a4c080e7          	jalr	-1460(ra) # 800024b6 <killed>
    80002a72:	cd01                	beqz	a0,80002a8a <usertrap+0xb0>
    80002a74:	4901                	li	s2,0
    exit(-1,p->exit_msg);
    80002a76:	04048593          	addi	a1,s1,64
    80002a7a:	557d                	li	a0,-1
    80002a7c:	00000097          	auipc	ra,0x0
    80002a80:	8b0080e7          	jalr	-1872(ra) # 8000232c <exit>
  if(which_dev == 2){
    80002a84:	4789                	li	a5,2
    80002a86:	06f90163          	beq	s2,a5,80002ae8 <usertrap+0x10e>
  usertrapret();
    80002a8a:	00000097          	auipc	ra,0x0
    80002a8e:	dd2080e7          	jalr	-558(ra) # 8000285c <usertrapret>
}
    80002a92:	60e2                	ld	ra,24(sp)
    80002a94:	6442                	ld	s0,16(sp)
    80002a96:	64a2                	ld	s1,8(sp)
    80002a98:	6902                	ld	s2,0(sp)
    80002a9a:	6105                	addi	sp,sp,32
    80002a9c:	8082                	ret
      exit(-1,p->exit_msg);
    80002a9e:	04048593          	addi	a1,s1,64
    80002aa2:	557d                	li	a0,-1
    80002aa4:	00000097          	auipc	ra,0x0
    80002aa8:	888080e7          	jalr	-1912(ra) # 8000232c <exit>
    80002aac:	b745                	j	80002a4c <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002aae:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002ab2:	5890                	lw	a2,48(s1)
    80002ab4:	00006517          	auipc	a0,0x6
    80002ab8:	89450513          	addi	a0,a0,-1900 # 80008348 <states.0+0x78>
    80002abc:	ffffe097          	auipc	ra,0xffffe
    80002ac0:	acc080e7          	jalr	-1332(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ac4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ac8:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002acc:	00006517          	auipc	a0,0x6
    80002ad0:	8ac50513          	addi	a0,a0,-1876 # 80008378 <states.0+0xa8>
    80002ad4:	ffffe097          	auipc	ra,0xffffe
    80002ad8:	ab4080e7          	jalr	-1356(ra) # 80000588 <printf>
    setkilled(p);
    80002adc:	8526                	mv	a0,s1
    80002ade:	00000097          	auipc	ra,0x0
    80002ae2:	9ac080e7          	jalr	-1620(ra) # 8000248a <setkilled>
    80002ae6:	b749                	j	80002a68 <usertrap+0x8e>
    myproc()->accumulator+=myproc()->ps_priority;
    80002ae8:	fffff097          	auipc	ra,0xfffff
    80002aec:	ee2080e7          	jalr	-286(ra) # 800019ca <myproc>
    80002af0:	7524                	ld	s1,104(a0)
    80002af2:	fffff097          	auipc	ra,0xfffff
    80002af6:	ed8080e7          	jalr	-296(ra) # 800019ca <myproc>
    80002afa:	713c                	ld	a5,96(a0)
    80002afc:	97a6                	add	a5,a5,s1
    80002afe:	f13c                	sd	a5,96(a0)
    yield();
    80002b00:	fffff097          	auipc	ra,0xfffff
    80002b04:	688080e7          	jalr	1672(ra) # 80002188 <yield>
    80002b08:	b749                	j	80002a8a <usertrap+0xb0>

0000000080002b0a <kerneltrap>:
{
    80002b0a:	7179                	addi	sp,sp,-48
    80002b0c:	f406                	sd	ra,40(sp)
    80002b0e:	f022                	sd	s0,32(sp)
    80002b10:	ec26                	sd	s1,24(sp)
    80002b12:	e84a                	sd	s2,16(sp)
    80002b14:	e44e                	sd	s3,8(sp)
    80002b16:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b18:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b1c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b20:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002b24:	1004f793          	andi	a5,s1,256
    80002b28:	cb85                	beqz	a5,80002b58 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b2a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002b2e:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002b30:	ef85                	bnez	a5,80002b68 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002b32:	00000097          	auipc	ra,0x0
    80002b36:	e06080e7          	jalr	-506(ra) # 80002938 <devintr>
    80002b3a:	cd1d                	beqz	a0,80002b78 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING){
    80002b3c:	4789                	li	a5,2
    80002b3e:	06f50a63          	beq	a0,a5,80002bb2 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b42:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b46:	10049073          	csrw	sstatus,s1
}
    80002b4a:	70a2                	ld	ra,40(sp)
    80002b4c:	7402                	ld	s0,32(sp)
    80002b4e:	64e2                	ld	s1,24(sp)
    80002b50:	6942                	ld	s2,16(sp)
    80002b52:	69a2                	ld	s3,8(sp)
    80002b54:	6145                	addi	sp,sp,48
    80002b56:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002b58:	00006517          	auipc	a0,0x6
    80002b5c:	84050513          	addi	a0,a0,-1984 # 80008398 <states.0+0xc8>
    80002b60:	ffffe097          	auipc	ra,0xffffe
    80002b64:	9de080e7          	jalr	-1570(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002b68:	00006517          	auipc	a0,0x6
    80002b6c:	85850513          	addi	a0,a0,-1960 # 800083c0 <states.0+0xf0>
    80002b70:	ffffe097          	auipc	ra,0xffffe
    80002b74:	9ce080e7          	jalr	-1586(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002b78:	85ce                	mv	a1,s3
    80002b7a:	00006517          	auipc	a0,0x6
    80002b7e:	86650513          	addi	a0,a0,-1946 # 800083e0 <states.0+0x110>
    80002b82:	ffffe097          	auipc	ra,0xffffe
    80002b86:	a06080e7          	jalr	-1530(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b8a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b8e:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b92:	00006517          	auipc	a0,0x6
    80002b96:	85e50513          	addi	a0,a0,-1954 # 800083f0 <states.0+0x120>
    80002b9a:	ffffe097          	auipc	ra,0xffffe
    80002b9e:	9ee080e7          	jalr	-1554(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002ba2:	00006517          	auipc	a0,0x6
    80002ba6:	86650513          	addi	a0,a0,-1946 # 80008408 <states.0+0x138>
    80002baa:	ffffe097          	auipc	ra,0xffffe
    80002bae:	994080e7          	jalr	-1644(ra) # 8000053e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING){
    80002bb2:	fffff097          	auipc	ra,0xfffff
    80002bb6:	e18080e7          	jalr	-488(ra) # 800019ca <myproc>
    80002bba:	d541                	beqz	a0,80002b42 <kerneltrap+0x38>
    80002bbc:	fffff097          	auipc	ra,0xfffff
    80002bc0:	e0e080e7          	jalr	-498(ra) # 800019ca <myproc>
    80002bc4:	4d18                	lw	a4,24(a0)
    80002bc6:	4791                	li	a5,4
    80002bc8:	f6f71de3          	bne	a4,a5,80002b42 <kerneltrap+0x38>
    myproc()->accumulator+=myproc()->ps_priority;
    80002bcc:	fffff097          	auipc	ra,0xfffff
    80002bd0:	dfe080e7          	jalr	-514(ra) # 800019ca <myproc>
    80002bd4:	06853983          	ld	s3,104(a0)
    80002bd8:	fffff097          	auipc	ra,0xfffff
    80002bdc:	df2080e7          	jalr	-526(ra) # 800019ca <myproc>
    80002be0:	713c                	ld	a5,96(a0)
    80002be2:	97ce                	add	a5,a5,s3
    80002be4:	f13c                	sd	a5,96(a0)
    yield();
    80002be6:	fffff097          	auipc	ra,0xfffff
    80002bea:	5a2080e7          	jalr	1442(ra) # 80002188 <yield>
    80002bee:	bf91                	j	80002b42 <kerneltrap+0x38>

0000000080002bf0 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002bf0:	1101                	addi	sp,sp,-32
    80002bf2:	ec06                	sd	ra,24(sp)
    80002bf4:	e822                	sd	s0,16(sp)
    80002bf6:	e426                	sd	s1,8(sp)
    80002bf8:	1000                	addi	s0,sp,32
    80002bfa:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002bfc:	fffff097          	auipc	ra,0xfffff
    80002c00:	dce080e7          	jalr	-562(ra) # 800019ca <myproc>
  switch (n) {
    80002c04:	4795                	li	a5,5
    80002c06:	0497e163          	bltu	a5,s1,80002c48 <argraw+0x58>
    80002c0a:	048a                	slli	s1,s1,0x2
    80002c0c:	00006717          	auipc	a4,0x6
    80002c10:	83470713          	addi	a4,a4,-1996 # 80008440 <states.0+0x170>
    80002c14:	94ba                	add	s1,s1,a4
    80002c16:	409c                	lw	a5,0(s1)
    80002c18:	97ba                	add	a5,a5,a4
    80002c1a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002c1c:	6d5c                	ld	a5,152(a0)
    80002c1e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002c20:	60e2                	ld	ra,24(sp)
    80002c22:	6442                	ld	s0,16(sp)
    80002c24:	64a2                	ld	s1,8(sp)
    80002c26:	6105                	addi	sp,sp,32
    80002c28:	8082                	ret
    return p->trapframe->a1;
    80002c2a:	6d5c                	ld	a5,152(a0)
    80002c2c:	7fa8                	ld	a0,120(a5)
    80002c2e:	bfcd                	j	80002c20 <argraw+0x30>
    return p->trapframe->a2;
    80002c30:	6d5c                	ld	a5,152(a0)
    80002c32:	63c8                	ld	a0,128(a5)
    80002c34:	b7f5                	j	80002c20 <argraw+0x30>
    return p->trapframe->a3;
    80002c36:	6d5c                	ld	a5,152(a0)
    80002c38:	67c8                	ld	a0,136(a5)
    80002c3a:	b7dd                	j	80002c20 <argraw+0x30>
    return p->trapframe->a4;
    80002c3c:	6d5c                	ld	a5,152(a0)
    80002c3e:	6bc8                	ld	a0,144(a5)
    80002c40:	b7c5                	j	80002c20 <argraw+0x30>
    return p->trapframe->a5;
    80002c42:	6d5c                	ld	a5,152(a0)
    80002c44:	6fc8                	ld	a0,152(a5)
    80002c46:	bfe9                	j	80002c20 <argraw+0x30>
  panic("argraw");
    80002c48:	00005517          	auipc	a0,0x5
    80002c4c:	7d050513          	addi	a0,a0,2000 # 80008418 <states.0+0x148>
    80002c50:	ffffe097          	auipc	ra,0xffffe
    80002c54:	8ee080e7          	jalr	-1810(ra) # 8000053e <panic>

0000000080002c58 <fetchaddr>:
{
    80002c58:	1101                	addi	sp,sp,-32
    80002c5a:	ec06                	sd	ra,24(sp)
    80002c5c:	e822                	sd	s0,16(sp)
    80002c5e:	e426                	sd	s1,8(sp)
    80002c60:	e04a                	sd	s2,0(sp)
    80002c62:	1000                	addi	s0,sp,32
    80002c64:	84aa                	mv	s1,a0
    80002c66:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002c68:	fffff097          	auipc	ra,0xfffff
    80002c6c:	d62080e7          	jalr	-670(ra) # 800019ca <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002c70:	655c                	ld	a5,136(a0)
    80002c72:	02f4f863          	bgeu	s1,a5,80002ca2 <fetchaddr+0x4a>
    80002c76:	00848713          	addi	a4,s1,8
    80002c7a:	02e7e663          	bltu	a5,a4,80002ca6 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002c7e:	46a1                	li	a3,8
    80002c80:	8626                	mv	a2,s1
    80002c82:	85ca                	mv	a1,s2
    80002c84:	6948                	ld	a0,144(a0)
    80002c86:	fffff097          	auipc	ra,0xfffff
    80002c8a:	a6e080e7          	jalr	-1426(ra) # 800016f4 <copyin>
    80002c8e:	00a03533          	snez	a0,a0
    80002c92:	40a00533          	neg	a0,a0
}
    80002c96:	60e2                	ld	ra,24(sp)
    80002c98:	6442                	ld	s0,16(sp)
    80002c9a:	64a2                	ld	s1,8(sp)
    80002c9c:	6902                	ld	s2,0(sp)
    80002c9e:	6105                	addi	sp,sp,32
    80002ca0:	8082                	ret
    return -1;
    80002ca2:	557d                	li	a0,-1
    80002ca4:	bfcd                	j	80002c96 <fetchaddr+0x3e>
    80002ca6:	557d                	li	a0,-1
    80002ca8:	b7fd                	j	80002c96 <fetchaddr+0x3e>

0000000080002caa <fetchstr>:
{
    80002caa:	7179                	addi	sp,sp,-48
    80002cac:	f406                	sd	ra,40(sp)
    80002cae:	f022                	sd	s0,32(sp)
    80002cb0:	ec26                	sd	s1,24(sp)
    80002cb2:	e84a                	sd	s2,16(sp)
    80002cb4:	e44e                	sd	s3,8(sp)
    80002cb6:	1800                	addi	s0,sp,48
    80002cb8:	892a                	mv	s2,a0
    80002cba:	84ae                	mv	s1,a1
    80002cbc:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002cbe:	fffff097          	auipc	ra,0xfffff
    80002cc2:	d0c080e7          	jalr	-756(ra) # 800019ca <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002cc6:	86ce                	mv	a3,s3
    80002cc8:	864a                	mv	a2,s2
    80002cca:	85a6                	mv	a1,s1
    80002ccc:	6948                	ld	a0,144(a0)
    80002cce:	fffff097          	auipc	ra,0xfffff
    80002cd2:	ab4080e7          	jalr	-1356(ra) # 80001782 <copyinstr>
    80002cd6:	00054e63          	bltz	a0,80002cf2 <fetchstr+0x48>
  return strlen(buf);
    80002cda:	8526                	mv	a0,s1
    80002cdc:	ffffe097          	auipc	ra,0xffffe
    80002ce0:	172080e7          	jalr	370(ra) # 80000e4e <strlen>
}
    80002ce4:	70a2                	ld	ra,40(sp)
    80002ce6:	7402                	ld	s0,32(sp)
    80002ce8:	64e2                	ld	s1,24(sp)
    80002cea:	6942                	ld	s2,16(sp)
    80002cec:	69a2                	ld	s3,8(sp)
    80002cee:	6145                	addi	sp,sp,48
    80002cf0:	8082                	ret
    return -1;
    80002cf2:	557d                	li	a0,-1
    80002cf4:	bfc5                	j	80002ce4 <fetchstr+0x3a>

0000000080002cf6 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002cf6:	1101                	addi	sp,sp,-32
    80002cf8:	ec06                	sd	ra,24(sp)
    80002cfa:	e822                	sd	s0,16(sp)
    80002cfc:	e426                	sd	s1,8(sp)
    80002cfe:	1000                	addi	s0,sp,32
    80002d00:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d02:	00000097          	auipc	ra,0x0
    80002d06:	eee080e7          	jalr	-274(ra) # 80002bf0 <argraw>
    80002d0a:	c088                	sw	a0,0(s1)
}
    80002d0c:	60e2                	ld	ra,24(sp)
    80002d0e:	6442                	ld	s0,16(sp)
    80002d10:	64a2                	ld	s1,8(sp)
    80002d12:	6105                	addi	sp,sp,32
    80002d14:	8082                	ret

0000000080002d16 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002d16:	1101                	addi	sp,sp,-32
    80002d18:	ec06                	sd	ra,24(sp)
    80002d1a:	e822                	sd	s0,16(sp)
    80002d1c:	e426                	sd	s1,8(sp)
    80002d1e:	1000                	addi	s0,sp,32
    80002d20:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d22:	00000097          	auipc	ra,0x0
    80002d26:	ece080e7          	jalr	-306(ra) # 80002bf0 <argraw>
    80002d2a:	e088                	sd	a0,0(s1)
}
    80002d2c:	60e2                	ld	ra,24(sp)
    80002d2e:	6442                	ld	s0,16(sp)
    80002d30:	64a2                	ld	s1,8(sp)
    80002d32:	6105                	addi	sp,sp,32
    80002d34:	8082                	ret

0000000080002d36 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002d36:	7179                	addi	sp,sp,-48
    80002d38:	f406                	sd	ra,40(sp)
    80002d3a:	f022                	sd	s0,32(sp)
    80002d3c:	ec26                	sd	s1,24(sp)
    80002d3e:	e84a                	sd	s2,16(sp)
    80002d40:	1800                	addi	s0,sp,48
    80002d42:	84ae                	mv	s1,a1
    80002d44:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002d46:	fd840593          	addi	a1,s0,-40
    80002d4a:	00000097          	auipc	ra,0x0
    80002d4e:	fcc080e7          	jalr	-52(ra) # 80002d16 <argaddr>
  return fetchstr(addr, buf, max);
    80002d52:	864a                	mv	a2,s2
    80002d54:	85a6                	mv	a1,s1
    80002d56:	fd843503          	ld	a0,-40(s0)
    80002d5a:	00000097          	auipc	ra,0x0
    80002d5e:	f50080e7          	jalr	-176(ra) # 80002caa <fetchstr>
}
    80002d62:	70a2                	ld	ra,40(sp)
    80002d64:	7402                	ld	s0,32(sp)
    80002d66:	64e2                	ld	s1,24(sp)
    80002d68:	6942                	ld	s2,16(sp)
    80002d6a:	6145                	addi	sp,sp,48
    80002d6c:	8082                	ret

0000000080002d6e <syscall>:
[SYS_set_cfs_priority] sys_set_cfs_priority,
};

void
syscall(void)
{
    80002d6e:	1101                	addi	sp,sp,-32
    80002d70:	ec06                	sd	ra,24(sp)
    80002d72:	e822                	sd	s0,16(sp)
    80002d74:	e426                	sd	s1,8(sp)
    80002d76:	e04a                	sd	s2,0(sp)
    80002d78:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002d7a:	fffff097          	auipc	ra,0xfffff
    80002d7e:	c50080e7          	jalr	-944(ra) # 800019ca <myproc>
    80002d82:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002d84:	09853903          	ld	s2,152(a0)
    80002d88:	0a893783          	ld	a5,168(s2)
    80002d8c:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002d90:	37fd                	addiw	a5,a5,-1
    80002d92:	475d                	li	a4,23
    80002d94:	00f76f63          	bltu	a4,a5,80002db2 <syscall+0x44>
    80002d98:	00369713          	slli	a4,a3,0x3
    80002d9c:	00005797          	auipc	a5,0x5
    80002da0:	6bc78793          	addi	a5,a5,1724 # 80008458 <syscalls>
    80002da4:	97ba                	add	a5,a5,a4
    80002da6:	639c                	ld	a5,0(a5)
    80002da8:	c789                	beqz	a5,80002db2 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002daa:	9782                	jalr	a5
    80002dac:	06a93823          	sd	a0,112(s2)
    80002db0:	a839                	j	80002dce <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002db2:	19848613          	addi	a2,s1,408
    80002db6:	588c                	lw	a1,48(s1)
    80002db8:	00005517          	auipc	a0,0x5
    80002dbc:	66850513          	addi	a0,a0,1640 # 80008420 <states.0+0x150>
    80002dc0:	ffffd097          	auipc	ra,0xffffd
    80002dc4:	7c8080e7          	jalr	1992(ra) # 80000588 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002dc8:	6cdc                	ld	a5,152(s1)
    80002dca:	577d                	li	a4,-1
    80002dcc:	fbb8                	sd	a4,112(a5)
  }
}
    80002dce:	60e2                	ld	ra,24(sp)
    80002dd0:	6442                	ld	s0,16(sp)
    80002dd2:	64a2                	ld	s1,8(sp)
    80002dd4:	6902                	ld	s2,0(sp)
    80002dd6:	6105                	addi	sp,sp,32
    80002dd8:	8082                	ret

0000000080002dda <sys_memsize>:
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
uint64
sys_memsize(void)
{
    80002dda:	1141                	addi	sp,sp,-16
    80002ddc:	e406                	sd	ra,8(sp)
    80002dde:	e022                	sd	s0,0(sp)
    80002de0:	0800                	addi	s0,sp,16
  return myproc()->sz;
    80002de2:	fffff097          	auipc	ra,0xfffff
    80002de6:	be8080e7          	jalr	-1048(ra) # 800019ca <myproc>
}
    80002dea:	6548                	ld	a0,136(a0)
    80002dec:	60a2                	ld	ra,8(sp)
    80002dee:	6402                	ld	s0,0(sp)
    80002df0:	0141                	addi	sp,sp,16
    80002df2:	8082                	ret

0000000080002df4 <sys_exit>:
uint64
sys_exit(void)
{
    80002df4:	7139                	addi	sp,sp,-64
    80002df6:	fc06                	sd	ra,56(sp)
    80002df8:	f822                	sd	s0,48(sp)
    80002dfa:	0080                	addi	s0,sp,64
  int n;
  char msg[32];
  argint(0, &n);
    80002dfc:	fec40593          	addi	a1,s0,-20
    80002e00:	4501                	li	a0,0
    80002e02:	00000097          	auipc	ra,0x0
    80002e06:	ef4080e7          	jalr	-268(ra) # 80002cf6 <argint>
  argstr(1,msg,32);
    80002e0a:	02000613          	li	a2,32
    80002e0e:	fc840593          	addi	a1,s0,-56
    80002e12:	4505                	li	a0,1
    80002e14:	00000097          	auipc	ra,0x0
    80002e18:	f22080e7          	jalr	-222(ra) # 80002d36 <argstr>
  exit(n, msg);
    80002e1c:	fc840593          	addi	a1,s0,-56
    80002e20:	fec42503          	lw	a0,-20(s0)
    80002e24:	fffff097          	auipc	ra,0xfffff
    80002e28:	508080e7          	jalr	1288(ra) # 8000232c <exit>
  return 0;  // not reached
}
    80002e2c:	4501                	li	a0,0
    80002e2e:	70e2                	ld	ra,56(sp)
    80002e30:	7442                	ld	s0,48(sp)
    80002e32:	6121                	addi	sp,sp,64
    80002e34:	8082                	ret

0000000080002e36 <sys_set_cfs_priority>:
uint64 
sys_set_cfs_priority(void) {
    80002e36:	1101                	addi	sp,sp,-32
    80002e38:	ec06                	sd	ra,24(sp)
    80002e3a:	e822                	sd	s0,16(sp)
    80002e3c:	1000                	addi	s0,sp,32
  int priority;
  argint(0, &priority);
    80002e3e:	fec40593          	addi	a1,s0,-20
    80002e42:	4501                	li	a0,0
    80002e44:	00000097          	auipc	ra,0x0
    80002e48:	eb2080e7          	jalr	-334(ra) # 80002cf6 <argint>
  if (priority >2 || priority<0){
    80002e4c:	fec42703          	lw	a4,-20(s0)
    80002e50:	4789                	li	a5,2
    return -1;
    80002e52:	557d                	li	a0,-1
  if (priority >2 || priority<0){
    80002e54:	00e7ea63          	bltu	a5,a4,80002e68 <sys_set_cfs_priority+0x32>
  }
  myproc()->cfs_priority=priority;
    80002e58:	fffff097          	auipc	ra,0xfffff
    80002e5c:	b72080e7          	jalr	-1166(ra) # 800019ca <myproc>
    80002e60:	fec42783          	lw	a5,-20(s0)
    80002e64:	d93c                	sw	a5,112(a0)
  return 0;
    80002e66:	4501                	li	a0,0
}
    80002e68:	60e2                	ld	ra,24(sp)
    80002e6a:	6442                	ld	s0,16(sp)
    80002e6c:	6105                	addi	sp,sp,32
    80002e6e:	8082                	ret

0000000080002e70 <sys_set_ps_priority>:
uint64 
sys_set_ps_priority(void) {
    80002e70:	7179                	addi	sp,sp,-48
    80002e72:	f406                	sd	ra,40(sp)
    80002e74:	f022                	sd	s0,32(sp)
    80002e76:	ec26                	sd	s1,24(sp)
    80002e78:	1800                	addi	s0,sp,48
  int priority;
  argint(0, &priority);
    80002e7a:	fdc40593          	addi	a1,s0,-36
    80002e7e:	4501                	li	a0,0
    80002e80:	00000097          	auipc	ra,0x0
    80002e84:	e76080e7          	jalr	-394(ra) # 80002cf6 <argint>
  if (priority < 1 || priority > 10) {
    80002e88:	fdc42483          	lw	s1,-36(s0)
    80002e8c:	fff4871b          	addiw	a4,s1,-1
    80002e90:	47a5                	li	a5,9
    return -1;
    80002e92:	557d                	li	a0,-1
  if (priority < 1 || priority > 10) {
    80002e94:	00e7e863          	bltu	a5,a4,80002ea4 <sys_set_ps_priority+0x34>
  }
  myproc()->ps_priority = priority;
    80002e98:	fffff097          	auipc	ra,0xfffff
    80002e9c:	b32080e7          	jalr	-1230(ra) # 800019ca <myproc>
    80002ea0:	f524                	sd	s1,104(a0)
  return 0;
    80002ea2:	4501                	li	a0,0
}
    80002ea4:	70a2                	ld	ra,40(sp)
    80002ea6:	7402                	ld	s0,32(sp)
    80002ea8:	64e2                	ld	s1,24(sp)
    80002eaa:	6145                	addi	sp,sp,48
    80002eac:	8082                	ret

0000000080002eae <sys_getpid>:
uint64
sys_getpid(void)
{
    80002eae:	1141                	addi	sp,sp,-16
    80002eb0:	e406                	sd	ra,8(sp)
    80002eb2:	e022                	sd	s0,0(sp)
    80002eb4:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002eb6:	fffff097          	auipc	ra,0xfffff
    80002eba:	b14080e7          	jalr	-1260(ra) # 800019ca <myproc>
}
    80002ebe:	5908                	lw	a0,48(a0)
    80002ec0:	60a2                	ld	ra,8(sp)
    80002ec2:	6402                	ld	s0,0(sp)
    80002ec4:	0141                	addi	sp,sp,16
    80002ec6:	8082                	ret

0000000080002ec8 <sys_fork>:

uint64
sys_fork(void)
{
    80002ec8:	1141                	addi	sp,sp,-16
    80002eca:	e406                	sd	ra,8(sp)
    80002ecc:	e022                	sd	s0,0(sp)
    80002ece:	0800                	addi	s0,sp,16
  return fork();
    80002ed0:	fffff097          	auipc	ra,0xfffff
    80002ed4:	eb0080e7          	jalr	-336(ra) # 80001d80 <fork>
}
    80002ed8:	60a2                	ld	ra,8(sp)
    80002eda:	6402                	ld	s0,0(sp)
    80002edc:	0141                	addi	sp,sp,16
    80002ede:	8082                	ret

0000000080002ee0 <sys_wait>:

uint64
sys_wait(void)
{
    80002ee0:	1101                	addi	sp,sp,-32
    80002ee2:	ec06                	sd	ra,24(sp)
    80002ee4:	e822                	sd	s0,16(sp)
    80002ee6:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002ee8:	fe840593          	addi	a1,s0,-24
    80002eec:	4501                	li	a0,0
    80002eee:	00000097          	auipc	ra,0x0
    80002ef2:	e28080e7          	jalr	-472(ra) # 80002d16 <argaddr>
  uint64 p2;
  argaddr(1, &p2);
    80002ef6:	fe040593          	addi	a1,s0,-32
    80002efa:	4505                	li	a0,1
    80002efc:	00000097          	auipc	ra,0x0
    80002f00:	e1a080e7          	jalr	-486(ra) # 80002d16 <argaddr>
  return wait(p,p2);
    80002f04:	fe043583          	ld	a1,-32(s0)
    80002f08:	fe843503          	ld	a0,-24(s0)
    80002f0c:	fffff097          	auipc	ra,0xfffff
    80002f10:	5dc080e7          	jalr	1500(ra) # 800024e8 <wait>
}
    80002f14:	60e2                	ld	ra,24(sp)
    80002f16:	6442                	ld	s0,16(sp)
    80002f18:	6105                	addi	sp,sp,32
    80002f1a:	8082                	ret

0000000080002f1c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002f1c:	7179                	addi	sp,sp,-48
    80002f1e:	f406                	sd	ra,40(sp)
    80002f20:	f022                	sd	s0,32(sp)
    80002f22:	ec26                	sd	s1,24(sp)
    80002f24:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002f26:	fdc40593          	addi	a1,s0,-36
    80002f2a:	4501                	li	a0,0
    80002f2c:	00000097          	auipc	ra,0x0
    80002f30:	dca080e7          	jalr	-566(ra) # 80002cf6 <argint>
  addr = myproc()->sz;
    80002f34:	fffff097          	auipc	ra,0xfffff
    80002f38:	a96080e7          	jalr	-1386(ra) # 800019ca <myproc>
    80002f3c:	6544                	ld	s1,136(a0)
  if(growproc(n) < 0)
    80002f3e:	fdc42503          	lw	a0,-36(s0)
    80002f42:	fffff097          	auipc	ra,0xfffff
    80002f46:	de2080e7          	jalr	-542(ra) # 80001d24 <growproc>
    80002f4a:	00054863          	bltz	a0,80002f5a <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002f4e:	8526                	mv	a0,s1
    80002f50:	70a2                	ld	ra,40(sp)
    80002f52:	7402                	ld	s0,32(sp)
    80002f54:	64e2                	ld	s1,24(sp)
    80002f56:	6145                	addi	sp,sp,48
    80002f58:	8082                	ret
    return -1;
    80002f5a:	54fd                	li	s1,-1
    80002f5c:	bfcd                	j	80002f4e <sys_sbrk+0x32>

0000000080002f5e <sys_sleep>:

uint64
sys_sleep(void)
{
    80002f5e:	7139                	addi	sp,sp,-64
    80002f60:	fc06                	sd	ra,56(sp)
    80002f62:	f822                	sd	s0,48(sp)
    80002f64:	f426                	sd	s1,40(sp)
    80002f66:	f04a                	sd	s2,32(sp)
    80002f68:	ec4e                	sd	s3,24(sp)
    80002f6a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002f6c:	fcc40593          	addi	a1,s0,-52
    80002f70:	4501                	li	a0,0
    80002f72:	00000097          	auipc	ra,0x0
    80002f76:	d84080e7          	jalr	-636(ra) # 80002cf6 <argint>
  acquire(&tickslock);
    80002f7a:	00015517          	auipc	a0,0x15
    80002f7e:	a2650513          	addi	a0,a0,-1498 # 800179a0 <tickslock>
    80002f82:	ffffe097          	auipc	ra,0xffffe
    80002f86:	c54080e7          	jalr	-940(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80002f8a:	00006917          	auipc	s2,0x6
    80002f8e:	97692903          	lw	s2,-1674(s2) # 80008900 <ticks>
  while(ticks - ticks0 < n){
    80002f92:	fcc42783          	lw	a5,-52(s0)
    80002f96:	cf9d                	beqz	a5,80002fd4 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002f98:	00015997          	auipc	s3,0x15
    80002f9c:	a0898993          	addi	s3,s3,-1528 # 800179a0 <tickslock>
    80002fa0:	00006497          	auipc	s1,0x6
    80002fa4:	96048493          	addi	s1,s1,-1696 # 80008900 <ticks>
    if(killed(myproc())){
    80002fa8:	fffff097          	auipc	ra,0xfffff
    80002fac:	a22080e7          	jalr	-1502(ra) # 800019ca <myproc>
    80002fb0:	fffff097          	auipc	ra,0xfffff
    80002fb4:	506080e7          	jalr	1286(ra) # 800024b6 <killed>
    80002fb8:	ed15                	bnez	a0,80002ff4 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002fba:	85ce                	mv	a1,s3
    80002fbc:	8526                	mv	a0,s1
    80002fbe:	fffff097          	auipc	ra,0xfffff
    80002fc2:	206080e7          	jalr	518(ra) # 800021c4 <sleep>
  while(ticks - ticks0 < n){
    80002fc6:	409c                	lw	a5,0(s1)
    80002fc8:	412787bb          	subw	a5,a5,s2
    80002fcc:	fcc42703          	lw	a4,-52(s0)
    80002fd0:	fce7ece3          	bltu	a5,a4,80002fa8 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002fd4:	00015517          	auipc	a0,0x15
    80002fd8:	9cc50513          	addi	a0,a0,-1588 # 800179a0 <tickslock>
    80002fdc:	ffffe097          	auipc	ra,0xffffe
    80002fe0:	cae080e7          	jalr	-850(ra) # 80000c8a <release>
  return 0;
    80002fe4:	4501                	li	a0,0
}
    80002fe6:	70e2                	ld	ra,56(sp)
    80002fe8:	7442                	ld	s0,48(sp)
    80002fea:	74a2                	ld	s1,40(sp)
    80002fec:	7902                	ld	s2,32(sp)
    80002fee:	69e2                	ld	s3,24(sp)
    80002ff0:	6121                	addi	sp,sp,64
    80002ff2:	8082                	ret
      release(&tickslock);
    80002ff4:	00015517          	auipc	a0,0x15
    80002ff8:	9ac50513          	addi	a0,a0,-1620 # 800179a0 <tickslock>
    80002ffc:	ffffe097          	auipc	ra,0xffffe
    80003000:	c8e080e7          	jalr	-882(ra) # 80000c8a <release>
      return -1;
    80003004:	557d                	li	a0,-1
    80003006:	b7c5                	j	80002fe6 <sys_sleep+0x88>

0000000080003008 <sys_kill>:

uint64
sys_kill(void)
{
    80003008:	1101                	addi	sp,sp,-32
    8000300a:	ec06                	sd	ra,24(sp)
    8000300c:	e822                	sd	s0,16(sp)
    8000300e:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003010:	fec40593          	addi	a1,s0,-20
    80003014:	4501                	li	a0,0
    80003016:	00000097          	auipc	ra,0x0
    8000301a:	ce0080e7          	jalr	-800(ra) # 80002cf6 <argint>
  return kill(pid);
    8000301e:	fec42503          	lw	a0,-20(s0)
    80003022:	fffff097          	auipc	ra,0xfffff
    80003026:	3f6080e7          	jalr	1014(ra) # 80002418 <kill>
}
    8000302a:	60e2                	ld	ra,24(sp)
    8000302c:	6442                	ld	s0,16(sp)
    8000302e:	6105                	addi	sp,sp,32
    80003030:	8082                	ret

0000000080003032 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003032:	1101                	addi	sp,sp,-32
    80003034:	ec06                	sd	ra,24(sp)
    80003036:	e822                	sd	s0,16(sp)
    80003038:	e426                	sd	s1,8(sp)
    8000303a:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000303c:	00015517          	auipc	a0,0x15
    80003040:	96450513          	addi	a0,a0,-1692 # 800179a0 <tickslock>
    80003044:	ffffe097          	auipc	ra,0xffffe
    80003048:	b92080e7          	jalr	-1134(ra) # 80000bd6 <acquire>
  xticks = ticks;
    8000304c:	00006497          	auipc	s1,0x6
    80003050:	8b44a483          	lw	s1,-1868(s1) # 80008900 <ticks>
  release(&tickslock);
    80003054:	00015517          	auipc	a0,0x15
    80003058:	94c50513          	addi	a0,a0,-1716 # 800179a0 <tickslock>
    8000305c:	ffffe097          	auipc	ra,0xffffe
    80003060:	c2e080e7          	jalr	-978(ra) # 80000c8a <release>
  return xticks;
}
    80003064:	02049513          	slli	a0,s1,0x20
    80003068:	9101                	srli	a0,a0,0x20
    8000306a:	60e2                	ld	ra,24(sp)
    8000306c:	6442                	ld	s0,16(sp)
    8000306e:	64a2                	ld	s1,8(sp)
    80003070:	6105                	addi	sp,sp,32
    80003072:	8082                	ret

0000000080003074 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003074:	7179                	addi	sp,sp,-48
    80003076:	f406                	sd	ra,40(sp)
    80003078:	f022                	sd	s0,32(sp)
    8000307a:	ec26                	sd	s1,24(sp)
    8000307c:	e84a                	sd	s2,16(sp)
    8000307e:	e44e                	sd	s3,8(sp)
    80003080:	e052                	sd	s4,0(sp)
    80003082:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003084:	00005597          	auipc	a1,0x5
    80003088:	49c58593          	addi	a1,a1,1180 # 80008520 <syscalls+0xc8>
    8000308c:	00015517          	auipc	a0,0x15
    80003090:	92c50513          	addi	a0,a0,-1748 # 800179b8 <bcache>
    80003094:	ffffe097          	auipc	ra,0xffffe
    80003098:	ab2080e7          	jalr	-1358(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000309c:	0001d797          	auipc	a5,0x1d
    800030a0:	91c78793          	addi	a5,a5,-1764 # 8001f9b8 <bcache+0x8000>
    800030a4:	0001d717          	auipc	a4,0x1d
    800030a8:	b7c70713          	addi	a4,a4,-1156 # 8001fc20 <bcache+0x8268>
    800030ac:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800030b0:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030b4:	00015497          	auipc	s1,0x15
    800030b8:	91c48493          	addi	s1,s1,-1764 # 800179d0 <bcache+0x18>
    b->next = bcache.head.next;
    800030bc:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800030be:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800030c0:	00005a17          	auipc	s4,0x5
    800030c4:	468a0a13          	addi	s4,s4,1128 # 80008528 <syscalls+0xd0>
    b->next = bcache.head.next;
    800030c8:	2b893783          	ld	a5,696(s2)
    800030cc:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800030ce:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800030d2:	85d2                	mv	a1,s4
    800030d4:	01048513          	addi	a0,s1,16
    800030d8:	00001097          	auipc	ra,0x1
    800030dc:	4c4080e7          	jalr	1220(ra) # 8000459c <initsleeplock>
    bcache.head.next->prev = b;
    800030e0:	2b893783          	ld	a5,696(s2)
    800030e4:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800030e6:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030ea:	45848493          	addi	s1,s1,1112
    800030ee:	fd349de3          	bne	s1,s3,800030c8 <binit+0x54>
  }
}
    800030f2:	70a2                	ld	ra,40(sp)
    800030f4:	7402                	ld	s0,32(sp)
    800030f6:	64e2                	ld	s1,24(sp)
    800030f8:	6942                	ld	s2,16(sp)
    800030fa:	69a2                	ld	s3,8(sp)
    800030fc:	6a02                	ld	s4,0(sp)
    800030fe:	6145                	addi	sp,sp,48
    80003100:	8082                	ret

0000000080003102 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003102:	7179                	addi	sp,sp,-48
    80003104:	f406                	sd	ra,40(sp)
    80003106:	f022                	sd	s0,32(sp)
    80003108:	ec26                	sd	s1,24(sp)
    8000310a:	e84a                	sd	s2,16(sp)
    8000310c:	e44e                	sd	s3,8(sp)
    8000310e:	1800                	addi	s0,sp,48
    80003110:	892a                	mv	s2,a0
    80003112:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003114:	00015517          	auipc	a0,0x15
    80003118:	8a450513          	addi	a0,a0,-1884 # 800179b8 <bcache>
    8000311c:	ffffe097          	auipc	ra,0xffffe
    80003120:	aba080e7          	jalr	-1350(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003124:	0001d497          	auipc	s1,0x1d
    80003128:	b4c4b483          	ld	s1,-1204(s1) # 8001fc70 <bcache+0x82b8>
    8000312c:	0001d797          	auipc	a5,0x1d
    80003130:	af478793          	addi	a5,a5,-1292 # 8001fc20 <bcache+0x8268>
    80003134:	02f48f63          	beq	s1,a5,80003172 <bread+0x70>
    80003138:	873e                	mv	a4,a5
    8000313a:	a021                	j	80003142 <bread+0x40>
    8000313c:	68a4                	ld	s1,80(s1)
    8000313e:	02e48a63          	beq	s1,a4,80003172 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003142:	449c                	lw	a5,8(s1)
    80003144:	ff279ce3          	bne	a5,s2,8000313c <bread+0x3a>
    80003148:	44dc                	lw	a5,12(s1)
    8000314a:	ff3799e3          	bne	a5,s3,8000313c <bread+0x3a>
      b->refcnt++;
    8000314e:	40bc                	lw	a5,64(s1)
    80003150:	2785                	addiw	a5,a5,1
    80003152:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003154:	00015517          	auipc	a0,0x15
    80003158:	86450513          	addi	a0,a0,-1948 # 800179b8 <bcache>
    8000315c:	ffffe097          	auipc	ra,0xffffe
    80003160:	b2e080e7          	jalr	-1234(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003164:	01048513          	addi	a0,s1,16
    80003168:	00001097          	auipc	ra,0x1
    8000316c:	46e080e7          	jalr	1134(ra) # 800045d6 <acquiresleep>
      return b;
    80003170:	a8b9                	j	800031ce <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003172:	0001d497          	auipc	s1,0x1d
    80003176:	af64b483          	ld	s1,-1290(s1) # 8001fc68 <bcache+0x82b0>
    8000317a:	0001d797          	auipc	a5,0x1d
    8000317e:	aa678793          	addi	a5,a5,-1370 # 8001fc20 <bcache+0x8268>
    80003182:	00f48863          	beq	s1,a5,80003192 <bread+0x90>
    80003186:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003188:	40bc                	lw	a5,64(s1)
    8000318a:	cf81                	beqz	a5,800031a2 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000318c:	64a4                	ld	s1,72(s1)
    8000318e:	fee49de3          	bne	s1,a4,80003188 <bread+0x86>
  panic("bget: no buffers");
    80003192:	00005517          	auipc	a0,0x5
    80003196:	39e50513          	addi	a0,a0,926 # 80008530 <syscalls+0xd8>
    8000319a:	ffffd097          	auipc	ra,0xffffd
    8000319e:	3a4080e7          	jalr	932(ra) # 8000053e <panic>
      b->dev = dev;
    800031a2:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800031a6:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800031aa:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800031ae:	4785                	li	a5,1
    800031b0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800031b2:	00015517          	auipc	a0,0x15
    800031b6:	80650513          	addi	a0,a0,-2042 # 800179b8 <bcache>
    800031ba:	ffffe097          	auipc	ra,0xffffe
    800031be:	ad0080e7          	jalr	-1328(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    800031c2:	01048513          	addi	a0,s1,16
    800031c6:	00001097          	auipc	ra,0x1
    800031ca:	410080e7          	jalr	1040(ra) # 800045d6 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800031ce:	409c                	lw	a5,0(s1)
    800031d0:	cb89                	beqz	a5,800031e2 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800031d2:	8526                	mv	a0,s1
    800031d4:	70a2                	ld	ra,40(sp)
    800031d6:	7402                	ld	s0,32(sp)
    800031d8:	64e2                	ld	s1,24(sp)
    800031da:	6942                	ld	s2,16(sp)
    800031dc:	69a2                	ld	s3,8(sp)
    800031de:	6145                	addi	sp,sp,48
    800031e0:	8082                	ret
    virtio_disk_rw(b, 0);
    800031e2:	4581                	li	a1,0
    800031e4:	8526                	mv	a0,s1
    800031e6:	00003097          	auipc	ra,0x3
    800031ea:	fde080e7          	jalr	-34(ra) # 800061c4 <virtio_disk_rw>
    b->valid = 1;
    800031ee:	4785                	li	a5,1
    800031f0:	c09c                	sw	a5,0(s1)
  return b;
    800031f2:	b7c5                	j	800031d2 <bread+0xd0>

00000000800031f4 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800031f4:	1101                	addi	sp,sp,-32
    800031f6:	ec06                	sd	ra,24(sp)
    800031f8:	e822                	sd	s0,16(sp)
    800031fa:	e426                	sd	s1,8(sp)
    800031fc:	1000                	addi	s0,sp,32
    800031fe:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003200:	0541                	addi	a0,a0,16
    80003202:	00001097          	auipc	ra,0x1
    80003206:	46e080e7          	jalr	1134(ra) # 80004670 <holdingsleep>
    8000320a:	cd01                	beqz	a0,80003222 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000320c:	4585                	li	a1,1
    8000320e:	8526                	mv	a0,s1
    80003210:	00003097          	auipc	ra,0x3
    80003214:	fb4080e7          	jalr	-76(ra) # 800061c4 <virtio_disk_rw>
}
    80003218:	60e2                	ld	ra,24(sp)
    8000321a:	6442                	ld	s0,16(sp)
    8000321c:	64a2                	ld	s1,8(sp)
    8000321e:	6105                	addi	sp,sp,32
    80003220:	8082                	ret
    panic("bwrite");
    80003222:	00005517          	auipc	a0,0x5
    80003226:	32650513          	addi	a0,a0,806 # 80008548 <syscalls+0xf0>
    8000322a:	ffffd097          	auipc	ra,0xffffd
    8000322e:	314080e7          	jalr	788(ra) # 8000053e <panic>

0000000080003232 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003232:	1101                	addi	sp,sp,-32
    80003234:	ec06                	sd	ra,24(sp)
    80003236:	e822                	sd	s0,16(sp)
    80003238:	e426                	sd	s1,8(sp)
    8000323a:	e04a                	sd	s2,0(sp)
    8000323c:	1000                	addi	s0,sp,32
    8000323e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003240:	01050913          	addi	s2,a0,16
    80003244:	854a                	mv	a0,s2
    80003246:	00001097          	auipc	ra,0x1
    8000324a:	42a080e7          	jalr	1066(ra) # 80004670 <holdingsleep>
    8000324e:	c92d                	beqz	a0,800032c0 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003250:	854a                	mv	a0,s2
    80003252:	00001097          	auipc	ra,0x1
    80003256:	3da080e7          	jalr	986(ra) # 8000462c <releasesleep>

  acquire(&bcache.lock);
    8000325a:	00014517          	auipc	a0,0x14
    8000325e:	75e50513          	addi	a0,a0,1886 # 800179b8 <bcache>
    80003262:	ffffe097          	auipc	ra,0xffffe
    80003266:	974080e7          	jalr	-1676(ra) # 80000bd6 <acquire>
  b->refcnt--;
    8000326a:	40bc                	lw	a5,64(s1)
    8000326c:	37fd                	addiw	a5,a5,-1
    8000326e:	0007871b          	sext.w	a4,a5
    80003272:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003274:	eb05                	bnez	a4,800032a4 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003276:	68bc                	ld	a5,80(s1)
    80003278:	64b8                	ld	a4,72(s1)
    8000327a:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000327c:	64bc                	ld	a5,72(s1)
    8000327e:	68b8                	ld	a4,80(s1)
    80003280:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003282:	0001c797          	auipc	a5,0x1c
    80003286:	73678793          	addi	a5,a5,1846 # 8001f9b8 <bcache+0x8000>
    8000328a:	2b87b703          	ld	a4,696(a5)
    8000328e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003290:	0001d717          	auipc	a4,0x1d
    80003294:	99070713          	addi	a4,a4,-1648 # 8001fc20 <bcache+0x8268>
    80003298:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000329a:	2b87b703          	ld	a4,696(a5)
    8000329e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800032a0:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800032a4:	00014517          	auipc	a0,0x14
    800032a8:	71450513          	addi	a0,a0,1812 # 800179b8 <bcache>
    800032ac:	ffffe097          	auipc	ra,0xffffe
    800032b0:	9de080e7          	jalr	-1570(ra) # 80000c8a <release>
}
    800032b4:	60e2                	ld	ra,24(sp)
    800032b6:	6442                	ld	s0,16(sp)
    800032b8:	64a2                	ld	s1,8(sp)
    800032ba:	6902                	ld	s2,0(sp)
    800032bc:	6105                	addi	sp,sp,32
    800032be:	8082                	ret
    panic("brelse");
    800032c0:	00005517          	auipc	a0,0x5
    800032c4:	29050513          	addi	a0,a0,656 # 80008550 <syscalls+0xf8>
    800032c8:	ffffd097          	auipc	ra,0xffffd
    800032cc:	276080e7          	jalr	630(ra) # 8000053e <panic>

00000000800032d0 <bpin>:

void
bpin(struct buf *b) {
    800032d0:	1101                	addi	sp,sp,-32
    800032d2:	ec06                	sd	ra,24(sp)
    800032d4:	e822                	sd	s0,16(sp)
    800032d6:	e426                	sd	s1,8(sp)
    800032d8:	1000                	addi	s0,sp,32
    800032da:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032dc:	00014517          	auipc	a0,0x14
    800032e0:	6dc50513          	addi	a0,a0,1756 # 800179b8 <bcache>
    800032e4:	ffffe097          	auipc	ra,0xffffe
    800032e8:	8f2080e7          	jalr	-1806(ra) # 80000bd6 <acquire>
  b->refcnt++;
    800032ec:	40bc                	lw	a5,64(s1)
    800032ee:	2785                	addiw	a5,a5,1
    800032f0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032f2:	00014517          	auipc	a0,0x14
    800032f6:	6c650513          	addi	a0,a0,1734 # 800179b8 <bcache>
    800032fa:	ffffe097          	auipc	ra,0xffffe
    800032fe:	990080e7          	jalr	-1648(ra) # 80000c8a <release>
}
    80003302:	60e2                	ld	ra,24(sp)
    80003304:	6442                	ld	s0,16(sp)
    80003306:	64a2                	ld	s1,8(sp)
    80003308:	6105                	addi	sp,sp,32
    8000330a:	8082                	ret

000000008000330c <bunpin>:

void
bunpin(struct buf *b) {
    8000330c:	1101                	addi	sp,sp,-32
    8000330e:	ec06                	sd	ra,24(sp)
    80003310:	e822                	sd	s0,16(sp)
    80003312:	e426                	sd	s1,8(sp)
    80003314:	1000                	addi	s0,sp,32
    80003316:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003318:	00014517          	auipc	a0,0x14
    8000331c:	6a050513          	addi	a0,a0,1696 # 800179b8 <bcache>
    80003320:	ffffe097          	auipc	ra,0xffffe
    80003324:	8b6080e7          	jalr	-1866(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80003328:	40bc                	lw	a5,64(s1)
    8000332a:	37fd                	addiw	a5,a5,-1
    8000332c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000332e:	00014517          	auipc	a0,0x14
    80003332:	68a50513          	addi	a0,a0,1674 # 800179b8 <bcache>
    80003336:	ffffe097          	auipc	ra,0xffffe
    8000333a:	954080e7          	jalr	-1708(ra) # 80000c8a <release>
}
    8000333e:	60e2                	ld	ra,24(sp)
    80003340:	6442                	ld	s0,16(sp)
    80003342:	64a2                	ld	s1,8(sp)
    80003344:	6105                	addi	sp,sp,32
    80003346:	8082                	ret

0000000080003348 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003348:	1101                	addi	sp,sp,-32
    8000334a:	ec06                	sd	ra,24(sp)
    8000334c:	e822                	sd	s0,16(sp)
    8000334e:	e426                	sd	s1,8(sp)
    80003350:	e04a                	sd	s2,0(sp)
    80003352:	1000                	addi	s0,sp,32
    80003354:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003356:	00d5d59b          	srliw	a1,a1,0xd
    8000335a:	0001d797          	auipc	a5,0x1d
    8000335e:	d3a7a783          	lw	a5,-710(a5) # 80020094 <sb+0x1c>
    80003362:	9dbd                	addw	a1,a1,a5
    80003364:	00000097          	auipc	ra,0x0
    80003368:	d9e080e7          	jalr	-610(ra) # 80003102 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000336c:	0074f713          	andi	a4,s1,7
    80003370:	4785                	li	a5,1
    80003372:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003376:	14ce                	slli	s1,s1,0x33
    80003378:	90d9                	srli	s1,s1,0x36
    8000337a:	00950733          	add	a4,a0,s1
    8000337e:	05874703          	lbu	a4,88(a4)
    80003382:	00e7f6b3          	and	a3,a5,a4
    80003386:	c69d                	beqz	a3,800033b4 <bfree+0x6c>
    80003388:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000338a:	94aa                	add	s1,s1,a0
    8000338c:	fff7c793          	not	a5,a5
    80003390:	8ff9                	and	a5,a5,a4
    80003392:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003396:	00001097          	auipc	ra,0x1
    8000339a:	120080e7          	jalr	288(ra) # 800044b6 <log_write>
  brelse(bp);
    8000339e:	854a                	mv	a0,s2
    800033a0:	00000097          	auipc	ra,0x0
    800033a4:	e92080e7          	jalr	-366(ra) # 80003232 <brelse>
}
    800033a8:	60e2                	ld	ra,24(sp)
    800033aa:	6442                	ld	s0,16(sp)
    800033ac:	64a2                	ld	s1,8(sp)
    800033ae:	6902                	ld	s2,0(sp)
    800033b0:	6105                	addi	sp,sp,32
    800033b2:	8082                	ret
    panic("freeing free block");
    800033b4:	00005517          	auipc	a0,0x5
    800033b8:	1a450513          	addi	a0,a0,420 # 80008558 <syscalls+0x100>
    800033bc:	ffffd097          	auipc	ra,0xffffd
    800033c0:	182080e7          	jalr	386(ra) # 8000053e <panic>

00000000800033c4 <balloc>:
{
    800033c4:	711d                	addi	sp,sp,-96
    800033c6:	ec86                	sd	ra,88(sp)
    800033c8:	e8a2                	sd	s0,80(sp)
    800033ca:	e4a6                	sd	s1,72(sp)
    800033cc:	e0ca                	sd	s2,64(sp)
    800033ce:	fc4e                	sd	s3,56(sp)
    800033d0:	f852                	sd	s4,48(sp)
    800033d2:	f456                	sd	s5,40(sp)
    800033d4:	f05a                	sd	s6,32(sp)
    800033d6:	ec5e                	sd	s7,24(sp)
    800033d8:	e862                	sd	s8,16(sp)
    800033da:	e466                	sd	s9,8(sp)
    800033dc:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800033de:	0001d797          	auipc	a5,0x1d
    800033e2:	c9e7a783          	lw	a5,-866(a5) # 8002007c <sb+0x4>
    800033e6:	10078163          	beqz	a5,800034e8 <balloc+0x124>
    800033ea:	8baa                	mv	s7,a0
    800033ec:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800033ee:	0001db17          	auipc	s6,0x1d
    800033f2:	c8ab0b13          	addi	s6,s6,-886 # 80020078 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033f6:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800033f8:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033fa:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800033fc:	6c89                	lui	s9,0x2
    800033fe:	a061                	j	80003486 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003400:	974a                	add	a4,a4,s2
    80003402:	8fd5                	or	a5,a5,a3
    80003404:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003408:	854a                	mv	a0,s2
    8000340a:	00001097          	auipc	ra,0x1
    8000340e:	0ac080e7          	jalr	172(ra) # 800044b6 <log_write>
        brelse(bp);
    80003412:	854a                	mv	a0,s2
    80003414:	00000097          	auipc	ra,0x0
    80003418:	e1e080e7          	jalr	-482(ra) # 80003232 <brelse>
  bp = bread(dev, bno);
    8000341c:	85a6                	mv	a1,s1
    8000341e:	855e                	mv	a0,s7
    80003420:	00000097          	auipc	ra,0x0
    80003424:	ce2080e7          	jalr	-798(ra) # 80003102 <bread>
    80003428:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000342a:	40000613          	li	a2,1024
    8000342e:	4581                	li	a1,0
    80003430:	05850513          	addi	a0,a0,88
    80003434:	ffffe097          	auipc	ra,0xffffe
    80003438:	89e080e7          	jalr	-1890(ra) # 80000cd2 <memset>
  log_write(bp);
    8000343c:	854a                	mv	a0,s2
    8000343e:	00001097          	auipc	ra,0x1
    80003442:	078080e7          	jalr	120(ra) # 800044b6 <log_write>
  brelse(bp);
    80003446:	854a                	mv	a0,s2
    80003448:	00000097          	auipc	ra,0x0
    8000344c:	dea080e7          	jalr	-534(ra) # 80003232 <brelse>
}
    80003450:	8526                	mv	a0,s1
    80003452:	60e6                	ld	ra,88(sp)
    80003454:	6446                	ld	s0,80(sp)
    80003456:	64a6                	ld	s1,72(sp)
    80003458:	6906                	ld	s2,64(sp)
    8000345a:	79e2                	ld	s3,56(sp)
    8000345c:	7a42                	ld	s4,48(sp)
    8000345e:	7aa2                	ld	s5,40(sp)
    80003460:	7b02                	ld	s6,32(sp)
    80003462:	6be2                	ld	s7,24(sp)
    80003464:	6c42                	ld	s8,16(sp)
    80003466:	6ca2                	ld	s9,8(sp)
    80003468:	6125                	addi	sp,sp,96
    8000346a:	8082                	ret
    brelse(bp);
    8000346c:	854a                	mv	a0,s2
    8000346e:	00000097          	auipc	ra,0x0
    80003472:	dc4080e7          	jalr	-572(ra) # 80003232 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003476:	015c87bb          	addw	a5,s9,s5
    8000347a:	00078a9b          	sext.w	s5,a5
    8000347e:	004b2703          	lw	a4,4(s6)
    80003482:	06eaf363          	bgeu	s5,a4,800034e8 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003486:	41fad79b          	sraiw	a5,s5,0x1f
    8000348a:	0137d79b          	srliw	a5,a5,0x13
    8000348e:	015787bb          	addw	a5,a5,s5
    80003492:	40d7d79b          	sraiw	a5,a5,0xd
    80003496:	01cb2583          	lw	a1,28(s6)
    8000349a:	9dbd                	addw	a1,a1,a5
    8000349c:	855e                	mv	a0,s7
    8000349e:	00000097          	auipc	ra,0x0
    800034a2:	c64080e7          	jalr	-924(ra) # 80003102 <bread>
    800034a6:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034a8:	004b2503          	lw	a0,4(s6)
    800034ac:	000a849b          	sext.w	s1,s5
    800034b0:	8662                	mv	a2,s8
    800034b2:	faa4fde3          	bgeu	s1,a0,8000346c <balloc+0xa8>
      m = 1 << (bi % 8);
    800034b6:	41f6579b          	sraiw	a5,a2,0x1f
    800034ba:	01d7d69b          	srliw	a3,a5,0x1d
    800034be:	00c6873b          	addw	a4,a3,a2
    800034c2:	00777793          	andi	a5,a4,7
    800034c6:	9f95                	subw	a5,a5,a3
    800034c8:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800034cc:	4037571b          	sraiw	a4,a4,0x3
    800034d0:	00e906b3          	add	a3,s2,a4
    800034d4:	0586c683          	lbu	a3,88(a3)
    800034d8:	00d7f5b3          	and	a1,a5,a3
    800034dc:	d195                	beqz	a1,80003400 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034de:	2605                	addiw	a2,a2,1
    800034e0:	2485                	addiw	s1,s1,1
    800034e2:	fd4618e3          	bne	a2,s4,800034b2 <balloc+0xee>
    800034e6:	b759                	j	8000346c <balloc+0xa8>
  printf("balloc: out of blocks\n");
    800034e8:	00005517          	auipc	a0,0x5
    800034ec:	08850513          	addi	a0,a0,136 # 80008570 <syscalls+0x118>
    800034f0:	ffffd097          	auipc	ra,0xffffd
    800034f4:	098080e7          	jalr	152(ra) # 80000588 <printf>
  return 0;
    800034f8:	4481                	li	s1,0
    800034fa:	bf99                	j	80003450 <balloc+0x8c>

00000000800034fc <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800034fc:	7179                	addi	sp,sp,-48
    800034fe:	f406                	sd	ra,40(sp)
    80003500:	f022                	sd	s0,32(sp)
    80003502:	ec26                	sd	s1,24(sp)
    80003504:	e84a                	sd	s2,16(sp)
    80003506:	e44e                	sd	s3,8(sp)
    80003508:	e052                	sd	s4,0(sp)
    8000350a:	1800                	addi	s0,sp,48
    8000350c:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000350e:	47ad                	li	a5,11
    80003510:	02b7e763          	bltu	a5,a1,8000353e <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003514:	02059493          	slli	s1,a1,0x20
    80003518:	9081                	srli	s1,s1,0x20
    8000351a:	048a                	slli	s1,s1,0x2
    8000351c:	94aa                	add	s1,s1,a0
    8000351e:	0504a903          	lw	s2,80(s1)
    80003522:	06091e63          	bnez	s2,8000359e <bmap+0xa2>
      addr = balloc(ip->dev);
    80003526:	4108                	lw	a0,0(a0)
    80003528:	00000097          	auipc	ra,0x0
    8000352c:	e9c080e7          	jalr	-356(ra) # 800033c4 <balloc>
    80003530:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003534:	06090563          	beqz	s2,8000359e <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003538:	0524a823          	sw	s2,80(s1)
    8000353c:	a08d                	j	8000359e <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000353e:	ff45849b          	addiw	s1,a1,-12
    80003542:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003546:	0ff00793          	li	a5,255
    8000354a:	08e7e563          	bltu	a5,a4,800035d4 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000354e:	08052903          	lw	s2,128(a0)
    80003552:	00091d63          	bnez	s2,8000356c <bmap+0x70>
      addr = balloc(ip->dev);
    80003556:	4108                	lw	a0,0(a0)
    80003558:	00000097          	auipc	ra,0x0
    8000355c:	e6c080e7          	jalr	-404(ra) # 800033c4 <balloc>
    80003560:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003564:	02090d63          	beqz	s2,8000359e <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003568:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000356c:	85ca                	mv	a1,s2
    8000356e:	0009a503          	lw	a0,0(s3)
    80003572:	00000097          	auipc	ra,0x0
    80003576:	b90080e7          	jalr	-1136(ra) # 80003102 <bread>
    8000357a:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000357c:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003580:	02049593          	slli	a1,s1,0x20
    80003584:	9181                	srli	a1,a1,0x20
    80003586:	058a                	slli	a1,a1,0x2
    80003588:	00b784b3          	add	s1,a5,a1
    8000358c:	0004a903          	lw	s2,0(s1)
    80003590:	02090063          	beqz	s2,800035b0 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003594:	8552                	mv	a0,s4
    80003596:	00000097          	auipc	ra,0x0
    8000359a:	c9c080e7          	jalr	-868(ra) # 80003232 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000359e:	854a                	mv	a0,s2
    800035a0:	70a2                	ld	ra,40(sp)
    800035a2:	7402                	ld	s0,32(sp)
    800035a4:	64e2                	ld	s1,24(sp)
    800035a6:	6942                	ld	s2,16(sp)
    800035a8:	69a2                	ld	s3,8(sp)
    800035aa:	6a02                	ld	s4,0(sp)
    800035ac:	6145                	addi	sp,sp,48
    800035ae:	8082                	ret
      addr = balloc(ip->dev);
    800035b0:	0009a503          	lw	a0,0(s3)
    800035b4:	00000097          	auipc	ra,0x0
    800035b8:	e10080e7          	jalr	-496(ra) # 800033c4 <balloc>
    800035bc:	0005091b          	sext.w	s2,a0
      if(addr){
    800035c0:	fc090ae3          	beqz	s2,80003594 <bmap+0x98>
        a[bn] = addr;
    800035c4:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800035c8:	8552                	mv	a0,s4
    800035ca:	00001097          	auipc	ra,0x1
    800035ce:	eec080e7          	jalr	-276(ra) # 800044b6 <log_write>
    800035d2:	b7c9                	j	80003594 <bmap+0x98>
  panic("bmap: out of range");
    800035d4:	00005517          	auipc	a0,0x5
    800035d8:	fb450513          	addi	a0,a0,-76 # 80008588 <syscalls+0x130>
    800035dc:	ffffd097          	auipc	ra,0xffffd
    800035e0:	f62080e7          	jalr	-158(ra) # 8000053e <panic>

00000000800035e4 <iget>:
{
    800035e4:	7179                	addi	sp,sp,-48
    800035e6:	f406                	sd	ra,40(sp)
    800035e8:	f022                	sd	s0,32(sp)
    800035ea:	ec26                	sd	s1,24(sp)
    800035ec:	e84a                	sd	s2,16(sp)
    800035ee:	e44e                	sd	s3,8(sp)
    800035f0:	e052                	sd	s4,0(sp)
    800035f2:	1800                	addi	s0,sp,48
    800035f4:	89aa                	mv	s3,a0
    800035f6:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800035f8:	0001d517          	auipc	a0,0x1d
    800035fc:	aa050513          	addi	a0,a0,-1376 # 80020098 <itable>
    80003600:	ffffd097          	auipc	ra,0xffffd
    80003604:	5d6080e7          	jalr	1494(ra) # 80000bd6 <acquire>
  empty = 0;
    80003608:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000360a:	0001d497          	auipc	s1,0x1d
    8000360e:	aa648493          	addi	s1,s1,-1370 # 800200b0 <itable+0x18>
    80003612:	0001e697          	auipc	a3,0x1e
    80003616:	52e68693          	addi	a3,a3,1326 # 80021b40 <log>
    8000361a:	a039                	j	80003628 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000361c:	02090b63          	beqz	s2,80003652 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003620:	08848493          	addi	s1,s1,136
    80003624:	02d48a63          	beq	s1,a3,80003658 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003628:	449c                	lw	a5,8(s1)
    8000362a:	fef059e3          	blez	a5,8000361c <iget+0x38>
    8000362e:	4098                	lw	a4,0(s1)
    80003630:	ff3716e3          	bne	a4,s3,8000361c <iget+0x38>
    80003634:	40d8                	lw	a4,4(s1)
    80003636:	ff4713e3          	bne	a4,s4,8000361c <iget+0x38>
      ip->ref++;
    8000363a:	2785                	addiw	a5,a5,1
    8000363c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000363e:	0001d517          	auipc	a0,0x1d
    80003642:	a5a50513          	addi	a0,a0,-1446 # 80020098 <itable>
    80003646:	ffffd097          	auipc	ra,0xffffd
    8000364a:	644080e7          	jalr	1604(ra) # 80000c8a <release>
      return ip;
    8000364e:	8926                	mv	s2,s1
    80003650:	a03d                	j	8000367e <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003652:	f7f9                	bnez	a5,80003620 <iget+0x3c>
    80003654:	8926                	mv	s2,s1
    80003656:	b7e9                	j	80003620 <iget+0x3c>
  if(empty == 0)
    80003658:	02090c63          	beqz	s2,80003690 <iget+0xac>
  ip->dev = dev;
    8000365c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003660:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003664:	4785                	li	a5,1
    80003666:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000366a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000366e:	0001d517          	auipc	a0,0x1d
    80003672:	a2a50513          	addi	a0,a0,-1494 # 80020098 <itable>
    80003676:	ffffd097          	auipc	ra,0xffffd
    8000367a:	614080e7          	jalr	1556(ra) # 80000c8a <release>
}
    8000367e:	854a                	mv	a0,s2
    80003680:	70a2                	ld	ra,40(sp)
    80003682:	7402                	ld	s0,32(sp)
    80003684:	64e2                	ld	s1,24(sp)
    80003686:	6942                	ld	s2,16(sp)
    80003688:	69a2                	ld	s3,8(sp)
    8000368a:	6a02                	ld	s4,0(sp)
    8000368c:	6145                	addi	sp,sp,48
    8000368e:	8082                	ret
    panic("iget: no inodes");
    80003690:	00005517          	auipc	a0,0x5
    80003694:	f1050513          	addi	a0,a0,-240 # 800085a0 <syscalls+0x148>
    80003698:	ffffd097          	auipc	ra,0xffffd
    8000369c:	ea6080e7          	jalr	-346(ra) # 8000053e <panic>

00000000800036a0 <fsinit>:
fsinit(int dev) {
    800036a0:	7179                	addi	sp,sp,-48
    800036a2:	f406                	sd	ra,40(sp)
    800036a4:	f022                	sd	s0,32(sp)
    800036a6:	ec26                	sd	s1,24(sp)
    800036a8:	e84a                	sd	s2,16(sp)
    800036aa:	e44e                	sd	s3,8(sp)
    800036ac:	1800                	addi	s0,sp,48
    800036ae:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800036b0:	4585                	li	a1,1
    800036b2:	00000097          	auipc	ra,0x0
    800036b6:	a50080e7          	jalr	-1456(ra) # 80003102 <bread>
    800036ba:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800036bc:	0001d997          	auipc	s3,0x1d
    800036c0:	9bc98993          	addi	s3,s3,-1604 # 80020078 <sb>
    800036c4:	02000613          	li	a2,32
    800036c8:	05850593          	addi	a1,a0,88
    800036cc:	854e                	mv	a0,s3
    800036ce:	ffffd097          	auipc	ra,0xffffd
    800036d2:	660080e7          	jalr	1632(ra) # 80000d2e <memmove>
  brelse(bp);
    800036d6:	8526                	mv	a0,s1
    800036d8:	00000097          	auipc	ra,0x0
    800036dc:	b5a080e7          	jalr	-1190(ra) # 80003232 <brelse>
  if(sb.magic != FSMAGIC)
    800036e0:	0009a703          	lw	a4,0(s3)
    800036e4:	102037b7          	lui	a5,0x10203
    800036e8:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800036ec:	02f71263          	bne	a4,a5,80003710 <fsinit+0x70>
  initlog(dev, &sb);
    800036f0:	0001d597          	auipc	a1,0x1d
    800036f4:	98858593          	addi	a1,a1,-1656 # 80020078 <sb>
    800036f8:	854a                	mv	a0,s2
    800036fa:	00001097          	auipc	ra,0x1
    800036fe:	b40080e7          	jalr	-1216(ra) # 8000423a <initlog>
}
    80003702:	70a2                	ld	ra,40(sp)
    80003704:	7402                	ld	s0,32(sp)
    80003706:	64e2                	ld	s1,24(sp)
    80003708:	6942                	ld	s2,16(sp)
    8000370a:	69a2                	ld	s3,8(sp)
    8000370c:	6145                	addi	sp,sp,48
    8000370e:	8082                	ret
    panic("invalid file system");
    80003710:	00005517          	auipc	a0,0x5
    80003714:	ea050513          	addi	a0,a0,-352 # 800085b0 <syscalls+0x158>
    80003718:	ffffd097          	auipc	ra,0xffffd
    8000371c:	e26080e7          	jalr	-474(ra) # 8000053e <panic>

0000000080003720 <iinit>:
{
    80003720:	7179                	addi	sp,sp,-48
    80003722:	f406                	sd	ra,40(sp)
    80003724:	f022                	sd	s0,32(sp)
    80003726:	ec26                	sd	s1,24(sp)
    80003728:	e84a                	sd	s2,16(sp)
    8000372a:	e44e                	sd	s3,8(sp)
    8000372c:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000372e:	00005597          	auipc	a1,0x5
    80003732:	e9a58593          	addi	a1,a1,-358 # 800085c8 <syscalls+0x170>
    80003736:	0001d517          	auipc	a0,0x1d
    8000373a:	96250513          	addi	a0,a0,-1694 # 80020098 <itable>
    8000373e:	ffffd097          	auipc	ra,0xffffd
    80003742:	408080e7          	jalr	1032(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003746:	0001d497          	auipc	s1,0x1d
    8000374a:	97a48493          	addi	s1,s1,-1670 # 800200c0 <itable+0x28>
    8000374e:	0001e997          	auipc	s3,0x1e
    80003752:	40298993          	addi	s3,s3,1026 # 80021b50 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003756:	00005917          	auipc	s2,0x5
    8000375a:	e7a90913          	addi	s2,s2,-390 # 800085d0 <syscalls+0x178>
    8000375e:	85ca                	mv	a1,s2
    80003760:	8526                	mv	a0,s1
    80003762:	00001097          	auipc	ra,0x1
    80003766:	e3a080e7          	jalr	-454(ra) # 8000459c <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000376a:	08848493          	addi	s1,s1,136
    8000376e:	ff3498e3          	bne	s1,s3,8000375e <iinit+0x3e>
}
    80003772:	70a2                	ld	ra,40(sp)
    80003774:	7402                	ld	s0,32(sp)
    80003776:	64e2                	ld	s1,24(sp)
    80003778:	6942                	ld	s2,16(sp)
    8000377a:	69a2                	ld	s3,8(sp)
    8000377c:	6145                	addi	sp,sp,48
    8000377e:	8082                	ret

0000000080003780 <ialloc>:
{
    80003780:	715d                	addi	sp,sp,-80
    80003782:	e486                	sd	ra,72(sp)
    80003784:	e0a2                	sd	s0,64(sp)
    80003786:	fc26                	sd	s1,56(sp)
    80003788:	f84a                	sd	s2,48(sp)
    8000378a:	f44e                	sd	s3,40(sp)
    8000378c:	f052                	sd	s4,32(sp)
    8000378e:	ec56                	sd	s5,24(sp)
    80003790:	e85a                	sd	s6,16(sp)
    80003792:	e45e                	sd	s7,8(sp)
    80003794:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003796:	0001d717          	auipc	a4,0x1d
    8000379a:	8ee72703          	lw	a4,-1810(a4) # 80020084 <sb+0xc>
    8000379e:	4785                	li	a5,1
    800037a0:	04e7fa63          	bgeu	a5,a4,800037f4 <ialloc+0x74>
    800037a4:	8aaa                	mv	s5,a0
    800037a6:	8bae                	mv	s7,a1
    800037a8:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800037aa:	0001da17          	auipc	s4,0x1d
    800037ae:	8cea0a13          	addi	s4,s4,-1842 # 80020078 <sb>
    800037b2:	00048b1b          	sext.w	s6,s1
    800037b6:	0044d793          	srli	a5,s1,0x4
    800037ba:	018a2583          	lw	a1,24(s4)
    800037be:	9dbd                	addw	a1,a1,a5
    800037c0:	8556                	mv	a0,s5
    800037c2:	00000097          	auipc	ra,0x0
    800037c6:	940080e7          	jalr	-1728(ra) # 80003102 <bread>
    800037ca:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800037cc:	05850993          	addi	s3,a0,88
    800037d0:	00f4f793          	andi	a5,s1,15
    800037d4:	079a                	slli	a5,a5,0x6
    800037d6:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800037d8:	00099783          	lh	a5,0(s3)
    800037dc:	c3a1                	beqz	a5,8000381c <ialloc+0x9c>
    brelse(bp);
    800037de:	00000097          	auipc	ra,0x0
    800037e2:	a54080e7          	jalr	-1452(ra) # 80003232 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800037e6:	0485                	addi	s1,s1,1
    800037e8:	00ca2703          	lw	a4,12(s4)
    800037ec:	0004879b          	sext.w	a5,s1
    800037f0:	fce7e1e3          	bltu	a5,a4,800037b2 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    800037f4:	00005517          	auipc	a0,0x5
    800037f8:	de450513          	addi	a0,a0,-540 # 800085d8 <syscalls+0x180>
    800037fc:	ffffd097          	auipc	ra,0xffffd
    80003800:	d8c080e7          	jalr	-628(ra) # 80000588 <printf>
  return 0;
    80003804:	4501                	li	a0,0
}
    80003806:	60a6                	ld	ra,72(sp)
    80003808:	6406                	ld	s0,64(sp)
    8000380a:	74e2                	ld	s1,56(sp)
    8000380c:	7942                	ld	s2,48(sp)
    8000380e:	79a2                	ld	s3,40(sp)
    80003810:	7a02                	ld	s4,32(sp)
    80003812:	6ae2                	ld	s5,24(sp)
    80003814:	6b42                	ld	s6,16(sp)
    80003816:	6ba2                	ld	s7,8(sp)
    80003818:	6161                	addi	sp,sp,80
    8000381a:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000381c:	04000613          	li	a2,64
    80003820:	4581                	li	a1,0
    80003822:	854e                	mv	a0,s3
    80003824:	ffffd097          	auipc	ra,0xffffd
    80003828:	4ae080e7          	jalr	1198(ra) # 80000cd2 <memset>
      dip->type = type;
    8000382c:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003830:	854a                	mv	a0,s2
    80003832:	00001097          	auipc	ra,0x1
    80003836:	c84080e7          	jalr	-892(ra) # 800044b6 <log_write>
      brelse(bp);
    8000383a:	854a                	mv	a0,s2
    8000383c:	00000097          	auipc	ra,0x0
    80003840:	9f6080e7          	jalr	-1546(ra) # 80003232 <brelse>
      return iget(dev, inum);
    80003844:	85da                	mv	a1,s6
    80003846:	8556                	mv	a0,s5
    80003848:	00000097          	auipc	ra,0x0
    8000384c:	d9c080e7          	jalr	-612(ra) # 800035e4 <iget>
    80003850:	bf5d                	j	80003806 <ialloc+0x86>

0000000080003852 <iupdate>:
{
    80003852:	1101                	addi	sp,sp,-32
    80003854:	ec06                	sd	ra,24(sp)
    80003856:	e822                	sd	s0,16(sp)
    80003858:	e426                	sd	s1,8(sp)
    8000385a:	e04a                	sd	s2,0(sp)
    8000385c:	1000                	addi	s0,sp,32
    8000385e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003860:	415c                	lw	a5,4(a0)
    80003862:	0047d79b          	srliw	a5,a5,0x4
    80003866:	0001d597          	auipc	a1,0x1d
    8000386a:	82a5a583          	lw	a1,-2006(a1) # 80020090 <sb+0x18>
    8000386e:	9dbd                	addw	a1,a1,a5
    80003870:	4108                	lw	a0,0(a0)
    80003872:	00000097          	auipc	ra,0x0
    80003876:	890080e7          	jalr	-1904(ra) # 80003102 <bread>
    8000387a:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000387c:	05850793          	addi	a5,a0,88
    80003880:	40c8                	lw	a0,4(s1)
    80003882:	893d                	andi	a0,a0,15
    80003884:	051a                	slli	a0,a0,0x6
    80003886:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003888:	04449703          	lh	a4,68(s1)
    8000388c:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003890:	04649703          	lh	a4,70(s1)
    80003894:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003898:	04849703          	lh	a4,72(s1)
    8000389c:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800038a0:	04a49703          	lh	a4,74(s1)
    800038a4:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800038a8:	44f8                	lw	a4,76(s1)
    800038aa:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800038ac:	03400613          	li	a2,52
    800038b0:	05048593          	addi	a1,s1,80
    800038b4:	0531                	addi	a0,a0,12
    800038b6:	ffffd097          	auipc	ra,0xffffd
    800038ba:	478080e7          	jalr	1144(ra) # 80000d2e <memmove>
  log_write(bp);
    800038be:	854a                	mv	a0,s2
    800038c0:	00001097          	auipc	ra,0x1
    800038c4:	bf6080e7          	jalr	-1034(ra) # 800044b6 <log_write>
  brelse(bp);
    800038c8:	854a                	mv	a0,s2
    800038ca:	00000097          	auipc	ra,0x0
    800038ce:	968080e7          	jalr	-1688(ra) # 80003232 <brelse>
}
    800038d2:	60e2                	ld	ra,24(sp)
    800038d4:	6442                	ld	s0,16(sp)
    800038d6:	64a2                	ld	s1,8(sp)
    800038d8:	6902                	ld	s2,0(sp)
    800038da:	6105                	addi	sp,sp,32
    800038dc:	8082                	ret

00000000800038de <idup>:
{
    800038de:	1101                	addi	sp,sp,-32
    800038e0:	ec06                	sd	ra,24(sp)
    800038e2:	e822                	sd	s0,16(sp)
    800038e4:	e426                	sd	s1,8(sp)
    800038e6:	1000                	addi	s0,sp,32
    800038e8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800038ea:	0001c517          	auipc	a0,0x1c
    800038ee:	7ae50513          	addi	a0,a0,1966 # 80020098 <itable>
    800038f2:	ffffd097          	auipc	ra,0xffffd
    800038f6:	2e4080e7          	jalr	740(ra) # 80000bd6 <acquire>
  ip->ref++;
    800038fa:	449c                	lw	a5,8(s1)
    800038fc:	2785                	addiw	a5,a5,1
    800038fe:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003900:	0001c517          	auipc	a0,0x1c
    80003904:	79850513          	addi	a0,a0,1944 # 80020098 <itable>
    80003908:	ffffd097          	auipc	ra,0xffffd
    8000390c:	382080e7          	jalr	898(ra) # 80000c8a <release>
}
    80003910:	8526                	mv	a0,s1
    80003912:	60e2                	ld	ra,24(sp)
    80003914:	6442                	ld	s0,16(sp)
    80003916:	64a2                	ld	s1,8(sp)
    80003918:	6105                	addi	sp,sp,32
    8000391a:	8082                	ret

000000008000391c <ilock>:
{
    8000391c:	1101                	addi	sp,sp,-32
    8000391e:	ec06                	sd	ra,24(sp)
    80003920:	e822                	sd	s0,16(sp)
    80003922:	e426                	sd	s1,8(sp)
    80003924:	e04a                	sd	s2,0(sp)
    80003926:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003928:	c115                	beqz	a0,8000394c <ilock+0x30>
    8000392a:	84aa                	mv	s1,a0
    8000392c:	451c                	lw	a5,8(a0)
    8000392e:	00f05f63          	blez	a5,8000394c <ilock+0x30>
  acquiresleep(&ip->lock);
    80003932:	0541                	addi	a0,a0,16
    80003934:	00001097          	auipc	ra,0x1
    80003938:	ca2080e7          	jalr	-862(ra) # 800045d6 <acquiresleep>
  if(ip->valid == 0){
    8000393c:	40bc                	lw	a5,64(s1)
    8000393e:	cf99                	beqz	a5,8000395c <ilock+0x40>
}
    80003940:	60e2                	ld	ra,24(sp)
    80003942:	6442                	ld	s0,16(sp)
    80003944:	64a2                	ld	s1,8(sp)
    80003946:	6902                	ld	s2,0(sp)
    80003948:	6105                	addi	sp,sp,32
    8000394a:	8082                	ret
    panic("ilock");
    8000394c:	00005517          	auipc	a0,0x5
    80003950:	ca450513          	addi	a0,a0,-860 # 800085f0 <syscalls+0x198>
    80003954:	ffffd097          	auipc	ra,0xffffd
    80003958:	bea080e7          	jalr	-1046(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000395c:	40dc                	lw	a5,4(s1)
    8000395e:	0047d79b          	srliw	a5,a5,0x4
    80003962:	0001c597          	auipc	a1,0x1c
    80003966:	72e5a583          	lw	a1,1838(a1) # 80020090 <sb+0x18>
    8000396a:	9dbd                	addw	a1,a1,a5
    8000396c:	4088                	lw	a0,0(s1)
    8000396e:	fffff097          	auipc	ra,0xfffff
    80003972:	794080e7          	jalr	1940(ra) # 80003102 <bread>
    80003976:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003978:	05850593          	addi	a1,a0,88
    8000397c:	40dc                	lw	a5,4(s1)
    8000397e:	8bbd                	andi	a5,a5,15
    80003980:	079a                	slli	a5,a5,0x6
    80003982:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003984:	00059783          	lh	a5,0(a1)
    80003988:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000398c:	00259783          	lh	a5,2(a1)
    80003990:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003994:	00459783          	lh	a5,4(a1)
    80003998:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000399c:	00659783          	lh	a5,6(a1)
    800039a0:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800039a4:	459c                	lw	a5,8(a1)
    800039a6:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800039a8:	03400613          	li	a2,52
    800039ac:	05b1                	addi	a1,a1,12
    800039ae:	05048513          	addi	a0,s1,80
    800039b2:	ffffd097          	auipc	ra,0xffffd
    800039b6:	37c080e7          	jalr	892(ra) # 80000d2e <memmove>
    brelse(bp);
    800039ba:	854a                	mv	a0,s2
    800039bc:	00000097          	auipc	ra,0x0
    800039c0:	876080e7          	jalr	-1930(ra) # 80003232 <brelse>
    ip->valid = 1;
    800039c4:	4785                	li	a5,1
    800039c6:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800039c8:	04449783          	lh	a5,68(s1)
    800039cc:	fbb5                	bnez	a5,80003940 <ilock+0x24>
      panic("ilock: no type");
    800039ce:	00005517          	auipc	a0,0x5
    800039d2:	c2a50513          	addi	a0,a0,-982 # 800085f8 <syscalls+0x1a0>
    800039d6:	ffffd097          	auipc	ra,0xffffd
    800039da:	b68080e7          	jalr	-1176(ra) # 8000053e <panic>

00000000800039de <iunlock>:
{
    800039de:	1101                	addi	sp,sp,-32
    800039e0:	ec06                	sd	ra,24(sp)
    800039e2:	e822                	sd	s0,16(sp)
    800039e4:	e426                	sd	s1,8(sp)
    800039e6:	e04a                	sd	s2,0(sp)
    800039e8:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800039ea:	c905                	beqz	a0,80003a1a <iunlock+0x3c>
    800039ec:	84aa                	mv	s1,a0
    800039ee:	01050913          	addi	s2,a0,16
    800039f2:	854a                	mv	a0,s2
    800039f4:	00001097          	auipc	ra,0x1
    800039f8:	c7c080e7          	jalr	-900(ra) # 80004670 <holdingsleep>
    800039fc:	cd19                	beqz	a0,80003a1a <iunlock+0x3c>
    800039fe:	449c                	lw	a5,8(s1)
    80003a00:	00f05d63          	blez	a5,80003a1a <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003a04:	854a                	mv	a0,s2
    80003a06:	00001097          	auipc	ra,0x1
    80003a0a:	c26080e7          	jalr	-986(ra) # 8000462c <releasesleep>
}
    80003a0e:	60e2                	ld	ra,24(sp)
    80003a10:	6442                	ld	s0,16(sp)
    80003a12:	64a2                	ld	s1,8(sp)
    80003a14:	6902                	ld	s2,0(sp)
    80003a16:	6105                	addi	sp,sp,32
    80003a18:	8082                	ret
    panic("iunlock");
    80003a1a:	00005517          	auipc	a0,0x5
    80003a1e:	bee50513          	addi	a0,a0,-1042 # 80008608 <syscalls+0x1b0>
    80003a22:	ffffd097          	auipc	ra,0xffffd
    80003a26:	b1c080e7          	jalr	-1252(ra) # 8000053e <panic>

0000000080003a2a <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003a2a:	7179                	addi	sp,sp,-48
    80003a2c:	f406                	sd	ra,40(sp)
    80003a2e:	f022                	sd	s0,32(sp)
    80003a30:	ec26                	sd	s1,24(sp)
    80003a32:	e84a                	sd	s2,16(sp)
    80003a34:	e44e                	sd	s3,8(sp)
    80003a36:	e052                	sd	s4,0(sp)
    80003a38:	1800                	addi	s0,sp,48
    80003a3a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003a3c:	05050493          	addi	s1,a0,80
    80003a40:	08050913          	addi	s2,a0,128
    80003a44:	a021                	j	80003a4c <itrunc+0x22>
    80003a46:	0491                	addi	s1,s1,4
    80003a48:	01248d63          	beq	s1,s2,80003a62 <itrunc+0x38>
    if(ip->addrs[i]){
    80003a4c:	408c                	lw	a1,0(s1)
    80003a4e:	dde5                	beqz	a1,80003a46 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003a50:	0009a503          	lw	a0,0(s3)
    80003a54:	00000097          	auipc	ra,0x0
    80003a58:	8f4080e7          	jalr	-1804(ra) # 80003348 <bfree>
      ip->addrs[i] = 0;
    80003a5c:	0004a023          	sw	zero,0(s1)
    80003a60:	b7dd                	j	80003a46 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003a62:	0809a583          	lw	a1,128(s3)
    80003a66:	e185                	bnez	a1,80003a86 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003a68:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003a6c:	854e                	mv	a0,s3
    80003a6e:	00000097          	auipc	ra,0x0
    80003a72:	de4080e7          	jalr	-540(ra) # 80003852 <iupdate>
}
    80003a76:	70a2                	ld	ra,40(sp)
    80003a78:	7402                	ld	s0,32(sp)
    80003a7a:	64e2                	ld	s1,24(sp)
    80003a7c:	6942                	ld	s2,16(sp)
    80003a7e:	69a2                	ld	s3,8(sp)
    80003a80:	6a02                	ld	s4,0(sp)
    80003a82:	6145                	addi	sp,sp,48
    80003a84:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003a86:	0009a503          	lw	a0,0(s3)
    80003a8a:	fffff097          	auipc	ra,0xfffff
    80003a8e:	678080e7          	jalr	1656(ra) # 80003102 <bread>
    80003a92:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003a94:	05850493          	addi	s1,a0,88
    80003a98:	45850913          	addi	s2,a0,1112
    80003a9c:	a021                	j	80003aa4 <itrunc+0x7a>
    80003a9e:	0491                	addi	s1,s1,4
    80003aa0:	01248b63          	beq	s1,s2,80003ab6 <itrunc+0x8c>
      if(a[j])
    80003aa4:	408c                	lw	a1,0(s1)
    80003aa6:	dde5                	beqz	a1,80003a9e <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003aa8:	0009a503          	lw	a0,0(s3)
    80003aac:	00000097          	auipc	ra,0x0
    80003ab0:	89c080e7          	jalr	-1892(ra) # 80003348 <bfree>
    80003ab4:	b7ed                	j	80003a9e <itrunc+0x74>
    brelse(bp);
    80003ab6:	8552                	mv	a0,s4
    80003ab8:	fffff097          	auipc	ra,0xfffff
    80003abc:	77a080e7          	jalr	1914(ra) # 80003232 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003ac0:	0809a583          	lw	a1,128(s3)
    80003ac4:	0009a503          	lw	a0,0(s3)
    80003ac8:	00000097          	auipc	ra,0x0
    80003acc:	880080e7          	jalr	-1920(ra) # 80003348 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003ad0:	0809a023          	sw	zero,128(s3)
    80003ad4:	bf51                	j	80003a68 <itrunc+0x3e>

0000000080003ad6 <iput>:
{
    80003ad6:	1101                	addi	sp,sp,-32
    80003ad8:	ec06                	sd	ra,24(sp)
    80003ada:	e822                	sd	s0,16(sp)
    80003adc:	e426                	sd	s1,8(sp)
    80003ade:	e04a                	sd	s2,0(sp)
    80003ae0:	1000                	addi	s0,sp,32
    80003ae2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003ae4:	0001c517          	auipc	a0,0x1c
    80003ae8:	5b450513          	addi	a0,a0,1460 # 80020098 <itable>
    80003aec:	ffffd097          	auipc	ra,0xffffd
    80003af0:	0ea080e7          	jalr	234(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003af4:	4498                	lw	a4,8(s1)
    80003af6:	4785                	li	a5,1
    80003af8:	02f70363          	beq	a4,a5,80003b1e <iput+0x48>
  ip->ref--;
    80003afc:	449c                	lw	a5,8(s1)
    80003afe:	37fd                	addiw	a5,a5,-1
    80003b00:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003b02:	0001c517          	auipc	a0,0x1c
    80003b06:	59650513          	addi	a0,a0,1430 # 80020098 <itable>
    80003b0a:	ffffd097          	auipc	ra,0xffffd
    80003b0e:	180080e7          	jalr	384(ra) # 80000c8a <release>
}
    80003b12:	60e2                	ld	ra,24(sp)
    80003b14:	6442                	ld	s0,16(sp)
    80003b16:	64a2                	ld	s1,8(sp)
    80003b18:	6902                	ld	s2,0(sp)
    80003b1a:	6105                	addi	sp,sp,32
    80003b1c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b1e:	40bc                	lw	a5,64(s1)
    80003b20:	dff1                	beqz	a5,80003afc <iput+0x26>
    80003b22:	04a49783          	lh	a5,74(s1)
    80003b26:	fbf9                	bnez	a5,80003afc <iput+0x26>
    acquiresleep(&ip->lock);
    80003b28:	01048913          	addi	s2,s1,16
    80003b2c:	854a                	mv	a0,s2
    80003b2e:	00001097          	auipc	ra,0x1
    80003b32:	aa8080e7          	jalr	-1368(ra) # 800045d6 <acquiresleep>
    release(&itable.lock);
    80003b36:	0001c517          	auipc	a0,0x1c
    80003b3a:	56250513          	addi	a0,a0,1378 # 80020098 <itable>
    80003b3e:	ffffd097          	auipc	ra,0xffffd
    80003b42:	14c080e7          	jalr	332(ra) # 80000c8a <release>
    itrunc(ip);
    80003b46:	8526                	mv	a0,s1
    80003b48:	00000097          	auipc	ra,0x0
    80003b4c:	ee2080e7          	jalr	-286(ra) # 80003a2a <itrunc>
    ip->type = 0;
    80003b50:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003b54:	8526                	mv	a0,s1
    80003b56:	00000097          	auipc	ra,0x0
    80003b5a:	cfc080e7          	jalr	-772(ra) # 80003852 <iupdate>
    ip->valid = 0;
    80003b5e:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003b62:	854a                	mv	a0,s2
    80003b64:	00001097          	auipc	ra,0x1
    80003b68:	ac8080e7          	jalr	-1336(ra) # 8000462c <releasesleep>
    acquire(&itable.lock);
    80003b6c:	0001c517          	auipc	a0,0x1c
    80003b70:	52c50513          	addi	a0,a0,1324 # 80020098 <itable>
    80003b74:	ffffd097          	auipc	ra,0xffffd
    80003b78:	062080e7          	jalr	98(ra) # 80000bd6 <acquire>
    80003b7c:	b741                	j	80003afc <iput+0x26>

0000000080003b7e <iunlockput>:
{
    80003b7e:	1101                	addi	sp,sp,-32
    80003b80:	ec06                	sd	ra,24(sp)
    80003b82:	e822                	sd	s0,16(sp)
    80003b84:	e426                	sd	s1,8(sp)
    80003b86:	1000                	addi	s0,sp,32
    80003b88:	84aa                	mv	s1,a0
  iunlock(ip);
    80003b8a:	00000097          	auipc	ra,0x0
    80003b8e:	e54080e7          	jalr	-428(ra) # 800039de <iunlock>
  iput(ip);
    80003b92:	8526                	mv	a0,s1
    80003b94:	00000097          	auipc	ra,0x0
    80003b98:	f42080e7          	jalr	-190(ra) # 80003ad6 <iput>
}
    80003b9c:	60e2                	ld	ra,24(sp)
    80003b9e:	6442                	ld	s0,16(sp)
    80003ba0:	64a2                	ld	s1,8(sp)
    80003ba2:	6105                	addi	sp,sp,32
    80003ba4:	8082                	ret

0000000080003ba6 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003ba6:	1141                	addi	sp,sp,-16
    80003ba8:	e422                	sd	s0,8(sp)
    80003baa:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003bac:	411c                	lw	a5,0(a0)
    80003bae:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003bb0:	415c                	lw	a5,4(a0)
    80003bb2:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003bb4:	04451783          	lh	a5,68(a0)
    80003bb8:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003bbc:	04a51783          	lh	a5,74(a0)
    80003bc0:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003bc4:	04c56783          	lwu	a5,76(a0)
    80003bc8:	e99c                	sd	a5,16(a1)
}
    80003bca:	6422                	ld	s0,8(sp)
    80003bcc:	0141                	addi	sp,sp,16
    80003bce:	8082                	ret

0000000080003bd0 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003bd0:	457c                	lw	a5,76(a0)
    80003bd2:	0ed7e963          	bltu	a5,a3,80003cc4 <readi+0xf4>
{
    80003bd6:	7159                	addi	sp,sp,-112
    80003bd8:	f486                	sd	ra,104(sp)
    80003bda:	f0a2                	sd	s0,96(sp)
    80003bdc:	eca6                	sd	s1,88(sp)
    80003bde:	e8ca                	sd	s2,80(sp)
    80003be0:	e4ce                	sd	s3,72(sp)
    80003be2:	e0d2                	sd	s4,64(sp)
    80003be4:	fc56                	sd	s5,56(sp)
    80003be6:	f85a                	sd	s6,48(sp)
    80003be8:	f45e                	sd	s7,40(sp)
    80003bea:	f062                	sd	s8,32(sp)
    80003bec:	ec66                	sd	s9,24(sp)
    80003bee:	e86a                	sd	s10,16(sp)
    80003bf0:	e46e                	sd	s11,8(sp)
    80003bf2:	1880                	addi	s0,sp,112
    80003bf4:	8b2a                	mv	s6,a0
    80003bf6:	8bae                	mv	s7,a1
    80003bf8:	8a32                	mv	s4,a2
    80003bfa:	84b6                	mv	s1,a3
    80003bfc:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003bfe:	9f35                	addw	a4,a4,a3
    return 0;
    80003c00:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003c02:	0ad76063          	bltu	a4,a3,80003ca2 <readi+0xd2>
  if(off + n > ip->size)
    80003c06:	00e7f463          	bgeu	a5,a4,80003c0e <readi+0x3e>
    n = ip->size - off;
    80003c0a:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c0e:	0a0a8963          	beqz	s5,80003cc0 <readi+0xf0>
    80003c12:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c14:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003c18:	5c7d                	li	s8,-1
    80003c1a:	a82d                	j	80003c54 <readi+0x84>
    80003c1c:	020d1d93          	slli	s11,s10,0x20
    80003c20:	020ddd93          	srli	s11,s11,0x20
    80003c24:	05890793          	addi	a5,s2,88
    80003c28:	86ee                	mv	a3,s11
    80003c2a:	963e                	add	a2,a2,a5
    80003c2c:	85d2                	mv	a1,s4
    80003c2e:	855e                	mv	a0,s7
    80003c30:	fffff097          	auipc	ra,0xfffff
    80003c34:	a28080e7          	jalr	-1496(ra) # 80002658 <either_copyout>
    80003c38:	05850d63          	beq	a0,s8,80003c92 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003c3c:	854a                	mv	a0,s2
    80003c3e:	fffff097          	auipc	ra,0xfffff
    80003c42:	5f4080e7          	jalr	1524(ra) # 80003232 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c46:	013d09bb          	addw	s3,s10,s3
    80003c4a:	009d04bb          	addw	s1,s10,s1
    80003c4e:	9a6e                	add	s4,s4,s11
    80003c50:	0559f763          	bgeu	s3,s5,80003c9e <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003c54:	00a4d59b          	srliw	a1,s1,0xa
    80003c58:	855a                	mv	a0,s6
    80003c5a:	00000097          	auipc	ra,0x0
    80003c5e:	8a2080e7          	jalr	-1886(ra) # 800034fc <bmap>
    80003c62:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003c66:	cd85                	beqz	a1,80003c9e <readi+0xce>
    bp = bread(ip->dev, addr);
    80003c68:	000b2503          	lw	a0,0(s6)
    80003c6c:	fffff097          	auipc	ra,0xfffff
    80003c70:	496080e7          	jalr	1174(ra) # 80003102 <bread>
    80003c74:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c76:	3ff4f613          	andi	a2,s1,1023
    80003c7a:	40cc87bb          	subw	a5,s9,a2
    80003c7e:	413a873b          	subw	a4,s5,s3
    80003c82:	8d3e                	mv	s10,a5
    80003c84:	2781                	sext.w	a5,a5
    80003c86:	0007069b          	sext.w	a3,a4
    80003c8a:	f8f6f9e3          	bgeu	a3,a5,80003c1c <readi+0x4c>
    80003c8e:	8d3a                	mv	s10,a4
    80003c90:	b771                	j	80003c1c <readi+0x4c>
      brelse(bp);
    80003c92:	854a                	mv	a0,s2
    80003c94:	fffff097          	auipc	ra,0xfffff
    80003c98:	59e080e7          	jalr	1438(ra) # 80003232 <brelse>
      tot = -1;
    80003c9c:	59fd                	li	s3,-1
  }
  return tot;
    80003c9e:	0009851b          	sext.w	a0,s3
}
    80003ca2:	70a6                	ld	ra,104(sp)
    80003ca4:	7406                	ld	s0,96(sp)
    80003ca6:	64e6                	ld	s1,88(sp)
    80003ca8:	6946                	ld	s2,80(sp)
    80003caa:	69a6                	ld	s3,72(sp)
    80003cac:	6a06                	ld	s4,64(sp)
    80003cae:	7ae2                	ld	s5,56(sp)
    80003cb0:	7b42                	ld	s6,48(sp)
    80003cb2:	7ba2                	ld	s7,40(sp)
    80003cb4:	7c02                	ld	s8,32(sp)
    80003cb6:	6ce2                	ld	s9,24(sp)
    80003cb8:	6d42                	ld	s10,16(sp)
    80003cba:	6da2                	ld	s11,8(sp)
    80003cbc:	6165                	addi	sp,sp,112
    80003cbe:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cc0:	89d6                	mv	s3,s5
    80003cc2:	bff1                	j	80003c9e <readi+0xce>
    return 0;
    80003cc4:	4501                	li	a0,0
}
    80003cc6:	8082                	ret

0000000080003cc8 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003cc8:	457c                	lw	a5,76(a0)
    80003cca:	10d7e863          	bltu	a5,a3,80003dda <writei+0x112>
{
    80003cce:	7159                	addi	sp,sp,-112
    80003cd0:	f486                	sd	ra,104(sp)
    80003cd2:	f0a2                	sd	s0,96(sp)
    80003cd4:	eca6                	sd	s1,88(sp)
    80003cd6:	e8ca                	sd	s2,80(sp)
    80003cd8:	e4ce                	sd	s3,72(sp)
    80003cda:	e0d2                	sd	s4,64(sp)
    80003cdc:	fc56                	sd	s5,56(sp)
    80003cde:	f85a                	sd	s6,48(sp)
    80003ce0:	f45e                	sd	s7,40(sp)
    80003ce2:	f062                	sd	s8,32(sp)
    80003ce4:	ec66                	sd	s9,24(sp)
    80003ce6:	e86a                	sd	s10,16(sp)
    80003ce8:	e46e                	sd	s11,8(sp)
    80003cea:	1880                	addi	s0,sp,112
    80003cec:	8aaa                	mv	s5,a0
    80003cee:	8bae                	mv	s7,a1
    80003cf0:	8a32                	mv	s4,a2
    80003cf2:	8936                	mv	s2,a3
    80003cf4:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003cf6:	00e687bb          	addw	a5,a3,a4
    80003cfa:	0ed7e263          	bltu	a5,a3,80003dde <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003cfe:	00043737          	lui	a4,0x43
    80003d02:	0ef76063          	bltu	a4,a5,80003de2 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d06:	0c0b0863          	beqz	s6,80003dd6 <writei+0x10e>
    80003d0a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d0c:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003d10:	5c7d                	li	s8,-1
    80003d12:	a091                	j	80003d56 <writei+0x8e>
    80003d14:	020d1d93          	slli	s11,s10,0x20
    80003d18:	020ddd93          	srli	s11,s11,0x20
    80003d1c:	05848793          	addi	a5,s1,88
    80003d20:	86ee                	mv	a3,s11
    80003d22:	8652                	mv	a2,s4
    80003d24:	85de                	mv	a1,s7
    80003d26:	953e                	add	a0,a0,a5
    80003d28:	fffff097          	auipc	ra,0xfffff
    80003d2c:	986080e7          	jalr	-1658(ra) # 800026ae <either_copyin>
    80003d30:	07850263          	beq	a0,s8,80003d94 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003d34:	8526                	mv	a0,s1
    80003d36:	00000097          	auipc	ra,0x0
    80003d3a:	780080e7          	jalr	1920(ra) # 800044b6 <log_write>
    brelse(bp);
    80003d3e:	8526                	mv	a0,s1
    80003d40:	fffff097          	auipc	ra,0xfffff
    80003d44:	4f2080e7          	jalr	1266(ra) # 80003232 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d48:	013d09bb          	addw	s3,s10,s3
    80003d4c:	012d093b          	addw	s2,s10,s2
    80003d50:	9a6e                	add	s4,s4,s11
    80003d52:	0569f663          	bgeu	s3,s6,80003d9e <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003d56:	00a9559b          	srliw	a1,s2,0xa
    80003d5a:	8556                	mv	a0,s5
    80003d5c:	fffff097          	auipc	ra,0xfffff
    80003d60:	7a0080e7          	jalr	1952(ra) # 800034fc <bmap>
    80003d64:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003d68:	c99d                	beqz	a1,80003d9e <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003d6a:	000aa503          	lw	a0,0(s5)
    80003d6e:	fffff097          	auipc	ra,0xfffff
    80003d72:	394080e7          	jalr	916(ra) # 80003102 <bread>
    80003d76:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d78:	3ff97513          	andi	a0,s2,1023
    80003d7c:	40ac87bb          	subw	a5,s9,a0
    80003d80:	413b073b          	subw	a4,s6,s3
    80003d84:	8d3e                	mv	s10,a5
    80003d86:	2781                	sext.w	a5,a5
    80003d88:	0007069b          	sext.w	a3,a4
    80003d8c:	f8f6f4e3          	bgeu	a3,a5,80003d14 <writei+0x4c>
    80003d90:	8d3a                	mv	s10,a4
    80003d92:	b749                	j	80003d14 <writei+0x4c>
      brelse(bp);
    80003d94:	8526                	mv	a0,s1
    80003d96:	fffff097          	auipc	ra,0xfffff
    80003d9a:	49c080e7          	jalr	1180(ra) # 80003232 <brelse>
  }

  if(off > ip->size)
    80003d9e:	04caa783          	lw	a5,76(s5)
    80003da2:	0127f463          	bgeu	a5,s2,80003daa <writei+0xe2>
    ip->size = off;
    80003da6:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003daa:	8556                	mv	a0,s5
    80003dac:	00000097          	auipc	ra,0x0
    80003db0:	aa6080e7          	jalr	-1370(ra) # 80003852 <iupdate>

  return tot;
    80003db4:	0009851b          	sext.w	a0,s3
}
    80003db8:	70a6                	ld	ra,104(sp)
    80003dba:	7406                	ld	s0,96(sp)
    80003dbc:	64e6                	ld	s1,88(sp)
    80003dbe:	6946                	ld	s2,80(sp)
    80003dc0:	69a6                	ld	s3,72(sp)
    80003dc2:	6a06                	ld	s4,64(sp)
    80003dc4:	7ae2                	ld	s5,56(sp)
    80003dc6:	7b42                	ld	s6,48(sp)
    80003dc8:	7ba2                	ld	s7,40(sp)
    80003dca:	7c02                	ld	s8,32(sp)
    80003dcc:	6ce2                	ld	s9,24(sp)
    80003dce:	6d42                	ld	s10,16(sp)
    80003dd0:	6da2                	ld	s11,8(sp)
    80003dd2:	6165                	addi	sp,sp,112
    80003dd4:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003dd6:	89da                	mv	s3,s6
    80003dd8:	bfc9                	j	80003daa <writei+0xe2>
    return -1;
    80003dda:	557d                	li	a0,-1
}
    80003ddc:	8082                	ret
    return -1;
    80003dde:	557d                	li	a0,-1
    80003de0:	bfe1                	j	80003db8 <writei+0xf0>
    return -1;
    80003de2:	557d                	li	a0,-1
    80003de4:	bfd1                	j	80003db8 <writei+0xf0>

0000000080003de6 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003de6:	1141                	addi	sp,sp,-16
    80003de8:	e406                	sd	ra,8(sp)
    80003dea:	e022                	sd	s0,0(sp)
    80003dec:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003dee:	4639                	li	a2,14
    80003df0:	ffffd097          	auipc	ra,0xffffd
    80003df4:	fb2080e7          	jalr	-78(ra) # 80000da2 <strncmp>
}
    80003df8:	60a2                	ld	ra,8(sp)
    80003dfa:	6402                	ld	s0,0(sp)
    80003dfc:	0141                	addi	sp,sp,16
    80003dfe:	8082                	ret

0000000080003e00 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003e00:	7139                	addi	sp,sp,-64
    80003e02:	fc06                	sd	ra,56(sp)
    80003e04:	f822                	sd	s0,48(sp)
    80003e06:	f426                	sd	s1,40(sp)
    80003e08:	f04a                	sd	s2,32(sp)
    80003e0a:	ec4e                	sd	s3,24(sp)
    80003e0c:	e852                	sd	s4,16(sp)
    80003e0e:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003e10:	04451703          	lh	a4,68(a0)
    80003e14:	4785                	li	a5,1
    80003e16:	00f71a63          	bne	a4,a5,80003e2a <dirlookup+0x2a>
    80003e1a:	892a                	mv	s2,a0
    80003e1c:	89ae                	mv	s3,a1
    80003e1e:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e20:	457c                	lw	a5,76(a0)
    80003e22:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003e24:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e26:	e79d                	bnez	a5,80003e54 <dirlookup+0x54>
    80003e28:	a8a5                	j	80003ea0 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003e2a:	00004517          	auipc	a0,0x4
    80003e2e:	7e650513          	addi	a0,a0,2022 # 80008610 <syscalls+0x1b8>
    80003e32:	ffffc097          	auipc	ra,0xffffc
    80003e36:	70c080e7          	jalr	1804(ra) # 8000053e <panic>
      panic("dirlookup read");
    80003e3a:	00004517          	auipc	a0,0x4
    80003e3e:	7ee50513          	addi	a0,a0,2030 # 80008628 <syscalls+0x1d0>
    80003e42:	ffffc097          	auipc	ra,0xffffc
    80003e46:	6fc080e7          	jalr	1788(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e4a:	24c1                	addiw	s1,s1,16
    80003e4c:	04c92783          	lw	a5,76(s2)
    80003e50:	04f4f763          	bgeu	s1,a5,80003e9e <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e54:	4741                	li	a4,16
    80003e56:	86a6                	mv	a3,s1
    80003e58:	fc040613          	addi	a2,s0,-64
    80003e5c:	4581                	li	a1,0
    80003e5e:	854a                	mv	a0,s2
    80003e60:	00000097          	auipc	ra,0x0
    80003e64:	d70080e7          	jalr	-656(ra) # 80003bd0 <readi>
    80003e68:	47c1                	li	a5,16
    80003e6a:	fcf518e3          	bne	a0,a5,80003e3a <dirlookup+0x3a>
    if(de.inum == 0)
    80003e6e:	fc045783          	lhu	a5,-64(s0)
    80003e72:	dfe1                	beqz	a5,80003e4a <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003e74:	fc240593          	addi	a1,s0,-62
    80003e78:	854e                	mv	a0,s3
    80003e7a:	00000097          	auipc	ra,0x0
    80003e7e:	f6c080e7          	jalr	-148(ra) # 80003de6 <namecmp>
    80003e82:	f561                	bnez	a0,80003e4a <dirlookup+0x4a>
      if(poff)
    80003e84:	000a0463          	beqz	s4,80003e8c <dirlookup+0x8c>
        *poff = off;
    80003e88:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003e8c:	fc045583          	lhu	a1,-64(s0)
    80003e90:	00092503          	lw	a0,0(s2)
    80003e94:	fffff097          	auipc	ra,0xfffff
    80003e98:	750080e7          	jalr	1872(ra) # 800035e4 <iget>
    80003e9c:	a011                	j	80003ea0 <dirlookup+0xa0>
  return 0;
    80003e9e:	4501                	li	a0,0
}
    80003ea0:	70e2                	ld	ra,56(sp)
    80003ea2:	7442                	ld	s0,48(sp)
    80003ea4:	74a2                	ld	s1,40(sp)
    80003ea6:	7902                	ld	s2,32(sp)
    80003ea8:	69e2                	ld	s3,24(sp)
    80003eaa:	6a42                	ld	s4,16(sp)
    80003eac:	6121                	addi	sp,sp,64
    80003eae:	8082                	ret

0000000080003eb0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003eb0:	711d                	addi	sp,sp,-96
    80003eb2:	ec86                	sd	ra,88(sp)
    80003eb4:	e8a2                	sd	s0,80(sp)
    80003eb6:	e4a6                	sd	s1,72(sp)
    80003eb8:	e0ca                	sd	s2,64(sp)
    80003eba:	fc4e                	sd	s3,56(sp)
    80003ebc:	f852                	sd	s4,48(sp)
    80003ebe:	f456                	sd	s5,40(sp)
    80003ec0:	f05a                	sd	s6,32(sp)
    80003ec2:	ec5e                	sd	s7,24(sp)
    80003ec4:	e862                	sd	s8,16(sp)
    80003ec6:	e466                	sd	s9,8(sp)
    80003ec8:	1080                	addi	s0,sp,96
    80003eca:	84aa                	mv	s1,a0
    80003ecc:	8aae                	mv	s5,a1
    80003ece:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003ed0:	00054703          	lbu	a4,0(a0)
    80003ed4:	02f00793          	li	a5,47
    80003ed8:	02f70363          	beq	a4,a5,80003efe <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003edc:	ffffe097          	auipc	ra,0xffffe
    80003ee0:	aee080e7          	jalr	-1298(ra) # 800019ca <myproc>
    80003ee4:	19053503          	ld	a0,400(a0)
    80003ee8:	00000097          	auipc	ra,0x0
    80003eec:	9f6080e7          	jalr	-1546(ra) # 800038de <idup>
    80003ef0:	89aa                	mv	s3,a0
  while(*path == '/')
    80003ef2:	02f00913          	li	s2,47
  len = path - s;
    80003ef6:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003ef8:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003efa:	4b85                	li	s7,1
    80003efc:	a865                	j	80003fb4 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003efe:	4585                	li	a1,1
    80003f00:	4505                	li	a0,1
    80003f02:	fffff097          	auipc	ra,0xfffff
    80003f06:	6e2080e7          	jalr	1762(ra) # 800035e4 <iget>
    80003f0a:	89aa                	mv	s3,a0
    80003f0c:	b7dd                	j	80003ef2 <namex+0x42>
      iunlockput(ip);
    80003f0e:	854e                	mv	a0,s3
    80003f10:	00000097          	auipc	ra,0x0
    80003f14:	c6e080e7          	jalr	-914(ra) # 80003b7e <iunlockput>
      return 0;
    80003f18:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003f1a:	854e                	mv	a0,s3
    80003f1c:	60e6                	ld	ra,88(sp)
    80003f1e:	6446                	ld	s0,80(sp)
    80003f20:	64a6                	ld	s1,72(sp)
    80003f22:	6906                	ld	s2,64(sp)
    80003f24:	79e2                	ld	s3,56(sp)
    80003f26:	7a42                	ld	s4,48(sp)
    80003f28:	7aa2                	ld	s5,40(sp)
    80003f2a:	7b02                	ld	s6,32(sp)
    80003f2c:	6be2                	ld	s7,24(sp)
    80003f2e:	6c42                	ld	s8,16(sp)
    80003f30:	6ca2                	ld	s9,8(sp)
    80003f32:	6125                	addi	sp,sp,96
    80003f34:	8082                	ret
      iunlock(ip);
    80003f36:	854e                	mv	a0,s3
    80003f38:	00000097          	auipc	ra,0x0
    80003f3c:	aa6080e7          	jalr	-1370(ra) # 800039de <iunlock>
      return ip;
    80003f40:	bfe9                	j	80003f1a <namex+0x6a>
      iunlockput(ip);
    80003f42:	854e                	mv	a0,s3
    80003f44:	00000097          	auipc	ra,0x0
    80003f48:	c3a080e7          	jalr	-966(ra) # 80003b7e <iunlockput>
      return 0;
    80003f4c:	89e6                	mv	s3,s9
    80003f4e:	b7f1                	j	80003f1a <namex+0x6a>
  len = path - s;
    80003f50:	40b48633          	sub	a2,s1,a1
    80003f54:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003f58:	099c5463          	bge	s8,s9,80003fe0 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003f5c:	4639                	li	a2,14
    80003f5e:	8552                	mv	a0,s4
    80003f60:	ffffd097          	auipc	ra,0xffffd
    80003f64:	dce080e7          	jalr	-562(ra) # 80000d2e <memmove>
  while(*path == '/')
    80003f68:	0004c783          	lbu	a5,0(s1)
    80003f6c:	01279763          	bne	a5,s2,80003f7a <namex+0xca>
    path++;
    80003f70:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f72:	0004c783          	lbu	a5,0(s1)
    80003f76:	ff278de3          	beq	a5,s2,80003f70 <namex+0xc0>
    ilock(ip);
    80003f7a:	854e                	mv	a0,s3
    80003f7c:	00000097          	auipc	ra,0x0
    80003f80:	9a0080e7          	jalr	-1632(ra) # 8000391c <ilock>
    if(ip->type != T_DIR){
    80003f84:	04499783          	lh	a5,68(s3)
    80003f88:	f97793e3          	bne	a5,s7,80003f0e <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003f8c:	000a8563          	beqz	s5,80003f96 <namex+0xe6>
    80003f90:	0004c783          	lbu	a5,0(s1)
    80003f94:	d3cd                	beqz	a5,80003f36 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003f96:	865a                	mv	a2,s6
    80003f98:	85d2                	mv	a1,s4
    80003f9a:	854e                	mv	a0,s3
    80003f9c:	00000097          	auipc	ra,0x0
    80003fa0:	e64080e7          	jalr	-412(ra) # 80003e00 <dirlookup>
    80003fa4:	8caa                	mv	s9,a0
    80003fa6:	dd51                	beqz	a0,80003f42 <namex+0x92>
    iunlockput(ip);
    80003fa8:	854e                	mv	a0,s3
    80003faa:	00000097          	auipc	ra,0x0
    80003fae:	bd4080e7          	jalr	-1068(ra) # 80003b7e <iunlockput>
    ip = next;
    80003fb2:	89e6                	mv	s3,s9
  while(*path == '/')
    80003fb4:	0004c783          	lbu	a5,0(s1)
    80003fb8:	05279763          	bne	a5,s2,80004006 <namex+0x156>
    path++;
    80003fbc:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003fbe:	0004c783          	lbu	a5,0(s1)
    80003fc2:	ff278de3          	beq	a5,s2,80003fbc <namex+0x10c>
  if(*path == 0)
    80003fc6:	c79d                	beqz	a5,80003ff4 <namex+0x144>
    path++;
    80003fc8:	85a6                	mv	a1,s1
  len = path - s;
    80003fca:	8cda                	mv	s9,s6
    80003fcc:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003fce:	01278963          	beq	a5,s2,80003fe0 <namex+0x130>
    80003fd2:	dfbd                	beqz	a5,80003f50 <namex+0xa0>
    path++;
    80003fd4:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003fd6:	0004c783          	lbu	a5,0(s1)
    80003fda:	ff279ce3          	bne	a5,s2,80003fd2 <namex+0x122>
    80003fde:	bf8d                	j	80003f50 <namex+0xa0>
    memmove(name, s, len);
    80003fe0:	2601                	sext.w	a2,a2
    80003fe2:	8552                	mv	a0,s4
    80003fe4:	ffffd097          	auipc	ra,0xffffd
    80003fe8:	d4a080e7          	jalr	-694(ra) # 80000d2e <memmove>
    name[len] = 0;
    80003fec:	9cd2                	add	s9,s9,s4
    80003fee:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003ff2:	bf9d                	j	80003f68 <namex+0xb8>
  if(nameiparent){
    80003ff4:	f20a83e3          	beqz	s5,80003f1a <namex+0x6a>
    iput(ip);
    80003ff8:	854e                	mv	a0,s3
    80003ffa:	00000097          	auipc	ra,0x0
    80003ffe:	adc080e7          	jalr	-1316(ra) # 80003ad6 <iput>
    return 0;
    80004002:	4981                	li	s3,0
    80004004:	bf19                	j	80003f1a <namex+0x6a>
  if(*path == 0)
    80004006:	d7fd                	beqz	a5,80003ff4 <namex+0x144>
  while(*path != '/' && *path != 0)
    80004008:	0004c783          	lbu	a5,0(s1)
    8000400c:	85a6                	mv	a1,s1
    8000400e:	b7d1                	j	80003fd2 <namex+0x122>

0000000080004010 <dirlink>:
{
    80004010:	7139                	addi	sp,sp,-64
    80004012:	fc06                	sd	ra,56(sp)
    80004014:	f822                	sd	s0,48(sp)
    80004016:	f426                	sd	s1,40(sp)
    80004018:	f04a                	sd	s2,32(sp)
    8000401a:	ec4e                	sd	s3,24(sp)
    8000401c:	e852                	sd	s4,16(sp)
    8000401e:	0080                	addi	s0,sp,64
    80004020:	892a                	mv	s2,a0
    80004022:	8a2e                	mv	s4,a1
    80004024:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004026:	4601                	li	a2,0
    80004028:	00000097          	auipc	ra,0x0
    8000402c:	dd8080e7          	jalr	-552(ra) # 80003e00 <dirlookup>
    80004030:	e93d                	bnez	a0,800040a6 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004032:	04c92483          	lw	s1,76(s2)
    80004036:	c49d                	beqz	s1,80004064 <dirlink+0x54>
    80004038:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000403a:	4741                	li	a4,16
    8000403c:	86a6                	mv	a3,s1
    8000403e:	fc040613          	addi	a2,s0,-64
    80004042:	4581                	li	a1,0
    80004044:	854a                	mv	a0,s2
    80004046:	00000097          	auipc	ra,0x0
    8000404a:	b8a080e7          	jalr	-1142(ra) # 80003bd0 <readi>
    8000404e:	47c1                	li	a5,16
    80004050:	06f51163          	bne	a0,a5,800040b2 <dirlink+0xa2>
    if(de.inum == 0)
    80004054:	fc045783          	lhu	a5,-64(s0)
    80004058:	c791                	beqz	a5,80004064 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000405a:	24c1                	addiw	s1,s1,16
    8000405c:	04c92783          	lw	a5,76(s2)
    80004060:	fcf4ede3          	bltu	s1,a5,8000403a <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004064:	4639                	li	a2,14
    80004066:	85d2                	mv	a1,s4
    80004068:	fc240513          	addi	a0,s0,-62
    8000406c:	ffffd097          	auipc	ra,0xffffd
    80004070:	d72080e7          	jalr	-654(ra) # 80000dde <strncpy>
  de.inum = inum;
    80004074:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004078:	4741                	li	a4,16
    8000407a:	86a6                	mv	a3,s1
    8000407c:	fc040613          	addi	a2,s0,-64
    80004080:	4581                	li	a1,0
    80004082:	854a                	mv	a0,s2
    80004084:	00000097          	auipc	ra,0x0
    80004088:	c44080e7          	jalr	-956(ra) # 80003cc8 <writei>
    8000408c:	1541                	addi	a0,a0,-16
    8000408e:	00a03533          	snez	a0,a0
    80004092:	40a00533          	neg	a0,a0
}
    80004096:	70e2                	ld	ra,56(sp)
    80004098:	7442                	ld	s0,48(sp)
    8000409a:	74a2                	ld	s1,40(sp)
    8000409c:	7902                	ld	s2,32(sp)
    8000409e:	69e2                	ld	s3,24(sp)
    800040a0:	6a42                	ld	s4,16(sp)
    800040a2:	6121                	addi	sp,sp,64
    800040a4:	8082                	ret
    iput(ip);
    800040a6:	00000097          	auipc	ra,0x0
    800040aa:	a30080e7          	jalr	-1488(ra) # 80003ad6 <iput>
    return -1;
    800040ae:	557d                	li	a0,-1
    800040b0:	b7dd                	j	80004096 <dirlink+0x86>
      panic("dirlink read");
    800040b2:	00004517          	auipc	a0,0x4
    800040b6:	58650513          	addi	a0,a0,1414 # 80008638 <syscalls+0x1e0>
    800040ba:	ffffc097          	auipc	ra,0xffffc
    800040be:	484080e7          	jalr	1156(ra) # 8000053e <panic>

00000000800040c2 <namei>:

struct inode*
namei(char *path)
{
    800040c2:	1101                	addi	sp,sp,-32
    800040c4:	ec06                	sd	ra,24(sp)
    800040c6:	e822                	sd	s0,16(sp)
    800040c8:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800040ca:	fe040613          	addi	a2,s0,-32
    800040ce:	4581                	li	a1,0
    800040d0:	00000097          	auipc	ra,0x0
    800040d4:	de0080e7          	jalr	-544(ra) # 80003eb0 <namex>
}
    800040d8:	60e2                	ld	ra,24(sp)
    800040da:	6442                	ld	s0,16(sp)
    800040dc:	6105                	addi	sp,sp,32
    800040de:	8082                	ret

00000000800040e0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800040e0:	1141                	addi	sp,sp,-16
    800040e2:	e406                	sd	ra,8(sp)
    800040e4:	e022                	sd	s0,0(sp)
    800040e6:	0800                	addi	s0,sp,16
    800040e8:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800040ea:	4585                	li	a1,1
    800040ec:	00000097          	auipc	ra,0x0
    800040f0:	dc4080e7          	jalr	-572(ra) # 80003eb0 <namex>
}
    800040f4:	60a2                	ld	ra,8(sp)
    800040f6:	6402                	ld	s0,0(sp)
    800040f8:	0141                	addi	sp,sp,16
    800040fa:	8082                	ret

00000000800040fc <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800040fc:	1101                	addi	sp,sp,-32
    800040fe:	ec06                	sd	ra,24(sp)
    80004100:	e822                	sd	s0,16(sp)
    80004102:	e426                	sd	s1,8(sp)
    80004104:	e04a                	sd	s2,0(sp)
    80004106:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004108:	0001e917          	auipc	s2,0x1e
    8000410c:	a3890913          	addi	s2,s2,-1480 # 80021b40 <log>
    80004110:	01892583          	lw	a1,24(s2)
    80004114:	02892503          	lw	a0,40(s2)
    80004118:	fffff097          	auipc	ra,0xfffff
    8000411c:	fea080e7          	jalr	-22(ra) # 80003102 <bread>
    80004120:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004122:	02c92683          	lw	a3,44(s2)
    80004126:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004128:	02d05763          	blez	a3,80004156 <write_head+0x5a>
    8000412c:	0001e797          	auipc	a5,0x1e
    80004130:	a4478793          	addi	a5,a5,-1468 # 80021b70 <log+0x30>
    80004134:	05c50713          	addi	a4,a0,92
    80004138:	36fd                	addiw	a3,a3,-1
    8000413a:	1682                	slli	a3,a3,0x20
    8000413c:	9281                	srli	a3,a3,0x20
    8000413e:	068a                	slli	a3,a3,0x2
    80004140:	0001e617          	auipc	a2,0x1e
    80004144:	a3460613          	addi	a2,a2,-1484 # 80021b74 <log+0x34>
    80004148:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    8000414a:	4390                	lw	a2,0(a5)
    8000414c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000414e:	0791                	addi	a5,a5,4
    80004150:	0711                	addi	a4,a4,4
    80004152:	fed79ce3          	bne	a5,a3,8000414a <write_head+0x4e>
  }
  bwrite(buf);
    80004156:	8526                	mv	a0,s1
    80004158:	fffff097          	auipc	ra,0xfffff
    8000415c:	09c080e7          	jalr	156(ra) # 800031f4 <bwrite>
  brelse(buf);
    80004160:	8526                	mv	a0,s1
    80004162:	fffff097          	auipc	ra,0xfffff
    80004166:	0d0080e7          	jalr	208(ra) # 80003232 <brelse>
}
    8000416a:	60e2                	ld	ra,24(sp)
    8000416c:	6442                	ld	s0,16(sp)
    8000416e:	64a2                	ld	s1,8(sp)
    80004170:	6902                	ld	s2,0(sp)
    80004172:	6105                	addi	sp,sp,32
    80004174:	8082                	ret

0000000080004176 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004176:	0001e797          	auipc	a5,0x1e
    8000417a:	9f67a783          	lw	a5,-1546(a5) # 80021b6c <log+0x2c>
    8000417e:	0af05d63          	blez	a5,80004238 <install_trans+0xc2>
{
    80004182:	7139                	addi	sp,sp,-64
    80004184:	fc06                	sd	ra,56(sp)
    80004186:	f822                	sd	s0,48(sp)
    80004188:	f426                	sd	s1,40(sp)
    8000418a:	f04a                	sd	s2,32(sp)
    8000418c:	ec4e                	sd	s3,24(sp)
    8000418e:	e852                	sd	s4,16(sp)
    80004190:	e456                	sd	s5,8(sp)
    80004192:	e05a                	sd	s6,0(sp)
    80004194:	0080                	addi	s0,sp,64
    80004196:	8b2a                	mv	s6,a0
    80004198:	0001ea97          	auipc	s5,0x1e
    8000419c:	9d8a8a93          	addi	s5,s5,-1576 # 80021b70 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041a0:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800041a2:	0001e997          	auipc	s3,0x1e
    800041a6:	99e98993          	addi	s3,s3,-1634 # 80021b40 <log>
    800041aa:	a00d                	j	800041cc <install_trans+0x56>
    brelse(lbuf);
    800041ac:	854a                	mv	a0,s2
    800041ae:	fffff097          	auipc	ra,0xfffff
    800041b2:	084080e7          	jalr	132(ra) # 80003232 <brelse>
    brelse(dbuf);
    800041b6:	8526                	mv	a0,s1
    800041b8:	fffff097          	auipc	ra,0xfffff
    800041bc:	07a080e7          	jalr	122(ra) # 80003232 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041c0:	2a05                	addiw	s4,s4,1
    800041c2:	0a91                	addi	s5,s5,4
    800041c4:	02c9a783          	lw	a5,44(s3)
    800041c8:	04fa5e63          	bge	s4,a5,80004224 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800041cc:	0189a583          	lw	a1,24(s3)
    800041d0:	014585bb          	addw	a1,a1,s4
    800041d4:	2585                	addiw	a1,a1,1
    800041d6:	0289a503          	lw	a0,40(s3)
    800041da:	fffff097          	auipc	ra,0xfffff
    800041de:	f28080e7          	jalr	-216(ra) # 80003102 <bread>
    800041e2:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800041e4:	000aa583          	lw	a1,0(s5)
    800041e8:	0289a503          	lw	a0,40(s3)
    800041ec:	fffff097          	auipc	ra,0xfffff
    800041f0:	f16080e7          	jalr	-234(ra) # 80003102 <bread>
    800041f4:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800041f6:	40000613          	li	a2,1024
    800041fa:	05890593          	addi	a1,s2,88
    800041fe:	05850513          	addi	a0,a0,88
    80004202:	ffffd097          	auipc	ra,0xffffd
    80004206:	b2c080e7          	jalr	-1236(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    8000420a:	8526                	mv	a0,s1
    8000420c:	fffff097          	auipc	ra,0xfffff
    80004210:	fe8080e7          	jalr	-24(ra) # 800031f4 <bwrite>
    if(recovering == 0)
    80004214:	f80b1ce3          	bnez	s6,800041ac <install_trans+0x36>
      bunpin(dbuf);
    80004218:	8526                	mv	a0,s1
    8000421a:	fffff097          	auipc	ra,0xfffff
    8000421e:	0f2080e7          	jalr	242(ra) # 8000330c <bunpin>
    80004222:	b769                	j	800041ac <install_trans+0x36>
}
    80004224:	70e2                	ld	ra,56(sp)
    80004226:	7442                	ld	s0,48(sp)
    80004228:	74a2                	ld	s1,40(sp)
    8000422a:	7902                	ld	s2,32(sp)
    8000422c:	69e2                	ld	s3,24(sp)
    8000422e:	6a42                	ld	s4,16(sp)
    80004230:	6aa2                	ld	s5,8(sp)
    80004232:	6b02                	ld	s6,0(sp)
    80004234:	6121                	addi	sp,sp,64
    80004236:	8082                	ret
    80004238:	8082                	ret

000000008000423a <initlog>:
{
    8000423a:	7179                	addi	sp,sp,-48
    8000423c:	f406                	sd	ra,40(sp)
    8000423e:	f022                	sd	s0,32(sp)
    80004240:	ec26                	sd	s1,24(sp)
    80004242:	e84a                	sd	s2,16(sp)
    80004244:	e44e                	sd	s3,8(sp)
    80004246:	1800                	addi	s0,sp,48
    80004248:	892a                	mv	s2,a0
    8000424a:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000424c:	0001e497          	auipc	s1,0x1e
    80004250:	8f448493          	addi	s1,s1,-1804 # 80021b40 <log>
    80004254:	00004597          	auipc	a1,0x4
    80004258:	3f458593          	addi	a1,a1,1012 # 80008648 <syscalls+0x1f0>
    8000425c:	8526                	mv	a0,s1
    8000425e:	ffffd097          	auipc	ra,0xffffd
    80004262:	8e8080e7          	jalr	-1816(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    80004266:	0149a583          	lw	a1,20(s3)
    8000426a:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000426c:	0109a783          	lw	a5,16(s3)
    80004270:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004272:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004276:	854a                	mv	a0,s2
    80004278:	fffff097          	auipc	ra,0xfffff
    8000427c:	e8a080e7          	jalr	-374(ra) # 80003102 <bread>
  log.lh.n = lh->n;
    80004280:	4d34                	lw	a3,88(a0)
    80004282:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004284:	02d05563          	blez	a3,800042ae <initlog+0x74>
    80004288:	05c50793          	addi	a5,a0,92
    8000428c:	0001e717          	auipc	a4,0x1e
    80004290:	8e470713          	addi	a4,a4,-1820 # 80021b70 <log+0x30>
    80004294:	36fd                	addiw	a3,a3,-1
    80004296:	1682                	slli	a3,a3,0x20
    80004298:	9281                	srli	a3,a3,0x20
    8000429a:	068a                	slli	a3,a3,0x2
    8000429c:	06050613          	addi	a2,a0,96
    800042a0:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800042a2:	4390                	lw	a2,0(a5)
    800042a4:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800042a6:	0791                	addi	a5,a5,4
    800042a8:	0711                	addi	a4,a4,4
    800042aa:	fed79ce3          	bne	a5,a3,800042a2 <initlog+0x68>
  brelse(buf);
    800042ae:	fffff097          	auipc	ra,0xfffff
    800042b2:	f84080e7          	jalr	-124(ra) # 80003232 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800042b6:	4505                	li	a0,1
    800042b8:	00000097          	auipc	ra,0x0
    800042bc:	ebe080e7          	jalr	-322(ra) # 80004176 <install_trans>
  log.lh.n = 0;
    800042c0:	0001e797          	auipc	a5,0x1e
    800042c4:	8a07a623          	sw	zero,-1876(a5) # 80021b6c <log+0x2c>
  write_head(); // clear the log
    800042c8:	00000097          	auipc	ra,0x0
    800042cc:	e34080e7          	jalr	-460(ra) # 800040fc <write_head>
}
    800042d0:	70a2                	ld	ra,40(sp)
    800042d2:	7402                	ld	s0,32(sp)
    800042d4:	64e2                	ld	s1,24(sp)
    800042d6:	6942                	ld	s2,16(sp)
    800042d8:	69a2                	ld	s3,8(sp)
    800042da:	6145                	addi	sp,sp,48
    800042dc:	8082                	ret

00000000800042de <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800042de:	1101                	addi	sp,sp,-32
    800042e0:	ec06                	sd	ra,24(sp)
    800042e2:	e822                	sd	s0,16(sp)
    800042e4:	e426                	sd	s1,8(sp)
    800042e6:	e04a                	sd	s2,0(sp)
    800042e8:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800042ea:	0001e517          	auipc	a0,0x1e
    800042ee:	85650513          	addi	a0,a0,-1962 # 80021b40 <log>
    800042f2:	ffffd097          	auipc	ra,0xffffd
    800042f6:	8e4080e7          	jalr	-1820(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    800042fa:	0001e497          	auipc	s1,0x1e
    800042fe:	84648493          	addi	s1,s1,-1978 # 80021b40 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004302:	4979                	li	s2,30
    80004304:	a039                	j	80004312 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004306:	85a6                	mv	a1,s1
    80004308:	8526                	mv	a0,s1
    8000430a:	ffffe097          	auipc	ra,0xffffe
    8000430e:	eba080e7          	jalr	-326(ra) # 800021c4 <sleep>
    if(log.committing){
    80004312:	50dc                	lw	a5,36(s1)
    80004314:	fbed                	bnez	a5,80004306 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004316:	509c                	lw	a5,32(s1)
    80004318:	0017871b          	addiw	a4,a5,1
    8000431c:	0007069b          	sext.w	a3,a4
    80004320:	0027179b          	slliw	a5,a4,0x2
    80004324:	9fb9                	addw	a5,a5,a4
    80004326:	0017979b          	slliw	a5,a5,0x1
    8000432a:	54d8                	lw	a4,44(s1)
    8000432c:	9fb9                	addw	a5,a5,a4
    8000432e:	00f95963          	bge	s2,a5,80004340 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004332:	85a6                	mv	a1,s1
    80004334:	8526                	mv	a0,s1
    80004336:	ffffe097          	auipc	ra,0xffffe
    8000433a:	e8e080e7          	jalr	-370(ra) # 800021c4 <sleep>
    8000433e:	bfd1                	j	80004312 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004340:	0001e517          	auipc	a0,0x1e
    80004344:	80050513          	addi	a0,a0,-2048 # 80021b40 <log>
    80004348:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000434a:	ffffd097          	auipc	ra,0xffffd
    8000434e:	940080e7          	jalr	-1728(ra) # 80000c8a <release>
      break;
    }
  }
}
    80004352:	60e2                	ld	ra,24(sp)
    80004354:	6442                	ld	s0,16(sp)
    80004356:	64a2                	ld	s1,8(sp)
    80004358:	6902                	ld	s2,0(sp)
    8000435a:	6105                	addi	sp,sp,32
    8000435c:	8082                	ret

000000008000435e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000435e:	7139                	addi	sp,sp,-64
    80004360:	fc06                	sd	ra,56(sp)
    80004362:	f822                	sd	s0,48(sp)
    80004364:	f426                	sd	s1,40(sp)
    80004366:	f04a                	sd	s2,32(sp)
    80004368:	ec4e                	sd	s3,24(sp)
    8000436a:	e852                	sd	s4,16(sp)
    8000436c:	e456                	sd	s5,8(sp)
    8000436e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004370:	0001d497          	auipc	s1,0x1d
    80004374:	7d048493          	addi	s1,s1,2000 # 80021b40 <log>
    80004378:	8526                	mv	a0,s1
    8000437a:	ffffd097          	auipc	ra,0xffffd
    8000437e:	85c080e7          	jalr	-1956(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    80004382:	509c                	lw	a5,32(s1)
    80004384:	37fd                	addiw	a5,a5,-1
    80004386:	0007891b          	sext.w	s2,a5
    8000438a:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000438c:	50dc                	lw	a5,36(s1)
    8000438e:	e7b9                	bnez	a5,800043dc <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004390:	04091e63          	bnez	s2,800043ec <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004394:	0001d497          	auipc	s1,0x1d
    80004398:	7ac48493          	addi	s1,s1,1964 # 80021b40 <log>
    8000439c:	4785                	li	a5,1
    8000439e:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800043a0:	8526                	mv	a0,s1
    800043a2:	ffffd097          	auipc	ra,0xffffd
    800043a6:	8e8080e7          	jalr	-1816(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800043aa:	54dc                	lw	a5,44(s1)
    800043ac:	06f04763          	bgtz	a5,8000441a <end_op+0xbc>
    acquire(&log.lock);
    800043b0:	0001d497          	auipc	s1,0x1d
    800043b4:	79048493          	addi	s1,s1,1936 # 80021b40 <log>
    800043b8:	8526                	mv	a0,s1
    800043ba:	ffffd097          	auipc	ra,0xffffd
    800043be:	81c080e7          	jalr	-2020(ra) # 80000bd6 <acquire>
    log.committing = 0;
    800043c2:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800043c6:	8526                	mv	a0,s1
    800043c8:	ffffe097          	auipc	ra,0xffffe
    800043cc:	e60080e7          	jalr	-416(ra) # 80002228 <wakeup>
    release(&log.lock);
    800043d0:	8526                	mv	a0,s1
    800043d2:	ffffd097          	auipc	ra,0xffffd
    800043d6:	8b8080e7          	jalr	-1864(ra) # 80000c8a <release>
}
    800043da:	a03d                	j	80004408 <end_op+0xaa>
    panic("log.committing");
    800043dc:	00004517          	auipc	a0,0x4
    800043e0:	27450513          	addi	a0,a0,628 # 80008650 <syscalls+0x1f8>
    800043e4:	ffffc097          	auipc	ra,0xffffc
    800043e8:	15a080e7          	jalr	346(ra) # 8000053e <panic>
    wakeup(&log);
    800043ec:	0001d497          	auipc	s1,0x1d
    800043f0:	75448493          	addi	s1,s1,1876 # 80021b40 <log>
    800043f4:	8526                	mv	a0,s1
    800043f6:	ffffe097          	auipc	ra,0xffffe
    800043fa:	e32080e7          	jalr	-462(ra) # 80002228 <wakeup>
  release(&log.lock);
    800043fe:	8526                	mv	a0,s1
    80004400:	ffffd097          	auipc	ra,0xffffd
    80004404:	88a080e7          	jalr	-1910(ra) # 80000c8a <release>
}
    80004408:	70e2                	ld	ra,56(sp)
    8000440a:	7442                	ld	s0,48(sp)
    8000440c:	74a2                	ld	s1,40(sp)
    8000440e:	7902                	ld	s2,32(sp)
    80004410:	69e2                	ld	s3,24(sp)
    80004412:	6a42                	ld	s4,16(sp)
    80004414:	6aa2                	ld	s5,8(sp)
    80004416:	6121                	addi	sp,sp,64
    80004418:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000441a:	0001da97          	auipc	s5,0x1d
    8000441e:	756a8a93          	addi	s5,s5,1878 # 80021b70 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004422:	0001da17          	auipc	s4,0x1d
    80004426:	71ea0a13          	addi	s4,s4,1822 # 80021b40 <log>
    8000442a:	018a2583          	lw	a1,24(s4)
    8000442e:	012585bb          	addw	a1,a1,s2
    80004432:	2585                	addiw	a1,a1,1
    80004434:	028a2503          	lw	a0,40(s4)
    80004438:	fffff097          	auipc	ra,0xfffff
    8000443c:	cca080e7          	jalr	-822(ra) # 80003102 <bread>
    80004440:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004442:	000aa583          	lw	a1,0(s5)
    80004446:	028a2503          	lw	a0,40(s4)
    8000444a:	fffff097          	auipc	ra,0xfffff
    8000444e:	cb8080e7          	jalr	-840(ra) # 80003102 <bread>
    80004452:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004454:	40000613          	li	a2,1024
    80004458:	05850593          	addi	a1,a0,88
    8000445c:	05848513          	addi	a0,s1,88
    80004460:	ffffd097          	auipc	ra,0xffffd
    80004464:	8ce080e7          	jalr	-1842(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    80004468:	8526                	mv	a0,s1
    8000446a:	fffff097          	auipc	ra,0xfffff
    8000446e:	d8a080e7          	jalr	-630(ra) # 800031f4 <bwrite>
    brelse(from);
    80004472:	854e                	mv	a0,s3
    80004474:	fffff097          	auipc	ra,0xfffff
    80004478:	dbe080e7          	jalr	-578(ra) # 80003232 <brelse>
    brelse(to);
    8000447c:	8526                	mv	a0,s1
    8000447e:	fffff097          	auipc	ra,0xfffff
    80004482:	db4080e7          	jalr	-588(ra) # 80003232 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004486:	2905                	addiw	s2,s2,1
    80004488:	0a91                	addi	s5,s5,4
    8000448a:	02ca2783          	lw	a5,44(s4)
    8000448e:	f8f94ee3          	blt	s2,a5,8000442a <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004492:	00000097          	auipc	ra,0x0
    80004496:	c6a080e7          	jalr	-918(ra) # 800040fc <write_head>
    install_trans(0); // Now install writes to home locations
    8000449a:	4501                	li	a0,0
    8000449c:	00000097          	auipc	ra,0x0
    800044a0:	cda080e7          	jalr	-806(ra) # 80004176 <install_trans>
    log.lh.n = 0;
    800044a4:	0001d797          	auipc	a5,0x1d
    800044a8:	6c07a423          	sw	zero,1736(a5) # 80021b6c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800044ac:	00000097          	auipc	ra,0x0
    800044b0:	c50080e7          	jalr	-944(ra) # 800040fc <write_head>
    800044b4:	bdf5                	j	800043b0 <end_op+0x52>

00000000800044b6 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800044b6:	1101                	addi	sp,sp,-32
    800044b8:	ec06                	sd	ra,24(sp)
    800044ba:	e822                	sd	s0,16(sp)
    800044bc:	e426                	sd	s1,8(sp)
    800044be:	e04a                	sd	s2,0(sp)
    800044c0:	1000                	addi	s0,sp,32
    800044c2:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800044c4:	0001d917          	auipc	s2,0x1d
    800044c8:	67c90913          	addi	s2,s2,1660 # 80021b40 <log>
    800044cc:	854a                	mv	a0,s2
    800044ce:	ffffc097          	auipc	ra,0xffffc
    800044d2:	708080e7          	jalr	1800(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800044d6:	02c92603          	lw	a2,44(s2)
    800044da:	47f5                	li	a5,29
    800044dc:	06c7c563          	blt	a5,a2,80004546 <log_write+0x90>
    800044e0:	0001d797          	auipc	a5,0x1d
    800044e4:	67c7a783          	lw	a5,1660(a5) # 80021b5c <log+0x1c>
    800044e8:	37fd                	addiw	a5,a5,-1
    800044ea:	04f65e63          	bge	a2,a5,80004546 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800044ee:	0001d797          	auipc	a5,0x1d
    800044f2:	6727a783          	lw	a5,1650(a5) # 80021b60 <log+0x20>
    800044f6:	06f05063          	blez	a5,80004556 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800044fa:	4781                	li	a5,0
    800044fc:	06c05563          	blez	a2,80004566 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004500:	44cc                	lw	a1,12(s1)
    80004502:	0001d717          	auipc	a4,0x1d
    80004506:	66e70713          	addi	a4,a4,1646 # 80021b70 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000450a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000450c:	4314                	lw	a3,0(a4)
    8000450e:	04b68c63          	beq	a3,a1,80004566 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004512:	2785                	addiw	a5,a5,1
    80004514:	0711                	addi	a4,a4,4
    80004516:	fef61be3          	bne	a2,a5,8000450c <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000451a:	0621                	addi	a2,a2,8
    8000451c:	060a                	slli	a2,a2,0x2
    8000451e:	0001d797          	auipc	a5,0x1d
    80004522:	62278793          	addi	a5,a5,1570 # 80021b40 <log>
    80004526:	963e                	add	a2,a2,a5
    80004528:	44dc                	lw	a5,12(s1)
    8000452a:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000452c:	8526                	mv	a0,s1
    8000452e:	fffff097          	auipc	ra,0xfffff
    80004532:	da2080e7          	jalr	-606(ra) # 800032d0 <bpin>
    log.lh.n++;
    80004536:	0001d717          	auipc	a4,0x1d
    8000453a:	60a70713          	addi	a4,a4,1546 # 80021b40 <log>
    8000453e:	575c                	lw	a5,44(a4)
    80004540:	2785                	addiw	a5,a5,1
    80004542:	d75c                	sw	a5,44(a4)
    80004544:	a835                	j	80004580 <log_write+0xca>
    panic("too big a transaction");
    80004546:	00004517          	auipc	a0,0x4
    8000454a:	11a50513          	addi	a0,a0,282 # 80008660 <syscalls+0x208>
    8000454e:	ffffc097          	auipc	ra,0xffffc
    80004552:	ff0080e7          	jalr	-16(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    80004556:	00004517          	auipc	a0,0x4
    8000455a:	12250513          	addi	a0,a0,290 # 80008678 <syscalls+0x220>
    8000455e:	ffffc097          	auipc	ra,0xffffc
    80004562:	fe0080e7          	jalr	-32(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    80004566:	00878713          	addi	a4,a5,8
    8000456a:	00271693          	slli	a3,a4,0x2
    8000456e:	0001d717          	auipc	a4,0x1d
    80004572:	5d270713          	addi	a4,a4,1490 # 80021b40 <log>
    80004576:	9736                	add	a4,a4,a3
    80004578:	44d4                	lw	a3,12(s1)
    8000457a:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000457c:	faf608e3          	beq	a2,a5,8000452c <log_write+0x76>
  }
  release(&log.lock);
    80004580:	0001d517          	auipc	a0,0x1d
    80004584:	5c050513          	addi	a0,a0,1472 # 80021b40 <log>
    80004588:	ffffc097          	auipc	ra,0xffffc
    8000458c:	702080e7          	jalr	1794(ra) # 80000c8a <release>
}
    80004590:	60e2                	ld	ra,24(sp)
    80004592:	6442                	ld	s0,16(sp)
    80004594:	64a2                	ld	s1,8(sp)
    80004596:	6902                	ld	s2,0(sp)
    80004598:	6105                	addi	sp,sp,32
    8000459a:	8082                	ret

000000008000459c <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000459c:	1101                	addi	sp,sp,-32
    8000459e:	ec06                	sd	ra,24(sp)
    800045a0:	e822                	sd	s0,16(sp)
    800045a2:	e426                	sd	s1,8(sp)
    800045a4:	e04a                	sd	s2,0(sp)
    800045a6:	1000                	addi	s0,sp,32
    800045a8:	84aa                	mv	s1,a0
    800045aa:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800045ac:	00004597          	auipc	a1,0x4
    800045b0:	0ec58593          	addi	a1,a1,236 # 80008698 <syscalls+0x240>
    800045b4:	0521                	addi	a0,a0,8
    800045b6:	ffffc097          	auipc	ra,0xffffc
    800045ba:	590080e7          	jalr	1424(ra) # 80000b46 <initlock>
  lk->name = name;
    800045be:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800045c2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045c6:	0204a423          	sw	zero,40(s1)
}
    800045ca:	60e2                	ld	ra,24(sp)
    800045cc:	6442                	ld	s0,16(sp)
    800045ce:	64a2                	ld	s1,8(sp)
    800045d0:	6902                	ld	s2,0(sp)
    800045d2:	6105                	addi	sp,sp,32
    800045d4:	8082                	ret

00000000800045d6 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800045d6:	1101                	addi	sp,sp,-32
    800045d8:	ec06                	sd	ra,24(sp)
    800045da:	e822                	sd	s0,16(sp)
    800045dc:	e426                	sd	s1,8(sp)
    800045de:	e04a                	sd	s2,0(sp)
    800045e0:	1000                	addi	s0,sp,32
    800045e2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045e4:	00850913          	addi	s2,a0,8
    800045e8:	854a                	mv	a0,s2
    800045ea:	ffffc097          	auipc	ra,0xffffc
    800045ee:	5ec080e7          	jalr	1516(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    800045f2:	409c                	lw	a5,0(s1)
    800045f4:	cb89                	beqz	a5,80004606 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800045f6:	85ca                	mv	a1,s2
    800045f8:	8526                	mv	a0,s1
    800045fa:	ffffe097          	auipc	ra,0xffffe
    800045fe:	bca080e7          	jalr	-1078(ra) # 800021c4 <sleep>
  while (lk->locked) {
    80004602:	409c                	lw	a5,0(s1)
    80004604:	fbed                	bnez	a5,800045f6 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004606:	4785                	li	a5,1
    80004608:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000460a:	ffffd097          	auipc	ra,0xffffd
    8000460e:	3c0080e7          	jalr	960(ra) # 800019ca <myproc>
    80004612:	591c                	lw	a5,48(a0)
    80004614:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004616:	854a                	mv	a0,s2
    80004618:	ffffc097          	auipc	ra,0xffffc
    8000461c:	672080e7          	jalr	1650(ra) # 80000c8a <release>
}
    80004620:	60e2                	ld	ra,24(sp)
    80004622:	6442                	ld	s0,16(sp)
    80004624:	64a2                	ld	s1,8(sp)
    80004626:	6902                	ld	s2,0(sp)
    80004628:	6105                	addi	sp,sp,32
    8000462a:	8082                	ret

000000008000462c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000462c:	1101                	addi	sp,sp,-32
    8000462e:	ec06                	sd	ra,24(sp)
    80004630:	e822                	sd	s0,16(sp)
    80004632:	e426                	sd	s1,8(sp)
    80004634:	e04a                	sd	s2,0(sp)
    80004636:	1000                	addi	s0,sp,32
    80004638:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000463a:	00850913          	addi	s2,a0,8
    8000463e:	854a                	mv	a0,s2
    80004640:	ffffc097          	auipc	ra,0xffffc
    80004644:	596080e7          	jalr	1430(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    80004648:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000464c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004650:	8526                	mv	a0,s1
    80004652:	ffffe097          	auipc	ra,0xffffe
    80004656:	bd6080e7          	jalr	-1066(ra) # 80002228 <wakeup>
  release(&lk->lk);
    8000465a:	854a                	mv	a0,s2
    8000465c:	ffffc097          	auipc	ra,0xffffc
    80004660:	62e080e7          	jalr	1582(ra) # 80000c8a <release>
}
    80004664:	60e2                	ld	ra,24(sp)
    80004666:	6442                	ld	s0,16(sp)
    80004668:	64a2                	ld	s1,8(sp)
    8000466a:	6902                	ld	s2,0(sp)
    8000466c:	6105                	addi	sp,sp,32
    8000466e:	8082                	ret

0000000080004670 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004670:	7179                	addi	sp,sp,-48
    80004672:	f406                	sd	ra,40(sp)
    80004674:	f022                	sd	s0,32(sp)
    80004676:	ec26                	sd	s1,24(sp)
    80004678:	e84a                	sd	s2,16(sp)
    8000467a:	e44e                	sd	s3,8(sp)
    8000467c:	1800                	addi	s0,sp,48
    8000467e:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004680:	00850913          	addi	s2,a0,8
    80004684:	854a                	mv	a0,s2
    80004686:	ffffc097          	auipc	ra,0xffffc
    8000468a:	550080e7          	jalr	1360(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000468e:	409c                	lw	a5,0(s1)
    80004690:	ef99                	bnez	a5,800046ae <holdingsleep+0x3e>
    80004692:	4481                	li	s1,0
  release(&lk->lk);
    80004694:	854a                	mv	a0,s2
    80004696:	ffffc097          	auipc	ra,0xffffc
    8000469a:	5f4080e7          	jalr	1524(ra) # 80000c8a <release>
  return r;
}
    8000469e:	8526                	mv	a0,s1
    800046a0:	70a2                	ld	ra,40(sp)
    800046a2:	7402                	ld	s0,32(sp)
    800046a4:	64e2                	ld	s1,24(sp)
    800046a6:	6942                	ld	s2,16(sp)
    800046a8:	69a2                	ld	s3,8(sp)
    800046aa:	6145                	addi	sp,sp,48
    800046ac:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800046ae:	0284a983          	lw	s3,40(s1)
    800046b2:	ffffd097          	auipc	ra,0xffffd
    800046b6:	318080e7          	jalr	792(ra) # 800019ca <myproc>
    800046ba:	5904                	lw	s1,48(a0)
    800046bc:	413484b3          	sub	s1,s1,s3
    800046c0:	0014b493          	seqz	s1,s1
    800046c4:	bfc1                	j	80004694 <holdingsleep+0x24>

00000000800046c6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800046c6:	1141                	addi	sp,sp,-16
    800046c8:	e406                	sd	ra,8(sp)
    800046ca:	e022                	sd	s0,0(sp)
    800046cc:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800046ce:	00004597          	auipc	a1,0x4
    800046d2:	fda58593          	addi	a1,a1,-38 # 800086a8 <syscalls+0x250>
    800046d6:	0001d517          	auipc	a0,0x1d
    800046da:	5b250513          	addi	a0,a0,1458 # 80021c88 <ftable>
    800046de:	ffffc097          	auipc	ra,0xffffc
    800046e2:	468080e7          	jalr	1128(ra) # 80000b46 <initlock>
}
    800046e6:	60a2                	ld	ra,8(sp)
    800046e8:	6402                	ld	s0,0(sp)
    800046ea:	0141                	addi	sp,sp,16
    800046ec:	8082                	ret

00000000800046ee <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800046ee:	1101                	addi	sp,sp,-32
    800046f0:	ec06                	sd	ra,24(sp)
    800046f2:	e822                	sd	s0,16(sp)
    800046f4:	e426                	sd	s1,8(sp)
    800046f6:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800046f8:	0001d517          	auipc	a0,0x1d
    800046fc:	59050513          	addi	a0,a0,1424 # 80021c88 <ftable>
    80004700:	ffffc097          	auipc	ra,0xffffc
    80004704:	4d6080e7          	jalr	1238(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004708:	0001d497          	auipc	s1,0x1d
    8000470c:	59848493          	addi	s1,s1,1432 # 80021ca0 <ftable+0x18>
    80004710:	0001e717          	auipc	a4,0x1e
    80004714:	53070713          	addi	a4,a4,1328 # 80022c40 <disk>
    if(f->ref == 0){
    80004718:	40dc                	lw	a5,4(s1)
    8000471a:	cf99                	beqz	a5,80004738 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000471c:	02848493          	addi	s1,s1,40
    80004720:	fee49ce3          	bne	s1,a4,80004718 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004724:	0001d517          	auipc	a0,0x1d
    80004728:	56450513          	addi	a0,a0,1380 # 80021c88 <ftable>
    8000472c:	ffffc097          	auipc	ra,0xffffc
    80004730:	55e080e7          	jalr	1374(ra) # 80000c8a <release>
  return 0;
    80004734:	4481                	li	s1,0
    80004736:	a819                	j	8000474c <filealloc+0x5e>
      f->ref = 1;
    80004738:	4785                	li	a5,1
    8000473a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000473c:	0001d517          	auipc	a0,0x1d
    80004740:	54c50513          	addi	a0,a0,1356 # 80021c88 <ftable>
    80004744:	ffffc097          	auipc	ra,0xffffc
    80004748:	546080e7          	jalr	1350(ra) # 80000c8a <release>
}
    8000474c:	8526                	mv	a0,s1
    8000474e:	60e2                	ld	ra,24(sp)
    80004750:	6442                	ld	s0,16(sp)
    80004752:	64a2                	ld	s1,8(sp)
    80004754:	6105                	addi	sp,sp,32
    80004756:	8082                	ret

0000000080004758 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004758:	1101                	addi	sp,sp,-32
    8000475a:	ec06                	sd	ra,24(sp)
    8000475c:	e822                	sd	s0,16(sp)
    8000475e:	e426                	sd	s1,8(sp)
    80004760:	1000                	addi	s0,sp,32
    80004762:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004764:	0001d517          	auipc	a0,0x1d
    80004768:	52450513          	addi	a0,a0,1316 # 80021c88 <ftable>
    8000476c:	ffffc097          	auipc	ra,0xffffc
    80004770:	46a080e7          	jalr	1130(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004774:	40dc                	lw	a5,4(s1)
    80004776:	02f05263          	blez	a5,8000479a <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000477a:	2785                	addiw	a5,a5,1
    8000477c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000477e:	0001d517          	auipc	a0,0x1d
    80004782:	50a50513          	addi	a0,a0,1290 # 80021c88 <ftable>
    80004786:	ffffc097          	auipc	ra,0xffffc
    8000478a:	504080e7          	jalr	1284(ra) # 80000c8a <release>
  return f;
}
    8000478e:	8526                	mv	a0,s1
    80004790:	60e2                	ld	ra,24(sp)
    80004792:	6442                	ld	s0,16(sp)
    80004794:	64a2                	ld	s1,8(sp)
    80004796:	6105                	addi	sp,sp,32
    80004798:	8082                	ret
    panic("filedup");
    8000479a:	00004517          	auipc	a0,0x4
    8000479e:	f1650513          	addi	a0,a0,-234 # 800086b0 <syscalls+0x258>
    800047a2:	ffffc097          	auipc	ra,0xffffc
    800047a6:	d9c080e7          	jalr	-612(ra) # 8000053e <panic>

00000000800047aa <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800047aa:	7139                	addi	sp,sp,-64
    800047ac:	fc06                	sd	ra,56(sp)
    800047ae:	f822                	sd	s0,48(sp)
    800047b0:	f426                	sd	s1,40(sp)
    800047b2:	f04a                	sd	s2,32(sp)
    800047b4:	ec4e                	sd	s3,24(sp)
    800047b6:	e852                	sd	s4,16(sp)
    800047b8:	e456                	sd	s5,8(sp)
    800047ba:	0080                	addi	s0,sp,64
    800047bc:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800047be:	0001d517          	auipc	a0,0x1d
    800047c2:	4ca50513          	addi	a0,a0,1226 # 80021c88 <ftable>
    800047c6:	ffffc097          	auipc	ra,0xffffc
    800047ca:	410080e7          	jalr	1040(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    800047ce:	40dc                	lw	a5,4(s1)
    800047d0:	06f05163          	blez	a5,80004832 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800047d4:	37fd                	addiw	a5,a5,-1
    800047d6:	0007871b          	sext.w	a4,a5
    800047da:	c0dc                	sw	a5,4(s1)
    800047dc:	06e04363          	bgtz	a4,80004842 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800047e0:	0004a903          	lw	s2,0(s1)
    800047e4:	0094ca83          	lbu	s5,9(s1)
    800047e8:	0104ba03          	ld	s4,16(s1)
    800047ec:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800047f0:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800047f4:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800047f8:	0001d517          	auipc	a0,0x1d
    800047fc:	49050513          	addi	a0,a0,1168 # 80021c88 <ftable>
    80004800:	ffffc097          	auipc	ra,0xffffc
    80004804:	48a080e7          	jalr	1162(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    80004808:	4785                	li	a5,1
    8000480a:	04f90d63          	beq	s2,a5,80004864 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000480e:	3979                	addiw	s2,s2,-2
    80004810:	4785                	li	a5,1
    80004812:	0527e063          	bltu	a5,s2,80004852 <fileclose+0xa8>
    begin_op();
    80004816:	00000097          	auipc	ra,0x0
    8000481a:	ac8080e7          	jalr	-1336(ra) # 800042de <begin_op>
    iput(ff.ip);
    8000481e:	854e                	mv	a0,s3
    80004820:	fffff097          	auipc	ra,0xfffff
    80004824:	2b6080e7          	jalr	694(ra) # 80003ad6 <iput>
    end_op();
    80004828:	00000097          	auipc	ra,0x0
    8000482c:	b36080e7          	jalr	-1226(ra) # 8000435e <end_op>
    80004830:	a00d                	j	80004852 <fileclose+0xa8>
    panic("fileclose");
    80004832:	00004517          	auipc	a0,0x4
    80004836:	e8650513          	addi	a0,a0,-378 # 800086b8 <syscalls+0x260>
    8000483a:	ffffc097          	auipc	ra,0xffffc
    8000483e:	d04080e7          	jalr	-764(ra) # 8000053e <panic>
    release(&ftable.lock);
    80004842:	0001d517          	auipc	a0,0x1d
    80004846:	44650513          	addi	a0,a0,1094 # 80021c88 <ftable>
    8000484a:	ffffc097          	auipc	ra,0xffffc
    8000484e:	440080e7          	jalr	1088(ra) # 80000c8a <release>
  }
}
    80004852:	70e2                	ld	ra,56(sp)
    80004854:	7442                	ld	s0,48(sp)
    80004856:	74a2                	ld	s1,40(sp)
    80004858:	7902                	ld	s2,32(sp)
    8000485a:	69e2                	ld	s3,24(sp)
    8000485c:	6a42                	ld	s4,16(sp)
    8000485e:	6aa2                	ld	s5,8(sp)
    80004860:	6121                	addi	sp,sp,64
    80004862:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004864:	85d6                	mv	a1,s5
    80004866:	8552                	mv	a0,s4
    80004868:	00000097          	auipc	ra,0x0
    8000486c:	34c080e7          	jalr	844(ra) # 80004bb4 <pipeclose>
    80004870:	b7cd                	j	80004852 <fileclose+0xa8>

0000000080004872 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004872:	715d                	addi	sp,sp,-80
    80004874:	e486                	sd	ra,72(sp)
    80004876:	e0a2                	sd	s0,64(sp)
    80004878:	fc26                	sd	s1,56(sp)
    8000487a:	f84a                	sd	s2,48(sp)
    8000487c:	f44e                	sd	s3,40(sp)
    8000487e:	0880                	addi	s0,sp,80
    80004880:	84aa                	mv	s1,a0
    80004882:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004884:	ffffd097          	auipc	ra,0xffffd
    80004888:	146080e7          	jalr	326(ra) # 800019ca <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000488c:	409c                	lw	a5,0(s1)
    8000488e:	37f9                	addiw	a5,a5,-2
    80004890:	4705                	li	a4,1
    80004892:	04f76763          	bltu	a4,a5,800048e0 <filestat+0x6e>
    80004896:	892a                	mv	s2,a0
    ilock(f->ip);
    80004898:	6c88                	ld	a0,24(s1)
    8000489a:	fffff097          	auipc	ra,0xfffff
    8000489e:	082080e7          	jalr	130(ra) # 8000391c <ilock>
    stati(f->ip, &st);
    800048a2:	fb840593          	addi	a1,s0,-72
    800048a6:	6c88                	ld	a0,24(s1)
    800048a8:	fffff097          	auipc	ra,0xfffff
    800048ac:	2fe080e7          	jalr	766(ra) # 80003ba6 <stati>
    iunlock(f->ip);
    800048b0:	6c88                	ld	a0,24(s1)
    800048b2:	fffff097          	auipc	ra,0xfffff
    800048b6:	12c080e7          	jalr	300(ra) # 800039de <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800048ba:	46e1                	li	a3,24
    800048bc:	fb840613          	addi	a2,s0,-72
    800048c0:	85ce                	mv	a1,s3
    800048c2:	09093503          	ld	a0,144(s2)
    800048c6:	ffffd097          	auipc	ra,0xffffd
    800048ca:	da2080e7          	jalr	-606(ra) # 80001668 <copyout>
    800048ce:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800048d2:	60a6                	ld	ra,72(sp)
    800048d4:	6406                	ld	s0,64(sp)
    800048d6:	74e2                	ld	s1,56(sp)
    800048d8:	7942                	ld	s2,48(sp)
    800048da:	79a2                	ld	s3,40(sp)
    800048dc:	6161                	addi	sp,sp,80
    800048de:	8082                	ret
  return -1;
    800048e0:	557d                	li	a0,-1
    800048e2:	bfc5                	j	800048d2 <filestat+0x60>

00000000800048e4 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800048e4:	7179                	addi	sp,sp,-48
    800048e6:	f406                	sd	ra,40(sp)
    800048e8:	f022                	sd	s0,32(sp)
    800048ea:	ec26                	sd	s1,24(sp)
    800048ec:	e84a                	sd	s2,16(sp)
    800048ee:	e44e                	sd	s3,8(sp)
    800048f0:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800048f2:	00854783          	lbu	a5,8(a0)
    800048f6:	c3d5                	beqz	a5,8000499a <fileread+0xb6>
    800048f8:	84aa                	mv	s1,a0
    800048fa:	89ae                	mv	s3,a1
    800048fc:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800048fe:	411c                	lw	a5,0(a0)
    80004900:	4705                	li	a4,1
    80004902:	04e78963          	beq	a5,a4,80004954 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004906:	470d                	li	a4,3
    80004908:	04e78d63          	beq	a5,a4,80004962 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000490c:	4709                	li	a4,2
    8000490e:	06e79e63          	bne	a5,a4,8000498a <fileread+0xa6>
    ilock(f->ip);
    80004912:	6d08                	ld	a0,24(a0)
    80004914:	fffff097          	auipc	ra,0xfffff
    80004918:	008080e7          	jalr	8(ra) # 8000391c <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000491c:	874a                	mv	a4,s2
    8000491e:	5094                	lw	a3,32(s1)
    80004920:	864e                	mv	a2,s3
    80004922:	4585                	li	a1,1
    80004924:	6c88                	ld	a0,24(s1)
    80004926:	fffff097          	auipc	ra,0xfffff
    8000492a:	2aa080e7          	jalr	682(ra) # 80003bd0 <readi>
    8000492e:	892a                	mv	s2,a0
    80004930:	00a05563          	blez	a0,8000493a <fileread+0x56>
      f->off += r;
    80004934:	509c                	lw	a5,32(s1)
    80004936:	9fa9                	addw	a5,a5,a0
    80004938:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000493a:	6c88                	ld	a0,24(s1)
    8000493c:	fffff097          	auipc	ra,0xfffff
    80004940:	0a2080e7          	jalr	162(ra) # 800039de <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004944:	854a                	mv	a0,s2
    80004946:	70a2                	ld	ra,40(sp)
    80004948:	7402                	ld	s0,32(sp)
    8000494a:	64e2                	ld	s1,24(sp)
    8000494c:	6942                	ld	s2,16(sp)
    8000494e:	69a2                	ld	s3,8(sp)
    80004950:	6145                	addi	sp,sp,48
    80004952:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004954:	6908                	ld	a0,16(a0)
    80004956:	00000097          	auipc	ra,0x0
    8000495a:	3c6080e7          	jalr	966(ra) # 80004d1c <piperead>
    8000495e:	892a                	mv	s2,a0
    80004960:	b7d5                	j	80004944 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004962:	02451783          	lh	a5,36(a0)
    80004966:	03079693          	slli	a3,a5,0x30
    8000496a:	92c1                	srli	a3,a3,0x30
    8000496c:	4725                	li	a4,9
    8000496e:	02d76863          	bltu	a4,a3,8000499e <fileread+0xba>
    80004972:	0792                	slli	a5,a5,0x4
    80004974:	0001d717          	auipc	a4,0x1d
    80004978:	27470713          	addi	a4,a4,628 # 80021be8 <devsw>
    8000497c:	97ba                	add	a5,a5,a4
    8000497e:	639c                	ld	a5,0(a5)
    80004980:	c38d                	beqz	a5,800049a2 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004982:	4505                	li	a0,1
    80004984:	9782                	jalr	a5
    80004986:	892a                	mv	s2,a0
    80004988:	bf75                	j	80004944 <fileread+0x60>
    panic("fileread");
    8000498a:	00004517          	auipc	a0,0x4
    8000498e:	d3e50513          	addi	a0,a0,-706 # 800086c8 <syscalls+0x270>
    80004992:	ffffc097          	auipc	ra,0xffffc
    80004996:	bac080e7          	jalr	-1108(ra) # 8000053e <panic>
    return -1;
    8000499a:	597d                	li	s2,-1
    8000499c:	b765                	j	80004944 <fileread+0x60>
      return -1;
    8000499e:	597d                	li	s2,-1
    800049a0:	b755                	j	80004944 <fileread+0x60>
    800049a2:	597d                	li	s2,-1
    800049a4:	b745                	j	80004944 <fileread+0x60>

00000000800049a6 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800049a6:	715d                	addi	sp,sp,-80
    800049a8:	e486                	sd	ra,72(sp)
    800049aa:	e0a2                	sd	s0,64(sp)
    800049ac:	fc26                	sd	s1,56(sp)
    800049ae:	f84a                	sd	s2,48(sp)
    800049b0:	f44e                	sd	s3,40(sp)
    800049b2:	f052                	sd	s4,32(sp)
    800049b4:	ec56                	sd	s5,24(sp)
    800049b6:	e85a                	sd	s6,16(sp)
    800049b8:	e45e                	sd	s7,8(sp)
    800049ba:	e062                	sd	s8,0(sp)
    800049bc:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800049be:	00954783          	lbu	a5,9(a0)
    800049c2:	10078663          	beqz	a5,80004ace <filewrite+0x128>
    800049c6:	892a                	mv	s2,a0
    800049c8:	8aae                	mv	s5,a1
    800049ca:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800049cc:	411c                	lw	a5,0(a0)
    800049ce:	4705                	li	a4,1
    800049d0:	02e78263          	beq	a5,a4,800049f4 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800049d4:	470d                	li	a4,3
    800049d6:	02e78663          	beq	a5,a4,80004a02 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800049da:	4709                	li	a4,2
    800049dc:	0ee79163          	bne	a5,a4,80004abe <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800049e0:	0ac05d63          	blez	a2,80004a9a <filewrite+0xf4>
    int i = 0;
    800049e4:	4981                	li	s3,0
    800049e6:	6b05                	lui	s6,0x1
    800049e8:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800049ec:	6b85                	lui	s7,0x1
    800049ee:	c00b8b9b          	addiw	s7,s7,-1024
    800049f2:	a861                	j	80004a8a <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800049f4:	6908                	ld	a0,16(a0)
    800049f6:	00000097          	auipc	ra,0x0
    800049fa:	22e080e7          	jalr	558(ra) # 80004c24 <pipewrite>
    800049fe:	8a2a                	mv	s4,a0
    80004a00:	a045                	j	80004aa0 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004a02:	02451783          	lh	a5,36(a0)
    80004a06:	03079693          	slli	a3,a5,0x30
    80004a0a:	92c1                	srli	a3,a3,0x30
    80004a0c:	4725                	li	a4,9
    80004a0e:	0cd76263          	bltu	a4,a3,80004ad2 <filewrite+0x12c>
    80004a12:	0792                	slli	a5,a5,0x4
    80004a14:	0001d717          	auipc	a4,0x1d
    80004a18:	1d470713          	addi	a4,a4,468 # 80021be8 <devsw>
    80004a1c:	97ba                	add	a5,a5,a4
    80004a1e:	679c                	ld	a5,8(a5)
    80004a20:	cbdd                	beqz	a5,80004ad6 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004a22:	4505                	li	a0,1
    80004a24:	9782                	jalr	a5
    80004a26:	8a2a                	mv	s4,a0
    80004a28:	a8a5                	j	80004aa0 <filewrite+0xfa>
    80004a2a:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004a2e:	00000097          	auipc	ra,0x0
    80004a32:	8b0080e7          	jalr	-1872(ra) # 800042de <begin_op>
      ilock(f->ip);
    80004a36:	01893503          	ld	a0,24(s2)
    80004a3a:	fffff097          	auipc	ra,0xfffff
    80004a3e:	ee2080e7          	jalr	-286(ra) # 8000391c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a42:	8762                	mv	a4,s8
    80004a44:	02092683          	lw	a3,32(s2)
    80004a48:	01598633          	add	a2,s3,s5
    80004a4c:	4585                	li	a1,1
    80004a4e:	01893503          	ld	a0,24(s2)
    80004a52:	fffff097          	auipc	ra,0xfffff
    80004a56:	276080e7          	jalr	630(ra) # 80003cc8 <writei>
    80004a5a:	84aa                	mv	s1,a0
    80004a5c:	00a05763          	blez	a0,80004a6a <filewrite+0xc4>
        f->off += r;
    80004a60:	02092783          	lw	a5,32(s2)
    80004a64:	9fa9                	addw	a5,a5,a0
    80004a66:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004a6a:	01893503          	ld	a0,24(s2)
    80004a6e:	fffff097          	auipc	ra,0xfffff
    80004a72:	f70080e7          	jalr	-144(ra) # 800039de <iunlock>
      end_op();
    80004a76:	00000097          	auipc	ra,0x0
    80004a7a:	8e8080e7          	jalr	-1816(ra) # 8000435e <end_op>

      if(r != n1){
    80004a7e:	009c1f63          	bne	s8,s1,80004a9c <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004a82:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004a86:	0149db63          	bge	s3,s4,80004a9c <filewrite+0xf6>
      int n1 = n - i;
    80004a8a:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004a8e:	84be                	mv	s1,a5
    80004a90:	2781                	sext.w	a5,a5
    80004a92:	f8fb5ce3          	bge	s6,a5,80004a2a <filewrite+0x84>
    80004a96:	84de                	mv	s1,s7
    80004a98:	bf49                	j	80004a2a <filewrite+0x84>
    int i = 0;
    80004a9a:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004a9c:	013a1f63          	bne	s4,s3,80004aba <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004aa0:	8552                	mv	a0,s4
    80004aa2:	60a6                	ld	ra,72(sp)
    80004aa4:	6406                	ld	s0,64(sp)
    80004aa6:	74e2                	ld	s1,56(sp)
    80004aa8:	7942                	ld	s2,48(sp)
    80004aaa:	79a2                	ld	s3,40(sp)
    80004aac:	7a02                	ld	s4,32(sp)
    80004aae:	6ae2                	ld	s5,24(sp)
    80004ab0:	6b42                	ld	s6,16(sp)
    80004ab2:	6ba2                	ld	s7,8(sp)
    80004ab4:	6c02                	ld	s8,0(sp)
    80004ab6:	6161                	addi	sp,sp,80
    80004ab8:	8082                	ret
    ret = (i == n ? n : -1);
    80004aba:	5a7d                	li	s4,-1
    80004abc:	b7d5                	j	80004aa0 <filewrite+0xfa>
    panic("filewrite");
    80004abe:	00004517          	auipc	a0,0x4
    80004ac2:	c1a50513          	addi	a0,a0,-998 # 800086d8 <syscalls+0x280>
    80004ac6:	ffffc097          	auipc	ra,0xffffc
    80004aca:	a78080e7          	jalr	-1416(ra) # 8000053e <panic>
    return -1;
    80004ace:	5a7d                	li	s4,-1
    80004ad0:	bfc1                	j	80004aa0 <filewrite+0xfa>
      return -1;
    80004ad2:	5a7d                	li	s4,-1
    80004ad4:	b7f1                	j	80004aa0 <filewrite+0xfa>
    80004ad6:	5a7d                	li	s4,-1
    80004ad8:	b7e1                	j	80004aa0 <filewrite+0xfa>

0000000080004ada <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004ada:	7179                	addi	sp,sp,-48
    80004adc:	f406                	sd	ra,40(sp)
    80004ade:	f022                	sd	s0,32(sp)
    80004ae0:	ec26                	sd	s1,24(sp)
    80004ae2:	e84a                	sd	s2,16(sp)
    80004ae4:	e44e                	sd	s3,8(sp)
    80004ae6:	e052                	sd	s4,0(sp)
    80004ae8:	1800                	addi	s0,sp,48
    80004aea:	84aa                	mv	s1,a0
    80004aec:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004aee:	0005b023          	sd	zero,0(a1)
    80004af2:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004af6:	00000097          	auipc	ra,0x0
    80004afa:	bf8080e7          	jalr	-1032(ra) # 800046ee <filealloc>
    80004afe:	e088                	sd	a0,0(s1)
    80004b00:	c551                	beqz	a0,80004b8c <pipealloc+0xb2>
    80004b02:	00000097          	auipc	ra,0x0
    80004b06:	bec080e7          	jalr	-1044(ra) # 800046ee <filealloc>
    80004b0a:	00aa3023          	sd	a0,0(s4)
    80004b0e:	c92d                	beqz	a0,80004b80 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004b10:	ffffc097          	auipc	ra,0xffffc
    80004b14:	fd6080e7          	jalr	-42(ra) # 80000ae6 <kalloc>
    80004b18:	892a                	mv	s2,a0
    80004b1a:	c125                	beqz	a0,80004b7a <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004b1c:	4985                	li	s3,1
    80004b1e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004b22:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004b26:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004b2a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004b2e:	00004597          	auipc	a1,0x4
    80004b32:	bba58593          	addi	a1,a1,-1094 # 800086e8 <syscalls+0x290>
    80004b36:	ffffc097          	auipc	ra,0xffffc
    80004b3a:	010080e7          	jalr	16(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004b3e:	609c                	ld	a5,0(s1)
    80004b40:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004b44:	609c                	ld	a5,0(s1)
    80004b46:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004b4a:	609c                	ld	a5,0(s1)
    80004b4c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b50:	609c                	ld	a5,0(s1)
    80004b52:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004b56:	000a3783          	ld	a5,0(s4)
    80004b5a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004b5e:	000a3783          	ld	a5,0(s4)
    80004b62:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b66:	000a3783          	ld	a5,0(s4)
    80004b6a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004b6e:	000a3783          	ld	a5,0(s4)
    80004b72:	0127b823          	sd	s2,16(a5)
  return 0;
    80004b76:	4501                	li	a0,0
    80004b78:	a025                	j	80004ba0 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004b7a:	6088                	ld	a0,0(s1)
    80004b7c:	e501                	bnez	a0,80004b84 <pipealloc+0xaa>
    80004b7e:	a039                	j	80004b8c <pipealloc+0xb2>
    80004b80:	6088                	ld	a0,0(s1)
    80004b82:	c51d                	beqz	a0,80004bb0 <pipealloc+0xd6>
    fileclose(*f0);
    80004b84:	00000097          	auipc	ra,0x0
    80004b88:	c26080e7          	jalr	-986(ra) # 800047aa <fileclose>
  if(*f1)
    80004b8c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004b90:	557d                	li	a0,-1
  if(*f1)
    80004b92:	c799                	beqz	a5,80004ba0 <pipealloc+0xc6>
    fileclose(*f1);
    80004b94:	853e                	mv	a0,a5
    80004b96:	00000097          	auipc	ra,0x0
    80004b9a:	c14080e7          	jalr	-1004(ra) # 800047aa <fileclose>
  return -1;
    80004b9e:	557d                	li	a0,-1
}
    80004ba0:	70a2                	ld	ra,40(sp)
    80004ba2:	7402                	ld	s0,32(sp)
    80004ba4:	64e2                	ld	s1,24(sp)
    80004ba6:	6942                	ld	s2,16(sp)
    80004ba8:	69a2                	ld	s3,8(sp)
    80004baa:	6a02                	ld	s4,0(sp)
    80004bac:	6145                	addi	sp,sp,48
    80004bae:	8082                	ret
  return -1;
    80004bb0:	557d                	li	a0,-1
    80004bb2:	b7fd                	j	80004ba0 <pipealloc+0xc6>

0000000080004bb4 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004bb4:	1101                	addi	sp,sp,-32
    80004bb6:	ec06                	sd	ra,24(sp)
    80004bb8:	e822                	sd	s0,16(sp)
    80004bba:	e426                	sd	s1,8(sp)
    80004bbc:	e04a                	sd	s2,0(sp)
    80004bbe:	1000                	addi	s0,sp,32
    80004bc0:	84aa                	mv	s1,a0
    80004bc2:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004bc4:	ffffc097          	auipc	ra,0xffffc
    80004bc8:	012080e7          	jalr	18(ra) # 80000bd6 <acquire>
  if(writable){
    80004bcc:	02090d63          	beqz	s2,80004c06 <pipeclose+0x52>
    pi->writeopen = 0;
    80004bd0:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004bd4:	21848513          	addi	a0,s1,536
    80004bd8:	ffffd097          	auipc	ra,0xffffd
    80004bdc:	650080e7          	jalr	1616(ra) # 80002228 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004be0:	2204b783          	ld	a5,544(s1)
    80004be4:	eb95                	bnez	a5,80004c18 <pipeclose+0x64>
    release(&pi->lock);
    80004be6:	8526                	mv	a0,s1
    80004be8:	ffffc097          	auipc	ra,0xffffc
    80004bec:	0a2080e7          	jalr	162(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004bf0:	8526                	mv	a0,s1
    80004bf2:	ffffc097          	auipc	ra,0xffffc
    80004bf6:	df8080e7          	jalr	-520(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    80004bfa:	60e2                	ld	ra,24(sp)
    80004bfc:	6442                	ld	s0,16(sp)
    80004bfe:	64a2                	ld	s1,8(sp)
    80004c00:	6902                	ld	s2,0(sp)
    80004c02:	6105                	addi	sp,sp,32
    80004c04:	8082                	ret
    pi->readopen = 0;
    80004c06:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004c0a:	21c48513          	addi	a0,s1,540
    80004c0e:	ffffd097          	auipc	ra,0xffffd
    80004c12:	61a080e7          	jalr	1562(ra) # 80002228 <wakeup>
    80004c16:	b7e9                	j	80004be0 <pipeclose+0x2c>
    release(&pi->lock);
    80004c18:	8526                	mv	a0,s1
    80004c1a:	ffffc097          	auipc	ra,0xffffc
    80004c1e:	070080e7          	jalr	112(ra) # 80000c8a <release>
}
    80004c22:	bfe1                	j	80004bfa <pipeclose+0x46>

0000000080004c24 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c24:	711d                	addi	sp,sp,-96
    80004c26:	ec86                	sd	ra,88(sp)
    80004c28:	e8a2                	sd	s0,80(sp)
    80004c2a:	e4a6                	sd	s1,72(sp)
    80004c2c:	e0ca                	sd	s2,64(sp)
    80004c2e:	fc4e                	sd	s3,56(sp)
    80004c30:	f852                	sd	s4,48(sp)
    80004c32:	f456                	sd	s5,40(sp)
    80004c34:	f05a                	sd	s6,32(sp)
    80004c36:	ec5e                	sd	s7,24(sp)
    80004c38:	e862                	sd	s8,16(sp)
    80004c3a:	1080                	addi	s0,sp,96
    80004c3c:	84aa                	mv	s1,a0
    80004c3e:	8aae                	mv	s5,a1
    80004c40:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004c42:	ffffd097          	auipc	ra,0xffffd
    80004c46:	d88080e7          	jalr	-632(ra) # 800019ca <myproc>
    80004c4a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004c4c:	8526                	mv	a0,s1
    80004c4e:	ffffc097          	auipc	ra,0xffffc
    80004c52:	f88080e7          	jalr	-120(ra) # 80000bd6 <acquire>
  while(i < n){
    80004c56:	0b405663          	blez	s4,80004d02 <pipewrite+0xde>
  int i = 0;
    80004c5a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c5c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004c5e:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004c62:	21c48b93          	addi	s7,s1,540
    80004c66:	a089                	j	80004ca8 <pipewrite+0x84>
      release(&pi->lock);
    80004c68:	8526                	mv	a0,s1
    80004c6a:	ffffc097          	auipc	ra,0xffffc
    80004c6e:	020080e7          	jalr	32(ra) # 80000c8a <release>
      return -1;
    80004c72:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004c74:	854a                	mv	a0,s2
    80004c76:	60e6                	ld	ra,88(sp)
    80004c78:	6446                	ld	s0,80(sp)
    80004c7a:	64a6                	ld	s1,72(sp)
    80004c7c:	6906                	ld	s2,64(sp)
    80004c7e:	79e2                	ld	s3,56(sp)
    80004c80:	7a42                	ld	s4,48(sp)
    80004c82:	7aa2                	ld	s5,40(sp)
    80004c84:	7b02                	ld	s6,32(sp)
    80004c86:	6be2                	ld	s7,24(sp)
    80004c88:	6c42                	ld	s8,16(sp)
    80004c8a:	6125                	addi	sp,sp,96
    80004c8c:	8082                	ret
      wakeup(&pi->nread);
    80004c8e:	8562                	mv	a0,s8
    80004c90:	ffffd097          	auipc	ra,0xffffd
    80004c94:	598080e7          	jalr	1432(ra) # 80002228 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004c98:	85a6                	mv	a1,s1
    80004c9a:	855e                	mv	a0,s7
    80004c9c:	ffffd097          	auipc	ra,0xffffd
    80004ca0:	528080e7          	jalr	1320(ra) # 800021c4 <sleep>
  while(i < n){
    80004ca4:	07495063          	bge	s2,s4,80004d04 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004ca8:	2204a783          	lw	a5,544(s1)
    80004cac:	dfd5                	beqz	a5,80004c68 <pipewrite+0x44>
    80004cae:	854e                	mv	a0,s3
    80004cb0:	ffffe097          	auipc	ra,0xffffe
    80004cb4:	806080e7          	jalr	-2042(ra) # 800024b6 <killed>
    80004cb8:	f945                	bnez	a0,80004c68 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004cba:	2184a783          	lw	a5,536(s1)
    80004cbe:	21c4a703          	lw	a4,540(s1)
    80004cc2:	2007879b          	addiw	a5,a5,512
    80004cc6:	fcf704e3          	beq	a4,a5,80004c8e <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004cca:	4685                	li	a3,1
    80004ccc:	01590633          	add	a2,s2,s5
    80004cd0:	faf40593          	addi	a1,s0,-81
    80004cd4:	0909b503          	ld	a0,144(s3)
    80004cd8:	ffffd097          	auipc	ra,0xffffd
    80004cdc:	a1c080e7          	jalr	-1508(ra) # 800016f4 <copyin>
    80004ce0:	03650263          	beq	a0,s6,80004d04 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004ce4:	21c4a783          	lw	a5,540(s1)
    80004ce8:	0017871b          	addiw	a4,a5,1
    80004cec:	20e4ae23          	sw	a4,540(s1)
    80004cf0:	1ff7f793          	andi	a5,a5,511
    80004cf4:	97a6                	add	a5,a5,s1
    80004cf6:	faf44703          	lbu	a4,-81(s0)
    80004cfa:	00e78c23          	sb	a4,24(a5)
      i++;
    80004cfe:	2905                	addiw	s2,s2,1
    80004d00:	b755                	j	80004ca4 <pipewrite+0x80>
  int i = 0;
    80004d02:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004d04:	21848513          	addi	a0,s1,536
    80004d08:	ffffd097          	auipc	ra,0xffffd
    80004d0c:	520080e7          	jalr	1312(ra) # 80002228 <wakeup>
  release(&pi->lock);
    80004d10:	8526                	mv	a0,s1
    80004d12:	ffffc097          	auipc	ra,0xffffc
    80004d16:	f78080e7          	jalr	-136(ra) # 80000c8a <release>
  return i;
    80004d1a:	bfa9                	j	80004c74 <pipewrite+0x50>

0000000080004d1c <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d1c:	715d                	addi	sp,sp,-80
    80004d1e:	e486                	sd	ra,72(sp)
    80004d20:	e0a2                	sd	s0,64(sp)
    80004d22:	fc26                	sd	s1,56(sp)
    80004d24:	f84a                	sd	s2,48(sp)
    80004d26:	f44e                	sd	s3,40(sp)
    80004d28:	f052                	sd	s4,32(sp)
    80004d2a:	ec56                	sd	s5,24(sp)
    80004d2c:	e85a                	sd	s6,16(sp)
    80004d2e:	0880                	addi	s0,sp,80
    80004d30:	84aa                	mv	s1,a0
    80004d32:	892e                	mv	s2,a1
    80004d34:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004d36:	ffffd097          	auipc	ra,0xffffd
    80004d3a:	c94080e7          	jalr	-876(ra) # 800019ca <myproc>
    80004d3e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004d40:	8526                	mv	a0,s1
    80004d42:	ffffc097          	auipc	ra,0xffffc
    80004d46:	e94080e7          	jalr	-364(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d4a:	2184a703          	lw	a4,536(s1)
    80004d4e:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d52:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d56:	02f71763          	bne	a4,a5,80004d84 <piperead+0x68>
    80004d5a:	2244a783          	lw	a5,548(s1)
    80004d5e:	c39d                	beqz	a5,80004d84 <piperead+0x68>
    if(killed(pr)){
    80004d60:	8552                	mv	a0,s4
    80004d62:	ffffd097          	auipc	ra,0xffffd
    80004d66:	754080e7          	jalr	1876(ra) # 800024b6 <killed>
    80004d6a:	e941                	bnez	a0,80004dfa <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d6c:	85a6                	mv	a1,s1
    80004d6e:	854e                	mv	a0,s3
    80004d70:	ffffd097          	auipc	ra,0xffffd
    80004d74:	454080e7          	jalr	1108(ra) # 800021c4 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d78:	2184a703          	lw	a4,536(s1)
    80004d7c:	21c4a783          	lw	a5,540(s1)
    80004d80:	fcf70de3          	beq	a4,a5,80004d5a <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d84:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d86:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d88:	05505363          	blez	s5,80004dce <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004d8c:	2184a783          	lw	a5,536(s1)
    80004d90:	21c4a703          	lw	a4,540(s1)
    80004d94:	02f70d63          	beq	a4,a5,80004dce <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004d98:	0017871b          	addiw	a4,a5,1
    80004d9c:	20e4ac23          	sw	a4,536(s1)
    80004da0:	1ff7f793          	andi	a5,a5,511
    80004da4:	97a6                	add	a5,a5,s1
    80004da6:	0187c783          	lbu	a5,24(a5)
    80004daa:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004dae:	4685                	li	a3,1
    80004db0:	fbf40613          	addi	a2,s0,-65
    80004db4:	85ca                	mv	a1,s2
    80004db6:	090a3503          	ld	a0,144(s4)
    80004dba:	ffffd097          	auipc	ra,0xffffd
    80004dbe:	8ae080e7          	jalr	-1874(ra) # 80001668 <copyout>
    80004dc2:	01650663          	beq	a0,s6,80004dce <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dc6:	2985                	addiw	s3,s3,1
    80004dc8:	0905                	addi	s2,s2,1
    80004dca:	fd3a91e3          	bne	s5,s3,80004d8c <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004dce:	21c48513          	addi	a0,s1,540
    80004dd2:	ffffd097          	auipc	ra,0xffffd
    80004dd6:	456080e7          	jalr	1110(ra) # 80002228 <wakeup>
  release(&pi->lock);
    80004dda:	8526                	mv	a0,s1
    80004ddc:	ffffc097          	auipc	ra,0xffffc
    80004de0:	eae080e7          	jalr	-338(ra) # 80000c8a <release>
  return i;
}
    80004de4:	854e                	mv	a0,s3
    80004de6:	60a6                	ld	ra,72(sp)
    80004de8:	6406                	ld	s0,64(sp)
    80004dea:	74e2                	ld	s1,56(sp)
    80004dec:	7942                	ld	s2,48(sp)
    80004dee:	79a2                	ld	s3,40(sp)
    80004df0:	7a02                	ld	s4,32(sp)
    80004df2:	6ae2                	ld	s5,24(sp)
    80004df4:	6b42                	ld	s6,16(sp)
    80004df6:	6161                	addi	sp,sp,80
    80004df8:	8082                	ret
      release(&pi->lock);
    80004dfa:	8526                	mv	a0,s1
    80004dfc:	ffffc097          	auipc	ra,0xffffc
    80004e00:	e8e080e7          	jalr	-370(ra) # 80000c8a <release>
      return -1;
    80004e04:	59fd                	li	s3,-1
    80004e06:	bff9                	j	80004de4 <piperead+0xc8>

0000000080004e08 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004e08:	1141                	addi	sp,sp,-16
    80004e0a:	e422                	sd	s0,8(sp)
    80004e0c:	0800                	addi	s0,sp,16
    80004e0e:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004e10:	8905                	andi	a0,a0,1
    80004e12:	c111                	beqz	a0,80004e16 <flags2perm+0xe>
      perm = PTE_X;
    80004e14:	4521                	li	a0,8
    if(flags & 0x2)
    80004e16:	8b89                	andi	a5,a5,2
    80004e18:	c399                	beqz	a5,80004e1e <flags2perm+0x16>
      perm |= PTE_W;
    80004e1a:	00456513          	ori	a0,a0,4
    return perm;
}
    80004e1e:	6422                	ld	s0,8(sp)
    80004e20:	0141                	addi	sp,sp,16
    80004e22:	8082                	ret

0000000080004e24 <exec>:

int
exec(char *path, char **argv)
{
    80004e24:	de010113          	addi	sp,sp,-544
    80004e28:	20113c23          	sd	ra,536(sp)
    80004e2c:	20813823          	sd	s0,528(sp)
    80004e30:	20913423          	sd	s1,520(sp)
    80004e34:	21213023          	sd	s2,512(sp)
    80004e38:	ffce                	sd	s3,504(sp)
    80004e3a:	fbd2                	sd	s4,496(sp)
    80004e3c:	f7d6                	sd	s5,488(sp)
    80004e3e:	f3da                	sd	s6,480(sp)
    80004e40:	efde                	sd	s7,472(sp)
    80004e42:	ebe2                	sd	s8,464(sp)
    80004e44:	e7e6                	sd	s9,456(sp)
    80004e46:	e3ea                	sd	s10,448(sp)
    80004e48:	ff6e                	sd	s11,440(sp)
    80004e4a:	1400                	addi	s0,sp,544
    80004e4c:	892a                	mv	s2,a0
    80004e4e:	dea43423          	sd	a0,-536(s0)
    80004e52:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e56:	ffffd097          	auipc	ra,0xffffd
    80004e5a:	b74080e7          	jalr	-1164(ra) # 800019ca <myproc>
    80004e5e:	84aa                	mv	s1,a0

  begin_op();
    80004e60:	fffff097          	auipc	ra,0xfffff
    80004e64:	47e080e7          	jalr	1150(ra) # 800042de <begin_op>

  if((ip = namei(path)) == 0){
    80004e68:	854a                	mv	a0,s2
    80004e6a:	fffff097          	auipc	ra,0xfffff
    80004e6e:	258080e7          	jalr	600(ra) # 800040c2 <namei>
    80004e72:	c93d                	beqz	a0,80004ee8 <exec+0xc4>
    80004e74:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004e76:	fffff097          	auipc	ra,0xfffff
    80004e7a:	aa6080e7          	jalr	-1370(ra) # 8000391c <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e7e:	04000713          	li	a4,64
    80004e82:	4681                	li	a3,0
    80004e84:	e5040613          	addi	a2,s0,-432
    80004e88:	4581                	li	a1,0
    80004e8a:	8556                	mv	a0,s5
    80004e8c:	fffff097          	auipc	ra,0xfffff
    80004e90:	d44080e7          	jalr	-700(ra) # 80003bd0 <readi>
    80004e94:	04000793          	li	a5,64
    80004e98:	00f51a63          	bne	a0,a5,80004eac <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004e9c:	e5042703          	lw	a4,-432(s0)
    80004ea0:	464c47b7          	lui	a5,0x464c4
    80004ea4:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004ea8:	04f70663          	beq	a4,a5,80004ef4 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004eac:	8556                	mv	a0,s5
    80004eae:	fffff097          	auipc	ra,0xfffff
    80004eb2:	cd0080e7          	jalr	-816(ra) # 80003b7e <iunlockput>
    end_op();
    80004eb6:	fffff097          	auipc	ra,0xfffff
    80004eba:	4a8080e7          	jalr	1192(ra) # 8000435e <end_op>
  }
  return -1;
    80004ebe:	557d                	li	a0,-1
}
    80004ec0:	21813083          	ld	ra,536(sp)
    80004ec4:	21013403          	ld	s0,528(sp)
    80004ec8:	20813483          	ld	s1,520(sp)
    80004ecc:	20013903          	ld	s2,512(sp)
    80004ed0:	79fe                	ld	s3,504(sp)
    80004ed2:	7a5e                	ld	s4,496(sp)
    80004ed4:	7abe                	ld	s5,488(sp)
    80004ed6:	7b1e                	ld	s6,480(sp)
    80004ed8:	6bfe                	ld	s7,472(sp)
    80004eda:	6c5e                	ld	s8,464(sp)
    80004edc:	6cbe                	ld	s9,456(sp)
    80004ede:	6d1e                	ld	s10,448(sp)
    80004ee0:	7dfa                	ld	s11,440(sp)
    80004ee2:	22010113          	addi	sp,sp,544
    80004ee6:	8082                	ret
    end_op();
    80004ee8:	fffff097          	auipc	ra,0xfffff
    80004eec:	476080e7          	jalr	1142(ra) # 8000435e <end_op>
    return -1;
    80004ef0:	557d                	li	a0,-1
    80004ef2:	b7f9                	j	80004ec0 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004ef4:	8526                	mv	a0,s1
    80004ef6:	ffffd097          	auipc	ra,0xffffd
    80004efa:	b98080e7          	jalr	-1128(ra) # 80001a8e <proc_pagetable>
    80004efe:	8b2a                	mv	s6,a0
    80004f00:	d555                	beqz	a0,80004eac <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f02:	e7042783          	lw	a5,-400(s0)
    80004f06:	e8845703          	lhu	a4,-376(s0)
    80004f0a:	c735                	beqz	a4,80004f76 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f0c:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f0e:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004f12:	6a05                	lui	s4,0x1
    80004f14:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004f18:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004f1c:	6d85                	lui	s11,0x1
    80004f1e:	7d7d                	lui	s10,0xfffff
    80004f20:	a481                	j	80005160 <exec+0x33c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004f22:	00003517          	auipc	a0,0x3
    80004f26:	7ce50513          	addi	a0,a0,1998 # 800086f0 <syscalls+0x298>
    80004f2a:	ffffb097          	auipc	ra,0xffffb
    80004f2e:	614080e7          	jalr	1556(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f32:	874a                	mv	a4,s2
    80004f34:	009c86bb          	addw	a3,s9,s1
    80004f38:	4581                	li	a1,0
    80004f3a:	8556                	mv	a0,s5
    80004f3c:	fffff097          	auipc	ra,0xfffff
    80004f40:	c94080e7          	jalr	-876(ra) # 80003bd0 <readi>
    80004f44:	2501                	sext.w	a0,a0
    80004f46:	1aa91a63          	bne	s2,a0,800050fa <exec+0x2d6>
  for(i = 0; i < sz; i += PGSIZE){
    80004f4a:	009d84bb          	addw	s1,s11,s1
    80004f4e:	013d09bb          	addw	s3,s10,s3
    80004f52:	1f74f763          	bgeu	s1,s7,80005140 <exec+0x31c>
    pa = walkaddr(pagetable, va + i);
    80004f56:	02049593          	slli	a1,s1,0x20
    80004f5a:	9181                	srli	a1,a1,0x20
    80004f5c:	95e2                	add	a1,a1,s8
    80004f5e:	855a                	mv	a0,s6
    80004f60:	ffffc097          	auipc	ra,0xffffc
    80004f64:	0fc080e7          	jalr	252(ra) # 8000105c <walkaddr>
    80004f68:	862a                	mv	a2,a0
    if(pa == 0)
    80004f6a:	dd45                	beqz	a0,80004f22 <exec+0xfe>
      n = PGSIZE;
    80004f6c:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004f6e:	fd49f2e3          	bgeu	s3,s4,80004f32 <exec+0x10e>
      n = sz - i;
    80004f72:	894e                	mv	s2,s3
    80004f74:	bf7d                	j	80004f32 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f76:	4901                	li	s2,0
  iunlockput(ip);
    80004f78:	8556                	mv	a0,s5
    80004f7a:	fffff097          	auipc	ra,0xfffff
    80004f7e:	c04080e7          	jalr	-1020(ra) # 80003b7e <iunlockput>
  end_op();
    80004f82:	fffff097          	auipc	ra,0xfffff
    80004f86:	3dc080e7          	jalr	988(ra) # 8000435e <end_op>
  p = myproc();
    80004f8a:	ffffd097          	auipc	ra,0xffffd
    80004f8e:	a40080e7          	jalr	-1472(ra) # 800019ca <myproc>
    80004f92:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004f94:	08853d03          	ld	s10,136(a0)
  sz = PGROUNDUP(sz);
    80004f98:	6785                	lui	a5,0x1
    80004f9a:	17fd                	addi	a5,a5,-1
    80004f9c:	993e                	add	s2,s2,a5
    80004f9e:	77fd                	lui	a5,0xfffff
    80004fa0:	00f977b3          	and	a5,s2,a5
    80004fa4:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004fa8:	4691                	li	a3,4
    80004faa:	6609                	lui	a2,0x2
    80004fac:	963e                	add	a2,a2,a5
    80004fae:	85be                	mv	a1,a5
    80004fb0:	855a                	mv	a0,s6
    80004fb2:	ffffc097          	auipc	ra,0xffffc
    80004fb6:	45e080e7          	jalr	1118(ra) # 80001410 <uvmalloc>
    80004fba:	8c2a                	mv	s8,a0
  ip = 0;
    80004fbc:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004fbe:	12050e63          	beqz	a0,800050fa <exec+0x2d6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004fc2:	75f9                	lui	a1,0xffffe
    80004fc4:	95aa                	add	a1,a1,a0
    80004fc6:	855a                	mv	a0,s6
    80004fc8:	ffffc097          	auipc	ra,0xffffc
    80004fcc:	66e080e7          	jalr	1646(ra) # 80001636 <uvmclear>
  stackbase = sp - PGSIZE;
    80004fd0:	7afd                	lui	s5,0xfffff
    80004fd2:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004fd4:	df043783          	ld	a5,-528(s0)
    80004fd8:	6388                	ld	a0,0(a5)
    80004fda:	c925                	beqz	a0,8000504a <exec+0x226>
    80004fdc:	e9040993          	addi	s3,s0,-368
    80004fe0:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004fe4:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004fe6:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004fe8:	ffffc097          	auipc	ra,0xffffc
    80004fec:	e66080e7          	jalr	-410(ra) # 80000e4e <strlen>
    80004ff0:	0015079b          	addiw	a5,a0,1
    80004ff4:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004ff8:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004ffc:	13596663          	bltu	s2,s5,80005128 <exec+0x304>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005000:	df043d83          	ld	s11,-528(s0)
    80005004:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005008:	8552                	mv	a0,s4
    8000500a:	ffffc097          	auipc	ra,0xffffc
    8000500e:	e44080e7          	jalr	-444(ra) # 80000e4e <strlen>
    80005012:	0015069b          	addiw	a3,a0,1
    80005016:	8652                	mv	a2,s4
    80005018:	85ca                	mv	a1,s2
    8000501a:	855a                	mv	a0,s6
    8000501c:	ffffc097          	auipc	ra,0xffffc
    80005020:	64c080e7          	jalr	1612(ra) # 80001668 <copyout>
    80005024:	10054663          	bltz	a0,80005130 <exec+0x30c>
    ustack[argc] = sp;
    80005028:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000502c:	0485                	addi	s1,s1,1
    8000502e:	008d8793          	addi	a5,s11,8
    80005032:	def43823          	sd	a5,-528(s0)
    80005036:	008db503          	ld	a0,8(s11)
    8000503a:	c911                	beqz	a0,8000504e <exec+0x22a>
    if(argc >= MAXARG)
    8000503c:	09a1                	addi	s3,s3,8
    8000503e:	fb3c95e3          	bne	s9,s3,80004fe8 <exec+0x1c4>
  sz = sz1;
    80005042:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005046:	4a81                	li	s5,0
    80005048:	a84d                	j	800050fa <exec+0x2d6>
  sp = sz;
    8000504a:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000504c:	4481                	li	s1,0
  ustack[argc] = 0;
    8000504e:	00349793          	slli	a5,s1,0x3
    80005052:	f9040713          	addi	a4,s0,-112
    80005056:	97ba                	add	a5,a5,a4
    80005058:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffdc180>
  sp -= (argc+1) * sizeof(uint64);
    8000505c:	00148693          	addi	a3,s1,1
    80005060:	068e                	slli	a3,a3,0x3
    80005062:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005066:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    8000506a:	01597663          	bgeu	s2,s5,80005076 <exec+0x252>
  sz = sz1;
    8000506e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005072:	4a81                	li	s5,0
    80005074:	a059                	j	800050fa <exec+0x2d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005076:	e9040613          	addi	a2,s0,-368
    8000507a:	85ca                	mv	a1,s2
    8000507c:	855a                	mv	a0,s6
    8000507e:	ffffc097          	auipc	ra,0xffffc
    80005082:	5ea080e7          	jalr	1514(ra) # 80001668 <copyout>
    80005086:	0a054963          	bltz	a0,80005138 <exec+0x314>
  p->trapframe->a1 = sp;
    8000508a:	098bb783          	ld	a5,152(s7) # 1098 <_entry-0x7fffef68>
    8000508e:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005092:	de843783          	ld	a5,-536(s0)
    80005096:	0007c703          	lbu	a4,0(a5)
    8000509a:	cf11                	beqz	a4,800050b6 <exec+0x292>
    8000509c:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000509e:	02f00693          	li	a3,47
    800050a2:	a039                	j	800050b0 <exec+0x28c>
      last = s+1;
    800050a4:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800050a8:	0785                	addi	a5,a5,1
    800050aa:	fff7c703          	lbu	a4,-1(a5)
    800050ae:	c701                	beqz	a4,800050b6 <exec+0x292>
    if(*s == '/')
    800050b0:	fed71ce3          	bne	a4,a3,800050a8 <exec+0x284>
    800050b4:	bfc5                	j	800050a4 <exec+0x280>
  safestrcpy(p->name, last, sizeof(p->name));
    800050b6:	4641                	li	a2,16
    800050b8:	de843583          	ld	a1,-536(s0)
    800050bc:	198b8513          	addi	a0,s7,408
    800050c0:	ffffc097          	auipc	ra,0xffffc
    800050c4:	d5c080e7          	jalr	-676(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    800050c8:	090bb503          	ld	a0,144(s7)
  p->pagetable = pagetable;
    800050cc:	096bb823          	sd	s6,144(s7)
  p->sz = sz;
    800050d0:	098bb423          	sd	s8,136(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800050d4:	098bb783          	ld	a5,152(s7)
    800050d8:	e6843703          	ld	a4,-408(s0)
    800050dc:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800050de:	098bb783          	ld	a5,152(s7)
    800050e2:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800050e6:	85ea                	mv	a1,s10
    800050e8:	ffffd097          	auipc	ra,0xffffd
    800050ec:	a42080e7          	jalr	-1470(ra) # 80001b2a <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800050f0:	0004851b          	sext.w	a0,s1
    800050f4:	b3f1                	j	80004ec0 <exec+0x9c>
    800050f6:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800050fa:	df843583          	ld	a1,-520(s0)
    800050fe:	855a                	mv	a0,s6
    80005100:	ffffd097          	auipc	ra,0xffffd
    80005104:	a2a080e7          	jalr	-1494(ra) # 80001b2a <proc_freepagetable>
  if(ip){
    80005108:	da0a92e3          	bnez	s5,80004eac <exec+0x88>
  return -1;
    8000510c:	557d                	li	a0,-1
    8000510e:	bb4d                	j	80004ec0 <exec+0x9c>
    80005110:	df243c23          	sd	s2,-520(s0)
    80005114:	b7dd                	j	800050fa <exec+0x2d6>
    80005116:	df243c23          	sd	s2,-520(s0)
    8000511a:	b7c5                	j	800050fa <exec+0x2d6>
    8000511c:	df243c23          	sd	s2,-520(s0)
    80005120:	bfe9                	j	800050fa <exec+0x2d6>
    80005122:	df243c23          	sd	s2,-520(s0)
    80005126:	bfd1                	j	800050fa <exec+0x2d6>
  sz = sz1;
    80005128:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000512c:	4a81                	li	s5,0
    8000512e:	b7f1                	j	800050fa <exec+0x2d6>
  sz = sz1;
    80005130:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005134:	4a81                	li	s5,0
    80005136:	b7d1                	j	800050fa <exec+0x2d6>
  sz = sz1;
    80005138:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000513c:	4a81                	li	s5,0
    8000513e:	bf75                	j	800050fa <exec+0x2d6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005140:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005144:	e0843783          	ld	a5,-504(s0)
    80005148:	0017869b          	addiw	a3,a5,1
    8000514c:	e0d43423          	sd	a3,-504(s0)
    80005150:	e0043783          	ld	a5,-512(s0)
    80005154:	0387879b          	addiw	a5,a5,56
    80005158:	e8845703          	lhu	a4,-376(s0)
    8000515c:	e0e6dee3          	bge	a3,a4,80004f78 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005160:	2781                	sext.w	a5,a5
    80005162:	e0f43023          	sd	a5,-512(s0)
    80005166:	03800713          	li	a4,56
    8000516a:	86be                	mv	a3,a5
    8000516c:	e1840613          	addi	a2,s0,-488
    80005170:	4581                	li	a1,0
    80005172:	8556                	mv	a0,s5
    80005174:	fffff097          	auipc	ra,0xfffff
    80005178:	a5c080e7          	jalr	-1444(ra) # 80003bd0 <readi>
    8000517c:	03800793          	li	a5,56
    80005180:	f6f51be3          	bne	a0,a5,800050f6 <exec+0x2d2>
    if(ph.type != ELF_PROG_LOAD)
    80005184:	e1842783          	lw	a5,-488(s0)
    80005188:	4705                	li	a4,1
    8000518a:	fae79de3          	bne	a5,a4,80005144 <exec+0x320>
    if(ph.memsz < ph.filesz)
    8000518e:	e4043483          	ld	s1,-448(s0)
    80005192:	e3843783          	ld	a5,-456(s0)
    80005196:	f6f4ede3          	bltu	s1,a5,80005110 <exec+0x2ec>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000519a:	e2843783          	ld	a5,-472(s0)
    8000519e:	94be                	add	s1,s1,a5
    800051a0:	f6f4ebe3          	bltu	s1,a5,80005116 <exec+0x2f2>
    if(ph.vaddr % PGSIZE != 0)
    800051a4:	de043703          	ld	a4,-544(s0)
    800051a8:	8ff9                	and	a5,a5,a4
    800051aa:	fbad                	bnez	a5,8000511c <exec+0x2f8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800051ac:	e1c42503          	lw	a0,-484(s0)
    800051b0:	00000097          	auipc	ra,0x0
    800051b4:	c58080e7          	jalr	-936(ra) # 80004e08 <flags2perm>
    800051b8:	86aa                	mv	a3,a0
    800051ba:	8626                	mv	a2,s1
    800051bc:	85ca                	mv	a1,s2
    800051be:	855a                	mv	a0,s6
    800051c0:	ffffc097          	auipc	ra,0xffffc
    800051c4:	250080e7          	jalr	592(ra) # 80001410 <uvmalloc>
    800051c8:	dea43c23          	sd	a0,-520(s0)
    800051cc:	d939                	beqz	a0,80005122 <exec+0x2fe>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800051ce:	e2843c03          	ld	s8,-472(s0)
    800051d2:	e2042c83          	lw	s9,-480(s0)
    800051d6:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800051da:	f60b83e3          	beqz	s7,80005140 <exec+0x31c>
    800051de:	89de                	mv	s3,s7
    800051e0:	4481                	li	s1,0
    800051e2:	bb95                	j	80004f56 <exec+0x132>

00000000800051e4 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800051e4:	7179                	addi	sp,sp,-48
    800051e6:	f406                	sd	ra,40(sp)
    800051e8:	f022                	sd	s0,32(sp)
    800051ea:	ec26                	sd	s1,24(sp)
    800051ec:	e84a                	sd	s2,16(sp)
    800051ee:	1800                	addi	s0,sp,48
    800051f0:	892e                	mv	s2,a1
    800051f2:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800051f4:	fdc40593          	addi	a1,s0,-36
    800051f8:	ffffe097          	auipc	ra,0xffffe
    800051fc:	afe080e7          	jalr	-1282(ra) # 80002cf6 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005200:	fdc42703          	lw	a4,-36(s0)
    80005204:	47bd                	li	a5,15
    80005206:	02e7eb63          	bltu	a5,a4,8000523c <argfd+0x58>
    8000520a:	ffffc097          	auipc	ra,0xffffc
    8000520e:	7c0080e7          	jalr	1984(ra) # 800019ca <myproc>
    80005212:	fdc42703          	lw	a4,-36(s0)
    80005216:	02270793          	addi	a5,a4,34
    8000521a:	078e                	slli	a5,a5,0x3
    8000521c:	953e                	add	a0,a0,a5
    8000521e:	611c                	ld	a5,0(a0)
    80005220:	c385                	beqz	a5,80005240 <argfd+0x5c>
    return -1;
  if(pfd)
    80005222:	00090463          	beqz	s2,8000522a <argfd+0x46>
    *pfd = fd;
    80005226:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000522a:	4501                	li	a0,0
  if(pf)
    8000522c:	c091                	beqz	s1,80005230 <argfd+0x4c>
    *pf = f;
    8000522e:	e09c                	sd	a5,0(s1)
}
    80005230:	70a2                	ld	ra,40(sp)
    80005232:	7402                	ld	s0,32(sp)
    80005234:	64e2                	ld	s1,24(sp)
    80005236:	6942                	ld	s2,16(sp)
    80005238:	6145                	addi	sp,sp,48
    8000523a:	8082                	ret
    return -1;
    8000523c:	557d                	li	a0,-1
    8000523e:	bfcd                	j	80005230 <argfd+0x4c>
    80005240:	557d                	li	a0,-1
    80005242:	b7fd                	j	80005230 <argfd+0x4c>

0000000080005244 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005244:	1101                	addi	sp,sp,-32
    80005246:	ec06                	sd	ra,24(sp)
    80005248:	e822                	sd	s0,16(sp)
    8000524a:	e426                	sd	s1,8(sp)
    8000524c:	1000                	addi	s0,sp,32
    8000524e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005250:	ffffc097          	auipc	ra,0xffffc
    80005254:	77a080e7          	jalr	1914(ra) # 800019ca <myproc>
    80005258:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000525a:	11050793          	addi	a5,a0,272
    8000525e:	4501                	li	a0,0
    80005260:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005262:	6398                	ld	a4,0(a5)
    80005264:	cb19                	beqz	a4,8000527a <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005266:	2505                	addiw	a0,a0,1
    80005268:	07a1                	addi	a5,a5,8
    8000526a:	fed51ce3          	bne	a0,a3,80005262 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000526e:	557d                	li	a0,-1
}
    80005270:	60e2                	ld	ra,24(sp)
    80005272:	6442                	ld	s0,16(sp)
    80005274:	64a2                	ld	s1,8(sp)
    80005276:	6105                	addi	sp,sp,32
    80005278:	8082                	ret
      p->ofile[fd] = f;
    8000527a:	02250793          	addi	a5,a0,34
    8000527e:	078e                	slli	a5,a5,0x3
    80005280:	963e                	add	a2,a2,a5
    80005282:	e204                	sd	s1,0(a2)
      return fd;
    80005284:	b7f5                	j	80005270 <fdalloc+0x2c>

0000000080005286 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005286:	715d                	addi	sp,sp,-80
    80005288:	e486                	sd	ra,72(sp)
    8000528a:	e0a2                	sd	s0,64(sp)
    8000528c:	fc26                	sd	s1,56(sp)
    8000528e:	f84a                	sd	s2,48(sp)
    80005290:	f44e                	sd	s3,40(sp)
    80005292:	f052                	sd	s4,32(sp)
    80005294:	ec56                	sd	s5,24(sp)
    80005296:	e85a                	sd	s6,16(sp)
    80005298:	0880                	addi	s0,sp,80
    8000529a:	8b2e                	mv	s6,a1
    8000529c:	89b2                	mv	s3,a2
    8000529e:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800052a0:	fb040593          	addi	a1,s0,-80
    800052a4:	fffff097          	auipc	ra,0xfffff
    800052a8:	e3c080e7          	jalr	-452(ra) # 800040e0 <nameiparent>
    800052ac:	84aa                	mv	s1,a0
    800052ae:	14050f63          	beqz	a0,8000540c <create+0x186>
    return 0;

  ilock(dp);
    800052b2:	ffffe097          	auipc	ra,0xffffe
    800052b6:	66a080e7          	jalr	1642(ra) # 8000391c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800052ba:	4601                	li	a2,0
    800052bc:	fb040593          	addi	a1,s0,-80
    800052c0:	8526                	mv	a0,s1
    800052c2:	fffff097          	auipc	ra,0xfffff
    800052c6:	b3e080e7          	jalr	-1218(ra) # 80003e00 <dirlookup>
    800052ca:	8aaa                	mv	s5,a0
    800052cc:	c931                	beqz	a0,80005320 <create+0x9a>
    iunlockput(dp);
    800052ce:	8526                	mv	a0,s1
    800052d0:	fffff097          	auipc	ra,0xfffff
    800052d4:	8ae080e7          	jalr	-1874(ra) # 80003b7e <iunlockput>
    ilock(ip);
    800052d8:	8556                	mv	a0,s5
    800052da:	ffffe097          	auipc	ra,0xffffe
    800052de:	642080e7          	jalr	1602(ra) # 8000391c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800052e2:	000b059b          	sext.w	a1,s6
    800052e6:	4789                	li	a5,2
    800052e8:	02f59563          	bne	a1,a5,80005312 <create+0x8c>
    800052ec:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdc2c4>
    800052f0:	37f9                	addiw	a5,a5,-2
    800052f2:	17c2                	slli	a5,a5,0x30
    800052f4:	93c1                	srli	a5,a5,0x30
    800052f6:	4705                	li	a4,1
    800052f8:	00f76d63          	bltu	a4,a5,80005312 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800052fc:	8556                	mv	a0,s5
    800052fe:	60a6                	ld	ra,72(sp)
    80005300:	6406                	ld	s0,64(sp)
    80005302:	74e2                	ld	s1,56(sp)
    80005304:	7942                	ld	s2,48(sp)
    80005306:	79a2                	ld	s3,40(sp)
    80005308:	7a02                	ld	s4,32(sp)
    8000530a:	6ae2                	ld	s5,24(sp)
    8000530c:	6b42                	ld	s6,16(sp)
    8000530e:	6161                	addi	sp,sp,80
    80005310:	8082                	ret
    iunlockput(ip);
    80005312:	8556                	mv	a0,s5
    80005314:	fffff097          	auipc	ra,0xfffff
    80005318:	86a080e7          	jalr	-1942(ra) # 80003b7e <iunlockput>
    return 0;
    8000531c:	4a81                	li	s5,0
    8000531e:	bff9                	j	800052fc <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005320:	85da                	mv	a1,s6
    80005322:	4088                	lw	a0,0(s1)
    80005324:	ffffe097          	auipc	ra,0xffffe
    80005328:	45c080e7          	jalr	1116(ra) # 80003780 <ialloc>
    8000532c:	8a2a                	mv	s4,a0
    8000532e:	c539                	beqz	a0,8000537c <create+0xf6>
  ilock(ip);
    80005330:	ffffe097          	auipc	ra,0xffffe
    80005334:	5ec080e7          	jalr	1516(ra) # 8000391c <ilock>
  ip->major = major;
    80005338:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000533c:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005340:	4905                	li	s2,1
    80005342:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005346:	8552                	mv	a0,s4
    80005348:	ffffe097          	auipc	ra,0xffffe
    8000534c:	50a080e7          	jalr	1290(ra) # 80003852 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005350:	000b059b          	sext.w	a1,s6
    80005354:	03258b63          	beq	a1,s2,8000538a <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    80005358:	004a2603          	lw	a2,4(s4)
    8000535c:	fb040593          	addi	a1,s0,-80
    80005360:	8526                	mv	a0,s1
    80005362:	fffff097          	auipc	ra,0xfffff
    80005366:	cae080e7          	jalr	-850(ra) # 80004010 <dirlink>
    8000536a:	06054f63          	bltz	a0,800053e8 <create+0x162>
  iunlockput(dp);
    8000536e:	8526                	mv	a0,s1
    80005370:	fffff097          	auipc	ra,0xfffff
    80005374:	80e080e7          	jalr	-2034(ra) # 80003b7e <iunlockput>
  return ip;
    80005378:	8ad2                	mv	s5,s4
    8000537a:	b749                	j	800052fc <create+0x76>
    iunlockput(dp);
    8000537c:	8526                	mv	a0,s1
    8000537e:	fffff097          	auipc	ra,0xfffff
    80005382:	800080e7          	jalr	-2048(ra) # 80003b7e <iunlockput>
    return 0;
    80005386:	8ad2                	mv	s5,s4
    80005388:	bf95                	j	800052fc <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000538a:	004a2603          	lw	a2,4(s4)
    8000538e:	00003597          	auipc	a1,0x3
    80005392:	38258593          	addi	a1,a1,898 # 80008710 <syscalls+0x2b8>
    80005396:	8552                	mv	a0,s4
    80005398:	fffff097          	auipc	ra,0xfffff
    8000539c:	c78080e7          	jalr	-904(ra) # 80004010 <dirlink>
    800053a0:	04054463          	bltz	a0,800053e8 <create+0x162>
    800053a4:	40d0                	lw	a2,4(s1)
    800053a6:	00003597          	auipc	a1,0x3
    800053aa:	37258593          	addi	a1,a1,882 # 80008718 <syscalls+0x2c0>
    800053ae:	8552                	mv	a0,s4
    800053b0:	fffff097          	auipc	ra,0xfffff
    800053b4:	c60080e7          	jalr	-928(ra) # 80004010 <dirlink>
    800053b8:	02054863          	bltz	a0,800053e8 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    800053bc:	004a2603          	lw	a2,4(s4)
    800053c0:	fb040593          	addi	a1,s0,-80
    800053c4:	8526                	mv	a0,s1
    800053c6:	fffff097          	auipc	ra,0xfffff
    800053ca:	c4a080e7          	jalr	-950(ra) # 80004010 <dirlink>
    800053ce:	00054d63          	bltz	a0,800053e8 <create+0x162>
    dp->nlink++;  // for ".."
    800053d2:	04a4d783          	lhu	a5,74(s1)
    800053d6:	2785                	addiw	a5,a5,1
    800053d8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800053dc:	8526                	mv	a0,s1
    800053de:	ffffe097          	auipc	ra,0xffffe
    800053e2:	474080e7          	jalr	1140(ra) # 80003852 <iupdate>
    800053e6:	b761                	j	8000536e <create+0xe8>
  ip->nlink = 0;
    800053e8:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800053ec:	8552                	mv	a0,s4
    800053ee:	ffffe097          	auipc	ra,0xffffe
    800053f2:	464080e7          	jalr	1124(ra) # 80003852 <iupdate>
  iunlockput(ip);
    800053f6:	8552                	mv	a0,s4
    800053f8:	ffffe097          	auipc	ra,0xffffe
    800053fc:	786080e7          	jalr	1926(ra) # 80003b7e <iunlockput>
  iunlockput(dp);
    80005400:	8526                	mv	a0,s1
    80005402:	ffffe097          	auipc	ra,0xffffe
    80005406:	77c080e7          	jalr	1916(ra) # 80003b7e <iunlockput>
  return 0;
    8000540a:	bdcd                	j	800052fc <create+0x76>
    return 0;
    8000540c:	8aaa                	mv	s5,a0
    8000540e:	b5fd                	j	800052fc <create+0x76>

0000000080005410 <sys_dup>:
{
    80005410:	7179                	addi	sp,sp,-48
    80005412:	f406                	sd	ra,40(sp)
    80005414:	f022                	sd	s0,32(sp)
    80005416:	ec26                	sd	s1,24(sp)
    80005418:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000541a:	fd840613          	addi	a2,s0,-40
    8000541e:	4581                	li	a1,0
    80005420:	4501                	li	a0,0
    80005422:	00000097          	auipc	ra,0x0
    80005426:	dc2080e7          	jalr	-574(ra) # 800051e4 <argfd>
    return -1;
    8000542a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000542c:	02054363          	bltz	a0,80005452 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005430:	fd843503          	ld	a0,-40(s0)
    80005434:	00000097          	auipc	ra,0x0
    80005438:	e10080e7          	jalr	-496(ra) # 80005244 <fdalloc>
    8000543c:	84aa                	mv	s1,a0
    return -1;
    8000543e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005440:	00054963          	bltz	a0,80005452 <sys_dup+0x42>
  filedup(f);
    80005444:	fd843503          	ld	a0,-40(s0)
    80005448:	fffff097          	auipc	ra,0xfffff
    8000544c:	310080e7          	jalr	784(ra) # 80004758 <filedup>
  return fd;
    80005450:	87a6                	mv	a5,s1
}
    80005452:	853e                	mv	a0,a5
    80005454:	70a2                	ld	ra,40(sp)
    80005456:	7402                	ld	s0,32(sp)
    80005458:	64e2                	ld	s1,24(sp)
    8000545a:	6145                	addi	sp,sp,48
    8000545c:	8082                	ret

000000008000545e <sys_read>:
{
    8000545e:	7179                	addi	sp,sp,-48
    80005460:	f406                	sd	ra,40(sp)
    80005462:	f022                	sd	s0,32(sp)
    80005464:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005466:	fd840593          	addi	a1,s0,-40
    8000546a:	4505                	li	a0,1
    8000546c:	ffffe097          	auipc	ra,0xffffe
    80005470:	8aa080e7          	jalr	-1878(ra) # 80002d16 <argaddr>
  argint(2, &n);
    80005474:	fe440593          	addi	a1,s0,-28
    80005478:	4509                	li	a0,2
    8000547a:	ffffe097          	auipc	ra,0xffffe
    8000547e:	87c080e7          	jalr	-1924(ra) # 80002cf6 <argint>
  if(argfd(0, 0, &f) < 0)
    80005482:	fe840613          	addi	a2,s0,-24
    80005486:	4581                	li	a1,0
    80005488:	4501                	li	a0,0
    8000548a:	00000097          	auipc	ra,0x0
    8000548e:	d5a080e7          	jalr	-678(ra) # 800051e4 <argfd>
    80005492:	87aa                	mv	a5,a0
    return -1;
    80005494:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005496:	0007cc63          	bltz	a5,800054ae <sys_read+0x50>
  return fileread(f, p, n);
    8000549a:	fe442603          	lw	a2,-28(s0)
    8000549e:	fd843583          	ld	a1,-40(s0)
    800054a2:	fe843503          	ld	a0,-24(s0)
    800054a6:	fffff097          	auipc	ra,0xfffff
    800054aa:	43e080e7          	jalr	1086(ra) # 800048e4 <fileread>
}
    800054ae:	70a2                	ld	ra,40(sp)
    800054b0:	7402                	ld	s0,32(sp)
    800054b2:	6145                	addi	sp,sp,48
    800054b4:	8082                	ret

00000000800054b6 <sys_write>:
{
    800054b6:	7179                	addi	sp,sp,-48
    800054b8:	f406                	sd	ra,40(sp)
    800054ba:	f022                	sd	s0,32(sp)
    800054bc:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800054be:	fd840593          	addi	a1,s0,-40
    800054c2:	4505                	li	a0,1
    800054c4:	ffffe097          	auipc	ra,0xffffe
    800054c8:	852080e7          	jalr	-1966(ra) # 80002d16 <argaddr>
  argint(2, &n);
    800054cc:	fe440593          	addi	a1,s0,-28
    800054d0:	4509                	li	a0,2
    800054d2:	ffffe097          	auipc	ra,0xffffe
    800054d6:	824080e7          	jalr	-2012(ra) # 80002cf6 <argint>
  if(argfd(0, 0, &f) < 0)
    800054da:	fe840613          	addi	a2,s0,-24
    800054de:	4581                	li	a1,0
    800054e0:	4501                	li	a0,0
    800054e2:	00000097          	auipc	ra,0x0
    800054e6:	d02080e7          	jalr	-766(ra) # 800051e4 <argfd>
    800054ea:	87aa                	mv	a5,a0
    return -1;
    800054ec:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800054ee:	0007cc63          	bltz	a5,80005506 <sys_write+0x50>
  return filewrite(f, p, n);
    800054f2:	fe442603          	lw	a2,-28(s0)
    800054f6:	fd843583          	ld	a1,-40(s0)
    800054fa:	fe843503          	ld	a0,-24(s0)
    800054fe:	fffff097          	auipc	ra,0xfffff
    80005502:	4a8080e7          	jalr	1192(ra) # 800049a6 <filewrite>
}
    80005506:	70a2                	ld	ra,40(sp)
    80005508:	7402                	ld	s0,32(sp)
    8000550a:	6145                	addi	sp,sp,48
    8000550c:	8082                	ret

000000008000550e <sys_close>:
{
    8000550e:	1101                	addi	sp,sp,-32
    80005510:	ec06                	sd	ra,24(sp)
    80005512:	e822                	sd	s0,16(sp)
    80005514:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005516:	fe040613          	addi	a2,s0,-32
    8000551a:	fec40593          	addi	a1,s0,-20
    8000551e:	4501                	li	a0,0
    80005520:	00000097          	auipc	ra,0x0
    80005524:	cc4080e7          	jalr	-828(ra) # 800051e4 <argfd>
    return -1;
    80005528:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000552a:	02054563          	bltz	a0,80005554 <sys_close+0x46>
  myproc()->ofile[fd] = 0;
    8000552e:	ffffc097          	auipc	ra,0xffffc
    80005532:	49c080e7          	jalr	1180(ra) # 800019ca <myproc>
    80005536:	fec42783          	lw	a5,-20(s0)
    8000553a:	02278793          	addi	a5,a5,34
    8000553e:	078e                	slli	a5,a5,0x3
    80005540:	97aa                	add	a5,a5,a0
    80005542:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005546:	fe043503          	ld	a0,-32(s0)
    8000554a:	fffff097          	auipc	ra,0xfffff
    8000554e:	260080e7          	jalr	608(ra) # 800047aa <fileclose>
  return 0;
    80005552:	4781                	li	a5,0
}
    80005554:	853e                	mv	a0,a5
    80005556:	60e2                	ld	ra,24(sp)
    80005558:	6442                	ld	s0,16(sp)
    8000555a:	6105                	addi	sp,sp,32
    8000555c:	8082                	ret

000000008000555e <sys_fstat>:
{
    8000555e:	1101                	addi	sp,sp,-32
    80005560:	ec06                	sd	ra,24(sp)
    80005562:	e822                	sd	s0,16(sp)
    80005564:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005566:	fe040593          	addi	a1,s0,-32
    8000556a:	4505                	li	a0,1
    8000556c:	ffffd097          	auipc	ra,0xffffd
    80005570:	7aa080e7          	jalr	1962(ra) # 80002d16 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005574:	fe840613          	addi	a2,s0,-24
    80005578:	4581                	li	a1,0
    8000557a:	4501                	li	a0,0
    8000557c:	00000097          	auipc	ra,0x0
    80005580:	c68080e7          	jalr	-920(ra) # 800051e4 <argfd>
    80005584:	87aa                	mv	a5,a0
    return -1;
    80005586:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005588:	0007ca63          	bltz	a5,8000559c <sys_fstat+0x3e>
  return filestat(f, st);
    8000558c:	fe043583          	ld	a1,-32(s0)
    80005590:	fe843503          	ld	a0,-24(s0)
    80005594:	fffff097          	auipc	ra,0xfffff
    80005598:	2de080e7          	jalr	734(ra) # 80004872 <filestat>
}
    8000559c:	60e2                	ld	ra,24(sp)
    8000559e:	6442                	ld	s0,16(sp)
    800055a0:	6105                	addi	sp,sp,32
    800055a2:	8082                	ret

00000000800055a4 <sys_link>:
{
    800055a4:	7169                	addi	sp,sp,-304
    800055a6:	f606                	sd	ra,296(sp)
    800055a8:	f222                	sd	s0,288(sp)
    800055aa:	ee26                	sd	s1,280(sp)
    800055ac:	ea4a                	sd	s2,272(sp)
    800055ae:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055b0:	08000613          	li	a2,128
    800055b4:	ed040593          	addi	a1,s0,-304
    800055b8:	4501                	li	a0,0
    800055ba:	ffffd097          	auipc	ra,0xffffd
    800055be:	77c080e7          	jalr	1916(ra) # 80002d36 <argstr>
    return -1;
    800055c2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055c4:	10054e63          	bltz	a0,800056e0 <sys_link+0x13c>
    800055c8:	08000613          	li	a2,128
    800055cc:	f5040593          	addi	a1,s0,-176
    800055d0:	4505                	li	a0,1
    800055d2:	ffffd097          	auipc	ra,0xffffd
    800055d6:	764080e7          	jalr	1892(ra) # 80002d36 <argstr>
    return -1;
    800055da:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055dc:	10054263          	bltz	a0,800056e0 <sys_link+0x13c>
  begin_op();
    800055e0:	fffff097          	auipc	ra,0xfffff
    800055e4:	cfe080e7          	jalr	-770(ra) # 800042de <begin_op>
  if((ip = namei(old)) == 0){
    800055e8:	ed040513          	addi	a0,s0,-304
    800055ec:	fffff097          	auipc	ra,0xfffff
    800055f0:	ad6080e7          	jalr	-1322(ra) # 800040c2 <namei>
    800055f4:	84aa                	mv	s1,a0
    800055f6:	c551                	beqz	a0,80005682 <sys_link+0xde>
  ilock(ip);
    800055f8:	ffffe097          	auipc	ra,0xffffe
    800055fc:	324080e7          	jalr	804(ra) # 8000391c <ilock>
  if(ip->type == T_DIR){
    80005600:	04449703          	lh	a4,68(s1)
    80005604:	4785                	li	a5,1
    80005606:	08f70463          	beq	a4,a5,8000568e <sys_link+0xea>
  ip->nlink++;
    8000560a:	04a4d783          	lhu	a5,74(s1)
    8000560e:	2785                	addiw	a5,a5,1
    80005610:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005614:	8526                	mv	a0,s1
    80005616:	ffffe097          	auipc	ra,0xffffe
    8000561a:	23c080e7          	jalr	572(ra) # 80003852 <iupdate>
  iunlock(ip);
    8000561e:	8526                	mv	a0,s1
    80005620:	ffffe097          	auipc	ra,0xffffe
    80005624:	3be080e7          	jalr	958(ra) # 800039de <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005628:	fd040593          	addi	a1,s0,-48
    8000562c:	f5040513          	addi	a0,s0,-176
    80005630:	fffff097          	auipc	ra,0xfffff
    80005634:	ab0080e7          	jalr	-1360(ra) # 800040e0 <nameiparent>
    80005638:	892a                	mv	s2,a0
    8000563a:	c935                	beqz	a0,800056ae <sys_link+0x10a>
  ilock(dp);
    8000563c:	ffffe097          	auipc	ra,0xffffe
    80005640:	2e0080e7          	jalr	736(ra) # 8000391c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005644:	00092703          	lw	a4,0(s2)
    80005648:	409c                	lw	a5,0(s1)
    8000564a:	04f71d63          	bne	a4,a5,800056a4 <sys_link+0x100>
    8000564e:	40d0                	lw	a2,4(s1)
    80005650:	fd040593          	addi	a1,s0,-48
    80005654:	854a                	mv	a0,s2
    80005656:	fffff097          	auipc	ra,0xfffff
    8000565a:	9ba080e7          	jalr	-1606(ra) # 80004010 <dirlink>
    8000565e:	04054363          	bltz	a0,800056a4 <sys_link+0x100>
  iunlockput(dp);
    80005662:	854a                	mv	a0,s2
    80005664:	ffffe097          	auipc	ra,0xffffe
    80005668:	51a080e7          	jalr	1306(ra) # 80003b7e <iunlockput>
  iput(ip);
    8000566c:	8526                	mv	a0,s1
    8000566e:	ffffe097          	auipc	ra,0xffffe
    80005672:	468080e7          	jalr	1128(ra) # 80003ad6 <iput>
  end_op();
    80005676:	fffff097          	auipc	ra,0xfffff
    8000567a:	ce8080e7          	jalr	-792(ra) # 8000435e <end_op>
  return 0;
    8000567e:	4781                	li	a5,0
    80005680:	a085                	j	800056e0 <sys_link+0x13c>
    end_op();
    80005682:	fffff097          	auipc	ra,0xfffff
    80005686:	cdc080e7          	jalr	-804(ra) # 8000435e <end_op>
    return -1;
    8000568a:	57fd                	li	a5,-1
    8000568c:	a891                	j	800056e0 <sys_link+0x13c>
    iunlockput(ip);
    8000568e:	8526                	mv	a0,s1
    80005690:	ffffe097          	auipc	ra,0xffffe
    80005694:	4ee080e7          	jalr	1262(ra) # 80003b7e <iunlockput>
    end_op();
    80005698:	fffff097          	auipc	ra,0xfffff
    8000569c:	cc6080e7          	jalr	-826(ra) # 8000435e <end_op>
    return -1;
    800056a0:	57fd                	li	a5,-1
    800056a2:	a83d                	j	800056e0 <sys_link+0x13c>
    iunlockput(dp);
    800056a4:	854a                	mv	a0,s2
    800056a6:	ffffe097          	auipc	ra,0xffffe
    800056aa:	4d8080e7          	jalr	1240(ra) # 80003b7e <iunlockput>
  ilock(ip);
    800056ae:	8526                	mv	a0,s1
    800056b0:	ffffe097          	auipc	ra,0xffffe
    800056b4:	26c080e7          	jalr	620(ra) # 8000391c <ilock>
  ip->nlink--;
    800056b8:	04a4d783          	lhu	a5,74(s1)
    800056bc:	37fd                	addiw	a5,a5,-1
    800056be:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800056c2:	8526                	mv	a0,s1
    800056c4:	ffffe097          	auipc	ra,0xffffe
    800056c8:	18e080e7          	jalr	398(ra) # 80003852 <iupdate>
  iunlockput(ip);
    800056cc:	8526                	mv	a0,s1
    800056ce:	ffffe097          	auipc	ra,0xffffe
    800056d2:	4b0080e7          	jalr	1200(ra) # 80003b7e <iunlockput>
  end_op();
    800056d6:	fffff097          	auipc	ra,0xfffff
    800056da:	c88080e7          	jalr	-888(ra) # 8000435e <end_op>
  return -1;
    800056de:	57fd                	li	a5,-1
}
    800056e0:	853e                	mv	a0,a5
    800056e2:	70b2                	ld	ra,296(sp)
    800056e4:	7412                	ld	s0,288(sp)
    800056e6:	64f2                	ld	s1,280(sp)
    800056e8:	6952                	ld	s2,272(sp)
    800056ea:	6155                	addi	sp,sp,304
    800056ec:	8082                	ret

00000000800056ee <sys_unlink>:
{
    800056ee:	7151                	addi	sp,sp,-240
    800056f0:	f586                	sd	ra,232(sp)
    800056f2:	f1a2                	sd	s0,224(sp)
    800056f4:	eda6                	sd	s1,216(sp)
    800056f6:	e9ca                	sd	s2,208(sp)
    800056f8:	e5ce                	sd	s3,200(sp)
    800056fa:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800056fc:	08000613          	li	a2,128
    80005700:	f3040593          	addi	a1,s0,-208
    80005704:	4501                	li	a0,0
    80005706:	ffffd097          	auipc	ra,0xffffd
    8000570a:	630080e7          	jalr	1584(ra) # 80002d36 <argstr>
    8000570e:	18054163          	bltz	a0,80005890 <sys_unlink+0x1a2>
  begin_op();
    80005712:	fffff097          	auipc	ra,0xfffff
    80005716:	bcc080e7          	jalr	-1076(ra) # 800042de <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000571a:	fb040593          	addi	a1,s0,-80
    8000571e:	f3040513          	addi	a0,s0,-208
    80005722:	fffff097          	auipc	ra,0xfffff
    80005726:	9be080e7          	jalr	-1602(ra) # 800040e0 <nameiparent>
    8000572a:	84aa                	mv	s1,a0
    8000572c:	c979                	beqz	a0,80005802 <sys_unlink+0x114>
  ilock(dp);
    8000572e:	ffffe097          	auipc	ra,0xffffe
    80005732:	1ee080e7          	jalr	494(ra) # 8000391c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005736:	00003597          	auipc	a1,0x3
    8000573a:	fda58593          	addi	a1,a1,-38 # 80008710 <syscalls+0x2b8>
    8000573e:	fb040513          	addi	a0,s0,-80
    80005742:	ffffe097          	auipc	ra,0xffffe
    80005746:	6a4080e7          	jalr	1700(ra) # 80003de6 <namecmp>
    8000574a:	14050a63          	beqz	a0,8000589e <sys_unlink+0x1b0>
    8000574e:	00003597          	auipc	a1,0x3
    80005752:	fca58593          	addi	a1,a1,-54 # 80008718 <syscalls+0x2c0>
    80005756:	fb040513          	addi	a0,s0,-80
    8000575a:	ffffe097          	auipc	ra,0xffffe
    8000575e:	68c080e7          	jalr	1676(ra) # 80003de6 <namecmp>
    80005762:	12050e63          	beqz	a0,8000589e <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005766:	f2c40613          	addi	a2,s0,-212
    8000576a:	fb040593          	addi	a1,s0,-80
    8000576e:	8526                	mv	a0,s1
    80005770:	ffffe097          	auipc	ra,0xffffe
    80005774:	690080e7          	jalr	1680(ra) # 80003e00 <dirlookup>
    80005778:	892a                	mv	s2,a0
    8000577a:	12050263          	beqz	a0,8000589e <sys_unlink+0x1b0>
  ilock(ip);
    8000577e:	ffffe097          	auipc	ra,0xffffe
    80005782:	19e080e7          	jalr	414(ra) # 8000391c <ilock>
  if(ip->nlink < 1)
    80005786:	04a91783          	lh	a5,74(s2)
    8000578a:	08f05263          	blez	a5,8000580e <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000578e:	04491703          	lh	a4,68(s2)
    80005792:	4785                	li	a5,1
    80005794:	08f70563          	beq	a4,a5,8000581e <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005798:	4641                	li	a2,16
    8000579a:	4581                	li	a1,0
    8000579c:	fc040513          	addi	a0,s0,-64
    800057a0:	ffffb097          	auipc	ra,0xffffb
    800057a4:	532080e7          	jalr	1330(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057a8:	4741                	li	a4,16
    800057aa:	f2c42683          	lw	a3,-212(s0)
    800057ae:	fc040613          	addi	a2,s0,-64
    800057b2:	4581                	li	a1,0
    800057b4:	8526                	mv	a0,s1
    800057b6:	ffffe097          	auipc	ra,0xffffe
    800057ba:	512080e7          	jalr	1298(ra) # 80003cc8 <writei>
    800057be:	47c1                	li	a5,16
    800057c0:	0af51563          	bne	a0,a5,8000586a <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800057c4:	04491703          	lh	a4,68(s2)
    800057c8:	4785                	li	a5,1
    800057ca:	0af70863          	beq	a4,a5,8000587a <sys_unlink+0x18c>
  iunlockput(dp);
    800057ce:	8526                	mv	a0,s1
    800057d0:	ffffe097          	auipc	ra,0xffffe
    800057d4:	3ae080e7          	jalr	942(ra) # 80003b7e <iunlockput>
  ip->nlink--;
    800057d8:	04a95783          	lhu	a5,74(s2)
    800057dc:	37fd                	addiw	a5,a5,-1
    800057de:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800057e2:	854a                	mv	a0,s2
    800057e4:	ffffe097          	auipc	ra,0xffffe
    800057e8:	06e080e7          	jalr	110(ra) # 80003852 <iupdate>
  iunlockput(ip);
    800057ec:	854a                	mv	a0,s2
    800057ee:	ffffe097          	auipc	ra,0xffffe
    800057f2:	390080e7          	jalr	912(ra) # 80003b7e <iunlockput>
  end_op();
    800057f6:	fffff097          	auipc	ra,0xfffff
    800057fa:	b68080e7          	jalr	-1176(ra) # 8000435e <end_op>
  return 0;
    800057fe:	4501                	li	a0,0
    80005800:	a84d                	j	800058b2 <sys_unlink+0x1c4>
    end_op();
    80005802:	fffff097          	auipc	ra,0xfffff
    80005806:	b5c080e7          	jalr	-1188(ra) # 8000435e <end_op>
    return -1;
    8000580a:	557d                	li	a0,-1
    8000580c:	a05d                	j	800058b2 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000580e:	00003517          	auipc	a0,0x3
    80005812:	f1250513          	addi	a0,a0,-238 # 80008720 <syscalls+0x2c8>
    80005816:	ffffb097          	auipc	ra,0xffffb
    8000581a:	d28080e7          	jalr	-728(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000581e:	04c92703          	lw	a4,76(s2)
    80005822:	02000793          	li	a5,32
    80005826:	f6e7f9e3          	bgeu	a5,a4,80005798 <sys_unlink+0xaa>
    8000582a:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000582e:	4741                	li	a4,16
    80005830:	86ce                	mv	a3,s3
    80005832:	f1840613          	addi	a2,s0,-232
    80005836:	4581                	li	a1,0
    80005838:	854a                	mv	a0,s2
    8000583a:	ffffe097          	auipc	ra,0xffffe
    8000583e:	396080e7          	jalr	918(ra) # 80003bd0 <readi>
    80005842:	47c1                	li	a5,16
    80005844:	00f51b63          	bne	a0,a5,8000585a <sys_unlink+0x16c>
    if(de.inum != 0)
    80005848:	f1845783          	lhu	a5,-232(s0)
    8000584c:	e7a1                	bnez	a5,80005894 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000584e:	29c1                	addiw	s3,s3,16
    80005850:	04c92783          	lw	a5,76(s2)
    80005854:	fcf9ede3          	bltu	s3,a5,8000582e <sys_unlink+0x140>
    80005858:	b781                	j	80005798 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    8000585a:	00003517          	auipc	a0,0x3
    8000585e:	ede50513          	addi	a0,a0,-290 # 80008738 <syscalls+0x2e0>
    80005862:	ffffb097          	auipc	ra,0xffffb
    80005866:	cdc080e7          	jalr	-804(ra) # 8000053e <panic>
    panic("unlink: writei");
    8000586a:	00003517          	auipc	a0,0x3
    8000586e:	ee650513          	addi	a0,a0,-282 # 80008750 <syscalls+0x2f8>
    80005872:	ffffb097          	auipc	ra,0xffffb
    80005876:	ccc080e7          	jalr	-820(ra) # 8000053e <panic>
    dp->nlink--;
    8000587a:	04a4d783          	lhu	a5,74(s1)
    8000587e:	37fd                	addiw	a5,a5,-1
    80005880:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005884:	8526                	mv	a0,s1
    80005886:	ffffe097          	auipc	ra,0xffffe
    8000588a:	fcc080e7          	jalr	-52(ra) # 80003852 <iupdate>
    8000588e:	b781                	j	800057ce <sys_unlink+0xe0>
    return -1;
    80005890:	557d                	li	a0,-1
    80005892:	a005                	j	800058b2 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005894:	854a                	mv	a0,s2
    80005896:	ffffe097          	auipc	ra,0xffffe
    8000589a:	2e8080e7          	jalr	744(ra) # 80003b7e <iunlockput>
  iunlockput(dp);
    8000589e:	8526                	mv	a0,s1
    800058a0:	ffffe097          	auipc	ra,0xffffe
    800058a4:	2de080e7          	jalr	734(ra) # 80003b7e <iunlockput>
  end_op();
    800058a8:	fffff097          	auipc	ra,0xfffff
    800058ac:	ab6080e7          	jalr	-1354(ra) # 8000435e <end_op>
  return -1;
    800058b0:	557d                	li	a0,-1
}
    800058b2:	70ae                	ld	ra,232(sp)
    800058b4:	740e                	ld	s0,224(sp)
    800058b6:	64ee                	ld	s1,216(sp)
    800058b8:	694e                	ld	s2,208(sp)
    800058ba:	69ae                	ld	s3,200(sp)
    800058bc:	616d                	addi	sp,sp,240
    800058be:	8082                	ret

00000000800058c0 <sys_open>:

uint64
sys_open(void)
{
    800058c0:	7131                	addi	sp,sp,-192
    800058c2:	fd06                	sd	ra,184(sp)
    800058c4:	f922                	sd	s0,176(sp)
    800058c6:	f526                	sd	s1,168(sp)
    800058c8:	f14a                	sd	s2,160(sp)
    800058ca:	ed4e                	sd	s3,152(sp)
    800058cc:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800058ce:	f4c40593          	addi	a1,s0,-180
    800058d2:	4505                	li	a0,1
    800058d4:	ffffd097          	auipc	ra,0xffffd
    800058d8:	422080e7          	jalr	1058(ra) # 80002cf6 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800058dc:	08000613          	li	a2,128
    800058e0:	f5040593          	addi	a1,s0,-176
    800058e4:	4501                	li	a0,0
    800058e6:	ffffd097          	auipc	ra,0xffffd
    800058ea:	450080e7          	jalr	1104(ra) # 80002d36 <argstr>
    800058ee:	87aa                	mv	a5,a0
    return -1;
    800058f0:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800058f2:	0a07c963          	bltz	a5,800059a4 <sys_open+0xe4>

  begin_op();
    800058f6:	fffff097          	auipc	ra,0xfffff
    800058fa:	9e8080e7          	jalr	-1560(ra) # 800042de <begin_op>

  if(omode & O_CREATE){
    800058fe:	f4c42783          	lw	a5,-180(s0)
    80005902:	2007f793          	andi	a5,a5,512
    80005906:	cfc5                	beqz	a5,800059be <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005908:	4681                	li	a3,0
    8000590a:	4601                	li	a2,0
    8000590c:	4589                	li	a1,2
    8000590e:	f5040513          	addi	a0,s0,-176
    80005912:	00000097          	auipc	ra,0x0
    80005916:	974080e7          	jalr	-1676(ra) # 80005286 <create>
    8000591a:	84aa                	mv	s1,a0
    if(ip == 0){
    8000591c:	c959                	beqz	a0,800059b2 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000591e:	04449703          	lh	a4,68(s1)
    80005922:	478d                	li	a5,3
    80005924:	00f71763          	bne	a4,a5,80005932 <sys_open+0x72>
    80005928:	0464d703          	lhu	a4,70(s1)
    8000592c:	47a5                	li	a5,9
    8000592e:	0ce7ed63          	bltu	a5,a4,80005a08 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005932:	fffff097          	auipc	ra,0xfffff
    80005936:	dbc080e7          	jalr	-580(ra) # 800046ee <filealloc>
    8000593a:	89aa                	mv	s3,a0
    8000593c:	10050363          	beqz	a0,80005a42 <sys_open+0x182>
    80005940:	00000097          	auipc	ra,0x0
    80005944:	904080e7          	jalr	-1788(ra) # 80005244 <fdalloc>
    80005948:	892a                	mv	s2,a0
    8000594a:	0e054763          	bltz	a0,80005a38 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000594e:	04449703          	lh	a4,68(s1)
    80005952:	478d                	li	a5,3
    80005954:	0cf70563          	beq	a4,a5,80005a1e <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005958:	4789                	li	a5,2
    8000595a:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000595e:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005962:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005966:	f4c42783          	lw	a5,-180(s0)
    8000596a:	0017c713          	xori	a4,a5,1
    8000596e:	8b05                	andi	a4,a4,1
    80005970:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005974:	0037f713          	andi	a4,a5,3
    80005978:	00e03733          	snez	a4,a4
    8000597c:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005980:	4007f793          	andi	a5,a5,1024
    80005984:	c791                	beqz	a5,80005990 <sys_open+0xd0>
    80005986:	04449703          	lh	a4,68(s1)
    8000598a:	4789                	li	a5,2
    8000598c:	0af70063          	beq	a4,a5,80005a2c <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005990:	8526                	mv	a0,s1
    80005992:	ffffe097          	auipc	ra,0xffffe
    80005996:	04c080e7          	jalr	76(ra) # 800039de <iunlock>
  end_op();
    8000599a:	fffff097          	auipc	ra,0xfffff
    8000599e:	9c4080e7          	jalr	-1596(ra) # 8000435e <end_op>

  return fd;
    800059a2:	854a                	mv	a0,s2
}
    800059a4:	70ea                	ld	ra,184(sp)
    800059a6:	744a                	ld	s0,176(sp)
    800059a8:	74aa                	ld	s1,168(sp)
    800059aa:	790a                	ld	s2,160(sp)
    800059ac:	69ea                	ld	s3,152(sp)
    800059ae:	6129                	addi	sp,sp,192
    800059b0:	8082                	ret
      end_op();
    800059b2:	fffff097          	auipc	ra,0xfffff
    800059b6:	9ac080e7          	jalr	-1620(ra) # 8000435e <end_op>
      return -1;
    800059ba:	557d                	li	a0,-1
    800059bc:	b7e5                	j	800059a4 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800059be:	f5040513          	addi	a0,s0,-176
    800059c2:	ffffe097          	auipc	ra,0xffffe
    800059c6:	700080e7          	jalr	1792(ra) # 800040c2 <namei>
    800059ca:	84aa                	mv	s1,a0
    800059cc:	c905                	beqz	a0,800059fc <sys_open+0x13c>
    ilock(ip);
    800059ce:	ffffe097          	auipc	ra,0xffffe
    800059d2:	f4e080e7          	jalr	-178(ra) # 8000391c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800059d6:	04449703          	lh	a4,68(s1)
    800059da:	4785                	li	a5,1
    800059dc:	f4f711e3          	bne	a4,a5,8000591e <sys_open+0x5e>
    800059e0:	f4c42783          	lw	a5,-180(s0)
    800059e4:	d7b9                	beqz	a5,80005932 <sys_open+0x72>
      iunlockput(ip);
    800059e6:	8526                	mv	a0,s1
    800059e8:	ffffe097          	auipc	ra,0xffffe
    800059ec:	196080e7          	jalr	406(ra) # 80003b7e <iunlockput>
      end_op();
    800059f0:	fffff097          	auipc	ra,0xfffff
    800059f4:	96e080e7          	jalr	-1682(ra) # 8000435e <end_op>
      return -1;
    800059f8:	557d                	li	a0,-1
    800059fa:	b76d                	j	800059a4 <sys_open+0xe4>
      end_op();
    800059fc:	fffff097          	auipc	ra,0xfffff
    80005a00:	962080e7          	jalr	-1694(ra) # 8000435e <end_op>
      return -1;
    80005a04:	557d                	li	a0,-1
    80005a06:	bf79                	j	800059a4 <sys_open+0xe4>
    iunlockput(ip);
    80005a08:	8526                	mv	a0,s1
    80005a0a:	ffffe097          	auipc	ra,0xffffe
    80005a0e:	174080e7          	jalr	372(ra) # 80003b7e <iunlockput>
    end_op();
    80005a12:	fffff097          	auipc	ra,0xfffff
    80005a16:	94c080e7          	jalr	-1716(ra) # 8000435e <end_op>
    return -1;
    80005a1a:	557d                	li	a0,-1
    80005a1c:	b761                	j	800059a4 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005a1e:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005a22:	04649783          	lh	a5,70(s1)
    80005a26:	02f99223          	sh	a5,36(s3)
    80005a2a:	bf25                	j	80005962 <sys_open+0xa2>
    itrunc(ip);
    80005a2c:	8526                	mv	a0,s1
    80005a2e:	ffffe097          	auipc	ra,0xffffe
    80005a32:	ffc080e7          	jalr	-4(ra) # 80003a2a <itrunc>
    80005a36:	bfa9                	j	80005990 <sys_open+0xd0>
      fileclose(f);
    80005a38:	854e                	mv	a0,s3
    80005a3a:	fffff097          	auipc	ra,0xfffff
    80005a3e:	d70080e7          	jalr	-656(ra) # 800047aa <fileclose>
    iunlockput(ip);
    80005a42:	8526                	mv	a0,s1
    80005a44:	ffffe097          	auipc	ra,0xffffe
    80005a48:	13a080e7          	jalr	314(ra) # 80003b7e <iunlockput>
    end_op();
    80005a4c:	fffff097          	auipc	ra,0xfffff
    80005a50:	912080e7          	jalr	-1774(ra) # 8000435e <end_op>
    return -1;
    80005a54:	557d                	li	a0,-1
    80005a56:	b7b9                	j	800059a4 <sys_open+0xe4>

0000000080005a58 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a58:	7175                	addi	sp,sp,-144
    80005a5a:	e506                	sd	ra,136(sp)
    80005a5c:	e122                	sd	s0,128(sp)
    80005a5e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005a60:	fffff097          	auipc	ra,0xfffff
    80005a64:	87e080e7          	jalr	-1922(ra) # 800042de <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005a68:	08000613          	li	a2,128
    80005a6c:	f7040593          	addi	a1,s0,-144
    80005a70:	4501                	li	a0,0
    80005a72:	ffffd097          	auipc	ra,0xffffd
    80005a76:	2c4080e7          	jalr	708(ra) # 80002d36 <argstr>
    80005a7a:	02054963          	bltz	a0,80005aac <sys_mkdir+0x54>
    80005a7e:	4681                	li	a3,0
    80005a80:	4601                	li	a2,0
    80005a82:	4585                	li	a1,1
    80005a84:	f7040513          	addi	a0,s0,-144
    80005a88:	fffff097          	auipc	ra,0xfffff
    80005a8c:	7fe080e7          	jalr	2046(ra) # 80005286 <create>
    80005a90:	cd11                	beqz	a0,80005aac <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a92:	ffffe097          	auipc	ra,0xffffe
    80005a96:	0ec080e7          	jalr	236(ra) # 80003b7e <iunlockput>
  end_op();
    80005a9a:	fffff097          	auipc	ra,0xfffff
    80005a9e:	8c4080e7          	jalr	-1852(ra) # 8000435e <end_op>
  return 0;
    80005aa2:	4501                	li	a0,0
}
    80005aa4:	60aa                	ld	ra,136(sp)
    80005aa6:	640a                	ld	s0,128(sp)
    80005aa8:	6149                	addi	sp,sp,144
    80005aaa:	8082                	ret
    end_op();
    80005aac:	fffff097          	auipc	ra,0xfffff
    80005ab0:	8b2080e7          	jalr	-1870(ra) # 8000435e <end_op>
    return -1;
    80005ab4:	557d                	li	a0,-1
    80005ab6:	b7fd                	j	80005aa4 <sys_mkdir+0x4c>

0000000080005ab8 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005ab8:	7135                	addi	sp,sp,-160
    80005aba:	ed06                	sd	ra,152(sp)
    80005abc:	e922                	sd	s0,144(sp)
    80005abe:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005ac0:	fffff097          	auipc	ra,0xfffff
    80005ac4:	81e080e7          	jalr	-2018(ra) # 800042de <begin_op>
  argint(1, &major);
    80005ac8:	f6c40593          	addi	a1,s0,-148
    80005acc:	4505                	li	a0,1
    80005ace:	ffffd097          	auipc	ra,0xffffd
    80005ad2:	228080e7          	jalr	552(ra) # 80002cf6 <argint>
  argint(2, &minor);
    80005ad6:	f6840593          	addi	a1,s0,-152
    80005ada:	4509                	li	a0,2
    80005adc:	ffffd097          	auipc	ra,0xffffd
    80005ae0:	21a080e7          	jalr	538(ra) # 80002cf6 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005ae4:	08000613          	li	a2,128
    80005ae8:	f7040593          	addi	a1,s0,-144
    80005aec:	4501                	li	a0,0
    80005aee:	ffffd097          	auipc	ra,0xffffd
    80005af2:	248080e7          	jalr	584(ra) # 80002d36 <argstr>
    80005af6:	02054b63          	bltz	a0,80005b2c <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005afa:	f6841683          	lh	a3,-152(s0)
    80005afe:	f6c41603          	lh	a2,-148(s0)
    80005b02:	458d                	li	a1,3
    80005b04:	f7040513          	addi	a0,s0,-144
    80005b08:	fffff097          	auipc	ra,0xfffff
    80005b0c:	77e080e7          	jalr	1918(ra) # 80005286 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b10:	cd11                	beqz	a0,80005b2c <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b12:	ffffe097          	auipc	ra,0xffffe
    80005b16:	06c080e7          	jalr	108(ra) # 80003b7e <iunlockput>
  end_op();
    80005b1a:	fffff097          	auipc	ra,0xfffff
    80005b1e:	844080e7          	jalr	-1980(ra) # 8000435e <end_op>
  return 0;
    80005b22:	4501                	li	a0,0
}
    80005b24:	60ea                	ld	ra,152(sp)
    80005b26:	644a                	ld	s0,144(sp)
    80005b28:	610d                	addi	sp,sp,160
    80005b2a:	8082                	ret
    end_op();
    80005b2c:	fffff097          	auipc	ra,0xfffff
    80005b30:	832080e7          	jalr	-1998(ra) # 8000435e <end_op>
    return -1;
    80005b34:	557d                	li	a0,-1
    80005b36:	b7fd                	j	80005b24 <sys_mknod+0x6c>

0000000080005b38 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b38:	7135                	addi	sp,sp,-160
    80005b3a:	ed06                	sd	ra,152(sp)
    80005b3c:	e922                	sd	s0,144(sp)
    80005b3e:	e526                	sd	s1,136(sp)
    80005b40:	e14a                	sd	s2,128(sp)
    80005b42:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005b44:	ffffc097          	auipc	ra,0xffffc
    80005b48:	e86080e7          	jalr	-378(ra) # 800019ca <myproc>
    80005b4c:	892a                	mv	s2,a0
  
  begin_op();
    80005b4e:	ffffe097          	auipc	ra,0xffffe
    80005b52:	790080e7          	jalr	1936(ra) # 800042de <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b56:	08000613          	li	a2,128
    80005b5a:	f6040593          	addi	a1,s0,-160
    80005b5e:	4501                	li	a0,0
    80005b60:	ffffd097          	auipc	ra,0xffffd
    80005b64:	1d6080e7          	jalr	470(ra) # 80002d36 <argstr>
    80005b68:	04054b63          	bltz	a0,80005bbe <sys_chdir+0x86>
    80005b6c:	f6040513          	addi	a0,s0,-160
    80005b70:	ffffe097          	auipc	ra,0xffffe
    80005b74:	552080e7          	jalr	1362(ra) # 800040c2 <namei>
    80005b78:	84aa                	mv	s1,a0
    80005b7a:	c131                	beqz	a0,80005bbe <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005b7c:	ffffe097          	auipc	ra,0xffffe
    80005b80:	da0080e7          	jalr	-608(ra) # 8000391c <ilock>
  if(ip->type != T_DIR){
    80005b84:	04449703          	lh	a4,68(s1)
    80005b88:	4785                	li	a5,1
    80005b8a:	04f71063          	bne	a4,a5,80005bca <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005b8e:	8526                	mv	a0,s1
    80005b90:	ffffe097          	auipc	ra,0xffffe
    80005b94:	e4e080e7          	jalr	-434(ra) # 800039de <iunlock>
  iput(p->cwd);
    80005b98:	19093503          	ld	a0,400(s2)
    80005b9c:	ffffe097          	auipc	ra,0xffffe
    80005ba0:	f3a080e7          	jalr	-198(ra) # 80003ad6 <iput>
  end_op();
    80005ba4:	ffffe097          	auipc	ra,0xffffe
    80005ba8:	7ba080e7          	jalr	1978(ra) # 8000435e <end_op>
  p->cwd = ip;
    80005bac:	18993823          	sd	s1,400(s2)
  return 0;
    80005bb0:	4501                	li	a0,0
}
    80005bb2:	60ea                	ld	ra,152(sp)
    80005bb4:	644a                	ld	s0,144(sp)
    80005bb6:	64aa                	ld	s1,136(sp)
    80005bb8:	690a                	ld	s2,128(sp)
    80005bba:	610d                	addi	sp,sp,160
    80005bbc:	8082                	ret
    end_op();
    80005bbe:	ffffe097          	auipc	ra,0xffffe
    80005bc2:	7a0080e7          	jalr	1952(ra) # 8000435e <end_op>
    return -1;
    80005bc6:	557d                	li	a0,-1
    80005bc8:	b7ed                	j	80005bb2 <sys_chdir+0x7a>
    iunlockput(ip);
    80005bca:	8526                	mv	a0,s1
    80005bcc:	ffffe097          	auipc	ra,0xffffe
    80005bd0:	fb2080e7          	jalr	-78(ra) # 80003b7e <iunlockput>
    end_op();
    80005bd4:	ffffe097          	auipc	ra,0xffffe
    80005bd8:	78a080e7          	jalr	1930(ra) # 8000435e <end_op>
    return -1;
    80005bdc:	557d                	li	a0,-1
    80005bde:	bfd1                	j	80005bb2 <sys_chdir+0x7a>

0000000080005be0 <sys_exec>:

uint64
sys_exec(void)
{
    80005be0:	7145                	addi	sp,sp,-464
    80005be2:	e786                	sd	ra,456(sp)
    80005be4:	e3a2                	sd	s0,448(sp)
    80005be6:	ff26                	sd	s1,440(sp)
    80005be8:	fb4a                	sd	s2,432(sp)
    80005bea:	f74e                	sd	s3,424(sp)
    80005bec:	f352                	sd	s4,416(sp)
    80005bee:	ef56                	sd	s5,408(sp)
    80005bf0:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005bf2:	e3840593          	addi	a1,s0,-456
    80005bf6:	4505                	li	a0,1
    80005bf8:	ffffd097          	auipc	ra,0xffffd
    80005bfc:	11e080e7          	jalr	286(ra) # 80002d16 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005c00:	08000613          	li	a2,128
    80005c04:	f4040593          	addi	a1,s0,-192
    80005c08:	4501                	li	a0,0
    80005c0a:	ffffd097          	auipc	ra,0xffffd
    80005c0e:	12c080e7          	jalr	300(ra) # 80002d36 <argstr>
    80005c12:	87aa                	mv	a5,a0
    return -1;
    80005c14:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005c16:	0c07c263          	bltz	a5,80005cda <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005c1a:	10000613          	li	a2,256
    80005c1e:	4581                	li	a1,0
    80005c20:	e4040513          	addi	a0,s0,-448
    80005c24:	ffffb097          	auipc	ra,0xffffb
    80005c28:	0ae080e7          	jalr	174(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005c2c:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005c30:	89a6                	mv	s3,s1
    80005c32:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005c34:	02000a13          	li	s4,32
    80005c38:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005c3c:	00391793          	slli	a5,s2,0x3
    80005c40:	e3040593          	addi	a1,s0,-464
    80005c44:	e3843503          	ld	a0,-456(s0)
    80005c48:	953e                	add	a0,a0,a5
    80005c4a:	ffffd097          	auipc	ra,0xffffd
    80005c4e:	00e080e7          	jalr	14(ra) # 80002c58 <fetchaddr>
    80005c52:	02054a63          	bltz	a0,80005c86 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005c56:	e3043783          	ld	a5,-464(s0)
    80005c5a:	c3b9                	beqz	a5,80005ca0 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005c5c:	ffffb097          	auipc	ra,0xffffb
    80005c60:	e8a080e7          	jalr	-374(ra) # 80000ae6 <kalloc>
    80005c64:	85aa                	mv	a1,a0
    80005c66:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005c6a:	cd11                	beqz	a0,80005c86 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005c6c:	6605                	lui	a2,0x1
    80005c6e:	e3043503          	ld	a0,-464(s0)
    80005c72:	ffffd097          	auipc	ra,0xffffd
    80005c76:	038080e7          	jalr	56(ra) # 80002caa <fetchstr>
    80005c7a:	00054663          	bltz	a0,80005c86 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005c7e:	0905                	addi	s2,s2,1
    80005c80:	09a1                	addi	s3,s3,8
    80005c82:	fb491be3          	bne	s2,s4,80005c38 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c86:	10048913          	addi	s2,s1,256
    80005c8a:	6088                	ld	a0,0(s1)
    80005c8c:	c531                	beqz	a0,80005cd8 <sys_exec+0xf8>
    kfree(argv[i]);
    80005c8e:	ffffb097          	auipc	ra,0xffffb
    80005c92:	d5c080e7          	jalr	-676(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c96:	04a1                	addi	s1,s1,8
    80005c98:	ff2499e3          	bne	s1,s2,80005c8a <sys_exec+0xaa>
  return -1;
    80005c9c:	557d                	li	a0,-1
    80005c9e:	a835                	j	80005cda <sys_exec+0xfa>
      argv[i] = 0;
    80005ca0:	0a8e                	slli	s5,s5,0x3
    80005ca2:	fc040793          	addi	a5,s0,-64
    80005ca6:	9abe                	add	s5,s5,a5
    80005ca8:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005cac:	e4040593          	addi	a1,s0,-448
    80005cb0:	f4040513          	addi	a0,s0,-192
    80005cb4:	fffff097          	auipc	ra,0xfffff
    80005cb8:	170080e7          	jalr	368(ra) # 80004e24 <exec>
    80005cbc:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cbe:	10048993          	addi	s3,s1,256
    80005cc2:	6088                	ld	a0,0(s1)
    80005cc4:	c901                	beqz	a0,80005cd4 <sys_exec+0xf4>
    kfree(argv[i]);
    80005cc6:	ffffb097          	auipc	ra,0xffffb
    80005cca:	d24080e7          	jalr	-732(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cce:	04a1                	addi	s1,s1,8
    80005cd0:	ff3499e3          	bne	s1,s3,80005cc2 <sys_exec+0xe2>
  return ret;
    80005cd4:	854a                	mv	a0,s2
    80005cd6:	a011                	j	80005cda <sys_exec+0xfa>
  return -1;
    80005cd8:	557d                	li	a0,-1
}
    80005cda:	60be                	ld	ra,456(sp)
    80005cdc:	641e                	ld	s0,448(sp)
    80005cde:	74fa                	ld	s1,440(sp)
    80005ce0:	795a                	ld	s2,432(sp)
    80005ce2:	79ba                	ld	s3,424(sp)
    80005ce4:	7a1a                	ld	s4,416(sp)
    80005ce6:	6afa                	ld	s5,408(sp)
    80005ce8:	6179                	addi	sp,sp,464
    80005cea:	8082                	ret

0000000080005cec <sys_pipe>:

uint64
sys_pipe(void)
{
    80005cec:	7139                	addi	sp,sp,-64
    80005cee:	fc06                	sd	ra,56(sp)
    80005cf0:	f822                	sd	s0,48(sp)
    80005cf2:	f426                	sd	s1,40(sp)
    80005cf4:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005cf6:	ffffc097          	auipc	ra,0xffffc
    80005cfa:	cd4080e7          	jalr	-812(ra) # 800019ca <myproc>
    80005cfe:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005d00:	fd840593          	addi	a1,s0,-40
    80005d04:	4501                	li	a0,0
    80005d06:	ffffd097          	auipc	ra,0xffffd
    80005d0a:	010080e7          	jalr	16(ra) # 80002d16 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005d0e:	fc840593          	addi	a1,s0,-56
    80005d12:	fd040513          	addi	a0,s0,-48
    80005d16:	fffff097          	auipc	ra,0xfffff
    80005d1a:	dc4080e7          	jalr	-572(ra) # 80004ada <pipealloc>
    return -1;
    80005d1e:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d20:	0c054763          	bltz	a0,80005dee <sys_pipe+0x102>
  fd0 = -1;
    80005d24:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005d28:	fd043503          	ld	a0,-48(s0)
    80005d2c:	fffff097          	auipc	ra,0xfffff
    80005d30:	518080e7          	jalr	1304(ra) # 80005244 <fdalloc>
    80005d34:	fca42223          	sw	a0,-60(s0)
    80005d38:	08054e63          	bltz	a0,80005dd4 <sys_pipe+0xe8>
    80005d3c:	fc843503          	ld	a0,-56(s0)
    80005d40:	fffff097          	auipc	ra,0xfffff
    80005d44:	504080e7          	jalr	1284(ra) # 80005244 <fdalloc>
    80005d48:	fca42023          	sw	a0,-64(s0)
    80005d4c:	06054a63          	bltz	a0,80005dc0 <sys_pipe+0xd4>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d50:	4691                	li	a3,4
    80005d52:	fc440613          	addi	a2,s0,-60
    80005d56:	fd843583          	ld	a1,-40(s0)
    80005d5a:	68c8                	ld	a0,144(s1)
    80005d5c:	ffffc097          	auipc	ra,0xffffc
    80005d60:	90c080e7          	jalr	-1780(ra) # 80001668 <copyout>
    80005d64:	02054063          	bltz	a0,80005d84 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005d68:	4691                	li	a3,4
    80005d6a:	fc040613          	addi	a2,s0,-64
    80005d6e:	fd843583          	ld	a1,-40(s0)
    80005d72:	0591                	addi	a1,a1,4
    80005d74:	68c8                	ld	a0,144(s1)
    80005d76:	ffffc097          	auipc	ra,0xffffc
    80005d7a:	8f2080e7          	jalr	-1806(ra) # 80001668 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005d7e:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d80:	06055763          	bgez	a0,80005dee <sys_pipe+0x102>
    p->ofile[fd0] = 0;
    80005d84:	fc442783          	lw	a5,-60(s0)
    80005d88:	02278793          	addi	a5,a5,34
    80005d8c:	078e                	slli	a5,a5,0x3
    80005d8e:	97a6                	add	a5,a5,s1
    80005d90:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005d94:	fc042503          	lw	a0,-64(s0)
    80005d98:	02250513          	addi	a0,a0,34
    80005d9c:	050e                	slli	a0,a0,0x3
    80005d9e:	94aa                	add	s1,s1,a0
    80005da0:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005da4:	fd043503          	ld	a0,-48(s0)
    80005da8:	fffff097          	auipc	ra,0xfffff
    80005dac:	a02080e7          	jalr	-1534(ra) # 800047aa <fileclose>
    fileclose(wf);
    80005db0:	fc843503          	ld	a0,-56(s0)
    80005db4:	fffff097          	auipc	ra,0xfffff
    80005db8:	9f6080e7          	jalr	-1546(ra) # 800047aa <fileclose>
    return -1;
    80005dbc:	57fd                	li	a5,-1
    80005dbe:	a805                	j	80005dee <sys_pipe+0x102>
    if(fd0 >= 0)
    80005dc0:	fc442783          	lw	a5,-60(s0)
    80005dc4:	0007c863          	bltz	a5,80005dd4 <sys_pipe+0xe8>
      p->ofile[fd0] = 0;
    80005dc8:	02278793          	addi	a5,a5,34
    80005dcc:	078e                	slli	a5,a5,0x3
    80005dce:	94be                	add	s1,s1,a5
    80005dd0:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005dd4:	fd043503          	ld	a0,-48(s0)
    80005dd8:	fffff097          	auipc	ra,0xfffff
    80005ddc:	9d2080e7          	jalr	-1582(ra) # 800047aa <fileclose>
    fileclose(wf);
    80005de0:	fc843503          	ld	a0,-56(s0)
    80005de4:	fffff097          	auipc	ra,0xfffff
    80005de8:	9c6080e7          	jalr	-1594(ra) # 800047aa <fileclose>
    return -1;
    80005dec:	57fd                	li	a5,-1
}
    80005dee:	853e                	mv	a0,a5
    80005df0:	70e2                	ld	ra,56(sp)
    80005df2:	7442                	ld	s0,48(sp)
    80005df4:	74a2                	ld	s1,40(sp)
    80005df6:	6121                	addi	sp,sp,64
    80005df8:	8082                	ret
    80005dfa:	0000                	unimp
    80005dfc:	0000                	unimp
	...

0000000080005e00 <kernelvec>:
    80005e00:	7111                	addi	sp,sp,-256
    80005e02:	e006                	sd	ra,0(sp)
    80005e04:	e40a                	sd	sp,8(sp)
    80005e06:	e80e                	sd	gp,16(sp)
    80005e08:	ec12                	sd	tp,24(sp)
    80005e0a:	f016                	sd	t0,32(sp)
    80005e0c:	f41a                	sd	t1,40(sp)
    80005e0e:	f81e                	sd	t2,48(sp)
    80005e10:	fc22                	sd	s0,56(sp)
    80005e12:	e0a6                	sd	s1,64(sp)
    80005e14:	e4aa                	sd	a0,72(sp)
    80005e16:	e8ae                	sd	a1,80(sp)
    80005e18:	ecb2                	sd	a2,88(sp)
    80005e1a:	f0b6                	sd	a3,96(sp)
    80005e1c:	f4ba                	sd	a4,104(sp)
    80005e1e:	f8be                	sd	a5,112(sp)
    80005e20:	fcc2                	sd	a6,120(sp)
    80005e22:	e146                	sd	a7,128(sp)
    80005e24:	e54a                	sd	s2,136(sp)
    80005e26:	e94e                	sd	s3,144(sp)
    80005e28:	ed52                	sd	s4,152(sp)
    80005e2a:	f156                	sd	s5,160(sp)
    80005e2c:	f55a                	sd	s6,168(sp)
    80005e2e:	f95e                	sd	s7,176(sp)
    80005e30:	fd62                	sd	s8,184(sp)
    80005e32:	e1e6                	sd	s9,192(sp)
    80005e34:	e5ea                	sd	s10,200(sp)
    80005e36:	e9ee                	sd	s11,208(sp)
    80005e38:	edf2                	sd	t3,216(sp)
    80005e3a:	f1f6                	sd	t4,224(sp)
    80005e3c:	f5fa                	sd	t5,232(sp)
    80005e3e:	f9fe                	sd	t6,240(sp)
    80005e40:	ccbfc0ef          	jal	ra,80002b0a <kerneltrap>
    80005e44:	6082                	ld	ra,0(sp)
    80005e46:	6122                	ld	sp,8(sp)
    80005e48:	61c2                	ld	gp,16(sp)
    80005e4a:	7282                	ld	t0,32(sp)
    80005e4c:	7322                	ld	t1,40(sp)
    80005e4e:	73c2                	ld	t2,48(sp)
    80005e50:	7462                	ld	s0,56(sp)
    80005e52:	6486                	ld	s1,64(sp)
    80005e54:	6526                	ld	a0,72(sp)
    80005e56:	65c6                	ld	a1,80(sp)
    80005e58:	6666                	ld	a2,88(sp)
    80005e5a:	7686                	ld	a3,96(sp)
    80005e5c:	7726                	ld	a4,104(sp)
    80005e5e:	77c6                	ld	a5,112(sp)
    80005e60:	7866                	ld	a6,120(sp)
    80005e62:	688a                	ld	a7,128(sp)
    80005e64:	692a                	ld	s2,136(sp)
    80005e66:	69ca                	ld	s3,144(sp)
    80005e68:	6a6a                	ld	s4,152(sp)
    80005e6a:	7a8a                	ld	s5,160(sp)
    80005e6c:	7b2a                	ld	s6,168(sp)
    80005e6e:	7bca                	ld	s7,176(sp)
    80005e70:	7c6a                	ld	s8,184(sp)
    80005e72:	6c8e                	ld	s9,192(sp)
    80005e74:	6d2e                	ld	s10,200(sp)
    80005e76:	6dce                	ld	s11,208(sp)
    80005e78:	6e6e                	ld	t3,216(sp)
    80005e7a:	7e8e                	ld	t4,224(sp)
    80005e7c:	7f2e                	ld	t5,232(sp)
    80005e7e:	7fce                	ld	t6,240(sp)
    80005e80:	6111                	addi	sp,sp,256
    80005e82:	10200073          	sret
    80005e86:	00000013          	nop
    80005e8a:	00000013          	nop
    80005e8e:	0001                	nop

0000000080005e90 <timervec>:
    80005e90:	34051573          	csrrw	a0,mscratch,a0
    80005e94:	e10c                	sd	a1,0(a0)
    80005e96:	e510                	sd	a2,8(a0)
    80005e98:	e914                	sd	a3,16(a0)
    80005e9a:	6d0c                	ld	a1,24(a0)
    80005e9c:	7110                	ld	a2,32(a0)
    80005e9e:	6194                	ld	a3,0(a1)
    80005ea0:	96b2                	add	a3,a3,a2
    80005ea2:	e194                	sd	a3,0(a1)
    80005ea4:	4589                	li	a1,2
    80005ea6:	14459073          	csrw	sip,a1
    80005eaa:	6914                	ld	a3,16(a0)
    80005eac:	6510                	ld	a2,8(a0)
    80005eae:	610c                	ld	a1,0(a0)
    80005eb0:	34051573          	csrrw	a0,mscratch,a0
    80005eb4:	30200073          	mret
	...

0000000080005eba <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005eba:	1141                	addi	sp,sp,-16
    80005ebc:	e422                	sd	s0,8(sp)
    80005ebe:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005ec0:	0c0007b7          	lui	a5,0xc000
    80005ec4:	4705                	li	a4,1
    80005ec6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005ec8:	c3d8                	sw	a4,4(a5)
}
    80005eca:	6422                	ld	s0,8(sp)
    80005ecc:	0141                	addi	sp,sp,16
    80005ece:	8082                	ret

0000000080005ed0 <plicinithart>:

void
plicinithart(void)
{
    80005ed0:	1141                	addi	sp,sp,-16
    80005ed2:	e406                	sd	ra,8(sp)
    80005ed4:	e022                	sd	s0,0(sp)
    80005ed6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ed8:	ffffc097          	auipc	ra,0xffffc
    80005edc:	ac6080e7          	jalr	-1338(ra) # 8000199e <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005ee0:	0085171b          	slliw	a4,a0,0x8
    80005ee4:	0c0027b7          	lui	a5,0xc002
    80005ee8:	97ba                	add	a5,a5,a4
    80005eea:	40200713          	li	a4,1026
    80005eee:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005ef2:	00d5151b          	slliw	a0,a0,0xd
    80005ef6:	0c2017b7          	lui	a5,0xc201
    80005efa:	953e                	add	a0,a0,a5
    80005efc:	00052023          	sw	zero,0(a0)
}
    80005f00:	60a2                	ld	ra,8(sp)
    80005f02:	6402                	ld	s0,0(sp)
    80005f04:	0141                	addi	sp,sp,16
    80005f06:	8082                	ret

0000000080005f08 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005f08:	1141                	addi	sp,sp,-16
    80005f0a:	e406                	sd	ra,8(sp)
    80005f0c:	e022                	sd	s0,0(sp)
    80005f0e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f10:	ffffc097          	auipc	ra,0xffffc
    80005f14:	a8e080e7          	jalr	-1394(ra) # 8000199e <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005f18:	00d5179b          	slliw	a5,a0,0xd
    80005f1c:	0c201537          	lui	a0,0xc201
    80005f20:	953e                	add	a0,a0,a5
  return irq;
}
    80005f22:	4148                	lw	a0,4(a0)
    80005f24:	60a2                	ld	ra,8(sp)
    80005f26:	6402                	ld	s0,0(sp)
    80005f28:	0141                	addi	sp,sp,16
    80005f2a:	8082                	ret

0000000080005f2c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005f2c:	1101                	addi	sp,sp,-32
    80005f2e:	ec06                	sd	ra,24(sp)
    80005f30:	e822                	sd	s0,16(sp)
    80005f32:	e426                	sd	s1,8(sp)
    80005f34:	1000                	addi	s0,sp,32
    80005f36:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005f38:	ffffc097          	auipc	ra,0xffffc
    80005f3c:	a66080e7          	jalr	-1434(ra) # 8000199e <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005f40:	00d5151b          	slliw	a0,a0,0xd
    80005f44:	0c2017b7          	lui	a5,0xc201
    80005f48:	97aa                	add	a5,a5,a0
    80005f4a:	c3c4                	sw	s1,4(a5)
}
    80005f4c:	60e2                	ld	ra,24(sp)
    80005f4e:	6442                	ld	s0,16(sp)
    80005f50:	64a2                	ld	s1,8(sp)
    80005f52:	6105                	addi	sp,sp,32
    80005f54:	8082                	ret

0000000080005f56 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005f56:	1141                	addi	sp,sp,-16
    80005f58:	e406                	sd	ra,8(sp)
    80005f5a:	e022                	sd	s0,0(sp)
    80005f5c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005f5e:	479d                	li	a5,7
    80005f60:	04a7cc63          	blt	a5,a0,80005fb8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005f64:	0001d797          	auipc	a5,0x1d
    80005f68:	cdc78793          	addi	a5,a5,-804 # 80022c40 <disk>
    80005f6c:	97aa                	add	a5,a5,a0
    80005f6e:	0187c783          	lbu	a5,24(a5)
    80005f72:	ebb9                	bnez	a5,80005fc8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005f74:	00451613          	slli	a2,a0,0x4
    80005f78:	0001d797          	auipc	a5,0x1d
    80005f7c:	cc878793          	addi	a5,a5,-824 # 80022c40 <disk>
    80005f80:	6394                	ld	a3,0(a5)
    80005f82:	96b2                	add	a3,a3,a2
    80005f84:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005f88:	6398                	ld	a4,0(a5)
    80005f8a:	9732                	add	a4,a4,a2
    80005f8c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005f90:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005f94:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005f98:	953e                	add	a0,a0,a5
    80005f9a:	4785                	li	a5,1
    80005f9c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005fa0:	0001d517          	auipc	a0,0x1d
    80005fa4:	cb850513          	addi	a0,a0,-840 # 80022c58 <disk+0x18>
    80005fa8:	ffffc097          	auipc	ra,0xffffc
    80005fac:	280080e7          	jalr	640(ra) # 80002228 <wakeup>
}
    80005fb0:	60a2                	ld	ra,8(sp)
    80005fb2:	6402                	ld	s0,0(sp)
    80005fb4:	0141                	addi	sp,sp,16
    80005fb6:	8082                	ret
    panic("free_desc 1");
    80005fb8:	00002517          	auipc	a0,0x2
    80005fbc:	7a850513          	addi	a0,a0,1960 # 80008760 <syscalls+0x308>
    80005fc0:	ffffa097          	auipc	ra,0xffffa
    80005fc4:	57e080e7          	jalr	1406(ra) # 8000053e <panic>
    panic("free_desc 2");
    80005fc8:	00002517          	auipc	a0,0x2
    80005fcc:	7a850513          	addi	a0,a0,1960 # 80008770 <syscalls+0x318>
    80005fd0:	ffffa097          	auipc	ra,0xffffa
    80005fd4:	56e080e7          	jalr	1390(ra) # 8000053e <panic>

0000000080005fd8 <virtio_disk_init>:
{
    80005fd8:	1101                	addi	sp,sp,-32
    80005fda:	ec06                	sd	ra,24(sp)
    80005fdc:	e822                	sd	s0,16(sp)
    80005fde:	e426                	sd	s1,8(sp)
    80005fe0:	e04a                	sd	s2,0(sp)
    80005fe2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005fe4:	00002597          	auipc	a1,0x2
    80005fe8:	79c58593          	addi	a1,a1,1948 # 80008780 <syscalls+0x328>
    80005fec:	0001d517          	auipc	a0,0x1d
    80005ff0:	d7c50513          	addi	a0,a0,-644 # 80022d68 <disk+0x128>
    80005ff4:	ffffb097          	auipc	ra,0xffffb
    80005ff8:	b52080e7          	jalr	-1198(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005ffc:	100017b7          	lui	a5,0x10001
    80006000:	4398                	lw	a4,0(a5)
    80006002:	2701                	sext.w	a4,a4
    80006004:	747277b7          	lui	a5,0x74727
    80006008:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000600c:	14f71c63          	bne	a4,a5,80006164 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006010:	100017b7          	lui	a5,0x10001
    80006014:	43dc                	lw	a5,4(a5)
    80006016:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006018:	4709                	li	a4,2
    8000601a:	14e79563          	bne	a5,a4,80006164 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000601e:	100017b7          	lui	a5,0x10001
    80006022:	479c                	lw	a5,8(a5)
    80006024:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006026:	12e79f63          	bne	a5,a4,80006164 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000602a:	100017b7          	lui	a5,0x10001
    8000602e:	47d8                	lw	a4,12(a5)
    80006030:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006032:	554d47b7          	lui	a5,0x554d4
    80006036:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000603a:	12f71563          	bne	a4,a5,80006164 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000603e:	100017b7          	lui	a5,0x10001
    80006042:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006046:	4705                	li	a4,1
    80006048:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000604a:	470d                	li	a4,3
    8000604c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000604e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006050:	c7ffe737          	lui	a4,0xc7ffe
    80006054:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb9df>
    80006058:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000605a:	2701                	sext.w	a4,a4
    8000605c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000605e:	472d                	li	a4,11
    80006060:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006062:	5bbc                	lw	a5,112(a5)
    80006064:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006068:	8ba1                	andi	a5,a5,8
    8000606a:	10078563          	beqz	a5,80006174 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000606e:	100017b7          	lui	a5,0x10001
    80006072:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006076:	43fc                	lw	a5,68(a5)
    80006078:	2781                	sext.w	a5,a5
    8000607a:	10079563          	bnez	a5,80006184 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000607e:	100017b7          	lui	a5,0x10001
    80006082:	5bdc                	lw	a5,52(a5)
    80006084:	2781                	sext.w	a5,a5
  if(max == 0)
    80006086:	10078763          	beqz	a5,80006194 <virtio_disk_init+0x1bc>
  if(max < NUM)
    8000608a:	471d                	li	a4,7
    8000608c:	10f77c63          	bgeu	a4,a5,800061a4 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    80006090:	ffffb097          	auipc	ra,0xffffb
    80006094:	a56080e7          	jalr	-1450(ra) # 80000ae6 <kalloc>
    80006098:	0001d497          	auipc	s1,0x1d
    8000609c:	ba848493          	addi	s1,s1,-1112 # 80022c40 <disk>
    800060a0:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800060a2:	ffffb097          	auipc	ra,0xffffb
    800060a6:	a44080e7          	jalr	-1468(ra) # 80000ae6 <kalloc>
    800060aa:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800060ac:	ffffb097          	auipc	ra,0xffffb
    800060b0:	a3a080e7          	jalr	-1478(ra) # 80000ae6 <kalloc>
    800060b4:	87aa                	mv	a5,a0
    800060b6:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800060b8:	6088                	ld	a0,0(s1)
    800060ba:	cd6d                	beqz	a0,800061b4 <virtio_disk_init+0x1dc>
    800060bc:	0001d717          	auipc	a4,0x1d
    800060c0:	b8c73703          	ld	a4,-1140(a4) # 80022c48 <disk+0x8>
    800060c4:	cb65                	beqz	a4,800061b4 <virtio_disk_init+0x1dc>
    800060c6:	c7fd                	beqz	a5,800061b4 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    800060c8:	6605                	lui	a2,0x1
    800060ca:	4581                	li	a1,0
    800060cc:	ffffb097          	auipc	ra,0xffffb
    800060d0:	c06080e7          	jalr	-1018(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    800060d4:	0001d497          	auipc	s1,0x1d
    800060d8:	b6c48493          	addi	s1,s1,-1172 # 80022c40 <disk>
    800060dc:	6605                	lui	a2,0x1
    800060de:	4581                	li	a1,0
    800060e0:	6488                	ld	a0,8(s1)
    800060e2:	ffffb097          	auipc	ra,0xffffb
    800060e6:	bf0080e7          	jalr	-1040(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    800060ea:	6605                	lui	a2,0x1
    800060ec:	4581                	li	a1,0
    800060ee:	6888                	ld	a0,16(s1)
    800060f0:	ffffb097          	auipc	ra,0xffffb
    800060f4:	be2080e7          	jalr	-1054(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800060f8:	100017b7          	lui	a5,0x10001
    800060fc:	4721                	li	a4,8
    800060fe:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006100:	4098                	lw	a4,0(s1)
    80006102:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006106:	40d8                	lw	a4,4(s1)
    80006108:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000610c:	6498                	ld	a4,8(s1)
    8000610e:	0007069b          	sext.w	a3,a4
    80006112:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006116:	9701                	srai	a4,a4,0x20
    80006118:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000611c:	6898                	ld	a4,16(s1)
    8000611e:	0007069b          	sext.w	a3,a4
    80006122:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006126:	9701                	srai	a4,a4,0x20
    80006128:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000612c:	4705                	li	a4,1
    8000612e:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80006130:	00e48c23          	sb	a4,24(s1)
    80006134:	00e48ca3          	sb	a4,25(s1)
    80006138:	00e48d23          	sb	a4,26(s1)
    8000613c:	00e48da3          	sb	a4,27(s1)
    80006140:	00e48e23          	sb	a4,28(s1)
    80006144:	00e48ea3          	sb	a4,29(s1)
    80006148:	00e48f23          	sb	a4,30(s1)
    8000614c:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006150:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006154:	0727a823          	sw	s2,112(a5)
}
    80006158:	60e2                	ld	ra,24(sp)
    8000615a:	6442                	ld	s0,16(sp)
    8000615c:	64a2                	ld	s1,8(sp)
    8000615e:	6902                	ld	s2,0(sp)
    80006160:	6105                	addi	sp,sp,32
    80006162:	8082                	ret
    panic("could not find virtio disk");
    80006164:	00002517          	auipc	a0,0x2
    80006168:	62c50513          	addi	a0,a0,1580 # 80008790 <syscalls+0x338>
    8000616c:	ffffa097          	auipc	ra,0xffffa
    80006170:	3d2080e7          	jalr	978(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    80006174:	00002517          	auipc	a0,0x2
    80006178:	63c50513          	addi	a0,a0,1596 # 800087b0 <syscalls+0x358>
    8000617c:	ffffa097          	auipc	ra,0xffffa
    80006180:	3c2080e7          	jalr	962(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    80006184:	00002517          	auipc	a0,0x2
    80006188:	64c50513          	addi	a0,a0,1612 # 800087d0 <syscalls+0x378>
    8000618c:	ffffa097          	auipc	ra,0xffffa
    80006190:	3b2080e7          	jalr	946(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    80006194:	00002517          	auipc	a0,0x2
    80006198:	65c50513          	addi	a0,a0,1628 # 800087f0 <syscalls+0x398>
    8000619c:	ffffa097          	auipc	ra,0xffffa
    800061a0:	3a2080e7          	jalr	930(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    800061a4:	00002517          	auipc	a0,0x2
    800061a8:	66c50513          	addi	a0,a0,1644 # 80008810 <syscalls+0x3b8>
    800061ac:	ffffa097          	auipc	ra,0xffffa
    800061b0:	392080e7          	jalr	914(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    800061b4:	00002517          	auipc	a0,0x2
    800061b8:	67c50513          	addi	a0,a0,1660 # 80008830 <syscalls+0x3d8>
    800061bc:	ffffa097          	auipc	ra,0xffffa
    800061c0:	382080e7          	jalr	898(ra) # 8000053e <panic>

00000000800061c4 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800061c4:	7119                	addi	sp,sp,-128
    800061c6:	fc86                	sd	ra,120(sp)
    800061c8:	f8a2                	sd	s0,112(sp)
    800061ca:	f4a6                	sd	s1,104(sp)
    800061cc:	f0ca                	sd	s2,96(sp)
    800061ce:	ecce                	sd	s3,88(sp)
    800061d0:	e8d2                	sd	s4,80(sp)
    800061d2:	e4d6                	sd	s5,72(sp)
    800061d4:	e0da                	sd	s6,64(sp)
    800061d6:	fc5e                	sd	s7,56(sp)
    800061d8:	f862                	sd	s8,48(sp)
    800061da:	f466                	sd	s9,40(sp)
    800061dc:	f06a                	sd	s10,32(sp)
    800061de:	ec6e                	sd	s11,24(sp)
    800061e0:	0100                	addi	s0,sp,128
    800061e2:	8aaa                	mv	s5,a0
    800061e4:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800061e6:	00c52d03          	lw	s10,12(a0)
    800061ea:	001d1d1b          	slliw	s10,s10,0x1
    800061ee:	1d02                	slli	s10,s10,0x20
    800061f0:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800061f4:	0001d517          	auipc	a0,0x1d
    800061f8:	b7450513          	addi	a0,a0,-1164 # 80022d68 <disk+0x128>
    800061fc:	ffffb097          	auipc	ra,0xffffb
    80006200:	9da080e7          	jalr	-1574(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80006204:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006206:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006208:	0001db97          	auipc	s7,0x1d
    8000620c:	a38b8b93          	addi	s7,s7,-1480 # 80022c40 <disk>
  for(int i = 0; i < 3; i++){
    80006210:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006212:	0001dc97          	auipc	s9,0x1d
    80006216:	b56c8c93          	addi	s9,s9,-1194 # 80022d68 <disk+0x128>
    8000621a:	a08d                	j	8000627c <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000621c:	00fb8733          	add	a4,s7,a5
    80006220:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006224:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006226:	0207c563          	bltz	a5,80006250 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000622a:	2905                	addiw	s2,s2,1
    8000622c:	0611                	addi	a2,a2,4
    8000622e:	05690c63          	beq	s2,s6,80006286 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006232:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006234:	0001d717          	auipc	a4,0x1d
    80006238:	a0c70713          	addi	a4,a4,-1524 # 80022c40 <disk>
    8000623c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000623e:	01874683          	lbu	a3,24(a4)
    80006242:	fee9                	bnez	a3,8000621c <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006244:	2785                	addiw	a5,a5,1
    80006246:	0705                	addi	a4,a4,1
    80006248:	fe979be3          	bne	a5,s1,8000623e <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000624c:	57fd                	li	a5,-1
    8000624e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006250:	01205d63          	blez	s2,8000626a <virtio_disk_rw+0xa6>
    80006254:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006256:	000a2503          	lw	a0,0(s4)
    8000625a:	00000097          	auipc	ra,0x0
    8000625e:	cfc080e7          	jalr	-772(ra) # 80005f56 <free_desc>
      for(int j = 0; j < i; j++)
    80006262:	2d85                	addiw	s11,s11,1
    80006264:	0a11                	addi	s4,s4,4
    80006266:	ffb918e3          	bne	s2,s11,80006256 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000626a:	85e6                	mv	a1,s9
    8000626c:	0001d517          	auipc	a0,0x1d
    80006270:	9ec50513          	addi	a0,a0,-1556 # 80022c58 <disk+0x18>
    80006274:	ffffc097          	auipc	ra,0xffffc
    80006278:	f50080e7          	jalr	-176(ra) # 800021c4 <sleep>
  for(int i = 0; i < 3; i++){
    8000627c:	f8040a13          	addi	s4,s0,-128
{
    80006280:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006282:	894e                	mv	s2,s3
    80006284:	b77d                	j	80006232 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006286:	f8042583          	lw	a1,-128(s0)
    8000628a:	00a58793          	addi	a5,a1,10
    8000628e:	0792                	slli	a5,a5,0x4

  if(write)
    80006290:	0001d617          	auipc	a2,0x1d
    80006294:	9b060613          	addi	a2,a2,-1616 # 80022c40 <disk>
    80006298:	00f60733          	add	a4,a2,a5
    8000629c:	018036b3          	snez	a3,s8
    800062a0:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800062a2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800062a6:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800062aa:	f6078693          	addi	a3,a5,-160
    800062ae:	6218                	ld	a4,0(a2)
    800062b0:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800062b2:	00878513          	addi	a0,a5,8
    800062b6:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    800062b8:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800062ba:	6208                	ld	a0,0(a2)
    800062bc:	96aa                	add	a3,a3,a0
    800062be:	4741                	li	a4,16
    800062c0:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800062c2:	4705                	li	a4,1
    800062c4:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    800062c8:	f8442703          	lw	a4,-124(s0)
    800062cc:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800062d0:	0712                	slli	a4,a4,0x4
    800062d2:	953a                	add	a0,a0,a4
    800062d4:	058a8693          	addi	a3,s5,88
    800062d8:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    800062da:	6208                	ld	a0,0(a2)
    800062dc:	972a                	add	a4,a4,a0
    800062de:	40000693          	li	a3,1024
    800062e2:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800062e4:	001c3c13          	seqz	s8,s8
    800062e8:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800062ea:	001c6c13          	ori	s8,s8,1
    800062ee:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800062f2:	f8842603          	lw	a2,-120(s0)
    800062f6:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800062fa:	0001d697          	auipc	a3,0x1d
    800062fe:	94668693          	addi	a3,a3,-1722 # 80022c40 <disk>
    80006302:	00258713          	addi	a4,a1,2
    80006306:	0712                	slli	a4,a4,0x4
    80006308:	9736                	add	a4,a4,a3
    8000630a:	587d                	li	a6,-1
    8000630c:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006310:	0612                	slli	a2,a2,0x4
    80006312:	9532                	add	a0,a0,a2
    80006314:	f9078793          	addi	a5,a5,-112
    80006318:	97b6                	add	a5,a5,a3
    8000631a:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    8000631c:	629c                	ld	a5,0(a3)
    8000631e:	97b2                	add	a5,a5,a2
    80006320:	4605                	li	a2,1
    80006322:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006324:	4509                	li	a0,2
    80006326:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    8000632a:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000632e:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006332:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006336:	6698                	ld	a4,8(a3)
    80006338:	00275783          	lhu	a5,2(a4)
    8000633c:	8b9d                	andi	a5,a5,7
    8000633e:	0786                	slli	a5,a5,0x1
    80006340:	97ba                	add	a5,a5,a4
    80006342:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006346:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000634a:	6698                	ld	a4,8(a3)
    8000634c:	00275783          	lhu	a5,2(a4)
    80006350:	2785                	addiw	a5,a5,1
    80006352:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006356:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000635a:	100017b7          	lui	a5,0x10001
    8000635e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006362:	004aa783          	lw	a5,4(s5)
    80006366:	02c79163          	bne	a5,a2,80006388 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    8000636a:	0001d917          	auipc	s2,0x1d
    8000636e:	9fe90913          	addi	s2,s2,-1538 # 80022d68 <disk+0x128>
  while(b->disk == 1) {
    80006372:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006374:	85ca                	mv	a1,s2
    80006376:	8556                	mv	a0,s5
    80006378:	ffffc097          	auipc	ra,0xffffc
    8000637c:	e4c080e7          	jalr	-436(ra) # 800021c4 <sleep>
  while(b->disk == 1) {
    80006380:	004aa783          	lw	a5,4(s5)
    80006384:	fe9788e3          	beq	a5,s1,80006374 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006388:	f8042903          	lw	s2,-128(s0)
    8000638c:	00290793          	addi	a5,s2,2
    80006390:	00479713          	slli	a4,a5,0x4
    80006394:	0001d797          	auipc	a5,0x1d
    80006398:	8ac78793          	addi	a5,a5,-1876 # 80022c40 <disk>
    8000639c:	97ba                	add	a5,a5,a4
    8000639e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800063a2:	0001d997          	auipc	s3,0x1d
    800063a6:	89e98993          	addi	s3,s3,-1890 # 80022c40 <disk>
    800063aa:	00491713          	slli	a4,s2,0x4
    800063ae:	0009b783          	ld	a5,0(s3)
    800063b2:	97ba                	add	a5,a5,a4
    800063b4:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800063b8:	854a                	mv	a0,s2
    800063ba:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800063be:	00000097          	auipc	ra,0x0
    800063c2:	b98080e7          	jalr	-1128(ra) # 80005f56 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800063c6:	8885                	andi	s1,s1,1
    800063c8:	f0ed                	bnez	s1,800063aa <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800063ca:	0001d517          	auipc	a0,0x1d
    800063ce:	99e50513          	addi	a0,a0,-1634 # 80022d68 <disk+0x128>
    800063d2:	ffffb097          	auipc	ra,0xffffb
    800063d6:	8b8080e7          	jalr	-1864(ra) # 80000c8a <release>
}
    800063da:	70e6                	ld	ra,120(sp)
    800063dc:	7446                	ld	s0,112(sp)
    800063de:	74a6                	ld	s1,104(sp)
    800063e0:	7906                	ld	s2,96(sp)
    800063e2:	69e6                	ld	s3,88(sp)
    800063e4:	6a46                	ld	s4,80(sp)
    800063e6:	6aa6                	ld	s5,72(sp)
    800063e8:	6b06                	ld	s6,64(sp)
    800063ea:	7be2                	ld	s7,56(sp)
    800063ec:	7c42                	ld	s8,48(sp)
    800063ee:	7ca2                	ld	s9,40(sp)
    800063f0:	7d02                	ld	s10,32(sp)
    800063f2:	6de2                	ld	s11,24(sp)
    800063f4:	6109                	addi	sp,sp,128
    800063f6:	8082                	ret

00000000800063f8 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800063f8:	1101                	addi	sp,sp,-32
    800063fa:	ec06                	sd	ra,24(sp)
    800063fc:	e822                	sd	s0,16(sp)
    800063fe:	e426                	sd	s1,8(sp)
    80006400:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006402:	0001d497          	auipc	s1,0x1d
    80006406:	83e48493          	addi	s1,s1,-1986 # 80022c40 <disk>
    8000640a:	0001d517          	auipc	a0,0x1d
    8000640e:	95e50513          	addi	a0,a0,-1698 # 80022d68 <disk+0x128>
    80006412:	ffffa097          	auipc	ra,0xffffa
    80006416:	7c4080e7          	jalr	1988(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000641a:	10001737          	lui	a4,0x10001
    8000641e:	533c                	lw	a5,96(a4)
    80006420:	8b8d                	andi	a5,a5,3
    80006422:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006424:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006428:	689c                	ld	a5,16(s1)
    8000642a:	0204d703          	lhu	a4,32(s1)
    8000642e:	0027d783          	lhu	a5,2(a5)
    80006432:	04f70863          	beq	a4,a5,80006482 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006436:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000643a:	6898                	ld	a4,16(s1)
    8000643c:	0204d783          	lhu	a5,32(s1)
    80006440:	8b9d                	andi	a5,a5,7
    80006442:	078e                	slli	a5,a5,0x3
    80006444:	97ba                	add	a5,a5,a4
    80006446:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006448:	00278713          	addi	a4,a5,2
    8000644c:	0712                	slli	a4,a4,0x4
    8000644e:	9726                	add	a4,a4,s1
    80006450:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006454:	e721                	bnez	a4,8000649c <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006456:	0789                	addi	a5,a5,2
    80006458:	0792                	slli	a5,a5,0x4
    8000645a:	97a6                	add	a5,a5,s1
    8000645c:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000645e:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006462:	ffffc097          	auipc	ra,0xffffc
    80006466:	dc6080e7          	jalr	-570(ra) # 80002228 <wakeup>

    disk.used_idx += 1;
    8000646a:	0204d783          	lhu	a5,32(s1)
    8000646e:	2785                	addiw	a5,a5,1
    80006470:	17c2                	slli	a5,a5,0x30
    80006472:	93c1                	srli	a5,a5,0x30
    80006474:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006478:	6898                	ld	a4,16(s1)
    8000647a:	00275703          	lhu	a4,2(a4)
    8000647e:	faf71ce3          	bne	a4,a5,80006436 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006482:	0001d517          	auipc	a0,0x1d
    80006486:	8e650513          	addi	a0,a0,-1818 # 80022d68 <disk+0x128>
    8000648a:	ffffb097          	auipc	ra,0xffffb
    8000648e:	800080e7          	jalr	-2048(ra) # 80000c8a <release>
}
    80006492:	60e2                	ld	ra,24(sp)
    80006494:	6442                	ld	s0,16(sp)
    80006496:	64a2                	ld	s1,8(sp)
    80006498:	6105                	addi	sp,sp,32
    8000649a:	8082                	ret
      panic("virtio_disk_intr status");
    8000649c:	00002517          	auipc	a0,0x2
    800064a0:	3ac50513          	addi	a0,a0,940 # 80008848 <syscalls+0x3f0>
    800064a4:	ffffa097          	auipc	ra,0xffffa
    800064a8:	09a080e7          	jalr	154(ra) # 8000053e <panic>
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
