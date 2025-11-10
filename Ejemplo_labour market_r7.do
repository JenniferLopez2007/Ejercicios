/******************************
	ROUND 7 LABOUR MARKET AND FAMILY FORMATION
					FACTSHEET
			1. Labour market vars
			
Created on: 17.06.2024
Created by: Tanima

Updated on: 20.08.2024
Updates by: Jennifer

Input: 	- YC and OC R7 Clean data_v1 for Peru

Output: - labourmarkets_r7.dta
		
		NOTE: Any comment with !! needs attention
		
******************************/

	***** Boiler plate ****** 
	clear all
	set more off
	version 18
	
	**** Globals 				
	global drive  "C:\Users\\`=c(username)'\NdM Dropbox\Jennifer Lopez\YL Round 7 development\R7 Factsheets\factsheet_PE" 
				// change path!!
				
	global input  "$drive\data\input"
	global data   "$drive\data\output_labour and family lives"
	global out    "$drive\output\labour and family lives"
	global factor "$drive\data\input"
	global lm     "D:\Trabajo\Niños del Milenio\Round 7\LabourMarket\Clean"
	
**#	================================================ * 
	* 		Importing and appending datasets		 *	
	*=============================================== *
	
	**--------- Expansion factor
	use "$factor\factor.dta", clear
	rename CHILDCODE childcode
	tempfile factor
	save `factor'
	
	**--------- Clen labour market data
	use "$lm\yc_lm_corrections.dta", clear
	keep childcode error_lastweek error_type_lastweek deswrk7fnl_final typwrk7fnl_final econsec7fnl_final employer7fnl_final error_last12 error_type_last12 deswrk12r7fnl_final typwrk12r7fnl_final econsec12r7fnl_final employer12r7fnl_final
	tempfile clean_lm_yc
	save `clean_lm_yc'
	
	use "$lm\oc_lm_corrections.dta", clear
	keep childcode error_lastweek error_type_lastweek deswrk7fnl_final typwrk7fnl_final econsec7fnl_final employer7fnl_final error_last12 error_type_last12 deswrk12r7fnl_final typwrk12r7fnl_final econsec12r7fnl_final employer12r7fnl_final

	append using `clean_lm_yc'
	tempfile clean_lm
	save `clean_lm'

	**--------- Clean dataset
	use "$input\R7\PE_R7_YCCH_V2.dta", clear
	append using "$input\R7\PE_R7_OCCH_V2.dta", force
	
	merge 1:1 childcode using `factor'
	keep if _merge==3
	drop _merge

	merge 1:1 childcode using `clean_lm'
	keep if _merge==3
	drop _merge
	
	gen country="Peru"
	
	order curredur7, after(prbspsr7)
	drop healthr7-prbspsr7
	drop ownhser7-section6_com

