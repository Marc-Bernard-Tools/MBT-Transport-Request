CLASS /mbtools/cl_cts_req_disp_wb DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

************************************************************************
* MBT Transport Request - ABAP Workbench
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

    CONSTANTS c_as4pos TYPE ddposition VALUE '999999' ##NO_TEXT.

    CLASS-DATA gt_object_list TYPE RANGE OF e071-object READ-ONLY.

    CLASS-METHODS class_constructor.
  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      ty_shorttext  TYPE seu_objtxt,
      ty_shorttexts TYPE STANDARD TABLE OF ty_shorttext WITH DEFAULT KEY.

    CLASS-METHODS split_object
      IMPORTING
        !iv_pgmid    TYPE e071-pgmid
        !iv_object   TYPE e071-object
        !iv_obj_name TYPE e071-obj_name
      EXPORTING
        !ev_obj_type TYPE trobjtype
        !ev_obj_name TYPE sobj_name
        !ev_encl_obj TYPE sobj_name.

    CLASS-METHODS get_shorttexts
      CHANGING
        ct_object TYPE ty_shorttexts.

ENDCLASS.



CLASS /mbtools/cl_cts_req_disp_wb IMPLEMENTATION.


  METHOD /mbtools/if_cts_req_display~get_object_descriptions.

    DATA:
      ls_e071_txt TYPE /mbtools/trwbo_s_e071_txt,
      ls_object   TYPE seu_objtxt,
      lt_object   TYPE TABLE OF seu_objtxt,
      lv_obj_name TYPE trobj_name.

    FIELD-SYMBOLS:
      <ls_e071>      TYPE trwbo_s_e071,
      <ls_e071k>     TYPE trwbo_s_e071k,
      <ls_e071k_str> TYPE trwbo_s_e071k_str.

    LOOP AT it_e071 ASSIGNING <ls_e071> WHERE object IN gt_object_list.
      CLEAR ls_object.

      split_object(
        EXPORTING
          iv_pgmid    = <ls_e071>-pgmid
          iv_object   = <ls_e071>-object
          iv_obj_name = <ls_e071>-obj_name
        IMPORTING
          ev_obj_type = ls_object-object
          ev_obj_name = ls_object-obj_name
          ev_encl_obj = ls_object-encl_obj ).

      COLLECT ls_object INTO lt_object.
    ENDLOOP.

    IF lt_object IS NOT INITIAL.

      get_shorttexts( CHANGING ct_object = lt_object ).

      LOOP AT it_e071 ASSIGNING <ls_e071> WHERE object IN gt_object_list.

        split_object(
          EXPORTING
            iv_pgmid    = <ls_e071>-pgmid
            iv_object   = <ls_e071>-object
            iv_obj_name = <ls_e071>-obj_name
          IMPORTING
            ev_obj_type = ls_object-object
            ev_obj_name = ls_object-obj_name
            ev_encl_obj = ls_object-encl_obj ).

        READ TABLE lt_object INTO ls_object
          WITH KEY object   = ls_object-object
                   obj_name = ls_object-obj_name
                   encl_obj = ls_object-encl_obj.
        IF sy-subrc = 0.
          CLEAR ls_e071_txt.
          MOVE-CORRESPONDING <ls_e071> TO ls_e071_txt.

          get_object_icon(
            EXPORTING
              iv_object = <ls_e071>-object
            CHANGING
              cv_icon   = ls_e071_txt-icon ).

          ls_e071_txt-text = ls_object-stext.
          ls_e071_txt-name = <ls_e071>-obj_name.
          INSERT ls_e071_txt INTO TABLE ct_e071_txt.
        ENDIF.

      ENDLOOP.

    ENDIF.

