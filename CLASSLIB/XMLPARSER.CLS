      !
      ! CLASS XMLPARSER.CLS
      !
      ! v0.13 Beta
      !
      ! This class is provided as a required subset of objects that make up the
      ! Open Source QMXML project. This project is released under public domain
      ! and is free for commercial and non-commercial use, distribution, and 
      ! modification. The original authors of this project do not accept any
      ! responsibility for damages caused by the use of this project. Technical
      ! support is confined to commercially sold distributions of this project
      ! and is offered at the will of the commercial entity which is distributing it.
      !
      ! Created 5/6/2006 by Glen Batchelor [mvdevcentral.com / picksource.com]
      !
      !  06/20/06 [.13 REVISION] BUG IN SELF-CLOSING TAG, RELATING TO DOMPOINTER
      !  05/22/06 [.12 REVISION] PERFORMANCE ENHANCEMENTS
      !  05/22/06 [.12 REVISION] SPLIT THE PREPARSE TO CORE CLASS
      !  05/19/06 [.11 REVISION] CODE RESTRUCTURING AND CDATA/TAG EXTRACTION FIX
      !  05/18/06 [.10 REVISION] PERFORMANCE ENHANCEMENTS LEVEL 1
      !  LEVEL 1 ENHANCEMENTS: EXECUTION SAVINGS OF 50% FOR xmltest1.xml
      !   ELEMINATE EXTRA LOOPS WHERE LOOPS CAN BE COMBINED
      !   REPLACE MULTIPLE REFERENCES TO A SINGLE ARRAY INDEX WITH A SINGLE VARIABLE
      !                       
      !  05/18/06 [.09 REVISION] CATALOG UPDATE AND NAME CHANGE
      !  05/15/06 [.08 REVISION] CDATA REDESIGN, REMOVAL OF COMMENTS, ADDITIONAL FIXES
      !  05/15/06 [.07 REVISION] FIXED BIG ATTRIBUTE EXTRACTION BUG
      !  05/15/06 [.06 REVISION] ADDED PARAMETRIC METHOD FOR PULLING DOM DATA
      !  05/15/06 [.06 REVISION] ADDED ELEMENT NAME METHOD FOR PULLING ATTRIBUTES
      !  05/15/06 [.06 REVISION] ADDED DOM PATH METHOD FOR PULLING ATTRIBUTES
      !  05/15/06 [.06 REVISION] FIXED ASSIGNMENT BUG IN DOM PATH AND POINTER UPDATES
      !  05/13/06 [.05 REVISION] ADDED DOM PATH AND NODE METHODS FOR PULLING CDATA
      !  05/13/06 [.04 REVISION] FIXED NODE TRAVERSING ERRORS WITH NULL ENTRIES IN 'newdocument'
      ! 
      !
      !
      !
      $MODE UV.LOCATE
      !
      !
      CLASS XMLPARSER.CLS
      $catalog global
      PRIVATE newdocument, VALUES, ELEMENTS, ATTRIBUTES, NODELEVELS, DOMPATH, CDATAPATH, CDATAVALUE, PROCESS.TIME, COMMENTS, NAMESPACES
      PRIVATE DELIMITER
      !---------------------------------------------------------------------------------------------
      !
      ! PROPERTIES
      !
      !---------------------------------------------------------------------------------------------
      !******************************************************
      ! RETURN ALL XML COMMENTS INTO A PROPERTY CALLED COMMENTS
      !
      GET COMMENTS
      RETURN COMMENTS
      END
      !---------------------------------------------------------------------------------------------
      !
      ! METHODS
      !
      !---------------------------------------------------------------------------------------------
      !******************************************************
      ! RETURN PARTS OF THE DOM
      !
      PUBLIC FUNCTION GETDOM(TYPE)
      BEGIN CASE
         CASE TYPE='DOMPOINTER'; DOM.VALUE = DOMPATH; CONVERT CHAR(253) TO "." IN DOM.VALUE
         CASE TYPE='DOMPATH'; DOM.VALUE = DOMPATH
         CASE TYPE='ELEMENTS'; DOM.VALUE = ELEMENTS
         CASE TYPE='NODELEVELS'; DOM.VALUE = NODELEVELS
         CASE TYPE='VALUES'; DOM.VALUE = VALUES
         CASE TYPE='ATTRIBUTES'; DOM.VALUE = ATTRIBUTES
         CASE TYPE='CDATAPATH'; DOM.VALUE = CDATAPATH
         CASE TYPE='CDATAVALUE'; DOM.VALUE = CDATAVALUE
         CASE TYPE='NAMESPACES'; DOM.VALUE = NAMESPACES
         CASE 1; DOM.VALUE = newdocument
      END CASE
      RETURN DOM.VALUE
      END
      !******************************************************
      ! RETURN ALL ATTRIBUTE PAIR ARRAYS FOR AN ELEMENT NAME
      !
      PUBLIC FUNCTION GETATTRIBUTESBYELEMENT(ELEMENT.NAME)
      ATTRIBUTEVAR = ''
      ELEMENT.COUNT = DCOUNT(ELEMENTS,CHAR(254))
      FOR EPTR = 1 TO ELEMENT.COUNT
         IF ELEMENTS<EPTR> = ELEMENT.NAME THEN
            ATTVAR = ATTRIBUTES<EPTR>
            CONVERT CHAR(253) TO CHAR(254) IN ATTVAR
            ATTRIBUTEVAR := CHAR(254):ATTVAR
         END
      NEXT EPTR
      RETURN ATTRIBUTEVAR
      END
      !******************************************************
      ! RETURN ATTRIBUTE PAIR ARRAY FOR A SPECIFIC DOM PATH
      !
      PUBLIC FUNCTION GETATTRIBUTESBYPATH(DOM.PATH)
      CONVERT "." TO CHAR(253) IN DOM.PATH
      LOCATE DOM.PATH IN DOMPATH SETTING ATVM THEN
         ATTVAR = ATTRIBUTES<ATVM>
         CONVERT CHAR(253) TO CHAR(254) IN ATTVAR
         ATTRIBUTEVAR = ATTVAR
      END ELSE
         ATTRIBUTEVAR = ''
      END
      RETURN ATTRIBUTEVAR
      END
      !******************************************************
      ! RETURN CDATA ARRAY FOR A SPECIFIC DOM PATH
      !
      PUBLIC FUNCTION GETCDATABYPATH(DOM.PATH)
      PATHCNT = DCOUNT(CDATAPATH,CHAR(254))
      THISCDATA=''
      FOR PTR = 1 TO PATHCNT
         IF CDATAPATH<PTR> = DOM.PATH THEN
            THISCDATA := CHAR(254):CDATAVALUE<PTR>
         END
      NEXT PTR
      RETURN THISCDATA
      END
      !******************************************************
      ! RETURN NODE LEVEL FOR A SPECIFIC ELEMENT NAME
      !
      PUBLIC FUNCTION GETNODELEVEL(ELEMENT.NAME)
      LOCATE ELEMENT.NAME IN ELEMENTS SETTING DOCVM THEN
         NODE.LEVEL = NODELEVELS<DOCVM>
      END ELSE
         NODE.LEVEL = ""
      END
      RETURN NODE.LEVEL
      END
      !******************************************************
      ! RETURN VALUES FOR A SPECIFIC ELEMENT NAME
      !
      PUBLIC FUNCTION GETVALUES(ELEMENT.NAME)
      DOMVALUES = ''
      ELCNT = DCOUNT(ELEMENTS,CHAR(254))
      FOR PTR = 1 TO ELCNT
         IF ELEMENTS<PTR> = ELEMENT.NAME THEN
            DOMVALUES<-1> = VALUES<PTR>
         END
      NEXT PTR
      RETURN DOMVALUES
      END
      !******************************************************
      ! RETURN VALUE FOR A SPECIFIC DOM POINTER
      !
      PUBLIC FUNCTION GETVALUE(DOC.POINTER)
      CONVERT "." TO CHAR(253) IN DOC.POINTER
      LOCATE DOC.POINTER IN DOMPATH SETTING DOCVM THEN
         DOMVALUE = VALUES<DOCVM>
      END ELSE
         DOMVALUE = ""
      END
      RETURN DOMVALUE
      END
      !******************************************************
      ! PARSING METHOD
      !
      PUBLIC SUBROUTINE parse(document)
      DEBUGFLAG=0
      !
      ! REMOVE EXTRA DELIMITERS AND CHARACTERS THAT ARE NOT PART OF OUR PARSING
      !
      CONVERT CHAR(254) TO "" IN document
      VALUES = ''
      ELEMENTS = ''
      ATTRIBUTES = ''
      NODELEVELS = ''
      DOMPATH = ''
      CDATAPATH = ''
      CDATAVALUE = ''
      COMMENTS = ''
      NAMESPACES = ''
      NODELVL = 0
      NODEPTR = 0
      THISOLDPATH = ''
      THISPATH = ''
      THISPATH2 = ''
      !
      ! REMOVE COMMENTS AND PRE-PARSE
      !
      XMLPARSER = object("XMLPARSER.CORE.CLS")
      xdocument = ''
