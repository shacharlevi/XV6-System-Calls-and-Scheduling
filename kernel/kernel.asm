
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8e013103          	ld	sp,-1824(sp) # 800088e0 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000056:	8ee70713          	addi	a4,a4,-1810 # 80008940 <timer_scratch>
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
    80000068:	14c78793          	addi	a5,a5,332 # 800061b0 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb84f>
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
    80000130:	76c080e7          	jalr	1900(ra) # 80002898 <either_copyin>
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
    8000018e:	8f650513          	addi	a0,a0,-1802 # 80010a80 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	8e648493          	addi	s1,s1,-1818 # 80010a80 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	97690913          	addi	s2,s2,-1674 # 80010b18 <cons+0x98>
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
    800001cc:	4d8080e7          	jalr	1240(ra) # 800026a0 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	176080e7          	jalr	374(ra) # 8000234c <sleep>
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
    80000216:	630080e7          	jalr	1584(ra) # 80002842 <either_copyout>
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
    8000022a:	85a50513          	addi	a0,a0,-1958 # 80010a80 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	84450513          	addi	a0,a0,-1980 # 80010a80 <cons>
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
    80000276:	8af72323          	sw	a5,-1882(a4) # 80010b18 <cons+0x98>
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
    800002d0:	7b450513          	addi	a0,a0,1972 # 80010a80 <cons>
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
    800002f6:	6e6080e7          	jalr	1766(ra) # 800029d8 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	78650513          	addi	a0,a0,1926 # 80010a80 <cons>
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
    80000322:	76270713          	addi	a4,a4,1890 # 80010a80 <cons>
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
    8000034c:	73878793          	addi	a5,a5,1848 # 80010a80 <cons>
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
    8000037a:	7a27a783          	lw	a5,1954(a5) # 80010b18 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	6f670713          	addi	a4,a4,1782 # 80010a80 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	6e648493          	addi	s1,s1,1766 # 80010a80 <cons>
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
    800003da:	6aa70713          	addi	a4,a4,1706 # 80010a80 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	72f72a23          	sw	a5,1844(a4) # 80010b20 <cons+0xa0>
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
    80000416:	66e78793          	addi	a5,a5,1646 # 80010a80 <cons>
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
    8000043a:	6ec7a323          	sw	a2,1766(a5) # 80010b1c <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	6da50513          	addi	a0,a0,1754 # 80010b18 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	fee080e7          	jalr	-18(ra) # 80002434 <wakeup>
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
    80000464:	62050513          	addi	a0,a0,1568 # 80010a80 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32a080e7          	jalr	810(ra) # 8000079a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00022797          	auipc	a5,0x22
    8000047c:	9a078793          	addi	a5,a5,-1632 # 80021e18 <devsw>
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
    8000054e:	5e07ab23          	sw	zero,1526(a5) # 80010b40 <pr+0x18>
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
    80000582:	38f72123          	sw	a5,898(a4) # 80008900 <panicked>
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
    800005be:	586dad83          	lw	s11,1414(s11) # 80010b40 <pr+0x18>
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
    800005fc:	53050513          	addi	a0,a0,1328 # 80010b28 <pr>
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
    8000075a:	3d250513          	addi	a0,a0,978 # 80010b28 <pr>
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
    80000776:	3b648493          	addi	s1,s1,950 # 80010b28 <pr>
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
    800007d6:	37650513          	addi	a0,a0,886 # 80010b48 <uart_tx_lock>
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
    80000802:	1027a783          	lw	a5,258(a5) # 80008900 <panicked>
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
    8000083a:	0d27b783          	ld	a5,210(a5) # 80008908 <uart_tx_r>
    8000083e:	00008717          	auipc	a4,0x8
    80000842:	0d273703          	ld	a4,210(a4) # 80008910 <uart_tx_w>
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
    80000864:	2e8a0a13          	addi	s4,s4,744 # 80010b48 <uart_tx_lock>
    uart_tx_r += 1;
    80000868:	00008497          	auipc	s1,0x8
    8000086c:	0a048493          	addi	s1,s1,160 # 80008908 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000870:	00008997          	auipc	s3,0x8
    80000874:	0a098993          	addi	s3,s3,160 # 80008910 <uart_tx_w>
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
    80000896:	ba2080e7          	jalr	-1118(ra) # 80002434 <wakeup>
    
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
    800008d2:	27a50513          	addi	a0,a0,634 # 80010b48 <uart_tx_lock>
    800008d6:	00000097          	auipc	ra,0x0
    800008da:	300080e7          	jalr	768(ra) # 80000bd6 <acquire>
  if(panicked){
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	0227a783          	lw	a5,34(a5) # 80008900 <panicked>
    800008e6:	e7c9                	bnez	a5,80000970 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e8:	00008717          	auipc	a4,0x8
    800008ec:	02873703          	ld	a4,40(a4) # 80008910 <uart_tx_w>
    800008f0:	00008797          	auipc	a5,0x8
    800008f4:	0187b783          	ld	a5,24(a5) # 80008908 <uart_tx_r>
    800008f8:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fc:	00010997          	auipc	s3,0x10
    80000900:	24c98993          	addi	s3,s3,588 # 80010b48 <uart_tx_lock>
    80000904:	00008497          	auipc	s1,0x8
    80000908:	00448493          	addi	s1,s1,4 # 80008908 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090c:	00008917          	auipc	s2,0x8
    80000910:	00490913          	addi	s2,s2,4 # 80008910 <uart_tx_w>
    80000914:	00e79f63          	bne	a5,a4,80000932 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000918:	85ce                	mv	a1,s3
    8000091a:	8526                	mv	a0,s1
    8000091c:	00002097          	auipc	ra,0x2
    80000920:	a30080e7          	jalr	-1488(ra) # 8000234c <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000924:	00093703          	ld	a4,0(s2)
    80000928:	609c                	ld	a5,0(s1)
    8000092a:	02078793          	addi	a5,a5,32
    8000092e:	fee785e3          	beq	a5,a4,80000918 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000932:	00010497          	auipc	s1,0x10
    80000936:	21648493          	addi	s1,s1,534 # 80010b48 <uart_tx_lock>
    8000093a:	01f77793          	andi	a5,a4,31
    8000093e:	97a6                	add	a5,a5,s1
    80000940:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000944:	0705                	addi	a4,a4,1
    80000946:	00008797          	auipc	a5,0x8
    8000094a:	fce7b523          	sd	a4,-54(a5) # 80008910 <uart_tx_w>
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
    800009c0:	18c48493          	addi	s1,s1,396 # 80010b48 <uart_tx_lock>
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
    80000a02:	5b278793          	addi	a5,a5,1458 # 80022fb0 <end>
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
    80000a22:	16290913          	addi	s2,s2,354 # 80010b80 <kmem>
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
    80000abe:	0c650513          	addi	a0,a0,198 # 80010b80 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00022517          	auipc	a0,0x22
    80000ad2:	4e250513          	addi	a0,a0,1250 # 80022fb0 <end>
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
    80000af4:	09048493          	addi	s1,s1,144 # 80010b80 <kmem>
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
    80000b0c:	07850513          	addi	a0,a0,120 # 80010b80 <kmem>
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
    80000b38:	04c50513          	addi	a0,a0,76 # 80010b80 <kmem>
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
    80000e8c:	a9070713          	addi	a4,a4,-1392 # 80008918 <started>
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
    80000ec2:	c5a080e7          	jalr	-934(ra) # 80002b18 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	32a080e7          	jalr	810(ra) # 800061f0 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	316080e7          	jalr	790(ra) # 800021e4 <scheduler>
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
    80000f3a:	bba080e7          	jalr	-1094(ra) # 80002af0 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	bda080e7          	jalr	-1062(ra) # 80002b18 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	294080e7          	jalr	660(ra) # 800061da <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	2a2080e7          	jalr	674(ra) # 800061f0 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	43e080e7          	jalr	1086(ra) # 80003394 <binit>
    iinit();         // inode table
    80000f5e:	00003097          	auipc	ra,0x3
    80000f62:	ae2080e7          	jalr	-1310(ra) # 80003a40 <iinit>
    fileinit();      // file table
    80000f66:	00004097          	auipc	ra,0x4
    80000f6a:	a80080e7          	jalr	-1408(ra) # 800049e6 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	38a080e7          	jalr	906(ra) # 800062f8 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	d2c080e7          	jalr	-724(ra) # 80001ca2 <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	98f72a23          	sw	a5,-1644(a4) # 80008918 <started>
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
    80000f9c:	9887b783          	ld	a5,-1656(a5) # 80008920 <kernel_pagetable>
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
    80001258:	6ca7b623          	sd	a0,1740(a5) # 80008920 <kernel_pagetable>
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
    80001850:	78448493          	addi	s1,s1,1924 # 80010fd0 <proc>
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
    8000186a:	36aa0a13          	addi	s4,s4,874 # 80017bd0 <tickslock>
    char *pa = kalloc();
    8000186e:	fffff097          	auipc	ra,0xfffff
    80001872:	278080e7          	jalr	632(ra) # 80000ae6 <kalloc>
    80001876:	862a                	mv	a2,a0
    if (pa == 0)
    80001878:	c131                	beqz	a0,800018bc <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    8000187a:	416485b3          	sub	a1,s1,s6
    8000187e:	8591                	srai	a1,a1,0x4
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
    800018a0:	1b048493          	addi	s1,s1,432
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
    800018ee:	2b650513          	addi	a0,a0,694 # 80010ba0 <pid_lock>
    800018f2:	fffff097          	auipc	ra,0xfffff
    800018f6:	254080e7          	jalr	596(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018fa:	00007597          	auipc	a1,0x7
    800018fe:	8ee58593          	addi	a1,a1,-1810 # 800081e8 <digits+0x1a8>
    80001902:	0000f517          	auipc	a0,0xf
    80001906:	2b650513          	addi	a0,a0,694 # 80010bb8 <wait_lock>
    8000190a:	fffff097          	auipc	ra,0xfffff
    8000190e:	23c080e7          	jalr	572(ra) # 80000b46 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001912:	0000f497          	auipc	s1,0xf
    80001916:	6be48493          	addi	s1,s1,1726 # 80010fd0 <proc>
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
    8000193a:	29a98993          	addi	s3,s3,666 # 80017bd0 <tickslock>
    initlock(&p->lock, "proc");
    8000193e:	85de                	mv	a1,s7
    80001940:	8526                	mv	a0,s1
    80001942:	fffff097          	auipc	ra,0xfffff
    80001946:	204080e7          	jalr	516(ra) # 80000b46 <initlock>
    p->state = UNUSED;
    8000194a:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    8000194e:	416487b3          	sub	a5,s1,s6
    80001952:	8791                	srai	a5,a5,0x4
    80001954:	000ab703          	ld	a4,0(s5)
    80001958:	02e787b3          	mul	a5,a5,a4
    8000195c:	2785                	addiw	a5,a5,1
    8000195e:	00d7979b          	slliw	a5,a5,0xd
    80001962:	40f907b3          	sub	a5,s2,a5
    80001966:	e4dc                	sd	a5,136(s1)
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
    80001980:	1b048493          	addi	s1,s1,432
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
    800019be:	21650513          	addi	a0,a0,534 # 80010bd0 <cpus>
    800019c2:	953e                	add	a0,a0,a5
    800019c4:	6422                	ld	s0,8(sp)
    800019c6:	0141                	addi	sp,sp,16
    800019c8:	8082                	ret

00000000800019ca <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
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
    800019e6:	1be70713          	addi	a4,a4,446 # 80010ba0 <pid_lock>
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
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
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

  if (first)
    80001a1a:	00007797          	auipc	a5,0x7
    80001a1e:	e767a783          	lw	a5,-394(a5) # 80008890 <first.1>
    80001a22:	eb89                	bnez	a5,80001a34 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a24:	00001097          	auipc	ra,0x1
    80001a28:	10c080e7          	jalr	268(ra) # 80002b30 <usertrapret>
}
    80001a2c:	60a2                	ld	ra,8(sp)
    80001a2e:	6402                	ld	s0,0(sp)
    80001a30:	0141                	addi	sp,sp,16
    80001a32:	8082                	ret
    first = 0;
    80001a34:	00007797          	auipc	a5,0x7
    80001a38:	e407ae23          	sw	zero,-420(a5) # 80008890 <first.1>
    fsinit(ROOTDEV);
    80001a3c:	4505                	li	a0,1
    80001a3e:	00002097          	auipc	ra,0x2
    80001a42:	f82080e7          	jalr	-126(ra) # 800039c0 <fsinit>
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
    80001a58:	14c90913          	addi	s2,s2,332 # 80010ba0 <pid_lock>
    80001a5c:	854a                	mv	a0,s2
    80001a5e:	fffff097          	auipc	ra,0xfffff
    80001a62:	178080e7          	jalr	376(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001a66:	00007797          	auipc	a5,0x7
    80001a6a:	e2e78793          	addi	a5,a5,-466 # 80008894 <nextpid>
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
  if (pagetable == 0)
    80001aa6:	c121                	beqz	a0,80001ae6 <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
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
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ac8:	4719                	li	a4,6
    80001aca:	0a093683          	ld	a3,160(s2)
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
  if (p->trapframe)
    80001b88:	7148                	ld	a0,160(a0)
    80001b8a:	c509                	beqz	a0,80001b94 <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001b8c:	fffff097          	auipc	ra,0xfffff
    80001b90:	e5e080e7          	jalr	-418(ra) # 800009ea <kfree>
  p->trapframe = 0;
    80001b94:	0a04b023          	sd	zero,160(s1)
  if (p->pagetable)
    80001b98:	6cc8                	ld	a0,152(s1)
    80001b9a:	c511                	beqz	a0,80001ba6 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b9c:	68cc                	ld	a1,144(s1)
    80001b9e:	00000097          	auipc	ra,0x0
    80001ba2:	f8c080e7          	jalr	-116(ra) # 80001b2a <proc_freepagetable>
  p->pagetable = 0;
    80001ba6:	0804bc23          	sd	zero,152(s1)
  p->sz = 0;
    80001baa:	0804b823          	sd	zero,144(s1)
  p->pid = 0;
    80001bae:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001bb2:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001bb6:	1a048023          	sb	zero,416(s1)
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
  for (p = proc; p < &proc[NPROC]; p++)
    80001be0:	0000f497          	auipc	s1,0xf
    80001be4:	3f048493          	addi	s1,s1,1008 # 80010fd0 <proc>
    80001be8:	00016917          	auipc	s2,0x16
    80001bec:	fe890913          	addi	s2,s2,-24 # 80017bd0 <tickslock>
    acquire(&p->lock);
    80001bf0:	8526                	mv	a0,s1
    80001bf2:	fffff097          	auipc	ra,0xfffff
    80001bf6:	fe4080e7          	jalr	-28(ra) # 80000bd6 <acquire>
    if (p->state == UNUSED)
    80001bfa:	4c9c                	lw	a5,24(s1)
    80001bfc:	cf81                	beqz	a5,80001c14 <allocproc+0x40>
      release(&p->lock);
    80001bfe:	8526                	mv	a0,s1
    80001c00:	fffff097          	auipc	ra,0xfffff
    80001c04:	08a080e7          	jalr	138(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001c08:	1b048493          	addi	s1,s1,432
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
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001c22:	fffff097          	auipc	ra,0xfffff
    80001c26:	ec4080e7          	jalr	-316(ra) # 80000ae6 <kalloc>
    80001c2a:	892a                	mv	s2,a0
    80001c2c:	f0c8                	sd	a0,160(s1)
    80001c2e:	c131                	beqz	a0,80001c72 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001c30:	8526                	mv	a0,s1
    80001c32:	00000097          	auipc	ra,0x0
    80001c36:	e5c080e7          	jalr	-420(ra) # 80001a8e <proc_pagetable>
    80001c3a:	892a                	mv	s2,a0
    80001c3c:	ecc8                	sd	a0,152(s1)
  if (p->pagetable == 0)
    80001c3e:	c531                	beqz	a0,80001c8a <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001c40:	07000613          	li	a2,112
    80001c44:	4581                	li	a1,0
    80001c46:	0a848513          	addi	a0,s1,168
    80001c4a:	fffff097          	auipc	ra,0xfffff
    80001c4e:	088080e7          	jalr	136(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001c52:	00000797          	auipc	a5,0x0
    80001c56:	db078793          	addi	a5,a5,-592 # 80001a02 <forkret>
    80001c5a:	f4dc                	sd	a5,168(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c5c:	64dc                	ld	a5,136(s1)
    80001c5e:	6705                	lui	a4,0x1
    80001c60:	97ba                	add	a5,a5,a4
    80001c62:	f8dc                	sd	a5,176(s1)
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
    80001cba:	c6a7b923          	sd	a0,-910(a5) # 80008928 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cbe:	03400613          	li	a2,52
    80001cc2:	00007597          	auipc	a1,0x7
    80001cc6:	bde58593          	addi	a1,a1,-1058 # 800088a0 <initcode>
    80001cca:	6d48                	ld	a0,152(a0)
    80001ccc:	fffff097          	auipc	ra,0xfffff
    80001cd0:	68a080e7          	jalr	1674(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80001cd4:	6785                	lui	a5,0x1
    80001cd6:	e8dc                	sd	a5,144(s1)
  p->trapframe->epc = 0;     // user program counter
    80001cd8:	70d8                	ld	a4,160(s1)
    80001cda:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001cde:	70d8                	ld	a4,160(s1)
    80001ce0:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001ce2:	4641                	li	a2,16
    80001ce4:	00006597          	auipc	a1,0x6
    80001ce8:	51c58593          	addi	a1,a1,1308 # 80008200 <digits+0x1c0>
    80001cec:	1a048513          	addi	a0,s1,416
    80001cf0:	fffff097          	auipc	ra,0xfffff
    80001cf4:	12c080e7          	jalr	300(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001cf8:	00006517          	auipc	a0,0x6
    80001cfc:	51850513          	addi	a0,a0,1304 # 80008210 <digits+0x1d0>
    80001d00:	00002097          	auipc	ra,0x2
    80001d04:	6e2080e7          	jalr	1762(ra) # 800043e2 <namei>
    80001d08:	18a4bc23          	sd	a0,408(s1)
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
    80001d3c:	694c                	ld	a1,144(a0)
  if (n > 0)
    80001d3e:	01204c63          	bgtz	s2,80001d56 <growproc+0x32>
  else if (n < 0)
    80001d42:	02094663          	bltz	s2,80001d6e <growproc+0x4a>
  p->sz = sz;
    80001d46:	e8cc                	sd	a1,144(s1)
  return 0;
    80001d48:	4501                	li	a0,0
}
    80001d4a:	60e2                	ld	ra,24(sp)
    80001d4c:	6442                	ld	s0,16(sp)
    80001d4e:	64a2                	ld	s1,8(sp)
    80001d50:	6902                	ld	s2,0(sp)
    80001d52:	6105                	addi	sp,sp,32
    80001d54:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001d56:	4691                	li	a3,4
    80001d58:	00b90633          	add	a2,s2,a1
    80001d5c:	6d48                	ld	a0,152(a0)
    80001d5e:	fffff097          	auipc	ra,0xfffff
    80001d62:	6b2080e7          	jalr	1714(ra) # 80001410 <uvmalloc>
    80001d66:	85aa                	mv	a1,a0
    80001d68:	fd79                	bnez	a0,80001d46 <growproc+0x22>
      return -1;
    80001d6a:	557d                	li	a0,-1
    80001d6c:	bff9                	j	80001d4a <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d6e:	00b90633          	add	a2,s2,a1
    80001d72:	6d48                	ld	a0,152(a0)
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
  if ((np = allocproc()) == 0)
    80001d9c:	00000097          	auipc	ra,0x0
    80001da0:	e38080e7          	jalr	-456(ra) # 80001bd4 <allocproc>
    80001da4:	10050c63          	beqz	a0,80001ebc <fork+0x13c>
    80001da8:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001daa:	090ab603          	ld	a2,144(s5)
    80001dae:	6d4c                	ld	a1,152(a0)
    80001db0:	098ab503          	ld	a0,152(s5)
    80001db4:	fffff097          	auipc	ra,0xfffff
    80001db8:	7b0080e7          	jalr	1968(ra) # 80001564 <uvmcopy>
    80001dbc:	04054863          	bltz	a0,80001e0c <fork+0x8c>
  np->sz = p->sz;
    80001dc0:	090ab783          	ld	a5,144(s5)
    80001dc4:	08fa3823          	sd	a5,144(s4)
  *(np->trapframe) = *(p->trapframe);
    80001dc8:	0a0ab683          	ld	a3,160(s5)
    80001dcc:	87b6                	mv	a5,a3
    80001dce:	0a0a3703          	ld	a4,160(s4)
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
    80001df6:	0a0a3783          	ld	a5,160(s4)
    80001dfa:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001dfe:	118a8493          	addi	s1,s5,280
    80001e02:	118a0913          	addi	s2,s4,280
    80001e06:	198a8993          	addi	s3,s5,408
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
  for (i = 0; i < NOFILE; i++)
    80001e24:	04a1                	addi	s1,s1,8
    80001e26:	0921                	addi	s2,s2,8
    80001e28:	01348b63          	beq	s1,s3,80001e3e <fork+0xbe>
    if (p->ofile[i])
    80001e2c:	6088                	ld	a0,0(s1)
    80001e2e:	d97d                	beqz	a0,80001e24 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e30:	00003097          	auipc	ra,0x3
    80001e34:	c48080e7          	jalr	-952(ra) # 80004a78 <filedup>
    80001e38:	00a93023          	sd	a0,0(s2)
    80001e3c:	b7e5                	j	80001e24 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e3e:	198ab503          	ld	a0,408(s5)
    80001e42:	00002097          	auipc	ra,0x2
    80001e46:	dbc080e7          	jalr	-580(ra) # 80003bfe <idup>
    80001e4a:	18aa3c23          	sd	a0,408(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e4e:	4641                	li	a2,16
    80001e50:	1a0a8593          	addi	a1,s5,416
    80001e54:	1a0a0513          	addi	a0,s4,416
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
    80001e72:	d4a48493          	addi	s1,s1,-694 # 80010bb8 <wait_lock>
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

0000000080001ec0 <ps_scheduler>:
{
    80001ec0:	7159                	addi	sp,sp,-112
    80001ec2:	f486                	sd	ra,104(sp)
    80001ec4:	f0a2                	sd	s0,96(sp)
    80001ec6:	eca6                	sd	s1,88(sp)
    80001ec8:	e8ca                	sd	s2,80(sp)
    80001eca:	e4ce                	sd	s3,72(sp)
    80001ecc:	e0d2                	sd	s4,64(sp)
    80001ece:	fc56                	sd	s5,56(sp)
    80001ed0:	f85a                	sd	s6,48(sp)
    80001ed2:	f45e                	sd	s7,40(sp)
    80001ed4:	1880                	addi	s0,sp,112
    80001ed6:	8b92                	mv	s7,tp
  int id = r_tp();
    80001ed8:	2b81                	sext.w	s7,s7
  initlock(&counter, "counter");
    80001eda:	00006597          	auipc	a1,0x6
    80001ede:	33e58593          	addi	a1,a1,830 # 80008218 <digits+0x1d8>
    80001ee2:	f9840513          	addi	a0,s0,-104
    80001ee6:	fffff097          	auipc	ra,0xfffff
    80001eea:	c60080e7          	jalr	-928(ra) # 80000b46 <initlock>
  c->proc = 0;
    80001eee:	007b9713          	slli	a4,s7,0x7
    80001ef2:	0000f797          	auipc	a5,0xf
    80001ef6:	cae78793          	addi	a5,a5,-850 # 80010ba0 <pid_lock>
    80001efa:	97ba                	add	a5,a5,a4
    80001efc:	0207b823          	sd	zero,48(a5)
  acquire(&counter);
    80001f00:	f9840513          	addi	a0,s0,-104
    80001f04:	fffff097          	auipc	ra,0xfffff
    80001f08:	cd2080e7          	jalr	-814(ra) # 80000bd6 <acquire>
  release(&counter); // long long min_accumulator = LLONG_MAX;
    80001f0c:	f9840513          	addi	a0,s0,-104
    80001f10:	fffff097          	auipc	ra,0xfffff
    80001f14:	d7a080e7          	jalr	-646(ra) # 80000c8a <release>
  proc_counter = 0;
    80001f18:	4a01                	li	s4,0
  min_proc = 0;
    80001f1a:	4b01                	li	s6,0
  for (p = proc; p < &proc[NPROC]; p++)
    80001f1c:	0000f497          	auipc	s1,0xf
    80001f20:	0b448493          	addi	s1,s1,180 # 80010fd0 <proc>
    if (p->state == RUNNABLE && (p->accumulator < min_accumulator || proc_counter == 0))
    80001f24:	498d                	li	s3,3
    80001f26:	00007a97          	auipc	s5,0x7
    80001f2a:	976a8a93          	addi	s5,s5,-1674 # 8000889c <min_accumulator>
  for (p = proc; p < &proc[NPROC]; p++)
    80001f2e:	00016917          	auipc	s2,0x16
    80001f32:	ca290913          	addi	s2,s2,-862 # 80017bd0 <tickslock>
    80001f36:	a81d                	j	80001f6c <ps_scheduler+0xac>
      acquire(&counter);
    80001f38:	f9840513          	addi	a0,s0,-104
    80001f3c:	fffff097          	auipc	ra,0xfffff
    80001f40:	c9a080e7          	jalr	-870(ra) # 80000bd6 <acquire>
      proc_counter++;
    80001f44:	2a05                	addiw	s4,s4,1
      release(&counter);
    80001f46:	f9840513          	addi	a0,s0,-104
    80001f4a:	fffff097          	auipc	ra,0xfffff
    80001f4e:	d40080e7          	jalr	-704(ra) # 80000c8a <release>
      min_accumulator = p->accumulator;
    80001f52:	70bc                	ld	a5,96(s1)
    80001f54:	00faa023          	sw	a5,0(s5)
    80001f58:	8b26                	mv	s6,s1
    release(&p->lock);
    80001f5a:	8526                	mv	a0,s1
    80001f5c:	fffff097          	auipc	ra,0xfffff
    80001f60:	d2e080e7          	jalr	-722(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001f64:	1b048493          	addi	s1,s1,432
    80001f68:	03248263          	beq	s1,s2,80001f8c <ps_scheduler+0xcc>
    acquire(&p->lock); // printf("Process %d state: %d\n", p->pid, p->state);  // <-- Debugging statement
    80001f6c:	8526                	mv	a0,s1
    80001f6e:	fffff097          	auipc	ra,0xfffff
    80001f72:	c68080e7          	jalr	-920(ra) # 80000bd6 <acquire>
    if (p->state == RUNNABLE && (p->accumulator < min_accumulator || proc_counter == 0))
    80001f76:	4c9c                	lw	a5,24(s1)
    80001f78:	ff3791e3          	bne	a5,s3,80001f5a <ps_scheduler+0x9a>
    80001f7c:	000aa783          	lw	a5,0(s5)
    80001f80:	70b8                	ld	a4,96(s1)
    80001f82:	faf74be3          	blt	a4,a5,80001f38 <ps_scheduler+0x78>
    80001f86:	fc0a1ae3          	bnez	s4,80001f5a <ps_scheduler+0x9a>
    80001f8a:	b77d                	j	80001f38 <ps_scheduler+0x78>
  if (min_proc != 0)
    80001f8c:	020b0563          	beqz	s6,80001fb6 <ps_scheduler+0xf6>
    if (proc_counter == 1)
    80001f90:	4785                	li	a5,1
    80001f92:	02fa0d63          	beq	s4,a5,80001fcc <ps_scheduler+0x10c>
    acquire(&min_proc->lock);
    80001f96:	84da                	mv	s1,s6
    80001f98:	855a                	mv	a0,s6
    80001f9a:	fffff097          	auipc	ra,0xfffff
    80001f9e:	c3c080e7          	jalr	-964(ra) # 80000bd6 <acquire>
    if (min_proc->state == RUNNABLE)
    80001fa2:	018b2703          	lw	a4,24(s6) # 1018 <_entry-0x7fffefe8>
    80001fa6:	478d                	li	a5,3
    80001fa8:	02f70563          	beq	a4,a5,80001fd2 <ps_scheduler+0x112>
    release(&min_proc->lock);
    80001fac:	8526                	mv	a0,s1
    80001fae:	fffff097          	auipc	ra,0xfffff
    80001fb2:	cdc080e7          	jalr	-804(ra) # 80000c8a <release>
}
    80001fb6:	70a6                	ld	ra,104(sp)
    80001fb8:	7406                	ld	s0,96(sp)
    80001fba:	64e6                	ld	s1,88(sp)
    80001fbc:	6946                	ld	s2,80(sp)
    80001fbe:	69a6                	ld	s3,72(sp)
    80001fc0:	6a06                	ld	s4,64(sp)
    80001fc2:	7ae2                	ld	s5,56(sp)
    80001fc4:	7b42                	ld	s6,48(sp)
    80001fc6:	7ba2                	ld	s7,40(sp)
    80001fc8:	6165                	addi	sp,sp,112
    80001fca:	8082                	ret
      min_proc->accumulator = 0;
    80001fcc:	060b3023          	sd	zero,96(s6)
    80001fd0:	b7d9                	j	80001f96 <ps_scheduler+0xd6>
      min_proc->state = RUNNING;
    80001fd2:	4791                	li	a5,4
    80001fd4:	00fb2c23          	sw	a5,24(s6)
      c->proc = min_proc;
    80001fd8:	0b9e                	slli	s7,s7,0x7
    80001fda:	0000f917          	auipc	s2,0xf
    80001fde:	bc690913          	addi	s2,s2,-1082 # 80010ba0 <pid_lock>
    80001fe2:	995e                	add	s2,s2,s7
    80001fe4:	03693823          	sd	s6,48(s2)
      swtch(&c->context, &min_proc->context);
    80001fe8:	0a8b0593          	addi	a1,s6,168
    80001fec:	0000f517          	auipc	a0,0xf
    80001ff0:	bec50513          	addi	a0,a0,-1044 # 80010bd8 <cpus+0x8>
    80001ff4:	955e                	add	a0,a0,s7
    80001ff6:	00001097          	auipc	ra,0x1
    80001ffa:	a90080e7          	jalr	-1392(ra) # 80002a86 <swtch>
      c->proc = 0;
    80001ffe:	02093823          	sd	zero,48(s2)
    80002002:	b76d                	j	80001fac <ps_scheduler+0xec>

0000000080002004 <cfs_scheduler>:
void cfs_scheduler(void){
    80002004:	7119                	addi	sp,sp,-128
    80002006:	fc86                	sd	ra,120(sp)
    80002008:	f8a2                	sd	s0,112(sp)
    8000200a:	f4a6                	sd	s1,104(sp)
    8000200c:	f0ca                	sd	s2,96(sp)
    8000200e:	ecce                	sd	s3,88(sp)
    80002010:	e8d2                	sd	s4,80(sp)
    80002012:	e4d6                	sd	s5,72(sp)
    80002014:	e0da                	sd	s6,64(sp)
    80002016:	fc5e                	sd	s7,56(sp)
    80002018:	f862                	sd	s8,48(sp)
    8000201a:	f466                	sd	s9,40(sp)
    8000201c:	f06a                	sd	s10,32(sp)
    8000201e:	ec6e                	sd	s11,24(sp)
    80002020:	0100                	addi	s0,sp,128
    80002022:	8792                	mv	a5,tp
  int id = r_tp();
    80002024:	2781                	sext.w	a5,a5
    80002026:	f8f43423          	sd	a5,-120(s0)
  c->proc = 0;
    8000202a:	00779713          	slli	a4,a5,0x7
    8000202e:	0000f797          	auipc	a5,0xf
    80002032:	b7278793          	addi	a5,a5,-1166 # 80010ba0 <pid_lock>
    80002036:	97ba                	add	a5,a5,a4
    80002038:	0207b823          	sd	zero,48(a5)
  int min_vruntime = __INT_MAX__;
    8000203c:	80000bb7          	lui	s7,0x80000
    80002040:	fffbcb93          	not	s7,s7
  int decay_factor = 100;
    80002044:	06400913          	li	s2,100
  struct proc *min_proc = 0;
    80002048:	4d81                	li	s11,0
  for (p = proc; p < &proc[NPROC]; p++){
    8000204a:	0000f497          	auipc	s1,0xf
    8000204e:	f8648493          	addi	s1,s1,-122 # 80010fd0 <proc>
    switch (p->cfs_priority){
    80002052:	4b05                	li	s6,1
      decay_factor = 100;
    80002054:	06400d13          	li	s10,100
    switch (p->cfs_priority){
    80002058:	4a89                	li	s5,2
      decay_factor = 125;
    8000205a:	07d00c93          	li	s9,125
    switch (p->cfs_priority){
    8000205e:	04b00c13          	li	s8,75
    if (p->state == RUNNABLE && vruntime < min_vruntime){
    80002062:	4a0d                	li	s4,3
  for (p = proc; p < &proc[NPROC]; p++){
    80002064:	00016997          	auipc	s3,0x16
    80002068:	b6c98993          	addi	s3,s3,-1172 # 80017bd0 <tickslock>
    8000206c:	a005                	j	8000208c <cfs_scheduler+0x88>
    switch (p->cfs_priority){
    8000206e:	8962                	mv	s2,s8
    80002070:	a80d                	j	800020a2 <cfs_scheduler+0x9e>
      decay_factor = 100;
    80002072:	896a                	mv	s2,s10
    80002074:	a03d                	j	800020a2 <cfs_scheduler+0x9e>
      decay_factor = 125;
    80002076:	8966                	mv	s2,s9
    80002078:	a02d                	j	800020a2 <cfs_scheduler+0x9e>
    release(&p->lock);
    8000207a:	8526                	mv	a0,s1
    8000207c:	fffff097          	auipc	ra,0xfffff
    80002080:	c0e080e7          	jalr	-1010(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++){
    80002084:	1b048493          	addi	s1,s1,432
    80002088:	03348e63          	beq	s1,s3,800020c4 <cfs_scheduler+0xc0>
    acquire(&p->lock);
    8000208c:	8526                	mv	a0,s1
    8000208e:	fffff097          	auipc	ra,0xfffff
    80002092:	b48080e7          	jalr	-1208(ra) # 80000bd6 <acquire>
    switch (p->cfs_priority){
    80002096:	58bc                	lw	a5,112(s1)
    80002098:	fd678de3          	beq	a5,s6,80002072 <cfs_scheduler+0x6e>
    8000209c:	fd578de3          	beq	a5,s5,80002076 <cfs_scheduler+0x72>
    800020a0:	d7f9                	beqz	a5,8000206e <cfs_scheduler+0x6a>
    vruntime = decay_factor * ((p->rtime) / (p->rtime + p->stime + p->retime));
    800020a2:	58fc                	lw	a5,116(s1)
    800020a4:	5cb8                	lw	a4,120(s1)
    800020a6:	5cf0                	lw	a2,124(s1)
    if (p->state == RUNNABLE && vruntime < min_vruntime){
    800020a8:	4c94                	lw	a3,24(s1)
    800020aa:	fd4698e3          	bne	a3,s4,8000207a <cfs_scheduler+0x76>
    vruntime = decay_factor * ((p->rtime) / (p->rtime + p->stime + p->retime));
    800020ae:	9f3d                	addw	a4,a4,a5
    800020b0:	9f31                	addw	a4,a4,a2
    800020b2:	02e7c7bb          	divw	a5,a5,a4
    800020b6:	032787bb          	mulw	a5,a5,s2
    if (p->state == RUNNABLE && vruntime < min_vruntime){
    800020ba:	fd77d0e3          	bge	a5,s7,8000207a <cfs_scheduler+0x76>
      min_vruntime = vruntime;
    800020be:	8bbe                	mv	s7,a5
    if (p->state == RUNNABLE && vruntime < min_vruntime){
    800020c0:	8da6                	mv	s11,s1
    800020c2:	bf65                	j	8000207a <cfs_scheduler+0x76>
  if (min_proc != 0){
    800020c4:	020d8263          	beqz	s11,800020e8 <cfs_scheduler+0xe4>
    acquire(&min_proc->lock);
    800020c8:	84ee                	mv	s1,s11
    800020ca:	856e                	mv	a0,s11
    800020cc:	fffff097          	auipc	ra,0xfffff
    800020d0:	b0a080e7          	jalr	-1270(ra) # 80000bd6 <acquire>
    if (min_proc->state == RUNNABLE)
    800020d4:	018da703          	lw	a4,24(s11)
    800020d8:	478d                	li	a5,3
    800020da:	02f70663          	beq	a4,a5,80002106 <cfs_scheduler+0x102>
    release(&min_proc->lock);
    800020de:	8526                	mv	a0,s1
    800020e0:	fffff097          	auipc	ra,0xfffff
    800020e4:	baa080e7          	jalr	-1110(ra) # 80000c8a <release>
}
    800020e8:	70e6                	ld	ra,120(sp)
    800020ea:	7446                	ld	s0,112(sp)
    800020ec:	74a6                	ld	s1,104(sp)
    800020ee:	7906                	ld	s2,96(sp)
    800020f0:	69e6                	ld	s3,88(sp)
    800020f2:	6a46                	ld	s4,80(sp)
    800020f4:	6aa6                	ld	s5,72(sp)
    800020f6:	6b06                	ld	s6,64(sp)
    800020f8:	7be2                	ld	s7,56(sp)
    800020fa:	7c42                	ld	s8,48(sp)
    800020fc:	7ca2                	ld	s9,40(sp)
    800020fe:	7d02                	ld	s10,32(sp)
    80002100:	6de2                	ld	s11,24(sp)
    80002102:	6109                	addi	sp,sp,128
    80002104:	8082                	ret
      min_proc->state = RUNNING;
    80002106:	4791                	li	a5,4
    80002108:	00fdac23          	sw	a5,24(s11)
      c->proc = min_proc;
    8000210c:	f8843783          	ld	a5,-120(s0)
    80002110:	079e                	slli	a5,a5,0x7
    80002112:	0000f917          	auipc	s2,0xf
    80002116:	a8e90913          	addi	s2,s2,-1394 # 80010ba0 <pid_lock>
    8000211a:	993e                	add	s2,s2,a5
    8000211c:	03b93823          	sd	s11,48(s2)
      swtch(&c->context, &min_proc->context);
    80002120:	0a8d8593          	addi	a1,s11,168
    80002124:	0000f517          	auipc	a0,0xf
    80002128:	ab450513          	addi	a0,a0,-1356 # 80010bd8 <cpus+0x8>
    8000212c:	953e                	add	a0,a0,a5
    8000212e:	00001097          	auipc	ra,0x1
    80002132:	958080e7          	jalr	-1704(ra) # 80002a86 <swtch>
      c->proc = 0;
    80002136:	02093823          	sd	zero,48(s2)
    8000213a:	b755                	j	800020de <cfs_scheduler+0xda>

000000008000213c <original_scheduler>:
void original_scheduler(void){
    8000213c:	7139                	addi	sp,sp,-64
    8000213e:	fc06                	sd	ra,56(sp)
    80002140:	f822                	sd	s0,48(sp)
    80002142:	f426                	sd	s1,40(sp)
    80002144:	f04a                	sd	s2,32(sp)
    80002146:	ec4e                	sd	s3,24(sp)
    80002148:	e852                	sd	s4,16(sp)
    8000214a:	e456                	sd	s5,8(sp)
    8000214c:	e05a                	sd	s6,0(sp)
    8000214e:	0080                	addi	s0,sp,64
    80002150:	8792                	mv	a5,tp
  int id = r_tp();
    80002152:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002154:	00779a93          	slli	s5,a5,0x7
    80002158:	0000f717          	auipc	a4,0xf
    8000215c:	a4870713          	addi	a4,a4,-1464 # 80010ba0 <pid_lock>
    80002160:	9756                	add	a4,a4,s5
    80002162:	02073823          	sd	zero,48(a4)
      swtch(&c->context, &p->context);
    80002166:	0000f717          	auipc	a4,0xf
    8000216a:	a7270713          	addi	a4,a4,-1422 # 80010bd8 <cpus+0x8>
    8000216e:	9aba                	add	s5,s5,a4
  for (p = proc; p < &proc[NPROC]; p++){
    80002170:	0000f497          	auipc	s1,0xf
    80002174:	e6048493          	addi	s1,s1,-416 # 80010fd0 <proc>
    if (p->state == RUNNABLE){
    80002178:	498d                	li	s3,3
      p->state = RUNNING;
    8000217a:	4b11                	li	s6,4
      c->proc = p;
    8000217c:	079e                	slli	a5,a5,0x7
    8000217e:	0000fa17          	auipc	s4,0xf
    80002182:	a22a0a13          	addi	s4,s4,-1502 # 80010ba0 <pid_lock>
    80002186:	9a3e                	add	s4,s4,a5
  for (p = proc; p < &proc[NPROC]; p++){
    80002188:	00016917          	auipc	s2,0x16
    8000218c:	a4890913          	addi	s2,s2,-1464 # 80017bd0 <tickslock>
    80002190:	a811                	j	800021a4 <original_scheduler+0x68>
    release(&p->lock);
    80002192:	8526                	mv	a0,s1
    80002194:	fffff097          	auipc	ra,0xfffff
    80002198:	af6080e7          	jalr	-1290(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++){
    8000219c:	1b048493          	addi	s1,s1,432
    800021a0:	03248863          	beq	s1,s2,800021d0 <original_scheduler+0x94>
    acquire(&p->lock);
    800021a4:	8526                	mv	a0,s1
    800021a6:	fffff097          	auipc	ra,0xfffff
    800021aa:	a30080e7          	jalr	-1488(ra) # 80000bd6 <acquire>
    if (p->state == RUNNABLE){
    800021ae:	4c9c                	lw	a5,24(s1)
    800021b0:	ff3791e3          	bne	a5,s3,80002192 <original_scheduler+0x56>
      p->state = RUNNING;
    800021b4:	0164ac23          	sw	s6,24(s1)
      c->proc = p;
    800021b8:	029a3823          	sd	s1,48(s4)
      swtch(&c->context, &p->context);
    800021bc:	0a848593          	addi	a1,s1,168
    800021c0:	8556                	mv	a0,s5
    800021c2:	00001097          	auipc	ra,0x1
    800021c6:	8c4080e7          	jalr	-1852(ra) # 80002a86 <swtch>
      c->proc = 0;
    800021ca:	020a3823          	sd	zero,48(s4)
    800021ce:	b7d1                	j	80002192 <original_scheduler+0x56>
}
    800021d0:	70e2                	ld	ra,56(sp)
    800021d2:	7442                	ld	s0,48(sp)
    800021d4:	74a2                	ld	s1,40(sp)
    800021d6:	7902                	ld	s2,32(sp)
    800021d8:	69e2                	ld	s3,24(sp)
    800021da:	6a42                	ld	s4,16(sp)
    800021dc:	6aa2                	ld	s5,8(sp)
    800021de:	6b02                	ld	s6,0(sp)
    800021e0:	6121                	addi	sp,sp,64
    800021e2:	8082                	ret

00000000800021e4 <scheduler>:
{
    800021e4:	7179                	addi	sp,sp,-48
    800021e6:	f406                	sd	ra,40(sp)
    800021e8:	f022                	sd	s0,32(sp)
    800021ea:	ec26                	sd	s1,24(sp)
    800021ec:	e84a                	sd	s2,16(sp)
    800021ee:	e44e                	sd	s3,8(sp)
    800021f0:	1800                	addi	s0,sp,48
    if (sched_policy == 0)
    800021f2:	00006497          	auipc	s1,0x6
    800021f6:	6a648493          	addi	s1,s1,1702 # 80008898 <sched_policy>
    if (sched_policy == 1)
    800021fa:	4985                	li	s3,1
    if (sched_policy == 2)
    800021fc:	4909                	li	s2,2
    800021fe:	a039                	j	8000220c <scheduler+0x28>
    if (sched_policy == 1)
    80002200:	409c                	lw	a5,0(s1)
    80002202:	03378263          	beq	a5,s3,80002226 <scheduler+0x42>
    if (sched_policy == 2)
    80002206:	409c                	lw	a5,0(s1)
    80002208:	03278463          	beq	a5,s2,80002230 <scheduler+0x4c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000220c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002210:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002214:	10079073          	csrw	sstatus,a5
    if (sched_policy == 0)
    80002218:	409c                	lw	a5,0(s1)
    8000221a:	f3fd                	bnez	a5,80002200 <scheduler+0x1c>
      original_scheduler();
    8000221c:	00000097          	auipc	ra,0x0
    80002220:	f20080e7          	jalr	-224(ra) # 8000213c <original_scheduler>
    80002224:	bff1                	j	80002200 <scheduler+0x1c>
      ps_scheduler();
    80002226:	00000097          	auipc	ra,0x0
    8000222a:	c9a080e7          	jalr	-870(ra) # 80001ec0 <ps_scheduler>
    8000222e:	bfe1                	j	80002206 <scheduler+0x22>
      cfs_scheduler();
    80002230:	00000097          	auipc	ra,0x0
    80002234:	dd4080e7          	jalr	-556(ra) # 80002004 <cfs_scheduler>
    80002238:	bfd1                	j	8000220c <scheduler+0x28>

000000008000223a <sched>:
{
    8000223a:	7179                	addi	sp,sp,-48
    8000223c:	f406                	sd	ra,40(sp)
    8000223e:	f022                	sd	s0,32(sp)
    80002240:	ec26                	sd	s1,24(sp)
    80002242:	e84a                	sd	s2,16(sp)
    80002244:	e44e                	sd	s3,8(sp)
    80002246:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002248:	fffff097          	auipc	ra,0xfffff
    8000224c:	782080e7          	jalr	1922(ra) # 800019ca <myproc>
    80002250:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80002252:	fffff097          	auipc	ra,0xfffff
    80002256:	90a080e7          	jalr	-1782(ra) # 80000b5c <holding>
    8000225a:	c93d                	beqz	a0,800022d0 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000225c:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    8000225e:	2781                	sext.w	a5,a5
    80002260:	079e                	slli	a5,a5,0x7
    80002262:	0000f717          	auipc	a4,0xf
    80002266:	93e70713          	addi	a4,a4,-1730 # 80010ba0 <pid_lock>
    8000226a:	97ba                	add	a5,a5,a4
    8000226c:	0a87a703          	lw	a4,168(a5)
    80002270:	4785                	li	a5,1
    80002272:	06f71763          	bne	a4,a5,800022e0 <sched+0xa6>
  if (p->state == RUNNING)
    80002276:	4c98                	lw	a4,24(s1)
    80002278:	4791                	li	a5,4
    8000227a:	06f70b63          	beq	a4,a5,800022f0 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000227e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002282:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002284:	efb5                	bnez	a5,80002300 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002286:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002288:	0000f917          	auipc	s2,0xf
    8000228c:	91890913          	addi	s2,s2,-1768 # 80010ba0 <pid_lock>
    80002290:	2781                	sext.w	a5,a5
    80002292:	079e                	slli	a5,a5,0x7
    80002294:	97ca                	add	a5,a5,s2
    80002296:	0ac7a983          	lw	s3,172(a5)
    8000229a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000229c:	2781                	sext.w	a5,a5
    8000229e:	079e                	slli	a5,a5,0x7
    800022a0:	0000f597          	auipc	a1,0xf
    800022a4:	93858593          	addi	a1,a1,-1736 # 80010bd8 <cpus+0x8>
    800022a8:	95be                	add	a1,a1,a5
    800022aa:	0a848513          	addi	a0,s1,168
    800022ae:	00000097          	auipc	ra,0x0
    800022b2:	7d8080e7          	jalr	2008(ra) # 80002a86 <swtch>
    800022b6:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800022b8:	2781                	sext.w	a5,a5
    800022ba:	079e                	slli	a5,a5,0x7
    800022bc:	97ca                	add	a5,a5,s2
    800022be:	0b37a623          	sw	s3,172(a5)
}
    800022c2:	70a2                	ld	ra,40(sp)
    800022c4:	7402                	ld	s0,32(sp)
    800022c6:	64e2                	ld	s1,24(sp)
    800022c8:	6942                	ld	s2,16(sp)
    800022ca:	69a2                	ld	s3,8(sp)
    800022cc:	6145                	addi	sp,sp,48
    800022ce:	8082                	ret
    panic("sched p->lock");
    800022d0:	00006517          	auipc	a0,0x6
    800022d4:	f5050513          	addi	a0,a0,-176 # 80008220 <digits+0x1e0>
    800022d8:	ffffe097          	auipc	ra,0xffffe
    800022dc:	266080e7          	jalr	614(ra) # 8000053e <panic>
    panic("sched locks");
    800022e0:	00006517          	auipc	a0,0x6
    800022e4:	f5050513          	addi	a0,a0,-176 # 80008230 <digits+0x1f0>
    800022e8:	ffffe097          	auipc	ra,0xffffe
    800022ec:	256080e7          	jalr	598(ra) # 8000053e <panic>
    panic("sched running");
    800022f0:	00006517          	auipc	a0,0x6
    800022f4:	f5050513          	addi	a0,a0,-176 # 80008240 <digits+0x200>
    800022f8:	ffffe097          	auipc	ra,0xffffe
    800022fc:	246080e7          	jalr	582(ra) # 8000053e <panic>
    panic("sched interruptible");
    80002300:	00006517          	auipc	a0,0x6
    80002304:	f5050513          	addi	a0,a0,-176 # 80008250 <digits+0x210>
    80002308:	ffffe097          	auipc	ra,0xffffe
    8000230c:	236080e7          	jalr	566(ra) # 8000053e <panic>

0000000080002310 <yield>:
{
    80002310:	1101                	addi	sp,sp,-32
    80002312:	ec06                	sd	ra,24(sp)
    80002314:	e822                	sd	s0,16(sp)
    80002316:	e426                	sd	s1,8(sp)
    80002318:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000231a:	fffff097          	auipc	ra,0xfffff
    8000231e:	6b0080e7          	jalr	1712(ra) # 800019ca <myproc>
    80002322:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002324:	fffff097          	auipc	ra,0xfffff
    80002328:	8b2080e7          	jalr	-1870(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    8000232c:	478d                	li	a5,3
    8000232e:	cc9c                	sw	a5,24(s1)
  sched();
    80002330:	00000097          	auipc	ra,0x0
    80002334:	f0a080e7          	jalr	-246(ra) # 8000223a <sched>
  release(&p->lock);
    80002338:	8526                	mv	a0,s1
    8000233a:	fffff097          	auipc	ra,0xfffff
    8000233e:	950080e7          	jalr	-1712(ra) # 80000c8a <release>
}
    80002342:	60e2                	ld	ra,24(sp)
    80002344:	6442                	ld	s0,16(sp)
    80002346:	64a2                	ld	s1,8(sp)
    80002348:	6105                	addi	sp,sp,32
    8000234a:	8082                	ret

000000008000234c <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    8000234c:	7179                	addi	sp,sp,-48
    8000234e:	f406                	sd	ra,40(sp)
    80002350:	f022                	sd	s0,32(sp)
    80002352:	ec26                	sd	s1,24(sp)
    80002354:	e84a                	sd	s2,16(sp)
    80002356:	e44e                	sd	s3,8(sp)
    80002358:	1800                	addi	s0,sp,48
    8000235a:	89aa                	mv	s3,a0
    8000235c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000235e:	fffff097          	auipc	ra,0xfffff
    80002362:	66c080e7          	jalr	1644(ra) # 800019ca <myproc>
    80002366:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    80002368:	fffff097          	auipc	ra,0xfffff
    8000236c:	86e080e7          	jalr	-1938(ra) # 80000bd6 <acquire>
  release(lk);
    80002370:	854a                	mv	a0,s2
    80002372:	fffff097          	auipc	ra,0xfffff
    80002376:	918080e7          	jalr	-1768(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    8000237a:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000237e:	4789                	li	a5,2
    80002380:	cc9c                	sw	a5,24(s1)

  sched();
    80002382:	00000097          	auipc	ra,0x0
    80002386:	eb8080e7          	jalr	-328(ra) # 8000223a <sched>

  // Tidy up.
  p->chan = 0;
    8000238a:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000238e:	8526                	mv	a0,s1
    80002390:	fffff097          	auipc	ra,0xfffff
    80002394:	8fa080e7          	jalr	-1798(ra) # 80000c8a <release>
  acquire(lk);
    80002398:	854a                	mv	a0,s2
    8000239a:	fffff097          	auipc	ra,0xfffff
    8000239e:	83c080e7          	jalr	-1988(ra) # 80000bd6 <acquire>
}
    800023a2:	70a2                	ld	ra,40(sp)
    800023a4:	7402                	ld	s0,32(sp)
    800023a6:	64e2                	ld	s1,24(sp)
    800023a8:	6942                	ld	s2,16(sp)
    800023aa:	69a2                	ld	s3,8(sp)
    800023ac:	6145                	addi	sp,sp,48
    800023ae:	8082                	ret

00000000800023b0 <cfs_update>:

void cfs_update()
{
    800023b0:	7139                	addi	sp,sp,-64
    800023b2:	fc06                	sd	ra,56(sp)
    800023b4:	f822                	sd	s0,48(sp)
    800023b6:	f426                	sd	s1,40(sp)
    800023b8:	f04a                	sd	s2,32(sp)
    800023ba:	ec4e                	sd	s3,24(sp)
    800023bc:	e852                	sd	s4,16(sp)
    800023be:	e456                	sd	s5,8(sp)
    800023c0:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    800023c2:	fffff097          	auipc	ra,0xfffff
    800023c6:	608080e7          	jalr	1544(ra) # 800019ca <myproc>

  for (p = proc; p < &proc[NPROC]; p++)
    800023ca:	0000f497          	auipc	s1,0xf
    800023ce:	c0648493          	addi	s1,s1,-1018 # 80010fd0 <proc>
  {
    acquire(&p->lock);
    if (p->state == RUNNABLE)
    800023d2:	498d                	li	s3,3
    {
      p->retime++;
    }
    else if (p->state == SLEEPING)
    800023d4:	4a09                	li	s4,2
    {
      p->stime++;
    }
    else if (p->state == RUNNING)
    800023d6:	4a91                	li	s5,4
  for (p = proc; p < &proc[NPROC]; p++)
    800023d8:	00015917          	auipc	s2,0x15
    800023dc:	7f890913          	addi	s2,s2,2040 # 80017bd0 <tickslock>
    800023e0:	a829                	j	800023fa <cfs_update+0x4a>
      p->retime++;
    800023e2:	5cfc                	lw	a5,124(s1)
    800023e4:	2785                	addiw	a5,a5,1
    800023e6:	dcfc                	sw	a5,124(s1)
    {
      p->rtime++;
    }
    release(&p->lock);
    800023e8:	8526                	mv	a0,s1
    800023ea:	fffff097          	auipc	ra,0xfffff
    800023ee:	8a0080e7          	jalr	-1888(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800023f2:	1b048493          	addi	s1,s1,432
    800023f6:	03248663          	beq	s1,s2,80002422 <cfs_update+0x72>
    acquire(&p->lock);
    800023fa:	8526                	mv	a0,s1
    800023fc:	ffffe097          	auipc	ra,0xffffe
    80002400:	7da080e7          	jalr	2010(ra) # 80000bd6 <acquire>
    if (p->state == RUNNABLE)
    80002404:	4c9c                	lw	a5,24(s1)
    80002406:	fd378ee3          	beq	a5,s3,800023e2 <cfs_update+0x32>
    else if (p->state == SLEEPING)
    8000240a:	01478863          	beq	a5,s4,8000241a <cfs_update+0x6a>
    else if (p->state == RUNNING)
    8000240e:	fd579de3          	bne	a5,s5,800023e8 <cfs_update+0x38>
      p->rtime++;
    80002412:	58fc                	lw	a5,116(s1)
    80002414:	2785                	addiw	a5,a5,1
    80002416:	d8fc                	sw	a5,116(s1)
    80002418:	bfc1                	j	800023e8 <cfs_update+0x38>
      p->stime++;
    8000241a:	5cbc                	lw	a5,120(s1)
    8000241c:	2785                	addiw	a5,a5,1
    8000241e:	dcbc                	sw	a5,120(s1)
    80002420:	b7e1                	j	800023e8 <cfs_update+0x38>
  }
}
    80002422:	70e2                	ld	ra,56(sp)
    80002424:	7442                	ld	s0,48(sp)
    80002426:	74a2                	ld	s1,40(sp)
    80002428:	7902                	ld	s2,32(sp)
    8000242a:	69e2                	ld	s3,24(sp)
    8000242c:	6a42                	ld	s4,16(sp)
    8000242e:	6aa2                	ld	s5,8(sp)
    80002430:	6121                	addi	sp,sp,64
    80002432:	8082                	ret

0000000080002434 <wakeup>:
// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    80002434:	7139                	addi	sp,sp,-64
    80002436:	fc06                	sd	ra,56(sp)
    80002438:	f822                	sd	s0,48(sp)
    8000243a:	f426                	sd	s1,40(sp)
    8000243c:	f04a                	sd	s2,32(sp)
    8000243e:	ec4e                	sd	s3,24(sp)
    80002440:	e852                	sd	s4,16(sp)
    80002442:	e456                	sd	s5,8(sp)
    80002444:	e05a                	sd	s6,0(sp)
    80002446:	0080                	addi	s0,sp,64
    80002448:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000244a:	0000f497          	auipc	s1,0xf
    8000244e:	b8648493          	addi	s1,s1,-1146 # 80010fd0 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    80002452:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    80002454:	4b0d                	li	s6,3
        p->accumulator = min_accumulator;
    80002456:	00006a97          	auipc	s5,0x6
    8000245a:	446a8a93          	addi	s5,s5,1094 # 8000889c <min_accumulator>
  for (p = proc; p < &proc[NPROC]; p++)
    8000245e:	00015917          	auipc	s2,0x15
    80002462:	77290913          	addi	s2,s2,1906 # 80017bd0 <tickslock>
    80002466:	a811                	j	8000247a <wakeup+0x46>
      //   p->stime++;
      // }
      // else if (p->state==RUNNING){
      //   p->rtime++;
      // }
      release(&p->lock);
    80002468:	8526                	mv	a0,s1
    8000246a:	fffff097          	auipc	ra,0xfffff
    8000246e:	820080e7          	jalr	-2016(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002472:	1b048493          	addi	s1,s1,432
    80002476:	03248963          	beq	s1,s2,800024a8 <wakeup+0x74>
    if (p != myproc())
    8000247a:	fffff097          	auipc	ra,0xfffff
    8000247e:	550080e7          	jalr	1360(ra) # 800019ca <myproc>
    80002482:	fea488e3          	beq	s1,a0,80002472 <wakeup+0x3e>
      acquire(&p->lock);
    80002486:	8526                	mv	a0,s1
    80002488:	ffffe097          	auipc	ra,0xffffe
    8000248c:	74e080e7          	jalr	1870(ra) # 80000bd6 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    80002490:	4c9c                	lw	a5,24(s1)
    80002492:	fd379be3          	bne	a5,s3,80002468 <wakeup+0x34>
    80002496:	709c                	ld	a5,32(s1)
    80002498:	fd4798e3          	bne	a5,s4,80002468 <wakeup+0x34>
        p->state = RUNNABLE;
    8000249c:	0164ac23          	sw	s6,24(s1)
        p->accumulator = min_accumulator;
    800024a0:	000aa783          	lw	a5,0(s5)
    800024a4:	f0bc                	sd	a5,96(s1)
    800024a6:	b7c9                	j	80002468 <wakeup+0x34>
    }
  }
}
    800024a8:	70e2                	ld	ra,56(sp)
    800024aa:	7442                	ld	s0,48(sp)
    800024ac:	74a2                	ld	s1,40(sp)
    800024ae:	7902                	ld	s2,32(sp)
    800024b0:	69e2                	ld	s3,24(sp)
    800024b2:	6a42                	ld	s4,16(sp)
    800024b4:	6aa2                	ld	s5,8(sp)
    800024b6:	6b02                	ld	s6,0(sp)
    800024b8:	6121                	addi	sp,sp,64
    800024ba:	8082                	ret

00000000800024bc <reparent>:
{
    800024bc:	7179                	addi	sp,sp,-48
    800024be:	f406                	sd	ra,40(sp)
    800024c0:	f022                	sd	s0,32(sp)
    800024c2:	ec26                	sd	s1,24(sp)
    800024c4:	e84a                	sd	s2,16(sp)
    800024c6:	e44e                	sd	s3,8(sp)
    800024c8:	e052                	sd	s4,0(sp)
    800024ca:	1800                	addi	s0,sp,48
    800024cc:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800024ce:	0000f497          	auipc	s1,0xf
    800024d2:	b0248493          	addi	s1,s1,-1278 # 80010fd0 <proc>
      pp->parent = initproc;
    800024d6:	00006a17          	auipc	s4,0x6
    800024da:	452a0a13          	addi	s4,s4,1106 # 80008928 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800024de:	00015997          	auipc	s3,0x15
    800024e2:	6f298993          	addi	s3,s3,1778 # 80017bd0 <tickslock>
    800024e6:	a029                	j	800024f0 <reparent+0x34>
    800024e8:	1b048493          	addi	s1,s1,432
    800024ec:	01348d63          	beq	s1,s3,80002506 <reparent+0x4a>
    if (pp->parent == p)
    800024f0:	7c9c                	ld	a5,56(s1)
    800024f2:	ff279be3          	bne	a5,s2,800024e8 <reparent+0x2c>
      pp->parent = initproc;
    800024f6:	000a3503          	ld	a0,0(s4)
    800024fa:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800024fc:	00000097          	auipc	ra,0x0
    80002500:	f38080e7          	jalr	-200(ra) # 80002434 <wakeup>
    80002504:	b7d5                	j	800024e8 <reparent+0x2c>
}
    80002506:	70a2                	ld	ra,40(sp)
    80002508:	7402                	ld	s0,32(sp)
    8000250a:	64e2                	ld	s1,24(sp)
    8000250c:	6942                	ld	s2,16(sp)
    8000250e:	69a2                	ld	s3,8(sp)
    80002510:	6a02                	ld	s4,0(sp)
    80002512:	6145                	addi	sp,sp,48
    80002514:	8082                	ret

0000000080002516 <exit>:
{
    80002516:	7139                	addi	sp,sp,-64
    80002518:	fc06                	sd	ra,56(sp)
    8000251a:	f822                	sd	s0,48(sp)
    8000251c:	f426                	sd	s1,40(sp)
    8000251e:	f04a                	sd	s2,32(sp)
    80002520:	ec4e                	sd	s3,24(sp)
    80002522:	e852                	sd	s4,16(sp)
    80002524:	e456                	sd	s5,8(sp)
    80002526:	0080                	addi	s0,sp,64
    80002528:	8a2a                	mv	s4,a0
    8000252a:	8aae                	mv	s5,a1
  struct proc *p = myproc();
    8000252c:	fffff097          	auipc	ra,0xfffff
    80002530:	49e080e7          	jalr	1182(ra) # 800019ca <myproc>
    80002534:	89aa                	mv	s3,a0
  if (p == initproc)
    80002536:	00006797          	auipc	a5,0x6
    8000253a:	3f27b783          	ld	a5,1010(a5) # 80008928 <initproc>
    8000253e:	11850493          	addi	s1,a0,280
    80002542:	19850913          	addi	s2,a0,408
    80002546:	02a79363          	bne	a5,a0,8000256c <exit+0x56>
    panic("init exiting");
    8000254a:	00006517          	auipc	a0,0x6
    8000254e:	d1e50513          	addi	a0,a0,-738 # 80008268 <digits+0x228>
    80002552:	ffffe097          	auipc	ra,0xffffe
    80002556:	fec080e7          	jalr	-20(ra) # 8000053e <panic>
      fileclose(f);
    8000255a:	00002097          	auipc	ra,0x2
    8000255e:	570080e7          	jalr	1392(ra) # 80004aca <fileclose>
      p->ofile[fd] = 0;
    80002562:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    80002566:	04a1                	addi	s1,s1,8
    80002568:	01248563          	beq	s1,s2,80002572 <exit+0x5c>
    if (p->ofile[fd])
    8000256c:	6088                	ld	a0,0(s1)
    8000256e:	f575                	bnez	a0,8000255a <exit+0x44>
    80002570:	bfdd                	j	80002566 <exit+0x50>
  begin_op();
    80002572:	00002097          	auipc	ra,0x2
    80002576:	08c080e7          	jalr	140(ra) # 800045fe <begin_op>
  iput(p->cwd);
    8000257a:	1989b503          	ld	a0,408(s3)
    8000257e:	00002097          	auipc	ra,0x2
    80002582:	878080e7          	jalr	-1928(ra) # 80003df6 <iput>
  end_op();
    80002586:	00002097          	auipc	ra,0x2
    8000258a:	0f8080e7          	jalr	248(ra) # 8000467e <end_op>
  p->cwd = 0;
    8000258e:	1809bc23          	sd	zero,408(s3)
  acquire(&wait_lock);
    80002592:	0000e497          	auipc	s1,0xe
    80002596:	62648493          	addi	s1,s1,1574 # 80010bb8 <wait_lock>
    8000259a:	8526                	mv	a0,s1
    8000259c:	ffffe097          	auipc	ra,0xffffe
    800025a0:	63a080e7          	jalr	1594(ra) # 80000bd6 <acquire>
  reparent(p);
    800025a4:	854e                	mv	a0,s3
    800025a6:	00000097          	auipc	ra,0x0
    800025aa:	f16080e7          	jalr	-234(ra) # 800024bc <reparent>
  wakeup(p->parent);
    800025ae:	0389b503          	ld	a0,56(s3)
    800025b2:	00000097          	auipc	ra,0x0
    800025b6:	e82080e7          	jalr	-382(ra) # 80002434 <wakeup>
  acquire(&p->lock);
    800025ba:	854e                	mv	a0,s3
    800025bc:	ffffe097          	auipc	ra,0xffffe
    800025c0:	61a080e7          	jalr	1562(ra) # 80000bd6 <acquire>
  safestrcpy(p->exit_msg, msg, sizeof(p->exit_msg)); // Copy string to process PCB
    800025c4:	02000613          	li	a2,32
    800025c8:	85d6                	mv	a1,s5
    800025ca:	04098513          	addi	a0,s3,64
    800025ce:	fffff097          	auipc	ra,0xfffff
    800025d2:	84e080e7          	jalr	-1970(ra) # 80000e1c <safestrcpy>
  p->xstate = status;
    800025d6:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800025da:	4795                	li	a5,5
    800025dc:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800025e0:	8526                	mv	a0,s1
    800025e2:	ffffe097          	auipc	ra,0xffffe
    800025e6:	6a8080e7          	jalr	1704(ra) # 80000c8a <release>
  sched();
    800025ea:	00000097          	auipc	ra,0x0
    800025ee:	c50080e7          	jalr	-944(ra) # 8000223a <sched>
  panic("zombie exit");
    800025f2:	00006517          	auipc	a0,0x6
    800025f6:	c8650513          	addi	a0,a0,-890 # 80008278 <digits+0x238>
    800025fa:	ffffe097          	auipc	ra,0xffffe
    800025fe:	f44080e7          	jalr	-188(ra) # 8000053e <panic>

0000000080002602 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002602:	7179                	addi	sp,sp,-48
    80002604:	f406                	sd	ra,40(sp)
    80002606:	f022                	sd	s0,32(sp)
    80002608:	ec26                	sd	s1,24(sp)
    8000260a:	e84a                	sd	s2,16(sp)
    8000260c:	e44e                	sd	s3,8(sp)
    8000260e:	1800                	addi	s0,sp,48
    80002610:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002612:	0000f497          	auipc	s1,0xf
    80002616:	9be48493          	addi	s1,s1,-1602 # 80010fd0 <proc>
    8000261a:	00015997          	auipc	s3,0x15
    8000261e:	5b698993          	addi	s3,s3,1462 # 80017bd0 <tickslock>
  {
    acquire(&p->lock);
    80002622:	8526                	mv	a0,s1
    80002624:	ffffe097          	auipc	ra,0xffffe
    80002628:	5b2080e7          	jalr	1458(ra) # 80000bd6 <acquire>
    if (p->pid == pid)
    8000262c:	589c                	lw	a5,48(s1)
    8000262e:	01278d63          	beq	a5,s2,80002648 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002632:	8526                	mv	a0,s1
    80002634:	ffffe097          	auipc	ra,0xffffe
    80002638:	656080e7          	jalr	1622(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    8000263c:	1b048493          	addi	s1,s1,432
    80002640:	ff3491e3          	bne	s1,s3,80002622 <kill+0x20>
  }
  return -1;
    80002644:	557d                	li	a0,-1
    80002646:	a829                	j	80002660 <kill+0x5e>
      p->killed = 1;
    80002648:	4785                	li	a5,1
    8000264a:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    8000264c:	4c98                	lw	a4,24(s1)
    8000264e:	4789                	li	a5,2
    80002650:	00f70f63          	beq	a4,a5,8000266e <kill+0x6c>
      release(&p->lock);
    80002654:	8526                	mv	a0,s1
    80002656:	ffffe097          	auipc	ra,0xffffe
    8000265a:	634080e7          	jalr	1588(ra) # 80000c8a <release>
      return 0;
    8000265e:	4501                	li	a0,0
}
    80002660:	70a2                	ld	ra,40(sp)
    80002662:	7402                	ld	s0,32(sp)
    80002664:	64e2                	ld	s1,24(sp)
    80002666:	6942                	ld	s2,16(sp)
    80002668:	69a2                	ld	s3,8(sp)
    8000266a:	6145                	addi	sp,sp,48
    8000266c:	8082                	ret
        p->state = RUNNABLE;
    8000266e:	478d                	li	a5,3
    80002670:	cc9c                	sw	a5,24(s1)
    80002672:	b7cd                	j	80002654 <kill+0x52>

0000000080002674 <setkilled>:

void setkilled(struct proc *p)
{
    80002674:	1101                	addi	sp,sp,-32
    80002676:	ec06                	sd	ra,24(sp)
    80002678:	e822                	sd	s0,16(sp)
    8000267a:	e426                	sd	s1,8(sp)
    8000267c:	1000                	addi	s0,sp,32
    8000267e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002680:	ffffe097          	auipc	ra,0xffffe
    80002684:	556080e7          	jalr	1366(ra) # 80000bd6 <acquire>
  p->killed = 1;
    80002688:	4785                	li	a5,1
    8000268a:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000268c:	8526                	mv	a0,s1
    8000268e:	ffffe097          	auipc	ra,0xffffe
    80002692:	5fc080e7          	jalr	1532(ra) # 80000c8a <release>
}
    80002696:	60e2                	ld	ra,24(sp)
    80002698:	6442                	ld	s0,16(sp)
    8000269a:	64a2                	ld	s1,8(sp)
    8000269c:	6105                	addi	sp,sp,32
    8000269e:	8082                	ret

00000000800026a0 <killed>:

int killed(struct proc *p)
{
    800026a0:	1101                	addi	sp,sp,-32
    800026a2:	ec06                	sd	ra,24(sp)
    800026a4:	e822                	sd	s0,16(sp)
    800026a6:	e426                	sd	s1,8(sp)
    800026a8:	e04a                	sd	s2,0(sp)
    800026aa:	1000                	addi	s0,sp,32
    800026ac:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800026ae:	ffffe097          	auipc	ra,0xffffe
    800026b2:	528080e7          	jalr	1320(ra) # 80000bd6 <acquire>
  k = p->killed;
    800026b6:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800026ba:	8526                	mv	a0,s1
    800026bc:	ffffe097          	auipc	ra,0xffffe
    800026c0:	5ce080e7          	jalr	1486(ra) # 80000c8a <release>
  return k;
}
    800026c4:	854a                	mv	a0,s2
    800026c6:	60e2                	ld	ra,24(sp)
    800026c8:	6442                	ld	s0,16(sp)
    800026ca:	64a2                	ld	s1,8(sp)
    800026cc:	6902                	ld	s2,0(sp)
    800026ce:	6105                	addi	sp,sp,32
    800026d0:	8082                	ret

00000000800026d2 <wait>:
{
    800026d2:	711d                	addi	sp,sp,-96
    800026d4:	ec86                	sd	ra,88(sp)
    800026d6:	e8a2                	sd	s0,80(sp)
    800026d8:	e4a6                	sd	s1,72(sp)
    800026da:	e0ca                	sd	s2,64(sp)
    800026dc:	fc4e                	sd	s3,56(sp)
    800026de:	f852                	sd	s4,48(sp)
    800026e0:	f456                	sd	s5,40(sp)
    800026e2:	f05a                	sd	s6,32(sp)
    800026e4:	ec5e                	sd	s7,24(sp)
    800026e6:	e862                	sd	s8,16(sp)
    800026e8:	e466                	sd	s9,8(sp)
    800026ea:	1080                	addi	s0,sp,96
    800026ec:	8baa                	mv	s7,a0
    800026ee:	8b2e                	mv	s6,a1
  struct proc *p = myproc();
    800026f0:	fffff097          	auipc	ra,0xfffff
    800026f4:	2da080e7          	jalr	730(ra) # 800019ca <myproc>
    800026f8:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800026fa:	0000e517          	auipc	a0,0xe
    800026fe:	4be50513          	addi	a0,a0,1214 # 80010bb8 <wait_lock>
    80002702:	ffffe097          	auipc	ra,0xffffe
    80002706:	4d4080e7          	jalr	1236(ra) # 80000bd6 <acquire>
    havekids = 0;
    8000270a:	4c01                	li	s8,0
        if (pp->state == ZOMBIE)
    8000270c:	4a15                	li	s4,5
        havekids = 1;
    8000270e:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002710:	00015997          	auipc	s3,0x15
    80002714:	4c098993          	addi	s3,s3,1216 # 80017bd0 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002718:	0000ec97          	auipc	s9,0xe
    8000271c:	4a0c8c93          	addi	s9,s9,1184 # 80010bb8 <wait_lock>
    havekids = 0;
    80002720:	8762                	mv	a4,s8
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002722:	0000f497          	auipc	s1,0xf
    80002726:	8ae48493          	addi	s1,s1,-1874 # 80010fd0 <proc>
    8000272a:	a06d                	j	800027d4 <wait+0x102>
          pid = pp->pid;
    8000272c:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002730:	040b9463          	bnez	s7,80002778 <wait+0xa6>
          if (dst != 0 && copyout(p->pagetable, dst, (char *)&pp->exit_msg,
    80002734:	000b0f63          	beqz	s6,80002752 <wait+0x80>
    80002738:	02000693          	li	a3,32
    8000273c:	04048613          	addi	a2,s1,64
    80002740:	85da                	mv	a1,s6
    80002742:	09893503          	ld	a0,152(s2)
    80002746:	fffff097          	auipc	ra,0xfffff
    8000274a:	f22080e7          	jalr	-222(ra) # 80001668 <copyout>
    8000274e:	06054063          	bltz	a0,800027ae <wait+0xdc>
          freeproc(pp);
    80002752:	8526                	mv	a0,s1
    80002754:	fffff097          	auipc	ra,0xfffff
    80002758:	428080e7          	jalr	1064(ra) # 80001b7c <freeproc>
          release(&pp->lock);
    8000275c:	8526                	mv	a0,s1
    8000275e:	ffffe097          	auipc	ra,0xffffe
    80002762:	52c080e7          	jalr	1324(ra) # 80000c8a <release>
          release(&wait_lock);
    80002766:	0000e517          	auipc	a0,0xe
    8000276a:	45250513          	addi	a0,a0,1106 # 80010bb8 <wait_lock>
    8000276e:	ffffe097          	auipc	ra,0xffffe
    80002772:	51c080e7          	jalr	1308(ra) # 80000c8a <release>
          return pid;
    80002776:	a04d                	j	80002818 <wait+0x146>
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002778:	4691                	li	a3,4
    8000277a:	02c48613          	addi	a2,s1,44
    8000277e:	85de                	mv	a1,s7
    80002780:	09893503          	ld	a0,152(s2)
    80002784:	fffff097          	auipc	ra,0xfffff
    80002788:	ee4080e7          	jalr	-284(ra) # 80001668 <copyout>
    8000278c:	fa0554e3          	bgez	a0,80002734 <wait+0x62>
            release(&pp->lock);
    80002790:	8526                	mv	a0,s1
    80002792:	ffffe097          	auipc	ra,0xffffe
    80002796:	4f8080e7          	jalr	1272(ra) # 80000c8a <release>
            release(&wait_lock);
    8000279a:	0000e517          	auipc	a0,0xe
    8000279e:	41e50513          	addi	a0,a0,1054 # 80010bb8 <wait_lock>
    800027a2:	ffffe097          	auipc	ra,0xffffe
    800027a6:	4e8080e7          	jalr	1256(ra) # 80000c8a <release>
            return -1;
    800027aa:	59fd                	li	s3,-1
    800027ac:	a0b5                	j	80002818 <wait+0x146>
            release(&pp->lock);
    800027ae:	8526                	mv	a0,s1
    800027b0:	ffffe097          	auipc	ra,0xffffe
    800027b4:	4da080e7          	jalr	1242(ra) # 80000c8a <release>
            release(&wait_lock);
    800027b8:	0000e517          	auipc	a0,0xe
    800027bc:	40050513          	addi	a0,a0,1024 # 80010bb8 <wait_lock>
    800027c0:	ffffe097          	auipc	ra,0xffffe
    800027c4:	4ca080e7          	jalr	1226(ra) # 80000c8a <release>
            return -1;
    800027c8:	59fd                	li	s3,-1
    800027ca:	a0b9                	j	80002818 <wait+0x146>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800027cc:	1b048493          	addi	s1,s1,432
    800027d0:	03348463          	beq	s1,s3,800027f8 <wait+0x126>
      if (pp->parent == p)
    800027d4:	7c9c                	ld	a5,56(s1)
    800027d6:	ff279be3          	bne	a5,s2,800027cc <wait+0xfa>
        acquire(&pp->lock);
    800027da:	8526                	mv	a0,s1
    800027dc:	ffffe097          	auipc	ra,0xffffe
    800027e0:	3fa080e7          	jalr	1018(ra) # 80000bd6 <acquire>
        if (pp->state == ZOMBIE)
    800027e4:	4c9c                	lw	a5,24(s1)
    800027e6:	f54783e3          	beq	a5,s4,8000272c <wait+0x5a>
        release(&pp->lock);
    800027ea:	8526                	mv	a0,s1
    800027ec:	ffffe097          	auipc	ra,0xffffe
    800027f0:	49e080e7          	jalr	1182(ra) # 80000c8a <release>
        havekids = 1;
    800027f4:	8756                	mv	a4,s5
    800027f6:	bfd9                	j	800027cc <wait+0xfa>
    if (!havekids || killed(p))
    800027f8:	c719                	beqz	a4,80002806 <wait+0x134>
    800027fa:	854a                	mv	a0,s2
    800027fc:	00000097          	auipc	ra,0x0
    80002800:	ea4080e7          	jalr	-348(ra) # 800026a0 <killed>
    80002804:	c905                	beqz	a0,80002834 <wait+0x162>
      release(&wait_lock);
    80002806:	0000e517          	auipc	a0,0xe
    8000280a:	3b250513          	addi	a0,a0,946 # 80010bb8 <wait_lock>
    8000280e:	ffffe097          	auipc	ra,0xffffe
    80002812:	47c080e7          	jalr	1148(ra) # 80000c8a <release>
      return -1;
    80002816:	59fd                	li	s3,-1
}
    80002818:	854e                	mv	a0,s3
    8000281a:	60e6                	ld	ra,88(sp)
    8000281c:	6446                	ld	s0,80(sp)
    8000281e:	64a6                	ld	s1,72(sp)
    80002820:	6906                	ld	s2,64(sp)
    80002822:	79e2                	ld	s3,56(sp)
    80002824:	7a42                	ld	s4,48(sp)
    80002826:	7aa2                	ld	s5,40(sp)
    80002828:	7b02                	ld	s6,32(sp)
    8000282a:	6be2                	ld	s7,24(sp)
    8000282c:	6c42                	ld	s8,16(sp)
    8000282e:	6ca2                	ld	s9,8(sp)
    80002830:	6125                	addi	sp,sp,96
    80002832:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002834:	85e6                	mv	a1,s9
    80002836:	854a                	mv	a0,s2
    80002838:	00000097          	auipc	ra,0x0
    8000283c:	b14080e7          	jalr	-1260(ra) # 8000234c <sleep>
    havekids = 0;
    80002840:	b5c5                	j	80002720 <wait+0x4e>

0000000080002842 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002842:	7179                	addi	sp,sp,-48
    80002844:	f406                	sd	ra,40(sp)
    80002846:	f022                	sd	s0,32(sp)
    80002848:	ec26                	sd	s1,24(sp)
    8000284a:	e84a                	sd	s2,16(sp)
    8000284c:	e44e                	sd	s3,8(sp)
    8000284e:	e052                	sd	s4,0(sp)
    80002850:	1800                	addi	s0,sp,48
    80002852:	84aa                	mv	s1,a0
    80002854:	892e                	mv	s2,a1
    80002856:	89b2                	mv	s3,a2
    80002858:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000285a:	fffff097          	auipc	ra,0xfffff
    8000285e:	170080e7          	jalr	368(ra) # 800019ca <myproc>
  if (user_dst)
    80002862:	c08d                	beqz	s1,80002884 <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    80002864:	86d2                	mv	a3,s4
    80002866:	864e                	mv	a2,s3
    80002868:	85ca                	mv	a1,s2
    8000286a:	6d48                	ld	a0,152(a0)
    8000286c:	fffff097          	auipc	ra,0xfffff
    80002870:	dfc080e7          	jalr	-516(ra) # 80001668 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002874:	70a2                	ld	ra,40(sp)
    80002876:	7402                	ld	s0,32(sp)
    80002878:	64e2                	ld	s1,24(sp)
    8000287a:	6942                	ld	s2,16(sp)
    8000287c:	69a2                	ld	s3,8(sp)
    8000287e:	6a02                	ld	s4,0(sp)
    80002880:	6145                	addi	sp,sp,48
    80002882:	8082                	ret
    memmove((char *)dst, src, len);
    80002884:	000a061b          	sext.w	a2,s4
    80002888:	85ce                	mv	a1,s3
    8000288a:	854a                	mv	a0,s2
    8000288c:	ffffe097          	auipc	ra,0xffffe
    80002890:	4a2080e7          	jalr	1186(ra) # 80000d2e <memmove>
    return 0;
    80002894:	8526                	mv	a0,s1
    80002896:	bff9                	j	80002874 <either_copyout+0x32>

0000000080002898 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002898:	7179                	addi	sp,sp,-48
    8000289a:	f406                	sd	ra,40(sp)
    8000289c:	f022                	sd	s0,32(sp)
    8000289e:	ec26                	sd	s1,24(sp)
    800028a0:	e84a                	sd	s2,16(sp)
    800028a2:	e44e                	sd	s3,8(sp)
    800028a4:	e052                	sd	s4,0(sp)
    800028a6:	1800                	addi	s0,sp,48
    800028a8:	892a                	mv	s2,a0
    800028aa:	84ae                	mv	s1,a1
    800028ac:	89b2                	mv	s3,a2
    800028ae:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800028b0:	fffff097          	auipc	ra,0xfffff
    800028b4:	11a080e7          	jalr	282(ra) # 800019ca <myproc>
  if (user_src)
    800028b8:	c08d                	beqz	s1,800028da <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    800028ba:	86d2                	mv	a3,s4
    800028bc:	864e                	mv	a2,s3
    800028be:	85ca                	mv	a1,s2
    800028c0:	6d48                	ld	a0,152(a0)
    800028c2:	fffff097          	auipc	ra,0xfffff
    800028c6:	e32080e7          	jalr	-462(ra) # 800016f4 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800028ca:	70a2                	ld	ra,40(sp)
    800028cc:	7402                	ld	s0,32(sp)
    800028ce:	64e2                	ld	s1,24(sp)
    800028d0:	6942                	ld	s2,16(sp)
    800028d2:	69a2                	ld	s3,8(sp)
    800028d4:	6a02                	ld	s4,0(sp)
    800028d6:	6145                	addi	sp,sp,48
    800028d8:	8082                	ret
    memmove(dst, (char *)src, len);
    800028da:	000a061b          	sext.w	a2,s4
    800028de:	85ce                	mv	a1,s3
    800028e0:	854a                	mv	a0,s2
    800028e2:	ffffe097          	auipc	ra,0xffffe
    800028e6:	44c080e7          	jalr	1100(ra) # 80000d2e <memmove>
    return 0;
    800028ea:	8526                	mv	a0,s1
    800028ec:	bff9                	j	800028ca <either_copyin+0x32>

00000000800028ee <get_cfs_stats>:
int get_cfs_stats(uint64 add, int pid)
{
    800028ee:	715d                	addi	sp,sp,-80
    800028f0:	e486                	sd	ra,72(sp)
    800028f2:	e0a2                	sd	s0,64(sp)
    800028f4:	fc26                	sd	s1,56(sp)
    800028f6:	f84a                	sd	s2,48(sp)
    800028f8:	f44e                	sd	s3,40(sp)
    800028fa:	f052                	sd	s4,32(sp)
    800028fc:	ec56                	sd	s5,24(sp)
    800028fe:	0880                	addi	s0,sp,80
    80002900:	8aaa                	mv	s5,a0
    80002902:	892e                	mv	s2,a1
  struct proc *p;
  int values[4];
  printf("%d\n",pid);
    80002904:	00006517          	auipc	a0,0x6
    80002908:	b5450513          	addi	a0,a0,-1196 # 80008458 <states.0+0x168>
    8000290c:	ffffe097          	auipc	ra,0xffffe
    80002910:	c7c080e7          	jalr	-900(ra) # 80000588 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002914:	0000e497          	auipc	s1,0xe
    80002918:	6bc48493          	addi	s1,s1,1724 # 80010fd0 <proc>
  {
      printf("p->pid=%d\n",p->pid);
    8000291c:	00006997          	auipc	s3,0x6
    80002920:	96c98993          	addi	s3,s3,-1684 # 80008288 <digits+0x248>
  for (p = proc; p < &proc[NPROC]; p++)
    80002924:	00015a17          	auipc	s4,0x15
    80002928:	2aca0a13          	addi	s4,s4,684 # 80017bd0 <tickslock>
      printf("p->pid=%d\n",p->pid);
    8000292c:	588c                	lw	a1,48(s1)
    8000292e:	854e                	mv	a0,s3
    80002930:	ffffe097          	auipc	ra,0xffffe
    80002934:	c58080e7          	jalr	-936(ra) # 80000588 <printf>
    acquire(&p->lock);
    80002938:	8526                	mv	a0,s1
    8000293a:	ffffe097          	auipc	ra,0xffffe
    8000293e:	29c080e7          	jalr	668(ra) # 80000bd6 <acquire>
    if (p->pid == pid)
    80002942:	589c                	lw	a5,48(s1)
    80002944:	01278d63          	beq	a5,s2,8000295e <get_cfs_stats+0x70>
        return -1;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002948:	8526                	mv	a0,s1
    8000294a:	ffffe097          	auipc	ra,0xffffe
    8000294e:	340080e7          	jalr	832(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002952:	1b048493          	addi	s1,s1,432
    80002956:	fd449be3          	bne	s1,s4,8000292c <get_cfs_stats+0x3e>
  }
  return -1;
    8000295a:	557d                	li	a0,-1
    8000295c:	a0b1                	j	800029a8 <get_cfs_stats+0xba>
      printf("here2\n");
    8000295e:	00006517          	auipc	a0,0x6
    80002962:	93a50513          	addi	a0,a0,-1734 # 80008298 <digits+0x258>
    80002966:	ffffe097          	auipc	ra,0xffffe
    8000296a:	c22080e7          	jalr	-990(ra) # 80000588 <printf>
      values[0] = p->cfs_priority;
    8000296e:	58bc                	lw	a5,112(s1)
    80002970:	faf42823          	sw	a5,-80(s0)
      values[1] = p->rtime;
    80002974:	58fc                	lw	a5,116(s1)
    80002976:	faf42a23          	sw	a5,-76(s0)
      values[2] = p->stime;
    8000297a:	5cbc                	lw	a5,120(s1)
    8000297c:	faf42c23          	sw	a5,-72(s0)
      values[3] = p->retime;
    80002980:	5cfc                	lw	a5,124(s1)
    80002982:	faf42e23          	sw	a5,-68(s0)
      if (copyout(p->pagetable, add, (char *)values,
    80002986:	46c1                	li	a3,16
    80002988:	fb040613          	addi	a2,s0,-80
    8000298c:	85d6                	mv	a1,s5
    8000298e:	6cc8                	ld	a0,152(s1)
    80002990:	fffff097          	auipc	ra,0xfffff
    80002994:	cd8080e7          	jalr	-808(ra) # 80001668 <copyout>
    80002998:	02054163          	bltz	a0,800029ba <get_cfs_stats+0xcc>
      release(&p->lock);
    8000299c:	8526                	mv	a0,s1
    8000299e:	ffffe097          	auipc	ra,0xffffe
    800029a2:	2ec080e7          	jalr	748(ra) # 80000c8a <release>
      return 0;
    800029a6:	4501                	li	a0,0
}
    800029a8:	60a6                	ld	ra,72(sp)
    800029aa:	6406                	ld	s0,64(sp)
    800029ac:	74e2                	ld	s1,56(sp)
    800029ae:	7942                	ld	s2,48(sp)
    800029b0:	79a2                	ld	s3,40(sp)
    800029b2:	7a02                	ld	s4,32(sp)
    800029b4:	6ae2                	ld	s5,24(sp)
    800029b6:	6161                	addi	sp,sp,80
    800029b8:	8082                	ret
        printf("here3\n");
    800029ba:	00006517          	auipc	a0,0x6
    800029be:	8e650513          	addi	a0,a0,-1818 # 800082a0 <digits+0x260>
    800029c2:	ffffe097          	auipc	ra,0xffffe
    800029c6:	bc6080e7          	jalr	-1082(ra) # 80000588 <printf>
        release(&p->lock);
    800029ca:	8526                	mv	a0,s1
    800029cc:	ffffe097          	auipc	ra,0xffffe
    800029d0:	2be080e7          	jalr	702(ra) # 80000c8a <release>
        return -1;
    800029d4:	557d                	li	a0,-1
    800029d6:	bfc9                	j	800029a8 <get_cfs_stats+0xba>

00000000800029d8 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    800029d8:	715d                	addi	sp,sp,-80
    800029da:	e486                	sd	ra,72(sp)
    800029dc:	e0a2                	sd	s0,64(sp)
    800029de:	fc26                	sd	s1,56(sp)
    800029e0:	f84a                	sd	s2,48(sp)
    800029e2:	f44e                	sd	s3,40(sp)
    800029e4:	f052                	sd	s4,32(sp)
    800029e6:	ec56                	sd	s5,24(sp)
    800029e8:	e85a                	sd	s6,16(sp)
    800029ea:	e45e                	sd	s7,8(sp)
    800029ec:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    800029ee:	00005517          	auipc	a0,0x5
    800029f2:	6da50513          	addi	a0,a0,1754 # 800080c8 <digits+0x88>
    800029f6:	ffffe097          	auipc	ra,0xffffe
    800029fa:	b92080e7          	jalr	-1134(ra) # 80000588 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800029fe:	0000e497          	auipc	s1,0xe
    80002a02:	77248493          	addi	s1,s1,1906 # 80011170 <proc+0x1a0>
    80002a06:	00015917          	auipc	s2,0x15
    80002a0a:	36a90913          	addi	s2,s2,874 # 80017d70 <bcache+0x188>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002a0e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002a10:	00006997          	auipc	s3,0x6
    80002a14:	89898993          	addi	s3,s3,-1896 # 800082a8 <digits+0x268>
    printf("%d %s %s", p->pid, state, p->name);
    80002a18:	00006a97          	auipc	s5,0x6
    80002a1c:	898a8a93          	addi	s5,s5,-1896 # 800082b0 <digits+0x270>
    printf("\n");
    80002a20:	00005a17          	auipc	s4,0x5
    80002a24:	6a8a0a13          	addi	s4,s4,1704 # 800080c8 <digits+0x88>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002a28:	00006b97          	auipc	s7,0x6
    80002a2c:	8c8b8b93          	addi	s7,s7,-1848 # 800082f0 <states.0>
    80002a30:	a00d                	j	80002a52 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002a32:	e906a583          	lw	a1,-368(a3)
    80002a36:	8556                	mv	a0,s5
    80002a38:	ffffe097          	auipc	ra,0xffffe
    80002a3c:	b50080e7          	jalr	-1200(ra) # 80000588 <printf>
    printf("\n");
    80002a40:	8552                	mv	a0,s4
    80002a42:	ffffe097          	auipc	ra,0xffffe
    80002a46:	b46080e7          	jalr	-1210(ra) # 80000588 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002a4a:	1b048493          	addi	s1,s1,432
    80002a4e:	03248163          	beq	s1,s2,80002a70 <procdump+0x98>
    if (p->state == UNUSED)
    80002a52:	86a6                	mv	a3,s1
    80002a54:	e784a783          	lw	a5,-392(s1)
    80002a58:	dbed                	beqz	a5,80002a4a <procdump+0x72>
      state = "???";
    80002a5a:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002a5c:	fcfb6be3          	bltu	s6,a5,80002a32 <procdump+0x5a>
    80002a60:	1782                	slli	a5,a5,0x20
    80002a62:	9381                	srli	a5,a5,0x20
    80002a64:	078e                	slli	a5,a5,0x3
    80002a66:	97de                	add	a5,a5,s7
    80002a68:	6390                	ld	a2,0(a5)
    80002a6a:	f661                	bnez	a2,80002a32 <procdump+0x5a>
      state = "???";
    80002a6c:	864e                	mv	a2,s3
    80002a6e:	b7d1                	j	80002a32 <procdump+0x5a>
  }
}
    80002a70:	60a6                	ld	ra,72(sp)
    80002a72:	6406                	ld	s0,64(sp)
    80002a74:	74e2                	ld	s1,56(sp)
    80002a76:	7942                	ld	s2,48(sp)
    80002a78:	79a2                	ld	s3,40(sp)
    80002a7a:	7a02                	ld	s4,32(sp)
    80002a7c:	6ae2                	ld	s5,24(sp)
    80002a7e:	6b42                	ld	s6,16(sp)
    80002a80:	6ba2                	ld	s7,8(sp)
    80002a82:	6161                	addi	sp,sp,80
    80002a84:	8082                	ret

0000000080002a86 <swtch>:
    80002a86:	00153023          	sd	ra,0(a0)
    80002a8a:	00253423          	sd	sp,8(a0)
    80002a8e:	e900                	sd	s0,16(a0)
    80002a90:	ed04                	sd	s1,24(a0)
    80002a92:	03253023          	sd	s2,32(a0)
    80002a96:	03353423          	sd	s3,40(a0)
    80002a9a:	03453823          	sd	s4,48(a0)
    80002a9e:	03553c23          	sd	s5,56(a0)
    80002aa2:	05653023          	sd	s6,64(a0)
    80002aa6:	05753423          	sd	s7,72(a0)
    80002aaa:	05853823          	sd	s8,80(a0)
    80002aae:	05953c23          	sd	s9,88(a0)
    80002ab2:	07a53023          	sd	s10,96(a0)
    80002ab6:	07b53423          	sd	s11,104(a0)
    80002aba:	0005b083          	ld	ra,0(a1)
    80002abe:	0085b103          	ld	sp,8(a1)
    80002ac2:	6980                	ld	s0,16(a1)
    80002ac4:	6d84                	ld	s1,24(a1)
    80002ac6:	0205b903          	ld	s2,32(a1)
    80002aca:	0285b983          	ld	s3,40(a1)
    80002ace:	0305ba03          	ld	s4,48(a1)
    80002ad2:	0385ba83          	ld	s5,56(a1)
    80002ad6:	0405bb03          	ld	s6,64(a1)
    80002ada:	0485bb83          	ld	s7,72(a1)
    80002ade:	0505bc03          	ld	s8,80(a1)
    80002ae2:	0585bc83          	ld	s9,88(a1)
    80002ae6:	0605bd03          	ld	s10,96(a1)
    80002aea:	0685bd83          	ld	s11,104(a1)
    80002aee:	8082                	ret

0000000080002af0 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002af0:	1141                	addi	sp,sp,-16
    80002af2:	e406                	sd	ra,8(sp)
    80002af4:	e022                	sd	s0,0(sp)
    80002af6:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002af8:	00006597          	auipc	a1,0x6
    80002afc:	82858593          	addi	a1,a1,-2008 # 80008320 <states.0+0x30>
    80002b00:	00015517          	auipc	a0,0x15
    80002b04:	0d050513          	addi	a0,a0,208 # 80017bd0 <tickslock>
    80002b08:	ffffe097          	auipc	ra,0xffffe
    80002b0c:	03e080e7          	jalr	62(ra) # 80000b46 <initlock>
}
    80002b10:	60a2                	ld	ra,8(sp)
    80002b12:	6402                	ld	s0,0(sp)
    80002b14:	0141                	addi	sp,sp,16
    80002b16:	8082                	ret

0000000080002b18 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002b18:	1141                	addi	sp,sp,-16
    80002b1a:	e422                	sd	s0,8(sp)
    80002b1c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b1e:	00003797          	auipc	a5,0x3
    80002b22:	60278793          	addi	a5,a5,1538 # 80006120 <kernelvec>
    80002b26:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002b2a:	6422                	ld	s0,8(sp)
    80002b2c:	0141                	addi	sp,sp,16
    80002b2e:	8082                	ret

0000000080002b30 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002b30:	1141                	addi	sp,sp,-16
    80002b32:	e406                	sd	ra,8(sp)
    80002b34:	e022                	sd	s0,0(sp)
    80002b36:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002b38:	fffff097          	auipc	ra,0xfffff
    80002b3c:	e92080e7          	jalr	-366(ra) # 800019ca <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b40:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002b44:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b46:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002b4a:	00004617          	auipc	a2,0x4
    80002b4e:	4b660613          	addi	a2,a2,1206 # 80007000 <_trampoline>
    80002b52:	00004697          	auipc	a3,0x4
    80002b56:	4ae68693          	addi	a3,a3,1198 # 80007000 <_trampoline>
    80002b5a:	8e91                	sub	a3,a3,a2
    80002b5c:	040007b7          	lui	a5,0x4000
    80002b60:	17fd                	addi	a5,a5,-1
    80002b62:	07b2                	slli	a5,a5,0xc
    80002b64:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b66:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002b6a:	7158                	ld	a4,160(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002b6c:	180026f3          	csrr	a3,satp
    80002b70:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002b72:	7158                	ld	a4,160(a0)
    80002b74:	6554                	ld	a3,136(a0)
    80002b76:	6585                	lui	a1,0x1
    80002b78:	96ae                	add	a3,a3,a1
    80002b7a:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002b7c:	7158                	ld	a4,160(a0)
    80002b7e:	00000697          	auipc	a3,0x0
    80002b82:	14068693          	addi	a3,a3,320 # 80002cbe <usertrap>
    80002b86:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002b88:	7158                	ld	a4,160(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002b8a:	8692                	mv	a3,tp
    80002b8c:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b8e:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002b92:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002b96:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b9a:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002b9e:	7158                	ld	a4,160(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002ba0:	6f18                	ld	a4,24(a4)
    80002ba2:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002ba6:	6d48                	ld	a0,152(a0)
    80002ba8:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002baa:	00004717          	auipc	a4,0x4
    80002bae:	4f270713          	addi	a4,a4,1266 # 8000709c <userret>
    80002bb2:	8f11                	sub	a4,a4,a2
    80002bb4:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002bb6:	577d                	li	a4,-1
    80002bb8:	177e                	slli	a4,a4,0x3f
    80002bba:	8d59                	or	a0,a0,a4
    80002bbc:	9782                	jalr	a5
}
    80002bbe:	60a2                	ld	ra,8(sp)
    80002bc0:	6402                	ld	s0,0(sp)
    80002bc2:	0141                	addi	sp,sp,16
    80002bc4:	8082                	ret

0000000080002bc6 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002bc6:	1101                	addi	sp,sp,-32
    80002bc8:	ec06                	sd	ra,24(sp)
    80002bca:	e822                	sd	s0,16(sp)
    80002bcc:	e426                	sd	s1,8(sp)
    80002bce:	1000                	addi	s0,sp,32
  cfs_update();
    80002bd0:	fffff097          	auipc	ra,0xfffff
    80002bd4:	7e0080e7          	jalr	2016(ra) # 800023b0 <cfs_update>
  acquire(&tickslock);
    80002bd8:	00015497          	auipc	s1,0x15
    80002bdc:	ff848493          	addi	s1,s1,-8 # 80017bd0 <tickslock>
    80002be0:	8526                	mv	a0,s1
    80002be2:	ffffe097          	auipc	ra,0xffffe
    80002be6:	ff4080e7          	jalr	-12(ra) # 80000bd6 <acquire>
  ticks++;
    80002bea:	00006517          	auipc	a0,0x6
    80002bee:	d4650513          	addi	a0,a0,-698 # 80008930 <ticks>
    80002bf2:	411c                	lw	a5,0(a0)
    80002bf4:	2785                	addiw	a5,a5,1
    80002bf6:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002bf8:	00000097          	auipc	ra,0x0
    80002bfc:	83c080e7          	jalr	-1988(ra) # 80002434 <wakeup>
  release(&tickslock);
    80002c00:	8526                	mv	a0,s1
    80002c02:	ffffe097          	auipc	ra,0xffffe
    80002c06:	088080e7          	jalr	136(ra) # 80000c8a <release>
  cfs_update();
    80002c0a:	fffff097          	auipc	ra,0xfffff
    80002c0e:	7a6080e7          	jalr	1958(ra) # 800023b0 <cfs_update>
}
    80002c12:	60e2                	ld	ra,24(sp)
    80002c14:	6442                	ld	s0,16(sp)
    80002c16:	64a2                	ld	s1,8(sp)
    80002c18:	6105                	addi	sp,sp,32
    80002c1a:	8082                	ret

0000000080002c1c <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002c1c:	1101                	addi	sp,sp,-32
    80002c1e:	ec06                	sd	ra,24(sp)
    80002c20:	e822                	sd	s0,16(sp)
    80002c22:	e426                	sd	s1,8(sp)
    80002c24:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c26:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002c2a:	00074d63          	bltz	a4,80002c44 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002c2e:	57fd                	li	a5,-1
    80002c30:	17fe                	slli	a5,a5,0x3f
    80002c32:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002c34:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002c36:	06f70363          	beq	a4,a5,80002c9c <devintr+0x80>
  }
}
    80002c3a:	60e2                	ld	ra,24(sp)
    80002c3c:	6442                	ld	s0,16(sp)
    80002c3e:	64a2                	ld	s1,8(sp)
    80002c40:	6105                	addi	sp,sp,32
    80002c42:	8082                	ret
     (scause & 0xff) == 9){
    80002c44:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002c48:	46a5                	li	a3,9
    80002c4a:	fed792e3          	bne	a5,a3,80002c2e <devintr+0x12>
    int irq = plic_claim();
    80002c4e:	00003097          	auipc	ra,0x3
    80002c52:	5da080e7          	jalr	1498(ra) # 80006228 <plic_claim>
    80002c56:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002c58:	47a9                	li	a5,10
    80002c5a:	02f50763          	beq	a0,a5,80002c88 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002c5e:	4785                	li	a5,1
    80002c60:	02f50963          	beq	a0,a5,80002c92 <devintr+0x76>
    return 1;
    80002c64:	4505                	li	a0,1
    } else if(irq){
    80002c66:	d8f1                	beqz	s1,80002c3a <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002c68:	85a6                	mv	a1,s1
    80002c6a:	00005517          	auipc	a0,0x5
    80002c6e:	6be50513          	addi	a0,a0,1726 # 80008328 <states.0+0x38>
    80002c72:	ffffe097          	auipc	ra,0xffffe
    80002c76:	916080e7          	jalr	-1770(ra) # 80000588 <printf>
      plic_complete(irq);
    80002c7a:	8526                	mv	a0,s1
    80002c7c:	00003097          	auipc	ra,0x3
    80002c80:	5d0080e7          	jalr	1488(ra) # 8000624c <plic_complete>
    return 1;
    80002c84:	4505                	li	a0,1
    80002c86:	bf55                	j	80002c3a <devintr+0x1e>
      uartintr();
    80002c88:	ffffe097          	auipc	ra,0xffffe
    80002c8c:	d12080e7          	jalr	-750(ra) # 8000099a <uartintr>
    80002c90:	b7ed                	j	80002c7a <devintr+0x5e>
      virtio_disk_intr();
    80002c92:	00004097          	auipc	ra,0x4
    80002c96:	a86080e7          	jalr	-1402(ra) # 80006718 <virtio_disk_intr>
    80002c9a:	b7c5                	j	80002c7a <devintr+0x5e>
    if(cpuid() == 0){
    80002c9c:	fffff097          	auipc	ra,0xfffff
    80002ca0:	d02080e7          	jalr	-766(ra) # 8000199e <cpuid>
    80002ca4:	c901                	beqz	a0,80002cb4 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002ca6:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002caa:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002cac:	14479073          	csrw	sip,a5
    return 2;
    80002cb0:	4509                	li	a0,2
    80002cb2:	b761                	j	80002c3a <devintr+0x1e>
      clockintr();
    80002cb4:	00000097          	auipc	ra,0x0
    80002cb8:	f12080e7          	jalr	-238(ra) # 80002bc6 <clockintr>
    80002cbc:	b7ed                	j	80002ca6 <devintr+0x8a>

0000000080002cbe <usertrap>:
{
    80002cbe:	1101                	addi	sp,sp,-32
    80002cc0:	ec06                	sd	ra,24(sp)
    80002cc2:	e822                	sd	s0,16(sp)
    80002cc4:	e426                	sd	s1,8(sp)
    80002cc6:	e04a                	sd	s2,0(sp)
    80002cc8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cca:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002cce:	1007f793          	andi	a5,a5,256
    80002cd2:	e3b1                	bnez	a5,80002d16 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002cd4:	00003797          	auipc	a5,0x3
    80002cd8:	44c78793          	addi	a5,a5,1100 # 80006120 <kernelvec>
    80002cdc:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002ce0:	fffff097          	auipc	ra,0xfffff
    80002ce4:	cea080e7          	jalr	-790(ra) # 800019ca <myproc>
    80002ce8:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002cea:	715c                	ld	a5,160(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cec:	14102773          	csrr	a4,sepc
    80002cf0:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cf2:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002cf6:	47a1                	li	a5,8
    80002cf8:	02f70763          	beq	a4,a5,80002d26 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002cfc:	00000097          	auipc	ra,0x0
    80002d00:	f20080e7          	jalr	-224(ra) # 80002c1c <devintr>
    80002d04:	892a                	mv	s2,a0
    80002d06:	c551                	beqz	a0,80002d92 <usertrap+0xd4>
  if(killed(p))
    80002d08:	8526                	mv	a0,s1
    80002d0a:	00000097          	auipc	ra,0x0
    80002d0e:	996080e7          	jalr	-1642(ra) # 800026a0 <killed>
    80002d12:	c939                	beqz	a0,80002d68 <usertrap+0xaa>
    80002d14:	a099                	j	80002d5a <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002d16:	00005517          	auipc	a0,0x5
    80002d1a:	63250513          	addi	a0,a0,1586 # 80008348 <states.0+0x58>
    80002d1e:	ffffe097          	auipc	ra,0xffffe
    80002d22:	820080e7          	jalr	-2016(ra) # 8000053e <panic>
    if(killed(p))
    80002d26:	00000097          	auipc	ra,0x0
    80002d2a:	97a080e7          	jalr	-1670(ra) # 800026a0 <killed>
    80002d2e:	e931                	bnez	a0,80002d82 <usertrap+0xc4>
    p->trapframe->epc += 4;
    80002d30:	70d8                	ld	a4,160(s1)
    80002d32:	6f1c                	ld	a5,24(a4)
    80002d34:	0791                	addi	a5,a5,4
    80002d36:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d38:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002d3c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d40:	10079073          	csrw	sstatus,a5
    syscall();
    80002d44:	00000097          	auipc	ra,0x0
    80002d48:	30e080e7          	jalr	782(ra) # 80003052 <syscall>
  if(killed(p))
    80002d4c:	8526                	mv	a0,s1
    80002d4e:	00000097          	auipc	ra,0x0
    80002d52:	952080e7          	jalr	-1710(ra) # 800026a0 <killed>
    80002d56:	cd01                	beqz	a0,80002d6e <usertrap+0xb0>
    80002d58:	4901                	li	s2,0
    exit(-1,p->exit_msg);
    80002d5a:	04048593          	addi	a1,s1,64
    80002d5e:	557d                	li	a0,-1
    80002d60:	fffff097          	auipc	ra,0xfffff
    80002d64:	7b6080e7          	jalr	1974(ra) # 80002516 <exit>
  if(which_dev == 2){
    80002d68:	4789                	li	a5,2
    80002d6a:	06f90163          	beq	s2,a5,80002dcc <usertrap+0x10e>
  usertrapret();
    80002d6e:	00000097          	auipc	ra,0x0
    80002d72:	dc2080e7          	jalr	-574(ra) # 80002b30 <usertrapret>
}
    80002d76:	60e2                	ld	ra,24(sp)
    80002d78:	6442                	ld	s0,16(sp)
    80002d7a:	64a2                	ld	s1,8(sp)
    80002d7c:	6902                	ld	s2,0(sp)
    80002d7e:	6105                	addi	sp,sp,32
    80002d80:	8082                	ret
      exit(-1,p->exit_msg);
    80002d82:	04048593          	addi	a1,s1,64
    80002d86:	557d                	li	a0,-1
    80002d88:	fffff097          	auipc	ra,0xfffff
    80002d8c:	78e080e7          	jalr	1934(ra) # 80002516 <exit>
    80002d90:	b745                	j	80002d30 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d92:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002d96:	5890                	lw	a2,48(s1)
    80002d98:	00005517          	auipc	a0,0x5
    80002d9c:	5d050513          	addi	a0,a0,1488 # 80008368 <states.0+0x78>
    80002da0:	ffffd097          	auipc	ra,0xffffd
    80002da4:	7e8080e7          	jalr	2024(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002da8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002dac:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002db0:	00005517          	auipc	a0,0x5
    80002db4:	5e850513          	addi	a0,a0,1512 # 80008398 <states.0+0xa8>
    80002db8:	ffffd097          	auipc	ra,0xffffd
    80002dbc:	7d0080e7          	jalr	2000(ra) # 80000588 <printf>
    setkilled(p);
    80002dc0:	8526                	mv	a0,s1
    80002dc2:	00000097          	auipc	ra,0x0
    80002dc6:	8b2080e7          	jalr	-1870(ra) # 80002674 <setkilled>
    80002dca:	b749                	j	80002d4c <usertrap+0x8e>
    myproc()->accumulator+=myproc()->ps_priority;
    80002dcc:	fffff097          	auipc	ra,0xfffff
    80002dd0:	bfe080e7          	jalr	-1026(ra) # 800019ca <myproc>
    80002dd4:	7524                	ld	s1,104(a0)
    80002dd6:	fffff097          	auipc	ra,0xfffff
    80002dda:	bf4080e7          	jalr	-1036(ra) # 800019ca <myproc>
    80002dde:	713c                	ld	a5,96(a0)
    80002de0:	97a6                	add	a5,a5,s1
    80002de2:	f13c                	sd	a5,96(a0)
    yield();
    80002de4:	fffff097          	auipc	ra,0xfffff
    80002de8:	52c080e7          	jalr	1324(ra) # 80002310 <yield>
    80002dec:	b749                	j	80002d6e <usertrap+0xb0>

0000000080002dee <kerneltrap>:
{
    80002dee:	7179                	addi	sp,sp,-48
    80002df0:	f406                	sd	ra,40(sp)
    80002df2:	f022                	sd	s0,32(sp)
    80002df4:	ec26                	sd	s1,24(sp)
    80002df6:	e84a                	sd	s2,16(sp)
    80002df8:	e44e                	sd	s3,8(sp)
    80002dfa:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002dfc:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e00:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e04:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002e08:	1004f793          	andi	a5,s1,256
    80002e0c:	cb85                	beqz	a5,80002e3c <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e0e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002e12:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002e14:	ef85                	bnez	a5,80002e4c <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002e16:	00000097          	auipc	ra,0x0
    80002e1a:	e06080e7          	jalr	-506(ra) # 80002c1c <devintr>
    80002e1e:	cd1d                	beqz	a0,80002e5c <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING){
    80002e20:	4789                	li	a5,2
    80002e22:	06f50a63          	beq	a0,a5,80002e96 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002e26:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002e2a:	10049073          	csrw	sstatus,s1
}
    80002e2e:	70a2                	ld	ra,40(sp)
    80002e30:	7402                	ld	s0,32(sp)
    80002e32:	64e2                	ld	s1,24(sp)
    80002e34:	6942                	ld	s2,16(sp)
    80002e36:	69a2                	ld	s3,8(sp)
    80002e38:	6145                	addi	sp,sp,48
    80002e3a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002e3c:	00005517          	auipc	a0,0x5
    80002e40:	57c50513          	addi	a0,a0,1404 # 800083b8 <states.0+0xc8>
    80002e44:	ffffd097          	auipc	ra,0xffffd
    80002e48:	6fa080e7          	jalr	1786(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002e4c:	00005517          	auipc	a0,0x5
    80002e50:	59450513          	addi	a0,a0,1428 # 800083e0 <states.0+0xf0>
    80002e54:	ffffd097          	auipc	ra,0xffffd
    80002e58:	6ea080e7          	jalr	1770(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002e5c:	85ce                	mv	a1,s3
    80002e5e:	00005517          	auipc	a0,0x5
    80002e62:	5a250513          	addi	a0,a0,1442 # 80008400 <states.0+0x110>
    80002e66:	ffffd097          	auipc	ra,0xffffd
    80002e6a:	722080e7          	jalr	1826(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e6e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002e72:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002e76:	00005517          	auipc	a0,0x5
    80002e7a:	59a50513          	addi	a0,a0,1434 # 80008410 <states.0+0x120>
    80002e7e:	ffffd097          	auipc	ra,0xffffd
    80002e82:	70a080e7          	jalr	1802(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002e86:	00005517          	auipc	a0,0x5
    80002e8a:	5a250513          	addi	a0,a0,1442 # 80008428 <states.0+0x138>
    80002e8e:	ffffd097          	auipc	ra,0xffffd
    80002e92:	6b0080e7          	jalr	1712(ra) # 8000053e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING){
    80002e96:	fffff097          	auipc	ra,0xfffff
    80002e9a:	b34080e7          	jalr	-1228(ra) # 800019ca <myproc>
    80002e9e:	d541                	beqz	a0,80002e26 <kerneltrap+0x38>
    80002ea0:	fffff097          	auipc	ra,0xfffff
    80002ea4:	b2a080e7          	jalr	-1238(ra) # 800019ca <myproc>
    80002ea8:	4d18                	lw	a4,24(a0)
    80002eaa:	4791                	li	a5,4
    80002eac:	f6f71de3          	bne	a4,a5,80002e26 <kerneltrap+0x38>
    myproc()->accumulator+=myproc()->ps_priority;
    80002eb0:	fffff097          	auipc	ra,0xfffff
    80002eb4:	b1a080e7          	jalr	-1254(ra) # 800019ca <myproc>
    80002eb8:	06853983          	ld	s3,104(a0)
    80002ebc:	fffff097          	auipc	ra,0xfffff
    80002ec0:	b0e080e7          	jalr	-1266(ra) # 800019ca <myproc>
    80002ec4:	713c                	ld	a5,96(a0)
    80002ec6:	97ce                	add	a5,a5,s3
    80002ec8:	f13c                	sd	a5,96(a0)
    yield();
    80002eca:	fffff097          	auipc	ra,0xfffff
    80002ece:	446080e7          	jalr	1094(ra) # 80002310 <yield>
    80002ed2:	bf91                	j	80002e26 <kerneltrap+0x38>

0000000080002ed4 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002ed4:	1101                	addi	sp,sp,-32
    80002ed6:	ec06                	sd	ra,24(sp)
    80002ed8:	e822                	sd	s0,16(sp)
    80002eda:	e426                	sd	s1,8(sp)
    80002edc:	1000                	addi	s0,sp,32
    80002ede:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002ee0:	fffff097          	auipc	ra,0xfffff
    80002ee4:	aea080e7          	jalr	-1302(ra) # 800019ca <myproc>
  switch (n) {
    80002ee8:	4795                	li	a5,5
    80002eea:	0497e163          	bltu	a5,s1,80002f2c <argraw+0x58>
    80002eee:	048a                	slli	s1,s1,0x2
    80002ef0:	00005717          	auipc	a4,0x5
    80002ef4:	57070713          	addi	a4,a4,1392 # 80008460 <states.0+0x170>
    80002ef8:	94ba                	add	s1,s1,a4
    80002efa:	409c                	lw	a5,0(s1)
    80002efc:	97ba                	add	a5,a5,a4
    80002efe:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002f00:	715c                	ld	a5,160(a0)
    80002f02:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002f04:	60e2                	ld	ra,24(sp)
    80002f06:	6442                	ld	s0,16(sp)
    80002f08:	64a2                	ld	s1,8(sp)
    80002f0a:	6105                	addi	sp,sp,32
    80002f0c:	8082                	ret
    return p->trapframe->a1;
    80002f0e:	715c                	ld	a5,160(a0)
    80002f10:	7fa8                	ld	a0,120(a5)
    80002f12:	bfcd                	j	80002f04 <argraw+0x30>
    return p->trapframe->a2;
    80002f14:	715c                	ld	a5,160(a0)
    80002f16:	63c8                	ld	a0,128(a5)
    80002f18:	b7f5                	j	80002f04 <argraw+0x30>
    return p->trapframe->a3;
    80002f1a:	715c                	ld	a5,160(a0)
    80002f1c:	67c8                	ld	a0,136(a5)
    80002f1e:	b7dd                	j	80002f04 <argraw+0x30>
    return p->trapframe->a4;
    80002f20:	715c                	ld	a5,160(a0)
    80002f22:	6bc8                	ld	a0,144(a5)
    80002f24:	b7c5                	j	80002f04 <argraw+0x30>
    return p->trapframe->a5;
    80002f26:	715c                	ld	a5,160(a0)
    80002f28:	6fc8                	ld	a0,152(a5)
    80002f2a:	bfe9                	j	80002f04 <argraw+0x30>
  panic("argraw");
    80002f2c:	00005517          	auipc	a0,0x5
    80002f30:	50c50513          	addi	a0,a0,1292 # 80008438 <states.0+0x148>
    80002f34:	ffffd097          	auipc	ra,0xffffd
    80002f38:	60a080e7          	jalr	1546(ra) # 8000053e <panic>

0000000080002f3c <fetchaddr>:
{
    80002f3c:	1101                	addi	sp,sp,-32
    80002f3e:	ec06                	sd	ra,24(sp)
    80002f40:	e822                	sd	s0,16(sp)
    80002f42:	e426                	sd	s1,8(sp)
    80002f44:	e04a                	sd	s2,0(sp)
    80002f46:	1000                	addi	s0,sp,32
    80002f48:	84aa                	mv	s1,a0
    80002f4a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002f4c:	fffff097          	auipc	ra,0xfffff
    80002f50:	a7e080e7          	jalr	-1410(ra) # 800019ca <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002f54:	695c                	ld	a5,144(a0)
    80002f56:	02f4f863          	bgeu	s1,a5,80002f86 <fetchaddr+0x4a>
    80002f5a:	00848713          	addi	a4,s1,8
    80002f5e:	02e7e663          	bltu	a5,a4,80002f8a <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002f62:	46a1                	li	a3,8
    80002f64:	8626                	mv	a2,s1
    80002f66:	85ca                	mv	a1,s2
    80002f68:	6d48                	ld	a0,152(a0)
    80002f6a:	ffffe097          	auipc	ra,0xffffe
    80002f6e:	78a080e7          	jalr	1930(ra) # 800016f4 <copyin>
    80002f72:	00a03533          	snez	a0,a0
    80002f76:	40a00533          	neg	a0,a0
}
    80002f7a:	60e2                	ld	ra,24(sp)
    80002f7c:	6442                	ld	s0,16(sp)
    80002f7e:	64a2                	ld	s1,8(sp)
    80002f80:	6902                	ld	s2,0(sp)
    80002f82:	6105                	addi	sp,sp,32
    80002f84:	8082                	ret
    return -1;
    80002f86:	557d                	li	a0,-1
    80002f88:	bfcd                	j	80002f7a <fetchaddr+0x3e>
    80002f8a:	557d                	li	a0,-1
    80002f8c:	b7fd                	j	80002f7a <fetchaddr+0x3e>

0000000080002f8e <fetchstr>:
{
    80002f8e:	7179                	addi	sp,sp,-48
    80002f90:	f406                	sd	ra,40(sp)
    80002f92:	f022                	sd	s0,32(sp)
    80002f94:	ec26                	sd	s1,24(sp)
    80002f96:	e84a                	sd	s2,16(sp)
    80002f98:	e44e                	sd	s3,8(sp)
    80002f9a:	1800                	addi	s0,sp,48
    80002f9c:	892a                	mv	s2,a0
    80002f9e:	84ae                	mv	s1,a1
    80002fa0:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002fa2:	fffff097          	auipc	ra,0xfffff
    80002fa6:	a28080e7          	jalr	-1496(ra) # 800019ca <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002faa:	86ce                	mv	a3,s3
    80002fac:	864a                	mv	a2,s2
    80002fae:	85a6                	mv	a1,s1
    80002fb0:	6d48                	ld	a0,152(a0)
    80002fb2:	ffffe097          	auipc	ra,0xffffe
    80002fb6:	7d0080e7          	jalr	2000(ra) # 80001782 <copyinstr>
    80002fba:	00054e63          	bltz	a0,80002fd6 <fetchstr+0x48>
  return strlen(buf);
    80002fbe:	8526                	mv	a0,s1
    80002fc0:	ffffe097          	auipc	ra,0xffffe
    80002fc4:	e8e080e7          	jalr	-370(ra) # 80000e4e <strlen>
}
    80002fc8:	70a2                	ld	ra,40(sp)
    80002fca:	7402                	ld	s0,32(sp)
    80002fcc:	64e2                	ld	s1,24(sp)
    80002fce:	6942                	ld	s2,16(sp)
    80002fd0:	69a2                	ld	s3,8(sp)
    80002fd2:	6145                	addi	sp,sp,48
    80002fd4:	8082                	ret
    return -1;
    80002fd6:	557d                	li	a0,-1
    80002fd8:	bfc5                	j	80002fc8 <fetchstr+0x3a>

0000000080002fda <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002fda:	1101                	addi	sp,sp,-32
    80002fdc:	ec06                	sd	ra,24(sp)
    80002fde:	e822                	sd	s0,16(sp)
    80002fe0:	e426                	sd	s1,8(sp)
    80002fe2:	1000                	addi	s0,sp,32
    80002fe4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002fe6:	00000097          	auipc	ra,0x0
    80002fea:	eee080e7          	jalr	-274(ra) # 80002ed4 <argraw>
    80002fee:	c088                	sw	a0,0(s1)
}
    80002ff0:	60e2                	ld	ra,24(sp)
    80002ff2:	6442                	ld	s0,16(sp)
    80002ff4:	64a2                	ld	s1,8(sp)
    80002ff6:	6105                	addi	sp,sp,32
    80002ff8:	8082                	ret

0000000080002ffa <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002ffa:	1101                	addi	sp,sp,-32
    80002ffc:	ec06                	sd	ra,24(sp)
    80002ffe:	e822                	sd	s0,16(sp)
    80003000:	e426                	sd	s1,8(sp)
    80003002:	1000                	addi	s0,sp,32
    80003004:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003006:	00000097          	auipc	ra,0x0
    8000300a:	ece080e7          	jalr	-306(ra) # 80002ed4 <argraw>
    8000300e:	e088                	sd	a0,0(s1)
}
    80003010:	60e2                	ld	ra,24(sp)
    80003012:	6442                	ld	s0,16(sp)
    80003014:	64a2                	ld	s1,8(sp)
    80003016:	6105                	addi	sp,sp,32
    80003018:	8082                	ret

000000008000301a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000301a:	7179                	addi	sp,sp,-48
    8000301c:	f406                	sd	ra,40(sp)
    8000301e:	f022                	sd	s0,32(sp)
    80003020:	ec26                	sd	s1,24(sp)
    80003022:	e84a                	sd	s2,16(sp)
    80003024:	1800                	addi	s0,sp,48
    80003026:	84ae                	mv	s1,a1
    80003028:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    8000302a:	fd840593          	addi	a1,s0,-40
    8000302e:	00000097          	auipc	ra,0x0
    80003032:	fcc080e7          	jalr	-52(ra) # 80002ffa <argaddr>
  return fetchstr(addr, buf, max);
    80003036:	864a                	mv	a2,s2
    80003038:	85a6                	mv	a1,s1
    8000303a:	fd843503          	ld	a0,-40(s0)
    8000303e:	00000097          	auipc	ra,0x0
    80003042:	f50080e7          	jalr	-176(ra) # 80002f8e <fetchstr>
}
    80003046:	70a2                	ld	ra,40(sp)
    80003048:	7402                	ld	s0,32(sp)
    8000304a:	64e2                	ld	s1,24(sp)
    8000304c:	6942                	ld	s2,16(sp)
    8000304e:	6145                	addi	sp,sp,48
    80003050:	8082                	ret

0000000080003052 <syscall>:
[SYS_get_cfs_stats] sys_get_cfs_stats,
};

void
syscall(void)
{
    80003052:	1101                	addi	sp,sp,-32
    80003054:	ec06                	sd	ra,24(sp)
    80003056:	e822                	sd	s0,16(sp)
    80003058:	e426                	sd	s1,8(sp)
    8000305a:	e04a                	sd	s2,0(sp)
    8000305c:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    8000305e:	fffff097          	auipc	ra,0xfffff
    80003062:	96c080e7          	jalr	-1684(ra) # 800019ca <myproc>
    80003066:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80003068:	0a053903          	ld	s2,160(a0)
    8000306c:	0a893783          	ld	a5,168(s2)
    80003070:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003074:	37fd                	addiw	a5,a5,-1
    80003076:	4761                	li	a4,24
    80003078:	00f76f63          	bltu	a4,a5,80003096 <syscall+0x44>
    8000307c:	00369713          	slli	a4,a3,0x3
    80003080:	00005797          	auipc	a5,0x5
    80003084:	3f878793          	addi	a5,a5,1016 # 80008478 <syscalls>
    80003088:	97ba                	add	a5,a5,a4
    8000308a:	639c                	ld	a5,0(a5)
    8000308c:	c789                	beqz	a5,80003096 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    8000308e:	9782                	jalr	a5
    80003090:	06a93823          	sd	a0,112(s2)
    80003094:	a839                	j	800030b2 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003096:	1a048613          	addi	a2,s1,416
    8000309a:	588c                	lw	a1,48(s1)
    8000309c:	00005517          	auipc	a0,0x5
    800030a0:	3a450513          	addi	a0,a0,932 # 80008440 <states.0+0x150>
    800030a4:	ffffd097          	auipc	ra,0xffffd
    800030a8:	4e4080e7          	jalr	1252(ra) # 80000588 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800030ac:	70dc                	ld	a5,160(s1)
    800030ae:	577d                	li	a4,-1
    800030b0:	fbb8                	sd	a4,112(a5)
  }
}
    800030b2:	60e2                	ld	ra,24(sp)
    800030b4:	6442                	ld	s0,16(sp)
    800030b6:	64a2                	ld	s1,8(sp)
    800030b8:	6902                	ld	s2,0(sp)
    800030ba:	6105                	addi	sp,sp,32
    800030bc:	8082                	ret

00000000800030be <sys_memsize>:
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
uint64
sys_memsize(void)
{
    800030be:	1141                	addi	sp,sp,-16
    800030c0:	e406                	sd	ra,8(sp)
    800030c2:	e022                	sd	s0,0(sp)
    800030c4:	0800                	addi	s0,sp,16
  return myproc()->sz;
    800030c6:	fffff097          	auipc	ra,0xfffff
    800030ca:	904080e7          	jalr	-1788(ra) # 800019ca <myproc>
}
    800030ce:	6948                	ld	a0,144(a0)
    800030d0:	60a2                	ld	ra,8(sp)
    800030d2:	6402                	ld	s0,0(sp)
    800030d4:	0141                	addi	sp,sp,16
    800030d6:	8082                	ret

00000000800030d8 <sys_exit>:
uint64
sys_exit(void)
{
    800030d8:	7139                	addi	sp,sp,-64
    800030da:	fc06                	sd	ra,56(sp)
    800030dc:	f822                	sd	s0,48(sp)
    800030de:	0080                	addi	s0,sp,64
  int n;
  char msg[32];
  argint(0, &n);
    800030e0:	fec40593          	addi	a1,s0,-20
    800030e4:	4501                	li	a0,0
    800030e6:	00000097          	auipc	ra,0x0
    800030ea:	ef4080e7          	jalr	-268(ra) # 80002fda <argint>
  argstr(1,msg,32);
    800030ee:	02000613          	li	a2,32
    800030f2:	fc840593          	addi	a1,s0,-56
    800030f6:	4505                	li	a0,1
    800030f8:	00000097          	auipc	ra,0x0
    800030fc:	f22080e7          	jalr	-222(ra) # 8000301a <argstr>
  exit(n, msg);
    80003100:	fc840593          	addi	a1,s0,-56
    80003104:	fec42503          	lw	a0,-20(s0)
    80003108:	fffff097          	auipc	ra,0xfffff
    8000310c:	40e080e7          	jalr	1038(ra) # 80002516 <exit>
  return 0;  // not reached
}
    80003110:	4501                	li	a0,0
    80003112:	70e2                	ld	ra,56(sp)
    80003114:	7442                	ld	s0,48(sp)
    80003116:	6121                	addi	sp,sp,64
    80003118:	8082                	ret

000000008000311a <sys_set_cfs_priority>:
uint64 
sys_set_cfs_priority(void) { //task6
    8000311a:	1101                	addi	sp,sp,-32
    8000311c:	ec06                	sd	ra,24(sp)
    8000311e:	e822                	sd	s0,16(sp)
    80003120:	1000                	addi	s0,sp,32
  int priority;
  argint(0, &priority);
    80003122:	fec40593          	addi	a1,s0,-20
    80003126:	4501                	li	a0,0
    80003128:	00000097          	auipc	ra,0x0
    8000312c:	eb2080e7          	jalr	-334(ra) # 80002fda <argint>
  if (priority >2 || priority<0){
    80003130:	fec42703          	lw	a4,-20(s0)
    80003134:	4789                	li	a5,2
    return -1;
    80003136:	557d                	li	a0,-1
  if (priority >2 || priority<0){
    80003138:	00e7ea63          	bltu	a5,a4,8000314c <sys_set_cfs_priority+0x32>
  }
  myproc()->cfs_priority=priority;
    8000313c:	fffff097          	auipc	ra,0xfffff
    80003140:	88e080e7          	jalr	-1906(ra) # 800019ca <myproc>
    80003144:	fec42783          	lw	a5,-20(s0)
    80003148:	d93c                	sw	a5,112(a0)
  //           break;
  //         case 2:
  //           decay_factor=125;
  //           break;
  //       }
  return 0;
    8000314a:	4501                	li	a0,0
}
    8000314c:	60e2                	ld	ra,24(sp)
    8000314e:	6442                	ld	s0,16(sp)
    80003150:	6105                	addi	sp,sp,32
    80003152:	8082                	ret

0000000080003154 <sys_get_cfs_stats>:

uint64
sys_get_cfs_stats(void){//task6
    80003154:	1101                	addi	sp,sp,-32
    80003156:	ec06                	sd	ra,24(sp)
    80003158:	e822                	sd	s0,16(sp)
    8000315a:	1000                	addi	s0,sp,32
  uint64 add;
  argaddr(0, &add);
    8000315c:	fe840593          	addi	a1,s0,-24
    80003160:	4501                	li	a0,0
    80003162:	00000097          	auipc	ra,0x0
    80003166:	e98080e7          	jalr	-360(ra) # 80002ffa <argaddr>
  int pid;
  argint(0,&pid);
    8000316a:	fe440593          	addi	a1,s0,-28
    8000316e:	4501                	li	a0,0
    80003170:	00000097          	auipc	ra,0x0
    80003174:	e6a080e7          	jalr	-406(ra) # 80002fda <argint>
  return get_cfs_stats(add,pid);
    80003178:	fe442583          	lw	a1,-28(s0)
    8000317c:	fe843503          	ld	a0,-24(s0)
    80003180:	fffff097          	auipc	ra,0xfffff
    80003184:	76e080e7          	jalr	1902(ra) # 800028ee <get_cfs_stats>
}
    80003188:	60e2                	ld	ra,24(sp)
    8000318a:	6442                	ld	s0,16(sp)
    8000318c:	6105                	addi	sp,sp,32
    8000318e:	8082                	ret

0000000080003190 <sys_set_ps_priority>:

uint64 
sys_set_ps_priority(void) {//task5
    80003190:	7179                	addi	sp,sp,-48
    80003192:	f406                	sd	ra,40(sp)
    80003194:	f022                	sd	s0,32(sp)
    80003196:	ec26                	sd	s1,24(sp)
    80003198:	1800                	addi	s0,sp,48
  int priority;
  argint(0, &priority);
    8000319a:	fdc40593          	addi	a1,s0,-36
    8000319e:	4501                	li	a0,0
    800031a0:	00000097          	auipc	ra,0x0
    800031a4:	e3a080e7          	jalr	-454(ra) # 80002fda <argint>
  if (priority < 1 || priority > 10) {
    800031a8:	fdc42483          	lw	s1,-36(s0)
    800031ac:	fff4871b          	addiw	a4,s1,-1
    800031b0:	47a5                	li	a5,9
    return -1;
    800031b2:	557d                	li	a0,-1
  if (priority < 1 || priority > 10) {
    800031b4:	00e7e863          	bltu	a5,a4,800031c4 <sys_set_ps_priority+0x34>
  }
  myproc()->ps_priority = priority;
    800031b8:	fffff097          	auipc	ra,0xfffff
    800031bc:	812080e7          	jalr	-2030(ra) # 800019ca <myproc>
    800031c0:	f524                	sd	s1,104(a0)
  return 0;
    800031c2:	4501                	li	a0,0
}
    800031c4:	70a2                	ld	ra,40(sp)
    800031c6:	7402                	ld	s0,32(sp)
    800031c8:	64e2                	ld	s1,24(sp)
    800031ca:	6145                	addi	sp,sp,48
    800031cc:	8082                	ret

00000000800031ce <sys_getpid>:

uint64
sys_getpid(void)
{
    800031ce:	1141                	addi	sp,sp,-16
    800031d0:	e406                	sd	ra,8(sp)
    800031d2:	e022                	sd	s0,0(sp)
    800031d4:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800031d6:	ffffe097          	auipc	ra,0xffffe
    800031da:	7f4080e7          	jalr	2036(ra) # 800019ca <myproc>
}
    800031de:	5908                	lw	a0,48(a0)
    800031e0:	60a2                	ld	ra,8(sp)
    800031e2:	6402                	ld	s0,0(sp)
    800031e4:	0141                	addi	sp,sp,16
    800031e6:	8082                	ret

00000000800031e8 <sys_fork>:

uint64
sys_fork(void)
{
    800031e8:	1141                	addi	sp,sp,-16
    800031ea:	e406                	sd	ra,8(sp)
    800031ec:	e022                	sd	s0,0(sp)
    800031ee:	0800                	addi	s0,sp,16
  return fork();
    800031f0:	fffff097          	auipc	ra,0xfffff
    800031f4:	b90080e7          	jalr	-1136(ra) # 80001d80 <fork>
}
    800031f8:	60a2                	ld	ra,8(sp)
    800031fa:	6402                	ld	s0,0(sp)
    800031fc:	0141                	addi	sp,sp,16
    800031fe:	8082                	ret

0000000080003200 <sys_wait>:

uint64
sys_wait(void)
{
    80003200:	1101                	addi	sp,sp,-32
    80003202:	ec06                	sd	ra,24(sp)
    80003204:	e822                	sd	s0,16(sp)
    80003206:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80003208:	fe840593          	addi	a1,s0,-24
    8000320c:	4501                	li	a0,0
    8000320e:	00000097          	auipc	ra,0x0
    80003212:	dec080e7          	jalr	-532(ra) # 80002ffa <argaddr>
  uint64 p2;
  argaddr(1, &p2);
    80003216:	fe040593          	addi	a1,s0,-32
    8000321a:	4505                	li	a0,1
    8000321c:	00000097          	auipc	ra,0x0
    80003220:	dde080e7          	jalr	-546(ra) # 80002ffa <argaddr>
  return wait(p,p2);
    80003224:	fe043583          	ld	a1,-32(s0)
    80003228:	fe843503          	ld	a0,-24(s0)
    8000322c:	fffff097          	auipc	ra,0xfffff
    80003230:	4a6080e7          	jalr	1190(ra) # 800026d2 <wait>
}
    80003234:	60e2                	ld	ra,24(sp)
    80003236:	6442                	ld	s0,16(sp)
    80003238:	6105                	addi	sp,sp,32
    8000323a:	8082                	ret

000000008000323c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000323c:	7179                	addi	sp,sp,-48
    8000323e:	f406                	sd	ra,40(sp)
    80003240:	f022                	sd	s0,32(sp)
    80003242:	ec26                	sd	s1,24(sp)
    80003244:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80003246:	fdc40593          	addi	a1,s0,-36
    8000324a:	4501                	li	a0,0
    8000324c:	00000097          	auipc	ra,0x0
    80003250:	d8e080e7          	jalr	-626(ra) # 80002fda <argint>
  addr = myproc()->sz;
    80003254:	ffffe097          	auipc	ra,0xffffe
    80003258:	776080e7          	jalr	1910(ra) # 800019ca <myproc>
    8000325c:	6944                	ld	s1,144(a0)
  if(growproc(n) < 0)
    8000325e:	fdc42503          	lw	a0,-36(s0)
    80003262:	fffff097          	auipc	ra,0xfffff
    80003266:	ac2080e7          	jalr	-1342(ra) # 80001d24 <growproc>
    8000326a:	00054863          	bltz	a0,8000327a <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    8000326e:	8526                	mv	a0,s1
    80003270:	70a2                	ld	ra,40(sp)
    80003272:	7402                	ld	s0,32(sp)
    80003274:	64e2                	ld	s1,24(sp)
    80003276:	6145                	addi	sp,sp,48
    80003278:	8082                	ret
    return -1;
    8000327a:	54fd                	li	s1,-1
    8000327c:	bfcd                	j	8000326e <sys_sbrk+0x32>

000000008000327e <sys_sleep>:

uint64
sys_sleep(void)
{
    8000327e:	7139                	addi	sp,sp,-64
    80003280:	fc06                	sd	ra,56(sp)
    80003282:	f822                	sd	s0,48(sp)
    80003284:	f426                	sd	s1,40(sp)
    80003286:	f04a                	sd	s2,32(sp)
    80003288:	ec4e                	sd	s3,24(sp)
    8000328a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    8000328c:	fcc40593          	addi	a1,s0,-52
    80003290:	4501                	li	a0,0
    80003292:	00000097          	auipc	ra,0x0
    80003296:	d48080e7          	jalr	-696(ra) # 80002fda <argint>
  acquire(&tickslock);
    8000329a:	00015517          	auipc	a0,0x15
    8000329e:	93650513          	addi	a0,a0,-1738 # 80017bd0 <tickslock>
    800032a2:	ffffe097          	auipc	ra,0xffffe
    800032a6:	934080e7          	jalr	-1740(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    800032aa:	00005917          	auipc	s2,0x5
    800032ae:	68692903          	lw	s2,1670(s2) # 80008930 <ticks>
  while(ticks - ticks0 < n){
    800032b2:	fcc42783          	lw	a5,-52(s0)
    800032b6:	cf9d                	beqz	a5,800032f4 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800032b8:	00015997          	auipc	s3,0x15
    800032bc:	91898993          	addi	s3,s3,-1768 # 80017bd0 <tickslock>
    800032c0:	00005497          	auipc	s1,0x5
    800032c4:	67048493          	addi	s1,s1,1648 # 80008930 <ticks>
    if(killed(myproc())){
    800032c8:	ffffe097          	auipc	ra,0xffffe
    800032cc:	702080e7          	jalr	1794(ra) # 800019ca <myproc>
    800032d0:	fffff097          	auipc	ra,0xfffff
    800032d4:	3d0080e7          	jalr	976(ra) # 800026a0 <killed>
    800032d8:	ed15                	bnez	a0,80003314 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    800032da:	85ce                	mv	a1,s3
    800032dc:	8526                	mv	a0,s1
    800032de:	fffff097          	auipc	ra,0xfffff
    800032e2:	06e080e7          	jalr	110(ra) # 8000234c <sleep>
  while(ticks - ticks0 < n){
    800032e6:	409c                	lw	a5,0(s1)
    800032e8:	412787bb          	subw	a5,a5,s2
    800032ec:	fcc42703          	lw	a4,-52(s0)
    800032f0:	fce7ece3          	bltu	a5,a4,800032c8 <sys_sleep+0x4a>
  }
  release(&tickslock);
    800032f4:	00015517          	auipc	a0,0x15
    800032f8:	8dc50513          	addi	a0,a0,-1828 # 80017bd0 <tickslock>
    800032fc:	ffffe097          	auipc	ra,0xffffe
    80003300:	98e080e7          	jalr	-1650(ra) # 80000c8a <release>
  return 0;
    80003304:	4501                	li	a0,0
}
    80003306:	70e2                	ld	ra,56(sp)
    80003308:	7442                	ld	s0,48(sp)
    8000330a:	74a2                	ld	s1,40(sp)
    8000330c:	7902                	ld	s2,32(sp)
    8000330e:	69e2                	ld	s3,24(sp)
    80003310:	6121                	addi	sp,sp,64
    80003312:	8082                	ret
      release(&tickslock);
    80003314:	00015517          	auipc	a0,0x15
    80003318:	8bc50513          	addi	a0,a0,-1860 # 80017bd0 <tickslock>
    8000331c:	ffffe097          	auipc	ra,0xffffe
    80003320:	96e080e7          	jalr	-1682(ra) # 80000c8a <release>
      return -1;
    80003324:	557d                	li	a0,-1
    80003326:	b7c5                	j	80003306 <sys_sleep+0x88>

0000000080003328 <sys_kill>:

uint64
sys_kill(void)
{
    80003328:	1101                	addi	sp,sp,-32
    8000332a:	ec06                	sd	ra,24(sp)
    8000332c:	e822                	sd	s0,16(sp)
    8000332e:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003330:	fec40593          	addi	a1,s0,-20
    80003334:	4501                	li	a0,0
    80003336:	00000097          	auipc	ra,0x0
    8000333a:	ca4080e7          	jalr	-860(ra) # 80002fda <argint>
  return kill(pid);
    8000333e:	fec42503          	lw	a0,-20(s0)
    80003342:	fffff097          	auipc	ra,0xfffff
    80003346:	2c0080e7          	jalr	704(ra) # 80002602 <kill>
}
    8000334a:	60e2                	ld	ra,24(sp)
    8000334c:	6442                	ld	s0,16(sp)
    8000334e:	6105                	addi	sp,sp,32
    80003350:	8082                	ret

0000000080003352 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003352:	1101                	addi	sp,sp,-32
    80003354:	ec06                	sd	ra,24(sp)
    80003356:	e822                	sd	s0,16(sp)
    80003358:	e426                	sd	s1,8(sp)
    8000335a:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000335c:	00015517          	auipc	a0,0x15
    80003360:	87450513          	addi	a0,a0,-1932 # 80017bd0 <tickslock>
    80003364:	ffffe097          	auipc	ra,0xffffe
    80003368:	872080e7          	jalr	-1934(ra) # 80000bd6 <acquire>
  xticks = ticks;
    8000336c:	00005497          	auipc	s1,0x5
    80003370:	5c44a483          	lw	s1,1476(s1) # 80008930 <ticks>
  release(&tickslock);
    80003374:	00015517          	auipc	a0,0x15
    80003378:	85c50513          	addi	a0,a0,-1956 # 80017bd0 <tickslock>
    8000337c:	ffffe097          	auipc	ra,0xffffe
    80003380:	90e080e7          	jalr	-1778(ra) # 80000c8a <release>
  return xticks;
}
    80003384:	02049513          	slli	a0,s1,0x20
    80003388:	9101                	srli	a0,a0,0x20
    8000338a:	60e2                	ld	ra,24(sp)
    8000338c:	6442                	ld	s0,16(sp)
    8000338e:	64a2                	ld	s1,8(sp)
    80003390:	6105                	addi	sp,sp,32
    80003392:	8082                	ret

0000000080003394 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003394:	7179                	addi	sp,sp,-48
    80003396:	f406                	sd	ra,40(sp)
    80003398:	f022                	sd	s0,32(sp)
    8000339a:	ec26                	sd	s1,24(sp)
    8000339c:	e84a                	sd	s2,16(sp)
    8000339e:	e44e                	sd	s3,8(sp)
    800033a0:	e052                	sd	s4,0(sp)
    800033a2:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800033a4:	00005597          	auipc	a1,0x5
    800033a8:	1a458593          	addi	a1,a1,420 # 80008548 <syscalls+0xd0>
    800033ac:	00015517          	auipc	a0,0x15
    800033b0:	83c50513          	addi	a0,a0,-1988 # 80017be8 <bcache>
    800033b4:	ffffd097          	auipc	ra,0xffffd
    800033b8:	792080e7          	jalr	1938(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800033bc:	0001d797          	auipc	a5,0x1d
    800033c0:	82c78793          	addi	a5,a5,-2004 # 8001fbe8 <bcache+0x8000>
    800033c4:	0001d717          	auipc	a4,0x1d
    800033c8:	a8c70713          	addi	a4,a4,-1396 # 8001fe50 <bcache+0x8268>
    800033cc:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800033d0:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800033d4:	00015497          	auipc	s1,0x15
    800033d8:	82c48493          	addi	s1,s1,-2004 # 80017c00 <bcache+0x18>
    b->next = bcache.head.next;
    800033dc:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800033de:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800033e0:	00005a17          	auipc	s4,0x5
    800033e4:	170a0a13          	addi	s4,s4,368 # 80008550 <syscalls+0xd8>
    b->next = bcache.head.next;
    800033e8:	2b893783          	ld	a5,696(s2)
    800033ec:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800033ee:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800033f2:	85d2                	mv	a1,s4
    800033f4:	01048513          	addi	a0,s1,16
    800033f8:	00001097          	auipc	ra,0x1
    800033fc:	4c4080e7          	jalr	1220(ra) # 800048bc <initsleeplock>
    bcache.head.next->prev = b;
    80003400:	2b893783          	ld	a5,696(s2)
    80003404:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003406:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000340a:	45848493          	addi	s1,s1,1112
    8000340e:	fd349de3          	bne	s1,s3,800033e8 <binit+0x54>
  }
}
    80003412:	70a2                	ld	ra,40(sp)
    80003414:	7402                	ld	s0,32(sp)
    80003416:	64e2                	ld	s1,24(sp)
    80003418:	6942                	ld	s2,16(sp)
    8000341a:	69a2                	ld	s3,8(sp)
    8000341c:	6a02                	ld	s4,0(sp)
    8000341e:	6145                	addi	sp,sp,48
    80003420:	8082                	ret

0000000080003422 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003422:	7179                	addi	sp,sp,-48
    80003424:	f406                	sd	ra,40(sp)
    80003426:	f022                	sd	s0,32(sp)
    80003428:	ec26                	sd	s1,24(sp)
    8000342a:	e84a                	sd	s2,16(sp)
    8000342c:	e44e                	sd	s3,8(sp)
    8000342e:	1800                	addi	s0,sp,48
    80003430:	892a                	mv	s2,a0
    80003432:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003434:	00014517          	auipc	a0,0x14
    80003438:	7b450513          	addi	a0,a0,1972 # 80017be8 <bcache>
    8000343c:	ffffd097          	auipc	ra,0xffffd
    80003440:	79a080e7          	jalr	1946(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003444:	0001d497          	auipc	s1,0x1d
    80003448:	a5c4b483          	ld	s1,-1444(s1) # 8001fea0 <bcache+0x82b8>
    8000344c:	0001d797          	auipc	a5,0x1d
    80003450:	a0478793          	addi	a5,a5,-1532 # 8001fe50 <bcache+0x8268>
    80003454:	02f48f63          	beq	s1,a5,80003492 <bread+0x70>
    80003458:	873e                	mv	a4,a5
    8000345a:	a021                	j	80003462 <bread+0x40>
    8000345c:	68a4                	ld	s1,80(s1)
    8000345e:	02e48a63          	beq	s1,a4,80003492 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003462:	449c                	lw	a5,8(s1)
    80003464:	ff279ce3          	bne	a5,s2,8000345c <bread+0x3a>
    80003468:	44dc                	lw	a5,12(s1)
    8000346a:	ff3799e3          	bne	a5,s3,8000345c <bread+0x3a>
      b->refcnt++;
    8000346e:	40bc                	lw	a5,64(s1)
    80003470:	2785                	addiw	a5,a5,1
    80003472:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003474:	00014517          	auipc	a0,0x14
    80003478:	77450513          	addi	a0,a0,1908 # 80017be8 <bcache>
    8000347c:	ffffe097          	auipc	ra,0xffffe
    80003480:	80e080e7          	jalr	-2034(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003484:	01048513          	addi	a0,s1,16
    80003488:	00001097          	auipc	ra,0x1
    8000348c:	46e080e7          	jalr	1134(ra) # 800048f6 <acquiresleep>
      return b;
    80003490:	a8b9                	j	800034ee <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003492:	0001d497          	auipc	s1,0x1d
    80003496:	a064b483          	ld	s1,-1530(s1) # 8001fe98 <bcache+0x82b0>
    8000349a:	0001d797          	auipc	a5,0x1d
    8000349e:	9b678793          	addi	a5,a5,-1610 # 8001fe50 <bcache+0x8268>
    800034a2:	00f48863          	beq	s1,a5,800034b2 <bread+0x90>
    800034a6:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800034a8:	40bc                	lw	a5,64(s1)
    800034aa:	cf81                	beqz	a5,800034c2 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800034ac:	64a4                	ld	s1,72(s1)
    800034ae:	fee49de3          	bne	s1,a4,800034a8 <bread+0x86>
  panic("bget: no buffers");
    800034b2:	00005517          	auipc	a0,0x5
    800034b6:	0a650513          	addi	a0,a0,166 # 80008558 <syscalls+0xe0>
    800034ba:	ffffd097          	auipc	ra,0xffffd
    800034be:	084080e7          	jalr	132(ra) # 8000053e <panic>
      b->dev = dev;
    800034c2:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800034c6:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800034ca:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800034ce:	4785                	li	a5,1
    800034d0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800034d2:	00014517          	auipc	a0,0x14
    800034d6:	71650513          	addi	a0,a0,1814 # 80017be8 <bcache>
    800034da:	ffffd097          	auipc	ra,0xffffd
    800034de:	7b0080e7          	jalr	1968(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    800034e2:	01048513          	addi	a0,s1,16
    800034e6:	00001097          	auipc	ra,0x1
    800034ea:	410080e7          	jalr	1040(ra) # 800048f6 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800034ee:	409c                	lw	a5,0(s1)
    800034f0:	cb89                	beqz	a5,80003502 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800034f2:	8526                	mv	a0,s1
    800034f4:	70a2                	ld	ra,40(sp)
    800034f6:	7402                	ld	s0,32(sp)
    800034f8:	64e2                	ld	s1,24(sp)
    800034fa:	6942                	ld	s2,16(sp)
    800034fc:	69a2                	ld	s3,8(sp)
    800034fe:	6145                	addi	sp,sp,48
    80003500:	8082                	ret
    virtio_disk_rw(b, 0);
    80003502:	4581                	li	a1,0
    80003504:	8526                	mv	a0,s1
    80003506:	00003097          	auipc	ra,0x3
    8000350a:	fde080e7          	jalr	-34(ra) # 800064e4 <virtio_disk_rw>
    b->valid = 1;
    8000350e:	4785                	li	a5,1
    80003510:	c09c                	sw	a5,0(s1)
  return b;
    80003512:	b7c5                	j	800034f2 <bread+0xd0>

0000000080003514 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003514:	1101                	addi	sp,sp,-32
    80003516:	ec06                	sd	ra,24(sp)
    80003518:	e822                	sd	s0,16(sp)
    8000351a:	e426                	sd	s1,8(sp)
    8000351c:	1000                	addi	s0,sp,32
    8000351e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003520:	0541                	addi	a0,a0,16
    80003522:	00001097          	auipc	ra,0x1
    80003526:	46e080e7          	jalr	1134(ra) # 80004990 <holdingsleep>
    8000352a:	cd01                	beqz	a0,80003542 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000352c:	4585                	li	a1,1
    8000352e:	8526                	mv	a0,s1
    80003530:	00003097          	auipc	ra,0x3
    80003534:	fb4080e7          	jalr	-76(ra) # 800064e4 <virtio_disk_rw>
}
    80003538:	60e2                	ld	ra,24(sp)
    8000353a:	6442                	ld	s0,16(sp)
    8000353c:	64a2                	ld	s1,8(sp)
    8000353e:	6105                	addi	sp,sp,32
    80003540:	8082                	ret
    panic("bwrite");
    80003542:	00005517          	auipc	a0,0x5
    80003546:	02e50513          	addi	a0,a0,46 # 80008570 <syscalls+0xf8>
    8000354a:	ffffd097          	auipc	ra,0xffffd
    8000354e:	ff4080e7          	jalr	-12(ra) # 8000053e <panic>

0000000080003552 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003552:	1101                	addi	sp,sp,-32
    80003554:	ec06                	sd	ra,24(sp)
    80003556:	e822                	sd	s0,16(sp)
    80003558:	e426                	sd	s1,8(sp)
    8000355a:	e04a                	sd	s2,0(sp)
    8000355c:	1000                	addi	s0,sp,32
    8000355e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003560:	01050913          	addi	s2,a0,16
    80003564:	854a                	mv	a0,s2
    80003566:	00001097          	auipc	ra,0x1
    8000356a:	42a080e7          	jalr	1066(ra) # 80004990 <holdingsleep>
    8000356e:	c92d                	beqz	a0,800035e0 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003570:	854a                	mv	a0,s2
    80003572:	00001097          	auipc	ra,0x1
    80003576:	3da080e7          	jalr	986(ra) # 8000494c <releasesleep>

  acquire(&bcache.lock);
    8000357a:	00014517          	auipc	a0,0x14
    8000357e:	66e50513          	addi	a0,a0,1646 # 80017be8 <bcache>
    80003582:	ffffd097          	auipc	ra,0xffffd
    80003586:	654080e7          	jalr	1620(ra) # 80000bd6 <acquire>
  b->refcnt--;
    8000358a:	40bc                	lw	a5,64(s1)
    8000358c:	37fd                	addiw	a5,a5,-1
    8000358e:	0007871b          	sext.w	a4,a5
    80003592:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003594:	eb05                	bnez	a4,800035c4 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003596:	68bc                	ld	a5,80(s1)
    80003598:	64b8                	ld	a4,72(s1)
    8000359a:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000359c:	64bc                	ld	a5,72(s1)
    8000359e:	68b8                	ld	a4,80(s1)
    800035a0:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800035a2:	0001c797          	auipc	a5,0x1c
    800035a6:	64678793          	addi	a5,a5,1606 # 8001fbe8 <bcache+0x8000>
    800035aa:	2b87b703          	ld	a4,696(a5)
    800035ae:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800035b0:	0001d717          	auipc	a4,0x1d
    800035b4:	8a070713          	addi	a4,a4,-1888 # 8001fe50 <bcache+0x8268>
    800035b8:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800035ba:	2b87b703          	ld	a4,696(a5)
    800035be:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800035c0:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800035c4:	00014517          	auipc	a0,0x14
    800035c8:	62450513          	addi	a0,a0,1572 # 80017be8 <bcache>
    800035cc:	ffffd097          	auipc	ra,0xffffd
    800035d0:	6be080e7          	jalr	1726(ra) # 80000c8a <release>
}
    800035d4:	60e2                	ld	ra,24(sp)
    800035d6:	6442                	ld	s0,16(sp)
    800035d8:	64a2                	ld	s1,8(sp)
    800035da:	6902                	ld	s2,0(sp)
    800035dc:	6105                	addi	sp,sp,32
    800035de:	8082                	ret
    panic("brelse");
    800035e0:	00005517          	auipc	a0,0x5
    800035e4:	f9850513          	addi	a0,a0,-104 # 80008578 <syscalls+0x100>
    800035e8:	ffffd097          	auipc	ra,0xffffd
    800035ec:	f56080e7          	jalr	-170(ra) # 8000053e <panic>

00000000800035f0 <bpin>:

void
bpin(struct buf *b) {
    800035f0:	1101                	addi	sp,sp,-32
    800035f2:	ec06                	sd	ra,24(sp)
    800035f4:	e822                	sd	s0,16(sp)
    800035f6:	e426                	sd	s1,8(sp)
    800035f8:	1000                	addi	s0,sp,32
    800035fa:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800035fc:	00014517          	auipc	a0,0x14
    80003600:	5ec50513          	addi	a0,a0,1516 # 80017be8 <bcache>
    80003604:	ffffd097          	auipc	ra,0xffffd
    80003608:	5d2080e7          	jalr	1490(ra) # 80000bd6 <acquire>
  b->refcnt++;
    8000360c:	40bc                	lw	a5,64(s1)
    8000360e:	2785                	addiw	a5,a5,1
    80003610:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003612:	00014517          	auipc	a0,0x14
    80003616:	5d650513          	addi	a0,a0,1494 # 80017be8 <bcache>
    8000361a:	ffffd097          	auipc	ra,0xffffd
    8000361e:	670080e7          	jalr	1648(ra) # 80000c8a <release>
}
    80003622:	60e2                	ld	ra,24(sp)
    80003624:	6442                	ld	s0,16(sp)
    80003626:	64a2                	ld	s1,8(sp)
    80003628:	6105                	addi	sp,sp,32
    8000362a:	8082                	ret

000000008000362c <bunpin>:

void
bunpin(struct buf *b) {
    8000362c:	1101                	addi	sp,sp,-32
    8000362e:	ec06                	sd	ra,24(sp)
    80003630:	e822                	sd	s0,16(sp)
    80003632:	e426                	sd	s1,8(sp)
    80003634:	1000                	addi	s0,sp,32
    80003636:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003638:	00014517          	auipc	a0,0x14
    8000363c:	5b050513          	addi	a0,a0,1456 # 80017be8 <bcache>
    80003640:	ffffd097          	auipc	ra,0xffffd
    80003644:	596080e7          	jalr	1430(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80003648:	40bc                	lw	a5,64(s1)
    8000364a:	37fd                	addiw	a5,a5,-1
    8000364c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000364e:	00014517          	auipc	a0,0x14
    80003652:	59a50513          	addi	a0,a0,1434 # 80017be8 <bcache>
    80003656:	ffffd097          	auipc	ra,0xffffd
    8000365a:	634080e7          	jalr	1588(ra) # 80000c8a <release>
}
    8000365e:	60e2                	ld	ra,24(sp)
    80003660:	6442                	ld	s0,16(sp)
    80003662:	64a2                	ld	s1,8(sp)
    80003664:	6105                	addi	sp,sp,32
    80003666:	8082                	ret

0000000080003668 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003668:	1101                	addi	sp,sp,-32
    8000366a:	ec06                	sd	ra,24(sp)
    8000366c:	e822                	sd	s0,16(sp)
    8000366e:	e426                	sd	s1,8(sp)
    80003670:	e04a                	sd	s2,0(sp)
    80003672:	1000                	addi	s0,sp,32
    80003674:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003676:	00d5d59b          	srliw	a1,a1,0xd
    8000367a:	0001d797          	auipc	a5,0x1d
    8000367e:	c4a7a783          	lw	a5,-950(a5) # 800202c4 <sb+0x1c>
    80003682:	9dbd                	addw	a1,a1,a5
    80003684:	00000097          	auipc	ra,0x0
    80003688:	d9e080e7          	jalr	-610(ra) # 80003422 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000368c:	0074f713          	andi	a4,s1,7
    80003690:	4785                	li	a5,1
    80003692:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003696:	14ce                	slli	s1,s1,0x33
    80003698:	90d9                	srli	s1,s1,0x36
    8000369a:	00950733          	add	a4,a0,s1
    8000369e:	05874703          	lbu	a4,88(a4)
    800036a2:	00e7f6b3          	and	a3,a5,a4
    800036a6:	c69d                	beqz	a3,800036d4 <bfree+0x6c>
    800036a8:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800036aa:	94aa                	add	s1,s1,a0
    800036ac:	fff7c793          	not	a5,a5
    800036b0:	8ff9                	and	a5,a5,a4
    800036b2:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800036b6:	00001097          	auipc	ra,0x1
    800036ba:	120080e7          	jalr	288(ra) # 800047d6 <log_write>
  brelse(bp);
    800036be:	854a                	mv	a0,s2
    800036c0:	00000097          	auipc	ra,0x0
    800036c4:	e92080e7          	jalr	-366(ra) # 80003552 <brelse>
}
    800036c8:	60e2                	ld	ra,24(sp)
    800036ca:	6442                	ld	s0,16(sp)
    800036cc:	64a2                	ld	s1,8(sp)
    800036ce:	6902                	ld	s2,0(sp)
    800036d0:	6105                	addi	sp,sp,32
    800036d2:	8082                	ret
    panic("freeing free block");
    800036d4:	00005517          	auipc	a0,0x5
    800036d8:	eac50513          	addi	a0,a0,-340 # 80008580 <syscalls+0x108>
    800036dc:	ffffd097          	auipc	ra,0xffffd
    800036e0:	e62080e7          	jalr	-414(ra) # 8000053e <panic>

00000000800036e4 <balloc>:
{
    800036e4:	711d                	addi	sp,sp,-96
    800036e6:	ec86                	sd	ra,88(sp)
    800036e8:	e8a2                	sd	s0,80(sp)
    800036ea:	e4a6                	sd	s1,72(sp)
    800036ec:	e0ca                	sd	s2,64(sp)
    800036ee:	fc4e                	sd	s3,56(sp)
    800036f0:	f852                	sd	s4,48(sp)
    800036f2:	f456                	sd	s5,40(sp)
    800036f4:	f05a                	sd	s6,32(sp)
    800036f6:	ec5e                	sd	s7,24(sp)
    800036f8:	e862                	sd	s8,16(sp)
    800036fa:	e466                	sd	s9,8(sp)
    800036fc:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800036fe:	0001d797          	auipc	a5,0x1d
    80003702:	bae7a783          	lw	a5,-1106(a5) # 800202ac <sb+0x4>
    80003706:	10078163          	beqz	a5,80003808 <balloc+0x124>
    8000370a:	8baa                	mv	s7,a0
    8000370c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000370e:	0001db17          	auipc	s6,0x1d
    80003712:	b9ab0b13          	addi	s6,s6,-1126 # 800202a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003716:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003718:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000371a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000371c:	6c89                	lui	s9,0x2
    8000371e:	a061                	j	800037a6 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003720:	974a                	add	a4,a4,s2
    80003722:	8fd5                	or	a5,a5,a3
    80003724:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003728:	854a                	mv	a0,s2
    8000372a:	00001097          	auipc	ra,0x1
    8000372e:	0ac080e7          	jalr	172(ra) # 800047d6 <log_write>
        brelse(bp);
    80003732:	854a                	mv	a0,s2
    80003734:	00000097          	auipc	ra,0x0
    80003738:	e1e080e7          	jalr	-482(ra) # 80003552 <brelse>
  bp = bread(dev, bno);
    8000373c:	85a6                	mv	a1,s1
    8000373e:	855e                	mv	a0,s7
    80003740:	00000097          	auipc	ra,0x0
    80003744:	ce2080e7          	jalr	-798(ra) # 80003422 <bread>
    80003748:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000374a:	40000613          	li	a2,1024
    8000374e:	4581                	li	a1,0
    80003750:	05850513          	addi	a0,a0,88
    80003754:	ffffd097          	auipc	ra,0xffffd
    80003758:	57e080e7          	jalr	1406(ra) # 80000cd2 <memset>
  log_write(bp);
    8000375c:	854a                	mv	a0,s2
    8000375e:	00001097          	auipc	ra,0x1
    80003762:	078080e7          	jalr	120(ra) # 800047d6 <log_write>
  brelse(bp);
    80003766:	854a                	mv	a0,s2
    80003768:	00000097          	auipc	ra,0x0
    8000376c:	dea080e7          	jalr	-534(ra) # 80003552 <brelse>
}
    80003770:	8526                	mv	a0,s1
    80003772:	60e6                	ld	ra,88(sp)
    80003774:	6446                	ld	s0,80(sp)
    80003776:	64a6                	ld	s1,72(sp)
    80003778:	6906                	ld	s2,64(sp)
    8000377a:	79e2                	ld	s3,56(sp)
    8000377c:	7a42                	ld	s4,48(sp)
    8000377e:	7aa2                	ld	s5,40(sp)
    80003780:	7b02                	ld	s6,32(sp)
    80003782:	6be2                	ld	s7,24(sp)
    80003784:	6c42                	ld	s8,16(sp)
    80003786:	6ca2                	ld	s9,8(sp)
    80003788:	6125                	addi	sp,sp,96
    8000378a:	8082                	ret
    brelse(bp);
    8000378c:	854a                	mv	a0,s2
    8000378e:	00000097          	auipc	ra,0x0
    80003792:	dc4080e7          	jalr	-572(ra) # 80003552 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003796:	015c87bb          	addw	a5,s9,s5
    8000379a:	00078a9b          	sext.w	s5,a5
    8000379e:	004b2703          	lw	a4,4(s6)
    800037a2:	06eaf363          	bgeu	s5,a4,80003808 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    800037a6:	41fad79b          	sraiw	a5,s5,0x1f
    800037aa:	0137d79b          	srliw	a5,a5,0x13
    800037ae:	015787bb          	addw	a5,a5,s5
    800037b2:	40d7d79b          	sraiw	a5,a5,0xd
    800037b6:	01cb2583          	lw	a1,28(s6)
    800037ba:	9dbd                	addw	a1,a1,a5
    800037bc:	855e                	mv	a0,s7
    800037be:	00000097          	auipc	ra,0x0
    800037c2:	c64080e7          	jalr	-924(ra) # 80003422 <bread>
    800037c6:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037c8:	004b2503          	lw	a0,4(s6)
    800037cc:	000a849b          	sext.w	s1,s5
    800037d0:	8662                	mv	a2,s8
    800037d2:	faa4fde3          	bgeu	s1,a0,8000378c <balloc+0xa8>
      m = 1 << (bi % 8);
    800037d6:	41f6579b          	sraiw	a5,a2,0x1f
    800037da:	01d7d69b          	srliw	a3,a5,0x1d
    800037de:	00c6873b          	addw	a4,a3,a2
    800037e2:	00777793          	andi	a5,a4,7
    800037e6:	9f95                	subw	a5,a5,a3
    800037e8:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800037ec:	4037571b          	sraiw	a4,a4,0x3
    800037f0:	00e906b3          	add	a3,s2,a4
    800037f4:	0586c683          	lbu	a3,88(a3)
    800037f8:	00d7f5b3          	and	a1,a5,a3
    800037fc:	d195                	beqz	a1,80003720 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037fe:	2605                	addiw	a2,a2,1
    80003800:	2485                	addiw	s1,s1,1
    80003802:	fd4618e3          	bne	a2,s4,800037d2 <balloc+0xee>
    80003806:	b759                	j	8000378c <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003808:	00005517          	auipc	a0,0x5
    8000380c:	d9050513          	addi	a0,a0,-624 # 80008598 <syscalls+0x120>
    80003810:	ffffd097          	auipc	ra,0xffffd
    80003814:	d78080e7          	jalr	-648(ra) # 80000588 <printf>
  return 0;
    80003818:	4481                	li	s1,0
    8000381a:	bf99                	j	80003770 <balloc+0x8c>

000000008000381c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000381c:	7179                	addi	sp,sp,-48
    8000381e:	f406                	sd	ra,40(sp)
    80003820:	f022                	sd	s0,32(sp)
    80003822:	ec26                	sd	s1,24(sp)
    80003824:	e84a                	sd	s2,16(sp)
    80003826:	e44e                	sd	s3,8(sp)
    80003828:	e052                	sd	s4,0(sp)
    8000382a:	1800                	addi	s0,sp,48
    8000382c:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000382e:	47ad                	li	a5,11
    80003830:	02b7e763          	bltu	a5,a1,8000385e <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003834:	02059493          	slli	s1,a1,0x20
    80003838:	9081                	srli	s1,s1,0x20
    8000383a:	048a                	slli	s1,s1,0x2
    8000383c:	94aa                	add	s1,s1,a0
    8000383e:	0504a903          	lw	s2,80(s1)
    80003842:	06091e63          	bnez	s2,800038be <bmap+0xa2>
      addr = balloc(ip->dev);
    80003846:	4108                	lw	a0,0(a0)
    80003848:	00000097          	auipc	ra,0x0
    8000384c:	e9c080e7          	jalr	-356(ra) # 800036e4 <balloc>
    80003850:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003854:	06090563          	beqz	s2,800038be <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003858:	0524a823          	sw	s2,80(s1)
    8000385c:	a08d                	j	800038be <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000385e:	ff45849b          	addiw	s1,a1,-12
    80003862:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003866:	0ff00793          	li	a5,255
    8000386a:	08e7e563          	bltu	a5,a4,800038f4 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000386e:	08052903          	lw	s2,128(a0)
    80003872:	00091d63          	bnez	s2,8000388c <bmap+0x70>
      addr = balloc(ip->dev);
    80003876:	4108                	lw	a0,0(a0)
    80003878:	00000097          	auipc	ra,0x0
    8000387c:	e6c080e7          	jalr	-404(ra) # 800036e4 <balloc>
    80003880:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003884:	02090d63          	beqz	s2,800038be <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003888:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000388c:	85ca                	mv	a1,s2
    8000388e:	0009a503          	lw	a0,0(s3)
    80003892:	00000097          	auipc	ra,0x0
    80003896:	b90080e7          	jalr	-1136(ra) # 80003422 <bread>
    8000389a:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000389c:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800038a0:	02049593          	slli	a1,s1,0x20
    800038a4:	9181                	srli	a1,a1,0x20
    800038a6:	058a                	slli	a1,a1,0x2
    800038a8:	00b784b3          	add	s1,a5,a1
    800038ac:	0004a903          	lw	s2,0(s1)
    800038b0:	02090063          	beqz	s2,800038d0 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800038b4:	8552                	mv	a0,s4
    800038b6:	00000097          	auipc	ra,0x0
    800038ba:	c9c080e7          	jalr	-868(ra) # 80003552 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800038be:	854a                	mv	a0,s2
    800038c0:	70a2                	ld	ra,40(sp)
    800038c2:	7402                	ld	s0,32(sp)
    800038c4:	64e2                	ld	s1,24(sp)
    800038c6:	6942                	ld	s2,16(sp)
    800038c8:	69a2                	ld	s3,8(sp)
    800038ca:	6a02                	ld	s4,0(sp)
    800038cc:	6145                	addi	sp,sp,48
    800038ce:	8082                	ret
      addr = balloc(ip->dev);
    800038d0:	0009a503          	lw	a0,0(s3)
    800038d4:	00000097          	auipc	ra,0x0
    800038d8:	e10080e7          	jalr	-496(ra) # 800036e4 <balloc>
    800038dc:	0005091b          	sext.w	s2,a0
      if(addr){
    800038e0:	fc090ae3          	beqz	s2,800038b4 <bmap+0x98>
        a[bn] = addr;
    800038e4:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800038e8:	8552                	mv	a0,s4
    800038ea:	00001097          	auipc	ra,0x1
    800038ee:	eec080e7          	jalr	-276(ra) # 800047d6 <log_write>
    800038f2:	b7c9                	j	800038b4 <bmap+0x98>
  panic("bmap: out of range");
    800038f4:	00005517          	auipc	a0,0x5
    800038f8:	cbc50513          	addi	a0,a0,-836 # 800085b0 <syscalls+0x138>
    800038fc:	ffffd097          	auipc	ra,0xffffd
    80003900:	c42080e7          	jalr	-958(ra) # 8000053e <panic>

0000000080003904 <iget>:
{
    80003904:	7179                	addi	sp,sp,-48
    80003906:	f406                	sd	ra,40(sp)
    80003908:	f022                	sd	s0,32(sp)
    8000390a:	ec26                	sd	s1,24(sp)
    8000390c:	e84a                	sd	s2,16(sp)
    8000390e:	e44e                	sd	s3,8(sp)
    80003910:	e052                	sd	s4,0(sp)
    80003912:	1800                	addi	s0,sp,48
    80003914:	89aa                	mv	s3,a0
    80003916:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003918:	0001d517          	auipc	a0,0x1d
    8000391c:	9b050513          	addi	a0,a0,-1616 # 800202c8 <itable>
    80003920:	ffffd097          	auipc	ra,0xffffd
    80003924:	2b6080e7          	jalr	694(ra) # 80000bd6 <acquire>
  empty = 0;
    80003928:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000392a:	0001d497          	auipc	s1,0x1d
    8000392e:	9b648493          	addi	s1,s1,-1610 # 800202e0 <itable+0x18>
    80003932:	0001e697          	auipc	a3,0x1e
    80003936:	43e68693          	addi	a3,a3,1086 # 80021d70 <log>
    8000393a:	a039                	j	80003948 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000393c:	02090b63          	beqz	s2,80003972 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003940:	08848493          	addi	s1,s1,136
    80003944:	02d48a63          	beq	s1,a3,80003978 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003948:	449c                	lw	a5,8(s1)
    8000394a:	fef059e3          	blez	a5,8000393c <iget+0x38>
    8000394e:	4098                	lw	a4,0(s1)
    80003950:	ff3716e3          	bne	a4,s3,8000393c <iget+0x38>
    80003954:	40d8                	lw	a4,4(s1)
    80003956:	ff4713e3          	bne	a4,s4,8000393c <iget+0x38>
      ip->ref++;
    8000395a:	2785                	addiw	a5,a5,1
    8000395c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000395e:	0001d517          	auipc	a0,0x1d
    80003962:	96a50513          	addi	a0,a0,-1686 # 800202c8 <itable>
    80003966:	ffffd097          	auipc	ra,0xffffd
    8000396a:	324080e7          	jalr	804(ra) # 80000c8a <release>
      return ip;
    8000396e:	8926                	mv	s2,s1
    80003970:	a03d                	j	8000399e <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003972:	f7f9                	bnez	a5,80003940 <iget+0x3c>
    80003974:	8926                	mv	s2,s1
    80003976:	b7e9                	j	80003940 <iget+0x3c>
  if(empty == 0)
    80003978:	02090c63          	beqz	s2,800039b0 <iget+0xac>
  ip->dev = dev;
    8000397c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003980:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003984:	4785                	li	a5,1
    80003986:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000398a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000398e:	0001d517          	auipc	a0,0x1d
    80003992:	93a50513          	addi	a0,a0,-1734 # 800202c8 <itable>
    80003996:	ffffd097          	auipc	ra,0xffffd
    8000399a:	2f4080e7          	jalr	756(ra) # 80000c8a <release>
}
    8000399e:	854a                	mv	a0,s2
    800039a0:	70a2                	ld	ra,40(sp)
    800039a2:	7402                	ld	s0,32(sp)
    800039a4:	64e2                	ld	s1,24(sp)
    800039a6:	6942                	ld	s2,16(sp)
    800039a8:	69a2                	ld	s3,8(sp)
    800039aa:	6a02                	ld	s4,0(sp)
    800039ac:	6145                	addi	sp,sp,48
    800039ae:	8082                	ret
    panic("iget: no inodes");
    800039b0:	00005517          	auipc	a0,0x5
    800039b4:	c1850513          	addi	a0,a0,-1000 # 800085c8 <syscalls+0x150>
    800039b8:	ffffd097          	auipc	ra,0xffffd
    800039bc:	b86080e7          	jalr	-1146(ra) # 8000053e <panic>

00000000800039c0 <fsinit>:
fsinit(int dev) {
    800039c0:	7179                	addi	sp,sp,-48
    800039c2:	f406                	sd	ra,40(sp)
    800039c4:	f022                	sd	s0,32(sp)
    800039c6:	ec26                	sd	s1,24(sp)
    800039c8:	e84a                	sd	s2,16(sp)
    800039ca:	e44e                	sd	s3,8(sp)
    800039cc:	1800                	addi	s0,sp,48
    800039ce:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800039d0:	4585                	li	a1,1
    800039d2:	00000097          	auipc	ra,0x0
    800039d6:	a50080e7          	jalr	-1456(ra) # 80003422 <bread>
    800039da:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800039dc:	0001d997          	auipc	s3,0x1d
    800039e0:	8cc98993          	addi	s3,s3,-1844 # 800202a8 <sb>
    800039e4:	02000613          	li	a2,32
    800039e8:	05850593          	addi	a1,a0,88
    800039ec:	854e                	mv	a0,s3
    800039ee:	ffffd097          	auipc	ra,0xffffd
    800039f2:	340080e7          	jalr	832(ra) # 80000d2e <memmove>
  brelse(bp);
    800039f6:	8526                	mv	a0,s1
    800039f8:	00000097          	auipc	ra,0x0
    800039fc:	b5a080e7          	jalr	-1190(ra) # 80003552 <brelse>
  if(sb.magic != FSMAGIC)
    80003a00:	0009a703          	lw	a4,0(s3)
    80003a04:	102037b7          	lui	a5,0x10203
    80003a08:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003a0c:	02f71263          	bne	a4,a5,80003a30 <fsinit+0x70>
  initlog(dev, &sb);
    80003a10:	0001d597          	auipc	a1,0x1d
    80003a14:	89858593          	addi	a1,a1,-1896 # 800202a8 <sb>
    80003a18:	854a                	mv	a0,s2
    80003a1a:	00001097          	auipc	ra,0x1
    80003a1e:	b40080e7          	jalr	-1216(ra) # 8000455a <initlog>
}
    80003a22:	70a2                	ld	ra,40(sp)
    80003a24:	7402                	ld	s0,32(sp)
    80003a26:	64e2                	ld	s1,24(sp)
    80003a28:	6942                	ld	s2,16(sp)
    80003a2a:	69a2                	ld	s3,8(sp)
    80003a2c:	6145                	addi	sp,sp,48
    80003a2e:	8082                	ret
    panic("invalid file system");
    80003a30:	00005517          	auipc	a0,0x5
    80003a34:	ba850513          	addi	a0,a0,-1112 # 800085d8 <syscalls+0x160>
    80003a38:	ffffd097          	auipc	ra,0xffffd
    80003a3c:	b06080e7          	jalr	-1274(ra) # 8000053e <panic>

0000000080003a40 <iinit>:
{
    80003a40:	7179                	addi	sp,sp,-48
    80003a42:	f406                	sd	ra,40(sp)
    80003a44:	f022                	sd	s0,32(sp)
    80003a46:	ec26                	sd	s1,24(sp)
    80003a48:	e84a                	sd	s2,16(sp)
    80003a4a:	e44e                	sd	s3,8(sp)
    80003a4c:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003a4e:	00005597          	auipc	a1,0x5
    80003a52:	ba258593          	addi	a1,a1,-1118 # 800085f0 <syscalls+0x178>
    80003a56:	0001d517          	auipc	a0,0x1d
    80003a5a:	87250513          	addi	a0,a0,-1934 # 800202c8 <itable>
    80003a5e:	ffffd097          	auipc	ra,0xffffd
    80003a62:	0e8080e7          	jalr	232(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003a66:	0001d497          	auipc	s1,0x1d
    80003a6a:	88a48493          	addi	s1,s1,-1910 # 800202f0 <itable+0x28>
    80003a6e:	0001e997          	auipc	s3,0x1e
    80003a72:	31298993          	addi	s3,s3,786 # 80021d80 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003a76:	00005917          	auipc	s2,0x5
    80003a7a:	b8290913          	addi	s2,s2,-1150 # 800085f8 <syscalls+0x180>
    80003a7e:	85ca                	mv	a1,s2
    80003a80:	8526                	mv	a0,s1
    80003a82:	00001097          	auipc	ra,0x1
    80003a86:	e3a080e7          	jalr	-454(ra) # 800048bc <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003a8a:	08848493          	addi	s1,s1,136
    80003a8e:	ff3498e3          	bne	s1,s3,80003a7e <iinit+0x3e>
}
    80003a92:	70a2                	ld	ra,40(sp)
    80003a94:	7402                	ld	s0,32(sp)
    80003a96:	64e2                	ld	s1,24(sp)
    80003a98:	6942                	ld	s2,16(sp)
    80003a9a:	69a2                	ld	s3,8(sp)
    80003a9c:	6145                	addi	sp,sp,48
    80003a9e:	8082                	ret

0000000080003aa0 <ialloc>:
{
    80003aa0:	715d                	addi	sp,sp,-80
    80003aa2:	e486                	sd	ra,72(sp)
    80003aa4:	e0a2                	sd	s0,64(sp)
    80003aa6:	fc26                	sd	s1,56(sp)
    80003aa8:	f84a                	sd	s2,48(sp)
    80003aaa:	f44e                	sd	s3,40(sp)
    80003aac:	f052                	sd	s4,32(sp)
    80003aae:	ec56                	sd	s5,24(sp)
    80003ab0:	e85a                	sd	s6,16(sp)
    80003ab2:	e45e                	sd	s7,8(sp)
    80003ab4:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003ab6:	0001c717          	auipc	a4,0x1c
    80003aba:	7fe72703          	lw	a4,2046(a4) # 800202b4 <sb+0xc>
    80003abe:	4785                	li	a5,1
    80003ac0:	04e7fa63          	bgeu	a5,a4,80003b14 <ialloc+0x74>
    80003ac4:	8aaa                	mv	s5,a0
    80003ac6:	8bae                	mv	s7,a1
    80003ac8:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003aca:	0001ca17          	auipc	s4,0x1c
    80003ace:	7dea0a13          	addi	s4,s4,2014 # 800202a8 <sb>
    80003ad2:	00048b1b          	sext.w	s6,s1
    80003ad6:	0044d793          	srli	a5,s1,0x4
    80003ada:	018a2583          	lw	a1,24(s4)
    80003ade:	9dbd                	addw	a1,a1,a5
    80003ae0:	8556                	mv	a0,s5
    80003ae2:	00000097          	auipc	ra,0x0
    80003ae6:	940080e7          	jalr	-1728(ra) # 80003422 <bread>
    80003aea:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003aec:	05850993          	addi	s3,a0,88
    80003af0:	00f4f793          	andi	a5,s1,15
    80003af4:	079a                	slli	a5,a5,0x6
    80003af6:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003af8:	00099783          	lh	a5,0(s3)
    80003afc:	c3a1                	beqz	a5,80003b3c <ialloc+0x9c>
    brelse(bp);
    80003afe:	00000097          	auipc	ra,0x0
    80003b02:	a54080e7          	jalr	-1452(ra) # 80003552 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b06:	0485                	addi	s1,s1,1
    80003b08:	00ca2703          	lw	a4,12(s4)
    80003b0c:	0004879b          	sext.w	a5,s1
    80003b10:	fce7e1e3          	bltu	a5,a4,80003ad2 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003b14:	00005517          	auipc	a0,0x5
    80003b18:	aec50513          	addi	a0,a0,-1300 # 80008600 <syscalls+0x188>
    80003b1c:	ffffd097          	auipc	ra,0xffffd
    80003b20:	a6c080e7          	jalr	-1428(ra) # 80000588 <printf>
  return 0;
    80003b24:	4501                	li	a0,0
}
    80003b26:	60a6                	ld	ra,72(sp)
    80003b28:	6406                	ld	s0,64(sp)
    80003b2a:	74e2                	ld	s1,56(sp)
    80003b2c:	7942                	ld	s2,48(sp)
    80003b2e:	79a2                	ld	s3,40(sp)
    80003b30:	7a02                	ld	s4,32(sp)
    80003b32:	6ae2                	ld	s5,24(sp)
    80003b34:	6b42                	ld	s6,16(sp)
    80003b36:	6ba2                	ld	s7,8(sp)
    80003b38:	6161                	addi	sp,sp,80
    80003b3a:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003b3c:	04000613          	li	a2,64
    80003b40:	4581                	li	a1,0
    80003b42:	854e                	mv	a0,s3
    80003b44:	ffffd097          	auipc	ra,0xffffd
    80003b48:	18e080e7          	jalr	398(ra) # 80000cd2 <memset>
      dip->type = type;
    80003b4c:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003b50:	854a                	mv	a0,s2
    80003b52:	00001097          	auipc	ra,0x1
    80003b56:	c84080e7          	jalr	-892(ra) # 800047d6 <log_write>
      brelse(bp);
    80003b5a:	854a                	mv	a0,s2
    80003b5c:	00000097          	auipc	ra,0x0
    80003b60:	9f6080e7          	jalr	-1546(ra) # 80003552 <brelse>
      return iget(dev, inum);
    80003b64:	85da                	mv	a1,s6
    80003b66:	8556                	mv	a0,s5
    80003b68:	00000097          	auipc	ra,0x0
    80003b6c:	d9c080e7          	jalr	-612(ra) # 80003904 <iget>
    80003b70:	bf5d                	j	80003b26 <ialloc+0x86>

0000000080003b72 <iupdate>:
{
    80003b72:	1101                	addi	sp,sp,-32
    80003b74:	ec06                	sd	ra,24(sp)
    80003b76:	e822                	sd	s0,16(sp)
    80003b78:	e426                	sd	s1,8(sp)
    80003b7a:	e04a                	sd	s2,0(sp)
    80003b7c:	1000                	addi	s0,sp,32
    80003b7e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b80:	415c                	lw	a5,4(a0)
    80003b82:	0047d79b          	srliw	a5,a5,0x4
    80003b86:	0001c597          	auipc	a1,0x1c
    80003b8a:	73a5a583          	lw	a1,1850(a1) # 800202c0 <sb+0x18>
    80003b8e:	9dbd                	addw	a1,a1,a5
    80003b90:	4108                	lw	a0,0(a0)
    80003b92:	00000097          	auipc	ra,0x0
    80003b96:	890080e7          	jalr	-1904(ra) # 80003422 <bread>
    80003b9a:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b9c:	05850793          	addi	a5,a0,88
    80003ba0:	40c8                	lw	a0,4(s1)
    80003ba2:	893d                	andi	a0,a0,15
    80003ba4:	051a                	slli	a0,a0,0x6
    80003ba6:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003ba8:	04449703          	lh	a4,68(s1)
    80003bac:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003bb0:	04649703          	lh	a4,70(s1)
    80003bb4:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003bb8:	04849703          	lh	a4,72(s1)
    80003bbc:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003bc0:	04a49703          	lh	a4,74(s1)
    80003bc4:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003bc8:	44f8                	lw	a4,76(s1)
    80003bca:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003bcc:	03400613          	li	a2,52
    80003bd0:	05048593          	addi	a1,s1,80
    80003bd4:	0531                	addi	a0,a0,12
    80003bd6:	ffffd097          	auipc	ra,0xffffd
    80003bda:	158080e7          	jalr	344(ra) # 80000d2e <memmove>
  log_write(bp);
    80003bde:	854a                	mv	a0,s2
    80003be0:	00001097          	auipc	ra,0x1
    80003be4:	bf6080e7          	jalr	-1034(ra) # 800047d6 <log_write>
  brelse(bp);
    80003be8:	854a                	mv	a0,s2
    80003bea:	00000097          	auipc	ra,0x0
    80003bee:	968080e7          	jalr	-1688(ra) # 80003552 <brelse>
}
    80003bf2:	60e2                	ld	ra,24(sp)
    80003bf4:	6442                	ld	s0,16(sp)
    80003bf6:	64a2                	ld	s1,8(sp)
    80003bf8:	6902                	ld	s2,0(sp)
    80003bfa:	6105                	addi	sp,sp,32
    80003bfc:	8082                	ret

0000000080003bfe <idup>:
{
    80003bfe:	1101                	addi	sp,sp,-32
    80003c00:	ec06                	sd	ra,24(sp)
    80003c02:	e822                	sd	s0,16(sp)
    80003c04:	e426                	sd	s1,8(sp)
    80003c06:	1000                	addi	s0,sp,32
    80003c08:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003c0a:	0001c517          	auipc	a0,0x1c
    80003c0e:	6be50513          	addi	a0,a0,1726 # 800202c8 <itable>
    80003c12:	ffffd097          	auipc	ra,0xffffd
    80003c16:	fc4080e7          	jalr	-60(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003c1a:	449c                	lw	a5,8(s1)
    80003c1c:	2785                	addiw	a5,a5,1
    80003c1e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003c20:	0001c517          	auipc	a0,0x1c
    80003c24:	6a850513          	addi	a0,a0,1704 # 800202c8 <itable>
    80003c28:	ffffd097          	auipc	ra,0xffffd
    80003c2c:	062080e7          	jalr	98(ra) # 80000c8a <release>
}
    80003c30:	8526                	mv	a0,s1
    80003c32:	60e2                	ld	ra,24(sp)
    80003c34:	6442                	ld	s0,16(sp)
    80003c36:	64a2                	ld	s1,8(sp)
    80003c38:	6105                	addi	sp,sp,32
    80003c3a:	8082                	ret

0000000080003c3c <ilock>:
{
    80003c3c:	1101                	addi	sp,sp,-32
    80003c3e:	ec06                	sd	ra,24(sp)
    80003c40:	e822                	sd	s0,16(sp)
    80003c42:	e426                	sd	s1,8(sp)
    80003c44:	e04a                	sd	s2,0(sp)
    80003c46:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003c48:	c115                	beqz	a0,80003c6c <ilock+0x30>
    80003c4a:	84aa                	mv	s1,a0
    80003c4c:	451c                	lw	a5,8(a0)
    80003c4e:	00f05f63          	blez	a5,80003c6c <ilock+0x30>
  acquiresleep(&ip->lock);
    80003c52:	0541                	addi	a0,a0,16
    80003c54:	00001097          	auipc	ra,0x1
    80003c58:	ca2080e7          	jalr	-862(ra) # 800048f6 <acquiresleep>
  if(ip->valid == 0){
    80003c5c:	40bc                	lw	a5,64(s1)
    80003c5e:	cf99                	beqz	a5,80003c7c <ilock+0x40>
}
    80003c60:	60e2                	ld	ra,24(sp)
    80003c62:	6442                	ld	s0,16(sp)
    80003c64:	64a2                	ld	s1,8(sp)
    80003c66:	6902                	ld	s2,0(sp)
    80003c68:	6105                	addi	sp,sp,32
    80003c6a:	8082                	ret
    panic("ilock");
    80003c6c:	00005517          	auipc	a0,0x5
    80003c70:	9ac50513          	addi	a0,a0,-1620 # 80008618 <syscalls+0x1a0>
    80003c74:	ffffd097          	auipc	ra,0xffffd
    80003c78:	8ca080e7          	jalr	-1846(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003c7c:	40dc                	lw	a5,4(s1)
    80003c7e:	0047d79b          	srliw	a5,a5,0x4
    80003c82:	0001c597          	auipc	a1,0x1c
    80003c86:	63e5a583          	lw	a1,1598(a1) # 800202c0 <sb+0x18>
    80003c8a:	9dbd                	addw	a1,a1,a5
    80003c8c:	4088                	lw	a0,0(s1)
    80003c8e:	fffff097          	auipc	ra,0xfffff
    80003c92:	794080e7          	jalr	1940(ra) # 80003422 <bread>
    80003c96:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c98:	05850593          	addi	a1,a0,88
    80003c9c:	40dc                	lw	a5,4(s1)
    80003c9e:	8bbd                	andi	a5,a5,15
    80003ca0:	079a                	slli	a5,a5,0x6
    80003ca2:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003ca4:	00059783          	lh	a5,0(a1)
    80003ca8:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003cac:	00259783          	lh	a5,2(a1)
    80003cb0:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003cb4:	00459783          	lh	a5,4(a1)
    80003cb8:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003cbc:	00659783          	lh	a5,6(a1)
    80003cc0:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003cc4:	459c                	lw	a5,8(a1)
    80003cc6:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003cc8:	03400613          	li	a2,52
    80003ccc:	05b1                	addi	a1,a1,12
    80003cce:	05048513          	addi	a0,s1,80
    80003cd2:	ffffd097          	auipc	ra,0xffffd
    80003cd6:	05c080e7          	jalr	92(ra) # 80000d2e <memmove>
    brelse(bp);
    80003cda:	854a                	mv	a0,s2
    80003cdc:	00000097          	auipc	ra,0x0
    80003ce0:	876080e7          	jalr	-1930(ra) # 80003552 <brelse>
    ip->valid = 1;
    80003ce4:	4785                	li	a5,1
    80003ce6:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003ce8:	04449783          	lh	a5,68(s1)
    80003cec:	fbb5                	bnez	a5,80003c60 <ilock+0x24>
      panic("ilock: no type");
    80003cee:	00005517          	auipc	a0,0x5
    80003cf2:	93250513          	addi	a0,a0,-1742 # 80008620 <syscalls+0x1a8>
    80003cf6:	ffffd097          	auipc	ra,0xffffd
    80003cfa:	848080e7          	jalr	-1976(ra) # 8000053e <panic>

0000000080003cfe <iunlock>:
{
    80003cfe:	1101                	addi	sp,sp,-32
    80003d00:	ec06                	sd	ra,24(sp)
    80003d02:	e822                	sd	s0,16(sp)
    80003d04:	e426                	sd	s1,8(sp)
    80003d06:	e04a                	sd	s2,0(sp)
    80003d08:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003d0a:	c905                	beqz	a0,80003d3a <iunlock+0x3c>
    80003d0c:	84aa                	mv	s1,a0
    80003d0e:	01050913          	addi	s2,a0,16
    80003d12:	854a                	mv	a0,s2
    80003d14:	00001097          	auipc	ra,0x1
    80003d18:	c7c080e7          	jalr	-900(ra) # 80004990 <holdingsleep>
    80003d1c:	cd19                	beqz	a0,80003d3a <iunlock+0x3c>
    80003d1e:	449c                	lw	a5,8(s1)
    80003d20:	00f05d63          	blez	a5,80003d3a <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003d24:	854a                	mv	a0,s2
    80003d26:	00001097          	auipc	ra,0x1
    80003d2a:	c26080e7          	jalr	-986(ra) # 8000494c <releasesleep>
}
    80003d2e:	60e2                	ld	ra,24(sp)
    80003d30:	6442                	ld	s0,16(sp)
    80003d32:	64a2                	ld	s1,8(sp)
    80003d34:	6902                	ld	s2,0(sp)
    80003d36:	6105                	addi	sp,sp,32
    80003d38:	8082                	ret
    panic("iunlock");
    80003d3a:	00005517          	auipc	a0,0x5
    80003d3e:	8f650513          	addi	a0,a0,-1802 # 80008630 <syscalls+0x1b8>
    80003d42:	ffffc097          	auipc	ra,0xffffc
    80003d46:	7fc080e7          	jalr	2044(ra) # 8000053e <panic>

0000000080003d4a <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003d4a:	7179                	addi	sp,sp,-48
    80003d4c:	f406                	sd	ra,40(sp)
    80003d4e:	f022                	sd	s0,32(sp)
    80003d50:	ec26                	sd	s1,24(sp)
    80003d52:	e84a                	sd	s2,16(sp)
    80003d54:	e44e                	sd	s3,8(sp)
    80003d56:	e052                	sd	s4,0(sp)
    80003d58:	1800                	addi	s0,sp,48
    80003d5a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003d5c:	05050493          	addi	s1,a0,80
    80003d60:	08050913          	addi	s2,a0,128
    80003d64:	a021                	j	80003d6c <itrunc+0x22>
    80003d66:	0491                	addi	s1,s1,4
    80003d68:	01248d63          	beq	s1,s2,80003d82 <itrunc+0x38>
    if(ip->addrs[i]){
    80003d6c:	408c                	lw	a1,0(s1)
    80003d6e:	dde5                	beqz	a1,80003d66 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003d70:	0009a503          	lw	a0,0(s3)
    80003d74:	00000097          	auipc	ra,0x0
    80003d78:	8f4080e7          	jalr	-1804(ra) # 80003668 <bfree>
      ip->addrs[i] = 0;
    80003d7c:	0004a023          	sw	zero,0(s1)
    80003d80:	b7dd                	j	80003d66 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003d82:	0809a583          	lw	a1,128(s3)
    80003d86:	e185                	bnez	a1,80003da6 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003d88:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003d8c:	854e                	mv	a0,s3
    80003d8e:	00000097          	auipc	ra,0x0
    80003d92:	de4080e7          	jalr	-540(ra) # 80003b72 <iupdate>
}
    80003d96:	70a2                	ld	ra,40(sp)
    80003d98:	7402                	ld	s0,32(sp)
    80003d9a:	64e2                	ld	s1,24(sp)
    80003d9c:	6942                	ld	s2,16(sp)
    80003d9e:	69a2                	ld	s3,8(sp)
    80003da0:	6a02                	ld	s4,0(sp)
    80003da2:	6145                	addi	sp,sp,48
    80003da4:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003da6:	0009a503          	lw	a0,0(s3)
    80003daa:	fffff097          	auipc	ra,0xfffff
    80003dae:	678080e7          	jalr	1656(ra) # 80003422 <bread>
    80003db2:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003db4:	05850493          	addi	s1,a0,88
    80003db8:	45850913          	addi	s2,a0,1112
    80003dbc:	a021                	j	80003dc4 <itrunc+0x7a>
    80003dbe:	0491                	addi	s1,s1,4
    80003dc0:	01248b63          	beq	s1,s2,80003dd6 <itrunc+0x8c>
      if(a[j])
    80003dc4:	408c                	lw	a1,0(s1)
    80003dc6:	dde5                	beqz	a1,80003dbe <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003dc8:	0009a503          	lw	a0,0(s3)
    80003dcc:	00000097          	auipc	ra,0x0
    80003dd0:	89c080e7          	jalr	-1892(ra) # 80003668 <bfree>
    80003dd4:	b7ed                	j	80003dbe <itrunc+0x74>
    brelse(bp);
    80003dd6:	8552                	mv	a0,s4
    80003dd8:	fffff097          	auipc	ra,0xfffff
    80003ddc:	77a080e7          	jalr	1914(ra) # 80003552 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003de0:	0809a583          	lw	a1,128(s3)
    80003de4:	0009a503          	lw	a0,0(s3)
    80003de8:	00000097          	auipc	ra,0x0
    80003dec:	880080e7          	jalr	-1920(ra) # 80003668 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003df0:	0809a023          	sw	zero,128(s3)
    80003df4:	bf51                	j	80003d88 <itrunc+0x3e>

0000000080003df6 <iput>:
{
    80003df6:	1101                	addi	sp,sp,-32
    80003df8:	ec06                	sd	ra,24(sp)
    80003dfa:	e822                	sd	s0,16(sp)
    80003dfc:	e426                	sd	s1,8(sp)
    80003dfe:	e04a                	sd	s2,0(sp)
    80003e00:	1000                	addi	s0,sp,32
    80003e02:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003e04:	0001c517          	auipc	a0,0x1c
    80003e08:	4c450513          	addi	a0,a0,1220 # 800202c8 <itable>
    80003e0c:	ffffd097          	auipc	ra,0xffffd
    80003e10:	dca080e7          	jalr	-566(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e14:	4498                	lw	a4,8(s1)
    80003e16:	4785                	li	a5,1
    80003e18:	02f70363          	beq	a4,a5,80003e3e <iput+0x48>
  ip->ref--;
    80003e1c:	449c                	lw	a5,8(s1)
    80003e1e:	37fd                	addiw	a5,a5,-1
    80003e20:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003e22:	0001c517          	auipc	a0,0x1c
    80003e26:	4a650513          	addi	a0,a0,1190 # 800202c8 <itable>
    80003e2a:	ffffd097          	auipc	ra,0xffffd
    80003e2e:	e60080e7          	jalr	-416(ra) # 80000c8a <release>
}
    80003e32:	60e2                	ld	ra,24(sp)
    80003e34:	6442                	ld	s0,16(sp)
    80003e36:	64a2                	ld	s1,8(sp)
    80003e38:	6902                	ld	s2,0(sp)
    80003e3a:	6105                	addi	sp,sp,32
    80003e3c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e3e:	40bc                	lw	a5,64(s1)
    80003e40:	dff1                	beqz	a5,80003e1c <iput+0x26>
    80003e42:	04a49783          	lh	a5,74(s1)
    80003e46:	fbf9                	bnez	a5,80003e1c <iput+0x26>
    acquiresleep(&ip->lock);
    80003e48:	01048913          	addi	s2,s1,16
    80003e4c:	854a                	mv	a0,s2
    80003e4e:	00001097          	auipc	ra,0x1
    80003e52:	aa8080e7          	jalr	-1368(ra) # 800048f6 <acquiresleep>
    release(&itable.lock);
    80003e56:	0001c517          	auipc	a0,0x1c
    80003e5a:	47250513          	addi	a0,a0,1138 # 800202c8 <itable>
    80003e5e:	ffffd097          	auipc	ra,0xffffd
    80003e62:	e2c080e7          	jalr	-468(ra) # 80000c8a <release>
    itrunc(ip);
    80003e66:	8526                	mv	a0,s1
    80003e68:	00000097          	auipc	ra,0x0
    80003e6c:	ee2080e7          	jalr	-286(ra) # 80003d4a <itrunc>
    ip->type = 0;
    80003e70:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003e74:	8526                	mv	a0,s1
    80003e76:	00000097          	auipc	ra,0x0
    80003e7a:	cfc080e7          	jalr	-772(ra) # 80003b72 <iupdate>
    ip->valid = 0;
    80003e7e:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003e82:	854a                	mv	a0,s2
    80003e84:	00001097          	auipc	ra,0x1
    80003e88:	ac8080e7          	jalr	-1336(ra) # 8000494c <releasesleep>
    acquire(&itable.lock);
    80003e8c:	0001c517          	auipc	a0,0x1c
    80003e90:	43c50513          	addi	a0,a0,1084 # 800202c8 <itable>
    80003e94:	ffffd097          	auipc	ra,0xffffd
    80003e98:	d42080e7          	jalr	-702(ra) # 80000bd6 <acquire>
    80003e9c:	b741                	j	80003e1c <iput+0x26>

0000000080003e9e <iunlockput>:
{
    80003e9e:	1101                	addi	sp,sp,-32
    80003ea0:	ec06                	sd	ra,24(sp)
    80003ea2:	e822                	sd	s0,16(sp)
    80003ea4:	e426                	sd	s1,8(sp)
    80003ea6:	1000                	addi	s0,sp,32
    80003ea8:	84aa                	mv	s1,a0
  iunlock(ip);
    80003eaa:	00000097          	auipc	ra,0x0
    80003eae:	e54080e7          	jalr	-428(ra) # 80003cfe <iunlock>
  iput(ip);
    80003eb2:	8526                	mv	a0,s1
    80003eb4:	00000097          	auipc	ra,0x0
    80003eb8:	f42080e7          	jalr	-190(ra) # 80003df6 <iput>
}
    80003ebc:	60e2                	ld	ra,24(sp)
    80003ebe:	6442                	ld	s0,16(sp)
    80003ec0:	64a2                	ld	s1,8(sp)
    80003ec2:	6105                	addi	sp,sp,32
    80003ec4:	8082                	ret

0000000080003ec6 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003ec6:	1141                	addi	sp,sp,-16
    80003ec8:	e422                	sd	s0,8(sp)
    80003eca:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003ecc:	411c                	lw	a5,0(a0)
    80003ece:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003ed0:	415c                	lw	a5,4(a0)
    80003ed2:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003ed4:	04451783          	lh	a5,68(a0)
    80003ed8:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003edc:	04a51783          	lh	a5,74(a0)
    80003ee0:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003ee4:	04c56783          	lwu	a5,76(a0)
    80003ee8:	e99c                	sd	a5,16(a1)
}
    80003eea:	6422                	ld	s0,8(sp)
    80003eec:	0141                	addi	sp,sp,16
    80003eee:	8082                	ret

0000000080003ef0 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ef0:	457c                	lw	a5,76(a0)
    80003ef2:	0ed7e963          	bltu	a5,a3,80003fe4 <readi+0xf4>
{
    80003ef6:	7159                	addi	sp,sp,-112
    80003ef8:	f486                	sd	ra,104(sp)
    80003efa:	f0a2                	sd	s0,96(sp)
    80003efc:	eca6                	sd	s1,88(sp)
    80003efe:	e8ca                	sd	s2,80(sp)
    80003f00:	e4ce                	sd	s3,72(sp)
    80003f02:	e0d2                	sd	s4,64(sp)
    80003f04:	fc56                	sd	s5,56(sp)
    80003f06:	f85a                	sd	s6,48(sp)
    80003f08:	f45e                	sd	s7,40(sp)
    80003f0a:	f062                	sd	s8,32(sp)
    80003f0c:	ec66                	sd	s9,24(sp)
    80003f0e:	e86a                	sd	s10,16(sp)
    80003f10:	e46e                	sd	s11,8(sp)
    80003f12:	1880                	addi	s0,sp,112
    80003f14:	8b2a                	mv	s6,a0
    80003f16:	8bae                	mv	s7,a1
    80003f18:	8a32                	mv	s4,a2
    80003f1a:	84b6                	mv	s1,a3
    80003f1c:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003f1e:	9f35                	addw	a4,a4,a3
    return 0;
    80003f20:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003f22:	0ad76063          	bltu	a4,a3,80003fc2 <readi+0xd2>
  if(off + n > ip->size)
    80003f26:	00e7f463          	bgeu	a5,a4,80003f2e <readi+0x3e>
    n = ip->size - off;
    80003f2a:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f2e:	0a0a8963          	beqz	s5,80003fe0 <readi+0xf0>
    80003f32:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f34:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003f38:	5c7d                	li	s8,-1
    80003f3a:	a82d                	j	80003f74 <readi+0x84>
    80003f3c:	020d1d93          	slli	s11,s10,0x20
    80003f40:	020ddd93          	srli	s11,s11,0x20
    80003f44:	05890793          	addi	a5,s2,88
    80003f48:	86ee                	mv	a3,s11
    80003f4a:	963e                	add	a2,a2,a5
    80003f4c:	85d2                	mv	a1,s4
    80003f4e:	855e                	mv	a0,s7
    80003f50:	fffff097          	auipc	ra,0xfffff
    80003f54:	8f2080e7          	jalr	-1806(ra) # 80002842 <either_copyout>
    80003f58:	05850d63          	beq	a0,s8,80003fb2 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003f5c:	854a                	mv	a0,s2
    80003f5e:	fffff097          	auipc	ra,0xfffff
    80003f62:	5f4080e7          	jalr	1524(ra) # 80003552 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f66:	013d09bb          	addw	s3,s10,s3
    80003f6a:	009d04bb          	addw	s1,s10,s1
    80003f6e:	9a6e                	add	s4,s4,s11
    80003f70:	0559f763          	bgeu	s3,s5,80003fbe <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003f74:	00a4d59b          	srliw	a1,s1,0xa
    80003f78:	855a                	mv	a0,s6
    80003f7a:	00000097          	auipc	ra,0x0
    80003f7e:	8a2080e7          	jalr	-1886(ra) # 8000381c <bmap>
    80003f82:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003f86:	cd85                	beqz	a1,80003fbe <readi+0xce>
    bp = bread(ip->dev, addr);
    80003f88:	000b2503          	lw	a0,0(s6)
    80003f8c:	fffff097          	auipc	ra,0xfffff
    80003f90:	496080e7          	jalr	1174(ra) # 80003422 <bread>
    80003f94:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f96:	3ff4f613          	andi	a2,s1,1023
    80003f9a:	40cc87bb          	subw	a5,s9,a2
    80003f9e:	413a873b          	subw	a4,s5,s3
    80003fa2:	8d3e                	mv	s10,a5
    80003fa4:	2781                	sext.w	a5,a5
    80003fa6:	0007069b          	sext.w	a3,a4
    80003faa:	f8f6f9e3          	bgeu	a3,a5,80003f3c <readi+0x4c>
    80003fae:	8d3a                	mv	s10,a4
    80003fb0:	b771                	j	80003f3c <readi+0x4c>
      brelse(bp);
    80003fb2:	854a                	mv	a0,s2
    80003fb4:	fffff097          	auipc	ra,0xfffff
    80003fb8:	59e080e7          	jalr	1438(ra) # 80003552 <brelse>
      tot = -1;
    80003fbc:	59fd                	li	s3,-1
  }
  return tot;
    80003fbe:	0009851b          	sext.w	a0,s3
}
    80003fc2:	70a6                	ld	ra,104(sp)
    80003fc4:	7406                	ld	s0,96(sp)
    80003fc6:	64e6                	ld	s1,88(sp)
    80003fc8:	6946                	ld	s2,80(sp)
    80003fca:	69a6                	ld	s3,72(sp)
    80003fcc:	6a06                	ld	s4,64(sp)
    80003fce:	7ae2                	ld	s5,56(sp)
    80003fd0:	7b42                	ld	s6,48(sp)
    80003fd2:	7ba2                	ld	s7,40(sp)
    80003fd4:	7c02                	ld	s8,32(sp)
    80003fd6:	6ce2                	ld	s9,24(sp)
    80003fd8:	6d42                	ld	s10,16(sp)
    80003fda:	6da2                	ld	s11,8(sp)
    80003fdc:	6165                	addi	sp,sp,112
    80003fde:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003fe0:	89d6                	mv	s3,s5
    80003fe2:	bff1                	j	80003fbe <readi+0xce>
    return 0;
    80003fe4:	4501                	li	a0,0
}
    80003fe6:	8082                	ret

0000000080003fe8 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003fe8:	457c                	lw	a5,76(a0)
    80003fea:	10d7e863          	bltu	a5,a3,800040fa <writei+0x112>
{
    80003fee:	7159                	addi	sp,sp,-112
    80003ff0:	f486                	sd	ra,104(sp)
    80003ff2:	f0a2                	sd	s0,96(sp)
    80003ff4:	eca6                	sd	s1,88(sp)
    80003ff6:	e8ca                	sd	s2,80(sp)
    80003ff8:	e4ce                	sd	s3,72(sp)
    80003ffa:	e0d2                	sd	s4,64(sp)
    80003ffc:	fc56                	sd	s5,56(sp)
    80003ffe:	f85a                	sd	s6,48(sp)
    80004000:	f45e                	sd	s7,40(sp)
    80004002:	f062                	sd	s8,32(sp)
    80004004:	ec66                	sd	s9,24(sp)
    80004006:	e86a                	sd	s10,16(sp)
    80004008:	e46e                	sd	s11,8(sp)
    8000400a:	1880                	addi	s0,sp,112
    8000400c:	8aaa                	mv	s5,a0
    8000400e:	8bae                	mv	s7,a1
    80004010:	8a32                	mv	s4,a2
    80004012:	8936                	mv	s2,a3
    80004014:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004016:	00e687bb          	addw	a5,a3,a4
    8000401a:	0ed7e263          	bltu	a5,a3,800040fe <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000401e:	00043737          	lui	a4,0x43
    80004022:	0ef76063          	bltu	a4,a5,80004102 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004026:	0c0b0863          	beqz	s6,800040f6 <writei+0x10e>
    8000402a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000402c:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004030:	5c7d                	li	s8,-1
    80004032:	a091                	j	80004076 <writei+0x8e>
    80004034:	020d1d93          	slli	s11,s10,0x20
    80004038:	020ddd93          	srli	s11,s11,0x20
    8000403c:	05848793          	addi	a5,s1,88
    80004040:	86ee                	mv	a3,s11
    80004042:	8652                	mv	a2,s4
    80004044:	85de                	mv	a1,s7
    80004046:	953e                	add	a0,a0,a5
    80004048:	fffff097          	auipc	ra,0xfffff
    8000404c:	850080e7          	jalr	-1968(ra) # 80002898 <either_copyin>
    80004050:	07850263          	beq	a0,s8,800040b4 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004054:	8526                	mv	a0,s1
    80004056:	00000097          	auipc	ra,0x0
    8000405a:	780080e7          	jalr	1920(ra) # 800047d6 <log_write>
    brelse(bp);
    8000405e:	8526                	mv	a0,s1
    80004060:	fffff097          	auipc	ra,0xfffff
    80004064:	4f2080e7          	jalr	1266(ra) # 80003552 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004068:	013d09bb          	addw	s3,s10,s3
    8000406c:	012d093b          	addw	s2,s10,s2
    80004070:	9a6e                	add	s4,s4,s11
    80004072:	0569f663          	bgeu	s3,s6,800040be <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80004076:	00a9559b          	srliw	a1,s2,0xa
    8000407a:	8556                	mv	a0,s5
    8000407c:	fffff097          	auipc	ra,0xfffff
    80004080:	7a0080e7          	jalr	1952(ra) # 8000381c <bmap>
    80004084:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004088:	c99d                	beqz	a1,800040be <writei+0xd6>
    bp = bread(ip->dev, addr);
    8000408a:	000aa503          	lw	a0,0(s5)
    8000408e:	fffff097          	auipc	ra,0xfffff
    80004092:	394080e7          	jalr	916(ra) # 80003422 <bread>
    80004096:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004098:	3ff97513          	andi	a0,s2,1023
    8000409c:	40ac87bb          	subw	a5,s9,a0
    800040a0:	413b073b          	subw	a4,s6,s3
    800040a4:	8d3e                	mv	s10,a5
    800040a6:	2781                	sext.w	a5,a5
    800040a8:	0007069b          	sext.w	a3,a4
    800040ac:	f8f6f4e3          	bgeu	a3,a5,80004034 <writei+0x4c>
    800040b0:	8d3a                	mv	s10,a4
    800040b2:	b749                	j	80004034 <writei+0x4c>
      brelse(bp);
    800040b4:	8526                	mv	a0,s1
    800040b6:	fffff097          	auipc	ra,0xfffff
    800040ba:	49c080e7          	jalr	1180(ra) # 80003552 <brelse>
  }

  if(off > ip->size)
    800040be:	04caa783          	lw	a5,76(s5)
    800040c2:	0127f463          	bgeu	a5,s2,800040ca <writei+0xe2>
    ip->size = off;
    800040c6:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800040ca:	8556                	mv	a0,s5
    800040cc:	00000097          	auipc	ra,0x0
    800040d0:	aa6080e7          	jalr	-1370(ra) # 80003b72 <iupdate>

  return tot;
    800040d4:	0009851b          	sext.w	a0,s3
}
    800040d8:	70a6                	ld	ra,104(sp)
    800040da:	7406                	ld	s0,96(sp)
    800040dc:	64e6                	ld	s1,88(sp)
    800040de:	6946                	ld	s2,80(sp)
    800040e0:	69a6                	ld	s3,72(sp)
    800040e2:	6a06                	ld	s4,64(sp)
    800040e4:	7ae2                	ld	s5,56(sp)
    800040e6:	7b42                	ld	s6,48(sp)
    800040e8:	7ba2                	ld	s7,40(sp)
    800040ea:	7c02                	ld	s8,32(sp)
    800040ec:	6ce2                	ld	s9,24(sp)
    800040ee:	6d42                	ld	s10,16(sp)
    800040f0:	6da2                	ld	s11,8(sp)
    800040f2:	6165                	addi	sp,sp,112
    800040f4:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800040f6:	89da                	mv	s3,s6
    800040f8:	bfc9                	j	800040ca <writei+0xe2>
    return -1;
    800040fa:	557d                	li	a0,-1
}
    800040fc:	8082                	ret
    return -1;
    800040fe:	557d                	li	a0,-1
    80004100:	bfe1                	j	800040d8 <writei+0xf0>
    return -1;
    80004102:	557d                	li	a0,-1
    80004104:	bfd1                	j	800040d8 <writei+0xf0>

0000000080004106 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004106:	1141                	addi	sp,sp,-16
    80004108:	e406                	sd	ra,8(sp)
    8000410a:	e022                	sd	s0,0(sp)
    8000410c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000410e:	4639                	li	a2,14
    80004110:	ffffd097          	auipc	ra,0xffffd
    80004114:	c92080e7          	jalr	-878(ra) # 80000da2 <strncmp>
}
    80004118:	60a2                	ld	ra,8(sp)
    8000411a:	6402                	ld	s0,0(sp)
    8000411c:	0141                	addi	sp,sp,16
    8000411e:	8082                	ret

0000000080004120 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004120:	7139                	addi	sp,sp,-64
    80004122:	fc06                	sd	ra,56(sp)
    80004124:	f822                	sd	s0,48(sp)
    80004126:	f426                	sd	s1,40(sp)
    80004128:	f04a                	sd	s2,32(sp)
    8000412a:	ec4e                	sd	s3,24(sp)
    8000412c:	e852                	sd	s4,16(sp)
    8000412e:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004130:	04451703          	lh	a4,68(a0)
    80004134:	4785                	li	a5,1
    80004136:	00f71a63          	bne	a4,a5,8000414a <dirlookup+0x2a>
    8000413a:	892a                	mv	s2,a0
    8000413c:	89ae                	mv	s3,a1
    8000413e:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004140:	457c                	lw	a5,76(a0)
    80004142:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004144:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004146:	e79d                	bnez	a5,80004174 <dirlookup+0x54>
    80004148:	a8a5                	j	800041c0 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    8000414a:	00004517          	auipc	a0,0x4
    8000414e:	4ee50513          	addi	a0,a0,1262 # 80008638 <syscalls+0x1c0>
    80004152:	ffffc097          	auipc	ra,0xffffc
    80004156:	3ec080e7          	jalr	1004(ra) # 8000053e <panic>
      panic("dirlookup read");
    8000415a:	00004517          	auipc	a0,0x4
    8000415e:	4f650513          	addi	a0,a0,1270 # 80008650 <syscalls+0x1d8>
    80004162:	ffffc097          	auipc	ra,0xffffc
    80004166:	3dc080e7          	jalr	988(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000416a:	24c1                	addiw	s1,s1,16
    8000416c:	04c92783          	lw	a5,76(s2)
    80004170:	04f4f763          	bgeu	s1,a5,800041be <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004174:	4741                	li	a4,16
    80004176:	86a6                	mv	a3,s1
    80004178:	fc040613          	addi	a2,s0,-64
    8000417c:	4581                	li	a1,0
    8000417e:	854a                	mv	a0,s2
    80004180:	00000097          	auipc	ra,0x0
    80004184:	d70080e7          	jalr	-656(ra) # 80003ef0 <readi>
    80004188:	47c1                	li	a5,16
    8000418a:	fcf518e3          	bne	a0,a5,8000415a <dirlookup+0x3a>
    if(de.inum == 0)
    8000418e:	fc045783          	lhu	a5,-64(s0)
    80004192:	dfe1                	beqz	a5,8000416a <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004194:	fc240593          	addi	a1,s0,-62
    80004198:	854e                	mv	a0,s3
    8000419a:	00000097          	auipc	ra,0x0
    8000419e:	f6c080e7          	jalr	-148(ra) # 80004106 <namecmp>
    800041a2:	f561                	bnez	a0,8000416a <dirlookup+0x4a>
      if(poff)
    800041a4:	000a0463          	beqz	s4,800041ac <dirlookup+0x8c>
        *poff = off;
    800041a8:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800041ac:	fc045583          	lhu	a1,-64(s0)
    800041b0:	00092503          	lw	a0,0(s2)
    800041b4:	fffff097          	auipc	ra,0xfffff
    800041b8:	750080e7          	jalr	1872(ra) # 80003904 <iget>
    800041bc:	a011                	j	800041c0 <dirlookup+0xa0>
  return 0;
    800041be:	4501                	li	a0,0
}
    800041c0:	70e2                	ld	ra,56(sp)
    800041c2:	7442                	ld	s0,48(sp)
    800041c4:	74a2                	ld	s1,40(sp)
    800041c6:	7902                	ld	s2,32(sp)
    800041c8:	69e2                	ld	s3,24(sp)
    800041ca:	6a42                	ld	s4,16(sp)
    800041cc:	6121                	addi	sp,sp,64
    800041ce:	8082                	ret

00000000800041d0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800041d0:	711d                	addi	sp,sp,-96
    800041d2:	ec86                	sd	ra,88(sp)
    800041d4:	e8a2                	sd	s0,80(sp)
    800041d6:	e4a6                	sd	s1,72(sp)
    800041d8:	e0ca                	sd	s2,64(sp)
    800041da:	fc4e                	sd	s3,56(sp)
    800041dc:	f852                	sd	s4,48(sp)
    800041de:	f456                	sd	s5,40(sp)
    800041e0:	f05a                	sd	s6,32(sp)
    800041e2:	ec5e                	sd	s7,24(sp)
    800041e4:	e862                	sd	s8,16(sp)
    800041e6:	e466                	sd	s9,8(sp)
    800041e8:	1080                	addi	s0,sp,96
    800041ea:	84aa                	mv	s1,a0
    800041ec:	8aae                	mv	s5,a1
    800041ee:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    800041f0:	00054703          	lbu	a4,0(a0)
    800041f4:	02f00793          	li	a5,47
    800041f8:	02f70363          	beq	a4,a5,8000421e <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800041fc:	ffffd097          	auipc	ra,0xffffd
    80004200:	7ce080e7          	jalr	1998(ra) # 800019ca <myproc>
    80004204:	19853503          	ld	a0,408(a0)
    80004208:	00000097          	auipc	ra,0x0
    8000420c:	9f6080e7          	jalr	-1546(ra) # 80003bfe <idup>
    80004210:	89aa                	mv	s3,a0
  while(*path == '/')
    80004212:	02f00913          	li	s2,47
  len = path - s;
    80004216:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004218:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000421a:	4b85                	li	s7,1
    8000421c:	a865                	j	800042d4 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    8000421e:	4585                	li	a1,1
    80004220:	4505                	li	a0,1
    80004222:	fffff097          	auipc	ra,0xfffff
    80004226:	6e2080e7          	jalr	1762(ra) # 80003904 <iget>
    8000422a:	89aa                	mv	s3,a0
    8000422c:	b7dd                	j	80004212 <namex+0x42>
      iunlockput(ip);
    8000422e:	854e                	mv	a0,s3
    80004230:	00000097          	auipc	ra,0x0
    80004234:	c6e080e7          	jalr	-914(ra) # 80003e9e <iunlockput>
      return 0;
    80004238:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    8000423a:	854e                	mv	a0,s3
    8000423c:	60e6                	ld	ra,88(sp)
    8000423e:	6446                	ld	s0,80(sp)
    80004240:	64a6                	ld	s1,72(sp)
    80004242:	6906                	ld	s2,64(sp)
    80004244:	79e2                	ld	s3,56(sp)
    80004246:	7a42                	ld	s4,48(sp)
    80004248:	7aa2                	ld	s5,40(sp)
    8000424a:	7b02                	ld	s6,32(sp)
    8000424c:	6be2                	ld	s7,24(sp)
    8000424e:	6c42                	ld	s8,16(sp)
    80004250:	6ca2                	ld	s9,8(sp)
    80004252:	6125                	addi	sp,sp,96
    80004254:	8082                	ret
      iunlock(ip);
    80004256:	854e                	mv	a0,s3
    80004258:	00000097          	auipc	ra,0x0
    8000425c:	aa6080e7          	jalr	-1370(ra) # 80003cfe <iunlock>
      return ip;
    80004260:	bfe9                	j	8000423a <namex+0x6a>
      iunlockput(ip);
    80004262:	854e                	mv	a0,s3
    80004264:	00000097          	auipc	ra,0x0
    80004268:	c3a080e7          	jalr	-966(ra) # 80003e9e <iunlockput>
      return 0;
    8000426c:	89e6                	mv	s3,s9
    8000426e:	b7f1                	j	8000423a <namex+0x6a>
  len = path - s;
    80004270:	40b48633          	sub	a2,s1,a1
    80004274:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004278:	099c5463          	bge	s8,s9,80004300 <namex+0x130>
    memmove(name, s, DIRSIZ);
    8000427c:	4639                	li	a2,14
    8000427e:	8552                	mv	a0,s4
    80004280:	ffffd097          	auipc	ra,0xffffd
    80004284:	aae080e7          	jalr	-1362(ra) # 80000d2e <memmove>
  while(*path == '/')
    80004288:	0004c783          	lbu	a5,0(s1)
    8000428c:	01279763          	bne	a5,s2,8000429a <namex+0xca>
    path++;
    80004290:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004292:	0004c783          	lbu	a5,0(s1)
    80004296:	ff278de3          	beq	a5,s2,80004290 <namex+0xc0>
    ilock(ip);
    8000429a:	854e                	mv	a0,s3
    8000429c:	00000097          	auipc	ra,0x0
    800042a0:	9a0080e7          	jalr	-1632(ra) # 80003c3c <ilock>
    if(ip->type != T_DIR){
    800042a4:	04499783          	lh	a5,68(s3)
    800042a8:	f97793e3          	bne	a5,s7,8000422e <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800042ac:	000a8563          	beqz	s5,800042b6 <namex+0xe6>
    800042b0:	0004c783          	lbu	a5,0(s1)
    800042b4:	d3cd                	beqz	a5,80004256 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800042b6:	865a                	mv	a2,s6
    800042b8:	85d2                	mv	a1,s4
    800042ba:	854e                	mv	a0,s3
    800042bc:	00000097          	auipc	ra,0x0
    800042c0:	e64080e7          	jalr	-412(ra) # 80004120 <dirlookup>
    800042c4:	8caa                	mv	s9,a0
    800042c6:	dd51                	beqz	a0,80004262 <namex+0x92>
    iunlockput(ip);
    800042c8:	854e                	mv	a0,s3
    800042ca:	00000097          	auipc	ra,0x0
    800042ce:	bd4080e7          	jalr	-1068(ra) # 80003e9e <iunlockput>
    ip = next;
    800042d2:	89e6                	mv	s3,s9
  while(*path == '/')
    800042d4:	0004c783          	lbu	a5,0(s1)
    800042d8:	05279763          	bne	a5,s2,80004326 <namex+0x156>
    path++;
    800042dc:	0485                	addi	s1,s1,1
  while(*path == '/')
    800042de:	0004c783          	lbu	a5,0(s1)
    800042e2:	ff278de3          	beq	a5,s2,800042dc <namex+0x10c>
  if(*path == 0)
    800042e6:	c79d                	beqz	a5,80004314 <namex+0x144>
    path++;
    800042e8:	85a6                	mv	a1,s1
  len = path - s;
    800042ea:	8cda                	mv	s9,s6
    800042ec:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    800042ee:	01278963          	beq	a5,s2,80004300 <namex+0x130>
    800042f2:	dfbd                	beqz	a5,80004270 <namex+0xa0>
    path++;
    800042f4:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800042f6:	0004c783          	lbu	a5,0(s1)
    800042fa:	ff279ce3          	bne	a5,s2,800042f2 <namex+0x122>
    800042fe:	bf8d                	j	80004270 <namex+0xa0>
    memmove(name, s, len);
    80004300:	2601                	sext.w	a2,a2
    80004302:	8552                	mv	a0,s4
    80004304:	ffffd097          	auipc	ra,0xffffd
    80004308:	a2a080e7          	jalr	-1494(ra) # 80000d2e <memmove>
    name[len] = 0;
    8000430c:	9cd2                	add	s9,s9,s4
    8000430e:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004312:	bf9d                	j	80004288 <namex+0xb8>
  if(nameiparent){
    80004314:	f20a83e3          	beqz	s5,8000423a <namex+0x6a>
    iput(ip);
    80004318:	854e                	mv	a0,s3
    8000431a:	00000097          	auipc	ra,0x0
    8000431e:	adc080e7          	jalr	-1316(ra) # 80003df6 <iput>
    return 0;
    80004322:	4981                	li	s3,0
    80004324:	bf19                	j	8000423a <namex+0x6a>
  if(*path == 0)
    80004326:	d7fd                	beqz	a5,80004314 <namex+0x144>
  while(*path != '/' && *path != 0)
    80004328:	0004c783          	lbu	a5,0(s1)
    8000432c:	85a6                	mv	a1,s1
    8000432e:	b7d1                	j	800042f2 <namex+0x122>

0000000080004330 <dirlink>:
{
    80004330:	7139                	addi	sp,sp,-64
    80004332:	fc06                	sd	ra,56(sp)
    80004334:	f822                	sd	s0,48(sp)
    80004336:	f426                	sd	s1,40(sp)
    80004338:	f04a                	sd	s2,32(sp)
    8000433a:	ec4e                	sd	s3,24(sp)
    8000433c:	e852                	sd	s4,16(sp)
    8000433e:	0080                	addi	s0,sp,64
    80004340:	892a                	mv	s2,a0
    80004342:	8a2e                	mv	s4,a1
    80004344:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004346:	4601                	li	a2,0
    80004348:	00000097          	auipc	ra,0x0
    8000434c:	dd8080e7          	jalr	-552(ra) # 80004120 <dirlookup>
    80004350:	e93d                	bnez	a0,800043c6 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004352:	04c92483          	lw	s1,76(s2)
    80004356:	c49d                	beqz	s1,80004384 <dirlink+0x54>
    80004358:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000435a:	4741                	li	a4,16
    8000435c:	86a6                	mv	a3,s1
    8000435e:	fc040613          	addi	a2,s0,-64
    80004362:	4581                	li	a1,0
    80004364:	854a                	mv	a0,s2
    80004366:	00000097          	auipc	ra,0x0
    8000436a:	b8a080e7          	jalr	-1142(ra) # 80003ef0 <readi>
    8000436e:	47c1                	li	a5,16
    80004370:	06f51163          	bne	a0,a5,800043d2 <dirlink+0xa2>
    if(de.inum == 0)
    80004374:	fc045783          	lhu	a5,-64(s0)
    80004378:	c791                	beqz	a5,80004384 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000437a:	24c1                	addiw	s1,s1,16
    8000437c:	04c92783          	lw	a5,76(s2)
    80004380:	fcf4ede3          	bltu	s1,a5,8000435a <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004384:	4639                	li	a2,14
    80004386:	85d2                	mv	a1,s4
    80004388:	fc240513          	addi	a0,s0,-62
    8000438c:	ffffd097          	auipc	ra,0xffffd
    80004390:	a52080e7          	jalr	-1454(ra) # 80000dde <strncpy>
  de.inum = inum;
    80004394:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004398:	4741                	li	a4,16
    8000439a:	86a6                	mv	a3,s1
    8000439c:	fc040613          	addi	a2,s0,-64
    800043a0:	4581                	li	a1,0
    800043a2:	854a                	mv	a0,s2
    800043a4:	00000097          	auipc	ra,0x0
    800043a8:	c44080e7          	jalr	-956(ra) # 80003fe8 <writei>
    800043ac:	1541                	addi	a0,a0,-16
    800043ae:	00a03533          	snez	a0,a0
    800043b2:	40a00533          	neg	a0,a0
}
    800043b6:	70e2                	ld	ra,56(sp)
    800043b8:	7442                	ld	s0,48(sp)
    800043ba:	74a2                	ld	s1,40(sp)
    800043bc:	7902                	ld	s2,32(sp)
    800043be:	69e2                	ld	s3,24(sp)
    800043c0:	6a42                	ld	s4,16(sp)
    800043c2:	6121                	addi	sp,sp,64
    800043c4:	8082                	ret
    iput(ip);
    800043c6:	00000097          	auipc	ra,0x0
    800043ca:	a30080e7          	jalr	-1488(ra) # 80003df6 <iput>
    return -1;
    800043ce:	557d                	li	a0,-1
    800043d0:	b7dd                	j	800043b6 <dirlink+0x86>
      panic("dirlink read");
    800043d2:	00004517          	auipc	a0,0x4
    800043d6:	28e50513          	addi	a0,a0,654 # 80008660 <syscalls+0x1e8>
    800043da:	ffffc097          	auipc	ra,0xffffc
    800043de:	164080e7          	jalr	356(ra) # 8000053e <panic>

00000000800043e2 <namei>:

struct inode*
namei(char *path)
{
    800043e2:	1101                	addi	sp,sp,-32
    800043e4:	ec06                	sd	ra,24(sp)
    800043e6:	e822                	sd	s0,16(sp)
    800043e8:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800043ea:	fe040613          	addi	a2,s0,-32
    800043ee:	4581                	li	a1,0
    800043f0:	00000097          	auipc	ra,0x0
    800043f4:	de0080e7          	jalr	-544(ra) # 800041d0 <namex>
}
    800043f8:	60e2                	ld	ra,24(sp)
    800043fa:	6442                	ld	s0,16(sp)
    800043fc:	6105                	addi	sp,sp,32
    800043fe:	8082                	ret

0000000080004400 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004400:	1141                	addi	sp,sp,-16
    80004402:	e406                	sd	ra,8(sp)
    80004404:	e022                	sd	s0,0(sp)
    80004406:	0800                	addi	s0,sp,16
    80004408:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000440a:	4585                	li	a1,1
    8000440c:	00000097          	auipc	ra,0x0
    80004410:	dc4080e7          	jalr	-572(ra) # 800041d0 <namex>
}
    80004414:	60a2                	ld	ra,8(sp)
    80004416:	6402                	ld	s0,0(sp)
    80004418:	0141                	addi	sp,sp,16
    8000441a:	8082                	ret

000000008000441c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000441c:	1101                	addi	sp,sp,-32
    8000441e:	ec06                	sd	ra,24(sp)
    80004420:	e822                	sd	s0,16(sp)
    80004422:	e426                	sd	s1,8(sp)
    80004424:	e04a                	sd	s2,0(sp)
    80004426:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004428:	0001e917          	auipc	s2,0x1e
    8000442c:	94890913          	addi	s2,s2,-1720 # 80021d70 <log>
    80004430:	01892583          	lw	a1,24(s2)
    80004434:	02892503          	lw	a0,40(s2)
    80004438:	fffff097          	auipc	ra,0xfffff
    8000443c:	fea080e7          	jalr	-22(ra) # 80003422 <bread>
    80004440:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004442:	02c92683          	lw	a3,44(s2)
    80004446:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004448:	02d05763          	blez	a3,80004476 <write_head+0x5a>
    8000444c:	0001e797          	auipc	a5,0x1e
    80004450:	95478793          	addi	a5,a5,-1708 # 80021da0 <log+0x30>
    80004454:	05c50713          	addi	a4,a0,92
    80004458:	36fd                	addiw	a3,a3,-1
    8000445a:	1682                	slli	a3,a3,0x20
    8000445c:	9281                	srli	a3,a3,0x20
    8000445e:	068a                	slli	a3,a3,0x2
    80004460:	0001e617          	auipc	a2,0x1e
    80004464:	94460613          	addi	a2,a2,-1724 # 80021da4 <log+0x34>
    80004468:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    8000446a:	4390                	lw	a2,0(a5)
    8000446c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000446e:	0791                	addi	a5,a5,4
    80004470:	0711                	addi	a4,a4,4
    80004472:	fed79ce3          	bne	a5,a3,8000446a <write_head+0x4e>
  }
  bwrite(buf);
    80004476:	8526                	mv	a0,s1
    80004478:	fffff097          	auipc	ra,0xfffff
    8000447c:	09c080e7          	jalr	156(ra) # 80003514 <bwrite>
  brelse(buf);
    80004480:	8526                	mv	a0,s1
    80004482:	fffff097          	auipc	ra,0xfffff
    80004486:	0d0080e7          	jalr	208(ra) # 80003552 <brelse>
}
    8000448a:	60e2                	ld	ra,24(sp)
    8000448c:	6442                	ld	s0,16(sp)
    8000448e:	64a2                	ld	s1,8(sp)
    80004490:	6902                	ld	s2,0(sp)
    80004492:	6105                	addi	sp,sp,32
    80004494:	8082                	ret

0000000080004496 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004496:	0001e797          	auipc	a5,0x1e
    8000449a:	9067a783          	lw	a5,-1786(a5) # 80021d9c <log+0x2c>
    8000449e:	0af05d63          	blez	a5,80004558 <install_trans+0xc2>
{
    800044a2:	7139                	addi	sp,sp,-64
    800044a4:	fc06                	sd	ra,56(sp)
    800044a6:	f822                	sd	s0,48(sp)
    800044a8:	f426                	sd	s1,40(sp)
    800044aa:	f04a                	sd	s2,32(sp)
    800044ac:	ec4e                	sd	s3,24(sp)
    800044ae:	e852                	sd	s4,16(sp)
    800044b0:	e456                	sd	s5,8(sp)
    800044b2:	e05a                	sd	s6,0(sp)
    800044b4:	0080                	addi	s0,sp,64
    800044b6:	8b2a                	mv	s6,a0
    800044b8:	0001ea97          	auipc	s5,0x1e
    800044bc:	8e8a8a93          	addi	s5,s5,-1816 # 80021da0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044c0:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800044c2:	0001e997          	auipc	s3,0x1e
    800044c6:	8ae98993          	addi	s3,s3,-1874 # 80021d70 <log>
    800044ca:	a00d                	j	800044ec <install_trans+0x56>
    brelse(lbuf);
    800044cc:	854a                	mv	a0,s2
    800044ce:	fffff097          	auipc	ra,0xfffff
    800044d2:	084080e7          	jalr	132(ra) # 80003552 <brelse>
    brelse(dbuf);
    800044d6:	8526                	mv	a0,s1
    800044d8:	fffff097          	auipc	ra,0xfffff
    800044dc:	07a080e7          	jalr	122(ra) # 80003552 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044e0:	2a05                	addiw	s4,s4,1
    800044e2:	0a91                	addi	s5,s5,4
    800044e4:	02c9a783          	lw	a5,44(s3)
    800044e8:	04fa5e63          	bge	s4,a5,80004544 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800044ec:	0189a583          	lw	a1,24(s3)
    800044f0:	014585bb          	addw	a1,a1,s4
    800044f4:	2585                	addiw	a1,a1,1
    800044f6:	0289a503          	lw	a0,40(s3)
    800044fa:	fffff097          	auipc	ra,0xfffff
    800044fe:	f28080e7          	jalr	-216(ra) # 80003422 <bread>
    80004502:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004504:	000aa583          	lw	a1,0(s5)
    80004508:	0289a503          	lw	a0,40(s3)
    8000450c:	fffff097          	auipc	ra,0xfffff
    80004510:	f16080e7          	jalr	-234(ra) # 80003422 <bread>
    80004514:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004516:	40000613          	li	a2,1024
    8000451a:	05890593          	addi	a1,s2,88
    8000451e:	05850513          	addi	a0,a0,88
    80004522:	ffffd097          	auipc	ra,0xffffd
    80004526:	80c080e7          	jalr	-2036(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    8000452a:	8526                	mv	a0,s1
    8000452c:	fffff097          	auipc	ra,0xfffff
    80004530:	fe8080e7          	jalr	-24(ra) # 80003514 <bwrite>
    if(recovering == 0)
    80004534:	f80b1ce3          	bnez	s6,800044cc <install_trans+0x36>
      bunpin(dbuf);
    80004538:	8526                	mv	a0,s1
    8000453a:	fffff097          	auipc	ra,0xfffff
    8000453e:	0f2080e7          	jalr	242(ra) # 8000362c <bunpin>
    80004542:	b769                	j	800044cc <install_trans+0x36>
}
    80004544:	70e2                	ld	ra,56(sp)
    80004546:	7442                	ld	s0,48(sp)
    80004548:	74a2                	ld	s1,40(sp)
    8000454a:	7902                	ld	s2,32(sp)
    8000454c:	69e2                	ld	s3,24(sp)
    8000454e:	6a42                	ld	s4,16(sp)
    80004550:	6aa2                	ld	s5,8(sp)
    80004552:	6b02                	ld	s6,0(sp)
    80004554:	6121                	addi	sp,sp,64
    80004556:	8082                	ret
    80004558:	8082                	ret

000000008000455a <initlog>:
{
    8000455a:	7179                	addi	sp,sp,-48
    8000455c:	f406                	sd	ra,40(sp)
    8000455e:	f022                	sd	s0,32(sp)
    80004560:	ec26                	sd	s1,24(sp)
    80004562:	e84a                	sd	s2,16(sp)
    80004564:	e44e                	sd	s3,8(sp)
    80004566:	1800                	addi	s0,sp,48
    80004568:	892a                	mv	s2,a0
    8000456a:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000456c:	0001e497          	auipc	s1,0x1e
    80004570:	80448493          	addi	s1,s1,-2044 # 80021d70 <log>
    80004574:	00004597          	auipc	a1,0x4
    80004578:	0fc58593          	addi	a1,a1,252 # 80008670 <syscalls+0x1f8>
    8000457c:	8526                	mv	a0,s1
    8000457e:	ffffc097          	auipc	ra,0xffffc
    80004582:	5c8080e7          	jalr	1480(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    80004586:	0149a583          	lw	a1,20(s3)
    8000458a:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000458c:	0109a783          	lw	a5,16(s3)
    80004590:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004592:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004596:	854a                	mv	a0,s2
    80004598:	fffff097          	auipc	ra,0xfffff
    8000459c:	e8a080e7          	jalr	-374(ra) # 80003422 <bread>
  log.lh.n = lh->n;
    800045a0:	4d34                	lw	a3,88(a0)
    800045a2:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800045a4:	02d05563          	blez	a3,800045ce <initlog+0x74>
    800045a8:	05c50793          	addi	a5,a0,92
    800045ac:	0001d717          	auipc	a4,0x1d
    800045b0:	7f470713          	addi	a4,a4,2036 # 80021da0 <log+0x30>
    800045b4:	36fd                	addiw	a3,a3,-1
    800045b6:	1682                	slli	a3,a3,0x20
    800045b8:	9281                	srli	a3,a3,0x20
    800045ba:	068a                	slli	a3,a3,0x2
    800045bc:	06050613          	addi	a2,a0,96
    800045c0:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800045c2:	4390                	lw	a2,0(a5)
    800045c4:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800045c6:	0791                	addi	a5,a5,4
    800045c8:	0711                	addi	a4,a4,4
    800045ca:	fed79ce3          	bne	a5,a3,800045c2 <initlog+0x68>
  brelse(buf);
    800045ce:	fffff097          	auipc	ra,0xfffff
    800045d2:	f84080e7          	jalr	-124(ra) # 80003552 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800045d6:	4505                	li	a0,1
    800045d8:	00000097          	auipc	ra,0x0
    800045dc:	ebe080e7          	jalr	-322(ra) # 80004496 <install_trans>
  log.lh.n = 0;
    800045e0:	0001d797          	auipc	a5,0x1d
    800045e4:	7a07ae23          	sw	zero,1980(a5) # 80021d9c <log+0x2c>
  write_head(); // clear the log
    800045e8:	00000097          	auipc	ra,0x0
    800045ec:	e34080e7          	jalr	-460(ra) # 8000441c <write_head>
}
    800045f0:	70a2                	ld	ra,40(sp)
    800045f2:	7402                	ld	s0,32(sp)
    800045f4:	64e2                	ld	s1,24(sp)
    800045f6:	6942                	ld	s2,16(sp)
    800045f8:	69a2                	ld	s3,8(sp)
    800045fa:	6145                	addi	sp,sp,48
    800045fc:	8082                	ret

00000000800045fe <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800045fe:	1101                	addi	sp,sp,-32
    80004600:	ec06                	sd	ra,24(sp)
    80004602:	e822                	sd	s0,16(sp)
    80004604:	e426                	sd	s1,8(sp)
    80004606:	e04a                	sd	s2,0(sp)
    80004608:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000460a:	0001d517          	auipc	a0,0x1d
    8000460e:	76650513          	addi	a0,a0,1894 # 80021d70 <log>
    80004612:	ffffc097          	auipc	ra,0xffffc
    80004616:	5c4080e7          	jalr	1476(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    8000461a:	0001d497          	auipc	s1,0x1d
    8000461e:	75648493          	addi	s1,s1,1878 # 80021d70 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004622:	4979                	li	s2,30
    80004624:	a039                	j	80004632 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004626:	85a6                	mv	a1,s1
    80004628:	8526                	mv	a0,s1
    8000462a:	ffffe097          	auipc	ra,0xffffe
    8000462e:	d22080e7          	jalr	-734(ra) # 8000234c <sleep>
    if(log.committing){
    80004632:	50dc                	lw	a5,36(s1)
    80004634:	fbed                	bnez	a5,80004626 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004636:	509c                	lw	a5,32(s1)
    80004638:	0017871b          	addiw	a4,a5,1
    8000463c:	0007069b          	sext.w	a3,a4
    80004640:	0027179b          	slliw	a5,a4,0x2
    80004644:	9fb9                	addw	a5,a5,a4
    80004646:	0017979b          	slliw	a5,a5,0x1
    8000464a:	54d8                	lw	a4,44(s1)
    8000464c:	9fb9                	addw	a5,a5,a4
    8000464e:	00f95963          	bge	s2,a5,80004660 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004652:	85a6                	mv	a1,s1
    80004654:	8526                	mv	a0,s1
    80004656:	ffffe097          	auipc	ra,0xffffe
    8000465a:	cf6080e7          	jalr	-778(ra) # 8000234c <sleep>
    8000465e:	bfd1                	j	80004632 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004660:	0001d517          	auipc	a0,0x1d
    80004664:	71050513          	addi	a0,a0,1808 # 80021d70 <log>
    80004668:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000466a:	ffffc097          	auipc	ra,0xffffc
    8000466e:	620080e7          	jalr	1568(ra) # 80000c8a <release>
      break;
    }
  }
}
    80004672:	60e2                	ld	ra,24(sp)
    80004674:	6442                	ld	s0,16(sp)
    80004676:	64a2                	ld	s1,8(sp)
    80004678:	6902                	ld	s2,0(sp)
    8000467a:	6105                	addi	sp,sp,32
    8000467c:	8082                	ret

000000008000467e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000467e:	7139                	addi	sp,sp,-64
    80004680:	fc06                	sd	ra,56(sp)
    80004682:	f822                	sd	s0,48(sp)
    80004684:	f426                	sd	s1,40(sp)
    80004686:	f04a                	sd	s2,32(sp)
    80004688:	ec4e                	sd	s3,24(sp)
    8000468a:	e852                	sd	s4,16(sp)
    8000468c:	e456                	sd	s5,8(sp)
    8000468e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004690:	0001d497          	auipc	s1,0x1d
    80004694:	6e048493          	addi	s1,s1,1760 # 80021d70 <log>
    80004698:	8526                	mv	a0,s1
    8000469a:	ffffc097          	auipc	ra,0xffffc
    8000469e:	53c080e7          	jalr	1340(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    800046a2:	509c                	lw	a5,32(s1)
    800046a4:	37fd                	addiw	a5,a5,-1
    800046a6:	0007891b          	sext.w	s2,a5
    800046aa:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800046ac:	50dc                	lw	a5,36(s1)
    800046ae:	e7b9                	bnez	a5,800046fc <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800046b0:	04091e63          	bnez	s2,8000470c <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800046b4:	0001d497          	auipc	s1,0x1d
    800046b8:	6bc48493          	addi	s1,s1,1724 # 80021d70 <log>
    800046bc:	4785                	li	a5,1
    800046be:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800046c0:	8526                	mv	a0,s1
    800046c2:	ffffc097          	auipc	ra,0xffffc
    800046c6:	5c8080e7          	jalr	1480(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800046ca:	54dc                	lw	a5,44(s1)
    800046cc:	06f04763          	bgtz	a5,8000473a <end_op+0xbc>
    acquire(&log.lock);
    800046d0:	0001d497          	auipc	s1,0x1d
    800046d4:	6a048493          	addi	s1,s1,1696 # 80021d70 <log>
    800046d8:	8526                	mv	a0,s1
    800046da:	ffffc097          	auipc	ra,0xffffc
    800046de:	4fc080e7          	jalr	1276(ra) # 80000bd6 <acquire>
    log.committing = 0;
    800046e2:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800046e6:	8526                	mv	a0,s1
    800046e8:	ffffe097          	auipc	ra,0xffffe
    800046ec:	d4c080e7          	jalr	-692(ra) # 80002434 <wakeup>
    release(&log.lock);
    800046f0:	8526                	mv	a0,s1
    800046f2:	ffffc097          	auipc	ra,0xffffc
    800046f6:	598080e7          	jalr	1432(ra) # 80000c8a <release>
}
    800046fa:	a03d                	j	80004728 <end_op+0xaa>
    panic("log.committing");
    800046fc:	00004517          	auipc	a0,0x4
    80004700:	f7c50513          	addi	a0,a0,-132 # 80008678 <syscalls+0x200>
    80004704:	ffffc097          	auipc	ra,0xffffc
    80004708:	e3a080e7          	jalr	-454(ra) # 8000053e <panic>
    wakeup(&log);
    8000470c:	0001d497          	auipc	s1,0x1d
    80004710:	66448493          	addi	s1,s1,1636 # 80021d70 <log>
    80004714:	8526                	mv	a0,s1
    80004716:	ffffe097          	auipc	ra,0xffffe
    8000471a:	d1e080e7          	jalr	-738(ra) # 80002434 <wakeup>
  release(&log.lock);
    8000471e:	8526                	mv	a0,s1
    80004720:	ffffc097          	auipc	ra,0xffffc
    80004724:	56a080e7          	jalr	1386(ra) # 80000c8a <release>
}
    80004728:	70e2                	ld	ra,56(sp)
    8000472a:	7442                	ld	s0,48(sp)
    8000472c:	74a2                	ld	s1,40(sp)
    8000472e:	7902                	ld	s2,32(sp)
    80004730:	69e2                	ld	s3,24(sp)
    80004732:	6a42                	ld	s4,16(sp)
    80004734:	6aa2                	ld	s5,8(sp)
    80004736:	6121                	addi	sp,sp,64
    80004738:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000473a:	0001da97          	auipc	s5,0x1d
    8000473e:	666a8a93          	addi	s5,s5,1638 # 80021da0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004742:	0001da17          	auipc	s4,0x1d
    80004746:	62ea0a13          	addi	s4,s4,1582 # 80021d70 <log>
    8000474a:	018a2583          	lw	a1,24(s4)
    8000474e:	012585bb          	addw	a1,a1,s2
    80004752:	2585                	addiw	a1,a1,1
    80004754:	028a2503          	lw	a0,40(s4)
    80004758:	fffff097          	auipc	ra,0xfffff
    8000475c:	cca080e7          	jalr	-822(ra) # 80003422 <bread>
    80004760:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004762:	000aa583          	lw	a1,0(s5)
    80004766:	028a2503          	lw	a0,40(s4)
    8000476a:	fffff097          	auipc	ra,0xfffff
    8000476e:	cb8080e7          	jalr	-840(ra) # 80003422 <bread>
    80004772:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004774:	40000613          	li	a2,1024
    80004778:	05850593          	addi	a1,a0,88
    8000477c:	05848513          	addi	a0,s1,88
    80004780:	ffffc097          	auipc	ra,0xffffc
    80004784:	5ae080e7          	jalr	1454(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    80004788:	8526                	mv	a0,s1
    8000478a:	fffff097          	auipc	ra,0xfffff
    8000478e:	d8a080e7          	jalr	-630(ra) # 80003514 <bwrite>
    brelse(from);
    80004792:	854e                	mv	a0,s3
    80004794:	fffff097          	auipc	ra,0xfffff
    80004798:	dbe080e7          	jalr	-578(ra) # 80003552 <brelse>
    brelse(to);
    8000479c:	8526                	mv	a0,s1
    8000479e:	fffff097          	auipc	ra,0xfffff
    800047a2:	db4080e7          	jalr	-588(ra) # 80003552 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800047a6:	2905                	addiw	s2,s2,1
    800047a8:	0a91                	addi	s5,s5,4
    800047aa:	02ca2783          	lw	a5,44(s4)
    800047ae:	f8f94ee3          	blt	s2,a5,8000474a <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800047b2:	00000097          	auipc	ra,0x0
    800047b6:	c6a080e7          	jalr	-918(ra) # 8000441c <write_head>
    install_trans(0); // Now install writes to home locations
    800047ba:	4501                	li	a0,0
    800047bc:	00000097          	auipc	ra,0x0
    800047c0:	cda080e7          	jalr	-806(ra) # 80004496 <install_trans>
    log.lh.n = 0;
    800047c4:	0001d797          	auipc	a5,0x1d
    800047c8:	5c07ac23          	sw	zero,1496(a5) # 80021d9c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800047cc:	00000097          	auipc	ra,0x0
    800047d0:	c50080e7          	jalr	-944(ra) # 8000441c <write_head>
    800047d4:	bdf5                	j	800046d0 <end_op+0x52>

00000000800047d6 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800047d6:	1101                	addi	sp,sp,-32
    800047d8:	ec06                	sd	ra,24(sp)
    800047da:	e822                	sd	s0,16(sp)
    800047dc:	e426                	sd	s1,8(sp)
    800047de:	e04a                	sd	s2,0(sp)
    800047e0:	1000                	addi	s0,sp,32
    800047e2:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800047e4:	0001d917          	auipc	s2,0x1d
    800047e8:	58c90913          	addi	s2,s2,1420 # 80021d70 <log>
    800047ec:	854a                	mv	a0,s2
    800047ee:	ffffc097          	auipc	ra,0xffffc
    800047f2:	3e8080e7          	jalr	1000(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800047f6:	02c92603          	lw	a2,44(s2)
    800047fa:	47f5                	li	a5,29
    800047fc:	06c7c563          	blt	a5,a2,80004866 <log_write+0x90>
    80004800:	0001d797          	auipc	a5,0x1d
    80004804:	58c7a783          	lw	a5,1420(a5) # 80021d8c <log+0x1c>
    80004808:	37fd                	addiw	a5,a5,-1
    8000480a:	04f65e63          	bge	a2,a5,80004866 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000480e:	0001d797          	auipc	a5,0x1d
    80004812:	5827a783          	lw	a5,1410(a5) # 80021d90 <log+0x20>
    80004816:	06f05063          	blez	a5,80004876 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000481a:	4781                	li	a5,0
    8000481c:	06c05563          	blez	a2,80004886 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004820:	44cc                	lw	a1,12(s1)
    80004822:	0001d717          	auipc	a4,0x1d
    80004826:	57e70713          	addi	a4,a4,1406 # 80021da0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000482a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000482c:	4314                	lw	a3,0(a4)
    8000482e:	04b68c63          	beq	a3,a1,80004886 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004832:	2785                	addiw	a5,a5,1
    80004834:	0711                	addi	a4,a4,4
    80004836:	fef61be3          	bne	a2,a5,8000482c <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000483a:	0621                	addi	a2,a2,8
    8000483c:	060a                	slli	a2,a2,0x2
    8000483e:	0001d797          	auipc	a5,0x1d
    80004842:	53278793          	addi	a5,a5,1330 # 80021d70 <log>
    80004846:	963e                	add	a2,a2,a5
    80004848:	44dc                	lw	a5,12(s1)
    8000484a:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000484c:	8526                	mv	a0,s1
    8000484e:	fffff097          	auipc	ra,0xfffff
    80004852:	da2080e7          	jalr	-606(ra) # 800035f0 <bpin>
    log.lh.n++;
    80004856:	0001d717          	auipc	a4,0x1d
    8000485a:	51a70713          	addi	a4,a4,1306 # 80021d70 <log>
    8000485e:	575c                	lw	a5,44(a4)
    80004860:	2785                	addiw	a5,a5,1
    80004862:	d75c                	sw	a5,44(a4)
    80004864:	a835                	j	800048a0 <log_write+0xca>
    panic("too big a transaction");
    80004866:	00004517          	auipc	a0,0x4
    8000486a:	e2250513          	addi	a0,a0,-478 # 80008688 <syscalls+0x210>
    8000486e:	ffffc097          	auipc	ra,0xffffc
    80004872:	cd0080e7          	jalr	-816(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    80004876:	00004517          	auipc	a0,0x4
    8000487a:	e2a50513          	addi	a0,a0,-470 # 800086a0 <syscalls+0x228>
    8000487e:	ffffc097          	auipc	ra,0xffffc
    80004882:	cc0080e7          	jalr	-832(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    80004886:	00878713          	addi	a4,a5,8
    8000488a:	00271693          	slli	a3,a4,0x2
    8000488e:	0001d717          	auipc	a4,0x1d
    80004892:	4e270713          	addi	a4,a4,1250 # 80021d70 <log>
    80004896:	9736                	add	a4,a4,a3
    80004898:	44d4                	lw	a3,12(s1)
    8000489a:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000489c:	faf608e3          	beq	a2,a5,8000484c <log_write+0x76>
  }
  release(&log.lock);
    800048a0:	0001d517          	auipc	a0,0x1d
    800048a4:	4d050513          	addi	a0,a0,1232 # 80021d70 <log>
    800048a8:	ffffc097          	auipc	ra,0xffffc
    800048ac:	3e2080e7          	jalr	994(ra) # 80000c8a <release>
}
    800048b0:	60e2                	ld	ra,24(sp)
    800048b2:	6442                	ld	s0,16(sp)
    800048b4:	64a2                	ld	s1,8(sp)
    800048b6:	6902                	ld	s2,0(sp)
    800048b8:	6105                	addi	sp,sp,32
    800048ba:	8082                	ret

00000000800048bc <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800048bc:	1101                	addi	sp,sp,-32
    800048be:	ec06                	sd	ra,24(sp)
    800048c0:	e822                	sd	s0,16(sp)
    800048c2:	e426                	sd	s1,8(sp)
    800048c4:	e04a                	sd	s2,0(sp)
    800048c6:	1000                	addi	s0,sp,32
    800048c8:	84aa                	mv	s1,a0
    800048ca:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800048cc:	00004597          	auipc	a1,0x4
    800048d0:	df458593          	addi	a1,a1,-524 # 800086c0 <syscalls+0x248>
    800048d4:	0521                	addi	a0,a0,8
    800048d6:	ffffc097          	auipc	ra,0xffffc
    800048da:	270080e7          	jalr	624(ra) # 80000b46 <initlock>
  lk->name = name;
    800048de:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800048e2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800048e6:	0204a423          	sw	zero,40(s1)
}
    800048ea:	60e2                	ld	ra,24(sp)
    800048ec:	6442                	ld	s0,16(sp)
    800048ee:	64a2                	ld	s1,8(sp)
    800048f0:	6902                	ld	s2,0(sp)
    800048f2:	6105                	addi	sp,sp,32
    800048f4:	8082                	ret

00000000800048f6 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800048f6:	1101                	addi	sp,sp,-32
    800048f8:	ec06                	sd	ra,24(sp)
    800048fa:	e822                	sd	s0,16(sp)
    800048fc:	e426                	sd	s1,8(sp)
    800048fe:	e04a                	sd	s2,0(sp)
    80004900:	1000                	addi	s0,sp,32
    80004902:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004904:	00850913          	addi	s2,a0,8
    80004908:	854a                	mv	a0,s2
    8000490a:	ffffc097          	auipc	ra,0xffffc
    8000490e:	2cc080e7          	jalr	716(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    80004912:	409c                	lw	a5,0(s1)
    80004914:	cb89                	beqz	a5,80004926 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004916:	85ca                	mv	a1,s2
    80004918:	8526                	mv	a0,s1
    8000491a:	ffffe097          	auipc	ra,0xffffe
    8000491e:	a32080e7          	jalr	-1486(ra) # 8000234c <sleep>
  while (lk->locked) {
    80004922:	409c                	lw	a5,0(s1)
    80004924:	fbed                	bnez	a5,80004916 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004926:	4785                	li	a5,1
    80004928:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000492a:	ffffd097          	auipc	ra,0xffffd
    8000492e:	0a0080e7          	jalr	160(ra) # 800019ca <myproc>
    80004932:	591c                	lw	a5,48(a0)
    80004934:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004936:	854a                	mv	a0,s2
    80004938:	ffffc097          	auipc	ra,0xffffc
    8000493c:	352080e7          	jalr	850(ra) # 80000c8a <release>
}
    80004940:	60e2                	ld	ra,24(sp)
    80004942:	6442                	ld	s0,16(sp)
    80004944:	64a2                	ld	s1,8(sp)
    80004946:	6902                	ld	s2,0(sp)
    80004948:	6105                	addi	sp,sp,32
    8000494a:	8082                	ret

000000008000494c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000494c:	1101                	addi	sp,sp,-32
    8000494e:	ec06                	sd	ra,24(sp)
    80004950:	e822                	sd	s0,16(sp)
    80004952:	e426                	sd	s1,8(sp)
    80004954:	e04a                	sd	s2,0(sp)
    80004956:	1000                	addi	s0,sp,32
    80004958:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000495a:	00850913          	addi	s2,a0,8
    8000495e:	854a                	mv	a0,s2
    80004960:	ffffc097          	auipc	ra,0xffffc
    80004964:	276080e7          	jalr	630(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    80004968:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000496c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004970:	8526                	mv	a0,s1
    80004972:	ffffe097          	auipc	ra,0xffffe
    80004976:	ac2080e7          	jalr	-1342(ra) # 80002434 <wakeup>
  release(&lk->lk);
    8000497a:	854a                	mv	a0,s2
    8000497c:	ffffc097          	auipc	ra,0xffffc
    80004980:	30e080e7          	jalr	782(ra) # 80000c8a <release>
}
    80004984:	60e2                	ld	ra,24(sp)
    80004986:	6442                	ld	s0,16(sp)
    80004988:	64a2                	ld	s1,8(sp)
    8000498a:	6902                	ld	s2,0(sp)
    8000498c:	6105                	addi	sp,sp,32
    8000498e:	8082                	ret

0000000080004990 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004990:	7179                	addi	sp,sp,-48
    80004992:	f406                	sd	ra,40(sp)
    80004994:	f022                	sd	s0,32(sp)
    80004996:	ec26                	sd	s1,24(sp)
    80004998:	e84a                	sd	s2,16(sp)
    8000499a:	e44e                	sd	s3,8(sp)
    8000499c:	1800                	addi	s0,sp,48
    8000499e:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800049a0:	00850913          	addi	s2,a0,8
    800049a4:	854a                	mv	a0,s2
    800049a6:	ffffc097          	auipc	ra,0xffffc
    800049aa:	230080e7          	jalr	560(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800049ae:	409c                	lw	a5,0(s1)
    800049b0:	ef99                	bnez	a5,800049ce <holdingsleep+0x3e>
    800049b2:	4481                	li	s1,0
  release(&lk->lk);
    800049b4:	854a                	mv	a0,s2
    800049b6:	ffffc097          	auipc	ra,0xffffc
    800049ba:	2d4080e7          	jalr	724(ra) # 80000c8a <release>
  return r;
}
    800049be:	8526                	mv	a0,s1
    800049c0:	70a2                	ld	ra,40(sp)
    800049c2:	7402                	ld	s0,32(sp)
    800049c4:	64e2                	ld	s1,24(sp)
    800049c6:	6942                	ld	s2,16(sp)
    800049c8:	69a2                	ld	s3,8(sp)
    800049ca:	6145                	addi	sp,sp,48
    800049cc:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800049ce:	0284a983          	lw	s3,40(s1)
    800049d2:	ffffd097          	auipc	ra,0xffffd
    800049d6:	ff8080e7          	jalr	-8(ra) # 800019ca <myproc>
    800049da:	5904                	lw	s1,48(a0)
    800049dc:	413484b3          	sub	s1,s1,s3
    800049e0:	0014b493          	seqz	s1,s1
    800049e4:	bfc1                	j	800049b4 <holdingsleep+0x24>

00000000800049e6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800049e6:	1141                	addi	sp,sp,-16
    800049e8:	e406                	sd	ra,8(sp)
    800049ea:	e022                	sd	s0,0(sp)
    800049ec:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800049ee:	00004597          	auipc	a1,0x4
    800049f2:	ce258593          	addi	a1,a1,-798 # 800086d0 <syscalls+0x258>
    800049f6:	0001d517          	auipc	a0,0x1d
    800049fa:	4c250513          	addi	a0,a0,1218 # 80021eb8 <ftable>
    800049fe:	ffffc097          	auipc	ra,0xffffc
    80004a02:	148080e7          	jalr	328(ra) # 80000b46 <initlock>
}
    80004a06:	60a2                	ld	ra,8(sp)
    80004a08:	6402                	ld	s0,0(sp)
    80004a0a:	0141                	addi	sp,sp,16
    80004a0c:	8082                	ret

0000000080004a0e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004a0e:	1101                	addi	sp,sp,-32
    80004a10:	ec06                	sd	ra,24(sp)
    80004a12:	e822                	sd	s0,16(sp)
    80004a14:	e426                	sd	s1,8(sp)
    80004a16:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004a18:	0001d517          	auipc	a0,0x1d
    80004a1c:	4a050513          	addi	a0,a0,1184 # 80021eb8 <ftable>
    80004a20:	ffffc097          	auipc	ra,0xffffc
    80004a24:	1b6080e7          	jalr	438(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a28:	0001d497          	auipc	s1,0x1d
    80004a2c:	4a848493          	addi	s1,s1,1192 # 80021ed0 <ftable+0x18>
    80004a30:	0001e717          	auipc	a4,0x1e
    80004a34:	44070713          	addi	a4,a4,1088 # 80022e70 <disk>
    if(f->ref == 0){
    80004a38:	40dc                	lw	a5,4(s1)
    80004a3a:	cf99                	beqz	a5,80004a58 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a3c:	02848493          	addi	s1,s1,40
    80004a40:	fee49ce3          	bne	s1,a4,80004a38 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004a44:	0001d517          	auipc	a0,0x1d
    80004a48:	47450513          	addi	a0,a0,1140 # 80021eb8 <ftable>
    80004a4c:	ffffc097          	auipc	ra,0xffffc
    80004a50:	23e080e7          	jalr	574(ra) # 80000c8a <release>
  return 0;
    80004a54:	4481                	li	s1,0
    80004a56:	a819                	j	80004a6c <filealloc+0x5e>
      f->ref = 1;
    80004a58:	4785                	li	a5,1
    80004a5a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004a5c:	0001d517          	auipc	a0,0x1d
    80004a60:	45c50513          	addi	a0,a0,1116 # 80021eb8 <ftable>
    80004a64:	ffffc097          	auipc	ra,0xffffc
    80004a68:	226080e7          	jalr	550(ra) # 80000c8a <release>
}
    80004a6c:	8526                	mv	a0,s1
    80004a6e:	60e2                	ld	ra,24(sp)
    80004a70:	6442                	ld	s0,16(sp)
    80004a72:	64a2                	ld	s1,8(sp)
    80004a74:	6105                	addi	sp,sp,32
    80004a76:	8082                	ret

0000000080004a78 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004a78:	1101                	addi	sp,sp,-32
    80004a7a:	ec06                	sd	ra,24(sp)
    80004a7c:	e822                	sd	s0,16(sp)
    80004a7e:	e426                	sd	s1,8(sp)
    80004a80:	1000                	addi	s0,sp,32
    80004a82:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004a84:	0001d517          	auipc	a0,0x1d
    80004a88:	43450513          	addi	a0,a0,1076 # 80021eb8 <ftable>
    80004a8c:	ffffc097          	auipc	ra,0xffffc
    80004a90:	14a080e7          	jalr	330(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004a94:	40dc                	lw	a5,4(s1)
    80004a96:	02f05263          	blez	a5,80004aba <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004a9a:	2785                	addiw	a5,a5,1
    80004a9c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004a9e:	0001d517          	auipc	a0,0x1d
    80004aa2:	41a50513          	addi	a0,a0,1050 # 80021eb8 <ftable>
    80004aa6:	ffffc097          	auipc	ra,0xffffc
    80004aaa:	1e4080e7          	jalr	484(ra) # 80000c8a <release>
  return f;
}
    80004aae:	8526                	mv	a0,s1
    80004ab0:	60e2                	ld	ra,24(sp)
    80004ab2:	6442                	ld	s0,16(sp)
    80004ab4:	64a2                	ld	s1,8(sp)
    80004ab6:	6105                	addi	sp,sp,32
    80004ab8:	8082                	ret
    panic("filedup");
    80004aba:	00004517          	auipc	a0,0x4
    80004abe:	c1e50513          	addi	a0,a0,-994 # 800086d8 <syscalls+0x260>
    80004ac2:	ffffc097          	auipc	ra,0xffffc
    80004ac6:	a7c080e7          	jalr	-1412(ra) # 8000053e <panic>

0000000080004aca <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004aca:	7139                	addi	sp,sp,-64
    80004acc:	fc06                	sd	ra,56(sp)
    80004ace:	f822                	sd	s0,48(sp)
    80004ad0:	f426                	sd	s1,40(sp)
    80004ad2:	f04a                	sd	s2,32(sp)
    80004ad4:	ec4e                	sd	s3,24(sp)
    80004ad6:	e852                	sd	s4,16(sp)
    80004ad8:	e456                	sd	s5,8(sp)
    80004ada:	0080                	addi	s0,sp,64
    80004adc:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004ade:	0001d517          	auipc	a0,0x1d
    80004ae2:	3da50513          	addi	a0,a0,986 # 80021eb8 <ftable>
    80004ae6:	ffffc097          	auipc	ra,0xffffc
    80004aea:	0f0080e7          	jalr	240(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004aee:	40dc                	lw	a5,4(s1)
    80004af0:	06f05163          	blez	a5,80004b52 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004af4:	37fd                	addiw	a5,a5,-1
    80004af6:	0007871b          	sext.w	a4,a5
    80004afa:	c0dc                	sw	a5,4(s1)
    80004afc:	06e04363          	bgtz	a4,80004b62 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004b00:	0004a903          	lw	s2,0(s1)
    80004b04:	0094ca83          	lbu	s5,9(s1)
    80004b08:	0104ba03          	ld	s4,16(s1)
    80004b0c:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004b10:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004b14:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004b18:	0001d517          	auipc	a0,0x1d
    80004b1c:	3a050513          	addi	a0,a0,928 # 80021eb8 <ftable>
    80004b20:	ffffc097          	auipc	ra,0xffffc
    80004b24:	16a080e7          	jalr	362(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    80004b28:	4785                	li	a5,1
    80004b2a:	04f90d63          	beq	s2,a5,80004b84 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004b2e:	3979                	addiw	s2,s2,-2
    80004b30:	4785                	li	a5,1
    80004b32:	0527e063          	bltu	a5,s2,80004b72 <fileclose+0xa8>
    begin_op();
    80004b36:	00000097          	auipc	ra,0x0
    80004b3a:	ac8080e7          	jalr	-1336(ra) # 800045fe <begin_op>
    iput(ff.ip);
    80004b3e:	854e                	mv	a0,s3
    80004b40:	fffff097          	auipc	ra,0xfffff
    80004b44:	2b6080e7          	jalr	694(ra) # 80003df6 <iput>
    end_op();
    80004b48:	00000097          	auipc	ra,0x0
    80004b4c:	b36080e7          	jalr	-1226(ra) # 8000467e <end_op>
    80004b50:	a00d                	j	80004b72 <fileclose+0xa8>
    panic("fileclose");
    80004b52:	00004517          	auipc	a0,0x4
    80004b56:	b8e50513          	addi	a0,a0,-1138 # 800086e0 <syscalls+0x268>
    80004b5a:	ffffc097          	auipc	ra,0xffffc
    80004b5e:	9e4080e7          	jalr	-1564(ra) # 8000053e <panic>
    release(&ftable.lock);
    80004b62:	0001d517          	auipc	a0,0x1d
    80004b66:	35650513          	addi	a0,a0,854 # 80021eb8 <ftable>
    80004b6a:	ffffc097          	auipc	ra,0xffffc
    80004b6e:	120080e7          	jalr	288(ra) # 80000c8a <release>
  }
}
    80004b72:	70e2                	ld	ra,56(sp)
    80004b74:	7442                	ld	s0,48(sp)
    80004b76:	74a2                	ld	s1,40(sp)
    80004b78:	7902                	ld	s2,32(sp)
    80004b7a:	69e2                	ld	s3,24(sp)
    80004b7c:	6a42                	ld	s4,16(sp)
    80004b7e:	6aa2                	ld	s5,8(sp)
    80004b80:	6121                	addi	sp,sp,64
    80004b82:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004b84:	85d6                	mv	a1,s5
    80004b86:	8552                	mv	a0,s4
    80004b88:	00000097          	auipc	ra,0x0
    80004b8c:	34c080e7          	jalr	844(ra) # 80004ed4 <pipeclose>
    80004b90:	b7cd                	j	80004b72 <fileclose+0xa8>

0000000080004b92 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004b92:	715d                	addi	sp,sp,-80
    80004b94:	e486                	sd	ra,72(sp)
    80004b96:	e0a2                	sd	s0,64(sp)
    80004b98:	fc26                	sd	s1,56(sp)
    80004b9a:	f84a                	sd	s2,48(sp)
    80004b9c:	f44e                	sd	s3,40(sp)
    80004b9e:	0880                	addi	s0,sp,80
    80004ba0:	84aa                	mv	s1,a0
    80004ba2:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004ba4:	ffffd097          	auipc	ra,0xffffd
    80004ba8:	e26080e7          	jalr	-474(ra) # 800019ca <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004bac:	409c                	lw	a5,0(s1)
    80004bae:	37f9                	addiw	a5,a5,-2
    80004bb0:	4705                	li	a4,1
    80004bb2:	04f76763          	bltu	a4,a5,80004c00 <filestat+0x6e>
    80004bb6:	892a                	mv	s2,a0
    ilock(f->ip);
    80004bb8:	6c88                	ld	a0,24(s1)
    80004bba:	fffff097          	auipc	ra,0xfffff
    80004bbe:	082080e7          	jalr	130(ra) # 80003c3c <ilock>
    stati(f->ip, &st);
    80004bc2:	fb840593          	addi	a1,s0,-72
    80004bc6:	6c88                	ld	a0,24(s1)
    80004bc8:	fffff097          	auipc	ra,0xfffff
    80004bcc:	2fe080e7          	jalr	766(ra) # 80003ec6 <stati>
    iunlock(f->ip);
    80004bd0:	6c88                	ld	a0,24(s1)
    80004bd2:	fffff097          	auipc	ra,0xfffff
    80004bd6:	12c080e7          	jalr	300(ra) # 80003cfe <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004bda:	46e1                	li	a3,24
    80004bdc:	fb840613          	addi	a2,s0,-72
    80004be0:	85ce                	mv	a1,s3
    80004be2:	09893503          	ld	a0,152(s2)
    80004be6:	ffffd097          	auipc	ra,0xffffd
    80004bea:	a82080e7          	jalr	-1406(ra) # 80001668 <copyout>
    80004bee:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004bf2:	60a6                	ld	ra,72(sp)
    80004bf4:	6406                	ld	s0,64(sp)
    80004bf6:	74e2                	ld	s1,56(sp)
    80004bf8:	7942                	ld	s2,48(sp)
    80004bfa:	79a2                	ld	s3,40(sp)
    80004bfc:	6161                	addi	sp,sp,80
    80004bfe:	8082                	ret
  return -1;
    80004c00:	557d                	li	a0,-1
    80004c02:	bfc5                	j	80004bf2 <filestat+0x60>

0000000080004c04 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004c04:	7179                	addi	sp,sp,-48
    80004c06:	f406                	sd	ra,40(sp)
    80004c08:	f022                	sd	s0,32(sp)
    80004c0a:	ec26                	sd	s1,24(sp)
    80004c0c:	e84a                	sd	s2,16(sp)
    80004c0e:	e44e                	sd	s3,8(sp)
    80004c10:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004c12:	00854783          	lbu	a5,8(a0)
    80004c16:	c3d5                	beqz	a5,80004cba <fileread+0xb6>
    80004c18:	84aa                	mv	s1,a0
    80004c1a:	89ae                	mv	s3,a1
    80004c1c:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004c1e:	411c                	lw	a5,0(a0)
    80004c20:	4705                	li	a4,1
    80004c22:	04e78963          	beq	a5,a4,80004c74 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004c26:	470d                	li	a4,3
    80004c28:	04e78d63          	beq	a5,a4,80004c82 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c2c:	4709                	li	a4,2
    80004c2e:	06e79e63          	bne	a5,a4,80004caa <fileread+0xa6>
    ilock(f->ip);
    80004c32:	6d08                	ld	a0,24(a0)
    80004c34:	fffff097          	auipc	ra,0xfffff
    80004c38:	008080e7          	jalr	8(ra) # 80003c3c <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004c3c:	874a                	mv	a4,s2
    80004c3e:	5094                	lw	a3,32(s1)
    80004c40:	864e                	mv	a2,s3
    80004c42:	4585                	li	a1,1
    80004c44:	6c88                	ld	a0,24(s1)
    80004c46:	fffff097          	auipc	ra,0xfffff
    80004c4a:	2aa080e7          	jalr	682(ra) # 80003ef0 <readi>
    80004c4e:	892a                	mv	s2,a0
    80004c50:	00a05563          	blez	a0,80004c5a <fileread+0x56>
      f->off += r;
    80004c54:	509c                	lw	a5,32(s1)
    80004c56:	9fa9                	addw	a5,a5,a0
    80004c58:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004c5a:	6c88                	ld	a0,24(s1)
    80004c5c:	fffff097          	auipc	ra,0xfffff
    80004c60:	0a2080e7          	jalr	162(ra) # 80003cfe <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004c64:	854a                	mv	a0,s2
    80004c66:	70a2                	ld	ra,40(sp)
    80004c68:	7402                	ld	s0,32(sp)
    80004c6a:	64e2                	ld	s1,24(sp)
    80004c6c:	6942                	ld	s2,16(sp)
    80004c6e:	69a2                	ld	s3,8(sp)
    80004c70:	6145                	addi	sp,sp,48
    80004c72:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004c74:	6908                	ld	a0,16(a0)
    80004c76:	00000097          	auipc	ra,0x0
    80004c7a:	3c6080e7          	jalr	966(ra) # 8000503c <piperead>
    80004c7e:	892a                	mv	s2,a0
    80004c80:	b7d5                	j	80004c64 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004c82:	02451783          	lh	a5,36(a0)
    80004c86:	03079693          	slli	a3,a5,0x30
    80004c8a:	92c1                	srli	a3,a3,0x30
    80004c8c:	4725                	li	a4,9
    80004c8e:	02d76863          	bltu	a4,a3,80004cbe <fileread+0xba>
    80004c92:	0792                	slli	a5,a5,0x4
    80004c94:	0001d717          	auipc	a4,0x1d
    80004c98:	18470713          	addi	a4,a4,388 # 80021e18 <devsw>
    80004c9c:	97ba                	add	a5,a5,a4
    80004c9e:	639c                	ld	a5,0(a5)
    80004ca0:	c38d                	beqz	a5,80004cc2 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004ca2:	4505                	li	a0,1
    80004ca4:	9782                	jalr	a5
    80004ca6:	892a                	mv	s2,a0
    80004ca8:	bf75                	j	80004c64 <fileread+0x60>
    panic("fileread");
    80004caa:	00004517          	auipc	a0,0x4
    80004cae:	a4650513          	addi	a0,a0,-1466 # 800086f0 <syscalls+0x278>
    80004cb2:	ffffc097          	auipc	ra,0xffffc
    80004cb6:	88c080e7          	jalr	-1908(ra) # 8000053e <panic>
    return -1;
    80004cba:	597d                	li	s2,-1
    80004cbc:	b765                	j	80004c64 <fileread+0x60>
      return -1;
    80004cbe:	597d                	li	s2,-1
    80004cc0:	b755                	j	80004c64 <fileread+0x60>
    80004cc2:	597d                	li	s2,-1
    80004cc4:	b745                	j	80004c64 <fileread+0x60>

0000000080004cc6 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004cc6:	715d                	addi	sp,sp,-80
    80004cc8:	e486                	sd	ra,72(sp)
    80004cca:	e0a2                	sd	s0,64(sp)
    80004ccc:	fc26                	sd	s1,56(sp)
    80004cce:	f84a                	sd	s2,48(sp)
    80004cd0:	f44e                	sd	s3,40(sp)
    80004cd2:	f052                	sd	s4,32(sp)
    80004cd4:	ec56                	sd	s5,24(sp)
    80004cd6:	e85a                	sd	s6,16(sp)
    80004cd8:	e45e                	sd	s7,8(sp)
    80004cda:	e062                	sd	s8,0(sp)
    80004cdc:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004cde:	00954783          	lbu	a5,9(a0)
    80004ce2:	10078663          	beqz	a5,80004dee <filewrite+0x128>
    80004ce6:	892a                	mv	s2,a0
    80004ce8:	8aae                	mv	s5,a1
    80004cea:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004cec:	411c                	lw	a5,0(a0)
    80004cee:	4705                	li	a4,1
    80004cf0:	02e78263          	beq	a5,a4,80004d14 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004cf4:	470d                	li	a4,3
    80004cf6:	02e78663          	beq	a5,a4,80004d22 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004cfa:	4709                	li	a4,2
    80004cfc:	0ee79163          	bne	a5,a4,80004dde <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004d00:	0ac05d63          	blez	a2,80004dba <filewrite+0xf4>
    int i = 0;
    80004d04:	4981                	li	s3,0
    80004d06:	6b05                	lui	s6,0x1
    80004d08:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004d0c:	6b85                	lui	s7,0x1
    80004d0e:	c00b8b9b          	addiw	s7,s7,-1024
    80004d12:	a861                	j	80004daa <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004d14:	6908                	ld	a0,16(a0)
    80004d16:	00000097          	auipc	ra,0x0
    80004d1a:	22e080e7          	jalr	558(ra) # 80004f44 <pipewrite>
    80004d1e:	8a2a                	mv	s4,a0
    80004d20:	a045                	j	80004dc0 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004d22:	02451783          	lh	a5,36(a0)
    80004d26:	03079693          	slli	a3,a5,0x30
    80004d2a:	92c1                	srli	a3,a3,0x30
    80004d2c:	4725                	li	a4,9
    80004d2e:	0cd76263          	bltu	a4,a3,80004df2 <filewrite+0x12c>
    80004d32:	0792                	slli	a5,a5,0x4
    80004d34:	0001d717          	auipc	a4,0x1d
    80004d38:	0e470713          	addi	a4,a4,228 # 80021e18 <devsw>
    80004d3c:	97ba                	add	a5,a5,a4
    80004d3e:	679c                	ld	a5,8(a5)
    80004d40:	cbdd                	beqz	a5,80004df6 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004d42:	4505                	li	a0,1
    80004d44:	9782                	jalr	a5
    80004d46:	8a2a                	mv	s4,a0
    80004d48:	a8a5                	j	80004dc0 <filewrite+0xfa>
    80004d4a:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004d4e:	00000097          	auipc	ra,0x0
    80004d52:	8b0080e7          	jalr	-1872(ra) # 800045fe <begin_op>
      ilock(f->ip);
    80004d56:	01893503          	ld	a0,24(s2)
    80004d5a:	fffff097          	auipc	ra,0xfffff
    80004d5e:	ee2080e7          	jalr	-286(ra) # 80003c3c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004d62:	8762                	mv	a4,s8
    80004d64:	02092683          	lw	a3,32(s2)
    80004d68:	01598633          	add	a2,s3,s5
    80004d6c:	4585                	li	a1,1
    80004d6e:	01893503          	ld	a0,24(s2)
    80004d72:	fffff097          	auipc	ra,0xfffff
    80004d76:	276080e7          	jalr	630(ra) # 80003fe8 <writei>
    80004d7a:	84aa                	mv	s1,a0
    80004d7c:	00a05763          	blez	a0,80004d8a <filewrite+0xc4>
        f->off += r;
    80004d80:	02092783          	lw	a5,32(s2)
    80004d84:	9fa9                	addw	a5,a5,a0
    80004d86:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004d8a:	01893503          	ld	a0,24(s2)
    80004d8e:	fffff097          	auipc	ra,0xfffff
    80004d92:	f70080e7          	jalr	-144(ra) # 80003cfe <iunlock>
      end_op();
    80004d96:	00000097          	auipc	ra,0x0
    80004d9a:	8e8080e7          	jalr	-1816(ra) # 8000467e <end_op>

      if(r != n1){
    80004d9e:	009c1f63          	bne	s8,s1,80004dbc <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004da2:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004da6:	0149db63          	bge	s3,s4,80004dbc <filewrite+0xf6>
      int n1 = n - i;
    80004daa:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004dae:	84be                	mv	s1,a5
    80004db0:	2781                	sext.w	a5,a5
    80004db2:	f8fb5ce3          	bge	s6,a5,80004d4a <filewrite+0x84>
    80004db6:	84de                	mv	s1,s7
    80004db8:	bf49                	j	80004d4a <filewrite+0x84>
    int i = 0;
    80004dba:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004dbc:	013a1f63          	bne	s4,s3,80004dda <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004dc0:	8552                	mv	a0,s4
    80004dc2:	60a6                	ld	ra,72(sp)
    80004dc4:	6406                	ld	s0,64(sp)
    80004dc6:	74e2                	ld	s1,56(sp)
    80004dc8:	7942                	ld	s2,48(sp)
    80004dca:	79a2                	ld	s3,40(sp)
    80004dcc:	7a02                	ld	s4,32(sp)
    80004dce:	6ae2                	ld	s5,24(sp)
    80004dd0:	6b42                	ld	s6,16(sp)
    80004dd2:	6ba2                	ld	s7,8(sp)
    80004dd4:	6c02                	ld	s8,0(sp)
    80004dd6:	6161                	addi	sp,sp,80
    80004dd8:	8082                	ret
    ret = (i == n ? n : -1);
    80004dda:	5a7d                	li	s4,-1
    80004ddc:	b7d5                	j	80004dc0 <filewrite+0xfa>
    panic("filewrite");
    80004dde:	00004517          	auipc	a0,0x4
    80004de2:	92250513          	addi	a0,a0,-1758 # 80008700 <syscalls+0x288>
    80004de6:	ffffb097          	auipc	ra,0xffffb
    80004dea:	758080e7          	jalr	1880(ra) # 8000053e <panic>
    return -1;
    80004dee:	5a7d                	li	s4,-1
    80004df0:	bfc1                	j	80004dc0 <filewrite+0xfa>
      return -1;
    80004df2:	5a7d                	li	s4,-1
    80004df4:	b7f1                	j	80004dc0 <filewrite+0xfa>
    80004df6:	5a7d                	li	s4,-1
    80004df8:	b7e1                	j	80004dc0 <filewrite+0xfa>

0000000080004dfa <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004dfa:	7179                	addi	sp,sp,-48
    80004dfc:	f406                	sd	ra,40(sp)
    80004dfe:	f022                	sd	s0,32(sp)
    80004e00:	ec26                	sd	s1,24(sp)
    80004e02:	e84a                	sd	s2,16(sp)
    80004e04:	e44e                	sd	s3,8(sp)
    80004e06:	e052                	sd	s4,0(sp)
    80004e08:	1800                	addi	s0,sp,48
    80004e0a:	84aa                	mv	s1,a0
    80004e0c:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004e0e:	0005b023          	sd	zero,0(a1)
    80004e12:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004e16:	00000097          	auipc	ra,0x0
    80004e1a:	bf8080e7          	jalr	-1032(ra) # 80004a0e <filealloc>
    80004e1e:	e088                	sd	a0,0(s1)
    80004e20:	c551                	beqz	a0,80004eac <pipealloc+0xb2>
    80004e22:	00000097          	auipc	ra,0x0
    80004e26:	bec080e7          	jalr	-1044(ra) # 80004a0e <filealloc>
    80004e2a:	00aa3023          	sd	a0,0(s4)
    80004e2e:	c92d                	beqz	a0,80004ea0 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004e30:	ffffc097          	auipc	ra,0xffffc
    80004e34:	cb6080e7          	jalr	-842(ra) # 80000ae6 <kalloc>
    80004e38:	892a                	mv	s2,a0
    80004e3a:	c125                	beqz	a0,80004e9a <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004e3c:	4985                	li	s3,1
    80004e3e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004e42:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004e46:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004e4a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004e4e:	00004597          	auipc	a1,0x4
    80004e52:	8c258593          	addi	a1,a1,-1854 # 80008710 <syscalls+0x298>
    80004e56:	ffffc097          	auipc	ra,0xffffc
    80004e5a:	cf0080e7          	jalr	-784(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004e5e:	609c                	ld	a5,0(s1)
    80004e60:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004e64:	609c                	ld	a5,0(s1)
    80004e66:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004e6a:	609c                	ld	a5,0(s1)
    80004e6c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004e70:	609c                	ld	a5,0(s1)
    80004e72:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004e76:	000a3783          	ld	a5,0(s4)
    80004e7a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004e7e:	000a3783          	ld	a5,0(s4)
    80004e82:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004e86:	000a3783          	ld	a5,0(s4)
    80004e8a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004e8e:	000a3783          	ld	a5,0(s4)
    80004e92:	0127b823          	sd	s2,16(a5)
  return 0;
    80004e96:	4501                	li	a0,0
    80004e98:	a025                	j	80004ec0 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004e9a:	6088                	ld	a0,0(s1)
    80004e9c:	e501                	bnez	a0,80004ea4 <pipealloc+0xaa>
    80004e9e:	a039                	j	80004eac <pipealloc+0xb2>
    80004ea0:	6088                	ld	a0,0(s1)
    80004ea2:	c51d                	beqz	a0,80004ed0 <pipealloc+0xd6>
    fileclose(*f0);
    80004ea4:	00000097          	auipc	ra,0x0
    80004ea8:	c26080e7          	jalr	-986(ra) # 80004aca <fileclose>
  if(*f1)
    80004eac:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004eb0:	557d                	li	a0,-1
  if(*f1)
    80004eb2:	c799                	beqz	a5,80004ec0 <pipealloc+0xc6>
    fileclose(*f1);
    80004eb4:	853e                	mv	a0,a5
    80004eb6:	00000097          	auipc	ra,0x0
    80004eba:	c14080e7          	jalr	-1004(ra) # 80004aca <fileclose>
  return -1;
    80004ebe:	557d                	li	a0,-1
}
    80004ec0:	70a2                	ld	ra,40(sp)
    80004ec2:	7402                	ld	s0,32(sp)
    80004ec4:	64e2                	ld	s1,24(sp)
    80004ec6:	6942                	ld	s2,16(sp)
    80004ec8:	69a2                	ld	s3,8(sp)
    80004eca:	6a02                	ld	s4,0(sp)
    80004ecc:	6145                	addi	sp,sp,48
    80004ece:	8082                	ret
  return -1;
    80004ed0:	557d                	li	a0,-1
    80004ed2:	b7fd                	j	80004ec0 <pipealloc+0xc6>

0000000080004ed4 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004ed4:	1101                	addi	sp,sp,-32
    80004ed6:	ec06                	sd	ra,24(sp)
    80004ed8:	e822                	sd	s0,16(sp)
    80004eda:	e426                	sd	s1,8(sp)
    80004edc:	e04a                	sd	s2,0(sp)
    80004ede:	1000                	addi	s0,sp,32
    80004ee0:	84aa                	mv	s1,a0
    80004ee2:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004ee4:	ffffc097          	auipc	ra,0xffffc
    80004ee8:	cf2080e7          	jalr	-782(ra) # 80000bd6 <acquire>
  if(writable){
    80004eec:	02090d63          	beqz	s2,80004f26 <pipeclose+0x52>
    pi->writeopen = 0;
    80004ef0:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004ef4:	21848513          	addi	a0,s1,536
    80004ef8:	ffffd097          	auipc	ra,0xffffd
    80004efc:	53c080e7          	jalr	1340(ra) # 80002434 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004f00:	2204b783          	ld	a5,544(s1)
    80004f04:	eb95                	bnez	a5,80004f38 <pipeclose+0x64>
    release(&pi->lock);
    80004f06:	8526                	mv	a0,s1
    80004f08:	ffffc097          	auipc	ra,0xffffc
    80004f0c:	d82080e7          	jalr	-638(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004f10:	8526                	mv	a0,s1
    80004f12:	ffffc097          	auipc	ra,0xffffc
    80004f16:	ad8080e7          	jalr	-1320(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    80004f1a:	60e2                	ld	ra,24(sp)
    80004f1c:	6442                	ld	s0,16(sp)
    80004f1e:	64a2                	ld	s1,8(sp)
    80004f20:	6902                	ld	s2,0(sp)
    80004f22:	6105                	addi	sp,sp,32
    80004f24:	8082                	ret
    pi->readopen = 0;
    80004f26:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004f2a:	21c48513          	addi	a0,s1,540
    80004f2e:	ffffd097          	auipc	ra,0xffffd
    80004f32:	506080e7          	jalr	1286(ra) # 80002434 <wakeup>
    80004f36:	b7e9                	j	80004f00 <pipeclose+0x2c>
    release(&pi->lock);
    80004f38:	8526                	mv	a0,s1
    80004f3a:	ffffc097          	auipc	ra,0xffffc
    80004f3e:	d50080e7          	jalr	-688(ra) # 80000c8a <release>
}
    80004f42:	bfe1                	j	80004f1a <pipeclose+0x46>

0000000080004f44 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004f44:	711d                	addi	sp,sp,-96
    80004f46:	ec86                	sd	ra,88(sp)
    80004f48:	e8a2                	sd	s0,80(sp)
    80004f4a:	e4a6                	sd	s1,72(sp)
    80004f4c:	e0ca                	sd	s2,64(sp)
    80004f4e:	fc4e                	sd	s3,56(sp)
    80004f50:	f852                	sd	s4,48(sp)
    80004f52:	f456                	sd	s5,40(sp)
    80004f54:	f05a                	sd	s6,32(sp)
    80004f56:	ec5e                	sd	s7,24(sp)
    80004f58:	e862                	sd	s8,16(sp)
    80004f5a:	1080                	addi	s0,sp,96
    80004f5c:	84aa                	mv	s1,a0
    80004f5e:	8aae                	mv	s5,a1
    80004f60:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004f62:	ffffd097          	auipc	ra,0xffffd
    80004f66:	a68080e7          	jalr	-1432(ra) # 800019ca <myproc>
    80004f6a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004f6c:	8526                	mv	a0,s1
    80004f6e:	ffffc097          	auipc	ra,0xffffc
    80004f72:	c68080e7          	jalr	-920(ra) # 80000bd6 <acquire>
  while(i < n){
    80004f76:	0b405663          	blez	s4,80005022 <pipewrite+0xde>
  int i = 0;
    80004f7a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f7c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004f7e:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004f82:	21c48b93          	addi	s7,s1,540
    80004f86:	a089                	j	80004fc8 <pipewrite+0x84>
      release(&pi->lock);
    80004f88:	8526                	mv	a0,s1
    80004f8a:	ffffc097          	auipc	ra,0xffffc
    80004f8e:	d00080e7          	jalr	-768(ra) # 80000c8a <release>
      return -1;
    80004f92:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004f94:	854a                	mv	a0,s2
    80004f96:	60e6                	ld	ra,88(sp)
    80004f98:	6446                	ld	s0,80(sp)
    80004f9a:	64a6                	ld	s1,72(sp)
    80004f9c:	6906                	ld	s2,64(sp)
    80004f9e:	79e2                	ld	s3,56(sp)
    80004fa0:	7a42                	ld	s4,48(sp)
    80004fa2:	7aa2                	ld	s5,40(sp)
    80004fa4:	7b02                	ld	s6,32(sp)
    80004fa6:	6be2                	ld	s7,24(sp)
    80004fa8:	6c42                	ld	s8,16(sp)
    80004faa:	6125                	addi	sp,sp,96
    80004fac:	8082                	ret
      wakeup(&pi->nread);
    80004fae:	8562                	mv	a0,s8
    80004fb0:	ffffd097          	auipc	ra,0xffffd
    80004fb4:	484080e7          	jalr	1156(ra) # 80002434 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004fb8:	85a6                	mv	a1,s1
    80004fba:	855e                	mv	a0,s7
    80004fbc:	ffffd097          	auipc	ra,0xffffd
    80004fc0:	390080e7          	jalr	912(ra) # 8000234c <sleep>
  while(i < n){
    80004fc4:	07495063          	bge	s2,s4,80005024 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004fc8:	2204a783          	lw	a5,544(s1)
    80004fcc:	dfd5                	beqz	a5,80004f88 <pipewrite+0x44>
    80004fce:	854e                	mv	a0,s3
    80004fd0:	ffffd097          	auipc	ra,0xffffd
    80004fd4:	6d0080e7          	jalr	1744(ra) # 800026a0 <killed>
    80004fd8:	f945                	bnez	a0,80004f88 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004fda:	2184a783          	lw	a5,536(s1)
    80004fde:	21c4a703          	lw	a4,540(s1)
    80004fe2:	2007879b          	addiw	a5,a5,512
    80004fe6:	fcf704e3          	beq	a4,a5,80004fae <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004fea:	4685                	li	a3,1
    80004fec:	01590633          	add	a2,s2,s5
    80004ff0:	faf40593          	addi	a1,s0,-81
    80004ff4:	0989b503          	ld	a0,152(s3)
    80004ff8:	ffffc097          	auipc	ra,0xffffc
    80004ffc:	6fc080e7          	jalr	1788(ra) # 800016f4 <copyin>
    80005000:	03650263          	beq	a0,s6,80005024 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005004:	21c4a783          	lw	a5,540(s1)
    80005008:	0017871b          	addiw	a4,a5,1
    8000500c:	20e4ae23          	sw	a4,540(s1)
    80005010:	1ff7f793          	andi	a5,a5,511
    80005014:	97a6                	add	a5,a5,s1
    80005016:	faf44703          	lbu	a4,-81(s0)
    8000501a:	00e78c23          	sb	a4,24(a5)
      i++;
    8000501e:	2905                	addiw	s2,s2,1
    80005020:	b755                	j	80004fc4 <pipewrite+0x80>
  int i = 0;
    80005022:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005024:	21848513          	addi	a0,s1,536
    80005028:	ffffd097          	auipc	ra,0xffffd
    8000502c:	40c080e7          	jalr	1036(ra) # 80002434 <wakeup>
  release(&pi->lock);
    80005030:	8526                	mv	a0,s1
    80005032:	ffffc097          	auipc	ra,0xffffc
    80005036:	c58080e7          	jalr	-936(ra) # 80000c8a <release>
  return i;
    8000503a:	bfa9                	j	80004f94 <pipewrite+0x50>

000000008000503c <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000503c:	715d                	addi	sp,sp,-80
    8000503e:	e486                	sd	ra,72(sp)
    80005040:	e0a2                	sd	s0,64(sp)
    80005042:	fc26                	sd	s1,56(sp)
    80005044:	f84a                	sd	s2,48(sp)
    80005046:	f44e                	sd	s3,40(sp)
    80005048:	f052                	sd	s4,32(sp)
    8000504a:	ec56                	sd	s5,24(sp)
    8000504c:	e85a                	sd	s6,16(sp)
    8000504e:	0880                	addi	s0,sp,80
    80005050:	84aa                	mv	s1,a0
    80005052:	892e                	mv	s2,a1
    80005054:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005056:	ffffd097          	auipc	ra,0xffffd
    8000505a:	974080e7          	jalr	-1676(ra) # 800019ca <myproc>
    8000505e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005060:	8526                	mv	a0,s1
    80005062:	ffffc097          	auipc	ra,0xffffc
    80005066:	b74080e7          	jalr	-1164(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000506a:	2184a703          	lw	a4,536(s1)
    8000506e:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005072:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005076:	02f71763          	bne	a4,a5,800050a4 <piperead+0x68>
    8000507a:	2244a783          	lw	a5,548(s1)
    8000507e:	c39d                	beqz	a5,800050a4 <piperead+0x68>
    if(killed(pr)){
    80005080:	8552                	mv	a0,s4
    80005082:	ffffd097          	auipc	ra,0xffffd
    80005086:	61e080e7          	jalr	1566(ra) # 800026a0 <killed>
    8000508a:	e941                	bnez	a0,8000511a <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000508c:	85a6                	mv	a1,s1
    8000508e:	854e                	mv	a0,s3
    80005090:	ffffd097          	auipc	ra,0xffffd
    80005094:	2bc080e7          	jalr	700(ra) # 8000234c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005098:	2184a703          	lw	a4,536(s1)
    8000509c:	21c4a783          	lw	a5,540(s1)
    800050a0:	fcf70de3          	beq	a4,a5,8000507a <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050a4:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800050a6:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050a8:	05505363          	blez	s5,800050ee <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    800050ac:	2184a783          	lw	a5,536(s1)
    800050b0:	21c4a703          	lw	a4,540(s1)
    800050b4:	02f70d63          	beq	a4,a5,800050ee <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800050b8:	0017871b          	addiw	a4,a5,1
    800050bc:	20e4ac23          	sw	a4,536(s1)
    800050c0:	1ff7f793          	andi	a5,a5,511
    800050c4:	97a6                	add	a5,a5,s1
    800050c6:	0187c783          	lbu	a5,24(a5)
    800050ca:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800050ce:	4685                	li	a3,1
    800050d0:	fbf40613          	addi	a2,s0,-65
    800050d4:	85ca                	mv	a1,s2
    800050d6:	098a3503          	ld	a0,152(s4)
    800050da:	ffffc097          	auipc	ra,0xffffc
    800050de:	58e080e7          	jalr	1422(ra) # 80001668 <copyout>
    800050e2:	01650663          	beq	a0,s6,800050ee <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050e6:	2985                	addiw	s3,s3,1
    800050e8:	0905                	addi	s2,s2,1
    800050ea:	fd3a91e3          	bne	s5,s3,800050ac <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800050ee:	21c48513          	addi	a0,s1,540
    800050f2:	ffffd097          	auipc	ra,0xffffd
    800050f6:	342080e7          	jalr	834(ra) # 80002434 <wakeup>
  release(&pi->lock);
    800050fa:	8526                	mv	a0,s1
    800050fc:	ffffc097          	auipc	ra,0xffffc
    80005100:	b8e080e7          	jalr	-1138(ra) # 80000c8a <release>
  return i;
}
    80005104:	854e                	mv	a0,s3
    80005106:	60a6                	ld	ra,72(sp)
    80005108:	6406                	ld	s0,64(sp)
    8000510a:	74e2                	ld	s1,56(sp)
    8000510c:	7942                	ld	s2,48(sp)
    8000510e:	79a2                	ld	s3,40(sp)
    80005110:	7a02                	ld	s4,32(sp)
    80005112:	6ae2                	ld	s5,24(sp)
    80005114:	6b42                	ld	s6,16(sp)
    80005116:	6161                	addi	sp,sp,80
    80005118:	8082                	ret
      release(&pi->lock);
    8000511a:	8526                	mv	a0,s1
    8000511c:	ffffc097          	auipc	ra,0xffffc
    80005120:	b6e080e7          	jalr	-1170(ra) # 80000c8a <release>
      return -1;
    80005124:	59fd                	li	s3,-1
    80005126:	bff9                	j	80005104 <piperead+0xc8>

0000000080005128 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80005128:	1141                	addi	sp,sp,-16
    8000512a:	e422                	sd	s0,8(sp)
    8000512c:	0800                	addi	s0,sp,16
    8000512e:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80005130:	8905                	andi	a0,a0,1
    80005132:	c111                	beqz	a0,80005136 <flags2perm+0xe>
      perm = PTE_X;
    80005134:	4521                	li	a0,8
    if(flags & 0x2)
    80005136:	8b89                	andi	a5,a5,2
    80005138:	c399                	beqz	a5,8000513e <flags2perm+0x16>
      perm |= PTE_W;
    8000513a:	00456513          	ori	a0,a0,4
    return perm;
}
    8000513e:	6422                	ld	s0,8(sp)
    80005140:	0141                	addi	sp,sp,16
    80005142:	8082                	ret

0000000080005144 <exec>:

int
exec(char *path, char **argv)
{
    80005144:	de010113          	addi	sp,sp,-544
    80005148:	20113c23          	sd	ra,536(sp)
    8000514c:	20813823          	sd	s0,528(sp)
    80005150:	20913423          	sd	s1,520(sp)
    80005154:	21213023          	sd	s2,512(sp)
    80005158:	ffce                	sd	s3,504(sp)
    8000515a:	fbd2                	sd	s4,496(sp)
    8000515c:	f7d6                	sd	s5,488(sp)
    8000515e:	f3da                	sd	s6,480(sp)
    80005160:	efde                	sd	s7,472(sp)
    80005162:	ebe2                	sd	s8,464(sp)
    80005164:	e7e6                	sd	s9,456(sp)
    80005166:	e3ea                	sd	s10,448(sp)
    80005168:	ff6e                	sd	s11,440(sp)
    8000516a:	1400                	addi	s0,sp,544
    8000516c:	892a                	mv	s2,a0
    8000516e:	dea43423          	sd	a0,-536(s0)
    80005172:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005176:	ffffd097          	auipc	ra,0xffffd
    8000517a:	854080e7          	jalr	-1964(ra) # 800019ca <myproc>
    8000517e:	84aa                	mv	s1,a0

  begin_op();
    80005180:	fffff097          	auipc	ra,0xfffff
    80005184:	47e080e7          	jalr	1150(ra) # 800045fe <begin_op>

  if((ip = namei(path)) == 0){
    80005188:	854a                	mv	a0,s2
    8000518a:	fffff097          	auipc	ra,0xfffff
    8000518e:	258080e7          	jalr	600(ra) # 800043e2 <namei>
    80005192:	c93d                	beqz	a0,80005208 <exec+0xc4>
    80005194:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005196:	fffff097          	auipc	ra,0xfffff
    8000519a:	aa6080e7          	jalr	-1370(ra) # 80003c3c <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000519e:	04000713          	li	a4,64
    800051a2:	4681                	li	a3,0
    800051a4:	e5040613          	addi	a2,s0,-432
    800051a8:	4581                	li	a1,0
    800051aa:	8556                	mv	a0,s5
    800051ac:	fffff097          	auipc	ra,0xfffff
    800051b0:	d44080e7          	jalr	-700(ra) # 80003ef0 <readi>
    800051b4:	04000793          	li	a5,64
    800051b8:	00f51a63          	bne	a0,a5,800051cc <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800051bc:	e5042703          	lw	a4,-432(s0)
    800051c0:	464c47b7          	lui	a5,0x464c4
    800051c4:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800051c8:	04f70663          	beq	a4,a5,80005214 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800051cc:	8556                	mv	a0,s5
    800051ce:	fffff097          	auipc	ra,0xfffff
    800051d2:	cd0080e7          	jalr	-816(ra) # 80003e9e <iunlockput>
    end_op();
    800051d6:	fffff097          	auipc	ra,0xfffff
    800051da:	4a8080e7          	jalr	1192(ra) # 8000467e <end_op>
  }
  return -1;
    800051de:	557d                	li	a0,-1
}
    800051e0:	21813083          	ld	ra,536(sp)
    800051e4:	21013403          	ld	s0,528(sp)
    800051e8:	20813483          	ld	s1,520(sp)
    800051ec:	20013903          	ld	s2,512(sp)
    800051f0:	79fe                	ld	s3,504(sp)
    800051f2:	7a5e                	ld	s4,496(sp)
    800051f4:	7abe                	ld	s5,488(sp)
    800051f6:	7b1e                	ld	s6,480(sp)
    800051f8:	6bfe                	ld	s7,472(sp)
    800051fa:	6c5e                	ld	s8,464(sp)
    800051fc:	6cbe                	ld	s9,456(sp)
    800051fe:	6d1e                	ld	s10,448(sp)
    80005200:	7dfa                	ld	s11,440(sp)
    80005202:	22010113          	addi	sp,sp,544
    80005206:	8082                	ret
    end_op();
    80005208:	fffff097          	auipc	ra,0xfffff
    8000520c:	476080e7          	jalr	1142(ra) # 8000467e <end_op>
    return -1;
    80005210:	557d                	li	a0,-1
    80005212:	b7f9                	j	800051e0 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80005214:	8526                	mv	a0,s1
    80005216:	ffffd097          	auipc	ra,0xffffd
    8000521a:	878080e7          	jalr	-1928(ra) # 80001a8e <proc_pagetable>
    8000521e:	8b2a                	mv	s6,a0
    80005220:	d555                	beqz	a0,800051cc <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005222:	e7042783          	lw	a5,-400(s0)
    80005226:	e8845703          	lhu	a4,-376(s0)
    8000522a:	c735                	beqz	a4,80005296 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000522c:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000522e:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005232:	6a05                	lui	s4,0x1
    80005234:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005238:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    8000523c:	6d85                	lui	s11,0x1
    8000523e:	7d7d                	lui	s10,0xfffff
    80005240:	a481                	j	80005480 <exec+0x33c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005242:	00003517          	auipc	a0,0x3
    80005246:	4d650513          	addi	a0,a0,1238 # 80008718 <syscalls+0x2a0>
    8000524a:	ffffb097          	auipc	ra,0xffffb
    8000524e:	2f4080e7          	jalr	756(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005252:	874a                	mv	a4,s2
    80005254:	009c86bb          	addw	a3,s9,s1
    80005258:	4581                	li	a1,0
    8000525a:	8556                	mv	a0,s5
    8000525c:	fffff097          	auipc	ra,0xfffff
    80005260:	c94080e7          	jalr	-876(ra) # 80003ef0 <readi>
    80005264:	2501                	sext.w	a0,a0
    80005266:	1aa91a63          	bne	s2,a0,8000541a <exec+0x2d6>
  for(i = 0; i < sz; i += PGSIZE){
    8000526a:	009d84bb          	addw	s1,s11,s1
    8000526e:	013d09bb          	addw	s3,s10,s3
    80005272:	1f74f763          	bgeu	s1,s7,80005460 <exec+0x31c>
    pa = walkaddr(pagetable, va + i);
    80005276:	02049593          	slli	a1,s1,0x20
    8000527a:	9181                	srli	a1,a1,0x20
    8000527c:	95e2                	add	a1,a1,s8
    8000527e:	855a                	mv	a0,s6
    80005280:	ffffc097          	auipc	ra,0xffffc
    80005284:	ddc080e7          	jalr	-548(ra) # 8000105c <walkaddr>
    80005288:	862a                	mv	a2,a0
    if(pa == 0)
    8000528a:	dd45                	beqz	a0,80005242 <exec+0xfe>
      n = PGSIZE;
    8000528c:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    8000528e:	fd49f2e3          	bgeu	s3,s4,80005252 <exec+0x10e>
      n = sz - i;
    80005292:	894e                	mv	s2,s3
    80005294:	bf7d                	j	80005252 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005296:	4901                	li	s2,0
  iunlockput(ip);
    80005298:	8556                	mv	a0,s5
    8000529a:	fffff097          	auipc	ra,0xfffff
    8000529e:	c04080e7          	jalr	-1020(ra) # 80003e9e <iunlockput>
  end_op();
    800052a2:	fffff097          	auipc	ra,0xfffff
    800052a6:	3dc080e7          	jalr	988(ra) # 8000467e <end_op>
  p = myproc();
    800052aa:	ffffc097          	auipc	ra,0xffffc
    800052ae:	720080e7          	jalr	1824(ra) # 800019ca <myproc>
    800052b2:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    800052b4:	09053d03          	ld	s10,144(a0)
  sz = PGROUNDUP(sz);
    800052b8:	6785                	lui	a5,0x1
    800052ba:	17fd                	addi	a5,a5,-1
    800052bc:	993e                	add	s2,s2,a5
    800052be:	77fd                	lui	a5,0xfffff
    800052c0:	00f977b3          	and	a5,s2,a5
    800052c4:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800052c8:	4691                	li	a3,4
    800052ca:	6609                	lui	a2,0x2
    800052cc:	963e                	add	a2,a2,a5
    800052ce:	85be                	mv	a1,a5
    800052d0:	855a                	mv	a0,s6
    800052d2:	ffffc097          	auipc	ra,0xffffc
    800052d6:	13e080e7          	jalr	318(ra) # 80001410 <uvmalloc>
    800052da:	8c2a                	mv	s8,a0
  ip = 0;
    800052dc:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800052de:	12050e63          	beqz	a0,8000541a <exec+0x2d6>
  uvmclear(pagetable, sz-2*PGSIZE);
    800052e2:	75f9                	lui	a1,0xffffe
    800052e4:	95aa                	add	a1,a1,a0
    800052e6:	855a                	mv	a0,s6
    800052e8:	ffffc097          	auipc	ra,0xffffc
    800052ec:	34e080e7          	jalr	846(ra) # 80001636 <uvmclear>
  stackbase = sp - PGSIZE;
    800052f0:	7afd                	lui	s5,0xfffff
    800052f2:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    800052f4:	df043783          	ld	a5,-528(s0)
    800052f8:	6388                	ld	a0,0(a5)
    800052fa:	c925                	beqz	a0,8000536a <exec+0x226>
    800052fc:	e9040993          	addi	s3,s0,-368
    80005300:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80005304:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005306:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005308:	ffffc097          	auipc	ra,0xffffc
    8000530c:	b46080e7          	jalr	-1210(ra) # 80000e4e <strlen>
    80005310:	0015079b          	addiw	a5,a0,1
    80005314:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005318:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    8000531c:	13596663          	bltu	s2,s5,80005448 <exec+0x304>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005320:	df043d83          	ld	s11,-528(s0)
    80005324:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005328:	8552                	mv	a0,s4
    8000532a:	ffffc097          	auipc	ra,0xffffc
    8000532e:	b24080e7          	jalr	-1244(ra) # 80000e4e <strlen>
    80005332:	0015069b          	addiw	a3,a0,1
    80005336:	8652                	mv	a2,s4
    80005338:	85ca                	mv	a1,s2
    8000533a:	855a                	mv	a0,s6
    8000533c:	ffffc097          	auipc	ra,0xffffc
    80005340:	32c080e7          	jalr	812(ra) # 80001668 <copyout>
    80005344:	10054663          	bltz	a0,80005450 <exec+0x30c>
    ustack[argc] = sp;
    80005348:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000534c:	0485                	addi	s1,s1,1
    8000534e:	008d8793          	addi	a5,s11,8
    80005352:	def43823          	sd	a5,-528(s0)
    80005356:	008db503          	ld	a0,8(s11)
    8000535a:	c911                	beqz	a0,8000536e <exec+0x22a>
    if(argc >= MAXARG)
    8000535c:	09a1                	addi	s3,s3,8
    8000535e:	fb3c95e3          	bne	s9,s3,80005308 <exec+0x1c4>
  sz = sz1;
    80005362:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005366:	4a81                	li	s5,0
    80005368:	a84d                	j	8000541a <exec+0x2d6>
  sp = sz;
    8000536a:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000536c:	4481                	li	s1,0
  ustack[argc] = 0;
    8000536e:	00349793          	slli	a5,s1,0x3
    80005372:	f9040713          	addi	a4,s0,-112
    80005376:	97ba                	add	a5,a5,a4
    80005378:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffdbf50>
  sp -= (argc+1) * sizeof(uint64);
    8000537c:	00148693          	addi	a3,s1,1
    80005380:	068e                	slli	a3,a3,0x3
    80005382:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005386:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    8000538a:	01597663          	bgeu	s2,s5,80005396 <exec+0x252>
  sz = sz1;
    8000538e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005392:	4a81                	li	s5,0
    80005394:	a059                	j	8000541a <exec+0x2d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005396:	e9040613          	addi	a2,s0,-368
    8000539a:	85ca                	mv	a1,s2
    8000539c:	855a                	mv	a0,s6
    8000539e:	ffffc097          	auipc	ra,0xffffc
    800053a2:	2ca080e7          	jalr	714(ra) # 80001668 <copyout>
    800053a6:	0a054963          	bltz	a0,80005458 <exec+0x314>
  p->trapframe->a1 = sp;
    800053aa:	0a0bb783          	ld	a5,160(s7) # 10a0 <_entry-0x7fffef60>
    800053ae:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800053b2:	de843783          	ld	a5,-536(s0)
    800053b6:	0007c703          	lbu	a4,0(a5)
    800053ba:	cf11                	beqz	a4,800053d6 <exec+0x292>
    800053bc:	0785                	addi	a5,a5,1
    if(*s == '/')
    800053be:	02f00693          	li	a3,47
    800053c2:	a039                	j	800053d0 <exec+0x28c>
      last = s+1;
    800053c4:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800053c8:	0785                	addi	a5,a5,1
    800053ca:	fff7c703          	lbu	a4,-1(a5)
    800053ce:	c701                	beqz	a4,800053d6 <exec+0x292>
    if(*s == '/')
    800053d0:	fed71ce3          	bne	a4,a3,800053c8 <exec+0x284>
    800053d4:	bfc5                	j	800053c4 <exec+0x280>
  safestrcpy(p->name, last, sizeof(p->name));
    800053d6:	4641                	li	a2,16
    800053d8:	de843583          	ld	a1,-536(s0)
    800053dc:	1a0b8513          	addi	a0,s7,416
    800053e0:	ffffc097          	auipc	ra,0xffffc
    800053e4:	a3c080e7          	jalr	-1476(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    800053e8:	098bb503          	ld	a0,152(s7)
  p->pagetable = pagetable;
    800053ec:	096bbc23          	sd	s6,152(s7)
  p->sz = sz;
    800053f0:	098bb823          	sd	s8,144(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800053f4:	0a0bb783          	ld	a5,160(s7)
    800053f8:	e6843703          	ld	a4,-408(s0)
    800053fc:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800053fe:	0a0bb783          	ld	a5,160(s7)
    80005402:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005406:	85ea                	mv	a1,s10
    80005408:	ffffc097          	auipc	ra,0xffffc
    8000540c:	722080e7          	jalr	1826(ra) # 80001b2a <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005410:	0004851b          	sext.w	a0,s1
    80005414:	b3f1                	j	800051e0 <exec+0x9c>
    80005416:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    8000541a:	df843583          	ld	a1,-520(s0)
    8000541e:	855a                	mv	a0,s6
    80005420:	ffffc097          	auipc	ra,0xffffc
    80005424:	70a080e7          	jalr	1802(ra) # 80001b2a <proc_freepagetable>
  if(ip){
    80005428:	da0a92e3          	bnez	s5,800051cc <exec+0x88>
  return -1;
    8000542c:	557d                	li	a0,-1
    8000542e:	bb4d                	j	800051e0 <exec+0x9c>
    80005430:	df243c23          	sd	s2,-520(s0)
    80005434:	b7dd                	j	8000541a <exec+0x2d6>
    80005436:	df243c23          	sd	s2,-520(s0)
    8000543a:	b7c5                	j	8000541a <exec+0x2d6>
    8000543c:	df243c23          	sd	s2,-520(s0)
    80005440:	bfe9                	j	8000541a <exec+0x2d6>
    80005442:	df243c23          	sd	s2,-520(s0)
    80005446:	bfd1                	j	8000541a <exec+0x2d6>
  sz = sz1;
    80005448:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000544c:	4a81                	li	s5,0
    8000544e:	b7f1                	j	8000541a <exec+0x2d6>
  sz = sz1;
    80005450:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005454:	4a81                	li	s5,0
    80005456:	b7d1                	j	8000541a <exec+0x2d6>
  sz = sz1;
    80005458:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000545c:	4a81                	li	s5,0
    8000545e:	bf75                	j	8000541a <exec+0x2d6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005460:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005464:	e0843783          	ld	a5,-504(s0)
    80005468:	0017869b          	addiw	a3,a5,1
    8000546c:	e0d43423          	sd	a3,-504(s0)
    80005470:	e0043783          	ld	a5,-512(s0)
    80005474:	0387879b          	addiw	a5,a5,56
    80005478:	e8845703          	lhu	a4,-376(s0)
    8000547c:	e0e6dee3          	bge	a3,a4,80005298 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005480:	2781                	sext.w	a5,a5
    80005482:	e0f43023          	sd	a5,-512(s0)
    80005486:	03800713          	li	a4,56
    8000548a:	86be                	mv	a3,a5
    8000548c:	e1840613          	addi	a2,s0,-488
    80005490:	4581                	li	a1,0
    80005492:	8556                	mv	a0,s5
    80005494:	fffff097          	auipc	ra,0xfffff
    80005498:	a5c080e7          	jalr	-1444(ra) # 80003ef0 <readi>
    8000549c:	03800793          	li	a5,56
    800054a0:	f6f51be3          	bne	a0,a5,80005416 <exec+0x2d2>
    if(ph.type != ELF_PROG_LOAD)
    800054a4:	e1842783          	lw	a5,-488(s0)
    800054a8:	4705                	li	a4,1
    800054aa:	fae79de3          	bne	a5,a4,80005464 <exec+0x320>
    if(ph.memsz < ph.filesz)
    800054ae:	e4043483          	ld	s1,-448(s0)
    800054b2:	e3843783          	ld	a5,-456(s0)
    800054b6:	f6f4ede3          	bltu	s1,a5,80005430 <exec+0x2ec>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800054ba:	e2843783          	ld	a5,-472(s0)
    800054be:	94be                	add	s1,s1,a5
    800054c0:	f6f4ebe3          	bltu	s1,a5,80005436 <exec+0x2f2>
    if(ph.vaddr % PGSIZE != 0)
    800054c4:	de043703          	ld	a4,-544(s0)
    800054c8:	8ff9                	and	a5,a5,a4
    800054ca:	fbad                	bnez	a5,8000543c <exec+0x2f8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800054cc:	e1c42503          	lw	a0,-484(s0)
    800054d0:	00000097          	auipc	ra,0x0
    800054d4:	c58080e7          	jalr	-936(ra) # 80005128 <flags2perm>
    800054d8:	86aa                	mv	a3,a0
    800054da:	8626                	mv	a2,s1
    800054dc:	85ca                	mv	a1,s2
    800054de:	855a                	mv	a0,s6
    800054e0:	ffffc097          	auipc	ra,0xffffc
    800054e4:	f30080e7          	jalr	-208(ra) # 80001410 <uvmalloc>
    800054e8:	dea43c23          	sd	a0,-520(s0)
    800054ec:	d939                	beqz	a0,80005442 <exec+0x2fe>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800054ee:	e2843c03          	ld	s8,-472(s0)
    800054f2:	e2042c83          	lw	s9,-480(s0)
    800054f6:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800054fa:	f60b83e3          	beqz	s7,80005460 <exec+0x31c>
    800054fe:	89de                	mv	s3,s7
    80005500:	4481                	li	s1,0
    80005502:	bb95                	j	80005276 <exec+0x132>

0000000080005504 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005504:	7179                	addi	sp,sp,-48
    80005506:	f406                	sd	ra,40(sp)
    80005508:	f022                	sd	s0,32(sp)
    8000550a:	ec26                	sd	s1,24(sp)
    8000550c:	e84a                	sd	s2,16(sp)
    8000550e:	1800                	addi	s0,sp,48
    80005510:	892e                	mv	s2,a1
    80005512:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005514:	fdc40593          	addi	a1,s0,-36
    80005518:	ffffe097          	auipc	ra,0xffffe
    8000551c:	ac2080e7          	jalr	-1342(ra) # 80002fda <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005520:	fdc42703          	lw	a4,-36(s0)
    80005524:	47bd                	li	a5,15
    80005526:	02e7eb63          	bltu	a5,a4,8000555c <argfd+0x58>
    8000552a:	ffffc097          	auipc	ra,0xffffc
    8000552e:	4a0080e7          	jalr	1184(ra) # 800019ca <myproc>
    80005532:	fdc42703          	lw	a4,-36(s0)
    80005536:	02270793          	addi	a5,a4,34
    8000553a:	078e                	slli	a5,a5,0x3
    8000553c:	953e                	add	a0,a0,a5
    8000553e:	651c                	ld	a5,8(a0)
    80005540:	c385                	beqz	a5,80005560 <argfd+0x5c>
    return -1;
  if(pfd)
    80005542:	00090463          	beqz	s2,8000554a <argfd+0x46>
    *pfd = fd;
    80005546:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000554a:	4501                	li	a0,0
  if(pf)
    8000554c:	c091                	beqz	s1,80005550 <argfd+0x4c>
    *pf = f;
    8000554e:	e09c                	sd	a5,0(s1)
}
    80005550:	70a2                	ld	ra,40(sp)
    80005552:	7402                	ld	s0,32(sp)
    80005554:	64e2                	ld	s1,24(sp)
    80005556:	6942                	ld	s2,16(sp)
    80005558:	6145                	addi	sp,sp,48
    8000555a:	8082                	ret
    return -1;
    8000555c:	557d                	li	a0,-1
    8000555e:	bfcd                	j	80005550 <argfd+0x4c>
    80005560:	557d                	li	a0,-1
    80005562:	b7fd                	j	80005550 <argfd+0x4c>

0000000080005564 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005564:	1101                	addi	sp,sp,-32
    80005566:	ec06                	sd	ra,24(sp)
    80005568:	e822                	sd	s0,16(sp)
    8000556a:	e426                	sd	s1,8(sp)
    8000556c:	1000                	addi	s0,sp,32
    8000556e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005570:	ffffc097          	auipc	ra,0xffffc
    80005574:	45a080e7          	jalr	1114(ra) # 800019ca <myproc>
    80005578:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000557a:	11850793          	addi	a5,a0,280
    8000557e:	4501                	li	a0,0
    80005580:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005582:	6398                	ld	a4,0(a5)
    80005584:	cb19                	beqz	a4,8000559a <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005586:	2505                	addiw	a0,a0,1
    80005588:	07a1                	addi	a5,a5,8
    8000558a:	fed51ce3          	bne	a0,a3,80005582 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000558e:	557d                	li	a0,-1
}
    80005590:	60e2                	ld	ra,24(sp)
    80005592:	6442                	ld	s0,16(sp)
    80005594:	64a2                	ld	s1,8(sp)
    80005596:	6105                	addi	sp,sp,32
    80005598:	8082                	ret
      p->ofile[fd] = f;
    8000559a:	02250793          	addi	a5,a0,34
    8000559e:	078e                	slli	a5,a5,0x3
    800055a0:	963e                	add	a2,a2,a5
    800055a2:	e604                	sd	s1,8(a2)
      return fd;
    800055a4:	b7f5                	j	80005590 <fdalloc+0x2c>

00000000800055a6 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800055a6:	715d                	addi	sp,sp,-80
    800055a8:	e486                	sd	ra,72(sp)
    800055aa:	e0a2                	sd	s0,64(sp)
    800055ac:	fc26                	sd	s1,56(sp)
    800055ae:	f84a                	sd	s2,48(sp)
    800055b0:	f44e                	sd	s3,40(sp)
    800055b2:	f052                	sd	s4,32(sp)
    800055b4:	ec56                	sd	s5,24(sp)
    800055b6:	e85a                	sd	s6,16(sp)
    800055b8:	0880                	addi	s0,sp,80
    800055ba:	8b2e                	mv	s6,a1
    800055bc:	89b2                	mv	s3,a2
    800055be:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800055c0:	fb040593          	addi	a1,s0,-80
    800055c4:	fffff097          	auipc	ra,0xfffff
    800055c8:	e3c080e7          	jalr	-452(ra) # 80004400 <nameiparent>
    800055cc:	84aa                	mv	s1,a0
    800055ce:	14050f63          	beqz	a0,8000572c <create+0x186>
    return 0;

  ilock(dp);
    800055d2:	ffffe097          	auipc	ra,0xffffe
    800055d6:	66a080e7          	jalr	1642(ra) # 80003c3c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800055da:	4601                	li	a2,0
    800055dc:	fb040593          	addi	a1,s0,-80
    800055e0:	8526                	mv	a0,s1
    800055e2:	fffff097          	auipc	ra,0xfffff
    800055e6:	b3e080e7          	jalr	-1218(ra) # 80004120 <dirlookup>
    800055ea:	8aaa                	mv	s5,a0
    800055ec:	c931                	beqz	a0,80005640 <create+0x9a>
    iunlockput(dp);
    800055ee:	8526                	mv	a0,s1
    800055f0:	fffff097          	auipc	ra,0xfffff
    800055f4:	8ae080e7          	jalr	-1874(ra) # 80003e9e <iunlockput>
    ilock(ip);
    800055f8:	8556                	mv	a0,s5
    800055fa:	ffffe097          	auipc	ra,0xffffe
    800055fe:	642080e7          	jalr	1602(ra) # 80003c3c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005602:	000b059b          	sext.w	a1,s6
    80005606:	4789                	li	a5,2
    80005608:	02f59563          	bne	a1,a5,80005632 <create+0x8c>
    8000560c:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdc094>
    80005610:	37f9                	addiw	a5,a5,-2
    80005612:	17c2                	slli	a5,a5,0x30
    80005614:	93c1                	srli	a5,a5,0x30
    80005616:	4705                	li	a4,1
    80005618:	00f76d63          	bltu	a4,a5,80005632 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000561c:	8556                	mv	a0,s5
    8000561e:	60a6                	ld	ra,72(sp)
    80005620:	6406                	ld	s0,64(sp)
    80005622:	74e2                	ld	s1,56(sp)
    80005624:	7942                	ld	s2,48(sp)
    80005626:	79a2                	ld	s3,40(sp)
    80005628:	7a02                	ld	s4,32(sp)
    8000562a:	6ae2                	ld	s5,24(sp)
    8000562c:	6b42                	ld	s6,16(sp)
    8000562e:	6161                	addi	sp,sp,80
    80005630:	8082                	ret
    iunlockput(ip);
    80005632:	8556                	mv	a0,s5
    80005634:	fffff097          	auipc	ra,0xfffff
    80005638:	86a080e7          	jalr	-1942(ra) # 80003e9e <iunlockput>
    return 0;
    8000563c:	4a81                	li	s5,0
    8000563e:	bff9                	j	8000561c <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005640:	85da                	mv	a1,s6
    80005642:	4088                	lw	a0,0(s1)
    80005644:	ffffe097          	auipc	ra,0xffffe
    80005648:	45c080e7          	jalr	1116(ra) # 80003aa0 <ialloc>
    8000564c:	8a2a                	mv	s4,a0
    8000564e:	c539                	beqz	a0,8000569c <create+0xf6>
  ilock(ip);
    80005650:	ffffe097          	auipc	ra,0xffffe
    80005654:	5ec080e7          	jalr	1516(ra) # 80003c3c <ilock>
  ip->major = major;
    80005658:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000565c:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005660:	4905                	li	s2,1
    80005662:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005666:	8552                	mv	a0,s4
    80005668:	ffffe097          	auipc	ra,0xffffe
    8000566c:	50a080e7          	jalr	1290(ra) # 80003b72 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005670:	000b059b          	sext.w	a1,s6
    80005674:	03258b63          	beq	a1,s2,800056aa <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    80005678:	004a2603          	lw	a2,4(s4)
    8000567c:	fb040593          	addi	a1,s0,-80
    80005680:	8526                	mv	a0,s1
    80005682:	fffff097          	auipc	ra,0xfffff
    80005686:	cae080e7          	jalr	-850(ra) # 80004330 <dirlink>
    8000568a:	06054f63          	bltz	a0,80005708 <create+0x162>
  iunlockput(dp);
    8000568e:	8526                	mv	a0,s1
    80005690:	fffff097          	auipc	ra,0xfffff
    80005694:	80e080e7          	jalr	-2034(ra) # 80003e9e <iunlockput>
  return ip;
    80005698:	8ad2                	mv	s5,s4
    8000569a:	b749                	j	8000561c <create+0x76>
    iunlockput(dp);
    8000569c:	8526                	mv	a0,s1
    8000569e:	fffff097          	auipc	ra,0xfffff
    800056a2:	800080e7          	jalr	-2048(ra) # 80003e9e <iunlockput>
    return 0;
    800056a6:	8ad2                	mv	s5,s4
    800056a8:	bf95                	j	8000561c <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800056aa:	004a2603          	lw	a2,4(s4)
    800056ae:	00003597          	auipc	a1,0x3
    800056b2:	08a58593          	addi	a1,a1,138 # 80008738 <syscalls+0x2c0>
    800056b6:	8552                	mv	a0,s4
    800056b8:	fffff097          	auipc	ra,0xfffff
    800056bc:	c78080e7          	jalr	-904(ra) # 80004330 <dirlink>
    800056c0:	04054463          	bltz	a0,80005708 <create+0x162>
    800056c4:	40d0                	lw	a2,4(s1)
    800056c6:	00003597          	auipc	a1,0x3
    800056ca:	07a58593          	addi	a1,a1,122 # 80008740 <syscalls+0x2c8>
    800056ce:	8552                	mv	a0,s4
    800056d0:	fffff097          	auipc	ra,0xfffff
    800056d4:	c60080e7          	jalr	-928(ra) # 80004330 <dirlink>
    800056d8:	02054863          	bltz	a0,80005708 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    800056dc:	004a2603          	lw	a2,4(s4)
    800056e0:	fb040593          	addi	a1,s0,-80
    800056e4:	8526                	mv	a0,s1
    800056e6:	fffff097          	auipc	ra,0xfffff
    800056ea:	c4a080e7          	jalr	-950(ra) # 80004330 <dirlink>
    800056ee:	00054d63          	bltz	a0,80005708 <create+0x162>
    dp->nlink++;  // for ".."
    800056f2:	04a4d783          	lhu	a5,74(s1)
    800056f6:	2785                	addiw	a5,a5,1
    800056f8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800056fc:	8526                	mv	a0,s1
    800056fe:	ffffe097          	auipc	ra,0xffffe
    80005702:	474080e7          	jalr	1140(ra) # 80003b72 <iupdate>
    80005706:	b761                	j	8000568e <create+0xe8>
  ip->nlink = 0;
    80005708:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000570c:	8552                	mv	a0,s4
    8000570e:	ffffe097          	auipc	ra,0xffffe
    80005712:	464080e7          	jalr	1124(ra) # 80003b72 <iupdate>
  iunlockput(ip);
    80005716:	8552                	mv	a0,s4
    80005718:	ffffe097          	auipc	ra,0xffffe
    8000571c:	786080e7          	jalr	1926(ra) # 80003e9e <iunlockput>
  iunlockput(dp);
    80005720:	8526                	mv	a0,s1
    80005722:	ffffe097          	auipc	ra,0xffffe
    80005726:	77c080e7          	jalr	1916(ra) # 80003e9e <iunlockput>
  return 0;
    8000572a:	bdcd                	j	8000561c <create+0x76>
    return 0;
    8000572c:	8aaa                	mv	s5,a0
    8000572e:	b5fd                	j	8000561c <create+0x76>

0000000080005730 <sys_dup>:
{
    80005730:	7179                	addi	sp,sp,-48
    80005732:	f406                	sd	ra,40(sp)
    80005734:	f022                	sd	s0,32(sp)
    80005736:	ec26                	sd	s1,24(sp)
    80005738:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000573a:	fd840613          	addi	a2,s0,-40
    8000573e:	4581                	li	a1,0
    80005740:	4501                	li	a0,0
    80005742:	00000097          	auipc	ra,0x0
    80005746:	dc2080e7          	jalr	-574(ra) # 80005504 <argfd>
    return -1;
    8000574a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000574c:	02054363          	bltz	a0,80005772 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005750:	fd843503          	ld	a0,-40(s0)
    80005754:	00000097          	auipc	ra,0x0
    80005758:	e10080e7          	jalr	-496(ra) # 80005564 <fdalloc>
    8000575c:	84aa                	mv	s1,a0
    return -1;
    8000575e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005760:	00054963          	bltz	a0,80005772 <sys_dup+0x42>
  filedup(f);
    80005764:	fd843503          	ld	a0,-40(s0)
    80005768:	fffff097          	auipc	ra,0xfffff
    8000576c:	310080e7          	jalr	784(ra) # 80004a78 <filedup>
  return fd;
    80005770:	87a6                	mv	a5,s1
}
    80005772:	853e                	mv	a0,a5
    80005774:	70a2                	ld	ra,40(sp)
    80005776:	7402                	ld	s0,32(sp)
    80005778:	64e2                	ld	s1,24(sp)
    8000577a:	6145                	addi	sp,sp,48
    8000577c:	8082                	ret

000000008000577e <sys_read>:
{
    8000577e:	7179                	addi	sp,sp,-48
    80005780:	f406                	sd	ra,40(sp)
    80005782:	f022                	sd	s0,32(sp)
    80005784:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005786:	fd840593          	addi	a1,s0,-40
    8000578a:	4505                	li	a0,1
    8000578c:	ffffe097          	auipc	ra,0xffffe
    80005790:	86e080e7          	jalr	-1938(ra) # 80002ffa <argaddr>
  argint(2, &n);
    80005794:	fe440593          	addi	a1,s0,-28
    80005798:	4509                	li	a0,2
    8000579a:	ffffe097          	auipc	ra,0xffffe
    8000579e:	840080e7          	jalr	-1984(ra) # 80002fda <argint>
  if(argfd(0, 0, &f) < 0)
    800057a2:	fe840613          	addi	a2,s0,-24
    800057a6:	4581                	li	a1,0
    800057a8:	4501                	li	a0,0
    800057aa:	00000097          	auipc	ra,0x0
    800057ae:	d5a080e7          	jalr	-678(ra) # 80005504 <argfd>
    800057b2:	87aa                	mv	a5,a0
    return -1;
    800057b4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800057b6:	0007cc63          	bltz	a5,800057ce <sys_read+0x50>
  return fileread(f, p, n);
    800057ba:	fe442603          	lw	a2,-28(s0)
    800057be:	fd843583          	ld	a1,-40(s0)
    800057c2:	fe843503          	ld	a0,-24(s0)
    800057c6:	fffff097          	auipc	ra,0xfffff
    800057ca:	43e080e7          	jalr	1086(ra) # 80004c04 <fileread>
}
    800057ce:	70a2                	ld	ra,40(sp)
    800057d0:	7402                	ld	s0,32(sp)
    800057d2:	6145                	addi	sp,sp,48
    800057d4:	8082                	ret

00000000800057d6 <sys_write>:
{
    800057d6:	7179                	addi	sp,sp,-48
    800057d8:	f406                	sd	ra,40(sp)
    800057da:	f022                	sd	s0,32(sp)
    800057dc:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800057de:	fd840593          	addi	a1,s0,-40
    800057e2:	4505                	li	a0,1
    800057e4:	ffffe097          	auipc	ra,0xffffe
    800057e8:	816080e7          	jalr	-2026(ra) # 80002ffa <argaddr>
  argint(2, &n);
    800057ec:	fe440593          	addi	a1,s0,-28
    800057f0:	4509                	li	a0,2
    800057f2:	ffffd097          	auipc	ra,0xffffd
    800057f6:	7e8080e7          	jalr	2024(ra) # 80002fda <argint>
  if(argfd(0, 0, &f) < 0)
    800057fa:	fe840613          	addi	a2,s0,-24
    800057fe:	4581                	li	a1,0
    80005800:	4501                	li	a0,0
    80005802:	00000097          	auipc	ra,0x0
    80005806:	d02080e7          	jalr	-766(ra) # 80005504 <argfd>
    8000580a:	87aa                	mv	a5,a0
    return -1;
    8000580c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000580e:	0007cc63          	bltz	a5,80005826 <sys_write+0x50>
  return filewrite(f, p, n);
    80005812:	fe442603          	lw	a2,-28(s0)
    80005816:	fd843583          	ld	a1,-40(s0)
    8000581a:	fe843503          	ld	a0,-24(s0)
    8000581e:	fffff097          	auipc	ra,0xfffff
    80005822:	4a8080e7          	jalr	1192(ra) # 80004cc6 <filewrite>
}
    80005826:	70a2                	ld	ra,40(sp)
    80005828:	7402                	ld	s0,32(sp)
    8000582a:	6145                	addi	sp,sp,48
    8000582c:	8082                	ret

000000008000582e <sys_close>:
{
    8000582e:	1101                	addi	sp,sp,-32
    80005830:	ec06                	sd	ra,24(sp)
    80005832:	e822                	sd	s0,16(sp)
    80005834:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005836:	fe040613          	addi	a2,s0,-32
    8000583a:	fec40593          	addi	a1,s0,-20
    8000583e:	4501                	li	a0,0
    80005840:	00000097          	auipc	ra,0x0
    80005844:	cc4080e7          	jalr	-828(ra) # 80005504 <argfd>
    return -1;
    80005848:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000584a:	02054563          	bltz	a0,80005874 <sys_close+0x46>
  myproc()->ofile[fd] = 0;
    8000584e:	ffffc097          	auipc	ra,0xffffc
    80005852:	17c080e7          	jalr	380(ra) # 800019ca <myproc>
    80005856:	fec42783          	lw	a5,-20(s0)
    8000585a:	02278793          	addi	a5,a5,34
    8000585e:	078e                	slli	a5,a5,0x3
    80005860:	97aa                	add	a5,a5,a0
    80005862:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    80005866:	fe043503          	ld	a0,-32(s0)
    8000586a:	fffff097          	auipc	ra,0xfffff
    8000586e:	260080e7          	jalr	608(ra) # 80004aca <fileclose>
  return 0;
    80005872:	4781                	li	a5,0
}
    80005874:	853e                	mv	a0,a5
    80005876:	60e2                	ld	ra,24(sp)
    80005878:	6442                	ld	s0,16(sp)
    8000587a:	6105                	addi	sp,sp,32
    8000587c:	8082                	ret

000000008000587e <sys_fstat>:
{
    8000587e:	1101                	addi	sp,sp,-32
    80005880:	ec06                	sd	ra,24(sp)
    80005882:	e822                	sd	s0,16(sp)
    80005884:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005886:	fe040593          	addi	a1,s0,-32
    8000588a:	4505                	li	a0,1
    8000588c:	ffffd097          	auipc	ra,0xffffd
    80005890:	76e080e7          	jalr	1902(ra) # 80002ffa <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005894:	fe840613          	addi	a2,s0,-24
    80005898:	4581                	li	a1,0
    8000589a:	4501                	li	a0,0
    8000589c:	00000097          	auipc	ra,0x0
    800058a0:	c68080e7          	jalr	-920(ra) # 80005504 <argfd>
    800058a4:	87aa                	mv	a5,a0
    return -1;
    800058a6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800058a8:	0007ca63          	bltz	a5,800058bc <sys_fstat+0x3e>
  return filestat(f, st);
    800058ac:	fe043583          	ld	a1,-32(s0)
    800058b0:	fe843503          	ld	a0,-24(s0)
    800058b4:	fffff097          	auipc	ra,0xfffff
    800058b8:	2de080e7          	jalr	734(ra) # 80004b92 <filestat>
}
    800058bc:	60e2                	ld	ra,24(sp)
    800058be:	6442                	ld	s0,16(sp)
    800058c0:	6105                	addi	sp,sp,32
    800058c2:	8082                	ret

00000000800058c4 <sys_link>:
{
    800058c4:	7169                	addi	sp,sp,-304
    800058c6:	f606                	sd	ra,296(sp)
    800058c8:	f222                	sd	s0,288(sp)
    800058ca:	ee26                	sd	s1,280(sp)
    800058cc:	ea4a                	sd	s2,272(sp)
    800058ce:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058d0:	08000613          	li	a2,128
    800058d4:	ed040593          	addi	a1,s0,-304
    800058d8:	4501                	li	a0,0
    800058da:	ffffd097          	auipc	ra,0xffffd
    800058de:	740080e7          	jalr	1856(ra) # 8000301a <argstr>
    return -1;
    800058e2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058e4:	10054e63          	bltz	a0,80005a00 <sys_link+0x13c>
    800058e8:	08000613          	li	a2,128
    800058ec:	f5040593          	addi	a1,s0,-176
    800058f0:	4505                	li	a0,1
    800058f2:	ffffd097          	auipc	ra,0xffffd
    800058f6:	728080e7          	jalr	1832(ra) # 8000301a <argstr>
    return -1;
    800058fa:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058fc:	10054263          	bltz	a0,80005a00 <sys_link+0x13c>
  begin_op();
    80005900:	fffff097          	auipc	ra,0xfffff
    80005904:	cfe080e7          	jalr	-770(ra) # 800045fe <begin_op>
  if((ip = namei(old)) == 0){
    80005908:	ed040513          	addi	a0,s0,-304
    8000590c:	fffff097          	auipc	ra,0xfffff
    80005910:	ad6080e7          	jalr	-1322(ra) # 800043e2 <namei>
    80005914:	84aa                	mv	s1,a0
    80005916:	c551                	beqz	a0,800059a2 <sys_link+0xde>
  ilock(ip);
    80005918:	ffffe097          	auipc	ra,0xffffe
    8000591c:	324080e7          	jalr	804(ra) # 80003c3c <ilock>
  if(ip->type == T_DIR){
    80005920:	04449703          	lh	a4,68(s1)
    80005924:	4785                	li	a5,1
    80005926:	08f70463          	beq	a4,a5,800059ae <sys_link+0xea>
  ip->nlink++;
    8000592a:	04a4d783          	lhu	a5,74(s1)
    8000592e:	2785                	addiw	a5,a5,1
    80005930:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005934:	8526                	mv	a0,s1
    80005936:	ffffe097          	auipc	ra,0xffffe
    8000593a:	23c080e7          	jalr	572(ra) # 80003b72 <iupdate>
  iunlock(ip);
    8000593e:	8526                	mv	a0,s1
    80005940:	ffffe097          	auipc	ra,0xffffe
    80005944:	3be080e7          	jalr	958(ra) # 80003cfe <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005948:	fd040593          	addi	a1,s0,-48
    8000594c:	f5040513          	addi	a0,s0,-176
    80005950:	fffff097          	auipc	ra,0xfffff
    80005954:	ab0080e7          	jalr	-1360(ra) # 80004400 <nameiparent>
    80005958:	892a                	mv	s2,a0
    8000595a:	c935                	beqz	a0,800059ce <sys_link+0x10a>
  ilock(dp);
    8000595c:	ffffe097          	auipc	ra,0xffffe
    80005960:	2e0080e7          	jalr	736(ra) # 80003c3c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005964:	00092703          	lw	a4,0(s2)
    80005968:	409c                	lw	a5,0(s1)
    8000596a:	04f71d63          	bne	a4,a5,800059c4 <sys_link+0x100>
    8000596e:	40d0                	lw	a2,4(s1)
    80005970:	fd040593          	addi	a1,s0,-48
    80005974:	854a                	mv	a0,s2
    80005976:	fffff097          	auipc	ra,0xfffff
    8000597a:	9ba080e7          	jalr	-1606(ra) # 80004330 <dirlink>
    8000597e:	04054363          	bltz	a0,800059c4 <sys_link+0x100>
  iunlockput(dp);
    80005982:	854a                	mv	a0,s2
    80005984:	ffffe097          	auipc	ra,0xffffe
    80005988:	51a080e7          	jalr	1306(ra) # 80003e9e <iunlockput>
  iput(ip);
    8000598c:	8526                	mv	a0,s1
    8000598e:	ffffe097          	auipc	ra,0xffffe
    80005992:	468080e7          	jalr	1128(ra) # 80003df6 <iput>
  end_op();
    80005996:	fffff097          	auipc	ra,0xfffff
    8000599a:	ce8080e7          	jalr	-792(ra) # 8000467e <end_op>
  return 0;
    8000599e:	4781                	li	a5,0
    800059a0:	a085                	j	80005a00 <sys_link+0x13c>
    end_op();
    800059a2:	fffff097          	auipc	ra,0xfffff
    800059a6:	cdc080e7          	jalr	-804(ra) # 8000467e <end_op>
    return -1;
    800059aa:	57fd                	li	a5,-1
    800059ac:	a891                	j	80005a00 <sys_link+0x13c>
    iunlockput(ip);
    800059ae:	8526                	mv	a0,s1
    800059b0:	ffffe097          	auipc	ra,0xffffe
    800059b4:	4ee080e7          	jalr	1262(ra) # 80003e9e <iunlockput>
    end_op();
    800059b8:	fffff097          	auipc	ra,0xfffff
    800059bc:	cc6080e7          	jalr	-826(ra) # 8000467e <end_op>
    return -1;
    800059c0:	57fd                	li	a5,-1
    800059c2:	a83d                	j	80005a00 <sys_link+0x13c>
    iunlockput(dp);
    800059c4:	854a                	mv	a0,s2
    800059c6:	ffffe097          	auipc	ra,0xffffe
    800059ca:	4d8080e7          	jalr	1240(ra) # 80003e9e <iunlockput>
  ilock(ip);
    800059ce:	8526                	mv	a0,s1
    800059d0:	ffffe097          	auipc	ra,0xffffe
    800059d4:	26c080e7          	jalr	620(ra) # 80003c3c <ilock>
  ip->nlink--;
    800059d8:	04a4d783          	lhu	a5,74(s1)
    800059dc:	37fd                	addiw	a5,a5,-1
    800059de:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800059e2:	8526                	mv	a0,s1
    800059e4:	ffffe097          	auipc	ra,0xffffe
    800059e8:	18e080e7          	jalr	398(ra) # 80003b72 <iupdate>
  iunlockput(ip);
    800059ec:	8526                	mv	a0,s1
    800059ee:	ffffe097          	auipc	ra,0xffffe
    800059f2:	4b0080e7          	jalr	1200(ra) # 80003e9e <iunlockput>
  end_op();
    800059f6:	fffff097          	auipc	ra,0xfffff
    800059fa:	c88080e7          	jalr	-888(ra) # 8000467e <end_op>
  return -1;
    800059fe:	57fd                	li	a5,-1
}
    80005a00:	853e                	mv	a0,a5
    80005a02:	70b2                	ld	ra,296(sp)
    80005a04:	7412                	ld	s0,288(sp)
    80005a06:	64f2                	ld	s1,280(sp)
    80005a08:	6952                	ld	s2,272(sp)
    80005a0a:	6155                	addi	sp,sp,304
    80005a0c:	8082                	ret

0000000080005a0e <sys_unlink>:
{
    80005a0e:	7151                	addi	sp,sp,-240
    80005a10:	f586                	sd	ra,232(sp)
    80005a12:	f1a2                	sd	s0,224(sp)
    80005a14:	eda6                	sd	s1,216(sp)
    80005a16:	e9ca                	sd	s2,208(sp)
    80005a18:	e5ce                	sd	s3,200(sp)
    80005a1a:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005a1c:	08000613          	li	a2,128
    80005a20:	f3040593          	addi	a1,s0,-208
    80005a24:	4501                	li	a0,0
    80005a26:	ffffd097          	auipc	ra,0xffffd
    80005a2a:	5f4080e7          	jalr	1524(ra) # 8000301a <argstr>
    80005a2e:	18054163          	bltz	a0,80005bb0 <sys_unlink+0x1a2>
  begin_op();
    80005a32:	fffff097          	auipc	ra,0xfffff
    80005a36:	bcc080e7          	jalr	-1076(ra) # 800045fe <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005a3a:	fb040593          	addi	a1,s0,-80
    80005a3e:	f3040513          	addi	a0,s0,-208
    80005a42:	fffff097          	auipc	ra,0xfffff
    80005a46:	9be080e7          	jalr	-1602(ra) # 80004400 <nameiparent>
    80005a4a:	84aa                	mv	s1,a0
    80005a4c:	c979                	beqz	a0,80005b22 <sys_unlink+0x114>
  ilock(dp);
    80005a4e:	ffffe097          	auipc	ra,0xffffe
    80005a52:	1ee080e7          	jalr	494(ra) # 80003c3c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005a56:	00003597          	auipc	a1,0x3
    80005a5a:	ce258593          	addi	a1,a1,-798 # 80008738 <syscalls+0x2c0>
    80005a5e:	fb040513          	addi	a0,s0,-80
    80005a62:	ffffe097          	auipc	ra,0xffffe
    80005a66:	6a4080e7          	jalr	1700(ra) # 80004106 <namecmp>
    80005a6a:	14050a63          	beqz	a0,80005bbe <sys_unlink+0x1b0>
    80005a6e:	00003597          	auipc	a1,0x3
    80005a72:	cd258593          	addi	a1,a1,-814 # 80008740 <syscalls+0x2c8>
    80005a76:	fb040513          	addi	a0,s0,-80
    80005a7a:	ffffe097          	auipc	ra,0xffffe
    80005a7e:	68c080e7          	jalr	1676(ra) # 80004106 <namecmp>
    80005a82:	12050e63          	beqz	a0,80005bbe <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005a86:	f2c40613          	addi	a2,s0,-212
    80005a8a:	fb040593          	addi	a1,s0,-80
    80005a8e:	8526                	mv	a0,s1
    80005a90:	ffffe097          	auipc	ra,0xffffe
    80005a94:	690080e7          	jalr	1680(ra) # 80004120 <dirlookup>
    80005a98:	892a                	mv	s2,a0
    80005a9a:	12050263          	beqz	a0,80005bbe <sys_unlink+0x1b0>
  ilock(ip);
    80005a9e:	ffffe097          	auipc	ra,0xffffe
    80005aa2:	19e080e7          	jalr	414(ra) # 80003c3c <ilock>
  if(ip->nlink < 1)
    80005aa6:	04a91783          	lh	a5,74(s2)
    80005aaa:	08f05263          	blez	a5,80005b2e <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005aae:	04491703          	lh	a4,68(s2)
    80005ab2:	4785                	li	a5,1
    80005ab4:	08f70563          	beq	a4,a5,80005b3e <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005ab8:	4641                	li	a2,16
    80005aba:	4581                	li	a1,0
    80005abc:	fc040513          	addi	a0,s0,-64
    80005ac0:	ffffb097          	auipc	ra,0xffffb
    80005ac4:	212080e7          	jalr	530(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005ac8:	4741                	li	a4,16
    80005aca:	f2c42683          	lw	a3,-212(s0)
    80005ace:	fc040613          	addi	a2,s0,-64
    80005ad2:	4581                	li	a1,0
    80005ad4:	8526                	mv	a0,s1
    80005ad6:	ffffe097          	auipc	ra,0xffffe
    80005ada:	512080e7          	jalr	1298(ra) # 80003fe8 <writei>
    80005ade:	47c1                	li	a5,16
    80005ae0:	0af51563          	bne	a0,a5,80005b8a <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005ae4:	04491703          	lh	a4,68(s2)
    80005ae8:	4785                	li	a5,1
    80005aea:	0af70863          	beq	a4,a5,80005b9a <sys_unlink+0x18c>
  iunlockput(dp);
    80005aee:	8526                	mv	a0,s1
    80005af0:	ffffe097          	auipc	ra,0xffffe
    80005af4:	3ae080e7          	jalr	942(ra) # 80003e9e <iunlockput>
  ip->nlink--;
    80005af8:	04a95783          	lhu	a5,74(s2)
    80005afc:	37fd                	addiw	a5,a5,-1
    80005afe:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005b02:	854a                	mv	a0,s2
    80005b04:	ffffe097          	auipc	ra,0xffffe
    80005b08:	06e080e7          	jalr	110(ra) # 80003b72 <iupdate>
  iunlockput(ip);
    80005b0c:	854a                	mv	a0,s2
    80005b0e:	ffffe097          	auipc	ra,0xffffe
    80005b12:	390080e7          	jalr	912(ra) # 80003e9e <iunlockput>
  end_op();
    80005b16:	fffff097          	auipc	ra,0xfffff
    80005b1a:	b68080e7          	jalr	-1176(ra) # 8000467e <end_op>
  return 0;
    80005b1e:	4501                	li	a0,0
    80005b20:	a84d                	j	80005bd2 <sys_unlink+0x1c4>
    end_op();
    80005b22:	fffff097          	auipc	ra,0xfffff
    80005b26:	b5c080e7          	jalr	-1188(ra) # 8000467e <end_op>
    return -1;
    80005b2a:	557d                	li	a0,-1
    80005b2c:	a05d                	j	80005bd2 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005b2e:	00003517          	auipc	a0,0x3
    80005b32:	c1a50513          	addi	a0,a0,-998 # 80008748 <syscalls+0x2d0>
    80005b36:	ffffb097          	auipc	ra,0xffffb
    80005b3a:	a08080e7          	jalr	-1528(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b3e:	04c92703          	lw	a4,76(s2)
    80005b42:	02000793          	li	a5,32
    80005b46:	f6e7f9e3          	bgeu	a5,a4,80005ab8 <sys_unlink+0xaa>
    80005b4a:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b4e:	4741                	li	a4,16
    80005b50:	86ce                	mv	a3,s3
    80005b52:	f1840613          	addi	a2,s0,-232
    80005b56:	4581                	li	a1,0
    80005b58:	854a                	mv	a0,s2
    80005b5a:	ffffe097          	auipc	ra,0xffffe
    80005b5e:	396080e7          	jalr	918(ra) # 80003ef0 <readi>
    80005b62:	47c1                	li	a5,16
    80005b64:	00f51b63          	bne	a0,a5,80005b7a <sys_unlink+0x16c>
    if(de.inum != 0)
    80005b68:	f1845783          	lhu	a5,-232(s0)
    80005b6c:	e7a1                	bnez	a5,80005bb4 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b6e:	29c1                	addiw	s3,s3,16
    80005b70:	04c92783          	lw	a5,76(s2)
    80005b74:	fcf9ede3          	bltu	s3,a5,80005b4e <sys_unlink+0x140>
    80005b78:	b781                	j	80005ab8 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005b7a:	00003517          	auipc	a0,0x3
    80005b7e:	be650513          	addi	a0,a0,-1050 # 80008760 <syscalls+0x2e8>
    80005b82:	ffffb097          	auipc	ra,0xffffb
    80005b86:	9bc080e7          	jalr	-1604(ra) # 8000053e <panic>
    panic("unlink: writei");
    80005b8a:	00003517          	auipc	a0,0x3
    80005b8e:	bee50513          	addi	a0,a0,-1042 # 80008778 <syscalls+0x300>
    80005b92:	ffffb097          	auipc	ra,0xffffb
    80005b96:	9ac080e7          	jalr	-1620(ra) # 8000053e <panic>
    dp->nlink--;
    80005b9a:	04a4d783          	lhu	a5,74(s1)
    80005b9e:	37fd                	addiw	a5,a5,-1
    80005ba0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005ba4:	8526                	mv	a0,s1
    80005ba6:	ffffe097          	auipc	ra,0xffffe
    80005baa:	fcc080e7          	jalr	-52(ra) # 80003b72 <iupdate>
    80005bae:	b781                	j	80005aee <sys_unlink+0xe0>
    return -1;
    80005bb0:	557d                	li	a0,-1
    80005bb2:	a005                	j	80005bd2 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005bb4:	854a                	mv	a0,s2
    80005bb6:	ffffe097          	auipc	ra,0xffffe
    80005bba:	2e8080e7          	jalr	744(ra) # 80003e9e <iunlockput>
  iunlockput(dp);
    80005bbe:	8526                	mv	a0,s1
    80005bc0:	ffffe097          	auipc	ra,0xffffe
    80005bc4:	2de080e7          	jalr	734(ra) # 80003e9e <iunlockput>
  end_op();
    80005bc8:	fffff097          	auipc	ra,0xfffff
    80005bcc:	ab6080e7          	jalr	-1354(ra) # 8000467e <end_op>
  return -1;
    80005bd0:	557d                	li	a0,-1
}
    80005bd2:	70ae                	ld	ra,232(sp)
    80005bd4:	740e                	ld	s0,224(sp)
    80005bd6:	64ee                	ld	s1,216(sp)
    80005bd8:	694e                	ld	s2,208(sp)
    80005bda:	69ae                	ld	s3,200(sp)
    80005bdc:	616d                	addi	sp,sp,240
    80005bde:	8082                	ret

0000000080005be0 <sys_open>:

uint64
sys_open(void)
{
    80005be0:	7131                	addi	sp,sp,-192
    80005be2:	fd06                	sd	ra,184(sp)
    80005be4:	f922                	sd	s0,176(sp)
    80005be6:	f526                	sd	s1,168(sp)
    80005be8:	f14a                	sd	s2,160(sp)
    80005bea:	ed4e                	sd	s3,152(sp)
    80005bec:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005bee:	f4c40593          	addi	a1,s0,-180
    80005bf2:	4505                	li	a0,1
    80005bf4:	ffffd097          	auipc	ra,0xffffd
    80005bf8:	3e6080e7          	jalr	998(ra) # 80002fda <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005bfc:	08000613          	li	a2,128
    80005c00:	f5040593          	addi	a1,s0,-176
    80005c04:	4501                	li	a0,0
    80005c06:	ffffd097          	auipc	ra,0xffffd
    80005c0a:	414080e7          	jalr	1044(ra) # 8000301a <argstr>
    80005c0e:	87aa                	mv	a5,a0
    return -1;
    80005c10:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005c12:	0a07c963          	bltz	a5,80005cc4 <sys_open+0xe4>

  begin_op();
    80005c16:	fffff097          	auipc	ra,0xfffff
    80005c1a:	9e8080e7          	jalr	-1560(ra) # 800045fe <begin_op>

  if(omode & O_CREATE){
    80005c1e:	f4c42783          	lw	a5,-180(s0)
    80005c22:	2007f793          	andi	a5,a5,512
    80005c26:	cfc5                	beqz	a5,80005cde <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005c28:	4681                	li	a3,0
    80005c2a:	4601                	li	a2,0
    80005c2c:	4589                	li	a1,2
    80005c2e:	f5040513          	addi	a0,s0,-176
    80005c32:	00000097          	auipc	ra,0x0
    80005c36:	974080e7          	jalr	-1676(ra) # 800055a6 <create>
    80005c3a:	84aa                	mv	s1,a0
    if(ip == 0){
    80005c3c:	c959                	beqz	a0,80005cd2 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005c3e:	04449703          	lh	a4,68(s1)
    80005c42:	478d                	li	a5,3
    80005c44:	00f71763          	bne	a4,a5,80005c52 <sys_open+0x72>
    80005c48:	0464d703          	lhu	a4,70(s1)
    80005c4c:	47a5                	li	a5,9
    80005c4e:	0ce7ed63          	bltu	a5,a4,80005d28 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005c52:	fffff097          	auipc	ra,0xfffff
    80005c56:	dbc080e7          	jalr	-580(ra) # 80004a0e <filealloc>
    80005c5a:	89aa                	mv	s3,a0
    80005c5c:	10050363          	beqz	a0,80005d62 <sys_open+0x182>
    80005c60:	00000097          	auipc	ra,0x0
    80005c64:	904080e7          	jalr	-1788(ra) # 80005564 <fdalloc>
    80005c68:	892a                	mv	s2,a0
    80005c6a:	0e054763          	bltz	a0,80005d58 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005c6e:	04449703          	lh	a4,68(s1)
    80005c72:	478d                	li	a5,3
    80005c74:	0cf70563          	beq	a4,a5,80005d3e <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005c78:	4789                	li	a5,2
    80005c7a:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005c7e:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005c82:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005c86:	f4c42783          	lw	a5,-180(s0)
    80005c8a:	0017c713          	xori	a4,a5,1
    80005c8e:	8b05                	andi	a4,a4,1
    80005c90:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005c94:	0037f713          	andi	a4,a5,3
    80005c98:	00e03733          	snez	a4,a4
    80005c9c:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005ca0:	4007f793          	andi	a5,a5,1024
    80005ca4:	c791                	beqz	a5,80005cb0 <sys_open+0xd0>
    80005ca6:	04449703          	lh	a4,68(s1)
    80005caa:	4789                	li	a5,2
    80005cac:	0af70063          	beq	a4,a5,80005d4c <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005cb0:	8526                	mv	a0,s1
    80005cb2:	ffffe097          	auipc	ra,0xffffe
    80005cb6:	04c080e7          	jalr	76(ra) # 80003cfe <iunlock>
  end_op();
    80005cba:	fffff097          	auipc	ra,0xfffff
    80005cbe:	9c4080e7          	jalr	-1596(ra) # 8000467e <end_op>

  return fd;
    80005cc2:	854a                	mv	a0,s2
}
    80005cc4:	70ea                	ld	ra,184(sp)
    80005cc6:	744a                	ld	s0,176(sp)
    80005cc8:	74aa                	ld	s1,168(sp)
    80005cca:	790a                	ld	s2,160(sp)
    80005ccc:	69ea                	ld	s3,152(sp)
    80005cce:	6129                	addi	sp,sp,192
    80005cd0:	8082                	ret
      end_op();
    80005cd2:	fffff097          	auipc	ra,0xfffff
    80005cd6:	9ac080e7          	jalr	-1620(ra) # 8000467e <end_op>
      return -1;
    80005cda:	557d                	li	a0,-1
    80005cdc:	b7e5                	j	80005cc4 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005cde:	f5040513          	addi	a0,s0,-176
    80005ce2:	ffffe097          	auipc	ra,0xffffe
    80005ce6:	700080e7          	jalr	1792(ra) # 800043e2 <namei>
    80005cea:	84aa                	mv	s1,a0
    80005cec:	c905                	beqz	a0,80005d1c <sys_open+0x13c>
    ilock(ip);
    80005cee:	ffffe097          	auipc	ra,0xffffe
    80005cf2:	f4e080e7          	jalr	-178(ra) # 80003c3c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005cf6:	04449703          	lh	a4,68(s1)
    80005cfa:	4785                	li	a5,1
    80005cfc:	f4f711e3          	bne	a4,a5,80005c3e <sys_open+0x5e>
    80005d00:	f4c42783          	lw	a5,-180(s0)
    80005d04:	d7b9                	beqz	a5,80005c52 <sys_open+0x72>
      iunlockput(ip);
    80005d06:	8526                	mv	a0,s1
    80005d08:	ffffe097          	auipc	ra,0xffffe
    80005d0c:	196080e7          	jalr	406(ra) # 80003e9e <iunlockput>
      end_op();
    80005d10:	fffff097          	auipc	ra,0xfffff
    80005d14:	96e080e7          	jalr	-1682(ra) # 8000467e <end_op>
      return -1;
    80005d18:	557d                	li	a0,-1
    80005d1a:	b76d                	j	80005cc4 <sys_open+0xe4>
      end_op();
    80005d1c:	fffff097          	auipc	ra,0xfffff
    80005d20:	962080e7          	jalr	-1694(ra) # 8000467e <end_op>
      return -1;
    80005d24:	557d                	li	a0,-1
    80005d26:	bf79                	j	80005cc4 <sys_open+0xe4>
    iunlockput(ip);
    80005d28:	8526                	mv	a0,s1
    80005d2a:	ffffe097          	auipc	ra,0xffffe
    80005d2e:	174080e7          	jalr	372(ra) # 80003e9e <iunlockput>
    end_op();
    80005d32:	fffff097          	auipc	ra,0xfffff
    80005d36:	94c080e7          	jalr	-1716(ra) # 8000467e <end_op>
    return -1;
    80005d3a:	557d                	li	a0,-1
    80005d3c:	b761                	j	80005cc4 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005d3e:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005d42:	04649783          	lh	a5,70(s1)
    80005d46:	02f99223          	sh	a5,36(s3)
    80005d4a:	bf25                	j	80005c82 <sys_open+0xa2>
    itrunc(ip);
    80005d4c:	8526                	mv	a0,s1
    80005d4e:	ffffe097          	auipc	ra,0xffffe
    80005d52:	ffc080e7          	jalr	-4(ra) # 80003d4a <itrunc>
    80005d56:	bfa9                	j	80005cb0 <sys_open+0xd0>
      fileclose(f);
    80005d58:	854e                	mv	a0,s3
    80005d5a:	fffff097          	auipc	ra,0xfffff
    80005d5e:	d70080e7          	jalr	-656(ra) # 80004aca <fileclose>
    iunlockput(ip);
    80005d62:	8526                	mv	a0,s1
    80005d64:	ffffe097          	auipc	ra,0xffffe
    80005d68:	13a080e7          	jalr	314(ra) # 80003e9e <iunlockput>
    end_op();
    80005d6c:	fffff097          	auipc	ra,0xfffff
    80005d70:	912080e7          	jalr	-1774(ra) # 8000467e <end_op>
    return -1;
    80005d74:	557d                	li	a0,-1
    80005d76:	b7b9                	j	80005cc4 <sys_open+0xe4>

0000000080005d78 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005d78:	7175                	addi	sp,sp,-144
    80005d7a:	e506                	sd	ra,136(sp)
    80005d7c:	e122                	sd	s0,128(sp)
    80005d7e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005d80:	fffff097          	auipc	ra,0xfffff
    80005d84:	87e080e7          	jalr	-1922(ra) # 800045fe <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005d88:	08000613          	li	a2,128
    80005d8c:	f7040593          	addi	a1,s0,-144
    80005d90:	4501                	li	a0,0
    80005d92:	ffffd097          	auipc	ra,0xffffd
    80005d96:	288080e7          	jalr	648(ra) # 8000301a <argstr>
    80005d9a:	02054963          	bltz	a0,80005dcc <sys_mkdir+0x54>
    80005d9e:	4681                	li	a3,0
    80005da0:	4601                	li	a2,0
    80005da2:	4585                	li	a1,1
    80005da4:	f7040513          	addi	a0,s0,-144
    80005da8:	fffff097          	auipc	ra,0xfffff
    80005dac:	7fe080e7          	jalr	2046(ra) # 800055a6 <create>
    80005db0:	cd11                	beqz	a0,80005dcc <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005db2:	ffffe097          	auipc	ra,0xffffe
    80005db6:	0ec080e7          	jalr	236(ra) # 80003e9e <iunlockput>
  end_op();
    80005dba:	fffff097          	auipc	ra,0xfffff
    80005dbe:	8c4080e7          	jalr	-1852(ra) # 8000467e <end_op>
  return 0;
    80005dc2:	4501                	li	a0,0
}
    80005dc4:	60aa                	ld	ra,136(sp)
    80005dc6:	640a                	ld	s0,128(sp)
    80005dc8:	6149                	addi	sp,sp,144
    80005dca:	8082                	ret
    end_op();
    80005dcc:	fffff097          	auipc	ra,0xfffff
    80005dd0:	8b2080e7          	jalr	-1870(ra) # 8000467e <end_op>
    return -1;
    80005dd4:	557d                	li	a0,-1
    80005dd6:	b7fd                	j	80005dc4 <sys_mkdir+0x4c>

0000000080005dd8 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005dd8:	7135                	addi	sp,sp,-160
    80005dda:	ed06                	sd	ra,152(sp)
    80005ddc:	e922                	sd	s0,144(sp)
    80005dde:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005de0:	fffff097          	auipc	ra,0xfffff
    80005de4:	81e080e7          	jalr	-2018(ra) # 800045fe <begin_op>
  argint(1, &major);
    80005de8:	f6c40593          	addi	a1,s0,-148
    80005dec:	4505                	li	a0,1
    80005dee:	ffffd097          	auipc	ra,0xffffd
    80005df2:	1ec080e7          	jalr	492(ra) # 80002fda <argint>
  argint(2, &minor);
    80005df6:	f6840593          	addi	a1,s0,-152
    80005dfa:	4509                	li	a0,2
    80005dfc:	ffffd097          	auipc	ra,0xffffd
    80005e00:	1de080e7          	jalr	478(ra) # 80002fda <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e04:	08000613          	li	a2,128
    80005e08:	f7040593          	addi	a1,s0,-144
    80005e0c:	4501                	li	a0,0
    80005e0e:	ffffd097          	auipc	ra,0xffffd
    80005e12:	20c080e7          	jalr	524(ra) # 8000301a <argstr>
    80005e16:	02054b63          	bltz	a0,80005e4c <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005e1a:	f6841683          	lh	a3,-152(s0)
    80005e1e:	f6c41603          	lh	a2,-148(s0)
    80005e22:	458d                	li	a1,3
    80005e24:	f7040513          	addi	a0,s0,-144
    80005e28:	fffff097          	auipc	ra,0xfffff
    80005e2c:	77e080e7          	jalr	1918(ra) # 800055a6 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e30:	cd11                	beqz	a0,80005e4c <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005e32:	ffffe097          	auipc	ra,0xffffe
    80005e36:	06c080e7          	jalr	108(ra) # 80003e9e <iunlockput>
  end_op();
    80005e3a:	fffff097          	auipc	ra,0xfffff
    80005e3e:	844080e7          	jalr	-1980(ra) # 8000467e <end_op>
  return 0;
    80005e42:	4501                	li	a0,0
}
    80005e44:	60ea                	ld	ra,152(sp)
    80005e46:	644a                	ld	s0,144(sp)
    80005e48:	610d                	addi	sp,sp,160
    80005e4a:	8082                	ret
    end_op();
    80005e4c:	fffff097          	auipc	ra,0xfffff
    80005e50:	832080e7          	jalr	-1998(ra) # 8000467e <end_op>
    return -1;
    80005e54:	557d                	li	a0,-1
    80005e56:	b7fd                	j	80005e44 <sys_mknod+0x6c>

0000000080005e58 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005e58:	7135                	addi	sp,sp,-160
    80005e5a:	ed06                	sd	ra,152(sp)
    80005e5c:	e922                	sd	s0,144(sp)
    80005e5e:	e526                	sd	s1,136(sp)
    80005e60:	e14a                	sd	s2,128(sp)
    80005e62:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005e64:	ffffc097          	auipc	ra,0xffffc
    80005e68:	b66080e7          	jalr	-1178(ra) # 800019ca <myproc>
    80005e6c:	892a                	mv	s2,a0
  
  begin_op();
    80005e6e:	ffffe097          	auipc	ra,0xffffe
    80005e72:	790080e7          	jalr	1936(ra) # 800045fe <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005e76:	08000613          	li	a2,128
    80005e7a:	f6040593          	addi	a1,s0,-160
    80005e7e:	4501                	li	a0,0
    80005e80:	ffffd097          	auipc	ra,0xffffd
    80005e84:	19a080e7          	jalr	410(ra) # 8000301a <argstr>
    80005e88:	04054b63          	bltz	a0,80005ede <sys_chdir+0x86>
    80005e8c:	f6040513          	addi	a0,s0,-160
    80005e90:	ffffe097          	auipc	ra,0xffffe
    80005e94:	552080e7          	jalr	1362(ra) # 800043e2 <namei>
    80005e98:	84aa                	mv	s1,a0
    80005e9a:	c131                	beqz	a0,80005ede <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005e9c:	ffffe097          	auipc	ra,0xffffe
    80005ea0:	da0080e7          	jalr	-608(ra) # 80003c3c <ilock>
  if(ip->type != T_DIR){
    80005ea4:	04449703          	lh	a4,68(s1)
    80005ea8:	4785                	li	a5,1
    80005eaa:	04f71063          	bne	a4,a5,80005eea <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005eae:	8526                	mv	a0,s1
    80005eb0:	ffffe097          	auipc	ra,0xffffe
    80005eb4:	e4e080e7          	jalr	-434(ra) # 80003cfe <iunlock>
  iput(p->cwd);
    80005eb8:	19893503          	ld	a0,408(s2)
    80005ebc:	ffffe097          	auipc	ra,0xffffe
    80005ec0:	f3a080e7          	jalr	-198(ra) # 80003df6 <iput>
  end_op();
    80005ec4:	ffffe097          	auipc	ra,0xffffe
    80005ec8:	7ba080e7          	jalr	1978(ra) # 8000467e <end_op>
  p->cwd = ip;
    80005ecc:	18993c23          	sd	s1,408(s2)
  return 0;
    80005ed0:	4501                	li	a0,0
}
    80005ed2:	60ea                	ld	ra,152(sp)
    80005ed4:	644a                	ld	s0,144(sp)
    80005ed6:	64aa                	ld	s1,136(sp)
    80005ed8:	690a                	ld	s2,128(sp)
    80005eda:	610d                	addi	sp,sp,160
    80005edc:	8082                	ret
    end_op();
    80005ede:	ffffe097          	auipc	ra,0xffffe
    80005ee2:	7a0080e7          	jalr	1952(ra) # 8000467e <end_op>
    return -1;
    80005ee6:	557d                	li	a0,-1
    80005ee8:	b7ed                	j	80005ed2 <sys_chdir+0x7a>
    iunlockput(ip);
    80005eea:	8526                	mv	a0,s1
    80005eec:	ffffe097          	auipc	ra,0xffffe
    80005ef0:	fb2080e7          	jalr	-78(ra) # 80003e9e <iunlockput>
    end_op();
    80005ef4:	ffffe097          	auipc	ra,0xffffe
    80005ef8:	78a080e7          	jalr	1930(ra) # 8000467e <end_op>
    return -1;
    80005efc:	557d                	li	a0,-1
    80005efe:	bfd1                	j	80005ed2 <sys_chdir+0x7a>

0000000080005f00 <sys_exec>:

uint64
sys_exec(void)
{
    80005f00:	7145                	addi	sp,sp,-464
    80005f02:	e786                	sd	ra,456(sp)
    80005f04:	e3a2                	sd	s0,448(sp)
    80005f06:	ff26                	sd	s1,440(sp)
    80005f08:	fb4a                	sd	s2,432(sp)
    80005f0a:	f74e                	sd	s3,424(sp)
    80005f0c:	f352                	sd	s4,416(sp)
    80005f0e:	ef56                	sd	s5,408(sp)
    80005f10:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005f12:	e3840593          	addi	a1,s0,-456
    80005f16:	4505                	li	a0,1
    80005f18:	ffffd097          	auipc	ra,0xffffd
    80005f1c:	0e2080e7          	jalr	226(ra) # 80002ffa <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005f20:	08000613          	li	a2,128
    80005f24:	f4040593          	addi	a1,s0,-192
    80005f28:	4501                	li	a0,0
    80005f2a:	ffffd097          	auipc	ra,0xffffd
    80005f2e:	0f0080e7          	jalr	240(ra) # 8000301a <argstr>
    80005f32:	87aa                	mv	a5,a0
    return -1;
    80005f34:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005f36:	0c07c263          	bltz	a5,80005ffa <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005f3a:	10000613          	li	a2,256
    80005f3e:	4581                	li	a1,0
    80005f40:	e4040513          	addi	a0,s0,-448
    80005f44:	ffffb097          	auipc	ra,0xffffb
    80005f48:	d8e080e7          	jalr	-626(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005f4c:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005f50:	89a6                	mv	s3,s1
    80005f52:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005f54:	02000a13          	li	s4,32
    80005f58:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005f5c:	00391793          	slli	a5,s2,0x3
    80005f60:	e3040593          	addi	a1,s0,-464
    80005f64:	e3843503          	ld	a0,-456(s0)
    80005f68:	953e                	add	a0,a0,a5
    80005f6a:	ffffd097          	auipc	ra,0xffffd
    80005f6e:	fd2080e7          	jalr	-46(ra) # 80002f3c <fetchaddr>
    80005f72:	02054a63          	bltz	a0,80005fa6 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005f76:	e3043783          	ld	a5,-464(s0)
    80005f7a:	c3b9                	beqz	a5,80005fc0 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005f7c:	ffffb097          	auipc	ra,0xffffb
    80005f80:	b6a080e7          	jalr	-1174(ra) # 80000ae6 <kalloc>
    80005f84:	85aa                	mv	a1,a0
    80005f86:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005f8a:	cd11                	beqz	a0,80005fa6 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005f8c:	6605                	lui	a2,0x1
    80005f8e:	e3043503          	ld	a0,-464(s0)
    80005f92:	ffffd097          	auipc	ra,0xffffd
    80005f96:	ffc080e7          	jalr	-4(ra) # 80002f8e <fetchstr>
    80005f9a:	00054663          	bltz	a0,80005fa6 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005f9e:	0905                	addi	s2,s2,1
    80005fa0:	09a1                	addi	s3,s3,8
    80005fa2:	fb491be3          	bne	s2,s4,80005f58 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fa6:	10048913          	addi	s2,s1,256
    80005faa:	6088                	ld	a0,0(s1)
    80005fac:	c531                	beqz	a0,80005ff8 <sys_exec+0xf8>
    kfree(argv[i]);
    80005fae:	ffffb097          	auipc	ra,0xffffb
    80005fb2:	a3c080e7          	jalr	-1476(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fb6:	04a1                	addi	s1,s1,8
    80005fb8:	ff2499e3          	bne	s1,s2,80005faa <sys_exec+0xaa>
  return -1;
    80005fbc:	557d                	li	a0,-1
    80005fbe:	a835                	j	80005ffa <sys_exec+0xfa>
      argv[i] = 0;
    80005fc0:	0a8e                	slli	s5,s5,0x3
    80005fc2:	fc040793          	addi	a5,s0,-64
    80005fc6:	9abe                	add	s5,s5,a5
    80005fc8:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005fcc:	e4040593          	addi	a1,s0,-448
    80005fd0:	f4040513          	addi	a0,s0,-192
    80005fd4:	fffff097          	auipc	ra,0xfffff
    80005fd8:	170080e7          	jalr	368(ra) # 80005144 <exec>
    80005fdc:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fde:	10048993          	addi	s3,s1,256
    80005fe2:	6088                	ld	a0,0(s1)
    80005fe4:	c901                	beqz	a0,80005ff4 <sys_exec+0xf4>
    kfree(argv[i]);
    80005fe6:	ffffb097          	auipc	ra,0xffffb
    80005fea:	a04080e7          	jalr	-1532(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fee:	04a1                	addi	s1,s1,8
    80005ff0:	ff3499e3          	bne	s1,s3,80005fe2 <sys_exec+0xe2>
  return ret;
    80005ff4:	854a                	mv	a0,s2
    80005ff6:	a011                	j	80005ffa <sys_exec+0xfa>
  return -1;
    80005ff8:	557d                	li	a0,-1
}
    80005ffa:	60be                	ld	ra,456(sp)
    80005ffc:	641e                	ld	s0,448(sp)
    80005ffe:	74fa                	ld	s1,440(sp)
    80006000:	795a                	ld	s2,432(sp)
    80006002:	79ba                	ld	s3,424(sp)
    80006004:	7a1a                	ld	s4,416(sp)
    80006006:	6afa                	ld	s5,408(sp)
    80006008:	6179                	addi	sp,sp,464
    8000600a:	8082                	ret

000000008000600c <sys_pipe>:

uint64
sys_pipe(void)
{
    8000600c:	7139                	addi	sp,sp,-64
    8000600e:	fc06                	sd	ra,56(sp)
    80006010:	f822                	sd	s0,48(sp)
    80006012:	f426                	sd	s1,40(sp)
    80006014:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006016:	ffffc097          	auipc	ra,0xffffc
    8000601a:	9b4080e7          	jalr	-1612(ra) # 800019ca <myproc>
    8000601e:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80006020:	fd840593          	addi	a1,s0,-40
    80006024:	4501                	li	a0,0
    80006026:	ffffd097          	auipc	ra,0xffffd
    8000602a:	fd4080e7          	jalr	-44(ra) # 80002ffa <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000602e:	fc840593          	addi	a1,s0,-56
    80006032:	fd040513          	addi	a0,s0,-48
    80006036:	fffff097          	auipc	ra,0xfffff
    8000603a:	dc4080e7          	jalr	-572(ra) # 80004dfa <pipealloc>
    return -1;
    8000603e:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006040:	0c054763          	bltz	a0,8000610e <sys_pipe+0x102>
  fd0 = -1;
    80006044:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006048:	fd043503          	ld	a0,-48(s0)
    8000604c:	fffff097          	auipc	ra,0xfffff
    80006050:	518080e7          	jalr	1304(ra) # 80005564 <fdalloc>
    80006054:	fca42223          	sw	a0,-60(s0)
    80006058:	08054e63          	bltz	a0,800060f4 <sys_pipe+0xe8>
    8000605c:	fc843503          	ld	a0,-56(s0)
    80006060:	fffff097          	auipc	ra,0xfffff
    80006064:	504080e7          	jalr	1284(ra) # 80005564 <fdalloc>
    80006068:	fca42023          	sw	a0,-64(s0)
    8000606c:	06054a63          	bltz	a0,800060e0 <sys_pipe+0xd4>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006070:	4691                	li	a3,4
    80006072:	fc440613          	addi	a2,s0,-60
    80006076:	fd843583          	ld	a1,-40(s0)
    8000607a:	6cc8                	ld	a0,152(s1)
    8000607c:	ffffb097          	auipc	ra,0xffffb
    80006080:	5ec080e7          	jalr	1516(ra) # 80001668 <copyout>
    80006084:	02054063          	bltz	a0,800060a4 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006088:	4691                	li	a3,4
    8000608a:	fc040613          	addi	a2,s0,-64
    8000608e:	fd843583          	ld	a1,-40(s0)
    80006092:	0591                	addi	a1,a1,4
    80006094:	6cc8                	ld	a0,152(s1)
    80006096:	ffffb097          	auipc	ra,0xffffb
    8000609a:	5d2080e7          	jalr	1490(ra) # 80001668 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000609e:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800060a0:	06055763          	bgez	a0,8000610e <sys_pipe+0x102>
    p->ofile[fd0] = 0;
    800060a4:	fc442783          	lw	a5,-60(s0)
    800060a8:	02278793          	addi	a5,a5,34
    800060ac:	078e                	slli	a5,a5,0x3
    800060ae:	97a6                	add	a5,a5,s1
    800060b0:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    800060b4:	fc042503          	lw	a0,-64(s0)
    800060b8:	02250513          	addi	a0,a0,34
    800060bc:	050e                	slli	a0,a0,0x3
    800060be:	94aa                	add	s1,s1,a0
    800060c0:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    800060c4:	fd043503          	ld	a0,-48(s0)
    800060c8:	fffff097          	auipc	ra,0xfffff
    800060cc:	a02080e7          	jalr	-1534(ra) # 80004aca <fileclose>
    fileclose(wf);
    800060d0:	fc843503          	ld	a0,-56(s0)
    800060d4:	fffff097          	auipc	ra,0xfffff
    800060d8:	9f6080e7          	jalr	-1546(ra) # 80004aca <fileclose>
    return -1;
    800060dc:	57fd                	li	a5,-1
    800060de:	a805                	j	8000610e <sys_pipe+0x102>
    if(fd0 >= 0)
    800060e0:	fc442783          	lw	a5,-60(s0)
    800060e4:	0007c863          	bltz	a5,800060f4 <sys_pipe+0xe8>
      p->ofile[fd0] = 0;
    800060e8:	02278793          	addi	a5,a5,34
    800060ec:	078e                	slli	a5,a5,0x3
    800060ee:	94be                	add	s1,s1,a5
    800060f0:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    800060f4:	fd043503          	ld	a0,-48(s0)
    800060f8:	fffff097          	auipc	ra,0xfffff
    800060fc:	9d2080e7          	jalr	-1582(ra) # 80004aca <fileclose>
    fileclose(wf);
    80006100:	fc843503          	ld	a0,-56(s0)
    80006104:	fffff097          	auipc	ra,0xfffff
    80006108:	9c6080e7          	jalr	-1594(ra) # 80004aca <fileclose>
    return -1;
    8000610c:	57fd                	li	a5,-1
}
    8000610e:	853e                	mv	a0,a5
    80006110:	70e2                	ld	ra,56(sp)
    80006112:	7442                	ld	s0,48(sp)
    80006114:	74a2                	ld	s1,40(sp)
    80006116:	6121                	addi	sp,sp,64
    80006118:	8082                	ret
    8000611a:	0000                	unimp
    8000611c:	0000                	unimp
	...

0000000080006120 <kernelvec>:
    80006120:	7111                	addi	sp,sp,-256
    80006122:	e006                	sd	ra,0(sp)
    80006124:	e40a                	sd	sp,8(sp)
    80006126:	e80e                	sd	gp,16(sp)
    80006128:	ec12                	sd	tp,24(sp)
    8000612a:	f016                	sd	t0,32(sp)
    8000612c:	f41a                	sd	t1,40(sp)
    8000612e:	f81e                	sd	t2,48(sp)
    80006130:	fc22                	sd	s0,56(sp)
    80006132:	e0a6                	sd	s1,64(sp)
    80006134:	e4aa                	sd	a0,72(sp)
    80006136:	e8ae                	sd	a1,80(sp)
    80006138:	ecb2                	sd	a2,88(sp)
    8000613a:	f0b6                	sd	a3,96(sp)
    8000613c:	f4ba                	sd	a4,104(sp)
    8000613e:	f8be                	sd	a5,112(sp)
    80006140:	fcc2                	sd	a6,120(sp)
    80006142:	e146                	sd	a7,128(sp)
    80006144:	e54a                	sd	s2,136(sp)
    80006146:	e94e                	sd	s3,144(sp)
    80006148:	ed52                	sd	s4,152(sp)
    8000614a:	f156                	sd	s5,160(sp)
    8000614c:	f55a                	sd	s6,168(sp)
    8000614e:	f95e                	sd	s7,176(sp)
    80006150:	fd62                	sd	s8,184(sp)
    80006152:	e1e6                	sd	s9,192(sp)
    80006154:	e5ea                	sd	s10,200(sp)
    80006156:	e9ee                	sd	s11,208(sp)
    80006158:	edf2                	sd	t3,216(sp)
    8000615a:	f1f6                	sd	t4,224(sp)
    8000615c:	f5fa                	sd	t5,232(sp)
    8000615e:	f9fe                	sd	t6,240(sp)
    80006160:	c8ffc0ef          	jal	ra,80002dee <kerneltrap>
    80006164:	6082                	ld	ra,0(sp)
    80006166:	6122                	ld	sp,8(sp)
    80006168:	61c2                	ld	gp,16(sp)
    8000616a:	7282                	ld	t0,32(sp)
    8000616c:	7322                	ld	t1,40(sp)
    8000616e:	73c2                	ld	t2,48(sp)
    80006170:	7462                	ld	s0,56(sp)
    80006172:	6486                	ld	s1,64(sp)
    80006174:	6526                	ld	a0,72(sp)
    80006176:	65c6                	ld	a1,80(sp)
    80006178:	6666                	ld	a2,88(sp)
    8000617a:	7686                	ld	a3,96(sp)
    8000617c:	7726                	ld	a4,104(sp)
    8000617e:	77c6                	ld	a5,112(sp)
    80006180:	7866                	ld	a6,120(sp)
    80006182:	688a                	ld	a7,128(sp)
    80006184:	692a                	ld	s2,136(sp)
    80006186:	69ca                	ld	s3,144(sp)
    80006188:	6a6a                	ld	s4,152(sp)
    8000618a:	7a8a                	ld	s5,160(sp)
    8000618c:	7b2a                	ld	s6,168(sp)
    8000618e:	7bca                	ld	s7,176(sp)
    80006190:	7c6a                	ld	s8,184(sp)
    80006192:	6c8e                	ld	s9,192(sp)
    80006194:	6d2e                	ld	s10,200(sp)
    80006196:	6dce                	ld	s11,208(sp)
    80006198:	6e6e                	ld	t3,216(sp)
    8000619a:	7e8e                	ld	t4,224(sp)
    8000619c:	7f2e                	ld	t5,232(sp)
    8000619e:	7fce                	ld	t6,240(sp)
    800061a0:	6111                	addi	sp,sp,256
    800061a2:	10200073          	sret
    800061a6:	00000013          	nop
    800061aa:	00000013          	nop
    800061ae:	0001                	nop

00000000800061b0 <timervec>:
    800061b0:	34051573          	csrrw	a0,mscratch,a0
    800061b4:	e10c                	sd	a1,0(a0)
    800061b6:	e510                	sd	a2,8(a0)
    800061b8:	e914                	sd	a3,16(a0)
    800061ba:	6d0c                	ld	a1,24(a0)
    800061bc:	7110                	ld	a2,32(a0)
    800061be:	6194                	ld	a3,0(a1)
    800061c0:	96b2                	add	a3,a3,a2
    800061c2:	e194                	sd	a3,0(a1)
    800061c4:	4589                	li	a1,2
    800061c6:	14459073          	csrw	sip,a1
    800061ca:	6914                	ld	a3,16(a0)
    800061cc:	6510                	ld	a2,8(a0)
    800061ce:	610c                	ld	a1,0(a0)
    800061d0:	34051573          	csrrw	a0,mscratch,a0
    800061d4:	30200073          	mret
	...

00000000800061da <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800061da:	1141                	addi	sp,sp,-16
    800061dc:	e422                	sd	s0,8(sp)
    800061de:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800061e0:	0c0007b7          	lui	a5,0xc000
    800061e4:	4705                	li	a4,1
    800061e6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800061e8:	c3d8                	sw	a4,4(a5)
}
    800061ea:	6422                	ld	s0,8(sp)
    800061ec:	0141                	addi	sp,sp,16
    800061ee:	8082                	ret

00000000800061f0 <plicinithart>:

void
plicinithart(void)
{
    800061f0:	1141                	addi	sp,sp,-16
    800061f2:	e406                	sd	ra,8(sp)
    800061f4:	e022                	sd	s0,0(sp)
    800061f6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800061f8:	ffffb097          	auipc	ra,0xffffb
    800061fc:	7a6080e7          	jalr	1958(ra) # 8000199e <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006200:	0085171b          	slliw	a4,a0,0x8
    80006204:	0c0027b7          	lui	a5,0xc002
    80006208:	97ba                	add	a5,a5,a4
    8000620a:	40200713          	li	a4,1026
    8000620e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006212:	00d5151b          	slliw	a0,a0,0xd
    80006216:	0c2017b7          	lui	a5,0xc201
    8000621a:	953e                	add	a0,a0,a5
    8000621c:	00052023          	sw	zero,0(a0)
}
    80006220:	60a2                	ld	ra,8(sp)
    80006222:	6402                	ld	s0,0(sp)
    80006224:	0141                	addi	sp,sp,16
    80006226:	8082                	ret

0000000080006228 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006228:	1141                	addi	sp,sp,-16
    8000622a:	e406                	sd	ra,8(sp)
    8000622c:	e022                	sd	s0,0(sp)
    8000622e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006230:	ffffb097          	auipc	ra,0xffffb
    80006234:	76e080e7          	jalr	1902(ra) # 8000199e <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006238:	00d5179b          	slliw	a5,a0,0xd
    8000623c:	0c201537          	lui	a0,0xc201
    80006240:	953e                	add	a0,a0,a5
  return irq;
}
    80006242:	4148                	lw	a0,4(a0)
    80006244:	60a2                	ld	ra,8(sp)
    80006246:	6402                	ld	s0,0(sp)
    80006248:	0141                	addi	sp,sp,16
    8000624a:	8082                	ret

000000008000624c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000624c:	1101                	addi	sp,sp,-32
    8000624e:	ec06                	sd	ra,24(sp)
    80006250:	e822                	sd	s0,16(sp)
    80006252:	e426                	sd	s1,8(sp)
    80006254:	1000                	addi	s0,sp,32
    80006256:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006258:	ffffb097          	auipc	ra,0xffffb
    8000625c:	746080e7          	jalr	1862(ra) # 8000199e <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006260:	00d5151b          	slliw	a0,a0,0xd
    80006264:	0c2017b7          	lui	a5,0xc201
    80006268:	97aa                	add	a5,a5,a0
    8000626a:	c3c4                	sw	s1,4(a5)
}
    8000626c:	60e2                	ld	ra,24(sp)
    8000626e:	6442                	ld	s0,16(sp)
    80006270:	64a2                	ld	s1,8(sp)
    80006272:	6105                	addi	sp,sp,32
    80006274:	8082                	ret

0000000080006276 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006276:	1141                	addi	sp,sp,-16
    80006278:	e406                	sd	ra,8(sp)
    8000627a:	e022                	sd	s0,0(sp)
    8000627c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000627e:	479d                	li	a5,7
    80006280:	04a7cc63          	blt	a5,a0,800062d8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006284:	0001d797          	auipc	a5,0x1d
    80006288:	bec78793          	addi	a5,a5,-1044 # 80022e70 <disk>
    8000628c:	97aa                	add	a5,a5,a0
    8000628e:	0187c783          	lbu	a5,24(a5)
    80006292:	ebb9                	bnez	a5,800062e8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006294:	00451613          	slli	a2,a0,0x4
    80006298:	0001d797          	auipc	a5,0x1d
    8000629c:	bd878793          	addi	a5,a5,-1064 # 80022e70 <disk>
    800062a0:	6394                	ld	a3,0(a5)
    800062a2:	96b2                	add	a3,a3,a2
    800062a4:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800062a8:	6398                	ld	a4,0(a5)
    800062aa:	9732                	add	a4,a4,a2
    800062ac:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800062b0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800062b4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800062b8:	953e                	add	a0,a0,a5
    800062ba:	4785                	li	a5,1
    800062bc:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    800062c0:	0001d517          	auipc	a0,0x1d
    800062c4:	bc850513          	addi	a0,a0,-1080 # 80022e88 <disk+0x18>
    800062c8:	ffffc097          	auipc	ra,0xffffc
    800062cc:	16c080e7          	jalr	364(ra) # 80002434 <wakeup>
}
    800062d0:	60a2                	ld	ra,8(sp)
    800062d2:	6402                	ld	s0,0(sp)
    800062d4:	0141                	addi	sp,sp,16
    800062d6:	8082                	ret
    panic("free_desc 1");
    800062d8:	00002517          	auipc	a0,0x2
    800062dc:	4b050513          	addi	a0,a0,1200 # 80008788 <syscalls+0x310>
    800062e0:	ffffa097          	auipc	ra,0xffffa
    800062e4:	25e080e7          	jalr	606(ra) # 8000053e <panic>
    panic("free_desc 2");
    800062e8:	00002517          	auipc	a0,0x2
    800062ec:	4b050513          	addi	a0,a0,1200 # 80008798 <syscalls+0x320>
    800062f0:	ffffa097          	auipc	ra,0xffffa
    800062f4:	24e080e7          	jalr	590(ra) # 8000053e <panic>

00000000800062f8 <virtio_disk_init>:
{
    800062f8:	1101                	addi	sp,sp,-32
    800062fa:	ec06                	sd	ra,24(sp)
    800062fc:	e822                	sd	s0,16(sp)
    800062fe:	e426                	sd	s1,8(sp)
    80006300:	e04a                	sd	s2,0(sp)
    80006302:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006304:	00002597          	auipc	a1,0x2
    80006308:	4a458593          	addi	a1,a1,1188 # 800087a8 <syscalls+0x330>
    8000630c:	0001d517          	auipc	a0,0x1d
    80006310:	c8c50513          	addi	a0,a0,-884 # 80022f98 <disk+0x128>
    80006314:	ffffb097          	auipc	ra,0xffffb
    80006318:	832080e7          	jalr	-1998(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000631c:	100017b7          	lui	a5,0x10001
    80006320:	4398                	lw	a4,0(a5)
    80006322:	2701                	sext.w	a4,a4
    80006324:	747277b7          	lui	a5,0x74727
    80006328:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000632c:	14f71c63          	bne	a4,a5,80006484 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006330:	100017b7          	lui	a5,0x10001
    80006334:	43dc                	lw	a5,4(a5)
    80006336:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006338:	4709                	li	a4,2
    8000633a:	14e79563          	bne	a5,a4,80006484 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000633e:	100017b7          	lui	a5,0x10001
    80006342:	479c                	lw	a5,8(a5)
    80006344:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006346:	12e79f63          	bne	a5,a4,80006484 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000634a:	100017b7          	lui	a5,0x10001
    8000634e:	47d8                	lw	a4,12(a5)
    80006350:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006352:	554d47b7          	lui	a5,0x554d4
    80006356:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000635a:	12f71563          	bne	a4,a5,80006484 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000635e:	100017b7          	lui	a5,0x10001
    80006362:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006366:	4705                	li	a4,1
    80006368:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000636a:	470d                	li	a4,3
    8000636c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000636e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006370:	c7ffe737          	lui	a4,0xc7ffe
    80006374:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb7af>
    80006378:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000637a:	2701                	sext.w	a4,a4
    8000637c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000637e:	472d                	li	a4,11
    80006380:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006382:	5bbc                	lw	a5,112(a5)
    80006384:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006388:	8ba1                	andi	a5,a5,8
    8000638a:	10078563          	beqz	a5,80006494 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000638e:	100017b7          	lui	a5,0x10001
    80006392:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006396:	43fc                	lw	a5,68(a5)
    80006398:	2781                	sext.w	a5,a5
    8000639a:	10079563          	bnez	a5,800064a4 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000639e:	100017b7          	lui	a5,0x10001
    800063a2:	5bdc                	lw	a5,52(a5)
    800063a4:	2781                	sext.w	a5,a5
  if(max == 0)
    800063a6:	10078763          	beqz	a5,800064b4 <virtio_disk_init+0x1bc>
  if(max < NUM)
    800063aa:	471d                	li	a4,7
    800063ac:	10f77c63          	bgeu	a4,a5,800064c4 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    800063b0:	ffffa097          	auipc	ra,0xffffa
    800063b4:	736080e7          	jalr	1846(ra) # 80000ae6 <kalloc>
    800063b8:	0001d497          	auipc	s1,0x1d
    800063bc:	ab848493          	addi	s1,s1,-1352 # 80022e70 <disk>
    800063c0:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800063c2:	ffffa097          	auipc	ra,0xffffa
    800063c6:	724080e7          	jalr	1828(ra) # 80000ae6 <kalloc>
    800063ca:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800063cc:	ffffa097          	auipc	ra,0xffffa
    800063d0:	71a080e7          	jalr	1818(ra) # 80000ae6 <kalloc>
    800063d4:	87aa                	mv	a5,a0
    800063d6:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800063d8:	6088                	ld	a0,0(s1)
    800063da:	cd6d                	beqz	a0,800064d4 <virtio_disk_init+0x1dc>
    800063dc:	0001d717          	auipc	a4,0x1d
    800063e0:	a9c73703          	ld	a4,-1380(a4) # 80022e78 <disk+0x8>
    800063e4:	cb65                	beqz	a4,800064d4 <virtio_disk_init+0x1dc>
    800063e6:	c7fd                	beqz	a5,800064d4 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    800063e8:	6605                	lui	a2,0x1
    800063ea:	4581                	li	a1,0
    800063ec:	ffffb097          	auipc	ra,0xffffb
    800063f0:	8e6080e7          	jalr	-1818(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    800063f4:	0001d497          	auipc	s1,0x1d
    800063f8:	a7c48493          	addi	s1,s1,-1412 # 80022e70 <disk>
    800063fc:	6605                	lui	a2,0x1
    800063fe:	4581                	li	a1,0
    80006400:	6488                	ld	a0,8(s1)
    80006402:	ffffb097          	auipc	ra,0xffffb
    80006406:	8d0080e7          	jalr	-1840(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    8000640a:	6605                	lui	a2,0x1
    8000640c:	4581                	li	a1,0
    8000640e:	6888                	ld	a0,16(s1)
    80006410:	ffffb097          	auipc	ra,0xffffb
    80006414:	8c2080e7          	jalr	-1854(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006418:	100017b7          	lui	a5,0x10001
    8000641c:	4721                	li	a4,8
    8000641e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006420:	4098                	lw	a4,0(s1)
    80006422:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006426:	40d8                	lw	a4,4(s1)
    80006428:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000642c:	6498                	ld	a4,8(s1)
    8000642e:	0007069b          	sext.w	a3,a4
    80006432:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006436:	9701                	srai	a4,a4,0x20
    80006438:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000643c:	6898                	ld	a4,16(s1)
    8000643e:	0007069b          	sext.w	a3,a4
    80006442:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006446:	9701                	srai	a4,a4,0x20
    80006448:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000644c:	4705                	li	a4,1
    8000644e:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80006450:	00e48c23          	sb	a4,24(s1)
    80006454:	00e48ca3          	sb	a4,25(s1)
    80006458:	00e48d23          	sb	a4,26(s1)
    8000645c:	00e48da3          	sb	a4,27(s1)
    80006460:	00e48e23          	sb	a4,28(s1)
    80006464:	00e48ea3          	sb	a4,29(s1)
    80006468:	00e48f23          	sb	a4,30(s1)
    8000646c:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006470:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006474:	0727a823          	sw	s2,112(a5)
}
    80006478:	60e2                	ld	ra,24(sp)
    8000647a:	6442                	ld	s0,16(sp)
    8000647c:	64a2                	ld	s1,8(sp)
    8000647e:	6902                	ld	s2,0(sp)
    80006480:	6105                	addi	sp,sp,32
    80006482:	8082                	ret
    panic("could not find virtio disk");
    80006484:	00002517          	auipc	a0,0x2
    80006488:	33450513          	addi	a0,a0,820 # 800087b8 <syscalls+0x340>
    8000648c:	ffffa097          	auipc	ra,0xffffa
    80006490:	0b2080e7          	jalr	178(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    80006494:	00002517          	auipc	a0,0x2
    80006498:	34450513          	addi	a0,a0,836 # 800087d8 <syscalls+0x360>
    8000649c:	ffffa097          	auipc	ra,0xffffa
    800064a0:	0a2080e7          	jalr	162(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    800064a4:	00002517          	auipc	a0,0x2
    800064a8:	35450513          	addi	a0,a0,852 # 800087f8 <syscalls+0x380>
    800064ac:	ffffa097          	auipc	ra,0xffffa
    800064b0:	092080e7          	jalr	146(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    800064b4:	00002517          	auipc	a0,0x2
    800064b8:	36450513          	addi	a0,a0,868 # 80008818 <syscalls+0x3a0>
    800064bc:	ffffa097          	auipc	ra,0xffffa
    800064c0:	082080e7          	jalr	130(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    800064c4:	00002517          	auipc	a0,0x2
    800064c8:	37450513          	addi	a0,a0,884 # 80008838 <syscalls+0x3c0>
    800064cc:	ffffa097          	auipc	ra,0xffffa
    800064d0:	072080e7          	jalr	114(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    800064d4:	00002517          	auipc	a0,0x2
    800064d8:	38450513          	addi	a0,a0,900 # 80008858 <syscalls+0x3e0>
    800064dc:	ffffa097          	auipc	ra,0xffffa
    800064e0:	062080e7          	jalr	98(ra) # 8000053e <panic>

00000000800064e4 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800064e4:	7119                	addi	sp,sp,-128
    800064e6:	fc86                	sd	ra,120(sp)
    800064e8:	f8a2                	sd	s0,112(sp)
    800064ea:	f4a6                	sd	s1,104(sp)
    800064ec:	f0ca                	sd	s2,96(sp)
    800064ee:	ecce                	sd	s3,88(sp)
    800064f0:	e8d2                	sd	s4,80(sp)
    800064f2:	e4d6                	sd	s5,72(sp)
    800064f4:	e0da                	sd	s6,64(sp)
    800064f6:	fc5e                	sd	s7,56(sp)
    800064f8:	f862                	sd	s8,48(sp)
    800064fa:	f466                	sd	s9,40(sp)
    800064fc:	f06a                	sd	s10,32(sp)
    800064fe:	ec6e                	sd	s11,24(sp)
    80006500:	0100                	addi	s0,sp,128
    80006502:	8aaa                	mv	s5,a0
    80006504:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006506:	00c52d03          	lw	s10,12(a0)
    8000650a:	001d1d1b          	slliw	s10,s10,0x1
    8000650e:	1d02                	slli	s10,s10,0x20
    80006510:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006514:	0001d517          	auipc	a0,0x1d
    80006518:	a8450513          	addi	a0,a0,-1404 # 80022f98 <disk+0x128>
    8000651c:	ffffa097          	auipc	ra,0xffffa
    80006520:	6ba080e7          	jalr	1722(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80006524:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006526:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006528:	0001db97          	auipc	s7,0x1d
    8000652c:	948b8b93          	addi	s7,s7,-1720 # 80022e70 <disk>
  for(int i = 0; i < 3; i++){
    80006530:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006532:	0001dc97          	auipc	s9,0x1d
    80006536:	a66c8c93          	addi	s9,s9,-1434 # 80022f98 <disk+0x128>
    8000653a:	a08d                	j	8000659c <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000653c:	00fb8733          	add	a4,s7,a5
    80006540:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006544:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006546:	0207c563          	bltz	a5,80006570 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000654a:	2905                	addiw	s2,s2,1
    8000654c:	0611                	addi	a2,a2,4
    8000654e:	05690c63          	beq	s2,s6,800065a6 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006552:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006554:	0001d717          	auipc	a4,0x1d
    80006558:	91c70713          	addi	a4,a4,-1764 # 80022e70 <disk>
    8000655c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000655e:	01874683          	lbu	a3,24(a4)
    80006562:	fee9                	bnez	a3,8000653c <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006564:	2785                	addiw	a5,a5,1
    80006566:	0705                	addi	a4,a4,1
    80006568:	fe979be3          	bne	a5,s1,8000655e <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000656c:	57fd                	li	a5,-1
    8000656e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006570:	01205d63          	blez	s2,8000658a <virtio_disk_rw+0xa6>
    80006574:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006576:	000a2503          	lw	a0,0(s4)
    8000657a:	00000097          	auipc	ra,0x0
    8000657e:	cfc080e7          	jalr	-772(ra) # 80006276 <free_desc>
      for(int j = 0; j < i; j++)
    80006582:	2d85                	addiw	s11,s11,1
    80006584:	0a11                	addi	s4,s4,4
    80006586:	ffb918e3          	bne	s2,s11,80006576 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000658a:	85e6                	mv	a1,s9
    8000658c:	0001d517          	auipc	a0,0x1d
    80006590:	8fc50513          	addi	a0,a0,-1796 # 80022e88 <disk+0x18>
    80006594:	ffffc097          	auipc	ra,0xffffc
    80006598:	db8080e7          	jalr	-584(ra) # 8000234c <sleep>
  for(int i = 0; i < 3; i++){
    8000659c:	f8040a13          	addi	s4,s0,-128
{
    800065a0:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800065a2:	894e                	mv	s2,s3
    800065a4:	b77d                	j	80006552 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800065a6:	f8042583          	lw	a1,-128(s0)
    800065aa:	00a58793          	addi	a5,a1,10
    800065ae:	0792                	slli	a5,a5,0x4

  if(write)
    800065b0:	0001d617          	auipc	a2,0x1d
    800065b4:	8c060613          	addi	a2,a2,-1856 # 80022e70 <disk>
    800065b8:	00f60733          	add	a4,a2,a5
    800065bc:	018036b3          	snez	a3,s8
    800065c0:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800065c2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800065c6:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800065ca:	f6078693          	addi	a3,a5,-160
    800065ce:	6218                	ld	a4,0(a2)
    800065d0:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800065d2:	00878513          	addi	a0,a5,8
    800065d6:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    800065d8:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800065da:	6208                	ld	a0,0(a2)
    800065dc:	96aa                	add	a3,a3,a0
    800065de:	4741                	li	a4,16
    800065e0:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800065e2:	4705                	li	a4,1
    800065e4:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    800065e8:	f8442703          	lw	a4,-124(s0)
    800065ec:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800065f0:	0712                	slli	a4,a4,0x4
    800065f2:	953a                	add	a0,a0,a4
    800065f4:	058a8693          	addi	a3,s5,88
    800065f8:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    800065fa:	6208                	ld	a0,0(a2)
    800065fc:	972a                	add	a4,a4,a0
    800065fe:	40000693          	li	a3,1024
    80006602:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006604:	001c3c13          	seqz	s8,s8
    80006608:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000660a:	001c6c13          	ori	s8,s8,1
    8000660e:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006612:	f8842603          	lw	a2,-120(s0)
    80006616:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000661a:	0001d697          	auipc	a3,0x1d
    8000661e:	85668693          	addi	a3,a3,-1962 # 80022e70 <disk>
    80006622:	00258713          	addi	a4,a1,2
    80006626:	0712                	slli	a4,a4,0x4
    80006628:	9736                	add	a4,a4,a3
    8000662a:	587d                	li	a6,-1
    8000662c:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006630:	0612                	slli	a2,a2,0x4
    80006632:	9532                	add	a0,a0,a2
    80006634:	f9078793          	addi	a5,a5,-112
    80006638:	97b6                	add	a5,a5,a3
    8000663a:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    8000663c:	629c                	ld	a5,0(a3)
    8000663e:	97b2                	add	a5,a5,a2
    80006640:	4605                	li	a2,1
    80006642:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006644:	4509                	li	a0,2
    80006646:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    8000664a:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000664e:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006652:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006656:	6698                	ld	a4,8(a3)
    80006658:	00275783          	lhu	a5,2(a4)
    8000665c:	8b9d                	andi	a5,a5,7
    8000665e:	0786                	slli	a5,a5,0x1
    80006660:	97ba                	add	a5,a5,a4
    80006662:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006666:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000666a:	6698                	ld	a4,8(a3)
    8000666c:	00275783          	lhu	a5,2(a4)
    80006670:	2785                	addiw	a5,a5,1
    80006672:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006676:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000667a:	100017b7          	lui	a5,0x10001
    8000667e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006682:	004aa783          	lw	a5,4(s5)
    80006686:	02c79163          	bne	a5,a2,800066a8 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    8000668a:	0001d917          	auipc	s2,0x1d
    8000668e:	90e90913          	addi	s2,s2,-1778 # 80022f98 <disk+0x128>
  while(b->disk == 1) {
    80006692:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006694:	85ca                	mv	a1,s2
    80006696:	8556                	mv	a0,s5
    80006698:	ffffc097          	auipc	ra,0xffffc
    8000669c:	cb4080e7          	jalr	-844(ra) # 8000234c <sleep>
  while(b->disk == 1) {
    800066a0:	004aa783          	lw	a5,4(s5)
    800066a4:	fe9788e3          	beq	a5,s1,80006694 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800066a8:	f8042903          	lw	s2,-128(s0)
    800066ac:	00290793          	addi	a5,s2,2
    800066b0:	00479713          	slli	a4,a5,0x4
    800066b4:	0001c797          	auipc	a5,0x1c
    800066b8:	7bc78793          	addi	a5,a5,1980 # 80022e70 <disk>
    800066bc:	97ba                	add	a5,a5,a4
    800066be:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800066c2:	0001c997          	auipc	s3,0x1c
    800066c6:	7ae98993          	addi	s3,s3,1966 # 80022e70 <disk>
    800066ca:	00491713          	slli	a4,s2,0x4
    800066ce:	0009b783          	ld	a5,0(s3)
    800066d2:	97ba                	add	a5,a5,a4
    800066d4:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800066d8:	854a                	mv	a0,s2
    800066da:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800066de:	00000097          	auipc	ra,0x0
    800066e2:	b98080e7          	jalr	-1128(ra) # 80006276 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800066e6:	8885                	andi	s1,s1,1
    800066e8:	f0ed                	bnez	s1,800066ca <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800066ea:	0001d517          	auipc	a0,0x1d
    800066ee:	8ae50513          	addi	a0,a0,-1874 # 80022f98 <disk+0x128>
    800066f2:	ffffa097          	auipc	ra,0xffffa
    800066f6:	598080e7          	jalr	1432(ra) # 80000c8a <release>
}
    800066fa:	70e6                	ld	ra,120(sp)
    800066fc:	7446                	ld	s0,112(sp)
    800066fe:	74a6                	ld	s1,104(sp)
    80006700:	7906                	ld	s2,96(sp)
    80006702:	69e6                	ld	s3,88(sp)
    80006704:	6a46                	ld	s4,80(sp)
    80006706:	6aa6                	ld	s5,72(sp)
    80006708:	6b06                	ld	s6,64(sp)
    8000670a:	7be2                	ld	s7,56(sp)
    8000670c:	7c42                	ld	s8,48(sp)
    8000670e:	7ca2                	ld	s9,40(sp)
    80006710:	7d02                	ld	s10,32(sp)
    80006712:	6de2                	ld	s11,24(sp)
    80006714:	6109                	addi	sp,sp,128
    80006716:	8082                	ret

0000000080006718 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006718:	1101                	addi	sp,sp,-32
    8000671a:	ec06                	sd	ra,24(sp)
    8000671c:	e822                	sd	s0,16(sp)
    8000671e:	e426                	sd	s1,8(sp)
    80006720:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006722:	0001c497          	auipc	s1,0x1c
    80006726:	74e48493          	addi	s1,s1,1870 # 80022e70 <disk>
    8000672a:	0001d517          	auipc	a0,0x1d
    8000672e:	86e50513          	addi	a0,a0,-1938 # 80022f98 <disk+0x128>
    80006732:	ffffa097          	auipc	ra,0xffffa
    80006736:	4a4080e7          	jalr	1188(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000673a:	10001737          	lui	a4,0x10001
    8000673e:	533c                	lw	a5,96(a4)
    80006740:	8b8d                	andi	a5,a5,3
    80006742:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006744:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006748:	689c                	ld	a5,16(s1)
    8000674a:	0204d703          	lhu	a4,32(s1)
    8000674e:	0027d783          	lhu	a5,2(a5)
    80006752:	04f70863          	beq	a4,a5,800067a2 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006756:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000675a:	6898                	ld	a4,16(s1)
    8000675c:	0204d783          	lhu	a5,32(s1)
    80006760:	8b9d                	andi	a5,a5,7
    80006762:	078e                	slli	a5,a5,0x3
    80006764:	97ba                	add	a5,a5,a4
    80006766:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006768:	00278713          	addi	a4,a5,2
    8000676c:	0712                	slli	a4,a4,0x4
    8000676e:	9726                	add	a4,a4,s1
    80006770:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006774:	e721                	bnez	a4,800067bc <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006776:	0789                	addi	a5,a5,2
    80006778:	0792                	slli	a5,a5,0x4
    8000677a:	97a6                	add	a5,a5,s1
    8000677c:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000677e:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006782:	ffffc097          	auipc	ra,0xffffc
    80006786:	cb2080e7          	jalr	-846(ra) # 80002434 <wakeup>

    disk.used_idx += 1;
    8000678a:	0204d783          	lhu	a5,32(s1)
    8000678e:	2785                	addiw	a5,a5,1
    80006790:	17c2                	slli	a5,a5,0x30
    80006792:	93c1                	srli	a5,a5,0x30
    80006794:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006798:	6898                	ld	a4,16(s1)
    8000679a:	00275703          	lhu	a4,2(a4)
    8000679e:	faf71ce3          	bne	a4,a5,80006756 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800067a2:	0001c517          	auipc	a0,0x1c
    800067a6:	7f650513          	addi	a0,a0,2038 # 80022f98 <disk+0x128>
    800067aa:	ffffa097          	auipc	ra,0xffffa
    800067ae:	4e0080e7          	jalr	1248(ra) # 80000c8a <release>
}
    800067b2:	60e2                	ld	ra,24(sp)
    800067b4:	6442                	ld	s0,16(sp)
    800067b6:	64a2                	ld	s1,8(sp)
    800067b8:	6105                	addi	sp,sp,32
    800067ba:	8082                	ret
      panic("virtio_disk_intr status");
    800067bc:	00002517          	auipc	a0,0x2
    800067c0:	0b450513          	addi	a0,a0,180 # 80008870 <syscalls+0x3f8>
    800067c4:	ffffa097          	auipc	ra,0xffffa
    800067c8:	d7a080e7          	jalr	-646(ra) # 8000053e <panic>
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
