PREF=A0802-pt
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
		--output-document=$@ \
		--user-agent="Mozilla/5.0 (X11; Linux x86_64)"
	touch $@

www/%.jpeg: www/%.url
	wget \
		--input-file=$< \
		--output-document=$@ \
		--user-agent="Mozilla/5.0 (X11; Linux x86_64)"
	touch $@

www/%.png: www/%.url
	wget \
		--input-file=$< \
		--output-document=$@ \
		--user-agent="Mozilla/5.0 (X11; Linux x86_64)"
	touch $@

www/%.svg: www/%.url
	wget \
		--input-file=$< \
		--output-document=$@ \
		--user-agent="Mozilla/5.0 (X11; Linux x86_64)"
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

wwwEXT = jpg short
wwwFIG = 01-cold-dr-pepper \
		 02-cold-bottle \
		 03-LN2 \
		 04-windshield-ice \
		 05-clouds-rain \
		 06-snow-storm \
		 07-Sachseln-snow \
		 08-sling-psychrometer

${PRES}.pdf: ${PRES}.tex ${PREF}.tex bibfile.bib \
		fig/T-po-in-Ts-diag.pdf \
		fig/adiabatic-saturation-0.pdf \
		fig/adiabatic-saturation-1.pdf \
		fig/adiabatic-saturation-2.pdf \
		fig/adiabatic-saturation-3.pdf \
		$(foreach EXT,$(wwwEXT), \
			$(foreach BAS,$(wwwFIG),www/$(BAS).$(EXT))) \
		root/00-res/logo/CNThermSci-logo-A.pdf
	pdflatex --enable-write18 ${PRES}.tex
	bibtex ${PRES}
	pdflatex --enable-write18 ${PRES}.tex
	pdflatex --enable-write18 ${PRES}.tex

${HOUT}.pdf: ${HOUT}.tex ${PREF}.tex bibfile.bib \
		fig/T-po-in-Ts-diag.pdf \
		fig/adiabatic-saturation-0.pdf \
		fig/adiabatic-saturation-1.pdf \
		fig/adiabatic-saturation-2.pdf \
		fig/adiabatic-saturation-3.pdf \
		$(foreach EXT,$(wwwEXT), \
			$(foreach BAS,$(wwwFIG),www/$(BAS).$(EXT))) \
		root/00-res/logo/CNThermSci-logo-W.pdf
	pdflatex --enable-write18 ${HOUT}.tex
	bibtex ${HOUT}
	pdflatex --enable-write18 ${HOUT}.tex
	pdflatex --enable-write18 ${HOUT}.tex