*   Table Content (TABU)
    IF it_e071k IS SUPPLIED.
      CLEAR lt_object.

      LOOP AT it_e071k ASSIGNING <ls_e071k> WHERE object IN gt_object_list.

        CLEAR ls_object.

        lv_obj_name = <ls_e071k>-objname.

        split_object(
          EXPORTING
            iv_pgmid    = <ls_e071k>-pgmid
            iv_object   = <ls_e071k>-object
            iv_obj_name = lv_obj_name
          IMPORTING
            ev_obj_type = ls_object-object
            ev_obj_name = ls_object-obj_name
            ev_encl_obj = ls_object-encl_obj ).

        COLLECT ls_object INTO lt_object.

      ENDLOOP.

      IF lt_object IS NOT INITIAL.

        get_shorttexts( CHANGING ct_object = lt_object ).

        LOOP AT it_e071k ASSIGNING <ls_e071k> WHERE object IN gt_object_list.

          lv_obj_name = <ls_e071k>-objname.

          split_object(
            EXPORTING
              iv_pgmid    = <ls_e071k>-pgmid
              iv_object   = <ls_e071k>-object
              iv_obj_name = lv_obj_name
            IMPORTING
              ev_obj_type = ls_object-object
              ev_obj_name = ls_object-obj_name
              ev_encl_obj = ls_object-encl_obj ).

          READ TABLE lt_object INTO ls_object
            WITH KEY object   = ls_object-object
                     obj_name = ls_object-obj_name
                     encl_obj = ls_object-encl_obj.
          IF sy-subrc = 0.
            CLEAR ls_e071_txt.
            MOVE-CORRESPONDING <ls_e071k> TO ls_e071_txt.

            get_object_icon(
              EXPORTING
                iv_object = <ls_e071k>-object
              CHANGING
                cv_icon   = ls_e071_txt-icon ).

            ls_e071_txt-text     = ls_object-stext.
            ls_e071_txt-name     = <ls_e071k>-objname.
            ls_e071_txt-obj_name = <ls_e071k>-objname.
            ls_e071_txt-as4pos   = c_as4pos.
            COLLECT ls_e071_txt INTO ct_e071_txt.
          ENDIF.

        ENDLOOP.

      ENDIF.
    ENDIF. "it_e071k

*   Table Strings (TABU)
    IF it_e071k_str IS SUPPLIED.
      CLEAR lt_object.

      LOOP AT it_e071k_str ASSIGNING <ls_e071k_str> WHERE object IN gt_object_list.

        CLEAR ls_object.

        lv_obj_name = <ls_e071k_str>-objname.

        split_object(
          EXPORTING
            iv_pgmid    = <ls_e071k_str>-pgmid
            iv_object   = <ls_e071k_str>-object
            iv_obj_name = lv_obj_name
          IMPORTING
            ev_obj_type = ls_object-object
            ev_obj_name = ls_object-obj_name
            ev_encl_obj = ls_object-encl_obj ).

        COLLECT ls_object INTO lt_object.

      ENDLOOP.

      IF lt_object IS NOT INITIAL.

        get_shorttexts( CHANGING ct_object = lt_object ).

        LOOP AT it_e071k_str ASSIGNING <ls_e071k_str> WHERE object IN gt_object_list.

          lv_obj_name = <ls_e071k_str>-objname.

          split_object(
            EXPORTING
              iv_pgmid    = <ls_e071k_str>-pgmid
              iv_object   = <ls_e071k_str>-object
              iv_obj_name = lv_obj_name
            IMPORTING
              ev_obj_type = ls_object-object
              ev_obj_name = ls_object-obj_name
              ev_encl_obj = ls_object-encl_obj ).

          READ TABLE lt_object INTO ls_object
            WITH KEY object   = ls_object-object
                     obj_name = ls_object-obj_name
                     encl_obj = ls_object-encl_obj.
          IF sy-subrc = 0.
            CLEAR ls_e071_txt.
            MOVE-CORRESPONDING <ls_e071k_str> TO ls_e071_txt.

            get_object_icon(
              EXPORTING
                iv_object = <ls_e071k_str>-object
              CHANGING
                cv_icon   = ls_e071_txt-icon ).

            ls_e071_txt-text     = ls_object-stext.
            ls_e071_txt-name     = <ls_e071k_str>-objname.
            ls_e071_txt-obj_name = <ls_e071k_str>-objname.
            ls_e071_txt-as4pos   = c_as4pos.
            COLLECT ls_e071_txt INTO ct_e071_txt.
          ENDIF.

        ENDLOOP.

      ENDIF.
    ENDIF. "it_e071k_str

  ENDMETHOD.


  METHOD /mbtools/if_cts_req_display~get_object_icon.

