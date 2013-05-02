
_sh:     formato del fichero elf32-i386


Desensamblado de la sección .text:

00000000 <runcmd>:
struct cmd *parsecmd(char*);

// Execute cmd.  Never returns.
void
runcmd(struct cmd *cmd)
{
       0:	55                   	push   %ebp
       1:	89 e5                	mov    %esp,%ebp
       3:	83 ec 38             	sub    $0x38,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0){
       6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
       a:	75 19                	jne    25 <runcmd+0x25>
	printf(2, "Exit 1 Sh\n");
       c:	c7 44 24 04 dc 14 00 	movl   $0x14dc,0x4(%esp)
      13:	00 
      14:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      1b:	e8 e9 10 00 00       	call   1109 <printf>
    exit();
      20:	e8 67 0f 00 00       	call   f8c <exit>
  }
  
  switch(cmd->type){
      25:	8b 45 08             	mov    0x8(%ebp),%eax
      28:	8b 00                	mov    (%eax),%eax
      2a:	83 f8 05             	cmp    $0x5,%eax
      2d:	77 09                	ja     38 <runcmd+0x38>
      2f:	8b 04 85 20 15 00 00 	mov    0x1520(,%eax,4),%eax
      36:	ff e0                	jmp    *%eax
  default:
    panic("runcmd");
      38:	c7 04 24 e7 14 00 00 	movl   $0x14e7,(%esp)
      3f:	e8 3e 03 00 00       	call   382 <panic>

  case EXEC:
    ecmd = (struct execcmd*)cmd;
      44:	8b 45 08             	mov    0x8(%ebp),%eax
      47:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ecmd->argv[0] == 0){
      4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
      4d:	8b 40 04             	mov    0x4(%eax),%eax
      50:	85 c0                	test   %eax,%eax
      52:	75 19                	jne    6d <runcmd+0x6d>
	  printf(2, "Exit 2 Sh\n");
      54:	c7 44 24 04 ee 14 00 	movl   $0x14ee,0x4(%esp)
      5b:	00 
      5c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      63:	e8 a1 10 00 00       	call   1109 <printf>
      exit();
      68:	e8 1f 0f 00 00       	call   f8c <exit>
    }
    exec(ecmd->argv[0], ecmd->argv);
      6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
      70:	8d 50 04             	lea    0x4(%eax),%edx
      73:	8b 45 f4             	mov    -0xc(%ebp),%eax
      76:	8b 40 04             	mov    0x4(%eax),%eax
      79:	89 54 24 04          	mov    %edx,0x4(%esp)
      7d:	89 04 24             	mov    %eax,(%esp)
      80:	e8 3f 0f 00 00       	call   fc4 <exec>
    printf(2, "exec %s failed\n", ecmd->argv[0]);
      85:	8b 45 f4             	mov    -0xc(%ebp),%eax
      88:	8b 40 04             	mov    0x4(%eax),%eax
      8b:	89 44 24 08          	mov    %eax,0x8(%esp)
      8f:	c7 44 24 04 f9 14 00 	movl   $0x14f9,0x4(%esp)
      96:	00 
      97:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      9e:	e8 66 10 00 00       	call   1109 <printf>
    break;
      a3:	e9 84 01 00 00       	jmp    22c <runcmd+0x22c>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
      a8:	8b 45 08             	mov    0x8(%ebp),%eax
      ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
    close(rcmd->fd);
      ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
      b1:	8b 40 14             	mov    0x14(%eax),%eax
      b4:	89 04 24             	mov    %eax,(%esp)
      b7:	e8 f8 0e 00 00       	call   fb4 <close>
    if(open(rcmd->file, rcmd->mode) < 0){
      bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
      bf:	8b 50 10             	mov    0x10(%eax),%edx
      c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
      c5:	8b 40 08             	mov    0x8(%eax),%eax
      c8:	89 54 24 04          	mov    %edx,0x4(%esp)
      cc:	89 04 24             	mov    %eax,(%esp)
      cf:	e8 f8 0e 00 00       	call   fcc <open>
      d4:	85 c0                	test   %eax,%eax
      d6:	79 23                	jns    fb <runcmd+0xfb>
      printf(2, "open %s failed\n", rcmd->file);
      d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
      db:	8b 40 08             	mov    0x8(%eax),%eax
      de:	89 44 24 08          	mov    %eax,0x8(%esp)
      e2:	c7 44 24 04 09 15 00 	movl   $0x1509,0x4(%esp)
      e9:	00 
      ea:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      f1:	e8 13 10 00 00       	call   1109 <printf>
      exit();
      f6:	e8 91 0e 00 00       	call   f8c <exit>
    }
    runcmd(rcmd->cmd);
      fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
      fe:	8b 40 04             	mov    0x4(%eax),%eax
     101:	89 04 24             	mov    %eax,(%esp)
     104:	e8 f7 fe ff ff       	call   0 <runcmd>
    break;
     109:	e9 1e 01 00 00       	jmp    22c <runcmd+0x22c>

  case LIST:
    lcmd = (struct listcmd*)cmd;
     10e:	8b 45 08             	mov    0x8(%ebp),%eax
     111:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(fork1() == 0)
     114:	e8 8f 02 00 00       	call   3a8 <fork1>
     119:	85 c0                	test   %eax,%eax
     11b:	75 0e                	jne    12b <runcmd+0x12b>
      runcmd(lcmd->left);
     11d:	8b 45 ec             	mov    -0x14(%ebp),%eax
     120:	8b 40 04             	mov    0x4(%eax),%eax
     123:	89 04 24             	mov    %eax,(%esp)
     126:	e8 d5 fe ff ff       	call   0 <runcmd>
    wait();
     12b:	e8 64 0e 00 00       	call   f94 <wait>
    runcmd(lcmd->right);
     130:	8b 45 ec             	mov    -0x14(%ebp),%eax
     133:	8b 40 08             	mov    0x8(%eax),%eax
     136:	89 04 24             	mov    %eax,(%esp)
     139:	e8 c2 fe ff ff       	call   0 <runcmd>
    break;
     13e:	e9 e9 00 00 00       	jmp    22c <runcmd+0x22c>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     143:	8b 45 08             	mov    0x8(%ebp),%eax
     146:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pipe(p) < 0)
     149:	8d 45 dc             	lea    -0x24(%ebp),%eax
     14c:	89 04 24             	mov    %eax,(%esp)
     14f:	e8 48 0e 00 00       	call   f9c <pipe>
     154:	85 c0                	test   %eax,%eax
     156:	79 0c                	jns    164 <runcmd+0x164>
      panic("pipe");
     158:	c7 04 24 19 15 00 00 	movl   $0x1519,(%esp)
     15f:	e8 1e 02 00 00       	call   382 <panic>
    if(fork1() == 0){
     164:	e8 3f 02 00 00       	call   3a8 <fork1>
     169:	85 c0                	test   %eax,%eax
     16b:	75 3b                	jne    1a8 <runcmd+0x1a8>
      close(1);
     16d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     174:	e8 3b 0e 00 00       	call   fb4 <close>
      dup(p[1]);
     179:	8b 45 e0             	mov    -0x20(%ebp),%eax
     17c:	89 04 24             	mov    %eax,(%esp)
     17f:	e8 80 0e 00 00       	call   1004 <dup>
      close(p[0]);
     184:	8b 45 dc             	mov    -0x24(%ebp),%eax
     187:	89 04 24             	mov    %eax,(%esp)
     18a:	e8 25 0e 00 00       	call   fb4 <close>
      close(p[1]);
     18f:	8b 45 e0             	mov    -0x20(%ebp),%eax
     192:	89 04 24             	mov    %eax,(%esp)
     195:	e8 1a 0e 00 00       	call   fb4 <close>
      runcmd(pcmd->left);
     19a:	8b 45 e8             	mov    -0x18(%ebp),%eax
     19d:	8b 40 04             	mov    0x4(%eax),%eax
     1a0:	89 04 24             	mov    %eax,(%esp)
     1a3:	e8 58 fe ff ff       	call   0 <runcmd>
    }
    if(fork1() == 0){
     1a8:	e8 fb 01 00 00       	call   3a8 <fork1>
     1ad:	85 c0                	test   %eax,%eax
     1af:	75 3b                	jne    1ec <runcmd+0x1ec>
      close(0);
     1b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     1b8:	e8 f7 0d 00 00       	call   fb4 <close>
      dup(p[0]);
     1bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1c0:	89 04 24             	mov    %eax,(%esp)
     1c3:	e8 3c 0e 00 00       	call   1004 <dup>
      close(p[0]);
     1c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1cb:	89 04 24             	mov    %eax,(%esp)
     1ce:	e8 e1 0d 00 00       	call   fb4 <close>
      close(p[1]);
     1d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
     1d6:	89 04 24             	mov    %eax,(%esp)
     1d9:	e8 d6 0d 00 00       	call   fb4 <close>
      runcmd(pcmd->right);
     1de:	8b 45 e8             	mov    -0x18(%ebp),%eax
     1e1:	8b 40 08             	mov    0x8(%eax),%eax
     1e4:	89 04 24             	mov    %eax,(%esp)
     1e7:	e8 14 fe ff ff       	call   0 <runcmd>
    }
    close(p[0]);
     1ec:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1ef:	89 04 24             	mov    %eax,(%esp)
     1f2:	e8 bd 0d 00 00       	call   fb4 <close>
    close(p[1]);
     1f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
     1fa:	89 04 24             	mov    %eax,(%esp)
     1fd:	e8 b2 0d 00 00       	call   fb4 <close>
    wait();
     202:	e8 8d 0d 00 00       	call   f94 <wait>
    wait();
     207:	e8 88 0d 00 00       	call   f94 <wait>
    break;
     20c:	eb 1e                	jmp    22c <runcmd+0x22c>
    
  case BACK:
    bcmd = (struct backcmd*)cmd;
     20e:	8b 45 08             	mov    0x8(%ebp),%eax
     211:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(fork1() == 0)
     214:	e8 8f 01 00 00       	call   3a8 <fork1>
     219:	85 c0                	test   %eax,%eax
     21b:	75 0e                	jne    22b <runcmd+0x22b>
      runcmd(bcmd->cmd);
     21d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     220:	8b 40 04             	mov    0x4(%eax),%eax
     223:	89 04 24             	mov    %eax,(%esp)
     226:	e8 d5 fd ff ff       	call   0 <runcmd>
    break;
     22b:	90                   	nop
  }
  exit();
     22c:	e8 5b 0d 00 00       	call   f8c <exit>

00000231 <getcmd>:
}

int
getcmd(char *buf, int nbuf)
{
     231:	55                   	push   %ebp
     232:	89 e5                	mov    %esp,%ebp
     234:	83 ec 18             	sub    $0x18,%esp
  printf(2, "$ ");
     237:	c7 44 24 04 38 15 00 	movl   $0x1538,0x4(%esp)
     23e:	00 
     23f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     246:	e8 be 0e 00 00       	call   1109 <printf>
  memset(buf, 0, nbuf);
     24b:	8b 45 0c             	mov    0xc(%ebp),%eax
     24e:	89 44 24 08          	mov    %eax,0x8(%esp)
     252:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     259:	00 
     25a:	8b 45 08             	mov    0x8(%ebp),%eax
     25d:	89 04 24             	mov    %eax,(%esp)
     260:	e8 80 0b 00 00       	call   de5 <memset>
  gets(buf, nbuf);
     265:	8b 45 0c             	mov    0xc(%ebp),%eax
     268:	89 44 24 04          	mov    %eax,0x4(%esp)
     26c:	8b 45 08             	mov    0x8(%ebp),%eax
     26f:	89 04 24             	mov    %eax,(%esp)
     272:	e8 c5 0b 00 00       	call   e3c <gets>
  if(buf[0] == 0) // EOF
     277:	8b 45 08             	mov    0x8(%ebp),%eax
     27a:	0f b6 00             	movzbl (%eax),%eax
     27d:	84 c0                	test   %al,%al
     27f:	75 07                	jne    288 <getcmd+0x57>
    return -1;
     281:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     286:	eb 05                	jmp    28d <getcmd+0x5c>
  return 0;
     288:	b8 00 00 00 00       	mov    $0x0,%eax
}
     28d:	c9                   	leave  
     28e:	c3                   	ret    

0000028f <main>:

