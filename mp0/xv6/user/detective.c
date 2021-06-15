#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
#include <stddef.h>



int DETECTED = 0;
const char* FIND = "y";
const char* LOST = "n";

char* fmtname(char *path){

	char *p;
  	// Find first character after last slash.
  	for(p=path+strlen(path); p >= path && *p != '/'; p--)
    	;
  	p++;
  	return p;
  	// Return blank-padded name
 /*
  	memmove(buf, p, strlen(p));
  	memset(buf + strlen(p), ' ', DIRSIZ-strlen(p));
  	return buf;*/
}

void detect(const char path_name[512], const char search_name[512]){
	struct stat st_parent;
	struct dirent de;
	int fd;
	int readlen;
	char* str_pos;
	char buf[512];

	int pid = getpid();

	if ((fd = open(path_name, 0)) < 0){
		fprintf(2, "ls: cannot open %s\n", path_name);
		return;
	}

	if (fstat(fd, &st_parent) < 0){
		fprintf(2, "ls: cannot stat %s\n", path_name);
		close(fd);
		return;
	}

   	if (st_parent.type == T_DIR) {
   		strcpy(buf, path_name);
		str_pos = buf + strlen(buf);
   		*str_pos++ = '/';
	    while ((readlen = read(fd, &de, sizeof(de))) == sizeof(de)){
	    	if (de.inum == 0)
	        	continue;
	      	memmove(str_pos, de.name, DIRSIZ);
      		str_pos[DIRSIZ] = 0;	//buf = path/filename
	      	if (fmtname(buf)[0] == '.'){
	      		continue;
	      	} else{
	      		detect(buf, search_name);
	      	}
	    }
	} else{
		strcpy(buf, path_name);
		if (strcmp(search_name, fmtname(buf)) == 0){
			printf("%d as Watson: %s\n", pid, buf);
			DETECTED = 1;
		}
	}
	close(fd);
	return;
}


int main(int argc, char const *argv[])
{
	char search_name[80];
	if (argc == 1){
		printf("usage: ./detective [filename]\n");
		return 0;
	}
	strcpy(search_name, argv[1]);
	int pid;
	int p2c[2], c2p[2];
	pipe(p2c);
	pipe(c2p);
	if ((pid = fork()) == 0){	//child
		close(p2c[1]);
		close(c2p[0]);
		detect(".", search_name);
		if (DETECTED == 1){
			write(c2p[1], FIND, strlen(FIND));
		} else{
			write(c2p[1], LOST, strlen(LOST));
		}
	} else{
		close(p2c[0]);
		close(c2p[1]);
		pid = getpid();
		char buffer[80];
		for (int i = 0; i < 80; i++){
			buffer[i] = '\0';
		}
		read(c2p[0], buffer, 20);
		if (buffer[0] == 'y')
			printf("%d as Holmes: This is the evidence\n", pid);
		if (buffer[0] == 'n')
			printf("%d as Holmes: This is the alibi\n", pid);
		wait(NULL);
	}

	exit(0);
}