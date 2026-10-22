#include "xparameters.h"
#include "xil_io.h"

#define FREQ_METER XPAR_FREQ_METER_IP_0_BASEADDR

#define WINDOW 0x00
#define CTRL 0x04
#define COUNT 0x08
#define STATUS 0x0c

int main(void){
    u32 time_in_clks = 1000;
    Xil_Out32(FREQ_METER, time_in_clks);
    Xil_Out32(FREQ_METER + CTRL, 1);
    Xil_Out32(FREQ_METER + CTRL, 0);
     
    while(!Xil_In32(FREQ_METER + STATUS));
    u32 counts = Xil_In32(FREQ_METER + COUNT);
    
    u32 freq = (u32)(((u64)counts*100000000)/time_in_clks);  //1МГц
    
    while(1){
        
    }
    
    return 0;
}