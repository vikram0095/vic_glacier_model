function [out_nse, out_r,out_rmse,out_per_rmse] = eval_performance(Q_sim,Q_obs)
            
        neg_ind_sim=find(Q_sim>=0);
        neg_ind_obs=find(Q_obs>=0);
        neg_ind=intersect(neg_ind_sim,neg_ind_obs);
        
        dat1=Q_sim(neg_ind);
        dat2=Q_obs(neg_ind);
        
        neg_ind_sim=find(~isnan(dat1));
        neg_ind_obs=find(~isnan(dat2));
        neg_ind=intersect(neg_ind_sim,neg_ind_obs);
        
        dat1=dat1(neg_ind);
        dat2=dat2(neg_ind);
        
        
        out_r=corrcoef(dat1,dat2);
        out_rmse=sqrt(mean((dat1 - dat2).^2));
        out_per_rmse=out_rmse./mean(dat2);
        
        E = dat1 - dat2;
        SSE = sum(E.^2);
        u = mean(dat2);
        SSU = sum((dat2 - u).^2);

        out_nse = 1 - SSE/SSU;
            
end