
// Table 1: Diversity in Medication Use (Quinolones/Antibiotic/Steroid/Unlabelled Use)
use "${dir}/constructed/classic.dta" , clear

  foreach var in med_st med_qu med_an med_un {
    replace `var' = 0 if `var' == .
    local l : var label `var'
    gen `var'l = "`l'" if `var' == 1
  }

  contract study facility_type med_stl med_qul med_anl med_unl
    gen x = study + " " + facility_type
    gen y = itrim(trim(med_anl + " " + med_qul + " " + med_stl + " " + med_unl))
      replace y = " None" if y == ""
      replace y = subinstr(y," "," + ",.) if y != " None"
      egen check = noccur(y) , string(+)
      replace y = " "*(3-check) + y
    encode x , gen(x2)
    encode y , gen(y2)

  bys x: egen tot = sum(_freq)
    gen perc = 100*(_freq/tot)

  tabout y x using "${dir}/outputs/t1.xls", c(mean _freq) sum replace
  tabout y x using "${dir}/outputs/t1.xls", c(mean perc) sum append

// Figure 1: Management
use "${dir}/constructed/classic.dta" , clear

  graph dot med_any lab_cxr lab_afb lab_gx lab_hiv ///
  , over(facility_type, axis(noline) lab(labsize(vsmall))) over(study) nofill ///
    ${graph_opts} ylab(${pct}) ysize(6) ///
      marker(1, m(T) msize(*3) mlc(white) mlw(vthin) mla(center) mfc(maroon)) ///
      marker(2, m(O) msize(*3) mlc(white) mlw(vthin) mla(center) mfc(dkorange)) ///
      marker(3, m(S) msize(*3) mlc(white) mlw(vthin) mla(center) mfc(navy)) ///
      marker(4, m(D) msize(*3) mlc(white) mlw(vthin) mla(center) mfc(dkgreen)) ///
      marker(5, m(O) msize(*5) mlc(white) mlw(vthin) mla(center) mfc(black)) ///
    linetype(line) line(lw(thin) lc(gs14)) ///
    legend(on span order(1 "Any Medication" 3 "Sputum AFB" 2 "Chest X-Ray" 4 "Xpert MTB/RIF" 5 "HIV Test") ///
      symxsize(small) symysize(small) region(lc(black))) noextendline

  graph export "${dir}/outputs/f1.eps" , replace

// Figure 2: Checklist Range
use "${dir}/constructed/classic.dta" , clear

  graph hbox checklist ///
    , over(facility_type, axis(noline) lab(labsize(vsmall))) over(study) nofill noout ///
      ${graph_opts} ylab(${pct}) ///
      bar(1 , lc(black) lw(thin) la(center) fi(50) fc(navy)) ///
      note(" ") ytit("History Checklist Completion {&rarr}")

      graph export "${dir}/outputs/f2.eps" , replace

// Figure 3: Changes by case (Qutub)

use "${dir}/constructed/qutub.dta" , clear
replace facility_type = study + " " + facility_type

lab def case_code 1 "Classic" 2 "X-Ray" 3 "Sputum" 4 "Recurrent" , replace

  graph dot lab_any med_tb med_st med_qu ///
  , over(case_code, axis(noline) lab(labsize(vsmall))) over(facility_type, lab(labsize(small))) ///
    ${graph_opts} ylab(${pct}) ysize(5) ///
      marker(4, m(T) msize(*3) mlc(white) mlw(vthin) mla(center) mfc(maroon)) ///
      marker(3, m(O) msize(*3) mlc(white) mlw(vthin) mla(center) mfc(dkorange)) ///
      marker(2, m(S) msize(*3) mlc(white) mlw(vthin) mla(center) mfc(navy)) ///
      marker(1, m(D) msize(*3) mlc(white) mlw(vthin) mla(center) mfc(dkgreen)) ///
    linetype(line) line(lw(thin) lc(gs14)) ///
    legend(on span order(1 "Any TB Test" 2 "TB Medication" 3 "Steroids" 4 "Quinolones") ///
      symxsize(small) symysize(small) region(lc(black))) noextendline

  graph export "${dir}/outputs/f3.eps" , replace

// Figure 4: SP Fixed Effects

  // Characteristics
  use "${dir}/constructed/sp_id.dta" , clear
    anova lab_any ///
      i.facility_type_code i.case ///
      c.sp_age c.sp_height c.sp_weight c.sp_bmi sp_male, sequential

      cap mat drop results
      forvalues i = 1/7 {
        mat nr = [`e(ss_`i')']
        mat rownames nr = "`e(term_`i')'"
        mat results = nullmat(results) \ nr
        local `e(term_`i')'l : var lab `e(term_`i')'
        di "``e(term_`i')'l'"
      }

    clear
    svmat results
      replace results1 = results1/`=`e(mss)'+`e(rss)''
    gen n = ""
    forv i = 1/7 {
      replace n = "``e(term_`i')'l'" in `i'
    }

    graph hbar results1 ///
      , over(n) ${graph_opts} bar(1, fc(navy) lc(black) lw(medium)) blab(bar,format(%9.3f)) ///
      ytit("Explained testing variance {&rarr}") ylab(0 "0%" .02 "2%" .04 "4%" .06 "6%" .08 "8%")

    graph save "${dir}/temp/f-4-1.gph" , replace

  // SP ID
  use "${dir}/constructed/sp_id.dta" , clear
    anova lab_any ///
    i.facility_type_code i.case ///
      i.sp_id , sequential


      cap mat drop results
      forvalues i = 1/3 {
        mat nr = [`e(ss_`i')']
        mat rownames nr = "`e(term_`i')'"
        mat results = nullmat(results) \ nr
        local `e(term_`i')'l : var lab `e(term_`i')'
        di "``e(term_`i')'l'"
      }

    clear
    svmat results
      replace results1 = results1/`=`e(mss)'+`e(rss)''
    gen n = ""
    forv i = 1/3 {
      replace n = "``e(term_`i')'l'" in `i'
    }

    graph bar results1 ///
      , over(n) ${graph_opts} bar(1, fc(maroon) lc(black) lw(medium)) blab(bar,format(%9.3f)) ///
      ytit("Explained testing variance {&rarr}") ylab(0 "0%" .02 "2%" .04 "4%" .06 "6%" .08 "8%")

    graph save "${dir}/temp/f-4-2.gph" , replace

  graph combine ///
    "${dir}/temp/f-4-1.gph" ///
    "${dir}/temp/f-4-2.gph" ///
  , ${comb_opts} r(1) xsize(6)

  graph export "${dir}/outputs/f4.eps" , replace

// Have a lovely day!
