************************************************************************
* /MBTOOLS/IF_CTS_REQ_DISPLAY
* MBT Request Display
*
* (c) MBT 2020 https://marcbernardtools.com/
************************************************************************
interface /MBTOOLS/IF_CTS_REQ_DISPLAY
  public .

  type-pools ICON .

  interfaces IF_BADI_INTERFACE .

* Ellipsis character
  constants C_ELLIPSIS type C value '…' ##NO_TEXT.
* Position for ellipsis = Length of data element SEU_TEXT - 2
  constants C_POS_ELLIPSIS type I value 73 ##NO_TEXT.

  class-methods GET_OBJECT_DESCRIPTIONS
    importing
      !IT_E071 type TRWBO_T_E071
      !IT_E071K type TRWBO_T_E071K optional
      !IT_E071K_STR type TRWBO_T_E071K_STR optional
    changing
      !CT_E071_TXT type /MBTOOLS/TRWBO_T_E071_TXT .
  class-methods GET_OBJECT_ICON
    importing
      value(IV_OBJECT) type TROBJTYPE
      value(IV_OBJ_TYPE) type CSEQUENCE optional
      value(IV_ICON) type ICON_D optional
    changing
      value(CV_ICON) type ICON_D .
endinterface.
