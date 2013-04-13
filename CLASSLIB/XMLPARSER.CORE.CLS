      !
      ! CLASS XMLPARSER.CORE.CLS
      !
      ! v0.12 Beta
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
      !  05/22/06 [.12 REVISION] PERFORMANCE ENHANCEMENTS
      !  05/22/06 CODE UPDATE - SEPERATED PRE-PARSING TO THE CORE CLASS
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
      CLASS XMLPARSER.CORE.CLS
      $catalog global
      PUBLIC newdocument,COMMENTS,DELIMITER
      !
      GET DELIMITER
      RETURN DELIMITER
      END
      !
      !*******************************************************************
      !
      ! REMOVE COMMENTS
      !
      PUBLIC FUNCTION REMOVECOMMENTS(document)
      CRT "swapping CRLF"
      document = SWAP(document,CHAR(254),'')
      document = SWAP(document,CHAR(13),'')
      document = SWAP(document,CHAR(10),'')
      document = SWAP(document,"<!--",CHAR(254):"<!--")
      document = SWAP(document,"-->","-->":CHAR(254))
      document1 = ''
      document2 = ''
      CCNT = 1
      COMMENTS = ''
      PPTR = 1
      ndocument = ''
      COMMENTFLAG = 0
      STOP = 0
      DOCLEN = LEN(document)
      LNS = DCOUNT(document,CHAR(254))
      FOR PTR = 1 TO LNS
         IF document<PTR>[1,4] = "<!--" THEN
            IF COMMENTS = "" THEN
               COMMENTS = document<PTR>
            END ELSE
               COMMENTS := CHAR(254):document<PTR>
            END
         END ELSE
            ndocument := document<PTR>
         END
      NEXT PTR
      document=ndocument
      CRT "Done removing comment data"
      RETURN document
      END
      !*******************************************************************
      !
      ! PRE-PARSE
      !
      PUBLIC FUNCTION PREPARSE(document)
      newdocument = ''
      !
      ! DETERMINE WHICH DELIMITER WE CAN USE TO DEAL WITH CDATA
      !
      DELIMITER = ''
      IF COUNT(document,CHAR(254)) = 0 THEN
         DELIMITER = CHAR(254)
      END
      IF DELIMITER = '' AND COUNT(document,CHAR(253)) = 0 THEN
         DELIMITER = CHAR(253)
      END
      IF DELIMITER = '' AND COUNT(document,CHAR(252)) = 0 THEN
         DELIMITER = CHAR(252)
      END
      IF DELIMITER = '' AND COUNT(document,CHAR(251)) = 0 THEN
         DELIMITER = CHAR(251)
      END
      IF INDEX(document,"]]>",1) > 0 THEN
         document2 = ''
         document = SWAP(document,"]]>",DELIMITER)
         LNS = DCOUNT(document,DELIMITER)
         FOR PTR = 1 TO LNS - 1
            THISLINE = document<PTR>
            IF THISLINE # "" THEN
               IF document2 = "" THEN
                  document2 = TRIM(THISLINE):"]]>"
               END ELSE
                  document2 := DELIMITER:TRIM(THISLINE):"]]>"
               END
            END
         NEXT PTR
         document2 := DELIMITER:document<PTR+1>
         document = ''
         document = SWAP(document2,"<![CDATA[",DELIMITER)
         document2 = ''
         LNS = DCOUNT(document,DELIMITER)
         FOR PTR = 1 TO LNS
            THISLINE = document<PTR>
            IF THISLINE # "" THEN
               IF INDEX(THISLINE,"]]>",1) > 0 THEN
                  IF document2 = "" THEN
                     document2 = "<![CDATA[":TRIM(THISLINE)
                  END ELSE
                     document2 := DELIMITER:"<![CDATA[":TRIM(THISLINE)
                  END
               END ELSE
                  IF document2 = "" THEN
                     document2 = TRIM(THISLINE)
                  END ELSE
                     document2 := DELIMITER:TRIM(THISLINE)
                  END
               END
            END
         NEXT PTR
         document = document2
         LNS = DCOUNT(document,CHAR(254))
         FOR PTR = 1 TO LNS
            THISLINE = document<PTR>
            IF THISLINE # "" THEN
               IF INDEX(THISLINE,"<![CDATA",1) > 0 THEN 
                  IF newdocument = "" THEN
                     newdocument = THISLINE
                  END ELSE
                     newdocument := DELIMITER:THISLINE
                  END
               END ELSE
                  CONVERT "<" TO CHAR(254) IN THISLINE
                  TLNS = DCOUNT(THISLINE,CHAR(254))
                  FOR TPTR = 1 TO TLNS
                     IF THISLINE<TPTR> # "" THEN
                        DOCLINE = THISLINE<TPTR>
                        CONVERT ">" TO CHAR(254) IN DOCLINE
                        IF DCOUNT(DOCLINE,CHAR(254)) > 1 THEN
                           IF newdocument = "" THEN
                              newdocument = "<":TRIM(DOCLINE<1>):DELIMITER:TRIM(DOCLINE<2>)
                           END ELSE
                              newdocument := DELIMITER:"<":DOCLINE<1>:">":CHAR(254):DOCLINE<2>
                           END
                        END ELSE
                           IF newdocument = "" THEN
                              newdocument = "<":TRIM(THISLINE<TPTR>)
                           END ELSE
                              newdocument := DELIMITER:"<":TRIM(THISLINE<TPTR>)
                           END
                        END
                     END
                  NEXT TPTR
               END
            END
         NEXT PTR
      END ELSE
         newdocument = ''
         CONVERT "<" TO DELIMITER IN document
         TLNS = DCOUNT(document,CHAR(254))
         FOR TPTR = 1 TO TLNS
            IF document<TPTR> # "" THEN
               DOCLINE = document<TPTR>
               CONVERT ">" TO CHAR(254) IN DOCLINE
               IF DCOUNT(DOCLINE,CHAR(254)) > 1 THEN
                  IF newdocument = "" THEN
                     newdocument = "<":TRIM(DOCLINE<1>):DELIMITER:TRIM(DOCLINE<2>)
                  END ELSE
                     newdocument := DELIMITER:"<":DOCLINE<1>:">":CHAR(254):DOCLINE<2>
                  END
               END ELSE
                  IF newdocument = "" THEN
                     newdocument = "<":TRIM(document<TPTR>)
                  END ELSE
                     newdocument := DELIMITER:"<":TRIM(document<TPTR>)
                  END
               END
            END
         NEXT TPTR
      END
      RETURN newdocument
      END
      !
      ! END OF CLASS
      !
      END
