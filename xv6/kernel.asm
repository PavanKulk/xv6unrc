
kernel:     formato del fichero elf32-i386


Desensamblado de la sección .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 50 c6 10 80       	mov    $0x8010c650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 57 34 10 80       	mov    $0x80103457,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 a8 81 10 	movl   $0x801081a8,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100049:	e8 d4 4a 00 00       	call   80104b22 <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 90 db 10 80 84 	movl   $0x8010db84,0x8010db90
80100055:	db 10 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 94 db 10 80 84 	movl   $0x8010db84,0x8010db94
8010005f:	db 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 94 c6 10 80 	movl   $0x8010c694,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 94 db 10 80    	mov    0x8010db94,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c 84 db 10 80 	movl   $0x8010db84,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 94 db 10 80       	mov    0x8010db94,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 94 db 10 80       	mov    %eax,0x8010db94

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 84 db 10 80 	cmpl   $0x8010db84,-0xc(%ebp)
801000ac:	72 bd                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ae:	c9                   	leave  
801000af:	c3                   	ret    

801000b0 <bget>:
// Look through buffer cache for sector on device dev.
// If not found, allocate fresh block.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint sector)
{
801000b0:	55                   	push   %ebp
801000b1:	89 e5                	mov    %esp,%ebp
801000b3:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b6:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801000bd:	e8 81 4a 00 00       	call   80104b43 <acquire>

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 94 db 10 80       	mov    0x8010db94,%eax
801000c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000ca:	eb 63                	jmp    8010012f <bget+0x7f>
    if(b->dev == dev && b->sector == sector){
801000cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000cf:	8b 40 04             	mov    0x4(%eax),%eax
801000d2:	3b 45 08             	cmp    0x8(%ebp),%eax
801000d5:	75 4f                	jne    80100126 <bget+0x76>
801000d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000da:	8b 40 08             	mov    0x8(%eax),%eax
801000dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e0:	75 44                	jne    80100126 <bget+0x76>
      if(!(b->flags & B_BUSY)){
801000e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e5:	8b 00                	mov    (%eax),%eax
801000e7:	83 e0 01             	and    $0x1,%eax
801000ea:	85 c0                	test   %eax,%eax
801000ec:	75 23                	jne    80100111 <bget+0x61>
        b->flags |= B_BUSY;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 00                	mov    (%eax),%eax
801000f3:	89 c2                	mov    %eax,%edx
801000f5:	83 ca 01             	or     $0x1,%edx
801000f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fb:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
801000fd:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100104:	e8 9c 4a 00 00       	call   80104ba5 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 60 c6 10 	movl   $0x8010c660,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 42 47 00 00       	call   80104866 <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 84 db 10 80 	cmpl   $0x8010db84,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 90 db 10 80       	mov    0x8010db90,%eax
8010013d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100140:	eb 4d                	jmp    8010018f <bget+0xdf>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
80100142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100145:	8b 00                	mov    (%eax),%eax
80100147:	83 e0 01             	and    $0x1,%eax
8010014a:	85 c0                	test   %eax,%eax
8010014c:	75 38                	jne    80100186 <bget+0xd6>
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 04             	and    $0x4,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 2c                	jne    80100186 <bget+0xd6>
      b->dev = dev;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 08             	mov    0x8(%ebp),%edx
80100160:	89 50 04             	mov    %edx,0x4(%eax)
      b->sector = sector;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	8b 55 0c             	mov    0xc(%ebp),%edx
80100169:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100175:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010017c:	e8 24 4a 00 00       	call   80104ba5 <release>
      return b;
80100181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100184:	eb 1e                	jmp    801001a4 <bget+0xf4>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 0c             	mov    0xc(%eax),%eax
8010018c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010018f:	81 7d f4 84 db 10 80 	cmpl   $0x8010db84,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 af 81 10 80 	movl   $0x801081af,(%esp)
8010019f:	e8 a2 03 00 00       	call   80100546 <panic>
}
801001a4:	c9                   	leave  
801001a5:	c3                   	ret    

801001a6 <bread>:

// Return a B_BUSY buf with the contents of the indicated disk sector.
struct buf*
bread(uint dev, uint sector)
{
801001a6:	55                   	push   %ebp
801001a7:	89 e5                	mov    %esp,%ebp
801001a9:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, sector);
801001ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801001af:	89 44 24 04          	mov    %eax,0x4(%esp)
801001b3:	8b 45 08             	mov    0x8(%ebp),%eax
801001b6:	89 04 24             	mov    %eax,(%esp)
801001b9:	e8 f2 fe ff ff       	call   801000b0 <bget>
801001be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID))
801001c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001c4:	8b 00                	mov    (%eax),%eax
801001c6:	83 e0 02             	and    $0x2,%eax
801001c9:	85 c0                	test   %eax,%eax
801001cb:	75 0b                	jne    801001d8 <bread+0x32>
    iderw(b);
801001cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d0:	89 04 24             	mov    %eax,(%esp)
801001d3:	e8 20 26 00 00       	call   801027f8 <iderw>
  return b;
801001d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001db:	c9                   	leave  
801001dc:	c3                   	ret    

801001dd <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001dd:	55                   	push   %ebp
801001de:	89 e5                	mov    %esp,%ebp
801001e0:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
801001e3:	8b 45 08             	mov    0x8(%ebp),%eax
801001e6:	8b 00                	mov    (%eax),%eax
801001e8:	83 e0 01             	and    $0x1,%eax
801001eb:	85 c0                	test   %eax,%eax
801001ed:	75 0c                	jne    801001fb <bwrite+0x1e>
    panic("bwrite");
801001ef:	c7 04 24 c0 81 10 80 	movl   $0x801081c0,(%esp)
801001f6:	e8 4b 03 00 00       	call   80100546 <panic>
  b->flags |= B_DIRTY;
801001fb:	8b 45 08             	mov    0x8(%ebp),%eax
801001fe:	8b 00                	mov    (%eax),%eax
80100200:	89 c2                	mov    %eax,%edx
80100202:	83 ca 04             	or     $0x4,%edx
80100205:	8b 45 08             	mov    0x8(%ebp),%eax
80100208:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010020a:	8b 45 08             	mov    0x8(%ebp),%eax
8010020d:	89 04 24             	mov    %eax,(%esp)
80100210:	e8 e3 25 00 00       	call   801027f8 <iderw>
}
80100215:	c9                   	leave  
80100216:	c3                   	ret    

80100217 <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100217:	55                   	push   %ebp
80100218:	89 e5                	mov    %esp,%ebp
8010021a:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
8010021d:	8b 45 08             	mov    0x8(%ebp),%eax
80100220:	8b 00                	mov    (%eax),%eax
80100222:	83 e0 01             	and    $0x1,%eax
80100225:	85 c0                	test   %eax,%eax
80100227:	75 0c                	jne    80100235 <brelse+0x1e>
    panic("brelse");
80100229:	c7 04 24 c7 81 10 80 	movl   $0x801081c7,(%esp)
80100230:	e8 11 03 00 00       	call   80100546 <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010023c:	e8 02 49 00 00       	call   80104b43 <acquire>

  b->next->prev = b->prev;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 40 10             	mov    0x10(%eax),%eax
80100247:	8b 55 08             	mov    0x8(%ebp),%edx
8010024a:	8b 52 0c             	mov    0xc(%edx),%edx
8010024d:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	8b 40 0c             	mov    0xc(%eax),%eax
80100256:	8b 55 08             	mov    0x8(%ebp),%edx
80100259:	8b 52 10             	mov    0x10(%edx),%edx
8010025c:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010025f:	8b 15 94 db 10 80    	mov    0x8010db94,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c 84 db 10 80 	movl   $0x8010db84,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 94 db 10 80       	mov    0x8010db94,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 94 db 10 80       	mov    %eax,0x8010db94

  b->flags &= ~B_BUSY;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	8b 00                	mov    (%eax),%eax
8010028d:	89 c2                	mov    %eax,%edx
8010028f:	83 e2 fe             	and    $0xfffffffe,%edx
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80100297:	8b 45 08             	mov    0x8(%ebp),%eax
8010029a:	89 04 24             	mov    %eax,(%esp)
8010029d:	e8 9d 46 00 00       	call   8010493f <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801002a9:	e8 f7 48 00 00       	call   80104ba5 <release>
}
801002ae:	c9                   	leave  
801002af:	c3                   	ret    

801002b0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002b0:	55                   	push   %ebp
801002b1:	89 e5                	mov    %esp,%ebp
801002b3:	53                   	push   %ebx
801002b4:	83 ec 14             	sub    $0x14,%esp
801002b7:	8b 45 08             	mov    0x8(%ebp),%eax
801002ba:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002be:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
801002c2:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801002c6:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
801002ca:	ec                   	in     (%dx),%al
801002cb:	89 c3                	mov    %eax,%ebx
801002cd:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801002d0:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801002d4:	83 c4 14             	add    $0x14,%esp
801002d7:	5b                   	pop    %ebx
801002d8:	5d                   	pop    %ebp
801002d9:	c3                   	ret    

801002da <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002da:	55                   	push   %ebp
801002db:	89 e5                	mov    %esp,%ebp
801002dd:	83 ec 08             	sub    $0x8,%esp
801002e0:	8b 55 08             	mov    0x8(%ebp),%edx
801002e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801002e6:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801002ea:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801002ed:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801002f1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801002f5:	ee                   	out    %al,(%dx)
}
801002f6:	c9                   	leave  
801002f7:	c3                   	ret    

801002f8 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801002f8:	55                   	push   %ebp
801002f9:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801002fb:	fa                   	cli    
}
801002fc:	5d                   	pop    %ebp
801002fd:	c3                   	ret    

801002fe <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
801002fe:	55                   	push   %ebp
801002ff:	89 e5                	mov    %esp,%ebp
80100301:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100304:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100308:	74 1c                	je     80100326 <printint+0x28>
8010030a:	8b 45 08             	mov    0x8(%ebp),%eax
8010030d:	c1 e8 1f             	shr    $0x1f,%eax
80100310:	0f b6 c0             	movzbl %al,%eax
80100313:	89 45 10             	mov    %eax,0x10(%ebp)
80100316:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010031a:	74 0a                	je     80100326 <printint+0x28>
    x = -xx;
8010031c:	8b 45 08             	mov    0x8(%ebp),%eax
8010031f:	f7 d8                	neg    %eax
80100321:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100324:	eb 06                	jmp    8010032c <printint+0x2e>
  else
    x = xx;
80100326:	8b 45 08             	mov    0x8(%ebp),%eax
80100329:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
8010032c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100333:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100336:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100339:	ba 00 00 00 00       	mov    $0x0,%edx
8010033e:	f7 f1                	div    %ecx
80100340:	89 d0                	mov    %edx,%eax
80100342:	0f b6 80 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%eax
80100349:	8d 4d e0             	lea    -0x20(%ebp),%ecx
8010034c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010034f:	01 ca                	add    %ecx,%edx
80100351:	88 02                	mov    %al,(%edx)
80100353:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
80100357:	8b 55 0c             	mov    0xc(%ebp),%edx
8010035a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
8010035d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100360:	ba 00 00 00 00       	mov    $0x0,%edx
80100365:	f7 75 d4             	divl   -0x2c(%ebp)
80100368:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010036b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010036f:	75 c2                	jne    80100333 <printint+0x35>

  if(sign)
80100371:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100375:	74 27                	je     8010039e <printint+0xa0>
    buf[i++] = '-';
80100377:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010037a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010037d:	01 d0                	add    %edx,%eax
8010037f:	c6 00 2d             	movb   $0x2d,(%eax)
80100382:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
80100386:	eb 16                	jmp    8010039e <printint+0xa0>
    consputc(buf[i]);
80100388:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010038b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038e:	01 d0                	add    %edx,%eax
80100390:	0f b6 00             	movzbl (%eax),%eax
80100393:	0f be c0             	movsbl %al,%eax
80100396:	89 04 24             	mov    %eax,(%esp)
80100399:	e8 bb 03 00 00       	call   80100759 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
8010039e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003a6:	79 e0                	jns    80100388 <printint+0x8a>
    consputc(buf[i]);
}
801003a8:	c9                   	leave  
801003a9:	c3                   	ret    

801003aa <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003aa:	55                   	push   %ebp
801003ab:	89 e5                	mov    %esp,%ebp
801003ad:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003b0:	a1 f4 b5 10 80       	mov    0x8010b5f4,%eax
801003b5:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003b8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003bc:	74 0c                	je     801003ca <cprintf+0x20>
    acquire(&cons.lock);
801003be:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
801003c5:	e8 79 47 00 00       	call   80104b43 <acquire>

  if (fmt == 0)
801003ca:	8b 45 08             	mov    0x8(%ebp),%eax
801003cd:	85 c0                	test   %eax,%eax
801003cf:	75 0c                	jne    801003dd <cprintf+0x33>
    panic("null fmt");
801003d1:	c7 04 24 ce 81 10 80 	movl   $0x801081ce,(%esp)
801003d8:	e8 69 01 00 00       	call   80100546 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003dd:	8d 45 0c             	lea    0xc(%ebp),%eax
801003e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801003ea:	e9 20 01 00 00       	jmp    8010050f <cprintf+0x165>
    if(c != '%'){
801003ef:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801003f3:	74 10                	je     80100405 <cprintf+0x5b>
      consputc(c);
801003f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801003f8:	89 04 24             	mov    %eax,(%esp)
801003fb:	e8 59 03 00 00       	call   80100759 <consputc>
      continue;
80100400:	e9 06 01 00 00       	jmp    8010050b <cprintf+0x161>
    }
    c = fmt[++i] & 0xff;
80100405:	8b 55 08             	mov    0x8(%ebp),%edx
80100408:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010040c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010040f:	01 d0                	add    %edx,%eax
80100411:	0f b6 00             	movzbl (%eax),%eax
80100414:	0f be c0             	movsbl %al,%eax
80100417:	25 ff 00 00 00       	and    $0xff,%eax
8010041c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
8010041f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100423:	0f 84 08 01 00 00    	je     80100531 <cprintf+0x187>
      break;
    switch(c){
80100429:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010042c:	83 f8 70             	cmp    $0x70,%eax
8010042f:	74 4d                	je     8010047e <cprintf+0xd4>
80100431:	83 f8 70             	cmp    $0x70,%eax
80100434:	7f 13                	jg     80100449 <cprintf+0x9f>
80100436:	83 f8 25             	cmp    $0x25,%eax
80100439:	0f 84 a6 00 00 00    	je     801004e5 <cprintf+0x13b>
8010043f:	83 f8 64             	cmp    $0x64,%eax
80100442:	74 14                	je     80100458 <cprintf+0xae>
80100444:	e9 aa 00 00 00       	jmp    801004f3 <cprintf+0x149>
80100449:	83 f8 73             	cmp    $0x73,%eax
8010044c:	74 53                	je     801004a1 <cprintf+0xf7>
8010044e:	83 f8 78             	cmp    $0x78,%eax
80100451:	74 2b                	je     8010047e <cprintf+0xd4>
80100453:	e9 9b 00 00 00       	jmp    801004f3 <cprintf+0x149>
    case 'd':
      printint(*argp++, 10, 1);
80100458:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010045b:	8b 00                	mov    (%eax),%eax
8010045d:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
80100461:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80100468:	00 
80100469:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100470:	00 
80100471:	89 04 24             	mov    %eax,(%esp)
80100474:	e8 85 fe ff ff       	call   801002fe <printint>
      break;
80100479:	e9 8d 00 00 00       	jmp    8010050b <cprintf+0x161>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010047e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100481:	8b 00                	mov    (%eax),%eax
80100483:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
80100487:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010048e:	00 
8010048f:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80100496:	00 
80100497:	89 04 24             	mov    %eax,(%esp)
8010049a:	e8 5f fe ff ff       	call   801002fe <printint>
      break;
8010049f:	eb 6a                	jmp    8010050b <cprintf+0x161>
    case 's':
      if((s = (char*)*argp++) == 0)
801004a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004a4:	8b 00                	mov    (%eax),%eax
801004a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004a9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004ad:	0f 94 c0             	sete   %al
801004b0:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
801004b4:	84 c0                	test   %al,%al
801004b6:	74 20                	je     801004d8 <cprintf+0x12e>
        s = "(null)";
801004b8:	c7 45 ec d7 81 10 80 	movl   $0x801081d7,-0x14(%ebp)
      for(; *s; s++)
801004bf:	eb 17                	jmp    801004d8 <cprintf+0x12e>
        consputc(*s);
801004c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004c4:	0f b6 00             	movzbl (%eax),%eax
801004c7:	0f be c0             	movsbl %al,%eax
801004ca:	89 04 24             	mov    %eax,(%esp)
801004cd:	e8 87 02 00 00       	call   80100759 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004d2:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004d6:	eb 01                	jmp    801004d9 <cprintf+0x12f>
801004d8:	90                   	nop
801004d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004dc:	0f b6 00             	movzbl (%eax),%eax
801004df:	84 c0                	test   %al,%al
801004e1:	75 de                	jne    801004c1 <cprintf+0x117>
        consputc(*s);
      break;
801004e3:	eb 26                	jmp    8010050b <cprintf+0x161>
    case '%':
      consputc('%');
801004e5:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004ec:	e8 68 02 00 00       	call   80100759 <consputc>
      break;
801004f1:	eb 18                	jmp    8010050b <cprintf+0x161>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004f3:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004fa:	e8 5a 02 00 00       	call   80100759 <consputc>
      consputc(c);
801004ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100502:	89 04 24             	mov    %eax,(%esp)
80100505:	e8 4f 02 00 00       	call   80100759 <consputc>
      break;
8010050a:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010050b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010050f:	8b 55 08             	mov    0x8(%ebp),%edx
80100512:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100515:	01 d0                	add    %edx,%eax
80100517:	0f b6 00             	movzbl (%eax),%eax
8010051a:	0f be c0             	movsbl %al,%eax
8010051d:	25 ff 00 00 00       	and    $0xff,%eax
80100522:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100525:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100529:	0f 85 c0 fe ff ff    	jne    801003ef <cprintf+0x45>
8010052f:	eb 01                	jmp    80100532 <cprintf+0x188>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
80100531:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
80100532:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100536:	74 0c                	je     80100544 <cprintf+0x19a>
    release(&cons.lock);
80100538:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
8010053f:	e8 61 46 00 00       	call   80104ba5 <release>
}
80100544:	c9                   	leave  
80100545:	c3                   	ret    

80100546 <panic>:

void
panic(char *s)
{
80100546:	55                   	push   %ebp
80100547:	89 e5                	mov    %esp,%ebp
80100549:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];
  
  cli();
8010054c:	e8 a7 fd ff ff       	call   801002f8 <cli>
  cons.locking = 0;
80100551:	c7 05 f4 b5 10 80 00 	movl   $0x0,0x8010b5f4
80100558:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010055b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100561:	0f b6 00             	movzbl (%eax),%eax
80100564:	0f b6 c0             	movzbl %al,%eax
80100567:	89 44 24 04          	mov    %eax,0x4(%esp)
8010056b:	c7 04 24 de 81 10 80 	movl   $0x801081de,(%esp)
80100572:	e8 33 fe ff ff       	call   801003aa <cprintf>
  cprintf(s);
80100577:	8b 45 08             	mov    0x8(%ebp),%eax
8010057a:	89 04 24             	mov    %eax,(%esp)
8010057d:	e8 28 fe ff ff       	call   801003aa <cprintf>
  cprintf("\n");
80100582:	c7 04 24 ed 81 10 80 	movl   $0x801081ed,(%esp)
80100589:	e8 1c fe ff ff       	call   801003aa <cprintf>
  getcallerpcs(&s, pcs);
8010058e:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100591:	89 44 24 04          	mov    %eax,0x4(%esp)
80100595:	8d 45 08             	lea    0x8(%ebp),%eax
80100598:	89 04 24             	mov    %eax,(%esp)
8010059b:	e8 54 46 00 00       	call   80104bf4 <getcallerpcs>
  for(i=0; i<10; i++)
801005a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005a7:	eb 1b                	jmp    801005c4 <panic+0x7e>
    cprintf(" %p", pcs[i]);
801005a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005ac:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005b0:	89 44 24 04          	mov    %eax,0x4(%esp)
801005b4:	c7 04 24 ef 81 10 80 	movl   $0x801081ef,(%esp)
801005bb:	e8 ea fd ff ff       	call   801003aa <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005c0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005c4:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005c8:	7e df                	jle    801005a9 <panic+0x63>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005ca:	c7 05 a0 b5 10 80 01 	movl   $0x1,0x8010b5a0
801005d1:	00 00 00 
  for(;;)
    ;
801005d4:	eb fe                	jmp    801005d4 <panic+0x8e>

801005d6 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005d6:	55                   	push   %ebp
801005d7:	89 e5                	mov    %esp,%ebp
801005d9:	83 ec 28             	sub    $0x28,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005dc:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005e3:	00 
801005e4:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005eb:	e8 ea fc ff ff       	call   801002da <outb>
  pos = inb(CRTPORT+1) << 8;
801005f0:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005f7:	e8 b4 fc ff ff       	call   801002b0 <inb>
801005fc:	0f b6 c0             	movzbl %al,%eax
801005ff:	c1 e0 08             	shl    $0x8,%eax
80100602:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
80100605:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
8010060c:	00 
8010060d:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100614:	e8 c1 fc ff ff       	call   801002da <outb>
  pos |= inb(CRTPORT+1);
80100619:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100620:	e8 8b fc ff ff       	call   801002b0 <inb>
80100625:	0f b6 c0             	movzbl %al,%eax
80100628:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010062b:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
8010062f:	75 30                	jne    80100661 <cgaputc+0x8b>
    pos += 80 - pos%80;
80100631:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100634:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100639:	89 c8                	mov    %ecx,%eax
8010063b:	f7 ea                	imul   %edx
8010063d:	c1 fa 05             	sar    $0x5,%edx
80100640:	89 c8                	mov    %ecx,%eax
80100642:	c1 f8 1f             	sar    $0x1f,%eax
80100645:	29 c2                	sub    %eax,%edx
80100647:	89 d0                	mov    %edx,%eax
80100649:	c1 e0 02             	shl    $0x2,%eax
8010064c:	01 d0                	add    %edx,%eax
8010064e:	c1 e0 04             	shl    $0x4,%eax
80100651:	89 ca                	mov    %ecx,%edx
80100653:	29 c2                	sub    %eax,%edx
80100655:	b8 50 00 00 00       	mov    $0x50,%eax
8010065a:	29 d0                	sub    %edx,%eax
8010065c:	01 45 f4             	add    %eax,-0xc(%ebp)
8010065f:	eb 32                	jmp    80100693 <cgaputc+0xbd>
  else if(c == BACKSPACE){
80100661:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100668:	75 0c                	jne    80100676 <cgaputc+0xa0>
    if(pos > 0) --pos;
8010066a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010066e:	7e 23                	jle    80100693 <cgaputc+0xbd>
80100670:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100674:	eb 1d                	jmp    80100693 <cgaputc+0xbd>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100676:	a1 00 90 10 80       	mov    0x80109000,%eax
8010067b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010067e:	01 d2                	add    %edx,%edx
80100680:	01 c2                	add    %eax,%edx
80100682:	8b 45 08             	mov    0x8(%ebp),%eax
80100685:	66 25 ff 00          	and    $0xff,%ax
80100689:	80 cc 07             	or     $0x7,%ah
8010068c:	66 89 02             	mov    %ax,(%edx)
8010068f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  
  if((pos/80) >= 24){  // Scroll up.
80100693:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
8010069a:	7e 53                	jle    801006ef <cgaputc+0x119>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
8010069c:	a1 00 90 10 80       	mov    0x80109000,%eax
801006a1:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006a7:	a1 00 90 10 80       	mov    0x80109000,%eax
801006ac:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006b3:	00 
801006b4:	89 54 24 04          	mov    %edx,0x4(%esp)
801006b8:	89 04 24             	mov    %eax,(%esp)
801006bb:	e8 b1 47 00 00       	call   80104e71 <memmove>
    pos -= 80;
801006c0:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006c4:	b8 80 07 00 00       	mov    $0x780,%eax
801006c9:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006cc:	01 c0                	add    %eax,%eax
801006ce:	8b 15 00 90 10 80    	mov    0x80109000,%edx
801006d4:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006d7:	01 c9                	add    %ecx,%ecx
801006d9:	01 ca                	add    %ecx,%edx
801006db:	89 44 24 08          	mov    %eax,0x8(%esp)
801006df:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006e6:	00 
801006e7:	89 14 24             	mov    %edx,(%esp)
801006ea:	e8 af 46 00 00       	call   80104d9e <memset>
  }
  
  outb(CRTPORT, 14);
801006ef:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801006f6:	00 
801006f7:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801006fe:	e8 d7 fb ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos>>8);
80100703:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100706:	c1 f8 08             	sar    $0x8,%eax
80100709:	0f b6 c0             	movzbl %al,%eax
8010070c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100710:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100717:	e8 be fb ff ff       	call   801002da <outb>
  outb(CRTPORT, 15);
8010071c:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100723:	00 
80100724:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010072b:	e8 aa fb ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos);
80100730:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100733:	0f b6 c0             	movzbl %al,%eax
80100736:	89 44 24 04          	mov    %eax,0x4(%esp)
8010073a:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100741:	e8 94 fb ff ff       	call   801002da <outb>
  crt[pos] = ' ' | 0x0700;
80100746:	a1 00 90 10 80       	mov    0x80109000,%eax
8010074b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010074e:	01 d2                	add    %edx,%edx
80100750:	01 d0                	add    %edx,%eax
80100752:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100757:	c9                   	leave  
80100758:	c3                   	ret    

80100759 <consputc>:

void
consputc(int c)
{
80100759:	55                   	push   %ebp
8010075a:	89 e5                	mov    %esp,%ebp
8010075c:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
8010075f:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
80100764:	85 c0                	test   %eax,%eax
80100766:	74 07                	je     8010076f <consputc+0x16>
    cli();
80100768:	e8 8b fb ff ff       	call   801002f8 <cli>
    for(;;)
      ;
8010076d:	eb fe                	jmp    8010076d <consputc+0x14>
  }

  if(c == BACKSPACE){
8010076f:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100776:	75 26                	jne    8010079e <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100778:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010077f:	e8 e1 5f 00 00       	call   80106765 <uartputc>
80100784:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010078b:	e8 d5 5f 00 00       	call   80106765 <uartputc>
80100790:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100797:	e8 c9 5f 00 00       	call   80106765 <uartputc>
8010079c:	eb 0b                	jmp    801007a9 <consputc+0x50>
  } else
    uartputc(c);
8010079e:	8b 45 08             	mov    0x8(%ebp),%eax
801007a1:	89 04 24             	mov    %eax,(%esp)
801007a4:	e8 bc 5f 00 00       	call   80106765 <uartputc>
  cgaputc(c);
801007a9:	8b 45 08             	mov    0x8(%ebp),%eax
801007ac:	89 04 24             	mov    %eax,(%esp)
801007af:	e8 22 fe ff ff       	call   801005d6 <cgaputc>
}
801007b4:	c9                   	leave  
801007b5:	c3                   	ret    

801007b6 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007b6:	55                   	push   %ebp
801007b7:	89 e5                	mov    %esp,%ebp
801007b9:	83 ec 28             	sub    $0x28,%esp
  int c;

  acquire(&input.lock);
801007bc:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
801007c3:	e8 7b 43 00 00       	call   80104b43 <acquire>
  while((c = getc()) >= 0){
801007c8:	e9 41 01 00 00       	jmp    8010090e <consoleintr+0x158>
    switch(c){
801007cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007d0:	83 f8 10             	cmp    $0x10,%eax
801007d3:	74 1e                	je     801007f3 <consoleintr+0x3d>
801007d5:	83 f8 10             	cmp    $0x10,%eax
801007d8:	7f 0a                	jg     801007e4 <consoleintr+0x2e>
801007da:	83 f8 08             	cmp    $0x8,%eax
801007dd:	74 68                	je     80100847 <consoleintr+0x91>
801007df:	e9 94 00 00 00       	jmp    80100878 <consoleintr+0xc2>
801007e4:	83 f8 15             	cmp    $0x15,%eax
801007e7:	74 2f                	je     80100818 <consoleintr+0x62>
801007e9:	83 f8 7f             	cmp    $0x7f,%eax
801007ec:	74 59                	je     80100847 <consoleintr+0x91>
801007ee:	e9 85 00 00 00       	jmp    80100878 <consoleintr+0xc2>
    case C('P'):  // Process listing.
      procdump();
801007f3:	e8 ea 41 00 00       	call   801049e2 <procdump>
      break;
801007f8:	e9 11 01 00 00       	jmp    8010090e <consoleintr+0x158>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801007fd:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100802:	83 e8 01             	sub    $0x1,%eax
80100805:	a3 5c de 10 80       	mov    %eax,0x8010de5c
        consputc(BACKSPACE);
8010080a:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100811:	e8 43 ff ff ff       	call   80100759 <consputc>
80100816:	eb 01                	jmp    80100819 <consoleintr+0x63>
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100818:	90                   	nop
80100819:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
8010081f:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100824:	39 c2                	cmp    %eax,%edx
80100826:	0f 84 db 00 00 00    	je     80100907 <consoleintr+0x151>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010082c:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100831:	83 e8 01             	sub    $0x1,%eax
80100834:	83 e0 7f             	and    $0x7f,%eax
80100837:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010083e:	3c 0a                	cmp    $0xa,%al
80100840:	75 bb                	jne    801007fd <consoleintr+0x47>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100842:	e9 c0 00 00 00       	jmp    80100907 <consoleintr+0x151>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100847:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
8010084d:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100852:	39 c2                	cmp    %eax,%edx
80100854:	0f 84 b0 00 00 00    	je     8010090a <consoleintr+0x154>
        input.e--;
8010085a:	a1 5c de 10 80       	mov    0x8010de5c,%eax
8010085f:	83 e8 01             	sub    $0x1,%eax
80100862:	a3 5c de 10 80       	mov    %eax,0x8010de5c
        consputc(BACKSPACE);
80100867:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010086e:	e8 e6 fe ff ff       	call   80100759 <consputc>
      }
      break;
80100873:	e9 92 00 00 00       	jmp    8010090a <consoleintr+0x154>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100878:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010087c:	0f 84 8b 00 00 00    	je     8010090d <consoleintr+0x157>
80100882:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100888:	a1 54 de 10 80       	mov    0x8010de54,%eax
8010088d:	89 d1                	mov    %edx,%ecx
8010088f:	29 c1                	sub    %eax,%ecx
80100891:	89 c8                	mov    %ecx,%eax
80100893:	83 f8 7f             	cmp    $0x7f,%eax
80100896:	77 75                	ja     8010090d <consoleintr+0x157>
        c = (c == '\r') ? '\n' : c;
80100898:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
8010089c:	74 05                	je     801008a3 <consoleintr+0xed>
8010089e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008a1:	eb 05                	jmp    801008a8 <consoleintr+0xf2>
801008a3:	b8 0a 00 00 00       	mov    $0xa,%eax
801008a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008ab:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801008b0:	89 c1                	mov    %eax,%ecx
801008b2:	83 e1 7f             	and    $0x7f,%ecx
801008b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801008b8:	88 91 d4 dd 10 80    	mov    %dl,-0x7fef222c(%ecx)
801008be:	83 c0 01             	add    $0x1,%eax
801008c1:	a3 5c de 10 80       	mov    %eax,0x8010de5c
        consputc(c);
801008c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008c9:	89 04 24             	mov    %eax,(%esp)
801008cc:	e8 88 fe ff ff       	call   80100759 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008d1:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
801008d5:	74 18                	je     801008ef <consoleintr+0x139>
801008d7:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
801008db:	74 12                	je     801008ef <consoleintr+0x139>
801008dd:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801008e2:	8b 15 54 de 10 80    	mov    0x8010de54,%edx
801008e8:	83 ea 80             	sub    $0xffffff80,%edx
801008eb:	39 d0                	cmp    %edx,%eax
801008ed:	75 1e                	jne    8010090d <consoleintr+0x157>
          input.w = input.e;
801008ef:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801008f4:	a3 58 de 10 80       	mov    %eax,0x8010de58
          wakeup(&input.r);
801008f9:	c7 04 24 54 de 10 80 	movl   $0x8010de54,(%esp)
80100900:	e8 3a 40 00 00       	call   8010493f <wakeup>
        }
      }
      break;
80100905:	eb 06                	jmp    8010090d <consoleintr+0x157>
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100907:	90                   	nop
80100908:	eb 04                	jmp    8010090e <consoleintr+0x158>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
8010090a:	90                   	nop
8010090b:	eb 01                	jmp    8010090e <consoleintr+0x158>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
          input.w = input.e;
          wakeup(&input.r);
        }
      }
      break;
8010090d:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
8010090e:	8b 45 08             	mov    0x8(%ebp),%eax
80100911:	ff d0                	call   *%eax
80100913:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100916:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010091a:	0f 89 ad fe ff ff    	jns    801007cd <consoleintr+0x17>
        }
      }
      break;
    }
  }
  release(&input.lock);
80100920:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100927:	e8 79 42 00 00       	call   80104ba5 <release>
}
8010092c:	c9                   	leave  
8010092d:	c3                   	ret    

8010092e <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010092e:	55                   	push   %ebp
8010092f:	89 e5                	mov    %esp,%ebp
80100931:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100934:	8b 45 08             	mov    0x8(%ebp),%eax
80100937:	89 04 24             	mov    %eax,(%esp)
8010093a:	e8 9b 10 00 00       	call   801019da <iunlock>
  target = n;
8010093f:	8b 45 10             	mov    0x10(%ebp),%eax
80100942:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100945:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
8010094c:	e8 f2 41 00 00       	call   80104b43 <acquire>
  while(n > 0){
80100951:	e9 a8 00 00 00       	jmp    801009fe <consoleread+0xd0>
    while(input.r == input.w){
      if(proc->killed){
80100956:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010095c:	8b 40 24             	mov    0x24(%eax),%eax
8010095f:	85 c0                	test   %eax,%eax
80100961:	74 21                	je     80100984 <consoleread+0x56>
        release(&input.lock);
80100963:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
8010096a:	e8 36 42 00 00       	call   80104ba5 <release>
        ilock(ip);
8010096f:	8b 45 08             	mov    0x8(%ebp),%eax
80100972:	89 04 24             	mov    %eax,(%esp)
80100975:	e8 12 0f 00 00       	call   8010188c <ilock>
        return -1;
8010097a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010097f:	e9 a9 00 00 00       	jmp    80100a2d <consoleread+0xff>
      }
      sleep(&input.r, &input.lock);
80100984:	c7 44 24 04 a0 dd 10 	movl   $0x8010dda0,0x4(%esp)
8010098b:	80 
8010098c:	c7 04 24 54 de 10 80 	movl   $0x8010de54,(%esp)
80100993:	e8 ce 3e 00 00       	call   80104866 <sleep>
80100998:	eb 01                	jmp    8010099b <consoleread+0x6d>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
8010099a:	90                   	nop
8010099b:	8b 15 54 de 10 80    	mov    0x8010de54,%edx
801009a1:	a1 58 de 10 80       	mov    0x8010de58,%eax
801009a6:	39 c2                	cmp    %eax,%edx
801009a8:	74 ac                	je     80100956 <consoleread+0x28>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009aa:	a1 54 de 10 80       	mov    0x8010de54,%eax
801009af:	89 c2                	mov    %eax,%edx
801009b1:	83 e2 7f             	and    $0x7f,%edx
801009b4:	0f b6 92 d4 dd 10 80 	movzbl -0x7fef222c(%edx),%edx
801009bb:	0f be d2             	movsbl %dl,%edx
801009be:	89 55 f0             	mov    %edx,-0x10(%ebp)
801009c1:	83 c0 01             	add    $0x1,%eax
801009c4:	a3 54 de 10 80       	mov    %eax,0x8010de54
    if(c == C('D')){  // EOF
801009c9:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009cd:	75 17                	jne    801009e6 <consoleread+0xb8>
      if(n < target){
801009cf:	8b 45 10             	mov    0x10(%ebp),%eax
801009d2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801009d5:	73 2f                	jae    80100a06 <consoleread+0xd8>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
801009d7:	a1 54 de 10 80       	mov    0x8010de54,%eax
801009dc:	83 e8 01             	sub    $0x1,%eax
801009df:	a3 54 de 10 80       	mov    %eax,0x8010de54
      }
      break;
801009e4:	eb 20                	jmp    80100a06 <consoleread+0xd8>
    }
    *dst++ = c;
801009e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801009e9:	89 c2                	mov    %eax,%edx
801009eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801009ee:	88 10                	mov    %dl,(%eax)
801009f0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    --n;
801009f4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
801009f8:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
801009fc:	74 0b                	je     80100a09 <consoleread+0xdb>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
801009fe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a02:	7f 96                	jg     8010099a <consoleread+0x6c>
80100a04:	eb 04                	jmp    80100a0a <consoleread+0xdc>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100a06:	90                   	nop
80100a07:	eb 01                	jmp    80100a0a <consoleread+0xdc>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100a09:	90                   	nop
  }
  release(&input.lock);
80100a0a:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100a11:	e8 8f 41 00 00       	call   80104ba5 <release>
  ilock(ip);
80100a16:	8b 45 08             	mov    0x8(%ebp),%eax
80100a19:	89 04 24             	mov    %eax,(%esp)
80100a1c:	e8 6b 0e 00 00       	call   8010188c <ilock>

  return target - n;
80100a21:	8b 45 10             	mov    0x10(%ebp),%eax
80100a24:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a27:	89 d1                	mov    %edx,%ecx
80100a29:	29 c1                	sub    %eax,%ecx
80100a2b:	89 c8                	mov    %ecx,%eax
}
80100a2d:	c9                   	leave  
80100a2e:	c3                   	ret    

80100a2f <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a2f:	55                   	push   %ebp
80100a30:	89 e5                	mov    %esp,%ebp
80100a32:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100a35:	8b 45 08             	mov    0x8(%ebp),%eax
80100a38:	89 04 24             	mov    %eax,(%esp)
80100a3b:	e8 9a 0f 00 00       	call   801019da <iunlock>
  acquire(&cons.lock);
80100a40:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100a47:	e8 f7 40 00 00       	call   80104b43 <acquire>
  for(i = 0; i < n; i++)
80100a4c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a53:	eb 1f                	jmp    80100a74 <consolewrite+0x45>
    consputc(buf[i] & 0xff);
80100a55:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a58:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a5b:	01 d0                	add    %edx,%eax
80100a5d:	0f b6 00             	movzbl (%eax),%eax
80100a60:	0f be c0             	movsbl %al,%eax
80100a63:	25 ff 00 00 00       	and    $0xff,%eax
80100a68:	89 04 24             	mov    %eax,(%esp)
80100a6b:	e8 e9 fc ff ff       	call   80100759 <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100a70:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a77:	3b 45 10             	cmp    0x10(%ebp),%eax
80100a7a:	7c d9                	jl     80100a55 <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100a7c:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100a83:	e8 1d 41 00 00       	call   80104ba5 <release>
  ilock(ip);
80100a88:	8b 45 08             	mov    0x8(%ebp),%eax
80100a8b:	89 04 24             	mov    %eax,(%esp)
80100a8e:	e8 f9 0d 00 00       	call   8010188c <ilock>

  return n;
80100a93:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100a96:	c9                   	leave  
80100a97:	c3                   	ret    

80100a98 <consoleinit>:

void
consoleinit(void)
{
80100a98:	55                   	push   %ebp
80100a99:	89 e5                	mov    %esp,%ebp
80100a9b:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100a9e:	c7 44 24 04 f3 81 10 	movl   $0x801081f3,0x4(%esp)
80100aa5:	80 
80100aa6:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100aad:	e8 70 40 00 00       	call   80104b22 <initlock>
  initlock(&input.lock, "input");
80100ab2:	c7 44 24 04 fb 81 10 	movl   $0x801081fb,0x4(%esp)
80100ab9:	80 
80100aba:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100ac1:	e8 5c 40 00 00       	call   80104b22 <initlock>

  devsw[CONSOLE].write = consolewrite;
80100ac6:	c7 05 0c e8 10 80 2f 	movl   $0x80100a2f,0x8010e80c
80100acd:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100ad0:	c7 05 08 e8 10 80 2e 	movl   $0x8010092e,0x8010e808
80100ad7:	09 10 80 
  cons.locking = 1;
80100ada:	c7 05 f4 b5 10 80 01 	movl   $0x1,0x8010b5f4
80100ae1:	00 00 00 

  picenable(IRQ_KBD);
80100ae4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100aeb:	e8 15 30 00 00       	call   80103b05 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100af0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100af7:	00 
80100af8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100aff:	e8 b6 1e 00 00       	call   801029ba <ioapicenable>
}
80100b04:	c9                   	leave  
80100b05:	c3                   	ret    
80100b06:	66 90                	xchg   %ax,%ax

80100b08 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b08:	55                   	push   %ebp
80100b09:	89 e5                	mov    %esp,%ebp
80100b0b:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  if((ip = namei(path)) == 0)
80100b11:	8b 45 08             	mov    0x8(%ebp),%eax
80100b14:	89 04 24             	mov    %eax,(%esp)
80100b17:	e8 31 19 00 00       	call   8010244d <namei>
80100b1c:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b1f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b23:	75 0a                	jne    80100b2f <exec+0x27>
    return -1;
80100b25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b2a:	e9 ef 03 00 00       	jmp    80100f1e <exec+0x416>
  ilock(ip);
80100b2f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b32:	89 04 24             	mov    %eax,(%esp)
80100b35:	e8 52 0d 00 00       	call   8010188c <ilock>
  pgdir = 0;
80100b3a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b41:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100b48:	00 
80100b49:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100b50:	00 
80100b51:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100b57:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b5b:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b5e:	89 04 24             	mov    %eax,(%esp)
80100b61:	e8 33 12 00 00       	call   80101d99 <readi>
80100b66:	83 f8 33             	cmp    $0x33,%eax
80100b69:	0f 86 69 03 00 00    	jbe    80100ed8 <exec+0x3d0>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100b6f:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100b75:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100b7a:	0f 85 5b 03 00 00    	jne    80100edb <exec+0x3d3>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100b80:	e8 32 6d 00 00       	call   801078b7 <setupkvm>
80100b85:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100b88:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100b8c:	0f 84 4c 03 00 00    	je     80100ede <exec+0x3d6>
    goto bad;

  // Load program into memory.
  sz = 0;
80100b92:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100b99:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100ba0:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100ba6:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100ba9:	e9 c5 00 00 00       	jmp    80100c73 <exec+0x16b>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100bae:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100bb1:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100bb8:	00 
80100bb9:	89 44 24 08          	mov    %eax,0x8(%esp)
80100bbd:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100bc3:	89 44 24 04          	mov    %eax,0x4(%esp)
80100bc7:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100bca:	89 04 24             	mov    %eax,(%esp)
80100bcd:	e8 c7 11 00 00       	call   80101d99 <readi>
80100bd2:	83 f8 20             	cmp    $0x20,%eax
80100bd5:	0f 85 06 03 00 00    	jne    80100ee1 <exec+0x3d9>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100bdb:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100be1:	83 f8 01             	cmp    $0x1,%eax
80100be4:	75 7f                	jne    80100c65 <exec+0x15d>
      continue;
    if(ph.memsz < ph.filesz)
80100be6:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100bec:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100bf2:	39 c2                	cmp    %eax,%edx
80100bf4:	0f 82 ea 02 00 00    	jb     80100ee4 <exec+0x3dc>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100bfa:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c00:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c06:	01 d0                	add    %edx,%eax
80100c08:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c0f:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c13:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c16:	89 04 24             	mov    %eax,(%esp)
80100c19:	e8 6b 70 00 00       	call   80107c89 <allocuvm>
80100c1e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c21:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c25:	0f 84 bc 02 00 00    	je     80100ee7 <exec+0x3df>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c2b:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100c31:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c37:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100c3d:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100c41:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100c45:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100c48:	89 54 24 08          	mov    %edx,0x8(%esp)
80100c4c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c50:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c53:	89 04 24             	mov    %eax,(%esp)
80100c56:	e8 3f 6f 00 00       	call   80107b9a <loaduvm>
80100c5b:	85 c0                	test   %eax,%eax
80100c5d:	0f 88 87 02 00 00    	js     80100eea <exec+0x3e2>
80100c63:	eb 01                	jmp    80100c66 <exec+0x15e>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100c65:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c66:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100c6a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c6d:	83 c0 20             	add    $0x20,%eax
80100c70:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c73:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100c7a:	0f b7 c0             	movzwl %ax,%eax
80100c7d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100c80:	0f 8f 28 ff ff ff    	jg     80100bae <exec+0xa6>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100c86:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c89:	89 04 24             	mov    %eax,(%esp)
80100c8c:	e8 7f 0e 00 00       	call   80101b10 <iunlockput>
  ip = 0;
80100c91:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100c98:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c9b:	05 ff 0f 00 00       	add    $0xfff,%eax
80100ca0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100ca5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100ca8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cab:	05 00 20 00 00       	add    $0x2000,%eax
80100cb0:	89 44 24 08          	mov    %eax,0x8(%esp)
80100cb4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cb7:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cbb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cbe:	89 04 24             	mov    %eax,(%esp)
80100cc1:	e8 c3 6f 00 00       	call   80107c89 <allocuvm>
80100cc6:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cc9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100ccd:	0f 84 1a 02 00 00    	je     80100eed <exec+0x3e5>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100cd3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cd6:	2d 00 20 00 00       	sub    $0x2000,%eax
80100cdb:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cdf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100ce2:	89 04 24             	mov    %eax,(%esp)
80100ce5:	e8 cf 71 00 00       	call   80107eb9 <clearpteu>
  sp = sz;
80100cea:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ced:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100cf0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100cf7:	e9 97 00 00 00       	jmp    80100d93 <exec+0x28b>
    if(argc >= MAXARG)
80100cfc:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d00:	0f 87 ea 01 00 00    	ja     80100ef0 <exec+0x3e8>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d09:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d10:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d13:	01 d0                	add    %edx,%eax
80100d15:	8b 00                	mov    (%eax),%eax
80100d17:	89 04 24             	mov    %eax,(%esp)
80100d1a:	e8 fd 42 00 00       	call   8010501c <strlen>
80100d1f:	f7 d0                	not    %eax
80100d21:	89 c2                	mov    %eax,%edx
80100d23:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d26:	01 d0                	add    %edx,%eax
80100d28:	83 e0 fc             	and    $0xfffffffc,%eax
80100d2b:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d31:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d38:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d3b:	01 d0                	add    %edx,%eax
80100d3d:	8b 00                	mov    (%eax),%eax
80100d3f:	89 04 24             	mov    %eax,(%esp)
80100d42:	e8 d5 42 00 00       	call   8010501c <strlen>
80100d47:	83 c0 01             	add    $0x1,%eax
80100d4a:	89 c2                	mov    %eax,%edx
80100d4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d4f:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100d56:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d59:	01 c8                	add    %ecx,%eax
80100d5b:	8b 00                	mov    (%eax),%eax
80100d5d:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100d61:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d65:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d68:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d6c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d6f:	89 04 24             	mov    %eax,(%esp)
80100d72:	e8 85 73 00 00       	call   801080fc <copyout>
80100d77:	85 c0                	test   %eax,%eax
80100d79:	0f 88 74 01 00 00    	js     80100ef3 <exec+0x3eb>
      goto bad;
    ustack[3+argc] = sp;
80100d7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d82:	8d 50 03             	lea    0x3(%eax),%edx
80100d85:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d88:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d8f:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100d93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d96:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d9d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100da0:	01 d0                	add    %edx,%eax
80100da2:	8b 00                	mov    (%eax),%eax
80100da4:	85 c0                	test   %eax,%eax
80100da6:	0f 85 50 ff ff ff    	jne    80100cfc <exec+0x1f4>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100dac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100daf:	83 c0 03             	add    $0x3,%eax
80100db2:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100db9:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100dbd:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100dc4:	ff ff ff 
  ustack[1] = argc;
80100dc7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dca:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100dd0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dd3:	83 c0 01             	add    $0x1,%eax
80100dd6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ddd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100de0:	29 d0                	sub    %edx,%eax
80100de2:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100de8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100deb:	83 c0 04             	add    $0x4,%eax
80100dee:	c1 e0 02             	shl    $0x2,%eax
80100df1:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100df4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100df7:	83 c0 04             	add    $0x4,%eax
80100dfa:	c1 e0 02             	shl    $0x2,%eax
80100dfd:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100e01:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e07:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e0b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e0e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e12:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e15:	89 04 24             	mov    %eax,(%esp)
80100e18:	e8 df 72 00 00       	call   801080fc <copyout>
80100e1d:	85 c0                	test   %eax,%eax
80100e1f:	0f 88 d1 00 00 00    	js     80100ef6 <exec+0x3ee>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e25:	8b 45 08             	mov    0x8(%ebp),%eax
80100e28:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e31:	eb 17                	jmp    80100e4a <exec+0x342>
    if(*s == '/')
80100e33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e36:	0f b6 00             	movzbl (%eax),%eax
80100e39:	3c 2f                	cmp    $0x2f,%al
80100e3b:	75 09                	jne    80100e46 <exec+0x33e>
      last = s+1;
80100e3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e40:	83 c0 01             	add    $0x1,%eax
80100e43:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e46:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e4d:	0f b6 00             	movzbl (%eax),%eax
80100e50:	84 c0                	test   %al,%al
80100e52:	75 df                	jne    80100e33 <exec+0x32b>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e54:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e5a:	8d 50 6c             	lea    0x6c(%eax),%edx
80100e5d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100e64:	00 
80100e65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100e68:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e6c:	89 14 24             	mov    %edx,(%esp)
80100e6f:	e8 5a 41 00 00       	call   80104fce <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100e74:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e7a:	8b 40 04             	mov    0x4(%eax),%eax
80100e7d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100e80:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e86:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100e89:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100e8c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e92:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100e95:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100e97:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e9d:	8b 40 18             	mov    0x18(%eax),%eax
80100ea0:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100ea6:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100ea9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eaf:	8b 40 18             	mov    0x18(%eax),%eax
80100eb2:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100eb5:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100eb8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ebe:	89 04 24             	mov    %eax,(%esp)
80100ec1:	e8 e2 6a 00 00       	call   801079a8 <switchuvm>
  freevm(oldpgdir);
80100ec6:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ec9:	89 04 24             	mov    %eax,(%esp)
80100ecc:	e8 4e 6f 00 00       	call   80107e1f <freevm>
  return 0;
80100ed1:	b8 00 00 00 00       	mov    $0x0,%eax
80100ed6:	eb 46                	jmp    80100f1e <exec+0x416>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80100ed8:	90                   	nop
80100ed9:	eb 1c                	jmp    80100ef7 <exec+0x3ef>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100edb:	90                   	nop
80100edc:	eb 19                	jmp    80100ef7 <exec+0x3ef>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100ede:	90                   	nop
80100edf:	eb 16                	jmp    80100ef7 <exec+0x3ef>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100ee1:	90                   	nop
80100ee2:	eb 13                	jmp    80100ef7 <exec+0x3ef>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100ee4:	90                   	nop
80100ee5:	eb 10                	jmp    80100ef7 <exec+0x3ef>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100ee7:	90                   	nop
80100ee8:	eb 0d                	jmp    80100ef7 <exec+0x3ef>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100eea:	90                   	nop
80100eeb:	eb 0a                	jmp    80100ef7 <exec+0x3ef>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80100eed:	90                   	nop
80100eee:	eb 07                	jmp    80100ef7 <exec+0x3ef>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100ef0:	90                   	nop
80100ef1:	eb 04                	jmp    80100ef7 <exec+0x3ef>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100ef3:	90                   	nop
80100ef4:	eb 01                	jmp    80100ef7 <exec+0x3ef>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100ef6:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100ef7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100efb:	74 0b                	je     80100f08 <exec+0x400>
    freevm(pgdir);
80100efd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f00:	89 04 24             	mov    %eax,(%esp)
80100f03:	e8 17 6f 00 00       	call   80107e1f <freevm>
  if(ip)
80100f08:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f0c:	74 0b                	je     80100f19 <exec+0x411>
    iunlockput(ip);
80100f0e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100f11:	89 04 24             	mov    %eax,(%esp)
80100f14:	e8 f7 0b 00 00       	call   80101b10 <iunlockput>
  return -1;
80100f19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f1e:	c9                   	leave  
80100f1f:	c3                   	ret    

80100f20 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f20:	55                   	push   %ebp
80100f21:	89 e5                	mov    %esp,%ebp
80100f23:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100f26:	c7 44 24 04 01 82 10 	movl   $0x80108201,0x4(%esp)
80100f2d:	80 
80100f2e:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100f35:	e8 e8 3b 00 00       	call   80104b22 <initlock>
}
80100f3a:	c9                   	leave  
80100f3b:	c3                   	ret    

80100f3c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f3c:	55                   	push   %ebp
80100f3d:	89 e5                	mov    %esp,%ebp
80100f3f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f42:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100f49:	e8 f5 3b 00 00       	call   80104b43 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f4e:	c7 45 f4 94 de 10 80 	movl   $0x8010de94,-0xc(%ebp)
80100f55:	eb 29                	jmp    80100f80 <filealloc+0x44>
    if(f->ref == 0){
80100f57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f5a:	8b 40 04             	mov    0x4(%eax),%eax
80100f5d:	85 c0                	test   %eax,%eax
80100f5f:	75 1b                	jne    80100f7c <filealloc+0x40>
      f->ref = 1;
80100f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f64:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100f6b:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100f72:	e8 2e 3c 00 00       	call   80104ba5 <release>
      return f;
80100f77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f7a:	eb 1e                	jmp    80100f9a <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f7c:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100f80:	81 7d f4 f4 e7 10 80 	cmpl   $0x8010e7f4,-0xc(%ebp)
80100f87:	72 ce                	jb     80100f57 <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100f89:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100f90:	e8 10 3c 00 00       	call   80104ba5 <release>
  return 0;
80100f95:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100f9a:	c9                   	leave  
80100f9b:	c3                   	ret    

80100f9c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100f9c:	55                   	push   %ebp
80100f9d:	89 e5                	mov    %esp,%ebp
80100f9f:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80100fa2:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100fa9:	e8 95 3b 00 00       	call   80104b43 <acquire>
  if(f->ref < 1)
80100fae:	8b 45 08             	mov    0x8(%ebp),%eax
80100fb1:	8b 40 04             	mov    0x4(%eax),%eax
80100fb4:	85 c0                	test   %eax,%eax
80100fb6:	7f 0c                	jg     80100fc4 <filedup+0x28>
    panic("filedup");
80100fb8:	c7 04 24 08 82 10 80 	movl   $0x80108208,(%esp)
80100fbf:	e8 82 f5 ff ff       	call   80100546 <panic>
  f->ref++;
80100fc4:	8b 45 08             	mov    0x8(%ebp),%eax
80100fc7:	8b 40 04             	mov    0x4(%eax),%eax
80100fca:	8d 50 01             	lea    0x1(%eax),%edx
80100fcd:	8b 45 08             	mov    0x8(%ebp),%eax
80100fd0:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100fd3:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100fda:	e8 c6 3b 00 00       	call   80104ba5 <release>
  return f;
80100fdf:	8b 45 08             	mov    0x8(%ebp),%eax
}
80100fe2:	c9                   	leave  
80100fe3:	c3                   	ret    

80100fe4 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100fe4:	55                   	push   %ebp
80100fe5:	89 e5                	mov    %esp,%ebp
80100fe7:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
80100fea:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100ff1:	e8 4d 3b 00 00       	call   80104b43 <acquire>
  if(f->ref < 1)
80100ff6:	8b 45 08             	mov    0x8(%ebp),%eax
80100ff9:	8b 40 04             	mov    0x4(%eax),%eax
80100ffc:	85 c0                	test   %eax,%eax
80100ffe:	7f 0c                	jg     8010100c <fileclose+0x28>
    panic("fileclose");
80101000:	c7 04 24 10 82 10 80 	movl   $0x80108210,(%esp)
80101007:	e8 3a f5 ff ff       	call   80100546 <panic>
  if(--f->ref > 0){
8010100c:	8b 45 08             	mov    0x8(%ebp),%eax
8010100f:	8b 40 04             	mov    0x4(%eax),%eax
80101012:	8d 50 ff             	lea    -0x1(%eax),%edx
80101015:	8b 45 08             	mov    0x8(%ebp),%eax
80101018:	89 50 04             	mov    %edx,0x4(%eax)
8010101b:	8b 45 08             	mov    0x8(%ebp),%eax
8010101e:	8b 40 04             	mov    0x4(%eax),%eax
80101021:	85 c0                	test   %eax,%eax
80101023:	7e 11                	jle    80101036 <fileclose+0x52>
    release(&ftable.lock);
80101025:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
8010102c:	e8 74 3b 00 00       	call   80104ba5 <release>
80101031:	e9 82 00 00 00       	jmp    801010b8 <fileclose+0xd4>
    return;
  }
  ff = *f;
80101036:	8b 45 08             	mov    0x8(%ebp),%eax
80101039:	8b 10                	mov    (%eax),%edx
8010103b:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010103e:	8b 50 04             	mov    0x4(%eax),%edx
80101041:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101044:	8b 50 08             	mov    0x8(%eax),%edx
80101047:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010104a:	8b 50 0c             	mov    0xc(%eax),%edx
8010104d:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101050:	8b 50 10             	mov    0x10(%eax),%edx
80101053:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101056:	8b 40 14             	mov    0x14(%eax),%eax
80101059:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010105c:	8b 45 08             	mov    0x8(%ebp),%eax
8010105f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101066:	8b 45 08             	mov    0x8(%ebp),%eax
80101069:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010106f:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80101076:	e8 2a 3b 00 00       	call   80104ba5 <release>
  
  if(ff.type == FD_PIPE)
8010107b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010107e:	83 f8 01             	cmp    $0x1,%eax
80101081:	75 18                	jne    8010109b <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
80101083:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101087:	0f be d0             	movsbl %al,%edx
8010108a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010108d:	89 54 24 04          	mov    %edx,0x4(%esp)
80101091:	89 04 24             	mov    %eax,(%esp)
80101094:	e8 26 2d 00 00       	call   80103dbf <pipeclose>
80101099:	eb 1d                	jmp    801010b8 <fileclose+0xd4>
  else if(ff.type == FD_INODE){
8010109b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010109e:	83 f8 02             	cmp    $0x2,%eax
801010a1:	75 15                	jne    801010b8 <fileclose+0xd4>
    begin_trans();
801010a3:	e8 c0 21 00 00       	call   80103268 <begin_trans>
    iput(ff.ip);
801010a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801010ab:	89 04 24             	mov    %eax,(%esp)
801010ae:	e8 8c 09 00 00       	call   80101a3f <iput>
    commit_trans();
801010b3:	e8 f9 21 00 00       	call   801032b1 <commit_trans>
  }
}
801010b8:	c9                   	leave  
801010b9:	c3                   	ret    

801010ba <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801010ba:	55                   	push   %ebp
801010bb:	89 e5                	mov    %esp,%ebp
801010bd:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801010c0:	8b 45 08             	mov    0x8(%ebp),%eax
801010c3:	8b 00                	mov    (%eax),%eax
801010c5:	83 f8 02             	cmp    $0x2,%eax
801010c8:	75 38                	jne    80101102 <filestat+0x48>
    ilock(f->ip);
801010ca:	8b 45 08             	mov    0x8(%ebp),%eax
801010cd:	8b 40 10             	mov    0x10(%eax),%eax
801010d0:	89 04 24             	mov    %eax,(%esp)
801010d3:	e8 b4 07 00 00       	call   8010188c <ilock>
    stati(f->ip, st);
801010d8:	8b 45 08             	mov    0x8(%ebp),%eax
801010db:	8b 40 10             	mov    0x10(%eax),%eax
801010de:	8b 55 0c             	mov    0xc(%ebp),%edx
801010e1:	89 54 24 04          	mov    %edx,0x4(%esp)
801010e5:	89 04 24             	mov    %eax,(%esp)
801010e8:	e8 67 0c 00 00       	call   80101d54 <stati>
    iunlock(f->ip);
801010ed:	8b 45 08             	mov    0x8(%ebp),%eax
801010f0:	8b 40 10             	mov    0x10(%eax),%eax
801010f3:	89 04 24             	mov    %eax,(%esp)
801010f6:	e8 df 08 00 00       	call   801019da <iunlock>
    return 0;
801010fb:	b8 00 00 00 00       	mov    $0x0,%eax
80101100:	eb 05                	jmp    80101107 <filestat+0x4d>
  }
  return -1;
80101102:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101107:	c9                   	leave  
80101108:	c3                   	ret    

80101109 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101109:	55                   	push   %ebp
8010110a:	89 e5                	mov    %esp,%ebp
8010110c:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
8010110f:	8b 45 08             	mov    0x8(%ebp),%eax
80101112:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101116:	84 c0                	test   %al,%al
80101118:	75 0a                	jne    80101124 <fileread+0x1b>
    return -1;
8010111a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010111f:	e9 9f 00 00 00       	jmp    801011c3 <fileread+0xba>
  if(f->type == FD_PIPE)
80101124:	8b 45 08             	mov    0x8(%ebp),%eax
80101127:	8b 00                	mov    (%eax),%eax
80101129:	83 f8 01             	cmp    $0x1,%eax
8010112c:	75 1e                	jne    8010114c <fileread+0x43>
    return piperead(f->pipe, addr, n);
8010112e:	8b 45 08             	mov    0x8(%ebp),%eax
80101131:	8b 40 0c             	mov    0xc(%eax),%eax
80101134:	8b 55 10             	mov    0x10(%ebp),%edx
80101137:	89 54 24 08          	mov    %edx,0x8(%esp)
8010113b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010113e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101142:	89 04 24             	mov    %eax,(%esp)
80101145:	e8 f9 2d 00 00       	call   80103f43 <piperead>
8010114a:	eb 77                	jmp    801011c3 <fileread+0xba>
  if(f->type == FD_INODE){
8010114c:	8b 45 08             	mov    0x8(%ebp),%eax
8010114f:	8b 00                	mov    (%eax),%eax
80101151:	83 f8 02             	cmp    $0x2,%eax
80101154:	75 61                	jne    801011b7 <fileread+0xae>
    ilock(f->ip);
80101156:	8b 45 08             	mov    0x8(%ebp),%eax
80101159:	8b 40 10             	mov    0x10(%eax),%eax
8010115c:	89 04 24             	mov    %eax,(%esp)
8010115f:	e8 28 07 00 00       	call   8010188c <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101164:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101167:	8b 45 08             	mov    0x8(%ebp),%eax
8010116a:	8b 50 14             	mov    0x14(%eax),%edx
8010116d:	8b 45 08             	mov    0x8(%ebp),%eax
80101170:	8b 40 10             	mov    0x10(%eax),%eax
80101173:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101177:	89 54 24 08          	mov    %edx,0x8(%esp)
8010117b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010117e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101182:	89 04 24             	mov    %eax,(%esp)
80101185:	e8 0f 0c 00 00       	call   80101d99 <readi>
8010118a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010118d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101191:	7e 11                	jle    801011a4 <fileread+0x9b>
      f->off += r;
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	8b 50 14             	mov    0x14(%eax),%edx
80101199:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010119c:	01 c2                	add    %eax,%edx
8010119e:	8b 45 08             	mov    0x8(%ebp),%eax
801011a1:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801011a4:	8b 45 08             	mov    0x8(%ebp),%eax
801011a7:	8b 40 10             	mov    0x10(%eax),%eax
801011aa:	89 04 24             	mov    %eax,(%esp)
801011ad:	e8 28 08 00 00       	call   801019da <iunlock>
    return r;
801011b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011b5:	eb 0c                	jmp    801011c3 <fileread+0xba>
  }
  panic("fileread");
801011b7:	c7 04 24 1a 82 10 80 	movl   $0x8010821a,(%esp)
801011be:	e8 83 f3 ff ff       	call   80100546 <panic>
}
801011c3:	c9                   	leave  
801011c4:	c3                   	ret    

801011c5 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801011c5:	55                   	push   %ebp
801011c6:	89 e5                	mov    %esp,%ebp
801011c8:	53                   	push   %ebx
801011c9:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801011cc:	8b 45 08             	mov    0x8(%ebp),%eax
801011cf:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801011d3:	84 c0                	test   %al,%al
801011d5:	75 0a                	jne    801011e1 <filewrite+0x1c>
    return -1;
801011d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011dc:	e9 23 01 00 00       	jmp    80101304 <filewrite+0x13f>
  if(f->type == FD_PIPE)
801011e1:	8b 45 08             	mov    0x8(%ebp),%eax
801011e4:	8b 00                	mov    (%eax),%eax
801011e6:	83 f8 01             	cmp    $0x1,%eax
801011e9:	75 21                	jne    8010120c <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801011eb:	8b 45 08             	mov    0x8(%ebp),%eax
801011ee:	8b 40 0c             	mov    0xc(%eax),%eax
801011f1:	8b 55 10             	mov    0x10(%ebp),%edx
801011f4:	89 54 24 08          	mov    %edx,0x8(%esp)
801011f8:	8b 55 0c             	mov    0xc(%ebp),%edx
801011fb:	89 54 24 04          	mov    %edx,0x4(%esp)
801011ff:	89 04 24             	mov    %eax,(%esp)
80101202:	e8 4a 2c 00 00       	call   80103e51 <pipewrite>
80101207:	e9 f8 00 00 00       	jmp    80101304 <filewrite+0x13f>
  if(f->type == FD_INODE){
8010120c:	8b 45 08             	mov    0x8(%ebp),%eax
8010120f:	8b 00                	mov    (%eax),%eax
80101211:	83 f8 02             	cmp    $0x2,%eax
80101214:	0f 85 de 00 00 00    	jne    801012f8 <filewrite+0x133>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
8010121a:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
80101221:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101228:	e9 a8 00 00 00       	jmp    801012d5 <filewrite+0x110>
      int n1 = n - i;
8010122d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101230:	8b 55 10             	mov    0x10(%ebp),%edx
80101233:	89 d1                	mov    %edx,%ecx
80101235:	29 c1                	sub    %eax,%ecx
80101237:	89 c8                	mov    %ecx,%eax
80101239:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
8010123c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010123f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101242:	7e 06                	jle    8010124a <filewrite+0x85>
        n1 = max;
80101244:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101247:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_trans();
8010124a:	e8 19 20 00 00       	call   80103268 <begin_trans>
      ilock(f->ip);
8010124f:	8b 45 08             	mov    0x8(%ebp),%eax
80101252:	8b 40 10             	mov    0x10(%eax),%eax
80101255:	89 04 24             	mov    %eax,(%esp)
80101258:	e8 2f 06 00 00       	call   8010188c <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010125d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101260:	8b 45 08             	mov    0x8(%ebp),%eax
80101263:	8b 50 14             	mov    0x14(%eax),%edx
80101266:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101269:	8b 45 0c             	mov    0xc(%ebp),%eax
8010126c:	01 c3                	add    %eax,%ebx
8010126e:	8b 45 08             	mov    0x8(%ebp),%eax
80101271:	8b 40 10             	mov    0x10(%eax),%eax
80101274:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101278:	89 54 24 08          	mov    %edx,0x8(%esp)
8010127c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101280:	89 04 24             	mov    %eax,(%esp)
80101283:	e8 7f 0c 00 00       	call   80101f07 <writei>
80101288:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010128b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010128f:	7e 11                	jle    801012a2 <filewrite+0xdd>
        f->off += r;
80101291:	8b 45 08             	mov    0x8(%ebp),%eax
80101294:	8b 50 14             	mov    0x14(%eax),%edx
80101297:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010129a:	01 c2                	add    %eax,%edx
8010129c:	8b 45 08             	mov    0x8(%ebp),%eax
8010129f:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801012a2:	8b 45 08             	mov    0x8(%ebp),%eax
801012a5:	8b 40 10             	mov    0x10(%eax),%eax
801012a8:	89 04 24             	mov    %eax,(%esp)
801012ab:	e8 2a 07 00 00       	call   801019da <iunlock>
      commit_trans();
801012b0:	e8 fc 1f 00 00       	call   801032b1 <commit_trans>

      if(r < 0)
801012b5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012b9:	78 28                	js     801012e3 <filewrite+0x11e>
        break;
      if(r != n1)
801012bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012be:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801012c1:	74 0c                	je     801012cf <filewrite+0x10a>
        panic("short filewrite");
801012c3:	c7 04 24 23 82 10 80 	movl   $0x80108223,(%esp)
801012ca:	e8 77 f2 ff ff       	call   80100546 <panic>
      i += r;
801012cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012d2:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801012d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012d8:	3b 45 10             	cmp    0x10(%ebp),%eax
801012db:	0f 8c 4c ff ff ff    	jl     8010122d <filewrite+0x68>
801012e1:	eb 01                	jmp    801012e4 <filewrite+0x11f>
        f->off += r;
      iunlock(f->ip);
      commit_trans();

      if(r < 0)
        break;
801012e3:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801012e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012e7:	3b 45 10             	cmp    0x10(%ebp),%eax
801012ea:	75 05                	jne    801012f1 <filewrite+0x12c>
801012ec:	8b 45 10             	mov    0x10(%ebp),%eax
801012ef:	eb 05                	jmp    801012f6 <filewrite+0x131>
801012f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012f6:	eb 0c                	jmp    80101304 <filewrite+0x13f>
  }
  panic("filewrite");
801012f8:	c7 04 24 33 82 10 80 	movl   $0x80108233,(%esp)
801012ff:	e8 42 f2 ff ff       	call   80100546 <panic>
}
80101304:	83 c4 24             	add    $0x24,%esp
80101307:	5b                   	pop    %ebx
80101308:	5d                   	pop    %ebp
80101309:	c3                   	ret    
8010130a:	66 90                	xchg   %ax,%ax

8010130c <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
8010130c:	55                   	push   %ebp
8010130d:	89 e5                	mov    %esp,%ebp
8010130f:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
80101312:	8b 45 08             	mov    0x8(%ebp),%eax
80101315:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010131c:	00 
8010131d:	89 04 24             	mov    %eax,(%esp)
80101320:	e8 81 ee ff ff       	call   801001a6 <bread>
80101325:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101328:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010132b:	83 c0 18             	add    $0x18,%eax
8010132e:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80101335:	00 
80101336:	89 44 24 04          	mov    %eax,0x4(%esp)
8010133a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010133d:	89 04 24             	mov    %eax,(%esp)
80101340:	e8 2c 3b 00 00       	call   80104e71 <memmove>
  brelse(bp);
80101345:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101348:	89 04 24             	mov    %eax,(%esp)
8010134b:	e8 c7 ee ff ff       	call   80100217 <brelse>
}
80101350:	c9                   	leave  
80101351:	c3                   	ret    

80101352 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101352:	55                   	push   %ebp
80101353:	89 e5                	mov    %esp,%ebp
80101355:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101358:	8b 55 0c             	mov    0xc(%ebp),%edx
8010135b:	8b 45 08             	mov    0x8(%ebp),%eax
8010135e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101362:	89 04 24             	mov    %eax,(%esp)
80101365:	e8 3c ee ff ff       	call   801001a6 <bread>
8010136a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010136d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101370:	83 c0 18             	add    $0x18,%eax
80101373:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010137a:	00 
8010137b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101382:	00 
80101383:	89 04 24             	mov    %eax,(%esp)
80101386:	e8 13 3a 00 00       	call   80104d9e <memset>
  log_write(bp);
8010138b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010138e:	89 04 24             	mov    %eax,(%esp)
80101391:	e8 73 1f 00 00       	call   80103309 <log_write>
  brelse(bp);
80101396:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101399:	89 04 24             	mov    %eax,(%esp)
8010139c:	e8 76 ee ff ff       	call   80100217 <brelse>
}
801013a1:	c9                   	leave  
801013a2:	c3                   	ret    

801013a3 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801013a3:	55                   	push   %ebp
801013a4:	89 e5                	mov    %esp,%ebp
801013a6:	53                   	push   %ebx
801013a7:	83 ec 34             	sub    $0x34,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
801013aa:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
801013b1:	8b 45 08             	mov    0x8(%ebp),%eax
801013b4:	8d 55 d8             	lea    -0x28(%ebp),%edx
801013b7:	89 54 24 04          	mov    %edx,0x4(%esp)
801013bb:	89 04 24             	mov    %eax,(%esp)
801013be:	e8 49 ff ff ff       	call   8010130c <readsb>
  for(b = 0; b < sb.size; b += BPB){
801013c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801013ca:	e9 0d 01 00 00       	jmp    801014dc <balloc+0x139>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
801013cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013d2:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801013d8:	85 c0                	test   %eax,%eax
801013da:	0f 48 c2             	cmovs  %edx,%eax
801013dd:	c1 f8 0c             	sar    $0xc,%eax
801013e0:	8b 55 e0             	mov    -0x20(%ebp),%edx
801013e3:	c1 ea 03             	shr    $0x3,%edx
801013e6:	01 d0                	add    %edx,%eax
801013e8:	83 c0 03             	add    $0x3,%eax
801013eb:	89 44 24 04          	mov    %eax,0x4(%esp)
801013ef:	8b 45 08             	mov    0x8(%ebp),%eax
801013f2:	89 04 24             	mov    %eax,(%esp)
801013f5:	e8 ac ed ff ff       	call   801001a6 <bread>
801013fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801013fd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101404:	e9 a3 00 00 00       	jmp    801014ac <balloc+0x109>
      m = 1 << (bi % 8);
80101409:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010140c:	89 c2                	mov    %eax,%edx
8010140e:	c1 fa 1f             	sar    $0x1f,%edx
80101411:	c1 ea 1d             	shr    $0x1d,%edx
80101414:	01 d0                	add    %edx,%eax
80101416:	83 e0 07             	and    $0x7,%eax
80101419:	29 d0                	sub    %edx,%eax
8010141b:	ba 01 00 00 00       	mov    $0x1,%edx
80101420:	89 d3                	mov    %edx,%ebx
80101422:	89 c1                	mov    %eax,%ecx
80101424:	d3 e3                	shl    %cl,%ebx
80101426:	89 d8                	mov    %ebx,%eax
80101428:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010142b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010142e:	8d 50 07             	lea    0x7(%eax),%edx
80101431:	85 c0                	test   %eax,%eax
80101433:	0f 48 c2             	cmovs  %edx,%eax
80101436:	c1 f8 03             	sar    $0x3,%eax
80101439:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010143c:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101441:	0f b6 c0             	movzbl %al,%eax
80101444:	23 45 e8             	and    -0x18(%ebp),%eax
80101447:	85 c0                	test   %eax,%eax
80101449:	75 5d                	jne    801014a8 <balloc+0x105>
        bp->data[bi/8] |= m;  // Mark block in use.
8010144b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010144e:	8d 50 07             	lea    0x7(%eax),%edx
80101451:	85 c0                	test   %eax,%eax
80101453:	0f 48 c2             	cmovs  %edx,%eax
80101456:	c1 f8 03             	sar    $0x3,%eax
80101459:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010145c:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101461:	89 d1                	mov    %edx,%ecx
80101463:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101466:	09 ca                	or     %ecx,%edx
80101468:	89 d1                	mov    %edx,%ecx
8010146a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010146d:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
80101471:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101474:	89 04 24             	mov    %eax,(%esp)
80101477:	e8 8d 1e 00 00       	call   80103309 <log_write>
        brelse(bp);
8010147c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010147f:	89 04 24             	mov    %eax,(%esp)
80101482:	e8 90 ed ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
80101487:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010148a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010148d:	01 c2                	add    %eax,%edx
8010148f:	8b 45 08             	mov    0x8(%ebp),%eax
80101492:	89 54 24 04          	mov    %edx,0x4(%esp)
80101496:	89 04 24             	mov    %eax,(%esp)
80101499:	e8 b4 fe ff ff       	call   80101352 <bzero>
        return b + bi;
8010149e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014a4:	01 d0                	add    %edx,%eax
801014a6:	eb 4e                	jmp    801014f6 <balloc+0x153>

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014a8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801014ac:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801014b3:	7f 15                	jg     801014ca <balloc+0x127>
801014b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014bb:	01 d0                	add    %edx,%eax
801014bd:	89 c2                	mov    %eax,%edx
801014bf:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014c2:	39 c2                	cmp    %eax,%edx
801014c4:	0f 82 3f ff ff ff    	jb     80101409 <balloc+0x66>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801014ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014cd:	89 04 24             	mov    %eax,(%esp)
801014d0:	e8 42 ed ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
801014d5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801014dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014df:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014e2:	39 c2                	cmp    %eax,%edx
801014e4:	0f 82 e5 fe ff ff    	jb     801013cf <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801014ea:	c7 04 24 3d 82 10 80 	movl   $0x8010823d,(%esp)
801014f1:	e8 50 f0 ff ff       	call   80100546 <panic>
}
801014f6:	83 c4 34             	add    $0x34,%esp
801014f9:	5b                   	pop    %ebx
801014fa:	5d                   	pop    %ebp
801014fb:	c3                   	ret    

801014fc <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801014fc:	55                   	push   %ebp
801014fd:	89 e5                	mov    %esp,%ebp
801014ff:	53                   	push   %ebx
80101500:	83 ec 34             	sub    $0x34,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
80101503:	8d 45 dc             	lea    -0x24(%ebp),%eax
80101506:	89 44 24 04          	mov    %eax,0x4(%esp)
8010150a:	8b 45 08             	mov    0x8(%ebp),%eax
8010150d:	89 04 24             	mov    %eax,(%esp)
80101510:	e8 f7 fd ff ff       	call   8010130c <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
80101515:	8b 45 0c             	mov    0xc(%ebp),%eax
80101518:	89 c2                	mov    %eax,%edx
8010151a:	c1 ea 0c             	shr    $0xc,%edx
8010151d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101520:	c1 e8 03             	shr    $0x3,%eax
80101523:	01 d0                	add    %edx,%eax
80101525:	8d 50 03             	lea    0x3(%eax),%edx
80101528:	8b 45 08             	mov    0x8(%ebp),%eax
8010152b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010152f:	89 04 24             	mov    %eax,(%esp)
80101532:	e8 6f ec ff ff       	call   801001a6 <bread>
80101537:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
8010153a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010153d:	25 ff 0f 00 00       	and    $0xfff,%eax
80101542:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101545:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101548:	89 c2                	mov    %eax,%edx
8010154a:	c1 fa 1f             	sar    $0x1f,%edx
8010154d:	c1 ea 1d             	shr    $0x1d,%edx
80101550:	01 d0                	add    %edx,%eax
80101552:	83 e0 07             	and    $0x7,%eax
80101555:	29 d0                	sub    %edx,%eax
80101557:	ba 01 00 00 00       	mov    $0x1,%edx
8010155c:	89 d3                	mov    %edx,%ebx
8010155e:	89 c1                	mov    %eax,%ecx
80101560:	d3 e3                	shl    %cl,%ebx
80101562:	89 d8                	mov    %ebx,%eax
80101564:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101567:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010156a:	8d 50 07             	lea    0x7(%eax),%edx
8010156d:	85 c0                	test   %eax,%eax
8010156f:	0f 48 c2             	cmovs  %edx,%eax
80101572:	c1 f8 03             	sar    $0x3,%eax
80101575:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101578:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
8010157d:	0f b6 c0             	movzbl %al,%eax
80101580:	23 45 ec             	and    -0x14(%ebp),%eax
80101583:	85 c0                	test   %eax,%eax
80101585:	75 0c                	jne    80101593 <bfree+0x97>
    panic("freeing free block");
80101587:	c7 04 24 53 82 10 80 	movl   $0x80108253,(%esp)
8010158e:	e8 b3 ef ff ff       	call   80100546 <panic>
  bp->data[bi/8] &= ~m;
80101593:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101596:	8d 50 07             	lea    0x7(%eax),%edx
80101599:	85 c0                	test   %eax,%eax
8010159b:	0f 48 c2             	cmovs  %edx,%eax
8010159e:	c1 f8 03             	sar    $0x3,%eax
801015a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015a4:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801015a9:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801015ac:	f7 d1                	not    %ecx
801015ae:	21 ca                	and    %ecx,%edx
801015b0:	89 d1                	mov    %edx,%ecx
801015b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015b5:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
801015b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015bc:	89 04 24             	mov    %eax,(%esp)
801015bf:	e8 45 1d 00 00       	call   80103309 <log_write>
  brelse(bp);
801015c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015c7:	89 04 24             	mov    %eax,(%esp)
801015ca:	e8 48 ec ff ff       	call   80100217 <brelse>
}
801015cf:	83 c4 34             	add    $0x34,%esp
801015d2:	5b                   	pop    %ebx
801015d3:	5d                   	pop    %ebp
801015d4:	c3                   	ret    

801015d5 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
801015d5:	55                   	push   %ebp
801015d6:	89 e5                	mov    %esp,%ebp
801015d8:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
801015db:	c7 44 24 04 66 82 10 	movl   $0x80108266,0x4(%esp)
801015e2:	80 
801015e3:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
801015ea:	e8 33 35 00 00       	call   80104b22 <initlock>
}
801015ef:	c9                   	leave  
801015f0:	c3                   	ret    

801015f1 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801015f1:	55                   	push   %ebp
801015f2:	89 e5                	mov    %esp,%ebp
801015f4:	83 ec 48             	sub    $0x48,%esp
801015f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801015fa:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
801015fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101601:	8d 55 dc             	lea    -0x24(%ebp),%edx
80101604:	89 54 24 04          	mov    %edx,0x4(%esp)
80101608:	89 04 24             	mov    %eax,(%esp)
8010160b:	e8 fc fc ff ff       	call   8010130c <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
80101610:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101617:	e9 98 00 00 00       	jmp    801016b4 <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
8010161c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010161f:	c1 e8 03             	shr    $0x3,%eax
80101622:	83 c0 02             	add    $0x2,%eax
80101625:	89 44 24 04          	mov    %eax,0x4(%esp)
80101629:	8b 45 08             	mov    0x8(%ebp),%eax
8010162c:	89 04 24             	mov    %eax,(%esp)
8010162f:	e8 72 eb ff ff       	call   801001a6 <bread>
80101634:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101637:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010163a:	8d 50 18             	lea    0x18(%eax),%edx
8010163d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101640:	83 e0 07             	and    $0x7,%eax
80101643:	c1 e0 06             	shl    $0x6,%eax
80101646:	01 d0                	add    %edx,%eax
80101648:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010164b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010164e:	0f b7 00             	movzwl (%eax),%eax
80101651:	66 85 c0             	test   %ax,%ax
80101654:	75 4f                	jne    801016a5 <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
80101656:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
8010165d:	00 
8010165e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101665:	00 
80101666:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101669:	89 04 24             	mov    %eax,(%esp)
8010166c:	e8 2d 37 00 00       	call   80104d9e <memset>
      dip->type = type;
80101671:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101674:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
80101678:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
8010167b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010167e:	89 04 24             	mov    %eax,(%esp)
80101681:	e8 83 1c 00 00       	call   80103309 <log_write>
      brelse(bp);
80101686:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101689:	89 04 24             	mov    %eax,(%esp)
8010168c:	e8 86 eb ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
80101691:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101694:	89 44 24 04          	mov    %eax,0x4(%esp)
80101698:	8b 45 08             	mov    0x8(%ebp),%eax
8010169b:	89 04 24             	mov    %eax,(%esp)
8010169e:	e8 e5 00 00 00       	call   80101788 <iget>
801016a3:	eb 29                	jmp    801016ce <ialloc+0xdd>
    }
    brelse(bp);
801016a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016a8:	89 04 24             	mov    %eax,(%esp)
801016ab:	e8 67 eb ff ff       	call   80100217 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
801016b0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801016b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801016ba:	39 c2                	cmp    %eax,%edx
801016bc:	0f 82 5a ff ff ff    	jb     8010161c <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
801016c2:	c7 04 24 6d 82 10 80 	movl   $0x8010826d,(%esp)
801016c9:	e8 78 ee ff ff       	call   80100546 <panic>
}
801016ce:	c9                   	leave  
801016cf:	c3                   	ret    

801016d0 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
801016d0:	55                   	push   %ebp
801016d1:	89 e5                	mov    %esp,%ebp
801016d3:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
801016d6:	8b 45 08             	mov    0x8(%ebp),%eax
801016d9:	8b 40 04             	mov    0x4(%eax),%eax
801016dc:	c1 e8 03             	shr    $0x3,%eax
801016df:	8d 50 02             	lea    0x2(%eax),%edx
801016e2:	8b 45 08             	mov    0x8(%ebp),%eax
801016e5:	8b 00                	mov    (%eax),%eax
801016e7:	89 54 24 04          	mov    %edx,0x4(%esp)
801016eb:	89 04 24             	mov    %eax,(%esp)
801016ee:	e8 b3 ea ff ff       	call   801001a6 <bread>
801016f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801016f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016f9:	8d 50 18             	lea    0x18(%eax),%edx
801016fc:	8b 45 08             	mov    0x8(%ebp),%eax
801016ff:	8b 40 04             	mov    0x4(%eax),%eax
80101702:	83 e0 07             	and    $0x7,%eax
80101705:	c1 e0 06             	shl    $0x6,%eax
80101708:	01 d0                	add    %edx,%eax
8010170a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
8010170d:	8b 45 08             	mov    0x8(%ebp),%eax
80101710:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101714:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101717:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010171a:	8b 45 08             	mov    0x8(%ebp),%eax
8010171d:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101721:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101724:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101728:	8b 45 08             	mov    0x8(%ebp),%eax
8010172b:	0f b7 50 14          	movzwl 0x14(%eax),%edx
8010172f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101732:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101736:	8b 45 08             	mov    0x8(%ebp),%eax
80101739:	0f b7 50 16          	movzwl 0x16(%eax),%edx
8010173d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101740:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101744:	8b 45 08             	mov    0x8(%ebp),%eax
80101747:	8b 50 18             	mov    0x18(%eax),%edx
8010174a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010174d:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101750:	8b 45 08             	mov    0x8(%ebp),%eax
80101753:	8d 50 1c             	lea    0x1c(%eax),%edx
80101756:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101759:	83 c0 0c             	add    $0xc,%eax
8010175c:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101763:	00 
80101764:	89 54 24 04          	mov    %edx,0x4(%esp)
80101768:	89 04 24             	mov    %eax,(%esp)
8010176b:	e8 01 37 00 00       	call   80104e71 <memmove>
  log_write(bp);
80101770:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101773:	89 04 24             	mov    %eax,(%esp)
80101776:	e8 8e 1b 00 00       	call   80103309 <log_write>
  brelse(bp);
8010177b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010177e:	89 04 24             	mov    %eax,(%esp)
80101781:	e8 91 ea ff ff       	call   80100217 <brelse>
}
80101786:	c9                   	leave  
80101787:	c3                   	ret    

80101788 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101788:	55                   	push   %ebp
80101789:	89 e5                	mov    %esp,%ebp
8010178b:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
8010178e:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101795:	e8 a9 33 00 00       	call   80104b43 <acquire>

  // Is the inode already cached?
  empty = 0;
8010179a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801017a1:	c7 45 f4 94 e8 10 80 	movl   $0x8010e894,-0xc(%ebp)
801017a8:	eb 59                	jmp    80101803 <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801017aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ad:	8b 40 08             	mov    0x8(%eax),%eax
801017b0:	85 c0                	test   %eax,%eax
801017b2:	7e 35                	jle    801017e9 <iget+0x61>
801017b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017b7:	8b 00                	mov    (%eax),%eax
801017b9:	3b 45 08             	cmp    0x8(%ebp),%eax
801017bc:	75 2b                	jne    801017e9 <iget+0x61>
801017be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017c1:	8b 40 04             	mov    0x4(%eax),%eax
801017c4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801017c7:	75 20                	jne    801017e9 <iget+0x61>
      ip->ref++;
801017c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017cc:	8b 40 08             	mov    0x8(%eax),%eax
801017cf:	8d 50 01             	lea    0x1(%eax),%edx
801017d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017d5:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801017d8:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
801017df:	e8 c1 33 00 00       	call   80104ba5 <release>
      return ip;
801017e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017e7:	eb 6f                	jmp    80101858 <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801017e9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017ed:	75 10                	jne    801017ff <iget+0x77>
801017ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f2:	8b 40 08             	mov    0x8(%eax),%eax
801017f5:	85 c0                	test   %eax,%eax
801017f7:	75 06                	jne    801017ff <iget+0x77>
      empty = ip;
801017f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017fc:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801017ff:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101803:	81 7d f4 34 f8 10 80 	cmpl   $0x8010f834,-0xc(%ebp)
8010180a:	72 9e                	jb     801017aa <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010180c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101810:	75 0c                	jne    8010181e <iget+0x96>
    panic("iget: no inodes");
80101812:	c7 04 24 7f 82 10 80 	movl   $0x8010827f,(%esp)
80101819:	e8 28 ed ff ff       	call   80100546 <panic>

  ip = empty;
8010181e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101821:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101824:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101827:	8b 55 08             	mov    0x8(%ebp),%edx
8010182a:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
8010182c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010182f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101832:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101838:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
8010183f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101842:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101849:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101850:	e8 50 33 00 00       	call   80104ba5 <release>

  return ip;
80101855:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101858:	c9                   	leave  
80101859:	c3                   	ret    

8010185a <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
8010185a:	55                   	push   %ebp
8010185b:	89 e5                	mov    %esp,%ebp
8010185d:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101860:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101867:	e8 d7 32 00 00       	call   80104b43 <acquire>
  ip->ref++;
8010186c:	8b 45 08             	mov    0x8(%ebp),%eax
8010186f:	8b 40 08             	mov    0x8(%eax),%eax
80101872:	8d 50 01             	lea    0x1(%eax),%edx
80101875:	8b 45 08             	mov    0x8(%ebp),%eax
80101878:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
8010187b:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101882:	e8 1e 33 00 00       	call   80104ba5 <release>
  return ip;
80101887:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010188a:	c9                   	leave  
8010188b:	c3                   	ret    

8010188c <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
8010188c:	55                   	push   %ebp
8010188d:	89 e5                	mov    %esp,%ebp
8010188f:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101892:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101896:	74 0a                	je     801018a2 <ilock+0x16>
80101898:	8b 45 08             	mov    0x8(%ebp),%eax
8010189b:	8b 40 08             	mov    0x8(%eax),%eax
8010189e:	85 c0                	test   %eax,%eax
801018a0:	7f 0c                	jg     801018ae <ilock+0x22>
    panic("ilock");
801018a2:	c7 04 24 8f 82 10 80 	movl   $0x8010828f,(%esp)
801018a9:	e8 98 ec ff ff       	call   80100546 <panic>

  acquire(&icache.lock);
801018ae:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
801018b5:	e8 89 32 00 00       	call   80104b43 <acquire>
  while(ip->flags & I_BUSY)
801018ba:	eb 13                	jmp    801018cf <ilock+0x43>
    sleep(ip, &icache.lock);
801018bc:	c7 44 24 04 60 e8 10 	movl   $0x8010e860,0x4(%esp)
801018c3:	80 
801018c4:	8b 45 08             	mov    0x8(%ebp),%eax
801018c7:	89 04 24             	mov    %eax,(%esp)
801018ca:	e8 97 2f 00 00       	call   80104866 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
801018cf:	8b 45 08             	mov    0x8(%ebp),%eax
801018d2:	8b 40 0c             	mov    0xc(%eax),%eax
801018d5:	83 e0 01             	and    $0x1,%eax
801018d8:	85 c0                	test   %eax,%eax
801018da:	75 e0                	jne    801018bc <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
801018dc:	8b 45 08             	mov    0x8(%ebp),%eax
801018df:	8b 40 0c             	mov    0xc(%eax),%eax
801018e2:	89 c2                	mov    %eax,%edx
801018e4:	83 ca 01             	or     $0x1,%edx
801018e7:	8b 45 08             	mov    0x8(%ebp),%eax
801018ea:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801018ed:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
801018f4:	e8 ac 32 00 00       	call   80104ba5 <release>

  if(!(ip->flags & I_VALID)){
801018f9:	8b 45 08             	mov    0x8(%ebp),%eax
801018fc:	8b 40 0c             	mov    0xc(%eax),%eax
801018ff:	83 e0 02             	and    $0x2,%eax
80101902:	85 c0                	test   %eax,%eax
80101904:	0f 85 ce 00 00 00    	jne    801019d8 <ilock+0x14c>
    bp = bread(ip->dev, IBLOCK(ip->inum));
8010190a:	8b 45 08             	mov    0x8(%ebp),%eax
8010190d:	8b 40 04             	mov    0x4(%eax),%eax
80101910:	c1 e8 03             	shr    $0x3,%eax
80101913:	8d 50 02             	lea    0x2(%eax),%edx
80101916:	8b 45 08             	mov    0x8(%ebp),%eax
80101919:	8b 00                	mov    (%eax),%eax
8010191b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010191f:	89 04 24             	mov    %eax,(%esp)
80101922:	e8 7f e8 ff ff       	call   801001a6 <bread>
80101927:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
8010192a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010192d:	8d 50 18             	lea    0x18(%eax),%edx
80101930:	8b 45 08             	mov    0x8(%ebp),%eax
80101933:	8b 40 04             	mov    0x4(%eax),%eax
80101936:	83 e0 07             	and    $0x7,%eax
80101939:	c1 e0 06             	shl    $0x6,%eax
8010193c:	01 d0                	add    %edx,%eax
8010193e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101941:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101944:	0f b7 10             	movzwl (%eax),%edx
80101947:	8b 45 08             	mov    0x8(%ebp),%eax
8010194a:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
8010194e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101951:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101955:	8b 45 08             	mov    0x8(%ebp),%eax
80101958:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
8010195c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010195f:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101963:	8b 45 08             	mov    0x8(%ebp),%eax
80101966:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
8010196a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010196d:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101971:	8b 45 08             	mov    0x8(%ebp),%eax
80101974:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101978:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010197b:	8b 50 08             	mov    0x8(%eax),%edx
8010197e:	8b 45 08             	mov    0x8(%ebp),%eax
80101981:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101984:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101987:	8d 50 0c             	lea    0xc(%eax),%edx
8010198a:	8b 45 08             	mov    0x8(%ebp),%eax
8010198d:	83 c0 1c             	add    $0x1c,%eax
80101990:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101997:	00 
80101998:	89 54 24 04          	mov    %edx,0x4(%esp)
8010199c:	89 04 24             	mov    %eax,(%esp)
8010199f:	e8 cd 34 00 00       	call   80104e71 <memmove>
    brelse(bp);
801019a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a7:	89 04 24             	mov    %eax,(%esp)
801019aa:	e8 68 e8 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
801019af:	8b 45 08             	mov    0x8(%ebp),%eax
801019b2:	8b 40 0c             	mov    0xc(%eax),%eax
801019b5:	89 c2                	mov    %eax,%edx
801019b7:	83 ca 02             	or     $0x2,%edx
801019ba:	8b 45 08             	mov    0x8(%ebp),%eax
801019bd:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
801019c0:	8b 45 08             	mov    0x8(%ebp),%eax
801019c3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801019c7:	66 85 c0             	test   %ax,%ax
801019ca:	75 0c                	jne    801019d8 <ilock+0x14c>
      panic("ilock: no type");
801019cc:	c7 04 24 95 82 10 80 	movl   $0x80108295,(%esp)
801019d3:	e8 6e eb ff ff       	call   80100546 <panic>
  }
}
801019d8:	c9                   	leave  
801019d9:	c3                   	ret    

801019da <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
801019da:	55                   	push   %ebp
801019db:	89 e5                	mov    %esp,%ebp
801019dd:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
801019e0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019e4:	74 17                	je     801019fd <iunlock+0x23>
801019e6:	8b 45 08             	mov    0x8(%ebp),%eax
801019e9:	8b 40 0c             	mov    0xc(%eax),%eax
801019ec:	83 e0 01             	and    $0x1,%eax
801019ef:	85 c0                	test   %eax,%eax
801019f1:	74 0a                	je     801019fd <iunlock+0x23>
801019f3:	8b 45 08             	mov    0x8(%ebp),%eax
801019f6:	8b 40 08             	mov    0x8(%eax),%eax
801019f9:	85 c0                	test   %eax,%eax
801019fb:	7f 0c                	jg     80101a09 <iunlock+0x2f>
    panic("iunlock");
801019fd:	c7 04 24 a4 82 10 80 	movl   $0x801082a4,(%esp)
80101a04:	e8 3d eb ff ff       	call   80100546 <panic>

  acquire(&icache.lock);
80101a09:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101a10:	e8 2e 31 00 00       	call   80104b43 <acquire>
  ip->flags &= ~I_BUSY;
80101a15:	8b 45 08             	mov    0x8(%ebp),%eax
80101a18:	8b 40 0c             	mov    0xc(%eax),%eax
80101a1b:	89 c2                	mov    %eax,%edx
80101a1d:	83 e2 fe             	and    $0xfffffffe,%edx
80101a20:	8b 45 08             	mov    0x8(%ebp),%eax
80101a23:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101a26:	8b 45 08             	mov    0x8(%ebp),%eax
80101a29:	89 04 24             	mov    %eax,(%esp)
80101a2c:	e8 0e 2f 00 00       	call   8010493f <wakeup>
  release(&icache.lock);
80101a31:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101a38:	e8 68 31 00 00       	call   80104ba5 <release>
}
80101a3d:	c9                   	leave  
80101a3e:	c3                   	ret    

80101a3f <iput>:
// be recycled.
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
void
iput(struct inode *ip)
{
80101a3f:	55                   	push   %ebp
80101a40:	89 e5                	mov    %esp,%ebp
80101a42:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101a45:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101a4c:	e8 f2 30 00 00       	call   80104b43 <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101a51:	8b 45 08             	mov    0x8(%ebp),%eax
80101a54:	8b 40 08             	mov    0x8(%eax),%eax
80101a57:	83 f8 01             	cmp    $0x1,%eax
80101a5a:	0f 85 93 00 00 00    	jne    80101af3 <iput+0xb4>
80101a60:	8b 45 08             	mov    0x8(%ebp),%eax
80101a63:	8b 40 0c             	mov    0xc(%eax),%eax
80101a66:	83 e0 02             	and    $0x2,%eax
80101a69:	85 c0                	test   %eax,%eax
80101a6b:	0f 84 82 00 00 00    	je     80101af3 <iput+0xb4>
80101a71:	8b 45 08             	mov    0x8(%ebp),%eax
80101a74:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101a78:	66 85 c0             	test   %ax,%ax
80101a7b:	75 76                	jne    80101af3 <iput+0xb4>
    // inode has no links: truncate and free inode.
    if(ip->flags & I_BUSY)
80101a7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a80:	8b 40 0c             	mov    0xc(%eax),%eax
80101a83:	83 e0 01             	and    $0x1,%eax
80101a86:	85 c0                	test   %eax,%eax
80101a88:	74 0c                	je     80101a96 <iput+0x57>
      panic("iput busy");
80101a8a:	c7 04 24 ac 82 10 80 	movl   $0x801082ac,(%esp)
80101a91:	e8 b0 ea ff ff       	call   80100546 <panic>
    ip->flags |= I_BUSY;
80101a96:	8b 45 08             	mov    0x8(%ebp),%eax
80101a99:	8b 40 0c             	mov    0xc(%eax),%eax
80101a9c:	89 c2                	mov    %eax,%edx
80101a9e:	83 ca 01             	or     $0x1,%edx
80101aa1:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa4:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101aa7:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101aae:	e8 f2 30 00 00       	call   80104ba5 <release>
    itrunc(ip);
80101ab3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab6:	89 04 24             	mov    %eax,(%esp)
80101ab9:	e8 7d 01 00 00       	call   80101c3b <itrunc>
    ip->type = 0;
80101abe:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac1:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101ac7:	8b 45 08             	mov    0x8(%ebp),%eax
80101aca:	89 04 24             	mov    %eax,(%esp)
80101acd:	e8 fe fb ff ff       	call   801016d0 <iupdate>
    acquire(&icache.lock);
80101ad2:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101ad9:	e8 65 30 00 00       	call   80104b43 <acquire>
    ip->flags = 0;
80101ade:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101ae8:	8b 45 08             	mov    0x8(%ebp),%eax
80101aeb:	89 04 24             	mov    %eax,(%esp)
80101aee:	e8 4c 2e 00 00       	call   8010493f <wakeup>
  }
  ip->ref--;
80101af3:	8b 45 08             	mov    0x8(%ebp),%eax
80101af6:	8b 40 08             	mov    0x8(%eax),%eax
80101af9:	8d 50 ff             	lea    -0x1(%eax),%edx
80101afc:	8b 45 08             	mov    0x8(%ebp),%eax
80101aff:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b02:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101b09:	e8 97 30 00 00       	call   80104ba5 <release>
}
80101b0e:	c9                   	leave  
80101b0f:	c3                   	ret    

80101b10 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101b10:	55                   	push   %ebp
80101b11:	89 e5                	mov    %esp,%ebp
80101b13:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101b16:	8b 45 08             	mov    0x8(%ebp),%eax
80101b19:	89 04 24             	mov    %eax,(%esp)
80101b1c:	e8 b9 fe ff ff       	call   801019da <iunlock>
  iput(ip);
80101b21:	8b 45 08             	mov    0x8(%ebp),%eax
80101b24:	89 04 24             	mov    %eax,(%esp)
80101b27:	e8 13 ff ff ff       	call   80101a3f <iput>
}
80101b2c:	c9                   	leave  
80101b2d:	c3                   	ret    

80101b2e <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101b2e:	55                   	push   %ebp
80101b2f:	89 e5                	mov    %esp,%ebp
80101b31:	53                   	push   %ebx
80101b32:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101b35:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101b39:	77 3e                	ja     80101b79 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101b3b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3e:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b41:	83 c2 04             	add    $0x4,%edx
80101b44:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101b48:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b4b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b4f:	75 20                	jne    80101b71 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101b51:	8b 45 08             	mov    0x8(%ebp),%eax
80101b54:	8b 00                	mov    (%eax),%eax
80101b56:	89 04 24             	mov    %eax,(%esp)
80101b59:	e8 45 f8 ff ff       	call   801013a3 <balloc>
80101b5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b61:	8b 45 08             	mov    0x8(%ebp),%eax
80101b64:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b67:	8d 4a 04             	lea    0x4(%edx),%ecx
80101b6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b6d:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b74:	e9 bc 00 00 00       	jmp    80101c35 <bmap+0x107>
  }
  bn -= NDIRECT;
80101b79:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101b7d:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101b81:	0f 87 a2 00 00 00    	ja     80101c29 <bmap+0xfb>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101b87:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8a:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b90:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b94:	75 19                	jne    80101baf <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101b96:	8b 45 08             	mov    0x8(%ebp),%eax
80101b99:	8b 00                	mov    (%eax),%eax
80101b9b:	89 04 24             	mov    %eax,(%esp)
80101b9e:	e8 00 f8 ff ff       	call   801013a3 <balloc>
80101ba3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ba6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bac:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101baf:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb2:	8b 00                	mov    (%eax),%eax
80101bb4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bb7:	89 54 24 04          	mov    %edx,0x4(%esp)
80101bbb:	89 04 24             	mov    %eax,(%esp)
80101bbe:	e8 e3 e5 ff ff       	call   801001a6 <bread>
80101bc3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101bc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bc9:	83 c0 18             	add    $0x18,%eax
80101bcc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101bcf:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bd2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101bd9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101bdc:	01 d0                	add    %edx,%eax
80101bde:	8b 00                	mov    (%eax),%eax
80101be0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101be3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101be7:	75 30                	jne    80101c19 <bmap+0xeb>
      a[bn] = addr = balloc(ip->dev);
80101be9:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bec:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101bf3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101bf6:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101bf9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfc:	8b 00                	mov    (%eax),%eax
80101bfe:	89 04 24             	mov    %eax,(%esp)
80101c01:	e8 9d f7 ff ff       	call   801013a3 <balloc>
80101c06:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c0c:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101c0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c11:	89 04 24             	mov    %eax,(%esp)
80101c14:	e8 f0 16 00 00       	call   80103309 <log_write>
    }
    brelse(bp);
80101c19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c1c:	89 04 24             	mov    %eax,(%esp)
80101c1f:	e8 f3 e5 ff ff       	call   80100217 <brelse>
    return addr;
80101c24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c27:	eb 0c                	jmp    80101c35 <bmap+0x107>
  }

  panic("bmap: out of range");
80101c29:	c7 04 24 b6 82 10 80 	movl   $0x801082b6,(%esp)
80101c30:	e8 11 e9 ff ff       	call   80100546 <panic>
}
80101c35:	83 c4 24             	add    $0x24,%esp
80101c38:	5b                   	pop    %ebx
80101c39:	5d                   	pop    %ebp
80101c3a:	c3                   	ret    

80101c3b <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101c3b:	55                   	push   %ebp
80101c3c:	89 e5                	mov    %esp,%ebp
80101c3e:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c41:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101c48:	eb 44                	jmp    80101c8e <itrunc+0x53>
    if(ip->addrs[i]){
80101c4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c50:	83 c2 04             	add    $0x4,%edx
80101c53:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c57:	85 c0                	test   %eax,%eax
80101c59:	74 2f                	je     80101c8a <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101c5b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c5e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c61:	83 c2 04             	add    $0x4,%edx
80101c64:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101c68:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6b:	8b 00                	mov    (%eax),%eax
80101c6d:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c71:	89 04 24             	mov    %eax,(%esp)
80101c74:	e8 83 f8 ff ff       	call   801014fc <bfree>
      ip->addrs[i] = 0;
80101c79:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c7f:	83 c2 04             	add    $0x4,%edx
80101c82:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101c89:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c8a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101c8e:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101c92:	7e b6                	jle    80101c4a <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101c94:	8b 45 08             	mov    0x8(%ebp),%eax
80101c97:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c9a:	85 c0                	test   %eax,%eax
80101c9c:	0f 84 9b 00 00 00    	je     80101d3d <itrunc+0x102>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101ca2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca5:	8b 50 4c             	mov    0x4c(%eax),%edx
80101ca8:	8b 45 08             	mov    0x8(%ebp),%eax
80101cab:	8b 00                	mov    (%eax),%eax
80101cad:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cb1:	89 04 24             	mov    %eax,(%esp)
80101cb4:	e8 ed e4 ff ff       	call   801001a6 <bread>
80101cb9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101cbc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cbf:	83 c0 18             	add    $0x18,%eax
80101cc2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101cc5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101ccc:	eb 3b                	jmp    80101d09 <itrunc+0xce>
      if(a[j])
80101cce:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cd1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cd8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101cdb:	01 d0                	add    %edx,%eax
80101cdd:	8b 00                	mov    (%eax),%eax
80101cdf:	85 c0                	test   %eax,%eax
80101ce1:	74 22                	je     80101d05 <itrunc+0xca>
        bfree(ip->dev, a[j]);
80101ce3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ce6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ced:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101cf0:	01 d0                	add    %edx,%eax
80101cf2:	8b 10                	mov    (%eax),%edx
80101cf4:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf7:	8b 00                	mov    (%eax),%eax
80101cf9:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cfd:	89 04 24             	mov    %eax,(%esp)
80101d00:	e8 f7 f7 ff ff       	call   801014fc <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101d05:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101d09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d0c:	83 f8 7f             	cmp    $0x7f,%eax
80101d0f:	76 bd                	jbe    80101cce <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101d11:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d14:	89 04 24             	mov    %eax,(%esp)
80101d17:	e8 fb e4 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101d1c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1f:	8b 50 4c             	mov    0x4c(%eax),%edx
80101d22:	8b 45 08             	mov    0x8(%ebp),%eax
80101d25:	8b 00                	mov    (%eax),%eax
80101d27:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d2b:	89 04 24             	mov    %eax,(%esp)
80101d2e:	e8 c9 f7 ff ff       	call   801014fc <bfree>
    ip->addrs[NDIRECT] = 0;
80101d33:	8b 45 08             	mov    0x8(%ebp),%eax
80101d36:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101d3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d40:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101d47:	8b 45 08             	mov    0x8(%ebp),%eax
80101d4a:	89 04 24             	mov    %eax,(%esp)
80101d4d:	e8 7e f9 ff ff       	call   801016d0 <iupdate>
}
80101d52:	c9                   	leave  
80101d53:	c3                   	ret    

80101d54 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101d54:	55                   	push   %ebp
80101d55:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101d57:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5a:	8b 00                	mov    (%eax),%eax
80101d5c:	89 c2                	mov    %eax,%edx
80101d5e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d61:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101d64:	8b 45 08             	mov    0x8(%ebp),%eax
80101d67:	8b 50 04             	mov    0x4(%eax),%edx
80101d6a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d6d:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101d70:	8b 45 08             	mov    0x8(%ebp),%eax
80101d73:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101d77:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d7a:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101d7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d80:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101d84:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d87:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101d8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8e:	8b 50 18             	mov    0x18(%eax),%edx
80101d91:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d94:	89 50 10             	mov    %edx,0x10(%eax)
}
80101d97:	5d                   	pop    %ebp
80101d98:	c3                   	ret    

80101d99 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101d99:	55                   	push   %ebp
80101d9a:	89 e5                	mov    %esp,%ebp
80101d9c:	53                   	push   %ebx
80101d9d:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101da0:	8b 45 08             	mov    0x8(%ebp),%eax
80101da3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101da7:	66 83 f8 03          	cmp    $0x3,%ax
80101dab:	75 60                	jne    80101e0d <readi+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101dad:	8b 45 08             	mov    0x8(%ebp),%eax
80101db0:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101db4:	66 85 c0             	test   %ax,%ax
80101db7:	78 20                	js     80101dd9 <readi+0x40>
80101db9:	8b 45 08             	mov    0x8(%ebp),%eax
80101dbc:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101dc0:	66 83 f8 09          	cmp    $0x9,%ax
80101dc4:	7f 13                	jg     80101dd9 <readi+0x40>
80101dc6:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc9:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101dcd:	98                   	cwtl   
80101dce:	8b 04 c5 00 e8 10 80 	mov    -0x7fef1800(,%eax,8),%eax
80101dd5:	85 c0                	test   %eax,%eax
80101dd7:	75 0a                	jne    80101de3 <readi+0x4a>
      return -1;
80101dd9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101dde:	e9 1e 01 00 00       	jmp    80101f01 <readi+0x168>
    return devsw[ip->major].read(ip, dst, n);
80101de3:	8b 45 08             	mov    0x8(%ebp),%eax
80101de6:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101dea:	98                   	cwtl   
80101deb:	8b 04 c5 00 e8 10 80 	mov    -0x7fef1800(,%eax,8),%eax
80101df2:	8b 55 14             	mov    0x14(%ebp),%edx
80101df5:	89 54 24 08          	mov    %edx,0x8(%esp)
80101df9:	8b 55 0c             	mov    0xc(%ebp),%edx
80101dfc:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e00:	8b 55 08             	mov    0x8(%ebp),%edx
80101e03:	89 14 24             	mov    %edx,(%esp)
80101e06:	ff d0                	call   *%eax
80101e08:	e9 f4 00 00 00       	jmp    80101f01 <readi+0x168>
  }

  if(off > ip->size || off + n < off)
80101e0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e10:	8b 40 18             	mov    0x18(%eax),%eax
80101e13:	3b 45 10             	cmp    0x10(%ebp),%eax
80101e16:	72 0d                	jb     80101e25 <readi+0x8c>
80101e18:	8b 45 14             	mov    0x14(%ebp),%eax
80101e1b:	8b 55 10             	mov    0x10(%ebp),%edx
80101e1e:	01 d0                	add    %edx,%eax
80101e20:	3b 45 10             	cmp    0x10(%ebp),%eax
80101e23:	73 0a                	jae    80101e2f <readi+0x96>
    return -1;
80101e25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101e2a:	e9 d2 00 00 00       	jmp    80101f01 <readi+0x168>
  if(off + n > ip->size)
80101e2f:	8b 45 14             	mov    0x14(%ebp),%eax
80101e32:	8b 55 10             	mov    0x10(%ebp),%edx
80101e35:	01 c2                	add    %eax,%edx
80101e37:	8b 45 08             	mov    0x8(%ebp),%eax
80101e3a:	8b 40 18             	mov    0x18(%eax),%eax
80101e3d:	39 c2                	cmp    %eax,%edx
80101e3f:	76 0c                	jbe    80101e4d <readi+0xb4>
    n = ip->size - off;
80101e41:	8b 45 08             	mov    0x8(%ebp),%eax
80101e44:	8b 40 18             	mov    0x18(%eax),%eax
80101e47:	2b 45 10             	sub    0x10(%ebp),%eax
80101e4a:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e4d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e54:	e9 99 00 00 00       	jmp    80101ef2 <readi+0x159>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101e59:	8b 45 10             	mov    0x10(%ebp),%eax
80101e5c:	c1 e8 09             	shr    $0x9,%eax
80101e5f:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e63:	8b 45 08             	mov    0x8(%ebp),%eax
80101e66:	89 04 24             	mov    %eax,(%esp)
80101e69:	e8 c0 fc ff ff       	call   80101b2e <bmap>
80101e6e:	8b 55 08             	mov    0x8(%ebp),%edx
80101e71:	8b 12                	mov    (%edx),%edx
80101e73:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e77:	89 14 24             	mov    %edx,(%esp)
80101e7a:	e8 27 e3 ff ff       	call   801001a6 <bread>
80101e7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101e82:	8b 45 10             	mov    0x10(%ebp),%eax
80101e85:	89 c2                	mov    %eax,%edx
80101e87:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80101e8d:	b8 00 02 00 00       	mov    $0x200,%eax
80101e92:	89 c1                	mov    %eax,%ecx
80101e94:	29 d1                	sub    %edx,%ecx
80101e96:	89 ca                	mov    %ecx,%edx
80101e98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e9b:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101e9e:	89 cb                	mov    %ecx,%ebx
80101ea0:	29 c3                	sub    %eax,%ebx
80101ea2:	89 d8                	mov    %ebx,%eax
80101ea4:	39 c2                	cmp    %eax,%edx
80101ea6:	0f 46 c2             	cmovbe %edx,%eax
80101ea9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101eac:	8b 45 10             	mov    0x10(%ebp),%eax
80101eaf:	25 ff 01 00 00       	and    $0x1ff,%eax
80101eb4:	8d 50 10             	lea    0x10(%eax),%edx
80101eb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101eba:	01 d0                	add    %edx,%eax
80101ebc:	8d 50 08             	lea    0x8(%eax),%edx
80101ebf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ec2:	89 44 24 08          	mov    %eax,0x8(%esp)
80101ec6:	89 54 24 04          	mov    %edx,0x4(%esp)
80101eca:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ecd:	89 04 24             	mov    %eax,(%esp)
80101ed0:	e8 9c 2f 00 00       	call   80104e71 <memmove>
    brelse(bp);
80101ed5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ed8:	89 04 24             	mov    %eax,(%esp)
80101edb:	e8 37 e3 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101ee0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ee3:	01 45 f4             	add    %eax,-0xc(%ebp)
80101ee6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ee9:	01 45 10             	add    %eax,0x10(%ebp)
80101eec:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eef:	01 45 0c             	add    %eax,0xc(%ebp)
80101ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ef5:	3b 45 14             	cmp    0x14(%ebp),%eax
80101ef8:	0f 82 5b ff ff ff    	jb     80101e59 <readi+0xc0>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101efe:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101f01:	83 c4 24             	add    $0x24,%esp
80101f04:	5b                   	pop    %ebx
80101f05:	5d                   	pop    %ebp
80101f06:	c3                   	ret    

80101f07 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101f07:	55                   	push   %ebp
80101f08:	89 e5                	mov    %esp,%ebp
80101f0a:	53                   	push   %ebx
80101f0b:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f11:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101f15:	66 83 f8 03          	cmp    $0x3,%ax
80101f19:	75 60                	jne    80101f7b <writei+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101f1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f1e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f22:	66 85 c0             	test   %ax,%ax
80101f25:	78 20                	js     80101f47 <writei+0x40>
80101f27:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f2e:	66 83 f8 09          	cmp    $0x9,%ax
80101f32:	7f 13                	jg     80101f47 <writei+0x40>
80101f34:	8b 45 08             	mov    0x8(%ebp),%eax
80101f37:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f3b:	98                   	cwtl   
80101f3c:	8b 04 c5 04 e8 10 80 	mov    -0x7fef17fc(,%eax,8),%eax
80101f43:	85 c0                	test   %eax,%eax
80101f45:	75 0a                	jne    80101f51 <writei+0x4a>
      return -1;
80101f47:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f4c:	e9 49 01 00 00       	jmp    8010209a <writei+0x193>
    return devsw[ip->major].write(ip, src, n);
80101f51:	8b 45 08             	mov    0x8(%ebp),%eax
80101f54:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f58:	98                   	cwtl   
80101f59:	8b 04 c5 04 e8 10 80 	mov    -0x7fef17fc(,%eax,8),%eax
80101f60:	8b 55 14             	mov    0x14(%ebp),%edx
80101f63:	89 54 24 08          	mov    %edx,0x8(%esp)
80101f67:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f6a:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f6e:	8b 55 08             	mov    0x8(%ebp),%edx
80101f71:	89 14 24             	mov    %edx,(%esp)
80101f74:	ff d0                	call   *%eax
80101f76:	e9 1f 01 00 00       	jmp    8010209a <writei+0x193>
  }

  if(off > ip->size || off + n < off)
80101f7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7e:	8b 40 18             	mov    0x18(%eax),%eax
80101f81:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f84:	72 0d                	jb     80101f93 <writei+0x8c>
80101f86:	8b 45 14             	mov    0x14(%ebp),%eax
80101f89:	8b 55 10             	mov    0x10(%ebp),%edx
80101f8c:	01 d0                	add    %edx,%eax
80101f8e:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f91:	73 0a                	jae    80101f9d <writei+0x96>
    return -1;
80101f93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f98:	e9 fd 00 00 00       	jmp    8010209a <writei+0x193>
  if(off + n > MAXFILE*BSIZE)
80101f9d:	8b 45 14             	mov    0x14(%ebp),%eax
80101fa0:	8b 55 10             	mov    0x10(%ebp),%edx
80101fa3:	01 d0                	add    %edx,%eax
80101fa5:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101faa:	76 0a                	jbe    80101fb6 <writei+0xaf>
    return -1;
80101fac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fb1:	e9 e4 00 00 00       	jmp    8010209a <writei+0x193>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101fb6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101fbd:	e9 a4 00 00 00       	jmp    80102066 <writei+0x15f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101fc2:	8b 45 10             	mov    0x10(%ebp),%eax
80101fc5:	c1 e8 09             	shr    $0x9,%eax
80101fc8:	89 44 24 04          	mov    %eax,0x4(%esp)
80101fcc:	8b 45 08             	mov    0x8(%ebp),%eax
80101fcf:	89 04 24             	mov    %eax,(%esp)
80101fd2:	e8 57 fb ff ff       	call   80101b2e <bmap>
80101fd7:	8b 55 08             	mov    0x8(%ebp),%edx
80101fda:	8b 12                	mov    (%edx),%edx
80101fdc:	89 44 24 04          	mov    %eax,0x4(%esp)
80101fe0:	89 14 24             	mov    %edx,(%esp)
80101fe3:	e8 be e1 ff ff       	call   801001a6 <bread>
80101fe8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101feb:	8b 45 10             	mov    0x10(%ebp),%eax
80101fee:	89 c2                	mov    %eax,%edx
80101ff0:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80101ff6:	b8 00 02 00 00       	mov    $0x200,%eax
80101ffb:	89 c1                	mov    %eax,%ecx
80101ffd:	29 d1                	sub    %edx,%ecx
80101fff:	89 ca                	mov    %ecx,%edx
80102001:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102004:	8b 4d 14             	mov    0x14(%ebp),%ecx
80102007:	89 cb                	mov    %ecx,%ebx
80102009:	29 c3                	sub    %eax,%ebx
8010200b:	89 d8                	mov    %ebx,%eax
8010200d:	39 c2                	cmp    %eax,%edx
8010200f:	0f 46 c2             	cmovbe %edx,%eax
80102012:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102015:	8b 45 10             	mov    0x10(%ebp),%eax
80102018:	25 ff 01 00 00       	and    $0x1ff,%eax
8010201d:	8d 50 10             	lea    0x10(%eax),%edx
80102020:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102023:	01 d0                	add    %edx,%eax
80102025:	8d 50 08             	lea    0x8(%eax),%edx
80102028:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010202b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010202f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102032:	89 44 24 04          	mov    %eax,0x4(%esp)
80102036:	89 14 24             	mov    %edx,(%esp)
80102039:	e8 33 2e 00 00       	call   80104e71 <memmove>
    log_write(bp);
8010203e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102041:	89 04 24             	mov    %eax,(%esp)
80102044:	e8 c0 12 00 00       	call   80103309 <log_write>
    brelse(bp);
80102049:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010204c:	89 04 24             	mov    %eax,(%esp)
8010204f:	e8 c3 e1 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102054:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102057:	01 45 f4             	add    %eax,-0xc(%ebp)
8010205a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010205d:	01 45 10             	add    %eax,0x10(%ebp)
80102060:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102063:	01 45 0c             	add    %eax,0xc(%ebp)
80102066:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102069:	3b 45 14             	cmp    0x14(%ebp),%eax
8010206c:	0f 82 50 ff ff ff    	jb     80101fc2 <writei+0xbb>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102072:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102076:	74 1f                	je     80102097 <writei+0x190>
80102078:	8b 45 08             	mov    0x8(%ebp),%eax
8010207b:	8b 40 18             	mov    0x18(%eax),%eax
8010207e:	3b 45 10             	cmp    0x10(%ebp),%eax
80102081:	73 14                	jae    80102097 <writei+0x190>
    ip->size = off;
80102083:	8b 45 08             	mov    0x8(%ebp),%eax
80102086:	8b 55 10             	mov    0x10(%ebp),%edx
80102089:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
8010208c:	8b 45 08             	mov    0x8(%ebp),%eax
8010208f:	89 04 24             	mov    %eax,(%esp)
80102092:	e8 39 f6 ff ff       	call   801016d0 <iupdate>
  }
  return n;
80102097:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010209a:	83 c4 24             	add    $0x24,%esp
8010209d:	5b                   	pop    %ebx
8010209e:	5d                   	pop    %ebp
8010209f:	c3                   	ret    

801020a0 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801020a0:	55                   	push   %ebp
801020a1:	89 e5                	mov    %esp,%ebp
801020a3:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
801020a6:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801020ad:	00 
801020ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801020b1:	89 44 24 04          	mov    %eax,0x4(%esp)
801020b5:	8b 45 08             	mov    0x8(%ebp),%eax
801020b8:	89 04 24             	mov    %eax,(%esp)
801020bb:	e8 55 2e 00 00       	call   80104f15 <strncmp>
}
801020c0:	c9                   	leave  
801020c1:	c3                   	ret    

801020c2 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801020c2:	55                   	push   %ebp
801020c3:	89 e5                	mov    %esp,%ebp
801020c5:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801020c8:	8b 45 08             	mov    0x8(%ebp),%eax
801020cb:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801020cf:	66 83 f8 01          	cmp    $0x1,%ax
801020d3:	74 0c                	je     801020e1 <dirlookup+0x1f>
    panic("dirlookup not DIR");
801020d5:	c7 04 24 c9 82 10 80 	movl   $0x801082c9,(%esp)
801020dc:	e8 65 e4 ff ff       	call   80100546 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801020e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020e8:	e9 87 00 00 00       	jmp    80102174 <dirlookup+0xb2>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801020ed:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801020f4:	00 
801020f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020f8:	89 44 24 08          	mov    %eax,0x8(%esp)
801020fc:	8d 45 e0             	lea    -0x20(%ebp),%eax
801020ff:	89 44 24 04          	mov    %eax,0x4(%esp)
80102103:	8b 45 08             	mov    0x8(%ebp),%eax
80102106:	89 04 24             	mov    %eax,(%esp)
80102109:	e8 8b fc ff ff       	call   80101d99 <readi>
8010210e:	83 f8 10             	cmp    $0x10,%eax
80102111:	74 0c                	je     8010211f <dirlookup+0x5d>
      panic("dirlink read");
80102113:	c7 04 24 db 82 10 80 	movl   $0x801082db,(%esp)
8010211a:	e8 27 e4 ff ff       	call   80100546 <panic>
    if(de.inum == 0)
8010211f:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102123:	66 85 c0             	test   %ax,%ax
80102126:	74 47                	je     8010216f <dirlookup+0xad>
      continue;
    if(namecmp(name, de.name) == 0){
80102128:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010212b:	83 c0 02             	add    $0x2,%eax
8010212e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102132:	8b 45 0c             	mov    0xc(%ebp),%eax
80102135:	89 04 24             	mov    %eax,(%esp)
80102138:	e8 63 ff ff ff       	call   801020a0 <namecmp>
8010213d:	85 c0                	test   %eax,%eax
8010213f:	75 2f                	jne    80102170 <dirlookup+0xae>
      // entry matches path element
      if(poff)
80102141:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102145:	74 08                	je     8010214f <dirlookup+0x8d>
        *poff = off;
80102147:	8b 45 10             	mov    0x10(%ebp),%eax
8010214a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010214d:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010214f:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102153:	0f b7 c0             	movzwl %ax,%eax
80102156:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102159:	8b 45 08             	mov    0x8(%ebp),%eax
8010215c:	8b 00                	mov    (%eax),%eax
8010215e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102161:	89 54 24 04          	mov    %edx,0x4(%esp)
80102165:	89 04 24             	mov    %eax,(%esp)
80102168:	e8 1b f6 ff ff       	call   80101788 <iget>
8010216d:	eb 19                	jmp    80102188 <dirlookup+0xc6>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
8010216f:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102170:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102174:	8b 45 08             	mov    0x8(%ebp),%eax
80102177:	8b 40 18             	mov    0x18(%eax),%eax
8010217a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010217d:	0f 87 6a ff ff ff    	ja     801020ed <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102183:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102188:	c9                   	leave  
80102189:	c3                   	ret    

8010218a <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010218a:	55                   	push   %ebp
8010218b:	89 e5                	mov    %esp,%ebp
8010218d:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102190:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102197:	00 
80102198:	8b 45 0c             	mov    0xc(%ebp),%eax
8010219b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010219f:	8b 45 08             	mov    0x8(%ebp),%eax
801021a2:	89 04 24             	mov    %eax,(%esp)
801021a5:	e8 18 ff ff ff       	call   801020c2 <dirlookup>
801021aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
801021ad:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801021b1:	74 15                	je     801021c8 <dirlink+0x3e>
    iput(ip);
801021b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021b6:	89 04 24             	mov    %eax,(%esp)
801021b9:	e8 81 f8 ff ff       	call   80101a3f <iput>
    return -1;
801021be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021c3:	e9 b8 00 00 00       	jmp    80102280 <dirlink+0xf6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801021c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021cf:	eb 44                	jmp    80102215 <dirlink+0x8b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021d4:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801021db:	00 
801021dc:	89 44 24 08          	mov    %eax,0x8(%esp)
801021e0:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021e3:	89 44 24 04          	mov    %eax,0x4(%esp)
801021e7:	8b 45 08             	mov    0x8(%ebp),%eax
801021ea:	89 04 24             	mov    %eax,(%esp)
801021ed:	e8 a7 fb ff ff       	call   80101d99 <readi>
801021f2:	83 f8 10             	cmp    $0x10,%eax
801021f5:	74 0c                	je     80102203 <dirlink+0x79>
      panic("dirlink read");
801021f7:	c7 04 24 db 82 10 80 	movl   $0x801082db,(%esp)
801021fe:	e8 43 e3 ff ff       	call   80100546 <panic>
    if(de.inum == 0)
80102203:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102207:	66 85 c0             	test   %ax,%ax
8010220a:	74 18                	je     80102224 <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010220c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010220f:	83 c0 10             	add    $0x10,%eax
80102212:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102215:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102218:	8b 45 08             	mov    0x8(%ebp),%eax
8010221b:	8b 40 18             	mov    0x18(%eax),%eax
8010221e:	39 c2                	cmp    %eax,%edx
80102220:	72 af                	jb     801021d1 <dirlink+0x47>
80102222:	eb 01                	jmp    80102225 <dirlink+0x9b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
80102224:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102225:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
8010222c:	00 
8010222d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102230:	89 44 24 04          	mov    %eax,0x4(%esp)
80102234:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102237:	83 c0 02             	add    $0x2,%eax
8010223a:	89 04 24             	mov    %eax,(%esp)
8010223d:	e8 2b 2d 00 00       	call   80104f6d <strncpy>
  de.inum = inum;
80102242:	8b 45 10             	mov    0x10(%ebp),%eax
80102245:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102249:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010224c:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102253:	00 
80102254:	89 44 24 08          	mov    %eax,0x8(%esp)
80102258:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010225b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010225f:	8b 45 08             	mov    0x8(%ebp),%eax
80102262:	89 04 24             	mov    %eax,(%esp)
80102265:	e8 9d fc ff ff       	call   80101f07 <writei>
8010226a:	83 f8 10             	cmp    $0x10,%eax
8010226d:	74 0c                	je     8010227b <dirlink+0xf1>
    panic("dirlink");
8010226f:	c7 04 24 e8 82 10 80 	movl   $0x801082e8,(%esp)
80102276:	e8 cb e2 ff ff       	call   80100546 <panic>
  
  return 0;
8010227b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102280:	c9                   	leave  
80102281:	c3                   	ret    

80102282 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102282:	55                   	push   %ebp
80102283:	89 e5                	mov    %esp,%ebp
80102285:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
80102288:	eb 04                	jmp    8010228e <skipelem+0xc>
    path++;
8010228a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
8010228e:	8b 45 08             	mov    0x8(%ebp),%eax
80102291:	0f b6 00             	movzbl (%eax),%eax
80102294:	3c 2f                	cmp    $0x2f,%al
80102296:	74 f2                	je     8010228a <skipelem+0x8>
    path++;
  if(*path == 0)
80102298:	8b 45 08             	mov    0x8(%ebp),%eax
8010229b:	0f b6 00             	movzbl (%eax),%eax
8010229e:	84 c0                	test   %al,%al
801022a0:	75 0a                	jne    801022ac <skipelem+0x2a>
    return 0;
801022a2:	b8 00 00 00 00       	mov    $0x0,%eax
801022a7:	e9 88 00 00 00       	jmp    80102334 <skipelem+0xb2>
  s = path;
801022ac:	8b 45 08             	mov    0x8(%ebp),%eax
801022af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801022b2:	eb 04                	jmp    801022b8 <skipelem+0x36>
    path++;
801022b4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801022b8:	8b 45 08             	mov    0x8(%ebp),%eax
801022bb:	0f b6 00             	movzbl (%eax),%eax
801022be:	3c 2f                	cmp    $0x2f,%al
801022c0:	74 0a                	je     801022cc <skipelem+0x4a>
801022c2:	8b 45 08             	mov    0x8(%ebp),%eax
801022c5:	0f b6 00             	movzbl (%eax),%eax
801022c8:	84 c0                	test   %al,%al
801022ca:	75 e8                	jne    801022b4 <skipelem+0x32>
    path++;
  len = path - s;
801022cc:	8b 55 08             	mov    0x8(%ebp),%edx
801022cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022d2:	89 d1                	mov    %edx,%ecx
801022d4:	29 c1                	sub    %eax,%ecx
801022d6:	89 c8                	mov    %ecx,%eax
801022d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801022db:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801022df:	7e 1c                	jle    801022fd <skipelem+0x7b>
    memmove(name, s, DIRSIZ);
801022e1:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801022e8:	00 
801022e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022ec:	89 44 24 04          	mov    %eax,0x4(%esp)
801022f0:	8b 45 0c             	mov    0xc(%ebp),%eax
801022f3:	89 04 24             	mov    %eax,(%esp)
801022f6:	e8 76 2b 00 00       	call   80104e71 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801022fb:	eb 2a                	jmp    80102327 <skipelem+0xa5>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
801022fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102300:	89 44 24 08          	mov    %eax,0x8(%esp)
80102304:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102307:	89 44 24 04          	mov    %eax,0x4(%esp)
8010230b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010230e:	89 04 24             	mov    %eax,(%esp)
80102311:	e8 5b 2b 00 00       	call   80104e71 <memmove>
    name[len] = 0;
80102316:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102319:	8b 45 0c             	mov    0xc(%ebp),%eax
8010231c:	01 d0                	add    %edx,%eax
8010231e:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102321:	eb 04                	jmp    80102327 <skipelem+0xa5>
    path++;
80102323:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102327:	8b 45 08             	mov    0x8(%ebp),%eax
8010232a:	0f b6 00             	movzbl (%eax),%eax
8010232d:	3c 2f                	cmp    $0x2f,%al
8010232f:	74 f2                	je     80102323 <skipelem+0xa1>
    path++;
  return path;
80102331:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102334:	c9                   	leave  
80102335:	c3                   	ret    

80102336 <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102336:	55                   	push   %ebp
80102337:	89 e5                	mov    %esp,%ebp
80102339:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010233c:	8b 45 08             	mov    0x8(%ebp),%eax
8010233f:	0f b6 00             	movzbl (%eax),%eax
80102342:	3c 2f                	cmp    $0x2f,%al
80102344:	75 1c                	jne    80102362 <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
80102346:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010234d:	00 
8010234e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102355:	e8 2e f4 ff ff       	call   80101788 <iget>
8010235a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
8010235d:	e9 af 00 00 00       	jmp    80102411 <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
80102362:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102368:	8b 40 68             	mov    0x68(%eax),%eax
8010236b:	89 04 24             	mov    %eax,(%esp)
8010236e:	e8 e7 f4 ff ff       	call   8010185a <idup>
80102373:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102376:	e9 96 00 00 00       	jmp    80102411 <namex+0xdb>
    ilock(ip);
8010237b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010237e:	89 04 24             	mov    %eax,(%esp)
80102381:	e8 06 f5 ff ff       	call   8010188c <ilock>
    if(ip->type != T_DIR){
80102386:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102389:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010238d:	66 83 f8 01          	cmp    $0x1,%ax
80102391:	74 15                	je     801023a8 <namex+0x72>
      iunlockput(ip);
80102393:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102396:	89 04 24             	mov    %eax,(%esp)
80102399:	e8 72 f7 ff ff       	call   80101b10 <iunlockput>
      return 0;
8010239e:	b8 00 00 00 00       	mov    $0x0,%eax
801023a3:	e9 a3 00 00 00       	jmp    8010244b <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
801023a8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801023ac:	74 1d                	je     801023cb <namex+0x95>
801023ae:	8b 45 08             	mov    0x8(%ebp),%eax
801023b1:	0f b6 00             	movzbl (%eax),%eax
801023b4:	84 c0                	test   %al,%al
801023b6:	75 13                	jne    801023cb <namex+0x95>
      // Stop one level early.
      iunlock(ip);
801023b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023bb:	89 04 24             	mov    %eax,(%esp)
801023be:	e8 17 f6 ff ff       	call   801019da <iunlock>
      return ip;
801023c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023c6:	e9 80 00 00 00       	jmp    8010244b <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801023cb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801023d2:	00 
801023d3:	8b 45 10             	mov    0x10(%ebp),%eax
801023d6:	89 44 24 04          	mov    %eax,0x4(%esp)
801023da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023dd:	89 04 24             	mov    %eax,(%esp)
801023e0:	e8 dd fc ff ff       	call   801020c2 <dirlookup>
801023e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801023e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801023ec:	75 12                	jne    80102400 <namex+0xca>
      iunlockput(ip);
801023ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023f1:	89 04 24             	mov    %eax,(%esp)
801023f4:	e8 17 f7 ff ff       	call   80101b10 <iunlockput>
      return 0;
801023f9:	b8 00 00 00 00       	mov    $0x0,%eax
801023fe:	eb 4b                	jmp    8010244b <namex+0x115>
    }
    iunlockput(ip);
80102400:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102403:	89 04 24             	mov    %eax,(%esp)
80102406:	e8 05 f7 ff ff       	call   80101b10 <iunlockput>
    ip = next;
8010240b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010240e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102411:	8b 45 10             	mov    0x10(%ebp),%eax
80102414:	89 44 24 04          	mov    %eax,0x4(%esp)
80102418:	8b 45 08             	mov    0x8(%ebp),%eax
8010241b:	89 04 24             	mov    %eax,(%esp)
8010241e:	e8 5f fe ff ff       	call   80102282 <skipelem>
80102423:	89 45 08             	mov    %eax,0x8(%ebp)
80102426:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010242a:	0f 85 4b ff ff ff    	jne    8010237b <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102430:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102434:	74 12                	je     80102448 <namex+0x112>
    iput(ip);
80102436:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102439:	89 04 24             	mov    %eax,(%esp)
8010243c:	e8 fe f5 ff ff       	call   80101a3f <iput>
    return 0;
80102441:	b8 00 00 00 00       	mov    $0x0,%eax
80102446:	eb 03                	jmp    8010244b <namex+0x115>
  }
  return ip;
80102448:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010244b:	c9                   	leave  
8010244c:	c3                   	ret    

8010244d <namei>:

struct inode*
namei(char *path)
{
8010244d:	55                   	push   %ebp
8010244e:	89 e5                	mov    %esp,%ebp
80102450:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102453:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102456:	89 44 24 08          	mov    %eax,0x8(%esp)
8010245a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102461:	00 
80102462:	8b 45 08             	mov    0x8(%ebp),%eax
80102465:	89 04 24             	mov    %eax,(%esp)
80102468:	e8 c9 fe ff ff       	call   80102336 <namex>
}
8010246d:	c9                   	leave  
8010246e:	c3                   	ret    

8010246f <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
8010246f:	55                   	push   %ebp
80102470:	89 e5                	mov    %esp,%ebp
80102472:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
80102475:	8b 45 0c             	mov    0xc(%ebp),%eax
80102478:	89 44 24 08          	mov    %eax,0x8(%esp)
8010247c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102483:	00 
80102484:	8b 45 08             	mov    0x8(%ebp),%eax
80102487:	89 04 24             	mov    %eax,(%esp)
8010248a:	e8 a7 fe ff ff       	call   80102336 <namex>
}
8010248f:	c9                   	leave  
80102490:	c3                   	ret    
80102491:	66 90                	xchg   %ax,%ax
80102493:	90                   	nop

80102494 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102494:	55                   	push   %ebp
80102495:	89 e5                	mov    %esp,%ebp
80102497:	53                   	push   %ebx
80102498:	83 ec 14             	sub    $0x14,%esp
8010249b:	8b 45 08             	mov    0x8(%ebp),%eax
8010249e:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801024a2:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
801024a6:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801024aa:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
801024ae:	ec                   	in     (%dx),%al
801024af:	89 c3                	mov    %eax,%ebx
801024b1:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801024b4:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801024b8:	83 c4 14             	add    $0x14,%esp
801024bb:	5b                   	pop    %ebx
801024bc:	5d                   	pop    %ebp
801024bd:	c3                   	ret    

801024be <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
801024be:	55                   	push   %ebp
801024bf:	89 e5                	mov    %esp,%ebp
801024c1:	57                   	push   %edi
801024c2:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801024c3:	8b 55 08             	mov    0x8(%ebp),%edx
801024c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801024c9:	8b 45 10             	mov    0x10(%ebp),%eax
801024cc:	89 cb                	mov    %ecx,%ebx
801024ce:	89 df                	mov    %ebx,%edi
801024d0:	89 c1                	mov    %eax,%ecx
801024d2:	fc                   	cld    
801024d3:	f3 6d                	rep insl (%dx),%es:(%edi)
801024d5:	89 c8                	mov    %ecx,%eax
801024d7:	89 fb                	mov    %edi,%ebx
801024d9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801024dc:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801024df:	5b                   	pop    %ebx
801024e0:	5f                   	pop    %edi
801024e1:	5d                   	pop    %ebp
801024e2:	c3                   	ret    

801024e3 <outb>:

static inline void
outb(ushort port, uchar data)
{
801024e3:	55                   	push   %ebp
801024e4:	89 e5                	mov    %esp,%ebp
801024e6:	83 ec 08             	sub    $0x8,%esp
801024e9:	8b 55 08             	mov    0x8(%ebp),%edx
801024ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801024ef:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801024f3:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801024f6:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801024fa:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801024fe:	ee                   	out    %al,(%dx)
}
801024ff:	c9                   	leave  
80102500:	c3                   	ret    

80102501 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102501:	55                   	push   %ebp
80102502:	89 e5                	mov    %esp,%ebp
80102504:	56                   	push   %esi
80102505:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102506:	8b 55 08             	mov    0x8(%ebp),%edx
80102509:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010250c:	8b 45 10             	mov    0x10(%ebp),%eax
8010250f:	89 cb                	mov    %ecx,%ebx
80102511:	89 de                	mov    %ebx,%esi
80102513:	89 c1                	mov    %eax,%ecx
80102515:	fc                   	cld    
80102516:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102518:	89 c8                	mov    %ecx,%eax
8010251a:	89 f3                	mov    %esi,%ebx
8010251c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010251f:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102522:	5b                   	pop    %ebx
80102523:	5e                   	pop    %esi
80102524:	5d                   	pop    %ebp
80102525:	c3                   	ret    

80102526 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102526:	55                   	push   %ebp
80102527:	89 e5                	mov    %esp,%ebp
80102529:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
8010252c:	90                   	nop
8010252d:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102534:	e8 5b ff ff ff       	call   80102494 <inb>
80102539:	0f b6 c0             	movzbl %al,%eax
8010253c:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010253f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102542:	25 c0 00 00 00       	and    $0xc0,%eax
80102547:	83 f8 40             	cmp    $0x40,%eax
8010254a:	75 e1                	jne    8010252d <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010254c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102550:	74 11                	je     80102563 <idewait+0x3d>
80102552:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102555:	83 e0 21             	and    $0x21,%eax
80102558:	85 c0                	test   %eax,%eax
8010255a:	74 07                	je     80102563 <idewait+0x3d>
    return -1;
8010255c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102561:	eb 05                	jmp    80102568 <idewait+0x42>
  return 0;
80102563:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102568:	c9                   	leave  
80102569:	c3                   	ret    

8010256a <ideinit>:

void
ideinit(void)
{
8010256a:	55                   	push   %ebp
8010256b:	89 e5                	mov    %esp,%ebp
8010256d:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102570:	c7 44 24 04 f0 82 10 	movl   $0x801082f0,0x4(%esp)
80102577:	80 
80102578:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
8010257f:	e8 9e 25 00 00       	call   80104b22 <initlock>
  picenable(IRQ_IDE);
80102584:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
8010258b:	e8 75 15 00 00       	call   80103b05 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102590:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
80102595:	83 e8 01             	sub    $0x1,%eax
80102598:	89 44 24 04          	mov    %eax,0x4(%esp)
8010259c:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801025a3:	e8 12 04 00 00       	call   801029ba <ioapicenable>
  idewait(0);
801025a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801025af:	e8 72 ff ff ff       	call   80102526 <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801025b4:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
801025bb:	00 
801025bc:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801025c3:	e8 1b ff ff ff       	call   801024e3 <outb>
  for(i=0; i<1000; i++){
801025c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025cf:	eb 20                	jmp    801025f1 <ideinit+0x87>
    if(inb(0x1f7) != 0){
801025d1:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801025d8:	e8 b7 fe ff ff       	call   80102494 <inb>
801025dd:	84 c0                	test   %al,%al
801025df:	74 0c                	je     801025ed <ideinit+0x83>
      havedisk1 = 1;
801025e1:	c7 05 38 b6 10 80 01 	movl   $0x1,0x8010b638
801025e8:	00 00 00 
      break;
801025eb:	eb 0d                	jmp    801025fa <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801025ed:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801025f1:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801025f8:	7e d7                	jle    801025d1 <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801025fa:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102601:	00 
80102602:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102609:	e8 d5 fe ff ff       	call   801024e3 <outb>
}
8010260e:	c9                   	leave  
8010260f:	c3                   	ret    

80102610 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102610:	55                   	push   %ebp
80102611:	89 e5                	mov    %esp,%ebp
80102613:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102616:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010261a:	75 0c                	jne    80102628 <idestart+0x18>
    panic("idestart");
8010261c:	c7 04 24 f4 82 10 80 	movl   $0x801082f4,(%esp)
80102623:	e8 1e df ff ff       	call   80100546 <panic>

  idewait(0);
80102628:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010262f:	e8 f2 fe ff ff       	call   80102526 <idewait>
  outb(0x3f6, 0);  // generate interrupt
80102634:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010263b:	00 
8010263c:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
80102643:	e8 9b fe ff ff       	call   801024e3 <outb>
  outb(0x1f2, 1);  // number of sectors
80102648:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010264f:	00 
80102650:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
80102657:	e8 87 fe ff ff       	call   801024e3 <outb>
  outb(0x1f3, b->sector & 0xff);
8010265c:	8b 45 08             	mov    0x8(%ebp),%eax
8010265f:	8b 40 08             	mov    0x8(%eax),%eax
80102662:	0f b6 c0             	movzbl %al,%eax
80102665:	89 44 24 04          	mov    %eax,0x4(%esp)
80102669:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102670:	e8 6e fe ff ff       	call   801024e3 <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
80102675:	8b 45 08             	mov    0x8(%ebp),%eax
80102678:	8b 40 08             	mov    0x8(%eax),%eax
8010267b:	c1 e8 08             	shr    $0x8,%eax
8010267e:	0f b6 c0             	movzbl %al,%eax
80102681:	89 44 24 04          	mov    %eax,0x4(%esp)
80102685:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
8010268c:	e8 52 fe ff ff       	call   801024e3 <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
80102691:	8b 45 08             	mov    0x8(%ebp),%eax
80102694:	8b 40 08             	mov    0x8(%eax),%eax
80102697:	c1 e8 10             	shr    $0x10,%eax
8010269a:	0f b6 c0             	movzbl %al,%eax
8010269d:	89 44 24 04          	mov    %eax,0x4(%esp)
801026a1:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
801026a8:	e8 36 fe ff ff       	call   801024e3 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
801026ad:	8b 45 08             	mov    0x8(%ebp),%eax
801026b0:	8b 40 04             	mov    0x4(%eax),%eax
801026b3:	83 e0 01             	and    $0x1,%eax
801026b6:	89 c2                	mov    %eax,%edx
801026b8:	c1 e2 04             	shl    $0x4,%edx
801026bb:	8b 45 08             	mov    0x8(%ebp),%eax
801026be:	8b 40 08             	mov    0x8(%eax),%eax
801026c1:	c1 e8 18             	shr    $0x18,%eax
801026c4:	83 e0 0f             	and    $0xf,%eax
801026c7:	09 d0                	or     %edx,%eax
801026c9:	83 c8 e0             	or     $0xffffffe0,%eax
801026cc:	0f b6 c0             	movzbl %al,%eax
801026cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801026d3:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801026da:	e8 04 fe ff ff       	call   801024e3 <outb>
  if(b->flags & B_DIRTY){
801026df:	8b 45 08             	mov    0x8(%ebp),%eax
801026e2:	8b 00                	mov    (%eax),%eax
801026e4:	83 e0 04             	and    $0x4,%eax
801026e7:	85 c0                	test   %eax,%eax
801026e9:	74 34                	je     8010271f <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
801026eb:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
801026f2:	00 
801026f3:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026fa:	e8 e4 fd ff ff       	call   801024e3 <outb>
    outsl(0x1f0, b->data, 512/4);
801026ff:	8b 45 08             	mov    0x8(%ebp),%eax
80102702:	83 c0 18             	add    $0x18,%eax
80102705:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010270c:	00 
8010270d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102711:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102718:	e8 e4 fd ff ff       	call   80102501 <outsl>
8010271d:	eb 14                	jmp    80102733 <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
8010271f:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80102726:	00 
80102727:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010272e:	e8 b0 fd ff ff       	call   801024e3 <outb>
  }
}
80102733:	c9                   	leave  
80102734:	c3                   	ret    

80102735 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102735:	55                   	push   %ebp
80102736:	89 e5                	mov    %esp,%ebp
80102738:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
8010273b:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102742:	e8 fc 23 00 00       	call   80104b43 <acquire>
  if((b = idequeue) == 0){
80102747:	a1 34 b6 10 80       	mov    0x8010b634,%eax
8010274c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010274f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102753:	75 11                	jne    80102766 <ideintr+0x31>
    release(&idelock);
80102755:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
8010275c:	e8 44 24 00 00       	call   80104ba5 <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102761:	e9 90 00 00 00       	jmp    801027f6 <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102766:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102769:	8b 40 14             	mov    0x14(%eax),%eax
8010276c:	a3 34 b6 10 80       	mov    %eax,0x8010b634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102771:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102774:	8b 00                	mov    (%eax),%eax
80102776:	83 e0 04             	and    $0x4,%eax
80102779:	85 c0                	test   %eax,%eax
8010277b:	75 2e                	jne    801027ab <ideintr+0x76>
8010277d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102784:	e8 9d fd ff ff       	call   80102526 <idewait>
80102789:	85 c0                	test   %eax,%eax
8010278b:	78 1e                	js     801027ab <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
8010278d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102790:	83 c0 18             	add    $0x18,%eax
80102793:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010279a:	00 
8010279b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010279f:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801027a6:	e8 13 fd ff ff       	call   801024be <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801027ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027ae:	8b 00                	mov    (%eax),%eax
801027b0:	89 c2                	mov    %eax,%edx
801027b2:	83 ca 02             	or     $0x2,%edx
801027b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027b8:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801027ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027bd:	8b 00                	mov    (%eax),%eax
801027bf:	89 c2                	mov    %eax,%edx
801027c1:	83 e2 fb             	and    $0xfffffffb,%edx
801027c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027c7:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801027c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027cc:	89 04 24             	mov    %eax,(%esp)
801027cf:	e8 6b 21 00 00       	call   8010493f <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
801027d4:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801027d9:	85 c0                	test   %eax,%eax
801027db:	74 0d                	je     801027ea <ideintr+0xb5>
    idestart(idequeue);
801027dd:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801027e2:	89 04 24             	mov    %eax,(%esp)
801027e5:	e8 26 fe ff ff       	call   80102610 <idestart>

  release(&idelock);
801027ea:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801027f1:	e8 af 23 00 00       	call   80104ba5 <release>
}
801027f6:	c9                   	leave  
801027f7:	c3                   	ret    

801027f8 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801027f8:	55                   	push   %ebp
801027f9:	89 e5                	mov    %esp,%ebp
801027fb:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
801027fe:	8b 45 08             	mov    0x8(%ebp),%eax
80102801:	8b 00                	mov    (%eax),%eax
80102803:	83 e0 01             	and    $0x1,%eax
80102806:	85 c0                	test   %eax,%eax
80102808:	75 0c                	jne    80102816 <iderw+0x1e>
    panic("iderw: buf not busy");
8010280a:	c7 04 24 fd 82 10 80 	movl   $0x801082fd,(%esp)
80102811:	e8 30 dd ff ff       	call   80100546 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102816:	8b 45 08             	mov    0x8(%ebp),%eax
80102819:	8b 00                	mov    (%eax),%eax
8010281b:	83 e0 06             	and    $0x6,%eax
8010281e:	83 f8 02             	cmp    $0x2,%eax
80102821:	75 0c                	jne    8010282f <iderw+0x37>
    panic("iderw: nothing to do");
80102823:	c7 04 24 11 83 10 80 	movl   $0x80108311,(%esp)
8010282a:	e8 17 dd ff ff       	call   80100546 <panic>
  if(b->dev != 0 && !havedisk1)
8010282f:	8b 45 08             	mov    0x8(%ebp),%eax
80102832:	8b 40 04             	mov    0x4(%eax),%eax
80102835:	85 c0                	test   %eax,%eax
80102837:	74 15                	je     8010284e <iderw+0x56>
80102839:	a1 38 b6 10 80       	mov    0x8010b638,%eax
8010283e:	85 c0                	test   %eax,%eax
80102840:	75 0c                	jne    8010284e <iderw+0x56>
    panic("iderw: ide disk 1 not present");
80102842:	c7 04 24 26 83 10 80 	movl   $0x80108326,(%esp)
80102849:	e8 f8 dc ff ff       	call   80100546 <panic>

  acquire(&idelock);  //DOC:acquire-lock
8010284e:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102855:	e8 e9 22 00 00       	call   80104b43 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
8010285a:	8b 45 08             	mov    0x8(%ebp),%eax
8010285d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102864:	c7 45 f4 34 b6 10 80 	movl   $0x8010b634,-0xc(%ebp)
8010286b:	eb 0b                	jmp    80102878 <iderw+0x80>
8010286d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102870:	8b 00                	mov    (%eax),%eax
80102872:	83 c0 14             	add    $0x14,%eax
80102875:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102878:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010287b:	8b 00                	mov    (%eax),%eax
8010287d:	85 c0                	test   %eax,%eax
8010287f:	75 ec                	jne    8010286d <iderw+0x75>
    ;
  *pp = b;
80102881:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102884:	8b 55 08             	mov    0x8(%ebp),%edx
80102887:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102889:	a1 34 b6 10 80       	mov    0x8010b634,%eax
8010288e:	3b 45 08             	cmp    0x8(%ebp),%eax
80102891:	75 22                	jne    801028b5 <iderw+0xbd>
    idestart(b);
80102893:	8b 45 08             	mov    0x8(%ebp),%eax
80102896:	89 04 24             	mov    %eax,(%esp)
80102899:	e8 72 fd ff ff       	call   80102610 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010289e:	eb 15                	jmp    801028b5 <iderw+0xbd>
    sleep(b, &idelock);
801028a0:	c7 44 24 04 00 b6 10 	movl   $0x8010b600,0x4(%esp)
801028a7:	80 
801028a8:	8b 45 08             	mov    0x8(%ebp),%eax
801028ab:	89 04 24             	mov    %eax,(%esp)
801028ae:	e8 b3 1f 00 00       	call   80104866 <sleep>
801028b3:	eb 01                	jmp    801028b6 <iderw+0xbe>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801028b5:	90                   	nop
801028b6:	8b 45 08             	mov    0x8(%ebp),%eax
801028b9:	8b 00                	mov    (%eax),%eax
801028bb:	83 e0 06             	and    $0x6,%eax
801028be:	83 f8 02             	cmp    $0x2,%eax
801028c1:	75 dd                	jne    801028a0 <iderw+0xa8>
    sleep(b, &idelock);
  }

  release(&idelock);
801028c3:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801028ca:	e8 d6 22 00 00       	call   80104ba5 <release>
}
801028cf:	c9                   	leave  
801028d0:	c3                   	ret    
801028d1:	66 90                	xchg   %ax,%ax
801028d3:	90                   	nop

801028d4 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
801028d4:	55                   	push   %ebp
801028d5:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801028d7:	a1 34 f8 10 80       	mov    0x8010f834,%eax
801028dc:	8b 55 08             	mov    0x8(%ebp),%edx
801028df:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
801028e1:	a1 34 f8 10 80       	mov    0x8010f834,%eax
801028e6:	8b 40 10             	mov    0x10(%eax),%eax
}
801028e9:	5d                   	pop    %ebp
801028ea:	c3                   	ret    

801028eb <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
801028eb:	55                   	push   %ebp
801028ec:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801028ee:	a1 34 f8 10 80       	mov    0x8010f834,%eax
801028f3:	8b 55 08             	mov    0x8(%ebp),%edx
801028f6:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
801028f8:	a1 34 f8 10 80       	mov    0x8010f834,%eax
801028fd:	8b 55 0c             	mov    0xc(%ebp),%edx
80102900:	89 50 10             	mov    %edx,0x10(%eax)
}
80102903:	5d                   	pop    %ebp
80102904:	c3                   	ret    

80102905 <ioapicinit>:

void
ioapicinit(void)
{
80102905:	55                   	push   %ebp
80102906:	89 e5                	mov    %esp,%ebp
80102908:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
8010290b:	a1 04 f9 10 80       	mov    0x8010f904,%eax
80102910:	85 c0                	test   %eax,%eax
80102912:	0f 84 9f 00 00 00    	je     801029b7 <ioapicinit+0xb2>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102918:	c7 05 34 f8 10 80 00 	movl   $0xfec00000,0x8010f834
8010291f:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102922:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102929:	e8 a6 ff ff ff       	call   801028d4 <ioapicread>
8010292e:	c1 e8 10             	shr    $0x10,%eax
80102931:	25 ff 00 00 00       	and    $0xff,%eax
80102936:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102939:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102940:	e8 8f ff ff ff       	call   801028d4 <ioapicread>
80102945:	c1 e8 18             	shr    $0x18,%eax
80102948:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
8010294b:	0f b6 05 00 f9 10 80 	movzbl 0x8010f900,%eax
80102952:	0f b6 c0             	movzbl %al,%eax
80102955:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102958:	74 0c                	je     80102966 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
8010295a:	c7 04 24 44 83 10 80 	movl   $0x80108344,(%esp)
80102961:	e8 44 da ff ff       	call   801003aa <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102966:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010296d:	eb 3e                	jmp    801029ad <ioapicinit+0xa8>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
8010296f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102972:	83 c0 20             	add    $0x20,%eax
80102975:	0d 00 00 01 00       	or     $0x10000,%eax
8010297a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010297d:	83 c2 08             	add    $0x8,%edx
80102980:	01 d2                	add    %edx,%edx
80102982:	89 44 24 04          	mov    %eax,0x4(%esp)
80102986:	89 14 24             	mov    %edx,(%esp)
80102989:	e8 5d ff ff ff       	call   801028eb <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
8010298e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102991:	83 c0 08             	add    $0x8,%eax
80102994:	01 c0                	add    %eax,%eax
80102996:	83 c0 01             	add    $0x1,%eax
80102999:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801029a0:	00 
801029a1:	89 04 24             	mov    %eax,(%esp)
801029a4:	e8 42 ff ff ff       	call   801028eb <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801029a9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801029ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029b0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801029b3:	7e ba                	jle    8010296f <ioapicinit+0x6a>
801029b5:	eb 01                	jmp    801029b8 <ioapicinit+0xb3>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
801029b7:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
801029b8:	c9                   	leave  
801029b9:	c3                   	ret    

801029ba <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
801029ba:	55                   	push   %ebp
801029bb:	89 e5                	mov    %esp,%ebp
801029bd:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
801029c0:	a1 04 f9 10 80       	mov    0x8010f904,%eax
801029c5:	85 c0                	test   %eax,%eax
801029c7:	74 39                	je     80102a02 <ioapicenable+0x48>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
801029c9:	8b 45 08             	mov    0x8(%ebp),%eax
801029cc:	83 c0 20             	add    $0x20,%eax
801029cf:	8b 55 08             	mov    0x8(%ebp),%edx
801029d2:	83 c2 08             	add    $0x8,%edx
801029d5:	01 d2                	add    %edx,%edx
801029d7:	89 44 24 04          	mov    %eax,0x4(%esp)
801029db:	89 14 24             	mov    %edx,(%esp)
801029de:	e8 08 ff ff ff       	call   801028eb <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801029e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801029e6:	c1 e0 18             	shl    $0x18,%eax
801029e9:	8b 55 08             	mov    0x8(%ebp),%edx
801029ec:	83 c2 08             	add    $0x8,%edx
801029ef:	01 d2                	add    %edx,%edx
801029f1:	83 c2 01             	add    $0x1,%edx
801029f4:	89 44 24 04          	mov    %eax,0x4(%esp)
801029f8:	89 14 24             	mov    %edx,(%esp)
801029fb:	e8 eb fe ff ff       	call   801028eb <ioapicwrite>
80102a00:	eb 01                	jmp    80102a03 <ioapicenable+0x49>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102a02:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102a03:	c9                   	leave  
80102a04:	c3                   	ret    
80102a05:	66 90                	xchg   %ax,%ax
80102a07:	90                   	nop

80102a08 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102a08:	55                   	push   %ebp
80102a09:	89 e5                	mov    %esp,%ebp
80102a0b:	8b 45 08             	mov    0x8(%ebp),%eax
80102a0e:	05 00 00 00 80       	add    $0x80000000,%eax
80102a13:	5d                   	pop    %ebp
80102a14:	c3                   	ret    

80102a15 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102a15:	55                   	push   %ebp
80102a16:	89 e5                	mov    %esp,%ebp
80102a18:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102a1b:	c7 44 24 04 76 83 10 	movl   $0x80108376,0x4(%esp)
80102a22:	80 
80102a23:	c7 04 24 40 f8 10 80 	movl   $0x8010f840,(%esp)
80102a2a:	e8 f3 20 00 00       	call   80104b22 <initlock>
  kmem.use_lock = 0;
80102a2f:	c7 05 74 f8 10 80 00 	movl   $0x0,0x8010f874
80102a36:	00 00 00 
  freerange(vstart, vend);
80102a39:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a3c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a40:	8b 45 08             	mov    0x8(%ebp),%eax
80102a43:	89 04 24             	mov    %eax,(%esp)
80102a46:	e8 26 00 00 00       	call   80102a71 <freerange>
}
80102a4b:	c9                   	leave  
80102a4c:	c3                   	ret    

80102a4d <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102a4d:	55                   	push   %ebp
80102a4e:	89 e5                	mov    %esp,%ebp
80102a50:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102a53:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a56:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a5a:	8b 45 08             	mov    0x8(%ebp),%eax
80102a5d:	89 04 24             	mov    %eax,(%esp)
80102a60:	e8 0c 00 00 00       	call   80102a71 <freerange>
  kmem.use_lock = 1;
80102a65:	c7 05 74 f8 10 80 01 	movl   $0x1,0x8010f874
80102a6c:	00 00 00 
}
80102a6f:	c9                   	leave  
80102a70:	c3                   	ret    

80102a71 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102a71:	55                   	push   %ebp
80102a72:	89 e5                	mov    %esp,%ebp
80102a74:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102a77:	8b 45 08             	mov    0x8(%ebp),%eax
80102a7a:	05 ff 0f 00 00       	add    $0xfff,%eax
80102a7f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102a84:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a87:	eb 12                	jmp    80102a9b <freerange+0x2a>
    kfree(p);
80102a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a8c:	89 04 24             	mov    %eax,(%esp)
80102a8f:	e8 16 00 00 00       	call   80102aaa <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a94:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102a9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a9e:	05 00 10 00 00       	add    $0x1000,%eax
80102aa3:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102aa6:	76 e1                	jbe    80102a89 <freerange+0x18>
    kfree(p);
}
80102aa8:	c9                   	leave  
80102aa9:	c3                   	ret    

80102aaa <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102aaa:	55                   	push   %ebp
80102aab:	89 e5                	mov    %esp,%ebp
80102aad:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102ab0:	8b 45 08             	mov    0x8(%ebp),%eax
80102ab3:	25 ff 0f 00 00       	and    $0xfff,%eax
80102ab8:	85 c0                	test   %eax,%eax
80102aba:	75 1b                	jne    80102ad7 <kfree+0x2d>
80102abc:	81 7d 08 fc 26 11 80 	cmpl   $0x801126fc,0x8(%ebp)
80102ac3:	72 12                	jb     80102ad7 <kfree+0x2d>
80102ac5:	8b 45 08             	mov    0x8(%ebp),%eax
80102ac8:	89 04 24             	mov    %eax,(%esp)
80102acb:	e8 38 ff ff ff       	call   80102a08 <v2p>
80102ad0:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102ad5:	76 0c                	jbe    80102ae3 <kfree+0x39>
    panic("kfree");
80102ad7:	c7 04 24 7b 83 10 80 	movl   $0x8010837b,(%esp)
80102ade:	e8 63 da ff ff       	call   80100546 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102ae3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102aea:	00 
80102aeb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102af2:	00 
80102af3:	8b 45 08             	mov    0x8(%ebp),%eax
80102af6:	89 04 24             	mov    %eax,(%esp)
80102af9:	e8 a0 22 00 00       	call   80104d9e <memset>

  if(kmem.use_lock)
80102afe:	a1 74 f8 10 80       	mov    0x8010f874,%eax
80102b03:	85 c0                	test   %eax,%eax
80102b05:	74 0c                	je     80102b13 <kfree+0x69>
    acquire(&kmem.lock);
80102b07:	c7 04 24 40 f8 10 80 	movl   $0x8010f840,(%esp)
80102b0e:	e8 30 20 00 00       	call   80104b43 <acquire>
  r = (struct run*)v;
80102b13:	8b 45 08             	mov    0x8(%ebp),%eax
80102b16:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102b19:	8b 15 78 f8 10 80    	mov    0x8010f878,%edx
80102b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b22:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102b24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b27:	a3 78 f8 10 80       	mov    %eax,0x8010f878
  if(kmem.use_lock)
80102b2c:	a1 74 f8 10 80       	mov    0x8010f874,%eax
80102b31:	85 c0                	test   %eax,%eax
80102b33:	74 0c                	je     80102b41 <kfree+0x97>
    release(&kmem.lock);
80102b35:	c7 04 24 40 f8 10 80 	movl   $0x8010f840,(%esp)
80102b3c:	e8 64 20 00 00       	call   80104ba5 <release>
}
80102b41:	c9                   	leave  
80102b42:	c3                   	ret    

80102b43 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102b43:	55                   	push   %ebp
80102b44:	89 e5                	mov    %esp,%ebp
80102b46:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102b49:	a1 74 f8 10 80       	mov    0x8010f874,%eax
80102b4e:	85 c0                	test   %eax,%eax
80102b50:	74 0c                	je     80102b5e <kalloc+0x1b>
    acquire(&kmem.lock);
80102b52:	c7 04 24 40 f8 10 80 	movl   $0x8010f840,(%esp)
80102b59:	e8 e5 1f 00 00       	call   80104b43 <acquire>
  r = kmem.freelist;
80102b5e:	a1 78 f8 10 80       	mov    0x8010f878,%eax
80102b63:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102b66:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102b6a:	74 0a                	je     80102b76 <kalloc+0x33>
    kmem.freelist = r->next;
80102b6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b6f:	8b 00                	mov    (%eax),%eax
80102b71:	a3 78 f8 10 80       	mov    %eax,0x8010f878
  if(kmem.use_lock)
80102b76:	a1 74 f8 10 80       	mov    0x8010f874,%eax
80102b7b:	85 c0                	test   %eax,%eax
80102b7d:	74 0c                	je     80102b8b <kalloc+0x48>
    release(&kmem.lock);
80102b7f:	c7 04 24 40 f8 10 80 	movl   $0x8010f840,(%esp)
80102b86:	e8 1a 20 00 00       	call   80104ba5 <release>
  return (char*)r;
80102b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102b8e:	c9                   	leave  
80102b8f:	c3                   	ret    

80102b90 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102b90:	55                   	push   %ebp
80102b91:	89 e5                	mov    %esp,%ebp
80102b93:	53                   	push   %ebx
80102b94:	83 ec 14             	sub    $0x14,%esp
80102b97:	8b 45 08             	mov    0x8(%ebp),%eax
80102b9a:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b9e:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80102ba2:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102ba6:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102baa:	ec                   	in     (%dx),%al
80102bab:	89 c3                	mov    %eax,%ebx
80102bad:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102bb0:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102bb4:	83 c4 14             	add    $0x14,%esp
80102bb7:	5b                   	pop    %ebx
80102bb8:	5d                   	pop    %ebp
80102bb9:	c3                   	ret    

80102bba <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102bba:	55                   	push   %ebp
80102bbb:	89 e5                	mov    %esp,%ebp
80102bbd:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102bc0:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102bc7:	e8 c4 ff ff ff       	call   80102b90 <inb>
80102bcc:	0f b6 c0             	movzbl %al,%eax
80102bcf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bd5:	83 e0 01             	and    $0x1,%eax
80102bd8:	85 c0                	test   %eax,%eax
80102bda:	75 0a                	jne    80102be6 <kbdgetc+0x2c>
    return -1;
80102bdc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102be1:	e9 25 01 00 00       	jmp    80102d0b <kbdgetc+0x151>
  data = inb(KBDATAP);
80102be6:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102bed:	e8 9e ff ff ff       	call   80102b90 <inb>
80102bf2:	0f b6 c0             	movzbl %al,%eax
80102bf5:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102bf8:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102bff:	75 17                	jne    80102c18 <kbdgetc+0x5e>
    shift |= E0ESC;
80102c01:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c06:	83 c8 40             	or     $0x40,%eax
80102c09:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102c0e:	b8 00 00 00 00       	mov    $0x0,%eax
80102c13:	e9 f3 00 00 00       	jmp    80102d0b <kbdgetc+0x151>
  } else if(data & 0x80){
80102c18:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c1b:	25 80 00 00 00       	and    $0x80,%eax
80102c20:	85 c0                	test   %eax,%eax
80102c22:	74 45                	je     80102c69 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102c24:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c29:	83 e0 40             	and    $0x40,%eax
80102c2c:	85 c0                	test   %eax,%eax
80102c2e:	75 08                	jne    80102c38 <kbdgetc+0x7e>
80102c30:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c33:	83 e0 7f             	and    $0x7f,%eax
80102c36:	eb 03                	jmp    80102c3b <kbdgetc+0x81>
80102c38:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c3b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102c3e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c41:	05 20 90 10 80       	add    $0x80109020,%eax
80102c46:	0f b6 00             	movzbl (%eax),%eax
80102c49:	83 c8 40             	or     $0x40,%eax
80102c4c:	0f b6 c0             	movzbl %al,%eax
80102c4f:	f7 d0                	not    %eax
80102c51:	89 c2                	mov    %eax,%edx
80102c53:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c58:	21 d0                	and    %edx,%eax
80102c5a:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102c5f:	b8 00 00 00 00       	mov    $0x0,%eax
80102c64:	e9 a2 00 00 00       	jmp    80102d0b <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102c69:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c6e:	83 e0 40             	and    $0x40,%eax
80102c71:	85 c0                	test   %eax,%eax
80102c73:	74 14                	je     80102c89 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102c75:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102c7c:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c81:	83 e0 bf             	and    $0xffffffbf,%eax
80102c84:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  }

  shift |= shiftcode[data];
80102c89:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c8c:	05 20 90 10 80       	add    $0x80109020,%eax
80102c91:	0f b6 00             	movzbl (%eax),%eax
80102c94:	0f b6 d0             	movzbl %al,%edx
80102c97:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c9c:	09 d0                	or     %edx,%eax
80102c9e:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  shift ^= togglecode[data];
80102ca3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ca6:	05 20 91 10 80       	add    $0x80109120,%eax
80102cab:	0f b6 00             	movzbl (%eax),%eax
80102cae:	0f b6 d0             	movzbl %al,%edx
80102cb1:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102cb6:	31 d0                	xor    %edx,%eax
80102cb8:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102cbd:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102cc2:	83 e0 03             	and    $0x3,%eax
80102cc5:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102ccc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ccf:	01 d0                	add    %edx,%eax
80102cd1:	0f b6 00             	movzbl (%eax),%eax
80102cd4:	0f b6 c0             	movzbl %al,%eax
80102cd7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102cda:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102cdf:	83 e0 08             	and    $0x8,%eax
80102ce2:	85 c0                	test   %eax,%eax
80102ce4:	74 22                	je     80102d08 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102ce6:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102cea:	76 0c                	jbe    80102cf8 <kbdgetc+0x13e>
80102cec:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102cf0:	77 06                	ja     80102cf8 <kbdgetc+0x13e>
      c += 'A' - 'a';
80102cf2:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102cf6:	eb 10                	jmp    80102d08 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102cf8:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102cfc:	76 0a                	jbe    80102d08 <kbdgetc+0x14e>
80102cfe:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102d02:	77 04                	ja     80102d08 <kbdgetc+0x14e>
      c += 'a' - 'A';
80102d04:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102d08:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102d0b:	c9                   	leave  
80102d0c:	c3                   	ret    

80102d0d <kbdintr>:

void
kbdintr(void)
{
80102d0d:	55                   	push   %ebp
80102d0e:	89 e5                	mov    %esp,%ebp
80102d10:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102d13:	c7 04 24 ba 2b 10 80 	movl   $0x80102bba,(%esp)
80102d1a:	e8 97 da ff ff       	call   801007b6 <consoleintr>
}
80102d1f:	c9                   	leave  
80102d20:	c3                   	ret    
80102d21:	66 90                	xchg   %ax,%ax
80102d23:	90                   	nop

80102d24 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102d24:	55                   	push   %ebp
80102d25:	89 e5                	mov    %esp,%ebp
80102d27:	83 ec 08             	sub    $0x8,%esp
80102d2a:	8b 55 08             	mov    0x8(%ebp),%edx
80102d2d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d30:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102d34:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d37:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102d3b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102d3f:	ee                   	out    %al,(%dx)
}
80102d40:	c9                   	leave  
80102d41:	c3                   	ret    

80102d42 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102d42:	55                   	push   %ebp
80102d43:	89 e5                	mov    %esp,%ebp
80102d45:	53                   	push   %ebx
80102d46:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102d49:	9c                   	pushf  
80102d4a:	5b                   	pop    %ebx
80102d4b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80102d4e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102d51:	83 c4 10             	add    $0x10,%esp
80102d54:	5b                   	pop    %ebx
80102d55:	5d                   	pop    %ebp
80102d56:	c3                   	ret    

80102d57 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102d57:	55                   	push   %ebp
80102d58:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102d5a:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102d5f:	8b 55 08             	mov    0x8(%ebp),%edx
80102d62:	c1 e2 02             	shl    $0x2,%edx
80102d65:	01 c2                	add    %eax,%edx
80102d67:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d6a:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102d6c:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102d71:	83 c0 20             	add    $0x20,%eax
80102d74:	8b 00                	mov    (%eax),%eax
}
80102d76:	5d                   	pop    %ebp
80102d77:	c3                   	ret    

80102d78 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102d78:	55                   	push   %ebp
80102d79:	89 e5                	mov    %esp,%ebp
80102d7b:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80102d7e:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102d83:	85 c0                	test   %eax,%eax
80102d85:	0f 84 47 01 00 00    	je     80102ed2 <lapicinit+0x15a>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102d8b:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102d92:	00 
80102d93:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102d9a:	e8 b8 ff ff ff       	call   80102d57 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102d9f:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102da6:	00 
80102da7:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102dae:	e8 a4 ff ff ff       	call   80102d57 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102db3:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102dba:	00 
80102dbb:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102dc2:	e8 90 ff ff ff       	call   80102d57 <lapicw>
  lapicw(TICR, 10000000); 
80102dc7:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102dce:	00 
80102dcf:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102dd6:	e8 7c ff ff ff       	call   80102d57 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102ddb:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102de2:	00 
80102de3:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102dea:	e8 68 ff ff ff       	call   80102d57 <lapicw>
  lapicw(LINT1, MASKED);
80102def:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102df6:	00 
80102df7:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102dfe:	e8 54 ff ff ff       	call   80102d57 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102e03:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102e08:	83 c0 30             	add    $0x30,%eax
80102e0b:	8b 00                	mov    (%eax),%eax
80102e0d:	c1 e8 10             	shr    $0x10,%eax
80102e10:	25 ff 00 00 00       	and    $0xff,%eax
80102e15:	83 f8 03             	cmp    $0x3,%eax
80102e18:	76 14                	jbe    80102e2e <lapicinit+0xb6>
    lapicw(PCINT, MASKED);
80102e1a:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e21:	00 
80102e22:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102e29:	e8 29 ff ff ff       	call   80102d57 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102e2e:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102e35:	00 
80102e36:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102e3d:	e8 15 ff ff ff       	call   80102d57 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102e42:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e49:	00 
80102e4a:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102e51:	e8 01 ff ff ff       	call   80102d57 <lapicw>
  lapicw(ESR, 0);
80102e56:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e5d:	00 
80102e5e:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102e65:	e8 ed fe ff ff       	call   80102d57 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102e6a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e71:	00 
80102e72:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102e79:	e8 d9 fe ff ff       	call   80102d57 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102e7e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e85:	00 
80102e86:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102e8d:	e8 c5 fe ff ff       	call   80102d57 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102e92:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102e99:	00 
80102e9a:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102ea1:	e8 b1 fe ff ff       	call   80102d57 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102ea6:	90                   	nop
80102ea7:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102eac:	05 00 03 00 00       	add    $0x300,%eax
80102eb1:	8b 00                	mov    (%eax),%eax
80102eb3:	25 00 10 00 00       	and    $0x1000,%eax
80102eb8:	85 c0                	test   %eax,%eax
80102eba:	75 eb                	jne    80102ea7 <lapicinit+0x12f>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102ebc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ec3:	00 
80102ec4:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102ecb:	e8 87 fe ff ff       	call   80102d57 <lapicw>
80102ed0:	eb 01                	jmp    80102ed3 <lapicinit+0x15b>

void
lapicinit(void)
{
  if(!lapic) 
    return;
80102ed2:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102ed3:	c9                   	leave  
80102ed4:	c3                   	ret    

80102ed5 <cpunum>:

int
cpunum(void)
{
80102ed5:	55                   	push   %ebp
80102ed6:	89 e5                	mov    %esp,%ebp
80102ed8:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102edb:	e8 62 fe ff ff       	call   80102d42 <readeflags>
80102ee0:	25 00 02 00 00       	and    $0x200,%eax
80102ee5:	85 c0                	test   %eax,%eax
80102ee7:	74 29                	je     80102f12 <cpunum+0x3d>
    static int n;
    if(n++ == 0)
80102ee9:	a1 40 b6 10 80       	mov    0x8010b640,%eax
80102eee:	85 c0                	test   %eax,%eax
80102ef0:	0f 94 c2             	sete   %dl
80102ef3:	83 c0 01             	add    $0x1,%eax
80102ef6:	a3 40 b6 10 80       	mov    %eax,0x8010b640
80102efb:	84 d2                	test   %dl,%dl
80102efd:	74 13                	je     80102f12 <cpunum+0x3d>
      cprintf("cpu called from %x with interrupts enabled\n",
80102eff:	8b 45 04             	mov    0x4(%ebp),%eax
80102f02:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f06:	c7 04 24 84 83 10 80 	movl   $0x80108384,(%esp)
80102f0d:	e8 98 d4 ff ff       	call   801003aa <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80102f12:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102f17:	85 c0                	test   %eax,%eax
80102f19:	74 0f                	je     80102f2a <cpunum+0x55>
    return lapic[ID]>>24;
80102f1b:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102f20:	83 c0 20             	add    $0x20,%eax
80102f23:	8b 00                	mov    (%eax),%eax
80102f25:	c1 e8 18             	shr    $0x18,%eax
80102f28:	eb 05                	jmp    80102f2f <cpunum+0x5a>
  return 0;
80102f2a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102f2f:	c9                   	leave  
80102f30:	c3                   	ret    

80102f31 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102f31:	55                   	push   %ebp
80102f32:	89 e5                	mov    %esp,%ebp
80102f34:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80102f37:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102f3c:	85 c0                	test   %eax,%eax
80102f3e:	74 14                	je     80102f54 <lapiceoi+0x23>
    lapicw(EOI, 0);
80102f40:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f47:	00 
80102f48:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102f4f:	e8 03 fe ff ff       	call   80102d57 <lapicw>
}
80102f54:	c9                   	leave  
80102f55:	c3                   	ret    

80102f56 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102f56:	55                   	push   %ebp
80102f57:	89 e5                	mov    %esp,%ebp
}
80102f59:	5d                   	pop    %ebp
80102f5a:	c3                   	ret    

80102f5b <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102f5b:	55                   	push   %ebp
80102f5c:	89 e5                	mov    %esp,%ebp
80102f5e:	83 ec 1c             	sub    $0x1c,%esp
80102f61:	8b 45 08             	mov    0x8(%ebp),%eax
80102f64:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
80102f67:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80102f6e:	00 
80102f6f:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80102f76:	e8 a9 fd ff ff       	call   80102d24 <outb>
  outb(IO_RTC+1, 0x0A);
80102f7b:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80102f82:	00 
80102f83:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80102f8a:	e8 95 fd ff ff       	call   80102d24 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102f8f:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102f96:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102f99:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102f9e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102fa1:	8d 50 02             	lea    0x2(%eax),%edx
80102fa4:	8b 45 0c             	mov    0xc(%ebp),%eax
80102fa7:	c1 e8 04             	shr    $0x4,%eax
80102faa:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102fad:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102fb1:	c1 e0 18             	shl    $0x18,%eax
80102fb4:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fb8:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102fbf:	e8 93 fd ff ff       	call   80102d57 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102fc4:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80102fcb:	00 
80102fcc:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102fd3:	e8 7f fd ff ff       	call   80102d57 <lapicw>
  microdelay(200);
80102fd8:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102fdf:	e8 72 ff ff ff       	call   80102f56 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80102fe4:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80102feb:	00 
80102fec:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102ff3:	e8 5f fd ff ff       	call   80102d57 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102ff8:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102fff:	e8 52 ff ff ff       	call   80102f56 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103004:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010300b:	eb 40                	jmp    8010304d <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
8010300d:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103011:	c1 e0 18             	shl    $0x18,%eax
80103014:	89 44 24 04          	mov    %eax,0x4(%esp)
80103018:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010301f:	e8 33 fd ff ff       	call   80102d57 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80103024:	8b 45 0c             	mov    0xc(%ebp),%eax
80103027:	c1 e8 0c             	shr    $0xc,%eax
8010302a:	80 cc 06             	or     $0x6,%ah
8010302d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103031:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103038:	e8 1a fd ff ff       	call   80102d57 <lapicw>
    microdelay(200);
8010303d:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103044:	e8 0d ff ff ff       	call   80102f56 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103049:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010304d:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103051:	7e ba                	jle    8010300d <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103053:	c9                   	leave  
80103054:	c3                   	ret    
80103055:	66 90                	xchg   %ax,%ax
80103057:	90                   	nop

80103058 <initlog>:

static void recover_from_log(void);

void
initlog(void)
{
80103058:	55                   	push   %ebp
80103059:	89 e5                	mov    %esp,%ebp
8010305b:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010305e:	c7 44 24 04 b0 83 10 	movl   $0x801083b0,0x4(%esp)
80103065:	80 
80103066:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
8010306d:	e8 b0 1a 00 00       	call   80104b22 <initlock>
  readsb(ROOTDEV, &sb);
80103072:	8d 45 e8             	lea    -0x18(%ebp),%eax
80103075:	89 44 24 04          	mov    %eax,0x4(%esp)
80103079:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103080:	e8 87 e2 ff ff       	call   8010130c <readsb>
  log.start = sb.size - sb.nlog;
80103085:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103088:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010308b:	89 d1                	mov    %edx,%ecx
8010308d:	29 c1                	sub    %eax,%ecx
8010308f:	89 c8                	mov    %ecx,%eax
80103091:	a3 b4 f8 10 80       	mov    %eax,0x8010f8b4
  log.size = sb.nlog;
80103096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103099:	a3 b8 f8 10 80       	mov    %eax,0x8010f8b8
  log.dev = ROOTDEV;
8010309e:	c7 05 c0 f8 10 80 01 	movl   $0x1,0x8010f8c0
801030a5:	00 00 00 
  recover_from_log();
801030a8:	e8 9a 01 00 00       	call   80103247 <recover_from_log>
}
801030ad:	c9                   	leave  
801030ae:	c3                   	ret    

801030af <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
801030af:	55                   	push   %ebp
801030b0:	89 e5                	mov    %esp,%ebp
801030b2:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801030b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801030bc:	e9 8c 00 00 00       	jmp    8010314d <install_trans+0x9e>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801030c1:	8b 15 b4 f8 10 80    	mov    0x8010f8b4,%edx
801030c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030ca:	01 d0                	add    %edx,%eax
801030cc:	83 c0 01             	add    $0x1,%eax
801030cf:	89 c2                	mov    %eax,%edx
801030d1:	a1 c0 f8 10 80       	mov    0x8010f8c0,%eax
801030d6:	89 54 24 04          	mov    %edx,0x4(%esp)
801030da:	89 04 24             	mov    %eax,(%esp)
801030dd:	e8 c4 d0 ff ff       	call   801001a6 <bread>
801030e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
801030e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030e8:	83 c0 10             	add    $0x10,%eax
801030eb:	8b 04 85 88 f8 10 80 	mov    -0x7fef0778(,%eax,4),%eax
801030f2:	89 c2                	mov    %eax,%edx
801030f4:	a1 c0 f8 10 80       	mov    0x8010f8c0,%eax
801030f9:	89 54 24 04          	mov    %edx,0x4(%esp)
801030fd:	89 04 24             	mov    %eax,(%esp)
80103100:	e8 a1 d0 ff ff       	call   801001a6 <bread>
80103105:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103108:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010310b:	8d 50 18             	lea    0x18(%eax),%edx
8010310e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103111:	83 c0 18             	add    $0x18,%eax
80103114:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010311b:	00 
8010311c:	89 54 24 04          	mov    %edx,0x4(%esp)
80103120:	89 04 24             	mov    %eax,(%esp)
80103123:	e8 49 1d 00 00       	call   80104e71 <memmove>
    bwrite(dbuf);  // write dst to disk
80103128:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010312b:	89 04 24             	mov    %eax,(%esp)
8010312e:	e8 aa d0 ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
80103133:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103136:	89 04 24             	mov    %eax,(%esp)
80103139:	e8 d9 d0 ff ff       	call   80100217 <brelse>
    brelse(dbuf);
8010313e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103141:	89 04 24             	mov    %eax,(%esp)
80103144:	e8 ce d0 ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103149:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010314d:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
80103152:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103155:	0f 8f 66 ff ff ff    	jg     801030c1 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
8010315b:	c9                   	leave  
8010315c:	c3                   	ret    

8010315d <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010315d:	55                   	push   %ebp
8010315e:	89 e5                	mov    %esp,%ebp
80103160:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103163:	a1 b4 f8 10 80       	mov    0x8010f8b4,%eax
80103168:	89 c2                	mov    %eax,%edx
8010316a:	a1 c0 f8 10 80       	mov    0x8010f8c0,%eax
8010316f:	89 54 24 04          	mov    %edx,0x4(%esp)
80103173:	89 04 24             	mov    %eax,(%esp)
80103176:	e8 2b d0 ff ff       	call   801001a6 <bread>
8010317b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010317e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103181:	83 c0 18             	add    $0x18,%eax
80103184:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103187:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010318a:	8b 00                	mov    (%eax),%eax
8010318c:	a3 c4 f8 10 80       	mov    %eax,0x8010f8c4
  for (i = 0; i < log.lh.n; i++) {
80103191:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103198:	eb 1b                	jmp    801031b5 <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
8010319a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010319d:	8b 55 f4             	mov    -0xc(%ebp),%edx
801031a0:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801031a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801031a7:	83 c2 10             	add    $0x10,%edx
801031aa:	89 04 95 88 f8 10 80 	mov    %eax,-0x7fef0778(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801031b1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801031b5:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
801031ba:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801031bd:	7f db                	jg     8010319a <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
801031bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031c2:	89 04 24             	mov    %eax,(%esp)
801031c5:	e8 4d d0 ff ff       	call   80100217 <brelse>
}
801031ca:	c9                   	leave  
801031cb:	c3                   	ret    

801031cc <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801031cc:	55                   	push   %ebp
801031cd:	89 e5                	mov    %esp,%ebp
801031cf:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801031d2:	a1 b4 f8 10 80       	mov    0x8010f8b4,%eax
801031d7:	89 c2                	mov    %eax,%edx
801031d9:	a1 c0 f8 10 80       	mov    0x8010f8c0,%eax
801031de:	89 54 24 04          	mov    %edx,0x4(%esp)
801031e2:	89 04 24             	mov    %eax,(%esp)
801031e5:	e8 bc cf ff ff       	call   801001a6 <bread>
801031ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801031ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031f0:	83 c0 18             	add    $0x18,%eax
801031f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801031f6:	8b 15 c4 f8 10 80    	mov    0x8010f8c4,%edx
801031fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031ff:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103201:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103208:	eb 1b                	jmp    80103225 <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
8010320a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010320d:	83 c0 10             	add    $0x10,%eax
80103210:	8b 0c 85 88 f8 10 80 	mov    -0x7fef0778(,%eax,4),%ecx
80103217:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010321a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010321d:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103221:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103225:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
8010322a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010322d:	7f db                	jg     8010320a <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
8010322f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103232:	89 04 24             	mov    %eax,(%esp)
80103235:	e8 a3 cf ff ff       	call   801001dd <bwrite>
  brelse(buf);
8010323a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010323d:	89 04 24             	mov    %eax,(%esp)
80103240:	e8 d2 cf ff ff       	call   80100217 <brelse>
}
80103245:	c9                   	leave  
80103246:	c3                   	ret    

80103247 <recover_from_log>:

static void
recover_from_log(void)
{
80103247:	55                   	push   %ebp
80103248:	89 e5                	mov    %esp,%ebp
8010324a:	83 ec 08             	sub    $0x8,%esp
  read_head();      
8010324d:	e8 0b ff ff ff       	call   8010315d <read_head>
  install_trans(); // if committed, copy from log to disk
80103252:	e8 58 fe ff ff       	call   801030af <install_trans>
  log.lh.n = 0;
80103257:	c7 05 c4 f8 10 80 00 	movl   $0x0,0x8010f8c4
8010325e:	00 00 00 
  write_head(); // clear the log
80103261:	e8 66 ff ff ff       	call   801031cc <write_head>
}
80103266:	c9                   	leave  
80103267:	c3                   	ret    

80103268 <begin_trans>:

void
begin_trans(void)
{
80103268:	55                   	push   %ebp
80103269:	89 e5                	mov    %esp,%ebp
8010326b:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
8010326e:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80103275:	e8 c9 18 00 00       	call   80104b43 <acquire>
  while (log.busy) {
8010327a:	eb 14                	jmp    80103290 <begin_trans+0x28>
    sleep(&log, &log.lock);
8010327c:	c7 44 24 04 80 f8 10 	movl   $0x8010f880,0x4(%esp)
80103283:	80 
80103284:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
8010328b:	e8 d6 15 00 00       	call   80104866 <sleep>

void
begin_trans(void)
{
  acquire(&log.lock);
  while (log.busy) {
80103290:	a1 bc f8 10 80       	mov    0x8010f8bc,%eax
80103295:	85 c0                	test   %eax,%eax
80103297:	75 e3                	jne    8010327c <begin_trans+0x14>
    sleep(&log, &log.lock);
  }
  log.busy = 1;
80103299:	c7 05 bc f8 10 80 01 	movl   $0x1,0x8010f8bc
801032a0:	00 00 00 
  release(&log.lock);
801032a3:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
801032aa:	e8 f6 18 00 00       	call   80104ba5 <release>
}
801032af:	c9                   	leave  
801032b0:	c3                   	ret    

801032b1 <commit_trans>:

void
commit_trans(void)
{
801032b1:	55                   	push   %ebp
801032b2:	89 e5                	mov    %esp,%ebp
801032b4:	83 ec 18             	sub    $0x18,%esp
  if (log.lh.n > 0) {
801032b7:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
801032bc:	85 c0                	test   %eax,%eax
801032be:	7e 19                	jle    801032d9 <commit_trans+0x28>
    write_head();    // Write header to disk -- the real commit
801032c0:	e8 07 ff ff ff       	call   801031cc <write_head>
    install_trans(); // Now install writes to home locations
801032c5:	e8 e5 fd ff ff       	call   801030af <install_trans>
    log.lh.n = 0; 
801032ca:	c7 05 c4 f8 10 80 00 	movl   $0x0,0x8010f8c4
801032d1:	00 00 00 
    write_head();    // Erase the transaction from the log
801032d4:	e8 f3 fe ff ff       	call   801031cc <write_head>
  }
  
  acquire(&log.lock);
801032d9:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
801032e0:	e8 5e 18 00 00       	call   80104b43 <acquire>
  log.busy = 0;
801032e5:	c7 05 bc f8 10 80 00 	movl   $0x0,0x8010f8bc
801032ec:	00 00 00 
  wakeup(&log);
801032ef:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
801032f6:	e8 44 16 00 00       	call   8010493f <wakeup>
  release(&log.lock);
801032fb:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80103302:	e8 9e 18 00 00       	call   80104ba5 <release>
}
80103307:	c9                   	leave  
80103308:	c3                   	ret    

80103309 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103309:	55                   	push   %ebp
8010330a:	89 e5                	mov    %esp,%ebp
8010330c:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010330f:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
80103314:	83 f8 09             	cmp    $0x9,%eax
80103317:	7f 12                	jg     8010332b <log_write+0x22>
80103319:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
8010331e:	8b 15 b8 f8 10 80    	mov    0x8010f8b8,%edx
80103324:	83 ea 01             	sub    $0x1,%edx
80103327:	39 d0                	cmp    %edx,%eax
80103329:	7c 0c                	jl     80103337 <log_write+0x2e>
    panic("too big a transaction");
8010332b:	c7 04 24 b4 83 10 80 	movl   $0x801083b4,(%esp)
80103332:	e8 0f d2 ff ff       	call   80100546 <panic>
  if (!log.busy)
80103337:	a1 bc f8 10 80       	mov    0x8010f8bc,%eax
8010333c:	85 c0                	test   %eax,%eax
8010333e:	75 0c                	jne    8010334c <log_write+0x43>
    panic("write outside of trans");
80103340:	c7 04 24 ca 83 10 80 	movl   $0x801083ca,(%esp)
80103347:	e8 fa d1 ff ff       	call   80100546 <panic>

  for (i = 0; i < log.lh.n; i++) {
8010334c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103353:	eb 1d                	jmp    80103372 <log_write+0x69>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
80103355:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103358:	83 c0 10             	add    $0x10,%eax
8010335b:	8b 04 85 88 f8 10 80 	mov    -0x7fef0778(,%eax,4),%eax
80103362:	89 c2                	mov    %eax,%edx
80103364:	8b 45 08             	mov    0x8(%ebp),%eax
80103367:	8b 40 08             	mov    0x8(%eax),%eax
8010336a:	39 c2                	cmp    %eax,%edx
8010336c:	74 10                	je     8010337e <log_write+0x75>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
  if (!log.busy)
    panic("write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
8010336e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103372:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
80103377:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010337a:	7f d9                	jg     80103355 <log_write+0x4c>
8010337c:	eb 01                	jmp    8010337f <log_write+0x76>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
      break;
8010337e:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
8010337f:	8b 45 08             	mov    0x8(%ebp),%eax
80103382:	8b 40 08             	mov    0x8(%eax),%eax
80103385:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103388:	83 c2 10             	add    $0x10,%edx
8010338b:	89 04 95 88 f8 10 80 	mov    %eax,-0x7fef0778(,%edx,4)
  struct buf *lbuf = bread(b->dev, log.start+i+1);
80103392:	8b 15 b4 f8 10 80    	mov    0x8010f8b4,%edx
80103398:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010339b:	01 d0                	add    %edx,%eax
8010339d:	83 c0 01             	add    $0x1,%eax
801033a0:	89 c2                	mov    %eax,%edx
801033a2:	8b 45 08             	mov    0x8(%ebp),%eax
801033a5:	8b 40 04             	mov    0x4(%eax),%eax
801033a8:	89 54 24 04          	mov    %edx,0x4(%esp)
801033ac:	89 04 24             	mov    %eax,(%esp)
801033af:	e8 f2 cd ff ff       	call   801001a6 <bread>
801033b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(lbuf->data, b->data, BSIZE);
801033b7:	8b 45 08             	mov    0x8(%ebp),%eax
801033ba:	8d 50 18             	lea    0x18(%eax),%edx
801033bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033c0:	83 c0 18             	add    $0x18,%eax
801033c3:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801033ca:	00 
801033cb:	89 54 24 04          	mov    %edx,0x4(%esp)
801033cf:	89 04 24             	mov    %eax,(%esp)
801033d2:	e8 9a 1a 00 00       	call   80104e71 <memmove>
  bwrite(lbuf);
801033d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033da:	89 04 24             	mov    %eax,(%esp)
801033dd:	e8 fb cd ff ff       	call   801001dd <bwrite>
  brelse(lbuf);
801033e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033e5:	89 04 24             	mov    %eax,(%esp)
801033e8:	e8 2a ce ff ff       	call   80100217 <brelse>
  if (i == log.lh.n)
801033ed:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
801033f2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033f5:	75 0d                	jne    80103404 <log_write+0xfb>
    log.lh.n++;
801033f7:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
801033fc:	83 c0 01             	add    $0x1,%eax
801033ff:	a3 c4 f8 10 80       	mov    %eax,0x8010f8c4
  b->flags |= B_DIRTY; // XXX prevent eviction
80103404:	8b 45 08             	mov    0x8(%ebp),%eax
80103407:	8b 00                	mov    (%eax),%eax
80103409:	89 c2                	mov    %eax,%edx
8010340b:	83 ca 04             	or     $0x4,%edx
8010340e:	8b 45 08             	mov    0x8(%ebp),%eax
80103411:	89 10                	mov    %edx,(%eax)
}
80103413:	c9                   	leave  
80103414:	c3                   	ret    
80103415:	66 90                	xchg   %ax,%ax
80103417:	90                   	nop

80103418 <v2p>:
80103418:	55                   	push   %ebp
80103419:	89 e5                	mov    %esp,%ebp
8010341b:	8b 45 08             	mov    0x8(%ebp),%eax
8010341e:	05 00 00 00 80       	add    $0x80000000,%eax
80103423:	5d                   	pop    %ebp
80103424:	c3                   	ret    

80103425 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103425:	55                   	push   %ebp
80103426:	89 e5                	mov    %esp,%ebp
80103428:	8b 45 08             	mov    0x8(%ebp),%eax
8010342b:	05 00 00 00 80       	add    $0x80000000,%eax
80103430:	5d                   	pop    %ebp
80103431:	c3                   	ret    

80103432 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103432:	55                   	push   %ebp
80103433:	89 e5                	mov    %esp,%ebp
80103435:	53                   	push   %ebx
80103436:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80103439:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010343c:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
8010343f:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103442:	89 c3                	mov    %eax,%ebx
80103444:	89 d8                	mov    %ebx,%eax
80103446:	f0 87 02             	lock xchg %eax,(%edx)
80103449:	89 c3                	mov    %eax,%ebx
8010344b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010344e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103451:	83 c4 10             	add    $0x10,%esp
80103454:	5b                   	pop    %ebx
80103455:	5d                   	pop    %ebp
80103456:	c3                   	ret    

80103457 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103457:	55                   	push   %ebp
80103458:	89 e5                	mov    %esp,%ebp
8010345a:	83 e4 f0             	and    $0xfffffff0,%esp
8010345d:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103460:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103467:	80 
80103468:	c7 04 24 fc 26 11 80 	movl   $0x801126fc,(%esp)
8010346f:	e8 a1 f5 ff ff       	call   80102a15 <kinit1>
  kvmalloc();      // kernel page table
80103474:	e8 fb 44 00 00       	call   80107974 <kvmalloc>
  mpinit();        // collect info about this machine
80103479:	e8 57 04 00 00       	call   801038d5 <mpinit>
  lapicinit();
8010347e:	e8 f5 f8 ff ff       	call   80102d78 <lapicinit>
  seginit();       // set up segments
80103483:	e8 81 3e 00 00       	call   80107309 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103488:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010348e:	0f b6 00             	movzbl (%eax),%eax
80103491:	0f b6 c0             	movzbl %al,%eax
80103494:	89 44 24 04          	mov    %eax,0x4(%esp)
80103498:	c7 04 24 e1 83 10 80 	movl   $0x801083e1,(%esp)
8010349f:	e8 06 cf ff ff       	call   801003aa <cprintf>
  picinit();       // interrupt controller
801034a4:	e8 91 06 00 00       	call   80103b3a <picinit>
  ioapicinit();    // another interrupt controller
801034a9:	e8 57 f4 ff ff       	call   80102905 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801034ae:	e8 e5 d5 ff ff       	call   80100a98 <consoleinit>
  uartinit();      // serial port
801034b3:	e8 9c 31 00 00       	call   80106654 <uartinit>
  pinit();         // process table
801034b8:	e8 96 0b 00 00       	call   80104053 <pinit>
  tvinit();        // trap vectors
801034bd:	e8 29 2d 00 00       	call   801061eb <tvinit>
  binit();         // buffer cache
801034c2:	e8 6d cb ff ff       	call   80100034 <binit>
  fileinit();      // file table
801034c7:	e8 54 da ff ff       	call   80100f20 <fileinit>
  iinit();         // inode cache
801034cc:	e8 04 e1 ff ff       	call   801015d5 <iinit>
  ideinit();       // disk
801034d1:	e8 94 f0 ff ff       	call   8010256a <ideinit>
  if(!ismp)
801034d6:	a1 04 f9 10 80       	mov    0x8010f904,%eax
801034db:	85 c0                	test   %eax,%eax
801034dd:	75 05                	jne    801034e4 <main+0x8d>
    timerinit();   // uniprocessor timer
801034df:	e8 4a 2c 00 00       	call   8010612e <timerinit>
  startothers();   // start other processors
801034e4:	e8 7f 00 00 00       	call   80103568 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801034e9:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
801034f0:	8e 
801034f1:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
801034f8:	e8 50 f5 ff ff       	call   80102a4d <kinit2>
  userinit();      // first user process
801034fd:	e8 6c 0c 00 00       	call   8010416e <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103502:	e8 1a 00 00 00       	call   80103521 <mpmain>

80103507 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103507:	55                   	push   %ebp
80103508:	89 e5                	mov    %esp,%ebp
8010350a:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
8010350d:	e8 79 44 00 00       	call   8010798b <switchkvm>
  seginit();
80103512:	e8 f2 3d 00 00       	call   80107309 <seginit>
  lapicinit();
80103517:	e8 5c f8 ff ff       	call   80102d78 <lapicinit>
  mpmain();
8010351c:	e8 00 00 00 00       	call   80103521 <mpmain>

80103521 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103521:	55                   	push   %ebp
80103522:	89 e5                	mov    %esp,%ebp
80103524:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103527:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010352d:	0f b6 00             	movzbl (%eax),%eax
80103530:	0f b6 c0             	movzbl %al,%eax
80103533:	89 44 24 04          	mov    %eax,0x4(%esp)
80103537:	c7 04 24 f8 83 10 80 	movl   $0x801083f8,(%esp)
8010353e:	e8 67 ce ff ff       	call   801003aa <cprintf>
  idtinit();       // load idt register
80103543:	e8 17 2e 00 00       	call   8010635f <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103548:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010354e:	05 a8 00 00 00       	add    $0xa8,%eax
80103553:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010355a:	00 
8010355b:	89 04 24             	mov    %eax,(%esp)
8010355e:	e8 cf fe ff ff       	call   80103432 <xchg>
  scheduler();     // start running processes
80103563:	e8 55 11 00 00       	call   801046bd <scheduler>

80103568 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103568:	55                   	push   %ebp
80103569:	89 e5                	mov    %esp,%ebp
8010356b:	53                   	push   %ebx
8010356c:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
8010356f:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
80103576:	e8 aa fe ff ff       	call   80103425 <p2v>
8010357b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010357e:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103583:	89 44 24 08          	mov    %eax,0x8(%esp)
80103587:	c7 44 24 04 0c b5 10 	movl   $0x8010b50c,0x4(%esp)
8010358e:	80 
8010358f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103592:	89 04 24             	mov    %eax,(%esp)
80103595:	e8 d7 18 00 00       	call   80104e71 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
8010359a:	c7 45 f4 20 f9 10 80 	movl   $0x8010f920,-0xc(%ebp)
801035a1:	e9 86 00 00 00       	jmp    8010362c <startothers+0xc4>
    if(c == cpus+cpunum())  // We've started already.
801035a6:	e8 2a f9 ff ff       	call   80102ed5 <cpunum>
801035ab:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801035b1:	05 20 f9 10 80       	add    $0x8010f920,%eax
801035b6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801035b9:	74 69                	je     80103624 <startothers+0xbc>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801035bb:	e8 83 f5 ff ff       	call   80102b43 <kalloc>
801035c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801035c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035c6:	83 e8 04             	sub    $0x4,%eax
801035c9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801035cc:	81 c2 00 10 00 00    	add    $0x1000,%edx
801035d2:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801035d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035d7:	83 e8 08             	sub    $0x8,%eax
801035da:	c7 00 07 35 10 80    	movl   $0x80103507,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
801035e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035e3:	8d 58 f4             	lea    -0xc(%eax),%ebx
801035e6:	c7 04 24 00 a0 10 80 	movl   $0x8010a000,(%esp)
801035ed:	e8 26 fe ff ff       	call   80103418 <v2p>
801035f2:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
801035f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035f7:	89 04 24             	mov    %eax,(%esp)
801035fa:	e8 19 fe ff ff       	call   80103418 <v2p>
801035ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103602:	0f b6 12             	movzbl (%edx),%edx
80103605:	0f b6 d2             	movzbl %dl,%edx
80103608:	89 44 24 04          	mov    %eax,0x4(%esp)
8010360c:	89 14 24             	mov    %edx,(%esp)
8010360f:	e8 47 f9 ff ff       	call   80102f5b <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103614:	90                   	nop
80103615:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103618:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010361e:	85 c0                	test   %eax,%eax
80103620:	74 f3                	je     80103615 <startothers+0xad>
80103622:	eb 01                	jmp    80103625 <startothers+0xbd>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103624:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103625:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
8010362c:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
80103631:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103637:	05 20 f9 10 80       	add    $0x8010f920,%eax
8010363c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010363f:	0f 87 61 ff ff ff    	ja     801035a6 <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103645:	83 c4 24             	add    $0x24,%esp
80103648:	5b                   	pop    %ebx
80103649:	5d                   	pop    %ebp
8010364a:	c3                   	ret    
8010364b:	90                   	nop

8010364c <p2v>:
8010364c:	55                   	push   %ebp
8010364d:	89 e5                	mov    %esp,%ebp
8010364f:	8b 45 08             	mov    0x8(%ebp),%eax
80103652:	05 00 00 00 80       	add    $0x80000000,%eax
80103657:	5d                   	pop    %ebp
80103658:	c3                   	ret    

80103659 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103659:	55                   	push   %ebp
8010365a:	89 e5                	mov    %esp,%ebp
8010365c:	53                   	push   %ebx
8010365d:	83 ec 14             	sub    $0x14,%esp
80103660:	8b 45 08             	mov    0x8(%ebp),%eax
80103663:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103667:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
8010366b:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
8010366f:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80103673:	ec                   	in     (%dx),%al
80103674:	89 c3                	mov    %eax,%ebx
80103676:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80103679:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
8010367d:	83 c4 14             	add    $0x14,%esp
80103680:	5b                   	pop    %ebx
80103681:	5d                   	pop    %ebp
80103682:	c3                   	ret    

80103683 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103683:	55                   	push   %ebp
80103684:	89 e5                	mov    %esp,%ebp
80103686:	83 ec 08             	sub    $0x8,%esp
80103689:	8b 55 08             	mov    0x8(%ebp),%edx
8010368c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010368f:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103693:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103696:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010369a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010369e:	ee                   	out    %al,(%dx)
}
8010369f:	c9                   	leave  
801036a0:	c3                   	ret    

801036a1 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
801036a1:	55                   	push   %ebp
801036a2:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
801036a4:	a1 44 b6 10 80       	mov    0x8010b644,%eax
801036a9:	89 c2                	mov    %eax,%edx
801036ab:	b8 20 f9 10 80       	mov    $0x8010f920,%eax
801036b0:	89 d1                	mov    %edx,%ecx
801036b2:	29 c1                	sub    %eax,%ecx
801036b4:	89 c8                	mov    %ecx,%eax
801036b6:	c1 f8 02             	sar    $0x2,%eax
801036b9:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
801036bf:	5d                   	pop    %ebp
801036c0:	c3                   	ret    

801036c1 <sum>:

static uchar
sum(uchar *addr, int len)
{
801036c1:	55                   	push   %ebp
801036c2:	89 e5                	mov    %esp,%ebp
801036c4:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
801036c7:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
801036ce:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801036d5:	eb 15                	jmp    801036ec <sum+0x2b>
    sum += addr[i];
801036d7:	8b 55 fc             	mov    -0x4(%ebp),%edx
801036da:	8b 45 08             	mov    0x8(%ebp),%eax
801036dd:	01 d0                	add    %edx,%eax
801036df:	0f b6 00             	movzbl (%eax),%eax
801036e2:	0f b6 c0             	movzbl %al,%eax
801036e5:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
801036e8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801036ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
801036ef:	3b 45 0c             	cmp    0xc(%ebp),%eax
801036f2:	7c e3                	jl     801036d7 <sum+0x16>
    sum += addr[i];
  return sum;
801036f4:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801036f7:	c9                   	leave  
801036f8:	c3                   	ret    

801036f9 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
801036f9:	55                   	push   %ebp
801036fa:	89 e5                	mov    %esp,%ebp
801036fc:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
801036ff:	8b 45 08             	mov    0x8(%ebp),%eax
80103702:	89 04 24             	mov    %eax,(%esp)
80103705:	e8 42 ff ff ff       	call   8010364c <p2v>
8010370a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
8010370d:	8b 55 0c             	mov    0xc(%ebp),%edx
80103710:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103713:	01 d0                	add    %edx,%eax
80103715:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103718:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010371b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010371e:	eb 3f                	jmp    8010375f <mpsearch1+0x66>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103720:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103727:	00 
80103728:	c7 44 24 04 0c 84 10 	movl   $0x8010840c,0x4(%esp)
8010372f:	80 
80103730:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103733:	89 04 24             	mov    %eax,(%esp)
80103736:	e8 da 16 00 00       	call   80104e15 <memcmp>
8010373b:	85 c0                	test   %eax,%eax
8010373d:	75 1c                	jne    8010375b <mpsearch1+0x62>
8010373f:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103746:	00 
80103747:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010374a:	89 04 24             	mov    %eax,(%esp)
8010374d:	e8 6f ff ff ff       	call   801036c1 <sum>
80103752:	84 c0                	test   %al,%al
80103754:	75 05                	jne    8010375b <mpsearch1+0x62>
      return (struct mp*)p;
80103756:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103759:	eb 11                	jmp    8010376c <mpsearch1+0x73>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
8010375b:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010375f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103762:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103765:	72 b9                	jb     80103720 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103767:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010376c:	c9                   	leave  
8010376d:	c3                   	ret    

8010376e <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
8010376e:	55                   	push   %ebp
8010376f:	89 e5                	mov    %esp,%ebp
80103771:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103774:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
8010377b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010377e:	83 c0 0f             	add    $0xf,%eax
80103781:	0f b6 00             	movzbl (%eax),%eax
80103784:	0f b6 c0             	movzbl %al,%eax
80103787:	89 c2                	mov    %eax,%edx
80103789:	c1 e2 08             	shl    $0x8,%edx
8010378c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010378f:	83 c0 0e             	add    $0xe,%eax
80103792:	0f b6 00             	movzbl (%eax),%eax
80103795:	0f b6 c0             	movzbl %al,%eax
80103798:	09 d0                	or     %edx,%eax
8010379a:	c1 e0 04             	shl    $0x4,%eax
8010379d:	89 45 f0             	mov    %eax,-0x10(%ebp)
801037a0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801037a4:	74 21                	je     801037c7 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
801037a6:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
801037ad:	00 
801037ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037b1:	89 04 24             	mov    %eax,(%esp)
801037b4:	e8 40 ff ff ff       	call   801036f9 <mpsearch1>
801037b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
801037bc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801037c0:	74 50                	je     80103812 <mpsearch+0xa4>
      return mp;
801037c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037c5:	eb 5f                	jmp    80103826 <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
801037c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037ca:	83 c0 14             	add    $0x14,%eax
801037cd:	0f b6 00             	movzbl (%eax),%eax
801037d0:	0f b6 c0             	movzbl %al,%eax
801037d3:	89 c2                	mov    %eax,%edx
801037d5:	c1 e2 08             	shl    $0x8,%edx
801037d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037db:	83 c0 13             	add    $0x13,%eax
801037de:	0f b6 00             	movzbl (%eax),%eax
801037e1:	0f b6 c0             	movzbl %al,%eax
801037e4:	09 d0                	or     %edx,%eax
801037e6:	c1 e0 0a             	shl    $0xa,%eax
801037e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
801037ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037ef:	2d 00 04 00 00       	sub    $0x400,%eax
801037f4:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
801037fb:	00 
801037fc:	89 04 24             	mov    %eax,(%esp)
801037ff:	e8 f5 fe ff ff       	call   801036f9 <mpsearch1>
80103804:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103807:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010380b:	74 05                	je     80103812 <mpsearch+0xa4>
      return mp;
8010380d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103810:	eb 14                	jmp    80103826 <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103812:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103819:	00 
8010381a:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103821:	e8 d3 fe ff ff       	call   801036f9 <mpsearch1>
}
80103826:	c9                   	leave  
80103827:	c3                   	ret    

80103828 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103828:	55                   	push   %ebp
80103829:	89 e5                	mov    %esp,%ebp
8010382b:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
8010382e:	e8 3b ff ff ff       	call   8010376e <mpsearch>
80103833:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103836:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010383a:	74 0a                	je     80103846 <mpconfig+0x1e>
8010383c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010383f:	8b 40 04             	mov    0x4(%eax),%eax
80103842:	85 c0                	test   %eax,%eax
80103844:	75 0a                	jne    80103850 <mpconfig+0x28>
    return 0;
80103846:	b8 00 00 00 00       	mov    $0x0,%eax
8010384b:	e9 83 00 00 00       	jmp    801038d3 <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103850:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103853:	8b 40 04             	mov    0x4(%eax),%eax
80103856:	89 04 24             	mov    %eax,(%esp)
80103859:	e8 ee fd ff ff       	call   8010364c <p2v>
8010385e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103861:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103868:	00 
80103869:	c7 44 24 04 11 84 10 	movl   $0x80108411,0x4(%esp)
80103870:	80 
80103871:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103874:	89 04 24             	mov    %eax,(%esp)
80103877:	e8 99 15 00 00       	call   80104e15 <memcmp>
8010387c:	85 c0                	test   %eax,%eax
8010387e:	74 07                	je     80103887 <mpconfig+0x5f>
    return 0;
80103880:	b8 00 00 00 00       	mov    $0x0,%eax
80103885:	eb 4c                	jmp    801038d3 <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103887:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010388a:	0f b6 40 06          	movzbl 0x6(%eax),%eax
8010388e:	3c 01                	cmp    $0x1,%al
80103890:	74 12                	je     801038a4 <mpconfig+0x7c>
80103892:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103895:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103899:	3c 04                	cmp    $0x4,%al
8010389b:	74 07                	je     801038a4 <mpconfig+0x7c>
    return 0;
8010389d:	b8 00 00 00 00       	mov    $0x0,%eax
801038a2:	eb 2f                	jmp    801038d3 <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
801038a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038a7:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801038ab:	0f b7 c0             	movzwl %ax,%eax
801038ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801038b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038b5:	89 04 24             	mov    %eax,(%esp)
801038b8:	e8 04 fe ff ff       	call   801036c1 <sum>
801038bd:	84 c0                	test   %al,%al
801038bf:	74 07                	je     801038c8 <mpconfig+0xa0>
    return 0;
801038c1:	b8 00 00 00 00       	mov    $0x0,%eax
801038c6:	eb 0b                	jmp    801038d3 <mpconfig+0xab>
  *pmp = mp;
801038c8:	8b 45 08             	mov    0x8(%ebp),%eax
801038cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801038ce:	89 10                	mov    %edx,(%eax)
  return conf;
801038d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801038d3:	c9                   	leave  
801038d4:	c3                   	ret    

801038d5 <mpinit>:

void
mpinit(void)
{
801038d5:	55                   	push   %ebp
801038d6:	89 e5                	mov    %esp,%ebp
801038d8:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
801038db:	c7 05 44 b6 10 80 20 	movl   $0x8010f920,0x8010b644
801038e2:	f9 10 80 
  if((conf = mpconfig(&mp)) == 0)
801038e5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801038e8:	89 04 24             	mov    %eax,(%esp)
801038eb:	e8 38 ff ff ff       	call   80103828 <mpconfig>
801038f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801038f3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801038f7:	0f 84 9c 01 00 00    	je     80103a99 <mpinit+0x1c4>
    return;
  ismp = 1;
801038fd:	c7 05 04 f9 10 80 01 	movl   $0x1,0x8010f904
80103904:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103907:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010390a:	8b 40 24             	mov    0x24(%eax),%eax
8010390d:	a3 7c f8 10 80       	mov    %eax,0x8010f87c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103912:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103915:	83 c0 2c             	add    $0x2c,%eax
80103918:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010391b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010391e:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103922:	0f b7 d0             	movzwl %ax,%edx
80103925:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103928:	01 d0                	add    %edx,%eax
8010392a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010392d:	e9 f4 00 00 00       	jmp    80103a26 <mpinit+0x151>
    switch(*p){
80103932:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103935:	0f b6 00             	movzbl (%eax),%eax
80103938:	0f b6 c0             	movzbl %al,%eax
8010393b:	83 f8 04             	cmp    $0x4,%eax
8010393e:	0f 87 bf 00 00 00    	ja     80103a03 <mpinit+0x12e>
80103944:	8b 04 85 54 84 10 80 	mov    -0x7fef7bac(,%eax,4),%eax
8010394b:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
8010394d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103950:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103953:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103956:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010395a:	0f b6 d0             	movzbl %al,%edx
8010395d:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
80103962:	39 c2                	cmp    %eax,%edx
80103964:	74 2d                	je     80103993 <mpinit+0xbe>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103966:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103969:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010396d:	0f b6 d0             	movzbl %al,%edx
80103970:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
80103975:	89 54 24 08          	mov    %edx,0x8(%esp)
80103979:	89 44 24 04          	mov    %eax,0x4(%esp)
8010397d:	c7 04 24 16 84 10 80 	movl   $0x80108416,(%esp)
80103984:	e8 21 ca ff ff       	call   801003aa <cprintf>
        ismp = 0;
80103989:	c7 05 04 f9 10 80 00 	movl   $0x0,0x8010f904
80103990:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103993:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103996:	0f b6 40 03          	movzbl 0x3(%eax),%eax
8010399a:	0f b6 c0             	movzbl %al,%eax
8010399d:	83 e0 02             	and    $0x2,%eax
801039a0:	85 c0                	test   %eax,%eax
801039a2:	74 15                	je     801039b9 <mpinit+0xe4>
        bcpu = &cpus[ncpu];
801039a4:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
801039a9:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801039af:	05 20 f9 10 80       	add    $0x8010f920,%eax
801039b4:	a3 44 b6 10 80       	mov    %eax,0x8010b644
      cpus[ncpu].id = ncpu;
801039b9:	8b 15 00 ff 10 80    	mov    0x8010ff00,%edx
801039bf:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
801039c4:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
801039ca:	81 c2 20 f9 10 80    	add    $0x8010f920,%edx
801039d0:	88 02                	mov    %al,(%edx)
      ncpu++;
801039d2:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
801039d7:	83 c0 01             	add    $0x1,%eax
801039da:	a3 00 ff 10 80       	mov    %eax,0x8010ff00
      p += sizeof(struct mpproc);
801039df:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
801039e3:	eb 41                	jmp    80103a26 <mpinit+0x151>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
801039e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
801039eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801039ee:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801039f2:	a2 00 f9 10 80       	mov    %al,0x8010f900
      p += sizeof(struct mpioapic);
801039f7:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
801039fb:	eb 29                	jmp    80103a26 <mpinit+0x151>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
801039fd:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103a01:	eb 23                	jmp    80103a26 <mpinit+0x151>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a06:	0f b6 00             	movzbl (%eax),%eax
80103a09:	0f b6 c0             	movzbl %al,%eax
80103a0c:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a10:	c7 04 24 34 84 10 80 	movl   $0x80108434,(%esp)
80103a17:	e8 8e c9 ff ff       	call   801003aa <cprintf>
      ismp = 0;
80103a1c:	c7 05 04 f9 10 80 00 	movl   $0x0,0x8010f904
80103a23:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a29:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103a2c:	0f 82 00 ff ff ff    	jb     80103932 <mpinit+0x5d>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103a32:	a1 04 f9 10 80       	mov    0x8010f904,%eax
80103a37:	85 c0                	test   %eax,%eax
80103a39:	75 1d                	jne    80103a58 <mpinit+0x183>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103a3b:	c7 05 00 ff 10 80 01 	movl   $0x1,0x8010ff00
80103a42:	00 00 00 
    lapic = 0;
80103a45:	c7 05 7c f8 10 80 00 	movl   $0x0,0x8010f87c
80103a4c:	00 00 00 
    ioapicid = 0;
80103a4f:	c6 05 00 f9 10 80 00 	movb   $0x0,0x8010f900
80103a56:	eb 41                	jmp    80103a99 <mpinit+0x1c4>
    return;
  }

  if(mp->imcrp){
80103a58:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103a5b:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103a5f:	84 c0                	test   %al,%al
80103a61:	74 36                	je     80103a99 <mpinit+0x1c4>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103a63:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103a6a:	00 
80103a6b:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103a72:	e8 0c fc ff ff       	call   80103683 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103a77:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103a7e:	e8 d6 fb ff ff       	call   80103659 <inb>
80103a83:	83 c8 01             	or     $0x1,%eax
80103a86:	0f b6 c0             	movzbl %al,%eax
80103a89:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a8d:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103a94:	e8 ea fb ff ff       	call   80103683 <outb>
  }
}
80103a99:	c9                   	leave  
80103a9a:	c3                   	ret    
80103a9b:	90                   	nop

80103a9c <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103a9c:	55                   	push   %ebp
80103a9d:	89 e5                	mov    %esp,%ebp
80103a9f:	83 ec 08             	sub    $0x8,%esp
80103aa2:	8b 55 08             	mov    0x8(%ebp),%edx
80103aa5:	8b 45 0c             	mov    0xc(%ebp),%eax
80103aa8:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103aac:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103aaf:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103ab3:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103ab7:	ee                   	out    %al,(%dx)
}
80103ab8:	c9                   	leave  
80103ab9:	c3                   	ret    

80103aba <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103aba:	55                   	push   %ebp
80103abb:	89 e5                	mov    %esp,%ebp
80103abd:	83 ec 0c             	sub    $0xc,%esp
80103ac0:	8b 45 08             	mov    0x8(%ebp),%eax
80103ac3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103ac7:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103acb:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103ad1:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103ad5:	0f b6 c0             	movzbl %al,%eax
80103ad8:	89 44 24 04          	mov    %eax,0x4(%esp)
80103adc:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103ae3:	e8 b4 ff ff ff       	call   80103a9c <outb>
  outb(IO_PIC2+1, mask >> 8);
80103ae8:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103aec:	66 c1 e8 08          	shr    $0x8,%ax
80103af0:	0f b6 c0             	movzbl %al,%eax
80103af3:	89 44 24 04          	mov    %eax,0x4(%esp)
80103af7:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103afe:	e8 99 ff ff ff       	call   80103a9c <outb>
}
80103b03:	c9                   	leave  
80103b04:	c3                   	ret    

80103b05 <picenable>:

void
picenable(int irq)
{
80103b05:	55                   	push   %ebp
80103b06:	89 e5                	mov    %esp,%ebp
80103b08:	53                   	push   %ebx
80103b09:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103b0c:	8b 45 08             	mov    0x8(%ebp),%eax
80103b0f:	ba 01 00 00 00       	mov    $0x1,%edx
80103b14:	89 d3                	mov    %edx,%ebx
80103b16:	89 c1                	mov    %eax,%ecx
80103b18:	d3 e3                	shl    %cl,%ebx
80103b1a:	89 d8                	mov    %ebx,%eax
80103b1c:	89 c2                	mov    %eax,%edx
80103b1e:	f7 d2                	not    %edx
80103b20:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103b27:	21 d0                	and    %edx,%eax
80103b29:	0f b7 c0             	movzwl %ax,%eax
80103b2c:	89 04 24             	mov    %eax,(%esp)
80103b2f:	e8 86 ff ff ff       	call   80103aba <picsetmask>
}
80103b34:	83 c4 04             	add    $0x4,%esp
80103b37:	5b                   	pop    %ebx
80103b38:	5d                   	pop    %ebp
80103b39:	c3                   	ret    

80103b3a <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103b3a:	55                   	push   %ebp
80103b3b:	89 e5                	mov    %esp,%ebp
80103b3d:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103b40:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103b47:	00 
80103b48:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103b4f:	e8 48 ff ff ff       	call   80103a9c <outb>
  outb(IO_PIC2+1, 0xFF);
80103b54:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103b5b:	00 
80103b5c:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103b63:	e8 34 ff ff ff       	call   80103a9c <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103b68:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103b6f:	00 
80103b70:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103b77:	e8 20 ff ff ff       	call   80103a9c <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103b7c:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103b83:	00 
80103b84:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103b8b:	e8 0c ff ff ff       	call   80103a9c <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103b90:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103b97:	00 
80103b98:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103b9f:	e8 f8 fe ff ff       	call   80103a9c <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103ba4:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103bab:	00 
80103bac:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103bb3:	e8 e4 fe ff ff       	call   80103a9c <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103bb8:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103bbf:	00 
80103bc0:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103bc7:	e8 d0 fe ff ff       	call   80103a9c <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103bcc:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103bd3:	00 
80103bd4:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103bdb:	e8 bc fe ff ff       	call   80103a9c <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103be0:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103be7:	00 
80103be8:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103bef:	e8 a8 fe ff ff       	call   80103a9c <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103bf4:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103bfb:	00 
80103bfc:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103c03:	e8 94 fe ff ff       	call   80103a9c <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103c08:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103c0f:	00 
80103c10:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103c17:	e8 80 fe ff ff       	call   80103a9c <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103c1c:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103c23:	00 
80103c24:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103c2b:	e8 6c fe ff ff       	call   80103a9c <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103c30:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103c37:	00 
80103c38:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103c3f:	e8 58 fe ff ff       	call   80103a9c <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103c44:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103c4b:	00 
80103c4c:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103c53:	e8 44 fe ff ff       	call   80103a9c <outb>

  if(irqmask != 0xFFFF)
80103c58:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103c5f:	66 83 f8 ff          	cmp    $0xffff,%ax
80103c63:	74 12                	je     80103c77 <picinit+0x13d>
    picsetmask(irqmask);
80103c65:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103c6c:	0f b7 c0             	movzwl %ax,%eax
80103c6f:	89 04 24             	mov    %eax,(%esp)
80103c72:	e8 43 fe ff ff       	call   80103aba <picsetmask>
}
80103c77:	c9                   	leave  
80103c78:	c3                   	ret    
80103c79:	66 90                	xchg   %ax,%ax
80103c7b:	90                   	nop

80103c7c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103c7c:	55                   	push   %ebp
80103c7d:	89 e5                	mov    %esp,%ebp
80103c7f:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103c82:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103c89:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c8c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103c92:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c95:	8b 10                	mov    (%eax),%edx
80103c97:	8b 45 08             	mov    0x8(%ebp),%eax
80103c9a:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103c9c:	e8 9b d2 ff ff       	call   80100f3c <filealloc>
80103ca1:	8b 55 08             	mov    0x8(%ebp),%edx
80103ca4:	89 02                	mov    %eax,(%edx)
80103ca6:	8b 45 08             	mov    0x8(%ebp),%eax
80103ca9:	8b 00                	mov    (%eax),%eax
80103cab:	85 c0                	test   %eax,%eax
80103cad:	0f 84 c8 00 00 00    	je     80103d7b <pipealloc+0xff>
80103cb3:	e8 84 d2 ff ff       	call   80100f3c <filealloc>
80103cb8:	8b 55 0c             	mov    0xc(%ebp),%edx
80103cbb:	89 02                	mov    %eax,(%edx)
80103cbd:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cc0:	8b 00                	mov    (%eax),%eax
80103cc2:	85 c0                	test   %eax,%eax
80103cc4:	0f 84 b1 00 00 00    	je     80103d7b <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103cca:	e8 74 ee ff ff       	call   80102b43 <kalloc>
80103ccf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cd2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103cd6:	0f 84 9e 00 00 00    	je     80103d7a <pipealloc+0xfe>
    goto bad;
  p->readopen = 1;
80103cdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cdf:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103ce6:	00 00 00 
  p->writeopen = 1;
80103ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cec:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103cf3:	00 00 00 
  p->nwrite = 0;
80103cf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cf9:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103d00:	00 00 00 
  p->nread = 0;
80103d03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d06:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103d0d:	00 00 00 
  initlock(&p->lock, "pipe");
80103d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d13:	c7 44 24 04 68 84 10 	movl   $0x80108468,0x4(%esp)
80103d1a:	80 
80103d1b:	89 04 24             	mov    %eax,(%esp)
80103d1e:	e8 ff 0d 00 00       	call   80104b22 <initlock>
  (*f0)->type = FD_PIPE;
80103d23:	8b 45 08             	mov    0x8(%ebp),%eax
80103d26:	8b 00                	mov    (%eax),%eax
80103d28:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103d2e:	8b 45 08             	mov    0x8(%ebp),%eax
80103d31:	8b 00                	mov    (%eax),%eax
80103d33:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103d37:	8b 45 08             	mov    0x8(%ebp),%eax
80103d3a:	8b 00                	mov    (%eax),%eax
80103d3c:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103d40:	8b 45 08             	mov    0x8(%ebp),%eax
80103d43:	8b 00                	mov    (%eax),%eax
80103d45:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d48:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103d4b:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d4e:	8b 00                	mov    (%eax),%eax
80103d50:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103d56:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d59:	8b 00                	mov    (%eax),%eax
80103d5b:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103d5f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d62:	8b 00                	mov    (%eax),%eax
80103d64:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103d68:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d6b:	8b 00                	mov    (%eax),%eax
80103d6d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d70:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103d73:	b8 00 00 00 00       	mov    $0x0,%eax
80103d78:	eb 43                	jmp    80103dbd <pipealloc+0x141>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80103d7a:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80103d7b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d7f:	74 0b                	je     80103d8c <pipealloc+0x110>
    kfree((char*)p);
80103d81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d84:	89 04 24             	mov    %eax,(%esp)
80103d87:	e8 1e ed ff ff       	call   80102aaa <kfree>
  if(*f0)
80103d8c:	8b 45 08             	mov    0x8(%ebp),%eax
80103d8f:	8b 00                	mov    (%eax),%eax
80103d91:	85 c0                	test   %eax,%eax
80103d93:	74 0d                	je     80103da2 <pipealloc+0x126>
    fileclose(*f0);
80103d95:	8b 45 08             	mov    0x8(%ebp),%eax
80103d98:	8b 00                	mov    (%eax),%eax
80103d9a:	89 04 24             	mov    %eax,(%esp)
80103d9d:	e8 42 d2 ff ff       	call   80100fe4 <fileclose>
  if(*f1)
80103da2:	8b 45 0c             	mov    0xc(%ebp),%eax
80103da5:	8b 00                	mov    (%eax),%eax
80103da7:	85 c0                	test   %eax,%eax
80103da9:	74 0d                	je     80103db8 <pipealloc+0x13c>
    fileclose(*f1);
80103dab:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dae:	8b 00                	mov    (%eax),%eax
80103db0:	89 04 24             	mov    %eax,(%esp)
80103db3:	e8 2c d2 ff ff       	call   80100fe4 <fileclose>
  return -1;
80103db8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103dbd:	c9                   	leave  
80103dbe:	c3                   	ret    

80103dbf <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103dbf:	55                   	push   %ebp
80103dc0:	89 e5                	mov    %esp,%ebp
80103dc2:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80103dc5:	8b 45 08             	mov    0x8(%ebp),%eax
80103dc8:	89 04 24             	mov    %eax,(%esp)
80103dcb:	e8 73 0d 00 00       	call   80104b43 <acquire>
  if(writable){
80103dd0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103dd4:	74 1f                	je     80103df5 <pipeclose+0x36>
    p->writeopen = 0;
80103dd6:	8b 45 08             	mov    0x8(%ebp),%eax
80103dd9:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103de0:	00 00 00 
    wakeup(&p->nread);
80103de3:	8b 45 08             	mov    0x8(%ebp),%eax
80103de6:	05 34 02 00 00       	add    $0x234,%eax
80103deb:	89 04 24             	mov    %eax,(%esp)
80103dee:	e8 4c 0b 00 00       	call   8010493f <wakeup>
80103df3:	eb 1d                	jmp    80103e12 <pipeclose+0x53>
  } else {
    p->readopen = 0;
80103df5:	8b 45 08             	mov    0x8(%ebp),%eax
80103df8:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103dff:	00 00 00 
    wakeup(&p->nwrite);
80103e02:	8b 45 08             	mov    0x8(%ebp),%eax
80103e05:	05 38 02 00 00       	add    $0x238,%eax
80103e0a:	89 04 24             	mov    %eax,(%esp)
80103e0d:	e8 2d 0b 00 00       	call   8010493f <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103e12:	8b 45 08             	mov    0x8(%ebp),%eax
80103e15:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103e1b:	85 c0                	test   %eax,%eax
80103e1d:	75 25                	jne    80103e44 <pipeclose+0x85>
80103e1f:	8b 45 08             	mov    0x8(%ebp),%eax
80103e22:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103e28:	85 c0                	test   %eax,%eax
80103e2a:	75 18                	jne    80103e44 <pipeclose+0x85>
    release(&p->lock);
80103e2c:	8b 45 08             	mov    0x8(%ebp),%eax
80103e2f:	89 04 24             	mov    %eax,(%esp)
80103e32:	e8 6e 0d 00 00       	call   80104ba5 <release>
    kfree((char*)p);
80103e37:	8b 45 08             	mov    0x8(%ebp),%eax
80103e3a:	89 04 24             	mov    %eax,(%esp)
80103e3d:	e8 68 ec ff ff       	call   80102aaa <kfree>
80103e42:	eb 0b                	jmp    80103e4f <pipeclose+0x90>
  } else
    release(&p->lock);
80103e44:	8b 45 08             	mov    0x8(%ebp),%eax
80103e47:	89 04 24             	mov    %eax,(%esp)
80103e4a:	e8 56 0d 00 00       	call   80104ba5 <release>
}
80103e4f:	c9                   	leave  
80103e50:	c3                   	ret    

80103e51 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103e51:	55                   	push   %ebp
80103e52:	89 e5                	mov    %esp,%ebp
80103e54:	53                   	push   %ebx
80103e55:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80103e58:	8b 45 08             	mov    0x8(%ebp),%eax
80103e5b:	89 04 24             	mov    %eax,(%esp)
80103e5e:	e8 e0 0c 00 00       	call   80104b43 <acquire>
  for(i = 0; i < n; i++){
80103e63:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103e6a:	e9 a8 00 00 00       	jmp    80103f17 <pipewrite+0xc6>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80103e6f:	8b 45 08             	mov    0x8(%ebp),%eax
80103e72:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103e78:	85 c0                	test   %eax,%eax
80103e7a:	74 0d                	je     80103e89 <pipewrite+0x38>
80103e7c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103e82:	8b 40 24             	mov    0x24(%eax),%eax
80103e85:	85 c0                	test   %eax,%eax
80103e87:	74 15                	je     80103e9e <pipewrite+0x4d>
        release(&p->lock);
80103e89:	8b 45 08             	mov    0x8(%ebp),%eax
80103e8c:	89 04 24             	mov    %eax,(%esp)
80103e8f:	e8 11 0d 00 00       	call   80104ba5 <release>
        return -1;
80103e94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e99:	e9 9f 00 00 00       	jmp    80103f3d <pipewrite+0xec>
      }
      wakeup(&p->nread);
80103e9e:	8b 45 08             	mov    0x8(%ebp),%eax
80103ea1:	05 34 02 00 00       	add    $0x234,%eax
80103ea6:	89 04 24             	mov    %eax,(%esp)
80103ea9:	e8 91 0a 00 00       	call   8010493f <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103eae:	8b 45 08             	mov    0x8(%ebp),%eax
80103eb1:	8b 55 08             	mov    0x8(%ebp),%edx
80103eb4:	81 c2 38 02 00 00    	add    $0x238,%edx
80103eba:	89 44 24 04          	mov    %eax,0x4(%esp)
80103ebe:	89 14 24             	mov    %edx,(%esp)
80103ec1:	e8 a0 09 00 00       	call   80104866 <sleep>
80103ec6:	eb 01                	jmp    80103ec9 <pipewrite+0x78>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103ec8:	90                   	nop
80103ec9:	8b 45 08             	mov    0x8(%ebp),%eax
80103ecc:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80103ed2:	8b 45 08             	mov    0x8(%ebp),%eax
80103ed5:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103edb:	05 00 02 00 00       	add    $0x200,%eax
80103ee0:	39 c2                	cmp    %eax,%edx
80103ee2:	74 8b                	je     80103e6f <pipewrite+0x1e>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103ee4:	8b 45 08             	mov    0x8(%ebp),%eax
80103ee7:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103eed:	89 c3                	mov    %eax,%ebx
80103eef:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
80103ef5:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80103ef8:	8b 55 0c             	mov    0xc(%ebp),%edx
80103efb:	01 ca                	add    %ecx,%edx
80103efd:	0f b6 0a             	movzbl (%edx),%ecx
80103f00:	8b 55 08             	mov    0x8(%ebp),%edx
80103f03:	88 4c 1a 34          	mov    %cl,0x34(%edx,%ebx,1)
80103f07:	8d 50 01             	lea    0x1(%eax),%edx
80103f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f0d:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80103f13:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103f17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f1a:	3b 45 10             	cmp    0x10(%ebp),%eax
80103f1d:	7c a9                	jl     80103ec8 <pipewrite+0x77>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80103f22:	05 34 02 00 00       	add    $0x234,%eax
80103f27:	89 04 24             	mov    %eax,(%esp)
80103f2a:	e8 10 0a 00 00       	call   8010493f <wakeup>
  release(&p->lock);
80103f2f:	8b 45 08             	mov    0x8(%ebp),%eax
80103f32:	89 04 24             	mov    %eax,(%esp)
80103f35:	e8 6b 0c 00 00       	call   80104ba5 <release>
  return n;
80103f3a:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103f3d:	83 c4 24             	add    $0x24,%esp
80103f40:	5b                   	pop    %ebx
80103f41:	5d                   	pop    %ebp
80103f42:	c3                   	ret    

80103f43 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103f43:	55                   	push   %ebp
80103f44:	89 e5                	mov    %esp,%ebp
80103f46:	53                   	push   %ebx
80103f47:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80103f4a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f4d:	89 04 24             	mov    %eax,(%esp)
80103f50:	e8 ee 0b 00 00       	call   80104b43 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103f55:	eb 3a                	jmp    80103f91 <piperead+0x4e>
    if(proc->killed){
80103f57:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103f5d:	8b 40 24             	mov    0x24(%eax),%eax
80103f60:	85 c0                	test   %eax,%eax
80103f62:	74 15                	je     80103f79 <piperead+0x36>
      release(&p->lock);
80103f64:	8b 45 08             	mov    0x8(%ebp),%eax
80103f67:	89 04 24             	mov    %eax,(%esp)
80103f6a:	e8 36 0c 00 00       	call   80104ba5 <release>
      return -1;
80103f6f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f74:	e9 b7 00 00 00       	jmp    80104030 <piperead+0xed>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103f79:	8b 45 08             	mov    0x8(%ebp),%eax
80103f7c:	8b 55 08             	mov    0x8(%ebp),%edx
80103f7f:	81 c2 34 02 00 00    	add    $0x234,%edx
80103f85:	89 44 24 04          	mov    %eax,0x4(%esp)
80103f89:	89 14 24             	mov    %edx,(%esp)
80103f8c:	e8 d5 08 00 00       	call   80104866 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103f91:	8b 45 08             	mov    0x8(%ebp),%eax
80103f94:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103f9a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f9d:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103fa3:	39 c2                	cmp    %eax,%edx
80103fa5:	75 0d                	jne    80103fb4 <piperead+0x71>
80103fa7:	8b 45 08             	mov    0x8(%ebp),%eax
80103faa:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103fb0:	85 c0                	test   %eax,%eax
80103fb2:	75 a3                	jne    80103f57 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103fb4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103fbb:	eb 4a                	jmp    80104007 <piperead+0xc4>
    if(p->nread == p->nwrite)
80103fbd:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc0:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103fc6:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc9:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103fcf:	39 c2                	cmp    %eax,%edx
80103fd1:	74 3e                	je     80104011 <piperead+0xce>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103fd3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fd6:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fd9:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80103fdc:	8b 45 08             	mov    0x8(%ebp),%eax
80103fdf:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103fe5:	89 c3                	mov    %eax,%ebx
80103fe7:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
80103fed:	8b 55 08             	mov    0x8(%ebp),%edx
80103ff0:	0f b6 54 1a 34       	movzbl 0x34(%edx,%ebx,1),%edx
80103ff5:	88 11                	mov    %dl,(%ecx)
80103ff7:	8d 50 01             	lea    0x1(%eax),%edx
80103ffa:	8b 45 08             	mov    0x8(%ebp),%eax
80103ffd:	89 90 34 02 00 00    	mov    %edx,0x234(%eax)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104003:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104007:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010400a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010400d:	7c ae                	jl     80103fbd <piperead+0x7a>
8010400f:	eb 01                	jmp    80104012 <piperead+0xcf>
    if(p->nread == p->nwrite)
      break;
80104011:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104012:	8b 45 08             	mov    0x8(%ebp),%eax
80104015:	05 38 02 00 00       	add    $0x238,%eax
8010401a:	89 04 24             	mov    %eax,(%esp)
8010401d:	e8 1d 09 00 00       	call   8010493f <wakeup>
  release(&p->lock);
80104022:	8b 45 08             	mov    0x8(%ebp),%eax
80104025:	89 04 24             	mov    %eax,(%esp)
80104028:	e8 78 0b 00 00       	call   80104ba5 <release>
  return i;
8010402d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104030:	83 c4 24             	add    $0x24,%esp
80104033:	5b                   	pop    %ebx
80104034:	5d                   	pop    %ebp
80104035:	c3                   	ret    
80104036:	66 90                	xchg   %ax,%ax

80104038 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104038:	55                   	push   %ebp
80104039:	89 e5                	mov    %esp,%ebp
8010403b:	53                   	push   %ebx
8010403c:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010403f:	9c                   	pushf  
80104040:	5b                   	pop    %ebx
80104041:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80104044:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104047:	83 c4 10             	add    $0x10,%esp
8010404a:	5b                   	pop    %ebx
8010404b:	5d                   	pop    %ebp
8010404c:	c3                   	ret    

8010404d <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
8010404d:	55                   	push   %ebp
8010404e:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104050:	fb                   	sti    
}
80104051:	5d                   	pop    %ebp
80104052:	c3                   	ret    

80104053 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104053:	55                   	push   %ebp
80104054:	89 e5                	mov    %esp,%ebp
80104056:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104059:	c7 44 24 04 6d 84 10 	movl   $0x8010846d,0x4(%esp)
80104060:	80 
80104061:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104068:	e8 b5 0a 00 00       	call   80104b22 <initlock>
}
8010406d:	c9                   	leave  
8010406e:	c3                   	ret    

8010406f <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010406f:	55                   	push   %ebp
80104070:	89 e5                	mov    %esp,%ebp
80104072:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104075:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
8010407c:	e8 c2 0a 00 00       	call   80104b43 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104081:	c7 45 f4 54 ff 10 80 	movl   $0x8010ff54,-0xc(%ebp)
80104088:	eb 0e                	jmp    80104098 <allocproc+0x29>
    if(p->state == UNUSED)
8010408a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010408d:	8b 40 0c             	mov    0xc(%eax),%eax
80104090:	85 c0                	test   %eax,%eax
80104092:	74 23                	je     801040b7 <allocproc+0x48>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104094:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104098:	81 7d f4 54 1e 11 80 	cmpl   $0x80111e54,-0xc(%ebp)
8010409f:	72 e9                	jb     8010408a <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
801040a1:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801040a8:	e8 f8 0a 00 00       	call   80104ba5 <release>
  return 0;
801040ad:	b8 00 00 00 00       	mov    $0x0,%eax
801040b2:	e9 b5 00 00 00       	jmp    8010416c <allocproc+0xfd>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
801040b7:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801040b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040bb:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801040c2:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801040c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040ca:	89 42 10             	mov    %eax,0x10(%edx)
801040cd:	83 c0 01             	add    $0x1,%eax
801040d0:	a3 04 b0 10 80       	mov    %eax,0x8010b004
  release(&ptable.lock);
801040d5:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801040dc:	e8 c4 0a 00 00       	call   80104ba5 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801040e1:	e8 5d ea ff ff       	call   80102b43 <kalloc>
801040e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040e9:	89 42 08             	mov    %eax,0x8(%edx)
801040ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040ef:	8b 40 08             	mov    0x8(%eax),%eax
801040f2:	85 c0                	test   %eax,%eax
801040f4:	75 11                	jne    80104107 <allocproc+0x98>
    p->state = UNUSED;
801040f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040f9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104100:	b8 00 00 00 00       	mov    $0x0,%eax
80104105:	eb 65                	jmp    8010416c <allocproc+0xfd>
  }
  sp = p->kstack + KSTACKSIZE;
80104107:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010410a:	8b 40 08             	mov    0x8(%eax),%eax
8010410d:	05 00 10 00 00       	add    $0x1000,%eax
80104112:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104115:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010411c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010411f:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104122:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104126:	ba a0 61 10 80       	mov    $0x801061a0,%edx
8010412b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010412e:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104130:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104134:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104137:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010413a:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010413d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104140:	8b 40 1c             	mov    0x1c(%eax),%eax
80104143:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010414a:	00 
8010414b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104152:	00 
80104153:	89 04 24             	mov    %eax,(%esp)
80104156:	e8 43 0c 00 00       	call   80104d9e <memset>
  p->context->eip = (uint)forkret;
8010415b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010415e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104161:	ba 3a 48 10 80       	mov    $0x8010483a,%edx
80104166:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104169:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010416c:	c9                   	leave  
8010416d:	c3                   	ret    

8010416e <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010416e:	55                   	push   %ebp
8010416f:	89 e5                	mov    %esp,%ebp
80104171:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
80104174:	e8 f6 fe ff ff       	call   8010406f <allocproc>
80104179:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
8010417c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010417f:	a3 48 b6 10 80       	mov    %eax,0x8010b648
  if((p->pgdir = setupkvm()) == 0)
80104184:	e8 2e 37 00 00       	call   801078b7 <setupkvm>
80104189:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010418c:	89 42 04             	mov    %eax,0x4(%edx)
8010418f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104192:	8b 40 04             	mov    0x4(%eax),%eax
80104195:	85 c0                	test   %eax,%eax
80104197:	75 0c                	jne    801041a5 <userinit+0x37>
    panic("userinit: out of memory?");
80104199:	c7 04 24 74 84 10 80 	movl   $0x80108474,(%esp)
801041a0:	e8 a1 c3 ff ff       	call   80100546 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801041a5:	ba 2c 00 00 00       	mov    $0x2c,%edx
801041aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041ad:	8b 40 04             	mov    0x4(%eax),%eax
801041b0:	89 54 24 08          	mov    %edx,0x8(%esp)
801041b4:	c7 44 24 04 e0 b4 10 	movl   $0x8010b4e0,0x4(%esp)
801041bb:	80 
801041bc:	89 04 24             	mov    %eax,(%esp)
801041bf:	e8 4b 39 00 00       	call   80107b0f <inituvm>
  p->sz = PGSIZE;
801041c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041c7:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801041cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041d0:	8b 40 18             	mov    0x18(%eax),%eax
801041d3:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
801041da:	00 
801041db:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801041e2:	00 
801041e3:	89 04 24             	mov    %eax,(%esp)
801041e6:	e8 b3 0b 00 00       	call   80104d9e <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801041eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041ee:	8b 40 18             	mov    0x18(%eax),%eax
801041f1:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801041f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041fa:	8b 40 18             	mov    0x18(%eax),%eax
801041fd:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104203:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104206:	8b 40 18             	mov    0x18(%eax),%eax
80104209:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010420c:	8b 52 18             	mov    0x18(%edx),%edx
8010420f:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104213:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104217:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010421a:	8b 40 18             	mov    0x18(%eax),%eax
8010421d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104220:	8b 52 18             	mov    0x18(%edx),%edx
80104223:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104227:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010422b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010422e:	8b 40 18             	mov    0x18(%eax),%eax
80104231:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104238:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010423b:	8b 40 18             	mov    0x18(%eax),%eax
8010423e:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104245:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104248:	8b 40 18             	mov    0x18(%eax),%eax
8010424b:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104252:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104255:	83 c0 6c             	add    $0x6c,%eax
80104258:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010425f:	00 
80104260:	c7 44 24 04 8d 84 10 	movl   $0x8010848d,0x4(%esp)
80104267:	80 
80104268:	89 04 24             	mov    %eax,(%esp)
8010426b:	e8 5e 0d 00 00       	call   80104fce <safestrcpy>
  p->cwd = namei("/");
80104270:	c7 04 24 96 84 10 80 	movl   $0x80108496,(%esp)
80104277:	e8 d1 e1 ff ff       	call   8010244d <namei>
8010427c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010427f:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
80104282:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104285:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
8010428c:	c9                   	leave  
8010428d:	c3                   	ret    

8010428e <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
8010428e:	55                   	push   %ebp
8010428f:	89 e5                	mov    %esp,%ebp
80104291:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
80104294:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010429a:	8b 00                	mov    (%eax),%eax
8010429c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
8010429f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801042a3:	7e 34                	jle    801042d9 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801042a5:	8b 55 08             	mov    0x8(%ebp),%edx
801042a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ab:	01 c2                	add    %eax,%edx
801042ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042b3:	8b 40 04             	mov    0x4(%eax),%eax
801042b6:	89 54 24 08          	mov    %edx,0x8(%esp)
801042ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042bd:	89 54 24 04          	mov    %edx,0x4(%esp)
801042c1:	89 04 24             	mov    %eax,(%esp)
801042c4:	e8 c0 39 00 00       	call   80107c89 <allocuvm>
801042c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801042cc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801042d0:	75 41                	jne    80104313 <growproc+0x85>
      return -1;
801042d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042d7:	eb 58                	jmp    80104331 <growproc+0xa3>
  } else if(n < 0){
801042d9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801042dd:	79 34                	jns    80104313 <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
801042df:	8b 55 08             	mov    0x8(%ebp),%edx
801042e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042e5:	01 c2                	add    %eax,%edx
801042e7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042ed:	8b 40 04             	mov    0x4(%eax),%eax
801042f0:	89 54 24 08          	mov    %edx,0x8(%esp)
801042f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042f7:	89 54 24 04          	mov    %edx,0x4(%esp)
801042fb:	89 04 24             	mov    %eax,(%esp)
801042fe:	e8 60 3a 00 00       	call   80107d63 <deallocuvm>
80104303:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104306:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010430a:	75 07                	jne    80104313 <growproc+0x85>
      return -1;
8010430c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104311:	eb 1e                	jmp    80104331 <growproc+0xa3>
  }
  proc->sz = sz;
80104313:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104319:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010431c:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
8010431e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104324:	89 04 24             	mov    %eax,(%esp)
80104327:	e8 7c 36 00 00       	call   801079a8 <switchuvm>
  return 0;
8010432c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104331:	c9                   	leave  
80104332:	c3                   	ret    

80104333 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104333:	55                   	push   %ebp
80104334:	89 e5                	mov    %esp,%ebp
80104336:	57                   	push   %edi
80104337:	56                   	push   %esi
80104338:	53                   	push   %ebx
80104339:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0){
8010433c:	e8 2e fd ff ff       	call   8010406f <allocproc>
80104341:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104344:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104348:	75 0a                	jne    80104354 <fork+0x21>
    return -1;
8010434a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010434f:	e9 3a 01 00 00       	jmp    8010448e <fork+0x15b>
  }
 
  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104354:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010435a:	8b 10                	mov    (%eax),%edx
8010435c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104362:	8b 40 04             	mov    0x4(%eax),%eax
80104365:	89 54 24 04          	mov    %edx,0x4(%esp)
80104369:	89 04 24             	mov    %eax,(%esp)
8010436c:	e8 a3 3b 00 00       	call   80107f14 <copyuvm>
80104371:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104374:	89 42 04             	mov    %eax,0x4(%edx)
80104377:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010437a:	8b 40 04             	mov    0x4(%eax),%eax
8010437d:	85 c0                	test   %eax,%eax
8010437f:	75 2c                	jne    801043ad <fork+0x7a>
    kfree(np->kstack);
80104381:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104384:	8b 40 08             	mov    0x8(%eax),%eax
80104387:	89 04 24             	mov    %eax,(%esp)
8010438a:	e8 1b e7 ff ff       	call   80102aaa <kfree>
    np->kstack = 0;
8010438f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104392:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104399:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010439c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801043a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043a8:	e9 e1 00 00 00       	jmp    8010448e <fork+0x15b>
  }
  np->sz = proc->sz;
801043ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801043b3:	8b 10                	mov    (%eax),%edx
801043b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043b8:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801043ba:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801043c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043c4:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801043c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043ca:	8b 50 18             	mov    0x18(%eax),%edx
801043cd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801043d3:	8b 40 18             	mov    0x18(%eax),%eax
801043d6:	89 c3                	mov    %eax,%ebx
801043d8:	b8 13 00 00 00       	mov    $0x13,%eax
801043dd:	89 d7                	mov    %edx,%edi
801043df:	89 de                	mov    %ebx,%esi
801043e1:	89 c1                	mov    %eax,%ecx
801043e3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801043e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043e8:	8b 40 18             	mov    0x18(%eax),%eax
801043eb:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801043f2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801043f9:	eb 3d                	jmp    80104438 <fork+0x105>
    if(proc->ofile[i])
801043fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104401:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104404:	83 c2 08             	add    $0x8,%edx
80104407:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010440b:	85 c0                	test   %eax,%eax
8010440d:	74 25                	je     80104434 <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
8010440f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104415:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104418:	83 c2 08             	add    $0x8,%edx
8010441b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010441f:	89 04 24             	mov    %eax,(%esp)
80104422:	e8 75 cb ff ff       	call   80100f9c <filedup>
80104427:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010442a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010442d:	83 c1 08             	add    $0x8,%ecx
80104430:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104434:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104438:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010443c:	7e bd                	jle    801043fb <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
8010443e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104444:	8b 40 68             	mov    0x68(%eax),%eax
80104447:	89 04 24             	mov    %eax,(%esp)
8010444a:	e8 0b d4 ff ff       	call   8010185a <idup>
8010444f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104452:	89 42 68             	mov    %eax,0x68(%edx)
 
  pid = np->pid;
80104455:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104458:	8b 40 10             	mov    0x10(%eax),%eax
8010445b:	89 45 dc             	mov    %eax,-0x24(%ebp)
  np->state = RUNNABLE;
8010445e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104461:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104468:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010446e:	8d 50 6c             	lea    0x6c(%eax),%edx
80104471:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104474:	83 c0 6c             	add    $0x6c,%eax
80104477:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010447e:	00 
8010447f:	89 54 24 04          	mov    %edx,0x4(%esp)
80104483:	89 04 24             	mov    %eax,(%esp)
80104486:	e8 43 0b 00 00       	call   80104fce <safestrcpy>
  return pid;
8010448b:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
8010448e:	83 c4 2c             	add    $0x2c,%esp
80104491:	5b                   	pop    %ebx
80104492:	5e                   	pop    %esi
80104493:	5f                   	pop    %edi
80104494:	5d                   	pop    %ebp
80104495:	c3                   	ret    

80104496 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104496:	55                   	push   %ebp
80104497:	89 e5                	mov    %esp,%ebp
80104499:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
8010449c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801044a3:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801044a8:	39 c2                	cmp    %eax,%edx
801044aa:	75 0c                	jne    801044b8 <exit+0x22>
    panic("init exiting");
801044ac:	c7 04 24 98 84 10 80 	movl   $0x80108498,(%esp)
801044b3:	e8 8e c0 ff ff       	call   80100546 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801044b8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801044bf:	eb 44                	jmp    80104505 <exit+0x6f>
    if(proc->ofile[fd]){
801044c1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044c7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801044ca:	83 c2 08             	add    $0x8,%edx
801044cd:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801044d1:	85 c0                	test   %eax,%eax
801044d3:	74 2c                	je     80104501 <exit+0x6b>
      fileclose(proc->ofile[fd]);
801044d5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044db:	8b 55 f0             	mov    -0x10(%ebp),%edx
801044de:	83 c2 08             	add    $0x8,%edx
801044e1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801044e5:	89 04 24             	mov    %eax,(%esp)
801044e8:	e8 f7 ca ff ff       	call   80100fe4 <fileclose>
      proc->ofile[fd] = 0;
801044ed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044f3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801044f6:	83 c2 08             	add    $0x8,%edx
801044f9:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104500:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104501:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104505:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104509:	7e b6                	jle    801044c1 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  iput(proc->cwd);
8010450b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104511:	8b 40 68             	mov    0x68(%eax),%eax
80104514:	89 04 24             	mov    %eax,(%esp)
80104517:	e8 23 d5 ff ff       	call   80101a3f <iput>
  proc->cwd = 0;
8010451c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104522:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104529:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104530:	e8 0e 06 00 00       	call   80104b43 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104535:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010453b:	8b 40 14             	mov    0x14(%eax),%eax
8010453e:	89 04 24             	mov    %eax,(%esp)
80104541:	e8 bb 03 00 00       	call   80104901 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104546:	c7 45 f4 54 ff 10 80 	movl   $0x8010ff54,-0xc(%ebp)
8010454d:	eb 38                	jmp    80104587 <exit+0xf1>
    if(p->parent == proc){
8010454f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104552:	8b 50 14             	mov    0x14(%eax),%edx
80104555:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010455b:	39 c2                	cmp    %eax,%edx
8010455d:	75 24                	jne    80104583 <exit+0xed>
      p->parent = initproc;
8010455f:	8b 15 48 b6 10 80    	mov    0x8010b648,%edx
80104565:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104568:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010456b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010456e:	8b 40 0c             	mov    0xc(%eax),%eax
80104571:	83 f8 05             	cmp    $0x5,%eax
80104574:	75 0d                	jne    80104583 <exit+0xed>
        wakeup1(initproc);
80104576:	a1 48 b6 10 80       	mov    0x8010b648,%eax
8010457b:	89 04 24             	mov    %eax,(%esp)
8010457e:	e8 7e 03 00 00       	call   80104901 <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104583:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104587:	81 7d f4 54 1e 11 80 	cmpl   $0x80111e54,-0xc(%ebp)
8010458e:	72 bf                	jb     8010454f <exit+0xb9>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104590:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104596:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010459d:	e8 b4 01 00 00       	call   80104756 <sched>
  panic("zombie exit");
801045a2:	c7 04 24 a5 84 10 80 	movl   $0x801084a5,(%esp)
801045a9:	e8 98 bf ff ff       	call   80100546 <panic>

801045ae <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801045ae:	55                   	push   %ebp
801045af:	89 e5                	mov    %esp,%ebp
801045b1:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
801045b4:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801045bb:	e8 83 05 00 00       	call   80104b43 <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
801045c0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045c7:	c7 45 f4 54 ff 10 80 	movl   $0x8010ff54,-0xc(%ebp)
801045ce:	e9 9a 00 00 00       	jmp    8010466d <wait+0xbf>
      if(p->parent != proc)
801045d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d6:	8b 50 14             	mov    0x14(%eax),%edx
801045d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045df:	39 c2                	cmp    %eax,%edx
801045e1:	0f 85 81 00 00 00    	jne    80104668 <wait+0xba>
        continue;
      havekids = 1;
801045e7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801045ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f1:	8b 40 0c             	mov    0xc(%eax),%eax
801045f4:	83 f8 05             	cmp    $0x5,%eax
801045f7:	75 70                	jne    80104669 <wait+0xbb>
        // Found one.
        pid = p->pid;
801045f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045fc:	8b 40 10             	mov    0x10(%eax),%eax
801045ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104602:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104605:	8b 40 08             	mov    0x8(%eax),%eax
80104608:	89 04 24             	mov    %eax,(%esp)
8010460b:	e8 9a e4 ff ff       	call   80102aaa <kfree>
        p->kstack = 0;
80104610:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104613:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010461a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010461d:	8b 40 04             	mov    0x4(%eax),%eax
80104620:	89 04 24             	mov    %eax,(%esp)
80104623:	e8 f7 37 00 00       	call   80107e1f <freevm>
        p->state = UNUSED;
80104628:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010462b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104632:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104635:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010463c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010463f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104646:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104649:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010464d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104650:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104657:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
8010465e:	e8 42 05 00 00       	call   80104ba5 <release>
        return pid;
80104663:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104666:	eb 53                	jmp    801046bb <wait+0x10d>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104668:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104669:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010466d:	81 7d f4 54 1e 11 80 	cmpl   $0x80111e54,-0xc(%ebp)
80104674:	0f 82 59 ff ff ff    	jb     801045d3 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
8010467a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010467e:	74 0d                	je     8010468d <wait+0xdf>
80104680:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104686:	8b 40 24             	mov    0x24(%eax),%eax
80104689:	85 c0                	test   %eax,%eax
8010468b:	74 13                	je     801046a0 <wait+0xf2>
      release(&ptable.lock);
8010468d:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104694:	e8 0c 05 00 00       	call   80104ba5 <release>
      return -1;
80104699:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010469e:	eb 1b                	jmp    801046bb <wait+0x10d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
801046a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046a6:	c7 44 24 04 20 ff 10 	movl   $0x8010ff20,0x4(%esp)
801046ad:	80 
801046ae:	89 04 24             	mov    %eax,(%esp)
801046b1:	e8 b0 01 00 00       	call   80104866 <sleep>
  }
801046b6:	e9 05 ff ff ff       	jmp    801045c0 <wait+0x12>
}
801046bb:	c9                   	leave  
801046bc:	c3                   	ret    

801046bd <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801046bd:	55                   	push   %ebp
801046be:	89 e5                	mov    %esp,%ebp
801046c0:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
801046c3:	e8 85 f9 ff ff       	call   8010404d <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801046c8:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801046cf:	e8 6f 04 00 00       	call   80104b43 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046d4:	c7 45 f4 54 ff 10 80 	movl   $0x8010ff54,-0xc(%ebp)
801046db:	eb 5f                	jmp    8010473c <scheduler+0x7f>
      if(p->state != RUNNABLE)
801046dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046e0:	8b 40 0c             	mov    0xc(%eax),%eax
801046e3:	83 f8 03             	cmp    $0x3,%eax
801046e6:	75 4f                	jne    80104737 <scheduler+0x7a>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
801046e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046eb:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
801046f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f4:	89 04 24             	mov    %eax,(%esp)
801046f7:	e8 ac 32 00 00       	call   801079a8 <switchuvm>
      p->state = RUNNING;
801046fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ff:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104706:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010470c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010470f:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104716:	83 c2 04             	add    $0x4,%edx
80104719:	89 44 24 04          	mov    %eax,0x4(%esp)
8010471d:	89 14 24             	mov    %edx,(%esp)
80104720:	e8 1f 09 00 00       	call   80105044 <swtch>
      switchkvm();
80104725:	e8 61 32 00 00       	call   8010798b <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
8010472a:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104731:	00 00 00 00 
80104735:	eb 01                	jmp    80104738 <scheduler+0x7b>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80104737:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104738:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010473c:	81 7d f4 54 1e 11 80 	cmpl   $0x80111e54,-0xc(%ebp)
80104743:	72 98                	jb     801046dd <scheduler+0x20>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104745:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
8010474c:	e8 54 04 00 00       	call   80104ba5 <release>

  }
80104751:	e9 6d ff ff ff       	jmp    801046c3 <scheduler+0x6>

80104756 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104756:	55                   	push   %ebp
80104757:	89 e5                	mov    %esp,%ebp
80104759:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
8010475c:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104763:	e8 05 05 00 00       	call   80104c6d <holding>
80104768:	85 c0                	test   %eax,%eax
8010476a:	75 0c                	jne    80104778 <sched+0x22>
    panic("sched ptable.lock");
8010476c:	c7 04 24 b1 84 10 80 	movl   $0x801084b1,(%esp)
80104773:	e8 ce bd ff ff       	call   80100546 <panic>
  if(cpu->ncli != 1)
80104778:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010477e:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104784:	83 f8 01             	cmp    $0x1,%eax
80104787:	74 0c                	je     80104795 <sched+0x3f>
    panic("sched locks");
80104789:	c7 04 24 c3 84 10 80 	movl   $0x801084c3,(%esp)
80104790:	e8 b1 bd ff ff       	call   80100546 <panic>
  if(proc->state == RUNNING)
80104795:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010479b:	8b 40 0c             	mov    0xc(%eax),%eax
8010479e:	83 f8 04             	cmp    $0x4,%eax
801047a1:	75 0c                	jne    801047af <sched+0x59>
    panic("sched running");
801047a3:	c7 04 24 cf 84 10 80 	movl   $0x801084cf,(%esp)
801047aa:	e8 97 bd ff ff       	call   80100546 <panic>
  if(readeflags()&FL_IF)
801047af:	e8 84 f8 ff ff       	call   80104038 <readeflags>
801047b4:	25 00 02 00 00       	and    $0x200,%eax
801047b9:	85 c0                	test   %eax,%eax
801047bb:	74 0c                	je     801047c9 <sched+0x73>
    panic("sched interruptible");
801047bd:	c7 04 24 dd 84 10 80 	movl   $0x801084dd,(%esp)
801047c4:	e8 7d bd ff ff       	call   80100546 <panic>
  intena = cpu->intena;
801047c9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801047cf:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801047d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
801047d8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801047de:	8b 40 04             	mov    0x4(%eax),%eax
801047e1:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801047e8:	83 c2 1c             	add    $0x1c,%edx
801047eb:	89 44 24 04          	mov    %eax,0x4(%esp)
801047ef:	89 14 24             	mov    %edx,(%esp)
801047f2:	e8 4d 08 00 00       	call   80105044 <swtch>
  cpu->intena = intena;
801047f7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801047fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104800:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104806:	c9                   	leave  
80104807:	c3                   	ret    

80104808 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104808:	55                   	push   %ebp
80104809:	89 e5                	mov    %esp,%ebp
8010480b:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
8010480e:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104815:	e8 29 03 00 00       	call   80104b43 <acquire>
  proc->state = RUNNABLE;
8010481a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104820:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104827:	e8 2a ff ff ff       	call   80104756 <sched>
  release(&ptable.lock);
8010482c:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104833:	e8 6d 03 00 00       	call   80104ba5 <release>
}
80104838:	c9                   	leave  
80104839:	c3                   	ret    

8010483a <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010483a:	55                   	push   %ebp
8010483b:	89 e5                	mov    %esp,%ebp
8010483d:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104840:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104847:	e8 59 03 00 00       	call   80104ba5 <release>

  if (first) {
8010484c:	a1 20 b0 10 80       	mov    0x8010b020,%eax
80104851:	85 c0                	test   %eax,%eax
80104853:	74 0f                	je     80104864 <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104855:	c7 05 20 b0 10 80 00 	movl   $0x0,0x8010b020
8010485c:	00 00 00 
    initlog();
8010485f:	e8 f4 e7 ff ff       	call   80103058 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104864:	c9                   	leave  
80104865:	c3                   	ret    

80104866 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104866:	55                   	push   %ebp
80104867:	89 e5                	mov    %esp,%ebp
80104869:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
8010486c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104872:	85 c0                	test   %eax,%eax
80104874:	75 0c                	jne    80104882 <sleep+0x1c>
    panic("sleep");
80104876:	c7 04 24 f1 84 10 80 	movl   $0x801084f1,(%esp)
8010487d:	e8 c4 bc ff ff       	call   80100546 <panic>

  if(lk == 0)
80104882:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104886:	75 0c                	jne    80104894 <sleep+0x2e>
    panic("sleep without lk");
80104888:	c7 04 24 f7 84 10 80 	movl   $0x801084f7,(%esp)
8010488f:	e8 b2 bc ff ff       	call   80100546 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104894:	81 7d 0c 20 ff 10 80 	cmpl   $0x8010ff20,0xc(%ebp)
8010489b:	74 17                	je     801048b4 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
8010489d:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801048a4:	e8 9a 02 00 00       	call   80104b43 <acquire>
    release(lk);
801048a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801048ac:	89 04 24             	mov    %eax,(%esp)
801048af:	e8 f1 02 00 00       	call   80104ba5 <release>
  }

  // Go to sleep.
  proc->chan = chan;
801048b4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048ba:	8b 55 08             	mov    0x8(%ebp),%edx
801048bd:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
801048c0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048c6:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
801048cd:	e8 84 fe ff ff       	call   80104756 <sched>

  // Tidy up.
  proc->chan = 0;
801048d2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048d8:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
801048df:	81 7d 0c 20 ff 10 80 	cmpl   $0x8010ff20,0xc(%ebp)
801048e6:	74 17                	je     801048ff <sleep+0x99>
    release(&ptable.lock);
801048e8:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801048ef:	e8 b1 02 00 00       	call   80104ba5 <release>
    acquire(lk);
801048f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801048f7:	89 04 24             	mov    %eax,(%esp)
801048fa:	e8 44 02 00 00       	call   80104b43 <acquire>
  }
}
801048ff:	c9                   	leave  
80104900:	c3                   	ret    

80104901 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104901:	55                   	push   %ebp
80104902:	89 e5                	mov    %esp,%ebp
80104904:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104907:	c7 45 fc 54 ff 10 80 	movl   $0x8010ff54,-0x4(%ebp)
8010490e:	eb 24                	jmp    80104934 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104910:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104913:	8b 40 0c             	mov    0xc(%eax),%eax
80104916:	83 f8 02             	cmp    $0x2,%eax
80104919:	75 15                	jne    80104930 <wakeup1+0x2f>
8010491b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010491e:	8b 40 20             	mov    0x20(%eax),%eax
80104921:	3b 45 08             	cmp    0x8(%ebp),%eax
80104924:	75 0a                	jne    80104930 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104926:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104929:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104930:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
80104934:	81 7d fc 54 1e 11 80 	cmpl   $0x80111e54,-0x4(%ebp)
8010493b:	72 d3                	jb     80104910 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
8010493d:	c9                   	leave  
8010493e:	c3                   	ret    

8010493f <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
8010493f:	55                   	push   %ebp
80104940:	89 e5                	mov    %esp,%ebp
80104942:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104945:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
8010494c:	e8 f2 01 00 00       	call   80104b43 <acquire>
  wakeup1(chan);
80104951:	8b 45 08             	mov    0x8(%ebp),%eax
80104954:	89 04 24             	mov    %eax,(%esp)
80104957:	e8 a5 ff ff ff       	call   80104901 <wakeup1>
  release(&ptable.lock);
8010495c:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104963:	e8 3d 02 00 00       	call   80104ba5 <release>
}
80104968:	c9                   	leave  
80104969:	c3                   	ret    

8010496a <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
8010496a:	55                   	push   %ebp
8010496b:	89 e5                	mov    %esp,%ebp
8010496d:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104970:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104977:	e8 c7 01 00 00       	call   80104b43 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010497c:	c7 45 f4 54 ff 10 80 	movl   $0x8010ff54,-0xc(%ebp)
80104983:	eb 41                	jmp    801049c6 <kill+0x5c>
    if(p->pid == pid){
80104985:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104988:	8b 40 10             	mov    0x10(%eax),%eax
8010498b:	3b 45 08             	cmp    0x8(%ebp),%eax
8010498e:	75 32                	jne    801049c2 <kill+0x58>
      p->killed = 1;
80104990:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104993:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
8010499a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010499d:	8b 40 0c             	mov    0xc(%eax),%eax
801049a0:	83 f8 02             	cmp    $0x2,%eax
801049a3:	75 0a                	jne    801049af <kill+0x45>
        p->state = RUNNABLE;
801049a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801049af:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801049b6:	e8 ea 01 00 00       	call   80104ba5 <release>
      return 0;
801049bb:	b8 00 00 00 00       	mov    $0x0,%eax
801049c0:	eb 1e                	jmp    801049e0 <kill+0x76>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049c2:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801049c6:	81 7d f4 54 1e 11 80 	cmpl   $0x80111e54,-0xc(%ebp)
801049cd:	72 b6                	jb     80104985 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
801049cf:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801049d6:	e8 ca 01 00 00       	call   80104ba5 <release>
  return -1;
801049db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801049e0:	c9                   	leave  
801049e1:	c3                   	ret    

801049e2 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801049e2:	55                   	push   %ebp
801049e3:	89 e5                	mov    %esp,%ebp
801049e5:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049e8:	c7 45 f0 54 ff 10 80 	movl   $0x8010ff54,-0x10(%ebp)
801049ef:	e9 d8 00 00 00       	jmp    80104acc <procdump+0xea>
    if(p->state == UNUSED)
801049f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049f7:	8b 40 0c             	mov    0xc(%eax),%eax
801049fa:	85 c0                	test   %eax,%eax
801049fc:	0f 84 c5 00 00 00    	je     80104ac7 <procdump+0xe5>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104a02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a05:	8b 40 0c             	mov    0xc(%eax),%eax
80104a08:	83 f8 05             	cmp    $0x5,%eax
80104a0b:	77 23                	ja     80104a30 <procdump+0x4e>
80104a0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a10:	8b 40 0c             	mov    0xc(%eax),%eax
80104a13:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104a1a:	85 c0                	test   %eax,%eax
80104a1c:	74 12                	je     80104a30 <procdump+0x4e>
      state = states[p->state];
80104a1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a21:	8b 40 0c             	mov    0xc(%eax),%eax
80104a24:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104a2b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104a2e:	eb 07                	jmp    80104a37 <procdump+0x55>
    else
      state = "???";
80104a30:	c7 45 ec 08 85 10 80 	movl   $0x80108508,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104a37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a3a:	8d 50 6c             	lea    0x6c(%eax),%edx
80104a3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a40:	8b 40 10             	mov    0x10(%eax),%eax
80104a43:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104a47:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104a4a:	89 54 24 08          	mov    %edx,0x8(%esp)
80104a4e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a52:	c7 04 24 0c 85 10 80 	movl   $0x8010850c,(%esp)
80104a59:	e8 4c b9 ff ff       	call   801003aa <cprintf>
    if(p->state == SLEEPING){
80104a5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a61:	8b 40 0c             	mov    0xc(%eax),%eax
80104a64:	83 f8 02             	cmp    $0x2,%eax
80104a67:	75 50                	jne    80104ab9 <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104a69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a6c:	8b 40 1c             	mov    0x1c(%eax),%eax
80104a6f:	8b 40 0c             	mov    0xc(%eax),%eax
80104a72:	83 c0 08             	add    $0x8,%eax
80104a75:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104a78:	89 54 24 04          	mov    %edx,0x4(%esp)
80104a7c:	89 04 24             	mov    %eax,(%esp)
80104a7f:	e8 70 01 00 00       	call   80104bf4 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104a84:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104a8b:	eb 1b                	jmp    80104aa8 <procdump+0xc6>
        cprintf(" %p", pc[i]);
80104a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a90:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104a94:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a98:	c7 04 24 15 85 10 80 	movl   $0x80108515,(%esp)
80104a9f:	e8 06 b9 ff ff       	call   801003aa <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104aa4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104aa8:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104aac:	7f 0b                	jg     80104ab9 <procdump+0xd7>
80104aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab1:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104ab5:	85 c0                	test   %eax,%eax
80104ab7:	75 d4                	jne    80104a8d <procdump+0xab>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104ab9:	c7 04 24 19 85 10 80 	movl   $0x80108519,(%esp)
80104ac0:	e8 e5 b8 ff ff       	call   801003aa <cprintf>
80104ac5:	eb 01                	jmp    80104ac8 <procdump+0xe6>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80104ac7:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ac8:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104acc:	81 7d f0 54 1e 11 80 	cmpl   $0x80111e54,-0x10(%ebp)
80104ad3:	0f 82 1b ff ff ff    	jb     801049f4 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104ad9:	c9                   	leave  
80104ada:	c3                   	ret    
80104adb:	90                   	nop

80104adc <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104adc:	55                   	push   %ebp
80104add:	89 e5                	mov    %esp,%ebp
80104adf:	53                   	push   %ebx
80104ae0:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104ae3:	9c                   	pushf  
80104ae4:	5b                   	pop    %ebx
80104ae5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80104ae8:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104aeb:	83 c4 10             	add    $0x10,%esp
80104aee:	5b                   	pop    %ebx
80104aef:	5d                   	pop    %ebp
80104af0:	c3                   	ret    

80104af1 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104af1:	55                   	push   %ebp
80104af2:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104af4:	fa                   	cli    
}
80104af5:	5d                   	pop    %ebp
80104af6:	c3                   	ret    

80104af7 <sti>:

static inline void
sti(void)
{
80104af7:	55                   	push   %ebp
80104af8:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104afa:	fb                   	sti    
}
80104afb:	5d                   	pop    %ebp
80104afc:	c3                   	ret    

80104afd <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104afd:	55                   	push   %ebp
80104afe:	89 e5                	mov    %esp,%ebp
80104b00:	53                   	push   %ebx
80104b01:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80104b04:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104b07:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80104b0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104b0d:	89 c3                	mov    %eax,%ebx
80104b0f:	89 d8                	mov    %ebx,%eax
80104b11:	f0 87 02             	lock xchg %eax,(%edx)
80104b14:	89 c3                	mov    %eax,%ebx
80104b16:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104b19:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104b1c:	83 c4 10             	add    $0x10,%esp
80104b1f:	5b                   	pop    %ebx
80104b20:	5d                   	pop    %ebp
80104b21:	c3                   	ret    

80104b22 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104b22:	55                   	push   %ebp
80104b23:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104b25:	8b 45 08             	mov    0x8(%ebp),%eax
80104b28:	8b 55 0c             	mov    0xc(%ebp),%edx
80104b2b:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104b2e:	8b 45 08             	mov    0x8(%ebp),%eax
80104b31:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104b37:	8b 45 08             	mov    0x8(%ebp),%eax
80104b3a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104b41:	5d                   	pop    %ebp
80104b42:	c3                   	ret    

80104b43 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104b43:	55                   	push   %ebp
80104b44:	89 e5                	mov    %esp,%ebp
80104b46:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104b49:	e8 49 01 00 00       	call   80104c97 <pushcli>
  if(holding(lk))
80104b4e:	8b 45 08             	mov    0x8(%ebp),%eax
80104b51:	89 04 24             	mov    %eax,(%esp)
80104b54:	e8 14 01 00 00       	call   80104c6d <holding>
80104b59:	85 c0                	test   %eax,%eax
80104b5b:	74 0c                	je     80104b69 <acquire+0x26>
    panic("acquire");
80104b5d:	c7 04 24 45 85 10 80 	movl   $0x80108545,(%esp)
80104b64:	e8 dd b9 ff ff       	call   80100546 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80104b69:	90                   	nop
80104b6a:	8b 45 08             	mov    0x8(%ebp),%eax
80104b6d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80104b74:	00 
80104b75:	89 04 24             	mov    %eax,(%esp)
80104b78:	e8 80 ff ff ff       	call   80104afd <xchg>
80104b7d:	85 c0                	test   %eax,%eax
80104b7f:	75 e9                	jne    80104b6a <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80104b81:	8b 45 08             	mov    0x8(%ebp),%eax
80104b84:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104b8b:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80104b8e:	8b 45 08             	mov    0x8(%ebp),%eax
80104b91:	83 c0 0c             	add    $0xc,%eax
80104b94:	89 44 24 04          	mov    %eax,0x4(%esp)
80104b98:	8d 45 08             	lea    0x8(%ebp),%eax
80104b9b:	89 04 24             	mov    %eax,(%esp)
80104b9e:	e8 51 00 00 00       	call   80104bf4 <getcallerpcs>
}
80104ba3:	c9                   	leave  
80104ba4:	c3                   	ret    

80104ba5 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104ba5:	55                   	push   %ebp
80104ba6:	89 e5                	mov    %esp,%ebp
80104ba8:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80104bab:	8b 45 08             	mov    0x8(%ebp),%eax
80104bae:	89 04 24             	mov    %eax,(%esp)
80104bb1:	e8 b7 00 00 00       	call   80104c6d <holding>
80104bb6:	85 c0                	test   %eax,%eax
80104bb8:	75 0c                	jne    80104bc6 <release+0x21>
    panic("release");
80104bba:	c7 04 24 4d 85 10 80 	movl   $0x8010854d,(%esp)
80104bc1:	e8 80 b9 ff ff       	call   80100546 <panic>

  lk->pcs[0] = 0;
80104bc6:	8b 45 08             	mov    0x8(%ebp),%eax
80104bc9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104bd0:	8b 45 08             	mov    0x8(%ebp),%eax
80104bd3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80104bda:	8b 45 08             	mov    0x8(%ebp),%eax
80104bdd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104be4:	00 
80104be5:	89 04 24             	mov    %eax,(%esp)
80104be8:	e8 10 ff ff ff       	call   80104afd <xchg>

  popcli();
80104bed:	e8 ed 00 00 00       	call   80104cdf <popcli>
}
80104bf2:	c9                   	leave  
80104bf3:	c3                   	ret    

80104bf4 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104bf4:	55                   	push   %ebp
80104bf5:	89 e5                	mov    %esp,%ebp
80104bf7:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80104bfa:	8b 45 08             	mov    0x8(%ebp),%eax
80104bfd:	83 e8 08             	sub    $0x8,%eax
80104c00:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104c03:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104c0a:	eb 38                	jmp    80104c44 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104c0c:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104c10:	74 53                	je     80104c65 <getcallerpcs+0x71>
80104c12:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104c19:	76 4a                	jbe    80104c65 <getcallerpcs+0x71>
80104c1b:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104c1f:	74 44                	je     80104c65 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104c21:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c24:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104c2b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c2e:	01 c2                	add    %eax,%edx
80104c30:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c33:	8b 40 04             	mov    0x4(%eax),%eax
80104c36:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104c38:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c3b:	8b 00                	mov    (%eax),%eax
80104c3d:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104c40:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104c44:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104c48:	7e c2                	jle    80104c0c <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104c4a:	eb 19                	jmp    80104c65 <getcallerpcs+0x71>
    pcs[i] = 0;
80104c4c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c4f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104c56:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c59:	01 d0                	add    %edx,%eax
80104c5b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104c61:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104c65:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104c69:	7e e1                	jle    80104c4c <getcallerpcs+0x58>
    pcs[i] = 0;
}
80104c6b:	c9                   	leave  
80104c6c:	c3                   	ret    

80104c6d <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104c6d:	55                   	push   %ebp
80104c6e:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80104c70:	8b 45 08             	mov    0x8(%ebp),%eax
80104c73:	8b 00                	mov    (%eax),%eax
80104c75:	85 c0                	test   %eax,%eax
80104c77:	74 17                	je     80104c90 <holding+0x23>
80104c79:	8b 45 08             	mov    0x8(%ebp),%eax
80104c7c:	8b 50 08             	mov    0x8(%eax),%edx
80104c7f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c85:	39 c2                	cmp    %eax,%edx
80104c87:	75 07                	jne    80104c90 <holding+0x23>
80104c89:	b8 01 00 00 00       	mov    $0x1,%eax
80104c8e:	eb 05                	jmp    80104c95 <holding+0x28>
80104c90:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c95:	5d                   	pop    %ebp
80104c96:	c3                   	ret    

80104c97 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104c97:	55                   	push   %ebp
80104c98:	89 e5                	mov    %esp,%ebp
80104c9a:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80104c9d:	e8 3a fe ff ff       	call   80104adc <readeflags>
80104ca2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80104ca5:	e8 47 fe ff ff       	call   80104af1 <cli>
  if(cpu->ncli++ == 0)
80104caa:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cb0:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80104cb6:	85 d2                	test   %edx,%edx
80104cb8:	0f 94 c1             	sete   %cl
80104cbb:	83 c2 01             	add    $0x1,%edx
80104cbe:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80104cc4:	84 c9                	test   %cl,%cl
80104cc6:	74 15                	je     80104cdd <pushcli+0x46>
    cpu->intena = eflags & FL_IF;
80104cc8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cce:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104cd1:	81 e2 00 02 00 00    	and    $0x200,%edx
80104cd7:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104cdd:	c9                   	leave  
80104cde:	c3                   	ret    

80104cdf <popcli>:

void
popcli(void)
{
80104cdf:	55                   	push   %ebp
80104ce0:	89 e5                	mov    %esp,%ebp
80104ce2:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80104ce5:	e8 f2 fd ff ff       	call   80104adc <readeflags>
80104cea:	25 00 02 00 00       	and    $0x200,%eax
80104cef:	85 c0                	test   %eax,%eax
80104cf1:	74 0c                	je     80104cff <popcli+0x20>
    panic("popcli - interruptible");
80104cf3:	c7 04 24 55 85 10 80 	movl   $0x80108555,(%esp)
80104cfa:	e8 47 b8 ff ff       	call   80100546 <panic>
  if(--cpu->ncli < 0)
80104cff:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d05:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80104d0b:	83 ea 01             	sub    $0x1,%edx
80104d0e:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80104d14:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104d1a:	85 c0                	test   %eax,%eax
80104d1c:	79 0c                	jns    80104d2a <popcli+0x4b>
    panic("popcli");
80104d1e:	c7 04 24 6c 85 10 80 	movl   $0x8010856c,(%esp)
80104d25:	e8 1c b8 ff ff       	call   80100546 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80104d2a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d30:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104d36:	85 c0                	test   %eax,%eax
80104d38:	75 15                	jne    80104d4f <popcli+0x70>
80104d3a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d40:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104d46:	85 c0                	test   %eax,%eax
80104d48:	74 05                	je     80104d4f <popcli+0x70>
    sti();
80104d4a:	e8 a8 fd ff ff       	call   80104af7 <sti>
}
80104d4f:	c9                   	leave  
80104d50:	c3                   	ret    
80104d51:	66 90                	xchg   %ax,%ax
80104d53:	90                   	nop

80104d54 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80104d54:	55                   	push   %ebp
80104d55:	89 e5                	mov    %esp,%ebp
80104d57:	57                   	push   %edi
80104d58:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104d59:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d5c:	8b 55 10             	mov    0x10(%ebp),%edx
80104d5f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d62:	89 cb                	mov    %ecx,%ebx
80104d64:	89 df                	mov    %ebx,%edi
80104d66:	89 d1                	mov    %edx,%ecx
80104d68:	fc                   	cld    
80104d69:	f3 aa                	rep stos %al,%es:(%edi)
80104d6b:	89 ca                	mov    %ecx,%edx
80104d6d:	89 fb                	mov    %edi,%ebx
80104d6f:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104d72:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80104d75:	5b                   	pop    %ebx
80104d76:	5f                   	pop    %edi
80104d77:	5d                   	pop    %ebp
80104d78:	c3                   	ret    

80104d79 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80104d79:	55                   	push   %ebp
80104d7a:	89 e5                	mov    %esp,%ebp
80104d7c:	57                   	push   %edi
80104d7d:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104d7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d81:	8b 55 10             	mov    0x10(%ebp),%edx
80104d84:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d87:	89 cb                	mov    %ecx,%ebx
80104d89:	89 df                	mov    %ebx,%edi
80104d8b:	89 d1                	mov    %edx,%ecx
80104d8d:	fc                   	cld    
80104d8e:	f3 ab                	rep stos %eax,%es:(%edi)
80104d90:	89 ca                	mov    %ecx,%edx
80104d92:	89 fb                	mov    %edi,%ebx
80104d94:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104d97:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80104d9a:	5b                   	pop    %ebx
80104d9b:	5f                   	pop    %edi
80104d9c:	5d                   	pop    %ebp
80104d9d:	c3                   	ret    

80104d9e <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104d9e:	55                   	push   %ebp
80104d9f:	89 e5                	mov    %esp,%ebp
80104da1:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80104da4:	8b 45 08             	mov    0x8(%ebp),%eax
80104da7:	83 e0 03             	and    $0x3,%eax
80104daa:	85 c0                	test   %eax,%eax
80104dac:	75 49                	jne    80104df7 <memset+0x59>
80104dae:	8b 45 10             	mov    0x10(%ebp),%eax
80104db1:	83 e0 03             	and    $0x3,%eax
80104db4:	85 c0                	test   %eax,%eax
80104db6:	75 3f                	jne    80104df7 <memset+0x59>
    c &= 0xFF;
80104db8:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104dbf:	8b 45 10             	mov    0x10(%ebp),%eax
80104dc2:	c1 e8 02             	shr    $0x2,%eax
80104dc5:	89 c2                	mov    %eax,%edx
80104dc7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dca:	89 c1                	mov    %eax,%ecx
80104dcc:	c1 e1 18             	shl    $0x18,%ecx
80104dcf:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dd2:	c1 e0 10             	shl    $0x10,%eax
80104dd5:	09 c1                	or     %eax,%ecx
80104dd7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dda:	c1 e0 08             	shl    $0x8,%eax
80104ddd:	09 c8                	or     %ecx,%eax
80104ddf:	0b 45 0c             	or     0xc(%ebp),%eax
80104de2:	89 54 24 08          	mov    %edx,0x8(%esp)
80104de6:	89 44 24 04          	mov    %eax,0x4(%esp)
80104dea:	8b 45 08             	mov    0x8(%ebp),%eax
80104ded:	89 04 24             	mov    %eax,(%esp)
80104df0:	e8 84 ff ff ff       	call   80104d79 <stosl>
80104df5:	eb 19                	jmp    80104e10 <memset+0x72>
  } else
    stosb(dst, c, n);
80104df7:	8b 45 10             	mov    0x10(%ebp),%eax
80104dfa:	89 44 24 08          	mov    %eax,0x8(%esp)
80104dfe:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e01:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e05:	8b 45 08             	mov    0x8(%ebp),%eax
80104e08:	89 04 24             	mov    %eax,(%esp)
80104e0b:	e8 44 ff ff ff       	call   80104d54 <stosb>
  return dst;
80104e10:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104e13:	c9                   	leave  
80104e14:	c3                   	ret    

80104e15 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104e15:	55                   	push   %ebp
80104e16:	89 e5                	mov    %esp,%ebp
80104e18:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80104e1b:	8b 45 08             	mov    0x8(%ebp),%eax
80104e1e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104e21:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e24:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104e27:	eb 32                	jmp    80104e5b <memcmp+0x46>
    if(*s1 != *s2)
80104e29:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e2c:	0f b6 10             	movzbl (%eax),%edx
80104e2f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e32:	0f b6 00             	movzbl (%eax),%eax
80104e35:	38 c2                	cmp    %al,%dl
80104e37:	74 1a                	je     80104e53 <memcmp+0x3e>
      return *s1 - *s2;
80104e39:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e3c:	0f b6 00             	movzbl (%eax),%eax
80104e3f:	0f b6 d0             	movzbl %al,%edx
80104e42:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e45:	0f b6 00             	movzbl (%eax),%eax
80104e48:	0f b6 c0             	movzbl %al,%eax
80104e4b:	89 d1                	mov    %edx,%ecx
80104e4d:	29 c1                	sub    %eax,%ecx
80104e4f:	89 c8                	mov    %ecx,%eax
80104e51:	eb 1c                	jmp    80104e6f <memcmp+0x5a>
    s1++, s2++;
80104e53:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104e57:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80104e5b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104e5f:	0f 95 c0             	setne  %al
80104e62:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104e66:	84 c0                	test   %al,%al
80104e68:	75 bf                	jne    80104e29 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80104e6a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e6f:	c9                   	leave  
80104e70:	c3                   	ret    

80104e71 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104e71:	55                   	push   %ebp
80104e72:	89 e5                	mov    %esp,%ebp
80104e74:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104e77:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e7a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104e7d:	8b 45 08             	mov    0x8(%ebp),%eax
80104e80:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104e83:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e86:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104e89:	73 54                	jae    80104edf <memmove+0x6e>
80104e8b:	8b 45 10             	mov    0x10(%ebp),%eax
80104e8e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104e91:	01 d0                	add    %edx,%eax
80104e93:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104e96:	76 47                	jbe    80104edf <memmove+0x6e>
    s += n;
80104e98:	8b 45 10             	mov    0x10(%ebp),%eax
80104e9b:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104e9e:	8b 45 10             	mov    0x10(%ebp),%eax
80104ea1:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104ea4:	eb 13                	jmp    80104eb9 <memmove+0x48>
      *--d = *--s;
80104ea6:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104eaa:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104eae:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104eb1:	0f b6 10             	movzbl (%eax),%edx
80104eb4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104eb7:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80104eb9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104ebd:	0f 95 c0             	setne  %al
80104ec0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104ec4:	84 c0                	test   %al,%al
80104ec6:	75 de                	jne    80104ea6 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80104ec8:	eb 25                	jmp    80104eef <memmove+0x7e>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80104eca:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ecd:	0f b6 10             	movzbl (%eax),%edx
80104ed0:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ed3:	88 10                	mov    %dl,(%eax)
80104ed5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104ed9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104edd:	eb 01                	jmp    80104ee0 <memmove+0x6f>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80104edf:	90                   	nop
80104ee0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104ee4:	0f 95 c0             	setne  %al
80104ee7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104eeb:	84 c0                	test   %al,%al
80104eed:	75 db                	jne    80104eca <memmove+0x59>
      *d++ = *s++;

  return dst;
80104eef:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104ef2:	c9                   	leave  
80104ef3:	c3                   	ret    

80104ef4 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104ef4:	55                   	push   %ebp
80104ef5:	89 e5                	mov    %esp,%ebp
80104ef7:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80104efa:	8b 45 10             	mov    0x10(%ebp),%eax
80104efd:	89 44 24 08          	mov    %eax,0x8(%esp)
80104f01:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f04:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f08:	8b 45 08             	mov    0x8(%ebp),%eax
80104f0b:	89 04 24             	mov    %eax,(%esp)
80104f0e:	e8 5e ff ff ff       	call   80104e71 <memmove>
}
80104f13:	c9                   	leave  
80104f14:	c3                   	ret    

80104f15 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104f15:	55                   	push   %ebp
80104f16:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104f18:	eb 0c                	jmp    80104f26 <strncmp+0x11>
    n--, p++, q++;
80104f1a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104f1e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104f22:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80104f26:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f2a:	74 1a                	je     80104f46 <strncmp+0x31>
80104f2c:	8b 45 08             	mov    0x8(%ebp),%eax
80104f2f:	0f b6 00             	movzbl (%eax),%eax
80104f32:	84 c0                	test   %al,%al
80104f34:	74 10                	je     80104f46 <strncmp+0x31>
80104f36:	8b 45 08             	mov    0x8(%ebp),%eax
80104f39:	0f b6 10             	movzbl (%eax),%edx
80104f3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f3f:	0f b6 00             	movzbl (%eax),%eax
80104f42:	38 c2                	cmp    %al,%dl
80104f44:	74 d4                	je     80104f1a <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80104f46:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f4a:	75 07                	jne    80104f53 <strncmp+0x3e>
    return 0;
80104f4c:	b8 00 00 00 00       	mov    $0x0,%eax
80104f51:	eb 18                	jmp    80104f6b <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
80104f53:	8b 45 08             	mov    0x8(%ebp),%eax
80104f56:	0f b6 00             	movzbl (%eax),%eax
80104f59:	0f b6 d0             	movzbl %al,%edx
80104f5c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f5f:	0f b6 00             	movzbl (%eax),%eax
80104f62:	0f b6 c0             	movzbl %al,%eax
80104f65:	89 d1                	mov    %edx,%ecx
80104f67:	29 c1                	sub    %eax,%ecx
80104f69:	89 c8                	mov    %ecx,%eax
}
80104f6b:	5d                   	pop    %ebp
80104f6c:	c3                   	ret    

80104f6d <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104f6d:	55                   	push   %ebp
80104f6e:	89 e5                	mov    %esp,%ebp
80104f70:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80104f73:	8b 45 08             	mov    0x8(%ebp),%eax
80104f76:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104f79:	90                   	nop
80104f7a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f7e:	0f 9f c0             	setg   %al
80104f81:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104f85:	84 c0                	test   %al,%al
80104f87:	74 30                	je     80104fb9 <strncpy+0x4c>
80104f89:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f8c:	0f b6 10             	movzbl (%eax),%edx
80104f8f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f92:	88 10                	mov    %dl,(%eax)
80104f94:	8b 45 08             	mov    0x8(%ebp),%eax
80104f97:	0f b6 00             	movzbl (%eax),%eax
80104f9a:	84 c0                	test   %al,%al
80104f9c:	0f 95 c0             	setne  %al
80104f9f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104fa3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80104fa7:	84 c0                	test   %al,%al
80104fa9:	75 cf                	jne    80104f7a <strncpy+0xd>
    ;
  while(n-- > 0)
80104fab:	eb 0c                	jmp    80104fb9 <strncpy+0x4c>
    *s++ = 0;
80104fad:	8b 45 08             	mov    0x8(%ebp),%eax
80104fb0:	c6 00 00             	movb   $0x0,(%eax)
80104fb3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104fb7:	eb 01                	jmp    80104fba <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80104fb9:	90                   	nop
80104fba:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104fbe:	0f 9f c0             	setg   %al
80104fc1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104fc5:	84 c0                	test   %al,%al
80104fc7:	75 e4                	jne    80104fad <strncpy+0x40>
    *s++ = 0;
  return os;
80104fc9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104fcc:	c9                   	leave  
80104fcd:	c3                   	ret    

80104fce <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104fce:	55                   	push   %ebp
80104fcf:	89 e5                	mov    %esp,%ebp
80104fd1:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80104fd4:	8b 45 08             	mov    0x8(%ebp),%eax
80104fd7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104fda:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104fde:	7f 05                	jg     80104fe5 <safestrcpy+0x17>
    return os;
80104fe0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fe3:	eb 35                	jmp    8010501a <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80104fe5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104fe9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104fed:	7e 22                	jle    80105011 <safestrcpy+0x43>
80104fef:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ff2:	0f b6 10             	movzbl (%eax),%edx
80104ff5:	8b 45 08             	mov    0x8(%ebp),%eax
80104ff8:	88 10                	mov    %dl,(%eax)
80104ffa:	8b 45 08             	mov    0x8(%ebp),%eax
80104ffd:	0f b6 00             	movzbl (%eax),%eax
80105000:	84 c0                	test   %al,%al
80105002:	0f 95 c0             	setne  %al
80105005:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105009:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
8010500d:	84 c0                	test   %al,%al
8010500f:	75 d4                	jne    80104fe5 <safestrcpy+0x17>
    ;
  *s = 0;
80105011:	8b 45 08             	mov    0x8(%ebp),%eax
80105014:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105017:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010501a:	c9                   	leave  
8010501b:	c3                   	ret    

8010501c <strlen>:

int
strlen(const char *s)
{
8010501c:	55                   	push   %ebp
8010501d:	89 e5                	mov    %esp,%ebp
8010501f:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105022:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105029:	eb 04                	jmp    8010502f <strlen+0x13>
8010502b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010502f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105032:	8b 45 08             	mov    0x8(%ebp),%eax
80105035:	01 d0                	add    %edx,%eax
80105037:	0f b6 00             	movzbl (%eax),%eax
8010503a:	84 c0                	test   %al,%al
8010503c:	75 ed                	jne    8010502b <strlen+0xf>
    ;
  return n;
8010503e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105041:	c9                   	leave  
80105042:	c3                   	ret    
80105043:	90                   	nop

80105044 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105044:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105048:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
8010504c:	55                   	push   %ebp
  pushl %ebx
8010504d:	53                   	push   %ebx
  pushl %esi
8010504e:	56                   	push   %esi
  pushl %edi
8010504f:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105050:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105052:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105054:	5f                   	pop    %edi
  popl %esi
80105055:	5e                   	pop    %esi
  popl %ebx
80105056:	5b                   	pop    %ebx
  popl %ebp
80105057:	5d                   	pop    %ebp
  ret
80105058:	c3                   	ret    
80105059:	66 90                	xchg   %ax,%ax
8010505b:	90                   	nop

8010505c <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010505c:	55                   	push   %ebp
8010505d:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
8010505f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105065:	8b 00                	mov    (%eax),%eax
80105067:	3b 45 08             	cmp    0x8(%ebp),%eax
8010506a:	76 12                	jbe    8010507e <fetchint+0x22>
8010506c:	8b 45 08             	mov    0x8(%ebp),%eax
8010506f:	8d 50 04             	lea    0x4(%eax),%edx
80105072:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105078:	8b 00                	mov    (%eax),%eax
8010507a:	39 c2                	cmp    %eax,%edx
8010507c:	76 07                	jbe    80105085 <fetchint+0x29>
    return -1;
8010507e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105083:	eb 0f                	jmp    80105094 <fetchint+0x38>
  *ip = *(int*)(addr);
80105085:	8b 45 08             	mov    0x8(%ebp),%eax
80105088:	8b 10                	mov    (%eax),%edx
8010508a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010508d:	89 10                	mov    %edx,(%eax)
  return 0;
8010508f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105094:	5d                   	pop    %ebp
80105095:	c3                   	ret    

80105096 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105096:	55                   	push   %ebp
80105097:	89 e5                	mov    %esp,%ebp
80105099:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
8010509c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050a2:	8b 00                	mov    (%eax),%eax
801050a4:	3b 45 08             	cmp    0x8(%ebp),%eax
801050a7:	77 07                	ja     801050b0 <fetchstr+0x1a>
    return -1;
801050a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050ae:	eb 48                	jmp    801050f8 <fetchstr+0x62>
  *pp = (char*)addr;
801050b0:	8b 55 08             	mov    0x8(%ebp),%edx
801050b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801050b6:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
801050b8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050be:	8b 00                	mov    (%eax),%eax
801050c0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801050c3:	8b 45 0c             	mov    0xc(%ebp),%eax
801050c6:	8b 00                	mov    (%eax),%eax
801050c8:	89 45 fc             	mov    %eax,-0x4(%ebp)
801050cb:	eb 1e                	jmp    801050eb <fetchstr+0x55>
    if(*s == 0)
801050cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050d0:	0f b6 00             	movzbl (%eax),%eax
801050d3:	84 c0                	test   %al,%al
801050d5:	75 10                	jne    801050e7 <fetchstr+0x51>
      return s - *pp;
801050d7:	8b 55 fc             	mov    -0x4(%ebp),%edx
801050da:	8b 45 0c             	mov    0xc(%ebp),%eax
801050dd:	8b 00                	mov    (%eax),%eax
801050df:	89 d1                	mov    %edx,%ecx
801050e1:	29 c1                	sub    %eax,%ecx
801050e3:	89 c8                	mov    %ecx,%eax
801050e5:	eb 11                	jmp    801050f8 <fetchstr+0x62>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
801050e7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801050eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050ee:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801050f1:	72 da                	jb     801050cd <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
801050f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801050f8:	c9                   	leave  
801050f9:	c3                   	ret    

801050fa <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801050fa:	55                   	push   %ebp
801050fb:	89 e5                	mov    %esp,%ebp
801050fd:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105100:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105106:	8b 40 18             	mov    0x18(%eax),%eax
80105109:	8b 50 44             	mov    0x44(%eax),%edx
8010510c:	8b 45 08             	mov    0x8(%ebp),%eax
8010510f:	c1 e0 02             	shl    $0x2,%eax
80105112:	01 d0                	add    %edx,%eax
80105114:	8d 50 04             	lea    0x4(%eax),%edx
80105117:	8b 45 0c             	mov    0xc(%ebp),%eax
8010511a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010511e:	89 14 24             	mov    %edx,(%esp)
80105121:	e8 36 ff ff ff       	call   8010505c <fetchint>
}
80105126:	c9                   	leave  
80105127:	c3                   	ret    

80105128 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105128:	55                   	push   %ebp
80105129:	89 e5                	mov    %esp,%ebp
8010512b:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
8010512e:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105131:	89 44 24 04          	mov    %eax,0x4(%esp)
80105135:	8b 45 08             	mov    0x8(%ebp),%eax
80105138:	89 04 24             	mov    %eax,(%esp)
8010513b:	e8 ba ff ff ff       	call   801050fa <argint>
80105140:	85 c0                	test   %eax,%eax
80105142:	79 07                	jns    8010514b <argptr+0x23>
    return -1;
80105144:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105149:	eb 3d                	jmp    80105188 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
8010514b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010514e:	89 c2                	mov    %eax,%edx
80105150:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105156:	8b 00                	mov    (%eax),%eax
80105158:	39 c2                	cmp    %eax,%edx
8010515a:	73 16                	jae    80105172 <argptr+0x4a>
8010515c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010515f:	89 c2                	mov    %eax,%edx
80105161:	8b 45 10             	mov    0x10(%ebp),%eax
80105164:	01 c2                	add    %eax,%edx
80105166:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010516c:	8b 00                	mov    (%eax),%eax
8010516e:	39 c2                	cmp    %eax,%edx
80105170:	76 07                	jbe    80105179 <argptr+0x51>
    return -1;
80105172:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105177:	eb 0f                	jmp    80105188 <argptr+0x60>
  *pp = (char*)i;
80105179:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010517c:	89 c2                	mov    %eax,%edx
8010517e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105181:	89 10                	mov    %edx,(%eax)
  return 0;
80105183:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105188:	c9                   	leave  
80105189:	c3                   	ret    

8010518a <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010518a:	55                   	push   %ebp
8010518b:	89 e5                	mov    %esp,%ebp
8010518d:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105190:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105193:	89 44 24 04          	mov    %eax,0x4(%esp)
80105197:	8b 45 08             	mov    0x8(%ebp),%eax
8010519a:	89 04 24             	mov    %eax,(%esp)
8010519d:	e8 58 ff ff ff       	call   801050fa <argint>
801051a2:	85 c0                	test   %eax,%eax
801051a4:	79 07                	jns    801051ad <argstr+0x23>
    return -1;
801051a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051ab:	eb 12                	jmp    801051bf <argstr+0x35>
  return fetchstr(addr, pp);
801051ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051b0:	8b 55 0c             	mov    0xc(%ebp),%edx
801051b3:	89 54 24 04          	mov    %edx,0x4(%esp)
801051b7:	89 04 24             	mov    %eax,(%esp)
801051ba:	e8 d7 fe ff ff       	call   80105096 <fetchstr>
}
801051bf:	c9                   	leave  
801051c0:	c3                   	ret    

801051c1 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
801051c1:	55                   	push   %ebp
801051c2:	89 e5                	mov    %esp,%ebp
801051c4:	53                   	push   %ebx
801051c5:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
801051c8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051ce:	8b 40 18             	mov    0x18(%eax),%eax
801051d1:	8b 40 1c             	mov    0x1c(%eax),%eax
801051d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801051d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801051db:	7e 30                	jle    8010520d <syscall+0x4c>
801051dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051e0:	83 f8 15             	cmp    $0x15,%eax
801051e3:	77 28                	ja     8010520d <syscall+0x4c>
801051e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051e8:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801051ef:	85 c0                	test   %eax,%eax
801051f1:	74 1a                	je     8010520d <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
801051f3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051f9:	8b 58 18             	mov    0x18(%eax),%ebx
801051fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051ff:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105206:	ff d0                	call   *%eax
80105208:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010520b:	eb 3d                	jmp    8010524a <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
8010520d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105213:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105216:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
8010521c:	8b 40 10             	mov    0x10(%eax),%eax
8010521f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105222:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105226:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010522a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010522e:	c7 04 24 73 85 10 80 	movl   $0x80108573,(%esp)
80105235:	e8 70 b1 ff ff       	call   801003aa <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
8010523a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105240:	8b 40 18             	mov    0x18(%eax),%eax
80105243:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010524a:	83 c4 24             	add    $0x24,%esp
8010524d:	5b                   	pop    %ebx
8010524e:	5d                   	pop    %ebp
8010524f:	c3                   	ret    

80105250 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105250:	55                   	push   %ebp
80105251:	89 e5                	mov    %esp,%ebp
80105253:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105256:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105259:	89 44 24 04          	mov    %eax,0x4(%esp)
8010525d:	8b 45 08             	mov    0x8(%ebp),%eax
80105260:	89 04 24             	mov    %eax,(%esp)
80105263:	e8 92 fe ff ff       	call   801050fa <argint>
80105268:	85 c0                	test   %eax,%eax
8010526a:	79 07                	jns    80105273 <argfd+0x23>
    return -1;
8010526c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105271:	eb 50                	jmp    801052c3 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105273:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105276:	85 c0                	test   %eax,%eax
80105278:	78 21                	js     8010529b <argfd+0x4b>
8010527a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010527d:	83 f8 0f             	cmp    $0xf,%eax
80105280:	7f 19                	jg     8010529b <argfd+0x4b>
80105282:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105288:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010528b:	83 c2 08             	add    $0x8,%edx
8010528e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105292:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105295:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105299:	75 07                	jne    801052a2 <argfd+0x52>
    return -1;
8010529b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052a0:	eb 21                	jmp    801052c3 <argfd+0x73>
  if(pfd)
801052a2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801052a6:	74 08                	je     801052b0 <argfd+0x60>
    *pfd = fd;
801052a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801052ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801052ae:	89 10                	mov    %edx,(%eax)
  if(pf)
801052b0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801052b4:	74 08                	je     801052be <argfd+0x6e>
    *pf = f;
801052b6:	8b 45 10             	mov    0x10(%ebp),%eax
801052b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801052bc:	89 10                	mov    %edx,(%eax)
  return 0;
801052be:	b8 00 00 00 00       	mov    $0x0,%eax
}
801052c3:	c9                   	leave  
801052c4:	c3                   	ret    

801052c5 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801052c5:	55                   	push   %ebp
801052c6:	89 e5                	mov    %esp,%ebp
801052c8:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801052cb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801052d2:	eb 30                	jmp    80105304 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
801052d4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052da:	8b 55 fc             	mov    -0x4(%ebp),%edx
801052dd:	83 c2 08             	add    $0x8,%edx
801052e0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801052e4:	85 c0                	test   %eax,%eax
801052e6:	75 18                	jne    80105300 <fdalloc+0x3b>
      proc->ofile[fd] = f;
801052e8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052ee:	8b 55 fc             	mov    -0x4(%ebp),%edx
801052f1:	8d 4a 08             	lea    0x8(%edx),%ecx
801052f4:	8b 55 08             	mov    0x8(%ebp),%edx
801052f7:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801052fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052fe:	eb 0f                	jmp    8010530f <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105300:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105304:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105308:	7e ca                	jle    801052d4 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
8010530a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010530f:	c9                   	leave  
80105310:	c3                   	ret    

80105311 <sys_dup>:

int
sys_dup(void)
{
80105311:	55                   	push   %ebp
80105312:	89 e5                	mov    %esp,%ebp
80105314:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105317:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010531a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010531e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105325:	00 
80105326:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010532d:	e8 1e ff ff ff       	call   80105250 <argfd>
80105332:	85 c0                	test   %eax,%eax
80105334:	79 07                	jns    8010533d <sys_dup+0x2c>
    return -1;
80105336:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010533b:	eb 29                	jmp    80105366 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
8010533d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105340:	89 04 24             	mov    %eax,(%esp)
80105343:	e8 7d ff ff ff       	call   801052c5 <fdalloc>
80105348:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010534b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010534f:	79 07                	jns    80105358 <sys_dup+0x47>
    return -1;
80105351:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105356:	eb 0e                	jmp    80105366 <sys_dup+0x55>
  filedup(f);
80105358:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010535b:	89 04 24             	mov    %eax,(%esp)
8010535e:	e8 39 bc ff ff       	call   80100f9c <filedup>
  return fd;
80105363:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105366:	c9                   	leave  
80105367:	c3                   	ret    

80105368 <sys_read>:

int
sys_read(void)
{
80105368:	55                   	push   %ebp
80105369:	89 e5                	mov    %esp,%ebp
8010536b:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010536e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105371:	89 44 24 08          	mov    %eax,0x8(%esp)
80105375:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010537c:	00 
8010537d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105384:	e8 c7 fe ff ff       	call   80105250 <argfd>
80105389:	85 c0                	test   %eax,%eax
8010538b:	78 35                	js     801053c2 <sys_read+0x5a>
8010538d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105390:	89 44 24 04          	mov    %eax,0x4(%esp)
80105394:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010539b:	e8 5a fd ff ff       	call   801050fa <argint>
801053a0:	85 c0                	test   %eax,%eax
801053a2:	78 1e                	js     801053c2 <sys_read+0x5a>
801053a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053a7:	89 44 24 08          	mov    %eax,0x8(%esp)
801053ab:	8d 45 ec             	lea    -0x14(%ebp),%eax
801053ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801053b2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801053b9:	e8 6a fd ff ff       	call   80105128 <argptr>
801053be:	85 c0                	test   %eax,%eax
801053c0:	79 07                	jns    801053c9 <sys_read+0x61>
    return -1;
801053c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053c7:	eb 19                	jmp    801053e2 <sys_read+0x7a>
  return fileread(f, p, n);
801053c9:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801053cc:	8b 55 ec             	mov    -0x14(%ebp),%edx
801053cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053d2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801053d6:	89 54 24 04          	mov    %edx,0x4(%esp)
801053da:	89 04 24             	mov    %eax,(%esp)
801053dd:	e8 27 bd ff ff       	call   80101109 <fileread>
}
801053e2:	c9                   	leave  
801053e3:	c3                   	ret    

801053e4 <sys_write>:

int
sys_write(void)
{
801053e4:	55                   	push   %ebp
801053e5:	89 e5                	mov    %esp,%ebp
801053e7:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801053ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
801053ed:	89 44 24 08          	mov    %eax,0x8(%esp)
801053f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801053f8:	00 
801053f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105400:	e8 4b fe ff ff       	call   80105250 <argfd>
80105405:	85 c0                	test   %eax,%eax
80105407:	78 35                	js     8010543e <sys_write+0x5a>
80105409:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010540c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105410:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105417:	e8 de fc ff ff       	call   801050fa <argint>
8010541c:	85 c0                	test   %eax,%eax
8010541e:	78 1e                	js     8010543e <sys_write+0x5a>
80105420:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105423:	89 44 24 08          	mov    %eax,0x8(%esp)
80105427:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010542a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010542e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105435:	e8 ee fc ff ff       	call   80105128 <argptr>
8010543a:	85 c0                	test   %eax,%eax
8010543c:	79 07                	jns    80105445 <sys_write+0x61>
    return -1;
8010543e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105443:	eb 19                	jmp    8010545e <sys_write+0x7a>
  return filewrite(f, p, n);
80105445:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105448:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010544b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010544e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105452:	89 54 24 04          	mov    %edx,0x4(%esp)
80105456:	89 04 24             	mov    %eax,(%esp)
80105459:	e8 67 bd ff ff       	call   801011c5 <filewrite>
}
8010545e:	c9                   	leave  
8010545f:	c3                   	ret    

80105460 <sys_close>:

int
sys_close(void)
{
80105460:	55                   	push   %ebp
80105461:	89 e5                	mov    %esp,%ebp
80105463:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105466:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105469:	89 44 24 08          	mov    %eax,0x8(%esp)
8010546d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105470:	89 44 24 04          	mov    %eax,0x4(%esp)
80105474:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010547b:	e8 d0 fd ff ff       	call   80105250 <argfd>
80105480:	85 c0                	test   %eax,%eax
80105482:	79 07                	jns    8010548b <sys_close+0x2b>
    return -1;
80105484:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105489:	eb 24                	jmp    801054af <sys_close+0x4f>
  proc->ofile[fd] = 0;
8010548b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105491:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105494:	83 c2 08             	add    $0x8,%edx
80105497:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010549e:	00 
  fileclose(f);
8010549f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054a2:	89 04 24             	mov    %eax,(%esp)
801054a5:	e8 3a bb ff ff       	call   80100fe4 <fileclose>
  return 0;
801054aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054af:	c9                   	leave  
801054b0:	c3                   	ret    

801054b1 <sys_fstat>:

int
sys_fstat(void)
{
801054b1:	55                   	push   %ebp
801054b2:	89 e5                	mov    %esp,%ebp
801054b4:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801054b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801054ba:	89 44 24 08          	mov    %eax,0x8(%esp)
801054be:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801054c5:	00 
801054c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801054cd:	e8 7e fd ff ff       	call   80105250 <argfd>
801054d2:	85 c0                	test   %eax,%eax
801054d4:	78 1f                	js     801054f5 <sys_fstat+0x44>
801054d6:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801054dd:	00 
801054de:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054e1:	89 44 24 04          	mov    %eax,0x4(%esp)
801054e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801054ec:	e8 37 fc ff ff       	call   80105128 <argptr>
801054f1:	85 c0                	test   %eax,%eax
801054f3:	79 07                	jns    801054fc <sys_fstat+0x4b>
    return -1;
801054f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054fa:	eb 12                	jmp    8010550e <sys_fstat+0x5d>
  return filestat(f, st);
801054fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801054ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105502:	89 54 24 04          	mov    %edx,0x4(%esp)
80105506:	89 04 24             	mov    %eax,(%esp)
80105509:	e8 ac bb ff ff       	call   801010ba <filestat>
}
8010550e:	c9                   	leave  
8010550f:	c3                   	ret    

80105510 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105510:	55                   	push   %ebp
80105511:	89 e5                	mov    %esp,%ebp
80105513:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105516:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105519:	89 44 24 04          	mov    %eax,0x4(%esp)
8010551d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105524:	e8 61 fc ff ff       	call   8010518a <argstr>
80105529:	85 c0                	test   %eax,%eax
8010552b:	78 17                	js     80105544 <sys_link+0x34>
8010552d:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105530:	89 44 24 04          	mov    %eax,0x4(%esp)
80105534:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010553b:	e8 4a fc ff ff       	call   8010518a <argstr>
80105540:	85 c0                	test   %eax,%eax
80105542:	79 0a                	jns    8010554e <sys_link+0x3e>
    return -1;
80105544:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105549:	e9 3c 01 00 00       	jmp    8010568a <sys_link+0x17a>
  if((ip = namei(old)) == 0)
8010554e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105551:	89 04 24             	mov    %eax,(%esp)
80105554:	e8 f4 ce ff ff       	call   8010244d <namei>
80105559:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010555c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105560:	75 0a                	jne    8010556c <sys_link+0x5c>
    return -1;
80105562:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105567:	e9 1e 01 00 00       	jmp    8010568a <sys_link+0x17a>

  begin_trans();
8010556c:	e8 f7 dc ff ff       	call   80103268 <begin_trans>

  ilock(ip);
80105571:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105574:	89 04 24             	mov    %eax,(%esp)
80105577:	e8 10 c3 ff ff       	call   8010188c <ilock>
  if(ip->type == T_DIR){
8010557c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010557f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105583:	66 83 f8 01          	cmp    $0x1,%ax
80105587:	75 1a                	jne    801055a3 <sys_link+0x93>
    iunlockput(ip);
80105589:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010558c:	89 04 24             	mov    %eax,(%esp)
8010558f:	e8 7c c5 ff ff       	call   80101b10 <iunlockput>
    commit_trans();
80105594:	e8 18 dd ff ff       	call   801032b1 <commit_trans>
    return -1;
80105599:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010559e:	e9 e7 00 00 00       	jmp    8010568a <sys_link+0x17a>
  }

  ip->nlink++;
801055a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055a6:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801055aa:	8d 50 01             	lea    0x1(%eax),%edx
801055ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055b0:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801055b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055b7:	89 04 24             	mov    %eax,(%esp)
801055ba:	e8 11 c1 ff ff       	call   801016d0 <iupdate>
  iunlock(ip);
801055bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055c2:	89 04 24             	mov    %eax,(%esp)
801055c5:	e8 10 c4 ff ff       	call   801019da <iunlock>

  if((dp = nameiparent(new, name)) == 0)
801055ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
801055cd:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801055d0:	89 54 24 04          	mov    %edx,0x4(%esp)
801055d4:	89 04 24             	mov    %eax,(%esp)
801055d7:	e8 93 ce ff ff       	call   8010246f <nameiparent>
801055dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
801055df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801055e3:	74 68                	je     8010564d <sys_link+0x13d>
    goto bad;
  ilock(dp);
801055e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055e8:	89 04 24             	mov    %eax,(%esp)
801055eb:	e8 9c c2 ff ff       	call   8010188c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801055f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055f3:	8b 10                	mov    (%eax),%edx
801055f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055f8:	8b 00                	mov    (%eax),%eax
801055fa:	39 c2                	cmp    %eax,%edx
801055fc:	75 20                	jne    8010561e <sys_link+0x10e>
801055fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105601:	8b 40 04             	mov    0x4(%eax),%eax
80105604:	89 44 24 08          	mov    %eax,0x8(%esp)
80105608:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010560b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010560f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105612:	89 04 24             	mov    %eax,(%esp)
80105615:	e8 70 cb ff ff       	call   8010218a <dirlink>
8010561a:	85 c0                	test   %eax,%eax
8010561c:	79 0d                	jns    8010562b <sys_link+0x11b>
    iunlockput(dp);
8010561e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105621:	89 04 24             	mov    %eax,(%esp)
80105624:	e8 e7 c4 ff ff       	call   80101b10 <iunlockput>
    goto bad;
80105629:	eb 23                	jmp    8010564e <sys_link+0x13e>
  }
  iunlockput(dp);
8010562b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010562e:	89 04 24             	mov    %eax,(%esp)
80105631:	e8 da c4 ff ff       	call   80101b10 <iunlockput>
  iput(ip);
80105636:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105639:	89 04 24             	mov    %eax,(%esp)
8010563c:	e8 fe c3 ff ff       	call   80101a3f <iput>

  commit_trans();
80105641:	e8 6b dc ff ff       	call   801032b1 <commit_trans>

  return 0;
80105646:	b8 00 00 00 00       	mov    $0x0,%eax
8010564b:	eb 3d                	jmp    8010568a <sys_link+0x17a>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
8010564d:	90                   	nop
  commit_trans();

  return 0;

bad:
  ilock(ip);
8010564e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105651:	89 04 24             	mov    %eax,(%esp)
80105654:	e8 33 c2 ff ff       	call   8010188c <ilock>
  ip->nlink--;
80105659:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010565c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105660:	8d 50 ff             	lea    -0x1(%eax),%edx
80105663:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105666:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
8010566a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010566d:	89 04 24             	mov    %eax,(%esp)
80105670:	e8 5b c0 ff ff       	call   801016d0 <iupdate>
  iunlockput(ip);
80105675:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105678:	89 04 24             	mov    %eax,(%esp)
8010567b:	e8 90 c4 ff ff       	call   80101b10 <iunlockput>
  commit_trans();
80105680:	e8 2c dc ff ff       	call   801032b1 <commit_trans>
  return -1;
80105685:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010568a:	c9                   	leave  
8010568b:	c3                   	ret    

8010568c <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010568c:	55                   	push   %ebp
8010568d:	89 e5                	mov    %esp,%ebp
8010568f:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105692:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105699:	eb 4b                	jmp    801056e6 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010569b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010569e:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801056a5:	00 
801056a6:	89 44 24 08          	mov    %eax,0x8(%esp)
801056aa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801056ad:	89 44 24 04          	mov    %eax,0x4(%esp)
801056b1:	8b 45 08             	mov    0x8(%ebp),%eax
801056b4:	89 04 24             	mov    %eax,(%esp)
801056b7:	e8 dd c6 ff ff       	call   80101d99 <readi>
801056bc:	83 f8 10             	cmp    $0x10,%eax
801056bf:	74 0c                	je     801056cd <isdirempty+0x41>
      panic("isdirempty: readi");
801056c1:	c7 04 24 8f 85 10 80 	movl   $0x8010858f,(%esp)
801056c8:	e8 79 ae ff ff       	call   80100546 <panic>
    if(de.inum != 0)
801056cd:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801056d1:	66 85 c0             	test   %ax,%ax
801056d4:	74 07                	je     801056dd <isdirempty+0x51>
      return 0;
801056d6:	b8 00 00 00 00       	mov    $0x0,%eax
801056db:	eb 1b                	jmp    801056f8 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801056dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056e0:	83 c0 10             	add    $0x10,%eax
801056e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801056e9:	8b 45 08             	mov    0x8(%ebp),%eax
801056ec:	8b 40 18             	mov    0x18(%eax),%eax
801056ef:	39 c2                	cmp    %eax,%edx
801056f1:	72 a8                	jb     8010569b <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
801056f3:	b8 01 00 00 00       	mov    $0x1,%eax
}
801056f8:	c9                   	leave  
801056f9:	c3                   	ret    

801056fa <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801056fa:	55                   	push   %ebp
801056fb:	89 e5                	mov    %esp,%ebp
801056fd:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105700:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105703:	89 44 24 04          	mov    %eax,0x4(%esp)
80105707:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010570e:	e8 77 fa ff ff       	call   8010518a <argstr>
80105713:	85 c0                	test   %eax,%eax
80105715:	79 0a                	jns    80105721 <sys_unlink+0x27>
    return -1;
80105717:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010571c:	e9 aa 01 00 00       	jmp    801058cb <sys_unlink+0x1d1>
  if((dp = nameiparent(path, name)) == 0)
80105721:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105724:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105727:	89 54 24 04          	mov    %edx,0x4(%esp)
8010572b:	89 04 24             	mov    %eax,(%esp)
8010572e:	e8 3c cd ff ff       	call   8010246f <nameiparent>
80105733:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105736:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010573a:	75 0a                	jne    80105746 <sys_unlink+0x4c>
    return -1;
8010573c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105741:	e9 85 01 00 00       	jmp    801058cb <sys_unlink+0x1d1>

  begin_trans();
80105746:	e8 1d db ff ff       	call   80103268 <begin_trans>

  ilock(dp);
8010574b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010574e:	89 04 24             	mov    %eax,(%esp)
80105751:	e8 36 c1 ff ff       	call   8010188c <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105756:	c7 44 24 04 a1 85 10 	movl   $0x801085a1,0x4(%esp)
8010575d:	80 
8010575e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105761:	89 04 24             	mov    %eax,(%esp)
80105764:	e8 37 c9 ff ff       	call   801020a0 <namecmp>
80105769:	85 c0                	test   %eax,%eax
8010576b:	0f 84 45 01 00 00    	je     801058b6 <sys_unlink+0x1bc>
80105771:	c7 44 24 04 a3 85 10 	movl   $0x801085a3,0x4(%esp)
80105778:	80 
80105779:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010577c:	89 04 24             	mov    %eax,(%esp)
8010577f:	e8 1c c9 ff ff       	call   801020a0 <namecmp>
80105784:	85 c0                	test   %eax,%eax
80105786:	0f 84 2a 01 00 00    	je     801058b6 <sys_unlink+0x1bc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
8010578c:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010578f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105793:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105796:	89 44 24 04          	mov    %eax,0x4(%esp)
8010579a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010579d:	89 04 24             	mov    %eax,(%esp)
801057a0:	e8 1d c9 ff ff       	call   801020c2 <dirlookup>
801057a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801057a8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801057ac:	0f 84 03 01 00 00    	je     801058b5 <sys_unlink+0x1bb>
    goto bad;
  ilock(ip);
801057b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057b5:	89 04 24             	mov    %eax,(%esp)
801057b8:	e8 cf c0 ff ff       	call   8010188c <ilock>

  if(ip->nlink < 1)
801057bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057c0:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801057c4:	66 85 c0             	test   %ax,%ax
801057c7:	7f 0c                	jg     801057d5 <sys_unlink+0xdb>
    panic("unlink: nlink < 1");
801057c9:	c7 04 24 a6 85 10 80 	movl   $0x801085a6,(%esp)
801057d0:	e8 71 ad ff ff       	call   80100546 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801057d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057d8:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801057dc:	66 83 f8 01          	cmp    $0x1,%ax
801057e0:	75 1f                	jne    80105801 <sys_unlink+0x107>
801057e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057e5:	89 04 24             	mov    %eax,(%esp)
801057e8:	e8 9f fe ff ff       	call   8010568c <isdirempty>
801057ed:	85 c0                	test   %eax,%eax
801057ef:	75 10                	jne    80105801 <sys_unlink+0x107>
    iunlockput(ip);
801057f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057f4:	89 04 24             	mov    %eax,(%esp)
801057f7:	e8 14 c3 ff ff       	call   80101b10 <iunlockput>
    goto bad;
801057fc:	e9 b5 00 00 00       	jmp    801058b6 <sys_unlink+0x1bc>
  }

  memset(&de, 0, sizeof(de));
80105801:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105808:	00 
80105809:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105810:	00 
80105811:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105814:	89 04 24             	mov    %eax,(%esp)
80105817:	e8 82 f5 ff ff       	call   80104d9e <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010581c:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010581f:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105826:	00 
80105827:	89 44 24 08          	mov    %eax,0x8(%esp)
8010582b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010582e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105832:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105835:	89 04 24             	mov    %eax,(%esp)
80105838:	e8 ca c6 ff ff       	call   80101f07 <writei>
8010583d:	83 f8 10             	cmp    $0x10,%eax
80105840:	74 0c                	je     8010584e <sys_unlink+0x154>
    panic("unlink: writei");
80105842:	c7 04 24 b8 85 10 80 	movl   $0x801085b8,(%esp)
80105849:	e8 f8 ac ff ff       	call   80100546 <panic>
  if(ip->type == T_DIR){
8010584e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105851:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105855:	66 83 f8 01          	cmp    $0x1,%ax
80105859:	75 1c                	jne    80105877 <sys_unlink+0x17d>
    dp->nlink--;
8010585b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010585e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105862:	8d 50 ff             	lea    -0x1(%eax),%edx
80105865:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105868:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
8010586c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010586f:	89 04 24             	mov    %eax,(%esp)
80105872:	e8 59 be ff ff       	call   801016d0 <iupdate>
  }
  iunlockput(dp);
80105877:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010587a:	89 04 24             	mov    %eax,(%esp)
8010587d:	e8 8e c2 ff ff       	call   80101b10 <iunlockput>

  ip->nlink--;
80105882:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105885:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105889:	8d 50 ff             	lea    -0x1(%eax),%edx
8010588c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010588f:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105893:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105896:	89 04 24             	mov    %eax,(%esp)
80105899:	e8 32 be ff ff       	call   801016d0 <iupdate>
  iunlockput(ip);
8010589e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058a1:	89 04 24             	mov    %eax,(%esp)
801058a4:	e8 67 c2 ff ff       	call   80101b10 <iunlockput>

  commit_trans();
801058a9:	e8 03 da ff ff       	call   801032b1 <commit_trans>

  return 0;
801058ae:	b8 00 00 00 00       	mov    $0x0,%eax
801058b3:	eb 16                	jmp    801058cb <sys_unlink+0x1d1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
801058b5:	90                   	nop
  commit_trans();

  return 0;

bad:
  iunlockput(dp);
801058b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058b9:	89 04 24             	mov    %eax,(%esp)
801058bc:	e8 4f c2 ff ff       	call   80101b10 <iunlockput>
  commit_trans();
801058c1:	e8 eb d9 ff ff       	call   801032b1 <commit_trans>
  return -1;
801058c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801058cb:	c9                   	leave  
801058cc:	c3                   	ret    

801058cd <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801058cd:	55                   	push   %ebp
801058ce:	89 e5                	mov    %esp,%ebp
801058d0:	83 ec 48             	sub    $0x48,%esp
801058d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801058d6:	8b 55 10             	mov    0x10(%ebp),%edx
801058d9:	8b 45 14             	mov    0x14(%ebp),%eax
801058dc:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801058e0:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801058e4:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801058e8:	8d 45 de             	lea    -0x22(%ebp),%eax
801058eb:	89 44 24 04          	mov    %eax,0x4(%esp)
801058ef:	8b 45 08             	mov    0x8(%ebp),%eax
801058f2:	89 04 24             	mov    %eax,(%esp)
801058f5:	e8 75 cb ff ff       	call   8010246f <nameiparent>
801058fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105901:	75 0a                	jne    8010590d <create+0x40>
    return 0;
80105903:	b8 00 00 00 00       	mov    $0x0,%eax
80105908:	e9 7e 01 00 00       	jmp    80105a8b <create+0x1be>
  ilock(dp);
8010590d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105910:	89 04 24             	mov    %eax,(%esp)
80105913:	e8 74 bf ff ff       	call   8010188c <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105918:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010591b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010591f:	8d 45 de             	lea    -0x22(%ebp),%eax
80105922:	89 44 24 04          	mov    %eax,0x4(%esp)
80105926:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105929:	89 04 24             	mov    %eax,(%esp)
8010592c:	e8 91 c7 ff ff       	call   801020c2 <dirlookup>
80105931:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105934:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105938:	74 47                	je     80105981 <create+0xb4>
    iunlockput(dp);
8010593a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010593d:	89 04 24             	mov    %eax,(%esp)
80105940:	e8 cb c1 ff ff       	call   80101b10 <iunlockput>
    ilock(ip);
80105945:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105948:	89 04 24             	mov    %eax,(%esp)
8010594b:	e8 3c bf ff ff       	call   8010188c <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105950:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105955:	75 15                	jne    8010596c <create+0x9f>
80105957:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010595a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010595e:	66 83 f8 02          	cmp    $0x2,%ax
80105962:	75 08                	jne    8010596c <create+0x9f>
      return ip;
80105964:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105967:	e9 1f 01 00 00       	jmp    80105a8b <create+0x1be>
    iunlockput(ip);
8010596c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010596f:	89 04 24             	mov    %eax,(%esp)
80105972:	e8 99 c1 ff ff       	call   80101b10 <iunlockput>
    return 0;
80105977:	b8 00 00 00 00       	mov    $0x0,%eax
8010597c:	e9 0a 01 00 00       	jmp    80105a8b <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105981:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105985:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105988:	8b 00                	mov    (%eax),%eax
8010598a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010598e:	89 04 24             	mov    %eax,(%esp)
80105991:	e8 5b bc ff ff       	call   801015f1 <ialloc>
80105996:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105999:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010599d:	75 0c                	jne    801059ab <create+0xde>
    panic("create: ialloc");
8010599f:	c7 04 24 c7 85 10 80 	movl   $0x801085c7,(%esp)
801059a6:	e8 9b ab ff ff       	call   80100546 <panic>

  ilock(ip);
801059ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059ae:	89 04 24             	mov    %eax,(%esp)
801059b1:	e8 d6 be ff ff       	call   8010188c <ilock>
  ip->major = major;
801059b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059b9:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801059bd:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
801059c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059c4:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801059c8:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
801059cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059cf:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
801059d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059d8:	89 04 24             	mov    %eax,(%esp)
801059db:	e8 f0 bc ff ff       	call   801016d0 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
801059e0:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801059e5:	75 6a                	jne    80105a51 <create+0x184>
    dp->nlink++;  // for ".."
801059e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ea:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801059ee:	8d 50 01             	lea    0x1(%eax),%edx
801059f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059f4:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801059f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059fb:	89 04 24             	mov    %eax,(%esp)
801059fe:	e8 cd bc ff ff       	call   801016d0 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105a03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a06:	8b 40 04             	mov    0x4(%eax),%eax
80105a09:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a0d:	c7 44 24 04 a1 85 10 	movl   $0x801085a1,0x4(%esp)
80105a14:	80 
80105a15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a18:	89 04 24             	mov    %eax,(%esp)
80105a1b:	e8 6a c7 ff ff       	call   8010218a <dirlink>
80105a20:	85 c0                	test   %eax,%eax
80105a22:	78 21                	js     80105a45 <create+0x178>
80105a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a27:	8b 40 04             	mov    0x4(%eax),%eax
80105a2a:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a2e:	c7 44 24 04 a3 85 10 	movl   $0x801085a3,0x4(%esp)
80105a35:	80 
80105a36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a39:	89 04 24             	mov    %eax,(%esp)
80105a3c:	e8 49 c7 ff ff       	call   8010218a <dirlink>
80105a41:	85 c0                	test   %eax,%eax
80105a43:	79 0c                	jns    80105a51 <create+0x184>
      panic("create dots");
80105a45:	c7 04 24 d6 85 10 80 	movl   $0x801085d6,(%esp)
80105a4c:	e8 f5 aa ff ff       	call   80100546 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105a51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a54:	8b 40 04             	mov    0x4(%eax),%eax
80105a57:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a5b:	8d 45 de             	lea    -0x22(%ebp),%eax
80105a5e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a65:	89 04 24             	mov    %eax,(%esp)
80105a68:	e8 1d c7 ff ff       	call   8010218a <dirlink>
80105a6d:	85 c0                	test   %eax,%eax
80105a6f:	79 0c                	jns    80105a7d <create+0x1b0>
    panic("create: dirlink");
80105a71:	c7 04 24 e2 85 10 80 	movl   $0x801085e2,(%esp)
80105a78:	e8 c9 aa ff ff       	call   80100546 <panic>

  iunlockput(dp);
80105a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a80:	89 04 24             	mov    %eax,(%esp)
80105a83:	e8 88 c0 ff ff       	call   80101b10 <iunlockput>

  return ip;
80105a88:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105a8b:	c9                   	leave  
80105a8c:	c3                   	ret    

80105a8d <sys_open>:

int
sys_open(void)
{
80105a8d:	55                   	push   %ebp
80105a8e:	89 e5                	mov    %esp,%ebp
80105a90:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105a93:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105a96:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a9a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105aa1:	e8 e4 f6 ff ff       	call   8010518a <argstr>
80105aa6:	85 c0                	test   %eax,%eax
80105aa8:	78 17                	js     80105ac1 <sys_open+0x34>
80105aaa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105aad:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ab1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105ab8:	e8 3d f6 ff ff       	call   801050fa <argint>
80105abd:	85 c0                	test   %eax,%eax
80105abf:	79 0a                	jns    80105acb <sys_open+0x3e>
    return -1;
80105ac1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ac6:	e9 48 01 00 00       	jmp    80105c13 <sys_open+0x186>
  if(omode & O_CREATE){
80105acb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ace:	25 00 02 00 00       	and    $0x200,%eax
80105ad3:	85 c0                	test   %eax,%eax
80105ad5:	74 40                	je     80105b17 <sys_open+0x8a>
    begin_trans();
80105ad7:	e8 8c d7 ff ff       	call   80103268 <begin_trans>
    ip = create(path, T_FILE, 0, 0);
80105adc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105adf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105ae6:	00 
80105ae7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105aee:	00 
80105aef:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80105af6:	00 
80105af7:	89 04 24             	mov    %eax,(%esp)
80105afa:	e8 ce fd ff ff       	call   801058cd <create>
80105aff:	89 45 f4             	mov    %eax,-0xc(%ebp)
    commit_trans();
80105b02:	e8 aa d7 ff ff       	call   801032b1 <commit_trans>
    if(ip == 0)
80105b07:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b0b:	75 5c                	jne    80105b69 <sys_open+0xdc>
      return -1;
80105b0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b12:	e9 fc 00 00 00       	jmp    80105c13 <sys_open+0x186>
  } else {
    if((ip = namei(path)) == 0)
80105b17:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b1a:	89 04 24             	mov    %eax,(%esp)
80105b1d:	e8 2b c9 ff ff       	call   8010244d <namei>
80105b22:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b25:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b29:	75 0a                	jne    80105b35 <sys_open+0xa8>
      return -1;
80105b2b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b30:	e9 de 00 00 00       	jmp    80105c13 <sys_open+0x186>
    ilock(ip);
80105b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b38:	89 04 24             	mov    %eax,(%esp)
80105b3b:	e8 4c bd ff ff       	call   8010188c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80105b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b43:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105b47:	66 83 f8 01          	cmp    $0x1,%ax
80105b4b:	75 1c                	jne    80105b69 <sys_open+0xdc>
80105b4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b50:	85 c0                	test   %eax,%eax
80105b52:	74 15                	je     80105b69 <sys_open+0xdc>
      iunlockput(ip);
80105b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b57:	89 04 24             	mov    %eax,(%esp)
80105b5a:	e8 b1 bf ff ff       	call   80101b10 <iunlockput>
      return -1;
80105b5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b64:	e9 aa 00 00 00       	jmp    80105c13 <sys_open+0x186>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105b69:	e8 ce b3 ff ff       	call   80100f3c <filealloc>
80105b6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b71:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b75:	74 14                	je     80105b8b <sys_open+0xfe>
80105b77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b7a:	89 04 24             	mov    %eax,(%esp)
80105b7d:	e8 43 f7 ff ff       	call   801052c5 <fdalloc>
80105b82:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105b85:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105b89:	79 23                	jns    80105bae <sys_open+0x121>
    if(f)
80105b8b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b8f:	74 0b                	je     80105b9c <sys_open+0x10f>
      fileclose(f);
80105b91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b94:	89 04 24             	mov    %eax,(%esp)
80105b97:	e8 48 b4 ff ff       	call   80100fe4 <fileclose>
    iunlockput(ip);
80105b9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b9f:	89 04 24             	mov    %eax,(%esp)
80105ba2:	e8 69 bf ff ff       	call   80101b10 <iunlockput>
    return -1;
80105ba7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bac:	eb 65                	jmp    80105c13 <sys_open+0x186>
  }
  iunlock(ip);
80105bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bb1:	89 04 24             	mov    %eax,(%esp)
80105bb4:	e8 21 be ff ff       	call   801019da <iunlock>

  f->type = FD_INODE;
80105bb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bbc:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105bc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bc5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105bc8:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105bcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bce:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105bd5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105bd8:	83 e0 01             	and    $0x1,%eax
80105bdb:	85 c0                	test   %eax,%eax
80105bdd:	0f 94 c0             	sete   %al
80105be0:	89 c2                	mov    %eax,%edx
80105be2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105be5:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105be8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105beb:	83 e0 01             	and    $0x1,%eax
80105bee:	85 c0                	test   %eax,%eax
80105bf0:	75 0a                	jne    80105bfc <sys_open+0x16f>
80105bf2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105bf5:	83 e0 02             	and    $0x2,%eax
80105bf8:	85 c0                	test   %eax,%eax
80105bfa:	74 07                	je     80105c03 <sys_open+0x176>
80105bfc:	b8 01 00 00 00       	mov    $0x1,%eax
80105c01:	eb 05                	jmp    80105c08 <sys_open+0x17b>
80105c03:	b8 00 00 00 00       	mov    $0x0,%eax
80105c08:	89 c2                	mov    %eax,%edx
80105c0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c0d:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105c10:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105c13:	c9                   	leave  
80105c14:	c3                   	ret    

80105c15 <sys_mkdir>:

int
sys_mkdir(void)
{
80105c15:	55                   	push   %ebp
80105c16:	89 e5                	mov    %esp,%ebp
80105c18:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_trans();
80105c1b:	e8 48 d6 ff ff       	call   80103268 <begin_trans>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105c20:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c23:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c27:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c2e:	e8 57 f5 ff ff       	call   8010518a <argstr>
80105c33:	85 c0                	test   %eax,%eax
80105c35:	78 2c                	js     80105c63 <sys_mkdir+0x4e>
80105c37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c3a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105c41:	00 
80105c42:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105c49:	00 
80105c4a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105c51:	00 
80105c52:	89 04 24             	mov    %eax,(%esp)
80105c55:	e8 73 fc ff ff       	call   801058cd <create>
80105c5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c5d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c61:	75 0c                	jne    80105c6f <sys_mkdir+0x5a>
    commit_trans();
80105c63:	e8 49 d6 ff ff       	call   801032b1 <commit_trans>
    return -1;
80105c68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c6d:	eb 15                	jmp    80105c84 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80105c6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c72:	89 04 24             	mov    %eax,(%esp)
80105c75:	e8 96 be ff ff       	call   80101b10 <iunlockput>
  commit_trans();
80105c7a:	e8 32 d6 ff ff       	call   801032b1 <commit_trans>
  return 0;
80105c7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c84:	c9                   	leave  
80105c85:	c3                   	ret    

80105c86 <sys_mknod>:

int
sys_mknod(void)
{
80105c86:	55                   	push   %ebp
80105c87:	89 e5                	mov    %esp,%ebp
80105c89:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
80105c8c:	e8 d7 d5 ff ff       	call   80103268 <begin_trans>
  if((len=argstr(0, &path)) < 0 ||
80105c91:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c94:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c98:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c9f:	e8 e6 f4 ff ff       	call   8010518a <argstr>
80105ca4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ca7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cab:	78 5e                	js     80105d0b <sys_mknod+0x85>
     argint(1, &major) < 0 ||
80105cad:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105cb0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cb4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105cbb:	e8 3a f4 ff ff       	call   801050fa <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
80105cc0:	85 c0                	test   %eax,%eax
80105cc2:	78 47                	js     80105d0b <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80105cc4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105cc7:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ccb:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105cd2:	e8 23 f4 ff ff       	call   801050fa <argint>
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80105cd7:	85 c0                	test   %eax,%eax
80105cd9:	78 30                	js     80105d0b <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80105cdb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105cde:	0f bf c8             	movswl %ax,%ecx
80105ce1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ce4:	0f bf d0             	movswl %ax,%edx
80105ce7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80105cea:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80105cee:	89 54 24 08          	mov    %edx,0x8(%esp)
80105cf2:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80105cf9:	00 
80105cfa:	89 04 24             	mov    %eax,(%esp)
80105cfd:	e8 cb fb ff ff       	call   801058cd <create>
80105d02:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d05:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d09:	75 0c                	jne    80105d17 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    commit_trans();
80105d0b:	e8 a1 d5 ff ff       	call   801032b1 <commit_trans>
    return -1;
80105d10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d15:	eb 15                	jmp    80105d2c <sys_mknod+0xa6>
  }
  iunlockput(ip);
80105d17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d1a:	89 04 24             	mov    %eax,(%esp)
80105d1d:	e8 ee bd ff ff       	call   80101b10 <iunlockput>
  commit_trans();
80105d22:	e8 8a d5 ff ff       	call   801032b1 <commit_trans>
  return 0;
80105d27:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d2c:	c9                   	leave  
80105d2d:	c3                   	ret    

80105d2e <sys_chdir>:

int
sys_chdir(void)
{
80105d2e:	55                   	push   %ebp
80105d2f:	89 e5                	mov    %esp,%ebp
80105d31:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
80105d34:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d37:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d3b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d42:	e8 43 f4 ff ff       	call   8010518a <argstr>
80105d47:	85 c0                	test   %eax,%eax
80105d49:	78 14                	js     80105d5f <sys_chdir+0x31>
80105d4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d4e:	89 04 24             	mov    %eax,(%esp)
80105d51:	e8 f7 c6 ff ff       	call   8010244d <namei>
80105d56:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d59:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d5d:	75 07                	jne    80105d66 <sys_chdir+0x38>
    return -1;
80105d5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d64:	eb 57                	jmp    80105dbd <sys_chdir+0x8f>
  ilock(ip);
80105d66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d69:	89 04 24             	mov    %eax,(%esp)
80105d6c:	e8 1b bb ff ff       	call   8010188c <ilock>
  if(ip->type != T_DIR){
80105d71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d74:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d78:	66 83 f8 01          	cmp    $0x1,%ax
80105d7c:	74 12                	je     80105d90 <sys_chdir+0x62>
    iunlockput(ip);
80105d7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d81:	89 04 24             	mov    %eax,(%esp)
80105d84:	e8 87 bd ff ff       	call   80101b10 <iunlockput>
    return -1;
80105d89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d8e:	eb 2d                	jmp    80105dbd <sys_chdir+0x8f>
  }
  iunlock(ip);
80105d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d93:	89 04 24             	mov    %eax,(%esp)
80105d96:	e8 3f bc ff ff       	call   801019da <iunlock>
  iput(proc->cwd);
80105d9b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105da1:	8b 40 68             	mov    0x68(%eax),%eax
80105da4:	89 04 24             	mov    %eax,(%esp)
80105da7:	e8 93 bc ff ff       	call   80101a3f <iput>
  proc->cwd = ip;
80105dac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105db2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105db5:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105db8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105dbd:	c9                   	leave  
80105dbe:	c3                   	ret    

80105dbf <sys_exec>:

int
sys_exec(void)
{
80105dbf:	55                   	push   %ebp
80105dc0:	89 e5                	mov    %esp,%ebp
80105dc2:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105dc8:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105dcb:	89 44 24 04          	mov    %eax,0x4(%esp)
80105dcf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105dd6:	e8 af f3 ff ff       	call   8010518a <argstr>
80105ddb:	85 c0                	test   %eax,%eax
80105ddd:	78 1a                	js     80105df9 <sys_exec+0x3a>
80105ddf:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105de5:	89 44 24 04          	mov    %eax,0x4(%esp)
80105de9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105df0:	e8 05 f3 ff ff       	call   801050fa <argint>
80105df5:	85 c0                	test   %eax,%eax
80105df7:	79 0a                	jns    80105e03 <sys_exec+0x44>
    return -1;
80105df9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dfe:	e9 c8 00 00 00       	jmp    80105ecb <sys_exec+0x10c>
  }
  memset(argv, 0, sizeof(argv));
80105e03:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80105e0a:	00 
80105e0b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105e12:	00 
80105e13:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105e19:	89 04 24             	mov    %eax,(%esp)
80105e1c:	e8 7d ef ff ff       	call   80104d9e <memset>
  for(i=0;; i++){
80105e21:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105e28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e2b:	83 f8 1f             	cmp    $0x1f,%eax
80105e2e:	76 0a                	jbe    80105e3a <sys_exec+0x7b>
      return -1;
80105e30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e35:	e9 91 00 00 00       	jmp    80105ecb <sys_exec+0x10c>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e3d:	c1 e0 02             	shl    $0x2,%eax
80105e40:	89 c2                	mov    %eax,%edx
80105e42:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105e48:	01 c2                	add    %eax,%edx
80105e4a:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105e50:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e54:	89 14 24             	mov    %edx,(%esp)
80105e57:	e8 00 f2 ff ff       	call   8010505c <fetchint>
80105e5c:	85 c0                	test   %eax,%eax
80105e5e:	79 07                	jns    80105e67 <sys_exec+0xa8>
      return -1;
80105e60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e65:	eb 64                	jmp    80105ecb <sys_exec+0x10c>
    if(uarg == 0){
80105e67:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105e6d:	85 c0                	test   %eax,%eax
80105e6f:	75 26                	jne    80105e97 <sys_exec+0xd8>
      argv[i] = 0;
80105e71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e74:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105e7b:	00 00 00 00 
      break;
80105e7f:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105e80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e83:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105e89:	89 54 24 04          	mov    %edx,0x4(%esp)
80105e8d:	89 04 24             	mov    %eax,(%esp)
80105e90:	e8 73 ac ff ff       	call   80100b08 <exec>
80105e95:	eb 34                	jmp    80105ecb <sys_exec+0x10c>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80105e97:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105e9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ea0:	c1 e2 02             	shl    $0x2,%edx
80105ea3:	01 c2                	add    %eax,%edx
80105ea5:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105eab:	89 54 24 04          	mov    %edx,0x4(%esp)
80105eaf:	89 04 24             	mov    %eax,(%esp)
80105eb2:	e8 df f1 ff ff       	call   80105096 <fetchstr>
80105eb7:	85 c0                	test   %eax,%eax
80105eb9:	79 07                	jns    80105ec2 <sys_exec+0x103>
      return -1;
80105ebb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ec0:	eb 09                	jmp    80105ecb <sys_exec+0x10c>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80105ec2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80105ec6:	e9 5d ff ff ff       	jmp    80105e28 <sys_exec+0x69>
  return exec(path, argv);
}
80105ecb:	c9                   	leave  
80105ecc:	c3                   	ret    

80105ecd <sys_pipe>:

int
sys_pipe(void)
{
80105ecd:	55                   	push   %ebp
80105ece:	89 e5                	mov    %esp,%ebp
80105ed0:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105ed3:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80105eda:	00 
80105edb:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ede:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ee2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ee9:	e8 3a f2 ff ff       	call   80105128 <argptr>
80105eee:	85 c0                	test   %eax,%eax
80105ef0:	79 0a                	jns    80105efc <sys_pipe+0x2f>
    return -1;
80105ef2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ef7:	e9 9b 00 00 00       	jmp    80105f97 <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
80105efc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105eff:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f03:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f06:	89 04 24             	mov    %eax,(%esp)
80105f09:	e8 6e dd ff ff       	call   80103c7c <pipealloc>
80105f0e:	85 c0                	test   %eax,%eax
80105f10:	79 07                	jns    80105f19 <sys_pipe+0x4c>
    return -1;
80105f12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f17:	eb 7e                	jmp    80105f97 <sys_pipe+0xca>
  fd0 = -1;
80105f19:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105f20:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f23:	89 04 24             	mov    %eax,(%esp)
80105f26:	e8 9a f3 ff ff       	call   801052c5 <fdalloc>
80105f2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f2e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f32:	78 14                	js     80105f48 <sys_pipe+0x7b>
80105f34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f37:	89 04 24             	mov    %eax,(%esp)
80105f3a:	e8 86 f3 ff ff       	call   801052c5 <fdalloc>
80105f3f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f42:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f46:	79 37                	jns    80105f7f <sys_pipe+0xb2>
    if(fd0 >= 0)
80105f48:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f4c:	78 14                	js     80105f62 <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
80105f4e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105f54:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f57:	83 c2 08             	add    $0x8,%edx
80105f5a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105f61:	00 
    fileclose(rf);
80105f62:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f65:	89 04 24             	mov    %eax,(%esp)
80105f68:	e8 77 b0 ff ff       	call   80100fe4 <fileclose>
    fileclose(wf);
80105f6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f70:	89 04 24             	mov    %eax,(%esp)
80105f73:	e8 6c b0 ff ff       	call   80100fe4 <fileclose>
    return -1;
80105f78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f7d:	eb 18                	jmp    80105f97 <sys_pipe+0xca>
  }
  fd[0] = fd0;
80105f7f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f82:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f85:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105f87:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f8a:	8d 50 04             	lea    0x4(%eax),%edx
80105f8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f90:	89 02                	mov    %eax,(%edx)
  return 0;
80105f92:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f97:	c9                   	leave  
80105f98:	c3                   	ret    
80105f99:	66 90                	xchg   %ax,%ax
80105f9b:	90                   	nop

80105f9c <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80105f9c:	55                   	push   %ebp
80105f9d:	89 e5                	mov    %esp,%ebp
80105f9f:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105fa2:	e8 8c e3 ff ff       	call   80104333 <fork>
}
80105fa7:	c9                   	leave  
80105fa8:	c3                   	ret    

80105fa9 <sys_exit>:

int
sys_exit(void)
{
80105fa9:	55                   	push   %ebp
80105faa:	89 e5                	mov    %esp,%ebp
80105fac:	83 ec 08             	sub    $0x8,%esp
  exit();
80105faf:	e8 e2 e4 ff ff       	call   80104496 <exit>
  return 0;  // not reached
80105fb4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105fb9:	c9                   	leave  
80105fba:	c3                   	ret    

80105fbb <sys_wait>:

int
sys_wait(void)
{
80105fbb:	55                   	push   %ebp
80105fbc:	89 e5                	mov    %esp,%ebp
80105fbe:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105fc1:	e8 e8 e5 ff ff       	call   801045ae <wait>
}
80105fc6:	c9                   	leave  
80105fc7:	c3                   	ret    

80105fc8 <sys_kill>:

int
sys_kill(void)
{
80105fc8:	55                   	push   %ebp
80105fc9:	89 e5                	mov    %esp,%ebp
80105fcb:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105fce:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105fd1:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fd5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105fdc:	e8 19 f1 ff ff       	call   801050fa <argint>
80105fe1:	85 c0                	test   %eax,%eax
80105fe3:	79 07                	jns    80105fec <sys_kill+0x24>
    return -1;
80105fe5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fea:	eb 0b                	jmp    80105ff7 <sys_kill+0x2f>
  return kill(pid);
80105fec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fef:	89 04 24             	mov    %eax,(%esp)
80105ff2:	e8 73 e9 ff ff       	call   8010496a <kill>
}
80105ff7:	c9                   	leave  
80105ff8:	c3                   	ret    

80105ff9 <sys_getpid>:

int
sys_getpid(void)
{
80105ff9:	55                   	push   %ebp
80105ffa:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80105ffc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106002:	8b 40 10             	mov    0x10(%eax),%eax
}
80106005:	5d                   	pop    %ebp
80106006:	c3                   	ret    

80106007 <sys_sbrk>:

int
sys_sbrk(void)
{
80106007:	55                   	push   %ebp
80106008:	89 e5                	mov    %esp,%ebp
8010600a:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010600d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106010:	89 44 24 04          	mov    %eax,0x4(%esp)
80106014:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010601b:	e8 da f0 ff ff       	call   801050fa <argint>
80106020:	85 c0                	test   %eax,%eax
80106022:	79 07                	jns    8010602b <sys_sbrk+0x24>
    return -1;
80106024:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106029:	eb 24                	jmp    8010604f <sys_sbrk+0x48>
  addr = proc->sz;
8010602b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106031:	8b 00                	mov    (%eax),%eax
80106033:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106036:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106039:	89 04 24             	mov    %eax,(%esp)
8010603c:	e8 4d e2 ff ff       	call   8010428e <growproc>
80106041:	85 c0                	test   %eax,%eax
80106043:	79 07                	jns    8010604c <sys_sbrk+0x45>
    return -1;
80106045:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010604a:	eb 03                	jmp    8010604f <sys_sbrk+0x48>
  return addr;
8010604c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010604f:	c9                   	leave  
80106050:	c3                   	ret    

80106051 <sys_sleep>:

int
sys_sleep(void)
{
80106051:	55                   	push   %ebp
80106052:	89 e5                	mov    %esp,%ebp
80106054:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80106057:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010605a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010605e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106065:	e8 90 f0 ff ff       	call   801050fa <argint>
8010606a:	85 c0                	test   %eax,%eax
8010606c:	79 07                	jns    80106075 <sys_sleep+0x24>
    return -1;
8010606e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106073:	eb 6c                	jmp    801060e1 <sys_sleep+0x90>
  acquire(&tickslock);
80106075:	c7 04 24 60 1e 11 80 	movl   $0x80111e60,(%esp)
8010607c:	e8 c2 ea ff ff       	call   80104b43 <acquire>
  ticks0 = ticks;
80106081:	a1 a0 26 11 80       	mov    0x801126a0,%eax
80106086:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106089:	eb 34                	jmp    801060bf <sys_sleep+0x6e>
    if(proc->killed){
8010608b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106091:	8b 40 24             	mov    0x24(%eax),%eax
80106094:	85 c0                	test   %eax,%eax
80106096:	74 13                	je     801060ab <sys_sleep+0x5a>
      release(&tickslock);
80106098:	c7 04 24 60 1e 11 80 	movl   $0x80111e60,(%esp)
8010609f:	e8 01 eb ff ff       	call   80104ba5 <release>
      return -1;
801060a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060a9:	eb 36                	jmp    801060e1 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
801060ab:	c7 44 24 04 60 1e 11 	movl   $0x80111e60,0x4(%esp)
801060b2:	80 
801060b3:	c7 04 24 a0 26 11 80 	movl   $0x801126a0,(%esp)
801060ba:	e8 a7 e7 ff ff       	call   80104866 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801060bf:	a1 a0 26 11 80       	mov    0x801126a0,%eax
801060c4:	89 c2                	mov    %eax,%edx
801060c6:	2b 55 f4             	sub    -0xc(%ebp),%edx
801060c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060cc:	39 c2                	cmp    %eax,%edx
801060ce:	72 bb                	jb     8010608b <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801060d0:	c7 04 24 60 1e 11 80 	movl   $0x80111e60,(%esp)
801060d7:	e8 c9 ea ff ff       	call   80104ba5 <release>
  return 0;
801060dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060e1:	c9                   	leave  
801060e2:	c3                   	ret    

801060e3 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801060e3:	55                   	push   %ebp
801060e4:	89 e5                	mov    %esp,%ebp
801060e6:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
801060e9:	c7 04 24 60 1e 11 80 	movl   $0x80111e60,(%esp)
801060f0:	e8 4e ea ff ff       	call   80104b43 <acquire>
  xticks = ticks;
801060f5:	a1 a0 26 11 80       	mov    0x801126a0,%eax
801060fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801060fd:	c7 04 24 60 1e 11 80 	movl   $0x80111e60,(%esp)
80106104:	e8 9c ea ff ff       	call   80104ba5 <release>
  return xticks;
80106109:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010610c:	c9                   	leave  
8010610d:	c3                   	ret    
8010610e:	66 90                	xchg   %ax,%ax

80106110 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106110:	55                   	push   %ebp
80106111:	89 e5                	mov    %esp,%ebp
80106113:	83 ec 08             	sub    $0x8,%esp
80106116:	8b 55 08             	mov    0x8(%ebp),%edx
80106119:	8b 45 0c             	mov    0xc(%ebp),%eax
8010611c:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106120:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106123:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106127:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010612b:	ee                   	out    %al,(%dx)
}
8010612c:	c9                   	leave  
8010612d:	c3                   	ret    

8010612e <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
8010612e:	55                   	push   %ebp
8010612f:	89 e5                	mov    %esp,%ebp
80106131:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106134:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
8010613b:	00 
8010613c:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
80106143:	e8 c8 ff ff ff       	call   80106110 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106148:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
8010614f:	00 
80106150:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106157:	e8 b4 ff ff ff       	call   80106110 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
8010615c:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
80106163:	00 
80106164:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
8010616b:	e8 a0 ff ff ff       	call   80106110 <outb>
  picenable(IRQ_TIMER);
80106170:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106177:	e8 89 d9 ff ff       	call   80103b05 <picenable>
}
8010617c:	c9                   	leave  
8010617d:	c3                   	ret    
8010617e:	66 90                	xchg   %ax,%ax

80106180 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106180:	1e                   	push   %ds
  pushl %es
80106181:	06                   	push   %es
  pushl %fs
80106182:	0f a0                	push   %fs
  pushl %gs
80106184:	0f a8                	push   %gs
  pushal
80106186:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106187:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010618b:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010618d:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
8010618f:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106193:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106195:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106197:	54                   	push   %esp
  call trap
80106198:	e8 de 01 00 00       	call   8010637b <trap>
  addl $4, %esp
8010619d:	83 c4 04             	add    $0x4,%esp

801061a0 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801061a0:	61                   	popa   
  popl %gs
801061a1:	0f a9                	pop    %gs
  popl %fs
801061a3:	0f a1                	pop    %fs
  popl %es
801061a5:	07                   	pop    %es
  popl %ds
801061a6:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801061a7:	83 c4 08             	add    $0x8,%esp
  iret
801061aa:	cf                   	iret   
801061ab:	90                   	nop

801061ac <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801061ac:	55                   	push   %ebp
801061ad:	89 e5                	mov    %esp,%ebp
801061af:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801061b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801061b5:	83 e8 01             	sub    $0x1,%eax
801061b8:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801061bc:	8b 45 08             	mov    0x8(%ebp),%eax
801061bf:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801061c3:	8b 45 08             	mov    0x8(%ebp),%eax
801061c6:	c1 e8 10             	shr    $0x10,%eax
801061c9:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801061cd:	8d 45 fa             	lea    -0x6(%ebp),%eax
801061d0:	0f 01 18             	lidtl  (%eax)
}
801061d3:	c9                   	leave  
801061d4:	c3                   	ret    

801061d5 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801061d5:	55                   	push   %ebp
801061d6:	89 e5                	mov    %esp,%ebp
801061d8:	53                   	push   %ebx
801061d9:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801061dc:	0f 20 d3             	mov    %cr2,%ebx
801061df:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return val;
801061e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801061e5:	83 c4 10             	add    $0x10,%esp
801061e8:	5b                   	pop    %ebx
801061e9:	5d                   	pop    %ebp
801061ea:	c3                   	ret    

801061eb <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801061eb:	55                   	push   %ebp
801061ec:	89 e5                	mov    %esp,%ebp
801061ee:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
801061f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801061f8:	e9 c3 00 00 00       	jmp    801062c0 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801061fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106200:	8b 04 85 98 b0 10 80 	mov    -0x7fef4f68(,%eax,4),%eax
80106207:	89 c2                	mov    %eax,%edx
80106209:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010620c:	66 89 14 c5 a0 1e 11 	mov    %dx,-0x7feee160(,%eax,8)
80106213:	80 
80106214:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106217:	66 c7 04 c5 a2 1e 11 	movw   $0x8,-0x7feee15e(,%eax,8)
8010621e:	80 08 00 
80106221:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106224:	0f b6 14 c5 a4 1e 11 	movzbl -0x7feee15c(,%eax,8),%edx
8010622b:	80 
8010622c:	83 e2 e0             	and    $0xffffffe0,%edx
8010622f:	88 14 c5 a4 1e 11 80 	mov    %dl,-0x7feee15c(,%eax,8)
80106236:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106239:	0f b6 14 c5 a4 1e 11 	movzbl -0x7feee15c(,%eax,8),%edx
80106240:	80 
80106241:	83 e2 1f             	and    $0x1f,%edx
80106244:	88 14 c5 a4 1e 11 80 	mov    %dl,-0x7feee15c(,%eax,8)
8010624b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010624e:	0f b6 14 c5 a5 1e 11 	movzbl -0x7feee15b(,%eax,8),%edx
80106255:	80 
80106256:	83 e2 f0             	and    $0xfffffff0,%edx
80106259:	83 ca 0e             	or     $0xe,%edx
8010625c:	88 14 c5 a5 1e 11 80 	mov    %dl,-0x7feee15b(,%eax,8)
80106263:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106266:	0f b6 14 c5 a5 1e 11 	movzbl -0x7feee15b(,%eax,8),%edx
8010626d:	80 
8010626e:	83 e2 ef             	and    $0xffffffef,%edx
80106271:	88 14 c5 a5 1e 11 80 	mov    %dl,-0x7feee15b(,%eax,8)
80106278:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010627b:	0f b6 14 c5 a5 1e 11 	movzbl -0x7feee15b(,%eax,8),%edx
80106282:	80 
80106283:	83 e2 9f             	and    $0xffffff9f,%edx
80106286:	88 14 c5 a5 1e 11 80 	mov    %dl,-0x7feee15b(,%eax,8)
8010628d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106290:	0f b6 14 c5 a5 1e 11 	movzbl -0x7feee15b(,%eax,8),%edx
80106297:	80 
80106298:	83 ca 80             	or     $0xffffff80,%edx
8010629b:	88 14 c5 a5 1e 11 80 	mov    %dl,-0x7feee15b(,%eax,8)
801062a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062a5:	8b 04 85 98 b0 10 80 	mov    -0x7fef4f68(,%eax,4),%eax
801062ac:	c1 e8 10             	shr    $0x10,%eax
801062af:	89 c2                	mov    %eax,%edx
801062b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062b4:	66 89 14 c5 a6 1e 11 	mov    %dx,-0x7feee15a(,%eax,8)
801062bb:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801062bc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801062c0:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801062c7:	0f 8e 30 ff ff ff    	jle    801061fd <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801062cd:	a1 98 b1 10 80       	mov    0x8010b198,%eax
801062d2:	66 a3 a0 20 11 80    	mov    %ax,0x801120a0
801062d8:	66 c7 05 a2 20 11 80 	movw   $0x8,0x801120a2
801062df:	08 00 
801062e1:	0f b6 05 a4 20 11 80 	movzbl 0x801120a4,%eax
801062e8:	83 e0 e0             	and    $0xffffffe0,%eax
801062eb:	a2 a4 20 11 80       	mov    %al,0x801120a4
801062f0:	0f b6 05 a4 20 11 80 	movzbl 0x801120a4,%eax
801062f7:	83 e0 1f             	and    $0x1f,%eax
801062fa:	a2 a4 20 11 80       	mov    %al,0x801120a4
801062ff:	0f b6 05 a5 20 11 80 	movzbl 0x801120a5,%eax
80106306:	83 c8 0f             	or     $0xf,%eax
80106309:	a2 a5 20 11 80       	mov    %al,0x801120a5
8010630e:	0f b6 05 a5 20 11 80 	movzbl 0x801120a5,%eax
80106315:	83 e0 ef             	and    $0xffffffef,%eax
80106318:	a2 a5 20 11 80       	mov    %al,0x801120a5
8010631d:	0f b6 05 a5 20 11 80 	movzbl 0x801120a5,%eax
80106324:	83 c8 60             	or     $0x60,%eax
80106327:	a2 a5 20 11 80       	mov    %al,0x801120a5
8010632c:	0f b6 05 a5 20 11 80 	movzbl 0x801120a5,%eax
80106333:	83 c8 80             	or     $0xffffff80,%eax
80106336:	a2 a5 20 11 80       	mov    %al,0x801120a5
8010633b:	a1 98 b1 10 80       	mov    0x8010b198,%eax
80106340:	c1 e8 10             	shr    $0x10,%eax
80106343:	66 a3 a6 20 11 80    	mov    %ax,0x801120a6
  
  initlock(&tickslock, "time");
80106349:	c7 44 24 04 f4 85 10 	movl   $0x801085f4,0x4(%esp)
80106350:	80 
80106351:	c7 04 24 60 1e 11 80 	movl   $0x80111e60,(%esp)
80106358:	e8 c5 e7 ff ff       	call   80104b22 <initlock>
}
8010635d:	c9                   	leave  
8010635e:	c3                   	ret    

8010635f <idtinit>:

void
idtinit(void)
{
8010635f:	55                   	push   %ebp
80106360:	89 e5                	mov    %esp,%ebp
80106362:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106365:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
8010636c:	00 
8010636d:	c7 04 24 a0 1e 11 80 	movl   $0x80111ea0,(%esp)
80106374:	e8 33 fe ff ff       	call   801061ac <lidt>
}
80106379:	c9                   	leave  
8010637a:	c3                   	ret    

8010637b <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010637b:	55                   	push   %ebp
8010637c:	89 e5                	mov    %esp,%ebp
8010637e:	57                   	push   %edi
8010637f:	56                   	push   %esi
80106380:	53                   	push   %ebx
80106381:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106384:	8b 45 08             	mov    0x8(%ebp),%eax
80106387:	8b 40 30             	mov    0x30(%eax),%eax
8010638a:	83 f8 40             	cmp    $0x40,%eax
8010638d:	75 3e                	jne    801063cd <trap+0x52>
    if(proc->killed)
8010638f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106395:	8b 40 24             	mov    0x24(%eax),%eax
80106398:	85 c0                	test   %eax,%eax
8010639a:	74 05                	je     801063a1 <trap+0x26>
      exit();
8010639c:	e8 f5 e0 ff ff       	call   80104496 <exit>
    proc->tf = tf;
801063a1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063a7:	8b 55 08             	mov    0x8(%ebp),%edx
801063aa:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801063ad:	e8 0f ee ff ff       	call   801051c1 <syscall>
    if(proc->killed)
801063b2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063b8:	8b 40 24             	mov    0x24(%eax),%eax
801063bb:	85 c0                	test   %eax,%eax
801063bd:	0f 84 40 02 00 00    	je     80106603 <trap+0x288>
      exit();
801063c3:	e8 ce e0 ff ff       	call   80104496 <exit>
    return;
801063c8:	e9 36 02 00 00       	jmp    80106603 <trap+0x288>
  }

  switch(tf->trapno){
801063cd:	8b 45 08             	mov    0x8(%ebp),%eax
801063d0:	8b 40 30             	mov    0x30(%eax),%eax
801063d3:	83 e8 0e             	sub    $0xe,%eax
801063d6:	83 f8 31             	cmp    $0x31,%eax
801063d9:	0f 87 c8 00 00 00    	ja     801064a7 <trap+0x12c>
801063df:	8b 04 85 b8 86 10 80 	mov    -0x7fef7948(,%eax,4),%eax
801063e6:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
801063e8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801063ee:	0f b6 00             	movzbl (%eax),%eax
801063f1:	84 c0                	test   %al,%al
801063f3:	75 31                	jne    80106426 <trap+0xab>
      acquire(&tickslock);
801063f5:	c7 04 24 60 1e 11 80 	movl   $0x80111e60,(%esp)
801063fc:	e8 42 e7 ff ff       	call   80104b43 <acquire>
      ticks++;
80106401:	a1 a0 26 11 80       	mov    0x801126a0,%eax
80106406:	83 c0 01             	add    $0x1,%eax
80106409:	a3 a0 26 11 80       	mov    %eax,0x801126a0
      wakeup(&ticks);
8010640e:	c7 04 24 a0 26 11 80 	movl   $0x801126a0,(%esp)
80106415:	e8 25 e5 ff ff       	call   8010493f <wakeup>
      release(&tickslock);
8010641a:	c7 04 24 60 1e 11 80 	movl   $0x80111e60,(%esp)
80106421:	e8 7f e7 ff ff       	call   80104ba5 <release>
    }
    lapiceoi();
80106426:	e8 06 cb ff ff       	call   80102f31 <lapiceoi>
    break;
8010642b:	e9 4d 01 00 00       	jmp    8010657d <trap+0x202>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106430:	e8 00 c3 ff ff       	call   80102735 <ideintr>
    lapiceoi();
80106435:	e8 f7 ca ff ff       	call   80102f31 <lapiceoi>
    break;
8010643a:	e9 3e 01 00 00       	jmp    8010657d <trap+0x202>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010643f:	e8 c9 c8 ff ff       	call   80102d0d <kbdintr>
    lapiceoi();
80106444:	e8 e8 ca ff ff       	call   80102f31 <lapiceoi>
    break;
80106449:	e9 2f 01 00 00       	jmp    8010657d <trap+0x202>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010644e:	e8 b5 03 00 00       	call   80106808 <uartintr>
    lapiceoi();
80106453:	e8 d9 ca ff ff       	call   80102f31 <lapiceoi>
    break;
80106458:	e9 20 01 00 00       	jmp    8010657d <trap+0x202>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
8010645d:	8b 45 08             	mov    0x8(%ebp),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106460:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106463:	8b 45 08             	mov    0x8(%ebp),%eax
80106466:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010646a:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
8010646d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106473:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106476:	0f b6 c0             	movzbl %al,%eax
80106479:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010647d:	89 54 24 08          	mov    %edx,0x8(%esp)
80106481:	89 44 24 04          	mov    %eax,0x4(%esp)
80106485:	c7 04 24 fc 85 10 80 	movl   $0x801085fc,(%esp)
8010648c:	e8 19 9f ff ff       	call   801003aa <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106491:	e8 9b ca ff ff       	call   80102f31 <lapiceoi>
    break;
80106496:	e9 e2 00 00 00       	jmp    8010657d <trap+0x202>
  case T_PGFLT:
      //si la pagina es de usuario y no esta habilitada para escritura
      //Restauramos bits.Sino goto al default
      cprintf("TENEMOS NUESTRO TRAP !!!\n");
8010649b:	c7 04 24 20 86 10 80 	movl   $0x80108620,(%esp)
801064a2:	e8 03 9f ff ff       	call   801003aa <cprintf>
          
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
801064a7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064ad:	85 c0                	test   %eax,%eax
801064af:	74 11                	je     801064c2 <trap+0x147>
801064b1:	8b 45 08             	mov    0x8(%ebp),%eax
801064b4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801064b8:	0f b7 c0             	movzwl %ax,%eax
801064bb:	83 e0 03             	and    $0x3,%eax
801064be:	85 c0                	test   %eax,%eax
801064c0:	75 46                	jne    80106508 <trap+0x18d>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801064c2:	e8 0e fd ff ff       	call   801061d5 <rcr2>
              tf->trapno, cpu->id, tf->eip, rcr2());
801064c7:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801064ca:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
801064cd:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801064d4:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801064d7:	0f b6 ca             	movzbl %dl,%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
801064da:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801064dd:	8b 52 30             	mov    0x30(%edx),%edx
801064e0:	89 44 24 10          	mov    %eax,0x10(%esp)
801064e4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
801064e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801064ec:	89 54 24 04          	mov    %edx,0x4(%esp)
801064f0:	c7 04 24 3c 86 10 80 	movl   $0x8010863c,(%esp)
801064f7:	e8 ae 9e ff ff       	call   801003aa <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
801064fc:	c7 04 24 6e 86 10 80 	movl   $0x8010866e,(%esp)
80106503:	e8 3e a0 ff ff       	call   80100546 <panic>
    }
    // In user space, assume process misbehaved.
    
    //deberiamos atrapar el trap y cargar las demas paginas
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106508:	e8 c8 fc ff ff       	call   801061d5 <rcr2>
8010650d:	89 c2                	mov    %eax,%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
8010650f:	8b 45 08             	mov    0x8(%ebp),%eax
      panic("trap");
    }
    // In user space, assume process misbehaved.
    
    //deberiamos atrapar el trap y cargar las demas paginas
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106512:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106515:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010651b:	0f b6 00             	movzbl (%eax),%eax
      panic("trap");
    }
    // In user space, assume process misbehaved.
    
    //deberiamos atrapar el trap y cargar las demas paginas
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010651e:	0f b6 f0             	movzbl %al,%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106521:	8b 45 08             	mov    0x8(%ebp),%eax
      panic("trap");
    }
    // In user space, assume process misbehaved.
    
    //deberiamos atrapar el trap y cargar las demas paginas
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106524:	8b 58 34             	mov    0x34(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106527:	8b 45 08             	mov    0x8(%ebp),%eax
      panic("trap");
    }
    // In user space, assume process misbehaved.
    
    //deberiamos atrapar el trap y cargar las demas paginas
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010652a:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
8010652d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106533:	83 c0 6c             	add    $0x6c,%eax
80106536:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106539:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      panic("trap");
    }
    // In user space, assume process misbehaved.
    
    //deberiamos atrapar el trap y cargar las demas paginas
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010653f:	8b 40 10             	mov    0x10(%eax),%eax
80106542:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106546:	89 7c 24 18          	mov    %edi,0x18(%esp)
8010654a:	89 74 24 14          	mov    %esi,0x14(%esp)
8010654e:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106552:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106556:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106559:	89 54 24 08          	mov    %edx,0x8(%esp)
8010655d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106561:	c7 04 24 74 86 10 80 	movl   $0x80108674,(%esp)
80106568:	e8 3d 9e ff ff       	call   801003aa <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
8010656d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106573:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010657a:	eb 01                	jmp    8010657d <trap+0x202>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
8010657c:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010657d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106583:	85 c0                	test   %eax,%eax
80106585:	74 24                	je     801065ab <trap+0x230>
80106587:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010658d:	8b 40 24             	mov    0x24(%eax),%eax
80106590:	85 c0                	test   %eax,%eax
80106592:	74 17                	je     801065ab <trap+0x230>
80106594:	8b 45 08             	mov    0x8(%ebp),%eax
80106597:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010659b:	0f b7 c0             	movzwl %ax,%eax
8010659e:	83 e0 03             	and    $0x3,%eax
801065a1:	83 f8 03             	cmp    $0x3,%eax
801065a4:	75 05                	jne    801065ab <trap+0x230>
    exit();
801065a6:	e8 eb de ff ff       	call   80104496 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
801065ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065b1:	85 c0                	test   %eax,%eax
801065b3:	74 1e                	je     801065d3 <trap+0x258>
801065b5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065bb:	8b 40 0c             	mov    0xc(%eax),%eax
801065be:	83 f8 04             	cmp    $0x4,%eax
801065c1:	75 10                	jne    801065d3 <trap+0x258>
801065c3:	8b 45 08             	mov    0x8(%ebp),%eax
801065c6:	8b 40 30             	mov    0x30(%eax),%eax
801065c9:	83 f8 20             	cmp    $0x20,%eax
801065cc:	75 05                	jne    801065d3 <trap+0x258>
    yield();
801065ce:	e8 35 e2 ff ff       	call   80104808 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801065d3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065d9:	85 c0                	test   %eax,%eax
801065db:	74 27                	je     80106604 <trap+0x289>
801065dd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065e3:	8b 40 24             	mov    0x24(%eax),%eax
801065e6:	85 c0                	test   %eax,%eax
801065e8:	74 1a                	je     80106604 <trap+0x289>
801065ea:	8b 45 08             	mov    0x8(%ebp),%eax
801065ed:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801065f1:	0f b7 c0             	movzwl %ax,%eax
801065f4:	83 e0 03             	and    $0x3,%eax
801065f7:	83 f8 03             	cmp    $0x3,%eax
801065fa:	75 08                	jne    80106604 <trap+0x289>
    exit();
801065fc:	e8 95 de ff ff       	call   80104496 <exit>
80106601:	eb 01                	jmp    80106604 <trap+0x289>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80106603:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80106604:	83 c4 3c             	add    $0x3c,%esp
80106607:	5b                   	pop    %ebx
80106608:	5e                   	pop    %esi
80106609:	5f                   	pop    %edi
8010660a:	5d                   	pop    %ebp
8010660b:	c3                   	ret    

8010660c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010660c:	55                   	push   %ebp
8010660d:	89 e5                	mov    %esp,%ebp
8010660f:	53                   	push   %ebx
80106610:	83 ec 14             	sub    $0x14,%esp
80106613:	8b 45 08             	mov    0x8(%ebp),%eax
80106616:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010661a:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
8010661e:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80106622:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80106626:	ec                   	in     (%dx),%al
80106627:	89 c3                	mov    %eax,%ebx
80106629:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
8010662c:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80106630:	83 c4 14             	add    $0x14,%esp
80106633:	5b                   	pop    %ebx
80106634:	5d                   	pop    %ebp
80106635:	c3                   	ret    

80106636 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106636:	55                   	push   %ebp
80106637:	89 e5                	mov    %esp,%ebp
80106639:	83 ec 08             	sub    $0x8,%esp
8010663c:	8b 55 08             	mov    0x8(%ebp),%edx
8010663f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106642:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106646:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106649:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010664d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106651:	ee                   	out    %al,(%dx)
}
80106652:	c9                   	leave  
80106653:	c3                   	ret    

80106654 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106654:	55                   	push   %ebp
80106655:	89 e5                	mov    %esp,%ebp
80106657:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
8010665a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106661:	00 
80106662:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106669:	e8 c8 ff ff ff       	call   80106636 <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010666e:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106675:	00 
80106676:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
8010667d:	e8 b4 ff ff ff       	call   80106636 <outb>
  outb(COM1+0, 115200/9600);
80106682:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106689:	00 
8010668a:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106691:	e8 a0 ff ff ff       	call   80106636 <outb>
  outb(COM1+1, 0);
80106696:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010669d:	00 
8010669e:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
801066a5:	e8 8c ff ff ff       	call   80106636 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801066aa:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801066b1:	00 
801066b2:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
801066b9:	e8 78 ff ff ff       	call   80106636 <outb>
  outb(COM1+4, 0);
801066be:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801066c5:	00 
801066c6:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
801066cd:	e8 64 ff ff ff       	call   80106636 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801066d2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801066d9:	00 
801066da:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
801066e1:	e8 50 ff ff ff       	call   80106636 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801066e6:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801066ed:	e8 1a ff ff ff       	call   8010660c <inb>
801066f2:	3c ff                	cmp    $0xff,%al
801066f4:	74 6c                	je     80106762 <uartinit+0x10e>
    return;
  uart = 1;
801066f6:	c7 05 4c b6 10 80 01 	movl   $0x1,0x8010b64c
801066fd:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106700:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106707:	e8 00 ff ff ff       	call   8010660c <inb>
  inb(COM1+0);
8010670c:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106713:	e8 f4 fe ff ff       	call   8010660c <inb>
  picenable(IRQ_COM1);
80106718:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010671f:	e8 e1 d3 ff ff       	call   80103b05 <picenable>
  ioapicenable(IRQ_COM1, 0);
80106724:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010672b:	00 
8010672c:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106733:	e8 82 c2 ff ff       	call   801029ba <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106738:	c7 45 f4 80 87 10 80 	movl   $0x80108780,-0xc(%ebp)
8010673f:	eb 15                	jmp    80106756 <uartinit+0x102>
    uartputc(*p);
80106741:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106744:	0f b6 00             	movzbl (%eax),%eax
80106747:	0f be c0             	movsbl %al,%eax
8010674a:	89 04 24             	mov    %eax,(%esp)
8010674d:	e8 13 00 00 00       	call   80106765 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106752:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106756:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106759:	0f b6 00             	movzbl (%eax),%eax
8010675c:	84 c0                	test   %al,%al
8010675e:	75 e1                	jne    80106741 <uartinit+0xed>
80106760:	eb 01                	jmp    80106763 <uartinit+0x10f>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80106762:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80106763:	c9                   	leave  
80106764:	c3                   	ret    

80106765 <uartputc>:

void
uartputc(int c)
{
80106765:	55                   	push   %ebp
80106766:	89 e5                	mov    %esp,%ebp
80106768:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
8010676b:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106770:	85 c0                	test   %eax,%eax
80106772:	74 4d                	je     801067c1 <uartputc+0x5c>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106774:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010677b:	eb 10                	jmp    8010678d <uartputc+0x28>
    microdelay(10);
8010677d:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106784:	e8 cd c7 ff ff       	call   80102f56 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106789:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010678d:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106791:	7f 16                	jg     801067a9 <uartputc+0x44>
80106793:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
8010679a:	e8 6d fe ff ff       	call   8010660c <inb>
8010679f:	0f b6 c0             	movzbl %al,%eax
801067a2:	83 e0 20             	and    $0x20,%eax
801067a5:	85 c0                	test   %eax,%eax
801067a7:	74 d4                	je     8010677d <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
801067a9:	8b 45 08             	mov    0x8(%ebp),%eax
801067ac:	0f b6 c0             	movzbl %al,%eax
801067af:	89 44 24 04          	mov    %eax,0x4(%esp)
801067b3:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801067ba:	e8 77 fe ff ff       	call   80106636 <outb>
801067bf:	eb 01                	jmp    801067c2 <uartputc+0x5d>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
801067c1:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
801067c2:	c9                   	leave  
801067c3:	c3                   	ret    

801067c4 <uartgetc>:

static int
uartgetc(void)
{
801067c4:	55                   	push   %ebp
801067c5:	89 e5                	mov    %esp,%ebp
801067c7:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
801067ca:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
801067cf:	85 c0                	test   %eax,%eax
801067d1:	75 07                	jne    801067da <uartgetc+0x16>
    return -1;
801067d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067d8:	eb 2c                	jmp    80106806 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
801067da:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801067e1:	e8 26 fe ff ff       	call   8010660c <inb>
801067e6:	0f b6 c0             	movzbl %al,%eax
801067e9:	83 e0 01             	and    $0x1,%eax
801067ec:	85 c0                	test   %eax,%eax
801067ee:	75 07                	jne    801067f7 <uartgetc+0x33>
    return -1;
801067f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067f5:	eb 0f                	jmp    80106806 <uartgetc+0x42>
  return inb(COM1+0);
801067f7:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801067fe:	e8 09 fe ff ff       	call   8010660c <inb>
80106803:	0f b6 c0             	movzbl %al,%eax
}
80106806:	c9                   	leave  
80106807:	c3                   	ret    

80106808 <uartintr>:

void
uartintr(void)
{
80106808:	55                   	push   %ebp
80106809:	89 e5                	mov    %esp,%ebp
8010680b:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
8010680e:	c7 04 24 c4 67 10 80 	movl   $0x801067c4,(%esp)
80106815:	e8 9c 9f ff ff       	call   801007b6 <consoleintr>
}
8010681a:	c9                   	leave  
8010681b:	c3                   	ret    

8010681c <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010681c:	6a 00                	push   $0x0
  pushl $0
8010681e:	6a 00                	push   $0x0
  jmp alltraps
80106820:	e9 5b f9 ff ff       	jmp    80106180 <alltraps>

80106825 <vector1>:
.globl vector1
vector1:
  pushl $0
80106825:	6a 00                	push   $0x0
  pushl $1
80106827:	6a 01                	push   $0x1
  jmp alltraps
80106829:	e9 52 f9 ff ff       	jmp    80106180 <alltraps>

8010682e <vector2>:
.globl vector2
vector2:
  pushl $0
8010682e:	6a 00                	push   $0x0
  pushl $2
80106830:	6a 02                	push   $0x2
  jmp alltraps
80106832:	e9 49 f9 ff ff       	jmp    80106180 <alltraps>

80106837 <vector3>:
.globl vector3
vector3:
  pushl $0
80106837:	6a 00                	push   $0x0
  pushl $3
80106839:	6a 03                	push   $0x3
  jmp alltraps
8010683b:	e9 40 f9 ff ff       	jmp    80106180 <alltraps>

80106840 <vector4>:
.globl vector4
vector4:
  pushl $0
80106840:	6a 00                	push   $0x0
  pushl $4
80106842:	6a 04                	push   $0x4
  jmp alltraps
80106844:	e9 37 f9 ff ff       	jmp    80106180 <alltraps>

80106849 <vector5>:
.globl vector5
vector5:
  pushl $0
80106849:	6a 00                	push   $0x0
  pushl $5
8010684b:	6a 05                	push   $0x5
  jmp alltraps
8010684d:	e9 2e f9 ff ff       	jmp    80106180 <alltraps>

80106852 <vector6>:
.globl vector6
vector6:
  pushl $0
80106852:	6a 00                	push   $0x0
  pushl $6
80106854:	6a 06                	push   $0x6
  jmp alltraps
80106856:	e9 25 f9 ff ff       	jmp    80106180 <alltraps>

8010685b <vector7>:
.globl vector7
vector7:
  pushl $0
8010685b:	6a 00                	push   $0x0
  pushl $7
8010685d:	6a 07                	push   $0x7
  jmp alltraps
8010685f:	e9 1c f9 ff ff       	jmp    80106180 <alltraps>

80106864 <vector8>:
.globl vector8
vector8:
  pushl $8
80106864:	6a 08                	push   $0x8
  jmp alltraps
80106866:	e9 15 f9 ff ff       	jmp    80106180 <alltraps>

8010686b <vector9>:
.globl vector9
vector9:
  pushl $0
8010686b:	6a 00                	push   $0x0
  pushl $9
8010686d:	6a 09                	push   $0x9
  jmp alltraps
8010686f:	e9 0c f9 ff ff       	jmp    80106180 <alltraps>

80106874 <vector10>:
.globl vector10
vector10:
  pushl $10
80106874:	6a 0a                	push   $0xa
  jmp alltraps
80106876:	e9 05 f9 ff ff       	jmp    80106180 <alltraps>

8010687b <vector11>:
.globl vector11
vector11:
  pushl $11
8010687b:	6a 0b                	push   $0xb
  jmp alltraps
8010687d:	e9 fe f8 ff ff       	jmp    80106180 <alltraps>

80106882 <vector12>:
.globl vector12
vector12:
  pushl $12
80106882:	6a 0c                	push   $0xc
  jmp alltraps
80106884:	e9 f7 f8 ff ff       	jmp    80106180 <alltraps>

80106889 <vector13>:
.globl vector13
vector13:
  pushl $13
80106889:	6a 0d                	push   $0xd
  jmp alltraps
8010688b:	e9 f0 f8 ff ff       	jmp    80106180 <alltraps>

80106890 <vector14>:
.globl vector14
vector14:
  pushl $14
80106890:	6a 0e                	push   $0xe
  jmp alltraps
80106892:	e9 e9 f8 ff ff       	jmp    80106180 <alltraps>

80106897 <vector15>:
.globl vector15
vector15:
  pushl $0
80106897:	6a 00                	push   $0x0
  pushl $15
80106899:	6a 0f                	push   $0xf
  jmp alltraps
8010689b:	e9 e0 f8 ff ff       	jmp    80106180 <alltraps>

801068a0 <vector16>:
.globl vector16
vector16:
  pushl $0
801068a0:	6a 00                	push   $0x0
  pushl $16
801068a2:	6a 10                	push   $0x10
  jmp alltraps
801068a4:	e9 d7 f8 ff ff       	jmp    80106180 <alltraps>

801068a9 <vector17>:
.globl vector17
vector17:
  pushl $17
801068a9:	6a 11                	push   $0x11
  jmp alltraps
801068ab:	e9 d0 f8 ff ff       	jmp    80106180 <alltraps>

801068b0 <vector18>:
.globl vector18
vector18:
  pushl $0
801068b0:	6a 00                	push   $0x0
  pushl $18
801068b2:	6a 12                	push   $0x12
  jmp alltraps
801068b4:	e9 c7 f8 ff ff       	jmp    80106180 <alltraps>

801068b9 <vector19>:
.globl vector19
vector19:
  pushl $0
801068b9:	6a 00                	push   $0x0
  pushl $19
801068bb:	6a 13                	push   $0x13
  jmp alltraps
801068bd:	e9 be f8 ff ff       	jmp    80106180 <alltraps>

801068c2 <vector20>:
.globl vector20
vector20:
  pushl $0
801068c2:	6a 00                	push   $0x0
  pushl $20
801068c4:	6a 14                	push   $0x14
  jmp alltraps
801068c6:	e9 b5 f8 ff ff       	jmp    80106180 <alltraps>

801068cb <vector21>:
.globl vector21
vector21:
  pushl $0
801068cb:	6a 00                	push   $0x0
  pushl $21
801068cd:	6a 15                	push   $0x15
  jmp alltraps
801068cf:	e9 ac f8 ff ff       	jmp    80106180 <alltraps>

801068d4 <vector22>:
.globl vector22
vector22:
  pushl $0
801068d4:	6a 00                	push   $0x0
  pushl $22
801068d6:	6a 16                	push   $0x16
  jmp alltraps
801068d8:	e9 a3 f8 ff ff       	jmp    80106180 <alltraps>

801068dd <vector23>:
.globl vector23
vector23:
  pushl $0
801068dd:	6a 00                	push   $0x0
  pushl $23
801068df:	6a 17                	push   $0x17
  jmp alltraps
801068e1:	e9 9a f8 ff ff       	jmp    80106180 <alltraps>

801068e6 <vector24>:
.globl vector24
vector24:
  pushl $0
801068e6:	6a 00                	push   $0x0
  pushl $24
801068e8:	6a 18                	push   $0x18
  jmp alltraps
801068ea:	e9 91 f8 ff ff       	jmp    80106180 <alltraps>

801068ef <vector25>:
.globl vector25
vector25:
  pushl $0
801068ef:	6a 00                	push   $0x0
  pushl $25
801068f1:	6a 19                	push   $0x19
  jmp alltraps
801068f3:	e9 88 f8 ff ff       	jmp    80106180 <alltraps>

801068f8 <vector26>:
.globl vector26
vector26:
  pushl $0
801068f8:	6a 00                	push   $0x0
  pushl $26
801068fa:	6a 1a                	push   $0x1a
  jmp alltraps
801068fc:	e9 7f f8 ff ff       	jmp    80106180 <alltraps>

80106901 <vector27>:
.globl vector27
vector27:
  pushl $0
80106901:	6a 00                	push   $0x0
  pushl $27
80106903:	6a 1b                	push   $0x1b
  jmp alltraps
80106905:	e9 76 f8 ff ff       	jmp    80106180 <alltraps>

8010690a <vector28>:
.globl vector28
vector28:
  pushl $0
8010690a:	6a 00                	push   $0x0
  pushl $28
8010690c:	6a 1c                	push   $0x1c
  jmp alltraps
8010690e:	e9 6d f8 ff ff       	jmp    80106180 <alltraps>

80106913 <vector29>:
.globl vector29
vector29:
  pushl $0
80106913:	6a 00                	push   $0x0
  pushl $29
80106915:	6a 1d                	push   $0x1d
  jmp alltraps
80106917:	e9 64 f8 ff ff       	jmp    80106180 <alltraps>

8010691c <vector30>:
.globl vector30
vector30:
  pushl $0
8010691c:	6a 00                	push   $0x0
  pushl $30
8010691e:	6a 1e                	push   $0x1e
  jmp alltraps
80106920:	e9 5b f8 ff ff       	jmp    80106180 <alltraps>

80106925 <vector31>:
.globl vector31
vector31:
  pushl $0
80106925:	6a 00                	push   $0x0
  pushl $31
80106927:	6a 1f                	push   $0x1f
  jmp alltraps
80106929:	e9 52 f8 ff ff       	jmp    80106180 <alltraps>

8010692e <vector32>:
.globl vector32
vector32:
  pushl $0
8010692e:	6a 00                	push   $0x0
  pushl $32
80106930:	6a 20                	push   $0x20
  jmp alltraps
80106932:	e9 49 f8 ff ff       	jmp    80106180 <alltraps>

80106937 <vector33>:
.globl vector33
vector33:
  pushl $0
80106937:	6a 00                	push   $0x0
  pushl $33
80106939:	6a 21                	push   $0x21
  jmp alltraps
8010693b:	e9 40 f8 ff ff       	jmp    80106180 <alltraps>

80106940 <vector34>:
.globl vector34
vector34:
  pushl $0
80106940:	6a 00                	push   $0x0
  pushl $34
80106942:	6a 22                	push   $0x22
  jmp alltraps
80106944:	e9 37 f8 ff ff       	jmp    80106180 <alltraps>

80106949 <vector35>:
.globl vector35
vector35:
  pushl $0
80106949:	6a 00                	push   $0x0
  pushl $35
8010694b:	6a 23                	push   $0x23
  jmp alltraps
8010694d:	e9 2e f8 ff ff       	jmp    80106180 <alltraps>

80106952 <vector36>:
.globl vector36
vector36:
  pushl $0
80106952:	6a 00                	push   $0x0
  pushl $36
80106954:	6a 24                	push   $0x24
  jmp alltraps
80106956:	e9 25 f8 ff ff       	jmp    80106180 <alltraps>

8010695b <vector37>:
.globl vector37
vector37:
  pushl $0
8010695b:	6a 00                	push   $0x0
  pushl $37
8010695d:	6a 25                	push   $0x25
  jmp alltraps
8010695f:	e9 1c f8 ff ff       	jmp    80106180 <alltraps>

80106964 <vector38>:
.globl vector38
vector38:
  pushl $0
80106964:	6a 00                	push   $0x0
  pushl $38
80106966:	6a 26                	push   $0x26
  jmp alltraps
80106968:	e9 13 f8 ff ff       	jmp    80106180 <alltraps>

8010696d <vector39>:
.globl vector39
vector39:
  pushl $0
8010696d:	6a 00                	push   $0x0
  pushl $39
8010696f:	6a 27                	push   $0x27
  jmp alltraps
80106971:	e9 0a f8 ff ff       	jmp    80106180 <alltraps>

80106976 <vector40>:
.globl vector40
vector40:
  pushl $0
80106976:	6a 00                	push   $0x0
  pushl $40
80106978:	6a 28                	push   $0x28
  jmp alltraps
8010697a:	e9 01 f8 ff ff       	jmp    80106180 <alltraps>

8010697f <vector41>:
.globl vector41
vector41:
  pushl $0
8010697f:	6a 00                	push   $0x0
  pushl $41
80106981:	6a 29                	push   $0x29
  jmp alltraps
80106983:	e9 f8 f7 ff ff       	jmp    80106180 <alltraps>

80106988 <vector42>:
.globl vector42
vector42:
  pushl $0
80106988:	6a 00                	push   $0x0
  pushl $42
8010698a:	6a 2a                	push   $0x2a
  jmp alltraps
8010698c:	e9 ef f7 ff ff       	jmp    80106180 <alltraps>

80106991 <vector43>:
.globl vector43
vector43:
  pushl $0
80106991:	6a 00                	push   $0x0
  pushl $43
80106993:	6a 2b                	push   $0x2b
  jmp alltraps
80106995:	e9 e6 f7 ff ff       	jmp    80106180 <alltraps>

8010699a <vector44>:
.globl vector44
vector44:
  pushl $0
8010699a:	6a 00                	push   $0x0
  pushl $44
8010699c:	6a 2c                	push   $0x2c
  jmp alltraps
8010699e:	e9 dd f7 ff ff       	jmp    80106180 <alltraps>

801069a3 <vector45>:
.globl vector45
vector45:
  pushl $0
801069a3:	6a 00                	push   $0x0
  pushl $45
801069a5:	6a 2d                	push   $0x2d
  jmp alltraps
801069a7:	e9 d4 f7 ff ff       	jmp    80106180 <alltraps>

801069ac <vector46>:
.globl vector46
vector46:
  pushl $0
801069ac:	6a 00                	push   $0x0
  pushl $46
801069ae:	6a 2e                	push   $0x2e
  jmp alltraps
801069b0:	e9 cb f7 ff ff       	jmp    80106180 <alltraps>

801069b5 <vector47>:
.globl vector47
vector47:
  pushl $0
801069b5:	6a 00                	push   $0x0
  pushl $47
801069b7:	6a 2f                	push   $0x2f
  jmp alltraps
801069b9:	e9 c2 f7 ff ff       	jmp    80106180 <alltraps>

801069be <vector48>:
.globl vector48
vector48:
  pushl $0
801069be:	6a 00                	push   $0x0
  pushl $48
801069c0:	6a 30                	push   $0x30
  jmp alltraps
801069c2:	e9 b9 f7 ff ff       	jmp    80106180 <alltraps>

801069c7 <vector49>:
.globl vector49
vector49:
  pushl $0
801069c7:	6a 00                	push   $0x0
  pushl $49
801069c9:	6a 31                	push   $0x31
  jmp alltraps
801069cb:	e9 b0 f7 ff ff       	jmp    80106180 <alltraps>

801069d0 <vector50>:
.globl vector50
vector50:
  pushl $0
801069d0:	6a 00                	push   $0x0
  pushl $50
801069d2:	6a 32                	push   $0x32
  jmp alltraps
801069d4:	e9 a7 f7 ff ff       	jmp    80106180 <alltraps>

801069d9 <vector51>:
.globl vector51
vector51:
  pushl $0
801069d9:	6a 00                	push   $0x0
  pushl $51
801069db:	6a 33                	push   $0x33
  jmp alltraps
801069dd:	e9 9e f7 ff ff       	jmp    80106180 <alltraps>

801069e2 <vector52>:
.globl vector52
vector52:
  pushl $0
801069e2:	6a 00                	push   $0x0
  pushl $52
801069e4:	6a 34                	push   $0x34
  jmp alltraps
801069e6:	e9 95 f7 ff ff       	jmp    80106180 <alltraps>

801069eb <vector53>:
.globl vector53
vector53:
  pushl $0
801069eb:	6a 00                	push   $0x0
  pushl $53
801069ed:	6a 35                	push   $0x35
  jmp alltraps
801069ef:	e9 8c f7 ff ff       	jmp    80106180 <alltraps>

801069f4 <vector54>:
.globl vector54
vector54:
  pushl $0
801069f4:	6a 00                	push   $0x0
  pushl $54
801069f6:	6a 36                	push   $0x36
  jmp alltraps
801069f8:	e9 83 f7 ff ff       	jmp    80106180 <alltraps>

801069fd <vector55>:
.globl vector55
vector55:
  pushl $0
801069fd:	6a 00                	push   $0x0
  pushl $55
801069ff:	6a 37                	push   $0x37
  jmp alltraps
80106a01:	e9 7a f7 ff ff       	jmp    80106180 <alltraps>

80106a06 <vector56>:
.globl vector56
vector56:
  pushl $0
80106a06:	6a 00                	push   $0x0
  pushl $56
80106a08:	6a 38                	push   $0x38
  jmp alltraps
80106a0a:	e9 71 f7 ff ff       	jmp    80106180 <alltraps>

80106a0f <vector57>:
.globl vector57
vector57:
  pushl $0
80106a0f:	6a 00                	push   $0x0
  pushl $57
80106a11:	6a 39                	push   $0x39
  jmp alltraps
80106a13:	e9 68 f7 ff ff       	jmp    80106180 <alltraps>

80106a18 <vector58>:
.globl vector58
vector58:
  pushl $0
80106a18:	6a 00                	push   $0x0
  pushl $58
80106a1a:	6a 3a                	push   $0x3a
  jmp alltraps
80106a1c:	e9 5f f7 ff ff       	jmp    80106180 <alltraps>

80106a21 <vector59>:
.globl vector59
vector59:
  pushl $0
80106a21:	6a 00                	push   $0x0
  pushl $59
80106a23:	6a 3b                	push   $0x3b
  jmp alltraps
80106a25:	e9 56 f7 ff ff       	jmp    80106180 <alltraps>

80106a2a <vector60>:
.globl vector60
vector60:
  pushl $0
80106a2a:	6a 00                	push   $0x0
  pushl $60
80106a2c:	6a 3c                	push   $0x3c
  jmp alltraps
80106a2e:	e9 4d f7 ff ff       	jmp    80106180 <alltraps>

80106a33 <vector61>:
.globl vector61
vector61:
  pushl $0
80106a33:	6a 00                	push   $0x0
  pushl $61
80106a35:	6a 3d                	push   $0x3d
  jmp alltraps
80106a37:	e9 44 f7 ff ff       	jmp    80106180 <alltraps>

80106a3c <vector62>:
.globl vector62
vector62:
  pushl $0
80106a3c:	6a 00                	push   $0x0
  pushl $62
80106a3e:	6a 3e                	push   $0x3e
  jmp alltraps
80106a40:	e9 3b f7 ff ff       	jmp    80106180 <alltraps>

80106a45 <vector63>:
.globl vector63
vector63:
  pushl $0
80106a45:	6a 00                	push   $0x0
  pushl $63
80106a47:	6a 3f                	push   $0x3f
  jmp alltraps
80106a49:	e9 32 f7 ff ff       	jmp    80106180 <alltraps>

80106a4e <vector64>:
.globl vector64
vector64:
  pushl $0
80106a4e:	6a 00                	push   $0x0
  pushl $64
80106a50:	6a 40                	push   $0x40
  jmp alltraps
80106a52:	e9 29 f7 ff ff       	jmp    80106180 <alltraps>

80106a57 <vector65>:
.globl vector65
vector65:
  pushl $0
80106a57:	6a 00                	push   $0x0
  pushl $65
80106a59:	6a 41                	push   $0x41
  jmp alltraps
80106a5b:	e9 20 f7 ff ff       	jmp    80106180 <alltraps>

80106a60 <vector66>:
.globl vector66
vector66:
  pushl $0
80106a60:	6a 00                	push   $0x0
  pushl $66
80106a62:	6a 42                	push   $0x42
  jmp alltraps
80106a64:	e9 17 f7 ff ff       	jmp    80106180 <alltraps>

80106a69 <vector67>:
.globl vector67
vector67:
  pushl $0
80106a69:	6a 00                	push   $0x0
  pushl $67
80106a6b:	6a 43                	push   $0x43
  jmp alltraps
80106a6d:	e9 0e f7 ff ff       	jmp    80106180 <alltraps>

80106a72 <vector68>:
.globl vector68
vector68:
  pushl $0
80106a72:	6a 00                	push   $0x0
  pushl $68
80106a74:	6a 44                	push   $0x44
  jmp alltraps
80106a76:	e9 05 f7 ff ff       	jmp    80106180 <alltraps>

80106a7b <vector69>:
.globl vector69
vector69:
  pushl $0
80106a7b:	6a 00                	push   $0x0
  pushl $69
80106a7d:	6a 45                	push   $0x45
  jmp alltraps
80106a7f:	e9 fc f6 ff ff       	jmp    80106180 <alltraps>

80106a84 <vector70>:
.globl vector70
vector70:
  pushl $0
80106a84:	6a 00                	push   $0x0
  pushl $70
80106a86:	6a 46                	push   $0x46
  jmp alltraps
80106a88:	e9 f3 f6 ff ff       	jmp    80106180 <alltraps>

80106a8d <vector71>:
.globl vector71
vector71:
  pushl $0
80106a8d:	6a 00                	push   $0x0
  pushl $71
80106a8f:	6a 47                	push   $0x47
  jmp alltraps
80106a91:	e9 ea f6 ff ff       	jmp    80106180 <alltraps>

80106a96 <vector72>:
.globl vector72
vector72:
  pushl $0
80106a96:	6a 00                	push   $0x0
  pushl $72
80106a98:	6a 48                	push   $0x48
  jmp alltraps
80106a9a:	e9 e1 f6 ff ff       	jmp    80106180 <alltraps>

80106a9f <vector73>:
.globl vector73
vector73:
  pushl $0
80106a9f:	6a 00                	push   $0x0
  pushl $73
80106aa1:	6a 49                	push   $0x49
  jmp alltraps
80106aa3:	e9 d8 f6 ff ff       	jmp    80106180 <alltraps>

80106aa8 <vector74>:
.globl vector74
vector74:
  pushl $0
80106aa8:	6a 00                	push   $0x0
  pushl $74
80106aaa:	6a 4a                	push   $0x4a
  jmp alltraps
80106aac:	e9 cf f6 ff ff       	jmp    80106180 <alltraps>

80106ab1 <vector75>:
.globl vector75
vector75:
  pushl $0
80106ab1:	6a 00                	push   $0x0
  pushl $75
80106ab3:	6a 4b                	push   $0x4b
  jmp alltraps
80106ab5:	e9 c6 f6 ff ff       	jmp    80106180 <alltraps>

80106aba <vector76>:
.globl vector76
vector76:
  pushl $0
80106aba:	6a 00                	push   $0x0
  pushl $76
80106abc:	6a 4c                	push   $0x4c
  jmp alltraps
80106abe:	e9 bd f6 ff ff       	jmp    80106180 <alltraps>

80106ac3 <vector77>:
.globl vector77
vector77:
  pushl $0
80106ac3:	6a 00                	push   $0x0
  pushl $77
80106ac5:	6a 4d                	push   $0x4d
  jmp alltraps
80106ac7:	e9 b4 f6 ff ff       	jmp    80106180 <alltraps>

80106acc <vector78>:
.globl vector78
vector78:
  pushl $0
80106acc:	6a 00                	push   $0x0
  pushl $78
80106ace:	6a 4e                	push   $0x4e
  jmp alltraps
80106ad0:	e9 ab f6 ff ff       	jmp    80106180 <alltraps>

80106ad5 <vector79>:
.globl vector79
vector79:
  pushl $0
80106ad5:	6a 00                	push   $0x0
  pushl $79
80106ad7:	6a 4f                	push   $0x4f
  jmp alltraps
80106ad9:	e9 a2 f6 ff ff       	jmp    80106180 <alltraps>

80106ade <vector80>:
.globl vector80
vector80:
  pushl $0
80106ade:	6a 00                	push   $0x0
  pushl $80
80106ae0:	6a 50                	push   $0x50
  jmp alltraps
80106ae2:	e9 99 f6 ff ff       	jmp    80106180 <alltraps>

80106ae7 <vector81>:
.globl vector81
vector81:
  pushl $0
80106ae7:	6a 00                	push   $0x0
  pushl $81
80106ae9:	6a 51                	push   $0x51
  jmp alltraps
80106aeb:	e9 90 f6 ff ff       	jmp    80106180 <alltraps>

80106af0 <vector82>:
.globl vector82
vector82:
  pushl $0
80106af0:	6a 00                	push   $0x0
  pushl $82
80106af2:	6a 52                	push   $0x52
  jmp alltraps
80106af4:	e9 87 f6 ff ff       	jmp    80106180 <alltraps>

80106af9 <vector83>:
.globl vector83
vector83:
  pushl $0
80106af9:	6a 00                	push   $0x0
  pushl $83
80106afb:	6a 53                	push   $0x53
  jmp alltraps
80106afd:	e9 7e f6 ff ff       	jmp    80106180 <alltraps>

80106b02 <vector84>:
.globl vector84
vector84:
  pushl $0
80106b02:	6a 00                	push   $0x0
  pushl $84
80106b04:	6a 54                	push   $0x54
  jmp alltraps
80106b06:	e9 75 f6 ff ff       	jmp    80106180 <alltraps>

80106b0b <vector85>:
.globl vector85
vector85:
  pushl $0
80106b0b:	6a 00                	push   $0x0
  pushl $85
80106b0d:	6a 55                	push   $0x55
  jmp alltraps
80106b0f:	e9 6c f6 ff ff       	jmp    80106180 <alltraps>

80106b14 <vector86>:
.globl vector86
vector86:
  pushl $0
80106b14:	6a 00                	push   $0x0
  pushl $86
80106b16:	6a 56                	push   $0x56
  jmp alltraps
80106b18:	e9 63 f6 ff ff       	jmp    80106180 <alltraps>

80106b1d <vector87>:
.globl vector87
vector87:
  pushl $0
80106b1d:	6a 00                	push   $0x0
  pushl $87
80106b1f:	6a 57                	push   $0x57
  jmp alltraps
80106b21:	e9 5a f6 ff ff       	jmp    80106180 <alltraps>

80106b26 <vector88>:
.globl vector88
vector88:
  pushl $0
80106b26:	6a 00                	push   $0x0
  pushl $88
80106b28:	6a 58                	push   $0x58
  jmp alltraps
80106b2a:	e9 51 f6 ff ff       	jmp    80106180 <alltraps>

80106b2f <vector89>:
.globl vector89
vector89:
  pushl $0
80106b2f:	6a 00                	push   $0x0
  pushl $89
80106b31:	6a 59                	push   $0x59
  jmp alltraps
80106b33:	e9 48 f6 ff ff       	jmp    80106180 <alltraps>

80106b38 <vector90>:
.globl vector90
vector90:
  pushl $0
80106b38:	6a 00                	push   $0x0
  pushl $90
80106b3a:	6a 5a                	push   $0x5a
  jmp alltraps
80106b3c:	e9 3f f6 ff ff       	jmp    80106180 <alltraps>

80106b41 <vector91>:
.globl vector91
vector91:
  pushl $0
80106b41:	6a 00                	push   $0x0
  pushl $91
80106b43:	6a 5b                	push   $0x5b
  jmp alltraps
80106b45:	e9 36 f6 ff ff       	jmp    80106180 <alltraps>

80106b4a <vector92>:
.globl vector92
vector92:
  pushl $0
80106b4a:	6a 00                	push   $0x0
  pushl $92
80106b4c:	6a 5c                	push   $0x5c
  jmp alltraps
80106b4e:	e9 2d f6 ff ff       	jmp    80106180 <alltraps>

80106b53 <vector93>:
.globl vector93
vector93:
  pushl $0
80106b53:	6a 00                	push   $0x0
  pushl $93
80106b55:	6a 5d                	push   $0x5d
  jmp alltraps
80106b57:	e9 24 f6 ff ff       	jmp    80106180 <alltraps>

80106b5c <vector94>:
.globl vector94
vector94:
  pushl $0
80106b5c:	6a 00                	push   $0x0
  pushl $94
80106b5e:	6a 5e                	push   $0x5e
  jmp alltraps
80106b60:	e9 1b f6 ff ff       	jmp    80106180 <alltraps>

80106b65 <vector95>:
.globl vector95
vector95:
  pushl $0
80106b65:	6a 00                	push   $0x0
  pushl $95
80106b67:	6a 5f                	push   $0x5f
  jmp alltraps
80106b69:	e9 12 f6 ff ff       	jmp    80106180 <alltraps>

80106b6e <vector96>:
.globl vector96
vector96:
  pushl $0
80106b6e:	6a 00                	push   $0x0
  pushl $96
80106b70:	6a 60                	push   $0x60
  jmp alltraps
80106b72:	e9 09 f6 ff ff       	jmp    80106180 <alltraps>

80106b77 <vector97>:
.globl vector97
vector97:
  pushl $0
80106b77:	6a 00                	push   $0x0
  pushl $97
80106b79:	6a 61                	push   $0x61
  jmp alltraps
80106b7b:	e9 00 f6 ff ff       	jmp    80106180 <alltraps>

80106b80 <vector98>:
.globl vector98
vector98:
  pushl $0
80106b80:	6a 00                	push   $0x0
  pushl $98
80106b82:	6a 62                	push   $0x62
  jmp alltraps
80106b84:	e9 f7 f5 ff ff       	jmp    80106180 <alltraps>

80106b89 <vector99>:
.globl vector99
vector99:
  pushl $0
80106b89:	6a 00                	push   $0x0
  pushl $99
80106b8b:	6a 63                	push   $0x63
  jmp alltraps
80106b8d:	e9 ee f5 ff ff       	jmp    80106180 <alltraps>

80106b92 <vector100>:
.globl vector100
vector100:
  pushl $0
80106b92:	6a 00                	push   $0x0
  pushl $100
80106b94:	6a 64                	push   $0x64
  jmp alltraps
80106b96:	e9 e5 f5 ff ff       	jmp    80106180 <alltraps>

80106b9b <vector101>:
.globl vector101
vector101:
  pushl $0
80106b9b:	6a 00                	push   $0x0
  pushl $101
80106b9d:	6a 65                	push   $0x65
  jmp alltraps
80106b9f:	e9 dc f5 ff ff       	jmp    80106180 <alltraps>

80106ba4 <vector102>:
.globl vector102
vector102:
  pushl $0
80106ba4:	6a 00                	push   $0x0
  pushl $102
80106ba6:	6a 66                	push   $0x66
  jmp alltraps
80106ba8:	e9 d3 f5 ff ff       	jmp    80106180 <alltraps>

80106bad <vector103>:
.globl vector103
vector103:
  pushl $0
80106bad:	6a 00                	push   $0x0
  pushl $103
80106baf:	6a 67                	push   $0x67
  jmp alltraps
80106bb1:	e9 ca f5 ff ff       	jmp    80106180 <alltraps>

80106bb6 <vector104>:
.globl vector104
vector104:
  pushl $0
80106bb6:	6a 00                	push   $0x0
  pushl $104
80106bb8:	6a 68                	push   $0x68
  jmp alltraps
80106bba:	e9 c1 f5 ff ff       	jmp    80106180 <alltraps>

80106bbf <vector105>:
.globl vector105
vector105:
  pushl $0
80106bbf:	6a 00                	push   $0x0
  pushl $105
80106bc1:	6a 69                	push   $0x69
  jmp alltraps
80106bc3:	e9 b8 f5 ff ff       	jmp    80106180 <alltraps>

80106bc8 <vector106>:
.globl vector106
vector106:
  pushl $0
80106bc8:	6a 00                	push   $0x0
  pushl $106
80106bca:	6a 6a                	push   $0x6a
  jmp alltraps
80106bcc:	e9 af f5 ff ff       	jmp    80106180 <alltraps>

80106bd1 <vector107>:
.globl vector107
vector107:
  pushl $0
80106bd1:	6a 00                	push   $0x0
  pushl $107
80106bd3:	6a 6b                	push   $0x6b
  jmp alltraps
80106bd5:	e9 a6 f5 ff ff       	jmp    80106180 <alltraps>

80106bda <vector108>:
.globl vector108
vector108:
  pushl $0
80106bda:	6a 00                	push   $0x0
  pushl $108
80106bdc:	6a 6c                	push   $0x6c
  jmp alltraps
80106bde:	e9 9d f5 ff ff       	jmp    80106180 <alltraps>

80106be3 <vector109>:
.globl vector109
vector109:
  pushl $0
80106be3:	6a 00                	push   $0x0
  pushl $109
80106be5:	6a 6d                	push   $0x6d
  jmp alltraps
80106be7:	e9 94 f5 ff ff       	jmp    80106180 <alltraps>

80106bec <vector110>:
.globl vector110
vector110:
  pushl $0
80106bec:	6a 00                	push   $0x0
  pushl $110
80106bee:	6a 6e                	push   $0x6e
  jmp alltraps
80106bf0:	e9 8b f5 ff ff       	jmp    80106180 <alltraps>

80106bf5 <vector111>:
.globl vector111
vector111:
  pushl $0
80106bf5:	6a 00                	push   $0x0
  pushl $111
80106bf7:	6a 6f                	push   $0x6f
  jmp alltraps
80106bf9:	e9 82 f5 ff ff       	jmp    80106180 <alltraps>

80106bfe <vector112>:
.globl vector112
vector112:
  pushl $0
80106bfe:	6a 00                	push   $0x0
  pushl $112
80106c00:	6a 70                	push   $0x70
  jmp alltraps
80106c02:	e9 79 f5 ff ff       	jmp    80106180 <alltraps>

80106c07 <vector113>:
.globl vector113
vector113:
  pushl $0
80106c07:	6a 00                	push   $0x0
  pushl $113
80106c09:	6a 71                	push   $0x71
  jmp alltraps
80106c0b:	e9 70 f5 ff ff       	jmp    80106180 <alltraps>

80106c10 <vector114>:
.globl vector114
vector114:
  pushl $0
80106c10:	6a 00                	push   $0x0
  pushl $114
80106c12:	6a 72                	push   $0x72
  jmp alltraps
80106c14:	e9 67 f5 ff ff       	jmp    80106180 <alltraps>

80106c19 <vector115>:
.globl vector115
vector115:
  pushl $0
80106c19:	6a 00                	push   $0x0
  pushl $115
80106c1b:	6a 73                	push   $0x73
  jmp alltraps
80106c1d:	e9 5e f5 ff ff       	jmp    80106180 <alltraps>

80106c22 <vector116>:
.globl vector116
vector116:
  pushl $0
80106c22:	6a 00                	push   $0x0
  pushl $116
80106c24:	6a 74                	push   $0x74
  jmp alltraps
80106c26:	e9 55 f5 ff ff       	jmp    80106180 <alltraps>

80106c2b <vector117>:
.globl vector117
vector117:
  pushl $0
80106c2b:	6a 00                	push   $0x0
  pushl $117
80106c2d:	6a 75                	push   $0x75
  jmp alltraps
80106c2f:	e9 4c f5 ff ff       	jmp    80106180 <alltraps>

80106c34 <vector118>:
.globl vector118
vector118:
  pushl $0
80106c34:	6a 00                	push   $0x0
  pushl $118
80106c36:	6a 76                	push   $0x76
  jmp alltraps
80106c38:	e9 43 f5 ff ff       	jmp    80106180 <alltraps>

80106c3d <vector119>:
.globl vector119
vector119:
  pushl $0
80106c3d:	6a 00                	push   $0x0
  pushl $119
80106c3f:	6a 77                	push   $0x77
  jmp alltraps
80106c41:	e9 3a f5 ff ff       	jmp    80106180 <alltraps>

80106c46 <vector120>:
.globl vector120
vector120:
  pushl $0
80106c46:	6a 00                	push   $0x0
  pushl $120
80106c48:	6a 78                	push   $0x78
  jmp alltraps
80106c4a:	e9 31 f5 ff ff       	jmp    80106180 <alltraps>

80106c4f <vector121>:
.globl vector121
vector121:
  pushl $0
80106c4f:	6a 00                	push   $0x0
  pushl $121
80106c51:	6a 79                	push   $0x79
  jmp alltraps
80106c53:	e9 28 f5 ff ff       	jmp    80106180 <alltraps>

80106c58 <vector122>:
.globl vector122
vector122:
  pushl $0
80106c58:	6a 00                	push   $0x0
  pushl $122
80106c5a:	6a 7a                	push   $0x7a
  jmp alltraps
80106c5c:	e9 1f f5 ff ff       	jmp    80106180 <alltraps>

80106c61 <vector123>:
.globl vector123
vector123:
  pushl $0
80106c61:	6a 00                	push   $0x0
  pushl $123
80106c63:	6a 7b                	push   $0x7b
  jmp alltraps
80106c65:	e9 16 f5 ff ff       	jmp    80106180 <alltraps>

80106c6a <vector124>:
.globl vector124
vector124:
  pushl $0
80106c6a:	6a 00                	push   $0x0
  pushl $124
80106c6c:	6a 7c                	push   $0x7c
  jmp alltraps
80106c6e:	e9 0d f5 ff ff       	jmp    80106180 <alltraps>

80106c73 <vector125>:
.globl vector125
vector125:
  pushl $0
80106c73:	6a 00                	push   $0x0
  pushl $125
80106c75:	6a 7d                	push   $0x7d
  jmp alltraps
80106c77:	e9 04 f5 ff ff       	jmp    80106180 <alltraps>

80106c7c <vector126>:
.globl vector126
vector126:
  pushl $0
80106c7c:	6a 00                	push   $0x0
  pushl $126
80106c7e:	6a 7e                	push   $0x7e
  jmp alltraps
80106c80:	e9 fb f4 ff ff       	jmp    80106180 <alltraps>

80106c85 <vector127>:
.globl vector127
vector127:
  pushl $0
80106c85:	6a 00                	push   $0x0
  pushl $127
80106c87:	6a 7f                	push   $0x7f
  jmp alltraps
80106c89:	e9 f2 f4 ff ff       	jmp    80106180 <alltraps>

80106c8e <vector128>:
.globl vector128
vector128:
  pushl $0
80106c8e:	6a 00                	push   $0x0
  pushl $128
80106c90:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106c95:	e9 e6 f4 ff ff       	jmp    80106180 <alltraps>

80106c9a <vector129>:
.globl vector129
vector129:
  pushl $0
80106c9a:	6a 00                	push   $0x0
  pushl $129
80106c9c:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106ca1:	e9 da f4 ff ff       	jmp    80106180 <alltraps>

80106ca6 <vector130>:
.globl vector130
vector130:
  pushl $0
80106ca6:	6a 00                	push   $0x0
  pushl $130
80106ca8:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106cad:	e9 ce f4 ff ff       	jmp    80106180 <alltraps>

80106cb2 <vector131>:
.globl vector131
vector131:
  pushl $0
80106cb2:	6a 00                	push   $0x0
  pushl $131
80106cb4:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106cb9:	e9 c2 f4 ff ff       	jmp    80106180 <alltraps>

80106cbe <vector132>:
.globl vector132
vector132:
  pushl $0
80106cbe:	6a 00                	push   $0x0
  pushl $132
80106cc0:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106cc5:	e9 b6 f4 ff ff       	jmp    80106180 <alltraps>

80106cca <vector133>:
.globl vector133
vector133:
  pushl $0
80106cca:	6a 00                	push   $0x0
  pushl $133
80106ccc:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106cd1:	e9 aa f4 ff ff       	jmp    80106180 <alltraps>

80106cd6 <vector134>:
.globl vector134
vector134:
  pushl $0
80106cd6:	6a 00                	push   $0x0
  pushl $134
80106cd8:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106cdd:	e9 9e f4 ff ff       	jmp    80106180 <alltraps>

80106ce2 <vector135>:
.globl vector135
vector135:
  pushl $0
80106ce2:	6a 00                	push   $0x0
  pushl $135
80106ce4:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106ce9:	e9 92 f4 ff ff       	jmp    80106180 <alltraps>

80106cee <vector136>:
.globl vector136
vector136:
  pushl $0
80106cee:	6a 00                	push   $0x0
  pushl $136
80106cf0:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106cf5:	e9 86 f4 ff ff       	jmp    80106180 <alltraps>

80106cfa <vector137>:
.globl vector137
vector137:
  pushl $0
80106cfa:	6a 00                	push   $0x0
  pushl $137
80106cfc:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106d01:	e9 7a f4 ff ff       	jmp    80106180 <alltraps>

80106d06 <vector138>:
.globl vector138
vector138:
  pushl $0
80106d06:	6a 00                	push   $0x0
  pushl $138
80106d08:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106d0d:	e9 6e f4 ff ff       	jmp    80106180 <alltraps>

80106d12 <vector139>:
.globl vector139
vector139:
  pushl $0
80106d12:	6a 00                	push   $0x0
  pushl $139
80106d14:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106d19:	e9 62 f4 ff ff       	jmp    80106180 <alltraps>

80106d1e <vector140>:
.globl vector140
vector140:
  pushl $0
80106d1e:	6a 00                	push   $0x0
  pushl $140
80106d20:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106d25:	e9 56 f4 ff ff       	jmp    80106180 <alltraps>

80106d2a <vector141>:
.globl vector141
vector141:
  pushl $0
80106d2a:	6a 00                	push   $0x0
  pushl $141
80106d2c:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106d31:	e9 4a f4 ff ff       	jmp    80106180 <alltraps>

80106d36 <vector142>:
.globl vector142
vector142:
  pushl $0
80106d36:	6a 00                	push   $0x0
  pushl $142
80106d38:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106d3d:	e9 3e f4 ff ff       	jmp    80106180 <alltraps>

80106d42 <vector143>:
.globl vector143
vector143:
  pushl $0
80106d42:	6a 00                	push   $0x0
  pushl $143
80106d44:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106d49:	e9 32 f4 ff ff       	jmp    80106180 <alltraps>

80106d4e <vector144>:
.globl vector144
vector144:
  pushl $0
80106d4e:	6a 00                	push   $0x0
  pushl $144
80106d50:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106d55:	e9 26 f4 ff ff       	jmp    80106180 <alltraps>

80106d5a <vector145>:
.globl vector145
vector145:
  pushl $0
80106d5a:	6a 00                	push   $0x0
  pushl $145
80106d5c:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106d61:	e9 1a f4 ff ff       	jmp    80106180 <alltraps>

80106d66 <vector146>:
.globl vector146
vector146:
  pushl $0
80106d66:	6a 00                	push   $0x0
  pushl $146
80106d68:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106d6d:	e9 0e f4 ff ff       	jmp    80106180 <alltraps>

80106d72 <vector147>:
.globl vector147
vector147:
  pushl $0
80106d72:	6a 00                	push   $0x0
  pushl $147
80106d74:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106d79:	e9 02 f4 ff ff       	jmp    80106180 <alltraps>

80106d7e <vector148>:
.globl vector148
vector148:
  pushl $0
80106d7e:	6a 00                	push   $0x0
  pushl $148
80106d80:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106d85:	e9 f6 f3 ff ff       	jmp    80106180 <alltraps>

80106d8a <vector149>:
.globl vector149
vector149:
  pushl $0
80106d8a:	6a 00                	push   $0x0
  pushl $149
80106d8c:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106d91:	e9 ea f3 ff ff       	jmp    80106180 <alltraps>

80106d96 <vector150>:
.globl vector150
vector150:
  pushl $0
80106d96:	6a 00                	push   $0x0
  pushl $150
80106d98:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106d9d:	e9 de f3 ff ff       	jmp    80106180 <alltraps>

80106da2 <vector151>:
.globl vector151
vector151:
  pushl $0
80106da2:	6a 00                	push   $0x0
  pushl $151
80106da4:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106da9:	e9 d2 f3 ff ff       	jmp    80106180 <alltraps>

80106dae <vector152>:
.globl vector152
vector152:
  pushl $0
80106dae:	6a 00                	push   $0x0
  pushl $152
80106db0:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106db5:	e9 c6 f3 ff ff       	jmp    80106180 <alltraps>

80106dba <vector153>:
.globl vector153
vector153:
  pushl $0
80106dba:	6a 00                	push   $0x0
  pushl $153
80106dbc:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106dc1:	e9 ba f3 ff ff       	jmp    80106180 <alltraps>

80106dc6 <vector154>:
.globl vector154
vector154:
  pushl $0
80106dc6:	6a 00                	push   $0x0
  pushl $154
80106dc8:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106dcd:	e9 ae f3 ff ff       	jmp    80106180 <alltraps>

80106dd2 <vector155>:
.globl vector155
vector155:
  pushl $0
80106dd2:	6a 00                	push   $0x0
  pushl $155
80106dd4:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106dd9:	e9 a2 f3 ff ff       	jmp    80106180 <alltraps>

80106dde <vector156>:
.globl vector156
vector156:
  pushl $0
80106dde:	6a 00                	push   $0x0
  pushl $156
80106de0:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106de5:	e9 96 f3 ff ff       	jmp    80106180 <alltraps>

80106dea <vector157>:
.globl vector157
vector157:
  pushl $0
80106dea:	6a 00                	push   $0x0
  pushl $157
80106dec:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106df1:	e9 8a f3 ff ff       	jmp    80106180 <alltraps>

80106df6 <vector158>:
.globl vector158
vector158:
  pushl $0
80106df6:	6a 00                	push   $0x0
  pushl $158
80106df8:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106dfd:	e9 7e f3 ff ff       	jmp    80106180 <alltraps>

80106e02 <vector159>:
.globl vector159
vector159:
  pushl $0
80106e02:	6a 00                	push   $0x0
  pushl $159
80106e04:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106e09:	e9 72 f3 ff ff       	jmp    80106180 <alltraps>

80106e0e <vector160>:
.globl vector160
vector160:
  pushl $0
80106e0e:	6a 00                	push   $0x0
  pushl $160
80106e10:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106e15:	e9 66 f3 ff ff       	jmp    80106180 <alltraps>

80106e1a <vector161>:
.globl vector161
vector161:
  pushl $0
80106e1a:	6a 00                	push   $0x0
  pushl $161
80106e1c:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106e21:	e9 5a f3 ff ff       	jmp    80106180 <alltraps>

80106e26 <vector162>:
.globl vector162
vector162:
  pushl $0
80106e26:	6a 00                	push   $0x0
  pushl $162
80106e28:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106e2d:	e9 4e f3 ff ff       	jmp    80106180 <alltraps>

80106e32 <vector163>:
.globl vector163
vector163:
  pushl $0
80106e32:	6a 00                	push   $0x0
  pushl $163
80106e34:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106e39:	e9 42 f3 ff ff       	jmp    80106180 <alltraps>

80106e3e <vector164>:
.globl vector164
vector164:
  pushl $0
80106e3e:	6a 00                	push   $0x0
  pushl $164
80106e40:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106e45:	e9 36 f3 ff ff       	jmp    80106180 <alltraps>

80106e4a <vector165>:
.globl vector165
vector165:
  pushl $0
80106e4a:	6a 00                	push   $0x0
  pushl $165
80106e4c:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106e51:	e9 2a f3 ff ff       	jmp    80106180 <alltraps>

80106e56 <vector166>:
.globl vector166
vector166:
  pushl $0
80106e56:	6a 00                	push   $0x0
  pushl $166
80106e58:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106e5d:	e9 1e f3 ff ff       	jmp    80106180 <alltraps>

80106e62 <vector167>:
.globl vector167
vector167:
  pushl $0
80106e62:	6a 00                	push   $0x0
  pushl $167
80106e64:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106e69:	e9 12 f3 ff ff       	jmp    80106180 <alltraps>

80106e6e <vector168>:
.globl vector168
vector168:
  pushl $0
80106e6e:	6a 00                	push   $0x0
  pushl $168
80106e70:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106e75:	e9 06 f3 ff ff       	jmp    80106180 <alltraps>

80106e7a <vector169>:
.globl vector169
vector169:
  pushl $0
80106e7a:	6a 00                	push   $0x0
  pushl $169
80106e7c:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106e81:	e9 fa f2 ff ff       	jmp    80106180 <alltraps>

80106e86 <vector170>:
.globl vector170
vector170:
  pushl $0
80106e86:	6a 00                	push   $0x0
  pushl $170
80106e88:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106e8d:	e9 ee f2 ff ff       	jmp    80106180 <alltraps>

80106e92 <vector171>:
.globl vector171
vector171:
  pushl $0
80106e92:	6a 00                	push   $0x0
  pushl $171
80106e94:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106e99:	e9 e2 f2 ff ff       	jmp    80106180 <alltraps>

80106e9e <vector172>:
.globl vector172
vector172:
  pushl $0
80106e9e:	6a 00                	push   $0x0
  pushl $172
80106ea0:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106ea5:	e9 d6 f2 ff ff       	jmp    80106180 <alltraps>

80106eaa <vector173>:
.globl vector173
vector173:
  pushl $0
80106eaa:	6a 00                	push   $0x0
  pushl $173
80106eac:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106eb1:	e9 ca f2 ff ff       	jmp    80106180 <alltraps>

80106eb6 <vector174>:
.globl vector174
vector174:
  pushl $0
80106eb6:	6a 00                	push   $0x0
  pushl $174
80106eb8:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106ebd:	e9 be f2 ff ff       	jmp    80106180 <alltraps>

80106ec2 <vector175>:
.globl vector175
vector175:
  pushl $0
80106ec2:	6a 00                	push   $0x0
  pushl $175
80106ec4:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106ec9:	e9 b2 f2 ff ff       	jmp    80106180 <alltraps>

80106ece <vector176>:
.globl vector176
vector176:
  pushl $0
80106ece:	6a 00                	push   $0x0
  pushl $176
80106ed0:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106ed5:	e9 a6 f2 ff ff       	jmp    80106180 <alltraps>

80106eda <vector177>:
.globl vector177
vector177:
  pushl $0
80106eda:	6a 00                	push   $0x0
  pushl $177
80106edc:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106ee1:	e9 9a f2 ff ff       	jmp    80106180 <alltraps>

80106ee6 <vector178>:
.globl vector178
vector178:
  pushl $0
80106ee6:	6a 00                	push   $0x0
  pushl $178
80106ee8:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106eed:	e9 8e f2 ff ff       	jmp    80106180 <alltraps>

80106ef2 <vector179>:
.globl vector179
vector179:
  pushl $0
80106ef2:	6a 00                	push   $0x0
  pushl $179
80106ef4:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106ef9:	e9 82 f2 ff ff       	jmp    80106180 <alltraps>

80106efe <vector180>:
.globl vector180
vector180:
  pushl $0
80106efe:	6a 00                	push   $0x0
  pushl $180
80106f00:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106f05:	e9 76 f2 ff ff       	jmp    80106180 <alltraps>

80106f0a <vector181>:
.globl vector181
vector181:
  pushl $0
80106f0a:	6a 00                	push   $0x0
  pushl $181
80106f0c:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106f11:	e9 6a f2 ff ff       	jmp    80106180 <alltraps>

80106f16 <vector182>:
.globl vector182
vector182:
  pushl $0
80106f16:	6a 00                	push   $0x0
  pushl $182
80106f18:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106f1d:	e9 5e f2 ff ff       	jmp    80106180 <alltraps>

80106f22 <vector183>:
.globl vector183
vector183:
  pushl $0
80106f22:	6a 00                	push   $0x0
  pushl $183
80106f24:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106f29:	e9 52 f2 ff ff       	jmp    80106180 <alltraps>

80106f2e <vector184>:
.globl vector184
vector184:
  pushl $0
80106f2e:	6a 00                	push   $0x0
  pushl $184
80106f30:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106f35:	e9 46 f2 ff ff       	jmp    80106180 <alltraps>

80106f3a <vector185>:
.globl vector185
vector185:
  pushl $0
80106f3a:	6a 00                	push   $0x0
  pushl $185
80106f3c:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106f41:	e9 3a f2 ff ff       	jmp    80106180 <alltraps>

80106f46 <vector186>:
.globl vector186
vector186:
  pushl $0
80106f46:	6a 00                	push   $0x0
  pushl $186
80106f48:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106f4d:	e9 2e f2 ff ff       	jmp    80106180 <alltraps>

80106f52 <vector187>:
.globl vector187
vector187:
  pushl $0
80106f52:	6a 00                	push   $0x0
  pushl $187
80106f54:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106f59:	e9 22 f2 ff ff       	jmp    80106180 <alltraps>

80106f5e <vector188>:
.globl vector188
vector188:
  pushl $0
80106f5e:	6a 00                	push   $0x0
  pushl $188
80106f60:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106f65:	e9 16 f2 ff ff       	jmp    80106180 <alltraps>

80106f6a <vector189>:
.globl vector189
vector189:
  pushl $0
80106f6a:	6a 00                	push   $0x0
  pushl $189
80106f6c:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106f71:	e9 0a f2 ff ff       	jmp    80106180 <alltraps>

80106f76 <vector190>:
.globl vector190
vector190:
  pushl $0
80106f76:	6a 00                	push   $0x0
  pushl $190
80106f78:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106f7d:	e9 fe f1 ff ff       	jmp    80106180 <alltraps>

80106f82 <vector191>:
.globl vector191
vector191:
  pushl $0
80106f82:	6a 00                	push   $0x0
  pushl $191
80106f84:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106f89:	e9 f2 f1 ff ff       	jmp    80106180 <alltraps>

80106f8e <vector192>:
.globl vector192
vector192:
  pushl $0
80106f8e:	6a 00                	push   $0x0
  pushl $192
80106f90:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106f95:	e9 e6 f1 ff ff       	jmp    80106180 <alltraps>

80106f9a <vector193>:
.globl vector193
vector193:
  pushl $0
80106f9a:	6a 00                	push   $0x0
  pushl $193
80106f9c:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106fa1:	e9 da f1 ff ff       	jmp    80106180 <alltraps>

80106fa6 <vector194>:
.globl vector194
vector194:
  pushl $0
80106fa6:	6a 00                	push   $0x0
  pushl $194
80106fa8:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106fad:	e9 ce f1 ff ff       	jmp    80106180 <alltraps>

80106fb2 <vector195>:
.globl vector195
vector195:
  pushl $0
80106fb2:	6a 00                	push   $0x0
  pushl $195
80106fb4:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106fb9:	e9 c2 f1 ff ff       	jmp    80106180 <alltraps>

80106fbe <vector196>:
.globl vector196
vector196:
  pushl $0
80106fbe:	6a 00                	push   $0x0
  pushl $196
80106fc0:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106fc5:	e9 b6 f1 ff ff       	jmp    80106180 <alltraps>

80106fca <vector197>:
.globl vector197
vector197:
  pushl $0
80106fca:	6a 00                	push   $0x0
  pushl $197
80106fcc:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106fd1:	e9 aa f1 ff ff       	jmp    80106180 <alltraps>

80106fd6 <vector198>:
.globl vector198
vector198:
  pushl $0
80106fd6:	6a 00                	push   $0x0
  pushl $198
80106fd8:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106fdd:	e9 9e f1 ff ff       	jmp    80106180 <alltraps>

80106fe2 <vector199>:
.globl vector199
vector199:
  pushl $0
80106fe2:	6a 00                	push   $0x0
  pushl $199
80106fe4:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106fe9:	e9 92 f1 ff ff       	jmp    80106180 <alltraps>

80106fee <vector200>:
.globl vector200
vector200:
  pushl $0
80106fee:	6a 00                	push   $0x0
  pushl $200
80106ff0:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106ff5:	e9 86 f1 ff ff       	jmp    80106180 <alltraps>

80106ffa <vector201>:
.globl vector201
vector201:
  pushl $0
80106ffa:	6a 00                	push   $0x0
  pushl $201
80106ffc:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107001:	e9 7a f1 ff ff       	jmp    80106180 <alltraps>

80107006 <vector202>:
.globl vector202
vector202:
  pushl $0
80107006:	6a 00                	push   $0x0
  pushl $202
80107008:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010700d:	e9 6e f1 ff ff       	jmp    80106180 <alltraps>

80107012 <vector203>:
.globl vector203
vector203:
  pushl $0
80107012:	6a 00                	push   $0x0
  pushl $203
80107014:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107019:	e9 62 f1 ff ff       	jmp    80106180 <alltraps>

8010701e <vector204>:
.globl vector204
vector204:
  pushl $0
8010701e:	6a 00                	push   $0x0
  pushl $204
80107020:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107025:	e9 56 f1 ff ff       	jmp    80106180 <alltraps>

8010702a <vector205>:
.globl vector205
vector205:
  pushl $0
8010702a:	6a 00                	push   $0x0
  pushl $205
8010702c:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107031:	e9 4a f1 ff ff       	jmp    80106180 <alltraps>

80107036 <vector206>:
.globl vector206
vector206:
  pushl $0
80107036:	6a 00                	push   $0x0
  pushl $206
80107038:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010703d:	e9 3e f1 ff ff       	jmp    80106180 <alltraps>

80107042 <vector207>:
.globl vector207
vector207:
  pushl $0
80107042:	6a 00                	push   $0x0
  pushl $207
80107044:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107049:	e9 32 f1 ff ff       	jmp    80106180 <alltraps>

8010704e <vector208>:
.globl vector208
vector208:
  pushl $0
8010704e:	6a 00                	push   $0x0
  pushl $208
80107050:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107055:	e9 26 f1 ff ff       	jmp    80106180 <alltraps>

8010705a <vector209>:
.globl vector209
vector209:
  pushl $0
8010705a:	6a 00                	push   $0x0
  pushl $209
8010705c:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107061:	e9 1a f1 ff ff       	jmp    80106180 <alltraps>

80107066 <vector210>:
.globl vector210
vector210:
  pushl $0
80107066:	6a 00                	push   $0x0
  pushl $210
80107068:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010706d:	e9 0e f1 ff ff       	jmp    80106180 <alltraps>

80107072 <vector211>:
.globl vector211
vector211:
  pushl $0
80107072:	6a 00                	push   $0x0
  pushl $211
80107074:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107079:	e9 02 f1 ff ff       	jmp    80106180 <alltraps>

8010707e <vector212>:
.globl vector212
vector212:
  pushl $0
8010707e:	6a 00                	push   $0x0
  pushl $212
80107080:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107085:	e9 f6 f0 ff ff       	jmp    80106180 <alltraps>

8010708a <vector213>:
.globl vector213
vector213:
  pushl $0
8010708a:	6a 00                	push   $0x0
  pushl $213
8010708c:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107091:	e9 ea f0 ff ff       	jmp    80106180 <alltraps>

80107096 <vector214>:
.globl vector214
vector214:
  pushl $0
80107096:	6a 00                	push   $0x0
  pushl $214
80107098:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010709d:	e9 de f0 ff ff       	jmp    80106180 <alltraps>

801070a2 <vector215>:
.globl vector215
vector215:
  pushl $0
801070a2:	6a 00                	push   $0x0
  pushl $215
801070a4:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801070a9:	e9 d2 f0 ff ff       	jmp    80106180 <alltraps>

801070ae <vector216>:
.globl vector216
vector216:
  pushl $0
801070ae:	6a 00                	push   $0x0
  pushl $216
801070b0:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801070b5:	e9 c6 f0 ff ff       	jmp    80106180 <alltraps>

801070ba <vector217>:
.globl vector217
vector217:
  pushl $0
801070ba:	6a 00                	push   $0x0
  pushl $217
801070bc:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801070c1:	e9 ba f0 ff ff       	jmp    80106180 <alltraps>

801070c6 <vector218>:
.globl vector218
vector218:
  pushl $0
801070c6:	6a 00                	push   $0x0
  pushl $218
801070c8:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801070cd:	e9 ae f0 ff ff       	jmp    80106180 <alltraps>

801070d2 <vector219>:
.globl vector219
vector219:
  pushl $0
801070d2:	6a 00                	push   $0x0
  pushl $219
801070d4:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801070d9:	e9 a2 f0 ff ff       	jmp    80106180 <alltraps>

801070de <vector220>:
.globl vector220
vector220:
  pushl $0
801070de:	6a 00                	push   $0x0
  pushl $220
801070e0:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801070e5:	e9 96 f0 ff ff       	jmp    80106180 <alltraps>

801070ea <vector221>:
.globl vector221
vector221:
  pushl $0
801070ea:	6a 00                	push   $0x0
  pushl $221
801070ec:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801070f1:	e9 8a f0 ff ff       	jmp    80106180 <alltraps>

801070f6 <vector222>:
.globl vector222
vector222:
  pushl $0
801070f6:	6a 00                	push   $0x0
  pushl $222
801070f8:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801070fd:	e9 7e f0 ff ff       	jmp    80106180 <alltraps>

80107102 <vector223>:
.globl vector223
vector223:
  pushl $0
80107102:	6a 00                	push   $0x0
  pushl $223
80107104:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107109:	e9 72 f0 ff ff       	jmp    80106180 <alltraps>

8010710e <vector224>:
.globl vector224
vector224:
  pushl $0
8010710e:	6a 00                	push   $0x0
  pushl $224
80107110:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107115:	e9 66 f0 ff ff       	jmp    80106180 <alltraps>

8010711a <vector225>:
.globl vector225
vector225:
  pushl $0
8010711a:	6a 00                	push   $0x0
  pushl $225
8010711c:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107121:	e9 5a f0 ff ff       	jmp    80106180 <alltraps>

80107126 <vector226>:
.globl vector226
vector226:
  pushl $0
80107126:	6a 00                	push   $0x0
  pushl $226
80107128:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010712d:	e9 4e f0 ff ff       	jmp    80106180 <alltraps>

80107132 <vector227>:
.globl vector227
vector227:
  pushl $0
80107132:	6a 00                	push   $0x0
  pushl $227
80107134:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107139:	e9 42 f0 ff ff       	jmp    80106180 <alltraps>

8010713e <vector228>:
.globl vector228
vector228:
  pushl $0
8010713e:	6a 00                	push   $0x0
  pushl $228
80107140:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107145:	e9 36 f0 ff ff       	jmp    80106180 <alltraps>

8010714a <vector229>:
.globl vector229
vector229:
  pushl $0
8010714a:	6a 00                	push   $0x0
  pushl $229
8010714c:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107151:	e9 2a f0 ff ff       	jmp    80106180 <alltraps>

80107156 <vector230>:
.globl vector230
vector230:
  pushl $0
80107156:	6a 00                	push   $0x0
  pushl $230
80107158:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010715d:	e9 1e f0 ff ff       	jmp    80106180 <alltraps>

80107162 <vector231>:
.globl vector231
vector231:
  pushl $0
80107162:	6a 00                	push   $0x0
  pushl $231
80107164:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107169:	e9 12 f0 ff ff       	jmp    80106180 <alltraps>

8010716e <vector232>:
.globl vector232
vector232:
  pushl $0
8010716e:	6a 00                	push   $0x0
  pushl $232
80107170:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107175:	e9 06 f0 ff ff       	jmp    80106180 <alltraps>

8010717a <vector233>:
.globl vector233
vector233:
  pushl $0
8010717a:	6a 00                	push   $0x0
  pushl $233
8010717c:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107181:	e9 fa ef ff ff       	jmp    80106180 <alltraps>

80107186 <vector234>:
.globl vector234
vector234:
  pushl $0
80107186:	6a 00                	push   $0x0
  pushl $234
80107188:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010718d:	e9 ee ef ff ff       	jmp    80106180 <alltraps>

80107192 <vector235>:
.globl vector235
vector235:
  pushl $0
80107192:	6a 00                	push   $0x0
  pushl $235
80107194:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107199:	e9 e2 ef ff ff       	jmp    80106180 <alltraps>

8010719e <vector236>:
.globl vector236
vector236:
  pushl $0
8010719e:	6a 00                	push   $0x0
  pushl $236
801071a0:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801071a5:	e9 d6 ef ff ff       	jmp    80106180 <alltraps>

801071aa <vector237>:
.globl vector237
vector237:
  pushl $0
801071aa:	6a 00                	push   $0x0
  pushl $237
801071ac:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801071b1:	e9 ca ef ff ff       	jmp    80106180 <alltraps>

801071b6 <vector238>:
.globl vector238
vector238:
  pushl $0
801071b6:	6a 00                	push   $0x0
  pushl $238
801071b8:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801071bd:	e9 be ef ff ff       	jmp    80106180 <alltraps>

801071c2 <vector239>:
.globl vector239
vector239:
  pushl $0
801071c2:	6a 00                	push   $0x0
  pushl $239
801071c4:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801071c9:	e9 b2 ef ff ff       	jmp    80106180 <alltraps>

801071ce <vector240>:
.globl vector240
vector240:
  pushl $0
801071ce:	6a 00                	push   $0x0
  pushl $240
801071d0:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801071d5:	e9 a6 ef ff ff       	jmp    80106180 <alltraps>

801071da <vector241>:
.globl vector241
vector241:
  pushl $0
801071da:	6a 00                	push   $0x0
  pushl $241
801071dc:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801071e1:	e9 9a ef ff ff       	jmp    80106180 <alltraps>

801071e6 <vector242>:
.globl vector242
vector242:
  pushl $0
801071e6:	6a 00                	push   $0x0
  pushl $242
801071e8:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801071ed:	e9 8e ef ff ff       	jmp    80106180 <alltraps>

801071f2 <vector243>:
.globl vector243
vector243:
  pushl $0
801071f2:	6a 00                	push   $0x0
  pushl $243
801071f4:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801071f9:	e9 82 ef ff ff       	jmp    80106180 <alltraps>

801071fe <vector244>:
.globl vector244
vector244:
  pushl $0
801071fe:	6a 00                	push   $0x0
  pushl $244
80107200:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107205:	e9 76 ef ff ff       	jmp    80106180 <alltraps>

8010720a <vector245>:
.globl vector245
vector245:
  pushl $0
8010720a:	6a 00                	push   $0x0
  pushl $245
8010720c:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107211:	e9 6a ef ff ff       	jmp    80106180 <alltraps>

80107216 <vector246>:
.globl vector246
vector246:
  pushl $0
80107216:	6a 00                	push   $0x0
  pushl $246
80107218:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010721d:	e9 5e ef ff ff       	jmp    80106180 <alltraps>

80107222 <vector247>:
.globl vector247
vector247:
  pushl $0
80107222:	6a 00                	push   $0x0
  pushl $247
80107224:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107229:	e9 52 ef ff ff       	jmp    80106180 <alltraps>

8010722e <vector248>:
.globl vector248
vector248:
  pushl $0
8010722e:	6a 00                	push   $0x0
  pushl $248
80107230:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107235:	e9 46 ef ff ff       	jmp    80106180 <alltraps>

8010723a <vector249>:
.globl vector249
vector249:
  pushl $0
8010723a:	6a 00                	push   $0x0
  pushl $249
8010723c:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107241:	e9 3a ef ff ff       	jmp    80106180 <alltraps>

80107246 <vector250>:
.globl vector250
vector250:
  pushl $0
80107246:	6a 00                	push   $0x0
  pushl $250
80107248:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010724d:	e9 2e ef ff ff       	jmp    80106180 <alltraps>

80107252 <vector251>:
.globl vector251
vector251:
  pushl $0
80107252:	6a 00                	push   $0x0
  pushl $251
80107254:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107259:	e9 22 ef ff ff       	jmp    80106180 <alltraps>

8010725e <vector252>:
.globl vector252
vector252:
  pushl $0
8010725e:	6a 00                	push   $0x0
  pushl $252
80107260:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107265:	e9 16 ef ff ff       	jmp    80106180 <alltraps>

8010726a <vector253>:
.globl vector253
vector253:
  pushl $0
8010726a:	6a 00                	push   $0x0
  pushl $253
8010726c:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107271:	e9 0a ef ff ff       	jmp    80106180 <alltraps>

80107276 <vector254>:
.globl vector254
vector254:
  pushl $0
80107276:	6a 00                	push   $0x0
  pushl $254
80107278:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010727d:	e9 fe ee ff ff       	jmp    80106180 <alltraps>

80107282 <vector255>:
.globl vector255
vector255:
  pushl $0
80107282:	6a 00                	push   $0x0
  pushl $255
80107284:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107289:	e9 f2 ee ff ff       	jmp    80106180 <alltraps>
8010728e:	66 90                	xchg   %ax,%ax

80107290 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107290:	55                   	push   %ebp
80107291:	89 e5                	mov    %esp,%ebp
80107293:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107296:	8b 45 0c             	mov    0xc(%ebp),%eax
80107299:	83 e8 01             	sub    $0x1,%eax
8010729c:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801072a0:	8b 45 08             	mov    0x8(%ebp),%eax
801072a3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801072a7:	8b 45 08             	mov    0x8(%ebp),%eax
801072aa:	c1 e8 10             	shr    $0x10,%eax
801072ad:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801072b1:	8d 45 fa             	lea    -0x6(%ebp),%eax
801072b4:	0f 01 10             	lgdtl  (%eax)
}
801072b7:	c9                   	leave  
801072b8:	c3                   	ret    

801072b9 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801072b9:	55                   	push   %ebp
801072ba:	89 e5                	mov    %esp,%ebp
801072bc:	83 ec 04             	sub    $0x4,%esp
801072bf:	8b 45 08             	mov    0x8(%ebp),%eax
801072c2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801072c6:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801072ca:	0f 00 d8             	ltr    %ax
}
801072cd:	c9                   	leave  
801072ce:	c3                   	ret    

801072cf <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801072cf:	55                   	push   %ebp
801072d0:	89 e5                	mov    %esp,%ebp
801072d2:	83 ec 04             	sub    $0x4,%esp
801072d5:	8b 45 08             	mov    0x8(%ebp),%eax
801072d8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801072dc:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801072e0:	8e e8                	mov    %eax,%gs
}
801072e2:	c9                   	leave  
801072e3:	c3                   	ret    

801072e4 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801072e4:	55                   	push   %ebp
801072e5:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801072e7:	8b 45 08             	mov    0x8(%ebp),%eax
801072ea:	0f 22 d8             	mov    %eax,%cr3
}
801072ed:	5d                   	pop    %ebp
801072ee:	c3                   	ret    

801072ef <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801072ef:	55                   	push   %ebp
801072f0:	89 e5                	mov    %esp,%ebp
801072f2:	8b 45 08             	mov    0x8(%ebp),%eax
801072f5:	05 00 00 00 80       	add    $0x80000000,%eax
801072fa:	5d                   	pop    %ebp
801072fb:	c3                   	ret    

801072fc <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801072fc:	55                   	push   %ebp
801072fd:	89 e5                	mov    %esp,%ebp
801072ff:	8b 45 08             	mov    0x8(%ebp),%eax
80107302:	05 00 00 00 80       	add    $0x80000000,%eax
80107307:	5d                   	pop    %ebp
80107308:	c3                   	ret    

80107309 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107309:	55                   	push   %ebp
8010730a:	89 e5                	mov    %esp,%ebp
8010730c:	53                   	push   %ebx
8010730d:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107310:	e8 c0 bb ff ff       	call   80102ed5 <cpunum>
80107315:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010731b:	05 20 f9 10 80       	add    $0x8010f920,%eax
80107320:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107323:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107326:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010732c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010732f:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107335:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107338:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010733c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010733f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107343:	83 e2 f0             	and    $0xfffffff0,%edx
80107346:	83 ca 0a             	or     $0xa,%edx
80107349:	88 50 7d             	mov    %dl,0x7d(%eax)
8010734c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010734f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107353:	83 ca 10             	or     $0x10,%edx
80107356:	88 50 7d             	mov    %dl,0x7d(%eax)
80107359:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010735c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107360:	83 e2 9f             	and    $0xffffff9f,%edx
80107363:	88 50 7d             	mov    %dl,0x7d(%eax)
80107366:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107369:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010736d:	83 ca 80             	or     $0xffffff80,%edx
80107370:	88 50 7d             	mov    %dl,0x7d(%eax)
80107373:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107376:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010737a:	83 ca 0f             	or     $0xf,%edx
8010737d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107380:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107383:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107387:	83 e2 ef             	and    $0xffffffef,%edx
8010738a:	88 50 7e             	mov    %dl,0x7e(%eax)
8010738d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107390:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107394:	83 e2 df             	and    $0xffffffdf,%edx
80107397:	88 50 7e             	mov    %dl,0x7e(%eax)
8010739a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010739d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073a1:	83 ca 40             	or     $0x40,%edx
801073a4:	88 50 7e             	mov    %dl,0x7e(%eax)
801073a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073aa:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073ae:	83 ca 80             	or     $0xffffff80,%edx
801073b1:	88 50 7e             	mov    %dl,0x7e(%eax)
801073b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073b7:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801073bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073be:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801073c5:	ff ff 
801073c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073ca:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801073d1:	00 00 
801073d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073d6:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801073dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073e0:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801073e7:	83 e2 f0             	and    $0xfffffff0,%edx
801073ea:	83 ca 02             	or     $0x2,%edx
801073ed:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801073f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073f6:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801073fd:	83 ca 10             	or     $0x10,%edx
80107400:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107406:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107409:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107410:	83 e2 9f             	and    $0xffffff9f,%edx
80107413:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107419:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010741c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107423:	83 ca 80             	or     $0xffffff80,%edx
80107426:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010742c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010742f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107436:	83 ca 0f             	or     $0xf,%edx
80107439:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010743f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107442:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107449:	83 e2 ef             	and    $0xffffffef,%edx
8010744c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107452:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107455:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010745c:	83 e2 df             	and    $0xffffffdf,%edx
8010745f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107465:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107468:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010746f:	83 ca 40             	or     $0x40,%edx
80107472:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107478:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010747b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107482:	83 ca 80             	or     $0xffffff80,%edx
80107485:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010748b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010748e:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107495:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107498:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010749f:	ff ff 
801074a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074a4:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801074ab:	00 00 
801074ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074b0:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801074b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ba:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801074c1:	83 e2 f0             	and    $0xfffffff0,%edx
801074c4:	83 ca 0a             	or     $0xa,%edx
801074c7:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801074cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074d0:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801074d7:	83 ca 10             	or     $0x10,%edx
801074da:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801074e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074e3:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801074ea:	83 ca 60             	or     $0x60,%edx
801074ed:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801074f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074f6:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801074fd:	83 ca 80             	or     $0xffffff80,%edx
80107500:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107506:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107509:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107510:	83 ca 0f             	or     $0xf,%edx
80107513:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107519:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010751c:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107523:	83 e2 ef             	and    $0xffffffef,%edx
80107526:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010752c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010752f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107536:	83 e2 df             	and    $0xffffffdf,%edx
80107539:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010753f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107542:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107549:	83 ca 40             	or     $0x40,%edx
8010754c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107552:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107555:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010755c:	83 ca 80             	or     $0xffffff80,%edx
8010755f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107565:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107568:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010756f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107572:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107579:	ff ff 
8010757b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010757e:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107585:	00 00 
80107587:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010758a:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107591:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107594:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010759b:	83 e2 f0             	and    $0xfffffff0,%edx
8010759e:	83 ca 02             	or     $0x2,%edx
801075a1:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801075a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075aa:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801075b1:	83 ca 10             	or     $0x10,%edx
801075b4:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801075ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075bd:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801075c4:	83 ca 60             	or     $0x60,%edx
801075c7:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801075cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075d0:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801075d7:	83 ca 80             	or     $0xffffff80,%edx
801075da:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801075e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e3:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801075ea:	83 ca 0f             	or     $0xf,%edx
801075ed:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801075f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f6:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801075fd:	83 e2 ef             	and    $0xffffffef,%edx
80107600:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107606:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107609:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107610:	83 e2 df             	and    $0xffffffdf,%edx
80107613:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107619:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010761c:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107623:	83 ca 40             	or     $0x40,%edx
80107626:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010762c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010762f:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107636:	83 ca 80             	or     $0xffffff80,%edx
80107639:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010763f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107642:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107649:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010764c:	05 b4 00 00 00       	add    $0xb4,%eax
80107651:	89 c3                	mov    %eax,%ebx
80107653:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107656:	05 b4 00 00 00       	add    $0xb4,%eax
8010765b:	c1 e8 10             	shr    $0x10,%eax
8010765e:	89 c1                	mov    %eax,%ecx
80107660:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107663:	05 b4 00 00 00       	add    $0xb4,%eax
80107668:	c1 e8 18             	shr    $0x18,%eax
8010766b:	89 c2                	mov    %eax,%edx
8010766d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107670:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107677:	00 00 
80107679:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010767c:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107683:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107686:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
8010768c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010768f:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107696:	83 e1 f0             	and    $0xfffffff0,%ecx
80107699:	83 c9 02             	or     $0x2,%ecx
8010769c:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801076a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076a5:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801076ac:	83 c9 10             	or     $0x10,%ecx
801076af:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801076b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076b8:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801076bf:	83 e1 9f             	and    $0xffffff9f,%ecx
801076c2:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801076c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076cb:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801076d2:	83 c9 80             	or     $0xffffff80,%ecx
801076d5:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801076db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076de:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
801076e5:	83 e1 f0             	and    $0xfffffff0,%ecx
801076e8:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801076ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076f1:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
801076f8:	83 e1 ef             	and    $0xffffffef,%ecx
801076fb:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107701:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107704:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
8010770b:	83 e1 df             	and    $0xffffffdf,%ecx
8010770e:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107714:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107717:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
8010771e:	83 c9 40             	or     $0x40,%ecx
80107721:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010772a:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107731:	83 c9 80             	or     $0xffffff80,%ecx
80107734:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
8010773a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010773d:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107743:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107746:	83 c0 70             	add    $0x70,%eax
80107749:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107750:	00 
80107751:	89 04 24             	mov    %eax,(%esp)
80107754:	e8 37 fb ff ff       	call   80107290 <lgdt>
  loadgs(SEG_KCPU << 3);
80107759:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107760:	e8 6a fb ff ff       	call   801072cf <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107765:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107768:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
8010776e:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107775:	00 00 00 00 
}
80107779:	83 c4 24             	add    $0x24,%esp
8010777c:	5b                   	pop    %ebx
8010777d:	5d                   	pop    %ebp
8010777e:	c3                   	ret    

8010777f <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010777f:	55                   	push   %ebp
80107780:	89 e5                	mov    %esp,%ebp
80107782:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107785:	8b 45 0c             	mov    0xc(%ebp),%eax
80107788:	c1 e8 16             	shr    $0x16,%eax
8010778b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107792:	8b 45 08             	mov    0x8(%ebp),%eax
80107795:	01 d0                	add    %edx,%eax
80107797:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
8010779a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010779d:	8b 00                	mov    (%eax),%eax
8010779f:	83 e0 01             	and    $0x1,%eax
801077a2:	85 c0                	test   %eax,%eax
801077a4:	74 17                	je     801077bd <walkpgdir+0x3e>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
801077a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801077a9:	8b 00                	mov    (%eax),%eax
801077ab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801077b0:	89 04 24             	mov    %eax,(%esp)
801077b3:	e8 44 fb ff ff       	call   801072fc <p2v>
801077b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801077bb:	eb 4b                	jmp    80107808 <walkpgdir+0x89>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801077bd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801077c1:	74 0e                	je     801077d1 <walkpgdir+0x52>
801077c3:	e8 7b b3 ff ff       	call   80102b43 <kalloc>
801077c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801077cb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801077cf:	75 07                	jne    801077d8 <walkpgdir+0x59>
      return 0;
801077d1:	b8 00 00 00 00       	mov    $0x0,%eax
801077d6:	eb 47                	jmp    8010781f <walkpgdir+0xa0>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801077d8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801077df:	00 
801077e0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801077e7:	00 
801077e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077eb:	89 04 24             	mov    %eax,(%esp)
801077ee:	e8 ab d5 ff ff       	call   80104d9e <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
801077f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f6:	89 04 24             	mov    %eax,(%esp)
801077f9:	e8 f1 fa ff ff       	call   801072ef <v2p>
801077fe:	89 c2                	mov    %eax,%edx
80107800:	83 ca 07             	or     $0x7,%edx
80107803:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107806:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107808:	8b 45 0c             	mov    0xc(%ebp),%eax
8010780b:	c1 e8 0c             	shr    $0xc,%eax
8010780e:	25 ff 03 00 00       	and    $0x3ff,%eax
80107813:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010781a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010781d:	01 d0                	add    %edx,%eax
}
8010781f:	c9                   	leave  
80107820:	c3                   	ret    

80107821 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107821:	55                   	push   %ebp
80107822:	89 e5                	mov    %esp,%ebp
80107824:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107827:	8b 45 0c             	mov    0xc(%ebp),%eax
8010782a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010782f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107832:	8b 55 0c             	mov    0xc(%ebp),%edx
80107835:	8b 45 10             	mov    0x10(%ebp),%eax
80107838:	01 d0                	add    %edx,%eax
8010783a:	83 e8 01             	sub    $0x1,%eax
8010783d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107842:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107845:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
8010784c:	00 
8010784d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107850:	89 44 24 04          	mov    %eax,0x4(%esp)
80107854:	8b 45 08             	mov    0x8(%ebp),%eax
80107857:	89 04 24             	mov    %eax,(%esp)
8010785a:	e8 20 ff ff ff       	call   8010777f <walkpgdir>
8010785f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107862:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107866:	75 07                	jne    8010786f <mappages+0x4e>
      return -1;
80107868:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010786d:	eb 46                	jmp    801078b5 <mappages+0x94>
    if(*pte & PTE_P)
8010786f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107872:	8b 00                	mov    (%eax),%eax
80107874:	83 e0 01             	and    $0x1,%eax
80107877:	85 c0                	test   %eax,%eax
80107879:	74 0c                	je     80107887 <mappages+0x66>
      panic("remap");
8010787b:	c7 04 24 88 87 10 80 	movl   $0x80108788,(%esp)
80107882:	e8 bf 8c ff ff       	call   80100546 <panic>
    *pte = pa | perm | PTE_P;
80107887:	8b 45 18             	mov    0x18(%ebp),%eax
8010788a:	0b 45 14             	or     0x14(%ebp),%eax
8010788d:	89 c2                	mov    %eax,%edx
8010788f:	83 ca 01             	or     $0x1,%edx
80107892:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107895:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107897:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010789a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010789d:	74 10                	je     801078af <mappages+0x8e>
      break;
    a += PGSIZE;
8010789f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801078a6:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
801078ad:	eb 96                	jmp    80107845 <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
801078af:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
801078b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801078b5:	c9                   	leave  
801078b6:	c3                   	ret    

801078b7 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801078b7:	55                   	push   %ebp
801078b8:	89 e5                	mov    %esp,%ebp
801078ba:	53                   	push   %ebx
801078bb:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801078be:	e8 80 b2 ff ff       	call   80102b43 <kalloc>
801078c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801078c6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801078ca:	75 0a                	jne    801078d6 <setupkvm+0x1f>
    return 0;
801078cc:	b8 00 00 00 00       	mov    $0x0,%eax
801078d1:	e9 98 00 00 00       	jmp    8010796e <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
801078d6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801078dd:	00 
801078de:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801078e5:	00 
801078e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078e9:	89 04 24             	mov    %eax,(%esp)
801078ec:	e8 ad d4 ff ff       	call   80104d9e <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
801078f1:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
801078f8:	e8 ff f9 ff ff       	call   801072fc <p2v>
801078fd:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80107902:	76 0c                	jbe    80107910 <setupkvm+0x59>
    panic("PHYSTOP too high");
80107904:	c7 04 24 8e 87 10 80 	movl   $0x8010878e,(%esp)
8010790b:	e8 36 8c ff ff       	call   80100546 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107910:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
80107917:	eb 49                	jmp    80107962 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
80107919:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
8010791c:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
8010791f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107922:	8b 50 04             	mov    0x4(%eax),%edx
80107925:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107928:	8b 58 08             	mov    0x8(%eax),%ebx
8010792b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010792e:	8b 40 04             	mov    0x4(%eax),%eax
80107931:	29 c3                	sub    %eax,%ebx
80107933:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107936:	8b 00                	mov    (%eax),%eax
80107938:	89 4c 24 10          	mov    %ecx,0x10(%esp)
8010793c:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107940:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107944:	89 44 24 04          	mov    %eax,0x4(%esp)
80107948:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010794b:	89 04 24             	mov    %eax,(%esp)
8010794e:	e8 ce fe ff ff       	call   80107821 <mappages>
80107953:	85 c0                	test   %eax,%eax
80107955:	79 07                	jns    8010795e <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80107957:	b8 00 00 00 00       	mov    $0x0,%eax
8010795c:	eb 10                	jmp    8010796e <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010795e:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107962:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
80107969:	72 ae                	jb     80107919 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
8010796b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010796e:	83 c4 34             	add    $0x34,%esp
80107971:	5b                   	pop    %ebx
80107972:	5d                   	pop    %ebp
80107973:	c3                   	ret    

80107974 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107974:	55                   	push   %ebp
80107975:	89 e5                	mov    %esp,%ebp
80107977:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010797a:	e8 38 ff ff ff       	call   801078b7 <setupkvm>
8010797f:	a3 f8 26 11 80       	mov    %eax,0x801126f8
  switchkvm();
80107984:	e8 02 00 00 00       	call   8010798b <switchkvm>
}
80107989:	c9                   	leave  
8010798a:	c3                   	ret    

8010798b <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010798b:	55                   	push   %ebp
8010798c:	89 e5                	mov    %esp,%ebp
8010798e:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80107991:	a1 f8 26 11 80       	mov    0x801126f8,%eax
80107996:	89 04 24             	mov    %eax,(%esp)
80107999:	e8 51 f9 ff ff       	call   801072ef <v2p>
8010799e:	89 04 24             	mov    %eax,(%esp)
801079a1:	e8 3e f9 ff ff       	call   801072e4 <lcr3>
}
801079a6:	c9                   	leave  
801079a7:	c3                   	ret    

801079a8 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801079a8:	55                   	push   %ebp
801079a9:	89 e5                	mov    %esp,%ebp
801079ab:	53                   	push   %ebx
801079ac:	83 ec 14             	sub    $0x14,%esp
  pushcli();
801079af:	e8 e3 d2 ff ff       	call   80104c97 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
801079b4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801079ba:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801079c1:	83 c2 08             	add    $0x8,%edx
801079c4:	89 d3                	mov    %edx,%ebx
801079c6:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801079cd:	83 c2 08             	add    $0x8,%edx
801079d0:	c1 ea 10             	shr    $0x10,%edx
801079d3:	89 d1                	mov    %edx,%ecx
801079d5:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801079dc:	83 c2 08             	add    $0x8,%edx
801079df:	c1 ea 18             	shr    $0x18,%edx
801079e2:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
801079e9:	67 00 
801079eb:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
801079f2:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
801079f8:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801079ff:	83 e1 f0             	and    $0xfffffff0,%ecx
80107a02:	83 c9 09             	or     $0x9,%ecx
80107a05:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107a0b:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107a12:	83 c9 10             	or     $0x10,%ecx
80107a15:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107a1b:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107a22:	83 e1 9f             	and    $0xffffff9f,%ecx
80107a25:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107a2b:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107a32:	83 c9 80             	or     $0xffffff80,%ecx
80107a35:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107a3b:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107a42:	83 e1 f0             	and    $0xfffffff0,%ecx
80107a45:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107a4b:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107a52:	83 e1 ef             	and    $0xffffffef,%ecx
80107a55:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107a5b:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107a62:	83 e1 df             	and    $0xffffffdf,%ecx
80107a65:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107a6b:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107a72:	83 c9 40             	or     $0x40,%ecx
80107a75:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107a7b:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107a82:	83 e1 7f             	and    $0x7f,%ecx
80107a85:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107a8b:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80107a91:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107a97:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107a9e:	83 e2 ef             	and    $0xffffffef,%edx
80107aa1:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80107aa7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107aad:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80107ab3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107ab9:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80107ac0:	8b 52 08             	mov    0x8(%edx),%edx
80107ac3:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107ac9:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80107acc:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80107ad3:	e8 e1 f7 ff ff       	call   801072b9 <ltr>
  if(p->pgdir == 0)
80107ad8:	8b 45 08             	mov    0x8(%ebp),%eax
80107adb:	8b 40 04             	mov    0x4(%eax),%eax
80107ade:	85 c0                	test   %eax,%eax
80107ae0:	75 0c                	jne    80107aee <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80107ae2:	c7 04 24 9f 87 10 80 	movl   $0x8010879f,(%esp)
80107ae9:	e8 58 8a ff ff       	call   80100546 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80107aee:	8b 45 08             	mov    0x8(%ebp),%eax
80107af1:	8b 40 04             	mov    0x4(%eax),%eax
80107af4:	89 04 24             	mov    %eax,(%esp)
80107af7:	e8 f3 f7 ff ff       	call   801072ef <v2p>
80107afc:	89 04 24             	mov    %eax,(%esp)
80107aff:	e8 e0 f7 ff ff       	call   801072e4 <lcr3>
  popcli();
80107b04:	e8 d6 d1 ff ff       	call   80104cdf <popcli>
}
80107b09:	83 c4 14             	add    $0x14,%esp
80107b0c:	5b                   	pop    %ebx
80107b0d:	5d                   	pop    %ebp
80107b0e:	c3                   	ret    

80107b0f <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107b0f:	55                   	push   %ebp
80107b10:	89 e5                	mov    %esp,%ebp
80107b12:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80107b15:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107b1c:	76 0c                	jbe    80107b2a <inituvm+0x1b>
    panic("inituvm: more than a page");
80107b1e:	c7 04 24 b3 87 10 80 	movl   $0x801087b3,(%esp)
80107b25:	e8 1c 8a ff ff       	call   80100546 <panic>
  mem = kalloc();
80107b2a:	e8 14 b0 ff ff       	call   80102b43 <kalloc>
80107b2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107b32:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107b39:	00 
80107b3a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107b41:	00 
80107b42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b45:	89 04 24             	mov    %eax,(%esp)
80107b48:	e8 51 d2 ff ff       	call   80104d9e <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80107b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b50:	89 04 24             	mov    %eax,(%esp)
80107b53:	e8 97 f7 ff ff       	call   801072ef <v2p>
80107b58:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80107b5f:	00 
80107b60:	89 44 24 0c          	mov    %eax,0xc(%esp)
80107b64:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107b6b:	00 
80107b6c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107b73:	00 
80107b74:	8b 45 08             	mov    0x8(%ebp),%eax
80107b77:	89 04 24             	mov    %eax,(%esp)
80107b7a:	e8 a2 fc ff ff       	call   80107821 <mappages>
  memmove(mem, init, sz);
80107b7f:	8b 45 10             	mov    0x10(%ebp),%eax
80107b82:	89 44 24 08          	mov    %eax,0x8(%esp)
80107b86:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b89:	89 44 24 04          	mov    %eax,0x4(%esp)
80107b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b90:	89 04 24             	mov    %eax,(%esp)
80107b93:	e8 d9 d2 ff ff       	call   80104e71 <memmove>
}
80107b98:	c9                   	leave  
80107b99:	c3                   	ret    

80107b9a <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107b9a:	55                   	push   %ebp
80107b9b:	89 e5                	mov    %esp,%ebp
80107b9d:	53                   	push   %ebx
80107b9e:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107ba1:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ba4:	25 ff 0f 00 00       	and    $0xfff,%eax
80107ba9:	85 c0                	test   %eax,%eax
80107bab:	74 0c                	je     80107bb9 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107bad:	c7 04 24 d0 87 10 80 	movl   $0x801087d0,(%esp)
80107bb4:	e8 8d 89 ff ff       	call   80100546 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107bb9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107bc0:	e9 ad 00 00 00       	jmp    80107c72 <loaduvm+0xd8>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc8:	8b 55 0c             	mov    0xc(%ebp),%edx
80107bcb:	01 d0                	add    %edx,%eax
80107bcd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107bd4:	00 
80107bd5:	89 44 24 04          	mov    %eax,0x4(%esp)
80107bd9:	8b 45 08             	mov    0x8(%ebp),%eax
80107bdc:	89 04 24             	mov    %eax,(%esp)
80107bdf:	e8 9b fb ff ff       	call   8010777f <walkpgdir>
80107be4:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107be7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107beb:	75 0c                	jne    80107bf9 <loaduvm+0x5f>
      panic("loaduvm: address should exist");
80107bed:	c7 04 24 f3 87 10 80 	movl   $0x801087f3,(%esp)
80107bf4:	e8 4d 89 ff ff       	call   80100546 <panic>
    pa = PTE_ADDR(*pte);
80107bf9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107bfc:	8b 00                	mov    (%eax),%eax
80107bfe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c03:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107c06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c09:	8b 55 18             	mov    0x18(%ebp),%edx
80107c0c:	89 d1                	mov    %edx,%ecx
80107c0e:	29 c1                	sub    %eax,%ecx
80107c10:	89 c8                	mov    %ecx,%eax
80107c12:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107c17:	77 11                	ja     80107c2a <loaduvm+0x90>
      n = sz - i;
80107c19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c1c:	8b 55 18             	mov    0x18(%ebp),%edx
80107c1f:	89 d1                	mov    %edx,%ecx
80107c21:	29 c1                	sub    %eax,%ecx
80107c23:	89 c8                	mov    %ecx,%eax
80107c25:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107c28:	eb 07                	jmp    80107c31 <loaduvm+0x97>
    else
      n = PGSIZE;
80107c2a:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80107c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c34:	8b 55 14             	mov    0x14(%ebp),%edx
80107c37:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80107c3a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107c3d:	89 04 24             	mov    %eax,(%esp)
80107c40:	e8 b7 f6 ff ff       	call   801072fc <p2v>
80107c45:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107c48:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107c4c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107c50:	89 44 24 04          	mov    %eax,0x4(%esp)
80107c54:	8b 45 10             	mov    0x10(%ebp),%eax
80107c57:	89 04 24             	mov    %eax,(%esp)
80107c5a:	e8 3a a1 ff ff       	call   80101d99 <readi>
80107c5f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107c62:	74 07                	je     80107c6b <loaduvm+0xd1>
      return -1;
80107c64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c69:	eb 18                	jmp    80107c83 <loaduvm+0xe9>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80107c6b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c75:	3b 45 18             	cmp    0x18(%ebp),%eax
80107c78:	0f 82 47 ff ff ff    	jb     80107bc5 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80107c7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107c83:	83 c4 24             	add    $0x24,%esp
80107c86:	5b                   	pop    %ebx
80107c87:	5d                   	pop    %ebp
80107c88:	c3                   	ret    

80107c89 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107c89:	55                   	push   %ebp
80107c8a:	89 e5                	mov    %esp,%ebp
80107c8c:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107c8f:	8b 45 10             	mov    0x10(%ebp),%eax
80107c92:	85 c0                	test   %eax,%eax
80107c94:	79 0a                	jns    80107ca0 <allocuvm+0x17>
    return 0;
80107c96:	b8 00 00 00 00       	mov    $0x0,%eax
80107c9b:	e9 c1 00 00 00       	jmp    80107d61 <allocuvm+0xd8>
  if(newsz < oldsz)
80107ca0:	8b 45 10             	mov    0x10(%ebp),%eax
80107ca3:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107ca6:	73 08                	jae    80107cb0 <allocuvm+0x27>
    return oldsz;
80107ca8:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cab:	e9 b1 00 00 00       	jmp    80107d61 <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
80107cb0:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cb3:	05 ff 0f 00 00       	add    $0xfff,%eax
80107cb8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107cbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107cc0:	e9 8d 00 00 00       	jmp    80107d52 <allocuvm+0xc9>
    mem = kalloc();
80107cc5:	e8 79 ae ff ff       	call   80102b43 <kalloc>
80107cca:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107ccd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107cd1:	75 2c                	jne    80107cff <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80107cd3:	c7 04 24 11 88 10 80 	movl   $0x80108811,(%esp)
80107cda:	e8 cb 86 ff ff       	call   801003aa <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80107cdf:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ce2:	89 44 24 08          	mov    %eax,0x8(%esp)
80107ce6:	8b 45 10             	mov    0x10(%ebp),%eax
80107ce9:	89 44 24 04          	mov    %eax,0x4(%esp)
80107ced:	8b 45 08             	mov    0x8(%ebp),%eax
80107cf0:	89 04 24             	mov    %eax,(%esp)
80107cf3:	e8 6b 00 00 00       	call   80107d63 <deallocuvm>
      return 0;
80107cf8:	b8 00 00 00 00       	mov    $0x0,%eax
80107cfd:	eb 62                	jmp    80107d61 <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
80107cff:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107d06:	00 
80107d07:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107d0e:	00 
80107d0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d12:	89 04 24             	mov    %eax,(%esp)
80107d15:	e8 84 d0 ff ff       	call   80104d9e <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80107d1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d1d:	89 04 24             	mov    %eax,(%esp)
80107d20:	e8 ca f5 ff ff       	call   801072ef <v2p>
80107d25:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107d28:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80107d2f:	00 
80107d30:	89 44 24 0c          	mov    %eax,0xc(%esp)
80107d34:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107d3b:	00 
80107d3c:	89 54 24 04          	mov    %edx,0x4(%esp)
80107d40:	8b 45 08             	mov    0x8(%ebp),%eax
80107d43:	89 04 24             	mov    %eax,(%esp)
80107d46:	e8 d6 fa ff ff       	call   80107821 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80107d4b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107d52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d55:	3b 45 10             	cmp    0x10(%ebp),%eax
80107d58:	0f 82 67 ff ff ff    	jb     80107cc5 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80107d5e:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107d61:	c9                   	leave  
80107d62:	c3                   	ret    

80107d63 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107d63:	55                   	push   %ebp
80107d64:	89 e5                	mov    %esp,%ebp
80107d66:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107d69:	8b 45 10             	mov    0x10(%ebp),%eax
80107d6c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107d6f:	72 08                	jb     80107d79 <deallocuvm+0x16>
    return oldsz;
80107d71:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d74:	e9 a4 00 00 00       	jmp    80107e1d <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
80107d79:	8b 45 10             	mov    0x10(%ebp),%eax
80107d7c:	05 ff 0f 00 00       	add    $0xfff,%eax
80107d81:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d86:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107d89:	e9 80 00 00 00       	jmp    80107e0e <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d91:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107d98:	00 
80107d99:	89 44 24 04          	mov    %eax,0x4(%esp)
80107d9d:	8b 45 08             	mov    0x8(%ebp),%eax
80107da0:	89 04 24             	mov    %eax,(%esp)
80107da3:	e8 d7 f9 ff ff       	call   8010777f <walkpgdir>
80107da8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107dab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107daf:	75 09                	jne    80107dba <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
80107db1:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80107db8:	eb 4d                	jmp    80107e07 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
80107dba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107dbd:	8b 00                	mov    (%eax),%eax
80107dbf:	83 e0 01             	and    $0x1,%eax
80107dc2:	85 c0                	test   %eax,%eax
80107dc4:	74 41                	je     80107e07 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
80107dc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107dc9:	8b 00                	mov    (%eax),%eax
80107dcb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107dd0:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107dd3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107dd7:	75 0c                	jne    80107de5 <deallocuvm+0x82>
        panic("kfree");
80107dd9:	c7 04 24 29 88 10 80 	movl   $0x80108829,(%esp)
80107de0:	e8 61 87 ff ff       	call   80100546 <panic>
      char *v = p2v(pa);
80107de5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107de8:	89 04 24             	mov    %eax,(%esp)
80107deb:	e8 0c f5 ff ff       	call   801072fc <p2v>
80107df0:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107df3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107df6:	89 04 24             	mov    %eax,(%esp)
80107df9:	e8 ac ac ff ff       	call   80102aaa <kfree>
      *pte = 0;
80107dfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e01:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80107e07:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e11:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107e14:	0f 82 74 ff ff ff    	jb     80107d8e <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80107e1a:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107e1d:	c9                   	leave  
80107e1e:	c3                   	ret    

80107e1f <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107e1f:	55                   	push   %ebp
80107e20:	89 e5                	mov    %esp,%ebp
80107e22:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80107e25:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107e29:	75 0c                	jne    80107e37 <freevm+0x18>
    panic("freevm: no pgdir");
80107e2b:	c7 04 24 2f 88 10 80 	movl   $0x8010882f,(%esp)
80107e32:	e8 0f 87 ff ff       	call   80100546 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107e37:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107e3e:	00 
80107e3f:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80107e46:	80 
80107e47:	8b 45 08             	mov    0x8(%ebp),%eax
80107e4a:	89 04 24             	mov    %eax,(%esp)
80107e4d:	e8 11 ff ff ff       	call   80107d63 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80107e52:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107e59:	eb 48                	jmp    80107ea3 <freevm+0x84>
    if(pgdir[i] & PTE_P){
80107e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107e65:	8b 45 08             	mov    0x8(%ebp),%eax
80107e68:	01 d0                	add    %edx,%eax
80107e6a:	8b 00                	mov    (%eax),%eax
80107e6c:	83 e0 01             	and    $0x1,%eax
80107e6f:	85 c0                	test   %eax,%eax
80107e71:	74 2c                	je     80107e9f <freevm+0x80>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80107e73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e76:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107e7d:	8b 45 08             	mov    0x8(%ebp),%eax
80107e80:	01 d0                	add    %edx,%eax
80107e82:	8b 00                	mov    (%eax),%eax
80107e84:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e89:	89 04 24             	mov    %eax,(%esp)
80107e8c:	e8 6b f4 ff ff       	call   801072fc <p2v>
80107e91:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107e94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e97:	89 04 24             	mov    %eax,(%esp)
80107e9a:	e8 0b ac ff ff       	call   80102aaa <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80107e9f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107ea3:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107eaa:	76 af                	jbe    80107e5b <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80107eac:	8b 45 08             	mov    0x8(%ebp),%eax
80107eaf:	89 04 24             	mov    %eax,(%esp)
80107eb2:	e8 f3 ab ff ff       	call   80102aaa <kfree>
}
80107eb7:	c9                   	leave  
80107eb8:	c3                   	ret    

80107eb9 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107eb9:	55                   	push   %ebp
80107eba:	89 e5                	mov    %esp,%ebp
80107ebc:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107ebf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107ec6:	00 
80107ec7:	8b 45 0c             	mov    0xc(%ebp),%eax
80107eca:	89 44 24 04          	mov    %eax,0x4(%esp)
80107ece:	8b 45 08             	mov    0x8(%ebp),%eax
80107ed1:	89 04 24             	mov    %eax,(%esp)
80107ed4:	e8 a6 f8 ff ff       	call   8010777f <walkpgdir>
80107ed9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107edc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107ee0:	75 0c                	jne    80107eee <clearpteu+0x35>
    panic("clearpteu");
80107ee2:	c7 04 24 40 88 10 80 	movl   $0x80108840,(%esp)
80107ee9:	e8 58 86 ff ff       	call   80100546 <panic>
  *pte &= ~PTE_U;
80107eee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef1:	8b 00                	mov    (%eax),%eax
80107ef3:	89 c2                	mov    %eax,%edx
80107ef5:	83 e2 fb             	and    $0xfffffffb,%edx
80107ef8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107efb:	89 10                	mov    %edx,(%eax)
}
80107efd:	c9                   	leave  
80107efe:	c3                   	ret    

80107eff <esPaginaKernel>:

// Verifica si es pagina de kernel o no.
int
esPaginaKernel(pte_t *pte){
80107eff:	55                   	push   %ebp
80107f00:	89 e5                	mov    %esp,%ebp
    //si es cero estamos en el kernel y devolvemos 
    //true caso contrario false.
    return ((*pte & PTE_U) == 0);
80107f02:	8b 45 08             	mov    0x8(%ebp),%eax
80107f05:	8b 00                	mov    (%eax),%eax
80107f07:	83 e0 04             	and    $0x4,%eax
80107f0a:	85 c0                	test   %eax,%eax
80107f0c:	0f 94 c0             	sete   %al
80107f0f:	0f b6 c0             	movzbl %al,%eax
}
80107f12:	5d                   	pop    %ebp
80107f13:	c3                   	ret    

80107f14 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107f14:	55                   	push   %ebp
80107f15:	89 e5                	mov    %esp,%ebp
80107f17:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i;
  char *mem;
  int primerPagina = 1;
80107f1a:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)

  if((d = setupkvm()) == 0)
80107f21:	e8 91 f9 ff ff       	call   801078b7 <setupkvm>
80107f26:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107f29:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80107f2d:	75 0a                	jne    80107f39 <copyuvm+0x25>
    return 0;
80107f2f:	b8 00 00 00 00       	mov    $0x0,%eax
80107f34:	e9 64 01 00 00       	jmp    8010809d <copyuvm+0x189>
  for(i = 0; i < sz; i += PGSIZE){
80107f39:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107f40:	e9 30 01 00 00       	jmp    80108075 <copyuvm+0x161>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107f45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f48:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107f4f:	00 
80107f50:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f54:	8b 45 08             	mov    0x8(%ebp),%eax
80107f57:	89 04 24             	mov    %eax,(%esp)
80107f5a:	e8 20 f8 ff ff       	call   8010777f <walkpgdir>
80107f5f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107f62:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80107f66:	75 0c                	jne    80107f74 <copyuvm+0x60>
      panic("copyuvm: pte should exist");
80107f68:	c7 04 24 4a 88 10 80 	movl   $0x8010884a,(%esp)
80107f6f:	e8 d2 85 ff ff       	call   80100546 <panic>
    if(!(*pte & PTE_P))
80107f74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107f77:	8b 00                	mov    (%eax),%eax
80107f79:	83 e0 01             	and    $0x1,%eax
80107f7c:	85 c0                	test   %eax,%eax
80107f7e:	75 0c                	jne    80107f8c <copyuvm+0x78>
      panic("copyuvm: page not present");
80107f80:	c7 04 24 64 88 10 80 	movl   $0x80108864,(%esp)
80107f87:	e8 ba 85 ff ff       	call   80100546 <panic>
    //solo para una pagina 
    // 1 hacer un if que pregunte si es pagina de usuario y si es de usuario 
    //ponerla como no escribible y preguntar si es primera pagina para 
    //copiarsela al proceso hijo. Si no es de usuario, copiarla al hijo
    //(o sea hacer lo que hacia antes)
    if (!esPaginaKernel(pte)){
80107f8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107f8f:	89 04 24             	mov    %eax,(%esp)
80107f92:	e8 68 ff ff ff       	call   80107eff <esPaginaKernel>
80107f97:	85 c0                	test   %eax,%eax
80107f99:	75 61                	jne    80107ffc <copyuvm+0xe8>
                if (primerPagina){
80107f9b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f9f:	74 4a                	je     80107feb <copyuvm+0xd7>
                    primerPagina = 0;
80107fa1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
                    pa = PTE_ADDR(*pte);
80107fa8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107fab:	8b 00                	mov    (%eax),%eax
80107fad:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fb2:	89 45 e0             	mov    %eax,-0x20(%ebp)
                    if((mem = kalloc()) == 0)
80107fb5:	e8 89 ab ff ff       	call   80102b43 <kalloc>
80107fba:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107fbd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107fc1:	0f 84 bf 00 00 00    	je     80108086 <copyuvm+0x172>
                      goto bad;
                    memmove(mem, (char*)p2v(pa), PGSIZE);
80107fc7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107fca:	89 04 24             	mov    %eax,(%esp)
80107fcd:	e8 2a f3 ff ff       	call   801072fc <p2v>
80107fd2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107fd9:	00 
80107fda:	89 44 24 04          	mov    %eax,0x4(%esp)
80107fde:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fe1:	89 04 24             	mov    %eax,(%esp)
80107fe4:	e8 88 ce ff ff       	call   80104e71 <memmove>
80107fe9:	eb 4e                	jmp    80108039 <copyuvm+0x125>
                } else{
                    *pte = ((*pte) & (~PTE_W));
80107feb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107fee:	8b 00                	mov    (%eax),%eax
80107ff0:	89 c2                	mov    %eax,%edx
80107ff2:	83 e2 fd             	and    $0xfffffffd,%edx
80107ff5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107ff8:	89 10                	mov    %edx,(%eax)
80107ffa:	eb 3d                	jmp    80108039 <copyuvm+0x125>
                }    
    }else{//si es pagina de kernel se hacia como antes
        pa = PTE_ADDR(*pte);
80107ffc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107fff:	8b 00                	mov    (%eax),%eax
80108001:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108006:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if((mem = kalloc()) == 0)
80108009:	e8 35 ab ff ff       	call   80102b43 <kalloc>
8010800e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108011:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108015:	74 72                	je     80108089 <copyuvm+0x175>
          goto bad;
        memmove(mem, (char*)p2v(pa), PGSIZE);
80108017:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010801a:	89 04 24             	mov    %eax,(%esp)
8010801d:	e8 da f2 ff ff       	call   801072fc <p2v>
80108022:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108029:	00 
8010802a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010802e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108031:	89 04 24             	mov    %eax,(%esp)
80108034:	e8 38 ce ff ff       	call   80104e71 <memmove>
    }
    
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
80108039:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010803c:	89 04 24             	mov    %eax,(%esp)
8010803f:	e8 ab f2 ff ff       	call   801072ef <v2p>
80108044:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108047:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
8010804e:	00 
8010804f:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108053:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010805a:	00 
8010805b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010805f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108062:	89 04 24             	mov    %eax,(%esp)
80108065:	e8 b7 f7 ff ff       	call   80107821 <mappages>
8010806a:	85 c0                	test   %eax,%eax
8010806c:	78 1e                	js     8010808c <copyuvm+0x178>
  char *mem;
  int primerPagina = 1;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010806e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108075:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108078:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010807b:	0f 82 c4 fe ff ff    	jb     80107f45 <copyuvm+0x31>
    }
    
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
  }
  return d;
80108081:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108084:	eb 17                	jmp    8010809d <copyuvm+0x189>
    if (!esPaginaKernel(pte)){
                if (primerPagina){
                    primerPagina = 0;
                    pa = PTE_ADDR(*pte);
                    if((mem = kalloc()) == 0)
                      goto bad;
80108086:	90                   	nop
80108087:	eb 04                	jmp    8010808d <copyuvm+0x179>
                    *pte = ((*pte) & (~PTE_W));
                }    
    }else{//si es pagina de kernel se hacia como antes
        pa = PTE_ADDR(*pte);
        if((mem = kalloc()) == 0)
          goto bad;
80108089:	90                   	nop
8010808a:	eb 01                	jmp    8010808d <copyuvm+0x179>
        memmove(mem, (char*)p2v(pa), PGSIZE);
    }
    
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
8010808c:	90                   	nop
  }
  return d;

bad:
  freevm(d);
8010808d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108090:	89 04 24             	mov    %eax,(%esp)
80108093:	e8 87 fd ff ff       	call   80107e1f <freevm>
  return 0;
80108098:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010809d:	c9                   	leave  
8010809e:	c3                   	ret    

8010809f <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010809f:	55                   	push   %ebp
801080a0:	89 e5                	mov    %esp,%ebp
801080a2:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801080a5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801080ac:	00 
801080ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801080b0:	89 44 24 04          	mov    %eax,0x4(%esp)
801080b4:	8b 45 08             	mov    0x8(%ebp),%eax
801080b7:	89 04 24             	mov    %eax,(%esp)
801080ba:	e8 c0 f6 ff ff       	call   8010777f <walkpgdir>
801080bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801080c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080c5:	8b 00                	mov    (%eax),%eax
801080c7:	83 e0 01             	and    $0x1,%eax
801080ca:	85 c0                	test   %eax,%eax
801080cc:	75 07                	jne    801080d5 <uva2ka+0x36>
    return 0;
801080ce:	b8 00 00 00 00       	mov    $0x0,%eax
801080d3:	eb 25                	jmp    801080fa <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
801080d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080d8:	8b 00                	mov    (%eax),%eax
801080da:	83 e0 04             	and    $0x4,%eax
801080dd:	85 c0                	test   %eax,%eax
801080df:	75 07                	jne    801080e8 <uva2ka+0x49>
    return 0;
801080e1:	b8 00 00 00 00       	mov    $0x0,%eax
801080e6:	eb 12                	jmp    801080fa <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
801080e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080eb:	8b 00                	mov    (%eax),%eax
801080ed:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080f2:	89 04 24             	mov    %eax,(%esp)
801080f5:	e8 02 f2 ff ff       	call   801072fc <p2v>
}
801080fa:	c9                   	leave  
801080fb:	c3                   	ret    

801080fc <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801080fc:	55                   	push   %ebp
801080fd:	89 e5                	mov    %esp,%ebp
801080ff:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108102:	8b 45 10             	mov    0x10(%ebp),%eax
80108105:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108108:	e9 89 00 00 00       	jmp    80108196 <copyout+0x9a>
    va0 = (uint)PGROUNDDOWN(va);
8010810d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108110:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108115:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108118:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010811b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010811f:	8b 45 08             	mov    0x8(%ebp),%eax
80108122:	89 04 24             	mov    %eax,(%esp)
80108125:	e8 75 ff ff ff       	call   8010809f <uva2ka>
8010812a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010812d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108131:	75 07                	jne    8010813a <copyout+0x3e>
      return -1;
80108133:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108138:	eb 6b                	jmp    801081a5 <copyout+0xa9>
    n = PGSIZE - (va - va0);
8010813a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010813d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108140:	89 d1                	mov    %edx,%ecx
80108142:	29 c1                	sub    %eax,%ecx
80108144:	89 c8                	mov    %ecx,%eax
80108146:	05 00 10 00 00       	add    $0x1000,%eax
8010814b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010814e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108151:	3b 45 14             	cmp    0x14(%ebp),%eax
80108154:	76 06                	jbe    8010815c <copyout+0x60>
      n = len;
80108156:	8b 45 14             	mov    0x14(%ebp),%eax
80108159:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010815c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010815f:	8b 55 0c             	mov    0xc(%ebp),%edx
80108162:	29 c2                	sub    %eax,%edx
80108164:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108167:	01 c2                	add    %eax,%edx
80108169:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010816c:	89 44 24 08          	mov    %eax,0x8(%esp)
80108170:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108173:	89 44 24 04          	mov    %eax,0x4(%esp)
80108177:	89 14 24             	mov    %edx,(%esp)
8010817a:	e8 f2 cc ff ff       	call   80104e71 <memmove>
    len -= n;
8010817f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108182:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108185:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108188:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010818b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010818e:	05 00 10 00 00       	add    $0x1000,%eax
80108193:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108196:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010819a:	0f 85 6d ff ff ff    	jne    8010810d <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801081a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801081a5:	c9                   	leave  
801081a6:	c3                   	ret    
