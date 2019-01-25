// Figures

  // Figure 1: Management
  use "${dir}/constructed/classic.dta" , clear

    graph hbar med_any  lab_cxr lab_afb lab_gx  ///
      , over(facility_type) over(study) nofill ///
        ${graph_opts} ylab(${pct}) ///
        ysize(4.5) bar(1 , fc(maroon) ${bar}) bar(2 , fc(dkorange) ${bar})  bar(3 , fc(navy) ${bar})  bar(4 , fc(dkgreen) ${bar})  ///
        legend(order(1 "Any Medication" 3 "Sputum AFB" 2 "Chest X-Ray" 4 "Xpert MTB/RIF"))

    graph export "${dir}/outputs/f1.eps" , replace

  // Figure 2: Diversity in Medication Use (Quinolones/Antibiotic/Steroid/Unlabelled Use)
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

    levelsof y2 , local(levels)
    foreach mix in `levels' {
      local lab : lab (y2) `mix'
      local ylab `"`ylab' `mix' "`lab'"  "'
    }

    levelsof x2 , local(levels)
    foreach place in `levels' {
      local plots = "`plots' (scatter y2 x2 if x2 == `place' [pweight = _freq] , m(i) mc(black) ml(_freq) mlabp(0))"
      local lab : lab (x2) `place'
      local xlab `"`xlab' `place' "`lab'"  "'
    }

    tw `plots' , ${graph_opts} ///
      ylab(`ylab' , notick) xlab(`xlab',angle(90)) ///
      legend(off) yscale(reverse) xtit(" ") ytit(" ") xsize(8)

      graph export "${dir}/outputs/f2.eps" , replace

  // Figure 3: Checklist Range
  use "${dir}/constructed/classic.dta" , clear

    graph hbox checklist ///
      , over(facility_type, axis(noline)) over(study) nofill noout ///
        ${graph_opts} ylab(${pct}) ///
        bar(1 , lc(black) lw(thin) la(center) fi(0) ) xsize(8) ///
        note(" ") ytit("History Checklist Completion {&rarr}")

        graph export "${dir}/outputs/f3.eps" , replace

  // Figure 4: Changes by case (Qutub)

    // Figure 4.1: Testing
    use "${dir}/constructed/qutub.dta" , clear

      collapse (mean) lab_any med_tb (sebinomial) se=lab_any  , by(case_code facility_type study)
        gen ul = lab_any + 1.96 * se
        gen ll = lab_any - 1.96 * se
      gen check = study + " " + facility_type + " "
      sort check case_code

      tw  ///
        (line lab_any case_code , connect(ascending) lc(black) lw(thin)) ///
        (line med_tb case_code if case_code >= 2 & !regexm(check,"Patna Informal"), connect(ascending) lc(black) lw(thin)) ///
        (scatter lab_any case_code , mlc(black) mlw(med) mfc(white) msize(large)) ///
        (scatter med_tb case_code if case_code >= 2 & !regexm(check,"Patna Informal") , mlc(black) mlw(med) mfc(black) msize(large)) ///
        (scatter lab_any case_code if case_code == 1 , m(none) mlab(check) mlabc(black) mlabpos(9) mlabgap(1)) ///
        (scatter med_tb case_code if case_code == 2 & !regexm(check,"Patna"), m(none) mlab(check) mlabc(black) mlabpos(2) mlabgap(1)) ///
        (scatter med_tb case_code if case_code == 3 & regexm(check,"Patna Formal"), m(none) mlab(check) mlabc(black) mlabpos(10) mlabgap(1)) ///
      , ${tw_opts} xtit(" ") xlab(0 "SP:" 1 `" "Classic" "Case" "' 2 `" "Showed" "X-Ray" "' 3 `" "Showed" "Sputum" "' 4 `" "MDR" "Case" "' , notick) ///
        ylab(1 "100%" 0 "0%"  , notick) yline(0 1 , lc(black)) ytit(" ") legend(order(3 "Laboratory Testing" 4 "Anti-TB Medication") ring(0) pos(11)) title("TB-Related Management")

        graph save "${dir}/temp/f-4-1.gph" , replace

    // Figure 4.2: Steroids & Quinolones
    use "${dir}/constructed/qutub.dta" , clear

      collapse (mean) med_st med_qu  , by(case_code facility_type study)
        // gen ul = med_any + 1.96 * se
        // gen ll = med_any - 1.96 * se
      gen check = study + " " + facility_type + " "
      sort check case_code

      tw  ///
        (line med_st case_code , connect(ascending) lc(black) lw(thin)) ///
        (line med_qu case_code , connect(ascending) lc(black) lw(thin)) ///
        (scatter med_st case_code , mlc(black) mlw(med) mfc(black) msize(large)) ///
        (scatter med_qu case_code , mlc(black) mlw(med) mfc(white) msize(large)) ///
        (scatter med_st case_code if case_code == 1 , m(none) mlab(check) mlabc(black) mlabpos(9) mlabgap(1)) ///
        (scatter med_qu case_code if case_code == 1 , m(none) mlab(check) mlabc(black) mlabpos(9) mlabgap(1)) ///
      , ${tw_opts} xtit(" ") xlab(0 "SP:" 1 `" "Classic" "Case" "' 2 `" "Showed" "X-Ray" "' 3 `" "Showed" "Sputum" "' 4 `" "MDR" "Case" "' , notick) ///
        ylab(.50 "50%" 0 "0%" , notick) yline(0 .5 , lc(black)) ytit(" ") legend(order(4 "Quinolones" 3 "Steroids" ) ring(0) pos(11)) title("Contraindicated Medication")

        graph save "${dir}/temp/f-4-2.gph" , replace

    // Combine
    graph combine ///
      "${dir}/temp/f-4-1.gph" ///
      "${dir}/temp/f-4-2.gph" ///
    , ${comb_opts} r(1) xsize(8)

    graph export "${dir}/outputs/f4.eps" , replace

  // Figure 5: SP Fixed Effects

    // Characteristics
    use "${dir}/constructed/sp_id.dta" , clear
      anova lab_any ///
        i.facility_type i.case ///
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
        , over(n) ${graph_opts} bar(1, fc(black) ${bar}) blab(bar,format(%9.3f)) ///
        ytit("Explained proportion of testing variance {&rarr}")

      graph save "${dir}/temp/f-5-1.gph" , replace
      // graph export "${dir}/outputs/f5.eps" , replace

    // SP ID
    use "${dir}/constructed/sp_id.dta" , clear
      anova lab_any ///
      i.facility_type i.case ///
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
        , over(n) ${graph_opts} bar(1, fc(black) ${bar}) blab(bar,format(%9.3f)) ///
        ytit("Explained proportion of testing variance {&rarr}")

      graph save "${dir}/temp/f-5-2.gph" , replace

    graph combine ///
      "${dir}/temp/f-5-1.gph" ///
      "${dir}/temp/f-5-2.gph" ///
    , ${comb_opts} r(1) xsize(8)

    graph export "${dir}/outputs/f5.eps" , replace

// Have a lovely day!
