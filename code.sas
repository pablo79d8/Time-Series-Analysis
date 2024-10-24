
data pernoctaza;
        input pernoctaza;
		date=intnx('MONTH','01jan2000'd,_n_-1); 
		format date MONYY.;/*2000:1  2000:2  2000:3  2000:4  2000:5  ...   2000:12*/      * Construimos la fecha;
        cards;
17451
19983
25777
31255
37402
33992
74859
110975
48611
36880
26394
24240
18199
20588
25506
37577
28747
39291
77280
128001
53200
37641
34557
30013
16649
21906
35660
30764
38166
38696
78711
134114
51278
36350
32293
27158
14390
20681
31851
38681
41026
41506
79152
140398
53403
41226
31284
27302
18023
24674
33793
43271
42785
42399
83388
133266
53469
45937
31615
30505
19745
24103
43660
33732
39978
44849
76153
140852
56477
48101
32547
30227
22639
29584
37604
52467
42675
48813
81487
139727
53517
50543
37018
31285
25622
31610
42917
61267
45481
56423
80992
145958
56141
50925
40183
33401
25602
34029
49280
49384
46310
55357
80503
132669
58222
49017
39908
31732
24112
31671
39500
51798
43018
50079
71901
121420
53456
48013
39096
31001
23876
29264
38253
52303
46138
51357
72055
111326
54307
52070
37565
31666
23477
26684
34571
61219
45618
49233
64602
110158
56563
54005
35307
33495
24520
27971
34439
60014
47041
49125
63488
102073
56212
44295
34349
32807
25720
24581
42936
37834
42085
47439
59857
85838
51460
46825
37363
35584
23480
25661
32562
48266
43539
45586
66243
96424
47258
42852
36031
37108
23610
24124
36302
51245
45849
48265
59024
106071
51658
49147
38058
41780
25784
25715
49448
34863
44626
51477
69724
102963
54657
56547
39641
42317
27124
27330
40038
65817
52763
54741
71992
120724
62777
55815
41554
44811
32169
36575
55349
65037
59319
64145
81312
128866
78906
68825
53448
55101
35261
38545
51316
73997
64518
79508
88996
152287
80452
70968
57407
60917
;
proc arima data=pernoctaza plots(unpack)=all;  
		identify var=pernoctaza(1,12);
        run;
		*estimate q=(1)(12,24) p=(1)(12) method=ml;  					/* (1,1,1)(1,1,2) */
		*estimate q=(1)(12,24) p=(1) method=ml;  						/* (1,1,1)(0,1,2) */
		*estimate q=(1)(12,24) p=(1,2,3)(12) method=ml; 				/* (3,1,1)(1,1,2) */
		*estimate q=(1)(12,24) p=(1,2,3) method=ml noconstant; 					/* (3,1,1)(0,1,2) */
		*estimate q=(1)(12,24) p=(12) method=ml;						/* (0,1,1)(1,1,2) */
		*estimate q=(1)(12,24) method=ml;								/* (0,1,1)(0,1,2) */
		*estimate q=(1)(12) p=(1)(12) method=ml; 						/* (1,1,1)(1,1,1) */
		*estimate q=(1)(12) p=(1) method=ml;							/* (1,1,1)(0,1,1) */
		*estimate q=(1)(12) p=(12) method=ml; 							/* (0,1,1)(1,1,1) */
		*estimate q=(1)(12)  method=ml; 								/* (0,1,1)(0,1,1) */


        *forecast out=b lead=12 id=date interval=month;  
run;


/* Modelos SIN constante */
proc arima data=pernoctaza plots(unpack)=all;  
		identify var=pernoctaza(1,12);
        run;
		*estimate q=(1)(12,24) p=(1)(12) method=ml noconstant;  				/* (1,1,1)(1,1,2) */
		*estimate q=(1)(12,24) p=(12) method=ml noconstant;						/* (0,1,1)(1,1,2) */
		*estimate q=(1)(12,24) method=ml noconstant;							/* (0,1,1)(0,1,2) */
		*estimate q=(1)(12) p=(12) method=ml noconstant; 						/* (0,1,1)(1,1,1) */
		*estimate q=(1)(12)  method=ml noconstant; 								/* (0,1,1)(0,1,1) */

        *forecast out=b lead=12 id=date interval=month;  
