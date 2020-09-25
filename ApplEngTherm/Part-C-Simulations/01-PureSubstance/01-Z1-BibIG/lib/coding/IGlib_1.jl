### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ e6313090-f7c0-11ea-0f25-5128ff9de54b
md"# Extensão da Biblioteca de Gás Ideal"

# ╔═╡ e18c6af8-fec5-11ea-0e6b-b981e5eb3c85
module IGas
	include("IGlib_0.jl")
	# export PlutoUI, Formatting, DataFrames, BrowseTables
	# export IG
	# export stdGas
	# export 𝐑, 𝐌, 𝐏, 𝐓, 𝐯, cp, cv, γ, 𝐮, 𝐡, s°, 𝐬
	# export THERM, uType, hType
end

# ╔═╡ e4346b78-fec7-11ea-3041-ef62b1848d6b
IGas.𝐓

# ╔═╡ 7df3c0e0-fec7-11ea-135d-1d76890ccf84
# "𝐓" can be typed by \bfT<tab>
function IGas.𝐓(gas::IGas.IG, uVal::IGas.uType, molr=true; maxIt::Integer=0, epsU::Integer=4)
	# Auxiliary function of whether to break due to iterations
	breakIt(i) = maxIt > 0 ? i >= maxIt || i >= 1024 : false
	# Set functions 𝑓(x) and 𝑔(x) ≡ d𝑓/dx
	𝑓, 𝑔 = 𝐮, cv
	# Get u bounds as y and check
	TMin, TMax = Tmin(gas), Tmax(gas)
	uMin, uMax = 𝑓(gas, molr, T=TMin), 𝑓(gas, molr, T=TMax)
	if !(uMin <= uVal() <= uMax)
		throw(DomainError(uVal(), "out of bounds $(uMin) ⩽ u ⩽ $(uMax)."))
	end
	# Linear initial estimate and initializations
	r = (uVal() - uMin) / (uMax - uMin)
	T = [ TMin + r * (TMax - TMin) ] # Iterations are length(T)-1
	u = [ 𝑓(gas, molr, T=T[end]) ]
	why = :because
	# Main loop
	while true
		append!(T, T[end] + (uVal() - u[end]) / 𝑔(gas, molr, T=T[end]))
		append!(u, 𝑓(gas, molr, T=T[end]))
		if breakIt(length(T)-1)
			why = :it; break
		elseif abs(u[end] - uVal()) <= eps(uVal()) * epsU
			why = :Δu; break
		end
	end
	return (
		T[end], :why => why, :it => length(T)-1,
		:Δu => abs(u[end] - uVal()),
		:Ts => T, :us => u
	)
end

# ╔═╡ 675de6bc-fec8-11ea-1b59-e585e8cba51a
IGas.𝐓

# ╔═╡ Cell order:
# ╟─e6313090-f7c0-11ea-0f25-5128ff9de54b
# ╠═e18c6af8-fec5-11ea-0e6b-b981e5eb3c85
# ╠═e4346b78-fec7-11ea-3041-ef62b1848d6b
# ╠═7df3c0e0-fec7-11ea-135d-1d76890ccf84
# ╠═675de6bc-fec8-11ea-1b59-e585e8cba51a
