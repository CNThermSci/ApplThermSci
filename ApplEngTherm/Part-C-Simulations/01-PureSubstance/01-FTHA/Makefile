PREF=C0101-pt
PRES=${PREF}-PRES
HOUT=${PREF}-HOUT

clean:
	for TRG in ${PRES} ${HOUT}; do \
		for EXT in log aux blg bbl nav out snm toc; do \
			rm -vf $$TRG.$$EXT; \
		done; \
	done

wipe: clean
	rm -vf fig/*pdf

root/00-res/logo/%.pdf: root/00-res/logo/%.svg
	inkscape \
		--export-type=pdf \
		--export-filename=$@ \
		$<

fig/P-V_diagram_deviations_to_Otto_cycle.svg:
	wget \
		'https://upload.wikimedia.org/wikipedia/commons/6/6c/P-V_diagram_deviations_to_Otto_cycle.svg' \
		-O fig/P-V_diagram_deviations_to_Otto_cycle.svg

fig/%.pdf: fig/%.svg
	inkscape \
		--export-type=pdf \
		--export-filename=$@ \
		$<

${PRES}.pdf: ${PRES}.tex ${PREF}.tex bibfile.bib \
		fig/P-V_diagram_deviations_to_Otto_cycle.pdf \
		fig/FTHAEngine01.pdf \
		fig/FTHAEngine02.pdf \
		fig/FTHAEngine03.pdf \
		fig/FTHATiming01.pdf \
		fig/val_r=12,0_k=1,334.pdf \
		fig/test_r=12,0_speed.pdf \
		fig/test_r=12,0_speed-T.pdf \
		fig/test_r=12,0_speed-a.pdf \
		fig/test_r=12,0_speed-P.pdf \
		root/00-res/logo/CNThermSci-logo-A.pdf
	pdflatex --enable-write18 ${PRES}.tex
	#pdflatex --enable-write18 ${PRES}.tex

${HOUT}.pdf: ${HOUT}.tex ${PREF}.tex bibfile.bib \
		fig/P-V_diagram_deviations_to_Otto_cycle.pdf \
		fig/FTHAEngine01.pdf \
		fig/FTHAEngine02.pdf \
		fig/FTHAEngine03.pdf \
		fig/FTHATiming01.pdf \
		fig/val_r=12,0_k=1,334.pdf \
		fig/test_r=12,0_speed.pdf \
		fig/test_r=12,0_speed-T.pdf \
		fig/test_r=12,0_speed-a.pdf \
		fig/test_r=12,0_speed-P.pdf \
		root/00-res/logo/CNThermSci-logo-A.pdf
	pdflatex --enable-write18 ${HOUT}.tex
	#pdflatex --enable-write18 ${HOUT}.tex


