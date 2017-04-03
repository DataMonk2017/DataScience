function [X_norm, mu, sigma] = featureNormalize(X)
%FEATURENORMALIZE Normalizes the features in X 
%   FEATURENORMALIZE(X) returns a normalized version of X where
%   the mean value of each feature is 0 and the standard deviation
%   is 1. This is often a good preprocessing step to do when
%   working with learning algorithms.

% You need to set these values correctly
X_norm = X;
mu = zeros(1, size(X, 2));
sigma = zeros(1, size(X, 2));

% ====================== YOUR CODE HERE ======================
% Instructions: First, for each feature dimension, compute the mean
%               of the feature and subtract it from the dataset,
%               storing the mean value in mu. Next, compute the 
%               standard deviation of each feature and divide
%               each feature by it's standard deviation, storing
%               the standard deviation in sigma. 
%
%               Note that X is a matrix where each column is a 
%               feature and each row is an example. You need 
%               to perform the normalization separately for 
%               each feature. 
%
% Hint: You might find the 'mean' and 'std' functions useful.
% for loop way      
%for i = 1:size(X,2),
%  mu(i) = mean(X(:,i));
%  sigma(i) = std(X(:,i));
%  X_norm(:,i) = (X(:,i)-mu(i))/sigma(i);
%  end
mu = mean(X);
sigma = std(X);
X_norm = (X.-mu)./repmat(sigma,[],size(X,1));
%if we have itercept already
%X_norm = [ones(size(X,1),1),(X(:,2).-mu(2:end))./repmat(sigma(2:end),[],size(X,1))]





% ============================================================

end
