
*===============================================================================
* - - - - write output to files - - - -
*===============================================================================
Files
         input_echo_file         /'%outdir%%ds%Storage_dispatch_inputs_%file_name_instance%.csv'/
         results_file            /'%outdir%%ds%Storage_dispatch_results_%file_name_instance%.csv'/
         summary_file            /'%outdir%%ds%Storage_dispatch_summary_%file_name_instance%.csv'/
         summary_file_yearly     /'%outdir%%ds%Storage_dispatch_summary_yearly_%file_name_instance%.csv'/
         RT_out_file             /'%outdir%%ds%Real_time_output_values.csv'/
         results_file_devices    /'%outdir%%ds%Storage_dispatch_resultsDevices_%file_name_instance%.csv'/
         summary_file_devices    /'%outdir%%ds%Storage_dispatch_summaryDevices_%file_name_instance%.csv'/
;


scalar max_max_cap; max_max_cap = max(smax(devices,input_capacity_MW(devices)),smax(devices,output_capacity_MW(devices)));
* Create Dynamic set     (1. Create a large set, 2. Find the max dimension, 3. Create a new set as a subset, 4. Limit the subset to the max dimension
set most_devices_limit /1*2/;
scalar most_devices; most_devices = max(card(devices),card(devices_ren))
set most_devices_set(most_devices_limit);
most_devices_set(most_devices_limit)$(ord(most_devices_limit) <= most_devices) = yes;
Parameter
    Output_power_sold(interval,devices)
    Output_power_load(interval,devices)
;
Output_power_sold(interval,devices) = output_power_MW_non_ren_sold.l(interval,devices)+output_power_MW_ren_sold.l(interval,devices);
Output_power_load(interval,devices) = output_power_MW_non_ren_load.l(interval,devices)+output_power_MW_ren_load.l(interval,devices);


if( (arbitrage_and_AS.modelstat=1 or arbitrage_and_AS.modelstat=2 or arbitrage_and_AS.modelstat=8),

         if ( max_max_cap>100, input_echo_file.nd = 2; else input_echo_file.nd = 4; );
         input_echo_file.pw = 10000;
         put input_echo_file;
                 PUT 'Run on a %system.filesys% machine on %system.date% %system.time%.' /;
                 put 'Optimal solution found within time limit:,',
                 if ( optimal_solution_reached = 1,
                         put 'Yes' /;
                 else
                         put 'No' /;
                 );
                 put /;
                 put 'zone, %zone_instance%' /;
                 put 'year, %year_instance%' /;
                 put 'interval length (hours), ',        interval_length /;
                 put 'operating period length (hours), ' operating_period_length /;
                 put 'additional look-ahead (hours), '   look_ahead_length /;
                 put 'output capacity (MW), ',           sum(devices, output_capacity_MW(devices)) /;
                 put 'input capacity (MW), ',            sum(devices, input_capacity_MW(devices))   /;
                 put 'storage capacity (hours), ',       sum(devices, storage_capacity_hours(devices)) /;
                 put 'input efficiency (%), ',           sum(devices, input_efficiency(devices)) /;
                 put 'output efficiency (%), ',          sum(devices, output_efficiency(devices)) /;
                 put 'input heat rate (MMBtu/MWh), ',    sum(devices, input_heat_rate(devices)) /;
                 put 'ouptut heat rate (MMBtu/MWh), ',   sum(devices, output_heat_rate(devices)) /;
                 put 'variable O&M cost, ',              VOM_cost /;
                 put 'regulation cost, ',                reg_cost /;
                 put 'hydrogen use, ',                   sum(devices, H2_use(devices)) /;
                 put /;
                 put 'input' /;
                 put 'LSL limit fraction, ',             sum(devices, input_LSL_fraction(devices)) /;
                 put 'reg up limit fraction, ',          sum(devices, input_regup_limit_fraction(devices)) /;
                 put 'reg down limit fraction, ',        sum(devices, input_regdn_limit_fraction(devices)) /;
                 put 'spining reserve limit fraction, ', sum(devices, input_spinres_limit_fraction(devices)) /;
                 put 'startup cost ($/MW-start), ',      sum(devices, input_startup_cost(devices)):0:10 /;
                 put 'minimum run intervals, '           min_input_on_intervals /;
                 put /;
                 put 'output' /;
                 put 'LSL limit fraction, ',             sum(devices, output_LSL_fraction(devices)) /;
                 put 'reg up limit fraction, ',          sum(devices, output_regup_limit_fraction(devices)) /;
                 put 'reg down limit fraction, ',        sum(devices, output_regdn_limit_fraction(devices)) /;
                 put 'spining reserve limit fraction, ', sum(devices, output_spinres_limit_fraction(devices)) /;
                 put 'startup cost ($/MW-start), ',      sum(devices, output_startup_cost(devices)):0:10 /;
                 put 'minimum run intervals, ',          min_output_on_intervals /;
                 put /;
                 put 'Int,Elec Purchase ($/MWh),Elec Sale ($/MWh), Elec Purchase RT ($/MWh),Elec Sale RT ($/MWh),Reg Up ($/MW),Reg Dn ($/MW),Spin Res ($/MW),Nonspin Res ($/MW),Nat Gas ($/MMBTU),H2 ($/kg),Renewable In (MW),Load Profile (MW),Input Cap, Output Cap,Meter ($/mth)' /;
                 loop(interval, put      ord(interval),',',
                                         elec_purchase_price(interval),',',
                                         elec_sale_price(interval),',',
                                         elec_purchase_price_RT(interval),',',
                                         elec_sale_price_RT(interval),',',
                                         regup_price(interval),',',
                                         regdn_price(interval),',',
                                         spinres_price(interval),',',
                                         nonspinres_price(interval),',',
                                         NG_price(interval),',',
                                         sum(devices, H2_price(interval,devices)),',',
                                         sum(devices_ren, Renewable_power(interval,devices_ren)),',',
                                         Load_profile(interval),',',
                                         sum(devices, Max_input_cap(interval,devices)),',',
                                         sum(devices, Max_output_cap(interval,devices)),',',
                                         meter_mnth_chg(interval) /;
                 );

         if ( max_max_cap>100, results_file.nd = 2; elseif max_max_cap>10, results_file.nd = 4; elseif max_max_cap>0.1, results_file.nd = 6; else results_file.nd = 8;);
         results_file.pw = 10000;
         put results_file;
                 PUT 'Run on a %system.filesys% machine on %system.date% %system.time%.' /;
                 put 'Optimal solution found within time limit:,',
                 if ( optimal_solution_reached = 1,
                         put 'Yes' /;
                 else
                         put 'No' /;
                 );
                 put /;
                 put 'Renewable Capacity (MW), ',                sum(devices_ren, Renewable_MW(devices_ren)) /;
                 put 'Renewable Penetration for Input (%), ',    Renewable_pen_input /;
                 put 'hydrogen use, ',                           sum(devices, H2_use(devices)) /;
                 put /;
                 put 'NPV of actual operating profit, ',         actual_operating_profit_NPV /;
                 put 'total electricity input (MWh), ',          elec_in_MWh /;
                 put 'total electricity output (MWh), ',         elec_output_MWh /;
                 put 'output to input ratio, ',                  output_input_ratio /;
                 put 'input capacity factor, ',                  input_capacity_factor /;
                 put 'output capacity factor, ',                 output_capacity_factor /;
                 put 'average regup (MW), ',                     avg_regup_MW /;
                 put 'average regdn (MW), ',                     avg_regdn_MW /;
                 put 'average spinres (MW), ',                   avg_spinres_MW /;
                 put 'average nonspinres (MW), ',                avg_nonspinres_MW /;
                 put 'number of input power system starts, ',    num_input_starts /;
                 put 'number of output power system starts, ',   num_output_starts /;
                 put 'arbitrage revenue ($),',                   arbitrage_revenue /;
                 put 'regup revenue ($), ',                      regup_revenue /;
                 put 'regdn revenue ($), ',                      regdn_revenue /;
                 put 'spinres revenue ($), ',                    spinres_revenue /;
                 put 'nonspinres revenue ($), ',                 nonspinres_revenue /;
                 put 'hydrogen revenue ($), ',                   H2_revenue /;
                 put 'REC revenue ($), ',                        REC_revenue /;
                 put 'LCFS revenue ($), ',                       LCFS_revenue /;
                 put 'startup costs ($), ',                      startup_costs /;
                 put /;
                 put 'Interval,Input Power (MW),Output Power (MW),Storage Level (MW-h),Input Reg Up (MW),Output Reg Up (MW),Input Reg Dn (MW),Output Reg Dn (MW),Input Spin (MW),Output Spin (MW),Input Nonspin (MW),Output Nonspin (MW),'
                 put 'H2 Sold (kg),Non-Ren Import (MW),Load Profile (MW),Renewable Input (MW),Renewables Sold (MW),Curtailment (MW)'/;
                 loop(interval, put      ord(interval),',',
                                         sum(devices, input_power_MW.l(interval,devices)),',',
                                         sum(devices, output_power_MW.l(interval,devices)),',',
                                         sum(devices, storage_level_MWh_tot(interval,devices)),',',
                                         sum(devices, input_regup_MW.l(interval,devices)),',',
                                         sum(devices, output_regup_MW.l(interval,devices)),',',
                                         sum(devices, input_regdn_MW.l(interval,devices)),',',
                                         sum(devices, output_regdn_MW.l(interval,devices)),',',
                                         sum(devices, input_spinres_MW.l(interval,devices)),',',
                                         sum(devices, output_spinres_MW.l(interval,devices)),',',
                                         sum(devices, input_nonspinres_MW.l(interval,devices)),',',
                                         sum(devices, output_nonspinres_MW.l(interval,devices)),',',
                                         sum(devices, H2_sold.l(interval,devices)),',',
                                         Import_elec_profile.l(interval),',',
                                         Load_profile(interval),',',
                                         sum(devices_ren, Renewable_power(interval,devices_ren)),',',
                                         sum(devices_ren, renewable_power_MW_sold.l(interval,devices_ren)),',',
                                         curtailment(interval) /;
                 );

         summary_file.nd = 8;
         put summary_file;
                 PUT 'Run on a %system.filesys% machine on %system.date% %system.time%.' /;
                 put 'Elapsed Time (minutes):,',                 elapsedtime /;
                 put /;
                 put 'Renewable Capacity (MW), ',                sum(devices_ren, Renewable_MW(devices_ren)) /;
                 put 'Renewable Penetration for Input (%), ',    Renewable_pen_input /;
                 put 'interval length (hours), ',                interval_length /;
                 put 'operating period length (hours), '         operating_period_length /;
                 put 'additional look-ahead (hours), '           look_ahead_length /;
                 put 'output capacity (MW), ',                   sum(devices, output_capacity_MW(devices)) /;
                 put 'input capacity (MW), ',                    sum(devices, input_capacity_MW(devices))   /;
                 put 'storage capacity (hours), ',               sum(devices, storage_capacity_hours(devices)) /;
                 put 'input efficiency (%), ',                   sum(devices, input_efficiency(devices)) /;
                 put 'output efficiency (%), ',                  sum(devices, output_efficiency(devices)) /;
                 put 'input heat rate (MMBtu/MWh), ',            sum(devices, input_heat_rate(devices)) /;
                 put 'ouptut heat rate (MMBtu/MWh), ',           sum(devices, output_heat_rate(devices)) /;
                 put 'variable O&M cost, ',                      VOM_cost /;
                 put 'regulation cost, ',                        reg_cost /;
                 put 'hydrogen use, ',                           sum(devices, H2_use(devices)) /;
                 put /;
                 put 'input' /;
                 put 'LSL limit fraction, ',                     sum(devices, input_LSL_fraction(devices)) /;
                 put 'reg up limit fraction, ',                  sum(devices, input_regup_limit_fraction(devices)) /;
                 put 'reg down limit fraction, ',                sum(devices, input_regdn_limit_fraction(devices)) /;
                 put 'spining reserve limit fraction, ',         sum(devices, input_spinres_limit_fraction(devices)) /;
                 put 'startup cost ($/MW-start), ',              sum(devices, input_startup_cost(devices)):0:10 /;
                 put 'minimum run intervals, '                   min_input_on_intervals /;
                 put /;
                 put 'output' /;
                 put 'LSL limit fraction, ',                     sum(devices, output_LSL_fraction(devices)) /;
                 put 'reg up limit fraction, ',                  sum(devices, output_regup_limit_fraction(devices)) /;
                 put 'reg down limit fraction, ',                sum(devices, output_regdn_limit_fraction(devices)) /;
                 put 'spining reserve limit fraction, ',         sum(devices, output_spinres_limit_fraction(devices)) /;
                 put 'startup cost ($/MW-start), ',              sum(devices, output_startup_cost(devices)):0:10 /;
                 put 'minimum run intervals, ',                  min_output_on_intervals /;
                 put /;
                 put 'total electricity input (MWh), ',          elec_in_MWh /;
                 put 'total electricity output (MWh), ',         elec_output_MWh /;
                 put 'output to input ratio, ',                  output_input_ratio /;
                 put 'input capacity factor, ',                  input_capacity_factor /;
                 put 'output capacity factor, ',                 output_capacity_factor /;
                 put 'average regup (MW), ',                     avg_regup_MW /;
                 put 'average regdn (MW), ',                     avg_regdn_MW /;
                 put 'average spinres (MW), ',                   avg_spinres_MW /;
                 put 'average nonspinres (MW), '                 avg_nonspinres_MW /;
                 put 'number of input power system starts, ',    num_input_starts /;
                 put 'number of output power system starts, ',   num_output_starts /;
                 put 'arbitrage revenue ($),',                   arbitrage_revenue /;
                 put 'regup revenue ($), ',                      regup_revenue /;
                 put 'regdn revenue ($), ',                      regdn_revenue /;
                 put 'spinres revenue ($), ',                    spinres_revenue /;
                 put 'nonspinres revenue ($), ',                 nonspinres_revenue /;
                 put 'hydrogen revenue ($), ',                   H2_revenue /;
                 put 'REC revenue ($), ',                        REC_revenue /;
                 put 'LCFS revenue ($), ',                       LCFS_revenue /;
                 put 'startup costs ($), ',                      startup_costs /;
                 put 'Fixed demand charge ($), ',                Fixed_dem_charge_cost/;
                 put 'Timed demand charge 1 ($), ',              Timed_dem_1_cost/;
                 put 'Timed demand charge 2 ($), ',              Timed_dem_2_cost/;
                 put 'Timed demand charge 3 ($), ',              Timed_dem_3_cost/;
                 put 'Timed demand charge 4 ($), ',              Timed_dem_4_cost/;
                 put 'Timed demand charge 5 ($), ',              Timed_dem_5_cost/;
                 put 'Timed demand charge 6 ($), ',              Timed_dem_6_cost/;
                 put 'Meter cost ($), ',                         Meter_cost/;
                 put 'Renewable sales ($), ',                    renewable_sales /;
                 put 'Renewable FOM cost ($), ',                 renew_FOM_cost2 /;
                 put 'Input FOM cost ($), ',                     input_FOM_cost2 /;
                 put 'Output FOM cost ($), ',                    output_FOM_cost2 /;
                 put 'Renewable VOM cost ($), ',                 renew_VOM_cost2 /;
                 put 'Input VOM cost ($), ',                     input_VOM_cost2 /;
                 put 'Output VOM cost ($), ',                    output_VOM_cost2 /;
                 put 'Debts ($),',                               Debts / ;
                 put 'Taxes ($),',                               Taxes /;
                 put 'Renewable capital cost ($), ',             renew_cap_cost2 /;
                 put 'Input capital cost ($), ',                 input_cap_cost2 /;
                 put 'Output capital cost ($), ',                output_cap_cost2 /;
                 put 'Hydrogen storage cost ($), ',              H2stor_cap_cost2 /;
                 put 'Hydrogen compressor cost ($), '            H2comp_cap_cost2 /;
                 put 'NPV arbitrage revenue ($),',               arbitrage_revenue_NPV /;
                 put 'NPV regup revenue ($), ',                  regup_revenue_NPV /;
                 put 'NPV regdn revenue ($), ',                  regdn_revenue_NPV /;
                 put 'NPV spinres revenue ($), ',                spinres_revenue_NPV /;
                 put 'NPV nonspinres revenue ($), ',             nonspinres_revenue_NPV /;
                 put 'NPV of hydrogen revenue ($), ',            H2_revenue_NPV /;
                 put 'NPV of REC revenue ($), ',                 REC_revenue_NPV /;
                 put 'NPV of LCFS revenue ($), ',                LCFS_revenue_NPV /;
                 put 'NPV of startup costs ($), ',               startup_costs_NPV /;
                 put 'NPV of Fixed demand charge ($), ',         Fixed_dem_charge_cost_NPV/;
                 put 'NPV of Timed demand charge 1 ($), ',       Timed_dem_1_cost_NPV/;
                 put 'NPV of Timed demand charge 2 ($), ',       Timed_dem_2_cost_NPV/;
                 put 'NPV of Timed demand charge 3 ($), ',       Timed_dem_3_cost_NPV/;
                 put 'NPV of Timed demand charge 4 ($), ',       Timed_dem_4_cost_NPV/;
                 put 'NPV of Timed demand charge 5 ($), ',       Timed_dem_5_cost_NPV/;
                 put 'NPV of Timed demand charge 6 ($), ',       Timed_dem_6_cost_NPV/;
                 put 'NPV of Meter cost ($), ',                  Meter_cost_NPV/;
                 put 'NPV Renewable sales ($), ',                renewable_sales_NPV /;
                 put 'NPV Renewable FOM cost ($), ',             renew_FOM_cost2_NPV /;
                 put 'NPV Input FOM cost ($), ',                 input_FOM_cost2_NPV /;
                 put 'NPV Output FOM cost ($), ',                output_FOM_cost2_NPV /;
                 put 'NPV Renewable VOM cost ($), ',             renew_VOM_cost2_NPV /;
                 put 'NPV Input VOM cost ($), ',                 input_VOM_cost2_NPV /;
                 put 'NPV Output VOM cost ($), ',                output_VOM_cost2_NPV /;
                 put 'NPV of Debts ($),',                        Debts_NPV / ;
                 put 'NPV of Taxes ($),',                        Taxes_NPV /;
                 put 'NPV of actual operating profit ($), ',     actual_operating_profit_NPV /;
                 put 'Renewable Penetration net meter (%), ',    Renewable_pen_input_net /;
                 put 'Curtailment (MWh), ',                      curtailment_sum /;
                 put 'Storage revenue ($), ',                    Storage_revenue /;
                 put 'Renewable only revenue ($), ',             Renewable_only_revenue /;
                 put 'Renewable max revenue ($), ',              Renewable_max_revenue /;
                 put 'Renewable Electricity Input (MWh), ',      Renewable_electricity_in /;
                 put 'Electricity Import (MWh), ',               Electricity_import /;
                 put 'Total Electricity Consumed (MWh), ',       Total_elec_consumed /;
                 put 'Yearly Debt service ($), ',                (debt_service.l) /;
                 put 'WACC, ',                                   (wacc) /;
                 put 'Num of e-devices, ',                       (num_elec_devices) /;
                 put 'Num of non-e-devices, ',                   (num_non_elec_devices) /;
                 put /
                 put 'Hydrogen cost breakdown (US$/kg)' /;
                 put 'LCFS_FCEV (US$/kg),',                      (- LCFS_revenueH2) /;
                 put 'Renewable revenue(US$/kg),',               (- Renewable_revenueH2) /;
                 put 'Energy charge (US$/kg),',                  (- Energy_chargeH2) /;
                 put 'Fixed demand charge (US$/kg),',            (- Fixed_demand_chargeH2) /;
                 put 'Timed demand charge (US$/kg),',            (- Timed_demand_chargeH2) /;
                 put 'Meters cost (US$/kg),',                    (- Meters_costH2) /;
                 put 'Storage & compression cost (US$/kg),',     (- Storage_costH2 - Compressor_costH2 - Debts_StoNComp*DebtsH2) /;
                 put 'Input CAPEX (US$/kg),',                    (-input_cap_costH2 - Debts_Input*DebtsH2) /;
                 put 'Input FOM (US$/kg),',                      (-input_FOM_costH2) /;
                 put 'Renewable capital cost (US$/kg),',         (-Renewable_cap_costH2 - Debts_Renewable*DebtsH2) /;
                 put 'Renewable FOM (US$/kg),',                  (-Renewable_FOM_costH2) /;
                 put 'Taxes (US$/kg),',                          (-TaxesH2) /;
                 put 'H2 NPV cost (US$/kg),',                    (-H2_break_even_cost) / ;
                 put /;

         summary_file_yearly.nd = 8;
         summary_file_yearly.pw = 10000;
         put summary_file_yearly;
                 put 'Year, Fixed demand charge, Timed demand charge 1, Timed demand charge 2, Timed demand charge 3, Timed demand charge 4, Timed demand charge 5,  Timed demand charge 6, Meter cost,'
                 put 'Fuel cost, Electricity cost, Electricity cost (renewable), Arbitrage, Renewable sales, REC revenue, LCFS revenue,'
                 put 'Renewable FOM, Input FOM, Output FOM, Renewable VOM, Input VOM, Output VOM,'
                 put 'Regulation up, Regulation down, Spinning reserve, Nonspinning reserve, Startup costs, H2 revenue,'
                 put 'H2 sold (kg), H2 revenue adj, H2 price ($/kg), Taxes, Debts, Actual operating profit, Depreciated value, Inflation, Tax carryover, Divide by this to convert to NPV' /;
                 loop(years, put         ord(years),',',
                                         Fixed_dem_charge_cost_yearly(years),',',
                                         Timed_dem_1_cost_yearly(years),',',
                                         Timed_dem_2_cost_yearly(years),',',
                                         Timed_dem_3_cost_yearly(years),',',
                                         Timed_dem_4_cost_yearly(years),',',
                                         Timed_dem_5_cost_yearly(years),',',
                                         Timed_dem_6_cost_yearly(years),',',
                                         Meter_cost_yearly(years),',',
                                         fuel_cost_yearly(years),',',
                                         elec_cost_yearly(years),',',
                                         elec_cost_ren_yearly(years),',',
                                         arbitrage_revenue_yearly(years),',',
                                         renewable_sales_yearly(years),',',
                                         REC_revenue_yearly(years),',',
                                         LCFS_revenue_yearly(years),',',
                                         renew_FOM_cost2_yearly(years),',',
                                         input_FOM_cost2_yearly(years),',',
                                         output_FOM_cost2_yearly(years),',',
                                         renew_VOM_cost2_yearly(years),',',
                                         input_VOM_cost2_yearly(years),',',
                                         output_VOM_cost2_yearly(years),',',
                                         regup_revenue_yearly(years),',',
                                         regdn_revenue_yearly(years),',',
                                         spinres_revenue_yearly(years),',',
                                         nonspinres_revenue_yearly(years),',',
                                         startup_costs_yearly(years),',',
                                         H2_revenue_yearly(years),',',
                                         H2_sold_yearly(years),',',
                                         H2_revenue_yearly2(years),',',
                                         H2_price_yearly(years),',',
                                         Taxes_yearly(years),',',
                                         Debts_yearly(years),',',
                                         actual_operating_profit_yearly(years),',',
                                         amount_depreciated.l(years),',',
                                         inflation_vec(years),',',
                                         reserved_taxes.l(years),',',
                                         to_NPV(years) /;
                 );
                 put /;

*$ontext

         if ( max_max_cap>100, results_file_devices.nd = 2; elseif max_max_cap>10, results_file_devices.nd = 4; elseif max_max_cap>0.1, results_file_devices.nd = 6; else results_file_devices.nd = 8;);
         results_file_devices.pw = 20000;
         put results_file_devices;
                 put 'Interval,';
                 loop(devices, put 'In Pwr ',ord(devices):0:0,' (MW),Out Pwr Sold',ord(devices):0:0,' (MW),Out Pwr Load',ord(devices):0:0,' (MW),Storage Lvl ',ord(devices):0:0,' (MW-h),Cool Down Period ',ord(devices):0:0,' (Binary),H2 Out ',ord(devices):0:0,' (kg),Non-Ren In ',ord(devices):0:0,' (MW),');
                 loop(devices_ren, put 'Ren In ',ord(devices_ren):0:0,' (MW),Ren Sold ',ord(devices_ren):0:0,' (MW),');
                 put 'Curtailment (MW), Elec Purchase (INR/MWh), Elec Purchase RT (INR/MWh)' /;
                 loop(interval, 
                        put      ord(interval),',';
                                loop(devices,     put input_power_MW.l(interval,devices),',',
                                                      Output_power_sold(interval,devices),',',
                                                      Output_power_load(interval,devices),',',
                                                      storage_level_MWh_tot(interval,devices),',',
                                                      cooldown.l(interval,devices),',',
                                                      H2_sold.l(interval,devices),',',
                                                      input_power_MW_non_ren.l(interval,devices),',',);
                                loop(devices_ren, put Renewable_power(interval,devices_ren),',',
                                                      renewable_power_MW_sold.l(interval,devices_ren),',');
                                                  put curtailment(interval),',',
                                                      elec_purchase_price(interval),',',
                                                      elec_purchase_price_RT(interval)                                                     
                                                      ;
                                put /;
                 );

         if ( max_max_cap>100, summary_file_devices.nd = 2; else summary_file_devices.nd = 4; );
         summary_file_devices.pw = 20000;
         put summary_file_devices;
                 PUT 'Run on a %system.filesys% machine on %system.date% %system.time%.' /;
                 put 'Optimal solution found within time limit:,',
                 if ( optimal_solution_reached = 1,
                         put 'Yes' /;
                 else
                         put 'No' /;
                 );
                 put /;
                 put 'Device Number,';                           loop(most_devices_set, put most_devices_set.tl,',');            put /;
                 put 'Renewable Capacity (MW),';                 loop(devices_ren, put Renewable_MW(devices_ren),',');           put /;
                 put 'Renewable Penetration for Input (%), ',    Renewable_pen_input /;
                 put 'interval length (hours), ',                interval_length /;
                 put 'operating period length (hours), '         operating_period_length /;
                 put 'additional look-ahead (hours), '           look_ahead_length /;
                 put 'output capacity (MW), ',                   loop(devices, put output_capacity_MW(devices),',');             put /;
                 put 'input capacity (MW), ',                    loop(devices, put input_capacity_MW(devices),',');              put /;
                 put 'storage capacity (hours), ',               loop(devices, put storage_capacity_hours(devices),',');         put /;
                 put 'input efficiency (%), ',                   loop(devices, put input_efficiency(devices),',');               put /;
                 put 'output efficiency (%), ',                  loop(devices, put output_efficiency(devices),',');              put /;
                 put 'input heat rate (MMBtu/MWh), ',            loop(devices, put input_heat_rate(devices),',');                put /;
                 put 'ouptut heat rate (MMBtu/MWh), ',           loop(devices, put output_heat_rate(devices),',');               put /;
                 put 'variable O&M cost, ',                      VOM_cost /;
                 put 'regulation cost, ',                        reg_cost /;
                 put 'hydrogen use, ',                           loop(devices, put H2_use(devices),',');                         put /;
                 put /;
                 put 'input' /;
                 put 'LSL limit fraction, ',                     loop(devices, put input_LSL_fraction(devices),',');             put /;
                 put 'reg up limit fraction, ',                  loop(devices, put input_regup_limit_fraction(devices),',');     put /;
                 put 'reg down limit fraction, ',                loop(devices, put input_regdn_limit_fraction(devices),',');     put /;
                 put 'spining reserve limit fraction, ',         loop(devices, put input_spinres_limit_fraction(devices),',');   put /;
                 put 'startup cost ($/MW-start), ',              loop(devices, put input_startup_cost(devices),',');             put /;
                 put 'minimum run intervals, '                   min_input_on_intervals /;
                 put /;
                 put 'output' /;
                 put 'LSL limit fraction, ',                     loop(devices, put output_LSL_fraction(devices),',');            put /;
                 put 'reg up limit fraction, ',                  loop(devices, put output_regup_limit_fraction(devices),',');    put /;
                 put 'reg down limit fraction, ',                loop(devices, put output_regdn_limit_fraction(devices),',');    put /;
                 put 'spining reserve limit fraction, ',         loop(devices, put output_spinres_limit_fraction(devices),',');  put /;
                 put 'startup cost ($/MW-start), ',              loop(devices, put output_startup_cost(devices),',');            put /;
                 put 'minimum run intervals, ',                  min_output_on_intervals /;
                 put /;
                 put 'actual operating profit ($), ',            sum(years,actual_operating_profit_yearly(years)) /;
                 put 'total electricity input (MWh), ',          elec_in_MWh /;
                 put 'total electricity output (MWh), ',         elec_output_MWh /;
                 put 'output to input ratio, ',                  output_input_ratio /;
                 put 'input capacity factor, ',                  input_capacity_factor /;
                 put 'output capacity factor, ',                 output_capacity_factor /;
                 put 'average regup (MW), ',                     loop(devices, put avg_regup_MW_vec(devices),',');               put /;
                 put 'average regdn (MW), ',                     loop(devices, put avg_regdn_MW_vec(devices),',');               put /;
                 put 'average spinres (MW), ',                   loop(devices, put avg_spinres_MW_vec(devices),',');             put /;
                 put 'average nonspinres (MW), '                 loop(devices, put avg_nonspinres_MW_vec(devices),',');          put /;
                 put 'number of input power system starts, ',    loop(devices, put num_input_starts_vec(devices),',');           put /;
                 put 'number of output power system starts, ',   loop(devices, put num_output_starts_vec(devices),',');          put /;
                 put 'arbitrage revenue ($),',                   loop(devices, put arbitrage_revenue_vec(devices),',');          put /;
                 put 'regup revenue ($), ',                      loop(devices, put regup_revenue_vec(devices),',');              put /;
                 put 'regdn revenue ($), ',                      loop(devices, put regdn_revenue_vec(devices),',');              put /;
                 put 'spinres revenue ($), ',                    loop(devices, put spinres_revenue_vec(devices),',');            put /;
                 put 'nonspinres revenue ($), ',                 loop(devices, put nonspinres_revenue_vec(devices),',');         put /;
                 put 'hydrogen revenue ($), ',                   loop(devices, put H2_revenue_vec(devices),',');                 put /;
                 put 'REC revenue ($), ',                        REC_revenue /;
                 put 'LCFS revenue ($), ',                       LCFS_revenue /;
                 put 'startup costs ($), ',                      loop(devices, put startup_costs_vec(devices),',');              put /;
                 put 'Fixed demand charge ($), ',                Fixed_dem_charge_cost/;
                 put 'Timed demand charge 1 ($), ',              Timed_dem_1_cost/;
                 put 'Timed demand charge 2 ($), ',              Timed_dem_2_cost/;
                 put 'Timed demand charge 3 ($), ',              Timed_dem_3_cost/;
                 put 'Timed demand charge 4 ($), ',              Timed_dem_4_cost/;
                 put 'Timed demand charge 5 ($), ',              Timed_dem_5_cost/;
                 put 'Timed demand charge 6 ($), ',              Timed_dem_6_cost/;
                 put 'Meter cost ($), ',                         Meter_cost/;
                 put 'Renewable capital cost ($), ',             loop(devices_ren, put renew_cap_cost2_vec(devices_ren),',');    put /;
                 put 'Input capital cost ($), ',                 loop(devices, put input_cap_cost2_vec(devices),',');            put /;
                 put 'Output capital cost ($), ',                loop(devices, put output_cap_cost2_vec(devices),',');           put /;
                 put 'Hydrogen storage cost ($), ',              loop(devices, put H2stor_cap_cost2_vec(devices),',');           put /;
                 put 'Renewable FOM cost ($), ',                 loop(devices_ren, put renew_FOM_cost2_vec(devices_ren),',');    put /;
                 put 'Input FOM cost ($), ',                     loop(devices, put input_FOM_cost2_vec(devices),',');            put /;
                 put 'Output FOM cost ($), ',                    loop(devices, put output_FOM_cost2_vec(devices),',');           put /;
                 put 'Renewable VOM cost ($), ',                 loop(devices_ren, put renew_VOM_cost2_vec(devices_ren),',');    put /;
                 put 'Input VOM cost ($), ',                     input_VOM_cost2/;
                 put 'Output VOM cost ($), ',                    output_VOM_cost2/;
                 put 'Renewable sales ($), ',                    loop(devices_ren, put renewable_sales_vec(devices_ren),',');    put /;
                 put 'Renewable Penetration net meter (%), ',    Renewable_pen_input_net /;
                 put 'Curtailment (MWh), ',                      curtailment_sum /;
                 put 'Storage revenue ($), ',                    loop(devices, put Storage_revenue_vec(devices),',');            put /;
                 put 'Renewable only revenue ($), ',             Renewable_only_revenue /;
                 put 'Renewable max revenue ($), ',              Renewable_max_revenue /;
                 put 'Renewable Electricity Input (MWh), ',      Renewable_electricity_in /;
                 put 'Input Electricity Import (MWh), ',         loop(devices, put Input_elec_import_vec(devices),',');         put /;
                 put 'Integer device adjustment, ',              loop(devices, put CF_adjust.l(devices),',');                   put /;
                 put /;
*$offtext

         if (next_interval>1,
                 RT_out_file.nd = 4;
                 put RT_out_file;
                       put 'Interval, Electrolyzer Setpoint (MW)' /;
                       loop(next_int, put  next_interval,',',
                                           sum(devices, input_power_MW.l(next_int,devices)) /;
                       );
         );

else
*         put input_echo_file;
*                 put 'Error--solution not found.';
*         put results_file;
*                 put 'Error--solution not found.';
         put summary_file;
                 put 'Error--solution not found.';
*         put RT_out_file;
*                 put 'Error--soultion not found.';
);
