clear all;

 

 

fid = fopen('UL_5_25_NoFilter_S7_68_Trig.bin','r');

[data,count] = fread(fid, 'single');

fclose(fid);

 

Offset = 280228 + 2 ;

 

Nfft = 512;

SamplingScale = (double(Nfft)/2048);

CP_LengthList = SamplingScale * [160;144;144;144;144;144;144];

Symbol_LengthList = SamplingScale * [2048;2048;2048;2048;2048;2048;2048];

 

dataI = data(1:2:end);

dataQ = data(2:2:end);

dataComplex = dataI + j*dataQ;

 

rSeq = [];

rThreshold = 0.2;

rPeakIndex = [];

NoOfSymbolsToScan = 10;

 

SearchStart = 0;

 

for i = (SearchStart+0):(SearchStart + NoOfSymbolsToScan*Nfft + NoOfSymbolsToScan*144)

    X = dataComplex(i+1:i+144/4);

    Y = dataComplex(i+1+Nfft:i+Nfft+144/4);

    r = X' * Y;

    rSeq = [rSeq r];

end;

 

pks = find(abs(rSeq) > 0.24);

 

subplot(3,1,1);

plot(abs(rSeq),'r-'); xlim([1 length(rSeq)]); ylabel('r');

 

subplot(3,1,2);

plot(real(rSeq),'r-'); xlim([1 length(rSeq)]);ylabel('Re(r)');

 

subplot(3,1,3);

plot(imag(rSeq),'r-'); xlim([1 length(rSeq)]);ylabel('Im(r)');