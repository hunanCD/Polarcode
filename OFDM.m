TotalNumberOfSubCarrier = 64;

% for each symbol bits a1 to a52 are assigned to subcarrier

% index [-26 to -1 1 to 26]

subcarrierIndex_Data = [-26:-1 1:26];

BitsPerSymbol = 52;

 

close all;

figure;

 

% BPSK modulation

ModSequence = 2*randi([0 1],1,BitsPerSymbol)-1;

subplot(6,1,1); stem(abs(ModSequence));xlim([1 length(ModSequence)]);

 

TimeDomainSequence = []; % empty vector

 

ModSequenceForSubCarriers = zeros(1,TotalNumberOfSubCarrier);

 

% assigning bits a1 to a52 to subcarriers [-26 to -1, 1 to 26]

ModSequenceForSubCarriers(subcarrierIndex_Data+TotalNumberOfSubCarrier/2+1) = ModSequence(1,:);

subplot(6,1,2); stem(abs(ModSequenceForSubCarriers));xlim([1 length(ModSequenceForSubCarriers)]);

 

%  shift subcarriers at indices [-26 to -1] to fft input indices [38 to 63]

ModSequenceForSubCarriers = fftshift(ModSequenceForSubCarriers);

subplot(6,1,3); stem(abs(ModSequenceForSubCarriers));xlim([1 length(ModSequenceForSubCarriers)]);

 

ModSequenceInTimeDomain = ifft(ModSequenceForSubCarriers,TotalNumberOfSubCarrier);

subplot(6,1,4); stem(abs(ModSequenceInTimeDomain));xlim([1 length(ModSequenceInTimeDomain)]);

 

% adding cyclic prefix of 16 samples

ModSequenceInTimeDomain_with_CP = [ModSequenceInTimeDomain(49:64) ModSequenceInTimeDomain];

subplot(6,1,5); stem(abs(ModSequenceInTimeDomain_with_CP));

                     xlim([1 length(ModSequenceInTimeDomain_with_CP)]);

 

TimeDomainSequence = [TimeDomainSequence ModSequenceInTimeDomain_with_CP];

subplot(6,1,6); stem(abs(TimeDomainSequence));xlim([1 length(TimeDomainSequence)]);

 

 

figure;

SamplingRate = 20;

[PowerSpectrum,W] = pwelch(TimeDomainSequence,[],[],4096,20);    

subplot(1,3,1);plot([-2048:2047]*SamplingRate/4096,10*log10(fftshift(PowerSpectrum)));

                    xlabel('frequency, MHz')

                    ylabel('power spectral density')

subplot(1,3,2);plot(10*log10(fftshift(abs(fft(ModSequenceInTimeDomain)))));

                    xlim([1 length(ModSequenceInTimeDomain)]);

subplot(1,3,3);plot(10*log10(fftshift(abs(fft(TimeDomainSequence)))));

                    xlim([1 length(TimeDomainSequence)]);