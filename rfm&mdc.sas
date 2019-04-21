libname cc 'H:\SAS';
DATA cc.panel;
INFILE "H:\SAS\factiss_PANEL_GR_1114_1165.DAT" DLM = "09"x FIRSTOBS = 2 ;
INPUT PANID	WEEK UNITS $OUTLET$ DOLLARS IRI_KEY COLUPC;
RUN;

data cc.panel2;
set cc.panel;
upc = put(colupc,z13.);
run;

PROC IMPORT DATAFILE='H:\SAS\prod_tissue.xls'
	DBMS=XLS
	replace
	OUT=cc.import;
	GETNAMES=YES;
	run;

data cc.b1;
set cc.import;
sy1 = sy*1; 
ge1 = ge*1;
vend1 = vend*1;
item1 = item*1;
sy2 = put(sy1,z2.);
vend2 = put(vend1,z5.);
item2 = put(item1,z5.);
key = catt(sy2,ge1,vend2,item2);run;

data cc.brand;
set cc.b1;
keep key l3;
run;

proc freq data= cc.brand;
table l3 ;
run;

PROC IMPORT DATAFILE='H:\SAS\ads demo1.csv'
	DBMS=csv
	replace
	OUT=cc.IMPORT1;
	GETNAMES=YES;
RUN;
proc sql;
create table cc.panel_d as 
select a.*,b.* from cc.panel2 a left join cc.import1 b on a.panid = b.Panelist_ID order by panid;run;

proc sql;
create table cc.panel_data as
select a.*,b.l3 from cc.panel_d a left join cc.brand b on a.upc = b.key order by panid;run;

/*data cc.panel_data;
set cc.panel_data;
where l3 = 'PRIVATE LABEL';
run;*/
/*data cc.panel_data;
set cc.panel_data;
where l3 = 'KIMBERLY CLARK CORP';
run;*/
data cc.panel_data;
set cc.panel_data;
where l3 = 'IRVING TISSUE CONVERTERS';
run;


proc sql;
select distinct PANID from cc.panel_data; run;

/*RFM*/

proc sql;
create table cc.mon as
select distinct PANID,sum(Dollars) as monetory_amount,max(week) as Recency, count(1) as Frequency from cc.panel group by PANID order by monetory_amount desc;
run;

/*proc sql;
select PANID, sum(dollars) as a from cc.b1 group by PANID order by a desc;
run;
proc sql;
select PANID, max(week) as Recency from cc.d1 group by PANID order by recency desc;
run;
proc sql;
select PANID,count(1) as Frequency from cc.d1 group by PANID order by frequency desc;
run;*/
proc sql;
create table cc.rfm as select 
PANID, 
case when Recency between 1155 and  1165 then 3
when Recency between 1135 and  1154 then 2
end as R,
case when frequency > 15 then 3
when frequency between 5 and 14 then 2
else 1
end as F, 
case when monetory_amount > 75 then 3 
when monetory_amount between 25 and 74 then 2
else 1 
end as M
from cc.mon;
run;

proc sql;
create table cc.RFM_Final as 
select PANID, R, F, M, R*100+F*10+M as RFM_Code from cc.rfm order by RFM_Code desc;
run;

/*Combining two*/
proc sql;
create table cc.clst as
select a.*, b.R, b.F, b.M, b.RFM_Code from cc.panel_data a left join cc.RFM_Final b on a.PANID = b.PANID; run;

/*based on monetory amount*/
proc sort data = cc.clst; by M; run;

proc means data = cc.clst;
by M;
var R F M RFM_Code Combined_Pre_Tax_Income_of_HH Family_Size HH_RACE Type_of_Residential_Possession
Age_Group_Applied_to_Male_HH Education_Level_Reached_by_Male Occupation_Code_of_Male_HH Male_Working_Hour_Code 
Age_Group_Applied_to_Female_HH Education_Level_Reached_by_Femal Occupation_Code_of_Female_HH Female_Working_Hour_Code 
Number_of_Dogs Number_of_Cats Children_Group_Code Marital_Status Year;
run;

/*based on frequency*/
proc sort data = cc.clst; by F; run;

proc means data = cc.clst;
by F;
var R F M RFM_Code Combined_Pre_Tax_Income_of_HH Family_Size HH_RACE Type_of_Residential_Possession
Age_Group_Applied_to_Male_HH Education_Level_Reached_by_Male Occupation_Code_of_Male_HH Male_Working_Hour_Code 
Age_Group_Applied_to_Female_HH Education_Level_Reached_by_Femal Occupation_Code_of_Female_HH Female_Working_Hour_Code 
Number_of_Dogs Number_of_Cats Children_Group_Code Marital_Status Year;
run;

