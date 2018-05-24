function [dec, dec_list] = polar_decoder(llr, K, L)

N = length(llr);
n = log2(N);
[~, info_bit_idx, frozen_bit_flag] = polar_seq_gen(N, K);

% Initialization the decoding list
list_size = 1;
dec_list  = cell(1,L);
for listIdx = 1:list_size
    % Each list contains a LLR array, partial sum array and path metric(PM)
    dec_list{listIdx}.LLR = [NaN(N,log2(N)), llr(:)];
    dec_list{listIdx}.par_sum = NaN(N,log2(N)+1);
    dec_list{listIdx}.PM  = 0;
end

% pre-calculate code trellis
trellis = zeros(n, 2^(n-1));
for s = 1:n
    idx = repmat((0:2^(n-s)-1)*2^s,2^(s-1),1);
    trellis(s,:) = idx(:)'+ repmat(1:2^(s-1),1,2^(n-s));
end

% SCL decoding
for i = 1:N
    % update LLR before decoding bit i
    for listIdx = 1:list_size
        LLR = dec_list{listIdx}.LLR;
        par_sum = dec_list{listIdx}.par_sum;
        % forward calculation of partial sum
        for s = 1:n
            idx = trellis(s,:);
            idx = idx(~(isnan(par_sum(idx,s)) | isnan(par_sum(idx+2^(s-1),s))) & isnan(par_sum(idx,s+1)));
            par_sum(idx,s+1) = mod(par_sum(idx,s)+par_sum(idx+2^(s-1),s), 2);
            par_sum(idx+2^(s-1),s+1) = par_sum(idx+2^(s-1),s);
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
        dec_list{listIdx}.LLR = LLR;
        dec_list{listIdx}.par_sum = par_sum;
    end
    
    % update path metric and decoding list
    if frozen_bit_flag(i)
        % frozen bit
        for listIdx = 1:list_size
            dec_list{listIdx}.PM = phi(dec_list{listIdx}.PM, dec_list{listIdx}.LLR(i,1), 0, 1);
            dec_list{listIdx}.par_sum(i,1) = 0;
        end
    else
        % info bit
        PM = zeros(1,2*list_size);
        for listIdx = 1:list_size
            PM(listIdx) = phi(dec_list{listIdx}.PM, dec_list{listIdx}.LLR(i,1), 0, 1);
            PM(listIdx+list_size) = phi(dec_list{listIdx}.PM, dec_list{listIdx}.LLR(i,1), 1, 1);
            dec_list{listIdx}.par_sum(i,1) = 0;
            dec_list{listIdx}.PM = PM(listIdx);
            dec_list{listIdx+list_size} = dec_list{listIdx};
            dec_list{listIdx+list_size}.par_sum(i,1) = 1;
            dec_list{listIdx+list_size}.PM = PM(listIdx+list_size);
        end
        if list_size >= L
            [~,sort_idx] = sort(PM);
            dec_list = dec_list(sort_idx(1:L));
        else
            list_size = 2*list_size;
        end
    end
end

dec = dec_list{1}.par_sum(info_bit_idx+1,1)';

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

function PM = phi(PM,LLR,u,dec_type)
if dec_type == 0
    PM = PM + log(1+exp(-(1-2*u)*LLR));
else
    PM = PM + ((1-2*u)~=sign(LLR))*abs(LLR);
end

end