**#	================================================ * 
	* 			Labour Market Participation			 *	
	*=============================================== *

	/****** WORKED IN THE REF PERIOD ******/ 
	
	**--------- Work12 : Work in the last 12 months (same as employment in 
	*														last 12 months)
	gen work12=.
	replace work12=1 if lst12nhsr7 == 1 | lst12bsnr7==1 | lst12frmr7==1 
	replace work12=0 if lst12nhsr7 == 0 & lst12bsnr7==0 & lst12frmr7==0 
	label var work12 "Worked for at least an hour in the last 12 months"
	label val work12 yesno
	tab work12 yc, m co
	

	**--------- Work7 : Work in the last week 
	cap drop work_week
	replace lstwkfrmr7=0 if lst12frmr7==0
	replace lstwkbsnr7=0 if lst12bsnr7==0
	replace lstwknhsr7=0 if lst12nhsr7==0
	gen work7=.
	replace work7=1 if lstwkfrmr7==1 | lstwknhsr7==1 | lstwkbsnr7==1
	replace work7=0 if (lstwkfrmr7==0 & lstwknhsr7==0 & lstwkbsnr7==0)
	label var work7 "Worked for at least an hour in the last 7 days"
	label val work7 yesno
	tab work7 yc, m co

	

	/****** EMPLOYED IN THE REF PERIOD ******/ 
	
	**--------- Employ7 : Employed in the last week according to ILO definition 
	*													(as close as possible)
	gen employ7=.
	replace employ7=1 if work7==1
	replace employ7=1 if work7==0 & curjbr7==1			
				// Did not work in past 7 days but has a job
	replace employ7=1 if work7==0 & lkwrklstwkr7==0 & ynlkwrkr7==7 	
				// Did not work in past 7 days & does not have a job & is not 
				// looking for a job bcos waiting for busy season
	replace employ7=0 if work7==0 & lkwrklstwkr7==0 & ynlkwrkr7!=7 	
				// Did not work in the past 7 days & and not looking for work
	replace employ7=0 if work7==0 & lkwrklstwkr7==1					
				// Did not work in the past 7 days & looking for work
	label values employ7 yesno
	label var employ7 "Currently employed (ref period: 7 days)"
	tab employ7 yc, m co
	
	
	**--------- Q_employ7 : Currently employed according to questionnaire/ 
	*													for factsheets
				// this does not include those not looking for work because they 
				// are waiting for busy season
	gen q_employ7=.
	replace q_employ7=1 if work7==1
	replace q_employ7=1 if work7==0 & curjbr7==1
	replace q_employ7=0 if work7==0 & (curjbr7==0 | curjbr7==.)
	label values q_employ7 yesno
	label var q_employ7 "Employed in the last week"
	tab q_employ7 yc, m co
	
	
	** Worked in the past 12 months is used as "employment" in the past 12 months
	tab work12 yc, m co
	
	
	
	/****** ACTIVE/INACTIVE IN THE REF PERIOD ******/ 
	
	**--------- Active7 : Active in the past week by ILO definition 
	*										(as close as possible)
	gen active7=1 if employ7==1		
	replace active7=1 if employ7==0 & lkwrklstwkr7==1	
				// Not employed but searching for jobs 

	replace active7=1 if employ7==0 & lkwrklstwkr7==0 & 		///
			(ynlkwrkr7==6 | ynlkwrkr7==7)
				// Not employed and not searching because waiting for employer 
				// recall or waiting for busy season - available for work 
				// so they are considered active

	replace active7=0 	if employ7==0 & lkwrklstwkr7==0 & 					///
			(ynlkwrkr7==1 | ynlkwrkr7==2 | ynlkwrkr7==3 | ynlkwrkr7==4 | 	///
			ynlkwrkr7==5 | ynlkwrkr7==8 | ynlkwrkr7==9)
				// Unemployed but not searching because student/housewife/disabled etc
	label values active7 yesno
	label var active7 "Active labour force (ref period: 7 days)"
	tab active7 yc, m co
	
	**--------- Inactive7 : Inactive in the past week by ILO definition 
	*											(as close as possible) 
	clonevar inactive7 = active7
	recode inactive7 (0=1) (1=0)
	label var inactive7 "Inactive labour force (ref period: 7 days)"
	
	**--------- q_active7 : Active in the past week by questionnaire definition
	gen q_active7=1 		if q_employ7==1
	replace q_active7=1 	if q_employ7==0 & lkwrklstwkr7==1
	replace q_active7=0		if q_employ7==0 & lkwrklstwkr7==0
	label values q_active7 yesno
	label var q_active7 "Active labour force (factsheet def)"
	tab q_active7 yc, m co
	
	**--------- q_inactive7 : Inactive in the past week by questionnaire 
	*														definition
	clonevar q_inactive7 = q_active7
	recode q_inactive7 (0=1) (1=0)
	label var q_inactive7 "Inactive labour force (factsheet def)"
	
	**--------- Active12 : Active in the 12 months
	gen active12=1 if work12==1
	replace active12=1 if work12==0 & lkwrklstwkr7==1  			
				// looked for work in last 7 days 
	replace active12=1 if work12==0 & lkwrklstwkr7==0 & lkwrklst12r7==1 
				// didn't look in last 7, but looked in last 12
	replace active12=0 if work12==0 & lkwrklstwkr7==0 & lkwrklst12r7==0 
				// didn't look for work in the last 7 days or past year
	label var active12 "Active persons in the last 12 months" 
	label values active12 yesno
	tab active12 yc, m co
	
	**--------- Inactive12 : Inactive in the 12 months
	clonevar inactive12 = active12
	recode inactive12 (0=1) (1=0)
	label var inactive12 "Inactive persons in the last 12 months"

	
	
	/****** UNEMPLOYED IN THE REF PERIOD ******/ 
	
	**--------- Unempl7 : Did not work but looking for work in the last 7 days 
	gen unemp7=. 
	replace unemp7=1 if employ7==0 & active7==1
	replace unemp7=0 if employ7==1 
	replace unemp7=0 if employ7==0 & active7==0
	label var unemp7 "Currently unemployed (ref period: 7 days)"
	label val unemp7 yesno
	tab unemp7 yc, m co
	
	**--------- Q_unemp7 : Did not work but looking for work in the last 7 days 
	*				 according to questionnaire definition
		
	gen q_unemp7=. 
	replace q_unemp7=1 if q_employ7==0 & q_active7==1
	replace q_unemp7=0 if q_employ7==1
	replace q_unemp7=0 if q_employ7==0 & q_active7==0
	label val q_unemp7 yesno
	label var q_unemp7 "Currently unemployed (factsheet def)"
	tab q_unemp7 yc, m co
	
	**--------- Unemp12 : Did not work but looking for work in the last 12 months 
	gen unemp12=.
	replace unemp12=1 if work12==0 & active12==1
	replace unemp12=0 if work12==1 | (work12==0 & active12==0)
	label var unemp12 "Unemployed in the last 12 months"
	label val unemp12 yesno
	tab unemp12 yc, m co
	
	
	
	/****** EMPLOYMENT STATUS ******/ 	
	
	**--------- Empstat7: Employment status based on last week based on ILO  
	*										definition (as close as possible)
	gen empstat7=1 if employ7==1
	replace empstat7=2 if unemp7==1
	replace empstat7=3 if active7==0
	label define stat_L 1"Employed" 2"Unemployed" 3"Inactive"
	label values empstat7 stat_L
	label var empstat7 "Current employment status (ref period: 7 days)"
	tab empstat7 yc, m co
			
	**--------- Empstat7: Employment status based on last week by q definition
		
	gen q_empstat7=1 if q_employ7==1
	replace q_empstat7=2 if q_unemp7==1
	replace q_empstat7=3 if q_active7==0
	label values q_empstat7 stat_L
	label var q_empstat7 "Current employment status (factsheet def)"
	tab q_empstat7 yc, m co
		
	**--------- Empstat12 : Employment status based on last 12 months
		* Not going to label work as employed, because of definition issues
	gen empstat12=.
	replace empstat12=1 if work12==1 
	replace empstat12=2 if unemp12==1
	replace empstat12=3 if active12==0
	label define empstat_L 1"Worked" 2"Unemployed" 3"Inactive"
	label values empstat12 empstat_L 
	label var empstat12 "Work status in the last 12 months" 
	tab empstat12 yc, m co
	
	
	