int
main(void)
{
     28f:	55                   	push   %ebp
     290:	89 e5                	mov    %esp,%ebp
     292:	83 e4 f0             	and    $0xfffffff0,%esp
     295:	83 ec 20             	sub    $0x20,%esp
  static char buf[100];
  int fd;
  
  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     298:	eb 19                	jmp    2b3 <main+0x24>
    if(fd >= 3){
     29a:	83 7c 24 1c 02       	cmpl   $0x2,0x1c(%esp)
     29f:	7e 12                	jle    2b3 <main+0x24>
      close(fd);
     2a1:	8b 44 24 1c          	mov    0x1c(%esp),%eax
     2a5:	89 04 24             	mov    %eax,(%esp)
     2a8:	e8 07 0d 00 00       	call   fb4 <close>
      break;
     2ad:	90                   	nop
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     2ae:	e9 ae 00 00 00       	jmp    361 <main+0xd2>
{
  static char buf[100];
  int fd;
  
  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     2b3:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
     2ba:	00 
     2bb:	c7 04 24 3b 15 00 00 	movl   $0x153b,(%esp)
     2c2:	e8 05 0d 00 00       	call   fcc <open>
     2c7:	89 44 24 1c          	mov    %eax,0x1c(%esp)
     2cb:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
     2d0:	79 c8                	jns    29a <main+0xb>
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     2d2:	e9 8a 00 00 00       	jmp    361 <main+0xd2>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     2d7:	0f b6 05 a0 1a 00 00 	movzbl 0x1aa0,%eax
     2de:	3c 63                	cmp    $0x63,%al
     2e0:	75 5a                	jne    33c <main+0xad>
     2e2:	0f b6 05 a1 1a 00 00 	movzbl 0x1aa1,%eax
     2e9:	3c 64                	cmp    $0x64,%al
     2eb:	75 4f                	jne    33c <main+0xad>
     2ed:	0f b6 05 a2 1a 00 00 	movzbl 0x1aa2,%eax
     2f4:	3c 20                	cmp    $0x20,%al
     2f6:	75 44                	jne    33c <main+0xad>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
     2f8:	c7 04 24 a0 1a 00 00 	movl   $0x1aa0,(%esp)
     2ff:	e8 ba 0a 00 00       	call   dbe <strlen>
     304:	83 e8 01             	sub    $0x1,%eax
     307:	c6 80 a0 1a 00 00 00 	movb   $0x0,0x1aa0(%eax)
      if(chdir(buf+3) < 0)
     30e:	c7 04 24 a3 1a 00 00 	movl   $0x1aa3,(%esp)
     315:	e8 e2 0c 00 00       	call   ffc <chdir>
     31a:	85 c0                	test   %eax,%eax
     31c:	79 42                	jns    360 <main+0xd1>
        printf(2, "cannot cd %s\n", buf+3);
     31e:	c7 44 24 08 a3 1a 00 	movl   $0x1aa3,0x8(%esp)
     325:	00 
     326:	c7 44 24 04 43 15 00 	movl   $0x1543,0x4(%esp)
     32d:	00 
     32e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     335:	e8 cf 0d 00 00       	call   1109 <printf>
      continue;
     33a:	eb 24                	jmp    360 <main+0xd1>
    }
    if(fork1() == 0)
     33c:	e8 67 00 00 00       	call   3a8 <fork1>
     341:	85 c0                	test   %eax,%eax
     343:	75 14                	jne    359 <main+0xca>
      runcmd(parsecmd(buf));
     345:	c7 04 24 a0 1a 00 00 	movl   $0x1aa0,(%esp)
     34c:	e8 c9 03 00 00       	call   71a <parsecmd>
     351:	89 04 24             	mov    %eax,(%esp)
     354:	e8 a7 fc ff ff       	call   0 <runcmd>
    wait();
     359:	e8 36 0c 00 00       	call   f94 <wait>
     35e:	eb 01                	jmp    361 <main+0xd2>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
      if(chdir(buf+3) < 0)
        printf(2, "cannot cd %s\n", buf+3);
      continue;
     360:	90                   	nop
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     361:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
     368:	00 
     369:	c7 04 24 a0 1a 00 00 	movl   $0x1aa0,(%esp)
     370:	e8 bc fe ff ff       	call   231 <getcmd>
     375:	85 c0                	test   %eax,%eax
     377:	0f 89 5a ff ff ff    	jns    2d7 <main+0x48>
    }
    if(fork1() == 0)
      runcmd(parsecmd(buf));
    wait();
  }
  exit();
     37d:	e8 0a 0c 00 00       	call   f8c <exit>

00000382 <panic>:
}

void
panic(char *s)
{
     382:	55                   	push   %ebp
     383:	89 e5                	mov    %esp,%ebp
     385:	83 ec 18             	sub    $0x18,%esp
  printf(2, "%s\n", s);
     388:	8b 45 08             	mov    0x8(%ebp),%eax
     38b:	89 44 24 08          	mov    %eax,0x8(%esp)
     38f:	c7 44 24 04 51 15 00 	movl   $0x1551,0x4(%esp)
     396:	00 
     397:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     39e:	e8 66 0d 00 00       	call   1109 <printf>
  exit();
     3a3:	e8 e4 0b 00 00       	call   f8c <exit>

000003a8 <fork1>:
}

int
fork1(void)
{
     3a8:	55                   	push   %ebp
     3a9:	89 e5                	mov    %esp,%ebp
     3ab:	83 ec 28             	sub    $0x28,%esp
  int pid;
  
  pid = fork();
     3ae:	e8 d1 0b 00 00       	call   f84 <fork>
     3b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid == -1)
     3b6:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
     3ba:	75 0c                	jne    3c8 <fork1+0x20>
    panic("fork");
     3bc:	c7 04 24 55 15 00 00 	movl   $0x1555,(%esp)
     3c3:	e8 ba ff ff ff       	call   382 <panic>
  return pid;
     3c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     3cb:	c9                   	leave  
     3cc:	c3                   	ret    

000003cd <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     3cd:	55                   	push   %ebp
     3ce:	89 e5                	mov    %esp,%ebp
     3d0:	83 ec 28             	sub    $0x28,%esp
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     3d3:	c7 04 24 54 00 00 00 	movl   $0x54,(%esp)
     3da:	e8 1a 10 00 00       	call   13f9 <malloc>
     3df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     3e2:	c7 44 24 08 54 00 00 	movl   $0x54,0x8(%esp)
     3e9:	00 
     3ea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     3f1:	00 
     3f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
     3f5:	89 04 24             	mov    %eax,(%esp)
     3f8:	e8 e8 09 00 00       	call   de5 <memset>
  cmd->type = EXEC;
     3fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
     400:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  return (struct cmd*)cmd;
     406:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     409:	c9                   	leave  
     40a:	c3                   	ret    

0000040b <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     40b:	55                   	push   %ebp
     40c:	89 e5                	mov    %esp,%ebp
     40e:	83 ec 28             	sub    $0x28,%esp
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     411:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
     418:	e8 dc 0f 00 00       	call   13f9 <malloc>
     41d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     420:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
     427:	00 
     428:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     42f:	00 
     430:	8b 45 f4             	mov    -0xc(%ebp),%eax
     433:	89 04 24             	mov    %eax,(%esp)
     436:	e8 aa 09 00 00       	call   de5 <memset>
  cmd->type = REDIR;
     43b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     43e:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  cmd->cmd = subcmd;
     444:	8b 45 f4             	mov    -0xc(%ebp),%eax
     447:	8b 55 08             	mov    0x8(%ebp),%edx
     44a:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->file = file;
     44d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     450:	8b 55 0c             	mov    0xc(%ebp),%edx
     453:	89 50 08             	mov    %edx,0x8(%eax)
  cmd->efile = efile;
     456:	8b 45 f4             	mov    -0xc(%ebp),%eax
     459:	8b 55 10             	mov    0x10(%ebp),%edx
     45c:	89 50 0c             	mov    %edx,0xc(%eax)
  cmd->mode = mode;
     45f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     462:	8b 55 14             	mov    0x14(%ebp),%edx
     465:	89 50 10             	mov    %edx,0x10(%eax)
  cmd->fd = fd;
     468:	8b 45 f4             	mov    -0xc(%ebp),%eax
     46b:	8b 55 18             	mov    0x18(%ebp),%edx
     46e:	89 50 14             	mov    %edx,0x14(%eax)
  return (struct cmd*)cmd;
     471:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     474:	c9                   	leave  
     475:	c3                   	ret    

00000476 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     476:	55                   	push   %ebp
     477:	89 e5                	mov    %esp,%ebp
     479:	83 ec 28             	sub    $0x28,%esp
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     47c:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     483:	e8 71 0f 00 00       	call   13f9 <malloc>
     488:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     48b:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     492:	00 
     493:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     49a:	00 
     49b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     49e:	89 04 24             	mov    %eax,(%esp)
     4a1:	e8 3f 09 00 00       	call   de5 <memset>
  cmd->type = PIPE;
     4a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4a9:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
  cmd->left = left;
     4af:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4b2:	8b 55 08             	mov    0x8(%ebp),%edx
     4b5:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     4b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4bb:	8b 55 0c             	mov    0xc(%ebp),%edx
     4be:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     4c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     4c4:	c9                   	leave  
     4c5:	c3                   	ret    

000004c6 <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     4c6:	55                   	push   %ebp
     4c7:	89 e5                	mov    %esp,%ebp
     4c9:	83 ec 28             	sub    $0x28,%esp
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     4cc:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     4d3:	e8 21 0f 00 00       	call   13f9 <malloc>
     4d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     4db:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     4e2:	00 
     4e3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     4ea:	00 
     4eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4ee:	89 04 24             	mov    %eax,(%esp)
     4f1:	e8 ef 08 00 00       	call   de5 <memset>
  cmd->type = LIST;
     4f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4f9:	c7 00 04 00 00 00    	movl   $0x4,(%eax)
  cmd->left = left;
     4ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
     502:	8b 55 08             	mov    0x8(%ebp),%edx
     505:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     508:	8b 45 f4             	mov    -0xc(%ebp),%eax
     50b:	8b 55 0c             	mov    0xc(%ebp),%edx
     50e:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     511:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     514:	c9                   	leave  
     515:	c3                   	ret    

00000516 <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     516:	55                   	push   %ebp
     517:	89 e5                	mov    %esp,%ebp
     519:	83 ec 28             	sub    $0x28,%esp
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     51c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
     523:	e8 d1 0e 00 00       	call   13f9 <malloc>
     528:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     52b:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
     532:	00 
     533:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     53a:	00 
     53b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     53e:	89 04 24             	mov    %eax,(%esp)
     541:	e8 9f 08 00 00       	call   de5 <memset>
  cmd->type = BACK;
     546:	8b 45 f4             	mov    -0xc(%ebp),%eax
     549:	c7 00 05 00 00 00    	movl   $0x5,(%eax)
  cmd->cmd = subcmd;
     54f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     552:	8b 55 08             	mov    0x8(%ebp),%edx
     555:	89 50 04             	mov    %edx,0x4(%eax)
  return (struct cmd*)cmd;
     558:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     55b:	c9                   	leave  
     55c:	c3                   	ret    

