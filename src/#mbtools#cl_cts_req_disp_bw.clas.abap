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

    TYPE-POOLS: icon, rsd.

    INTERFACES if_badi_interface .
    INTERFACES /mbtools/if_cts_req_display .

    ALIASES get_object_descriptions
      FOR /mbtools/if_cts_req_display~get_object_descriptions .
    ALIASES get_object_icon
      FOR /mbtools/if_cts_req_display~get_object_icon .

    CLASS-DATA:
      nt_object_list TYPE RANGE OF e071-object READ-ONLY .

    CLASS-METHODS class_constructor .

  PROTECTED SECTION.

  PRIVATE SECTION.

    CLASS-DATA p_r_repository TYPE REF TO cl_rso_repository .
    CLASS-DATA p_th_tlogoprop TYPE rso_th_tlogoprop .

ENDCLASS.



CLASS /MBTOOLS/CL_CTS_REQ_DISP_BW IMPLEMENTATION.


  METHOD /mbtools/if_cts_req_display~get_object_descriptions.

    FIELD-SYMBOLS:
      <ls_e071>     TYPE e071.

    DATA:
      l_s_e071_txt  TYPE /mbtools/trwbo_s_e071_txt,
      l_s_object    TYPE rso_s_tlogo,
      l_s_tlogoprop TYPE rstlogoprop,
      l_tlogo       TYPE rstlogo,
      l_objvers     TYPE rsobjvers,
      l_txtlg       TYPE rstxtlg,
      l_icon        TYPE icon_d,
      l_iobjtp      TYPE rsiobjtp,
      l_compid      TYPE rszcompid,
      l_deftp       TYPE rszdeftp,
      l_element     TYPE string,
      l_text        TYPE string.

    LOOP AT it_e071 ASSIGNING <ls_e071> WHERE object IN nt_object_list.
      CLEAR: l_icon, l_txtlg.

      CLEAR l_s_object.
      l_s_object-tlogo = <ls_e071>-object.
      l_s_object-objnm = <ls_e071>-obj_name.

*     Check if content object
      READ TABLE p_th_tlogoprop INTO l_s_tlogoprop
        WITH KEY tlogo_d = l_s_object-tlogo.
      IF sy-subrc = 0.
        l_objvers = rs_c_objvers-delivery.
        l_s_object-tlogo = l_s_tlogoprop-tlogo.
      ELSE.
        l_objvers = rs_c_objvers-active.
      ENDIF.

*     Source system objects
      CASE l_s_object-tlogo.
        WHEN 'DSAA'. " Application component hierarchy
          CALL METHOD get_object_icon
            EXPORTING
              i_object = l_s_object-tlogo
            CHANGING
              r_icon   = l_icon.

          SELECT SINGLE txtlg INTO l_txtlg FROM rodsapplt
            WHERE hier = l_s_object-objnm AND applnm = '000001' AND objvers = l_objvers AND langu = sy-langu.
          IF sy-subrc <> 0.
            SELECT SINGLE txtlg INTO l_txtlg FROM rodsapplt
              WHERE hier = l_s_object-objnm AND applnm = '000001' AND objvers = l_objvers.
          ENDIF.
          IF sy-subrc <> 0.
            l_icon = icon_delete.
          ENDIF.

        WHEN 'OSOA'. " DataSource
          CALL METHOD get_object_icon
            EXPORTING
              i_object = l_s_object-tlogo
            CHANGING
              r_icon   = l_icon.

          SELECT SINGLE txtlg INTO l_txtlg FROM roosourcet
            WHERE oltpsource = l_s_object-objnm AND objvers = l_objvers AND langu = sy-langu.
          IF sy-subrc <> 0.
            SELECT SINGLE txtlg INTO l_txtlg FROM roosourcet
              WHERE oltpsource = l_s_object-objnm AND objvers = l_objvers.
          ENDIF.
          IF sy-subrc <> 0.
            l_icon = icon_delete.
          ENDIF.

        WHEN OTHERS.
