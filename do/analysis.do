// Figures

  // Figure 1: Management
  use "${dir}/constructed/classic.dta" , clear

    graph hbar med_any  lab_cxr lab_afb lab_gx  ///
      , over(facility_type,  lab(labsize(vsmall))) over(study) nofill ///
        ${graph_opts} ylab(${pct}) ///
        ysize(5) bar(1 , fc(maroon) ${bar}) bar(2 , fc(dkorange) ${bar})  bar(3 , fc(navy) ${bar})  bar(4 , fc(dkgreen) ${bar})  ///
        legend(on order(1 "Any Medication" 3 "Sputum AFB" 2 "Chest X-Ray" 4 "Xpert MTB/RIF") symxsize(small) symysize(small))

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

    bys x: egen tot = sum(_freq)
      gen perc = 100*(_freq/tot)

    tabout y x using "${dir}/outputs/meds.xls", c(mean _freq) sum replace
    tabout y x using "${dir}/outputs/meds.xls", c(mean perc) sum append

  // Figure 3: Checklist Range
  use "${dir}/constructed/classic.dta" , clear

    graph hbox checklist ///
      , over(facility_type, axis(noline) lab(labsize(vsmall))) over(study) nofill noout ///
        ${graph_opts} ylab(${pct}) ///
        bar(1 , lc(black) lw(thin) la(center) fi(0) ) xsize(7) ///
        note(" ") ytit("History Checklist Completion {&rarr}")

        graph export "${dir}/outputs/f3.eps" , replace

  // Figure 4: Changes by case (Qutub)

    // Figure 4.1: Testing
    use "${dir}/constructed/qutub.dta" , clear
    replace facility_type = " Hospital" if facility_type == "Hospital"

    lab def case_code 1 "A" 2 "B" 3 "C" 4 "D" , replace

    graph bar lab_any med_tb ///
      , over(case_code) over(facility_type)   ///
        nofill ylab(${pct}) ///
        bar(1 , fc(dkgreen) lc(white) lw(medium) la(center)) ///
        bar(2 , fc(black) lc(white) lw(medium) la(center)) ///
        legend(on pos(12) order(1 "TB Testing" 2 "Anti-TB Medication") region(lc(none) fc(none)))

        graph save "${dir}/temp/f-4-1.gph" , replace


    graph bar med_st med_qu ///
      , over(case_code) over(facility_type)   ///
        nofill ylab(${pct}) ///
        bar(1 , fc(dkorange) lc(white) lw(medium) la(center)) ///
        bar(2 , fc(maroon) lc(white) lw(medium) la(center)) ///
        legend(on pos(12) order(1 "Steroids" 2 "Fluoroquinolones") region(lc(none) fc(none)))

        graph save "${dir}/temp/f-4-2.gph" , replace

    // Combine
    graph combine ///
      "${dir}/temp/f-4-1.gph" ///
      "${dir}/temp/f-4-2.gph" ///
    , ${comb_opts} r(1) xsize(7)

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
    , ${comb_opts} r(1)

    graph export "${dir}/outputs/f5.eps" , replace

// Have a lovely day!
