/* tiocsti.c -- use TIOCSTI ioctl() to insert character in tty input */

#include <sys/ioctl.h>
#include <stdio.h>
#include <stdlib.h>

void
ioctl_tiocsti (char *c) {
	if (ioctl (0, TIOCSTI, (c)) == -1) {
		perror("TIOCSTI");
		exit (EXIT_FAILURE);
	}
}

int
main (int argc, char **argv) {
	// Loop through all the positional arguments
	while (*(++argv)){
		while (**argv)
			ioctl_tiocsti((*argv)++);
		// Only print a space if this is not the last argument
		if (*(argv+1))
			ioctl_tiocsti(" ");
	}
	return (0);
}

