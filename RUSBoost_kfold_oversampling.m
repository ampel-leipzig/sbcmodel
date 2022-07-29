function [aucs,perf,rf] = RUSBoost_kfold(data,tars, diagnoses, ntrees, maxSplits, learnRate, overSampling_factor)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

% transform to logical in case its still a double
%tars = logical(tars);

k = 5 ;
partition = cvpartition(tars, 'kfold', k) ;

aucs = zeros(k,1) ;
perf = cell(k,1) ;
rf = cell(5,1) ;
for i=1:k
    
    data_training = data(partition.training(i),:) ;
    tars_training = tars(partition.training(i)) ;
    diag_training = diagnoses(partition.training(i)) ;
    
    Testing_data = data(partition.test(i),:) ;
    Testing_tar = tars(partition.test(i),:) ;
    
    extra_datapoints = data_training(tars_training=="Control" & diag_training=="Sepsis",:) ;
    extra_datapoints = repmat(extra_datapoints,overSampling_factor,1) ;
    
    extra_labels = tars_training(tars_training=="Control" & diag_training=="Sepsis",:) ;
    extra_labels = repmat(extra_labels, overSampling_factor, 1) ;
    
    tars_training = vertcat(tars_training, extra_labels) ;
    data_training = vertcat(data_training, extra_datapoints) ;
    
    
    N = size(data_training,1); % Number of observations in the training sample
    t = templateTree('MaxNumSplits', min([maxSplits N]));

    % best hyperparameters:
    % 495 trees
    % learn rate 0.90369
    % maxnumsplits 79
    % mdl = fitcensemble(data_training,tars_training,'Method','RUSBoost',...
    % 'ScoreTransform','none','Learners',t,'OptimizeHyperparameters',...
    % {'NumLearningCycles','LearnRate','MaxNumSplits'})
    mdl = fitcensemble(data_training,tars_training,'Method','RUSBoost', ...
    'NumLearningCycles',ntrees,'Learners',t, ...
    'LearnRate', learnRate,'ScoreTransform','none', ...
    'nprint',100);



[Testing_pred,Scores] = mdl.predict(Testing_data) ;
Scores = Scores(:,2) ;

%Testing_pred = cell2mat(Testing_pred);
%Testing_pred = str2num(Testing_pred);
%Testing_pred = logical(Testing_pred);

nPos = sum(Testing_tar== "Sepsis");
nNeg = numel(Testing_tar) - nPos ;

cm = confusionmat(Testing_tar, Testing_pred) ;
cm_raw = cm ;

cm(1,:) = cm(1,:)./ nNeg ;
cm(2,:) = cm(2,:)./ nPos ;

acc = sum(Testing_tar==Testing_pred)/numel(Testing_tar);

[x,y,thresholds,auc] = perfcurve(Testing_tar, Scores, "Sepsis") ;

perf_struct = struct() ;
perf_struct.acc = acc;
perf_struct.cm = cm ;
perf_struct.auc = auc;
perf_struct.rocx = x;
perf_struct.rocy = y;
perf_struct.idx_test = partition.test(i);


[pr_x, pr_y, ~, auc_pr] = perfcurve( Testing_tar, Scores, "Sepsis" ,'XCrit', 'reca', 'YCrit', 'prec') ;
perf_struct.pr_x = pr_x ;
perf_struct.pr_y = pr_y ;
perf_struct.auc_pr = auc_pr ;
perf_struct.cm_raw = cm_raw ;

%plot(x,y,'-r')

% 15.11.21
perf_struct.thresholds = thresholds ;
perf_struct.scores = Scores ;
aucs(i) = auc
perf{i} = perf_struct;

rf{i} = mdl ;

end
end