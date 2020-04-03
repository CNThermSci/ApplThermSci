PREF=A0302-pt
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
		--file=$< \
		--export-pdf=$@

fig/%.pdf: fig/%.svg
	inkscape \
		--file=$< \
		--export-pdf=$@

${PRES}.pdf: ${PRES}.tex ${PREF}.tex bibfile.bib \
		root/00-res/logo/CNThermSci-logo-A.pdf \
		fig/A0301-pt-VPistCyl.pdf \
		fig/A0301-pt-HPistCyl.pdf \
		fig/A0301-pt-HPistCylForc.pdf \
		fig/A0301-pt-HPistCylPlot.pdf \
		fig/A0301-pt-HPistCylPlotInt.pdf \
		fig/A0301-pt-HPistCylPlotPath.pdf \
		fig/A0301-pt-HPistCylPlotCycle.pdf \
		fig/A0301-pt-HPistCylPlotCycle-00.pdf \
		fig/A0301-pt-HPistCylPlotCycle-01.pdf \
		fig/A0301-pt-HPistCylPlotCycle-02.pdf \
		fig/A0301-pt-HPistCylPlotCycle-03.pdf \
		fig/A0301-pt-HPistCylPlotCycle-04.pdf \
		fig/A0301-pt-HPistCylPlotCycle-05.pdf
	pdflatex --enable-write18 ${PRES}.tex
	pdflatex --enable-write18 ${PRES}.tex

${HOUT}.pdf: ${HOUT}.tex ${PREF}.tex bibfile.bib \
		root/00-res/logo/CNThermSci-logo-A.pdf \
		fig/A0301-pt-VPistCyl.pdf \
		fig/A0301-pt-HPistCyl.pdf \
		fig/A0301-pt-HPistCylForc.pdf \
		fig/A0301-pt-HPistCylPlot.pdf \
		fig/A0301-pt-HPistCylPlotInt.pdf \
		fig/A0301-pt-HPistCylPlotPath.pdf \
		fig/A0301-pt-HPistCylPlotCycle.pdf \
		fig/A0301-pt-HPistCylPlotCycle-00.pdf \
		fig/A0301-pt-HPistCylPlotCycle-01.pdf \
		fig/A0301-pt-HPistCylPlotCycle-02.pdf \
		fig/A0301-pt-HPistCylPlotCycle-03.pdf \
		fig/A0301-pt-HPistCylPlotCycle-04.pdf \
		fig/A0301-pt-HPistCylPlotCycle-05.pdf
	pdflatex --enable-write18 ${HOUT}.tex
	pdflatex --enable-write18 ${HOUT}.tex


