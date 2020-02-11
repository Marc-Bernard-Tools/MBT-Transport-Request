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

*"* public components of class /MBTOOLS/CL_CTS_REQ_DISP_BDS
*"* do not include other source files here!!!
  PUBLIC SECTION.
    TYPE-POOLS skwfc .

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
*"* protected components of class /MBTOOLS/CL_CTS_REQ_DISP_BDS
*"* do not include other source files here!!!
  PRIVATE SECTION.

    CLASS-DATA p_r_term TYPE REF TO cl_kwui_terminology .
ENDCLASS.



CLASS /MBTOOLS/CL_CTS_REQ_DISP_BDS IMPLEMENTATION.


  METHOD /mbtools/if_cts_req_display~get_object_descriptions.

    FIELD-SYMBOLS:
      <ls_e071>    TYPE trwbo_s_e071.

    DATA:
      l_s_e071_txt TYPE /mbtools/trwbo_s_e071_txt,
      l_guid       TYPE sdok_docid,
      l_icon       TYPE icon_d,
      l_s_io       TYPE skwf_io,
      l_t_io       TYPE TABLE OF skwf_io,
      l_s_dspname  TYPE skwf_dspn,
      l_t_dspname  TYPE TABLE OF skwf_dspn.

    LOOP AT it_e071 ASSIGNING <ls_e071> WHERE object IN nt_object_list.
      CLEAR l_s_io.
      l_s_io-objid = <ls_e071>-obj_name.

      CASE <ls_e071>-object.
        WHEN 'BLFO'. " BW: LOIO Class Folder
          l_s_io-objtype = skwfc_obtype_folder.
          l_s_io-class   = 'BW_FLD'.
        WHEN 'BLMA'. " BW: LOIO Class Master Data
          l_s_io-objtype = if_rsod_const=>skwf_objtype_l.
          l_s_io-class   = if_rsod_const=>loio_class_mast.
        WHEN 'BPMA'. " BW: PHIO Class Master Data
          l_s_io-objtype = if_rsod_const=>skwf_objtype_p.
          l_s_io-class   = if_rsod_const=>phio_class_mast.
        WHEN 'SBEL'. " BW: LOIO Class Metadata
          l_s_io-objtype = if_rsod_const=>skwf_objtype_l.
          l_s_io-class   = if_rsod_const=>loio_class_meta.
        WHEN 'SBEP'. " BW: PHIO Class Metadata
          l_s_io-objtype = if_rsod_const=>skwf_objtype_p.
          l_s_io-class   = if_rsod_const=>phio_class_meta.
        WHEN 'BLTM'. " BW: LOIO Class Web Templates
          l_s_io-objtype = if_rsod_const=>skwf_objtype_l.
          l_s_io-class   = if_rsod_const=>loio_class_tmpl.
        WHEN 'BPTM'. " BW: PHIO Class Web Templates
          l_s_io-objtype = if_rsod_const=>skwf_objtype_p.
          l_s_io-class   = if_rsod_const=>phio_class_tmpl.
        WHEN 'SBGL'. " BW: LOIO Class Transaction Data
          l_s_io-objtype = if_rsod_const=>skwf_objtype_l.
          l_s_io-class   = if_rsod_const=>loio_class_tran.
        WHEN 'SBGP'. " BW: PHIO Class Transaction Data
          l_s_io-objtype = if_rsod_const=>skwf_objtype_p.
          l_s_io-class   = if_rsod_const=>phio_class_tran.
        WHEN 'SMIM'. " Other MIME objects
          l_guid = <ls_e071>-obj_name.

          CALL METHOD cl_wb_mr_services=>mr_loio_existence_check
            EXPORTING
              i_loio_id = l_guid
            IMPORTING
              e_io      = l_s_io
            EXCEPTIONS
              not_found = 1.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
      ENDCASE.

      APPEND l_s_io TO l_t_io.
    ENDLOOP.

    CHECK NOT l_t_io IS INITIAL.

    CALL METHOD cl_skwf_display_util=>ios_displayname_get
      EXPORTING
        ios           = l_t_io
        x_description = abap_true
      IMPORTING
        disp_names    = l_t_dspname.

    LOOP AT it_e071 ASSIGNING <ls_e071>.
      READ TABLE l_t_dspname INTO l_s_dspname
        WITH KEY objid = <ls_e071>-obj_name.
      IF sy-subrc = 0.
        CLEAR l_s_e071_txt.

        MOVE-CORRESPONDING <ls_e071> TO l_s_e071_txt.
        l_icon = l_s_dspname-objtype.

        CALL METHOD get_object_icon
          EXPORTING
            i_object = l_s_e071_txt-object
            i_icon   = l_icon
          CHANGING
            r_icon   = l_s_e071_txt-icon.

        l_s_e071_txt-text = l_s_dspname-descript.
        l_s_e071_txt-name = l_s_dspname-name.

        INSERT l_s_e071_txt INTO TABLE ct_e071_txt.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD /mbtools/if_cts_req_display~get_object_icon.

    DATA l_s_io TYPE skwf_io.

    CASE i_object.
      WHEN 'BLFO'. " BW: LOIO Class Folder
        l_s_io-objtype = skwfc_obtype_folder.
      WHEN 'BLMA'. " BW: LOIO Class Master Data
        l_s_io-objtype = skwfc_obtype_loio.
      WHEN 'BPMA'. " BW: PHIO Class Master Data
        l_s_io-objtype = skwfc_obtype_phio.
      WHEN 'SBEL'. " BW: LOIO Class Metadata
        l_s_io-objtype = skwfc_obtype_loio.
      WHEN 'SBEP'. " BW: PHIO Class Metadata
        l_s_io-objtype = skwfc_obtype_phio.
      WHEN 'BLTM'. " BW: LOIO Class Web Templates
        l_s_io-objtype = skwfc_obtype_loio.
      WHEN 'BPTM'. " BW: PHIO Class Web Templates
        l_s_io-objtype = skwfc_obtype_phio.
      WHEN 'SBGL'. " BW: LOIO Class Transaction Data
        l_s_io-objtype = skwfc_obtype_loio.
      WHEN 'SBGP'. " BW: PHIO Class Transaction Data
        l_s_io-objtype = skwfc_obtype_phio.
      WHEN 'SMIM'. " Other MIME objects
        IF i_icon = skwfc_obtype_folder.
          l_s_io-objtype = skwfc_obtype_folder.
        ELSE.
          l_s_io-objtype = skwfc_obtype_loio.
        ENDIF.
    ENDCASE.

    r_icon = p_r_term->get_icon_for_io( p_io = l_s_io ).

    IF r_icon IS INITIAL.
      r_icon = icon_dummy.
    ENDIF.

  ENDMETHOD.


  METHOD class_constructor.

    DATA ls_object_list LIKE LINE OF nt_object_list.

    CREATE OBJECT p_r_term.

    ls_object_list-sign   = 'I'.
    ls_object_list-option = 'EQ'.

    ls_object_list-low = 'BLFO'. " BW: LOIO Class Folder
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'BLMA'. " BW: LOIO Class Master Data
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'BPMA'. " BW: PHIO Class Master Data
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'BLTM'. " BW: LOIO Class Web Templates
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'BPTM'. " BW: PHIO Class Web Templates
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'SBEL'. " BW: LOIO Class Metadata
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'SBEP'. " BW: PHIO Class Metadata
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'SBGL'. " BW: LOIO Class Transaction Data
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'SBGP'. " BW: PHIO Class Transaction Data
    APPEND ls_object_list TO nt_object_list.
    ls_object_list-low = 'SMIM'. " Other MIME objects
    APPEND ls_object_list TO nt_object_list.

  ENDMETHOD.
ENDCLASS.