**#	================================================ * 
	* 			Reason for not working				 *	
	*=============================================== *

	**--------- ynlkwrk12r7 : reason for not working in the past week
	codebook ynlkwrkr7
	label list ynlkwrkr7
	
	tab ynlkwrkothr7
	*br childid ynlkwrkothr7 if ynlkwrkothr7!=""
	
	replace ynlkwrkr7=3 if childid=="PE011029"
	replace ynlkwrkr7=1 if childid=="PE018007"
	replace ynlkwrkr7=4 if childid=="PE021010"
	replace ynlkwrkr7=3 if childid=="PE021083"
	replace ynlkwrkr7=1 if childid=="PE028015"
	replace ynlkwrkr7=1 if childid=="PE041028"
	replace ynlkwrkr7=1 if childid=="PE051029"
	replace ynlkwrkr7=7 if childid=="PE058020"
	replace ynlkwrkr7=1 if childid=="PE081099"
	replace ynlkwrkr7=1 if childid=="PE091029"
	replace ynlkwrkr7=3 if childid=="PE091030"
	replace ynlkwrkr7=3 if childid=="PE091058"
	replace ynlkwrkr7=3 if childid=="PE101015"
	replace ynlkwrkr7=6 if childid=="PE128041"
	replace ynlkwrkr7=3 if childid=="PE131063"
	replace ynlkwrkr7=3 if childid=="PE161078"
	replace ynlkwrkr7=1 if childid=="PE191042"
	replace ynlkwrkr7=3 if childid=="PE191088"	
	replace ynlkwrkr7=4 if childid=="PE191098"
	replace ynlkwrkr7=5 if childid=="PE208021"
	
	tab ynlkwrkoth12r7
	*br childid ynlkwrkoth12r7 if ynlkwrkoth12r7!=""

	replace ynlkwrk12r7=2 if childid=="PE011013"
	replace ynlkwrk12r7=2 if childid=="PE011029"
	replace ynlkwrk12r7=1 if childid=="PE011077"
	replace ynlkwrk12r7=4 if childid=="PE018026"
	replace ynlkwrk12r7=4 if childid=="PE021010"
	replace ynlkwrk12r7=7 if childid=="PE021065"
	replace ynlkwrk12r7=3 if childid=="PE021083"
	replace ynlkwrk12r7=1 if childid=="PE028015"
	replace ynlkwrk12r7=1 if childid=="PE041020"
	replace ynlkwrk12r7=1 if childid=="PE041028"
	replace ynlkwrk12r7=5 if childid=="PE041070"
	replace ynlkwrk12r7=1 if childid=="PE048009"
	replace ynlkwrk12r7=1 if childid=="PE051029"
	replace ynlkwrk12r7=6 if childid=="PE058021"
	replace ynlkwrk12r7=2 if childid=="PE061018"
	replace ynlkwrk12r7=6 if childid=="PE081062"
	replace ynlkwrk12r7=6 if childid=="PE088017"
	replace ynlkwrk12r7=3 if childid=="PE091030"
	replace ynlkwrk12r7=5 if childid=="PE091054"
	replace ynlkwrk12r7=3 if childid=="PE091058"
	replace ynlkwrk12r7=5 if childid=="PE091064"
	replace ynlkwrk12r7=3 if childid=="PE091072"
	replace ynlkwrk12r7=4 if childid=="PE091086"
	replace ynlkwrk12r7=6 if childid=="PE091088"
	replace ynlkwrk12r7=6 if childid=="PE098001"
	replace ynlkwrk12r7=3 if childid=="PE101015"
	replace ynlkwrk12r7=2 if childid=="PE121094"
	replace ynlkwrk12r7=3 if childid=="PE131063"
	replace ynlkwrk12r7=4 if childid=="PE131083"
	replace ynlkwrk12r7=1 if childid=="PE151007"
	replace ynlkwrk12r7=7 if childid=="PE158026"
	replace ynlkwrk12r7=3 if childid=="PE161078"
	replace ynlkwrk12r7=1 if childid=="PE181065"
	replace ynlkwrk12r7=2 if childid=="PE181074"
	replace ynlkwrk12r7=1 if childid=="PE191003"
	replace ynlkwrk12r7=1 if childid=="PE191042"
	replace ynlkwrk12r7=3 if childid=="PE191088"
	replace ynlkwrk12r7=4 if childid=="PE198015"
	replace ynlkwrk12r7=6 if childid=="PE198031"
	replace ynlkwrk12r7=1 if childid=="PE208023"

	tab ynlkwrkr7 country
	
	codebook childcode
	*br childid country ynlkwrkothr7 if ynlkwrkr7==8
		// Note: Some of the "Others" could be recoded. We could do this
		// cleaning here if this hasn't been done in data cleaning already
	clonevar reason_ntwork7=ynlkwrkr7
	label var reason_ntwork7 "Reason for not working in the last week"
	

	**--------- ynlkwrk12r7 : reason for not working in the past year
	tab ynlkwrk12r7 country
	*br childid country ynlkwrkoth12r7 if ynlkwrk12r7==8
		// Note: Some of the "Others" could be recoded. We could do this 
		// cleaning here if this hasn't been done in data cleaning already 
	clonevar reason_ntwork12=ynlkwrk12r7
	label var reason_ntwork12 "Reason for not working in the last 12 months"
	
