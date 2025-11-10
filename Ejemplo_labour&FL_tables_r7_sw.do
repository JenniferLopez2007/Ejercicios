/******************************
	ROUND 7 LABOUR MARKET AND FAMILY FORMATION
					FACTSHEET
		4. Figures and statistics		
		
Created on: 20.08.2024
Created by: Jennifer

Input: 	- labour&familyPE_factsheetR7.dta
Output: - lf_factsheetR7_tables_Peru.xlsx
		  (Table 1, Table 1 for annex, Main Table)				

******************************/

	clear all
	set more off
	version 18

	global drive  "C:\Users\\`=c(username)'\NdM Dropbox\Jennifer Lopez\YL Round 7 development\R7 Factsheets\factsheet_PE" 
				// change path!!
	global input  "$drive\data\input"
	global data   "$drive\data\output_labour and family lives"
	global out    "$drive\output\labour and family lives"
	global factor "$drive\data\input"
	
	local c "Peru"
	local co = "pe"

**#	================================================ * 
	* 	 				 TABLE 1	 				 *	
	*=============================================== * 
	
use "$data/labour&familyPE_factsheetR7.dta", clear

/* Satisfaction with work - to be use in the factsheets
tab wrkstsfct7r7 if yc==1
tab wrkstsfct7r7 if yc==0
*/
keep if yc==1
	
	* Setting up local for excel column letters
	local row=1
		forval i=1/70 {
			local col = `i'
			excelcol `col'
			local locletter`i' = "`r(column)'"
		}
	
	
putexcel set "$out/lf_factsheetR7_tables_`c'_sw.xlsx", sheet("table1") modify

****** Creating a skeleton of the table ******

**-- Outcomes
	
	local sector "agri7"
	tab agri7, gen(agri7_)
	
	local row=1
	local i = 2		
		
	local a : variable label q_employ7
	putexcel `locletter`i''`row'="`a'", bold hcenter border(all)	
	local i = `i' + 1
		
	levelsof `sector', local(levels)
	foreach d of local levels {		
		local val_lab : label `sector' `d' 
		putexcel `locletter`i''`row'="`val_lab'", bold hcenter border(all)
		local i = `i' + 1
	}

	
	local a : variable label mn_hrswek
	putexcel `locletter`i''`row'="`a'", bold hcenter border(all)	
	local i = `i' + 1
	
	local a : variable label wrtcnt 
	putexcel `locletter`i''`row'="`a'", bold hcenter border(all)	
	local i = `i' + 1
	
	putexcel `locletter`i''`row'="Total number of YL participants", bold hcenter border(all)	
	local i = `i' + 1
	
**-- Cross cuts

	local outcome_Peru "marcohabchild no_marrcohabchild marr_lglage child19" 
	

	local row = 2
	local i = 1
	
	foreach o of local outcome_`c'  {		
		local var_lab : variable label `o' 
		putexcel `locletter`i''`row'="`var_lab'", bold border(all)
		local ++row
	}
	
	putexcel `locletter`i''`row'="Total Average", bold border(all)
	
**-- Insert values
	// Note: Employment charactersitics are calculated as a % of those employed
	
	local row = 2
	local i = 2
	
	foreach var of local outcome_`c' {	
		
		*-- Mean by employed
			sum q_employ7 if `var'==1 [weight=factor]
			putexcel `locletter`i''`row'=`r(mean)'*100, nformat(0.0) border(all)
			local i = `i' + 1
			
		*-- Mean by `sector'
			levelsof `sector', local(levels) 
			foreach x of local levels {
				sum `sector'_`x' if `var'==1 & q_employ7==1 [weight=factor]
				putexcel `locletter`i''`row'=`r(mean)'*100, nformat(0.0) border(all)
				local i = `i' + 1
			}
			
		*-- Mean by hours worked and contract
			sum mn_hrswek if `var' == 1 & q_employ7==1 [weight=factor]
			putexcel `locletter`i''`row'=`r(mean)', nformat(0.0) border(all)
			local i = `i' + 1
			
			sum wrtcnt if `var' == 1 & q_employ7==1 [weight=factor]
			putexcel `locletter`i''`row'=`r(mean)'*100, nformat(0.0) border(all)
			local i = `i' + 1
			
		*-- N
			count if `var'==1
			putexcel `locletter`i''`row'=`r(N)', border(all)
			local i = `i' + 1
					
		local row = `row' + 1
		local i = 2	

	}	
	
	*-- TOTAL: Mean by employed
		sum q_employ7 [weight=factor]
		putexcel `locletter`i''`row'=`r(mean)'*100, nformat(0.0) border(all)
		local i = `i' + 1
			
	*-- TOTAL: Mean by `sector'
		levelsof `sector', local(levels) 
		foreach x of local levels {
			sum `sector'_`x' if q_employ7==1 [weight=factor]
			putexcel `locletter`i''`row'=`r(mean)'*100, nformat(0.0) border(all)
			local i = `i' + 1
		}
			
	*-- TOTAL: Mean by hours worked and contract
		sum mn_hrswek if q_employ7==1 [weight=factor]
		putexcel `locletter`i''`row'=`r(mean)', nformat(0.0) border(all)
		local i = `i' + 1
			
		sum wrtcnt if q_employ7==1 [weight=factor]
		putexcel `locletter`i''`row'=`r(mean)'*100, nformat(0.0) border(all)
		local i = `i' + 1	
		
	*-- TOTAL: N
		count
		putexcel `locletter`i''`row'=`r(N)', border(all)

