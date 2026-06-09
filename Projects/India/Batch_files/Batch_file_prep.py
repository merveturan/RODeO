# -*- coding: utf-8 -*-
"""
Created on Thu Dec  9 19:08:49 2021
Modified on Mon Jul 17 17:04:37 2023

@author: aschleif and molmezt
"""

#%%
# Import packages
import pandas as pd

#%%
# Set constant parameters
#input_efficiency_inst = 0.87 # Battery input efficiency 
#output_efficiency_inst = 0.87 # Battery output efficiency 
#max_output_cap_inst = 1 # Interconnection capacity 
#max_input_cap_inst = 1 # Interconnection capacity 
#input_cap_instance = 1 # Battery capacity
#output_cap_instance = 1 # Battery capacity
#allow_import_instance = 1 # 1 if grid charging allowed, 0 if not
#Renewable_MW_instance = 0
#ren_prof_instance = 'renewable_profiles_hourly'

# Set path and file names
csv_path = r'C:\Users\molmezt\Desktop\RODeO_2\Projects\India\Batch_files\batch_file.csv'
scen_csv_file = pd.read_csv(csv_path, index_col=0)

# Fill missing scenario column values from the Default column
scenario_cols = [col for col in scen_csv_file.columns
                 if col != 'Default' and not str(col).startswith('Unnamed')]
for col in scenario_cols:
    scen_csv_file[col] = scen_csv_file[col].fillna(scen_csv_file['Default'])
batch_name='Scen_ancilary'

#%%
# Write batch file
mybat_dir= r'C:\Users\molmezt\Desktop\RODeO_2\Projects\India\Batch_files\{}.bat'.format(batch_name)

myBat = open(mybat_dir,'w+')
outdir = r'C:\Users\molmezt\Desktop\RODeO_2\Projects\India\Output\{}'.format(batch_name)
myBat.write('if not exist "{}" mkdir "{}"\n'.format(outdir, outdir))
for scen in scen_csv_file.columns.to_list()[1:]:
    scen_line=scen_csv_file[scen]
    license_param = '' if pd.isna(scen_line['license_parameter']) else scen_line['license_parameter']
    text_out = '{} {} {}'.format(scen_line['GAMS'],scen_line['Model_name'], license_param)
    text_out += ' logOption=4 logFile=gamslog_{}.txt  o={}/{}.lst '.format(scen_line['file_name_instance'], scen_line['outdir'], scen_line['file_name_instance'])
    text_out += ' --file_name_instance={}'.format(scen_line['file_name_instance'])
    text_out += ' --indir={}'.format( scen_line['indir'] )
    text_out += ' --outdir={}/{}'.format( scen_line['outdir'],batch_name )
    text_out += ' --int_length_instance={}'.format( scen_line['int_length_instance'])
    text_out += ' --elec_rate_instance={}'.format( scen_line['elec_rate_instance'] )
    text_out += ' --ren_prof_instance={}'.format( scen_line['ren_prof_instance'])
    text_out += ' --energy_purchase_price_inst={}'.format( scen_line['energy_purchase_price_inst'] )
    text_out += ' --energy_sale_price_inst={}'.format( scen_line['energy_sale_price_inst'] )
    text_out += ' --energy_purchase_price_rt_inst={}'.format( scen_line['energy_purchase_price_rt_inst'] )
    text_out += ' --energy_sale_price_RT_inst={}'.format( scen_line['energy_sale_price_RT_inst'] )
    text_out += ' --input_cap_instance={}'.format( scen_line['input_cap_instance'] )
    text_out += ' --output_cap_instance={}'.format( scen_line['output_cap_instance'] )
    text_out += ' --max_output_cap_inst={}'.format( scen_line['max_output_cap_inst'] )
    text_out += ' --max_input_cap_inst={}'.format( scen_line['max_input_cap_inst'] )
    text_out += ' --allow_import_instance={}'.format( scen_line['allow_import_instance'] )
    text_out += ' --input_efficiency_inst={}'.format( scen_line['input_efficiency_inst'] )
    text_out += ' --output_efficiency_inst={}'.format( scen_line['output_efficiency_inst'] )
    text_out += ' --Renewable_MW_instance={}'.format( scen_line['Renewable_MW_instance'])
    text_out += ' --storage_cap_instance={}'.format( scen_line['storage_cap_instance'] )
    text_out += ' --op_length_instance={}'.format( scen_line['op_length_instance'] )
    text_out += ' --op_period_instance={}'.format( scen_line['op_period_instance'] )
    text_out += ' --renew_cap_cost_inst={}'.format( scen_line['renew_cap_cost_inst'] )
    text_out += ' --input_cap_cost_inst={}'.format( scen_line['input_cap_cost_inst'] )
    text_out += ' --renew_FOM_cost_inst={}'.format( scen_line['renew_FOM_cost_inst'] )
    text_out += ' --input_FOM_cost_inst={}'.format( scen_line['input_FOM_cost_inst'] )
    text_out += ' --Sw_cycle_limit_both={}'.format( scen_line['Sw_cycle_limit_both'] )
    text_out += ' --Sw_daily_cycle_limit={}'.format( scen_line['Sw_daily_cycle_limit'] )
    text_out += ' --cftr_instance={}'.format( scen_line['cftr_instance'] )
    text_out += ' --Sw_cooldown={}'.format( scen_line['Sw_cooldown'] )
    text_out += ' --Sw_cooldown_numcycle={}'.format( scen_line['Sw_cooldown_numcycle'] )
    text_out += ' --Sw_cooldown_len={}'.format( scen_line['Sw_cooldown_len'] )
    text_out += ' --Sw_share_energy={}'.format( scen_line['Sw_share_energy'] )
    text_out += ' --Sw_least_time_interval={}'.format( scen_line['Sw_least_time_interval'] )
    text_out += '\n'
    myBat.write(text_out)
    del text_out
