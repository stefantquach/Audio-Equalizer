# Audio-Equalizer
This is a hardware project for creating an Audio Equalizer on the Artix-7 FPGA on the Nexys 4 DDR board. This project was created using Xilinx Vivado.

## Hardware Used
* Nexys 4 DDR board (using a Xilinx Artix-7 FPGA)
* LTC1865 16-bit ADC
* LTC1654 14-bit DAC

## Implementation
This project uses the Nexys4 DDR board description files provided by Diligent.  
The equalizer uses the Microblaze microprocessor, but the peripherals, such as the SPI, FIR filters, and controller were all described in Verilog. All of these peripherals were created to interact with the Microblaze on the Axi4Lite Bus  
The breakdown of the project is as follows:
* Axi4LiteRegs: This project implements the modules required to communicate on the Axi4Lite bus, notably `Axi4Lite_Supporter` and `Axi4Lite_Manager`. The name of the project comes from the `Axi4Lite_Regs` module, which simply contains registers that can be read and written to.
* SPI_Periph: This project implements the module required to communicate over SPI with the DAC and ADC.
* FIR_Peripheral: This project contains the FIR calculation module, which contains a variable amount of FIR filters, all calculating in parallel, as well as the controller which manages writing to the SPI modules described previously.
