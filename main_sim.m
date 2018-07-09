

clear; clc; close all;

 

N = 16 ;

K = 8 ;

 

%global EbN0

EbN0 = 1:0.5:4;

nMaxBlks = 1e4;

tarErrs = 100;

nErr  = double(zeros(1, length(EbN0)));

nBlks = nMaxBlks*ones(1, length(EbN0));

 

for ebn0 = 1:length(EbN0)  %SNR

    for k = 1:nMaxBlks     %number of Blocks

        info_bit = randi([0,1],1,K);

        code_bit = polar_encoder(info_bit, N);

        unit_noise = randn(1,N);

        en = 10^(EbN0(ebn0)/10);

        sigma = 1/sqrt(2*en*K/N); % sigma=E/sqrt(2*SNR)

        x = (1-2*code_bit) + sigma*unit_noise;
       %dec = polar_decoder(x, K, 1);

        %nErr(1,ebn0) = nErr(1,ebn0) + ((dec-info_bit)*(dec-info_bit)'>0);

        %dec = polar_decoder(x, K, 2);

        %nErr(2,ebn0) = nErr(2,ebn0) + ((dec-info_bit)*(dec-info_bit)'>0);

        %dec = polar_decoder(x, K, 8);

        %nErr(3,ebn0) = nErr(3,ebn0) + ((dec-info_bit)*(dec-info_bit)'>0);

       dec = polar_decoder_sc(x, K);

       nErr(ebn0) = nErr(ebn0) + ((dec-info_bit)*(dec-info_bit)'>0);
%   fprintf('nErr(ebn0) =%d, (dec-info_bit)*(dec-info_bit)=%d ',nErr(ebn0) ,(dec-info_bit)*(dec-info_bit)');
       if((dec-info_bit)*(dec-info_bit)'==0)

          
          
          fprintf('\n\n ==================this block BLER is 0 EbN0 = %0.1fdB  ==================\n',EbN0(ebn0));
          
          fprintf('k=%d    ',k);

          fprintf('BLER     :  ');

          fprintf('%0.2e    ',nErr(ebn0)/k);

       end

       % if mod(k,10) == 0

        %    fprintf('\n\n ================== EbN0 = %0.1fdB  ==================\n',EbN0(ebn0));

        %    fprintf('List Size:     1            2           8\n');

        %    fprintf('BLER     :  ');

        %    for n = 1:3

        %        fprintf('%0.2e    ',nErr(n, ebn0)/k);

         %   end

        %end

        if mod(k,10) == 0

          fprintf('\n\n ================== EbN0 = %0.1fdB  ==================\n',EbN0(ebn0));

           %fprintf('List Size:     1            2           8\n');

            fprintf('BLER     :  ');

 

           fprintf('%0.2e    ',nErr(ebn0)/k);

        end

        %end

       % if nErr(1,ebn0) > tarErrs && nErr(2,ebn0) > tarErrs && nErr(3,ebn0) > tarErrs

       %     nBlks(:,ebn0) = k;

        %    break;

        if nErr(ebn0) > tarErrs

              nBlks(:,ebn0) = k;

              break;

        end

    end

end

 
%BLER = zeros(1,length(nBlks));

BLER = nErr./nBlks;

semilogy(EbN0, BLER, 'o-'); grid on;