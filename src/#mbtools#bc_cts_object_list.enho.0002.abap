"NAME:\PR:SAPLSTRH\FO:CREATE_KEY_LIST\SE:BEGIN\EI
ENHANCEMENT 0 /MBTOOLS/BC_CTS_OBJECT_LIST.
************************************************************************
* MBT Transport Request
*
* Copyright 2021 Marc Bernard <https://marcbernardtools.com/>
* SPDX-License-Identifier: GPL-3.0-or-later
************************************************************************

  IF /mbtools/cl_switches=>is_active( /mbtools/cl_switches=>c_tool-mbt_transport_request ) = abap_true.

    PERFORM create_key_list IN PROGRAM /mbtools/cts_object_list
      USING    pv_keep_nodes
               pv_object_level
               pv_as4pos
               pt_e071
               pt_e071k
               pt_e071k_str
      CHANGING pt_nodes.

    EXIT.

  ENDIF.

ENDENHANCEMENT.