*   See function RS_SHORTTEXT_GET
    CASE iv_object.
      WHEN 'APPL'.
        cv_icon = icon_package_application.
      WHEN 'BMED' OR swbm_c_type_proc_function.
        cv_icon = icon_workflow_activity.
      WHEN 'BMPC' OR swbm_c_type_proc_process.
        cv_icon = icon_workflow_process.
      WHEN 'CLAS' OR swbm_c_type_class OR 'SHMA' OR swbm_c_type_shared_obj_area
          OR 'CINC' OR 'CLSD' OR 'CPRI' OR 'CPRO' OR 'CPUB' OR 'CPAK' OR 'MAPP'.
        cv_icon = icon_oo_class.
      WHEN 'COCO' OR swbm_c_type_control_composite.
        cv_icon = icon_layout_control.
      WHEN 'DEVC' OR swbm_c_type_devclass OR 'DEVP'.
        cv_icon = icon_package_standard.
      WHEN 'DIAL' OR swbm_c_type_dialog.
        cv_icon = icon_wd_view.
      WHEN 'DOMA' OR 'DOMD' OR swbm_c_type_ddic_domain.
        cv_icon = icon_database_table_ina.
      WHEN 'DSEL'.
        cv_icon = icon_database_table.
      WHEN 'DTEL' OR 'DTED' OR swbm_c_type_ddic_dataelement.
        cv_icon = icon_database_table_ina.
      WHEN 'DYNP' OR swbm_c_type_prg_dynpro.
        cv_icon = icon_wd_view.
      WHEN 'ENQU' OR 'ENQD' OR swbm_c_type_ddic_enqueue.
        cv_icon = icon_locked.
      WHEN 'FUNC' OR 'SRFC' OR swbm_c_type_function.
        cv_icon = icon_abap.
      WHEN 'FUGR' OR 'FUGS' OR 'FUGT' OR swbm_c_type_function_pool.
        cv_icon = icon_abap.
      WHEN 'GURL' OR swbm_c_type_url.
        cv_icon = icon_url.
      WHEN 'IAMA' OR swbm_c_type_miniapp.
        cv_icon = icon_htm.
      WHEN 'IASP' OR swbm_c_type_service.
        cv_icon = icon_htm.
      WHEN 'IATU' OR swbm_c_type_w3_template.
        cv_icon = icon_htm.
      WHEN 'IAMU' OR swbm_c_type_w3_mime.
        cv_icon = icon_bmp.
      WHEN 'IARP' OR swbm_c_type_w3_resource.
        cv_icon = icon_htm.
      WHEN 'INTF' OR swbm_c_type_interface.
        cv_icon = icon_oo_interface.
      WHEN 'MCOB' OR swbm_c_type_ddic_matchcode OR 'MCOD'.
        cv_icon = icon_value_help.
      WHEN 'MCID'.
        cv_icon = icon_value_help.
      WHEN 'MESS' OR swbm_c_type_message.
        cv_icon = icon_message_type.
      WHEN 'METH' OR swbm_c_type_cls_mtd_impl.
        cv_icon = icon_oo_class_method.
      WHEN 'MSAG' OR swbm_c_type_message_id OR 'MSAD'.
        cv_icon = icon_message_type.
      WHEN 'PARA' OR swbm_c_type_parameter_id.
        cv_icon = icon_parameter.
      WHEN 'PDAC' OR swbm_c_type_wf_role.
        cv_icon = icon_role.
      WHEN 'PDTS' OR swbm_c_type_wf_task.
        cv_icon = icon_workflow_activity.
      WHEN 'PDWS' OR swbm_c_type_wf_workflow.
        cv_icon = icon_workflow.
      WHEN 'PINF' OR swbm_c_type_package_interface OR 'PIFA' OR 'PIFH'.
        cv_icon = icon_package_dynamic.
      WHEN 'PROG' OR 'REPS' OR swbm_c_type_prg_source OR swbm_c_type_prg_include.
        cv_icon = icon_abap.
      WHEN 'REPT'.
        cv_icon = icon_text_ina.
      WHEN 'SCAT' OR swbm_c_type_testcase.
        cv_icon = icon_test.
      WHEN 'SOBJ' OR swbm_c_type_bor_objtype.
        cv_icon = icon_businav_objects.
      WHEN 'SHI3' OR 'U' OR 'SHI6' OR 'SHI7'.
        cv_icon = icon_context_menu.
      WHEN 'SHLP' OR 'SHLD' OR swbm_c_type_ddic_searchhelp OR 'SHLX'.
        cv_icon = icon_value_help.
      WHEN 'SLDB' OR swbm_c_type_logical_database.
        cv_icon = icon_database_table.
      WHEN 'SMOD'.
        cv_icon = icon_modification_overview.
      WHEN 'CMOD'.
        cv_icon = icon_modification_create.
      WHEN 'SUSO' OR swbm_c_type_auth_object.
        cv_icon = icon_locked.
      WHEN 'SQLT' OR swbm_c_type_ddic_pool_cluster OR 'SQLD' OR 'SQTT'.
        cv_icon = icon_database_table.
      WHEN 'SXSD' OR swbm_c_type_badi_def.
        cv_icon = icon_abap.
      WHEN 'SXCI' OR swbm_c_type_badi_imp.
        cv_icon = icon_abap.
      WHEN 'CUAD' OR swbm_c_type_cua_status.
        cv_icon = icon_wd_toolbar.
      WHEN swbm_c_type_cua_title.
        cv_icon = icon_wd_toolbar_caption.
      WHEN 'TABL' OR 'TABD' OR swbm_c_type_ddic_db_table OR swbm_c_type_ddic_structure
          OR swbm_c_type_prg_table OR 'TABT' OR 'INDX'.
        cv_icon = icon_database_table.
      WHEN 'TRAN' OR swbm_c_type_transaction.
        cv_icon = icon_execute_object.
      WHEN 'TTYP' OR 'TTYD' OR swbm_c_type_ddic_tabletype OR 'TTYX'.
        cv_icon = icon_view_table.
      WHEN 'TYPE' OR swbm_c_type_ddic_typepool.
        cv_icon = icon_database_table_ina.
      WHEN 'UDMO' OR swbm_c_type_datamodel.
        cv_icon = icon_businav_datamodel.
      WHEN 'UENO' OR swbm_c_type_entity.
        cv_icon = icon_businav_entity.
      WHEN 'VIEW' OR 'VIED' OR swbm_c_type_ddic_view OR 'VDAT' OR 'VIET'.
        cv_icon = icon_database_table_ina.
      WHEN 'XSLT' OR swbm_c_type_xslt_file.
        cv_icon = icon_xml_doc.
      WHEN 'WTAG' OR swbm_c_type_o2_taglibrary.
        cv_icon = icon_htt.
      WHEN 'WTHM' OR swbm_c_type_o2_theme.
        cv_icon = icon_htt.
      WHEN 'WAPA' OR swbm_c_type_o2_application OR 'WAPD'.
        cv_icon = icon_wd_application.
        " 'WDYA' and swbm_c_type_wdy_application
        " 'WDYN' and swbm_c_type_wdy_component
        " see /MBTOOLS/CL_CTS_REQ_DISP_WDY
      WHEN 'WEBI' OR swbm_c_type_virt_interface.
        cv_icon = icon_interface.
      WHEN 'ENHO' OR swbm_c_type_enhancement.
        cv_icon = icon_vsd.
      WHEN 'ENHC' OR swbm_c_type_enh_composite.
        cv_icon = icon_wd_tree_node.
      WHEN 'ENHS' OR swbm_c_type_enh_spot.
        cv_icon = icon_wd_context.
      WHEN 'ENSC' OR swbm_c_type_enh_spot_comp.
        cv_icon = icon_wd_controller.
      WHEN 'SFPI' OR swbm_c_type_formobject_intf.
        cv_icon = icon_view_form.
      WHEN 'SFPF' OR swbm_c_type_formobject_form.
        cv_icon = icon_view_form.
        " 'WDCA' and swbm_c_type_wdy_appl_config
        " 'WDCC' and swbm_c_type_wdy_comp_config
        " see /MBTOOLS/CL_CTS_REQ_DISP_WDY
      WHEN 'COAS' OR swbm_c_type_cool_aspect.
        cv_icon = icon_oo_class.
      WHEN 'COSM' OR swbm_c_type_cool_service_mod.
        cv_icon = icon_oo_interface.
      WHEN 'ACID' OR swbm_c_type_activation_id.
        cv_icon = icon_check.
      WHEN 'ECTC' OR swbm_c_type_ecatt_test_config.
        cv_icon = icon_test.
      WHEN 'ECTD' OR swbm_c_type_ecatt_test_data.
        cv_icon = icon_test.
      WHEN 'ECSD' OR swbm_c_type_ecatt_system_data.
        cv_icon = icon_test.
      WHEN 'ECSC' OR swbm_c_type_ecatt_test_script.
        cv_icon = icon_test.
      WHEN 'AUTH'.
        cv_icon = icon_locked.
