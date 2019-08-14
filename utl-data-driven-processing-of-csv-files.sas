
Data driven processing of csv files                                                                                   
                                                                                                                      
No need for 'proc export' - datastep more fexible and shorted with error checking?                                    
                                                                                                                      
SAS forum                                                                                                             
https://tinyurl.com/yyordr6n                                                                                          
https://communities.sas.com/t5/SAS-Programming/quoting-issues/m-p/581216                                              
                                                                                                                      
*_                   _                                                                                                
(_)_ __  _ __  _   _| |_                                                                                              
| | '_ \| '_ \| | | | __|                                                                                             
| | | | | |_) | |_| | |_                                                                                              
|_|_| |_| .__/ \__,_|\__|                                                                                             
        |_|                                                                                                           
;                                                                                                                     
                                                                                                                      
data meta;                                                                                                            
 input file firstob lastob;                                                                                           
cards4;                                                                                                               
1 1 2                                                                                                                 
2 2 4                                                                                                                 
3 4 6                                                                                                                 
;;;;                                                                                                                  
run;quit;                                                                                                             
                                                                                                                      
data hav1 hav2 hav3;                                                                                                  
  set sashelp.class(keep=name age sex);                                                                               
  select (mod(_n_,3));                                                                                                
     when (2) output hav1;                                                                                            
     when (1) output hav2;                                                                                            
     when (0) output hav3;                                                                                            
  end; * no need for otherwise;                                                                                       
run;quit;                                                                                                             
                                                                                                                      
                                                                                                                      
WORK.META total obs=3                                                                                                 
                                                                                                                      
 FILENUM FIRSTOB    LASTOB                                                                                            
                                                                                                                      
   1       1          2                                                                                               
   2       2          4                                                                                               
   3       4          6    RULE CSV file3 will have obs 4-6                                                           
                                                                                                                      
                                                                                                                      
 THREE INPUT TABLES                                                                                                   
                                                                                                                      
           WORK.HAV1                WORK.HAV2                 WORK.HAV3      |                                        
     -------------------    ---------------------     ---------------------  |                                        
Obs  NAME     SEX    AGE    NAME       SEX    AGE     NAME       SEX    AGE  |                                        
                                                                             |  RULE CSV File 3 has obs 4-6           
 1  Alice      F      13    Alfred      M      14     Barbara     F      13  |                                        
 2  Henry      M      14    Carol       F      14     James       M      12  |     d:/csv/aug19_3                     
 3  Janet      F      15    Jane        F      12     Jeffrey     M      13  |     --------------                     
 4  Joyce      F      11    John        M      12     Judy        F      14  |  -  Judy;F;14                          
 5  Mary       F      15    Louise      F      12     Philip      M      16  |   | Philip;M;16                        
 6  Ronald     M      15    Robert      M      12     Thomas      M      11  |  -  Thomas;M;11                        
 7                          William     M      15                                                                     
                                                                                                                      
*            _               _                                                                                        
  ___  _   _| |_ _ __  _   _| |_                                                                                      
 / _ \| | | | __| '_ \| | | | __|                                                                                     
| (_) | |_| | |_| |_) | |_| | |_                                                                                      
 \___/ \__,_|\__| .__/ \__,_|\__|                                                                                     
                |_|                                                                                                   
;                                                                                                                     
                                                                                                                      
 WORK.LOG total obs=3                                                                                                 
                                                                                                                      
        STATUS          FIRSTOB    LASTOB                                                                             
                                                                                                                      
  AUG19_1 SUCCESSFUL       1          2                                                                               
  AUG19_2 SUCCESSFUL       2          4                                                                               
  AUG19_3 SUCCESSFUL       4          6                                                                               
                                                                                                                      
                                                                                                                      
Three CSV files                                                                                                       
                                                                                                                      
d:/csv/aug19_1 (obs 1-2 from hav1)                                                                                    
                                                                                                                      
NAME;SEX;AGE                                                                                                          
Alice;F;13                                                                                                            
Henry;M;14                                                                                                            
                                                                                                                      
d:/csv/aug19_2 (obs 2-4 from hav2)                                                                                    
                                                                                                                      
NAME;SEX;AGE                                                                                                          
Carol;F;14                                                                                                            
Jane;F;12                                                                                                             
John;M;12                                                                                                             
                                                                                                                      
d:/csv/aug19_3 (obs 4-6 from hav3)                                                                                    
                                                                                                                      
NAME;SEX;AGE                                                                                                          
Judy;F;14                                                                                                             
Philip;M;16                                                                                                           
Thomas;M;11                                                                                                           
                                                                                                                      
*          _       _   _                                                                                              
 ___  ___ | |_   _| |_(_) ___  _ __                                                                                   
/ __|/ _ \| | | | | __| |/ _ \| '_ \                                                                                  
\__ \ (_) | | |_| | |_| | (_) | | | |                                                                                 
|___/\___/|_|\__,_|\__|_|\___/|_| |_|                                                                                 
                                                                                                                      
;                                                                                                                     
                                                                                                                      
                                                                                                                      
data log;                                                                                                             
  retain status;                                                                                                      
  set meta end=dne;                                                                                                   
                                                                                                                      
  call symputx('firstob',firstob);                                                                                    
  call symputx('lastob',lastob);                                                                                      
  call symputx('file',file);                                                                                          
                                                                                                                      
  rc=dosubl('                                                                                                         
      data _null_;                                                                                                    
            file "d:/csv/aug19_&file..csv";                                                                           
            set hav&file.                                                                                             
                  (firstobs=&firstob OBS=&lastob);                                                                    
            if _n_=1 then put "%utl_varlist(hav&file,od=%str(;))";                                                    
            put (_all_) ( $ +(-1) ";");                                                                               
      run;quit;                                                                                                       
      %let cc=&syserr;                                                                                                
  ');                                                                                                                 
                                                                                                                      
   if symgetn('cc')=0 then status=cats("AUG19_",file," SUCCESSFUL");                                                  
   else do;                                                                                                           
      status="AUG19_&filenum FAILED STOPPING";                                                                        
      stop;                                                                                                           
   end;                                                                                                               
   drop rc file;                                                                                                      
run;quit;                                                                                                             
                                                                                                                      
                                                                                                                      