**#	================================================ * 
	* 	 	TABLE 1	(BY GENDER) FOR ANNEX 			 *	
	*=============================================== * 
	
	use "$data/labour&familyPE_factsheetR7.dta", clear
	keep if yc==1


**-- Setting country=
	keep if country=="`c'"
	
	* Setting up local for excel column letters
	local row=1
		forval i=1/70 {
			local col = `i'
			excelcol `col'
			local locletter`i' = "`r(column)'"
		}
	
	
putexcel set "$out/lf_factsheetR7_tables_`c'_sw.xlsx", sheet("table1_for annex") modify

****** Creating a skeleton of the table ******

**-- Outcomes
	
	local sector "agri7" 
	
	local row=1
	local i = 2		
		
	local a : variable label q_employ7
	putexcel `locletter`i''`row'="`a'", bold hcenter border(all)	
	local i = `i' + 1
		
	levelsof `sector', local(levels)
	foreach d of local levels {		
		local val_lab : label `sector' `d' 
		putexcel `locletter`i''`row'="`val_lab'", bold hcenter border(all)
		local i = `i' + 1
	}

	
	local a : variable label mn_hrswek
	putexcel `locletter`i''`row'="`a'", bold hcenter border(all)	
	local i = `i' + 1
	
	local a : variable label wrtcnt 
	putexcel `locletter`i''`row'="`a'", bold hcenter border(all)	
	local i = `i' + 1
	
	putexcel `locletter`i''`row'="Total number of YL participants", bold hcenter border(all)	
	local i = `i' + 1
	
**-- Cross cuts

	local outcome_Peru "marcohabchild no_marrcohabchild marr_lglage child19" 
	

	local row = 2
	local i = 1
	
	foreach o of local outcome_`c'  {		
		local var_lab : variable label `o' 
		putexcel `locletter`i''`row'="`var_lab'", bold border(all)
		local row = `row' + 1
		putexcel `locletter`i''`row'="   Women", italic border(all)
		local row = `row' + 1
		putexcel `locletter`i''`row'="   Men", italic border(all)
		local row = `row' + 1
	}
	
	putexcel `locletter`i''`row'="Total Average", bold border(all)
	
**-- Insert values
	// Note: Employment charactersitics are calculated as a % of those employed
	
	tab `sector', gen(`sector'_)
	
	local row = 2
	local i = 2
	
	foreach var of local outcome_`c' {	
		
		*-- Mean by employed
			sum q_employ7 if `var'==1 [weight=factor]
			putexcel `locletter`i''`row'=`r(mean)'*100, nformat(0.0) border(all)
			local i = `i' + 1
			
		*-- Mean by `sector'
			levelsof `sector', local(levels) 
			foreach x of local levels {
				sum `sector'_`x' if `var'==1 & q_employ7==1 [weight=factor]
				putexcel `locletter`i''`row'=`r(mean)'*100, nformat(0.0) border(all)
				local i = `i' + 1
			}
			
		*-- Mean by hours worked and contract
			sum mn_hrswek if `var' == 1 & q_employ7==1 [weight=factor]
			putexcel `locletter`i''`row'=`r(mean)', nformat(0.0) border(all)
			local i = `i' + 1
			
			sum wrtcnt if `var' == 1 & q_employ7==1 [weight=factor]
			putexcel `locletter`i''`row'=`r(mean)'*100, nformat(0.0) border(all)
			local i = `i' + 1
			
		*-- N
			count if `var'==1
			putexcel `locletter`i''`row'=`r(N)', border(all)
			local i = `i' + 1
					
		local row = `row' + 1
		local i = 2	
		
		
		forval j =0/1 {
			preserve
			keep if chsex_r1==`j'
			
			*-- Mean by employed
			sum q_employ7 if `var'==1 [weight=factor]
			putexcel `locletter`i''`row'=`r(mean)'*100, nformat(0.0) border(all)
			local i = `i' + 1
			
		*-- Mean by `sector'
			levelsof `sector', local(levels) 
			foreach x of local levels {
				sum `sector'_`x' if `var'==1 & q_employ7==1 [weight=factor]
				putexcel `locletter`i''`row'=`r(mean)'*100, nformat(0.0) border(all)
				local i = `i' + 1
			}
			
		*-- Mean by hours worked and contract
			sum mn_hrswek if `var' == 1 & q_employ7==1 [weight=factor]
			putexcel `locletter`i''`row'=`r(mean)', nformat(0.0) border(all)
			local i = `i' + 1
			
			sum wrtcnt if `var' == 1 & q_employ7==1 [weight=factor]
			putexcel `locletter`i''`row'=`r(mean)'*100, nformat(0.0) border(all)
			local i = `i' + 1
			
		*-- N
			count if `var'==1
			putexcel `locletter`i''`row'=`r(N)', border(all)
			local i = `i' + 1
			
		local row = `row' + 1
		local i = 2
					
		restore
		}

	}
	
	*-- Mean by employed
		sum q_employ7 [weight=factor]
		putexcel `locletter`i''`row'=`r(mean)'*100, nformat(0.0) border(all)
		local i = `i' + 1
			
	*-- Mean by `sector'
		levelsof `sector', local(levels) 
		foreach x of local levels {
			sum `sector'_`x' if q_employ7==1 [weight=factor]
			putexcel `locletter`i''`row'=`r(mean)'*100, nformat(0.0) border(all)
			local i = `i' + 1
		}
			
	*-- Mean by hours worked and contract
		sum mn_hrswek if q_employ7==1 [weight=factor]
		putexcel `locletter`i''`row'=`r(mean)', nformat(0.0) border(all)
		local i = `i' + 1
			
		sum wrtcnt if q_employ7==1 [weight=factor]
		putexcel `locletter`i''`row'=`r(mean)'*100, nformat(0.0) border(all)
		local i = `i' + 1	
		
	*-- TOTAL: N
		count
		putexcel `locletter`i''`row'=`r(N)', border(all)
						