**#	================================================ * 
	* 				Work/studying Status			 *	
	*=============================================== *	
	
	// Note: enrolment calculated based on 6.2 Current education section (Q4). 
	// Could have calculated it based on education status in this year in the 
	// 6.1 Education history section (Q2) but section 6.1 is not asked to
	// ET phone survey participants
	
	**--------- studying : enrolled in current academic year
	gen enrol=1 if inlist(curredur7,1,2,4)	
	replace enrol=0 if inlist(curredur7,0,3)
	label var enrol "Currently enrolled in school"
			// 1 missing
			
	**--------- workstat12 : work/studying activity status
	gen workstat12=1 if enrol==1 & work12==0
	replace workstat12=2 if enrol==0 & work12==1
	replace workstat12=3 if enrol==1 & work12==1
	replace workstat12=4 if enrol==0 & work12==0
	
	label define workstat12 1"Studying only" 2"Working only" ///
		  3"Studying and working" 4"Neither working nor studying (NEET)" 
	label val workstat12 workstat12
	label var workstat12 "Working status: working, studying, either or neither"
	bys yc: ta workstat12 country, m co
	
	tab workstat12, gen(workstat12_)
	label var workstat12_1 "Studying only"
	label var workstat12_2 "Working only"
	label var workstat12_3 "Studying and working"
	label var workstat12_4 "Neither working nor studying"


	
