
/******************************

	EJERCICIO 1
	
	Input:  - ENAHO MÓDULOS EDUCACIÓN, SUMARIA, 
	Output: - Tabla con el número y porcentaje de personas que están matriculadas ///
	          en una universidad pública y privada, por región
	
******************************/

clear all
set more off
global users "D"

	global input "${users}:\Ejercicio\Input"
	global output "${users}:\Ejercicio\Output"
	
	global sa "$input\"
    global su "$input\966-Modulo34"
	global ed "$input\966-Modulo03"
	
**#	================================================ * 
	*   		        Ejercicio 1   		         *	
	*=============================================== *

**-- Se importan y unen las bases de datos de educación y sumaria
	use "$ed/enaho01a-2024-300.dta", clear
	merge m:1 conglome vivienda hogar using "$su/sumaria-2024.dta", nogen
	
	gen facpob=mieperho*factor07
	svyset [pweight=facpob], psu(conglome) strata(estrato)

**-- Se generan las variables de área de residencia, region y departamento	
	gen          area=estrato
    recode       area (1/5=1) (6/8=0)
    lab def      area 1 "Urbana" 0 "Rural", modify
    lab val      area area
    lab var      area "Area de residencia"

	codebook dominio
	recode       dominio (1 2 3 8=1) (4 5 6=2) (7=3), gen(region)
    lab def      region 1 "Costa" 2 "Sierra" 3 "Selva", modify
	lab val      region region 
	tab region
	
	codebook ubigeo
	gen dpto=substr(ubigeo, 1, 2)
	destring dpto, replace
	label var dpto "Departamento"
    label def dpto 1 "Amazonas" 2 "Ancash" 3 "Apurimac" 4 "Arequipa" ///
	5 "Ayacucho" 6 "Cajamarca"  7 "Callao" 8 "Cusco" 9 "Huancavelica" ///
	10 "Huanuco" 11 "Ica" 12 "Junin" 13 "La_Libertad" 14 "Lambayeque" ///
	15 "Lima" 16 "Loreto" 17 "Madre_de_Dios" 18 "Moquegua" 19 "Pasco" ///
	20 "Piura" 21 "Puno" 22 "San_Martin" 23 "Tacna" 24 "Tumbes" 25 "Ucayali", modify
    label val dpto dpto

**-- Se genera la variable principal de matrícula universitaria por tipo de institución
	// Nota: Se considera al total de la población y a la población actualmente matriculada
	
	codebook p306 p307d p308a p308d
	
	* Población total
	gen          matri_univ=1 if p306==1 & p308a==5 & p308d==1
    replace      matri_univ=2 if p306==1 & p308a==5 & p308d==2
	replace      matri_univ=0 if matri_univ==. & p306!=.
    label var    matri_univ "Matrícula universitaria"    
	label def    matri_univ 0"No matriculado en univ." 1 "Matriculado - Univ. - Pub." 2 "Matriculado - Univ. - Priv."
    label val    matri_univ matri_univ

    * Población matriculada en educación
    gen          matri_univ_b=0 if p306==1
	replace      matri_univ_b=1 if p306==1 & p308a==5 & p308d==1
    replace      matri_univ_b=2 if p306==1 & p308a==5 & p308d==2
    label var    matri_univ_b "Matrícula universitaria"   
	label val    matri_univ_b matri_univ

	* Población de 17 a 24 años
    gen          matri_univ_c=0 if (p208a>=17 & p208a<=24)
	replace      matri_univ_c=1 if (p208a>=17 & p208a<=24) & p306==1 & p308a==5 & p308d==1
    replace      matri_univ_c=2 if (p208a>=17 & p208a<=24) & p306==1 & p308a==5 & p308d==2
    label var    matri_univ_c "Matrícula universitaria"   
	label val    matri_univ_c matri_univ


**-- Se realizan los cálculos para la población en situación de pobreza (pobres no extremos y pobres extremos)
	// Nota: Se realiza los cálculos para área, región y departamento solo con fines ilustrativos
    codebook pobreza
	tab matri_univ [aw=factora07]
    tab matri_univ if (pobreza==1 | pobreza==2) [aw=factora07]
	
    foreach var of varlist area region dpto {
	svy: tab `var' matri_univ, format(%12.1fc) percent row obs
	}
	
	* Población total en situación de pobreza
    foreach var of varlist area region dpto {
	svy: tab `var' matri_univ if (pobreza==1 | pobreza==2), format(%12.1fc) percent row obs
	}

