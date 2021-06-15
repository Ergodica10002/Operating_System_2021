
user/_threads:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <thread_create>:
static int __time_slot_size = 10;
static int is_thread_start = 0;
static jmp_buf env_st;
// static jmp_buf env_tmp;

struct thread *thread_create(void (*f)(void *), void *arg, int execution_time_slot){
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  10:	8a2a                	mv	s4,a0
  12:	89ae                	mv	s3,a1
  14:	8932                	mv	s2,a2
    struct thread *t = (struct thread*) malloc(sizeof(struct thread));
  16:	0c800513          	li	a0,200
  1a:	00001097          	auipc	ra,0x1
  1e:	a5e080e7          	jalr	-1442(ra) # a78 <malloc>
  22:	84aa                	mv	s1,a0
    //unsigned long stack_p = 0;
    unsigned long new_stack_p;
    unsigned long new_stack;
    new_stack = (unsigned long) malloc(sizeof(unsigned long)*0x100);
  24:	6505                	lui	a0,0x1
  26:	80050513          	addi	a0,a0,-2048 # 800 <vprintf+0x52>
  2a:	00001097          	auipc	ra,0x1
  2e:	a4e080e7          	jalr	-1458(ra) # a78 <malloc>
    new_stack_p = new_stack +0x100*8-0x2*8;
    t->fp = f;
  32:	0144b023          	sd	s4,0(s1)
    t->arg = arg;
  36:	0134b423          	sd	s3,8(s1)
    t->ID  = -1;
  3a:	57fd                	li	a5,-1
  3c:	08f4a823          	sw	a5,144(s1)
    t->buf_set = 0;
  40:	0804ae23          	sw	zero,156(s1)
    t->stack = (void*) new_stack;
  44:	e888                	sd	a0,16(s1)
    new_stack_p = new_stack +0x100*8-0x2*8;
  46:	7f050513          	addi	a0,a0,2032
    t->stack_p = (void*) new_stack_p;
  4a:	ec88                	sd	a0,24(s1)

    if( is_thread_start == 0 )
  4c:	00001797          	auipc	a5,0x1
  50:	bfc7a783          	lw	a5,-1028(a5) # c48 <is_thread_start>
  54:	c799                	beqz	a5,62 <thread_create+0x62>
        t->remain_execution_time = execution_time_slot;
    else
        t->remain_execution_time = execution_time_slot * __time_slot_size;
  56:	00001797          	auipc	a5,0x1
  5a:	be67a783          	lw	a5,-1050(a5) # c3c <__time_slot_size>
  5e:	0327893b          	mulw	s2,a5,s2
  62:	0b24aa23          	sw	s2,180(s1)

    t->is_yield = 0;
  66:	0a04ae23          	sw	zero,188(s1)
    t->is_exited = 0;
  6a:	0c04a023          	sw	zero,192(s1)
    return t;
}
  6e:	8526                	mv	a0,s1
  70:	70a2                	ld	ra,40(sp)
  72:	7402                	ld	s0,32(sp)
  74:	64e2                	ld	s1,24(sp)
  76:	6942                	ld	s2,16(sp)
  78:	69a2                	ld	s3,8(sp)
  7a:	6a02                	ld	s4,0(sp)
  7c:	6145                	addi	sp,sp,48
  7e:	8082                	ret

0000000000000080 <thread_add_runqueue>:
void thread_add_runqueue(struct thread *t){
  80:	1101                	addi	sp,sp,-32
  82:	ec06                	sd	ra,24(sp)
  84:	e822                	sd	s0,16(sp)
  86:	e426                	sd	s1,8(sp)
  88:	1000                	addi	s0,sp,32
  8a:	84aa                	mv	s1,a0
    t->start_time = uptime();
  8c:	00000097          	auipc	ra,0x0
  90:	636080e7          	jalr	1590(ra) # 6c2 <uptime>
  94:	0aa4ac23          	sw	a0,184(s1)
    t->ID  = id;
  98:	00001717          	auipc	a4,0x1
  9c:	ba870713          	addi	a4,a4,-1112 # c40 <id>
  a0:	431c                	lw	a5,0(a4)
  a2:	08f4a823          	sw	a5,144(s1)
    id ++;
  a6:	2785                	addiw	a5,a5,1
  a8:	c31c                	sw	a5,0(a4)
    if(current_thread == NULL){
  aa:	00001797          	auipc	a5,0x1
  ae:	ba67b783          	ld	a5,-1114(a5) # c50 <current_thread>
  b2:	c395                	beqz	a5,d6 <thread_add_runqueue+0x56>
        current_thread->previous = t;
        current_thread->next = t;
        return;
    }
    else{
        if(current_thread->previous->ID == current_thread->ID){
  b4:	73d8                	ld	a4,160(a5)
  b6:	09072603          	lw	a2,144(a4)
  ba:	0907a683          	lw	a3,144(a5)
  be:	02d60363          	beq	a2,a3,e4 <thread_add_runqueue+0x64>
            t->previous = current_thread;
            t->next = current_thread;
        }
        else{
            //Two or more threads in queue
            current_thread->previous->next = t;
  c2:	f744                	sd	s1,168(a4)
            t->previous = current_thread->previous;
  c4:	73d8                	ld	a4,160(a5)
  c6:	f0d8                	sd	a4,160(s1)
            t->next = current_thread;
  c8:	f4dc                	sd	a5,168(s1)
            current_thread->previous = t;
  ca:	f3c4                	sd	s1,160(a5)
        }
    }
}
  cc:	60e2                	ld	ra,24(sp)
  ce:	6442                	ld	s0,16(sp)
  d0:	64a2                	ld	s1,8(sp)
  d2:	6105                	addi	sp,sp,32
  d4:	8082                	ret
        current_thread = t;
  d6:	00001797          	auipc	a5,0x1
  da:	b697bd23          	sd	s1,-1158(a5) # c50 <current_thread>
        current_thread->previous = t;
  de:	f0c4                	sd	s1,160(s1)
        current_thread->next = t;
  e0:	f4c4                	sd	s1,168(s1)
        return;
  e2:	b7ed                	j	cc <thread_add_runqueue+0x4c>
            current_thread->previous = t;
  e4:	f3c4                	sd	s1,160(a5)
            current_thread->next = t;
  e6:	f7c4                	sd	s1,168(a5)
            t->previous = current_thread;
  e8:	f0dc                	sd	a5,160(s1)
            t->next = current_thread;
  ea:	f4dc                	sd	a5,168(s1)
  ec:	b7c5                	j	cc <thread_add_runqueue+0x4c>

00000000000000ee <schedule>:
        
       
    }
    thread_exit();
}
void schedule(void){
  ee:	1141                	addi	sp,sp,-16
  f0:	e422                	sd	s0,8(sp)
  f2:	0800                	addi	s0,sp,16
    if( is_thread_start == 0 )
  f4:	00001797          	auipc	a5,0x1
  f8:	b547a783          	lw	a5,-1196(a5) # c48 <is_thread_start>
  fc:	cb91                	beqz	a5,110 <schedule+0x22>
    else
    {
#if ALG == DEFAULT
        current_thread = current_thread->next;
#elif ALG == FCFS
        if (current_thread->is_exited == 1){
  fe:	00001797          	auipc	a5,0x1
 102:	b527b783          	ld	a5,-1198(a5) # c50 <current_thread>
 106:	0c07a683          	lw	a3,192(a5)
 10a:	4705                	li	a4,1
 10c:	00e68563          	beq	a3,a4,116 <schedule+0x28>
            }
            current_thread = SJ_thread;
        }
#endif
    }
}
 110:	6422                	ld	s0,8(sp)
 112:	0141                	addi	sp,sp,16
 114:	8082                	ret
            current_thread = current_thread->next;    
 116:	77dc                	ld	a5,168(a5)
 118:	00001717          	auipc	a4,0x1
 11c:	b2f73c23          	sd	a5,-1224(a4) # c50 <current_thread>
 120:	bfc5                	j	110 <schedule+0x22>

