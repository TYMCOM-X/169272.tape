
require "     SPL external variables" message;
external Own Integer Brk, BrkLin, BrkNam, BrkUsr, BrkWht, BrkBrk, BrkCmd;
external Own Integer RsDone, RsDate, RsNum, RsSite, RsFlag, RsDot;
external Own Integer RsCount, SixCrlf, Index, FrmLic, LudDist;
external Own Integer OptIndent, OptFullCase, OptHeading;
external Own Integer OptCopies, OptTransfer, OptQuest, OptFortran;
external Own Integer OptDouble, OptSite, OptPtrSite, OptPaper;
external Own Integer OptParts, OptDecolate, OptDeliver, OptCustomer;
external Own Integer OptChgOther, OptKatakana, OptLPPage;
external Own String Line, RsUser, RsDev, RsFile, RsForm, RsName, SvOper;
external Own Integer Array RsBlk[1:6];
    Comment 2w=username, 1w=device, 1w=filename, 1w=ext, 1w=extra;
  