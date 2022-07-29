[mimic_predictions, mimic_scores] = bc_mdl_final.predict(data_mimic( :, {'Age','Sex','HGB','RBC','WBC','MCV','PLT'})) ;

mimic_scores = mimic_scores(:,2) ;
%mimic_scores = calc_score(mimic_scores) ;
mimic_label = data_mimic.Label=="Sepsis" ;

data_mimic.Scores = mimic_scores ;
[mimic_rocx, mimic_rocy, ~, mimic_auc] = perfcurve(data_mimic.Label,mimic_scores, "Sepsis") ;
[~,mimic_auc_ci] = auc([mimic_label mimic_scores], 0.05, 'mann-whitney') ;

data_mimic.Scores = 1./(1+exp(-median(data_mimic.Scores)*(data_mimic.Scores-median(data_mimic.Scores)))) ;

plot(mimic_rocx, mimic_rocy)