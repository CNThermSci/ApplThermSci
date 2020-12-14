PREF=B0101-pt
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
		www/1024px-J85_ge_17a_turbojet_engine.jpg \
		www/GE_H_series_Gas_Turbine.jpg \
		www/413492.jpg \
		www/5883675.jpg \
		fig/basic_engine.pdf \
		fig/basic_engine_simp_1.pdf \
		fig/basic_engine_simp_2.pdf \
		fig/basic_engine_simp_3.pdf \
		root/00-res/logo/CNThermSci-logo-A.pdf
	pdflatex --enable-write18 ${PRES}.tex
	pdflatex --enable-write18 ${PRES}.tex

${HOUT}.pdf: ${HOUT}.tex ${PREF}.tex bibfile.bib \
		www/1024px-J85_ge_17a_turbojet_engine.jpg \
		www/GE_H_series_Gas_Turbine.jpg \
		www/413492.jpg \
		www/5883675.jpg \
		fig/basic_engine.pdf \
		fig/basic_engine_simp_1.pdf \
		fig/basic_engine_simp_2.pdf \
		fig/basic_engine_simp_3.pdf \
		root/00-res/logo/CNThermSci-logo-W.pdf
	pdflatex --enable-write18 ${HOUT}.tex
	pdflatex --enable-write18 ${HOUT}.tex


