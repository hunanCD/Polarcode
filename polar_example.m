signal = randi([0,1],1,ST);
frozen = zeros(1,FT);
encode = zeros(1,N * block);
noise = snr(i) ^ 1/2 * randn(1,N * block);


for j=1:block
    encode(1,((j-1)*N+1):(j*N)) = signal(((j-1)*S+1):(j*S))*g(signal_index) + frozen(((j-1)*F+1):(j*F))*G(frozen_index);
end

encode = mod(encode,2);
encode = 2 * encode - 1;
encode = encode + noise;
