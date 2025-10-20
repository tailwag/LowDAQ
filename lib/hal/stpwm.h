#include <Arduino.h>

struct PinTimerMap {
    uint8_t pin;
    TIM_TypeDef * timer;
    uint8_t channel;
};

extern PinTimerMap timerMap[4];

TIM_TypeDef * getMapForPin(uint8_t pin);
int getChannelForPin(uint8_t pin);

class htPwm {
    private:
        int frequency;
        int dutyCycle;
        bool enabled;
        int pwmPin;
        int channel;
        int8_t status;
        HardwareTimer *haltime;


    public: 
        void enable();
        void disable();
        int getState();
        void setFrequency(int f);
        int getFrequency(); 
        void setDutyCycle(int dc);
        int getDutyCycle();
    
        htPwm(int p);    
};
