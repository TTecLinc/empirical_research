# -*- coding: utf-8 -*-
"""
Created on Thu Dec 10 15:54:23 2020

@author: Peilin Yang
"""


from numpy import *
import pylab
import math

# Initial Parameter
n_iter = 100
sz = (n_iter,) # size of array

# Array
x = zeros(sz)
xes = zeros(sz)
f = zeros(sz)
fes = zeros(sz)
kk1 = zeros(n_iter-1)
kk2 = zeros(n_iter-1)

A = mat([[0.5,2],[0,1]])
B = mat([[0],[1]])
C = mat([1,0])

P = mat([[500,0],[0,200]])
Q = mat([[0,0],[0,10]])
I = mat([[1,0],[0,1]])

U = random.normal(0,math.sqrt(10),n_iter)
V = random.normal(0,math.sqrt(10),n_iter)

# real
x[0]=650
f[0]=250

# estimate
xes[0]=600
fes[0]=200

R = 10

# intial guesses
xhat = mat([[650],[250]])

for k in range(1,n_iter):

    # Step 1: One-Step forcast
    # State Variable: X
    #X(k|k-1) = AX(k-1|k-1) + BU(k)
    xhat = A*xhat + B*U[k-1]  
    # Control Variable: Y
    
    y = C*xhat + V[k-1]
    
    # Step 2: Predicted Cov Matrix
    P = A*P*A.T + Q
    x[k] = xhat[0][0]
    f[k] = xhat[1][0]

    # Step 3: Kalman Matrix
    inv = linalg.inv(C*P*C.T+R)
    #Kg(k) = P(k|k-1)H'/[HP(k|k-1)H' + R]
    K = P*C.T*inv 
    kk1[k-1] = K[0][0]
    kk2[k-1] = K[1][0]
    
    # Step 4: Adjust Predction
    #X(k|k) = X(k|k-1) + Kg(k)[Z(k) - HX(k|k-1)]
    xhat = xhat+K*(y-C*xhat) 
    xes[k] = xhat[0][0]
    fes[k] = xhat[1][0]
    #P(k|k) = (1 - Kg(k)H)P(k|k-1)
    
    # Step 5: Given First-Order Condition-K, we have Optimal P
    P = (I-K*C)*P 
    print(P)
pylab.figure()
pylab.plot(x,'k*',label='simulation system')
pylab.plot(xes,'b^',label='estimation')
pylab.title('The number of insects')
pylab.xticks(arange(0,n_iter,1))
pylab.legend()
pylab.xlabel('Iteration')
pylab.ylabel('quantity')

pylab.figure()
pylab.plot(f,'k*',label='simulation system')
pylab.plot(fes,'b^',label='estimation')
pylab.title('The number of food')
pylab.xticks(arange(0,n_iter,1))
pylab.legend()
pylab.xlabel('Iteration')
pylab.ylabel('quantity')

pylab.figure()
pylab.plot(kk1,'k-',label='insects')
pylab.plot(kk2,'b-',label='food')
pylab.title('Kalman gain curve')
pylab.xticks(arange(0,n_iter-1,1))
pylab.legend()
pylab.xlabel('Iteration')
pylab.ylabel('quantity')
pylab.show()