**#	================================================ * 
	* 	 				 MAIN TABLE 				 *	
	*=============================================== * 
	use "$data/labour&familyPE_factsheetR7.dta", clear
    replace child19=0 if child19==.
    replace marr_lglage=0 if marr_lglage==. /*I added this*/
	tab1 typesite_r1 typesite_con
    recode typesite_r1 (0=2)
    label define typesite_r1  1 "Urban" 2 "Rural", modify 
    label val typesite_r1  typesite_r1 

	* Setting locals
	local note = "Notes: Differences are significant at ***1%, **5% and *10%. Differences are percentage points. Information on maternal education and language was taken from 2006 (Round 2). Area of residence refers to the household location in 2002 (Round 1) as well as 2023 (Round 7). Household wealth terciles were calculated separately for each cohort using the household wealth index of 2002 (Round 1). "
	local mcc = "marcohabchild"

	
	* Setting up local for excel column letters
	local row=1
		forval i=1/70 {
			local col = `i'
			excelcol `col'
			local locletter`i' = "`r(column)'"
		}
		
		
putexcel set "$out/lf_factsheetR7_tables_`c'_sw.xlsx", sheet("main_table") modify

	
****** Creating a skeleton of the table ******
	
**Outcomes
	
	local row=1
	local i = 2	
	

	local x = `i' + 2
	local a : variable label work12 
	putexcel `locletter`i''`row':`locletter`x''`row'="`a'", ///
		bold merge hcenter border(all)
			
	local ++row
	putexcel `locletter`i''`row'="YC (2023)", hcenter border(all)
			
	local z=`i'+1
	putexcel `locletter`z''`row'="OC (2016)", hcenter border(all)		 	
	putexcel `locletter`x''`row'="OC (2023)", hcenter border(all)		 	
	local row=1
	local i = `i' + 3
	
	local x = `i' + 1
	local a : variable label workstat12_4 
	putexcel `locletter`i''`row':`locletter`x''`row'="`a'", ///
		bold merge hcenter border(all)
			
	local ++row
	putexcel `locletter`i''`row'="YC (2023)", hcenter border(all)
	
	local z=`i'+1
	putexcel `locletter`z''`row'="OC (2023)", hcenter border(all)
	putexcel `locletter`x''`row'="OC (2016)", hcenter border(all) /*I changed this*/	 	
	local row=1
	local i = `i' + 2
		
	foreach o of varlist q_employ7 wrtcnt {
		local x = `i' + 1
		local a : variable label `o' 
		putexcel `locletter`i''`row':`locletter`x''`row'="`a'", ///
			bold merge hcenter border(all)
			
		local ++row
		putexcel `locletter`i''`row'="YC (2023)", hcenter border(all)
		putexcel `locletter`x''`row'="OC (2023)", hcenter border(all)
			
		local row=1
		local i = `i' + 2
		}
			
	local x = `i' + 2
	local a : variable label `mcc'
	putexcel `locletter`i''`row':`locletter`x''`row'="`a'", ///
			bold merge hcenter border(all)
			
	local ++row
	putexcel `locletter`i''`row'="YC (2023)", hcenter border(all)		
	local z=`i'+1
	putexcel `locletter`z''`row'="OC (2016)", hcenter border(all)		 	
	putexcel `locletter`x''`row'="OC (2023)", hcenter border(all)
	local row=1
	local i = `i' + 3
	
	foreach o of varlist marr_lglage child19 {		
		
		local x = `i' + 1
		local a : variable label `o' 
		putexcel `locletter`i''`row':`locletter`x''`row'="`a'", ///
			bold merge hcenter border(all)
		
		local ++row
		putexcel `locletter`i''`row'="YC", hcenter border(all)
		putexcel `locletter`x''`row'="OC", hcenter border(all)
		
		local row=1
		local i = `i' + 2
		
	}
	

** Crosscut variable labels

	local crosscut_pe "chsex_r1 typesite_r1 typesite_con wi_terc_r1 mumlang_r2_pe_d  momedu_r2_pe_cat" 
	// Note: include typesite_con when typesite R7 is available !!
	 
	local row = 3
	local i = 1
	
	putexcel `locletter`i''`row'="Average of full sample", bold border(all)
	local row = `row' + 2
	
	foreach var of local crosscut_`co' { 
	
	local var_lab : variable label `var' 
	putexcel `locletter`i''`row'="`var_lab'", bold border(all)
	local ++row
		
	levelsof `var', local(levels)
	foreach d of local levels {		
		local val_lab : label `var' `d' 
		putexcel `locletter`i''`row'="`val_lab'", italic border(all)
		local ++row
	}
	
		putexcel `locletter`i''`row'="Difference*,**,*** (t-test)", italic border(all)
		local row = `row' + 2
		
	}
	
	putexcel `locletter`i''`row'="Total number of YL participants", bold border(all)	
	
	putexcel (A1:`locletter`x''`row'), border(all)	
	
	*Final note
	local ++row
	putexcel `locletter`i''`row':`locletter`x''`row'="`note'", merge
	
	
		
