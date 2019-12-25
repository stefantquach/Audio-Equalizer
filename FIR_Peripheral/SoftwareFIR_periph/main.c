#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "stdint.h"
#include "fir_filter.h"

int16_t xCirc[NTAPS];


int16_t y[NUM_ITERATIONS];

int main()
{		
	uint16_t currentIndex = 0;
	initFilter(xCirc, NTAPS);
	
	for(int n = 0; n<NUM_ITERATIONS; ++n)
	{
		uint16_t sum = 0;
		for(int i=0; i<NUM_FILTERS; ++i) {
			// Inserting new element in x
			xCirc[currentIndex] = xSamples[n];

			// Computing output
			sum += filter(xCirc, currentIndex, h[i], NTAPS);

			// wrapping index for circular buffer
			++currentIndex;
			if(currentIndex >= NTAPS)
				currentIndex = 0;
		}
		y[n]=sum;
	}
	return 0;
}
