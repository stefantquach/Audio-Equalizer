/*
 * main.c
 *
 *  Created on: Sep 12, 2019
 *      Author: stefan.quach
 */

//AXI GPIO driver
#include "xgpio.h"

//send data over UART
#include "xil_printf.h"

//information about AXI peripherals
#include "xparameters.h"

#include "fir_filter.h"


#define NUM_ITERATIONS 1000

int16_t xCirc[NTAPS];


int16_t y[NUM_ITERATIONS];

int main()
{
	xil_printf("\nHello World\n");

	uint16_t currentIndex = 0;
	initFilter(xCirc, NTAPS);

	uint32_t* reg0 = (uint32_t*)0x44A00000;
	*reg0 = 0;
	*reg0 = 1;
	for(int n = 0; n<NUM_ITERATIONS; ++n)
	{
		// Inserting new element in x
		xCirc[currentIndex] = xSamples[n];

		// Computing output
		y[n] = filter(xCirc, currentIndex, h, NTAPS);
		xil_printf("%i\n", y[n]);

		// wrapping index for circular buffer
		++currentIndex;
		if(currentIndex >= NTAPS)
			currentIndex = 0;
	}
	*reg0 = 2;
	return 0;
}