myBat.write('\n')
myBat.close()

#%%
# Write PowerShell timing script
myps1_dir = r'C:\Users\molmezt\Desktop\RODeO_2\Projects\India\Batch_files\{}.ps1'.format(batch_name)
solve_times_csv = r'Projects/India/Output/{}/solve_times.csv'.format(batch_name)
myPS1 = open(myps1_dir, 'w+')
myPS1.write('$log = @()\n\n')
for scen in scen_csv_file.columns.to_list()[1:]:
    scen_line = scen_csv_file[scen]
    license_param = '' if pd.isna(scen_line['license_parameter']) else scen_line['license_parameter']
    gams_cmd = '{} {} {}'.format(scen_line['GAMS'], scen_line['Model_name'], license_param)
    gams_cmd += ' logOption=4 logFile=gamslog_{}.txt  o={}/{}.lst '.format(scen_line['file_name_instance'], scen_line['outdir'], scen_line['file_name_instance'])
    gams_cmd += ' --file_name_instance={}'.format(scen_line['file_name_instance'])
    gams_cmd += ' --indir={}'.format(scen_line['indir'])
    gams_cmd += ' --outdir={}/{}'.format(scen_line['outdir'], batch_name)
    gams_cmd += ' --int_length_instance={}'.format(scen_line['int_length_instance'])
    gams_cmd += ' --elec_rate_instance={}'.format(scen_line['elec_rate_instance'])
    gams_cmd += ' --ren_prof_instance={}'.format(scen_line['ren_prof_instance'])
    gams_cmd += ' --energy_purchase_price_inst={}'.format(scen_line['energy_purchase_price_inst'])
    gams_cmd += ' --energy_sale_price_inst={}'.format(scen_line['energy_sale_price_inst'])
    gams_cmd += ' --energy_purchase_price_rt_inst={}'.format(scen_line['energy_purchase_price_rt_inst'])
    gams_cmd += ' --energy_sale_price_RT_inst={}'.format(scen_line['energy_sale_price_RT_inst'])
    gams_cmd += ' --input_cap_instance={}'.format(scen_line['input_cap_instance'])
    gams_cmd += ' --output_cap_instance={}'.format(scen_line['output_cap_instance'])
    gams_cmd += ' --max_output_cap_inst={}'.format(scen_line['max_output_cap_inst'])
    gams_cmd += ' --max_input_cap_inst={}'.format(scen_line['max_input_cap_inst'])
    gams_cmd += ' --allow_import_instance={}'.format(scen_line['allow_import_instance'])
    gams_cmd += ' --input_efficiency_inst={}'.format(scen_line['input_efficiency_inst'])
    gams_cmd += ' --output_efficiency_inst={}'.format(scen_line['output_efficiency_inst'])
    gams_cmd += ' --Renewable_MW_instance={}'.format(scen_line['Renewable_MW_instance'])
    gams_cmd += ' --storage_cap_instance={}'.format(scen_line['storage_cap_instance'])
    gams_cmd += ' --op_length_instance={}'.format(scen_line['op_length_instance'])
    gams_cmd += ' --op_period_instance={}'.format(scen_line['op_period_instance'])
    gams_cmd += ' --renew_cap_cost_inst={}'.format(scen_line['renew_cap_cost_inst'])
    gams_cmd += ' --input_cap_cost_inst={}'.format(scen_line['input_cap_cost_inst'])
    gams_cmd += ' --renew_FOM_cost_inst={}'.format(scen_line['renew_FOM_cost_inst'])
    gams_cmd += ' --input_FOM_cost_inst={}'.format(scen_line['input_FOM_cost_inst'])
    gams_cmd += ' --Sw_cycle_limit_both={}'.format(scen_line['Sw_cycle_limit_both'])
    gams_cmd += ' --Sw_daily_cycle_limit={}'.format(scen_line['Sw_daily_cycle_limit'])
    gams_cmd += ' --cftr_instance={}'.format(scen_line['cftr_instance'])
    gams_cmd += ' --Sw_cooldown={}'.format(scen_line['Sw_cooldown'])
    gams_cmd += ' --Sw_cooldown_numcycle={}'.format(scen_line['Sw_cooldown_numcycle'])
    gams_cmd += ' --Sw_cooldown_len={}'.format(scen_line['Sw_cooldown_len'])
    gams_cmd += ' --Sw_share_energy={}'.format(scen_line['Sw_share_energy'])
    gams_cmd += ' --Sw_least_time_interval={}'.format(scen_line['Sw_least_time_interval'])
    myPS1.write('Write-Host "Running {}..."\n'.format(scen_line['file_name_instance']))
    myPS1.write('$t = Measure-Command {{ cmd /c "{}" }}\n'.format(gams_cmd))
    myPS1.write('$log += [PSCustomObject]@{{ Scenario="{}"; Minutes=[math]::Round($t.TotalMinutes,4); Seconds=[math]::Round($t.TotalSeconds,1) }}\n'.format(scen_line['file_name_instance']))
    myPS1.write('Write-Host "  -> finished in $([math]::Round($t.TotalMinutes,2)) min"\n\n')


myPS1.write(f'$outDir = "Projects/India/Output/{batch_name}"\n')
myPS1.write('if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }\n')

myPS1.write('$log | Export-Csv -Path "{}" -NoTypeInformation\n'.format(solve_times_csv))
myPS1.write('Write-Host "Solve times saved to {}"\n'.format(solve_times_csv))
myPS1.close()


# %%
