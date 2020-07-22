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
		root/00-res/logo/CNThermSci-logo-A.pdf
	pdflatex --enable-write18 ${PRES}.tex
	pdflatex --enable-write18 ${PRES}.tex

${HOUT}.pdf: ${HOUT}.tex ${PREF}.tex bibfile.bib \
		fig/P-V_diagram_deviations_to_Otto_cycle.pdf \
		root/00-res/logo/CNThermSci-logo-A.pdf
	pdflatex --enable-write18 ${HOUT}.tex
	pdflatex --enable-write18 ${HOUT}.tex


