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
      value(IV_ICON) type ICON_D optional
    changing
      value(RV_ICON) type ICON_D .
endinterface.
