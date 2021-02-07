#include <Rcpp.h>
using namespace Rcpp;
#include <stdint.h>   // Standard types 
#include <stdio.h>    // Standard input/output definitions 
#include <unistd.h>   // UNIX standard function definitions 
#include <fcntl.h>    // File control definitions 
#include <errno.h>    // Error number definitions 
#include <termios.h>  // POSIX terminal control definitions 
#include <string.h>   // String function definitions 
#include <sys/ioctl.h>
#include <vector>

// [[Rcpp::export]]
int ar_write(int fd, const char* str)
{
  int len = strlen(str);
  int n = write(fd, str, len);
  if( n!=len ) {
    perror("serialport_write: couldn't write whole string\n");
    return -1;
  }
  return 0;
}