0000000000000122 <thread_exit>:
void thread_exit(void){
 122:	1101                	addi	sp,sp,-32
 124:	ec06                	sd	ra,24(sp)
 126:	e822                	sd	s0,16(sp)
 128:	e426                	sd	s1,8(sp)
 12a:	e04a                	sd	s2,0(sp)
 12c:	1000                	addi	s0,sp,32
    // remove the thread immediately, and cancel previous thrdstop.
    thrdresume(current_thread->thrdstop_context_id, 1);
 12e:	00001497          	auipc	s1,0x1
 132:	b2248493          	addi	s1,s1,-1246 # c50 <current_thread>
 136:	609c                	ld	a5,0(s1)
 138:	4585                	li	a1,1
 13a:	0b07a503          	lw	a0,176(a5)
 13e:	00000097          	auipc	ra,0x0
 142:	594080e7          	jalr	1428(ra) # 6d2 <thrdresume>
    struct thread* to_remove = current_thread;
 146:	6084                	ld	s1,0(s1)
    printf("thread id %d exec %d ticks\n", to_remove->ID, uptime() - to_remove->start_time);
 148:	0904a903          	lw	s2,144(s1)
 14c:	00000097          	auipc	ra,0x0
 150:	576080e7          	jalr	1398(ra) # 6c2 <uptime>
 154:	0b84a603          	lw	a2,184(s1)
 158:	40c5063b          	subw	a2,a0,a2
 15c:	85ca                	mv	a1,s2
 15e:	00001517          	auipc	a0,0x1
 162:	a7a50513          	addi	a0,a0,-1414 # bd8 <longjmp_1+0xa>
 166:	00001097          	auipc	ra,0x1
 16a:	854080e7          	jalr	-1964(ra) # 9ba <printf>

    to_remove->is_exited = 1;
 16e:	4785                	li	a5,1
 170:	0cf4a023          	sw	a5,192(s1)

    if(to_remove->next != to_remove){
 174:	74dc                	ld	a5,168(s1)
 176:	02978e63          	beq	a5,s1,1b2 <thread_exit+0x90>
        //Still more thread to execute
        schedule() ;
 17a:	00000097          	auipc	ra,0x0
 17e:	f74080e7          	jalr	-140(ra) # ee <schedule>
        //Connect the remaining threads
        struct thread* to_remove_next = to_remove->next;
 182:	74d8                	ld	a4,168(s1)
        to_remove_next->previous = to_remove->previous;
 184:	70dc                	ld	a5,160(s1)
 186:	f35c                	sd	a5,160(a4)
        to_remove->previous->next = to_remove_next;
 188:	f7d8                	sd	a4,168(a5)


        //free pointers
        free(to_remove->stack);
 18a:	6888                	ld	a0,16(s1)
 18c:	00001097          	auipc	ra,0x1
 190:	864080e7          	jalr	-1948(ra) # 9f0 <free>
        free(to_remove);
 194:	8526                	mv	a0,s1
 196:	00001097          	auipc	ra,0x1
 19a:	85a080e7          	jalr	-1958(ra) # 9f0 <free>
        dispatch();
 19e:	00000097          	auipc	ra,0x0
 1a2:	028080e7          	jalr	40(ra) # 1c6 <dispatch>
    }
    else{
        //No more thread to execute
        longjmp(env_st, -1);
    }
}
 1a6:	60e2                	ld	ra,24(sp)
 1a8:	6442                	ld	s0,16(sp)
 1aa:	64a2                	ld	s1,8(sp)
 1ac:	6902                	ld	s2,0(sp)
 1ae:	6105                	addi	sp,sp,32
 1b0:	8082                	ret
        longjmp(env_st, -1);
 1b2:	55fd                	li	a1,-1
 1b4:	00001517          	auipc	a0,0x1
 1b8:	aac50513          	addi	a0,a0,-1364 # c60 <env_st>
 1bc:	00001097          	auipc	ra,0x1
 1c0:	9d8080e7          	jalr	-1576(ra) # b94 <longjmp>
}
 1c4:	b7cd                	j	1a6 <thread_exit+0x84>

00000000000001c6 <dispatch>:
void dispatch(void){
 1c6:	1101                	addi	sp,sp,-32
 1c8:	ec06                	sd	ra,24(sp)
 1ca:	e822                	sd	s0,16(sp)
 1cc:	e426                	sd	s1,8(sp)
 1ce:	e04a                	sd	s2,0(sp)
 1d0:	1000                	addi	s0,sp,32
    if(current_thread->buf_set)
 1d2:	00001497          	auipc	s1,0x1
 1d6:	a7e4b483          	ld	s1,-1410(s1) # c50 <current_thread>
 1da:	09c4a783          	lw	a5,156(s1)
 1de:	cfb1                	beqz	a5,23a <dispatch+0x74>
        thrdstop( next_time, current_thread->thrdstop_context_id, my_thrdstop_handler); // after next_time ticks, my_thrdstop_handler will be called.
 1e0:	0b04a583          	lw	a1,176(s1)
        int next_time = (__time_slot_size >= current_thread->remain_execution_time )? current_thread->remain_execution_time: __time_slot_size;
 1e4:	00001797          	auipc	a5,0x1
 1e8:	a587a783          	lw	a5,-1448(a5) # c3c <__time_slot_size>
 1ec:	0b44a503          	lw	a0,180(s1)
 1f0:	0005069b          	sext.w	a3,a0
 1f4:	0007871b          	sext.w	a4,a5
 1f8:	00d75363          	bge	a4,a3,1fe <dispatch+0x38>
 1fc:	853e                	mv	a0,a5
        thrdstop( next_time, current_thread->thrdstop_context_id, my_thrdstop_handler); // after next_time ticks, my_thrdstop_handler will be called.
 1fe:	00000617          	auipc	a2,0x0
 202:	09860613          	addi	a2,a2,152 # 296 <my_thrdstop_handler>
 206:	2501                	sext.w	a0,a0
 208:	00000097          	auipc	ra,0x0
 20c:	4c2080e7          	jalr	1218(ra) # 6ca <thrdstop>
        thrdresume(current_thread->thrdstop_context_id, 0);
 210:	4581                	li	a1,0
 212:	00001797          	auipc	a5,0x1
 216:	a3e7b783          	ld	a5,-1474(a5) # c50 <current_thread>
 21a:	0b07a503          	lw	a0,176(a5)
 21e:	00000097          	auipc	ra,0x0
 222:	4b4080e7          	jalr	1204(ra) # 6d2 <thrdresume>
    thread_exit();
 226:	00000097          	auipc	ra,0x0
 22a:	efc080e7          	jalr	-260(ra) # 122 <thread_exit>
}
 22e:	60e2                	ld	ra,24(sp)
 230:	6442                	ld	s0,16(sp)
 232:	64a2                	ld	s1,8(sp)
 234:	6902                	ld	s2,0(sp)
 236:	6105                	addi	sp,sp,32
 238:	8082                	ret
        current_thread->buf_set = 1;
 23a:	4785                	li	a5,1
 23c:	08f4ae23          	sw	a5,156(s1)
        new_stack_p = (unsigned long) current_thread->stack_p;      
 240:	0184b903          	ld	s2,24(s1)
        current_thread->thrdstop_context_id = thrdstop( __time_slot_size, -1, my_thrdstop_handler);
 244:	00000617          	auipc	a2,0x0
 248:	05260613          	addi	a2,a2,82 # 296 <my_thrdstop_handler>
 24c:	55fd                	li	a1,-1
 24e:	00001517          	auipc	a0,0x1
 252:	9ee52503          	lw	a0,-1554(a0) # c3c <__time_slot_size>
 256:	00000097          	auipc	ra,0x0
 25a:	474080e7          	jalr	1140(ra) # 6ca <thrdstop>
 25e:	0aa4a823          	sw	a0,176(s1)
        if( current_thread->thrdstop_context_id < 0 )
 262:	00001797          	auipc	a5,0x1
 266:	9ee7b783          	ld	a5,-1554(a5) # c50 <current_thread>
 26a:	0b07a703          	lw	a4,176(a5)
 26e:	00074763          	bltz	a4,27c <dispatch+0xb6>
        asm volatile("mv sp, %0" : : "r" (new_stack_p));
 272:	814a                	mv	sp,s2
        current_thread->fp(current_thread->arg);
 274:	6398                	ld	a4,0(a5)
 276:	6788                	ld	a0,8(a5)
 278:	9702                	jalr	a4
 27a:	b775                	j	226 <dispatch+0x60>
            printf("error: number of threads may exceed\n");
 27c:	00001517          	auipc	a0,0x1
 280:	97c50513          	addi	a0,a0,-1668 # bf8 <longjmp_1+0x2a>
 284:	00000097          	auipc	ra,0x0
 288:	736080e7          	jalr	1846(ra) # 9ba <printf>
            exit(1);
 28c:	4505                	li	a0,1
 28e:	00000097          	auipc	ra,0x0
 292:	39c080e7          	jalr	924(ra) # 62a <exit>

