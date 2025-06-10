"Name: \TY:CL_CTS_REQUEST_TREE\ME:INSERT_OBJECT_LIST\SE:BEGIN\EI
ENHANCEMENT 0 /MBTOOLS/BC_CTS_REQUEST_TREE.
************************************************************************
* MBT Transport Request
*
* Copyright 2021 Marc Bernard <https://marcbernardtools.com/>
* SPDX-License-Identifier: GPL-3.0-only
************************************************************************
*{   INSERT         M0NK900019                                        2
*** Enhancement: BADI to get description of objects as alternativ to object names

    DATA:
      li_badi      TYPE REF TO /mbtools/bc_cts_req_display,
      lt_txt       TYPE /mbtools/trwbo_t_e071_txt,
      lv_found     TYPE abap_bool,
      lv_icon_name TYPE tv_image,
      lv_objt_name TYPE trobj_name,
      lv_disp_name TYPE trobj_name.

    GET BADI li_badi.

    IF li_badi IS BOUND.
      CALL BADI li_badi->get_object_descriptions
        EXPORTING
          it_e071     = it_objects
        CHANGING
          ct_e071_txt = lt_txt.

      SORT lt_txt.
    ENDIF.
*
*}   INSERT

  DATA: mbt_ls_e071              TYPE e071,
        mbt_ls_object_text       TYPE ko100,
        mbt_lv_pgmid             TYPE trwbo_s_e071-pgmid,
        mbt_lv_object            TYPE trwbo_s_e071-object,
        mbt_lv_obj_name          TYPE trwbo_s_e071-obj_name,
        mbt_lv_activity          TYPE tractivity,
        mbt_lv_activity_text     TYPE cus_imgact-text,
        mbt_lv_text(100)         TYPE c,
        mbt_l_node_key           TYPE seu_id,
        mbt_l_node_key_for_type  TYPE seu_id,
        mbt_l_node_key_for_name  TYPE seu_id,
        mbt_l_expander           TYPE as4flag,
        mbt_l_isfolder           TYPE as4flag,
        mbt_l_object(30)         TYPE c,
        mbt_l_info(128)          TYPE c,
        mbt_ls_item              TYPE treemlitem,
        mbt_lt_items             TYPE treemlitab.

  IF /mbtools/cl_switches=>is_active( /mbtools/cl_switches=>c_tool-mbt_transport_request ) = abap_true.

  READ TABLE it_objects INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    mbt_lv_pgmid    = '$%^&'."If we initialize with SPACE we'll fall over
    mbt_lv_object   = '$%^&'."empty e071 entries, so we init' with nonsense
    mbt_lv_activity = '$%^&'.

    SORT it_objects BY activity pgmid object obj_name.

    LOOP AT it_objects INTO mbt_ls_e071.

      IF mbt_lv_activity <> mbt_ls_e071-activity.
        IF mbt_ls_e071-activity = space.
          mbt_l_node_key_for_type = i_father_node_key.
        ELSE.

          CALL METHOD me->get_activity_text
            EXPORTING
              i_activity      = mbt_ls_e071-activity
            IMPORTING
              e_activity_text = mbt_lv_activity_text.

          CLEAR: mbt_ls_item, mbt_lt_items.
          mbt_ls_item-item_name = '1'.
          mbt_ls_item-class     = cl_list_tree_model=>item_class_text.
          mbt_ls_item-alignment = cl_list_tree_model=>align_auto.
          mbt_ls_item-font      = cl_list_tree_model=>item_font_prop.
          mbt_ls_item-text      = text-img.
          APPEND mbt_ls_item TO mbt_lt_items.

          mbt_ls_item-item_name = '2'.
          IF mbt_lv_activity_text = space.
            mbt_ls_item-text      = mbt_ls_e071-activity.
          ELSE.
            mbt_ls_item-text      = mbt_lv_activity_text.
          ENDIF.
          APPEND mbt_ls_item TO mbt_lt_items.

          mbt_l_object = mbt_ls_e071-activity.

          CALL METHOD me->add_node
            EXPORTING
              node_key_type   = sreqs_node_activity
              father_node_key = i_father_node_key
              item_table      = mbt_lt_items
              image           = 'BNONE'
              object          = mbt_l_object
            IMPORTING
              node_key        = mbt_l_node_key_for_type.

        ENDIF.
      ENDIF.

*     Move comments completely into lv_obj_name, so that the
*     text can be found in gt_object_texts and that the comment is
*     displayed completely in the object list
      IF mbt_ls_e071-pgmid(1) EQ '*'.
        mbt_ls_e071-pgmid  = '*'.
        mbt_ls_e071-object = space.
        mbt_lv_obj_name(4)   = mbt_ls_e071-pgmid.
        mbt_lv_obj_name+5(4) = mbt_ls_e071-object.
        mbt_lv_obj_name+10   = mbt_ls_e071-obj_name.
      ELSE.
        mbt_lv_obj_name      = mbt_ls_e071-obj_name.
      ENDIF.

      IF mbt_lv_activity <> mbt_ls_e071-activity
      OR mbt_lv_pgmid    <> mbt_ls_e071-pgmid
      OR mbt_lv_object   <> mbt_ls_e071-object .
        mbt_lv_activity = mbt_ls_e071-activity.
        mbt_lv_pgmid    = mbt_ls_e071-pgmid.
        mbt_lv_object   = mbt_ls_e071-object.
