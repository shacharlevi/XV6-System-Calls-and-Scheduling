
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
    80000068:	17c78793          	addi	a5,a5,380 # 800061e0 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdba4f>
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
    80000130:	782080e7          	jalr	1922(ra) # 800028ae <either_copyin>
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
    800001c4:	820080e7          	jalr	-2016(ra) # 800019e0 <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	4ee080e7          	jalr	1262(ra) # 800026b6 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	18c080e7          	jalr	396(ra) # 80002362 <sleep>
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
    80000216:	646080e7          	jalr	1606(ra) # 80002858 <either_copyout>
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
    800002f6:	6d6080e7          	jalr	1750(ra) # 800029c8 <procdump>
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
    8000044a:	004080e7          	jalr	4(ra) # 8000244a <wakeup>
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
    80000478:	00021797          	auipc	a5,0x21
    8000047c:	7a078793          	addi	a5,a5,1952 # 80021c18 <devsw>
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
    80000896:	bb8080e7          	jalr	-1096(ra) # 8000244a <wakeup>
    
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
    80000920:	a46080e7          	jalr	-1466(ra) # 80002362 <sleep>
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
    80000a02:	3b278793          	addi	a5,a5,946 # 80022db0 <end>
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
    80000ad2:	2e250513          	addi	a0,a0,738 # 80022db0 <end>
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
    80000ec2:	c4a080e7          	jalr	-950(ra) # 80002b08 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	35a080e7          	jalr	858(ra) # 80006220 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	32c080e7          	jalr	812(ra) # 800021fa <scheduler>
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
    80000f3a:	baa080e7          	jalr	-1110(ra) # 80002ae0 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	bca080e7          	jalr	-1078(ra) # 80002b08 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	2c4080e7          	jalr	708(ra) # 8000620a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	2d2080e7          	jalr	722(ra) # 80006220 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	466080e7          	jalr	1126(ra) # 800033bc <binit>
    iinit();         // inode table
    80000f5e:	00003097          	auipc	ra,0x3
    80000f62:	b0a080e7          	jalr	-1270(ra) # 80003a68 <iinit>
    fileinit();      // file table
    80000f66:	00004097          	auipc	ra,0x4
    80000f6a:	aa8080e7          	jalr	-1368(ra) # 80004a0e <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	3ba080e7          	jalr	954(ra) # 80006328 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	d42080e7          	jalr	-702(ra) # 80001cb8 <userinit>
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
    8000186a:	16aa0a13          	addi	s4,s4,362 # 800179d0 <tickslock>
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
    8000193a:	09a98993          	addi	s3,s3,154 # 800179d0 <tickslock>
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
    800019be:	21650513          	addi	a0,a0,534 # 80010bd0 <cpus>
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
    800019d4:	f4a7ac23          	sw	a0,-168(a5) # 80008928 <sched_policy>
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
    800019fc:	1a870713          	addi	a4,a4,424 # 80010ba0 <pid_lock>
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
    80001a34:	e607a783          	lw	a5,-416(a5) # 80008890 <first.1>
    80001a38:	eb89                	bnez	a5,80001a4a <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a3a:	00001097          	auipc	ra,0x1
    80001a3e:	0e6080e7          	jalr	230(ra) # 80002b20 <usertrapret>
}
    80001a42:	60a2                	ld	ra,8(sp)
    80001a44:	6402                	ld	s0,0(sp)
    80001a46:	0141                	addi	sp,sp,16
    80001a48:	8082                	ret
    first = 0;
    80001a4a:	00007797          	auipc	a5,0x7
    80001a4e:	e407a323          	sw	zero,-442(a5) # 80008890 <first.1>
    fsinit(ROOTDEV);
    80001a52:	4505                	li	a0,1
    80001a54:	00002097          	auipc	ra,0x2
    80001a58:	f94080e7          	jalr	-108(ra) # 800039e8 <fsinit>
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
    80001a6e:	13690913          	addi	s2,s2,310 # 80010ba0 <pid_lock>
    80001a72:	854a                	mv	a0,s2
    80001a74:	fffff097          	auipc	ra,0xfffff
    80001a78:	162080e7          	jalr	354(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001a7c:	00007797          	auipc	a5,0x7
    80001a80:	e1878793          	addi	a5,a5,-488 # 80008894 <nextpid>
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
    80001bfa:	3da48493          	addi	s1,s1,986 # 80010fd0 <proc>
    80001bfe:	00016917          	auipc	s2,0x16
    80001c02:	dd290913          	addi	s2,s2,-558 # 800179d0 <tickslock>
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
    80001cd0:	c6a7b223          	sd	a0,-924(a5) # 80008930 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cd4:	03400613          	li	a2,52
    80001cd8:	00007597          	auipc	a1,0x7
    80001cdc:	bc858593          	addi	a1,a1,-1080 # 800088a0 <initcode>
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
    80001d1a:	6f4080e7          	jalr	1780(ra) # 8000440a <namei>
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
    80001e4a:	c5a080e7          	jalr	-934(ra) # 80004aa0 <filedup>
    80001e4e:	00a93023          	sd	a0,0(s2)
    80001e52:	b7e5                	j	80001e3a <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e54:	190ab503          	ld	a0,400(s5)
    80001e58:	00002097          	auipc	ra,0x2
    80001e5c:	dce080e7          	jalr	-562(ra) # 80003c26 <idup>
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
    80001e88:	d3448493          	addi	s1,s1,-716 # 80010bb8 <wait_lock>
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

0000000080001ed6 <ps_scheduler>:
{
    80001ed6:	7159                	addi	sp,sp,-112
    80001ed8:	f486                	sd	ra,104(sp)
    80001eda:	f0a2                	sd	s0,96(sp)
    80001edc:	eca6                	sd	s1,88(sp)
    80001ede:	e8ca                	sd	s2,80(sp)
    80001ee0:	e4ce                	sd	s3,72(sp)
    80001ee2:	e0d2                	sd	s4,64(sp)
    80001ee4:	fc56                	sd	s5,56(sp)
    80001ee6:	f85a                	sd	s6,48(sp)
    80001ee8:	f45e                	sd	s7,40(sp)
    80001eea:	1880                	addi	s0,sp,112
    80001eec:	8b92                	mv	s7,tp
  int id = r_tp();
    80001eee:	2b81                	sext.w	s7,s7
  initlock(&counter, "counter");
    80001ef0:	00006597          	auipc	a1,0x6
    80001ef4:	32858593          	addi	a1,a1,808 # 80008218 <digits+0x1d8>
    80001ef8:	f9840513          	addi	a0,s0,-104
    80001efc:	fffff097          	auipc	ra,0xfffff
    80001f00:	c4a080e7          	jalr	-950(ra) # 80000b46 <initlock>
  c->proc = 0;
    80001f04:	007b9713          	slli	a4,s7,0x7
    80001f08:	0000f797          	auipc	a5,0xf
    80001f0c:	c9878793          	addi	a5,a5,-872 # 80010ba0 <pid_lock>
    80001f10:	97ba                	add	a5,a5,a4
    80001f12:	0207b823          	sd	zero,48(a5)
  acquire(&counter);
    80001f16:	f9840513          	addi	a0,s0,-104
    80001f1a:	fffff097          	auipc	ra,0xfffff
    80001f1e:	cbc080e7          	jalr	-836(ra) # 80000bd6 <acquire>
  release(&counter); // long long min_accumulator = LLONG_MAX;
    80001f22:	f9840513          	addi	a0,s0,-104
    80001f26:	fffff097          	auipc	ra,0xfffff
    80001f2a:	d64080e7          	jalr	-668(ra) # 80000c8a <release>
  proc_counter = 0;
    80001f2e:	4a01                	li	s4,0
  min_proc = 0;
    80001f30:	4b01                	li	s6,0
  for (p = proc; p < &proc[NPROC]; p++)
    80001f32:	0000f497          	auipc	s1,0xf
    80001f36:	09e48493          	addi	s1,s1,158 # 80010fd0 <proc>
    if (p->state == RUNNABLE && (p->accumulator < min_accumulator || proc_counter == 0))
    80001f3a:	498d                	li	s3,3
    80001f3c:	00007a97          	auipc	s5,0x7
    80001f40:	95ca8a93          	addi	s5,s5,-1700 # 80008898 <min_accumulator>
  for (p = proc; p < &proc[NPROC]; p++)
    80001f44:	00016917          	auipc	s2,0x16
    80001f48:	a8c90913          	addi	s2,s2,-1396 # 800179d0 <tickslock>
    80001f4c:	a81d                	j	80001f82 <ps_scheduler+0xac>
      acquire(&counter);
    80001f4e:	f9840513          	addi	a0,s0,-104
    80001f52:	fffff097          	auipc	ra,0xfffff
    80001f56:	c84080e7          	jalr	-892(ra) # 80000bd6 <acquire>
      proc_counter++;
    80001f5a:	2a05                	addiw	s4,s4,1
      release(&counter);
    80001f5c:	f9840513          	addi	a0,s0,-104
    80001f60:	fffff097          	auipc	ra,0xfffff
    80001f64:	d2a080e7          	jalr	-726(ra) # 80000c8a <release>
      min_accumulator = p->accumulator;
    80001f68:	70bc                	ld	a5,96(s1)
    80001f6a:	00faa023          	sw	a5,0(s5)
    80001f6e:	8b26                	mv	s6,s1
    release(&p->lock);
    80001f70:	8526                	mv	a0,s1
    80001f72:	fffff097          	auipc	ra,0xfffff
    80001f76:	d18080e7          	jalr	-744(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001f7a:	1a848493          	addi	s1,s1,424
    80001f7e:	03248263          	beq	s1,s2,80001fa2 <ps_scheduler+0xcc>
    acquire(&p->lock); // printf("Process %d state: %d\n", p->pid, p->state);  // <-- Debugging statement
    80001f82:	8526                	mv	a0,s1
    80001f84:	fffff097          	auipc	ra,0xfffff
    80001f88:	c52080e7          	jalr	-942(ra) # 80000bd6 <acquire>
    if (p->state == RUNNABLE && (p->accumulator < min_accumulator || proc_counter == 0))
    80001f8c:	4c9c                	lw	a5,24(s1)
    80001f8e:	ff3791e3          	bne	a5,s3,80001f70 <ps_scheduler+0x9a>
    80001f92:	000aa783          	lw	a5,0(s5)
    80001f96:	70b8                	ld	a4,96(s1)
    80001f98:	faf74be3          	blt	a4,a5,80001f4e <ps_scheduler+0x78>
    80001f9c:	fc0a1ae3          	bnez	s4,80001f70 <ps_scheduler+0x9a>
    80001fa0:	b77d                	j	80001f4e <ps_scheduler+0x78>
  if (min_proc != 0)
    80001fa2:	020b0563          	beqz	s6,80001fcc <ps_scheduler+0xf6>
    if (proc_counter == 1)
    80001fa6:	4785                	li	a5,1
    80001fa8:	02fa0d63          	beq	s4,a5,80001fe2 <ps_scheduler+0x10c>
    acquire(&min_proc->lock);
    80001fac:	84da                	mv	s1,s6
    80001fae:	855a                	mv	a0,s6
    80001fb0:	fffff097          	auipc	ra,0xfffff
    80001fb4:	c26080e7          	jalr	-986(ra) # 80000bd6 <acquire>
    if (min_proc->state == RUNNABLE)
    80001fb8:	018b2703          	lw	a4,24(s6) # 1018 <_entry-0x7fffefe8>
    80001fbc:	478d                	li	a5,3
    80001fbe:	02f70563          	beq	a4,a5,80001fe8 <ps_scheduler+0x112>
    release(&min_proc->lock);
    80001fc2:	8526                	mv	a0,s1
    80001fc4:	fffff097          	auipc	ra,0xfffff
    80001fc8:	cc6080e7          	jalr	-826(ra) # 80000c8a <release>
}
    80001fcc:	70a6                	ld	ra,104(sp)
    80001fce:	7406                	ld	s0,96(sp)
    80001fd0:	64e6                	ld	s1,88(sp)
    80001fd2:	6946                	ld	s2,80(sp)
    80001fd4:	69a6                	ld	s3,72(sp)
    80001fd6:	6a06                	ld	s4,64(sp)
    80001fd8:	7ae2                	ld	s5,56(sp)
    80001fda:	7b42                	ld	s6,48(sp)
    80001fdc:	7ba2                	ld	s7,40(sp)
    80001fde:	6165                	addi	sp,sp,112
    80001fe0:	8082                	ret
      min_proc->accumulator = 0;
    80001fe2:	060b3023          	sd	zero,96(s6)
    80001fe6:	b7d9                	j	80001fac <ps_scheduler+0xd6>
      min_proc->state = RUNNING;
    80001fe8:	4791                	li	a5,4
    80001fea:	00fb2c23          	sw	a5,24(s6)
      c->proc = min_proc;
    80001fee:	0b9e                	slli	s7,s7,0x7
    80001ff0:	0000f917          	auipc	s2,0xf
    80001ff4:	bb090913          	addi	s2,s2,-1104 # 80010ba0 <pid_lock>
    80001ff8:	995e                	add	s2,s2,s7
    80001ffa:	03693823          	sd	s6,48(s2)
      swtch(&c->context, &min_proc->context);
    80001ffe:	0a0b0593          	addi	a1,s6,160
    80002002:	0000f517          	auipc	a0,0xf
    80002006:	bd650513          	addi	a0,a0,-1066 # 80010bd8 <cpus+0x8>
    8000200a:	955e                	add	a0,a0,s7
    8000200c:	00001097          	auipc	ra,0x1
    80002010:	a6a080e7          	jalr	-1430(ra) # 80002a76 <swtch>
      c->proc = 0;
    80002014:	02093823          	sd	zero,48(s2)
    80002018:	b76d                	j	80001fc2 <ps_scheduler+0xec>

000000008000201a <cfs_scheduler>:
void cfs_scheduler(void){
    8000201a:	7119                	addi	sp,sp,-128
    8000201c:	fc86                	sd	ra,120(sp)
    8000201e:	f8a2                	sd	s0,112(sp)
    80002020:	f4a6                	sd	s1,104(sp)
    80002022:	f0ca                	sd	s2,96(sp)
    80002024:	ecce                	sd	s3,88(sp)
    80002026:	e8d2                	sd	s4,80(sp)
    80002028:	e4d6                	sd	s5,72(sp)
    8000202a:	e0da                	sd	s6,64(sp)
    8000202c:	fc5e                	sd	s7,56(sp)
    8000202e:	f862                	sd	s8,48(sp)
    80002030:	f466                	sd	s9,40(sp)
    80002032:	f06a                	sd	s10,32(sp)
    80002034:	ec6e                	sd	s11,24(sp)
    80002036:	0100                	addi	s0,sp,128
    80002038:	8792                	mv	a5,tp
  int id = r_tp();
    8000203a:	2781                	sext.w	a5,a5
    8000203c:	f8f43423          	sd	a5,-120(s0)
  c->proc = 0;
    80002040:	00779713          	slli	a4,a5,0x7
    80002044:	0000f797          	auipc	a5,0xf
    80002048:	b5c78793          	addi	a5,a5,-1188 # 80010ba0 <pid_lock>
    8000204c:	97ba                	add	a5,a5,a4
    8000204e:	0207b823          	sd	zero,48(a5)
  int min_vruntime = __INT_MAX__;
    80002052:	80000bb7          	lui	s7,0x80000
    80002056:	fffbcb93          	not	s7,s7
  int decay_factor = 100;
    8000205a:	06400913          	li	s2,100
  struct proc *min_proc = 0;
    8000205e:	4d81                	li	s11,0
  for (p = proc; p < &proc[NPROC]; p++){
    80002060:	0000f497          	auipc	s1,0xf
    80002064:	f7048493          	addi	s1,s1,-144 # 80010fd0 <proc>
    switch (p->cfs_priority){
    80002068:	4b05                	li	s6,1
      decay_factor = 100;
    8000206a:	06400d13          	li	s10,100
    switch (p->cfs_priority){
    8000206e:	4a89                	li	s5,2
      decay_factor = 125;
    80002070:	07d00c93          	li	s9,125
    switch (p->cfs_priority){
    80002074:	04b00c13          	li	s8,75
    if (p->state == RUNNABLE && vruntime < min_vruntime){
    80002078:	4a0d                	li	s4,3
  for (p = proc; p < &proc[NPROC]; p++){
    8000207a:	00016997          	auipc	s3,0x16
    8000207e:	95698993          	addi	s3,s3,-1706 # 800179d0 <tickslock>
    80002082:	a005                	j	800020a2 <cfs_scheduler+0x88>
    switch (p->cfs_priority){
    80002084:	8962                	mv	s2,s8
    80002086:	a80d                	j	800020b8 <cfs_scheduler+0x9e>
      decay_factor = 100;
    80002088:	896a                	mv	s2,s10
    8000208a:	a03d                	j	800020b8 <cfs_scheduler+0x9e>
      decay_factor = 125;
    8000208c:	8966                	mv	s2,s9
    8000208e:	a02d                	j	800020b8 <cfs_scheduler+0x9e>
    release(&p->lock);
    80002090:	8526                	mv	a0,s1
    80002092:	fffff097          	auipc	ra,0xfffff
    80002096:	bf8080e7          	jalr	-1032(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++){
    8000209a:	1a848493          	addi	s1,s1,424
    8000209e:	03348e63          	beq	s1,s3,800020da <cfs_scheduler+0xc0>
    acquire(&p->lock);
    800020a2:	8526                	mv	a0,s1
    800020a4:	fffff097          	auipc	ra,0xfffff
    800020a8:	b32080e7          	jalr	-1230(ra) # 80000bd6 <acquire>
    switch (p->cfs_priority){
    800020ac:	58bc                	lw	a5,112(s1)
    800020ae:	fd678de3          	beq	a5,s6,80002088 <cfs_scheduler+0x6e>
    800020b2:	fd578de3          	beq	a5,s5,8000208c <cfs_scheduler+0x72>
    800020b6:	d7f9                	beqz	a5,80002084 <cfs_scheduler+0x6a>
    vruntime = decay_factor * ((p->rtime) / (p->rtime + p->stime + p->retime));
    800020b8:	58fc                	lw	a5,116(s1)
    800020ba:	5cb8                	lw	a4,120(s1)
    800020bc:	5cf0                	lw	a2,124(s1)
    if (p->state == RUNNABLE && vruntime < min_vruntime){
    800020be:	4c94                	lw	a3,24(s1)
    800020c0:	fd4698e3          	bne	a3,s4,80002090 <cfs_scheduler+0x76>
    vruntime = decay_factor * ((p->rtime) / (p->rtime + p->stime + p->retime));
    800020c4:	9f3d                	addw	a4,a4,a5
    800020c6:	9f31                	addw	a4,a4,a2
    800020c8:	02e7c7bb          	divw	a5,a5,a4
    800020cc:	032787bb          	mulw	a5,a5,s2
    if (p->state == RUNNABLE && vruntime < min_vruntime){
    800020d0:	fd77d0e3          	bge	a5,s7,80002090 <cfs_scheduler+0x76>
      min_vruntime = vruntime;
    800020d4:	8bbe                	mv	s7,a5
    if (p->state == RUNNABLE && vruntime < min_vruntime){
    800020d6:	8da6                	mv	s11,s1
    800020d8:	bf65                	j	80002090 <cfs_scheduler+0x76>
  if (min_proc != 0){
    800020da:	020d8263          	beqz	s11,800020fe <cfs_scheduler+0xe4>
    acquire(&min_proc->lock);
    800020de:	84ee                	mv	s1,s11
    800020e0:	856e                	mv	a0,s11
    800020e2:	fffff097          	auipc	ra,0xfffff
    800020e6:	af4080e7          	jalr	-1292(ra) # 80000bd6 <acquire>
    if (min_proc->state == RUNNABLE)
    800020ea:	018da703          	lw	a4,24(s11)
    800020ee:	478d                	li	a5,3
    800020f0:	02f70663          	beq	a4,a5,8000211c <cfs_scheduler+0x102>
    release(&min_proc->lock);
    800020f4:	8526                	mv	a0,s1
    800020f6:	fffff097          	auipc	ra,0xfffff
    800020fa:	b94080e7          	jalr	-1132(ra) # 80000c8a <release>
}
    800020fe:	70e6                	ld	ra,120(sp)
    80002100:	7446                	ld	s0,112(sp)
    80002102:	74a6                	ld	s1,104(sp)
    80002104:	7906                	ld	s2,96(sp)
    80002106:	69e6                	ld	s3,88(sp)
    80002108:	6a46                	ld	s4,80(sp)
    8000210a:	6aa6                	ld	s5,72(sp)
    8000210c:	6b06                	ld	s6,64(sp)
    8000210e:	7be2                	ld	s7,56(sp)
    80002110:	7c42                	ld	s8,48(sp)
    80002112:	7ca2                	ld	s9,40(sp)
    80002114:	7d02                	ld	s10,32(sp)
    80002116:	6de2                	ld	s11,24(sp)
    80002118:	6109                	addi	sp,sp,128
    8000211a:	8082                	ret
      min_proc->state = RUNNING;
    8000211c:	4791                	li	a5,4
    8000211e:	00fdac23          	sw	a5,24(s11)
      c->proc = min_proc;
    80002122:	f8843783          	ld	a5,-120(s0)
    80002126:	079e                	slli	a5,a5,0x7
    80002128:	0000f917          	auipc	s2,0xf
    8000212c:	a7890913          	addi	s2,s2,-1416 # 80010ba0 <pid_lock>
    80002130:	993e                	add	s2,s2,a5
    80002132:	03b93823          	sd	s11,48(s2)
      swtch(&c->context, &min_proc->context);
    80002136:	0a0d8593          	addi	a1,s11,160
    8000213a:	0000f517          	auipc	a0,0xf
    8000213e:	a9e50513          	addi	a0,a0,-1378 # 80010bd8 <cpus+0x8>
    80002142:	953e                	add	a0,a0,a5
    80002144:	00001097          	auipc	ra,0x1
    80002148:	932080e7          	jalr	-1742(ra) # 80002a76 <swtch>
      c->proc = 0;
    8000214c:	02093823          	sd	zero,48(s2)
    80002150:	b755                	j	800020f4 <cfs_scheduler+0xda>

0000000080002152 <original_scheduler>:
void original_scheduler(void){
    80002152:	7139                	addi	sp,sp,-64
    80002154:	fc06                	sd	ra,56(sp)
    80002156:	f822                	sd	s0,48(sp)
    80002158:	f426                	sd	s1,40(sp)
    8000215a:	f04a                	sd	s2,32(sp)
    8000215c:	ec4e                	sd	s3,24(sp)
    8000215e:	e852                	sd	s4,16(sp)
    80002160:	e456                	sd	s5,8(sp)
    80002162:	e05a                	sd	s6,0(sp)
    80002164:	0080                	addi	s0,sp,64
    80002166:	8792                	mv	a5,tp
  int id = r_tp();
    80002168:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000216a:	00779a93          	slli	s5,a5,0x7
    8000216e:	0000f717          	auipc	a4,0xf
    80002172:	a3270713          	addi	a4,a4,-1486 # 80010ba0 <pid_lock>
    80002176:	9756                	add	a4,a4,s5
    80002178:	02073823          	sd	zero,48(a4)
      swtch(&c->context, &p->context);
    8000217c:	0000f717          	auipc	a4,0xf
    80002180:	a5c70713          	addi	a4,a4,-1444 # 80010bd8 <cpus+0x8>
    80002184:	9aba                	add	s5,s5,a4
  for (p = proc; p < &proc[NPROC]; p++){
    80002186:	0000f497          	auipc	s1,0xf
    8000218a:	e4a48493          	addi	s1,s1,-438 # 80010fd0 <proc>
    if (p->state == RUNNABLE){
    8000218e:	498d                	li	s3,3
      p->state = RUNNING;
    80002190:	4b11                	li	s6,4
      c->proc = p;
    80002192:	079e                	slli	a5,a5,0x7
    80002194:	0000fa17          	auipc	s4,0xf
    80002198:	a0ca0a13          	addi	s4,s4,-1524 # 80010ba0 <pid_lock>
    8000219c:	9a3e                	add	s4,s4,a5
  for (p = proc; p < &proc[NPROC]; p++){
    8000219e:	00016917          	auipc	s2,0x16
    800021a2:	83290913          	addi	s2,s2,-1998 # 800179d0 <tickslock>
    800021a6:	a811                	j	800021ba <original_scheduler+0x68>
    release(&p->lock);
    800021a8:	8526                	mv	a0,s1
    800021aa:	fffff097          	auipc	ra,0xfffff
    800021ae:	ae0080e7          	jalr	-1312(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++){
    800021b2:	1a848493          	addi	s1,s1,424
    800021b6:	03248863          	beq	s1,s2,800021e6 <original_scheduler+0x94>
    acquire(&p->lock);
    800021ba:	8526                	mv	a0,s1
    800021bc:	fffff097          	auipc	ra,0xfffff
    800021c0:	a1a080e7          	jalr	-1510(ra) # 80000bd6 <acquire>
    if (p->state == RUNNABLE){
    800021c4:	4c9c                	lw	a5,24(s1)
    800021c6:	ff3791e3          	bne	a5,s3,800021a8 <original_scheduler+0x56>
      p->state = RUNNING;
    800021ca:	0164ac23          	sw	s6,24(s1)
      c->proc = p;
    800021ce:	029a3823          	sd	s1,48(s4)
      swtch(&c->context, &p->context);
    800021d2:	0a048593          	addi	a1,s1,160
    800021d6:	8556                	mv	a0,s5
    800021d8:	00001097          	auipc	ra,0x1
    800021dc:	89e080e7          	jalr	-1890(ra) # 80002a76 <swtch>
      c->proc = 0;
    800021e0:	020a3823          	sd	zero,48(s4)
    800021e4:	b7d1                	j	800021a8 <original_scheduler+0x56>
}
    800021e6:	70e2                	ld	ra,56(sp)
    800021e8:	7442                	ld	s0,48(sp)
    800021ea:	74a2                	ld	s1,40(sp)
    800021ec:	7902                	ld	s2,32(sp)
    800021ee:	69e2                	ld	s3,24(sp)
    800021f0:	6a42                	ld	s4,16(sp)
    800021f2:	6aa2                	ld	s5,8(sp)
    800021f4:	6b02                	ld	s6,0(sp)
    800021f6:	6121                	addi	sp,sp,64
    800021f8:	8082                	ret

00000000800021fa <scheduler>:
{
    800021fa:	7179                	addi	sp,sp,-48
    800021fc:	f406                	sd	ra,40(sp)
    800021fe:	f022                	sd	s0,32(sp)
    80002200:	ec26                	sd	s1,24(sp)
    80002202:	e84a                	sd	s2,16(sp)
    80002204:	e44e                	sd	s3,8(sp)
    80002206:	1800                	addi	s0,sp,48
    if (sched_policy == 0)
    80002208:	00006497          	auipc	s1,0x6
    8000220c:	72048493          	addi	s1,s1,1824 # 80008928 <sched_policy>
    if (sched_policy == 1)
    80002210:	4985                	li	s3,1
    if (sched_policy == 2)
    80002212:	4909                	li	s2,2
    80002214:	a039                	j	80002222 <scheduler+0x28>
    if (sched_policy == 1)
    80002216:	409c                	lw	a5,0(s1)
    80002218:	03378263          	beq	a5,s3,8000223c <scheduler+0x42>
    if (sched_policy == 2)
    8000221c:	409c                	lw	a5,0(s1)
    8000221e:	03278463          	beq	a5,s2,80002246 <scheduler+0x4c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002222:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002226:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000222a:	10079073          	csrw	sstatus,a5
    if (sched_policy == 0)
    8000222e:	409c                	lw	a5,0(s1)
    80002230:	f3fd                	bnez	a5,80002216 <scheduler+0x1c>
      original_scheduler();
    80002232:	00000097          	auipc	ra,0x0
    80002236:	f20080e7          	jalr	-224(ra) # 80002152 <original_scheduler>
    8000223a:	bff1                	j	80002216 <scheduler+0x1c>
      ps_scheduler();
    8000223c:	00000097          	auipc	ra,0x0
    80002240:	c9a080e7          	jalr	-870(ra) # 80001ed6 <ps_scheduler>
    80002244:	bfe1                	j	8000221c <scheduler+0x22>
      cfs_scheduler();
    80002246:	00000097          	auipc	ra,0x0
    8000224a:	dd4080e7          	jalr	-556(ra) # 8000201a <cfs_scheduler>
    8000224e:	bfd1                	j	80002222 <scheduler+0x28>

0000000080002250 <sched>:
{
    80002250:	7179                	addi	sp,sp,-48
    80002252:	f406                	sd	ra,40(sp)
    80002254:	f022                	sd	s0,32(sp)
    80002256:	ec26                	sd	s1,24(sp)
    80002258:	e84a                	sd	s2,16(sp)
    8000225a:	e44e                	sd	s3,8(sp)
    8000225c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000225e:	fffff097          	auipc	ra,0xfffff
    80002262:	782080e7          	jalr	1922(ra) # 800019e0 <myproc>
    80002266:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80002268:	fffff097          	auipc	ra,0xfffff
    8000226c:	8f4080e7          	jalr	-1804(ra) # 80000b5c <holding>
    80002270:	c93d                	beqz	a0,800022e6 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002272:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80002274:	2781                	sext.w	a5,a5
    80002276:	079e                	slli	a5,a5,0x7
    80002278:	0000f717          	auipc	a4,0xf
    8000227c:	92870713          	addi	a4,a4,-1752 # 80010ba0 <pid_lock>
    80002280:	97ba                	add	a5,a5,a4
    80002282:	0a87a703          	lw	a4,168(a5)
    80002286:	4785                	li	a5,1
    80002288:	06f71763          	bne	a4,a5,800022f6 <sched+0xa6>
  if (p->state == RUNNING)
    8000228c:	4c98                	lw	a4,24(s1)
    8000228e:	4791                	li	a5,4
    80002290:	06f70b63          	beq	a4,a5,80002306 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002294:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002298:	8b89                	andi	a5,a5,2
  if (intr_get())
    8000229a:	efb5                	bnez	a5,80002316 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000229c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000229e:	0000f917          	auipc	s2,0xf
    800022a2:	90290913          	addi	s2,s2,-1790 # 80010ba0 <pid_lock>
    800022a6:	2781                	sext.w	a5,a5
    800022a8:	079e                	slli	a5,a5,0x7
    800022aa:	97ca                	add	a5,a5,s2
    800022ac:	0ac7a983          	lw	s3,172(a5)
    800022b0:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800022b2:	2781                	sext.w	a5,a5
    800022b4:	079e                	slli	a5,a5,0x7
    800022b6:	0000f597          	auipc	a1,0xf
    800022ba:	92258593          	addi	a1,a1,-1758 # 80010bd8 <cpus+0x8>
    800022be:	95be                	add	a1,a1,a5
    800022c0:	0a048513          	addi	a0,s1,160
    800022c4:	00000097          	auipc	ra,0x0
    800022c8:	7b2080e7          	jalr	1970(ra) # 80002a76 <swtch>
    800022cc:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800022ce:	2781                	sext.w	a5,a5
    800022d0:	079e                	slli	a5,a5,0x7
    800022d2:	97ca                	add	a5,a5,s2
    800022d4:	0b37a623          	sw	s3,172(a5)
}
    800022d8:	70a2                	ld	ra,40(sp)
    800022da:	7402                	ld	s0,32(sp)
    800022dc:	64e2                	ld	s1,24(sp)
    800022de:	6942                	ld	s2,16(sp)
    800022e0:	69a2                	ld	s3,8(sp)
    800022e2:	6145                	addi	sp,sp,48
    800022e4:	8082                	ret
    panic("sched p->lock");
    800022e6:	00006517          	auipc	a0,0x6
    800022ea:	f3a50513          	addi	a0,a0,-198 # 80008220 <digits+0x1e0>
    800022ee:	ffffe097          	auipc	ra,0xffffe
    800022f2:	250080e7          	jalr	592(ra) # 8000053e <panic>
    panic("sched locks");
    800022f6:	00006517          	auipc	a0,0x6
    800022fa:	f3a50513          	addi	a0,a0,-198 # 80008230 <digits+0x1f0>
    800022fe:	ffffe097          	auipc	ra,0xffffe
    80002302:	240080e7          	jalr	576(ra) # 8000053e <panic>
    panic("sched running");
    80002306:	00006517          	auipc	a0,0x6
    8000230a:	f3a50513          	addi	a0,a0,-198 # 80008240 <digits+0x200>
    8000230e:	ffffe097          	auipc	ra,0xffffe
    80002312:	230080e7          	jalr	560(ra) # 8000053e <panic>
    panic("sched interruptible");
    80002316:	00006517          	auipc	a0,0x6
    8000231a:	f3a50513          	addi	a0,a0,-198 # 80008250 <digits+0x210>
    8000231e:	ffffe097          	auipc	ra,0xffffe
    80002322:	220080e7          	jalr	544(ra) # 8000053e <panic>

0000000080002326 <yield>:
{
    80002326:	1101                	addi	sp,sp,-32
    80002328:	ec06                	sd	ra,24(sp)
    8000232a:	e822                	sd	s0,16(sp)
    8000232c:	e426                	sd	s1,8(sp)
    8000232e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002330:	fffff097          	auipc	ra,0xfffff
    80002334:	6b0080e7          	jalr	1712(ra) # 800019e0 <myproc>
    80002338:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000233a:	fffff097          	auipc	ra,0xfffff
    8000233e:	89c080e7          	jalr	-1892(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    80002342:	478d                	li	a5,3
    80002344:	cc9c                	sw	a5,24(s1)
  sched();
    80002346:	00000097          	auipc	ra,0x0
    8000234a:	f0a080e7          	jalr	-246(ra) # 80002250 <sched>
  release(&p->lock);
    8000234e:	8526                	mv	a0,s1
    80002350:	fffff097          	auipc	ra,0xfffff
    80002354:	93a080e7          	jalr	-1734(ra) # 80000c8a <release>
}
    80002358:	60e2                	ld	ra,24(sp)
    8000235a:	6442                	ld	s0,16(sp)
    8000235c:	64a2                	ld	s1,8(sp)
    8000235e:	6105                	addi	sp,sp,32
    80002360:	8082                	ret

0000000080002362 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    80002362:	7179                	addi	sp,sp,-48
    80002364:	f406                	sd	ra,40(sp)
    80002366:	f022                	sd	s0,32(sp)
    80002368:	ec26                	sd	s1,24(sp)
    8000236a:	e84a                	sd	s2,16(sp)
    8000236c:	e44e                	sd	s3,8(sp)
    8000236e:	1800                	addi	s0,sp,48
    80002370:	89aa                	mv	s3,a0
    80002372:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002374:	fffff097          	auipc	ra,0xfffff
    80002378:	66c080e7          	jalr	1644(ra) # 800019e0 <myproc>
    8000237c:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    8000237e:	fffff097          	auipc	ra,0xfffff
    80002382:	858080e7          	jalr	-1960(ra) # 80000bd6 <acquire>
  release(lk);
    80002386:	854a                	mv	a0,s2
    80002388:	fffff097          	auipc	ra,0xfffff
    8000238c:	902080e7          	jalr	-1790(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    80002390:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002394:	4789                	li	a5,2
    80002396:	cc9c                	sw	a5,24(s1)

  sched();
    80002398:	00000097          	auipc	ra,0x0
    8000239c:	eb8080e7          	jalr	-328(ra) # 80002250 <sched>

  // Tidy up.
  p->chan = 0;
    800023a0:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800023a4:	8526                	mv	a0,s1
    800023a6:	fffff097          	auipc	ra,0xfffff
    800023aa:	8e4080e7          	jalr	-1820(ra) # 80000c8a <release>
  acquire(lk);
    800023ae:	854a                	mv	a0,s2
    800023b0:	fffff097          	auipc	ra,0xfffff
    800023b4:	826080e7          	jalr	-2010(ra) # 80000bd6 <acquire>
}
    800023b8:	70a2                	ld	ra,40(sp)
    800023ba:	7402                	ld	s0,32(sp)
    800023bc:	64e2                	ld	s1,24(sp)
    800023be:	6942                	ld	s2,16(sp)
    800023c0:	69a2                	ld	s3,8(sp)
    800023c2:	6145                	addi	sp,sp,48
    800023c4:	8082                	ret

00000000800023c6 <cfs_update>:

void cfs_update()
{
    800023c6:	7139                	addi	sp,sp,-64
    800023c8:	fc06                	sd	ra,56(sp)
    800023ca:	f822                	sd	s0,48(sp)
    800023cc:	f426                	sd	s1,40(sp)
    800023ce:	f04a                	sd	s2,32(sp)
    800023d0:	ec4e                	sd	s3,24(sp)
    800023d2:	e852                	sd	s4,16(sp)
    800023d4:	e456                	sd	s5,8(sp)
    800023d6:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    800023d8:	fffff097          	auipc	ra,0xfffff
    800023dc:	608080e7          	jalr	1544(ra) # 800019e0 <myproc>

  for (p = proc; p < &proc[NPROC]; p++)
    800023e0:	0000f497          	auipc	s1,0xf
    800023e4:	bf048493          	addi	s1,s1,-1040 # 80010fd0 <proc>
  {
    acquire(&p->lock);
    if (p->state == RUNNABLE)
    800023e8:	498d                	li	s3,3
    {
      p->retime++;
    }
    else if (p->state == SLEEPING)
    800023ea:	4a09                	li	s4,2
    {
      p->stime++;
    }
    else if (p->state == RUNNING)
    800023ec:	4a91                	li	s5,4
  for (p = proc; p < &proc[NPROC]; p++)
    800023ee:	00015917          	auipc	s2,0x15
    800023f2:	5e290913          	addi	s2,s2,1506 # 800179d0 <tickslock>
    800023f6:	a829                	j	80002410 <cfs_update+0x4a>
      p->retime++;
    800023f8:	5cfc                	lw	a5,124(s1)
    800023fa:	2785                	addiw	a5,a5,1
    800023fc:	dcfc                	sw	a5,124(s1)
    {
      p->rtime++;
    }
    release(&p->lock);
    800023fe:	8526                	mv	a0,s1
    80002400:	fffff097          	auipc	ra,0xfffff
    80002404:	88a080e7          	jalr	-1910(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002408:	1a848493          	addi	s1,s1,424
    8000240c:	03248663          	beq	s1,s2,80002438 <cfs_update+0x72>
    acquire(&p->lock);
    80002410:	8526                	mv	a0,s1
    80002412:	ffffe097          	auipc	ra,0xffffe
    80002416:	7c4080e7          	jalr	1988(ra) # 80000bd6 <acquire>
    if (p->state == RUNNABLE)
    8000241a:	4c9c                	lw	a5,24(s1)
    8000241c:	fd378ee3          	beq	a5,s3,800023f8 <cfs_update+0x32>
    else if (p->state == SLEEPING)
    80002420:	01478863          	beq	a5,s4,80002430 <cfs_update+0x6a>
    else if (p->state == RUNNING)
    80002424:	fd579de3          	bne	a5,s5,800023fe <cfs_update+0x38>
      p->rtime++;
    80002428:	58fc                	lw	a5,116(s1)
    8000242a:	2785                	addiw	a5,a5,1
    8000242c:	d8fc                	sw	a5,116(s1)
    8000242e:	bfc1                	j	800023fe <cfs_update+0x38>
      p->stime++;
    80002430:	5cbc                	lw	a5,120(s1)
    80002432:	2785                	addiw	a5,a5,1
    80002434:	dcbc                	sw	a5,120(s1)
    80002436:	b7e1                	j	800023fe <cfs_update+0x38>
  }
}
    80002438:	70e2                	ld	ra,56(sp)
    8000243a:	7442                	ld	s0,48(sp)
    8000243c:	74a2                	ld	s1,40(sp)
    8000243e:	7902                	ld	s2,32(sp)
    80002440:	69e2                	ld	s3,24(sp)
    80002442:	6a42                	ld	s4,16(sp)
    80002444:	6aa2                	ld	s5,8(sp)
    80002446:	6121                	addi	sp,sp,64
    80002448:	8082                	ret

000000008000244a <wakeup>:
// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    8000244a:	7139                	addi	sp,sp,-64
    8000244c:	fc06                	sd	ra,56(sp)
    8000244e:	f822                	sd	s0,48(sp)
    80002450:	f426                	sd	s1,40(sp)
    80002452:	f04a                	sd	s2,32(sp)
    80002454:	ec4e                	sd	s3,24(sp)
    80002456:	e852                	sd	s4,16(sp)
    80002458:	e456                	sd	s5,8(sp)
    8000245a:	e05a                	sd	s6,0(sp)
    8000245c:	0080                	addi	s0,sp,64
    8000245e:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002460:	0000f497          	auipc	s1,0xf
    80002464:	b7048493          	addi	s1,s1,-1168 # 80010fd0 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    80002468:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    8000246a:	4b0d                	li	s6,3
        p->accumulator = min_accumulator;
    8000246c:	00006a97          	auipc	s5,0x6
    80002470:	42ca8a93          	addi	s5,s5,1068 # 80008898 <min_accumulator>
  for (p = proc; p < &proc[NPROC]; p++)
    80002474:	00015917          	auipc	s2,0x15
    80002478:	55c90913          	addi	s2,s2,1372 # 800179d0 <tickslock>
    8000247c:	a811                	j	80002490 <wakeup+0x46>
      //   p->stime++;
      // }
      // else if (p->state==RUNNING){
      //   p->rtime++;
      // }
      release(&p->lock);
    8000247e:	8526                	mv	a0,s1
    80002480:	fffff097          	auipc	ra,0xfffff
    80002484:	80a080e7          	jalr	-2038(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002488:	1a848493          	addi	s1,s1,424
    8000248c:	03248963          	beq	s1,s2,800024be <wakeup+0x74>
    if (p != myproc())
    80002490:	fffff097          	auipc	ra,0xfffff
    80002494:	550080e7          	jalr	1360(ra) # 800019e0 <myproc>
    80002498:	fea488e3          	beq	s1,a0,80002488 <wakeup+0x3e>
      acquire(&p->lock);
    8000249c:	8526                	mv	a0,s1
    8000249e:	ffffe097          	auipc	ra,0xffffe
    800024a2:	738080e7          	jalr	1848(ra) # 80000bd6 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    800024a6:	4c9c                	lw	a5,24(s1)
    800024a8:	fd379be3          	bne	a5,s3,8000247e <wakeup+0x34>
    800024ac:	709c                	ld	a5,32(s1)
    800024ae:	fd4798e3          	bne	a5,s4,8000247e <wakeup+0x34>
        p->state = RUNNABLE;
    800024b2:	0164ac23          	sw	s6,24(s1)
        p->accumulator = min_accumulator;
    800024b6:	000aa783          	lw	a5,0(s5)
    800024ba:	f0bc                	sd	a5,96(s1)
    800024bc:	b7c9                	j	8000247e <wakeup+0x34>
    }
  }
}
    800024be:	70e2                	ld	ra,56(sp)
    800024c0:	7442                	ld	s0,48(sp)
    800024c2:	74a2                	ld	s1,40(sp)
    800024c4:	7902                	ld	s2,32(sp)
    800024c6:	69e2                	ld	s3,24(sp)
    800024c8:	6a42                	ld	s4,16(sp)
    800024ca:	6aa2                	ld	s5,8(sp)
    800024cc:	6b02                	ld	s6,0(sp)
    800024ce:	6121                	addi	sp,sp,64
    800024d0:	8082                	ret

00000000800024d2 <reparent>:
{
    800024d2:	7179                	addi	sp,sp,-48
    800024d4:	f406                	sd	ra,40(sp)
    800024d6:	f022                	sd	s0,32(sp)
    800024d8:	ec26                	sd	s1,24(sp)
    800024da:	e84a                	sd	s2,16(sp)
    800024dc:	e44e                	sd	s3,8(sp)
    800024de:	e052                	sd	s4,0(sp)
    800024e0:	1800                	addi	s0,sp,48
    800024e2:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800024e4:	0000f497          	auipc	s1,0xf
    800024e8:	aec48493          	addi	s1,s1,-1300 # 80010fd0 <proc>
      pp->parent = initproc;
    800024ec:	00006a17          	auipc	s4,0x6
    800024f0:	444a0a13          	addi	s4,s4,1092 # 80008930 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800024f4:	00015997          	auipc	s3,0x15
    800024f8:	4dc98993          	addi	s3,s3,1244 # 800179d0 <tickslock>
    800024fc:	a029                	j	80002506 <reparent+0x34>
    800024fe:	1a848493          	addi	s1,s1,424
    80002502:	01348d63          	beq	s1,s3,8000251c <reparent+0x4a>
    if (pp->parent == p)
    80002506:	7c9c                	ld	a5,56(s1)
    80002508:	ff279be3          	bne	a5,s2,800024fe <reparent+0x2c>
      pp->parent = initproc;
    8000250c:	000a3503          	ld	a0,0(s4)
    80002510:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002512:	00000097          	auipc	ra,0x0
    80002516:	f38080e7          	jalr	-200(ra) # 8000244a <wakeup>
    8000251a:	b7d5                	j	800024fe <reparent+0x2c>
}
    8000251c:	70a2                	ld	ra,40(sp)
    8000251e:	7402                	ld	s0,32(sp)
    80002520:	64e2                	ld	s1,24(sp)
    80002522:	6942                	ld	s2,16(sp)
    80002524:	69a2                	ld	s3,8(sp)
    80002526:	6a02                	ld	s4,0(sp)
    80002528:	6145                	addi	sp,sp,48
    8000252a:	8082                	ret

000000008000252c <exit>:
{
    8000252c:	7139                	addi	sp,sp,-64
    8000252e:	fc06                	sd	ra,56(sp)
    80002530:	f822                	sd	s0,48(sp)
    80002532:	f426                	sd	s1,40(sp)
    80002534:	f04a                	sd	s2,32(sp)
    80002536:	ec4e                	sd	s3,24(sp)
    80002538:	e852                	sd	s4,16(sp)
    8000253a:	e456                	sd	s5,8(sp)
    8000253c:	0080                	addi	s0,sp,64
    8000253e:	8a2a                	mv	s4,a0
    80002540:	8aae                	mv	s5,a1
  struct proc *p = myproc();
    80002542:	fffff097          	auipc	ra,0xfffff
    80002546:	49e080e7          	jalr	1182(ra) # 800019e0 <myproc>
    8000254a:	89aa                	mv	s3,a0
  if (p == initproc)
    8000254c:	00006797          	auipc	a5,0x6
    80002550:	3e47b783          	ld	a5,996(a5) # 80008930 <initproc>
    80002554:	11050493          	addi	s1,a0,272
    80002558:	19050913          	addi	s2,a0,400
    8000255c:	02a79363          	bne	a5,a0,80002582 <exit+0x56>
    panic("init exiting");
    80002560:	00006517          	auipc	a0,0x6
    80002564:	d0850513          	addi	a0,a0,-760 # 80008268 <digits+0x228>
    80002568:	ffffe097          	auipc	ra,0xffffe
    8000256c:	fd6080e7          	jalr	-42(ra) # 8000053e <panic>
      fileclose(f);
    80002570:	00002097          	auipc	ra,0x2
    80002574:	582080e7          	jalr	1410(ra) # 80004af2 <fileclose>
      p->ofile[fd] = 0;
    80002578:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    8000257c:	04a1                	addi	s1,s1,8
    8000257e:	01248563          	beq	s1,s2,80002588 <exit+0x5c>
    if (p->ofile[fd])
    80002582:	6088                	ld	a0,0(s1)
    80002584:	f575                	bnez	a0,80002570 <exit+0x44>
    80002586:	bfdd                	j	8000257c <exit+0x50>
  begin_op();
    80002588:	00002097          	auipc	ra,0x2
    8000258c:	09e080e7          	jalr	158(ra) # 80004626 <begin_op>
  iput(p->cwd);
    80002590:	1909b503          	ld	a0,400(s3)
    80002594:	00002097          	auipc	ra,0x2
    80002598:	88a080e7          	jalr	-1910(ra) # 80003e1e <iput>
  end_op();
    8000259c:	00002097          	auipc	ra,0x2
    800025a0:	10a080e7          	jalr	266(ra) # 800046a6 <end_op>
  p->cwd = 0;
    800025a4:	1809b823          	sd	zero,400(s3)
  acquire(&wait_lock);
    800025a8:	0000e497          	auipc	s1,0xe
    800025ac:	61048493          	addi	s1,s1,1552 # 80010bb8 <wait_lock>
    800025b0:	8526                	mv	a0,s1
    800025b2:	ffffe097          	auipc	ra,0xffffe
    800025b6:	624080e7          	jalr	1572(ra) # 80000bd6 <acquire>
  reparent(p);
    800025ba:	854e                	mv	a0,s3
    800025bc:	00000097          	auipc	ra,0x0
    800025c0:	f16080e7          	jalr	-234(ra) # 800024d2 <reparent>
  wakeup(p->parent);
    800025c4:	0389b503          	ld	a0,56(s3)
    800025c8:	00000097          	auipc	ra,0x0
    800025cc:	e82080e7          	jalr	-382(ra) # 8000244a <wakeup>
  acquire(&p->lock);
    800025d0:	854e                	mv	a0,s3
    800025d2:	ffffe097          	auipc	ra,0xffffe
    800025d6:	604080e7          	jalr	1540(ra) # 80000bd6 <acquire>
  safestrcpy(p->exit_msg, msg, sizeof(p->exit_msg)); // Copy string to process PCB
    800025da:	02000613          	li	a2,32
    800025de:	85d6                	mv	a1,s5
    800025e0:	04098513          	addi	a0,s3,64
    800025e4:	fffff097          	auipc	ra,0xfffff
    800025e8:	838080e7          	jalr	-1992(ra) # 80000e1c <safestrcpy>
  p->xstate = status;
    800025ec:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800025f0:	4795                	li	a5,5
    800025f2:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800025f6:	8526                	mv	a0,s1
    800025f8:	ffffe097          	auipc	ra,0xffffe
    800025fc:	692080e7          	jalr	1682(ra) # 80000c8a <release>
  sched();
    80002600:	00000097          	auipc	ra,0x0
    80002604:	c50080e7          	jalr	-944(ra) # 80002250 <sched>
  panic("zombie exit");
    80002608:	00006517          	auipc	a0,0x6
    8000260c:	c7050513          	addi	a0,a0,-912 # 80008278 <digits+0x238>
    80002610:	ffffe097          	auipc	ra,0xffffe
    80002614:	f2e080e7          	jalr	-210(ra) # 8000053e <panic>

0000000080002618 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002618:	7179                	addi	sp,sp,-48
    8000261a:	f406                	sd	ra,40(sp)
    8000261c:	f022                	sd	s0,32(sp)
    8000261e:	ec26                	sd	s1,24(sp)
    80002620:	e84a                	sd	s2,16(sp)
    80002622:	e44e                	sd	s3,8(sp)
    80002624:	1800                	addi	s0,sp,48
    80002626:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002628:	0000f497          	auipc	s1,0xf
    8000262c:	9a848493          	addi	s1,s1,-1624 # 80010fd0 <proc>
    80002630:	00015997          	auipc	s3,0x15
    80002634:	3a098993          	addi	s3,s3,928 # 800179d0 <tickslock>
  {
    acquire(&p->lock);
    80002638:	8526                	mv	a0,s1
    8000263a:	ffffe097          	auipc	ra,0xffffe
    8000263e:	59c080e7          	jalr	1436(ra) # 80000bd6 <acquire>
    if (p->pid == pid)
    80002642:	589c                	lw	a5,48(s1)
    80002644:	01278d63          	beq	a5,s2,8000265e <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002648:	8526                	mv	a0,s1
    8000264a:	ffffe097          	auipc	ra,0xffffe
    8000264e:	640080e7          	jalr	1600(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002652:	1a848493          	addi	s1,s1,424
    80002656:	ff3491e3          	bne	s1,s3,80002638 <kill+0x20>
  }
  return -1;
    8000265a:	557d                	li	a0,-1
    8000265c:	a829                	j	80002676 <kill+0x5e>
      p->killed = 1;
    8000265e:	4785                	li	a5,1
    80002660:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    80002662:	4c98                	lw	a4,24(s1)
    80002664:	4789                	li	a5,2
    80002666:	00f70f63          	beq	a4,a5,80002684 <kill+0x6c>
      release(&p->lock);
    8000266a:	8526                	mv	a0,s1
    8000266c:	ffffe097          	auipc	ra,0xffffe
    80002670:	61e080e7          	jalr	1566(ra) # 80000c8a <release>
      return 0;
    80002674:	4501                	li	a0,0
}
    80002676:	70a2                	ld	ra,40(sp)
    80002678:	7402                	ld	s0,32(sp)
    8000267a:	64e2                	ld	s1,24(sp)
    8000267c:	6942                	ld	s2,16(sp)
    8000267e:	69a2                	ld	s3,8(sp)
    80002680:	6145                	addi	sp,sp,48
    80002682:	8082                	ret
        p->state = RUNNABLE;
    80002684:	478d                	li	a5,3
    80002686:	cc9c                	sw	a5,24(s1)
    80002688:	b7cd                	j	8000266a <kill+0x52>

000000008000268a <setkilled>:

void setkilled(struct proc *p)
{
    8000268a:	1101                	addi	sp,sp,-32
    8000268c:	ec06                	sd	ra,24(sp)
    8000268e:	e822                	sd	s0,16(sp)
    80002690:	e426                	sd	s1,8(sp)
    80002692:	1000                	addi	s0,sp,32
    80002694:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002696:	ffffe097          	auipc	ra,0xffffe
    8000269a:	540080e7          	jalr	1344(ra) # 80000bd6 <acquire>
  p->killed = 1;
    8000269e:	4785                	li	a5,1
    800026a0:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800026a2:	8526                	mv	a0,s1
    800026a4:	ffffe097          	auipc	ra,0xffffe
    800026a8:	5e6080e7          	jalr	1510(ra) # 80000c8a <release>
}
    800026ac:	60e2                	ld	ra,24(sp)
    800026ae:	6442                	ld	s0,16(sp)
    800026b0:	64a2                	ld	s1,8(sp)
    800026b2:	6105                	addi	sp,sp,32
    800026b4:	8082                	ret

00000000800026b6 <killed>:

int killed(struct proc *p)
{
    800026b6:	1101                	addi	sp,sp,-32
    800026b8:	ec06                	sd	ra,24(sp)
    800026ba:	e822                	sd	s0,16(sp)
    800026bc:	e426                	sd	s1,8(sp)
    800026be:	e04a                	sd	s2,0(sp)
    800026c0:	1000                	addi	s0,sp,32
    800026c2:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800026c4:	ffffe097          	auipc	ra,0xffffe
    800026c8:	512080e7          	jalr	1298(ra) # 80000bd6 <acquire>
  k = p->killed;
    800026cc:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800026d0:	8526                	mv	a0,s1
    800026d2:	ffffe097          	auipc	ra,0xffffe
    800026d6:	5b8080e7          	jalr	1464(ra) # 80000c8a <release>
  return k;
}
    800026da:	854a                	mv	a0,s2
    800026dc:	60e2                	ld	ra,24(sp)
    800026de:	6442                	ld	s0,16(sp)
    800026e0:	64a2                	ld	s1,8(sp)
    800026e2:	6902                	ld	s2,0(sp)
    800026e4:	6105                	addi	sp,sp,32
    800026e6:	8082                	ret

00000000800026e8 <wait>:
{
    800026e8:	711d                	addi	sp,sp,-96
    800026ea:	ec86                	sd	ra,88(sp)
    800026ec:	e8a2                	sd	s0,80(sp)
    800026ee:	e4a6                	sd	s1,72(sp)
    800026f0:	e0ca                	sd	s2,64(sp)
    800026f2:	fc4e                	sd	s3,56(sp)
    800026f4:	f852                	sd	s4,48(sp)
    800026f6:	f456                	sd	s5,40(sp)
    800026f8:	f05a                	sd	s6,32(sp)
    800026fa:	ec5e                	sd	s7,24(sp)
    800026fc:	e862                	sd	s8,16(sp)
    800026fe:	e466                	sd	s9,8(sp)
    80002700:	1080                	addi	s0,sp,96
    80002702:	8baa                	mv	s7,a0
    80002704:	8b2e                	mv	s6,a1
  struct proc *p = myproc();
    80002706:	fffff097          	auipc	ra,0xfffff
    8000270a:	2da080e7          	jalr	730(ra) # 800019e0 <myproc>
    8000270e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002710:	0000e517          	auipc	a0,0xe
    80002714:	4a850513          	addi	a0,a0,1192 # 80010bb8 <wait_lock>
    80002718:	ffffe097          	auipc	ra,0xffffe
    8000271c:	4be080e7          	jalr	1214(ra) # 80000bd6 <acquire>
    havekids = 0;
    80002720:	4c01                	li	s8,0
        if (pp->state == ZOMBIE)
    80002722:	4a15                	li	s4,5
        havekids = 1;
    80002724:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002726:	00015997          	auipc	s3,0x15
    8000272a:	2aa98993          	addi	s3,s3,682 # 800179d0 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000272e:	0000ec97          	auipc	s9,0xe
    80002732:	48ac8c93          	addi	s9,s9,1162 # 80010bb8 <wait_lock>
    havekids = 0;
    80002736:	8762                	mv	a4,s8
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002738:	0000f497          	auipc	s1,0xf
    8000273c:	89848493          	addi	s1,s1,-1896 # 80010fd0 <proc>
    80002740:	a06d                	j	800027ea <wait+0x102>
          pid = pp->pid;
    80002742:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002746:	040b9463          	bnez	s7,8000278e <wait+0xa6>
          if (dst != 0 && copyout(p->pagetable, dst, (char *)&pp->exit_msg,
    8000274a:	000b0f63          	beqz	s6,80002768 <wait+0x80>
    8000274e:	02000693          	li	a3,32
    80002752:	04048613          	addi	a2,s1,64
    80002756:	85da                	mv	a1,s6
    80002758:	09093503          	ld	a0,144(s2)
    8000275c:	fffff097          	auipc	ra,0xfffff
    80002760:	f0c080e7          	jalr	-244(ra) # 80001668 <copyout>
    80002764:	06054063          	bltz	a0,800027c4 <wait+0xdc>
          freeproc(pp);
    80002768:	8526                	mv	a0,s1
    8000276a:	fffff097          	auipc	ra,0xfffff
    8000276e:	428080e7          	jalr	1064(ra) # 80001b92 <freeproc>
          release(&pp->lock);
    80002772:	8526                	mv	a0,s1
    80002774:	ffffe097          	auipc	ra,0xffffe
    80002778:	516080e7          	jalr	1302(ra) # 80000c8a <release>
          release(&wait_lock);
    8000277c:	0000e517          	auipc	a0,0xe
    80002780:	43c50513          	addi	a0,a0,1084 # 80010bb8 <wait_lock>
    80002784:	ffffe097          	auipc	ra,0xffffe
    80002788:	506080e7          	jalr	1286(ra) # 80000c8a <release>
          return pid;
    8000278c:	a04d                	j	8000282e <wait+0x146>
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000278e:	4691                	li	a3,4
    80002790:	02c48613          	addi	a2,s1,44
    80002794:	85de                	mv	a1,s7
    80002796:	09093503          	ld	a0,144(s2)
    8000279a:	fffff097          	auipc	ra,0xfffff
    8000279e:	ece080e7          	jalr	-306(ra) # 80001668 <copyout>
    800027a2:	fa0554e3          	bgez	a0,8000274a <wait+0x62>
            release(&pp->lock);
    800027a6:	8526                	mv	a0,s1
    800027a8:	ffffe097          	auipc	ra,0xffffe
    800027ac:	4e2080e7          	jalr	1250(ra) # 80000c8a <release>
            release(&wait_lock);
    800027b0:	0000e517          	auipc	a0,0xe
    800027b4:	40850513          	addi	a0,a0,1032 # 80010bb8 <wait_lock>
    800027b8:	ffffe097          	auipc	ra,0xffffe
    800027bc:	4d2080e7          	jalr	1234(ra) # 80000c8a <release>
            return -1;
    800027c0:	59fd                	li	s3,-1
    800027c2:	a0b5                	j	8000282e <wait+0x146>
            release(&pp->lock);
    800027c4:	8526                	mv	a0,s1
    800027c6:	ffffe097          	auipc	ra,0xffffe
    800027ca:	4c4080e7          	jalr	1220(ra) # 80000c8a <release>
            release(&wait_lock);
    800027ce:	0000e517          	auipc	a0,0xe
    800027d2:	3ea50513          	addi	a0,a0,1002 # 80010bb8 <wait_lock>
    800027d6:	ffffe097          	auipc	ra,0xffffe
    800027da:	4b4080e7          	jalr	1204(ra) # 80000c8a <release>
            return -1;
    800027de:	59fd                	li	s3,-1
    800027e0:	a0b9                	j	8000282e <wait+0x146>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800027e2:	1a848493          	addi	s1,s1,424
    800027e6:	03348463          	beq	s1,s3,8000280e <wait+0x126>
      if (pp->parent == p)
    800027ea:	7c9c                	ld	a5,56(s1)
    800027ec:	ff279be3          	bne	a5,s2,800027e2 <wait+0xfa>
        acquire(&pp->lock);
    800027f0:	8526                	mv	a0,s1
    800027f2:	ffffe097          	auipc	ra,0xffffe
    800027f6:	3e4080e7          	jalr	996(ra) # 80000bd6 <acquire>
        if (pp->state == ZOMBIE)
    800027fa:	4c9c                	lw	a5,24(s1)
    800027fc:	f54783e3          	beq	a5,s4,80002742 <wait+0x5a>
        release(&pp->lock);
    80002800:	8526                	mv	a0,s1
    80002802:	ffffe097          	auipc	ra,0xffffe
    80002806:	488080e7          	jalr	1160(ra) # 80000c8a <release>
        havekids = 1;
    8000280a:	8756                	mv	a4,s5
    8000280c:	bfd9                	j	800027e2 <wait+0xfa>
    if (!havekids || killed(p))
    8000280e:	c719                	beqz	a4,8000281c <wait+0x134>
    80002810:	854a                	mv	a0,s2
    80002812:	00000097          	auipc	ra,0x0
    80002816:	ea4080e7          	jalr	-348(ra) # 800026b6 <killed>
    8000281a:	c905                	beqz	a0,8000284a <wait+0x162>
      release(&wait_lock);
    8000281c:	0000e517          	auipc	a0,0xe
    80002820:	39c50513          	addi	a0,a0,924 # 80010bb8 <wait_lock>
    80002824:	ffffe097          	auipc	ra,0xffffe
    80002828:	466080e7          	jalr	1126(ra) # 80000c8a <release>
      return -1;
    8000282c:	59fd                	li	s3,-1
}
    8000282e:	854e                	mv	a0,s3
    80002830:	60e6                	ld	ra,88(sp)
    80002832:	6446                	ld	s0,80(sp)
    80002834:	64a6                	ld	s1,72(sp)
    80002836:	6906                	ld	s2,64(sp)
    80002838:	79e2                	ld	s3,56(sp)
    8000283a:	7a42                	ld	s4,48(sp)
    8000283c:	7aa2                	ld	s5,40(sp)
    8000283e:	7b02                	ld	s6,32(sp)
    80002840:	6be2                	ld	s7,24(sp)
    80002842:	6c42                	ld	s8,16(sp)
    80002844:	6ca2                	ld	s9,8(sp)
    80002846:	6125                	addi	sp,sp,96
    80002848:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000284a:	85e6                	mv	a1,s9
    8000284c:	854a                	mv	a0,s2
    8000284e:	00000097          	auipc	ra,0x0
    80002852:	b14080e7          	jalr	-1260(ra) # 80002362 <sleep>
    havekids = 0;
    80002856:	b5c5                	j	80002736 <wait+0x4e>

0000000080002858 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002858:	7179                	addi	sp,sp,-48
    8000285a:	f406                	sd	ra,40(sp)
    8000285c:	f022                	sd	s0,32(sp)
    8000285e:	ec26                	sd	s1,24(sp)
    80002860:	e84a                	sd	s2,16(sp)
    80002862:	e44e                	sd	s3,8(sp)
    80002864:	e052                	sd	s4,0(sp)
    80002866:	1800                	addi	s0,sp,48
    80002868:	84aa                	mv	s1,a0
    8000286a:	892e                	mv	s2,a1
    8000286c:	89b2                	mv	s3,a2
    8000286e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002870:	fffff097          	auipc	ra,0xfffff
    80002874:	170080e7          	jalr	368(ra) # 800019e0 <myproc>
  if (user_dst)
    80002878:	c08d                	beqz	s1,8000289a <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    8000287a:	86d2                	mv	a3,s4
    8000287c:	864e                	mv	a2,s3
    8000287e:	85ca                	mv	a1,s2
    80002880:	6948                	ld	a0,144(a0)
    80002882:	fffff097          	auipc	ra,0xfffff
    80002886:	de6080e7          	jalr	-538(ra) # 80001668 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000288a:	70a2                	ld	ra,40(sp)
    8000288c:	7402                	ld	s0,32(sp)
    8000288e:	64e2                	ld	s1,24(sp)
    80002890:	6942                	ld	s2,16(sp)
    80002892:	69a2                	ld	s3,8(sp)
    80002894:	6a02                	ld	s4,0(sp)
    80002896:	6145                	addi	sp,sp,48
    80002898:	8082                	ret
    memmove((char *)dst, src, len);
    8000289a:	000a061b          	sext.w	a2,s4
    8000289e:	85ce                	mv	a1,s3
    800028a0:	854a                	mv	a0,s2
    800028a2:	ffffe097          	auipc	ra,0xffffe
    800028a6:	48c080e7          	jalr	1164(ra) # 80000d2e <memmove>
    return 0;
    800028aa:	8526                	mv	a0,s1
    800028ac:	bff9                	j	8000288a <either_copyout+0x32>

00000000800028ae <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800028ae:	7179                	addi	sp,sp,-48
    800028b0:	f406                	sd	ra,40(sp)
    800028b2:	f022                	sd	s0,32(sp)
    800028b4:	ec26                	sd	s1,24(sp)
    800028b6:	e84a                	sd	s2,16(sp)
    800028b8:	e44e                	sd	s3,8(sp)
    800028ba:	e052                	sd	s4,0(sp)
    800028bc:	1800                	addi	s0,sp,48
    800028be:	892a                	mv	s2,a0
    800028c0:	84ae                	mv	s1,a1
    800028c2:	89b2                	mv	s3,a2
    800028c4:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800028c6:	fffff097          	auipc	ra,0xfffff
    800028ca:	11a080e7          	jalr	282(ra) # 800019e0 <myproc>
  if (user_src)
    800028ce:	c08d                	beqz	s1,800028f0 <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    800028d0:	86d2                	mv	a3,s4
    800028d2:	864e                	mv	a2,s3
    800028d4:	85ca                	mv	a1,s2
    800028d6:	6948                	ld	a0,144(a0)
    800028d8:	fffff097          	auipc	ra,0xfffff
    800028dc:	e1c080e7          	jalr	-484(ra) # 800016f4 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800028e0:	70a2                	ld	ra,40(sp)
    800028e2:	7402                	ld	s0,32(sp)
    800028e4:	64e2                	ld	s1,24(sp)
    800028e6:	6942                	ld	s2,16(sp)
    800028e8:	69a2                	ld	s3,8(sp)
    800028ea:	6a02                	ld	s4,0(sp)
    800028ec:	6145                	addi	sp,sp,48
    800028ee:	8082                	ret
    memmove(dst, (char *)src, len);
    800028f0:	000a061b          	sext.w	a2,s4
    800028f4:	85ce                	mv	a1,s3
    800028f6:	854a                	mv	a0,s2
    800028f8:	ffffe097          	auipc	ra,0xffffe
    800028fc:	436080e7          	jalr	1078(ra) # 80000d2e <memmove>
    return 0;
    80002900:	8526                	mv	a0,s1
    80002902:	bff9                	j	800028e0 <either_copyin+0x32>

0000000080002904 <get_cfs_stats>:
int get_cfs_stats(uint64 add, int pid)
{
    80002904:	7139                	addi	sp,sp,-64
    80002906:	fc06                	sd	ra,56(sp)
    80002908:	f822                	sd	s0,48(sp)
    8000290a:	f426                	sd	s1,40(sp)
    8000290c:	f04a                	sd	s2,32(sp)
    8000290e:	ec4e                	sd	s3,24(sp)
    80002910:	e852                	sd	s4,16(sp)
    80002912:	0080                	addi	s0,sp,64
    80002914:	8a2a                	mv	s4,a0
    80002916:	892e                	mv	s2,a1
  struct proc *p;
  // struct proc *found_proc;

  int values[4];
  // printf("%d\n",pid);
  for (p = proc; p < &proc[NPROC]; p++)
    80002918:	0000e497          	auipc	s1,0xe
    8000291c:	6b848493          	addi	s1,s1,1720 # 80010fd0 <proc>
    80002920:	00015997          	auipc	s3,0x15
    80002924:	0b098993          	addi	s3,s3,176 # 800179d0 <tickslock>
  {
      // printf("p->pid=%d\n",p->pid);
    acquire(&p->lock);
    80002928:	8526                	mv	a0,s1
    8000292a:	ffffe097          	auipc	ra,0xffffe
    8000292e:	2ac080e7          	jalr	684(ra) # 80000bd6 <acquire>
    if (p->pid == pid)
    80002932:	589c                	lw	a5,48(s1)
    80002934:	01278d63          	beq	a5,s2,8000294e <get_cfs_stats+0x4a>
        return -1;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002938:	8526                	mv	a0,s1
    8000293a:	ffffe097          	auipc	ra,0xffffe
    8000293e:	350080e7          	jalr	848(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002942:	1a848493          	addi	s1,s1,424
    80002946:	ff3491e3          	bne	s1,s3,80002928 <get_cfs_stats+0x24>
  }
  return -1;
    8000294a:	557d                	li	a0,-1
    8000294c:	a0b9                	j	8000299a <get_cfs_stats+0x96>
      values[0] = p->cfs_priority;
    8000294e:	58bc                	lw	a5,112(s1)
    80002950:	fcf42023          	sw	a5,-64(s0)
      values[1] = p->rtime;
    80002954:	58f0                	lw	a2,116(s1)
    80002956:	fcc42223          	sw	a2,-60(s0)
      values[2] = p->stime;
    8000295a:	5cbc                	lw	a5,120(s1)
    8000295c:	fcf42423          	sw	a5,-56(s0)
      values[3] = p->retime;
    80002960:	5cfc                	lw	a5,124(s1)
    80002962:	fcf42623          	sw	a5,-52(s0)
    printf("p number:%d, rtime:%d\n",p->pid,p->rtime);
    80002966:	85ca                	mv	a1,s2
    80002968:	00006517          	auipc	a0,0x6
    8000296c:	92050513          	addi	a0,a0,-1760 # 80008288 <digits+0x248>
    80002970:	ffffe097          	auipc	ra,0xffffe
    80002974:	c18080e7          	jalr	-1000(ra) # 80000588 <printf>
      if (copyout(p->pagetable, add, (char *)values,
    80002978:	46c1                	li	a3,16
    8000297a:	fc040613          	addi	a2,s0,-64
    8000297e:	85d2                	mv	a1,s4
    80002980:	68c8                	ld	a0,144(s1)
    80002982:	fffff097          	auipc	ra,0xfffff
    80002986:	ce6080e7          	jalr	-794(ra) # 80001668 <copyout>
    8000298a:	02054063          	bltz	a0,800029aa <get_cfs_stats+0xa6>
      release(&p->lock);
    8000298e:	8526                	mv	a0,s1
    80002990:	ffffe097          	auipc	ra,0xffffe
    80002994:	2fa080e7          	jalr	762(ra) # 80000c8a <release>
      return 0;
    80002998:	4501                	li	a0,0
}
    8000299a:	70e2                	ld	ra,56(sp)
    8000299c:	7442                	ld	s0,48(sp)
    8000299e:	74a2                	ld	s1,40(sp)
    800029a0:	7902                	ld	s2,32(sp)
    800029a2:	69e2                	ld	s3,24(sp)
    800029a4:	6a42                	ld	s4,16(sp)
    800029a6:	6121                	addi	sp,sp,64
    800029a8:	8082                	ret
        printf("here3\n");
    800029aa:	00006517          	auipc	a0,0x6
    800029ae:	8f650513          	addi	a0,a0,-1802 # 800082a0 <digits+0x260>
    800029b2:	ffffe097          	auipc	ra,0xffffe
    800029b6:	bd6080e7          	jalr	-1066(ra) # 80000588 <printf>
        release(&p->lock);
    800029ba:	8526                	mv	a0,s1
    800029bc:	ffffe097          	auipc	ra,0xffffe
    800029c0:	2ce080e7          	jalr	718(ra) # 80000c8a <release>
        return -1;
    800029c4:	557d                	li	a0,-1
    800029c6:	bfd1                	j	8000299a <get_cfs_stats+0x96>

00000000800029c8 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    800029c8:	715d                	addi	sp,sp,-80
    800029ca:	e486                	sd	ra,72(sp)
    800029cc:	e0a2                	sd	s0,64(sp)
    800029ce:	fc26                	sd	s1,56(sp)
    800029d0:	f84a                	sd	s2,48(sp)
    800029d2:	f44e                	sd	s3,40(sp)
    800029d4:	f052                	sd	s4,32(sp)
    800029d6:	ec56                	sd	s5,24(sp)
    800029d8:	e85a                	sd	s6,16(sp)
    800029da:	e45e                	sd	s7,8(sp)
    800029dc:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    800029de:	00005517          	auipc	a0,0x5
    800029e2:	6ea50513          	addi	a0,a0,1770 # 800080c8 <digits+0x88>
    800029e6:	ffffe097          	auipc	ra,0xffffe
    800029ea:	ba2080e7          	jalr	-1118(ra) # 80000588 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800029ee:	0000e497          	auipc	s1,0xe
    800029f2:	77a48493          	addi	s1,s1,1914 # 80011168 <proc+0x198>
    800029f6:	00015917          	auipc	s2,0x15
    800029fa:	17290913          	addi	s2,s2,370 # 80017b68 <bcache+0x180>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029fe:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002a00:	00006997          	auipc	s3,0x6
    80002a04:	8a898993          	addi	s3,s3,-1880 # 800082a8 <digits+0x268>
    printf("%d %s %s", p->pid, state, p->name);
    80002a08:	00006a97          	auipc	s5,0x6
    80002a0c:	8a8a8a93          	addi	s5,s5,-1880 # 800082b0 <digits+0x270>
    printf("\n");
    80002a10:	00005a17          	auipc	s4,0x5
    80002a14:	6b8a0a13          	addi	s4,s4,1720 # 800080c8 <digits+0x88>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002a18:	00006b97          	auipc	s7,0x6
    80002a1c:	8d8b8b93          	addi	s7,s7,-1832 # 800082f0 <states.0>
    80002a20:	a00d                	j	80002a42 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002a22:	e986a583          	lw	a1,-360(a3)
    80002a26:	8556                	mv	a0,s5
    80002a28:	ffffe097          	auipc	ra,0xffffe
    80002a2c:	b60080e7          	jalr	-1184(ra) # 80000588 <printf>
    printf("\n");
    80002a30:	8552                	mv	a0,s4
    80002a32:	ffffe097          	auipc	ra,0xffffe
    80002a36:	b56080e7          	jalr	-1194(ra) # 80000588 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002a3a:	1a848493          	addi	s1,s1,424
    80002a3e:	03248163          	beq	s1,s2,80002a60 <procdump+0x98>
    if (p->state == UNUSED)
    80002a42:	86a6                	mv	a3,s1
    80002a44:	e804a783          	lw	a5,-384(s1)
    80002a48:	dbed                	beqz	a5,80002a3a <procdump+0x72>
      state = "???";
    80002a4a:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002a4c:	fcfb6be3          	bltu	s6,a5,80002a22 <procdump+0x5a>
    80002a50:	1782                	slli	a5,a5,0x20
    80002a52:	9381                	srli	a5,a5,0x20
    80002a54:	078e                	slli	a5,a5,0x3
    80002a56:	97de                	add	a5,a5,s7
    80002a58:	6390                	ld	a2,0(a5)
    80002a5a:	f661                	bnez	a2,80002a22 <procdump+0x5a>
      state = "???";
    80002a5c:	864e                	mv	a2,s3
    80002a5e:	b7d1                	j	80002a22 <procdump+0x5a>
  }
}
    80002a60:	60a6                	ld	ra,72(sp)
    80002a62:	6406                	ld	s0,64(sp)
    80002a64:	74e2                	ld	s1,56(sp)
    80002a66:	7942                	ld	s2,48(sp)
    80002a68:	79a2                	ld	s3,40(sp)
    80002a6a:	7a02                	ld	s4,32(sp)
    80002a6c:	6ae2                	ld	s5,24(sp)
    80002a6e:	6b42                	ld	s6,16(sp)
    80002a70:	6ba2                	ld	s7,8(sp)
    80002a72:	6161                	addi	sp,sp,80
    80002a74:	8082                	ret

0000000080002a76 <swtch>:
    80002a76:	00153023          	sd	ra,0(a0)
    80002a7a:	00253423          	sd	sp,8(a0)
    80002a7e:	e900                	sd	s0,16(a0)
    80002a80:	ed04                	sd	s1,24(a0)
    80002a82:	03253023          	sd	s2,32(a0)
    80002a86:	03353423          	sd	s3,40(a0)
    80002a8a:	03453823          	sd	s4,48(a0)
    80002a8e:	03553c23          	sd	s5,56(a0)
    80002a92:	05653023          	sd	s6,64(a0)
    80002a96:	05753423          	sd	s7,72(a0)
    80002a9a:	05853823          	sd	s8,80(a0)
    80002a9e:	05953c23          	sd	s9,88(a0)
    80002aa2:	07a53023          	sd	s10,96(a0)
    80002aa6:	07b53423          	sd	s11,104(a0)
    80002aaa:	0005b083          	ld	ra,0(a1)
    80002aae:	0085b103          	ld	sp,8(a1)
    80002ab2:	6980                	ld	s0,16(a1)
    80002ab4:	6d84                	ld	s1,24(a1)
    80002ab6:	0205b903          	ld	s2,32(a1)
    80002aba:	0285b983          	ld	s3,40(a1)
    80002abe:	0305ba03          	ld	s4,48(a1)
    80002ac2:	0385ba83          	ld	s5,56(a1)
    80002ac6:	0405bb03          	ld	s6,64(a1)
    80002aca:	0485bb83          	ld	s7,72(a1)
    80002ace:	0505bc03          	ld	s8,80(a1)
    80002ad2:	0585bc83          	ld	s9,88(a1)
    80002ad6:	0605bd03          	ld	s10,96(a1)
    80002ada:	0685bd83          	ld	s11,104(a1)
    80002ade:	8082                	ret

0000000080002ae0 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002ae0:	1141                	addi	sp,sp,-16
    80002ae2:	e406                	sd	ra,8(sp)
    80002ae4:	e022                	sd	s0,0(sp)
    80002ae6:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002ae8:	00006597          	auipc	a1,0x6
    80002aec:	83858593          	addi	a1,a1,-1992 # 80008320 <states.0+0x30>
    80002af0:	00015517          	auipc	a0,0x15
    80002af4:	ee050513          	addi	a0,a0,-288 # 800179d0 <tickslock>
    80002af8:	ffffe097          	auipc	ra,0xffffe
    80002afc:	04e080e7          	jalr	78(ra) # 80000b46 <initlock>
}
    80002b00:	60a2                	ld	ra,8(sp)
    80002b02:	6402                	ld	s0,0(sp)
    80002b04:	0141                	addi	sp,sp,16
    80002b06:	8082                	ret

0000000080002b08 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002b08:	1141                	addi	sp,sp,-16
    80002b0a:	e422                	sd	s0,8(sp)
    80002b0c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b0e:	00003797          	auipc	a5,0x3
    80002b12:	64278793          	addi	a5,a5,1602 # 80006150 <kernelvec>
    80002b16:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002b1a:	6422                	ld	s0,8(sp)
    80002b1c:	0141                	addi	sp,sp,16
    80002b1e:	8082                	ret

0000000080002b20 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002b20:	1141                	addi	sp,sp,-16
    80002b22:	e406                	sd	ra,8(sp)
    80002b24:	e022                	sd	s0,0(sp)
    80002b26:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002b28:	fffff097          	auipc	ra,0xfffff
    80002b2c:	eb8080e7          	jalr	-328(ra) # 800019e0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b30:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002b34:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b36:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002b3a:	00004617          	auipc	a2,0x4
    80002b3e:	4c660613          	addi	a2,a2,1222 # 80007000 <_trampoline>
    80002b42:	00004697          	auipc	a3,0x4
    80002b46:	4be68693          	addi	a3,a3,1214 # 80007000 <_trampoline>
    80002b4a:	8e91                	sub	a3,a3,a2
    80002b4c:	040007b7          	lui	a5,0x4000
    80002b50:	17fd                	addi	a5,a5,-1
    80002b52:	07b2                	slli	a5,a5,0xc
    80002b54:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b56:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002b5a:	6d58                	ld	a4,152(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002b5c:	180026f3          	csrr	a3,satp
    80002b60:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002b62:	6d58                	ld	a4,152(a0)
    80002b64:	6154                	ld	a3,128(a0)
    80002b66:	6585                	lui	a1,0x1
    80002b68:	96ae                	add	a3,a3,a1
    80002b6a:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002b6c:	6d58                	ld	a4,152(a0)
    80002b6e:	00000697          	auipc	a3,0x0
    80002b72:	13068693          	addi	a3,a3,304 # 80002c9e <usertrap>
    80002b76:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002b78:	6d58                	ld	a4,152(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002b7a:	8692                	mv	a3,tp
    80002b7c:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b7e:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002b82:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002b86:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b8a:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002b8e:	6d58                	ld	a4,152(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b90:	6f18                	ld	a4,24(a4)
    80002b92:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002b96:	6948                	ld	a0,144(a0)
    80002b98:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002b9a:	00004717          	auipc	a4,0x4
    80002b9e:	50270713          	addi	a4,a4,1282 # 8000709c <userret>
    80002ba2:	8f11                	sub	a4,a4,a2
    80002ba4:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002ba6:	577d                	li	a4,-1
    80002ba8:	177e                	slli	a4,a4,0x3f
    80002baa:	8d59                	or	a0,a0,a4
    80002bac:	9782                	jalr	a5
}
    80002bae:	60a2                	ld	ra,8(sp)
    80002bb0:	6402                	ld	s0,0(sp)
    80002bb2:	0141                	addi	sp,sp,16
    80002bb4:	8082                	ret

0000000080002bb6 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002bb6:	1101                	addi	sp,sp,-32
    80002bb8:	ec06                	sd	ra,24(sp)
    80002bba:	e822                	sd	s0,16(sp)
    80002bbc:	e426                	sd	s1,8(sp)
    80002bbe:	1000                	addi	s0,sp,32
  // cfs_update();
  acquire(&tickslock);
    80002bc0:	00015497          	auipc	s1,0x15
    80002bc4:	e1048493          	addi	s1,s1,-496 # 800179d0 <tickslock>
    80002bc8:	8526                	mv	a0,s1
    80002bca:	ffffe097          	auipc	ra,0xffffe
    80002bce:	00c080e7          	jalr	12(ra) # 80000bd6 <acquire>
  ticks++;
    80002bd2:	00006517          	auipc	a0,0x6
    80002bd6:	d6650513          	addi	a0,a0,-666 # 80008938 <ticks>
    80002bda:	411c                	lw	a5,0(a0)
    80002bdc:	2785                	addiw	a5,a5,1
    80002bde:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002be0:	00000097          	auipc	ra,0x0
    80002be4:	86a080e7          	jalr	-1942(ra) # 8000244a <wakeup>
  release(&tickslock);
    80002be8:	8526                	mv	a0,s1
    80002bea:	ffffe097          	auipc	ra,0xffffe
    80002bee:	0a0080e7          	jalr	160(ra) # 80000c8a <release>
  // cfs_update();
}
    80002bf2:	60e2                	ld	ra,24(sp)
    80002bf4:	6442                	ld	s0,16(sp)
    80002bf6:	64a2                	ld	s1,8(sp)
    80002bf8:	6105                	addi	sp,sp,32
    80002bfa:	8082                	ret

0000000080002bfc <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002bfc:	1101                	addi	sp,sp,-32
    80002bfe:	ec06                	sd	ra,24(sp)
    80002c00:	e822                	sd	s0,16(sp)
    80002c02:	e426                	sd	s1,8(sp)
    80002c04:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c06:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002c0a:	00074d63          	bltz	a4,80002c24 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002c0e:	57fd                	li	a5,-1
    80002c10:	17fe                	slli	a5,a5,0x3f
    80002c12:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002c14:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002c16:	06f70363          	beq	a4,a5,80002c7c <devintr+0x80>
  }
}
    80002c1a:	60e2                	ld	ra,24(sp)
    80002c1c:	6442                	ld	s0,16(sp)
    80002c1e:	64a2                	ld	s1,8(sp)
    80002c20:	6105                	addi	sp,sp,32
    80002c22:	8082                	ret
     (scause & 0xff) == 9){
    80002c24:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002c28:	46a5                	li	a3,9
    80002c2a:	fed792e3          	bne	a5,a3,80002c0e <devintr+0x12>
    int irq = plic_claim();
    80002c2e:	00003097          	auipc	ra,0x3
    80002c32:	62a080e7          	jalr	1578(ra) # 80006258 <plic_claim>
    80002c36:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002c38:	47a9                	li	a5,10
    80002c3a:	02f50763          	beq	a0,a5,80002c68 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002c3e:	4785                	li	a5,1
    80002c40:	02f50963          	beq	a0,a5,80002c72 <devintr+0x76>
    return 1;
    80002c44:	4505                	li	a0,1
    } else if(irq){
    80002c46:	d8f1                	beqz	s1,80002c1a <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002c48:	85a6                	mv	a1,s1
    80002c4a:	00005517          	auipc	a0,0x5
    80002c4e:	6de50513          	addi	a0,a0,1758 # 80008328 <states.0+0x38>
    80002c52:	ffffe097          	auipc	ra,0xffffe
    80002c56:	936080e7          	jalr	-1738(ra) # 80000588 <printf>
      plic_complete(irq);
    80002c5a:	8526                	mv	a0,s1
    80002c5c:	00003097          	auipc	ra,0x3
    80002c60:	620080e7          	jalr	1568(ra) # 8000627c <plic_complete>
    return 1;
    80002c64:	4505                	li	a0,1
    80002c66:	bf55                	j	80002c1a <devintr+0x1e>
      uartintr();
    80002c68:	ffffe097          	auipc	ra,0xffffe
    80002c6c:	d32080e7          	jalr	-718(ra) # 8000099a <uartintr>
    80002c70:	b7ed                	j	80002c5a <devintr+0x5e>
      virtio_disk_intr();
    80002c72:	00004097          	auipc	ra,0x4
    80002c76:	ad6080e7          	jalr	-1322(ra) # 80006748 <virtio_disk_intr>
    80002c7a:	b7c5                	j	80002c5a <devintr+0x5e>
    if(cpuid() == 0){
    80002c7c:	fffff097          	auipc	ra,0xfffff
    80002c80:	d22080e7          	jalr	-734(ra) # 8000199e <cpuid>
    80002c84:	c901                	beqz	a0,80002c94 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002c86:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002c8a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002c8c:	14479073          	csrw	sip,a5
    return 2;
    80002c90:	4509                	li	a0,2
    80002c92:	b761                	j	80002c1a <devintr+0x1e>
      clockintr();
    80002c94:	00000097          	auipc	ra,0x0
    80002c98:	f22080e7          	jalr	-222(ra) # 80002bb6 <clockintr>
    80002c9c:	b7ed                	j	80002c86 <devintr+0x8a>

0000000080002c9e <usertrap>:
{
    80002c9e:	1101                	addi	sp,sp,-32
    80002ca0:	ec06                	sd	ra,24(sp)
    80002ca2:	e822                	sd	s0,16(sp)
    80002ca4:	e426                	sd	s1,8(sp)
    80002ca6:	e04a                	sd	s2,0(sp)
    80002ca8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002caa:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002cae:	1007f793          	andi	a5,a5,256
    80002cb2:	e3b1                	bnez	a5,80002cf6 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002cb4:	00003797          	auipc	a5,0x3
    80002cb8:	49c78793          	addi	a5,a5,1180 # 80006150 <kernelvec>
    80002cbc:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002cc0:	fffff097          	auipc	ra,0xfffff
    80002cc4:	d20080e7          	jalr	-736(ra) # 800019e0 <myproc>
    80002cc8:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002cca:	6d5c                	ld	a5,152(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ccc:	14102773          	csrr	a4,sepc
    80002cd0:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cd2:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002cd6:	47a1                	li	a5,8
    80002cd8:	02f70763          	beq	a4,a5,80002d06 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002cdc:	00000097          	auipc	ra,0x0
    80002ce0:	f20080e7          	jalr	-224(ra) # 80002bfc <devintr>
    80002ce4:	892a                	mv	s2,a0
    80002ce6:	c551                	beqz	a0,80002d72 <usertrap+0xd4>
  if(killed(p))
    80002ce8:	8526                	mv	a0,s1
    80002cea:	00000097          	auipc	ra,0x0
    80002cee:	9cc080e7          	jalr	-1588(ra) # 800026b6 <killed>
    80002cf2:	c939                	beqz	a0,80002d48 <usertrap+0xaa>
    80002cf4:	a099                	j	80002d3a <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002cf6:	00005517          	auipc	a0,0x5
    80002cfa:	65250513          	addi	a0,a0,1618 # 80008348 <states.0+0x58>
    80002cfe:	ffffe097          	auipc	ra,0xffffe
    80002d02:	840080e7          	jalr	-1984(ra) # 8000053e <panic>
    if(killed(p))
    80002d06:	00000097          	auipc	ra,0x0
    80002d0a:	9b0080e7          	jalr	-1616(ra) # 800026b6 <killed>
    80002d0e:	e931                	bnez	a0,80002d62 <usertrap+0xc4>
    p->trapframe->epc += 4;
    80002d10:	6cd8                	ld	a4,152(s1)
    80002d12:	6f1c                	ld	a5,24(a4)
    80002d14:	0791                	addi	a5,a5,4
    80002d16:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d18:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002d1c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d20:	10079073          	csrw	sstatus,a5
    syscall();
    80002d24:	00000097          	auipc	ra,0x0
    80002d28:	31e080e7          	jalr	798(ra) # 80003042 <syscall>
  if(killed(p))
    80002d2c:	8526                	mv	a0,s1
    80002d2e:	00000097          	auipc	ra,0x0
    80002d32:	988080e7          	jalr	-1656(ra) # 800026b6 <killed>
    80002d36:	cd01                	beqz	a0,80002d4e <usertrap+0xb0>
    80002d38:	4901                	li	s2,0
    exit(-1,p->exit_msg);
    80002d3a:	04048593          	addi	a1,s1,64
    80002d3e:	557d                	li	a0,-1
    80002d40:	fffff097          	auipc	ra,0xfffff
    80002d44:	7ec080e7          	jalr	2028(ra) # 8000252c <exit>
  if(which_dev == 2){
    80002d48:	4789                	li	a5,2
    80002d4a:	06f90163          	beq	s2,a5,80002dac <usertrap+0x10e>
  usertrapret();
    80002d4e:	00000097          	auipc	ra,0x0
    80002d52:	dd2080e7          	jalr	-558(ra) # 80002b20 <usertrapret>
}
    80002d56:	60e2                	ld	ra,24(sp)
    80002d58:	6442                	ld	s0,16(sp)
    80002d5a:	64a2                	ld	s1,8(sp)
    80002d5c:	6902                	ld	s2,0(sp)
    80002d5e:	6105                	addi	sp,sp,32
    80002d60:	8082                	ret
      exit(-1,p->exit_msg);
    80002d62:	04048593          	addi	a1,s1,64
    80002d66:	557d                	li	a0,-1
    80002d68:	fffff097          	auipc	ra,0xfffff
    80002d6c:	7c4080e7          	jalr	1988(ra) # 8000252c <exit>
    80002d70:	b745                	j	80002d10 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d72:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002d76:	5890                	lw	a2,48(s1)
    80002d78:	00005517          	auipc	a0,0x5
    80002d7c:	5f050513          	addi	a0,a0,1520 # 80008368 <states.0+0x78>
    80002d80:	ffffe097          	auipc	ra,0xffffe
    80002d84:	808080e7          	jalr	-2040(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d88:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d8c:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d90:	00005517          	auipc	a0,0x5
    80002d94:	60850513          	addi	a0,a0,1544 # 80008398 <states.0+0xa8>
    80002d98:	ffffd097          	auipc	ra,0xffffd
    80002d9c:	7f0080e7          	jalr	2032(ra) # 80000588 <printf>
    setkilled(p);
    80002da0:	8526                	mv	a0,s1
    80002da2:	00000097          	auipc	ra,0x0
    80002da6:	8e8080e7          	jalr	-1816(ra) # 8000268a <setkilled>
    80002daa:	b749                	j	80002d2c <usertrap+0x8e>
    myproc()->accumulator+=myproc()->ps_priority;
    80002dac:	fffff097          	auipc	ra,0xfffff
    80002db0:	c34080e7          	jalr	-972(ra) # 800019e0 <myproc>
    80002db4:	7524                	ld	s1,104(a0)
    80002db6:	fffff097          	auipc	ra,0xfffff
    80002dba:	c2a080e7          	jalr	-982(ra) # 800019e0 <myproc>
    80002dbe:	713c                	ld	a5,96(a0)
    80002dc0:	97a6                	add	a5,a5,s1
    80002dc2:	f13c                	sd	a5,96(a0)
    cfs_update();
    80002dc4:	fffff097          	auipc	ra,0xfffff
    80002dc8:	602080e7          	jalr	1538(ra) # 800023c6 <cfs_update>
    yield();
    80002dcc:	fffff097          	auipc	ra,0xfffff
    80002dd0:	55a080e7          	jalr	1370(ra) # 80002326 <yield>
    80002dd4:	bfad                	j	80002d4e <usertrap+0xb0>

0000000080002dd6 <kerneltrap>:
{
    80002dd6:	7179                	addi	sp,sp,-48
    80002dd8:	f406                	sd	ra,40(sp)
    80002dda:	f022                	sd	s0,32(sp)
    80002ddc:	ec26                	sd	s1,24(sp)
    80002dde:	e84a                	sd	s2,16(sp)
    80002de0:	e44e                	sd	s3,8(sp)
    80002de2:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002de4:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002de8:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002dec:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002df0:	1004f793          	andi	a5,s1,256
    80002df4:	cb85                	beqz	a5,80002e24 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002df6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002dfa:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002dfc:	ef85                	bnez	a5,80002e34 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002dfe:	00000097          	auipc	ra,0x0
    80002e02:	dfe080e7          	jalr	-514(ra) # 80002bfc <devintr>
    80002e06:	cd1d                	beqz	a0,80002e44 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING){
    80002e08:	4789                	li	a5,2
    80002e0a:	06f50a63          	beq	a0,a5,80002e7e <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002e0e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002e12:	10049073          	csrw	sstatus,s1
}
    80002e16:	70a2                	ld	ra,40(sp)
    80002e18:	7402                	ld	s0,32(sp)
    80002e1a:	64e2                	ld	s1,24(sp)
    80002e1c:	6942                	ld	s2,16(sp)
    80002e1e:	69a2                	ld	s3,8(sp)
    80002e20:	6145                	addi	sp,sp,48
    80002e22:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002e24:	00005517          	auipc	a0,0x5
    80002e28:	59450513          	addi	a0,a0,1428 # 800083b8 <states.0+0xc8>
    80002e2c:	ffffd097          	auipc	ra,0xffffd
    80002e30:	712080e7          	jalr	1810(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002e34:	00005517          	auipc	a0,0x5
    80002e38:	5ac50513          	addi	a0,a0,1452 # 800083e0 <states.0+0xf0>
    80002e3c:	ffffd097          	auipc	ra,0xffffd
    80002e40:	702080e7          	jalr	1794(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002e44:	85ce                	mv	a1,s3
    80002e46:	00005517          	auipc	a0,0x5
    80002e4a:	5ba50513          	addi	a0,a0,1466 # 80008400 <states.0+0x110>
    80002e4e:	ffffd097          	auipc	ra,0xffffd
    80002e52:	73a080e7          	jalr	1850(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e56:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002e5a:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002e5e:	00005517          	auipc	a0,0x5
    80002e62:	5b250513          	addi	a0,a0,1458 # 80008410 <states.0+0x120>
    80002e66:	ffffd097          	auipc	ra,0xffffd
    80002e6a:	722080e7          	jalr	1826(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002e6e:	00005517          	auipc	a0,0x5
    80002e72:	5ba50513          	addi	a0,a0,1466 # 80008428 <states.0+0x138>
    80002e76:	ffffd097          	auipc	ra,0xffffd
    80002e7a:	6c8080e7          	jalr	1736(ra) # 8000053e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING){
    80002e7e:	fffff097          	auipc	ra,0xfffff
    80002e82:	b62080e7          	jalr	-1182(ra) # 800019e0 <myproc>
    80002e86:	d541                	beqz	a0,80002e0e <kerneltrap+0x38>
    80002e88:	fffff097          	auipc	ra,0xfffff
    80002e8c:	b58080e7          	jalr	-1192(ra) # 800019e0 <myproc>
    80002e90:	4d18                	lw	a4,24(a0)
    80002e92:	4791                	li	a5,4
    80002e94:	f6f71de3          	bne	a4,a5,80002e0e <kerneltrap+0x38>
    myproc()->accumulator+=myproc()->ps_priority;
    80002e98:	fffff097          	auipc	ra,0xfffff
    80002e9c:	b48080e7          	jalr	-1208(ra) # 800019e0 <myproc>
    80002ea0:	06853983          	ld	s3,104(a0)
    80002ea4:	fffff097          	auipc	ra,0xfffff
    80002ea8:	b3c080e7          	jalr	-1220(ra) # 800019e0 <myproc>
    80002eac:	713c                	ld	a5,96(a0)
    80002eae:	97ce                	add	a5,a5,s3
    80002eb0:	f13c                	sd	a5,96(a0)
    cfs_update();
    80002eb2:	fffff097          	auipc	ra,0xfffff
    80002eb6:	514080e7          	jalr	1300(ra) # 800023c6 <cfs_update>
    yield();
    80002eba:	fffff097          	auipc	ra,0xfffff
    80002ebe:	46c080e7          	jalr	1132(ra) # 80002326 <yield>
    80002ec2:	b7b1                	j	80002e0e <kerneltrap+0x38>

0000000080002ec4 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002ec4:	1101                	addi	sp,sp,-32
    80002ec6:	ec06                	sd	ra,24(sp)
    80002ec8:	e822                	sd	s0,16(sp)
    80002eca:	e426                	sd	s1,8(sp)
    80002ecc:	1000                	addi	s0,sp,32
    80002ece:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002ed0:	fffff097          	auipc	ra,0xfffff
    80002ed4:	b10080e7          	jalr	-1264(ra) # 800019e0 <myproc>
  switch (n) {
    80002ed8:	4795                	li	a5,5
    80002eda:	0497e163          	bltu	a5,s1,80002f1c <argraw+0x58>
    80002ede:	048a                	slli	s1,s1,0x2
    80002ee0:	00005717          	auipc	a4,0x5
    80002ee4:	58070713          	addi	a4,a4,1408 # 80008460 <states.0+0x170>
    80002ee8:	94ba                	add	s1,s1,a4
    80002eea:	409c                	lw	a5,0(s1)
    80002eec:	97ba                	add	a5,a5,a4
    80002eee:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002ef0:	6d5c                	ld	a5,152(a0)
    80002ef2:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002ef4:	60e2                	ld	ra,24(sp)
    80002ef6:	6442                	ld	s0,16(sp)
    80002ef8:	64a2                	ld	s1,8(sp)
    80002efa:	6105                	addi	sp,sp,32
    80002efc:	8082                	ret
    return p->trapframe->a1;
    80002efe:	6d5c                	ld	a5,152(a0)
    80002f00:	7fa8                	ld	a0,120(a5)
    80002f02:	bfcd                	j	80002ef4 <argraw+0x30>
    return p->trapframe->a2;
    80002f04:	6d5c                	ld	a5,152(a0)
    80002f06:	63c8                	ld	a0,128(a5)
    80002f08:	b7f5                	j	80002ef4 <argraw+0x30>
    return p->trapframe->a3;
    80002f0a:	6d5c                	ld	a5,152(a0)
    80002f0c:	67c8                	ld	a0,136(a5)
    80002f0e:	b7dd                	j	80002ef4 <argraw+0x30>
    return p->trapframe->a4;
    80002f10:	6d5c                	ld	a5,152(a0)
    80002f12:	6bc8                	ld	a0,144(a5)
    80002f14:	b7c5                	j	80002ef4 <argraw+0x30>
    return p->trapframe->a5;
    80002f16:	6d5c                	ld	a5,152(a0)
    80002f18:	6fc8                	ld	a0,152(a5)
    80002f1a:	bfe9                	j	80002ef4 <argraw+0x30>
  panic("argraw");
    80002f1c:	00005517          	auipc	a0,0x5
    80002f20:	51c50513          	addi	a0,a0,1308 # 80008438 <states.0+0x148>
    80002f24:	ffffd097          	auipc	ra,0xffffd
    80002f28:	61a080e7          	jalr	1562(ra) # 8000053e <panic>

0000000080002f2c <fetchaddr>:
{
    80002f2c:	1101                	addi	sp,sp,-32
    80002f2e:	ec06                	sd	ra,24(sp)
    80002f30:	e822                	sd	s0,16(sp)
    80002f32:	e426                	sd	s1,8(sp)
    80002f34:	e04a                	sd	s2,0(sp)
    80002f36:	1000                	addi	s0,sp,32
    80002f38:	84aa                	mv	s1,a0
    80002f3a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002f3c:	fffff097          	auipc	ra,0xfffff
    80002f40:	aa4080e7          	jalr	-1372(ra) # 800019e0 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002f44:	655c                	ld	a5,136(a0)
    80002f46:	02f4f863          	bgeu	s1,a5,80002f76 <fetchaddr+0x4a>
    80002f4a:	00848713          	addi	a4,s1,8
    80002f4e:	02e7e663          	bltu	a5,a4,80002f7a <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002f52:	46a1                	li	a3,8
    80002f54:	8626                	mv	a2,s1
    80002f56:	85ca                	mv	a1,s2
    80002f58:	6948                	ld	a0,144(a0)
    80002f5a:	ffffe097          	auipc	ra,0xffffe
    80002f5e:	79a080e7          	jalr	1946(ra) # 800016f4 <copyin>
    80002f62:	00a03533          	snez	a0,a0
    80002f66:	40a00533          	neg	a0,a0
}
    80002f6a:	60e2                	ld	ra,24(sp)
    80002f6c:	6442                	ld	s0,16(sp)
    80002f6e:	64a2                	ld	s1,8(sp)
    80002f70:	6902                	ld	s2,0(sp)
    80002f72:	6105                	addi	sp,sp,32
    80002f74:	8082                	ret
    return -1;
    80002f76:	557d                	li	a0,-1
    80002f78:	bfcd                	j	80002f6a <fetchaddr+0x3e>
    80002f7a:	557d                	li	a0,-1
    80002f7c:	b7fd                	j	80002f6a <fetchaddr+0x3e>

0000000080002f7e <fetchstr>:
{
    80002f7e:	7179                	addi	sp,sp,-48
    80002f80:	f406                	sd	ra,40(sp)
    80002f82:	f022                	sd	s0,32(sp)
    80002f84:	ec26                	sd	s1,24(sp)
    80002f86:	e84a                	sd	s2,16(sp)
    80002f88:	e44e                	sd	s3,8(sp)
    80002f8a:	1800                	addi	s0,sp,48
    80002f8c:	892a                	mv	s2,a0
    80002f8e:	84ae                	mv	s1,a1
    80002f90:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002f92:	fffff097          	auipc	ra,0xfffff
    80002f96:	a4e080e7          	jalr	-1458(ra) # 800019e0 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002f9a:	86ce                	mv	a3,s3
    80002f9c:	864a                	mv	a2,s2
    80002f9e:	85a6                	mv	a1,s1
    80002fa0:	6948                	ld	a0,144(a0)
    80002fa2:	ffffe097          	auipc	ra,0xffffe
    80002fa6:	7e0080e7          	jalr	2016(ra) # 80001782 <copyinstr>
    80002faa:	00054e63          	bltz	a0,80002fc6 <fetchstr+0x48>
  return strlen(buf);
    80002fae:	8526                	mv	a0,s1
    80002fb0:	ffffe097          	auipc	ra,0xffffe
    80002fb4:	e9e080e7          	jalr	-354(ra) # 80000e4e <strlen>
}
    80002fb8:	70a2                	ld	ra,40(sp)
    80002fba:	7402                	ld	s0,32(sp)
    80002fbc:	64e2                	ld	s1,24(sp)
    80002fbe:	6942                	ld	s2,16(sp)
    80002fc0:	69a2                	ld	s3,8(sp)
    80002fc2:	6145                	addi	sp,sp,48
    80002fc4:	8082                	ret
    return -1;
    80002fc6:	557d                	li	a0,-1
    80002fc8:	bfc5                	j	80002fb8 <fetchstr+0x3a>

0000000080002fca <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002fca:	1101                	addi	sp,sp,-32
    80002fcc:	ec06                	sd	ra,24(sp)
    80002fce:	e822                	sd	s0,16(sp)
    80002fd0:	e426                	sd	s1,8(sp)
    80002fd2:	1000                	addi	s0,sp,32
    80002fd4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002fd6:	00000097          	auipc	ra,0x0
    80002fda:	eee080e7          	jalr	-274(ra) # 80002ec4 <argraw>
    80002fde:	c088                	sw	a0,0(s1)
}
    80002fe0:	60e2                	ld	ra,24(sp)
    80002fe2:	6442                	ld	s0,16(sp)
    80002fe4:	64a2                	ld	s1,8(sp)
    80002fe6:	6105                	addi	sp,sp,32
    80002fe8:	8082                	ret

0000000080002fea <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002fea:	1101                	addi	sp,sp,-32
    80002fec:	ec06                	sd	ra,24(sp)
    80002fee:	e822                	sd	s0,16(sp)
    80002ff0:	e426                	sd	s1,8(sp)
    80002ff2:	1000                	addi	s0,sp,32
    80002ff4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ff6:	00000097          	auipc	ra,0x0
    80002ffa:	ece080e7          	jalr	-306(ra) # 80002ec4 <argraw>
    80002ffe:	e088                	sd	a0,0(s1)
}
    80003000:	60e2                	ld	ra,24(sp)
    80003002:	6442                	ld	s0,16(sp)
    80003004:	64a2                	ld	s1,8(sp)
    80003006:	6105                	addi	sp,sp,32
    80003008:	8082                	ret

000000008000300a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000300a:	7179                	addi	sp,sp,-48
    8000300c:	f406                	sd	ra,40(sp)
    8000300e:	f022                	sd	s0,32(sp)
    80003010:	ec26                	sd	s1,24(sp)
    80003012:	e84a                	sd	s2,16(sp)
    80003014:	1800                	addi	s0,sp,48
    80003016:	84ae                	mv	s1,a1
    80003018:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    8000301a:	fd840593          	addi	a1,s0,-40
    8000301e:	00000097          	auipc	ra,0x0
    80003022:	fcc080e7          	jalr	-52(ra) # 80002fea <argaddr>
  return fetchstr(addr, buf, max);
    80003026:	864a                	mv	a2,s2
    80003028:	85a6                	mv	a1,s1
    8000302a:	fd843503          	ld	a0,-40(s0)
    8000302e:	00000097          	auipc	ra,0x0
    80003032:	f50080e7          	jalr	-176(ra) # 80002f7e <fetchstr>
}
    80003036:	70a2                	ld	ra,40(sp)
    80003038:	7402                	ld	s0,32(sp)
    8000303a:	64e2                	ld	s1,24(sp)
    8000303c:	6942                	ld	s2,16(sp)
    8000303e:	6145                	addi	sp,sp,48
    80003040:	8082                	ret

0000000080003042 <syscall>:
[SYS_set_policy] sys_set_policy,
};

void
syscall(void)
{
    80003042:	1101                	addi	sp,sp,-32
    80003044:	ec06                	sd	ra,24(sp)
    80003046:	e822                	sd	s0,16(sp)
    80003048:	e426                	sd	s1,8(sp)
    8000304a:	e04a                	sd	s2,0(sp)
    8000304c:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    8000304e:	fffff097          	auipc	ra,0xfffff
    80003052:	992080e7          	jalr	-1646(ra) # 800019e0 <myproc>
    80003056:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80003058:	09853903          	ld	s2,152(a0)
    8000305c:	0a893783          	ld	a5,168(s2)
    80003060:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003064:	37fd                	addiw	a5,a5,-1
    80003066:	4765                	li	a4,25
    80003068:	00f76f63          	bltu	a4,a5,80003086 <syscall+0x44>
    8000306c:	00369713          	slli	a4,a3,0x3
    80003070:	00005797          	auipc	a5,0x5
    80003074:	40878793          	addi	a5,a5,1032 # 80008478 <syscalls>
    80003078:	97ba                	add	a5,a5,a4
    8000307a:	639c                	ld	a5,0(a5)
    8000307c:	c789                	beqz	a5,80003086 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    8000307e:	9782                	jalr	a5
    80003080:	06a93823          	sd	a0,112(s2)
    80003084:	a839                	j	800030a2 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003086:	19848613          	addi	a2,s1,408
    8000308a:	588c                	lw	a1,48(s1)
    8000308c:	00005517          	auipc	a0,0x5
    80003090:	3b450513          	addi	a0,a0,948 # 80008440 <states.0+0x150>
    80003094:	ffffd097          	auipc	ra,0xffffd
    80003098:	4f4080e7          	jalr	1268(ra) # 80000588 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000309c:	6cdc                	ld	a5,152(s1)
    8000309e:	577d                	li	a4,-1
    800030a0:	fbb8                	sd	a4,112(a5)
  }
}
    800030a2:	60e2                	ld	ra,24(sp)
    800030a4:	6442                	ld	s0,16(sp)
    800030a6:	64a2                	ld	s1,8(sp)
    800030a8:	6902                	ld	s2,0(sp)
    800030aa:	6105                	addi	sp,sp,32
    800030ac:	8082                	ret

00000000800030ae <sys_memsize>:
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
uint64
sys_memsize(void)
{
    800030ae:	1141                	addi	sp,sp,-16
    800030b0:	e406                	sd	ra,8(sp)
    800030b2:	e022                	sd	s0,0(sp)
    800030b4:	0800                	addi	s0,sp,16
  return myproc()->sz;
    800030b6:	fffff097          	auipc	ra,0xfffff
    800030ba:	92a080e7          	jalr	-1750(ra) # 800019e0 <myproc>
}
    800030be:	6548                	ld	a0,136(a0)
    800030c0:	60a2                	ld	ra,8(sp)
    800030c2:	6402                	ld	s0,0(sp)
    800030c4:	0141                	addi	sp,sp,16
    800030c6:	8082                	ret

00000000800030c8 <sys_exit>:
uint64
sys_exit(void)
{
    800030c8:	7139                	addi	sp,sp,-64
    800030ca:	fc06                	sd	ra,56(sp)
    800030cc:	f822                	sd	s0,48(sp)
    800030ce:	0080                	addi	s0,sp,64
  int n;
  char msg[32];
  argint(0, &n);
    800030d0:	fec40593          	addi	a1,s0,-20
    800030d4:	4501                	li	a0,0
    800030d6:	00000097          	auipc	ra,0x0
    800030da:	ef4080e7          	jalr	-268(ra) # 80002fca <argint>
  argstr(1,msg,32);
    800030de:	02000613          	li	a2,32
    800030e2:	fc840593          	addi	a1,s0,-56
    800030e6:	4505                	li	a0,1
    800030e8:	00000097          	auipc	ra,0x0
    800030ec:	f22080e7          	jalr	-222(ra) # 8000300a <argstr>
  exit(n, msg);
    800030f0:	fc840593          	addi	a1,s0,-56
    800030f4:	fec42503          	lw	a0,-20(s0)
    800030f8:	fffff097          	auipc	ra,0xfffff
    800030fc:	434080e7          	jalr	1076(ra) # 8000252c <exit>
  return 0;  // not reached
}
    80003100:	4501                	li	a0,0
    80003102:	70e2                	ld	ra,56(sp)
    80003104:	7442                	ld	s0,48(sp)
    80003106:	6121                	addi	sp,sp,64
    80003108:	8082                	ret

000000008000310a <sys_set_cfs_priority>:
uint64 
sys_set_cfs_priority(void) { //task6
    8000310a:	1101                	addi	sp,sp,-32
    8000310c:	ec06                	sd	ra,24(sp)
    8000310e:	e822                	sd	s0,16(sp)
    80003110:	1000                	addi	s0,sp,32
  int priority;
  argint(0, &priority);
    80003112:	fec40593          	addi	a1,s0,-20
    80003116:	4501                	li	a0,0
    80003118:	00000097          	auipc	ra,0x0
    8000311c:	eb2080e7          	jalr	-334(ra) # 80002fca <argint>
  if (priority >2 || priority<0){
    80003120:	fec42703          	lw	a4,-20(s0)
    80003124:	4789                	li	a5,2
    return -1;
    80003126:	557d                	li	a0,-1
  if (priority >2 || priority<0){
    80003128:	00e7ea63          	bltu	a5,a4,8000313c <sys_set_cfs_priority+0x32>
  }
  myproc()->cfs_priority=priority;
    8000312c:	fffff097          	auipc	ra,0xfffff
    80003130:	8b4080e7          	jalr	-1868(ra) # 800019e0 <myproc>
    80003134:	fec42783          	lw	a5,-20(s0)
    80003138:	d93c                	sw	a5,112(a0)
  //           break;
  //         case 2:
  //           decay_factor=125;
  //           break;
  //       }
  return 0;
    8000313a:	4501                	li	a0,0
}
    8000313c:	60e2                	ld	ra,24(sp)
    8000313e:	6442                	ld	s0,16(sp)
    80003140:	6105                	addi	sp,sp,32
    80003142:	8082                	ret

0000000080003144 <sys_get_cfs_stats>:

uint64
sys_get_cfs_stats(void){//task6
    80003144:	1101                	addi	sp,sp,-32
    80003146:	ec06                	sd	ra,24(sp)
    80003148:	e822                	sd	s0,16(sp)
    8000314a:	1000                	addi	s0,sp,32
  uint64 add;
  argaddr(0, &add);
    8000314c:	fe840593          	addi	a1,s0,-24
    80003150:	4501                	li	a0,0
    80003152:	00000097          	auipc	ra,0x0
    80003156:	e98080e7          	jalr	-360(ra) # 80002fea <argaddr>
  int pid;
  argint(1,&pid);
    8000315a:	fe440593          	addi	a1,s0,-28
    8000315e:	4505                	li	a0,1
    80003160:	00000097          	auipc	ra,0x0
    80003164:	e6a080e7          	jalr	-406(ra) # 80002fca <argint>
  return get_cfs_stats(add,pid);
    80003168:	fe442583          	lw	a1,-28(s0)
    8000316c:	fe843503          	ld	a0,-24(s0)
    80003170:	fffff097          	auipc	ra,0xfffff
    80003174:	794080e7          	jalr	1940(ra) # 80002904 <get_cfs_stats>
}
    80003178:	60e2                	ld	ra,24(sp)
    8000317a:	6442                	ld	s0,16(sp)
    8000317c:	6105                	addi	sp,sp,32
    8000317e:	8082                	ret

0000000080003180 <sys_set_policy>:

uint64
sys_set_policy(void){
    80003180:	1101                	addi	sp,sp,-32
    80003182:	ec06                	sd	ra,24(sp)
    80003184:	e822                	sd	s0,16(sp)
    80003186:	1000                	addi	s0,sp,32
  int policy;
  argint(0,&policy);
    80003188:	fec40593          	addi	a1,s0,-20
    8000318c:	4501                	li	a0,0
    8000318e:	00000097          	auipc	ra,0x0
    80003192:	e3c080e7          	jalr	-452(ra) # 80002fca <argint>
  if (policy >2 || policy<0){
    80003196:	fec42783          	lw	a5,-20(s0)
    8000319a:	0007869b          	sext.w	a3,a5
    8000319e:	4709                	li	a4,2
    return -1;
    800031a0:	557d                	li	a0,-1
  if (policy >2 || policy<0){
    800031a2:	00d76763          	bltu	a4,a3,800031b0 <sys_set_policy+0x30>
  }
  return set_policy(policy);
    800031a6:	853e                	mv	a0,a5
    800031a8:	fffff097          	auipc	ra,0xfffff
    800031ac:	822080e7          	jalr	-2014(ra) # 800019ca <set_policy>
}
    800031b0:	60e2                	ld	ra,24(sp)
    800031b2:	6442                	ld	s0,16(sp)
    800031b4:	6105                	addi	sp,sp,32
    800031b6:	8082                	ret

00000000800031b8 <sys_set_ps_priority>:

uint64 
sys_set_ps_priority(void) {//task5
    800031b8:	7179                	addi	sp,sp,-48
    800031ba:	f406                	sd	ra,40(sp)
    800031bc:	f022                	sd	s0,32(sp)
    800031be:	ec26                	sd	s1,24(sp)
    800031c0:	1800                	addi	s0,sp,48
  int priority;
  argint(0, &priority);
    800031c2:	fdc40593          	addi	a1,s0,-36
    800031c6:	4501                	li	a0,0
    800031c8:	00000097          	auipc	ra,0x0
    800031cc:	e02080e7          	jalr	-510(ra) # 80002fca <argint>
  if (priority < 1 || priority > 10) {
    800031d0:	fdc42483          	lw	s1,-36(s0)
    800031d4:	fff4871b          	addiw	a4,s1,-1
    800031d8:	47a5                	li	a5,9
    return -1;
    800031da:	557d                	li	a0,-1
  if (priority < 1 || priority > 10) {
    800031dc:	00e7e863          	bltu	a5,a4,800031ec <sys_set_ps_priority+0x34>
  }
  myproc()->ps_priority = priority;
    800031e0:	fffff097          	auipc	ra,0xfffff
    800031e4:	800080e7          	jalr	-2048(ra) # 800019e0 <myproc>
    800031e8:	f524                	sd	s1,104(a0)
  return 0;
    800031ea:	4501                	li	a0,0
}
    800031ec:	70a2                	ld	ra,40(sp)
    800031ee:	7402                	ld	s0,32(sp)
    800031f0:	64e2                	ld	s1,24(sp)
    800031f2:	6145                	addi	sp,sp,48
    800031f4:	8082                	ret

00000000800031f6 <sys_getpid>:

uint64
sys_getpid(void)
{
    800031f6:	1141                	addi	sp,sp,-16
    800031f8:	e406                	sd	ra,8(sp)
    800031fa:	e022                	sd	s0,0(sp)
    800031fc:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800031fe:	ffffe097          	auipc	ra,0xffffe
    80003202:	7e2080e7          	jalr	2018(ra) # 800019e0 <myproc>
}
    80003206:	5908                	lw	a0,48(a0)
    80003208:	60a2                	ld	ra,8(sp)
    8000320a:	6402                	ld	s0,0(sp)
    8000320c:	0141                	addi	sp,sp,16
    8000320e:	8082                	ret

0000000080003210 <sys_fork>:

uint64
sys_fork(void)
{
    80003210:	1141                	addi	sp,sp,-16
    80003212:	e406                	sd	ra,8(sp)
    80003214:	e022                	sd	s0,0(sp)
    80003216:	0800                	addi	s0,sp,16
  return fork();
    80003218:	fffff097          	auipc	ra,0xfffff
    8000321c:	b7e080e7          	jalr	-1154(ra) # 80001d96 <fork>
}
    80003220:	60a2                	ld	ra,8(sp)
    80003222:	6402                	ld	s0,0(sp)
    80003224:	0141                	addi	sp,sp,16
    80003226:	8082                	ret

0000000080003228 <sys_wait>:

uint64
sys_wait(void)
{
    80003228:	1101                	addi	sp,sp,-32
    8000322a:	ec06                	sd	ra,24(sp)
    8000322c:	e822                	sd	s0,16(sp)
    8000322e:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80003230:	fe840593          	addi	a1,s0,-24
    80003234:	4501                	li	a0,0
    80003236:	00000097          	auipc	ra,0x0
    8000323a:	db4080e7          	jalr	-588(ra) # 80002fea <argaddr>
  uint64 p2;
  argaddr(1, &p2);
    8000323e:	fe040593          	addi	a1,s0,-32
    80003242:	4505                	li	a0,1
    80003244:	00000097          	auipc	ra,0x0
    80003248:	da6080e7          	jalr	-602(ra) # 80002fea <argaddr>
  return wait(p,p2);
    8000324c:	fe043583          	ld	a1,-32(s0)
    80003250:	fe843503          	ld	a0,-24(s0)
    80003254:	fffff097          	auipc	ra,0xfffff
    80003258:	494080e7          	jalr	1172(ra) # 800026e8 <wait>
}
    8000325c:	60e2                	ld	ra,24(sp)
    8000325e:	6442                	ld	s0,16(sp)
    80003260:	6105                	addi	sp,sp,32
    80003262:	8082                	ret

0000000080003264 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003264:	7179                	addi	sp,sp,-48
    80003266:	f406                	sd	ra,40(sp)
    80003268:	f022                	sd	s0,32(sp)
    8000326a:	ec26                	sd	s1,24(sp)
    8000326c:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    8000326e:	fdc40593          	addi	a1,s0,-36
    80003272:	4501                	li	a0,0
    80003274:	00000097          	auipc	ra,0x0
    80003278:	d56080e7          	jalr	-682(ra) # 80002fca <argint>
  addr = myproc()->sz;
    8000327c:	ffffe097          	auipc	ra,0xffffe
    80003280:	764080e7          	jalr	1892(ra) # 800019e0 <myproc>
    80003284:	6544                	ld	s1,136(a0)
  if(growproc(n) < 0)
    80003286:	fdc42503          	lw	a0,-36(s0)
    8000328a:	fffff097          	auipc	ra,0xfffff
    8000328e:	ab0080e7          	jalr	-1360(ra) # 80001d3a <growproc>
    80003292:	00054863          	bltz	a0,800032a2 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80003296:	8526                	mv	a0,s1
    80003298:	70a2                	ld	ra,40(sp)
    8000329a:	7402                	ld	s0,32(sp)
    8000329c:	64e2                	ld	s1,24(sp)
    8000329e:	6145                	addi	sp,sp,48
    800032a0:	8082                	ret
    return -1;
    800032a2:	54fd                	li	s1,-1
    800032a4:	bfcd                	j	80003296 <sys_sbrk+0x32>

00000000800032a6 <sys_sleep>:

uint64
sys_sleep(void)
{
    800032a6:	7139                	addi	sp,sp,-64
    800032a8:	fc06                	sd	ra,56(sp)
    800032aa:	f822                	sd	s0,48(sp)
    800032ac:	f426                	sd	s1,40(sp)
    800032ae:	f04a                	sd	s2,32(sp)
    800032b0:	ec4e                	sd	s3,24(sp)
    800032b2:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800032b4:	fcc40593          	addi	a1,s0,-52
    800032b8:	4501                	li	a0,0
    800032ba:	00000097          	auipc	ra,0x0
    800032be:	d10080e7          	jalr	-752(ra) # 80002fca <argint>
  acquire(&tickslock);
    800032c2:	00014517          	auipc	a0,0x14
    800032c6:	70e50513          	addi	a0,a0,1806 # 800179d0 <tickslock>
    800032ca:	ffffe097          	auipc	ra,0xffffe
    800032ce:	90c080e7          	jalr	-1780(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    800032d2:	00005917          	auipc	s2,0x5
    800032d6:	66692903          	lw	s2,1638(s2) # 80008938 <ticks>
  while(ticks - ticks0 < n){
    800032da:	fcc42783          	lw	a5,-52(s0)
    800032de:	cf9d                	beqz	a5,8000331c <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800032e0:	00014997          	auipc	s3,0x14
    800032e4:	6f098993          	addi	s3,s3,1776 # 800179d0 <tickslock>
    800032e8:	00005497          	auipc	s1,0x5
    800032ec:	65048493          	addi	s1,s1,1616 # 80008938 <ticks>
    if(killed(myproc())){
    800032f0:	ffffe097          	auipc	ra,0xffffe
    800032f4:	6f0080e7          	jalr	1776(ra) # 800019e0 <myproc>
    800032f8:	fffff097          	auipc	ra,0xfffff
    800032fc:	3be080e7          	jalr	958(ra) # 800026b6 <killed>
    80003300:	ed15                	bnez	a0,8000333c <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80003302:	85ce                	mv	a1,s3
    80003304:	8526                	mv	a0,s1
    80003306:	fffff097          	auipc	ra,0xfffff
    8000330a:	05c080e7          	jalr	92(ra) # 80002362 <sleep>
  while(ticks - ticks0 < n){
    8000330e:	409c                	lw	a5,0(s1)
    80003310:	412787bb          	subw	a5,a5,s2
    80003314:	fcc42703          	lw	a4,-52(s0)
    80003318:	fce7ece3          	bltu	a5,a4,800032f0 <sys_sleep+0x4a>
  }
  release(&tickslock);
    8000331c:	00014517          	auipc	a0,0x14
    80003320:	6b450513          	addi	a0,a0,1716 # 800179d0 <tickslock>
    80003324:	ffffe097          	auipc	ra,0xffffe
    80003328:	966080e7          	jalr	-1690(ra) # 80000c8a <release>
  return 0;
    8000332c:	4501                	li	a0,0
}
    8000332e:	70e2                	ld	ra,56(sp)
    80003330:	7442                	ld	s0,48(sp)
    80003332:	74a2                	ld	s1,40(sp)
    80003334:	7902                	ld	s2,32(sp)
    80003336:	69e2                	ld	s3,24(sp)
    80003338:	6121                	addi	sp,sp,64
    8000333a:	8082                	ret
      release(&tickslock);
    8000333c:	00014517          	auipc	a0,0x14
    80003340:	69450513          	addi	a0,a0,1684 # 800179d0 <tickslock>
    80003344:	ffffe097          	auipc	ra,0xffffe
    80003348:	946080e7          	jalr	-1722(ra) # 80000c8a <release>
      return -1;
    8000334c:	557d                	li	a0,-1
    8000334e:	b7c5                	j	8000332e <sys_sleep+0x88>

0000000080003350 <sys_kill>:

uint64
sys_kill(void)
{
    80003350:	1101                	addi	sp,sp,-32
    80003352:	ec06                	sd	ra,24(sp)
    80003354:	e822                	sd	s0,16(sp)
    80003356:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003358:	fec40593          	addi	a1,s0,-20
    8000335c:	4501                	li	a0,0
    8000335e:	00000097          	auipc	ra,0x0
    80003362:	c6c080e7          	jalr	-916(ra) # 80002fca <argint>
  return kill(pid);
    80003366:	fec42503          	lw	a0,-20(s0)
    8000336a:	fffff097          	auipc	ra,0xfffff
    8000336e:	2ae080e7          	jalr	686(ra) # 80002618 <kill>
}
    80003372:	60e2                	ld	ra,24(sp)
    80003374:	6442                	ld	s0,16(sp)
    80003376:	6105                	addi	sp,sp,32
    80003378:	8082                	ret

000000008000337a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000337a:	1101                	addi	sp,sp,-32
    8000337c:	ec06                	sd	ra,24(sp)
    8000337e:	e822                	sd	s0,16(sp)
    80003380:	e426                	sd	s1,8(sp)
    80003382:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003384:	00014517          	auipc	a0,0x14
    80003388:	64c50513          	addi	a0,a0,1612 # 800179d0 <tickslock>
    8000338c:	ffffe097          	auipc	ra,0xffffe
    80003390:	84a080e7          	jalr	-1974(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80003394:	00005497          	auipc	s1,0x5
    80003398:	5a44a483          	lw	s1,1444(s1) # 80008938 <ticks>
  release(&tickslock);
    8000339c:	00014517          	auipc	a0,0x14
    800033a0:	63450513          	addi	a0,a0,1588 # 800179d0 <tickslock>
    800033a4:	ffffe097          	auipc	ra,0xffffe
    800033a8:	8e6080e7          	jalr	-1818(ra) # 80000c8a <release>
  return xticks;
}
    800033ac:	02049513          	slli	a0,s1,0x20
    800033b0:	9101                	srli	a0,a0,0x20
    800033b2:	60e2                	ld	ra,24(sp)
    800033b4:	6442                	ld	s0,16(sp)
    800033b6:	64a2                	ld	s1,8(sp)
    800033b8:	6105                	addi	sp,sp,32
    800033ba:	8082                	ret

00000000800033bc <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800033bc:	7179                	addi	sp,sp,-48
    800033be:	f406                	sd	ra,40(sp)
    800033c0:	f022                	sd	s0,32(sp)
    800033c2:	ec26                	sd	s1,24(sp)
    800033c4:	e84a                	sd	s2,16(sp)
    800033c6:	e44e                	sd	s3,8(sp)
    800033c8:	e052                	sd	s4,0(sp)
    800033ca:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800033cc:	00005597          	auipc	a1,0x5
    800033d0:	18458593          	addi	a1,a1,388 # 80008550 <syscalls+0xd8>
    800033d4:	00014517          	auipc	a0,0x14
    800033d8:	61450513          	addi	a0,a0,1556 # 800179e8 <bcache>
    800033dc:	ffffd097          	auipc	ra,0xffffd
    800033e0:	76a080e7          	jalr	1898(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800033e4:	0001c797          	auipc	a5,0x1c
    800033e8:	60478793          	addi	a5,a5,1540 # 8001f9e8 <bcache+0x8000>
    800033ec:	0001d717          	auipc	a4,0x1d
    800033f0:	86470713          	addi	a4,a4,-1948 # 8001fc50 <bcache+0x8268>
    800033f4:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800033f8:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800033fc:	00014497          	auipc	s1,0x14
    80003400:	60448493          	addi	s1,s1,1540 # 80017a00 <bcache+0x18>
    b->next = bcache.head.next;
    80003404:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003406:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003408:	00005a17          	auipc	s4,0x5
    8000340c:	150a0a13          	addi	s4,s4,336 # 80008558 <syscalls+0xe0>
    b->next = bcache.head.next;
    80003410:	2b893783          	ld	a5,696(s2)
    80003414:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003416:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000341a:	85d2                	mv	a1,s4
    8000341c:	01048513          	addi	a0,s1,16
    80003420:	00001097          	auipc	ra,0x1
    80003424:	4c4080e7          	jalr	1220(ra) # 800048e4 <initsleeplock>
    bcache.head.next->prev = b;
    80003428:	2b893783          	ld	a5,696(s2)
    8000342c:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000342e:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003432:	45848493          	addi	s1,s1,1112
    80003436:	fd349de3          	bne	s1,s3,80003410 <binit+0x54>
  }
}
    8000343a:	70a2                	ld	ra,40(sp)
    8000343c:	7402                	ld	s0,32(sp)
    8000343e:	64e2                	ld	s1,24(sp)
    80003440:	6942                	ld	s2,16(sp)
    80003442:	69a2                	ld	s3,8(sp)
    80003444:	6a02                	ld	s4,0(sp)
    80003446:	6145                	addi	sp,sp,48
    80003448:	8082                	ret

000000008000344a <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000344a:	7179                	addi	sp,sp,-48
    8000344c:	f406                	sd	ra,40(sp)
    8000344e:	f022                	sd	s0,32(sp)
    80003450:	ec26                	sd	s1,24(sp)
    80003452:	e84a                	sd	s2,16(sp)
    80003454:	e44e                	sd	s3,8(sp)
    80003456:	1800                	addi	s0,sp,48
    80003458:	892a                	mv	s2,a0
    8000345a:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000345c:	00014517          	auipc	a0,0x14
    80003460:	58c50513          	addi	a0,a0,1420 # 800179e8 <bcache>
    80003464:	ffffd097          	auipc	ra,0xffffd
    80003468:	772080e7          	jalr	1906(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000346c:	0001d497          	auipc	s1,0x1d
    80003470:	8344b483          	ld	s1,-1996(s1) # 8001fca0 <bcache+0x82b8>
    80003474:	0001c797          	auipc	a5,0x1c
    80003478:	7dc78793          	addi	a5,a5,2012 # 8001fc50 <bcache+0x8268>
    8000347c:	02f48f63          	beq	s1,a5,800034ba <bread+0x70>
    80003480:	873e                	mv	a4,a5
    80003482:	a021                	j	8000348a <bread+0x40>
    80003484:	68a4                	ld	s1,80(s1)
    80003486:	02e48a63          	beq	s1,a4,800034ba <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000348a:	449c                	lw	a5,8(s1)
    8000348c:	ff279ce3          	bne	a5,s2,80003484 <bread+0x3a>
    80003490:	44dc                	lw	a5,12(s1)
    80003492:	ff3799e3          	bne	a5,s3,80003484 <bread+0x3a>
      b->refcnt++;
    80003496:	40bc                	lw	a5,64(s1)
    80003498:	2785                	addiw	a5,a5,1
    8000349a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000349c:	00014517          	auipc	a0,0x14
    800034a0:	54c50513          	addi	a0,a0,1356 # 800179e8 <bcache>
    800034a4:	ffffd097          	auipc	ra,0xffffd
    800034a8:	7e6080e7          	jalr	2022(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    800034ac:	01048513          	addi	a0,s1,16
    800034b0:	00001097          	auipc	ra,0x1
    800034b4:	46e080e7          	jalr	1134(ra) # 8000491e <acquiresleep>
      return b;
    800034b8:	a8b9                	j	80003516 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800034ba:	0001c497          	auipc	s1,0x1c
    800034be:	7de4b483          	ld	s1,2014(s1) # 8001fc98 <bcache+0x82b0>
    800034c2:	0001c797          	auipc	a5,0x1c
    800034c6:	78e78793          	addi	a5,a5,1934 # 8001fc50 <bcache+0x8268>
    800034ca:	00f48863          	beq	s1,a5,800034da <bread+0x90>
    800034ce:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800034d0:	40bc                	lw	a5,64(s1)
    800034d2:	cf81                	beqz	a5,800034ea <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800034d4:	64a4                	ld	s1,72(s1)
    800034d6:	fee49de3          	bne	s1,a4,800034d0 <bread+0x86>
  panic("bget: no buffers");
    800034da:	00005517          	auipc	a0,0x5
    800034de:	08650513          	addi	a0,a0,134 # 80008560 <syscalls+0xe8>
    800034e2:	ffffd097          	auipc	ra,0xffffd
    800034e6:	05c080e7          	jalr	92(ra) # 8000053e <panic>
      b->dev = dev;
    800034ea:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800034ee:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800034f2:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800034f6:	4785                	li	a5,1
    800034f8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800034fa:	00014517          	auipc	a0,0x14
    800034fe:	4ee50513          	addi	a0,a0,1262 # 800179e8 <bcache>
    80003502:	ffffd097          	auipc	ra,0xffffd
    80003506:	788080e7          	jalr	1928(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    8000350a:	01048513          	addi	a0,s1,16
    8000350e:	00001097          	auipc	ra,0x1
    80003512:	410080e7          	jalr	1040(ra) # 8000491e <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003516:	409c                	lw	a5,0(s1)
    80003518:	cb89                	beqz	a5,8000352a <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000351a:	8526                	mv	a0,s1
    8000351c:	70a2                	ld	ra,40(sp)
    8000351e:	7402                	ld	s0,32(sp)
    80003520:	64e2                	ld	s1,24(sp)
    80003522:	6942                	ld	s2,16(sp)
    80003524:	69a2                	ld	s3,8(sp)
    80003526:	6145                	addi	sp,sp,48
    80003528:	8082                	ret
    virtio_disk_rw(b, 0);
    8000352a:	4581                	li	a1,0
    8000352c:	8526                	mv	a0,s1
    8000352e:	00003097          	auipc	ra,0x3
    80003532:	fe6080e7          	jalr	-26(ra) # 80006514 <virtio_disk_rw>
    b->valid = 1;
    80003536:	4785                	li	a5,1
    80003538:	c09c                	sw	a5,0(s1)
  return b;
    8000353a:	b7c5                	j	8000351a <bread+0xd0>

000000008000353c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000353c:	1101                	addi	sp,sp,-32
    8000353e:	ec06                	sd	ra,24(sp)
    80003540:	e822                	sd	s0,16(sp)
    80003542:	e426                	sd	s1,8(sp)
    80003544:	1000                	addi	s0,sp,32
    80003546:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003548:	0541                	addi	a0,a0,16
    8000354a:	00001097          	auipc	ra,0x1
    8000354e:	46e080e7          	jalr	1134(ra) # 800049b8 <holdingsleep>
    80003552:	cd01                	beqz	a0,8000356a <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003554:	4585                	li	a1,1
    80003556:	8526                	mv	a0,s1
    80003558:	00003097          	auipc	ra,0x3
    8000355c:	fbc080e7          	jalr	-68(ra) # 80006514 <virtio_disk_rw>
}
    80003560:	60e2                	ld	ra,24(sp)
    80003562:	6442                	ld	s0,16(sp)
    80003564:	64a2                	ld	s1,8(sp)
    80003566:	6105                	addi	sp,sp,32
    80003568:	8082                	ret
    panic("bwrite");
    8000356a:	00005517          	auipc	a0,0x5
    8000356e:	00e50513          	addi	a0,a0,14 # 80008578 <syscalls+0x100>
    80003572:	ffffd097          	auipc	ra,0xffffd
    80003576:	fcc080e7          	jalr	-52(ra) # 8000053e <panic>

000000008000357a <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000357a:	1101                	addi	sp,sp,-32
    8000357c:	ec06                	sd	ra,24(sp)
    8000357e:	e822                	sd	s0,16(sp)
    80003580:	e426                	sd	s1,8(sp)
    80003582:	e04a                	sd	s2,0(sp)
    80003584:	1000                	addi	s0,sp,32
    80003586:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003588:	01050913          	addi	s2,a0,16
    8000358c:	854a                	mv	a0,s2
    8000358e:	00001097          	auipc	ra,0x1
    80003592:	42a080e7          	jalr	1066(ra) # 800049b8 <holdingsleep>
    80003596:	c92d                	beqz	a0,80003608 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003598:	854a                	mv	a0,s2
    8000359a:	00001097          	auipc	ra,0x1
    8000359e:	3da080e7          	jalr	986(ra) # 80004974 <releasesleep>

  acquire(&bcache.lock);
    800035a2:	00014517          	auipc	a0,0x14
    800035a6:	44650513          	addi	a0,a0,1094 # 800179e8 <bcache>
    800035aa:	ffffd097          	auipc	ra,0xffffd
    800035ae:	62c080e7          	jalr	1580(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800035b2:	40bc                	lw	a5,64(s1)
    800035b4:	37fd                	addiw	a5,a5,-1
    800035b6:	0007871b          	sext.w	a4,a5
    800035ba:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800035bc:	eb05                	bnez	a4,800035ec <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800035be:	68bc                	ld	a5,80(s1)
    800035c0:	64b8                	ld	a4,72(s1)
    800035c2:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800035c4:	64bc                	ld	a5,72(s1)
    800035c6:	68b8                	ld	a4,80(s1)
    800035c8:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800035ca:	0001c797          	auipc	a5,0x1c
    800035ce:	41e78793          	addi	a5,a5,1054 # 8001f9e8 <bcache+0x8000>
    800035d2:	2b87b703          	ld	a4,696(a5)
    800035d6:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800035d8:	0001c717          	auipc	a4,0x1c
    800035dc:	67870713          	addi	a4,a4,1656 # 8001fc50 <bcache+0x8268>
    800035e0:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800035e2:	2b87b703          	ld	a4,696(a5)
    800035e6:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800035e8:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800035ec:	00014517          	auipc	a0,0x14
    800035f0:	3fc50513          	addi	a0,a0,1020 # 800179e8 <bcache>
    800035f4:	ffffd097          	auipc	ra,0xffffd
    800035f8:	696080e7          	jalr	1686(ra) # 80000c8a <release>
}
    800035fc:	60e2                	ld	ra,24(sp)
    800035fe:	6442                	ld	s0,16(sp)
    80003600:	64a2                	ld	s1,8(sp)
    80003602:	6902                	ld	s2,0(sp)
    80003604:	6105                	addi	sp,sp,32
    80003606:	8082                	ret
    panic("brelse");
    80003608:	00005517          	auipc	a0,0x5
    8000360c:	f7850513          	addi	a0,a0,-136 # 80008580 <syscalls+0x108>
    80003610:	ffffd097          	auipc	ra,0xffffd
    80003614:	f2e080e7          	jalr	-210(ra) # 8000053e <panic>

0000000080003618 <bpin>:

void
bpin(struct buf *b) {
    80003618:	1101                	addi	sp,sp,-32
    8000361a:	ec06                	sd	ra,24(sp)
    8000361c:	e822                	sd	s0,16(sp)
    8000361e:	e426                	sd	s1,8(sp)
    80003620:	1000                	addi	s0,sp,32
    80003622:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003624:	00014517          	auipc	a0,0x14
    80003628:	3c450513          	addi	a0,a0,964 # 800179e8 <bcache>
    8000362c:	ffffd097          	auipc	ra,0xffffd
    80003630:	5aa080e7          	jalr	1450(ra) # 80000bd6 <acquire>
  b->refcnt++;
    80003634:	40bc                	lw	a5,64(s1)
    80003636:	2785                	addiw	a5,a5,1
    80003638:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000363a:	00014517          	auipc	a0,0x14
    8000363e:	3ae50513          	addi	a0,a0,942 # 800179e8 <bcache>
    80003642:	ffffd097          	auipc	ra,0xffffd
    80003646:	648080e7          	jalr	1608(ra) # 80000c8a <release>
}
    8000364a:	60e2                	ld	ra,24(sp)
    8000364c:	6442                	ld	s0,16(sp)
    8000364e:	64a2                	ld	s1,8(sp)
    80003650:	6105                	addi	sp,sp,32
    80003652:	8082                	ret

0000000080003654 <bunpin>:

void
bunpin(struct buf *b) {
    80003654:	1101                	addi	sp,sp,-32
    80003656:	ec06                	sd	ra,24(sp)
    80003658:	e822                	sd	s0,16(sp)
    8000365a:	e426                	sd	s1,8(sp)
    8000365c:	1000                	addi	s0,sp,32
    8000365e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003660:	00014517          	auipc	a0,0x14
    80003664:	38850513          	addi	a0,a0,904 # 800179e8 <bcache>
    80003668:	ffffd097          	auipc	ra,0xffffd
    8000366c:	56e080e7          	jalr	1390(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80003670:	40bc                	lw	a5,64(s1)
    80003672:	37fd                	addiw	a5,a5,-1
    80003674:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003676:	00014517          	auipc	a0,0x14
    8000367a:	37250513          	addi	a0,a0,882 # 800179e8 <bcache>
    8000367e:	ffffd097          	auipc	ra,0xffffd
    80003682:	60c080e7          	jalr	1548(ra) # 80000c8a <release>
}
    80003686:	60e2                	ld	ra,24(sp)
    80003688:	6442                	ld	s0,16(sp)
    8000368a:	64a2                	ld	s1,8(sp)
    8000368c:	6105                	addi	sp,sp,32
    8000368e:	8082                	ret

0000000080003690 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003690:	1101                	addi	sp,sp,-32
    80003692:	ec06                	sd	ra,24(sp)
    80003694:	e822                	sd	s0,16(sp)
    80003696:	e426                	sd	s1,8(sp)
    80003698:	e04a                	sd	s2,0(sp)
    8000369a:	1000                	addi	s0,sp,32
    8000369c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000369e:	00d5d59b          	srliw	a1,a1,0xd
    800036a2:	0001d797          	auipc	a5,0x1d
    800036a6:	a227a783          	lw	a5,-1502(a5) # 800200c4 <sb+0x1c>
    800036aa:	9dbd                	addw	a1,a1,a5
    800036ac:	00000097          	auipc	ra,0x0
    800036b0:	d9e080e7          	jalr	-610(ra) # 8000344a <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800036b4:	0074f713          	andi	a4,s1,7
    800036b8:	4785                	li	a5,1
    800036ba:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800036be:	14ce                	slli	s1,s1,0x33
    800036c0:	90d9                	srli	s1,s1,0x36
    800036c2:	00950733          	add	a4,a0,s1
    800036c6:	05874703          	lbu	a4,88(a4)
    800036ca:	00e7f6b3          	and	a3,a5,a4
    800036ce:	c69d                	beqz	a3,800036fc <bfree+0x6c>
    800036d0:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800036d2:	94aa                	add	s1,s1,a0
    800036d4:	fff7c793          	not	a5,a5
    800036d8:	8ff9                	and	a5,a5,a4
    800036da:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800036de:	00001097          	auipc	ra,0x1
    800036e2:	120080e7          	jalr	288(ra) # 800047fe <log_write>
  brelse(bp);
    800036e6:	854a                	mv	a0,s2
    800036e8:	00000097          	auipc	ra,0x0
    800036ec:	e92080e7          	jalr	-366(ra) # 8000357a <brelse>
}
    800036f0:	60e2                	ld	ra,24(sp)
    800036f2:	6442                	ld	s0,16(sp)
    800036f4:	64a2                	ld	s1,8(sp)
    800036f6:	6902                	ld	s2,0(sp)
    800036f8:	6105                	addi	sp,sp,32
    800036fa:	8082                	ret
    panic("freeing free block");
    800036fc:	00005517          	auipc	a0,0x5
    80003700:	e8c50513          	addi	a0,a0,-372 # 80008588 <syscalls+0x110>
    80003704:	ffffd097          	auipc	ra,0xffffd
    80003708:	e3a080e7          	jalr	-454(ra) # 8000053e <panic>

000000008000370c <balloc>:
{
    8000370c:	711d                	addi	sp,sp,-96
    8000370e:	ec86                	sd	ra,88(sp)
    80003710:	e8a2                	sd	s0,80(sp)
    80003712:	e4a6                	sd	s1,72(sp)
    80003714:	e0ca                	sd	s2,64(sp)
    80003716:	fc4e                	sd	s3,56(sp)
    80003718:	f852                	sd	s4,48(sp)
    8000371a:	f456                	sd	s5,40(sp)
    8000371c:	f05a                	sd	s6,32(sp)
    8000371e:	ec5e                	sd	s7,24(sp)
    80003720:	e862                	sd	s8,16(sp)
    80003722:	e466                	sd	s9,8(sp)
    80003724:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003726:	0001d797          	auipc	a5,0x1d
    8000372a:	9867a783          	lw	a5,-1658(a5) # 800200ac <sb+0x4>
    8000372e:	10078163          	beqz	a5,80003830 <balloc+0x124>
    80003732:	8baa                	mv	s7,a0
    80003734:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003736:	0001db17          	auipc	s6,0x1d
    8000373a:	972b0b13          	addi	s6,s6,-1678 # 800200a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000373e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003740:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003742:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003744:	6c89                	lui	s9,0x2
    80003746:	a061                	j	800037ce <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003748:	974a                	add	a4,a4,s2
    8000374a:	8fd5                	or	a5,a5,a3
    8000374c:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003750:	854a                	mv	a0,s2
    80003752:	00001097          	auipc	ra,0x1
    80003756:	0ac080e7          	jalr	172(ra) # 800047fe <log_write>
        brelse(bp);
    8000375a:	854a                	mv	a0,s2
    8000375c:	00000097          	auipc	ra,0x0
    80003760:	e1e080e7          	jalr	-482(ra) # 8000357a <brelse>
  bp = bread(dev, bno);
    80003764:	85a6                	mv	a1,s1
    80003766:	855e                	mv	a0,s7
    80003768:	00000097          	auipc	ra,0x0
    8000376c:	ce2080e7          	jalr	-798(ra) # 8000344a <bread>
    80003770:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003772:	40000613          	li	a2,1024
    80003776:	4581                	li	a1,0
    80003778:	05850513          	addi	a0,a0,88
    8000377c:	ffffd097          	auipc	ra,0xffffd
    80003780:	556080e7          	jalr	1366(ra) # 80000cd2 <memset>
  log_write(bp);
    80003784:	854a                	mv	a0,s2
    80003786:	00001097          	auipc	ra,0x1
    8000378a:	078080e7          	jalr	120(ra) # 800047fe <log_write>
  brelse(bp);
    8000378e:	854a                	mv	a0,s2
    80003790:	00000097          	auipc	ra,0x0
    80003794:	dea080e7          	jalr	-534(ra) # 8000357a <brelse>
}
    80003798:	8526                	mv	a0,s1
    8000379a:	60e6                	ld	ra,88(sp)
    8000379c:	6446                	ld	s0,80(sp)
    8000379e:	64a6                	ld	s1,72(sp)
    800037a0:	6906                	ld	s2,64(sp)
    800037a2:	79e2                	ld	s3,56(sp)
    800037a4:	7a42                	ld	s4,48(sp)
    800037a6:	7aa2                	ld	s5,40(sp)
    800037a8:	7b02                	ld	s6,32(sp)
    800037aa:	6be2                	ld	s7,24(sp)
    800037ac:	6c42                	ld	s8,16(sp)
    800037ae:	6ca2                	ld	s9,8(sp)
    800037b0:	6125                	addi	sp,sp,96
    800037b2:	8082                	ret
    brelse(bp);
    800037b4:	854a                	mv	a0,s2
    800037b6:	00000097          	auipc	ra,0x0
    800037ba:	dc4080e7          	jalr	-572(ra) # 8000357a <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800037be:	015c87bb          	addw	a5,s9,s5
    800037c2:	00078a9b          	sext.w	s5,a5
    800037c6:	004b2703          	lw	a4,4(s6)
    800037ca:	06eaf363          	bgeu	s5,a4,80003830 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    800037ce:	41fad79b          	sraiw	a5,s5,0x1f
    800037d2:	0137d79b          	srliw	a5,a5,0x13
    800037d6:	015787bb          	addw	a5,a5,s5
    800037da:	40d7d79b          	sraiw	a5,a5,0xd
    800037de:	01cb2583          	lw	a1,28(s6)
    800037e2:	9dbd                	addw	a1,a1,a5
    800037e4:	855e                	mv	a0,s7
    800037e6:	00000097          	auipc	ra,0x0
    800037ea:	c64080e7          	jalr	-924(ra) # 8000344a <bread>
    800037ee:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037f0:	004b2503          	lw	a0,4(s6)
    800037f4:	000a849b          	sext.w	s1,s5
    800037f8:	8662                	mv	a2,s8
    800037fa:	faa4fde3          	bgeu	s1,a0,800037b4 <balloc+0xa8>
      m = 1 << (bi % 8);
    800037fe:	41f6579b          	sraiw	a5,a2,0x1f
    80003802:	01d7d69b          	srliw	a3,a5,0x1d
    80003806:	00c6873b          	addw	a4,a3,a2
    8000380a:	00777793          	andi	a5,a4,7
    8000380e:	9f95                	subw	a5,a5,a3
    80003810:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003814:	4037571b          	sraiw	a4,a4,0x3
    80003818:	00e906b3          	add	a3,s2,a4
    8000381c:	0586c683          	lbu	a3,88(a3)
    80003820:	00d7f5b3          	and	a1,a5,a3
    80003824:	d195                	beqz	a1,80003748 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003826:	2605                	addiw	a2,a2,1
    80003828:	2485                	addiw	s1,s1,1
    8000382a:	fd4618e3          	bne	a2,s4,800037fa <balloc+0xee>
    8000382e:	b759                	j	800037b4 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003830:	00005517          	auipc	a0,0x5
    80003834:	d7050513          	addi	a0,a0,-656 # 800085a0 <syscalls+0x128>
    80003838:	ffffd097          	auipc	ra,0xffffd
    8000383c:	d50080e7          	jalr	-688(ra) # 80000588 <printf>
  return 0;
    80003840:	4481                	li	s1,0
    80003842:	bf99                	j	80003798 <balloc+0x8c>

0000000080003844 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003844:	7179                	addi	sp,sp,-48
    80003846:	f406                	sd	ra,40(sp)
    80003848:	f022                	sd	s0,32(sp)
    8000384a:	ec26                	sd	s1,24(sp)
    8000384c:	e84a                	sd	s2,16(sp)
    8000384e:	e44e                	sd	s3,8(sp)
    80003850:	e052                	sd	s4,0(sp)
    80003852:	1800                	addi	s0,sp,48
    80003854:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003856:	47ad                	li	a5,11
    80003858:	02b7e763          	bltu	a5,a1,80003886 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    8000385c:	02059493          	slli	s1,a1,0x20
    80003860:	9081                	srli	s1,s1,0x20
    80003862:	048a                	slli	s1,s1,0x2
    80003864:	94aa                	add	s1,s1,a0
    80003866:	0504a903          	lw	s2,80(s1)
    8000386a:	06091e63          	bnez	s2,800038e6 <bmap+0xa2>
      addr = balloc(ip->dev);
    8000386e:	4108                	lw	a0,0(a0)
    80003870:	00000097          	auipc	ra,0x0
    80003874:	e9c080e7          	jalr	-356(ra) # 8000370c <balloc>
    80003878:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000387c:	06090563          	beqz	s2,800038e6 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003880:	0524a823          	sw	s2,80(s1)
    80003884:	a08d                	j	800038e6 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003886:	ff45849b          	addiw	s1,a1,-12
    8000388a:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000388e:	0ff00793          	li	a5,255
    80003892:	08e7e563          	bltu	a5,a4,8000391c <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003896:	08052903          	lw	s2,128(a0)
    8000389a:	00091d63          	bnez	s2,800038b4 <bmap+0x70>
      addr = balloc(ip->dev);
    8000389e:	4108                	lw	a0,0(a0)
    800038a0:	00000097          	auipc	ra,0x0
    800038a4:	e6c080e7          	jalr	-404(ra) # 8000370c <balloc>
    800038a8:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800038ac:	02090d63          	beqz	s2,800038e6 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800038b0:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800038b4:	85ca                	mv	a1,s2
    800038b6:	0009a503          	lw	a0,0(s3)
    800038ba:	00000097          	auipc	ra,0x0
    800038be:	b90080e7          	jalr	-1136(ra) # 8000344a <bread>
    800038c2:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800038c4:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800038c8:	02049593          	slli	a1,s1,0x20
    800038cc:	9181                	srli	a1,a1,0x20
    800038ce:	058a                	slli	a1,a1,0x2
    800038d0:	00b784b3          	add	s1,a5,a1
    800038d4:	0004a903          	lw	s2,0(s1)
    800038d8:	02090063          	beqz	s2,800038f8 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800038dc:	8552                	mv	a0,s4
    800038de:	00000097          	auipc	ra,0x0
    800038e2:	c9c080e7          	jalr	-868(ra) # 8000357a <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800038e6:	854a                	mv	a0,s2
    800038e8:	70a2                	ld	ra,40(sp)
    800038ea:	7402                	ld	s0,32(sp)
    800038ec:	64e2                	ld	s1,24(sp)
    800038ee:	6942                	ld	s2,16(sp)
    800038f0:	69a2                	ld	s3,8(sp)
    800038f2:	6a02                	ld	s4,0(sp)
    800038f4:	6145                	addi	sp,sp,48
    800038f6:	8082                	ret
      addr = balloc(ip->dev);
    800038f8:	0009a503          	lw	a0,0(s3)
    800038fc:	00000097          	auipc	ra,0x0
    80003900:	e10080e7          	jalr	-496(ra) # 8000370c <balloc>
    80003904:	0005091b          	sext.w	s2,a0
      if(addr){
    80003908:	fc090ae3          	beqz	s2,800038dc <bmap+0x98>
        a[bn] = addr;
    8000390c:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003910:	8552                	mv	a0,s4
    80003912:	00001097          	auipc	ra,0x1
    80003916:	eec080e7          	jalr	-276(ra) # 800047fe <log_write>
    8000391a:	b7c9                	j	800038dc <bmap+0x98>
  panic("bmap: out of range");
    8000391c:	00005517          	auipc	a0,0x5
    80003920:	c9c50513          	addi	a0,a0,-868 # 800085b8 <syscalls+0x140>
    80003924:	ffffd097          	auipc	ra,0xffffd
    80003928:	c1a080e7          	jalr	-998(ra) # 8000053e <panic>

000000008000392c <iget>:
{
    8000392c:	7179                	addi	sp,sp,-48
    8000392e:	f406                	sd	ra,40(sp)
    80003930:	f022                	sd	s0,32(sp)
    80003932:	ec26                	sd	s1,24(sp)
    80003934:	e84a                	sd	s2,16(sp)
    80003936:	e44e                	sd	s3,8(sp)
    80003938:	e052                	sd	s4,0(sp)
    8000393a:	1800                	addi	s0,sp,48
    8000393c:	89aa                	mv	s3,a0
    8000393e:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003940:	0001c517          	auipc	a0,0x1c
    80003944:	78850513          	addi	a0,a0,1928 # 800200c8 <itable>
    80003948:	ffffd097          	auipc	ra,0xffffd
    8000394c:	28e080e7          	jalr	654(ra) # 80000bd6 <acquire>
  empty = 0;
    80003950:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003952:	0001c497          	auipc	s1,0x1c
    80003956:	78e48493          	addi	s1,s1,1934 # 800200e0 <itable+0x18>
    8000395a:	0001e697          	auipc	a3,0x1e
    8000395e:	21668693          	addi	a3,a3,534 # 80021b70 <log>
    80003962:	a039                	j	80003970 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003964:	02090b63          	beqz	s2,8000399a <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003968:	08848493          	addi	s1,s1,136
    8000396c:	02d48a63          	beq	s1,a3,800039a0 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003970:	449c                	lw	a5,8(s1)
    80003972:	fef059e3          	blez	a5,80003964 <iget+0x38>
    80003976:	4098                	lw	a4,0(s1)
    80003978:	ff3716e3          	bne	a4,s3,80003964 <iget+0x38>
    8000397c:	40d8                	lw	a4,4(s1)
    8000397e:	ff4713e3          	bne	a4,s4,80003964 <iget+0x38>
      ip->ref++;
    80003982:	2785                	addiw	a5,a5,1
    80003984:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003986:	0001c517          	auipc	a0,0x1c
    8000398a:	74250513          	addi	a0,a0,1858 # 800200c8 <itable>
    8000398e:	ffffd097          	auipc	ra,0xffffd
    80003992:	2fc080e7          	jalr	764(ra) # 80000c8a <release>
      return ip;
    80003996:	8926                	mv	s2,s1
    80003998:	a03d                	j	800039c6 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000399a:	f7f9                	bnez	a5,80003968 <iget+0x3c>
    8000399c:	8926                	mv	s2,s1
    8000399e:	b7e9                	j	80003968 <iget+0x3c>
  if(empty == 0)
    800039a0:	02090c63          	beqz	s2,800039d8 <iget+0xac>
  ip->dev = dev;
    800039a4:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800039a8:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800039ac:	4785                	li	a5,1
    800039ae:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800039b2:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800039b6:	0001c517          	auipc	a0,0x1c
    800039ba:	71250513          	addi	a0,a0,1810 # 800200c8 <itable>
    800039be:	ffffd097          	auipc	ra,0xffffd
    800039c2:	2cc080e7          	jalr	716(ra) # 80000c8a <release>
}
    800039c6:	854a                	mv	a0,s2
    800039c8:	70a2                	ld	ra,40(sp)
    800039ca:	7402                	ld	s0,32(sp)
    800039cc:	64e2                	ld	s1,24(sp)
    800039ce:	6942                	ld	s2,16(sp)
    800039d0:	69a2                	ld	s3,8(sp)
    800039d2:	6a02                	ld	s4,0(sp)
    800039d4:	6145                	addi	sp,sp,48
    800039d6:	8082                	ret
    panic("iget: no inodes");
    800039d8:	00005517          	auipc	a0,0x5
    800039dc:	bf850513          	addi	a0,a0,-1032 # 800085d0 <syscalls+0x158>
    800039e0:	ffffd097          	auipc	ra,0xffffd
    800039e4:	b5e080e7          	jalr	-1186(ra) # 8000053e <panic>

00000000800039e8 <fsinit>:
fsinit(int dev) {
    800039e8:	7179                	addi	sp,sp,-48
    800039ea:	f406                	sd	ra,40(sp)
    800039ec:	f022                	sd	s0,32(sp)
    800039ee:	ec26                	sd	s1,24(sp)
    800039f0:	e84a                	sd	s2,16(sp)
    800039f2:	e44e                	sd	s3,8(sp)
    800039f4:	1800                	addi	s0,sp,48
    800039f6:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800039f8:	4585                	li	a1,1
    800039fa:	00000097          	auipc	ra,0x0
    800039fe:	a50080e7          	jalr	-1456(ra) # 8000344a <bread>
    80003a02:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003a04:	0001c997          	auipc	s3,0x1c
    80003a08:	6a498993          	addi	s3,s3,1700 # 800200a8 <sb>
    80003a0c:	02000613          	li	a2,32
    80003a10:	05850593          	addi	a1,a0,88
    80003a14:	854e                	mv	a0,s3
    80003a16:	ffffd097          	auipc	ra,0xffffd
    80003a1a:	318080e7          	jalr	792(ra) # 80000d2e <memmove>
  brelse(bp);
    80003a1e:	8526                	mv	a0,s1
    80003a20:	00000097          	auipc	ra,0x0
    80003a24:	b5a080e7          	jalr	-1190(ra) # 8000357a <brelse>
  if(sb.magic != FSMAGIC)
    80003a28:	0009a703          	lw	a4,0(s3)
    80003a2c:	102037b7          	lui	a5,0x10203
    80003a30:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003a34:	02f71263          	bne	a4,a5,80003a58 <fsinit+0x70>
  initlog(dev, &sb);
    80003a38:	0001c597          	auipc	a1,0x1c
    80003a3c:	67058593          	addi	a1,a1,1648 # 800200a8 <sb>
    80003a40:	854a                	mv	a0,s2
    80003a42:	00001097          	auipc	ra,0x1
    80003a46:	b40080e7          	jalr	-1216(ra) # 80004582 <initlog>
}
    80003a4a:	70a2                	ld	ra,40(sp)
    80003a4c:	7402                	ld	s0,32(sp)
    80003a4e:	64e2                	ld	s1,24(sp)
    80003a50:	6942                	ld	s2,16(sp)
    80003a52:	69a2                	ld	s3,8(sp)
    80003a54:	6145                	addi	sp,sp,48
    80003a56:	8082                	ret
    panic("invalid file system");
    80003a58:	00005517          	auipc	a0,0x5
    80003a5c:	b8850513          	addi	a0,a0,-1144 # 800085e0 <syscalls+0x168>
    80003a60:	ffffd097          	auipc	ra,0xffffd
    80003a64:	ade080e7          	jalr	-1314(ra) # 8000053e <panic>

0000000080003a68 <iinit>:
{
    80003a68:	7179                	addi	sp,sp,-48
    80003a6a:	f406                	sd	ra,40(sp)
    80003a6c:	f022                	sd	s0,32(sp)
    80003a6e:	ec26                	sd	s1,24(sp)
    80003a70:	e84a                	sd	s2,16(sp)
    80003a72:	e44e                	sd	s3,8(sp)
    80003a74:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003a76:	00005597          	auipc	a1,0x5
    80003a7a:	b8258593          	addi	a1,a1,-1150 # 800085f8 <syscalls+0x180>
    80003a7e:	0001c517          	auipc	a0,0x1c
    80003a82:	64a50513          	addi	a0,a0,1610 # 800200c8 <itable>
    80003a86:	ffffd097          	auipc	ra,0xffffd
    80003a8a:	0c0080e7          	jalr	192(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003a8e:	0001c497          	auipc	s1,0x1c
    80003a92:	66248493          	addi	s1,s1,1634 # 800200f0 <itable+0x28>
    80003a96:	0001e997          	auipc	s3,0x1e
    80003a9a:	0ea98993          	addi	s3,s3,234 # 80021b80 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003a9e:	00005917          	auipc	s2,0x5
    80003aa2:	b6290913          	addi	s2,s2,-1182 # 80008600 <syscalls+0x188>
    80003aa6:	85ca                	mv	a1,s2
    80003aa8:	8526                	mv	a0,s1
    80003aaa:	00001097          	auipc	ra,0x1
    80003aae:	e3a080e7          	jalr	-454(ra) # 800048e4 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003ab2:	08848493          	addi	s1,s1,136
    80003ab6:	ff3498e3          	bne	s1,s3,80003aa6 <iinit+0x3e>
}
    80003aba:	70a2                	ld	ra,40(sp)
    80003abc:	7402                	ld	s0,32(sp)
    80003abe:	64e2                	ld	s1,24(sp)
    80003ac0:	6942                	ld	s2,16(sp)
    80003ac2:	69a2                	ld	s3,8(sp)
    80003ac4:	6145                	addi	sp,sp,48
    80003ac6:	8082                	ret

0000000080003ac8 <ialloc>:
{
    80003ac8:	715d                	addi	sp,sp,-80
    80003aca:	e486                	sd	ra,72(sp)
    80003acc:	e0a2                	sd	s0,64(sp)
    80003ace:	fc26                	sd	s1,56(sp)
    80003ad0:	f84a                	sd	s2,48(sp)
    80003ad2:	f44e                	sd	s3,40(sp)
    80003ad4:	f052                	sd	s4,32(sp)
    80003ad6:	ec56                	sd	s5,24(sp)
    80003ad8:	e85a                	sd	s6,16(sp)
    80003ada:	e45e                	sd	s7,8(sp)
    80003adc:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003ade:	0001c717          	auipc	a4,0x1c
    80003ae2:	5d672703          	lw	a4,1494(a4) # 800200b4 <sb+0xc>
    80003ae6:	4785                	li	a5,1
    80003ae8:	04e7fa63          	bgeu	a5,a4,80003b3c <ialloc+0x74>
    80003aec:	8aaa                	mv	s5,a0
    80003aee:	8bae                	mv	s7,a1
    80003af0:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003af2:	0001ca17          	auipc	s4,0x1c
    80003af6:	5b6a0a13          	addi	s4,s4,1462 # 800200a8 <sb>
    80003afa:	00048b1b          	sext.w	s6,s1
    80003afe:	0044d793          	srli	a5,s1,0x4
    80003b02:	018a2583          	lw	a1,24(s4)
    80003b06:	9dbd                	addw	a1,a1,a5
    80003b08:	8556                	mv	a0,s5
    80003b0a:	00000097          	auipc	ra,0x0
    80003b0e:	940080e7          	jalr	-1728(ra) # 8000344a <bread>
    80003b12:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003b14:	05850993          	addi	s3,a0,88
    80003b18:	00f4f793          	andi	a5,s1,15
    80003b1c:	079a                	slli	a5,a5,0x6
    80003b1e:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003b20:	00099783          	lh	a5,0(s3)
    80003b24:	c3a1                	beqz	a5,80003b64 <ialloc+0x9c>
    brelse(bp);
    80003b26:	00000097          	auipc	ra,0x0
    80003b2a:	a54080e7          	jalr	-1452(ra) # 8000357a <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b2e:	0485                	addi	s1,s1,1
    80003b30:	00ca2703          	lw	a4,12(s4)
    80003b34:	0004879b          	sext.w	a5,s1
    80003b38:	fce7e1e3          	bltu	a5,a4,80003afa <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003b3c:	00005517          	auipc	a0,0x5
    80003b40:	acc50513          	addi	a0,a0,-1332 # 80008608 <syscalls+0x190>
    80003b44:	ffffd097          	auipc	ra,0xffffd
    80003b48:	a44080e7          	jalr	-1468(ra) # 80000588 <printf>
  return 0;
    80003b4c:	4501                	li	a0,0
}
    80003b4e:	60a6                	ld	ra,72(sp)
    80003b50:	6406                	ld	s0,64(sp)
    80003b52:	74e2                	ld	s1,56(sp)
    80003b54:	7942                	ld	s2,48(sp)
    80003b56:	79a2                	ld	s3,40(sp)
    80003b58:	7a02                	ld	s4,32(sp)
    80003b5a:	6ae2                	ld	s5,24(sp)
    80003b5c:	6b42                	ld	s6,16(sp)
    80003b5e:	6ba2                	ld	s7,8(sp)
    80003b60:	6161                	addi	sp,sp,80
    80003b62:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003b64:	04000613          	li	a2,64
    80003b68:	4581                	li	a1,0
    80003b6a:	854e                	mv	a0,s3
    80003b6c:	ffffd097          	auipc	ra,0xffffd
    80003b70:	166080e7          	jalr	358(ra) # 80000cd2 <memset>
      dip->type = type;
    80003b74:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003b78:	854a                	mv	a0,s2
    80003b7a:	00001097          	auipc	ra,0x1
    80003b7e:	c84080e7          	jalr	-892(ra) # 800047fe <log_write>
      brelse(bp);
    80003b82:	854a                	mv	a0,s2
    80003b84:	00000097          	auipc	ra,0x0
    80003b88:	9f6080e7          	jalr	-1546(ra) # 8000357a <brelse>
      return iget(dev, inum);
    80003b8c:	85da                	mv	a1,s6
    80003b8e:	8556                	mv	a0,s5
    80003b90:	00000097          	auipc	ra,0x0
    80003b94:	d9c080e7          	jalr	-612(ra) # 8000392c <iget>
    80003b98:	bf5d                	j	80003b4e <ialloc+0x86>

0000000080003b9a <iupdate>:
{
    80003b9a:	1101                	addi	sp,sp,-32
    80003b9c:	ec06                	sd	ra,24(sp)
    80003b9e:	e822                	sd	s0,16(sp)
    80003ba0:	e426                	sd	s1,8(sp)
    80003ba2:	e04a                	sd	s2,0(sp)
    80003ba4:	1000                	addi	s0,sp,32
    80003ba6:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003ba8:	415c                	lw	a5,4(a0)
    80003baa:	0047d79b          	srliw	a5,a5,0x4
    80003bae:	0001c597          	auipc	a1,0x1c
    80003bb2:	5125a583          	lw	a1,1298(a1) # 800200c0 <sb+0x18>
    80003bb6:	9dbd                	addw	a1,a1,a5
    80003bb8:	4108                	lw	a0,0(a0)
    80003bba:	00000097          	auipc	ra,0x0
    80003bbe:	890080e7          	jalr	-1904(ra) # 8000344a <bread>
    80003bc2:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003bc4:	05850793          	addi	a5,a0,88
    80003bc8:	40c8                	lw	a0,4(s1)
    80003bca:	893d                	andi	a0,a0,15
    80003bcc:	051a                	slli	a0,a0,0x6
    80003bce:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003bd0:	04449703          	lh	a4,68(s1)
    80003bd4:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003bd8:	04649703          	lh	a4,70(s1)
    80003bdc:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003be0:	04849703          	lh	a4,72(s1)
    80003be4:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003be8:	04a49703          	lh	a4,74(s1)
    80003bec:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003bf0:	44f8                	lw	a4,76(s1)
    80003bf2:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003bf4:	03400613          	li	a2,52
    80003bf8:	05048593          	addi	a1,s1,80
    80003bfc:	0531                	addi	a0,a0,12
    80003bfe:	ffffd097          	auipc	ra,0xffffd
    80003c02:	130080e7          	jalr	304(ra) # 80000d2e <memmove>
  log_write(bp);
    80003c06:	854a                	mv	a0,s2
    80003c08:	00001097          	auipc	ra,0x1
    80003c0c:	bf6080e7          	jalr	-1034(ra) # 800047fe <log_write>
  brelse(bp);
    80003c10:	854a                	mv	a0,s2
    80003c12:	00000097          	auipc	ra,0x0
    80003c16:	968080e7          	jalr	-1688(ra) # 8000357a <brelse>
}
    80003c1a:	60e2                	ld	ra,24(sp)
    80003c1c:	6442                	ld	s0,16(sp)
    80003c1e:	64a2                	ld	s1,8(sp)
    80003c20:	6902                	ld	s2,0(sp)
    80003c22:	6105                	addi	sp,sp,32
    80003c24:	8082                	ret

0000000080003c26 <idup>:
{
    80003c26:	1101                	addi	sp,sp,-32
    80003c28:	ec06                	sd	ra,24(sp)
    80003c2a:	e822                	sd	s0,16(sp)
    80003c2c:	e426                	sd	s1,8(sp)
    80003c2e:	1000                	addi	s0,sp,32
    80003c30:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003c32:	0001c517          	auipc	a0,0x1c
    80003c36:	49650513          	addi	a0,a0,1174 # 800200c8 <itable>
    80003c3a:	ffffd097          	auipc	ra,0xffffd
    80003c3e:	f9c080e7          	jalr	-100(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003c42:	449c                	lw	a5,8(s1)
    80003c44:	2785                	addiw	a5,a5,1
    80003c46:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003c48:	0001c517          	auipc	a0,0x1c
    80003c4c:	48050513          	addi	a0,a0,1152 # 800200c8 <itable>
    80003c50:	ffffd097          	auipc	ra,0xffffd
    80003c54:	03a080e7          	jalr	58(ra) # 80000c8a <release>
}
    80003c58:	8526                	mv	a0,s1
    80003c5a:	60e2                	ld	ra,24(sp)
    80003c5c:	6442                	ld	s0,16(sp)
    80003c5e:	64a2                	ld	s1,8(sp)
    80003c60:	6105                	addi	sp,sp,32
    80003c62:	8082                	ret

0000000080003c64 <ilock>:
{
    80003c64:	1101                	addi	sp,sp,-32
    80003c66:	ec06                	sd	ra,24(sp)
    80003c68:	e822                	sd	s0,16(sp)
    80003c6a:	e426                	sd	s1,8(sp)
    80003c6c:	e04a                	sd	s2,0(sp)
    80003c6e:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003c70:	c115                	beqz	a0,80003c94 <ilock+0x30>
    80003c72:	84aa                	mv	s1,a0
    80003c74:	451c                	lw	a5,8(a0)
    80003c76:	00f05f63          	blez	a5,80003c94 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003c7a:	0541                	addi	a0,a0,16
    80003c7c:	00001097          	auipc	ra,0x1
    80003c80:	ca2080e7          	jalr	-862(ra) # 8000491e <acquiresleep>
  if(ip->valid == 0){
    80003c84:	40bc                	lw	a5,64(s1)
    80003c86:	cf99                	beqz	a5,80003ca4 <ilock+0x40>
}
    80003c88:	60e2                	ld	ra,24(sp)
    80003c8a:	6442                	ld	s0,16(sp)
    80003c8c:	64a2                	ld	s1,8(sp)
    80003c8e:	6902                	ld	s2,0(sp)
    80003c90:	6105                	addi	sp,sp,32
    80003c92:	8082                	ret
    panic("ilock");
    80003c94:	00005517          	auipc	a0,0x5
    80003c98:	98c50513          	addi	a0,a0,-1652 # 80008620 <syscalls+0x1a8>
    80003c9c:	ffffd097          	auipc	ra,0xffffd
    80003ca0:	8a2080e7          	jalr	-1886(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003ca4:	40dc                	lw	a5,4(s1)
    80003ca6:	0047d79b          	srliw	a5,a5,0x4
    80003caa:	0001c597          	auipc	a1,0x1c
    80003cae:	4165a583          	lw	a1,1046(a1) # 800200c0 <sb+0x18>
    80003cb2:	9dbd                	addw	a1,a1,a5
    80003cb4:	4088                	lw	a0,0(s1)
    80003cb6:	fffff097          	auipc	ra,0xfffff
    80003cba:	794080e7          	jalr	1940(ra) # 8000344a <bread>
    80003cbe:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003cc0:	05850593          	addi	a1,a0,88
    80003cc4:	40dc                	lw	a5,4(s1)
    80003cc6:	8bbd                	andi	a5,a5,15
    80003cc8:	079a                	slli	a5,a5,0x6
    80003cca:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003ccc:	00059783          	lh	a5,0(a1)
    80003cd0:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003cd4:	00259783          	lh	a5,2(a1)
    80003cd8:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003cdc:	00459783          	lh	a5,4(a1)
    80003ce0:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003ce4:	00659783          	lh	a5,6(a1)
    80003ce8:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003cec:	459c                	lw	a5,8(a1)
    80003cee:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003cf0:	03400613          	li	a2,52
    80003cf4:	05b1                	addi	a1,a1,12
    80003cf6:	05048513          	addi	a0,s1,80
    80003cfa:	ffffd097          	auipc	ra,0xffffd
    80003cfe:	034080e7          	jalr	52(ra) # 80000d2e <memmove>
    brelse(bp);
    80003d02:	854a                	mv	a0,s2
    80003d04:	00000097          	auipc	ra,0x0
    80003d08:	876080e7          	jalr	-1930(ra) # 8000357a <brelse>
    ip->valid = 1;
    80003d0c:	4785                	li	a5,1
    80003d0e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003d10:	04449783          	lh	a5,68(s1)
    80003d14:	fbb5                	bnez	a5,80003c88 <ilock+0x24>
      panic("ilock: no type");
    80003d16:	00005517          	auipc	a0,0x5
    80003d1a:	91250513          	addi	a0,a0,-1774 # 80008628 <syscalls+0x1b0>
    80003d1e:	ffffd097          	auipc	ra,0xffffd
    80003d22:	820080e7          	jalr	-2016(ra) # 8000053e <panic>

0000000080003d26 <iunlock>:
{
    80003d26:	1101                	addi	sp,sp,-32
    80003d28:	ec06                	sd	ra,24(sp)
    80003d2a:	e822                	sd	s0,16(sp)
    80003d2c:	e426                	sd	s1,8(sp)
    80003d2e:	e04a                	sd	s2,0(sp)
    80003d30:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003d32:	c905                	beqz	a0,80003d62 <iunlock+0x3c>
    80003d34:	84aa                	mv	s1,a0
    80003d36:	01050913          	addi	s2,a0,16
    80003d3a:	854a                	mv	a0,s2
    80003d3c:	00001097          	auipc	ra,0x1
    80003d40:	c7c080e7          	jalr	-900(ra) # 800049b8 <holdingsleep>
    80003d44:	cd19                	beqz	a0,80003d62 <iunlock+0x3c>
    80003d46:	449c                	lw	a5,8(s1)
    80003d48:	00f05d63          	blez	a5,80003d62 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003d4c:	854a                	mv	a0,s2
    80003d4e:	00001097          	auipc	ra,0x1
    80003d52:	c26080e7          	jalr	-986(ra) # 80004974 <releasesleep>
}
    80003d56:	60e2                	ld	ra,24(sp)
    80003d58:	6442                	ld	s0,16(sp)
    80003d5a:	64a2                	ld	s1,8(sp)
    80003d5c:	6902                	ld	s2,0(sp)
    80003d5e:	6105                	addi	sp,sp,32
    80003d60:	8082                	ret
    panic("iunlock");
    80003d62:	00005517          	auipc	a0,0x5
    80003d66:	8d650513          	addi	a0,a0,-1834 # 80008638 <syscalls+0x1c0>
    80003d6a:	ffffc097          	auipc	ra,0xffffc
    80003d6e:	7d4080e7          	jalr	2004(ra) # 8000053e <panic>

0000000080003d72 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003d72:	7179                	addi	sp,sp,-48
    80003d74:	f406                	sd	ra,40(sp)
    80003d76:	f022                	sd	s0,32(sp)
    80003d78:	ec26                	sd	s1,24(sp)
    80003d7a:	e84a                	sd	s2,16(sp)
    80003d7c:	e44e                	sd	s3,8(sp)
    80003d7e:	e052                	sd	s4,0(sp)
    80003d80:	1800                	addi	s0,sp,48
    80003d82:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003d84:	05050493          	addi	s1,a0,80
    80003d88:	08050913          	addi	s2,a0,128
    80003d8c:	a021                	j	80003d94 <itrunc+0x22>
    80003d8e:	0491                	addi	s1,s1,4
    80003d90:	01248d63          	beq	s1,s2,80003daa <itrunc+0x38>
    if(ip->addrs[i]){
    80003d94:	408c                	lw	a1,0(s1)
    80003d96:	dde5                	beqz	a1,80003d8e <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003d98:	0009a503          	lw	a0,0(s3)
    80003d9c:	00000097          	auipc	ra,0x0
    80003da0:	8f4080e7          	jalr	-1804(ra) # 80003690 <bfree>
      ip->addrs[i] = 0;
    80003da4:	0004a023          	sw	zero,0(s1)
    80003da8:	b7dd                	j	80003d8e <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003daa:	0809a583          	lw	a1,128(s3)
    80003dae:	e185                	bnez	a1,80003dce <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003db0:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003db4:	854e                	mv	a0,s3
    80003db6:	00000097          	auipc	ra,0x0
    80003dba:	de4080e7          	jalr	-540(ra) # 80003b9a <iupdate>
}
    80003dbe:	70a2                	ld	ra,40(sp)
    80003dc0:	7402                	ld	s0,32(sp)
    80003dc2:	64e2                	ld	s1,24(sp)
    80003dc4:	6942                	ld	s2,16(sp)
    80003dc6:	69a2                	ld	s3,8(sp)
    80003dc8:	6a02                	ld	s4,0(sp)
    80003dca:	6145                	addi	sp,sp,48
    80003dcc:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003dce:	0009a503          	lw	a0,0(s3)
    80003dd2:	fffff097          	auipc	ra,0xfffff
    80003dd6:	678080e7          	jalr	1656(ra) # 8000344a <bread>
    80003dda:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003ddc:	05850493          	addi	s1,a0,88
    80003de0:	45850913          	addi	s2,a0,1112
    80003de4:	a021                	j	80003dec <itrunc+0x7a>
    80003de6:	0491                	addi	s1,s1,4
    80003de8:	01248b63          	beq	s1,s2,80003dfe <itrunc+0x8c>
      if(a[j])
    80003dec:	408c                	lw	a1,0(s1)
    80003dee:	dde5                	beqz	a1,80003de6 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003df0:	0009a503          	lw	a0,0(s3)
    80003df4:	00000097          	auipc	ra,0x0
    80003df8:	89c080e7          	jalr	-1892(ra) # 80003690 <bfree>
    80003dfc:	b7ed                	j	80003de6 <itrunc+0x74>
    brelse(bp);
    80003dfe:	8552                	mv	a0,s4
    80003e00:	fffff097          	auipc	ra,0xfffff
    80003e04:	77a080e7          	jalr	1914(ra) # 8000357a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003e08:	0809a583          	lw	a1,128(s3)
    80003e0c:	0009a503          	lw	a0,0(s3)
    80003e10:	00000097          	auipc	ra,0x0
    80003e14:	880080e7          	jalr	-1920(ra) # 80003690 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003e18:	0809a023          	sw	zero,128(s3)
    80003e1c:	bf51                	j	80003db0 <itrunc+0x3e>

0000000080003e1e <iput>:
{
    80003e1e:	1101                	addi	sp,sp,-32
    80003e20:	ec06                	sd	ra,24(sp)
    80003e22:	e822                	sd	s0,16(sp)
    80003e24:	e426                	sd	s1,8(sp)
    80003e26:	e04a                	sd	s2,0(sp)
    80003e28:	1000                	addi	s0,sp,32
    80003e2a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003e2c:	0001c517          	auipc	a0,0x1c
    80003e30:	29c50513          	addi	a0,a0,668 # 800200c8 <itable>
    80003e34:	ffffd097          	auipc	ra,0xffffd
    80003e38:	da2080e7          	jalr	-606(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e3c:	4498                	lw	a4,8(s1)
    80003e3e:	4785                	li	a5,1
    80003e40:	02f70363          	beq	a4,a5,80003e66 <iput+0x48>
  ip->ref--;
    80003e44:	449c                	lw	a5,8(s1)
    80003e46:	37fd                	addiw	a5,a5,-1
    80003e48:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003e4a:	0001c517          	auipc	a0,0x1c
    80003e4e:	27e50513          	addi	a0,a0,638 # 800200c8 <itable>
    80003e52:	ffffd097          	auipc	ra,0xffffd
    80003e56:	e38080e7          	jalr	-456(ra) # 80000c8a <release>
}
    80003e5a:	60e2                	ld	ra,24(sp)
    80003e5c:	6442                	ld	s0,16(sp)
    80003e5e:	64a2                	ld	s1,8(sp)
    80003e60:	6902                	ld	s2,0(sp)
    80003e62:	6105                	addi	sp,sp,32
    80003e64:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e66:	40bc                	lw	a5,64(s1)
    80003e68:	dff1                	beqz	a5,80003e44 <iput+0x26>
    80003e6a:	04a49783          	lh	a5,74(s1)
    80003e6e:	fbf9                	bnez	a5,80003e44 <iput+0x26>
    acquiresleep(&ip->lock);
    80003e70:	01048913          	addi	s2,s1,16
    80003e74:	854a                	mv	a0,s2
    80003e76:	00001097          	auipc	ra,0x1
    80003e7a:	aa8080e7          	jalr	-1368(ra) # 8000491e <acquiresleep>
    release(&itable.lock);
    80003e7e:	0001c517          	auipc	a0,0x1c
    80003e82:	24a50513          	addi	a0,a0,586 # 800200c8 <itable>
    80003e86:	ffffd097          	auipc	ra,0xffffd
    80003e8a:	e04080e7          	jalr	-508(ra) # 80000c8a <release>
    itrunc(ip);
    80003e8e:	8526                	mv	a0,s1
    80003e90:	00000097          	auipc	ra,0x0
    80003e94:	ee2080e7          	jalr	-286(ra) # 80003d72 <itrunc>
    ip->type = 0;
    80003e98:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003e9c:	8526                	mv	a0,s1
    80003e9e:	00000097          	auipc	ra,0x0
    80003ea2:	cfc080e7          	jalr	-772(ra) # 80003b9a <iupdate>
    ip->valid = 0;
    80003ea6:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003eaa:	854a                	mv	a0,s2
    80003eac:	00001097          	auipc	ra,0x1
    80003eb0:	ac8080e7          	jalr	-1336(ra) # 80004974 <releasesleep>
    acquire(&itable.lock);
    80003eb4:	0001c517          	auipc	a0,0x1c
    80003eb8:	21450513          	addi	a0,a0,532 # 800200c8 <itable>
    80003ebc:	ffffd097          	auipc	ra,0xffffd
    80003ec0:	d1a080e7          	jalr	-742(ra) # 80000bd6 <acquire>
    80003ec4:	b741                	j	80003e44 <iput+0x26>

0000000080003ec6 <iunlockput>:
{
    80003ec6:	1101                	addi	sp,sp,-32
    80003ec8:	ec06                	sd	ra,24(sp)
    80003eca:	e822                	sd	s0,16(sp)
    80003ecc:	e426                	sd	s1,8(sp)
    80003ece:	1000                	addi	s0,sp,32
    80003ed0:	84aa                	mv	s1,a0
  iunlock(ip);
    80003ed2:	00000097          	auipc	ra,0x0
    80003ed6:	e54080e7          	jalr	-428(ra) # 80003d26 <iunlock>
  iput(ip);
    80003eda:	8526                	mv	a0,s1
    80003edc:	00000097          	auipc	ra,0x0
    80003ee0:	f42080e7          	jalr	-190(ra) # 80003e1e <iput>
}
    80003ee4:	60e2                	ld	ra,24(sp)
    80003ee6:	6442                	ld	s0,16(sp)
    80003ee8:	64a2                	ld	s1,8(sp)
    80003eea:	6105                	addi	sp,sp,32
    80003eec:	8082                	ret

0000000080003eee <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003eee:	1141                	addi	sp,sp,-16
    80003ef0:	e422                	sd	s0,8(sp)
    80003ef2:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003ef4:	411c                	lw	a5,0(a0)
    80003ef6:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003ef8:	415c                	lw	a5,4(a0)
    80003efa:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003efc:	04451783          	lh	a5,68(a0)
    80003f00:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003f04:	04a51783          	lh	a5,74(a0)
    80003f08:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003f0c:	04c56783          	lwu	a5,76(a0)
    80003f10:	e99c                	sd	a5,16(a1)
}
    80003f12:	6422                	ld	s0,8(sp)
    80003f14:	0141                	addi	sp,sp,16
    80003f16:	8082                	ret

0000000080003f18 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f18:	457c                	lw	a5,76(a0)
    80003f1a:	0ed7e963          	bltu	a5,a3,8000400c <readi+0xf4>
{
    80003f1e:	7159                	addi	sp,sp,-112
    80003f20:	f486                	sd	ra,104(sp)
    80003f22:	f0a2                	sd	s0,96(sp)
    80003f24:	eca6                	sd	s1,88(sp)
    80003f26:	e8ca                	sd	s2,80(sp)
    80003f28:	e4ce                	sd	s3,72(sp)
    80003f2a:	e0d2                	sd	s4,64(sp)
    80003f2c:	fc56                	sd	s5,56(sp)
    80003f2e:	f85a                	sd	s6,48(sp)
    80003f30:	f45e                	sd	s7,40(sp)
    80003f32:	f062                	sd	s8,32(sp)
    80003f34:	ec66                	sd	s9,24(sp)
    80003f36:	e86a                	sd	s10,16(sp)
    80003f38:	e46e                	sd	s11,8(sp)
    80003f3a:	1880                	addi	s0,sp,112
    80003f3c:	8b2a                	mv	s6,a0
    80003f3e:	8bae                	mv	s7,a1
    80003f40:	8a32                	mv	s4,a2
    80003f42:	84b6                	mv	s1,a3
    80003f44:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003f46:	9f35                	addw	a4,a4,a3
    return 0;
    80003f48:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003f4a:	0ad76063          	bltu	a4,a3,80003fea <readi+0xd2>
  if(off + n > ip->size)
    80003f4e:	00e7f463          	bgeu	a5,a4,80003f56 <readi+0x3e>
    n = ip->size - off;
    80003f52:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f56:	0a0a8963          	beqz	s5,80004008 <readi+0xf0>
    80003f5a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f5c:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003f60:	5c7d                	li	s8,-1
    80003f62:	a82d                	j	80003f9c <readi+0x84>
    80003f64:	020d1d93          	slli	s11,s10,0x20
    80003f68:	020ddd93          	srli	s11,s11,0x20
    80003f6c:	05890793          	addi	a5,s2,88
    80003f70:	86ee                	mv	a3,s11
    80003f72:	963e                	add	a2,a2,a5
    80003f74:	85d2                	mv	a1,s4
    80003f76:	855e                	mv	a0,s7
    80003f78:	fffff097          	auipc	ra,0xfffff
    80003f7c:	8e0080e7          	jalr	-1824(ra) # 80002858 <either_copyout>
    80003f80:	05850d63          	beq	a0,s8,80003fda <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003f84:	854a                	mv	a0,s2
    80003f86:	fffff097          	auipc	ra,0xfffff
    80003f8a:	5f4080e7          	jalr	1524(ra) # 8000357a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f8e:	013d09bb          	addw	s3,s10,s3
    80003f92:	009d04bb          	addw	s1,s10,s1
    80003f96:	9a6e                	add	s4,s4,s11
    80003f98:	0559f763          	bgeu	s3,s5,80003fe6 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003f9c:	00a4d59b          	srliw	a1,s1,0xa
    80003fa0:	855a                	mv	a0,s6
    80003fa2:	00000097          	auipc	ra,0x0
    80003fa6:	8a2080e7          	jalr	-1886(ra) # 80003844 <bmap>
    80003faa:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003fae:	cd85                	beqz	a1,80003fe6 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003fb0:	000b2503          	lw	a0,0(s6)
    80003fb4:	fffff097          	auipc	ra,0xfffff
    80003fb8:	496080e7          	jalr	1174(ra) # 8000344a <bread>
    80003fbc:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fbe:	3ff4f613          	andi	a2,s1,1023
    80003fc2:	40cc87bb          	subw	a5,s9,a2
    80003fc6:	413a873b          	subw	a4,s5,s3
    80003fca:	8d3e                	mv	s10,a5
    80003fcc:	2781                	sext.w	a5,a5
    80003fce:	0007069b          	sext.w	a3,a4
    80003fd2:	f8f6f9e3          	bgeu	a3,a5,80003f64 <readi+0x4c>
    80003fd6:	8d3a                	mv	s10,a4
    80003fd8:	b771                	j	80003f64 <readi+0x4c>
      brelse(bp);
    80003fda:	854a                	mv	a0,s2
    80003fdc:	fffff097          	auipc	ra,0xfffff
    80003fe0:	59e080e7          	jalr	1438(ra) # 8000357a <brelse>
      tot = -1;
    80003fe4:	59fd                	li	s3,-1
  }
  return tot;
    80003fe6:	0009851b          	sext.w	a0,s3
}
    80003fea:	70a6                	ld	ra,104(sp)
    80003fec:	7406                	ld	s0,96(sp)
    80003fee:	64e6                	ld	s1,88(sp)
    80003ff0:	6946                	ld	s2,80(sp)
    80003ff2:	69a6                	ld	s3,72(sp)
    80003ff4:	6a06                	ld	s4,64(sp)
    80003ff6:	7ae2                	ld	s5,56(sp)
    80003ff8:	7b42                	ld	s6,48(sp)
    80003ffa:	7ba2                	ld	s7,40(sp)
    80003ffc:	7c02                	ld	s8,32(sp)
    80003ffe:	6ce2                	ld	s9,24(sp)
    80004000:	6d42                	ld	s10,16(sp)
    80004002:	6da2                	ld	s11,8(sp)
    80004004:	6165                	addi	sp,sp,112
    80004006:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004008:	89d6                	mv	s3,s5
    8000400a:	bff1                	j	80003fe6 <readi+0xce>
    return 0;
    8000400c:	4501                	li	a0,0
}
    8000400e:	8082                	ret

0000000080004010 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004010:	457c                	lw	a5,76(a0)
    80004012:	10d7e863          	bltu	a5,a3,80004122 <writei+0x112>
{
    80004016:	7159                	addi	sp,sp,-112
    80004018:	f486                	sd	ra,104(sp)
    8000401a:	f0a2                	sd	s0,96(sp)
    8000401c:	eca6                	sd	s1,88(sp)
    8000401e:	e8ca                	sd	s2,80(sp)
    80004020:	e4ce                	sd	s3,72(sp)
    80004022:	e0d2                	sd	s4,64(sp)
    80004024:	fc56                	sd	s5,56(sp)
    80004026:	f85a                	sd	s6,48(sp)
    80004028:	f45e                	sd	s7,40(sp)
    8000402a:	f062                	sd	s8,32(sp)
    8000402c:	ec66                	sd	s9,24(sp)
    8000402e:	e86a                	sd	s10,16(sp)
    80004030:	e46e                	sd	s11,8(sp)
    80004032:	1880                	addi	s0,sp,112
    80004034:	8aaa                	mv	s5,a0
    80004036:	8bae                	mv	s7,a1
    80004038:	8a32                	mv	s4,a2
    8000403a:	8936                	mv	s2,a3
    8000403c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000403e:	00e687bb          	addw	a5,a3,a4
    80004042:	0ed7e263          	bltu	a5,a3,80004126 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004046:	00043737          	lui	a4,0x43
    8000404a:	0ef76063          	bltu	a4,a5,8000412a <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000404e:	0c0b0863          	beqz	s6,8000411e <writei+0x10e>
    80004052:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004054:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004058:	5c7d                	li	s8,-1
    8000405a:	a091                	j	8000409e <writei+0x8e>
    8000405c:	020d1d93          	slli	s11,s10,0x20
    80004060:	020ddd93          	srli	s11,s11,0x20
    80004064:	05848793          	addi	a5,s1,88
    80004068:	86ee                	mv	a3,s11
    8000406a:	8652                	mv	a2,s4
    8000406c:	85de                	mv	a1,s7
    8000406e:	953e                	add	a0,a0,a5
    80004070:	fffff097          	auipc	ra,0xfffff
    80004074:	83e080e7          	jalr	-1986(ra) # 800028ae <either_copyin>
    80004078:	07850263          	beq	a0,s8,800040dc <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000407c:	8526                	mv	a0,s1
    8000407e:	00000097          	auipc	ra,0x0
    80004082:	780080e7          	jalr	1920(ra) # 800047fe <log_write>
    brelse(bp);
    80004086:	8526                	mv	a0,s1
    80004088:	fffff097          	auipc	ra,0xfffff
    8000408c:	4f2080e7          	jalr	1266(ra) # 8000357a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004090:	013d09bb          	addw	s3,s10,s3
    80004094:	012d093b          	addw	s2,s10,s2
    80004098:	9a6e                	add	s4,s4,s11
    8000409a:	0569f663          	bgeu	s3,s6,800040e6 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    8000409e:	00a9559b          	srliw	a1,s2,0xa
    800040a2:	8556                	mv	a0,s5
    800040a4:	fffff097          	auipc	ra,0xfffff
    800040a8:	7a0080e7          	jalr	1952(ra) # 80003844 <bmap>
    800040ac:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800040b0:	c99d                	beqz	a1,800040e6 <writei+0xd6>
    bp = bread(ip->dev, addr);
    800040b2:	000aa503          	lw	a0,0(s5)
    800040b6:	fffff097          	auipc	ra,0xfffff
    800040ba:	394080e7          	jalr	916(ra) # 8000344a <bread>
    800040be:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800040c0:	3ff97513          	andi	a0,s2,1023
    800040c4:	40ac87bb          	subw	a5,s9,a0
    800040c8:	413b073b          	subw	a4,s6,s3
    800040cc:	8d3e                	mv	s10,a5
    800040ce:	2781                	sext.w	a5,a5
    800040d0:	0007069b          	sext.w	a3,a4
    800040d4:	f8f6f4e3          	bgeu	a3,a5,8000405c <writei+0x4c>
    800040d8:	8d3a                	mv	s10,a4
    800040da:	b749                	j	8000405c <writei+0x4c>
      brelse(bp);
    800040dc:	8526                	mv	a0,s1
    800040de:	fffff097          	auipc	ra,0xfffff
    800040e2:	49c080e7          	jalr	1180(ra) # 8000357a <brelse>
  }

  if(off > ip->size)
    800040e6:	04caa783          	lw	a5,76(s5)
    800040ea:	0127f463          	bgeu	a5,s2,800040f2 <writei+0xe2>
    ip->size = off;
    800040ee:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800040f2:	8556                	mv	a0,s5
    800040f4:	00000097          	auipc	ra,0x0
    800040f8:	aa6080e7          	jalr	-1370(ra) # 80003b9a <iupdate>

  return tot;
    800040fc:	0009851b          	sext.w	a0,s3
}
    80004100:	70a6                	ld	ra,104(sp)
    80004102:	7406                	ld	s0,96(sp)
    80004104:	64e6                	ld	s1,88(sp)
    80004106:	6946                	ld	s2,80(sp)
    80004108:	69a6                	ld	s3,72(sp)
    8000410a:	6a06                	ld	s4,64(sp)
    8000410c:	7ae2                	ld	s5,56(sp)
    8000410e:	7b42                	ld	s6,48(sp)
    80004110:	7ba2                	ld	s7,40(sp)
    80004112:	7c02                	ld	s8,32(sp)
    80004114:	6ce2                	ld	s9,24(sp)
    80004116:	6d42                	ld	s10,16(sp)
    80004118:	6da2                	ld	s11,8(sp)
    8000411a:	6165                	addi	sp,sp,112
    8000411c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000411e:	89da                	mv	s3,s6
    80004120:	bfc9                	j	800040f2 <writei+0xe2>
    return -1;
    80004122:	557d                	li	a0,-1
}
    80004124:	8082                	ret
    return -1;
    80004126:	557d                	li	a0,-1
    80004128:	bfe1                	j	80004100 <writei+0xf0>
    return -1;
    8000412a:	557d                	li	a0,-1
    8000412c:	bfd1                	j	80004100 <writei+0xf0>

000000008000412e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000412e:	1141                	addi	sp,sp,-16
    80004130:	e406                	sd	ra,8(sp)
    80004132:	e022                	sd	s0,0(sp)
    80004134:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004136:	4639                	li	a2,14
    80004138:	ffffd097          	auipc	ra,0xffffd
    8000413c:	c6a080e7          	jalr	-918(ra) # 80000da2 <strncmp>
}
    80004140:	60a2                	ld	ra,8(sp)
    80004142:	6402                	ld	s0,0(sp)
    80004144:	0141                	addi	sp,sp,16
    80004146:	8082                	ret

0000000080004148 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004148:	7139                	addi	sp,sp,-64
    8000414a:	fc06                	sd	ra,56(sp)
    8000414c:	f822                	sd	s0,48(sp)
    8000414e:	f426                	sd	s1,40(sp)
    80004150:	f04a                	sd	s2,32(sp)
    80004152:	ec4e                	sd	s3,24(sp)
    80004154:	e852                	sd	s4,16(sp)
    80004156:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004158:	04451703          	lh	a4,68(a0)
    8000415c:	4785                	li	a5,1
    8000415e:	00f71a63          	bne	a4,a5,80004172 <dirlookup+0x2a>
    80004162:	892a                	mv	s2,a0
    80004164:	89ae                	mv	s3,a1
    80004166:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004168:	457c                	lw	a5,76(a0)
    8000416a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000416c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000416e:	e79d                	bnez	a5,8000419c <dirlookup+0x54>
    80004170:	a8a5                	j	800041e8 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004172:	00004517          	auipc	a0,0x4
    80004176:	4ce50513          	addi	a0,a0,1230 # 80008640 <syscalls+0x1c8>
    8000417a:	ffffc097          	auipc	ra,0xffffc
    8000417e:	3c4080e7          	jalr	964(ra) # 8000053e <panic>
      panic("dirlookup read");
    80004182:	00004517          	auipc	a0,0x4
    80004186:	4d650513          	addi	a0,a0,1238 # 80008658 <syscalls+0x1e0>
    8000418a:	ffffc097          	auipc	ra,0xffffc
    8000418e:	3b4080e7          	jalr	948(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004192:	24c1                	addiw	s1,s1,16
    80004194:	04c92783          	lw	a5,76(s2)
    80004198:	04f4f763          	bgeu	s1,a5,800041e6 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000419c:	4741                	li	a4,16
    8000419e:	86a6                	mv	a3,s1
    800041a0:	fc040613          	addi	a2,s0,-64
    800041a4:	4581                	li	a1,0
    800041a6:	854a                	mv	a0,s2
    800041a8:	00000097          	auipc	ra,0x0
    800041ac:	d70080e7          	jalr	-656(ra) # 80003f18 <readi>
    800041b0:	47c1                	li	a5,16
    800041b2:	fcf518e3          	bne	a0,a5,80004182 <dirlookup+0x3a>
    if(de.inum == 0)
    800041b6:	fc045783          	lhu	a5,-64(s0)
    800041ba:	dfe1                	beqz	a5,80004192 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800041bc:	fc240593          	addi	a1,s0,-62
    800041c0:	854e                	mv	a0,s3
    800041c2:	00000097          	auipc	ra,0x0
    800041c6:	f6c080e7          	jalr	-148(ra) # 8000412e <namecmp>
    800041ca:	f561                	bnez	a0,80004192 <dirlookup+0x4a>
      if(poff)
    800041cc:	000a0463          	beqz	s4,800041d4 <dirlookup+0x8c>
        *poff = off;
    800041d0:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800041d4:	fc045583          	lhu	a1,-64(s0)
    800041d8:	00092503          	lw	a0,0(s2)
    800041dc:	fffff097          	auipc	ra,0xfffff
    800041e0:	750080e7          	jalr	1872(ra) # 8000392c <iget>
    800041e4:	a011                	j	800041e8 <dirlookup+0xa0>
  return 0;
    800041e6:	4501                	li	a0,0
}
    800041e8:	70e2                	ld	ra,56(sp)
    800041ea:	7442                	ld	s0,48(sp)
    800041ec:	74a2                	ld	s1,40(sp)
    800041ee:	7902                	ld	s2,32(sp)
    800041f0:	69e2                	ld	s3,24(sp)
    800041f2:	6a42                	ld	s4,16(sp)
    800041f4:	6121                	addi	sp,sp,64
    800041f6:	8082                	ret

00000000800041f8 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800041f8:	711d                	addi	sp,sp,-96
    800041fa:	ec86                	sd	ra,88(sp)
    800041fc:	e8a2                	sd	s0,80(sp)
    800041fe:	e4a6                	sd	s1,72(sp)
    80004200:	e0ca                	sd	s2,64(sp)
    80004202:	fc4e                	sd	s3,56(sp)
    80004204:	f852                	sd	s4,48(sp)
    80004206:	f456                	sd	s5,40(sp)
    80004208:	f05a                	sd	s6,32(sp)
    8000420a:	ec5e                	sd	s7,24(sp)
    8000420c:	e862                	sd	s8,16(sp)
    8000420e:	e466                	sd	s9,8(sp)
    80004210:	1080                	addi	s0,sp,96
    80004212:	84aa                	mv	s1,a0
    80004214:	8aae                	mv	s5,a1
    80004216:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004218:	00054703          	lbu	a4,0(a0)
    8000421c:	02f00793          	li	a5,47
    80004220:	02f70363          	beq	a4,a5,80004246 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004224:	ffffd097          	auipc	ra,0xffffd
    80004228:	7bc080e7          	jalr	1980(ra) # 800019e0 <myproc>
    8000422c:	19053503          	ld	a0,400(a0)
    80004230:	00000097          	auipc	ra,0x0
    80004234:	9f6080e7          	jalr	-1546(ra) # 80003c26 <idup>
    80004238:	89aa                	mv	s3,a0
  while(*path == '/')
    8000423a:	02f00913          	li	s2,47
  len = path - s;
    8000423e:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004240:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004242:	4b85                	li	s7,1
    80004244:	a865                	j	800042fc <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004246:	4585                	li	a1,1
    80004248:	4505                	li	a0,1
    8000424a:	fffff097          	auipc	ra,0xfffff
    8000424e:	6e2080e7          	jalr	1762(ra) # 8000392c <iget>
    80004252:	89aa                	mv	s3,a0
    80004254:	b7dd                	j	8000423a <namex+0x42>
      iunlockput(ip);
    80004256:	854e                	mv	a0,s3
    80004258:	00000097          	auipc	ra,0x0
    8000425c:	c6e080e7          	jalr	-914(ra) # 80003ec6 <iunlockput>
      return 0;
    80004260:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004262:	854e                	mv	a0,s3
    80004264:	60e6                	ld	ra,88(sp)
    80004266:	6446                	ld	s0,80(sp)
    80004268:	64a6                	ld	s1,72(sp)
    8000426a:	6906                	ld	s2,64(sp)
    8000426c:	79e2                	ld	s3,56(sp)
    8000426e:	7a42                	ld	s4,48(sp)
    80004270:	7aa2                	ld	s5,40(sp)
    80004272:	7b02                	ld	s6,32(sp)
    80004274:	6be2                	ld	s7,24(sp)
    80004276:	6c42                	ld	s8,16(sp)
    80004278:	6ca2                	ld	s9,8(sp)
    8000427a:	6125                	addi	sp,sp,96
    8000427c:	8082                	ret
      iunlock(ip);
    8000427e:	854e                	mv	a0,s3
    80004280:	00000097          	auipc	ra,0x0
    80004284:	aa6080e7          	jalr	-1370(ra) # 80003d26 <iunlock>
      return ip;
    80004288:	bfe9                	j	80004262 <namex+0x6a>
      iunlockput(ip);
    8000428a:	854e                	mv	a0,s3
    8000428c:	00000097          	auipc	ra,0x0
    80004290:	c3a080e7          	jalr	-966(ra) # 80003ec6 <iunlockput>
      return 0;
    80004294:	89e6                	mv	s3,s9
    80004296:	b7f1                	j	80004262 <namex+0x6a>
  len = path - s;
    80004298:	40b48633          	sub	a2,s1,a1
    8000429c:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800042a0:	099c5463          	bge	s8,s9,80004328 <namex+0x130>
    memmove(name, s, DIRSIZ);
    800042a4:	4639                	li	a2,14
    800042a6:	8552                	mv	a0,s4
    800042a8:	ffffd097          	auipc	ra,0xffffd
    800042ac:	a86080e7          	jalr	-1402(ra) # 80000d2e <memmove>
  while(*path == '/')
    800042b0:	0004c783          	lbu	a5,0(s1)
    800042b4:	01279763          	bne	a5,s2,800042c2 <namex+0xca>
    path++;
    800042b8:	0485                	addi	s1,s1,1
  while(*path == '/')
    800042ba:	0004c783          	lbu	a5,0(s1)
    800042be:	ff278de3          	beq	a5,s2,800042b8 <namex+0xc0>
    ilock(ip);
    800042c2:	854e                	mv	a0,s3
    800042c4:	00000097          	auipc	ra,0x0
    800042c8:	9a0080e7          	jalr	-1632(ra) # 80003c64 <ilock>
    if(ip->type != T_DIR){
    800042cc:	04499783          	lh	a5,68(s3)
    800042d0:	f97793e3          	bne	a5,s7,80004256 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800042d4:	000a8563          	beqz	s5,800042de <namex+0xe6>
    800042d8:	0004c783          	lbu	a5,0(s1)
    800042dc:	d3cd                	beqz	a5,8000427e <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800042de:	865a                	mv	a2,s6
    800042e0:	85d2                	mv	a1,s4
    800042e2:	854e                	mv	a0,s3
    800042e4:	00000097          	auipc	ra,0x0
    800042e8:	e64080e7          	jalr	-412(ra) # 80004148 <dirlookup>
    800042ec:	8caa                	mv	s9,a0
    800042ee:	dd51                	beqz	a0,8000428a <namex+0x92>
    iunlockput(ip);
    800042f0:	854e                	mv	a0,s3
    800042f2:	00000097          	auipc	ra,0x0
    800042f6:	bd4080e7          	jalr	-1068(ra) # 80003ec6 <iunlockput>
    ip = next;
    800042fa:	89e6                	mv	s3,s9
  while(*path == '/')
    800042fc:	0004c783          	lbu	a5,0(s1)
    80004300:	05279763          	bne	a5,s2,8000434e <namex+0x156>
    path++;
    80004304:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004306:	0004c783          	lbu	a5,0(s1)
    8000430a:	ff278de3          	beq	a5,s2,80004304 <namex+0x10c>
  if(*path == 0)
    8000430e:	c79d                	beqz	a5,8000433c <namex+0x144>
    path++;
    80004310:	85a6                	mv	a1,s1
  len = path - s;
    80004312:	8cda                	mv	s9,s6
    80004314:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004316:	01278963          	beq	a5,s2,80004328 <namex+0x130>
    8000431a:	dfbd                	beqz	a5,80004298 <namex+0xa0>
    path++;
    8000431c:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000431e:	0004c783          	lbu	a5,0(s1)
    80004322:	ff279ce3          	bne	a5,s2,8000431a <namex+0x122>
    80004326:	bf8d                	j	80004298 <namex+0xa0>
    memmove(name, s, len);
    80004328:	2601                	sext.w	a2,a2
    8000432a:	8552                	mv	a0,s4
    8000432c:	ffffd097          	auipc	ra,0xffffd
    80004330:	a02080e7          	jalr	-1534(ra) # 80000d2e <memmove>
    name[len] = 0;
    80004334:	9cd2                	add	s9,s9,s4
    80004336:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000433a:	bf9d                	j	800042b0 <namex+0xb8>
  if(nameiparent){
    8000433c:	f20a83e3          	beqz	s5,80004262 <namex+0x6a>
    iput(ip);
    80004340:	854e                	mv	a0,s3
    80004342:	00000097          	auipc	ra,0x0
    80004346:	adc080e7          	jalr	-1316(ra) # 80003e1e <iput>
    return 0;
    8000434a:	4981                	li	s3,0
    8000434c:	bf19                	j	80004262 <namex+0x6a>
  if(*path == 0)
    8000434e:	d7fd                	beqz	a5,8000433c <namex+0x144>
  while(*path != '/' && *path != 0)
    80004350:	0004c783          	lbu	a5,0(s1)
    80004354:	85a6                	mv	a1,s1
    80004356:	b7d1                	j	8000431a <namex+0x122>

0000000080004358 <dirlink>:
{
    80004358:	7139                	addi	sp,sp,-64
    8000435a:	fc06                	sd	ra,56(sp)
    8000435c:	f822                	sd	s0,48(sp)
    8000435e:	f426                	sd	s1,40(sp)
    80004360:	f04a                	sd	s2,32(sp)
    80004362:	ec4e                	sd	s3,24(sp)
    80004364:	e852                	sd	s4,16(sp)
    80004366:	0080                	addi	s0,sp,64
    80004368:	892a                	mv	s2,a0
    8000436a:	8a2e                	mv	s4,a1
    8000436c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000436e:	4601                	li	a2,0
    80004370:	00000097          	auipc	ra,0x0
    80004374:	dd8080e7          	jalr	-552(ra) # 80004148 <dirlookup>
    80004378:	e93d                	bnez	a0,800043ee <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000437a:	04c92483          	lw	s1,76(s2)
    8000437e:	c49d                	beqz	s1,800043ac <dirlink+0x54>
    80004380:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004382:	4741                	li	a4,16
    80004384:	86a6                	mv	a3,s1
    80004386:	fc040613          	addi	a2,s0,-64
    8000438a:	4581                	li	a1,0
    8000438c:	854a                	mv	a0,s2
    8000438e:	00000097          	auipc	ra,0x0
    80004392:	b8a080e7          	jalr	-1142(ra) # 80003f18 <readi>
    80004396:	47c1                	li	a5,16
    80004398:	06f51163          	bne	a0,a5,800043fa <dirlink+0xa2>
    if(de.inum == 0)
    8000439c:	fc045783          	lhu	a5,-64(s0)
    800043a0:	c791                	beqz	a5,800043ac <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043a2:	24c1                	addiw	s1,s1,16
    800043a4:	04c92783          	lw	a5,76(s2)
    800043a8:	fcf4ede3          	bltu	s1,a5,80004382 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800043ac:	4639                	li	a2,14
    800043ae:	85d2                	mv	a1,s4
    800043b0:	fc240513          	addi	a0,s0,-62
    800043b4:	ffffd097          	auipc	ra,0xffffd
    800043b8:	a2a080e7          	jalr	-1494(ra) # 80000dde <strncpy>
  de.inum = inum;
    800043bc:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043c0:	4741                	li	a4,16
    800043c2:	86a6                	mv	a3,s1
    800043c4:	fc040613          	addi	a2,s0,-64
    800043c8:	4581                	li	a1,0
    800043ca:	854a                	mv	a0,s2
    800043cc:	00000097          	auipc	ra,0x0
    800043d0:	c44080e7          	jalr	-956(ra) # 80004010 <writei>
    800043d4:	1541                	addi	a0,a0,-16
    800043d6:	00a03533          	snez	a0,a0
    800043da:	40a00533          	neg	a0,a0
}
    800043de:	70e2                	ld	ra,56(sp)
    800043e0:	7442                	ld	s0,48(sp)
    800043e2:	74a2                	ld	s1,40(sp)
    800043e4:	7902                	ld	s2,32(sp)
    800043e6:	69e2                	ld	s3,24(sp)
    800043e8:	6a42                	ld	s4,16(sp)
    800043ea:	6121                	addi	sp,sp,64
    800043ec:	8082                	ret
    iput(ip);
    800043ee:	00000097          	auipc	ra,0x0
    800043f2:	a30080e7          	jalr	-1488(ra) # 80003e1e <iput>
    return -1;
    800043f6:	557d                	li	a0,-1
    800043f8:	b7dd                	j	800043de <dirlink+0x86>
      panic("dirlink read");
    800043fa:	00004517          	auipc	a0,0x4
    800043fe:	26e50513          	addi	a0,a0,622 # 80008668 <syscalls+0x1f0>
    80004402:	ffffc097          	auipc	ra,0xffffc
    80004406:	13c080e7          	jalr	316(ra) # 8000053e <panic>

000000008000440a <namei>:

struct inode*
namei(char *path)
{
    8000440a:	1101                	addi	sp,sp,-32
    8000440c:	ec06                	sd	ra,24(sp)
    8000440e:	e822                	sd	s0,16(sp)
    80004410:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004412:	fe040613          	addi	a2,s0,-32
    80004416:	4581                	li	a1,0
    80004418:	00000097          	auipc	ra,0x0
    8000441c:	de0080e7          	jalr	-544(ra) # 800041f8 <namex>
}
    80004420:	60e2                	ld	ra,24(sp)
    80004422:	6442                	ld	s0,16(sp)
    80004424:	6105                	addi	sp,sp,32
    80004426:	8082                	ret

0000000080004428 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004428:	1141                	addi	sp,sp,-16
    8000442a:	e406                	sd	ra,8(sp)
    8000442c:	e022                	sd	s0,0(sp)
    8000442e:	0800                	addi	s0,sp,16
    80004430:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004432:	4585                	li	a1,1
    80004434:	00000097          	auipc	ra,0x0
    80004438:	dc4080e7          	jalr	-572(ra) # 800041f8 <namex>
}
    8000443c:	60a2                	ld	ra,8(sp)
    8000443e:	6402                	ld	s0,0(sp)
    80004440:	0141                	addi	sp,sp,16
    80004442:	8082                	ret

0000000080004444 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004444:	1101                	addi	sp,sp,-32
    80004446:	ec06                	sd	ra,24(sp)
    80004448:	e822                	sd	s0,16(sp)
    8000444a:	e426                	sd	s1,8(sp)
    8000444c:	e04a                	sd	s2,0(sp)
    8000444e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004450:	0001d917          	auipc	s2,0x1d
    80004454:	72090913          	addi	s2,s2,1824 # 80021b70 <log>
    80004458:	01892583          	lw	a1,24(s2)
    8000445c:	02892503          	lw	a0,40(s2)
    80004460:	fffff097          	auipc	ra,0xfffff
    80004464:	fea080e7          	jalr	-22(ra) # 8000344a <bread>
    80004468:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000446a:	02c92683          	lw	a3,44(s2)
    8000446e:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004470:	02d05763          	blez	a3,8000449e <write_head+0x5a>
    80004474:	0001d797          	auipc	a5,0x1d
    80004478:	72c78793          	addi	a5,a5,1836 # 80021ba0 <log+0x30>
    8000447c:	05c50713          	addi	a4,a0,92
    80004480:	36fd                	addiw	a3,a3,-1
    80004482:	1682                	slli	a3,a3,0x20
    80004484:	9281                	srli	a3,a3,0x20
    80004486:	068a                	slli	a3,a3,0x2
    80004488:	0001d617          	auipc	a2,0x1d
    8000448c:	71c60613          	addi	a2,a2,1820 # 80021ba4 <log+0x34>
    80004490:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004492:	4390                	lw	a2,0(a5)
    80004494:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004496:	0791                	addi	a5,a5,4
    80004498:	0711                	addi	a4,a4,4
    8000449a:	fed79ce3          	bne	a5,a3,80004492 <write_head+0x4e>
  }
  bwrite(buf);
    8000449e:	8526                	mv	a0,s1
    800044a0:	fffff097          	auipc	ra,0xfffff
    800044a4:	09c080e7          	jalr	156(ra) # 8000353c <bwrite>
  brelse(buf);
    800044a8:	8526                	mv	a0,s1
    800044aa:	fffff097          	auipc	ra,0xfffff
    800044ae:	0d0080e7          	jalr	208(ra) # 8000357a <brelse>
}
    800044b2:	60e2                	ld	ra,24(sp)
    800044b4:	6442                	ld	s0,16(sp)
    800044b6:	64a2                	ld	s1,8(sp)
    800044b8:	6902                	ld	s2,0(sp)
    800044ba:	6105                	addi	sp,sp,32
    800044bc:	8082                	ret

00000000800044be <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800044be:	0001d797          	auipc	a5,0x1d
    800044c2:	6de7a783          	lw	a5,1758(a5) # 80021b9c <log+0x2c>
    800044c6:	0af05d63          	blez	a5,80004580 <install_trans+0xc2>
{
    800044ca:	7139                	addi	sp,sp,-64
    800044cc:	fc06                	sd	ra,56(sp)
    800044ce:	f822                	sd	s0,48(sp)
    800044d0:	f426                	sd	s1,40(sp)
    800044d2:	f04a                	sd	s2,32(sp)
    800044d4:	ec4e                	sd	s3,24(sp)
    800044d6:	e852                	sd	s4,16(sp)
    800044d8:	e456                	sd	s5,8(sp)
    800044da:	e05a                	sd	s6,0(sp)
    800044dc:	0080                	addi	s0,sp,64
    800044de:	8b2a                	mv	s6,a0
    800044e0:	0001da97          	auipc	s5,0x1d
    800044e4:	6c0a8a93          	addi	s5,s5,1728 # 80021ba0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044e8:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800044ea:	0001d997          	auipc	s3,0x1d
    800044ee:	68698993          	addi	s3,s3,1670 # 80021b70 <log>
    800044f2:	a00d                	j	80004514 <install_trans+0x56>
    brelse(lbuf);
    800044f4:	854a                	mv	a0,s2
    800044f6:	fffff097          	auipc	ra,0xfffff
    800044fa:	084080e7          	jalr	132(ra) # 8000357a <brelse>
    brelse(dbuf);
    800044fe:	8526                	mv	a0,s1
    80004500:	fffff097          	auipc	ra,0xfffff
    80004504:	07a080e7          	jalr	122(ra) # 8000357a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004508:	2a05                	addiw	s4,s4,1
    8000450a:	0a91                	addi	s5,s5,4
    8000450c:	02c9a783          	lw	a5,44(s3)
    80004510:	04fa5e63          	bge	s4,a5,8000456c <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004514:	0189a583          	lw	a1,24(s3)
    80004518:	014585bb          	addw	a1,a1,s4
    8000451c:	2585                	addiw	a1,a1,1
    8000451e:	0289a503          	lw	a0,40(s3)
    80004522:	fffff097          	auipc	ra,0xfffff
    80004526:	f28080e7          	jalr	-216(ra) # 8000344a <bread>
    8000452a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000452c:	000aa583          	lw	a1,0(s5)
    80004530:	0289a503          	lw	a0,40(s3)
    80004534:	fffff097          	auipc	ra,0xfffff
    80004538:	f16080e7          	jalr	-234(ra) # 8000344a <bread>
    8000453c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000453e:	40000613          	li	a2,1024
    80004542:	05890593          	addi	a1,s2,88
    80004546:	05850513          	addi	a0,a0,88
    8000454a:	ffffc097          	auipc	ra,0xffffc
    8000454e:	7e4080e7          	jalr	2020(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    80004552:	8526                	mv	a0,s1
    80004554:	fffff097          	auipc	ra,0xfffff
    80004558:	fe8080e7          	jalr	-24(ra) # 8000353c <bwrite>
    if(recovering == 0)
    8000455c:	f80b1ce3          	bnez	s6,800044f4 <install_trans+0x36>
      bunpin(dbuf);
    80004560:	8526                	mv	a0,s1
    80004562:	fffff097          	auipc	ra,0xfffff
    80004566:	0f2080e7          	jalr	242(ra) # 80003654 <bunpin>
    8000456a:	b769                	j	800044f4 <install_trans+0x36>
}
    8000456c:	70e2                	ld	ra,56(sp)
    8000456e:	7442                	ld	s0,48(sp)
    80004570:	74a2                	ld	s1,40(sp)
    80004572:	7902                	ld	s2,32(sp)
    80004574:	69e2                	ld	s3,24(sp)
    80004576:	6a42                	ld	s4,16(sp)
    80004578:	6aa2                	ld	s5,8(sp)
    8000457a:	6b02                	ld	s6,0(sp)
    8000457c:	6121                	addi	sp,sp,64
    8000457e:	8082                	ret
    80004580:	8082                	ret

0000000080004582 <initlog>:
{
    80004582:	7179                	addi	sp,sp,-48
    80004584:	f406                	sd	ra,40(sp)
    80004586:	f022                	sd	s0,32(sp)
    80004588:	ec26                	sd	s1,24(sp)
    8000458a:	e84a                	sd	s2,16(sp)
    8000458c:	e44e                	sd	s3,8(sp)
    8000458e:	1800                	addi	s0,sp,48
    80004590:	892a                	mv	s2,a0
    80004592:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004594:	0001d497          	auipc	s1,0x1d
    80004598:	5dc48493          	addi	s1,s1,1500 # 80021b70 <log>
    8000459c:	00004597          	auipc	a1,0x4
    800045a0:	0dc58593          	addi	a1,a1,220 # 80008678 <syscalls+0x200>
    800045a4:	8526                	mv	a0,s1
    800045a6:	ffffc097          	auipc	ra,0xffffc
    800045aa:	5a0080e7          	jalr	1440(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    800045ae:	0149a583          	lw	a1,20(s3)
    800045b2:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800045b4:	0109a783          	lw	a5,16(s3)
    800045b8:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800045ba:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800045be:	854a                	mv	a0,s2
    800045c0:	fffff097          	auipc	ra,0xfffff
    800045c4:	e8a080e7          	jalr	-374(ra) # 8000344a <bread>
  log.lh.n = lh->n;
    800045c8:	4d34                	lw	a3,88(a0)
    800045ca:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800045cc:	02d05563          	blez	a3,800045f6 <initlog+0x74>
    800045d0:	05c50793          	addi	a5,a0,92
    800045d4:	0001d717          	auipc	a4,0x1d
    800045d8:	5cc70713          	addi	a4,a4,1484 # 80021ba0 <log+0x30>
    800045dc:	36fd                	addiw	a3,a3,-1
    800045de:	1682                	slli	a3,a3,0x20
    800045e0:	9281                	srli	a3,a3,0x20
    800045e2:	068a                	slli	a3,a3,0x2
    800045e4:	06050613          	addi	a2,a0,96
    800045e8:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800045ea:	4390                	lw	a2,0(a5)
    800045ec:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800045ee:	0791                	addi	a5,a5,4
    800045f0:	0711                	addi	a4,a4,4
    800045f2:	fed79ce3          	bne	a5,a3,800045ea <initlog+0x68>
  brelse(buf);
    800045f6:	fffff097          	auipc	ra,0xfffff
    800045fa:	f84080e7          	jalr	-124(ra) # 8000357a <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800045fe:	4505                	li	a0,1
    80004600:	00000097          	auipc	ra,0x0
    80004604:	ebe080e7          	jalr	-322(ra) # 800044be <install_trans>
  log.lh.n = 0;
    80004608:	0001d797          	auipc	a5,0x1d
    8000460c:	5807aa23          	sw	zero,1428(a5) # 80021b9c <log+0x2c>
  write_head(); // clear the log
    80004610:	00000097          	auipc	ra,0x0
    80004614:	e34080e7          	jalr	-460(ra) # 80004444 <write_head>
}
    80004618:	70a2                	ld	ra,40(sp)
    8000461a:	7402                	ld	s0,32(sp)
    8000461c:	64e2                	ld	s1,24(sp)
    8000461e:	6942                	ld	s2,16(sp)
    80004620:	69a2                	ld	s3,8(sp)
    80004622:	6145                	addi	sp,sp,48
    80004624:	8082                	ret

0000000080004626 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004626:	1101                	addi	sp,sp,-32
    80004628:	ec06                	sd	ra,24(sp)
    8000462a:	e822                	sd	s0,16(sp)
    8000462c:	e426                	sd	s1,8(sp)
    8000462e:	e04a                	sd	s2,0(sp)
    80004630:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004632:	0001d517          	auipc	a0,0x1d
    80004636:	53e50513          	addi	a0,a0,1342 # 80021b70 <log>
    8000463a:	ffffc097          	auipc	ra,0xffffc
    8000463e:	59c080e7          	jalr	1436(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    80004642:	0001d497          	auipc	s1,0x1d
    80004646:	52e48493          	addi	s1,s1,1326 # 80021b70 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000464a:	4979                	li	s2,30
    8000464c:	a039                	j	8000465a <begin_op+0x34>
      sleep(&log, &log.lock);
    8000464e:	85a6                	mv	a1,s1
    80004650:	8526                	mv	a0,s1
    80004652:	ffffe097          	auipc	ra,0xffffe
    80004656:	d10080e7          	jalr	-752(ra) # 80002362 <sleep>
    if(log.committing){
    8000465a:	50dc                	lw	a5,36(s1)
    8000465c:	fbed                	bnez	a5,8000464e <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000465e:	509c                	lw	a5,32(s1)
    80004660:	0017871b          	addiw	a4,a5,1
    80004664:	0007069b          	sext.w	a3,a4
    80004668:	0027179b          	slliw	a5,a4,0x2
    8000466c:	9fb9                	addw	a5,a5,a4
    8000466e:	0017979b          	slliw	a5,a5,0x1
    80004672:	54d8                	lw	a4,44(s1)
    80004674:	9fb9                	addw	a5,a5,a4
    80004676:	00f95963          	bge	s2,a5,80004688 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000467a:	85a6                	mv	a1,s1
    8000467c:	8526                	mv	a0,s1
    8000467e:	ffffe097          	auipc	ra,0xffffe
    80004682:	ce4080e7          	jalr	-796(ra) # 80002362 <sleep>
    80004686:	bfd1                	j	8000465a <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004688:	0001d517          	auipc	a0,0x1d
    8000468c:	4e850513          	addi	a0,a0,1256 # 80021b70 <log>
    80004690:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004692:	ffffc097          	auipc	ra,0xffffc
    80004696:	5f8080e7          	jalr	1528(ra) # 80000c8a <release>
      break;
    }
  }
}
    8000469a:	60e2                	ld	ra,24(sp)
    8000469c:	6442                	ld	s0,16(sp)
    8000469e:	64a2                	ld	s1,8(sp)
    800046a0:	6902                	ld	s2,0(sp)
    800046a2:	6105                	addi	sp,sp,32
    800046a4:	8082                	ret

00000000800046a6 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800046a6:	7139                	addi	sp,sp,-64
    800046a8:	fc06                	sd	ra,56(sp)
    800046aa:	f822                	sd	s0,48(sp)
    800046ac:	f426                	sd	s1,40(sp)
    800046ae:	f04a                	sd	s2,32(sp)
    800046b0:	ec4e                	sd	s3,24(sp)
    800046b2:	e852                	sd	s4,16(sp)
    800046b4:	e456                	sd	s5,8(sp)
    800046b6:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800046b8:	0001d497          	auipc	s1,0x1d
    800046bc:	4b848493          	addi	s1,s1,1208 # 80021b70 <log>
    800046c0:	8526                	mv	a0,s1
    800046c2:	ffffc097          	auipc	ra,0xffffc
    800046c6:	514080e7          	jalr	1300(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    800046ca:	509c                	lw	a5,32(s1)
    800046cc:	37fd                	addiw	a5,a5,-1
    800046ce:	0007891b          	sext.w	s2,a5
    800046d2:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800046d4:	50dc                	lw	a5,36(s1)
    800046d6:	e7b9                	bnez	a5,80004724 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800046d8:	04091e63          	bnez	s2,80004734 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800046dc:	0001d497          	auipc	s1,0x1d
    800046e0:	49448493          	addi	s1,s1,1172 # 80021b70 <log>
    800046e4:	4785                	li	a5,1
    800046e6:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800046e8:	8526                	mv	a0,s1
    800046ea:	ffffc097          	auipc	ra,0xffffc
    800046ee:	5a0080e7          	jalr	1440(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800046f2:	54dc                	lw	a5,44(s1)
    800046f4:	06f04763          	bgtz	a5,80004762 <end_op+0xbc>
    acquire(&log.lock);
    800046f8:	0001d497          	auipc	s1,0x1d
    800046fc:	47848493          	addi	s1,s1,1144 # 80021b70 <log>
    80004700:	8526                	mv	a0,s1
    80004702:	ffffc097          	auipc	ra,0xffffc
    80004706:	4d4080e7          	jalr	1236(ra) # 80000bd6 <acquire>
    log.committing = 0;
    8000470a:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000470e:	8526                	mv	a0,s1
    80004710:	ffffe097          	auipc	ra,0xffffe
    80004714:	d3a080e7          	jalr	-710(ra) # 8000244a <wakeup>
    release(&log.lock);
    80004718:	8526                	mv	a0,s1
    8000471a:	ffffc097          	auipc	ra,0xffffc
    8000471e:	570080e7          	jalr	1392(ra) # 80000c8a <release>
}
    80004722:	a03d                	j	80004750 <end_op+0xaa>
    panic("log.committing");
    80004724:	00004517          	auipc	a0,0x4
    80004728:	f5c50513          	addi	a0,a0,-164 # 80008680 <syscalls+0x208>
    8000472c:	ffffc097          	auipc	ra,0xffffc
    80004730:	e12080e7          	jalr	-494(ra) # 8000053e <panic>
    wakeup(&log);
    80004734:	0001d497          	auipc	s1,0x1d
    80004738:	43c48493          	addi	s1,s1,1084 # 80021b70 <log>
    8000473c:	8526                	mv	a0,s1
    8000473e:	ffffe097          	auipc	ra,0xffffe
    80004742:	d0c080e7          	jalr	-756(ra) # 8000244a <wakeup>
  release(&log.lock);
    80004746:	8526                	mv	a0,s1
    80004748:	ffffc097          	auipc	ra,0xffffc
    8000474c:	542080e7          	jalr	1346(ra) # 80000c8a <release>
}
    80004750:	70e2                	ld	ra,56(sp)
    80004752:	7442                	ld	s0,48(sp)
    80004754:	74a2                	ld	s1,40(sp)
    80004756:	7902                	ld	s2,32(sp)
    80004758:	69e2                	ld	s3,24(sp)
    8000475a:	6a42                	ld	s4,16(sp)
    8000475c:	6aa2                	ld	s5,8(sp)
    8000475e:	6121                	addi	sp,sp,64
    80004760:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004762:	0001da97          	auipc	s5,0x1d
    80004766:	43ea8a93          	addi	s5,s5,1086 # 80021ba0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000476a:	0001da17          	auipc	s4,0x1d
    8000476e:	406a0a13          	addi	s4,s4,1030 # 80021b70 <log>
    80004772:	018a2583          	lw	a1,24(s4)
    80004776:	012585bb          	addw	a1,a1,s2
    8000477a:	2585                	addiw	a1,a1,1
    8000477c:	028a2503          	lw	a0,40(s4)
    80004780:	fffff097          	auipc	ra,0xfffff
    80004784:	cca080e7          	jalr	-822(ra) # 8000344a <bread>
    80004788:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000478a:	000aa583          	lw	a1,0(s5)
    8000478e:	028a2503          	lw	a0,40(s4)
    80004792:	fffff097          	auipc	ra,0xfffff
    80004796:	cb8080e7          	jalr	-840(ra) # 8000344a <bread>
    8000479a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000479c:	40000613          	li	a2,1024
    800047a0:	05850593          	addi	a1,a0,88
    800047a4:	05848513          	addi	a0,s1,88
    800047a8:	ffffc097          	auipc	ra,0xffffc
    800047ac:	586080e7          	jalr	1414(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    800047b0:	8526                	mv	a0,s1
    800047b2:	fffff097          	auipc	ra,0xfffff
    800047b6:	d8a080e7          	jalr	-630(ra) # 8000353c <bwrite>
    brelse(from);
    800047ba:	854e                	mv	a0,s3
    800047bc:	fffff097          	auipc	ra,0xfffff
    800047c0:	dbe080e7          	jalr	-578(ra) # 8000357a <brelse>
    brelse(to);
    800047c4:	8526                	mv	a0,s1
    800047c6:	fffff097          	auipc	ra,0xfffff
    800047ca:	db4080e7          	jalr	-588(ra) # 8000357a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800047ce:	2905                	addiw	s2,s2,1
    800047d0:	0a91                	addi	s5,s5,4
    800047d2:	02ca2783          	lw	a5,44(s4)
    800047d6:	f8f94ee3          	blt	s2,a5,80004772 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800047da:	00000097          	auipc	ra,0x0
    800047de:	c6a080e7          	jalr	-918(ra) # 80004444 <write_head>
    install_trans(0); // Now install writes to home locations
    800047e2:	4501                	li	a0,0
    800047e4:	00000097          	auipc	ra,0x0
    800047e8:	cda080e7          	jalr	-806(ra) # 800044be <install_trans>
    log.lh.n = 0;
    800047ec:	0001d797          	auipc	a5,0x1d
    800047f0:	3a07a823          	sw	zero,944(a5) # 80021b9c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800047f4:	00000097          	auipc	ra,0x0
    800047f8:	c50080e7          	jalr	-944(ra) # 80004444 <write_head>
    800047fc:	bdf5                	j	800046f8 <end_op+0x52>

00000000800047fe <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800047fe:	1101                	addi	sp,sp,-32
    80004800:	ec06                	sd	ra,24(sp)
    80004802:	e822                	sd	s0,16(sp)
    80004804:	e426                	sd	s1,8(sp)
    80004806:	e04a                	sd	s2,0(sp)
    80004808:	1000                	addi	s0,sp,32
    8000480a:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000480c:	0001d917          	auipc	s2,0x1d
    80004810:	36490913          	addi	s2,s2,868 # 80021b70 <log>
    80004814:	854a                	mv	a0,s2
    80004816:	ffffc097          	auipc	ra,0xffffc
    8000481a:	3c0080e7          	jalr	960(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000481e:	02c92603          	lw	a2,44(s2)
    80004822:	47f5                	li	a5,29
    80004824:	06c7c563          	blt	a5,a2,8000488e <log_write+0x90>
    80004828:	0001d797          	auipc	a5,0x1d
    8000482c:	3647a783          	lw	a5,868(a5) # 80021b8c <log+0x1c>
    80004830:	37fd                	addiw	a5,a5,-1
    80004832:	04f65e63          	bge	a2,a5,8000488e <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004836:	0001d797          	auipc	a5,0x1d
    8000483a:	35a7a783          	lw	a5,858(a5) # 80021b90 <log+0x20>
    8000483e:	06f05063          	blez	a5,8000489e <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004842:	4781                	li	a5,0
    80004844:	06c05563          	blez	a2,800048ae <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004848:	44cc                	lw	a1,12(s1)
    8000484a:	0001d717          	auipc	a4,0x1d
    8000484e:	35670713          	addi	a4,a4,854 # 80021ba0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004852:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004854:	4314                	lw	a3,0(a4)
    80004856:	04b68c63          	beq	a3,a1,800048ae <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000485a:	2785                	addiw	a5,a5,1
    8000485c:	0711                	addi	a4,a4,4
    8000485e:	fef61be3          	bne	a2,a5,80004854 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004862:	0621                	addi	a2,a2,8
    80004864:	060a                	slli	a2,a2,0x2
    80004866:	0001d797          	auipc	a5,0x1d
    8000486a:	30a78793          	addi	a5,a5,778 # 80021b70 <log>
    8000486e:	963e                	add	a2,a2,a5
    80004870:	44dc                	lw	a5,12(s1)
    80004872:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004874:	8526                	mv	a0,s1
    80004876:	fffff097          	auipc	ra,0xfffff
    8000487a:	da2080e7          	jalr	-606(ra) # 80003618 <bpin>
    log.lh.n++;
    8000487e:	0001d717          	auipc	a4,0x1d
    80004882:	2f270713          	addi	a4,a4,754 # 80021b70 <log>
    80004886:	575c                	lw	a5,44(a4)
    80004888:	2785                	addiw	a5,a5,1
    8000488a:	d75c                	sw	a5,44(a4)
    8000488c:	a835                	j	800048c8 <log_write+0xca>
    panic("too big a transaction");
    8000488e:	00004517          	auipc	a0,0x4
    80004892:	e0250513          	addi	a0,a0,-510 # 80008690 <syscalls+0x218>
    80004896:	ffffc097          	auipc	ra,0xffffc
    8000489a:	ca8080e7          	jalr	-856(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    8000489e:	00004517          	auipc	a0,0x4
    800048a2:	e0a50513          	addi	a0,a0,-502 # 800086a8 <syscalls+0x230>
    800048a6:	ffffc097          	auipc	ra,0xffffc
    800048aa:	c98080e7          	jalr	-872(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    800048ae:	00878713          	addi	a4,a5,8
    800048b2:	00271693          	slli	a3,a4,0x2
    800048b6:	0001d717          	auipc	a4,0x1d
    800048ba:	2ba70713          	addi	a4,a4,698 # 80021b70 <log>
    800048be:	9736                	add	a4,a4,a3
    800048c0:	44d4                	lw	a3,12(s1)
    800048c2:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800048c4:	faf608e3          	beq	a2,a5,80004874 <log_write+0x76>
  }
  release(&log.lock);
    800048c8:	0001d517          	auipc	a0,0x1d
    800048cc:	2a850513          	addi	a0,a0,680 # 80021b70 <log>
    800048d0:	ffffc097          	auipc	ra,0xffffc
    800048d4:	3ba080e7          	jalr	954(ra) # 80000c8a <release>
}
    800048d8:	60e2                	ld	ra,24(sp)
    800048da:	6442                	ld	s0,16(sp)
    800048dc:	64a2                	ld	s1,8(sp)
    800048de:	6902                	ld	s2,0(sp)
    800048e0:	6105                	addi	sp,sp,32
    800048e2:	8082                	ret

00000000800048e4 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800048e4:	1101                	addi	sp,sp,-32
    800048e6:	ec06                	sd	ra,24(sp)
    800048e8:	e822                	sd	s0,16(sp)
    800048ea:	e426                	sd	s1,8(sp)
    800048ec:	e04a                	sd	s2,0(sp)
    800048ee:	1000                	addi	s0,sp,32
    800048f0:	84aa                	mv	s1,a0
    800048f2:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800048f4:	00004597          	auipc	a1,0x4
    800048f8:	dd458593          	addi	a1,a1,-556 # 800086c8 <syscalls+0x250>
    800048fc:	0521                	addi	a0,a0,8
    800048fe:	ffffc097          	auipc	ra,0xffffc
    80004902:	248080e7          	jalr	584(ra) # 80000b46 <initlock>
  lk->name = name;
    80004906:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000490a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000490e:	0204a423          	sw	zero,40(s1)
}
    80004912:	60e2                	ld	ra,24(sp)
    80004914:	6442                	ld	s0,16(sp)
    80004916:	64a2                	ld	s1,8(sp)
    80004918:	6902                	ld	s2,0(sp)
    8000491a:	6105                	addi	sp,sp,32
    8000491c:	8082                	ret

000000008000491e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000491e:	1101                	addi	sp,sp,-32
    80004920:	ec06                	sd	ra,24(sp)
    80004922:	e822                	sd	s0,16(sp)
    80004924:	e426                	sd	s1,8(sp)
    80004926:	e04a                	sd	s2,0(sp)
    80004928:	1000                	addi	s0,sp,32
    8000492a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000492c:	00850913          	addi	s2,a0,8
    80004930:	854a                	mv	a0,s2
    80004932:	ffffc097          	auipc	ra,0xffffc
    80004936:	2a4080e7          	jalr	676(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    8000493a:	409c                	lw	a5,0(s1)
    8000493c:	cb89                	beqz	a5,8000494e <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000493e:	85ca                	mv	a1,s2
    80004940:	8526                	mv	a0,s1
    80004942:	ffffe097          	auipc	ra,0xffffe
    80004946:	a20080e7          	jalr	-1504(ra) # 80002362 <sleep>
  while (lk->locked) {
    8000494a:	409c                	lw	a5,0(s1)
    8000494c:	fbed                	bnez	a5,8000493e <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000494e:	4785                	li	a5,1
    80004950:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004952:	ffffd097          	auipc	ra,0xffffd
    80004956:	08e080e7          	jalr	142(ra) # 800019e0 <myproc>
    8000495a:	591c                	lw	a5,48(a0)
    8000495c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000495e:	854a                	mv	a0,s2
    80004960:	ffffc097          	auipc	ra,0xffffc
    80004964:	32a080e7          	jalr	810(ra) # 80000c8a <release>
}
    80004968:	60e2                	ld	ra,24(sp)
    8000496a:	6442                	ld	s0,16(sp)
    8000496c:	64a2                	ld	s1,8(sp)
    8000496e:	6902                	ld	s2,0(sp)
    80004970:	6105                	addi	sp,sp,32
    80004972:	8082                	ret

0000000080004974 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004974:	1101                	addi	sp,sp,-32
    80004976:	ec06                	sd	ra,24(sp)
    80004978:	e822                	sd	s0,16(sp)
    8000497a:	e426                	sd	s1,8(sp)
    8000497c:	e04a                	sd	s2,0(sp)
    8000497e:	1000                	addi	s0,sp,32
    80004980:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004982:	00850913          	addi	s2,a0,8
    80004986:	854a                	mv	a0,s2
    80004988:	ffffc097          	auipc	ra,0xffffc
    8000498c:	24e080e7          	jalr	590(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    80004990:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004994:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004998:	8526                	mv	a0,s1
    8000499a:	ffffe097          	auipc	ra,0xffffe
    8000499e:	ab0080e7          	jalr	-1360(ra) # 8000244a <wakeup>
  release(&lk->lk);
    800049a2:	854a                	mv	a0,s2
    800049a4:	ffffc097          	auipc	ra,0xffffc
    800049a8:	2e6080e7          	jalr	742(ra) # 80000c8a <release>
}
    800049ac:	60e2                	ld	ra,24(sp)
    800049ae:	6442                	ld	s0,16(sp)
    800049b0:	64a2                	ld	s1,8(sp)
    800049b2:	6902                	ld	s2,0(sp)
    800049b4:	6105                	addi	sp,sp,32
    800049b6:	8082                	ret

00000000800049b8 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800049b8:	7179                	addi	sp,sp,-48
    800049ba:	f406                	sd	ra,40(sp)
    800049bc:	f022                	sd	s0,32(sp)
    800049be:	ec26                	sd	s1,24(sp)
    800049c0:	e84a                	sd	s2,16(sp)
    800049c2:	e44e                	sd	s3,8(sp)
    800049c4:	1800                	addi	s0,sp,48
    800049c6:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800049c8:	00850913          	addi	s2,a0,8
    800049cc:	854a                	mv	a0,s2
    800049ce:	ffffc097          	auipc	ra,0xffffc
    800049d2:	208080e7          	jalr	520(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800049d6:	409c                	lw	a5,0(s1)
    800049d8:	ef99                	bnez	a5,800049f6 <holdingsleep+0x3e>
    800049da:	4481                	li	s1,0
  release(&lk->lk);
    800049dc:	854a                	mv	a0,s2
    800049de:	ffffc097          	auipc	ra,0xffffc
    800049e2:	2ac080e7          	jalr	684(ra) # 80000c8a <release>
  return r;
}
    800049e6:	8526                	mv	a0,s1
    800049e8:	70a2                	ld	ra,40(sp)
    800049ea:	7402                	ld	s0,32(sp)
    800049ec:	64e2                	ld	s1,24(sp)
    800049ee:	6942                	ld	s2,16(sp)
    800049f0:	69a2                	ld	s3,8(sp)
    800049f2:	6145                	addi	sp,sp,48
    800049f4:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800049f6:	0284a983          	lw	s3,40(s1)
    800049fa:	ffffd097          	auipc	ra,0xffffd
    800049fe:	fe6080e7          	jalr	-26(ra) # 800019e0 <myproc>
    80004a02:	5904                	lw	s1,48(a0)
    80004a04:	413484b3          	sub	s1,s1,s3
    80004a08:	0014b493          	seqz	s1,s1
    80004a0c:	bfc1                	j	800049dc <holdingsleep+0x24>

0000000080004a0e <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004a0e:	1141                	addi	sp,sp,-16
    80004a10:	e406                	sd	ra,8(sp)
    80004a12:	e022                	sd	s0,0(sp)
    80004a14:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004a16:	00004597          	auipc	a1,0x4
    80004a1a:	cc258593          	addi	a1,a1,-830 # 800086d8 <syscalls+0x260>
    80004a1e:	0001d517          	auipc	a0,0x1d
    80004a22:	29a50513          	addi	a0,a0,666 # 80021cb8 <ftable>
    80004a26:	ffffc097          	auipc	ra,0xffffc
    80004a2a:	120080e7          	jalr	288(ra) # 80000b46 <initlock>
}
    80004a2e:	60a2                	ld	ra,8(sp)
    80004a30:	6402                	ld	s0,0(sp)
    80004a32:	0141                	addi	sp,sp,16
    80004a34:	8082                	ret

0000000080004a36 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004a36:	1101                	addi	sp,sp,-32
    80004a38:	ec06                	sd	ra,24(sp)
    80004a3a:	e822                	sd	s0,16(sp)
    80004a3c:	e426                	sd	s1,8(sp)
    80004a3e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004a40:	0001d517          	auipc	a0,0x1d
    80004a44:	27850513          	addi	a0,a0,632 # 80021cb8 <ftable>
    80004a48:	ffffc097          	auipc	ra,0xffffc
    80004a4c:	18e080e7          	jalr	398(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a50:	0001d497          	auipc	s1,0x1d
    80004a54:	28048493          	addi	s1,s1,640 # 80021cd0 <ftable+0x18>
    80004a58:	0001e717          	auipc	a4,0x1e
    80004a5c:	21870713          	addi	a4,a4,536 # 80022c70 <disk>
    if(f->ref == 0){
    80004a60:	40dc                	lw	a5,4(s1)
    80004a62:	cf99                	beqz	a5,80004a80 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a64:	02848493          	addi	s1,s1,40
    80004a68:	fee49ce3          	bne	s1,a4,80004a60 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004a6c:	0001d517          	auipc	a0,0x1d
    80004a70:	24c50513          	addi	a0,a0,588 # 80021cb8 <ftable>
    80004a74:	ffffc097          	auipc	ra,0xffffc
    80004a78:	216080e7          	jalr	534(ra) # 80000c8a <release>
  return 0;
    80004a7c:	4481                	li	s1,0
    80004a7e:	a819                	j	80004a94 <filealloc+0x5e>
      f->ref = 1;
    80004a80:	4785                	li	a5,1
    80004a82:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004a84:	0001d517          	auipc	a0,0x1d
    80004a88:	23450513          	addi	a0,a0,564 # 80021cb8 <ftable>
    80004a8c:	ffffc097          	auipc	ra,0xffffc
    80004a90:	1fe080e7          	jalr	510(ra) # 80000c8a <release>
}
    80004a94:	8526                	mv	a0,s1
    80004a96:	60e2                	ld	ra,24(sp)
    80004a98:	6442                	ld	s0,16(sp)
    80004a9a:	64a2                	ld	s1,8(sp)
    80004a9c:	6105                	addi	sp,sp,32
    80004a9e:	8082                	ret

0000000080004aa0 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004aa0:	1101                	addi	sp,sp,-32
    80004aa2:	ec06                	sd	ra,24(sp)
    80004aa4:	e822                	sd	s0,16(sp)
    80004aa6:	e426                	sd	s1,8(sp)
    80004aa8:	1000                	addi	s0,sp,32
    80004aaa:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004aac:	0001d517          	auipc	a0,0x1d
    80004ab0:	20c50513          	addi	a0,a0,524 # 80021cb8 <ftable>
    80004ab4:	ffffc097          	auipc	ra,0xffffc
    80004ab8:	122080e7          	jalr	290(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004abc:	40dc                	lw	a5,4(s1)
    80004abe:	02f05263          	blez	a5,80004ae2 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004ac2:	2785                	addiw	a5,a5,1
    80004ac4:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004ac6:	0001d517          	auipc	a0,0x1d
    80004aca:	1f250513          	addi	a0,a0,498 # 80021cb8 <ftable>
    80004ace:	ffffc097          	auipc	ra,0xffffc
    80004ad2:	1bc080e7          	jalr	444(ra) # 80000c8a <release>
  return f;
}
    80004ad6:	8526                	mv	a0,s1
    80004ad8:	60e2                	ld	ra,24(sp)
    80004ada:	6442                	ld	s0,16(sp)
    80004adc:	64a2                	ld	s1,8(sp)
    80004ade:	6105                	addi	sp,sp,32
    80004ae0:	8082                	ret
    panic("filedup");
    80004ae2:	00004517          	auipc	a0,0x4
    80004ae6:	bfe50513          	addi	a0,a0,-1026 # 800086e0 <syscalls+0x268>
    80004aea:	ffffc097          	auipc	ra,0xffffc
    80004aee:	a54080e7          	jalr	-1452(ra) # 8000053e <panic>

0000000080004af2 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004af2:	7139                	addi	sp,sp,-64
    80004af4:	fc06                	sd	ra,56(sp)
    80004af6:	f822                	sd	s0,48(sp)
    80004af8:	f426                	sd	s1,40(sp)
    80004afa:	f04a                	sd	s2,32(sp)
    80004afc:	ec4e                	sd	s3,24(sp)
    80004afe:	e852                	sd	s4,16(sp)
    80004b00:	e456                	sd	s5,8(sp)
    80004b02:	0080                	addi	s0,sp,64
    80004b04:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004b06:	0001d517          	auipc	a0,0x1d
    80004b0a:	1b250513          	addi	a0,a0,434 # 80021cb8 <ftable>
    80004b0e:	ffffc097          	auipc	ra,0xffffc
    80004b12:	0c8080e7          	jalr	200(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004b16:	40dc                	lw	a5,4(s1)
    80004b18:	06f05163          	blez	a5,80004b7a <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004b1c:	37fd                	addiw	a5,a5,-1
    80004b1e:	0007871b          	sext.w	a4,a5
    80004b22:	c0dc                	sw	a5,4(s1)
    80004b24:	06e04363          	bgtz	a4,80004b8a <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004b28:	0004a903          	lw	s2,0(s1)
    80004b2c:	0094ca83          	lbu	s5,9(s1)
    80004b30:	0104ba03          	ld	s4,16(s1)
    80004b34:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004b38:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004b3c:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004b40:	0001d517          	auipc	a0,0x1d
    80004b44:	17850513          	addi	a0,a0,376 # 80021cb8 <ftable>
    80004b48:	ffffc097          	auipc	ra,0xffffc
    80004b4c:	142080e7          	jalr	322(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    80004b50:	4785                	li	a5,1
    80004b52:	04f90d63          	beq	s2,a5,80004bac <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004b56:	3979                	addiw	s2,s2,-2
    80004b58:	4785                	li	a5,1
    80004b5a:	0527e063          	bltu	a5,s2,80004b9a <fileclose+0xa8>
    begin_op();
    80004b5e:	00000097          	auipc	ra,0x0
    80004b62:	ac8080e7          	jalr	-1336(ra) # 80004626 <begin_op>
    iput(ff.ip);
    80004b66:	854e                	mv	a0,s3
    80004b68:	fffff097          	auipc	ra,0xfffff
    80004b6c:	2b6080e7          	jalr	694(ra) # 80003e1e <iput>
    end_op();
    80004b70:	00000097          	auipc	ra,0x0
    80004b74:	b36080e7          	jalr	-1226(ra) # 800046a6 <end_op>
    80004b78:	a00d                	j	80004b9a <fileclose+0xa8>
    panic("fileclose");
    80004b7a:	00004517          	auipc	a0,0x4
    80004b7e:	b6e50513          	addi	a0,a0,-1170 # 800086e8 <syscalls+0x270>
    80004b82:	ffffc097          	auipc	ra,0xffffc
    80004b86:	9bc080e7          	jalr	-1604(ra) # 8000053e <panic>
    release(&ftable.lock);
    80004b8a:	0001d517          	auipc	a0,0x1d
    80004b8e:	12e50513          	addi	a0,a0,302 # 80021cb8 <ftable>
    80004b92:	ffffc097          	auipc	ra,0xffffc
    80004b96:	0f8080e7          	jalr	248(ra) # 80000c8a <release>
  }
}
    80004b9a:	70e2                	ld	ra,56(sp)
    80004b9c:	7442                	ld	s0,48(sp)
    80004b9e:	74a2                	ld	s1,40(sp)
    80004ba0:	7902                	ld	s2,32(sp)
    80004ba2:	69e2                	ld	s3,24(sp)
    80004ba4:	6a42                	ld	s4,16(sp)
    80004ba6:	6aa2                	ld	s5,8(sp)
    80004ba8:	6121                	addi	sp,sp,64
    80004baa:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004bac:	85d6                	mv	a1,s5
    80004bae:	8552                	mv	a0,s4
    80004bb0:	00000097          	auipc	ra,0x0
    80004bb4:	34c080e7          	jalr	844(ra) # 80004efc <pipeclose>
    80004bb8:	b7cd                	j	80004b9a <fileclose+0xa8>

0000000080004bba <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004bba:	715d                	addi	sp,sp,-80
    80004bbc:	e486                	sd	ra,72(sp)
    80004bbe:	e0a2                	sd	s0,64(sp)
    80004bc0:	fc26                	sd	s1,56(sp)
    80004bc2:	f84a                	sd	s2,48(sp)
    80004bc4:	f44e                	sd	s3,40(sp)
    80004bc6:	0880                	addi	s0,sp,80
    80004bc8:	84aa                	mv	s1,a0
    80004bca:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004bcc:	ffffd097          	auipc	ra,0xffffd
    80004bd0:	e14080e7          	jalr	-492(ra) # 800019e0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004bd4:	409c                	lw	a5,0(s1)
    80004bd6:	37f9                	addiw	a5,a5,-2
    80004bd8:	4705                	li	a4,1
    80004bda:	04f76763          	bltu	a4,a5,80004c28 <filestat+0x6e>
    80004bde:	892a                	mv	s2,a0
    ilock(f->ip);
    80004be0:	6c88                	ld	a0,24(s1)
    80004be2:	fffff097          	auipc	ra,0xfffff
    80004be6:	082080e7          	jalr	130(ra) # 80003c64 <ilock>
    stati(f->ip, &st);
    80004bea:	fb840593          	addi	a1,s0,-72
    80004bee:	6c88                	ld	a0,24(s1)
    80004bf0:	fffff097          	auipc	ra,0xfffff
    80004bf4:	2fe080e7          	jalr	766(ra) # 80003eee <stati>
    iunlock(f->ip);
    80004bf8:	6c88                	ld	a0,24(s1)
    80004bfa:	fffff097          	auipc	ra,0xfffff
    80004bfe:	12c080e7          	jalr	300(ra) # 80003d26 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004c02:	46e1                	li	a3,24
    80004c04:	fb840613          	addi	a2,s0,-72
    80004c08:	85ce                	mv	a1,s3
    80004c0a:	09093503          	ld	a0,144(s2)
    80004c0e:	ffffd097          	auipc	ra,0xffffd
    80004c12:	a5a080e7          	jalr	-1446(ra) # 80001668 <copyout>
    80004c16:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004c1a:	60a6                	ld	ra,72(sp)
    80004c1c:	6406                	ld	s0,64(sp)
    80004c1e:	74e2                	ld	s1,56(sp)
    80004c20:	7942                	ld	s2,48(sp)
    80004c22:	79a2                	ld	s3,40(sp)
    80004c24:	6161                	addi	sp,sp,80
    80004c26:	8082                	ret
  return -1;
    80004c28:	557d                	li	a0,-1
    80004c2a:	bfc5                	j	80004c1a <filestat+0x60>

0000000080004c2c <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004c2c:	7179                	addi	sp,sp,-48
    80004c2e:	f406                	sd	ra,40(sp)
    80004c30:	f022                	sd	s0,32(sp)
    80004c32:	ec26                	sd	s1,24(sp)
    80004c34:	e84a                	sd	s2,16(sp)
    80004c36:	e44e                	sd	s3,8(sp)
    80004c38:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004c3a:	00854783          	lbu	a5,8(a0)
    80004c3e:	c3d5                	beqz	a5,80004ce2 <fileread+0xb6>
    80004c40:	84aa                	mv	s1,a0
    80004c42:	89ae                	mv	s3,a1
    80004c44:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004c46:	411c                	lw	a5,0(a0)
    80004c48:	4705                	li	a4,1
    80004c4a:	04e78963          	beq	a5,a4,80004c9c <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004c4e:	470d                	li	a4,3
    80004c50:	04e78d63          	beq	a5,a4,80004caa <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c54:	4709                	li	a4,2
    80004c56:	06e79e63          	bne	a5,a4,80004cd2 <fileread+0xa6>
    ilock(f->ip);
    80004c5a:	6d08                	ld	a0,24(a0)
    80004c5c:	fffff097          	auipc	ra,0xfffff
    80004c60:	008080e7          	jalr	8(ra) # 80003c64 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004c64:	874a                	mv	a4,s2
    80004c66:	5094                	lw	a3,32(s1)
    80004c68:	864e                	mv	a2,s3
    80004c6a:	4585                	li	a1,1
    80004c6c:	6c88                	ld	a0,24(s1)
    80004c6e:	fffff097          	auipc	ra,0xfffff
    80004c72:	2aa080e7          	jalr	682(ra) # 80003f18 <readi>
    80004c76:	892a                	mv	s2,a0
    80004c78:	00a05563          	blez	a0,80004c82 <fileread+0x56>
      f->off += r;
    80004c7c:	509c                	lw	a5,32(s1)
    80004c7e:	9fa9                	addw	a5,a5,a0
    80004c80:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004c82:	6c88                	ld	a0,24(s1)
    80004c84:	fffff097          	auipc	ra,0xfffff
    80004c88:	0a2080e7          	jalr	162(ra) # 80003d26 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004c8c:	854a                	mv	a0,s2
    80004c8e:	70a2                	ld	ra,40(sp)
    80004c90:	7402                	ld	s0,32(sp)
    80004c92:	64e2                	ld	s1,24(sp)
    80004c94:	6942                	ld	s2,16(sp)
    80004c96:	69a2                	ld	s3,8(sp)
    80004c98:	6145                	addi	sp,sp,48
    80004c9a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004c9c:	6908                	ld	a0,16(a0)
    80004c9e:	00000097          	auipc	ra,0x0
    80004ca2:	3c6080e7          	jalr	966(ra) # 80005064 <piperead>
    80004ca6:	892a                	mv	s2,a0
    80004ca8:	b7d5                	j	80004c8c <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004caa:	02451783          	lh	a5,36(a0)
    80004cae:	03079693          	slli	a3,a5,0x30
    80004cb2:	92c1                	srli	a3,a3,0x30
    80004cb4:	4725                	li	a4,9
    80004cb6:	02d76863          	bltu	a4,a3,80004ce6 <fileread+0xba>
    80004cba:	0792                	slli	a5,a5,0x4
    80004cbc:	0001d717          	auipc	a4,0x1d
    80004cc0:	f5c70713          	addi	a4,a4,-164 # 80021c18 <devsw>
    80004cc4:	97ba                	add	a5,a5,a4
    80004cc6:	639c                	ld	a5,0(a5)
    80004cc8:	c38d                	beqz	a5,80004cea <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004cca:	4505                	li	a0,1
    80004ccc:	9782                	jalr	a5
    80004cce:	892a                	mv	s2,a0
    80004cd0:	bf75                	j	80004c8c <fileread+0x60>
    panic("fileread");
    80004cd2:	00004517          	auipc	a0,0x4
    80004cd6:	a2650513          	addi	a0,a0,-1498 # 800086f8 <syscalls+0x280>
    80004cda:	ffffc097          	auipc	ra,0xffffc
    80004cde:	864080e7          	jalr	-1948(ra) # 8000053e <panic>
    return -1;
    80004ce2:	597d                	li	s2,-1
    80004ce4:	b765                	j	80004c8c <fileread+0x60>
      return -1;
    80004ce6:	597d                	li	s2,-1
    80004ce8:	b755                	j	80004c8c <fileread+0x60>
    80004cea:	597d                	li	s2,-1
    80004cec:	b745                	j	80004c8c <fileread+0x60>

0000000080004cee <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004cee:	715d                	addi	sp,sp,-80
    80004cf0:	e486                	sd	ra,72(sp)
    80004cf2:	e0a2                	sd	s0,64(sp)
    80004cf4:	fc26                	sd	s1,56(sp)
    80004cf6:	f84a                	sd	s2,48(sp)
    80004cf8:	f44e                	sd	s3,40(sp)
    80004cfa:	f052                	sd	s4,32(sp)
    80004cfc:	ec56                	sd	s5,24(sp)
    80004cfe:	e85a                	sd	s6,16(sp)
    80004d00:	e45e                	sd	s7,8(sp)
    80004d02:	e062                	sd	s8,0(sp)
    80004d04:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004d06:	00954783          	lbu	a5,9(a0)
    80004d0a:	10078663          	beqz	a5,80004e16 <filewrite+0x128>
    80004d0e:	892a                	mv	s2,a0
    80004d10:	8aae                	mv	s5,a1
    80004d12:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004d14:	411c                	lw	a5,0(a0)
    80004d16:	4705                	li	a4,1
    80004d18:	02e78263          	beq	a5,a4,80004d3c <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004d1c:	470d                	li	a4,3
    80004d1e:	02e78663          	beq	a5,a4,80004d4a <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004d22:	4709                	li	a4,2
    80004d24:	0ee79163          	bne	a5,a4,80004e06 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004d28:	0ac05d63          	blez	a2,80004de2 <filewrite+0xf4>
    int i = 0;
    80004d2c:	4981                	li	s3,0
    80004d2e:	6b05                	lui	s6,0x1
    80004d30:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004d34:	6b85                	lui	s7,0x1
    80004d36:	c00b8b9b          	addiw	s7,s7,-1024
    80004d3a:	a861                	j	80004dd2 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004d3c:	6908                	ld	a0,16(a0)
    80004d3e:	00000097          	auipc	ra,0x0
    80004d42:	22e080e7          	jalr	558(ra) # 80004f6c <pipewrite>
    80004d46:	8a2a                	mv	s4,a0
    80004d48:	a045                	j	80004de8 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004d4a:	02451783          	lh	a5,36(a0)
    80004d4e:	03079693          	slli	a3,a5,0x30
    80004d52:	92c1                	srli	a3,a3,0x30
    80004d54:	4725                	li	a4,9
    80004d56:	0cd76263          	bltu	a4,a3,80004e1a <filewrite+0x12c>
    80004d5a:	0792                	slli	a5,a5,0x4
    80004d5c:	0001d717          	auipc	a4,0x1d
    80004d60:	ebc70713          	addi	a4,a4,-324 # 80021c18 <devsw>
    80004d64:	97ba                	add	a5,a5,a4
    80004d66:	679c                	ld	a5,8(a5)
    80004d68:	cbdd                	beqz	a5,80004e1e <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004d6a:	4505                	li	a0,1
    80004d6c:	9782                	jalr	a5
    80004d6e:	8a2a                	mv	s4,a0
    80004d70:	a8a5                	j	80004de8 <filewrite+0xfa>
    80004d72:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004d76:	00000097          	auipc	ra,0x0
    80004d7a:	8b0080e7          	jalr	-1872(ra) # 80004626 <begin_op>
      ilock(f->ip);
    80004d7e:	01893503          	ld	a0,24(s2)
    80004d82:	fffff097          	auipc	ra,0xfffff
    80004d86:	ee2080e7          	jalr	-286(ra) # 80003c64 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004d8a:	8762                	mv	a4,s8
    80004d8c:	02092683          	lw	a3,32(s2)
    80004d90:	01598633          	add	a2,s3,s5
    80004d94:	4585                	li	a1,1
    80004d96:	01893503          	ld	a0,24(s2)
    80004d9a:	fffff097          	auipc	ra,0xfffff
    80004d9e:	276080e7          	jalr	630(ra) # 80004010 <writei>
    80004da2:	84aa                	mv	s1,a0
    80004da4:	00a05763          	blez	a0,80004db2 <filewrite+0xc4>
        f->off += r;
    80004da8:	02092783          	lw	a5,32(s2)
    80004dac:	9fa9                	addw	a5,a5,a0
    80004dae:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004db2:	01893503          	ld	a0,24(s2)
    80004db6:	fffff097          	auipc	ra,0xfffff
    80004dba:	f70080e7          	jalr	-144(ra) # 80003d26 <iunlock>
      end_op();
    80004dbe:	00000097          	auipc	ra,0x0
    80004dc2:	8e8080e7          	jalr	-1816(ra) # 800046a6 <end_op>

      if(r != n1){
    80004dc6:	009c1f63          	bne	s8,s1,80004de4 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004dca:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004dce:	0149db63          	bge	s3,s4,80004de4 <filewrite+0xf6>
      int n1 = n - i;
    80004dd2:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004dd6:	84be                	mv	s1,a5
    80004dd8:	2781                	sext.w	a5,a5
    80004dda:	f8fb5ce3          	bge	s6,a5,80004d72 <filewrite+0x84>
    80004dde:	84de                	mv	s1,s7
    80004de0:	bf49                	j	80004d72 <filewrite+0x84>
    int i = 0;
    80004de2:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004de4:	013a1f63          	bne	s4,s3,80004e02 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004de8:	8552                	mv	a0,s4
    80004dea:	60a6                	ld	ra,72(sp)
    80004dec:	6406                	ld	s0,64(sp)
    80004dee:	74e2                	ld	s1,56(sp)
    80004df0:	7942                	ld	s2,48(sp)
    80004df2:	79a2                	ld	s3,40(sp)
    80004df4:	7a02                	ld	s4,32(sp)
    80004df6:	6ae2                	ld	s5,24(sp)
    80004df8:	6b42                	ld	s6,16(sp)
    80004dfa:	6ba2                	ld	s7,8(sp)
    80004dfc:	6c02                	ld	s8,0(sp)
    80004dfe:	6161                	addi	sp,sp,80
    80004e00:	8082                	ret
    ret = (i == n ? n : -1);
    80004e02:	5a7d                	li	s4,-1
    80004e04:	b7d5                	j	80004de8 <filewrite+0xfa>
    panic("filewrite");
    80004e06:	00004517          	auipc	a0,0x4
    80004e0a:	90250513          	addi	a0,a0,-1790 # 80008708 <syscalls+0x290>
    80004e0e:	ffffb097          	auipc	ra,0xffffb
    80004e12:	730080e7          	jalr	1840(ra) # 8000053e <panic>
    return -1;
    80004e16:	5a7d                	li	s4,-1
    80004e18:	bfc1                	j	80004de8 <filewrite+0xfa>
      return -1;
    80004e1a:	5a7d                	li	s4,-1
    80004e1c:	b7f1                	j	80004de8 <filewrite+0xfa>
    80004e1e:	5a7d                	li	s4,-1
    80004e20:	b7e1                	j	80004de8 <filewrite+0xfa>

0000000080004e22 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004e22:	7179                	addi	sp,sp,-48
    80004e24:	f406                	sd	ra,40(sp)
    80004e26:	f022                	sd	s0,32(sp)
    80004e28:	ec26                	sd	s1,24(sp)
    80004e2a:	e84a                	sd	s2,16(sp)
    80004e2c:	e44e                	sd	s3,8(sp)
    80004e2e:	e052                	sd	s4,0(sp)
    80004e30:	1800                	addi	s0,sp,48
    80004e32:	84aa                	mv	s1,a0
    80004e34:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004e36:	0005b023          	sd	zero,0(a1)
    80004e3a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004e3e:	00000097          	auipc	ra,0x0
    80004e42:	bf8080e7          	jalr	-1032(ra) # 80004a36 <filealloc>
    80004e46:	e088                	sd	a0,0(s1)
    80004e48:	c551                	beqz	a0,80004ed4 <pipealloc+0xb2>
    80004e4a:	00000097          	auipc	ra,0x0
    80004e4e:	bec080e7          	jalr	-1044(ra) # 80004a36 <filealloc>
    80004e52:	00aa3023          	sd	a0,0(s4)
    80004e56:	c92d                	beqz	a0,80004ec8 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004e58:	ffffc097          	auipc	ra,0xffffc
    80004e5c:	c8e080e7          	jalr	-882(ra) # 80000ae6 <kalloc>
    80004e60:	892a                	mv	s2,a0
    80004e62:	c125                	beqz	a0,80004ec2 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004e64:	4985                	li	s3,1
    80004e66:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004e6a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004e6e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004e72:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004e76:	00004597          	auipc	a1,0x4
    80004e7a:	8a258593          	addi	a1,a1,-1886 # 80008718 <syscalls+0x2a0>
    80004e7e:	ffffc097          	auipc	ra,0xffffc
    80004e82:	cc8080e7          	jalr	-824(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004e86:	609c                	ld	a5,0(s1)
    80004e88:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004e8c:	609c                	ld	a5,0(s1)
    80004e8e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004e92:	609c                	ld	a5,0(s1)
    80004e94:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004e98:	609c                	ld	a5,0(s1)
    80004e9a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004e9e:	000a3783          	ld	a5,0(s4)
    80004ea2:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004ea6:	000a3783          	ld	a5,0(s4)
    80004eaa:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004eae:	000a3783          	ld	a5,0(s4)
    80004eb2:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004eb6:	000a3783          	ld	a5,0(s4)
    80004eba:	0127b823          	sd	s2,16(a5)
  return 0;
    80004ebe:	4501                	li	a0,0
    80004ec0:	a025                	j	80004ee8 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004ec2:	6088                	ld	a0,0(s1)
    80004ec4:	e501                	bnez	a0,80004ecc <pipealloc+0xaa>
    80004ec6:	a039                	j	80004ed4 <pipealloc+0xb2>
    80004ec8:	6088                	ld	a0,0(s1)
    80004eca:	c51d                	beqz	a0,80004ef8 <pipealloc+0xd6>
    fileclose(*f0);
    80004ecc:	00000097          	auipc	ra,0x0
    80004ed0:	c26080e7          	jalr	-986(ra) # 80004af2 <fileclose>
  if(*f1)
    80004ed4:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004ed8:	557d                	li	a0,-1
  if(*f1)
    80004eda:	c799                	beqz	a5,80004ee8 <pipealloc+0xc6>
    fileclose(*f1);
    80004edc:	853e                	mv	a0,a5
    80004ede:	00000097          	auipc	ra,0x0
    80004ee2:	c14080e7          	jalr	-1004(ra) # 80004af2 <fileclose>
  return -1;
    80004ee6:	557d                	li	a0,-1
}
    80004ee8:	70a2                	ld	ra,40(sp)
    80004eea:	7402                	ld	s0,32(sp)
    80004eec:	64e2                	ld	s1,24(sp)
    80004eee:	6942                	ld	s2,16(sp)
    80004ef0:	69a2                	ld	s3,8(sp)
    80004ef2:	6a02                	ld	s4,0(sp)
    80004ef4:	6145                	addi	sp,sp,48
    80004ef6:	8082                	ret
  return -1;
    80004ef8:	557d                	li	a0,-1
    80004efa:	b7fd                	j	80004ee8 <pipealloc+0xc6>

0000000080004efc <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004efc:	1101                	addi	sp,sp,-32
    80004efe:	ec06                	sd	ra,24(sp)
    80004f00:	e822                	sd	s0,16(sp)
    80004f02:	e426                	sd	s1,8(sp)
    80004f04:	e04a                	sd	s2,0(sp)
    80004f06:	1000                	addi	s0,sp,32
    80004f08:	84aa                	mv	s1,a0
    80004f0a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004f0c:	ffffc097          	auipc	ra,0xffffc
    80004f10:	cca080e7          	jalr	-822(ra) # 80000bd6 <acquire>
  if(writable){
    80004f14:	02090d63          	beqz	s2,80004f4e <pipeclose+0x52>
    pi->writeopen = 0;
    80004f18:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004f1c:	21848513          	addi	a0,s1,536
    80004f20:	ffffd097          	auipc	ra,0xffffd
    80004f24:	52a080e7          	jalr	1322(ra) # 8000244a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004f28:	2204b783          	ld	a5,544(s1)
    80004f2c:	eb95                	bnez	a5,80004f60 <pipeclose+0x64>
    release(&pi->lock);
    80004f2e:	8526                	mv	a0,s1
    80004f30:	ffffc097          	auipc	ra,0xffffc
    80004f34:	d5a080e7          	jalr	-678(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004f38:	8526                	mv	a0,s1
    80004f3a:	ffffc097          	auipc	ra,0xffffc
    80004f3e:	ab0080e7          	jalr	-1360(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    80004f42:	60e2                	ld	ra,24(sp)
    80004f44:	6442                	ld	s0,16(sp)
    80004f46:	64a2                	ld	s1,8(sp)
    80004f48:	6902                	ld	s2,0(sp)
    80004f4a:	6105                	addi	sp,sp,32
    80004f4c:	8082                	ret
    pi->readopen = 0;
    80004f4e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004f52:	21c48513          	addi	a0,s1,540
    80004f56:	ffffd097          	auipc	ra,0xffffd
    80004f5a:	4f4080e7          	jalr	1268(ra) # 8000244a <wakeup>
    80004f5e:	b7e9                	j	80004f28 <pipeclose+0x2c>
    release(&pi->lock);
    80004f60:	8526                	mv	a0,s1
    80004f62:	ffffc097          	auipc	ra,0xffffc
    80004f66:	d28080e7          	jalr	-728(ra) # 80000c8a <release>
}
    80004f6a:	bfe1                	j	80004f42 <pipeclose+0x46>

0000000080004f6c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004f6c:	711d                	addi	sp,sp,-96
    80004f6e:	ec86                	sd	ra,88(sp)
    80004f70:	e8a2                	sd	s0,80(sp)
    80004f72:	e4a6                	sd	s1,72(sp)
    80004f74:	e0ca                	sd	s2,64(sp)
    80004f76:	fc4e                	sd	s3,56(sp)
    80004f78:	f852                	sd	s4,48(sp)
    80004f7a:	f456                	sd	s5,40(sp)
    80004f7c:	f05a                	sd	s6,32(sp)
    80004f7e:	ec5e                	sd	s7,24(sp)
    80004f80:	e862                	sd	s8,16(sp)
    80004f82:	1080                	addi	s0,sp,96
    80004f84:	84aa                	mv	s1,a0
    80004f86:	8aae                	mv	s5,a1
    80004f88:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004f8a:	ffffd097          	auipc	ra,0xffffd
    80004f8e:	a56080e7          	jalr	-1450(ra) # 800019e0 <myproc>
    80004f92:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004f94:	8526                	mv	a0,s1
    80004f96:	ffffc097          	auipc	ra,0xffffc
    80004f9a:	c40080e7          	jalr	-960(ra) # 80000bd6 <acquire>
  while(i < n){
    80004f9e:	0b405663          	blez	s4,8000504a <pipewrite+0xde>
  int i = 0;
    80004fa2:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004fa4:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004fa6:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004faa:	21c48b93          	addi	s7,s1,540
    80004fae:	a089                	j	80004ff0 <pipewrite+0x84>
      release(&pi->lock);
    80004fb0:	8526                	mv	a0,s1
    80004fb2:	ffffc097          	auipc	ra,0xffffc
    80004fb6:	cd8080e7          	jalr	-808(ra) # 80000c8a <release>
      return -1;
    80004fba:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004fbc:	854a                	mv	a0,s2
    80004fbe:	60e6                	ld	ra,88(sp)
    80004fc0:	6446                	ld	s0,80(sp)
    80004fc2:	64a6                	ld	s1,72(sp)
    80004fc4:	6906                	ld	s2,64(sp)
    80004fc6:	79e2                	ld	s3,56(sp)
    80004fc8:	7a42                	ld	s4,48(sp)
    80004fca:	7aa2                	ld	s5,40(sp)
    80004fcc:	7b02                	ld	s6,32(sp)
    80004fce:	6be2                	ld	s7,24(sp)
    80004fd0:	6c42                	ld	s8,16(sp)
    80004fd2:	6125                	addi	sp,sp,96
    80004fd4:	8082                	ret
      wakeup(&pi->nread);
    80004fd6:	8562                	mv	a0,s8
    80004fd8:	ffffd097          	auipc	ra,0xffffd
    80004fdc:	472080e7          	jalr	1138(ra) # 8000244a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004fe0:	85a6                	mv	a1,s1
    80004fe2:	855e                	mv	a0,s7
    80004fe4:	ffffd097          	auipc	ra,0xffffd
    80004fe8:	37e080e7          	jalr	894(ra) # 80002362 <sleep>
  while(i < n){
    80004fec:	07495063          	bge	s2,s4,8000504c <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004ff0:	2204a783          	lw	a5,544(s1)
    80004ff4:	dfd5                	beqz	a5,80004fb0 <pipewrite+0x44>
    80004ff6:	854e                	mv	a0,s3
    80004ff8:	ffffd097          	auipc	ra,0xffffd
    80004ffc:	6be080e7          	jalr	1726(ra) # 800026b6 <killed>
    80005000:	f945                	bnez	a0,80004fb0 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005002:	2184a783          	lw	a5,536(s1)
    80005006:	21c4a703          	lw	a4,540(s1)
    8000500a:	2007879b          	addiw	a5,a5,512
    8000500e:	fcf704e3          	beq	a4,a5,80004fd6 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005012:	4685                	li	a3,1
    80005014:	01590633          	add	a2,s2,s5
    80005018:	faf40593          	addi	a1,s0,-81
    8000501c:	0909b503          	ld	a0,144(s3)
    80005020:	ffffc097          	auipc	ra,0xffffc
    80005024:	6d4080e7          	jalr	1748(ra) # 800016f4 <copyin>
    80005028:	03650263          	beq	a0,s6,8000504c <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000502c:	21c4a783          	lw	a5,540(s1)
    80005030:	0017871b          	addiw	a4,a5,1
    80005034:	20e4ae23          	sw	a4,540(s1)
    80005038:	1ff7f793          	andi	a5,a5,511
    8000503c:	97a6                	add	a5,a5,s1
    8000503e:	faf44703          	lbu	a4,-81(s0)
    80005042:	00e78c23          	sb	a4,24(a5)
      i++;
    80005046:	2905                	addiw	s2,s2,1
    80005048:	b755                	j	80004fec <pipewrite+0x80>
  int i = 0;
    8000504a:	4901                	li	s2,0
  wakeup(&pi->nread);
    8000504c:	21848513          	addi	a0,s1,536
    80005050:	ffffd097          	auipc	ra,0xffffd
    80005054:	3fa080e7          	jalr	1018(ra) # 8000244a <wakeup>
  release(&pi->lock);
    80005058:	8526                	mv	a0,s1
    8000505a:	ffffc097          	auipc	ra,0xffffc
    8000505e:	c30080e7          	jalr	-976(ra) # 80000c8a <release>
  return i;
    80005062:	bfa9                	j	80004fbc <pipewrite+0x50>

0000000080005064 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005064:	715d                	addi	sp,sp,-80
    80005066:	e486                	sd	ra,72(sp)
    80005068:	e0a2                	sd	s0,64(sp)
    8000506a:	fc26                	sd	s1,56(sp)
    8000506c:	f84a                	sd	s2,48(sp)
    8000506e:	f44e                	sd	s3,40(sp)
    80005070:	f052                	sd	s4,32(sp)
    80005072:	ec56                	sd	s5,24(sp)
    80005074:	e85a                	sd	s6,16(sp)
    80005076:	0880                	addi	s0,sp,80
    80005078:	84aa                	mv	s1,a0
    8000507a:	892e                	mv	s2,a1
    8000507c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000507e:	ffffd097          	auipc	ra,0xffffd
    80005082:	962080e7          	jalr	-1694(ra) # 800019e0 <myproc>
    80005086:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005088:	8526                	mv	a0,s1
    8000508a:	ffffc097          	auipc	ra,0xffffc
    8000508e:	b4c080e7          	jalr	-1204(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005092:	2184a703          	lw	a4,536(s1)
    80005096:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000509a:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000509e:	02f71763          	bne	a4,a5,800050cc <piperead+0x68>
    800050a2:	2244a783          	lw	a5,548(s1)
    800050a6:	c39d                	beqz	a5,800050cc <piperead+0x68>
    if(killed(pr)){
    800050a8:	8552                	mv	a0,s4
    800050aa:	ffffd097          	auipc	ra,0xffffd
    800050ae:	60c080e7          	jalr	1548(ra) # 800026b6 <killed>
    800050b2:	e941                	bnez	a0,80005142 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800050b4:	85a6                	mv	a1,s1
    800050b6:	854e                	mv	a0,s3
    800050b8:	ffffd097          	auipc	ra,0xffffd
    800050bc:	2aa080e7          	jalr	682(ra) # 80002362 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800050c0:	2184a703          	lw	a4,536(s1)
    800050c4:	21c4a783          	lw	a5,540(s1)
    800050c8:	fcf70de3          	beq	a4,a5,800050a2 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050cc:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800050ce:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050d0:	05505363          	blez	s5,80005116 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    800050d4:	2184a783          	lw	a5,536(s1)
    800050d8:	21c4a703          	lw	a4,540(s1)
    800050dc:	02f70d63          	beq	a4,a5,80005116 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800050e0:	0017871b          	addiw	a4,a5,1
    800050e4:	20e4ac23          	sw	a4,536(s1)
    800050e8:	1ff7f793          	andi	a5,a5,511
    800050ec:	97a6                	add	a5,a5,s1
    800050ee:	0187c783          	lbu	a5,24(a5)
    800050f2:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800050f6:	4685                	li	a3,1
    800050f8:	fbf40613          	addi	a2,s0,-65
    800050fc:	85ca                	mv	a1,s2
    800050fe:	090a3503          	ld	a0,144(s4)
    80005102:	ffffc097          	auipc	ra,0xffffc
    80005106:	566080e7          	jalr	1382(ra) # 80001668 <copyout>
    8000510a:	01650663          	beq	a0,s6,80005116 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000510e:	2985                	addiw	s3,s3,1
    80005110:	0905                	addi	s2,s2,1
    80005112:	fd3a91e3          	bne	s5,s3,800050d4 <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005116:	21c48513          	addi	a0,s1,540
    8000511a:	ffffd097          	auipc	ra,0xffffd
    8000511e:	330080e7          	jalr	816(ra) # 8000244a <wakeup>
  release(&pi->lock);
    80005122:	8526                	mv	a0,s1
    80005124:	ffffc097          	auipc	ra,0xffffc
    80005128:	b66080e7          	jalr	-1178(ra) # 80000c8a <release>
  return i;
}
    8000512c:	854e                	mv	a0,s3
    8000512e:	60a6                	ld	ra,72(sp)
    80005130:	6406                	ld	s0,64(sp)
    80005132:	74e2                	ld	s1,56(sp)
    80005134:	7942                	ld	s2,48(sp)
    80005136:	79a2                	ld	s3,40(sp)
    80005138:	7a02                	ld	s4,32(sp)
    8000513a:	6ae2                	ld	s5,24(sp)
    8000513c:	6b42                	ld	s6,16(sp)
    8000513e:	6161                	addi	sp,sp,80
    80005140:	8082                	ret
      release(&pi->lock);
    80005142:	8526                	mv	a0,s1
    80005144:	ffffc097          	auipc	ra,0xffffc
    80005148:	b46080e7          	jalr	-1210(ra) # 80000c8a <release>
      return -1;
    8000514c:	59fd                	li	s3,-1
    8000514e:	bff9                	j	8000512c <piperead+0xc8>

0000000080005150 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80005150:	1141                	addi	sp,sp,-16
    80005152:	e422                	sd	s0,8(sp)
    80005154:	0800                	addi	s0,sp,16
    80005156:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80005158:	8905                	andi	a0,a0,1
    8000515a:	c111                	beqz	a0,8000515e <flags2perm+0xe>
      perm = PTE_X;
    8000515c:	4521                	li	a0,8
    if(flags & 0x2)
    8000515e:	8b89                	andi	a5,a5,2
    80005160:	c399                	beqz	a5,80005166 <flags2perm+0x16>
      perm |= PTE_W;
    80005162:	00456513          	ori	a0,a0,4
    return perm;
}
    80005166:	6422                	ld	s0,8(sp)
    80005168:	0141                	addi	sp,sp,16
    8000516a:	8082                	ret

000000008000516c <exec>:

int
exec(char *path, char **argv)
{
    8000516c:	de010113          	addi	sp,sp,-544
    80005170:	20113c23          	sd	ra,536(sp)
    80005174:	20813823          	sd	s0,528(sp)
    80005178:	20913423          	sd	s1,520(sp)
    8000517c:	21213023          	sd	s2,512(sp)
    80005180:	ffce                	sd	s3,504(sp)
    80005182:	fbd2                	sd	s4,496(sp)
    80005184:	f7d6                	sd	s5,488(sp)
    80005186:	f3da                	sd	s6,480(sp)
    80005188:	efde                	sd	s7,472(sp)
    8000518a:	ebe2                	sd	s8,464(sp)
    8000518c:	e7e6                	sd	s9,456(sp)
    8000518e:	e3ea                	sd	s10,448(sp)
    80005190:	ff6e                	sd	s11,440(sp)
    80005192:	1400                	addi	s0,sp,544
    80005194:	892a                	mv	s2,a0
    80005196:	dea43423          	sd	a0,-536(s0)
    8000519a:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000519e:	ffffd097          	auipc	ra,0xffffd
    800051a2:	842080e7          	jalr	-1982(ra) # 800019e0 <myproc>
    800051a6:	84aa                	mv	s1,a0

  begin_op();
    800051a8:	fffff097          	auipc	ra,0xfffff
    800051ac:	47e080e7          	jalr	1150(ra) # 80004626 <begin_op>

  if((ip = namei(path)) == 0){
    800051b0:	854a                	mv	a0,s2
    800051b2:	fffff097          	auipc	ra,0xfffff
    800051b6:	258080e7          	jalr	600(ra) # 8000440a <namei>
    800051ba:	c93d                	beqz	a0,80005230 <exec+0xc4>
    800051bc:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800051be:	fffff097          	auipc	ra,0xfffff
    800051c2:	aa6080e7          	jalr	-1370(ra) # 80003c64 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800051c6:	04000713          	li	a4,64
    800051ca:	4681                	li	a3,0
    800051cc:	e5040613          	addi	a2,s0,-432
    800051d0:	4581                	li	a1,0
    800051d2:	8556                	mv	a0,s5
    800051d4:	fffff097          	auipc	ra,0xfffff
    800051d8:	d44080e7          	jalr	-700(ra) # 80003f18 <readi>
    800051dc:	04000793          	li	a5,64
    800051e0:	00f51a63          	bne	a0,a5,800051f4 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800051e4:	e5042703          	lw	a4,-432(s0)
    800051e8:	464c47b7          	lui	a5,0x464c4
    800051ec:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800051f0:	04f70663          	beq	a4,a5,8000523c <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800051f4:	8556                	mv	a0,s5
    800051f6:	fffff097          	auipc	ra,0xfffff
    800051fa:	cd0080e7          	jalr	-816(ra) # 80003ec6 <iunlockput>
    end_op();
    800051fe:	fffff097          	auipc	ra,0xfffff
    80005202:	4a8080e7          	jalr	1192(ra) # 800046a6 <end_op>
  }
  return -1;
    80005206:	557d                	li	a0,-1
}
    80005208:	21813083          	ld	ra,536(sp)
    8000520c:	21013403          	ld	s0,528(sp)
    80005210:	20813483          	ld	s1,520(sp)
    80005214:	20013903          	ld	s2,512(sp)
    80005218:	79fe                	ld	s3,504(sp)
    8000521a:	7a5e                	ld	s4,496(sp)
    8000521c:	7abe                	ld	s5,488(sp)
    8000521e:	7b1e                	ld	s6,480(sp)
    80005220:	6bfe                	ld	s7,472(sp)
    80005222:	6c5e                	ld	s8,464(sp)
    80005224:	6cbe                	ld	s9,456(sp)
    80005226:	6d1e                	ld	s10,448(sp)
    80005228:	7dfa                	ld	s11,440(sp)
    8000522a:	22010113          	addi	sp,sp,544
    8000522e:	8082                	ret
    end_op();
    80005230:	fffff097          	auipc	ra,0xfffff
    80005234:	476080e7          	jalr	1142(ra) # 800046a6 <end_op>
    return -1;
    80005238:	557d                	li	a0,-1
    8000523a:	b7f9                	j	80005208 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    8000523c:	8526                	mv	a0,s1
    8000523e:	ffffd097          	auipc	ra,0xffffd
    80005242:	866080e7          	jalr	-1946(ra) # 80001aa4 <proc_pagetable>
    80005246:	8b2a                	mv	s6,a0
    80005248:	d555                	beqz	a0,800051f4 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000524a:	e7042783          	lw	a5,-400(s0)
    8000524e:	e8845703          	lhu	a4,-376(s0)
    80005252:	c735                	beqz	a4,800052be <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005254:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005256:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    8000525a:	6a05                	lui	s4,0x1
    8000525c:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005260:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80005264:	6d85                	lui	s11,0x1
    80005266:	7d7d                	lui	s10,0xfffff
    80005268:	a481                	j	800054a8 <exec+0x33c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000526a:	00003517          	auipc	a0,0x3
    8000526e:	4b650513          	addi	a0,a0,1206 # 80008720 <syscalls+0x2a8>
    80005272:	ffffb097          	auipc	ra,0xffffb
    80005276:	2cc080e7          	jalr	716(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000527a:	874a                	mv	a4,s2
    8000527c:	009c86bb          	addw	a3,s9,s1
    80005280:	4581                	li	a1,0
    80005282:	8556                	mv	a0,s5
    80005284:	fffff097          	auipc	ra,0xfffff
    80005288:	c94080e7          	jalr	-876(ra) # 80003f18 <readi>
    8000528c:	2501                	sext.w	a0,a0
    8000528e:	1aa91a63          	bne	s2,a0,80005442 <exec+0x2d6>
  for(i = 0; i < sz; i += PGSIZE){
    80005292:	009d84bb          	addw	s1,s11,s1
    80005296:	013d09bb          	addw	s3,s10,s3
    8000529a:	1f74f763          	bgeu	s1,s7,80005488 <exec+0x31c>
    pa = walkaddr(pagetable, va + i);
    8000529e:	02049593          	slli	a1,s1,0x20
    800052a2:	9181                	srli	a1,a1,0x20
    800052a4:	95e2                	add	a1,a1,s8
    800052a6:	855a                	mv	a0,s6
    800052a8:	ffffc097          	auipc	ra,0xffffc
    800052ac:	db4080e7          	jalr	-588(ra) # 8000105c <walkaddr>
    800052b0:	862a                	mv	a2,a0
    if(pa == 0)
    800052b2:	dd45                	beqz	a0,8000526a <exec+0xfe>
      n = PGSIZE;
    800052b4:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    800052b6:	fd49f2e3          	bgeu	s3,s4,8000527a <exec+0x10e>
      n = sz - i;
    800052ba:	894e                	mv	s2,s3
    800052bc:	bf7d                	j	8000527a <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800052be:	4901                	li	s2,0
  iunlockput(ip);
    800052c0:	8556                	mv	a0,s5
    800052c2:	fffff097          	auipc	ra,0xfffff
    800052c6:	c04080e7          	jalr	-1020(ra) # 80003ec6 <iunlockput>
  end_op();
    800052ca:	fffff097          	auipc	ra,0xfffff
    800052ce:	3dc080e7          	jalr	988(ra) # 800046a6 <end_op>
  p = myproc();
    800052d2:	ffffc097          	auipc	ra,0xffffc
    800052d6:	70e080e7          	jalr	1806(ra) # 800019e0 <myproc>
    800052da:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    800052dc:	08853d03          	ld	s10,136(a0)
  sz = PGROUNDUP(sz);
    800052e0:	6785                	lui	a5,0x1
    800052e2:	17fd                	addi	a5,a5,-1
    800052e4:	993e                	add	s2,s2,a5
    800052e6:	77fd                	lui	a5,0xfffff
    800052e8:	00f977b3          	and	a5,s2,a5
    800052ec:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800052f0:	4691                	li	a3,4
    800052f2:	6609                	lui	a2,0x2
    800052f4:	963e                	add	a2,a2,a5
    800052f6:	85be                	mv	a1,a5
    800052f8:	855a                	mv	a0,s6
    800052fa:	ffffc097          	auipc	ra,0xffffc
    800052fe:	116080e7          	jalr	278(ra) # 80001410 <uvmalloc>
    80005302:	8c2a                	mv	s8,a0
  ip = 0;
    80005304:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005306:	12050e63          	beqz	a0,80005442 <exec+0x2d6>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000530a:	75f9                	lui	a1,0xffffe
    8000530c:	95aa                	add	a1,a1,a0
    8000530e:	855a                	mv	a0,s6
    80005310:	ffffc097          	auipc	ra,0xffffc
    80005314:	326080e7          	jalr	806(ra) # 80001636 <uvmclear>
  stackbase = sp - PGSIZE;
    80005318:	7afd                	lui	s5,0xfffff
    8000531a:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    8000531c:	df043783          	ld	a5,-528(s0)
    80005320:	6388                	ld	a0,0(a5)
    80005322:	c925                	beqz	a0,80005392 <exec+0x226>
    80005324:	e9040993          	addi	s3,s0,-368
    80005328:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    8000532c:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000532e:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005330:	ffffc097          	auipc	ra,0xffffc
    80005334:	b1e080e7          	jalr	-1250(ra) # 80000e4e <strlen>
    80005338:	0015079b          	addiw	a5,a0,1
    8000533c:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005340:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005344:	13596663          	bltu	s2,s5,80005470 <exec+0x304>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005348:	df043d83          	ld	s11,-528(s0)
    8000534c:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005350:	8552                	mv	a0,s4
    80005352:	ffffc097          	auipc	ra,0xffffc
    80005356:	afc080e7          	jalr	-1284(ra) # 80000e4e <strlen>
    8000535a:	0015069b          	addiw	a3,a0,1
    8000535e:	8652                	mv	a2,s4
    80005360:	85ca                	mv	a1,s2
    80005362:	855a                	mv	a0,s6
    80005364:	ffffc097          	auipc	ra,0xffffc
    80005368:	304080e7          	jalr	772(ra) # 80001668 <copyout>
    8000536c:	10054663          	bltz	a0,80005478 <exec+0x30c>
    ustack[argc] = sp;
    80005370:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005374:	0485                	addi	s1,s1,1
    80005376:	008d8793          	addi	a5,s11,8
    8000537a:	def43823          	sd	a5,-528(s0)
    8000537e:	008db503          	ld	a0,8(s11)
    80005382:	c911                	beqz	a0,80005396 <exec+0x22a>
    if(argc >= MAXARG)
    80005384:	09a1                	addi	s3,s3,8
    80005386:	fb3c95e3          	bne	s9,s3,80005330 <exec+0x1c4>
  sz = sz1;
    8000538a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000538e:	4a81                	li	s5,0
    80005390:	a84d                	j	80005442 <exec+0x2d6>
  sp = sz;
    80005392:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005394:	4481                	li	s1,0
  ustack[argc] = 0;
    80005396:	00349793          	slli	a5,s1,0x3
    8000539a:	f9040713          	addi	a4,s0,-112
    8000539e:	97ba                	add	a5,a5,a4
    800053a0:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffdc150>
  sp -= (argc+1) * sizeof(uint64);
    800053a4:	00148693          	addi	a3,s1,1
    800053a8:	068e                	slli	a3,a3,0x3
    800053aa:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800053ae:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800053b2:	01597663          	bgeu	s2,s5,800053be <exec+0x252>
  sz = sz1;
    800053b6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800053ba:	4a81                	li	s5,0
    800053bc:	a059                	j	80005442 <exec+0x2d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800053be:	e9040613          	addi	a2,s0,-368
    800053c2:	85ca                	mv	a1,s2
    800053c4:	855a                	mv	a0,s6
    800053c6:	ffffc097          	auipc	ra,0xffffc
    800053ca:	2a2080e7          	jalr	674(ra) # 80001668 <copyout>
    800053ce:	0a054963          	bltz	a0,80005480 <exec+0x314>
  p->trapframe->a1 = sp;
    800053d2:	098bb783          	ld	a5,152(s7) # 1098 <_entry-0x7fffef68>
    800053d6:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800053da:	de843783          	ld	a5,-536(s0)
    800053de:	0007c703          	lbu	a4,0(a5)
    800053e2:	cf11                	beqz	a4,800053fe <exec+0x292>
    800053e4:	0785                	addi	a5,a5,1
    if(*s == '/')
    800053e6:	02f00693          	li	a3,47
    800053ea:	a039                	j	800053f8 <exec+0x28c>
      last = s+1;
    800053ec:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800053f0:	0785                	addi	a5,a5,1
    800053f2:	fff7c703          	lbu	a4,-1(a5)
    800053f6:	c701                	beqz	a4,800053fe <exec+0x292>
    if(*s == '/')
    800053f8:	fed71ce3          	bne	a4,a3,800053f0 <exec+0x284>
    800053fc:	bfc5                	j	800053ec <exec+0x280>
  safestrcpy(p->name, last, sizeof(p->name));
    800053fe:	4641                	li	a2,16
    80005400:	de843583          	ld	a1,-536(s0)
    80005404:	198b8513          	addi	a0,s7,408
    80005408:	ffffc097          	auipc	ra,0xffffc
    8000540c:	a14080e7          	jalr	-1516(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    80005410:	090bb503          	ld	a0,144(s7)
  p->pagetable = pagetable;
    80005414:	096bb823          	sd	s6,144(s7)
  p->sz = sz;
    80005418:	098bb423          	sd	s8,136(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000541c:	098bb783          	ld	a5,152(s7)
    80005420:	e6843703          	ld	a4,-408(s0)
    80005424:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005426:	098bb783          	ld	a5,152(s7)
    8000542a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000542e:	85ea                	mv	a1,s10
    80005430:	ffffc097          	auipc	ra,0xffffc
    80005434:	710080e7          	jalr	1808(ra) # 80001b40 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005438:	0004851b          	sext.w	a0,s1
    8000543c:	b3f1                	j	80005208 <exec+0x9c>
    8000543e:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005442:	df843583          	ld	a1,-520(s0)
    80005446:	855a                	mv	a0,s6
    80005448:	ffffc097          	auipc	ra,0xffffc
    8000544c:	6f8080e7          	jalr	1784(ra) # 80001b40 <proc_freepagetable>
  if(ip){
    80005450:	da0a92e3          	bnez	s5,800051f4 <exec+0x88>
  return -1;
    80005454:	557d                	li	a0,-1
    80005456:	bb4d                	j	80005208 <exec+0x9c>
    80005458:	df243c23          	sd	s2,-520(s0)
    8000545c:	b7dd                	j	80005442 <exec+0x2d6>
    8000545e:	df243c23          	sd	s2,-520(s0)
    80005462:	b7c5                	j	80005442 <exec+0x2d6>
    80005464:	df243c23          	sd	s2,-520(s0)
    80005468:	bfe9                	j	80005442 <exec+0x2d6>
    8000546a:	df243c23          	sd	s2,-520(s0)
    8000546e:	bfd1                	j	80005442 <exec+0x2d6>
  sz = sz1;
    80005470:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005474:	4a81                	li	s5,0
    80005476:	b7f1                	j	80005442 <exec+0x2d6>
  sz = sz1;
    80005478:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000547c:	4a81                	li	s5,0
    8000547e:	b7d1                	j	80005442 <exec+0x2d6>
  sz = sz1;
    80005480:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005484:	4a81                	li	s5,0
    80005486:	bf75                	j	80005442 <exec+0x2d6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005488:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000548c:	e0843783          	ld	a5,-504(s0)
    80005490:	0017869b          	addiw	a3,a5,1
    80005494:	e0d43423          	sd	a3,-504(s0)
    80005498:	e0043783          	ld	a5,-512(s0)
    8000549c:	0387879b          	addiw	a5,a5,56
    800054a0:	e8845703          	lhu	a4,-376(s0)
    800054a4:	e0e6dee3          	bge	a3,a4,800052c0 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800054a8:	2781                	sext.w	a5,a5
    800054aa:	e0f43023          	sd	a5,-512(s0)
    800054ae:	03800713          	li	a4,56
    800054b2:	86be                	mv	a3,a5
    800054b4:	e1840613          	addi	a2,s0,-488
    800054b8:	4581                	li	a1,0
    800054ba:	8556                	mv	a0,s5
    800054bc:	fffff097          	auipc	ra,0xfffff
    800054c0:	a5c080e7          	jalr	-1444(ra) # 80003f18 <readi>
    800054c4:	03800793          	li	a5,56
    800054c8:	f6f51be3          	bne	a0,a5,8000543e <exec+0x2d2>
    if(ph.type != ELF_PROG_LOAD)
    800054cc:	e1842783          	lw	a5,-488(s0)
    800054d0:	4705                	li	a4,1
    800054d2:	fae79de3          	bne	a5,a4,8000548c <exec+0x320>
    if(ph.memsz < ph.filesz)
    800054d6:	e4043483          	ld	s1,-448(s0)
    800054da:	e3843783          	ld	a5,-456(s0)
    800054de:	f6f4ede3          	bltu	s1,a5,80005458 <exec+0x2ec>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800054e2:	e2843783          	ld	a5,-472(s0)
    800054e6:	94be                	add	s1,s1,a5
    800054e8:	f6f4ebe3          	bltu	s1,a5,8000545e <exec+0x2f2>
    if(ph.vaddr % PGSIZE != 0)
    800054ec:	de043703          	ld	a4,-544(s0)
    800054f0:	8ff9                	and	a5,a5,a4
    800054f2:	fbad                	bnez	a5,80005464 <exec+0x2f8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800054f4:	e1c42503          	lw	a0,-484(s0)
    800054f8:	00000097          	auipc	ra,0x0
    800054fc:	c58080e7          	jalr	-936(ra) # 80005150 <flags2perm>
    80005500:	86aa                	mv	a3,a0
    80005502:	8626                	mv	a2,s1
    80005504:	85ca                	mv	a1,s2
    80005506:	855a                	mv	a0,s6
    80005508:	ffffc097          	auipc	ra,0xffffc
    8000550c:	f08080e7          	jalr	-248(ra) # 80001410 <uvmalloc>
    80005510:	dea43c23          	sd	a0,-520(s0)
    80005514:	d939                	beqz	a0,8000546a <exec+0x2fe>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005516:	e2843c03          	ld	s8,-472(s0)
    8000551a:	e2042c83          	lw	s9,-480(s0)
    8000551e:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005522:	f60b83e3          	beqz	s7,80005488 <exec+0x31c>
    80005526:	89de                	mv	s3,s7
    80005528:	4481                	li	s1,0
    8000552a:	bb95                	j	8000529e <exec+0x132>

000000008000552c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000552c:	7179                	addi	sp,sp,-48
    8000552e:	f406                	sd	ra,40(sp)
    80005530:	f022                	sd	s0,32(sp)
    80005532:	ec26                	sd	s1,24(sp)
    80005534:	e84a                	sd	s2,16(sp)
    80005536:	1800                	addi	s0,sp,48
    80005538:	892e                	mv	s2,a1
    8000553a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000553c:	fdc40593          	addi	a1,s0,-36
    80005540:	ffffe097          	auipc	ra,0xffffe
    80005544:	a8a080e7          	jalr	-1398(ra) # 80002fca <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005548:	fdc42703          	lw	a4,-36(s0)
    8000554c:	47bd                	li	a5,15
    8000554e:	02e7eb63          	bltu	a5,a4,80005584 <argfd+0x58>
    80005552:	ffffc097          	auipc	ra,0xffffc
    80005556:	48e080e7          	jalr	1166(ra) # 800019e0 <myproc>
    8000555a:	fdc42703          	lw	a4,-36(s0)
    8000555e:	02270793          	addi	a5,a4,34
    80005562:	078e                	slli	a5,a5,0x3
    80005564:	953e                	add	a0,a0,a5
    80005566:	611c                	ld	a5,0(a0)
    80005568:	c385                	beqz	a5,80005588 <argfd+0x5c>
    return -1;
  if(pfd)
    8000556a:	00090463          	beqz	s2,80005572 <argfd+0x46>
    *pfd = fd;
    8000556e:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005572:	4501                	li	a0,0
  if(pf)
    80005574:	c091                	beqz	s1,80005578 <argfd+0x4c>
    *pf = f;
    80005576:	e09c                	sd	a5,0(s1)
}
    80005578:	70a2                	ld	ra,40(sp)
    8000557a:	7402                	ld	s0,32(sp)
    8000557c:	64e2                	ld	s1,24(sp)
    8000557e:	6942                	ld	s2,16(sp)
    80005580:	6145                	addi	sp,sp,48
    80005582:	8082                	ret
    return -1;
    80005584:	557d                	li	a0,-1
    80005586:	bfcd                	j	80005578 <argfd+0x4c>
    80005588:	557d                	li	a0,-1
    8000558a:	b7fd                	j	80005578 <argfd+0x4c>

000000008000558c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000558c:	1101                	addi	sp,sp,-32
    8000558e:	ec06                	sd	ra,24(sp)
    80005590:	e822                	sd	s0,16(sp)
    80005592:	e426                	sd	s1,8(sp)
    80005594:	1000                	addi	s0,sp,32
    80005596:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005598:	ffffc097          	auipc	ra,0xffffc
    8000559c:	448080e7          	jalr	1096(ra) # 800019e0 <myproc>
    800055a0:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800055a2:	11050793          	addi	a5,a0,272
    800055a6:	4501                	li	a0,0
    800055a8:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800055aa:	6398                	ld	a4,0(a5)
    800055ac:	cb19                	beqz	a4,800055c2 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800055ae:	2505                	addiw	a0,a0,1
    800055b0:	07a1                	addi	a5,a5,8
    800055b2:	fed51ce3          	bne	a0,a3,800055aa <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800055b6:	557d                	li	a0,-1
}
    800055b8:	60e2                	ld	ra,24(sp)
    800055ba:	6442                	ld	s0,16(sp)
    800055bc:	64a2                	ld	s1,8(sp)
    800055be:	6105                	addi	sp,sp,32
    800055c0:	8082                	ret
      p->ofile[fd] = f;
    800055c2:	02250793          	addi	a5,a0,34
    800055c6:	078e                	slli	a5,a5,0x3
    800055c8:	963e                	add	a2,a2,a5
    800055ca:	e204                	sd	s1,0(a2)
      return fd;
    800055cc:	b7f5                	j	800055b8 <fdalloc+0x2c>

00000000800055ce <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800055ce:	715d                	addi	sp,sp,-80
    800055d0:	e486                	sd	ra,72(sp)
    800055d2:	e0a2                	sd	s0,64(sp)
    800055d4:	fc26                	sd	s1,56(sp)
    800055d6:	f84a                	sd	s2,48(sp)
    800055d8:	f44e                	sd	s3,40(sp)
    800055da:	f052                	sd	s4,32(sp)
    800055dc:	ec56                	sd	s5,24(sp)
    800055de:	e85a                	sd	s6,16(sp)
    800055e0:	0880                	addi	s0,sp,80
    800055e2:	8b2e                	mv	s6,a1
    800055e4:	89b2                	mv	s3,a2
    800055e6:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800055e8:	fb040593          	addi	a1,s0,-80
    800055ec:	fffff097          	auipc	ra,0xfffff
    800055f0:	e3c080e7          	jalr	-452(ra) # 80004428 <nameiparent>
    800055f4:	84aa                	mv	s1,a0
    800055f6:	14050f63          	beqz	a0,80005754 <create+0x186>
    return 0;

  ilock(dp);
    800055fa:	ffffe097          	auipc	ra,0xffffe
    800055fe:	66a080e7          	jalr	1642(ra) # 80003c64 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005602:	4601                	li	a2,0
    80005604:	fb040593          	addi	a1,s0,-80
    80005608:	8526                	mv	a0,s1
    8000560a:	fffff097          	auipc	ra,0xfffff
    8000560e:	b3e080e7          	jalr	-1218(ra) # 80004148 <dirlookup>
    80005612:	8aaa                	mv	s5,a0
    80005614:	c931                	beqz	a0,80005668 <create+0x9a>
    iunlockput(dp);
    80005616:	8526                	mv	a0,s1
    80005618:	fffff097          	auipc	ra,0xfffff
    8000561c:	8ae080e7          	jalr	-1874(ra) # 80003ec6 <iunlockput>
    ilock(ip);
    80005620:	8556                	mv	a0,s5
    80005622:	ffffe097          	auipc	ra,0xffffe
    80005626:	642080e7          	jalr	1602(ra) # 80003c64 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000562a:	000b059b          	sext.w	a1,s6
    8000562e:	4789                	li	a5,2
    80005630:	02f59563          	bne	a1,a5,8000565a <create+0x8c>
    80005634:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdc294>
    80005638:	37f9                	addiw	a5,a5,-2
    8000563a:	17c2                	slli	a5,a5,0x30
    8000563c:	93c1                	srli	a5,a5,0x30
    8000563e:	4705                	li	a4,1
    80005640:	00f76d63          	bltu	a4,a5,8000565a <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005644:	8556                	mv	a0,s5
    80005646:	60a6                	ld	ra,72(sp)
    80005648:	6406                	ld	s0,64(sp)
    8000564a:	74e2                	ld	s1,56(sp)
    8000564c:	7942                	ld	s2,48(sp)
    8000564e:	79a2                	ld	s3,40(sp)
    80005650:	7a02                	ld	s4,32(sp)
    80005652:	6ae2                	ld	s5,24(sp)
    80005654:	6b42                	ld	s6,16(sp)
    80005656:	6161                	addi	sp,sp,80
    80005658:	8082                	ret
    iunlockput(ip);
    8000565a:	8556                	mv	a0,s5
    8000565c:	fffff097          	auipc	ra,0xfffff
    80005660:	86a080e7          	jalr	-1942(ra) # 80003ec6 <iunlockput>
    return 0;
    80005664:	4a81                	li	s5,0
    80005666:	bff9                	j	80005644 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005668:	85da                	mv	a1,s6
    8000566a:	4088                	lw	a0,0(s1)
    8000566c:	ffffe097          	auipc	ra,0xffffe
    80005670:	45c080e7          	jalr	1116(ra) # 80003ac8 <ialloc>
    80005674:	8a2a                	mv	s4,a0
    80005676:	c539                	beqz	a0,800056c4 <create+0xf6>
  ilock(ip);
    80005678:	ffffe097          	auipc	ra,0xffffe
    8000567c:	5ec080e7          	jalr	1516(ra) # 80003c64 <ilock>
  ip->major = major;
    80005680:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005684:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005688:	4905                	li	s2,1
    8000568a:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000568e:	8552                	mv	a0,s4
    80005690:	ffffe097          	auipc	ra,0xffffe
    80005694:	50a080e7          	jalr	1290(ra) # 80003b9a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005698:	000b059b          	sext.w	a1,s6
    8000569c:	03258b63          	beq	a1,s2,800056d2 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    800056a0:	004a2603          	lw	a2,4(s4)
    800056a4:	fb040593          	addi	a1,s0,-80
    800056a8:	8526                	mv	a0,s1
    800056aa:	fffff097          	auipc	ra,0xfffff
    800056ae:	cae080e7          	jalr	-850(ra) # 80004358 <dirlink>
    800056b2:	06054f63          	bltz	a0,80005730 <create+0x162>
  iunlockput(dp);
    800056b6:	8526                	mv	a0,s1
    800056b8:	fffff097          	auipc	ra,0xfffff
    800056bc:	80e080e7          	jalr	-2034(ra) # 80003ec6 <iunlockput>
  return ip;
    800056c0:	8ad2                	mv	s5,s4
    800056c2:	b749                	j	80005644 <create+0x76>
    iunlockput(dp);
    800056c4:	8526                	mv	a0,s1
    800056c6:	fffff097          	auipc	ra,0xfffff
    800056ca:	800080e7          	jalr	-2048(ra) # 80003ec6 <iunlockput>
    return 0;
    800056ce:	8ad2                	mv	s5,s4
    800056d0:	bf95                	j	80005644 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800056d2:	004a2603          	lw	a2,4(s4)
    800056d6:	00003597          	auipc	a1,0x3
    800056da:	06a58593          	addi	a1,a1,106 # 80008740 <syscalls+0x2c8>
    800056de:	8552                	mv	a0,s4
    800056e0:	fffff097          	auipc	ra,0xfffff
    800056e4:	c78080e7          	jalr	-904(ra) # 80004358 <dirlink>
    800056e8:	04054463          	bltz	a0,80005730 <create+0x162>
    800056ec:	40d0                	lw	a2,4(s1)
    800056ee:	00003597          	auipc	a1,0x3
    800056f2:	05a58593          	addi	a1,a1,90 # 80008748 <syscalls+0x2d0>
    800056f6:	8552                	mv	a0,s4
    800056f8:	fffff097          	auipc	ra,0xfffff
    800056fc:	c60080e7          	jalr	-928(ra) # 80004358 <dirlink>
    80005700:	02054863          	bltz	a0,80005730 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    80005704:	004a2603          	lw	a2,4(s4)
    80005708:	fb040593          	addi	a1,s0,-80
    8000570c:	8526                	mv	a0,s1
    8000570e:	fffff097          	auipc	ra,0xfffff
    80005712:	c4a080e7          	jalr	-950(ra) # 80004358 <dirlink>
    80005716:	00054d63          	bltz	a0,80005730 <create+0x162>
    dp->nlink++;  // for ".."
    8000571a:	04a4d783          	lhu	a5,74(s1)
    8000571e:	2785                	addiw	a5,a5,1
    80005720:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005724:	8526                	mv	a0,s1
    80005726:	ffffe097          	auipc	ra,0xffffe
    8000572a:	474080e7          	jalr	1140(ra) # 80003b9a <iupdate>
    8000572e:	b761                	j	800056b6 <create+0xe8>
  ip->nlink = 0;
    80005730:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005734:	8552                	mv	a0,s4
    80005736:	ffffe097          	auipc	ra,0xffffe
    8000573a:	464080e7          	jalr	1124(ra) # 80003b9a <iupdate>
  iunlockput(ip);
    8000573e:	8552                	mv	a0,s4
    80005740:	ffffe097          	auipc	ra,0xffffe
    80005744:	786080e7          	jalr	1926(ra) # 80003ec6 <iunlockput>
  iunlockput(dp);
    80005748:	8526                	mv	a0,s1
    8000574a:	ffffe097          	auipc	ra,0xffffe
    8000574e:	77c080e7          	jalr	1916(ra) # 80003ec6 <iunlockput>
  return 0;
    80005752:	bdcd                	j	80005644 <create+0x76>
    return 0;
    80005754:	8aaa                	mv	s5,a0
    80005756:	b5fd                	j	80005644 <create+0x76>

0000000080005758 <sys_dup>:
{
    80005758:	7179                	addi	sp,sp,-48
    8000575a:	f406                	sd	ra,40(sp)
    8000575c:	f022                	sd	s0,32(sp)
    8000575e:	ec26                	sd	s1,24(sp)
    80005760:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005762:	fd840613          	addi	a2,s0,-40
    80005766:	4581                	li	a1,0
    80005768:	4501                	li	a0,0
    8000576a:	00000097          	auipc	ra,0x0
    8000576e:	dc2080e7          	jalr	-574(ra) # 8000552c <argfd>
    return -1;
    80005772:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005774:	02054363          	bltz	a0,8000579a <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005778:	fd843503          	ld	a0,-40(s0)
    8000577c:	00000097          	auipc	ra,0x0
    80005780:	e10080e7          	jalr	-496(ra) # 8000558c <fdalloc>
    80005784:	84aa                	mv	s1,a0
    return -1;
    80005786:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005788:	00054963          	bltz	a0,8000579a <sys_dup+0x42>
  filedup(f);
    8000578c:	fd843503          	ld	a0,-40(s0)
    80005790:	fffff097          	auipc	ra,0xfffff
    80005794:	310080e7          	jalr	784(ra) # 80004aa0 <filedup>
  return fd;
    80005798:	87a6                	mv	a5,s1
}
    8000579a:	853e                	mv	a0,a5
    8000579c:	70a2                	ld	ra,40(sp)
    8000579e:	7402                	ld	s0,32(sp)
    800057a0:	64e2                	ld	s1,24(sp)
    800057a2:	6145                	addi	sp,sp,48
    800057a4:	8082                	ret

00000000800057a6 <sys_read>:
{
    800057a6:	7179                	addi	sp,sp,-48
    800057a8:	f406                	sd	ra,40(sp)
    800057aa:	f022                	sd	s0,32(sp)
    800057ac:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800057ae:	fd840593          	addi	a1,s0,-40
    800057b2:	4505                	li	a0,1
    800057b4:	ffffe097          	auipc	ra,0xffffe
    800057b8:	836080e7          	jalr	-1994(ra) # 80002fea <argaddr>
  argint(2, &n);
    800057bc:	fe440593          	addi	a1,s0,-28
    800057c0:	4509                	li	a0,2
    800057c2:	ffffe097          	auipc	ra,0xffffe
    800057c6:	808080e7          	jalr	-2040(ra) # 80002fca <argint>
  if(argfd(0, 0, &f) < 0)
    800057ca:	fe840613          	addi	a2,s0,-24
    800057ce:	4581                	li	a1,0
    800057d0:	4501                	li	a0,0
    800057d2:	00000097          	auipc	ra,0x0
    800057d6:	d5a080e7          	jalr	-678(ra) # 8000552c <argfd>
    800057da:	87aa                	mv	a5,a0
    return -1;
    800057dc:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800057de:	0007cc63          	bltz	a5,800057f6 <sys_read+0x50>
  return fileread(f, p, n);
    800057e2:	fe442603          	lw	a2,-28(s0)
    800057e6:	fd843583          	ld	a1,-40(s0)
    800057ea:	fe843503          	ld	a0,-24(s0)
    800057ee:	fffff097          	auipc	ra,0xfffff
    800057f2:	43e080e7          	jalr	1086(ra) # 80004c2c <fileread>
}
    800057f6:	70a2                	ld	ra,40(sp)
    800057f8:	7402                	ld	s0,32(sp)
    800057fa:	6145                	addi	sp,sp,48
    800057fc:	8082                	ret

00000000800057fe <sys_write>:
{
    800057fe:	7179                	addi	sp,sp,-48
    80005800:	f406                	sd	ra,40(sp)
    80005802:	f022                	sd	s0,32(sp)
    80005804:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005806:	fd840593          	addi	a1,s0,-40
    8000580a:	4505                	li	a0,1
    8000580c:	ffffd097          	auipc	ra,0xffffd
    80005810:	7de080e7          	jalr	2014(ra) # 80002fea <argaddr>
  argint(2, &n);
    80005814:	fe440593          	addi	a1,s0,-28
    80005818:	4509                	li	a0,2
    8000581a:	ffffd097          	auipc	ra,0xffffd
    8000581e:	7b0080e7          	jalr	1968(ra) # 80002fca <argint>
  if(argfd(0, 0, &f) < 0)
    80005822:	fe840613          	addi	a2,s0,-24
    80005826:	4581                	li	a1,0
    80005828:	4501                	li	a0,0
    8000582a:	00000097          	auipc	ra,0x0
    8000582e:	d02080e7          	jalr	-766(ra) # 8000552c <argfd>
    80005832:	87aa                	mv	a5,a0
    return -1;
    80005834:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005836:	0007cc63          	bltz	a5,8000584e <sys_write+0x50>
  return filewrite(f, p, n);
    8000583a:	fe442603          	lw	a2,-28(s0)
    8000583e:	fd843583          	ld	a1,-40(s0)
    80005842:	fe843503          	ld	a0,-24(s0)
    80005846:	fffff097          	auipc	ra,0xfffff
    8000584a:	4a8080e7          	jalr	1192(ra) # 80004cee <filewrite>
}
    8000584e:	70a2                	ld	ra,40(sp)
    80005850:	7402                	ld	s0,32(sp)
    80005852:	6145                	addi	sp,sp,48
    80005854:	8082                	ret

0000000080005856 <sys_close>:
{
    80005856:	1101                	addi	sp,sp,-32
    80005858:	ec06                	sd	ra,24(sp)
    8000585a:	e822                	sd	s0,16(sp)
    8000585c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000585e:	fe040613          	addi	a2,s0,-32
    80005862:	fec40593          	addi	a1,s0,-20
    80005866:	4501                	li	a0,0
    80005868:	00000097          	auipc	ra,0x0
    8000586c:	cc4080e7          	jalr	-828(ra) # 8000552c <argfd>
    return -1;
    80005870:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005872:	02054563          	bltz	a0,8000589c <sys_close+0x46>
  myproc()->ofile[fd] = 0;
    80005876:	ffffc097          	auipc	ra,0xffffc
    8000587a:	16a080e7          	jalr	362(ra) # 800019e0 <myproc>
    8000587e:	fec42783          	lw	a5,-20(s0)
    80005882:	02278793          	addi	a5,a5,34
    80005886:	078e                	slli	a5,a5,0x3
    80005888:	97aa                	add	a5,a5,a0
    8000588a:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    8000588e:	fe043503          	ld	a0,-32(s0)
    80005892:	fffff097          	auipc	ra,0xfffff
    80005896:	260080e7          	jalr	608(ra) # 80004af2 <fileclose>
  return 0;
    8000589a:	4781                	li	a5,0
}
    8000589c:	853e                	mv	a0,a5
    8000589e:	60e2                	ld	ra,24(sp)
    800058a0:	6442                	ld	s0,16(sp)
    800058a2:	6105                	addi	sp,sp,32
    800058a4:	8082                	ret

00000000800058a6 <sys_fstat>:
{
    800058a6:	1101                	addi	sp,sp,-32
    800058a8:	ec06                	sd	ra,24(sp)
    800058aa:	e822                	sd	s0,16(sp)
    800058ac:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800058ae:	fe040593          	addi	a1,s0,-32
    800058b2:	4505                	li	a0,1
    800058b4:	ffffd097          	auipc	ra,0xffffd
    800058b8:	736080e7          	jalr	1846(ra) # 80002fea <argaddr>
  if(argfd(0, 0, &f) < 0)
    800058bc:	fe840613          	addi	a2,s0,-24
    800058c0:	4581                	li	a1,0
    800058c2:	4501                	li	a0,0
    800058c4:	00000097          	auipc	ra,0x0
    800058c8:	c68080e7          	jalr	-920(ra) # 8000552c <argfd>
    800058cc:	87aa                	mv	a5,a0
    return -1;
    800058ce:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800058d0:	0007ca63          	bltz	a5,800058e4 <sys_fstat+0x3e>
  return filestat(f, st);
    800058d4:	fe043583          	ld	a1,-32(s0)
    800058d8:	fe843503          	ld	a0,-24(s0)
    800058dc:	fffff097          	auipc	ra,0xfffff
    800058e0:	2de080e7          	jalr	734(ra) # 80004bba <filestat>
}
    800058e4:	60e2                	ld	ra,24(sp)
    800058e6:	6442                	ld	s0,16(sp)
    800058e8:	6105                	addi	sp,sp,32
    800058ea:	8082                	ret

00000000800058ec <sys_link>:
{
    800058ec:	7169                	addi	sp,sp,-304
    800058ee:	f606                	sd	ra,296(sp)
    800058f0:	f222                	sd	s0,288(sp)
    800058f2:	ee26                	sd	s1,280(sp)
    800058f4:	ea4a                	sd	s2,272(sp)
    800058f6:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058f8:	08000613          	li	a2,128
    800058fc:	ed040593          	addi	a1,s0,-304
    80005900:	4501                	li	a0,0
    80005902:	ffffd097          	auipc	ra,0xffffd
    80005906:	708080e7          	jalr	1800(ra) # 8000300a <argstr>
    return -1;
    8000590a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000590c:	10054e63          	bltz	a0,80005a28 <sys_link+0x13c>
    80005910:	08000613          	li	a2,128
    80005914:	f5040593          	addi	a1,s0,-176
    80005918:	4505                	li	a0,1
    8000591a:	ffffd097          	auipc	ra,0xffffd
    8000591e:	6f0080e7          	jalr	1776(ra) # 8000300a <argstr>
    return -1;
    80005922:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005924:	10054263          	bltz	a0,80005a28 <sys_link+0x13c>
  begin_op();
    80005928:	fffff097          	auipc	ra,0xfffff
    8000592c:	cfe080e7          	jalr	-770(ra) # 80004626 <begin_op>
  if((ip = namei(old)) == 0){
    80005930:	ed040513          	addi	a0,s0,-304
    80005934:	fffff097          	auipc	ra,0xfffff
    80005938:	ad6080e7          	jalr	-1322(ra) # 8000440a <namei>
    8000593c:	84aa                	mv	s1,a0
    8000593e:	c551                	beqz	a0,800059ca <sys_link+0xde>
  ilock(ip);
    80005940:	ffffe097          	auipc	ra,0xffffe
    80005944:	324080e7          	jalr	804(ra) # 80003c64 <ilock>
  if(ip->type == T_DIR){
    80005948:	04449703          	lh	a4,68(s1)
    8000594c:	4785                	li	a5,1
    8000594e:	08f70463          	beq	a4,a5,800059d6 <sys_link+0xea>
  ip->nlink++;
    80005952:	04a4d783          	lhu	a5,74(s1)
    80005956:	2785                	addiw	a5,a5,1
    80005958:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000595c:	8526                	mv	a0,s1
    8000595e:	ffffe097          	auipc	ra,0xffffe
    80005962:	23c080e7          	jalr	572(ra) # 80003b9a <iupdate>
  iunlock(ip);
    80005966:	8526                	mv	a0,s1
    80005968:	ffffe097          	auipc	ra,0xffffe
    8000596c:	3be080e7          	jalr	958(ra) # 80003d26 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005970:	fd040593          	addi	a1,s0,-48
    80005974:	f5040513          	addi	a0,s0,-176
    80005978:	fffff097          	auipc	ra,0xfffff
    8000597c:	ab0080e7          	jalr	-1360(ra) # 80004428 <nameiparent>
    80005980:	892a                	mv	s2,a0
    80005982:	c935                	beqz	a0,800059f6 <sys_link+0x10a>
  ilock(dp);
    80005984:	ffffe097          	auipc	ra,0xffffe
    80005988:	2e0080e7          	jalr	736(ra) # 80003c64 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000598c:	00092703          	lw	a4,0(s2)
    80005990:	409c                	lw	a5,0(s1)
    80005992:	04f71d63          	bne	a4,a5,800059ec <sys_link+0x100>
    80005996:	40d0                	lw	a2,4(s1)
    80005998:	fd040593          	addi	a1,s0,-48
    8000599c:	854a                	mv	a0,s2
    8000599e:	fffff097          	auipc	ra,0xfffff
    800059a2:	9ba080e7          	jalr	-1606(ra) # 80004358 <dirlink>
    800059a6:	04054363          	bltz	a0,800059ec <sys_link+0x100>
  iunlockput(dp);
    800059aa:	854a                	mv	a0,s2
    800059ac:	ffffe097          	auipc	ra,0xffffe
    800059b0:	51a080e7          	jalr	1306(ra) # 80003ec6 <iunlockput>
  iput(ip);
    800059b4:	8526                	mv	a0,s1
    800059b6:	ffffe097          	auipc	ra,0xffffe
    800059ba:	468080e7          	jalr	1128(ra) # 80003e1e <iput>
  end_op();
    800059be:	fffff097          	auipc	ra,0xfffff
    800059c2:	ce8080e7          	jalr	-792(ra) # 800046a6 <end_op>
  return 0;
    800059c6:	4781                	li	a5,0
    800059c8:	a085                	j	80005a28 <sys_link+0x13c>
    end_op();
    800059ca:	fffff097          	auipc	ra,0xfffff
    800059ce:	cdc080e7          	jalr	-804(ra) # 800046a6 <end_op>
    return -1;
    800059d2:	57fd                	li	a5,-1
    800059d4:	a891                	j	80005a28 <sys_link+0x13c>
    iunlockput(ip);
    800059d6:	8526                	mv	a0,s1
    800059d8:	ffffe097          	auipc	ra,0xffffe
    800059dc:	4ee080e7          	jalr	1262(ra) # 80003ec6 <iunlockput>
    end_op();
    800059e0:	fffff097          	auipc	ra,0xfffff
    800059e4:	cc6080e7          	jalr	-826(ra) # 800046a6 <end_op>
    return -1;
    800059e8:	57fd                	li	a5,-1
    800059ea:	a83d                	j	80005a28 <sys_link+0x13c>
    iunlockput(dp);
    800059ec:	854a                	mv	a0,s2
    800059ee:	ffffe097          	auipc	ra,0xffffe
    800059f2:	4d8080e7          	jalr	1240(ra) # 80003ec6 <iunlockput>
  ilock(ip);
    800059f6:	8526                	mv	a0,s1
    800059f8:	ffffe097          	auipc	ra,0xffffe
    800059fc:	26c080e7          	jalr	620(ra) # 80003c64 <ilock>
  ip->nlink--;
    80005a00:	04a4d783          	lhu	a5,74(s1)
    80005a04:	37fd                	addiw	a5,a5,-1
    80005a06:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005a0a:	8526                	mv	a0,s1
    80005a0c:	ffffe097          	auipc	ra,0xffffe
    80005a10:	18e080e7          	jalr	398(ra) # 80003b9a <iupdate>
  iunlockput(ip);
    80005a14:	8526                	mv	a0,s1
    80005a16:	ffffe097          	auipc	ra,0xffffe
    80005a1a:	4b0080e7          	jalr	1200(ra) # 80003ec6 <iunlockput>
  end_op();
    80005a1e:	fffff097          	auipc	ra,0xfffff
    80005a22:	c88080e7          	jalr	-888(ra) # 800046a6 <end_op>
  return -1;
    80005a26:	57fd                	li	a5,-1
}
    80005a28:	853e                	mv	a0,a5
    80005a2a:	70b2                	ld	ra,296(sp)
    80005a2c:	7412                	ld	s0,288(sp)
    80005a2e:	64f2                	ld	s1,280(sp)
    80005a30:	6952                	ld	s2,272(sp)
    80005a32:	6155                	addi	sp,sp,304
    80005a34:	8082                	ret

0000000080005a36 <sys_unlink>:
{
    80005a36:	7151                	addi	sp,sp,-240
    80005a38:	f586                	sd	ra,232(sp)
    80005a3a:	f1a2                	sd	s0,224(sp)
    80005a3c:	eda6                	sd	s1,216(sp)
    80005a3e:	e9ca                	sd	s2,208(sp)
    80005a40:	e5ce                	sd	s3,200(sp)
    80005a42:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005a44:	08000613          	li	a2,128
    80005a48:	f3040593          	addi	a1,s0,-208
    80005a4c:	4501                	li	a0,0
    80005a4e:	ffffd097          	auipc	ra,0xffffd
    80005a52:	5bc080e7          	jalr	1468(ra) # 8000300a <argstr>
    80005a56:	18054163          	bltz	a0,80005bd8 <sys_unlink+0x1a2>
  begin_op();
    80005a5a:	fffff097          	auipc	ra,0xfffff
    80005a5e:	bcc080e7          	jalr	-1076(ra) # 80004626 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005a62:	fb040593          	addi	a1,s0,-80
    80005a66:	f3040513          	addi	a0,s0,-208
    80005a6a:	fffff097          	auipc	ra,0xfffff
    80005a6e:	9be080e7          	jalr	-1602(ra) # 80004428 <nameiparent>
    80005a72:	84aa                	mv	s1,a0
    80005a74:	c979                	beqz	a0,80005b4a <sys_unlink+0x114>
  ilock(dp);
    80005a76:	ffffe097          	auipc	ra,0xffffe
    80005a7a:	1ee080e7          	jalr	494(ra) # 80003c64 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005a7e:	00003597          	auipc	a1,0x3
    80005a82:	cc258593          	addi	a1,a1,-830 # 80008740 <syscalls+0x2c8>
    80005a86:	fb040513          	addi	a0,s0,-80
    80005a8a:	ffffe097          	auipc	ra,0xffffe
    80005a8e:	6a4080e7          	jalr	1700(ra) # 8000412e <namecmp>
    80005a92:	14050a63          	beqz	a0,80005be6 <sys_unlink+0x1b0>
    80005a96:	00003597          	auipc	a1,0x3
    80005a9a:	cb258593          	addi	a1,a1,-846 # 80008748 <syscalls+0x2d0>
    80005a9e:	fb040513          	addi	a0,s0,-80
    80005aa2:	ffffe097          	auipc	ra,0xffffe
    80005aa6:	68c080e7          	jalr	1676(ra) # 8000412e <namecmp>
    80005aaa:	12050e63          	beqz	a0,80005be6 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005aae:	f2c40613          	addi	a2,s0,-212
    80005ab2:	fb040593          	addi	a1,s0,-80
    80005ab6:	8526                	mv	a0,s1
    80005ab8:	ffffe097          	auipc	ra,0xffffe
    80005abc:	690080e7          	jalr	1680(ra) # 80004148 <dirlookup>
    80005ac0:	892a                	mv	s2,a0
    80005ac2:	12050263          	beqz	a0,80005be6 <sys_unlink+0x1b0>
  ilock(ip);
    80005ac6:	ffffe097          	auipc	ra,0xffffe
    80005aca:	19e080e7          	jalr	414(ra) # 80003c64 <ilock>
  if(ip->nlink < 1)
    80005ace:	04a91783          	lh	a5,74(s2)
    80005ad2:	08f05263          	blez	a5,80005b56 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005ad6:	04491703          	lh	a4,68(s2)
    80005ada:	4785                	li	a5,1
    80005adc:	08f70563          	beq	a4,a5,80005b66 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005ae0:	4641                	li	a2,16
    80005ae2:	4581                	li	a1,0
    80005ae4:	fc040513          	addi	a0,s0,-64
    80005ae8:	ffffb097          	auipc	ra,0xffffb
    80005aec:	1ea080e7          	jalr	490(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005af0:	4741                	li	a4,16
    80005af2:	f2c42683          	lw	a3,-212(s0)
    80005af6:	fc040613          	addi	a2,s0,-64
    80005afa:	4581                	li	a1,0
    80005afc:	8526                	mv	a0,s1
    80005afe:	ffffe097          	auipc	ra,0xffffe
    80005b02:	512080e7          	jalr	1298(ra) # 80004010 <writei>
    80005b06:	47c1                	li	a5,16
    80005b08:	0af51563          	bne	a0,a5,80005bb2 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005b0c:	04491703          	lh	a4,68(s2)
    80005b10:	4785                	li	a5,1
    80005b12:	0af70863          	beq	a4,a5,80005bc2 <sys_unlink+0x18c>
  iunlockput(dp);
    80005b16:	8526                	mv	a0,s1
    80005b18:	ffffe097          	auipc	ra,0xffffe
    80005b1c:	3ae080e7          	jalr	942(ra) # 80003ec6 <iunlockput>
  ip->nlink--;
    80005b20:	04a95783          	lhu	a5,74(s2)
    80005b24:	37fd                	addiw	a5,a5,-1
    80005b26:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005b2a:	854a                	mv	a0,s2
    80005b2c:	ffffe097          	auipc	ra,0xffffe
    80005b30:	06e080e7          	jalr	110(ra) # 80003b9a <iupdate>
  iunlockput(ip);
    80005b34:	854a                	mv	a0,s2
    80005b36:	ffffe097          	auipc	ra,0xffffe
    80005b3a:	390080e7          	jalr	912(ra) # 80003ec6 <iunlockput>
  end_op();
    80005b3e:	fffff097          	auipc	ra,0xfffff
    80005b42:	b68080e7          	jalr	-1176(ra) # 800046a6 <end_op>
  return 0;
    80005b46:	4501                	li	a0,0
    80005b48:	a84d                	j	80005bfa <sys_unlink+0x1c4>
    end_op();
    80005b4a:	fffff097          	auipc	ra,0xfffff
    80005b4e:	b5c080e7          	jalr	-1188(ra) # 800046a6 <end_op>
    return -1;
    80005b52:	557d                	li	a0,-1
    80005b54:	a05d                	j	80005bfa <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005b56:	00003517          	auipc	a0,0x3
    80005b5a:	bfa50513          	addi	a0,a0,-1030 # 80008750 <syscalls+0x2d8>
    80005b5e:	ffffb097          	auipc	ra,0xffffb
    80005b62:	9e0080e7          	jalr	-1568(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b66:	04c92703          	lw	a4,76(s2)
    80005b6a:	02000793          	li	a5,32
    80005b6e:	f6e7f9e3          	bgeu	a5,a4,80005ae0 <sys_unlink+0xaa>
    80005b72:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b76:	4741                	li	a4,16
    80005b78:	86ce                	mv	a3,s3
    80005b7a:	f1840613          	addi	a2,s0,-232
    80005b7e:	4581                	li	a1,0
    80005b80:	854a                	mv	a0,s2
    80005b82:	ffffe097          	auipc	ra,0xffffe
    80005b86:	396080e7          	jalr	918(ra) # 80003f18 <readi>
    80005b8a:	47c1                	li	a5,16
    80005b8c:	00f51b63          	bne	a0,a5,80005ba2 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005b90:	f1845783          	lhu	a5,-232(s0)
    80005b94:	e7a1                	bnez	a5,80005bdc <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b96:	29c1                	addiw	s3,s3,16
    80005b98:	04c92783          	lw	a5,76(s2)
    80005b9c:	fcf9ede3          	bltu	s3,a5,80005b76 <sys_unlink+0x140>
    80005ba0:	b781                	j	80005ae0 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005ba2:	00003517          	auipc	a0,0x3
    80005ba6:	bc650513          	addi	a0,a0,-1082 # 80008768 <syscalls+0x2f0>
    80005baa:	ffffb097          	auipc	ra,0xffffb
    80005bae:	994080e7          	jalr	-1644(ra) # 8000053e <panic>
    panic("unlink: writei");
    80005bb2:	00003517          	auipc	a0,0x3
    80005bb6:	bce50513          	addi	a0,a0,-1074 # 80008780 <syscalls+0x308>
    80005bba:	ffffb097          	auipc	ra,0xffffb
    80005bbe:	984080e7          	jalr	-1660(ra) # 8000053e <panic>
    dp->nlink--;
    80005bc2:	04a4d783          	lhu	a5,74(s1)
    80005bc6:	37fd                	addiw	a5,a5,-1
    80005bc8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005bcc:	8526                	mv	a0,s1
    80005bce:	ffffe097          	auipc	ra,0xffffe
    80005bd2:	fcc080e7          	jalr	-52(ra) # 80003b9a <iupdate>
    80005bd6:	b781                	j	80005b16 <sys_unlink+0xe0>
    return -1;
    80005bd8:	557d                	li	a0,-1
    80005bda:	a005                	j	80005bfa <sys_unlink+0x1c4>
    iunlockput(ip);
    80005bdc:	854a                	mv	a0,s2
    80005bde:	ffffe097          	auipc	ra,0xffffe
    80005be2:	2e8080e7          	jalr	744(ra) # 80003ec6 <iunlockput>
  iunlockput(dp);
    80005be6:	8526                	mv	a0,s1
    80005be8:	ffffe097          	auipc	ra,0xffffe
    80005bec:	2de080e7          	jalr	734(ra) # 80003ec6 <iunlockput>
  end_op();
    80005bf0:	fffff097          	auipc	ra,0xfffff
    80005bf4:	ab6080e7          	jalr	-1354(ra) # 800046a6 <end_op>
  return -1;
    80005bf8:	557d                	li	a0,-1
}
    80005bfa:	70ae                	ld	ra,232(sp)
    80005bfc:	740e                	ld	s0,224(sp)
    80005bfe:	64ee                	ld	s1,216(sp)
    80005c00:	694e                	ld	s2,208(sp)
    80005c02:	69ae                	ld	s3,200(sp)
    80005c04:	616d                	addi	sp,sp,240
    80005c06:	8082                	ret

0000000080005c08 <sys_open>:

uint64
sys_open(void)
{
    80005c08:	7131                	addi	sp,sp,-192
    80005c0a:	fd06                	sd	ra,184(sp)
    80005c0c:	f922                	sd	s0,176(sp)
    80005c0e:	f526                	sd	s1,168(sp)
    80005c10:	f14a                	sd	s2,160(sp)
    80005c12:	ed4e                	sd	s3,152(sp)
    80005c14:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005c16:	f4c40593          	addi	a1,s0,-180
    80005c1a:	4505                	li	a0,1
    80005c1c:	ffffd097          	auipc	ra,0xffffd
    80005c20:	3ae080e7          	jalr	942(ra) # 80002fca <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005c24:	08000613          	li	a2,128
    80005c28:	f5040593          	addi	a1,s0,-176
    80005c2c:	4501                	li	a0,0
    80005c2e:	ffffd097          	auipc	ra,0xffffd
    80005c32:	3dc080e7          	jalr	988(ra) # 8000300a <argstr>
    80005c36:	87aa                	mv	a5,a0
    return -1;
    80005c38:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005c3a:	0a07c963          	bltz	a5,80005cec <sys_open+0xe4>

  begin_op();
    80005c3e:	fffff097          	auipc	ra,0xfffff
    80005c42:	9e8080e7          	jalr	-1560(ra) # 80004626 <begin_op>

  if(omode & O_CREATE){
    80005c46:	f4c42783          	lw	a5,-180(s0)
    80005c4a:	2007f793          	andi	a5,a5,512
    80005c4e:	cfc5                	beqz	a5,80005d06 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005c50:	4681                	li	a3,0
    80005c52:	4601                	li	a2,0
    80005c54:	4589                	li	a1,2
    80005c56:	f5040513          	addi	a0,s0,-176
    80005c5a:	00000097          	auipc	ra,0x0
    80005c5e:	974080e7          	jalr	-1676(ra) # 800055ce <create>
    80005c62:	84aa                	mv	s1,a0
    if(ip == 0){
    80005c64:	c959                	beqz	a0,80005cfa <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005c66:	04449703          	lh	a4,68(s1)
    80005c6a:	478d                	li	a5,3
    80005c6c:	00f71763          	bne	a4,a5,80005c7a <sys_open+0x72>
    80005c70:	0464d703          	lhu	a4,70(s1)
    80005c74:	47a5                	li	a5,9
    80005c76:	0ce7ed63          	bltu	a5,a4,80005d50 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005c7a:	fffff097          	auipc	ra,0xfffff
    80005c7e:	dbc080e7          	jalr	-580(ra) # 80004a36 <filealloc>
    80005c82:	89aa                	mv	s3,a0
    80005c84:	10050363          	beqz	a0,80005d8a <sys_open+0x182>
    80005c88:	00000097          	auipc	ra,0x0
    80005c8c:	904080e7          	jalr	-1788(ra) # 8000558c <fdalloc>
    80005c90:	892a                	mv	s2,a0
    80005c92:	0e054763          	bltz	a0,80005d80 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005c96:	04449703          	lh	a4,68(s1)
    80005c9a:	478d                	li	a5,3
    80005c9c:	0cf70563          	beq	a4,a5,80005d66 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005ca0:	4789                	li	a5,2
    80005ca2:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005ca6:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005caa:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005cae:	f4c42783          	lw	a5,-180(s0)
    80005cb2:	0017c713          	xori	a4,a5,1
    80005cb6:	8b05                	andi	a4,a4,1
    80005cb8:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005cbc:	0037f713          	andi	a4,a5,3
    80005cc0:	00e03733          	snez	a4,a4
    80005cc4:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005cc8:	4007f793          	andi	a5,a5,1024
    80005ccc:	c791                	beqz	a5,80005cd8 <sys_open+0xd0>
    80005cce:	04449703          	lh	a4,68(s1)
    80005cd2:	4789                	li	a5,2
    80005cd4:	0af70063          	beq	a4,a5,80005d74 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005cd8:	8526                	mv	a0,s1
    80005cda:	ffffe097          	auipc	ra,0xffffe
    80005cde:	04c080e7          	jalr	76(ra) # 80003d26 <iunlock>
  end_op();
    80005ce2:	fffff097          	auipc	ra,0xfffff
    80005ce6:	9c4080e7          	jalr	-1596(ra) # 800046a6 <end_op>

  return fd;
    80005cea:	854a                	mv	a0,s2
}
    80005cec:	70ea                	ld	ra,184(sp)
    80005cee:	744a                	ld	s0,176(sp)
    80005cf0:	74aa                	ld	s1,168(sp)
    80005cf2:	790a                	ld	s2,160(sp)
    80005cf4:	69ea                	ld	s3,152(sp)
    80005cf6:	6129                	addi	sp,sp,192
    80005cf8:	8082                	ret
      end_op();
    80005cfa:	fffff097          	auipc	ra,0xfffff
    80005cfe:	9ac080e7          	jalr	-1620(ra) # 800046a6 <end_op>
      return -1;
    80005d02:	557d                	li	a0,-1
    80005d04:	b7e5                	j	80005cec <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005d06:	f5040513          	addi	a0,s0,-176
    80005d0a:	ffffe097          	auipc	ra,0xffffe
    80005d0e:	700080e7          	jalr	1792(ra) # 8000440a <namei>
    80005d12:	84aa                	mv	s1,a0
    80005d14:	c905                	beqz	a0,80005d44 <sys_open+0x13c>
    ilock(ip);
    80005d16:	ffffe097          	auipc	ra,0xffffe
    80005d1a:	f4e080e7          	jalr	-178(ra) # 80003c64 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005d1e:	04449703          	lh	a4,68(s1)
    80005d22:	4785                	li	a5,1
    80005d24:	f4f711e3          	bne	a4,a5,80005c66 <sys_open+0x5e>
    80005d28:	f4c42783          	lw	a5,-180(s0)
    80005d2c:	d7b9                	beqz	a5,80005c7a <sys_open+0x72>
      iunlockput(ip);
    80005d2e:	8526                	mv	a0,s1
    80005d30:	ffffe097          	auipc	ra,0xffffe
    80005d34:	196080e7          	jalr	406(ra) # 80003ec6 <iunlockput>
      end_op();
    80005d38:	fffff097          	auipc	ra,0xfffff
    80005d3c:	96e080e7          	jalr	-1682(ra) # 800046a6 <end_op>
      return -1;
    80005d40:	557d                	li	a0,-1
    80005d42:	b76d                	j	80005cec <sys_open+0xe4>
      end_op();
    80005d44:	fffff097          	auipc	ra,0xfffff
    80005d48:	962080e7          	jalr	-1694(ra) # 800046a6 <end_op>
      return -1;
    80005d4c:	557d                	li	a0,-1
    80005d4e:	bf79                	j	80005cec <sys_open+0xe4>
    iunlockput(ip);
    80005d50:	8526                	mv	a0,s1
    80005d52:	ffffe097          	auipc	ra,0xffffe
    80005d56:	174080e7          	jalr	372(ra) # 80003ec6 <iunlockput>
    end_op();
    80005d5a:	fffff097          	auipc	ra,0xfffff
    80005d5e:	94c080e7          	jalr	-1716(ra) # 800046a6 <end_op>
    return -1;
    80005d62:	557d                	li	a0,-1
    80005d64:	b761                	j	80005cec <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005d66:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005d6a:	04649783          	lh	a5,70(s1)
    80005d6e:	02f99223          	sh	a5,36(s3)
    80005d72:	bf25                	j	80005caa <sys_open+0xa2>
    itrunc(ip);
    80005d74:	8526                	mv	a0,s1
    80005d76:	ffffe097          	auipc	ra,0xffffe
    80005d7a:	ffc080e7          	jalr	-4(ra) # 80003d72 <itrunc>
    80005d7e:	bfa9                	j	80005cd8 <sys_open+0xd0>
      fileclose(f);
    80005d80:	854e                	mv	a0,s3
    80005d82:	fffff097          	auipc	ra,0xfffff
    80005d86:	d70080e7          	jalr	-656(ra) # 80004af2 <fileclose>
    iunlockput(ip);
    80005d8a:	8526                	mv	a0,s1
    80005d8c:	ffffe097          	auipc	ra,0xffffe
    80005d90:	13a080e7          	jalr	314(ra) # 80003ec6 <iunlockput>
    end_op();
    80005d94:	fffff097          	auipc	ra,0xfffff
    80005d98:	912080e7          	jalr	-1774(ra) # 800046a6 <end_op>
    return -1;
    80005d9c:	557d                	li	a0,-1
    80005d9e:	b7b9                	j	80005cec <sys_open+0xe4>

0000000080005da0 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005da0:	7175                	addi	sp,sp,-144
    80005da2:	e506                	sd	ra,136(sp)
    80005da4:	e122                	sd	s0,128(sp)
    80005da6:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005da8:	fffff097          	auipc	ra,0xfffff
    80005dac:	87e080e7          	jalr	-1922(ra) # 80004626 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005db0:	08000613          	li	a2,128
    80005db4:	f7040593          	addi	a1,s0,-144
    80005db8:	4501                	li	a0,0
    80005dba:	ffffd097          	auipc	ra,0xffffd
    80005dbe:	250080e7          	jalr	592(ra) # 8000300a <argstr>
    80005dc2:	02054963          	bltz	a0,80005df4 <sys_mkdir+0x54>
    80005dc6:	4681                	li	a3,0
    80005dc8:	4601                	li	a2,0
    80005dca:	4585                	li	a1,1
    80005dcc:	f7040513          	addi	a0,s0,-144
    80005dd0:	fffff097          	auipc	ra,0xfffff
    80005dd4:	7fe080e7          	jalr	2046(ra) # 800055ce <create>
    80005dd8:	cd11                	beqz	a0,80005df4 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005dda:	ffffe097          	auipc	ra,0xffffe
    80005dde:	0ec080e7          	jalr	236(ra) # 80003ec6 <iunlockput>
  end_op();
    80005de2:	fffff097          	auipc	ra,0xfffff
    80005de6:	8c4080e7          	jalr	-1852(ra) # 800046a6 <end_op>
  return 0;
    80005dea:	4501                	li	a0,0
}
    80005dec:	60aa                	ld	ra,136(sp)
    80005dee:	640a                	ld	s0,128(sp)
    80005df0:	6149                	addi	sp,sp,144
    80005df2:	8082                	ret
    end_op();
    80005df4:	fffff097          	auipc	ra,0xfffff
    80005df8:	8b2080e7          	jalr	-1870(ra) # 800046a6 <end_op>
    return -1;
    80005dfc:	557d                	li	a0,-1
    80005dfe:	b7fd                	j	80005dec <sys_mkdir+0x4c>

0000000080005e00 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005e00:	7135                	addi	sp,sp,-160
    80005e02:	ed06                	sd	ra,152(sp)
    80005e04:	e922                	sd	s0,144(sp)
    80005e06:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005e08:	fffff097          	auipc	ra,0xfffff
    80005e0c:	81e080e7          	jalr	-2018(ra) # 80004626 <begin_op>
  argint(1, &major);
    80005e10:	f6c40593          	addi	a1,s0,-148
    80005e14:	4505                	li	a0,1
    80005e16:	ffffd097          	auipc	ra,0xffffd
    80005e1a:	1b4080e7          	jalr	436(ra) # 80002fca <argint>
  argint(2, &minor);
    80005e1e:	f6840593          	addi	a1,s0,-152
    80005e22:	4509                	li	a0,2
    80005e24:	ffffd097          	auipc	ra,0xffffd
    80005e28:	1a6080e7          	jalr	422(ra) # 80002fca <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e2c:	08000613          	li	a2,128
    80005e30:	f7040593          	addi	a1,s0,-144
    80005e34:	4501                	li	a0,0
    80005e36:	ffffd097          	auipc	ra,0xffffd
    80005e3a:	1d4080e7          	jalr	468(ra) # 8000300a <argstr>
    80005e3e:	02054b63          	bltz	a0,80005e74 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005e42:	f6841683          	lh	a3,-152(s0)
    80005e46:	f6c41603          	lh	a2,-148(s0)
    80005e4a:	458d                	li	a1,3
    80005e4c:	f7040513          	addi	a0,s0,-144
    80005e50:	fffff097          	auipc	ra,0xfffff
    80005e54:	77e080e7          	jalr	1918(ra) # 800055ce <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e58:	cd11                	beqz	a0,80005e74 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005e5a:	ffffe097          	auipc	ra,0xffffe
    80005e5e:	06c080e7          	jalr	108(ra) # 80003ec6 <iunlockput>
  end_op();
    80005e62:	fffff097          	auipc	ra,0xfffff
    80005e66:	844080e7          	jalr	-1980(ra) # 800046a6 <end_op>
  return 0;
    80005e6a:	4501                	li	a0,0
}
    80005e6c:	60ea                	ld	ra,152(sp)
    80005e6e:	644a                	ld	s0,144(sp)
    80005e70:	610d                	addi	sp,sp,160
    80005e72:	8082                	ret
    end_op();
    80005e74:	fffff097          	auipc	ra,0xfffff
    80005e78:	832080e7          	jalr	-1998(ra) # 800046a6 <end_op>
    return -1;
    80005e7c:	557d                	li	a0,-1
    80005e7e:	b7fd                	j	80005e6c <sys_mknod+0x6c>

0000000080005e80 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005e80:	7135                	addi	sp,sp,-160
    80005e82:	ed06                	sd	ra,152(sp)
    80005e84:	e922                	sd	s0,144(sp)
    80005e86:	e526                	sd	s1,136(sp)
    80005e88:	e14a                	sd	s2,128(sp)
    80005e8a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005e8c:	ffffc097          	auipc	ra,0xffffc
    80005e90:	b54080e7          	jalr	-1196(ra) # 800019e0 <myproc>
    80005e94:	892a                	mv	s2,a0
  
  begin_op();
    80005e96:	ffffe097          	auipc	ra,0xffffe
    80005e9a:	790080e7          	jalr	1936(ra) # 80004626 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005e9e:	08000613          	li	a2,128
    80005ea2:	f6040593          	addi	a1,s0,-160
    80005ea6:	4501                	li	a0,0
    80005ea8:	ffffd097          	auipc	ra,0xffffd
    80005eac:	162080e7          	jalr	354(ra) # 8000300a <argstr>
    80005eb0:	04054b63          	bltz	a0,80005f06 <sys_chdir+0x86>
    80005eb4:	f6040513          	addi	a0,s0,-160
    80005eb8:	ffffe097          	auipc	ra,0xffffe
    80005ebc:	552080e7          	jalr	1362(ra) # 8000440a <namei>
    80005ec0:	84aa                	mv	s1,a0
    80005ec2:	c131                	beqz	a0,80005f06 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005ec4:	ffffe097          	auipc	ra,0xffffe
    80005ec8:	da0080e7          	jalr	-608(ra) # 80003c64 <ilock>
  if(ip->type != T_DIR){
    80005ecc:	04449703          	lh	a4,68(s1)
    80005ed0:	4785                	li	a5,1
    80005ed2:	04f71063          	bne	a4,a5,80005f12 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005ed6:	8526                	mv	a0,s1
    80005ed8:	ffffe097          	auipc	ra,0xffffe
    80005edc:	e4e080e7          	jalr	-434(ra) # 80003d26 <iunlock>
  iput(p->cwd);
    80005ee0:	19093503          	ld	a0,400(s2)
    80005ee4:	ffffe097          	auipc	ra,0xffffe
    80005ee8:	f3a080e7          	jalr	-198(ra) # 80003e1e <iput>
  end_op();
    80005eec:	ffffe097          	auipc	ra,0xffffe
    80005ef0:	7ba080e7          	jalr	1978(ra) # 800046a6 <end_op>
  p->cwd = ip;
    80005ef4:	18993823          	sd	s1,400(s2)
  return 0;
    80005ef8:	4501                	li	a0,0
}
    80005efa:	60ea                	ld	ra,152(sp)
    80005efc:	644a                	ld	s0,144(sp)
    80005efe:	64aa                	ld	s1,136(sp)
    80005f00:	690a                	ld	s2,128(sp)
    80005f02:	610d                	addi	sp,sp,160
    80005f04:	8082                	ret
    end_op();
    80005f06:	ffffe097          	auipc	ra,0xffffe
    80005f0a:	7a0080e7          	jalr	1952(ra) # 800046a6 <end_op>
    return -1;
    80005f0e:	557d                	li	a0,-1
    80005f10:	b7ed                	j	80005efa <sys_chdir+0x7a>
    iunlockput(ip);
    80005f12:	8526                	mv	a0,s1
    80005f14:	ffffe097          	auipc	ra,0xffffe
    80005f18:	fb2080e7          	jalr	-78(ra) # 80003ec6 <iunlockput>
    end_op();
    80005f1c:	ffffe097          	auipc	ra,0xffffe
    80005f20:	78a080e7          	jalr	1930(ra) # 800046a6 <end_op>
    return -1;
    80005f24:	557d                	li	a0,-1
    80005f26:	bfd1                	j	80005efa <sys_chdir+0x7a>

0000000080005f28 <sys_exec>:

uint64
sys_exec(void)
{
    80005f28:	7145                	addi	sp,sp,-464
    80005f2a:	e786                	sd	ra,456(sp)
    80005f2c:	e3a2                	sd	s0,448(sp)
    80005f2e:	ff26                	sd	s1,440(sp)
    80005f30:	fb4a                	sd	s2,432(sp)
    80005f32:	f74e                	sd	s3,424(sp)
    80005f34:	f352                	sd	s4,416(sp)
    80005f36:	ef56                	sd	s5,408(sp)
    80005f38:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005f3a:	e3840593          	addi	a1,s0,-456
    80005f3e:	4505                	li	a0,1
    80005f40:	ffffd097          	auipc	ra,0xffffd
    80005f44:	0aa080e7          	jalr	170(ra) # 80002fea <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005f48:	08000613          	li	a2,128
    80005f4c:	f4040593          	addi	a1,s0,-192
    80005f50:	4501                	li	a0,0
    80005f52:	ffffd097          	auipc	ra,0xffffd
    80005f56:	0b8080e7          	jalr	184(ra) # 8000300a <argstr>
    80005f5a:	87aa                	mv	a5,a0
    return -1;
    80005f5c:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005f5e:	0c07c263          	bltz	a5,80006022 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005f62:	10000613          	li	a2,256
    80005f66:	4581                	li	a1,0
    80005f68:	e4040513          	addi	a0,s0,-448
    80005f6c:	ffffb097          	auipc	ra,0xffffb
    80005f70:	d66080e7          	jalr	-666(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005f74:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005f78:	89a6                	mv	s3,s1
    80005f7a:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005f7c:	02000a13          	li	s4,32
    80005f80:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005f84:	00391793          	slli	a5,s2,0x3
    80005f88:	e3040593          	addi	a1,s0,-464
    80005f8c:	e3843503          	ld	a0,-456(s0)
    80005f90:	953e                	add	a0,a0,a5
    80005f92:	ffffd097          	auipc	ra,0xffffd
    80005f96:	f9a080e7          	jalr	-102(ra) # 80002f2c <fetchaddr>
    80005f9a:	02054a63          	bltz	a0,80005fce <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005f9e:	e3043783          	ld	a5,-464(s0)
    80005fa2:	c3b9                	beqz	a5,80005fe8 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005fa4:	ffffb097          	auipc	ra,0xffffb
    80005fa8:	b42080e7          	jalr	-1214(ra) # 80000ae6 <kalloc>
    80005fac:	85aa                	mv	a1,a0
    80005fae:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005fb2:	cd11                	beqz	a0,80005fce <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005fb4:	6605                	lui	a2,0x1
    80005fb6:	e3043503          	ld	a0,-464(s0)
    80005fba:	ffffd097          	auipc	ra,0xffffd
    80005fbe:	fc4080e7          	jalr	-60(ra) # 80002f7e <fetchstr>
    80005fc2:	00054663          	bltz	a0,80005fce <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005fc6:	0905                	addi	s2,s2,1
    80005fc8:	09a1                	addi	s3,s3,8
    80005fca:	fb491be3          	bne	s2,s4,80005f80 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fce:	10048913          	addi	s2,s1,256
    80005fd2:	6088                	ld	a0,0(s1)
    80005fd4:	c531                	beqz	a0,80006020 <sys_exec+0xf8>
    kfree(argv[i]);
    80005fd6:	ffffb097          	auipc	ra,0xffffb
    80005fda:	a14080e7          	jalr	-1516(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fde:	04a1                	addi	s1,s1,8
    80005fe0:	ff2499e3          	bne	s1,s2,80005fd2 <sys_exec+0xaa>
  return -1;
    80005fe4:	557d                	li	a0,-1
    80005fe6:	a835                	j	80006022 <sys_exec+0xfa>
      argv[i] = 0;
    80005fe8:	0a8e                	slli	s5,s5,0x3
    80005fea:	fc040793          	addi	a5,s0,-64
    80005fee:	9abe                	add	s5,s5,a5
    80005ff0:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005ff4:	e4040593          	addi	a1,s0,-448
    80005ff8:	f4040513          	addi	a0,s0,-192
    80005ffc:	fffff097          	auipc	ra,0xfffff
    80006000:	170080e7          	jalr	368(ra) # 8000516c <exec>
    80006004:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006006:	10048993          	addi	s3,s1,256
    8000600a:	6088                	ld	a0,0(s1)
    8000600c:	c901                	beqz	a0,8000601c <sys_exec+0xf4>
    kfree(argv[i]);
    8000600e:	ffffb097          	auipc	ra,0xffffb
    80006012:	9dc080e7          	jalr	-1572(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006016:	04a1                	addi	s1,s1,8
    80006018:	ff3499e3          	bne	s1,s3,8000600a <sys_exec+0xe2>
  return ret;
    8000601c:	854a                	mv	a0,s2
    8000601e:	a011                	j	80006022 <sys_exec+0xfa>
  return -1;
    80006020:	557d                	li	a0,-1
}
    80006022:	60be                	ld	ra,456(sp)
    80006024:	641e                	ld	s0,448(sp)
    80006026:	74fa                	ld	s1,440(sp)
    80006028:	795a                	ld	s2,432(sp)
    8000602a:	79ba                	ld	s3,424(sp)
    8000602c:	7a1a                	ld	s4,416(sp)
    8000602e:	6afa                	ld	s5,408(sp)
    80006030:	6179                	addi	sp,sp,464
    80006032:	8082                	ret

0000000080006034 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006034:	7139                	addi	sp,sp,-64
    80006036:	fc06                	sd	ra,56(sp)
    80006038:	f822                	sd	s0,48(sp)
    8000603a:	f426                	sd	s1,40(sp)
    8000603c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000603e:	ffffc097          	auipc	ra,0xffffc
    80006042:	9a2080e7          	jalr	-1630(ra) # 800019e0 <myproc>
    80006046:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80006048:	fd840593          	addi	a1,s0,-40
    8000604c:	4501                	li	a0,0
    8000604e:	ffffd097          	auipc	ra,0xffffd
    80006052:	f9c080e7          	jalr	-100(ra) # 80002fea <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80006056:	fc840593          	addi	a1,s0,-56
    8000605a:	fd040513          	addi	a0,s0,-48
    8000605e:	fffff097          	auipc	ra,0xfffff
    80006062:	dc4080e7          	jalr	-572(ra) # 80004e22 <pipealloc>
    return -1;
    80006066:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006068:	0c054763          	bltz	a0,80006136 <sys_pipe+0x102>
  fd0 = -1;
    8000606c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006070:	fd043503          	ld	a0,-48(s0)
    80006074:	fffff097          	auipc	ra,0xfffff
    80006078:	518080e7          	jalr	1304(ra) # 8000558c <fdalloc>
    8000607c:	fca42223          	sw	a0,-60(s0)
    80006080:	08054e63          	bltz	a0,8000611c <sys_pipe+0xe8>
    80006084:	fc843503          	ld	a0,-56(s0)
    80006088:	fffff097          	auipc	ra,0xfffff
    8000608c:	504080e7          	jalr	1284(ra) # 8000558c <fdalloc>
    80006090:	fca42023          	sw	a0,-64(s0)
    80006094:	06054a63          	bltz	a0,80006108 <sys_pipe+0xd4>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006098:	4691                	li	a3,4
    8000609a:	fc440613          	addi	a2,s0,-60
    8000609e:	fd843583          	ld	a1,-40(s0)
    800060a2:	68c8                	ld	a0,144(s1)
    800060a4:	ffffb097          	auipc	ra,0xffffb
    800060a8:	5c4080e7          	jalr	1476(ra) # 80001668 <copyout>
    800060ac:	02054063          	bltz	a0,800060cc <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800060b0:	4691                	li	a3,4
    800060b2:	fc040613          	addi	a2,s0,-64
    800060b6:	fd843583          	ld	a1,-40(s0)
    800060ba:	0591                	addi	a1,a1,4
    800060bc:	68c8                	ld	a0,144(s1)
    800060be:	ffffb097          	auipc	ra,0xffffb
    800060c2:	5aa080e7          	jalr	1450(ra) # 80001668 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800060c6:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800060c8:	06055763          	bgez	a0,80006136 <sys_pipe+0x102>
    p->ofile[fd0] = 0;
    800060cc:	fc442783          	lw	a5,-60(s0)
    800060d0:	02278793          	addi	a5,a5,34
    800060d4:	078e                	slli	a5,a5,0x3
    800060d6:	97a6                	add	a5,a5,s1
    800060d8:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800060dc:	fc042503          	lw	a0,-64(s0)
    800060e0:	02250513          	addi	a0,a0,34
    800060e4:	050e                	slli	a0,a0,0x3
    800060e6:	94aa                	add	s1,s1,a0
    800060e8:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800060ec:	fd043503          	ld	a0,-48(s0)
    800060f0:	fffff097          	auipc	ra,0xfffff
    800060f4:	a02080e7          	jalr	-1534(ra) # 80004af2 <fileclose>
    fileclose(wf);
    800060f8:	fc843503          	ld	a0,-56(s0)
    800060fc:	fffff097          	auipc	ra,0xfffff
    80006100:	9f6080e7          	jalr	-1546(ra) # 80004af2 <fileclose>
    return -1;
    80006104:	57fd                	li	a5,-1
    80006106:	a805                	j	80006136 <sys_pipe+0x102>
    if(fd0 >= 0)
    80006108:	fc442783          	lw	a5,-60(s0)
    8000610c:	0007c863          	bltz	a5,8000611c <sys_pipe+0xe8>
      p->ofile[fd0] = 0;
    80006110:	02278793          	addi	a5,a5,34
    80006114:	078e                	slli	a5,a5,0x3
    80006116:	94be                	add	s1,s1,a5
    80006118:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000611c:	fd043503          	ld	a0,-48(s0)
    80006120:	fffff097          	auipc	ra,0xfffff
    80006124:	9d2080e7          	jalr	-1582(ra) # 80004af2 <fileclose>
    fileclose(wf);
    80006128:	fc843503          	ld	a0,-56(s0)
    8000612c:	fffff097          	auipc	ra,0xfffff
    80006130:	9c6080e7          	jalr	-1594(ra) # 80004af2 <fileclose>
    return -1;
    80006134:	57fd                	li	a5,-1
}
    80006136:	853e                	mv	a0,a5
    80006138:	70e2                	ld	ra,56(sp)
    8000613a:	7442                	ld	s0,48(sp)
    8000613c:	74a2                	ld	s1,40(sp)
    8000613e:	6121                	addi	sp,sp,64
    80006140:	8082                	ret
	...

0000000080006150 <kernelvec>:
    80006150:	7111                	addi	sp,sp,-256
    80006152:	e006                	sd	ra,0(sp)
    80006154:	e40a                	sd	sp,8(sp)
    80006156:	e80e                	sd	gp,16(sp)
    80006158:	ec12                	sd	tp,24(sp)
    8000615a:	f016                	sd	t0,32(sp)
    8000615c:	f41a                	sd	t1,40(sp)
    8000615e:	f81e                	sd	t2,48(sp)
    80006160:	fc22                	sd	s0,56(sp)
    80006162:	e0a6                	sd	s1,64(sp)
    80006164:	e4aa                	sd	a0,72(sp)
    80006166:	e8ae                	sd	a1,80(sp)
    80006168:	ecb2                	sd	a2,88(sp)
    8000616a:	f0b6                	sd	a3,96(sp)
    8000616c:	f4ba                	sd	a4,104(sp)
    8000616e:	f8be                	sd	a5,112(sp)
    80006170:	fcc2                	sd	a6,120(sp)
    80006172:	e146                	sd	a7,128(sp)
    80006174:	e54a                	sd	s2,136(sp)
    80006176:	e94e                	sd	s3,144(sp)
    80006178:	ed52                	sd	s4,152(sp)
    8000617a:	f156                	sd	s5,160(sp)
    8000617c:	f55a                	sd	s6,168(sp)
    8000617e:	f95e                	sd	s7,176(sp)
    80006180:	fd62                	sd	s8,184(sp)
    80006182:	e1e6                	sd	s9,192(sp)
    80006184:	e5ea                	sd	s10,200(sp)
    80006186:	e9ee                	sd	s11,208(sp)
    80006188:	edf2                	sd	t3,216(sp)
    8000618a:	f1f6                	sd	t4,224(sp)
    8000618c:	f5fa                	sd	t5,232(sp)
    8000618e:	f9fe                	sd	t6,240(sp)
    80006190:	c47fc0ef          	jal	ra,80002dd6 <kerneltrap>
    80006194:	6082                	ld	ra,0(sp)
    80006196:	6122                	ld	sp,8(sp)
    80006198:	61c2                	ld	gp,16(sp)
    8000619a:	7282                	ld	t0,32(sp)
    8000619c:	7322                	ld	t1,40(sp)
    8000619e:	73c2                	ld	t2,48(sp)
    800061a0:	7462                	ld	s0,56(sp)
    800061a2:	6486                	ld	s1,64(sp)
    800061a4:	6526                	ld	a0,72(sp)
    800061a6:	65c6                	ld	a1,80(sp)
    800061a8:	6666                	ld	a2,88(sp)
    800061aa:	7686                	ld	a3,96(sp)
    800061ac:	7726                	ld	a4,104(sp)
    800061ae:	77c6                	ld	a5,112(sp)
    800061b0:	7866                	ld	a6,120(sp)
    800061b2:	688a                	ld	a7,128(sp)
    800061b4:	692a                	ld	s2,136(sp)
    800061b6:	69ca                	ld	s3,144(sp)
    800061b8:	6a6a                	ld	s4,152(sp)
    800061ba:	7a8a                	ld	s5,160(sp)
    800061bc:	7b2a                	ld	s6,168(sp)
    800061be:	7bca                	ld	s7,176(sp)
    800061c0:	7c6a                	ld	s8,184(sp)
    800061c2:	6c8e                	ld	s9,192(sp)
    800061c4:	6d2e                	ld	s10,200(sp)
    800061c6:	6dce                	ld	s11,208(sp)
    800061c8:	6e6e                	ld	t3,216(sp)
    800061ca:	7e8e                	ld	t4,224(sp)
    800061cc:	7f2e                	ld	t5,232(sp)
    800061ce:	7fce                	ld	t6,240(sp)
    800061d0:	6111                	addi	sp,sp,256
    800061d2:	10200073          	sret
    800061d6:	00000013          	nop
    800061da:	00000013          	nop
    800061de:	0001                	nop

00000000800061e0 <timervec>:
    800061e0:	34051573          	csrrw	a0,mscratch,a0
    800061e4:	e10c                	sd	a1,0(a0)
    800061e6:	e510                	sd	a2,8(a0)
    800061e8:	e914                	sd	a3,16(a0)
    800061ea:	6d0c                	ld	a1,24(a0)
    800061ec:	7110                	ld	a2,32(a0)
    800061ee:	6194                	ld	a3,0(a1)
    800061f0:	96b2                	add	a3,a3,a2
    800061f2:	e194                	sd	a3,0(a1)
    800061f4:	4589                	li	a1,2
    800061f6:	14459073          	csrw	sip,a1
    800061fa:	6914                	ld	a3,16(a0)
    800061fc:	6510                	ld	a2,8(a0)
    800061fe:	610c                	ld	a1,0(a0)
    80006200:	34051573          	csrrw	a0,mscratch,a0
    80006204:	30200073          	mret
	...

000000008000620a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000620a:	1141                	addi	sp,sp,-16
    8000620c:	e422                	sd	s0,8(sp)
    8000620e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006210:	0c0007b7          	lui	a5,0xc000
    80006214:	4705                	li	a4,1
    80006216:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006218:	c3d8                	sw	a4,4(a5)
}
    8000621a:	6422                	ld	s0,8(sp)
    8000621c:	0141                	addi	sp,sp,16
    8000621e:	8082                	ret

0000000080006220 <plicinithart>:

void
plicinithart(void)
{
    80006220:	1141                	addi	sp,sp,-16
    80006222:	e406                	sd	ra,8(sp)
    80006224:	e022                	sd	s0,0(sp)
    80006226:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006228:	ffffb097          	auipc	ra,0xffffb
    8000622c:	776080e7          	jalr	1910(ra) # 8000199e <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006230:	0085171b          	slliw	a4,a0,0x8
    80006234:	0c0027b7          	lui	a5,0xc002
    80006238:	97ba                	add	a5,a5,a4
    8000623a:	40200713          	li	a4,1026
    8000623e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006242:	00d5151b          	slliw	a0,a0,0xd
    80006246:	0c2017b7          	lui	a5,0xc201
    8000624a:	953e                	add	a0,a0,a5
    8000624c:	00052023          	sw	zero,0(a0)
}
    80006250:	60a2                	ld	ra,8(sp)
    80006252:	6402                	ld	s0,0(sp)
    80006254:	0141                	addi	sp,sp,16
    80006256:	8082                	ret

0000000080006258 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006258:	1141                	addi	sp,sp,-16
    8000625a:	e406                	sd	ra,8(sp)
    8000625c:	e022                	sd	s0,0(sp)
    8000625e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006260:	ffffb097          	auipc	ra,0xffffb
    80006264:	73e080e7          	jalr	1854(ra) # 8000199e <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006268:	00d5179b          	slliw	a5,a0,0xd
    8000626c:	0c201537          	lui	a0,0xc201
    80006270:	953e                	add	a0,a0,a5
  return irq;
}
    80006272:	4148                	lw	a0,4(a0)
    80006274:	60a2                	ld	ra,8(sp)
    80006276:	6402                	ld	s0,0(sp)
    80006278:	0141                	addi	sp,sp,16
    8000627a:	8082                	ret

000000008000627c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000627c:	1101                	addi	sp,sp,-32
    8000627e:	ec06                	sd	ra,24(sp)
    80006280:	e822                	sd	s0,16(sp)
    80006282:	e426                	sd	s1,8(sp)
    80006284:	1000                	addi	s0,sp,32
    80006286:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006288:	ffffb097          	auipc	ra,0xffffb
    8000628c:	716080e7          	jalr	1814(ra) # 8000199e <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006290:	00d5151b          	slliw	a0,a0,0xd
    80006294:	0c2017b7          	lui	a5,0xc201
    80006298:	97aa                	add	a5,a5,a0
    8000629a:	c3c4                	sw	s1,4(a5)
}
    8000629c:	60e2                	ld	ra,24(sp)
    8000629e:	6442                	ld	s0,16(sp)
    800062a0:	64a2                	ld	s1,8(sp)
    800062a2:	6105                	addi	sp,sp,32
    800062a4:	8082                	ret

00000000800062a6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800062a6:	1141                	addi	sp,sp,-16
    800062a8:	e406                	sd	ra,8(sp)
    800062aa:	e022                	sd	s0,0(sp)
    800062ac:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800062ae:	479d                	li	a5,7
    800062b0:	04a7cc63          	blt	a5,a0,80006308 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800062b4:	0001d797          	auipc	a5,0x1d
    800062b8:	9bc78793          	addi	a5,a5,-1604 # 80022c70 <disk>
    800062bc:	97aa                	add	a5,a5,a0
    800062be:	0187c783          	lbu	a5,24(a5)
    800062c2:	ebb9                	bnez	a5,80006318 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800062c4:	00451613          	slli	a2,a0,0x4
    800062c8:	0001d797          	auipc	a5,0x1d
    800062cc:	9a878793          	addi	a5,a5,-1624 # 80022c70 <disk>
    800062d0:	6394                	ld	a3,0(a5)
    800062d2:	96b2                	add	a3,a3,a2
    800062d4:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800062d8:	6398                	ld	a4,0(a5)
    800062da:	9732                	add	a4,a4,a2
    800062dc:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800062e0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800062e4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800062e8:	953e                	add	a0,a0,a5
    800062ea:	4785                	li	a5,1
    800062ec:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    800062f0:	0001d517          	auipc	a0,0x1d
    800062f4:	99850513          	addi	a0,a0,-1640 # 80022c88 <disk+0x18>
    800062f8:	ffffc097          	auipc	ra,0xffffc
    800062fc:	152080e7          	jalr	338(ra) # 8000244a <wakeup>
}
    80006300:	60a2                	ld	ra,8(sp)
    80006302:	6402                	ld	s0,0(sp)
    80006304:	0141                	addi	sp,sp,16
    80006306:	8082                	ret
    panic("free_desc 1");
    80006308:	00002517          	auipc	a0,0x2
    8000630c:	48850513          	addi	a0,a0,1160 # 80008790 <syscalls+0x318>
    80006310:	ffffa097          	auipc	ra,0xffffa
    80006314:	22e080e7          	jalr	558(ra) # 8000053e <panic>
    panic("free_desc 2");
    80006318:	00002517          	auipc	a0,0x2
    8000631c:	48850513          	addi	a0,a0,1160 # 800087a0 <syscalls+0x328>
    80006320:	ffffa097          	auipc	ra,0xffffa
    80006324:	21e080e7          	jalr	542(ra) # 8000053e <panic>

0000000080006328 <virtio_disk_init>:
{
    80006328:	1101                	addi	sp,sp,-32
    8000632a:	ec06                	sd	ra,24(sp)
    8000632c:	e822                	sd	s0,16(sp)
    8000632e:	e426                	sd	s1,8(sp)
    80006330:	e04a                	sd	s2,0(sp)
    80006332:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006334:	00002597          	auipc	a1,0x2
    80006338:	47c58593          	addi	a1,a1,1148 # 800087b0 <syscalls+0x338>
    8000633c:	0001d517          	auipc	a0,0x1d
    80006340:	a5c50513          	addi	a0,a0,-1444 # 80022d98 <disk+0x128>
    80006344:	ffffb097          	auipc	ra,0xffffb
    80006348:	802080e7          	jalr	-2046(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000634c:	100017b7          	lui	a5,0x10001
    80006350:	4398                	lw	a4,0(a5)
    80006352:	2701                	sext.w	a4,a4
    80006354:	747277b7          	lui	a5,0x74727
    80006358:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000635c:	14f71c63          	bne	a4,a5,800064b4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006360:	100017b7          	lui	a5,0x10001
    80006364:	43dc                	lw	a5,4(a5)
    80006366:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006368:	4709                	li	a4,2
    8000636a:	14e79563          	bne	a5,a4,800064b4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000636e:	100017b7          	lui	a5,0x10001
    80006372:	479c                	lw	a5,8(a5)
    80006374:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006376:	12e79f63          	bne	a5,a4,800064b4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000637a:	100017b7          	lui	a5,0x10001
    8000637e:	47d8                	lw	a4,12(a5)
    80006380:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006382:	554d47b7          	lui	a5,0x554d4
    80006386:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000638a:	12f71563          	bne	a4,a5,800064b4 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000638e:	100017b7          	lui	a5,0x10001
    80006392:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006396:	4705                	li	a4,1
    80006398:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000639a:	470d                	li	a4,3
    8000639c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000639e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800063a0:	c7ffe737          	lui	a4,0xc7ffe
    800063a4:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb9af>
    800063a8:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800063aa:	2701                	sext.w	a4,a4
    800063ac:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800063ae:	472d                	li	a4,11
    800063b0:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800063b2:	5bbc                	lw	a5,112(a5)
    800063b4:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800063b8:	8ba1                	andi	a5,a5,8
    800063ba:	10078563          	beqz	a5,800064c4 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800063be:	100017b7          	lui	a5,0x10001
    800063c2:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800063c6:	43fc                	lw	a5,68(a5)
    800063c8:	2781                	sext.w	a5,a5
    800063ca:	10079563          	bnez	a5,800064d4 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800063ce:	100017b7          	lui	a5,0x10001
    800063d2:	5bdc                	lw	a5,52(a5)
    800063d4:	2781                	sext.w	a5,a5
  if(max == 0)
    800063d6:	10078763          	beqz	a5,800064e4 <virtio_disk_init+0x1bc>
  if(max < NUM)
    800063da:	471d                	li	a4,7
    800063dc:	10f77c63          	bgeu	a4,a5,800064f4 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    800063e0:	ffffa097          	auipc	ra,0xffffa
    800063e4:	706080e7          	jalr	1798(ra) # 80000ae6 <kalloc>
    800063e8:	0001d497          	auipc	s1,0x1d
    800063ec:	88848493          	addi	s1,s1,-1912 # 80022c70 <disk>
    800063f0:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800063f2:	ffffa097          	auipc	ra,0xffffa
    800063f6:	6f4080e7          	jalr	1780(ra) # 80000ae6 <kalloc>
    800063fa:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800063fc:	ffffa097          	auipc	ra,0xffffa
    80006400:	6ea080e7          	jalr	1770(ra) # 80000ae6 <kalloc>
    80006404:	87aa                	mv	a5,a0
    80006406:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006408:	6088                	ld	a0,0(s1)
    8000640a:	cd6d                	beqz	a0,80006504 <virtio_disk_init+0x1dc>
    8000640c:	0001d717          	auipc	a4,0x1d
    80006410:	86c73703          	ld	a4,-1940(a4) # 80022c78 <disk+0x8>
    80006414:	cb65                	beqz	a4,80006504 <virtio_disk_init+0x1dc>
    80006416:	c7fd                	beqz	a5,80006504 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    80006418:	6605                	lui	a2,0x1
    8000641a:	4581                	li	a1,0
    8000641c:	ffffb097          	auipc	ra,0xffffb
    80006420:	8b6080e7          	jalr	-1866(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006424:	0001d497          	auipc	s1,0x1d
    80006428:	84c48493          	addi	s1,s1,-1972 # 80022c70 <disk>
    8000642c:	6605                	lui	a2,0x1
    8000642e:	4581                	li	a1,0
    80006430:	6488                	ld	a0,8(s1)
    80006432:	ffffb097          	auipc	ra,0xffffb
    80006436:	8a0080e7          	jalr	-1888(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    8000643a:	6605                	lui	a2,0x1
    8000643c:	4581                	li	a1,0
    8000643e:	6888                	ld	a0,16(s1)
    80006440:	ffffb097          	auipc	ra,0xffffb
    80006444:	892080e7          	jalr	-1902(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006448:	100017b7          	lui	a5,0x10001
    8000644c:	4721                	li	a4,8
    8000644e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006450:	4098                	lw	a4,0(s1)
    80006452:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006456:	40d8                	lw	a4,4(s1)
    80006458:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000645c:	6498                	ld	a4,8(s1)
    8000645e:	0007069b          	sext.w	a3,a4
    80006462:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006466:	9701                	srai	a4,a4,0x20
    80006468:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000646c:	6898                	ld	a4,16(s1)
    8000646e:	0007069b          	sext.w	a3,a4
    80006472:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006476:	9701                	srai	a4,a4,0x20
    80006478:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000647c:	4705                	li	a4,1
    8000647e:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80006480:	00e48c23          	sb	a4,24(s1)
    80006484:	00e48ca3          	sb	a4,25(s1)
    80006488:	00e48d23          	sb	a4,26(s1)
    8000648c:	00e48da3          	sb	a4,27(s1)
    80006490:	00e48e23          	sb	a4,28(s1)
    80006494:	00e48ea3          	sb	a4,29(s1)
    80006498:	00e48f23          	sb	a4,30(s1)
    8000649c:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800064a0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800064a4:	0727a823          	sw	s2,112(a5)
}
    800064a8:	60e2                	ld	ra,24(sp)
    800064aa:	6442                	ld	s0,16(sp)
    800064ac:	64a2                	ld	s1,8(sp)
    800064ae:	6902                	ld	s2,0(sp)
    800064b0:	6105                	addi	sp,sp,32
    800064b2:	8082                	ret
    panic("could not find virtio disk");
    800064b4:	00002517          	auipc	a0,0x2
    800064b8:	30c50513          	addi	a0,a0,780 # 800087c0 <syscalls+0x348>
    800064bc:	ffffa097          	auipc	ra,0xffffa
    800064c0:	082080e7          	jalr	130(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    800064c4:	00002517          	auipc	a0,0x2
    800064c8:	31c50513          	addi	a0,a0,796 # 800087e0 <syscalls+0x368>
    800064cc:	ffffa097          	auipc	ra,0xffffa
    800064d0:	072080e7          	jalr	114(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    800064d4:	00002517          	auipc	a0,0x2
    800064d8:	32c50513          	addi	a0,a0,812 # 80008800 <syscalls+0x388>
    800064dc:	ffffa097          	auipc	ra,0xffffa
    800064e0:	062080e7          	jalr	98(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    800064e4:	00002517          	auipc	a0,0x2
    800064e8:	33c50513          	addi	a0,a0,828 # 80008820 <syscalls+0x3a8>
    800064ec:	ffffa097          	auipc	ra,0xffffa
    800064f0:	052080e7          	jalr	82(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    800064f4:	00002517          	auipc	a0,0x2
    800064f8:	34c50513          	addi	a0,a0,844 # 80008840 <syscalls+0x3c8>
    800064fc:	ffffa097          	auipc	ra,0xffffa
    80006500:	042080e7          	jalr	66(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    80006504:	00002517          	auipc	a0,0x2
    80006508:	35c50513          	addi	a0,a0,860 # 80008860 <syscalls+0x3e8>
    8000650c:	ffffa097          	auipc	ra,0xffffa
    80006510:	032080e7          	jalr	50(ra) # 8000053e <panic>

0000000080006514 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006514:	7119                	addi	sp,sp,-128
    80006516:	fc86                	sd	ra,120(sp)
    80006518:	f8a2                	sd	s0,112(sp)
    8000651a:	f4a6                	sd	s1,104(sp)
    8000651c:	f0ca                	sd	s2,96(sp)
    8000651e:	ecce                	sd	s3,88(sp)
    80006520:	e8d2                	sd	s4,80(sp)
    80006522:	e4d6                	sd	s5,72(sp)
    80006524:	e0da                	sd	s6,64(sp)
    80006526:	fc5e                	sd	s7,56(sp)
    80006528:	f862                	sd	s8,48(sp)
    8000652a:	f466                	sd	s9,40(sp)
    8000652c:	f06a                	sd	s10,32(sp)
    8000652e:	ec6e                	sd	s11,24(sp)
    80006530:	0100                	addi	s0,sp,128
    80006532:	8aaa                	mv	s5,a0
    80006534:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006536:	00c52d03          	lw	s10,12(a0)
    8000653a:	001d1d1b          	slliw	s10,s10,0x1
    8000653e:	1d02                	slli	s10,s10,0x20
    80006540:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006544:	0001d517          	auipc	a0,0x1d
    80006548:	85450513          	addi	a0,a0,-1964 # 80022d98 <disk+0x128>
    8000654c:	ffffa097          	auipc	ra,0xffffa
    80006550:	68a080e7          	jalr	1674(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80006554:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006556:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006558:	0001cb97          	auipc	s7,0x1c
    8000655c:	718b8b93          	addi	s7,s7,1816 # 80022c70 <disk>
  for(int i = 0; i < 3; i++){
    80006560:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006562:	0001dc97          	auipc	s9,0x1d
    80006566:	836c8c93          	addi	s9,s9,-1994 # 80022d98 <disk+0x128>
    8000656a:	a08d                	j	800065cc <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000656c:	00fb8733          	add	a4,s7,a5
    80006570:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006574:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006576:	0207c563          	bltz	a5,800065a0 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000657a:	2905                	addiw	s2,s2,1
    8000657c:	0611                	addi	a2,a2,4
    8000657e:	05690c63          	beq	s2,s6,800065d6 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006582:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006584:	0001c717          	auipc	a4,0x1c
    80006588:	6ec70713          	addi	a4,a4,1772 # 80022c70 <disk>
    8000658c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000658e:	01874683          	lbu	a3,24(a4)
    80006592:	fee9                	bnez	a3,8000656c <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006594:	2785                	addiw	a5,a5,1
    80006596:	0705                	addi	a4,a4,1
    80006598:	fe979be3          	bne	a5,s1,8000658e <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000659c:	57fd                	li	a5,-1
    8000659e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800065a0:	01205d63          	blez	s2,800065ba <virtio_disk_rw+0xa6>
    800065a4:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800065a6:	000a2503          	lw	a0,0(s4)
    800065aa:	00000097          	auipc	ra,0x0
    800065ae:	cfc080e7          	jalr	-772(ra) # 800062a6 <free_desc>
      for(int j = 0; j < i; j++)
    800065b2:	2d85                	addiw	s11,s11,1
    800065b4:	0a11                	addi	s4,s4,4
    800065b6:	ffb918e3          	bne	s2,s11,800065a6 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800065ba:	85e6                	mv	a1,s9
    800065bc:	0001c517          	auipc	a0,0x1c
    800065c0:	6cc50513          	addi	a0,a0,1740 # 80022c88 <disk+0x18>
    800065c4:	ffffc097          	auipc	ra,0xffffc
    800065c8:	d9e080e7          	jalr	-610(ra) # 80002362 <sleep>
  for(int i = 0; i < 3; i++){
    800065cc:	f8040a13          	addi	s4,s0,-128
{
    800065d0:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800065d2:	894e                	mv	s2,s3
    800065d4:	b77d                	j	80006582 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800065d6:	f8042583          	lw	a1,-128(s0)
    800065da:	00a58793          	addi	a5,a1,10
    800065de:	0792                	slli	a5,a5,0x4

  if(write)
    800065e0:	0001c617          	auipc	a2,0x1c
    800065e4:	69060613          	addi	a2,a2,1680 # 80022c70 <disk>
    800065e8:	00f60733          	add	a4,a2,a5
    800065ec:	018036b3          	snez	a3,s8
    800065f0:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800065f2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800065f6:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800065fa:	f6078693          	addi	a3,a5,-160
    800065fe:	6218                	ld	a4,0(a2)
    80006600:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006602:	00878513          	addi	a0,a5,8
    80006606:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006608:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000660a:	6208                	ld	a0,0(a2)
    8000660c:	96aa                	add	a3,a3,a0
    8000660e:	4741                	li	a4,16
    80006610:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006612:	4705                	li	a4,1
    80006614:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006618:	f8442703          	lw	a4,-124(s0)
    8000661c:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006620:	0712                	slli	a4,a4,0x4
    80006622:	953a                	add	a0,a0,a4
    80006624:	058a8693          	addi	a3,s5,88
    80006628:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000662a:	6208                	ld	a0,0(a2)
    8000662c:	972a                	add	a4,a4,a0
    8000662e:	40000693          	li	a3,1024
    80006632:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006634:	001c3c13          	seqz	s8,s8
    80006638:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000663a:	001c6c13          	ori	s8,s8,1
    8000663e:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006642:	f8842603          	lw	a2,-120(s0)
    80006646:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000664a:	0001c697          	auipc	a3,0x1c
    8000664e:	62668693          	addi	a3,a3,1574 # 80022c70 <disk>
    80006652:	00258713          	addi	a4,a1,2
    80006656:	0712                	slli	a4,a4,0x4
    80006658:	9736                	add	a4,a4,a3
    8000665a:	587d                	li	a6,-1
    8000665c:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006660:	0612                	slli	a2,a2,0x4
    80006662:	9532                	add	a0,a0,a2
    80006664:	f9078793          	addi	a5,a5,-112
    80006668:	97b6                	add	a5,a5,a3
    8000666a:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    8000666c:	629c                	ld	a5,0(a3)
    8000666e:	97b2                	add	a5,a5,a2
    80006670:	4605                	li	a2,1
    80006672:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006674:	4509                	li	a0,2
    80006676:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    8000667a:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000667e:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006682:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006686:	6698                	ld	a4,8(a3)
    80006688:	00275783          	lhu	a5,2(a4)
    8000668c:	8b9d                	andi	a5,a5,7
    8000668e:	0786                	slli	a5,a5,0x1
    80006690:	97ba                	add	a5,a5,a4
    80006692:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006696:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000669a:	6698                	ld	a4,8(a3)
    8000669c:	00275783          	lhu	a5,2(a4)
    800066a0:	2785                	addiw	a5,a5,1
    800066a2:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800066a6:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800066aa:	100017b7          	lui	a5,0x10001
    800066ae:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800066b2:	004aa783          	lw	a5,4(s5)
    800066b6:	02c79163          	bne	a5,a2,800066d8 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    800066ba:	0001c917          	auipc	s2,0x1c
    800066be:	6de90913          	addi	s2,s2,1758 # 80022d98 <disk+0x128>
  while(b->disk == 1) {
    800066c2:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800066c4:	85ca                	mv	a1,s2
    800066c6:	8556                	mv	a0,s5
    800066c8:	ffffc097          	auipc	ra,0xffffc
    800066cc:	c9a080e7          	jalr	-870(ra) # 80002362 <sleep>
  while(b->disk == 1) {
    800066d0:	004aa783          	lw	a5,4(s5)
    800066d4:	fe9788e3          	beq	a5,s1,800066c4 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800066d8:	f8042903          	lw	s2,-128(s0)
    800066dc:	00290793          	addi	a5,s2,2
    800066e0:	00479713          	slli	a4,a5,0x4
    800066e4:	0001c797          	auipc	a5,0x1c
    800066e8:	58c78793          	addi	a5,a5,1420 # 80022c70 <disk>
    800066ec:	97ba                	add	a5,a5,a4
    800066ee:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800066f2:	0001c997          	auipc	s3,0x1c
    800066f6:	57e98993          	addi	s3,s3,1406 # 80022c70 <disk>
    800066fa:	00491713          	slli	a4,s2,0x4
    800066fe:	0009b783          	ld	a5,0(s3)
    80006702:	97ba                	add	a5,a5,a4
    80006704:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006708:	854a                	mv	a0,s2
    8000670a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000670e:	00000097          	auipc	ra,0x0
    80006712:	b98080e7          	jalr	-1128(ra) # 800062a6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006716:	8885                	andi	s1,s1,1
    80006718:	f0ed                	bnez	s1,800066fa <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000671a:	0001c517          	auipc	a0,0x1c
    8000671e:	67e50513          	addi	a0,a0,1662 # 80022d98 <disk+0x128>
    80006722:	ffffa097          	auipc	ra,0xffffa
    80006726:	568080e7          	jalr	1384(ra) # 80000c8a <release>
}
    8000672a:	70e6                	ld	ra,120(sp)
    8000672c:	7446                	ld	s0,112(sp)
    8000672e:	74a6                	ld	s1,104(sp)
    80006730:	7906                	ld	s2,96(sp)
    80006732:	69e6                	ld	s3,88(sp)
    80006734:	6a46                	ld	s4,80(sp)
    80006736:	6aa6                	ld	s5,72(sp)
    80006738:	6b06                	ld	s6,64(sp)
    8000673a:	7be2                	ld	s7,56(sp)
    8000673c:	7c42                	ld	s8,48(sp)
    8000673e:	7ca2                	ld	s9,40(sp)
    80006740:	7d02                	ld	s10,32(sp)
    80006742:	6de2                	ld	s11,24(sp)
    80006744:	6109                	addi	sp,sp,128
    80006746:	8082                	ret

0000000080006748 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006748:	1101                	addi	sp,sp,-32
    8000674a:	ec06                	sd	ra,24(sp)
    8000674c:	e822                	sd	s0,16(sp)
    8000674e:	e426                	sd	s1,8(sp)
    80006750:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006752:	0001c497          	auipc	s1,0x1c
    80006756:	51e48493          	addi	s1,s1,1310 # 80022c70 <disk>
    8000675a:	0001c517          	auipc	a0,0x1c
    8000675e:	63e50513          	addi	a0,a0,1598 # 80022d98 <disk+0x128>
    80006762:	ffffa097          	auipc	ra,0xffffa
    80006766:	474080e7          	jalr	1140(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000676a:	10001737          	lui	a4,0x10001
    8000676e:	533c                	lw	a5,96(a4)
    80006770:	8b8d                	andi	a5,a5,3
    80006772:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006774:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006778:	689c                	ld	a5,16(s1)
    8000677a:	0204d703          	lhu	a4,32(s1)
    8000677e:	0027d783          	lhu	a5,2(a5)
    80006782:	04f70863          	beq	a4,a5,800067d2 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006786:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000678a:	6898                	ld	a4,16(s1)
    8000678c:	0204d783          	lhu	a5,32(s1)
    80006790:	8b9d                	andi	a5,a5,7
    80006792:	078e                	slli	a5,a5,0x3
    80006794:	97ba                	add	a5,a5,a4
    80006796:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006798:	00278713          	addi	a4,a5,2
    8000679c:	0712                	slli	a4,a4,0x4
    8000679e:	9726                	add	a4,a4,s1
    800067a0:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800067a4:	e721                	bnez	a4,800067ec <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800067a6:	0789                	addi	a5,a5,2
    800067a8:	0792                	slli	a5,a5,0x4
    800067aa:	97a6                	add	a5,a5,s1
    800067ac:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800067ae:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800067b2:	ffffc097          	auipc	ra,0xffffc
    800067b6:	c98080e7          	jalr	-872(ra) # 8000244a <wakeup>

    disk.used_idx += 1;
    800067ba:	0204d783          	lhu	a5,32(s1)
    800067be:	2785                	addiw	a5,a5,1
    800067c0:	17c2                	slli	a5,a5,0x30
    800067c2:	93c1                	srli	a5,a5,0x30
    800067c4:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800067c8:	6898                	ld	a4,16(s1)
    800067ca:	00275703          	lhu	a4,2(a4)
    800067ce:	faf71ce3          	bne	a4,a5,80006786 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800067d2:	0001c517          	auipc	a0,0x1c
    800067d6:	5c650513          	addi	a0,a0,1478 # 80022d98 <disk+0x128>
    800067da:	ffffa097          	auipc	ra,0xffffa
    800067de:	4b0080e7          	jalr	1200(ra) # 80000c8a <release>
}
    800067e2:	60e2                	ld	ra,24(sp)
    800067e4:	6442                	ld	s0,16(sp)
    800067e6:	64a2                	ld	s1,8(sp)
    800067e8:	6105                	addi	sp,sp,32
    800067ea:	8082                	ret
      panic("virtio_disk_intr status");
    800067ec:	00002517          	auipc	a0,0x2
    800067f0:	08c50513          	addi	a0,a0,140 # 80008878 <syscalls+0x400>
    800067f4:	ffffa097          	auipc	ra,0xffffa
    800067f8:	d4a080e7          	jalr	-694(ra) # 8000053e <panic>
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