** Insert values
	
	foreach x in work12 workstat12_4 workstat12r5_4 q_employ7 wrtcnt wrtcntr5 work12r5  ///
			marr_lglage child19 `mcc' {
		separate `x', by(yc)
	}
	
	local outcomes "work121 work12r50 work120 workstat12_41 workstat12r5_40 q_employ71 q_employ70 wrtcnt1 wrtcnt0 `mcc'1 `mcc'r5 `mcc'0 marr_lglage1 marr_lglage0 child191 child190"
	
	local row = 3
	local i = 2
	
	foreach var of local outcomes {	
		
		*Overall Mean
		sum `var' [weight=factor]
		putexcel `locletter`i''`row'=`r(mean)'*100, nformat(0.0) border(all)  
		local row = `row' + 3
		
		foreach cross of local crosscut_`co' {
			
			*** N and Mean by cross cut ***
			levelsof `cross', local(levels) 
			foreach x of local levels {
				sum `var' if `cross' == `x' [weight=factor]
				putexcel `locletter`i''`row'=`r(mean)'*100, nformat(0.0) border(all)
				local ++row

			}
			
			local row = `row' + 3
			
		}
		
		*Overall N
		local --row
		sum `var' [weight=factor]
		putexcel `locletter`i''`row'=`r(N)', border(all)
		
		local row = 3
		local i = `i' + 1	

	}

** Insert p-values
	svyset [weight=factor]
	
	local row = 3
	local i = 2	

	foreach var of local outcomes {	
		
		foreach cross of local crosscut_`co' {

			levelsof `cross'
			local obs = `r(r)'
			local row = `row' + `obs' + 3
			

			if "`cross'" == "chsex_r1" | "`cross'" == "typesite_r1" | ///
				"`cross'" == "`typesite_rcon'" | "`cross'" == "mumlang_r2_pe_d" {
				local cross_2 = "`cross'"
			}
			
			if "`cross'" == "wi_terc_r1" | ///
			   "`cross'" == "momedu_r2_pe_cat" {
				local cross_2 = "`cross'_C"
			}
			
			
			**												
			 cap svy: mean `var', over(`cross_2')
			 cap svy: mean `var', over(`cross_2') coeflegend
			 cap lincom _b[c.`var'@1.`cross_2'] - _b[c.`var'@0bn.`cross_2']
			 cap local value = string(`r(estimate)'*100, "%04.2f") 
			 cap dis "`value'"
			 
			 cap if `r(p)'<=0.001 {
				cap  putexcel `locletter`i''`row'="`value' ***", hcenter border(all)
				 }
						  
			cap if `r(p)'>0.001 & `r(p)'<=0.05 {
				 cap putexcel `locletter`i''`row'="`value' **", hcenter border(all) 
			}
						  
			cap if `r(p)'>0.05 & `r(p)'<=0.01 {
				 cap putexcel `locletter`i''`row'="`value' *", hcenter border(all) 
			}
						  
			cap  if `r(p)'>0.10 {
				cap putexcel `locletter`i''`row'="`value'", hcenter border(all) 
			}
			
			
			if "`cross'" == "region_r1_et" {
				local row = 29
				putexcel `locletter`i''`row'="."
			}
			
			 if "`cross'" == "chldeth_r1_in" {
				local row = 29
				putexcel `locletter`i''`row'="."
			}
	
		}
		
		local row = 3
		local i = `i' + 1
	
		}

