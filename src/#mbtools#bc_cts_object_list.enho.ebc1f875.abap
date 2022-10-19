"Name: \PR:SAPLSTRH\FO:CREATE_OBJECT_LIST\SE:BEGIN\EI
ENHANCEMENT 0 /MBTOOLS/BC_CTS_OBJECT_LIST.
************************************************************************
* MBT Transport Request
*
* Copyright 2021 Marc Bernard <https://marcbernardtools.com/>
* SPDX-License-Identifier: GPL-3.0-only
************************************************************************

  IF /mbtools/cl_switches=>is_active( /mbtools/cl_switches=>c_tool-mbt_transport_request ) = abap_true.

    PERFORM create_object_list IN PROGRAM /mbtools/cts_object_list
      USING    pv_parent_level
               pv_trkorr
               pv_with_keys
      CHANGING pt_e071
               pt_e071k
               pt_e071k_str
               pt_nodes.

    EXIT.

  ENDIF.

ENDENHANCEMENT.
