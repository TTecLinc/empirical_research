% --------------------------------
%  T = KalmanFilter(s,Q,R)
%  s   position change
%  Q   Cov State
%  R   Cov Error
% --------------------------------
%  
%  S(k+1) = 1*S(k) + T*V(k) + 0.5*T^2*a
%  V(k+1) = 0*S(k) + 1*V(k) + T*a
%  Obs Equation
%  y(k+1) = S(k+1) + v(k+1)
%  
%  X(k+1) = A * X(k)   + G*w(k+1); 
%  y(k+1) = H * X(k+1) + v(k+1);   
global Xu
t = (-2:0.001:3)'*5;
t = (-2:1:3)';
n = randn(size(t)); % Noise
s = sin(t);         % Signal
x = s + n;          % Signal with Noise
R = cov(n);         % Cov Obs

% [1] Large Prediction Error
Q = 200;
Q = 10^-1;
Q = 10^-6;
y = KalmanFilter(x,Q,R);
e = s - y;
figure;
subplot(211);
plot(x,'color',[0.2 0.5 0.8],'linewidth',2);hold on;
plot(y,'color',[1 0.6 0],'linewidth',2);
plot(s,'color',[1 0.9 0],'linewidth',2);
legend('Obs','Filter','Real Number','location','Best');
axis tight
subplot(212);
plot(e,'color',[0.2 0.5 0.8]);axis tight
legend('Error','location','Best');
axis tight
