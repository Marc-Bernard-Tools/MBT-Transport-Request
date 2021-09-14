INTERFACE /mbtools/if_cts_req_display
  PUBLIC .

************************************************************************
* MBT Transport Request
*
* Copyright 2021 Marc Bernard <https://marcbernardtools.com/>
* SPDX-License-Identifier: GPL-3.0-or-later
************************************************************************

  INTERFACES if_badi_interface .

* Position for ellipsis = Length of data element SEU_TEXT - 2
  CONSTANTS c_pos_ellipsis TYPE i VALUE 73 ##NO_TEXT.

  CLASS-METHODS get_object_descriptions
    IMPORTING
      !it_e071      TYPE trwbo_t_e071
      !it_e071k     TYPE trwbo_t_e071k OPTIONAL
      !it_e071k_str TYPE trwbo_t_e071k_str OPTIONAL
    CHANGING
      !ct_e071_txt  TYPE /mbtools/trwbo_t_e071_txt .
  CLASS-METHODS get_object_icon
    IMPORTING
      VALUE(iv_object)   TYPE trobjtype
      VALUE(iv_obj_type) TYPE csequence OPTIONAL
      VALUE(iv_icon)     TYPE icon_d OPTIONAL
    CHANGING
      VALUE(cv_icon)     TYPE icon_d .
ENDINTERFACE.