*     Additional objects
      WHEN 'XPRA' OR 'PRAG'.
        cv_icon = icon_abap.
      WHEN 'LDBA'.
        cv_icon = icon_database_table.
      WHEN 'DDLS' OR 'DF '. "swbm_c_type_ddic_ddl_source.
        cv_icon = icon_abap.
      WHEN 'DCLS' OR 'Q0R'.
        cv_icon = icon_locked.
      WHEN 'SAMC' OR 'SAPC'.
        cv_icon = icon_short_message.
      WHEN 'TABU'.
        cv_icon = icon_list.
      WHEN 'SPRX'.
        cv_icon = icon_url.
      WHEN OTHERS.
        cv_icon = icon_dummy.
    ENDCASE.

  ENDMETHOD.


  METHOD class_constructor.

    DATA ls_object_list LIKE LINE OF gt_object_list.

    ls_object_list-sign   = 'I'.
    ls_object_list-option = 'EQ'.

    ls_object_list-low = 'APPL'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'BMED'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_proc_function.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'BMPC'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_proc_process.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'CLAS'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_class.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SHMA'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_shared_obj_area.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'CINC'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'CLSD'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'CPRI'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'CPRO'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'CPUB'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'CPAK'. "NEW: class parts
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'MAPP'. "NEW: class parts
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'COCO'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_control_composite.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'DEVC'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'DEVP'. "LIMU mapping
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_devclass.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'DIAL'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_dialog.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'DOMA'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'DOMD'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_ddic_domain.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'DSEL'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'DTEL'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'DTED'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_ddic_dataelement.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'DYNP'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_prg_dynpro.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'ENQU'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'ENQD'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_ddic_enqueue.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'FUNC'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_function.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SRFC'. " RFC function
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'FUGR'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'FUGS'. " Exit function group
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'FUGT'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_function_pool.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'GURL'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_url.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'IAMA'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_miniapp.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'IASP'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_service.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'IATU'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_w3_template.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'IAMU'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_w3_mime.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'IARP'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_w3_resource.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'INTF'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_interface.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'MCOB'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'MCOD'. "LIMU mapping
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_ddic_matchcode.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'MCID'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'MESS'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_message.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'METH'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_cls_mtd_impl.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'MSAG'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'MSAD'. "LIMU mapping
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_message_id.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'PARA'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_parameter_id.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'PDAC'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_wf_role.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'PDTS'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_wf_task.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'PDWS'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_wf_workflow.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'PINF'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'PIFA'. "LIMU mapping
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'PIFH'. "LIMU mapping
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_package_interface.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'PROG'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'REPS'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_prg_source.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_prg_include.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'REPT'. "NEW: Report texts
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SCAT'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_testcase.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SOBJ'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_bor_objtype.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SHI3'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SHI6'. "NEW: Same as SHI3
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SHI7'. "NEW: Same as SHI3
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'U'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SHLP'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SHLD'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SHLX'. "LIMU mapping
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_ddic_searchhelp.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SLDB'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_logical_database.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SMOD'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'CMOD'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SUSO'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_auth_object.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SQLT'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SQLD'. "LIMU mapping
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SQTT'. "LIMU mapping
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_ddic_pool_cluster.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SXSD'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_badi_def.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SXCI'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_badi_imp.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'CUAD'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_cua_status.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_cua_title.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'TABL'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'TABD'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_ddic_db_table.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_ddic_structure.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_prg_table.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'TABU'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'VDAT'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'TABT'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'TRAN'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_transaction.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'TTYP'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'TTYD'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'TTYX'. "LIMU mapping
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_ddic_tabletype.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'TYPE'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_ddic_typepool.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'UDMO'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_datamodel.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'UENO'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_entity.
    APPEND ls_object_list TO gt_object_list.
    " 'VARI'
    " see /MBTOOLS/CL_CTS_REQ_DISP_BASIS
    ls_object_list-low = 'VIEW'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'VIED'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'VIET'. "LIMU mapping
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_ddic_view.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'XSLT'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_xslt_file.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'WTAG'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_o2_taglibrary.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'WTHM'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_o2_theme.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'WAPA'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'WAPD'. "LIMU mapping
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_o2_application.
    APPEND ls_object_list TO gt_object_list.
    " 'WDYA' and swbm_c_type_wdy_application
    " 'WDYN' and swbm_c_type_wdy_component
    " see /MBTOOLS/CL_CTS_REQ_DISP_WDY
    ls_object_list-low = 'WEBI'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_virt_interface.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'ENHO'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_enhancement.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'ENHC'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_enh_composite.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'ENHS'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_enh_spot.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'ENSC'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_enh_spot_comp.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SFPI'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_formobject_intf.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SFPF'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_formobject_form.
    APPEND ls_object_list TO gt_object_list.
    " 'WDCA' and swbm_c_type_wdy_appl_config
    " 'WDCC' and swbm_c_type_wdy_comp_config
    " see /MBTOOLS/CL_CTS_REQ_DISP_WDY
    ls_object_list-low = 'COAS'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_cool_aspect.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'COSM'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_cool_service_mod.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'ACID'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_activation_id.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'ECTC'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_ecatt_test_config.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'ECTD'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_ecatt_test_data.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'ECSD'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_ecatt_system_data.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'ECSC'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = swbm_c_type_ecatt_test_script.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'AUT'. "wb mapping
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'AUTH'.
    APPEND ls_object_list TO gt_object_list.
