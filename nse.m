function ret = nse(Q_sim,Q_obs)
            ret=0;
            
        neg_ind_sim=find(Q_sim>=0);
        neg_ind_obs=find(Q_obs>=0);
        neg_ind=intersect(neg_ind_sim,neg_ind_obs);
        dat1=Q_sim(neg_ind);
        dat2=Q_obs(neg_ind);
        out_r=corrcoef(dat1,dat2);
        out_rmse=sqrt(mean((dat1 - dat2).^2));
        out_per_rmse=out_rmse./mean(dat2);
        
        E = dat1 - dat2;
        SSE = sum(E.^2);
        u = mean(dat2);
        SSU = sum((dat2 - u).^2);

        NSout = 1 - SSE/SSU;
            
    ret=-NSout;
end