*       Insert new object type description

        CLEAR: mbt_ls_item, mbt_lt_items.
        mbt_ls_item-item_name = '1'.
        mbt_ls_item-class     = cl_list_tree_model=>item_class_text.
        mbt_ls_item-alignment = cl_list_tree_model=>align_auto.
        mbt_ls_item-font      = cl_list_tree_model=>item_font_prop.

        IF mbt_lv_pgmid = 'LANG'.
          READ TABLE texts_of_object_types INTO mbt_ls_object_text
                                           WITH KEY object = mbt_lv_object.
          IF sy-subrc = 0.
            CONCATENATE text-trl mbt_ls_object_text-text
                        INTO mbt_ls_item-text SEPARATED BY ' '.
            CONDENSE mbt_ls_item-text.
          ELSE.
            mbt_ls_item-text  = 'Kein Text vorhanden'(ktv).
          ENDIF.
        ELSE.
          READ TABLE texts_of_object_types INTO mbt_ls_object_text
                                     WITH KEY pgmid  = mbt_lv_pgmid
                                              object = mbt_lv_object
                                     BINARY SEARCH.
          IF sy-subrc EQ 0.
            mbt_ls_item-text  = mbt_ls_object_text-text.
          ELSE.
            mbt_ls_item-text  = 'Kein Text vorhanden'(ktv).
          ENDIF.
        ENDIF.
        APPEND mbt_ls_item TO mbt_lt_items.

        mbt_l_object   = mbt_ls_e071-pgmid.
        mbt_l_object+4 = mbt_ls_e071-object.

        CALL METHOD me->add_node
          EXPORTING
            node_key_type   = sreqs_node_objtyp
            father_node_key = mbt_l_node_key_for_type
            item_table      = mbt_lt_items
            image           = 'BNONE'
            object          = mbt_l_object
          IMPORTING
            node_key        = mbt_l_node_key_for_name.
      ENDIF.

*     Insert object
      CLEAR: mbt_ls_item, mbt_lt_items.
      mbt_ls_item-item_name = '1'.
      mbt_ls_item-class     = cl_list_tree_model=>item_class_text.
      mbt_ls_item-alignment = cl_list_tree_model=>align_auto.
      mbt_ls_item-font      = cl_list_tree_model=>item_font_prop.

*{   INSERT         M0NK900019                                        3
*
      PERFORM get_object_and_display_name IN PROGRAM /mbtools/cts_object_list
        USING lt_txt mbt_ls_e071-trkorr mbt_ls_e071-as4pos
              mbt_ls_e071-pgmid mbt_ls_e071-object
              mbt_ls_e071-objfunc mbt_ls_e071-obj_name
              'To be deleted in target system'(del)
        CHANGING lv_found lv_objt_name lv_disp_name.

      lv_icon_name = lv_objt_name(4).
      lv_objt_name = lv_objt_name+5.
*
*}   INSERT

      IF mbt_ls_e071-lang <> space.
        WRITE mbt_ls_e071-lang TO mbt_lv_text.
        mbt_ls_item-text = mbt_lv_text.
        APPEND mbt_ls_item TO mbt_lt_items.
      ENDIF.

      mbt_ls_item-item_name = '2'.

*{   REPLACE        M0NK900019                                        4
*
      IF lv_found = abap_true.
        IF lv_disp_name <> |[{ lv_objt_name }]| OR lv_icon_name = icon_delete.
          mbt_ls_item-text = |{ lv_objt_name }   { lv_disp_name }|.
        ELSE.
          mbt_ls_item-text = mbt_lv_obj_name.
        ENDIF.
      ELSE.
        mbt_ls_item-text = mbt_lv_obj_name.
      ENDIF.
*
*}   REPLACE
      APPEND mbt_ls_item TO mbt_lt_items.

      mbt_l_isfolder = ' '.
      IF mbt_ls_e071-objfunc = 'K'.
        mbt_l_isfolder = 'X'.
      ENDIF.

      mbt_l_expander = ' '.
      IF  mbt_ls_e071-objfunc = 'K'
      AND i_with_keys     <> 'X'.
        mbt_l_expander = 'X'.
      ENDIF.

      mbt_l_object    = mbt_ls_e071-trkorr.
      mbt_l_object+20 = mbt_ls_e071-as4pos.
      mbt_l_info    = mbt_ls_e071-pgmid.
      mbt_l_info+4  = mbt_ls_e071-object.
      mbt_l_info+8  = mbt_ls_e071-obj_name.

      CALL METHOD me->add_node
        EXPORTING
          node_key_type   = sreqs_node_object
          father_node_key = mbt_l_node_key_for_name
          item_table      = mbt_lt_items
          object          = mbt_l_object
          info            = mbt_l_info
          expander        = mbt_l_expander
          isfolder        = mbt_l_isfolder
          image           = lv_icon_name " 'BNONE'
        IMPORTING
          node_key        = mbt_l_node_key.

      IF  mbt_ls_e071-objfunc = 'K'
      AND i_with_keys     = 'X'.

        CALL METHOD me->insert_key_list
          EXPORTING
            i_father_node_key = mbt_l_node_key
            is_object         = mbt_ls_e071
            it_keys           = it_keys.
      ENDIF.
    ENDLOOP.
  ENDIF.

    EXIT.

  ENDIF.

ENDENHANCEMENT.
