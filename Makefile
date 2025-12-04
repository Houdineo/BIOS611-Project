.PHONY: clean

clean:
	rm -rf figures
	mkdir -p figures
	rm -f report.pdf

.PHONY: dir

dir:
	mkdir -p figures

# data: cleaned RDS

data/air_clean.rds: scripts/01_clean_air.R data/Air_Quality.csv
	Rscript scripts/01_clean_air.R
	
# figures

figures/fig1_no2_periods.png: scripts/02_fig1_no2_periods.R data/air_clean.rds | dir
	Rscript scripts/02_fig1_no2_periods.R

figures/fig2_summer_ozone.png: scripts/03_fig2_summer_ozone.R data/air_clean.rds | dir
	Rscript scripts/03_fig2_summer_ozone.R

figures/fig3a_pm25_top10.png figures/fig3b_pm25_bottom10.png: scripts/04_fig3_pm25_top_bottom.R data/air_clean.rds | dir
	Rscript scripts/04_fig3_pm25_top_bottom.R

figures/fig4_pollutant_corr.png: scripts/05_fig4_corr_heatmap.R data/air_clean.rds | dir
	Rscript scripts/05_fig4_corr_heatmap.R

figures/fig5_cluster_scatter.png: scripts/06_fig5_cluster_scatter.R data/air_clean.rds | dir
	Rscript scripts/06_fig5_cluster_scatter.R

figures/fig6_cluster_map.png: scripts/07_fig6_cluster_map.R data/air_clean.rds geography/CD.geojson | dir
	Rscript scripts/07_fig6_cluster_map.R

report.pdf: report.Rmd \
            figures/fig1_no2_periods.png \
            figures/fig2_summer_ozone.png \
            figures/fig3a_pm25_top10.png \
            figures/fig3b_pm25_bottom10.png \
            figures/fig4_pollutant_corr.png \
            figures/fig5_cluster_scatter.png \
            figures/fig6_cluster_map.png
	Rscript -e "rmarkdown::render('report.Rmd', output_format = 'pdf_document')"
