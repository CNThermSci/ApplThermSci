### A Pluto.jl notebook ###
# v0.11.12

using Markdown
using InteractiveUtils

# ╔═╡ 934ae304-f7ce-11ea-2b06-9b0f48cd9c22
using CSV

# ╔═╡ e6313090-f7c0-11ea-0f25-5128ff9de54b
md"# Biblioteca Simplificada de Gás Ideal

Biblioteca básica de gás ideal sob hipóteses:

- Substâncias puras;
- Função cp(T) polinomial cúbica;
- Função cp(T) válida para Tmin ⩽ T ⩽ Tmax;
- sref = s(Tref) conhecida.
"

# ╔═╡ 3cf7ab10-f7c2-11ea-0386-97c6d1f5ffc5
md"## Setup Mínimo"

# ╔═╡ 53ea6024-f7c2-11ea-2226-f9d22949c8b7
# Universal gas constant
R̄() = 8.314472 # ± 0.000015 # kJ/kmol⋅K

# ╔═╡ 815a5db4-f7c2-11ea-1747-e3f2eccdf1b2
# Standard Tref
Tref() = 298.15 # K

# ╔═╡ 8125f198-f7c2-11ea-14e4-7f873ab2c3f4
# IG (Ideal Gas) structure: values for each gas instance
struct IG
    MW                  # Molecular "Weight", kg/kmol
    CP::NTuple{4}       # Exactly 4 c̄p(T) coefficients
    Tmin                # T_min, K
    Tmax                # T_max, K
    sref                # s̄°ref, kJ/kmol·K
end

# ╔═╡ e66a728a-f7cd-11ea-1fe6-07c915fa1c9d
md"## Biblioteca Externa

Valores tabelados em Çengel, Y. A., Termodinâmica 7a Ed. ISBN 978-85-8055-200-3 (Tabelas A-1, A-2 e A-26), foram transportados para uma planilha (OpenOffice Spreadsheet) e exportados no formato CSV [Comma Separated Values], os quais podem ser lidos em Julia:
"

# ╔═╡ 034e8264-f7cf-11ea-2a5b-b13e84ce9026
gasRaw = CSV.File("IGTable.csv", normalizenames=true)

# ╔═╡ ad44f412-f7d2-11ea-0524-6f802013e302
function rowToIG(row)
	IG( row.MW, (row.cp_a, row.cp_b, row.cp_c, row.cp_d),
		row.Tmin, row.Tmax, row.sref)
end

# ╔═╡ 21eb877c-f7d1-11ea-241a-5b5b9166d851
gasLib = Dict(Symbol(r.Formula) => rowToIG(r) for r in gasRaw)

# ╔═╡ 21ba8f8c-f7d1-11ea-0419-4f1f17f1f76d
gasLib[:CH4]

# ╔═╡ 04402ca4-f7cf-11ea-02e7-2d95f990f682
md"## Funcionalidade da Biblioteca

Funções que calculam propriedades termodinâmicas dos gases."

# ╔═╡ 0411c8a0-f7cf-11ea-15ec-636d951c8e49
md"### Comportamento P-T-v"

# ╔═╡ 00e60032-f7d0-11ea-3784-cd9ef42ea3a6


# ╔═╡ 0190c5f8-f7d0-11ea-2f9c-f73bf010a371


# ╔═╡ Cell order:
# ╟─e6313090-f7c0-11ea-0f25-5128ff9de54b
# ╟─3cf7ab10-f7c2-11ea-0386-97c6d1f5ffc5
# ╠═53ea6024-f7c2-11ea-2226-f9d22949c8b7
# ╠═815a5db4-f7c2-11ea-1747-e3f2eccdf1b2
# ╠═8125f198-f7c2-11ea-14e4-7f873ab2c3f4
# ╟─e66a728a-f7cd-11ea-1fe6-07c915fa1c9d
# ╠═934ae304-f7ce-11ea-2b06-9b0f48cd9c22
# ╠═034e8264-f7cf-11ea-2a5b-b13e84ce9026
# ╠═ad44f412-f7d2-11ea-0524-6f802013e302
# ╠═21eb877c-f7d1-11ea-241a-5b5b9166d851
# ╠═21ba8f8c-f7d1-11ea-0419-4f1f17f1f76d
# ╟─04402ca4-f7cf-11ea-02e7-2d95f990f682
# ╟─0411c8a0-f7cf-11ea-15ec-636d951c8e49
# ╠═00e60032-f7d0-11ea-3784-cd9ef42ea3a6
# ╠═0190c5f8-f7d0-11ea-2f9c-f73bf010a371