run;


/* MODELOS SELECCIONADOS */
proc arima data=pernoctaza plots(unpack)=all ;  
		identify var=pernoctaza(1,12);
        run;
		*estimate q=(1)(12,24) p=(12) method=ml noconstant;							/* (0,1,1)(1,1,2) */
		*forecast out=m10 lead=24 id=date interval=month;  
		*estimate q=(1)(12,24) method=ml noconstant;								/* (0,1,1)(0,1,2) */
		*forecast out=m11 lead=24 id=date interval=month; 
		*estimate q=(1)(12)  method=ml noconstant; 									/* (0,1,1)(0,1,1) */
        *forecast out=m13 lead=24 id=date interval=month;  
		

		*estimate q=(12,24,36)  method=ml noconstant; 								/* (0,1,0)(0,1,3) */
        *forecast out=m15 lead=24 id=date interval=month;
		*estimate q=(12,24)  method=ml noconstant; 									/* (0,1,0)(0,1,2) */
        *forecast out=m15 lead=24 id=date interval=month;
 		*estimate p=(1,2,3) q=(12,24)  method=ml noconstant; 						/* (3,1,0)(0,1,2) */
        *forecast out=m16 lead=24 back=24 id=date interval=month;
		
run;
quit;




/* Analisis de Residuos */
proc timeseries data=m16 plots=(series acf);
		id date interval=month;
		var residual; 
		corr  ;
run;
proc univariate data=m16 normaltest all;
	var residual;
run;
* Calculo SSE;
data x;
set m16;
sum2+RESIDUAL*RESIDUAL;
var = sum2/_N_;
RUN;
quit;


proc timeseries data=m11 plots=(series acf);
		id date interval=month;
		var residual; 
		corr  ;
run;
proc univariate data=m11 normaltest all;
	var residual;
	run;
data x;
set m11;
sum2+RESIDUAL*RESIDUAL;
var = sum2/_N_;
RUN;
quit;



proc timeseries data=m13 plots=(series acf);
		id date interval=month;
		var residual; 
		corr  ;
run;
proc univariate data=m13 normaltest all;
	var residual;
run;
data x;
set m13;
sum2+RESIDUAL*RESIDUAL;
var = sum2/_N_;
RUN;
quit;





/* Comprobar la capacidad de predicción */
data b; set pernoctaza; if _N_ < 217;
run;
proc arima data=b plots(unpack)=all ;  
		identify var=pernoctaza(1,12);
        run;
		
		estimate q=(1)(12,24) method=ml noconstant;								/* (0,1,1)(0,1,2) */
		forecast out=m11b lead=24 id=date interval=month; 

		estimate q=(1)(12)  method=ml noconstant; 									/* (0,1,1)(0,1,1) */
        forecast out=m13b lead=24 id=date interval=month;  
		
 		estimate p=(1,2,3) q=(12,24)  method=ml noconstant; 						/* (3,1,0)(0,1,2) */
        forecast out=m16b lead=24 id=date interval=month;
		
run;
quit;
data w; set pernoctaza; if _N_ > 216;
run;
data m11w; set m11b; keep FORECAST; if _N_>216; rename forecast=forecnm;
run;
data m13w; set m13b; keep FORECAST; if _N_>216; rename forecast=forecnm;
run;
data m16w; set m16b; keep FORECAST; if _N_>216; rename forecast=forecnm;
run;

* para modelo 11;
data r11; merge w m11w; residuals = pernoctaza - forecnm;
run;
data x;
set r11;
sum2+RESIDUALs*RESIDUALs;
var = sum2/_N_;
RUN;
quit;

*modelo 13;
data r13; merge w m13w; residuals = pernoctaza - forecnm;
run;
data x;
set r13;
sum2+RESIDUALs*RESIDUALs;
var = sum2/_N_;
RUN;
quit;

*modelo 16;
data r16; merge w m16w; residuals = pernoctaza - forecnm;
run;
data x;
set r16;
sum2+RESIDUALs*RESIDUALs;
var = sum2/_N_;
RUN;
quit;