!      xdocument = XMLPARSER->REMOVECOMMENTS(document)
      newdocument = ''
      newdocument = XMLPARSER->PREPARSE(document)
      DELIMITER = XMLPARSER->DELIMITER
      !      LNS = DCOUNT(newdocument,DELIMITER)
      !      FOR PTR = 1 TO LNS
      !         CRT newdocument<PTR>
      !      NEXT PTR
      !      STOP
      !
      !
      ! CONVERT MAIN DOCUMENT ARRAY INTO DOM
      !
      !
      !
      ! ELEMENTS = CHAR(254) DELIMITED ARRAY OF ELEMENT NAMES 
      ! CDATAPATH = MATCHING ARRAY OF CDATA DOM PATHS DELIMITED BY CHAR(253) FOR MULTIPLE SECTIONS
      ! CDATAVALUES = MATCHING ARRAY OF CDATA SECTIONS DELIMITED BY CHAR(253) FOR MULTIPLE SECTIONS
      ! CLOSINGTAGS = CHAR(254) DELIMITED ARRAY OF CLOSING ELEMENT NAMES 
      ! NODELEVELS = MATCHING ARRAY OF NODE NUMBERS BASED ON <XML> AS NODE LEVEL 1
      ! VALUES = MATCHING ARRAY OF ELEMENT/CONTAINER VALUES
      ! ATTRIBUTES = CHAR(253) DELIMITED MV ARRAY OF ATTRIBUTE/VALUE PAIRS FOR EACH ELEMENT
      ! DOMPATH = CHAR(253) DELIMITED ARRAY OF THE DOMPATH FOR EACH MV ELEMENT
      !
      DOCLINES = DCOUNT(newdocument,DELIMITER)
      THISPATH = ''
      NODEPTR = 0
      FOR PTR = 1 TO DOCLINES
         THISDOCLINE = newdocument<PTR>
         IF TRIM(THISDOCLINE) = "" THEN GOTO NEXT.TAG
      !
      ! DETERMINE WHAT THE CURRENT DOCUMENT LINE IS
      !
         NEWCONTAINER = 0
         SELFCLOSINGTAG = 0
         COMMANDDIRECTIVE = 0
         CLOSINGTAG = 0
         CDATATAG = 0
      !
         IF THISDOCLINE[1,1] = "<" AND THISDOCLINE[2,1] # "/" AND THISDOCLINE[2,1] # "?" AND THISDOCLINE[2,1] # "!" THEN
            NEWCONTAINER = 1
            SELFCLOSINGTAG = 0
            COMMANDDIRECTIVE = 0
            CLOSINGTAG = 0
            CDATATAG = 0
         END
         IF THISDOCLINE[1,1] = "<" AND THISDOCLINE[2,1] = "?" THEN
            NEWCONTAINER = 0
            SELFCLOSINGTAG = 0
            COMMANDDIRECTIVE = 1
            CLOSINGTAG = 0
            CDATATAG = 0
         END
         IF THISDOCLINE[LEN(THISDOCLINE)-1,2] = "/>" THEN
            NEWCONTAINER = 0
            SELFCLOSINGTAG = 1
            COMMANDDIRECTIVE = 0
            CLOSINGTAG = 0
            CDATATAG = 0
         END
         IF THISDOCLINE[1,2] = "</" THEN
            NEWCONTAINER = 0
            SELFCLOSINGTAG = 0
            COMMANDDIRECTIVE = 0
            CLOSINGTAG = 1
            CDATATAG = 0
         END
         IF THISDOCLINE[1,9] = "<![CDATA[" THEN
            NEWCONTAINER = 0
            SELFCLOSINGTAG = 0
            COMMANDDIRECTIVE = 0
            CLOSINGTAG = 0
            CDATATAG = 1
         END
      !----------------------------------------------------------------
      !
      ! SELF CLOSING TAG
      ! 
         IF SELFCLOSINGTAG = 1 THEN
            NODEPTR = NODEPTR + 1
            ELEMENTSTR = THISDOCLINE[2,LEN(THISDOCLINE)-3]
            CONVERT CHAR(32) TO CHAR(254) IN ELEMENTSTR
      !
      ! EXTRACT ATTRIBUTE PAIRS IF PRESENT AND ASSIGN ELEMENT NAME VARIABLE
      !
            ELEMENTVAR = ELEMENTSTR<1>
            CONVERT CHAR(32) TO CHAR(254) IN ELEMENTVAR
            ELEMENTNAME = ELEMENTVAR<1>
            CONVERT ":" TO CHAR(254) IN ELEMENTNAME
            NAMESPC = ''
            IF INDEX(ELEMENTNAME,CHAR(254),1) > 0 THEN
               NAMESPC = ELEMENTNAME<1>
               ENAME = ELEMENTNAME<2>
               ELEMENTNAME = ENAME
            END ELSE
               ELEMENTNAME = ELEMENTVAR<1>
            END
            DEL ELEMENTVAR<1>
            CONVERT CHAR(254) TO CHAR(32) IN ELEMENTVAR
            ELEMENTVAR = TRIM(ELEMENTVAR)
            ATTRLEN = LEN(ELEMENTVAR)
            FIRSTFOUND=0
            THISATTRIBUTE=''
            ATTRARRAY = ''
            FOR APTR = 1 TO ATTRLEN
               IF ELEMENTVAR[APTR,1] = '"' THEN
                  IF FIRSTFOUND = 1 THEN
                     FIRSTFOUND = 0
                     THISATTRIBUTE := ELEMENTVAR[APTR,1]
                     IF ATTRARRAY = "" THEN
                        ATTRARRAY = TRIM(THISATTRIBUTE)
                     END ELSE
                        ATTRARRAY := CHAR(253):TRIM(THISATTRIBUTE)
                     END
                     THISATTRIBUTE=''
                  END ELSE
                     FIRSTFOUND = 1
                     THISATTRIBUTE := ELEMENTVAR[APTR,1]
                  END
               END ELSE
                  THISATTRIBUTE := ELEMENTVAR[APTR,1]
               END
            NEXT APTR
            IF ATTRIBUTES = "" THEN
               ATTRIBUTES = ATTRARRAY
            END ELSE
               ATTRIBUTES := CHAR(254):ATTRARRAY
            END
      !
      !
            IF ELEMENTS = "" THEN
               ELEMENTS = ELEMENTNAME
            END ELSE
               ELEMENTS := CHAR(254):ELEMENTNAME
            END
            IF NAMESPACES = "" THEN
               NAMESPACES = NAMESPC
            END ELSE
               NAMESPACES := CHAR(254):NAMESPC
            END
            IF NODELEVELS = "" THEN
               NODELEVELS = NODELVL
            END ELSE
               NODELEVELS := CHAR(254):NODELVL
            END
            IF THISPATH = "" THEN
               THISPATH = ELEMENTNAME
            END ELSE
               THISPATH := CHAR(253):ELEMENTNAME
            END
      !
      ! UPDATE DOM POINTER AND PATH
      !
            IF DOMPATH = "" THEN
               DOMPATH = THISPATH
            END ELSE
               DOMPATH := CHAR(254):THISPATH
            END
            LASTVAL = DCOUNT(THISPATH<1>,CHAR(253))
            DEL THISPATH<1,LASTVAL>
            THISPATH2 = THISPATH
            CONVERT CHAR(253) TO "." IN THISPATH2
            NODELVL = NODELVL - 1
            GOTO NEXT.TAG
         END
      !----------------------------------------------------------------
      !
      !OPEN NEW CONTAINER
      ! 
         IF NEWCONTAINER = 1 THEN
            NODELVL = NODELVL + 1
            NODEPTR = NODEPTR + 1
            ELEMENTSTR = THISDOCLINE[2,LEN(THISDOCLINE)-2]
      !
      ! EXTRACT ATTRIBUTE PAIRS IF PRESENT AND ASSIGN ELEMENT NAME VARIABLE
      !
            ELEMENTVAR = ELEMENTSTR<1>
            CONVERT CHAR(32) TO CHAR(254) IN ELEMENTVAR
            ELEMENTNAME = ELEMENTVAR<1>
            CONVERT ":" TO CHAR(254) IN ELEMENTNAME
            NAMESPC = ''
            IF INDEX(ELEMENTNAME,CHAR(254),1) > 0 THEN
               NAMESPC = ELEMENTNAME<1>
               ENAME = ELEMENTNAME<2>
               ELEMENTNAME = ENAME
            END ELSE
               ELEMENTNAME = ELEMENTVAR<1>
            END
            DEL ELEMENTVAR<1>
            CONVERT CHAR(254) TO CHAR(32) IN ELEMENTVAR
            ELEMENTVAR = TRIM(ELEMENTVAR)
            ATTRLEN = LEN(ELEMENTVAR)
            FIRSTFOUND=0
            THISATTRIBUTE=''
            ATTRARRAY = ''
            FOR APTR = 1 TO ATTRLEN
               IF ELEMENTVAR[APTR,1] = '"' THEN
                  IF FIRSTFOUND = 1 THEN
                     FIRSTFOUND = 0
                     THISATTRIBUTE = THISATTRIBUTE:ELEMENTVAR[APTR,1]
                     THISATTRIBUTE=''
                     IF ATTRARRAY = "" THEN
                        ATTRARRAY = TRIM(THISATTRIBUTE)
                     END ELSE
                        ATTRARRAY := CHAR(253):TRIM(THISATTRIBUTE)
                     END
                  END ELSE
                     FIRSTFOUND = 1
                     THISATTRIBUTE := ELEMENTVAR[APTR,1]
                  END
               END ELSE
                  THISATTRIBUTE := ELEMENTVAR[APTR,1]
               END
            NEXT APTR
            IF ATTRIBUTES = "" THEN
               ATTRIBUTES = ATTRARRAY
            END ELSE
               ATTRIBUTES := CHAR(254):ATTRARRAY
            END
      !
      !
            IF ELEMENTS = "" THEN
               ELEMENTS = ELEMENTNAME
            END ELSE
               ELEMENTS := CHAR(254):ELEMENTNAME
            END
            IF NAMESPACES = "" THEN
               NAMESPACES = NAMESPC
            END ELSE
               NAMESPACES := CHAR(254):NAMESPC
            END
            IF NODELEVELS = "" THEN
               NODELEVELS = NODELVL
            END ELSE
               NODELEVELS := CHAR(254):NODELVL
            END
            IF THISPATH = "" THEN
               THISPATH = ELEMENTNAME
            END ELSE
               THISPATH := CHAR(253):ELEMENTNAME
            END
      !
      ! UPDATE DOM POINTER AND PATH
      !
            IF DOMPATH = "" THEN
               DOMPATH = THISPATH
            END ELSE
               DOMPATH := CHAR(254):THISPATH
            END
            THISPATH2 = THISPATH
            CONVERT CHAR(253) TO "." IN THISPATH2
            GOTO NEXT.TAG
         END
      !----------------------------------------------------------------
      !
      ! COMMAND DIRECTIVE
      !
         IF COMMANDDIRECTIVE = 1 THEN
            IF THISDOCLINE[LEN(THISDOCLINE)-1,1] = "?" THEN
               THISDOCLINE=THISDOCLINE[1,LEN(THISDOCLINE)-1]
            END
            NODELVL = NODELVL + 1
            NODEPTR = NODEPTR + 1
            ELEMENTSTR = THISDOCLINE[3,LEN(THISDOCLINE)-2]
      !
      ! EXTRACT ATTRIBUTE PAIRS IF PRESENT AND ASSIGN ELEMENT NAME VARIABLE
      !
            ELEMENTVAR = ELEMENTSTR<1>
            CONVERT CHAR(32) TO CHAR(254) IN ELEMENTVAR
            ELEMENTNAME = ELEMENTVAR<1>
            CONVERT ":" TO CHAR(254) IN ELEMENTNAME
            NAMESPC = ''
            IF INDEX(ELEMENTNAME,CHAR(254),1) > 0 THEN
               NAMESPC = ELEMENTNAME<1>
               ENAME = ELEMENTNAME<2>
               ELEMENTNAME = ENAME
            END ELSE
               ELEMENTNAME = ELEMENTVAR<1>
            END
            DEL ELEMENTVAR<1>
            CONVERT CHAR(254) TO CHAR(32) IN ELEMENTVAR
            ELEMENTVAR = TRIM(ELEMENTVAR)
            ATTRLEN = LEN(ELEMENTVAR)
            FIRSTFOUND=0
            THISATTRIBUTE=''
            ATTRARRAY = ''
            FOR APTR = 1 TO ATTRLEN
               IF ELEMENTVAR[APTR,1] = '"' THEN
                  IF FIRSTFOUND = 1 THEN
                     FIRSTFOUND = 0
                     THISATTRIBUTE = THISATTRIBUTE:ELEMENTVAR[APTR,1]
                     IF ATTRARRAY = "" THEN
                        ATTRARRAY = TRIM(THISATTRIBUTE)
                     END ELSE
                        ATTRARRAY := CHAR(253):TRIM(THISATTRIBUTE)
                     END
                     THISATTRIBUTE=''
                  END ELSE
                     FIRSTFOUND = 1
                     THISATTRIBUTE := ELEMENTVAR[APTR,1]
                  END
               END ELSE
                  THISATTRIBUTE := ELEMENTVAR[APTR,1]
               END
            NEXT APTR
            IF ATTRIBUTES = "" THEN
               ATTRIBUTES = ATTRARRAY
            END ELSE
               ATTRIBUTES := CHAR(254):ATTRARRAY
            END
      !
      !
            IF ELEMENTS = "" THEN
               ELEMENTS = ELEMENTNAME
            END ELSE
               ELEMENTS := CHAR(254):ELEMENTNAME
            END
            IF NAMESPACES = "" THEN
               NAMESPACES = NAMESPC
            END ELSE
               NAMESPACES := CHAR(254):NAMESPC
            END
            IF NODELEVELS = "" THEN
               NODELEVELS = NODELVL
            END ELSE
               NODELEVELS := CHAR(254):NODELVL
            END
            IF THISPATH = "" THEN
               THISPATH = ELEMENTNAME
            END ELSE
               THISPATH := CHAR(253):ELEMENTNAME
            END
      !
      ! UPDATE DOM POINTER AND PATH
      !
            IF DOMPATH = "" THEN
               DOMPATH = THISPATH
            END ELSE
               DOMPATH := CHAR(254):THISPATH
            END
            THISPATH2 = THISPATH
            CONVERT CHAR(253) TO "." IN THISPATH2
            GOTO NEXT.TAG
         END
      !----------------------------------------------------------------
      !
      ! CLOSE CONTAINER
      ! 
         IF CLOSINGTAG = 1 THEN
            LASTVAL = DCOUNT(THISPATH<1>,CHAR(253))
            DEL THISPATH<1,LASTVAL>
            NODELVL = NODELVL - 1
            GOTO NEXT.TAG
         END
      !----------------------------------------------------------------
      !
      ! CDATA SECTIONS
      !
         IF CDATATAG = 1 THEN
            THISPATH2 = THISPATH
            CONVERT CHAR(253) TO "." IN THISPATH2
            LASTPTR = DCOUNT(CDATAVALUE<NODEPTR>,CHAR(253)) + 0
            CDATAPATH<NODEPTR,LASTPTR+1> = THISPATH2
            CDATAVALUE<NODEPTR,LASTPTR+1> = THISDOCLINE[10,LEN(THISDOCLINE)-12]
            GOTO NEXT.TAG
         END
         VALUES<NODEPTR> = THISDOCLINE
