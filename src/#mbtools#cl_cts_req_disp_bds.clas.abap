************************************************************************
* /MBTOOLS/CL_CTS_REQ_DISP_BDS
* MBT Request Display
*
* (c) MBT 2020 https://marcbernardtools.com/
************************************************************************
CLASS /mbtools/cl_cts_req_disp_bds DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPE-POOLS skwfc .

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

    CLASS-DATA:
      go_term TYPE REF TO cl_kwui_terminology .

ENDCLASS.



CLASS /MBTOOLS/CL_CTS_REQ_DISP_BDS IMPLEMENTATION.


  METHOD /mbtools/if_cts_req_display~get_object_descriptions.

    DATA:
      ls_e071_txt TYPE /mbtools/trwbo_s_e071_txt,
      lv_guid     TYPE sdok_docid,
      lv_icon     TYPE icon_d,
      ls_io       TYPE skwf_io,
      lt_io       TYPE TABLE OF skwf_io,
      ls_dspname  TYPE skwf_dspn,
      lt_dspname  TYPE TABLE OF skwf_dspn.

    FIELD-SYMBOLS:
      <ls_e071> TYPE trwbo_s_e071.

    LOOP AT it_e071 ASSIGNING <ls_e071> WHERE object IN gt_object_list.
      CLEAR ls_io.
      ls_io-objid = <ls_e071>-obj_name.

      CASE <ls_e071>-object.
        WHEN 'BLFO'. " BW: LOIO Class Folder
          ls_io-objtype = skwfc_obtype_folder.
          ls_io-class   = 'BW_FLD'.
        WHEN 'BLMA'. " BW: LOIO Class Master Data
          ls_io-objtype = if_rsod_const=>skwf_objtype_l.
          ls_io-class   = if_rsod_const=>loio_class_mast.
        WHEN 'BPMA'. " BW: PHIO Class Master Data
          ls_io-objtype = if_rsod_const=>skwf_objtype_p.
          ls_io-class   = if_rsod_const=>phio_class_mast.
        WHEN 'SBEL'. " BW: LOIO Class Metadata
          ls_io-objtype = if_rsod_const=>skwf_objtype_l.
          ls_io-class   = if_rsod_const=>loio_class_meta.
        WHEN 'SBEP'. " BW: PHIO Class Metadata
          ls_io-objtype = if_rsod_const=>skwf_objtype_p.
          ls_io-class   = if_rsod_const=>phio_class_meta.
        WHEN 'BLTM'. " BW: LOIO Class Web Templates
          ls_io-objtype = if_rsod_const=>skwf_objtype_l.
          ls_io-class   = if_rsod_const=>loio_class_tmpl.
        WHEN 'BPTM'. " BW: PHIO Class Web Templates
          ls_io-objtype = if_rsod_const=>skwf_objtype_p.
          ls_io-class   = if_rsod_const=>phio_class_tmpl.
        WHEN 'SBGL'. " BW: LOIO Class Transaction Data
          ls_io-objtype = if_rsod_const=>skwf_objtype_l.
          ls_io-class   = if_rsod_const=>loio_class_tran.
        WHEN 'SBGP'. " BW: PHIO Class Transaction Data
          ls_io-objtype = if_rsod_const=>skwf_objtype_p.
          ls_io-class   = if_rsod_const=>phio_class_tran.
        WHEN 'SMIM'. " Other MIME objects
          lv_guid = <ls_e071>-obj_name.

          cl_wb_mr_services=>mr_loio_existence_check(
            EXPORTING
              i_loio_id = lv_guid
            IMPORTING
              e_io      = ls_io
            EXCEPTIONS
              not_found = 1 ).
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
      ENDCASE.

      APPEND ls_io TO lt_io.
    ENDLOOP.

    CHECK NOT lt_io IS INITIAL.

    cl_skwf_display_util=>ios_displayname_get(
      EXPORTING
        ios           = lt_io
        x_description = abap_true
      IMPORTING
        disp_names    = lt_dspname ).

    LOOP AT it_e071 ASSIGNING <ls_e071>.
      READ TABLE lt_dspname INTO ls_dspname
        WITH KEY objid = <ls_e071>-obj_name.
      IF sy-subrc = 0.
        CLEAR ls_e071_txt.

        MOVE-CORRESPONDING <ls_e071> TO ls_e071_txt.
        lv_icon = ls_dspname-objtype.

        get_object_icon(
          EXPORTING
            iv_object = <ls_e071>-object
          CHANGING
            cv_icon   = ls_e071_txt-icon ).

        ls_e071_txt-text = ls_dspname-descript.
        ls_e071_txt-name = ls_dspname-name.

        INSERT ls_e071_txt INTO TABLE ct_e071_txt.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD /mbtools/if_cts_req_display~get_object_icon.

    DATA:
      ls_io TYPE skwf_io.

    CASE iv_object.
      WHEN 'BLFO'. " BW: LOIO Class Folder
        ls_io-objtype = skwfc_obtype_folder.
      WHEN 'BLMA'. " BW: LOIO Class Master Data
        ls_io-objtype = skwfc_obtype_loio.
      WHEN 'BPMA'. " BW: PHIO Class Master Data
        ls_io-objtype = skwfc_obtype_phio.
      WHEN 'SBEL'. " BW: LOIO Class Metadata
        ls_io-objtype = skwfc_obtype_loio.
      WHEN 'SBEP'. " BW: PHIO Class Metadata
        ls_io-objtype = skwfc_obtype_phio.
      WHEN 'BLTM'. " BW: LOIO Class Web Templates
        ls_io-objtype = skwfc_obtype_loio.
      WHEN 'BPTM'. " BW: PHIO Class Web Templates
        ls_io-objtype = skwfc_obtype_phio.
      WHEN 'SBGL'. " BW: LOIO Class Transaction Data
        ls_io-objtype = skwfc_obtype_loio.
      WHEN 'SBGP'. " BW: PHIO Class Transaction Data
        ls_io-objtype = skwfc_obtype_phio.
      WHEN 'SMIM'. " Other MIME objects
        IF iv_icon = skwfc_obtype_folder.
          ls_io-objtype = skwfc_obtype_folder.
        ELSE.
          ls_io-objtype = skwfc_obtype_loio.
        ENDIF.
    ENDCASE.

    cv_icon = go_term->get_icon_for_io( p_io = ls_io ).

    IF cv_icon IS INITIAL.
      cv_icon = icon_dummy.
    ENDIF.

  ENDMETHOD.


  METHOD class_constructor.

    DATA:
      ls_object_list LIKE LINE OF gt_object_list.

    CREATE OBJECT go_term.

    ls_object_list-sign   = 'I'.
    ls_object_list-option = 'EQ'.

    ls_object_list-low = 'BLFO'. " BW: LOIO Class Folder
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'BLMA'. " BW: LOIO Class Master Data
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'BPMA'. " BW: PHIO Class Master Data
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'BLTM'. " BW: LOIO Class Web Templates
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'BPTM'. " BW: PHIO Class Web Templates
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SBEL'. " BW: LOIO Class Metadata
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SBEP'. " BW: PHIO Class Metadata
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SBGL'. " BW: LOIO Class Transaction Data
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SBGP'. " BW: PHIO Class Transaction Data
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SMIM'. " Other MIME objects
    APPEND ls_object_list TO gt_object_list.

  ENDMETHOD.
ENDCLASS.
