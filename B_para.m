function y = B_para(Z)
for i = 1 : log2(length(Z))
    Z_pre = Z;
    disp(Z)%;
    for j = 1 : 2^(i-1)
        Z(2*j-1) = 2*Z_pre(j) - Z_pre(j)^2;
        Z(2*j) = Z_pre(j)^2;
            disp(Z)%;
    end
end

y = Z;
S = 4;
[Z_in_order,index] = sort( y );
signal_index = sort( index( 1: S ) );
frozen_index = sort( index( S+1:end ) );