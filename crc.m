K = 100;
info_bit = randi([0,1],1,K);
%exmp1
%info_bit= [1 1 0 1 0 1 1 0 1 1];
%gCrc24a = [1 0 0 1 1];
%exmp2
%info_bit= [1 0 1 1 0 0 1 1];
%gCrc24a = [1 1 0 0 1];
gCrc24a = [1 1 0 0 0 0 1 1 0 0 1 0 0 1 1 0 0 1 1 1 1 1 0 1 1]; %D24 + D23
%+ D18 + D17 + D14 + D11 + D10 + D7 + D6 + D5 + D4 + D3 + D + 1]
crcLen = length(gCrc24a);
crc_bit = zeros(1,crcLen-1);
state = 0;
N=length(info_bit);
	
   %bitMask = (long long int) 1<<crcLen;
   bitMask = bitshift(1,crcLen-1);
   % Loop and calculate CRC over each column vector
   state = 0;
   gCrc24a_bit = 0;
   b=zeros(1,crcLen-1);
   y=[info_bit b];
  for n=1:crcLen
      state = bitor(state,bitshift(y(n),crcLen-n));
      gCrc24a_bit = bitor(gCrc24a_bit,bitshift(gCrc24a(n),crcLen-n));
  end

  for n=1:(N-1)
	  
		   %state = bitshift(state,1);

		   if bitand(state,bitMask) >0 
		      state = bitxor(state,gCrc24a_bit); 
           end
           state =bitshift(state,1);
           f=bitor(state,y(n+crcLen));
           state = bitor(state,y(n+crcLen));
  end
 
  for n=1:crcLen-1
  crc_bit(crcLen-n) = bitget(state,n);
  end
    % Move CRC-bit into output vector
   
   output_bit = [info_bit crc_bit];
