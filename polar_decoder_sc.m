function [dec, dec_list] = polar_decoder(llr, K)

N = length(llr);
n = log2(N);
[~, info_bit_idx, frozen_bit_flag] = polar_seq_gen(N, K);

dec_list = NaN(1,N);
par_sum = NaN(N,log2(N)+1);
LLR = [NaN(N,log2(N)), llr(:)];

% pre-calculate code trellis
trellis = zeros(n, 2^(n-1));
for s = 1:n
    idx = repmat((0:2^(n-s)-1)*2^s,2^(s-1),1);
    trellis(s,:) = idx(:)'+ repmat(1:2^(s-1),1,2^(n-s));
end

% SCL decoding
for i = 1:N
    % update LLR before decoding bit i

       
        % forward calculation of partial sum
        for s = 1:n
            idx = trellis(n-s+1,:);
            idx = idx(~(isnan(par_sum(idx,s)) | isnan(par_sum(idx+2^(n-s),s))) & isnan(par_sum(idx,s+1)));
            par_sum(idx,s+1) = mod(par_sum(idx,s)+par_sum(idx+2^(n-s),s), 2);
            par_sum(idx+2^(n-s),s+1) = par_sum(idx+2^(n-s),s);
        end
        % backward calculation of LLR
        for s = n:-1:1
            % perform f operation
            idx = trellis(n-s+1,:);
            idx = idx(~(isnan(LLR(idx,s+1)) | isnan(LLR(idx+2^(n-s),s+1))) & isnan(LLR(idx,s)));
            LLR(idx,s) = f(LLR(idx,s+1),LLR(idx+2^(n-s),s+1),0);
            % perform g operation
            idx = trellis(n-s+1,:);
            idx = idx(~isnan(par_sum(idx, s)) & isnan(LLR(idx+2^(n-s),s)));
            LLR(idx+2^(n-s),s) = g(par_sum(idx,s),LLR(idx,s+1),LLR(idx+2^(n-s),s+1));
        end
        
    
    % frozen bit
     k =i-1;
    k_rever = 0;
    for m = 0:n-1
     k_rever = bitor(k_rever,bitset(0,n-m,bitand(bitshift(1,m),k )));
    end
    i_0 = k_rever+1;
        
    if frozen_bit_flag(i)
        
        dec_list(i) = 0;
    %info bit
    else
        if LLR(i_0,1) > 0
           dec_list(i) = 0;
        else 
           dec_list(i) = 1;
        end 
    end
   
     par_sum(i_0,1) = dec_list(i); 
    dec = dec_list;
end

    
function z = f(x,y,dec_type)
 if dec_type == 0
    z = 2.*atanh(tanh(x/2).*tanh(y/2));
 else
    z = sign(x).*sign(y).*min(abs(x),abs(y));
 end
end


function z = g(u,x,y)
z = (1-2*u).*x + y;
end

end

