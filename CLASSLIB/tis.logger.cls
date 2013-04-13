* START-LICENSE
*
* Trident Logger Class for OpenQM
* tis.logger.cls - A simple logging class
* Copyright (c) 2006, Trident Information Systems, Inc.
* All rights reserved.
* 
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * The name of Trident Information Systems may no be used to endorse or
*       promote products derived from this software without specific prior
*       written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS ``AS IS'' AND ANY
* EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*
* END-LICENSE
 
* START-HISTORY:
* 17 Oct 06  1.0.3 - Added LogMode property
*                  - Internal reorganization of some properties/methods
*                  
* 17 Oct 06  1.0.2 - Added append/prepend mode
*                  - Minor optimizations
*                  
* 14 Aug 06  1.0.1 - Update to LogTags functionality
* 08 Aug 06  1.0.0 - First release
* END-HISTORY

* START-DESCRIPTION:
*
* This class library allows for the addition of simple logging capabilities to 
* programs.  Logs are single items within a file.  A single log item may
* contain an unlimited number of entries, but for performance purposes, it is
* recommended that the number of entries is limited via the MaxEntries
* property.  For a complete description of this class, its properties, and
* methods, please see the documentation files tisLogger.chm or tisLogger.pdf
*
* END-DESCRIPTION

* START-CODE
* 
class tis.logger.cls

* ====================================================================
* Declarations - Properties and local functions / subroutines
* ====================================================================
   
   public DateFormat     ;* Property - Format mask for date conversion output     
   public IncDateTime    ;* Property - Determines date/time stamp inclusion
   public LogFileName    ;* Property - Name of logging file
   public LoggingActive  ;* Property - Boolean turns loging on/off
   public LogItemID      ;* Property - Id of item in logging file
   public LogMode        ;* Property - Returns APPEND or PREPEND - Read Only
   public LogTags        ;* Property - Dynamic array of filter values
   public MaxEntries     ;* Property - Max number of logging entries per item
   public Separator      ;* Property - Characters to separate logging text
                          *            and date-time stamp
         
   private ModeIsAppend  ;* Variable - Boolean - T=Append F=Prepend
   private FileID        ;* Variable - Logging file file.var of Open stmt
   private LogFileOpen   ;* Variable - Boolean is log file open (T/F)?
   
   deffun VerifyBoolean(value) local ;* Local function to set a boolean value

* ====================================================================
* Properties
* ====================================================================

* ====================================================================
* IncDateTime() - Property defines boolean value that determines if a
*                 date-time stamp is prefixed to logging entries

   public subroutine IncDateTime(value)
      IncDateTime = VerifyBoolean(value)
   end

* ====================================================================
* LogFileName() - Property defines the name of the logging file.  Setting
*                 this property also opens the logging file.
    
   public subroutine LogFileName(value)
      LogFileName = value
      if LogFileOpen then close FileID
      LogFileOpen = @False
      if len(LogFileName) > 0 then
         open LogFileName to FileID then LogFileOpen = @True
      end
   end

* ====================================================================
* LoggingActive() - Property defines a boolean value to enable/disable
*                   logging via the WriteLog() method.
    
   public subroutine LoggingActive(value)
      LoggingActive = VerifyBoolean(value)
   end

* ====================================================================
* LogMode() - Property returns logging mode as string value of 
*             APPEND or PREPEND.

   public function LogMode()
      if ModeIsAppend then return 'APPEND' else return 'PREPEND'
   end
   
* ====================================================================
* LogTags() - Property defines a dynamic array of values to act as a 
*             filter for the WriteLog() method.

   public subroutine LogTags(value)
      LogTags = upcase(value)
   end

* ====================================================================
* MaxEntries() - Property defines max number of logging entries per 
*                logging file item.
    
   public subroutine MaxEntries(value)
      value = int(oconv(value,'MCN'))
      if value < 0 then value = 0
      MaxEntries = value
   end

* ====================================================================
* Methods
* ====================================================================

* ====================================================================
* Create.Object() - Method sets default property values upon instantiation
    
   public subroutine Create.Object()
      DateFormat = 'D4'
      LogFileOpen = @False
      IncDateTime = @True
      LogFileName = ''
      LogItemID = ''
      LoggingActive = @True
      LogTags = ''
      MaxEntries = 500
      ModeIsAppend = @False
      Separator = '---'
   end

* ====================================================================
* DeleteLog() - Method deletes a logging item identified by LogID, or
*               deletes all items in current logging file if LogID = *

   public subroutine DeleteLog(LogID) var.args
      if LogFileOpen then
         if (arg.count() = 0) then LogID = ''
         if LogID = '*' then
            clearfile FileID
         end else 
            if len(LogId) = 0 then LogID = LogItemID
            if len(LogId) > 0 then delete FileID, LogID
         end
      end
   end

* ====================================================================
* SetModeAppend() - Method sets logging entries to be added to the 
*                   end of the logging file item.
    
   public subroutine SetModeAppend()
      ModeIsAppend = @True
   end
   
* ====================================================================
* SetModePrepend() - Method sets logging entries to be added to the 
*                    beginning of the logging file item.
    
   public subroutine SetModePrepend()
      ModeIsAppend = @False
   end     
   
* ====================================================================
* WriteLog() - Method writes MsgText to logging file.  Optional ItemID
*              supersedes LogItemID() property. Optional filter on Tag
*              value in conjunction with LogTags() property.
   
   public subroutine WriteLog(MsgText, Tag, ItemID) var.args

      ac = arg.count()

      begin case       
         case (ac < 1) or (ac > 3); return
         case ac = 1; Tag = ''; ItemID = ''
         case ac = 2; ItemID = ''
      end case
      
      begin case
         case not(LoggingActive); return
         case not(LogFileOpen)  ; return
         case len(MsgText) = 0  ; return
      end case
            
      if len(LogTags) > 0 then
         if len(Tag) > 0 then
            Tag = upcase(Tag)
            locate(Tag,LogTags;pos) else return
         end else
            return
         end
      end

      if len(ItemID) = 0 then ItemID = LogItemID
      if len(ItemID) = 0 then return

      if IncDateTime then
         d = oconv(date(),DateFormat)
         t = oconv(time(),'MTS')
         LineOut = d:' ':t:Separator:MsgText
      end else
         LineOut = MsgText
      end
      
      readu logRec from FileID,ItemID then
         if ModeIsAppend then
            logRec = logRec:@AM:LineOut ;* Append entry to log
         end else
            logRec = LineOut:@AM:logRec ;* Prepend entry to log
         end
      end else
         logrec = LineOut
      end
      
      If MaxEntries > 0 then
         logCount = dcount(logRec,@AM)
         if ModeIsAppend then
            pos = logCount - MaxEntries
            for ndx = 1 to pos
               logRec = delete(logRec,1)
            next ndx
         end else 
            pos = MaxEntries + 1
            for ndx = pos to logCount
               logRec = delete(logRec, pos)
            next ndx
         end
      end
      
      write logRec on FileID, ItemID

   end
   
* ====================================================================
* Local Functions and Subroutines
* ====================================================================   
   
* ====================================================================
* VerifyBoolean() - Local function returns a boolean result value
     
   local function VerifyBoolean(value)
      value = upcase(value)
      begin case
         case NUM(value) and (value > 0); return @True
         case value = 'T'    ; return @True
         case value = 'TRUE' ; return @True
         case value = 'Y'    ; return @True
         case value = 'YES'  ; return @True
         case 1              ; return @False          
      end case
   end
end
* END-CODE