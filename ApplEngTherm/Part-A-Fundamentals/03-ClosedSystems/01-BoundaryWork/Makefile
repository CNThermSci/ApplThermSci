PREF=A0301-pt
PRES=${PREF}-PRES
HOUT=${PREF}-HOUT

clean:
	for TRG in ${PRES} ${HOUT}; do \
		for EXT in log aux blg bbl nav out snm toc; do \
			rm -vf $$TRG.$$EXT; \
		done; \
	done
	rm -vf fig/*pdf

root/00-res/logo/%.pdf: root/00-res/logo/%.svg
	inkscape \
		--file=root/00-res/logo/$< \
		--export-pdf=root/00-res/logo/$@

fig/%.pdf: fig/%.svg
	inkscape \
		--file=$< \
		--export-pdf=$@

${PRES}.pdf: ${PRES}.tex ${PREF}.tex bibfile.bib \
		root/00-res/logo/CNThermSci-logo-A.pdf \
		fig/A0301-pt-VPistCyl.pdf \
		fig/A0301-pt-HPistCyl.pdf \
		fig/A0301-pt-HPistCylForc.pdf \
		fig/A0301-pt-HPistCylPlot.pdf
	pdflatex --enable-write18 ${PRES}.tex
	pdflatex --enable-write18 ${PRES}.tex

${HOUT}.pdf: ${HOUT}.tex ${PREF}.tex bibfile.bib \
		root/00-res/logo/CNThermSci-logo-A.pdf \
		fig/A0301-pt-VPistCyl.pdf \
		fig/A0301-pt-HPistCyl.pdf \
		fig/A0301-pt-HPistCylForc.pdf \
		fig/A0301-pt-HPistCylPlot.pdf
	pdflatex --enable-write18 ${HOUT}.tex
	pdflatex --enable-write18 ${HOUT}.tex