/*based on recency*/

proc sort data = cc.clst; by R; run;

proc means data = cc.clst;
by R;
var R F M RFM_Code Combined_Pre_Tax_Income_of_HH Family_Size HH_RACE Type_of_Residential_Possession
Age_Group_Applied_to_Male_HH Education_Level_Reached_by_Male Occupation_Code_of_Male_HH Male_Working_Hour_Code 
Age_Group_Applied_to_Female_HH Education_Level_Reached_by_Femal Occupation_Code_of_Female_HH Female_Working_Hour_Code 
Number_of_Dogs Number_of_Cats Children_Group_Code Marital_Status Year;
run;

/*based on rfm code*/
proc sort data = cc.clst; by RFM_Code; run;

proc means data = cc.clst;
by RFM_Code;
var R F M RFM_Code Combined_Pre_Tax_Income_of_HH Family_Size HH_RACE Type_of_Residential_Possession
Age_Group_Applied_to_Male_HH Education_Level_Reached_by_Male Occupation_Code_of_Male_HH Male_Working_Hour_Code 
Age_Group_Applied_to_Female_HH Education_Level_Reached_by_Femal Occupation_Code_of_Female_HH Female_Working_Hour_Code 
Number_of_Dogs Number_of_Cats Children_Group_Code Marital_Status Year;
run;

proc tabulate data = cc.clst out = cc.graph1;
var RFM_Code Combined_Pre_Tax_Income_of_HH Family_Size HH_RACE Type_of_Residential_Possession
Age_Group_Applied_to_Male_HH Education_Level_Reached_by_Male Occupation_Code_of_Male_HH Male_Working_Hour_Code 
Age_Group_Applied_to_Female_HH Education_Level_Reached_by_Femal Occupation_Code_of_Female_HH Female_Working_Hour_Code 
Number_of_Dogs Number_of_Cats Children_Group_Code Marital_Status Year;
class R;
format R;
table R = ' ',
n pctn='Market Share' (RFM_Code Combined_Pre_Tax_Income_of_HH Family_Size HH_RACE Type_of_Residential_Possession
Age_Group_Applied_to_Male_HH Education_Level_Reached_by_Male Occupation_Code_of_Male_HH Male_Working_Hour_Code 
Age_Group_Applied_to_Female_HH Education_Level_Reached_by_Femal Occupation_Code_of_Female_HH Female_Working_Hour_Code 
Number_of_Dogs Number_of_Cats Children_Group_Code Marital_Status Year) * mean = ' '/box = 'Cluster';
run;

proc tabulate data = cc.clst out = cc.graph1;
var RFM_Code Combined_Pre_Tax_Income_of_HH Family_Size HH_RACE Type_of_Residential_Possession
Age_Group_Applied_to_Male_HH Education_Level_Reached_by_Male Occupation_Code_of_Male_HH Male_Working_Hour_Code 
Age_Group_Applied_to_Female_HH Education_Level_Reached_by_Femal Occupation_Code_of_Female_HH Female_Working_Hour_Code 
Number_of_Dogs Number_of_Cats Children_Group_Code Marital_Status Year;
class F;
format F;
table F = ' ',
n pctn='Market Share' (RFM_Code Combined_Pre_Tax_Income_of_HH Family_Size HH_RACE Type_of_Residential_Possession
Age_Group_Applied_to_Male_HH Education_Level_Reached_by_Male Occupation_Code_of_Male_HH Male_Working_Hour_Code 
Age_Group_Applied_to_Female_HH Education_Level_Reached_by_Femal Occupation_Code_of_Female_HH Female_Working_Hour_Code 
Number_of_Dogs Number_of_Cats Children_Group_Code Marital_Status Year) * mean = ' '/box = 'Cluster';
run;

proc tabulate data = cc.clst out = cc.graph1;
var RFM_Code Combined_Pre_Tax_Income_of_HH Family_Size HH_RACE Type_of_Residential_Possession
Age_Group_Applied_to_Male_HH Education_Level_Reached_by_Male Occupation_Code_of_Male_HH Male_Working_Hour_Code 
Age_Group_Applied_to_Female_HH Education_Level_Reached_by_Femal Occupation_Code_of_Female_HH Female_Working_Hour_Code 
Number_of_Dogs Number_of_Cats Children_Group_Code Marital_Status Year;
class M;
format M;
table M = ' ',
n pctn='Market Share' (RFM_Code Combined_Pre_Tax_Income_of_HH Family_Size HH_RACE Type_of_Residential_Possession
Age_Group_Applied_to_Male_HH Education_Level_Reached_by_Male Occupation_Code_of_Male_HH Male_Working_Hour_Code 
Age_Group_Applied_to_Female_HH Education_Level_Reached_by_Femal Occupation_Code_of_Female_HH Female_Working_Hour_Code 
Number_of_Dogs Number_of_Cats Children_Group_Code Marital_Status Year) * mean = ' '/box = 'Cluster';
run;

