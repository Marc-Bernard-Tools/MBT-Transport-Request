"Name: \PR:SAPLSTRV\FO:CREATE_TREE\SE:BEGIN\EI
ENHANCEMENT 0 /MBTOOLS/BC_CTS_OBJECT_LIST_2.
************************************************************************
* MBT Transport Request
*
* Copyright 2021 Marc Bernard <https://marcbernardtools.com/>
* SPDX-License-Identifier: GPL-3.0-or-later
************************************************************************

  IF /mbtools/cl_switches=>is_active( /mbtools/cl_switches=>c_tool-mbt_transport_request ) = abap_true.

    PERFORM create_tree IN PROGRAM /mbtools/cts_object_list_2
      CHANGING pt_nodes.

  ENDIF.

ENDENHANCEMENT.