0000000000000296 <my_thrdstop_handler>:
void my_thrdstop_handler(void){
 296:	1141                	addi	sp,sp,-16
 298:	e406                	sd	ra,8(sp)
 29a:	e022                	sd	s0,0(sp)
 29c:	0800                	addi	s0,sp,16
    current_thread->remain_execution_time -= __time_slot_size ;
 29e:	00001717          	auipc	a4,0x1
 2a2:	9b273703          	ld	a4,-1614(a4) # c50 <current_thread>
 2a6:	0b472783          	lw	a5,180(a4)
 2aa:	00001697          	auipc	a3,0x1
 2ae:	9926a683          	lw	a3,-1646(a3) # c3c <__time_slot_size>
 2b2:	9f95                	subw	a5,a5,a3
 2b4:	0007869b          	sext.w	a3,a5
 2b8:	0af72a23          	sw	a5,180(a4)
    if( current_thread->remain_execution_time <= 0 )
 2bc:	00d05e63          	blez	a3,2d8 <my_thrdstop_handler+0x42>
        schedule();
 2c0:	00000097          	auipc	ra,0x0
 2c4:	e2e080e7          	jalr	-466(ra) # ee <schedule>
        dispatch();
 2c8:	00000097          	auipc	ra,0x0
 2cc:	efe080e7          	jalr	-258(ra) # 1c6 <dispatch>
}
 2d0:	60a2                	ld	ra,8(sp)
 2d2:	6402                	ld	s0,0(sp)
 2d4:	0141                	addi	sp,sp,16
 2d6:	8082                	ret
        thread_exit();
 2d8:	00000097          	auipc	ra,0x0
 2dc:	e4a080e7          	jalr	-438(ra) # 122 <thread_exit>
 2e0:	bfc5                	j	2d0 <my_thrdstop_handler+0x3a>

00000000000002e2 <thread_yield>:
void thread_yield(void){
 2e2:	1101                	addi	sp,sp,-32
 2e4:	ec06                	sd	ra,24(sp)
 2e6:	e822                	sd	s0,16(sp)
 2e8:	e426                	sd	s1,8(sp)
 2ea:	1000                	addi	s0,sp,32
    int consume_ticks = cancelthrdstop( current_thread->thrdstop_context_id ); // cancel previous thrdstop and save the current thread context
 2ec:	00001497          	auipc	s1,0x1
 2f0:	96448493          	addi	s1,s1,-1692 # c50 <current_thread>
 2f4:	609c                	ld	a5,0(s1)
 2f6:	0b07a503          	lw	a0,176(a5)
 2fa:	00000097          	auipc	ra,0x0
 2fe:	3e0080e7          	jalr	992(ra) # 6da <cancelthrdstop>
    if( current_thread->is_yield == 0 )
 302:	609c                	ld	a5,0(s1)
 304:	0bc7a703          	lw	a4,188(a5)
 308:	ef05                	bnez	a4,340 <thread_yield+0x5e>
        current_thread->remain_execution_time -= consume_ticks ;
 30a:	0b47a703          	lw	a4,180(a5)
 30e:	40a7053b          	subw	a0,a4,a0
 312:	0005071b          	sext.w	a4,a0
 316:	0aa7aa23          	sw	a0,180(a5)
        current_thread->is_yield = 1;
 31a:	4685                	li	a3,1
 31c:	0ad7ae23          	sw	a3,188(a5)
        if( current_thread->remain_execution_time <= 0 )
 320:	00e05b63          	blez	a4,336 <thread_yield+0x54>
            schedule();
 324:	00000097          	auipc	ra,0x0
 328:	dca080e7          	jalr	-566(ra) # ee <schedule>
            dispatch();
 32c:	00000097          	auipc	ra,0x0
 330:	e9a080e7          	jalr	-358(ra) # 1c6 <dispatch>
 334:	a801                	j	344 <thread_yield+0x62>
            thread_exit();
 336:	00000097          	auipc	ra,0x0
 33a:	dec080e7          	jalr	-532(ra) # 122 <thread_exit>
 33e:	a019                	j	344 <thread_yield+0x62>
        current_thread->is_yield = 0;
 340:	0a07ae23          	sw	zero,188(a5)
}
 344:	60e2                	ld	ra,24(sp)
 346:	6442                	ld	s0,16(sp)
 348:	64a2                	ld	s1,8(sp)
 34a:	6105                	addi	sp,sp,32
 34c:	8082                	ret

000000000000034e <thread_start_threading>:
void thread_start_threading(int time_slot_size){
 34e:	1141                	addi	sp,sp,-16
 350:	e406                	sd	ra,8(sp)
 352:	e022                	sd	s0,0(sp)
 354:	0800                	addi	s0,sp,16
    __time_slot_size = time_slot_size;
 356:	00001797          	auipc	a5,0x1
 35a:	8ea7a323          	sw	a0,-1818(a5) # c3c <__time_slot_size>
    
    struct thread* tmp_thread = current_thread;
 35e:	00001697          	auipc	a3,0x1
 362:	8f26b683          	ld	a3,-1806(a3) # c50 <current_thread>
 366:	87b6                	mv	a5,a3
    while (tmp_thread != NULL)
 368:	cb91                	beqz	a5,37c <thread_start_threading+0x2e>
    {
        tmp_thread->remain_execution_time *= time_slot_size;
 36a:	0b47a703          	lw	a4,180(a5)
 36e:	02a7073b          	mulw	a4,a4,a0
 372:	0ae7aa23          	sw	a4,180(a5)
        tmp_thread = tmp_thread->next;
 376:	77dc                	ld	a5,168(a5)
        if( tmp_thread == current_thread )
 378:	fef698e3          	bne	a3,a5,368 <thread_start_threading+0x1a>
            break;
    }

    int r;
    r = setjmp(env_st);
 37c:	00001517          	auipc	a0,0x1
 380:	8e450513          	addi	a0,a0,-1820 # c60 <env_st>
 384:	00000097          	auipc	ra,0x0
 388:	7d8080e7          	jalr	2008(ra) # b5c <setjmp>
    
    if(current_thread != NULL && r==0){
 38c:	00001797          	auipc	a5,0x1
 390:	8c47b783          	ld	a5,-1852(a5) # c50 <current_thread>
 394:	c391                	beqz	a5,398 <thread_start_threading+0x4a>
 396:	c509                	beqz	a0,3a0 <thread_start_threading+0x52>
        schedule() ;
        is_thread_start = 1;
        dispatch();
    }
}
 398:	60a2                	ld	ra,8(sp)
 39a:	6402                	ld	s0,0(sp)
 39c:	0141                	addi	sp,sp,16
 39e:	8082                	ret
        schedule() ;
 3a0:	00000097          	auipc	ra,0x0
 3a4:	d4e080e7          	jalr	-690(ra) # ee <schedule>
        is_thread_start = 1;
 3a8:	4785                	li	a5,1
 3aa:	00001717          	auipc	a4,0x1
 3ae:	88f72f23          	sw	a5,-1890(a4) # c48 <is_thread_start>
        dispatch();
 3b2:	00000097          	auipc	ra,0x0
 3b6:	e14080e7          	jalr	-492(ra) # 1c6 <dispatch>
}
 3ba:	bff9                	j	398 <thread_start_threading+0x4a>

00000000000003bc <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 3bc:	1141                	addi	sp,sp,-16
 3be:	e422                	sd	s0,8(sp)
 3c0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 3c2:	87aa                	mv	a5,a0
 3c4:	0585                	addi	a1,a1,1
 3c6:	0785                	addi	a5,a5,1
 3c8:	fff5c703          	lbu	a4,-1(a1)
 3cc:	fee78fa3          	sb	a4,-1(a5)
 3d0:	fb75                	bnez	a4,3c4 <strcpy+0x8>
    ;
  return os;
}
 3d2:	6422                	ld	s0,8(sp)
 3d4:	0141                	addi	sp,sp,16
 3d6:	8082                	ret

