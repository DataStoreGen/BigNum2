type BigNum = {number}
local BigNum = {}

function BigNum.new(man: number, exp: number): BigNum
	while math.abs(man) >= 10 do
		man/=10
		exp+=1
	end
	while math.abs(man) < 1 and man ~= 0 do
		man*=10
		exp-=1
	end
	return {man, math.floor(exp)}
end

function BigNum.fromNumber(value: number): BigNum
	local exp = math.log10(value)
	return {value/10^exp, exp}
end

function BigNum.fromString(value: string): BigNum
	local num = tonumber(value)
	if num then
		local exp = math.floor(math.log10(num))
		local man = num/(10^exp)
		return {man, exp}
	else
		local man, exp = string.match(value, '([-+%d%.]+)[eE]([-+]?%d+)')
		if man and exp then
			man, exp = tonumber(man), tonumber(exp)
			return {man, exp}
		end
	end
	warn('Failed to find e or convert "" into BigNum')
	return {0, 0}
end

function BigNum.convert(value): BigNum
	if type(value) == 'string' then
		local man, exp = string.match(value, '([-+%d%.]+)[eE]([-+]?%d+)')
		if man and exp then
			man, exp = tonumber(man), tonumber(exp)
			return {man, exp}
		end
		warn('Failed to find e or convert "" into BigNum')
		return {0, 0}
	elseif type(value) == 'number' then
		local exp = math.floor(math.log10(value))
		local man = value/10^exp
		return {man, exp}
	elseif type(value) == 'table' then
		return {value[1], value[2]}
	end
	warn('Failed to convert to BigNum')
	return {0, 0}
end

function BigNum.floor(val1): BigNum
	val1 = BigNum.convert(val1)
	local man, exp = val1[1], val1[2]
	if man == math.floor(man) then return BigNum.new(man, exp) end
	man = math.floor(man)
	return BigNum.new(man, exp)
end

function BigNum.fdiv(val1, val2)
	return BigNum.floor(BigNum.div(val1, val2))
end

function BigNum.toString(value: BigNum): string
	return value[1] .. 'e' .. value[2]
end

function BigNum.add(val1, val2): BigNum
	val1, val2 = BigNum.convert(val1), BigNum.convert(val2)
	local man1, exp1 = val1[1], val1[2]
	local man2, exp2 = val2[1], val2[2]
	local diff = exp1-exp2
	if math.abs(diff) > 15 then
		return diff > 0 and {man1, exp1} or {man2, exp2}
	end
	if diff > 0 then
		man2 = man2/(10^diff)
		exp2 = exp1
	elseif diff < 0 then
		man1 = man1/(10^-diff)
		exp1 = exp2
	end
	local man, exp = man1+man2, exp1
	return BigNum.new(man ,exp)
end

function BigNum.sub(val1, val2): BigNum
	val1, val2 = BigNum.convert(val1), BigNum.convert(val2)
	local man1, exp1 = val1[1], val1[2]
	local man2, exp2 = val2[1], val2[2]
	local diff = exp1-exp2
	if math.abs(diff) > 15 then
		return diff > 0 and {man1, exp1} or {man2, exp2}
	end
	if diff > 0 then
		man2 = man2/(10^diff)
		exp2 = exp1
	elseif diff < 0 then
		man1 = man1/(10^-diff)
		exp1 = exp2
	end
	local man, exp = man1-man2, exp1
	if man < 0 then return {0, 0} end
	return BigNum.new(man ,exp)
end

function BigNum.div(val1, val2): BigNum
	val1, val2 = BigNum.convert(val1), BigNum.convert(val2)
	local man1, exp1 = val1[1], val1[2]
	local man2, exp2 = val2[1], val2[2]
	local man, exp = man1/man2, exp1-exp2
	return BigNum.new(man, exp)
end

