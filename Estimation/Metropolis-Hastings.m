% Metropolis-Hastings algorithm
% true (target) pdf is p(x) where we know it but can't sample data. 
% proposal (sample) pdf is q(x*|x)=N(x,10) where we can sample.
%% 
clc
clear; 

X(1)=0; 
N=1e4;
p = @(x) 0.3*exp(-0.2*x.^2) + 0.7*exp(-0.2*(x-10).^2); 
dx=0.05; 
xx=-10:dx:20; 
fp=p(xx); 
plot(xx,fp) % plot the true p(x)

%% MH algorithm
sig=(10);

for i=1:N-1
    % A random number
    u=rand;
    x=X(i); 
    x_new=normrnd(x,sig); % new sample x_new based on existing x from proposal pdf.
    
    p_xnew=p(x_new);
    px=p(x); 
    
    % proposal distribution: q
    qxs=normpdf(x_new,x,sig);
    qx=normpdf(x,x_new,sig); % get p,q.
    
     if u<min(1,p_xnew*qx/(px*qxs))  % case 1: pesudo code
%     if u<min(1,p_xnew/(px))        % case 2: Metropolis algorithm
%     if u<min(1,p_xnew/qxs/(px/qx)) 
% case 3: independent sampler: i.i.d, not depend on parameter
        X(i+1)=x_new;
    else
        X(i+1)=x; 
    end
end
% compare pdf of the simulation result with true pdf.
N0=1;  
close all;
figure; %N/5; 
nb=histc(X(N0+1:N),xx); 
bar(xx+dx/2,nb/(N-N0)/dx); % plot samples.
A=sum(fp)*dx; 
hold on; 
plot(xx,fp/A,'r') % compare.
% figure(2); plot(N0+1:N,X(N0+1:N)) % plot the traces of x.

% compare cdf with true cdf.
F1(1)=0;
F2(1)=0;
for i=2:length(xx) 
  F1(i)=F1(i-1)+nb(i)/(N-N0); 
  F2(i)=F2(i-1)+fp(i)*dx/A;
end

figure
plot(xx,[F1' F2'])
max(F1-F2) % this is the true possible measure of accuracy.
