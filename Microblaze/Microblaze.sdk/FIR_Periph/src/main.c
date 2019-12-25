/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "fir_filter.h"
#include "xil_printf.h"


int main()
{
    xil_printf("Hello World\n\r");
    xil_printf("Writing Taps\n");
    int32_t* h_addr = (int32_t*)(0x44A10004);
    volatile int32_t* x_addr = (int32_t*)(0x44A10000);

    for(int i=0; i<NTAPS; ++i)
    {
    	*h_addr = h[i];
    	h_addr += 2;
    	int32_t val = *x_addr;
    	while((val & (1<<16))== 0)
		{
			val = *x_addr;
		}
    }
    xil_printf("Finished Writing Taps\n");

//    xil_printf("Resetting circular buffer\n");
//    for(int i=0; i<NTAPS; ++i)
//    {
//    	*x_addr = 0;
//		int32_t val = *x_addr;
//		while((val & (1<<16))== 0)
//		{
//			val = *x_addr;
//		}
//    }

    uint32_t* reg0 = (uint32_t*)0x44A00000;
	*reg0 = 0;
	*reg0 = 1;
    for(int i=0; i<NUM_ITERATIONS; ++i)
    {
    	*x_addr = xSamples[i];
    	int32_t val = *x_addr;
    	while((val & (1<<16))== 0)
    	{
    		val = *x_addr;
    	}
//    	xil_printf("%i\n", (int16_t)val);
    }
    *reg0 = 0;
    return 0;
}
