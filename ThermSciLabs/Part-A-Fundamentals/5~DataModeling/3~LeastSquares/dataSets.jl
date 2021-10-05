module dataSets

using Random

__X = [(0.5:0.0625:2.0)...]

LIN = 1.0:0.125:2.0
QUA = LIN / sqrt(max(__X...))
CUB = QUA / sqrt(max(__X...))
NXP = LIN * max(__X...)
EXP = LIN / sqrt(exp(max(__X...)))
INV = LIN * sqrt(min(__X...))
INS = INV * sqrt(min(__X...))
SIN = LIN / sqrt(max(__X...))

function newSet(;
                _lin=true,
                _qua=false,
                _cub=false,
                _nxp=false,
                _exp=false,
                _inv=false,
                _ins=false,
                _sin=false)
    COE = [
        _lin ? rand(LIN) : 0.0,
        _qua ? rand(QUA) : 0.0,
        _cub ? rand(CUB) : 0.0,
        _nxp ? rand(NXP) : 0.0,
        _exp ? rand(EXP) : 0.0,
        _inv ? rand(INV) : 0.0,
        _ins ? rand(INS) : 0.0,
        _sin ? rand(SIN) : 0.0
       ]
    __F = hcat(
        map(x->x,         __X),
        map(x->x^2,       __X),
        map(x->x^3,       __X),
        map(x->exp(-2x),  __X),
        map(x->exp(+2x),  __X),
        map(x->inv(x),    __X),
        map(x->inv(x)^2,  __X),
        map(x->sin(2π*x), __X),
    )
    RND = 0.125 * rand(length(__X))
    __Y = __F * COE + RND
    return (__X, __Y)
end

export newSet

end # module
