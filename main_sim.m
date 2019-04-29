clear; clc; close all;

N = 128;
K = 100;
%N = 1024 ;
%K = 1000 ;


EbN0 = -1:0.5:4;
%EbN0 = 4;
nMaxBlks = 1e4;
%nMaxBlks = 1;
tarErrs = 100;
nErr  = zeros(3, length(EbN0));
nBlks = nMaxBlks*ones(3, length(EbN0));


for ebn0 = 1:length(EbN0)
    for k = 1:nMaxBlks
        info_bit = randi([0,1],1,K);
        %info_bit = [1 0];
        code_bit = polar_encoder(info_bit, N);
        %unit_noise = randn(1,N);
        %en = 10^(EbN0(ebn0)/10);
        %sigma = 1/sqrt(2*en*K/N);
        
        unit_noise = randn(1,N);
        sigEner = norm(code_bit(:))^2;
        noiseEner = sigEner/(10^(EbN0(ebn0)/10));        % energy of noise to be added
        noiseVar = noiseEner/(length(code_bit(:)-1));     % variance of noise to be added
        noiseStd = sqrt(noiseVar);                   % std. deviation of noise to be added
        noise = noiseStd*unit_noise;           % noise
        x = (1-2*code_bit) + noise; 
        y = 2*x/EbN0(ebn0);
        %x = awgn(code_bit,0.5);
        %LLR = 2*x/(en^2);  % LLR=2yi/normal value ^2
        %y = [-4.4 -6.4 -2.0 4.8]; %date-0423
        dec = polar_decoder_sc(y, K);
        %dec = polar_decoder_scl(x, K, 1);
        nErr(1,ebn0) = nErr(1,ebn0) + ((dec-info_bit)*(dec-info_bit)'>0);
        %dec = polar_decoder_scl(x, K, 2);
        %nErr(2,ebn0) = nErr(2,ebn0) + ((dec-info_bit)*(dec-info_bit)'>0);
        %dec = polar_decoder_scl(x, K, 16);
        %nErr(3,ebn0) = nErr(3,ebn0) + ((dec-info_bit)*(dec-info_bit)'>0);

        if mod(k,10) == 0
            fprintf('\n\n ================== EbN0 = %0.1fdB  ==================\n',EbN0(ebn0));
            fprintf('List Size:     1            2           8\n');
            fprintf('BLER     :  ');
            for n = 1:3
                fprintf('%0.2e    ',nErr(n, ebn0)/k);
            end
        end
        %if nErr(1,ebn0) > tarErrs && nErr(2,ebn0) > tarErrs && nErr(3,ebn0) > tarErrs
        if nErr(1,ebn0) > tarErrs
            nBlks(:,ebn0) = k;
            break;
        end
    end
end

BLER = nErr./nBlks;
semilogy(EbN0, BLER, 'o-'); grid on;