/*
 * main.c
 *
 *  Created on: Nov 28, 2019
 *      Author: stefan.quach
 */
#include "xparameters.h"
#include "xstatus.h"
#include "xuartlite.h"
#include "xil_printf.h"
#include <stdint.h>
#include "fir_filter.h"

#define UARTLITE_DEVICE_ID	XPAR_UARTLITE_0_DEVICE_ID
#define PACKET_SIZE 3

XUartLite UartLite;		/* Instance of the UartLite Device */

uint8_t receive_buffer[PACKET_SIZE];

int main() {
	int i;
	volatile int32_t* taps = (int32_t*)0x44A10000;
	volatile int32_t* attenuations = (int32_t*)(taps+NUM_FILTERS*NTAPS);
	volatile int32_t* enable = (int32_t*)(taps+(NTAPS*NUM_FILTERS+NUM_FILTERS));

	// waiting for the peripheral to be ready
	while(*taps == 0);

	xil_printf("Peripheral ready\n");

	// writing taps
	for(i=0; i<NUM_FILTERS*NTAPS; ++i){
		taps[i]=h[i/NTAPS][i%NTAPS];
	}

//	xil_printf("Finished writing taps\n");

	*enable = 0; // enabling the peripheral (value doesn't matter)

//	xil_printf("Enabled %i\n", *taps);
	for(i=0; i<NUM_FILTERS;++i){
		attenuations[i]=0x4000;
	}
//	xil_printf("wrote attenuations\n");

	// Serial config stuff
	// Initializing serial port
	int Status = XUartLite_Initialize(&UartLite, UARTLITE_DEVICE_ID);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
	for(i=0; i<PACKET_SIZE; ++i) {
		receive_buffer[i]=0;
	}

	// main event loop
	while(1) {
		// read in bytes and wait until the entire packet has been received
		int receive_count = 0;
		while(receive_count < PACKET_SIZE) {
			receive_count += XUartLite_Recv(&UartLite, receive_buffer+receive_count, PACKET_SIZE-receive_count);
		}

		int16_t atten = (int16_t)(receive_buffer[1] << 8) | receive_buffer[2];

		// write attenuation
		if(receive_buffer[0] < NUM_FILTERS && atten <= 0x4000 && atten >= 0){
			attenuations[receive_buffer[0]]=atten;
		}
	}

	return 0;
}