function BigNum.mul(val1, val2): BigNum
	val1, val2 = BigNum.convert(val1), BigNum.convert(val2)
	local man1, exp1 = val1[1], val1[2]
	local man2, exp2 = val2[1], val2[2]
	local diff = exp1-exp2
	if math.abs(diff) > 15 then
		return diff > 0 and {man1, exp1} or {man2, exp2}
	end
	if diff > 0 then
		man2 = man2/(10^diff)
		exp2 = exp1
	elseif diff < 0 then
		man1 = man1/(10^-diff)
		exp1 = exp2
	end
	local man, exp = man1*man2, exp1+exp2
	return BigNum.new(man ,exp)
end

function BigNum.pow(val1, val2): BigNum
	val1, val2 = BigNum.convert(val1), BigNum.convert(val2)
	local lg10 = math.log10(val1[1]) + val1[2]
	local exponent = val2[1] * 10^val2[2]
	local rlog = lg10 * exponent
	local exp = math.floor(rlog)
	local man = 10 ^ (rlog - exp)
	return BigNum.new(man, exp)
end

function BigNum.log(val1, val2): BigNum
	val1, val2 = BigNum.convert(val1), BigNum.convert(val2)
	local man1, exp1 = val1[1], val1[2]
	local man2, exp2 = val2[1], val2[2]
	man1 = math.log10(man1) + exp1
	man2 = math.log10(man2) + exp2
	local man = man1/man2
	return BigNum.fromNumber(man)
end

function BigNum.log10(val): BigNum
	return BigNum.log(val, 10)
end

function BigNum.toNumber(val: BigNum): number
	val = BigNum.convert(val)
	return val[1]*10^val[2]
end

function BigNum.sqrt(val1): BigNum
	val1 = BigNum.convert(val1)
	local man1, exp1 = val1[1], val1[2]
	local exp = exp1/2
	local man = math.sqrt(man1)
	return BigNum.new(man, exp)
end

function BigNum.root(val1, val2)
	val1, val2 = BigNum.convert(val1), BigNum.convert(val2)
	local man1, exp1 = val1[1], val1[2]
	local man2, exp2 = val2[1], val2[2]
	local root = man2*10^exp2
	return BigNum.new(man1^(1/root), exp1/root)
end

function BigNum.mod(val1, val2): BigNum
	val1, val2 = BigNum.convert(val1), BigNum.convert(val2)
	local result = BigNum.sub(val1, BigNum.mul(val2, BigNum.fdiv(val1, val2)))
	if result[1] == 0 then return {0,0} end
	return BigNum.new(val1[1]%val2[1], 0)
end

local letterTable = {
	'','a', 'b', 'c' ,'d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'
}
function BigNum.letterShort(val, digits): string
	val = BigNum.convert(val)
	local man, exp = val[1], val[2]
	local group = math.floor(exp / 3)
	local letters = ""
	if group == 0 then
		letters = "a"
	else
		while group > 0 do
			local index = (group - 1) % 26 + 1
			letters = letterTable[index+1] .. letters
			group = math.floor((group - 1) / 26)
		end
	end
	local lf = math.fmod(exp, 3)
	return BigNum.showDigits(man * 10^lf, digits) .. letters
end

function BigNum.chechStatus(exp1, exp2, man1, man2)
	if exp1 > exp2 then
		man2 *= 10^(exp2-exp1)
		exp2 = exp1
	elseif exp2 > exp1 then
		man1 *= 10^(exp1-exp2)
		exp1 = exp2
	end
	return man1, man2
end

function BigNum.me(val1, val2): boolean
	val1, val2 = BigNum.convert(val1), BigNum.convert(val2)
	local man1, exp1 = val1[1], val1[2]
	local man2, exp2 = val2[1], val2[2]
	local m1, m2 = BigNum.chechStatus(exp1, exp2, man1, man2)
	return m1 > m2
end

function BigNum.le(val1, val2): boolean
	val1, val2 = BigNum.convert(val1), BigNum.convert(val2)
	local man1, exp1 = val1[1], val1[2]
	local man2, exp2 = val2[1], val2[2]
	local m1, m2 = BigNum.chechStatus(exp1, exp2, man1, man2)
	return m1 < m2
end