00000000000003d8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3d8:	1141                	addi	sp,sp,-16
 3da:	e422                	sd	s0,8(sp)
 3dc:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 3de:	00054783          	lbu	a5,0(a0)
 3e2:	cb91                	beqz	a5,3f6 <strcmp+0x1e>
 3e4:	0005c703          	lbu	a4,0(a1)
 3e8:	00f71763          	bne	a4,a5,3f6 <strcmp+0x1e>
    p++, q++;
 3ec:	0505                	addi	a0,a0,1
 3ee:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 3f0:	00054783          	lbu	a5,0(a0)
 3f4:	fbe5                	bnez	a5,3e4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 3f6:	0005c503          	lbu	a0,0(a1)
}
 3fa:	40a7853b          	subw	a0,a5,a0
 3fe:	6422                	ld	s0,8(sp)
 400:	0141                	addi	sp,sp,16
 402:	8082                	ret

0000000000000404 <strlen>:

uint
strlen(const char *s)
{
 404:	1141                	addi	sp,sp,-16
 406:	e422                	sd	s0,8(sp)
 408:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 40a:	00054783          	lbu	a5,0(a0)
 40e:	cf91                	beqz	a5,42a <strlen+0x26>
 410:	0505                	addi	a0,a0,1
 412:	87aa                	mv	a5,a0
 414:	4685                	li	a3,1
 416:	9e89                	subw	a3,a3,a0
 418:	00f6853b          	addw	a0,a3,a5
 41c:	0785                	addi	a5,a5,1
 41e:	fff7c703          	lbu	a4,-1(a5)
 422:	fb7d                	bnez	a4,418 <strlen+0x14>
    ;
  return n;
}
 424:	6422                	ld	s0,8(sp)
 426:	0141                	addi	sp,sp,16
 428:	8082                	ret
  for(n = 0; s[n]; n++)
 42a:	4501                	li	a0,0
 42c:	bfe5                	j	424 <strlen+0x20>

000000000000042e <memset>:

void*
memset(void *dst, int c, uint n)
{
 42e:	1141                	addi	sp,sp,-16
 430:	e422                	sd	s0,8(sp)
 432:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 434:	ca19                	beqz	a2,44a <memset+0x1c>
 436:	87aa                	mv	a5,a0
 438:	1602                	slli	a2,a2,0x20
 43a:	9201                	srli	a2,a2,0x20
 43c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 440:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 444:	0785                	addi	a5,a5,1
 446:	fee79de3          	bne	a5,a4,440 <memset+0x12>
  }
  return dst;
}
 44a:	6422                	ld	s0,8(sp)
 44c:	0141                	addi	sp,sp,16
 44e:	8082                	ret

0000000000000450 <strchr>:

char*
strchr(const char *s, char c)
{
 450:	1141                	addi	sp,sp,-16
 452:	e422                	sd	s0,8(sp)
 454:	0800                	addi	s0,sp,16
  for(; *s; s++)
 456:	00054783          	lbu	a5,0(a0)
 45a:	cb99                	beqz	a5,470 <strchr+0x20>
    if(*s == c)
 45c:	00f58763          	beq	a1,a5,46a <strchr+0x1a>
  for(; *s; s++)
 460:	0505                	addi	a0,a0,1
 462:	00054783          	lbu	a5,0(a0)
 466:	fbfd                	bnez	a5,45c <strchr+0xc>
      return (char*)s;
  return 0;
 468:	4501                	li	a0,0
}
 46a:	6422                	ld	s0,8(sp)
 46c:	0141                	addi	sp,sp,16
 46e:	8082                	ret
  return 0;
 470:	4501                	li	a0,0
 472:	bfe5                	j	46a <strchr+0x1a>

0000000000000474 <gets>:

char*
gets(char *buf, int max)
{
 474:	711d                	addi	sp,sp,-96
 476:	ec86                	sd	ra,88(sp)
 478:	e8a2                	sd	s0,80(sp)
 47a:	e4a6                	sd	s1,72(sp)
 47c:	e0ca                	sd	s2,64(sp)
 47e:	fc4e                	sd	s3,56(sp)
 480:	f852                	sd	s4,48(sp)
 482:	f456                	sd	s5,40(sp)
 484:	f05a                	sd	s6,32(sp)
 486:	ec5e                	sd	s7,24(sp)
 488:	1080                	addi	s0,sp,96
 48a:	8baa                	mv	s7,a0
 48c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 48e:	892a                	mv	s2,a0
 490:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 492:	4aa9                	li	s5,10
 494:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 496:	89a6                	mv	s3,s1
 498:	2485                	addiw	s1,s1,1
 49a:	0344d863          	bge	s1,s4,4ca <gets+0x56>
    cc = read(0, &c, 1);
 49e:	4605                	li	a2,1
 4a0:	faf40593          	addi	a1,s0,-81
 4a4:	4501                	li	a0,0
 4a6:	00000097          	auipc	ra,0x0
 4aa:	19c080e7          	jalr	412(ra) # 642 <read>
    if(cc < 1)
 4ae:	00a05e63          	blez	a0,4ca <gets+0x56>
    buf[i++] = c;
 4b2:	faf44783          	lbu	a5,-81(s0)
 4b6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 4ba:	01578763          	beq	a5,s5,4c8 <gets+0x54>
 4be:	0905                	addi	s2,s2,1
 4c0:	fd679be3          	bne	a5,s6,496 <gets+0x22>
  for(i=0; i+1 < max; ){
 4c4:	89a6                	mv	s3,s1
 4c6:	a011                	j	4ca <gets+0x56>
 4c8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 4ca:	99de                	add	s3,s3,s7
 4cc:	00098023          	sb	zero,0(s3)
  return buf;
}
 4d0:	855e                	mv	a0,s7
 4d2:	60e6                	ld	ra,88(sp)
 4d4:	6446                	ld	s0,80(sp)
 4d6:	64a6                	ld	s1,72(sp)
 4d8:	6906                	ld	s2,64(sp)
 4da:	79e2                	ld	s3,56(sp)
 4dc:	7a42                	ld	s4,48(sp)
 4de:	7aa2                	ld	s5,40(sp)
 4e0:	7b02                	ld	s6,32(sp)
 4e2:	6be2                	ld	s7,24(sp)
 4e4:	6125                	addi	sp,sp,96
 4e6:	8082                	ret

00000000000004e8 <stat>:

int
stat(const char *n, struct stat *st)
{
 4e8:	1101                	addi	sp,sp,-32
 4ea:	ec06                	sd	ra,24(sp)
 4ec:	e822                	sd	s0,16(sp)
 4ee:	e426                	sd	s1,8(sp)
 4f0:	e04a                	sd	s2,0(sp)
 4f2:	1000                	addi	s0,sp,32
 4f4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4f6:	4581                	li	a1,0
 4f8:	00000097          	auipc	ra,0x0
 4fc:	172080e7          	jalr	370(ra) # 66a <open>
  if(fd < 0)
 500:	02054563          	bltz	a0,52a <stat+0x42>
 504:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 506:	85ca                	mv	a1,s2
 508:	00000097          	auipc	ra,0x0
 50c:	17a080e7          	jalr	378(ra) # 682 <fstat>
 510:	892a                	mv	s2,a0
  close(fd);
 512:	8526                	mv	a0,s1
 514:	00000097          	auipc	ra,0x0
 518:	13e080e7          	jalr	318(ra) # 652 <close>
  return r;
}
 51c:	854a                	mv	a0,s2
 51e:	60e2                	ld	ra,24(sp)
 520:	6442                	ld	s0,16(sp)
 522:	64a2                	ld	s1,8(sp)
 524:	6902                	ld	s2,0(sp)
 526:	6105                	addi	sp,sp,32
 528:	8082                	ret
    return -1;
 52a:	597d                	li	s2,-1
 52c:	bfc5                	j	51c <stat+0x34>

000000000000052e <atoi>:

int
atoi(const char *s)
{
 52e:	1141                	addi	sp,sp,-16
 530:	e422                	sd	s0,8(sp)
 532:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 534:	00054603          	lbu	a2,0(a0)
 538:	fd06079b          	addiw	a5,a2,-48
 53c:	0ff7f793          	andi	a5,a5,255
 540:	4725                	li	a4,9
 542:	02f76963          	bltu	a4,a5,574 <atoi+0x46>
 546:	86aa                	mv	a3,a0
  n = 0;
 548:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 54a:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 54c:	0685                	addi	a3,a3,1
 54e:	0025179b          	slliw	a5,a0,0x2
 552:	9fa9                	addw	a5,a5,a0
 554:	0017979b          	slliw	a5,a5,0x1
 558:	9fb1                	addw	a5,a5,a2
 55a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 55e:	0006c603          	lbu	a2,0(a3)
 562:	fd06071b          	addiw	a4,a2,-48
 566:	0ff77713          	andi	a4,a4,255
 56a:	fee5f1e3          	bgeu	a1,a4,54c <atoi+0x1e>
  return n;
}
 56e:	6422                	ld	s0,8(sp)
 570:	0141                	addi	sp,sp,16
 572:	8082                	ret
  n = 0;
 574:	4501                	li	a0,0
 576:	bfe5                	j	56e <atoi+0x40>

0000000000000578 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 578:	1141                	addi	sp,sp,-16
 57a:	e422                	sd	s0,8(sp)
 57c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 57e:	02b57463          	bgeu	a0,a1,5a6 <memmove+0x2e>
    while(n-- > 0)
 582:	00c05f63          	blez	a2,5a0 <memmove+0x28>
 586:	1602                	slli	a2,a2,0x20
 588:	9201                	srli	a2,a2,0x20
 58a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 58e:	872a                	mv	a4,a0
      *dst++ = *src++;
 590:	0585                	addi	a1,a1,1
 592:	0705                	addi	a4,a4,1
 594:	fff5c683          	lbu	a3,-1(a1)
 598:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 59c:	fee79ae3          	bne	a5,a4,590 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 5a0:	6422                	ld	s0,8(sp)
 5a2:	0141                	addi	sp,sp,16
 5a4:	8082                	ret
    dst += n;
 5a6:	00c50733          	add	a4,a0,a2
    src += n;
 5aa:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 5ac:	fec05ae3          	blez	a2,5a0 <memmove+0x28>
 5b0:	fff6079b          	addiw	a5,a2,-1
 5b4:	1782                	slli	a5,a5,0x20
 5b6:	9381                	srli	a5,a5,0x20
 5b8:	fff7c793          	not	a5,a5
 5bc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 5be:	15fd                	addi	a1,a1,-1
 5c0:	177d                	addi	a4,a4,-1
 5c2:	0005c683          	lbu	a3,0(a1)
 5c6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 5ca:	fee79ae3          	bne	a5,a4,5be <memmove+0x46>
 5ce:	bfc9                	j	5a0 <memmove+0x28>

00000000000005d0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 5d0:	1141                	addi	sp,sp,-16
 5d2:	e422                	sd	s0,8(sp)
 5d4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 5d6:	ca05                	beqz	a2,606 <memcmp+0x36>
 5d8:	fff6069b          	addiw	a3,a2,-1
 5dc:	1682                	slli	a3,a3,0x20
 5de:	9281                	srli	a3,a3,0x20
 5e0:	0685                	addi	a3,a3,1
 5e2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 5e4:	00054783          	lbu	a5,0(a0)
 5e8:	0005c703          	lbu	a4,0(a1)
 5ec:	00e79863          	bne	a5,a4,5fc <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 5f0:	0505                	addi	a0,a0,1
    p2++;
 5f2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 5f4:	fed518e3          	bne	a0,a3,5e4 <memcmp+0x14>
  }
  return 0;
 5f8:	4501                	li	a0,0
 5fa:	a019                	j	600 <memcmp+0x30>
      return *p1 - *p2;
 5fc:	40e7853b          	subw	a0,a5,a4
}
 600:	6422                	ld	s0,8(sp)
 602:	0141                	addi	sp,sp,16
 604:	8082                	ret
  return 0;
 606:	4501                	li	a0,0
 608:	bfe5                	j	600 <memcmp+0x30>

