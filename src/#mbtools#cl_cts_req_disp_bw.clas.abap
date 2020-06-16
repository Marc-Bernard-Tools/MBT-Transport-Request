************************************************************************
* /MBTOOLS/CL_CTS_REQ_DISP_BW
* MBT Request Display
*
* (c) MBT 2020 https://marcbernardtools.com/
************************************************************************
CLASS /mbtools/cl_cts_req_disp_bw DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPE-POOLS rsd .
    TYPE-POOLS sbiw .

    INTERFACES if_badi_interface .
    INTERFACES /mbtools/if_cts_req_display .

    ALIASES get_object_descriptions
      FOR /mbtools/if_cts_req_display~get_object_descriptions .
    ALIASES get_object_icon
      FOR /mbtools/if_cts_req_display~get_object_icon .

    CLASS-DATA:
      gt_object_list TYPE RANGE OF e071-object READ-ONLY .

    CLASS-METHODS class_constructor .
  PROTECTED SECTION.

  PRIVATE SECTION.

    CLASS-DATA go_repository TYPE REF TO cl_rso_repository .
    CLASS-DATA gt_tlogoprop TYPE rso_th_tlogoprop .

ENDCLASS.



CLASS /MBTOOLS/CL_CTS_REQ_DISP_BW IMPLEMENTATION.


  METHOD /mbtools/if_cts_req_display~get_object_descriptions.

    DATA:
      ls_e071_txt  TYPE /mbtools/trwbo_s_e071_txt,
      ls_object    TYPE rso_s_tlogo,
      ls_tlogoprop TYPE rstlogoprop,
      lv_tlogo     TYPE rstlogo,
      lv_objvers   TYPE rsobjvers,
      lv_txtlg     TYPE rstxtlg,
      lv_icon      TYPE icon_d,
      lv_icon_2    TYPE icon_d,
      lv_applnm    TYPE rsapplnm,
      lv_type      TYPE roostype,
      lv_iobjtp    TYPE rsiobjtp,
      lv_compid    TYPE rszcompid,
      lv_deftp     TYPE rszdeftp,
      lv_element   TYPE string,
      lv_text      TYPE string.

    FIELD-SYMBOLS:
      <ls_e071> TYPE e071.

    LOOP AT it_e071 ASSIGNING <ls_e071> WHERE object IN gt_object_list.
      CLEAR: lv_icon, lv_txtlg.

      CLEAR ls_object.
      ls_object-tlogo = <ls_e071>-object.
      ls_object-objnm = <ls_e071>-obj_name.

      " Check if content object
      READ TABLE gt_tlogoprop INTO ls_tlogoprop
        WITH KEY tlogo_d = ls_object-tlogo.
      IF sy-subrc = 0.
        lv_objvers = rs_c_objvers-delivery.
        ls_object-tlogo = ls_tlogoprop-tlogo.
      ELSE.
        lv_objvers = rs_c_objvers-active.
      ENDIF.

      " Source system objects
      CASE ls_object-tlogo.
        WHEN 'DSAA'. " Application component hierarchy
          SELECT SINGLE applnm INTO lv_applnm FROM rodsappl
            WHERE hier LIKE 'APCO%' AND applnm = ls_object-objnm AND objvers = lv_objvers.
          IF sy-subrc <> 0.
            lv_icon = icon_delete.
          ENDIF.

          get_object_icon(
            EXPORTING
              iv_object = ls_object-tlogo
            CHANGING
              cv_icon   = lv_icon ).

          SELECT SINGLE txtlg INTO lv_txtlg FROM rodsapplt
            WHERE hier LIKE 'APCO%' AND applnm = ls_object-objnm AND objvers = lv_objvers AND langu = sy-langu.
          IF sy-subrc <> 0.
            SELECT SINGLE txtlg INTO lv_txtlg FROM rodsapplt
              WHERE hier LIKE 'APCO%' AND applnm = ls_object-objnm AND objvers = lv_objvers.
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
              WHERE oltpsource = ls_object-objnm AND objvers = lv_objvers.
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
              lv_txtlg = 'Characteristic'.
            WHEN rsd_c_objtp-keyfigure.
              lv_txtlg = 'Key Figure'.
            WHEN rsd_c_objtp-time.
              lv_txtlg = 'Time Characteristic'.
            WHEN rsd_c_objtp-package.
              lv_txtlg = 'Data Packet Characteristic'.
            WHEN rsd_c_objtp-unit.
              lv_txtlg = 'Unit of Measurement'.
            WHEN rsd_c_objtp-xxl.
              lv_txtlg = 'XXL InfoObject'.
            WHEN OTHERS.
              lv_txtlg = 'Unknown InfoObject Type'.
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
              lv_element = 'Query'.
            WHEN rzd1_c_deftp-structure.
              lv_element = 'Structure'.
            WHEN rzd1_c_deftp-selection.
              lv_element = 'Selection'.
            WHEN rzd1_c_deftp-calkeyfig.
              lv_element = 'Calc. Key Figure'.
            WHEN rzd1_c_deftp-restkeyfig.
              lv_element = 'Rest. Key Figure'.
            WHEN rzd1_c_deftp-characteristic.
              lv_element = 'Characteristic'.
            WHEN rzd1_c_deftp-formula.
              lv_element = 'Formula'.
            WHEN rzd1_c_deftp-variable.
              lv_element = 'Variable'.
            WHEN rzd1_c_deftp-sel_object.
              lv_element = 'Filter'.
            WHEN rzd1_c_deftp-sheet.
              lv_element = 'Sheet'.
            WHEN rzd1_c_deftp-str_mem OR rzd1_c_deftp-str_mem_inv.
              lv_element = 'Structure Member'.
            WHEN rzd1_c_deftp-cell OR rzd1_c_deftp-cell_inv.
              lv_element = 'Cell'.
            WHEN rzd1_c_deftp-cell.
              lv_element = 'Cell'.
            WHEN rzd1_c_deftp-exception.
              lv_element = 'Exception'.
            WHEN rzd1_c_deftp-condition.
              lv_element = 'Condition'.
            WHEN OTHERS.
              lv_element = 'Unkown Element Type'.
          ENDCASE.
          ls_e071_txt-text = |{ lv_element }: { ls_e071_txt-text }|.
        WHEN OTHERS.
          ls_e071_txt-name = ls_object-objnm.
      ENDCASE.

      INSERT ls_e071_txt INTO TABLE ct_e071_txt.
    ENDLOOP.

  ENDMETHOD.


  METHOD /mbtools/if_cts_req_display~get_object_icon.

    DATA:
      lv_tlogo TYPE rstlogo.

    lv_tlogo = iv_object.

    cv_icon = /mbtools/cl_tlogo=>get_tlogo_icon( iv_tlogo     = lv_tlogo
                                                 iv_tlogo_sub = iv_obj_type
                                                 iv_icon      = iv_icon ).

  ENDMETHOD.


  METHOD class_constructor.

    DATA:
      ls_tlogoprop   TYPE rstlogoprop,
      ls_object_list LIKE LINE OF gt_object_list.

    FIELD-SYMBOLS:
      <ls_tlogoprop> TYPE rstlogoprop.

    " Instanciate repository
    IF go_repository IS INITIAL.
      go_repository = cl_rso_repository=>get_repository( ).
    ENDIF.

    " Get all TLOGO properties
    IF gt_tlogoprop IS INITIAL.
      SELECT * FROM rstlogoprop INTO TABLE gt_tlogoprop.

      " Enhancements and DDLs are handled in /MBTOOLS/CL_CTS_REQ_DISP_WB
      DELETE gt_tlogoprop WHERE tlogo = 'ENHO' OR tlogo = 'DDLS'.

      " Add Application Component Hierarchty and DataSource
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