0000055d <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     55d:	55                   	push   %ebp
     55e:	89 e5                	mov    %esp,%ebp
     560:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int ret;
  
  s = *ps;
     563:	8b 45 08             	mov    0x8(%ebp),%eax
     566:	8b 00                	mov    (%eax),%eax
     568:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     56b:	eb 04                	jmp    571 <gettoken+0x14>
    s++;
     56d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
{
  char *s;
  int ret;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     571:	8b 45 f4             	mov    -0xc(%ebp),%eax
     574:	3b 45 0c             	cmp    0xc(%ebp),%eax
     577:	73 1d                	jae    596 <gettoken+0x39>
     579:	8b 45 f4             	mov    -0xc(%ebp),%eax
     57c:	0f b6 00             	movzbl (%eax),%eax
     57f:	0f be c0             	movsbl %al,%eax
     582:	89 44 24 04          	mov    %eax,0x4(%esp)
     586:	c7 04 24 64 1a 00 00 	movl   $0x1a64,(%esp)
     58d:	e8 77 08 00 00       	call   e09 <strchr>
     592:	85 c0                	test   %eax,%eax
     594:	75 d7                	jne    56d <gettoken+0x10>
    s++;
  if(q)
     596:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     59a:	74 08                	je     5a4 <gettoken+0x47>
    *q = s;
     59c:	8b 45 10             	mov    0x10(%ebp),%eax
     59f:	8b 55 f4             	mov    -0xc(%ebp),%edx
     5a2:	89 10                	mov    %edx,(%eax)
  ret = *s;
     5a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5a7:	0f b6 00             	movzbl (%eax),%eax
     5aa:	0f be c0             	movsbl %al,%eax
     5ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
  switch(*s){
     5b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5b3:	0f b6 00             	movzbl (%eax),%eax
     5b6:	0f be c0             	movsbl %al,%eax
     5b9:	83 f8 3c             	cmp    $0x3c,%eax
     5bc:	7f 1e                	jg     5dc <gettoken+0x7f>
     5be:	83 f8 3b             	cmp    $0x3b,%eax
     5c1:	7d 23                	jge    5e6 <gettoken+0x89>
     5c3:	83 f8 29             	cmp    $0x29,%eax
     5c6:	7f 3f                	jg     607 <gettoken+0xaa>
     5c8:	83 f8 28             	cmp    $0x28,%eax
     5cb:	7d 19                	jge    5e6 <gettoken+0x89>
     5cd:	85 c0                	test   %eax,%eax
     5cf:	0f 84 83 00 00 00    	je     658 <gettoken+0xfb>
     5d5:	83 f8 26             	cmp    $0x26,%eax
     5d8:	74 0c                	je     5e6 <gettoken+0x89>
     5da:	eb 2b                	jmp    607 <gettoken+0xaa>
     5dc:	83 f8 3e             	cmp    $0x3e,%eax
     5df:	74 0b                	je     5ec <gettoken+0x8f>
     5e1:	83 f8 7c             	cmp    $0x7c,%eax
     5e4:	75 21                	jne    607 <gettoken+0xaa>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     5e6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
     5ea:	eb 73                	jmp    65f <gettoken+0x102>
  case '>':
    s++;
     5ec:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(*s == '>'){
     5f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5f3:	0f b6 00             	movzbl (%eax),%eax
     5f6:	3c 3e                	cmp    $0x3e,%al
     5f8:	75 61                	jne    65b <gettoken+0xfe>
      ret = '+';
     5fa:	c7 45 f0 2b 00 00 00 	movl   $0x2b,-0x10(%ebp)
      s++;
     601:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }
    break;
     605:	eb 54                	jmp    65b <gettoken+0xfe>
  default:
    ret = 'a';
     607:	c7 45 f0 61 00 00 00 	movl   $0x61,-0x10(%ebp)
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     60e:	eb 04                	jmp    614 <gettoken+0xb7>
      s++;
     610:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      s++;
    }
    break;
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     614:	8b 45 f4             	mov    -0xc(%ebp),%eax
     617:	3b 45 0c             	cmp    0xc(%ebp),%eax
     61a:	73 42                	jae    65e <gettoken+0x101>
     61c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     61f:	0f b6 00             	movzbl (%eax),%eax
     622:	0f be c0             	movsbl %al,%eax
     625:	89 44 24 04          	mov    %eax,0x4(%esp)
     629:	c7 04 24 64 1a 00 00 	movl   $0x1a64,(%esp)
     630:	e8 d4 07 00 00       	call   e09 <strchr>
     635:	85 c0                	test   %eax,%eax
     637:	75 25                	jne    65e <gettoken+0x101>
     639:	8b 45 f4             	mov    -0xc(%ebp),%eax
     63c:	0f b6 00             	movzbl (%eax),%eax
     63f:	0f be c0             	movsbl %al,%eax
     642:	89 44 24 04          	mov    %eax,0x4(%esp)
     646:	c7 04 24 6a 1a 00 00 	movl   $0x1a6a,(%esp)
     64d:	e8 b7 07 00 00       	call   e09 <strchr>
     652:	85 c0                	test   %eax,%eax
     654:	74 ba                	je     610 <gettoken+0xb3>
      s++;
    break;
     656:	eb 06                	jmp    65e <gettoken+0x101>
  if(q)
    *q = s;
  ret = *s;
  switch(*s){
  case 0:
    break;
     658:	90                   	nop
     659:	eb 04                	jmp    65f <gettoken+0x102>
    s++;
    if(*s == '>'){
      ret = '+';
      s++;
    }
    break;
     65b:	90                   	nop
     65c:	eb 01                	jmp    65f <gettoken+0x102>
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
     65e:	90                   	nop
  }
  if(eq)
     65f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
     663:	74 0e                	je     673 <gettoken+0x116>
    *eq = s;
     665:	8b 45 14             	mov    0x14(%ebp),%eax
     668:	8b 55 f4             	mov    -0xc(%ebp),%edx
     66b:	89 10                	mov    %edx,(%eax)
  
  while(s < es && strchr(whitespace, *s))
     66d:	eb 04                	jmp    673 <gettoken+0x116>
    s++;
     66f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
  }
  if(eq)
    *eq = s;
  
  while(s < es && strchr(whitespace, *s))
     673:	8b 45 f4             	mov    -0xc(%ebp),%eax
     676:	3b 45 0c             	cmp    0xc(%ebp),%eax
     679:	73 1d                	jae    698 <gettoken+0x13b>
     67b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     67e:	0f b6 00             	movzbl (%eax),%eax
     681:	0f be c0             	movsbl %al,%eax
     684:	89 44 24 04          	mov    %eax,0x4(%esp)
     688:	c7 04 24 64 1a 00 00 	movl   $0x1a64,(%esp)
     68f:	e8 75 07 00 00       	call   e09 <strchr>
     694:	85 c0                	test   %eax,%eax
     696:	75 d7                	jne    66f <gettoken+0x112>
    s++;
  *ps = s;
     698:	8b 45 08             	mov    0x8(%ebp),%eax
     69b:	8b 55 f4             	mov    -0xc(%ebp),%edx
     69e:	89 10                	mov    %edx,(%eax)
  return ret;
     6a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     6a3:	c9                   	leave  
     6a4:	c3                   	ret    

000006a5 <peek>:

