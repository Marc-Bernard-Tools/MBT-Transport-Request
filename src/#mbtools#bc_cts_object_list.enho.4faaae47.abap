"Name: \FU:TRINT_DISPLAY_REQUESTS\SE:BEGIN\EI
ENHANCEMENT 0 /MBTOOLS/BC_CTS_OBJECT_LIST.
************************************************************************
* MBT Transport Request
*
* Copyright 2021 Marc Bernard <https://marcbernardtools.com/>
* SPDX-License-Identifier: GPL-3.0-or-later
************************************************************************

  IF /mbtools/cl_switches=>is_active( /mbtools/cl_switches=>c_tool-mbt_transport_request ) = abap_true.

    " Wider popup to display description AND object names
    IF is_popup-end_column = 84.
      is_popup-end_column = 150.
    ENDIF.

  ENDIF.

ENDENHANCEMENT.