xxx
**#	================================================ * 
	* 	 			 MAIN TABLE ANNEX				 *	
	*=============================================== * 

	use "$data/labour&familyPE_factsheetR7.dta", clear
    replace child19=0 if child19==.
    replace marr_lglage=0 if marr_lglage==. /*I added this*/
	tab1 typesite_r1 typesite_con
    recode typesite_r1 (0=2)
    label define typesite_r1  1 "Urban" 2 "Rural", modify 
    label val typesite_r1  typesite_r1 

	* Setting locals
	local note = "Notes: Differences are significant at ***1%, **5% and *10%. Differences are percentage points. Information on maternal education and language was taken from 2006 (Round 2). Area of residence refers to the household location in 2002 (Round 1) as well as 2023 (Round 7). Household wealth terciles were calculated separately for each cohort using the household wealth index of 2002 (Round 1). "
	local mcc = "marcohabchild"

	
	* Setting up local for excel column letters
	local row=1
		forval i=1/70 {
			local col = `i'
			excelcol `col'
			local locletter`i' = "`r(column)'"
		}
		
		
putexcel set "$out/lf_factsheetR7_tables_`c'_sw.xlsx", sheet("main_table_for annex") modify

	
****** Creating a skeleton of the table ******
	
**Outcomes

	tab agri7, gen(agri7_)
	label var agri7_1 "Agriculture sector"
	label var agri7_2 "Non-griculture sector"
	
	*Gen gendered versions of hours worked in care and paid work + marr before 
	* legal age and child before 19
	clonevar hwork_gen=hwork
	clonevar care_work_gen=care_work
	clonevar child19_gen=child19
	clonevar marr_lglage_gen=marr_lglage
	foreach x in hwork_gen care_work_gen marr_lglage_gen child19_gen {
		separate `x', by(chsex_r1)
	}

	*Dividing continuous vars with 100 for table
	foreach v in hwork care_work hworkr5 care_workr5 hwork_gen care_work_gen ///
		age_parent agemarr7 marrcohab_ager5 birth_ager5 ///
		hwork_gen0 hwork_gen1 care_work_gen0 care_work_gen1 {
		replace `v'=`v'/100
	}
	
	local row=1
	local i = 2	
	

	local x = `i' + 2
	local a : variable label work12 
	putexcel `locletter`i''`row':`locletter`x''`row'="`a'", ///
		bold merge hcenter border(all)
			
	local ++row
	putexcel `locletter`i''`row'="YC (2023)", hcenter border(all)
			
	local z=`i'+1
	putexcel `locletter`z''`row'="OC (2016)", hcenter border(all)		 	
	putexcel `locletter`x''`row'="OC (2023)", hcenter border(all)		 	
	local row=1
	local i = `i' + 3
	
	local x = `i' + 1
	local a : variable label workstat12_4 
	putexcel `locletter`i''`row':`locletter`x''`row'="`a'", ///
		bold merge hcenter border(all)
			
	local ++row
	putexcel `locletter`i''`row'="YC (2023)", hcenter border(all)
			
	putexcel `locletter`x''`row'="OC (2016)", hcenter border(all) /* I changed this*/ 	
	local row=1
	local i = `i' + 2
		
	foreach o of varlist q_employ7 wrtcnt {
		local x = `i' + 1
		local a : variable label `o' 
		putexcel `locletter`i''`row':`locletter`x''`row'="`a'", ///
			bold merge hcenter border(all)
			
		local ++row
		putexcel `locletter`i''`row'="YC (2023)", hcenter border(all)
		putexcel `locletter`x''`row'="OC (2023)", hcenter border(all)
			
		local row=1
		local i = `i' + 2
		}
	
	local x = `i' + 2
	local a : variable label `mcc'
	putexcel `locletter`i''`row':`locletter`x''`row'="`a'", ///
			bold merge hcenter border(all)
			
	local ++row
	putexcel `locletter`i''`row'="YC (2023)", hcenter border(all)		
	local z=`i'+1
	putexcel `locletter`z''`row'="OC (2016)", hcenter border(all)		 	
	putexcel `locletter`x''`row'="OC (2023)", hcenter border(all)
	local row=1
	local i = `i' + 3
	
	foreach o of varlist marr_lglage child19 {		
		
		local x = `i' + 1
		local a : variable label `o' 
		putexcel `locletter`i''`row':`locletter`x''`row'="`a'", ///
			bold merge hcenter border(all)
		
		local ++row
		putexcel `locletter`i''`row'="YC", hcenter border(all)
		putexcel `locletter`x''`row'="OC", hcenter border(all)
		
		local row=1
		local i = `i' + 2
		
	}
	
	foreach o of varlist marr_lglage child19 {		
		
		local x = `i' + 1
		local a : variable label `o' 
		putexcel `locletter`i''`row':`locletter`x''`row'="`a'", ///
			bold merge hcenter border(all)
		
		local ++row
		putexcel `locletter`i''`row'="Women", hcenter border(all)
		putexcel `locletter`x''`row'="Men", hcenter border(all)
		
		local row=1
		local i = `i' + 2
		
	}
		 		
	foreach o of varlist agri7_2 agri7_1 {
		local x = `i' + 1
		local a : variable label `o' 
		putexcel `locletter`i''`row':`locletter`x''`row'="`a'", ///
			bold merge hcenter border(all)
			
		local ++row
		putexcel `locletter`i''`row'="YC (2023)", hcenter border(all)
		putexcel `locletter`x''`row'="OC (2023)", hcenter border(all)
			
		local row=1
		local i = `i' + 2
	}
	
	foreach o of varlist hwork care_work evrmcr7 agemarr7 parent age_parent {
		local x = `i' + 1
		local a : variable label `o' 
		putexcel `locletter`i''`row':`locletter`x''`row'="`a'", ///
			bold merge hcenter border(all)
			
		local ++row
		putexcel `locletter`i''`row'="YC (2023)", hcenter border(all)
		putexcel `locletter`x''`row'="OC (2016)", hcenter border(all)
			
		local row=1
		local i = `i' + 2
	}
	
	foreach o of varlist mn_excesshrs  {
	local x = `i' + 1
	local a : variable label  `o'
	putexcel `locletter`i''`row':`locletter`x''`row'="`a'", ///
			bold merge hcenter border(all)			
	local ++row
	putexcel `locletter`i''`row'="YC (2023)", hcenter border(all)			 	
	putexcel `locletter`x''`row'="OC (2023)", hcenter border(all)
	local row=1
	local i = `i' + 2
	}
	
	foreach o of varlist hwork care_work  {
	local x = `i' + 1
	local a : variable label  `o'
	putexcel `locletter`i''`row':`locletter`x''`row'="`a'", ///
			bold merge hcenter border(all)			
	local ++row
	putexcel `locletter`i''`row'="Women (2023)", hcenter border(all)			 	
	putexcel `locletter`x''`row'="Men (2023)", hcenter border(all)
	local row=1
	local i = `i' + 2
	}
	
** Crosscut variable labels
	
	local crosscut_pe "chsex_r1 typesite_r1 typesite_con wi_terc_r1  mumlang_r2_pe_d  momedu_r2_pe_cat" 
		// Note: include typesite_con when typesite R7 is available !!

	local row = 3
	local i = 1
	
	putexcel `locletter`i''`row'="Average of full sample", bold border(all)
	local row = `row' + 2
	
	foreach var of local crosscut_`co' { 
	
	local var_lab : variable label `var' 
	putexcel `locletter`i''`row'="`var_lab'", bold border(all)
	local ++row
		
	levelsof `var', local(levels)
	foreach d of local levels {		
		local val_lab : label `var' `d' 
		putexcel `locletter`i''`row'="`val_lab'", italic border(all)
		local ++row
	}
	
		putexcel `locletter`i''`row'="Difference*,**,*** (t-test)", italic border(all)
		local row = `row' + 2
		
	}
	
	putexcel `locletter`i''`row'="Total number of YL participants", bold border(all)	
	
	putexcel (A1:`locletter`x''`row'), border(all)	
	
	*Final note
	local ++row
	putexcel `locletter`i''`row':`locletter`x''`row'="`note'", merge
	
	
		
