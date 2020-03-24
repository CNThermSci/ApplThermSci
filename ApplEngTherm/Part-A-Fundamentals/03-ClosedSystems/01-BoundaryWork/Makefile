PREF=A0301-pt

clean:
	rm ${PREF}.log
	rm ${PREF}.aux
	rm ${PREF}.blg
	rm ${PREF}.bbl

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

${PREF}.pdf: ${PREF}.tex bibfile.bib \
		../../../../00-res/logo/CNThermSci-logo-A.pdf \
		fig/A0301-pt-01-VPistCyl.pdf \
		fig/A0301-pt-02-HPistCylPlot.pdf
	pdflatex --enable-write18 ${PREF}.tex
	bibtex ${PREF}
	pdflatex --enable-write18 ${PREF}.tex
	pdflatex --enable-write18 ${PREF}.tex

