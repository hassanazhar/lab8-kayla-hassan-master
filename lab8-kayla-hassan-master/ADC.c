// ADC.c
// Runs on LM4F120/TM4C123
// Provide functions that initialize ADC0
// Last Modified: 3/6/2015 
// Student names: change this to your names or look very silly
// Last modification date: change this to the last modification date or look very silly

#include <stdint.h>
#include "tm4c123gh6pm.h"

// ADC initialization function 
// Input: none
// Output: none
void ADC_Init(void){ 
volatile unsigned long delay;
SYSCTL_RCGCGPIO_R|=0X10;
	while((SYSCTL_PRGPIO_R & 0x10) == 0){}
GPIO_PORTE_DIR_R &= ~0X04; // PE2 INPUT
GPIO_PORTE_AFSEL_R|=0X04; //ALT FUNC ON 
GPIO_PORTE_DEN_R &=~0X04;// DISABLE DIG I/0 ON PE2
GPIO_PORTE_AMSEL_R |= 0X04;
SYSCTL_RCGCADC_R |=0X01; //SETS ADC CLOCK
		delay = 0x5000;
		while(delay){delay--;}

//ADC0_PC_R &= ~0XF;
//ADC0_SAC_R = 0x04; // 16) enable hardware oversampling; A N means 2^N (16 here) samples are averaged; 0<=N<=6
ADC0_PC_R |= 0X01; //125KHZ MAYBE &=
ADC0_SSPRI_R = 0X0123; //SEQUENCER 3 HIGHEST PRI
ADC0_ACTSS_R &=~0X08;// DISABLE SEQUENCER 3
ADC0_EMUX_R&=~0XF000;	//SOFTWARE START TRIGGER EVENT
ADC0_SSMUX3_R = ~0X0F; // CHANNEL 1 FOR PE2
ADC0_SSMUX3_R +=1;
ADC0_SSCTL3_R = 0X06;// DISABLE TEMP MEASUREMENT ETC
ADC0_IM_R &= ~0X0008;// DISABLE INTERRUPTS
ADC0_SAC_R = 0x06; // 16) enable hardware oversampling; A N means 2^N (16 here) samples are averaged; 0<=N<=6
ADC0_ACTSS_R |= 0X0008;
}

//------------ADC_In------------
// Busy-wait Analog to digital conversion
// Input: none
// Output: 12-bit result of ADC conversion
uint32_t ADC_In(void){  
uint32_t data;
	ADC0_PSSI_R =0X08;// initialize ss3
	while((ADC0_RIS_R&0x08)==0){};// wait for conversion done
		data =ADC0_SSFIFO3_R&0xFFF; // read result
		ADC0_ISC_R = 0x0008;// acknowledge completion
		return data;
  
}