*         Get description and icon from BW repository
          CALL METHOD p_r_repository->get_properties_of_object
            EXPORTING
              i_objvers            = l_objvers
              i_s_object           = l_s_object
            IMPORTING
              e_txtlg              = l_txtlg
              e_icon               = l_icon
              e_query_element_type = l_deftp
            EXCEPTIONS
              object_not_found     = 1
              OTHERS               = 2.
          IF sy-subrc = 0.
            CALL METHOD get_object_icon
              EXPORTING
                i_object = l_s_object-tlogo
                i_icon   = l_icon
              CHANGING
                r_icon   = l_icon.
          ELSE.
            l_icon = icon_delete.
          ENDIF.
      ENDCASE.

*     Fill return table
      CLEAR l_s_e071_txt.
      MOVE-CORRESPONDING <ls_e071> TO l_s_e071_txt.
      l_s_e071_txt-icon = l_icon.
      l_s_e071_txt-text = l_txtlg.

      CASE l_s_object-tlogo.
        WHEN rs_c_tlogo-infoobject.
          " Get type of InfoObject
          SELECT SINGLE iobjtp INTO l_iobjtp FROM rsdiobj
            WHERE iobjnm = l_s_object-objnm AND objvers = l_objvers.

          CASE l_iobjtp.
            WHEN rsd_c_objtp-charact.
              l_txtlg = 'Characteristic:'.
            WHEN rsd_c_objtp-keyfigure.
              l_txtlg = 'Key Figure:'.
            WHEN rsd_c_objtp-time.
              l_txtlg = 'Time Characteristic:'.
            WHEN rsd_c_objtp-package.
              l_txtlg = 'Data Packet Characteristic:'.
            WHEN rsd_c_objtp-unit.
              l_txtlg = 'Unit of Measurement:'.
            WHEN rsd_c_objtp-xxl.
              l_txtlg = 'XXL InfoObject:'.
            WHEN OTHERS.
              l_txtlg = ''.
          ENDCASE.
          IF NOT l_txtlg IS INITIAL.
            CONCATENATE l_txtlg l_s_e071_txt-text INTO l_s_e071_txt-text SEPARATED BY space.
          ENDIF.

        WHEN rs_c_tlogo-element.
          " Get technical name for objects based on GUIDs
          SELECT SINGLE compid INTO l_compid FROM rszcompdir
            WHERE compuid = l_s_object-objnm AND objvers = l_objvers.
          IF sy-subrc = 0.
            l_s_e071_txt-name = l_compid.
          ELSE.
            l_s_e071_txt-name = l_s_object-objnm.
          ENDIF.

          CASE l_deftp.
            WHEN rzd1_c_deftp-report.
              l_element = 'Query:'.
            WHEN rzd1_c_deftp-structure.
              l_element = 'Structure:'.
            WHEN rzd1_c_deftp-selection.
              l_element = 'Selection:'.
            WHEN rzd1_c_deftp-calkeyfig.
              l_element = 'Calc. Key Figure:'.
            WHEN rzd1_c_deftp-restkeyfig.
              l_element = 'Rest. Key Figure:'.
            WHEN rzd1_c_deftp-characteristic.
              l_element = 'Characteristic:'.
            WHEN rzd1_c_deftp-formula.
              l_element = 'Formula:'.
            WHEN rzd1_c_deftp-variable.
              l_element = 'Variable:'.
            WHEN rzd1_c_deftp-sel_object.
              l_element = 'Filter:'.
            WHEN rzd1_c_deftp-sheet.
              l_element = 'Sheet:'.
            WHEN rzd1_c_deftp-str_mem OR rzd1_c_deftp-str_mem_inv.
              l_element = 'Structure Member:'.
            WHEN rzd1_c_deftp-cell OR rzd1_c_deftp-cell_inv.
              l_element = 'Cell:'.
            WHEN rzd1_c_deftp-cell.
              l_element = 'Cell:'.
            WHEN rzd1_c_deftp-exception.
              l_element = 'Exception:'.
            WHEN rzd1_c_deftp-condition.
              l_element = 'Condition:'.
            WHEN OTHERS.
              l_element = 'Unkown Type:'.
          ENDCASE.
          IF NOT l_element IS INITIAL.
            CONCATENATE l_element l_s_e071_txt-text INTO l_s_e071_txt-text SEPARATED BY space.
          ENDIF.
        WHEN OTHERS.
          l_s_e071_txt-name = l_s_object-objnm.
      ENDCASE.

      INSERT l_s_e071_txt INTO TABLE ct_e071_txt.
    ENDLOOP.

  ENDMETHOD.


  METHOD /mbtools/if_cts_req_display~get_object_icon.

    DATA:
      l_tlogo       TYPE rstlogo,
      l_s_tlogoprop TYPE rstlogoprop.

    l_tlogo = i_object.

