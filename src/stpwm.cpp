#include <stpwm.h>


PinTimerMap timerMap[] = {
  #ifdef F401RE
    {PA8,  TIM1, 1}, //D7 
    {PA9,  TIM1, 2}, //D8
    {PA10, TIM1, 3}, //D2
    {PA11, TIM1, 4},
    {PA0,  TIM2, 1}, //A0
    {PA1,  TIM2, 2}, //A1
    {PB10, TIM2, 3}, //D6
    {PA6,  TIM3, 1}, //D12
    {PA7,  TIM3, 2}, //D11
    {PB0,  TIM3, 3}, //A3
    {PB1,  TIM3, 4}, 
    {PB6,  TIM4, 1}, //D10
    {PB7,  TIM4, 2},
    {PB8,  TIM4, 3}, //D15
    {PB9,  TIM4, 4}, //D14
  #endif
  #ifdef G474RE
    {PC0,  TIM1, 1}, // L38, A5
    {PC1,  TIM1, 2}, // L36, A4
    {PC2,  TIM1, 3}, // L35
    {PC3,  TIM1, 4}, // L37
    {PA0,  TIM2, 1}, // L28, A0
    {PA1,  TIM2, 2}, // L30, A1
    {PB10, TIM2, 3}, // R25, D6
    {PB11, TIM2, 4}, // R18
    {PA6,  TIM3, 1}, // R13, D12
    {PA4,  TIM3, 2}, // L32, A2
    {PB0,  TIM3, 3}, // L34, A3
    {PB1,  TIM3, 4}, // R24 
    {PB6,  TIM4, 1}, // R17, D10
    {PB7,  TIM4, 2}, // L21
    {PB8,  TIM4, 3}, // R03, D15
    {PB9,  TIM4, 4}, // R05, D14
  #endif
};

TIM_TypeDef * getTimerForPin(uint8_t pin) {
    for (auto &m : timerMap) {
        if (m.pin == pin) return m.timer; 
    }
    return nullptr; // not found
}

int getChannelForPin(uint8_t pin) {
    for (auto &m : timerMap) {
        if (m.pin == pin) return m.channel; 
    }
    return -1;
}

htPwm::htPwm(int p) {
    TIM_TypeDef * selectedTimer = getTimerForPin(p);
    channel = getChannelForPin(p);

    frequency = 100;
    dutyCycle = 50;
    enabled = false;

    if (selectedTimer == nullptr) {
        status = 0;
        haltime = nullptr;
    }
    else {
        haltime = new HardwareTimer(selectedTimer); 

        haltime->setMode(channel, TIMER_OUTPUT_COMPARE_PWM1, p);
        haltime->setOverflow(100, HERTZ_FORMAT);
        haltime->setCaptureCompare(channel, 0, PERCENT_COMPARE_FORMAT);
        haltime->resume();

        status = 1;
    }
}

void htPwm::enable() {
    if (status == 0)
        return;

    enabled = true;

    haltime->setCaptureCompare(channel, dutyCycle, PERCENT_COMPARE_FORMAT);
}

void htPwm::disable() {
    if(status == 0)
        return;

    enabled = false;

    haltime->setCaptureCompare(channel, 0, PERCENT_COMPARE_FORMAT);

    return;
}

int htPwm::getState() {
    if (status == 0)
        return -1;

    return enabled;
}

void htPwm::setFrequency(int f) {
    if (status == 0)
        return;

    frequency = f;
    haltime->setOverflow(frequency, HERTZ_FORMAT);
 
    return;
}

int htPwm::getFrequency() {
    if (status == 0)
        return -1;

    return frequency;
}

void htPwm::setDutyCycle(int dc) {
    if (status == 0)
        return; 

    dutyCycle = constrain(dc, 0, 100); 

    haltime->setCaptureCompare(channel, dc, PERCENT_COMPARE_FORMAT);

    return;
}

int htPwm::getDutyCycle() {
    if (status == 0)
        return -1;
    
    return dutyCycle;
}