000000000000060a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 60a:	1141                	addi	sp,sp,-16
 60c:	e406                	sd	ra,8(sp)
 60e:	e022                	sd	s0,0(sp)
 610:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 612:	00000097          	auipc	ra,0x0
 616:	f66080e7          	jalr	-154(ra) # 578 <memmove>
}
 61a:	60a2                	ld	ra,8(sp)
 61c:	6402                	ld	s0,0(sp)
 61e:	0141                	addi	sp,sp,16
 620:	8082                	ret

0000000000000622 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 622:	4885                	li	a7,1
 ecall
 624:	00000073          	ecall
 ret
 628:	8082                	ret

000000000000062a <exit>:
.global exit
exit:
 li a7, SYS_exit
 62a:	4889                	li	a7,2
 ecall
 62c:	00000073          	ecall
 ret
 630:	8082                	ret

0000000000000632 <wait>:
.global wait
wait:
 li a7, SYS_wait
 632:	488d                	li	a7,3
 ecall
 634:	00000073          	ecall
 ret
 638:	8082                	ret

000000000000063a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 63a:	4891                	li	a7,4
 ecall
 63c:	00000073          	ecall
 ret
 640:	8082                	ret

0000000000000642 <read>:
.global read
read:
 li a7, SYS_read
 642:	4895                	li	a7,5
 ecall
 644:	00000073          	ecall
 ret
 648:	8082                	ret

000000000000064a <write>:
.global write
write:
 li a7, SYS_write
 64a:	48c1                	li	a7,16
 ecall
 64c:	00000073          	ecall
 ret
 650:	8082                	ret

0000000000000652 <close>:
.global close
close:
 li a7, SYS_close
 652:	48d5                	li	a7,21
 ecall
 654:	00000073          	ecall
 ret
 658:	8082                	ret

000000000000065a <kill>:
.global kill
kill:
 li a7, SYS_kill
 65a:	4899                	li	a7,6
 ecall
 65c:	00000073          	ecall
 ret
 660:	8082                	ret

0000000000000662 <exec>:
.global exec
exec:
 li a7, SYS_exec
 662:	489d                	li	a7,7
 ecall
 664:	00000073          	ecall
 ret
 668:	8082                	ret

000000000000066a <open>:
.global open
open:
 li a7, SYS_open
 66a:	48bd                	li	a7,15
 ecall
 66c:	00000073          	ecall
 ret
 670:	8082                	ret

0000000000000672 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 672:	48c5                	li	a7,17
 ecall
 674:	00000073          	ecall
 ret
 678:	8082                	ret

000000000000067a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 67a:	48c9                	li	a7,18
 ecall
 67c:	00000073          	ecall
 ret
 680:	8082                	ret

0000000000000682 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 682:	48a1                	li	a7,8
 ecall
 684:	00000073          	ecall
 ret
 688:	8082                	ret

000000000000068a <link>:
.global link
link:
 li a7, SYS_link
 68a:	48cd                	li	a7,19
 ecall
 68c:	00000073          	ecall
 ret
 690:	8082                	ret

0000000000000692 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 692:	48d1                	li	a7,20
 ecall
 694:	00000073          	ecall
 ret
 698:	8082                	ret

000000000000069a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 69a:	48a5                	li	a7,9
 ecall
 69c:	00000073          	ecall
 ret
 6a0:	8082                	ret

00000000000006a2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 6a2:	48a9                	li	a7,10
 ecall
 6a4:	00000073          	ecall
 ret
 6a8:	8082                	ret

00000000000006aa <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 6aa:	48ad                	li	a7,11
 ecall
 6ac:	00000073          	ecall
 ret
 6b0:	8082                	ret

00000000000006b2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 6b2:	48b1                	li	a7,12
 ecall
 6b4:	00000073          	ecall
 ret
 6b8:	8082                	ret

00000000000006ba <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 6ba:	48b5                	li	a7,13
 ecall
 6bc:	00000073          	ecall
 ret
 6c0:	8082                	ret

00000000000006c2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 6c2:	48b9                	li	a7,14
 ecall
 6c4:	00000073          	ecall
 ret
 6c8:	8082                	ret

00000000000006ca <thrdstop>:
.global thrdstop
thrdstop:
 li a7, SYS_thrdstop
 6ca:	48d9                	li	a7,22
 ecall
 6cc:	00000073          	ecall
 ret
 6d0:	8082                	ret

