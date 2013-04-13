      !
      ! CLASS XMLTOOLS.CLS
      !
      ! v0.04 Beta
      ! This class is provided as a required subset of objects that make up the
      ! Open Source QMXML project. This project is released under public domain
      ! and is free for commercial and non-commercial use, distribution, and 
      ! modification. The original authors of this project do not accept any
      ! responsibility for damages caused by the use of this project. Technical
      ! support is confined to commercially sold distributions of this project
      ! and is offered at the will of the commercial entity which is distributing it.
      !
      ! Created 5/15/2006 by Glen Batchelor [mvdevcentral.com / picksource.com]
      !
      !
      !  07/10/06 [.04 REVISION] ADDED DOCTYPE SPECIFIER FOR DTD REFERENCING
      !  07/10/06 [.04 REVISION] REMOVED </XML> CLOSING TAG FROM DOCUMENT
      !  06/27/06 [.03 REVISION] REMOVED CONTAINER VALUE PARAMETER
      !  06/27/06 [.03 REVISION] FIXED INDEXING ISSUE WHEN CLOSING CONTAINERS
      !  06/27/06 [.03 REVISION] AUTO SELF-CLOSING TAGS FOR ELEMENTS WITH NO VALUE
      !  05/18/06 [.02 REVISION] CATALOG UPDATE AND NAME CHANGE
      !
      !
      $MODE UV.LOCATE
      CLASS XMLTOOLS.CLS
      $catalog global
      PRIVATE XMLDOC, LEVEL, DOCSTATUS, OPENCONTAINERS, DOCTYPE.NAME, DOCTYPE.TYPE, DOCTYPE.URI
      !
      ! INIT
      !
      PUBLIC SUBROUTINE INIT
      XMLDOC = ''
      LEVEL = ''
      DOCSTATUS = ''
      OPENCONTAINERS = ''
      DOCTYPE.NAME = ''
      DOCTYPE.TYPE = ''
      DOCTYPE.URI = ''
      RETURN
      END          
      !----------------------------------------------------------
      !
      ! SET DOCTYPE SPECIFIER IF NEEDED
      !
      PUBLIC SUBROUTINE SETDOCTYPE(DNAME,DTYPE,DURI)
      DOCTYPE.NAME = DNAME
      DOCTYPE.TYPE = DTYPE
      DOCTYPE.URI = DURI
      RETURN
      END
      !----------------------------------------------------------
      !
      ! GET XML DOC
      !
      GET XML
      IF DOCSTATUS = 1 THEN
         CRT "ERROR: YOU HAVE NOT CLOSED YOUR DOCUMENT!"
         RETURN ''
      END
      IF OPENCONTAINERS > 0 THEN
         CRT "ERROR: YOU HAVE NOT CLOSED ALL OF YOUR CONTAINERS!"
         RETURN ''
      END
      RETURN XMLDOC
      END          
      !----------------------------------------------------------
      !
      ! OPEN DOCUMENT
      !
      PUBLIC FUNCTION OPENDOCUMENT(XMLVERSION,SPECS,ENCODING)
      XMLDOC = ''
      IF DOCTYPE.NAME # "" THEN
         XMLDOC<-1> = "<!DOCTYPE ":OCONV(DOCTYPE.NAME,"MCU"):" ":OCONV(DOCTYPE.TYPE,"MCU"):' "':DOCTYPE.URI:'">'
      END
      IF ENCODING = '' THEN ENCODING = 'UTF-8'
      IF XMLVERSION = '' THEN XMLVERSION = '1.0'
      ATTR = 'version="':XMLVERSION:'"'
      ATTR<-1> = 'encoding="':ENCODING:'"'
      SCNT = DCOUNT(SPECS,CHAR(254))
      FOR PTR = 1 TO SCNT
         ATTR<-1> = SPECS<PTR>
      NEXT PTR
      CONVERT CHAR(254) TO CHAR(32) IN ATTR
      XMLDOC<-1> = '<?xml ':ATTR:' ?>'
      LEVEL = 1
      DOCSTATUS = 1
      RETURN LEVEL
      END
      !
      ! CLOSE DOCUMENT
      !
      PUBLIC FUNCTION CLOSEDOCUMENT
      !      XMLDOC<-1> = '</xml>'
      LEVEL = LEVEL - 1
      DOCSTATUS = 0
      RETURN LEVEL
      END
      !----------------------------------------------------------
      !
      ! ADD AN ELEMENT BY ELEMENT NAME
      !
      PUBLIC FUNCTION ADDELEMENT(ELEMENT,ATTR,VAL)
      CONVERT CHAR(254) TO CHAR(32) IN ATTR
      CALL MARKUPENCODE(VAL)
      IF TRIM(VAL) = "" THEN
         IF TRIM(ATTR) = "" THEN
            XMLDOC<-1> = SPACE(LEVEL+1):'<':ELEMENT:'/>'
         END ELSE
            XMLDOC<-1> = SPACE(LEVEL+1):'<':ELEMENT:' ':ATTR:' />'
         END
         RETURN LEVEL
      END
      IF TRIM(ATTR) = "" THEN
         XMLDOC<-1> = SPACE(LEVEL+1):'<':ELEMENT:'>':VAL:'</':ELEMENT:'>'
      END ELSE
         XMLDOC<-1> = SPACE(LEVEL+1):'<':ELEMENT:' ':ATTR:'>':VAL:'</':ELEMENT:'>'
      END
      RETURN LEVEL
      END    
      !
      ! OPEN A CONTAINER BY ELEMENT NAME
      !
      PUBLIC FUNCTION OPENCONTAINER(ELEMENT,ATTR,DUMMY)
      CONVERT CHAR(254) TO CHAR(32) IN ATTR
      IF TRIM(ATTR) # "" THEN
         XMLDOC<-1> = SPACE(LEVEL):'<':ELEMENT:' ':ATTR:'>'
      END ELSE
         XMLDOC<-1> = SPACE(LEVEL):'<':ELEMENT:'>'
      END
      LEVEL = LEVEL + 1
      OPENCONTAINERS = OPENCONTAINERS + 1
      RETURN LEVEL
      END    
      !
      ! CLOSE A CONTAINER BY ELEMENT NAME
      !
      PUBLIC FUNCTION CLOSECONTAINER(ELEMENT)
      LEVEL = LEVEL - 1
      OPENCONTAINERS = OPENCONTAINERS - 1
      XMLDOC<-1> = SPACE(LEVEL):'</':ELEMENT:'>'
      RETURN LEVEL
      END    
      !----------------------------------------------------------
      END
      
