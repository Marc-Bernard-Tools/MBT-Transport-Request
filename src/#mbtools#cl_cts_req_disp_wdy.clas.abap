************************************************************************
* /MBTOOLS/CL_CTS_REQ_DISP_WDY
* MBT Request Display
*
* (c) MBT 2020 https://marcbernardtools.com/
************************************************************************
CLASS /mbtools/cl_cts_req_disp_wdy DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

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



CLASS /MBTOOLS/CL_CTS_REQ_DISP_WDY IMPLEMENTATION.


  METHOD /mbtools/if_cts_req_display~get_object_descriptions.

    DATA:
      ls_e071_txt TYPE /mbtools/trwbo_s_e071_txt.

    FIELD-SYMBOLS:
      <ls_e071> TYPE trwbo_s_e071.

    LOOP AT it_e071 ASSIGNING <ls_e071> WHERE object IN gt_object_list.
      CLEAR ls_e071_txt.
      MOVE-CORRESPONDING <ls_e071> TO ls_e071_txt.

      ls_e071_txt-icon = get_object_icon( <ls_e071>-object ).
      ls_e071_txt-name = <ls_e071>-obj_name.

      CASE <ls_e071>-object.
        WHEN 'WDCA'. " Web Dynpro Application Configuration
          SELECT SINGLE description FROM wdy_config_appt INTO ls_e071_txt-text
            WHERE config_id        = <ls_e071>-obj_name(32)
              AND config_type      = <ls_e071>-obj_name+32(2)
              AND config_var       = <ls_e071>-obj_name+34(6)
              AND langu            = sy-langu.
        WHEN 'WDCC'. " Web Dynpro Component Configuration
          SELECT SINGLE description FROM wdy_config_compt INTO ls_e071_txt-text
            WHERE config_id        = <ls_e071>-obj_name(32)
              AND config_type      = <ls_e071>-obj_name+32(2)
              AND config_var       = <ls_e071>-obj_name+34(6)
              AND text_id          = <ls_e071>-obj_name+40(6)
              AND langu            = sy-langu.
        WHEN 'WDRC'. " Web Dynpro Condition for a Recording Plug-In
          ls_e071_txt-text = '' ##TODO.
        WHEN 'WDRP'. " Web Dynpro Recording Plug-In
          ls_e071_txt-text = '' ##TODO.
        WHEN 'WDYA'. " Web Dynpro Application
          SELECT SINGLE description FROM wdy_applicationt INTO ls_e071_txt-text
            WHERE application_name = <ls_e071>-obj_name
              AND langu            = sy-langu.
        WHEN 'WDYC' OR 'WDYD'. " Web Dynpro Controller
          SELECT SINGLE description FROM wdy_controllert INTO ls_e071_txt-text
            WHERE component_name  = <ls_e071>-obj_name(30)
              AND controller_name = <ls_e071>-obj_name+30(30)
              AND langu           = sy-langu.
        WHEN 'WDYL'. " Web Dynpro UI-Element Library
          SELECT SINGLE display_name FROM wdy_ui_library INTO ls_e071_txt-text
            WHERE library_name = <ls_e071>-obj_name.
        WHEN 'WDYN'. " Web Dynpro Component
          SELECT SINGLE description FROM wdy_componentt INTO ls_e071_txt-text
            WHERE component_name = <ls_e071>-obj_name
              AND langu          = sy-langu.
        WHEN 'WDYV'. " Web Dynpro View
          SELECT SINGLE description FROM wdy_viewt INTO ls_e071_txt-text
            WHERE component_name = <ls_e071>-obj_name(30)
              AND view_name      = <ls_e071>-obj_name+30(30)
              AND langu          = sy-langu.
        WHEN 'SOTL' OR 'SOTS' OR 'SOTT' OR 'SOTU'. " OTR Short/Long Text
          SELECT SINGLE text FROM sotr_text INTO ls_e071_txt-text
            WHERE concept = <ls_e071>-obj_name+30(32)
              AND langu   = sy-langu.
      ENDCASE.

      INSERT ls_e071_txt INTO TABLE ct_e071_txt.
    ENDLOOP.

  ENDMETHOD.


  METHOD /mbtools/if_cts_req_display~get_object_icon.

    CASE iv_object.
      WHEN 'WDCA'. " Web Dynpro Application Configuration
        rv_icon = icon_configuration.
      WHEN 'WDCC'. " Web Dynpro Component Configuration
        rv_icon = icon_configuration.
      WHEN 'WDRC'. " Web Dynpro Condition for a Recording Plug-In
        rv_icon = icon_system_start_recording.
      WHEN 'WDRP'. " Web Dynpro Recording Plug-In
        rv_icon = icon_system_play.
      WHEN 'WDYA'. " Web Dynpro Application
        rv_icon = icon_wd_application.
      WHEN 'WDYC'. " Web Dynpro Controller
        rv_icon = icon_wd_custom_controller.
      WHEN 'WDYD'. " Web Dynpro Definition
        rv_icon = icon_wd_component.
      WHEN 'WDYL'. " Web Dynpro UI-Element Library
        rv_icon = icon_view_thumbnails.
      WHEN 'WDYN'. " Web Dynpro Component
        rv_icon = icon_wd_component.
      WHEN 'WDYV'. " Web Dynpro View
        rv_icon = icon_wd_view.
      WHEN 'SOTS' OR 'SOTT'. " OTR Short Text
        rv_icon = icon_change_text.
      WHEN 'SOTL' OR 'SOTU'. " OTR Long Text
        rv_icon = icon_annotation.
      WHEN OTHERS.
        rv_icon = icon_dummy.
    ENDCASE.

  ENDMETHOD.


  METHOD class_constructor.

    DATA:
      ls_object_list LIKE LINE OF gt_object_list.

    ls_object_list-sign   = 'I'.
    ls_object_list-option = 'EQ'.

    ls_object_list-low = 'WDCA'. " Web Dynpro Application Configuration
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'WDCC'. " Web Dynpro Component Configuration
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'WDRC'. " Web Dynpro Condition for a Recording Plug-In
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'WDRP'. " Web Dynpro Recording Plug-In
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'WDYA'. " Web Dynpro Application
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'WDYC'. " Web Dynpro Definitions
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'WDYD'. " Web Dynpro Definitions
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'WDYL'. " Web Dynpro UI Element Library
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'WDYN'. " Web Dynpro Definitions
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'WDYV'. " Web Dynpro Definitions
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SOTL'. " Web Dynpro Online Text Repository (OTR)
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SOTS'. " Web Dynpro Online Text Repository (OTR)
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SOTT'. " Web Dynpro Online Text Repository (OTR)
    APPEND ls_object_list TO gt_object_list.
    ls_object_list-low = 'SOTU'. " Web Dynpro Online Text Repository (OTR)
    APPEND ls_object_list TO gt_object_list.

  ENDMETHOD.
ENDCLASS.