00000000000006d2 <thrdresume>:
.global thrdresume
thrdresume:
 li a7, SYS_thrdresume
 6d2:	48dd                	li	a7,23
 ecall
 6d4:	00000073          	ecall
 ret
 6d8:	8082                	ret

00000000000006da <cancelthrdstop>:
.global cancelthrdstop
cancelthrdstop:
 li a7, SYS_cancelthrdstop
 6da:	48e1                	li	a7,24
 ecall
 6dc:	00000073          	ecall
 ret
 6e0:	8082                	ret

00000000000006e2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 6e2:	1101                	addi	sp,sp,-32
 6e4:	ec06                	sd	ra,24(sp)
 6e6:	e822                	sd	s0,16(sp)
 6e8:	1000                	addi	s0,sp,32
 6ea:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 6ee:	4605                	li	a2,1
 6f0:	fef40593          	addi	a1,s0,-17
 6f4:	00000097          	auipc	ra,0x0
 6f8:	f56080e7          	jalr	-170(ra) # 64a <write>
}
 6fc:	60e2                	ld	ra,24(sp)
 6fe:	6442                	ld	s0,16(sp)
 700:	6105                	addi	sp,sp,32
 702:	8082                	ret

0000000000000704 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 704:	7139                	addi	sp,sp,-64
 706:	fc06                	sd	ra,56(sp)
 708:	f822                	sd	s0,48(sp)
 70a:	f426                	sd	s1,40(sp)
 70c:	f04a                	sd	s2,32(sp)
 70e:	ec4e                	sd	s3,24(sp)
 710:	0080                	addi	s0,sp,64
 712:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 714:	c299                	beqz	a3,71a <printint+0x16>
 716:	0805c863          	bltz	a1,7a6 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 71a:	2581                	sext.w	a1,a1
  neg = 0;
 71c:	4881                	li	a7,0
 71e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 722:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 724:	2601                	sext.w	a2,a2
 726:	00000517          	auipc	a0,0x0
 72a:	50250513          	addi	a0,a0,1282 # c28 <digits>
 72e:	883a                	mv	a6,a4
 730:	2705                	addiw	a4,a4,1
 732:	02c5f7bb          	remuw	a5,a1,a2
 736:	1782                	slli	a5,a5,0x20
 738:	9381                	srli	a5,a5,0x20
 73a:	97aa                	add	a5,a5,a0
 73c:	0007c783          	lbu	a5,0(a5)
 740:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 744:	0005879b          	sext.w	a5,a1
 748:	02c5d5bb          	divuw	a1,a1,a2
 74c:	0685                	addi	a3,a3,1
 74e:	fec7f0e3          	bgeu	a5,a2,72e <printint+0x2a>
  if(neg)
 752:	00088b63          	beqz	a7,768 <printint+0x64>
    buf[i++] = '-';
 756:	fd040793          	addi	a5,s0,-48
 75a:	973e                	add	a4,a4,a5
 75c:	02d00793          	li	a5,45
 760:	fef70823          	sb	a5,-16(a4)
 764:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 768:	02e05863          	blez	a4,798 <printint+0x94>
 76c:	fc040793          	addi	a5,s0,-64
 770:	00e78933          	add	s2,a5,a4
 774:	fff78993          	addi	s3,a5,-1
 778:	99ba                	add	s3,s3,a4
 77a:	377d                	addiw	a4,a4,-1
 77c:	1702                	slli	a4,a4,0x20
 77e:	9301                	srli	a4,a4,0x20
 780:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 784:	fff94583          	lbu	a1,-1(s2)
 788:	8526                	mv	a0,s1
 78a:	00000097          	auipc	ra,0x0
 78e:	f58080e7          	jalr	-168(ra) # 6e2 <putc>
  while(--i >= 0)
 792:	197d                	addi	s2,s2,-1
 794:	ff3918e3          	bne	s2,s3,784 <printint+0x80>
}
 798:	70e2                	ld	ra,56(sp)
 79a:	7442                	ld	s0,48(sp)
 79c:	74a2                	ld	s1,40(sp)
 79e:	7902                	ld	s2,32(sp)
 7a0:	69e2                	ld	s3,24(sp)
 7a2:	6121                	addi	sp,sp,64
 7a4:	8082                	ret
    x = -xx;
 7a6:	40b005bb          	negw	a1,a1
    neg = 1;
 7aa:	4885                	li	a7,1
    x = -xx;
 7ac:	bf8d                	j	71e <printint+0x1a>

