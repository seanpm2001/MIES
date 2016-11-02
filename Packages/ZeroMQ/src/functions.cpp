// autogenerated by xop-stub-generator.pl from interface.h
#include "XOPStandardHeaders.h" // Include ANSI headers, Mac headers, IgorXOP.h, XOP.h and XOPSupport.h
#include "functions.h"

XOPIORecResult RegisterFunction()
{
  /*  NOTE:
    Some XOPs should return a result of NIL in response to the FUNCADDRS
    message.
    See XOP manual "Restrictions on Direct XFUNCs" section.
  */

  XOPIORecParam funcIndex    = GetXOPItem(0); /* which function invoked ? */
  XOPIORecResult returnValue = NIL;

  switch(funcIndex)
  {
  case 0:
    returnValue = (XOPIORecResult) zeromq_client_connect;
    break;
  case 1:
    returnValue = (XOPIORecResult) zeromq_client_recv;
    break;
  case 2:
    returnValue = (XOPIORecResult) zeromq_client_send;
    break;
  case 3:
    returnValue = (XOPIORecResult) zeromq_handler_start;
    break;
  case 4:
    returnValue = (XOPIORecResult) zeromq_handler_stop;
    break;
  case 5:
    returnValue = (XOPIORecResult) zeromq_server_bind;
    break;
  case 6:
    returnValue = (XOPIORecResult) zeromq_server_recv;
    break;
  case 7:
    returnValue = (XOPIORecResult) zeromq_server_send;
    break;
  case 8:
    returnValue = (XOPIORecResult) zeromq_set;
    break;
  case 9:
    returnValue = (XOPIORecResult) zeromq_stop;
    break;
  case 10:
    returnValue = (XOPIORecResult) zeromq_test_callfunction;
    break;
  case 11:
    returnValue = (XOPIORecResult) zeromq_test_serializeWave;
    break;
  }
  return returnValue;
}