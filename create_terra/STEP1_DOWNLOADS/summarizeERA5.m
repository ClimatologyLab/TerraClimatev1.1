function [] = summarizeERA5(year);

  new_file_path = '';

 step3_summarize_year_of_ERA5(year,new_file_path);
 step4_compute_monthly_values_for_year(year,new_file_path);

end