*   Get icon
    IF i_icon IS INITIAL.
      CASE i_object.
        WHEN 'DSAA' OR 'DSAD'. " Application component hierarchy
          CALL METHOD cl_rso_repository=>get_tlogo_icon
            EXPORTING
              i_tlogo = rs_c_tlogo-application
            RECEIVING
              r_icon  = r_icon.

        WHEN 'OSOA' OR 'OSOD'. " DataSource
          CALL METHOD cl_rso_repository=>get_tlogo_icon
            EXPORTING
              i_tlogo = rs_c_tlogo-datasource
            RECEIVING
              r_icon  = r_icon.

        WHEN OTHERS. " Other BW objects
          CALL METHOD cl_rso_repository=>get_tlogo_icon
            EXPORTING
              i_tlogo = l_tlogo
            RECEIVING
              r_icon  = r_icon.
      ENDCASE.
    ELSE.
      r_icon = i_icon.
    ENDIF.

*   Set fallback icon
    IF r_icon IS INITIAL OR r_icon = icon_dummy.
      r_icon = cl_rso_repository=>get_tlogo_icon( l_tlogo ).
    ELSEIF r_icon = icon_content_object.
      READ TABLE p_th_tlogoprop INTO l_s_tlogoprop
        WITH KEY tlogo_d = l_tlogo.
      IF sy-subrc = 0.
        r_icon = cl_rso_repository=>get_tlogo_icon( l_s_tlogoprop-tlogo ).
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD class_constructor.

    DATA:
      l_s_tlogoprop   TYPE rstlogoprop,
      l_s_object_list LIKE LINE OF nt_object_list.

*   Instanciate repository
    IF p_r_repository IS INITIAL.
      CALL METHOD cl_rso_repository=>get_repository
        RECEIVING
          r_r_repository = p_r_repository.
    ENDIF.

*   Get all TLOGO properties
    IF p_th_tlogoprop IS INITIAL.
      SELECT * FROM rstlogoprop INTO TABLE p_th_tlogoprop.

*     Enhancements and DDLs are handled in /MBTOOLS/CL_CTS_REQ_DISP_WB
      DELETE p_th_tlogoprop WHERE tlogo = 'ENHO' OR tlogo = 'DDLS'.

*     Add Application Component Hierarchty and DataSource
      l_s_tlogoprop-tlogo   = 'DSAA'.
      l_s_tlogoprop-tlogo_d = 'DSAD'.
      INSERT l_s_tlogoprop INTO TABLE p_th_tlogoprop.
      l_s_tlogoprop-tlogo   = 'OSOA'.
      l_s_tlogoprop-tlogo_d = 'OSOD'.
      INSERT l_s_tlogoprop INTO TABLE p_th_tlogoprop.
    ENDIF.

    l_s_object_list-sign   = 'I'.
    l_s_object_list-option = 'EQ'.

    LOOP AT p_th_tlogoprop INTO l_s_tlogoprop.
      l_s_object_list-low = l_s_tlogoprop-tlogo.
      APPEND l_s_object_list TO nt_object_list.
      l_s_object_list-low = l_s_tlogoprop-tlogo_d.
      APPEND l_s_object_list TO nt_object_list.
    ENDLOOP.

    DELETE nt_object_list WHERE low IS INITIAL.
    SORT nt_object_list.
    DELETE ADJACENT DUPLICATES FROM nt_object_list.

  ENDMETHOD.
ENDCLASS.
