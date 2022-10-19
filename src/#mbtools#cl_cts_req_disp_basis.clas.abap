CLASS /mbtools/cl_cts_req_disp_basis DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

************************************************************************
* MBT Transport Request - SAP Basis
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

    CLASS-DATA:
      gt_object_list TYPE RANGE OF e071-object READ-ONLY.

    CLASS-METHODS class_constructor.

  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_dokclass,
        dokclass  TYPE doku_class,
        dokdescr1 TYPE doku_descr,
      END OF ty_dokclass.

    CLASS-DATA:
      gt_dokclass TYPE HASHED TABLE OF ty_dokclass WITH UNIQUE KEY dokclass.

    CLASS-METHODS get_variant_text
      IMPORTING
        !iv_obj_name     TYPE csequence
      RETURNING
        VALUE(rv_result) TYPE ddtext.

    CLASS-METHODS get_documentation_text
      IMPORTING
        !iv_object       TYPE csequence
        !iv_obj_name     TYPE csequence
      RETURNING
        VALUE(rv_result) TYPE ddtext.

ENDCLASS.



CLASS /mbtools/cl_cts_req_disp_basis IMPLEMENTATION.


  METHOD /mbtools/if_cts_req_display~get_object_descriptions.

    DATA:
      lv_len        TYPE i,
      lv_tabname    TYPE tabname,
      lv_subrc      TYPE sy-subrc,
      lv_objectname TYPE objh-objectname,
      lv_objecttype TYPE objh-objecttype,
      ls_objt       TYPE objt,
      lv_objt       TYPE c LENGTH 1,
      lv_obj_type   TYPE trobjtype,
      lv_obj_name   TYPE sobj_name,
      ls_e071_txt   TYPE /mbtools/trwbo_s_e071_txt.

    FIELD-SYMBOLS:
      <ls_e071> TYPE trwbo_s_e071.

    LOOP AT it_e071 ASSIGNING <ls_e071> WHERE object IN gt_object_list.
      CLEAR ls_e071_txt.
      MOVE-CORRESPONDING <ls_e071> TO ls_e071_txt.

      get_object_icon(
        EXPORTING
          iv_object = <ls_e071>-object
        CHANGING
          cv_icon   = ls_e071_txt-icon ).

      ls_e071_txt-name = <ls_e071>-obj_name.

      CASE <ls_e071>-object.
        WHEN 'SICF'. " ICF Service
          SELECT SINGLE icf_docu FROM icfdocu INTO ls_e071_txt-text
            WHERE icf_name   = <ls_e071>-obj_name(15)
              AND icfparguid = <ls_e071>-obj_name+15(25)
              AND icf_langu  = sy-langu.
        WHEN 'TOBJ' OR 'OBJM'. " Transport object or AIM
          lv_len = strlen( <ls_e071>-obj_name ) - 1.
          lv_objectname = <ls_e071>-obj_name(lv_len).
          lv_objecttype = <ls_e071>-obj_name+lv_len(1).

          CALL FUNCTION 'CTO_OBJECT_GET_DDIC_TEXT'
            EXPORTING
              iv_objectname        = lv_objectname
              iv_objecttype        = lv_objecttype
              iv_language          = sy-langu
            IMPORTING
              es_objt              = ls_objt
              ev_objt_doesnt_exist = lv_objt.

          IF lv_objt IS INITIAL.
            ls_e071_txt-text = ls_objt-ddtext.
          ELSE.
            SELECT SINGLE ddtext FROM objt INTO ls_e071_txt-text
              WHERE language   = sy-langu
                AND objectname = lv_objectname
                AND objecttype = lv_objecttype.
          ENDIF.
        WHEN 'OBJA'. " After import method (api)
          lv_tabname = 'SLAPITX'.
          SELECT SINGLE description FROM (lv_tabname) INTO ls_e071_txt-text
            WHERE language = sy-langu
              AND api_id   = <ls_e071>-obj_name.

        WHEN 'DOCU' " Documentation
          OR 'DOCT' " General Text
          OR 'DOCV' " Documentation (Independent)
          OR 'DSYS'. " Chapter of a Book Structure
          ls_e071_txt-text = get_documentation_text(
            iv_object   = <ls_e071>-object
            iv_obj_name = <ls_e071>-obj_name ).
        WHEN 'NSPC'. " Namespace
          SELECT SINGLE descriptn FROM trnspacett INTO ls_e071_txt-text
            WHERE spras     = sy-langu
              AND namespace = <ls_e071>-obj_name.
        WHEN 'CDAT'. " View Cluster Maintenance: Data
          lv_objectname = <ls_e071>-obj_name.
          lv_objecttype = <ls_e071>-object(1).

          CALL FUNCTION 'CTO_OBJECT_GET_DDIC_TEXT'
            EXPORTING
              iv_objectname        = lv_objectname
              iv_objecttype        = lv_objecttype
              iv_language          = sy-langu
            IMPORTING
              es_objt              = ls_objt
              ev_objt_doesnt_exist = lv_objt.

          IF lv_objt IS INITIAL.
            ls_e071_txt-text = ls_objt-ddtext.
          ENDIF.
        WHEN 'TDAT'. " Customizing: Table Contents
          SELECT SINGLE ddtext FROM objt INTO ls_e071_txt-text
            WHERE language   = sy-langu
              AND objectname = <ls_e071>-obj_name
              AND objecttype = 'T'.
        WHEN 'STCS'. " Task List
          SELECT SINGLE descr FROM stc_scn_hdr_t INTO ls_e071_txt-text
            WHERE langu       = sy-langu
              AND scenario_id = <ls_e071>-obj_name.
        WHEN 'BMFR'. " Application component
          SELECT SINGLE name FROM df14t INTO ls_e071_txt-text
            WHERE langu    = sy-langu
              AND addon    = ''
              AND fctr_id  = <ls_e071>-obj_name
              AND as4local = 'A'.
        WHEN 'AOBJ'. " Archiving object
          SELECT SINGLE objtext FROM arch_txt INTO ls_e071_txt-text
            WHERE langu  = sy-langu
              AND object = <ls_e071>-obj_name.
        WHEN 'AVAS'. " Classification
          SELECT SINGLE trobjtype sobj_name FROM cls_assignment
            INTO (lv_obj_type, lv_obj_name)
            WHERE guid = <ls_e071>-obj_name ##WARN_OK.
          IF sy-subrc = 0.
            CONCATENATE lv_obj_type lv_obj_name INTO ls_e071_txt-text
              SEPARATED BY space.
          ENDIF.
        WHEN 'SFBF' OR 'SFB2'. " Business Function
          SELECT SINGLE name80 FROM sfw_bft INTO ls_e071_txt-text
            WHERE spras     = sy-langu
              AND bfunction = <ls_e071>-obj_name.
        WHEN 'SFBS' OR 'SFB1'. " Business Set
          SELECT SINGLE name80 FROM sfw_bst INTO ls_e071_txt-text
            WHERE spras = sy-langu
              AND bset  = <ls_e071>-obj_name.
        WHEN 'SFSW'. " Switch
          SELECT SINGLE name80 FROM sfw_switcht INTO ls_e071_txt-text
            WHERE spras     = sy-langu
              AND switch_id = <ls_e071>-obj_name.
        WHEN 'WGRP'. " Object Type Group
          SELECT SINGLE group_name FROM objtypegroups_t INTO ls_e071_txt-text
            WHERE language      = sy-langu
              AND objtype_group = <ls_e071>-obj_name
              AND ai_version    = 'A'.
        WHEN 'CUS0'. " IMG Activity
          SELECT SINGLE text FROM cus_imgact INTO ls_e071_txt-text
            WHERE spras    = sy-langu
              AND activity = <ls_e071>-obj_name.
        WHEN 'CUS1'. " Customizing Activity
          SELECT SINGLE text FROM cus_actt INTO ls_e071_txt-text
            WHERE spras  = sy-langu
              AND act_id = <ls_e071>-obj_name.
        WHEN 'CUS2'. " Customizing Attributes
          SELECT SINGLE text FROM cus_atrt INTO ls_e071_txt-text
            WHERE spras   = sy-langu
              AND attr_id = <ls_e071>-obj_name.
        WHEN 'NROB'. " Number Range
          SELECT SINGLE txt FROM tnrot INTO ls_e071_txt-text
            WHERE object = <ls_e071>-obj_name
              AND langu  = sy-langu.
        WHEN 'JOBD'. " Job Definition
          lv_tabname = 'STJR_JOBD_ROOT'.

          CALL FUNCTION 'DB_EXISTS_TABLE'
            EXPORTING
              tabname = lv_tabname
            IMPORTING
              subrc   = lv_subrc.

          IF lv_subrc = 0.
            SELECT SINGLE btcjob_name FROM (lv_tabname) INTO ls_e071_txt-text
              WHERE name = <ls_e071>-obj_name.
          ENDIF.
        WHEN 'WAPP'. " BSP Page
          SELECT SINGLE descript FROM o2pagdirt INTO ls_e071_txt-text
            WHERE applname = <ls_e071>-obj_name(30)
              AND pagekey  = <ls_e071>-obj_name+30(*)
              AND langu    = sy-langu.
        WHEN 'VCLS'. " View Cluster
          SELECT SINGLE text FROM vcldirt INTO ls_e071_txt-text
            WHERE vclname = <ls_e071>-obj_name
              AND spras   = sy-langu.
        WHEN 'VARI' OR 'VARX'. " Variants
          ls_e071_txt-text = get_variant_text( <ls_e071>-obj_name ).
        WHEN 'SUSC'. " Authorization object class
          SELECT SINGLE ctext FROM tobct INTO ls_e071_txt-text
            WHERE oclss = <ls_e071>-obj_name
              AND langu = sy-langu.
        WHEN 'W3HT'. " WWW HTML Templates
          SELECT SINGLE text FROM wwwdata INTO ls_e071_txt-text
            WHERE relid = 'HT'
              AND objid = <ls_e071>-obj_name
              AND srtf2 = 0.
        WHEN 'W3MI'. " WWW Mime
          SELECT SINGLE text FROM wwwdata INTO ls_e071_txt-text
            WHERE relid = 'MI'
              AND objid = <ls_e071>-obj_name
              AND srtf2 = 0.
        WHEN 'AVAR'. " Activation Variants
          SELECT SINGLE descript FROM aab_var_propt INTO ls_e071_txt-text
            WHERE name = <ls_e071>-obj_name
              AND local = ''
              AND langu = sy-langu.
        WHEN 'SHI5'. " Gen. hierarchy storage extrension name
          SELECT SINGLE text FROM ttree_extt INTO ls_e071_txt-text
            WHERE extension = <ls_e071>-obj_name
              AND spras     = sy-langu.

        WHEN OTHERS.
          ASSERT 0 = 1. " Check class constructor
      ENDCASE.

      INSERT ls_e071_txt INTO TABLE ct_e071_txt.
    ENDLOOP.

  ENDMETHOD.


  METHOD /mbtools/if_cts_req_display~get_object_icon.

    CASE iv_object.
      WHEN 'SICF'. " ICF Service
        cv_icon = icon_wf_reserve_workitem.
      WHEN 'TOBJ' OR 'OBJA' OR 'OBJM'. " Transport object & AIM
        cv_icon = icon_transport.
      WHEN 'DOCU'. " Documentation
        cv_icon = icon_document.
      WHEN 'DOCT'. " General Text
        cv_icon = icon_display_text.
      WHEN 'DOCV'. " Documentation (Independent)
        cv_icon = icon_document.
      WHEN 'DSYS'. " Chapter of a Book Structure
        cv_icon = icon_document.
      WHEN 'NSPC'. " Namespace
        cv_icon = icon_abc.
      WHEN 'CDAT'. " View Cluster Maintenance: Data
        cv_icon = icon_database_table_ina.
      WHEN 'TDAT'. " Customizing: Table Contents
        cv_icon = icon_table_settings.
      WHEN 'STCS'. " Task List
        cv_icon = icon_view_list.
      WHEN 'BMFR'. " Application component
        cv_icon = icon_display_tree.
      WHEN 'AOBJ'. " Archiving object
        cv_icon = icon_viewer_optical_archive.
      WHEN 'AVAS'. " Classification
        cv_icon = icon_class_connection_space.
      WHEN 'SFBF' OR 'SFB2'. " Business Function
        cv_icon = icon_activity_group.
      WHEN 'SFBS' OR 'SFB1'. " Business Set
        cv_icon = icon_composite_activitygroup.
      WHEN 'SFSW'. " Switch
        cv_icon = icon_business_area.
      WHEN 'WGRP'. " Object Type Group
        cv_icon = icon_object_list.
      WHEN 'CUS0'. " IMG Activity
        cv_icon = icon_display_text.
      WHEN 'CUS1'. " Customizing Activity
        cv_icon = icon_display_text.
      WHEN 'CUS2'. " Customizing Attributes
        cv_icon = icon_display_text.
      WHEN 'NROB'. " Number Range
        cv_icon = icon_change_number.
      WHEN 'JOBD'. " Job Definition
        cv_icon = icon_background_job.
      WHEN 'WAPP'. " BSP Page
        cv_icon = icon_wd_view.
      WHEN 'VCLS'. " View Cluster
        cv_icon = icon_bw_apd_db.
      WHEN 'VARI' OR 'VARX'. " Variant
        cv_icon = icon_abap.
      WHEN 'SUSC'. " Authorization object class
        cv_icon = icon_locked.
      WHEN 'W3HT'. " WWW HTML Templates
        cv_icon = icon_htm.
      WHEN 'W3MI'. " WWW Mime
        cv_icon = icon_bmp.
      WHEN 'AVAR'. " Activation Variants
        cv_icon = icon_variants.
      WHEN 'SHI5'. " Gen. hierarchy storage extrension name
        cv_icon = icon_tree.
      WHEN OTHERS.
        cv_icon = icon_dummy.
    ENDCASE.

  ENDMETHOD.


  METHOD class_constructor.

    DATA:
      ls_object_list LIKE LINE OF gt_object_list.

    ls_object_list-sign   = 'I'.
    ls_object_list-option = 'EQ'.

    ls_object_list-low = 'SICF'. " ICF Service
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'TOBJ'. " Transport object
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'OBJA'. " After import method (api)
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'OBJM'. " After import method (metadata)
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'DOCU'. " Documentation
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'DOCT'. " General Text
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'DOCV'. " Documentation (Independent)
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'DSYS'. " Chapter of a Book Structure
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'NSPC'. " Namespace
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'CDAT'. " View Cluster Maintenance: Data
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'TDAT'. " Customizing: Table Contents
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'STCS'. " Task List
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'BMFR'. " Application component
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'AOBJ'. " Archiving object
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'AVAS'. " Classification
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SFB1'. " Switch Framework
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SFB2'. " Switch Framework
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SFBF'. " Switch Framework
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SFBS'. " Switch Framework
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SFSW'. " Switch Framework
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'WGRP'. " Object Type Group
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'CUS0'. " IMG Activity
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'CUS1'. " Customizing Activity
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'CUS2'. " Customizing Attributes
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'NROB'. " Number Range
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'JOBD'. " Job Definition
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'WAPP'. " BSP Page (LIMU)
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'VCLS'. " View Cluster
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'VARI'. " Variants
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'VARX'. " Variants
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SUSC'. " Authorization object class
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'W3HT'. " WWW HTML
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'W3MI'. " WWW Mime
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'AVAR'. " Activation Variants
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SHI5'. " Gen. hierarchy storage extrension name
    APPEND ls_object_list TO gt_object_list.

    SELECT dokclass dokdescr1 FROM tdclt INTO TABLE gt_dokclass WHERE doklangu = sy-langu.
    CHECK sy-subrc = 0.

  ENDMETHOD.


  METHOD get_documentation_text.

    DATA:
      lv_dokclass  TYPE doku_class,
      lv_namespace TYPE namespace,
      lv_dokname   TYPE string,
      ls_dokclass  TYPE ty_dokclass.

    CASE iv_object.
      WHEN 'DOCT'.
        lv_dokclass = 'TX'.
        lv_dokname  = iv_obj_name.
      WHEN 'DOCU' OR 'DOCV'.
        IF iv_obj_name CS '/'.
          SPLIT iv_obj_name+1 AT '/' INTO lv_namespace lv_dokname.
        ELSE.
          lv_dokname = iv_obj_name.
        ENDIF.
        lv_dokclass = lv_dokname(2).
        lv_dokname  = lv_dokname+2.
      WHEN 'DSYS'.
        IF iv_obj_name CS '/'.
          SPLIT iv_obj_name+1 AT '/' INTO lv_namespace lv_dokname.
        ELSE.
          lv_dokname = iv_obj_name.
        ENDIF.
        lv_dokclass = lv_dokname(4).
        lv_dokname  = lv_dokname+4.
    ENDCASE.

    READ TABLE gt_dokclass INTO ls_dokclass WITH TABLE KEY dokclass = lv_dokclass.
    IF sy-subrc = 0.
      rv_result = |{ ls_dokclass-dokdescr1 }: { lv_dokname }|.
    ELSE.
      rv_result = iv_obj_name.
    ENDIF.

  ENDMETHOD.


  METHOD get_variant_text.

    " From INCLUDE TTYPLENG
    CONSTANTS:
      lc_prog     TYPE i VALUE 40,
      lc_vari     TYPE i VALUE 14,
      lc_prog_old TYPE i VALUE 8.

    DATA:
      lv_name         TYPE e071-obj_name,
      lv_length1      TYPE i,
      lv_length2      TYPE i,
      lv_objlen       TYPE i,
      lv_report       TYPE rsvar-report,
      lv_variant      TYPE rsvar-variant,
      lv_variant_text TYPE rsvar-vtext.

    " See TR_OBJECT_JUMP_TO_TOOL
    lv_length1  = lc_prog + lc_vari.      " new maximum length
    lv_name     = iv_obj_name(lv_length1)." skip comments
    lv_objlen   = strlen( lv_name ).
    lv_length2  = lc_prog_old + lc_vari.  " former maximum length
    IF lv_objlen > lv_length2.     " new syntax
      lv_variant = lv_name+lc_prog(lc_vari).
      lv_report  = lv_name(lc_prog).
    ELSE.                          " old syntax
      lv_variant = lv_name+lc_prog_old(lc_vari).
      lv_report  = lv_name(lc_prog_old).
    ENDIF.

    CALL FUNCTION 'RS_VARIANT_TEXT'
      EXPORTING
        curr_report = lv_report
        langu       = sy-langu
        variant     = lv_variant
      IMPORTING
        v_text      = lv_variant_text
      EXCEPTIONS
        no_text     = 1
        OTHERS      = 2.
    IF sy-subrc = 0.
      rv_result = lv_variant_text.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
