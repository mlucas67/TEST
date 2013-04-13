$ifndef isfile_h

    deffun isFile( fileVar ) local
    
    local function isFile( fileVar )
        return fileInfo( fileVar, 0 )
    end ;* isFile

    $define isfile_h 1
    
$endif    
