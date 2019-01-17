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

// Figure 1: Testing

  use "${dir}/constructed/SP Interactions.dta" ///
    if case == "Tuberculosis", clear

    assert _N == 1793 // Make sure it is the right number of TB interactions

    replace facility_type = "Public" if regexm(facility_type,"Public")
    replace facility_type = "Private" if study == "Kenya" & !regexm(facility_type,"Public")
    replace study = " Nairobi" if study == "Kenya"
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
      , over(facility_type) over(study) nofill ///
        ${graph_opts} ylab(${pct}) ysize(4.5) 

// Have a lovely day!