int
peek(char **ps, char *es, char *toks)
{
     6a5:	55                   	push   %ebp
     6a6:	89 e5                	mov    %esp,%ebp
     6a8:	83 ec 28             	sub    $0x28,%esp
  char *s;
  
  s = *ps;
     6ab:	8b 45 08             	mov    0x8(%ebp),%eax
     6ae:	8b 00                	mov    (%eax),%eax
     6b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     6b3:	eb 04                	jmp    6b9 <peek+0x14>
    s++;
     6b5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
peek(char **ps, char *es, char *toks)
{
  char *s;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     6b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6bc:	3b 45 0c             	cmp    0xc(%ebp),%eax
     6bf:	73 1d                	jae    6de <peek+0x39>
     6c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6c4:	0f b6 00             	movzbl (%eax),%eax
     6c7:	0f be c0             	movsbl %al,%eax
     6ca:	89 44 24 04          	mov    %eax,0x4(%esp)
     6ce:	c7 04 24 64 1a 00 00 	movl   $0x1a64,(%esp)
     6d5:	e8 2f 07 00 00       	call   e09 <strchr>
     6da:	85 c0                	test   %eax,%eax
     6dc:	75 d7                	jne    6b5 <peek+0x10>
    s++;
  *ps = s;
     6de:	8b 45 08             	mov    0x8(%ebp),%eax
     6e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
     6e4:	89 10                	mov    %edx,(%eax)
  return *s && strchr(toks, *s);
     6e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6e9:	0f b6 00             	movzbl (%eax),%eax
     6ec:	84 c0                	test   %al,%al
     6ee:	74 23                	je     713 <peek+0x6e>
     6f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6f3:	0f b6 00             	movzbl (%eax),%eax
     6f6:	0f be c0             	movsbl %al,%eax
     6f9:	89 44 24 04          	mov    %eax,0x4(%esp)
     6fd:	8b 45 10             	mov    0x10(%ebp),%eax
     700:	89 04 24             	mov    %eax,(%esp)
     703:	e8 01 07 00 00       	call   e09 <strchr>
     708:	85 c0                	test   %eax,%eax
     70a:	74 07                	je     713 <peek+0x6e>
     70c:	b8 01 00 00 00       	mov    $0x1,%eax
     711:	eb 05                	jmp    718 <peek+0x73>
     713:	b8 00 00 00 00       	mov    $0x0,%eax
}
     718:	c9                   	leave  
     719:	c3                   	ret    

0000071a <parsecmd>:
struct cmd *parseexec(char**, char*);
struct cmd *nulterminate(struct cmd*);

struct cmd*
parsecmd(char *s)
{
     71a:	55                   	push   %ebp
     71b:	89 e5                	mov    %esp,%ebp
     71d:	53                   	push   %ebx
     71e:	83 ec 24             	sub    $0x24,%esp
  char *es;
  struct cmd *cmd;

  es = s + strlen(s);
     721:	8b 5d 08             	mov    0x8(%ebp),%ebx
     724:	8b 45 08             	mov    0x8(%ebp),%eax
     727:	89 04 24             	mov    %eax,(%esp)
     72a:	e8 8f 06 00 00       	call   dbe <strlen>
     72f:	01 d8                	add    %ebx,%eax
     731:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cmd = parseline(&s, es);
     734:	8b 45 f4             	mov    -0xc(%ebp),%eax
     737:	89 44 24 04          	mov    %eax,0x4(%esp)
     73b:	8d 45 08             	lea    0x8(%ebp),%eax
     73e:	89 04 24             	mov    %eax,(%esp)
     741:	e8 60 00 00 00       	call   7a6 <parseline>
     746:	89 45 f0             	mov    %eax,-0x10(%ebp)
  peek(&s, es, "");
     749:	c7 44 24 08 5a 15 00 	movl   $0x155a,0x8(%esp)
     750:	00 
     751:	8b 45 f4             	mov    -0xc(%ebp),%eax
     754:	89 44 24 04          	mov    %eax,0x4(%esp)
     758:	8d 45 08             	lea    0x8(%ebp),%eax
     75b:	89 04 24             	mov    %eax,(%esp)
     75e:	e8 42 ff ff ff       	call   6a5 <peek>
  if(s != es){
     763:	8b 45 08             	mov    0x8(%ebp),%eax
     766:	3b 45 f4             	cmp    -0xc(%ebp),%eax
     769:	74 27                	je     792 <parsecmd+0x78>
    printf(2, "leftovers: %s\n", s);
     76b:	8b 45 08             	mov    0x8(%ebp),%eax
     76e:	89 44 24 08          	mov    %eax,0x8(%esp)
     772:	c7 44 24 04 5b 15 00 	movl   $0x155b,0x4(%esp)
     779:	00 
     77a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     781:	e8 83 09 00 00       	call   1109 <printf>
    panic("syntax");
     786:	c7 04 24 6a 15 00 00 	movl   $0x156a,(%esp)
     78d:	e8 f0 fb ff ff       	call   382 <panic>
  }
  nulterminate(cmd);
     792:	8b 45 f0             	mov    -0x10(%ebp),%eax
     795:	89 04 24             	mov    %eax,(%esp)
     798:	e8 a5 04 00 00       	call   c42 <nulterminate>
  return cmd;
     79d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     7a0:	83 c4 24             	add    $0x24,%esp
     7a3:	5b                   	pop    %ebx
     7a4:	5d                   	pop    %ebp
     7a5:	c3                   	ret    

000007a6 <parseline>:

struct cmd*
parseline(char **ps, char *es)
{
     7a6:	55                   	push   %ebp
     7a7:	89 e5                	mov    %esp,%ebp
     7a9:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
     7ac:	8b 45 0c             	mov    0xc(%ebp),%eax
     7af:	89 44 24 04          	mov    %eax,0x4(%esp)
     7b3:	8b 45 08             	mov    0x8(%ebp),%eax
     7b6:	89 04 24             	mov    %eax,(%esp)
     7b9:	e8 bc 00 00 00       	call   87a <parsepipe>
     7be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(peek(ps, es, "&")){
     7c1:	eb 30                	jmp    7f3 <parseline+0x4d>
    gettoken(ps, es, 0, 0);
     7c3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     7ca:	00 
     7cb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     7d2:	00 
     7d3:	8b 45 0c             	mov    0xc(%ebp),%eax
     7d6:	89 44 24 04          	mov    %eax,0x4(%esp)
     7da:	8b 45 08             	mov    0x8(%ebp),%eax
     7dd:	89 04 24             	mov    %eax,(%esp)
     7e0:	e8 78 fd ff ff       	call   55d <gettoken>
    cmd = backcmd(cmd);
     7e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
     7e8:	89 04 24             	mov    %eax,(%esp)
     7eb:	e8 26 fd ff ff       	call   516 <backcmd>
     7f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
parseline(char **ps, char *es)
{
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
  while(peek(ps, es, "&")){
     7f3:	c7 44 24 08 71 15 00 	movl   $0x1571,0x8(%esp)
     7fa:	00 
     7fb:	8b 45 0c             	mov    0xc(%ebp),%eax
     7fe:	89 44 24 04          	mov    %eax,0x4(%esp)
     802:	8b 45 08             	mov    0x8(%ebp),%eax
     805:	89 04 24             	mov    %eax,(%esp)
     808:	e8 98 fe ff ff       	call   6a5 <peek>
     80d:	85 c0                	test   %eax,%eax
     80f:	75 b2                	jne    7c3 <parseline+0x1d>
    gettoken(ps, es, 0, 0);
    cmd = backcmd(cmd);
  }
  if(peek(ps, es, ";")){
     811:	c7 44 24 08 73 15 00 	movl   $0x1573,0x8(%esp)
     818:	00 
     819:	8b 45 0c             	mov    0xc(%ebp),%eax
     81c:	89 44 24 04          	mov    %eax,0x4(%esp)
     820:	8b 45 08             	mov    0x8(%ebp),%eax
     823:	89 04 24             	mov    %eax,(%esp)
     826:	e8 7a fe ff ff       	call   6a5 <peek>
     82b:	85 c0                	test   %eax,%eax
     82d:	74 46                	je     875 <parseline+0xcf>
    gettoken(ps, es, 0, 0);
     82f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     836:	00 
     837:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     83e:	00 
     83f:	8b 45 0c             	mov    0xc(%ebp),%eax
     842:	89 44 24 04          	mov    %eax,0x4(%esp)
     846:	8b 45 08             	mov    0x8(%ebp),%eax
     849:	89 04 24             	mov    %eax,(%esp)
     84c:	e8 0c fd ff ff       	call   55d <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     851:	8b 45 0c             	mov    0xc(%ebp),%eax
     854:	89 44 24 04          	mov    %eax,0x4(%esp)
     858:	8b 45 08             	mov    0x8(%ebp),%eax
     85b:	89 04 24             	mov    %eax,(%esp)
     85e:	e8 43 ff ff ff       	call   7a6 <parseline>
     863:	89 44 24 04          	mov    %eax,0x4(%esp)
     867:	8b 45 f4             	mov    -0xc(%ebp),%eax
     86a:	89 04 24             	mov    %eax,(%esp)
     86d:	e8 54 fc ff ff       	call   4c6 <listcmd>
     872:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     875:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     878:	c9                   	leave  
     879:	c3                   	ret    

0000087a <parsepipe>:

struct cmd*
parsepipe(char **ps, char *es)
{
     87a:	55                   	push   %ebp
     87b:	89 e5                	mov    %esp,%ebp
     87d:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  cmd = parseexec(ps, es);
     880:	8b 45 0c             	mov    0xc(%ebp),%eax
     883:	89 44 24 04          	mov    %eax,0x4(%esp)
     887:	8b 45 08             	mov    0x8(%ebp),%eax
     88a:	89 04 24             	mov    %eax,(%esp)
     88d:	e8 68 02 00 00       	call   afa <parseexec>
     892:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(peek(ps, es, "|")){
     895:	c7 44 24 08 75 15 00 	movl   $0x1575,0x8(%esp)
     89c:	00 
     89d:	8b 45 0c             	mov    0xc(%ebp),%eax
     8a0:	89 44 24 04          	mov    %eax,0x4(%esp)
     8a4:	8b 45 08             	mov    0x8(%ebp),%eax
     8a7:	89 04 24             	mov    %eax,(%esp)
     8aa:	e8 f6 fd ff ff       	call   6a5 <peek>
     8af:	85 c0                	test   %eax,%eax
     8b1:	74 46                	je     8f9 <parsepipe+0x7f>
    gettoken(ps, es, 0, 0);
     8b3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     8ba:	00 
     8bb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     8c2:	00 
     8c3:	8b 45 0c             	mov    0xc(%ebp),%eax
     8c6:	89 44 24 04          	mov    %eax,0x4(%esp)
     8ca:	8b 45 08             	mov    0x8(%ebp),%eax
     8cd:	89 04 24             	mov    %eax,(%esp)
     8d0:	e8 88 fc ff ff       	call   55d <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     8d5:	8b 45 0c             	mov    0xc(%ebp),%eax
     8d8:	89 44 24 04          	mov    %eax,0x4(%esp)
     8dc:	8b 45 08             	mov    0x8(%ebp),%eax
     8df:	89 04 24             	mov    %eax,(%esp)
     8e2:	e8 93 ff ff ff       	call   87a <parsepipe>
     8e7:	89 44 24 04          	mov    %eax,0x4(%esp)
     8eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8ee:	89 04 24             	mov    %eax,(%esp)
     8f1:	e8 80 fb ff ff       	call   476 <pipecmd>
     8f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     8f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     8fc:	c9                   	leave  
     8fd:	c3                   	ret    

000008fe <parseredirs>:

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     8fe:	55                   	push   %ebp
     8ff:	89 e5                	mov    %esp,%ebp
     901:	83 ec 38             	sub    $0x38,%esp
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     904:	e9 f6 00 00 00       	jmp    9ff <parseredirs+0x101>
    tok = gettoken(ps, es, 0, 0);
     909:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     910:	00 
     911:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     918:	00 
     919:	8b 45 10             	mov    0x10(%ebp),%eax
     91c:	89 44 24 04          	mov    %eax,0x4(%esp)
     920:	8b 45 0c             	mov    0xc(%ebp),%eax
     923:	89 04 24             	mov    %eax,(%esp)
     926:	e8 32 fc ff ff       	call   55d <gettoken>
     92b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(gettoken(ps, es, &q, &eq) != 'a')
     92e:	8d 45 ec             	lea    -0x14(%ebp),%eax
     931:	89 44 24 0c          	mov    %eax,0xc(%esp)
     935:	8d 45 f0             	lea    -0x10(%ebp),%eax
     938:	89 44 24 08          	mov    %eax,0x8(%esp)
     93c:	8b 45 10             	mov    0x10(%ebp),%eax
     93f:	89 44 24 04          	mov    %eax,0x4(%esp)
     943:	8b 45 0c             	mov    0xc(%ebp),%eax
     946:	89 04 24             	mov    %eax,(%esp)
     949:	e8 0f fc ff ff       	call   55d <gettoken>
     94e:	83 f8 61             	cmp    $0x61,%eax
     951:	74 0c                	je     95f <parseredirs+0x61>
      panic("missing file for redirection");
     953:	c7 04 24 77 15 00 00 	movl   $0x1577,(%esp)
     95a:	e8 23 fa ff ff       	call   382 <panic>
    switch(tok){
     95f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     962:	83 f8 3c             	cmp    $0x3c,%eax
     965:	74 0f                	je     976 <parseredirs+0x78>
     967:	83 f8 3e             	cmp    $0x3e,%eax
     96a:	74 38                	je     9a4 <parseredirs+0xa6>
     96c:	83 f8 2b             	cmp    $0x2b,%eax
     96f:	74 61                	je     9d2 <parseredirs+0xd4>
     971:	e9 89 00 00 00       	jmp    9ff <parseredirs+0x101>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     976:	8b 55 ec             	mov    -0x14(%ebp),%edx
     979:	8b 45 f0             	mov    -0x10(%ebp),%eax
     97c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
     983:	00 
     984:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     98b:	00 
     98c:	89 54 24 08          	mov    %edx,0x8(%esp)
     990:	89 44 24 04          	mov    %eax,0x4(%esp)
     994:	8b 45 08             	mov    0x8(%ebp),%eax
     997:	89 04 24             	mov    %eax,(%esp)
     99a:	e8 6c fa ff ff       	call   40b <redircmd>
     99f:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     9a2:	eb 5b                	jmp    9ff <parseredirs+0x101>
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     9a4:	8b 55 ec             	mov    -0x14(%ebp),%edx
     9a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
     9aa:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     9b1:	00 
     9b2:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     9b9:	00 
     9ba:	89 54 24 08          	mov    %edx,0x8(%esp)
     9be:	89 44 24 04          	mov    %eax,0x4(%esp)
     9c2:	8b 45 08             	mov    0x8(%ebp),%eax
     9c5:	89 04 24             	mov    %eax,(%esp)
     9c8:	e8 3e fa ff ff       	call   40b <redircmd>
     9cd:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     9d0:	eb 2d                	jmp    9ff <parseredirs+0x101>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     9d2:	8b 55 ec             	mov    -0x14(%ebp),%edx
     9d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
     9d8:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     9df:	00 
     9e0:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     9e7:	00 
     9e8:	89 54 24 08          	mov    %edx,0x8(%esp)
     9ec:	89 44 24 04          	mov    %eax,0x4(%esp)
     9f0:	8b 45 08             	mov    0x8(%ebp),%eax
     9f3:	89 04 24             	mov    %eax,(%esp)
     9f6:	e8 10 fa ff ff       	call   40b <redircmd>
     9fb:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     9fe:	90                   	nop
parseredirs(struct cmd *cmd, char **ps, char *es)
{
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     9ff:	c7 44 24 08 94 15 00 	movl   $0x1594,0x8(%esp)
     a06:	00 
     a07:	8b 45 10             	mov    0x10(%ebp),%eax
     a0a:	89 44 24 04          	mov    %eax,0x4(%esp)
     a0e:	8b 45 0c             	mov    0xc(%ebp),%eax
     a11:	89 04 24             	mov    %eax,(%esp)
     a14:	e8 8c fc ff ff       	call   6a5 <peek>
     a19:	85 c0                	test   %eax,%eax
     a1b:	0f 85 e8 fe ff ff    	jne    909 <parseredirs+0xb>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
      break;
    }
  }
  return cmd;
     a21:	8b 45 08             	mov    0x8(%ebp),%eax
}
     a24:	c9                   	leave  
     a25:	c3                   	ret    

00000a26 <parseblock>:

struct cmd*
parseblock(char **ps, char *es)
{
     a26:	55                   	push   %ebp
     a27:	89 e5                	mov    %esp,%ebp
     a29:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  if(!peek(ps, es, "("))
     a2c:	c7 44 24 08 97 15 00 	movl   $0x1597,0x8(%esp)
     a33:	00 
     a34:	8b 45 0c             	mov    0xc(%ebp),%eax
     a37:	89 44 24 04          	mov    %eax,0x4(%esp)
     a3b:	8b 45 08             	mov    0x8(%ebp),%eax
     a3e:	89 04 24             	mov    %eax,(%esp)
     a41:	e8 5f fc ff ff       	call   6a5 <peek>
     a46:	85 c0                	test   %eax,%eax
     a48:	75 0c                	jne    a56 <parseblock+0x30>
    panic("parseblock");
     a4a:	c7 04 24 99 15 00 00 	movl   $0x1599,(%esp)
     a51:	e8 2c f9 ff ff       	call   382 <panic>
  gettoken(ps, es, 0, 0);
     a56:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     a5d:	00 
     a5e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     a65:	00 
     a66:	8b 45 0c             	mov    0xc(%ebp),%eax
     a69:	89 44 24 04          	mov    %eax,0x4(%esp)
     a6d:	8b 45 08             	mov    0x8(%ebp),%eax
     a70:	89 04 24             	mov    %eax,(%esp)
     a73:	e8 e5 fa ff ff       	call   55d <gettoken>
  cmd = parseline(ps, es);
     a78:	8b 45 0c             	mov    0xc(%ebp),%eax
     a7b:	89 44 24 04          	mov    %eax,0x4(%esp)
     a7f:	8b 45 08             	mov    0x8(%ebp),%eax
     a82:	89 04 24             	mov    %eax,(%esp)
     a85:	e8 1c fd ff ff       	call   7a6 <parseline>
     a8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!peek(ps, es, ")"))
     a8d:	c7 44 24 08 a4 15 00 	movl   $0x15a4,0x8(%esp)
     a94:	00 
     a95:	8b 45 0c             	mov    0xc(%ebp),%eax
     a98:	89 44 24 04          	mov    %eax,0x4(%esp)
     a9c:	8b 45 08             	mov    0x8(%ebp),%eax
     a9f:	89 04 24             	mov    %eax,(%esp)
     aa2:	e8 fe fb ff ff       	call   6a5 <peek>
     aa7:	85 c0                	test   %eax,%eax
     aa9:	75 0c                	jne    ab7 <parseblock+0x91>
    panic("syntax - missing )");
     aab:	c7 04 24 a6 15 00 00 	movl   $0x15a6,(%esp)
     ab2:	e8 cb f8 ff ff       	call   382 <panic>
  gettoken(ps, es, 0, 0);
     ab7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     abe:	00 
     abf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     ac6:	00 
     ac7:	8b 45 0c             	mov    0xc(%ebp),%eax
     aca:	89 44 24 04          	mov    %eax,0x4(%esp)
     ace:	8b 45 08             	mov    0x8(%ebp),%eax
     ad1:	89 04 24             	mov    %eax,(%esp)
     ad4:	e8 84 fa ff ff       	call   55d <gettoken>
  cmd = parseredirs(cmd, ps, es);
     ad9:	8b 45 0c             	mov    0xc(%ebp),%eax
     adc:	89 44 24 08          	mov    %eax,0x8(%esp)
     ae0:	8b 45 08             	mov    0x8(%ebp),%eax
     ae3:	89 44 24 04          	mov    %eax,0x4(%esp)
     ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
     aea:	89 04 24             	mov    %eax,(%esp)
     aed:	e8 0c fe ff ff       	call   8fe <parseredirs>
     af2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  return cmd;
     af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     af8:	c9                   	leave  
     af9:	c3                   	ret    

00000afa <parseexec>:

struct cmd*
parseexec(char **ps, char *es)
{
     afa:	55                   	push   %ebp
     afb:	89 e5                	mov    %esp,%ebp
     afd:	83 ec 38             	sub    $0x38,%esp
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;
  
  if(peek(ps, es, "("))
     b00:	c7 44 24 08 97 15 00 	movl   $0x1597,0x8(%esp)
     b07:	00 
     b08:	8b 45 0c             	mov    0xc(%ebp),%eax
     b0b:	89 44 24 04          	mov    %eax,0x4(%esp)
     b0f:	8b 45 08             	mov    0x8(%ebp),%eax
     b12:	89 04 24             	mov    %eax,(%esp)
     b15:	e8 8b fb ff ff       	call   6a5 <peek>
     b1a:	85 c0                	test   %eax,%eax
     b1c:	74 17                	je     b35 <parseexec+0x3b>
    return parseblock(ps, es);
     b1e:	8b 45 0c             	mov    0xc(%ebp),%eax
     b21:	89 44 24 04          	mov    %eax,0x4(%esp)
     b25:	8b 45 08             	mov    0x8(%ebp),%eax
     b28:	89 04 24             	mov    %eax,(%esp)
     b2b:	e8 f6 fe ff ff       	call   a26 <parseblock>
     b30:	e9 0b 01 00 00       	jmp    c40 <parseexec+0x146>

  ret = execcmd();
     b35:	e8 93 f8 ff ff       	call   3cd <execcmd>
     b3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  cmd = (struct execcmd*)ret;
     b3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
     b40:	89 45 ec             	mov    %eax,-0x14(%ebp)

  argc = 0;
     b43:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  ret = parseredirs(ret, ps, es);
     b4a:	8b 45 0c             	mov    0xc(%ebp),%eax
     b4d:	89 44 24 08          	mov    %eax,0x8(%esp)
     b51:	8b 45 08             	mov    0x8(%ebp),%eax
     b54:	89 44 24 04          	mov    %eax,0x4(%esp)
     b58:	8b 45 f0             	mov    -0x10(%ebp),%eax
     b5b:	89 04 24             	mov    %eax,(%esp)
     b5e:	e8 9b fd ff ff       	call   8fe <parseredirs>
     b63:	89 45 f0             	mov    %eax,-0x10(%ebp)
  while(!peek(ps, es, "|)&;")){
     b66:	e9 8e 00 00 00       	jmp    bf9 <parseexec+0xff>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     b6b:	8d 45 e0             	lea    -0x20(%ebp),%eax
     b6e:	89 44 24 0c          	mov    %eax,0xc(%esp)
     b72:	8d 45 e4             	lea    -0x1c(%ebp),%eax
     b75:	89 44 24 08          	mov    %eax,0x8(%esp)
     b79:	8b 45 0c             	mov    0xc(%ebp),%eax
     b7c:	89 44 24 04          	mov    %eax,0x4(%esp)
     b80:	8b 45 08             	mov    0x8(%ebp),%eax
     b83:	89 04 24             	mov    %eax,(%esp)
     b86:	e8 d2 f9 ff ff       	call   55d <gettoken>
     b8b:	89 45 e8             	mov    %eax,-0x18(%ebp)
     b8e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     b92:	0f 84 85 00 00 00    	je     c1d <parseexec+0x123>
      break;
    if(tok != 'a')
     b98:	83 7d e8 61          	cmpl   $0x61,-0x18(%ebp)
     b9c:	74 0c                	je     baa <parseexec+0xb0>
      panic("syntax");
     b9e:	c7 04 24 6a 15 00 00 	movl   $0x156a,(%esp)
     ba5:	e8 d8 f7 ff ff       	call   382 <panic>
    cmd->argv[argc] = q;
     baa:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
     bad:	8b 45 ec             	mov    -0x14(%ebp),%eax
     bb0:	8b 55 f4             	mov    -0xc(%ebp),%edx
     bb3:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
    cmd->eargv[argc] = eq;
     bb7:	8b 55 e0             	mov    -0x20(%ebp),%edx
     bba:	8b 45 ec             	mov    -0x14(%ebp),%eax
     bbd:	8b 4d f4             	mov    -0xc(%ebp),%ecx
     bc0:	83 c1 08             	add    $0x8,%ecx
     bc3:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    argc++;
     bc7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(argc >= MAXARGS)
     bcb:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     bcf:	7e 0c                	jle    bdd <parseexec+0xe3>
      panic("too many args");
     bd1:	c7 04 24 b9 15 00 00 	movl   $0x15b9,(%esp)
     bd8:	e8 a5 f7 ff ff       	call   382 <panic>
    ret = parseredirs(ret, ps, es);
     bdd:	8b 45 0c             	mov    0xc(%ebp),%eax
     be0:	89 44 24 08          	mov    %eax,0x8(%esp)
     be4:	8b 45 08             	mov    0x8(%ebp),%eax
     be7:	89 44 24 04          	mov    %eax,0x4(%esp)
     beb:	8b 45 f0             	mov    -0x10(%ebp),%eax
     bee:	89 04 24             	mov    %eax,(%esp)
     bf1:	e8 08 fd ff ff       	call   8fe <parseredirs>
     bf6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  ret = execcmd();
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
  while(!peek(ps, es, "|)&;")){
     bf9:	c7 44 24 08 c7 15 00 	movl   $0x15c7,0x8(%esp)
     c00:	00 
     c01:	8b 45 0c             	mov    0xc(%ebp),%eax
     c04:	89 44 24 04          	mov    %eax,0x4(%esp)
     c08:	8b 45 08             	mov    0x8(%ebp),%eax
     c0b:	89 04 24             	mov    %eax,(%esp)
     c0e:	e8 92 fa ff ff       	call   6a5 <peek>
     c13:	85 c0                	test   %eax,%eax
     c15:	0f 84 50 ff ff ff    	je     b6b <parseexec+0x71>
     c1b:	eb 01                	jmp    c1e <parseexec+0x124>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
     c1d:	90                   	nop
    argc++;
    if(argc >= MAXARGS)
      panic("too many args");
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
     c1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c21:	8b 55 f4             	mov    -0xc(%ebp),%edx
     c24:	c7 44 90 04 00 00 00 	movl   $0x0,0x4(%eax,%edx,4)
     c2b:	00 
  cmd->eargv[argc] = 0;
     c2c:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c2f:	8b 55 f4             	mov    -0xc(%ebp),%edx
     c32:	83 c2 08             	add    $0x8,%edx
     c35:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
     c3c:	00 
  return ret;
     c3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     c40:	c9                   	leave  
     c41:	c3                   	ret    

00000c42 <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     c42:	55                   	push   %ebp
     c43:	89 e5                	mov    %esp,%ebp
     c45:	83 ec 38             	sub    $0x38,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     c48:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
     c4c:	75 0a                	jne    c58 <nulterminate+0x16>
    return 0;
     c4e:	b8 00 00 00 00       	mov    $0x0,%eax
     c53:	e9 c9 00 00 00       	jmp    d21 <nulterminate+0xdf>
  
  switch(cmd->type){
     c58:	8b 45 08             	mov    0x8(%ebp),%eax
     c5b:	8b 00                	mov    (%eax),%eax
     c5d:	83 f8 05             	cmp    $0x5,%eax
     c60:	0f 87 b8 00 00 00    	ja     d1e <nulterminate+0xdc>
     c66:	8b 04 85 cc 15 00 00 	mov    0x15cc(,%eax,4),%eax
     c6d:	ff e0                	jmp    *%eax
  case EXEC:
    ecmd = (struct execcmd*)cmd;
     c6f:	8b 45 08             	mov    0x8(%ebp),%eax
     c72:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for(i=0; ecmd->argv[i]; i++)
     c75:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     c7c:	eb 14                	jmp    c92 <nulterminate+0x50>
      *ecmd->eargv[i] = 0;
     c7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
     c81:	8b 55 f4             	mov    -0xc(%ebp),%edx
     c84:	83 c2 08             	add    $0x8,%edx
     c87:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
     c8b:	c6 00 00             	movb   $0x0,(%eax)
    return 0;
  
  switch(cmd->type){
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     c8e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     c92:	8b 45 f0             	mov    -0x10(%ebp),%eax
     c95:	8b 55 f4             	mov    -0xc(%ebp),%edx
     c98:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
     c9c:	85 c0                	test   %eax,%eax
     c9e:	75 de                	jne    c7e <nulterminate+0x3c>
      *ecmd->eargv[i] = 0;
    break;
     ca0:	eb 7c                	jmp    d1e <nulterminate+0xdc>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
     ca2:	8b 45 08             	mov    0x8(%ebp),%eax
     ca5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    nulterminate(rcmd->cmd);
     ca8:	8b 45 ec             	mov    -0x14(%ebp),%eax
     cab:	8b 40 04             	mov    0x4(%eax),%eax
     cae:	89 04 24             	mov    %eax,(%esp)
     cb1:	e8 8c ff ff ff       	call   c42 <nulterminate>
    *rcmd->efile = 0;
     cb6:	8b 45 ec             	mov    -0x14(%ebp),%eax
     cb9:	8b 40 0c             	mov    0xc(%eax),%eax
     cbc:	c6 00 00             	movb   $0x0,(%eax)
    break;
     cbf:	eb 5d                	jmp    d1e <nulterminate+0xdc>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     cc1:	8b 45 08             	mov    0x8(%ebp),%eax
     cc4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nulterminate(pcmd->left);
     cc7:	8b 45 e8             	mov    -0x18(%ebp),%eax
     cca:	8b 40 04             	mov    0x4(%eax),%eax
     ccd:	89 04 24             	mov    %eax,(%esp)
     cd0:	e8 6d ff ff ff       	call   c42 <nulterminate>
    nulterminate(pcmd->right);
     cd5:	8b 45 e8             	mov    -0x18(%ebp),%eax
     cd8:	8b 40 08             	mov    0x8(%eax),%eax
     cdb:	89 04 24             	mov    %eax,(%esp)
     cde:	e8 5f ff ff ff       	call   c42 <nulterminate>
    break;
     ce3:	eb 39                	jmp    d1e <nulterminate+0xdc>
    
  case LIST:
    lcmd = (struct listcmd*)cmd;
     ce5:	8b 45 08             	mov    0x8(%ebp),%eax
     ce8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nulterminate(lcmd->left);
     ceb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     cee:	8b 40 04             	mov    0x4(%eax),%eax
     cf1:	89 04 24             	mov    %eax,(%esp)
     cf4:	e8 49 ff ff ff       	call   c42 <nulterminate>
    nulterminate(lcmd->right);
     cf9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     cfc:	8b 40 08             	mov    0x8(%eax),%eax
     cff:	89 04 24             	mov    %eax,(%esp)
     d02:	e8 3b ff ff ff       	call   c42 <nulterminate>
    break;
     d07:	eb 15                	jmp    d1e <nulterminate+0xdc>

  case BACK:
    bcmd = (struct backcmd*)cmd;
     d09:	8b 45 08             	mov    0x8(%ebp),%eax
     d0c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nulterminate(bcmd->cmd);
     d0f:	8b 45 e0             	mov    -0x20(%ebp),%eax
     d12:	8b 40 04             	mov    0x4(%eax),%eax
     d15:	89 04 24             	mov    %eax,(%esp)
     d18:	e8 25 ff ff ff       	call   c42 <nulterminate>
    break;
     d1d:	90                   	nop
  }
  return cmd;
     d1e:	8b 45 08             	mov    0x8(%ebp),%eax
}
     d21:	c9                   	leave  
     d22:	c3                   	ret    
     d23:	90                   	nop

00000d24 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
     d24:	55                   	push   %ebp
     d25:	89 e5                	mov    %esp,%ebp
     d27:	57                   	push   %edi
     d28:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
     d29:	8b 4d 08             	mov    0x8(%ebp),%ecx
     d2c:	8b 55 10             	mov    0x10(%ebp),%edx
     d2f:	8b 45 0c             	mov    0xc(%ebp),%eax
     d32:	89 cb                	mov    %ecx,%ebx
     d34:	89 df                	mov    %ebx,%edi
     d36:	89 d1                	mov    %edx,%ecx
     d38:	fc                   	cld    
     d39:	f3 aa                	rep stos %al,%es:(%edi)
     d3b:	89 ca                	mov    %ecx,%edx
     d3d:	89 fb                	mov    %edi,%ebx
     d3f:	89 5d 08             	mov    %ebx,0x8(%ebp)
     d42:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
     d45:	5b                   	pop    %ebx
     d46:	5f                   	pop    %edi
     d47:	5d                   	pop    %ebp
     d48:	c3                   	ret    

00000d49 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
     d49:	55                   	push   %ebp
     d4a:	89 e5                	mov    %esp,%ebp
     d4c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
     d4f:	8b 45 08             	mov    0x8(%ebp),%eax
     d52:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
     d55:	90                   	nop
     d56:	8b 45 0c             	mov    0xc(%ebp),%eax
     d59:	0f b6 10             	movzbl (%eax),%edx
     d5c:	8b 45 08             	mov    0x8(%ebp),%eax
     d5f:	88 10                	mov    %dl,(%eax)
     d61:	8b 45 08             	mov    0x8(%ebp),%eax
     d64:	0f b6 00             	movzbl (%eax),%eax
     d67:	84 c0                	test   %al,%al
     d69:	0f 95 c0             	setne  %al
     d6c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     d70:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
     d74:	84 c0                	test   %al,%al
     d76:	75 de                	jne    d56 <strcpy+0xd>
    ;
  return os;
     d78:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     d7b:	c9                   	leave  
     d7c:	c3                   	ret    

00000d7d <strcmp>:

int
strcmp(const char *p, const char *q)
{
     d7d:	55                   	push   %ebp
     d7e:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
     d80:	eb 08                	jmp    d8a <strcmp+0xd>
    p++, q++;
     d82:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     d86:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
     d8a:	8b 45 08             	mov    0x8(%ebp),%eax
     d8d:	0f b6 00             	movzbl (%eax),%eax
     d90:	84 c0                	test   %al,%al
     d92:	74 10                	je     da4 <strcmp+0x27>
     d94:	8b 45 08             	mov    0x8(%ebp),%eax
     d97:	0f b6 10             	movzbl (%eax),%edx
     d9a:	8b 45 0c             	mov    0xc(%ebp),%eax
     d9d:	0f b6 00             	movzbl (%eax),%eax
     da0:	38 c2                	cmp    %al,%dl
     da2:	74 de                	je     d82 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
     da4:	8b 45 08             	mov    0x8(%ebp),%eax
     da7:	0f b6 00             	movzbl (%eax),%eax
     daa:	0f b6 d0             	movzbl %al,%edx
     dad:	8b 45 0c             	mov    0xc(%ebp),%eax
     db0:	0f b6 00             	movzbl (%eax),%eax
     db3:	0f b6 c0             	movzbl %al,%eax
     db6:	89 d1                	mov    %edx,%ecx
     db8:	29 c1                	sub    %eax,%ecx
     dba:	89 c8                	mov    %ecx,%eax
}
     dbc:	5d                   	pop    %ebp
     dbd:	c3                   	ret    

00000dbe <strlen>:

uint
strlen(char *s)
{
     dbe:	55                   	push   %ebp
     dbf:	89 e5                	mov    %esp,%ebp
     dc1:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
     dc4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
     dcb:	eb 04                	jmp    dd1 <strlen+0x13>
     dcd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
     dd1:	8b 55 fc             	mov    -0x4(%ebp),%edx
     dd4:	8b 45 08             	mov    0x8(%ebp),%eax
     dd7:	01 d0                	add    %edx,%eax
     dd9:	0f b6 00             	movzbl (%eax),%eax
     ddc:	84 c0                	test   %al,%al
     dde:	75 ed                	jne    dcd <strlen+0xf>
    ;
  return n;
     de0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     de3:	c9                   	leave  
     de4:	c3                   	ret    

00000de5 <memset>:

void*
memset(void *dst, int c, uint n)
{
     de5:	55                   	push   %ebp
     de6:	89 e5                	mov    %esp,%ebp
     de8:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
     deb:	8b 45 10             	mov    0x10(%ebp),%eax
     dee:	89 44 24 08          	mov    %eax,0x8(%esp)
     df2:	8b 45 0c             	mov    0xc(%ebp),%eax
     df5:	89 44 24 04          	mov    %eax,0x4(%esp)
     df9:	8b 45 08             	mov    0x8(%ebp),%eax
     dfc:	89 04 24             	mov    %eax,(%esp)
     dff:	e8 20 ff ff ff       	call   d24 <stosb>
  return dst;
     e04:	8b 45 08             	mov    0x8(%ebp),%eax
}
     e07:	c9                   	leave  
     e08:	c3                   	ret    

00000e09 <strchr>:

char*
strchr(const char *s, char c)
{
     e09:	55                   	push   %ebp
     e0a:	89 e5                	mov    %esp,%ebp
     e0c:	83 ec 04             	sub    $0x4,%esp
     e0f:	8b 45 0c             	mov    0xc(%ebp),%eax
     e12:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
     e15:	eb 14                	jmp    e2b <strchr+0x22>
    if(*s == c)
     e17:	8b 45 08             	mov    0x8(%ebp),%eax
     e1a:	0f b6 00             	movzbl (%eax),%eax
     e1d:	3a 45 fc             	cmp    -0x4(%ebp),%al
     e20:	75 05                	jne    e27 <strchr+0x1e>
      return (char*)s;
     e22:	8b 45 08             	mov    0x8(%ebp),%eax
     e25:	eb 13                	jmp    e3a <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
     e27:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     e2b:	8b 45 08             	mov    0x8(%ebp),%eax
     e2e:	0f b6 00             	movzbl (%eax),%eax
     e31:	84 c0                	test   %al,%al
     e33:	75 e2                	jne    e17 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
     e35:	b8 00 00 00 00       	mov    $0x0,%eax
}
     e3a:	c9                   	leave  
     e3b:	c3                   	ret    

00000e3c <gets>:

char*
gets(char *buf, int max)
{
     e3c:	55                   	push   %ebp
     e3d:	89 e5                	mov    %esp,%ebp
     e3f:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     e42:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     e49:	eb 46                	jmp    e91 <gets+0x55>
    cc = read(0, &c, 1);
     e4b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     e52:	00 
     e53:	8d 45 ef             	lea    -0x11(%ebp),%eax
     e56:	89 44 24 04          	mov    %eax,0x4(%esp)
     e5a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     e61:	e8 3e 01 00 00       	call   fa4 <read>
     e66:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
     e69:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     e6d:	7e 2f                	jle    e9e <gets+0x62>
      break;
    buf[i++] = c;
     e6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
     e72:	8b 45 08             	mov    0x8(%ebp),%eax
     e75:	01 c2                	add    %eax,%edx
     e77:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     e7b:	88 02                	mov    %al,(%edx)
     e7d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
     e81:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     e85:	3c 0a                	cmp    $0xa,%al
     e87:	74 16                	je     e9f <gets+0x63>
     e89:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     e8d:	3c 0d                	cmp    $0xd,%al
     e8f:	74 0e                	je     e9f <gets+0x63>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     e91:	8b 45 f4             	mov    -0xc(%ebp),%eax
     e94:	83 c0 01             	add    $0x1,%eax
     e97:	3b 45 0c             	cmp    0xc(%ebp),%eax
     e9a:	7c af                	jl     e4b <gets+0xf>
     e9c:	eb 01                	jmp    e9f <gets+0x63>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
     e9e:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
     e9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
     ea2:	8b 45 08             	mov    0x8(%ebp),%eax
     ea5:	01 d0                	add    %edx,%eax
     ea7:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
     eaa:	8b 45 08             	mov    0x8(%ebp),%eax
}
     ead:	c9                   	leave  
     eae:	c3                   	ret    

00000eaf <stat>:

int
stat(char *n, struct stat *st)
{
     eaf:	55                   	push   %ebp
     eb0:	89 e5                	mov    %esp,%ebp
     eb2:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     eb5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     ebc:	00 
     ebd:	8b 45 08             	mov    0x8(%ebp),%eax
     ec0:	89 04 24             	mov    %eax,(%esp)
     ec3:	e8 04 01 00 00       	call   fcc <open>
     ec8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
     ecb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     ecf:	79 07                	jns    ed8 <stat+0x29>
    return -1;
     ed1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     ed6:	eb 23                	jmp    efb <stat+0x4c>
  r = fstat(fd, st);
     ed8:	8b 45 0c             	mov    0xc(%ebp),%eax
     edb:	89 44 24 04          	mov    %eax,0x4(%esp)
     edf:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ee2:	89 04 24             	mov    %eax,(%esp)
     ee5:	e8 fa 00 00 00       	call   fe4 <fstat>
     eea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
     eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ef0:	89 04 24             	mov    %eax,(%esp)
     ef3:	e8 bc 00 00 00       	call   fb4 <close>
  return r;
     ef8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     efb:	c9                   	leave  
     efc:	c3                   	ret    

00000efd <atoi>:

int
atoi(const char *s)
{
     efd:	55                   	push   %ebp
     efe:	89 e5                	mov    %esp,%ebp
     f00:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
     f03:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
     f0a:	eb 23                	jmp    f2f <atoi+0x32>
    n = n*10 + *s++ - '0';
     f0c:	8b 55 fc             	mov    -0x4(%ebp),%edx
     f0f:	89 d0                	mov    %edx,%eax
     f11:	c1 e0 02             	shl    $0x2,%eax
     f14:	01 d0                	add    %edx,%eax
     f16:	01 c0                	add    %eax,%eax
     f18:	89 c2                	mov    %eax,%edx
     f1a:	8b 45 08             	mov    0x8(%ebp),%eax
     f1d:	0f b6 00             	movzbl (%eax),%eax
     f20:	0f be c0             	movsbl %al,%eax
     f23:	01 d0                	add    %edx,%eax
     f25:	83 e8 30             	sub    $0x30,%eax
     f28:	89 45 fc             	mov    %eax,-0x4(%ebp)
     f2b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     f2f:	8b 45 08             	mov    0x8(%ebp),%eax
     f32:	0f b6 00             	movzbl (%eax),%eax
     f35:	3c 2f                	cmp    $0x2f,%al
     f37:	7e 0a                	jle    f43 <atoi+0x46>
     f39:	8b 45 08             	mov    0x8(%ebp),%eax
     f3c:	0f b6 00             	movzbl (%eax),%eax
     f3f:	3c 39                	cmp    $0x39,%al
     f41:	7e c9                	jle    f0c <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
     f43:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     f46:	c9                   	leave  
     f47:	c3                   	ret    

00000f48 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
     f48:	55                   	push   %ebp
     f49:	89 e5                	mov    %esp,%ebp
     f4b:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
     f4e:	8b 45 08             	mov    0x8(%ebp),%eax
     f51:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
     f54:	8b 45 0c             	mov    0xc(%ebp),%eax
     f57:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
     f5a:	eb 13                	jmp    f6f <memmove+0x27>
    *dst++ = *src++;
     f5c:	8b 45 f8             	mov    -0x8(%ebp),%eax
     f5f:	0f b6 10             	movzbl (%eax),%edx
     f62:	8b 45 fc             	mov    -0x4(%ebp),%eax
     f65:	88 10                	mov    %dl,(%eax)
     f67:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
     f6b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
     f6f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     f73:	0f 9f c0             	setg   %al
     f76:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
     f7a:	84 c0                	test   %al,%al
     f7c:	75 de                	jne    f5c <memmove+0x14>
    *dst++ = *src++;
  return vdst;
     f7e:	8b 45 08             	mov    0x8(%ebp),%eax
}
     f81:	c9                   	leave  
     f82:	c3                   	ret    
     f83:	90                   	nop

00000f84 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
     f84:	b8 01 00 00 00       	mov    $0x1,%eax
     f89:	cd 40                	int    $0x40
     f8b:	c3                   	ret    

00000f8c <exit>:
SYSCALL(exit)
     f8c:	b8 02 00 00 00       	mov    $0x2,%eax
     f91:	cd 40                	int    $0x40
     f93:	c3                   	ret    

00000f94 <wait>:
SYSCALL(wait)
     f94:	b8 03 00 00 00       	mov    $0x3,%eax
     f99:	cd 40                	int    $0x40
     f9b:	c3                   	ret    

00000f9c <pipe>:
SYSCALL(pipe)
     f9c:	b8 04 00 00 00       	mov    $0x4,%eax
     fa1:	cd 40                	int    $0x40
     fa3:	c3                   	ret    

00000fa4 <read>:
SYSCALL(read)
     fa4:	b8 05 00 00 00       	mov    $0x5,%eax
     fa9:	cd 40                	int    $0x40
     fab:	c3                   	ret    

00000fac <write>:
SYSCALL(write)
     fac:	b8 10 00 00 00       	mov    $0x10,%eax
     fb1:	cd 40                	int    $0x40
     fb3:	c3                   	ret    

00000fb4 <close>:
SYSCALL(close)
     fb4:	b8 15 00 00 00       	mov    $0x15,%eax
     fb9:	cd 40                	int    $0x40
     fbb:	c3                   	ret    

00000fbc <kill>:
SYSCALL(kill)
     fbc:	b8 06 00 00 00       	mov    $0x6,%eax
     fc1:	cd 40                	int    $0x40
     fc3:	c3                   	ret    

00000fc4 <exec>:
SYSCALL(exec)
     fc4:	b8 07 00 00 00       	mov    $0x7,%eax
     fc9:	cd 40                	int    $0x40
     fcb:	c3                   	ret    

00000fcc <open>:
SYSCALL(open)
     fcc:	b8 0f 00 00 00       	mov    $0xf,%eax
     fd1:	cd 40                	int    $0x40
     fd3:	c3                   	ret    

00000fd4 <mknod>:
SYSCALL(mknod)
     fd4:	b8 11 00 00 00       	mov    $0x11,%eax
     fd9:	cd 40                	int    $0x40
     fdb:	c3                   	ret    

00000fdc <unlink>:
SYSCALL(unlink)
     fdc:	b8 12 00 00 00       	mov    $0x12,%eax
     fe1:	cd 40                	int    $0x40
     fe3:	c3                   	ret    

00000fe4 <fstat>:
SYSCALL(fstat)
     fe4:	b8 08 00 00 00       	mov    $0x8,%eax
     fe9:	cd 40                	int    $0x40
     feb:	c3                   	ret    

00000fec <link>:
SYSCALL(link)
     fec:	b8 13 00 00 00       	mov    $0x13,%eax
     ff1:	cd 40                	int    $0x40
     ff3:	c3                   	ret    

00000ff4 <mkdir>:
SYSCALL(mkdir)
     ff4:	b8 14 00 00 00       	mov    $0x14,%eax
     ff9:	cd 40                	int    $0x40
     ffb:	c3                   	ret    

00000ffc <chdir>:
SYSCALL(chdir)
     ffc:	b8 09 00 00 00       	mov    $0x9,%eax
    1001:	cd 40                	int    $0x40
    1003:	c3                   	ret    

00001004 <dup>:
SYSCALL(dup)
    1004:	b8 0a 00 00 00       	mov    $0xa,%eax
    1009:	cd 40                	int    $0x40
    100b:	c3                   	ret    

0000100c <getpid>:
SYSCALL(getpid)
    100c:	b8 0b 00 00 00       	mov    $0xb,%eax
    1011:	cd 40                	int    $0x40
    1013:	c3                   	ret    

00001014 <sbrk>:
SYSCALL(sbrk)
    1014:	b8 0c 00 00 00       	mov    $0xc,%eax
    1019:	cd 40                	int    $0x40
    101b:	c3                   	ret    

0000101c <sleep>:
SYSCALL(sleep)
    101c:	b8 0d 00 00 00       	mov    $0xd,%eax
    1021:	cd 40                	int    $0x40
    1023:	c3                   	ret    

00001024 <uptime>:
SYSCALL(uptime)
    1024:	b8 0e 00 00 00       	mov    $0xe,%eax
    1029:	cd 40                	int    $0x40
    102b:	c3                   	ret    

0000102c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    102c:	55                   	push   %ebp
    102d:	89 e5                	mov    %esp,%ebp
    102f:	83 ec 28             	sub    $0x28,%esp
    1032:	8b 45 0c             	mov    0xc(%ebp),%eax
    1035:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    1038:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    103f:	00 
    1040:	8d 45 f4             	lea    -0xc(%ebp),%eax
    1043:	89 44 24 04          	mov    %eax,0x4(%esp)
    1047:	8b 45 08             	mov    0x8(%ebp),%eax
    104a:	89 04 24             	mov    %eax,(%esp)
    104d:	e8 5a ff ff ff       	call   fac <write>
}
    1052:	c9                   	leave  
    1053:	c3                   	ret    

00001054 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    1054:	55                   	push   %ebp
    1055:	89 e5                	mov    %esp,%ebp
    1057:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    105a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    1061:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    1065:	74 17                	je     107e <printint+0x2a>
    1067:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    106b:	79 11                	jns    107e <printint+0x2a>
    neg = 1;
    106d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    1074:	8b 45 0c             	mov    0xc(%ebp),%eax
    1077:	f7 d8                	neg    %eax
    1079:	89 45 ec             	mov    %eax,-0x14(%ebp)
    107c:	eb 06                	jmp    1084 <printint+0x30>
  } else {
    x = xx;
    107e:	8b 45 0c             	mov    0xc(%ebp),%eax
    1081:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    1084:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    108b:	8b 4d 10             	mov    0x10(%ebp),%ecx
    108e:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1091:	ba 00 00 00 00       	mov    $0x0,%edx
    1096:	f7 f1                	div    %ecx
    1098:	89 d0                	mov    %edx,%eax
    109a:	0f b6 80 74 1a 00 00 	movzbl 0x1a74(%eax),%eax
    10a1:	8d 4d dc             	lea    -0x24(%ebp),%ecx
    10a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
    10a7:	01 ca                	add    %ecx,%edx
    10a9:	88 02                	mov    %al,(%edx)
    10ab:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
    10af:	8b 55 10             	mov    0x10(%ebp),%edx
    10b2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    10b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
    10b8:	ba 00 00 00 00       	mov    $0x0,%edx
    10bd:	f7 75 d4             	divl   -0x2c(%ebp)
    10c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    10c3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    10c7:	75 c2                	jne    108b <printint+0x37>
  if(neg)
    10c9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    10cd:	74 2e                	je     10fd <printint+0xa9>
    buf[i++] = '-';
    10cf:	8d 55 dc             	lea    -0x24(%ebp),%edx
    10d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    10d5:	01 d0                	add    %edx,%eax
    10d7:	c6 00 2d             	movb   $0x2d,(%eax)
    10da:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
    10de:	eb 1d                	jmp    10fd <printint+0xa9>
    putc(fd, buf[i]);
    10e0:	8d 55 dc             	lea    -0x24(%ebp),%edx
    10e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    10e6:	01 d0                	add    %edx,%eax
    10e8:	0f b6 00             	movzbl (%eax),%eax
    10eb:	0f be c0             	movsbl %al,%eax
    10ee:	89 44 24 04          	mov    %eax,0x4(%esp)
    10f2:	8b 45 08             	mov    0x8(%ebp),%eax
    10f5:	89 04 24             	mov    %eax,(%esp)
    10f8:	e8 2f ff ff ff       	call   102c <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    10fd:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    1101:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1105:	79 d9                	jns    10e0 <printint+0x8c>
    putc(fd, buf[i]);
}
    1107:	c9                   	leave  
    1108:	c3                   	ret    

00001109 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    1109:	55                   	push   %ebp
    110a:	89 e5                	mov    %esp,%ebp
    110c:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    110f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    1116:	8d 45 0c             	lea    0xc(%ebp),%eax
    1119:	83 c0 04             	add    $0x4,%eax
    111c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    111f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1126:	e9 7d 01 00 00       	jmp    12a8 <printf+0x19f>
    c = fmt[i] & 0xff;
    112b:	8b 55 0c             	mov    0xc(%ebp),%edx
    112e:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1131:	01 d0                	add    %edx,%eax
    1133:	0f b6 00             	movzbl (%eax),%eax
    1136:	0f be c0             	movsbl %al,%eax
    1139:	25 ff 00 00 00       	and    $0xff,%eax
    113e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    1141:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1145:	75 2c                	jne    1173 <printf+0x6a>
      if(c == '%'){
    1147:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    114b:	75 0c                	jne    1159 <printf+0x50>
        state = '%';
    114d:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    1154:	e9 4b 01 00 00       	jmp    12a4 <printf+0x19b>
      } else {
        putc(fd, c);
    1159:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    115c:	0f be c0             	movsbl %al,%eax
    115f:	89 44 24 04          	mov    %eax,0x4(%esp)
    1163:	8b 45 08             	mov    0x8(%ebp),%eax
    1166:	89 04 24             	mov    %eax,(%esp)
    1169:	e8 be fe ff ff       	call   102c <putc>
    116e:	e9 31 01 00 00       	jmp    12a4 <printf+0x19b>
      }
    } else if(state == '%'){
    1173:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    1177:	0f 85 27 01 00 00    	jne    12a4 <printf+0x19b>
      if(c == 'd'){
    117d:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    1181:	75 2d                	jne    11b0 <printf+0xa7>
        printint(fd, *ap, 10, 1);
    1183:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1186:	8b 00                	mov    (%eax),%eax
    1188:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    118f:	00 
    1190:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    1197:	00 
    1198:	89 44 24 04          	mov    %eax,0x4(%esp)
    119c:	8b 45 08             	mov    0x8(%ebp),%eax
    119f:	89 04 24             	mov    %eax,(%esp)
    11a2:	e8 ad fe ff ff       	call   1054 <printint>
        ap++;
    11a7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    11ab:	e9 ed 00 00 00       	jmp    129d <printf+0x194>
      } else if(c == 'x' || c == 'p'){
    11b0:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    11b4:	74 06                	je     11bc <printf+0xb3>
    11b6:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    11ba:	75 2d                	jne    11e9 <printf+0xe0>
        printint(fd, *ap, 16, 0);
    11bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
    11bf:	8b 00                	mov    (%eax),%eax
    11c1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    11c8:	00 
    11c9:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    11d0:	00 
    11d1:	89 44 24 04          	mov    %eax,0x4(%esp)
    11d5:	8b 45 08             	mov    0x8(%ebp),%eax
    11d8:	89 04 24             	mov    %eax,(%esp)
    11db:	e8 74 fe ff ff       	call   1054 <printint>
        ap++;
    11e0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    11e4:	e9 b4 00 00 00       	jmp    129d <printf+0x194>
      } else if(c == 's'){
    11e9:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    11ed:	75 46                	jne    1235 <printf+0x12c>
        s = (char*)*ap;
    11ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
    11f2:	8b 00                	mov    (%eax),%eax
    11f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    11f7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    11fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    11ff:	75 27                	jne    1228 <printf+0x11f>
          s = "(null)";
    1201:	c7 45 f4 e4 15 00 00 	movl   $0x15e4,-0xc(%ebp)
        while(*s != 0){
    1208:	eb 1e                	jmp    1228 <printf+0x11f>
          putc(fd, *s);
    120a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    120d:	0f b6 00             	movzbl (%eax),%eax
    1210:	0f be c0             	movsbl %al,%eax
    1213:	89 44 24 04          	mov    %eax,0x4(%esp)
    1217:	8b 45 08             	mov    0x8(%ebp),%eax
    121a:	89 04 24             	mov    %eax,(%esp)
    121d:	e8 0a fe ff ff       	call   102c <putc>
          s++;
    1222:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1226:	eb 01                	jmp    1229 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    1228:	90                   	nop
    1229:	8b 45 f4             	mov    -0xc(%ebp),%eax
    122c:	0f b6 00             	movzbl (%eax),%eax
    122f:	84 c0                	test   %al,%al
    1231:	75 d7                	jne    120a <printf+0x101>
    1233:	eb 68                	jmp    129d <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1235:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    1239:	75 1d                	jne    1258 <printf+0x14f>
        putc(fd, *ap);
    123b:	8b 45 e8             	mov    -0x18(%ebp),%eax
    123e:	8b 00                	mov    (%eax),%eax
    1240:	0f be c0             	movsbl %al,%eax
    1243:	89 44 24 04          	mov    %eax,0x4(%esp)
    1247:	8b 45 08             	mov    0x8(%ebp),%eax
    124a:	89 04 24             	mov    %eax,(%esp)
    124d:	e8 da fd ff ff       	call   102c <putc>
        ap++;
    1252:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1256:	eb 45                	jmp    129d <printf+0x194>
      } else if(c == '%'){
    1258:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    125c:	75 17                	jne    1275 <printf+0x16c>
        putc(fd, c);
    125e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1261:	0f be c0             	movsbl %al,%eax
    1264:	89 44 24 04          	mov    %eax,0x4(%esp)
    1268:	8b 45 08             	mov    0x8(%ebp),%eax
    126b:	89 04 24             	mov    %eax,(%esp)
    126e:	e8 b9 fd ff ff       	call   102c <putc>
    1273:	eb 28                	jmp    129d <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    1275:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    127c:	00 
    127d:	8b 45 08             	mov    0x8(%ebp),%eax
    1280:	89 04 24             	mov    %eax,(%esp)
    1283:	e8 a4 fd ff ff       	call   102c <putc>
        putc(fd, c);
    1288:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    128b:	0f be c0             	movsbl %al,%eax
    128e:	89 44 24 04          	mov    %eax,0x4(%esp)
    1292:	8b 45 08             	mov    0x8(%ebp),%eax
    1295:	89 04 24             	mov    %eax,(%esp)
    1298:	e8 8f fd ff ff       	call   102c <putc>
      }
      state = 0;
    129d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    12a4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    12a8:	8b 55 0c             	mov    0xc(%ebp),%edx
    12ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
    12ae:	01 d0                	add    %edx,%eax
    12b0:	0f b6 00             	movzbl (%eax),%eax
    12b3:	84 c0                	test   %al,%al
    12b5:	0f 85 70 fe ff ff    	jne    112b <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    12bb:	c9                   	leave  
    12bc:	c3                   	ret    
    12bd:	66 90                	xchg   %ax,%ax
    12bf:	90                   	nop

000012c0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    12c0:	55                   	push   %ebp
    12c1:	89 e5                	mov    %esp,%ebp
    12c3:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    12c6:	8b 45 08             	mov    0x8(%ebp),%eax
    12c9:	83 e8 08             	sub    $0x8,%eax
    12cc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    12cf:	a1 0c 1b 00 00       	mov    0x1b0c,%eax
    12d4:	89 45 fc             	mov    %eax,-0x4(%ebp)
    12d7:	eb 24                	jmp    12fd <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    12d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12dc:	8b 00                	mov    (%eax),%eax
    12de:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    12e1:	77 12                	ja     12f5 <free+0x35>
    12e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
    12e6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    12e9:	77 24                	ja     130f <free+0x4f>
    12eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12ee:	8b 00                	mov    (%eax),%eax
    12f0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    12f3:	77 1a                	ja     130f <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    12f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12f8:	8b 00                	mov    (%eax),%eax
    12fa:	89 45 fc             	mov    %eax,-0x4(%ebp)
    12fd:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1300:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1303:	76 d4                	jbe    12d9 <free+0x19>
    1305:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1308:	8b 00                	mov    (%eax),%eax
    130a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    130d:	76 ca                	jbe    12d9 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    130f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1312:	8b 40 04             	mov    0x4(%eax),%eax
    1315:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    131c:	8b 45 f8             	mov    -0x8(%ebp),%eax
    131f:	01 c2                	add    %eax,%edx
    1321:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1324:	8b 00                	mov    (%eax),%eax
    1326:	39 c2                	cmp    %eax,%edx
    1328:	75 24                	jne    134e <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    132a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    132d:	8b 50 04             	mov    0x4(%eax),%edx
    1330:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1333:	8b 00                	mov    (%eax),%eax
    1335:	8b 40 04             	mov    0x4(%eax),%eax
    1338:	01 c2                	add    %eax,%edx
    133a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    133d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    1340:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1343:	8b 00                	mov    (%eax),%eax
    1345:	8b 10                	mov    (%eax),%edx
    1347:	8b 45 f8             	mov    -0x8(%ebp),%eax
    134a:	89 10                	mov    %edx,(%eax)
    134c:	eb 0a                	jmp    1358 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    134e:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1351:	8b 10                	mov    (%eax),%edx
    1353:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1356:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    1358:	8b 45 fc             	mov    -0x4(%ebp),%eax
    135b:	8b 40 04             	mov    0x4(%eax),%eax
    135e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1365:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1368:	01 d0                	add    %edx,%eax
    136a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    136d:	75 20                	jne    138f <free+0xcf>
    p->s.size += bp->s.size;
    136f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1372:	8b 50 04             	mov    0x4(%eax),%edx
    1375:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1378:	8b 40 04             	mov    0x4(%eax),%eax
    137b:	01 c2                	add    %eax,%edx
    137d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1380:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    1383:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1386:	8b 10                	mov    (%eax),%edx
    1388:	8b 45 fc             	mov    -0x4(%ebp),%eax
    138b:	89 10                	mov    %edx,(%eax)
    138d:	eb 08                	jmp    1397 <free+0xd7>
  } else
    p->s.ptr = bp;
    138f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1392:	8b 55 f8             	mov    -0x8(%ebp),%edx
    1395:	89 10                	mov    %edx,(%eax)
  freep = p;
    1397:	8b 45 fc             	mov    -0x4(%ebp),%eax
    139a:	a3 0c 1b 00 00       	mov    %eax,0x1b0c
}
    139f:	c9                   	leave  
    13a0:	c3                   	ret    

000013a1 <morecore>:

static Header*
morecore(uint nu)
{
    13a1:	55                   	push   %ebp
    13a2:	89 e5                	mov    %esp,%ebp
    13a4:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    13a7:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    13ae:	77 07                	ja     13b7 <morecore+0x16>
    nu = 4096;
    13b0:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    13b7:	8b 45 08             	mov    0x8(%ebp),%eax
    13ba:	c1 e0 03             	shl    $0x3,%eax
    13bd:	89 04 24             	mov    %eax,(%esp)
    13c0:	e8 4f fc ff ff       	call   1014 <sbrk>
    13c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    13c8:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    13cc:	75 07                	jne    13d5 <morecore+0x34>
    return 0;
    13ce:	b8 00 00 00 00       	mov    $0x0,%eax
    13d3:	eb 22                	jmp    13f7 <morecore+0x56>
  hp = (Header*)p;
    13d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    13db:	8b 45 f0             	mov    -0x10(%ebp),%eax
    13de:	8b 55 08             	mov    0x8(%ebp),%edx
    13e1:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    13e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
    13e7:	83 c0 08             	add    $0x8,%eax
    13ea:	89 04 24             	mov    %eax,(%esp)
    13ed:	e8 ce fe ff ff       	call   12c0 <free>
  return freep;
    13f2:	a1 0c 1b 00 00       	mov    0x1b0c,%eax
}
    13f7:	c9                   	leave  
    13f8:	c3                   	ret    

000013f9 <malloc>:

void*
malloc(uint nbytes)
{
    13f9:	55                   	push   %ebp
    13fa:	89 e5                	mov    %esp,%ebp
    13fc:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    13ff:	8b 45 08             	mov    0x8(%ebp),%eax
    1402:	83 c0 07             	add    $0x7,%eax
    1405:	c1 e8 03             	shr    $0x3,%eax
    1408:	83 c0 01             	add    $0x1,%eax
    140b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    140e:	a1 0c 1b 00 00       	mov    0x1b0c,%eax
    1413:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1416:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    141a:	75 23                	jne    143f <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    141c:	c7 45 f0 04 1b 00 00 	movl   $0x1b04,-0x10(%ebp)
    1423:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1426:	a3 0c 1b 00 00       	mov    %eax,0x1b0c
    142b:	a1 0c 1b 00 00       	mov    0x1b0c,%eax
    1430:	a3 04 1b 00 00       	mov    %eax,0x1b04
    base.s.size = 0;
    1435:	c7 05 08 1b 00 00 00 	movl   $0x0,0x1b08
    143c:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    143f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1442:	8b 00                	mov    (%eax),%eax
    1444:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    1447:	8b 45 f4             	mov    -0xc(%ebp),%eax
    144a:	8b 40 04             	mov    0x4(%eax),%eax
    144d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1450:	72 4d                	jb     149f <malloc+0xa6>
      if(p->s.size == nunits)
    1452:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1455:	8b 40 04             	mov    0x4(%eax),%eax
    1458:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    145b:	75 0c                	jne    1469 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    145d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1460:	8b 10                	mov    (%eax),%edx
    1462:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1465:	89 10                	mov    %edx,(%eax)
    1467:	eb 26                	jmp    148f <malloc+0x96>
      else {
        p->s.size -= nunits;
    1469:	8b 45 f4             	mov    -0xc(%ebp),%eax
    146c:	8b 40 04             	mov    0x4(%eax),%eax
    146f:	89 c2                	mov    %eax,%edx
    1471:	2b 55 ec             	sub    -0x14(%ebp),%edx
    1474:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1477:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    147a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    147d:	8b 40 04             	mov    0x4(%eax),%eax
    1480:	c1 e0 03             	shl    $0x3,%eax
    1483:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    1486:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1489:	8b 55 ec             	mov    -0x14(%ebp),%edx
    148c:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    148f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1492:	a3 0c 1b 00 00       	mov    %eax,0x1b0c
      return (void*)(p + 1);
    1497:	8b 45 f4             	mov    -0xc(%ebp),%eax
    149a:	83 c0 08             	add    $0x8,%eax
    149d:	eb 38                	jmp    14d7 <malloc+0xde>
    }
    if(p == freep)
    149f:	a1 0c 1b 00 00       	mov    0x1b0c,%eax
    14a4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    14a7:	75 1b                	jne    14c4 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
    14a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
    14ac:	89 04 24             	mov    %eax,(%esp)
    14af:	e8 ed fe ff ff       	call   13a1 <morecore>
    14b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    14b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    14bb:	75 07                	jne    14c4 <malloc+0xcb>
        return 0;
    14bd:	b8 00 00 00 00       	mov    $0x0,%eax
    14c2:	eb 13                	jmp    14d7 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    14c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    14ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14cd:	8b 00                	mov    (%eax),%eax
    14cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    14d2:	e9 70 ff ff ff       	jmp    1447 <malloc+0x4e>
}
    14d7:	c9                   	leave  
    14d8:	c3                   	ret    
