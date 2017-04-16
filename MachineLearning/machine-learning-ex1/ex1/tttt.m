% Choose some alpha value
alpha = 0.03;
num_iters = 50;

% Init Theta and Run Gradient Descent 
%figure;
theta = zeros(3, 1);
[theta, J_2] = gradientDescentMulti(X, y, theta, alpha, num_iters);
plot(1:50, J_2(1:50), 'r');
% Plot the convergence graph
%figure;
%plot(1:numel(J_1), J_1, '-b', 'LineWidth', 2);
plot(1:50, J_2(1:50), 'k');
xlabel('Number of iterations');
ylabel('Cost J');
hold on;
