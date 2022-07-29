% train 5-fold models
[aucs, perf, bc_mdls] = RUSBoost_kfold_oversampling(data_le(:,{'Age','Sex','HGB','RBC','WBC','MCV','PLT'}),data_le.Label,data_le.Diagnosis, ntrees, maxSplits, learn_rate , oversampling_factor) ;
auc_ci = prctile(aucs, [2.5 97.5]) ;
data_le.Scores = zeros(numel(data_le.Age),1) ;

for i=1:5
    data_le.Scores(perf{i}.idx_test) = perf{i}.scores ;
end
data_le.Scores = 1./(1+exp(-median(data_le.Scores)*(data_le.Scores-median(data_le.Scores)))) ;
%%
% train full model
    
temp_train_data = data_le ;

% multiply sepsis control datapoints
extra_datapoints = data_le(data_le.Label=="Control" & data_le.Diagnosis=="Sepsis",:) ;
extra_datapoints = repmat(extra_datapoints,oversampling_factor,1) ;

temp_train_data = vertcat(temp_train_data, extra_datapoints) ;
temp_train_labels = temp_train_data.Label ;
temp_train_data = temp_train_data(:,{'Age','Sex','HGB','RBC','WBC','MCV','PLT'}) ;

treeTemp = templateTree('MaxNumSplits', maxSplits);

bc_mdl_final = fitcensemble(temp_train_data,temp_train_labels,'Method','RUSBoost', ...
    'NumLearningCycles',ntrees,'Learners',treeTemp, ...
    'LearnRate', learn_rate ,'ScoreTransform','none', ...
    'nprint',100);

clear temp_train_data; clear temp_train_labels;