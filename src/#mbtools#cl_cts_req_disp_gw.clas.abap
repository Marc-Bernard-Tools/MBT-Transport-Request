CLASS /mbtools/cl_cts_req_disp_gw DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

************************************************************************
* MBT Request Display - SAP Gateway
*
* (c) MBT 2020 https://marcbernardtools.com/
************************************************************************
  PUBLIC SECTION.

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

ENDCLASS.



CLASS /mbtools/cl_cts_req_disp_gw IMPLEMENTATION.


  METHOD /mbtools/if_cts_req_display~get_object_descriptions.

    DATA:
      lv_tabname  TYPE tabname,
      ls_e071_txt TYPE /mbtools/trwbo_s_e071_txt.

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
        WHEN 'G4BA'  " SAP Gateway OData V4 Backend Service Group & Assigments
          OR 'G4BG'  " SAP Gateway OData V4 Backend Service Group & Assigments (obsolete)
          OR 'G4BS'. " SAP Gateway OData V4 Backend Service
          lv_tabname = '/IWBEP/I_V4_MSGT'.
          SELECT SINGLE description FROM (lv_tabname) INTO ls_e071_txt-text
            WHERE group_id = <ls_e071>-object
              AND language = sy-langu.
          INSERT ls_e071_txt INTO TABLE ct_e071_txt.
        WHEN 'IWMO'. " SAP Gateway Business Suite Enablement - Model
          lv_tabname = '/IWBEP/I_MGW_OHT'.
          SELECT SINGLE description FROM (lv_tabname) INTO ls_e071_txt-text
            WHERE technical_name = <ls_e071>-obj_name(32)
              AND version = <ls_e071>-obj_name+32(4)
              AND language = sy-langu.
          INSERT ls_e071_txt INTO TABLE ct_e071_txt.
        WHEN 'IWOM'. " SAP Gateway: Model Metadata
          lv_tabname = '/IWFND/I_MED_OHT'.
          SELECT SINGLE description FROM (lv_tabname) INTO ls_e071_txt-text
            WHERE model_identifier = <ls_e071>-obj_name
              AND is_active = 'A'
              AND language = sy-langu.
          INSERT ls_e071_txt INTO TABLE ct_e071_txt.
        WHEN 'IWPR'. " SAP Gateway BSE - Service Builder Project
          lv_tabname = '/IWBEP/I_SBD_PRT'.
          SELECT SINGLE description FROM (lv_tabname) INTO ls_e071_txt-text
            WHERE project = <ls_e071>-obj_name
              AND sylangu = sy-langu.
          INSERT ls_e071_txt INTO TABLE ct_e071_txt.
        WHEN 'IWSG'. " SAP Gateway: Service Groups Metadata
          lv_tabname = '/IWFND/I_MED_SRT'.
          SELECT SINGLE description FROM (lv_tabname) INTO ls_e071_txt-text
            WHERE srv_identifier = <ls_e071>-obj_name
              AND is_active = 'A'
              AND language = sy-langu.
          INSERT ls_e071_txt INTO TABLE ct_e071_txt.
        WHEN 'IWSV'. " SAP Gateway Business Suite Enablement - Service
          lv_tabname = '/IWBEP/I_MGW_SRT'.
          SELECT SINGLE description FROM (lv_tabname) INTO ls_e071_txt-text
            WHERE technical_name = <ls_e071>-obj_name(35)
              AND version = <ls_e071>-obj_name+35(4)
              AND language = sy-langu.
          INSERT ls_e071_txt INTO TABLE ct_e071_txt.
        WHEN 'IWVB'. " SAP Gateway Business Suite Enablement - Vocabulary Annotation
          lv_tabname = '/IWBEP/I_MGW_VAT'.
          SELECT SINGLE description FROM (lv_tabname) INTO ls_e071_txt-text
            WHERE technical_name = <ls_e071>-obj_name(32)
              AND version = <ls_e071>-obj_name+32(4)
              AND language = sy-langu.
          INSERT ls_e071_txt INTO TABLE ct_e071_txt.
        WHEN 'IWVO'. " SAP Gateway Business Suite Enablement - Vocabulary
          lv_tabname = '/IWBEP/I_MGW_VOT'.
          SELECT SINGLE description FROM (lv_tabname) INTO ls_e071_txt-text
            WHERE vocab_id = <ls_e071>-obj_name(32)
              AND version = <ls_e071>-obj_name+32(4)
              AND language = sy-langu.
          INSERT ls_e071_txt INTO TABLE ct_e071_txt.
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.


  METHOD /mbtools/if_cts_req_display~get_object_icon.

    CASE iv_object.
      WHEN 'G4BA'. " SAP Gateway OData V4 Backend Service Group & Assigments
        cv_icon = icon_database_table.
      WHEN 'G4BG'. " SAP Gateway OData V4 Backend Service Group & Assigments (obsolete)
        cv_icon = icon_database_table.
      WHEN 'G4BS'. " SAP Gateway OData V4 Backend Service
        cv_icon = icon_database_table.
      WHEN 'IWMO'. " SAP Gateway Business Suite Enablement - Model
        cv_icon = icon_model.
      WHEN 'IWOM'. " SAP Gateway: Model Metadata
        cv_icon = icon_model.
      WHEN 'IWPR'. " SAP Gateway BSE - Service Builder Project
        cv_icon = icon_project.
      WHEN 'IWSG'. " SAP Gateway: Service Groups Metadata
        cv_icon = icon_controlling_area.
      WHEN 'IWSV'. " SAP Gateway Business Suite Enablement - Service
        cv_icon = icon_controlling_area.
      WHEN 'IWVB'. " SAP Gateway Business Suite Enablement - Vocabulary Annotation
        cv_icon = icon_annotation.
      WHEN 'IWVO'. " SAP Gateway Business Suite Enablement - Vocabulary
        cv_icon = icon_abc.
      WHEN OTHERS.
        cv_icon = icon_dummy.
    ENDCASE.

  ENDMETHOD.


  METHOD class_constructor.

    DATA:
      ls_object_list LIKE LINE OF gt_object_list.

    ls_object_list-sign   = 'I'.
    ls_object_list-option = 'EQ'.

    ls_object_list-low = 'G4BA'. " SAP Gateway OData V4 Backend Service Group & Assigments
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'G4BG'. " SAP Gateway OData V4 Backend Service Group & Assigments (obsolete)
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'G4BS'. " SAP Gateway OData V4 Backend Service
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'IWMO'. " SAP Gateway Business Suite Enablement - Model
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'IWOM'. " SAP Gateway: Model Metadata
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'IWPR'. " SAP Gateway BSE - Service Builder Project
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'IWSG'. " SAP Gateway: Service Groups Metadata
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'IWSV'. " SAP Gateway Business Suite Enablement - Service
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'IWVB'. " SAP Gateway Business Suite Enablement - Vocabulary Annotation
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'IWVO'. " SAP Gateway Business Suite Enablement - Vocabulary
    APPEND ls_object_list TO gt_object_list.

  ENDMETHOD.
ENDCLASS.
