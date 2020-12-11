function T = KalmanFilter(s,Q,R)
global Xu
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


N = length(s);
T = 1;         
A = [1 T;0 1]; %  State Transition
G = [T^2/2;T]; %  Control Matrix
H = [1 0];     %  Obs Matrix

% The first State
Xu = [s(1); 0];
Pu = [0 0;0 0];
I  = [1 0;0 1];
T  = zeros(N,1);

for i = 2:N
    Xp = A * Xu;
    Pp = A * Pu * A' + G * Q * G';
    K  = Pp * H' * ( H * Pp * H' + R)^-1;
    % Optimal Obs: Optimal K Matrix
    Xu = ( I - K * H ) * Xp + K * s(i);
    Pu = ( I - K * H ) * Pp;
    T(i) = Xu(1);
    
end
 
end
