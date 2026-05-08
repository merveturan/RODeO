# -*- coding: utf-8 -*-
"""
Created on Thu Dec  9 19:08:49 2021
Modified on Mon Jul 17 17:04:37 2023

@author: aschleif and molmezt
"""

#%%
# Import packages
import os
import pandas as pd

#%%
# Set constant parameters
#input_efficiency_inst = 0.87 # Battery input efficiency 
#output_efficiency_inst = 0.87 # Battery output efficiency 
max_output_cap_inst = 1 # Interconnection capacity 
max_input_cap_inst = 1 # Interconnection capacity 
input_cap_instance = 1 # Battery capacity
output_cap_instance = 1 # Battery capacity
allow_import_instance = 1 # 1 if grid charging allowed, 0 if not
Renewable_MW_instance = 0
ren_prof_instance = 'renewable_profiles_hourly'

# Set path and file names 
nas01_path = '\\\\nrelnas01\\ReEDS\\Users\\aschleif\\_Price-taker_Analysis\\'

#%%
#ba_list = ['p{}'.format(i) for i in range(1, 135)]
ba_list = ['p10','p61']
year_list = [2026,2030,2040,2050]
#year_list = [2050]
battery_duration_list = [1,2,3,4,5,6,7,8,9,10,11,12]
input_efficiency_list = [0.592,0.671,0.742,0.806,0.866,0.922,0.825,0.837,0.849,0.86,0.872,0.883]

#scen_list = ["MidCaseTCExpire", "MidCase100by2035", "MidCase95by2050", "MidCase", "LowRECostTCExpire", "LowRECost", "LowNGPrice", "HighRECost", "HighNGPrice", "Electrification"]
scen_list = ["MidCase"]

#%%
# Write batch file
for scen in scen_list:
    mybat_dir= r'D:\merve\RODeO\Projects\Solar+Storage\Batch_files\Cambium_analysis_{}.bat'.format(scen)
    myBat = open(mybat_dir,'w+')
    for ba in ba_list:
        for year in year_list:
            for bat_dur in battery_duration_list:
                for input_efficiency_inst in input_efficiency_list:
                    output_efficiency_inst=input_efficiency_inst
#               print( '{}_{}_{}h'.format(ba, year, bat_dur) )
                    print('{}_{}_{}_{}h'.format(scen,ba, year, bat_dur) )
#               print('\n')
                    file_name_instance = '{}_{}_{}_{}h_{}eff'.format(scen , ba, year, bat_dur,round(output_efficiency_inst*input_efficiency_inst,2)) 
                    out_directory = '{}_{}'.format( scen, year )
                    energy_purchase_price_inst = 'Cambium22_{}_hourly_{}_{}_energy_purchase_prices'.format(scen,ba, year)
                    energy_sale_price_inst = 'Cambium22_{}_hourly_{}_{}_energy_sale_prices'.format(scen,ba, year)

                    text_out = '"C:\GAMS\{}\gams.exe" Storage_dispatch_v22_1 license=C:\GAMS\{}\gamslice.txt'.format( 34, 34 ) # 24.7
                    text_out += ' --file_name_instance={}'.format( file_name_instance )
                    text_out += ' --ren_prof_instance={}'.format( ren_prof_instance )
                    text_out += ' --energy_purchase_price_inst={}'.format( energy_purchase_price_inst )
                    text_out += ' --energy_sale_price_inst={}'.format( energy_sale_price_inst )
                    text_out += ' --outdir="Projects\Solar+Storage\Output\Eff_Sens\{}"'.format( out_directory )
                    text_out += ' --input_cap_instance={}'.format( input_cap_instance )
                    text_out += ' --output_cap_instance={}'.format( output_cap_instance )
                    text_out += ' --max_output_cap_inst={}'.format( max_output_cap_inst )
                    text_out += ' --max_input_cap_inst={}'.format( max_input_cap_inst )
                    text_out += ' --allow_import_instance={}'.format( allow_import_instance )
                    text_out += ' --input_efficiency_inst={}'.format( input_efficiency_inst )
                    text_out += ' --output_efficiency_inst={}'.format( output_efficiency_inst )
                    text_out += ' --Renewable_MW_instance={}'.format( Renewable_MW_instance )
                    text_out += ' --storage_cap_instance={}'.format( bat_dur )
                    text_out += '\n'
                    myBat.write(text_out)
                    del text_out
myBat.write('\n')

myBat.close()
#%%
#%%
# Write batch file
missing_csv=pd.read_csv(r'')
mybat_dir= r'D:\merve\RODeO\Projects\Solar+Storage\Batch_files\Cambium_analysis_{}.bat'.format(scen)
myBat = open(mybat_dir,'w+')
for i in len(missing_csv)
    scen=misssing_csv['scen'][i]
    year=misssing_csv['year'][i]
    bat_dur=misssing_csv['duration(h)'][i]
    ba=misssing_csv['region'][i]
#    print( '{}_{}_{}h'.format(ba, year, bat_dur) )
    print('{}_{}_{}_{}h'.format(scen,ba, year, bat_dur) )
#               print('\n')
    file_name_instance = '{}_{}_{}_{}h'.format(scen , ba, year, bat_dur) 
    out_directory = '{}_{}'.format( scen, year )
    energy_purchase_price_inst = 'Cambium22_{}_hourly_{}_{}_energy_purchase_prices'.format(scen,ba, year)
    energy_sale_price_inst = 'Cambium22_{}_hourly_{}_{}_energy_sale_prices'.format(scen,ba, year)
    text_out = '"C:\GAMS\{}\gams.exe" Storage_dispatch_v22_1 license=C:\GAMS\{}\gamslice.txt'.format( 34, 34 ) # 24.7
    text_out += ' --file_name_instance={}'.format( file_name_instance )
    text_out += ' --ren_prof_instance={}'.format( ren_prof_instance )
    text_out += ' --energy_purchase_price_inst={}'.format( energy_purchase_price_inst )
    text_out += ' --energy_sale_price_inst={}'.format( energy_sale_price_inst )
    text_out += ' --outdir="Projects\Solar+Storage\Output\{}"'.format( out_directory )
    text_out += ' --input_cap_instance={}'.format( input_cap_instance )
    text_out += ' --output_cap_instance={}'.format( output_cap_instance )
    text_out += ' --max_output_cap_inst={}'.format( max_output_cap_inst )
    text_out += ' --max_input_cap_inst={}'.format( max_input_cap_inst )
    text_out += ' --allow_import_instance={}'.format( allow_import_instance )
    text_out += ' --input_efficiency_inst={}'.format( input_efficiency_inst )
    text_out += ' --output_efficiency_inst={}'.format( output_efficiency_inst )
    text_out += ' --Renewable_MW_instance={}'.format( Renewable_MW_instance )
    text_out += ' --storage_cap_instance={}'.format( bat_dur )
    text_out += '\n'
    myBat.write(text_out)
    del text_out
myBat.write('\n')

myBat.close()