NEXT.TAG: 
      NEXT PTR
      !
      ! NAME SPACE COLLECTION
      !
      XMLNS = ''
      ECNT = DCOUNT(ELEMENTS,CHAR(254))
      FOR EPTR = 1 TO ECNT
         ACNT = DCOUNT(ATTRIBUTES<EPTR>,CHAR(253))
         FOR APTR = 1 TO ACNT
            IF INDEX(ATTRIBUTES<EPTR,APTR>,"xmlns:":NAMESPACES<EPTR>:"=",1) > 0 THEN
               IF XMLNS = "" THEN
                  XMLNS = ATTRIBUTES<EPTR,APTR>
               END ELSE
                  XMLNS := CHAR(254):ATTRIBUTES<EPTR,APTR>
               END
            END
         NEXT APTR
      NEXT EPTR
      NAMESPACES = XMLNS
      !
      ! DEBUG OUTPUT
      !
      IF DEBUGFLAG=1 THEN
         ELEMENTCOUNT = DCOUNT(ELEMENTS,CHAR(254))
         FOR PTR = 1 TO ELEMENTCOUNT
            CRT "DOMPATH=":DOMPATH<PTR>
            CRT "ELEMENTNAME=":ELEMENTS<PTR>
            CRT "DOMLEVEL=":NODELEVELS<PTR>
            CRT "VALUE=":VALUES<PTR>
            CRT "ATTRIBUTES: ":ATTRIBUTES<PTR>
            CRT
         NEXT PTR
         PTRMAX = DCOUNT(CDATAPATH,CHAR(254))
         FOR PTR = 1 TO PTRMAX
            IF CDATAVALUE<PTR> # "" THEN
               CDATACNT = DCOUNT(CDATAVALUE<PTR>,CHAR(253))
               FOR CDATAPTR = 1 TO CDATACNT
                  CRT CDATAPATH:' CDATA "':CDATAVALUE<PTR,CDATAPTR>:'"'
               NEXT CDATAPTR
            END
         NEXT PTR
      END
      !
      ! END OF OBJECT
      !
      END
      END
      
