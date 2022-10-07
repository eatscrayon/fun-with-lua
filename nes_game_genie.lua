local grimoire = {
	['A']=  0x0,['P']=  0x1,['Z']=  0x2,['L']=  0x3,['G']=  0x4,['I']=  0x5,['T']=  0x6,['Y']=  0x7,
	['E']=  0x8,['O']=  0x9,['X']=  0xA,['U']=  0xB,['K']=  0xC,['S']=  0xD,['V']=  0xE,['N']=  0xF,
	[0x0]=  'A',[0x1]=  'P',[0x2]=  'Z',[0x3]=  'L',[0x4]=  'G',[0x5]=  'I',[0x6]=  'T',[0x7]=  'Y',
	[0x8]=  'E',[0x9]=  'O',[0xA]=  'X',[0xB]=  'U',[0xC]=  'K',[0xD]=  'S',[0xE]=  'V',[0xF]=  'N',
}

local code_to_patch = function (inputcode)
    local hexcode = {}
    local out_patch_data = {["address"]= nil,["value"] = nil, ["compare"]= nil }

    if string.len(inputcode) == 6 then
        for index = 1, #inputcode do
            table.insert(hexcode,grimoire[string.char(inputcode:byte(index))])
        end
        local g_address = (0x8000 + ((hexcode[4] & 7) << 12) | ((hexcode[6] & 7) << 8) | ((hexcode[5] & 8) << 8) | ((hexcode[3] & 7) << 4) | ((hexcode[2] & 8) << 4) | (hexcode[5] & 7) | (hexcode[4] & 8))
        out_patch_data["address"] = g_address
        local g_value = ((hexcode[2] & 7) << 4) | ((hexcode[1] & 8) << 4) | (hexcode[1] & 7) | (hexcode[6] & 8)
        out_patch_data["value"] = g_value
        out_patch_data["starting_value"] = g_value

    elseif string.len(inputcode) == 8 then
        for index = 1, #inputcode do
            table.insert(hexcode,grimoire[string.char(inputcode:byte(index))])
        end
        local g_address = 0x8000 + ((hexcode[4] & 7) << 12) | ((hexcode[6] & 7) << 8) | ((hexcode[5] & 8) << 8) | ((hexcode[3] & 7) << 4) | ((hexcode[2] & 8) << 4) | (hexcode[5] & 7) | (hexcode[4] & 8)
        out_patch_data["address"] = g_address
        local g_value = ((hexcode[2] & 7) << 4) | ((hexcode[1] & 8) << 4) | (hexcode[1] & 7) | (hexcode[8] & 8)
        out_patch_data["value"] = g_value
        out_patch_data["starting_value"] = g_value
        local g_compare = ((hexcode[8] & 7) << 4) | ((hexcode[7] & 8) << 4) | (hexcode[7] & 7) | (hexcode[6] & 8)
        out_patch_data["compare"] = g_compare
        
    end
    return out_patch_data
end

local patch_to_code = function (in_patch_data)
    local tempcode = {}
    local out_code = ''
    if not in_patch_data["compare"] then

        local Xddd = (in_patch_data["address"]) >> 12
		local Efff = (in_patch_data["address"] & 3840) >> 8
		local Bccc = (in_patch_data["address"] & 240) >> 4
		local Deee = (in_patch_data["address"] & 15)
		local Abbb = (in_patch_data["value"] >> 4)
		local Faaa = (in_patch_data["value"] & 15)
        local  E = Efff & 8
		local  B = Bccc & 8
		local  D = Deee & 8
		local  A = Abbb & 8
		local  F = Faaa & 8
        local ddd = Xddd & 7
		local fff = Efff & 7
		local ccc = Bccc & 7
		local eee = Deee & 7
		local bbb = Abbb & 7
		local aaa = Faaa & 7
        table.insert(tempcode, A | aaa)
		table.insert(tempcode, B | bbb)
		table.insert(tempcode,     ccc)
		table.insert(tempcode, D | ddd)
		table.insert(tempcode, E | eee)
		table.insert(tempcode, F | fff)

    elseif in_patch_data["compare"] then
        local Xddd = (in_patch_data["address"]) >> 12
		local Efff = (in_patch_data["address"] & 3840) >> 8
		local Bccc = (in_patch_data["address"] & 240) >> 4
		local Deee = (in_patch_data["address"] & 15)
		local Ghhh = (in_patch_data["address"] >> 4)
		local Fggg = (in_patch_data["address"] & 15)
		local Abbb = (in_patch_data["value"] >> 4)
		local Haaa = (in_patch_data["value"] & 15)
		local E = Efff & 8
		local B = Bccc & 8
		local D = Deee & 8
		local G = Ghhh & 8
		local F = Fggg & 8
		local A = Abbb & 8
		local H = Haaa & 8
		local ddd = Xddd & 7
		local fff = Efff & 7
		local ccc = Bccc & 7
		local eee = Deee & 7
		local hhh = Ghhh & 7
		local ggg = Fggg & 7
		local bbb = Abbb & 7
		local aaa = Haaa & 7
		table.insert(tempcode, A | aaa)
		table.insert(tempcode, B | bbb)
		table.insert(tempcode,     ccc)
		table.insert(tempcode, D | ddd)
		table.insert(tempcode, E | eee)
		table.insert(tempcode, F | fff)
		table.insert(tempcode, G | ggg)
		table.insert(tempcode, H | hhh)
    end

    for _,v in ipairs(tempcode)do
        out_code = out_code .. grimoire[v]
    end
    return out_code
end

local code = string.upper(arg[1])
local code_minus_one = ''
local code_plus_one = ''
local patch_data = code_to_patch(code)


print("address: ",('%X'):format(patch_data["address"]))
print("value  : ",('%X'):format(patch_data["value"]))
print("compare: ",patch_data["compare"])


if patch_data["starting_value"] < 1 then
    code_minus_one = code
else 
    patch_data["value"] = patch_data["starting_value"]-1
    code_minus_one = patch_to_code(patch_data)
end


if patch_data["starting_value"] > 255 then
    code_plus_one = code
else 
    patch_data["value"] = patch_data["starting_value"]+1
    code_plus_one = patch_to_code(patch_data)
end

print("-1 : ",code_minus_one)
print(" 0 : ",code)
print("+1 : ",code_plus_one)
