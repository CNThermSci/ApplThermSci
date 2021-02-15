PREF=D0101-pt
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
		--export-pdf-version=1.4 \
		--export-filename=$@ \
		$<

cc/%.pdf: cc/%.svg
	inkscape \
		--export-pdf-version=1.4 \
		--export-filename=$@ \
		$<

www/%.jpg: www/%.url
	wget \
		--input-file=$< \
		--output-document=$@
	touch $@

www/%.jpeg: www/%.url
	wget \
		--input-file=$< \
		--output-document=$@
	touch $@

www/%.png: www/%.url
	wget \
		--input-file=$< \
		--output-document=$@
	touch $@

www/%.svg: www/%.url
	wget \
		--input-file=$< \
		--output-document=$@
	touch $@

www/%.pdf: www/%.svg
	inkscape \
		--export-pdf-version=1.4 \
		--export-filename=$@ \
		$<

fig/%.pdf: fig/%.svg
	inkscape \
		--export-pdf-version=1.4 \
		--export-filename=$@ \
		$<

${PRES}.pdf: ${PRES}.tex ${PREF}.tex bibfile.bib \
		fig/01-SistemaRefrGen.pdf \
		fig/0002-Refr-Vap-ID.pdf \
		fig/0003-Comp+HX+Turb.pdf \
		www/airplane-01.jpg \
		www/airplane-02.jpg \
		www/airplane-03.jpg \
		www/airplane-04.jpg \
		www/ammonia-01.jpg \
		www/ammonia-02.jpg \
		fig/0004-Absorpt-Refr-H2O+NH3.pdf \
		fig/0005-Absorpt-Refr-BrLi+H2O.pdf \
		root/00-res/logo/CNThermSci-logo-A.pdf
	pdflatex --enable-write18 ${PRES}.tex
	bibtex ${PRES}
	pdflatex --enable-write18 ${PRES}.tex
	pdflatex --enable-write18 ${PRES}.tex

${HOUT}.pdf: ${HOUT}.tex ${PREF}.tex bibfile.bib \
		fig/01-SistemaRefrGen.pdf \
		fig/0002-Refr-Vap-ID.pdf \
		fig/0003-Comp+HX+Turb.pdf \
		www/airplane-01.jpg \
		www/airplane-02.jpg \
		www/airplane-03.jpg \
		www/airplane-04.jpg \
		www/ammonia-01.jpg \
		www/ammonia-02.jpg \
		fig/0004-Absorpt-Refr-H2O+NH3.pdf \
		fig/0005-Absorpt-Refr-BrLi+H2O.pdf \
		root/00-res/logo/CNThermSci-logo-W.pdf
	pdflatex --enable-write18 ${HOUT}.tex
	bibtex ${HOUT}
	pdflatex --enable-write18 ${HOUT}.tex
	pdflatex --enable-write18 ${HOUT}.tex


