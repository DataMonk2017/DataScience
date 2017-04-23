function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.
%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%

%==========================Cost============================
%===For loop====
%for i = 1: m,
%  z2 = Theta1*[1 ; X(i,:)'];
%  a2 = sigmoid(z2);
%  z3 = Theta2*[1 ; a2];
%  #a3 = h
%  h = sigmoid(z3);
%  y_transformed = zeros(num_labels,1);
%  y_transformed(y(i)) = 1;
  %y(i)
  %y_transformed
%  J = J + 1.0/m*(-y_transformed'*log(h)-(1 .- y_transformed)'*log(1-h));
%  end
%J = J +lambda/(2*m)*(sum((Theta1(:,2:(input_layer_size+1))(:)).^2)+sum((Theta2(:,2:(hidden_layer_size+1))(:)).^2));
  %Theta1(:,2:(input_layer_size+1))
  %Theta2(:,2:(hidden_layer_size+1))


  
%====vectorization implementation====    
A1 = [ones(m,1) X]; % m *(input_layer_size+1)
Z2 = A1*Theta1'; % m * hidden_layer_size
A2 = [ones(m,1) sigmoid(Z2)]; % m * (hidden_layer_size+1)
Z3 = A2*Theta2';  %m * num_labels
h = sigmoid(Z3); %m *num_labels
%h = sigmoid(Theta2*[ones(1,m);sigmoid(Theta1*[ones(m,1) X]')]);
y_transformed = de2bi(2.^(y .-1)); %m*num_labels

%There are two methods of computing the sum for the vectorized J calculation.

%the other uses matrix multiplication and the trace function.
J = 1.0/m*trace(-y_transformed*log(h')-(1 .- y_transformed)*log(1 .-h'))...
+lambda/(2*m)*(sum(Theta1(:,2:(input_layer_size+1))(:).^2)+sum(Theta2(:,2:(hidden_layer_size+1))(:).^2));
%one uses element-wise multiplication and a double-sum.
%J = 1.0/m*sum((-y_transformed.*log(h)-(1 .- y_transformed).*log(1 .-h))(:))...
%+lambda/(2*m)*(sum(Theta1(:,2:(input_layer_size+1))(:).^2)+sum(Theta2(:,2:(hidden_layer_size+1))(:).^2));

%=====================Gradient Decent============================
%===For loop====
%for i = 1: m, 
%  a1 = [1 ; X(i,:)'];
%  z2 = Theta1*a1;
%  a2 = [1 ; sigmoid(z2)];
%  z3 = Theta2*a2;
  #a3 = h
%  h = sigmoid(z3);
%  y_transformed = zeros(num_labels,1);
%  y_transformed(y(i)) = 1;
%  delta3 = h - y_transformed;
  #size(Theta2)
  #size(delta3)
%  delta2 = (Theta2'*delta3)(2:end).*sigmoidGradient(z2);
%  Theta2_grad = Theta2_grad + delta3*a2';
%  Theta1_grad = Theta1_grad + delta2*a1';
%  end
%Theta1_grad = Theta1_grad ./ m + [zeros(hidden_layer_size,1) lambda/m*Theta1(:,2:end)];
%Theta2_grad = Theta2_grad ./ m + [zeros(num_labels,1) lambda/m*Theta2(:,2:end)]; 
%====Vecorization implementation=====
Delta3 = h - y_transformed; %m * num_labels
Delta2 =(Delta3*Theta2)(:,2:end).*sigmoidGradient(Z2); %m * hidden_layer_size

Theta1_grad = 1/m * Delta2' * A1 + [zeros(hidden_layer_size,1) lambda/m*Theta1(:,2:end)];
Theta2_grad = 1/m * Delta3' * A2 + [zeros(num_labels,1) lambda/m*Theta2(:,2:end)]; 
% -------------------------------------------------------------

% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];


end