proc tabulate data = cc.clst out = cc.graph1;
var Combined_Pre_Tax_Income_of_HH Family_Size HH_RACE Type_of_Residential_Possession
Age_Group_Applied_to_Male_HH Education_Level_Reached_by_Male Occupation_Code_of_Male_HH Male_Working_Hour_Code 
Age_Group_Applied_to_Female_HH Education_Level_Reached_by_Femal Occupation_Code_of_Female_HH Female_Working_Hour_Code 
Number_of_Dogs Number_of_Cats Children_Group_Code Marital_Status Year;
class RFM_Code;
format RFM_Code;
table RFM_Code = ' ',
n pctn='Market Share' ( Combined_Pre_Tax_Income_of_HH Family_Size HH_RACE Type_of_Residential_Possession
Age_Group_Applied_to_Male_HH Education_Level_Reached_by_Male Occupation_Code_of_Male_HH Male_Working_Hour_Code 
Age_Group_Applied_to_Female_HH Education_Level_Reached_by_Femal Occupation_Code_of_Female_HH Female_Working_Hour_Code 
Number_of_Dogs Number_of_Cats Children_Group_Code Marital_Status) * mean = ' '/box = 'Cluster';
run;

/*proc sql;
create table cc.FC as select 
PANID, 
case when RFM_Code in (551,552,553,554,555) then 5
when RFM_Code in (531,532,533,541,542,543) then 4
when RFM_Code in (511,512,513,521,522,523) then 3
when RFM_Code in (411,421,422,431,432,441) then 2
else 1
end as cluster
from cc.clst;
run;
proc sql;
create table cc.clst1 as
select distinct a.*, b.cluster from cc.clst a left join cc.FC b on a.PANID = b.PANID; run;
proc tabulate data = cc.clst1 out = cc.graph1;
var RFM_Code Combined_Pre_Tax_Income_of_HH Family_Size HH_RACE Type_of_Residential_Possession
Age_Group_Applied_to_Male_HH Education_Level_Reached_by_Male Occupation_Code_of_Male_HH Male_Working_Hour_Code 
Age_Group_Applied_to_Female_HH Education_Level_Reached_by_Femal Occupation_Code_of_Female_HH Female_Working_Hour_Code 
Number_of_Dogs Number_of_Cats Children_Group_Code Marital_Status;
class cluster;
format cluster;
table cluster = ' ',
n pctn='Market Share' (RFM_Code Combined_Pre_Tax_Income_of_HH Family_Size HH_RACE Type_of_Residential_Possession
Age_Group_Applied_to_Male_HH Education_Level_Reached_by_Male Occupation_Code_of_Male_HH Male_Working_Hour_Code 
Age_Group_Applied_to_Female_HH Education_Level_Reached_by_Femal Occupation_Code_of_Female_HH Female_Working_Hour_Code 
Number_of_Dogs Number_of_Cats Children_Group_Code Marital_Status) * mean = ' '/box = 'Cluster';
run;
*/
/*proc tabulate data = cc.clst1 out = graph1;
var RFM_Code Combined_Pre_Tax_Income_of_HH Family_Size HH_RACE Type_of_Residential_Possession
Age_Group_Applied_to_Male_HH Education_Level_Reached_by_Male Occupation_Code_of_Male_HH Male_Working_Hour_Code 
Age_Group_Applied_to_Female_HH Education_Level_Reached_by_Femal Occupation_Code_of_Female_HH Female_Working_Hour_Code 
Number_of_Dogs Number_of_Cats Children_Group_Code Marital_Status;
class cluster;
format cluster;
table cluster = ' ',
n pctn='Market Share' (RFM_Code Combined_Pre_Tax_Income_of_HH Family_Size HH_RACE Type_of_Residential_Possession
Age_Group_Applied_to_Male_HH Education_Level_Reached_by_Male Occupation_Code_of_Male_HH Male_Working_Hour_Code 
Age_Group_Applied_to_Female_HH Education_Level_Reached_by_Femal Occupation_Code_of_Female_HH Female_Working_Hour_Code 
Number_of_Dogs Number_of_Cats Children_Group_Code Marital_Status) * mean = ' '/box = 'Cluster';
run;*/

