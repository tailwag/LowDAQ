#include <stpwm.h>


PinTimerMap timerMap[4] = {
    {PA8, TIM1, 1}, 
    {PA0, TIM2, 1}, //A0
    {PB0, TIM3, 3}, //A3
    {PB7, TIM4, 2},
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

    if (selectedTimer == nullptr) {
        status = 0;
        frequency = 0;
        dutyCycle = 0.0;
        enabled = false;
        haltime = nullptr;
    }
    else {
        haltime = new HardwareTimer(selectedTimer); 

        haltime->setMode(channel, TIMER_OUTPUT_COMPARE_PWM1, p);
        haltime->setOverflow(1000, HERTZ_FORMAT);
        haltime->setCaptureCompare(channel, 50, PERCENT_COMPARE_FORMAT);
        haltime->resume();

        status = 1;
    }
}

void htPwm::enable() {
    if (status == 0)
        return;

    enabled = true;

    haltime->resume();
}

void htPwm::disable() {
    if(status == 0)
        return;

    enabled = false;

    haltime->pause();
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
