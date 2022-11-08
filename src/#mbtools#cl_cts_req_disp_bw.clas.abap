CLASS /mbtools/cl_cts_req_disp_bw DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

************************************************************************
* MBT Transport Request - SAP BW
*
* Copyright 2021 Marc Bernard <https://marcbernardtools.com/>
* SPDX-License-Identifier: GPL-3.0-only
************************************************************************
  PUBLIC SECTION.

    INTERFACES if_badi_interface.
    INTERFACES /mbtools/if_cts_req_display.

    ALIASES get_object_descriptions
      FOR /mbtools/if_cts_req_display~get_object_descriptions.
    ALIASES get_object_icon
      FOR /mbtools/if_cts_req_display~get_object_icon.

    CLASS-DATA gt_object_list TYPE RANGE OF e071-object READ-ONLY.

    CLASS-METHODS class_constructor.
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA go_repository TYPE REF TO cl_rso_repository.
    CLASS-DATA gt_tlogoprop TYPE rso_th_tlogoprop.

ENDCLASS.



CLASS /mbtools/cl_cts_req_disp_bw IMPLEMENTATION.


  METHOD /mbtools/if_cts_req_display~get_object_descriptions.

    DATA:
      ls_e071_txt  TYPE /mbtools/trwbo_s_e071_txt,
      ls_object    TYPE rso_s_tlogo,
      ls_tlogoprop TYPE rstlogoprop,
      lv_objvers   TYPE rsobjvers,
      lv_txtlg     TYPE rstxtlg,
      lv_icon      TYPE icon_d,
      lv_icon_2    TYPE icon_d,
      lv_applnm    TYPE rsapplnm,
      lv_type      TYPE roostype,
      lv_iobjtp    TYPE rsiobjtp,
      lv_compid    TYPE rszcompid,
      lv_deftp     TYPE rszdeftp,
      lv_element   TYPE string.

    FIELD-SYMBOLS <ls_e071> TYPE e071.

    LOOP AT it_e071 ASSIGNING <ls_e071> WHERE object IN gt_object_list.
      CLEAR: lv_icon, lv_txtlg.

      CLEAR ls_object.
      ls_object-tlogo = <ls_e071>-object.
      ls_object-objnm = <ls_e071>-obj_name.

      " Check if content object
      READ TABLE gt_tlogoprop INTO ls_tlogoprop
        WITH KEY tlogo_d = ls_object-tlogo.             "#EC CI_HASHSEQ
      IF sy-subrc = 0.
        lv_objvers = rs_c_objvers-delivery.
        ls_object-tlogo = ls_tlogoprop-tlogo.
      ELSE.
        lv_objvers = rs_c_objvers-active.
      ENDIF.

      " Source system objects
      CASE ls_object-tlogo.
        WHEN 'BIMO'. " BI Meta (Transport) Object Type
          get_object_icon(
            EXPORTING
              iv_object = ls_object-tlogo
            CHANGING
              cv_icon   = lv_icon ).

          lv_txtlg = /mbtools/cl_tlogo=>get_tlogo_text( |{ ls_object-objnm }| ).

        WHEN 'PCLA'. " Program Class for BW Generation Tools
          get_object_icon(
            EXPORTING
              iv_object = ls_object-tlogo
            CHANGING
              cv_icon   = lv_icon ).

          SELECT SINGLE title INTO lv_txtlg FROM rssgtpclat
            WHERE langu = sy-langu AND progclass = ls_object-objnm.

        WHEN 'DSAA'. " Application component hierarchy
          SELECT SINGLE applnm INTO lv_applnm FROM rodsappl
            WHERE hier LIKE 'APCO%' AND applnm = ls_object-objnm AND objvers = lv_objvers ##WARN_OK.
          IF sy-subrc <> 0.
            lv_icon = icon_delete.
          ENDIF.

          get_object_icon(
            EXPORTING
              iv_object = ls_object-tlogo
            CHANGING
              cv_icon   = lv_icon ).

          SELECT SINGLE txtlg INTO lv_txtlg FROM rodsapplt
            WHERE hier LIKE 'APCO%' AND applnm = ls_object-objnm
              AND objvers = lv_objvers AND langu = sy-langu ##WARN_OK.
          IF sy-subrc <> 0.
            SELECT SINGLE txtlg INTO lv_txtlg FROM rodsapplt
              WHERE hier LIKE 'APCO%' AND applnm = ls_object-objnm
                AND objvers = lv_objvers ##WARN_OK.     "#EC CI_NOFIRST
          ENDIF.

        WHEN 'OSOA'. " OLTP DataSource
          SELECT SINGLE type INTO lv_type FROM roosource
            WHERE oltpsource = ls_object-objnm AND objvers = lv_objvers.
          IF sy-subrc <> 0.
            lv_icon = icon_delete.
          ENDIF.

          get_object_icon(
            EXPORTING
              iv_object   = ls_object-tlogo
              iv_obj_type = lv_type
            CHANGING
              cv_icon     = lv_icon ).

          SELECT SINGLE txtlg INTO lv_txtlg FROM roosourcet
            WHERE oltpsource = ls_object-objnm AND objvers = lv_objvers AND langu = sy-langu.
          IF sy-subrc <> 0.
            SELECT SINGLE txtlg INTO lv_txtlg FROM roosourcet
              WHERE oltpsource = ls_object-objnm AND objvers = lv_objvers ##WARN_OK.
          ENDIF.

        WHEN OTHERS.
          " Get description and icon from BW repository
          go_repository->get_properties_of_object(
            EXPORTING
              i_objvers            = lv_objvers
              i_s_object           = ls_object
            IMPORTING
              e_txtlg              = lv_txtlg
              e_icon               = lv_icon
              e_query_element_type = lv_deftp
              e_iobjtp             = lv_iobjtp
            EXCEPTIONS
              object_not_found     = 1
              OTHERS               = 2 ).
          IF sy-subrc = 0.
            lv_icon_2 = lv_icon.

            get_object_icon(
              EXPORTING
                iv_object = ls_object-tlogo
                iv_icon   = lv_icon_2
              CHANGING
                cv_icon   = lv_icon ).
          ELSE.
            lv_icon = icon_delete.
          ENDIF.
      ENDCASE.

      " Fill return table
      CLEAR ls_e071_txt.
      MOVE-CORRESPONDING <ls_e071> TO ls_e071_txt.
      ls_e071_txt-icon = lv_icon.
      ls_e071_txt-text = lv_txtlg.

      CASE ls_object-tlogo.
        WHEN rs_c_tlogo-infoobject.
          CASE lv_iobjtp.
            WHEN rsd_c_objtp-charact.
              lv_txtlg = 'Characteristic'(001).
            WHEN rsd_c_objtp-keyfigure.
              lv_txtlg = 'Key Figure'(002).
            WHEN rsd_c_objtp-time.
              lv_txtlg = 'Time Characteristic'(003).
            WHEN rsd_c_objtp-package.
              lv_txtlg = 'Data Packet Characteristic'(004).
            WHEN rsd_c_objtp-unit.
              lv_txtlg = 'Unit of Measurement'(005).
            WHEN 'XXL'. "rsd_c_objtp-xxl.
              lv_txtlg = 'XXL InfoObject'(006).
            WHEN OTHERS.
              lv_txtlg = 'Unknown InfoObject Type'(007).
          ENDCASE.
          ls_e071_txt-text = |{ lv_txtlg }: { ls_e071_txt-text }|.

        WHEN rs_c_tlogo-element.
          " Get technical name for objects based on GUIDs
          SELECT SINGLE compid INTO lv_compid FROM rszcompdir
            WHERE compuid = ls_object-objnm AND objvers = lv_objvers.
          IF sy-subrc = 0.
            ls_e071_txt-name = lv_compid.
          ELSE.
            ls_e071_txt-name = ls_object-objnm.
          ENDIF.

          CASE lv_deftp.
            WHEN rzd1_c_deftp-report.
              lv_element = 'Query'(008).
            WHEN rzd1_c_deftp-structure.
              lv_element = 'Structure'(009).
            WHEN rzd1_c_deftp-selection.
              lv_element = 'Selection'(010).
            WHEN rzd1_c_deftp-calkeyfig.
              lv_element = 'Calc. Key Figure'(011).
            WHEN rzd1_c_deftp-restkeyfig.
              lv_element = 'Rest. Key Figure'(012).
            WHEN rzd1_c_deftp-characteristic.
              lv_element = 'Characteristic'(001).
            WHEN rzd1_c_deftp-formula.
              lv_element = 'Formula'(013).
            WHEN rzd1_c_deftp-variable.
              lv_element = 'Variable'(014).
            WHEN rzd1_c_deftp-sel_object.
              lv_element = 'Filter'(015).
            WHEN rzd1_c_deftp-sheet.
              lv_element = 'Sheet'(016).
            WHEN rzd1_c_deftp-str_mem OR rzd1_c_deftp-str_mem_inv.
              lv_element = 'Structure Member'(017).
            WHEN rzd1_c_deftp-cell OR rzd1_c_deftp-cell_inv.
              lv_element = 'Cell'(018).
            WHEN rzd1_c_deftp-exception.
              lv_element = 'Exception'(019).
            WHEN rzd1_c_deftp-condition.
              lv_element = 'Condition'(020).
            WHEN OTHERS.
              lv_element = 'Unkown Element Type'(021).
          ENDCASE.
          ls_e071_txt-text = |{ lv_element }: { ls_e071_txt-text }|.
        WHEN OTHERS.
          ls_e071_txt-name = ls_object-objnm.
      ENDCASE.

      INSERT ls_e071_txt INTO TABLE ct_e071_txt.
    ENDLOOP.

  ENDMETHOD.


  METHOD /mbtools/if_cts_req_display~get_object_icon.

    DATA lv_tlogo TYPE rstlogo.

    lv_tlogo = iv_object.

    cv_icon = /mbtools/cl_tlogo=>get_tlogo_icon( iv_tlogo     = lv_tlogo
                                                 iv_tlogo_sub = iv_obj_type
                                                 iv_icon      = iv_icon ).

  ENDMETHOD.


  METHOD class_constructor.

    DATA:
      ls_tlogoprop   TYPE rstlogoprop,
      ls_object_list LIKE LINE OF gt_object_list.

    FIELD-SYMBOLS <ls_tlogoprop> TYPE rstlogoprop.

    " Instanciate repository
    IF go_repository IS INITIAL.
      go_repository = cl_rso_repository=>get_repository( ).
    ENDIF.

    " Get all TLOGO properties
    IF gt_tlogoprop IS INITIAL.
      SELECT * FROM rstlogoprop INTO TABLE gt_tlogoprop.
      ASSERT sy-subrc = 0.

      " Enhancements and DDLs are handled in /MBTOOLS/CL_CTS_REQ_DISP_WB
      DELETE gt_tlogoprop WHERE tlogo = 'ENHO' OR tlogo = 'DDLS'. "#EC CI_HASHSEQ

      " Add Meta Object, Program Class, Application Component Hierarchty, and DataSource
      ls_tlogoprop-tlogo   = 'BIMO'.
      ls_tlogoprop-tlogo_d = ''.
      INSERT ls_tlogoprop INTO TABLE gt_tlogoprop.
      ls_tlogoprop-tlogo   = 'PCLA'.
      ls_tlogoprop-tlogo_d = ''.
      INSERT ls_tlogoprop INTO TABLE gt_tlogoprop.
      ls_tlogoprop-tlogo   = 'DSAA'.
      ls_tlogoprop-tlogo_d = 'DSAD'.
      INSERT ls_tlogoprop INTO TABLE gt_tlogoprop.
      ls_tlogoprop-tlogo   = 'OSOA'.
      ls_tlogoprop-tlogo_d = 'OSOD'.
      INSERT ls_tlogoprop INTO TABLE gt_tlogoprop.
    ENDIF.

    ls_object_list-sign   = 'I'.
    ls_object_list-option = 'EQ'.

    LOOP AT gt_tlogoprop ASSIGNING <ls_tlogoprop>.
      ls_object_list-low = <ls_tlogoprop>-tlogo.
      APPEND ls_object_list TO gt_object_list.

      IF <ls_tlogoprop>-tlogo_d = <ls_tlogoprop>-tlogo.
        CLEAR <ls_tlogoprop>-tlogo_d.
      ELSE.
        ls_object_list-low = <ls_tlogoprop>-tlogo_d.
        APPEND ls_object_list TO gt_object_list.
      ENDIF.
    ENDLOOP.

    DELETE gt_object_list WHERE low IS INITIAL.
    SORT gt_object_list.
    DELETE ADJACENT DUPLICATES FROM gt_object_list.

  ENDMETHOD.
ENDCLASS.
