************************************************************************
* /MBTOOLS/IF_CTS_REQ_DISPLAY
* MBT Request Display
*
* (c) MBT 2020 https://marcbernardtools.com/
************************************************************************
INTERFACE /mbtools/if_cts_req_display
  PUBLIC .

  INTERFACES if_badi_interface .

  CLASS-METHODS get_object_descriptions
    IMPORTING
      !it_e071      TYPE trwbo_t_e071
      !it_e071k     TYPE trwbo_t_e071k OPTIONAL
      !it_e071k_str TYPE trwbo_t_e071k_str OPTIONAL
    CHANGING
      !ct_e071_txt  TYPE /mbtools/trwbo_t_e071_txt .
  CLASS-METHODS get_object_icon
    IMPORTING
      VALUE(i_object) TYPE trobjtype
      VALUE(i_icon)   TYPE icon_d OPTIONAL
    CHANGING
      VALUE(r_icon)   TYPE icon_d .

ENDINTERFACE.
