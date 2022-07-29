
%%

[gw_predictions, gw_scores] = bc_mdl_final.predict(data_gw( :, {'Age','Sex','HGB','RBC','WBC','MCV','PLT'})) ;

%gw_scores = calc_score(gw_scores) ;
gw_scores = gw_scores(:,2) ;
gw_label = data_gw.Label == "Sepsis" ;

data_gw.Scores = gw_scores ;
[gw_rocx, gw_rocy, ~, gw_auc] = perfcurve(data_gw.Label,gw_scores, 'Sepsis') ;
[~,gw_auc_ci] = auc([gw_label gw_scores],0.05, 'mann-whitney') ;


% apply scaling function to scores
data_gw.Scores = 1./(1+exp(-median(data_gw.Scores)*(data_gw.Scores-median(data_gw.Scores)))) ;


%plot(gw_rocx, gw_rocy)