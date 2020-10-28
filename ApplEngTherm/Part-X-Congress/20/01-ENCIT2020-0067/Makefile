PREF=X2001-en
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

fig/%.pdf: fig/%.svg
	inkscape \
		--export-type=pdf \
		--export-filename=$@ \
		$<

Slide1.png: getMask1.sh
	getMask1.sh

Slide2.png: getMask2.sh
	getMask2.sh

${PRES}.pdf: ${PRES}.tex ${PREF}.tex bibfile.bib \
		fig/FIG_mechanism_rev05.pdf \
		fig/FIG_mechanism_rev06.pdf \
		fig/p_FBD.pdf \
		fig/r_FBD.pdf \
		fig/c_FBD.pdf \
		fig/fig-05.pdf \
		fig/fig-05a.pdf \
		fig/fig-05b.pdf \
		fig/fig-05c.pdf \
		fig/fig-05d.pdf \
		root/00-res/logo/CNThermSci-logo-A.pdf
	pdflatex --enable-write18 ${PRES}.tex
	#pdflatex --enable-write18 ${PRES}.tex

${HOUT}.pdf: ${HOUT}.tex ${PREF}.tex bibfile.bib \
		fig/FIG_mechanism_rev05.pdf \
		fig/FIG_mechanism_rev06.pdf \
		fig/p_FBD.pdf \
		fig/r_FBD.pdf \
		fig/c_FBD.pdf \
		fig/fig-05.pdf \
		fig/fig-05a.pdf \
		fig/fig-05b.pdf \
		fig/fig-05c.pdf \
		fig/fig-05d.pdf \
		root/00-res/logo/CNThermSci-logo-A.pdf
	pdflatex --enable-write18 ${HOUT}.tex
	#pdflatex --enable-write18 ${HOUT}.tex

${PRES}.png: ${PRES}.pdf
	mkdir -p ${PRES}.png
	cd ${PRES}.png; \
	pdftoppm -png -forcenum -r 200 "../${PRES}.pdf" "${PRES}"
	slides-merge.sh Slide1-Filled.png