** Insert values

	* Seperating vars by cohort
	foreach x in work12 workstat12_4 workstat12r5_4 q_employ7 wrtcnt wrtcntr5 work12r5  ///
			marr_lglage child19 `mcc' hwork care_work hworkr5 care_workr5 ///
			mn_excesshrs  agri7_2 agri7_1 evrmcr7 marrcohabr5 parent birthr5 ///
			age_parent birth_ager5 agemarr7 marrcohab_ager5 {
		separate `x', by(yc)
	}	

	local outcomes "work121 work12r50 work120 workstat12_41 workstat12r5_40 q_employ71 q_employ70 wrtcnt1 wrtcnt0 `mcc'1 `mcc'r5 `mcc'0 marr_lglage1 marr_lglage0 child191 child190 marr_lglage_gen0 marr_lglage_gen1 child19_gen0 child19_gen1 agri7_21 agri7_20 agri7_11 agri7_10 hwork1 hworkr50 care_work1 care_workr50  evrmcr71 marrcohabr50 agemarr71 marrcohab_ager50 parent1 birthr50 age_parent1 birth_ager50 mn_excesshrs1 mn_excesshrs0 hwork_gen0 hwork_gen1 care_work_gen0 care_work_gen1"
	
	local row = 3
	local i = 2
	
	foreach var of local outcomes {	
		
		*Overall mean
		sum `var' [weight=factor]
		putexcel `locletter`i''`row'=`r(mean)'*100, nformat(0.0) border(all)  
		local row = `row' + 3
		
		foreach cross of local crosscut_`co' {
			
			*** N and Mean by cross cut ***
			levelsof `cross', local(levels) 
			foreach x of local levels {
				cap sum `var' if `cross' == `x' [weight=factor]
				cap putexcel `locletter`i''`row'=`r(mean)'*100, nformat(0.0) border(all)
				local ++row

			}
			
			local row = `row' + 3
			
		}
		
		*Overall N
		cap sum `var' [weight=factor]
		local --row
		cap putexcel `locletter`i''`row'=`r(N)', border(all) 
		
		local row = 3
		local i = `i' + 1	

	}

** Insert p-values
	svyset [weight=factor]
	
	local row = 3
	local i = 2	
	
	foreach var of local outcomes {	
		
		foreach cross of local crosscut_`co' {

			levelsof `cross'
			local obs = `r(r)'
			local row = `row' + `obs' + 3
			

			if "`cross'" == "chsex_r1" | "`cross'" == "typesite_r1" | ///
				"`cross'" == "`typesite_rcon'" | "`cross'" ==  ///
				"region_r1_in_bif" | "`cross'" == "mumlang_r2_pe_d" | ///
				"`cross'" == "agri7" {
				local cross_2 = "`cross'"
			}
			
			if "`cross'" == "wi_terc_r1" | "`cross'" == "region_r1_et" | ///
				"`cross'" == "caredu_r2_et_cat" | ///
				"`cross'" == "chldeth_r1_in" | "`cross'" == ///
				"momedu_r2_in_cat" | "`cross'" == "momedu_r2_pe_cat" {
				local cross_2 = "`cross'_C"
			}

		
		
			**								
             cap svy: mean `var', over(`cross_2')
			 cap svy: mean `var', over(`cross_2') coeflegend
			 cap lincom _b[c.`var'@1.`cross_2'] - _b[c.`var'@0bn.`cross_2']
			 cap local value = string(`r(estimate)', "%04.2f") 
			 cap dis "`value'"
			 
			cap if `r(p)'<=0.001 {
				cap  putexcel `locletter`i''`row'="`value' ***", hcenter border(all) 
				 }
						  
			cap if `r(p)'>0.001 & `r(p)'<=0.05 {
				 cap putexcel `locletter`i''`row'="`value' **", hcenter border(all) 
			}
						  
			cap if `r(p)'>0.05 & `r(p)'<=0.01 {
				 cap putexcel `locletter`i''`row'="`value' *", hcenter border(all) 
			}
						  
			cap  if `r(p)'>0.01 {
				cap putexcel `locletter`i''`row'="`value'", hcenter border(all) 
			}
			
			
			if "`cross'" == "region_r1_et" {
				local row = 29
				putexcel `locletter`i''`row'="."
			}
			
			 if "`cross'" == "chldeth_r1_in" {
				local row = 29
				putexcel `locletter`i''`row'="."
			}
	
		}
		
		local row = 3 
		local i = `i' + 1
	
		}
