libname Predmod "E:\Pranesh\GMAT\MS in Analytics\UTD\CoursWork\MKT 6337 - Predictive Marketing Analytics\Project\mustketc\SAS Datasets";

proc print data = Predmod.ketchuppanel(obs = 20);run;
data Predmod.ketchuppanel(drop = SY GE VEND ITEM Parent_Company Vendor VOL_EQ PRODUCT_TYPE);
PU = DOLLARS/UNITS;
set Predmod.ketchuppanel;
run;

/* -------------------------------------------------------------starting regression----------------------------------------------------------*/
/*36 Ounces*/
data regress36;
set Predmod.ketchuppanel;
if Oz = 36;
if D = 1 then D1 = 1;else D1 = 0;
if D = 2 then D2 = 1;else D2 = 0;
if F = "A" then F_A = 1;else F_A = 0;
if F = "A+" then F_Aplus = 1;else F_Aplus =0;
if F = "B" then F_B = 1;else F_B = 0;
if F = "C" then F_C =1;else F_C = 0;
run;
proc freq data = regress36;table F;run;

proc freq data = regress36;table brand;run;

/* Splitting the data into 3 brands to perform competition analysis*/
data regress36_he regress36_hu regress36_del;
set regress36;
if brand = "HEINZ" then output regress36_he;
if brand = "HUNTS" then output regress36_hu;
if brand = "DEL MONTE CLASSICS" then output regress36_del;
run;

/* My market is Hunts...*/
/* so modifying my heinz data*/
proc print data = regress36_he(obs = 20);run;
proc sql;
create table regress36_he1 as select IRI_KEY, WEEK, avg(D1) as He_D1, avg(D2) as He_D2, avg(F_A) as He_FA, avg(F_Aplus) as He_FAplus, avg(F_B)
as He_FB, avg(F_C) as He_FC, avg(PR) as He_PR, avg(PU) as He_PU, sum(UNITS) as He_Units from regress36_he group by IRI_key, week;

/* Modifying Del Momte data*/
proc sql;
create table regress36_del1 as select IRI_KEY, WEEK, avg(D1) as Del_D1, avg(D2) as Del_D2, avg(F_A) as Del_FA, avg(F_Aplus) as Del_FAplus, avg(F_B)
as Del_FB, avg(F_C) as Del_FC, avg(PR) as Del_PR, avg(PU) as Del_PU, sum(UNITS) as Del_Units from regress36_del group by IRI_key, week;

/*Modifying the Hunts data to required format*/
proc sql;
create table regress36_hu1 as select IRI_KEY, WEEK, avg(D1) as D1, avg(D2) as D2, avg(F_A) as FA, avg(F_Aplus) as FAplus, avg(F_B)
as FB, avg(F_C) as FC, avg(PR) as PR, avg(PU) as PU, sum(UNITS) as Units, brand, market_name, store_type, Month, Year from regress36_hu 
group by IRI_key, week;



/* Now joining the 3 tables*/
proc sql;
create table regress as select * from regress36_Hu1, regress36_He1, regress36_del1 where 
regress36_Hu1.IRI_KEY = regress36_He1.IRI_KEY = regress36_del1.IRI_KEY and 
regress36_Hu1.WEEK = regress36_He1.WEEK = regress36_del1.WEEK;

proc print data = regress(obs = 20);run;

/*Panel Data Analysis*/
proc freq data = regress;table store_type;run;

data regress;
set regress;
if store_type = "Large" then store_type = 3;
if store_type = "Mediu" then store_type = 2;
if store_type = "Small" then store_type = 1;
if store_type = "V.Lar" then store_type = 4;
if year = "5" the year = 5;
if year = "4" the year = 4;
if year = "3" the year = 3;
if year = "2" the year = 2;
if year = "1" the year = 1;
D1PR = D1*PR;
D1PRFAplus = D1*PR*FAplus;
D2PR = D2*PR;
D2FAplus = D2*FAplus;
D1PRFC = D1*PR*FC;
D2FC = D2*FC;
/*num_year = input(Year,2.);
drop Year;
rename num_year = Year;
num_store_type = input(store_type,2.);
drop store_type;
rename num_store_type = store_type;*/
run;


