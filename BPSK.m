% This program is a demonstration of Binary Phase Shift Keying
% Modulates a random binary sequence onto a carrier wave to create an rf signal
% Then demodulates the same signal to recover the original bit stream

baud = 1e6; % Baud rate of 1 Mbps

carrier_freq = 100e6; % 100 MHz Radio Carrier Wave

seq_len = 64;
x = (randi([0 1],1,seq_len)); % random binary sequence of length 128

T = 1/(20*carrier_freq); % Sampling time with oversampling to make plots nice

xt = upsample(x, 1/(T*baud)); % Baseband signal upsampled to simulation period
xt = 2*(filter(ones(1,1/(T*baud)), 1, xt))-1; % Zero Order Hold interpolation

% Simulation Timescale
t = 0:T:seq_len/baud;
t = t(1:end-1);

carrier_I = cos(carrier_freq*t); % For BPSK, In-phase sequence is always 1s
carrier_Q = xt.*sin(carrier_freq*t); % Modulation affects the out-of-phase signal

rf = carrier_I + carrier_Q; % The radio signal is the sum of the in and out of phase components

demod_I = rf .* cos(carrier_freq*t); % Multiply rf signal with local oscillator I and Q signals 
demod_Q = rf .* sin(carrier_freq*t);


% [b,a] = butter(5,90e6/(1/T)) % Butterworth LPF to remove high frequencies
I = filter(b,a, demod_I); % Filtering the in-phase component should be a constant
Q = 2*filter(b,a, demod_Q); % Filtering the out-phase component should be the data sequence


Q(Q>0.5) = 1; % Comparator to digitize the data sequence
Q(Q<-0.5) = -1;

figure()
subplot(1,3,1)
plot(xt)
title("Input Binary Sequence");

subplot(1,3,2);
plot(I)
title("Demodulated In-Phase Component");

subplot(1,3,3)
plot(Q);
title("Demodulated Out-Phase Component");