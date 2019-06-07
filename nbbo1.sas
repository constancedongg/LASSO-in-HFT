/* ********************************************************************************* */
/* ******************** W R D S   R E S E A R C H   M A C R O S ******************** */
/* ********************************************************************************* */
/* WRDS Macro: NBBO                                                                  */
/* Summary   : Simplistic NBBO Derivation using SAS Views                            */
/* Date      : September 7, 2010                                                     */
/* Author    : Rabih Moussawi, WRDS                                                  */
/* Variables : - YYYYMMDD is the Date Stamp for the Quote dataset                    */
/*             - OUTSET is the output dataset                                        */
/* ********************************************************************************* */
   
%MACRO NBBO (YYYYMMDD=19930104,OUTSET=nbbo);
options nonotes;
%put ;
%put ### START NBBO Calculation for: &YYYYMMDD ;
   
/* Preliminary: Create an Informat to Convert EX to Numeric */
/* Keep only Known Exchange Types: as Defined in TAQ Manual */
proc format;
  invalue ex_to_exn      /* informat to be used in an INPUT function */
      'A'=01   /*AMEX*/
      'N'=02   /*NYSE*/
      'B'=03   /*BOST*/
      'P'=04   /*ARCA*/
      'C'=05   /*NSX -National (Cincinnati) Stock Ex*/
      'T'=06   /*NASD*/
      'Q'=07   /*NASD*/
      'D'=08   /*NASD-ADF*/
      'X'=09   /*PHIL-NASDAQ OMX PSX*/
      'I'=10   /*ISE */
      'M'=11   /*CHIC*/
      'W'=12   /*CBOE*/
      'Z'=13   /*BATS*/
      'Y'=14   /*BATS Y-Ex*/
      'J'=15   /*DEAX-DirectEdge A*/
      'K'=16   /*DEXX-DirectEdge X*/
       otherwise=17  /* you can drop those quotes in the if statement */
      ;
run;
/* Additional Exchange Values */
/* 'E'=17   /*SIP -Market Independent (SIP - Generated)*/
/* 'S'=18   /*Consolidated Tape System*/
   
/* First, Generate Last Prevailing Quote for Each Exchange, every second */
data _quotes / view=_quotes;
     set taq.cq_&yyyymmdd;
     by symbol date time NOTSORTED ex; length EXN 3.;
/* Convert EX to EXN for easy array reference */
EXN=input(ex,ex_to_exn.);
/* Keep the last prevailing Quote by exchange from consecutive quotes every second */
if last.EX and 1 <= EXN <= 17;
label EXN="Exchange Code (numeric)";
drop EX MMID;
run;
   
/* Second, Derive NBBO from Prevailing Quotes Across Exchange */
data &outset (sortedby= SYMBOL DATE TIME index=(SYMBOL)
              label="WRDS-TAQ NBBO Data");
set _quotes;
by symbol date time;
/* Retain Observations within Each Time Block */
retain nexb1-nexb17 nexo1-nexo17 sexb1-sexb17 sexo1-sexo17;
array nexb nexb:; array nexo nexo:; array sexb sexb:; array sexo sexo:;
/* Step1. Reset NBBO for each new stock and at open and close */
if first.date or (lag(time)<"09:30:00"t <= time) or (lag(time) <= "16:00:00"t < time) then
do i=1 to 17;
  nexb(i)=.; nexo(i)=.; sexb(i)=.; sexo(i)=.;
end;
/* Step2. Quote Rule: Prevailing Quote Supersedes Previous Quote */
nexb(exn)=bid;nexo(exn)=ofr;sexb(exn)=bidsiz;sexo(exn)=ofrsiz;
/* Step3. Determined if Prevailing Quotes is Eligible for NBBO */
/* See TAQ Manual pp 26 and pp 27 for MODE and NBBO Definitions */
/* Regulatory Trading Halts: MODE in (4,7,9,11,13,14,16,20,21,27,28) */
/* See TickData.com for more information on filters */
if mode not in (1,2,6,10,12,23) or bid >= ofr
then do; nexb(exn)=.; nexo(exn)=.; sexb(exn)=.; sexo(exn)=.; end;
if bid <= 0.01 or bidsiz <= 0 then nexb(exn)=.;
if ofr <= 0    or ofrsiz <= 0 then nexo(exn)=.;
/* Step4. Calculate NBBO */
BB=max(of nexb:);
BO=min(of nexo:);
/* Step5. Calculate Bid and Ofr Sizes at NBBO */
BBSize=0; BOSize=0;  
do i=1 to 17;
 if BB=nexb(i) then BBSize=max(BBSize,sexb(i));
 if BO=nexo(i) then BOSize=max(BOSize,sexo(i));
end;
if missing(BB) then BBSize=.;
if missing(BO) then BOSize=.;
/* Report # of Exchanges with Qualifying Quotes */
length NUMEX 3.;
NUMEX=max(N(of nexb:),N(of nexo:));
/* Keep NBBO Information at the End of Each Second Interval */
if last.time then output;
label BB = 'Best Bid';
label BO = 'Best Offer';
label BBSize='Best Bid Size';
label BOSize='Best Offer Size';
label NUMEX='# of Exchanges with Prevailing Quotes used in the NBBO';
drop EXN MODE BID OFR nexb: nexo: i sexb: sexo: ofrsiz bidsiz;
run;
   
/* House Cleaning */
proc sql; drop view _quotes; quit;
options notes;
%put ### DONE. NBBO Data Saved as  : &outset ; %put ;
%mend;
   
/* ********************************************************************************* */
/* *************  Material Copyright Wharton Research Data Services  *************** */
/* ****************************** All Rights Reserved ****************************** */
/* ********************************************************************************* */


%nbbo(yyyymmdd=20141203,outset=nbbo_20141203);