/*MDC*/
libname cc 'E:\ninja';
DATA cc.panel;
INFILE "E:\ninja\factiss_PANEL_GR_1114_1165.DAT" DLM = "09"x FIRSTOBS = 2 ;
INPUT PANID	WEEK UNITS $OUTLET$ DOLLARS IRI_KEY COLUPC;
RUN;
data cc.panel2;
set cc.panel;
upc = put(colupc,z13.);
run;
PROC IMPORT DATAFILE='E:\ninja\prod_tissue.xls'
	DBMS=XLS
	replace
	OUT=cc.import;
	GETNAMES=YES;
	run;

data cc.b1;
set cc.import;
sy1 = sy*1; 
ge1 = ge*1;
vend1 = vend*1;
item1 = item*1;
sy2 = put(sy1,z2.);
vend2 = put(vend1,z5.);
item2 = put(item1,z5.);
key = catt(sy2,ge1,vend2,item2);run;
data cc.brand;
set cc.b1;
keep key l3 l9 product_type l5;
run;
/*merging of panel data with product data*/
proc sql;
create table cc.panel_data as
select a.*,b.l3,b.l9,b.l5,b.Product_type from cc.panel2 a left join cc.brand b on a.upc = b.key order by panid;run;
proc freq data =cc.panel_data;
table l5;
run;
data cc.panel_data1;
set cc.panel_data;
if product_type='FACIAL TISSUE';
run;
data cc.b1;
set cc.panel_data1;
ct1 = scan(l9, -1, ' ');
ct2 = COMPRESS(ct1, "CT");
ct  = ct2*1;
drop ct1 ct2 l9 outlet colupc;
price = dollars/(units*ct);
run;
proc sql ;
create table cc.temp as select l3,sum(dollars) as total from cc.b1 group by l3 order by total desc;
run;
/*top 4 brands occupy 92.5% of the market*/
data cc.b2;
set cc.b1;
if l3='KIMBERLY CLARK CORP' then br=1;
if l3='IRVING TISSUE CONVERTERS' then br=2;
if l3='PROCTER & GAMBLE' then br=3;
if l3='PRIVATE LABEL' then br=4;
if br='.' then delete;
run;
proc freq data = cc.b2; 
table product_type;
run;
/*store data preprocessing*/
libname cc 'E:\ninja';
data cc.d1;
INFILE "E:\ninja\factiss_groc_1114_1165.txt" DLM=" " FIRSTOBS=2;
input IRI_KEY WEEK SY GE VEND  ITEM  UNITS DOLLARS  F$    D PR;
RUN;
data cc.d2;
set cc.d1;
if F = 'NONE' then Fe = 0;else Fe = 1;
if D = 0 then Di = 0;else Di = 1;
run;
data cc.d3;
set cc.d2;
sy1 = sy*1; 
ge1 = ge*1;
vend1 = vend*1;
item1 = item*1;
sy2 = put(sy1,z2.);
vend2 = put(vend1,z5.);
item2 = put(item1,z5.);
key = catt(sy2,ge1,vend2,item2);
run;
/*Sorting the data*/
proc sort data=cc.d3;
by descending key;
run;
proc sort data=cc.brand;
by descending key;
run;
/*Merging of store data with panel data*/
proc sql;
create table cc.d4 as
select a.*,b.l3,b.l9,b.product_type from cc.d3 a left join cc.brand b on a.key = b.key;run;
data cc.s1;
set cc.d4;
if product_type='FACIAL TISSUE';
run;
data cc.d5;
set cc.s1;
if l3='KIMBERLY CLARK CORP' then br=1;
if l3='IRVING TISSUE CONVERTERS' then br=2;
if l3='PROCTER & GAMBLE' then br=3;
if l3='PRIVATE LABEL' then br=4;
if br='.' then delete;
ct1 = scan(l9, -1, ' ');
ct2 = COMPRESS(ct1, "CT");
ct = ct2*1;
price = dollars/(units*ct);
drop ct1 ct2 l9 l3 F D; 
run;
proc reg data=cc.d5;
model units = price fe di pr;
run;
PROC TABULATE DATA=cc.d5 out=cc.d6;
VAR PRICE FE DI PR;
CLASS WEEK IRI_KEY BR;
TABLE WEEK*IRI_KEY*BR,(PRICE FE DI PR)*mean;
RUN;
libname cc 'E:\ninja';
data cc.d7;
set cc.d6;
if Fe_Mean = 0 then f = 0;else f = 1;
if Di_Mean = 0 then d = 0;else d = 1;
if Pr_Mean = 0 then P = 0;else p = 1;
drop Fe_Mean Di_Mean PR_Mean;
Rename price_Mean = price;
run;
libname cc 'E:\ninja';
proc sort data=cc.d7;
by IRI_Key week;
run;
proc transpose data=cc.d7 out=cc.w1 prefix=d;
by IRI_KEY week;
id br;
var d;
run;
proc transpose data=cc.d7 out=cc.w2 prefix=p;
    by IRI_KEY week;
    id br;
    var p;