*   Additional objects
    ls_object_list-low = 'LDBA'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'XPRA'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'INDX'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'DDLS'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'DCLS'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'DF '. "swbm_c_type_ddic_ddl_source.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'PRAG'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SPRX'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SAMC'.
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SAPC'.
    APPEND ls_object_list TO gt_object_list.

  ENDMETHOD.


  METHOD get_shorttexts.

    DATA lv_clear TYPE abap_bool.

    " RS_SHORTTEXT_GET has bug in buffer so we have to clear it every time (until we get a fix)
    " Note: This workaround still does not fix all issues with this function but better than nothing
    lv_clear = abap_true.

    TRY.
        CALL FUNCTION 'RS_SHORTTEXT_GET'
          EXPORTING
            clear_buffer = lv_clear  " not in lower releases
          TABLES
            obj_tab      = ct_object.
      CATCH cx_sy_dyn_call_param_not_found.
        CALL FUNCTION 'RS_SHORTTEXT_GET'
          TABLES
            obj_tab = ct_object.
    ENDTRY.

  ENDMETHOD.


  METHOD split_object.

    DATA:
      lv_name    TYPE e071-obj_name,
      lv_length1 TYPE i,
      lv_length2 TYPE i,
      lv_msag    TYPE i,
      lv_objlen  TYPE i.

    " From INCLUDE TTYPLENG
    CONSTANTS:
      lc_prog     TYPE i VALUE 40,
      lc_dynp     TYPE i VALUE 4,
      lc_msag     TYPE i VALUE 20,
      lc_mess     TYPE i VALUE 3,
      lc_clas     TYPE i VALUE 30,
      lc_meth     TYPE i VALUE 61,
      lc_prog_old TYPE i VALUE 8.

    CLEAR: ev_obj_type, ev_obj_name, ev_encl_obj.

    " Same logic as function module TR_OBJECT_JUMP_TO_TOOL
    IF iv_pgmid = 'LIMU' AND iv_object = 'REPO'.
      ev_obj_type = 'PROG'.
      ev_obj_name = iv_obj_name.
      ev_encl_obj = space.
    ELSEIF iv_pgmid = 'LIMU' AND iv_object = 'DYNP'.
      ev_obj_type = 'DYNP'.
      lv_length1  = lc_prog + lc_dynp.      " new maximal length
      lv_name     = iv_obj_name(lv_length1)." skip comments
      lv_objlen   = strlen( lv_name ).
      lv_length2  = lc_prog_old + lc_dynp.  " former maximal length
      IF lv_objlen > lv_length2.     " new syntax
        ev_obj_name = lv_name+lc_prog(lc_dynp).
        ev_encl_obj = lv_name(lc_prog).
      ELSE.                          " old syntax
        ev_obj_name = lv_name+lc_prog_old(lc_dynp).
        ev_encl_obj = lv_name(lc_prog_old).
      ENDIF.
    ELSEIF iv_pgmid = 'LIMU' AND iv_object = 'MESS'.
      ev_obj_type = 'MESS'.
      lv_length1  = lc_msag + lc_mess.      " maximum length
      lv_name     = iv_obj_name(lv_length1)." skip comments
      lv_objlen   = strlen( lv_name ).
      lv_msag     = lv_objlen - lc_mess.
      ev_obj_name = lv_name+lv_msag(lc_mess).
      ev_encl_obj = lv_name(lv_msag).
    ELSEIF iv_pgmid = 'LIMU' AND iv_object = 'METH'.
      ev_obj_type = 'METH'.
      lv_name = iv_obj_name+lc_clas(lc_meth).
