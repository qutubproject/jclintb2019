// Useful globals for everybody!

  // Options for -twoway- graphs
  global tw_opts ///
  	title(, justification(left) color(black) span pos(11)) ///
  	graphregion(color(white) lc(white) lw(med)) bgcolor(white) ///
  	ylab(,angle(0) nogrid) xtit(,placement(left) justification(left)) ///
  	yscale(noline) xscale(noline) legend(region(lc(none) fc(none)))

  // Options for -graph- graphs
  global graph_opts ///
  	title(, justification(left) color(black) span pos(11)) ///
  	graphregion(color(white) lc(white) lw(med)) bgcolor(white) ///
  	ylab(,angle(0) nogrid) ytit(,placement(left) justification(left))  ///
  	yscale(noline) legend(region(lc(none) fc(none)))

  // Options for histograms
  global hist_opts ///
  	ylab(, angle(0) axis(2)) yscale(off alt axis(2)) ///
  	ytit(, axis(2)) ytit(, axis(1))  yscale(alt)

  // Useful stuff

  global pct `" 0 "0%" .25 "25%" .5 "50%" .75 "75%" 1 "100%" "'
  global numbering `""(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "(8)" "(9)" "(10)""'
  global bar lc(white) lw(thin) la(center) fi(100) // ← Remove la(center) for Stata < 15

// Analysis for paper

  global dir "/Users/bbdaniels/GitHub/jclintb2019"

  // Figure 1: Testing // 2: Diversity in Incorrect Care (Antibiotic/Steroid/Unlabelled/??? Use) // Figure 3: Checklist Range
  use "${dir}/constructed/SP Interactions.dta" ///
    if case == "Tuberculosis", clear

    assert _N == 1793 // Make sure it is the right number of TB interactions

    replace facility_type = "Public" if regexm(facility_type,"Public")
    replace facility_type = " Township" if regexm(facility_type,"Township")
    replace facility_type = "Private" if study == "Kenya" & !regexm(facility_type,"Public")
    replace study = " Nairobi" if study == "Kenya"
    replace study = " China" if study == "China"
    replace study = "Delhi" if study == "Qutub Pilot"
    replace study = "Patna" if regexm(facility_type,"Patna")
    replace study = "Mumbai" if regexm(facility_type,"Mumbai")
    replace facility_type = "MBBS" if regexm(facility_type,"Hospital") | regexm(facility_type,"Formal")
    replace facility_type = "Non-MBBS" if regexm(facility_type,"Ayush") | regexm(facility_type,"Informal")
    replace lab_cxr = 1 if study == "Delhi"

    graph hbar lab_cxr lab_afb lab_gx ///
      , over(facility_type) over(study) nofill ///
        ${graph_opts} ylab(${pct}) ysize(4.5) ///
        bar(1 , ${bar})  bar(2 , ${bar})  bar(3 , ${bar})

    graph hbox checklist ///
      , over(facility_type, axis(noline)) over(study) nofill noout ///
        ${graph_opts} ylab(${pct}) ysize(4.5) ///
        bar(1 , lc(black) lw(thin) la(center) fi(0) ) ///
        note(" ") ytit("History Checklist Completion {&rarr}")

  // Figure 4.1: Changes with increased info
  use "${dir}/constructed/SP Interactions.dta" ///
    if regexm(study,"Qutub"), clear

    drop if study == "Qutub Pilot"
    replace study = "Patna" if regexm(facility_type,"Patna")
    replace study = "Mumbai" if regexm(facility_type,"Mumbai")
    replace facility_type = "MBBS" if regexm(facility_type,"Hospital") | regexm(facility_type,"Formal")
    replace facility_type = "Non-MBBS" if regexm(facility_type,"Ayush") | regexm(facility_type,"Informal")

    egen lab_any = rowmax(lab_cxr lab_afb lab_gx)

    encode case, gen(case2)
        collapse (mean) lab_any (sebinomial) se=lab_any  , by(case2 facility_type study)
          gen ul = lab_any + 1.96 * se
          gen ll = lab_any - 1.96 * se
        gen check = study + " " + facility_type + " "
        sort check case2

    tw  ///
      (line lab_any case2 , connect(ascending) lc(black) lw(thin)) ///
      (rspike ul ll case2 , connect(ascending) lc(black) lw(thin)) ///
      (scatter lab_any case2 , mlc(black) mlw(med) mfc(white) msize(large)) ///
      (scatter lab_any case2 if case2 == 1 , m(none) mlab(check) mlabc(black) mlabpos(9)) ///
    , ${tw_opts} xtit(" ") xlab(0 "SP Presentation:" 1 `" "Classic" "Case" "' 2 `" "Showed" "X-Ray" "' 3 `" "Showed" "Sputum" "' 4 `" "MDR" "Case" "' , notick) ///
      ylab(${pct} , notick) yline(0 1 , lc(black)) ytit(" ") legend(off)

  // Figure 4.2 // TODO: Change to antibiotics & steroids only
  use "${dir}/constructed/SP Interactions.dta" ///
    if regexm(study,"Qutub"), clear

    drop if study == "Qutub Pilot"
    replace study = "Patna" if regexm(facility_type,"Patna")
    replace study = "Mumbai" if regexm(facility_type,"Mumbai")
    replace facility_type = "MBBS" if regexm(facility_type,"Hospital") | regexm(facility_type,"Formal")
    replace facility_type = "Non-MBBS" if regexm(facility_type,"Ayush") | regexm(facility_type,"Informal")

    gen med_any = med >  0

    encode case, gen(case2)
        collapse (mean) med_any (sebinomial) se=med_any  , by(case2 facility_type study)
          gen ul = med_any + 1.96 * se
          gen ll = med_any - 1.96 * se
        gen check = study + " " + facility_type + " "
        sort check case2

    tw  ///
      (line med_any case2 , connect(ascending) lc(black) lw(thin)) ///
      (rspike ul ll case2 , connect(ascending) lc(black) lw(thin)) ///
      (scatter med_any case2 , mlc(black) mlw(med) mfc(white) msize(large)) ///
      (scatter med_any case2 if case2 == 1 , m(none) mlab(check) mlabc(black) mlabpos(9)) ///
    , ${tw_opts} xtit(" ") xlab(0 "SP Presentation:" 1 `" "Classic" "Case" "' 2 `" "Showed" "X-Ray" "' 3 `" "Showed" "Sputum" "' 4 `" "MDR" "Case" "' , notick) ///
      ylab(.5 "50%" .75 "75%" 1 "100%" , notick) yline(0 1 , lc(black)) ytit(" ") legend(off)

  // Figure 5: SP Fixed Effects

// Have a lovely day!