run;
proc transpose data=cc.d7 out=cc.w3 prefix=f;
    by IRI_KEY week;
    id br;
    var f;
run;
libname cc 'E:\ninja';
proc transpose data=cc.d7 out=cc.w4 prefix=price;
    by IRI_KEY week;
    id br;
    var price;
run;
data cc.det;
merge cc.w1 cc.w2 cc.w3 cc.w4;
by IRI_KEY week;
run;
data cc.detail;
set cc.det;
keep IRI_KEY week p1-p4 d1-d4 f1-f4 price1-price4;
run;
data cc.detail_2;
set  cc.detail;
if f1='.' then f1=0;
if f2='.' then f2=0;
if f3='.' then f3=0;
if f4='.' then f4=0;
if p1='.' then p1=0;
if p2='.' then p2=0;
if p3='.' then p3=0;
if p4='.' then p4=0;
if d1='.' then d1=0;
if d2='.' then d2=0;
if d3='.' then d3=0;
if d4='.' then d4=0;
if price1='.' then delete;
if price2='.' then delete;
if price3='.' then delete;
if price4='.' then delete;
run;
/*merging panel and store level data*/
proc sql;
create table cc.mdc_data as
select a.*,b.* from cc.b2 a inner join cc.detail_2 b on a.Iri_key = b.IRI_Key and a.week = b.week;run;
PROC IMPORT  DATAFILE='E:\ninja\ads demo1.csv'
	DBMS=csv
	replace
	OUT=cc.demo;
	GETNAMES=YES;
RUN;
/*adding demographic variable*/
proc sql;
create table cc.z1 as
select a.*,b.* from cc.mdc_data a left join cc.demo b on a.panid = b.panelist_id order by panid;run;
data cc.tissue;
set cc.z1;
keep panid week br d1-d4 p1-p4 f1-f4 price1-price4 combined_pre_tax_Income_of_HH family_size HH_RACE type_of_residential_possession Age_group_applied_to_male_HH male_working_hour_code Age_group_applied_to_female_HH Edu_level_reached_by_female_HH occupation_code_of_female_HH female_working_hour_code Marital_Status Children_group_code number_of_Dogs number_of_Cats;
run;
/*mdc data preprocessing*/
data cc.newdata (keep=panid tid decision mode price display feature loyalty combined_pre_tax_Income_of_HH family_size Age_group_applied_to_male_HH Age_group_applied_to_female_HH Marital_Status Child_group_code);
set cc.tissue;
array pvec{4} p1 - p4; 
array dvec{4} d1 - d4;
array fvec{4} f1 - f4;
array pricevec{4} price1 - price4;
retain tid 0;
tid+1;
do i = 1 to 4;
	mode=i;
	price=pricevec{i};
	display=dvec{i};
	feature=fvec{i};
	discount=pvec{i};
	decision=(br=i);
	output;
end;
run;
data cc.newdata;
set cc.newdata;
br2=0;
br3=0;
br4=0;
if mode = 2 then br2 = 1;
if mode = 3 then br3 = 1;
if mode = 4 then br4 = 1;
inc2=combined_pre_tax_Income_of_HH*br2;
inc3=combined_pre_tax_Income_of_HH*br3;
inc4=combined_pre_tax_Income_of_HH*br4;
nmemb2=family_size*br2;
nmemb3=family_size*br3;
nmemb4=family_size*br4;
Age_m2=Age_group_applied_to_male_HH*br2;
Age_m3=Age_group_applied_to_male_HH*br3;
Age_m4=Age_group_applied_to_male_HH*br4;
Age_f2=Age_group_applied_to_female_HH*br2;
Age_f3=Age_group_applied_to_female_HH*br3;
Age_f4=Age_group_applied_to_female_HH*br4;
MaritalStatus2=Marital_Status*br2;
MaritalStatus3=Marital_Status*br3;
MaritalStatus4=Marital_Status*br4;
Child_age2=Child_group_code*br2;
Child_age3=Child_group_code*br3;
Child_age4=Child_group_code*br4;
run;
proc mdc data=cc.newdata;
model decision = br2 br3 br4 price display feature inc2-inc4 nmemb2-nmemb4 Age_m2-Age_m4 Age_f2-Age_f4/ type=clogit 
	nchoice=4;
	id tid;
	output out=probdata pred=p;
run;