function BigNum.eq(val1, val2): boolean
	val1, val2 = BigNum.convert(val1), BigNum.convert(val2)
	local man1, exp1 = val1[1], val1[2]
	local man2, exp2 = val2[1], val2[2]
	local m1, m2 = BigNum.chechStatus(exp1, exp2, man1, man2)
	return m1 == m2
end

function BigNum.meeq(val1, val2): boolean
	val1, val2 = BigNum.convert(val1), BigNum.convert(val2)
	local man1, exp1 = val1[1], val1[2]
	local man2, exp2 = val2[1], val2[2]
	local m1, m2 = BigNum.chechStatus(exp1, exp2, man1, man2)
	return m1 >= m2
end

function BigNum.leeq(val1, val2): boolean
	val1, val2 = BigNum.convert(val1), BigNum.convert(val2)
	local man1, exp1 = val1[1], val1[2]
	local man2, exp2 = val2[1], val2[2]
	local m1, m2 = BigNum.chechStatus(exp1, exp2, man1, man2)
	return m1 <= m2
end

function BigNum.between(val1, val2, val3): boolean
	return BigNum.me(val1, val2) or BigNum.le(val1, val3)
end

function BigNum.num(val: BigNum): number
	local man, exp = val[1], val[2]
	local res: string = man .. 'e' .. exp
	return tonumber(res):: number
end

function BigNum.showDigits(val, digits: number?): number
	digits = digits or 2
	return math.floor(val*10^digits) / 10^digits
end

function BigNum.short(val, digits, canComma: boolean?): string
	canComma = canComma or false
	val = BigNum.convert(val)
	local SNumber1: number, SNumber: number = val[1], val[2]
	local leftover = math.fmod(SNumber, 3)
	SNumber = math.floor(SNumber / 3)-1
	if SNumber <= -1 then return tostring(BigNum.showDigits(SNumber1 * (10^leftover), digits)) end	
	local FirBigNumOnes: {string} = {"", "U","D","T","Qd","Qn","Sx","Sp","Oc","No"}
	local SecondOnes: {string} = {"", "De","Vt","Tg","qg","Qg","sg","Sg","Og","Ng"}
	local ThirdOnes: {string} = {"", "Ce", "Du","Tr","Qa","Qi","Se","Si","Ot","Ni"}
	local MultOnes: {string} = {"", "Mi","Mc","Na","Pi","Fm","At","Zp","Yc", "Xo", "Ve", "Me", "Due", "Tre", "Te", "Pt", "He", "Hp", "Oct", "En", "Ic", "Mei", "Dui", "Tri", "Teti", "Pti", "Hei", "Hp", "Oci", "Eni", "Tra","TeC","MTc","DTc","TrTc","TeTc","PeTc","HTc","HpT","OcT","EnT","TetC","MTetc","DTetc","TrTetc","TeTetc","PeTetc","HTetc","HpTetc","OcTetc","EnTetc","PcT","MPcT","DPcT","TPCt","TePCt","PePCt","HePCt","HpPct","OcPct","EnPct","HCt","MHcT","DHcT","THCt","TeHCt","PeHCt","HeHCt","HpHct","OcHct","EnHct","HpCt","MHpcT","DHpcT","THpCt","TeHpCt","PeHpCt","HeHpCt","HpHpct","OcHpct","EnHpct","OCt","MOcT","DOcT","TOCt","TeOCt","PeOCt","HeOCt","HpOct","OcOct","EnOct","Ent","MEnT","DEnT","TEnt","TeEnt","PeEnt","HeEnt","HpEnt","OcEnt","EnEnt","Hect", "MeHect"}
	if canComma then
		if SNumber == 0 or SNumber == 1 then
			return BigNum.AddComma(val)
		elseif SNumber == 2 then
			return tostring(BigNum.showDigits(SNumber1 * (10^leftover), digits)) .. "b"
		end
	else
		if SNumber == 0 then
			return tostring(BigNum.showDigits(SNumber1 * (10^leftover), digits)) .. "k"
		elseif SNumber == 1 then 
			return tostring(BigNum.showDigits(SNumber1 * (10^leftover), digits)) .. "m"
		elseif SNumber == 2 then
			return tostring(BigNum.showDigits(SNumber1 * (10^leftover), digits)) .. "b"
		end
	end
	local txt: string = ""
	local function suffixpart(n: number)
		local Hundreds: number = math.floor(n/100)
		n = math.fmod(n, 100)
		local Tens: number = math.floor(n/10)
		n = math.fmod(n, 10)
		local Ones: number = math.floor(n/1)
		txt = txt .. FirBigNumOnes[Ones + 1]
		txt = txt .. SecondOnes[Tens + 1]
		txt = txt .. ThirdOnes[Hundreds + 1]
	end
	local function suffixpart2(n: number)
		if n > 0 then
			n = n + 1
		end
		if n > 1000 then
			n = math.fmod(n, 1000)
		end
		local Hundreds = math.floor(n/100)
		n = math.fmod(n, 100)
		local Tens = math.floor(n/10)
		n = math.fmod(n, 10)
		local Ones = math.floor(n/1)
		txt = txt .. FirBigNumOnes[Ones + 1]
		txt = txt .. SecondOnes[Tens + 1]
		txt = txt .. ThirdOnes[Hundreds + 1]
	end
	if SNumber < 1000 then
		suffixpart(SNumber)
		return tostring(BigNum.showDigits(SNumber1 * (10^leftover), digits)) .. txt
	end
	for i=#MultOnes,0,-1 do
		if SNumber >= 10^(i*3) then
			suffixpart2(math.floor(SNumber / 10^(i*3))- 1)
			txt = txt .. MultOnes[i+1]
			SNumber = math.fmod(SNumber, 10^(i*3))
		end
	end
	return tostring(BigNum.showDigits(SNumber1 * (10^leftover), digits)) .. txt