proc sort data = regress;by Market_Name IRI_KEY WEEK ;run;
proc contents data = regress;run;
proc panel data = regress;
by Market_Name;
class store_type Month Year;
model Units = D1 D2 FA FAplus FB FC PR PU store_type Month He_D1 He_D2 He_FA He_FAplus He_FB He_FC He_PR He_PU He_Units Del_D1 
Del_D2 Del_FA Del_FAplus Del_FB Del_FC Del_PR Del_PU Del_Units Year D1PR D1PRFAplus D2PR D2FAplus D1PRFC D2FC;
id IRI_KEY WEEK;
run;
proc print data = regress(obs = 20);run;

proc freq data = regress;table market_name;run;

/* ----------------------------------------------------24 Oz -----------------------------------------------------------------*/

data regress24;
set Predmod.ketchuppanel;
if Oz = 24;
if D = 1 then D1 = 1;else D1 = 0;
if D = 2 then D2 = 1;else D2 = 0;
if F = "A" then F_A = 1;else F_A = 0;
if F = "A+" then F_Aplus = 1;else F_Aplus =0;
if F = "B" then F_B = 1;else F_B = 0;
if F = "C" then F_C =1;else F_C = 0;
run;

proc freq data = regress24;table brand;run;

data regress24_he regress24_hu regress24_del;
set regress24;
if brand = "HEINZ" or brand = "HEINZ EZ SQUIRT" then output regress24_he;
if brand = "HUNTS" then output regress24_hu;
if brand = "DEL MONTE" then output regress24_del;
run;


/* My market is Hunts...*/
/* so modifying my heinz data*/
proc print data = regress24_he(obs = 20);run;
proc sql;
create table regress24_he1 as select IRI_KEY, WEEK, avg(D1) as He_D1, avg(D2) as He_D2, avg(F_A) as He_FA, avg(F_Aplus) as He_FAplus, avg(F_B)
as He_FB, avg(F_C) as He_FC, avg(PR) as He_PR, avg(PU) as He_PU, sum(UNITS) as He_Units from regress24_he group by IRI_key, week;

/* Modifying Del Momte data*/
proc sql;
create table regress24_del1 as select IRI_KEY, WEEK, avg(D1) as Del_D1, avg(D2) as Del_D2, avg(F_A) as Del_FA, avg(F_Aplus) as Del_FAplus, avg(F_B)
as Del_FB, avg(F_C) as Del_FC, avg(PR) as Del_PR, avg(PU) as Del_PU, sum(UNITS) as Del_Units from regress24_del group by IRI_key, week;

/*Modifying the Hunts data to required format*/
proc sql;
create table regress24_hu1 as select IRI_KEY, WEEK, avg(D1) as D1, avg(D2) as D2, avg(F_A) as FA, avg(F_Aplus) as FAplus, avg(F_B)
as FB, avg(F_C) as FC, avg(PR) as PR, avg(PU) as PU, sum(UNITS) as Units, brand, market_name, store_type, Month, Year from regress24_hu 
group by IRI_key, week;

/* Full Merge*/
proc sql;
create table regress as select * from regress24_Hu1, regress24_He1, regress24_del1 where 
regress24_Hu1.IRI_KEY = regress24_He1.IRI_KEY = regress24_del1.IRI_KEY and 
regress24_Hu1.WEEK = regress24_He1.WEEK = regress24_del1.WEEK;


data regress;
set regress;
if store_type = "Large" then store_type = 3;
if store_type = "Mediu" then store_type = 2;
if store_type = "Small" then store_type = 1;
if store_type = "V.Lar" then store_type = 4;
if year = "5" the year = 5;
if year = "4" the year = 4;
if year = "3" the year = 3;
if year = "2" the year = 2;
if year = "1" the year = 1;
D1PR = D1*PR;
D1PRFAplus = D1*PR*FAplus;
D2PR = D2*PR;
D2FAplus = D2*FAplus;
D1PRFC = D1*PR*FC;
D2FC = D2*FC;
/*num_year = input(Year,2.);
drop Year;
rename num_year = Year;
num_store_type = input(store_type,2.);
drop store_type;
rename num_store_type = store_type;*/
run;

ods graphics off;
proc sort data = regress;by Market_Name IRI_KEY WEEK ;run;
proc contents data = regress;run;
proc panel data = regress;
by Market_Name;
class store_type Month Year;
model Units = D1 D2 FA FAplus FB FC PR PU store_type Month He_D1 He_D2 He_FA He_FAplus He_FB He_FC He_PR He_PU He_Units Del_D1 
Del_D2 Del_FA Del_FAplus Del_FB Del_FC Del_PR Del_PU Del_Units Year D1PR D1PRFAplus D2PR D2FAplus D1PRFC D2FC;
id IRI_KEY WEEK;
run;

proc freq data = regress;table market_name;run;
