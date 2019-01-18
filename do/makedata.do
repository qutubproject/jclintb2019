// Data setup for analysis

// Medications setup

  use "${dir}/data/raw/SP Medications.dta" , clear

    gen med_st = regexm(med_atc_code,"H02") | regexm(med_atc_code,"R01") | regexm(med_atc_code,"R03")
    gen med_tb = regexm(med_atc_code,"J04")
    gen med_qu = regexm(med_atc_code,"J01M")
    gen med_an = regexm(med_atc_code,"J01") & !regexm(med_atc_code,"J01M")
    gen med_un = med_atc_code == ""

  collapse (max) med_?? , by(study case uniqueid) fast
    label var med_st "Steroids"
    label var med_tb "Anti-TB"
    label var med_qu "Quinolones"
    label var med_un "Unlabelled"
    label var med_an "Antibiotics"

  save "${dir}/constructed/meds.dta" , replace
    use "${dir}/constructed/meds.dta" , clear

// Full TB Classic interactions data

   use "${dir}/data/raw/SP Interactions.dta" ///
     if case == "Tuberculosis", clear

   merge 1:1 study case uniqueid using "${dir}/constructed/meds.dta" , keep(1 3) nogen

   assert _N == 1793 // Make sure it is the right number of TB interactions

   drop if study == "Qutub Pilot"

   replace facility_type = "Public" if regexm(facility_type,"Public")
   replace facility_type = " Township" if regexm(facility_type,"Township")
   replace facility_type = "Private" if study == "Kenya" & !regexm(facility_type,"Public")
   replace study = " Nairobi" if study == "Kenya"
   replace study = " China" if study == "China"
   replace study = "Delhi" if study == "Qutub Pilot"
   replace study = "Patna" if regexm(facility_type,"Patna")
   replace study = "Mumbai" if regexm(facility_type,"Mumbai")

   foreach type in Hospital Formal Ayush Informal {
     replace facility_type = "`type'" if regexm(facility_type,"`type'")
   }

   gen med_any = med >  0

  save "${dir}/constructed/classic.dta" , replace
    use "${dir}/constructed/classic.dta" , clear

// TB SP 1-4: Patna & Mumbai

  use "${dir}/data/raw/SP Interactions.dta" ///
    if regexm(study,"Qutub"), clear

  merge 1:1 study case uniqueid using "${dir}/constructed/meds.dta" , keep(1 3) nogen

  drop if study == "Qutub Pilot"
  replace study = "Patna" if regexm(facility_type,"Patna")
  replace study = "Mumbai" if regexm(facility_type,"Mumbai")
  foreach type in Hospital Formal Ayush Informal {
    replace facility_type = "`type'" if regexm(facility_type,"`type'")
  }

  egen lab_any = rowmax(lab_cxr lab_afb lab_gx)
  gen med_any = med >  0

  encode case, gen(case_code)

  save "${dir}/constructed/qutub.dta" , replace
    use "${dir}/constructed/qutub.dta" , clear

// SP Characteristics & FE from Qutub Study

  use "/Users/bbdaniels/Dropbox/WorldBank/qutub/Restricted/CrossCityAnalysis/constructed/analysis_baseline.dta" , clear

  gen sp_bmi = (sp_weight*10000)/(sp_height*sp_height)
    label var sp_bmi "SP BMI"

  gen facility_type = "MBBS"
    replace facility_type = "Non-MBBS" if regexm(facilitycode,"QI") | regexm(facilitycode,"QA")
    encode facility_type , gen(facility_type_code)

  keep correct sp_age sp_height sp_weight sp_bmi sp_male city facility_type_code case sp_id

  replace sp_age = sp_age/10
    label var sp_age "SP Age (x10 Years)"

  replace sp_height = sp_height/10
    label var sp_height "SP Height (x10 cm)"

  replace sp_weight = sp_weight/10
    label var sp_weight "SP Weight (x10 kg)"

  label def case 1 "Classic" 2 "SP: Showed X-Ray" 3 "SP: Showed Sputum" 4 "SP: MDR Case" , modify

  gen temp = string(sp_id)
    drop sp_id
    encode temp , gen(sp_id)
    label drop sp_id
    label var sp_id "SP ID"

  save "${dir}/constructed/sp_id.dta" , replace
    use "${dir}/constructed/sp_id.dta" , clear


// Have a lovely day!