end

function BigNum.shortE(val, digits): string
	val = BigNum.convert(val)
	local first = {"", "U","D","T","Qd","Qn","Sx","Sp","Oc","No"}
	local second = {"", "De","Vt","Tg","qg","Qg","sg","Sg","Og","Ng"}
	local third = {'', 'Ce'}
	local function suffixPart(index)
		local hun = math.floor(index/100)
		index%=100
		local ten, one = math.floor(index/10), index%10
		return (first[one+1] or '') .. (second[ten+1] or '') .. (third[hun+1] or '')
	end
	local man, exp = val[1], val[2]
	local lf = math.fmod(math.floor(exp), 3)
	local index = 0
	while exp >= 1e3 do
		exp/=1e3
		index +=1
	end
	man = BigNum.showDigits(man*10^lf, digits)
	if index == 1 then
		return man .. 'e' .. exp .. 'k'
	elseif index == 2 then
		return man .. 'e' .. exp .. 'm'
	elseif index == 3 then
		return man .. 'e' .. exp .. 'b'
	end
	return man .. 'e' .. exp ..suffixPart(index)
end

function BigNum.HyperE(val): string
	val = BigNum.convert(val)
	local man, exp = val[1], val[2]
	if math.fmod(exp, 1000) then
		local newExp = math.floor(math.log10(exp))
		exp /=10^newExp
		return man .. 'e' .. exp .. 'e' .. newExp
	end
	return man ..'e' .. exp
end

function BigNum.AddComma(val): string
	val = BigNum.toNumber(BigNum.convert(val))
	local left, num, right = tostring(val):match('^([^%d]*%d)(%d*)(.-)$')
	num = num:reverse():gsub('(%d%d%d)', '%1,')
	return left .. num:reverse() .. right
end

function BigNum.fshort(val, digit, canComma: boolean?): string
	if BigNum.between(val, 0, 1) then
		return '1/' .. BigNum.short(BigNum.div(1, val), digit, canComma)
	end
	return BigNum.short(val, digit, canComma)
end

function BigNum.fshortE(val, digit): string
	if BigNum.between(val, 0, 1) then
		return '1/' .. BigNum.shortE(BigNum.div(1, val), digit)
	end
	return BigNum.shortE(val, digit)
