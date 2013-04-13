$ifndef SUGAR.H

    $define true 1
    $define false 0
    $define default 1
    $define qmNull ''
    $define endif end
    $define endclass end
    $define endsub end
    $define endsubroutine end
    $define endfun end
    $define endfunction end
    $define endget end
    $define endset end
    $define endopen end
    $define endread end
    $define endlocate end

    deffun IsObject( var ) calling "!GetObjectInfo" key 0
    deffun ObjectName( var ) calling "!GetObjectInfo" key 1
    deffun Reflection( var ) calling "!GetObjectInfo" key 2

    $define SUGAR.H 1

$endif
