local function isObject(obj)
    return objinfo(obj, 0)
end

local function className(obj)
    if isObject(obj) then return objinfo(obj, 1)
    if (obj = '') then return objinfo(me, 1)
    return obj
end

local function hasMethod(obj, method)
    names = objinfo(obj, 2)
    cc = dcount(names, @fm)
    for c = 1 to cc
        methods = names<c,2> : @svm : names<c,3>
        locate method in methods<1,1,1> setting pos then return @true
    next c
    return @false
end
