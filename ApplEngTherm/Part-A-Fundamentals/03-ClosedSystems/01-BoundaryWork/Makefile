PREF=A0301-pt
PRES=${PREF}-PRES
HOUT=${PREF}-HOUT

clean:
	for TRG in ${PRES} ${HOUT}; do \
		for EXT in log aux blg bbl nav out snm toc; do \
			rm -vf $$TRG.$$EXT; \
		done; \
	done

root/00-res/logo/CNThermSci-logo-A.pdf: root/00-res/logo/CNThermSci-logo-A.svg
	inkscape \
		--file=root/00-res/logo/CNThermSci-logo-A.svg \
		--export-pdf=root/00-res/logo/CNThermSci-logo-A.pdf

fig/A0301-pt-01-VPistCyl.pdf: fig/A0301-pt-01-VPistCyl.svg
	inkscape \
		--file=fig/A0301-pt-01-VPistCyl.svg \
		--export-pdf=fig/A0301-pt-01-VPistCyl.pdf

fig/A0301-pt-02-HPistCylPlot.pdf: fig/A0301-pt-02-HPistCylPlot.svg
	inkscape \
		--file=fig/A0301-pt-02-HPistCylPlot.svg \
		--export-pdf=fig/A0301-pt-02-HPistCylPlot.pdf

${PRES}.pdf: ${PRES}.tex bibfile.bib \
		root/00-res/logo/CNThermSci-logo-A.pdf \
		fig/A0301-pt-01-VPistCyl.pdf \
		fig/A0301-pt-02-HPistCylPlot.pdf
	pdflatex --enable-write18 ${PRES}.tex
	bibtex ${PRES}
	pdflatex --enable-write18 ${PRES}.tex
	pdflatex --enable-write18 ${PRES}.tex

${HOUT}.pdf: ${HOUT}.tex bibfile.bib \
		../../../../00-res/logo/CNThermSci-logo-A.pdf \
		fig/A0301-pt-01-VPistCyl.pdf \
		fig/A0301-pt-02-HPistCylPlot.pdf
	pdflatex --enable-write18 ${HOUT}.tex
	bibtex ${HOUT}
	pdflatex --enable-write18 ${HOUT}.tex
	pdflatex --enable-write18 ${HOUT}.tex