end

function BigNum.fLetter(val, digit): string
	if BigNum.between(val, 0, 1) then
		return '1/' .. BigNum.letterShort(BigNum.div(1, val), digit)
	end
	return BigNum.letterShort(val, digit)
end

function BigNum.fHyperE(val): string
	if BigNum.between(val, 0, 1) then
		return '1/' .. BigNum.HyperE(BigNum.div(1, val))
	end
	return BigNum.HyperE(val)
end

function BigNum.TimeTracker(value): string
	local totalSeconds = math.floor(BigNum.toNumber(value))
	local weeks = math.floor(totalSeconds / 604800)
	local days = math.floor((totalSeconds % 6000) / 86400)
	local hours = math.floor(totalSeconds / 3600)
	local minutes = math.floor((totalSeconds % 3600) / 60)
	local seconds = totalSeconds % 60

	local result = {}
	if weeks > 0 then
		table.insert(result, string.format('%dw', weeks))
	end
	if days > 0 then
		table.insert(result, string.format('%dd', days))
	end
	if hours > 0 then
		table.insert(result, string.format('%dh', hours))
	end
	if minutes > 0 then
		table.insert(result, string.format('%dm', minutes))
	end
	if seconds > 0 or #result == 0 then
		table.insert(result, string.format('%ds', seconds))
	end
	return table.concat(result, ":")
end

function BigNum.roman(value): string
	local num = BigNum.toNumber(value)
	local res = ''
	local roman = {
		{1000, "M"}, {900, "CM"}, {500, "D"}, {400, "CD"},
		{100, "C"}, {90, "XC"}, {50, "L"}, {40, "XL"},
		{10, "X"}, {9, "IX"}, {5, "V"}, {4, "IV"},
		{1, "I"}
	}
	for _, pair in ipairs(roman) do
		while num >= pair[1] do
			res = res .. pair[2]
			num = num - pair[1]
		end
	end
	return res
end

function BigNum.Changed(value: Instance, changed: (property: string) -> ())
	value.Changed:Connect(changed)
end

function BigNum.pow10(val1): BigNum
	return BigNum.pow(val1, 10)
end

function BigNum.lbencode(val): number
	val = BigNum.convert(val)
	local a = BigNum.add({1, val[2]}, 1)
	if a[2] ~= a[2] then return 0 end 
	local exp = a[2]
	if exp > 1.7976931348623157e308 then
		exp = 1.7976931348623157e308
	end
	if a[1] == 0 or exp <= 0 then return 0 end
	return (math.log10(exp + 1) + 1) * 4503599627370496 * val[1]
end

function BigNum.lbdecode(val: number): BigNum
	if val == 0 then return {0,0} end
	local s = math.sign(val)
	val = math.abs(val)
	local toBig = {1, 10^(val/4503599627370496-1)-1}
	toBig = BigNum.sub(toBig, 1)
	toBig[2] = math.floor(toBig[2] * 100 + 0.001) / 100
	return {s, toBig[2]}
end

function BigNum.Combine(val, digit, canComma): string
	if BigNum.meeq(val, {1, 1e100}) then
		return BigNum.HyperE(val)
	elseif BigNum.meeq(val, {1, 1e10}) then
		return BigNum.shortE(val, digit)
	else return BigNum.short(val, digit, canComma)
	end
end

function BigNum.abs(val): BigNum
	val = BigNum.convert(val)
	local man, exp = val[1], val[2]
	if man < 0 then
		man=-man
	elseif exp < 0 then
		exp=-exp
	end
	return {man, exp}
end

function BigNum.buy1(cost, pow): BigNum
	return  BigNum.mul(cost, pow)
end

function BigNum.buy5(cost, pow): BigNum
	return BigNum.mul(cost, BigNum.pow(pow, 5))
end

function BigNum.buy10(cost, pow): BigNum
	return BigNum.mul(cost, BigNum.pow10(pow))
end

return BigNum
