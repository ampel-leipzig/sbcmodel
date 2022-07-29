[le_val_predictions, le_val_scores] = bc_mdl_final.predict(data_le_val( :, {'Age','Sex','HGB','RBC','WBC','MCV','PLT'})) ;

%le_val_scores = calc_score(le_val_scores) ;
le_val_scores = le_val_scores(:,2) ;
le_val_label = data_le_val.Label == "Sepsis" ;

data_le_val.Scores = le_val_scores ;
[le_val_rocx, le_val_rocy, ~, le_val_auc] = perfcurve(data_le_val.Label,le_val_scores, 'Sepsis') ;
[~,le_val_auc_ci] = auc([le_val_label le_val_scores],0.05, 'mann-whitney') ;

%plot(le_val_rocx, le_val_rocy)

% score scaling
data_le_val.Scores = 1./(1+exp(-median(data_le_val.Scores)*(data_le_val.Scores-median(data_le_val.Scores)))) ;

%%
if 0
test_val = data_mimic ;
test_val.Label(test_val.SecToIcu<12*3600 & test_val.Diagnosis=="Sepsis") = "Sepsis" ;

[test_val_pred, test_val_scores] = bc_mdl_final.predict(test_val(:,{'Age','Sex','HGB','RBC','WBC','MCV','PLT'})) ;

test_val_scores = test_val_scores(:,2) ;
[~,~,~,test_val_auc] = perfcurve(test_val.Label, test_val_scores, 'Sepsis') ;
end