*     Inherited methods?
      IF lv_name CS '~'.
        SPLIT lv_name AT '~' INTO ev_encl_obj ev_obj_name.
      ELSE.
        ev_obj_name = lv_name.
        ev_encl_obj = iv_obj_name(lc_clas).
      ENDIF.
    ELSEIF iv_pgmid = 'LIMU' AND iv_object = 'INTD'.
      ev_obj_type = 'INTF'.
      ev_obj_name = iv_obj_name.
      ev_encl_obj = space.
    ELSEIF iv_pgmid = 'LIMU' AND iv_object = 'ADIR'.
      ev_obj_type = iv_obj_name+4(4).
      ev_obj_name = iv_obj_name+8.
    ELSE.
      ev_obj_type = iv_object.
      ev_obj_name = iv_obj_name.
      ev_encl_obj = space.
    ENDIF.

    " Map some object types
    CASE iv_object.
      WHEN 'CLSD' OR 'CPRI' OR 'CPRO' OR 'CPUB' OR 'CPAK' OR 'MAPP'.
        ev_obj_type = 'CLAS'.
      WHEN 'CINC'.
        IF ev_obj_name+30(2) = 'CC'.
          ev_obj_type = 'CLAS'.
          SPLIT ev_obj_name(30) AT '=' INTO ev_obj_name lv_name.
        ELSE.
          ev_obj_type = 'PROG'.
        ENDIF.
      WHEN 'REPS' OR 'REPT'.
        IF ev_obj_name+30(2) = 'CP'.
          ev_obj_type = 'CLAS'.
          SPLIT ev_obj_name(30) AT '=' INTO ev_obj_name lv_name.
        ELSE.
          ev_obj_type = 'PROG'.
        ENDIF.
      WHEN 'TABU' OR 'TABT'.
        ev_obj_type = 'TABL'.
      WHEN 'VDAT' OR 'CDAT' OR 'VIET'.
        ev_obj_type = 'VIEW'.
      WHEN 'SHLD' OR 'SHLX'.
        ev_obj_type = 'SHLP'.
      WHEN 'TTYX'.
        ev_obj_type = 'TTYP'.
      WHEN 'TYPD'.
        ev_obj_type = 'TYPE'.
      WHEN 'CUAD'.
        ev_obj_type = 'PROG'.
      WHEN 'XPRA'.
        ev_obj_type = 'PROG'.
      WHEN 'INDX'.
        ev_obj_type = 'TABL'.
        ev_obj_name = ev_obj_name(10).
      WHEN 'LDBA'.
        ev_obj_type = swbm_c_type_logical_database.
      WHEN 'DSEL'.
        ev_obj_type = swbm_c_type_logical_database.
        ev_obj_name = ev_obj_name+3(20).
      WHEN 'IARP' OR swbm_c_type_w3_resource.
        ev_obj_type = 'IASP'.
        ev_obj_name = ev_obj_name(14).
      WHEN 'IATU' OR swbm_c_type_w3_template.
        ev_obj_name = ev_obj_name+20(*).
        ev_encl_obj = ev_obj_name(20).
      WHEN 'SPRX'.
        ev_obj_type = ev_obj_name(4).
        ev_obj_name = ev_obj_name+4(*).
      WHEN 'DDLS'.
        ev_obj_type = 'DF '. "swbm_c_type_ddic_ddl_source.
      WHEN 'DCLS'.
        ev_obj_type = 'Q0R'.
      WHEN 'DEVP'.
        ev_obj_type = 'DEVC'.
      WHEN 'PIFA' OR 'PIFH'.
        ev_obj_type = 'PINF'.
      WHEN 'MCOD'.
        ev_obj_type = 'MCOB'.
      WHEN 'MSAD'.
        ev_obj_type = 'MSAG'.
      WHEN 'WAPD'.
        ev_obj_type = 'WAPA'.
      WHEN 'SQLD' OR 'SQTT'.
        ev_obj_type = 'SQLT'.
      WHEN 'FUGS'.
        ev_obj_type = 'FUGR'.
      WHEN 'SRFC'.
        ev_obj_type = 'FUNC'.
      WHEN 'SHI6' OR 'SHI7'.
        ev_obj_type = 'SHI3'.
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
