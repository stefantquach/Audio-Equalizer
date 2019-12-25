/*
 * main.c
 *
 *  Created on: Sep 5, 2019
 *      Author: stefan.quach
 */

//AXI GPIO driver
#include "xgpio.h"

//send data over UART
#include "xil_printf.h"

//information about AXI peripherals
#include "xparameters.h"

int main()
{
	XGpio gpio;
	XGpio gpio1;
	u32 btn, led, sw, rgb_led;
	u32 test_data;
	volatile u32* test_ptr = (u32*)0x44A00000;
	volatile u32* test_ptr2 = (u32*)0x44A00008;
	*test_ptr++ = 0xdeadbeef;
	*test_ptr++ = 0xfeedbeef;
	*test_ptr++ = 0xbeefdead;
	*test_ptr++ = 0xbeeffeed;

	test_ptr = (u32*)0x44A00000;
	for(int i=0; i<4; ++i)
	{
//		xil_printf("Address %08x: %08x", test_ptr, *test_ptr);
		test_data = *test_ptr++;
//		test_ptr++;
	}

	u32 data = *test_ptr2;

	XGpio_Initialize(&gpio, 0);
	XGpio_Initialize(&gpio1, 1);

	XGpio_SetDataDirection(&gpio, 2, 0x00000000); // set LED GPIO channel tristates to All Output
	XGpio_SetDataDirection(&gpio, 1, 0xFFFFFFFF); // set BTN GPIO channel tristates to All Input

	XGpio_SetDataDirection(&gpio1, 1, 0x00000000); // set LED GPIO channel tristates to All Output
	XGpio_SetDataDirection(&gpio1, 2, 0xFFFFFFFF); // set BTN GPIO channel tristates to All Input


	while (1)
	{
		btn = XGpio_DiscreteRead(&gpio, 1);
		sw = XGpio_DiscreteRead(&gpio1, 2);
		test_data = *test_ptr;
		*test_ptr2 = data++;
		*test_ptr = *test_ptr - 1;

		if (btn != 0) // turn all LEDs on when any button is pressed
			led = 0xFFFFFFFF;
		else
			led = 0x00000000;

		if (sw != 0)
			if(!(sw & ~0b111111))
				rgb_led = sw;
			else
			rgb_led = 0x00000009;
		else
			rgb_led = 0x00000000;

		XGpio_DiscreteWrite(&gpio, 2, led);
		XGpio_DiscreteWrite(&gpio1, 1, rgb_led);

		xil_printf("\rbutton state: %08x, Address 4: %08x, Address 8: %08x", btn, test_data, *test_ptr2);
	}
}