00000000000007ae <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 7ae:	7119                	addi	sp,sp,-128
 7b0:	fc86                	sd	ra,120(sp)
 7b2:	f8a2                	sd	s0,112(sp)
 7b4:	f4a6                	sd	s1,104(sp)
 7b6:	f0ca                	sd	s2,96(sp)
 7b8:	ecce                	sd	s3,88(sp)
 7ba:	e8d2                	sd	s4,80(sp)
 7bc:	e4d6                	sd	s5,72(sp)
 7be:	e0da                	sd	s6,64(sp)
 7c0:	fc5e                	sd	s7,56(sp)
 7c2:	f862                	sd	s8,48(sp)
 7c4:	f466                	sd	s9,40(sp)
 7c6:	f06a                	sd	s10,32(sp)
 7c8:	ec6e                	sd	s11,24(sp)
 7ca:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 7cc:	0005c903          	lbu	s2,0(a1)
 7d0:	18090f63          	beqz	s2,96e <vprintf+0x1c0>
 7d4:	8aaa                	mv	s5,a0
 7d6:	8b32                	mv	s6,a2
 7d8:	00158493          	addi	s1,a1,1
  state = 0;
 7dc:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 7de:	02500a13          	li	s4,37
      if(c == 'd'){
 7e2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 7e6:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 7ea:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 7ee:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7f2:	00000b97          	auipc	s7,0x0
 7f6:	436b8b93          	addi	s7,s7,1078 # c28 <digits>
 7fa:	a839                	j	818 <vprintf+0x6a>
        putc(fd, c);
 7fc:	85ca                	mv	a1,s2
 7fe:	8556                	mv	a0,s5
 800:	00000097          	auipc	ra,0x0
 804:	ee2080e7          	jalr	-286(ra) # 6e2 <putc>
 808:	a019                	j	80e <vprintf+0x60>
    } else if(state == '%'){
 80a:	01498f63          	beq	s3,s4,828 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 80e:	0485                	addi	s1,s1,1
 810:	fff4c903          	lbu	s2,-1(s1)
 814:	14090d63          	beqz	s2,96e <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 818:	0009079b          	sext.w	a5,s2
    if(state == 0){
 81c:	fe0997e3          	bnez	s3,80a <vprintf+0x5c>
      if(c == '%'){
 820:	fd479ee3          	bne	a5,s4,7fc <vprintf+0x4e>
        state = '%';
 824:	89be                	mv	s3,a5
 826:	b7e5                	j	80e <vprintf+0x60>
      if(c == 'd'){
 828:	05878063          	beq	a5,s8,868 <vprintf+0xba>
      } else if(c == 'l') {
 82c:	05978c63          	beq	a5,s9,884 <vprintf+0xd6>
      } else if(c == 'x') {
 830:	07a78863          	beq	a5,s10,8a0 <vprintf+0xf2>
      } else if(c == 'p') {
 834:	09b78463          	beq	a5,s11,8bc <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 838:	07300713          	li	a4,115
 83c:	0ce78663          	beq	a5,a4,908 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 840:	06300713          	li	a4,99
 844:	0ee78e63          	beq	a5,a4,940 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 848:	11478863          	beq	a5,s4,958 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 84c:	85d2                	mv	a1,s4
 84e:	8556                	mv	a0,s5
 850:	00000097          	auipc	ra,0x0
 854:	e92080e7          	jalr	-366(ra) # 6e2 <putc>
        putc(fd, c);
 858:	85ca                	mv	a1,s2
 85a:	8556                	mv	a0,s5
 85c:	00000097          	auipc	ra,0x0
 860:	e86080e7          	jalr	-378(ra) # 6e2 <putc>
      }
      state = 0;
 864:	4981                	li	s3,0
 866:	b765                	j	80e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 868:	008b0913          	addi	s2,s6,8
 86c:	4685                	li	a3,1
 86e:	4629                	li	a2,10
 870:	000b2583          	lw	a1,0(s6)
 874:	8556                	mv	a0,s5
 876:	00000097          	auipc	ra,0x0
 87a:	e8e080e7          	jalr	-370(ra) # 704 <printint>
 87e:	8b4a                	mv	s6,s2
      state = 0;
 880:	4981                	li	s3,0
 882:	b771                	j	80e <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 884:	008b0913          	addi	s2,s6,8
 888:	4681                	li	a3,0
 88a:	4629                	li	a2,10
 88c:	000b2583          	lw	a1,0(s6)
 890:	8556                	mv	a0,s5
 892:	00000097          	auipc	ra,0x0
 896:	e72080e7          	jalr	-398(ra) # 704 <printint>
 89a:	8b4a                	mv	s6,s2
      state = 0;
 89c:	4981                	li	s3,0
 89e:	bf85                	j	80e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 8a0:	008b0913          	addi	s2,s6,8
 8a4:	4681                	li	a3,0
 8a6:	4641                	li	a2,16
 8a8:	000b2583          	lw	a1,0(s6)
 8ac:	8556                	mv	a0,s5
 8ae:	00000097          	auipc	ra,0x0
 8b2:	e56080e7          	jalr	-426(ra) # 704 <printint>
 8b6:	8b4a                	mv	s6,s2
      state = 0;
 8b8:	4981                	li	s3,0
 8ba:	bf91                	j	80e <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 8bc:	008b0793          	addi	a5,s6,8
 8c0:	f8f43423          	sd	a5,-120(s0)
 8c4:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 8c8:	03000593          	li	a1,48
 8cc:	8556                	mv	a0,s5
 8ce:	00000097          	auipc	ra,0x0
 8d2:	e14080e7          	jalr	-492(ra) # 6e2 <putc>
  putc(fd, 'x');
 8d6:	85ea                	mv	a1,s10
 8d8:	8556                	mv	a0,s5
 8da:	00000097          	auipc	ra,0x0
 8de:	e08080e7          	jalr	-504(ra) # 6e2 <putc>
 8e2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 8e4:	03c9d793          	srli	a5,s3,0x3c
 8e8:	97de                	add	a5,a5,s7
 8ea:	0007c583          	lbu	a1,0(a5)
 8ee:	8556                	mv	a0,s5
 8f0:	00000097          	auipc	ra,0x0
 8f4:	df2080e7          	jalr	-526(ra) # 6e2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 8f8:	0992                	slli	s3,s3,0x4
 8fa:	397d                	addiw	s2,s2,-1
 8fc:	fe0914e3          	bnez	s2,8e4 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 900:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 904:	4981                	li	s3,0
 906:	b721                	j	80e <vprintf+0x60>
        s = va_arg(ap, char*);
 908:	008b0993          	addi	s3,s6,8
 90c:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 910:	02090163          	beqz	s2,932 <vprintf+0x184>
        while(*s != 0){
 914:	00094583          	lbu	a1,0(s2)
 918:	c9a1                	beqz	a1,968 <vprintf+0x1ba>
          putc(fd, *s);
 91a:	8556                	mv	a0,s5
 91c:	00000097          	auipc	ra,0x0
 920:	dc6080e7          	jalr	-570(ra) # 6e2 <putc>
          s++;
 924:	0905                	addi	s2,s2,1
        while(*s != 0){
 926:	00094583          	lbu	a1,0(s2)
 92a:	f9e5                	bnez	a1,91a <vprintf+0x16c>
        s = va_arg(ap, char*);
 92c:	8b4e                	mv	s6,s3
      state = 0;
 92e:	4981                	li	s3,0
 930:	bdf9                	j	80e <vprintf+0x60>
          s = "(null)";
 932:	00000917          	auipc	s2,0x0
 936:	2ee90913          	addi	s2,s2,750 # c20 <longjmp_1+0x52>
        while(*s != 0){
 93a:	02800593          	li	a1,40
 93e:	bff1                	j	91a <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 940:	008b0913          	addi	s2,s6,8
 944:	000b4583          	lbu	a1,0(s6)
 948:	8556                	mv	a0,s5
 94a:	00000097          	auipc	ra,0x0
 94e:	d98080e7          	jalr	-616(ra) # 6e2 <putc>
 952:	8b4a                	mv	s6,s2
      state = 0;
 954:	4981                	li	s3,0
 956:	bd65                	j	80e <vprintf+0x60>
        putc(fd, c);
 958:	85d2                	mv	a1,s4
 95a:	8556                	mv	a0,s5
 95c:	00000097          	auipc	ra,0x0
 960:	d86080e7          	jalr	-634(ra) # 6e2 <putc>
      state = 0;
 964:	4981                	li	s3,0
 966:	b565                	j	80e <vprintf+0x60>
        s = va_arg(ap, char*);
 968:	8b4e                	mv	s6,s3
      state = 0;
 96a:	4981                	li	s3,0
 96c:	b54d                	j	80e <vprintf+0x60>
    }
  }
}
 96e:	70e6                	ld	ra,120(sp)
 970:	7446                	ld	s0,112(sp)
 972:	74a6                	ld	s1,104(sp)
 974:	7906                	ld	s2,96(sp)
 976:	69e6                	ld	s3,88(sp)
 978:	6a46                	ld	s4,80(sp)
 97a:	6aa6                	ld	s5,72(sp)
 97c:	6b06                	ld	s6,64(sp)
 97e:	7be2                	ld	s7,56(sp)
 980:	7c42                	ld	s8,48(sp)
 982:	7ca2                	ld	s9,40(sp)
 984:	7d02                	ld	s10,32(sp)
 986:	6de2                	ld	s11,24(sp)
 988:	6109                	addi	sp,sp,128
 98a:	8082                	ret

000000000000098c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 98c:	715d                	addi	sp,sp,-80
 98e:	ec06                	sd	ra,24(sp)
 990:	e822                	sd	s0,16(sp)
 992:	1000                	addi	s0,sp,32
 994:	e010                	sd	a2,0(s0)
 996:	e414                	sd	a3,8(s0)
 998:	e818                	sd	a4,16(s0)
 99a:	ec1c                	sd	a5,24(s0)
 99c:	03043023          	sd	a6,32(s0)
 9a0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 9a4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 9a8:	8622                	mv	a2,s0
 9aa:	00000097          	auipc	ra,0x0
 9ae:	e04080e7          	jalr	-508(ra) # 7ae <vprintf>
}
 9b2:	60e2                	ld	ra,24(sp)
 9b4:	6442                	ld	s0,16(sp)
 9b6:	6161                	addi	sp,sp,80
 9b8:	8082                	ret

00000000000009ba <printf>:

void
printf(const char *fmt, ...)
{
 9ba:	711d                	addi	sp,sp,-96
 9bc:	ec06                	sd	ra,24(sp)
 9be:	e822                	sd	s0,16(sp)
 9c0:	1000                	addi	s0,sp,32
 9c2:	e40c                	sd	a1,8(s0)
 9c4:	e810                	sd	a2,16(s0)
 9c6:	ec14                	sd	a3,24(s0)
 9c8:	f018                	sd	a4,32(s0)
 9ca:	f41c                	sd	a5,40(s0)
 9cc:	03043823          	sd	a6,48(s0)
 9d0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 9d4:	00840613          	addi	a2,s0,8
 9d8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 9dc:	85aa                	mv	a1,a0
 9de:	4505                	li	a0,1
 9e0:	00000097          	auipc	ra,0x0
 9e4:	dce080e7          	jalr	-562(ra) # 7ae <vprintf>
}
 9e8:	60e2                	ld	ra,24(sp)
 9ea:	6442                	ld	s0,16(sp)
 9ec:	6125                	addi	sp,sp,96
 9ee:	8082                	ret

00000000000009f0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 9f0:	1141                	addi	sp,sp,-16
 9f2:	e422                	sd	s0,8(sp)
 9f4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 9f6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9fa:	00000797          	auipc	a5,0x0
 9fe:	25e7b783          	ld	a5,606(a5) # c58 <freep>
 a02:	a805                	j	a32 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 a04:	4618                	lw	a4,8(a2)
 a06:	9db9                	addw	a1,a1,a4
 a08:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a0c:	6398                	ld	a4,0(a5)
 a0e:	6318                	ld	a4,0(a4)
 a10:	fee53823          	sd	a4,-16(a0)
 a14:	a091                	j	a58 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 a16:	ff852703          	lw	a4,-8(a0)
 a1a:	9e39                	addw	a2,a2,a4
 a1c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 a1e:	ff053703          	ld	a4,-16(a0)
 a22:	e398                	sd	a4,0(a5)
 a24:	a099                	j	a6a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a26:	6398                	ld	a4,0(a5)
 a28:	00e7e463          	bltu	a5,a4,a30 <free+0x40>
 a2c:	00e6ea63          	bltu	a3,a4,a40 <free+0x50>
{
 a30:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a32:	fed7fae3          	bgeu	a5,a3,a26 <free+0x36>
 a36:	6398                	ld	a4,0(a5)
 a38:	00e6e463          	bltu	a3,a4,a40 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a3c:	fee7eae3          	bltu	a5,a4,a30 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 a40:	ff852583          	lw	a1,-8(a0)
 a44:	6390                	ld	a2,0(a5)
 a46:	02059713          	slli	a4,a1,0x20
 a4a:	9301                	srli	a4,a4,0x20
 a4c:	0712                	slli	a4,a4,0x4
 a4e:	9736                	add	a4,a4,a3
 a50:	fae60ae3          	beq	a2,a4,a04 <free+0x14>
    bp->s.ptr = p->s.ptr;
 a54:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 a58:	4790                	lw	a2,8(a5)
 a5a:	02061713          	slli	a4,a2,0x20
 a5e:	9301                	srli	a4,a4,0x20
 a60:	0712                	slli	a4,a4,0x4
 a62:	973e                	add	a4,a4,a5
 a64:	fae689e3          	beq	a3,a4,a16 <free+0x26>
  } else
    p->s.ptr = bp;
 a68:	e394                	sd	a3,0(a5)
  freep = p;
 a6a:	00000717          	auipc	a4,0x0
 a6e:	1ef73723          	sd	a5,494(a4) # c58 <freep>
}
 a72:	6422                	ld	s0,8(sp)
 a74:	0141                	addi	sp,sp,16
 a76:	8082                	ret

0000000000000a78 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a78:	7139                	addi	sp,sp,-64
 a7a:	fc06                	sd	ra,56(sp)
 a7c:	f822                	sd	s0,48(sp)
 a7e:	f426                	sd	s1,40(sp)
 a80:	f04a                	sd	s2,32(sp)
 a82:	ec4e                	sd	s3,24(sp)
 a84:	e852                	sd	s4,16(sp)
 a86:	e456                	sd	s5,8(sp)
 a88:	e05a                	sd	s6,0(sp)
 a8a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a8c:	02051493          	slli	s1,a0,0x20
 a90:	9081                	srli	s1,s1,0x20
 a92:	04bd                	addi	s1,s1,15
 a94:	8091                	srli	s1,s1,0x4
 a96:	0014899b          	addiw	s3,s1,1
 a9a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a9c:	00000517          	auipc	a0,0x0
 aa0:	1bc53503          	ld	a0,444(a0) # c58 <freep>
 aa4:	c515                	beqz	a0,ad0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aa6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 aa8:	4798                	lw	a4,8(a5)
 aaa:	02977f63          	bgeu	a4,s1,ae8 <malloc+0x70>
 aae:	8a4e                	mv	s4,s3
 ab0:	0009871b          	sext.w	a4,s3
 ab4:	6685                	lui	a3,0x1
 ab6:	00d77363          	bgeu	a4,a3,abc <malloc+0x44>
 aba:	6a05                	lui	s4,0x1
 abc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 ac0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 ac4:	00000917          	auipc	s2,0x0
 ac8:	19490913          	addi	s2,s2,404 # c58 <freep>
  if(p == (char*)-1)
 acc:	5afd                	li	s5,-1
 ace:	a88d                	j	b40 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 ad0:	00000797          	auipc	a5,0x0
 ad4:	20078793          	addi	a5,a5,512 # cd0 <base>
 ad8:	00000717          	auipc	a4,0x0
 adc:	18f73023          	sd	a5,384(a4) # c58 <freep>
 ae0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 ae2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 ae6:	b7e1                	j	aae <malloc+0x36>
      if(p->s.size == nunits)
 ae8:	02e48b63          	beq	s1,a4,b1e <malloc+0xa6>
        p->s.size -= nunits;
 aec:	4137073b          	subw	a4,a4,s3
 af0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 af2:	1702                	slli	a4,a4,0x20
 af4:	9301                	srli	a4,a4,0x20
 af6:	0712                	slli	a4,a4,0x4
 af8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 afa:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 afe:	00000717          	auipc	a4,0x0
 b02:	14a73d23          	sd	a0,346(a4) # c58 <freep>
      return (void*)(p + 1);
 b06:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 b0a:	70e2                	ld	ra,56(sp)
 b0c:	7442                	ld	s0,48(sp)
 b0e:	74a2                	ld	s1,40(sp)
 b10:	7902                	ld	s2,32(sp)
 b12:	69e2                	ld	s3,24(sp)
 b14:	6a42                	ld	s4,16(sp)
 b16:	6aa2                	ld	s5,8(sp)
 b18:	6b02                	ld	s6,0(sp)
 b1a:	6121                	addi	sp,sp,64
 b1c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 b1e:	6398                	ld	a4,0(a5)
 b20:	e118                	sd	a4,0(a0)
 b22:	bff1                	j	afe <malloc+0x86>
  hp->s.size = nu;
 b24:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 b28:	0541                	addi	a0,a0,16
 b2a:	00000097          	auipc	ra,0x0
 b2e:	ec6080e7          	jalr	-314(ra) # 9f0 <free>
  return freep;
 b32:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 b36:	d971                	beqz	a0,b0a <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b38:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b3a:	4798                	lw	a4,8(a5)
 b3c:	fa9776e3          	bgeu	a4,s1,ae8 <malloc+0x70>
    if(p == freep)
 b40:	00093703          	ld	a4,0(s2)
 b44:	853e                	mv	a0,a5
 b46:	fef719e3          	bne	a4,a5,b38 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 b4a:	8552                	mv	a0,s4
 b4c:	00000097          	auipc	ra,0x0
 b50:	b66080e7          	jalr	-1178(ra) # 6b2 <sbrk>
  if(p == (char*)-1)
 b54:	fd5518e3          	bne	a0,s5,b24 <malloc+0xac>
        return 0;
 b58:	4501                	li	a0,0
 b5a:	bf45                	j	b0a <malloc+0x92>

0000000000000b5c <setjmp>:
 b5c:	e100                	sd	s0,0(a0)
 b5e:	e504                	sd	s1,8(a0)
 b60:	01253823          	sd	s2,16(a0)
 b64:	01353c23          	sd	s3,24(a0)
 b68:	03453023          	sd	s4,32(a0)
 b6c:	03553423          	sd	s5,40(a0)
 b70:	03653823          	sd	s6,48(a0)
 b74:	03753c23          	sd	s7,56(a0)
 b78:	05853023          	sd	s8,64(a0)
 b7c:	05953423          	sd	s9,72(a0)
 b80:	05a53823          	sd	s10,80(a0)
 b84:	05b53c23          	sd	s11,88(a0)
 b88:	06153023          	sd	ra,96(a0)
 b8c:	06253423          	sd	sp,104(a0)
 b90:	4501                	li	a0,0
 b92:	8082                	ret

0000000000000b94 <longjmp>:
 b94:	6100                	ld	s0,0(a0)
 b96:	6504                	ld	s1,8(a0)
 b98:	01053903          	ld	s2,16(a0)
 b9c:	01853983          	ld	s3,24(a0)
 ba0:	02053a03          	ld	s4,32(a0)
 ba4:	02853a83          	ld	s5,40(a0)
 ba8:	03053b03          	ld	s6,48(a0)
 bac:	03853b83          	ld	s7,56(a0)
 bb0:	04053c03          	ld	s8,64(a0)
 bb4:	04853c83          	ld	s9,72(a0)
 bb8:	05053d03          	ld	s10,80(a0)
 bbc:	05853d83          	ld	s11,88(a0)
 bc0:	06053083          	ld	ra,96(a0)
 bc4:	06853103          	ld	sp,104(a0)
 bc8:	c199                	beqz	a1,bce <longjmp_1>
 bca:	852e                	mv	a0,a1
 bcc:	8082                	ret

0000000000000bce <longjmp_1>:
 bce:	4505                	li	a0,1
 bd0:	8082                	ret