**#	================================================ * 
	* 				   Main Activity				 *	
	*=============================================== *	
	
	*CHECKS
	count if mainactr7==. & typwrk7r7==. & q_employ7==1
	count if mainactr7==. & econsec7r7==. & q_employ7==1
			// only 3 so skip pattern seems to be fine
	
	/****** TYPE OF WORK ACTIVITY/ OCCUPATION ******/ 
	
	**--------- typwrk7r7_"country" : Type of work last week
		// Note: Type of work activity options differ by country so different
		// vars for each country

	tab q_employ7
	tab1 typwrk7r7 typwrk7fnl_final
	drop typwrk7r7
	rename typwrk7fnl_final typwrk7r7_pe
	
	label var typwrk7r7_pe "Type of work in the past week"
	tab typwrk7r7_pe if work7==1 & country=="Peru", m 
	
	
	**--------- Agri7 : If agricultural work activity or not (Binary)
		//Note: Creating this var before cleaning others because there are 2  
		//other work activity options- 1 for agro and 1 for non-agri
		
	codebook typwrk7r7_pe
	label list work_type
	
	gen agri7=1 if country=="Peru" & ///
			inlist(typwrk7r7_pe,21,22,2,3,4,5,6,7,8)
	replace agri7=2 if country=="Peru" & ///
			inlist(typwrk7r7_pe,9,10,11,12,13,14,15,23,16,20) // Change made: Added 20
	
	label var agri7 "Economic sector"
	*label define agri7 1 "Non-agricultural sector" 2 "Agricultural sector" // Error found
	label define agri7 1 "Agricultural sector" 2 "Non-agricultural sector" // Correct
	label val agri7 agri7
	tab agri7 yc if work7==1, m
	
	**--------- typwrk12r7_"country" : Type of work last year

	tab work12
	tab1 typwrk12r7 typwrk12r7fnl_final
	drop typwrk12r7
	rename typwrk12r7fnl_final typwrk12r7_pe
	
	label var typwrk12r7_pe "Type of work in the past year"
	tab typwrk12r7_pe if work12==1, m
	

	**--------- Agri12 : If agricultural work activity or not in last year
		//Note: Creating this var before cleaning others because there are 2  
		//'other' work activity options- 1 for agri and 1 for non-agri 
	gen agri12=1 if country=="Peru" & ///
			inlist(typwrk12r7_pe,21,22,2,3,4,5,6,7,8)
	replace agri12=2 if country=="Peru" & ///
			inlist(typwrk12r7_pe,9,10,11,12,13,14,15,23,16,20) // Change made: Added 20
	
	label var agri12 "Economic sector"
	*label define agri12 1 "Non-agricultural sector" 2 "Agricultural sector" // Error found
	label define agri12 1 "Non-agricultural sector" 2 "Agricultural sector" // Correct
	label val agri12 agri12
	tab agri12 yc if work12==1, m
	
	
	/****** ECONOMIC SECTOR ******/ 
	
	tab q_employ7
	tab1 econsec7r7 econsec7fnl_final
	*drop econsec7r7
	rename econsec7fnl_final econsec7r7_clean
	
	**--------- econsec7r7_clean: Employment sector based on activity last week
	tab econsec7r7_clean country if q_employ7==1, m
	tab mainactr7 country if q_employ7==1 & econsec7r7_clean==., m
				// 1 in Peru
	recode econsec7r7_clean (77 79 88 = .)
	label val econsec7r7_clean econsec7r7
	label var econsec7r7_clean "Economic sector of main work activity last week"
	

	**--------- broadsector7r7: Employment sector based on activity last year
	//Note: For economic sector, we use 21 "Sections" from ISIC- Rev. 4
	// The above broad sector categories is based on official guidelines for 
	// concordance by the ILO
	
	gen broadsector7r7=1 if inlist(econsec7r7_clean,1)
	replace broadsector7r7=2 if inlist(econsec7r7_clean,2,3,4,5,6)
	replace broadsector7r7=3 if inlist(econsec7r7_clean,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21)
	label define broadsector 1"Agriculture" 2"Industry" 3"Services"
	label val broadsector7r7 broadsector
	label var broadsector7r7 ///
		"Economic sector based on main activity in the past week"

	
	**--------- econsec12r7: Employment sector based on activity last year
	
	tab work12
	tab1 econsec12r7 econsec12r7fnl_final
	drop econsec12r7
	rename econsec12r7fnl_final econsec12r7

	tab econsec12r7 country if work12==1, m
	recode econsec12r7 (77 79 88 = .)
	label var econsec12r7 "Economic sector of main work activity last year"
	
	
	**--------- broadsector12r7: Employment sector based on activity last year
	gen broadsector12r7=1 if inlist(econsec12r7,1)
	replace broadsector12r7=2 if inlist(econsec12r7,2,3,4,5,6)
	replace broadsector12r7=3 if inlist(econsec12r7,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21)
	label val broadsector12r7 broadsector
	label var broadsector12r7 ///
		"Economic sector based on main activity in the past year"
	

