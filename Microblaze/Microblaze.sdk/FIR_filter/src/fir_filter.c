/*
 * fir_filter.c
 *
 *  Created on: Sep 12, 2019
 *      Author: stefan.quach
 */
#include "fir_filter.h"
#include "xil_printf.h"


int16_t initFilter(int16_t* x, uint32_t nTaps)
{
	int i;
	for (i=0; i<nTaps; ++i)
	{
		x[i] = 0;
	}
	return 0;
}


int16_t filter(int16_t* x, uint16_t xIndex, int16_t* h, uint32_t nTaps)
{
	int16_t y;
	int k,hIndex;
	k = xIndex;
	// iterating backwards
	for(hIndex=0; hIndex < nTaps; ++hIndex)
	{
		if (k < 0)
			k = nTaps-1;

		y += ((int32_t)x[k] * (int32_t)h[hIndex] + (1 << 14)) >> 15;
		--k;
	}
	return y;
}

