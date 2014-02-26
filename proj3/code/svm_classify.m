% Starter code prepared by James Hays for CS 143, Brown University

%This function will train a linear SVM for every category (i.e. one vs all)
%and then use the learned linear classifiers to predict the category of
%every test image. Every test feature will be evaluated with all 15 SVMs
%and the most confident SVM will "win". Confidence, or distance from the
%margin, is W*X + B where '*' is the inner product or dot product and W and
%B are the learned hyperplane parameters.

function predicted_categories = svm_classify(train_image_feats, train_labels, test_image_feats)
% image_feats is an N x d matrix, where d is the dimensionality of the
%  feature representation.
% train_labels is an N x 1 cell array, where each entry is a string
%  indicating the ground truth category for each training image.
% test_image_feats is an M x d matrix, where d is the dimensionality of the
%  feature representation. You can assume M = N unless you've modified the
%  starter code.
% predicted_categories is an M x 1 cell array, where each entry is a string
%  indicating the predicted category for each test image.

%{
Useful functions:
 matching_indices = strcmp(string, cell_array_of_strings)
 
  This can tell you which indices in train_labels match a particular
  category. This is useful for creating the binary labels for each SVM
  training task.

[W B] = vl_svmtrain(features, labels, LAMBDA)
  http://www.vlfeat.org/matlab/vl_svmtrain.html

  This function trains linear svms based on training examples, binary
  labels (-1 or 1), and LAMBDA which regularizes the linear classifier
  by encouraging W to be of small magnitude. LAMBDA is a very important
  parameter! You might need to experiment with a wide range of values for
  LAMBDA, e.g. 0.00001, 0.0001, 0.001, 0.01, 0.1, 1, 10.

  Matlab has a built in SVM, see 'help svmtrain', which is more general,
  but it obfuscates the learned SVM parameters in the case of the linear
  model. This makes it hard to compute "confidences" which are needed for
  one-vs-all classification.

%}

%unique() is used to get the category list from the observed training
%category list. 'categories' will not be in the same order as in proj3.m,
%because unique() sorts them. This shouldn't really matter, though.
categories = unique(train_labels); 
%each row is a different set of svm params (different category)
svm_paramsW=zeros(size(categories,1),size(train_image_feats,2));
svm_paramsB=zeros(size(categories,1),1);


global K;

FUNCTION='linear';
switch lower(FUNCTION),
    case 'linear'
        for i=1:length(categories),

            cat=categories(i);
            labels=zeros(size(train_labels))-1;
            indices=find(strcmp(cat,train_labels)==1);
            labels(indices)=1;
            %bag of words .0001
            [W,B]=vl_svmtrain(train_image_feats',labels,0.0001);

            svm_paramsW(i,:)=W';%sol
            svm_paramsB(i)=B; %b




        end

        predicted_categories=[];

        for i=1:size(test_image_feats,1),
            feat=test_image_feats(i,:);
            val_vector=(svm_paramsW*feat')+svm_paramsB;
            [C,I]=max(val_vector);
            predicted_categories{end+1}=categories{I};

        end
        predicted_categories=predicted_categories';
%end

    case 'rbf'
        x=train_image_feats;
        y=test_image_feats;
        sig=.4;
        x2=sum(x.^2,2);
        y2=sum(y.^2,2);
        dist=repmat(x2,1,length(x2))+repmat(y2',length(y2),1)-2*x*y';
        K = exp(-dist/(2*sig^2));
        
        rbf=zeros(size(test_image_feats,1),length(categories));
        predicted_categories=zeros(size(test_image_feats,1),1);
        
        for i=1:length(categories),

            cat=categories(i);
            labels=zeros(size(train_labels))-1;
            indices=find(strcmp(cat,train_labels)==1);
            labels(indices)=1;

            [w,b]=primal_svm(0,labels,10); 
            
            rbf(:,i)=K*w+b;
            


        end

        predicted_categories=[];

        for i=1:size(test_image_feats,1),
            [m,i]=max(rbf(i,:));
            predicted_categories{end+1}=categories{i};

        end
        predicted_categories=predicted_categories';
end

