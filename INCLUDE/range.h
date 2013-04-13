$ifndef RANGE_H

    deffun range( first, last, incr ) local
    
    local function range( first, last, incr=1 ) var.args
        retarr = ''
        for i = first to last step incr
            retarr<-1> = i
        next i
    end ;* range

$endif