/*
--------------------------------------------------
RECODE of |
dominio   |
(dominio  |
geografic |        Matrícula universitaria        
o)        | No matri  Matricul  Matricul     Total
----------+---------------------------------------
    Costa |     98.2       0.6       1.3     100.0
          |  9,031.0      67.0      84.0   9,182.0
          | 
   Sierra |     98.8       1.0       0.3     100.0
          | 10,650.0      74.0      22.0  10,746.0
          | 
    Selva |     99.7       0.2       0.1     100.0
          |  6,683.0      15.0       5.0   6,703.0
          | 
    Total |     98.6       0.6       0.8     100.0
          | 26,364.0     156.0     111.0  26,631.0
--------------------------------------------------

*/
	xxx
	* Población matriculada en situación de pobreza
	foreach var of varlist area region dpto {
	svy: tab `var' matri_univ_b if (pobreza==1 | pobreza==2), format(%12.1fc) percent row obs
	}

/*
--------------------------------------------------
RECODE of |
dominio   |
(dominio  |
geografic |        Matrícula universitaria        
o)        | No matri  Matricul  Matricul     Total
----------+---------------------------------------
    Costa |     94.6       1.7       3.7     100.0
          |  2,900.0      67.0      84.0   3,051.0
          | 
   Sierra |     96.5       2.7       0.7     100.0
          |  3,169.0      74.0      22.0   3,265.0
          | 
    Selva |     99.2       0.5       0.3     100.0
          |  2,484.0      15.0       5.0   2,504.0
          | 
    Total |     96.0       1.8       2.2     100.0
          |  8,553.0     156.0     111.0   8,820.0
--------------------------------------------------
*/

	* Población de 17 a 24 años en situación de pobreza
	foreach var of varlist area region dpto {
	svy: tab `var' matri_univ_c if (pobreza==1 | pobreza==2), format(%12.1fc) percent row obs
	}	

/*
--------------------------------------------------
RECODE of |
dominio   |
(dominio  |
geografic |        Matrícula universitaria        
o)        | No matri  Matricul  Matricul     Total
----------+---------------------------------------
    Costa |     98.2       0.6       1.3     100.0
          |  9,031.0      67.0      84.0   9,182.0
          | 
   Sierra |     98.8       1.0       0.3     100.0
          | 10,650.0      74.0      22.0  10,746.0
          | 
    Selva |     99.7       0.2       0.1     100.0
          |  6,683.0      15.0       5.0   6,703.0
          | 
    Total |     98.6       0.6       0.8     100.0
          | 26,364.0     156.0     111.0  26,631.0
--------------------------------------------------

*/