**#	================================================ * 
	* 				   Job Quality					 *	
	*=============================================== *		
	

		
	/****** HAVE WORK CONTRACT ******/
	gen wrtcnt=cntrctwk7r7 if cntrctwk7r7!=77
	label var wrtcnt "Employed in the last week with a contract" 
	label val wrtcnt yesno
	
	
	/****** EXCESSIVE WORK TIME ******/
		// For those who have worked in the past 7 days 
		// (excl. housewives and students). 
		// Can be calculated using i) hrs worked in main activity from Sec 9.2
		// labour market (MainActivity7) and from ii) hrs worked in work in
		// a given day from Sec 8 Time Use.
	
	table country yc, statistic (mean workhrr7 wrkhrs7r7)
		// hours worked per day is shorter than hrs worked in main activity !!
	bys yc: ttest wrkhrs7r7=workhrr7
					
	
	** i)
		// note that days worked per month was asked in R5 and 
		// days worked per week in R7.  So R7 indicator for hours worked per 
		// week is probably better suited to measure excessive work hours
		
	gen mn_hrswek=wrkdys7r7*wrkhrs7r7
	label var mn_hrswek "Hours worked in main activity per week"
	tab country yc if mn_hrswek>48 & mn_hrswek!=.
	bys yc: summ mn_hrswek
	
	** ii)
		// this was not calculated in past round and not appropriate to look
		// at in terms of job quality of main activity but does say 
		// something about decent work - esp.worker well-being & renumeration
		
	gen hrs_wrk=workhrr7*wrkdys7r7
	label var hrs_wrk "Hours worked per week"
	tab country yc if hrs_wrk>48 & hrs_wrk!=.
	bys yc: summ hrs_wrk

	g mn_excesshrs=1 		if (mn_hrswek>48 & mn_hrswek!=.)
	replace mn_excesshrs=0 	if mn_hrswek<=48
	label var mn_excesshrs "Works >48 hours/week in main activity only"
	tab mn_excesshrs yc, co

**#	================================================ * 
	* 				Saving dataset					 *	
	*=============================================== *	
	keep childid childcode country work7 q_employ7 employ7 unemp7 active7  inactive7  q_active7 q_inactive7 q_unemp7 work12 unemp12 inactive12 active12 empstat7 empstat12 workstat12 workstat12_1 workstat12_2 workstat12_3 workstat12_4 hrs_wrk mn_hrswek yc wrtcnt agri7 typwrk7r7_pe agri12 typwrk12r7_pe econsec12r7 econsec7r7_clean broadsector12r7 broadsector7r7 reason_ntwork7 reason_ntwork12 wrkstsfct7r7 typesite mn_excesshrs
	
	label data "variables for labour markets R7 PE"
	save "$data\labourmarketsPE_r7.dta", replace
