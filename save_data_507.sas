libname nbbo '/home/columbia/zd2216/new';
run;

data nbbo_20141203_new;
	set work.nbbo_20141203;
	WHERE (TIME BETWEEN "09:30:00"t AND "15:59:59"t)
    AND BB>5 AND BO>5
    /* 3 tickers for long-lived predictors */
    AND SYMBOL IN ("IWB", "IWM", "SPY"); % thi
    
proc export data=work.nbbo_20141203_new
	outfile='/home/columbia/zd2216/new/market_20141203.csv'
	
	dbms=csv
	replace;
run;