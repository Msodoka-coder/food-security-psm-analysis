
****************************************************
* Project: Do VSLA Enhance Food Security in Malawi?
* Author: Issa Msodoka
* Date: 2025
* Description:
* This script analyzes:
* 1) Socio-economic factors influencing VSLA membership
* 2) The impact of VSLA participation on food security
*    using Propensity Score Matching (PSM)
****************************************************

*--------------------------------------------------*
* Set working directory (same folder as the do-file)
*--------------------------------------------------*
cd "."

* Start log file
log using "vsla_food_security.log", replace

* Load dataset
use "analysis_vsla.dta", clear

*--------------------------------------------------*
* SECTION 1: DATA PREPARATION
*--------------------------------------------------*

*Create updated VSLA membership variable
gen VSLA_MEMBER_UPDATED = .
replace VSLA_MEMBER_UPDATED = 1 if VSLA_Membership_Years > 2
replace VSLA_MEMBER_UPDATED = 0 if VSLA_Membership_Years <= 2


* Recode sex variable: 0 = male, 1 = female
recode sex (1=0) (2=1)
label define sex_lbl 0 "male" 1 "female"
label values sex sex_lbl

* Generate dummy variables for categorical variables
tab education, gen(Educ_)
tab occupation, gen(occupation_)
tab religion, gen(religion_)
tab maritalstatus, gen(maritalstatus_)

*--------------------------------------------------*
* SECTION 2: OBJECTIVE 1
* Factors influencing VSLA participation
*--------------------------------------------------*

probit VSLA_MEMBER_UPDATED ///
    district ///
    age ///
    sex ///
    maritalstatus_2 ///
    religion_2 ///
    HH_size ///
    Land_Total_Acres ///
    i.education ///
    occupation_3 ///
    VSLA_Friends ///
    Group_Membership ///
    Credit_Interest_Rate

* Marginal effects
margins, dydx(*)

*--------------------------------------------------*
* SECTION 3: OBJECTIVE 2
* Impact of VSLA participation on food security
*--------------------------------------------------*

* Construct Coping Strategy Index (CSI)
gen CSI = .

replace CSI = new_1 * 2 * 5 if new_1 == 1
replace CSI = new_2 * 4 * 5 if new_2 == 1
replace CSI = new_3 * 1 * 7 if new_3 == 1
replace CSI = new_4 * 1 * 7 if new_4 == 1
replace CSI = new_5 * 1 * 7 if new_5 == 1
replace CSI = new_6 * 5 * 7 if new_6 == 1
replace CSI = new_7 * 1 * 7 if new_7 == 1
replace CSI = new_8 * 1 * 7 if new_8 == 1

* Set CSI to zero for low scores among members
replace CSI = 0 if CSI < 10 & VSLA_MEMBER_UPDATED == 1

*--------------------------------------------------*
* SECTION 4: PROPENSITY SCORE MATCHING (PSM)
*--------------------------------------------------*

teffects psmatch ///
    (CSI) ///
    (VSLA_MEMBER_UPDATED ///
        sex ///
        age ///
        religion_2 ///
        maritalstatus_2 ///
        i.education)


log close