**-- Se exportan las tablas
	// Nota: Dado que es Stata 16, no se puede usar comandos de Stata 17 o 18 que harían más simple el proceso para exportar tablas

    cd"$output"
	tempvar letter
    gen `letter'=66
	forval i=1/13 {
    local locletter`i'=char(`letter'+(`i'-1))
	}
	
	local row = 2
	
    putexcel set Ejercicio_1.xlsx, sheet("Región") modify
	putexcel `locletter1'`row'="Tabla 1: Personas en situación de pobreza matriculadas en universidades privadas y públicas - Por región", bold
	
	local row = `row' + 2
	local row2 = `row' + 2
	putexcel `locletter1'`row':`locletter1'`row2'="Región", merge vcenter
	putexcel `locletter2'`row':`locletter7'`row'="Muestra: Población pobre", merge hcenter
	putexcel `locletter8'`row':`locletter13'`row'="Muestra: Población de 17 a 24 años pobre", merge hcenter
	
	local row = `row' + 1
	putexcel `locletter2'`row':`locletter3'`row'="Costa", merge hcenter
	putexcel `locletter4'`row':`locletter5'`row'="Sierra", merge hcenter
	putexcel `locletter6'`row':`locletter7'`row'="Selva", merge hcenter
	putexcel `locletter8'`row':`locletter9'`row'="Costa", merge hcenter
	putexcel `locletter10'`row':`locletter11'`row'="Sierra", merge hcenter
	putexcel `locletter12'`row':`locletter13'`row'="Selva", merge hcenter
	
	local row = `row' + 1
	forval i=2(2)12 {
	putexcel `locletter`i''`row'="Total"
	}

	forval i=3(2)13 {
	putexcel `locletter`i''`row'="%"
	}
	
	foreach lab in "No matriculado" "Matriculado en Univ. Pública" "Matriculado en Univ. Privada" {
	local row = `row' + 1
	putexcel `locletter1'`row'="`lab'"
	}

	local row = `row' - 2

	forvalues x=1/3 {
	tab matri_univ if region==`x' & (pobreza==1 | pobreza==2) [aw=factora07], matcell(freq) matrow(names)
	local rows = rowsof(names)	
	forvalues i = 1/`rows' {
        local freq_val = freq[`i',1]
        local percent_val = `freq_val'/`r(N)'*100
        local percent_val : display %9.2f `percent_val'
        putexcel `locletter2'`row'=(`freq_val') `locletter3'`row'=(`percent_val')
        local row = `row' + 1
	}	
        local row = `row' - 3
		replace `letter'=`letter'+2
		local locletter2 =char(`letter'+1)
		local locletter3 =char(`letter'+2)
}

	tempvar letter2
    gen `letter2'=72
	forval i=1/7 {
    local locletter`i'=char(`letter2'+(`i'-1))
	}
	
	forvalues x=1/3 {
	tab matri_univ_c if region==`x' & (pobreza==1 | pobreza==2) [aw=factora07], matcell(freq) matrow(names)
	local rows = rowsof(names)	
	forvalues i = 1/`rows' {
        local freq_val = freq[`i',1]
        local percent_val = `freq_val'/`r(N)'*100
        local percent_val : display %9.2f `percent_val'
        putexcel `locletter2'`row'=(`freq_val') `locletter3'`row'=(`percent_val')
        local row = `row' + 1
	}	
        local row = `row' - 3
		replace `letter2'=`letter2'+2
		local locletter2 =char(`letter2'+1)
		local locletter3 =char(`letter2'+2)
}
	
	tempvar letter
    gen `letter'=66
	forval i=1/5 {
    local locletter`i'=char(`letter'+(`i'-1))
	}
	
	local row = `row' + 5
	putexcel `locletter2'`row':`locletter3'`row'="Muestra: Población", merge hcenter
	local row = `row' + 1
	putexcel `locletter2'`row'="Total" `locletter3'`row'="%"
	tab matri_univ if (pobreza==1 | pobreza==2) [aw=factora07], matcell(freq) matrow(names)
	local rows = rowsof(names)
	local varlabel: var label matri_univ
	putexcel `locletter1'`row'="`varlabel'"
    local row = `row' + 1	
	forvalues i = 1/`rows' {
        local val = names[`i',1]
		local val_lab : label (matri_univ) `val'
        local freq_val = freq[`i',1]
        local percent_val = `freq_val'/`r(N)'*100
        local percent_val : display %9.2f `percent_val'
        putexcel `locletter1'`row'=("`val_lab'") `locletter2'`row'=(`freq_val') `locletter3'`row'=(`percent_val') 
        local row = `row' + 1
	}	
	putexcel `locletter1'`row'=("Total") `locletter2'`row'=(r(N)) `locletter3'`row'=(100.00)
	
	
	local row = `row' - 5
	putexcel `locletter4'`row':`locletter5'`row'="Muestra: Matriculados actualmente", merge hcenter
	local row = `row' + 1
	putexcel `locletter4'`row'="Total" `locletter5'`row'="%"
	tab matri_univ_b if (pobreza==1 | pobreza==2) [aw=factora07], matcell(freq) matrow(names)
	local rows = rowsof(names)
    local row = `row' + 1
	forvalues i = 1/`rows' {
        local val = names[`i',1]
		local val_lab : label (matri_univ) `val'
        local freq_val = freq[`i',1]
        local percent_val = `freq_val'/`r(N)'*100
        local percent_val : display %9.2f `percent_val'
        putexcel `locletter4'`row'=(`freq_val') `locletter5'`row'=(`percent_val') 
        local row = `row' + 1
	}	
	putexcel `locletter4'`row'=(r(N)) `locletter5'`row'=(100.00)
